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
            <xd:p>This file holds rules on how to generate spec pages for elementSpecs</xd:p>
            <xd:p>
                A single elementSpec page has the following facets:
                <xd:ul>
                    <xd:li>Heading</xd:li>
                    <xd:li>Desc</xd:li>
                    <xd:li>Chapter references</xd:li>
                    <xd:li>Module</xd:li>
                    <xd:li>Attributes</xd:li>
                    <xd:li>Member Of</xd:li>
                    <xd:li>Contained By</xd:li>
                    <xd:li>May contain</xd:li>
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
    <xsl:function name="tools:getElementSpecs" as="node()">
        <xsl:message select="'Getting element specs'"/>
        <section id="elementSpecs" class="specSection">
            <h1>Element Specifications</h1>
            <xsl:for-each select="$elements">
                <xsl:sort select="@ident" data-type="text"/>
                <xsl:sequence select="tools:getElementSpecPage(.)"/>
            </xsl:for-each>
        </section>
    </xsl:function>
        
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a section for a single elementSpec</xd:p>
        </xd:desc>
        <xd:param name="element">the element</xd:param>
        <xd:return>the section element</xd:return>
    </xd:doc>
    <xsl:function name="tools:getElementSpecPage" as="node()">
        <xsl:param name="element" as="node()"/>
        
        <xsl:variable name="refs" select="tools:getReferencesFacet(tools:getReferencingChapters($element/@ident, 'element'))" as="node()?"/>
        <xsl:variable name="moduleFacet" select="tools:getModuleFacet($element)" as="node()"/>
        <xsl:variable name="attributesFacet" select="tools:getAttributesFacet($element)" as="node()"/>
        <xsl:variable name="memberOfFacet" select="tools:getMemberOfFacet($element)" as="node()"/>
        <xsl:variable name="containedByFacet" select="tools:getContainedByFacet($element)" as="node()"/>
        <xsl:variable name="mayContainFacet" select="tools:getMayContainFacet($element)" as="node()"/>
        <xsl:variable name="remarksFacet" select="tools:getRemarksFacet($element)" as="node()?"/>
        <xsl:variable name="constraintsFacet" select="tools:getSchematronFacet($element)" as="node()?"/>
        <xsl:variable name="declarationFacet" select="tools:getDeclarationFacet($element)" as="node()"/>
        
        <section class="specPage elementSpec">
            <h2 id="{$element/@ident}">&lt;<xsl:value-of select="$element/@ident"/>&gt;</h2>
            <div class="specs">
                <div class="desc">
                    <xsl:if test="$element/tei:gloss">
                        <xsl:value-of select="concat('(', $element/tei:gloss/text(), ') – ')"/>
                    </xsl:if>
                    <xsl:apply-templates select="$element/tei:desc/node()" mode="guidelines"/>
                    <xsl:sequence select="$refs"/>
                </div>
                <xsl:sequence select="$moduleFacet"/>
                <xsl:sequence select="$attributesFacet"/>
                <xsl:sequence select="$memberOfFacet"/>
                <xsl:sequence select="$containedByFacet"/>
                <xsl:sequence select="$mayContainFacet"/>
                <xsl:sequence select="$remarksFacet"/>
                <xsl:sequence select="$constraintsFacet"/>
                <xsl:sequence select="$declarationFacet"/>
            </div>
        </section>
    </xsl:function>
    
</xsl:stylesheet>