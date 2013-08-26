<?xml version="1.0" encoding="UTF-8"?>

<!-- ************************************************************** -->
<!--
  NAME:     musicxml2mei.xsl (version 2.2.3)
            Vers Date = 2010/04/23

  NOTICE:   Copyright (c) 2010 by the Music Encoding Initiative (MEI)
            Council.
  
            Licensed under the Educational Community License, Version
            2.0 (the "License"); you may not use this file except in
            compliance with the License. You may obtain a copy of the
            License at http://www.osedu.org/licenses/ECL-2.0.
            
            Unless required by applicable law or agreed to in writing,
            software distributed under the License is distributed on
            an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
            KIND, either express or implied. See the License for the
            specific language governing permissions and limitations
            under the License.
            
            This is a derivative work based on earlier versions of the
            schema copyright (c) 2001-2006 Perry Roland and the Rector
            and Visitors of the University of Virginia; licensed under
            the Educational Community License version 1.0.
  
  CONTACT:  contact@music-encoding.org 
-->

<!-- Modified by Raffaele Viglianti -->

<!DOCTYPE xsl:stylesheet [
<!ENTITY startbeam      "&#xE501;">
<!ENTITY endbeam        "&#xE502;">
<!ENTITY % MusicChars SYSTEM
   'http://text.lib.virginia.edu/charent/musicchar.ent'> %MusicChars;
]>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:saxon="http://saxon.sf.net/" exclude-result-prefixes="saxon">

  <!-- Stylesheet parameters -->
  <xsl:param name="accidattr">no</xsl:param>
  <!-- If set to 'yes', puts accidentals in attributes -->
  <xsl:param name="articattr">no</xsl:param>
  <!-- If set to 'yes', puts articulations in attributes -->
  <xsl:param name="sylattr">no</xsl:param>
  <!-- If set to 'yes', puts lyric syllables in attributes -->
  <xsl:param name="genid">no</xsl:param>
  <!-- If set to 'yes', creates an ID for the MEI file -->

  <xsl:character-map name="music-chars">
    <!-- <xsl:output-character character="&#x00A9;" string="&amp;copy;"/> -->
    <xsl:output-character character="&#x1D12A;" string="&amp;dblsharp;"/>
    <xsl:output-character character="&#x1D12B;" string="&amp;dblflat;"/>
    <xsl:output-character character="&#x266D;" string="&amp;flat;"/>
    <xsl:output-character character="&#x266E;" string="&amp;natural"/>
    <xsl:output-character character="&#x266F;" string="&amp;sharp;"/>
    <xsl:output-character character="&#x1D110;" string="&amp;ferm;"/>
    <xsl:output-character character="&#x1D111;" string="&amp;fermbelow;"/>
    <xsl:output-character character="&#x1D1B8;" string="&amp;long;"/>
    <xsl:output-character character="&#x1D15C;" string="&amp;breve;"/>
    <xsl:output-character character="&#x1D15D;" string="&amp;note1;"/>
    <xsl:output-character character="&#x1D15E;" string="&amp;note2;"/>
    <xsl:output-character character="&#x1D15F;" string="&amp;note4;"/>
    <xsl:output-character character="&#x1D160;" string="&amp;note8;"/>
    <xsl:output-character character="&#x1D161;" string="&amp;note16;"/>
    <xsl:output-character character="&#x1D162;" string="&amp;note32;"/>
    <xsl:output-character character="&#x1D163;" string="&amp;note64;"/>
    <xsl:output-character character="&#x1D164;" string="&amp;note128;"/>
    <xsl:output-character character="&#x1D109;" string="&amp;dalsegno;"/>
    <xsl:output-character character="&#x1D10A;" string="&amp;dacapo;"/>
    <xsl:output-character character="&#x1D10B;" string="&amp;segno;"/>
    <xsl:output-character character="&#x1D10C;" string="&amp;coda"/>
    <xsl:output-character character="&#x1D113;" string="&amp;caesura;"/>
  </xsl:character-map>

  <xsl:character-map name="delimiters">
    <xsl:output-character character="&startbeam;"
      string="&lt;beam&gt;"/>
    <xsl:output-character character="&endbeam;"
      string="&lt;/beam&gt;"/>
  </xsl:character-map>

  <xsl:output method="xml" indent="yes" encoding="UTF-8"
    omit-xml-declaration="no" standalone="no"
    use-character-maps="music-chars delimiters"/>

  <xsl:strip-space elements="*"/>

  <xsl:variable name="nl">
    <xsl:text>&#xa;</xsl:text>
  </xsl:variable>

  <xsl:variable name="progname">
    <xsl:text>musicxml2mei</xsl:text>
  </xsl:variable>

  <xsl:variable name="progversion">
    <xsl:text>v. 2.2.3</xsl:text>
  </xsl:variable>

  <!-- Create a 'default layout lookup table'. This is used for various
       tasks later. -->
  <xsl:variable name="defaultlayout">
    <xsl:choose>
      <xsl:when test="score-timewise">
        <xsl:apply-templates select="score-timewise/part-list" mode="stage1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="errorMessage">The source file is not a time-wise
          MusicXML file!</xsl:variable>
        <xsl:message terminate="yes">
          <xsl:value-of select="normalize-space($errorMessage)"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:variable name="stage1">
      <xsl:apply-templates select="score-timewise" mode="stage1"/>
    </xsl:variable>
    <!-- <xsl:copy-of select="$stage1"/> -->
    <xsl:apply-templates select="$stage1" mode="stage2"/>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="score-timewise" mode="stage1">
    <mei>
      <!-- Generate an id only on request -->
      <xsl:if test="$genid='yes'">
        <xsl:attribute name="xml:id">
          <xsl:value-of
            select="concat('_',format-dateTime(current-dateTime(), '[Y][M01][D01][H01][m01][s01][f001]'))"
          />
        </xsl:attribute>
      </xsl:if>

      <!-- Create the mei header -->
      <meihead>
        <filedesc>
          <titlestmt>
            <title>
              <xsl:value-of select="normalize-space(work/work-title)"/>
              <xsl:if test="normalize-space(work/work-number)!=''">
                <xsl:text>, </xsl:text>
                <xsl:value-of select="normalize-space(work/work-number)"/>
              </xsl:if>
              <xsl:if test="normalize-space(movement-number)!=''">
                <xsl:text>, </xsl:text>
                <xsl:value-of select="normalize-space(movement-number)"/>
              </xsl:if>
              <xsl:if test="normalize-space(movement-title)!=''">
                <xsl:if
                  test="normalize-space(concat(work/work-title,work/work-number,movement-number))!=''">
                  <xsl:text>. </xsl:text>
                </xsl:if>
                <xsl:value-of select="normalize-space(movement-title)"/>
              </xsl:if>
            </title>
            <xsl:if test="identification/creator">
              <respstmt>
                <xsl:for-each select="identification/creator">
                  <xsl:value-of select="$nl"/>
                  <resp>
                    <xsl:value-of select="./@type"/>
                  </resp>
                  <name>
                    <xsl:value-of select="normalize-space(.)"/>
                  </name>
                </xsl:for-each>
              </respstmt>
            </xsl:if>
          </titlestmt>
          <pubstmt/>

          <xsl:if test="work/work-title or movement-title">
            <sourcedesc>
              <source>
                <titlestmt>
                  <title>
                    <xsl:value-of select="normalize-space(work/work-title)"/>
                    <xsl:if test="normalize-space(work/work-number)!=''">
                      <xsl:text>, </xsl:text>
                      <xsl:value-of select="normalize-space(work/work-number)"/>
                    </xsl:if>
                    <xsl:if test="normalize-space(movement-number)!=''">
                      <xsl:text>, </xsl:text>
                      <xsl:value-of select="normalize-space(movement-number)"/>
                    </xsl:if>
                    <xsl:if test="normalize-space(movement-title)!=''">
                      <xsl:if
                        test="normalize-space(concat(work/work-title,work/work-number,movement-number))!=''">
                        <xsl:text>. </xsl:text>
                      </xsl:if>
                      <xsl:value-of select="normalize-space(movement-title)"/>
                    </xsl:if>
                  </title>
                  <xsl:if test="identification">
                    <respstmt>
                      <xsl:for-each select="identification/creator">
                        <xsl:value-of select="$nl"/>
                        <resp>
                          <xsl:value-of select="./@type"/>
                        </resp>
                        <name>
                          <xsl:value-of select="normalize-space(.)"/>
                        </name>
                      </xsl:for-each>
                      <xsl:for-each select="identification/encoding/encoder">
                        <name>
                          <xsl:attribute name="role">
                            <xsl:value-of select="./@type"/>
                          </xsl:attribute>
                          <xsl:value-of select="normalize-space(.)"/>
                        </name>
                      </xsl:for-each>
                      <xsl:if
                        test="not(identification/creator) and not(identification/encoding/encoder)">
                        <name/>
                      </xsl:if>
                    </respstmt>
                  </xsl:if>
                </titlestmt>
                <pubstmt>
                  <xsl:if test="identification/rights">
                    <availability>
                      <userestrict>
                        <xsl:value-of select="identification/rights"/>
                      </userestrict>
                    </availability>
                  </xsl:if>
                </pubstmt>
              </source>
            </sourcedesc>
          </xsl:if>

        </filedesc>
        <encodingdesc>
          <projectdesc>
            <p>Transcoded from a MusicXML <xsl:if test="@version"> version
                  <xsl:value-of select="@version"/>
              </xsl:if> file on <date>
                <xsl:value-of
                  select="format-date(current-date(), '[Y]-[M02]-[D02]')"/>
              </date> using an XSLT stylesheet (<xsl:value-of select="$progname"/><xsl:text> </xsl:text>
              <xsl:value-of select="$progversion"/>).</p>
            <xsl:if test="identification/encoding/software">
              <xsl:variable name="software">
                <xsl:value-of select="count(identification/encoding/software)"/>
              </xsl:variable>
              <p>The MusicXML file was generated using <xsl:for-each
                  select="identification/encoding/software">
                  <xsl:value-of select="."/>
                  <xsl:if test="count(following-sibling::software) &gt; 1">
                    <xsl:text>, </xsl:text>
                  </xsl:if>
                  <xsl:if test="count(following-sibling::software) = 1">
                    <xsl:choose>
                      <xsl:when test="count(preceding-sibling::software) = 0">
                        <xsl:text> and </xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text>, and </xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:if>
                </xsl:for-each>
                <xsl:if test="identification/encoding/encoding-date"> on <date>
                    <xsl:value-of select="identification/encoding/encoding-date"
                    />
                  </date>
                </xsl:if>.</p>
            </xsl:if>
          </projectdesc>
        </encodingdesc>
        <xsl:call-template name="profiledesc"/>
      </meihead>
      <music>
        <body>
          <mdiv>
            <score>
              <scoredef>

                <!-- Look in first measure for score-level meter signature -->
                <xsl:if test="descendant::measure[1]/part/attributes">
                  <xsl:if
                    test="descendant::measure[1]/part/attributes[time/beats]">
                    <xsl:attribute name="meter.count">
                      <xsl:value-of
                        select="descendant::part[attributes/time/beats][1]/attributes/time/beats"
                      />
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if
                    test="descendant::measure[1]/part/attributes[time/beat-type]">
                    <xsl:attribute name="meter.unit">
                      <xsl:value-of
                        select="descendant::part[attributes/time/beat-type][1]/attributes/time/beat-type"
                      />
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:variable name="symbol">
                    <xsl:value-of
                      select="descendant::part[attributes/time/@symbol][1]/attributes/time/@symbol"
                    />
                  </xsl:variable>
                  <xsl:choose>
                    <xsl:when test="$symbol='common'">
                      <xsl:attribute name="meter.sym">common</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$symbol='cut'">
                      <xsl:attribute name="meter.sym">cut</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$symbol='single-number'">
                      <xsl:attribute name="meter.rend">denomsym</xsl:attribute>
                    </xsl:when>
                    <xsl:when
                      test="descendant::part[attributes/time/senza-misura][1]/attributes/time/senza-misura">
                      <xsl:attribute name="meter.rend">invis</xsl:attribute>
                    </xsl:when>
                  </xsl:choose>
                </xsl:if>

                <!-- Look in first measure for score-level key signature and mode -->
                <xsl:if test="descendant::part/attributes[not(transpose)]/key">
                  <xsl:variable name="keysig">
                    <xsl:value-of
                      select="descendant::part[attributes[not(transpose) and key]][1]/attributes/key/fifths"
                    />
                  </xsl:variable>
                  <xsl:choose>
                    <xsl:when test="$keysig=''">
                      <xsl:attribute name="key.sig">
                        <xsl:text>0</xsl:text>
                      </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$keysig=0">
                      <xsl:attribute name="key.sig">
                        <xsl:value-of select="$keysig"/>
                      </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$keysig &gt; 0">
                      <xsl:attribute name="key.sig"><xsl:value-of
                          select="$keysig"/>s</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$keysig &lt; 0">
                      <xsl:attribute name="key.sig">
                        <xsl:value-of select="abs($keysig)"/>f</xsl:attribute>
                    </xsl:when>
                  </xsl:choose>
                  <xsl:if test="descendant::part/attributes/key/mode">
                    <xsl:attribute name="key.mode">
                      <xsl:value-of
                        select="descendant::part[attributes/key/mode][1]/attributes/key/mode"
                      />
                    </xsl:attribute>
                  </xsl:if>
                </xsl:if>

                <!-- If any staves are not printed, then staff optimization is in effect. -->
                <xsl:if
                  test="//measure/part/attributes/staff-details/@print-object='no'">
                  <xsl:attribute name="optimize">true</xsl:attribute>
                </xsl:if>

                <!-- Look in first measure for other score-level defaults -->
                <xsl:apply-templates select="defaults" mode="stage1"/>
                <!-- Create page headers and footers -->
                <xsl:call-template name="credits"/>

                <xsl:copy-of select="$defaultlayout"/>
              </scoredef>

              <!-- Process score measures -->
              <!-- Measures are grouped based on criteria in the group-ending-with attribute -->
              <xsl:for-each-group select="measure"
                group-ending-with="measure[part/barline/repeat[@direction='backward'] or 
following-sibling::measure[1][part/barline[@location='left']/repeat[@direction='forward']] or 
part/barline/ending[@type='stop'] or 
part/barline[@location='right']/bar-style='light-light' or 
following-sibling::measure[1][part/barline/ending[@type='start']] or 
following-sibling::measure[1][part/attributes[time or key]]
]">

                <!-- Other potential (sub?) section-ending conditions:
following-sibling::measure[1][print/page-layout] or
following-sibling::measure[1][print/system-layout] or
following-sibling::measure[1][print/staff-layout] or
following-sibling::measure[1][print/measure-layout] or
following-sibling::measure[1][attributes[staves]] or
following-sibling::measure[1][attributes[not(preceding-sibling::note)]] -->

                <!-- Create sections/endings based on the grouping of measures -->
                <xsl:choose>
                  <xsl:when test="part/barline/ending[@type='start']">
                    <ending>
                      <xsl:attribute name="n">
                        <xsl:choose>
                          <xsl:when
                            test="part/barline/ending[@type='start'] != ''">
                            <xsl:value-of
                              select="part/barline/ending[@type='start']"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of
                              select="part/barline/ending[@type='start']/@number"
                            />
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:attribute>
                      <xsl:for-each-group select="current-group()"
                        group-starting-with="measure[part/attributes[time or key]]">
                        <xsl:apply-templates select="current-group()"
                          mode="stage1"/>
                      </xsl:for-each-group>
                    </ending>
                  </xsl:when>
                  <xsl:otherwise>
                    <section>
                      <xsl:for-each-group select="current-group()"
                        group-starting-with="measure[part/attributes[time or key]]">
                        <xsl:apply-templates select="current-group()"
                          mode="stage1"/>
                      </xsl:for-each-group>
                    </section>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each-group>
            </score>
          </mdiv>
        </body>
      </music>
    </mei>
  </xsl:template>

  <xsl:template match="defaults" mode="stage1">
    <!-- Page scaling. Record MusicXML page scale: ratio of virtual units
         (tenths of interline space) to real-world units (millimeters). -->
    <xsl:for-each select="scaling">
      <xsl:attribute name="page.scale"><xsl:value-of select="tenths"
          />:<xsl:value-of select="millimeters"/></xsl:attribute>
    </xsl:for-each>

    <!-- MusicXML real-world units are millimeters -->
    <xsl:attribute name="page.units">mm</xsl:attribute>

    <!-- Process page layout options -->
    <xsl:for-each select="page-layout">
      <xsl:attribute name="page.height">
        <xsl:value-of select="page-height"/>
      </xsl:attribute>
      <xsl:attribute name="page.width">
        <xsl:value-of select="page-width"/>
      </xsl:attribute>
      <xsl:for-each select="page-margins[1]">
        <xsl:attribute name="page.leftmar">
          <xsl:value-of select="left-margin"/>
        </xsl:attribute>
        <xsl:attribute name="page.rightmar">
          <xsl:value-of select="right-margin"/>
        </xsl:attribute>
        <xsl:attribute name="page.topmar">
          <xsl:value-of select="top-margin"/>
        </xsl:attribute>
        <xsl:attribute name="page.botmar">
          <xsl:value-of select="bottom-margin"/>
        </xsl:attribute>
      </xsl:for-each>
    </xsl:for-each>

    <!-- Process system layout options -->
    <xsl:for-each select="system-layout">
      <xsl:for-each select="system-margins">
        <xsl:attribute name="system.leftmar">
          <xsl:value-of select="left-margin"/>
        </xsl:attribute>
        <xsl:attribute name="system.rightmar">
          <xsl:value-of select="right-margin"/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:for-each select="system-distance">
        <xsl:attribute name="spacing.system">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:for-each select="top-system-distance">
        <xsl:attribute name="system.topmar">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
    </xsl:for-each>

    <!-- Process staff layout options -->
    <xsl:for-each select="staff-layout">
      <xsl:for-each select="staff-distance">
        <xsl:attribute name="spacing.staff">
          <xsl:value-of select="."/>
        </xsl:attribute>
      </xsl:for-each>
    </xsl:for-each>

    <!-- Process various font options -->
    <xsl:for-each select="music-font">
      <xsl:attribute name="music.name">
        <xsl:value-of select="@font-family"/>
      </xsl:attribute>
      <xsl:attribute name="music.size">
        <xsl:value-of select="@font-size"/>
      </xsl:attribute>
    </xsl:for-each>
    <xsl:for-each select="word-font">
      <xsl:attribute name="text.name">
        <xsl:value-of select="@font-family"/>
      </xsl:attribute>
      <xsl:attribute name="text.size">
        <xsl:value-of select="@font-size"/>
      </xsl:attribute>
    </xsl:for-each>
    <xsl:for-each select="lyric-font">
      <xsl:attribute name="lyric.name">
        <xsl:value-of select="@font-family"/>
      </xsl:attribute>
      <xsl:attribute name="lyric.size">
        <xsl:value-of select="@font-size"/>
      </xsl:attribute>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="part-list" mode="stage1">
    <!-- Create the basic content of $defaultlayout. -->
    <xsl:variable name="outergrp">
      <staffgrp>
        <xsl:variable name="temptree">
          <xsl:apply-templates select="score-part|part-group" mode="staffdef"/>
        </xsl:variable>
        <xsl:variable name="temptree2">
          <xsl:apply-templates select="$temptree" mode="countstaves"/>
        </xsl:variable>
        <xsl:copy-of select="$temptree2/staffgrp|$temptree2/staffdef"/>
        <xsl:apply-templates
          select="$temptree2/part-group[@type='start' and group-symbol='bracket']"
          mode="bracketelements"/>
        <xsl:apply-templates
          select="$temptree2/part-group[@type='start' and group-symbol='brace']"
          mode="braceelements"/>
      </staffgrp>
    </xsl:variable>
    <xsl:apply-templates select="$outergrp" mode="outergrpfix"/>
  </xsl:template>

  <xsl:template match="staffdef|staffgrp" mode="outergrpfix">
    <!-- Continue processing the contents of $defaultlayout. -->
    <xsl:choose>
      <xsl:when test="name()='staffgrp' and count(ancestor::*)=0">
        <xsl:choose>
          <xsl:when
            test="count(staffgrp) = count(child::*) and count(child::*) = 1">
            <xsl:apply-templates select="staffgrp" mode="outergrpfix"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="(.)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="(.)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="part-group[@type='start' and group-symbol='bracket']"
    mode="bracketelements">
    <!-- Create stand-off bracket staff grouping symbols. -->
    <grpsym symbol="bracket">
      <xsl:attribute name="start">
        <xsl:value-of select="following-sibling::staffdef[1]/@n"/>
      </xsl:attribute>
      <xsl:variable name="level">
        <xsl:value-of select="@number"/>
      </xsl:variable>
      <xsl:attribute name="end">
        <xsl:for-each
          select="following-sibling::part-group[@type='stop' and @number=$level][1]">
          <xsl:value-of select="preceding-sibling::staffdef[1]/@n"/>
        </xsl:for-each>
      </xsl:attribute>
      <xsl:if test="group-name">
        <xsl:attribute name="label.full">
          <xsl:value-of select="group-name"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="group-abbreviation">
        <xsl:attribute name="label.abbr">
          <xsl:value-of select="group-abbreviation"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="group-barline='yes'">
        <xsl:attribute name="barthru">true</xsl:attribute>
      </xsl:if>
    </grpsym>
  </xsl:template>

  <xsl:template match="part-group[@type='start' and group-symbol='brace']"
    mode="braceelements">
    <!-- Create stand-off brace staff grouping symbols. -->
    <grpsym symbol="brace">
      <xsl:attribute name="start">
        <xsl:value-of select="following-sibling::staffdef[1]/@n"/>
      </xsl:attribute>
      <xsl:variable name="level">
        <xsl:value-of select="@number"/>
      </xsl:variable>
      <xsl:attribute name="end">
        <xsl:for-each
          select="following-sibling::part-group[@type='stop' and @number=$level][1]">
          <xsl:value-of select="preceding-sibling::staffdef[1]/@n"/>
        </xsl:for-each>
      </xsl:attribute>
      <xsl:if test="group-name">
        <xsl:attribute name="label.full">
          <xsl:value-of select="group-name"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="group-abbreviation">
        <xsl:attribute name="label.abbr">
          <xsl:value-of select="group-abbreviation"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="group-barline='yes'">
        <xsl:attribute name="barthru">true</xsl:attribute>
      </xsl:if>
    </grpsym>
  </xsl:template>

  <xsl:template match="staffdef|staffgrp|part-group" mode="countstaves">
    <!-- Number staves in $defaultlayout -->
    <xsl:choose>
      <xsl:when test="name()='staffdef'">
        <staffdef>
          <xsl:attribute name="n">
            <xsl:value-of select="count(preceding::staffdef) + 1"/>
          </xsl:attribute>
          <xsl:copy-of select="@*|node()"/>
        </staffdef>
      </xsl:when>
      <xsl:when test="name()='staffgrp'">
        <staffgrp>
          <xsl:copy-of select="@*|instrdef"/>
          <xsl:for-each select="staffdef">
            <staffdef>
              <xsl:attribute name="n">
                <xsl:value-of select="count(preceding::staffdef) + 1"/>
              </xsl:attribute>
              <xsl:copy-of select="@*|node()"/>
            </staffdef>
          </xsl:for-each>
        </staffgrp>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="(.)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="part-group" mode="staffdef">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="score-part" mode="staffdef">
    <!-- Create staffdef elements in $defaultlayout -->
    <xsl:variable name="partID">
      <xsl:value-of select="@id"/>
    </xsl:variable>
    <xsl:variable name="staves">
      <xsl:choose>
        <xsl:when test="following::measure/part[@id=$partID]/attributes/staves">
          <xsl:value-of
            select="max(following::measure/part[@id=$partID]/attributes/staves)"
          />
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$staves=1">
        <!-- When the part uses a single staff, create a staffdef element and its attributes. -->
        <staffdef>
          <xsl:attribute name="xml:id">
            <xsl:value-of select="$partID"/>
          </xsl:attribute>
          <xsl:attribute name="label.full">
            <xsl:value-of select="part-name"/>
          </xsl:attribute>
          <xsl:if test="part-abbreviation!=''">
            <xsl:attribute name="label.abbr">
              <xsl:value-of select="part-abbreviation"/>
            </xsl:attribute>
          </xsl:if>

          <xsl:choose>
            <xsl:when test="midi-instrument">
              <xsl:for-each select="midi-instrument">
                <instrdef>
                  <xsl:variable name="midiID">
                    <xsl:value-of select="@id"/>
                  </xsl:variable>
                  <xsl:attribute name="n">
                    <xsl:value-of
                      select="replace(normalize-space(preceding-sibling::score-instrument[@id=$midiID]), ' ', '_')"
                    />
                  </xsl:attribute>
                  <xsl:attribute name="xml:id">
                    <xsl:value-of select="$midiID"/>
                  </xsl:attribute>
                  <xsl:attribute name="midi.channel">
                    <xsl:value-of select="midi-channel"/>
                  </xsl:attribute>
                  <!-- It appears that MusicXML is using 1-based program numbers. Convert to 0-based. -->
                  <xsl:attribute name="midi.instrnum">
                    <xsl:value-of select="number(midi-program) - 1"/>
                  </xsl:attribute>
                </instrdef>
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="score-instrument">
              <xsl:for-each select="score-instrument">
                <instrdef>
                  <xsl:attribute name="xml:id">
                    <xsl:value-of select="@id"/>
                  </xsl:attribute>
                  <xsl:attribute name="midi.channel">
                    <xsl:value-of select="count(preceding::score-instrument)+1"
                    />
                  </xsl:attribute>
                  <xsl:attribute name="midi.instrnum">1</xsl:attribute>
                </instrdef>
              </xsl:for-each>
            </xsl:when>
          </xsl:choose>
        </staffdef>
      </xsl:when>
      <xsl:otherwise>
        <!-- When there's more than one staff in the part, create a staffgrp and its midi instrument
             definitions and then the required number of MEI staffdef elements. -->
        <staffgrp>
          <xsl:attribute name="xml:id">
            <xsl:value-of select="$partID"/>
          </xsl:attribute>
          <xsl:attribute name="symbol">brace</xsl:attribute>
          <xsl:attribute name="label.full">
            <xsl:value-of select="part-name"/>
          </xsl:attribute>
          <xsl:if test="part-abbreviation!=''">
            <xsl:attribute name="label.abbr">
              <xsl:value-of select="part-abbreviation"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:for-each select="midi-instrument">
            <instrdef>
              <xsl:variable name="midiID">
                <xsl:value-of select="@id"/>
              </xsl:variable>
              <xsl:attribute name="n">
                <xsl:value-of
                  select="replace(normalize-space(preceding-sibling::score-instrument[@id=$midiID]), ' ', '_')"
                />
              </xsl:attribute>
              <xsl:attribute name="xml:id">
                <xsl:value-of select="$midiID"/>
              </xsl:attribute>
              <xsl:attribute name="midi.channel">
                <xsl:value-of select="midi-channel"/>
              </xsl:attribute>
              <xsl:attribute name="midi.instrnum">
                <xsl:value-of select="number(midi-program) - 1"/>
              </xsl:attribute>
            </instrdef>
          </xsl:for-each>
          <xsl:call-template name="makestaffdef">
            <xsl:with-param name="num">
              <xsl:value-of select="$staves"/>
            </xsl:with-param>
            <xsl:with-param name="label.full"/>
            <xsl:with-param name="label.abbr"/>
          </xsl:call-template>
        </staffgrp>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="makestaffdef">
    <!-- This template is called recursively to create the desired number of staves for a part in $defaultlayout. -->
    <xsl:param name="num">1</xsl:param>
    <xsl:param name="label.full"/>
    <xsl:param name="label.abbr"/>
    <xsl:if test="$num &gt; 0">
      <staffdef>
        <xsl:if test="$label.full!=''">
          <xsl:attribute name="label.full">
            <xsl:value-of select="$label.full"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="$label.abbr!=''">
          <xsl:attribute name="label.abbr">
            <xsl:value-of select="$label.abbr"/>
          </xsl:attribute>
        </xsl:if>
      </staffdef>
      <xsl:call-template name="makestaffdef">
        <xsl:with-param name="num">
          <xsl:value-of select="$num - 1"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="credits">
    <!-- Transform MusicXML credits element into MEI pghead and pgfoot elements -->
    <xsl:variable name="pageheight">
      <xsl:value-of select="defaults/page-layout/page-height"/>
    </xsl:variable>
    <xsl:if test="credit/credit-words[@default-y &gt; ($pageheight div 2)]">
      <!-- Credits above the middle of the page go in pghead. -->
      <!--<pghead1>
        <table>
          <xsl:variable name="creditsrepaired">
            <xsl:apply-templates select="credit" mode="repair"/>
          </xsl:variable>
          <xsl:variable name="creditgroup">
            <xsl:copy-of
              select="$creditsrepaired//credit-words[@default-y &gt; ($pageheight div 2)]"
            />
          </xsl:variable>
          <xsl:variable name="creditgroup2">
            <xsl:for-each-group select="$creditgroup//credit-words"
              group-by="@default-y">
              <!-\- Credits are sorted in the order of appearance down the page and then across the page. -\->
              <xsl:sort select="@default-y" order="descending"
                data-type="number"/>
              <xsl:sort select="@default-x" order="ascending" data-type="number"/>
              <tr>
                <xsl:attribute name="y">
                  <xsl:value-of select="@default-y"/>
                </xsl:attribute>
                <xsl:copy-of select="current-group()"/>
              </tr>
            </xsl:for-each-group>
          </xsl:variable>
          <xsl:apply-templates select="$creditgroup2/tr" mode="stage1"/>
        </table>
      </pghead1>-->
    </xsl:if>

    <xsl:if test="credit/credit-words[@default-y &lt; ($pageheight div 2)]">
      <!-- Credits below the middle of the page go in pgfoot. -->
      <pgfoot1>
        <table>
          <xsl:variable name="creditsrepaired">
            <xsl:apply-templates select="credit" mode="repair"/>
          </xsl:variable>
          <xsl:variable name="creditgroup">
            <xsl:copy-of
              select="$creditsrepaired//credit-words[@default-y &lt; ($pageheight div 2)]"
            />
          </xsl:variable>
          <xsl:variable name="creditgroup2">
            <xsl:for-each-group select="$creditgroup//credit-words"
              group-by="@default-y">
              <xsl:sort select="@default-y" order="descending"
                data-type="number"/>
              <tr>
                <xsl:attribute name="y">
                  <xsl:value-of select="@default-y"/>
                </xsl:attribute>
                <xsl:copy-of select="current-group()"/>
              </tr>
            </xsl:for-each-group>
          </xsl:variable>
          <xsl:apply-templates select="$creditgroup2/tr" mode="stage1"/>
        </table>
      </pgfoot1>
    </xsl:if>
  </xsl:template>

  <xsl:template match="credit" mode="repair">
    <!-- A kludgey fix to deal with the fact that not all credits have y coordinates -->
    <credit>
      <xsl:for-each select="credit-words">
        <credit-words>
          <xsl:if test="not(@default-y)">
            <xsl:copy-of
              select="preceding-sibling::credit-words[@default-y][1]/@default-y"
            />
          </xsl:if>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates mode="stage1"/>
        </credit-words>
      </xsl:for-each>
    </credit>
  </xsl:template>

  <xsl:template match="tr" mode="stage1">
    <tr>
      <xsl:copy-of select="@*"/>
      <xsl:for-each select="credit-words[@default-y and @default-x]">
        <!-- Within each row sort the cells in order of appearance across the page. -->
        <xsl:sort select="@default-x" order="ascending" data-type="number"/>
        <td>
          <xsl:attribute name="x">
            <xsl:value-of select="@default-x"/>
          </xsl:attribute>
          <xsl:call-template name="textlanguage"/>
          <xsl:call-template name="fontproperties"/>
          <xsl:for-each
            select="following-sibling::credit-words[not(@default-x)]">
            <!-- When there's no x coordinate on the next credit, make it part of this credit. -->
            <lb/>
            <xsl:call-template name="textlanguage"/>
            <xsl:call-template name="fontproperties"/>
          </xsl:for-each>
        </td>
      </xsl:for-each>
    </tr>
  </xsl:template>

  <xsl:template match="pghead1" mode="stage1">
    <pghead1 xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:for-each select="table">
        <table>
          <xsl:copy-of select="@*"/>
          <xsl:for-each select="tr">
            <xsl:sort select="@y" order="descending" data-type="number"/>
            <tr>
              <xsl:copy-of select="@*"/>
              <xsl:for-each select="td">
                <xsl:sort select="@x" order="ascending" data-type="number"/>
                <xsl:copy-of select="."/>
              </xsl:for-each>
            </tr>
          </xsl:for-each>
        </table>
      </xsl:for-each>
    </pghead1>
  </xsl:template>

  <xsl:template match="pgfoot1" mode="stage1">
    <pgfoot1>
      <xsl:for-each select="table">
        <table>
          <xsl:copy-of select="@*"/>
          <xsl:for-each select="tr">
            <xsl:sort select="@y" order="descending" data-type="number"/>
            <tr>
              <xsl:copy-of select="@*"/>
              <xsl:for-each select="td">
                <xsl:sort select="@x" order="ascending" data-type="number"/>
                <xsl:copy-of select="."/>
              </xsl:for-each>
            </tr>
          </xsl:for-each>
        </table>
      </xsl:for-each>
    </pgfoot1>
  </xsl:template>

  <xsl:template name="profiledesc">
    <xsl:if test="count(distinct-values(//*/@xml:lang)) &gt; 0">
      <profiledesc>
        <langusage>
          <xsl:for-each select="distinct-values(//*/@xml:lang)">
            <!-- Identify all the languages used anywhere in the document. -->
            <language>
              <xsl:attribute name="xml:id">
                <xsl:value-of select="."/>
              </xsl:attribute>
            </language>
          </xsl:for-each>
        </langusage>
      </profiledesc>
    </xsl:if>
  </xsl:template>

  <xsl:template name="fontproperties">
    <!-- When there are typographic properties, wrap a rend sub-element around the content. -->
    <xsl:choose>
      <xsl:when
        test="@font-family|@font-style|@font-size|@font-weight|@justify|@halign|@valign">
        <rend>
          <xsl:if test="@font-family">
            <xsl:attribute name="fontfam">
              <xsl:value-of select="normalize-space(@font-family)"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@font-style">
            <xsl:attribute name="fontstyle">
              <xsl:choose>
                <xsl:when test="lower-case(substring(@font-style,1,4))='ital'">
                  <xsl:text>ital</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="@font-style"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@font-size">
            <xsl:attribute name="fontsize">
              <xsl:value-of select="@font-size"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@font-weight and @font-weight != 'normal'">
            <xsl:attribute name="fontweight">
              <xsl:value-of select="@font-weight"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="@halign">
              <xsl:attribute name="halign">
                <xsl:value-of select="@halign"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="@justify">
              <xsl:attribute name="halign">
                <xsl:value-of select="@justify"/>
              </xsl:attribute>
            </xsl:when>
          </xsl:choose>
          <xsl:if test="@valign">
            <xsl:copy-of select="@valign"/>
          </xsl:if>
          <!-- replace a significant linebreak with <lb/> -->
          <xsl:choose>
            <xsl:when test="contains(.,'&#xA;')">
              <xsl:value-of select="substring-before(.,'&#xA;')"/>
              <lb/>
              <xsl:value-of select="substring-after(.,'&#xA;')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </rend>
      </xsl:when>
      <xsl:otherwise>
        <!-- replace a significant linebreak with <lb/> -->
        <xsl:choose>
          <xsl:when test="contains(.,'&#xA;')">
            <xsl:value-of select="substring-before(.,'&#xA;')"/>
            <lb/>
            <xsl:value-of select="substring-after(.,'&#xA;')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="position">
    <!-- Make positional attributes -->
    <!-- <xsl:if test="@default-x">
      <xsl:attribute name="x"><xsl:value-of select="@default-x div 10"/></xsl:attribute>
    </xsl:if> -->
    <xsl:if test="@relative-x">
      <xsl:attribute name="ho">
        <xsl:value-of select="@relative-x div 10"/>
      </xsl:attribute>
    </xsl:if>
    <!-- <xsl:if test="@default-y">
      <xsl:attribute name="y"><xsl:value-of select="@default-y div 10"/></xsl:attribute>
    </xsl:if> -->
    <xsl:if test="@relative-y">
      <xsl:attribute name="vo">
        <xsl:value-of select="@relative-y div 10"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="textlanguage">
    <!-- Create lang(uage) attribute -->
    <xsl:if test="@xml:lang">
      <xsl:attribute name="xml:lang">
        <xsl:value-of select="@lang"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template match="measure" mode="stage1">
    <!-- Process each measure -->
    <!-- Page breaks and system breaks precede the measure. -->
    <xsl:if test="part[print/@new-page='yes']">
      <pb>
        <xsl:if
          test="normalize-space(part[print/@new-page='yes'][1]/print/@page-number) != ''">
          <xsl:attribute name="n">
            <xsl:value-of
              select="part[print/@new-page='yes'][1]/print/@page-number"/>
          </xsl:attribute>
        </xsl:if>
      </pb>
    </xsl:if>
    <xsl:if test="part[print/@new-system='yes']">
      <sb/>
    </xsl:if>

    <!-- Score-level info precedes the measure. -->
    <xsl:if
      test="part/attributes[not(preceding-sibling::note)][time or key] |
                  part[print/page-layout or print/system-layout]">
      <scoredef>
        <xsl:if test="part/attributes[1]/time">
          <xsl:attribute name="meter.count">
            <xsl:value-of
              select="part[attributes[1]/time/beats][1]/attributes/time/beats"/>
          </xsl:attribute>
          <xsl:attribute name="meter.unit">
            <xsl:value-of
              select="part[attributes[1]/time/beat-type][1]/attributes/time/beat-type"
            />
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="part/attributes[1]/time/@symbol='common'">
              <xsl:attribute name="meter.sym">common</xsl:attribute>
            </xsl:when>
            <xsl:when test="part/attributes[1]/time/@symbol='cut'">
              <xsl:attribute name="meter.sym">cut</xsl:attribute>
            </xsl:when>
            <xsl:when test="part/attributes[1]/time/@symbol='single-number'">
              <xsl:attribute name="meter.rend">denomsym</xsl:attribute>
            </xsl:when>
            <xsl:when test="part/attributes[1]/time/senza-misura">
              <xsl:attribute name="meter.rend">invis</xsl:attribute>
            </xsl:when>
          </xsl:choose>
        </xsl:if>
        <xsl:if test="part/attributes[1]/key">
          <xsl:variable name="keysig">
            <xsl:value-of
              select="part[attributes[not(transpose) and key]][1]/attributes[not(transpose)][1]/key/fifths"
            />
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$keysig=0">
              <xsl:attribute name="key.sig">
                <xsl:value-of select="$keysig"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="$keysig &gt; 0">
              <xsl:attribute name="key.sig"><xsl:value-of select="$keysig"
                />s</xsl:attribute>
            </xsl:when>
            <xsl:when test="$keysig &lt; 0">
              <xsl:attribute name="key.sig">
                <xsl:value-of select="abs($keysig)"/>f</xsl:attribute>
            </xsl:when>
          </xsl:choose>
          <xsl:if test="part[1]/attributes[1]/key/mode">
            <xsl:attribute name="key.mode">
              <xsl:value-of select="part[1]/attributes[1]/key/mode"/>
            </xsl:attribute>
          </xsl:if>
        </xsl:if>

        <!-- Page layout info precedes the measure. -->
        <xsl:for-each select="part[print/page-layout][1]/print/page-layout">
          <xsl:for-each select="page-height">
            <xsl:attribute name="page.height">
              <xsl:value-of select="."/>
            </xsl:attribute>
          </xsl:for-each>
          <xsl:for-each select="page-width">
            <xsl:attribute name="page.width">
              <xsl:value-of select="."/>
            </xsl:attribute>
          </xsl:for-each>
          <xsl:for-each select="page-margins">
            <xsl:attribute name="page.leftmar">
              <xsl:value-of select="left-margin"/>
            </xsl:attribute>
            <xsl:attribute name="page.rightmar">
              <xsl:value-of select="right-margin"/>
            </xsl:attribute>
            <xsl:attribute name="page.topmar">
              <xsl:value-of select="top-margin"/>
            </xsl:attribute>
            <xsl:attribute name="page.botmar">
              <xsl:value-of select="bottom-margin"/>
            </xsl:attribute>
          </xsl:for-each>
        </xsl:for-each>

        <!-- System layout info precedes the measure. -->
        <xsl:for-each select="part[print/system-layout][1]/print/system-layout">
          <xsl:for-each select="system-margins">
            <xsl:attribute name="system.leftmar">
              <xsl:value-of select="left-margin"/>
            </xsl:attribute>
            <xsl:attribute name="system.rightmar">
              <xsl:value-of select="right-margin"/>
            </xsl:attribute>
          </xsl:for-each>
          <xsl:for-each select="system-distance">
            <xsl:attribute name="spacing.system">
              <xsl:value-of select="."/>
            </xsl:attribute>
          </xsl:for-each>
          <xsl:for-each select="top-system-distance">
            <xsl:attribute name="system.topmar">
              <xsl:value-of select="."/>
            </xsl:attribute>
          </xsl:for-each>
        </xsl:for-each>
      </scoredef>
    </xsl:if>

    <!-- Staff-level info precedes the measure. This process can result in multiple declarations for
         the same staff. -->
    <xsl:for-each select="part">
      <xsl:variable name="partID">
        <xsl:value-of select="@id"/>
      </xsl:variable>
      <xsl:for-each
        select="attributes[not(preceding-sibling::note) and not(preceding-sibling::forward)][1]">
        <!-- Use 'attributes' elements that precede all note and forward elements. -->
        <xsl:choose>
          <xsl:when test="clef">
            <!-- Record clef(s) -->
            <xsl:for-each select="clef">
              <xsl:sort select="@number"/>
              <staffdef>
                <xsl:variable name="clefnum">
                  <xsl:choose>
                    <xsl:when test="@number">
                      <xsl:value-of select="@number"/>
                    </xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:attribute name="n">
                  <xsl:call-template name="getstaffnum">
                    <xsl:with-param name="partID">
                      <xsl:value-of select="$partID"/>
                    </xsl:with-param>
                    <xsl:with-param name="partstaff">
                      <xsl:value-of select="$clefnum"/>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:attribute>
                <xsl:choose>
                  <xsl:when test="sign='percussion'">
                    <xsl:attribute name="clef.shape">perc</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="sign='TAB'">
                    <xsl:attribute name="clef.shape">TAB</xsl:attribute>
                    <xsl:attribute name="tab.strings">
                      <xsl:variable name="tabstrings">
                        <xsl:for-each select="following-sibling::staff-details">
                          <xsl:for-each select="staff-tuning">
                            <xsl:sort select="@line" order="descending"/>
                            <xsl:variable name="thisstring">
                              <xsl:value-of select="tuning-step"/>
                            </xsl:variable>
                            <xsl:value-of
                              select="translate(tuning-step,'ABCDEFG','abcdefg')"/>
                            <xsl:for-each
                              select="following-sibling::staff-tuning/tuning-step[.=$thisstring]">
                              <xsl:text>'</xsl:text>
                            </xsl:for-each>
                            <xsl:value-of select="tuning-octave"/>
                            <xsl:text> </xsl:text>
                          </xsl:for-each>
                        </xsl:for-each>
                      </xsl:variable>
                      <xsl:value-of select="normalize-space($tabstrings)"/>
                    </xsl:attribute>
                    <xsl:if test="following-sibling::staff-details/capo">
                      <xsl:attribute name="trans.semi">
                        <xsl:value-of
                          select="following-sibling::staff-details/capo"/>
                      </xsl:attribute>
                    </xsl:if>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="lines">
                      <xsl:choose>
                        <xsl:when test="staff-details/staff-lines">
                          <xsl:value-of select="staff-details/staff-lines"/>
                        </xsl:when>
                        <xsl:otherwise>5</xsl:otherwise>
                      </xsl:choose>
                    </xsl:attribute>
                    <xsl:attribute name="clef.line">
                      <xsl:value-of select="line"/>
                    </xsl:attribute>
                    <xsl:attribute name="clef.shape">
                      <xsl:value-of select="sign"/>
                    </xsl:attribute>
                    <xsl:if test="clef-octave-change">
                      <xsl:if test="abs(number(clef-octave-change)) != 0">
                        <xsl:attribute name="clef.trans">
                          <xsl:choose>
                            <xsl:when test="clef-octave-change = '2'"
                              >15va</xsl:when>
                            <xsl:when test="clef-octave-change = '1'"
                              >8va</xsl:when>
                            <xsl:when test="clef-octave-change = '-1'"
                              >8vb</xsl:when>
                            <xsl:when test="clef-octave-change = '-2'"
                              >15vb</xsl:when>
                          </xsl:choose>
                        </xsl:attribute>
                      </xsl:if>
                    </xsl:if>
                  </xsl:otherwise>
                </xsl:choose>

                <!-- MIDI divisions are set per staff. -->
                <xsl:if test="../divisions">
                  <xsl:attribute name="ppq">
                    <xsl:value-of select="../divisions"/>
                  </xsl:attribute>
                </xsl:if>

                <!-- Set key sig and mode on each staff -->
                <xsl:if test="../key">
                  <xsl:variable name="keysig">
                    <xsl:value-of select="../key/fifths"/>
                  </xsl:variable>
                  <xsl:choose>
                    <xsl:when test="$keysig=0">
                      <xsl:attribute name="key.sig">
                        <xsl:value-of select="$keysig"/>
                      </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$keysig &gt; 0">
                      <xsl:attribute name="key.sig"><xsl:value-of
                          select="$keysig"/>s</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$keysig &lt; 0">
                      <xsl:attribute name="key.sig"><xsl:value-of
                          select="abs($keysig)"/>f</xsl:attribute>
                    </xsl:when>
                  </xsl:choose>
                </xsl:if>
                <xsl:if test="../key/mode">
                  <xsl:attribute name="key.mode">
                    <xsl:value-of select="../key/mode"/>
                  </xsl:attribute>
                </xsl:if>

                <!-- Handle transposed staves, including those transposed by octave -->
                <xsl:if test="../transpose">
                  <xsl:attribute name="trans.semi">
                    <xsl:choose>
                      <xsl:when test="../transpose/octave-change">
                        <xsl:variable name="octavechange">
                          <xsl:value-of select="../transpose/octave-change"/>
                        </xsl:variable>
                        <xsl:variable name="chromatic">
                          <xsl:value-of select="../transpose/chromatic"/>
                        </xsl:variable>
                        <xsl:value-of select="$chromatic + (12 * $octavechange)"
                        />
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="../transpose/chromatic"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                  <xsl:if test="../transpose/diatonic">
                    <xsl:attribute name="trans.diat">
                      <xsl:value-of select="../transpose/diatonic"/>
                    </xsl:attribute>
                  </xsl:if>
                </xsl:if>
                <xsl:comment>derp</xsl:comment>
              </staffdef>
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="divisions or transpose">
            <staffdef>
              <xsl:if test="divisions">
                <xsl:attribute name="ppq">
                  <xsl:value-of select="divisions"/>
                </xsl:attribute>
              </xsl:if>

              <xsl:if test="transpose">
                <xsl:attribute name="trans.semi">
                  <xsl:choose>
                    <xsl:when test="transpose/octave-change">
                      <xsl:variable name="octavechange">
                        <xsl:value-of select="transpose/octave-change"/>
                      </xsl:variable>
                      <xsl:variable name="chromatic">
                        <xsl:value-of select="transpose/chromatic"/>
                      </xsl:variable>
                      <xsl:value-of select="$chromatic + (12 * $octavechange)"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="transpose/chromatic"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
                <xsl:if test="transpose/diatonic">
                  <xsl:attribute name="trans.diat">
                    <xsl:value-of select="transpose/diatonic"/>
                  </xsl:attribute>
                </xsl:if>
              </xsl:if>
            </staffdef>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>

      <!-- Staff layout info precedes the measure -->
      <xsl:for-each select="print/staff-layout">
        <xsl:sort select="@number"/>
        <staffdef>
          <xsl:variable name="clefnum">
            <xsl:choose>
              <xsl:when test="@number">
                <xsl:value-of select="@number"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="n">
            <xsl:call-template name="getstaffnum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partstaff">
                <xsl:value-of select="$clefnum"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="spacing">
            <xsl:value-of select="staff-distance"/>
          </xsl:attribute>
        </staffdef>
      </xsl:for-each>
    </xsl:for-each>

    <!-- Hold the measure in $measure for later processing -->
    <xsl:variable name="measure">
      <measure>
        <!-- Measure attributes -->
        <xsl:if test="@implicit='yes'">
          <xsl:attribute name="complete">i</xsl:attribute>
        </xsl:if>
        <!-- DUCHEMIN - need alphanumeric measure numbers! -->
        <xsl:attribute name="n">
          <xsl:value-of select="@number"/>
        </xsl:attribute>
        <!--<xsl:analyze-string select="normalize-space(@number)" regex="^([0-9]+)$">
          <xsl:matching-substring>
            <xsl:attribute name="n">
              <xsl:value-of select="regex-group(1)"/>
            </xsl:attribute>
          </xsl:matching-substring>
        </xsl:analyze-string>-->
        <xsl:attribute name="xml:id">
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when
            test="following-sibling::measure[1]/part/barline[@location='left']/bar-style">
            <!-- When the *following measure* has its left barline attribute set, also set the right
               attribute on *this* measure -->
            <xsl:variable name="barstyle">
              <xsl:value-of
                select="following-sibling::measure[1]/part[1]/barline/bar-style"
              />
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$barstyle='dotted'">
                <xsl:attribute name="right">dotted</xsl:attribute>
              </xsl:when>
              <xsl:when test="$barstyle='dashed'">
                <xsl:attribute name="right">dashed</xsl:attribute>
              </xsl:when>
              <xsl:when test="$barstyle='light-light'">
                <xsl:attribute name="right">dbl</xsl:attribute>
              </xsl:when>
              <xsl:when test="$barstyle='heavy-light'">
                <xsl:choose>
                  <xsl:when
                    test="following-sibling::measure[1]/part/barline/repeat/@direction='forward'">
                    <xsl:choose>
                      <xsl:when test="part/barline/repeat/@direction='backward'">
                        <xsl:attribute name="right">rptboth</xsl:attribute>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:attribute name="right">rptstart</xsl:attribute>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="right">dbl</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="$barstyle='light-heavy'">
                <xsl:choose>
                  <xsl:when test="part/barline/repeat/@direction='backward'">
                    <xsl:attribute name="right">rptend</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="right">end</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="$barstyle='heavy-heavy'">
                <xsl:choose>
                  <xsl:when
                    test="part/barline/repeat/@direction='backward' and following-sibling::measure[1]/part/barline/repeat/@direction='forward'">
                    <xsl:attribute name="right">rptboth</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="right">dbl</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="$barstyle='none'">
                <xsl:attribute name="right">invis</xsl:attribute>
              </xsl:when>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="part/barline[@location='right']/bar-style">
            <!-- Set this measure's right attribute -->
            <xsl:variable name="barstyle">
              <xsl:value-of select="part[1]/barline/bar-style"/>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$barstyle='dotted'">
                <xsl:attribute name="right">dotted</xsl:attribute>
              </xsl:when>
              <xsl:when test="$barstyle='dashed'">
                <xsl:attribute name="right">dashed</xsl:attribute>
              </xsl:when>
              <xsl:when test="$barstyle='light-light'">
                <xsl:attribute name="right">dbl</xsl:attribute>
              </xsl:when>
              <xsl:when test="$barstyle='light-heavy'">
                <xsl:choose>
                  <xsl:when test="part/barline/repeat/@direction='backward'">
                    <xsl:choose>
                      <xsl:when
                        test="following-sibling::measure[1]/part/barline/repeat/@direction='forward'">
                        <xsl:attribute name="right">rptboth</xsl:attribute>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:attribute name="right">rptend</xsl:attribute>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="right">end</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="$barstyle='heavy-light'">
                <xsl:choose>
                  <xsl:when
                    test="following-sibling::measure[1]/part/barline/repeat[@direction='forward']">
                    <xsl:attribute name="right">rptstart</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="right">dbl</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="$barstyle='heavy-heavy'">
                <xsl:choose>
                  <xsl:when
                    test="part/barline/repeat[@direction='backward'] and following-sibling::measure[1]/part/barline/repeat[@direction='forward']">
                    <xsl:attribute name="right">rptboth</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="right">dbl</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="$barstyle='none'">
                <xsl:attribute name="right">invis</xsl:attribute>
              </xsl:when>
            </xsl:choose>
          </xsl:when>
          <!-- This stylesheet doesn't handle a barline in the middle of a measure -->
        </xsl:choose>

        <xsl:if test="part/barline[@location='left']/bar-style">
          <!-- Set this measure's left attribute -->
          <xsl:variable name="lbarstyle">
            <xsl:value-of select="part/barline/bar-style"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$lbarstyle='dotted'">
              <xsl:attribute name="left">dotted</xsl:attribute>
            </xsl:when>
            <xsl:when test="$lbarstyle='dashed'">
              <xsl:attribute name="left">dashed</xsl:attribute>
            </xsl:when>
            <xsl:when test="$lbarstyle='light-light'">
              <xsl:attribute name="left">dbl</xsl:attribute>
            </xsl:when>
            <xsl:when test="$lbarstyle='light-heavy'">
              <xsl:choose>
                <xsl:when test="part/barline/repeat/@direction='backward'">
                  <xsl:choose>
                    <xsl:when
                      test="preceding-sibling::measure[1]/part/barline/repeat/@direction='backward'">
                      <xsl:attribute name="left">rptend</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:attribute name="left">end</xsl:attribute>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="right">end</xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="$lbarstyle='heavy-light'">
              <xsl:choose>
                <xsl:when test="part/barline/repeat/@direction='forward'">
                  <xsl:attribute name="left">rptstart</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="left">dbl</xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="$lbarstyle='heavy-heavy'">
              <xsl:choose>
                <xsl:when
                  test="part/barline/repeat/@direction='forward' and preceding-sibling::measure[1]/part/barline/repeat/@direction='backward'">
                  <xsl:attribute name="left">rptboth</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="left">dbl</xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="$lbarstyle='none'">
              <xsl:attribute name="left">invis</xsl:attribute>
            </xsl:when>
          </xsl:choose>
        </xsl:if>
        
        <!-- Occasionally bar-style is not present, in which case: -->
        <xsl:if test="part/barline[@location='left'][repeat]">
          <!-- Set this measure's left attribute -->
            <xsl:choose>
              <xsl:when test="part/barline/repeat/@direction='forward'">
                <xsl:attribute name="left">rptstart</xsl:attribute>
              </xsl:when>
              <xsl:when
                test="part/barline/repeat/@direction='forward' and preceding-sibling::measure[1]/part/barline/repeat/@direction='backward'">
                <xsl:attribute name="left">rptboth</xsl:attribute>
              </xsl:when>
            </xsl:choose>
        </xsl:if>
        
        <xsl:if test="part/barline[@location='right'][repeat]">
          <!-- Set this measure's right attribute -->
          <xsl:choose>
            <xsl:when test="part/barline/repeat/@direction='backward'">
              <xsl:attribute name="right">rptend</xsl:attribute>
            </xsl:when>
            <xsl:when
              test="part/barline/repeat/@direction='backward' and following-sibling::measure[1]/part/barline/repeat/@direction='forward'">
              <xsl:attribute name="right">rptboth</xsl:attribute>
            </xsl:when>
          </xsl:choose>
        </xsl:if>

        <xsl:if test="@width">
          <!-- If it exists, grab the measure width -->
          <xsl:attribute name="width">
            <xsl:value-of select="@width"/>
          </xsl:attribute>
        </xsl:if>

        <!-- Process measure contents -->
        <xsl:for-each select="part">
          <!-- Events  -->
          <xsl:for-each-group
            select="note[not(chord)]|backup|attributes|forward"
            group-ending-with="backup">
            <xsl:apply-templates select="current-group()" mode="stage1"/>
          </xsl:for-each-group>
        </xsl:for-each>

        <xsl:for-each select="part">
          <!-- Control events -->
          <xsl:variable name="controlevents">
            <xsl:apply-templates select="note/notations/articulations/caesura"
              mode="stage1"/>
            <xsl:apply-templates select="note/notations/dynamics" mode="stage1"/>
            <xsl:apply-templates select="direction" mode="stage1"/>
            <xsl:apply-templates select="note/notations/tuplet[@type='start']"
              mode="stage1"/>
            <xsl:apply-templates
              select="note/notations/slur[@type='start' or @type='continue']"
              mode="stage1"/>
            <xsl:apply-templates select="note/notations/tied[@type='start']"
              mode="stage1"/>
            <xsl:apply-templates select="note/notations/fermata" mode="stage1"/>
            <xsl:apply-templates select="note/notations/ornaments" mode="stage1"/>
            <xsl:apply-templates
              select="note[not(chord) and notations/arpeggiate]" mode="arpeg"/>
            <xsl:apply-templates select="harmony" mode="stage1"/>
            <xsl:apply-templates
              select="note/notations/technical/pull-off[@type='start']"
              mode="stage1"/>
          </xsl:variable>
          <xsl:for-each select="$controlevents/*">
            <!-- For ease of reading, sort the control events on the tstamp.ges attribute. -->
            <xsl:sort select="@tstamp.ges" data-type="number"/>
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </xsl:for-each>
      </measure>
    </xsl:variable>

    <!-- Further process $measure -->
    <xsl:for-each select="$measure/measure">
      <measure>
        <xsl:copy-of select="@*"/>
        <!-- Create temporary part elements for use in the step below -->
        <xsl:for-each-group select="chord|clefchange|note|rest|space|mrest"
          group-by="@part">
          <xsl:variable name="partorg">
            <part>
              <xsl:attribute name="n">
                <xsl:value-of select="current-grouping-key()"/>
              </xsl:attribute>
              <xsl:for-each-group select="current-group()" group-by="@layer">
                <layer>
                  <xsl:attribute name="n">
                    <xsl:value-of select="current-grouping-key()"/>
                  </xsl:attribute>
                  <xsl:copy-of select="current-group()"/>
                </layer>
              </xsl:for-each-group>
            </part>
          </xsl:variable>

          <!-- Further process $partorg: create staff and layer elements. -->
          <xsl:variable name="stafforg">
            <xsl:for-each select="$partorg/part">
              <xsl:variable name="thispart">
                <xsl:value-of select="@n"/>
              </xsl:variable>
              <xsl:for-each select="layer">
                <xsl:variable name="thislayer">
                  <xsl:value-of select="@n"/>
                </xsl:variable>
                <xsl:variable name="staves">
                  <xsl:value-of select="distinct-values(*/@staff)"/>
                </xsl:variable>
                <xsl:variable name="countstaves">
                  <xsl:value-of select="count(distinct-values(*/@staff))"/>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="$countstaves=1">
                    <!-- The 'voice' lies on a single staff -->
                    <xsl:for-each select="distinct-values(*/@staff)">
                      <staff>
                        <xsl:attribute name="n">
                          <xsl:value-of select="."/>
                        </xsl:attribute>
                        <xsl:copy-of
                          select="$partorg/part[@n=$thispart]/layer[@n=$thislayer]/*"
                        />
                      </staff>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- The 'voice' crosses staves -->
                    <xsl:for-each select="distinct-values(*/@staff)">
                      <xsl:variable name="thisstaff">
                        <xsl:value-of select="."/>
                      </xsl:variable>
                      <staff>
                        <xsl:attribute name="n">
                          <xsl:value-of select="$thisstaff"/>
                        </xsl:attribute>
                        <xsl:for-each
                          select="$partorg/part[@n=$thispart]/layer[@n=$thislayer]/*[name()='note' or name()='chord' or name()='rest' or name()='pad' or name()='space' or name()='clefchange']">
                          <!-- Fill the unused time on 'the other staff' with space -->
                          <xsl:choose>
                            <xsl:when test="@staff=$thisstaff">
                              <xsl:copy-of select="."/>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:apply-templates select="." mode="insertspace"
                              />
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:for-each>
                      </staff>
                    </xsl:for-each>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:for-each>
          </xsl:variable>

          <!-- Further process $stafforg: sort by staff, then by layer -->
          <xsl:variable name="stafforg2">
            <xsl:for-each select="$stafforg/staff">
              <xsl:sort select="@n"/>
              <staff>
                <xsl:copy-of select="@*"/>
                <xsl:for-each-group select="child::*" group-by="@layer">
                  <xsl:sort select="current-grouping-key()"/>
                  <layer>
                    <xsl:attribute name="n">
                      <xsl:value-of select="current-grouping-key()"/>
                    </xsl:attribute>
                    <xsl:copy-of select="current-group()"/>
                  </layer>
                </xsl:for-each-group>
              </staff>
            </xsl:for-each>
          </xsl:variable>

          <!-- Further process $stafforg2: create beam elements -->
          <xsl:variable name="stafforg3">
            <xsl:for-each-group select="$stafforg2/staff" group-by="@n">
              <xsl:variable name="thisstaff">
                <xsl:value-of select="current-grouping-key()"/>
              </xsl:variable>
              <xsl:variable name="stafflayer">
                <staff>
                  <xsl:copy-of select="@*"/>
                  <xsl:copy-of select="$stafforg2/staff[@n=$thisstaff]/layer"/>
                </staff>
              </xsl:variable>
              <xsl:for-each select="$stafflayer/staff">
                <staff>
                  <xsl:copy-of select="@*"/>
                  <xsl:for-each select="layer">
                    <xsl:sort select="@n"/>
                    <layer>
                      <xsl:copy-of select="@*[not(name()='n')]"/>
                      <xsl:attribute name="n">
                        <xsl:value-of select="position()"/>
                      </xsl:attribute>
                      <xsl:if test="*[@tstamp.ges][1]/@tstamp.ges != 0">
                        <!-- If the 1st event in the layer doesn't have a timestamp of 0, insert space. -->
                        <space>
                          <xsl:attribute name="xml:id">
                            <xsl:value-of
                              select="generate-id(*[@tstamp.ges][1]/@tstamp.ges)"
                            />
                          </xsl:attribute>
                          <xsl:attribute name="tstamp.ges">0</xsl:attribute>
                          <xsl:attribute name="dur.ges">
                            <xsl:value-of select="*[@tstamp.ges][1]/@tstamp.ges"
                            />
                          </xsl:attribute>
                        </space>
                      </xsl:if>
                      <xsl:for-each select="*">
                        <xsl:choose>
                          <xsl:when test="starts-with(@beam,'i')">
                            <xsl:text>&startbeam;</xsl:text>
                            <xsl:apply-templates select="." mode="dropattrs"/>
                          </xsl:when>
                          <xsl:when test="starts-with(@beam,'t')">
                            <xsl:apply-templates select="." mode="dropattrs"/>
                            <xsl:text>&endbeam;</xsl:text>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:apply-templates select="." mode="dropattrs"/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:for-each>
                    </layer>
                  </xsl:for-each>
                </staff>
              </xsl:for-each>
            </xsl:for-each-group>
          </xsl:variable>

          <!-- Emit the final results -->
          <xsl:copy-of select="$stafforg3"/>

        </xsl:for-each-group>

        <!-- Copy controlevents -->
        <xsl:copy-of
          select="annot|arpeg|beamspan|bend|dir|dynam|fermata|gliss|hairpin|
                  harm|lyrics|midi|mordent|octave|pedal|reh|slur|tempo|tie|
                  trill|tupletspan|turn"/>

        <!-- Copy graphic primitives -->
        <xsl:copy-of select="curve|line"/>

      </measure>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="*" mode="dropattrs">
    <!-- Drop unnecesssary attributes -->
    <xsl:variable name="thiselement">
      <xsl:value-of select="name()"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="name()='space'">
        <xsl:element name="{$thiselement}">
          <xsl:copy-of
            select="@*[name()!='part' and name()!='staff' and name()!='layer']"/>
          <xsl:if test="@staff != ancestor::staff[1]/@n">
            <xsl:copy-of select="@staff"/>
          </xsl:if>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{$thiselement}">
          <xsl:copy-of
            select="@*[name()!='part' and name()!='staff' and name()!='layer']"/>
          <xsl:copy-of select="child::*"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*" mode="insertspace">
    <!-- Insert a time-filling space -->
    <xsl:if test="not(@grace)">
      <space>
        <xsl:attribute name="xml:id">
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
        <xsl:copy-of select="@tstamp.ges|@dur.ges|@part|@layer|@staff"/>
        <xsl:choose>
          <xsl:when test="@beam">
            <xsl:copy-of select="@beam"/>
          </xsl:when>
          <xsl:when test="*[@beam]">
            <xsl:copy-of select="*[@beam][1]/@beam"/>
          </xsl:when>
        </xsl:choose>
      </space>
    </xsl:if>
  </xsl:template>

  <xsl:template name="getsyldur">
    <!-- Find the terminating note of a syllable -->
    <xsl:param name="syldur"/>
    <xsl:variable name="thisdur">
      <xsl:value-of select="duration"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="following-sibling::note[1][not(lyric) and not(grace)]">
        <xsl:variable name="nextdur">
          <xsl:value-of
            select="following-sibling::note[1][not(lyric) and not(grace)]/duration"
          />
        </xsl:variable>
        <xsl:variable name="totaldur">
          <xsl:value-of select="$syldur + $nextdur"/>
        </xsl:variable>
        <xsl:for-each
          select="following-sibling::note[1][not(lyric) and not(grace)]">
          <xsl:call-template name="getsyldur">
            <xsl:with-param name="syldur">
              <xsl:value-of select="$totaldur"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$syldur"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="pull-off" mode="stage1">
    <!-- In MEI a pull off is a directive -->
    <dir>
      <xsl:attribute name="tstamp.ges">
        <xsl:for-each select="ancestor::note[1]">
          <xsl:call-template name="gettstamp.ges"/>
        </xsl:for-each>
      </xsl:attribute>
      <xsl:attribute name="place">
        <xsl:choose>
          <xsl:when test="@placement != ''">
            <xsl:value-of select="@placement"/>
          </xsl:when>
          <xsl:otherwise>above</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:variable name="partID">
        <xsl:value-of select="ancestor::part[1]/@id"/>
      </xsl:variable>
      <xsl:variable name="partstaff">
        <xsl:choose>
          <xsl:when test="ancestor::note[1]/staff">
            <xsl:value-of select="ancestor::note[1]/staff"/>
          </xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:attribute name="staff">
        <xsl:call-template name="getstaffnum">
          <xsl:with-param name="partID">
            <xsl:value-of select="$partID"/>
          </xsl:with-param>
          <xsl:with-param name="partstaff">
            <xsl:value-of select="$partstaff"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:attribute name="startid">
        <xsl:for-each select="ancestor::note[1]">
          <xsl:value-of select="generate-id()"/>
        </xsl:for-each>
      </xsl:attribute>
      <xsl:attribute name="endid">
        <xsl:choose>
          <xsl:when test="@number">
            <xsl:variable name="level">
              <xsl:value-of select="@number"/>
            </xsl:variable>
            <xsl:for-each
              select="following::pull-off[@type='stop' and @number=$level][1]">
              <xsl:for-each select="ancestor::note[1]">
                <xsl:value-of select="generate-id()"/>
              </xsl:for-each>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="following::pull-off[@type='stop'][1]">
              <xsl:for-each select="ancestor::note[1]">
                <xsl:attribute name="endid">
                  <xsl:value-of select="generate-id()"/>
                </xsl:attribute>
              </xsl:for-each>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="dur">
        <xsl:call-template name="getdurpulloff"/>
      </xsl:attribute>
      <xsl:call-template name="position"/>
      <xsl:value-of select="."/>
    </dir>
  </xsl:template>

  <xsl:template match="direction" mode="stage1">
    <!-- Make appropriate MEI elements.  Some MusicXML direction types (brackets, coda, dashes,
         damp, damp-all, eyeglasses, harp-pedals, and scordatura) are not handled yet. -->
    <xsl:for-each select="direction-type">
      <xsl:if test="bracket">
        <!-- MusicXML uses time stamps for brackets, while MEI uses xy coordinates! -->

        <xsl:for-each select="bracket[@type='start']">
          <xsl:variable name="number">
            <xsl:value-of select="@number"/>
          </xsl:variable>
          <line type="bracket">
            <xsl:choose>
              <xsl:when test="@line-type='solid'">
                <xsl:attribute name="rend">narrow</xsl:attribute>
              </xsl:when>
              <xsl:when test="@line-type">
                <xsl:attribute name="rend">
                  <xsl:value-of select="@line-type"/>
                </xsl:attribute>
              </xsl:when>
            </xsl:choose>
            <xsl:attribute name="x"/>
            <xsl:attribute name="y"/>
            <xsl:for-each
              select="following::bracket[@type='stop' and @number=$number][1]">
              <xsl:attribute name="x2"/>
              <xsl:attribute name="y2"/>
            </xsl:for-each>
          </line>
          <xsl:if test="@line-end">
            <line type="start-hook">
              <xsl:choose>
                <xsl:when test="@line-type='solid'">
                  <xsl:attribute name="rend">narrow</xsl:attribute>
                </xsl:when>
                <xsl:when test="@line-type">
                  <xsl:attribute name="rend">
                    <xsl:value-of select="@line-type"/>
                  </xsl:attribute>
                </xsl:when>
              </xsl:choose>
              <xsl:attribute name="x"/>
              <xsl:attribute name="x2"/>
              <xsl:attribute name="y"/>
              <xsl:attribute name="y2"/>
            </line>
          </xsl:if>
          <xsl:for-each
            select="following::bracket[@type='stop' and @number=$number][1]">
            <xsl:if test="@line-end">
              <line type="end-hook">
                <xsl:choose>
                  <xsl:when
                    test="preceding::bracket[@type='start' and @number=$number][1]/@line-type='solid'">
                    <xsl:attribute name="rend">narrow</xsl:attribute>
                  </xsl:when>
                  <xsl:when
                    test="preceding::bracket[@type='start' and @number=$number][1]/@line-type">
                    <xsl:attribute name="rend">
                      <xsl:value-of
                        select="preceding::bracket[@type='start' and @number=$number][1]/@line-type"
                      />
                    </xsl:attribute>
                  </xsl:when>
                </xsl:choose>
                <xsl:attribute name="x"/>
                <xsl:attribute name="x2"/>
                <xsl:attribute name="y"/>
                <xsl:attribute name="y2"/>
              </line>
            </xsl:if>
          </xsl:for-each>
        </xsl:for-each>

      </xsl:if>
      <xsl:if test="coda"> </xsl:if>
      <xsl:if test="dashes">
        <!-- Same as brackets -->
      </xsl:if>
      <xsl:if test="damp"> </xsl:if>
      <xsl:if test="damp-all"> </xsl:if>
      <xsl:if test="dynamics">
        <dynam>
          <xsl:attribute name="tstamp.ges">
            <xsl:for-each select="ancestor::direction[1]">
              <xsl:call-template name="gettstamp.ges"/>
            </xsl:for-each>
          </xsl:attribute>
          <xsl:attribute name="place">
            <xsl:choose>
              <xsl:when test="ancestor::direction/@placement != ''">
                <xsl:value-of select="ancestor::direction/@placement"/>
              </xsl:when>
              <xsl:otherwise>below</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:if test="ancestor::direction/offset">
            <xsl:attribute name="startto">
              <xsl:value-of select="ancestor::direction/offset"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:variable name="partID">
            <xsl:value-of select="ancestor::part[1]/@id"/>
          </xsl:variable>
          <xsl:variable name="partstaff">
            <xsl:choose>
              <xsl:when test="../staff">
                <xsl:value-of select="../staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="staff">
            <xsl:call-template name="getstaffnum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partstaff">
                <xsl:value-of select="$partstaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:for-each select="dynamics">
            <xsl:call-template name="position"/>
            <xsl:choose>
              <xsl:when test="@font-family|@font-style|@font-size|@font-weight">
                <rend>
                  <xsl:if test="../@font-family">
                    <xsl:attribute name="fontfam">
                      <xsl:value-of select="normalize-space(../@font-family)"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="../@font-style">
                    <xsl:attribute name="fontstyle">
                      <xsl:choose>
                        <xsl:when
                          test="lower-case(substring(../@font-style,1,4))='ital'">
                          <xsl:text>ital</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="../@font-style"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="../@font-size">
                    <xsl:attribute name="fontsize">
                      <xsl:value-of select="../@font-size"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="../@font-weight and ../@font-weight != 'normal'">
                    <xsl:attribute name="fontweight">
                      <xsl:value-of select="../@font-weight"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:for-each select="*">
                    <xsl:choose>
                      <xsl:when test="name()='other-dynamics'">
                        <xsl:value-of select="."/>
                        <xsl:if test="position() != last()">
                          <xsl:text> </xsl:text>
                        </xsl:if>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="name()"/>
                        <xsl:if test="position() != last()">
                          <xsl:text> </xsl:text>
                        </xsl:if>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each>
                </rend>
              </xsl:when>
              <xsl:otherwise>
                <xsl:for-each select="*">
                  <xsl:choose>
                    <xsl:when test="name()='other-dynamics'">
                      <xsl:value-of select="."/>
                      <xsl:if test="position() != last()">
                        <xsl:text> </xsl:text>
                      </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="name()"/>
                      <xsl:if test="position() != last()">
                        <xsl:text> </xsl:text>
                      </xsl:if>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </dynam>
      </xsl:if>
      <xsl:if test="eyeglasses"> </xsl:if>
      <xsl:if test="harp-pedals"> </xsl:if>
      <xsl:if test="metronome">
        <tempo>
          <xsl:attribute name="tstamp.ges">
            <xsl:for-each select="ancestor::direction[1]">
              <xsl:call-template name="gettstamp.ges"/>
            </xsl:for-each>
          </xsl:attribute>
          <xsl:attribute name="place">
            <xsl:choose>
              <xsl:when test="ancestor::direction/@placement != ''">
                <xsl:value-of select="ancestor::direction/@placement"/>
              </xsl:when>
              <xsl:otherwise>above</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:variable name="partID">
            <xsl:value-of select="ancestor::part[1]/@id"/>
          </xsl:variable>
          <xsl:variable name="partstaff">
            <xsl:choose>
              <xsl:when test="ancestor::note[1]/staff">
                <xsl:value-of select="ancestor::note[1]/staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="staff">
            <xsl:call-template name="getstaffnum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partstaff">
                <xsl:value-of select="$partstaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:for-each select="metronome">
            <xsl:call-template name="position"/>
          </xsl:for-each>
          <xsl:choose>
            <xsl:when
              test="metronome/@font-family or
                            metronome/@font-size or
                            metronome/@font-style='italic' or
                            metronome/@font-weight">
              <rend>
                <xsl:if test="metronome/@font-family">
                  <xsl:attribute name="fontfam">
                    <xsl:value-of
                      select="normalize-space(metronome/@font-family)"/>
                  </xsl:attribute>
                </xsl:if>
                <xsl:if test="metronome/@font-size">
                  <xsl:attribute name="fontsize">
                    <xsl:value-of select="metronome/@font-size"/>
                  </xsl:attribute>
                </xsl:if>
                <xsl:if test="metronome/@font-style='italic'">
                  <xsl:attribute name="fontstyle">ital</xsl:attribute>
                </xsl:if>
                <xsl:if test="metronome/@font-weight='bold'">
                  <xsl:attribute name="fontweight">bold</xsl:attribute>
                </xsl:if>
                <xsl:if test="metronome/@parentheses='yes'">
                  <xsl:text>(</xsl:text>
                </xsl:if>
                <xsl:for-each select="metronome/beat-unit">
                  <xsl:call-template name="beatunitdur"/>
                </xsl:for-each>
                <xsl:if test="metronome/beat-unit-dot">
                  <xsl:text>.</xsl:text>
                </xsl:if>
                <xsl:text>=</xsl:text>
                <xsl:value-of select="metronome/per-minute"/>
                <xsl:if test="metronome/@parentheses='yes'">
                  <xsl:text>)</xsl:text>
                </xsl:if>
              </rend>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="metronome/@parentheses='yes'">
                <xsl:text>(</xsl:text>
              </xsl:if>
              <xsl:for-each select="metronome/beat-unit">
                <xsl:call-template name="beatunitdur"/>
              </xsl:for-each>
              <xsl:if test="metronome/beat-unit-dot">
                <xsl:text>.</xsl:text>
              </xsl:if>
              <xsl:text>=</xsl:text>
              <xsl:value-of select="metronome/per-minute"/>
              <xsl:if test="metronome/@parentheses='yes'">
                <xsl:text>)</xsl:text>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </tempo>
      </xsl:if>
      <xsl:if test="octave-shift[not(@type='stop')]">
        <!-- Octave-shift is 'backwards', i.e. indicates written instead of sounding octave.
             Encoded pitches are subject to whether or not an octave-shift is in force. -->
        <octave>
          <xsl:attribute name="tstamp.ges">
            <xsl:for-each select="ancestor::direction[1]">
              <xsl:call-template name="gettstamp.ges"/>
            </xsl:for-each>
          </xsl:attribute>
          <xsl:attribute name="dis">
            <xsl:value-of select="octave-shift/@size"/>
          </xsl:attribute>
          <xsl:attribute name="place">
            <xsl:choose>
              <xsl:when test="octave-shift/@type='up'">below</xsl:when>
              <xsl:when test="octave-shift/@type='down'">above</xsl:when>
            </xsl:choose>
          </xsl:attribute>
          <xsl:variable name="partID">
            <xsl:value-of select="ancestor::part[1]/@id"/>
          </xsl:variable>
          <xsl:variable name="partstaff">
            <xsl:choose>
              <xsl:when test="../staff">
                <xsl:value-of select="../staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="staff">
            <xsl:call-template name="getstaffnum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partstaff">
                <xsl:value-of select="$partstaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:if test="following-sibling::offset">
            <xsl:attribute name="startto">
              <xsl:value-of select="following-sibling::offset[1]"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:for-each select="octave-shift">
            <xsl:call-template name="position"/>
          </xsl:for-each>
          <xsl:attribute name="dur">
            <xsl:call-template name="getduroctave"/>
          </xsl:attribute>
        </octave>
      </xsl:if>
      <xsl:if test="pedal">
        <pedal>
          <xsl:attribute name="tstamp.ges">
            <xsl:for-each select="ancestor::direction[1]">
              <xsl:call-template name="gettstamp.ges"/>
            </xsl:for-each>
          </xsl:attribute>
          <xsl:attribute name="place">below</xsl:attribute>
          <xsl:variable name="partID">
            <xsl:value-of select="ancestor::part[1]/@id"/>
          </xsl:variable>
          <xsl:variable name="partstaff">
            <xsl:choose>
              <xsl:when test="../staff">
                <xsl:value-of select="../staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="staff">
            <xsl:call-template name="getstaffnum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partstaff">
                <xsl:value-of select="$partstaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:for-each select="pedal">
            <xsl:attribute name="dir">
              <xsl:choose>
                <xsl:when test="@type='start'">down</xsl:when>
                <xsl:when test="@type='stop'">up</xsl:when>
                <xsl:when test="@type='change'">half</xsl:when>
              </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="style">
              <xsl:choose>
                <xsl:when test="@line='yes'">line</xsl:when>
                <xsl:otherwise>pedstar</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:call-template name="position"/>
          </xsl:for-each>
        </pedal>
      </xsl:if>
      <xsl:if test="rehearsal">
        <reh>
          <xsl:attribute name="tstamp.ges">
            <xsl:for-each select="ancestor::direction[1]">
              <xsl:call-template name="gettstamp.ges"/>
            </xsl:for-each>
          </xsl:attribute>
          <xsl:attribute name="place">
            <xsl:choose>
              <xsl:when test="ancestor::direction/@placement != ''">
                <xsl:value-of select="ancestor::direction/@placement"/>
              </xsl:when>
              <xsl:otherwise>above</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:variable name="partID">
            <xsl:value-of select="ancestor::part[1]/@id"/>
          </xsl:variable>
          <xsl:variable name="partstaff">
            <xsl:choose>
              <xsl:when test="../staff">
                <xsl:value-of select="../staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="staff">
            <xsl:call-template name="getstaffnum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partstaff">
                <xsl:value-of select="$partstaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:for-each select="rehearsal">
            <xsl:attribute name="enclose">
              <xsl:choose>
                <xsl:when test="@enclosure">
                  <xsl:value-of select="@enclosure"/>
                </xsl:when>
                <xsl:otherwise>box</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:call-template name="position"/>
            <xsl:call-template name="fontproperties"/>
          </xsl:for-each>
        </reh>
      </xsl:if>
      <xsl:if test="scordatura"> </xsl:if>
      <xsl:if test="segno">
        <dir>
          <xsl:attribute name="tstamp.ges">
            <xsl:for-each select="ancestor::direction[1]">
              <xsl:call-template name="gettstamp.ges"/>
            </xsl:for-each>
          </xsl:attribute>
          <xsl:attribute name="place">
            <xsl:choose>
              <xsl:when test="ancestor::direction/@placement != ''">
                <xsl:value-of select="ancestor::direction/@placement"/>
              </xsl:when>
              <xsl:otherwise>above</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:variable name="partID">
            <xsl:value-of select="ancestor::part[1]/@id"/>
          </xsl:variable>
          <xsl:variable name="partstaff">
            <xsl:choose>
              <xsl:when test="../staff">
                <xsl:value-of select="../staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="staff">
            <xsl:call-template name="getstaffnum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partstaff">
                <xsl:value-of select="$partstaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:for-each select="segno">
            <xsl:call-template name="position"/>
          </xsl:for-each>
          <xsl:choose>
            <xsl:when
              test="segno/@font-family or
                            segno/@font-size or
                            segno/@font-style='italic' or
                            segno/@font-weight">
              <rend>
                <xsl:if test="segno/@font-family">
                  <xsl:attribute name="fontfam">
                    <xsl:value-of select="normalize-space(segno/@font-family)"/>
                  </xsl:attribute>
                </xsl:if>
                <xsl:if test="segno/@font-size">
                  <xsl:attribute name="fontsize">
                    <xsl:value-of select="segno/@font-size"/>
                  </xsl:attribute>
                </xsl:if>
                <xsl:if test="segno/@font-style='italic'">
                  <xsl:attribute name="fontstyle">ital</xsl:attribute>
                </xsl:if>
                <xsl:if test="segno/@font-weight='bold'">
                  <xsl:attribute name="fontweight">bold</xsl:attribute>
                </xsl:if>
                <!-- <xsl:text disable-output-escaping="yes">&amp;segno;</xsl:text> -->
                <xsl:text>&#x1D10B;</xsl:text>
              </rend>
            </xsl:when>
            <xsl:otherwise>
              <!-- <xsl:text disable-output-escaping="yes">&amp;segno;</xsl:text> -->
              <xsl:text>&#x1D10B;</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </dir>
      </xsl:if>
      <xsl:if test="wedge[not(@type='stop')]">
        <hairpin>
          <xsl:attribute name="tstamp.ges">
            <xsl:for-each select="ancestor::direction[1]">
              <xsl:call-template name="gettstamp.ges"/>
            </xsl:for-each>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="wedge/@type='crescendo'">
              <xsl:attribute name="form">cres</xsl:attribute>
            </xsl:when>
            <xsl:when test="wedge/@type='diminuendo'">
              <xsl:attribute name="form">dim</xsl:attribute>
            </xsl:when>
          </xsl:choose>
          <xsl:attribute name="place">
            <xsl:choose>
              <xsl:when test="ancestor::direction/@placement != ''">
                <xsl:value-of select="ancestor::direction/@placement"/>
              </xsl:when>
              <xsl:otherwise>below</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:variable name="partID">
            <xsl:value-of select="ancestor::part[1]/@id"/>
          </xsl:variable>
          <xsl:variable name="partstaff">
            <xsl:choose>
              <xsl:when test="../staff">
                <xsl:value-of select="../staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="thisstaff">
            <xsl:call-template name="getstaffnum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partstaff">
                <xsl:value-of select="$partstaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <xsl:attribute name="staff">
            <xsl:value-of select="$thisstaff"/>
          </xsl:attribute>
          <!-- <xsl:if test="wedge/@default-y">
            <xsl:attribute name="y"><xsl:value-of select="wedge/@default-y"/></xsl:attribute>
          </xsl:if> -->
          <xsl:if test="wedge/@spread">
            <xsl:attribute name="opening">
              <xsl:value-of select="wedge/@spread div 10"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="following-sibling::offset">
            <!-- record the MusicXML offset value. Converted to beat value in 2mei2.xsl. -->
            <xsl:attribute name="startto">
              <xsl:value-of select="following-sibling::offset[1]"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="wedge/@number">
              <xsl:variable name="wedgenumber">
                <xsl:value-of select="wedge/@number"/>
              </xsl:variable>
              <!-- <xsl:if test="following::direction[direction-type/wedge[@type='stop' and @number=$wedgenumber]][1]/@default-y">
                <xsl:attribute name="y2"><xsl:value-of select="following::direction[direction-type/wedge[@type='stop' and @number=$wedgenumber]][1]/@default-y"/></xsl:attribute>
              </xsl:if> -->
              <xsl:if
                test="following::direction[direction-type/wedge[@type='stop' and @number=$wedgenumber]][1]/@relative-y">
                <xsl:attribute name="y2">
                  <xsl:value-of
                    select="following::direction[direction-type/wedge[@type='stop' and @number=$wedgenumber]][1]/@relative-y"
                  />
                </xsl:attribute>
              </xsl:if>
              <xsl:if
                test="following::direction[direction-type/wedge[@type='stop' and @number=$wedgenumber]][1]/offset">
                <xsl:attribute name="endto">
                  <xsl:value-of
                    select="following::direction[direction-type/wedge[@type='stop' and @number=$wedgenumber]][1]/offset"
                  />
                </xsl:attribute>
              </xsl:if>
              <xsl:if
                test="following::direction[direction-type/wedge[@type='stop' and @number=$wedgenumber and @spread &gt; 0]]">
                <xsl:attribute name="opening">
                  <xsl:value-of
                    select="following::direction[direction-type/wedge[@type='stop' and @number=$wedgenumber]][1]/direction-type/wedge[@type='stop' and @number=$wedgenumber]/@spread div 10"
                  />
                </xsl:attribute>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <!-- <xsl:if test="following::direction[direction-type/wedge[@type='stop']][1]/@default-y">
                <xsl:attribute name="y2"><xsl:value-of select="following::direction[direction-type/wedge[@type='stop']][1]/@default-y"/></xsl:attribute>
              </xsl:if> -->
              <xsl:if
                test="following::direction[direction-type/wedge[@type='stop']][1]/@relative-y">
                <xsl:attribute name="y2">
                  <xsl:value-of
                    select="following::direction[direction-type/wedge[@type='stop']][1]/@relative-y"
                  />
                </xsl:attribute>
              </xsl:if>
              <xsl:if
                test="following::direction[direction-type/wedge[@type='stop']][1]/offset">
                <xsl:attribute name="endto">
                  <xsl:value-of
                    select="following::direction[direction-type/wedge[@type='stop']][1]/offset"
                  />
                </xsl:attribute>
              </xsl:if>
              <xsl:if
                test="following::direction[direction-type/wedge[@type='stop' and @spread &gt; 0]]">
                <xsl:attribute name="opening">
                  <xsl:value-of
                    select="following::direction[direction-type/wedge[@type='stop']][1]/direction-type/wedge[@type='stop']/@spread div 10"
                  />
                </xsl:attribute>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:attribute name="dur">
            <xsl:call-template name="getdurhairpin"/>
          </xsl:attribute>
        </hairpin>
      </xsl:if>
      <xsl:if test="words">
        <dir>
          <xsl:attribute name="tstamp.ges">
            <xsl:for-each select="ancestor::direction[1]">
              <xsl:call-template name="gettstamp.ges"/>
            </xsl:for-each>
          </xsl:attribute>
          <xsl:attribute name="place">
            <xsl:choose>
              <xsl:when test="ancestor::direction/@placement != ''">
                <xsl:value-of select="ancestor::direction/@placement"/>
              </xsl:when>
              <xsl:otherwise>above</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:variable name="partID">
            <xsl:value-of select="ancestor::part[1]/@id"/>
          </xsl:variable>
          <xsl:variable name="partstaff">
            <xsl:choose>
              <xsl:when test="ancestor::note[1]/staff">
                <xsl:value-of select="ancestor::note[1]/staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="staff">
            <xsl:call-template name="getstaffnum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partstaff">
                <xsl:value-of select="$partstaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <!-- Convert ho and vo attributes to inter-line distances later -->
          <xsl:for-each select="words">
            <xsl:call-template name="position"/>
            <xsl:for-each
              select="../../following-sibling::*[1]/dashes[@type='start']">
              <xsl:attribute name="dur">
                <xsl:call-template name="getdurwords"/>
              </xsl:attribute>
            </xsl:for-each>
          <xsl:if test="@xml:lang">
            <xsl:attribute name="xml:lang">
              <xsl:value-of select="@xml:lang"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:choose>
            <xsl:when
              test="@font-family or 
                            @font-size or 
                            @font-style='italic' or
                            @font-weight">
              <rend>
                <xsl:if test="@font-family">
                  <xsl:attribute name="fontfam">
                    <xsl:value-of select="normalize-space(@font-family)"/>
                  </xsl:attribute>
                </xsl:if>
                <xsl:if test="@font-size">
                  <xsl:attribute name="fontsize">
                    <xsl:value-of select="@font-size"/>
                  </xsl:attribute>
                </xsl:if>
                <xsl:if test="@font-style='italic'">
                  <xsl:attribute name="fontstyle">ital</xsl:attribute>
                </xsl:if>
                <xsl:if test="@font-weight='bold'">
                  <xsl:attribute name="fontweight">bold</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="."/>
              </rend>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
          </xsl:for-each>
        </dir>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="harmony" mode="stage1">
    <!-- Handle harmony indications, such as guitar chord grids -->
    <harm>
      <xsl:attribute name="tstamp.ges">
        <xsl:call-template name="gettstamp.ges"/>
      </xsl:attribute>
      <xsl:attribute name="place">above</xsl:attribute>
      <xsl:variable name="partID">
        <xsl:value-of select="ancestor::part[1]/@id"/>
      </xsl:variable>
      <xsl:variable name="partstaff">1</xsl:variable>
      <xsl:attribute name="staff">
        <xsl:call-template name="getstaffnum">
          <xsl:with-param name="partID">
            <xsl:value-of select="$partID"/>
          </xsl:with-param>
          <xsl:with-param name="partstaff">
            <xsl:value-of select="$partstaff"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:call-template name="position"/>
      <xsl:choose>
        <xsl:when test="@font-family|@font-style|@font-size|@font-weight">
          <rend>
            <xsl:if test="@font-family">
              <xsl:attribute name="fontfam">
                <xsl:value-of select="normalize-space(@font-family)"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="@font-style">
              <xsl:attribute name="fontstyle">
                <xsl:choose>
                  <xsl:when test="lower-case(substring(@font-style,1,4))='ital'">
                    <xsl:text>ital</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="@font-style"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="@font-size">
              <xsl:attribute name="fontsize">
                <xsl:value-of select="@font-size"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="@font-weight and @font-weight != 'normal'">
              <xsl:attribute name="fontweight">
                <xsl:value-of select="@font-weight"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="harmlabel"/>
          </rend>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="harmlabel"/>
        </xsl:otherwise>
      </xsl:choose>
    </harm>
  </xsl:template>

  <xsl:template name="harmlabel">
    <xsl:value-of select="normalize-space(root/root-step)"/>
    <xsl:choose>
      <xsl:when test="root/root-alter = 2">
        <xsl:text>&#x1D12A;</xsl:text>
      </xsl:when>
      <xsl:when test="root/root-alter = 1">
        <xsl:text>&#x266F;</xsl:text>
      </xsl:when>
      <xsl:when test="root/root-alter = -1">
        <xsl:text>&#x266D;</xsl:text>
      </xsl:when>
      <xsl:when test="root/root-alter = -2">
        <xsl:text>&#x1D12B;</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="kind/@text">
        <xsl:value-of select="kind/@text"/>
      </xsl:when>
      <xsl:when test="kind">
        <xsl:choose>
          <xsl:when test="kind='minor'">
            <xsl:text>m</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmlabelalterations"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'augmented'">
            <xsl:text>aug</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmlabelalterations"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'diminished'">
            <xsl:text>dim</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmlabelalterations"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'dominant'">
            <xsl:text>7</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmlabelalterations"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'major-seventh'">
            <xsl:text>maj7</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmlabelalterations"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'minor-seventh'">
            <xsl:text>m7</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmlabelalterations"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'diminished-seventh'">
            <xsl:text>dim7</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmlabelalterations"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'augmented-seventh'">
            <xsl:text>aug7</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmlabelalterations"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'half-diminished'">
            <xsl:text>dim(m7</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:call-template name="harmlabelalterations"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'major-minor'">
            <xsl:text>m(maj7</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:call-template name="harmlabelalterations"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'major-sixth'">
            <xsl:text>6</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmlabelalterations"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'minor-sixth'">
            <xsl:text>m6</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmlabelalterations"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'dominant-ninth'">
            <xsl:text>9</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmlabelalterations"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'major-ninth'">
            <xsl:text>maj7(maj9</xsl:text>
            <xsl:call-template name="harmlabelalterations"/>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'minor-ninth'">
            <xsl:text>m(m9</xsl:text>
            <xsl:call-template name="harmlabelalterations"/>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'dominant-11th'">
            <xsl:text>11</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmlabelalterations"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'major-11th'">
            <xsl:text>maj9(add11</xsl:text>
            <xsl:text>(</xsl:text>
            <xsl:call-template name="harmlabelalterations"/>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'minor-11th'">
            <xsl:text>m9(add11</xsl:text>
            <xsl:call-template name="harmlabelalterations"/>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'dominant-13th'">
            <xsl:text>13</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmlabelalterations"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'major-13th'">
            <xsl:text>maj11(add13</xsl:text>
            <xsl:call-template name="harmlabelalterations"/>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'minor-13th'">
            <xsl:text>m11(add13</xsl:text>
            <xsl:call-template name="harmlabelalterations"/>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'suspended-second'">
            <xsl:text>sus2</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmlabelalterations"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'suspended-fourth'">
            <xsl:text>sus4</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmlabelalterations"/>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="bass">
      <xsl:text>/</xsl:text>
      <xsl:value-of select="normalize-space(bass/bass-step)"/>
      <xsl:choose>
        <xsl:when test="bass/bass-alter = 2">
          <xsl:text>&#x1D12A;</xsl:text>
        </xsl:when>
        <xsl:when test="bass/bass-alter = 1">
          <xsl:text>&#x266F;</xsl:text>
        </xsl:when>
        <xsl:when test="bass/bass-alter = -1">
          <xsl:text>&#x266D;</xsl:text>
        </xsl:when>
        <xsl:when test="bass/bass-alter = -2">
          <xsl:text>&#x1D12B;</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="harmlabelalterations">
    <xsl:for-each select="degree[degree-alter]">
      <xsl:choose>
        <xsl:when test="degree-alter = 2">
          <xsl:text>&#x1D12A;</xsl:text>
        </xsl:when>
        <xsl:when test="degree-alter = 1">
          <xsl:text>&#x266F;</xsl:text>
        </xsl:when>
        <xsl:when test="degree-alter = -1">
          <xsl:text>&#x266D;</xsl:text>
        </xsl:when>
        <xsl:when test="degree-alter = -2">
          <xsl:text>&#x1D12B;</xsl:text>
        </xsl:when>
      </xsl:choose>
      <xsl:value-of select="degree-value"/>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="caesura" mode="stage1">
    <!-- In MEI a caesura is a directive -->
    <dir>
      <xsl:attribute name="tstamp.ges">
        <xsl:for-each select="ancestor::note[1]">
          <xsl:call-template name="gettstamp.ges"/>
        </xsl:for-each>
      </xsl:attribute>
      <xsl:attribute name="place">
        <xsl:choose>
          <xsl:when test="@placement != ''">
            <xsl:value-of select="@placement"/>
          </xsl:when>
          <xsl:otherwise>above</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:variable name="partID">
        <xsl:value-of select="ancestor::part[1]/@id"/>
      </xsl:variable>
      <xsl:variable name="partstaff">
        <xsl:choose>
          <xsl:when test="ancestor::note[1]/staff">
            <xsl:value-of select="ancestor::note[1]/staff"/>
          </xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:attribute name="staff">
        <xsl:call-template name="getstaffnum">
          <xsl:with-param name="partID">
            <xsl:value-of select="$partID"/>
          </xsl:with-param>
          <xsl:with-param name="partstaff">
            <xsl:value-of select="$partstaff"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:attribute name="startid">
        <xsl:for-each select="ancestor::note[1]">
          <xsl:value-of select="generate-id()"/>
        </xsl:for-each>
      </xsl:attribute>
      <xsl:call-template name="position"/>
      <xsl:text>//</xsl:text>
    </dir>
  </xsl:template>

  <xsl:template match="note/notations/tied[@type='start']" mode="stage1">
    <tie>
      <xsl:attribute name="tstamp.ges">
        <xsl:for-each select="ancestor::note[1]">
          <xsl:call-template name="gettstamp.ges"/>
        </xsl:for-each>
      </xsl:attribute>

      <xsl:variable name="staff1">
        <xsl:variable name="partID">
          <xsl:value-of select="ancestor::part[1]/@id"/>
        </xsl:variable>
        <xsl:variable name="partstaff">
          <xsl:choose>
            <xsl:when test="ancestor::note[1]/staff">
              <xsl:value-of select="ancestor::note[1]/staff"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="getstaffnum">
          <xsl:with-param name="partID">
            <xsl:value-of select="$partID"/>
          </xsl:with-param>
          <xsl:with-param name="partstaff">
            <xsl:value-of select="$partstaff"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="partID2">
        <xsl:variable name="pitch">
          <xsl:value-of select="ancestor::note/pitch/step"/>
        </xsl:variable>
        <xsl:variable name="octave">
          <xsl:value-of select="ancestor::note/pitch/octave"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when
            test="following::note[pitch/step=$pitch and pitch/octave=$octave and tie/@type='stop']">
            <xsl:for-each
              select="following::note[pitch/step=$pitch and pitch/octave=$octave and tie/@type='stop'][1]">
              <xsl:value-of select="ancestor::part[1]/@id"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each
              select="following::note[pitch/step=$pitch and pitch/octave=$octave][1]">
              <xsl:value-of select="ancestor::part[1]/@id"/>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="partstaff2">
        <xsl:variable name="pitch">
          <xsl:value-of select="ancestor::note/pitch/step"/>
        </xsl:variable>
        <xsl:variable name="octave">
          <xsl:value-of select="ancestor::note/pitch/octave"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when
            test="following::note[pitch/step=$pitch and pitch/octave=$octave and tie/@type='stop']">
            <xsl:for-each
              select="following::note[pitch/step=$pitch and pitch/octave=$octave and tie/@type='stop'][1]">
              <xsl:choose>
                <xsl:when test="staff">
                  <xsl:value-of select="staff"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each
              select="following::note[pitch/step=$pitch and pitch/octave=$octave][1]">
              <xsl:choose>
                <xsl:when test="staff">
                  <xsl:value-of select="staff"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="staff2">
        <xsl:call-template name="getstaffnum">
          <xsl:with-param name="partID">
            <xsl:value-of select="$partID2"/>
          </xsl:with-param>
          <xsl:with-param name="partstaff">
            <xsl:value-of select="$partstaff2"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>

      <!-- It is rare, but possible for a tie to cross staves;
        therefore, @staff may have 2 values: one for the
        initial note of the tie and one for the terminal note. -->

      <xsl:attribute name="staff">
        <xsl:value-of select="$staff1"/>
        <xsl:if test="$staff2 != $staff1">
          <xsl:text> </xsl:text>
          <xsl:value-of select="$staff2"/>
        </xsl:if>
      </xsl:attribute>

      <xsl:choose>
        <xsl:when test="@orientation='under'">
          <xsl:attribute name="curvedir">below</xsl:attribute>
        </xsl:when>
        <xsl:when test="@orientation='over'">
          <xsl:attribute name="curvedir">above</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="ancestor::note/stem='up'">
              <xsl:attribute name="curvedir">below</xsl:attribute>
            </xsl:when>
            <xsl:when test="ancestor::note/stem='down'">
              <xsl:attribute name="curvedir">above</xsl:attribute>
            </xsl:when>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:attribute name="startid">
        <xsl:for-each select="ancestor::note">
          <xsl:value-of select="generate-id()"/>
        </xsl:for-each>
      </xsl:attribute>

      <xsl:attribute name="endid">
        <xsl:variable name="pitch">
          <xsl:value-of select="ancestor::note/pitch/step"/>
        </xsl:variable>
        <xsl:variable name="octave">
          <xsl:value-of select="ancestor::note/pitch/octave"/>
        </xsl:variable>
        <xsl:variable name="staff">
          <xsl:value-of select="ancestor::part/@id"/>
        </xsl:variable>
        <!-- The terminal note of the tie *ought to have* tie/@type='stop',
          but it is missing in some test files! In this case, look for the
          next note of the same pitch and octave (RV: and same staff). -->
        <!-- not safe: can jump to notes far away... Better hust get the next one -->
        <!--<xsl:choose>
          <xsl:when
            test="following::note[pitch/step=$pitch and pitch/octave=$octave and tie/@type='stop' and staff=$staff]">
            <xsl:for-each
              select="following::note[pitch/step=$pitch and pitch/octave=$octave and tie/@type='stop' and staff=$staff][1]">
              <xsl:value-of select="generate-id()"/>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each
              select="following::note[pitch/step=$pitch and pitch/octave=$octave][1]">
              <xsl:value-of select="generate-id()"/>
            </xsl:for-each>
          </xsl:otherwise>
          </xsl:choose>-->
        <xsl:for-each
          select="following::note[pitch/step=$pitch and pitch/octave=$octave and ancestor::part/@id=$staff][1]">
          <xsl:value-of select="generate-id()"/>
        </xsl:for-each>
      </xsl:attribute>
    </tie>
  </xsl:template>

  <xsl:template match="note/notations/slur[@type='start']" mode="stage1">
    <slur>
      <xsl:attribute name="tstamp.ges">
        <xsl:for-each select="ancestor::note[1]">
          <xsl:call-template name="gettstamp.ges"/>
        </xsl:for-each>
      </xsl:attribute>
      <xsl:attribute name="curvedir">
        <xsl:choose>
          <xsl:when test="@placement != ''">
            <xsl:value-of select="@placement"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="ancestor::note/stem='up'">
                <xsl:text>below</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>above</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="startid">
        <xsl:for-each select="ancestor::note[1]">
          <xsl:value-of select="generate-id()"/>
        </xsl:for-each>
      </xsl:attribute>
      <!-- <xsl:if test="@default-x">
        <xsl:attribute name="startho"><xsl:value-of select="@default-x"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="@default-y">
        <xsl:attribute name="startvo"><xsl:value-of select="@default-y"/></xsl:attribute>
      </xsl:if> -->
      <xsl:call-template name="getphraseend"/>
    </slur>
  </xsl:template>

  <xsl:template match="note/notations/slur[@type='continue']" mode="stage1">
    <xsl:variable name="slurnumber">
      <xsl:value-of select="@number"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="count(preceding-sibling::slur[@number=$slurnumber])=0">
        <!-- This is a continue/stop pair -->
        <slur>
          <xsl:attribute name="tstamp.ges">
            <xsl:for-each select="ancestor::note[1]">
              <xsl:call-template name="gettstamp.ges"/>
            </xsl:for-each>
          </xsl:attribute>
          <xsl:attribute name="curvedir">
            <xsl:choose>
              <xsl:when test="@placement != ''">
                <xsl:value-of select="@placement"/>
              </xsl:when>
              <xsl:otherwise>
                <!-- The place attribute isn't present; presumably, this phrase mark has the same
                     orientation as preceding::slur[@type='start' and @number={the same number
                     as this (the continuation) slur}][1]. Right now we'll just make it 'above'. -->
                <xsl:text>above</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:variable name="partID">
            <xsl:value-of select="ancestor::part[1]/@id"/>
          </xsl:variable>
          <xsl:variable name="partstaff">
            <xsl:choose>
              <xsl:when test="ancestor::note[1]/staff">
                <xsl:value-of select="ancestor::note[1]/staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="staff">
            <xsl:call-template name="getstaffnum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partstaff">
                <xsl:value-of select="$partstaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="startid">
            <xsl:for-each select="ancestor::note[1]">
              <xsl:value-of select="generate-id()"/>
            </xsl:for-each>
          </xsl:attribute>
          <!-- In the current examples 'continue-stop' type phrases have no
               duration, i.e., they start and end on the same note. -->
          <xsl:attribute name="dur">0</xsl:attribute>
          <!-- <xsl:if test="@default-x">
            <xsl:attribute name="startho"><xsl:value-of select="@default-x"/></xsl:attribute>
          </xsl:if>
          <xsl:if test="@default-y">
            <xsl:attribute name="startvo"><xsl:value-of select="@default-y"/></xsl:attribute>
          </xsl:if> -->
          <xsl:variable name="bezierstart">
            <xsl:value-of select="@bezier-x"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@bezier-y"/>
          </xsl:variable>
          <xsl:for-each
            select="following::slur[not(@type='start') and @number=$slurnumber][1]">
            <xsl:for-each select="ancestor::note[1]">
              <xsl:attribute name="endid">
                <xsl:value-of select="generate-id()"/>
              </xsl:attribute>
            </xsl:for-each>
            <!-- <xsl:if test="@default-x">
              <xsl:attribute name="endho"><xsl:value-of select="@default-x"/></xsl:attribute>
            </xsl:if>
            <xsl:if test="@default-y">
              <xsl:attribute name="endvo"><xsl:value-of select="@default-y"/></xsl:attribute>
            </xsl:if> -->
            <xsl:variable name="bezierend">
              <xsl:value-of select="@bezier-x"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="@bezier-y"/>
            </xsl:variable>
            <xsl:if test="concat($bezierstart,$bezierend) != '  '">
              <xsl:attribute name="bezier">
                <xsl:value-of select="$bezierstart"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$bezierend"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:for-each>
        </slur>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="note/notations/tuplet[@type='start']" mode="stage1">
    <!-- Create tupletspan control elements -->
    <tupletspan>
      <xsl:variable name="partID">
        <xsl:value-of select="ancestor::part[1]/@id"/>
      </xsl:variable>
      <xsl:variable name="partstaff">
        <xsl:choose>
          <xsl:when test="ancestor::note[1]/staff">
            <xsl:value-of select="ancestor::note[1]/staff"/>
          </xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:attribute name="staff">
        <xsl:call-template name="getstaffnum">
          <xsl:with-param name="partID">
            <xsl:value-of select="$partID"/>
          </xsl:with-param>
          <xsl:with-param name="partstaff">
            <xsl:value-of select="$partstaff"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:attribute name="startid">
        <xsl:for-each select="ancestor::note[1]">
          <xsl:value-of select="generate-id()"/>
        </xsl:for-each>
      </xsl:attribute>
      <xsl:attribute name="endid">
        <xsl:choose>
          <xsl:when test="@number">
            <xsl:variable name="tupletlevel">
              <xsl:value-of select="@number"/>
            </xsl:variable>
            <xsl:for-each
              select="following::tuplet[@type='stop' and @number=$tupletlevel][1]">
              <xsl:for-each select="ancestor::note[1]">
                <xsl:value-of select="generate-id()"/>
              </xsl:for-each>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="following::tuplet[@type='stop'][1]">
              <xsl:for-each select="ancestor::note[1]">
                <xsl:value-of select="generate-id()"/>
              </xsl:for-each>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:for-each select="ancestor::note[1]/time-modification">
        <xsl:attribute name="num">
          <xsl:value-of select="actual-notes"/>
        </xsl:attribute>
        <xsl:attribute name="numbase">
          <xsl:value-of select="normal-notes"/>
        </xsl:attribute>
        <xsl:if test="normal-type">
          <xsl:choose>
            <xsl:when test="normalize-space(normal-type) = 'long'">
              <xsl:attribute name="numbase">long</xsl:attribute>
            </xsl:when>
            <xsl:when test="normalize-space(normal-type) = 'breve'">
              <xsl:attribute name="numbase">breve</xsl:attribute>
            </xsl:when>
            <xsl:when test="normalize-space(normal-type) = 'whole'">
              <xsl:attribute name="numbase">1</xsl:attribute>
            </xsl:when>
            <xsl:when test="normalize-space(normal-type) = 'half'">
              <xsl:attribute name="numbase">2</xsl:attribute>
            </xsl:when>
            <xsl:when test="normalize-space(normal-type) = 'quarter'">
              <xsl:attribute name="numbase">4</xsl:attribute>
            </xsl:when>
            <xsl:when test="normalize-space(normal-type) = 'eighth'">
              <xsl:attribute name="numbase">8</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="numbase">
                <xsl:analyze-string select="normalize-space(normal-type)"
                  regex="^([0-9]+)(.*)$">
                  <xsl:matching-substring>
                    <xsl:value-of select="regex-group(1)"/>
                  </xsl:matching-substring>
                </xsl:analyze-string>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:for-each>
      <xsl:choose>
        <xsl:when test="@show-number='none'">
          <xsl:attribute name="num.visible">false</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="num.visible">true</xsl:attribute>
          <xsl:attribute name="num.place">
            <xsl:choose>
              <xsl:when test="@placement != ''">
                <xsl:value-of select="@placement"/>
              </xsl:when>
              <xsl:otherwise>above</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="@show-number='both'">
              <xsl:attribute name="num.format">ratio</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="num.format">count</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="@bracket='yes'">
          <xsl:attribute name="bracket.visible">true</xsl:attribute>
          <xsl:attribute name="bracket.place">
            <xsl:value-of select="@placement"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="@bracket='no'">
          <xsl:attribute name="bracket.visible">false</xsl:attribute>
        </xsl:when>
      </xsl:choose>
    </tupletspan>
  </xsl:template>

  <xsl:template match="note/notations/dynamics" mode="stage1">
    <!-- Dynamics -->
    <dynam>
      <xsl:attribute name="tstamp.ges">
        <xsl:for-each select="ancestor::note[1]">
          <xsl:call-template name="gettstamp.ges"/>
        </xsl:for-each>
      </xsl:attribute>
      <xsl:attribute name="place">
        <xsl:choose>
          <xsl:when test="@placement != ''">
            <xsl:value-of select="@placement"/>
          </xsl:when>
          <xsl:otherwise>below</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:variable name="partID">
        <xsl:value-of select="ancestor::part[1]/@id"/>
      </xsl:variable>
      <xsl:variable name="partstaff">
        <xsl:choose>
          <xsl:when test="ancestor::note[1]/staff">
            <xsl:value-of select="ancestor::note[1]/staff"/>
          </xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:attribute name="staff">
        <xsl:call-template name="getstaffnum">
          <xsl:with-param name="partID">
            <xsl:value-of select="$partID"/>
          </xsl:with-param>
          <xsl:with-param name="partstaff">
            <xsl:value-of select="$partstaff"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:attribute>

      <xsl:call-template name="position"/>

      <xsl:choose>
        <xsl:when test="@font-family|@font-style|@font-size|@font-weight">
          <rend>
            <xsl:if test="@font-family">
              <xsl:attribute name="fontfam">
                <xsl:value-of select="normalize-space(@font-family)"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="@font-style">
              <xsl:attribute name="fontstyle">
                <xsl:choose>
                  <xsl:when test="lower-case(substring(@font-style,1,4))='ital'">
                    <xsl:text>ital</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="@font-style"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="@font-size">
              <xsl:attribute name="fontsize">
                <xsl:value-of select="@font-size"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="@font-weight and @font-weight != 'normal'">
              <xsl:attribute name="fontweight">
                <xsl:value-of select="@font-weight"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:for-each select="*">
              <xsl:choose>
                <xsl:when test="name()='other-dynamics'">
                  <xsl:value-of select="."/>
                  <xsl:if test="position() != last()">
                    <xsl:text> </xsl:text>
                  </xsl:if>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="name()"/>
                  <xsl:if test="position() != last()">
                    <xsl:text> </xsl:text>
                  </xsl:if>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </rend>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="*">
            <xsl:choose>
              <xsl:when test="name()='other-dynamics'">
                <xsl:value-of select="."/>
                <xsl:if test="position() != last()">
                  <xsl:text> </xsl:text>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="name()"/>
                <xsl:if test="position() != last()">
                  <xsl:text> </xsl:text>
                </xsl:if>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </dynam>
  </xsl:template>

  <!-- Save this until later!
  <xsl:template match="sound">
  </xsl:template>
  -->

  <!-- Process mid-measure MusicXML attributes -->
  <xsl:template match="attributes" mode="stage1">

    <xsl:choose>
      <xsl:when test="count(following-sibling::*[not(name()='barline')])=0">
        <xsl:for-each select="clef">
          <clefchange>
            <xsl:variable name="partID">
              <xsl:value-of select="ancestor::part[1]/@id"/>
            </xsl:variable>
            <xsl:variable name="partstaff">
              <xsl:choose>
                <xsl:when test="@number">
                  <xsl:value-of select="@number"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:attribute name="part">
              <xsl:value-of select="$partID"/>
            </xsl:attribute>
            <xsl:attribute name="layer">
              <xsl:choose>
                <xsl:when test="preceding::note[1]/voice">
                  <xsl:value-of select="preceding::note[1]/voice"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>1</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="staff">
              <xsl:call-template name="getstaffnum">
                <xsl:with-param name="partID">
                  <xsl:value-of select="$partID"/>
                </xsl:with-param>
                <xsl:with-param name="partstaff">
                  <xsl:value-of select="$partstaff"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="tstamp.ges">
              <xsl:call-template name="gettstamp.ges"/>
            </xsl:attribute>
            <xsl:attribute name="shape">
              <xsl:choose>
                <xsl:when test="sign='percussion'">
                  <xsl:text>perc</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="sign"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="line">
              <xsl:value-of select="line"/>
            </xsl:attribute>
            <xsl:if test="clef-octave-change">
              <xsl:if test="abs(number(clef-octave-change)) != 0">
                <xsl:attribute name="trans">
                  <xsl:choose>
                    <xsl:when test="clef-octave-change = '2'">15va</xsl:when>
                    <xsl:when test="clef-octave-change = '1'">8va</xsl:when>
                    <xsl:when test="clef-octave-change = '-1'">8vb</xsl:when>
                    <xsl:when test="clef-octave-change = '-2'">15vb</xsl:when>
                  </xsl:choose>
                </xsl:attribute>
              </xsl:if>
            </xsl:if>
          </clefchange>
        </xsl:for-each>
      </xsl:when>
      <xsl:when
        test="preceding-sibling::note | preceding-sibling::forward | preceding-sibling::chord">
        <!-- Mid-measure attributes -->
        <xsl:for-each select="clef">
          <clefchange>
            <xsl:variable name="partID">
              <xsl:value-of select="ancestor::part[1]/@id"/>
            </xsl:variable>
            <xsl:variable name="partstaff">
              <xsl:choose>
                <xsl:when test="@number">
                  <xsl:value-of select="@number"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:attribute name="part">
              <xsl:value-of select="$partID"/>
            </xsl:attribute>
            <xsl:attribute name="layer">
              <xsl:choose>
                <xsl:when test="following::note[1]/voice">
                  <xsl:value-of select="following::note[1]/voice"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>1</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="staff">
              <xsl:call-template name="getstaffnum">
                <xsl:with-param name="partID">
                  <xsl:value-of select="$partID"/>
                </xsl:with-param>
                <xsl:with-param name="partstaff">
                  <xsl:value-of select="$partstaff"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="tstamp.ges">
              <xsl:call-template name="gettstamp.ges"/>
            </xsl:attribute>
            <xsl:attribute name="shape">
              <xsl:choose>
                <xsl:when test="sign='percussion'">
                  <xsl:text>perc</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="sign"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="line">
              <xsl:value-of select="line"/>
            </xsl:attribute>
            <xsl:if test="clef-octave-change">
              <xsl:if test="abs(number(clef-octave-change)) != 0">
                <xsl:attribute name="trans">
                  <xsl:choose>
                    <xsl:when test="clef-octave-change = '2'">15va</xsl:when>
                    <xsl:when test="clef-octave-change = '1'">8va</xsl:when>
                    <xsl:when test="clef-octave-change = '-1'">8vb</xsl:when>
                    <xsl:when test="clef-octave-change = '-2'">15vb</xsl:when>
                  </xsl:choose>
                </xsl:attribute>
              </xsl:if>
            </xsl:if>
          </clefchange>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="forward" mode="stage1">
    <!-- Forward skips in time have to be filled with space in MEI when 
         they are followed by events, i.e. notes -->
    <xsl:if test="following-sibling::note">
      <space>
        <xsl:attribute name="xml:id">
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
        <xsl:attribute name="tstamp.ges">
          <xsl:call-template name="gettstamp.ges"/>
        </xsl:attribute>
        <xsl:call-template name="gesturaldur"/>
        <xsl:call-template name="part-layer-staff-beam-assign"/>
      </space>
    </xsl:if>
  </xsl:template>

  <xsl:template match="backup" mode="stage1">
    <!-- This is a no-op!  Backup elements don't require any action in MEI. -->
  </xsl:template>

  <xsl:template match="note[not(chord)]" mode="stage1">
    <!-- Non-chord tones -->
    <xsl:choose>
      <xsl:when test="following-sibling::note[1][chord]">
        <xsl:variable name="chordthis">
          <chord>
            <xsl:apply-templates select="." mode="onenote"/>
          </chord>
        </xsl:variable>
        <xsl:apply-templates select="$chordthis/chord" mode="chordthis"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="onenote"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="chord" mode="chordthis">
    <!-- Copy some note attributes to the parent chord -->
    <xsl:variable name="chordthis2">
      <chord>
        <xsl:attribute name="xml:id">
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>

        <!-- Copy note attributes that always rightfully belong to the whole chord -->
        <xsl:copy-of
          select="note[1]/@dots | note[1]/@dur | note[1]/@dur.ges |
                             note[1]/@stem.dir | note[1]/@stem.len | note[1]/@tstamp.ges |
                             note[1]/@tuplet"/>

        <!-- Copy these attrs if even one of the notes has the attr -->
        <xsl:if test="note[@fermata]">
          <xsl:copy-of select="note[@fermata][1]/@fermata"/>
        </xsl:if>
        <xsl:if test="note[@grace]">
          <xsl:copy-of select="note[@grace][1]/@grace"/>
        </xsl:if>
        <xsl:if test="note[@beam]">
          <xsl:copy-of select="note[@beam][1]/@beam"/>
        </xsl:if>
        <xsl:if test="note[@stem.x]">
          <xsl:copy-of select="note[@stem.x][1]/@stem.x"/>
        </xsl:if>

        <!-- Copy these attrs if all notes have the attr and have the same value -->
        <xsl:if test="count(note[@part])=count(note)">
          <xsl:if test="count(distinct-values(note/@part))=1">
            <xsl:copy-of select="note[@part][1]/@part"/>
          </xsl:if>
        </xsl:if>
        <xsl:if test="count(note[@layer])=count(note)">
          <xsl:if test="count(distinct-values(note/@layer))=1">
            <xsl:copy-of select="note[@staff][1]/@layer"/>
          </xsl:if>
        </xsl:if>
        <xsl:if test="count(note[@staff])=count(note)">
          <xsl:if test="count(distinct-values(note/@staff))=1">
            <xsl:copy-of select="note[@staff][1]/@staff"/>
          </xsl:if>
        </xsl:if>
        <xsl:if test="count(note[@size])=count(note)">
          <xsl:if test="count(distinct-values(note/@size))=1">
            <xsl:copy-of select="note[@size][1]/@size"/>
          </xsl:if>
        </xsl:if>
        <xsl:if test="count(note[@instr])=count(note)">
          <xsl:if test="count(distinct-values(note/@instr))=1">
            <xsl:copy-of select="note[@instr][1]/@instr"/>
          </xsl:if>
        </xsl:if>
        <xsl:if test="count(note[@beam])=count(note)">
          <xsl:if test="count(distinct-values(note/@beam))=1">
            <xsl:copy-of select="note[@beam][1]/@beam"/>
          </xsl:if>
        </xsl:if>
        <xsl:if test="count(note[@tie])=count(note)">
          <xsl:if test="count(distinct-values(note/@tie))=1">
            <xsl:copy-of select="note[@tie][1]/@tie"/>
          </xsl:if>
        </xsl:if>
        <xsl:if test="count(note[@grace.time])=count(note)">
          <xsl:if test="count(distinct-values(note/@grace.time))=1">
            <xsl:copy-of select="note[@grace.time][1]/@grace.time"/>
          </xsl:if>
        </xsl:if>
        <xsl:if test="count(note[@headshape])=count(note)">
          <xsl:if test="count(distinct-values(note/@headshape))=1">
            <xsl:copy-of select="note[@altsym][1]/@headshape"/>
          </xsl:if>
        </xsl:if>
        <xsl:if test="count(note[@x])=count(note)">
          <xsl:if test="count(distinct-values(note/@x))=1">
            <xsl:copy-of select="note[@x][1]/@x"/>
          </xsl:if>
        </xsl:if>

        <!-- Copy notes -->
        <xsl:copy-of select="note"/>
      </chord>
    </xsl:variable>
    <xsl:apply-templates select="$chordthis2/chord" mode="thinnote"/>
  </xsl:template>

  <xsl:template match="chord" mode="thinnote">
    <!-- Eliminate note attributes copied to parent chord -->
    <chord>
      <xsl:copy-of select="@*"/>
      <xsl:variable name="sortedstaff">
        <xsl:perform-sort select="distinct-values(note/@staff)">
          <xsl:sort select="." data-type="number"/>
        </xsl:perform-sort>
      </xsl:variable>
      <xsl:attribute name="staff">
        <xsl:value-of select="$sortedstaff"/>
      </xsl:attribute>
      <xsl:variable name="sortedlayer">
        <xsl:perform-sort select="distinct-values(note/@layer)">
          <xsl:sort select="." data-type="number"/>
        </xsl:perform-sort>
      </xsl:variable>
      <xsl:attribute name="layer">
        <xsl:value-of select="$sortedlayer"/>
      </xsl:attribute>
      <xsl:for-each select="note">
        <xsl:sort select="@staff"/>
        <xsl:sort select="@layer"/>
        <note>
          <xsl:copy-of select="@xml:id"/>
          <xsl:for-each select="@*">
            <xsl:variable name="thisattr">
              <xsl:value-of select="name(.)"/>
            </xsl:variable>
            <!-- Copy any other note attributes (except @id which was handled above) that
            don't already exist on the parent chord -->
            <xsl:if test="not(ancestor::chord/@*[name()=$thisattr])">
              <xsl:copy-of select="."/>
            </xsl:if>
          </xsl:for-each>
          <!-- Copy any children -->
          <xsl:copy-of select="child::*"/>
        </note>
      </xsl:for-each>
    </chord>
  </xsl:template>

  <xsl:template match="note" mode="onenote">
    <!-- Create a note/rest element -->
    <xsl:choose>
      <xsl:when test="rest">
        <!-- This is a rest! -->
        <xsl:variable name="thisvoice">
          <xsl:value-of select="voice"/>
        </xsl:variable>
        <rest>
          <xsl:attribute name="xml:id">
            <xsl:value-of select="generate-id()"/>
          </xsl:attribute>
          <xsl:attribute name="tstamp.ges">
            <xsl:call-template name="gettstamp.ges"/>
          </xsl:attribute>
          <xsl:if test="type">
            <xsl:attribute name="dur">
              <xsl:call-template name="notateddur"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:call-template name="notateddot"/>
          <xsl:call-template name="fermata.attr"/>
          <xsl:if test="duration">
            <xsl:call-template name="gesturaldur"/>
          </xsl:if>
          <xsl:call-template name="part-layer-staff-beam-assign"/>
          <xsl:call-template name="position"/>
          <xsl:call-template name="restvo"/>
          <xsl:call-template name="size"/>
        </rest>
      </xsl:when>
      <xsl:otherwise>
        <!-- This is a 'pitched' or 'unpitched' note -->
        <!-- None of the Beyond MIDI examples include unpitched notes. -->
        <note>
          <xsl:attribute name="xml:id">
            <xsl:value-of select="generate-id()"/>
          </xsl:attribute>
          <xsl:attribute name="tstamp.ges">
            <xsl:call-template name="gettstamp.ges"/>
          </xsl:attribute>
          <xsl:if test="@print-object='no'">
            <xsl:attribute name="visible">false</xsl:attribute>
          </xsl:if>

          <!-- Is this a grace note? -->
          <xsl:if test="grace">
            <xsl:choose>
              <xsl:when test="grace/@steal-time-following">
                <xsl:attribute name="grace">acc</xsl:attribute>
                <xsl:attribute name="grace.time">
                  <xsl:value-of select="grace/@steal-time-following"/>
                </xsl:attribute>
                <xsl:if test="grace/@slash='yes'">
                  <xsl:attribute name="stem.mod">1slash</xsl:attribute>
                </xsl:if>
              </xsl:when>
              <xsl:when test="grace/@steal-time-previous">
                <xsl:attribute name="grace">unacc</xsl:attribute>
                <xsl:attribute name="grace.time">
                  <xsl:value-of select="grace/@steal-time-previous"/>
                </xsl:attribute>
                <xsl:if test="grace/@slash='yes'">
                  <xsl:attribute name="stem.mod">1slash</xsl:attribute>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="grace">unacc</xsl:attribute>
                <xsl:if test="grace/@slash='yes'">
                  <xsl:attribute name="stem.mod">1slash</xsl:attribute>
                </xsl:if>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>

          <!-- Notated pitch -->
          <xsl:choose>
            <xsl:when test="pitch">
              <xsl:attribute name="pname">
                <xsl:value-of select="lower-case(pitch/step)"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <!-- This note is unpitched, e.g., for unpitched percussion or of indeterminate pitch. -->
              <xsl:attribute name="pname">
                <xsl:value-of select="lower-case(unpitched/display-step)"/>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>

          <!-- Notated accidental in attribute. This block is turned off by default, but can be
               turned on with the accidattr stylesheet parameter. -->
          <xsl:if test="$accidattr='yes'">
            <xsl:choose>
              <xsl:when test="accidental/@editorial='yes'">
                <xsl:attribute name="accid.editorial">
                  <xsl:choose>
                    <xsl:when test="accidental = 'sharp'">s</xsl:when>
                    <xsl:when test="accidental = 'natural'">n</xsl:when>
                    <xsl:when test="accidental = 'flat'">f</xsl:when>
                    <xsl:when test="accidental = 'double-sharp'">x</xsl:when>
                    <xsl:when test="accidental = 'sharp-sharp'">ss</xsl:when>
                    <xsl:when test="accidental = 'flat-flat'">ff</xsl:when>
                    <xsl:when test="accidental = 'natural-sharp'">ns</xsl:when>
                    <xsl:when test="accidental = 'natural-flat'">nf</xsl:when>
                    <xsl:when test="accidental = 'quarter-flat'">fd</xsl:when>
                    <xsl:when test="accidental = 'quarter-sharp'">su</xsl:when>
                  </xsl:choose>
                </xsl:attribute>
                <!-- Accidental enclosure in attribute -->
                <xsl:choose>
                  <xsl:when test="accidental/@parentheses='yes'">
                    <xsl:attribute name="enclose.accid">paren</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="accidental/@bracket='yes'">
                    <xsl:attribute name="enclose.accid">brack</xsl:attribute>
                  </xsl:when>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="accidental">
                <xsl:attribute name="accid">
                  <xsl:choose>
                    <xsl:when test="accidental = 'sharp'">s</xsl:when>
                    <xsl:when test="accidental = 'natural'">n</xsl:when>
                    <xsl:when test="accidental = 'flat'">f</xsl:when>
                    <xsl:when test="accidental = 'double-sharp'">x</xsl:when>
                    <xsl:when test="accidental = 'sharp-sharp'">ss</xsl:when>
                    <xsl:when test="accidental = 'flat-flat'">ff</xsl:when>
                    <xsl:when test="accidental = 'natural-sharp'">ns</xsl:when>
                    <xsl:when test="accidental = 'natural-flat'">nf</xsl:when>
                    <xsl:when test="accidental = 'quarter-flat'">fd</xsl:when>
                    <xsl:when test="accidental = 'quarter-sharp'">su</xsl:when>
                  </xsl:choose>
                </xsl:attribute>
                <!-- Accidental enclosure in attribute -->
                <xsl:choose>
                  <xsl:when test="accidental/@parentheses='yes'">
                    <xsl:attribute name="enclose.accid">paren</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="accidental/@bracket='yes'">
                    <xsl:attribute name="enclose.accid">brack</xsl:attribute>
                  </xsl:when>
                </xsl:choose>
              </xsl:when>
            </xsl:choose>
          </xsl:if>

          <!-- Notated/performed octave -->
          <xsl:choose>
            <xsl:when test="pitch">
              <xsl:variable name="thispart">
                <xsl:value-of select="ancestor::part/@id"/>
              </xsl:variable>
              <xsl:variable name="partstaff">
                <xsl:choose>
                  <xsl:when test="staff">
                    <xsl:value-of select="staff"/>
                  </xsl:when>
                  <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:variable name="octave-shift">
                <xsl:value-of
                  select="count(preceding::octave-shift[not(@type='stop') and ancestor::part/@id=$thispart
                and ancestor::direction/staff=$partstaff]) - count(preceding::octave-shift[@type='stop' and
                ancestor::part/@id=$thispart and ancestor::direction/staff=$partstaff])"
                />
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="$octave-shift &gt; 0">
                  <xsl:variable name="shift">
                    <xsl:variable name="size">
                      <xsl:value-of
                        select="preceding::octave-shift[1][not(@type='stop') and
                      ancestor::part/@id=$thispart and ancestor::direction/staff=$partstaff]/@size"
                      />
                    </xsl:variable>
                    <xsl:choose>
                      <xsl:when test="$size=8">1</xsl:when>
                      <xsl:when test="$size=15">2</xsl:when>
                    </xsl:choose>
                  </xsl:variable>
                  <xsl:variable name="direction">
                    <xsl:value-of
                      select="preceding::octave-shift[1][not(@type='stop') and
                    ancestor::part/@id=$thispart and ancestor::direction/staff=$partstaff]/@type"
                    />
                  </xsl:variable>
                  <xsl:choose>
                    <xsl:when test="$direction='down'">
                      <xsl:attribute name="oct">
                        <xsl:value-of select="pitch/octave - $shift"/>
                      </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$direction='up'">
                      <xsl:attribute name="oct">
                        <xsl:value-of select="pitch/octave + $shift"/>
                      </xsl:attribute>
                    </xsl:when>
                  </xsl:choose>
                  <xsl:attribute name="oct.ges">
                    <xsl:value-of select="pitch/octave"/>
                  </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="oct">
                    <xsl:value-of select="pitch/octave"/>
                  </xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <!-- This note is of indeterminate pitch. -->
              <xsl:attribute name="oct">
                <xsl:value-of select="unpitched/display-octave"/>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>

          <!-- String tablature -->
          <xsl:if test="notations/technical/string">
            <xsl:attribute name="tab.string">
              <xsl:value-of select="notations/technical/string"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="notations/technical/fret">
            <xsl:attribute name="tab.fret">
              <xsl:value-of select="notations/technical/fret"/>
            </xsl:attribute>
          </xsl:if>

          <!-- Note attributes -->
          <xsl:variable name="notateddur">
            <xsl:call-template name="notateddur"/>
          </xsl:variable>
          <xsl:if test="$notateddur != ''">
            <xsl:attribute name="dur">
              <xsl:value-of select="$notateddur"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:call-template name="notateddot"/>
          <xsl:call-template name="fermata.attr"/>
          <!-- Articulations in attributes. This block is turned off by default, but can be
               turned on with the articattr stylesheet parameter. -->
          <xsl:if test="$articattr='yes'">
            <xsl:call-template name="artics"/>
          </xsl:if>
          <xsl:call-template name="gesturaldur"/>
          <xsl:call-template name="part-layer-staff-beam-assign"/>
          <xsl:call-template name="position"/>
          <xsl:call-template name="size"/>

          <!-- Notated tie in attribute:
               I'm using notations/tied here instead of note/tie because note/tie
               doesn't provide indication of middle notes in a tie, only start and stop.
               None of the current MusicXML examples record the position of ties. -->
          <xsl:choose>
            <xsl:when
              test="notations/tied/@type='start' and notations/tied/@type='stop'">
              <xsl:attribute name="tie">m</xsl:attribute>
            </xsl:when>
            <xsl:when test="notations/tied/@type='start'">
              <xsl:attribute name="tie">i</xsl:attribute>
            </xsl:when>
            <xsl:when test="notations/tied/@type='stop'">
              <xsl:attribute name="tie">t</xsl:attribute>
            </xsl:when>
          </xsl:choose>

          <!-- Stem attributes: direction and length
               MusicXML uses a text value of 'none' to record a zero-length stem, but
               stem/@relative-y or @default-y to record non-zero stem length. -->
          <xsl:choose>
            <xsl:when test="stem='up'">
              <xsl:attribute name="stem.dir">up</xsl:attribute>
              <xsl:if test="stem/@relative-y != 0">
                <xsl:attribute name="stem.len">
                  <xsl:value-of
                    select="abs(round-half-to-even(stem/@relative-y div 10,3))"
                  />
                </xsl:attribute>
              </xsl:if>
              <xsl:if test="stem/@default-y">
                <xsl:attribute name="stem.y">
                  <xsl:value-of
                    select="abs(round-half-to-even(stem/@default-y div 10,3))"/>
                </xsl:attribute>
              </xsl:if>
            </xsl:when>
            <xsl:when test="stem='down'">
              <xsl:attribute name="stem.dir">down</xsl:attribute>
              <xsl:if test="stem/@relative-y != 0">
                <xsl:attribute name="stem.len">
                  <xsl:value-of
                    select="abs(round-half-to-even(stem/@relative-y div 10,3))"
                  />
                </xsl:attribute>
              </xsl:if>
              <xsl:if test="stem/@default-y">
                <xsl:attribute name="stem.y">
                  <xsl:value-of
                    select="abs(round-half-to-even(stem/@default-y,3))"/>
                </xsl:attribute>
              </xsl:if>
            </xsl:when>
            <xsl:when test="stem='none'">
              <xsl:attribute name="stem.len">0</xsl:attribute>
            </xsl:when>
            <xsl:when test="stem='double'">
              <!-- This stylesheet doesn't handle 'double' stems
              because this is an indication of multiple layers. -->
            </xsl:when>
          </xsl:choose>

          <!-- Bowed tremolo -->
          <xsl:if test="notations/ornaments/tremolo">
            <xsl:attribute name="stem.mod">
              <xsl:value-of select="notations/ornaments/tremolo"/>
              <xsl:text>slash</xsl:text>
            </xsl:attribute>
          </xsl:if>

          <!-- Notehead shape -->
          <!-- It's not usually necessary to be explicit about whether
          the notehead is filled or not since the shape ought to be
          filled if the duration is <= quarter and open otherwise.
          However, this part of the stylesheet can be tweaked later. -->
          <xsl:choose>
            <xsl:when test="notehead='slash'">
              <xsl:attribute name="headshape">slash</xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='triangle'">
              <xsl:attribute name="headshape">isotriangle</xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='diamond'">
              <xsl:attribute name="headshape">diamond</xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='square'">
              <xsl:attribute name="headshape">rectangle</xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='cross'">
              <xsl:attribute name="headshape">cross</xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='x'">
              <xsl:attribute name="headshape">x</xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='circle-x'">
              <xsl:attribute name="headshape">circlex</xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='inverted triangle'">
              <xsl:attribute name="headshape">isotriangle</xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='arrow down'">
              <xsl:attribute name="headshape">isotriangle</xsl:attribute>
              <!-- Mup doesn't support centered stems -->
              <xsl:attribute name="stem.pos">center</xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='arrow up'">
              <xsl:attribute name="headshape">isotriangle</xsl:attribute>
              <!-- Mup doesn't support centered stems -->
              <xsl:attribute name="stem.pos">center</xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='slashed'">
              <!-- addslash must be added to the list of allowed values
              for the headshape attribute -->
              <xsl:attribute name="headshape">addslash</xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='back slashed'">
              <!-- addbackslash must be added to the list of allowed
              values for the headshape attribute -->
              <xsl:attribute name="headshape">addbackslash</xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='normal'">
              <!-- Regular notehead, this is a no-op! -->
            </xsl:when>
            <xsl:when test="notehead='none'">
              <xsl:attribute name="headshape">blank</xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='do'">
              <xsl:attribute name="headshape">isotriangle</xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='re'">
              <xsl:attribute name="headshape">semicircle</xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='mi'">
              <xsl:attribute name="headshape">diamond</xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='fa'">
              <xsl:attribute name="headshape">righttriangle</xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='so'">
              <!-- Regular notehead, this is a no-op! -->
            </xsl:when>
            <xsl:when test="notehead='la'">
              <xsl:attribute name="headshape">rectangle</xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='ti'">
              <xsl:attribute name="headshape">piewedge</xsl:attribute>
            </xsl:when>
          </xsl:choose>

          <!-- Gestural accidentals in attribute -->
          <xsl:choose>
            <xsl:when test="pitch/alter = 2">
              <xsl:attribute name="accid.ges">ss</xsl:attribute>
            </xsl:when>
            <xsl:when test="pitch/alter = 1">
              <xsl:attribute name="accid.ges">s</xsl:attribute>
            </xsl:when>
            <xsl:when test="pitch/alter = -1">
              <xsl:attribute name="accid.ges">f</xsl:attribute>
            </xsl:when>
            <xsl:when test="pitch/alter = -2">
              <xsl:attribute name="accid.ges">ff</xsl:attribute>
            </xsl:when>
          </xsl:choose>

          <!-- Instrument assignment -->
          <xsl:if test="instrument">
            <xsl:attribute name="instr">
              <xsl:value-of select="instrument/@id"/>
            </xsl:attribute>
            <xsl:variable name="notenum">
              <xsl:value-of select="instrument/@id"/>
            </xsl:variable>
            <xsl:if
              test="preceding::midi-instrument[@id=$notenum]/midi-unpitched">
              <xsl:attribute name="pnum">
                <xsl:value-of
                  select="preceding::midi-instrument[@id=$notenum][1]/midi-unpitched"
                />
              </xsl:attribute>
            </xsl:if>
          </xsl:if>

          <!-- Lyrics in attribute, if requested via the sylattr stylesheet parameter. -->
          <xsl:if test="$sylattr='yes'">
            <xsl:if test="lyric">
              <xsl:attribute name="syl">
                <xsl:for-each select="lyric">
                  <xsl:value-of select="text"/>
                  <xsl:if test="syllabic='begin' or syllabic='middle'">
                    <xsl:text>-</xsl:text>
                  </xsl:if>
                  <xsl:if test="extend">
                    <xsl:text>_</xsl:text>
                  </xsl:if>
                  <xsl:if test="position() != last()">
                    <xsl:text>//</xsl:text>
                  </xsl:if>
                </xsl:for-each>
              </xsl:attribute>
            </xsl:if>
          </xsl:if>

          <!-- Unless attributes are explicitly requested (via stylesheet parameters),
               create sub-elements for accidentals and articulations so that placement
               can be recorded. -->
          <xsl:if test="$accidattr='no'">
            <xsl:call-template name="accidentals"/>
          </xsl:if>
          <xsl:if test="$articattr='no'">
            <xsl:call-template name="articulations"/>
          </xsl:if>
          <xsl:if test="$sylattr='no'">
            <xsl:apply-templates select="lyric" mode="stage1"/>
          </xsl:if>

        </note>
        <xsl:if test="following-sibling::note[1][chord]">
          <xsl:apply-templates select="following-sibling::note[1][chord]"
            mode="onenote"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="accidentals">
    <!-- Accidentals in elements so that exact placement can be recorded -->
    <xsl:for-each select="accidental">
      <xsl:variable name="thisaccid">
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:variable>
      <accid>
        <xsl:choose>
          <xsl:when test="@editorial='yes'">
            <xsl:attribute name="type">editorial</xsl:attribute>
          </xsl:when>
          <xsl:when test="@cautionary='yes'">
            <xsl:attribute name="type">cautionary</xsl:attribute>
          </xsl:when>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="@parentheses='yes'">
            <xsl:attribute name="enclose.accid">paren</xsl:attribute>
          </xsl:when>
          <xsl:when test="@bracket='yes'">
            <xsl:attribute name="enclose.accid">brack</xsl:attribute>
          </xsl:when>
        </xsl:choose>
        <xsl:attribute name="accid">
          <xsl:choose>
            <xsl:when test="$thisaccid = 'sharp'">s</xsl:when>
            <xsl:when test="$thisaccid = 'natural'">n</xsl:when>
            <xsl:when test="$thisaccid = 'flat'">f</xsl:when>
            <xsl:when test="$thisaccid = 'double-sharp'">x</xsl:when>
            <xsl:when test="$thisaccid = 'sharp-sharp'">ss</xsl:when>
            <xsl:when test="$thisaccid = 'flat-flat'">ff</xsl:when>
            <xsl:when test="$thisaccid = 'natural-sharp'">ns</xsl:when>
            <xsl:when test="$thisaccid = 'natural-flat'">nf</xsl:when>
            <xsl:when test="$thisaccid = 'quarter-flat'">fd</xsl:when>
            <xsl:when test="$thisaccid = 'quarter-sharp'">su</xsl:when>
          </xsl:choose>
        </xsl:attribute>
        <xsl:call-template name="position"/>
        <!-- Accid element must allow rend in order to use fontproperties
        <xsl:call-template name="fontproperties"/> -->
      </accid>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="lyric" mode="stage1">
    <!-- Lyric sub-elements of note -->
    <verse>
      <xsl:attribute name="n">
        <xsl:choose>
          <xsl:when test="@number">
            <xsl:value-of select="@number"/>
          </xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>

      <!-- Relative vertical placement attributes go on verse -->
      <xsl:if test="@relative-y">
        <xsl:attribute name="vo">
          <xsl:value-of select="@relative-y"/>
        </xsl:attribute>
      </xsl:if>

      <xsl:for-each select="text">
        <syl>
          <xsl:choose>
            <xsl:when test="../syllabic='begin'">
              <xsl:attribute name="wordpos">i</xsl:attribute>
              <xsl:attribute name="con">d</xsl:attribute>
            </xsl:when>
            <xsl:when test="../syllabic='middle'">
              <xsl:attribute name="wordpos">m</xsl:attribute>
              <xsl:attribute name="con">d</xsl:attribute>
            </xsl:when>
            <xsl:when test="../syllabic='end'">
              <xsl:attribute name="wordpos">t</xsl:attribute>
              <xsl:if test="../extend">
                <xsl:attribute name="con">u</xsl:attribute>
              </xsl:if>
            </xsl:when>
            <xsl:when test="../syllabic='single'">
              <xsl:if test="../extend">
                <xsl:attribute name="con">u</xsl:attribute>
              </xsl:if>
            </xsl:when>
          </xsl:choose>

          <!-- Horizontal placement attributes go on syl -->
          <!-- <xsl:if test="../@default-x">
            <xsl:attribute name="x"><xsl:value-of select="../@default-x"/></xsl:attribute>
          </xsl:if> -->
          <xsl:if test="../@relative-x">
            <xsl:attribute name="ho">
              <xsl:value-of select="../@relative-x"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="../@justify">
            <xsl:attribute name="halign">
              <xsl:value-of select="../@justify"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:call-template name="fontproperties"/>
        </syl>
      </xsl:for-each>
      <xsl:if test="end-line">
        <lb/>
      </xsl:if>
      <xsl:if test="end-paragraph">
        <lb type="end-paragraph"/>
      </xsl:if>
    </verse>
  </xsl:template>

  <xsl:template match="note" mode="arpeg">
    <!-- Arpeggiated chords -->
    <arpeg>
      <xsl:attribute name="tstamp.ges">
        <xsl:call-template name="gettstamp.ges"/>
      </xsl:attribute>
      <xsl:variable name="plist">
        <xsl:apply-templates select="." mode="arpegcontinue"/>
      </xsl:variable>
      <xsl:attribute name="plist">
        <xsl:value-of select="$plist"/>
      </xsl:attribute>
      <xsl:for-each select="notations/arpeggiate">
        <xsl:call-template name="position"/>
      </xsl:for-each>

      <!-- Arpeggiate across which staves? -->
      <xsl:attribute name="staff">
        <xsl:variable name="arpegstaves">
          <xsl:apply-templates select="." mode="arpegstaff"/>
        </xsl:variable>
        <xsl:value-of select="distinct-values(tokenize($arpegstaves, ' '))"/>
      </xsl:attribute>

      <!-- Arpeggiate across which layers? -->
      <xsl:attribute name="layer">
        <xsl:variable name="arpeglayers">
          <xsl:apply-templates select="." mode="arpeglayer"/>
        </xsl:variable>
        <xsl:value-of select="distinct-values(tokenize($arpeglayers, ' '))"/>
      </xsl:attribute>
    </arpeg>
  </xsl:template>

  <xsl:template match="note" mode="arpeglayer">
    <xsl:choose>
      <xsl:when test="voice">
        <xsl:value-of select="voice"/>
      </xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
    <xsl:if test="following-sibling::note[1][chord and notations/arpeggiate]">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="following-sibling::note[1]" mode="arpeglayer"
      />
    </xsl:if>
  </xsl:template>

  <xsl:template match="note" mode="arpegstaff">
    <xsl:variable name="partID">
      <xsl:value-of select="ancestor::part[1]/@id"/>
    </xsl:variable>
    <xsl:variable name="partstaff">
      <xsl:choose>
        <xsl:when test="staff">
          <xsl:value-of select="staff"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="getstaffnum">
      <xsl:with-param name="partID">
        <xsl:value-of select="$partID"/>
      </xsl:with-param>
      <xsl:with-param name="partstaff">
        <xsl:value-of select="$partstaff"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="following-sibling::note[1][chord and notations/arpeggiate]">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="following-sibling::note[1]" mode="arpegstaff"
      />
    </xsl:if>
  </xsl:template>

  <xsl:template match="note" mode="arpegcontinue">
    <xsl:value-of select="generate-id()"/>
    <xsl:if test="following-sibling::note[1][chord and notations/arpeggiate]">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="following-sibling::note[1]"
        mode="arpegcontinue"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="ornaments" mode="stage1">
    <!-- Trills, turns -->
    <xsl:for-each select="trill-mark">
      <trill>
        <xsl:attribute name="place">
          <xsl:choose>
            <xsl:when test="@placement != ''">
              <xsl:value-of select="@placement"/>
            </xsl:when>
            <xsl:otherwise>above</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:for-each select="ancestor::note[1]">
          <xsl:attribute name="tstamp.ges">
            <xsl:call-template name="gettstamp.ges"/>
          </xsl:attribute>
          <xsl:variable name="partID">
            <xsl:value-of select="ancestor::part[1]/@id"/>
          </xsl:variable>
          <xsl:variable name="partstaff">
            <xsl:choose>
              <xsl:when test="staff">
                <xsl:value-of select="staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="staff">
            <xsl:call-template name="getstaffnum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partstaff">
                <xsl:value-of select="$partstaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="startid">
            <xsl:value-of select="generate-id()"/>
          </xsl:attribute>
        </xsl:for-each>
        <xsl:for-each select="following-sibling::*[1]">
          <xsl:if test="name()='accidental-mark'">
            <xsl:apply-templates select="." mode="amlist"/>
          </xsl:if>
        </xsl:for-each>
      </trill>
    </xsl:for-each>

    <xsl:for-each select="turn|delayed-turn">
      <turn>
        <xsl:attribute name="tstamp.ges">
          <xsl:for-each select="ancestor::note[1]">
            <xsl:call-template name="gettstamp.ges"/>
          </xsl:for-each>
        </xsl:attribute>
        <xsl:if test="name()='delayed-turn'">
          <xsl:attribute name="delayed">true</xsl:attribute>
        </xsl:if>
        <xsl:attribute name="place">
          <xsl:choose>
            <xsl:when test="@placement != ''">
              <xsl:value-of select="@placement"/>
            </xsl:when>
            <xsl:otherwise>above</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:variable name="partID">
          <xsl:value-of select="ancestor::part[1]/@id"/>
        </xsl:variable>
        <xsl:variable name="partstaff">
          <xsl:choose>
            <xsl:when test="ancestor::note[1]/staff">
              <xsl:value-of select="ancestor::note[1]/staff"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="staff">
          <xsl:call-template name="getstaffnum">
            <xsl:with-param name="partID">
              <xsl:value-of select="$partID"/>
            </xsl:with-param>
            <xsl:with-param name="partstaff">
              <xsl:value-of select="$partstaff"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:attribute>

        <xsl:call-template name="position"/>
        <xsl:for-each select="following-sibling::*[1]">
          <xsl:if test="name()='accidental-mark'">
            <xsl:apply-templates select="." mode="amlist"/>
          </xsl:if>
        </xsl:for-each>
      </turn>
    </xsl:for-each>

    <xsl:for-each select="mordent|inverted-mordent|shake">
      <mordent>
        <xsl:attribute name="tstamp.ges">
          <xsl:for-each select="ancestor::note[1]">
            <xsl:call-template name="gettstamp.ges"/>
          </xsl:for-each>
        </xsl:attribute>
        <xsl:if test="name()='mordent' or name()='inverted-mordent'">
          <xsl:if test="@long='yes'">
            <xsl:attribute name="long">true</xsl:attribute>
          </xsl:if>
        </xsl:if>
        <xsl:attribute name="place">
          <xsl:choose>
            <xsl:when test="@placement != ''">
              <xsl:value-of select="@placement"/>
            </xsl:when>
            <xsl:otherwise>above</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:variable name="partID">
          <xsl:value-of select="ancestor::part[1]/@id"/>
        </xsl:variable>
        <xsl:variable name="partstaff">
          <xsl:choose>
            <xsl:when test="ancestor::note[1]/staff">
              <xsl:value-of select="ancestor::note[1]/staff"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="staff">
          <xsl:call-template name="getstaffnum">
            <xsl:with-param name="partID">
              <xsl:value-of select="$partID"/>
            </xsl:with-param>
            <xsl:with-param name="partstaff">
              <xsl:value-of select="$partstaff"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:if test="name()='inverted-mordent' or name()='shake'">
          <xsl:attribute name="form">inv</xsl:attribute>
        </xsl:if>
        <xsl:call-template name="position"/>
        <xsl:for-each select="following-sibling::*[1]">
          <xsl:if test="name()='accidental-mark'">
            <xsl:apply-templates select="." mode="amlist"/>
          </xsl:if>
        </xsl:for-each>
      </mordent>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="accidental-mark" mode="amlist">
    <!-- Accidentals attached to ornaments -->
    <xsl:if test="@placement='above'">
      <xsl:attribute name="accidupper">
        <xsl:choose>
          <xsl:when test=". = 'sharp'">s</xsl:when>
          <xsl:when test=". = 'natural'">n</xsl:when>
          <xsl:when test=". = 'flat'">f</xsl:when>
          <xsl:when test=". = 'double-sharp'">x</xsl:when>
          <xsl:when test=". = 'sharp-sharp'">ss</xsl:when>
          <xsl:when test=". = 'flat-flat'">ff</xsl:when>
          <xsl:when test=". = 'natural-sharp'">ns</xsl:when>
          <xsl:when test=". = 'natural-flat'">nf</xsl:when>
          <xsl:when test=". = 'quarter-flat'">fd</xsl:when>
          <xsl:when test=". = 'quarter-sharp'">su</xsl:when>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@placement='below'">
      <xsl:attribute name="accidlower">
        <xsl:choose>
          <xsl:when test=". = 'sharp'">s</xsl:when>
          <xsl:when test=". = 'natural'">n</xsl:when>
          <xsl:when test=". = 'flat'">f</xsl:when>
          <xsl:when test=". = 'double-sharp'">x</xsl:when>
          <xsl:when test=". = 'sharp-sharp'">ss</xsl:when>
          <xsl:when test=". = 'flat-flat'">ff</xsl:when>
          <xsl:when test=". = 'natural-sharp'">ns</xsl:when>
          <xsl:when test=". = 'natural-flat'">nf</xsl:when>
          <xsl:when test=". = 'quarter-flat'">fd</xsl:when>
          <xsl:when test=". = 'quarter-sharp'">su</xsl:when>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:for-each select="following-sibling::*[1]">
      <xsl:if test="name()='accidental-mark'">
        <xsl:apply-templates select="." mode="amlist"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="fermata" mode="stage1">
    <fermata>
      <xsl:attribute name="place">
        <xsl:choose>
          <xsl:when test="@type='upright'">above</xsl:when>
          <xsl:when test="@type='inverted'">below</xsl:when>
          <xsl:otherwise>above</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:for-each select="ancestor::note[1]">
        <xsl:variable name="partID">
          <xsl:value-of select="ancestor::part/@id"/>
        </xsl:variable>
        <xsl:variable name="partstaff">
          <xsl:choose>
            <xsl:when test="staff">
              <xsl:value-of select="staff"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="staff">
          <xsl:call-template name="getstaffnum">
            <xsl:with-param name="partID">
              <xsl:value-of select="$partID"/>
            </xsl:with-param>
            <xsl:with-param name="partstaff">
              <xsl:value-of select="$partstaff"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:attribute name="tstamp.ges">
          <xsl:call-template name="gettstamp.ges"/>
        </xsl:attribute>
        <xsl:attribute name="startid">
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:call-template name="position"/>
      <xsl:attribute name="form">
        <xsl:choose>
          <xsl:when test="@type='inverted'">
            <xsl:text>inv</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>norm</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </fermata>
  </xsl:template>

  <xsl:template name="beatunitdur">
    <!-- Notated duration derived from metronome beat-unit sub-element -->
    <xsl:choose>
      <xsl:when test="normalize-space(.) = 'long'">
        <xsl:text>&#x1D1B8;</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space(.) = 'breve'">
        <xsl:text>&#x1D15C;</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space(.) = 'whole'">
        <xsl:text>&#x1D15D;</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space(.) = 'half'">
        <xsl:text>&#x1D15E;</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space(.) = 'quarter'">
        <xsl:text>&#x1D15F;</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space(.) = 'eighth'">
        <xsl:text>&#x1D160;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:analyze-string select="normalize-space(type)"
          regex="^([0-9]+)(.*)$">
          <xsl:matching-substring>
            <xsl:text disable-output-escaping="yes">&amp;note</xsl:text>
            <xsl:value-of select="regex-group(1)"/>
            <xsl:text>;</xsl:text>
          </xsl:matching-substring>
        </xsl:analyze-string>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="notateddur">
    <!-- Notated duration derived from type element -->
    <xsl:choose>
      <xsl:when test="normalize-space(type) = 'long'">
        <xsl:text>long</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space(type) = 'breve'">
        <xsl:text>breve</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space(type) = 'whole'">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space(type) = 'half'">
        <xsl:text>2</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space(type) = 'quarter'">
        <xsl:text>4</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space(type) = 'eighth'">
        <xsl:text>8</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:analyze-string select="normalize-space(type)"
          regex="^([0-9]+)(.*)$">
          <xsl:matching-substring>
            <xsl:value-of select="regex-group(1)"/>
          </xsl:matching-substring>
        </xsl:analyze-string>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="notateddot">
    <!-- Notated dotted values -->
    <xsl:if test="dot">
      <xsl:attribute name="dots">
        <xsl:value-of select="count(dot)"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="fermata.attr">
    <!-- Is there a fermata? -->
    <xsl:for-each select="notations/fermata[1]">
      <xsl:choose>
        <xsl:when test="@type='upright'">
          <xsl:attribute name="fermata">above</xsl:attribute>
        </xsl:when>
        <xsl:when test="@type='inverted'">
          <xsl:attribute name="fermata">below</xsl:attribute>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="gesturaldur">
    <!-- Gestural duration -->
    <xsl:attribute name="dur.ges">
      <xsl:choose>
        <xsl:when test="grace">
          <xsl:text>0</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="duration"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="size">
    <!-- Notehead size -->
    <xsl:choose>
      <xsl:when test="cue">
        <xsl:attribute name="size">cue</xsl:attribute>
      </xsl:when>
      <xsl:when test="type/@size='cue'">
        <xsl:attribute name="size">cue</xsl:attribute>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="part-layer-staff-beam-assign">
    <xsl:variable name="partID">
      <xsl:value-of select="ancestor::part[1]/@id"/>
    </xsl:variable>

    <!-- Part assignment -->
    <xsl:attribute name="part">
      <xsl:value-of select="$partID"/>
    </xsl:attribute>

    <!-- Layer (voice) assignment -->
    <!-- This is a voice within a part, not a layer on a staff as in MEI. -->
    <xsl:variable name="thisvoice">
      <xsl:choose>
        <xsl:when test="voice">
          <xsl:value-of select="voice"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="layer">
      <xsl:value-of select="$thisvoice"/>
    </xsl:attribute>

    <!-- Staff assignment -->
    <xsl:variable name="partstaff">
      <xsl:choose>
        <xsl:when test="staff">
          <xsl:value-of select="staff"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="staff">
      <xsl:call-template name="getstaffnum">
        <xsl:with-param name="partID">
          <xsl:value-of select="$partID"/>
        </xsl:with-param>
        <xsl:with-param name="partstaff">
          <xsl:value-of select="$partstaff"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:attribute>

    <!-- Beam assignment -->
    <!-- MEI only records the start, continuation, and end of the primary beam -->
    <xsl:choose>
      <xsl:when test="beam[@number='1']='begin'">
        <xsl:variable name="beamlevel">
          <xsl:value-of
            select="(count(preceding-sibling::*[beam[@number='1']='begin' and voice=$thisvoice]) + 1) - count(preceding-sibling::*[beam[@number='1']='end' and voice=$thisvoice])"
          />
        </xsl:variable>
        <xsl:attribute name="beam">i<xsl:value-of select="$beamlevel"
          /></xsl:attribute>
      </xsl:when>
      <xsl:when test="beam[@number ='1']='continue'">
        <xsl:variable name="beamlevel">
          <xsl:value-of
            select="count(preceding-sibling::*[beam[@number='1']='begin' and voice=$thisvoice]) - count(preceding-sibling::*[beam[@number='1']='end' and voice=$thisvoice])"
          />
        </xsl:variable>
        <xsl:attribute name="beam">m<xsl:value-of select="$beamlevel"
          /></xsl:attribute>
      </xsl:when>
      <xsl:when test="beam[@number='1']='end'">
        <xsl:variable name="beamlevel">
          <xsl:value-of
            select="count(preceding-sibling::*[beam[@number='1']='begin' and voice=$thisvoice]) - count(preceding-sibling::*[beam[@number='1']='end' and voice=$thisvoice])"
          />
        </xsl:variable>
        <xsl:attribute name="beam">t<xsl:value-of select="$beamlevel"
          /></xsl:attribute>
      </xsl:when>
      <xsl:when
        test="rest and (preceding-sibling::*[beam][1]/beam='begin' or 
                      preceding-sibling::*[beam][1]/beam='continue') and
                      (following-sibling::*[beam][1]/beam='end' or following-sibling::*[beam][1]/beam='continue')">
        <!-- In MusicXML rests under a beam do not have a 'continue' beam element so this data has to be supplied. -->
        <xsl:if
          test="preceding-sibling::*[beam][1]/voice=$thisvoice and following-sibling::*[beam][1]/voice=$thisvoice">
          <xsl:variable name="beamlevel">
            <xsl:value-of
              select="count(preceding-sibling::*[beam[@number='1']='begin' and voice=$thisvoice]) - count(preceding-sibling::*[beam[@number='1']='end' and voice=$thisvoice])"
            />
          </xsl:variable>
          <xsl:attribute name="beam">m<xsl:value-of select="$beamlevel"
            /></xsl:attribute>
        </xsl:if>
      </xsl:when>
    </xsl:choose>

    <!-- Tuplet attribute -->
    <xsl:if test="notations/tuplet or time-modification">
      <xsl:attribute name="tuplet">
        <xsl:choose>
          <xsl:when test="notations/tuplet[@type='start']">
            <xsl:text>i</xsl:text>
            <xsl:choose>
              <xsl:when test="notations/tuplet/@number">
                <xsl:value-of select="notations/tuplet/@number"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="notations/tuplet[@type='stop']">
            <xsl:text>t</xsl:text>
            <xsl:choose>
              <xsl:when test="notations/tuplet/@number">
                <xsl:value-of select="notations/tuplet/@number"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <!-- MusicXML doesn't have a tuplet of type 'continue' -->
            <xsl:text>m</xsl:text>
            <xsl:choose>
              <xsl:when
                test="preceding::note[notations/tuplet][1]/notations/tuplet/@number">
                <xsl:value-of
                  select="preceding::note[notations/tuplet][1]/notations/tuplet/@number"
                />
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="restvo">
    <!-- This template only applies to rests! -->
    <!-- Right now vertical position is a copy of the display-step and
         display-octave elements. -->
    <!-- Ought to calculate from relative-y, absolute-y being unwieldy when it
         comes to transposing parts; however, relative-y isn't used in the Beyond
         MIDI examples. -->
    <xsl:if test="rest/display-step">
      <xsl:attribute name="vo">
        <xsl:value-of select="rest/display-step"/>
        <xsl:value-of select="rest/display-octave"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="restvo2">
    <!-- MusicXML display-step and display-octave are converted to interline units -->
    <xsl:variable name="thisstaff">
      <xsl:value-of select="ancestor::staff/@n"/>
    </xsl:variable>
    <xsl:variable name="whereclef">
      <xsl:value-of
        select="name(preceding::*[(name()='staffdef' and
                              @n=$thisstaff and @clef.shape) or
                             (name()='staff' and @n=$thisstaff and layer/clefchange)][1])"
      />
    </xsl:variable>
    <xsl:variable name="clefshape">
      <xsl:choose>
        <xsl:when test="$whereclef='staffdef'">
          <xsl:value-of
            select="preceding::staffdef[@n=$thisstaff][@clef.shape][1]/@clef.shape"
          />
        </xsl:when>
        <xsl:when test="$whereclef='staff'">
          <xsl:value-of
            select="preceding::staff[@n=$thisstaff and layer/clefchange][1]/layer/clefchange[position()=last()]/@shape"
          />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="clefline">
      <xsl:choose>
        <xsl:when test="$whereclef='staffdef'">
          <xsl:value-of
            select="preceding::staffdef[@n=$thisstaff][@clef.line][1]/@clef.line"
          />
        </xsl:when>
        <xsl:when test="$whereclef='staff'">
          <xsl:value-of
            select="preceding::staff[@n=$thisstaff and layer/clefchange][1]/layer/clefchange[position()=last()]/@line"
          />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="display-step">
      <xsl:value-of select="substring(@vo,1,1)"/>
    </xsl:variable>
    <xsl:variable name="display-octave">
      <xsl:value-of select="substring(@vo,2,1)"/>
    </xsl:variable>

    <xsl:choose>
      <!-- treble clef -->
      <xsl:when test="$clefshape='G' and $clefline='2'">
        <xsl:choose>
          <xsl:when test="$display-step='C' and $display-octave='3'"
            >-13</xsl:when>
          <xsl:when test="$display-step='D' and $display-octave='3'"
            >-12</xsl:when>
          <xsl:when test="$display-step='E' and $display-octave='3'"
            >-11</xsl:when>
          <xsl:when test="$display-step='F' and $display-octave='3'"
            >-10</xsl:when>
          <xsl:when test="$display-step='G' and $display-octave='3'"
            >-9</xsl:when>
          <xsl:when test="$display-step='A' and $display-octave='3'"
            >-8</xsl:when>
          <xsl:when test="$display-step='B' and $display-octave='3'"
            >-7</xsl:when>
          <xsl:when test="$display-step='C' and $display-octave='4'"
            >-6</xsl:when>
          <xsl:when test="$display-step='D' and $display-octave='4'"
            >-5</xsl:when>
          <xsl:when test="$display-step='E' and $display-octave='4'"
            >-4</xsl:when>
          <xsl:when test="$display-step='F' and $display-octave='4'"
            >-3</xsl:when>
          <xsl:when test="$display-step='G' and $display-octave='4'"
            >-2</xsl:when>
          <xsl:when test="$display-step='A' and $display-octave='4'"
            >-1</xsl:when>
          <xsl:when test="$display-step='B' and $display-octave='4'"
            >0</xsl:when>
          <xsl:when test="$display-step='C' and $display-octave='5'"
            >1</xsl:when>
          <xsl:when test="$display-step='D' and $display-octave='5'"
            >2</xsl:when>
          <xsl:when test="$display-step='E' and $display-octave='5'"
            >3</xsl:when>
          <xsl:when test="$display-step='F' and $display-octave='5'"
            >4</xsl:when>
          <xsl:when test="$display-step='G' and $display-octave='5'"
            >5</xsl:when>
          <xsl:when test="$display-step='A' and $display-octave='5'"
            >6</xsl:when>
          <xsl:when test="$display-step='B' and $display-octave='5'"
            >7</xsl:when>
          <xsl:when test="$display-step='C' and $display-octave='6'"
            >8</xsl:when>
          <xsl:when test="$display-step='D' and $display-octave='6'"
            >9</xsl:when>
          <xsl:when test="$display-step='E' and $display-octave='6'"
            >10</xsl:when>
          <xsl:when test="$display-step='F' and $display-octave='6'"
            >11</xsl:when>
          <xsl:when test="$display-step='G' and $display-octave='6'"
            >12</xsl:when>
          <xsl:when test="$display-step='A' and $display-octave='6'"
            >13</xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- bass clef -->
      <xsl:when test="$clefshape='F' and $clefline='4'">
        <xsl:choose>
          <xsl:when test="$display-step='E' and $display-octave='1'"
            >-13</xsl:when>
          <xsl:when test="$display-step='F' and $display-octave='1'"
            >-12</xsl:when>
          <xsl:when test="$display-step='G' and $display-octave='1'"
            >-11</xsl:when>
          <xsl:when test="$display-step='A' and $display-octave='1'"
            >-10</xsl:when>
          <xsl:when test="$display-step='B' and $display-octave='1'"
            >-9</xsl:when>
          <xsl:when test="$display-step='C' and $display-octave='2'"
            >-8</xsl:when>
          <xsl:when test="$display-step='D' and $display-octave='2'"
            >-7</xsl:when>
          <xsl:when test="$display-step='E' and $display-octave='2'"
            >-6</xsl:when>
          <xsl:when test="$display-step='F' and $display-octave='2'"
            >-5</xsl:when>
          <xsl:when test="$display-step='G' and $display-octave='2'"
            >-4</xsl:when>
          <xsl:when test="$display-step='A' and $display-octave='2'"
            >-3</xsl:when>
          <xsl:when test="$display-step='B' and $display-octave='2'"
            >-2</xsl:when>
          <xsl:when test="$display-step='C' and $display-octave='3'"
            >-1</xsl:when>
          <xsl:when test="$display-step='D' and $display-octave='3'"
            >0</xsl:when>
          <xsl:when test="$display-step='E' and $display-octave='3'"
            >1</xsl:when>
          <xsl:when test="$display-step='F' and $display-octave='3'"
            >2</xsl:when>
          <xsl:when test="$display-step='G' and $display-octave='3'"
            >3</xsl:when>
          <xsl:when test="$display-step='A' and $display-octave='3'"
            >4</xsl:when>
          <xsl:when test="$display-step='B' and $display-octave='3'"
            >5</xsl:when>
          <xsl:when test="$display-step='C' and $display-octave='4'"
            >6</xsl:when>
          <xsl:when test="$display-step='D' and $display-octave='4'"
            >7</xsl:when>
          <xsl:when test="$display-step='E' and $display-octave='4'"
            >8</xsl:when>
          <xsl:when test="$display-step='F' and $display-octave='4'"
            >9</xsl:when>
          <xsl:when test="$display-step='G' and $display-octave='4'"
            >10</xsl:when>
          <xsl:when test="$display-step='A' and $display-octave='4'"
            >11</xsl:when>
          <xsl:when test="$display-step='B' and $display-octave='4'"
            >12</xsl:when>
          <xsl:when test="$display-step='C' and $display-octave='5'"
            >13</xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- mezzo-soprano clef -->
      <xsl:when test="$clefshape='C' and $clefline='4'">
        <xsl:choose>
          <xsl:when test="$display-step='C' and $display-octave='2'"
            >-13</xsl:when>
          <xsl:when test="$display-step='D' and $display-octave='2'"
            >-12</xsl:when>
          <xsl:when test="$display-step='E' and $display-octave='2'"
            >-11</xsl:when>
          <xsl:when test="$display-step='F' and $display-octave='2'"
            >-10</xsl:when>
          <xsl:when test="$display-step='G' and $display-octave='2'"
            >-9</xsl:when>
          <xsl:when test="$display-step='A' and $display-octave='2'"
            >-8</xsl:when>
          <xsl:when test="$display-step='B' and $display-octave='2'"
            >-7</xsl:when>
          <xsl:when test="$display-step='C' and $display-octave='3'"
            >-6</xsl:when>
          <xsl:when test="$display-step='D' and $display-octave='3'"
            >-5</xsl:when>
          <xsl:when test="$display-step='E' and $display-octave='3'"
            >-4</xsl:when>
          <xsl:when test="$display-step='F' and $display-octave='3'"
            >-3</xsl:when>
          <xsl:when test="$display-step='G' and $display-octave='3'"
            >-2</xsl:when>
          <xsl:when test="$display-step='A' and $display-octave='3'"
            >-1</xsl:when>
          <xsl:when test="$display-step='B' and $display-octave='3'"
            >0</xsl:when>
          <xsl:when test="$display-step='C' and $display-octave='4'"
            >1</xsl:when>
          <xsl:when test="$display-step='D' and $display-octave='4'"
            >2</xsl:when>
          <xsl:when test="$display-step='E' and $display-octave='4'"
            >4</xsl:when>
          <xsl:when test="$display-step='F' and $display-octave='4'"
            >5</xsl:when>
          <xsl:when test="$display-step='G' and $display-octave='4'"
            >6</xsl:when>
          <xsl:when test="$display-step='A' and $display-octave='4'"
            >7</xsl:when>
          <xsl:when test="$display-step='B' and $display-octave='4'"
            >8</xsl:when>
          <xsl:when test="$display-step='C' and $display-octave='5'"
            >9</xsl:when>
          <xsl:when test="$display-step='D' and $display-octave='5'"
            >10</xsl:when>
          <xsl:when test="$display-step='E' and $display-octave='5'"
            >11</xsl:when>
          <xsl:when test="$display-step='F' and $display-octave='5'"
            >12</xsl:when>
          <xsl:when test="$display-step='G' and $display-octave='5'"
            >13</xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- alto clef -->
      <xsl:when test="$clefshape='C' and $clefline='3'">
        <xsl:choose>
          <xsl:when test="$display-step='E' and $display-octave='2'"
            >-13</xsl:when>
          <xsl:when test="$display-step='F' and $display-octave='2'"
            >-12</xsl:when>
          <xsl:when test="$display-step='G' and $display-octave='2'"
            >-11</xsl:when>
          <xsl:when test="$display-step='A' and $display-octave='2'"
            >-10</xsl:when>
          <xsl:when test="$display-step='B' and $display-octave='2'"
            >-9</xsl:when>
          <xsl:when test="$display-step='C' and $display-octave='3'"
            >-8</xsl:when>
          <xsl:when test="$display-step='D' and $display-octave='3'"
            >-7</xsl:when>
          <xsl:when test="$display-step='E' and $display-octave='3'"
            >-6</xsl:when>
          <xsl:when test="$display-step='F' and $display-octave='3'"
            >-5</xsl:when>
          <xsl:when test="$display-step='G' and $display-octave='3'"
            >-4</xsl:when>
          <xsl:when test="$display-step='A' and $display-octave='3'"
            >-3</xsl:when>
          <xsl:when test="$display-step='B' and $display-octave='3'"
            >-2</xsl:when>
          <xsl:when test="$display-step='C' and $display-octave='4'"
            >-1</xsl:when>
          <xsl:when test="$display-step='D' and $display-octave='4'"
            >0</xsl:when>
          <xsl:when test="$display-step='E' and $display-octave='4'"
            >1</xsl:when>
          <xsl:when test="$display-step='F' and $display-octave='4'"
            >2</xsl:when>
          <xsl:when test="$display-step='G' and $display-octave='4'"
            >4</xsl:when>
          <xsl:when test="$display-step='A' and $display-octave='4'"
            >5</xsl:when>
          <xsl:when test="$display-step='B' and $display-octave='4'"
            >6</xsl:when>
          <xsl:when test="$display-step='C' and $display-octave='5'"
            >7</xsl:when>
          <xsl:when test="$display-step='D' and $display-octave='5'"
            >8</xsl:when>
          <xsl:when test="$display-step='E' and $display-octave='5'"
            >9</xsl:when>
          <xsl:when test="$display-step='F' and $display-octave='5'"
            >10</xsl:when>
          <xsl:when test="$display-step='G' and $display-octave='5'"
            >11</xsl:when>
          <xsl:when test="$display-step='A' and $display-octave='5'"
            >12</xsl:when>
          <xsl:when test="$display-step='B' and $display-octave='5'"
            >13</xsl:when>
        </xsl:choose>
      </xsl:when>
      <!-- tenor clef -->
      <xsl:when test="$clefshape='C' and $clefline='2'">
        <xsl:choose>
          <xsl:when test="$display-step='G' and $display-octave='2'"
            >-13</xsl:when>
          <xsl:when test="$display-step='A' and $display-octave='2'"
            >-12</xsl:when>
          <xsl:when test="$display-step='B' and $display-octave='2'"
            >-11</xsl:when>
          <xsl:when test="$display-step='C' and $display-octave='3'"
            >-10</xsl:when>
          <xsl:when test="$display-step='D' and $display-octave='3'"
            >-9</xsl:when>
          <xsl:when test="$display-step='E' and $display-octave='3'"
            >-8</xsl:when>
          <xsl:when test="$display-step='F' and $display-octave='3'"
            >-7</xsl:when>
          <xsl:when test="$display-step='G' and $display-octave='3'"
            >-6</xsl:when>
          <xsl:when test="$display-step='A' and $display-octave='3'"
            >-5</xsl:when>
          <xsl:when test="$display-step='B' and $display-octave='3'"
            >-4</xsl:when>
          <xsl:when test="$display-step='C' and $display-octave='4'"
            >-3</xsl:when>
          <xsl:when test="$display-step='D' and $display-octave='4'"
            >-2</xsl:when>
          <xsl:when test="$display-step='E' and $display-octave='r'"
            >-1</xsl:when>
          <xsl:when test="$display-step='F' and $display-octave='4'"
            >0</xsl:when>
          <xsl:when test="$display-step='G' and $display-octave='4'"
            >1</xsl:when>
          <xsl:when test="$display-step='A' and $display-octave='4'"
            >2</xsl:when>
          <xsl:when test="$display-step='B' and $display-octave='4'"
            >3</xsl:when>
          <xsl:when test="$display-step='C' and $display-octave='5'"
            >4</xsl:when>
          <xsl:when test="$display-step='D' and $display-octave='5'"
            >5</xsl:when>
          <xsl:when test="$display-step='E' and $display-octave='5'"
            >6</xsl:when>
          <xsl:when test="$display-step='F' and $display-octave='5'"
            >7</xsl:when>
          <xsl:when test="$display-step='G' and $display-octave='5'"
            >8</xsl:when>
          <xsl:when test="$display-step='A' and $display-octave='5'"
            >9</xsl:when>
          <xsl:when test="$display-step='B' and $display-octave='5'"
            >10</xsl:when>
          <xsl:when test="$display-step='C' and $display-octave='6'"
            >11</xsl:when>
          <xsl:when test="$display-step='D' and $display-octave='6'"
            >12</xsl:when>
          <xsl:when test="$display-step='E' and $display-octave='6'"
            >13</xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="artics">
    <!-- This template creates the note's artic attribute.  Use the articulations
    template for artic sub-elements. -->
    <xsl:variable name="articlist">
      <xsl:for-each select="notations/articulations/*">
        <xsl:choose>
          <!-- General use articulations -->
          <xsl:when test="name()='accent'">
            <xsl:text>acc</xsl:text>
          </xsl:when>
          <xsl:when test="name()='strong-accent'">
            <xsl:text>marc</xsl:text>
          </xsl:when>
          <xsl:when test="name()='staccato'">
            <xsl:text>stacc</xsl:text>
          </xsl:when>
          <xsl:when test="name()='tenuto'">
            <xsl:text>ten</xsl:text>
          </xsl:when>
          <xsl:when test="name()='detached-legato'">
            <xsl:text>ten-stacc</xsl:text>
          </xsl:when>
          <xsl:when test="name()='staccatissimo'">
            <xsl:text>stacciss</xsl:text>
          </xsl:when>
          <!-- String articulations -->
          <xsl:when test="name()='spiccato'">
            <xsl:text>spicc</xsl:text>
          </xsl:when>
          <!-- Jazz articulations -->
          <xsl:when test="name()='scoop'">
            <xsl:text>rip</xsl:text>
          </xsl:when>
          <xsl:when test="name()='plop'">
            <xsl:text>plop</xsl:text>
          </xsl:when>
          <xsl:when test="name()='doit'">
            <xsl:text>doit</xsl:text>
          </xsl:when>
          <xsl:when test="name()='falloff'">
            <xsl:text>fall</xsl:text>
          </xsl:when>
          <xsl:when test="name()='caesura'">
            <!-- This is a no-op. In MEI a caesura is a control element, not a note
                 articulation and is processed along with other control elements in
                 the measure template. -->
          </xsl:when>
        </xsl:choose>
        <xsl:if test="position() != last()">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:for-each select="notations/technical/*">
        <xsl:choose>
          <!-- String articulations -->
          <xsl:when test="name()='up-bow'">
            <xsl:text>upbow</xsl:text>
          </xsl:when>
          <xsl:when test="name()='down-bow'">
            <xsl:text>dnbow</xsl:text>
          </xsl:when>
          <xsl:when test="name()='harmonic'">
            <xsl:text>harm</xsl:text>
          </xsl:when>
          <xsl:when test="name()='open-string'">
            <xsl:text>open</xsl:text>
          </xsl:when>
          <xsl:when test="name()='snap-pizzicato'">
            <xsl:text>snap</xsl:text>
          </xsl:when>
          <xsl:when test="name()='tap'">
            <xsl:text>tap</xsl:text>
          </xsl:when>
          <xsl:when test="name()='pluck'">
            <xsl:text>lhpizz</xsl:text>
          </xsl:when>
          <!-- Wind articulations -->
          <xsl:when test="name()='double-tongue'">
            <xsl:text>dbltongue</xsl:text>
          </xsl:when>
          <xsl:when test="name()='triple-tongue'">
            <xsl:text>trpltongue</xsl:text>
          </xsl:when>
          <xsl:when test="name()='stopped'">
            <xsl:text>stop</xsl:text>
          </xsl:when>
          <xsl:when test="name()='bend'">
            <xsl:text>bend</xsl:text>
          </xsl:when>
          <!-- Keyboard/organ articulations -->
          <xsl:when test="name()='heel'">
            <xsl:text>heel</xsl:text>
          </xsl:when>
          <xsl:when test="name()='toe'">
            <xsl:text>toe</xsl:text>
          </xsl:when>
          <xsl:when test="name()='fingernails'">
            <xsl:text>fingernail</xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:if test="position() != last()">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="normalize-space($articlist) != ''">
      <xsl:attribute name="artic">
        <xsl:value-of select="$articlist"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="articulations">
    <!-- This template creates artic sub-elements so that placement of the articulations
    can be recorded. -->
    <xsl:for-each select="notations/articulations/*">
      <artic>
        <xsl:choose>
          <xsl:when test="name()='accent'">
            <xsl:attribute name="artic">acc</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="name()='strong-accent'">
            <xsl:attribute name="artic">marc</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="name()='staccato'">
            <xsl:attribute name="artic">stacc</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="name()='tenuto'">
            <xsl:attribute name="artic">ten</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="name()='detached-legato'">
            <xsl:attribute name="artic">ten-stacc</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="name()='staccatissimo'">
            <xsl:attribute name="artic">stacciss</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
        <xsl:call-template name="position"/>
        <!-- The artic element must allow rend in order to use fontproperties -->
        <!-- <xsl:call-template name="fontproperties"/> -->
      </artic>
    </xsl:for-each>

    <xsl:for-each
      select="notations/technical/*[not(name()='string' or name()='fret' or name()='pull-off')]">
      <!-- Tests for string and jazz articulations and for notation/technical elements
      other than tab string and fret indications and pull-offs which are handled elsewhere.
      What about hammer-ons? -->
      <artic>
        <xsl:choose>
          <xsl:when test="name()='up-bow'">
            <xsl:attribute name="artic">upbow</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="name()='down-bow'">
            <xsl:attribute name="artic">dnbow</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="name()='harmonic'">
            <xsl:attribute name="artic">harm</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="name()='open-string'">
            <xsl:attribute name="artic">open</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="name()='snap-pizzicato'">
            <xsl:attribute name="artic">snap</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="name()='tap'">
            <xsl:attribute name="artic">tap</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="name()='pluck'">
            <xsl:attribute name="artic">lhpizz</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="name()='double-tongue'">
            <xsl:attribute name="artic">dbltongue</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="name()='triple-tongue'">
            <xsl:attribute name="artic">trpltongue</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="name()='stopped'">
            <xsl:attribute name="artic">stop</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="name()='bend'">
            <xsl:attribute name="artic">bend</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="name()='heel'">
            <xsl:attribute name="artic">heel</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="name()='toe'">
            <xsl:attribute name="artic">toe</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="name()='fingernails'">
            <xsl:attribute name="artic">fingernail</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
        <xsl:call-template name="position"/>
        <!-- The artic element must allow rend in order to use fontproperties -->
        <!-- <xsl:call-template name="fontproperties"/> -->
      </artic>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="getdurpulloff">
    <!-- Find terminal note for pull-off -->
    <!-- Assumes that pull-off elements ALWAYS have number attributes -->
    <xsl:variable name="level">
      <xsl:value-of select="@number"/>
    </xsl:variable>
    <xsl:variable name="startmeasureid">
      <xsl:value-of select="generate-id(ancestor::measure[1])"/>
    </xsl:variable>
    <xsl:variable name="startmeasurepos">
      <xsl:for-each select="//measure">
        <xsl:if test="generate-id()=$startmeasureid">
          <xsl:value-of select="position()"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="thispart">
      <xsl:value-of select="ancestor::part[1]/@id"/>
    </xsl:variable>
    <xsl:for-each
      select="following::note[notations/technical/pull-off[@number=$level and @type='stop'] and ancestor::part[1]/@id=$thispart][1]">
      <xsl:variable name="endmeasureid">
        <xsl:value-of select="generate-id(ancestor::measure[1])"/>
      </xsl:variable>
      <xsl:variable name="endmeasurepos">
        <xsl:for-each select="//measure">
          <xsl:if test="generate-id()=$endmeasureid">
            <xsl:value-of select="position()"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="$endmeasurepos - $startmeasurepos"/>
      <xsl:text>m+</xsl:text>
      <xsl:call-template name="gettstamp.ges"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="getdurwords">
    <!-- Get terminal note for text string -->
    <!-- Assumes that dash elements ALWAYS have number attributes -->
    <xsl:variable name="dashnumber">
      <xsl:value-of select="@number"/>
    </xsl:variable>
    <xsl:variable name="startmeasureid">
      <xsl:value-of select="generate-id(ancestor::measure[1])"/>
    </xsl:variable>
    <xsl:variable name="startmeasurepos">
      <xsl:for-each select="//measure">
        <xsl:if test="generate-id()=$startmeasureid">
          <xsl:value-of select="position()"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="thispart">
      <xsl:value-of select="ancestor::part[1]/@id"/>
    </xsl:variable>
    <xsl:for-each
      select="following::direction[direction-type/dashes[@number=$dashnumber and @type='stop'] and ancestor::part[1]/@id=$thispart][1]">
      <xsl:variable name="endmeasureid">
        <xsl:value-of select="generate-id(ancestor::measure[1])"/>
      </xsl:variable>
      <xsl:variable name="endmeasurepos">
        <xsl:for-each select="//measure">
          <xsl:if test="generate-id()=$endmeasureid">
            <xsl:value-of select="position()"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="$endmeasurepos - $startmeasurepos"/>
      <xsl:text>m+</xsl:text>
      <xsl:call-template name="gettstamp.ges"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="getdurhairpin">
    <!-- Get terminal point of hairpin -->
    <!-- Assumes hairpins are NOT nested, i.e., have no number attributes -->
    <xsl:variable name="startmeasureid">
      <xsl:value-of select="generate-id(ancestor::measure[1])"/>
    </xsl:variable>
    <xsl:variable name="startmeasurepos">
      <xsl:for-each select="//measure">
        <xsl:if test="generate-id()=$startmeasureid">
          <xsl:value-of select="position()"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="thispart">
      <xsl:value-of select="ancestor::part[1]/@id"/>
    </xsl:variable>
    <xsl:for-each
      select="following::direction[direction-type/wedge[@type='stop'] and ancestor::part[1]/@id=$thispart][1]">
      <xsl:variable name="endmeasureid">
        <xsl:value-of select="generate-id(ancestor::measure[1])"/>
      </xsl:variable>
      <xsl:variable name="endmeasurepos">
        <xsl:for-each select="//measure">
          <xsl:if test="generate-id()=$endmeasureid">
            <xsl:value-of select="position()"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="$endmeasurepos - $startmeasurepos"/>
      <xsl:text>m+</xsl:text>
      <xsl:call-template name="gettstamp.ges"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="getduroctave">
    <!-- Get terminal point of octave shift indication -->
    <!-- Assumes octave-shift elements are NOT nested, i.e., have no number attributes -->
    <xsl:variable name="startmeasureid">
      <xsl:value-of select="generate-id(ancestor::measure[1])"/>
    </xsl:variable>
    <xsl:variable name="startmeasurepos">
      <xsl:for-each select="//measure">
        <xsl:if test="generate-id()=$startmeasureid">
          <xsl:value-of select="position()"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="thispart">
      <xsl:value-of select="ancestor::part[1]/@id"/>
    </xsl:variable>
    <xsl:for-each
      select="following::direction[direction-type/octave-shift[@type='stop'] and ancestor::part[1]/@id=$thispart][1]">
      <xsl:variable name="endmeasureid">
        <xsl:value-of select="generate-id(ancestor::measure[1])"/>
      </xsl:variable>
      <xsl:variable name="endmeasurepos">
        <xsl:for-each select="//measure">
          <xsl:if test="generate-id()=$endmeasureid">
            <xsl:value-of select="position()"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:value-of select="$endmeasurepos - $startmeasurepos"/>
      <xsl:text>m+</xsl:text>
      <xsl:call-template name="gettstamp.ges"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="getphraseend">
    <!-- Find terminal point of phrase -->
    <!-- Assumes that slur elements ALWAYS have number attributes -->
    <xsl:variable name="slurnumber">
      <xsl:value-of select="@number"/>
    </xsl:variable>
    <xsl:variable name="startmeasureid">
      <xsl:value-of select="generate-id(ancestor::measure[1])"/>
    </xsl:variable>
    <xsl:variable name="startmeasurepos">
      <xsl:for-each select="//measure">
        <xsl:if test="generate-id()=$startmeasureid">
          <xsl:value-of select="position()"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="thispart">
      <xsl:value-of select="ancestor::part[1]/@id"/>
    </xsl:variable>
    <xsl:variable name="bezierstart">
      <xsl:value-of select="@bezier-x"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@bezier-y"/>
    </xsl:variable>
    <xsl:variable name="partID">
      <xsl:value-of select="ancestor::part[1]/@id"/>
    </xsl:variable>
    <xsl:variable name="partstaff">
      <xsl:choose>
        <xsl:when test="ancestor::note[1]/staff">
          <xsl:value-of select="ancestor::note[1]/staff"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="staff1">
      <xsl:call-template name="getstaffnum">
        <xsl:with-param name="partID">
          <xsl:value-of select="$partID"/>
        </xsl:with-param>
        <xsl:with-param name="partstaff">
          <xsl:value-of select="$partstaff"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when
        test="preceding::note[notations/slur[@type='stop' and @number=$slurnumber] and
                      ancestor::part/@id=$thispart and generate-id(ancestor::measure[1])=$startmeasureid]
                      and not(following::note[notations/slur[@type='stop' and @number=$slurnumber] and
                      ancestor::part/@id=$thispart and generate-id(ancestor::measure[1])=$startmeasureid])">
        <xsl:variable name="now">
          <xsl:for-each select="ancestor::note[1]">
            <xsl:call-template name="gettstamp.ges"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:for-each
          select="preceding::note[notations/slur[@type='stop' and @number=$slurnumber] and
                      ancestor::part[1]/@id=$thispart and generate-id(ancestor::measure[1])=$startmeasureid][1]">
          <xsl:variable name="endtimestamp">
            <xsl:call-template name="gettstamp.ges"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="($endtimestamp - $now) &gt; 0">
              <xsl:attribute name="dur">
                <xsl:text>0m+</xsl:text>
                <xsl:value-of select="$endtimestamp"/>
              </xsl:attribute>

              <xsl:attribute name="endid">
                <xsl:value-of select="generate-id()"/>
              </xsl:attribute>

              <!-- <xsl:if test="notations/slur[@type='stop' and @number=$slurnumber]/@default-x">
                <xsl:attribute name="endho"><xsl:value-of select="notations/slur[@type='stop' and @number=$slurnumber]/@default-x"/></xsl:attribute>
              </xsl:if>
              <xsl:if test="notations/slur[@type='stop' and @number=$slurnumber]/@default-y">
                <xsl:attribute name="endvo"><xsl:value-of select="notations/slur[@type='stop' and @number=$slurnumber]/@default-y"/></xsl:attribute>
              </xsl:if> -->
              <xsl:variable name="bezierend">
                <xsl:value-of
                  select="notations/slur[@type='stop' and @number=$slurnumber]/@bezier-x"/>
                <xsl:text> </xsl:text>
                <xsl:value-of
                  select="notations/slur[@type='stop' and @number=$slurnumber]/@bezier-y"
                />
              </xsl:variable>
              <xsl:if test="concat($bezierstart,$bezierend) != '  '">
                <xsl:attribute name="bezier">
                  <xsl:value-of select="$bezierstart"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="$bezierend"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:variable name="partID2">
                <xsl:value-of select="ancestor::part[1]/@id"/>
              </xsl:variable>
              <xsl:variable name="partstaff2">
                <xsl:choose>
                  <xsl:when test="staff">
                    <xsl:value-of select="staff"/>
                  </xsl:when>
                  <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:variable name="staff2">
                <xsl:call-template name="getstaffnum">
                  <xsl:with-param name="partID">
                    <xsl:value-of select="$partID2"/>
                  </xsl:with-param>
                  <xsl:with-param name="partstaff">
                    <xsl:value-of select="$partstaff2"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:variable>
              <xsl:attribute name="staff">
                <xsl:value-of select="$staff1"/>
                <xsl:if test="$staff2 != $staff1">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="$staff2"/>
                </xsl:if>
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when
                  test="following::note[notations/slur[@type='stop' and @number=$slurnumber] and
                            ancestor::part[1]/@id=$thispart][1]">
                  <xsl:for-each
                    select="following::note[notations/slur[@type='stop' and @number=$slurnumber] and
                                        ancestor::part[1]/@id=$thispart][1]">
                    <xsl:variable name="endmeasureid">
                      <xsl:value-of select="generate-id(ancestor::measure[1])"/>
                    </xsl:variable>
                    <xsl:variable name="endmeasurepos">
                      <xsl:for-each select="//measure">
                        <xsl:if test="generate-id()=$endmeasureid">
                          <xsl:value-of select="position()"/>
                        </xsl:if>
                      </xsl:for-each>
                    </xsl:variable>

                    <xsl:attribute name="dur">
                      <xsl:value-of select="$endmeasurepos - $startmeasurepos"/>
                      <xsl:text>m+</xsl:text>
                      <xsl:call-template name="gettstamp.ges"/>
                    </xsl:attribute>

                    <xsl:attribute name="endid">
                      <xsl:value-of select="generate-id()"/>
                    </xsl:attribute>
                    <!-- <xsl:if test="notations/slur[@type='stop']/@default-x">
                      <xsl:attribute name="endho"><xsl:value-of select="notations/slur[@type='stop']/@default-x"/></xsl:attribute>
                    </xsl:if>
                    <xsl:if test="notations/slur/@default-y">
                      <xsl:attribute name="endvo"><xsl:value-of select="notations/slur[@type='stop']/@default-y"/></xsl:attribute>
                    </xsl:if> -->
                    <xsl:variable name="bezierend">
                      <xsl:value-of
                        select="notations/slur[@type='stop']/@bezier-x"/>
                      <xsl:text> </xsl:text>
                      <xsl:value-of
                        select="notations/slur[@type='stop']/@bezier-y"/>
                    </xsl:variable>
                    <xsl:if test="concat($bezierstart,$bezierend) != '  '">
                      <xsl:attribute name="bezier">
                        <xsl:value-of select="$bezierstart"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$bezierend"/>
                      </xsl:attribute>
                    </xsl:if>
                    <xsl:variable name="partID2">
                      <xsl:value-of select="ancestor::part[1]/@id"/>
                    </xsl:variable>
                    <xsl:variable name="partstaff2">
                      <xsl:choose>
                        <xsl:when test="staff">
                          <xsl:value-of select="staff"/>
                        </xsl:when>
                        <xsl:otherwise>1</xsl:otherwise>
                      </xsl:choose>
                    </xsl:variable>
                    <xsl:variable name="staff2">
                      <xsl:call-template name="getstaffnum">
                        <xsl:with-param name="partID">
                          <xsl:value-of select="$partID2"/>
                        </xsl:with-param>
                        <xsl:with-param name="partstaff">
                          <xsl:value-of select="$partstaff2"/>
                        </xsl:with-param>
                      </xsl:call-template>
                    </xsl:variable>
                    <xsl:attribute name="staff">
                      <xsl:value-of select="$staff1"/>
                      <xsl:if test="$staff2 != $staff1">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$staff2"/>
                      </xsl:if>
                    </xsl:attribute>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="partID">
                    <xsl:value-of select="ancestor::part[1]/@id"/>
                  </xsl:variable>
                  <xsl:variable name="partstaff">
                    <xsl:choose>
                      <xsl:when test="ancestor::note[1]/staff">
                        <xsl:value-of select="ancestor::note[1]/staff"/>
                      </xsl:when>
                      <xsl:otherwise>1</xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <xsl:attribute name="staff">
                    <xsl:call-template name="getstaffnum">
                      <xsl:with-param name="partID">
                        <xsl:value-of select="$partID"/>
                      </xsl:with-param>
                      <xsl:with-param name="partstaff">
                        <xsl:value-of select="$partstaff"/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:when
        test="following::note[notations/slur[@type='stop' and @number=$slurnumber] and ancestor::part[1]/@id=$thispart][1]">
        <xsl:for-each
          select="following::note[notations/slur[@type='stop' and @number=$slurnumber] and ancestor::part[1]/@id=$thispart][1]">
          <xsl:variable name="endmeasureid">
            <xsl:value-of select="generate-id(ancestor::measure[1])"/>
          </xsl:variable>
          <xsl:variable name="endmeasurepos">
            <xsl:for-each select="//measure">
              <xsl:if test="generate-id()=$endmeasureid">
                <xsl:value-of select="position()"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>

          <xsl:attribute name="dur">
            <xsl:value-of select="$endmeasurepos - $startmeasurepos"/>
            <xsl:text>m+</xsl:text>
            <xsl:call-template name="gettstamp.ges"/>
          </xsl:attribute>

          <xsl:attribute name="endid">
            <xsl:value-of select="generate-id()"/>
          </xsl:attribute>

          <!-- <xsl:if test="notations/slur[@type='stop']/@default-x">
            <xsl:attribute name="endho"><xsl:value-of select="notations/slur[@type='stop']/@default-x"/></xsl:attribute>
          </xsl:if>
          <xsl:if test="notations/slur[@type='stop']/@default-y">
            <xsl:attribute name="endvo"><xsl:value-of select="notations/slur[@type='stop']/@default-y"/></xsl:attribute>
          </xsl:if> -->
          <xsl:variable name="bezierend">
            <xsl:value-of select="notations/slur[@type='stop']/@bezier-x"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="notations/slur[@type='stop']/@bezier-y"/>
          </xsl:variable>
          <xsl:if test="concat($bezierstart,$bezierend) != '  '">
            <xsl:attribute name="bezier">
              <xsl:value-of select="$bezierstart"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="$bezierend"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:variable name="partID2">
            <xsl:value-of select="ancestor::part[1]/@id"/>
          </xsl:variable>
          <xsl:variable name="partstaff2">
            <xsl:choose>
              <xsl:when test="staff">
                <xsl:value-of select="staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="staff2">
            <xsl:call-template name="getstaffnum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID2"/>
              </xsl:with-param>
              <xsl:with-param name="partstaff">
                <xsl:value-of select="$partstaff2"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <xsl:attribute name="staff">
            <xsl:value-of select="$staff1"/>
            <xsl:if test="$staff2 != $staff1">
              <xsl:text> </xsl:text>
              <xsl:value-of select="$staff2"/>
            </xsl:if>
          </xsl:attribute>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="partID">
          <xsl:value-of select="ancestor::part[1]/@id"/>
        </xsl:variable>
        <xsl:variable name="partstaff">
          <xsl:choose>
            <xsl:when test="ancestor::note[1]/staff">
              <xsl:value-of select="ancestor::note[1]/staff"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="staff">
          <xsl:call-template name="getstaffnum">
            <xsl:with-param name="partID">
              <xsl:value-of select="$partID"/>
            </xsl:with-param>
            <xsl:with-param name="partstaff">
              <xsl:value-of select="$partstaff"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:attribute>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="getdurphrase">
    <!-- Find terminal point of phrase -->
    <!-- Assumes that slur elements ALWAYS have number attributes -->
    <xsl:variable name="slurnumber">
      <xsl:value-of select="@number"/>
    </xsl:variable>
    <xsl:variable name="startmeasureid">
      <xsl:value-of select="generate-id(ancestor::measure[1])"/>
    </xsl:variable>
    <xsl:variable name="startmeasurepos">
      <xsl:for-each select="//measure">
        <xsl:if test="generate-id()=$startmeasureid">
          <xsl:value-of select="position()"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="thispart">
      <xsl:value-of select="ancestor::part[1]/@id"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when
        test="preceding::note[notations/slur[@type='stop' and @number=$slurnumber] and
                      ancestor::part/@id=$thispart and generate-id(ancestor::measure[1])=$startmeasureid]">
        <xsl:variable name="now">
          <xsl:call-template name="gettstamp.ges"/>
        </xsl:variable>
        <xsl:for-each
          select="preceding::note[notations/slur[@type='stop' and @number=$slurnumber] and
                      ancestor::part[1]/@id=$thispart and generate-id(ancestor::measure[1])=$startmeasureid][1]">
          <xsl:variable name="endtimestamp">
            <xsl:call-template name="gettstamp.ges"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$endtimestamp &gt; $now">
              <xsl:text>0m+</xsl:text>
              <xsl:value-of select="$endtimestamp"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each
                select="following::note[notations/slur[@type='stop' and @number=$slurnumber] and
                            ancestor::part[1]/@id=$thispart][1]">
                <xsl:variable name="endmeasureid">
                  <xsl:value-of select="generate-id(ancestor::measure[1])"/>
                </xsl:variable>
                <xsl:variable name="endmeasurepos">
                  <xsl:for-each select="//measure">
                    <xsl:if test="generate-id()=$endmeasureid">
                      <xsl:value-of select="position()"/>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:variable>
                <xsl:value-of select="$endmeasurepos - $startmeasurepos"/>
                <xsl:text>m+</xsl:text>
                <xsl:call-template name="gettstamp.ges"/>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each
          select="following::note[notations/slur[@type='stop' and @number=$slurnumber] and ancestor::part[1]/@id=$thispart][1]">
          <xsl:variable name="endmeasureid">
            <xsl:value-of select="generate-id(ancestor::measure[1])"/>
          </xsl:variable>
          <xsl:variable name="endmeasurepos">
            <xsl:for-each select="//measure">
              <xsl:if test="generate-id()=$endmeasureid">
                <xsl:value-of select="position()"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:value-of select="$endmeasurepos - $startmeasurepos"/>
          <xsl:text>m+</xsl:text>
          <xsl:call-template name="gettstamp.ges"/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="gettstamp.ges">
    <!-- Assign a timestamp. -->
    <xsl:variable name="thispart">
      <xsl:value-of select="ancestor::part[1]/@id"/>
    </xsl:variable>
    <xsl:variable name="divisions">
      <xsl:choose>
        <xsl:when
          test="ancestor::measure[1]/part[@id=$thispart]/attributes/divisions">
          <xsl:value-of
            select="ancestor::measure[1]/part[@id=$thispart]/attributes/divisions"
          />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of
            select="preceding::measure[part[@id=$thispart][attributes/divisions]][1]/part[@id=$thispart]/attributes/divisions"
          />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="dursum">
      <xsl:value-of
        select="sum(preceding-sibling::note[not(chord)]/duration) + 
sum(preceding-sibling::forward/duration) - sum(preceding-sibling::backup/duration)"
      />
    </xsl:variable>
    <xsl:value-of select="round-half-to-even($dursum,3)"/>
  </xsl:template>

  <xsl:template name="getstaffnum">
    <!-- Assign a staff number from $defaultlayout -->
    <xsl:param name="partID">P1</xsl:param>
    <xsl:param name="partstaff">1</xsl:param>
    <xsl:variable name="ingroup">
      <xsl:value-of
        select="$defaultlayout//staffgrp[@xml:id=$partID]/staffdef[position()=$partstaff]/@n"
      />
    </xsl:variable>
    <xsl:variable name="indef">
      <xsl:value-of select="$defaultlayout//staffdef[@xml:id=$partID]/@n"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$ingroup != ''">
        <xsl:value-of select="$ingroup"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$indef"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Stage 2 templates -->
  <!-- copy most elements -->
  <xsl:template match="*" priority="1" mode="stage2">
    <xsl:element name="{local-name()}"
      xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:copy-of select="@*[not(name()='tstamp.ges')]"/>
      <xsl:apply-templates mode="stage2"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="mei" priority="2" mode="stage2">
    <mei meiversion="2010-05" xmlns="http://www.music-encoding.org/ns/mei"
      xmlns:xlink="http://www.w3.org/1999/xlink">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="stage2"/>
    </mei>
  </xsl:template>

  <xsl:template match="layer" priority="2" mode="stage2">
    <layer xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:copy-of select="@*"/>
      <xsl:if
        test="count(descendant::chord[@visible='no']) + count(descendant::note[@visible='no']) + count(descendant::rest[@visible='no']) = count(descendant::chord) + count(descendant::note) + count(descendant::rest)">
        <xsl:attribute name="visible">false</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="stage2"/>
    </layer>
  </xsl:template>

  <!-- don't copy beam, staff, or tstamp.ges attributes on space -->
  <xsl:template match="space" priority="2" mode="stage2">
    <space xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:copy-of
        select="@*[not(name()='beam') and not(name()='staff') and
        not(name()='tstamp.ges')]"/>
      <xsl:apply-templates mode="stage2"/>
    </space>
  </xsl:template>

  <!-- clean up n attributes on staff -->
  <xsl:template match="staff" priority="2" mode="stage2">
    <staff xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:copy-of select="@*[not(name()='n')]"/>
      <xsl:choose>
        <xsl:when test="contains(@n,' ')">
          <xsl:attribute name="n">
            <xsl:value-of select="substring-before(@n,' ')"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="@n"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates mode="stage2"/>
    </staff>
  </xsl:template>

  <!-- copy attributes on staffdef elements preceding the first measure to corresponding
       top-level staffgrp/staffdef -->
  <xsl:template match="body/mdiv/score/scoredef[1]/staffgrp" priority="2"
    mode="stage2">
    <staffgrp xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:copy-of select="@*"/>
      <xsl:for-each select="instrdef">
        <instrdef xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates mode="stage2"/>
        </instrdef>
      </xsl:for-each>
      <xsl:for-each select="staffdef|staffgrp">
        <xsl:choose>
          <xsl:when test="name()='staffdef'">
            <staffdef xmlns="http://www.music-encoding.org/ns/mei">
              <xsl:copy-of select="@*"/>
              <xsl:variable name="thisstaff">
                <xsl:value-of select="@n"/>
              </xsl:variable>
              <!-- Copy attributes from staffdef elements in section one preceding the first measure -->
              <xsl:if
                test="following::section[1]/staffdef[count(preceding::measure)=0]">
                <xsl:copy-of
                  select="following::section[1]/staffdef[count(preceding::measure)=0 and
                  @n=$thisstaff]/@*[not(name()='n')]"
                />
              </xsl:if>
              <xsl:choose>
                <xsl:when test="count(instrdef) = 1">
                  <instrdef>
                    <xsl:copy-of select="instrdef/@*"/>
                  </instrdef>
                </xsl:when>
                <xsl:when test="count(instrdef) &gt; 1">
                  <xsl:for-each select="instrdef">
                    <layerdef>
                      <xsl:attribute name="n">
                        <xsl:value-of select="position()"/>
                      </xsl:attribute>
                      <instrdef>
                        <xsl:copy-of select="@*"/>
                      </instrdef>
                    </layerdef>
                  </xsl:for-each>
                </xsl:when>
              </xsl:choose>
            </staffdef>
          </xsl:when>
          <xsl:when test="name()='staffgrp'">
            <staffgrp xmlns="http://www.music-encoding.org/ns/mei">
              <xsl:copy-of select="@*"/>
              <xsl:for-each select="staffdef">
                <staffdef xmlns="http://www.music-encoding.org/ns/mei">
                  <xsl:copy-of select="@*"/>
                  <xsl:variable name="thisstaff">
                    <xsl:value-of select="@n"/>
                  </xsl:variable>
                  <!-- Copy attributes from staffdef elements in section one preceding the first measure -->
                  <xsl:if
                    test="following::section[1]/staffdef[count(preceding::measure)=0]">
                    <xsl:copy-of
                      select="following::section[1]/staffdef[count(preceding::measure)=0 and
                                         @n=$thisstaff]/@*[not(name()='n')]"
                    />
                  </xsl:if>
                  <xsl:choose>
                    <xsl:when test="count(ancestor::staffgrp[1]/instrdef) = 1">
                      <xsl:copy-of
                        select="ancestor::staffgrp[1]/instrdef/@*[name()!='id']"
                      />
                    </xsl:when>
                    <xsl:when
                      test="count(ancestor::staffgrp[1]/instrdef) &gt; 1">
                      <xsl:variable name="layers">
                        <xsl:variable name="thisstaff" select="@n"/>
                        <xsl:for-each select="ancestor::staffgrp[1]/instrdef">
                          <xsl:variable name="thisinstr" select="@xml:id"/>
                          <xsl:if
                            test="following::*[@instr=$thisinstr and ancestor::staff[@n=$thisstaff]]">
                            <xsl:variable name="layer">
                              <xsl:value-of
                                select="following::*[@instr=$thisinstr and 
                            ancestor::staff[@n=$thisstaff]][1]/ancestor::layer/@n"
                              />
                            </xsl:variable>
                            <layerdef>
                              <instrdef>
                                <xsl:copy-of select="@*"/>
                              </instrdef>
                            </layerdef>
                          </xsl:if>
                        </xsl:for-each>
                      </xsl:variable>
                      <xsl:for-each select="$layers/layerdef"
                        xpath-default-namespace="http://www.music-encoding.org/ns/mei">
                        <layerdef>
                          <xsl:attribute name="n">
                            <xsl:value-of select="position()"/>
                          </xsl:attribute>
                          <xsl:copy-of select="instrdef"/>
                        </layerdef>
                      </xsl:for-each>
                    </xsl:when>
                  </xsl:choose>
                  <xsl:apply-templates select="*" mode="stage2"/>
                </staffdef>
              </xsl:for-each>
            </staffgrp>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </staffgrp>
  </xsl:template>

  <!-- copy staffdef elements and their attributes unless they precede the first measure -->
  <xsl:template match="section[1]/staffdef" priority="2" mode="stage2">
    <xsl:if test="not(count(preceding::measure)=0)">
      <staffdef xmlns="http://www.music-encoding.org/ns/mei">
        <xsl:copy-of select="@*"/>
        <xsl:apply-templates mode="stage2"/>
      </staffdef>
    </xsl:if>
  </xsl:template>

  <!-- When beam contains only space children, copy the children, but not the beam.
       Add 'with' attribute on beam if necessary -->
  <xsl:template match="beam" priority="2" mode="stage2">
    <xsl:choose>
      <xsl:when test="count(space)=count(*)">
        <xsl:apply-templates mode="stage2"/>
      </xsl:when>
      <xsl:otherwise>
        <beam xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:choose>
            <xsl:when test="*[@staff &gt; ancestor::staff[1]/@n]">
              <xsl:attribute name="with">below</xsl:attribute>
            </xsl:when>
            <xsl:when test="*[@staff &lt; ancestor::staff[1]/@n]">
              <xsl:attribute name="with">above</xsl:attribute>
            </xsl:when>
          </xsl:choose>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates mode="stage2"/>
        </beam>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- When the starting or ending note of a tuplet is part of a chord,
       repair the @startid and @endid attributes so that they point to the
       chord's id, not the note's id. -->
  <xsl:template match="tupletspan" priority="2" mode="stage2">
    <tupletspan xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:copy-of select="@*[not(name()='startid' or name()='endid')]"/>
      <xsl:variable name="start">
        <xsl:value-of select="@startid"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="preceding::note[@xml:id=$start]/parent::chord">
          <xsl:attribute name="startid">
            <xsl:value-of
              select="preceding::note[@xml:id=$start]/parent::chord/@xml:id"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="@startid"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="end">
        <xsl:value-of select="@endid"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="preceding::note[@xml:id=$end]/parent::chord">
          <xsl:attribute name="endid">
            <xsl:value-of
              select="preceding::note[@xml:id=$end]/parent::chord/@xml:id"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="@endid"/>
        </xsl:otherwise>
      </xsl:choose>
    </tupletspan>
  </xsl:template>

  <!-- Copy articulations from member notes. Do not copy beam
    or tstamp.ges attributes. -->
  <xsl:template match="chord" priority="2" mode="stage2">
    <chord xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:copy-of select="@*[not(name()='beam') and not(name()='tstamp.ges')]"/>
      <xsl:choose>
        <xsl:when test="$articattr='yes' and note/@artic">
          <xsl:attribute name="artic">
            <xsl:variable name="noteartics">
              <xsl:for-each select="note">
                <xsl:value-of select="@artic"/>
                <xsl:if test="position()!=last()">
                  <xsl:text> </xsl:text>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:value-of select="normalize-space($noteartics)"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="note/artic" mode="stage2"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates mode="stage2"/>
    </chord>
  </xsl:template>

  <!-- Copy artic sub-elements or artic attribute only if not a chord member. -->
  <xsl:template match="note" priority="2" mode="stage2">
    <note xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:copy-of
        select="@*[not(name()='beam') and not(name()='tstamp.ges')
        and not(name()='artic')]"/>
      <xsl:choose>
        <xsl:when test="not(ancestor::chord)">
          <xsl:copy-of select="@artic"/>
          <xsl:apply-templates mode="stage2"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="*[not(name()='artic')]" mode="stage2"/>
        </xsl:otherwise>
      </xsl:choose>
    </note>
  </xsl:template>

  <xsl:template
    match="annot | arpeg | beamspan | bend | dir | dynam | gliss |hairpin |
           harm | harppedal | mordent | octave | pedal | phrase | reh |
           slur | tie | tempo | trill | turn"
    priority="2" mode="stage2">
    <xsl:element name="{name()}" xmlns="http://www.music-encoding.org/ns/mei">
      <!-- MusicXML time offsets must be subtracted from/added to the current
           MusicXML tstamp.ges and dur attribute values to arrive at an MEI tstamp
           value. -->
      <xsl:copy-of select="@xml:id"/>
      <xsl:attribute name="tstamp">
        <xsl:choose>
          <xsl:when test="@startto">
            <xsl:choose>
              <xsl:when test="@startto &lt;= 0">
                <xsl:call-template name="tstamp.ges2beat">
                  <xsl:with-param name="tstamp.ges">
                    <xsl:value-of select="@tstamp.ges - abs(@startto)"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="tstamp.ges2beat">
                  <xsl:with-param name="tstamp.ges">
                    <xsl:value-of select="@tstamp.ges + @startto"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="tstamp.ges2beat">
              <xsl:with-param name="tstamp.ges">
                <xsl:value-of select="@tstamp.ges"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="@dur and @dur!='0'">
          <!-- this condition will never be true for arpeg -->
          <xsl:attribute name="dur">
            <xsl:value-of select="substring-before(@dur,'+')"/>
            <xsl:text>+</xsl:text>
            <xsl:choose>
              <xsl:when test="@endto">
                <xsl:choose>
                  <xsl:when test="@endto &lt;= 0">
                    <xsl:call-template name="tstamp.ges2beat">
                      <xsl:with-param name="tstamp.ges">
                        <xsl:value-of
                          select="number(substring-after(@dur,'+')) - abs(@endto)"
                        />
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:when>
                  <xsl:when test="@endto &gt; 0">
                    <xsl:call-template name="tstamp.ges2beat">
                      <xsl:with-param name="tstamp.ges">
                        <xsl:value-of
                          select="number(substring-after(@dur,'+')) + abs(@endto)"
                        />
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:when>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="tstamp.ges2beat">
                  <xsl:with-param name="tstamp.ges">
                    <xsl:value-of select="number(substring-after(@dur,'+'))"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <!-- arpeg has no dur attribute -->
          <xsl:copy-of select="@dur"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:copy-of
        select="@*[not(name()='tstamp.ges') and not(name()='dur') and
        not(name()='id')]"/>
      <xsl:apply-templates mode="stage2"/>
    </xsl:element>
  </xsl:template>

  <!-- Convert tstamp.ges value to musical time. -->
  <xsl:template name="tstamp.ges2beat">
    <xsl:param name="tstamp.ges"/>
    <xsl:variable name="thisstaff">
      <xsl:choose>
        <xsl:when test="@staff">
          <xsl:value-of select="@staff"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="ancestor::staff[1]/@n"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="ppq">
      <xsl:choose>
        <xsl:when test="preceding::staffdef[@n=$thisstaff][@ppq]">
          <xsl:value-of
            select="preceding::staffdef[@n=$thisstaff][@ppq][1]/@ppq"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>96</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="meter.unit">
      <xsl:choose>
        <xsl:when test="preceding::*[@meter.unit]/@meter.unit">
          <xsl:value-of select="preceding::*[@meter.unit][1]/@meter.unit"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>4</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$meter.unit = 4">
        <xsl:value-of select="1 + round-half-to-even($tstamp.ges div $ppq,3)"/>
      </xsl:when>
      <xsl:when test="$meter.unit != 4">
        <xsl:value-of
          select="1 + round-half-to-even(($tstamp.ges div $ppq) * ($meter.unit div 4),3)"
        />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="rest" priority="2" mode="stage2">
    <!-- This template replaces rest element with mrest element when there are no other events in
    the measure and the rest's gestural duration equals a complete measure duration. -->
    <xsl:choose>
      <xsl:when
        test="count(preceding-sibling::*[name()='beam' or name()='beatrpt' or
                      name()='btrem' or name()='chord' or name()='ftrem' or name()='note' or
                      name()='rest' or name()='space' or name()='tuplet']) +
                      count(following-sibling::*[name()='beam' or name()='beatrpt' or
                      name()='btrem' or name()='chord' or name()='ftrem' or name()='note' or
                      name()='rest' or name()='space' or name()='tuplet']) = 0">
        <!-- this is the only event in the measure -->
        <xsl:variable name="thisstaff">
          <xsl:value-of select="ancestor::staff/@n"/>
        </xsl:variable>
        <xsl:variable name="ppq">
          <xsl:value-of
            select="number(preceding::staffdef[@n=$thisstaff and @ppq][1]/@ppq)"
          />
        </xsl:variable>
        <xsl:variable name="meter.unit">
          <xsl:choose>
            <xsl:when test="preceding::scoredef[@meter.unit]">
              <xsl:value-of
                select="number(preceding::scoredef[@meter.unit][1]/@meter.unit)"
              />
            </xsl:when>
            <xsl:otherwise>4</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="meter.count">
          <xsl:choose>
            <xsl:when test="preceding::scoredef[@meter.count]">
              <xsl:value-of
                select="number(preceding::scoredef[@meter.count][1]/@meter.count)"
              />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of
                select="sum(ancestor::staff/layer[1]/*[@dur.ges]/@dur.ges) div $ppq"
              />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="measuredur">
          <xsl:choose>
            <xsl:when test="$meter.unit = 1">
              <xsl:value-of select="($meter.count * 4) * $ppq"/>
            </xsl:when>
            <xsl:when test="$meter.unit = 2">
              <xsl:value-of select="($meter.count * $meter.unit) * $ppq"/>
            </xsl:when>
            <xsl:when test="$meter.unit = 4">
              <xsl:value-of select="$meter.count * $ppq"/>
            </xsl:when>
            <xsl:when test="$meter.unit &gt; 4">
              <xsl:value-of
                select="($meter.count div ($meter.unit div 4)) * $ppq"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="@dur.ges=$measuredur">
            <!-- This is a full-measure rest: create mrest, copy most attributes from rest element,
            and check for vertical offset. -->

            <mrest xmlns="http://www.music-encoding.org/ns/mei">
              <xsl:copy-of select="@xml:id"/>
              <xsl:copy-of
                select="@*[not(name()='beam') and
                        not(name()='tstamp.ges') and
                        not(name()='id') and not(name()='vo')]"/>
              <xsl:if test="@vo">
                <xsl:attribute name="vo">
                  <xsl:call-template name="restvo2"/>
                </xsl:attribute>
              </xsl:if>
            </mrest>
          </xsl:when>
          <xsl:otherwise>
            <!-- This is not a full-measure rest: create copy of the rest, copy most
            of its attributes, and check for vertical offset. -->
            <rest xmlns="http://www.music-encoding.org/ns/mei">
              <xsl:copy-of
                select="@*[not(name()='beam') and not(name()='vo')
                and not(name()='tstamp.ges')]"/>
              <xsl:if test="@vo">
                <xsl:attribute name="vo">
                  <xsl:call-template name="restvo2"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:apply-templates mode="stage2"/>
            </rest>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!-- this is not the only event in the measure, copy it through -->
        <rest xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:copy-of
            select="@*[not(name()='beam') and not(name()='vo') and
            not(name()='tstamp.ges')]"/>
          <xsl:if test="@vo">
            <xsl:attribute name="vo">
              <xsl:call-template name="restvo2"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates mode="stage2"/>
        </rest>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
