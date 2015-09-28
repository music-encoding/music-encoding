<?xml version="1.0" encoding="UTF-8"?>

<!--
	
	marc2mei59x.xsl - XSLT (2.0) stylesheet component for transformation 
	of MARC XML to MEI header XML
	
	Perry Roland <pdr4h@virginia.edu>
	Music Library
	University of Virginia
	
	For info on MARC XML, see http://www.loc.gov/marc/marcxml.html
	For info on the MEI header, see http://music-encoding.org
	For info on RISM, see http://www.rism-ch.org
	
	This stylesheet is a component of the marc2mei.xsl stylesheet. The
	templates defined here override those in the including file. The
	analog and subfieldSelect templates are defined in marc2mei.xsl.
	
-->

<xsl:stylesheet version="2.0" xmlns="http://www.music-encoding.org/ns/mei"
  xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:marc="http://www.loc.gov/MARC21/slim" exclude-result-prefixes="marc mei">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" media-type="text/xml"/>

  <!-- 594 (RISM scoring note) -->
  <xsl:template match="marc:datafield[@tag = '594']" priority="2">
    <xsl:variable name="tag" select="@tag"/>
    <annot type="scoring">
      <xsl:attribute name="analog">
        <xsl:value-of select="$tag"/>
      </xsl:attribute>
      <xsl:variable name="delimiter">
        <xsl:text>; </xsl:text>
      </xsl:variable>
      <!-- cat everything into the $str variable -->
      <xsl:variable name="str">
        <xsl:for-each select="marc:subfield">
          <xsl:variable name="code">
            <xsl:value-of select="@code"/>
          </xsl:variable>
          <xsl:variable name="scoring">
            <xsl:choose>
              <xsl:when test="$code = 'a'">Solo voice</xsl:when>
              <xsl:when test="$code = 'b'">Additional solo voice</xsl:when>
              <xsl:when test="$code = 'c'">Choir voice</xsl:when>
              <xsl:when test="$code = 'd'">Additional choir voice</xsl:when>
              <xsl:when test="$code = 'e'">Solo intrument</xsl:when>
              <xsl:when test="$code = 'f'">Strings</xsl:when>
              <xsl:when test="$code = 'g'">Woodwinds</xsl:when>
              <xsl:when test="$code = 'h'">Brasses</xsl:when>
              <xsl:when test="$code = 'i'">Plucked instruments</xsl:when>
              <xsl:when test="$code = 'k'">Percussion</xsl:when>
              <xsl:when test="$code = 'l'">Keyboards</xsl:when>
              <xsl:when test="$code = 'm'">Other instruments</xsl:when>
              <xsl:when test="$code = 'n'">Basso continuo</xsl:when>
              <xsl:otherwise>[unspecified]</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <!-- cat the values: -->
          <xsl:value-of select="$scoring"/>
          <xsl:text>: </xsl:text>
          <xsl:value-of select="text()"/>
          <xsl:value-of select="$delimiter"/>
        </xsl:for-each>
      </xsl:variable>
      <!-- truncate the last delimiter -->
      <xsl:value-of select="substring($str, 1, string-length($str) - string-length($delimiter))"/>
    </annot>
  </xsl:template>

  <!-- 595 (RISM cast item) -->
  <xsl:template match="marc:datafield[@tag = '595']" priority="2">
    <xsl:variable name="tag" select="@tag"/>
    <castItem xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:if test="$analog = 'true'">
        <xsl:attribute name="analog">
          <xsl:value-of select="concat('marc:', $tag)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:call-template name="subfieldSelect">
        <xsl:with-param name="codes">a</xsl:with-param>
      </xsl:call-template>
    </castItem>
  </xsl:template>

</xsl:stylesheet>
