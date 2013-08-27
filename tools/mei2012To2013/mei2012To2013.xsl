<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns="http://www.music-encoding.org/ns/mei" xmlns:mei="http://www.music-encoding.org/ns/mei"
  xmlns:xlink="http://www.w3.org/1999/xlink">

  <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" standalone="no"/>
  <xsl:strip-space elements="*"/>

  <xsl:template match="/">
    <!-- Add oXygen processing instructions; -->
    <xsl:processing-instruction name="xml-model">
      <xsl:text>href="../../../schemata/mei-CMN.rng" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:text>
    </xsl:processing-instruction>
    <xsl:text>&#xA;</xsl:text>
    <xsl:processing-instruction name="xml-model">
      <xsl:text>href="../../../schemata/mei-CMN.rng" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
    </xsl:processing-instruction>
    <xsl:text>&#xA;</xsl:text>
    <xsl:apply-templates select="mei:*" mode="copy"/>
  </xsl:template>

  <xsl:template match="mei:mei|mei:meiHead|mei:music" mode="copy">
    <!-- Add @meiversion attribute -->
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name()='meiversion')]"/>
      <xsl:if test="@meiversion">
        <xsl:attribute name="meiversion">
          <xsl:text>2013</xsl:text>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:date" mode="copy">
    <!-- @reg renamed to @isodate -->
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name()='reg')]"/>
      <xsl:if test="@reg">
        <xsl:attribute name="isodate">
          <xsl:value-of select="@reg"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:event" mode="copy">
    <!-- @reg renamed to @isodate, mixed content wrapped by <p> -->
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name()='reg')]"/>
      <xsl:if test="@reg">
        <xsl:attribute name="isodate">
          <xsl:value-of select="@reg"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="text() and mei:*">
          <p xmlns:mei="http://www.music-encoding.org/ns/mei" xsl:exclude-result-prefixes="mei">
            <xsl:apply-templates mode="copy"/>
          </p>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="copy"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:list/mei:item" mode="copy">
    <li xmlns:mei="http://www.music-encoding.org/ns/mei" xsl:exclude-result-prefixes="mei">
      <xsl:apply-templates mode="copy"/>
    </li>
  </xsl:template>

  <xsl:template match="mei:physDesc" mode="copy">
    <!-- physLoc is pulled out and presented after physDesc. -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="mei:*[not(local-name()='physLoc')]" mode="copy"/>
    </xsl:copy>
    <xsl:apply-templates select="mei:physLoc" mode="copy"/>
  </xsl:template>

  <xsl:template match="mei:physLoc" mode="copy">
    <!-- The 2013 model only allows repository and identifier elements. -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="mei:repository" mode="copy"/>
      <xsl:apply-templates select="mei:identifier" mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:physLoc/mei:repository" mode="copy">
    <!-- New repository element will contain the textual content of the ancestor 
      physLoc as well as any textual and element content of repository -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="ancestor::mei:physLoc/text() |
        ancestor::mei:physLoc/mei:*[not(local-name()='repository') and
        not(local-name()='identifier')] | text() | mei:*" mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:pubStmt/mei:geogName" mode="copy">
    <pubPlace xmlns:mei="http://www.music-encoding.org/ns/mei" xsl:exclude-result-prefixes="mei">
      <xsl:variable name="attributeValues">
        <xsl:value-of select="@*"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="not($attributeValues='')">
          <geogName xmlns:mei="http://www.music-encoding.org/ns/mei"
            xsl:exclude-result-prefixes="mei">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates mode="copy"/>
          </geogName>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="copy"/>
        </xsl:otherwise>
      </xsl:choose>
    </pubPlace>
  </xsl:template>

  <xsl:template match="mei:rend" mode="copy">
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name()='rend') and not(local-name()='fontstyle')]"/>
      <xsl:if test="@fontstyle">
        <xsl:attribute name="fontstyle">
          <xsl:choose>
            <xsl:when test="@fontstyle = 'ital'">
              <xsl:text>italic</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@rend">
        <xsl:attribute name="rend">
          <xsl:value-of select="replace(@rend, 'dblunderline', 'underline(2)')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:rest" mode="copy">
    <!-- Translate @line values to @loc (which includes spaces) -->
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name()='line')]"/>
      <xsl:if test="@line">
        <xsl:attribute name="loc">
          <xsl:value-of select="translate(@line, '12345', '13579')"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:revisionDesc" mode="copy">
    <!-- Add a record of the conversion to revisionDesc -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="copy"/>
      <change xmlns:mei="http://www.music-encoding.org/ns/mei" xsl:exclude-result-prefixes="mei">
        <xsl:attribute name="n">
          <xsl:value-of select="count(mei:change) + 1"/>
        </xsl:attribute>
        <respStmt/>
        <changeDesc>
          <p>Converted to MEI 2013 using mei2012To2013.xsl</p>
        </changeDesc>
        <date>
          <xsl:attribute name="isodate">
            <xsl:value-of select="format-date(current-date(), '[Y]-[M02]-[D02]')"/>
          </xsl:attribute>
        </date>
      </change>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:scoreDef" mode="copy">
    <!-- @page.scale is replaced by @vu.height; @page.units is removed. -->
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name()='page.scale') and not(local-name()='page.units')]"/>
      <xsl:choose>
        <xsl:when test="contains(@page.scale,':')">
          <xsl:attribute name="vu.height">
            <xsl:value-of select="number(substring-after(@page.scale, ':')) div 8"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="contains(@page.scale, '%')">
          <xsl:copy-of select="@page.scale"/>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:source" mode="copy">
    <!-- history, key, tempo, meter, perfMedium, and incip are removed. -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
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
      <!-- relatedItem elements are copied to relation elements with
        commented-out content. Because the @rel attribute is missing,
        validation will fail.
      -->
      <xsl:if test="mei:relatedItem">
        <relationList xmlns:mei="http://www.music-encoding.org/ns/mei"
          xsl:exclude-result-prefixes="mei">
          <xsl:for-each select="mei:relatedItem">
            <relation xmlns:mei="http://www.music-encoding.org/ns/mei"
              xsl:exclude-result-prefixes="mei">
              <xsl:text disable-output-escaping="yes">&lt;!--</xsl:text>
              <xsl:apply-templates select="." mode="copy"/>
              <xsl:text disable-output-escaping="yes">--&gt;</xsl:text>
            </relation>
          </xsl:for-each>
        </relationList>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:work" mode="copy">
    <!-- Re-order work sub-elements -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="mei:identifier" mode="copy"/>
      <xsl:apply-templates select="mei:titleStmt" mode="copy"/>
      <xsl:apply-templates select="mei:key" mode="copy"/>
      <xsl:apply-templates select="mei:meter" mode="copy"/>
      <xsl:apply-templates select="mei:tempo" mode="copy"/>
      <xsl:apply-templates select="mei:mensuration" mode="copy"/>
      <xsl:apply-templates select="mei:incip" mode="copy"/>
      <!--<xsl:apply-templates select="mei:otherChar" mode="copy"/>-->
      <xsl:apply-templates select="mei:history" mode="copy"/>
      <xsl:apply-templates select="mei:langUsage" mode="copy"/>
      <xsl:apply-templates select="mei:perfMedium" mode="copy"/>
      <xsl:apply-templates select="mei:audience" mode="copy"/>
      <xsl:apply-templates select="mei:contents" mode="copy"/>
      <xsl:apply-templates select="mei:context" mode="copy"/>
      <xsl:if test="mei:relatedItem |
        ancestor::mei:meiHead/mei:fileDesc/mei:sourceDesc/mei:source/mei:relatedItem">
        <!-- relatedItem elements here and in preceding source elements are copied here -->
        <biblList xmlns:mei="http://www.music-encoding.org/ns/mei" xsl:exclude-result-prefixes="mei">
          <xsl:for-each select="mei:relatedItem |
            ancestor::mei:meiHead/mei:fileDesc/mei:sourceDesc/mei:source/mei:relatedItem">
            <bibl>
              <!-- BUT there's a problem w/ mei-CMN.rng: it doesn't allow <relatedItem>
                within <bibl>! -->
              <xsl:text disable-output-escaping="yes">&lt;!--</xsl:text>
              <xsl:apply-templates select="." mode="copy"/>
              <xsl:text disable-output-escaping="yes">--&gt;</xsl:text>
            </bibl>
          </xsl:for-each>
        </biblList>
      </xsl:if>
      <xsl:apply-templates select="mei:notesStmt" mode="copy"/>
      <xsl:apply-templates select="mei:classification" mode="copy"/>
      <!--<xsl:apply-templates select="mei:expressionList" mode="copy"/>
      <xsl:apply-templates select="mei:componentGrp" mode="copy"/>
      <xsl:apply-templates select="mei:relationList" mode="copy"/>-->
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:fermata" mode="copy">
    <!-- @dur on control events renamed to @tstamp2 -->
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name()='dur') and not(local-name()='place')]"/>
      <xsl:if test="@dur">
        <xsl:attribute name="tstamp2">
          <xsl:value-of select="@dur"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@place">
        <xsl:attribute name="place">
          <xsl:choose>
            <xsl:when test="@place='within'">
              <xsl:text>above</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>below</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:arpeg|mei:beamSpan|mei:breath|mei:hairpin|
    mei:harpPedal|mei:octave|mei:pedal|mei:reh|mei:slur|mei:tie|mei:tupletSpan|
    mei:bend|mei:dir|mei:dynam|mei:gliss|mei:phrase|mei:tempo|mei:mordent|
    mei:trill|mei:turn|mei:harm" mode="copy">
    <!-- @dur on control events renamed to @tstamp2 -->
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name()='dur')]"/>
      <xsl:if test="@dur">
        <xsl:attribute name="tstamp2">
          <xsl:value-of select="@dur"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:*[not(local-name()='rend') and @fontstyle]" mode="copy">
    <!-- 'ital' value for @fontstyle changed to 'italic'; this template applies to 
      elements other than rend. -->
    <xsl:copy>
      <xsl:copy-of select="@*[not(local-name()='fontstyle')]"/>
      <xsl:attribute name="fontstyle">
        <xsl:choose>
          <xsl:when test="@fontstyle = 'ital'">
            <xsl:text>italic</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()" mode="copy">
    <!-- Default behavior is to copy the node. -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
