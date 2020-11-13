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
            <xd:p><xd:b>Created on:</xd:b> Nov 21, 2018</xd:p>
            <xd:p><xd:b>Modified on:</xd:b> Nov 11, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:include href="./functions.xsl"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The MEI sources as they are</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="mei.source" select="/" as="node()"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The main chapters of the MEI Guidelines</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="chapters" select="//tei:body//tei:div[@type = 'div1']" as="node()*"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>HTML links to all top level chapters</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="chapter.links" as="node()*">
        <xsl:for-each select="$chapters">
            <xsl:variable name="id" select="@xml:id" as="xs:string"/>
            <xsl:variable name="title" select="normalize-space(string-join(./tei:head[1]/text(),' '))" as="xs:string"/>
            <xsl:variable name="num" select="concat(position(),'.')" as="xs:string"/>
            <a class="module" href="/documentation/{$version}/{$id}">
                <span class="no"><xsl:value-of select="$num"/></span>
                <span class="title"><xsl:value-of select="$title"/></span></a>
        </xsl:for-each>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>A flat list of chapter elements, each with a @level, @xml:id, @number and @head</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="all.chapters" select="tools:buildChapterList($mei.source//tei:body, 1, '')"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>A list of all elements in MEI</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="elements" as="node()*">
        <xsl:for-each select="$mei.source//tei:elementSpec">
            <xsl:sort select="@ident" data-type="text"/>
            <xsl:sequence select="."/>
        </xsl:for-each>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>A list of links to all elements</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="elements.links" as="node()*">
        <xsl:for-each select="$elements">
            <xsl:sort select="@ident" data-type="text"/>
            <xsl:variable name="name" select="@ident"/>
            <a class="{tools:getLinkClasses($name)} {substring($name,1,1)}" href="/documentation/{$version}/{$name}"><xsl:value-of select="$name"/></a>
        </xsl:for-each>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>A list of all attribute classes in MEI</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="att.classes" as="node()*">
        <xsl:for-each select="$mei.source//tei:classSpec[@type = 'atts']">
            <xsl:sort select="@ident" data-type="text"/>
            <xsl:sequence select="."/>
        </xsl:for-each>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>A list of links to all attribute classes</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="att.classes.links" as="node()*">
        <xsl:for-each select="$att.classes">
            <xsl:sort select="@ident" data-type="text"/>
            <xsl:variable name="name" select="@ident"/>
            <a class="{tools:getLinkClasses($name)} {substring($name,5,1)}" href="/documentation/{$version}/{$name}"><xsl:value-of select="$name"/></a>
        </xsl:for-each>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>A list of all model classes in MEI</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="model.classes" as="node()*">
        <xsl:for-each select="$mei.source//tei:classSpec[@type = 'model']">
            <xsl:sort select="@ident" data-type="text"/>
            <xsl:sequence select="."/>
        </xsl:for-each>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>A list of links to all model classes</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="model.classes.links" as="node()*">
        <xsl:for-each select="$model.classes">
            <xsl:sort select="@ident" data-type="text"/>
            <xsl:variable name="name" select="@ident"/>
            <a class="{tools:getLinkClasses($name)} {substring($name,7,1)}" href="/documentation/{$version}/{$name}"><xsl:value-of select="$name"/></a>
        </xsl:for-each>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>A list of all data types in MEI</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="data.types" as="node()*">
        <xsl:for-each select="$mei.source//tei:macroSpec[@type = 'dt']">
            <xsl:sort select="@ident" data-type="text"/>
            <xsl:sequence select="."/>
        </xsl:for-each>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>A list of links to all data types</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="data.types.links" as="node()*">
        <xsl:for-each select="$data.types">
            <xsl:variable name="name" select="@ident"/>
            <a class="{tools:getLinkClasses($name)} {substring($name,6,1)}" href="/documentation/{$version}/{$name}"><xsl:value-of select="$name"/></a>
        </xsl:for-each>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>A list of all macro groups in MEI</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="macro.groups" as="node()*">
        <xsl:for-each select="$mei.source//tei:macroSpec[@type = 'pe']">
            <xsl:sort select="@ident" data-type="text"/>
            <xsl:sequence select="."/>
        </xsl:for-each>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>A list of links to all macro groups</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="macro.groups.links" as="node()*">
        <xsl:for-each select="$data.types">
            <xsl:variable name="name" select="@ident"/>
            <a class="{tools:getLinkClasses($name)} {substring($name,7,1)}" href="/documentation/{$version}/{$name}"><xsl:value-of select="$name"/></a>
        </xsl:for-each>
    </xsl:variable>
    
    
    
    
</xsl:stylesheet>