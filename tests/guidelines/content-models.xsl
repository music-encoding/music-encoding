<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:tools="no:where"
    exclude-result-prefixes="tei tools" version="3.0">
    <xsl:import href="../../utils/guidelines_xslt/odd2html.xsl"/>
    <xsl:output method="xml" indent="yes"/>

    <!-- Exercise the real facet and website renderers, without generating the
         rest of the guidelines or invoking unrelated attribute/datatype code. -->
    <xsl:template match="/">
        <results>
            <xsl:for-each select="$elements | $macro.groups | $model.classes">
                <case ident="{@ident}">
                    <children>
                        <xsl:for-each select="tools:getContentChildren(.)"><child ident="{@ident}"/></xsl:for-each>
                    </children>
                    <xsl:variable name="facets">
                        <section><h2 id="{@ident}"><xsl:value-of select="@ident"/></h2>
                            <xsl:sequence select="tools:getMayContainFacet(.)"/>
                            <xsl:sequence select="tools:getContainedByFacet(.)"/>
                        </section>
                    </xsl:variable>
                    <raw><xsl:sequence select="$facets"/></raw>
                    <website><xsl:apply-templates select="$facets/node()" mode="get.website"/></website>
                </case>
            </xsl:for-each>
        </results>
    </xsl:template>
</xsl:stylesheet>
