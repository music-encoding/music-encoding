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
            <xd:p><xd:b>Created on:</xd:b> May 13, 2022</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>
                This file holds all relevant configuration options for the odd2html 
                transformation, mostly file paths.
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>This is a computed variable used to identify whether the source file has been 
                canonicalized upfront or not. Basically, it says whether the XSLT is run by Ant
                (canonicalized) or runs locally.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="source.is.canonicalized" as="xs:boolean">
        <xsl:variable name="document.uri.tokens" select="tokenize(document-uri(/),'/')" as="xs:string*"/>
        <xsl:choose>
            <xsl:when test="$document.uri.tokens[last() - 1] = 'build'">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:when test="$document.uri.tokens[last() - 1] = 'source'">
                <xsl:value-of select="false()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>This is a computed variable that cleans the basedir of the repo. Should 
                point to the top directory of the repo. All paths will be specified relative 
                to this.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="cleaned.basedir" as="xs:string">
        <xsl:choose>
            <xsl:when test="$basedir = '' and not($source.is.canonicalized)">
                <xsl:variable name="document.uri.tokens" select="tokenize(document-uri(/),'/')" as="xs:string*"/>
                <xsl:value-of select="string-join($document.uri.tokens[position() lt last() -1], '/') || '/'"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- todo: add some validation if that given $basedir really exists? -->
                <xsl:value-of select="$basedir || '/'"/>
            </xsl:otherwise>
        </xsl:choose>    
    </xsl:variable>

    <xd:doc>
        <xd:desc>
            <xd:p>Where to find the Guidelines files. This is necessary, as the XIncludes pulling in the chapters
                point to the bodies of those files, omitting the information about editors of the chapters stored
                in the headers of the respective TEI files. Hence, this goes back to the sources and opens those
                files independently again. See tools:generatePreface() in functions.xsl.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="docs.folder" select="collection($cleaned.basedir || 'source/docs')//tei:TEI" as="node()*"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The build folder, in which temporary assets are stored.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="build.folder" select="$cleaned.basedir || 'build/'" as="xs:string"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The folder, in which asset files are placed. Relative path.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="assets.folder.rel" select="'./assets/'" as="xs:string"/>

    <xd:doc>
        <xd:desc>
            <xd:p>Folder, in which the CSS files for print can be found. Necessary, as the PDF build artifact needs to
                point to the files in the assets folder.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="assets.folder.css.print" select="$assets.folder.rel || 'css/print/'" as="xs:string"/>

    <xd:doc>
        <xd:desc>
            <xd:p>Folder, in which the CSS files for screen can be found. Necessary, as the website build artifact needs to
                point to the files in the assets folder.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="assets.folder.css.screen" select="substring($assets.folder.rel, 3) || 'css/screen/'" as="xs:string"/>

    <xd:doc>
        <xd:desc>
            <xd:p>The folder, in which MEI files are placed that need to be turned into SVG images.
                Those images will eventually be placed in $dist.folder.generated.images. Relative path.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="assets.folder.generated.images.rel" select="$assets.folder.rel || 'images/GeneratedImages/'" as="xs:string"/>

    <xd:doc>
        <xd:desc>
            <xd:p>The folder, in which MEI files are placed that need to be turned into SVG images.
                Those images will eventually be placed in $dist.folder.generated.images. Absolute path.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="assets.folder.generated.images.abs" select="$build.folder || substring($assets.folder.generated.images.rel, 3)" as="xs:string"/>

    <xd:doc>
        <xd:desc>
            <xd:p>Folder, in which the JS files for screen can be found. Necessary, as the website build artifact needs to
                point to the files in the assets folder.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="assets.folder.js" select="substring($assets.folder.rel, 3) || 'js/'" as="xs:string"/>

    <xd:doc>
        <xd:desc>
            <xd:p>The dist folder, in which the final results of the XSLT are stored.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="dist.folder" select="$cleaned.basedir || 'dist/guidelines/dev/'" as="xs:string"/>

    <xd:doc>
        <xd:desc>
            <xd:p>The folder in which SVG images generated live from MEI are placed. Relative path.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="dist.folder.generated.images.rel" select="'./images/generated/'" as="xs:string"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The folder in which SVG images generated live from MEI are placed. Absolute path.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="dist.folder.generated.images.abs" select="$dist.folder || substring($dist.folder.generated.images.rel, 3)" as="xs:string"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The name of the resulting PDF file. Intentionally without file extension, as the same name is used
                for the HTML file generated to prepare the PDF.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="pdf.file.name" select="'MEI_Guidelines_v' || $version" as="xs:string"/>
</xsl:stylesheet>
