<?xml version="1.0" encoding="UTF-8"?>

<!-- 
    name: rng2odd.xsl
    
    author: Raffaele Viglianti
    
    description: This script converts ../RelaxSchema/mei19-all.rng into a valid TEI ODD file

    
-->


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns="http://www.tei-c.org/ns/1.0" xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
  xmlns:xhtml="http://www.w3.org/1000/xhtml" xml:lang="en"
  xmlns:sch="http://purl.oclc.org/dsdl/schematron"
  xpath-default-namespace="http://relaxng.org/ns/structure/1.0">

  <!-- Dependencies -->
  <xsl:import href="TEI/xhtml2tei.xsl" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"/>

  <xsl:output encoding="UTF-8" indent="yes" method="xml"/>

  <!-- Variables -->

  <!-- name: datatypes
         decription: relative path to datatypes.rng, included in MEI rng
    -->
  <xsl:variable name="datatypes">../RNG/datatypes.rng</xsl:variable>

  <!-- name: nl
         description: new line character for retty print
    -->
  <xsl:variable name="nl" select="'&#10;'"/>

  <!-- Functions -->

  <!-- name: make-namespace-node.
         description: copy an element adding namespace "rng".
         handle-models: determins ODD suffix when referring models from elements (only used by Element Classes template below; false() by default)
         recursive: copy children elements recursively.-->
  <xsl:template name="make-namespace-node">
    <xsl:param name="handle-models" select="false()"/>
    <xsl:param name="recursive"/>
    <!-- Ignoring _DUMMY models (may be osbolete) -->
    <!-- Ignoring leftover xhtml documentation -->
    <xsl:if
      test="not(contains(@name, '_DUMMY')) and not(self::*[namespace-uri()='http://www.w3.org/1999/xhtml'])">
      <xsl:element name="rng:{local-name(.)}">
        <xsl:choose>
          <!-- Handle ODD suffix if required -->
          <xsl:when test="$handle-models">
            <xsl:choose>
              <xsl:when test="self::ref and starts-with(@name, 'model.')">
                <xsl:variable name="this-mdl" select="@name"/>
                <xsl:attribute name="name">
                  <xsl:for-each select="ancestor::grammar//define[@name=$this-mdl]">
                    <!-- Determine suffix -->
                    <xsl:choose>
                      <!-- one element (no suffix) -->
                      <!-- Problem: alternation doesn't seem to be handled by roma, so it won't have suffix for now. -->
                      <xsl:when test="ref">
                        <xsl:value-of select="@name"/>
                      </xsl:when>
                      <!--only one of the members (alternation)-->
                      <xsl:when test="choice">
                        <xsl:value-of select="@name"/>
                        <xsl:text>_alternation</xsl:text>
                      </xsl:when>
                      <!-- members may be provided, in sequence, but are optional (sequenceOptional) -->
                      <xsl:when
                        test="optional and not(optional/*[not(self::ref)]) and not(zeroOrMore)">
                        <xsl:value-of select="@name"/>
                        <xsl:text>_sequenceOptional</xsl:text>
                      </xsl:when>
                      <!-- members may be provided one or more times, in sequence, but are optional (sequenceOptionalRepeatable) -->
                      <xsl:when
                        test="zeroOrMore and not(zeroOrMore/*[not(self::ref)]) and not(optional)">
                        <xsl:value-of select="@name"/>
                        <xsl:text>_sequenceOptionalRepeatable</xsl:text>
                      </xsl:when>
                      <!-- If it doens't fit in any of the previous cases, it's a macro -->
                      <xsl:otherwise>
                        <xsl:text>macro.</xsl:text>
                        <xsl:value-of select="substring-after(@name, 'model.')"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each>
                </xsl:attribute>
                <xsl:sequence select="@* except @name"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="@*"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <!-- Otherwise just copy all attributes -->
          <xsl:otherwise>
            <xsl:sequence select="@*"/>
          </xsl:otherwise>
        </xsl:choose>

        <!-- recursive? -->
        <xsl:choose>
          <!-- ON -->
          <!-- not(self::text()) condition is redundant and produces a warning with Saxon. -->
          <xsl:when test="$recursive and *[not(self::text())]">
            <xsl:for-each select="*[not(self::text())]">
              <xsl:choose>
                <!-- If ODD suffix handling is required, bring it forward in recursion -->
                <xsl:when test="$handle-models">
                  <xsl:call-template name="make-namespace-node">
                    <xsl:with-param name="handle-models" select="true()"/>
                    <xsl:with-param name="recursive" select="true()"/>
                  </xsl:call-template>
                </xsl:when>
                <!-- otherwise ignore it and keep going -->
                <xsl:otherwise>
                  <xsl:call-template name="make-namespace-node">
                    <xsl:with-param name="recursive" select="true()"/>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:when>
          <!-- OFF -->
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </xsl:if>
  </xsl:template>


  <!-- MAIN -->
  <xsl:template match="/">

    <xsl:processing-instruction name="oxygen">
      <xsl:text>RNGSchema="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="xml"</xsl:text>
    </xsl:processing-instruction>

    <TEI>

      <teiHeader>
        <fileDesc>
          <titleStmt>
            <title>MEI (Music Encoding Initiative)</title>
            <respStmt>
              <resp>automated and manual editing</resp>
              <name xml:id="RV">Raffaele Viglianti</name>
              <name xml:id="PR">Perry Roland</name>
            </respStmt>
          </titleStmt>
          <publicationStmt>
            <p>Converted from RNG with XSLT script ../Styles/rng2odd.xsl</p>
          </publicationStmt>
          <sourceDesc>
            <p>created on <xsl:value-of select="current-dateTime()"/></p>
          </sourceDesc>
        </fileDesc>
        <revisionDesc>
          <change who="#RV" when="{current-date()}"> Converted RNG Datatypes Declarations into ODD
            Datatype Macros according to TEI guidelines. <ref
              target="http://www.tei-c.org/release/doc/tei-p5-doc/html/ST.html#DTYPES">Chapter 1,
              §1.4.2</ref>. </change>
          <change who="#RV" when="{current-date()}"> Converted RNG Attribute Classes Declarations
            into ODD Attribute Classes according to TEI guidelines. <ref
              target="http://www.tei-c.org/release/doc/tei-p5-doc/html/ST.html#STECAT">Chapter 1,
              §1.3.1</ref>. </change>
          <change who="#RV" when="{current-date()}"> Converted RNG Model Classes Declarations into
            ODD Model Classes according to TEI guidelines. <ref
              target="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ST.html#STECCM">Chapter 1,
              §1.3.2</ref>. See also <ref
              target="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/TD.html#TDCLA">Chapter 22,
              §22.4.6</ref> for references to models. </change>
          <change who="#RV" when="{current-date()}"> Converted RNG Model Classes Declarations into
            ODD Macro Classes (when appropriate) according to TEI guidelines. <ref
              target="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/TD.html#TDENT">Chapter 22,
              §22.4.7</ref>. </change>
          <change who="#RV" when="{current-date()}"> Converted RNG Element Declarations into ODD
            Element Declarations according to TEI guidelines. <ref
              target="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/TD.html#TDcrystals"
              >Chapter 22, §22.3</ref>. See also <ref
              target="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/TD.html#TDCLA">Chapter 22,
              §22.4.6</ref> for references to models. </change>
          <change who="#PR" when="{current-date()}">Changed order of content and attlist
            declarations, fixed problem generating @usage</change>
          <change who="#RV" when="{current-date()}">Integrated Schematron rules within element
            declarations.</change>
        </revisionDesc>
      </teiHeader>
      <text>
        <front>
          <divGen type="toc"/>
        </front>
        <body>
          <p>MEI</p>

          <schemaSpec ident="mei" start="mei" ns="http://www.mei-c.org/ns/mei">

            <!-- DATA -->
            <xsl:value-of select="$nl"/>
            <xsl:comment>****</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>Datatype Macros</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>Number of definitions found in original RNG: <xsl:value-of
                select="count(document($datatypes)//define[starts-with(@name, 'data.')])"/>
            </xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>****</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:apply-templates select="document($datatypes)//define[starts-with(@name, 'data.')]"/>

            <!-- ATTRIBUTES -->
            <xsl:value-of select="$nl"/>
            <xsl:comment>****</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>Attribute Classes</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>Number of definitions found in original RNG: <xsl:value-of
                select="count(//define[starts-with(@name, 'att.')])"/>
            </xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>****</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:apply-templates select="//define[starts-with(@name, 'att.')]"/>

            <!--MODELS AND MACROS-->
            <xsl:value-of select="$nl"/>
            <xsl:comment>****</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>Defintion of Model and Macro Classes</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>Number of definitions found in original RNG: <xsl:value-of
                select="count(//define[starts-with(@name, 'model.')])"/>
            </xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>****</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:apply-templates select="//define[starts-with(@name, 'model.')]"/>

            <!-- ELEMENTS -->
            <!-- N.B. If the modularization of element, attlist.element and content.element
                            was done to facilitate the change of the element's name (i.e. for translations)
                            remember that it is possible to specify alternative names in ODD in <elementSpec>.
                            For this reason, this scripts re-joins them together -->
            <xsl:value-of select="$nl"/>
            <xsl:comment>****</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>Defintion of Model Classes</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>Number of definitions found in original RNG: <xsl:value-of
                select="count(//define[starts-with(@name, 'model.')])"/>
            </xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>****</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:apply-templates select="//define[not(contains(@name, '.'))]"/>
          </schemaSpec>

        </body>
      </text>
    </TEI>
  </xsl:template>

  <!-- Data Template-->
  <xsl:template match="//define[starts-with(@name, 'data.')]">
    <!-- 
            Attributes found in RNG: @name
            Content found in RNG: a:documentation, data, choice, text, list, ref
            
        -->
    <!-- in TEI's ODD, *all* datatype macros have module="tei" 
         This might change if there are datatypes specific to certain modules. i.e. mensural, neume -->
    <macroSpec module="mei" type="dt" ident="{@name}">
      <desc>
        <xsl:apply-templates select="a:documentation"/>
      </desc>
      <content>
        <xsl:for-each select="* except a:documentation">
          <xsl:call-template name="make-namespace-node">
            <xsl:with-param name="recursive" select="true()"/>
          </xsl:call-template>
        </xsl:for-each>
      </content>
    </macroSpec>
  </xsl:template>

  <!-- Attributes Template -->
  <xsl:template match="//define[starts-with(@name, 'att.')]">
    <!-- 
            Attributes found in RNG: @name
            Content found in RNG: a:documentation, optional, ref, attribute, empty 
        -->
    <classSpec type="atts" ident="{@name}">
      <desc>
        <xsl:apply-templates select="a:documentation"/>
      </desc>
      <!-- 
                N.B. ignoring child::empty -> does it make sense to have an empty attribute?
            -->
      <xsl:if test="ref">
        <classes>
          <xsl:for-each select="ref">
            <memberOf key="{@name}"/>
          </xsl:for-each>
        </classes>
      </xsl:if>
      <xsl:if test="descendant::attribute">
        <attList>
          <xsl:for-each select="descendant::attribute">

            <attDef>
              <!-- Convert 
                                att.common.attribute.id -> att.common.attribute.xml:id
                                att.lang.attribute.lang -> att.lang.attribute.xml:lang 
                            when found -->
              <xsl:attribute name="ident">
                <xsl:choose>
                  <xsl:when test="@name='id'">
                    <xsl:text>xml:id</xsl:text>
                  </xsl:when>
                  <xsl:when test="@name='lang'">
                    <xsl:text>xml:lang</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="@name"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <xsl:choose>
                <xsl:when test="parent::optional">
                  <xsl:attribute name="usage">opt</xsl:attribute>
                </xsl:when>
                <xsl:when test="parent::define">
                  <xsl:attribute name="usage">req</xsl:attribute>
                </xsl:when>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="data | ref">
                  <datatype>
                    <!-- N.B. attributes like @maxoccurs are available here, are they used for lists in PR's rng? -->
                    <xsl:for-each select="data | ref">
                      <xsl:call-template name="make-namespace-node">
                        <xsl:with-param name="recursive"/>
                      </xsl:call-template>
                    </xsl:for-each>
                  </datatype>
                </xsl:when>

                <!-- N.B. even closed lists can have a <datatype> specified in ODD -->
                <xsl:when test="value">
                  <defaultVal>
                    <xsl:value-of select="value"/>
                  </defaultVal>
                  <valList type="closed">
                    <valItem ident="{value}"/>
                  </valList>
                </xsl:when>
                <xsl:when test="choice">
                  <xsl:if test="@a:defaultValue">
                    <defaultVal>
                      <xsl:value-of select="@a:defaultValue"/>
                    </defaultVal>
                  </xsl:if>
                  <valList>
                    <xsl:attribute name="type">
                      <xsl:choose>
                        <xsl:when test="choice[not(text)]">
                          <xsl:text>closed</xsl:text>
                        </xsl:when>
                        <!-- not present in attribute definitions... -->
                        <xsl:when test="choice[text]">
                          <xsl:text>semi</xsl:text>
                        </xsl:when>
                      </xsl:choose>
                    </xsl:attribute>
                    <xsl:for-each select="choice/text">
                      <xsl:call-template name="make-namespace-node"/>
                    </xsl:for-each>
                    <xsl:for-each select="choice/value">
                      <valItem ident="{.}"/>
                    </xsl:for-each>
                  </valList>
                </xsl:when>
              </xsl:choose>
            </attDef>
          </xsl:for-each>
        </attList>
      </xsl:if>
    </classSpec>
  </xsl:template>

  <!-- MODELS and MACROS -->
  <xsl:template match="//define[starts-with(@name, 'model.')]">
    <!-- 
            Attributes found in RNG: @name
            Content found in RNG: ref, choice, optional, zeroOrMore
        -->
    <!-- 
            Determine if it's an ODD model or macro 
            (N.B.: Conditions in this switch *must* match the conditions in the suffix switch in xsl:template name="make-namespace-node" above.)
        -->

    <xsl:choose>
      <!-- This switch is based on the conditions expressed in xsl:template name="make-namespace-node" above. -->
      <xsl:when
        test="(ref)
                            or
                            (choice)
                            or
                            (optional and not(optional/*[not(self::ref)]) and not(zeroOrMore))
                            or
                            (zeroOrMore and not(zeroOrMore/*[not(self::ref)]) and not(optional))">
        <classSpec type="model" ident="{@name}">
          <xsl:variable name="model-name" select="@name"/>
          <desc>
            <xsl:apply-templates select="a:documentation"/>
          </desc>
          <!-- 
                        Memebrship to other Model Classes
                    -->
          <classes>
            <xsl:for-each
              select="ancestor::grammar//define[starts-with(@name, 'model.')]//ref[@name=$model-name]">
              <memberOf key="{ancestor::define/@name}"/>
            </xsl:for-each>
          </classes>
        </classSpec>
      </xsl:when>
      <!-- If it doens't fit in any of the previous cases, it's a macro -->
      <xsl:otherwise>
        <macroSpec type="pe" ident="macro.{substring-after(@name, 'model.')}">
          <desc>
            <xsl:apply-templates select="a:documentation"/>
          </desc>
          <content>
            <xsl:for-each select="*[not(self::a:documentation)]">
              <xsl:call-template name="make-namespace-node">
                <xsl:with-param name="handle-models" select="true()"/>
                <xsl:with-param name="recursive" select="true()"/>
              </xsl:call-template>
            </xsl:for-each>
          </content>
        </macroSpec>
      </xsl:otherwise>
    </xsl:choose>



  </xsl:template>

  <!-- ELEMENTS -->
  <xsl:template match="//define[not(contains(@name, '.'))]">
    <!-- 
            Attributes found in RNG: @name
            Content found in RNG: zeroOrMore|oneOrMoreref|empty|ref|optional|choice|text 
        -->
    <xsl:variable name="element-name" select="@name"/>
    <elementSpec ident="{@name}">
      <desc>
        <xsl:apply-templates select="element/a:documentation"/>
      </desc>
      <!-- 
                N.B. ignoring child::empty -> does it make sense to have an empty attribute?
            -->
      <xsl:if test="ancestor::grammar//define[@name=concat('attlist.',$element-name)]/ref">
        <classes>
          <xsl:for-each
            select="ancestor::grammar//define[@name=concat('attlist.',$element-name)]/ref">
            <memberOf key="{@name}"/>
          </xsl:for-each>
          <!-- 
                    Membership to Model Classes
                    -->
          <xsl:for-each
            select="ancestor::grammar//define[starts-with(@name, 'model.')]//ref[@name=$element-name]">
            <memberOf key="{ancestor::define/@name}"/>
          </xsl:for-each>
        </classes>
      </xsl:if>

      <content>
        <!-- Pulled from content.{@name} -->
        <xsl:for-each
          select="ancestor::grammar//define[@name=concat('content.',$element-name)]/*[not(self::a:documentation)]">
          <!-- copy the rng <ref>s but handle ODD suffixes for references to models. -->
          <xsl:call-template name="make-namespace-node">
            <xsl:with-param name="handle-models" select="true()"/>
            <xsl:with-param name="recursive" select="true()"/>
          </xsl:call-template>
        </xsl:for-each>
        <!-- other refs in element declaration that are not contained in content.{@name} -->
        <xsl:for-each
          select="element/*[not(self::ref[starts-with(@name, 'attlist.') or starts-with(@name, 'content.')]) and not(self::a:documentation)]">
          <xsl:call-template name="make-namespace-node">
            <xsl:with-param name="handle-models" select="true()"/>
            <xsl:with-param name="recursive" select="true()"/>
          </xsl:call-template>
        </xsl:for-each>
      </content>

      <!-- Schematron rules -->
      <xsl:for-each
        select="ancestor::grammar//sch:pattern/sch:rule">
        <xsl:variable name="context_nrml" select="normalize-space(@context)"/>
        
        <xsl:choose>
          <!-- If the current element is mei, add all generic patterns -->
          <xsl:when test="$element-name = 'mei' and starts-with($context_nrml, '*')">
              <constraintSpec
                ident="{
                if (parent::sch:pattern/sch:title != '') 
                then translate(translate(normalize-space(parent::sch:pattern/sch:title), ' ', '_'), '/\@:()[]', '') 
                else 'generic_rule-no_title'
                }"
                scheme="isoschematron">
                <constraint>
                  
                  <xsl:message>
                    <xsl:text>Adding generic schematron rule</xsl:text>
                    <xsl:text> from context: </xsl:text>
                    <xsl:text>'</xsl:text>
                    <xsl:value-of select="$context_nrml"/>
                    <xsl:text>'</xsl:text>
                  </xsl:message>
                  
                  <xsl:element name="sch:rule" namespace="http://purl.oclc.org/dsdl/schematron">
                    <xsl:sequence select="@* except @context"/>
                    <xsl:attribute name="context">
                        <xsl:text>mei:</xsl:text>
                        <xsl:value-of select="@context"/>
                    </xsl:attribute>
                    <xsl:for-each select="*">
                      <xsl:copy-of select="." copy-namespaces="no"/>
                    </xsl:for-each>
                  </xsl:element>
                  
                </constraint>
              </constraintSpec>
          </xsl:when>
          <!-- Other specific patterns -->
          <xsl:when test="
            matches($context_nrml, concat('^\s?', $element-name, '\s?$'))
            or matches($context_nrml, concat('^\s?', $element-name, '\s?\|'))
            or matches($context_nrml, concat('\|\s?', $element-name, '\s?$'))
            or matches($context_nrml, concat('\|\s?', $element-name, '\s?\|'))
            or ( matches($context_nrml, concat('^\s?', $element-name, '\s?\[.*\]\s?$')) and not(matches($context_nrml, '\|')) )
            or matches($context_nrml, concat('^\s?', $element-name, '\s?\[.*\]\s?\|'))
            or matches($context_nrml, concat('\|\s?', $element-name, '\s?\[.*\]\s?$'))
            or matches($context_nrml, concat('\|\s?', $element-name, '\s?\[.*\]\s?\|'))
            ">
            <constraintSpec
              ident="{
              if (parent::sch:pattern/sch:title != '') 
              then translate(translate(normalize-space(parent::sch:pattern/sch:title), ' ', '_'), '/\@:()[]', '') 
              else 'no_title'
              }"
              scheme="isoschematron">
              <constraint>
                
                <xsl:message>
                  <xsl:text>Adding schematron rule for element: </xsl:text>
                  <xsl:value-of select="$element-name"/>
                  <xsl:text> from rule context: </xsl:text>
                  <xsl:text>'</xsl:text>
                  <xsl:value-of select="$context_nrml"/>
                  <xsl:text>'</xsl:text>
                </xsl:message>
                
                <xsl:element name="sch:rule" namespace="http://purl.oclc.org/dsdl/schematron">
                  <xsl:sequence select="@* except @context"/>
                  <xsl:attribute name="context">
                    <xsl:choose>
                      <xsl:when test="contains($context_nrml, '|')">
                        <xsl:for-each select="tokenize($context_nrml, '\|')">
                          <xsl:if test="matches(., concat('^\s?', $element-name, '(\s?\[.*\])?\s?$'))">
                            <xsl:text>mei:</xsl:text>
                            <xsl:value-of select="replace(., '^\s', '')"/>
                          </xsl:if>
                        </xsl:for-each>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text>mei:</xsl:text>
                        <xsl:value-of select="@context"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                  <xsl:for-each select="*">
                    <xsl:copy-of select="." copy-namespaces="no"/>
                  </xsl:for-each>
                </xsl:element>
                
              </constraint>
            </constraintSpec>
          </xsl:when>
          <!-- Not matched (i.e. rule not relevant to the current element)-->
          <xsl:otherwise/>
        </xsl:choose>
        
      </xsl:for-each>

      <!-- Attributes -->
      <xsl:if
        test="ancestor::grammar//define[@name=concat('attlist.',$element-name)]/descendant::attribute">
        <attList>
          <!-- Pulled from attlist.{@name} -->
          <xsl:for-each select="ancestor::grammar//define[@name=concat('attlist.',$element-name)]">

            <xsl:for-each select="descendant::attribute">

              <attDef>
                <!-- Convert 
                                    mei.attribute.id -> mei.attribute.xml:id
                                    meicorpus.attribute.id -> meicorpus.attribute.xml:id
                                    when found -->
                <xsl:attribute name="ident">
                  <xsl:choose>
                    <xsl:when test="@name='id'">
                      <xsl:text>xml:id</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="@name"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
                <xsl:choose>
                  <xsl:when test="parent::optional">
                    <xsl:attribute name="usage">opt</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="parent::define">
                    <xsl:attribute name="usage">req</xsl:attribute>
                  </xsl:when>
                </xsl:choose>
                <xsl:choose>
                  <xsl:when test="data | ref">
                    <datatype>
                      <!-- N.B. attributes like @maxoccurs are available here, are they used for lists in PR's rng? -->
                      <xsl:for-each select="data | ref">
                        <xsl:call-template name="make-namespace-node">
                          <xsl:with-param name="recursive"/>
                        </xsl:call-template>
                      </xsl:for-each>
                    </datatype>
                  </xsl:when>

                  <!-- N.B. even closed lists can have a <datatype> specified in ODD -->
                  <xsl:when test="value">
                    <defaultVal>
                      <xsl:value-of select="value"/>
                    </defaultVal>
                    <valList type="closed">
                      <valItem ident="{value}"/>
                    </valList>
                  </xsl:when>
                  <xsl:when test="choice">
                    <xsl:if test="@a:defaultValue">
                      <defaultVal>
                        <xsl:value-of select="@a:defaultValue"/>
                      </defaultVal>
                    </xsl:if>
                    <valList>
                      <xsl:attribute name="type">
                        <xsl:choose>
                          <xsl:when test="choice[not(text)]">
                            <xsl:text>closed</xsl:text>
                          </xsl:when>
                          <!-- not present in attribute definitions... -->
                          <xsl:when test="choice[text]">
                            <xsl:text>semi</xsl:text>
                          </xsl:when>
                        </xsl:choose>
                      </xsl:attribute>
                      <xsl:for-each select="choice/text">
                        <xsl:call-template name="make-namespace-node"/>
                      </xsl:for-each>
                      <xsl:for-each select="choice/value">
                        <valItem ident="{.}"/>
                      </xsl:for-each>
                    </valList>
                  </xsl:when>
                </xsl:choose>
              </attDef>
            </xsl:for-each>
          </xsl:for-each>
        </attList>
      </xsl:if>
    </elementSpec>
  </xsl:template>

</xsl:stylesheet>
