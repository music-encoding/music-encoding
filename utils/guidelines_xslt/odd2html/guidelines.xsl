<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:egx="http://www.tei-c.org/ns/Examples"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:rng="http://relaxng.org/ns/structure/1.0"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:saxon="http://saxon.sf.net/"
    xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns:tools="no:where"
    exclude-result-prefixes="xs math xd xhtml tei rng sch egx saxon mei tools"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Nov 12, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This file holds most templates used to extract a HTML version of the MEI Guidelines</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Chapters</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:div" mode="guidelines">
        <xsl:variable name="chapter" select="." as="node()"/>
        
        <xsl:element name="{if(@type = 'div1') then('section') else('div')}">
            <xsl:attribute name="class" select="@type"/>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:element>
    </xsl:template>
        
    <xd:doc>
        <xd:desc>
            <xd:p>Chapter headings</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:head[parent::tei:div]" mode="guidelines">
        <xsl:variable name="div.id" select="parent::tei:div/@xml:id" as="xs:string"/>
        
        <xsl:variable name="tocInfo" select="$all.chapters/descendant-or-self::chapter[@xml:id = $div.id]" as="node()*"/>
        
        <xsl:if test="not($tocInfo)">
            <xsl:message terminate="yes" select="'ERROR: Unable to find chapter ' || $div.id || ' in $all.chapters'"/>
        </xsl:if>
        <xsl:if test="count($tocInfo) gt 1">
            <xsl:message terminate="yes" select="'ERROR: Too many chapters with ID ' || $div.id || ' in $all.chapters'"/>
        </xsl:if>
        <xsl:element name="h{$tocInfo/@level}">
            <xsl:attribute name="id" select="$div.id"/>
            <span class="headingNumber"><xsl:value-of select="$tocInfo/@number"/> </span>
            <span class="head"><xsl:value-of select="text()"/></span>
        </xsl:element>
    </xsl:template>
      
    <xd:doc>
        <xd:desc>
            <xd:p>Paragraphs</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:p" mode="guidelines">
        <p><xsl:apply-templates select="node()" mode="#current"/></p>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Lists</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:list" mode="guidelines">
        <xsl:choose>
            <xsl:when test="@type = ('bulleted','simple')">
                <xsl:if test="child::tei:head">
                    <strong class="listHead"><xsl:apply-templates select="child::tei:head/node()" mode="#current"/></strong>
                </xsl:if>
                <ul>
                    <xsl:for-each select="tei:item">
                        <li class="item">
                            <xsl:apply-templates select="node()" mode="#current"/>
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:when>
            <xsl:when test="@type = 'ordered'">
                <xsl:if test="child::tei:head">
                    <strong class="listHead"><xsl:apply-templates select="child::tei:head/node()"/></strong>
                </xsl:if>
                <ol>
                    <xsl:for-each select="tei:item">
                        <li class="item">
                            <xsl:apply-templates select="node()" mode="#current"/>
                        </li>
                    </xsl:for-each>
                </ol>
            </xsl:when>
            <xsl:when test="@type = 'gloss'">
                <dl>
                    <xsl:for-each select="tei:label">
                        <dt><span><xsl:apply-templates select="node()" mode="#current"/></span></dt>
                        <dd><xsl:apply-templates select="following-sibling::tei:item[1]/node()" mode="#current"/></dd>
                    </xsl:for-each>
                </dl>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="child::tei:head">
                    <strong class="listHead"><xsl:apply-templates select="child::tei:head/node()"/></strong>
                </xsl:if>
                <ul>
                    <xsl:for-each select="tei:item">
                        <li class="item">
                            <xsl:apply-templates select="node()" mode="#current"/>
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
        
    <xd:doc>
        <xd:desc>
            <xd:p>Element references</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:gi" mode="guidelines">
        <xsl:variable name="text" select="string(text())" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="@scheme = 'TEI' and unparsed-text-available('https://tei-c.org/release/doc/tei-p5-doc/en/html/ref-' || $text || '.html')">
                <a class="link_odd_elementSpec" href="https://tei-c.org/release/doc/tei-p5-doc/en/html/ref-{$text}.html">tei:<xsl:value-of select="$text"/></a>
            </xsl:when>
            <xsl:when test="$text = $elements/@ident">
                <a class="{tools:getLinkClasses($text)}" href="#{$text}"><xsl:value-of select="$text"/></a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no" select="'WARNING: Unable to retrieve definition of element ' || $text || '. No link created. Please check spelling…'"/>                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Attribute / Model class references</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:ident[@type = 'class']" mode="guidelines">
        <xsl:variable name="text" select="string(text())" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$text = //tei:classSpec/@ident">
                <a class="{tools:getLinkClasses($text)}" href="#{$text}"><xsl:value-of select="$text"/></a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="no" select="'ERROR: Unable to identify class ' || $text || ' from tei:ident element. No link created.'"/>
                <span class="ident">
                    <xsl:apply-templates select="node()" mode="#current"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xd:doc>
        <xd:desc>
            <xd:p>Specification Lists</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:specList" mode="guidelines">
        <ul class="specList">
            <xsl:apply-templates select="node() | @*" mode="#current"/>            
        </ul>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Specification Descriptions</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:specDesc" mode="guidelines">
        <xsl:variable name="key" select="@key" as="xs:string"/>
        <xsl:variable name="specDesc" select="." as="node()"/>
        <xsl:variable name="spec" select="if(count(//tei:*[@ident = $key and not(local-name() = ('schemaSpec','valItem'))]) = 1) 
            then(//tei:*[@ident = $key and not(local-name() = ('schemaSpec','valItem'))]) 
            else(//tei:*[@ident = $key and not(local-name() = ('schemaSpec','valItem','attDef'))])" as="node()*"/>
        <xsl:if test="count($spec) gt 1">
            <xsl:message select="'INFO: problem with tei:specDesc in chapter ' || ancestor::tei:div[1]/@xml:id || ' pointing at @key=' || $key || ', for which there ' || count($spec) || ' corresponding @idents.'"/>
        </xsl:if>
        <xsl:if test="count($spec) = 0">
            <xsl:message select="'INFO: problem with tei:specDesc in chapter ' || ancestor::tei:div[1]/@xml:id || ' pointing at @key=' || $key || ', which cannot be found with the current exclusions.'"/>
        </xsl:if>
        
        <!-- whether this specDesc is part of a specList or not -->
        <xsl:variable name="standalone" select="not(parent::tei:specList)" as="xs:boolean"/>
        
        <xsl:element name="{if($standalone) then('span') else('li')}">
            <xsl:attribute name="class" select="'specDesc'"/>
            <xsl:choose>
                <xsl:when test="not($specDesc/@atts)">
                    <span class="specList-{local-name($spec)}"><a class="{tools:getLinkClasses($key)}" href="#{$key}"><xsl:value-of select="$key"/></a></span>
                    <span class="specList-{local-name($spec)}-desc">
                        <xsl:apply-templates select="$spec/tei:desc/node()" mode="#current"/>
                    </span>
                </xsl:when>
                <xsl:otherwise>
                    <table class="specDesc">
                        <tbody>
                            <xsl:for-each select="tokenize(normalize-space($specDesc/@atts),' ')">
                                <xsl:variable name="current.att" select="." as="xs:string"/>
                                <tr>
                                    <td class="Attribute">
                                        <span class="att"><xsl:value-of select="$current.att"/></span> (<a class="{tools:getLinkClasses($key)}" href="#{$key}"><xsl:value-of select="$key"/></a>)
                                    </td>
                                    <td>
                                        <xsl:choose>
                                            <xsl:when test="$spec//tei:attDef[@ident = $current.att]">
                                                <xsl:apply-templates select="$spec//tei:attDef[@ident = $current.att]/tei:desc/node()" mode="#current"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:message select="'ERROR: I need to resolve attributes:'"/>
                                                <xsl:message select="$specDesc"/>
                                                <!-- TODO -->
                                                <!--<xsl:variable name="attributes" select="local:getAttributes($spec)" as="node()*"/>
                                                <xsl:apply-templates select="$attributes/descendant-or-self::div[span[@class='attribute']/text() = '@' || $current.att]/span[@class='attributeDesc']/node()" mode="#current"/>-->
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </tbody>
                    </table>
                </xsl:otherwise>
            </xsl:choose>    
        </xsl:element>
        
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Pointers</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:ptr" mode="guidelines">
        <xsl:variable name="chapter.id" select="replace(@target,'#','')" as="xs:string"/>
        <xsl:variable name="tocInfo" select="$all.chapters/descendant-or-self::chapter[@xml:id = $chapter.id]" as="node()?"/>
        <xsl:choose>
            <xsl:when test="starts-with(@target,'https://') or starts-with(@target,'http://') or starts-with(@target,'ftp://')">
                <!-- TODO: Should we try to retrieve the linked thing and a) provide info whether it's available, and b) try to create a title other than the link? -->
                <a class="link_ptr link_external" href="{@target}"><xsl:value-of select="@target"/></a>
            </xsl:when>
            <xsl:when test="not($tocInfo)">
                <xsl:message terminate="no" select="'ERROR: Could not retrieve chapter with @xml:id ' || $chapter.id || ' (referenced from a //tei:ptr/@target inside chapter ' || ancestor::tei:div[1]/@xml:id || '). Please check!'"/>
                <span class="wrong_ptr"><xsl:value-of select="@target"/></span>
            </xsl:when>
            <xsl:otherwise>
                <a class="link_ptr chapterLink" title="{$tocInfo/@head}" href="#{$chapter.id}"><xsl:value-of select="$tocInfo/@number || ' ' || $tocInfo/@head"/></a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>References</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:ref" mode="guidelines">
        <xsl:choose>
            <xsl:when test="starts-with(@target,'#')">
                <xsl:variable name="chapter.id" select="substring(@target,2)" as="xs:string"/>
                <xsl:variable name="tocInfo" select="$all.chapters/descendant-or-self::chapter[@xml:id = $chapter.id]" as="node()?"/>
                <xsl:choose>
                    <xsl:when test="exists($tocInfo)">
                        <a class="link_ref chapterLink" title="{$tocInfo/@number || ' ' || $tocInfo/@head}" href="#{$chapter.id}"><xsl:apply-templates select="node()" mode="#current"/></a>                        
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="wrong_ref" data-target="{$chapter.id}"><xsl:apply-templates select="node()" mode="#current"/></span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <a class="link_ref link_external" href="{@target}"><xsl:apply-templates select="node()" mode="#current"/></a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Figures</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:figure" mode="guidelines">
        <figure class="figure{if(child::egx:egXML) then(' specPage') else()}">
            <xsl:apply-templates select="tei:graphic | egx:egXML" mode="#current"/>
            <xsl:apply-templates select="tei:head" mode="#current"/>
        </figure>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Figure headings</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:head[parent::tei:figure]" mode="guidelines">
        <xsl:choose>
            <xsl:when test="parent::tei:figure and parent::tei:figure/tei:graphic">
                <figcaption class="figure-caption">Figure <xsl:value-of select="count(preceding::tei:figure[./tei:graphic]) + 1"/>. <xsl:apply-templates select="node()" mode="#current"/></figcaption>
            </xsl:when>
            <xsl:when test="parent::tei:figure and parent::tei:figure/egx:egXML">
                <figcaption class="figure-caption">Listing <xsl:value-of select="count(preceding::tei:figure[./egx:egXML]) + 1"/>. <xsl:apply-templates select="node()" mode="#current"/></figcaption>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Other headings</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:head[not(parent::tei:figure) and not(parent::tei:div)]" mode="guidelines">
        <span class="otherHead"><xsl:apply-templates select="node()" mode="#current"/></span>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Foreign elements</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:foreign" mode="guidelines">
        <span class="foreign"><xsl:apply-templates select="node()" mode="#current"/></span>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Attributes mentioned</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:att" mode="guidelines">
        <span class="att"><xsl:apply-templates select="node()" mode="#current"/></span>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Highlighted content</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:hi" mode="guidelines">
        <xsl:variable name="rends" select="if(@rend) then(tokenize(normalize-space(@rend),' ')) else()" as="xs:string*"/>
        <xsl:choose>
            <xsl:when test="'italic' = $rends and 'bold' = $rends">
                <strong><em><xsl:apply-templates select="node()" mode="#current"/></em></strong>
            </xsl:when>
            <xsl:when test="'italic' = $rends and not('bold' = $rends)">
                <em><xsl:apply-templates select="node()" mode="#current"/></em>
            </xsl:when>
            <xsl:when test="not('italic' = $rends) and 'bold' = $rends">
                <strong><xsl:apply-templates select="node()" mode="#current"/></strong>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message select="'INFO: Unknown values for tei:hi/@rend: _' || @rend || '_. Please update the XSLT.'"/>
                <span class="hi {string(@rend)}"><xsl:apply-templates select="node()" mode="#current"/></span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>soCalled</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:soCalled" mode="guidelines">
        <xsl:value-of select="'‘'"/><xsl:apply-templates select="node()" mode="#current"/><xsl:value-of select="'’'"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>title</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:title" mode="guidelines">
        <span class="title"><xsl:apply-templates select="node()" mode="#current"/></span>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>abbr</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:abbr" mode="guidelines">
        <abbr><xsl:apply-templates select="node()" mode="#current"/></abbr>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>bibl</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:bibl" mode="guidelines">
        <span class="bibl"><xsl:apply-templates select="node()" mode="#current"/></span>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Names</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:name" mode="guidelines">
        <xsl:choose>
            <xsl:when test="not(@ref)">
                <xsl:apply-templates select="node()" mode="#current" />
            </xsl:when>
            <xsl:otherwise>
                <a class="link_ref link_external" href="{@ref}">
                    <xsl:apply-templates select="node()" mode="#current" />
                </a>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Terms</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:term" mode="guidelines">
        <span class="term">
            <xsl:choose>
                <xsl:when test="not(@ref)">
                    <xsl:apply-templates select="node()" mode="#current" />
                </xsl:when>
                <xsl:when test="starts-with(@ref,'#')">
                    <xsl:variable name="chapter.id" select="substring(@target,2)" as="xs:string" />
                    <xsl:variable name="tocInfo" select="$all.chapters/descendant-or-self::chapter[@xml:id = $chapter.id]" as="node()?" />
                    <xsl:choose>
                        <xsl:when test="exists($tocInfo)">
                            <a class="link_ref chapterLink" title="{$tocInfo/@number || ' ' || $tocInfo/@head}" href="#{$chapter.id}">
                                <xsl:apply-templates select="node()" mode="#current" />
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <span class="wrong_ref" data-target="{$chapter.id}">
                                <xsl:apply-templates select="node()" mode="#current" />
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <a class="link_ref link_external" href="{@ref}">
                        <xsl:apply-templates select="node()" mode="#current" />
                    </a>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>mentioned</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:mentioned" mode="guidelines">
        <span class="mentioned"><xsl:apply-templates select="node()" mode="#current"/></span>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Quoted content</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:q|tei:quote" mode="guidelines">
        <xsl:value-of select="'&quot;'"/><xsl:apply-templates select="node()" mode="#current"/><xsl:value-of select="'&quot;'"/>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>Emphasized content</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:emph" mode="guidelines">
        <em class="mentioned"><xsl:apply-templates select="node()" mode="#current"/></em>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Table elements</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:table" mode="guidelines">
        <table>
            <xsl:apply-templates select="node()" mode="#current"/>
        </table>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Table rows elements</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:row" mode="guidelines">
        <tr>
            <xsl:apply-templates select="node()" mode="#current"/>
        </tr>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Table column elements</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:cell" mode="guidelines">
        <td>
            <xsl:apply-templates select="node()" mode="#current"/>
        </td>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Values</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:val" mode="guidelines">
        <span class="val"><xsl:apply-templates select="node()" mode="#current"/></span>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Formulas</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:formula" mode="guidelines">
        <span class="formula"><xsl:apply-templates select="node()" mode="#current"/></span>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Graphics</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:graphic" mode="guidelines">
        <xsl:choose>
            <xsl:when test="@rend">
                <img alt="SMuFL glyph" class="smufl" src="{@url}"/>
            </xsl:when>
            <xsl:otherwise>
                <img alt="example" class="graphic" src="{tools:adjustImageUrl(@url)}"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Exemplums</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:exemplum" mode="guidelines">
        <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Examples</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="egx:egXML" mode="guidelines">
        <xsl:variable name="validClass" select="'egXML_' || (if(@valid='false') then('invalid') else if(@valid='true') then('valid') else('feasible'))" as="xs:string"/>
        <xsl:variable name="renderedLive" select="'verovio' = tokenize(normalize-space(@rend),' ')" as="xs:boolean"/>
        <xsl:variable name="verovioClass" select="if($renderedLive) then(' verovio') else('')" as="xs:string"/>
        <xsl:variable name="id" select="generate-id(.)"/>
        <xsl:if test="$renderedLive">
            <xsl:variable name="imageUrl" select="$assets.folder.generated.images.rel || $id || '.mei.svg'"/>
            <img alt="example" class="graphic liveExample" src="{tools:adjustImageUrl($imageUrl)}"/>
        </xsl:if>
        <div id="{$id}" xml:space="preserve" class="pre code {$validClass}{$verovioClass}">
            <code>
                <xsl:choose>
                    <xsl:when test="@rend and 'text' = tokenize(normalize-space(@rend),' ')">
                        <!-- todo: render non-xml examples properly -->
                        <xsl:copy-of select="node()" xml:space="preserve"/>
                    </xsl:when>
                    <xsl:when test="child::element()">
                        <xsl:variable name="pi.start" select=".//processing-instruction('edit-start')" as="processing-instruction()*"/>
                        <xsl:variable name="pi.end" select=".//processing-instruction('edit-end')" as="processing-instruction()*"/>
                        <xsl:choose>
                            <xsl:when test="exists($pi.start) and exists($pi.end)">
                                <xsl:message select="'CUTTING EXAMPLE'"/>
                                <xsl:apply-templates select="$pi.start/following-sibling::node()[following::processing-instruction('edit-end')]" mode="preserveSpace"/>        
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:apply-templates select="child::node()" mode="preserveSpace"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="tools:xml2html(node())"/>
                        <!--<xsl:if test="$renderedLive">
                            <xsl:call-template name="prepareLiveExample">
                                <xsl:with-param name="id" select="$id"/>
                                <xsl:with-param name="content" select="node()"/>
                            </xsl:call-template>
                        </xsl:if>-->
                    </xsl:otherwise>
               </xsl:choose>            
            </code>
            <!-- TODO: Insert code for switching tabs between code and rendered image -->
        </div>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Code Examples from languages other than XML</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="tei:code" mode="guidelines">
        <code class="{@lang}"><xsl:apply-templates select="node()" mode="preserveSpace"/></code>
    </xsl:template>
    
    
</xsl:stylesheet>
