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
    xmlns:json="http://www.w3.org/2005/xpath-functions"
    xmlns:tools="no:where"
    xmlns:search="temp.search"
    exclude-result-prefixes="xs math xd xhtml tei tools search json rng sch egx"
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
        <xsl:message select="'Generating HTML document for website'"/>
        
        <xsl:variable name="web.output" select="$dist.folder" as="xs:string"/>
        
        <!-- index page -->
        <xsl:result-document href="{$web.output}index.html">
            <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
            <html lang="en">
                <head>
                    <meta http-equiv="content-type" content="text/html; charset=utf-8" />
                    <meta http-equiv="refresh" content="0;url=./content/index.html" />
                </head>
                <body>
                </body>
            </html>
        </xsl:result-document>
        
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
            
            <xsl:result-document href="{$path}" method="html">
                <xsl:sequence select="$content"/>
            </xsl:result-document>
        </xsl:for-each>
        
        <xsl:variable name="search.index" as="node()*">
            <map xmlns="http://www.w3.org/2005/xpath-functions">
                <array key="pages">
                    <xsl:for-each select="$input//*[matches(@class,'^div\d$')]">
                        <xsl:variable name="text" select="normalize-space(string-join(child::*[not(local-name() = ('h1','h2','h3','h4','h5','h6')) and not(@class and matches(@class,'^div\d$'))]//text(),' '))" as="xs:string?"/>
                        <xsl:variable name="h" select="child::*[local-name() = ('h1','h2','h3','h4','h5','h6')]" as="node()"/>
                        <xsl:variable name="id" select="$h/@id" as="xs:string"/>
                        <xsl:variable name="title" select="$h/span[@class='head']/text()" as="xs:string"/>
                        <xsl:variable name="path" select="$h/ancestor::section[@class='div1']/h1/@id" as="xs:string"/>
                        <xsl:variable name="hash" select="if($path eq $id) then() else('#' || $id)" as="xs:string?"/>
                        <xsl:variable name="url" select="'/content/' || $path || '.html' || $hash" as="xs:string"/>
                        <map>
                            <string key="text"><xsl:value-of select="$text"/></string>
                            <string key="title"><xsl:value-of select="$title"/></string>
                            <string key="url"><xsl:value-of select="$url"/></string>
                            <string key="tags"><xsl:value-of select="''"/></string>
                        </map>
                    </xsl:for-each>
                </array>
            </map>
        </xsl:variable>
        <xsl:variable name="newline" as="xs:string"><xsl:text>&#xa;</xsl:text></xsl:variable>
        <xsl:variable name="quot" as="xs:string">"</xsl:variable>
        <xsl:variable name="json.string" select="replace(replace(replace(xml-to-json($search.index),'\\/','/'),'\{', $newline || '{'),'(' || $quot || '(text|title|url|tags)' || $quot || ')',$newline || '  $1')" as="xs:string"/>
        
        <xsl:result-document href="{$web.output}assets/js/searchIndex.js" method="text" omit-xml-declaration="yes">
            const searchIndex = <xsl:sequence select="json:xml-to-json(search:getIndex())"/>
        </xsl:result-document>
        
        <xsl:result-document href="{$web.output}content/index.html" method="html">
            <xsl:variable name="chapter.overview" as="node()*">
                <h1>MEI Guidelines (<xsl:value-of select="$version"/>)</h1>
                <xsl:for-each select="$input//section[@class='div1']/h1[1]">
                    <p class="mainToc">
                        <a href="{@id}.html"><xsl:value-of select="normalize-space(string-join(.//text(),' '))"/></a>
                    </p>
                </xsl:for-each>
            </xsl:variable>
            <xsl:call-template name="getSinglePage">
                <xsl:with-param name="contents" select="$chapter.overview" as="node()*"/>
                <xsl:with-param name="media" select="'screen'"/>
            </xsl:call-template>
        </xsl:result-document>
        
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
            
            <xsl:result-document href="{$path}" method="html">
                <xsl:sequence select="$content"/>
            </xsl:result-document>
        </xsl:for-each>
        
        <xsl:result-document href="{$web.output}modules.html" method="html">
            <xsl:variable name="modules.overview" as="node()*">
                <div class="specPage overview">
                    <h2>MEI Modules</h2>
                    <xsl:for-each select="$input//section[@class='specPage moduleSpec']/h2[1]">
                        <xsl:sort select="@id"/>
                        <p class="mainToc">
                            <a href="./modules/{@id}.html" title="{normalize-space(string-join(parent::section/div[@class='specs']/div[@class='desc']/text(),' '))}"><xsl:value-of select="normalize-space(string-join(.//text(),' '))"/></a>
                        </p>
                    </xsl:for-each>    
                </div>
            </xsl:variable>
            <xsl:call-template name="getSinglePage">
                <xsl:with-param name="contents" select="$modules.overview" as="node()*"/>
                <xsl:with-param name="media" select="'screen'"/>
                <xsl:with-param name="reducedLevels" select="true()"/>
            </xsl:call-template>
        </xsl:result-document>
        
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
            
            <xsl:result-document href="{$path}" method="html">
                <xsl:sequence select="$content"/>
            </xsl:result-document>
        </xsl:for-each>
        
        <xsl:result-document href="{$web.output}elements.html" method="html">
            
            <xsl:variable name="elementSpecs" select="$input//section[@class='specPage elementSpec']/h2[1]" as="node()*"/>
            <xsl:variable name="starting.letters" select="distinct-values($elementSpecs/substring(@id,1,1))" as="xs:string*"/>
            
            <xsl:variable name="elements.overview" as="node()*">
                <div class="specPage overview">
                    <h2>Elements</h2>
                    <div class="letterSelection">
                        <ul class="pagination">
                            <xsl:for-each select="$starting.letters">
                                <xsl:sort select="."/>
                                <xsl:variable select="." name="current.letter" as="xs:string"/>
                                <li class="page-item">
                                    <a href="#letterFacet_{$current.letter}"><xsl:value-of select="$current.letter"/></a>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                    <xsl:for-each select="$starting.letters">
                        <xsl:sort select="."/>
                        <xsl:variable name="current.letter" select="." as="xs:string"/>
                        <div id="letterFacet_{$current.letter}" class="letter facet overview">
                            <div class="label"><xsl:value-of select="$current.letter"/></div>
                            <div class="statement compact list">
                                <xsl:for-each select="$elementSpecs[starts-with(@id, $current.letter)]">
                                    <xsl:sort select="@id"/>
                                    <a class="overviewLink element" title="{normalize-space(string-join(parent::section/div[@class='specs']/div[@class='desc']/text(),' '))}" data-initial="{$current.letter}" data-ident="{@id}" href="./elements/{@id}.html"><xsl:value-of select="@id"/></a>
                                </xsl:for-each>
                            </div>
                        </div>
                    </xsl:for-each>    
                </div>
            </xsl:variable>
            <xsl:call-template name="getSinglePage">
                <xsl:with-param name="contents" select="$elements.overview" as="node()*"/>
                <xsl:with-param name="media" select="'screen'"/>
                <xsl:with-param name="reducedLevels" select="true()"/>
            </xsl:call-template>
        </xsl:result-document>
        
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
            
            <xsl:result-document href="{$path}" method="html">
                <xsl:sequence select="$content"/>
            </xsl:result-document>
        </xsl:for-each>
        
        <xsl:result-document href="{$web.output}model-classes.html" method="html">
            
            <xsl:variable name="modelSpecs" select="$input//section[@class='specPage modelClassSpec']/h2[1]" as="node()*"/>
            <xsl:variable name="starting.letters" select="distinct-values($modelSpecs/substring(@id,7,1))" as="xs:string*"/>
            
            <xsl:variable name="models.overview" as="node()*">
                <div class="specPage overview">
                    <h2>Model Classes</h2>
                    <div class="letterSelection">
                        <ul class="pagination">
                            <xsl:for-each select="$starting.letters">
                                <xsl:sort select="."/>
                                <li class="page-item">
                                    <a href="#letterFacet_{.}"><xsl:value-of select="."/></a>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                    <xsl:for-each select="$starting.letters">
                        <xsl:sort select="."/>
                        <xsl:variable name="current.letter" select="." as="xs:string"/>
                        <div id="letterFacet_{$current.letter}" class="letter facet overview">
                            <div class="label"><xsl:value-of select="$current.letter"/></div>
                            <div class="statement compact list">
                                <xsl:for-each select="$modelSpecs[starts-with(@id, 'model.' || $current.letter)]">
                                    <xsl:sort select="@id"/>
                                    <a class="overviewLink model" title="{normalize-space(string-join(parent::section/div[@class='specs']/div[@class='desc']/text(),' '))}" data-initial="{$current.letter}" data-ident="{@id}" href="./model-classes/{@id}.html"><xsl:value-of select="@id"/></a>
                                </xsl:for-each>
                            </div>
                        </div>
                    </xsl:for-each>    
                </div>
            </xsl:variable>
            <xsl:call-template name="getSinglePage">
                <xsl:with-param name="contents" select="$models.overview" as="node()*"/>
                <xsl:with-param name="media" select="'screen'"/>
                <xsl:with-param name="reducedLevels" select="true()"/>
            </xsl:call-template>
        </xsl:result-document>
        
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
            
            <xsl:result-document href="{$path}" method="html">
                <xsl:sequence select="$content"/>
            </xsl:result-document>
        </xsl:for-each>
        
        <xsl:result-document href="{$web.output}macro-groups.html" method="html">
            
            <xsl:variable name="macroGroupSpecs" select="$input//section[@class='specPage macroGroupSpec']/h2[1]" as="node()*"/>
            <xsl:variable name="starting.letters" select="distinct-values($macroGroupSpecs/substring(@id,7,1))" as="xs:string*"/>
            
            <xsl:variable name="macroGroups.overview" as="node()*">
                <div class="specPage overview">
                    <h2>Macro Groups</h2>
                    <div class="letterSelection">
                        <ul class="pagination">
                            <xsl:for-each select="$starting.letters">
                                <xsl:sort select="."/>
                                <li class="page-item">
                                    <a href="#letterFacet_{.}"><xsl:value-of select="."/></a>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                    <xsl:for-each select="$starting.letters">
                        <xsl:sort select="."/>
                        <xsl:variable name="current.letter" select="." as="xs:string"/>
                        <div id="letterFacet_{$current.letter}" class="letter facet overview">
                            <div class="label"><xsl:value-of select="$current.letter"/></div>
                            <div class="statement compact list">
                                <xsl:for-each select="$macroGroupSpecs[starts-with(@id, 'macro.' || $current.letter)]">
                                    <xsl:sort select="@id"/>
                                    <a class="overviewLink macro" title="{normalize-space(string-join(parent::section/div[@class='specs']/div[@class='desc']/text(),' '))}" data-initial="{$current.letter}" data-ident="{@id}" href="./macro-groups/{@id}.html"><xsl:value-of select="@id"/></a>
                                </xsl:for-each>
                            </div>
                        </div>
                    </xsl:for-each>    
                </div>
            </xsl:variable>
            <xsl:call-template name="getSinglePage">
                <xsl:with-param name="contents" select="$macroGroups.overview" as="node()*"/>
                <xsl:with-param name="media" select="'screen'"/>
                <xsl:with-param name="reducedLevels" select="true()"/>
            </xsl:call-template>
        </xsl:result-document>
        
        <xsl:for-each select="$input//section[@class='specPage attClassSpec']">
            <xsl:variable name="current.page" select="." as="node()"/>
            <xsl:variable name="id" select="$current.page/h2[1]/@id" as="xs:string"/>
            <xsl:variable name="html" as="node()">
                <xsl:apply-templates select="$current.page" mode="get.website"/>
            </xsl:variable>
            
            <xsl:variable name="path" select="$web.output || 'attribute-classes/' || $id || '.html'" as="xs:string"/>
            <xsl:variable name="content" as="node()+">
                <xsl:call-template name="getSinglePage">
                    <xsl:with-param name="contents" select="$html" as="node()*"/>
                    <xsl:with-param name="media" select="'screen'"/>
                </xsl:call-template>
            </xsl:variable>
            
            <xsl:result-document href="{$path}" method="html">
                <xsl:sequence select="$content"/>
            </xsl:result-document>
        </xsl:for-each>
        
        <xsl:result-document href="{$web.output}attribute-classes.html" method="html">
            
            <xsl:variable name="attClassSpecs" select="$input//section[@class='specPage attClassSpec']/h2[1]" as="node()*"/>
            <xsl:variable name="starting.letters" select="distinct-values($attClassSpecs/substring(@id,5,1))" as="xs:string*"/>
            
            <xsl:variable name="attClasses.overview" as="node()*">
                <div class="specPage overview">
                    <h2>Attribute Classes</h2>
                    <div class="letterSelection">
                        <ul class="pagination">
                            <xsl:for-each select="$starting.letters">
                                <xsl:sort select="."/>
                                <li class="page-item">
                                    <a href="#letterFacet_{.}"><xsl:value-of select="."/></a>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                    <xsl:for-each select="$starting.letters">
                        <xsl:sort select="."/>
                        <xsl:variable name="current.letter" select="." as="xs:string"/>
                        <div id="letterFacet_{$current.letter}" class="letter facet overview">
                            <div class="label"><xsl:value-of select="$current.letter"/></div>
                            <div class="statement compact list">
                                <xsl:for-each select="$attClassSpecs[starts-with(@id, 'att.' || $current.letter)]">
                                    <xsl:sort select="@id"/>
                                    <a class="overviewLink attribute" title="{normalize-space(string-join(parent::section/div[@class='specs']/div[@class='desc']/text(),' '))}" data-initial="{$current.letter}" data-ident="{@id}" href="./attribute-classes/{@id}.html"><xsl:value-of select="@id"/></a>
                                </xsl:for-each>
                            </div>
                        </div>
                    </xsl:for-each>    
                </div>
            </xsl:variable>
            <xsl:call-template name="getSinglePage">
                <xsl:with-param name="contents" select="$attClasses.overview" as="node()*"/>
                <xsl:with-param name="media" select="'screen'"/>
                <xsl:with-param name="reducedLevels" select="true()"/>
            </xsl:call-template>
        </xsl:result-document>
        
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
            
            <xsl:result-document href="{$path}" method="html">
                <xsl:sequence select="$content"/>
            </xsl:result-document>
        </xsl:for-each>
        
        <xsl:result-document href="{$web.output}data-types.html" method="html">
            
            <xsl:variable name="dataTypeSpecs" select="$input//section[@class='specPage dataTypeSpec']/h2[1]" as="node()*"/>
            <xsl:variable name="starting.letters" select="distinct-values($dataTypeSpecs/substring(@id,6,1))" as="xs:string*"/>
            
            <xsl:variable name="dataTypes.overview" as="node()*">
                <div class="specPage overview">
                    <h2>Data Types</h2>
                    <div class="letterSelection">
                        <ul class="pagination">
                            <xsl:for-each select="$starting.letters">
                                <xsl:sort select="."/>
                                <li class="page-item">
                                    <a href="#letterFacet_{.}"><xsl:value-of select="."/></a>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                    <xsl:for-each select="$starting.letters">
                        <xsl:sort select="."/>
                        <xsl:variable name="current.letter" select="." as="xs:string"/>
                        <div id="letterFacet_{$current.letter}" class="letter facet overview">
                            <div class="label"><xsl:value-of select="$current.letter"/></div>
                            <div class="statement compact list">
                                <xsl:for-each select="$dataTypeSpecs[starts-with(@id, 'data.' || $current.letter)]">
                                    <xsl:sort select="@id"/>
                                    <a class="overviewLink datatype" title="{normalize-space(string-join(parent::section/div[@class='specs']/div[@class='desc']/text(),' '))}" data-initial="{$current.letter}" data-ident="{@id}" href="./data-types/{@id}.html"><xsl:value-of select="@id"/></a>
                                </xsl:for-each>
                            </div>
                        </div>
                    </xsl:for-each>    
                </div>
            </xsl:variable>
            <xsl:call-template name="getSinglePage">
                <xsl:with-param name="contents" select="$dataTypes.overview" as="node()*"/>
                <xsl:with-param name="media" select="'screen'"/>
                <xsl:with-param name="reducedLevels" select="true()"/>
            </xsl:call-template>
        </xsl:result-document>
        
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Retrieves the current menu structure from music-encoding.org and builds a menu</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="websiteMenu" as="node()">
        
        <xsl:variable name="url" as="xs:string?">
            <xsl:choose>
                <xsl:when test="unparsed-text-available('https://raw.githubusercontent.com/music-encoding/music-encoding.github.io/main/_config.yml')">
                    <xsl:value-of select="'https://raw.githubusercontent.com/music-encoding/music-encoding.github.io/main/_config.yml'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="not($url)">
                <xsl:comment>Error: Unable to retrieve _config.yml from music-encoding.github.io repo.</xsl:comment>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="config.yml.raw" select="unparsed-text-lines($url)" as="xs:string*"/>
                <xsl:variable name="menu.start" select="index-of($config.yml.raw,'menu:')" as="xs:integer"/>
                <xsl:variable name="menu.end" select="min(index-of($config.yml.raw,'')[. gt $menu.start])" as="xs:integer"/>
                <xsl:variable name="menu.lines" select="$config.yml.raw[position() gt $menu.start][position() lt $menu.end]" as="xs:string*"/>
                
                <xsl:variable name="tick" as="xs:string">'</xsl:variable>
                
                <xsl:variable name="menu" as="node()*">
                    <xsl:for-each select="$menu.lines">
                        <xsl:variable name="pos" select="position()" as="xs:integer"/>
                        <xsl:if test="starts-with(.,'    - id:')">
                            <xsl:variable name="id" select="substring-after(.,'id: ')" as="xs:string"/>
                            <xsl:variable name="label" select="replace(substring-after($menu.lines[position() gt $pos][starts-with(., '      label:')][1],' label: '),$tick,'')" as="xs:string"/>
                            <xsl:variable name="url" select="replace(substring-after($menu.lines[position() gt $pos][starts-with(., '      url:')][1],' url: '),$tick,'')" as="xs:string"/>
                            
                            <xsl:variable name="next.page" select="$menu.lines[position() gt $pos][starts-with(.,'    - id:')]" as="xs:string*"/>
                            <xsl:variable name="next.page.pos" select="if(count($next.page) eq 0) then(-1) else(index-of($menu.lines,$next.page[1]))" as="xs:integer"/>
                            <xsl:variable name="next.submenu" select="$menu.lines[position() gt $pos][starts-with(.,'      submenu:')]" as="xs:string*"/>
                            <xsl:variable name="next.submenu.pos" select="if(count($next.submenu) eq 0) then(-1) else(index-of($menu.lines,$next.submenu[1])[. gt $pos][1])" as="xs:integer"/>
                            
                            <!--<xsl:message select="'  page ' || $id || ' (' || $pos || ') has submenu starting at ' || $next.submenu.pos || ', while next page starts at ' || $next.page.pos"/>-->
                            
                            <page id="{$id}" level="1" label="{$label}" url="{$url}">
                                <xsl:choose>
                                    <xsl:when test="$next.submenu.pos eq -1"/>
                                    <xsl:when test="$next.page.pos eq -1 and $next.submenu.pos gt -1">
                                        <xsl:variable name="submenu.lines" select="$menu.lines[position() gt $next.submenu.pos]" as="xs:string+"/>
                                        <xsl:for-each select="$submenu.lines">
                                            <xsl:variable name="pos" select="position()" as="xs:integer"/>
                                            <xsl:if test="starts-with(.,'          - id:')">
                                                <xsl:variable name="id" select="substring-after(.,'id: ')" as="xs:string"/>
                                                <!-- attention: white space is important in the following two lines!!! -->
                                                <xsl:variable name="label" select="replace(substring-after($submenu.lines[position() gt $pos][starts-with(., '            label:')][1],' label: '),$tick,'')" as="xs:string"/>
                                                <xsl:variable name="url" select="replace(substring-after($submenu.lines[position() gt $pos][starts-with(., '            url:')][1],' url: '),$tick,'')" as="xs:string"/>
                                                <page id="{$id}" level="2" label="{$label}" url="{$url}"/>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </xsl:when>
                                    <xsl:when test="$next.submenu.pos lt $next.page.pos">
                                        <xsl:variable name="submenu.lines" select="$menu.lines[position() gt $next.submenu.pos][position() lt $next.page.pos]" as="xs:string+"/>
                                        <xsl:for-each select="$submenu.lines">
                                            <xsl:variable name="pos" select="position()" as="xs:integer"/>
                                            <xsl:if test="starts-with(.,'          - id:')">
                                                <xsl:variable name="id" select="substring-after(.,'id: ')" as="xs:string"/>
                                                <!-- attention: white space is important in the following two lines!!! -->
                                                <xsl:variable name="label" select="replace(substring-after($submenu.lines[position() gt $pos][starts-with(., '            label:')][1],' label: '),$tick,'')" as="xs:string"/>
                                                <xsl:variable name="url" select="replace(substring-after($submenu.lines[position() gt $pos][starts-with(., '            url:')][1],' url: '),$tick,'')" as="xs:string"/>
                                                <page id="{$id}" level="2" label="{$label}" url="{$url}"/>
                                            </xsl:if>
                                        </xsl:for-each>
                                    </xsl:when>
                                </xsl:choose>                                       
                            </page>
                        </xsl:if>                        
                    </xsl:for-each>
                </xsl:variable>
                
                <div class="headerBar">
                    <!--
                    <header class="navbar">
                        <div class="navbar-section">
                            <a class="navbar-brand" href="http://music-encoding.org">
                                <img src="http://music-encoding.org/pix/meilogo-inverted.png" alt="MEI logo"/>
                            </a>
                            <div class="hide-lg">
                                <xsl:for-each select="$menu/self::page">
                                    <div class="dropdown dropdownCustomMenuToggle">                                    
                                        <a href="{if(child::page) then('#') else('https://music-encoding.org' || @url)}" class="btn btn-link dropdown-toggle top-menu-link" tabindex="{position()}">
                                            <xsl:value-of select="@label"/> <xsl:if test="child::page"> <i class="icon icon-caret"></i></xsl:if>
                                        </a>
                                        <xsl:if test="child::page">
                                            <ul class="menu">
                                                <xsl:for-each select="child::page">
                                                    <li class="menu-item">
                                                        <a href="https://music-encoding.org{@url}" class="btn btn-link text-left menu-link">
                                                            <xsl:value-of select="@label"/>
                                                        </a>
                                                    </li>
                                                </xsl:for-each>
                                            </ul>
                                        </xsl:if>
                                    </div>
                                </xsl:for-each>    
                            </div>
                        </div>
                        <div class="navbar-section" id="socialLinks">
                            <a class="twitterLink" target="_blank" href="https://twitter.com/MusicEncoding">
                                <img src="http://music-encoding.org/pix/twitter.png" alt="Twitter" class="logo"/>
                            </a>
                            <a class="githubLink" target="_blank" href="https://github.com/music-encoding">
                                <img src="http://music-encoding.org/pix/github.png" alt="GitHub" class="logo"/>
                            </a>
                            <a class="slackLink" target="_blank" href="https://music-encoding.slack.com/">
                                <img src="http://music-encoding.org/pix/slack.png" alt="Slack" class="logo"/>
                            </a>
                        </div>
                        <div id="menu-accordion" class="accordion-container dropdown-toggle show-lg column col-12">
                            <div class="accordion">
                                <input id="accordion-toggle" type="checkbox" name="accordion-checkbox" hidden=""/>
                                <label class="accordion-header c-hand" for="accordion-toggle">
                                    <i class="icon icon-menu"></i>
                                </label>
                                
                                <div class="accordion-body">
                                    <ul class="menu menu-nav">
                                        <xsl:for-each select="$menu/self::page">
                                            <li class="menu-item">
                                                <div class="accordion menu">
                                                    <input id="accordion-About" type="checkbox" name="accordion-checkbox" hidden=""/>
                                                    <label class="accordion-header c-hand" for="accordion-About">
                                                        <xsl:choose>
                                                            <xsl:when test="child::page"><xsl:value-of select="@label"/></xsl:when>
                                                            <xsl:otherwise><a href="https://music-encoding.org{@url}"><xsl:value-of select="@label"/></a></xsl:otherwise>
                                                        </xsl:choose>
                                                        
                                                    </label>
                                                    <xsl:if test="child::page">
                                                        <div class="accordion-body">
                                                            <ul class="menu menu-nav">
                                                                <xsl:for-each select="child::page">
                                                                    <li class="menu-item"><a href="https://music-encoding.org{@url}"><xsl:value-of select="@label"/></a></li>
                                                                </xsl:for-each>
                                                            </ul>
                                                        </div>
                                                    </xsl:if>
                                                </div>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </header>
                    <div id="versionWarning" class="p-sticky">
                        This is version $outdated$ of the MEI Guidelines. Switch to current release <a href="$current-link$">$current$</a>. 
                        <!-\- This is the development version of the MEI Guidelines. Switch to current release <a href="$current-link$">$current$</a>.  -\->
                    </div>
                    -->
                </div>
                                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
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
            <xsl:choose>
                <xsl:when test="$facet.type != 'usedBy'">
                    <ul class="tab">
                        <xsl:for-each select="$tabs">
                            <li class="tab-item">
                                <a data-display="{@id}" 
                                    id="{@id}_tab"
                                    href="#{@id}_tab"
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
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="group" mode="get.website.classTab"/>
                </xsl:otherwise>
            </xsl:choose>
            
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
    
    
    <xsl:function name="tools:getMemberOrder" as="xs:string">
        <xsl:param name="ident" as="xs:string"/>
        <xsl:variable name="prefix" as="xs:string">
            <xsl:choose>
                <xsl:when test="$ident = $elements/@ident">1_</xsl:when>
                <xsl:when test="starts-with($ident,'model.')">2_</xsl:when>
                <xsl:when test="starts-with($ident,'att.')">3_</xsl:when>
                <xsl:otherwise>5_</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="$prefix || $ident"/>
    </xsl:function>
    
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
                    <xsl:for-each select="$div//item/desc/span['ident' = tokenize(@class,' ')]"><xsl:sort select="text()"/><xsl:if test="position() gt 1">, </xsl:if><xsl:sequence select="."/></xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$div/descendant-or-self::div[@class='textualContent']">
                        <span class="textualContent" title="textual content">textual content, </span>
                    </xsl:if>
                    
                    <xsl:variable name="deduplicated" as="node()*">
                        <xsl:variable name="uniqueIdents" select="distinct-values($div//item/link/node()/text())" as="xs:string*"/>
                        <xsl:for-each select="$uniqueIdents">
                            <xsl:sort select="tools:getMemberOrder(.)"/>
                            <xsl:variable name="currentIdent" select="." as="xs:string"/>
                            <xsl:sequence select="($div//item/link/node()[text() = $currentIdent])[1]"/>
                        </xsl:for-each>
                    </xsl:variable>
                    
                    <xsl:for-each select="$deduplicated"><xsl:if test="position() gt 1">, </xsl:if><xsl:copy>
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
            <xsl:for-each select="child::item[@class='attribute']">
                <div class="attributeRef">
                    <span class="ident attribute"><xsl:value-of select="child::link/text()"/></span>
                    <span class="desc"><xsl:apply-templates select="child::desc/node()" mode="get.website"/></span>
                </div>
            </xsl:for-each>
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
            
            <xsl:if test="$div/descendant-or-self::div[@class='textualContent']">
                <div class="textualContent" title="textual content">textual content</div>
            </xsl:if>
            
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
                            <xsl:sort select="@ident"/>
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
        
        <xsl:if test="$div/descendant-or-self::div[@class='textualContent']">
            <div class="textualContent" title="textual content">textual content</div>
        </xsl:if>
        
        <div id="{$facet.type}_full" class="facetTabbedContent full" data-label="full definition">
            <xsl:for-each select="$div//item">
                <xsl:sort select="@ident" data-type="text"/>
                <xsl:variable name="current.item" select="." as="node()"/>
                <xsl:variable name="start" select="ancestor::section/h2/@id" as="xs:string"/>
                
                <xsl:variable name="end" select="'@' || $current.item/@ident" as="xs:string">
                    
                </xsl:variable>
                <div class="classItem attributeDef">
                    <div class="desc"><xsl:apply-templates select="$current.item/desc/node()" mode="get.website"/></div>
                    <div class="breadcrumb">
                        <span class="step start">&lt;<xsl:value-of select="$start"/>&gt;</span>
                        <xsl:for-each select="$current.item/ancestor::group/link">
                            <span class="step">
                                <xsl:apply-templates select="node()" mode="get.website"/></span>
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
                <xsl:when test="'link_odd_elementSpec' = $classes and not(matches(.,'https?://'))">
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
    
    <xd:doc>
        <xd:desc>
            <xd:p>Adjusts specLists in the Guidelines to Spectre tiles</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="ul[@class='specList']" mode="get.website">
        <!-- 
            <li class="specDesc">
                <span class="specList-elementSpec">
                    <a class="link_odd link_odd_elementSpec" href="../elements/app.html">app</a>
                </span>(apparatus) – Contains one or more alternative encodings.
            </li> -->
        <!-- 
            <li class="specDesc">
              <table class="specDesc">
                 <tbody>
                    <tr>
                       <td class="Attribute"><span class="att"><a class="link_odd link_odd_attClass" href="../attribute-classes/att.evidence.html">cert</a></span></td>
                       <td>Signifies the degree of certainty or precision associated with a feature.</td>
                    </tr>
                 </tbody>
              </table>
           </li>
        -->
        <xsl:for-each select="li[@class='specDesc']">
            
            <xsl:choose>
                <xsl:when test="span/@class='specList-elementSpec'">
                    
                    <div class="tile tile-centered">
                        <div class="tile-icon">
                            <div class="example-tile-icon">
                                <i class="icon icon-resize-horiz centered"></i>
                            </div>
                        </div>
                        <div class="tile-content">
                            <div class="tile-title">
                                <xsl:apply-templates select=".//span[@class='specList-elementSpec']" mode="#current"/>
                            </div>
                            <div class="tile-subtitle text-gray">
                                <xsl:apply-templates select=".//span[@class='specList-elementSpec-desc']"/>
                            </div>
                        </div>
                    </div>
                    
                </xsl:when>
                <xsl:when test=".//@class='Attribute'">
                    <xsl:for-each select=".//tr">
                        <div class="tile tile-centered">
                            <div class="tile-icon">
                                <div class="example-tile-icon">
                                    <span class="font-icon centered">@</span>
                                </div>
                            </div>
                            <div class="tile-content">
                                <div class="tile-title">
                                    <xsl:apply-templates select="td[1]/node()" mode="#current"/>
                                </div>
                                <div class="tile-subtitle text-gray">
                                    <xsl:apply-templates select="td[2]/node()" mode="#current"/>
                                </div>
                            </div>
                        </div>
                    </xsl:for-each>
                    
                </xsl:when>
                <xsl:otherwise>
                    <!-- some other reference, treated similarly to elements for now -->
                    <xsl:message select="'better have an eye on this:'"/>
                    <xsl:message select="."/>
                    <div class="tile tile-centered">
                        <div class="tile-icon">
                            <div class="example-tile-icon">
                                <i class="icon icon-link centered"></i>
                            </div>
                        </div>
                        <div class="tile-content">
                            <div class="tile-title">
                                <xsl:apply-templates select=".//a" mode="#current"/>
                            </div>
                            <div class="tile-subtitle text-gray">
                                <xsl:apply-templates select="text()"/>
                            </div>
                        </div>
                    </div>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Adjusts definition lists / gloss lists for the website</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="dl" mode="get.website">
        <xsl:for-each select="dt">
            <p class="gloss">
                <strong><xsl:apply-templates select="node()" mode="#current"/></strong>:
                <xsl:apply-templates select="following-sibling::dd[1]/node()" mode="#current"/>
            </p>
        </xsl:for-each>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Adjusts image links for website output</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="img/@src" mode="get.website">
        <xsl:choose>
            <xsl:when test="starts-with(., 'http')">
                <xsl:attribute name="src" select="."/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="src" select="'../' || substring(., 3)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>
