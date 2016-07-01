<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    
    xmlns:rng="http://relaxng.org/ns/structure/1.0"
     exclude-result-prefixes="rng"
      version="2.0">
    
    <xsl:output 
        method="xml"
        encoding="utf-8"
        indent="yes"
        omit-xml-declaration="yes"/>
    
    <xsl:template match="tei:macroSpec[@type='dt']">

        <dataSpec  xmlns="http://www.tei-c.org/ns/1.0">
          <xsl:attribute name="module">
              <xsl:value-of select="@module"/>
          </xsl:attribute>
          <xsl:attribute name="ident">
              <xsl:value-of select="@ident"/>
          </xsl:attribute>         
            <xsl:apply-templates />
      </dataSpec>
        
        <!-- output an attdef using this datatype -->
        
        <!--<attDef ident="{concat('A_', substring-after(@ident,'data.'))}">
            <datatype><ref xmlns="http://relaxng.org/ns/structure/1.0" name="{@ident}"/></datatype>
        </attDef>-->
  
    </xsl:template>
    
    <xsl:template match="tei:macroSpec[@type='dt']//tei:content">
<xsl:copy>
        <xsl:choose>
            <xsl:when test="rng:choice">
                <alternate>
                    <xsl:for-each select="rng:choice/rng:data">
                        <dataRef name="{@type}">
                            <xsl:if test="rng:param/@name='pattern'">
                                <xsl:attribute name="restriction">
                                    <xsl:value-of select="rng:param"/>
                                </xsl:attribute>
                            </xsl:if>
                        </dataRef>
                    </xsl:for-each>
                    <xsl:for-each select="rng:choice/rng:ref">
                        <dataRef name="{@name}">
                            <xsl:if test="rng:param/@name='pattern'">
                                <xsl:attribute name="restriction">
                                    <xsl:value-of select="rng:param"/>
                                </xsl:attribute>
                            </xsl:if>
                        </dataRef>
                    </xsl:for-each>
                    <xsl:if test="rng:choice/rng:value">
                        <valList>
                            <xsl:for-each select="rng:choice/rng:value">
                                <valItem ident="{.}"/>
                            </xsl:for-each>
                        </valList>
                    </xsl:if>
                </alternate>
            </xsl:when>
            <xsl:when test="rng:data/rng:param/@name='pattern'">
                <dataRef name="{rng:data/@type}"
                    restriction="{rng:data/rng:param}"/>
            </xsl:when>
            <xsl:when test="rng:data">
                <dataRef name="{rng:data/@type}"/>
            </xsl:when>
            <xsl:when test="rng:ref">
                <xsl:for-each select="rng:ref">
                    <dataRef key="{@name}"/>    
                </xsl:for-each>                
            </xsl:when>
            <xsl:when test="tei:*">
                <xsl:sequence select="tei:*"/>
            </xsl:when>
            <xsl:otherwise>
                <textNode/>
            </xsl:otherwise>
        </xsl:choose>
</xsl:copy>
    </xsl:template>
  
    <!-- copy everything else -->
    
    <xsl:template match="*">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates 
                select="*|comment()|processing-instruction()|text()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="@*|processing-instruction()|text()">
        <xsl:copy/>
    </xsl:template>
    
    <xsl:template match="comment()">
        <xsl:copy/>
    </xsl:template>
</xsl:stylesheet>