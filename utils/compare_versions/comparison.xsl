<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:math="http://www.w3.org/2005/xpath-functions/math" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:rng="http://relaxng.org/ns/structure/1.0" xmlns:sch="http://purl.oclc.org/dsdl/schematron" xmlns:xi="http://www.w3.org/2001/XInclude" exclude-result-prefixes="xs math xd mei tei rng sch xi" version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Oct 29, 2018</xd:p>
            <xd:p><xd:b>Author:</xd:b> johannes</xd:p>
            <xd:p></xd:p>
        </xd:desc>
    </xd:doc>

    <!-- TODO: content link to text has no target -->
    <!-- TODO: content link to empty has no target -->
    <!-- TODO: linking v4 element-names are lowercase while v5 are uppercase, this might change in the future, so maybe checking availability or switching between version instead of making a general decision would be beneficial. -->

    <xsl:output method="html" indent="yes"/>

    <xsl:variable name="new.file" select="//tei:back" as="node()"/>
    <xsl:variable name="new.version" select="//tei:attDef[@ident='meiversion']//tei:defaultVal" as="xs:string"/>
    <xsl:variable name="new.version.major" as="xs:string*">
        <xsl:choose>
            <xsl:when test="tokenize($new.version, '-')[2] = 'dev'">
                <!-- use 'dev' if version contains dev -->
                <xsl:value-of select="'dev'"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- otherwise use major version number with leading 'v', e.g. v5 -->
                <xsl:value-of select="concat('v',tokenize($new.version, '\.')[1])"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:param name="old.version.filename" select="''" as="xs:string"/>
    <xsl:variable name="old.file" select="doc($old.version.filename)//tei:back" as="node()"/>
    <xsl:variable name="old.version" select="doc($old.version.filename)//tei:attDef[@ident='meiversion']//tei:defaultVal" as="xs:string"/>
    <xsl:variable name="old.version.major" select="concat('v',tokenize($old.version, '\.')[1])" as="xs:string"/>

    <xsl:variable name="html.guidelines" select="'https://music-encoding.org/guidelines/'"/>
    <xsl:variable name="new.guidelines" select="concat($html.guidelines,$new.version.major)"/>
    <xsl:variable name="old.guidelines" select="concat($html.guidelines,$old.version.major)"/>

    <xsl:param name="output.folder" select="''" as="xs:string"/>
    <xsl:variable name="output" select="concat($output.folder,'comparison_',$new.version.major,'_vs_',$old.version.major, '.html')"/>

    <xsl:template match="/">
        <xsl:result-document href="{$output}">
            ---
            layout: default
            title: "Comparison of MEI v<xsl:value-of select="$new.version"/> and v<xsl:value-of select="$old.version"/>"
            ---
            <div>
                <link rel="stylesheet" href="resources/css/main.css"/>
                <div id="headingArea">
                    <h1>MEI Comparison <br/>
                        <small>
                            <span class="">Version <xsl:value-of select="$new.version"/></span>
                            <span class=""> vs </span>
                            <span class="">Version <xsl:value-of select="$old.version"/></span>
                        </small>
                    </h1>
                </div>
                <div id="chartArea">
                    <div id="chartsBox">
                        <div id="elementsChart" class="chartBox">
                            <label>Elements</label>
                        </div>
                        <div id="attClassesChart" class="chartBox">
                            <label>Attribute Classes</label>
                        </div>
                        <div id="modelClassesChart" class="chartBox">
                            <label>Model Classes</label>
                        </div>
                        <div id="macroChart" class="chartBox">
                            <label>Macro Groups</label>
                        </div>
                        <div id="dataChart" class="chartBox">
                            <label>Data Types</label>
                        </div>
                        <div style="margin-top: -.5rem;">
                            <span class="added sample">added content</span>
                            <span class="changed sample">changed content</span>
                            <span class="removed sample">removed content</span>
                            <span class="unchanged sample">unchanged content</span>
                            <span class="sample">|</span>
                            <span class="sample">click slice to go to section</span>
                        </div>
                    </div>
                </div>
                <xsl:variable name="elements" select="mei:compareElements($new.file,$old.file)" as="node()*"/>
                <xsl:variable name="attClasses" select="mei:compareAttributeClasses($new.file,$old.file)"/>
                <xsl:variable name="modelClasses" select="mei:compareModelClasses($new.file,$old.file)"/>
                <xsl:variable name="macro" select="mei:compareMacroSpec($new.file,$old.file)"/>
                <xsl:variable name="data" select="mei:compareDataSpec($new.file,$old.file)"/>

                <xsl:sequence select="$elements"/>
                <xsl:sequence select="$attClasses"/>
                <xsl:sequence select="$modelClasses"/>
                <xsl:sequence select="$macro"/>
                <xsl:sequence select="$data"/>
                <script src="resources/js/d3.min.js"></script>
                <script>
                    var elements = [
                        {type:'added', count: <xsl:value-of select="count($elements//tr[@class='a'])"/>, ref:'#elementsAdded'},
                        {type:'changed', count: <xsl:value-of select="count($elements//tr[@class='c'])"/>, ref:'#elementsChanged'},
                        {type:'removed', count: <xsl:value-of select="count($elements//tr[@class='r'])"/>, ref:'#elementsRemoved'},
                        {type:'unchanged', count: <xsl:value-of select="count($elements//tr[@class='u'])"/>, ref:'#elementsUnchanged'}
                    ];
                    var attClasses = [
                    {type:'added', count: <xsl:value-of select="count($attClasses//tr[@class='a'])"/>, ref:'#attClassesAdded'},
                    {type:'changed', count: <xsl:value-of select="count($attClasses//tr[@class='c'])"/>, ref:'#attClassesChanged'},
                    {type:'removed', count: <xsl:value-of select="count($attClasses//tr[@class='r'])"/>, ref:'#attClassesRemoved'},
                    {type:'unchanged', count: <xsl:value-of select="count($attClasses//tr[@class='u'])"/>, ref:'#attClassesUnchanged'}
                    ];
                    var modelClasses = [
                    {type:'added', count: <xsl:value-of select="count($modelClasses//tr[@class='a'])"/>, ref:'#modelClassesAdded'},
                    {type:'changed', count: <xsl:value-of select="count($modelClasses//tr[@class='c'])"/>, ref:'#modelClassesChanged'},
                    {type:'removed', count: <xsl:value-of select="count($modelClasses//tr[@class='r'])"/>, ref:'#modelClassesRemoved'},
                    {type:'unchanged', count: <xsl:value-of select="count($modelClasses//tr[@class='u'])"/>, ref:'#modelClassesUnchanged'}
                    ];
                    var macro = [
                    {type:'added', count: <xsl:value-of select="count($macro//tr[@class='a'])"/>, ref:'#macroAdded'},
                    {type:'changed', count: <xsl:value-of select="count($macro//tr[@class='c'])"/>, ref:'#macroChanged'},
                    {type:'removed', count: <xsl:value-of select="count($macro//tr[@class='r'])"/>, ref:'#macroRemoved'},
                    {type:'unchanged', count: <xsl:value-of select="count($macro//tr[@class='u'])"/>, ref:'#macroUnchanged'}
                    ];
                    var data = [
                    {type:'added', count: <xsl:value-of select="count($data//tr[@class='a'])"/>, ref:'#dataSpecAdded'},
                    {type:'changed', count: <xsl:value-of select="count($data//tr[@class='c'])"/>, ref:'#dataSpecChanged'},
                    {type:'removed', count: <xsl:value-of select="count($data//tr[@class='r'])"/>, ref:'#dataSpecRemoved'},
                    {type:'unchanged', count: <xsl:value-of select="count($data//tr[@class='u'])"/>, ref:'#dataSpecUnchanged'}
                    ];
                </script>
                <script src="resources/js/main.js"></script>
            </div>
        </xsl:result-document>
    </xsl:template>

    <xsl:function name="mei:getDesc" as="xs:string">
        <xsl:param name="spec" as="element()"/>
        <xsl:variable name="gloss" select="if($spec/tei:gloss/text()) then('(' || $spec/tei:gloss/text() || ') – ') else()" as="xs:string?"/>
        <xsl:variable name="desc" select="string-join($spec/tei:desc//text(),' ')" as="xs:string"/>
        <xsl:value-of select="normalize-space($gloss || $desc)"/>
    </xsl:function>

    <xsl:function name="mei:compareElements" as="node()*">
        <xsl:param name="new.file" as="node()"/>
        <xsl:param name="old.file" as="node()"/>

        <xsl:variable name="new.elements" select="distinct-values($new.file//tei:elementSpec/@ident)" as="xs:string*"/>
        <xsl:variable name="old.elements" select="distinct-values($old.file//tei:elementSpec/@ident)" as="xs:string*"/>

        <xsl:variable name="added.elements" select="$new.elements[not(. = $old.elements)]" as="xs:string*"/>
        <xsl:variable name="removed.elements" select="$old.elements[not(. = $new.elements)]" as="xs:string*"/>
        <xsl:variable name="kept.elements" select="$new.elements[. = $old.elements]" as="xs:string*"/>
        <xsl:variable name="modified.elements" as="node()*">
            <xsl:for-each select="$kept.elements">
                <xsl:variable name="current.element" select="." as="xs:string"/>
                <xsl:variable name="new.element" select="$new.file//tei:elementSpec[@ident = $current.element]" as="node()"/>
                <xsl:variable name="old.element" select="$old.file//tei:elementSpec[@ident = $current.element]" as="node()"/>

                <xsl:variable name="new.memberships" select="$new.element//tei:memberOf/@key" as="xs:string*"/>
                <xsl:variable name="old.memberships" select="$old.element//tei:memberOf/@key" as="xs:string*"/>
                <xsl:variable name="lowercased.new.memberships" select="$new.element//tei:memberOf/lower-case(@key)" as="xs:string*"/>
                <xsl:variable name="lowercased.old.memberships" select="$old.element//tei:memberOf/lower-case(@key)" as="xs:string*"/>

                <xsl:variable name="added.memberships" select="$new.memberships[not(. = $old.memberships) and not(lower-case(.) = $lowercased.old.memberships)]" as="xs:string*"/>
                <xsl:variable name="removed.memberships" select="$old.memberships[not(. = $new.memberships) and not(lower-case(.) = $lowercased.new.memberships)]" as="xs:string*"/>
                <xsl:variable name="casechanged.memberships" select="$new.memberships[not(. = $old.memberships) and lower-case(.) = $lowercased.old.memberships]" as="xs:string*"/>

                <xsl:variable name="new.desc" select="mei:getDesc($new.element)" as="xs:string"/>
                <xsl:variable name="old.desc" select="mei:getDesc($old.element)" as="xs:string"/>

                <xsl:variable name="new.content" as="xs:string*">
                    <xsl:if test="$new.element/tei:content//rng:text">
                        <xsl:value-of select="'text'"/>
                    </xsl:if>
                    <xsl:if test="$new.element/tei:content//(tei:empty|rng:empty)">
                        <xsl:value-of select="'empty'"/>
                    </xsl:if>
                    <xsl:sequence select="$new.element/tei:content//rng:ref/@name"/>
                </xsl:variable>
                <xsl:variable name="old.content" as="xs:string*">
                    <xsl:if test="$old.element/tei:content//rng:text">
                        <xsl:value-of select="'text'"/>
                    </xsl:if>
                    <xsl:if test="$old.element/tei:content//(tei:empty|rng:empty)">
                        <xsl:value-of select="'empty'"/>
                    </xsl:if>
                    <xsl:sequence select="$old.element/tei:content//rng:ref/@name"/>
                </xsl:variable>
                <xsl:variable name="lowercased.new.content" as="xs:string*">
                    <xsl:if test="$new.element/tei:content//rng:text">
                        <xsl:value-of select="'text'"/>
                    </xsl:if>
                    <xsl:if test="$new.element/tei:content//(tei:empty|rng:empty)">
                        <xsl:value-of select="'empty'"/>
                    </xsl:if>
                    <xsl:sequence select="$new.element/tei:content//rng:ref/lower-case(@name)"/>
                </xsl:variable>
                <xsl:variable name="lowercased.old.content" as="xs:string*">
                    <xsl:if test="$old.element/tei:content//rng:text">
                        <xsl:value-of select="'text'"/>
                    </xsl:if>
                    <xsl:if test="$old.element/tei:content//(tei:empty|rng:empty)">
                        <xsl:value-of select="'empty'"/>
                    </xsl:if>
                    <xsl:sequence select="$old.element/tei:content//rng:ref/lower-case(@name)"/>
                </xsl:variable>

                <xsl:variable name="added.content" select="$new.content[not(. = $old.content) and not(lower-case(.) = $lowercased.old.content)]" as="xs:string*"/>
                <xsl:variable name="removed.content" select="$old.content[not(. = $new.content) and not(lower-case(.) = $lowercased.new.content)]" as="xs:string*"/>
                <xsl:variable name="casechanged.content" select="$new.content[not(. = $old.content) and lower-case(.) = $lowercased.old.content]" as="xs:string*"/>

                <xsl:variable name="new.atts" as="node()*">
                    <xsl:sequence select="$new.element//tei:attDef"/>
                    <xsl:sequence select="for $attClass in $new.element//tei:memberOf[starts-with(@key,'att.')]/@key return mei:resolveAttClass($attClass,$new.file)"/>
                </xsl:variable>
                <xsl:variable name="old.atts" as="node()*">
                    <xsl:sequence select="$old.element//tei:attDef"/>
                    <xsl:sequence select="for $attClass in $old.element//tei:memberOf[starts-with(@key,'att.')]/@key return mei:resolveAttClass($attClass,$old.file)"/>
                </xsl:variable>

                <xsl:variable name="added.atts" select="$new.atts[not(@ident = $old.atts/@ident) and not(lower-case(@ident) = $old.atts/lower-case(@ident))]" as="node()*"/>
                <xsl:variable name="removed.atts" select="$old.atts[not(@ident = $new.atts/@ident) and not(lower-case(@ident) = $new.atts/lower-case(@ident))]" as="node()*"/>
                <xsl:variable name="changed.atts" as="node()*">
                    <xsl:for-each select="$new.atts[lower-case(@ident) = $old.atts/lower-case(@ident)]">
                        <!-- check attributes here -->
                        <xsl:variable name="this.att" select="." as="node()"/>
                        <xsl:variable name="other.att" select="$old.atts[lower-case(@ident) = lower-case($this.att/@ident)]" as="node()"/>
                        <xsl:variable name="comp1" as="node()">
                            <attDef xmlns="http://www.tei-c.org/ns/1.0" ident="{$this.att/@ident}" xsl:exclude-result-prefixes="tei rng sch xi">
                                <xsl:variable name="prep" as="node()*">
                                    <xsl:apply-templates select="$this.att/node()" mode="prep" exclude-result-prefixes="#all"/>
                                </xsl:variable>
                                <xsl:apply-templates select="$prep" mode="simplify-space" exclude-result-prefixes="#all"/>
                            </attDef>
                        </xsl:variable>
                        <xsl:variable name="comp2" as="node()">
                            <attDef xmlns="http://www.tei-c.org/ns/1.0" ident="{$other.att/@ident}" xsl:exclude-result-prefixes="tei rng sch xi">
                                <xsl:variable name="prep" as="node()*">
                                    <xsl:apply-templates select="$other.att/node()" mode="prep" exclude-result-prefixes="#all"/>
                                </xsl:variable>
                                <xsl:apply-templates select="$prep" mode="simplify-space" exclude-result-prefixes="#all"/>
                            </attDef>
                        </xsl:variable>
                        <!--<xsl:if test="$this.att/@ident = 'ho'">
                            <xsl:message select="$comp1"/>
                            <xsl:message select="$comp2" terminate="yes"/>
                        </xsl:if>-->
                        <xsl:choose>
                            <xsl:when test="not(deep-equal($comp1,$comp2))">
                                <xsl:message select="$comp1"/>
                                <xsl:message select="$comp2"/>
                                <xsl:sequence select="."/>
                            </xsl:when>
                        </xsl:choose>

                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="unchanged.atts" select="$new.atts[not(@ident = $changed.atts/@ident)]" as="node()*"/>

                <xsl:if test="count($added.memberships) gt 0 
                    or count($removed.memberships) gt 0 
                    or count($casechanged.memberships) gt 0
                    or count($added.content) gt 0
                    or count($removed.content) gt 0
                    or count($casechanged.content) gt 0
                    or count($added.atts) gt 0
                    or count($removed.atts) gt 0
                    or count($changed.atts) gt 0">
                    <tr class="c" id="{$current.element}">
                        <td class="element ident">
                            <xsl:value-of select="$current.element"/>
                        </td>
                        <td class="module">
                            <xsl:value-of select="$new.element/@module"/>
                        </td>
                        <td class="desc">
                            <xsl:choose>
                                <xsl:when test="$new.desc != $old.desc">
                                    <span class="removed block">
                                        <xsl:value-of select="$old.desc"/>
                                    </span>
                                    <span class="added block">
                                        <xsl:value-of select="$new.desc"/>
                                    </span>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$new.desc"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td class="classes">Classes:<br/>
                            <ul>
                                <xsl:for-each select="$new.memberships">
                                    <xsl:variable name="current.class" select="." as="xs:string"/>
                                    <xsl:choose>
                                        <xsl:when test="$current.class = $added.memberships">
                                            <li class="added" title="added class">
                                                <a href="#{$current.class}">
                                                    <xsl:value-of select="$current.class"/>
                                                </a>
                                            </li>
                                        </xsl:when>
                                        <xsl:when test="$current.class = $casechanged.memberships">
                                            <li class="casechanged" title="was: {$old.memberships[lower-case(.) = lower-case($current.class)]}">
                                                <a href="#{$current.class}">
                                                    <xsl:value-of select="$current.class"/>
                                                </a>
                                            </li>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <li class="unchanged">
                                                <xsl:value-of select="$current.class"/>
                                            </li>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                                <xsl:for-each select="$removed.memberships">
                                    <li class="removed" title="removed class">
                                        <a href="#{.}">
                                            <xsl:value-of select="."/>
                                        </a>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </td>
                        <td class="content">Content:<br/>
                            <ul>
                                <xsl:for-each select="$new.content">
                                    <xsl:variable name="current.content" select="." as="xs:string"/>
                                    <xsl:choose>
                                        <xsl:when test="$current.content= $added.content">
                                            <li class="added" title="added content">
                                                <a href="#{$current.content}">
                                                    <xsl:value-of select="$current.content"/>
                                                </a>
                                            </li>
                                        </xsl:when>
                                        <xsl:when test="$current.content = $casechanged.content">
                                            <li class="casechanged" title="was: {$old.content[lower-case(.) = lower-case($current.content)]}">
                                                <a href="#{$current.content}">
                                                    <xsl:value-of select="$current.content"/>
                                                </a>
                                            </li>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <li class="unchanged">
                                                <xsl:value-of select="$current.content"/>
                                            </li>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                                <xsl:for-each select="$removed.content">
                                    <li class="removed" title="removed content">
                                        <a href="#{.}">
                                            <xsl:value-of select="."/>
                                        </a>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </td>
                        <td class="atts">Attributes:<br/>
                            <ul>
                                <xsl:for-each select="$new.atts/@ident">
                                    <xsl:variable name="current.att" select="." as="xs:string"/>
                                    <xsl:choose>
                                        <xsl:when test="$current.att = $added.atts/@ident">
                                            <li class="added" title="added attribute">
                                                <span class="attribute">
                                                    <a href="{$new.guidelines}/elements/{$current.element}.html" target="_blank">
                                                        <xsl:value-of select="$current.att"/>
                                                    </a>
                                                </span>
                                            </li>
                                            <!-- TODO: linking does not work here since there is no target to point to -->
                                        </xsl:when>
                                        <xsl:when test="$current.att = $changed.atts/@ident">
                                            <li class="changed" title="changed attribute">
                                                <span class="attribute">
                                                    <a href="{$new.guidelines}/elements/{$current.element}.html" target="_blank">
                                                        <xsl:value-of select="$current.att"/>
                                                    </a>
                                                </span>
                                            </li>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <li class="unchanged">
                                                <span class="attribute">
                                                    <xsl:value-of select="$current.att"/>
                                                </span>
                                            </li>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                                <xsl:for-each select="$removed.atts/@ident">
                                    <li class="removed" title="removed attribute">
                                        <span class="attribute">
                                            <a href="{$old.guidelines}/elements/{lower-case($current.element)}.html" target="_blank">
                                                <xsl:value-of select="."/>
                                            </a>
                                        </span>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </td>
                    </tr>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="unchanged.elements" select="$kept.elements[not(. = $modified.elements//td[@class='element ident']/text())]" as="xs:string*"/>

        <h2>Element Comparison</h2>
        <h3 id="elementsAdded"><xsl:value-of select="count($added.elements)"/> new elements:</h3>
        <table class="added">
            <xsl:for-each select="$added.elements">
                <xsl:variable name="current.element" select="." as="xs:string"/>
                <xsl:variable name="elementSpec" select="$new.file//tei:elementSpec[@ident = $current.element]" as="node()"/>
                <tr class="a" id="{$current.element}">
                    <td class="element ident">
                        <a href="{$new.guidelines}/elements/{$current.element}.html" target="_blank">
                            <xsl:value-of select="$current.element"/>
                        </a>
                    </td>
                    <td class="module">
                        <xsl:value-of select="$elementSpec/@module"/>
                    </td>
                    <td>
                        <xsl:value-of select="string-join($elementSpec/tei:desc//text(),' ')"/>
                    </td>
                    <td>
                        <a href="{$new.guidelines}/elements/{$current.element}.html" target="_blank">visit guidelines</a>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
        <h3 id="elementsRemoved"><xsl:value-of select="count($removed.elements)"/> removed elements:</h3>
        <table class="removed">
            <xsl:for-each select="$removed.elements">
                <xsl:variable name="current.element" select="." as="xs:string"/>
                <xsl:variable name="elementSpec" select="$old.file//tei:elementSpec[@ident = $current.element]" as="node()"/>
                <tr class="r" id="{$current.element}">
                    <td class="element ident">
                        <xsl:value-of select="$current.element"/>
                    </td>
                    <td class="module">
                        <xsl:value-of select="$elementSpec/@module"/>
                    </td>
                    <td>
                        <xsl:value-of select="string-join($elementSpec/tei:desc//text(),' ')"/>
                    </td>
                    <td>
                        <a href="{$old.guidelines}/elements/{lower-case($current.element)}.html" target="_blank">visit guidelines</a>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
        <h3 id="elementsChanged"><xsl:value-of select="count($modified.elements)"/> modified elements:</h3>
        <table>
            <xsl:sequence select="$modified.elements"/>
        </table>
        <h3 id="elementsUnchanged"><xsl:value-of select="count($unchanged.elements)"/> unchanged elements:</h3>
        <table>
            <xsl:for-each select="$unchanged.elements">
                <xsl:variable name="current.element" select="." as="xs:string"/>
                <xsl:variable name="elementSpec" select="$new.file//tei:elementSpec[@ident = $current.element]" as="node()"/>
                <tr class="u">
                    <td class="element ident">
                        <xsl:value-of select="$current.element"/>
                    </td>
                    <td class="module unchanged">
                        <xsl:value-of select="$elementSpec/@module"/>
                    </td>
                    <td class="unchanged">
                        <xsl:value-of select="string-join($elementSpec/tei:desc//text(),' ')"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:function>

    <xsl:function name="mei:compareAttributeClasses" as="node()*">
        <xsl:param name="new.file" as="node()"/>
        <xsl:param name="old.file" as="node()"/>

        <xsl:variable name="new.attributes" select="distinct-values($new.file//tei:classSpec[@type = 'atts']/@ident)" as="xs:string*"/>
        <xsl:variable name="old.attributes" select="distinct-values($old.file//tei:classSpec[@type = 'atts']/@ident)" as="xs:string*"/>

        <xsl:variable name="added.attributes" select="$new.attributes[not(. = $old.attributes)]" as="xs:string*"/>
        <xsl:variable name="removed.attributes" select="$old.attributes[not(. = $new.attributes)]" as="xs:string*"/>
        <xsl:variable name="kept.attributes" select="$new.attributes[. = $old.attributes]" as="xs:string*"/>
        <xsl:variable name="modified.attributes" as="node()*">
            <xsl:for-each select="$kept.attributes">
                <xsl:variable name="current.attribute" select="." as="xs:string"/>
                <xsl:variable name="new.attribute" select="$new.file//tei:classSpec[@type = 'atts' and @ident = $current.attribute]" as="node()"/>
                <xsl:variable name="old.attribute" select="$old.file//tei:classSpec[@type = 'atts' and @ident = $current.attribute]" as="node()"/>

                <xsl:variable name="new.memberships" select="$new.attribute//tei:memberOf/@key" as="xs:string*"/>
                <xsl:variable name="old.memberships" select="$old.attribute//tei:memberOf/@key" as="xs:string*"/>
                <xsl:variable name="lowercased.new.memberships" select="$new.attribute//tei:memberOf/lower-case(@key)" as="xs:string*"/>
                <xsl:variable name="lowercased.old.memberships" select="$old.attribute//tei:memberOf/lower-case(@key)" as="xs:string*"/>

                <xsl:variable name="added.memberships" select="$new.memberships[not(. = $old.memberships) and not(lower-case(.) = $lowercased.old.memberships)]" as="xs:string*"/>
                <xsl:variable name="removed.memberships" select="$old.memberships[not(. = $new.memberships) and not(lower-case(.) = $lowercased.new.memberships)]" as="xs:string*"/>
                <xsl:variable name="casechanged.memberships" select="$new.memberships[not(. = $old.memberships) and lower-case(.) = $lowercased.old.memberships]" as="xs:string*"/>

                <xsl:variable name="new.desc" select="string-join($new.attribute/tei:desc//text(),' ')" as="xs:string"/>
                <xsl:variable name="old.desc" select="string-join($old.attribute/tei:desc//text(),' ')" as="xs:string"/>

                <xsl:variable name="new.content" as="xs:string*">
                    <xsl:sequence select="$new.attribute//tei:attDef/@ident"/>
                </xsl:variable>
                <xsl:variable name="old.content" as="xs:string*">
                    <xsl:sequence select="$old.attribute//tei:attDef/@ident"/>
                </xsl:variable>

                <xsl:variable name="added.content" select="$new.content[not(. = $old.content)]" as="xs:string*"/>
                <xsl:variable name="removed.content" select="$old.content[not(. = $new.content)]" as="xs:string*"/>

                <xsl:if test="count($added.memberships) gt 0 
                    or count($removed.memberships) gt 0 
                    or count($casechanged.memberships) gt 0
                    or count($added.content) gt 0
                    or count($removed.content) gt 0">
                    <tr class="c" id="{$current.attribute}">
                        <td class="attClass ident">
                            <xsl:value-of select="$current.attribute"/>
                        </td>
                        <td class="module">
                            <xsl:value-of select="$new.attribute/@module"/>
                        </td>
                        <td class="desc">
                            <xsl:choose>
                                <xsl:when test="$new.desc != $old.desc">
                                    <span class="removed block">
                                        <xsl:value-of select="$old.desc"/>
                                    </span>
                                    <span class="added block">
                                        <xsl:value-of select="$new.desc"/>
                                    </span>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$new.desc"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td class="classes">Classes:<br/>
                            <ul>
                                <xsl:for-each select="$new.memberships">
                                    <xsl:variable name="current.class" select="." as="xs:string"/>
                                    <xsl:choose>
                                        <xsl:when test="$current.class = $added.memberships">
                                            <li class="added" title="added class">
                                                <a href="#{$current.class}">
                                                    <xsl:value-of select="$current.class"/>
                                                </a>
                                            </li>
                                        </xsl:when>
                                        <xsl:when test="$current.class = $casechanged.memberships">
                                            <li class="casechanged" title="was: {$old.memberships[lower-case(.) = lower-case($current.class)]}">
                                                <xsl:value-of select="$current.class"/>
                                            </li>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <li class="unchanged">
                                                <xsl:value-of select="$current.class"/>
                                            </li>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                                <xsl:for-each select="$removed.memberships">
                                    <li class="removed" title="removed class">
                                        <a href="#{.}">
                                            <xsl:value-of select="."/>
                                        </a>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </td>
                        <td class="content">Attributes:<br/>
                            <ul>
                                <xsl:for-each select="$new.content">
                                    <xsl:variable name="current.content" select="." as="xs:string"/>
                                    <xsl:choose>
                                        <xsl:when test="$current.content= $added.content">
                                            <li class="added" title="added attribute">
                                                <span class="attribute">
                                                    <a href="{$new.guidelines}/attribute-classes/{$current.attribute}.html" target="_blank">
                                                        <xsl:value-of select="$current.content"/>
                                                    </a>
                                                </span>
                                            </li>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <li class="unchanged">
                                                <span class="attribute">
                                                    <xsl:value-of select="$current.content"/>
                                                </span>
                                            </li>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                                <xsl:for-each select="$removed.content">
                                    <li class="removed" title="removed attribute">
                                        <span class="attribute">
                                            <a href="{$old.guidelines}/attribute-classes/{lower-case($current.attribute)}.html" target="_blank">
                                                <xsl:value-of select="."/>
                                            </a>
                                        </span>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </td>
                    </tr>
                </xsl:if>


            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="unchanged.attributes" select="$kept.attributes[not(. = $modified.attributes//td[@class='attClass ident']/text())]" as="xs:string*"/>

        <h2>Attribute Class Comparison</h2>
        <h3 id="attClassesAdded"><xsl:value-of select="count($added.attributes)"/> new attribute classes:</h3>
        <table class="added">
            <xsl:for-each select="$added.attributes">
                <xsl:variable name="current.element" select="." as="xs:string"/>
                <xsl:variable name="elementSpec" select="$new.file//tei:classSpec[@type = 'atts' and @ident = $current.element]" as="node()"/>
                <tr class="a" id="{$current.element}">
                    <td class="attClass ident">
                        <xsl:value-of select="$current.element"/>
                    </td>
                    <td class="module">
                        <xsl:value-of select="$elementSpec/@module"/>
                    </td>
                    <td>
                        <xsl:value-of select="string-join($elementSpec/tei:desc//text(),' ')"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
        <h3 id="attClassesRemoved"><xsl:value-of select="count($removed.attributes)"/> removed attribute classes:</h3>
        <table class="removed">
            <xsl:for-each select="$removed.attributes">
                <xsl:variable name="current.element" select="." as="xs:string"/>
                <xsl:variable name="elementSpec" select="$old.file//tei:classSpec[@type = 'atts' and @ident = $current.element]" as="node()"/>
                <tr class="r" id="{$current.element}">
                    <td class="attClass ident">
                        <xsl:value-of select="$current.element"/>
                    </td>
                    <td class="module">
                        <xsl:value-of select="$elementSpec/@module"/>
                    </td>
                    <td>
                        <xsl:value-of select="string-join($elementSpec/tei:desc//text(),' ')"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
        <h3 id="attClassesChanged"><xsl:value-of select="count($modified.attributes)"/> modified attributes classes:</h3>
        <table>
            <xsl:sequence select="$modified.attributes"/>
        </table>
        <h3 id="attClassesUnchanged"><xsl:value-of select="count($unchanged.attributes)"/> unchanged attribute classes:</h3>
        <table>
            <xsl:for-each select="$unchanged.attributes">
                <xsl:variable name="current.element" select="." as="xs:string"/>
                <xsl:variable name="elementSpec" select="$new.file//tei:classSpec[@type = 'atts' and @ident = $current.element]" as="node()"/>
                <tr class="u" id="{$current.element}">
                    <td class="attClass ident">
                        <xsl:value-of select="$current.element"/>
                    </td>
                    <td class="module unchanged">
                        <xsl:value-of select="$elementSpec/@module"/>
                    </td>
                    <td class="unchanged">
                        <xsl:value-of select="string-join($elementSpec/tei:desc//text(),' ')"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:function>

    <xsl:function name="mei:compareModelClasses" as="node()*">
        <xsl:param name="new.file" as="node()"/>
        <xsl:param name="old.file" as="node()"/>

        <xsl:variable name="new.models" select="distinct-values($new.file//tei:classSpec[@type = 'model']/@ident)" as="xs:string*"/>
        <xsl:variable name="old.models" select="distinct-values($old.file//tei:classSpec[@type = 'model']/@ident)" as="xs:string*"/>

        <xsl:variable name="added.models" select="$new.models[not(. = $old.models)]" as="xs:string*"/>
        <xsl:variable name="removed.models" select="$old.models[not(. = $new.models)]" as="xs:string*"/>
        <xsl:variable name="kept.models" select="$new.models[. = $old.models]" as="xs:string*"/>
        <xsl:variable name="modified.models" as="node()*">
            <xsl:for-each select="$kept.models">
                <xsl:variable name="current.model" select="." as="xs:string"/>
                <xsl:variable name="new.model" select="$new.file//tei:classSpec[@type = 'model' and @ident = $current.model]" as="node()"/>
                <xsl:variable name="old.model" select="$old.file//tei:classSpec[@type = 'model' and @ident = $current.model]" as="node()"/>

                <xsl:variable name="new.memberships" select="$new.model//tei:memberOf/@key" as="xs:string*"/>
                <xsl:variable name="old.memberships" select="$old.model//tei:memberOf/@key" as="xs:string*"/>
                <xsl:variable name="lowercased.new.memberships" select="$new.model//tei:memberOf/lower-case(@key)" as="xs:string*"/>
                <xsl:variable name="lowercased.old.memberships" select="$old.model//tei:memberOf/lower-case(@key)" as="xs:string*"/>

                <xsl:variable name="added.memberships" select="$new.memberships[not(. = $old.memberships) and not(lower-case(.) = $lowercased.old.memberships)]" as="xs:string*"/>
                <xsl:variable name="removed.memberships" select="$old.memberships[not(. = $new.memberships) and not(lower-case(.) = $lowercased.new.memberships)]" as="xs:string*"/>
                <xsl:variable name="casechanged.memberships" select="$new.memberships[not(. = $old.memberships) and lower-case(.) = $lowercased.old.memberships]" as="xs:string*"/>

                <xsl:variable name="new.desc" select="string-join($new.model/tei:desc//text(),' ')" as="xs:string"/>
                <xsl:variable name="old.desc" select="string-join($old.model/tei:desc//text(),' ')" as="xs:string"/>

                <xsl:if test="count($added.memberships) gt 0 
                    or count($removed.memberships) gt 0 
                    or count($casechanged.memberships) gt 0">
                    <tr class="c" id="{$current.model}">
                        <td class="modelClass ident">
                            <xsl:value-of select="$current.model"/>
                        </td>
                        <td class="module">
                            <xsl:value-of select="$new.model/@module"/>
                        </td>
                        <td class="desc">
                            <xsl:choose>
                                <xsl:when test="$new.desc != $old.desc">
                                    <span class="removed block">
                                        <xsl:value-of select="$old.desc"/>
                                    </span>
                                    <span class="added block">
                                        <xsl:value-of select="$new.desc"/>
                                    </span>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$new.desc"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td class="classes">Classes:<br/>
                            <ul>
                                <xsl:for-each select="$new.memberships">
                                    <xsl:variable name="current.class" select="." as="xs:string"/>
                                    <xsl:choose>
                                        <xsl:when test="$current.class= $added.memberships">
                                            <li class="added model" title="added model">
                                                <xsl:value-of select="$current.class"/>
                                            </li>
                                        </xsl:when>
                                        <xsl:when test="$current.class = $casechanged.memberships">
                                            <li class="casechanged model" title="was: {$old.memberships[lower-case(.) = lower-case($current.class)]}">
                                                <xsl:value-of select="$current.class"/>
                                            </li>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <li class="unchanged model">
                                                <xsl:value-of select="$current.class"/>
                                            </li>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                                <xsl:for-each select="$removed.memberships">
                                    <li class="removed model" title="removed model">
                                        <xsl:value-of select="."/>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </td>
                    </tr>
                </xsl:if>


            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="unchanged.models" select="$kept.models[not(. = $modified.models//td[@class='modelClass ident']/text())]" as="xs:string*"/>

        <h2>Model Class Comparison</h2>
        <h3 id="modelClassesAdded"><xsl:value-of select="count($added.models)"/> new model classes:</h3>
        <table class="added">
            <xsl:for-each select="$added.models">
                <xsl:variable name="current.element" select="." as="xs:string"/>
                <xsl:variable name="elementSpec" select="$new.file//tei:classSpec[@type = 'model' and @ident = $current.element]" as="node()"/>
                <tr class="a" id="${$current.element}">
                    <td class="modelClass ident">
                        <xsl:value-of select="$current.element"/>
                    </td>
                    <td class="module">
                        <xsl:value-of select="$elementSpec/@module"/>
                    </td>
                    <td>
                        <xsl:value-of select="string-join($elementSpec/tei:desc//text(),' ')"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
        <h3 id="modelClassesRemoved"><xsl:value-of select="count($removed.models)"/> removed model classes:</h3>
        <table class="removed">
            <xsl:for-each select="$removed.models">
                <xsl:variable name="current.element" select="." as="xs:string"/>
                <xsl:variable name="elementSpec" select="$old.file//tei:classSpec[@type = 'model' and @ident = $current.element]" as="node()"/>
                <tr class="r" id="{$current.element}">
                    <td class="modelClass ident">
                        <xsl:value-of select="$current.element"/>
                    </td>
                    <td class="module">
                        <xsl:value-of select="$elementSpec/@module"/>
                    </td>
                    <td>
                        <xsl:value-of select="string-join($elementSpec/tei:desc//text(),' ')"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
        <h3 id="modelClassesChanged"><xsl:value-of select="count($modified.models)"/> modified model classes:</h3>
        <table>
            <xsl:sequence select="$modified.models"/>
        </table>
        <h3 id="modelClassesUnchanged"><xsl:value-of select="count($unchanged.models)"/> unchanged model classes:</h3>
        <table>
            <xsl:for-each select="$unchanged.models">
                <xsl:variable name="current.element" select="." as="xs:string"/>
                <xsl:variable name="elementSpec" select="$new.file//tei:classSpec[@type = 'model' and @ident = $current.element]" as="node()"/>
                <tr class="u" id="{$current.element}">
                    <td class="modelClass ident">
                        <xsl:value-of select="$current.element"/>
                    </td>
                    <td class="module unchanged">
                        <xsl:value-of select="$elementSpec/@module"/>
                    </td>
                    <td class="unchanged">
                        <xsl:value-of select="string-join($elementSpec/tei:desc//text(),' ')"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:function>

    <xsl:function name="mei:compareMacroSpec" as="node()*">
        <xsl:param name="new.file" as="node()"/>
        <xsl:param name="old.file" as="node()"/>

        <xsl:variable name="new.macros" select="distinct-values($new.file//tei:macroSpec[not(@type = 'dt')]/@ident)" as="xs:string*"/>
        <xsl:variable name="old.macros" select="distinct-values($old.file//tei:macroSpec[not(@type = 'dt')]/@ident)" as="xs:string*"/>

        <xsl:variable name="added.macros" select="$new.macros[not(. = $old.macros)]" as="xs:string*"/>
        <xsl:variable name="removed.macros" select="$old.macros[not(. = $new.macros)]" as="xs:string*"/>
        <xsl:variable name="kept.macros" select="$new.macros[. = $old.macros]" as="xs:string*"/>
        <xsl:variable name="modified.macros" as="node()*">
            <xsl:for-each select="$kept.macros">
                <xsl:variable name="current.macro" select="." as="xs:string"/>
                <xsl:variable name="new.model" select="$new.file//tei:macroSpec[not(@type = 'dt') and @ident = $current.macro]" as="node()"/>
                <xsl:variable name="old.model" select="$old.file//tei:macroSpec[not(@type = 'dt') and @ident = $current.macro]" as="node()"/>

                <xsl:variable name="new.content" as="xs:string*">
                    <xsl:sequence select="$new.model//rng:ref[@name != 'macro.anyXML']/@name"/>
                    <xsl:if test="$new.model//rng:element[rng:anyName]">
                        <xsl:value-of select="'any XML content'"/>
                    </xsl:if>
                    <xsl:if test="$new.model//(tei:empty|rng:empty)">
                        <xsl:value-of select="'no content'"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:variable name="old.content" as="xs:string*">
                    <xsl:sequence select="$old.model//rng:ref[@name != 'macro.anyXML']/@name"/>
                    <xsl:if test="$old.model//rng:element[rng:anyName]">
                        <xsl:value-of select="'any XML content'"/>
                    </xsl:if>
                    <xsl:if test="$old.model//(tei:empty|rng:empty)">
                        <xsl:value-of select="'no content'"/>
                    </xsl:if>
                </xsl:variable>
                <xsl:variable name="lowercased.new.content" select="for $content in $new.content return lower-case($content)" as="xs:string*"/>
                <xsl:variable name="lowercased.old.content" select="for $content in $old.content return lower-case($content)" as="xs:string*"/>

                <xsl:variable name="added.content" select="$new.content[not(. = $old.content) and not(lower-case(.) = $lowercased.old.content)]" as="xs:string*"/>
                <xsl:variable name="removed.content" select="$old.content[not(. = $new.content) and not(lower-case(.) = $lowercased.new.content)]" as="xs:string*"/>
                <xsl:variable name="casechanged.content" select="$new.content[not(. = $old.content) and lower-case(.) = $lowercased.old.content]" as="xs:string*"/>

                <xsl:variable name="new.desc" select="string-join($new.model/tei:desc//text(),' ')" as="xs:string"/>
                <xsl:variable name="old.desc" select="string-join($old.model/tei:desc//text(),' ')" as="xs:string"/>

                <xsl:if test="count($added.content) gt 0 
                    or count($removed.content) gt 0 
                    or count($casechanged.content) gt 0">
                    <tr class="c" id="{$current.macro}">
                        <td class="macroClass ident">
                            <xsl:value-of select="$current.macro"/>
                        </td>
                        <td class="module">
                            <xsl:value-of select="$new.model/@module"/>
                        </td>
                        <td class="desc">
                            <xsl:choose>
                                <xsl:when test="$new.desc != $old.desc">
                                    <span class="removed block">
                                        <xsl:value-of select="$old.desc"/>
                                    </span>
                                    <span class="added block">
                                        <xsl:value-of select="$new.desc"/>
                                    </span>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$new.desc"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td class="classes">Classes:<br/>
                            <ul>
                                <xsl:for-each select="$new.content">
                                    <xsl:variable name="current.content" select="." as="xs:string"/>
                                    <xsl:choose>
                                        <xsl:when test="$current.content= $added.content">
                                            <li class="added macro pe" title="added macro">
                                                <xsl:value-of select="$current.content"/>
                                            </li>
                                        </xsl:when>
                                        <xsl:when test="$current.content = $casechanged.content">
                                            <li class="casechanged macro pe" title="was: {$old.content[lower-case(.) = lower-case($current.content)]}">
                                                <xsl:value-of select="$current.content"/>
                                            </li>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <li class="unchanged macro pe">
                                                <xsl:value-of select="$current.content"/>
                                            </li>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                                <xsl:for-each select="$removed.content">
                                    <li class="removed macro pe" title="removed macro">
                                        <xsl:value-of select="."/>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </td>
                    </tr>
                </xsl:if>


            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="unchanged.macros" select="$kept.macros[not(. = $modified.macros//td[@class='macroClass ident']/text())]" as="xs:string*"/>

        <h2>MacroSpec Comparison (Parameter Entities)</h2>
        <h3 id="macroAdded"><xsl:value-of select="count($added.macros)"/> new macroSpec classes:</h3>
        <table class="added">
            <xsl:for-each select="$added.macros">
                <xsl:variable name="current.element" select="." as="xs:string"/>
                <xsl:variable name="elementSpec" as="node()">
                    <xsl:choose>
                        <xsl:when test="$new.file//tei:macroSpec[@type = 'pe']">
                            <xsl:value-of select="$new.file//tei:macroSpec[@type = 'pe' and @ident = $current.element]"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$new.file//tei:macroSpec[@ident = $current.element]"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <tr class="a" id="${$current.element}">
                    <td class="macroClass ident">
                        <xsl:value-of select="$current.element"/>
                    </td>
                    <td class="module">
                        <xsl:value-of select="$elementSpec/@module"/>
                    </td>
                    <td>
                        <xsl:value-of select="string-join($elementSpec/tei:desc//text(),' ')"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
        <h3 id="macroRemoved"><xsl:value-of select="count($removed.macros)"/> removed macroSpec classes:</h3>
        <table class="removed">
            <xsl:for-each select="$removed.macros">
                <xsl:variable name="current.element" select="." as="xs:string"/>
                <xsl:variable name="elementSpec" select="$old.file//tei:macroSpec[not(@type = 'dt') and @ident = $current.element]" as="node()"/>
                <tr class="r" id="{$current.element}">
                    <td class="macroClass ident">
                        <xsl:value-of select="$current.element"/>
                    </td>
                    <td class="module">
                        <xsl:value-of select="$elementSpec/@module"/>
                    </td>
                    <td>
                        <xsl:value-of select="string-join($elementSpec/tei:desc//text(),' ')"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
        <h3 id="macroChanged"><xsl:value-of select="count($modified.macros)"/> modified macroSpec classes:</h3>
        <table>
            <xsl:sequence select="$modified.macros"/>
        </table>
        <h3 id="macroUnchanged"><xsl:value-of select="count($unchanged.macros)"/> unchanged macroSpec classes:</h3>
        <table>
            <xsl:for-each select="$unchanged.macros">
                <xsl:variable name="current.element" select="." as="xs:string"/>
                <xsl:variable name="elementSpec" select="$new.file//tei:macroSpec[not(@type = 'dt') and @ident = $current.element]" as="node()"/>
                <tr class="u" id="{$current.element}">
                    <td class="macroClass ident">
                        <xsl:value-of select="$current.element"/>
                    </td>
                    <td class="module unchanged">
                        <xsl:value-of select="$elementSpec/@module"/>
                    </td>
                    <td class="unchanged">
                        <xsl:value-of select="string-join($elementSpec/tei:desc//text(),' ')"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:function>

    <xsl:function name="mei:compareDataSpec" as="node()*">
        <xsl:param name="new.file" as="node()"/>
        <xsl:param name="old.file" as="node()"/>

        <xsl:variable name="new.models" select="distinct-values($new.file//(tei:dataSpec|tei:macroSpec[@type = 'dt'])/@ident)" as="xs:string*"/>
        <xsl:variable name="old.models" select="distinct-values($old.file//(tei:dataSpec|tei:macroSpec[@type = 'dt'])/@ident)" as="xs:string*"/>

        <xsl:variable name="added.models" select="$new.models[not(. = $old.models)]" as="xs:string*"/>
        <xsl:variable name="removed.models" select="$old.models[not(. = $new.models)]" as="xs:string*"/>
        <xsl:variable name="kept.models" select="$new.models[. = $old.models]" as="xs:string*"/>
        <xsl:variable name="modified.models" as="node()*">
            <xsl:for-each select="$kept.models">
                <xsl:variable name="current.macro" select="." as="xs:string"/>
                <xsl:variable name="new.macro" select="$new.file//(tei:dataSpec[@ident = $current.macro]|tei:macroSpec[@type = 'dt' and @ident = $current.macro])" as="node()"/>
                <xsl:variable name="old.macro" select="$old.file//(tei:dataSpec[@ident = $current.macro]|tei:macroSpec[@type = 'dt' and @ident = $current.macro])" as="node()"/>

                <xsl:variable name="new.references" select="$new.macro//rng:ref/@name | $new.macro//tei:macroRef/@key" as="xs:string*"/>
                <xsl:variable name="old.references" select="$old.macro//rng:ref/@name | $new.macro//tei:macroRef/@key" as="xs:string*"/>
                <xsl:variable name="lowercased.new.references" select="for $ref in $new.references return lower-case($ref)" as="xs:string*"/>
                <xsl:variable name="lowercased.old.references" select="for $ref in $old.references return lower-case($ref)" as="xs:string*"/>

                <xsl:variable name="added.references" select="$new.references[not(. = $old.references) and not(lower-case(.) = $lowercased.old.references)]" as="xs:string*"/>
                <xsl:variable name="removed.references" select="$old.references[not(. = $new.references) and not(lower-case(.) = $lowercased.new.references)]" as="xs:string*"/>
                <xsl:variable name="casechanged.references" select="$new.references[not(. = $old.references) and lower-case(.) = $lowercased.old.references]" as="xs:string*"/>

                <xsl:variable name="new.desc" select="string-join($new.macro/tei:desc//text(),' ')" as="xs:string"/>
                <xsl:variable name="old.desc" select="string-join($old.macro/tei:desc//text(),' ')" as="xs:string"/>

                <xsl:variable name="new.values" as="xs:string*">
                    <xsl:sequence select="$new.macro//tei:valItem/@ident"/>
                    <xsl:sequence select="$new.macro//rng:data[not(ancestor::rng:except)]/mei:resolveDataType(.)"/>
                </xsl:variable>
                <xsl:variable name="old.values" as="xs:string*">
                    <xsl:sequence select="$old.macro//tei:valItem/@ident"/>
                    <xsl:sequence select="$old.macro//rng:data[not(ancestor::rng:except)]/mei:resolveDataType(.)"/>
                </xsl:variable>

                <xsl:variable name="added.values" select="$new.values[not(. = $old.values)]" as="xs:string*"/>
                <xsl:variable name="removed.values" select="$old.values[not(. = $new.values)]" as="xs:string*"/>

                <xsl:if test="count($added.references) gt 0 
                    or count($removed.references) gt 0 
                    or count($casechanged.references) gt 0
                    or count($added.values) gt 0
                    or count($removed.values) gt 0">
                    <tr class="c" id="{$current.macro}">
                        <td class="macroSpec datatype ident">
                            <xsl:value-of select="$current.macro"/>
                        </td>
                        <td class="module">
                            <xsl:value-of select="$new.macro/@module"/>
                        </td>
                        <td class="desc">
                            <xsl:choose>
                                <xsl:when test="$new.desc != $old.desc">
                                    <span class="removed block">
                                        <xsl:value-of select="$old.desc"/>
                                    </span>
                                    <span class="added block">
                                        <xsl:value-of select="$new.desc"/>
                                    </span>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$new.desc"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                        <td class="classes">Referenced Macros:<br/>
                            <ul>
                                <xsl:for-each select="$new.references">
                                    <xsl:variable name="current.ref" select="." as="xs:string"/>
                                    <xsl:choose>
                                        <xsl:when test="$current.ref= $added.references">
                                            <li class="added macro datatype" title="added macroSpec">
                                                <xsl:value-of select="$current.ref"/>
                                            </li>
                                        </xsl:when>
                                        <xsl:when test="$current.ref = $casechanged.references">
                                            <li class="casechanged macro datatype" title="was: {$old.references[lower-case(.) = lower-case($current.ref)]}">
                                                <xsl:value-of select="$current.ref"/>
                                            </li>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <li class="unchanged macro datatype">
                                                <xsl:value-of select="$current.ref"/>
                                            </li>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                                <xsl:for-each select="$removed.references">
                                    <li class="removed macro datatype" title="removed macroSpec">
                                        <xsl:value-of select="."/>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </td>
                        <td class="classes">Allowed values:<br/>
                            <ul>
                                <xsl:for-each select="$new.values">
                                    <xsl:variable name="current.value" select="." as="xs:string"/>
                                    <xsl:choose>
                                        <xsl:when test="$current.value= $added.values">
                                            <li class="added datatype value" title="added value">
                                                <xsl:value-of select="$current.value"/>
                                            </li>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <li class="unchanged datatype value">
                                                <xsl:value-of select="$current.value"/>
                                            </li>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                                <xsl:for-each select="$removed.values">
                                    <li class="removed datatype value" title="removed value">
                                        <xsl:value-of select="."/>
                                    </li>
                                </xsl:for-each>
                            </ul>
                        </td>
                    </tr>
                </xsl:if>


            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="unchanged.models" select="$kept.models[not(. = $modified.models//td[@class='macroSpec datatype ident']/text())]" as="xs:string*"/>

        <h2>DataSpec Comparison (datatypes)</h2>
        <h3 id="dataSpecAdded"><xsl:value-of select="count($added.models)"/> new dataSpecs:</h3>
        <table class="added">
            <xsl:for-each select="$added.models">
                <xsl:variable name="current.element" select="." as="xs:string"/>
                <xsl:variable name="dataSpec" select="$new.file//(tei:dataSpec[@ident = $current.element]|tei:macroSpec[@type = 'dt' and @ident = $current.element])" as="node()"/>
                <tr class="a" id="{$current.element}">
                    <td class="dataSpec datatype ident">
                        <xsl:value-of select="$current.element"/>
                    </td>
                    <td class="module">
                        <xsl:value-of select="$dataSpec/@module"/>
                    </td>
                    <td>
                        <xsl:value-of select="string-join($dataSpec/tei:desc//text(),' ')"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
        <h3 id="dataSpecRemoved"><xsl:value-of select="count($removed.models)"/> removed dataSpecs:</h3>
        <table class="removed">
            <xsl:for-each select="$removed.models">
                <xsl:variable name="current.element" select="." as="xs:string"/>
                <xsl:variable name="dataSpec" select="$old.file//(tei:dataSpec[@ident = $current.element]|tei:macroSpec[@type = 'dt' and @ident = $current.element])" as="node()"/>
                <tr class="r" id="{$current.element}">
                    <td class="dataSpec datatype ident">
                        <xsl:value-of select="$current.element"/>
                    </td>
                    <td class="module">
                        <xsl:value-of select="$dataSpec/@module"/>
                    </td>
                    <td>
                        <xsl:value-of select="string-join($dataSpec/tei:desc//text(),' ')"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
        <h3 id="dataSpecChanged"><xsl:value-of select="count($modified.models)"/> modified dataSpecs:</h3>
        <table>
            <xsl:sequence select="$modified.models"/>
        </table>
        <h3 id="dataSpecUnchanged"><xsl:value-of select="count($unchanged.models)"/> unchanged dataSpecs:</h3>
        <table>
            <xsl:for-each select="$unchanged.models">
                <xsl:variable name="current.element" select="." as="xs:string"/>
                <xsl:variable name="dataSpec" select="$new.file//(tei:dataSpec[@ident = $current.element]|tei:macroSpec[@type = 'dt' and @ident = $current.element])" as="node()"/>
                <tr class="u" id="{$current.element}">
                    <td class="dataSpec datatype ident">
                        <xsl:value-of select="$current.element"/>
                    </td>
                    <td class="module unchanged">
                        <xsl:value-of select="$dataSpec/@module"/>
                    </td>
                    <td class="unchanged">
                        <xsl:value-of select="string-join($dataSpec/tei:desc//text(),' ')"/>
                    </td>
                </tr>
            </xsl:for-each>
        </table>
    </xsl:function>

    <xsl:function name="mei:resolveDataType" as="xs:string">
        <xsl:param name="data" as="node()"/>
        <xsl:choose>
            <xsl:when test="$data/@type = ('token','string')">
                <xsl:choose>
                    <xsl:when test="$data/rng:param">
                        <xsl:value-of select="$data/rng:param/text()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="string($data/@type)"/>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:when>
            <xsl:when test="ends-with(lower-case($data/@type),'integer') or $data/@type = 'decimal'">
                <xsl:choose>
                    <xsl:when test="$data/rng:param[@name = 'pattern']">
                        <xsl:value-of select="$data/rng:param/text()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="type" as="xs:string">
                            <xsl:choose>
                                <xsl:when test="$data/@type = 'integer'">
                                    <xsl:value-of select="'integer'"/>
                                </xsl:when>
                                <xsl:when test="$data/@type = 'positiveInteger'">
                                    <xsl:value-of select="'positive integer'"/>
                                </xsl:when>
                                <xsl:when test="$data/@type = 'nonNegativeInteger'">
                                    <xsl:value-of select="'non-negative integer'"/>
                                </xsl:when>
                                <xsl:when test="$data/@type = 'decimal'">
                                    <xsl:value-of select="'decimal number'"/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="lower.threshold" as="xs:string">
                            <xsl:choose>
                                <xsl:when test="$data/rng:param[@name = 'minInclusive']">
                                    <xsl:value-of select="', &gt;= ' || $data/rng:param[@name = 'minInclusive']/text()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="''"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="upper.threshold" as="xs:string">
                            <xsl:choose>
                                <xsl:when test="$data/rng:param[@name = 'maxInclusive']">
                                    <xsl:value-of select="', &lt;= ' || $data/rng:param[@name = 'maxInclusive']/text()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="''"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:value-of select="$type || $lower.threshold || $upper.threshold"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$data/@type = 'IDREF'">
                <xsl:value-of select="'an ID reference'"/>
            </xsl:when>
            <xsl:when test="$data/@type = ('date','gYear','gMonth','gDay','gYearMonth','gMonthDay','time','dateTime')">
                <xsl:value-of select="string($data/@type)"/>
            </xsl:when>
            <xsl:when test="$data/@type = ('NCName','NMTOKEN')">
                <xsl:value-of select="string($data/@type)"/>
            </xsl:when>
            <xsl:when test="$data/@type = 'anyURI'">
                <xsl:value-of select="'any URI'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'Breaks at ' || $data/@type" terminate="yes"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="mei:resolveAttClass" as="node()*">
        <xsl:param name="class.name" as="xs:string"/>
        <xsl:param name="file" as="node()"/>
        <xsl:variable name="att.class" select="$file//tei:classSpec[@type = 'atts' and @ident = $class.name]" as="node()"/>
        <xsl:sequence select="$att.class//tei:attDef"/>
        <xsl:sequence select="for $inherited.class in $att.class//tei:memberOf[starts-with(@key,'att.')]/@key return mei:resolveAttClass($inherited.class,$file)"/>
    </xsl:function>

    <!-- older versions of MEI did not have xml:lang attributes on desc -->
    <xsl:template match="@xml:lang" mode="simplify-space" priority="1"/>

    <xsl:template match="tei:abbr" mode="prep">
        <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:template>

    <xsl:template match="tei:*" mode="prep simplify-space">
        <xsl:element name="{local-name()}" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="rng:*" mode="prep simplify-space">
        <xsl:element name="{local-name()}" namespace="http://relaxng.org/ns/structure/1.0">
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="sch:*" mode="prep simplify-space">
        <xsl:element name="{local-name()}" namespace="http://purl.oclc.org/dsdl/schematron">
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="text()" mode="simplify-space" priority="1">
        <xsl:variable name="ticks">['’]</xsl:variable>
        <xsl:value-of select="normalize-space(replace(.,$ticks, ''))"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>This is a generic copy template which will copy all content in all modes</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy>
            <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
    </xsl:template>


</xsl:stylesheet>