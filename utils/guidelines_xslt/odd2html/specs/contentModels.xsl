<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:tools="no:where"
    exclude-result-prefixes="xs map tei tools" version="3.0">

    <!-- Build the graph once. Reverse traversal is used on every spec page;
         repeatedly scanning every content model here is prohibitively costly. -->
    <xsl:variable name="content.references" as="map(*)">
        <xsl:map>
            <xsl:for-each select="$elements | $model.classes | $macro.groups">
                <xsl:map-entry key="generate-id()" select="tools:resolveContentReferences(.)"/>
            </xsl:for-each>
        </xsl:map>
    </xsl:variable>

    <xsl:variable name="content.referrers" as="map(*)">
        <xsl:variable name="entries" as="map(*)*">
            <xsl:for-each select="$elements | $model.classes | $macro.groups">
                <xsl:variable name="referrer" select="." as="node()"/>
                <xsl:for-each select="tools:getContentReferences(.)">
                    <xsl:sequence select="map {generate-id(): $referrer}"/>
                </xsl:for-each>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="map:merge($entries, map {'duplicates': 'combine'})"/>
    </xsl:variable>

    <xsl:function name="tools:getContentReferences" as="node()*">
        <xsl:param name="object" as="node()"/>
        <xsl:sequence select="map:get($content.references, generate-id($object))"/>
    </xsl:function>

    <!-- Resolve only definitions available in this customization. Occurrence bounds
         affect ordering/cardinality, not the set of possible children, except
         that maxOccurs="0" disables an entire branch. -->
    <xsl:function name="tools:getContentNodes" as="element()*">
        <xsl:param name="object" as="node()"/>
        <xsl:sequence select="$object/tei:content//*[not(ancestor-or-self::*[@maxOccurs = '0'])]"/>
    </xsl:function>

    <xsl:function name="tools:resolveContentReferences" as="node()*">
        <xsl:param name="object" as="node()"/>
        <xsl:variable name="content" select="tools:getContentNodes($object)" as="element()*"/>
        <xsl:choose>
            <xsl:when test="$object/self::tei:classSpec[@type = 'model']">
                <xsl:sequence select="($elements | $model.classes | $macro.groups)
                    [tei:classes/tei:memberOf/@key = $object/@ident]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="
                    $elements[@ident = $content/self::tei:elementRef/@key] |
                    $model.classes[@ident = $content/self::tei:classRef/@key] |
                    $macro.groups[@ident = $content/self::tei:macroRef/@key]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- Expand classes and macros, but never descend into a referenced element's
         own content: that would confuse children with further descendants.
         A visited set makes recursive and diamond-shaped models finite/unique. -->
    <xsl:function name="tools:getContentModels" as="node()*">
        <xsl:param name="objects" as="node()*"/>
        <xsl:param name="visited" as="node()*"/>
        <xsl:variable name="fresh" select="$objects except $visited" as="node()*"/>
        <xsl:if test="exists($fresh)">
            <xsl:variable name="next" as="node()*">
                <xsl:for-each select="$fresh">
                    <xsl:sequence select="tools:getContentReferences(.)[not(self::tei:elementSpec)]"/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:sequence select="$fresh | tools:getContentModels($next, $visited | $fresh)"/>
        </xsl:if>
    </xsl:function>

    <xsl:function name="tools:getContentChildren" as="node()*">
        <xsl:param name="object" as="node()"/>
        <xsl:variable name="children" as="node()*">
            <xsl:for-each select="tools:getContentModels($object, ())">
                <xsl:sequence select="tools:getContentReferences(.)[self::tei:elementSpec]"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:sequence select="$children | ()"/>
    </xsl:function>

    <xsl:function name="tools:getReferencingModels" as="node()*">
        <xsl:param name="object" as="node()"/>
        <xsl:sequence select="map:get($content.referrers, generate-id($object))[not(self::tei:elementSpec)]"/>
    </xsl:function>

    <xsl:function name="tools:getContentParents" as="node()*">
        <xsl:param name="object" as="node()"/>
        <xsl:sequence select="map:get($content.referrers, generate-id($object))[self::tei:elementSpec]"/>
    </xsl:function>

    <xsl:function name="tools:getWildcardDescriptions" as="element(div)*">
        <xsl:param name="models" as="node()*"/>
        <xsl:variable name="wildcards" as="element()*">
            <xsl:for-each select="$models">
                <xsl:sequence select="tools:getContentNodes(.)[self::tei:anyElement]"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each-group select="$wildcards" group-by="serialize(.)">
            <div class="wildcardContent">
                <xsl:text>Any XML element</xsl:text>
                <xsl:choose>
                    <xsl:when test="self::tei:anyElement/@except">
                        <xsl:text> except elements in these namespaces: </xsl:text>
                        <xsl:value-of select="string-join(tokenize(normalize-space(@except), '\s+'), ', ')"/>
                    </xsl:when>
                </xsl:choose>
                <xsl:text>.</xsl:text>
            </div>
        </xsl:for-each-group>
    </xsl:function>
</xsl:stylesheet>
