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
            <xd:p>This XSLT is part of odd2html.xsl. It holds basic functions, which are
                used to adjust input parameters like image paths.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Fixes image paths</xd:p>
        </xd:desc>
        <xd:param name="url">The url stored in the data</xd:param>
        <xd:return>The modified image url</xd:return>
    </xd:doc>
    <xsl:function name="tools:adjustImageUrl" as="xs:string">
        <xsl:param name="url" as="xs:string"/>
        
        <xsl:variable name="out" as="xs:string">
            <xsl:choose>
                <xsl:when test="starts-with($url,'../images')">
                    <xsl:value-of select="substring($url,4)"/>
                </xsl:when>
                <xsl:when test="starts-with($url, 'http://')">
                    <xsl:sequence select="$url"/>
                </xsl:when>
                <xsl:when test="starts-with($url, 'https://')">
                    <xsl:sequence select="$url"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$url"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$out"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Builds a flat list of chapter elements that can be used for building tocs etc. Recursively called on child chapters.</xd:p>
        </xd:desc>
        <xd:param name="node">The node whose children will be examined. Starts at the TEI body, looks for divs</xd:param>
        <xd:param name="level">The current level of nesting. Increased by one with every recursive call</xd:param>
        <xd:param name="parent.number">The number of parent chapters, to which the current index will be appended</xd:param>
        <xd:return>A list of chapter elements</xd:return>
    </xd:doc>
    <xsl:function name="tools:buildChapterList" as="node()*">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="level" as="xs:integer"/>
        <xsl:param name="parent.number" as="xs:string"/>
        
        <xsl:for-each select="$node/child::tei:div">
            <xsl:variable name="current.div" select="." as="node()"/>
            <xsl:variable name="index" select="position()" as="xs:integer"/>
            <chapter level="{$level}" xml:id="{$current.div/@xml:id}" number="{$parent.number || $index}" head="{normalize-space(string-join($current.div/tei:head/text(),' '))}">
                <xsl:sequence select="tools:buildChapterList($current.div, $level + 1, $parent.number || $index || '.')"/>    
            </chapter>            
        </xsl:for-each>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Generates the preface of the MEI Guidelines</xd:p>
        </xd:desc>
        <xd:return>A chapter element with the generated preface</xd:return>
    </xd:doc>
    <xsl:function name="tools:generatePreface" as="node()">        
        <section>
            <h1>Preface</h1>
            <strong>generated on <xsl:value-of select="$version"/></strong>
        </section>
    </xsl:function>
        
    <xd:doc>
        <xd:desc>
            <xd:p>Generates a table of contents</xd:p>
        </xd:desc>
        <xd:return>the table of contents markup</xd:return>
    </xd:doc>
    <xsl:function name="tools:generateToc" as="node()">
        <nav>
            <header>Table of Contents</header>
            <!-- TODO: Do we have front pages that need to be included? -->
            <ul class="toc toc_body">
                <xsl:for-each select="$all.chapters">
                    <xsl:sequence select="tools:generateTocChapterItem(.)"/>    
                </xsl:for-each>
            </ul>
            <ul class="toc toc_back">
                <li class="toc">
                    <span class="sectionHeading">MEI Specification</span>
                    <ul class="toc">
                        <!-- TODO: Shouldn't we include a section on the MEI modules, even though there is very little to display? -->
                        <li class="toc toc_2">
                            <a class="toc toc_2" href="#elementSpecs">Element Specifications</a>
                        </li>
                        <li class="toc toc_2">
                            <a class="toc toc_2" href="#modelClassSpecs">Model Class Specifications</a>
                        </li>
                        <li class="toc toc_2">
                            <a class="toc toc_2" href="#attClassSpecs">Attribute Class Specifications</a>
                        </li>
                        <li class="toc toc_2">
                            <a class="toc toc_2" href="#dataTypeSpecs">Data Type Specifications</a>
                        </li>
                        <li class="toc toc_2">
                            <a class="toc toc_2" href="#macroGroupSpecs">Macro Group Specifications</a>
                        </li>
                    </ul>
                </li>
                <li class="toc">
                    <span class="sectionHeading">Indizes</span>
                    <ul class="toc">
                        <li class="toc toc_2">
                            <a class="toc toc_2" href="#elementIndex">Index of Elements</a>
                        </li>
                        <li class="toc toc_2">
                            <a class="toc toc_2" href="#modelClassIndex">Index of Model Classes</a>
                        </li>
                        <li class="toc toc_2">
                            <a class="toc toc_2" href="#attClassIndex">Index of Attribute Classes</a>
                        </li>
                        <li class="toc toc_2">
                            <a class="toc toc_2" href="#dataTypeIndex">Index of Data Types</a>
                        </li>
                        <li class="toc toc_2">
                            <a class="toc toc_2" href="#macroGroupIndex">Index of Macro Groups</a>
                        </li>
                    </ul>
                </li>
            </ul>
        </nav>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Generates a TOC entry for a given chapter, and recursively for all its children</xd:p>
        </xd:desc>
        <xd:param name="chapter">The chapter that needs to be included in the toc</xd:param>
        <xd:return>the proper HTML output for the TOC</xd:return>
    </xd:doc>
    <xsl:function name="tools:generateTocChapterItem" as="node()">
        <xsl:param name="chapter" as="node()"/>
        
        <li class="toc">
            <span class="headingNumber"><xsl:value-of select="$chapter/@number"/>. </span>
            <a class="toc toc_{$chapter/@level}" href="#{$chapter/@xml:id}" title="{$chapter/@head}"><xsl:value-of select="$chapter/@head"/></a>
            <xsl:if test="$chapter/child::chapter">
                <ul class="toc">
                    <xsl:for-each select="$chapter/child::chapter">
                        <xsl:sequence select="tools:generateTocChapterItem(.)"/>    
                    </xsl:for-each>
                </ul>
            </xsl:if>
        </li>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Creates consistent css classes for links into the specs</xd:p>
        </xd:desc>
        <xd:param name="target">The ID of the things that need to be linked</xd:param>
        <xd:return>The classes string</xd:return>
    </xd:doc>
    <xsl:function name="tools:getLinkClasses" as="xs:string">
        <xsl:param name="target" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="starts-with($target,'att.') and $target = $att.classes/@ident">
                <xsl:value-of select="'link_odd link_odd_attClass'"/>
            </xsl:when>
            <xsl:when test="starts-with($target,'model.') and $target = $model.classes/@ident">
                <xsl:value-of select="'link_odd link_odd_modelClass'"/>
            </xsl:when>
            <xsl:when test="starts-with($target,'data.') and $target = $data.types/@ident">
                <xsl:value-of select="'link_odd link_odd_dataType'"/>
            </xsl:when>
            <xsl:when test="starts-with($target,'macro.') and $target = $macro.groups/@ident">
                <xsl:value-of select="'link_odd link_odd_macroGroup'"/>
            </xsl:when>
            <xsl:when test="$target = $elements/@ident">
                <xsl:value-of select="'link_odd link_odd_elementSpec'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'ERROR: Unable to resolve link to ' || $target"/>
                <xsl:value-of select="'link_odd broken'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Creates links to chapters that reference a given object</xd:p>
        </xd:desc>
        <xd:param name="ident">the identifier of the sought object</xd:param>
        <xd:param name="type">the type of the object</xd:param>
        <xd:return>an array of links, if any</xd:return>
    </xd:doc>
    <xsl:function name="tools:getReferencingChapters" as="node()*">
        <xsl:param name="ident" as="xs:string"/>
        <xsl:param name="type" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="$type = 'element'">
                <xsl:for-each select="$all.chapters/descendant-or-self::chapter[@xml:id = $chapters//tei:gi[text() = $ident]/ancestor::tei:div[1]/@xml:id or @xml:id = $chapters//tei:specDesc[@key = $ident]/ancestor::tei:div[1]/@xml:id]">
                    <xsl:variable name="chapter" select="." as="node()"/>
                    <xsl:variable name="hasSpecDesc" select="exists($chapter//tei:specDesc[@key = $ident])" as="xs:boolean"/>
                    <xsl:variable name="class" select="'chapterLink' || (if($hasSpecDesc) then(' desc') else(''))" as="xs:string"/>
                    <a class="{$class}" href="#{$chapter/@xml:id}" title="{$chapter/@number || ' ' || $chapter/@head}"><xsl:value-of select="$chapter/@number || ' ' || $chapter/@head"/></a>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$type = 'attClass'">
                <xsl:for-each select="$all.chapters/descendant-or-self::chapter[@xml:id = $chapters//tei:ident[text() = $ident]/ancestor::tei:div[1]/@xml:id or @xml:id = $chapters//tei:specDesc[@key = $ident]/ancestor::tei:div[1]/@xml:id]">
                    <xsl:variable name="chapter" select="." as="node()"/>
                    <xsl:variable name="hasSpecDesc" select="exists($chapter//tei:specDesc[@key = $ident])" as="xs:boolean"/>
                    <xsl:variable name="class" select="'chapterLink' || (if($hasSpecDesc) then(' desc') else(''))" as="xs:string"/>
                    <a class="{$class}" href="#{$chapter/@xml:id}" title="{$chapter/@number || ' ' || $chapter/@head}"><xsl:value-of select="$chapter/@number || ' ' || $chapter/@head"/></a>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$type = 'modelClass'">
                <xsl:for-each select="$all.chapters/descendant-or-self::chapter[@xml:id = $chapters//tei:ident[text() = $ident]/ancestor::tei:div[1]/@xml:id or @xml:id = $chapters//tei:specDesc[@key = $ident]/ancestor::tei:div[1]/@xml:id]">
                    <xsl:variable name="chapter" select="." as="node()"/>
                    <xsl:variable name="hasSpecDesc" select="exists($chapter//tei:specDesc[@key = $ident])" as="xs:boolean"/>
                    <xsl:variable name="class" select="'chapterLink' || (if($hasSpecDesc) then(' desc') else(''))" as="xs:string"/>
                    <a class="{$class}" href="#{$chapter/@xml:id}" title="{$chapter/@number || ' ' || $chapter/@head}"><xsl:value-of select="$chapter/@number || ' ' || $chapter/@head"/></a>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$type = 'dataType'">
                <!-- dunno how to reference data types, so nothing given back here yet -->
            </xsl:when>
            <xsl:when test="$type = 'macroGroup'">
                <!-- dunno how to reference macro groups, so nothing given back here yet -->
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'ERROR: tools:retrieveMentions does not understand how to resolve $type=' || $type || ' yet. Please fix…'"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
</xsl:stylesheet>