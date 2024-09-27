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
            <xd:p>This file holds rules on how to generate spec pages for moduleSpecs</xd:p>
            <xd:p>
                A single moduleSpec page has the following facets:
                <xd:ul>
                    <xd:li>Heading</xd:li>
                    <xd:li>Desc</xd:li>
                    <xd:li>List of elements</xd:li>
                    <xd:li>List of model classes</xd:li>
                    <xd:li>List of macro groups</xd:li>
                    <xd:li>List of attribute classes</xd:li>
                    <xd:li>List of data types</xd:li>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a section with all moduleSpecs</xd:p>
        </xd:desc>
        <xd:return>the section element</xd:return>
    </xd:doc>
    <xsl:function name="tools:getModuleSpecs" as="node()">
        <section id="moduleSpecs" class="specSection">
            <h1>MEI Modules</h1>
            <xsl:for-each select="$modules">
                <xsl:sort select="@ident" data-type="text"/>
                <xsl:sequence select="tools:getModuleSpecPage(.)"/>
            </xsl:for-each>
        </section>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a section for a single moduleSpec</xd:p>
        </xd:desc>
        <xd:param name="module">the module</xd:param>
        <xd:return>the section element</xd:return>
    </xd:doc>
    <xsl:function name="tools:getModuleSpecPage" as="node()">
        <xsl:param name="module" as="node()"/>
        <xsl:variable name="module.content" select="$module/parent::tei:specGrp" as="node()"/>
        
        <section class="specPage moduleSpec">
            <h2 id="{$module/@ident}"><xsl:value-of select="$module/@ident"/></h2>
            
            <div class="specs">
                <div class="desc">
                    <xsl:apply-templates select="$module/tei:desc/node()" mode="guidelines"/>                    
                </div>
                <div class="contentListBox">
                    <h3>Elements in <xsl:value-of select="$module/@ident"/></h3>
                    <div class="contents">
                        <xsl:variable name="items" select="$module.content//tei:elementSpec" as="node()*"/>
                        <xsl:for-each select="$items">
                            <a class="{tools:getLinkClasses(@ident)}" href="#{@ident}" title="{normalize-space(string-join(child::tei:desc//text(),' '))}">&lt;<xsl:value-of select="@ident"/>&gt;</a><xsl:if test="position() lt count($items)">, </xsl:if>
                        </xsl:for-each>
                        <xsl:if test="count($items) = 0">
                            <span class="placeholder">– no elements defined in <xsl:value-of select="$module/@ident"/> – </span>
                        </xsl:if>
                    </div>
                </div>
                <div class="contentListBox">
                    <h3>Model Classes in <xsl:value-of select="$module/@ident"/></h3>
                    <div class="contents">
                        <xsl:variable name="items" select="$module.content//tei:classSpec[@type = 'model']" as="node()*"/>
                        <xsl:for-each select="$items">
                            <a class="{tools:getLinkClasses(@ident)}" href="#{@ident}" title="{normalize-space(string-join(child::tei:desc//text(),' '))}"><xsl:value-of select="@ident"/></a><xsl:if test="position() lt count($items)">, </xsl:if>        
                        </xsl:for-each>
                        <xsl:if test="count($items) = 0">
                            <span class="placeholder">– no model classes defined in <xsl:value-of select="$module/@ident"/> – </span>
                        </xsl:if>
                    </div>
                </div>
                <div class="contentListBox">
                    <h3>Macro Groups in <xsl:value-of select="$module/@ident"/></h3>
                    <div class="contents">
                        <xsl:variable name="items" select="$module.content//tei:macroSpec[@type = 'pe']" as="node()*"/>
                        <xsl:for-each select="$items">
                            <a class="{tools:getLinkClasses(@ident)}" href="#{@ident}" title="{normalize-space(string-join(child::tei:desc//text(),' '))}"><xsl:value-of select="@ident"/></a><xsl:if test="position() lt count($items)">, </xsl:if>        
                        </xsl:for-each>
                        <xsl:if test="count($items) = 0">
                            <span class="placeholder">– no macro groups defined in <xsl:value-of select="$module/@ident"/> – </span>
                        </xsl:if>
                    </div>
                </div>
                <div class="contentListBox">
                    <h3>Attribute Classes in <xsl:value-of select="$module/@ident"/></h3>
                    <div class="contents">
                        <xsl:variable name="items" select="$module.content//tei:classSpec[@type = 'atts']" as="node()*"/>
                        <xsl:for-each select="$items">
                            <a class="{tools:getLinkClasses(@ident)}" href="#{@ident}" title="{normalize-space(string-join(child::tei:desc//text(),' '))}"><xsl:value-of select="@ident"/></a><xsl:if test="position() lt count($items)">, </xsl:if>        
                        </xsl:for-each>
                        <xsl:if test="count($items) = 0">
                            <span class="placeholder">– no attribute classes defined in <xsl:value-of select="$module/@ident"/> – </span>
                        </xsl:if>
                    </div>
                </div>
                <div class="contentListBox">
                    <h3>Data Types in <xsl:value-of select="$module/@ident"/></h3>
                    <div class="contents">
                        <xsl:variable name="items" select="$module.content//tei:macroSpec[@type = 'dt']" as="node()*"/>
                        <xsl:for-each select="$items">
                            <a class="{tools:getLinkClasses(@ident)}" href="#{@ident}" title="{normalize-space(string-join(child::tei:desc//text(),' '))}"><xsl:value-of select="@ident"/></a><xsl:if test="position() lt count($items)">, </xsl:if>        
                        </xsl:for-each>
                        <xsl:if test="count($items) = 0">
                            <span class="placeholder">– no data types defined in <xsl:value-of select="$module/@ident"/> – </span>
                        </xsl:if>
                    </div>
                </div>
            </div>
        </section>
    </xsl:function>
    
</xsl:stylesheet>
