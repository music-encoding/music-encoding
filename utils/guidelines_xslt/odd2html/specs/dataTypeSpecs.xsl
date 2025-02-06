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
            <xd:p><xd:b>Created on:</xd:b> Nov 12, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This file holds rules on how to generate spec pages for macroSpec[@type = 'dt']</xd:p>
            <xd:p>
                A single data type page has the following facets:
                <xd:ul>
                    <xd:li>Heading</xd:li>
                    <xd:li>Desc</xd:li>
                    <!--<xd:li>Chapter references</xd:li>-->
                    <xd:li>Module</xd:li>
                    <xd:li>Used By</xd:li>
                    <xd:li>Tolerated values</xd:li>
                    <xd:li>Remarks (optional)</xd:li>
                    <xd:li>Constraints (optional)</xd:li>
                    <xd:li>Declaration</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a section with all data type specs</xd:p>
        </xd:desc>
        <xd:return>the section element</xd:return>
    </xd:doc>
    <xsl:function name="tools:getDataTypeSpecs" as="node()">
        <xsl:message select="'Getting data type specs'"/>
        <section id="dataTypeSpecs" class="specSection">
            <h1>Data Type Specifications</h1>
            <xsl:for-each select="$data.types">
                <xsl:sort select="@ident" data-type="text"/>
                <xsl:sequence select="tools:getDataTypeSpecPage(.)"/>
            </xsl:for-each>
        </section>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a section for a single dataTypeSpec</xd:p>
        </xd:desc>
        <xd:param name="data.type">the data type</xd:param>
        <xd:return>the section element</xd:return>
    </xd:doc>
    <xsl:function name="tools:getDataTypeSpecPage" as="node()">
        <xsl:param name="data.type" as="node()"/>
        
        <xsl:variable name="moduleFacet" select="tools:getModuleFacet($data.type)" as="node()"/>
        <xsl:variable name="usedByFacet" select="tools:getDatatypeUsersFacet($data.type)" as="node()"/>
        <xsl:variable name="toleratedValuesFacet" select="tools:getToleratedValuesFacet($data.type)" as="node()?"/>
        <xsl:variable name="remarksFacet" select="tools:getRemarksFacet($data.type)" as="node()?"/>
        <xsl:variable name="constraintsFacet" select="tools:getSchematronFacet($data.type)" as="node()?"/>
        <xsl:variable name="declarationFacet" select="tools:getDeclarationFacet($data.type)" as="node()"/>
        
        <section class="specPage dataTypeSpec">
            <h2 id="{$data.type/@ident}"><xsl:value-of select="$data.type/@ident"/></h2>
            <div class="specs">
                <div class="desc">
                    <xsl:apply-templates select="$data.type/tei:desc/node()" mode="guidelines"/>                    
                </div>
                <xsl:sequence select="$moduleFacet"/>
                <xsl:sequence select="$usedByFacet"/>
                <xsl:sequence select="$toleratedValuesFacet"/>
                <xsl:sequence select="$remarksFacet"/>
                <xsl:sequence select="$constraintsFacet"/>
                <xsl:sequence select="$declarationFacet"/>
            </div>
        </section>
    </xsl:function>
    
</xsl:stylesheet>