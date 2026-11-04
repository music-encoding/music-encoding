<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:tools="no:where"
    exclude-result-prefixes="xs map tei tools" version="3.0">

    <xsl:function name="tools:getAttributeValues" as="node()+">
        <xsl:param name="attribute" as="element(tei:attDef)"/>
        <xsl:variable name="values" select="$attribute/tei:valList" as="element(tei:valList)?"/>
        <xsl:choose>
            <xsl:when test="$values">
                <xsl:value-of select="if($values/@type = 'semi') then(' Suggested values are:') else(' Allowed values are:')"/>
                <xsl:for-each select="$values/tei:valItem">
                    <xsl:if test="position() gt 1"><xsl:text>, </xsl:text></xsl:if>
                    <xsl:text> "</xsl:text><span style="font-weight: 500;"><xsl:value-of select="@ident"/></span><xsl:text>"</xsl:text>
                    <xsl:if test="tei:desc"><xsl:text> </xsl:text><i><xsl:text>(</xsl:text><xsl:apply-templates select="tei:desc/node()" mode="guidelines"/><xsl:text>)</xsl:text></i></xsl:if>
                </xsl:for-each>
                <xsl:text>.</xsl:text>
                <!-- A semi-open list suggests tokens; it does not replace the
                     datatype's restrictions or its space-separated list bounds. -->
                <xsl:if test="$values/@type = 'semi' and $attribute/tei:datatype">
                    <xsl:text> </xsl:text><xsl:sequence select="tools:describeAttributeDatatype($attribute/tei:datatype)"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$attribute/tei:datatype">
                <xsl:sequence select="tools:describeAttributeDatatype($attribute/tei:datatype)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="tools:unsupportedAttributeDatatype($attribute)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="tools:describeAttributeDatatype" as="node()+">
        <xsl:param name="datatype" as="element(tei:datatype)"/>
        <xsl:choose>
            <xsl:when test="count($datatype/*) = 1">
                <xsl:variable name="description" select="tools:attributeDatatypeOccurrences($datatype, 'value', tools:describeAttributeValue($datatype/*))" as="node()+"/>
                <xsl:variable name="problems" select="$description/descendant-or-self::span[@class = 'datatypeUnsupported']" as="element(span)*"/>
                <xsl:choose>
                    <xsl:when test="exists($problems)"><xsl:sequence select="$problems[1]"/></xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="if(some $part in ($datatype, $datatype/*) satisfies
                            exists($part/@minOccurs[. != '1'] | $part/@maxOccurs[. != '1']))
                            then('Value consists of ') else('Value conforms to ')"/>
                        <xsl:sequence select="$description"/>
                        <xsl:text>.</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise><xsl:sequence select="tools:unsupportedAttributeDatatype($datatype)"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- Render a single unit first, then apply that node's occurrence bounds.
         This keeps repeated sequences (pairs, for example) distinct from an
         arbitrary list of their individual component values. -->
    <xsl:function name="tools:describeAttributeValue" as="node()+">
        <xsl:param name="node" as="element()"/>
        <xsl:variable name="description" as="node()+">
            <xsl:choose>
                <xsl:when test="$node/self::tei:dataRef[@key][not(*)]">
                    <xsl:choose>
                        <xsl:when test="$node/@key = $data.types/@ident">
                            <a class="{tools:getLinkClasses($node/@key)}" href="#{$node/@key}"><xsl:value-of select="$node/@key"/></a>
                        </xsl:when>
                        <xsl:otherwise><xsl:sequence select="tools:unsupportedAttributeDatatype($node)"/></xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="$node/self::tei:dataRef[@name]">
                    <xsl:text>the XML Schema </xsl:text>
                    <a target="_blank" href="https://www.w3.org/TR/xmlschema11-2/#{$node/@name}"><xsl:value-of select="$node/@name"/></a>
                    <xsl:text> datatype</xsl:text>
                    <xsl:if test="$node/*">
                        <xsl:text> (</xsl:text>
                        <xsl:for-each select="$node/*">
                            <xsl:if test="position() gt 1"><xsl:text>; </xsl:text></xsl:if>
                            <xsl:sequence select="tools:describeAttributeFacet(.)"/>
                        </xsl:for-each>
                        <xsl:text>)</xsl:text>
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$node/self::tei:sequence[*] or $node/self::tei:alternate[*]">
                    <xsl:value-of select="if($node/self::tei:sequence) then('a sequence of (') else('one of (')"/>
                    <xsl:for-each select="$node/*">
                        <xsl:if test="position() gt 1"><xsl:value-of select="if($node/self::tei:sequence) then(', followed by ') else(' or ')"/></xsl:if>
                        <xsl:sequence select="tools:describeAttributeValue(.)"/>
                    </xsl:for-each>
                    <xsl:text>)</xsl:text>
                </xsl:when>
                <xsl:otherwise><xsl:sequence select="tools:unsupportedAttributeDatatype($node)"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="tools:attributeDatatypeOccurrences($node, if($node/self::tei:sequence) then('sequence') else('value'), $description)"/>
    </xsl:function>

    <xsl:function name="tools:attributeDatatypeOccurrences" as="node()+">
        <xsl:param name="node" as="element()"/>
        <xsl:param name="unit" as="xs:string"/>
        <xsl:param name="description" as="node()+"/>
        <xsl:variable name="min" select="string(($node/@minOccurs, '1')[1])" as="xs:string"/>
        <xsl:variable name="max" select="string(($node/@maxOccurs, '1')[1])" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="not($min castable as xs:nonNegativeInteger) or
                not($max = 'unbounded' or $max castable as xs:nonNegativeInteger)">
                <xsl:sequence select="tools:unsupportedAttributeDatatype($node)"/>
            </xsl:when>
            <xsl:when test="if($max = 'unbounded') then(false()) else(xs:integer($max) lt xs:integer($min))">
                <xsl:sequence select="tools:unsupportedAttributeDatatype($node)"/>
            </xsl:when>
            <xsl:when test="$max = '0'"><xsl:text>an empty value</xsl:text></xsl:when>
            <xsl:when test="xs:integer($min) = 1 and $max = '1'"><xsl:sequence select="$description"/></xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$max = 'unbounded'"><xsl:value-of select="$min || ' or more'"/></xsl:when>
                    <xsl:when test="$min = $max"><xsl:value-of select="'exactly ' || $min"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="$min || ' to ' || $max"/></xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="' space-separated ' || $unit || (if($max = '1') then('') else('s')) || ', each conforming to '"/>
                <xsl:sequence select="$description"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="tools:describeAttributeFacet" as="node()+">
        <xsl:param name="facet" as="element()"/>
        <xsl:variable name="labels" as="map(xs:string, xs:string)" select="map {
            'pattern': 'matching the regular expression ',
            'minInclusive': 'greater than or equal to ', 'maxInclusive': 'less than or equal to ',
            'minExclusive': 'greater than ', 'maxExclusive': 'less than ',
            'length': 'length equal to ', 'minLength': 'length at least ', 'maxLength': 'length at most ',
            'totalDigits': 'at most this many total digits: ', 'fractionDigits': 'at most this many fractional digits: ',
            'enumeration': 'equal to ', 'whiteSpace': 'whitespace processing: ',
            'explicitTimezone': 'timezone requirement: '
        }"/>
        <xsl:choose>
            <xsl:when test="$facet/self::tei:dataFacet[@value] and map:contains($labels, string($facet/@name))">
                <xsl:value-of select="map:get($labels, string($facet/@name))"/>
                <code><xsl:value-of select="$facet/@value"/></code>
            </xsl:when>
            <xsl:otherwise><xsl:sequence select="tools:unsupportedAttributeDatatype($facet)"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="tools:unsupportedAttributeDatatype" as="element(span)">
        <xsl:param name="node" as="element()"/>
        <xsl:variable name="missing" select="exists($node/self::tei:dataRef[@key][not(@key = $data.types/@ident)])" as="xs:boolean"/>
        <xsl:message select="'WARNING: ' || (if($missing) then('Unavailable Pure ODD datatype reference') else('Unsupported Pure ODD attribute datatype')) || ' at ' ||
            string-join(($node/ancestor-or-self::*[self::tei:elementSpec or self::tei:classSpec]/@ident,
            $node/ancestor-or-self::tei:attDef/@ident), '/') || ': ' || serialize($node)"/>
        <span class="datatypeUnsupported">
            <xsl:choose>
                <xsl:when test="$missing">Datatype <xsl:value-of select="$node/@key"/> is not available in this customization; see the declaration.</xsl:when>
                <xsl:otherwise>Datatype description unavailable for <xsl:value-of select="local-name($node)"/>; see the declaration.</xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:function>
</xsl:stylesheet>
