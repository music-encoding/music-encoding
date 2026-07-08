<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" xmlns:purify="http://www.tei-c.org/ns/1.0/purify" xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:rng="http://relaxng.org/ns/structure/1.0" exclude-result-prefixes="#all" version="2.0">

  <xsl:output method="xml" indent="yes"/>
  
  <xsl:param name="schema-prefix" as="xs:token" select="xs:token('tei')" />
  
  <xsl:function name="purify:is-xs-datatype" as="xs:boolean">
    <xsl:param name="name" as="xs:token" required="yes"/>
    
    <!-- TODO checkc against xs datatypes -->
    
    <xsl:sequence select="xs:boolean( $name = ('nonNegativeInteger'))"/>
    
  </xsl:function>
  
  <!-- ****************************************************************** -->
  <!-- Overall, this is an identity transform: here we copy over anything -->
  <!-- and everything that is not an ODD element matched below.           -->
  <!-- ****************************************************************** -->
  <xsl:template match="node()">
    <xsl:if test="not(ancestor::*)">
      <xsl:text>&#x0A;</xsl:text>
    </xsl:if>
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>
    
  <!-- ********************************************* -->
  <!-- Process TEI ODD elements that need to change. -->
  <!-- ********************************************* -->

  <!-- If the <content> has unusual or complicated stuff, -->
  <!-- we just copy it for manual treatment later         -->
  <xsl:template match="content[
      descendant::rng:anyName
    | descendant::rng:attribute
    | descendant::rng:element
    | descendant::rng:except
    | descendant::rng:name
    | descendant::rng:nsName
    | descendant::rng:value
    ]">
    <xsl:call-template name="purify:alert">
      <xsl:with-param name="message" tunnel="yes">strange content child elements - purify manually</xsl:with-param>
    </xsl:call-template>
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="content">
    
    <xsl:variable name="childCount" select="count(*)"/>
    
    <xsl:choose>
      <xsl:when test="$childCount = 0">
        <xsl:copy>
          <xsl:apply-templates select="@*" />
          <xsl:call-template name="purify:alert">
            <xsl:with-param name="message" tunnel="yes">inferred empty element</xsl:with-param>
          </xsl:call-template>
          <empty/>
        </xsl:copy>
      </xsl:when>
      <xsl:when test="$childCount = 1">
          <xsl:next-match />
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*" />
          <xsl:call-template name="purify:alert">
            <xsl:with-param name="message" tunnel="yes">inferred sequence element - thoroughly inspect against source and compare generated schema</xsl:with-param>
          </xsl:call-template>
          <xsl:element name="sequence">
            <xsl:apply-templates />
          </xsl:element>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>

  <xsl:template match="exemplum">
    <xsl:copy-of select="."/>
  </xsl:template>
 
  <!-- ********************************************* -->
  <!-- Process RNG elements that need to change. -->
  <!-- ********************************************* -->
  
  <xsl:template match="rng:ref">
    <xsl:choose>
      <xsl:when test="starts-with(@name, 'model.')">
        <xsl:choose>
          <xsl:when test="contains(@name, '_')">
            <classRef key="{substring-before(@name,'_')}">
              <xsl:attribute name="expand">
                <xsl:value-of select="substring-after(@name, '_')"/>
              </xsl:attribute>
              <xsl:call-template name="maxmin"/>
            </classRef>
          </xsl:when>
          <xsl:otherwise>
            <classRef key="{@name}">
              <xsl:call-template name="maxmin"/>
            </classRef>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="starts-with(@name, 'att.')">
        <classRef key="{@name}">
          <xsl:call-template name="maxmin"/>
        </classRef>
      </xsl:when>
      <xsl:when test="starts-with(@name, 'macro.')">
        <macroRef key="{@name}">
          <xsl:call-template name="maxmin"/>
        </macroRef>
      </xsl:when>
      <xsl:when test="starts-with(@name, 'data.')">
        <macroRef key="{@name}">
          <xsl:call-template name="maxmin"/>
        </macroRef>
      </xsl:when>
      <xsl:otherwise>
        <elementRef key="{@name}">
          <xsl:call-template name="maxmin"/>
        </elementRef>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="rng:group">
    <xsl:choose>
      <xsl:when test="count(*) gt 1">
        <sequence>
          <xsl:call-template name="maxmin"/>
          <xsl:apply-templates select="node() except text()[ normalize-space(.) eq '']"/>
        </sequence>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="node() except text()[ normalize-space(.) eq '']"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="rng:text">
    <textNode/>
  </xsl:template>

  <xsl:template match="rng:choice[not(parent::datatype)]">
    <alternate>
      <xsl:call-template name="maxmin"/>
      <xsl:apply-templates select="node() except text()[ normalize-space(.) eq '']"/>
    </alternate>
  </xsl:template>

  <xsl:template match="rng:zeroOrMore | rng:oneOrMore | rng:optional">
    <xsl:choose>
      <xsl:when test="count(*) eq 1">
        <xsl:apply-templates select="node() except text()[ normalize-space(.) eq '']"/>
      </xsl:when>
      <xsl:otherwise>
        <sequence>
          <xsl:choose>
            <xsl:when test="self::rng:zeroOrMore">
              <xsl:attribute name="minOccurs">0</xsl:attribute>
              <xsl:attribute name="maxOccurs">unbounded</xsl:attribute>
            </xsl:when>
            <xsl:when test="self::rng:oneOrMore">
              <xsl:attribute name="minOccurs">1</xsl:attribute>
              <xsl:attribute name="maxOccurs">unbounded</xsl:attribute>
            </xsl:when>
            <xsl:when test="self::rng:optional">
              <xsl:attribute name="minOccurs">0</xsl:attribute>
            </xsl:when>
          </xsl:choose>
          <xsl:apply-templates select="node() except text()[ normalize-space(.) eq '']"/>
        </sequence>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="rng:empty"/>
  
  
  <xsl:template match="rng:interleave">
    <interleave>
      <xsl:apply-templates />
    </interleave>
  </xsl:template>
  
  <!-- ********************************************* -->
  <!-- Convert datatypes .                           -->
  <!-- ********************************************* -->
   
  <xsl:template match="datatype/rng:ref">
     <dataRef key="{concat($schema-prefix,./@name)}">
       <xsl:apply-templates />
     </dataRef>
  </xsl:template>
  
  <xsl:template match="rng:data[ancestor::content or ancestor::datatype]">
    <dataRef name="{./@type}">
      <xsl:apply-templates />
    </dataRef>
  </xsl:template>
  
  <xsl:template match="rng:text[parent::datatype]">
    <dataRef name="string">
      <xsl:apply-templates />
    </dataRef>
  </xsl:template>
  
  <xsl:template match="rng:param[parent::rng:data]">
      <xsl:element name="dataFacet">
        <xsl:attribute name="name" select="@name" />
        <xsl:attribute name="value" select="normalize-space(.)" />
      </xsl:element>
  </xsl:template>
  
  <xsl:template match="macroSpec[@type='dt']">
    <xsl:element name="dataSpec">
      <xsl:apply-templates select="@*,*"/>
    </xsl:element>
  </xsl:template>
  
  <!-- ********************************************* -->
  <!-- Process macroSpecs.                           -->
  <!-- ********************************************* -->
  
  <xsl:template match="@type[parent::macroSpec]" />
  
  <!-- ********************************************* -->
  <!-- Process constraintSpecs.                      -->
  <!-- ********************************************* -->

  <xsl:template match="@scheme[parent::constraintSpec]">
    <xsl:attribute name="scheme">schematron</xsl:attribute>
  </xsl:template>

  <!-- ********************************************* -->
  <!-- Warn about the stuff we couldn't handle.      -->
  <!-- ********************************************* -->

  
  <xsl:template match="rng:anyName | rng:attribute | rng:element | rng:except
                     | rng:name | rng:nsName | rng:value">
    <xsl:variable name="message" as="xs:string" select="string-join((name(.),for $att in @* return string-join(('@' || name(), .), ':')), ' ')" />
    <xsl:call-template name="purify:alert">
      <xsl:with-param name="message" select="$message" tunnel="yes" />
    </xsl:call-template>
    <!--<xsl:message>Purify: TODO</xsl:message>-->
    <junk was="{name(.)}">
      <xsl:apply-templates select="@*,*"/>
    </junk>
  </xsl:template>
  
  <xsl:template match="rng:* | alternate[parent::datatype]">
    <xsl:call-template name="purify:alert">
      <xsl:with-param name="message" tunnel="yes">unprocessed <xsl:value-of select="name(.)"/> - fix in source</xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="purify:add-processing-instruction">
      <xsl:with-param name="message" tunnel="yes">an unprocessed <xsl:value-of select="name(.)"/> started here</xsl:with-param>
    </xsl:call-template>
    <xsl:apply-templates/>
    <xsl:call-template name="purify:add-processing-instruction">
      <xsl:with-param name="message" tunnel="yes">an unprocessed <xsl:value-of select="name(.)"/> ended here</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- *********************************************** -->
  <!-- subroutine to handle repetition and optionality -->
  <!-- *********************************************** -->
  <xsl:template name="maxmin">
    <xsl:variable name="num_siblings" select="count(../*) -1"/>
    <xsl:choose>
      <xsl:when test="parent::rng:zeroOrMore  and  $num_siblings eq 0">
        <xsl:attribute name="minOccurs">0</xsl:attribute>
        <xsl:attribute name="maxOccurs">unbounded</xsl:attribute>
      </xsl:when>
      <xsl:when test="parent::rng:oneOrMore  and  $num_siblings eq 0">
        <xsl:attribute name="minOccurs">1</xsl:attribute>
        <xsl:attribute name="maxOccurs">unbounded</xsl:attribute>
      </xsl:when>
      <xsl:when test="parent::rng:optional  and  $num_siblings eq 0">
        <xsl:attribute name="minOccurs">0</xsl:attribute>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <!-- ************************************** -->
  <!-- subroutines to log and insert messages -->
  <!-- ************************************** -->
  
  <xsl:template name="purify:add-processing-instruction">
    <xsl:param name="message" as="xs:string" tunnel="yes" />
    <xsl:processing-instruction name="PURIFY"><xsl:copy-of select="$message"/></xsl:processing-instruction>
  </xsl:template>
  
  <xsl:template name="purify:add-comment">
    <xsl:param name="message" as="xs:string" tunnel="yes" />
    <xsl:comment>PURIFY: <xsl:copy-of select="$message"/></xsl:comment>
  </xsl:template>

  <xsl:template name="purify:add-todo">
    <xsl:param name="message" as="xs:string" tunnel="yes" />
    <xsl:comment>TODO: purify <xsl:copy-of select="$message"/></xsl:comment>
  </xsl:template>

  <xsl:template name="purify:log-message">
    <xsl:param name="message" as="xs:string" tunnel="yes" />
    <xsl:param name="terminate" as="xs:string" select="xs:string('no')" tunnel="yes" />
    <xsl:message terminate="{$terminate}">PURIFY: <xsl:copy-of select="$message"/></xsl:message>
    <!-- (line <xsl:value-of select="saxon:line-number(.)"/>) only available in Saxon-PE or Saxon-EE -->
  </xsl:template>
  
  <xsl:template name="purify:alert">
    <xsl:param name="message" as="xs:string" required="yes" tunnel="yes" />
    <xsl:param name="terminate" as="xs:string" select="xs:string('no')"  tunnel="yes" />
    
    <xsl:call-template name="purify:log-message" />
    <xsl:call-template name="purify:add-comment" />
    <xsl:call-template name="purify:add-processing-instruction" />
    
  </xsl:template>

</xsl:stylesheet>
