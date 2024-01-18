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
    xmlns:json="http://www.w3.org/2005/xpath-functions"    
    exclude-result-prefixes="xs math xd xhtml tei tools rng sch egx json"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jul 8, 2021</xd:p>
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
    <xd:doc>
        <xd:desc>
            <xd:p></xd:p>
        </xd:desc>
        <xd:param name="url"></xd:param>
        <xd:return></xd:return>
    </xd:doc>
    <xsl:function name="tools:adjustImageUrl" as="xs:string">
        <xsl:param name="url" as="xs:string"/>
        <xsl:variable name="out" as="xs:string">
            <xsl:choose>
                <xsl:when test="starts-with($url,'../images')">
                    <xsl:value-of select="$assets.folder.rel || substring($url,4)"/>
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
    
    <!--<xd:doc>
        <xd:desc>
            <xd:p>Builds a flat list of chapter elements that can be used for building tocs etc. Recursively called on child chapters.</xd:p>
        </xd:desc>
        <xd:param name="node">The node whose children will be examined. Starts at the TEI body, looks for divs</xd:param>
        <xd:param name="level">The current level of nesting. Increased by one with every recursive call</xd:param>
        <xd:param name="parent.number">The number of parent chapters, to which the current index will be appended</xd:param>
        <xd:return>A list of chapter elements</xd:return>
    </xd:doc>-->
    <xd:doc>
        <xd:desc>
            <xd:p></xd:p>
        </xd:desc>
        <xd:param name="node"></xd:param>
        <xd:param name="level"></xd:param>
        <xd:param name="parent.number"></xd:param>
        <xd:return></xd:return>
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
    <xd:doc>
        <xd:desc>
            <xd:p></xd:p>
        </xd:desc>
        <xd:return></xd:return>
    </xd:doc>
    <xsl:function name="tools:generatePreface" as="node()+">
        <xsl:message select="'Generating preface'"/>
        <xsl:variable name="git.link" select="'https://github.com/music-encoding/music-encoding/commit/' || $retrieved.hash" as="xs:string"/>
        <xsl:variable name="git.short" select="substring($retrieved.hash,1,7)" as="xs:string"/>
        
        <xsl:variable name="overlay.content" as="xs:string?">
            <xsl:choose>
                <xsl:when test="tokenize($git.head,'/')[last()] = ('stable','main','master','v5.0')"></xsl:when>
                <xsl:when test="tokenize($git.head,'/')[last()] = 'develop'">DEVELOPMENT VERSION</xsl:when>
                <xsl:otherwise><xsl:value-of select="upper-case(tokenize($git.head,'/')[last()]) || ' BRANCH'"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="editor.in.chief" select="$source.file//tei:respStmt/tei:name[@role='pbd']/normalize-space(text())" as="xs:string+"/>
        <xsl:variable name="editors" as="xs:string+">
            <xsl:for-each select="distinct-values($docs.folder//tei:respStmt/tei:name[@role='edt']/normalize-space(text()))">
                <xsl:sort select="tokenize(.,' ')[last()]"/>
                <xsl:variable name="current.name" select="." as="xs:string"/>
                <xsl:variable name="chapter.ids" select="$docs.folder/self::tei:TEI[.//tei:respStmt/tei:name[@role='edt']/normalize-space(text()) = $current.name]//tei:div[@type='div1']/@xml:id" as="xs:string+"/>
                <xsl:variable name="chapter.nums" as="xs:integer+">
                    <xsl:for-each select="$chapter.ids">
                        <xsl:variable name="current.chapter.id" select="." as="xs:string"/>
                        <xsl:value-of select="count($source.file//tei:div[@xml:id = $current.chapter.id]/preceding-sibling::tei:div) + 1"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="ordered.chapter.nums" as="xs:string+">
                    <xsl:for-each select="$chapter.nums">
                        <xsl:sort select="." data-type="number" order="ascending"/>
                        <xsl:value-of select="string(.)"/>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="chapters" select="if(count($ordered.chapter.nums) = 1) then('(Chapter ' || $ordered.chapter.nums || ')') else('(Chapters ' || string-join($ordered.chapter.nums, ', ') || ')')" as="xs:string"/>
                <xsl:value-of select="$current.name || ' ' || $chapters"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="editor-in-chief-label" select="if(count($editor.in.chief) gt 1) then('Editors-in-chief') else('Editor-in-chief')" as="xs:string"/>
        
        <xsl:message select="'pbd: ' || string-join($editor.in.chief,', ')"/>
        <xsl:message select="'edt: ' || string-join($editors,', ')"/>
        
        <section class="page1">
            <div id="hiddenBranchInfo"><xsl:value-of select="$overlay.content"/></div>
            <h1>
                <small class="in">The</small>
                Music Encoding Initiative
                <small class="out">Guidelines</small>
            </h1>
            <img id="meiLogo" src="images/meilogo.png"/>    
            <div class="bottom">
                <div class="versionDiv">Version <span id="version"><xsl:value-of select="$version"/></span> <span class="gitLinkWrapper">(<a id="gitVersionLink" href="{$git.link}">#<xsl:value-of select="$git.short"/></a>)</span></div>
                <div class="generationDiv">generated on <span id="generationDate"><xsl:value-of select="format-date(current-date(), '[D1] [MNn] [Y1]')"/></span></div>                
            </div>
        </section>
        <section class="imprintPage">
            <div id="imprint">
                <div class="title">The Music Encoding Initiative Guidelines</div>
                <div class="versionInfo">Version <xsl:value-of select="$version"/> (<a class="hiddenLink" href="{$git.link}">#<xsl:value-of select="$git.short"/></a>), generated on <xsl:value-of select="format-date(current-date(), '[D1] [MNn] [Y1]')"/></div>
                <div class="editors"><xsl:value-of select="$editor-in-chief-label"/>: <xsl:value-of select="string-join($editor.in.chief,', ')"/></div>
                <div class="editors">Editors: <xsl:value-of select="string-join($editors,', ')"/></div>
                <div class="layout">Layout: Johannes Kepper</div>
                <div class="copyright">© by the Music Encoding Initiative, as represented by the MEI Board.</div>
                <div class="license">Licensed under the Educational Community License, Version 2.0 (the "License"); you may not use this file except in compliance 
                    with the License. You may obtain a copy of the License at <a class="hiddenLink" href="https://opensource.org/licenses/ECL-2.0">https://opensource.org/licenses/ECL-2.0</a>.</div>
            </div>
        </section>
    </xsl:function>
        
    <xd:doc>
        <xd:desc>
            <xd:p>Generates a table of contents</xd:p>
        </xd:desc>
        <xd:return>the table of contents markup</xd:return>
    </xd:doc>
    <xd:doc>
        <xd:desc>
            <xd:p></xd:p>
        </xd:desc>
        <xd:return></xd:return>
    </xd:doc>
    <xsl:function name="tools:generateToc" as="node()">
        <xsl:message select="'Generating TOC'"/>
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
                        <li class="toc toc_2">
                            <a class="toc toc_2" href="#moduleSpecs">Modules in MEI</a>
                        </li>
                        <li class="toc toc_2">
                            <a class="toc toc_2" href="#elementSpecs">Element Specifications</a>
                        </li>
                        <li class="toc toc_2">
                            <a class="toc toc_2" href="#modelClassSpecs">Model Class Specifications</a>
                        </li>
                        <li class="toc toc_2">
                            <a class="toc toc_2" href="#macroGroupSpecs">Macro Group Specifications</a>
                        </li>
                        <li class="toc toc_2">
                            <a class="toc toc_2" href="#attClassSpecs">Attribute Class Specifications</a>
                        </li>
                        <li class="toc toc_2">
                            <a class="toc toc_2" href="#dataTypeSpecs">Data Type Specifications</a>
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
                            <a class="toc toc_2" href="#macroGroupIndex">Index of Macro Groups</a>
                        </li>
                        <li class="toc toc_2">
                            <a class="toc toc_2" href="#attClassIndex">Index of Attribute Classes</a>
                        </li>
                        <li class="toc toc_2">
                            <a class="toc toc_2" href="#dataTypeIndex">Index of Data Types</a>
                        </li>     
                        <li class="toc toc_2">
                            <a class="toc toc_2" href="#contributorList">Contributors</a>
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
    <xd:doc>
        <xd:desc>
            <xd:p></xd:p>
        </xd:desc>
        <xd:param name="chapter"></xd:param>
        <xd:return></xd:return>
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
    <xd:doc>
        <xd:desc>
            <xd:p></xd:p>
        </xd:desc>
        <xd:param name="target"></xd:param>
        <xd:return></xd:return>
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
            <xsl:when test="$target = ('svg_svg','svg')">
                <xsl:value-of select="'link_odd link_external_module'"/>
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
    <xd:doc>
        <xd:desc>
            <xd:p></xd:p>
        </xd:desc>
        <xd:param name="ident"></xd:param>
        <xd:param name="type"></xd:param>
        <xd:return></xd:return>
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
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>Generates indizes for the back of the Guidelines PDF</xd:p>
        </xd:desc>
        <xd:return></xd:return>
    </xd:doc>
    <xd:doc>
        <xd:desc>
            <xd:p></xd:p>
        </xd:desc>
        <xd:return></xd:return>
    </xd:doc>
    <xsl:function name="tools:generateIndizes" as="node()+">
        <xsl:message select="'Generating indices'"/>
        <section id="elementIndex" class="backIndex">
            <h1>Index of Elements</h1>
            <xsl:for-each select="$elements.pdf.links">
                <div class="indexLink">
                    <xsl:sequence select="."/>
                </div>
            </xsl:for-each>
        </section>
        <section id="modelClassIndex" class="backIndex">
            <h1>Index of Model Classes</h1>
            <xsl:for-each select="$model.classes.pdf.links">
                <div class="indexLink">
                    <xsl:sequence select="."/>
                </div>
            </xsl:for-each>
        </section>
        <section id="macroGroupIndex" class="backIndex">
            <h1>Index of Macro Groups</h1>
            <xsl:for-each select="$macro.groups.pdf.links">
                <div class="indexLink">
                    <xsl:sequence select="."/>
                </div>
            </xsl:for-each>
        </section>
        <section id="attClassIndex" class="backIndex">
            <h1>Index of Attribute Classes</h1>
            <xsl:for-each select="$att.classes.pdf.links">
                <div class="indexLink">
                    <xsl:sequence select="."/>
                </div>
            </xsl:for-each>
        </section>
        <section id="dataTypeIndex" class="backIndex">
            <h1>Index of Data Types</h1>
            <xsl:for-each select="$data.types.pdf.links">
                <div class="indexLink">
                    <xsl:sequence select="."/>
                </div>
            </xsl:for-each>
        </section>
        <section id="contributorList" class="backIndex">
            <h1>Contributors</h1>
            <p>
                The Guidelines and specifications made available in this document wouldn't have been possible without the generous
                and selfless support of a large number of people. Some of those people, especially from the early days of MEI are 
                explicitly mentioned in chapter <a href="#acknowledgments">1.1.1 Acknowledgments</a> of these Guidelines. However, we 
                believe it is important to give proper recognition to everyone contributing to this community effort. Without 
                their continued commitment, MEI would not be possible. 
            </p>            
            <xsl:sequence select="tools:getContributors()"/>
            <p>
                This list is automatically compiled from all contributors to the 
                <a href="https://github.com/music-encoding/music-encoding">/music-encoding/music-encoding</a>
                and <a href="https://github.com/music-encoding/guidelines">/music-encoding/guidelines</a> repositories at GitHub. The editors
                of the Guidelines are equally added, as are other people who have made substantial contributions beyond the scope of 
                GitHub. 
                It is certainly not an exhaustive list, as there are manifold ways to contribute to MEI. If you feel like you should be 
                mentioned here, please reach out to the <a href="https://music-encoding.org/community/mei-board.html">Technical 
                    Co-Chairs of the MEI Board</a>, and they will happily include you here. 
            </p>
            <p>
                As representatives of the MEI Community, the MEI Board would like to thank everyone involved in the creation and 
                maintenance of these MEI Guidelines. At the same time, it invites new contributors and encourages to help building 
                bridges between different musical repertoires and styles, historical periods, cultural backgrounds, musical domains, 
                research interests, and methodical concepts by reasoning about a common encoding framework like MEI. 
            </p>
            
        </section>
    </xsl:function>
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>Retrieves the Contributors to the MEI Guidelines and Specs from the public GitHub API</xd:p>
        </xd:desc>
        <xd:return></xd:return>
    </xd:doc>
    <xsl:function name="tools:getContributors" as="node()*">
        <xsl:variable name="spec.repo.contributors" select="'https://api.github.com/repos/music-encoding/music-encoding/contributors'" as="xs:string"/>
        <xsl:variable name="docs.repo.contributors" select="'https://api.github.com/repos/music-encoding/guidelines/contributors'" as="xs:string"/>
        
        <xsl:variable name="contributors">
            <xsl:variable name="raw.contributors" as="node()*">
                <xsl:sequence select="tools:retrieveData($docs.repo.contributors)/child::json:array/json:map"/>
                <xsl:sequence select="tools:retrieveData($spec.repo.contributors)/child::json:array/json:map"/>
            </xsl:variable>
            <xsl:variable name="unique.ids" select="distinct-values($raw.contributors//json:number[@key = 'id']/text())" as="xs:string*"/>
            <xsl:variable name="unique.contributors" as="node()*">
                <xsl:for-each select="$unique.ids">
                    <xsl:variable name="current.id" select="." as="xs:string"/>
                    <xsl:sequence select="($raw.contributors/self::json:map[./json:number[@key='id']/text() = $current.id])[1]"/>
                </xsl:for-each>
            </xsl:variable>
            
            <!-- DEBUG -->
            <!--<xsl:message select="$raw.contributors"/>
            <xsl:message select="$unique.ids"/>-->
            
            
            <array xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:for-each select="$unique.contributors">
                    <xsl:sort select="json:string[@key = 'url']/text()"/>
                    <xsl:variable name="user.data" select="tools:retrieveData(json:string[@key = 'url']/text())/child::json:map" as="node()?"/>
                    <map>
                        <string key="login"><xsl:value-of select="$user.data/json:string[@key = 'login']"/></string>
                        <string key="name"><xsl:value-of select="$user.data/json:string[@key = 'name']"/></string>
                        <string key="github"><xsl:value-of select="$user.data/json:string[@key = 'html_url']"/></string>
                        <string key="viaf"></string>
                        <string key="orcid"></string>
                        <string key="avatar"><xsl:value-of select="$user.data/json:string[@key = 'avatar_url']"/></string>
                    </map>                    
                </xsl:for-each>    
            </array>
            
        </xsl:variable>
        
        <xsl:variable name="curated.uri" as="xs:string">
            <xsl:choose>
                <xsl:when test="$basedir eq ''">
                    <xsl:value-of select="replace(string(document-uri($mei.source)),'/source/mei-source.xml','/source/contributors/curated.contributors.json')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$basedir || '/source/contributors/curated.contributors.json'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="curated.contributors" select="tools:retrieveData($curated.uri)" as="node()*"/>
        
        <xsl:variable name="merged.contributors" as="node()*">
            <array xmlns="http://www.w3.org/2005/xpath-functions">
            <xsl:for-each select="$curated.contributors//json:map[not(json:boolean[@key = 'suppress']/text() = 'true')] | $contributors//json:map[not(json:string[@key='github']/text() = $curated.contributors//json:string[@key = 'github']/text())]">
                <xsl:sort select=".//json:string[@key='name']/text()"/>
                <xsl:sequence select="."/>
            </xsl:for-each>
            </array>
        </xsl:variable>
        
        <table class="meiContributors">
            <thead>
                <tr>
                    <td class="names"></td>
                    <td class="git"><img class="contributorHeading" src="images/github-logo.svg"/></td>
                    <td class="orcid"><img class="contributorHeading" src="images/ORCID_logo.svg"/></td>
                    <td class="viaf">VIAF</td>
                </tr>
            </thead>
            <tbody>
                <xsl:for-each select="$merged.contributors//json:map[json:string[@key = 'login']]">
                    <!-- make sure accounts without name are pushed to the end -->
                    <xsl:sort select="tokenize(normalize-space(./json:string[@key = 'name']/text() || 'zzzzzzzz'),' ')[last()]"/>
                    <xsl:variable name="current.contributor" select="." as="node()"/>
                    <xsl:variable name="name" select="$current.contributor/json:string[@key = 'name']/text() || ''" as="xs:string"/>
                    <xsl:variable name="login" select="$current.contributor/json:string[@key = 'login']/text()" as="xs:string"/>
                    <tr class="meiContributor">
                        <td class="contributorName">
                            <xsl:value-of select="if(string-length($name) gt 0) then ($name) else($login)"/>
                        </td>
                        <td class="git">
                            <a class="contributorLink gitLink" href="{$current.contributor/json:string[@key = 'github']/text()}">
                                <img class="contibutorAvatar" src="{$current.contributor/json:string[@key = 'avatar']/text()}"/>
                                <span><xsl:value-of select="substring-after($current.contributor/json:string[@key = 'github']/text(),'https://github.com/')"/></span>
                            </a>
                        </td>
                        <td class="orcid">
                            <xsl:if test="$current.contributor/json:string[@key = 'orcid']/text() and string-length($current.contributor/json:string[@key = 'orcid']/text()) gt 0">
                                <a class="contributorLink orcidLink" href="{$current.contributor/json:string[@key = 'orcid']/text()}">
                                    <img class="contibutorAvatar" src="images/ORCID_iD.svg"/>
                                    <span><xsl:value-of select="substring-after($current.contributor/json:string[@key = 'orcid']/text(),'https://orcid.org/')"/></span>
                                </a>
                            </xsl:if>                            
                        </td>                        
                        <td class="viaf">
                            <xsl:if test="$current.contributor/json:string[@key = 'viaf']/text() and string-length($current.contributor/json:string[@key = 'viaf']/text()) gt 0">
                                <a class="contributorLink viafLink" href="{$current.contributor/json:string[@key = 'viaf']/text()}">
                                    <span><xsl:value-of select="$current.contributor/json:string[@key = 'viaf']/text()"/></span>
                                </a>
                            </xsl:if>
                            
                        </td>
                    </tr>
                </xsl:for-each>
                <xsl:for-each select="$merged.contributors//json:map[not(json:string[@key = 'login'])]">
                    <xsl:message select="'Unable to handle the following contributor:'"/>
                    <xsl:message select="."/>
                </xsl:for-each>
            </tbody>
        </table>
        
        
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Retrieves a JSON document and returns it as XML</xd:p>
        </xd:desc>
        <xd:param name="url"></xd:param>
        <xd:return></xd:return>
    </xd:doc>
    <xsl:function name="tools:retrieveData" as="node()*">
        <xsl:param name="url" as="xs:string"/>
        <xsl:variable name="json" as="node()*">
            <xsl:try>
                <xsl:sequence select="json-to-xml(unparsed-text($url))"/>
                <xsl:catch errors="*"></xsl:catch>
            </xsl:try>
        </xsl:variable>
        
        <xsl:sequence select="$json"/>
    </xsl:function>
</xsl:stylesheet>