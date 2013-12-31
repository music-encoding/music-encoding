<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:mei="http://www.music-encoding.org/ns/mei" exclude-result-prefixes="mei"
  xmlns:saxon="http://saxon.sf.net/" extension-element-prefixes="saxon">
  <xsl:output doctype-system="http://www.musicxml.org/dtds/timewise.dtd"
    doctype-public="-//Recordare//DTD MusicXML 2.0 Timewise//EN" method="xml" indent="yes"
    encoding="UTF-8" omit-xml-declaration="no" standalone="no"/>
  <xsl:strip-space elements="*"/>

  <!-- parameters -->
  <!-- PARAM:ppqDefault
      This parameter defines the number of pulses per quarter note when it's
      not defined in the input file. Suggested values are:
      960
      768
      96
  -->
  <xsl:param name="ppqDefault" select="960"/>

  <!-- PARAM:reQuantize
      This parameter controls whether @dur.ges values in the file are used or discarded.
      A value of 'false()' uses @dur.ges values in the file, if they exist. A value of 
      'true()' ignores any @dur.ges values in the file and calculates new values based 
      on the value of the ppqDefault parameter.
  -->
  <xsl:param name="reQuantize" select="false()"/>

  <!-- global variables -->
  <xsl:variable name="nl">
    <xsl:text>&#xa;</xsl:text>
  </xsl:variable>
  <xsl:variable name="progName">
    <xsl:text>mei2musicxml.xsl</xsl:text>
  </xsl:variable>
  <xsl:variable name="progVersion">
    <xsl:text>v. 0.2</xsl:text>
  </xsl:variable>

  <!-- 'Match' templates -->
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="mei:mei">
        <!-- $stage1 holds MusicXML-like MEI markup; that is, (mostly)
        MEI elements organized by part -->
        <xsl:variable name="stage1">
          <xsl:apply-templates select="mei:mei"/>
        </xsl:variable>
        <!--<xsl:copy-of select="$stage1"/>-->
        <xsl:apply-templates select="$stage1/*" mode="stage2"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="errorMessage">The source file is not an MEI file!</xsl:variable>
        <xsl:message terminate="yes">
          <xsl:value-of select="normalize-space($errorMessage)"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:mei">
    <score-timewise>
      <xsl:apply-templates select="mei:meiHead"/>
      <xsl:apply-templates select="mei:music/mei:body/mei:mdiv/mei:score/mei:scoreDef"
        mode="defaults"/>
      <xsl:apply-templates select="mei:music/mei:body/mei:mdiv/mei:score/mei:scoreDef"
        mode="credits"/>
      <xsl:value-of select="$nl"/>
      <part-list>
        <xsl:apply-templates
          select="mei:music/mei:body/mei:mdiv/mei:score/mei:scoreDef/mei:staffGrp" mode="partList"/>
      </part-list>
      <xsl:apply-templates select="mei:music/mei:body/mei:mdiv/mei:score//mei:measure" mode="stage1"
      />
    </score-timewise>
  </xsl:template>

  <xsl:template match="mei:anchoredText">
    <credit>
      <xsl:attribute name="page">
        <xsl:choose>
          <xsl:when test="ancestor::mei:pgHead or ancestor::mei:pgFoot">
            <xsl:value-of select="1"/>
          </xsl:when>
          <xsl:when test="ancestor::mei:pgHead2 or ancestor::mei:pgFoot2">
            <xsl:value-of select="2"/>
          </xsl:when>
        </xsl:choose>
      </xsl:attribute>
      <xsl:if test="@n">
        <credit-type>
          <xsl:value-of select="replace(@n, '_', '&#32;')"/>
        </credit-type>
      </xsl:if>
      <xsl:for-each-group select="mei:*" group-ending-with="mei:lb">
        <credit-words>
          <xsl:if test="position() = 1">
            <xsl:if test="ancestor::mei:anchoredText/@x">
              <xsl:attribute name="default-x">
                <xsl:value-of select="format-number(ancestor::mei:anchoredText/@x * 5,
                  '###0.####')"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="ancestor::mei:anchoredText/@y">
              <xsl:attribute name="default-y">
                <xsl:value-of select="format-number(ancestor::mei:anchoredText/@y * 5,
                  '###0.####')"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:if>
          <xsl:call-template name="rendition"/>
          <xsl:choose>
            <xsl:when test="processing-instruction()">
              <xsl:apply-templates select="." mode="stage1"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="creditText">
                <xsl:for-each select="current-group()">
                  <xsl:apply-templates select="." mode="stage1"/>
                  <xsl:if test="position() != last()">
                    <xsl:text>&#32;</xsl:text>
                  </xsl:if>
                </xsl:for-each>
              </xsl:variable>
              <xsl:value-of select="replace(replace($creditText, '&#32;&#32;+', '&#32;'),
                '&#xA;&#32;', '&#xA;')"/>
            </xsl:otherwise>
          </xsl:choose>
        </credit-words>
      </xsl:for-each-group>
    </credit>
  </xsl:template>

  <xsl:template match="mei:arpeg | mei:beamSpan | mei:breath | mei:fermata | mei:hairpin |
    mei:harpPedal | mei:octave | mei:pedal | mei:reh | mei:slur | mei:tie | mei:tupletSpan |
    mei:bend | mei:dir | mei:dynam | mei:harm | mei:gliss | mei:phrase| mei:tempo | mei:mordent |
    mei:trill | mei:turn" mode="stage1">
    <xsl:copy>
      <!-- copy all attributes but @staff. -->
      <xsl:copy-of select="@*[not(local-name() = 'staff')]"/>
      <xsl:if test="not(@xml:id)">
        <xsl:attribute name="xml:id">
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
      </xsl:if>
      <!-- add @staff back if it has multiple values -->
      <xsl:if test="contains(@staff, '&#32;')">
        <xsl:copy-of select="@staff"/>
      </xsl:if>
      <!-- part assignment -->
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
          <!-- use staff assignment of starting event -->
          <xsl:when test="@startid">
            <xsl:variable name="startEventID">
              <xsl:value-of select="substring(@startid, 2)"/>
            </xsl:variable>
            <xsl:choose>
              <!-- starting event has @staff -->
              <xsl:when test="preceding::mei:*[@xml:id=$startEventID and @staff]">
                <xsl:value-of select="preceding::mei:*[@xml:id=$startEventID]/@staff"/>
              </xsl:when>
              <!-- starting event has a staff element ancestor -->
              <xsl:otherwise>
                <xsl:value-of
                  select="preceding::mei:*[@xml:id=$startEventID]/ancestor::mei:staff/@n"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="partID">
        <xsl:call-template name="partID">
          <xsl:with-param name="thisStaff">
            <xsl:value-of select="$thisStaff"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:attribute name="partID">
        <xsl:value-of select="$partID"/>
      </xsl:attribute>
      <!-- staff assignment in MEI; that is, staff counted from top to bottom of score -->
      <xsl:attribute name="meiStaff">
        <xsl:value-of select="$thisStaff"/>
      </xsl:attribute>
      <!-- staff assignment in MusicXML; that is, where the numbering of staves starts over with each part -->
      <xsl:attribute name="partStaff">
        <xsl:choose>
          <xsl:when test="preceding::mei:staffGrp[@xml:id and
            mei:staffDef[@n=$thisStaff]]/mei:staffDef[@n=$thisStaff]">
            <xsl:for-each select="preceding::mei:staffGrp[@xml:id and
              mei:staffDef[@n=$thisStaff]][1]/mei:staffDef[@n=$thisStaff]">
              <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:when
            test="preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]]/mei:staffDef[@n=$thisStaff]">
            <xsl:value-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$thisStaff"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <!-- typically control events aren't assigned to a layer, but @voice
      may be necessary later for making sure the control event ends up in
      the right place in the MusicXML stream of events. -->
      <xsl:attribute name="voice">
        <xsl:choose>
          <xsl:when test="@layer">
            <xsl:value-of select="@layer"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <!-- copy contents -->
      <xsl:copy-of select="node() | text()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:availability">
    <xsl:if test="normalize-space(mei:useRestrict) != ''">
      <rights>
        <xsl:value-of select="mei:useRestrict"/>
      </rights>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:beam | mei:tuplet" mode="stage1">
    <xsl:variable name="thisStaff">
      <xsl:choose>
        <xsl:when test="@staff">
          <xsl:value-of select="@staff"/>
        </xsl:when>
        <xsl:when test="ancestor::mei:*[@staff]">
          <xsl:value-of select="ancestor::mei:*[@staff][1]/@staff"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="ancestor::mei:staff/@n"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="partID">
      <xsl:call-template name="partID">
        <xsl:with-param name="thisStaff">
          <xsl:value-of select="$thisStaff"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="ppq">
      <xsl:choose>
        <!-- preceding staff definition for this staff has ppq value -->
        <xsl:when test="preceding::mei:staffDef[@n=$thisStaff and @ppq] and not($reQuantize)">
          <xsl:value-of select="preceding::mei:staffDef[@n=$thisStaff and @ppq][1]/@ppq"/>
        </xsl:when>
        <!-- preceding score definition has ppq value -->
        <xsl:when test="preceding::mei:scoreDef[@ppq] and not($reQuantize)">
          <xsl:value-of select="preceding::mei:scoreDef[@ppq][1]/@ppq"/>
        </xsl:when>
        <!-- preceding event on this staff has an undotted quarter note duration and gestural duration -->
        <xsl:when test="preceding::mei:*[ancestor::mei:staff[@n=$thisStaff] and @dur='4' and
          not(@dots) and @dur.ges] and not($reQuantize)">
          <xsl:value-of select="replace(preceding::mei:*[ancestor::mei:staff[@n=$thisStaff] and
            @dur='4' and not(@dots) and @dur.ges][1]/@dur.ges, '[^\d]+', '')"/>
        </xsl:when>
        <!-- following event on this staff has an undotted quarter note duration and gestural duration -->
        <xsl:when test="following::mei:*[ancestor::mei:staff[@n=$thisStaff] and @dur='4' and
          not(@dots) and @dur.ges] and not($reQuantize)">
          <xsl:value-of select="replace(following::mei:*[ancestor::mei:staff[@n=$thisStaff] and
            @dur='4' and not(@dots) and @dur.ges][1]/@dur.ges, '[^\d]+', '')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$ppqDefault"/>
        </xsl:otherwise>
      </xsl:choose>
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
      <xsl:call-template name="measureDuration">
        <xsl:with-param name="ppq" select="$ppq"/>
        <xsl:with-param name="meterCount" select="$meterCount"/>
        <xsl:with-param name="meterUnit" select="$meterUnit"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:copy>
      <!-- copy all attributes except @staff and @dur.ges; these will be supplied later -->
      <xsl:copy-of select="@*[not(local-name() = 'staff') and not(name()='dur.ges')]"/>
      <xsl:attribute name="measureDuration">
        <xsl:value-of select="$measureDuration"/>
      </xsl:attribute>
      <!--<xsl:variable name="partID">
        <xsl:call-template name="partID">
          <xsl:with-param name="thisStaff">
            <xsl:value-of select="$thisStaff"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>-->
      <xsl:attribute name="partID">
        <xsl:value-of select="$partID"/>
      </xsl:attribute>
      <!-- staff assignment in MEI; that is, staff counted from top to bottom of score -->
      <xsl:attribute name="meiStaff">
        <xsl:value-of select="$thisStaff"/>
      </xsl:attribute>
      <!-- staff assignment in MusicXML; that is, where the numbering of staves starts over with each part -->
      <xsl:attribute name="partStaff">
        <xsl:variable name="thisStaff">
          <xsl:choose>
            <xsl:when test="@staff">
              <xsl:value-of select="@staff"/>
            </xsl:when>
            <xsl:when test="ancestor::mei:*[@staff]">
              <xsl:value-of select="ancestor::mei:*[@staff][1]/@staff"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$thisStaff"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <!-- use position of this staff in a preceding staff group -->
          <xsl:when test="preceding::mei:staffGrp[@xml:id and
            mei:staffDef[@n=$thisStaff]]/mei:staffDef[@n=$thisStaff]">
            <xsl:for-each select="preceding::mei:staffGrp[@xml:id and
              mei:staffDef[@n=$thisStaff]][1]/mei:staffDef[@n=$thisStaff]">
              <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
            </xsl:for-each>
          </xsl:when>
          <!-- this staff is the only one in a group -->
          <xsl:when
            test="preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]]/mei:staffDef[@n=$thisStaff]">
            <xsl:value-of select="1"/>
          </xsl:when>
          <!-- default to the MEI staff value -->
          <xsl:otherwise>
            <xsl:value-of select="$thisStaff"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <!-- At this point, voice = layer assigned in MEI -->
      <xsl:attribute name="voice">
        <xsl:value-of select="ancestor::mei:layer/@n"/>
      </xsl:attribute>
      <xsl:if test="local-name()='chord'">
        <xsl:attribute name="dur.ges">
          <xsl:choose>
            <!-- if chord has a gestural duration and requantization isn't called for, use @dur.ges value -->
            <xsl:when test="@dur.ges and not($reQuantize)">
              <xsl:value-of select="replace(@dur.ges, '[^\d]+', '')"/>
            </xsl:when>
            <!-- event is a grace note/chord; gestural duration = 0 -->
            <xsl:when test="@grace">
              <xsl:value-of select="0"/>
            </xsl:when>
            <!-- calculate gestural duration based on written duration -->
            <xsl:otherwise>
              <xsl:call-template name="gesturalDurationFromWrittenDuration">
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
        </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="comment()"/>
      <xsl:apply-templates select="mei:*" mode="stage1"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:chord" mode="stage1">
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
    <xsl:variable name="partID">
      <xsl:call-template name="partID">
        <xsl:with-param name="thisStaff">
          <xsl:value-of select="$thisStaff"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="ppq">
      <xsl:choose>
        <!-- preceding staff definition for this staff has ppq value -->
        <xsl:when test="preceding::mei:staffDef[@n=$thisStaff and @ppq] and not($reQuantize)">
          <xsl:value-of select="preceding::mei:staffDef[@n=$thisStaff and @ppq][1]/@ppq"/>
        </xsl:when>
        <!-- preceding score definition has ppq value -->
        <xsl:when test="preceding::mei:scoreDef[@ppq] and not($reQuantize)">
          <xsl:value-of select="preceding::mei:scoreDef[@ppq][1]/@ppq"/>
        </xsl:when>
        <!-- preceding event on this staff has an undotted quarter note duration and gestural duration -->
        <xsl:when test="preceding::mei:*[ancestor::mei:staff[@n=$thisStaff] and @dur='4' and
          not(@dots) and @dur.ges] and not($reQuantize)">
          <xsl:value-of select="replace(preceding::mei:*[ancestor::mei:staff[@n=$thisStaff] and
            @dur='4' and not(@dots) and @dur.ges][1]/@dur.ges, '[^\d]+', '')"/>
        </xsl:when>
        <!-- following event on this staff has an undotted quarter note duration and gestural duration -->
        <xsl:when test="following::mei:*[ancestor::mei:staff[@n=$thisStaff] and @dur='4' and
          not(@dots) and @dur.ges] and not($reQuantize)">
          <xsl:value-of select="replace(following::mei:*[ancestor::mei:staff[@n=$thisStaff] and
            @dur='4' and not(@dots) and @dur.ges][1]/@dur.ges, '[^\d]+', '')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$ppqDefault"/>
        </xsl:otherwise>
      </xsl:choose>
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
      <xsl:call-template name="measureDuration">
        <xsl:with-param name="ppq" select="$ppq"/>
        <xsl:with-param name="meterCount" select="$meterCount"/>
        <xsl:with-param name="meterUnit" select="$meterUnit"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:copy>
      <!-- copy all attributes except @dur.ges, which will be supplied later -->
      <xsl:copy-of select="@*[not(name()='dur.ges')]"/>
      <xsl:attribute name="measureDuration">
        <xsl:value-of select="$measureDuration"/>
      </xsl:attribute>
      <!--<xsl:variable name="partID">
        <xsl:call-template name="partID">
          <xsl:with-param name="thisStaff">
            <xsl:value-of select="$thisStaff"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>-->
      <xsl:attribute name="partID">
        <xsl:value-of select="$partID"/>
      </xsl:attribute>
      <!-- staff assignment in MEI; that is, staff counted from top to bottom of score -->
      <xsl:attribute name="meiStaff">
        <xsl:value-of select="$thisStaff"/>
      </xsl:attribute>

      <!-- staff assignment in MusicXML; that is, where the numbering of staves starts over with each part -->
      <xsl:attribute name="partStaff">
        <xsl:choose>
          <xsl:when test="preceding::mei:staffGrp[@xml:id and
            mei:staffDef[@n=$thisStaff]]/mei:staffDef[@n=$thisStaff]">
            <xsl:for-each select="preceding::mei:staffGrp[@xml:id and
              mei:staffDef[@n=$thisStaff]][1]/mei:staffDef[@n=$thisStaff]">
              <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:when
            test="preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]]/mei:staffDef[@n=$thisStaff]">
            <xsl:value-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$thisStaff"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>

      <!-- At this point, voice = layer assigned in MEI -->
      <xsl:attribute name="voice">
        <xsl:value-of select="ancestor::mei:layer/@n"/>
      </xsl:attribute>
      <xsl:if test="local-name()='chord'">
        <xsl:attribute name="dur.ges">
          <xsl:choose>
            <!-- if chord has a gestural duration and requantization isn't called for, use @dur.ges value -->
            <xsl:when test="@dur.ges and not($reQuantize)">
              <xsl:value-of select="replace(@dur.ges, '[^\d]+', '')"/>
            </xsl:when>
            <!-- event is a grace note/chord; gestural duration = 0 -->
            <xsl:when test="@grace">
              <xsl:value-of select="0"/>
            </xsl:when>
            <!-- calculate gestural duration based on written duration -->
            <xsl:otherwise>
              <xsl:call-template name="gesturalDurationFromWrittenDuration">
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
        </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="comment()"/>
      <xsl:apply-templates select="mei:*" mode="stage1"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:clef" mode="stage1">
    <xsl:variable name="thisStaff">
      <xsl:value-of select="ancestor::mei:staff/@n"/>
    </xsl:variable>
    <xsl:variable name="partID">
      <xsl:call-template name="partID">
        <xsl:with-param name="thisStaff">
          <xsl:value-of select="$thisStaff"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="ppq">
      <xsl:choose>
        <xsl:when test="preceding::mei:staffDef[@n=$thisStaff and @ppq] and not($reQuantize)">
          <xsl:value-of select="preceding::mei:staffDef[@n=$thisStaff and @ppq][1]/@ppq"/>
        </xsl:when>
        <xsl:when test="preceding::mei:scoreDef[@ppq] and not($reQuantize)">
          <xsl:value-of select="preceding::mei:scoreDef[@ppq][1]/@ppq"/>
        </xsl:when>
        <xsl:when test="preceding::mei:*[ancestor::mei:staff[@n=$thisStaff] and @dur='4' and
          not(@dots) and @dur.ges] and not($reQuantize)">
          <xsl:value-of select="replace(preceding::mei:*[@dur='4' and not(@dots) and
            @dur.ges][1]/@dur.ges, '[^\d]+', '')"/>
        </xsl:when>
        <xsl:when test="following::mei:*[ancestor::mei:staff[@n=$thisStaff] and @dur='4' and
          not(@dots) and @dur.ges] and not($reQuantize)">
          <xsl:value-of select="replace(following::mei:*[ancestor::mei:staff[@n=$thisStaff] and
            @dur='4' and not(@dots) and @dur.ges][1]/@dur.ges, '[^\d]+', '')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$ppqDefault"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="meterCount">
      <xsl:choose>
        <xsl:when test="preceding::mei:staffDef[@n=$thisStaff and @meter.count]">
          <xsl:value-of select="preceding::mei:staffDef[@n=$thisStaff and
            @meter.count][1]/@meter.count"/>
        </xsl:when>
        <xsl:when test="preceding::mei:scoreDef[@meter.count]">
          <xsl:value-of select="preceding::mei:scoreDef[@meter.count][1]/@meter.count"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="4"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="meterUnit">
      <xsl:choose>
        <xsl:when test="preceding::mei:staffDef[@n=$thisStaff and @meter.unit]">
          <xsl:value-of select="preceding::mei:staffDef[@n=$thisStaff and
            @meter.unit][1]/@meter.unit"/>
        </xsl:when>
        <xsl:when test="preceding::mei:scoreDef[@meter.unit]">
          <xsl:value-of select="preceding::mei:scoreDef[@meter.unit][1]/@meter.unit"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="4"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name() = 'staff') and not(name()='dur.ges')]"/>
      <!--<xsl:variable name="partID">
        <xsl:call-template name="partID">
          <xsl:with-param name="thisStaff">
            <xsl:value-of select="$thisStaff"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>-->
      <xsl:attribute name="partID">
        <xsl:value-of select="$partID"/>
      </xsl:attribute>
      <!-- staff assignment in MEI; that is, staff counted from top to bottom of score -->
      <xsl:attribute name="meiStaff">
        <xsl:value-of select="$thisStaff"/>
      </xsl:attribute>
      <!-- staff assignment in MusicXML; that is, where the numbering of staves starts over with each part -->
      <xsl:attribute name="partStaff">
        <xsl:choose>
          <xsl:when test="preceding::mei:staffGrp[@xml:id and
            mei:staffDef[@n=$thisStaff]]/mei:staffDef[@n=$thisStaff]">
            <xsl:for-each select="preceding::mei:staffGrp[@xml:id and
              mei:staffDef[@n=$thisStaff]][1]/mei:staffDef[@n=$thisStaff]">
              <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:when
            test="preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]]/mei:staffDef[@n=$thisStaff]">
            <xsl:value-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$thisStaff"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <!-- At this point, voice = layer assigned in MEI -->
      <xsl:attribute name="voice">
        <xsl:value-of select="ancestor::mei:layer/@n"/>
      </xsl:attribute>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:arpeg | mei:dir | mei:dynam | mei:pedal | mei:tempo" mode="addTstamp.ges">
    <xsl:param name="events"/>
    <xsl:param name="localScoreDef"/>
    <xsl:param name="defaultScoreDef"/>
    <xsl:variable name="ppq">
      <xsl:variable name="thisStaff">
        <xsl:value-of select="@meiStaff"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$localScoreDef//mei:staffDef[@n=$thisStaff and @ppq] and
          not($reQuantize)">
          <xsl:value-of select="$localScoreDef//mei:staffDef[@n=$thisStaff and @ppq][1]/@ppq"/>
        </xsl:when>
        <xsl:when test="$localScoreDef//mei:scoreDef[@ppq] and not($reQuantize)">
          <xsl:value-of select="$localScoreDef//mei:scoreDef[@ppq][1]/@ppq"/>
        </xsl:when>
        <xsl:when test="$defaultScoreDef//mei:staffDef[@n=$thisStaff and @ppq] and
          not($reQuantize)">
          <xsl:value-of select="$defaultScoreDef//mei:staffDef[@n=$thisStaff and @ppq][1]/@ppq"/>
        </xsl:when>
        <xsl:when test="$defaultScoreDef//mei:scoreDef[@ppq] and not($reQuantize)">
          <xsl:value-of select="$defaultScoreDef//mei:scoreDef[@ppq][1]/@ppq"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$ppqDefault"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:choose>
        <xsl:when test="@startid or @plist">
          <!-- Do nothing! Directive is attached to specific note(s) -->
        </xsl:when>
        <xsl:when test="@tstamp">
          <!-- @tstamp.ges is needed to merge directive into event stream -->
          <xsl:if test="not(@tstamp.ges)">
            <xsl:attribute name="tstamp.ges">
              <xsl:variable name="thisStartID">
                <xsl:value-of select="@startid"/>
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="$events/part/*[concat('#', @xml:id)=$thisStartID]">
                  <xsl:value-of select="$events/part/*[concat('#',
                    @xml:id)=$thisStartID]/@tstamp.ges"/>
                </xsl:when>
                <xsl:when test="number(@tstamp) = 1">
                  <xsl:value-of select="0"/>
                </xsl:when>
                <xsl:when test="number(@tstamp) &gt; 0">
                  <xsl:variable name="ppqTemp">
                    <xsl:value-of select="number(@tstamp) * $ppq"/>
                  </xsl:variable>
                  <xsl:choose>
                    <xsl:when test="$ppqTemp &gt; $ppq">
                      <xsl:value-of select="$ppqTemp - $ppq"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$ppqTemp"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>0</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </xsl:if>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates mode="addTstamp.ges"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:fileDesc" mode="source">
    <xsl:for-each select="mei:titleStmt">
      <xsl:variable name="creators">
        <xsl:variable name="creatorString">
          <xsl:value-of select="mei:respStmt/*[@role='creator' or @role='composer' or
            @role='librettist' or @role='lyricist' or @role='arranger']"/>
        </xsl:variable>
        <xsl:variable name="separator">
          <xsl:choose>
            <xsl:when test="contains($creatorString, ',')">
              <xsl:text>;&#32;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>,&#32;</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="distinct-values(mei:respStmt/*[@role='creator' or @role='composer' or
          @role='librettist' or @role='lyricist' or @role='arranger'])">
          <xsl:value-of select="replace(., '\.+', '.')"/>
          <xsl:if test="position() != last()">
            <xsl:value-of select="$separator"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="encoders">
        <xsl:variable name="encoderString">
          <xsl:value-of select="mei:respStmt/*[@role='encoder']"/>
        </xsl:variable>
        <xsl:variable name="separator">
          <xsl:choose>
            <xsl:when test="contains($encoderString, ',')">
              <xsl:text>;&#32;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>,&#32;</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="mei:respStmt/*[@role='encoder']">
          <xsl:value-of select="replace(., '[.:,;+/ ]+$', '')"/>
          <xsl:if test="position() != last()">
            <xsl:value-of select="$separator"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="title">
        <xsl:for-each select="mei:title">
          <xsl:value-of select="replace(., '[.:,;+/ ]+$', '')"/>
          <xsl:if test="position() != last()">
            <xsl:text>,&#32;</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="publisher">
        <xsl:for-each select="../mei:pubStmt/mei:respStmt[1]/mei:*">
          <xsl:value-of select="replace(., '[.:,;+/ ]+$', '')"/>
          <xsl:if test="position() != last()">
            <xsl:text>,&#32;</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="pubPlace">
        <xsl:for-each select="../mei:pubStmt/mei:address[1]/mei:addrLine">
          <xsl:value-of select="replace(., '[.:,;+/ ]+$', '')"/>
          <xsl:if test="position() != last()">
            <xsl:text>,&#32;</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="pubDate">
        <xsl:value-of select="../mei:pubStmt/mei:date[1]"/>
      </xsl:variable>
      <xsl:if test="normalize-space($creators) != ''">
        <xsl:value-of select="normalize-space($creators)"/>
        <xsl:if test="not(matches(normalize-space($creators), '\.$'))">
          <xsl:text>.</xsl:text>
        </xsl:if>
        <xsl:if test="normalize-space($title) != ''">
          <xsl:text>&#32;</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="normalize-space($title) != ''">
        <xsl:value-of select="normalize-space($title)"/>
        <xsl:if test="not(matches(normalize-space($title), '\.$'))">
          <xsl:text>.</xsl:text>
        </xsl:if>
        <xsl:if test="normalize-space($encoders) != ''">
          <xsl:text>&#32;</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="normalize-space($encoders) != ''">
        <xsl:text>Encoded by&#32;</xsl:text>
        <xsl:value-of select="normalize-space($encoders)"/>
        <xsl:if test="not(matches(normalize-space($encoders), '\.$'))">
          <xsl:text>.</xsl:text>
        </xsl:if>
        <xsl:if test="normalize-space($publisher) != ''">
          <xsl:text>&#32;</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="normalize-space($publisher) != ''">
        <xsl:value-of select="normalize-space($publisher)"/>
        <xsl:if test="normalize-space($publisher) != ''">
          <xsl:text>:&#32;</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="normalize-space($pubPlace) != ''">
        <xsl:value-of select="normalize-space($pubPlace)"/>
        <xsl:if test="normalize-space($pubPlace) != ''">
          <xsl:text>,&#32;</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="normalize-space($pubDate) != ''">
        <xsl:value-of select="$pubDate"/>
        <xsl:if test="not(matches(normalize-space($pubDate), '\.$'))">
          <xsl:text>.</xsl:text>
        </xsl:if>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mei:meiHead">
    <xsl:choose>
      <xsl:when test="mei:workDesc/mei:work">
        <xsl:apply-templates select="mei:workDesc/mei:work"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="mei:fileDesc/mei:sourceDesc/mei:source[1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:identifier" mode="workTitle">
    <!-- Do nothing! Exclude identifier from title content -->
  </xsl:template>

  <xsl:template match="mei:instrDef" mode="partList">
    <score-instrument>
      <xsl:attribute name="id">
        <xsl:choose>
          <xsl:when test="@xml:id">
            <xsl:value-of select="@xml:id"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>I</xsl:text>
            <xsl:value-of select="count(preceding::mei:instrDef) + 1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <instrument-name>
        <xsl:value-of select="replace(@midi.instrname, '_', '&#32;')"/>
      </instrument-name>
    </score-instrument>
    <midi-instrument>
      <xsl:attribute name="id">
        <xsl:attribute name="id">
          <xsl:choose>
            <xsl:when test="@xml:id">
              <xsl:value-of select="@xml:id"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>I</xsl:text>
              <xsl:value-of select="count(preceding::mei:instrDef) + 1"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:attribute>
      <xsl:if test="@midi.channel">
        <midi-channel>
          <xsl:value-of select="@midi.channel"/>
        </midi-channel>
      </xsl:if>
      <xsl:if test="@midi.instrnum">
        <midi-program>
          <!-- MusicXML uses 1-based program numbers -->
          <xsl:value-of select="@midi.instrnum + 1"/>
        </midi-program>
      </xsl:if>
      <xsl:if test="@midi.volume">
        <volume>
          <!-- MusicXML uses scaling factor instead of actual MIDI value -->
          <xsl:value-of select="round((@midi.volume * 100) div 127)"/>
        </volume>
      </xsl:if>
      <xsl:if test="@midi.pan">
        <pan>
          <!-- Placement within stereo sound field (left=0, right=127) -->
          <xsl:choose>
            <xsl:when test="@midi.pan = 63 or @midi.pan = 64">
              <xsl:value-of select="0"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="round(-90 + ((180 div 127) * @midi.pan))"/>
            </xsl:otherwise>
          </xsl:choose>
        </pan>
      </xsl:if>
    </midi-instrument>
  </xsl:template>

  <xsl:template match="mei:lb" mode="stage1">
    <xsl:text>&#xA;</xsl:text>
  </xsl:template>

  <xsl:template match="mei:measure" mode="stage1">
    <measure>
      <!-- DEBUG: -->
      <xsl:copy-of select="@*"/>

      <xsl:variable name="thisMeasure">
        <xsl:value-of select="@xml:id"/>
      </xsl:variable>

      <xsl:variable name="measureNum">
        <xsl:value-of select="@n"/>
      </xsl:variable>

      <xsl:variable name="sb">
        <xsl:choose>
          <!-- system break between this measure and the previous one -->
          <xsl:when
            test="preceding-sibling::mei:sb[preceding-sibling::mei:measure[following-sibling::mei:measure[1][@xml:id=$thisMeasure]]]">
            <xsl:copy-of
              select="preceding-sibling::mei:sb[preceding-sibling::mei:measure[following-sibling::mei:measure[@xml:id=$thisMeasure]]][1]"
            />
          </xsl:when>
          <!-- system break preceding first measure -->
          <!--<xsl:when test="preceding-sibling::mei:sb">
            <xsl:copy-of select="preceding-sibling::mei:sb[1]"/>
          </xsl:when>-->
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="pb">
        <xsl:choose>
          <!-- page breaks between this measure and the previous one -->
          <xsl:when
            test="preceding-sibling::mei:pb[preceding-sibling::mei:measure[following-sibling::mei:measure[1][@xml:id=$thisMeasure]]]">
            <xsl:copy-of
              select="preceding-sibling::mei:pb[preceding-sibling::mei:measure[following-sibling::mei:measure[1][@xml:id=$thisMeasure]]]"
            />
          </xsl:when>
          <!-- page breaks preceding first measure -->
          <xsl:when test="not(preceding-sibling::mei:measure) and preceding-sibling::mei:pb">
            <xsl:copy-of select="preceding-sibling::mei:pb"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>

      <!-- defaultScoreDef contains the top-level score definition with new ppq values 
      (if requested). It will be used to resolve staves to parts when local modifications
      are encountered in measures other than the first. -->
      <xsl:variable name="defaultScoreDef">
        <scoreDef xmlns="http://www.music-encoding.org/ns/mei"
          xmlns:xlink="http://www.w3.org/1999/xlink">
          <xsl:attribute name="defaultScoreDef">
            <xsl:value-of select="true()"/>
          </xsl:attribute>
          <xsl:choose>
            <!-- reQuantize -->
            <xsl:when test="$reQuantize">
              <!-- copy all attributes but @ppq, add new @ppq on scoreDef -->
              <xsl:copy-of select="//mei:music//mei:score/mei:scoreDef/@*[not(local-name()='ppq')]"/>
              <xsl:attribute name="ppq">
                <xsl:value-of select="$ppqDefault"/>
              </xsl:attribute>
              <!-- remove @ppq on descendants -->
              <xsl:apply-templates
                select="//mei:music//mei:score/mei:scoreDef/mei:*[not(starts-with(local-name(),
                'pg'))]" mode="dropPPQ"/>
            </xsl:when>
            <xsl:otherwise>
              <!-- copy attributes and descendants unchanged -->
              <xsl:copy-of select="//mei:music//mei:score/mei:scoreDef/@*"/>
              <xsl:apply-templates
                select="//mei:music//mei:score/mei:scoreDef/mei:*[not(starts-with(local-name(),
                'pg'))]" mode="addStaffPartID"/>
              <!--<xsl:copy-of
                select="//mei:music//mei:score/mei:scoreDef/mei:*[not(starts-with(local-name(),
                'pg'))]"/>-->
            </xsl:otherwise>
          </xsl:choose>
        </scoreDef>
      </xsl:variable>

      <xsl:variable name="localScoreDef">
        <!-- initial measure gets a signal to create default "attributes" -->
        <xsl:if test="count(preceding::mei:measure[not(ancestor::mei:incip)])=0">
          <mei:initialAttributes/>
        </xsl:if>
        <!-- copy any scoreDef or staffDef elements between this measure and the 
              previous one (with changes in ppq, if requested) -->
        <xsl:for-each
          select="preceding-sibling::mei:scoreDef[preceding-sibling::mei:measure[following-sibling::mei:measure[1][@xml:id=$thisMeasure]]]
          |
          preceding-sibling::mei:scoreDef[ancestor::mei:section[mei:measure[1][@xml:id=$thisMeasure]]]
          |
          preceding-sibling::mei:staffDef[ancestor::mei:section[mei:measure[1][@xml:id=$thisMeasure]]]
          |
          preceding-sibling::mei:staffDef[preceding-sibling::mei:measure[following-sibling::mei:measure[1][@xml:id=$thisMeasure]]]">
          <xsl:choose>
            <xsl:when test="local-name()='scoreDef'">
              <scoreDef xmlns="http://www.music-encoding.org/ns/mei"
                xmlns:xlink="http://www.w3.org/1999/xlink">
                <xsl:choose>
                  <!-- reQuantize -->
                  <xsl:when test="$reQuantize">
                    <!-- copy all attributes but @ppq -->
                    <xsl:copy-of select="@*[not(local-name()='ppq')]"/>
                    <!-- remove @ppq on descendants -->
                    <xsl:apply-templates select="mei:*[not(starts-with(local-name(), 'pg'))]"
                      mode="dropPPQ"/>
                  </xsl:when>
                  <!-- copy attributes and descendants unchanged -->
                  <xsl:otherwise>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates select="mei:*[not(starts-with(local-name(), 'pg'))]"
                      mode="addStaffPartID"/>
                    <!--<xsl:copy-of select="mei:*[not(starts-with(local-name(), 'pg'))]"/>-->
                  </xsl:otherwise>
                </xsl:choose>
              </scoreDef>
            </xsl:when>
            <xsl:when test="local-name()='staffDef'">
              <staffDef xmlns="http://www.music-encoding.org/ns/mei"
                xmlns:xlink="http://www.w3.org/1999/xlink">
                <xsl:choose>
                  <!-- reQuantize -->
                  <xsl:when test="$reQuantize">
                    <!-- copy all attributes but @ppq -->
                    <xsl:copy-of select="@*[not(local-name()='ppq')]"/>
                  </xsl:when>
                  <!-- copy attributes and descendants unchanged -->
                  <xsl:otherwise>
                    <xsl:copy-of select="@*"/>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="not(@xml:id)">
                  <xsl:attribute name="xml:id">
                    <xsl:text>P</xsl:text>
                    <xsl:value-of select="generate-id()"/>
                  </xsl:attribute>
                </xsl:if>
              </staffDef>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>

      <!-- DEBUG: -->
      <!--<xsl:copy-of select="$localScoreDef"/>-->
      <!--<xsl:copy-of select="$defaultScoreDef"/>-->

      <!-- Measure content pass 1 -->
      <xsl:variable name="measureContent">
        <xsl:copy-of select="comment()"/>
        <events>
          <xsl:apply-templates select="mei:staff/mei:layer/* | mei:staff/comment() |
            mei:staff/mei:layer/comment()" mode="stage1"/>
        </events>
        <controlevents>
          <xsl:apply-templates select="*[not(local-name()='staff') and not(name()='')]"
            mode="stage1"/>
        </controlevents>
      </xsl:variable>

      <!-- DEBUG: -->
      <!--<xsl:copy-of select="$measureContent"/>-->

      <!-- Measure content pass 2: group events by part and voice -->
      <xsl:variable name="measureContent2">
        <xsl:copy-of select="$measureContent/comment()"/>
        <xsl:for-each-group select="$measureContent/events/*" group-by="@partID">
          <part id="{@partID}">
            <xsl:for-each-group select="current-group()" group-by="@voice">
              <xsl:for-each-group select="current-group()" group-by="@meiStaff">
                <voice>
                  <xsl:copy-of select="current-group()"/>
                </voice>
              </xsl:for-each-group>
            </xsl:for-each-group>
          </part>
        </xsl:for-each-group>
        <!-- carry along control events for now -->
        <xsl:copy-of select="$measureContent/controlevents"/>
      </xsl:variable>

      <!-- DEBUG: -->
      <!--<xsl:copy-of select="$measureContent2"/>-->

      <!-- Measure content pass 3: number voices -->
      <xsl:variable name="measureContent3">
        <xsl:copy-of select="$measureContent2/comment()"/>
        <xsl:for-each select="$measureContent2/part">
          <part>
            <xsl:copy-of select="@*"/>
            <xsl:for-each select="voice">
              <xsl:sort select="*[@meiStaff][1]/@meiStaff"/>
              <xsl:sort select="*[@meiStaff][1]/@voice"/>
              <voice>
                <xsl:for-each select="*">
                  <xsl:copy>
                    <xsl:copy-of select="@*[not(local-name()='voice')]"/>
                    <xsl:attribute name="voice">
                      <xsl:for-each select="ancestor::voice">
                        <xsl:value-of select="count(preceding-sibling::voice) + 1"/>
                      </xsl:for-each>
                    </xsl:attribute>
                    <xsl:copy-of select="* | comment() | text()"/>
                  </xsl:copy>
                </xsl:for-each>
              </voice>
            </xsl:for-each>
          </part>
        </xsl:for-each>
        <!-- carry along control events for now -->
        <xsl:copy-of select="$measureContent2/controlevents"/>
      </xsl:variable>

      <!-- DEBUG: -->
      <!--<xsl:copy-of select="$measureContent3"/>-->

      <!-- Measure content pass 4: add tstamp.ges to voice chldren; replace voice elements with <backup> delimiter -->
      <xsl:variable name="measureContent4">
        <xsl:copy-of select="$measureContent3/comment()"/>
        <xsl:for-each select="$measureContent3/part">
          <part>
            <xsl:copy-of select="@*"/>
            <xsl:for-each select="voice">
              <xsl:variable name="voiceContent">
                <xsl:copy-of select="*"/>
              </xsl:variable>
              <xsl:apply-templates select="$voiceContent/*" mode="addTstamp.ges"/>
              <xsl:if test="position() != last()">
                <backup>
                  <duration>
                    <xsl:variable name="backupDuration">
                      <xsl:value-of select="sum(mei:*//@dur.ges)"/>
                    </xsl:variable>
                    <xsl:choose>
                      <xsl:when test="$backupDuration &gt; 0">
                        <!-- backup value = the sum of the preceding events in this voice -->
                        <xsl:value-of select="$backupDuration"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <!-- backup to beginning of measure -->
                        <xsl:value-of select="mei:*[@measureDuration][1]/@measureDuration"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </duration>
                </backup>
              </xsl:if>
            </xsl:for-each>
          </part>
        </xsl:for-each>
        <!-- carry along control events for now -->
        <xsl:copy-of select="$measureContent3/controlevents"/>
      </xsl:variable>

      <!-- DEBUG: -->
      <!--<xsl:copy-of select="$measureContent4"/>-->

      <!-- Measure content pass 5: re-wrap sorted events in <events>; copy control events into appropriate part -->
      <xsl:variable name="measureContent5">
        <xsl:copy-of select="$measureContent4/comment()"/>
        <xsl:for-each select="$measureContent4/part">
          <part>
            <xsl:copy-of select="@*"/>
            <events>
              <xsl:copy-of select="*"/>
            </events>
            <xsl:variable name="partID">
              <xsl:value-of select="@id"/>
            </xsl:variable>
            <controlevents>
              <xsl:apply-templates select="$measureContent4/controlevents/*[@partID=$partID] |
                $measureContent4/controlevents/comment()" mode="addTstamp.ges">
                <xsl:with-param name="events">
                  <xsl:copy-of select="."/>
                </xsl:with-param>
                <xsl:with-param name="localScoreDef">
                  <xsl:copy-of select="$localScoreDef"/>
                </xsl:with-param>
                <xsl:with-param name="defaultScoreDef">
                  <xsl:copy-of select="$defaultScoreDef"/>
                </xsl:with-param>
              </xsl:apply-templates>
            </controlevents>
          </part>
        </xsl:for-each>
      </xsl:variable>

      <!-- DEBUG: -->
      <!--<xsl:copy-of select="$measureContent5"/>-->

      <!-- Measure content pass 6: if there are any page or system breaks or score
        definitions between this measure and the previous one, copy/resolve them 
        into the appropriate part -->
      <xsl:variable name="measureContent6">
        <xsl:copy-of select="$measureContent5/comment()"/>
        <xsl:for-each select="$measureContent5/part">
          <xsl:variable name="thisPart">
            <xsl:value-of select="@id"/>
          </xsl:variable>
          <part>
            <xsl:copy-of select="@*"/>
            <!-- if it's not empty, $localScoreDef will contain any local modifications and an initial
              measure flag for the initial measure, but only local modifications in subsequent measures -->
            <xsl:if test="$localScoreDef/mei:scoreDef or $localScoreDef/mei:staffDef | $sb/* |
              $pb/*">
              <xsl:variable name="printInstructions">
                <print>
                  <xsl:if test="$sb/*">
                    <xsl:attribute name="new-system">
                      <xsl:text>yes</xsl:text>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="$pb/*">
                    <xsl:attribute name="new-page">
                      <xsl:text>yes</xsl:text>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="$pb/mei:pb[last()]/@n">
                    <xsl:attribute name="page-number">
                      <xsl:value-of select="$pb/mei:pb[last()]/@n"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="$pb/mei:pb[following-sibling::mei:*[1][local-name()='pb']]">
                    <xsl:attribute name="blank-page">
                      <xsl:value-of
                        select="count($pb/mei:pb[following-sibling::mei:*[1][local-name()='pb']])"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="$localScoreDef/mei:scoreDef/@*[starts-with(local-name(),
                    'page')]">
                    <page-layout>
                      <xsl:for-each select="$localScoreDef/mei:scoreDef[@page.height][last()]">
                        <page-height>
                          <xsl:value-of select="format-number(number(replace(@page.height,
                            '[a-z]+$', '')) * 5, '###0.####')"/>
                        </page-height>
                      </xsl:for-each>
                      <xsl:for-each select="$localScoreDef/mei:scoreDef[@page.width][last()]">
                        <page-width>
                          <xsl:value-of select="format-number(number(replace(@page.width, '[a-z]+$',
                            '')) * 5, '###0.####')"/>
                        </page-width>
                      </xsl:for-each>
                      <xsl:if test="$localScoreDef/mei:scoreDef/@*[matches(local-name(),
                        'page\.(left|right|top|bot)mar')]">
                        <page-margins type="both">
                          <xsl:for-each select="$localScoreDef/mei:scoreDef[@page.leftmar][last()]">
                            <left-margin>
                              <xsl:choose>
                                <xsl:when test="replace(@page.leftmar, '[a-z]+$', '') = '0'">
                                  <xsl:value-of select="@page.leftmar"/>
                                </xsl:when>
                                <xsl:when test="number(replace(@page.leftmar, '[a-z]+$', ''))">
                                  <xsl:value-of select="format-number(number(replace(@page.leftmar,
                                    '[a-z]+$', '')) * 5, '###0.####')"/>
                                </xsl:when>
                              </xsl:choose>
                            </left-margin>
                          </xsl:for-each>
                          <xsl:for-each select="$localScoreDef/mei:scoreDef[@page.rightmar][last()]">
                            <right-margin>
                              <xsl:choose>
                                <xsl:when test="replace(@page.rightmar, '[a-z]+$', '') = '0'">
                                  <xsl:value-of select="@page.rightmar"/>
                                </xsl:when>
                                <xsl:when test="number(replace(@page.rightmar, '[a-z]+$', ''))">
                                  <xsl:value-of select="format-number(number(replace(@page.rightmar,
                                    '[a-z]+$', '')) * 5, '###0.####')"/>
                                </xsl:when>
                              </xsl:choose>
                            </right-margin>
                          </xsl:for-each>
                          <xsl:for-each select="$localScoreDef/mei:scoreDef[@page.topmar][last()]">
                            <top-margin>
                              <xsl:choose>
                                <xsl:when test="replace(@page.topmar, '[a-z]+$', '') = '0'">
                                  <xsl:value-of select="@page.topmar"/>
                                </xsl:when>
                                <xsl:when test="number(replace(@page.topmar, '[a-z]+$', ''))">
                                  <xsl:value-of select="format-number(number(replace(@page.topmar,
                                    '[a-z]+$', '')) * 5, '###0.####')"/>
                                </xsl:when>
                              </xsl:choose>
                            </top-margin>
                          </xsl:for-each>
                          <xsl:for-each select="$localScoreDef/mei:scoreDef[@page.botmar][last()]">
                            <bottom-margin>
                              <xsl:choose>
                                <xsl:when test="replace(@page.botmar, '[a-z]+$', '') = '0'">
                                  <xsl:value-of select="@page.botmar"/>
                                </xsl:when>
                                <xsl:when test="number(replace(@page.botmar, '[a-z]+$', ''))">
                                  <xsl:value-of select="format-number(number(replace(@page.botmar,
                                    '[a-z]+$', '')) * 5, '###0.####')"/>
                                </xsl:when>
                              </xsl:choose>
                            </bottom-margin>
                          </xsl:for-each>
                        </page-margins>
                      </xsl:if>
                    </page-layout>
                  </xsl:if>
                  <xsl:if test="$localScoreDef/mei:scoreDef/@*[starts-with(local-name(),
                    'system') or starts-with(local-name(), 'spacing.system')]">
                    <system-layout>
                      <xsl:if test="$localScoreDef/mei:scoreDef/@*[matches(local-name(),
                        'system\.(left|right)mar')]">
                        <system-margins>
                          <xsl:for-each
                            select="$localScoreDef/mei:scoreDef[@system.leftmar][last()]">
                            <left-margin>
                              <xsl:choose>
                                <xsl:when test="replace(@system.leftmar, '[a-z]+$', '') = '0'">
                                  <xsl:value-of select="@system.leftmar"/>
                                </xsl:when>
                                <xsl:when test="number(replace(@system.leftmar, '[a-z]+$', ''))">
                                  <xsl:value-of
                                    select="format-number(number(replace(@system.leftmar,
                                    '[a-z]+$', ''))* 5,
                                    '###0.####')"/>
                                </xsl:when>
                              </xsl:choose>
                            </left-margin>
                          </xsl:for-each>
                          <xsl:for-each
                            select="$localScoreDef/mei:scoreDef[@system.rightmar][last()]">
                            <right-margin>
                              <xsl:choose>
                                <xsl:when test="replace(@system.rightmar, '[a-z]+$', '') = '0'">
                                  <xsl:value-of select="@system.rightmar"/>
                                </xsl:when>
                                <xsl:when test="number(replace(@system.rightmar, '[a-z]+$', ''))">
                                  <xsl:value-of
                                    select="format-number(number(replace(@system.rightmar,
                                    '[a-z]+$', '')) * 5, '###0.####')"/>
                                </xsl:when>
                              </xsl:choose>
                            </right-margin>
                          </xsl:for-each>
                        </system-margins>
                      </xsl:if>
                      <xsl:for-each select="$localScoreDef/mei:scoreDef[@spacing.system][last()]">
                        <system-distance>
                          <xsl:choose>
                            <xsl:when test="replace(@spacing.system, '[a-z]+$', '') = '0'">
                              <xsl:value-of select="@spacing.system"/>
                            </xsl:when>
                            <xsl:when test="number(replace(@spacing.system, '[a-z]+$', ''))">
                              <xsl:value-of select="format-number(number(replace(@spacing.system,
                                '[a-z]+$', '')) * 5, '###0.####')"/>
                            </xsl:when>
                          </xsl:choose>
                        </system-distance>
                      </xsl:for-each>
                      <xsl:for-each select="$localScoreDef/mei:scoreDef[@system.topmar][last()]">
                        <top-system-distance>
                          <xsl:choose>
                            <xsl:when test="replace(@system.topmar, '[a-z]+$', '') = '0'">
                              <xsl:value-of select="@system.topmar"/>
                            </xsl:when>
                            <xsl:when test="number(replace(@system.topmar, '[a-z]+$', ''))">
                              <xsl:value-of select="format-number(number(replace(@system.topmar,
                                '[a-z]+$', '')) * 5, '###0.####')"/>
                            </xsl:when>
                          </xsl:choose>
                        </top-system-distance>
                      </xsl:for-each>
                    </system-layout>
                  </xsl:if>
                  <xsl:variable name="staffLayout">
                    <xsl:choose>
                      <!-- local definitions present; look for distances on staff definitions -->
                      <xsl:when test="$localScoreDef//mei:staffDef[@spacing]">
                        <xsl:for-each select="$localScoreDef//mei:staffDef[@spacing]">
                          <xsl:variable name="thisStaff">
                            <xsl:value-of select="@n"/>
                          </xsl:variable>
                          <!-- the part this staff belongs to -->
                          <xsl:variable name="staffPart">
                            <xsl:choose>
                              <xsl:when
                                test="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]]">
                                <xsl:value-of
                                  select="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]]/@xml:id"
                                />
                              </xsl:when>
                              <xsl:when test="$defaultScoreDef//mei:staffDef[@xml:id and
                                @n=$thisStaff]">
                                <xsl:value-of select="$defaultScoreDef//mei:staffDef[@xml:id and
                                  @n=$thisStaff]/@xml:id"/>
                              </xsl:when>
                            </xsl:choose>
                          </xsl:variable>
                          <!-- if this staff belongs to the current part -->
                          <xsl:if test="$staffPart=$thisPart">
                            <staff-layout>
                              <xsl:attribute name="number">
                                <xsl:choose>
                                  <xsl:when
                                    test="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]]">
                                    <xsl:for-each
                                      select="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]][1]/mei:staffDef[@n=$thisStaff]">
                                      <xsl:value-of select="count(preceding-sibling::mei:staffDef) +
                                        1"/>
                                    </xsl:for-each>
                                  </xsl:when>
                                  <xsl:when
                                    test="$defaultScoreDef//mei:staffGrp[mei:staffDef[@n=$thisStaff]]/mei:staffDef[@n=$thisStaff]">
                                    <xsl:value-of select="1"/>
                                  </xsl:when>
                                </xsl:choose>
                              </xsl:attribute>
                              <staff-distance>
                                <xsl:choose>
                                  <xsl:when test="replace(@spacing, '[a-z]+$', '') = '0'">
                                    <xsl:value-of select="@spacing"/>
                                  </xsl:when>
                                  <xsl:when test="number(replace(@spacing, '[a-z]+$', ''))">
                                    <xsl:value-of select="format-number(number(replace(@spacing,
                                      '[a-z]+$', '')) * 5, '###0.####')"/>
                                  </xsl:when>
                                </xsl:choose>
                              </staff-distance>
                            </staff-layout>
                          </xsl:if>
                        </xsl:for-each>
                      </xsl:when>
                      <!--if initial measure, look for staff distances on default scoreDef -->
                      <xsl:when test="$localScoreDef/mei:initialAttributes">
                        <xsl:choose>
                          <xsl:when test="$defaultScoreDef//mei:staffDef[@xml:id=$thisPart] or
                            $defaultScoreDef//mei:staffGrp[@xml:id=$thisPart]//mei:staffDef">
                            <xsl:for-each select="$defaultScoreDef//mei:staffDef[@xml:id=$thisPart]">
                              <staff-layout>
                                <staff-distance>
                                  <xsl:choose>
                                    <xsl:when test="replace(@spacing, '[a-z]+$', '') = '0'">
                                      <xsl:value-of select="@spacing"/>
                                    </xsl:when>
                                    <xsl:when test="number(replace(@spacing, '[a-z]+$', ''))">
                                      <xsl:value-of select="format-number(number(replace(@spacing,
                                        '[a-z]+$', '')) * 5, '###0.####')"/>
                                    </xsl:when>
                                  </xsl:choose>
                                </staff-distance>
                              </staff-layout>
                            </xsl:for-each>
                            <xsl:for-each
                              select="$defaultScoreDef//mei:staffGrp[@xml:id=$thisPart]//mei:staffDef">
                              <xsl:variable name="staffNumber">
                                <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
                              </xsl:variable>
                              <xsl:if test="$staffNumber != 1">
                                <staff-layout>
                                  <xsl:attribute name="number">
                                    <xsl:value-of select="$staffNumber"/>
                                  </xsl:attribute>
                                  <staff-distance>
                                    <xsl:choose>
                                      <xsl:when test="replace(@spacing, '[a-z]+$', '') = '0'">
                                        <xsl:value-of select="@spacing"/>
                                      </xsl:when>
                                      <xsl:when test="number(replace(@spacing, '[a-z]+$', ''))">
                                        <xsl:value-of select="format-number(number(replace(@spacing,
                                          '[a-z]+$', '')) * 5, '###0.####')"/>
                                      </xsl:when>
                                    </xsl:choose>
                                  </staff-distance>
                                </staff-layout>
                              </xsl:if>
                            </xsl:for-each>
                          </xsl:when>
                        </xsl:choose>
                      </xsl:when>
                    </xsl:choose>
                  </xsl:variable>
                  <!-- if defined multiple times, keep only the last staff-distance -->
                  <xsl:for-each-group select="$staffLayout/staff-layout" group-by="@number">
                    <xsl:sort select="current-grouping-key()"/>
                    <xsl:copy>
                      <xsl:copy-of select="@*"/>
                      <xsl:for-each select="current-group()/staff-distance">
                        <xsl:if test="position()=last()">
                          <xsl:copy-of select="."/>
                        </xsl:if>
                      </xsl:for-each>
                    </xsl:copy>
                  </xsl:for-each-group>
                </print>
              </xsl:variable>
              <xsl:if test="$printInstructions != ''">
                <xsl:copy-of select="$printInstructions"/>
              </xsl:if>
            </xsl:if>

            <!-- generate MusicXML "attributes" -->
            <xsl:variable name="divisions">
              <xsl:choose>
                <!-- local definitions present; look for ppq on staff definitions -->
                <xsl:when test="$localScoreDef//mei:staffDef[@ppq]">
                  <xsl:for-each select="$localScoreDef//mei:staffDef[@ppq]">
                    <xsl:variable name="thisStaff">
                      <xsl:value-of select="@n"/>
                    </xsl:variable>
                    <xsl:variable name="staffPart">
                      <xsl:choose>
                        <xsl:when test="$defaultScoreDef//mei:staffDef[@xml:id=$thisPart and
                          @n=$thisStaff]">
                          <xsl:value-of select="$defaultScoreDef//mei:staffDef[@xml:id=$thisPart and
                            @n=$thisStaff]/@xml:id"/>
                        </xsl:when>
                        <xsl:when
                          test="$defaultScoreDef//mei:staffGrp[@xml:id=$thisPart][descendant::mei:staffDef[@n=$thisStaff]]">
                          <xsl:value-of
                            select="$defaultScoreDef//mei:staffGrp[@xml:id=$thisPart][descendant::mei:staffDef[@n=$thisStaff]]/@xml:id"
                          />
                        </xsl:when>
                      </xsl:choose>
                    </xsl:variable>
                    <!-- if this staff belongs to the current part -->
                    <xsl:if test="$staffPart=$thisPart">
                      <value>
                        <xsl:value-of select="@ppq"/>
                      </value>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:when>
                <!-- local definitions present; look for ppq on score definition -->
                <xsl:when test="$localScoreDef/mei:scoreDef[@ppq]">
                  <value>
                    <xsl:value-of select="$localScoreDef/mei:scoreDef[@ppq]/@ppq"/>
                  </value>
                </xsl:when>
                <!-- no local definitions available; look for ppq in default scoreDef -->
                <xsl:when test="$localScoreDef/mei:initialAttributes">
                  <xsl:choose>
                    <xsl:when test="$defaultScoreDef//mei:staffDef[@xml:id=$thisPart and @ppq]">
                      <value>
                        <xsl:value-of select="$defaultScoreDef//mei:staffDef[@xml:id=$thisPart
                          and @ppq][1]/@ppq"/>
                      </value>
                    </xsl:when>
                    <xsl:when test="$defaultScoreDef//mei:staffDef[generate-id()=$thisPart and
                      @ppq]">
                      <value>
                        <xsl:value-of select="$defaultScoreDef//mei:staffDef[generate-id()=$thisPart
                          and @ppq]/@ppq"/>
                      </value>
                    </xsl:when>
                    <xsl:when
                      test="$defaultScoreDef//mei:staffGrp[@xml:id=$thisPart]//mei:staffDef[@ppq]">
                      <value>
                        <xsl:value-of
                          select="$defaultScoreDef//mei:staffGrp[@xml:id=$thisPart]//mei:staffDef[@ppq][1]/@ppq"
                        />
                      </value>
                    </xsl:when>
                    <xsl:otherwise>
                      <value>
                        <xsl:value-of select="$defaultScoreDef/mei:scoreDef/@ppq"/>
                      </value>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <!-- if none of the conditions above is met, this is not the initial 
                    measure and $divisions will be empty. -->
              </xsl:choose>
            </xsl:variable>

            <xsl:variable name="keySig">
              <xsl:choose>
                <!-- local definitions present; look for key info on staff definitions -->
                <xsl:when test="$localScoreDef//mei:staffDef[@key.sig or @key.mode]">
                  <xsl:for-each select="$localScoreDef//mei:staffDef[@key.sig or @key.mode]">
                    <xsl:variable name="thisStaff">
                      <xsl:value-of select="@n"/>
                    </xsl:variable>
                    <!-- the part this staff belongs to -->
                    <xsl:variable name="staffPart">
                      <xsl:choose>
                        <xsl:when
                          test="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]]">
                          <xsl:value-of
                            select="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]]/@xml:id"
                          />
                        </xsl:when>
                        <xsl:when test="$defaultScoreDef//mei:staffDef[@xml:id and @n=$thisStaff]">
                          <xsl:value-of select="$defaultScoreDef//mei:staffDef[@xml:id and
                            @n=$thisStaff]/@xml:id"/>
                        </xsl:when>
                      </xsl:choose>
                    </xsl:variable>
                    <!-- if this staff belongs to the current part -->
                    <xsl:if test="$staffPart=$thisPart">
                      <key>
                        <xsl:attribute name="number">
                          <xsl:choose>
                            <xsl:when
                              test="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]]">
                              <xsl:for-each
                                select="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]][1]/mei:staffDef[@n=$thisStaff]">
                                <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
                              </xsl:for-each>
                            </xsl:when>
                            <xsl:when
                              test="$defaultScoreDef//mei:staffGrp[mei:staffDef[@n=$thisStaff]]/mei:staffDef[@n=$thisStaff]">
                              <xsl:value-of select="1"/>
                            </xsl:when>
                          </xsl:choose>
                        </xsl:attribute>
                        <xsl:if test="@key.sig">
                          <fifths>
                            <xsl:choose>
                              <xsl:when test="matches(@key.sig, '0')">
                                <xsl:value-of select="0"/>
                              </xsl:when>
                              <xsl:when test="matches(@key.sig, 'f$')">
                                <xsl:text>-</xsl:text>
                                <xsl:value-of select="replace(@key.sig, 'f', '')"/>
                              </xsl:when>
                              <xsl:when test="matches(@key.sig, 's$')">
                                <xsl:value-of select="replace(@key.sig, 's', '')"/>
                              </xsl:when>
                            </xsl:choose>
                          </fifths>
                        </xsl:if>
                        <xsl:if test="@key.mode">
                          <mode>
                            <xsl:value-of select="@key.mode"/>
                          </mode>
                        </xsl:if>
                      </key>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:when>
                <!-- if initial measure, look for key signature and mode on default scoreDef -->
                <xsl:when test="$localScoreDef/mei:initialAttributes">
                  <xsl:choose>
                    <xsl:when test="$defaultScoreDef//mei:staffDef[@xml:id=$thisPart and (@key.sig
                      or @key.mode)] or
                      $defaultScoreDef//mei:staffGrp[@xml:id=$thisPart]//mei:staffDef[@key.sig or
                      @key.mode]">
                      <xsl:for-each select="$defaultScoreDef//mei:staffDef[@xml:id=$thisPart and
                        (@key.sig or @key.mode)]">
                        <key>
                          <xsl:if test="@key.sig">
                            <fifths>
                              <xsl:choose>
                                <xsl:when test="matches(@key.sig, '0')">
                                  <xsl:value-of select="0"/>
                                </xsl:when>
                                <xsl:when test="matches(@key.sig, 'f$')">
                                  <xsl:text>-</xsl:text>
                                  <xsl:value-of select="replace(@key.sig, 'f', '')"/>
                                </xsl:when>
                                <xsl:when test="matches(@key.sig, 's$')">
                                  <xsl:value-of select="replace(@key.sig, 's', '')"/>
                                </xsl:when>
                              </xsl:choose>
                            </fifths>
                          </xsl:if>
                          <xsl:if test="@key.mode or $defaultScoreDef/mei:scoreDef/@key.mode">
                            <mode>
                              <xsl:choose>
                                <xsl:when test="@key.mode">
                                  <xsl:value-of select="@key.mode"/>
                                </xsl:when>
                                <xsl:otherwise>
                                  <xsl:value-of select="$defaultScoreDef/mei:scoreDef/@key.mode"/>
                                </xsl:otherwise>
                              </xsl:choose>
                            </mode>
                          </xsl:if>
                        </key>
                      </xsl:for-each>
                      <xsl:for-each
                        select="$defaultScoreDef//mei:staffGrp[@xml:id=$thisPart]//mei:staffDef[@key.sig
                        or @key.mode]">
                        <key>
                          <xsl:attribute name="number">
                            <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
                          </xsl:attribute>
                          <xsl:if test="@key.sig">
                            <fifths>
                              <xsl:choose>
                                <xsl:when test="matches(@key.sig, '0')">
                                  <xsl:value-of select="0"/>
                                </xsl:when>
                                <xsl:when test="matches(@key.sig, 'f$')">
                                  <xsl:text>-</xsl:text>
                                  <xsl:value-of select="replace(@key.sig, 'f', '')"/>
                                </xsl:when>
                                <xsl:when test="matches(@key.sig, 's$')">
                                  <xsl:value-of select="replace(@key.sig, 's', '')"/>
                                </xsl:when>
                              </xsl:choose>
                            </fifths>
                          </xsl:if>
                          <xsl:if test="@key.mode or $defaultScoreDef/mei:scoreDef/@key.mode">
                            <mode>
                              <xsl:choose>
                                <xsl:when test="@key.mode">
                                  <xsl:value-of select="@key.mode"/>
                                </xsl:when>
                                <xsl:otherwise>
                                  <xsl:value-of select="$defaultScoreDef/mei:scoreDef/@key.mode"/>
                                </xsl:otherwise>
                              </xsl:choose>
                            </mode>
                          </xsl:if>
                        </key>
                      </xsl:for-each>
                    </xsl:when>
                    <!-- part-specific declarations not available; use score-level default values -->
                    <xsl:when test="$defaultScoreDef/mei:scoreDef[@key.sig or @key.mode]">
                      <key>
                        <xsl:if test="$defaultScoreDef/mei:scoreDef/@key.sig">
                          <fifths>
                            <xsl:choose>
                              <xsl:when test="matches($defaultScoreDef/mei:scoreDef/@key.sig, '0')">
                                <xsl:value-of select="0"/>
                              </xsl:when>
                              <xsl:when test="matches($defaultScoreDef/mei:scoreDef/@key.sig, 'f$')">
                                <xsl:text>-</xsl:text>
                                <xsl:value-of
                                  select="replace($defaultScoreDef/mei:scoreDef/@key.sig, 'f', '')"
                                />
                              </xsl:when>
                              <xsl:when test="matches($defaultScoreDef/mei:scoreDef/@key.sig, 's$')">
                                <xsl:value-of
                                  select="replace($defaultScoreDef/mei:scoreDef/@key.sig, 's', '')"
                                />
                              </xsl:when>
                            </xsl:choose>
                          </fifths>
                        </xsl:if>
                        <xsl:if test="$defaultScoreDef/mei:scoreDef/@key.mode">
                          <mode>
                            <xsl:value-of select="$defaultScoreDef/mei:scoreDef/@key.mode"/>
                          </mode>
                        </xsl:if>
                      </key>
                    </xsl:when>
                  </xsl:choose>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>

            <xsl:variable name="timeSig">
              <xsl:choose>
                <!-- local definitions present; look for time signature info on staff definitions -->
                <xsl:when test="$localScoreDef//mei:staffDef[@meter.count or @meter.unit]">
                  <xsl:for-each select="$localScoreDef//mei:staffDef[@meter.count or @meter.unit]">
                    <xsl:variable name="thisStaff">
                      <xsl:value-of select="@n"/>
                    </xsl:variable>
                    <!-- the part this staff belongs to -->
                    <xsl:variable name="staffPart">
                      <xsl:choose>
                        <xsl:when
                          test="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]]">
                          <xsl:value-of
                            select="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]]/@xml:id"
                          />
                        </xsl:when>
                        <xsl:when test="$defaultScoreDef//mei:staffDef[@xml:id and @n=$thisStaff]">
                          <xsl:value-of select="$defaultScoreDef//mei:staffDef[@xml:id and
                            @n=$thisStaff]/@xml:id"/>
                        </xsl:when>
                      </xsl:choose>
                    </xsl:variable>
                    <!-- if this staff belongs to the current part -->
                    <xsl:if test="$staffPart=$thisPart">
                      <time>
                        <xsl:attribute name="number">
                          <xsl:choose>
                            <xsl:when
                              test="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]]">
                              <xsl:for-each
                                select="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]][1]/mei:staffDef[@n=$thisStaff]">
                                <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
                              </xsl:for-each>
                            </xsl:when>
                            <xsl:when
                              test="$defaultScoreDef//mei:staffGrp[mei:staffDef[@n=$thisStaff]]/mei:staffDef[@n=$thisStaff]">
                              <xsl:value-of select="1"/>
                            </xsl:when>
                          </xsl:choose>
                        </xsl:attribute>
                        <xsl:if test="@meter.sym">
                          <xsl:attribute name="symbol">
                            <xsl:value-of select="@meter.sym"/>
                          </xsl:attribute>
                        </xsl:if>
                        <beats>
                          <xsl:value-of select="@meter.count"/>
                        </beats>
                        <beat-type>
                          <xsl:value-of select="@meter.unit"/>
                        </beat-type>
                      </time>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:when>
                <!-- local definitions present; look for time signature info on score definition -->
                <xsl:when test="$localScoreDef/mei:scoreDef[@meter.count or @meter.unit]">
                  <time>
                    <xsl:if test="$localScoreDef/mei:scoreDef/@meter.sym">
                      <xsl:attribute name="symbol">
                        <xsl:value-of select="$localScoreDef/mei:scoreDef/@meter.sym"/>
                      </xsl:attribute>
                    </xsl:if>
                    <beats>
                      <xsl:value-of select="$localScoreDef/mei:scoreDef/@meter.count"/>
                    </beats>
                    <beat-type>
                      <xsl:value-of select="$localScoreDef/mei:scoreDef/@meter.unit"/>
                    </beat-type>
                  </time>
                </xsl:when>
                <!-- initial measure; look for time sig on default scoreDef -->
                <xsl:when test="$localScoreDef/mei:initialAttributes">
                  <xsl:choose>
                    <xsl:when test="$defaultScoreDef//mei:staffDef[@xml:id=$thisPart and
                      (@meter.count or @meter.unit)] or
                      $defaultScoreDef//mei:staffGrp[@xml:id=$thisPart]//mei:staffDef[@meter.count
                      or @meter.unit]">
                      <xsl:for-each select="$defaultScoreDef//mei:staffDef[@xml:id=$thisPart and
                        (@meter.count or @meter.unit)]">
                        <time>
                          <xsl:if test="@meter.sym">
                            <xsl:attribute name="symbol">
                              <xsl:value-of select="@meter.sym"/>
                            </xsl:attribute>
                          </xsl:if>
                          <beats>
                            <xsl:value-of select="@meter.count"/>
                          </beats>
                          <beat-type>
                            <xsl:value-of select="@meter.unit"/>
                          </beat-type>
                        </time>
                      </xsl:for-each>
                      <xsl:for-each
                        select="$defaultScoreDef//mei:staffGrp[@xml:id=$thisPart]//mei:staffDef">
                        <time>
                          <xsl:attribute name="number">
                            <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
                          </xsl:attribute>
                          <xsl:if test="@meter.sym or $defaultScoreDef/mei:scoreDef/@meter.sym">
                            <xsl:attribute name="symbol">
                              <xsl:choose>
                                <xsl:when test="@meter.sym">
                                  <xsl:value-of select="@meter.sym"/>
                                </xsl:when>
                                <xsl:when test="$defaultScoreDef/mei:scoreDef/@meter.sym">
                                  <xsl:value-of select="$defaultScoreDef/mei:scoreDef/@meter.sym"/>
                                </xsl:when>
                              </xsl:choose>
                            </xsl:attribute>
                          </xsl:if>
                          <beats>
                            <xsl:choose>
                              <xsl:when test="@meter.count">
                                <xsl:value-of select="@meter.count"/>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:value-of select="$defaultScoreDef/mei:scoreDef/@meter.count"/>
                              </xsl:otherwise>
                            </xsl:choose>
                          </beats>
                          <beat-type>
                            <xsl:choose>
                              <xsl:when test="@meter.count">
                                <xsl:value-of select="@meter.unit"/>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:value-of select="$defaultScoreDef/mei:scoreDef/@meter.unit"/>
                              </xsl:otherwise>
                            </xsl:choose>
                          </beat-type>
                        </time>
                      </xsl:for-each>
                    </xsl:when>
                    <!-- part-specific declarations not available; use score-level default values -->
                    <xsl:when test="$defaultScoreDef/mei:scoreDef[@meter.count or @meter.unit]">
                      <time>
                        <xsl:if test="$defaultScoreDef/mei:scoreDef/@meter.sym">
                          <xsl:attribute name="symbol">
                            <xsl:value-of select="$defaultScoreDef/mei:scoreDef/@meter.sym"/>
                          </xsl:attribute>
                        </xsl:if>
                        <beats>
                          <xsl:value-of select="$defaultScoreDef/mei:scoreDef/@meter.count"/>
                        </beats>
                        <beat-type>
                          <xsl:value-of select="$defaultScoreDef/mei:scoreDef/@meter.unit"/>
                        </beat-type>
                      </time>
                    </xsl:when>
                  </xsl:choose>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>

            <xsl:variable name="staves">
              <xsl:choose>
                <!-- single-staff part -->
                <xsl:when test="$localScoreDef//mei:staffDef[@xml:id=$thisPart]">
                  <staves>
                    <xsl:value-of select="1"/>
                  </staves>
                </xsl:when>
                <!-- multi-staff part; count staves -->
                <xsl:when test="$localScoreDef//mei:staffGrp[@xml:id=$thisPart]">
                  <staves>
                    <xsl:value-of
                      select="count($localScoreDef//mei:staffGrp[@xml:id=$thisPart]/mei:staffDef)"/>
                  </staves>
                </xsl:when>
                <!-- initial measure; staff count mandatory -->
                <xsl:when test="$localScoreDef/mei:initialAttributes">
                  <xsl:choose>
                    <!-- single-staff part -->
                    <xsl:when test="$defaultScoreDef//mei:staffDef[@xml:id=$thisPart]">
                      <staves>
                        <xsl:value-of select="1"/>
                      </staves>
                    </xsl:when>
                    <!-- multi-staff part; count staves -->
                    <xsl:when test="$defaultScoreDef//mei:staffGrp[@xml:id=$thisPart]">
                      <staves>
                        <xsl:value-of
                          select="count($defaultScoreDef//mei:staffGrp[@xml:id=$thisPart]/mei:staffDef)"
                        />
                      </staves>
                    </xsl:when>
                  </xsl:choose>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>

            <xsl:variable name="clefs">
              <xsl:choose>
                <!-- local definitions present; look for clefs on staff definitions -->
                <xsl:when test="$localScoreDef//mei:staffDef[@clef.shape or @clef.line]">
                  <xsl:for-each select="$localScoreDef//mei:staffDef[@clef.shape or @clef.line]">
                    <xsl:variable name="thisStaff">
                      <xsl:value-of select="@n"/>
                    </xsl:variable>
                    <!-- the part this staff belongs to -->
                    <xsl:variable name="staffPart">
                      <xsl:choose>
                        <xsl:when
                          test="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]]">
                          <xsl:value-of
                            select="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]]/@xml:id"
                          />
                        </xsl:when>
                        <xsl:when test="$defaultScoreDef//mei:staffDef[@xml:id and @n=$thisStaff]">
                          <xsl:value-of select="$defaultScoreDef//mei:staffDef[@xml:id and
                            @n=$thisStaff]/@xml:id"/>
                        </xsl:when>
                      </xsl:choose>
                    </xsl:variable>
                    <!-- if this staff belongs to the current part -->
                    <xsl:if test="$staffPart=$thisPart">
                      <clef>
                        <xsl:attribute name="number">
                          <xsl:choose>
                            <xsl:when
                              test="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]]">
                              <xsl:for-each
                                select="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]][1]/mei:staffDef[@n=$thisStaff]">
                                <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
                              </xsl:for-each>
                            </xsl:when>
                            <xsl:when
                              test="$defaultScoreDef//mei:staffGrp[mei:staffDef[@n=$thisStaff]]/mei:staffDef[@n=$thisStaff]">
                              <xsl:value-of select="1"/>
                            </xsl:when>
                          </xsl:choose>
                        </xsl:attribute>
                        <sign>
                          <xsl:choose>
                            <xsl:when test="@clef.shape='perc'">
                              <xsl:text>percussion</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:value-of select="@clef.shape"/>
                            </xsl:otherwise>
                          </xsl:choose>
                        </sign>
                        <xsl:if test="@clef.line">
                          <line>
                            <xsl:value-of select="@clef.line"/>
                          </line>
                        </xsl:if>
                        <xsl:if test="@clef.dis">
                          <clef-octave-change>
                            <xsl:if test="@clef.dis.place='below'">
                              <xsl:text>-</xsl:text>
                            </xsl:if>
                            <xsl:choose>
                              <xsl:when test="@clef.dis='8'">
                                <xsl:value-of select="1"/>
                              </xsl:when>
                              <xsl:when test="@clef.dis='15'">
                                <xsl:value-of select="2"/>
                              </xsl:when>
                              <xsl:when test="@clef.dis='22'">
                                <xsl:value-of select="3"/>
                              </xsl:when>
                            </xsl:choose>
                          </clef-octave-change>
                        </xsl:if>
                      </clef>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:when>
                <!-- local definitions present; look for clefs on score definition -->
                <xsl:when test="$localScoreDef/mei:scoreDef[@clef.shape or @clef.line]">
                  <clef>
                    <xsl:if test="$localScoreDef/mei:scoreDef[@clef.shape]">
                      <sign>
                        <xsl:choose>
                          <xsl:when test="$localScoreDef/mei:scoreDef/@clef.shape='perc'">
                            <xsl:text>percussion</xsl:text>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="$localScoreDef/mei:scoreDef/@clef.shape"/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </sign>
                    </xsl:if>
                    <xsl:if test="$localScoreDef/mei:scoreDef[@clef.line]">
                      <xsl:if test="$localScoreDef/mei:scoreDef/@clef.line">
                        <line>
                          <xsl:value-of select="$localScoreDef/mei:scoreDef/@clef.line"/>
                        </line>
                      </xsl:if>
                    </xsl:if>
                    <xsl:if test="@clef.dis">
                      <clef-octave-change>
                        <xsl:if test="@clef.dis.place='below'">
                          <xsl:text>-</xsl:text>
                        </xsl:if>
                        <xsl:choose>
                          <xsl:when test="@clef.dis='8'">
                            <xsl:value-of select="1"/>
                          </xsl:when>
                          <xsl:when test="@clef.dis='15'">
                            <xsl:value-of select="2"/>
                          </xsl:when>
                          <xsl:when test="@clef.dis='22'">
                            <xsl:value-of select="3"/>
                          </xsl:when>
                        </xsl:choose>
                      </clef-octave-change>
                    </xsl:if>
                  </clef>
                </xsl:when>
                <!--if initial measure, look for clef declarations on default scoreDef -->
                <xsl:when test="$localScoreDef/mei:initialAttributes">
                  <xsl:choose>
                    <xsl:when test="$defaultScoreDef//mei:staffDef[@xml:id=$thisPart] or
                      $defaultScoreDef//mei:staffGrp[@xml:id=$thisPart]//mei:staffDef">
                      <xsl:for-each select="$defaultScoreDef//mei:staffDef[@xml:id=$thisPart]">
                        <clef>
                          <sign>
                            <xsl:choose>
                              <xsl:when test="@clef.shape='perc'">
                                <xsl:text>percussion</xsl:text>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:value-of select="@clef.shape"/>
                              </xsl:otherwise>
                            </xsl:choose>
                          </sign>
                          <xsl:if test="@clef.line">
                            <line>
                              <xsl:value-of select="@clef.line"/>
                            </line>
                          </xsl:if>
                          <xsl:if test="@clef.dis">
                            <clef-octave-change>
                              <xsl:if test="@clef.dis.place='below'">
                                <xsl:text>-</xsl:text>
                              </xsl:if>
                              <xsl:choose>
                                <xsl:when test="@clef.dis='8'">
                                  <xsl:value-of select="1"/>
                                </xsl:when>
                                <xsl:when test="@clef.dis='15'">
                                  <xsl:value-of select="2"/>
                                </xsl:when>
                                <xsl:when test="@clef.dis='22'">
                                  <xsl:value-of select="3"/>
                                </xsl:when>
                              </xsl:choose>
                            </clef-octave-change>
                          </xsl:if>
                        </clef>
                      </xsl:for-each>
                      <xsl:for-each
                        select="$defaultScoreDef//mei:staffGrp[@xml:id=$thisPart]//mei:staffDef">
                        <clef>
                          <xsl:attribute name="number">
                            <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
                          </xsl:attribute>
                          <sign>
                            <xsl:choose>
                              <xsl:when test="@clef.shape">
                                <xsl:choose>
                                  <xsl:when test="@clef.shape='perc'">
                                    <xsl:text>percussion</xsl:text>
                                  </xsl:when>
                                  <xsl:otherwise>
                                    <xsl:value-of select="@clef.shape"/>
                                  </xsl:otherwise>
                                </xsl:choose>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:value-of select="$defaultScoreDef/mei:scoreDef/@clef.shape"/>
                              </xsl:otherwise>
                            </xsl:choose>
                          </sign>
                          <line>
                            <xsl:choose>
                              <xsl:when test="@clef.line">
                                <xsl:value-of select="@clef.line"/>
                              </xsl:when>
                              <xsl:when test="$defaultScoreDef/mei:scoreDef/@clef.line">
                                <xsl:value-of select="$defaultScoreDef/mei:scoreDef/@clef.line"/>
                              </xsl:when>
                            </xsl:choose>
                          </line>
                          <xsl:if test="@clef.dis">
                            <clef-octave-change>
                              <xsl:if test="@clef.dis.place='below'">
                                <xsl:text>-</xsl:text>
                              </xsl:if>
                              <xsl:choose>
                                <xsl:when test="@clef.dis='8'">
                                  <xsl:value-of select="1"/>
                                </xsl:when>
                                <xsl:when test="@clef.dis='15'">
                                  <xsl:value-of select="2"/>
                                </xsl:when>
                                <xsl:when test="@clef.dis='22'">
                                  <xsl:value-of select="3"/>
                                </xsl:when>
                              </xsl:choose>
                            </clef-octave-change>
                          </xsl:if>
                        </clef>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:when test="$defaultScoreDef/mei:scoreDef[@clef.shape or @clef.line]">
                      <clef>
                        <xsl:if test="$defaultScoreDef/mei:scoreDef/@clef.shape">
                          <sign>
                            <xsl:choose>
                              <xsl:when test="$defaultScoreDef/mei:scoreDef/@clef.shape='perc'">
                                <xsl:text>percussion</xsl:text>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:value-of select="$defaultScoreDef/mei:scoreDef/@clef.shape"/>
                              </xsl:otherwise>
                            </xsl:choose>
                          </sign>
                        </xsl:if>
                        <xsl:if test="$defaultScoreDef/mei:scoreDef/@clef.line">
                          <line>
                            <xsl:value-of select="$defaultScoreDef/mei:scoreDef/@clef.line"/>
                          </line>
                        </xsl:if>
                        <xsl:if test="@clef.dis">
                          <clef-octave-change>
                            <xsl:if test="@clef.dis.place='below'">
                              <xsl:text>-</xsl:text>
                            </xsl:if>
                            <xsl:choose>
                              <xsl:when test="@clef.dis='8'">
                                <xsl:value-of select="1"/>
                              </xsl:when>
                              <xsl:when test="@clef.dis='15'">
                                <xsl:value-of select="2"/>
                              </xsl:when>
                              <xsl:when test="@clef.dis='22'">
                                <xsl:value-of select="3"/>
                              </xsl:when>
                            </xsl:choose>
                          </clef-octave-change>
                        </xsl:if>
                      </clef>
                    </xsl:when>
                  </xsl:choose>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>

            <xsl:variable name="staffDetails">
              <xsl:choose>
                <!-- local definitions present; look for staff-specific attributes -->
                <xsl:when test="$localScoreDef//mei:staffDef[@lines or @scale or @visible]">
                  <xsl:for-each select="$localScoreDef//mei:staffDef[@lines or @scale or @visible]">
                    <xsl:variable name="thisStaff">
                      <xsl:value-of select="@n"/>
                    </xsl:variable>
                    <!-- the part this staff belongs to -->
                    <xsl:variable name="staffPart">
                      <xsl:choose>
                        <xsl:when
                          test="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]]">
                          <xsl:value-of
                            select="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]]/@xml:id"
                          />
                        </xsl:when>
                        <xsl:when test="$defaultScoreDef//mei:staffDef[@xml:id and @n=$thisStaff]">
                          <xsl:value-of select="$defaultScoreDef//mei:staffDef[@xml:id and
                            @n=$thisStaff]/@xml:id"/>
                        </xsl:when>
                      </xsl:choose>
                    </xsl:variable>
                    <!-- if this staff belongs to the current part -->
                    <xsl:if test="$staffPart=$thisPart">
                      <staff-details>
                        <xsl:attribute name="number">
                          <xsl:choose>
                            <xsl:when
                              test="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]]">
                              <xsl:for-each
                                select="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]][1]/mei:staffDef[@n=$thisStaff]">
                                <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
                              </xsl:for-each>
                            </xsl:when>
                            <xsl:when
                              test="$defaultScoreDef//mei:staffGrp[mei:staffDef[@n=$thisStaff]]/mei:staffDef[@n=$thisStaff]">
                              <xsl:value-of select="1"/>
                            </xsl:when>
                          </xsl:choose>
                        </xsl:attribute>
                        <xsl:if test="@visible='no'">
                          <xsl:attribute name="print-object">
                            <xsl:text>no</xsl:text>
                          </xsl:attribute>
                        </xsl:if>
                        <xsl:if test="@lines">
                          <staff-lines>
                            <xsl:value-of select="@lines"/>
                          </staff-lines>
                        </xsl:if>
                        <xsl:if test="@scale">
                          <xsl:value-of select="replace(@scale, '%', '')"/>
                        </xsl:if>
                      </staff-details>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:when>
                <!--if initial measure, look for clef declarations in $defaultScoreDef -->
                <xsl:when test="$localScoreDef/mei:initialAttributes">
                  <xsl:choose>
                    <xsl:when test="$defaultScoreDef//mei:staffDef[@xml:id=$thisPart][@lines or
                      @visible] or
                      $defaultScoreDef//mei:staffGrp[@xml:id=$thisPart]//mei:staffDef[@lines or
                      @visible]">
                      <xsl:for-each select="$defaultScoreDef//mei:staffDef[@xml:id=$thisPart][@lines
                        or @visible]">
                        <staff-details>
                          <xsl:if test="@visible='no'">
                            <xsl:attribute name="print-object">
                              <xsl:text>no</xsl:text>
                            </xsl:attribute>
                          </xsl:if>
                          <xsl:if test="@lines">
                            <staff-lines>
                              <xsl:value-of select="@lines"/>
                            </staff-lines>
                          </xsl:if>
                        </staff-details>
                      </xsl:for-each>
                      <xsl:for-each
                        select="$defaultScoreDef//mei:staffGrp[@xml:id=$thisPart]//mei:staffDef[@lines
                        or @visible]">
                        <staff-details>
                          <xsl:attribute name="number">
                            <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
                          </xsl:attribute>
                          <xsl:if test="@visible='no'">
                            <xsl:attribute name="print-object">
                              <xsl:text>no</xsl:text>
                            </xsl:attribute>
                          </xsl:if>
                          <xsl:if test="@lines">
                            <staff-lines>
                              <xsl:value-of select="@lines"/>
                            </staff-lines>
                          </xsl:if>
                        </staff-details>
                      </xsl:for-each>
                    </xsl:when>
                  </xsl:choose>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>

            <xsl:variable name="transpose">
              <xsl:choose>
                <!-- local definitions present; look for staff-specific attributes -->
                <xsl:when test="$localScoreDef//mei:staffDef[@trans.semi or @trans.diat]">
                  <xsl:for-each select="$localScoreDef//mei:staffDef[@trans.semi or @trans.diat]">
                    <xsl:variable name="thisStaff">
                      <xsl:value-of select="@n"/>
                    </xsl:variable>
                    <!-- the part this staff belongs to -->
                    <xsl:variable name="staffPart">
                      <xsl:choose>
                        <xsl:when
                          test="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]]">
                          <xsl:value-of
                            select="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]]/@xml:id"
                          />
                        </xsl:when>
                        <xsl:when test="$defaultScoreDef//mei:staffDef[@xml:id and @n=$thisStaff]">
                          <xsl:value-of select="$defaultScoreDef//mei:staffDef[@xml:id and
                            @n=$thisStaff]/@xml:id"/>
                        </xsl:when>
                      </xsl:choose>
                    </xsl:variable>
                    <!-- if this staff belongs to the current part -->
                    <xsl:if test="$staffPart=$thisPart">
                      <transpose>
                        <xsl:attribute name="number">
                          <xsl:choose>
                            <xsl:when
                              test="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]]">
                              <xsl:for-each
                                select="$defaultScoreDef//mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]][1]/mei:staffDef[@n=$thisStaff]">
                                <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
                              </xsl:for-each>
                            </xsl:when>
                            <xsl:when
                              test="$defaultScoreDef//mei:staffGrp[mei:staffDef[@n=$thisStaff]]/mei:staffDef[@n=$thisStaff]">
                              <xsl:value-of select="1"/>
                            </xsl:when>
                          </xsl:choose>
                        </xsl:attribute>
                        <xsl:if test="@trans.diat">
                          <diatonic>
                            <xsl:value-of select="@trans.diat"/>
                          </diatonic>
                        </xsl:if>
                        <xsl:if test="@trans.semi">
                          <chromatic>
                            <xsl:choose>
                              <xsl:when test="abs(number(@trans.semi)) &gt;= 12">
                                <xsl:if test="@trans.semi &lt; 0">
                                  <xsl:text>-</xsl:text>
                                </xsl:if>
                                <xsl:value-of select="abs(@trans.semi) - (floor((abs(@trans.semi)
                                  div 12)) * 12)"/>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:value-of select="@trans.semi"/>
                              </xsl:otherwise>
                            </xsl:choose>
                          </chromatic>
                          <xsl:if test="abs(number(@trans.semi)) &gt;= 12">
                            <octave-change>
                              <xsl:if test="@trans.semi &lt; 0">
                                <xsl:text>-</xsl:text>
                              </xsl:if>
                              <xsl:value-of select="floor(abs(@trans.semi) div 12)"/>
                            </octave-change>
                          </xsl:if>
                        </xsl:if>
                      </transpose>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:when>
                <!--if initial measure, look for clef declarations on default scoreDef -->
                <xsl:when test="$localScoreDef/mei:initialAttributes">
                  <xsl:choose>
                    <xsl:when test="$defaultScoreDef//mei:staffDef[@xml:id=$thisPart][@trans.semi or
                      @trans.diat] or
                      $defaultScoreDef//mei:staffGrp[@xml:id=$thisPart]//mei:staffDef[@trans.semi or
                      @trans.diat]">
                      <xsl:for-each
                        select="$defaultScoreDef//mei:staffDef[@xml:id=$thisPart][@trans.semi or
                        @trans.diat]">
                        <transpose>
                          <xsl:if test="@trans.diat">
                            <diatonic>
                              <xsl:value-of select="@trans.diat"/>
                            </diatonic>
                          </xsl:if>
                          <xsl:if test="@trans.semi">
                            <chromatic>
                              <xsl:choose>
                                <xsl:when test="abs(number(@trans.semi)) &gt;= 12">
                                  <xsl:if test="@trans.semi &lt; 0">
                                    <xsl:text>-</xsl:text>
                                  </xsl:if>
                                  <xsl:value-of select="abs(@trans.semi) - (floor((abs(@trans.semi)
                                    div 12)) * 12)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                  <xsl:value-of select="@trans.semi"/>
                                </xsl:otherwise>
                              </xsl:choose>
                            </chromatic>
                            <xsl:if test="abs(number(@trans.semi)) &gt;= 12">
                              <octave-change>
                                <xsl:if test="@trans.semi &lt; 0">
                                  <xsl:text>-</xsl:text>
                                </xsl:if>
                                <xsl:value-of select="floor(abs(@trans.semi) div 12)"/>
                              </octave-change>
                            </xsl:if>
                          </xsl:if>
                        </transpose>
                      </xsl:for-each>
                      <xsl:for-each
                        select="$defaultScoreDef//mei:staffGrp[@xml:id=$thisPart]//mei:staffDef[@lines
                        or @visible]">
                        <tranpose>
                          <xsl:attribute name="number">
                            <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
                          </xsl:attribute>
                          <xsl:if test="@trans.diat">
                            <diatonic>
                              <xsl:value-of select="@trans.diat"/>
                            </diatonic>
                          </xsl:if>
                          <xsl:if test="@trans.semi">
                            <chromatic>
                              <xsl:choose>
                                <xsl:when test="abs(number(@trans.semi)) &gt;= 12">
                                  <xsl:if test="@trans.semi &lt; 0">
                                    <xsl:text>-</xsl:text>
                                  </xsl:if>
                                  <xsl:value-of select="abs(@trans.semi) - (floor((abs(@trans.semi)
                                    div 12)) * 12)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                  <xsl:value-of select="@trans.semi"/>
                                </xsl:otherwise>
                              </xsl:choose>
                            </chromatic>
                            <xsl:if test="abs(number(@trans.semi)) &gt;= 12">
                              <octave-change>
                                <xsl:if test="@trans.semi &lt; 0">
                                  <xsl:text>-</xsl:text>
                                </xsl:if>
                                <xsl:value-of select="floor(abs(@trans.semi) div 12)"/>
                              </octave-change>
                            </xsl:if>
                          </xsl:if>
                        </tranpose>
                      </xsl:for-each>
                    </xsl:when>
                  </xsl:choose>
                </xsl:when>
              </xsl:choose>
            </xsl:variable>

            <xsl:variable name="attributes">
              <xsl:if test="$divisions != ''">
                <xsl:choose>
                  <xsl:when test="count($divisions/value) = 1">
                    <divisions>
                      <xsl:value-of select="$divisions"/>
                    </divisions>
                  </xsl:when>
                  <xsl:when test="count($divisions/value) &gt; 1">
                    <xsl:variable name="warning">
                      <xsl:text>More than one @ppq value for the same part</xsl:text>
                    </xsl:variable>
                    <xsl:message terminate="yes">
                      <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
                        ').'))"/>
                    </xsl:message>
                  </xsl:when>
                </xsl:choose>
              </xsl:if>
              <xsl:if test="$keySig != ''">
                <xsl:copy-of select="$keySig"/>
              </xsl:if>
              <xsl:if test="$timeSig != ''">
                <xsl:copy-of select="$timeSig"/>
              </xsl:if>
              <xsl:if test="$staves != ''">
                <xsl:copy-of select="$staves"/>
              </xsl:if>
              <xsl:if test="$clefs != ''">
                <xsl:copy-of select="$clefs"/>
              </xsl:if>
              <xsl:if test="$staffDetails != ''">
                <xsl:copy-of select="$staffDetails"/>
              </xsl:if>
              <xsl:if test="$transpose != ''">
                <xsl:copy-of select="$transpose"/>
              </xsl:if>
            </xsl:variable>

            <xsl:if test="$attributes != ''">
              <attributes>
                <xsl:copy-of select="$attributes"/>
              </attributes>
            </xsl:if>

            <!-- copy events; replace comment elements with XML comments; 
            eliminate beam elements, but keep their contents -->
            <events>
              <xsl:for-each select="events/*">
                <xsl:choose>
                  <xsl:when test="local-name()='beam'">
                    <xsl:copy-of select="mei:*"/>
                  </xsl:when>
                  <xsl:when test="local-name()='comment'">
                    <xsl:comment>
                      <xsl:value-of select="."/>
                    </xsl:comment>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:copy-of select="."/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </events>

            <!-- drop any empty controlevents containers; when controlevents
            has content, add @xml:id to each child -->
            <xsl:if test="controlevents/node()">
              <xsl:copy-of select="controlevents"/>
            </xsl:if>

          </part>
        </xsl:for-each>
      </xsl:variable>

      <!-- DEBUG: -->
      <!--<xsl:copy-of select="$measureContent6"/>-->

      <!-- Measure content pass 7: integrate "measure-attached" controlevents;
      that is, those with @tstamp.ges attribute (but not @startid or @plist), 
      into the sequence of events at the appropriate time -->
      <xsl:variable name="measureContent7">
        <xsl:copy-of select="$measureContent6/comment()"/>
        <xsl:for-each select="$measureContent6/part">
          <xsl:variable name="thisPart">
            <xsl:value-of select="@id"/>
          </xsl:variable>
          <part>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="print[following-sibling::events]"/>
            <xsl:copy-of select="attributes[following-sibling::events]"/>

            <xsl:variable name="controlevents">
              <xsl:copy-of select="controlevents"/>
            </xsl:variable>

            <xsl:variable name="events">
              <xsl:for-each select="events/mei:* | events/backup | events/comment()">
                <xsl:choose>
                  <xsl:when test="local-name()='backup' or local-name()='clef' or name()=''">
                    <!-- copy through backup, clef, and comment nodes -->
                    <xsl:copy-of select="."/>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- process event -->
                    <!-- this event's staff assignment -->
                    <xsl:variable name="thisStaff">
                      <xsl:value-of select="@partStaff"/>
                    </xsl:variable>
                    <xsl:variable name="thisVoice">
                      <xsl:value-of select="@voice"/>
                    </xsl:variable>
                    <!-- this event's time stamp -->
                    <xsl:variable name="thisTstamp.ges">
                      <xsl:choose>
                        <xsl:when test="@tstamp.ges">
                          <xsl:value-of select="number(@tstamp.ges)"/>
                        </xsl:when>
                        <xsl:when test="descendant::*[@tstamp.ges]">
                          <xsl:value-of select="number(descendant::*[@tstamp.ges][1]/@tstamp.ges)"/>
                        </xsl:when>
                      </xsl:choose>
                    </xsl:variable>
                    <!-- the previous event's time stamp -->
                    <xsl:variable name="prevTstamp.ges">
                      <xsl:choose>
                        <xsl:when test="local-name(preceding-sibling::*[1])='backup'">
                          <xsl:value-of select="0"/>
                        </xsl:when>
                        <xsl:when test="count(preceding-sibling::*)=0">
                          <xsl:value-of select="-1"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of
                            select="number(preceding-sibling::mei:*[@tstamp.ges][1]/@tstamp.ges)"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:variable>
                    <xsl:choose>
                      <xsl:when test="$thisTstamp.ges = 0">
                        <!-- DEBUG: -->
                        <!--<xsl:comment>
                          <xsl:value-of select="normalize-space(concat('&#32;', $prevTstamp.ges,
                            '&#32;&lt; tstamp.ges &lt;=&#32;', $thisTstamp.ges,
                            '&#32;'))"/>
                        </xsl:comment>
                        <xsl:copy-of select="$nl"/>-->
                        <!-- first, control events associated with this staff and voice -->
                        <xsl:for-each
                          select="ancestor::part/controlevents/mei:*[number(@tstamp.ges)=0
                          and @partStaff=$thisStaff and @voice=$thisVoice and not(@startid or
                          @plist)]">
                          <controlRef xmlns="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="targettype">
                              <xsl:value-of select="local-name()"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">
                              <xsl:value-of select="@xml:id"/>
                            </xsl:attribute>
                          </controlRef>
                        </xsl:for-each>
                        <!-- next, control events associated with this staff, but not this voice -->
                        <xsl:for-each
                          select="ancestor::part/controlevents/mei:*[number(@tstamp.ges)=0
                          and @partStaff=$thisStaff and not(@startid or @plist)]">
                          <controlRef xmlns="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="targettype">
                              <xsl:value-of select="local-name()"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">
                              <xsl:value-of select="@xml:id"/>
                            </xsl:attribute>
                          </controlRef>
                        </xsl:for-each>
                        <!-- then control events NOT associated with this staff, but occurring
                        in the proper timestamp range -->
                        <xsl:for-each
                          select="ancestor::part/controlevents/mei:*[number(@tstamp.ges)=0
                          and @partStaff!=$thisStaff and not(@startid or @plist)]">
                          <controlRef xmlns="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="targettype">
                              <xsl:value-of select="local-name()"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">
                              <xsl:value-of select="@xml:id"/>
                            </xsl:attribute>
                          </controlRef>
                        </xsl:for-each>
                      </xsl:when>
                      <xsl:otherwise>
                        <!-- control events with tstamp between tstamp of the previous event and this 
                        event's time stamp -->
                        <!-- DEBUG: -->
                        <!--<xsl:comment>
                          <xsl:value-of select="normalize-space(concat('&#32;', $prevTstamp.ges,
                            '&#32;&lt; tstamp.ges &lt;=&#32;', $thisTstamp.ges,
                            '&#32;'))"/>
                        </xsl:comment>
                        <xsl:copy-of select="$nl"/>-->
                        <!-- first, control events associated with this staff and voice -->
                        <xsl:for-each select="ancestor::part/controlevents/mei:*[number(@tstamp.ges)
                          &gt; $prevTstamp.ges and number(@tstamp.ges) &lt;=
                          $thisTstamp.ges and @partStaff=$thisStaff and @voice=$thisVoice and
                          not(@startid or @plist)]">
                          <controlRef xmlns="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="targettype">
                              <xsl:value-of select="local-name()"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">
                              <xsl:value-of select="@xml:id"/>
                            </xsl:attribute>
                          </controlRef>
                        </xsl:for-each>
                        <!-- next, control events associated with this staff, but not this voice -->
                        <xsl:for-each select="ancestor::part/controlevents/mei:*[number(@tstamp.ges)
                          &gt; $prevTstamp.ges and number(@tstamp.ges) &lt;=
                          $thisTstamp.ges and @partStaff=$thisStaff and not(@startid or @plist)]">
                          <controlRef xmlns="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="targettype">
                              <xsl:value-of select="local-name()"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">
                              <xsl:value-of select="@xml:id"/>
                            </xsl:attribute>
                          </controlRef>
                        </xsl:for-each>
                        <!-- then control events NOT associated with this staff, but occurring
                        in the proper timestamp range -->
                        <xsl:for-each select="ancestor::part/controlevents/mei:*[number(@tstamp.ges)
                          &gt; $prevTstamp.ges and number(@tstamp.ges) &lt;=
                          $thisTstamp.ges and @partStaff!=$thisStaff and not(@startid or @plist)]">
                          <controlRef xmlns="http://www.music-encoding.org/ns/mei">
                            <xsl:attribute name="targettype">
                              <xsl:value-of select="local-name()"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">
                              <xsl:value-of select="@xml:id"/>
                            </xsl:attribute>
                          </controlRef>
                        </xsl:for-each>
                      </xsl:otherwise>
                    </xsl:choose>
                    <!-- copy this event -->
                    <xsl:copy-of select="."/>
                    <!-- copy any control events following last event in measure -->
                    <xsl:if test="position()=last() and @tstamp.ges">
                      <xsl:for-each select="ancestor::part/controlevents/mei:*[number(@tstamp.ges)
                        &gt; $thisTstamp.ges and not(@startid or @plist)]">
                        <controlRef xmlns="http://www.music-encoding.org/ns/mei">
                          <xsl:attribute name="targettype">
                            <xsl:value-of select="local-name()"/>
                          </xsl:attribute>
                          <xsl:attribute name="target">
                            <xsl:value-of select="@xml:id"/>
                          </xsl:attribute>
                        </controlRef>
                      </xsl:for-each>
                    </xsl:if>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:variable>

            <!-- resolve control event references, removing any duplicates -->
            <xsl:variable name="events2">
              <xsl:for-each select="$events/mei:* | $events/backup | $events/comment()">
                <xsl:choose>
                  <xsl:when test="local-name()='controlRef'">
                    <xsl:variable name="thisTarget">
                      <xsl:value-of select="@target"/>
                    </xsl:variable>
                    <xsl:if test="not(preceding-sibling::mei:controlRef[@target=$thisTarget])">
                      <xsl:copy-of select="$controlevents//mei:*[@xml:id=$thisTarget]"/>
                    </xsl:if>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:copy-of select="."/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:variable>
            <xsl:copy-of select="$events2"/>

            <!-- carry through only controlevents associated with specific event(s) -->
            <xsl:if test="controlevents/mei:*[@startid or @plist] or controlevents/comment()">
              <controlevents>
                <xsl:copy-of select="controlevents/mei:*[@startid or @plist] |
                  controlevents/comment() "/>
              </controlevents>
            </xsl:if>
          </part>
        </xsl:for-each>
      </xsl:variable>

      <!-- OUTPUT: -->
      <xsl:copy-of select="$measureContent7"/>

    </measure>
  </xsl:template>

  <xsl:template match="mei:note | mei:rest | mei:beam | mei:tuplet | mei:chord | mei:space |
    mei:mRest | mei:mSpace" mode="addTstamp.ges">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <!-- if not already present, add @tstamp.ges -->
      <xsl:if test="not(@tstamp.ges)">
        <xsl:attribute name="tstamp.ges">
          <xsl:choose>
            <xsl:when test="local-name(..)='chord'">
              <xsl:for-each select="..">
                <xsl:value-of select="sum(preceding::mei:*[@dur.ges]/@dur.ges)"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="sum(preceding::mei:*[@dur.ges]/@dur.ges)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="addTstamp.ges"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:note | mei:rest | mei:space | mei:mRest | mei:mSpace" mode="stage1">
    <xsl:variable name="thisStaff">
      <xsl:choose>
        <!-- use @staff when provided -->
        <xsl:when test="@staff">
          <xsl:value-of select="@staff"/>
        </xsl:when>
        <xsl:when test="ancestor::mei:*[@staff]">
          <xsl:value-of select="ancestor::mei:*[@staff][1]/@staff"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="ancestor::mei:staff/@n"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="partID">
      <xsl:call-template name="partID">
        <xsl:with-param name="thisStaff">
          <xsl:value-of select="$thisStaff"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="ppq">
      <xsl:choose>
        <xsl:when test="preceding::mei:staffDef[@n=$thisStaff and @ppq] and not($reQuantize)">
          <xsl:value-of select="preceding::mei:staffDef[@n=$thisStaff and @ppq][1]/@ppq"/>
        </xsl:when>
        <xsl:when test="preceding::mei:scoreDef[@ppq] and not($reQuantize)">
          <xsl:value-of select="preceding::mei:scoreDef[@ppq][1]/@ppq"/>
        </xsl:when>
        <xsl:when test="preceding::mei:*[ancestor::mei:staff[@n=$thisStaff] and @dur='4' and
          not(@dots) and @dur.ges] and not($reQuantize)">
          <xsl:value-of select="replace(preceding::mei:*[ancestor::mei:staff[@n=$thisStaff] and
            @dur='4' and not(@dots) and @dur.ges][1]/@dur.ges, '[^\d]+', '')"/>
        </xsl:when>
        <xsl:when test="following::mei:*[ancestor::mei:staff[@n=$thisStaff] and @dur='4' and
          @dur.ges] and not($reQuantize)">
          <xsl:value-of select="replace(following::mei:*[ancestor::mei:staff[@n=$thisStaff] and
            @dur='4' and not(@dots) and @dur.ges][1]/@dur.ges, '[^\d]+', '')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$ppqDefault"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="meterCount">
      <xsl:choose>
        <xsl:when test="preceding::mei:staffDef[@n=$thisStaff and @meter.count]">
          <xsl:value-of select="preceding::mei:staffDef[@n=$thisStaff and
            @meter.count][1]/@meter.count"/>
        </xsl:when>
        <xsl:when test="preceding::mei:scoreDef[@meter.count]">
          <xsl:value-of select="preceding::mei:scoreDef[@meter.count][1]/@meter.count"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="4"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="meterUnit">
      <xsl:choose>
        <xsl:when test="preceding::mei:staffDef[@n=$thisStaff and @meter.unit]">
          <xsl:value-of select="preceding::mei:staffDef[@n=$thisStaff and
            @meter.unit][1]/@meter.unit"/>
        </xsl:when>
        <xsl:when test="preceding::mei:scoreDef[@meter.unit]">
          <xsl:value-of select="preceding::mei:scoreDef[@meter.unit][1]/@meter.unit"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="4"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="measureDuration">
      <xsl:call-template name="measureDuration">
        <xsl:with-param name="ppq" select="$ppq"/>
        <xsl:with-param name="meterCount" select="$meterCount"/>
        <xsl:with-param name="meterUnit" select="$meterUnit"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="@*[not(name()='dur.ges')]"/>
      <xsl:if test="not(@beam) and (ancestor::mei:beam or ancestor::mei:*[@beam])">
        <xsl:attribute name="beam">
          <xsl:choose>
            <xsl:when test="ancestor::mei:*[@beam]">
              <xsl:value-of select="ancestor::mei:*[@beam]/@beam"/>
            </xsl:when>
            <xsl:when test="local-name(..) = 'beam'">
              <xsl:choose>
                <xsl:when test="count(preceding-sibling::mei:*) = 0">
                  <xsl:text>i</xsl:text>
                </xsl:when>
                <xsl:when test="count(following-sibling::mei:*) = 0">
                  <xsl:text>t</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>m</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:value-of select="count(ancestor::mei:beam)"/>
            </xsl:when>
            <xsl:when test="ancestor::mei:beam">
              <xsl:for-each select="..">
                <xsl:choose>
                  <xsl:when test="count(preceding-sibling::mei:*) = 0">
                    <xsl:text>i</xsl:text>
                  </xsl:when>
                  <xsl:when test="count(following-sibling::mei:*) = 0">
                    <xsl:text>t</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>m</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
              <xsl:value-of select="count(ancestor::mei:beam)"/>
            </xsl:when>
          </xsl:choose>
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="measureDuration">
        <xsl:value-of select="$measureDuration"/>
      </xsl:attribute>
      <!--<xsl:variable name="partID">
        <xsl:call-template name="partID">
          <xsl:with-param name="thisStaff">
            <xsl:value-of select="$thisStaff"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>-->
      <!-- part ID -->
      <xsl:attribute name="partID">
        <xsl:value-of select="$partID"/>
      </xsl:attribute>
      <!-- staff assignment in MEI; that is, staff counted from top to bottom of score -->
      <xsl:attribute name="meiStaff">
        <!-- For sorting purposes, this is set to the @n value of the ancestor staff; however,
        this may not be the actual staff on which the note occurs. For example, a chord
        may have notes on more than one staff. @staff will have the original value. -->
        <xsl:value-of select="ancestor::mei:staff/@n"/>
      </xsl:attribute>
      <!-- staff assignment in MusicXML; that is, where the numbering of staves starts over
        with each part. The event's @staff value takes precedence over the <staff> in which 
        it occurred. -->
      <xsl:attribute name="partStaff">
        <xsl:variable name="thisStaff">
          <xsl:choose>
            <xsl:when test="@staff">
              <xsl:value-of select="@staff"/>
            </xsl:when>
            <xsl:when test="ancestor::mei:*[@staff]">
              <xsl:value-of select="ancestor::mei:*[@staff][1]/@staff"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$thisStaff"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="preceding::mei:staffGrp[@xml:id and
            mei:staffDef[@n=$thisStaff]]/mei:staffDef[@n=$thisStaff]">
            <xsl:for-each select="preceding::mei:staffGrp[@xml:id and
              mei:staffDef[@n=$thisStaff]][1]/mei:staffDef[@n=$thisStaff]">
              <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:when
            test="preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]]/mei:staffDef[@n=$thisStaff]">
            <xsl:value-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$thisStaff"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <!-- At this point, voice = layer assigned in MEI -->
      <xsl:attribute name="voice">
        <xsl:value-of select="ancestor::mei:layer/@n"/>
      </xsl:attribute>
      <xsl:if test="local-name(..) != 'chord'">
        <xsl:attribute name="dur.ges">
          <xsl:choose>
            <xsl:when test="@dur.ges and not($reQuantize)">
              <xsl:value-of select="replace(@dur.ges, '[^\d]+', '')"/>
            </xsl:when>
            <!-- event is a grace note/chord; gestural duration = 0 -->
            <xsl:when test="@grace">
              <xsl:value-of select="0"/>
            </xsl:when>
            <!-- event is a measure rest or space -->
            <xsl:when test="local-name()='mRest' or local-name()='mSpace'">
              <xsl:choose>
                <!-- calculate gestural duration based on written duration -->
                <xsl:when test="@dur">
                  <xsl:call-template name="gesturalDurationFromWrittenDuration">
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
                <xsl:otherwise>
                  <xsl:value-of select="$measureDuration"/>
                </xsl:otherwise>
                <!-- could use sum of gestural durations of events on other layer of 
                    this or some other staff -->
              </xsl:choose>
            </xsl:when>
            <!-- event is neither grace, measure rest nor measure space -->
            <xsl:otherwise>
              <!-- calculate gestural duration based on written duration -->
              <xsl:call-template name="gesturalDurationFromWrittenDuration">
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
        </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="comment()"/>
      <xsl:apply-templates select="mei:*" mode="stage1"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:pgHead | mei:pgFoot | mei:pgHead2 | mei:pgFoot2">
    <xsl:choose>
      <xsl:when test="mei:anchoredText">
        <xsl:apply-templates select="mei:anchoredText"/>
      </xsl:when>
      <xsl:otherwise>
        <credit>
          <xsl:attribute name="page">
            <xsl:choose>
              <xsl:when test="ancestor-or-self::mei:pgHead or ancestor-or-self::mei:pgFoot">
                <xsl:value-of select="1"/>
              </xsl:when>
              <xsl:when test="ancestor-or-self::mei:pgHead2 or ancestor-or-self::mei:pgFoot2">
                <xsl:value-of select="2"/>
              </xsl:when>
            </xsl:choose>
          </xsl:attribute>
          <xsl:choose>
            <!-- pgHead, etc. contains only rend and lb elements -->
            <xsl:when test="(mei:rend or mei:lb) and count(mei:rend) + count(mei:lb) = count(mei:*)">
              <xsl:for-each select="mei:rend">
                <credit-words>
                  <xsl:call-template name="rendition"/>
                  <xsl:variable name="creditText">
                    <xsl:apply-templates mode="stage1"/>
                  </xsl:variable>
                  <xsl:value-of select="replace(replace($creditText, '&#32;&#32;+', '&#32;'),
                    '&#xA;&#32;', '&#xA;')"/>
                </credit-words>
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="mei:table and count(mei:table) = count(mei:*)">
              <!-- pgHead, etc. contains a table -->
              <xsl:for-each select="descendant::mei:td">
                <credit-words>
                  <xsl:copy-of select="mei:rend[1]/@*"/>
                  <xsl:variable name="creditText">
                    <xsl:apply-templates mode="stage1"/>
                  </xsl:variable>
                  <xsl:value-of select="replace(replace($creditText, '&#32;&#32;+', '&#32;'),
                    '&#xA;&#32;', '&#xA;')"/>
                </credit-words>
              </xsl:for-each>
            </xsl:when>
            <!-- pgHead, etc. has mixed content -->
            <xsl:when test="text()">
              <credit-words>
                <xsl:variable name="creditText">
                  <xsl:apply-templates mode="stage1"/>
                </xsl:variable>
                <xsl:value-of select="replace(replace($creditText, '&#32;&#32;+', '&#32;'),
                  '&#xA;&#32;', '&#xA;')"/>
              </credit-words>
            </xsl:when>
            <!-- pgHead, etc. contains MEI elements other than rend, lb, or table -->
            <xsl:otherwise>
              <xsl:for-each select="mei:*[not(local-name()='lb')]">
                <xsl:choose>
                  <!-- subordinate element contains only rend and lb elements -->
                  <xsl:when test="(mei:rend or mei:lb) and count(mei:rend) + count(mei:lb) =
                    count(mei:*)">
                    <xsl:for-each select="mei:rend">
                      <credit-words>
                        <xsl:call-template name="rendition"/>
                        <xsl:variable name="creditText">
                          <xsl:apply-templates mode="stage1"/>
                        </xsl:variable>
                        <xsl:value-of select="replace(replace($creditText, '&#32;&#32;+', '&#32;'),
                          '&#xA;&#32;', '&#xA;')"/>
                      </credit-words>
                    </xsl:for-each>
                  </xsl:when>
                  <!-- subordinate element has mixed content -->
                  <xsl:otherwise>
                    <credit-words>
                      <xsl:call-template name="rendition"/>
                      <xsl:variable name="creditText">
                        <xsl:apply-templates mode="stage1"/>
                      </xsl:variable>
                      <xsl:value-of select="replace(replace($creditText, '&#32;&#32;+', '&#32;'),
                        '&#xA;&#32;', '&#xA;')"/>
                    </credit-words>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </credit>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:rend" mode="stage1">
    <xsl:apply-templates mode="stage1"/>
  </xsl:template>

  <xsl:template match="mei:scoreDef" mode="credits">
    <xsl:apply-templates select="mei:pgHead | mei:pgFoot "/>
    <xsl:apply-templates select="mei:pgHead2 | mei:pgFoot2"/>
  </xsl:template>

  <xsl:template match="mei:scoreDef" mode="defaults">
    <xsl:if test="@vu.height | @page.height | @page.width | @page.leftmar | @page.rightmar |
      @page.topmar | @page.botmar | @system.leftmar | @system.rightmar | @system.topmar |
      @spacing.system | @spacing.staff | @music.name | @text.name | @lyric.name">
      <defaults>
        <xsl:if test="@vu.height">
          <scaling>
            <millimeters>
              <xsl:value-of select="number(replace(@vu.height, '[a-z]+$', '')) * 8"/>
            </millimeters>
            <tenths>40</tenths>
          </scaling>
        </xsl:if>
        <xsl:if test="@page.height | @page.width | @page.leftmar | @page.rightmar | @page.topmar |
          @page.botmar">
          <page-layout>
            <page-height>
              <xsl:value-of select="format-number(number(replace(@page.height, '[a-z]+$', '')) *
                5, '###0.####')"/>
            </page-height>
            <page-width>
              <xsl:value-of select="format-number(number(replace(@page.width, '[a-z]+$', '')) * 5,
                '###0.####')"/>
            </page-width>
            <page-margins type="both">
              <left-margin>
                <xsl:choose>
                  <xsl:when test="replace(@page.leftmar, '[a-z]+$', '') = '0'">
                    <xsl:value-of select="@page.leftmar"/>
                  </xsl:when>
                  <xsl:when test="number(replace(@page.leftmar, '[a-z]+$', ''))">
                    <xsl:value-of select="format-number(number(replace(@page.leftmar, '[a-z]+$',
                      '')) * 5, '###0.####')"/>
                  </xsl:when>
                </xsl:choose>
              </left-margin>
              <right-margin>
                <xsl:choose>
                  <xsl:when test="replace(@page.rightmar, '[a-z]+$', '') = '0'">
                    <xsl:value-of select="@page.rightmar"/>
                  </xsl:when>
                  <xsl:when test="number(replace(@page.rightmar, '[a-z]+$', ''))">
                    <xsl:value-of select="format-number(number(replace(@page.rightmar, '[a-z]+$',
                      '')) * 5, '###0.####')"/>
                  </xsl:when>
                </xsl:choose>
              </right-margin>
              <top-margin>
                <xsl:choose>
                  <xsl:when test="replace(@page.topmar, '[a-z]+$', '') = '0'">
                    <xsl:value-of select="@page.topmar"/>
                  </xsl:when>
                  <xsl:when test="number(replace(@page.topmar, '[a-z]+$', ''))">
                    <xsl:value-of select="format-number(number(replace(@page.topmar, '[a-z]+$', ''))
                      * 5, '###0.####')"/>
                  </xsl:when>
                </xsl:choose>
              </top-margin>
              <bottom-margin>
                <xsl:choose>
                  <xsl:when test="replace(@page.botmar, '[a-z]+$', '') = '0'">
                    <xsl:value-of select="@page.botmar"/>
                  </xsl:when>
                  <xsl:when test="number(replace(@page.botmar, '[a-z]+$', ''))">
                    <xsl:value-of select="format-number(number(replace(@page.botmar, '[a-z]+$', ''))
                      * 5, '###0.####')"/>
                  </xsl:when>
                </xsl:choose>
              </bottom-margin>
            </page-margins>
          </page-layout>
        </xsl:if>
        <xsl:if test="@system.leftmar | @system.rightmar | @system.topmar | @spacing.system">
          <system-layout>
            <system-margins>
              <left-margin>
                <xsl:choose>
                  <xsl:when test="replace(@system.leftmar, '[a-z]+$', '') = '0'">
                    <xsl:value-of select="@system.leftmar"/>
                  </xsl:when>
                  <xsl:when test="number(replace(@system.leftmar, '[a-z]+$', ''))">
                    <xsl:value-of select="format-number(number(replace(@system.leftmar, '[a-z]+$',
                      ''))* 5, '###0.####')"/>
                  </xsl:when>
                </xsl:choose>
              </left-margin>
              <right-margin>
                <xsl:choose>
                  <xsl:when test="replace(@system.rightmar, '[a-z]+$', '') = '0'">
                    <xsl:value-of select="@system.rightmar"/>
                  </xsl:when>
                  <xsl:when test="number(replace(@system.rightmar, '[a-z]+$', ''))">
                    <xsl:value-of select="format-number(number(replace(@system.rightmar, '[a-z]+$',
                      '')) * 5, '###0.####')"/>
                  </xsl:when>
                </xsl:choose>
              </right-margin>
            </system-margins>
            <system-distance>
              <xsl:choose>
                <xsl:when test="replace(@spacing.system, '[a-z]+$', '') = '0'">
                  <xsl:value-of select="@spacing.system"/>
                </xsl:when>
                <xsl:when test="number(replace(@spacing.system, '[a-z]+$', ''))">
                  <xsl:value-of select="format-number(number(replace(@spacing.system, '[a-z]+$',
                    '')) * 5, '###0.####')"/>
                </xsl:when>
              </xsl:choose>
            </system-distance>
            <top-system-distance>
              <xsl:choose>
                <xsl:when test="replace(@system.topmar, '[a-z]+$', '') = '0'">
                  <xsl:value-of select="@system.topmar"/>
                </xsl:when>
                <xsl:when test="number(replace(@system.topmar, '[a-z]+$', ''))">
                  <xsl:value-of select="format-number(number(replace(@system.topmar, '[a-z]+$', ''))
                    * 5, '###0.####')"/>
                </xsl:when>
              </xsl:choose>
            </top-system-distance>
          </system-layout>
        </xsl:if>
        <xsl:if test="@spacing.staff">
          <staff-layout>
            <staff-distance>
              <xsl:choose>
                <xsl:when test="replace(@spacing.staff, '[a-z]+$', '') = '0'">
                  <xsl:value-of select="@spacing.staff"/>
                </xsl:when>
                <xsl:when test="number(replace(@spacing.staff, '[a-z]+$', ''))">
                  <xsl:value-of select="format-number(number(replace(@spacing.staff, '[a-z]+$', ''))
                    * 5, '###0.####')"/>
                </xsl:when>
              </xsl:choose>
            </staff-distance>
          </staff-layout>
        </xsl:if>
        <xsl:if test="@music.name | @text.name | @lyric.name">
          <music-font>
            <xsl:attribute name="font-family">
              <xsl:value-of select="normalize-space(@music.name)"/>
            </xsl:attribute>
            <xsl:if test="@music.size">
              <xsl:attribute name="font-size">
                <xsl:value-of select="@music.size"/>
              </xsl:attribute>
            </xsl:if>
          </music-font>
        </xsl:if>
        <xsl:if test="@text.name">
          <word-font>
            <xsl:attribute name="font-family">
              <xsl:value-of select="normalize-space(@text.name)"/>
            </xsl:attribute>
            <xsl:if test="@text.size">
              <xsl:attribute name="font-size">
                <xsl:value-of select="@text.size"/>
              </xsl:attribute>
            </xsl:if>
          </word-font>
        </xsl:if>
        <xsl:if test="@lyric.name">
          <lyric-font>
            <xsl:attribute name="font-family">
              <xsl:value-of select="normalize-space(@lyric.name)"/>
            </xsl:attribute>
            <xsl:if test="@lyric.size">
              <xsl:attribute name="font-size">
                <xsl:value-of select="@lyric.size"/>
              </xsl:attribute>
            </xsl:if>
          </lyric-font>
        </xsl:if>
      </defaults>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:staff/comment() | mei:layer/comment()" mode="stage1">
    <!-- comments within staff or layer become comment elements so that they can be assigned
    to a part and staff -->
    <comment>
      <xsl:variable name="thisStaff">
        <xsl:value-of select="ancestor::mei:staff/@n"/>
      </xsl:variable>
      <xsl:variable name="partID">
        <xsl:call-template name="partID">
          <xsl:with-param name="thisStaff">
            <xsl:value-of select="$thisStaff"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <!-- part ID -->
      <xsl:attribute name="partID">
        <xsl:value-of select="$partID"/>
      </xsl:attribute>
      <!-- staff assignment in MEI; that is, staff counted from top to bottom of score -->
      <xsl:attribute name="meiStaff">
        <xsl:value-of select="ancestor::mei:staff/@n"/>
      </xsl:attribute>
      <!-- staff assignment in MusicXML; that is, where the numbering of staves starts over with each part -->
      <xsl:attribute name="partStaff">
        <xsl:choose>
          <xsl:when test="preceding::mei:staffGrp[@xml:id and
            mei:staffDef[@n=$thisStaff]]/mei:staffDef[@n=$thisStaff]">
            <xsl:for-each select="preceding::mei:staffGrp[@xml:id and
              mei:staffDef[@n=$thisStaff]][1]/mei:staffDef[@n=$thisStaff]">
              <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:when
            test="preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]]/mei:staffDef[@n=$thisStaff]">
            <xsl:value-of select="1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$thisStaff"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <!-- At this point, voice = layer assigned in MEI -->
      <xsl:attribute name="voice">
        <xsl:choose>
          <xsl:when test="ancestor::mei:layer">
            <xsl:value-of select="ancestor::mei:layer/@n"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:value-of select="."/>
    </comment>
  </xsl:template>

  <xsl:template match="mei:staffDef" mode="partList">
    <score-part>
      <xsl:attribute name="id">
        <xsl:choose>
          <xsl:when test="@xml:id">
            <xsl:value-of select="@xml:id"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>P</xsl:text>
            <xsl:value-of select="generate-id()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <part-name>
        <xsl:choose>
          <xsl:when test="@label">
            <xsl:value-of select="replace(replace(@label, '&#x266d;', 'b'), '&#x266f;', '#')"/>
          </xsl:when>
          <xsl:when test="ancestor::mei:staffGrp[@label]">
            <xsl:value-of select="replace(replace(ancestor::mei:staffGrp[@label][1]/@label,
              '&#x266d;', 'b'), '&#x266f;', '#')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>MusicXML Part</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </part-name>
      <xsl:if test="matches(@label, '(&#x266d;|&#x266f;)')">
        <part-name-display>
          <xsl:apply-templates select="@label" mode="partName"/>
        </part-name-display>
      </xsl:if>
      <xsl:if test="@label.abbr">
        <part-abbreviation>
          <xsl:value-of select="replace(replace(@label.abbr, '&#x266d;', 'b'), '&#x266f;', '#')"/>
        </part-abbreviation>
      </xsl:if>
      <xsl:if test="matches(@label.abbr, '(&#x266d;|&#x266f;)')">
        <part-abbreviation-display>
          <xsl:apply-templates select="@label.abbr" mode="partName"/>
        </part-abbreviation-display>
      </xsl:if>
      <xsl:apply-templates select="mei:instrDef" mode="partList"/>
    </score-part>
  </xsl:template>

  <xsl:template match="mei:staffGrp" mode="partList">
    <!-- The assignment of staffGrp and staffDef elements to MusicXML parts
      depends on the occurrence of instrDef or the use of @xml:id. When a staffGrp
      has a single instrument definition or has an xml:id attribute, then it becomes 
      a part. Otherwise, each staff definition is a part. -->
    <xsl:if test="exists(@*)">
      <part-group type="start">
        <xsl:attribute name="number">
          <xsl:value-of select="count(ancestor::mei:staffGrp[exists(@*)])+1"/>
        </xsl:attribute>
        <xsl:if test="@label">
          <group-name>
            <xsl:value-of select="replace(replace(@label, '&#x266d;', 'b'), '&#x266f;', '#')"/>
          </group-name>
        </xsl:if>
        <xsl:if test="matches(@label, '(&#x266d;|&#x266f;)')">
          <group-name-display>
            <xsl:apply-templates select="@label" mode="partName"/>
          </group-name-display>
        </xsl:if>
        <xsl:if test="@label.abbr">
          <group-abbreviation>
            <xsl:value-of select="replace(replace(@label.abbr, '&#x266d;', 'b'), '&#x266f;', '#')"/>
          </group-abbreviation>
        </xsl:if>
        <xsl:if test="matches(@label.abbr, '(&#x266d;|&#x266f;)')">
          <group-abbreviation-display>
            <xsl:apply-templates select="@label.abbr" mode="partName"/>
          </group-abbreviation-display>
        </xsl:if>
        <xsl:if test="@symbol">
          <group-symbol>
            <xsl:if test="@symbol != 'line'">
              <xsl:value-of select="@symbol"/>
            </xsl:if>
          </group-symbol>
        </xsl:if>
        <xsl:if test="@barthru">
          <group-barline>
            <xsl:choose>
              <xsl:when test="@barthru='true'">
                <xsl:text>yes</xsl:text>
              </xsl:when>
              <xsl:when test="@barthru='false'">
                <xsl:text>no</xsl:text>
              </xsl:when>
            </xsl:choose>
          </group-barline>
        </xsl:if>
      </part-group>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="count(mei:instrDef) = 1">
        <!-- The staff group constitutes a single part -->
        <score-part>
          <xsl:attribute name="id">
            <xsl:value-of select="@xml:id"/>
          </xsl:attribute>
          <part-name>
            <xsl:choose>
              <xsl:when test="@label">
                <xsl:value-of select="replace(replace(@label, '&#x266d;', 'b'), '&#x266f;', '#')"/>
              </xsl:when>
              <xsl:when test="ancestor::mei:staffGrp[@label]">
                <xsl:value-of select="replace(replace(ancestor::mei:staffGrp[@label][1]/@label,
                  '&#x266d;', 'b'), '&#x266f;', '#')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>MusicXML Part</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </part-name>
          <xsl:if test="matches(@label, '(&#x266d;|&#x266f;)')">
            <part-name-display>
              <xsl:apply-templates select="@label" mode="partName"/>
            </part-name-display>
          </xsl:if>
          <xsl:if test="@label.abbr">
            <part-abbreviation>
              <xsl:value-of select="replace(replace(@label.abbr, '&#x266d;', 'b'), '&#x266f;', '#')"
              />
            </part-abbreviation>
          </xsl:if>
          <xsl:if test="matches(@label.abbr, '(&#x266d;|&#x266f;)')">
            <part-abbreviation-display>
              <xsl:apply-templates select="@label.abbr" mode="partName"/>
            </part-abbreviation-display>
          </xsl:if>
          <xsl:apply-templates select="mei:instrDef" mode="partList"/>
        </score-part>
      </xsl:when>
      <xsl:when test="@xml:id">
        <!-- The staff group constitutes a single part -->
        <!-- Can this be OR'd with the condition above? -->
        <score-part>
          <xsl:attribute name="id">
            <xsl:value-of select="@xml:id"/>
          </xsl:attribute>
          <part-name>
            <xsl:choose>
              <xsl:when test="@label">
                <xsl:value-of select="replace(replace(@label, '&#x266d;', 'b'), '&#x266f;', '#')"/>
              </xsl:when>
              <xsl:when test="ancestor::mei:staffGrp[@label]">
                <xsl:value-of select="replace(replace(ancestor::mei:staffGrp[@label][1]/@label,
                  '&#x266d;', 'b'), '&#x266f;', '#')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>MusicXML Part</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </part-name>
          <xsl:if test="matches(@label, '(&#x266d;|&#x266f;)')">
            <part-name-display>
              <xsl:apply-templates select="@label" mode="partName"/>
            </part-name-display>
          </xsl:if>
          <xsl:if test="@label.abbr">
            <part-abbreviation>
              <xsl:value-of select="replace(replace(@label.abbr, '&#x266d;', 'b'), '&#x266f;', '#')"
              />
            </part-abbreviation>
          </xsl:if>
          <xsl:if test="matches(@label.abbr, '(&#x266d;|&#x266f;)')">
            <part-abbreviation-display>
              <xsl:apply-templates select="@label.abbr" mode="partName"/>
            </part-abbreviation-display>
          </xsl:if>
          <xsl:apply-templates select="mei:instrDef" mode="partList"/>
        </score-part>
      </xsl:when>
      <!-- each staffGrp or staffDef is a separate part -->
      <xsl:otherwise>
        <xsl:apply-templates select="mei:staffDef | mei:staffGrp" mode="partList"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="exists(@*)">
      <part-group type="stop">
        <xsl:attribute name="number">
          <xsl:value-of select="count(ancestor::mei:staffGrp[exists(@*)])+1"/>
        </xsl:attribute>
      </part-group>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:work | mei:source">
    <!-- Both work and source descriptions result in MusicXML work description -->
    <xsl:variable name="workContent">
      <work>
        <xsl:choose>
          <xsl:when test="mei:titleStmt//mei:identifier[@type='workNum']">
            <xsl:for-each select="mei:titleStmt//mei:identifier[@type='workNum'][1]">
              <work-number>
                <xsl:value-of select="."/>
              </work-number>
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="mei:titleStmt//mei:identifier[not(@type='mvtNum')]">
            <work-number>
              <xsl:for-each select="mei:titleStmt//mei:identifier[not(@type='mvtNum')]">
                <xsl:value-of select="."/>
                <xsl:if test="position() != last()">
                  <xsl:text>,&#32;</xsl:text>
                </xsl:if>
              </xsl:for-each>
            </work-number>
          </xsl:when>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="mei:titleStmt/mei:title[@type='uniform']">
            <xsl:for-each select="mei:titleStmt/mei:title[@type='uniform'][1]">
              <xsl:variable name="workTitle">
                <xsl:apply-templates select="." mode="workTitle"/>
              </xsl:variable>
              <xsl:if test="normalize-space($workTitle) != ''">
                <work-title>
                  <xsl:value-of select="replace(normalize-space($workTitle), '(,|;|:|\.|\s)+$', '')"
                  />
                </work-title>
              </xsl:if>
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="mei:titleStmt/mei:title[@label='work']">
            <xsl:variable name="workTitle">
              <xsl:for-each select="mei:titleStmt/mei:title[@label='work']">
                <xsl:apply-templates select="mei:*[not(local-name()='title' and @label='movement')]
                  | text()" mode="workTitle"/>
                <xsl:if test="position() != last()">
                  <xsl:text> ; </xsl:text>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:if test="normalize-space($workTitle) != ''">
              <work-title>
                <xsl:value-of select="replace(normalize-space($workTitle), '(,|;|:|\.|\s)+$', '')"/>
              </work-title>
            </xsl:if>
          </xsl:when>
          <xsl:when test="mei:titleStmt/mei:title[not(@label='movement')]">
            <xsl:variable name="workTitle">
              <xsl:for-each select="mei:titleStmt/mei:title[not(@label='movement')]">
                <xsl:apply-templates select="." mode="workTitle"/>
                <xsl:if test="position() != last()">
                  <xsl:text> ; </xsl:text>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:if test="normalize-space($workTitle) != ''">
              <work-title>
                <xsl:value-of select="replace(normalize-space($workTitle), '(,|;|:|\.|\s)+$', '')"/>
              </work-title>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </work>
    </xsl:variable>
    <xsl:if test="$workContent/work/*">
      <xsl:copy-of select="$workContent"/>
    </xsl:if>
    <xsl:for-each select="mei:titleStmt//mei:identifier[@type='mvtNum'][1]">
      <movement-number>
        <xsl:value-of select="."/>
      </movement-number>
    </xsl:for-each>
    <xsl:if test="mei:titleStmt//mei:title[@label='movement']">
      <xsl:variable name="movementTitle">
        <xsl:for-each select="mei:titleStmt//mei:title[@label='movement']">
          <xsl:apply-templates select="." mode="workTitle"/>
          <xsl:if test="position() != last()">
            <xsl:text> ; </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <movement-title>
        <xsl:value-of select="replace(normalize-space($movementTitle), '(,|;|:|\.|\s)+$', '')"/>
      </movement-title>
    </xsl:if>
    <identification>
      <xsl:choose>
        <xsl:when test="mei:titleStmt/mei:respStmt/mei:resp">
          <xsl:for-each select="mei:titleStmt/mei:respStmt/mei:resp">
            <creator>
              <xsl:attribute name="type">
                <xsl:value-of select="."/>
              </xsl:attribute>
              <xsl:value-of select="following-sibling::mei:name[1]"/>
            </creator>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="mei:titleStmt/mei:respStmt[mei:name or mei:persName or mei:corpName]">
          <xsl:for-each select="mei:titleStmt/mei:respStmt">
            <xsl:for-each select="mei:name | mei:persName | mei:corpName">
              <creator>
                <xsl:attribute name="type">
                  <xsl:value-of select="@role"/>
                </xsl:attribute>
                <xsl:value-of select="."/>
              </creator>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="ancestor::mei:meiHead/mei:fileDesc/mei:pubStmt/mei:availability"/>
      <encoding>
        <software>
          <xsl:value-of select="$progName"/>
          <xsl:text>&#32;</xsl:text>
          <xsl:value-of select="$progVersion"/>
        </software>
        <encoding-date>
          <xsl:value-of select="format-date(current-date(), '[Y]-[M02]-[D02]')"/>
        </encoding-date>
      </encoding>
      <!-- the source for the conversion is the MEI file -->
      <source>
        <xsl:variable name="source">
          <xsl:apply-templates select="ancestor::mei:meiHead/mei:fileDesc" mode="source"/>
        </xsl:variable>
        <xsl:text>MEI encoding</xsl:text>
        <xsl:choose>
          <xsl:when test="normalize-space($source) != ''">
            <xsl:text>:&#32;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>.</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$source"/>
      </source>
      <!-- miscellaneous information -->
      <xsl:if test="ancestor::mei:meiHead//mei:notesStmt[mei:annot[@label]]">
        <miscellaneous>
          <xsl:for-each select="ancestor::mei:meiHead//mei:notesStmt[mei:annot]/mei:annot[@label]">
            <miscellaneous-field>
              <xsl:attribute name="name">
                <xsl:value-of select="@label"/>
              </xsl:attribute>
              <xsl:value-of select="."/>
            </miscellaneous-field>
          </xsl:for-each>
        </miscellaneous>
      </xsl:if>
    </identification>
  </xsl:template>

  <!-- Named templates -->
  <xsl:template name="gesturalDurationFromWrittenDuration">
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

  <xsl:template name="measureDuration">
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

  <xsl:template name="partID">
    <xsl:param name="thisStaff">1</xsl:param>
    <xsl:choose>
      <!-- use the xml:id of preceding staffGrp that has staff definition child for the current staff -->
      <xsl:when test="preceding::mei:staffGrp[@xml:id][mei:staffDef[@n=$thisStaff]]">
        <xsl:value-of
          select="preceding::mei:staffGrp[@xml:id][mei:staffDef[@n=$thisStaff]][1]/@xml:id"/>
      </xsl:when>
      <!-- use the xml:id of preceding staffGrp that has staff definition descendant for the current staff -->
      <xsl:when test="preceding::mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]]">
        <xsl:value-of
          select="preceding::mei:staffGrp[@xml:id][descendant::mei:staffDef[@n=$thisStaff]][1]/@xml:id"
        />
      </xsl:when>
      <!-- use the xml:id of preceding staffDef for the current staff -->
      <xsl:when test="preceding::mei:staffDef[@n=$thisStaff and @xml:id]">
        <xsl:value-of select="preceding::mei:staffDef[@n=$thisStaff and
          @xml:id][1]/@xml:id"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- construct a part ID -->
        <xsl:text>P</xsl:text>
        <xsl:value-of
          select="generate-id(preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]][1]/mei:staffDef[@n=$thisStaff])"/>

        <!-- construct a part ID -->
        <!--<xsl:text>P</xsl:text>
        <xsl:choose>
          <xsl:when
            test="count(preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]][1]/mei:staffDef)=1">
            <xsl:value-of
              select="generate-id(preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]][1]/mei:staffDef[1])"
            />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of
              select="generate-id(preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]][1])"/>
          </xsl:otherwise>
        </xsl:choose>-->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="rendition">
    <!-- creates renditional attributes -->
    <xsl:copy-of select="@halign | @rotation | @valign | @xml:lang | @xml:space"/>
    <!-- color has to be converted to AARRGGBB -->
    <xsl:if test="@fontfam">
      <xsl:attribute name="font-family">
        <xsl:value-of select="@fontfam"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@fontsize">
      <xsl:attribute name="font-size">
        <xsl:value-of select="@fontsize"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@fontstyle">
      <xsl:attribute name="font-style">
        <xsl:value-of select="@fontstyle"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@fontweight">
      <xsl:attribute name="font-weight">
        <xsl:value-of select="@fontweight"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@rend">
      <xsl:analyze-string select="@rend" regex="\s+">
        <xsl:non-matching-substring>
          <xsl:choose>
            <xsl:when test="matches(., '^underline$')">
              <xsl:attribute name="underline">
                <xsl:value-of select="1"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="matches(., 'underline\(\d+\)')">
              <xsl:attribute name="underline">
                <xsl:value-of select="replace(., '.*\((\d+)\)', '$1')"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="matches(., '^overline$')">
              <xsl:attribute name="overline">
                <xsl:value-of select="1"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="matches(., 'overline\(\d+\)')">
              <xsl:attribute name="overline">
                <xsl:value-of select="replace(., '.*\((\d+)\)', '$1')"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="matches(., '^(line-through|strike)$')">
              <xsl:attribute name="line-through">
                <xsl:value-of select="1"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="matches(., '(line-through|strike)\(\d+\)')">
              <xsl:attribute name="line-through">
                <xsl:value-of select="replace(., '.*\((\d+)\)', '$1')"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="matches(., 'letter-spacing\((\+|-)?\d+(\.\d+)?\)')">
              <xsl:attribute name="letter-spacing">
                <xsl:value-of select="replace(., '.*\(((\+|-)?\d+(\.\d+)?)\)', '$1')"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="matches(., 'line-height\((\+|-)?\d+(\.\d+)?\)')">
              <xsl:attribute name="line-height">
                <xsl:value-of select="replace(., '.*\(((\+|-)?\d+(\.\d+)?)\)', '$1')"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="matches(., '(bold|bolder)')">
              <xsl:attribute name="font-weight">
                <xsl:text>bold</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="matches(., '(box|circle|dbox|tbox)')">
              <xsl:attribute name="enclosure">
                <xsl:value-of select="replace(replace(replace(replace(., 'tbox', 'triangle'),
                  'dbox', 'diamond'), 'box', 'rectangle'), 'circle', 'circle')"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="matches(., '(lro|ltr|rlo|rtl)')">
              <xsl:attribute name="dir">
                <xsl:value-of select="."/>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="matches(.,
              '(large|medium|small|x-large|x-small|xx-large|xx-small)')">
              <xsl:attribute name="font-size">
                <xsl:value-of select="."/>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="matches(., 'italic')">
              <xsl:attribute name="font-style">
                <xsl:value-of select="."/>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="matches(., 'none')">
              <xsl:attribute name="print-object">
                <xsl:text>no</xsl:text>
              </xsl:attribute>
            </xsl:when>
          </xsl:choose>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:*[ancestor::*[starts-with(local-name(), 'pg')]]/*[not(local-name()='lb'
    or local-name()='rend')]" mode="stage1">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

  <xsl:template match="@label | @label.abbr" mode="partName">
    <xsl:analyze-string select="." regex="(&#x266d;|&#x266f;)">
      <xsl:matching-substring>
        <accidental-text>
          <xsl:value-of select="replace(replace(., '&#x266d;', 'flat'), '&#x266f;', 'sharp')"/>
        </accidental-text>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <display-text>
          <xsl:value-of select="."/>
        </display-text>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>

  <!-- Default template for addTstamp.ges -->
  <xsl:template match="@* | node() | comment()" mode="addTstamp.ges">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="addTstamp.ges"/>
    </xsl:copy>
  </xsl:template>

  <!-- Default template for dropPPQ mode -->
  <xsl:template match="@* | node() | comment()" mode="dropPPQ">
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name()='ppq')]"/>
      <xsl:apply-templates mode="dropPPQ"/>
    </xsl:copy>
  </xsl:template>

  <!-- Default template for stage 1 -->
  <xsl:template match="@* | node() | comment()" mode="stage1">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="stage1"/>
    </xsl:copy>
  </xsl:template>

  <!-- Default template for stage2 -->
  <xsl:template match="@* | node()" mode="stage2">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="stage2"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="measure" mode="stage2">
    <xsl:copy>
      <xsl:attribute name="number">
        <xsl:choose>
          <xsl:when test="@n">
            <xsl:value-of select="@n"/>
          </xsl:when>
          <xsl:when test="preceding::measure[@n]">
            <xsl:variable name="precedingNumberedMeasure">
              <xsl:value-of select="generate-id(preceding::measure[@n][1])"/>
            </xsl:variable>
            <xsl:variable name="interveningMeasures">
              <xsl:value-of
                select="count(preceding::measure[preceding::measure[generate-id()=$precedingNumberedMeasure]])
                + 1"/>
            </xsl:variable>
            <xsl:value-of select="preceding::measure[@n][1]/@n"/>
            <xsl:value-of select="substring('abcdefghijklmnopqrstuvwxyz', $interveningMeasures,
              1)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="count(preceding::measure) + 1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:if test="@width">
        <xsl:attribute name="width">
          <xsl:value-of select="format-number(@width * 5, '###0.####')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@metcon">
        <xsl:attribute name="implicit">
          <xsl:choose>
            <xsl:when test="@metcon='true'">
              <xsl:text>no</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>yes</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="stage2"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="part" mode="stage2">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <!-- left barline -->
      <xsl:choose>
        <xsl:when test="ancestor::measure/@left">
          <barline location="left">
            <xsl:choose>
              <xsl:when test="ancestor::measure/@left='dashed'">
                <bar-style>dashed</bar-style>
              </xsl:when>
              <xsl:when test="ancestor::measure/@left='dotted'">
                <bar-style>dotted</bar-style>
              </xsl:when>
              <xsl:when test="ancestor::measure/@left='dbl'">
                <bar-style>light-light</bar-style>
              </xsl:when>
              <xsl:when test="ancestor::measure/@left='dbldashed'">
                <xsl:comment>MusicXML doesn't support double dashed barlines</xsl:comment>
              </xsl:when>
              <xsl:when test="ancestor::measure/@left='dbldotted'">
                <xsl:comment>MusicXML doesn't support double dotted barlines</xsl:comment>
              </xsl:when>
              <xsl:when test="ancestor::measure/@left='end'">
                <bar-style>light-heavy</bar-style>
              </xsl:when>
              <xsl:when test="ancestor::measure/@left='invis'">
                <bar-style>none</bar-style>
              </xsl:when>
            </xsl:choose>
          </barline>
        </xsl:when>
        <xsl:when test="ancestor::measure/preceding::measure[1][@right='rptstart' or
          @right='rptboth']">
          <barline location="left">
            <xsl:choose>
              <xsl:when test="ancestor::measure/preceding::measure[1]/@right='rptstart'">
                <bar-style>heavy-light</bar-style>
                <repeat direction="forward"/>
              </xsl:when>
              <xsl:when test="ancestor::measure/preceding::measure[1]/@right='rptboth'">
                <bar-style>light-light</bar-style>
                <repeat direction="forward"/>
              </xsl:when>
            </xsl:choose>
          </barline>
        </xsl:when>
      </xsl:choose>

      <xsl:apply-templates mode="stage2"/>

      <!--<xsl:apply-templates select="events/*" mode="stage2"/>
      <xsl:copy-of select="controlevents"/>-->
      <!--<xsl:apply-templates mode="stage2"/>-->

      <!--
        <xsl:apply-templates select="events/*" mode="stage2"/>
        <xsl:apply-templates select="*[local-name() != 'controlevents' and local-name() != 'sb' and
        local-name() != 'scoreDef']" mode="stage2"/>
      -->

      <!-- right barline -->
      <xsl:choose>
        <xsl:when test="ancestor::measure/@right">
          <barline location="right">
            <xsl:choose>
              <xsl:when test="ancestor::measure/@right='dashed'">
                <bar-style>dashed</bar-style>
              </xsl:when>
              <xsl:when test="ancestor::measure/@right='dotted'">
                <bar-style>dotted</bar-style>
              </xsl:when>
              <xsl:when test="ancestor::measure/@right='dbl'">
                <bar-style>light-light</bar-style>
              </xsl:when>
              <xsl:when test="ancestor::measure/@right='dbldashed'">
                <xsl:comment>MusicXML doesn't support double dashed barlines</xsl:comment>
              </xsl:when>
              <xsl:when test="ancestor::measure/@right='dbldotted'">
                <xsl:comment>MusicXML doesn't support double dotted barlines</xsl:comment>
              </xsl:when>
              <xsl:when test="ancestor::measure/@right='end'">
                <bar-style>light-heavy</bar-style>
              </xsl:when>
              <xsl:when test="ancestor::measure/@right='invis'">
                <bar-style>none</bar-style>
              </xsl:when>
              <xsl:when test="ancestor::measure/@right='rptstart'">
                <bar-style>heavy-light</bar-style>
                <repeat direction="forward"/>
              </xsl:when>
              <xsl:when test="ancestor::measure/@right='rptboth'">
                <bar-style>light-heavy</bar-style>
                <repeat direction="backward"/>
              </xsl:when>
              <xsl:when test="ancestor::measure/@right='rptend'">
                <bar-style>light-heavy</bar-style>
                <repeat direction="backward"/>
              </xsl:when>
              <xsl:when test="ancestor::measure/@right='single'">
                <bar-style>regular</bar-style>
              </xsl:when>
            </xsl:choose>
          </barline>
        </xsl:when>
        <xsl:when test="ancestor::measure/following::measure[1][@left='rptend' or @left='rptboth']">
          <xsl:choose>
            <xsl:when test="ancestor::measure/following::measure[1]/@left='rptend'">
              <bar-style>heavy-light</bar-style>
              <repeat direction="backward"/>
            </xsl:when>
            <xsl:when test="ancestor::measure/following::measure[1]/@left='rptboth'">
              <bar-style>light-light</bar-style>
              <repeat direction="backward"/>
            </xsl:when>
          </xsl:choose>
        </xsl:when>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="events" mode="stage2">
    <xsl:apply-templates mode="stage2"/>
  </xsl:template>

  <xsl:template match="part-group" mode="stage2">
    <!-- renumber part-groups sequentially -->
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name()='number')]"/>
      <xsl:choose>
        <xsl:when test="@type='start'">
          <xsl:attribute name="number">
            <xsl:value-of select="count(preceding::part-group[@type='start']) + 1"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="@type='stop'">
          <xsl:variable name="thisNumber">
            <xsl:value-of select="@number"/>
          </xsl:variable>
          <xsl:attribute name="number">
            <xsl:for-each select="preceding::part-group[@number=$thisNumber and @type='start'][1]">
              <xsl:value-of select="count(preceding::part-group[@type='start']) + 1"/>
            </xsl:for-each>
          </xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates mode="stage2"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:beam | mei:chord | mei:tuplet" mode="stage2">
    <xsl:apply-templates mode="stage2"/>
  </xsl:template>

  <xsl:template match="mei:clef" mode="stage2">
    <attributes>
      <clef>
        <xsl:attribute name="number">
          <xsl:value-of select="@partStaff"/>
        </xsl:attribute>
        <sign>
          <xsl:value-of select="@shape"/>
        </sign>
        <line>
          <xsl:value-of select="@line"/>
        </line>
      </clef>
    </attributes>
  </xsl:template>

  <xsl:template match="mei:mRest | mei:mSpace | mei:rest | mei:space" mode="stage2">
    <xsl:variable name="noteIDref">
      <xsl:value-of select="concat('#',@xml:id)"/>
    </xsl:variable>
    <xsl:variable name="thisTstamp.ges">
      <xsl:choose>
        <xsl:when test="@tstamp.ges">
          <xsl:value-of select="@tstamp.ges"/>
        </xsl:when>
        <xsl:when test="../@stamp.ges">
          <xsl:value-of select="../@tstamp.ges"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="prevTstamp.ges">
      <xsl:choose>
        <xsl:when test="preceding-sibling::mei:*[not(preceding-sibling::backup) and @tstamp]">
          <xsl:value-of select="preceding-sibling::mei:*[not(preceding-sibling::backup) and
            @tstamp][1]/@tstamp"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="0"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <note xmlns="">

      <!-- DEBUG: -->
      <!--<xsl:copy-of select="@*"/>-->

      <xsl:if test="local-name()='space' or local-name()='mSpace'">
        <xsl:attribute name="print-object">
          <xsl:text>no</xsl:text>
        </xsl:attribute>
      </xsl:if>
      <rest>
        <xsl:if test="@ploc">
          <display-step>
            <xsl:value-of select="upper-case(@ploc)"/>
          </display-step>
        </xsl:if>
        <xsl:if test="@oloc">
          <display-octave>
            <xsl:value-of select="@oloc"/>
          </display-octave>
        </xsl:if>
      </rest>
      <xsl:choose>
        <xsl:when test="@dur.ges = 0">
          <!-- This is a grace note that has no explicit performed duration -->
        </xsl:when>
        <xsl:when test="@dur.ges">
          <duration>
            <xsl:value-of select="@dur.ges"/>
          </duration>
        </xsl:when>
        <xsl:when test="ancestor::mei:*[@dur.ges]">
          <duration>
            <xsl:value-of select="ancestor::mei:*[@dur.ges][1]/@dur.ges"/>
          </duration>
        </xsl:when>
      </xsl:choose>
      <voice>
        <xsl:choose>
          <xsl:when test="@voice">
            <xsl:value-of select="@voice"/>
          </xsl:when>
          <xsl:when test="ancestor::mei:*[@voice]">
            <xsl:value-of select="ancestor::mei:*[@voice][1]/@voice"/>
          </xsl:when>
        </xsl:choose>
      </voice>
      <xsl:if test="@dur or ancestor::mei:*[@dur]">
        <type>
          <xsl:choose>
            <xsl:when test="@dur">
              <xsl:choose>
                <xsl:when test="@dur='breve' or @dur='long' or @dur='maxima'">
                  <xsl:value-of select="@dur"/>
                </xsl:when>
                <xsl:when test="@dur='1'">
                  <xsl:text>whole</xsl:text>
                </xsl:when>
                <xsl:when test="@dur='2'">
                  <xsl:text>half</xsl:text>
                </xsl:when>
                <xsl:when test="@dur='4'">
                  <xsl:text>quarter</xsl:text>
                </xsl:when>
                <xsl:when test="@dur='8'">
                  <xsl:text>eighth</xsl:text>
                </xsl:when>
                <xsl:when test="@dur='16' or @dur='32' or @dur='64' or @dur='128' or @dur='256' or
                  @dur='512' or @dur='1024'">
                  <xsl:value-of select="@dur"/>
                  <xsl:text>th</xsl:text>
                </xsl:when>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="ancestor::mei:*[@dur]">
              <xsl:choose>
                <xsl:when test="ancestor::mei:*[@dur][1]/@dur='breve' or
                  ancestor::mei:*[@dur][1]/@dur='long' or ancestor::mei:*[@dur][1]/@dur='maxima'">
                  <xsl:value-of select="ancestor::mei:*[@dur][1]/@dur"/>
                </xsl:when>
                <xsl:when test="ancestor::mei:*[@dur][1]/@dur='1'">
                  <xsl:text>whole</xsl:text>
                </xsl:when>
                <xsl:when test="ancestor::mei:*[@dur][1]/@dur='2'">
                  <xsl:text>half</xsl:text>
                </xsl:when>
                <xsl:when test="ancestor::mei:*[@dur][1]/@dur='4'">
                  <xsl:text>quarter</xsl:text>
                </xsl:when>
                <xsl:when test="ancestor::mei:*[@dur][1]/@dur='8'">
                  <xsl:text>eighth</xsl:text>
                </xsl:when>
                <xsl:when test="ancestor::mei:*[@dur][1]/@dur='16' or
                  ancestor::mei:*[@dur][1]/@dur='32' or ancestor::mei:*[@dur][1]/@dur='64' or
                  ancestor::mei:*[@dur][1]/@dur='128' or ancestor::mei:*[@dur][1]/@dur='256' or
                  ancestor::mei:*[@dur][1]/@dur='512' or ancestor::mei:*[@dur][1]/@dur='1024'">
                  <xsl:value-of select="ancestor::mei:*[@dur][1]/@dur"/>
                  <xsl:text>th</xsl:text>
                </xsl:when>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="@dur.ges">
              <!-- Map @dur.ges to written value? -->
            </xsl:when>
          </xsl:choose>
        </type>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@dots">
          <xsl:for-each select="1 to @dots">
            <dot/>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="ancestor::mei:*[@dots]">
          <xsl:for-each select="1 to ancestor::mei:*[@dots][1]/@dots">
            <dot/>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
      <staff>
        <xsl:choose>
          <xsl:when test="@partStaff">
            <xsl:value-of select="@partStaff"/>
          </xsl:when>
          <xsl:when test="ancestor::mei:*[@partStaff]">
            <xsl:value-of select="ancestor::mei:*[@partStaff][1]/@partStaff"/>
          </xsl:when>
        </xsl:choose>
      </staff>
    </note>
  </xsl:template>

  <xsl:template match="mei:dynam" mode="stage2">
    <direction xmlns="">
      <xsl:if test="@place">
        <xsl:attribute name="placement">
          <xsl:value-of select="@place"/>
        </xsl:attribute>
      </xsl:if>
      <direction-type>
        <xsl:variable name="dynamValue">
          <xsl:value-of select="."/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="matches($dynamValue, 'cresc|decresc|diminuendo|dim\.')">
            <xsl:for-each select="mei:rend | text()">
              <words>
                <xsl:choose>
                  <!-- rend element -->
                  <xsl:when test="local-name()='rend'">
                    <xsl:call-template name="rendition"/>
                    <xsl:value-of select="$dynamValue"/>
                  </xsl:when>
                  <!-- text node -->
                  <xsl:when test="name()=''">
                    <xsl:value-of select="$dynamValue"/>
                  </xsl:when>
                </xsl:choose>
              </words>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <dynamics>
              <xsl:choose>
                <xsl:when test="matches($dynamValue,
                  '^p+$|^f+|^mp$|^mf$|^sfp*$|^f(p|z)$|^rfz*$|^sfz$|^sffz$')">
                  <xsl:for-each select="mei:rend | text()">
                    <xsl:choose>
                      <!-- rend element -->
                      <xsl:when test="local-name()='rend'">
                        <xsl:call-template name="rendition"/>
                        <xsl:element name="{$dynamValue}"/>
                      </xsl:when>
                      <!-- text node -->
                      <xsl:when test="name()=''">
                        <xsl:element name="{$dynamValue}"/>
                      </xsl:when>
                    </xsl:choose>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <other-dynamics>
                    <xsl:value-of select="normalize-space(.)"/>
                  </other-dynamics>
                </xsl:otherwise>
              </xsl:choose>
            </dynamics>
          </xsl:otherwise>
        </xsl:choose>
      </direction-type>
      <staff>
        <xsl:value-of select="@partStaff"/>
      </staff>
      <xsl:if test="@val">
        <sound>
          <xsl:attribute name="dynamics">
            <xsl:value-of select="ceiling(number(@val) + (number(@val) * .10))"/>
          </xsl:attribute>
        </sound>
      </xsl:if>
    </direction>
  </xsl:template>

  <xsl:template match="mei:dir | mei:tempo" mode="stage2">
    <direction xmlns="">
      <xsl:if test="@place">
        <xsl:attribute name="placement">
          <xsl:value-of select="@place"/>
        </xsl:attribute>
      </xsl:if>
      <direction-type>
        <xsl:for-each select="mei:rend | text()">
          <words>
            <xsl:choose>
              <!-- rend element -->
              <xsl:when test="local-name()='rend'">
                <xsl:call-template name="rendition"/>
                <xsl:value-of select="."/>
              </xsl:when>
              <!-- text node -->
              <xsl:when test="name()=''">
                <xsl:copy-of select="."/>
              </xsl:when>
            </xsl:choose>
          </words>
        </xsl:for-each>
      </direction-type>
      <staff>
        <xsl:value-of select="@partStaff"/>
      </staff>
      <xsl:if test="@midi.tempo">
        <sound>
          <xsl:attribute name="tempo">
            <xsl:value-of select="@midi.tempo"/>
          </xsl:attribute>
        </sound>
      </xsl:if>
    </direction>
  </xsl:template>

  <xsl:template match="mei:note" mode="stage2">
    <xsl:variable name="noteIDref">
      <xsl:value-of select="concat('#',@xml:id)"/>
    </xsl:variable>
    <xsl:variable name="thisTstamp.ges">
      <xsl:choose>
        <xsl:when test="@tstamp.ges">
          <xsl:value-of select="@tstamp.ges"/>
        </xsl:when>
        <xsl:when test="../@stamp.ges">
          <xsl:value-of select="../@tstamp.ges"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="prevTstamp.ges">
      <xsl:choose>
        <xsl:when test="preceding-sibling::mei:*[not(preceding-sibling::backup) and @tstamp]">
          <xsl:value-of select="preceding-sibling::mei:*[not(preceding-sibling::backup) and
            @tstamp][1]/@tstamp"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="0"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!--<xsl:copy-of select="ancestor::measure/part/controlevents/mei:*[@tstamp.ges &gt; $prevTstamp.ges
      and @tstamp.ges &lt;=$thisTstamp.ges]"/>-->

    <!--<xsl:apply-templates select="ancestor::measure/part/controlevents/mei:dynam[@label != 'notation'
      and @startid=$noteIDref] | ancestor::measure/part/controlevents/mei:tempo[@startid=$noteIDref]" mode="stage2.dir"/>
-->
    <note xmlns="">

      <!-- DEBUG: -->
      <!--<xsl:copy-of select="@*"/>-->

      <!-- DEBUG: -->
      <!--<xsl:if test="ancestor::mei:chord">
        <xsl:copy-of select="ancestor::mei:chord/@*[not(local-name() = 'id')]"/>
      </xsl:if>-->

      <xsl:if test="ancestor::mei:chord and preceding-sibling::mei:note">
        <chord/>
      </xsl:if>
      <xsl:if test="@grace">
        <grace>
          <xsl:if test="matches(@stem.mod, 'slash')">
            <xsl:attribute name="slash">
              <xsl:text>yes</xsl:text>
            </xsl:attribute>
          </xsl:if>
        </grace>
      </xsl:if>
      <pitch>
        <step>
          <xsl:value-of select="upper-case(@pname)"/>
        </step>
        <xsl:if test="@accid.ges">
          <alter>
            <xsl:choose>
              <xsl:when test="@accid.ges = 'f'">
                <xsl:text>-1</xsl:text>
              </xsl:when>
              <xsl:when test="@accid.ges = 's'">
                <xsl:text>1</xsl:text>
              </xsl:when>
            </xsl:choose>
          </alter>
        </xsl:if>
        <octave>
          <xsl:choose>
            <xsl:when test="@oct.ges">
              <xsl:value-of select="@oct.ges"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@oct"/>
            </xsl:otherwise>
          </xsl:choose>
        </octave>
      </pitch>
      <xsl:choose>
        <xsl:when test="@dur.ges = 0">
          <!-- This is a grace note that has no explicit performed duration -->
        </xsl:when>
        <xsl:when test="@dur.ges">
          <duration>
            <xsl:value-of select="@dur.ges"/>
          </duration>
        </xsl:when>
        <xsl:when test="ancestor::mei:*[@dur.ges]">
          <duration>
            <xsl:value-of select="ancestor::mei:*[@dur.ges][1]/@dur.ges"/>
          </duration>
        </xsl:when>
      </xsl:choose>
      <voice>
        <xsl:choose>
          <xsl:when test="@voice">
            <xsl:value-of select="@voice"/>
          </xsl:when>
          <xsl:when test="ancestor::mei:*[@voice]">
            <xsl:value-of select="ancestor::mei:*[@voice][1]/@voice"/>
          </xsl:when>
        </xsl:choose>
      </voice>
      <xsl:if test="@dur or ancestor::mei:*[@dur]">
        <type>
          <xsl:choose>
            <xsl:when test="@dur">
              <xsl:choose>
                <xsl:when test="@dur='breve' or @dur='long' or @dur='maxima'">
                  <xsl:value-of select="@dur"/>
                </xsl:when>
                <xsl:when test="@dur='1'">
                  <xsl:text>whole</xsl:text>
                </xsl:when>
                <xsl:when test="@dur='2'">
                  <xsl:text>half</xsl:text>
                </xsl:when>
                <xsl:when test="@dur='4'">
                  <xsl:text>quarter</xsl:text>
                </xsl:when>
                <xsl:when test="@dur='8'">
                  <xsl:text>eighth</xsl:text>
                </xsl:when>
                <xsl:when test="@dur='16' or @dur='32' or @dur='64' or @dur='128' or @dur='256' or
                  @dur='512' or @dur='1024'">
                  <xsl:value-of select="@dur"/>
                  <xsl:text>th</xsl:text>
                </xsl:when>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="ancestor::mei:*[@dur]">
              <xsl:choose>
                <xsl:when test="ancestor::mei:*[@dur][1]/@dur='breve' or
                  ancestor::mei:*[@dur][1]/@dur='long' or ancestor::mei:*[@dur][1]/@dur='maxima'">
                  <xsl:value-of select="ancestor::mei:*[@dur][1]/@dur"/>
                </xsl:when>
                <xsl:when test="ancestor::mei:*[@dur][1]/@dur='1'">
                  <xsl:text>whole</xsl:text>
                </xsl:when>
                <xsl:when test="ancestor::mei:*[@dur][1]/@dur='2'">
                  <xsl:text>half</xsl:text>
                </xsl:when>
                <xsl:when test="ancestor::mei:*[@dur][1]/@dur='4'">
                  <xsl:text>quarter</xsl:text>
                </xsl:when>
                <xsl:when test="ancestor::mei:*[@dur][1]/@dur='8'">
                  <xsl:text>eighth</xsl:text>
                </xsl:when>
                <xsl:when test="ancestor::mei:*[@dur][1]/@dur='16' or
                  ancestor::mei:*[@dur][1]/@dur='32' or ancestor::mei:*[@dur][1]/@dur='64' or
                  ancestor::mei:*[@dur][1]/@dur='128' or ancestor::mei:*[@dur][1]/@dur='256' or
                  ancestor::mei:*[@dur][1]/@dur='512' or ancestor::mei:*[@dur][1]/@dur='1024'">
                  <xsl:value-of select="ancestor::mei:*[@dur][1]/@dur"/>
                  <xsl:text>th</xsl:text>
                </xsl:when>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="@dur.ges">
              <!-- Map @dur.ges to written value? -->
            </xsl:when>
          </xsl:choose>
        </type>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@dots">
          <xsl:for-each select="1 to @dots">
            <dot/>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="ancestor::mei:*[@dots]">
          <xsl:for-each select="1 to ancestor::mei:*[@dots][1]/@dots">
            <dot/>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
      <xsl:if test="@accid">
        <accidental>
          <xsl:choose>
            <xsl:when test="@accid='f'">
              <xsl:text>flat</xsl:text>
            </xsl:when>
            <xsl:when test="@accid='s'">
              <xsl:text>sharp</xsl:text>
            </xsl:when>
            <xsl:when test="@accid='n'">
              <xsl:text>natural</xsl:text>
            </xsl:when>
          </xsl:choose>
        </accidental>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@stem.dir">
          <stem>
            <xsl:value-of select="@stem.dir"/>
          </stem>
        </xsl:when>
        <xsl:when test="ancestor::mei:*[@stem.dir]">
          <stem>
            <xsl:value-of select="ancestor::mei:*[@stem.dir][1]/@stem.dir"/>
          </stem>
        </xsl:when>
      </xsl:choose>
      <staff>
        <xsl:choose>
          <xsl:when test="@partStaff">
            <xsl:value-of select="@partStaff"/>
          </xsl:when>
          <xsl:when test="ancestor::mei:*[@partStaff]">
            <xsl:value-of select="ancestor::mei:*[@partStaff][1]/@partStaff"/>
          </xsl:when>
        </xsl:choose>
      </staff>

      <!-- So-called "notations" attached to individual notes -->
      <!-- Processing MEI control events into MusicXML notations requires checking the
      control event's startid (and sometimes endid) against the current event ID. -->
      <xsl:variable name="thisEventID">
        <xsl:value-of select="@xml:id"/>
      </xsl:variable>

      <!-- The following variables, e.g., $accidentalMarks, $arpeggiation, etc., 
      collect MusicXML elements. Later, if found not to be empty, their contents
      are copied to <notations> sub-elements. -->

      <!-- Editorial and cautionary accidentals -->
      <xsl:variable name="accidentalMarks">
        <xsl:for-each select="mei:accid[@place='above' or @place='below' or @func='edit' or
          @func='caution']">
          <accidental-mark>
            <xsl:if test="@place">
              <xsl:attribute name="placement">
                <xsl:value-of select="@place"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="@accid='s'">
                <xsl:text>sharp</xsl:text>
              </xsl:when>
              <xsl:when test="@accid='n'">
                <xsl:text>natural</xsl:text>
              </xsl:when>
              <xsl:when test="@accid='f'">
                <xsl:text>flat</xsl:text>
              </xsl:when>
              <xsl:when test="@accid='x'">
                <xsl:text>double-sharp</xsl:text>
              </xsl:when>
              <xsl:when test="@accid='ff'">
                <xsl:text>double-flat</xsl:text>
              </xsl:when>
              <xsl:when test="@accid='ss'">
                <xsl:text>sharp-sharp</xsl:text>
              </xsl:when>
              <xsl:when test="@accid='ns'">
                <xsl:text>natural-sharp</xsl:text>
              </xsl:when>
              <xsl:when test="@accid='nf'">
                <xsl:text>natural-flat</xsl:text>
              </xsl:when>
              <xsl:when test="@accid='fd'">
                <xsl:text>flat-down</xsl:text>
              </xsl:when>
              <xsl:when test="@accid='fu'">
                <xsl:text>flat-up</xsl:text>
              </xsl:when>
              <xsl:when test="@accid='nd'">
                <xsl:text>natural-down</xsl:text>
              </xsl:when>
              <xsl:when test="@accid='nu'">
                <xsl:text>natural-up</xsl:text>
              </xsl:when>
              <xsl:when test="@accid='sd'">
                <xsl:text>sharp-down</xsl:text>
              </xsl:when>
              <xsl:when test="@accid='su'">
                <xsl:text>sharp-up</xsl:text>
              </xsl:when>
              <xsl:when test="@accid='ts'">
                <xsl:text>triple-sharp</xsl:text>
              </xsl:when>
              <xsl:when test="@accid='tf'">
                <xsl:text>triple-flat</xsl:text>
              </xsl:when>
            </xsl:choose>
          </accidental-mark>
        </xsl:for-each>
      </xsl:variable>

      <!-- Arpeggiation in MEI is a control event. -->
      <xsl:variable name="arpeggiation">
        <xsl:for-each select="following::controlevents/mei:arpeg[not(@order='nonarp')]">
          <xsl:analyze-string select="@plist" regex="\s+">
            <xsl:non-matching-substring>
              <xsl:if test="substring(.,2)=$thisEventID">
                <arpeggiate/>
              </xsl:if>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:for-each>
        <xsl:for-each select="following::controlevents/mei:arpeg[@order='nonarp']">
          <xsl:variable name="firstNoteID">
            <xsl:value-of select="substring(replace(@plist,'^([^\s]+)\s+.*', '$1'), 2)"/>
          </xsl:variable>
          <xsl:variable name="lastNoteID">
            <xsl:value-of select="substring(replace(@plist,'^.*\s+([^\s]+)$','$1'), 2)"/>
          </xsl:variable>
          <xsl:if test="matches($thisEventID, $firstNoteID) or matches($thisEventID, $lastNoteID)">
            <non-arpeggiate>
              <xsl:attribute name="type">
                <xsl:choose>
                  <xsl:when test="matches($thisEventID, $firstNoteID)">
                    <xsl:text>bottom</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches($thisEventID, $lastNoteID)">
                    <xsl:text>top</xsl:text>
                  </xsl:when>
                </xsl:choose>
              </xsl:attribute>
            </non-arpeggiate>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>

      <!-- Articulations -->
      <xsl:variable name="articulations">
        <xsl:for-each select="mei:artic[@artic] | ancestor::mei:chord/mei:artic[@artic]">
          <xsl:variable name="articPlace">
            <xsl:value-of select="@place"/>
          </xsl:variable>
          <xsl:analyze-string select="@artic" regex="\s+">
            <xsl:non-matching-substring>
              <xsl:variable name="articElement">
                <xsl:choose>
                  <xsl:when test="matches(., '^acc$')">
                    <xsl:text>accent</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^doit$')">
                    <xsl:text>doit</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^fall$')">
                    <xsl:text>falloff</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^marc$')">
                    <xsl:text>strong-accent</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^plop$')">
                    <xsl:text>plop</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^rip$')">
                    <xsl:text>scoop</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^spicc$')">
                    <xsl:text>spiccato</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^stacc$')">
                    <xsl:text>staccato</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^stacciss$')">
                    <xsl:text>staccatissimo</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^ten$')">
                    <xsl:text>tenuto</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^ten-stacc$')">
                    <xsl:text>detached-legato</xsl:text>
                  </xsl:when>
                </xsl:choose>
              </xsl:variable>
              <xsl:if test="$articElement != ''">
                <xsl:element name="{$articElement}">
                  <xsl:if test="($articPlace != '')">
                    <xsl:attribute name="placement">
                      <xsl:value-of select="$articPlace"/>
                    </xsl:attribute>
                  </xsl:if>
                </xsl:element>
              </xsl:if>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:for-each>

        <!-- Some MusicXML "articulations" are MEI control events. -->
        <xsl:for-each
          select="//controlevents/mei:dir[substring(@startid,2)=$thisEventID][@label='breath-mark'
          or @label='caesura' or @label='stress' or @label='unstress']">
          <xsl:variable name="articPlace">
            <xsl:value-of select="@place"/>
          </xsl:variable>
          <xsl:variable name="articElement">
            <xsl:value-of select="@label"/>
          </xsl:variable>
          <xsl:if test="$articElement != ''">
            <xsl:element name="{$articElement}">
              <xsl:if test="($articPlace != '')">
                <xsl:attribute name="placement">
                  <xsl:value-of select="$articPlace"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:if test="$articElement='breath-mark'">
                <xsl:choose>
                  <xsl:when test="matches(., &quot;&apos;&quot;)">
                    <xsl:text>tick</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., ',')">
                    <xsl:text>comma</xsl:text>
                  </xsl:when>
                </xsl:choose>
              </xsl:if>
            </xsl:element>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>

      <!-- Fermatas are control events in MEI. -->
      <xsl:variable name="fermatas">
        <xsl:for-each select="//controlevents/mei:fermata[substring(@startid,2)=$thisEventID]">
          <fermata>
            <xsl:attribute name="type">
              <xsl:choose>
                <xsl:when test="@form = 'inv'">
                  <xsl:text>inverted</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>upright</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:choose>
              <xsl:when test="@shape = 'square'">
                <xsl:text>square</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>normal</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </fermata>
        </xsl:for-each>
      </xsl:variable>

      <!-- Ornaments are control events in MEI. -->
      <xsl:variable name="ornaments">
        <xsl:for-each select="//controlevents/mei:*[local-name()='mordent' or
          local-name()='trill' or local-name()='turn'][substring(@startid,2)=$thisEventID] |
          //controlevents/mei:dir[@label='shake' or
          @label='schleifer'][substring(@startid,2)=$thisEventID]">
          <xsl:variable name="ornamPlace">
            <xsl:value-of select="@place"/>
          </xsl:variable>
          <xsl:variable name="ornamElement">
            <xsl:choose>
              <xsl:when test="local-name()='dir'">
                <xsl:value-of select="@label"/>
              </xsl:when>
              <xsl:when test="local-name()='mordent'">
                <xsl:choose>
                  <xsl:when test="@form='inv' and @label='shake'">
                    <xsl:text>shake</xsl:text>
                  </xsl:when>
                  <xsl:when test="@form='inv'">
                    <xsl:text>inverted-mordent</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="local-name()"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="local-name()='trill'">
                <xsl:text>trill-mark</xsl:text>
              </xsl:when>
              <xsl:when test="local-name()='turn'">
                <xsl:choose>
                  <xsl:when test="@form='inv' and @delayed='true'">
                    <xsl:text>delayed-inverted-turn</xsl:text>
                  </xsl:when>
                  <xsl:when test="@form='inv'">
                    <xsl:text>inverted-turn</xsl:text>
                  </xsl:when>
                  <xsl:when test="@delayed='true'">
                    <xsl:text>delayed-turn</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>turn</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
            </xsl:choose>
          </xsl:variable>
          <xsl:if test="$ornamElement != ''">
            <xsl:element name="{$ornamElement}">
              <xsl:if test="($ornamPlace != '')">
                <xsl:attribute name="placement">
                  <xsl:value-of select="$ornamPlace"/>
                </xsl:attribute>
              </xsl:if>
            </xsl:element>
            <!-- Accidentals attached to ornament -->
            <xsl:if test="@accidupper">
              <accidental-mark>
                <xsl:attribute name="placement">
                  <xsl:text>above</xsl:text>
                </xsl:attribute>
                <xsl:analyze-string select="@accidupper" regex="\s+">
                  <xsl:non-matching-substring>
                    <xsl:choose>
                      <xsl:when test="normalize-space(.) = 's'">
                        <xsl:text>sharp</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'n'">
                        <xsl:text>natural</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'f'">
                        <xsl:text>flat</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'x'">
                        <xsl:text>double-sharp</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'ff'">
                        <xsl:text>double-flat</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'ss'">
                        <xsl:text>sharp-sharp</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'ff'">
                        <xsl:text>flat-flat</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'ns'">
                        <xsl:text>natural-sharp</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'nf'">
                        <xsl:text>natural-flat</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'fd'">
                        <xsl:text>flat-down</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'fu'">
                        <xsl:text>flat-up</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'nd'">
                        <xsl:text>natural-down</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'nu'">
                        <xsl:text>natural-up</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'sd'">
                        <xsl:text>sharp-down</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'su'">
                        <xsl:text>sharp-up</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'ts'">
                        <xsl:text>triple-sharp</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'tf'">
                        <xsl:text>triple-flat</xsl:text>
                      </xsl:when>
                    </xsl:choose>
                  </xsl:non-matching-substring>
                </xsl:analyze-string>
              </accidental-mark>
            </xsl:if>
            <xsl:if test="@accidlower">
              <accidental-mark>
                <xsl:attribute name="placement">
                  <xsl:text>below</xsl:text>
                </xsl:attribute>
                <xsl:analyze-string select="@accidlower" regex="\s+">
                  <xsl:non-matching-substring>
                    <xsl:choose>
                      <xsl:when test="normalize-space(.) = 's'">
                        <xsl:text>sharp</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'n'">
                        <xsl:text>natural</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'f'">
                        <xsl:text>flat</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'x'">
                        <xsl:text>double-sharp</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'ff'">
                        <xsl:text>double-flat</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'ss'">
                        <xsl:text>sharp-sharp</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'ff'">
                        <xsl:text>flat-flat</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'ns'">
                        <xsl:text>natural-sharp</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'nf'">
                        <xsl:text>natural-flat</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'fd'">
                        <xsl:text>flat-down</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'fu'">
                        <xsl:text>flat-up</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'nd'">
                        <xsl:text>natural-down</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'nu'">
                        <xsl:text>natural-up</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'sd'">
                        <xsl:text>sharp-down</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'su'">
                        <xsl:text>sharp-up</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'ts'">
                        <xsl:text>triple-sharp</xsl:text>
                      </xsl:when>
                      <xsl:when test="normalize-space(.) = 'tf'">
                        <xsl:text>triple-flat</xsl:text>
                      </xsl:when>
                    </xsl:choose>
                  </xsl:non-matching-substring>
                </xsl:analyze-string>
              </accidental-mark>
            </xsl:if>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>

      <!-- Technical/performance indications -->
      <xsl:variable name="technical">
        <!-- Some indications are MEI articulations. -->
        <xsl:for-each select="mei:artic[@artic]">
          <xsl:variable name="techPlace">
            <xsl:value-of select="@place"/>
          </xsl:variable>
          <xsl:analyze-string select="@artic" regex="\s+">
            <xsl:non-matching-substring>
              <xsl:variable name="techElement">
                <xsl:choose>
                  <!-- technical -->
                  <xsl:when test="matches(., '^bend$')">
                    <xsl:text>bend</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^dbltongue$')">
                    <xsl:text>double-tongue</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^dnbow$')">
                    <xsl:text>down-bow</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^fingernail$')">
                    <xsl:text>fingernails</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^harm$')">
                    <xsl:text>harmonic</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^heel$')">
                    <xsl:text>heel</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^open$')">
                    <xsl:text>open-string</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^snap$')">
                    <xsl:text>snap-pizzicato</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^stop$')">
                    <xsl:text>stopped</xsl:text>
                  </xsl:when>
                  <!-- tap is recorded in a directive -->
                  <xsl:when test="matches(., '^toe$')">
                    <xsl:text>toe</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^trpltongue$')">
                    <xsl:text>triple-tongue</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., '^upbow$')">
                    <xsl:text>up-bow</xsl:text>
                  </xsl:when>
                </xsl:choose>
              </xsl:variable>
              <xsl:if test="$techElement != ''">
                <xsl:element name="{$techElement}">
                  <xsl:if test="($techPlace != '')">
                    <xsl:attribute name="placement">
                      <xsl:value-of select="$techPlace"/>
                    </xsl:attribute>
                  </xsl:if>
                </xsl:element>
              </xsl:if>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:for-each>

        <!-- String tablature is recorded in event attributes. -->
        <xsl:if test="@tab.string">
          <string>
            <xsl:value-of select="@tab.string"/>
          </string>
        </xsl:if>
        <xsl:if test="@tab.fret">
          <fret>
            <xsl:choose>
              <xsl:when test="@tab.fret='o'">
                <xsl:text>0</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@tab.fret"/>
              </xsl:otherwise>
            </xsl:choose>
          </fret>
        </xsl:if>

        <!-- Other indications are MEI directives. -->
        <xsl:for-each select="//controlevents/mei:dir[@label='pluck' or
          @label='tap'][substring(@startid,2)=$thisEventID]">
          <xsl:variable name="techPlace">
            <xsl:value-of select="@place"/>
          </xsl:variable>
          <xsl:variable name="techElement">
            <xsl:value-of select="@label"/>
          </xsl:variable>
          <xsl:if test="$techElement != ''">
            <xsl:element name="{$techElement}">
              <xsl:if test="($techPlace != '')">
                <xsl:attribute name="placement">
                  <xsl:value-of select="$techPlace"/>
                </xsl:attribute>
              </xsl:if>
              <!-- Copy content of directive -->
              <xsl:copy-of select="node()"/>
            </xsl:element>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>

      <!-- Dynamics and hammer-on and pull-off indications can potentially 
          cross measure boundaries, so must be "passed through" for processing
          later -->

      <!--<xsl:variable name="dynamics">
          <xsl:for-each select="//controlevents/mei:dynam[substring(@startid,2)=$thisEventID]">
            <xsl:variable name="dynamPlace">
              <xsl:value-of select="@place"/>
            </xsl:variable>
            <xsl:variable name="dynamElement">
              <xsl:choose>
                <xsl:when test="matches(normalize-space(.),
                  '^(p|f){1,5}$|^m(f|p)$|^sf(p{1,2})?$|^sf{1,2}z$|^rfz?$|^fz$')">
                  <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>other-dynamics</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:if test="$dynamElement != ''">
              <xsl:element name="{$dynamElement}">
                <xsl:if test="($dynamPlace != '')">
                  <xsl:attribute name="placement">
                    <xsl:value-of select="$dynamPlace"/>
                  </xsl:attribute>
                </xsl:if>
                <!-\\- Copy directive content -\\->
                <xsl:if test="$dynamElement = 'other-dynamics'">
                  <xsl:value-of select="normalize-space(.)"/>
                </xsl:if>
              </xsl:element>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable> -->

      <!-- <xsl:for-each select="//controlevents/mei:dir[@label='hammer-on' or
          @label='pull-off'][substring(@startid,2)=$thisEventID]">
          <xsl:variable name="techPlace">
            <xsl:value-of select="@place"/>
          </xsl:variable>
          <xsl:variable name="techElement">
            <xsl:value-of select="@label"/>
          </xsl:variable>
          <xsl:if test="$techElement != ''">
            <xsl:element name="{$techElement}">
              <xsl:if test="($techPlace != '')">
                <xsl:attribute name="placement">
                  <xsl:value-of select="$techPlace"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:attribute name="type">
                <xsl:text>start</xsl:text>
              </xsl:attribute>
              <!-\\- Copy content of directive to start marker -\\->
              <xsl:copy-of select="node()"/>
            </xsl:element>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="//controlevents/mei:dir[@label='hammer-on' or
          @label='pull-off'][substring(@endid,2)=$thisEventID]">
          <xsl:variable name="techPlace">
            <xsl:value-of select="@place"/>
          </xsl:variable>
          <xsl:variable name="techElement">
            <xsl:value-of select="@label"/>
          </xsl:variable>
          <xsl:if test="$techElement != ''">
            <xsl:element name="{$techElement}">
              <xsl:if test="($techPlace != '')">
                <xsl:attribute name="placement">
                  <xsl:value-of select="$techPlace"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:attribute name="type">
                <xsl:text>stop</xsl:text>
              </xsl:attribute>
            </xsl:element>
          </xsl:if>
        </xsl:for-each> -->

      <!-- If any of the preceding variables aren't empty, create a <notations> element
      and fill it with appropriate content. -->
      <xsl:if test="$accidentalMarks/* or $arpeggiation/* or $articulations/* or $fermatas/*
        or $ornaments/* or $technical/*">
        <notations>
          <xsl:if test="$accidentalMarks/*">
            <xsl:copy-of select="$accidentalMarks/*"/>
          </xsl:if>
          <xsl:if test="$arpeggiation/*">
            <xsl:copy-of select="$arpeggiation/*"/>
          </xsl:if>
          <xsl:if test="$articulations/*">
            <articulations>
              <xsl:copy-of select="$articulations/*"/>
            </articulations>
          </xsl:if>
          <!--<xsl:if test="$dynamics/*">
            <xsl:for-each select="$dynamics/*">
              <dynamics>
                <xsl:copy-of select="@*"/>
                <xsl:variable name="elementName">
                  <xsl:value-of select="local-name()"/>
                </xsl:variable>
                <xsl:element name="{$elementName}">
                  <xsl:copy-of select="node()"/>
                </xsl:element>
              </dynamics>
            </xsl:for-each>
          </xsl:if>-->
          <xsl:if test="$fermatas/*">
            <xsl:copy-of select="$fermatas/*"/>
          </xsl:if>
          <xsl:if test="$ornaments/*">
            <ornaments>
              <!-- In MusicXML ornaments, e.g., trill, don't allow content so copy
              comments into parent <ornaments> element. -->
              <xsl:for-each select="//controlevents/mei:*[local-name()='mordent' or
                local-name()='trill' or local-name()='turn'][substring(@startid,2)=$thisEventID] |
                //controlevents/mei:dir[@label='shake' or
                @label='schleifer'][substring(@startid,2)=$thisEventID]">
                <xsl:copy-of select="comment()"/>
              </xsl:for-each>
              <xsl:copy-of select="$ornaments/*"/>
            </ornaments>
          </xsl:if>
          <xsl:if test="$technical/*">
            <technical>
              <xsl:copy-of select="$technical/*"/>
            </technical>
          </xsl:if>
        </notations>
      </xsl:if>

      <xsl:for-each select="mei:verse">
        <lyric>
          <xsl:attribute name="number">
            <xsl:choose>
              <xsl:when test="@n">
                <xsl:value-of select="@n"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>1</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <syllabic>
            <xsl:choose>
              <xsl:when test="mei:syl/@wordpos='i'">
                <xsl:text>begin</xsl:text>
              </xsl:when>
              <xsl:when test="mei:syl/@wordpos='m'">
                <xsl:text>middle</xsl:text>
              </xsl:when>
              <xsl:when test="mei:syl/@wordpos='t'">
                <xsl:text>end</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>single</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </syllabic>
          <xsl:for-each select="mei:syl">
            <text>
              <xsl:value-of select="."/>
            </text>
          </xsl:for-each>
        </lyric>
      </xsl:for-each>
    </note>
  </xsl:template>

  <xsl:template match="mei:pedal" mode="stage2">
    <direction xmlns="">
      <xsl:if test="@place">
        <xsl:attribute name="placement">
          <xsl:value-of select="@place"/>
        </xsl:attribute>
      </xsl:if>
      <direction-type>
        <pedal>
          <xsl:attribute name="type">
            <xsl:choose>
              <xsl:when test="@dir='bounce'">
                <xsl:text>change</xsl:text>
              </xsl:when>
              <xsl:when test="@dir='down'">
                <xsl:text>start</xsl:text>
              </xsl:when>
              <xsl:when test="@dir='up'">
                <xsl:text>stop</xsl:text>
              </xsl:when>
            </xsl:choose>
          </xsl:attribute>
        </pedal>
      </direction-type>
      <staff>
        <xsl:value-of select="@partStaff"/>
      </staff>
    </direction>
  </xsl:template>

  <xsl:template match="controlevents" mode="stage2"/>

  <!-- for now, ignore any controlevents (other than those currently dealt with) that happen to 
    get into the stream of events -->
  <xsl:template match="mei:add | mei:anchoredText | mei:annot | mei:app | mei:arpeg |
    mei:beamSpan | mei:bend | mei:breath | mei:choice | mei:corr | mei:curve | mei:damage |
    mei:del | mei:div | mei:fermata | mei:gap | mei:gliss | mei:hairpin | mei:handShift |
    mei:harm | mei:harpPedal | mei:line | mei:lyrics | mei:midi | mei:mordent | mei:octave |
    mei:orig | mei:ossia | mei:pb | mei:phrase | mei:reg | mei:reh | mei:restore | mei:sb |
    mei:sic | mei:slur | mei:subst | mei:supplied | mei:symbol | mei:tie | mei:trill |
    mei:tupletSpan | mei:turn | mei:unclear" mode="stage2">
    <xsl:comment>
      <xsl:comment>
        <xsl:value-of select="local-name()"/>
      </xsl:comment>
    </xsl:comment>
  </xsl:template>

  <!-- Default template for addStaffPartID mode -->
  <xsl:template match="@* | node() | comment()" mode="addStaffPartID">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:if test="local-name()='staffDef' and not(@xml:id)">
        <xsl:attribute name="xml:id">
          <xsl:text>P</xsl:text>
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="addStaffPartID"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
