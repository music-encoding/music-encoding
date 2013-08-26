<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://music-encoding.org/tools/musicxml2mei"
  xmlns:functx="http://www.functx.com" exclude-result-prefixes="mei xs f functx"
  xmlns:saxon="http://saxon.sf.net/" extension-element-prefixes="saxon">

  <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" standalone="no"/>
  <xsl:strip-space elements="*"/>

  <!-- global variables -->
  <xsl:variable name="nl">
    <xsl:text>&#xa;</xsl:text>
  </xsl:variable>
  <xsl:variable name="progName">
    <xsl:text>meiScore2Parts</xsl:text>
  </xsl:variable>
  <xsl:variable name="progVersion">
    <xsl:text>v. 0.1</xsl:text>
  </xsl:variable>

  <!-- 'Match' templates -->
  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="mei:mei">
        <mei xmlns="http://www.music-encoding.org/ns/mei" meiversion="2013">
          <!-- An MEI 2013 input file -->
          <xsl:copy-of select="//mei:meiHead"/>
          <xsl:apply-templates select="//mei:music"/>
        </mei>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="errorMessage">The source file is not an MEI 2013 file!</xsl:variable>
        <xsl:message terminate="yes">
          <xsl:value-of select="normalize-space($errorMessage)"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:music">
    <music xmlns="http://www.music-encoding.org/ns/mei">
      <body>
        <xsl:apply-templates select="mei:body/mei:mdiv"/>
      </body>
    </music>
  </xsl:template>

  <xsl:template match="mei:mdiv">
    <mdiv xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:apply-templates select="mei:score"/>
    </mdiv>
  </xsl:template>

  <xsl:template match="mei:score">
    <parts xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:for-each select="mei:scoreDef/mei:staffGrp/*[local-name()='staffDef' or
        local-name()='staffGrp']">
        <xsl:variable name="partNum">
          <xsl:value-of select="count(preceding-sibling::mei:staffDef) +
            count(preceding-sibling::mei:staffGrp) + 1"/>
        </xsl:variable>
        <xsl:variable name="partStaves">
          <xsl:choose>
            <xsl:when test="local-name(.)='staffDef'">
              <xsl:value-of select="@n"/>
            </xsl:when>
            <xsl:when test="local-name(.)='staffGrp'">
              <xsl:value-of select="min(mei:staffDef/@n)"/>
              <xsl:text>-</xsl:text>
              <xsl:value-of select="max(mei:staffDef/@n)"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:message>Part <xsl:value-of select="$partNum"/>: staff(s) <xsl:value-of
            select="$partStaves"/>
        </xsl:message>
        <part>
          <xsl:attribute name="n">
            <xsl:value-of select="$partNum"/>
          </xsl:attribute>
          <scoreDef>
            <xsl:for-each select="ancestor::mei:scoreDef">
              <xsl:copy-of select="@*"/>
              <xsl:copy-of select="mei:pgHead|mei:pgHead2|mei:pgFoot|mei:pgFoot2"/>
            </xsl:for-each>
            <xsl:choose>
              <xsl:when test="local-name(.)='staffDef'">
                <staffGrp>
                  <xsl:copy-of select="."/>
                </staffGrp>
              </xsl:when>
              <xsl:when test="local-name(.)='staffGrp'">
                <xsl:copy-of select="."/>
              </xsl:when>
            </xsl:choose>
          </scoreDef>
          <xsl:apply-templates
            select="ancestor::mei:score/mei:section|ancestor::mei:score/mei:ending"/>
        </part>
      </xsl:for-each>
    </parts>
  </xsl:template>

  <xsl:template match="mei:section|mei:ending">
    <xsl:variable name="sectionOrEnding">
      <xsl:value-of select="local-name(.)"/>
    </xsl:variable>
    <xsl:element name="{$sectionOrEnding}" xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:apply-templates select="mei:pb|mei:sb|mei:scoreDef|mei:measure"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="mei:pb|mei:sb|mei:scoreDef">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="mei:measure">
    <measure xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:copy-of select="@*[not(name()='xml:id')]"/>
    </measure>
  </xsl:template>

</xsl:stylesheet>
