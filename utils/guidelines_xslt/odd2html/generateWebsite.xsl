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
            <xd:p>For tabbed facets, it's necessary to have IDs</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="div['facet' = tokenize(normalize-space(@class),' ')]" mode="get.website">
        <xsl:copy>
            <xsl:attribute name="id" select="substring-after(@class, 'facet ')"/>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Split up classes into multipe tabs</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="div['classes' = tokenize(normalize-space(@class),' ')]" mode="get.website">
        
        <xsl:variable name="facet.type" select="substring-after(parent::div/@class,'facet ')" as="xs:string"/>
        <!-- allowed values:
            attributes   -> used on elements, att.classes                   -> compact, full definition, by class, by module
            containedBy  -> used on elements, model.classes, macro.groups   -> compact, by class, by module
            mayContain   -> used on elements, macro.groups                  -> compact, by class, by module
            members      -> used on model.classes                           -> compact, by module
            availableAt  -> used on att.classes                             -> compact, by class, by module
            usedBy       -> used on data.types                              -> keine tabs, aber untergliedert in Element und Attribute 
        -->
        
        <xsl:variable name="compact" as="node()?">
            <xsl:if test="$facet.type = ('attributes','containedBy','mayContain','members','availableAt')">
                <xsl:sequence select="tools:getCompactTab(., $facet.type)"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="full" as="node()?">
            <xsl:if test="$facet.type = ('attributes')">
                <xsl:sequence select="tools:getFullDefinitionTab(., $facet.type)"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="by.class" as="node()?">
            <xsl:if test="$facet.type = ('attributes','containedBy','mayContain','availableAt')">
                <xsl:sequence select="tools:getByClassTab(., $facet.type)"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="by.module" as="node()?">
            <xsl:if test="$facet.type = ('attributes','containedBy','mayContain','members','availableAt')">
                <xsl:sequence select="tools:getByModuleTab(., $facet.type)"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="tabs" select="$compact | $full | $by.class | $by.module" as="node()*"/>
        
        <xsl:copy>
            <xsl:apply-templates select="@*" mode="#current"/>
            <ul class="tab">
                <xsl:for-each select="$tabs">
                    <li class="tab-item">
                        <a data-display="{@id}" 
                            id="{@id}_tab"
                            href="#{@id}"
                            class="displayTab{if(position() = 1) then(' active') else()}"><xsl:value-of select="@data-label"/></a>
                    </li>
                </xsl:for-each>
            </ul>
            <xsl:for-each select="$tabs">
                <xsl:copy>
                    <xsl:sequence select="@*"/>
                    <xsl:if test="position() = 1">
                        <xsl:attribute name="class" select="@class || ' active'"/>
                    </xsl:if>
                    <xsl:sequence select="node()"/>
                </xsl:copy>
            </xsl:for-each>
        </xsl:copy>
        
        <!--<xsl:sequence select="$compact"/>-->
        <!--<xsl:sequence select="$full"/>-->
        <!--<xsl:sequence select="$by.class"/>-->
        <!--<xsl:sequence select="$by.module"/>-->
        
        <!--<xsl:choose>
            <xsl:when test="$facet.type = 'attributes'">
                
            </xsl:when>
        </xsl:choose>-->
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>Generates a tab for compact display, i.e. only labels (attributes) / links (everything else)</xd:p>
        </xd:desc>
        <xd:param name="div">The wrapper that holds all items (organized by classes)</xd:param>
        <xd:param name="facet.type">The type of contents</xd:param>
        <xd:return>The resulting tab content</xd:return>
    </xd:doc>
    <xsl:function name="tools:getCompactTab" as="node()">
        <xsl:param name="div" as="node()"/>
        <xsl:param name="facet.type" as="xs:string"/>
        
        <div id="{$facet.type}_compact" class="facetTabbedContent compact" data-label="compact">
            <xsl:choose>
                <xsl:when test="$facet.type = 'attributes'">
                    <xsl:for-each select="$div//item/desc/span['ident' = tokenize(@class,' ')]"><xsl:if test="position() gt 1">, </xsl:if><xsl:sequence select="."/></xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:for-each select="$div//item/link/node()"><xsl:if test="position() gt 1">, </xsl:if><xsl:copy>
                            <xsl:apply-templates select="@*" mode="get.website"/>
                            <xsl:attribute name="title" select="normalize-space(string-join(ancestor::item[1]/desc//text(),' '))"/>
                            <xsl:apply-templates select="node()" mode="get.website"/>
                        </xsl:copy></xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>            
        </div>        
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Generates a tab for display by class, with proper nesting</xd:p>
        </xd:desc>
        <xd:param name="div">The wrapper that holds all items (organized by classes)</xd:param>
        <xd:param name="facet.type">The type of contents</xd:param>
        <xd:return>The resulting tab content</xd:return>
    </xd:doc>
    <xsl:function name="tools:getByClassTab" as="node()">
        <xsl:param name="div" as="node()"/>
        <xsl:param name="facet.type" as="xs:string"/>
        
        <div id="{$facet.type}_class" class="facetTabbedContent class" data-label="by class">
            <xsl:apply-templates select="$div/node()" mode="get.website.classTab"/>      
        </div>        
    </xsl:function>
        
    <xd:doc>
        <xd:desc>
            <xd:p>Resolves groups for tabbed content in the "by class" perspective</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="group" mode="get.website.classTab">
        <div class="classBox" title="{@ident}">
            <div class="classHeading">
                <label class="classLabel">
                    <xsl:apply-templates select="child::link/node()" mode="get.website"/>
                </label>
                <span class="classDesc">
                    <xsl:apply-templates select="child::desc/node()" mode="get.website"/>
                </span>
            </div>
            <div class="classContent">
                <xsl:apply-templates select="child::item" mode="#current"/>
                <xsl:apply-templates select="child::group" mode="#current"/>                
            </div>
        </div>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Resolves items for tabbed content in the "by class" perspective</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="item" mode="get.website.classTab">
        <div class="def">
            <xsl:if test="not(@class='attribute')">
                <span class="ident" title="{normalize-space(string-join(child::desc//text(),' '))}">
                    <xsl:apply-templates select="child::link/node()" mode="get.website"/>        
                </span>    
            </xsl:if>
            <span class="desc">
                <xsl:apply-templates select="child::desc/node()" mode="get.website"/>
            </span>
        </div>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Generates a tab for display by module</xd:p>
        </xd:desc>
        <xd:param name="div">The wrapper that holds all items (organized by classes)</xd:param>
        <xd:param name="facet.type">The type of contents</xd:param>
        <xd:return>The resulting tab content</xd:return>
    </xd:doc>
    <xsl:function name="tools:getByModuleTab" as="node()">
        <xsl:param name="div" as="node()"/>
        <xsl:param name="facet.type" as="xs:string"/>
        
        <div id="{$facet.type}_module" class="facetTabbedContent module" data-label="by module">
            <xsl:apply-templates select="($div//text)[1]" mode="get.website"/>
            
            <xsl:variable name="modules.used" select="distinct-values($div//item/@module)" as="xs:string*"/>
            
            <xsl:for-each select="$modules.used">
                <xsl:sort select="." data-type="text"/>
                <xsl:variable name="current.module.ident" select="." as="xs:string"/>
                <xsl:variable name="module" select="$modules/self::tei:moduleSpec[@ident = $current.module.ident]" as="node()"/>
                <xsl:variable name="current.items" select="$div//item[@module = $module/@ident]" as="node()+"/>
                
                <div class="classBox" title="{$module/@ident}">
                    <div class="classHeading">
                        <label class="classLabel">
                            <xsl:value-of select="$module/@ident"/>
                        </label>
                        <span class="classDesc">
                            <xsl:value-of select="normalize-space(string-join($module/tei:desc//text(),' '))"/>
                        </span>
                    </div>
                    <div class="classContent">
                        <xsl:for-each select="$current.items">
                            <xsl:apply-templates select="." mode="get.website.classTab"/>
                        </xsl:for-each>                        
                    </div>
                </div>
            </xsl:for-each>
        </div>        
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Generates a tab for displaying full details on attributes</xd:p>
        </xd:desc>
        <xd:param name="div">The wrapper that holds all items (organized by classes)</xd:param>
        <xd:param name="facet.type">The type of contents</xd:param>
        <xd:return>The resulting tab content</xd:return>
    </xd:doc>
    <xsl:function name="tools:getFullDefinitionTab" as="node()">
        <xsl:param name="div" as="node()"/>
        <xsl:param name="facet.type" as="xs:string"/>
        
        <div id="{$facet.type}_full" class="facetTabbedContent full" data-label="full definition">
            <xsl:for-each select="$div//item">
                <xsl:sort select="@ident" data-type="text"/>
                <xsl:variable name="current.item" select="." as="node()"/>
                <xsl:variable name="start" select="ancestor::section/h2/@id" as="xs:string"/>
                
                <xsl:variable name="end" select="'@' || $current.item/@ident" as="xs:string">
                    
                </xsl:variable>
                <div class="classItem">
                    <div class="desc"><xsl:apply-templates select="$current.item/desc/node()" mode="get.website"/></div>
                    <div class="breadcrumb">
                        <span class="step start"><xsl:value-of select="$start"/></span>
                        <xsl:for-each select="$current.item/ancestor::group/link">
                            <span class="step"><xsl:apply-templates select="node()" mode="get.website"/></span>
                        </xsl:for-each>
                        <span class="step end"><xsl:value-of select="$end"/></span>
                    </div>
                </div>
            </xsl:for-each>           
        </div>        
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Creates a statement about textual content being allowed</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="text" mode="get.website.classTab">
        <div class="textualContent" title="textual content">textual content</div>
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