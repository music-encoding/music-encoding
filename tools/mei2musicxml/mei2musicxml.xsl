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

  <!-- global variables -->
  <xsl:variable name="nl">
    <xsl:text>&#xa;</xsl:text>
  </xsl:variable>
  <xsl:variable name="progName">
    <xsl:text>mei2musicxml</xsl:text>
  </xsl:variable>
  <xsl:variable name="progVersion">
    <xsl:text>v. 0.1</xsl:text>
  </xsl:variable>

  <!-- 'Match' templates -->
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="mei:mei">
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

  <xsl:template match="mei:measure" mode="stage1">
    <measure>
      <xsl:if test="@n">
        <xsl:attribute name="number">
          <xsl:value-of select="@n"/>
        </xsl:attribute>
      </xsl:if>
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
      <xsl:copy-of select="@right | @left"/>

      <!-- DEBUG: -->
      <!--<xsl:copy-of select="@*"/>-->

      <xsl:variable name="thisMeasure">
        <xsl:value-of select="@xml:id"/>
      </xsl:variable>

      <xsl:variable name="sb">
        <xsl:choose>
          <xsl:when
            test="preceding-sibling::mei:sb[preceding-sibling::mei:measure[following-sibling::mei:measure[1][@xml:id=$thisMeasure]]]">
            <xsl:copy-of
              select="preceding-sibling::mei:sb[preceding-sibling::mei:measure[following-sibling::mei:measure[@xml:id=$thisMeasure]]][1]"
            />
          </xsl:when>
          <xsl:when test="local-name(preceding-sibling::*[1]) = 'sb'">
            <xsl:copy-of select="preceding-sibling::mei:sb[1]"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="localScoreDef">
        <xsl:choose>
          <xsl:when
            test="preceding-sibling::mei:scoreDef[preceding-sibling::mei:measure[following-sibling::mei:measure[1][@xml:id=$thisMeasure]]]">
            <xsl:copy-of
              select="preceding-sibling::mei:scoreDef[preceding-sibling::mei:measure[following-sibling::mei:measure[@xml:id=$thisMeasure]]][1]"
            />
          </xsl:when>
          <xsl:when test="local-name(preceding-sibling::mei:*[1]) = 'scoreDef'">
            <xsl:copy-of select="preceding-sibling::mei:scoreDef[1]"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="measureContent">
        <!-- Gather event and controlevent contents of measure -->
        <events>
          <xsl:for-each select="mei:staff/mei:layer/*">
            <xsl:variable name="thisStaff">
              <xsl:value-of select="ancestor::mei:staff/@n"/>
            </xsl:variable>
            <xsl:variable name="ppq">
              <xsl:choose>
                <xsl:when test="preceding::mei:staffDef[@n=$thisStaff and @ppq]">
                  <xsl:value-of select="preceding::mei:staffDef[@n=$thisStaff and
                    @ppq][1]/@ppq"/>
                </xsl:when>
                <xsl:when test="preceding::mei:scoreDef[@ppq]">
                  <xsl:value-of select="preceding::mei:scoreDef[@ppq][1]/@ppq"/>
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
              <!-- copy all attributes but @staff and @dur.ges. -->
              <xsl:copy-of select="@*[not(local-name() = 'staff') and not(name()='dur.ges')]"/>
              <xsl:attribute name="measureDuration">
                <xsl:value-of select="$measureDuration"/>
              </xsl:attribute>
              <xsl:variable name="partID">
                <xsl:choose>
                  <xsl:when test="preceding::mei:staffGrp[@xml:id][mei:staffDef[@n=$thisStaff]]">
                    <!-- use staffGrp/xml:id -->
                    <xsl:value-of
                      select="preceding::mei:staffGrp[@xml:id][mei:staffDef[@n=$thisStaff]][1]/@xml:id"
                    />
                  </xsl:when>
                  <xsl:when test="preceding::mei:staffDef[@n=$thisStaff and @xml:id]">
                    <!-- use staffDef/xml:id -->
                    <xsl:value-of select="preceding::mei:staffDef[@n=$thisStaff and
                      @xml:id][1]/@xml:id"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- construct part ID -->
                    <xsl:text>P_</xsl:text>
                    <xsl:choose>
                      <xsl:when
                        test="count(preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]][1]/mei:staffDef)=1">
                        <xsl:value-of
                          select="generate-id(preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]][1]/mei:staffDef[1])"
                        />
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of
                          select="generate-id(preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]][1])"
                        />
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:attribute name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:attribute>
              <!-- staff assignment in MEI; that is, staff counted from top to bottom of score -->
              <xsl:attribute name="meiStaff">
                <xsl:value-of select="ancestor::mei:staff/@n"/>
              </xsl:attribute>
              <!-- staff assignment in MusicXML; that is, where the numbering of staves starts over with each part -->
              <xsl:attribute name="partStaff">
                <xsl:variable name="thisStaff">
                  <xsl:choose>
                    <xsl:when test="not(@staff)">
                      <xsl:value-of select="$thisStaff"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="@staff"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:for-each
                  select="preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]][1]/mei:staffDef[@n=$thisStaff]">
                  <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
                </xsl:for-each>
              </xsl:attribute>
              <!-- At this point, voice = layer assigned in MEI -->
              <xsl:attribute name="voice">
                <xsl:value-of select="ancestor::mei:layer/@n"/>
              </xsl:attribute>
              <!-- Use existing or construct @dur.ges -->
              <xsl:choose>
                <!-- use existing attribute -->
                <xsl:when test="@dur.ges">
                  <xsl:attribute name="dur.ges">
                    <xsl:value-of select="replace(@dur.ges, 'p$', '')"/>
                  </xsl:attribute>
                  <xsl:copy-of select="mei:*"/>
                </xsl:when>
                <!-- for events directly in layer, calculate @dur.ges -->
                <xsl:when test="local-name() = 'note' or local-name() = 'chord' or local-name()
                  = 'rest' or local-name() = 'space' or local-name() = 'mRest' or
                  local-name() = 'mSpace'">
                  <xsl:attribute name="dur.ges">
                    <xsl:choose>
                      <xsl:when test="@grace">
                        <xsl:value-of select="0"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:call-template name="gesturalDurationFromWrittenDuration">
                          <xsl:with-param name="writtenDur">
                            <xsl:choose>
                              <xsl:when test="@dur">
                                <xsl:value-of select="@dur"/>
                              </xsl:when>
                              <xsl:when test="preceding-sibling::mei:*[(local-name()='note' or
                                local-name()='chord' or local-name()='rest') and @dur]">
                                <xsl:value-of select="preceding-sibling::mei:*[(local-name()='note'
                                  or local-name()='chord' or local-name()='rest') and
                                  @dur][1]/@dur"/>
                              </xsl:when>
                              <xsl:when test="following-sibling::mei:*[(local-name()='note' or
                                local-name()='chord' or local-name()='rest') and @dur]">
                                <xsl:value-of select="following-sibling::mei:*[(local-name()='note'
                                  or local-name()='chord' or local-name()='rest') and
                                  @dur][1]/@dur"/>
                              </xsl:when>
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
                  <xsl:copy-of select="mei:*"/>
                </xsl:when>
                <!-- for beam (and tuplet?) calculate @dur.ges for each child -->
                <xsl:when test="local-name() = 'beam' or local-name() = 'tuplet'">
                  <xsl:for-each select="mei:note|mei:chord|mei:rest|mei:space">
                    <xsl:variable name="thisElement">
                      <xsl:value-of select="name()"/>
                    </xsl:variable>
                    <xsl:element name="{$thisElement}" xmlns="http://www.music-encoding.org/ns/mei">
                      <xsl:copy-of select="@*[not(local-name() = 'staff')]"/>
                      <!-- staff assignment in MEI; that is, staff counted from top to bottom of score -->
                      <xsl:attribute name="meiStaff">
                        <xsl:choose>
                          <xsl:when test="@staff">
                            <xsl:value-of select="@staff"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="ancestor::mei:staff/@n"/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:attribute>
                      <!-- staff assignment in MusicXML; that is, where the numbering of staves starts over with each part -->
                      <xsl:attribute name="partStaff">
                        <xsl:variable name="thisStaff">
                          <xsl:choose>
                            <xsl:when test="not(@staff)">
                              <xsl:value-of select="$thisStaff"/>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:value-of select="@staff"/>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:variable>
                        <xsl:for-each
                          select="preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]][1]/mei:staffDef[@n=$thisStaff]">
                          <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
                        </xsl:for-each>
                      </xsl:attribute>
                      <xsl:attribute name="dur.ges">
                        <xsl:choose>
                          <xsl:when test="@grace">
                            <xsl:value-of select="0"/>
                          </xsl:when>
                          <xsl:when test="@dur.ges">
                            <xsl:value-of select="replace(@dur.ges, 'p$', '')"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:call-template name="gesturalDurationFromWrittenDuration">
                              <xsl:with-param name="writtenDur">
                                <xsl:choose>
                                  <xsl:when test="@dur">
                                    <xsl:value-of select="@dur"/>
                                  </xsl:when>
                                  <xsl:when test="preceding-sibling::mei:*[(local-name()='note'
                                    or local-name()='chord' or local-name()='rest') and @dur]">
                                    <xsl:value-of
                                      select="preceding-sibling::mei:*[(local-name()='note' or
                                      local-name()='chord' or local-name()='rest') and
                                      @dur][1]/@dur"/>
                                  </xsl:when>
                                  <xsl:when test="following-sibling::mei:*[(local-name()='note'
                                    or local-name()='chord' or local-name()='rest') and @dur]">
                                    <xsl:value-of
                                      select="following-sibling::mei:*[(local-name()='note' or
                                      local-name()='chord' or local-name()='rest') and
                                      @dur][1]/@dur"/>
                                  </xsl:when>
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
                                <xsl:choose>
                                  <xsl:when test="preceding::mei:staffDef[@n=$thisStaff and
                                    @ppq]">
                                    <xsl:value-of select="preceding::mei:staffDef[@n=$thisStaff
                                      and @ppq][1]/@ppq"/>
                                  </xsl:when>
                                  <xsl:when test="preceding::mei:scoreDef[@ppq]">
                                    <xsl:value-of select="preceding::mei:scoreDef[@ppq][1]/@ppq"/>
                                  </xsl:when>
                                  <xsl:otherwise>
                                    <xsl:value-of select="$ppqDefault"/>
                                  </xsl:otherwise>
                                </xsl:choose>
                              </xsl:with-param>
                            </xsl:call-template>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:attribute>
                      <xsl:copy-of select="mei:*"/>
                    </xsl:element>
                  </xsl:for-each>
                </xsl:when>
              </xsl:choose>
            </xsl:copy>
          </xsl:for-each>
        </events>
        <controlevents>
          <xsl:for-each select="*[not(local-name()='staff')] | comment()">
            <xsl:choose>
              <xsl:when test="local-name()=''">
                <!-- This node is a comment -->
                <xsl:copy-of select="."/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy>
                  <!-- copy all attributes but @staff. -->
                  <xsl:copy-of select="@*[not(local-name() = 'staff')]"/>
                  <xsl:variable name="thisStaff">
                    <xsl:value-of select="@staff"/>
                  </xsl:variable>
                  <xsl:variable name="partID">
                    <xsl:choose>
                      <xsl:when test="preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff] and
                        @xml:id]">
                        <!-- use staffGrp/xml:id -->
                        <xsl:value-of select="preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]
                          and @xml:id][1]/@xml:id"/>
                      </xsl:when>
                      <xsl:when test="preceding::mei:staffDef[@n=$thisStaff and @xml:id]">
                        <!-- use staffDef/xml:id -->
                        <xsl:value-of select="preceding::mei:staffDef[@n=$thisStaff][1]/@xml:id"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <!-- construct part ID -->
                        <xsl:text>P_</xsl:text>
                        <xsl:choose>
                          <xsl:when
                            test="count(preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]][1]/mei:staffDef)=1">
                            <xsl:value-of
                              select="generate-id(preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]][1]/mei:staffDef[1])"
                            />
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of
                              select="generate-id(preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]][1])"
                            />
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:otherwise>
                    </xsl:choose>
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
                    <xsl:for-each
                      select="preceding::mei:staffGrp[mei:staffDef[@n=$thisStaff]][1]/mei:staffDef[@n=$thisStaff]">
                      <xsl:value-of select="count(preceding-sibling::mei:staffDef) + 1"/>
                    </xsl:for-each>
                  </xsl:attribute>
                  <xsl:copy-of select="node()"/>
                </xsl:copy>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </controlevents>
      </xsl:variable>

      <!-- DEBUG: -->
      <!--<xsl:copy-of select="$measureContent"/>-->

      <!-- Group events by partID -->
      <xsl:variable name="measureContent2">
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
        <xsl:copy-of select="$measureContent/controlevents"/>
      </xsl:variable>

      <!-- DEBUG: -->
      <!--<xsl:copy-of select="$measureContent2"/>-->

      <!-- Group events within part by MEI staff and voice -->
      <xsl:variable name="measureContent3">
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
                    <xsl:copy-of select="*"/>
                  </xsl:copy>
                </xsl:for-each>
              </voice>
            </xsl:for-each>
          </part>
        </xsl:for-each>
        <xsl:copy-of select="$measureContent2/controlevents"/>
      </xsl:variable>

      <!-- DEBUG: -->
      <!--<xsl:copy-of select="$measureContent3"/>-->

      <!-- Replace temporary voice elements with <backup> delimiter between voices -->
      <xsl:variable name="measureContent4">
        <xsl:for-each select="$measureContent3/part">
          <part>
            <xsl:copy-of select="@*"/>
            <xsl:for-each select="voice">
              <xsl:copy-of select="mei:*"/>
              <xsl:if test="position() != last()">
                <backup>
                  <duration>
                    <xsl:variable name="backupDuration">
                      <xsl:value-of select="sum(mei:*//@dur.ges)"/>
                    </xsl:variable>
                    <xsl:choose>
                      <xsl:when test="$backupDuration &gt; 0">
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
        <xsl:copy-of select="$measureContent3/controlevents"/>
      </xsl:variable>

      <!-- DEBUG: -->
      <!--<xsl:copy-of select="$measureContent4"/>-->

      <!-- Copy controlevents into appropriate part -->
      <xsl:variable name="measureContent5">
        <xsl:for-each select="$measureContent4/part">
          <part>
            <xsl:copy-of select="@*"/>
            <events>
              <xsl:copy-of select="*"/>
            </events>
            <xsl:variable name="partID">
              <xsl:value-of select="@id"/>
            </xsl:variable>
            <xsl:if test="$measureContent4/controlevents/*">
              <controlevents>
                <!-- Comments between controlevents are dropped here! -->
                <xsl:copy-of select="$measureContent4/controlevents/*[@partID=$partID]"/>
              </controlevents>
            </xsl:if>
          </part>
        </xsl:for-each>
      </xsl:variable>

      <!-- DEBUG: -->
      <!--<xsl:copy-of select="$measureContent5"/>-->

      <!-- Insert MusicXML print and attributes elements where necessary -->
      <xsl:variable name="measureContent6">
        <xsl:for-each select="$measureContent5/part">
          <part>
            <xsl:copy-of select="@*"/>

            <xsl:if test="$sb/*">
              <xsl:copy-of select="$sb"/>
            </xsl:if>

            <xsl:if test="$localScoreDef/*">
              <xsl:copy-of select="$localScoreDef"/>
            </xsl:if>

            <!--<xsl:copy-of select="events"/>-->
            <xsl:apply-templates select="events/*" mode="partContent"/>

            <!-- DEBUG: -->
            <xsl:if test="controlevents/*">
              <xsl:copy-of select="controlevents"/>
            </xsl:if>

          </part>
        </xsl:for-each>
      </xsl:variable>
      <xsl:copy-of select="$measureContent6"/>
    </measure>
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

  <xsl:template match="mei:work | mei:source">
    <work>
      <xsl:for-each select="mei:titleStmt/descendant::mei:identifier[1]">
        <work-number>
          <xsl:value-of select="."/>
        </work-number>
      </xsl:for-each>
      <xsl:choose>
        <xsl:when test="mei:titleStmt/mei:title[@type='uniform']">
          <xsl:for-each select="mei:titleStmt/mei:title[@type='uniform'][1]">
            <xsl:variable name="workTitle">
              <xsl:apply-templates mode="workTitle"/>
            </xsl:variable>
            <work-title>
              <xsl:value-of select="replace(normalize-space($workTitle), '(,|;|:|\.|\s)+$', '')"/>
            </work-title>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="mei:titleStmt/mei:title">
          <xsl:variable name="workTitle">
            <xsl:for-each select="mei:titleStmt/mei:title[not(@type='uniform')]">
              <xsl:apply-templates select="." mode="workTitle"/>
              <xsl:if test="position() != last()">
                <xsl:text> ; </xsl:text>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <work-title>
            <xsl:value-of select="replace(normalize-space($workTitle), '(,|;|:|\.|\s)+$', '')"/>
          </work-title>
        </xsl:when>
      </xsl:choose>
    </work>
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
          <xsl:text>&#32;stylesheet&#32;</xsl:text>
          <xsl:value-of select="$progVersion"/>
        </software>
        <encoding-date>
          <xsl:value-of select="format-date(current-date(), '[Y]-[M02]-[D02]')"/>
        </encoding-date>
      </encoding>
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
      <xsl:variable name="default-x">
        <xsl:value-of select="@x"/>
      </xsl:variable>
      <xsl:variable name="default-y">
        <xsl:value-of select="@y"/>
      </xsl:variable>
      <xsl:for-each-group select="mei:*" group-ending-with="mei:lb">
        <credit-words>
          <xsl:if test="position() = 1">
            <xsl:if test="ancestor::mei:anchoredText/@x">
              <xsl:attribute name="default-x">
                <xsl:value-of select="format-number(ancestor::mei:anchoredText/@x * 5, '###0.####')"
                />
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="ancestor::mei:anchoredText/@y">
              <xsl:attribute name="default-y">
                <xsl:value-of select="format-number(ancestor::mei:anchoredText/@y * 5, '###0.####')"
                />
              </xsl:attribute>
            </xsl:if>
          </xsl:if>
          <xsl:call-template name="rendition"/>
          <xsl:variable name="creditText">
            <xsl:for-each select="current-group()">
              <xsl:value-of select="."/>
              <xsl:if test="position() != last()">
                <xsl:text>&#32;</xsl:text>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:value-of select="normalize-space($creditText)"/>
        </credit-words>
      </xsl:for-each-group>
    </credit>
  </xsl:template>

  <xsl:template match="mei:availability">
    <xsl:if test="normalize-space(mei:useRestrict) != ''">
      <rights>
        <xsl:value-of select="mei:useRestrict"/>
      </rights>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:fileDesc" mode="source">
    <xsl:for-each select="mei:titleStmt">
      <xsl:variable name="creators">
        <xsl:for-each select="mei:respStmt/*[@role='creator' or @role='composer' or
          @role='librettist' or @role='lyricist' or @role='arranger']">
          <xsl:value-of select="."/>
          <xsl:if test="position() != last()">
            <xsl:text>,&#32;</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="encoders">
        <xsl:for-each select="mei:respStmt/*[@role='encoder']">
          <xsl:value-of select="."/>
          <xsl:if test="position() != last()">
            <xsl:text>,&#32;</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="title">
        <xsl:for-each select="mei:title">
          <xsl:value-of select="."/>
          <xsl:if test="position() != last()">
            <xsl:text>,&#32;</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="publisher">
        <xsl:for-each select="../mei:pubStmt/mei:respStmt[1]/mei:*">
          <xsl:value-of select="."/>
          <xsl:if test="position() != last()">
            <xsl:text>,&#32;</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="pubPlace">
        <xsl:for-each select="../mei:pubStmt/mei:address[1]/mei:addrLine">
          <xsl:value-of select="."/>
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
        <xsl:text>.</xsl:text>
        <xsl:if test="normalize-space($title) != ''">
          <xsl:text>&#32;</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="normalize-space($title) != ''">
        <xsl:value-of select="normalize-space($title)"/>
        <xsl:text>.</xsl:text>
        <xsl:if test="normalize-space($encoders) != ''">
          <xsl:text>&#32;</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="normalize-space($encoders) != ''">
        <xsl:text>Encoded by&#32;</xsl:text>
        <xsl:value-of select="normalize-space($encoders)"/>
        <xsl:text>.</xsl:text>
        <xsl:if test="normalize-space($publisher) != ''">
          <xsl:text>&#32;</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="normalize-space($publisher) != ''">
        <xsl:value-of select="normalize-space($publisher)"/>
        <xsl:if test="normalize-space($pubPlace) != ''">
          <xsl:text>:&#32;</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="normalize-space($pubPlace) != ''">
        <xsl:value-of select="normalize-space($pubPlace)"/>
        <xsl:if test="normalize-space($pubDate) != ''">
          <xsl:text>,&#32;</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="normalize-space($pubDate) != ''">
        <xsl:value-of select="$pubDate"/>
        <xsl:text>.</xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="mei:identifier" mode="workTitle">
    <!-- Do nothing! Exclude identifier from title Content -->
  </xsl:template>

  <xsl:template match="mei:scoreDef" mode="credits">
    <xsl:apply-templates select="mei:pgHead | mei:pgFoot | mei:pgHead2 | mei:pgFoot2"/>
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
            <xsl:when test="(mei:rend or mei:lb) and count(mei:rend) + count(mei:lb) = count(mei:*)">
              <xsl:for-each select="mei:rend">
                <credit-words>
                  <xsl:call-template name="rendition"/>
                  <xsl:value-of select="normalize-space(.)"/>
                </credit-words>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="mei:*">
                <xsl:choose>
                  <xsl:when test="(mei:rend or mei:lb) and count(mei:rend) + count(mei:lb) =
                    count(mei:*)">
                    <xsl:for-each select="mei:rend">
                      <credit-words>
                        <xsl:call-template name="rendition"/>
                        <xsl:value-of select="normalize-space(.)"/>
                      </credit-words>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                    <credit-words>
                      <xsl:value-of select="normalize-space(.)"/>
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
              <xsl:value-of select="format-number(number(replace(@page.height, '[a-z]+$', '')) * 5,
                '###0.####')"/>
            </page-height>
            <page-width>
              <xsl:value-of select="format-number(number(replace(@page.width, '[a-z]+$', '')) * 5,
                '###0.####')"/>
            </page-width>
            <page-margins type="both">
              <left-margin>
                <xsl:value-of select="format-number(number(replace(@page.leftmar, '[a-z]+$', '')) *
                  5, '###0.####')"/>
              </left-margin>
              <right-margin>
                <xsl:value-of select="format-number(number(replace(@page.rightmar, '[a-z]+$', '')) *
                  5, '###0.####')"/>
              </right-margin>
              <top-margin>
                <xsl:value-of select="format-number(number(replace(@page.topmar, '[a-z]+$', '')) *
                  5, '###0.####')"/>
              </top-margin>
              <bottom-margin>
                <xsl:value-of select="format-number(number(replace(@page.botmar, '[a-z]+$', '')) *
                  5, '###0.####')"/>
              </bottom-margin>
            </page-margins>
          </page-layout>
        </xsl:if>
        <xsl:if test="@system.leftmar | @system.rightmar | @system.topmar | @spacing.system">
          <system-layout>
            <system-margins>
              <left-margin>
                <xsl:value-of select="format-number(number(replace(@system.leftmar, '[a-z]+$', ''))
                  * 5, '###0.####')"/>
              </left-margin>
              <right-margin>
                <xsl:value-of select="format-number(number(replace(@system.rightmar, '[a-z]+$', ''))
                  * 5, '###0.####')"/>
              </right-margin>
            </system-margins>
            <system-distance>
              <xsl:value-of select="format-number(number(replace(@spacing.system, '[a-z]+$', '')) *
                5, '###0.####')"/>
            </system-distance>
            <top-system-distance>
              <xsl:value-of select="format-number(number(replace(@system.topmar, '[a-z]+$', '')) *
                5, '###0.####')"/>
            </top-system-distance>
          </system-layout>
        </xsl:if>
        <xsl:if test="@spacing.staff">
          <staff-layout>
            <staff-distance>
              <xsl:value-of select="format-number(number(replace(@spacing.staff, '[a-z]+$', '')) *
                5, '###0.####')"/>
            </staff-distance>
          </staff-layout>
        </xsl:if>
        <xsl:if test="@music.name | @text.name | @lyric.name">
          <music-font font-family="{@music.name}" font-size="{@music.size}"/>
          <word-font font-family="{@text.name}" font-size="{@text.size}"/>
          <lyric-font font-family="{@lyric.name}" font-size="{@lyric.size}"/>
        </xsl:if>
      </defaults>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:staffDef" mode="partList">
    <score-part>
      <xsl:attribute name="id">
        <xsl:choose>
          <xsl:when test="@xml:id">
            <xsl:value-of select="@xml:id"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>P_</xsl:text>
            <xsl:value-of select="generate-id()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <part-name>
        <xsl:choose>
          <xsl:when test="@label">
            <xsl:value-of select="@label"/>
          </xsl:when>
          <xsl:when test="ancestor::mei:staffGrp[@label]">
            <xsl:value-of select="ancestor::mei:staffGrp[@label][1]/@label"/>
          </xsl:when>
        </xsl:choose>
      </part-name>
      <xsl:apply-templates select="mei:instrDef" mode="partList"/>
    </score-part>
  </xsl:template>

  <xsl:template match="mei:staffGrp" mode="partList">
    <xsl:choose>
      <!-- The entire staff group constitutes a single part -->
      <xsl:when test="mei:instrDef or (@label and not(mei:staffDef/@label))">
        <score-part>
          <xsl:attribute name="id">
            <xsl:value-of select="@xml:id"/>
          </xsl:attribute>
          <part-name>
            <xsl:value-of select="@label"/>
          </part-name>
          <xsl:apply-templates select="mei:instrDef" mode="partList"/>
        </score-part>
      </xsl:when>
      <!-- Each staffGrp or staffDef is a separate part -->
      <xsl:otherwise>
        <xsl:apply-templates select="mei:staffDef | mei:staffGrp" mode="partList"/>
      </xsl:otherwise>
    </xsl:choose>
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
            <xsl:value-of select="generate-id()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <instrument-name>
        <xsl:value-of select="replace(@midi.instrname, '_', '&#32;')"/>
      </instrument-name>
    </score-instrument>
    <midi-instrument>
      <xsl:attribute name="id">
        <xsl:choose>
          <xsl:when test="@xml:id">
            <xsl:value-of select="@xml:id"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>I</xsl:text>
            <xsl:value-of select="generate-id()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <midi-channel>
        <xsl:value-of select="@midi.channel"/>
      </midi-channel>
      <midi-program>
        <!-- MusicXML uses 1-based program numbers -->
        <xsl:value-of select="@midi.instrnum + 1"/>
      </midi-program>
      <volume>
        <!-- MusicXML uses scaling factor instead of actual MIDI value -->
        <xsl:value-of select="round((@midi.volume * 100) div 127)"/>
      </volume>
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
    </midi-instrument>
  </xsl:template>

  <!-- Named templates -->
  <xsl:template name="gesturalDurationFromWrittenDuration">
    <!-- Calculate quantized value (in ppq units) -->
    <xsl:param name="ppq"/>
    <xsl:param name="writtenDur"/>
    <xsl:param name="dots"/>
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
          <!--<xsl:choose>
            <xsl:when test="@tuplet">
              <xsl:value-of select="$ppq div 3"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$ppq div 2"/>
            </xsl:otherwise>
          </xsl:choose>-->
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
    <xsl:value-of select="$baseDur + $dotClicks"/>
  </xsl:template>

  <xsl:template name="measureDuration">
    <!-- Calculate duration of a measure in ppq units -->
    <xsl:param name="meterCount"/>
    <xsl:param name="meterUnit"/>
    <xsl:param name="ppq"/>
    <!--DEBUG:-->
    <!--<xsl:variable name="errorMessage">
      <xsl:text>m. </xsl:text>
      <xsl:value-of select="ancestor::measure/@number"/>
      <xsl:text>, part </xsl:text>
      <xsl:value-of select="ancestor::part/@id"/>
      <xsl:text>: meterCount=</xsl:text>
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
        <xsl:value-of select="($meterCount div ($meterUnit div 4)) * $ppq"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="rendition">
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
                <xsl:value-of select="replace(replace(replace(replace(., 'box', 'rectangle'),
                  'circle', 'circle'), 'dbox', 'diamond'), 'tbox', 'triangle')"/>
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

  <xsl:template match="backup" mode="partContent">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="mei:clef" mode="partContent">
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

  <xsl:template match="mei:mRest|mei:mSpace|mei:rest|mei:space" mode="partContent">
    <note>

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
          <xsl:when test="@dur.ges"> </xsl:when>
        </xsl:choose>
      </type>
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

  <xsl:template match="mei:beam|mei:chord|mei:tuplet" mode="partContent">
    <xsl:apply-templates mode="partContent"/>
  </xsl:template>

  <xsl:template match="mei:note" mode="partContent">
    <note>

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
        </xsl:choose>
      </type>
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
        <xsl:for-each select="mei:artic[@artic]">
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
                <!-\- Copy directive content -\->
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
              <!-\- Copy content of directive to start marker -\->
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
            <xsl:value-of select="@n"/>
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

  <xsl:template match="measure" mode="stage2">
    <xsl:copy>
      <xsl:copy-of select="@number"/>
      <xsl:if test="@width">
        <xsl:attribute name="width">
          <xsl:value-of select="format-number(@width * 5, '###0.####')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="part" mode="stage2"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="part" mode="stage2">
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name()='right')]"/>
      <xsl:apply-templates select="*[local-name() = 'sb' or local-name()= 'scoreDef']" mode="stage2"/>
      <xsl:if test="ancestor::measure/@left">
        <xsl:choose>
          <xsl:when test="ancestor::measure/@left='rptstart'">
            <barline location="left">
              <bar-style>heavy-light</bar-style>
              <repeat direction="forward"/>
            </barline>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
      <xsl:apply-templates select="*[local-name() != 'controlevents' and local-name() != 'sb' and
        local-name() != 'scoreDef']" mode="stage2"/>
      <xsl:if test="ancestor::measure/@right">
        <xsl:choose>
          <xsl:when test="ancestor::measure/@right='dbl'">
            <barline location="right">
              <bar-style>light-light</bar-style>
            </barline>
          </xsl:when>
          <xsl:when test="ancestor::measure/@right='end'">
            <barline location="right">
              <bar-style>light-heavy</bar-style>
            </barline>
          </xsl:when>
          <xsl:when test="ancestor::measure/@right='rptend'">
            <barline location="right">
              <bar-style>light-heavy</bar-style>
              <repeat direction="backward"/>
            </barline>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="note" mode="stage2">
    <xsl:copy>
      <xsl:apply-templates mode="stage2"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()" mode="stage2">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="stage2"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
