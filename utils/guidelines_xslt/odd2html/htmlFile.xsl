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
    <xsl:template name="getSinglePage">
        <xsl:param name="contents" as="node()*"/>
        <xsl:param name="media" as="xs:string"/>
        
        <html xml:lang="en">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
                <xsl:comment>THIS FILE IS GENERATED FROM AN XML MASTER. DO NOT EDIT!</xsl:comment>
                <title>Music Encoding Initiative Guidelines</title>
                <meta name="author" content="Johannes Kepper" />
                <meta name="author" content="Perry D. Roland" />
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
                            href="css/mei-print.css" />
                        <link rel="stylesheet" media="print" type="text/css"
                            href="css/mei.css" />
                    </xsl:when>
                    <xsl:when test="$media = 'screen'">
                        <link rel="stylesheet" media="screen" type="text/css"
                            href="../css/mei-website.css" />
                        <link rel="stylesheet" media="screen" type="text/css"
                            href="../css/mei-screen.css" />                        
                    </xsl:when>
                    
                    
                </xsl:choose>
            </head>
            <body class="simple" id="TOP">
                <xsl:if test="$media = 'screen'">
                    <xsl:sequence select="$websiteMenu"/>    
                </xsl:if>
                <xsl:sequence select="$contents"/>
                <xsl:if test="$media = 'screen'">
                    <script type="text/javascript">
                        const tabbedFacets = document.querySelectorAll('.facet ul.tab');
                        
                        const tabClick = function(e) {
                            const style = e.target.getAttribute('data-display');
                            const facetId = e.target.parentNode.parentNode.parentNode.parentNode.id;
                            console.log('clicked at ' + facetId + ' with style ' + style)
                            setTabs(facetId,style)
                        }
                        
                        console.log('Javascript is working…')
                        
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
                            
                            console.log('setting tabs, storageName: ' + storageName + ', facetId: ' + facetId + ', style: ' + style)
                            
                            const facetElem = document.getElementById(facetId);
                            
                            console.log(facetElem)
                            
                            const oldTab = facetElem.querySelector('.displayTab.active');
                            oldTab.classList.remove('active');
                            
                            console.log('trying to find newTab: "' + style + '_tab"');
                            
                            const newTab = document.getElementById(style + '_tab');
                            newTab.classList.add('active');
                            
                            console.log('\noldTab / newTab:')
                            console.log(oldTab)
                            console.log(newTab)
                            
                            const oldBox = facetElem.querySelector('.active.facetTabbedContent');
                            oldBox.classList.remove('active');
                            oldBox.style.display = 'none';
                            
                            const newBox = document.getElementById(style);
                            newBox.classList.add('active');
                            newBox.style.display = 'block';      
                            
                            console.log('\noldBox / newBox:')
                            console.log(oldBox)
                            console.log(newBox)
                        }
                    </script>
                </xsl:if>
            </body>
        </html>
    </xsl:template>
    
</xsl:stylesheet>