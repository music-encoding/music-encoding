<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:map="http://www.w3.org/2005/xpath-functions/map" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs math xd map mei" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jun 2, 2025</xd:p>
            <xd:p><xd:b>Author:</xd:b> Benjamin W. Bohl</xd:p>
            <xd:p><xd:b>Author:</xd:b> Stefan Münnich</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:import href="../odd2html.xsl"/>

    <xsl:param name="customizationIndexPages" as="xs:string"/>
    
    <xsl:param name="output.folder" as="xs:string"/>
    
    <xsl:variable name="source.file" select="doc('../../../source/mei-source.xml')/tei:TEI" as="node()"/>

    <xsl:param name="version" as="xs:string" select="$source.file//tei:editionStmt/tei:edition"/>
    
    <xsl:variable name="isCompiledOdd" select="xs:boolean('false')" as="xs:boolean" />
    
    <xsl:variable name="all-customizations" as="map(*)*" >
        <xsl:for-each select="tokenize($customizationIndexPages, ';')">
            <xsl:variable name="path" select="." as="xs:string"/>
            <xsl:variable name="customizationName" select="tokenize(., '/')[1]" as="xs:string"/>
            <xsl:variable name="node" select="doc('../../../customizations/' || $customizationName || '.xml')/tei:TEI" as="node()"/>
            <xsl:map>
                <xsl:map-entry key="'name'" select="$customizationName"/>
                <xsl:map-entry key="'node'" select="$node"/>
                <xsl:map-entry key="'path'" select="."/>
                <xsl:map-entry key="'group'" select="mei:getCustomizationGroupingKey($node)"/>
            </xsl:map>
        </xsl:for-each>
    </xsl:variable>
    
    <xsl:function name="mei:getCustomizationGroupHeading">
        <xsl:param name="groupingKey" as="xs:integer" required="yes"/>
        <xsl:choose>
            <xsl:when test="$groupingKey = 1">
                <xsl:text>Special Purpose Customizations</xsl:text>
            </xsl:when>
            <xsl:when test="$groupingKey = 2">
                <xsl:text>All-Inclusive MEI Customizations (Use Only for Testing or Validation)</xsl:text>
            </xsl:when>
            <xsl:when test="$groupingKey = 3">
                <xsl:text>Other Customizations</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="mei:getCustomizationGroupingKey" as="xs:integer">
        <xsl:param name="customization" required="yes"/>
        <xsl:choose>
            <xsl:when test="$customization//tei:profileDesc/tei:textClass/tei:keywords/tei:term = ('repertoire', 'interchange', 'interoperability')">1</xsl:when>
            <xsl:when test="$customization//tei:profileDesc/tei:textClass/tei:keywords/tei:term = ('testing', 'validation')">2</xsl:when>
            <xsl:otherwise>3</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:template name="initial-template">
        <xsl:result-document href="{string-join(($output.folder, 'index.html'), '/')}">
            <xsl:variable name="contents">
                <xsl:element name="h2">Guidelines for the MEI Customizations</xsl:element>
                <xsl:for-each-group select="$all-customizations" group-by="map:get(.,'group')">
                    <xsl:sort select="current-grouping-key()" order="ascending" />
                    <xsl:element name="h4"><xsl:value-of select="mei:getCustomizationGroupHeading(current-grouping-key())"/></xsl:element>
                    <xsl:element name="div">
                        <xsl:attribute name="class">columns filter-body projects</xsl:attribute>
                        <xsl:for-each select="current-group()">
                            <xsl:call-template name="generate-customization-card">
                                <xsl:with-param name="customization" select="." />
                            </xsl:call-template>
                        </xsl:for-each>
                    </xsl:element>
                </xsl:for-each-group>
            </xsl:variable>

            <xsl:call-template name="getSinglePage">
                <xsl:with-param name="contents" select="$contents" as="node()*"/>
                <xsl:with-param name="media" select="'screen'"/>
                <xsl:with-param name="reducedLevels" select="xs:boolean('true')"/>
                <xsl:with-param name="skipSideNav" select="xs:boolean('true')"/>
            </xsl:call-template>
            
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="generate-customization-card">
        <xsl:param name="customization" as="map(*)" required="yes"/>
        <xsl:param name="customizationNode" select="map:get($customization, 'node')" as="node()"/>
        <xsl:element name="div">
            <xsl:attribute name="class">column col-4 col-sm-12 col-lg-6 filter-item</xsl:attribute>
            <xsl:element name="div">
                <xsl:attribute name="class">card project</xsl:attribute>
                <xsl:element name="div">
                    <xsl:attribute name="class">card-header</xsl:attribute>
                    <xsl:element name="div">
                        <xsl:attribute name="class">card-title h5</xsl:attribute>
                        <xsl:value-of select="($customizationNode//tei:fileDesc/tei:titleStmt/tei:title[@type='short'], map:get($customization, 'name'))[1]"/>
                    </xsl:element>
                    <xsl:element name="div">
                        <xsl:attribute name="class">card-subtitle text-gray</xsl:attribute>
                        <xsl:apply-templates select="$customizationNode//tei:profileDesc/tei:abstract/tei:p" mode="guidelines"/>
                    </xsl:element>
                </xsl:element>
                <xsl:element name="div">
                    <xsl:attribute name="class">card-footer</xsl:attribute>
                    <xsl:element name="a">
                        <xsl:attribute name="class">btn float-right btn-sm</xsl:attribute>
                        <xsl:attribute name="href" select="map:get($customization, 'path')"/>
                        <xsl:text>Proceed to Guidelines…</xsl:text>
                    </xsl:element>
                    <xsl:for-each select="$customizationNode//tei:profileDesc/tei:textClass/tei:keywords/tei:term">
                        <xsl:element name="label">
                            <xsl:attribute name="class">chip</xsl:attribute>
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:for-each>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Element references</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:gi" mode="guidelines">
        <xsl:variable name="text" select="string(text())" as="xs:string"/>
        <xsl:value-of select="."/>
    </xsl:template>
    
</xsl:stylesheet>
