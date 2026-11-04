<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tools="no:where" exclude-result-prefixes="tools" version="3.0">
    <xsl:import href="../../utils/guidelines_xslt/odd2html.xsl"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="/">
        <results>
            <xsl:for-each select="$att.classes | $elements">
                <case ident="{@ident}">
                    <xsl:variable name="facets">
                        <section><h2 id="{@ident}"><xsl:value-of select="@ident"/></h2>
                            <xsl:sequence select="tools:getAttributesFacet(.)"/>
                        </section>
                    </xsl:variable>
                    <raw><xsl:sequence select="$facets"/></raw>
                    <website><xsl:apply-templates select="$facets/node()" mode="get.website"/></website>
                </case>
            </xsl:for-each>
        </results>
    </xsl:template>
</xsl:stylesheet>
