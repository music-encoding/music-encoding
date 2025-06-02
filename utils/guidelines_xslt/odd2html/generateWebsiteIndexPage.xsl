<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:tei="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs math xd" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jun 2, 2025</xd:p>
            <xd:p><xd:b>Author:</xd:b> bwb</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>

    <xsl:import href="../odd2html.xsl"/>

    <xsl:param name="customizationIndexPages" as="xs:string"/>
    <xsl:param name="output.folder" as="xs:string"/>
    <xsl:variable name="source.file" select="doc('../../../source/mei-source.xml')/tei:TEI" as="node()"/>
    <xsl:param name="version" as="xs:string" select="$source.file//tei:editionStmt/tei:edition" />

    <xsl:template name="initial-template">

        <xsl:result-document href="{string-join(($output.folder, 'index.html'), '/')}">

            <xsl:variable name="contents">

                <xsl:element name="div">
                    <xsl:attribute name="class">columns filter-body customizations</xsl:attribute>

                    <xsl:variable name="customizationIndexPage" select="tokenize($customizationIndexPages, ';')"/>

                    <xsl:for-each select="$customizationIndexPage">

                        <xsl:variable name="customizationName" select="tokenize(., '/')[1]"/>

                        <xsl:element name="div">
                            <xsl:attribute name="class">column col-4 col-sm-12 col-lg-6 filter-item</xsl:attribute>

                            <xsl:element name="div">
                                <xsl:attribute name="class">card project</xsl:attribute>

                                <xsl:element name="div">
                                    <xsl:attribute name="class">card-header</xsl:attribute>
                                    <xsl:element name="div">
                                        <xsl:attribute name="class">card-title h5</xsl:attribute>
                                        <xsl:value-of select="$customizationName"/>
                                    </xsl:element>
                                    <xsl:element name="div">

                                        <xsl:attribute name="class">card-subtitle text-gray</xsl:attribute>
                                        <xsl:text>some subtitle</xsl:text>
                                    </xsl:element>
                                </xsl:element>

                                <xsl:element name="div">
                                    <xsl:attribute name="class">card-footer</xsl:attribute>
                                    <xsl:element name="a">
                                        <xsl:attribute name="class">btn float-right btn-sm</xsl:attribute>
                                        <xsl:attribute name="href" select="."/>
                                        <xsl:text>More…</xsl:text>
                                    </xsl:element>
                                    <xsl:element name="label">
                                        <xsl:attribute name="class">chip</xsl:attribute>
                                        <xsl:text>some-tag</xsl:text>
                                    </xsl:element>
                                </xsl:element>

                            </xsl:element>
                        </xsl:element>

                    </xsl:for-each>

                </xsl:element>

            </xsl:variable>


        <xsl:call-template name="getSinglePage">
            <xsl:with-param name="contents" select="$contents" as="node()*" />
            <xsl:with-param name="media" select="'screen'" />
            <xsl:with-param name="reducedLevels" select="xs:boolean('true')" />
            
        </xsl:call-template>
        </xsl:result-document>

    </xsl:template>

</xsl:stylesheet>
