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
            <xd:p><xd:b>Created on:</xd:b> Nov 11, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This XSLT generates a single HTML file from the MEI ODD sources. This single HTML file 
                may be used for further processing, either towards a PDF file, or towards a publication
                on the MEI website, which requires a separation into multiple files.</xd:p>
            <xd:p>TODO: We should consider to have additional data dictionaries (just the specs part)
                as separate files for each MEI customization.</xd:p>
            <xd:p>It is based on older XSLT that were built for similar tasks.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output indent="yes" method="xhtml"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The relative path where the resulting HTML file should be stored. If changed, you should adjust image paths accordingly (see funcions.xsl)</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="output.folder" select="'./'" as="xs:string"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The version of the Guidelines</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="version" select="//tei:classSpec[@ident = ('att.meiversion','att.meiVersion')]//tei:defaultVal/text()" as="xs:string"/>
        
    <xd:doc>
        <xd:desc>
            <xd:p>The git commit hash of the version this is generated from</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="hash" select="'latest'" as="xs:string"/>
    
    <xsl:include href="odd2html/globalVariables.xsl"/>
    <xsl:include href="odd2html/guidelines.xsl"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The main method of this stylesheet</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:message select="'Processing MEI v' || $version || ' with odd2html.xsl on ' || substring(string(current-date()),1,10)"/>
        <xsl:message select="'  chapters: ' || count($chapters) || ' (' || count($all.chapters/descendant-or-self::chapter) || ' subchapters)'"/>
        <xsl:message select="'  elements: ' || count($elements)"/>
        <xsl:message select="'  model classes: ' || count($model.classes)"/>
        <xsl:message select="'  attribute classes: ' || count($att.classes)"/>
        <xsl:message select="'  data types: ' || count($data.types)"/>
        <xsl:message select="'  macro groups: ' || count($macro.groups)"/>
        
        <xsl:variable name="intro"/>
        <xsl:variable name="toc" select="tools:generateToc()" as="node()"/>
        <xsl:variable name="preface" select="tools:generatePreface()" as="node()"/>
        <xsl:variable name="guidelines" as="node()">
            <main>
                <xsl:apply-templates select="$mei.source//tei:body/child::tei:div" mode="guidelines"/>                
            </main>
        </xsl:variable>
        
        <temporaryWrapper>
            <xsl:sequence select="$preface"/>
            <xsl:sequence select="$toc"/>
            <xsl:sequence select="$guidelines"/>
        </temporaryWrapper>
        
        
    </xsl:template>
    
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>