<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns="http://www.music-encoding.org/ns/mei" xmlns:mei="http://www.music-encoding.org/ns/mei"
  xmlns:xlink="http://www.w3.org/1999/xlink">

  <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" standalone="no"/>
  <xsl:strip-space elements="*"/>

  <!-- ======================================================================= -->
  <!-- PARAMETERS                                                              -->
  <!-- ======================================================================= -->

  <!-- PARAM:verbose
      This parameter controls the feedback provided by the stylesheet. The default value of 'true()'
      produces a log message for every change. When set to 'false()' no messages are produced.
  -->
  <xsl:param name="verbose" select="true()"/>
  <!-- path to rng -->
  <xsl:param name="rng_model_path"
    >http://music-encoding.googlecode.com/svn/tags/MEI2013_v2.1.0/schemata/mei-all.rng</xsl:param>
  <!-- path to schematron -->
  <xsl:param name="sch_model_path"
    >http://music-encoding.googlecode.com/svn/tags/MEI2013_v2.1.0/schemata/mei-all.rng</xsl:param>

  <!-- ======================================================================= -->
  <!-- GLOBAL VARIABLES                                                        -->
  <!-- ======================================================================= -->

  <!-- program name -->
  <xsl:variable name="progname">
    <xsl:text>mei2012To2013.xsl</xsl:text>
  </xsl:variable>

  <!-- program version -->
  <xsl:variable name="version">
    <xsl:text>1.0 beta</xsl:text>
  </xsl:variable>

  <!-- new line -->
  <xsl:variable name="nl">
    <xsl:text>&#xa;</xsl:text>
  </xsl:variable>

  <!-- ======================================================================= -->
  <!-- UTILITIES / NAMED TEMPLATES                                             -->
  <!-- ======================================================================= -->

  <xsl:template name="thisID">
    <xsl:choose>
      <xsl:when test="@xml:id">
        <xsl:value-of select="concat('[#', @xml:id, ']')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('[#', generate-id(), ']')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="thisMeasure">
    <xsl:choose>
      <xsl:when test="ancestor::mei:measure[@n]">
        <xsl:value-of select="ancestor::mei:measure/@n"/>
      </xsl:when>
      <xsl:when test="ancestor::mei:measure">
        <xsl:for-each select="ancestor::mei:measure">
          <xsl:value-of select="count(preceding::mei:measure) + 1"/>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="warning">
    <xsl:param name="warningText"/>
    <xsl:message>
      <xsl:value-of select="normalize-space($warningText)"/>
    </xsl:message>
  </xsl:template>


  <!-- ======================================================================= -->
  <!-- MAIN OUTPUT TEMPLATE                                                    -->
  <!-- ======================================================================= -->

  <xsl:template match="/">
    <xsl:if test="$rng_model_path != ''">
      <xsl:processing-instruction name="xml-model">
        <xsl:value-of select="concat('&#32;href=&quot;', $rng_model_path, '&quot;')"/>
        <xsl:text> type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
      </xsl:processing-instruction>
      <xsl:value-of select="$nl"/>
    </xsl:if>

    <xsl:if test="$sch_model_path != ''">
      <xsl:processing-instruction name="xml-model">
        <xsl:value-of select="concat('&#32;href=&quot;', $sch_model_path, '&quot;')"/>
        <xsl:text> type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:text>
      </xsl:processing-instruction>
      <xsl:value-of select="$nl"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="mei:mei|mei:meiHead|mei:music">
        <xsl:apply-templates select="mei:* | comment()" mode="copy"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="warning">The source file is not an MEI file!</xsl:variable>
        <xsl:message terminate="yes">
          <xsl:value-of select="normalize-space($warning)"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- MATCH TEMPLATES                                                         -->
  <!-- ======================================================================= -->

  <xsl:template match="mei:mei|mei:meiHead|mei:music" mode="copy">
    <!-- Add @meiversion attribute to document element -->
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name()='meiversion')]" mode="copy"/>
      <xsl:if test="count(ancestor::mei:*) = 0">
        <xsl:attribute name="meiversion">
          <xsl:text>2013</xsl:text>
        </xsl:attribute>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of select="concat(local-name(), '&#32;', $thisID, '&#32;: Added
                @meiversion')"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:arpeg|mei:beamSpan|mei:breath|mei:hairpin|
    mei:harpPedal|mei:octave|mei:pedal|mei:reh|mei:slur|mei:tie|mei:tupletSpan|
    mei:bend|mei:dir|mei:dynam|mei:gliss|mei:phrase|mei:tempo|mei:mordent|
    mei:trill|mei:turn|mei:harm" mode="copy">
    <!-- Rename @dur on control events to @tstamp2 -->
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name()='dur')]" mode="copy"/>
      <xsl:if test="@dur">
        <xsl:attribute name="tstamp2">
          <xsl:value-of select="@dur"/>
        </xsl:attribute>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:variable name="thisMeasure">
            <xsl:call-template name="thisMeasure"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:if test="ancestor::mei:incip">
                <xsl:text>incip/</xsl:text>
              </xsl:if>
              <xsl:value-of select="concat('m. ', $thisMeasure, '/', local-name(), '&#32;', $thisID,
                '&#32;: Removed @dur; added @tstamp2')"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:condition|mei:exhibHist|mei:inscription|
    mei:physMedium|mei:plateNum|mei:provenance|mei:titlePage|mei:treatHist|
    mei:treatSched|mei:watermark" mode="asBibl">
    <!-- Output as annotation -->
    <annot xmlns:mei="http://www.music-encoding.org/ns/mei" xsl:exclude-result-prefixes="mei
      xlink">
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:if test="not(@label)">
        <xsl:attribute name="label">
          <xsl:value-of select="local-name()"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="asBibl"/>
    </annot>
  </xsl:template>

  <xsl:template match="mei:contents" mode="asBibl">
    <!-- Output as annotation containing a table, list, or p as appropriate -->
    <annot xmlns:mei="http://www.music-encoding.org/ns/mei" xsl:exclude-result-prefixes="mei
      xlink">
      <xsl:apply-templates select="@*[not(local-name()='target' or local-name()='targettype' or
        matches(name(), 'xlink:'))]" mode="copy"/>
      <xsl:choose>
        <!-- 2-column table in order accommodate label element content -->
        <xsl:when test="mei:label">
          <table>
            <xsl:apply-templates select="@*" mode="copy"/>
            <xsl:if test="mei:head">
              <caption>
                <xsl:apply-templates select="mei:head/node()" mode="copy"/>
              </caption>
            </xsl:if>
            <xsl:for-each select="mei:contentItem">
              <tr>
                <td>
                  <xsl:choose>
                    <xsl:when test="local-name(preceding-sibling::*[1])='label'">
                      <xsl:apply-templates select="preceding-sibling::*[1]/node()" mode="copy"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text disable-output-escaping="yes">&amp;#32;</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                </td>
                <td>
                  <xsl:apply-templates select="./node()" mode="copy"/>
                </td>
              </tr>
            </xsl:for-each>
          </table>
        </xsl:when>
        <!-- paragraph -->
        <xsl:when test="mei:p">
          <xsl:if test="not(@label) and mei:head">
            <xsl:attribute name="label">
              <xsl:value-of select="mei:head"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:copy-of select="mei:p"/>
        </xsl:when>
        <!-- list -->
        <xsl:otherwise>
          <list>
            <xsl:copy-of select="mei:head"/>
            <xsl:for-each select="mei:contentItem">
              <li>
                <xsl:apply-templates select="node()" mode="copy"/>
              </li>
            </xsl:for-each>
          </list>
        </xsl:otherwise>
      </xsl:choose>
    </annot>
  </xsl:template>

  <xsl:template match="mei:date" mode="copy">
    <!-- @reg renamed to @isodate -->
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name()='reg')]" mode="copy"/>
      <xsl:if test="@reg">
        <xsl:attribute name="isodate">
          <xsl:value-of select="@reg"/>
        </xsl:attribute>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of select="concat(local-name(ancestor::mei:*[1]), '/', local-name(),
                '&#32;', $thisID, '&#32;: Renamed @reg to @isodate')"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:dimensions" mode="asBibl">
    <!-- Output as annotation; drop @unit, adding its value to content if not already present -->
    <annot xmlns:mei="http://www.music-encoding.org/ns/mei" xsl:exclude-result-prefixes="mei
      xlink">
      <xsl:apply-templates select="@*[not(local-name()='unit')]" mode="copy"/>
      <xsl:if test="not(@label)">
        <xsl:attribute name="label">
          <xsl:value-of select="local-name()"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="asBibl"/>
      <xsl:if test="@unit">
        <xsl:variable name="unit">
          <xsl:value-of select="@unit"/>
        </xsl:variable>
        <xsl:if test="not(matches(., $unit))">
          <xsl:value-of select="$unit"/>
        </xsl:if>
      </xsl:if>
    </annot>
  </xsl:template>

  <xsl:template match="mei:editionStmt|mei:physDesc|mei:titleStmt" mode="asBibl">
    <!-- Drop physDesc but process children -->
    <xsl:apply-templates mode="asBibl"/>
  </xsl:template>

  <xsl:template match="mei:event" mode="copy">
    <!-- @reg renamed to @isodate, mixed content wrapped by <p> -->
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name()='reg')]" mode="copy"/>
      <xsl:if test="@reg">
        <xsl:attribute name="isodate">
          <xsl:value-of select="@reg"/>
        </xsl:attribute>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of select="concat(local-name(), '&#32;', $thisID, '&#32;: Renamed @reg to
                @isodate')"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <xsl:choose>
        <!-- potentially mixed content -->
        <xsl:when test="text()">
          <p xmlns:mei="http://www.music-encoding.org/ns/mei" xsl:exclude-result-prefixes="mei
            xlink">
            <xsl:apply-templates mode="copy"/>
          </p>
          <xsl:if test="$verbose">
            <xsl:variable name="thisID">
              <xsl:call-template name="thisID"/>
            </xsl:variable>
            <xsl:call-template name="warning">
              <xsl:with-param name="warningText">
                <xsl:value-of select="concat(local-name(), '&#32;', $thisID, '&#32;: Wrapped content
                  with p element')"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
        </xsl:when>
        <!-- MEI elements -->
        <xsl:otherwise>
          <xsl:apply-templates mode="copy"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:fermata" mode="copy">
    <!-- @dur on control events renamed to @tstamp2 -->
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name()='dur') and not(local-name()='place')]"
        mode="copy"/>
      <xsl:if test="@dur">
        <xsl:attribute name="tstamp2">
          <xsl:value-of select="@dur"/>
        </xsl:attribute>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:variable name="thisMeasure">
            <xsl:call-template name="thisMeasure"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:if test="ancestor::mei:incip">
                <xsl:text>incip/</xsl:text>
              </xsl:if>
              <xsl:value-of select="concat('m. ', $thisMeasure, '/', local-name(), '&#32;', $thisID,
                '&#32;: Removed @dur; added @tstamp2')"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <xsl:if test="@place">
        <xsl:attribute name="place">
          <xsl:choose>
            <xsl:when test="@place='within'">
              <xsl:text>above</xsl:text>
              <xsl:if test="$verbose">
                <xsl:variable name="thisID">
                  <xsl:call-template name="thisID"/>
                </xsl:variable>
                <xsl:variable name="thisMeasure">
                  <xsl:call-template name="thisMeasure"/>
                </xsl:variable>
                <xsl:call-template name="warning">
                  <xsl:with-param name="warningText">
                    <xsl:if test="ancestor::mei:incip">
                      <xsl:text>incip/</xsl:text>
                    </xsl:if>
                    <xsl:value-of select="concat('m. ', $thisMeasure, '/', local-name(), '&#32;',
                      $thisID, '&#32;: Modified @place')"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@place"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:incipCode" mode="copy">
    <!-- Add @form -->
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:if test="not(@form)">
        <xsl:attribute name="form">
          <xsl:choose>
            <xsl:when test="matches(normalize-space(.),'^\*')">
              <xsl:text>parsons</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>unknown</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:list/mei:item" mode="copy">
    <!-- Rename to <li> -->
    <li xmlns:mei="http://www.music-encoding.org/ns/mei" xsl:exclude-result-prefixes="mei xlink">
      <xsl:apply-templates mode="copy"/>
    </li>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of select="concat(local-name(), '&#32;', $thisID, '&#32;: Renamed to li')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:pgHead/mei:table | mei:pgHead2/mei:table | mei:pgFoot/mei:table |
    mei:pgFoot2/mei:table" mode="copy">
    <!-- Convert table cells to anchoredText elements -->
    <xsl:for-each select="descendant::mei:td">
      <anchoredText xmlns:mei="http://www.music-encoding.org/ns/mei"
        xsl:exclude-result-prefixes="mei xlink">
        <xsl:if test="@x or ancestor::mei:tr[@x]">
          <xsl:attribute name="x">
            <xsl:choose>
              <xsl:when test="@x">
                <xsl:value-of select="@x"/>
              </xsl:when>
              <xsl:when test="ancestor::mei:tr[@x]">
                <xsl:value-of select="ancestor::mei:tr[@x]/@x"/>
              </xsl:when>
            </xsl:choose>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="@x or ancestor::mei:tr[@x]">
          <xsl:attribute name="y">
            <xsl:choose>
              <xsl:when test="@y">
                <xsl:value-of select="@y"/>
              </xsl:when>
              <xsl:when test="ancestor::mei:tr[@y]">
                <xsl:value-of select="ancestor::mei:tr[@y]/@y"/>
              </xsl:when>
            </xsl:choose>
          </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates mode="copy"/>
      </anchoredText>
    </xsl:for-each>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of select="concat(local-name(ancestor::mei:*[1]), '/', local-name(), '&#32;',
            $thisID, '&#32;: Replaced by anchoredText elements')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:physDesc" mode="copy">
    <!-- physLoc is pulled out and presented after physDesc. -->
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates select="mei:*[not(local-name()='physLoc')]" mode="copy"/>
    </xsl:copy>
    <xsl:if test="mei:physLoc">
      <xsl:apply-templates select="mei:physLoc" mode="copy"/>
      <xsl:if test="$verbose">
        <xsl:variable name="thisID">
          <xsl:call-template name="thisID"/>
        </xsl:variable>
        <xsl:call-template name="warning">
          <xsl:with-param name="warningText">
            <xsl:value-of select="concat(local-name(ancestor::mei:*[1]), '/', local-name(), '&#32;',
              $thisID, '&#32;: Reordered content')"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:physLoc" mode="copy">
    <!-- The 2013 model only allows repository and identifier elements. -->
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates select="comment()" mode="copy"/>
      <xsl:apply-templates select="mei:repository" mode="copy"/>
      <xsl:apply-templates select="mei:identifier" mode="copy"/>
    </xsl:copy>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of select="concat(local-name(ancestor::mei:*[1]), '/', local-name(), '&#32;',
            $thisID, '&#32;: Reordered content')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:physLoc/mei:repository" mode="copy">
    <!-- New repository element will contain the textual content of the ancestor 
      physLoc as well as any textual and element content of repository -->
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates select="ancestor::mei:physLoc/text() |
        ancestor::mei:physLoc/mei:*[not(local-name()='repository') and
        not(local-name()='identifier')] | text() | mei:*" mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:pubStmt" mode="asBibl">
    <!-- Copy respStmt and collect address, date, and geogName elements within imprint -->
    <xsl:copy-of select="mei:respStmt"/>
    <xsl:if test="mei:date|mei:address|mei:geogName">
      <imprint xmlns:mei="http://www.music-encoding.org/ns/mei" xsl:exclude-result-prefixes="mei
        xlink">
        <xsl:apply-templates select="mei:date" mode="asBibl"/>
        <xsl:if test="mei:address|mei:geogName">
          <pubPlace>
            <xsl:apply-templates select="mei:address|mei:geogName" mode="asBibl"/>
          </pubPlace>
        </xsl:if>
      </imprint>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:pubStmt/mei:geogName" mode="asBibl">
    <xsl:variable name="attributeValues">
      <xsl:value-of select="@*"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="not($attributeValues='')">
        <geogName xmlns:mei="http://www.music-encoding.org/ns/mei" xsl:exclude-result-prefixes="mei
          xlink">
          <xsl:apply-templates select="@*" mode="copy"/>
          <xsl:apply-templates mode="copy"/>
        </geogName>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="copy"/>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of select="concat(local-name(ancestor::mei:*[1]), '/', local-name(),
                '&#32;', $thisID, '&#32;: Copied content only')"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:pubStmt/mei:geogName" mode="copy">
    <!-- Use only the content of geogName if it has no attributes -->
    <pubPlace xmlns:mei="http://www.music-encoding.org/ns/mei" xsl:exclude-result-prefixes="mei
      xlink">
      <xsl:variable name="attributeValues">
        <xsl:value-of select="@*"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="not($attributeValues='')">
          <geogName xmlns:mei="http://www.music-encoding.org/ns/mei"
            xsl:exclude-result-prefixes="mei xlink">
            <xsl:apply-templates select="@*" mode="copy"/>
            <xsl:apply-templates mode="copy"/>
          </geogName>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="copy"/>
          <xsl:if test="$verbose">
            <xsl:variable name="thisID">
              <xsl:call-template name="thisID"/>
            </xsl:variable>
            <xsl:call-template name="warning">
              <xsl:with-param name="warningText">
                <xsl:value-of select="concat(local-name(ancestor::mei:*[1]), '/', local-name(),
                  '&#32;', $thisID, '&#32;: Copied content only')"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </pubPlace>
  </xsl:template>

  <xsl:template match="mei:relatedItem" mode="asBibl">
    <!-- Rename relatedItem to bibl -->
    <bibl xmlns:mei="http://www.music-encoding.org/ns/mei" xsl:exclude-result-prefixes="mei xlink">
      <xsl:attribute name="xml:id">
        <xsl:choose>
          <xsl:when test="@xml:id">
            <xsl:value-of select="@xml:id"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="generate-id()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <!-- mei-CMN.rng doesn't allow <relatedItem> within <bibl>! -->
      <xsl:apply-templates mode="asBibl"/>
    </bibl>
  </xsl:template>

  <xsl:template match="mei:rest" mode="copy">
    <!-- Translate @line values to @loc (which includes spaces) -->
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name()='line' or local-name()='dur.ges')]"
        mode="copy"/>
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:variable name="thisMeasure">
        <xsl:call-template name="thisMeasure"/>
      </xsl:variable>
      <xsl:if test="@line">
        <xsl:attribute name="loc">
          <xsl:value-of select="translate(@line, '12345', '13579')"/>
        </xsl:attribute>
        <xsl:if test="$verbose">
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:if test="ancestor::mei:incip">
                <xsl:text>incip/</xsl:text>
              </xsl:if>
              <xsl:value-of select="concat('m. ', $thisMeasure, '/', local-name(), '&#32;', $thisID,
                '&#32;: Converted @line to @loc')"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:revisionDesc" mode="copy">
    <!-- Add a record of the conversion to 2013 to revisionDesc -->
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates mode="copy"/>
      <change xmlns:mei="http://www.music-encoding.org/ns/mei" xsl:exclude-result-prefixes="mei
        xlink">
        <xsl:attribute name="n">
          <xsl:value-of select="count(mei:change) + 1"/>
        </xsl:attribute>
        <respStmt/>
        <changeDesc>
          <p>Converted to MEI 2013 using <xsl:value-of select="$progname"/>, version <xsl:value-of
              select="$version"/></p>
        </changeDesc>
        <date>
          <xsl:attribute name="isodate">
            <xsl:value-of select="format-date(current-date(), '[Y]-[M02]-[D02]')"/>
          </xsl:attribute>
        </date>
      </change>
    </xsl:copy>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of select="concat(local-name(ancestor::mei:*[1]), '/', local-name(), '&#32;',
            $thisID, '&#32;: Added change element')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:scoreDef" mode="copy">
    <!-- @page.scale is replaced by @vu.height; @page.units is removed. -->
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name()='page.scale') and
        not(local-name()='page.units')]" mode="copy"/>
      <xsl:choose>
        <xsl:when test="contains(@page.scale,':')">
          <xsl:attribute name="vu.height">
            <xsl:value-of select="concat(format-number(number(substring-after(@page.scale, ':')) div
              8, '###0.####'), 'mm')"/>
          </xsl:attribute>
          <xsl:if test="$verbose">
            <xsl:variable name="thisID">
              <xsl:call-template name="thisID"/>
            </xsl:variable>
            <xsl:call-template name="warning">
              <xsl:with-param name="warningText">
                <xsl:value-of select="concat(local-name(ancestor::mei:*[1]), '/', local-name(),
                  '&#32;', $thisID, '&#32;: Removed @page.scale; added
                  @vu.height')"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
        </xsl:when>
        <xsl:when test="contains(@page.scale, '%')">
          <xsl:copy-of select="@page.scale"/>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <!--<xsl:template match="mei:score/mei:scoreDef/mei:staffGrp" mode="copy">
    <xsl:choose>
      <xsl:when test="@symbol and not(@symbol='line')">
        <staffGrp xmlns:mei="http://www.music-encoding.org/ns/mei" xsl:exclude-result-prefixes="mei
          xlink">
          <xsl:attribute name="symbol">line</xsl:attribute>
          <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="copy"/>
          </xsl:copy>
        </staffGrp>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:copy-of select="@* except @symbol "/>
          <xsl:choose>
            <xsl:when test="@symbol">
              <xsl:copy-of select="@symbol"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="symbol">line</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:apply-templates mode="copy"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>-->

  <xsl:template match="mei:seriesStmt" mode="asBibl">
    <!-- Rename seriesStmt to series -->
    <series xmlns:mei="http://www.music-encoding.org/ns/mei" xsl:exclude-result-prefixes="mei xlink">
      <xsl:apply-templates mode="asBibl"/>
    </series>
  </xsl:template>

  <xsl:template match="mei:source" mode="copy">
    <!-- history, key, tempo, meter, perfMedium, and incip are removed. -->
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates select="comment()" mode="copy"/>
      <xsl:apply-templates select="mei:identifier" mode="copy"/>
      <xsl:apply-templates select="mei:titleStmt" mode="copy"/>
      <xsl:apply-templates select="mei:editionStmt" mode="copy"/>
      <xsl:apply-templates select="mei:pubStmt" mode="copy"/>
      <xsl:apply-templates select="mei:physDesc" mode="copy"/>
      <xsl:apply-templates select="mei:seriesStmt" mode="copy"/>
      <xsl:apply-templates select="mei:contents" mode="copy"/>
      <xsl:apply-templates select="mei:langUsage" mode="copy"/>
      <xsl:apply-templates select="mei:notesStmt" mode="copy"/>
      <xsl:apply-templates select="mei:classification" mode="copy"/>
      <xsl:if test="$verbose">
        <xsl:variable name="thisID">
          <xsl:call-template name="thisID"/>
        </xsl:variable>
        <xsl:call-template name="warning">
          <xsl:with-param name="warningText">
            <xsl:value-of select="concat(local-name(ancestor::mei:*[1]), '/', local-name(), '&#32;',
              $thisID, '&#32;: Reordered content')"/>
            <xsl:if test="mei:history | mei:key | mei:tempo | mei:meter | mei:perfMedium |
              mei:incip">
              <xsl:text>;&#32;Removed history, key, tempo, meter, perfMedium, and incip</xsl:text>
            </xsl:if>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="mei:relatedItem">
        <relationList xmlns:mei="http://www.music-encoding.org/ns/mei"
          xsl:exclude-result-prefixes="mei xlink">
          <xsl:for-each select="mei:relatedItem">
            <relation xmlns:mei="http://www.music-encoding.org/ns/mei"
              xsl:exclude-result-prefixes="mei xlink">
              <xsl:attribute name="target">
                <xsl:choose>
                  <xsl:when test="@xml:id">
                    <xsl:value-of select="concat('#', @xml:id)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat('#', generate-id())"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <xsl:attribute name="rel">
                <xsl:choose>
                  <xsl:when test="@rel='constituent'">
                    <xsl:text>hasPart</xsl:text>
                  </xsl:when>
                  <xsl:when test="@rel='host'">
                    <xsl:text>isPartOf</xsl:text>
                  </xsl:when>
                  <xsl:when test="@rel='isReferencedBy'">
                    <xsl:text>hasSummarization</xsl:text>
                  </xsl:when>
                  <xsl:when test="@rel='original'">
                    <xsl:text>isReproductionOf</xsl:text>
                  </xsl:when>
                  <xsl:when test="@rel='otherFormat'">
                    <xsl:text>hasReproduction</xsl:text>
                  </xsl:when>
                  <xsl:when test="@rel='otherVersion'">
                    <xsl:text>hasReconfiguration</xsl:text>
                  </xsl:when>
                  <xsl:when test="@rel='preceding'">
                    <xsl:text>isSuccessorOf</xsl:text>
                  </xsl:when>
                  <xsl:when test="@rel='references'">
                    <xsl:text>isSummarizationOf</xsl:text>
                  </xsl:when>
                  <xsl:when test="@rel='succeeding'">
                    <xsl:text>hasSuccessor</xsl:text>
                  </xsl:when>
                </xsl:choose>
              </xsl:attribute>
            </relation>
          </xsl:for-each>
        </relationList>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of select="concat(local-name(ancestor::mei:*[1]), '/', local-name(),
                '&#32;', $thisID, '&#32;: Created relationList here; biblList in work')"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:tempo[ancestor::mei:work]" mode="copy">
    <!-- Drop attributes not allowed by schematron rule for tempo in meiHead -->
    <xsl:copy>
      <xsl:apply-templates select="@*[local-name()='label' or local-name()='n' or matches(name(),
        '^xml')]" mode="copy"/>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:work" mode="copy">
    <!-- Re-order work sub-elements -->
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates select="comment()" mode="copy"/>
      <xsl:apply-templates select="mei:identifier" mode="copy"/>
      <xsl:apply-templates select="mei:titleStmt" mode="copy"/>
      <xsl:apply-templates select="mei:key" mode="copy"/>
      <xsl:apply-templates select="mei:meter" mode="copy"/>
      <xsl:apply-templates select="mei:tempo" mode="copy"/>
      <xsl:apply-templates select="mei:mensuration" mode="copy"/>
      <xsl:apply-templates select="mei:incip" mode="copy"/>
      <xsl:apply-templates select="mei:history" mode="copy"/>
      <xsl:apply-templates select="mei:langUsage" mode="copy"/>
      <xsl:apply-templates select="mei:perfMedium" mode="copy"/>
      <xsl:apply-templates select="mei:audience" mode="copy"/>
      <xsl:apply-templates select="mei:contents" mode="copy"/>
      <xsl:apply-templates select="mei:context" mode="copy"/>
      <xsl:if test="$verbose">
        <xsl:variable name="thisID">
          <xsl:call-template name="thisID"/>
        </xsl:variable>
        <xsl:call-template name="warning">
          <xsl:with-param name="warningText">
            <xsl:value-of select="concat(local-name(ancestor::mei:*[1]), '/', local-name(), '&#32;',
              $thisID, '&#32;: Reordered content')"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="mei:relatedItem |
        ancestor::mei:meiHead/mei:fileDesc/mei:sourceDesc/mei:source/mei:relatedItem">
        <!-- relatedItem elements here and in preceding source elements are copied here -->
        <biblList xmlns:mei="http://www.music-encoding.org/ns/mei" xsl:exclude-result-prefixes="mei
          xlink">
          <xsl:apply-templates select="mei:relatedItem |
            ancestor::mei:meiHead/mei:fileDesc/mei:sourceDesc/mei:source/mei:relatedItem"
            mode="asBibl"/>
        </biblList>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of select="concat(local-name(ancestor::mei:*[1]), '/', local-name(),
                '&#32;', $thisID, '&#32;: Moved work/relatedItem and source/relatedItem elements to
                biblList')"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates select="mei:notesStmt" mode="copy"/>
      <xsl:apply-templates select="mei:classification" mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@dur.ges" mode="copy">
    <xsl:attribute name="dur.ges">
      <xsl:choose>
        <xsl:when test="number(.)">
          <xsl:value-of select="concat(., 'p')"/>
          <xsl:if test="$verbose">
            <xsl:variable name="thisID">
              <xsl:for-each select="..">
                <xsl:call-template name="thisID"/>
              </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="thisMeasure">
              <xsl:call-template name="thisMeasure"/>
            </xsl:variable>
            <xsl:call-template name="warning">
              <xsl:with-param name="warningText">
                <xsl:if test="ancestor::mei:incip">
                  <xsl:text>incip/</xsl:text>
                </xsl:if>
                <xsl:value-of select="concat('m. ', $thisMeasure, '/', local-name(..), '&#32;',
                  $thisID, '&#32;: Assumed numeric @dur.ges value to be ppq')"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@fontstyle" mode="copy">
    <xsl:attribute name="fontstyle">
      <xsl:choose>
        <xsl:when test="matches(., 'ital')">
          <xsl:text>italic</xsl:text>
          <xsl:if test="$verbose">
            <xsl:variable name="thisID">
              <xsl:for-each select="..">
                <xsl:call-template name="thisID"/>
              </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="thisMeasure">
              <xsl:call-template name="thisMeasure"/>
            </xsl:variable>
            <xsl:call-template name="warning">
              <xsl:with-param name="warningText">
                <xsl:choose>
                  <xsl:when test="not(normalize-space($thisMeasure)='')">
                    <xsl:if test="ancestor::mei:incip">
                      <xsl:text>incip/</xsl:text>
                    </xsl:if>
                    <xsl:value-of select="concat('m. ', $thisMeasure, '/')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="concat(local-name(ancestor::mei:*[2]), '/')"/>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="concat(local-name(ancestor::mei:*[1]),
                  '&#32;', $thisID, '&#32;: Modified @fontstyle value')"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@rend" mode="copy">
    <xsl:attribute name="rend">
      <xsl:value-of select="replace(., 'dblunderline', 'underline(2)')"/>
    </xsl:attribute>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:for-each select="..">
          <xsl:call-template name="thisID"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="thisMeasure">
        <xsl:call-template name="thisMeasure"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:choose>
            <xsl:when test="not(normalize-space($thisMeasure)='')">
              <xsl:if test="ancestor::mei:incip">
                <xsl:text>incip/</xsl:text>
              </xsl:if>
              <xsl:value-of select="concat('m. ', $thisMeasure, '/')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat(local-name(ancestor::mei:*[2]), '/')"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:value-of select="concat(local-name(ancestor::mei:*[1]), '&#32;', $thisID,
            '&#32;: Modified @rend value')"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@startid | @endid | @altsym | @authURI | @copyof | custos/@target | @hand |
    @chordref | @instr | @def | @nymref | @xlink:role | @new | @old | @ref | @classcode | @avref |
    @origin" mode="copy">
    <xsl:variable name="thisAttr">
      <xsl:value-of select="local-name()"/>
    </xsl:variable>
    <xsl:attribute name="{$thisAttr}">
      <xsl:choose>
        <xsl:when test="not(matches(., '^(http|#)')) and not(matches(., '/'))">
          <xsl:value-of select="concat('#', .)"/>
          <xsl:if test="$verbose">
            <xsl:variable name="thisID">
              <xsl:for-each select="..">
                <xsl:call-template name="thisID"/>
              </xsl:for-each>
            </xsl:variable>
            <xsl:variable name="thisMeasure">
              <xsl:call-template name="thisMeasure"/>
            </xsl:variable>
            <xsl:call-template name="warning">
              <xsl:with-param name="warningText">
                <xsl:if test="ancestor::mei:incip">
                  <xsl:text>incip/</xsl:text>
                </xsl:if>
                <xsl:if test="ancestor::mei:measure">
                  <xsl:value-of select="concat('m. ', $thisMeasure, '/')"/>
                </xsl:if>
                <xsl:value-of select="concat(local-name(ancestor::mei:*[1]), '&#32;', $thisID,
                  '&#32;: Added &quot;#&quot; to ', $thisAttr)"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@plist" mode="copy">
    <xsl:attribute name="plist">
      <xsl:variable name="plistNew">
        <xsl:choose>
          <xsl:when test="not(matches(., '^(http|#)')) and not(matches(., '/'))">
            <xsl:value-of select="concat('#', replace(., '(&#32;)([^#])', '$1#$2'))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="replace(., '(&#32;)([^#])', '$1#$2')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:value-of select="$plistNew"/>
      <xsl:if test="$verbose and not(normalize-space($plistNew) = normalize-space(.))">
        <xsl:variable name="thisID">
          <xsl:for-each select="..">
            <xsl:call-template name="thisID"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="thisMeasure">
          <xsl:call-template name="thisMeasure"/>
        </xsl:variable>
        <xsl:call-template name="warning">
          <xsl:with-param name="warningText">
            <xsl:if test="ancestor::mei:incip">
              <xsl:text>incip/</xsl:text>
            </xsl:if>
            <xsl:if test="ancestor::mei:measure">
              <xsl:value-of select="concat('m. ', $thisMeasure, '/')"/>
            </xsl:if>
            <xsl:value-of select="concat(local-name(ancestor::mei:*[1]), '&#32;', $thisID,
              '&#32;: Added &quot;#&quot; to plist')"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@*|node()" mode="asBibl">
    <!-- Default behavior is to copy the node. -->
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="asBibl"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()" mode="copy">
    <!-- Default behavior is to copy the node. -->
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="copy"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
