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
    </xd:doc>
    <xsl:template name="getSinglePage">
        <xsl:param name="contents" as="node()*"/>
        
        <html xml:lang="en">
            <head>
                <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
                <xsl:comment>THIS FILE IS GENERATED FROM AN XML MASTER. DO NOT EDIT!</xsl:comment>
                <title>Music Encoding Initiative Guidelines</title>
                <meta name="author" content="Perry D. Roland, Johannes Kepper" />
                <meta name="subject" content="Documentation for the Music Encoding Initiative (MEI) Data Model" />
                <meta name="keywords" content="Music Encoding, MEI, Digital Humanities, Music, Musicology, Music Librarianship, Music Information Retrieval" />
                <meta name="date" content="{substring(string(current-date()),1,10)}" />
                <meta name="generator" content="MEI XSLT stylesheets" />
                <meta name="DC.Title" content="Music Encoding Initiative Guidelines" />
                <meta name="DC.Type" content="Text" />
                <meta name="DC.Format" content="text/html" />
                <link rel="stylesheet" media="print" type="text/css"
                    href="css/mei-print.css" />
                <link rel="stylesheet" media="print" type="text/css"
                    href="css/mei.css" 
                     />
                
            </head>
            <body class="simple" id="TOP">
                <xsl:sequence select="$contents"/>
            </body>
        </html>
    </xsl:template>
    
</xsl:stylesheet>