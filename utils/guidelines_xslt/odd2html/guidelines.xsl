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
            <xd:p><xd:b>Created on:</xd:b> Nov 12, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This file holds most templates used to extract a HTML version of the MEI Guidelines</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Chapters</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:div" mode="guidelines">
        <xsl:variable name="chapter" select="." as="node()"/>
        
        <xsl:element name="{if(@type = 'div1') then('section') else('div')}">
            <xsl:attribute name="class" select="@type"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:element>
    </xsl:template>
        
    <xd:doc>
        <xd:desc>
            <xd:p>Chapter headings</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:head[parent::tei:div]" mode="guidelines">
        <xsl:variable name="div.id" select="parent::tei:div/@xml:id" as="xs:string"/>
        
        <xsl:variable name="tocInfo" select="$all.chapters/descendant-or-self::chapter[@xml:id = $div.id]" as="node()*"/>
        
        <xsl:if test="not($tocInfo)">
            <xsl:message terminate="yes" select="'ERROR: Unable to find chapter ' || $div.id || ' in $all.chapters'"/>
        </xsl:if>
        <xsl:if test="count($tocInfo) gt 1">
            <xsl:message terminate="yes" select="'ERROR: Too many chapters with ID ' || $div.id || ' in $all.chapters'"/>
        </xsl:if>
        <xsl:element name="h{$tocInfo/@level}">
            <xsl:attribute name="id" select="$div.id"/>
            <span class="headingNumber"><xsl:value-of select="$tocInfo/@number"/> </span>
            <span class="head"><xsl:value-of select="text()"/></span>
        </xsl:element>
    </xsl:template>
      
    <xd:doc>
        <xd:desc>
            <xd:p>Paragraphs</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:p" mode="guidelines">
        <p><xsl:apply-templates select="node()" mode="#current"/></p>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Lists</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:list" mode="guidelines">
        <xsl:choose>
            <xsl:when test="@type = ('bulleted','simple')">
                <xsl:if test="child::tei:head">
                    <strong class="listHead"><xsl:apply-templates select="child::tei:head/node()" mode="#current"/></strong>
                </xsl:if>
                <ul>
                    <xsl:for-each select="tei:item">
                        <li class="item">
                            <xsl:apply-templates select="node()" mode="#current"/>
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:when>
            <xsl:when test="@type = 'ordered'">
                <xsl:if test="child::tei:head">
                    <strong class="listHead"><xsl:apply-templates select="child::tei:head/node()"/></strong>
                </xsl:if>
                <ol>
                    <xsl:for-each select="tei:item">
                        <li class="item">
                            <xsl:apply-templates select="node()" mode="#current"/>
                        </li>
                    </xsl:for-each>
                </ol>
            </xsl:when>
            <xsl:when test="@type = 'gloss'">
                <dl>
                    <xsl:for-each select="tei:label">
                        <dt><span><xsl:apply-templates select="node()" mode="#current"/></span></dt>
                        <dd><xsl:apply-templates select="following-sibling::tei:item[1]/node()" mode="#current"/></dd>
                    </xsl:for-each>
                </dl>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="child::tei:head">
                    <strong class="listHead"><xsl:apply-templates select="child::tei:head/node()"/></strong>
                </xsl:if>
                <ul>
                    <xsl:for-each select="tei:item">
                        <li class="item">
                            <xsl:apply-templates select="node()" mode="#current"/>
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
        
    <xd:doc>
        <xd:desc>
            <xd:p>Element references</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:gi" mode="guidelines">
        <xsl:variable name="text" select="string(text())" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$text = $elements/@ident">
                <a class="link_odd_elementSpec" href="#{$text}"><xsl:value-of select="$text"/></a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes" select="'WARNING: Unable to retrieve definition of element ' || $text || '. No link created. Please check spelling…'"/>                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    
    
</xsl:stylesheet>