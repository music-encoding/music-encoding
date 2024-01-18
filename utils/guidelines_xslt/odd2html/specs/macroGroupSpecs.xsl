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
            <xd:p>This file holds rules on how to generate spec pages for macro groups</xd:p>
            <xd:p>
                A single macro group page has the following facets:
                <xd:ul>
                    <xd:li>Heading</xd:li>
                    <xd:li>Desc</xd:li>
                    <!--<xd:li>Chapter references</xd:li>-->
                    <xd:li>Module</xd:li>
                    <!--<xd:li>Member Of</xd:li>-->
                    <!--<xd:li>Members</xd:li>-->
                    <xd:li>Contained By</xd:li>
                    <xd:li>May contain</xd:li>
                    <!--<xd:li>Remarks (optional)</xd:li>-->
                    <!--<xd:li>Constraints (optional)</xd:li>-->
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
    <xsl:function name="tools:getMacroGroupSpecs" as="node()">
        <xsl:message select="'Getting macro group specs'"/>
        <section id="macroGroupSpecs" class="specSection">
            <h1>Macro Group Specifications</h1>
            <xsl:for-each select="$macro.groups">
                <xsl:sort select="@ident" data-type="text"/>
                <xsl:sequence select="tools:getMacroGroupSpecPage(.)"/>
            </xsl:for-each>
        </section>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a section for a single macroSpec[@type='pe']</xd:p>
        </xd:desc>
        <xd:param name="macro.group">the macro group</xd:param>
        <xd:return>the section element</xd:return>
    </xd:doc>
    <xsl:function name="tools:getMacroGroupSpecPage" as="node()">
        <xsl:param name="macro.group" as="node()"/>
        
        <xsl:variable name="moduleFacet" select="tools:getModuleFacet($macro.group)" as="node()"/>
        
        <xsl:variable name="containedByFacet" select="tools:getContainedByFacet($macro.group)" as="node()"/>
        <xsl:variable name="mayContainFacet" select="tools:getMayContainFacet($macro.group)" as="node()"/>
        
        <xsl:variable name="declarationFacet" select="tools:getDeclarationFacet($macro.group)" as="node()"/>
        
        <section class="specPage macroGroupSpec">
            <h2 id="{$macro.group/@ident}"><xsl:value-of select="$macro.group/@ident"/></h2>
            <div class="specs">
                <div class="desc">
                    <xsl:apply-templates select="$macro.group/tei:desc/node()" mode="guidelines"/>
                </div>
                <xsl:sequence select="$moduleFacet"/>
                <!-- TODO: fix this: apparently recursive calls -->
                <xsl:sequence select="$containedByFacet"/>                
                <xsl:sequence select="$mayContainFacet"/>
                <xsl:sequence select="$declarationFacet"/>
            </div>
        </section>
    </xsl:function>
    
</xsl:stylesheet>