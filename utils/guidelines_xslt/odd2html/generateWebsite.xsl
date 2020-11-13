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
            <xd:p>This XSLT is part of odd2html.xsl. It generates the various HTML files needed to
                serve the MEI Guidelines from a webserver.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This function is the main starting point for generating a website version of the guidelines.</xd:p>
            <xd:p>It will generate resulting documents inside $output.folder/web</xd:p>
        </xd:desc>
        <xd:param name="input">A single page version of the Guidelines (already HTML)</xd:param>
    </xd:doc>
    <xsl:template name="generateWebsite">
        <xsl:param name="input" as="node()+"/>
        
        <xsl:variable name="web.output" select="$output.folder || 'web/'" as="xs:string"/>
        
        <xsl:for-each select="$input//section[@class='div1']">
            <xsl:variable name="current.chapter" select="." as="node()"/>
            <xsl:variable name="id" select="$current.chapter/h1[1]/@id" as="xs:string"/>
            <xsl:variable name="html" as="node()">
                <xsl:apply-templates select="$current.chapter" mode="get.website"/>
            </xsl:variable>
            
            <xsl:variable name="path" select="$web.output || 'content/' || $id || '.html'" as="xs:string"/>
            <xsl:variable name="content" as="node()+">
                <xsl:call-template name="getSinglePage">
                    <xsl:with-param name="contents" select="$html" as="node()*"/>
                    <xsl:with-param name="media" select="'screen'"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:result-document href="{$path}">
                <xsl:sequence select="$content"/>
            </xsl:result-document>
        </xsl:for-each>
        
        <xsl:for-each select="$input//section[@class='specPage moduleSpec']">
            <xsl:variable name="current.page" select="." as="node()"/>
            <xsl:variable name="id" select="$current.page/h2[1]/@id" as="xs:string"/>
            <xsl:variable name="html" as="node()">
                <xsl:apply-templates select="$current.page" mode="get.website"/>
            </xsl:variable>
            
            <xsl:variable name="path" select="$web.output || 'modules/' || $id || '.html'" as="xs:string"/>
            <xsl:variable name="content" as="node()+">
                <xsl:call-template name="getSinglePage">
                    <xsl:with-param name="contents" select="$html" as="node()*"/>
                    <xsl:with-param name="media" select="'screen'"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:result-document href="{$path}">
                <xsl:sequence select="$content"/>
            </xsl:result-document>
        </xsl:for-each>
        
        <xsl:for-each select="$input//section[@class='specPage elementSpec']">
            <xsl:variable name="current.page" select="." as="node()"/>
            <xsl:variable name="id" select="$current.page/h2[1]/@id" as="xs:string"/>
            <xsl:variable name="html" as="node()">
                <xsl:apply-templates select="$current.page" mode="get.website"/>
            </xsl:variable>
            
            <xsl:variable name="path" select="$web.output || 'elements/' || $id || '.html'" as="xs:string"/>
            <xsl:variable name="content" as="node()+">
                <xsl:call-template name="getSinglePage">
                    <xsl:with-param name="contents" select="$html" as="node()*"/>
                    <xsl:with-param name="media" select="'screen'"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:result-document href="{$path}">
                <xsl:sequence select="$content"/>
            </xsl:result-document>
        </xsl:for-each>
        
        <xsl:for-each select="$input//section[@class='specPage modelClassSpec']">
            <xsl:variable name="current.page" select="." as="node()"/>
            <xsl:variable name="id" select="$current.page/h2[1]/@id" as="xs:string"/>
            <xsl:variable name="html" as="node()">
                <xsl:apply-templates select="$current.page" mode="get.website"/>
            </xsl:variable>
            
            <xsl:variable name="path" select="$web.output || 'model-classes/' || $id || '.html'" as="xs:string"/>
            <xsl:variable name="content" as="node()+">
                <xsl:call-template name="getSinglePage">
                    <xsl:with-param name="contents" select="$html" as="node()*"/>
                    <xsl:with-param name="media" select="'screen'"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:result-document href="{$path}">
                <xsl:sequence select="$content"/>
            </xsl:result-document>
        </xsl:for-each>
        
        <xsl:for-each select="$input//section[@class='specPage macroGroupSpec']">
            <xsl:variable name="current.page" select="." as="node()"/>
            <xsl:variable name="id" select="$current.page/h2[1]/@id" as="xs:string"/>
            <xsl:variable name="html" as="node()">
                <xsl:apply-templates select="$current.page" mode="get.website"/>
            </xsl:variable>
            
            <xsl:variable name="path" select="$web.output || 'macro-groups/' || $id || '.html'" as="xs:string"/>
            <xsl:variable name="content" as="node()+">
                <xsl:call-template name="getSinglePage">
                    <xsl:with-param name="contents" select="$html" as="node()*"/>
                    <xsl:with-param name="media" select="'screen'"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:result-document href="{$path}">
                <xsl:sequence select="$content"/>
            </xsl:result-document>
        </xsl:for-each>
        
        <xsl:for-each select="$input//section[@class='specPage attClassSpec']">
            <xsl:variable name="current.page" select="." as="node()"/>
            <xsl:variable name="id" select="$current.page/h2[1]/@id" as="xs:string"/>
            <xsl:variable name="html" as="node()">
                <xsl:apply-templates select="$current.page" mode="get.website"/>
            </xsl:variable>
            
            <xsl:variable name="path" select="$web.output || 'att-classes/' || $id || '.html'" as="xs:string"/>
            <xsl:variable name="content" as="node()+">
                <xsl:call-template name="getSinglePage">
                    <xsl:with-param name="contents" select="$html" as="node()*"/>
                    <xsl:with-param name="media" select="'screen'"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:result-document href="{$path}">
                <xsl:sequence select="$content"/>
            </xsl:result-document>
        </xsl:for-each>
        
        <xsl:for-each select="$input//section[@class='specPage dataTypeSpec']">
            <xsl:variable name="current.page" select="." as="node()"/>
            <xsl:variable name="id" select="$current.page/h2[1]/@id" as="xs:string"/>
            <xsl:variable name="html" as="node()">
                <xsl:apply-templates select="$current.page" mode="get.website"/>
            </xsl:variable>
            
            <xsl:variable name="path" select="$web.output || 'data-types/' || $id || '.html'" as="xs:string"/>
            <xsl:variable name="content" as="node()+">
                <xsl:call-template name="getSinglePage">
                    <xsl:with-param name="contents" select="$html" as="node()*"/>
                    <xsl:with-param name="media" select="'screen'"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:result-document href="{$path}">
                <xsl:sequence select="$content"/>
            </xsl:result-document>
        </xsl:for-each>
        
    </xsl:template>
    
    
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>Adjusts links when generating website output</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="a/@href" mode="get.website">
        <xsl:variable name="classes" select="tokenize(normalize-space(parent::a/@class),' ')" as="xs:string*"/>
        <xsl:variable name="target" as="xs:string">
            <xsl:choose>
                <xsl:when test="'link_odd_elementSpec' = $classes">
                    <xsl:value-of select="replace(.,'#','../elements/') || '.html'"/>
                </xsl:when>
                <xsl:when test="'link_odd_modelClass' = $classes">
                    <xsl:value-of select="replace(.,'#','../model-classes/') || '.html'"/>
                </xsl:when>
                <xsl:when test="'link_odd_macroGroup' = $classes">
                    <xsl:value-of select="replace(.,'#','../macro-groups/') || '.html'"/>
                </xsl:when>
                <xsl:when test="'link_odd_attClass' = $classes">
                    <xsl:value-of select="replace(.,'#','../attribute-classes/') || '.html'"/>
                </xsl:when>
                <xsl:when test="'link_odd_dataType' = $classes">
                    <xsl:value-of select="replace(.,'#','../data-types/') || '.html'"/>
                </xsl:when>     
                <xsl:when test="'chapterLink' = $classes">
                    <xsl:variable name="chapter.id" select="replace(.,'#','')" as="xs:string"/>
                    <!--<xsl:variable name="first.level.chapter" select="$mei.source//tei:div[@type='div1' and .//@xml.id = $chapter.id]/@xml:id" as="xs:string?"/>-->
                    <xsl:variable name="first.level.chapter" select="$mei.source//tei:div[@xml:id = $chapter.id]/ancestor-or-self::tei:div[@type = 'div1']/@xml:id" as="xs:string?"/>
                    <xsl:if test="not($first.level.chapter)">
                        <xsl:message select="'Unable to retrieve link to _' || . || '_ inside ' || exists($mei.source)"/>
                    </xsl:if>
                    <xsl:variable name="subchapter" select="if($chapter.id = $first.level.chapter) then('') else('#' || $chapter.id)" as="xs:string"/>
                    <xsl:value-of select="'../content/' || $first.level.chapter || '.html' || $subchapter"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>    
        </xsl:variable>
        <xsl:attribute name="href" select="$target"/>
    </xsl:template>
    
</xsl:stylesheet>