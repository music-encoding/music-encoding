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
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:tools="no:where"
    exclude-result-prefixes="xs math xd xhtml tei rng sch egx saxon mei tools"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Apr 10, 2022</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>
                This file prepares examples that are supposed to be rendered (currently using Verovio). 
                As they are embedded in the Guidelines using XInclude, the links to them are not 
                accessible to the XSLT – they are stored in the xi:include element, which is 
                tacitly replaced by the content of these files. Accordingly, it is not possible to just
                convert them from outside the XSLT process – it would not be known where to embed them. 
                Instead, the content of those files, which is embedded in the canonicalized XML, is 
                written to a new file in a specific folder, and an additional placeholder is left in
                the HTML output. Those "exported" examples can then be converted to SVG using other 
                tools, and can be picked up for HTML or PDF display after that, using the placeholders 
                inserted earlier.
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <!--<xsl:template name="prepareLiveExample">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="content" as="node()*"/>
        
        <resultDoc path="{$output.folder}web/liveExamples/{$id}.mei">
            <xsl:sequence select="$content"/>
        </resultDoc>
    </xsl:template>-->
    
    <xsl:template name="prepareLiveExamples">
        <xsl:param name="guidelinesSources" as="node()*"/>
        <xsl:message select="'Preparing live examples'"/>
        
        <xsl:for-each select="$guidelinesSources//egx:egXML['verovio' = tokenize(normalize-space(@rend),' ')]">
            <xsl:variable name="id" select="generate-id(.)" as="xs:string"/>
            <xsl:try>
                <xsl:result-document href="{$assets.folder.generated.images.abs}{$id}.mei" method="xml" indent="yes">
                    <xsl:sequence select="parse-xml(node())"/>
                </xsl:result-document>
                <xsl:catch>
                    <xsl:message select="'Unable to generate separate file for Listing ' || count(preceding::tei:figure[./egx:egXML]) + 1"/>
                </xsl:catch>
            </xsl:try>
            
        </xsl:for-each>
    </xsl:template>
    
    <!--<xsl:template match="resultDoc" mode="prepareLiveExamples">
        <xsl:result-document href="{@path}">
            <xsl:sequence select="node()"/>
        </xsl:result-document>
    </xsl:template>-->
</xsl:stylesheet>