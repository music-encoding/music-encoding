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
    <xsl:text>mei2013To2015.xsl</xsl:text>
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
        <xsl:value-of select="concat(' href=&quot;', $rng_model_path, '&quot;')"/>
        <xsl:text> type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
      </xsl:processing-instruction>
      <xsl:value-of select="$nl"/>
    </xsl:if>

    <xsl:if test="$sch_model_path != ''">
      <xsl:processing-instruction name="xml-model">
        <xsl:value-of select="concat(' href=&quot;', $sch_model_path, '&quot;')"/>
        <xsl:text> type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:text>
      </xsl:processing-instruction>
      <xsl:value-of select="$nl"/>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="mei:mei | mei:meiHead | mei:music">
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

  <xsl:template match="mei:mei | mei:meiHead | mei:music" mode="copy">
    <!-- Change @meiversion attribute on document element; drop @meiversion.num -->
    <xsl:copy>
      <xsl:apply-templates
        select="
          @*[not(local-name() = 'meiversion') and not(local-name() =
          'meiversion.num')]"
        mode="copy"/>
      <xsl:if test="count(ancestor::mei:*) = 0">
        <xsl:attribute name="meiversion">
          <xsl:text>3.0.0</xsl:text>
        </xsl:attribute>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(), '&#32;', $thisID, '&#32;: Modified
                @meiversion')"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:source" mode="copy">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="mei:langUsage and mei:contents">
          <!-- Reorder child elements -->
          <xsl:apply-templates select="@*" mode="copy"/>
          <xsl:apply-templates select="comment()" mode="copy"/>
          <xsl:apply-templates select="mei:identifier" mode="copy"/>
          <xsl:apply-templates select="mei:titleStmt" mode="copy"/>
          <xsl:apply-templates select="mei:editionStmt" mode="copy"/>
          <xsl:apply-templates select="mei:pubStmt" mode="copy"/>
          <xsl:apply-templates select="mei:physDesc" mode="copy"/>
          <xsl:apply-templates select="mei:physLoc" mode="copy"/>
          <xsl:apply-templates select="mei:seriesStmt" mode="copy"/>
          <xsl:apply-templates select="mei:langUsage" mode="copy"/>
          <xsl:apply-templates select="mei:contents" mode="copy"/>
          <xsl:apply-templates select="mei:biblList" mode="copy"/>
          <xsl:apply-templates select="mei:notesStmt" mode="copy"/>
          <xsl:apply-templates select="mei:classification" mode="copy"/>
          <xsl:apply-templates select="mei:itemList" mode="copy"/>
          <xsl:apply-templates select="mei:componentGrp" mode="copy"/>
          <xsl:apply-templates select="mei:relationList" mode="copy"/>
          <xsl:if test="$verbose">
            <xsl:variable name="thisID">
              <xsl:call-template name="thisID"/>
            </xsl:variable>
            <xsl:call-template name="warning">
              <xsl:with-param name="warningText">
                <xsl:choose>
                  <xsl:when test="comment()">
                    <xsl:value-of
                      select="
                        concat(local-name(ancestor::mei:*[1]), '/', local-name(), '&#32;',
                        $thisID, '&#32;: Reordered content, moved comments')"
                    />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of
                      select="
                        concat(local-name(ancestor::mei:*[1]), '/', local-name(), '&#32;',
                        $thisID, '&#32;: Reordered content')"
                    />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="copy"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:barLine | mei:beam | mei:beatRpt | mei:bTrem | mei:meterSig | mei:sb"
    mode="copy">
    <!-- Rename @rend to @form on barLine, beam, beatRpt, bTrem, meterSig, and sb. -->
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name() = 'rend')]" mode="copy"/>
      <xsl:if test="@rend">
        <xsl:attribute name="form">
          <xsl:value-of select="@rend"/>
        </xsl:attribute>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(), '&#32;', $thisID, '&#32;: Renamed @rend to
                @form')"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:pedal" mode="copy">
    <!-- Rename @style to @form on pedal. -->
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name() = 'style')]" mode="copy"/>
      <xsl:if test="@style">
        <xsl:attribute name="form">
          <xsl:value-of select="@style"/>
        </xsl:attribute>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(), '&#32;', $thisID, '&#32;: Renamed @style to
                @form')"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:curve | mei:phrase | mei:slur" mode="copy">
    <!-- Parse @rend into @lform and @lwidth on curve, line, phrase, and slur. -->
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name() = 'rend')]" mode="copy"/>
      <xsl:if test="@rend">
        <xsl:choose>
          <xsl:when test="@rend = 'narrow' or @rend = 'medium' or @rend = 'wide'">
            <xsl:attribute name="lwidth">
              <xsl:value-of select="@rend"/>
            </xsl:attribute>
          </xsl:when>
          <xsl:when test="@rend = 'dashed' or @rend = 'dotted'">
            <xsl:attribute name="lform">
              <xsl:value-of select="@rend"/>
            </xsl:attribute>
          </xsl:when>
        </xsl:choose>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(), '&#32;', $thisID, '&#32;: Moved @rend to
                @lform or @lwidth')"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:line" mode="copy">
    <!-- Parse @rend into @form and @width on line. -->
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name() = 'rend')]" mode="copy"/>
      <xsl:if test="@rend">
        <xsl:choose>
          <xsl:when test="@rend = 'narrow' or @rend = 'medium' or @rend = 'wide'">
            <xsl:attribute name="width">
              <xsl:value-of select="@rend"/>
            </xsl:attribute>
          </xsl:when>
          <xsl:when test="@rend = 'dashed' or @rend = 'dotted'">
            <xsl:attribute name="form">
              <xsl:value-of select="@rend"/>
            </xsl:attribute>
          </xsl:when>
        </xsl:choose>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(), '&#32;', $thisID, '&#32;: Moved @rend value
                to @form or @width')"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:scoreDef[mei:staffGrp[@symbol = 'line']]" mode="copy">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:attribute name="system.leftline">true</xsl:attribute>
      <xsl:if test="$verbose">
        <xsl:variable name="thisID">
          <xsl:call-template name="thisID"/>
        </xsl:variable>
        <xsl:call-template name="warning">
          <xsl:with-param name="warningText">
            <xsl:value-of
              select="
                concat(local-name(), '&#32;', $thisID, '&#32;: Moved outer
              staffGrp @symbol value to @system.leftline')"
            />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:scoreDef/mei:staffGrp[@symbol = 'line'] | mei:grpSym[@symbol = 'line']"
    mode="copy">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name() = 'symbol')]" mode="copy"/>
      <xsl:if test="$verbose">
        <xsl:variable name="thisID">
          <xsl:call-template name="thisID"/>
        </xsl:variable>
        <xsl:call-template name="warning">
          <xsl:with-param name="warningText">
            <xsl:value-of
              select="
                concat(local-name(), '&#32;', $thisID, '&#32;: Removed
              @symbol')"
            />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:revisionDesc" mode="copy">
    <!-- Add a record of the conversion to 2015 to revisionDesc -->
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates mode="copy"/>
      <change xmlns:mei="http://www.music-encoding.org/ns/mei"
        xsl:exclude-result-prefixes="mei
        xlink">
        <xsl:attribute name="n">
          <xsl:value-of select="count(mei:change) + 1"/>
        </xsl:attribute>
        <respStmt/>
        <changeDesc>
          <p>Converted to version 3.0.0 using <xsl:value-of select="$progname"/>, version
              <xsl:value-of select="$version"/></p>
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
          <xsl:value-of
            select="
              concat(local-name(ancestor::mei:*[1]), '/',
              local-name(), '&#32;', $thisID, '&#32;: Added change element')"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:gliss[@text]" mode="copy">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name() = 'text')]" mode="copy"/>
      <xsl:value-of select="@text"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:figDesc[mei:lg or mei:p or mei:quote or mei:table]" mode="copy">
    <xsl:choose>
      <xsl:when test="*[../text()[normalize-space()]]">
        <!-- If there's text directly in figDesc, copy everything but the textcomponent and graphicprimitive elements -->
        <xsl:copy>
          <xsl:apply-templates select="@*" mode="copy"/>
          <xsl:apply-templates
            select="
              node()[not(local-name() = 'lg') and not(local-name() = 'p') and
              not(local-name() = 'quote') and not(local-name() = 'table') and
              not(local-name() = 'anchoredText') and not(local-name() = 'curve') and
              not(local-name() = 'line')]"
            mode="copy"/>
        </xsl:copy>
        <!-- move textcomponent elements into new figDesc -->
        <figDesc xmlns:mei="http://www.music-encoding.org/ns/mei"
          xsl:exclude-result-prefixes="mei
          xlink">
          <xsl:apply-templates
            select="
              @*[not(name() = 'xml:id') and not(local-name() = 'n') and
              not(local-name() = 'label')]"
            mode="copy"/>
          <xsl:if test="@xml:id">
            <xsl:attribute name="xml:id">
              <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@n">
            <xsl:attribute name="n">
              <xsl:value-of select="concat(@n, '_struct')"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@label">
            <xsl:attribute name="label">
              <xsl:value-of select="concat(@label, '_struct')"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates
            select="
              *[local-name() = 'lg' or local-name() = 'p' or
              local-name() = 'quote' or local-name() = 'table']"
            mode="copy"/>
        </figDesc>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(), '&#32;', $thisID, '&#32;: Split figDesc
                with mixed content into two figDesc elements')"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="(mei:anchoredText or mei:curve or mei:line) and $verbose">
      <xsl:text disable-output-escaping="yes">&lt;!-- </xsl:text>
      <xsl:apply-templates
        select="
          *[local-name() = 'anchoredText' or local-name() = 'curve' or
          local-name() = 'line']"
        mode="copy"/>
      <xsl:text disable-output-escaping="yes"> --&gt;</xsl:text>
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(), '&#32;', $thisID, '&#32;: Commented out
            anchoredText,  curve, and line elements')"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:annot[mei:lg or mei:p or mei:quote or mei:table]" mode="copy">
    <xsl:choose>
      <xsl:when test="*[../text()[normalize-space()]]">
        <!-- If there's text directly in annot, copy everything but the textcomponent and graphicprimitive elements -->
        <xsl:copy>
          <xsl:apply-templates select="@*" mode="copy"/>
          <xsl:apply-templates
            select="
              node()[not(local-name() = 'lg') and not(local-name() = 'p') and
              not(local-name() = 'quote') and not(local-name() = 'table')]"
            mode="copy"/>
        </xsl:copy>
        <!-- move textcomponent elements into new annot -->
        <annot xmlns:mei="http://www.music-encoding.org/ns/mei"
          xsl:exclude-result-prefixes="mei
          xlink">
          <xsl:apply-templates
            select="
              @*[not(name() = 'xml:id') and not(local-name() = 'n') and
              not(local-name() = 'label')]"
            mode="copy"/>
          <xsl:if test="@xml:id">
            <xsl:attribute name="xml:id">
              <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@n">
            <xsl:attribute name="n">
              <xsl:value-of select="concat(@n, '_struct')"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@label">
            <xsl:attribute name="label">
              <xsl:value-of select="concat(@label, '_struct')"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates
            select="
              *[local-name() = 'lg' or local-name() = 'p' or
              local-name() = 'quote' or local-name() = 'table']"
            mode="copy"/>
        </annot>
        <xsl:if test="$verbose">
          <xsl:variable name="thisID">
            <xsl:call-template name="thisID"/>
          </xsl:variable>
          <xsl:call-template name="warning">
            <xsl:with-param name="warningText">
              <xsl:value-of
                select="
                  concat(local-name(), '&#32;', $thisID, '&#32;: Split annot
                with mixed content into two annot elements')"
              />
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:tapeConfig" mode="copy">
    <trackConfig xmlns:mei="http://www.music-encoding.org/ns/mei"
      xsl:exclude-result-prefixes="mei
      xlink">
      <xsl:apply-templates select="@*" mode="copy"/>
      <xsl:apply-templates/>
    </trackConfig>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(), '&#32;', $thisID, '&#32;: Renamed tapeConfig to trackConfig')"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@key.sig.mixed" mode="copy" priority="1">
    <!-- new pattern for key.sig.mixed -->
    <xsl:attribute name="key.sig.mixed">
      <xsl:variable name="new">
        <xsl:analyze-string select="." regex="^([a-g])([0-9])(.*)$">
          <xsl:matching-substring>
            <xsl:value-of select="regex-group(1)"/>
            <xsl:value-of select="regex-group(2)"/>
            <xsl:value-of
              select="
                replace(replace(replace(replace(replace(replace(replace(replace(regex-group(3),
                '---', 'tf'), 'fff', 'tf'), '###', 'ts'), 'sss', 'ts'), '--', 'ff'), '##', 'ss'),
                '-', 'f'), '#', 's')"
            />
          </xsl:matching-substring>
        </xsl:analyze-string>
      </xsl:variable>
      <xsl:value-of select="$new"/>
    </xsl:attribute>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(ancestor::mei:*[1]), '/@',
              local-name(), '&#32;', $thisID, '&#32;: Modified @key.sig.mixed')"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@tab.strings" mode="copy" priority="1">
    <!-- new pattern for tab.strings -->
    <xsl:attribute name="tab.strings">
      <xsl:variable name="new">
        <xsl:analyze-string select="." regex="\s+">
          <xsl:non-matching-substring>
            <xsl:analyze-string select="." regex="^([a-g])([\-#fs]?)([0-9])$">
              <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
                <xsl:value-of select="regex-group(3)"/>
                <xsl:value-of select="replace(replace(regex-group(2), '-', 'f'), '#', 's')"/>
                <xsl:text>&#32;</xsl:text>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:non-matching-substring>
        </xsl:analyze-string>
      </xsl:variable>
      <xsl:value-of select="normalize-space($new)"/>
    </xsl:attribute>
    <xsl:if test="$verbose">
      <xsl:variable name="thisID">
        <xsl:call-template name="thisID"/>
      </xsl:variable>
      <xsl:call-template name="warning">
        <xsl:with-param name="warningText">
          <xsl:value-of
            select="
              concat(local-name(ancestor::mei:*[1]), '/@',
              local-name(), '&#32;', $thisID, '&#32;: Modified @tab.strings')"
          />
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:symbol/@ref" mode="copy">
    <xsl:attribute name="altsym">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="@* | node()" mode="copy">
    <!-- Default behavior is to copy the node. -->
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="copy"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
