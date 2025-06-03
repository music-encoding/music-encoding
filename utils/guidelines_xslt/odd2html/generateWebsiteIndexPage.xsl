<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:tools="no:where" exclude-result-prefixes="xs math xd" version="3.0">
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
    
    <xsl:template name="initial-template">

        <xsl:result-document href="{string-join(($output.folder, 'index.html'), '/')}">

            <xsl:variable name="contents">

                <xsl:element name="div">
                    <xsl:attribute name="class">columns filter-body projects</xsl:attribute>

                    <xsl:for-each select="tokenize($customizationIndexPages, ';')">
                        
                        <xsl:variable name="customizationName" select="tokenize(., '/')[1]"/>
                        
                        <xsl:variable name="customization.file" select="doc('../../../customizations/' || $customizationName || '.xml')/tei:TEI" as="node()"/>

                        <xsl:element name="div">
                            <xsl:attribute name="class">column col-4 col-sm-12 col-lg-6 filter-item</xsl:attribute>

                            <xsl:element name="div">
                                <xsl:attribute name="class">card project</xsl:attribute>

                                <xsl:element name="div">
                                    <xsl:attribute name="class">card-header</xsl:attribute>
                                    <xsl:element name="div">
                                        <xsl:attribute name="class">card-title h5</xsl:attribute>
                                        <xsl:value-of select="($customization.file//tei:fileDesc/tei:titleStmt/tei:title[@type='short'], $customizationName)[1]"/>
                                    </xsl:element>
                                    <xsl:element name="div">
                                        <xsl:attribute name="class">card-subtitle text-gray</xsl:attribute>
                                        <xsl:apply-templates select="$customization.file//tei:fileDesc/tei:titleStmt/tei:title[@type='main']"/>
                                    </xsl:element>
                                </xsl:element>
                                
                                <xsl:element name="div">
                                    <xsl:attribute name="class">card-body</xsl:attribute>
                                    <xsl:apply-templates select="$customization.file//tei:profileDesc/tei:abstract/tei:p" mode="guidelines"/>
                                </xsl:element>
                                
                                <xsl:element name="div">
                                    <xsl:attribute name="class">card-footer</xsl:attribute>
                                    <xsl:element name="a">
                                        <xsl:attribute name="class">btn float-right btn-sm</xsl:attribute>
                                        <xsl:attribute name="href" select="."/>
                                        <xsl:text>Proceed to Guidelines…</xsl:text>
                                    </xsl:element>
                                    
                                    <xsl:for-each select="$customization.file//tei:profileDesc/tei:textClass/tei:keywords/tei:term">
                                        <xsl:element name="label">
                                            <xsl:attribute name="class">chip</xsl:attribute>
                                            <xsl:value-of select="."/>
                                        </xsl:element>
                                    </xsl:for-each>
                                    

                                </xsl:element>

                            </xsl:element>

                        </xsl:element>

                    </xsl:for-each>

                </xsl:element>

            </xsl:variable>

            <xsl:call-template name="getSinglePage">
                <xsl:with-param name="contents" select="$contents" as="node()*"/>
                <xsl:with-param name="media" select="'screen'"/>
                <xsl:with-param name="reducedLevels" select="xs:boolean('true')"/>
                <xsl:with-param name="skipSideNav" select="xs:boolean('true')"/>
            </xsl:call-template>
            
        </xsl:result-document>
        
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Element references</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:gi" mode="guidelines">
        <xsl:variable name="text" select="string(text())" as="xs:string"/>        <xsl:value-of select="."/>
    </xsl:template>
    
</xsl:stylesheet>
