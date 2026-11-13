<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" xmlns:purify="http://www.tei-c.org/ns/1.0/purify" xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:rng="http://relaxng.org/ns/structure/1.0" exclude-result-prefixes="#all" version="2.0">

  <xsl:output method="xml" indent="yes"/>
  
  <xsl:param name="schema-prefix" as="xs:token" select="xs:token('')" />
  
  <xsl:param name="target-tei-version">4.12.0</xsl:param>
  
  <xsl:param name="debug" select="xs:boolean('false')"/>
  
  <xsl:variable name="target-tei-version.major" select="xs:integer(tokenize($target-tei-version, '\.')[1])" as="xs:integer"/>
  <xsl:variable name="target-tei-version.minor" select="xs:integer(tokenize($target-tei-version, '\.')[2])" as="xs:integer"/>
  <xsl:variable name="target-tei-version.patch" select="xs:integer(tokenize($target-tei-version, '\.')[3])" as="xs:integer"/>
  
  <!-- All modules next to the one being processed: datatype macros may be
       used in another module than the one they are defined in.
       purify-odd.xsl overrides this with the resolved dependencies. -->
  <xsl:variable name="all-modules" as="document-node()*"
    select="(collection(resolve-uri('.', base-uri(/)) || '?select=*.xml'), /)"/>

  <!-- idents of all datatype macros -->
  <xsl:variable name="dt-macros" as="xs:string*"
    select="distinct-values($all-modules//macroSpec[@type = 'dt']/@ident)"/>

  <!-- An rng:list holding one repeated pattern, as alternative of a choice
       directly in the content of a datatype macro, e.g.
       data.PART = "all" | "none" | list { data.URI+ }.
       Pure ODD cannot express such a list inside a dataSpec (a sequence
       needs two children). The repetition is therefore moved to the
       datatype of every attribute using the macro (see below). -->
  <xsl:function name="purify:is-liftable-list" as="xs:boolean">
    <xsl:param name="list" as="element(rng:list)"/>
    <xsl:sequence select="exists($list[parent::rng:choice/parent::content/parent::macroSpec[@type = 'dt']]
                                      [count(*) eq 1]
                                      [rng:oneOrMore[count(*) eq 1]])"/>
  </xsl:function>

  <!-- datatype macros whose list is lifted to the using attributes -->
  <xsl:variable name="list-datatypes" as="xs:string*"
    select="distinct-values($all-modules//macroSpec[@type = 'dt']
                              [content/rng:choice/rng:list[purify:is-liftable-list(.)]]/@ident)"/>

  <!-- A datatype holding an rng:list with a single (possibly repeated)
       pattern: expressible by the occurrence attributes of <datatype>. -->
  <xsl:function name="purify:is-single-list" as="xs:boolean">
    <xsl:param name="datatype" as="element(datatype)"/>
    <xsl:variable name="rep" select="$datatype/rng:list/*[self::rng:oneOrMore or self::rng:zeroOrMore or self::rng:optional]"/>
    <xsl:sequence select="count($datatype/*) eq 1
                          and count($datatype/rng:list/*) eq 1
                          and (empty($rep) or count($rep/*) eq 1)"/>
  </xsl:function>

  <!-- A datatype holding any other rng:list (e.g. pairs of values): it
       needs a dataSpec of its own, as <datatype> only allows one dataRef. -->
  <!-- The same holds for a choice of datatypes, e.g.
       data.FRETNUMBER | data.FRETNUMBER.omit. -->
  <xsl:function name="purify:is-multi-list" as="xs:boolean">
    <xsl:param name="datatype" as="element(datatype)"/>
    <xsl:sequence select="(exists($datatype/rng:list) and not(purify:is-single-list($datatype)))
                          or exists($datatype/rng:choice)"/>
  </xsl:function>

  <!-- The RELAX NG pattern for "any element (except from some namespaces)
       with any attributes and any content", referring to itself, e.g.
       macro.anyXML. It is exactly what odd2relax generates for an
       anyElement with @exclude. -->
  <xsl:function name="purify:is-any-element" as="xs:boolean">
    <xsl:param name="e" as="element(rng:element)"/>
    <xsl:variable name="self" select="$e/ancestor::macroSpec[1]/@ident"/>
    <xsl:sequence select="count($e/*) eq 3
      and $e/*[1][self::rng:anyName][count(*) eq 1]/rng:except[*][every $n in * satisfies $n/self::rng:nsName[@ns]]
      and $e/*[2][self::rng:zeroOrMore][count(*) eq 1]/rng:attribute[count(*) eq 1]/rng:anyName[not(*)]
      and $e/*[3][self::rng:zeroOrMore][count(*) eq 1]/rng:choice[count(*) eq 2][rng:text][rng:ref[@name = $self]]"/>
  </xsl:function>

  <xsl:function name="purify:list-dataspec-ident" as="xs:string">
    <xsl:param name="datatype" as="element(datatype)"/>
    <xsl:sequence select="'data.' || upper-case($datatype/ancestor::attDef[1]/@ident)"/>
  </xsl:function>

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
    
  <xsl:template match="/">
    <xsl:message>
      Target TEI version: <xsl:value-of select="$target-tei-version"/>
    </xsl:message>
    <xsl:message>
        major: <xsl:value-of select="$target-tei-version.major"/>
    </xsl:message>
    <xsl:message>
        minor: <xsl:value-of select="$target-tei-version.minor"/>
    </xsl:message>
    <xsl:message>
        patch: <xsl:value-of select="$target-tei-version.patch"/>
    </xsl:message>
    
    <xsl:apply-templates />

  </xsl:template>
    
  <!-- ********************************************* -->
  <!-- Process TEI ODD elements that need to change. -->
  <!-- ********************************************* -->

  <xsl:template match="content[count(*) eq 1][rng:element[purify:is-any-element(.)]]" priority="2">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <anyElement exclude="{string-join(rng:element/rng:anyName/rng:except/rng:nsName/@ns, ' ')}"/>
    </xsl:copy>
  </xsl:template>

  <!-- TEI calls the attribute @exclude; an @except is ignored, and the
       TEI namespace is excluded instead. -->
  <xsl:template match="anyElement/@except">
    <xsl:attribute name="exclude" select="."/>
  </xsl:template>

  <!-- If the <content> has unusual or complicated stuff, -->
  <!-- we just copy it for manual treatment later         -->
  <xsl:template match="content[
      descendant::rng:anyName
    | descendant::rng:attribute
    | descendant::rng:element
    | descendant::rng:except
    | descendant::rng:name
    | descendant::rng:nsName
    | descendant::rng:value[not(parent::rng:choice)]
    | descendant::rng:list[not(purify:is-liftable-list(.))]
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
          <xsl:if test="$debug">
            <xsl:call-template name="purify:alert">
            <xsl:with-param name="message" tunnel="yes">inferred sequence element - thoroughly inspect against source and compare generated schema</xsl:with-param>
          </xsl:call-template>
          </xsl:if>
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

  <!-- A moduleRef/@url includes an external RELAX NG schema; its content
       (e.g. an rng:define combining into an ODD class) is RELAX NG by
       design and has no pure ODD equivalent, so it is copied unchanged. -->
  <xsl:template match="moduleRef[@url]">
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
        <dataRef key="{@name}">
          <xsl:call-template name="maxmin"/>
        </dataRef>
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

  <!-- A choice of one pattern needs no alternate. Its occurrence moves to
       the pattern (maxmin looks past a single-child choice), so it is only
       unwrapped when the pattern can carry it: a ref, group or choice, or
       any pattern when the choice has no occurrence. Otherwise (e.g.
       zeroOrMore/choice/optional) the alternate is kept. -->
  <xsl:template match="rng:choice">
    <xsl:variable name="occurrence" as="attribute()*">
      <xsl:call-template name="maxmin"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="count(*) eq 1
                      and (*[self::rng:ref or self::rng:group or self::rng:choice] or empty($occurrence))">
        <xsl:apply-templates select="node() except text()[ normalize-space(.) eq '']"/>
      </xsl:when>
      <xsl:otherwise>
        <alternate>
          <xsl:sequence select="$occurrence"/>
          <xsl:apply-templates select="node() except text()[ normalize-space(.) eq '']"/>
        </alternate>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Literal values of a choice become a closed valList. alternate only
       allows one valList, before the other patterns, so all values of the
       choice are collected there. A choice of nothing but values needs no
       alternate around its valList. -->
  <xsl:template match="rng:choice[rng:value]" priority="1">
    <xsl:variable name="valList" as="element()">
      <valList type="closed">
        <xsl:for-each select="rng:value">
          <valItem ident="{normalize-space(.)}"/>
        </xsl:for-each>
      </valList>
    </xsl:variable>
    <xsl:variable name="others" select="* except rng:value"/>
    <xsl:variable name="occurrence" as="attribute()*">
      <xsl:call-template name="maxmin"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="empty($others) and empty($occurrence)">
        <xsl:sequence select="$valList"/>
      </xsl:when>
      <xsl:otherwise>
        <alternate>
          <xsl:sequence select="$occurrence"/>
          <xsl:sequence select="$valList"/>
          <xsl:apply-templates select="$others"/>
        </alternate>
      </xsl:otherwise>
    </xsl:choose>
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
    <xsl:choose>
      <!-- <interleave> is available from TEI 4.12.0 on -->
      <xsl:when test="$target-tei-version.major gt 4
                      or ($target-tei-version.major eq 4 and $target-tei-version.minor ge 12)">
        <interleave>
      <xsl:apply-templates />
    </interleave>
      </xsl:when>
    <xsl:otherwise>
        <sequence preserveOrder="false">
          <xsl:apply-templates />
        </sequence>
      </xsl:otherwise>
    </xsl:choose>
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

  <!-- Datatype macros become dataSpecs (see above), so any existing
       (already pure) reference to them has to become a dataRef. -->
  <xsl:template match="macroRef[@key = $dt-macros or starts-with(@key, 'data.')]">
    <dataRef>
      <xsl:apply-templates select="@*"/>
    </dataRef>
  </xsl:template>

  <!-- A <datatype> may only hold a single dataRef. An rng:list with a
       single (possibly repeated) pattern is expressed by the occurrence
       attributes of <datatype>, which odd2relax turns into an rng:list
       again. -->
  <xsl:template match="datatype[purify:is-single-list(.)]">
    <xsl:variable name="rep" select="rng:list/*[self::rng:oneOrMore or self::rng:zeroOrMore or self::rng:optional]"/>
    <xsl:copy>
      <xsl:apply-templates select="@* except (@minOccurs, @maxOccurs)"/>
      <xsl:choose>
        <xsl:when test="$rep/self::rng:oneOrMore">
          <xsl:attribute name="maxOccurs">unbounded</xsl:attribute>
        </xsl:when>
        <xsl:when test="$rep/self::rng:zeroOrMore">
          <xsl:attribute name="minOccurs">0</xsl:attribute>
          <xsl:attribute name="maxOccurs">unbounded</xsl:attribute>
        </xsl:when>
        <xsl:when test="$rep/self::rng:optional">
          <xsl:attribute name="minOccurs">0</xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <xsl:apply-templates select="(if ($rep) then $rep else rng:list)/*"/>
    </xsl:copy>
  </xsl:template>

  <!-- Any other list: refer to a dataSpec generated for it (see below). -->
  <xsl:template match="datatype[purify:is-multi-list(.)]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <dataRef key="{purify:list-dataspec-ident(.)}"/>
    </xsl:copy>
  </xsl:template>

  <!-- Emit the dataSpecs for the lists of a spec right after it. A
       sequence of nothing but dataRefs is turned into an rng:list by
       odd2relax. -->
  <xsl:template match="*[self::classSpec or self::elementSpec][.//attDef/datatype[purify:is-multi-list(.)]]">
    <xsl:next-match/>
    <xsl:for-each select=".//attDef/datatype[purify:is-multi-list(.)]">
      <xsl:variable name="ident" select="purify:list-dataspec-ident(.)"/>
      <xsl:variable name="att" select="ancestor::attDef[1]/@ident"/>
      <dataSpec ident="{$ident}" module="{ancestor::*[@module][1]/@module}">
        <xsl:call-template name="purify:alert">
          <xsl:with-param name="message" tunnel="yes" select="'generated ' || $ident || ' for the datatype of @' || $att || ' - check ident and desc'"/>
        </xsl:call-template>
        <xsl:if test="$all-modules//*[@ident = $ident]">
          <xsl:call-template name="purify:alert">
            <xsl:with-param name="message" tunnel="yes" select="$ident || ' already exists - rename the generated dataSpec'"/>
          </xsl:call-template>
        </xsl:if>
        <desc xml:lang="en">Datatype of the <att><xsl:value-of select="$att"/></att> attribute.</desc>
        <content>
          <xsl:choose>
            <xsl:when test="count(rng:list/*) gt 1">
              <sequence>
                <xsl:apply-templates select="(rng:list/*, rng:choice)"/>
              </sequence>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="(rng:list/*, rng:choice)"/>
            </xsl:otherwise>
          </xsl:choose>
        </content>
      </dataSpec>
    </xsl:for-each>
  </xsl:template>

  <!-- The list of a datatype macro like data.PART only keeps its item
       here; the repetition moves to the using attributes. -->
  <xsl:template match="rng:list[purify:is-liftable-list(.)]">
    <xsl:for-each select="rng:oneOrMore/*">
      <xsl:choose>
        <xsl:when test="self::rng:ref">
          <dataRef key="{@name}"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="datatype[count(*) eq 1][(rng:ref/@name, dataRef/@key) = $list-datatypes]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:choose>
        <xsl:when test="not(@maxOccurs) or @maxOccurs = '1'">
          <xsl:attribute name="maxOccurs">unbounded</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="purify:alert">
            <xsl:with-param name="message" tunnel="yes" select="'datatype ' || (rng:ref/@name, dataRef/@key)[1] || ' is a list itself, but already repeated - purify manually'"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="*"/>
    </xsl:copy>
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
    <!--<xsl:message>Pure ODD: TODO</xsl:message>-->
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
    <!-- A single-child rng:group or rng:choice produces no output (see the
         rng:group and rng:choice templates), so look past any such groups
         and choices for the repetition wrapper. Otherwise e.g.
         zeroOrMore/group/choice loses its occurrence. -->
    <xsl:variable name="node" select="(ancestor-or-self::*[not(parent::*[self::rng:group or self::rng:choice][count(*) eq 1])])[last()]"/>
    <xsl:variable name="num_siblings" select="count($node/../*) -1"/>
    <xsl:choose>
      <xsl:when test="$node/parent::rng:zeroOrMore  and  $num_siblings eq 0">
        <xsl:attribute name="minOccurs">0</xsl:attribute>
        <xsl:attribute name="maxOccurs">unbounded</xsl:attribute>
      </xsl:when>
      <xsl:when test="$node/parent::rng:oneOrMore  and  $num_siblings eq 0">
        <xsl:attribute name="minOccurs">1</xsl:attribute>
        <xsl:attribute name="maxOccurs">unbounded</xsl:attribute>
      </xsl:when>
      <xsl:when test="$node/parent::rng:optional  and  $num_siblings eq 0">
        <xsl:attribute name="minOccurs">0</xsl:attribute>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <!-- ************************************** -->
  <!-- subroutines to log and insert messages -->
  <!-- ************************************** -->
  
  <xsl:template name="purify:add-processing-instruction">
    <xsl:param name="message" as="xs:string" tunnel="yes" />
    <xsl:processing-instruction name="PUREODD"><xsl:copy-of select="$message"/></xsl:processing-instruction>
  </xsl:template>
  
  <xsl:template name="purify:add-comment">
    <xsl:param name="message" as="xs:string" tunnel="yes" />
    <xsl:comment>PUREODD: <xsl:copy-of select="$message"/></xsl:comment>
  </xsl:template>

  <xsl:template name="purify:add-todo">
    <xsl:param name="message" as="xs:string" tunnel="yes" />
    <xsl:comment>TODO: Pure ODD <xsl:copy-of select="$message"/></xsl:comment>
  </xsl:template>

  <xsl:template name="purify:log-message">
    <xsl:param name="message" as="xs:string" tunnel="yes" />
    <xsl:param name="terminate" as="xs:string" select="xs:string('no')" tunnel="yes" />
    <xsl:message terminate="{$terminate}">PUREODD: <xsl:copy-of select="$message"/></xsl:message>
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
