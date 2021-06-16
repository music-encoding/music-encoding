<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:egx="http://www.tei-c.org/ns/Examples"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:rng="http://relaxng.org/ns/structure/1.0"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:tools="no:where"
    exclude-result-prefixes="xs math xd xhtml tei tools rng sch egx"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Nov 13, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This XSLT is part of odd2html.xsl. It prepares a HTML file for rendering as PDF.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This function is the main starting point for preparing a PDF version of the guidelines.</xd:p>
            <xd:p>It will generate resulting documents inside $output.folder/web</xd:p>
        </xd:desc>
        <xd:param name="input">A single page version of the Guidelines (already HTML)</xd:param>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Resolves classes</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="div['classes' = tokenize(normalize-space(@class),' ')]" mode="preparePDF">
        
        <xsl:variable name="classType" select="preceding-sibling::div[@class='label']/text()" as="xs:string"/>
        <xsl:variable name="items" select=".//item" as="node()*"/>
        <xsl:variable name="obj.ident" select="ancestor::section/h2/@id" as="xs:string"/>
        
        <!--<xsl:message select="$obj.ident || ' has following items in the _' || $classType || '_ section: ' || string-join($items/@ident, ', ')"/>-->
        
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <xsl:apply-templates select="text" mode="#current"/>
            <xsl:for-each select="$items">
                <xsl:sort select="@ident" data-type="text"/>
                <xsl:variable name="current.item" select="." as="node()"/>
                <xsl:variable name="start" as="xs:string">
                    <xsl:choose>
                        <xsl:when test="$elements/self::tei:elementSpec[@ident = $obj.ident]"><xsl:value-of select="'&lt;' || $obj.ident || '&gt;'"/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="$obj.ident"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="end" as="xs:string">
                    <xsl:choose>
                        <xsl:when test="$elements/self::tei:elementSpec[@ident = $current.item/@ident]"><xsl:value-of select="'&lt;' || $current.item/@ident || '&gt;'"/></xsl:when>
                        <xsl:when test="$current.item/@class='attribute'"><xsl:value-of select="'@' || $current.item/@ident"/></xsl:when>
                        <xsl:otherwise><xsl:value-of select="$obj.ident"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <div class="classItem">
                    <label><xsl:value-of select="$current.item/link/node()"/></label>
                    <div class="desc"><xsl:apply-templates select="$current.item/desc/node()" mode="#current"/></div>
                    <div class="breadcrumb">
                        <span class="step start"><xsl:value-of select="$start"/></span>
                        <xsl:for-each select="$current.item/ancestor::group/link">
                            <span class="step"><xsl:apply-templates select="node()" mode="#current"/></span>
                        </xsl:for-each>
                        <span class="step end"><xsl:value-of select="$end"/></span>
                    </div>
                </div>
            </xsl:for-each>            
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Generates a disclaimer that an element may have textual content</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="text" mode="preparePDF">
        <!-- this is for textual content in elements -->
        <div class="classItem disclaimer">
            may contain text
        </div>
    </xsl:template>
    
</xsl:stylesheet>