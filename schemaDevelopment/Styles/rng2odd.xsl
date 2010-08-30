<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns="http://www.tei-c.org/ns/1.0" xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
  xmlns:xhtml="http://www.w3.org/1000/xhtml" xml:lang="en"
  xmlns:sch="http://purl.oclc.org/dsdl/schematron"
  xmlns:loc="http:/local-namespace/"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xpath-default-namespace="http://relaxng.org/ns/structure/1.0">

  <xsl:import href="TEI/xhtml2tei.xsl" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all"/>

  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> 2009</xd:p>
      <xd:p><xd:b>Author:</xd:b> Raffaele Viglianti</xd:p>
      <xd:p><xd:b>Author:</xd:b> Perry Roland</xd:p>
      <xd:p>This script converts ../ModularizationTesting/mei-all.rng into a valid TEI ODD file</xd:p>
      <xd:p>Includes XSLT from TEI <xd:i>xhtml2tei</xd:i>, 
        to convert HTML documentation from the source into TEI.</xd:p>
    </xd:desc>
  </xd:doc>

  <xsl:output encoding="UTF-8" indent="yes" method="xml"/>

  <!-- ********
    Variables 
  ******** -->
  
  <xd:doc>
    <xd:desc><xd:p>New line character for pretty print</xd:p></xd:desc>
  </xd:doc>
  <xsl:variable name="nl" select="'&#10;'"/>

  <xd:doc>
    <xd:desc><xd:p>Relative path to root.</xd:p></xd:desc>
  </xd:doc>
  <xsl:variable name="path_to_root" select="'../'"/>

  <xd:doc>
    <xd:desc>
      <xd:p>Stores names of and relative paths to imported RNG modules.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:variable name="modules">
    <loc:modules>
      <xsl:for-each select="//include[ends-with(@href, '_Module.rng')]">
        <loc:module>
          <loc:name><xsl:value-of select="substring-before(@href, '_Module')"/></loc:name>
          <loc:path>
            <xsl:value-of select="$path_to_root"/>
            <xsl:text>RNG/</xsl:text>
            <xsl:value-of select="@href"/></loc:path>
        </loc:module>
      </xsl:for-each>
    </loc:modules>
  </xsl:variable>

  <xd:doc>
    <xd:desc>
      <xd:p>Stores relative paths to imported RNGs that are note modules.</xd:p>
    </xd:desc>
  </xd:doc>
  <xsl:variable name="other_imports">
    <loc:imports>
      <xsl:for-each select="//include[not(ends-with(@href, '_Module.rng'))]">
        <loc:import>
          <loc:name><xsl:value-of select="substring-before(@href, '.rng')"/></loc:name>
          <loc:path>
            <xsl:value-of select="$path_to_root"/>
            <xsl:text>RNG/</xsl:text>
            <xsl:value-of select="@href"/></loc:path>
        </loc:import>
      </xsl:for-each>
    </loc:imports>
  </xsl:variable>
 
  <xd:doc>
    <xd:desc>
      <xd:p>Aggregates all the documents aggregated. The script will process this variable further.</xd:p>
    </xd:desc>
  </xd:doc>
 <xsl:variable name="aggregation">
   <loc:aggregation>
     <loc:datatypes>
       <xsl:sequence select="document($other_imports//loc:import[loc:name='datatypes']/loc:path)"/>
     </loc:datatypes>
     <loc:schematron>
       <xsl:sequence select="document($other_imports//loc:import[loc:name='coConstraints']/loc:path)"/>
     </loc:schematron>
     <loc:other_imports>
       <xsl:for-each select="$other_imports//loc:import">
         <!-- Exclude datatypes, schematron constraints and defaultClassDecls (empty) -->
         <xsl:if test="loc:name != 'datatypes' and loc:name != 'coConstraints' and loc:name != 'defaultClassDecls'">
          <loc:div name="{loc:name}">
           <xsl:sequence select="document(loc:path)"/></loc:div>
         </xsl:if>
       </xsl:for-each>
     </loc:other_imports>
     <loc:modules>
       <xsl:for-each select="$modules//loc:module">
         <loc:div name="{loc:name}"><xsl:sequence select="document(loc:path)"/></loc:div>
       </xsl:for-each>
     </loc:modules>
   </loc:aggregation>
 </xsl:variable>

<!-- Uncomment this and comment MAIN for debugging $aggregation -->
<!--<xsl:template match="/">
  <xsl:sequence select="$aggregation"/>
  
  <xsl:for-each select="$aggregation//define[starts-with(@name,'model.')][not(zeroOrMore/choice)]">
    <xsl:for-each select="$aggregation//define[starts-with(@name,'content.')]/descendant::ref[@name=current()/@name]">
     
        
        <xsl:choose>
          <xsl:when test="ancestor::choice[parent::zeroOrMore]"><!-\-<xsl:text> YES</xsl:text>-\-></xsl:when>
          <xsl:otherwise>
            <xsl:message><xsl:text>Element: </xsl:text><xsl:value-of select="@name"/>
            <xsl:text> NO</xsl:text>
            <xsl:text>Structure: </xsl:text>
            <xsl:value-of select="parent::*/parent::*/name()"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="parent::*/name()"/></xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      
      
    </xsl:for-each>
  </xsl:for-each>
  
  
</xsl:template>-->


  <!-- ******** 
    Functions 
  ******** -->

  <xd:doc>
    <xd:desc>
      <xd:p>copy an element adding namespace <xd:i>rng</xd:i>.</xd:p>
        <xd:ul>
          <xd:li><xd:b>handle-models</xd:b>: determines ODD suffix when referring models from elements (only used by Element Classes template below; false() by default)</xd:li>
          <xd:li><xd:b>recursive</xd:b>: copy children elements recursively</xd:li>
        </xd:ul>
    </xd:desc>
  </xd:doc>
  <xsl:template name="make-namespace-node">
    <xsl:param name="handle-models" select="false()"/>
    <xsl:param name="recursive"/>
    <!-- Ignoring leftover xhtml documentation -->
    <xsl:if
      test="not(self::*[namespace-uri()='http://www.w3.org/1999/xhtml'])">
      <xsl:element name="rng:{local-name(.)}" exclude-result-prefixes="loc a xhtml xd">
        <xsl:choose>
          <!-- Handle ODD suffix if required -->
          <xsl:when test="$handle-models">
            <xsl:choose>
              <xsl:when test="self::ref and starts-with(@name, 'model.')">
                <xsl:variable name="this-mdl" select="@name"/>
                <xsl:attribute name="name">
                  <!-- Problem with combine interleave. If more than one, the name is repeated. Making sure to get only the first one for now -->
                  <xsl:for-each select="ancestor::loc:aggregation//define[@name=$this-mdl][not(preceding::define[@name=$this-mdl])]">
                    <!-- Determine suffix -->
                    <xsl:variable name="mdlName">
                      <xsl:value-of select="@name"/>
                      <!--<xsl:choose>
                        <xsl:when test="starts-with(ancestor::loc:div/@name, 'shared')">
                          <xsl:value-of select="@name"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="concat(@name, '.', ancestor::loc:div/@name)"/>
                        </xsl:otherwise>
                      </xsl:choose>-->
                    </xsl:variable>
                    <xsl:choose>
                      <!-- one element (no suffix) or choice (default behaviour) -->
                      <xsl:when test="ref or choice">
                        <xsl:value-of select="$mdlName"/>
                      </xsl:when>
                      <!--only one of the members (alternation)-->
                      <!--<xsl:when test="choice">
                        <xsl:value-of select="@name"/>
                        <xsl:text>_alternation</xsl:text>
                      </xsl:when>-->
                      <!-- members may be provided, in sequence, but are optional (sequenceOptional) -->
                      <xsl:when
                        test="optional and not(optional/*[not(self::ref)]) and not(zeroOrMore)">
                        <xsl:value-of select="$mdlName"/>
                        <xsl:text>_sequenceOptional</xsl:text>
                      </xsl:when>
                      <!-- members may be provided one or more times, in sequence, but are optional (sequenceOptionalRepeatable) -->
                      <xsl:when
                        test="zeroOrMore and not(zeroOrMore/*[not(self::ref)]) and not(optional)">
                        <xsl:value-of select="@name"/>
                        <xsl:text>_sequenceOptionalRepeatable</xsl:text>
                      </xsl:when>
                      <xsl:when test="zeroOrMore/choice and not(optional)">
                        <xsl:value-of select="$mdlName"/>
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


  <!-- ********
      MAIN 
  ******** -->
  <xsl:template match="/">

    <!-- Oxygen-specific link to TEI schema. -->
    <xsl:processing-instruction name="oxygen">
      <xsl:text>RNGSchema="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_odds.rng" type="xml"</xsl:text>
    </xsl:processing-instruction>

    <TEI xsl:exclude-result-prefixes="loc a xhtml xd">

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
          <change who="#RV" when="{current-date()}">Integrated modules.</change>
        </revisionDesc>
      </teiHeader>
      <text>
        <front>
          <divGen type="toc"/>
        </front>
        <body>
          <p>MEI</p>

          <!--<schemaSpec ident="mei" start="mei" ns="http://www.mei-c.org/ns/mei">-->

            <!-- MODULES -->
            <xsl:value-of select="$nl"/>
            <xsl:comment>****</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>Modules</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>Number of modules found in original RNG: <xsl:value-of
              select="count($modules//loc:module)"/>
            </xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>****</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:for-each select="$modules//loc:module">
              <moduleSpec ident="{loc:name}">
                <desc>
                  <xsl:apply-templates select="a:documentation"/>
                </desc>
              </moduleSpec>
            </xsl:for-each>

            <!-- DATATYPES -->
            <xsl:value-of select="$nl"/>
            <xsl:comment>****</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>Datatype Macros</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>Number of definitions found in original RNG: <xsl:value-of
                select="count($aggregation//loc:datatypes//define[starts-with(@name, 'data.')])"/>
            </xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>****</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:apply-templates select="$aggregation//loc:datatypes//define[starts-with(@name, 'data.')]"/>

            <!-- ATTRIBUTES -->
            <xsl:value-of select="$nl"/>
            <xsl:comment>****</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>Attribute Classes</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>Number of definitions found in original RNG: <xsl:value-of
                select="count($aggregation//define[starts-with(@name, 'att.')])"/>
            </xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>****</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:apply-templates select="$aggregation//define[starts-with(@name, 'att.')]"/>

            <!--MODELS AND MACROS-->
            <xsl:value-of select="$nl"/>
            <xsl:comment>****</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>Defintion of Model and Macro Classes</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>Number of definitions found in original RNG: <xsl:value-of
                select="count($aggregation//define[starts-with(@name, 'model.')])"/>
            </xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>****</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:apply-templates select="$aggregation//define[starts-with(@name, 'model.')]"/>

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
                select="count($aggregation//define[starts-with(@name, 'model.')])"/>
            </xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:comment>****</xsl:comment>
            <xsl:value-of select="$nl"/>
            <xsl:apply-templates select="$aggregation//define[not(contains(@name, '.'))]"/>
          <!--</schemaSpec>-->

        </body>
      </text>
    </TEI>
    
    <!-- CREATE STANDARD CUSTOMISATIONS -->
    <xsl:result-document href="../ODD/mei-all.xml">
      <xsl:processing-instruction name="oxygen">
        <xsl:text>RNGSchema="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="xml"</xsl:text>
      </xsl:processing-instruction>
      <TEI xmlns:rng="http://relaxng.org/ns/structure/1.0"
        xmlns="http://www.tei-c.org/ns/1.0"  xsl:exclude-result-prefixes="loc a xhtml xd">
        <teiHeader>
          <fileDesc>
            <titleStmt>
              <title>MEI (Music Encoding Initiative) - ALL</title>
              <respStmt>
                <resp>Authored by</resp>
                <name xml:id="RV">Raffaele Viglianti</name>
              </respStmt>
            </titleStmt>
            <publicationStmt>
              <p>Automatically Generated</p>
            </publicationStmt>
            <sourceDesc>
              <p>created on 2010-08-26T22:09:54.285+02:00</p>
            </sourceDesc>
          </fileDesc>
        </teiHeader>
        <text>
          <front>
            <divGen type="toc"/>
          </front>
          <body>
            
            <schemaSpec ident="mei" start="mei" ns="http://www.music-encoding.org/ns/mei">
              
              <moduleRef key="MEI.shared"/>
              <moduleRef key="MEI.header"/>
              <moduleRef key="MEI.cmn"/>
              <moduleRef key="MEI.mensural"/>
              <moduleRef key="MEI.neumes"/>
              <moduleRef key="MEI.analysis"/>
              <moduleRef key="MEI.cmnOrnaments"/>
              <moduleRef key="MEI.corpus"/>
              <moduleRef key="MEI.critapp"/>
              <moduleRef key="MEI.edittrans"/>
              <moduleRef key="MEI.facsimile"/>
              <moduleRef key="MEI.figtable"/>
              <moduleRef key="MEI.harmony"/>
              <moduleRef key="MEI.linkalign"/>
              <moduleRef key="MEI.lyrics"/>
              <moduleRef key="MEI.midi"/>
              <moduleRef key="MEI.namesdates"/>
              <moduleRef key="MEI.ptrref"/>
              <moduleRef key="MEI.tablature"/>
              <moduleRef key="MEI.text"/>
              <moduleRef key="MEI.usersymbols"/>
              
            </schemaSpec>
            
          </body></text></TEI>
    </xsl:result-document>
    
  </xsl:template>

  <!-- Data Template-->
  <xsl:template match="//define[starts-with(@name, 'data.')]">
    <!-- in TEI's ODD, *all* datatype macros have module="tei" 
         This might change if there are datatypes specific to certain modules. i.e. mensural, neume -->
    <macroSpec module="mei" type="dt" ident="{@name}" xsl:exclude-result-prefixes="loc a xhtml xd">
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
    <xsl:variable name="thisAtt" select="@name"/>
    <classSpec type="atts" module="MEI.{ancestor::loc:div/@name}" xsl:exclude-result-prefixes="loc a xhtml xd">
      <!-- Handling att.stemmed, the only attribute class with @combine -->
      <xsl:attribute name="ident">
        <xsl:value-of select="@name"/>
        <xsl:if test="@name='att.stemmed' and ancestor::loc:div/@name='cmn'">
          <xsl:text>.cmn</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <desc>
        <xsl:apply-templates select="a:documentation"/>
      </desc>
      <!-- 
                N.B. ignoring child::empty -> does it make sense to have an empty attribute?
            -->
      <xsl:if test="ref">
        <classes>
          <xsl:variable name="modulesnames">
            <xsl:text>_</xsl:text>
            <xsl:for-each select="$modules//loc:module/loc:name">
              <xsl:value-of select="concat(.,'_')"/>
            </xsl:for-each>
          </xsl:variable>
          
          <xsl:for-each select="ref">
            <!--<xsl:if test="not(contains($modulesnames, concat('_', substring-after(@name, concat($thisAtt, '.')), '_')))">-->
              <memberOf key="{@name}"/>
          </xsl:for-each>
          
          <!--<xsl:if test="contains($modulesnames, concat('_', tokenize(@name, '\.')[last()], '_'))">
            <memberOf key="{substring-before(@name, concat('.', tokenize(@name, '\.')[last()]))}"/>
          </xsl:if>-->
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
              <xsl:if test="@ns='http://www.w3.org/1999/xlink'">
                <xsl:sequence select="@ns"/>
              </xsl:if>
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
                        <xsl:with-param name="recursive" select="true()"/>
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
    <!--<xsl:message>
      <xsl:value-of select="@name"/><xsl:text> from:</xsl:text>
      <xsl:value-of select="ancestor::loc:div/@name"/>      
    </xsl:message>-->
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
              (zeroOrMore and not(zeroOrMore/*[not(self::ref)]) and not(optional))
              or
              (zeroOrMore/choice and not (optional))">
        <classSpec type="model" ident="{@name}" module="MEI.{ancestor::loc:div/@name}" xsl:exclude-result-prefixes="loc a xhtml xd">
          <!-- If not in shared_Module, add module name to element. Attempt to avoid combine problems? Killed for now -->
          <!--<xsl:attribute name="ident">
            <xsl:choose>
              <xsl:when test="starts-with(ancestor::loc:div/@name, 'shared')">
                <xsl:value-of select="@name"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@name"/>
                <xsl:text>.</xsl:text>
                <xsl:value-of select="ancestor::loc:div/@name"/>
              </xsl:otherwise>
          </xsl:choose>
          </xsl:attribute>-->
          <xsl:variable name="model-name" select="@name"/>
          <desc>
            <xsl:apply-templates select="a:documentation"/>
          </desc>
          <!--  Memebrship to other Model Classes -->
          <xsl:if test="ancestor::loc:aggregation//define[starts-with(@name, 'model.')]//ref[@name=$model-name]">
            <classes>
            <xsl:for-each
              select="ancestor::loc:aggregation//define[starts-with(@name, 'model.')]//ref[@name=$model-name]">
              <memberOf key="{ancestor::define/@name}"/>
              
              <!-- If not in shared module, calculate dependecies -->
              <!--<xsl:if test="not(starts-with(ancestor::loc:div/@name, 'shared_'))">
                <memberOf key="{@name}"/>
              </xsl:if>-->
            </xsl:for-each>
            </classes>
          </xsl:if>
        </classSpec>
      </xsl:when>
      <!-- If it doens't fit in any of the previous cases, it's a macro -->
      <xsl:otherwise>
        <xsl:if test="@combine">
          <xsl:message>WARNING: Identified Macro with @combine. Possible model? Name: <xsl:value-of select="@name"/></xsl:message>
        </xsl:if>
        <macroSpec type="pe" ident="macro.{substring-after(@name, 'model.')}"  module="MEI.{ancestor::loc:div/@name}" xsl:exclude-result-prefixes="loc a xhtml xd">
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
    <elementSpec ident="{@name}"  module="MEI.{ancestor::loc:div/@name}" xsl:exclude-result-prefixes="loc a xhtml xd">
      <desc>
        <xsl:apply-templates select="element/a:documentation"/>
      </desc>
      <!-- 
                N.B. ignoring child::empty -> does it make sense to have an empty attribute? May be obsolete
            -->
      <xsl:if test="ancestor::loc:aggregation//define[@name=concat('attlist.',$element-name)]/ref
        | ancestor::loc:aggregation//define[starts-with(@name, 'model.')]//ref[@name=$element-name]">
        <classes>
          <xsl:for-each
            select="ancestor::loc:aggregation//define[@name=concat('attlist.',$element-name)]/ref">
            <memberOf key="{@name}"/>
          </xsl:for-each>
          <!-- 
                    Membership to Model Classes
                    -->
          <xsl:for-each
            select="ancestor::loc:aggregation//define[starts-with(@name, 'model.')]//ref[@name=$element-name]">
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
        select="//loc:schematron//sch:pattern/sch:rule">
        <xsl:variable name="context_nrml" select="normalize-space(@context)"/>
        <!--<xsl:message><xsl:value-of select="$context_nrml"></xsl:value-of></xsl:message>-->
        <xsl:choose>
          <!-- If the current element is mei, add all generic patterns -->
          <xsl:when test="$element-name = 'mei' and starts-with($context_nrml, 'mei:*')">
            
            <constraintSpec ident="set_ns" scheme="isoschematron">
              <constraint>
                <sch:ns uri="http://www.music-encoding.org/ns/mei" prefix="mei"/>
              </constraint>
            </constraintSpec>            
            
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
                  
                  <xsl:element name="sch:rule" namespace="http://purl.oclc.org/dsdl/schematron" exclude-result-prefixes="loc a xhtml xd">
                    <xsl:sequence select="@*"/>
                    <xsl:for-each select="*">
                      <xsl:copy-of select="." copy-namespaces="no"/>
                    </xsl:for-each>
                  </xsl:element>
                  
                </constraint>
              </constraintSpec>
          </xsl:when>
          <!-- Other specific patterns -->
          <xsl:when test="
            matches($context_nrml, concat('^\s?', 'mei:', $element-name, '\s?$'))
            or matches($context_nrml, concat('^\s?', 'mei:', $element-name, '\s?\|'))
            or matches($context_nrml, concat('\|\s?', 'mei:', $element-name, '\s?$'))
            or matches($context_nrml, concat('\|\s?', 'mei:', $element-name, '\s?\|'))
            or ( matches($context_nrml, concat('^\s?', 'mei:', $element-name, '\s?\[.*\]\s?$')) and not(matches($context_nrml, '\|')) )
            or matches($context_nrml, concat('^\s?', 'mei:', $element-name, '\s?\[.*\]\s?\|'))
            or matches($context_nrml, concat('\|\s?', 'mei:', $element-name, '\s?\[.*\]\s?$'))
            or matches($context_nrml, concat('\|\s?', 'mei:', $element-name, '\s?\[.*\]\s?\|'))
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
                
                <xsl:element name="sch:rule" namespace="http://purl.oclc.org/dsdl/schematron" exclude-result-prefixes="loc a xhtml xd">
                  <xsl:sequence select="@* except @context"/>
                  <xsl:attribute name="context">
                    <xsl:choose>
                      <xsl:when test="contains($context_nrml, '|')">
                        <xsl:for-each select="tokenize($context_nrml, '\|')">
                          <xsl:if test="matches(., concat('^\s?', 'mei:', $element-name, '(\s?\[.*\])?\s?$'))">
                            <!--<xsl:text>mei:</xsl:text>--> <!-- obsolete -->
                            <xsl:value-of select="replace(., '^\s', '')"/>
                          </xsl:if>
                        </xsl:for-each>
                      </xsl:when>
                      <xsl:otherwise>
                        <!--<xsl:text>mei:</xsl:text>--> <!-- obsolete -->
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
                          <xsl:with-param name="recursive" select="true()"/>
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
