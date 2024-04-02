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
            <xd:p>This file holds rules on how to generate spec pages for attribute classes</xd:p>
            <xd:p>
                A single attribute class page has the following facets:
                <xd:ul>
                    <xd:li>Heading</xd:li>
                    <xd:li>Desc</xd:li>
                    <xd:li>Chapter references</xd:li>
                    <xd:li>Module</xd:li>
                    <xd:li>Attributes</xd:li>
                    <xd:li>Available at</xd:li>
                    <xd:li>Remarks (optional)</xd:li>
                    <xd:li>Constraints (optional)</xd:li>
                    <xd:li>Declaration</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a section with all elementSpecs</xd:p>
        </xd:desc>
        <xd:return>the section element</xd:return>
    </xd:doc>
    <xsl:function name="tools:getAttClassSpecs" as="node()">
        <xsl:message select="'Getting attribute class specs'"/>
        <section id="attClassSpecs" class="specSection">
            <h1>Attribute Class Specifications</h1>
            <xsl:for-each select="$att.classes">
                <xsl:sort select="@ident" data-type="text"/>
                <xsl:sequence select="tools:getAttClassSpecPage(.)"/>
            </xsl:for-each>
        </section>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a section for a single classSpec[@type='atts']</xd:p>
        </xd:desc>
        <xd:param name="att.class">the attribute class</xd:param>
        <xd:return>the section element</xd:return>
    </xd:doc>
    <xsl:function name="tools:getAttClassSpecPage" as="node()">
        <xsl:param name="att.class" as="node()"/>
        
        <xsl:variable name="refs" select="tools:getReferencesFacet(tools:getReferencingChapters($att.class/@ident, 'modelClass'))" as="node()?"/>
        <xsl:variable name="moduleFacet" select="tools:getModuleFacet($att.class)" as="node()"/>
        <xsl:variable name="attributesFacet" select="tools:getAttributesFacet($att.class)" as="node()"/>
        
        <xsl:variable name="availableAtFacet" select="tools:getElementsWithAttClassFacet($att.class)" as="node()"/>
        
        <xsl:variable name="remarksFacet" select="tools:getRemarksFacet($att.class)" as="node()?"/>
        <xsl:variable name="constraintsFacet" select="tools:getSchematronFacet($att.class)" as="node()?"/>
        <xsl:variable name="declarationFacet" select="tools:getDeclarationFacet($att.class)" as="node()"/>
        
        <section class="specPage attClassSpec">
            <h2 id="{$att.class/@ident}"><xsl:value-of select="$att.class/@ident"/></h2>
            <div class="specs">
                <div class="desc">
                    <xsl:apply-templates select="$att.class/tei:desc/node()" mode="guidelines"/>
                    <xsl:sequence select="$refs"/>
                </div>
                <xsl:sequence select="$moduleFacet"/>
                <xsl:sequence select="$attributesFacet"/>
                <xsl:sequence select="$availableAtFacet"/>
                <xsl:sequence select="$remarksFacet"/>
                <xsl:sequence select="$constraintsFacet"/>
                <xsl:sequence select="$declarationFacet"/>
            </div>
        </section>
    </xsl:function>
    
</xsl:stylesheet>