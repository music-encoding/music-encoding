<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs xd eg"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:eg="http://www.tei-c.org/ns/Examples"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 20, 2010</xd:p>
            <xd:p><xd:b>Author:</xd:b> raffaeleviglianti</xd:p>
            <xd:p>Converts TEI with Music Notation ODD into a webpage</xd:p>
        </xd:desc>
    </xd:doc>

    <xsl:output
        doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
        encoding="UTF-8" method="xhtml" indent="yes"/>

    <xsl:variable name="newline">
        <xsl:text>
</xsl:text>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:comment xml:space="preserve">
            Design by Free CSS Templates
            http://www.freecsstemplates.org
            Released for free under a Creative Commons Attribution 2.5 License
            
            Name       : Brown Stone  
            Description: A two-column, fixed-width design with dark color scheme.
            Version    : 1.0
            Released   : 20100928
            </xsl:comment>

        <html xmlns="http://www.w3.org/1999/xhtml">
            <head>
                <meta name="keywords" content=""/>
                <meta name="description" content=""/>
                <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
                <title>TEI Music SIG</title>
                <link href="../_a/css/style.css" rel="stylesheet" type="text/css" media="screen"/>
                <link href="../_a/css/twm_style.css" rel="stylesheet" type="text/css" media="screen"/>
                <link href="../_a/css/css-buttons.css" rel="stylesheet" type="text/css"
                    media="screen"/>
                <script type="text/javascript" xml:space="preserve">

                    var _gaq = _gaq || [];
                    _gaq.push(['_setAccount', 'UA-17412873-2']);
                    _gaq.push(['_trackPageview']);
                  
                    (function() {
                      var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
                      ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
                      var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
                    })();

                </script>
            </head>
            <body>
                <div id="wrapper">
                    <div id="page">
                        <div id="page-bgtop">
                            <div id="page-bgbtm">
                                <div id="content">
                                    <div class="post">
                                        
                                        
                                        <xsl:apply-templates select="//front/div/head[1]"/>
                                        
                                        
                                        <!--<p class="meta"><span class="date">November 10, 2010</span><span class="posted">Posted by <strong>Raffaele Viglianti</strong></span></p>-->
                                        <div style="clear: both;">&#160;</div>
                                        <div class="entry">
                                            
                                            <xsl:call-template name="toc"/>
                                            
                                            <xsl:apply-templates select="//front/div/div"/>
                                            
                                        </div>
                                        <div class="entry">
                                            
                                            <xsl:apply-templates select="//body/div"/>
                                            
                                        </div>
                                    </div>
                                    <div style="clear: both;">&#160;</div>
                                    
                                </div>
                                <!-- end #content -->
                                <div id="sidebar">
                                    <div id="logo">
                                        <h1>
                                            <a href="#">TEI Music SIG </a>
                                        </h1>
                                        <!--<p>Design by <a href="http://www.freecsstemplates.org/">CSS Templates</a></p>-->
                                    </div>
                                    <div id="menu">
                                        <ul>
                                            <li>
                                                <a href="../index.html">Home</a>
                                            </li>
                                            <li>
                                                <a href="../about.html">About the SIG</a>
                                            </li>
                                            <li class="current_page_item">
                                                <a href="index.html">TEI with music notation</a>
                                            </li>
                                            <li>
                                                <a href="http://wiki.tei-c.org/index.php/SIG:Music"
                                                    >Wiki</a>
                                            </li>
                                            <li>
                                                <a href="http://www.tei-c.org/">TEI Home</a>
                                            </li>
                                        </ul>
                                    </div>

                                </div>
                                <!-- end #sidebar -->
                                <div style="clear: both;">&#160;</div>
                            </div>
                        </div>
                    </div>
                    <!-- end #page -->
                </div>
                <div id="footer">
                    <p>Design by <a href="http://www.freecsstemplates.org/">CSS Templates</a>.</p>
                </div>
                <!-- end #footer -->
            </body>
        </html>

    </xsl:template>
    
    <xsl:template match="//div/head">
        <xsl:choose>
            <xsl:when test="parent::div/parent::front">
                <h2 class="title" xmlns="http://www.w3.org/1999/xhtml">
                    <a href="#"><xsl:value-of select="."/></a>
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <h3 xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:if test="ancestor::body">
                        <xsl:choose>
                            <xsl:when test="parent::div/parent::div[parent::div]">
                                <xsl:number select="parent::div/parent::div/parent::div" format="1"/>
                                <xsl:text>.</xsl:text>
                                <xsl:number select="parent::div/parent::div" format="1"/>
                                <xsl:text>.</xsl:text>
                                <xsl:number select="parent::div" format="1"/>
                                <xsl:text>. </xsl:text>
                            </xsl:when>
                        <xsl:when test="parent::div[parent::div]">
                            <xsl:number select="parent::div/parent::div" format="1"/>
                            <xsl:text>.</xsl:text>
                            <xsl:number select="parent::div" format="1"/>
                            <xsl:text>. </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:number select="parent::div" format="1"/>
                            <xsl:text>. </xsl:text>
                        </xsl:otherwise>
                        </xsl:choose>
                    </xsl:if>
                    <xsl:value-of select="."/>
                </h3>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="div">
        <div xmlns="http://www.w3.org/1999/xhtml">
            <a name="{@xml:id}">&#160;</a>
           <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="hi">
        <xsl:choose>
            <xsl:when test="@rend='bold'">
                <strong xmlns="http://www.w3.org/1999/xhtml"><xsl:apply-templates/></strong>
            </xsl:when>
            <xsl:when test="@rend='italic'">
                <em xmlns="http://www.w3.org/1999/xhtml"><xsl:apply-templates/></em>
            </xsl:when>
            <xsl:when test="@rend='small'">
                <small xmlns="http://www.w3.org/1999/xhtml"><xsl:apply-templates/></small>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="ref">
        <a xmlns="http://www.w3.org/1999/xhtml" href="{@target}">
            <xsl:if test="@rend">
                <xsl:attribute name="class">
                    <xsl:value-of select="@rend"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="parent::ab[@xml:id='download_button']">
                    <span><xsl:apply-templates/></span>
                </xsl:when>
                <xsl:otherwise><xsl:apply-templates/></xsl:otherwise>
            </xsl:choose>
            
        </a>
    </xsl:template>
    
    <xsl:template match="list">
        <xsl:choose>
            <xsl:when test="@type='bulleted' or not(@type)">
                <ul xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:if test="@rend">
                        <xsl:attribute name="class">
                            <xsl:value-of select="@rend"/>
                        </xsl:attribute>
                    </xsl:if>
                   <xsl:call-template name="do_list"/>
                </ul>
            </xsl:when>
            <xsl:when test="@type='ordered'">
                <ol xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:if test="@rend">
                        <xsl:attribute name="class">
                            <xsl:value-of select="@rend"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:call-template name="do_list"/>
                </ol>
            </xsl:when>
        </xsl:choose>
        
    </xsl:template>

    <xsl:template name="do_list">
        <xsl:if test="label">
            <li xmlns="http://www.w3.org/1999/xhtml"><xsl:apply-templates/></li>
        </xsl:if>
        <xsl:for-each select="item">
            <li xmlns="http://www.w3.org/1999/xhtml"><xsl:apply-templates/></li>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="label">
        <strong xmlns="http://www.w3.org/1999/xhtml"><xsl:apply-templates/></strong>
    </xsl:template>

    <xsl:template match="eg:egXML">
        
        <xsl:variable name="egxml">
            <xsl:apply-templates mode="escape"/>
        </xsl:variable>
        
        <pre xmlns="http://www.w3.org/1999/xhtml">
            <xsl:value-of select="$egxml"/>
        </pre>
        
    </xsl:template>
    
    <xsl:template match="p">
        <p xmlns="http://www.w3.org/1999/xhtml">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="ab">
        <xsl:choose>
            <xsl:when test="@xml:id='download_button'">
                <span xmlns="http://www.w3.org/1999/xhtml" id="{@xml:id}">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <xsl:template match="figure[not(ancestor::eg:egXML)]">
        <div class="example-img">
            <img src="../_a/images/examples/{graphic/@url}" alt="{figDesc}"/>
        </div>
    </xsl:template>
    
    <xsl:template name="toc">
        <table xmlns="http://www.w3.org/1999/xhtml" id="TOC">
         <tr>
            <td><ul class="toc">
             <xsl:for-each select="//front/div//div[head]">
                <li><a href="#{@xml:id}"><xsl:value-of select="head"/></a></li>
             </xsl:for-each>
         </ul></td>
         <td><ul class="toc">
             <xsl:for-each select="//body//div/head">
                 <li>
                     <xsl:choose>
                         <xsl:when test="parent::div/parent::div[parent::div]">
                             <xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
                             <xsl:number select="parent::div/parent::div/parent::div" format="1"/>
                             <xsl:text>.</xsl:text>
                             <xsl:number select="parent::div/parent::div" format="1"/>
                             <xsl:text>.</xsl:text>
                             <xsl:number select="parent::div" format="1"/>
                             <xsl:text>. </xsl:text>
                         </xsl:when>
                         <xsl:when test="parent::div[parent::div]">
                             <xsl:text>&#160;&#160;</xsl:text>
                             <xsl:number select="parent::div/parent::div" format="1"/>
                             <xsl:text>.</xsl:text>
                             <xsl:number select="parent::div" format="1"/>
                             <xsl:text>. </xsl:text>
                         </xsl:when>
                         <xsl:otherwise>
                             <xsl:number select="parent::div" format="1"/>
                             <xsl:text>. </xsl:text>
                         </xsl:otherwise>
                     </xsl:choose>
                     <a href="#{parent::div/@xml:id}"><xsl:value-of select="."/></a>
                     </li>
             </xsl:for-each>
         </ul></td></tr>
        </table>
    </xsl:template>

<!-- === ESCAPE XML FOR egXML ELEMENTS === -->
    
    <xsl:template match="*" mode="escape">
        <xsl:choose>
            <xsl:when test="count(child::node()) > 0">
                
                <!-- Begin opening tag -->
                <xsl:text>&lt;</xsl:text>
                <xsl:value-of select="name()"/>
                
                <xsl:call-template name="escape_attributes"/>
                
                <!-- End opening tag -->
                <xsl:text>&gt;</xsl:text>
                
                <!-- Content (child elements, text nodes, and PIs) -->
                <xsl:apply-templates select="node()" mode="escape"/>
                
                <!-- Closing tag -->
                <xsl:text>&lt;/</xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text>&gt;</xsl:text>
                
                
            </xsl:when>       
            <xsl:otherwise>
                <!-- Begin opening tag -->
                <xsl:text>&lt;</xsl:text>
                <xsl:value-of select="name()"/>
                
                <xsl:call-template name="escape_attributes"/>
                
                <!-- End opening tag -->
                <xsl:text>/&gt;</xsl:text>
                
            </xsl:otherwise>
        </xsl:choose>
        
        
    </xsl:template>
    
    <xsl:template name="escape_attributes">
        <!-- Attributes -->
        <xsl:for-each select="@*">
            <xsl:text> </xsl:text>
            <xsl:value-of select="name()"/>
            <xsl:text>="</xsl:text>
            <xsl:call-template name="escape-xml">
                <xsl:with-param name="text" select="."/>
            </xsl:call-template>
            <xsl:text>"</xsl:text>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="text()" mode="escape">
        <xsl:call-template name="escape-xml">
            <xsl:with-param name="text" select="."/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="processing-instruction()" mode="escape">
        <xsl:text>&lt;?</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="escape-xml">
            <xsl:with-param name="text" select="."/>
        </xsl:call-template>
        <xsl:text>?&gt;</xsl:text>
    </xsl:template>
    
    <xsl:template name="escape-xml">
        <xsl:param name="indent" select="''"/>
        <xsl:param name="text"/>
        <xsl:message>
            <xsl:value-of select="$text"/>
        </xsl:message>
        <xsl:if test="$text != ''">
            <xsl:variable name="head" select="substring($text, 1, 1)"/>
            <xsl:variable name="tail" select="substring($text, 2)"/>
            <xsl:choose>
                <!--<xsl:when test="$head = '&amp;'">&amp;amp;</xsl:when>-->
                <xsl:when test="$head = '&lt;'">&amp;lt;</xsl:when>
                <xsl:when test="$head = '&gt;'">&amp;gt;</xsl:when>
                <!--<xsl:when test="$head = '&quot;'">&amp;quot;</xsl:when>
                <xsl:when test="$head = &quot;&apos;&quot;">&amp;apos;</xsl:when>-->
                <xsl:otherwise><xsl:value-of select="$head"/></xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="escape-xml">
                <xsl:with-param name="text" select="$tail"/>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>

<!-- === TRASHCAN === -->
<!--<xsl:template match="*" mode="escape">
    <xsl:param name="indent" select="''"/>
    <xsl:param name="indent-increment" select="'    '"/>
    <xsl:variable name="newline" select="'&amp;#10;'"/>    
    <xsl:value-of select="$indent"/>
    <xsl:choose>
    <xsl:when test="count(child::*) > 0">
    <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:apply-templates select="*|text()" mode="escape">
    <xsl:with-param name="indent" select="concat ($indent, $indent-increment)"/>
    </xsl:apply-templates>
    <xsl:value-of select="$newline"/>
    <xsl:value-of select="$indent"/>
    </xsl:copy>
    </xsl:when>       
    <xsl:otherwise>
    <xsl:copy-of select="."/>
    </xsl:otherwise>
    </xsl:choose>
    
    <!-\- Begin opening tag -\->
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name()"/>
    
    <!-\- Namespaces -\->
    <!-\-<xsl:for-each select="namespace::*">
    <xsl:text> xmlns</xsl:text>
    <xsl:if test="name() != ''">
    <xsl:text>:</xsl:text>
    <xsl:value-of select="name()"/>
    </xsl:if>
    <xsl:text>='</xsl:text>
    <xsl:call-template name="escape-xml">
    <xsl:with-param name="text" select="."/>
    </xsl:call-template>
    <xsl:text>'</xsl:text>
    </xsl:for-each>-\->
    
    <!-\- Attributes -\->
    <xsl:for-each select="@*">
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>='</xsl:text>
    <xsl:call-template name="escape-xml">
    <xsl:with-param name="text" select="."/>
    </xsl:call-template>
    <xsl:text>'</xsl:text>
    </xsl:for-each>
    
    <!-\- End opening tag -\->
    <xsl:text>&gt;</xsl:text>
    
    <!-\- Content (child elements, text nodes, and PIs) -\->
    <xsl:apply-templates select="node()" mode="escape" />
    
    <!-\- Closing tag -\->
    <xsl:text>&lt;/</xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>&gt;</xsl:text>
    </xsl:template>-->
