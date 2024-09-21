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
                
                <xsl:choose>
                    <xsl:when test="$classType = 'Available at'">
                        <div class="classItem">
                            <label><a class="link_odd link_odd_elementSpec" href="#{$current.item/@ident}">&lt;<xsl:value-of select="$current.item/@ident"/>&gt;</a></label>
                            <div class="desc"><xsl:apply-templates select="$current.item/desc/node()" mode="#current"/></div>
                            <div class="breadcrumb">
                                <span class="step start"><xsl:value-of select="$start"/></span>
                                <xsl:for-each select="$current.item/ancestor::group/link[position() gt 1]">
                                    <span class="step"><xsl:apply-templates select="node()" mode="#current"/></span>
                                </xsl:for-each>
                                <span class="step end"><xsl:value-of select="$end"/></span>
                            </div>
                        </div>
                    </xsl:when>
                    <xsl:when test="$classType = 'Used by'">
                        <xsl:choose>
                            <xsl:when test="$current.item/@class='element' and $elements/self::tei:elementSpec[@ident = $current.item/@ident]">
                                <xsl:for-each select="$current.item//item[@class='attribute']">
                                    <xsl:variable name="att.item" select="." as="node()"/>
                                    <div class="classItem">
                                        <label>
                                            <a class="link_odd link_odd_elementSpec" href="#{$current.item/@ident}">&lt;<xsl:value-of select="$current.item/@ident"/>&gt;</a> / 
                                            <span class="ident attribute">@<xsl:value-of select="$att.item/link/text()"/></span> 
                                        </label>
                                        <div class="desc"><xsl:apply-templates select="$att.item/desc/node()" mode="#current"/></div>
                                    </div>
                                </xsl:for-each>                                    
                            </xsl:when>
                            <xsl:when test="$att.classes/self::tei:classSpec[@ident = $current.item/@ident]">
                                <div class="classItem">
                                    <label>
                                        <xsl:apply-templates select="$current.item/link/node()" mode="#current"/>
                                    </label>
                                    <div class="desc"><xsl:apply-templates select="$current.item/desc/node()" mode="#current"/></div>
                                </div>
                            </xsl:when>
                            <xsl:when test="$data.types/self::tei:macroSpec[@ident = $current.item/@ident]">
                                <div class="classItem">
                                    <label>
                                        <a class="link_odd link_odd_dataType" href="#{$current.item/@ident}"><xsl:value-of select="$current.item/@ident"/></a>
                                    </label>
                                    <div class="desc"><xsl:apply-templates select="$current.item/desc/node()" mode="#current"/></div>
                                </div>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$classType = ('Contained By', 'May Contain', 'Members', 'Attributes')">
                        <xsl:variable name="dist" as="xs:integer">
                            <!-- on elements, all intermediary steps need to be rendered, on other things the first can be skipped -->
                            <xsl:choose>
                                <xsl:when test="ancestor::section[@id = 'elementSpecs']"><xsl:value-of select="0"/></xsl:when>
                                <xsl:otherwise><xsl:value-of select="1"/></xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="mod.end" as="xs:string">
                            <xsl:choose>
                                <xsl:when test="$classType = 'Attributes' and not(starts-with($end, '@'))">
                                    <xsl:value-of select="'@' || substring($end,2,string-length($end) - 2)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$end"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <div class="classItem">
                            <label><xsl:apply-templates select="$current.item/link/node()" mode="#current"/></label>
                            <div class="desc"><xsl:apply-templates select="$current.item/desc/node()" mode="#current"/></div>
                            <div class="breadcrumb">
                                <span class="step start"><xsl:value-of select="$start"/></span>
                                <xsl:for-each select="$current.item/ancestor::group/link[position() gt $dist]">
                                    <span class="step"><xsl:apply-templates select="node()" mode="#current"/></span>
                                </xsl:for-each>
                                <span class="step end"><xsl:value-of select="$mod.end"/></span>
                            </div>
                        </div>        
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="classItem">
                            <label><xsl:value-of select="$current.item/link/node()"/></label>
                            <div class="desc"><xsl:apply-templates select="$current.item/desc/node()" mode="#current"/></div>
                            <div class="breadcrumb">
                                <span class="step start"><xsl:value-of select="$start"/></span>
                                <xsl:for-each select="$current.item/ancestor::group/link[position() gt 1]">
                                    <span class="step"><xsl:apply-templates select="node()" mode="#current"/></span>
                                </xsl:for-each>
                                <span class="step end"><xsl:value-of select="$end"/></span>
                            </div>
                        </div>        
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:for-each>            
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This template ensures a space character between heading number and heading in the PDF table of contents</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="span[@class='headingNumber']" mode="preparePDF">
        <xsl:choose>
            <xsl:when test="parent::h1 or parent::h2 or parent::h3 or parent::h4 or parent::h5 or parent::h6">
                <xsl:copy>
                    <xsl:apply-templates select="node() | @*" mode="#current"/><xsl:value-of select="' '"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:next-match/>
            </xsl:otherwise>
        </xsl:choose>        
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
    
    <xsl:template match="img/@src" mode="preparePDF">
        <xsl:choose>
            <xsl:when test="starts-with(.,'http://')">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="starts-with(.,'https://')">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="starts-with(.,'./assets/images/') and not(contains(.,'GeneratedImages/'))">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="starts-with(.,'./assets/images/GeneratedImages/')">
                <xsl:next-match/>
            </xsl:when>
            <xsl:when test="starts-with(.,'images/') and not(contains(.,'GeneratedImages/'))">
                <xsl:attribute name="src" select="$assets.folder.rel || ."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes" select="'dunno how to resolve image src=' || ."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>