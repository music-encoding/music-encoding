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
    xmlns:search="temp.search"
    exclude-result-prefixes="xs math xd xhtml tei tools search rng sch egx"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Nov 12, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This file holds the skeleton for an HTML file, which is populated with the translated Guidelines.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This is a skeleton for an HTML file</xd:p>
        </xd:desc>
        <xd:param name="contents">Everything that is supposed to be inserted into the file</xd:param>
        <xd:param name="media">The medium for which this file is intended</xd:param>
    </xd:doc>
    <xsl:template name="getSinglePage" >
        <xsl:param name="contents" as="node()*"/>
        <xsl:param name="media" as="xs:string"/>
        <xsl:param name="reducedLevels" as="xs:boolean?"/>
        
        <xsl:variable name="output.path" select="if($reducedLevels) then('') else('../')" as="xs:string"/>
        <html lang="en">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
                <xsl:comment>THIS FILE IS GENERATED FROM AN XML TEMPLATE. DO NOT EDIT!</xsl:comment>
                <title>Music Encoding Initiative Guidelines</title>
                <xsl:for-each select="$source.file//tei:respStmt/tei:name[@role='pbd']/normalize-space(text())">
                    <meta name="author" content="{.}"/>
                </xsl:for-each>
                <meta name="subject" content="Documentation for the Music Encoding Initiative (MEI) Data Model" />
                <meta name="keywords" content="Music Encoding, MEI, Digital Humanities, Musicology, Music Librarianship, Music Information Retrieval" />
                <meta name="date" content="{substring(string(current-date()),1,10)}" />
                <meta name="generator" content="MEI XSLT stylesheets" />
                <meta name="DC.Title" content="Music Encoding Initiative Guidelines" />
                <meta name="DC.Type" content="Text" />
                <meta name="DC.Format" content="text/html" />
                <xsl:choose>
                    <xsl:when test="$media = 'print'">
                        <link rel="stylesheet" media="print" type="text/css"
                            href="{$assets.folder.css.print}mei-print.css" />
                        <link rel="stylesheet" media="print" type="text/css"
                            href="{$assets.folder.css.print}mei.css" />
                    </xsl:when>
                    <xsl:when test="$media = 'screen'">
                        <link rel="stylesheet" media="screen" type="text/css"
                            href="{$output.path}{$assets.folder.css.screen}search.css" />
                        <link rel="stylesheet" media="screen" type="text/css"
                            href="{$output.path}{$assets.folder.css.screen}mei-website.css" />
                        <link rel="stylesheet" media="screen" type="text/css"
                            href="{$output.path}{$assets.folder.css.screen}mei-screen.css" />
                        <script src="{$output.path}{$assets.folder.js}searchIndex.js"></script>
                        <script src="{$output.path}{$assets.folder.js}fuse.min.js"></script>
                    </xsl:when>
                </xsl:choose>
            </head>
            <body class="simple" id="TOP">
                
                <xsl:choose>
                    <!-- a lot of adjustments is necessary for website generation -->
                    <xsl:when test="$media = 'screen'">
                        
                        <xsl:variable name="pageMenu" as="node()?">
                            <xsl:if test="$contents/@class='div1'">
                                <!-- generate pageMenu only when on a guidelines chapter, but not for spec pages -->
                                <p class="sectionToc sticky">
                                    <xsl:for-each select="$contents//(h2 | h3)">
                                        <xsl:variable name="title" select="string-join(.//text(), ' ')" as="xs:string"/>
                                        <xsl:variable name="level" select="if(local-name() = 'h2') then('level-2') else('level-3')" as="xs:string"/>
                                        <a class="{$level}" href="#{@id}"><xsl:value-of select="$title"/></a>
                                    </xsl:for-each>
                                </p>
                            </xsl:if>
                            
                        </xsl:variable>
                        
                        
                        <xsl:sequence select="$websiteMenu"/>
                        <div class="container-fluid content">
                            <div class="columns specsLayout">
                                <div class="top-navigation column col-md-12 show-md">
                                    <div class="top-navigation-header columns">
                                        <div class="buttonbox">
                                            <button class="btn btn-action btn-sm btn-primary" id="topNavigationShow"><i class="icon icon-menu"></i></button>
                                        </div>
                                        
                                        <div class="searchbox">
                                            
                                            <form><div class="search_group">
                                                <input id="search_inputTop" title="At least 3 characters" type="text"></input><button type="submit" id="submitSearchButtonTop" class="search_button"><span class="search_icon">⚲</span></button>
                                            </div></form>
                                            
                                        </div>
                                        
                                    </div>
                                </div>
                                <div class="column col-8 col-md-12">
                                    <div id="search-content"></div>
                                    <xsl:sequence select="$contents"/>    
                                </div>
                                <div class="column col-4 hide-md">
                                    <div id="guidelinesVersion">
                                        <span class="versionLabel">MEI Version: </span>
                                        <span id="versionID"><xsl:value-of select="$version"/> </span>
                                        <span class="gitLink">(<a href="https://github.com/music-encoding/music-encoding/commit/{$hash}" target="_blank" rel="noopener noreferrer">#<xsl:value-of select="substring($hash,1,7)"/></a>)</span>   
                                    </div>
                                    
                                    <form><div class="search_group">
                                        <input name="q" id="search_input" title="At least 3 characters" type="text"></input><button type="submit" id="submitSearchButtonSide" class="search_button"><span class="search_icon">⚲</span></button>
                                    </div></form>
                                    
                                    <ul class="nav"> 
                                        <li class="nav-item">
                                            <a href="{$output.path}content/index.html">Guidelines</a>
                                        </li>
                                        <li class="nav-item">
                                            <a href="{$output.path}modules.html">Modules</a>
                                        </li>
                                        <li class="nav-item">
                                            <a href="{$output.path}elements.html">Elements</a>
                                        </li>
                                        <li class="nav-item">
                                            <a href="{$output.path}model-classes.html">Model Classes</a>
                                        </li>
                                        <li class="nav-item">
                                            <a href="{$output.path}macro-groups.html">Macro Groups</a>
                                        </li>
                                        <li class="nav-item">
                                            <a href="{$output.path}attribute-classes.html">Attribute Classes</a>
                                        </li>
                                        <li class="nav-item">
                                            <a href="{$output.path}data-types.html">Data Types</a>
                                        </li>                                        
                                    </ul> 
                                    <div class="divider"></div>
                                    <xsl:sequence select="$pageMenu"/>                    
                                </div>        
                            </div>
                            <div class="modal" id="toc-modal">
                                <a href="#close" id="toc-modal-outer-close" class="modal-overlay" aria-label="Close"></a>
                                <div class="modal-container">
                                    <div class="modal-header">
                                        <a href="#close" id="toc-modal-inner-close" class="btn btn-clear float-right" aria-label="Close"></a>
                                        <div class="modal-title h5">Table of Contents</div>
                                    </div>
                                    <div class="modal-body">
                                        <div class="content">
                                            <ul class="nav"> 
                                                <li class="nav-item">
                                                    <a href="{$output.path}content/index.html">Guidelines</a>
                                                </li>
                                                <li class="nav-item">
                                                    <a href="{$output.path}modules.html">Modules</a>
                                                </li>
                                                <li class="nav-item">
                                                    <a href="{$output.path}elements.html">Elements</a>
                                                </li>
                                                <li class="nav-item">
                                                    <a href="{$output.path}model-classes.html">Model Classes</a>
                                                </li>
                                                <li class="nav-item">
                                                    <a href="{$output.path}macro-groups.html">Macro Groups</a>
                                                </li>
                                                <li class="nav-item">
                                                    <a href="{$output.path}attribute-classes.html">Attribute Classes</a>
                                                </li>
                                                <li class="nav-item">
                                                    <a href="{$output.path}data-types.html">Data Types</a>
                                                </li>                   
                                            </ul> 
                                            <div class="divider"></div>
                                            <xsl:sequence select="$pageMenu"/>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <script>
                                window.addEventListener("load", function(event) {
                                    document.getElementById('topNavigationShow').addEventListener('click',function(e) {
                                        var elem = document.getElementById('toc-modal');
                                        elem.classList.toggle('active');
                                    })
                                    document.getElementById('toc-modal-outer-close').addEventListener('click',function(e) {
                                        var elem = document.getElementById('toc-modal');
                                        elem.classList.toggle('active');
                                    })
                                    document.getElementById('toc-modal-inner-close').addEventListener('click',function(e) {
                                        var elem = document.getElementById('toc-modal');
                                        elem.classList.toggle('active');
                                    })
                                    
                                    function getMenu() {
                                        const fullVersion = '<xsl:value-of select="$version"/>'
                                        const version = (fullVersion.includes('-dev')) ? 'dev' : 'v' + fullVersion.split('.')[0];
                                        console.log('trying to get menu for version ' + version + ' (' + fullVersion + ')'); 
                                        
                                        const url = 'https://music-encoding.org/menus/' + version + '/menu.html';
                                        
                                        fetch(url)
                                            .then(function(response) { return response.text()})
                                            .then(function(doc) {
                                                let headerBar = document.querySelector('.headerBar');
                                                const parser = new DOMParser();
                                                const htmlDoc = parser.parseFromString(doc, 'text/html');
                                                const menu = htmlDoc.querySelector('.headerBar');
                                                headerBar.parentNode.replaceChild(menu, headerBar);
                                            });
                                    };
                                    getMenu();
                                        
                                });
                            </script>
                        </div>
                        
                        <div class="modal" id="searchResultsModal">
                            <a id="searchModalCloseBg" href="#" class="modal-overlay" aria-label="Close"></a>
                            <div class="modal-container">
                                <div class="modal-header">
                                    <button id="searchModalCloseLink" class="btn btn-clear float-right" aria-label="Close"></button>
                                    <div class="modal-title h5">Search Results for "<span id="searchPattern"></span>"</div>
                                </div>
                                <div class="modal-body">
                                    <div class="content" id="searchResultsBox">
                                        <!-- content here -->
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    <button class="btn" id="searchModalCloseBtn">Close</button>
                                </div>
                            </div>
                        </div>
                        
                        <script type="text/javascript">
                            const tabbedFacets = document.querySelectorAll('.facet ul.tab');
                            
                            const tabClick = function(e) {
                                const style = e.target.getAttribute('data-display');
                                const facetId = e.target.parentNode.parentNode.parentNode.parentNode.id;
                                //console.log('clicked at ' + facetId + ' with style ' + style)
                                setTabs(facetId,style)
                            }
                            
                            console.log('[INFO] Javascript initialized')
                            
                            for(let facetUl of tabbedFacets) {
                                const facetElem = facetUl.parentNode.parentNode;
                                const facetId = facetElem.id;
                                const storageName = 'meiSpecs_' + facetId + '_display';
                                const defaultValue = facetUl.children[0].children[0].getAttribute('data-display');
                                
                                if(localStorage.getItem(storageName) === null) {
                                    setTabs(facetElem.id,defaultValue);
                                } else {
                                    setTabs(facetElem.id,localStorage.getItem(storageName));
                                }
                                
                                const tabs = facetUl.querySelectorAll('.tab-item a');
                                
                                for(let tab of tabs) {
                                    tab.addEventListener('click',tabClick);
                                }                            
                            }
                            
                            function setTabs(facetId, style) {                            
                                const storageName = 'meiSpecs_' + facetId + '_display';
                                localStorage.setItem(storageName,style);
                                
                                const facetElem = document.getElementById(facetId);
                                
                                const oldTab = facetElem.querySelector('.displayTab.active');
                                oldTab.classList.remove('active');
                                
                                const newTab = document.getElementById(style + '_tab');
                                newTab.classList.add('active');
                                
                                const oldBox = facetElem.querySelector('.active.facetTabbedContent');
                                oldBox.classList.remove('active');
                                oldBox.style.display = 'none';
                                
                                const newBox = document.getElementById(style);
                                newBox.classList.add('active');
                                newBox.style.display = 'block';
                            }
                            
                            const reducedLevels = <xsl:value-of select="if($reducedLevels = true()) then('true') else('false')"/>;
                            <xsl:sequence select="search:getJavascript()"/>
                        </script>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- for PDF, things are pretty simple… -->
                        <xsl:sequence select="$contents"/>
                    </xsl:otherwise>
                </xsl:choose>
            </body>
        </html>
    </xsl:template>
    
</xsl:stylesheet>
