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
            <xd:p>Determines whether this is operating on a compiled ODD file.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="isCompiledOdd" select="not(//tei:moduleRef[not(@url = '../source/svg11.rng')])" as="xs:boolean">
        <!-- todo: relaxed test due to external svg module -->
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Determines whether this is operating on a customization or the full mei-source.xml file.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="isCustomization" select="not(ends-with(document-uri(/), '/source/mei-source.xml'))" as="xs:boolean"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The MEI sources as they are. If applied to a customization, this still refers to the main MEI sources.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="mei.source" as="node()">
        <xsl:choose>
            <xsl:when test="not($isCustomization)">
                <xsl:sequence select="/"/>
            </xsl:when>
            <xsl:when test="$isCompiledOdd">
                <xsl:sequence select="/"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="doc($basedir || '/source/mei-source.xml')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The MEI sources used to generate specs. For customizations, this is the compiled ODD.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="compiled.source" as="node()">
        <xsl:choose>
            <xsl:when test="not($isCustomization)">
                <xsl:sequence select="/"/>
            </xsl:when>
            <xsl:when test="$isCompiledOdd">
                <xsl:sequence select="/"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="not($isCompiledOdd)">
                    <xsl:message terminate="yes">ERROR:currently only compiled ODDs or canonicalized sources are processable, please create a respective version of your ODD first.</xsl:message>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>If operated on a customization, this holds a reference to the rules provided there.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="mei.customization" as="node()?">
        <xsl:if test="$isCustomization">
            <xsl:sequence select="/"/>
        </xsl:if>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The documentation chapters of the MEI sources</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="source.chapters" select="$mei.source//tei:body//tei:div[@type = 'div1']" as="node()*"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The main chapters of the MEI Guidelines relevant for this, be it source or customization</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="chapters" as="node()*">
        <xsl:choose>
            <xsl:when test="$isCustomization">
                <xsl:sequence select="$mei.customization//tei:div[@type='customizationDocs']//tei:div[@type = 'div1']"/>
                <xsl:sequence select="$mei.customization//tei:div[@type = 'sourceRefs']/tei:div[@type = 'div1']"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$source.chapters"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Custom Guidelines chapters for this Customization, if applicable</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="custom.chapters" select="$mei.customization//tei:div[@type='customizationDocs']//tei:div[@type = 'div1']" as="node()*"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>HTML links to all top level chapters</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="chapter.links" as="node()*">
        <xsl:for-each select="$chapters">
            <xsl:variable name="id" select="@xml:id" as="xs:string"/>
            <xsl:variable name="title" select="normalize-space(string-join(./tei:head[1]/text(),' '))" as="xs:string"/>
            <xsl:variable name="num" select="concat($source.chapters[@xml:id = $id]/position(),'.')" as="xs:string"/>
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
    <xsl:variable name="all.chapters" as="node()+">
        <xsl:choose>
            <xsl:when test="$isCustomization">
                <xsl:sequence select="tools:buildChapterList($mei.customization//tei:div[@type='customizationDocs'], 1, '', 'A')"/>
                <xsl:sequence select="tools:buildChapterList($mei.customization//tei:div[@type = 'sourceRefs'], 1, '', 'B')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="tools:buildChapterList($mei.source//tei:body, 1, '', '')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>A list of all relevant modules in the processed ODD</xd:p>
        </xd:desc><?TODO all in all of MEI (source) or all in processed file? ?>
    </xd:doc>
    <xsl:variable name="modules" as="node()*">
        <xsl:choose>
            <xsl:when test="$isCompiledOdd">
                <xsl:for-each select="$mei.source//tei:moduleSpec">
                    <xsl:sort select="@ident" data-type="text"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$isCustomization">
                <xsl:for-each select="$mei.source//tei:moduleSpec[@ident = $mei.customization//tei:moduleRef/@key]">
                    <xsl:sort select="@ident" data-type="text"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$mei.source//tei:moduleSpec">
                    <xsl:sort select="@ident" data-type="text"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>A list of all elements relevant for the processed file.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="elements" as="node()*">
        <xsl:choose>
            <xsl:when test="$isCompiledOdd">
                <xsl:for-each select="//tei:elementSpec"><?NB could also use $mei.source?>
                    <xsl:sort select="@ident" data-type="text"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$isCustomization">
                <xsl:for-each select="$compiled.source//tei:elementSpec">
                    <xsl:sort select="@ident" data-type="text"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$mei.source//tei:elementSpec">
                    <xsl:sort select="@ident" data-type="text"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
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
            <xd:p>A list of links to all elements for PDF purposes</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="elements.pdf.links" as="node()*">
        <xsl:for-each select="$elements">
            <xsl:sort select="@ident" data-type="text"/>
            <xsl:variable name="name" select="@ident"/>
            <a class="{tools:getLinkClasses($name)} {substring($name,1,1)}" href="#{$name}"><xsl:value-of select="$name"/></a>
        </xsl:for-each>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>A list of all attribute classes in MEI</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="att.classes" as="node()*">
        <xsl:choose>
            <xsl:when test="$isCompiledOdd">
                <xsl:for-each select="$mei.source//tei:classSpec[@type = 'atts']">
                    <xsl:sort select="@ident" data-type="text"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$isCustomization">
                <xsl:for-each select="$compiled.source//tei:classSpec[@type = 'atts']">
                    <xsl:sort select="@ident" data-type="text"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$mei.source//tei:classSpec[@type = 'atts']">
                    <xsl:sort select="@ident" data-type="text"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
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
            <xd:p>A list of links to all attribute classes for PDF purposes</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="att.classes.pdf.links" as="node()*">
        <xsl:for-each select="$att.classes">
            <xsl:sort select="@ident" data-type="text"/>
            <xsl:variable name="name" select="@ident"/>
            <a class="{tools:getLinkClasses($name)} {substring($name,5,1)}" href="#{$name}"><xsl:value-of select="$name"/></a>
        </xsl:for-each>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>A list of all model classes in MEI</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="model.classes" as="node()*">
        <xsl:choose>
            <xsl:when test="$isCompiledOdd">
                <xsl:for-each select="$mei.source//tei:classSpec[@type = 'model']">
                    <xsl:sort select="@ident" data-type="text"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$isCustomization">
                <xsl:for-each select="$compiled.source//tei:classSpec[@type = 'model']">
                    <xsl:sort select="@ident" data-type="text"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$mei.source//tei:classSpec[@type = 'model']">
                    <xsl:sort select="@ident" data-type="text"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
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
            <xd:p>A list of links to all model classes for PDF purposes</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="model.classes.pdf.links" as="node()*">
        <xsl:for-each select="$model.classes">
            <xsl:sort select="@ident" data-type="text"/>
            <xsl:variable name="name" select="@ident"/>
            <a class="{tools:getLinkClasses($name)} {substring($name,7,1)}" href="#{$name}"><xsl:value-of select="$name"/></a>
        </xsl:for-each>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>A list of all data types in MEI</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="data.types" as="node()*">
        <xsl:choose>
            <xsl:when test="$isCompiledOdd">
                <xsl:for-each select="$mei.source//tei:macroSpec[@type = 'dt']">
                    <xsl:sort select="@ident" data-type="text"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$isCustomization">
                <xsl:for-each select="$compiled.source//tei:macroSpec[@type = 'dt']">
                    <xsl:sort select="@ident" data-type="text"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$mei.source//tei:macroSpec[@type = 'dt']">
                    <xsl:sort select="@ident" data-type="text"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
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
            <xd:p>A list of links to all data types for PDF purposes</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="data.types.pdf.links" as="node()*">
        <xsl:for-each select="$data.types">
            <xsl:variable name="name" select="@ident"/>
            <a class="{tools:getLinkClasses($name)} {substring($name,6,1)}" href="#{$name}"><xsl:value-of select="$name"/></a>
        </xsl:for-each>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>A list of all macro groups in MEI</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="macro.groups" as="node()*">
        <xsl:choose>
            <xsl:when test="$isCompiledOdd">
                <xsl:for-each select="$mei.source//tei:macroSpec[@type = 'pe']">
                    <xsl:sort select="@ident" data-type="text"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$isCustomization">
                <xsl:for-each select="$compiled.source//tei:macroSpec[@type = 'pe']">
                    <xsl:sort select="@ident" data-type="text"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:for-each select="$mei.source//tei:macroSpec[@type = 'pe']">
                    <xsl:sort select="@ident" data-type="text"/>
                    <xsl:sequence select="."/>
                </xsl:for-each>
            </xsl:otherwise>
        </xsl:choose>
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
    
    <xd:doc>
        <xd:desc>
            <xd:p>A list of links to all macro group for PDF purposess</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="macro.groups.pdf.links" as="node()*">
        <xsl:for-each select="$data.types">
            <xsl:variable name="name" select="@ident"/>
            <a class="{tools:getLinkClasses($name)} {substring($name,7,1)}" href="#{$name}"><xsl:value-of select="$name"/></a>
        </xsl:for-each>
    </xsl:variable>
    
    
    
    
</xsl:stylesheet>