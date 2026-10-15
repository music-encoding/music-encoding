<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xsl xs math xd xi" 
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Nov 12, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> Benjamin W. Bohl @bwbohl</xd:p>
            <xd:p>This XSLT is used in the Apache ANT based building process to create a canonicalized source.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output indent="false"></xsl:output>
    
    <xsl:template match="node()|@*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="processing-instruction('xml-model')" mode="clone">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="processing-instruction('xml-model')" mode="cleanup"/>
    
    <xsl:template match="/processing-instruction('xml-model')" mode="cleanup">
        <xsl:variable name="pi-value.tokens" select="tokenize(., ' ')"/>
        <xsl:variable name="pi-href" select="replace($pi-value.tokens[1], '&quot;validation/', '&quot;../source/validation/')"/>
        <xsl:text>&#xa;</xsl:text>
        <xsl:processing-instruction name="xml-model">
            <xsl:value-of select="$pi-href, $pi-value.tokens[position() > 1]" separator=" "/>
        </xsl:processing-instruction>
    </xsl:template>
    
    <xsl:template match="/">
        <xsl:variable name="xincluded">
            <xsl:apply-templates/>
        </xsl:variable>
        <xsl:apply-templates select="$xincluded" mode="cleanup"/>
    </xsl:template>
    
    <xsl:template match="/" mode="cleanup">
        <xsl:text>&#xa;</xsl:text>
        <xsl:copy>
            <xsl:apply-templates select="node()" mode="cleanup"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="tei:TEI" mode="cleanup">
        <xsl:text>&#xa;</xsl:text>
        <xsl:comment>
            <xsl:text>canonicalized: </xsl:text>
            <xsl:value-of select="current-dateTime()"/>
        </xsl:comment>
        <xsl:text>&#xa;</xsl:text>
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates select="node()" mode="cleanup"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@xml:lang[. = '']" mode="cleanup"/>
    
    <xsl:template match="@xml:base" mode="cleanup"/>
</xsl:stylesheet>