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
            <xd:p>This stylesheet is used to render XML into HTML</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Wraps plain text examples with a temporary root node, and then treats everyhing as XML</xd:p>
        </xd:desc>
        <xd:param name="input">The string that is supposed to be parsed as XML</xd:param>
        <xd:return>The resulting XML nodes</xd:return>
    </xd:doc>
    <xsl:function name="tools:xml2html" as="node()*">
        <xsl:param name="input" as="xs:string"/>
        
        <xsl:variable name="wrapped" select="'&lt;WRAPPER&gt;' || $input || '&lt;/WRAPPER&gt;'" as="xs:string"/>
        <xsl:variable name="output">
            <xsl:try>
                <xsl:variable name="xml" select="parse-xml($wrapped)/WRAPPER/child::node()" as="node()*"/>
                
                <xsl:apply-templates select="$xml" mode="preserveSpace"/>        
                <xsl:catch>
                    <xsl:message select="'ERROR: Unable to parse the following XML snippet, which is apparently not well-formed:'"/>
                    <xsl:message select="$input"/>
                    <xsl:sequence select="$input"/>
                </xsl:catch>
            </xsl:try>    
        </xsl:variable>
        <xsl:sequence select="$output"/>
    </xsl:function>
    
    <!-- in order to preserve spacing, it is important that the following template is kept on one line -->
    <xd:doc>
        <xd:desc>
            <xd:p>Deals with elements in XML examples</xd:p>
        </xd:desc>
        <xd:param name="indent">The level of indentation</xd:param>
    </xd:doc>
    <xsl:template match="element()" mode="preserveSpace" priority="1">
        <xsl:param name="indent" as="xs:integer?"/>
        <xsl:variable name="indent.level" select="if($indent) then($indent) else(1)" as="xs:integer"/>
        <xsl:variable name="element" select="." as="node()"/>
        
        <xsl:variable name="indent.threshold" select="30" as="xs:integer"/>
        
        <xsl:choose>
            <xsl:when test="local-name() = 'param' and @name = 'pattern' and string-length(text()) gt $indent.threshold * 1">
                <div class="indent{$indent.level}"><span data-indentation="{$indent.level}" class="element">&lt;<xsl:value-of select="name($element)"/><xsl:apply-templates select="$element/@*" mode="#current"/>&gt;</span>
                    <xsl:choose>
                        <xsl:when test="string-length(text()) gt $indent.threshold * 8">
                            <div class="indent{$indent.level + 1}"><xsl:value-of select="substring(text(),$indent.threshold * 0 + 1,$indent.threshold * 2)"/></div>
                            <div class="indent{$indent.level + 2}"><xsl:value-of select="substring(text(),$indent.threshold * 2 + 1,$indent.threshold * 2)"/></div>
                            <div class="indent{$indent.level + 2}"><xsl:value-of select="substring(text(),$indent.threshold * 4 + 1,$indent.threshold * 2)"/></div>
                            <div class="indent{$indent.level + 2}"><xsl:value-of select="substring(text(),$indent.threshold * 6 + 1,$indent.threshold * 2)"/></div>
                            <div class="indent{$indent.level + 2}"><xsl:value-of select="substring(text(),$indent.threshold * 8 + 1,$indent.threshold * 2)"/></div>
                        </xsl:when>
                        <xsl:when test="string-length(text()) gt $indent.threshold * 6">
                            <div class="indent{$indent.level + 1}"><xsl:value-of select="substring(text(),$indent.threshold * 0 + 1,$indent.threshold * 2)"/></div>
                            <div class="indent{$indent.level + 2}"><xsl:value-of select="substring(text(),$indent.threshold * 2 + 1,$indent.threshold * 2)"/></div>
                            <div class="indent{$indent.level + 2}"><xsl:value-of select="substring(text(),$indent.threshold * 4 + 1,$indent.threshold * 2)"/></div>
                            <div class="indent{$indent.level + 2}"><xsl:value-of select="substring(text(),$indent.threshold * 6 + 1,$indent.threshold * 2)"/></div>
                        </xsl:when>
                        <xsl:when test="string-length(text()) gt $indent.threshold * 4">
                            <div class="indent{$indent.level + 1}"><xsl:value-of select="substring(text(),$indent.threshold * 0 + 1,$indent.threshold * 2)"/></div>
                            <div class="indent{$indent.level + 2}"><xsl:value-of select="substring(text(),$indent.threshold * 2 + 1,$indent.threshold * 2)"/></div>
                            <div class="indent{$indent.level + 2}"><xsl:value-of select="substring(text(),$indent.threshold * 4 + 1,$indent.threshold * 2)"/></div>
                        </xsl:when>
                        <xsl:when test="string-length(text()) gt $indent.threshold * 2">
                            <div class="indent{$indent.level + 1}"><xsl:value-of select="substring(text(),$indent.threshold * 0 + 1,$indent.threshold * 2)"/></div>
                            <div class="indent{$indent.level + 2}"><xsl:value-of select="substring(text(),$indent.threshold * 2 + 1,$indent.threshold * 2)"/></div>
                        </xsl:when>
                        <xsl:when test="string-length(text()) gt $indent.threshold * 1">
                            <div class="indent{$indent.level + 1}"><xsl:value-of select="substring(text(),1,100)"/></div>        
                        </xsl:when>
                    </xsl:choose>
                    <span data-indentation="{$indent.level}" class="element">&lt;/<xsl:value-of select="name($element)"/>&gt;</span></div>
            </xsl:when>
            <xsl:otherwise>
                <div class="indent{$indent.level}"><span data-indentation="{$indent.level}" class="element">&lt;<xsl:value-of select="name($element)"/><xsl:apply-templates select="$element/@*" mode="#current"/><xsl:if test="not($element/node())">/</xsl:if>&gt;</span><xsl:apply-templates select="$element/node()" mode="#current"><xsl:with-param name="indent" select="$indent.level + 1" as="xs:integer"/></xsl:apply-templates><xsl:if test="$element/node()"><span data-indentation="{$indent.level}" class="element">&lt;/<xsl:value-of select="name($element)"/>&gt;</span></xsl:if></div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Deals with comments in XML examples</xd:p>
        </xd:desc>
        <xd:param name="indent">The level of indentation</xd:param>
    </xd:doc>
    <xsl:template match="comment()" mode="preserveSpace" priority="1">
        <xsl:param name="indent" as="xs:integer?"/>
        <xsl:variable name="indent.level" select="if($indent) then($indent) else(1)" as="xs:integer"/>
        <xsl:variable name="element" select="." as="node()"/>
        <div class="indent{$indent.level}"><span data-indentation="{$indent.level}" class="comment">&lt;!--<xsl:value-of select="."/>--&gt;</span></div>   
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Don't display Processing instructions in examples</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="processing-instruction()" mode="preserveSpace" priority="1"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Deals with attributes in XML examples</xd:p>
            <xd:p>In order to preserve spacing, it is important that the following template is kept on one line.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@*" mode="preserveSpace" priority="1"><xsl:value-of select="' '"/><span class="attribute"><xsl:value-of select="name()"/>=</span><span class="attributevalue">"<xsl:value-of select="string(.)"/>"</span></xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Translates memberOf relationships into operable links</xd:p>
            <xd:p>In order to preserve spacing, it is important that the following template is kept on one line.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:memberOf/@key" mode="preserveSpace" priority="2"><xsl:value-of select="' '"/><span class="attribute"><xsl:value-of select="local-name()"/>=</span><span class="attributevalue">"<a class="{tools:getLinkClasses(.)}" href="#{string(.)}"><xsl:value-of select="string(.)"/></a>"</span></xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Translates macroRef relationships into operable links</xd:p>
            <xd:p>In order to preserve spacing, it is important that the following template is kept on one line.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:macroRef/@key" mode="preserveSpace" priority="2"><xsl:value-of select="' '"/><span class="attribute"><xsl:value-of select="local-name()"/>=</span><span class="attributevalue">"<a class="{tools:getLinkClasses(.)}" href="#{string(.)}"><xsl:value-of select="string(.)"/></a>"</span></xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Translates rng:ref relationships into operable links</xd:p>
            <xd:p>In order to preserve spacing, it is important that the following template is kept on one line.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="rng:ref/@name" mode="preserveSpace" priority="2"><xsl:value-of select="' '"/><span class="attribute"><xsl:value-of select="local-name()"/>=</span><span class="attributevalue">"<a class="{tools:getLinkClasses(.)}" href="#{string(.)}"><xsl:value-of select="string(.)"/></a>"</span></xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Kicks out @mode on anything except egXML</xd:p>
        </xd:desc>
        <xd:param name="getODD"></xd:param>
    </xd:doc>
    <xsl:template match="@mode[not(ancestor::egx:egXML)]" mode="preserveSpace" priority="2">
        <xsl:param name="getODD" tunnel="yes" as="xs:boolean?"/>
        <!--<xsl:if test="not($getODD) or $getODD = false()">
            <xsl:next-match/>
        </xsl:if>-->
    </xsl:template>
        
    <xd:doc>
        <xd:desc>
            <xd:p>Kicks out some unwanted attributes</xd:p>
        </xd:desc>
        <xd:param name="getODD"></xd:param>
    </xd:doc>
    <xsl:template match="tei:elementSpec//@ns | tei:elementSpec//@predeclare | tei:elementSpec//@status | tei:elementSpec//@autoPrefix" mode="preserveSpace" priority="2">
        <xsl:param name="getODD" tunnel="yes" as="xs:boolean?"/>
        <!--<xsl:if test="not($getODD) or $getODD = false()">
            <xsl:next-match/>
        </xsl:if>-->
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Kicks out some unwanted attributes</xd:p>
        </xd:desc>
        <xd:param name="getODD"></xd:param>
    </xd:doc>
    <xsl:template match="tei:classSpec//@ns | tei:classSpec//@predeclare | tei:classSpec//@status | tei:classSpec//@autoPrefix" mode="preserveSpace" priority="2">
        <xsl:param name="getODD" tunnel="yes" as="xs:boolean?"/>
        <!--<xsl:if test="not($getODD) or $getODD = false()">
            <xsl:next-match/>
        </xsl:if>-->
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Kicks out some unwanted attributes</xd:p>
        </xd:desc>
        <xd:param name="getODD"></xd:param>
    </xd:doc>
    <xsl:template match="tei:macroSpec//@ns | tei:macroSpec//@predeclare | tei:macroSpec//@status | tei:macroSpec//@autoPrefix" mode="preserveSpace" priority="2">
        <xsl:param name="getODD" tunnel="yes" as="xs:boolean?"/>
        <!--<xsl:if test="not($getODD) or $getODD = false()">
            <xsl:next-match/>
        </xsl:if>-->
    </xsl:template>
</xsl:stylesheet>