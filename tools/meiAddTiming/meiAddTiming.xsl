<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:mei="http://www.music-encoding.org/ns/mei" exclude-result-prefixes="mei"
  xmlns:saxon="http://saxon.sf.net/" extension-element-prefixes="saxon">
  <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" standalone="no"/>
  <xsl:strip-space elements="*"/>

  <!-- ======================================================================= -->
  <!-- DESCRIPTION                                                             -->
  <!-- ======================================================================= -->

  <!-- This stylesheet adds/recalculates values for the attributes dur.ges, 
  tstamp.ges, and tstamp based either on the value of the ppq attributes in the 
  file or the value supplied in the ppqNew parameter. These attributes are useful 
  in converting MEI to one-pass, MIDI-based representations. -->

  <!-- ======================================================================= -->
  <!-- PARAMETERS                                                              -->
  <!-- ======================================================================= -->

  <!-- PARAM: ppqNew
    This parameter defines the number of pulses per quarter note for the output file.
    Suggested values are:
    9600
    960 <- Default value
    768
    96
  -->
  <xsl:param name="ppqNew" select="960"/>

  <!-- PARAM: reQuantize
      This parameter controls whether @dur.ges and @tstamp.ges values in the file are 
      copied or discarded. A value of 'false' keeps existing @tstamp.ges and @dur.ges 
      values, while any other value calculates new values using the value of the ppqNew 
      parameter.
  -->
  <xsl:param name="reQuantize" select="'false'"/>

  <!-- PARAM: rng_model_path
    This is the path to the RNG schema -->
  <xsl:param name="rng_model_path"
    >http://music-encoding.googlecode.com/svn/tags/MEI2013_v2.1.0/schemata/mei-all.rng</xsl:param>

  <!-- PARAM: sch_model_path
    This is the path to the Schematron schema -->
  <xsl:param name="sch_model_path"
    >http://music-encoding.googlecode.com/svn/tags/MEI2013_v2.1.0/schemata/mei-all.rng</xsl:param>

  <!-- ======================================================================= -->
  <!-- GLOBAL VARIABLES                                                        -->
  <!-- ======================================================================= -->

  <!-- program name -->
  <xsl:variable name="progName">
    <xsl:text>meiAddTiming.xsl</xsl:text>
  </xsl:variable>

  <!-- program version -->
  <xsl:variable name="progVersion">
    <xsl:text>v. 0.1</xsl:text>
  </xsl:variable>

  <!-- new line -->
  <xsl:variable name="nl">
    <xsl:text>&#xa;</xsl:text>
  </xsl:variable>

  <!-- ======================================================================= -->
  <!-- UTILITIES / NAMED TEMPLATES                                             -->
  <!-- ======================================================================= -->

  <xsl:template name="meiAddTiming_gesturalDurationFromWrittenDuration">
    <!-- Calculate quantized value (in ppq units) -->
    <xsl:param name="ppq"/>
    <xsl:param name="writtenDur"/>
    <xsl:param name="dots"/>
    <xsl:variable name="thisEventID">
      <xsl:value-of select="@xml:id"/>
    </xsl:variable>
    <!-- written duration in ppq units -->
    <xsl:variable name="baseDur">
      <xsl:choose>
        <xsl:when test="$writtenDur = 'long'">
          <xsl:value-of select="$ppq * 16"/>
        </xsl:when>
        <xsl:when test="$writtenDur = 'breve'">
          <xsl:value-of select="$ppq * 8"/>
        </xsl:when>
        <xsl:when test="$writtenDur = '1'">
          <xsl:value-of select="$ppq * 4"/>
        </xsl:when>
        <xsl:when test="$writtenDur = '2'">
          <xsl:value-of select="$ppq * 2"/>
        </xsl:when>
        <xsl:when test="$writtenDur = '4'">
          <xsl:value-of select="$ppq"/>
        </xsl:when>
        <xsl:when test="$writtenDur = '8'">
          <xsl:value-of select="$ppq div 2"/>
        </xsl:when>
        <xsl:when test="$writtenDur = '16'">
          <xsl:value-of select="$ppq div 4"/>
        </xsl:when>
        <xsl:when test="$writtenDur = '32'">
          <xsl:value-of select="$ppq div 8"/>
        </xsl:when>
        <xsl:when test="$writtenDur = '64'">
          <xsl:value-of select="$ppq div 16"/>
        </xsl:when>
        <xsl:when test="$writtenDur = '128'">
          <xsl:value-of select="$ppq div 32"/>
        </xsl:when>
        <xsl:when test="$writtenDur = '256'">
          <xsl:value-of select="$ppq div 64"/>
        </xsl:when>
        <xsl:when test="$writtenDur = '512'">
          <xsl:value-of select="$ppq div 128"/>
        </xsl:when>
        <xsl:when test="$writtenDur = '1024'">
          <xsl:value-of select="$ppq div 256"/>
        </xsl:when>
        <xsl:when test="$writtenDur = '2048'">
          <xsl:value-of select="$ppq div 512"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <!-- ppq value of dots -->
    <xsl:variable name="dotClicks">
      <xsl:choose>
        <xsl:when test="$dots = 1">
          <xsl:value-of select="$baseDur div 2"/>
        </xsl:when>
        <xsl:when test="$dots = 2">
          <xsl:value-of select="($baseDur div 2) div 2"/>
        </xsl:when>
        <xsl:when test="$dots = 3">
          <xsl:value-of select="(($baseDur div 2) div 2) div 2"/>
        </xsl:when>
        <xsl:when test="$dots = 4">
          <xsl:value-of select="((($baseDur div 2) div 2) div 2) div 2"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="0"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Is this event a participant in a tuplet? -->
    <xsl:variable name="tupletRatio">
      <xsl:choose>
        <xsl:when test="ancestor::mei:tuplet">
          <xsl:value-of select="concat(ancestor::mei:tuplet[1]/@num, ':',
            ancestor::mei:tuplet[1]/@numbase)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="following::mei:tupletSpan">
            <xsl:variable name="tupletParticipants">
              <xsl:value-of select="concat(@startid, '&#32;', @plist, '&#32;', @endid, '&#32;')"/>
            </xsl:variable>
            <xsl:if test="contains($tupletParticipants, concat('#', $thisEventID, '&#32;'))">
              <xsl:value-of select="concat(@num, ':', @numbase)"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <!-- modify the gestural duration determined above using the tuplet ratio -->
      <xsl:when test="$tupletRatio != ''">
        <xsl:variable name="num">
          <xsl:value-of select="number(substring-before($tupletRatio, ':'))"/>
        </xsl:variable>
        <xsl:variable name="numbase">
          <xsl:value-of select="number(substring-after($tupletRatio, ':'))"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="($baseDur + $dotClicks) &gt; $ppq">
            <xsl:value-of select="format-number((($baseDur + $dotClicks) * $num) div $numbase,
              '###0')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="format-number((($baseDur + $dotClicks) * $numbase) div $num,
              '###0')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <!-- return the unmodified gestural duration -->
      <xsl:otherwise>
        <xsl:value-of select="($baseDur + $dotClicks)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="meiAddTiming_measureDuration">
    <!-- calculates duration of a measure in ppq units -->
    <xsl:param name="meterCount"/>
    <xsl:param name="meterUnit"/>
    <xsl:param name="ppq"/>
    <!--DEBUG:-->
    <!--<xsl:variable name="errorMessage">
      <xsl:text>meterCount=</xsl:text>
      <xsl:value-of select="$meterCount"/>
      <xsl:text>, meterUnit=</xsl:text>
      <xsl:value-of select="$meterUnit"/>
      <xsl:text>, ppq=</xsl:text>
      <xsl:value-of select="$ppq"/>
    </xsl:variable>
    <xsl:message>
      <xsl:value-of select="$errorMessage"/>
    </xsl:message>-->
    <xsl:choose>
      <xsl:when test="$meterUnit = 1">
        <xsl:value-of select="($meterCount * 4) * $ppq"/>
      </xsl:when>
      <xsl:when test="$meterUnit = 2">
        <xsl:value-of select="($meterCount * $meterUnit) * $ppq"/>
      </xsl:when>
      <xsl:when test="$meterUnit = 4">
        <xsl:value-of select="$meterCount * $ppq"/>
      </xsl:when>
      <xsl:when test="$meterUnit &gt; 4">
        <xsl:value-of select="(($meterCount * 4) div $meterUnit) * $ppq"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="meiAddTiming_ppqLocal">
    <xsl:param name="thisStaff"/>
    <xsl:choose>
      <!-- preceding staff definition for this staff has ppq value -->
      <xsl:when test="preceding::mei:staffDef[@n=$thisStaff and @ppq] and $reQuantize='false'">
        <xsl:value-of select="preceding::mei:staffDef[@n=$thisStaff and @ppq][1]/@ppq"/>
      </xsl:when>
      <!-- preceding score definition has ppq value -->
      <xsl:when test="preceding::mei:scoreDef[@ppq] and $reQuantize='false'">
        <xsl:value-of select="preceding::mei:scoreDef[@ppq][1]/@ppq"/>
      </xsl:when>
      <!-- preceding event on this staff has an undotted quarter note duration and gestural duration -->
      <xsl:when test="preceding::mei:*[ancestor::mei:staff[@n=$thisStaff] and @dur='4' and
        not(@dots) and @dur.ges] and $reQuantize='false'">
        <xsl:value-of select="replace(preceding::mei:*[ancestor::mei:staff[@n=$thisStaff] and
          @dur='4' and not(@dots) and @dur.ges][1]/@dur.ges, '[^\d]+', '')"/>
      </xsl:when>
      <!-- following event on this staff has an undotted quarter note duration and gestural duration -->
      <xsl:when test="following::mei:*[ancestor::mei:staff[@n=$thisStaff] and @dur='4' and
        not(@dots) and @dur.ges] and $reQuantize='false'">
        <xsl:value-of select="replace(following::mei:*[ancestor::mei:staff[@n=$thisStaff] and
          @dur='4' and not(@dots) and @dur.ges][1]/@dur.ges, '[^\d]+', '')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$ppqNew"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- MATCH TEMPLATES                                                         -->
  <!-- ======================================================================= -->

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="mei:mei[@meiversion='2013']">
        <xsl:variable name="meiAddTiming_stage1">
          <xsl:apply-templates mode="meiAddTiming_stage1"/>
        </xsl:variable>
        <xsl:variable name="meiAddTiming_stage2">
          <xsl:apply-templates select="$meiAddTiming_stage1" mode="meiAddTiming_stage2"/>
        </xsl:variable>
        <xsl:apply-templates select="$meiAddTiming_stage2" mode="meiAddTiming_stage3"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="warning">The source file is not a 2013 version MEI file!</xsl:variable>
        <xsl:message terminate="yes">
          <xsl:value-of select="normalize-space($warning)"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:chord" mode="meiAddTiming_stage1">
    <xsl:variable name="thisStaff">
      <xsl:choose>
        <!-- use @staff when provided -->
        <xsl:when test="@staff">
          <xsl:choose>
            <xsl:when test="contains(@staff, '&#32;')">
              <xsl:value-of select="substring-before(@staff, '&#32;')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@staff"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="ancestor::mei:*[@staff]">
          <xsl:value-of select="ancestor::mei:*[@staff][1]/@staff"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="ancestor::mei:staff/@n"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="ppq">
      <xsl:call-template name="meiAddTiming_ppqLocal">
        <xsl:with-param name="thisStaff">
          <xsl:value-of select="$thisStaff"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="meterCount">
      <xsl:choose>
        <!-- preceding staff definition for this staff sets the meter count -->
        <xsl:when test="preceding::mei:staffDef[@n=$thisStaff and @meter.count]">
          <xsl:value-of select="preceding::mei:staffDef[@n=$thisStaff and
            @meter.count][1]/@meter.count"/>
        </xsl:when>
        <!-- preceding score definition sets the meter count -->
        <xsl:when test="preceding::mei:scoreDef[@meter.count]">
          <xsl:value-of select="preceding::mei:scoreDef[@meter.count][1]/@meter.count"/>
        </xsl:when>
        <!-- assume 4-beat measure -->
        <xsl:otherwise>
          <xsl:value-of select="4"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="meterUnit">
      <xsl:choose>
        <!-- preceding staff definition for this staff sets the meter unit -->
        <xsl:when test="preceding::mei:staffDef[@n=$thisStaff and @meter.unit]">
          <xsl:value-of select="preceding::mei:staffDef[@n=$thisStaff and
            @meter.unit][1]/@meter.unit"/>
        </xsl:when>
        <!-- preceding score definition sets the meter unit -->
        <xsl:when test="preceding::mei:scoreDef[@meter.unit]">
          <xsl:value-of select="preceding::mei:scoreDef[@meter.unit][1]/@meter.unit"/>
        </xsl:when>
        <!-- assume a quarter note meter unit -->
        <xsl:otherwise>
          <xsl:value-of select="4"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="measureDuration">
      <xsl:call-template name="meiAddTiming_measureDuration">
        <xsl:with-param name="ppq" select="$ppq"/>
        <xsl:with-param name="meterCount" select="$meterCount"/>
        <xsl:with-param name="meterUnit" select="$meterUnit"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="@*[not(name()='dur.ges')]"/>
      <xsl:attribute name="dur.ges">
        <xsl:choose>
          <!-- event is a grace note/chord; gestural duration = 0 -->
          <xsl:when test="@grace">
            <xsl:value-of select="0"/>
          </xsl:when>
          <!-- calculate gestural duration based on written duration -->
          <xsl:otherwise>
            <xsl:call-template name="meiAddTiming_gesturalDurationFromWrittenDuration">
              <xsl:with-param name="writtenDur">
                <xsl:choose>
                  <!-- chord has a written duration -->
                  <xsl:when test="@dur">
                    <xsl:value-of select="@dur"/>
                  </xsl:when>
                  <!-- preceding note, rest, or chord has a written duration -->
                  <xsl:when test="preceding-sibling::mei:*[(local-name()='note' or
                    local-name()='chord' or local-name()='rest') and @dur]">
                    <xsl:value-of select="preceding-sibling::mei:*[(local-name()='note'
                      or local-name()='chord' or local-name()='rest') and
                      @dur][1]/@dur"/>
                  </xsl:when>
                  <!-- following note, rest, or chord has a written duration -->
                  <xsl:when test="following-sibling::mei:*[(local-name()='note' or
                    local-name()='chord' or local-name()='rest') and @dur]">
                    <xsl:value-of select="following-sibling::mei:*[(local-name()='note'
                      or local-name()='chord' or local-name()='rest') and
                      @dur][1]/@dur"/>
                  </xsl:when>
                  <!-- when all else fails, assume a quarter note written duration -->
                  <xsl:otherwise>
                    <xsl:value-of select="4"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
              <xsl:with-param name="dots">
                <xsl:choose>
                  <!-- chord's written duration is dotted -->
                  <xsl:when test="@dots">
                    <xsl:value-of select="@dots"/>
                  </xsl:when>
                  <!-- no dots -->
                  <xsl:otherwise>
                    <xsl:value-of select="0"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
              <xsl:with-param name="ppq">
                <xsl:value-of select="$ppq"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>p</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates mode="meiAddTiming_stage1"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:meiHead | mei:music" mode="meiAddTiming_stage1">
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name()='meiversion') and
        not(local-name()='meiversion.num')]"/>
      <xsl:apply-templates mode="meiAddTiming_stage1"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:note | mei:rest | mei:space | mei:mRest | mei:mSpace"
    mode="meiAddTiming_stage1">
    <xsl:variable name="thisStaff">
      <xsl:choose>
        <!-- use @staff when provided -->
        <xsl:when test="@staff">
          <xsl:value-of select="@staff"/>
        </xsl:when>
        <!-- ancestor's @staff value -->
        <xsl:when test="ancestor::mei:*[@staff]">
          <xsl:value-of select="ancestor::mei:*[@staff][1]/@staff"/>
        </xsl:when>
        <!-- staff element -->
        <xsl:otherwise>
          <xsl:value-of select="ancestor::mei:staff/@n"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="ppq">
      <xsl:call-template name="meiAddTiming_ppqLocal">
        <xsl:with-param name="thisStaff">
          <xsl:value-of select="$thisStaff"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="meterCount">
      <xsl:choose>
        <!-- preceding staff definition for this staff sets the meter count -->
        <xsl:when test="preceding::mei:staffDef[@n=$thisStaff and @meter.count]">
          <xsl:value-of select="preceding::mei:staffDef[@n=$thisStaff and
            @meter.count][1]/@meter.count"/>
        </xsl:when>
        <!-- preceding score definition sets the meter count -->
        <xsl:when test="preceding::mei:scoreDef[@meter.count]">
          <xsl:value-of select="preceding::mei:scoreDef[@meter.count][1]/@meter.count"/>
        </xsl:when>
        <!-- assume 4-beat measure -->
        <xsl:otherwise>
          <xsl:value-of select="4"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="meterUnit">
      <xsl:choose>
        <!-- preceding staff definition for this staff sets the meter unit -->
        <xsl:when test="preceding::mei:staffDef[@n=$thisStaff and @meter.unit]">
          <xsl:value-of select="preceding::mei:staffDef[@n=$thisStaff and
            @meter.unit][1]/@meter.unit"/>
        </xsl:when>
        <!-- preceding score definition sets the meter unit -->
        <xsl:when test="preceding::mei:scoreDef[@meter.unit]">
          <xsl:value-of select="preceding::mei:scoreDef[@meter.unit][1]/@meter.unit"/>
        </xsl:when>
        <!-- assume a quarter note meter unit -->
        <xsl:otherwise>
          <xsl:value-of select="4"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="measureDuration">
      <xsl:call-template name="meiAddTiming_measureDuration">
        <xsl:with-param name="ppq" select="$ppq"/>
        <xsl:with-param name="meterCount" select="$meterCount"/>
        <xsl:with-param name="meterUnit" select="$meterUnit"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="@*[not(name()='dur.ges')]"/>
      <!-- no chord parent -->
      <xsl:if test="local-name(..) != 'chord'">
        <xsl:attribute name="dur.ges">
          <xsl:choose>
            <!-- event is a grace note/chord; gestural duration = 0 -->
            <xsl:when test="@grace">
              <xsl:value-of select="0"/>
            </xsl:when>
            <!-- event is a measure rest or space -->
            <xsl:when test="local-name()='mRest' or local-name()='mSpace'">
              <xsl:choose>
                <!-- calculate gestural duration based on written duration -->
                <xsl:when test="@dur">
                  <xsl:call-template name="meiAddTiming_gesturalDurationFromWrittenDuration">
                    <xsl:with-param name="writtenDur">
                      <xsl:value-of select="@dur"/>
                    </xsl:with-param>
                    <xsl:with-param name="dots">
                      <xsl:choose>
                        <xsl:when test="@dots">
                          <xsl:value-of select="@dots"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="0"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:with-param>
                    <xsl:with-param name="ppq">
                      <xsl:value-of select="$ppq"/>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:when>
                <!-- no written duration; use measure duration based on ppq and meter -->
                <!-- could use sum of gestural durations of events on other layer of 
                    this or some other staff, I suppose -->
                <xsl:otherwise>
                  <xsl:value-of select="$measureDuration"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <!-- event is neither grace, measure rest nor measure space -->
            <xsl:otherwise>
              <!-- calculate gestural duration based on written duration -->
              <xsl:call-template name="meiAddTiming_gesturalDurationFromWrittenDuration">
                <xsl:with-param name="writtenDur">
                  <xsl:choose>
                    <!-- event has a written duration -->
                    <xsl:when test="@dur">
                      <xsl:value-of select="@dur"/>
                    </xsl:when>
                    <!-- ancestor, such as chord, has a written duration -->
                    <xsl:when test="ancestor::mei:*[@dur]">
                      <xsl:value-of select="ancestor::mei:*[@dur][1]/@dur"/>
                    </xsl:when>
                    <!-- preceding note, rest, or chord has a written duration -->
                    <xsl:when test="preceding-sibling::mei:*[(local-name()='note' or
                      local-name()='chord' or local-name()='rest') and @dur]">
                      <xsl:value-of select="preceding-sibling::mei:*[(local-name()='note'
                        or local-name()='chord' or local-name()='rest') and
                        @dur][1]/@dur"/>
                    </xsl:when>
                    <!-- following note, rest, or chord has a written duration -->
                    <xsl:when test="following-sibling::mei:*[(local-name()='note' or
                      local-name()='chord' or local-name()='rest') and @dur]">
                      <xsl:value-of select="following-sibling::mei:*[(local-name()='note'
                        or local-name()='chord' or local-name()='rest') and
                        @dur][1]/@dur"/>
                    </xsl:when>
                    <!-- when all else fails, assume a quarter note written duration -->
                    <xsl:otherwise>
                      <xsl:value-of select="4"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="dots">
                  <xsl:choose>
                    <xsl:when test="@dots">
                      <xsl:value-of select="@dots"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="0"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:with-param>
                <xsl:with-param name="ppq">
                  <xsl:value-of select="$ppq"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text>p</xsl:text>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="meiAddTiming_stage1"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:revisionDesc" mode="meiAddTiming_stage1">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="meiAddTiming_stage1"/>
      <change xmlns="http://www.music-encoding.org/ns/mei">
        <xsl:attribute name="n">
          <xsl:value-of select="count(mei:change) + 1"/>
        </xsl:attribute>
        <respStmt/>
        <changeDesc>
          <p>
            <xsl:value-of select="normalize-space(concat('Added MIDI-like timing information
              (@dur.ges, @tstamp.ges, sometimes @tstamp) using&#32;', $progName, ', ',
              $progVersion, '.'))"/>
            <xsl:choose>
              <xsl:when test="not($reQuantize='false')">
                <xsl:value-of select="concat('&#32;', normalize-space(concat('The global value for
                  @ppq was set to&#32;',$ppqNew, '.')))"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="ancestor::mei:mei//mei:scoreDef[@ppq] or
                    ancestor::mei:mei//mei:scoreDef//mei:staffDef[@ppq]">
                    <xsl:text>&#32;Pre-existing values for @ppq were retained.</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat('&#32;', normalize-space(concat('The global value
                      for @ppq was set to&#32;', $ppqNew, '.')))"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </p>
        </changeDesc>
        <date>
          <xsl:attribute name="isodate">
            <xsl:value-of select="format-date(current-date(), '[Y]-[M02]-[D02]')"/>
          </xsl:attribute>
        </date>
      </change>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:scoreDef[not(ancestor::mei:section)]" mode="meiAddTiming_stage1">
    <xsl:copy>
      <xsl:copy-of select="@* except @ppq"/>
      <xsl:choose>
        <xsl:when test="@ppq and $reQuantize='false'">
          <!-- if existing @ppq and reQuantization isn't desired, keep the existing value of @ppq -->
          <xsl:attribute name="ppq">
            <xsl:value-of select="@ppq"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="preceding::mei:scoreDef[@ppq] and $reQuantize='false'">
          <!-- Do nothing! ppq carried forward from preceding scoreDef -->
        </xsl:when>
        <xsl:when test="descendant::mei:staffDef[@ppq]">
          <!-- Do nothing! ppq provided on individual staves -->
        </xsl:when>
        <xsl:otherwise>
          <!-- provide new value for @ppq -->
          <xsl:attribute name="ppq">
            <xsl:value-of select="$ppqNew"/>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates mode="meiAddTiming_stage1"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:staffDef[not(ancestor::mei:section)]" mode="meiAddTiming_stage1">
    <xsl:copy>
      <xsl:copy-of select="@* except @ppq"/>
      <xsl:choose>
        <xsl:when test="@ppq and $reQuantize='false'">
          <xsl:attribute name="ppq">
            <xsl:value-of select="@ppq"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <!-- Do nothing! staffDef inherits ppq value from scoreDef -->
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="not(@xml:id) and not(ancestor::mei:staffGrp[@xml:id])">
        <!-- construct a part ID. A file without XML IDs on staffDef or staffGrp elements
        will result in @xml:id being created for each staffDef. In other words, each staff
        is assumed to represent a separate part. -->
        <xsl:attribute name="xml:id">
          <xsl:value-of select="concat('P', generate-id())"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="meiAddTiming_stage1"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:*[local-name()='note' or local-name()='chord' or local-name()='rest' or
    local-name()='space' or local-name()='barLine' or local-name()='beatRpt' or
    local-name()='custos' or local-name()='halfmRpt' or local-name()='mRest' or
    local-name()='mRpt' or local-name()='mRpt2' or local-name()='mSpace' or
    local-name()='multiRest' or local-name()='multiRpt' or local-name()='pad']
    [not(ancestor::mei:chord)] | mei:layer/mei:*[local-name()='accid' or local-name()='artic' or
    local-name()='clef' or local-name()='dot']" mode="meiAddTiming_stage2">
    <xsl:variable name="thisLayer">
      <xsl:value-of select="generate-id(ancestor::mei:layer)"/>
    </xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <!-- calculate @tstamp.ges based on the sum of the gestural durations of the preceding events in the layer -->
      <xsl:attribute name="tstamp.ges">
        <xsl:value-of select="sum(preceding::mei:*[local-name()='chord' or
          local-name()='note' or local-name()='rest' or local-name()='space' or
          local-name()='mRest' or local-name()='mSpace'][not(ancestor::mei:chord)]
          [generate-id(ancestor::mei:layer)=$thisLayer]/number(substring-before(@dur.ges, 'p')))"/>
      </xsl:attribute>
      <xsl:apply-templates mode="meiAddTiming_stage2"/>
    </xsl:copy>
  </xsl:template>

  <!-- time stamps on control events are handled in the 3rd pass because they can sometimes
  only be calculated based on a time stamp added in the 2nd pass). -->
  <xsl:template match="mei:*[local-name()='arpeg' or local-name()='beamSpan' or local-name()='bend'
    or local-name()='breath' or local-name()='curve' or local-name()='dir' or
    local-name()='dynam' or local-name()='fermata' or local-name()='gliss' or
    local-name()='hairpin' or local-name()='harm' or local-name()='harpPedal' or
    local-name()='mordent' or local-name()='octave' or local-name()='pedal' or
    local-name()='phrase' or local-name()='reh' or local-name()='slur' or local-name()='tempo'
    or local-name()='tie' or local-name()='trill' or local-name()='tupletSpan' or
    local-name()='turn'][ancestor::mei:incip or ancestor::mei:body]" mode="meiAddTiming_stage3">
    <xsl:variable name="thisStaff">
      <xsl:choose>
        <xsl:when test="contains(@staff, '&#32;')">
          <xsl:value-of select="substring-before(@staff, '&#32;')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@staff"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="ppq">
      <xsl:call-template name="meiAddTiming_ppqLocal">
        <xsl:with-param name="thisStaff">
          <xsl:value-of select="$thisStaff"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="meterUnit">
      <xsl:choose>
        <!-- preceding staff definition for this staff sets the meter unit -->
        <xsl:when test="preceding::mei:staffDef[@n=$thisStaff and @meter.unit]">
          <xsl:value-of select="preceding::mei:staffDef[@n=$thisStaff and
            @meter.unit][1]/@meter.unit"/>
        </xsl:when>
        <!-- preceding score definition sets the meter unit -->
        <xsl:when test="preceding::mei:scoreDef[@meter.unit]">
          <xsl:value-of select="preceding::mei:scoreDef[@meter.unit][1]/@meter.unit"/>
        </xsl:when>
        <!-- assume a quarter note meter unit -->
        <xsl:otherwise>
          <xsl:value-of select="4"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="@* except @tstamp.ges"/>
      <xsl:attribute name="tstamp.ges">
        <xsl:choose>
          <xsl:when test="@startid or @plist">
            <xsl:variable name="thisStartID">
              <xsl:choose>
                <xsl:when test="@startid">
                  <xsl:value-of select="@startid"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="contains(@plist, '&#32;')">
                      <xsl:value-of select="substring-before(@plist, '&#32;')"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="@plist"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="preceding::mei:*[concat('#', @xml:id)=$thisStartID]/@tstamp.ges">
                <!-- use the value of @tstamp.ges from the event referenced by $thisStartID -->
                <xsl:value-of select="preceding::mei:*[concat('#',
                  @xml:id)=$thisStartID]/@tstamp.ges"/>
              </xsl:when>
              <xsl:when test="preceding::mei:*[concat('#',
                @xml:id)=$thisStartID]/ancestor::mei:*/@tstamp.ges">
                <xsl:value-of select="preceding::mei:*[concat('#',
                  @xml:id)=$thisStartID]/ancestor::mei:*[@tstamp.ges][1]/@tstamp.ges"/>
              </xsl:when>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="@tstamp">
            <xsl:choose>
              <!-- anything on the left barline or on beat 1 gets a tstamp.ges value of '0' -->
              <xsl:when test="number(@tstamp) = 0 or number(@tstamp) = 1">
                <xsl:value-of select="0"/>
              </xsl:when>
              <!-- calculate value of @tstamp.ges based on @tstamp, accounting for inadequate accuracy
              in @tstamp -->
              <xsl:when test="number(@tstamp) &gt; 0">
                <xsl:variable name="lastDigit">
                  <xsl:value-of select="substring(string(@tstamp), string-length(string(@tstamp)))"
                  />
                </xsl:variable>
                <xsl:variable name="temp">
                  <xsl:choose>
                    <xsl:when test="matches(string(@tstamp), '\.') and not(matches(string(@tstamp),
                      '\.\d{3}')) and not(matches($lastDigit, '(0|5)'))">
                      <xsl:choose>
                        <xsl:when test="$lastDigit='3'">
                          <xsl:value-of select="round-half-to-even((number(concat(string(@tstamp),
                            '333')) * $ppq) - $ppq)"/>
                        </xsl:when>
                        <xsl:when test="$lastDigit='6'">
                          <xsl:value-of select="round-half-to-even((number(concat(string(@tstamp),
                            '666')) * $ppq) - $ppq)"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="round-half-to-even((number(concat(string(@tstamp),
                            '5')) * $ppq) - $ppq)"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="round-half-to-even((number(@tstamp) * $ppq) - $ppq)"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="$meterUnit = 2">
                    <xsl:value-of select="$temp * $meterUnit"/>
                  </xsl:when>
                  <xsl:when test="$meterUnit &gt; 4">
                    <xsl:value-of select="round-half-to-even($temp div ($meterUnit div 4))"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$temp"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates mode="meiAddTiming_stage3"/>
    </xsl:copy>
  </xsl:template>

  <!-- Default template for stage1 -->
  <xsl:template match="@* | node() | comment()" mode="meiAddTiming_stage1">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="meiAddTiming_stage1"/>
    </xsl:copy>
  </xsl:template>

  <!-- Default template for stage2 -->
  <xsl:template match="@* | node() | comment()" mode="meiAddTiming_stage2">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="meiAddTiming_stage2"/>
    </xsl:copy>
  </xsl:template>

  <!-- Default template for stage3 -->
  <xsl:template match="@* | node() | comment()" mode="meiAddTiming_stage3">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="meiAddTiming_stage3"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
