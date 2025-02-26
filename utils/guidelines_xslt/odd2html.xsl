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
            <xd:p><xd:b>Created on:</xd:b> Nov 11, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This XSLT generates a single HTML file from the MEI ODD sources. This single HTML file 
                may be used for further processing, either towards a PDF file, or towards a publication
                on the MEI website, which requires a separation into multiple files.</xd:p>
            <xd:p>TODO: We should consider to have additional data dictionaries (just the specs part)
                as separate files for each MEI customization.</xd:p>
            <xd:p>It is based on older XSLTs that were built for similar tasks.</xd:p>
            <xd:p>This file holds the main templates and drives the conversion process. Several other files are 
                included which focus on specific tasks:
            <xd:ul>
                <xd:li>
                    <xd:b>odd2html/config.xsl</xd:b>: 
                    This file holds configuration options for the XSLT, mostly output paths.
                </xd:li>
                <xd:li>
                    <xd:b>odd2html/globalVariables.xsl</xd:b>: 
                    This file holds preprocessed variables, like all elements, which are made available throughout 
                    the XSLT.
                </xd:li>
                <xd:li>
                    <xd:b>odd2html/functions.xsl</xd:b>: 
                    Loaded from globalVariables.xsl, this file holds generic functions which will adjust image paths
                    and do similar generic tasks.
                </xd:li>
                <xd:li>
                    <xd:b>odd2html/guidelines.xsl</xd:b>: 
                    This file holds templates that will translate TEI ODD into HTML. This is where the chapters
                    of the Guidelines are translated.
                </xd:li>
                <xd:li>
                    <xd:b>odd2html/renderXML.xsl</xd:b>: 
                    This file holds templates to render XML snippets into HTML examples.
                </xd:li>
                <xd:li>
                    <xd:b>odd2html/htmlFile.xsl</xd:b>: 
                    This file holds a skeleton for an HTML file.
                </xd:li>
                <xd:li>
                    <xd:b>odd2html/specs/genericSpecFunctions.xsl</xd:b>: 
                    Here, most functions for generating the spec pages are stored. This is where parent and child elements
                    are identified, plus more. 
                </xd:li>
                <xd:li>
                    <xd:b>odd2html/specs/moduleSpecs.xsl</xd:b>: 
                    This is where moduleSpecs are handled. 
                </xd:li>
                <xd:li>
                    <xd:b>odd2html/specs/elementSpecs.xsl</xd:b>: 
                    This is where elementSpecs are handled. 
                </xd:li>
                <xd:li>
                    <xd:b>odd2html/specs/modelClassSpecs.xsl</xd:b>: 
                    This is where model classes are handled. 
                </xd:li>
                <xd:li>
                    <xd:b>odd2html/specs/macroGroupSpecs.xsl</xd:b>: 
                    This is where macro groups are handled. 
                </xd:li>
                <xd:li>
                    <xd:b>odd2html/specs/attClassSpecs.xsl</xd:b>: 
                    This is where attribute classes are handled. 
                </xd:li>
                <xd:li>
                    <xd:b>odd2html/specs/dataTypeSpecs.xsl</xd:b>: 
                    This is where data types are handled. 
                </xd:li>
                <xd:li>
                    <xd:b>odd2html/generateWebsite.xsl</xd:b>: 
                    This holds code for extracting the website version from a single HTML page. 
                </xd:li>
                <xd:li>
                    <xd:b>odd2html/preparePDF.xsl</xd:b>: 
                    This holds code for polishing the HTML output for PDF publication. 
                </xd:li>
                <xd:li>
                    <xd:b>odd2html/prepareLiveExample.xsl</xd:b>: 
                    This prepares examples that are to be rendered for inclusion in the Guidelines. 
                </xd:li>
                <xd:li>
                    <xd:b>odd2html/generateSearchIndex.xsl</xd:b>: 
                    This holds code for preparing the search function on the website. 
                </xd:li>
            </xd:ul></xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:output indent="yes" method="xhtml"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The version of the Guidelines</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="version" select="tokenize(//tei:edition, ' ')[last()]" as="xs:string"/>
        
    <xd:doc>
        <xd:desc>
            <xd:p>The git commit hash of the version this is generated from. Should not be set manually.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="hash" select="'latest'" as="xs:string"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The git branch of the repo</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="branch" select="'develop'" as="xs:string"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The base directory handed over from Ant. Should not be set when the XSLT is called locally.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="basedir" select="''" as="xs:string"/>
    
    <xsl:variable name="source.file" select="/tei:TEI" as="node()"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The (computed) head branch of the repo for which documentation will be generated.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="git.head" as="xs:string">
        <xsl:choose>
            <xsl:when test="$hash eq 'latest'">
                <xsl:variable name="git.path" select="substring-before(string(document-uri(/)),'/source/mei-source.xml') || '/.git/'" as="xs:string"/>
                <xsl:value-of select="normalize-space(substring-after(unparsed-text($git.path || 'HEAD'),'ref: '))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$branch"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The (computed) git hash of the repo.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="retrieved.hash" as="xs:string">
        <xsl:choose>
            <xsl:when test="$hash eq 'latest'">
                <xsl:variable name="git.path" select="substring-before(string(document-uri(/)),'/source/mei-source.xml') || '/.git/'" as="xs:string"/>
                <xsl:value-of select="unparsed-text($git.path || $git.head) || ''"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$hash"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:include href="odd2html/config.xsl"/>
    <xsl:include href="odd2html/globalVariables.xsl"/>
    <xsl:include href="odd2html/guidelines.xsl"/>
    <xsl:include href="odd2html/renderXML.xsl"/>
    <xsl:include href="odd2html/htmlFile.xsl"/>
    
    <xsl:include href="odd2html/specs/genericSpecFunctions.xsl"/>
    <xsl:include href="odd2html/specs/moduleSpecs.xsl"/>
    <xsl:include href="odd2html/specs/elementSpecs.xsl"/>
    <xsl:include href="odd2html/specs/modelClassSpecs.xsl"/>
    <xsl:include href="odd2html/specs/macroGroupSpecs.xsl"/>
    <xsl:include href="odd2html/specs/attClassSpecs.xsl"/>
    <xsl:include href="odd2html/specs/dataTypeSpecs.xsl"/>
    
    <xsl:include href="odd2html/generateWebsite.xsl"/>
    <xsl:include href="odd2html/preparePDF.xsl"/>
    
    <xsl:include href="odd2html/generateSearchIndex.xsl"/>
    
    <xsl:include href="odd2html/prepareLiveExamples.xsl"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>The main method of this stylesheet</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:message select="'Processing MEI v' || $version || ' from branch ' || $git.head ||' at revision ' || $retrieved.hash || ' with odd2html.xsl on ' || substring(string(current-date()),1,10)"/>
        <xsl:message select="'.   chapters: ' || count($chapters) || ' (' || count($all.chapters/descendant-or-self::chapter) || ' subchapters)'"/>
        <xsl:message select="'.   elements: ' || count($elements)"/>
        <xsl:message select="'.   model classes: ' || count($model.classes)"/>
        <xsl:message select="'.   attribute classes: ' || count($att.classes)"/>
        <xsl:message select="'.   data types: ' || count($data.types)"/>
        <xsl:message select="'.   macro groups: ' || count($macro.groups)"/>
        
        <xsl:variable name="preface" select="tools:generatePreface()" as="node()+"/>
        <xsl:variable name="toc" select="tools:generateToc()" as="node()"/>
        <xsl:variable name="guidelines" as="node()">
            <main>
                <xsl:apply-templates select="$mei.source//tei:body/child::tei:div" mode="guidelines"/>                
            </main>
        </xsl:variable>
        <xsl:variable name="moduleSpecs" select="tools:getModuleSpecs()" as="node()"/>
        <xsl:variable name="elementSpecs" select="tools:getElementSpecs()" as="node()"/>
        <xsl:variable name="modelClassSpecs" select="tools:getModelClassSpecs()" as="node()"/>
        <xsl:variable name="macroGroupSpecs" select="tools:getMacroGroupSpecs()" as="node()"/>
        <xsl:variable name="attClassSpecs" select="tools:getAttClassSpecs()" as="node()"/>
        <xsl:variable name="dataTypeSpecs" select="tools:getDataTypeSpecs()" as="node()"/>
        
        <xsl:variable name="indizes" select="tools:generateIndizes()" as="node()+"/>
            
        
        
        <xsl:variable name="contents" as="node()*">
            <xsl:sequence select="$preface"/>
            <xsl:sequence select="$toc"/>
            <xsl:sequence select="$guidelines"/>
            
            <xsl:sequence select="$moduleSpecs"/>
            <xsl:sequence select="$elementSpecs"/>
            <xsl:sequence select="$modelClassSpecs"/>
            <xsl:sequence select="$macroGroupSpecs"/>
            <xsl:sequence select="$attClassSpecs"/>
            <xsl:sequence select="$dataTypeSpecs"/>
            
            <xsl:sequence select="$indizes"/>
        </xsl:variable>
                
        <!-- generate a single-page HTML version of the Guidelines -->
        <xsl:variable name="singlePage" as="node()+">
            <xsl:call-template name="getSinglePage">
                <xsl:with-param name="contents" select="$contents" as="node()*"/>
                <xsl:with-param name="media" select="'print'"/>
            </xsl:call-template>
        </xsl:variable>
        
        <!-- retrieve multiple HTML files for online publication -->
        <xsl:call-template name="prepareLiveExamples">
            <xsl:with-param name="guidelinesSources" select="$mei.source//tei:body/child::tei:div"/>
        </xsl:call-template>
        
        <!-- retrieve multiple HTML files for online publication -->
        <xsl:call-template name="generateWebsite">
            <xsl:with-param name="input" select="$singlePage"/>
        </xsl:call-template>
        
        
        <!--<xsl:result-document href="{$output.folder}MEI_Guidelines_v{$version}_{$hash}_raw.html">
            <xsl:sequence select="$singlePage"/>
        </xsl:result-document>-->
        
        <xsl:result-document href="{$build.folder || $pdf.file.name}.html">
            <xsl:apply-templates select="$singlePage" mode="preparePDF"/>
        </xsl:result-document>
        
    </xsl:template>
    
    <!-- Generic templates down here -->
    
    <xd:doc>
        <xd:desc>
            <xd:p>Arbitrary tei-Elements</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:*" mode="#all">
        <xsl:message select="'DEBUG: processing tei:' || local-name()"/>
        <span class="{local-name()}">
            <xsl:apply-templates select="child::node()" mode="#current"/>
        </span>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Arbitrary rng-Elements</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="rng:*" mode="#all">
        <xsl:message select="'DEBUG: processing rng:' || local-name()"/>
        <span class="{local-name()}">
            <xsl:apply-templates select="node()" mode="#current"/>
        </span>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Generic copy template</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>