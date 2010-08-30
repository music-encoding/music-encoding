<?xml version="1.0" encoding="UTF-8"?>

<!-- ************************************************************** -->
<!--
NAME:     File      = 2mup.xsl (version 1.0.1)
          Vers Date = 2009/12/09

NOTICE:   Copyright (c) 2007-2009 Perry Roland and the Rector and
          Visitors of the University of Virginia.

          Licensed under the Educational Community License version 1.0.

          This Original Work, including software, source code,
          documents, or other related items, is being provided by the
          copyright holder(s) subject to the terms of the Educational
          Community License. By obtaining, using and/or copying this
          Original Work, you agree that you have read, understand, and
          will comply with the following terms and conditions of the
          Educational Community License:

          Permission to use, copy, modify, merge, publish, distribute,
          and sublicense this Original Work and its documentation, with
          or without modification, for any purpose, and without fee or
          royalty to the copyright holder(s) is hereby granted, provided
          that you include the following on ALL copies of the Original
          Work or portions thereof, including modifications or
          derivatives, that you make:

          The full text of the Educational Community License in a
          location viewable to users of the redistributed or derivative
          work. 

          Any pre-existing intellectual property disclaimers, notices,
          or terms and conditions. 

          Notice of any changes or modifications to the Original Work,
          including the date the changes were made. 

          Any modifications of the Original Work must be distributed in
          such a manner as to avoid any confusion with the Original Work
          of the copyright holders.

          THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
          KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
          WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
          PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
          COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
          LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
          OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
          SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

          The name and trademarks of copyright holder(s) may NOT be used
          in advertising or publicity pertaining to the Original or
          Derivative Works without specific, written prior permission.
          Title to copyright in the Original Work and any associated
          documentation will at all times remain with the copyright
          holders.

PURPOSE:  This XSLT stylesheet transforms a Music Encoding Initiative
          (MEI) file to a Music Publisher (mup) file.
          
AUTHOR:   Perry Roland
          pdr4h@virginia.edu
          University of Virginia
          Charlottesville, VA 22903

NOTES:    

TO DO:    1. bow markings must always be above, use 'mussym' instead
             of 'with'

CHANGES:  
                                                                    -->
<!-- ************************************************************** -->

<!DOCTYPE xsl:stylesheet [
]>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:saxon="http://saxon.sf.net/" exclude-result-prefixes="saxon">

  <xsl:strip-space elements="*"/>
  <xsl:variable name="nl">
    <xsl:text>&#xA;</xsl:text>
  </xsl:variable>
  <xsl:variable name="indent">
    <xsl:text>  </xsl:text>
  </xsl:variable>
  <xsl:param name="source"/>
  <xsl:character-map name="mup-chars">
    <xsl:output-character character="&#x00A1;" string="\(exclamdown)"/>
    <xsl:output-character character="&#x00A3;" string="\(sterling)"/>
    <xsl:output-character character="&#x00A5;" string="\(yen)"/>
    <xsl:output-character character="&#x00A9;" string="\(copyright)"/>
    <xsl:output-character character="&#x00AA;" string="\(ordfeminine)"/>
    <xsl:output-character character="&#x00AB;" string="\(&lt;&lt;)"/>
    <xsl:output-character character="&#x00BA;" string="\(ordmasculine)"/>
    <xsl:output-character character="&#x00BB;" string="\(>>)"/>
    <xsl:output-character character="&#x00BF;" string="\(questiondown)"/>
    <xsl:output-character character="&#x00C0;" string="\(A`)"/>
    <xsl:output-character character="&#x00C1;" string="\(A')"/>
    <xsl:output-character character="&#x00C2;" string="\(A^)"/>
    <xsl:output-character character="&#x00C3;" string="\(A~)"/>
    <xsl:output-character character="&#x00C4;" string="\(A:)"/>
    <xsl:output-character character="&#x00C5;" string="\(Ao)"/>
    <xsl:output-character character="&#x00C6;" string="\(AE)"/>
    <xsl:output-character character="&#x00C7;" string="\(C,)"/>
    <xsl:output-character character="&#x00C8;" string="\(E`)"/>
    <xsl:output-character character="&#x00C9;" string="\(E')"/>
    <xsl:output-character character="&#x00CA;" string="\(E^)"/>
    <xsl:output-character character="&#x00CB;" string="\(E:)"/>
    <xsl:output-character character="&#x00CC;" string="\(I`)"/>
    <xsl:output-character character="&#x00CD;" string="\(I')"/>
    <xsl:output-character character="&#x00CE;" string="\(I^)"/>
    <xsl:output-character character="&#x00CF;" string="\(I:)"/>
    <xsl:output-character character="&#x00D1;" string="\(N~)"/>
    <xsl:output-character character="&#x00D2;" string="\(O`)"/>
    <xsl:output-character character="&#x00D3;" string="\(O')"/>
    <xsl:output-character character="&#x00D4;" string="\(O^)"/>
    <xsl:output-character character="&#x00D5;" string="\(O~)"/>
    <xsl:output-character character="&#x00D6;" string="\(O:)"/>
    <xsl:output-character character="&#x00D8;" string="\(O/)"/>
    <xsl:output-character character="&#x00D9;" string="\(U`)"/>
    <xsl:output-character character="&#x00DA;" string="\(U')"/>
    <xsl:output-character character="&#x00DB;" string="\(U^)"/>
    <xsl:output-character character="&#x00DC;" string="\(U:)"/>
    <xsl:output-character character="&#x00DF;" string="\(ss)"/>
    <xsl:output-character character="&#x00E0;" string="\(a`)"/>
    <xsl:output-character character="&#x00E1;" string="\(a')"/>
    <xsl:output-character character="&#x00E2;" string="\(a^)"/>
    <xsl:output-character character="&#x00E3;" string="\(a~)"/>
    <xsl:output-character character="&#x00E4;" string="\(a:)"/>
    <xsl:output-character character="&#x00E5;" string="\(ao)"/>
    <xsl:output-character character="&#x00E6;" string="\(ae)"/>
    <xsl:output-character character="&#x00E7;" string="\(c,)"/>
    <xsl:output-character character="&#x00E8;" string="\(e`)"/>
    <xsl:output-character character="&#x00E9;" string="\(e')"/>
    <xsl:output-character character="&#x00EA;" string="\(e^)"/>
    <xsl:output-character character="&#x00EB;" string="\(e:)"/>
    <xsl:output-character character="&#x00EC;" string="\(i`)"/>
    <xsl:output-character character="&#x00ED;" string="\(i')"/>
    <xsl:output-character character="&#x00EE;" string="\(i^)"/>
    <xsl:output-character character="&#x00EF;" string="\(i:)"/>
    <xsl:output-character character="&#x00F1;" string="\(n~)"/>
    <xsl:output-character character="&#x00F2;" string="\(o`)"/>
    <xsl:output-character character="&#x00F3;" string="\(o')"/>
    <xsl:output-character character="&#x00F4;" string="\(o^)"/>
    <xsl:output-character character="&#x00F5;" string="\(o~)"/>
    <xsl:output-character character="&#x00F6;" string="\(o:)"/>
    <xsl:output-character character="&#x00F8;" string="\(o/)"/>
    <xsl:output-character character="&#x00F9;" string="\(u`)"/>
    <xsl:output-character character="&#x00FA;" string="\(u')"/>
    <xsl:output-character character="&#x00FB;" string="\(u^)"/>
    <xsl:output-character character="&#x00FC;" string="\(u:)"/>
    <xsl:output-character character="&#x00FF;" string="\(y:)"/>
    <xsl:output-character character="&#x0131;" string="\(dotlessi)"/>
    <xsl:output-character character="&#x0141;" string="\(L/)"/>
    <xsl:output-character character="&#x0142;" string="\(l/)"/>
    <xsl:output-character character="&#x0152;" string="\(OE)"/>
    <xsl:output-character character="&#x0153;" string="\(oe)"/>
    <xsl:output-character character="&#x0160;" string="\(Sv)"/>
    <xsl:output-character character="&#x0161;" string="\(sv)"/>
    <xsl:output-character character="&#x0178;" string="\(Y:)"/>
    <xsl:output-character character="&#x017D;" string="\(Zv)"/>
    <xsl:output-character character="&#x017E;" string="\(zv)"/>
    <xsl:output-character character="&#x0300;" string="\(grave)"/>
    <xsl:output-character character="&#x0301;" string="\(acute)"/>
    <xsl:output-character character="&#x0304;" string="\(macron)"/>
    <xsl:output-character character="&#x0306;" string="\(breve)"/>
    <xsl:output-character character="&#x0307;" string="\(dotaccent)"/>
    <xsl:output-character character="&#x0308;" string="\(dieresis)"/>
    <xsl:output-character character="&#x030A;" string="\(ring)"/>
    <xsl:output-character character="&#x030B;" string="\(hungarumlaut)"/>
    <xsl:output-character character="&#x030C;" string="\(caron)"/>
    <xsl:output-character character="&#x0327;" string="\(cedilla)"/>
    <xsl:output-character character="&#x0328;" string="\(ogonek)"/>
    <xsl:output-character character="&#x2014;" string="\(emdash)"/>
    <xsl:output-character character="&#x201C;" string="\(``)"/>
    <xsl:output-character character="&#x201D;" string="\('')"/>
    <xsl:output-character character="&#x2020;" string="\(dagger)"/>
    <xsl:output-character character="&#x2021;" string="\(daggerdbl)"/>
    <xsl:output-character character="&#x2022;" string="\(bullet)"/>
    <xsl:output-character character="&#x2039;" string="\(quilsinglleft)"/>
    <xsl:output-character character="&#x203A;" string="\(guilsinglright)"/>
    <xsl:output-character character="&#x2018;" string="'"/>
    <xsl:output-character character="&#x2019;" string="'"/>
  </xsl:character-map>

  <xsl:character-map name="music-chars">
    <xsl:output-character character="&#x1D110;" string="\(ferm)"/>
    <xsl:output-character character="&#x1D111;" string="\(uferm)"/>
    <xsl:output-character character="&#x1D1B8;" string="&amp;long;"/>
    <xsl:output-character character="&#x1D15C;" string="&amp;breve;"/>
    <xsl:output-character character="&#x1D15D;" string="\(sm1n)"/>
    <xsl:output-character character="&#x1D15E;" string="\(smup2n)"/>
    <xsl:output-character character="&#x1D15F;" string="\(smup4n)"/>
    <xsl:output-character character="&#x1D160;" string="\(smup8n)"/>
    <xsl:output-character character="&#x1D109;" string="D.S."/>
    <xsl:output-character character="&#x1D10A;" string="D.C."/>
    <xsl:output-character character="&#x1D10B;" string="\(sign)"/>
    <xsl:output-character character="&#x1D10C;" string="\(coda)"/>
    <xsl:output-character character="&#x1D10E;" string="\(measrpt)"/>
    <xsl:output-character character="&#x1D112;" string=","/>
    <xsl:output-character character="&#x1D113;" string="\(rr)"/>
  </xsl:character-map>

  <xsl:output method="text" indent="no" encoding="utf-8"
    use-character-maps="mup-chars music-chars"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- MEI header -->
  <xsl:template match="meihead">
    <xsl:for-each select="filedesc/titlestmt[descendant::text()]">
      <xsl:text>// </xsl:text>
      <xsl:for-each select="title">
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:if test="position() !=last()">
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:value-of select="$nl"/>
      <xsl:for-each select="respstmt[descendant::text()]">
        <xsl:text>// </xsl:text>
        <xsl:for-each select="*">
          <xsl:value-of select="normalize-space(.)"/>
          <xsl:if test="position()!=last()">
            <xsl:text> </xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="$nl"/>
      </xsl:for-each>
      <xsl:value-of select="$nl"/>
    </xsl:for-each>

    <xsl:for-each select="filedesc/pubstmt[descendant::text()]">
      <xsl:for-each select="*">
        <xsl:text>// </xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:value-of select="$nl"/>
      </xsl:for-each>
      <xsl:value-of select="$nl"/>
    </xsl:for-each>

    <xsl:for-each select="filedesc/sourcedesc[descendant::text()]">
      <xsl:value-of select="$nl"/>
      <xsl:for-each select="source">
        <xsl:text>// Source </xsl:text>
        <xsl:value-of select="position()"/>
        <xsl:text>: </xsl:text>
        <xsl:for-each select="titlestmt">
          <xsl:for-each select="title">
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:if test="position() !=last()">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:for-each>
          <xsl:value-of select="$nl"/>
          <xsl:for-each select="respstmt">
            <xsl:text>// </xsl:text>
            <xsl:for-each select="*">
              <xsl:value-of select="normalize-space(.)"/>
              <xsl:if test="position()!=last()">
                <xsl:text> </xsl:text>
              </xsl:if>
            </xsl:for-each>
            <xsl:value-of select="$nl"/>
          </xsl:for-each>
        </xsl:for-each>
        <xsl:for-each select="pubstmt">
          <xsl:for-each select="*">
            <xsl:text>// </xsl:text>
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:value-of select="$nl"/>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:for-each>
      <xsl:value-of select="$nl"/>
    </xsl:for-each>

    <xsl:for-each select="encodingdesc/projectdesc[descendant::text()]">
      <xsl:for-each select="p">
        <xsl:text>// </xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:value-of select="$nl"/>
      </xsl:for-each>
      <xsl:value-of select="$nl"/>
    </xsl:for-each>

    <xsl:for-each select="profiledesc[descendant::text()]">
      <xsl:for-each select="langusage">
        <xsl:value-of select="$nl"/>
        <xsl:text>// Languages: </xsl:text>
        <xsl:for-each select="language">
          <xsl:choose>
            <xsl:when test="text()">
              <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@xml:id"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="position() != last()">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="$nl"/>
      </xsl:for-each>
      <xsl:for-each select="classification">
        <xsl:for-each select="classcode[descendant::text()]">
          <xsl:text>// Class. code </xsl:text>
          <xsl:value-of select="position()"/>
          <xsl:text>: </xsl:text>
          <xsl:value-of select="normalize-space(.)"/>
          <xsl:value-of select="$nl"/>
        </xsl:for-each>
        <xsl:for-each select="keywords[descendant::text()]">
          <xsl:text>// </xsl:text>
          <xsl:for-each select="term[descendant::text()]">
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:if test="@classcode">
              <xsl:variable name="thisclasscode">
                <xsl:value-of select="@classcode"/>
              </xsl:variable>
              <xsl:text> [</xsl:text>
              <xsl:for-each select="//classcode[@xml:id=$thisclasscode]">
                <xsl:value-of select="count(preceding-sibling::classcode) + 1"/>
              </xsl:for-each>
              <xsl:text>]</xsl:text>
            </xsl:if>
            <xsl:if test="position() != last()">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:for-each>
          <xsl:value-of select="$nl"/>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:for-each>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <!-- MEI work element -->
  <xsl:template match="work">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- front and matter -->
  <xsl:template match="front">
    <xsl:text>// front matter not yet implemented</xsl:text>
    <xsl:value-of select="$nl"/>
  </xsl:template>
  <xsl:template match="back">
    <xsl:text>// back matter not yet implemented</xsl:text>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="music">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="mdiv">
    <xsl:apply-templates select="score"/>
  </xsl:template>

  <xsl:template match="score">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="scoredef">
    <xsl:text>score</xsl:text>
    <xsl:value-of select="$nl"/>
    <!-- floating voices, pack factor, scale, and measure numbering set in first scoredef -->
    <xsl:if test="count(preceding::scoredef)=0">
      <xsl:value-of select="$indent"/>
      <xsl:text>vscheme=3f</xsl:text>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="$indent"/>
      <xsl:text>packfact=.5</xsl:text>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="$indent"/>
      <xsl:text>scale=.75 // turned on for testing</xsl:text>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="$indent"/>
      <xsl:text>measnum=y // turned on for testing</xsl:text>
      <xsl:value-of select="$nl"/>
    </xsl:if>

    <!-- How many staves? -->
    <xsl:if test="staffgrp">
      <xsl:value-of select="$indent"/>
      <xsl:text>staffs=</xsl:text>
      <xsl:value-of select="count(.//staffdef)"/>
      <xsl:value-of select="$nl"/>
    </xsl:if>

    <!-- Global optimization? -->
    <xsl:if test="@optimize">
      <xsl:value-of select="$indent"/>
      <xsl:text>visible=whereused</xsl:text>
      <xsl:value-of select="$nl"/>
    </xsl:if>

    <!-- Meter signature -->
    <xsl:choose>
      <xsl:when test="@meter.sym">
        <xsl:value-of select="$indent"/>
        <xsl:text>time=</xsl:text>
        <xsl:value-of select="@meter.sym"/>
        <xsl:if test="@meter.rend='invis'">
          <xsl:text>n</xsl:text>
        </xsl:if>
        <xsl:value-of select="$nl"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="@meter.count">
          <xsl:value-of select="$indent"/><xsl:text>time=</xsl:text>
          <xsl:value-of select="@meter.count"/>/<xsl:value-of
            select="@meter.unit"/>
          <xsl:if test="@meter.rend='invis'">
            <xsl:text>n</xsl:text>
          </xsl:if>
          <xsl:value-of select="$nl"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>

    <!-- Key signature for score -->
    <xsl:if test="@key.sig">
      <xsl:value-of select="$indent"/>
      <xsl:text>key=</xsl:text>
      <xsl:choose>
        <xsl:when test="@key.sig='0'">
          <xsl:text>0&#x0026;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of
            select="replace(replace(@key.sig,'f','&#x0026;'),'s','#')"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="$nl"/>
    </xsl:if>

    <!-- Layout and size info included but currently ignored due to problems converting MusicXML units -->
    <xsl:if test="@page.units">
      <xsl:value-of select="$indent"/>
      <xsl:text>//units=cm</xsl:text>
      <xsl:value-of select="$nl"/>
    </xsl:if>
    <xsl:if test="@page.height">
      <xsl:if test="@page.units='mm'">
        <xsl:value-of select="$indent"/>
        <xsl:text>//pageheight=</xsl:text>
        <xsl:value-of select="@page.height div 100"/>
        <xsl:value-of select="$nl"/>
      </xsl:if>
    </xsl:if>
    <xsl:if test="@page.width">
      <xsl:if test="@page.units='mm'">
        <xsl:value-of select="$indent"/>
        <xsl:text>//pagewidth=</xsl:text>
        <xsl:value-of select="@page.width div 100"/>
        <xsl:value-of select="$nl"/>
      </xsl:if>
    </xsl:if>
    <xsl:if test="@page.leftmar">
      <xsl:if test="@page.units='mm'">
        <xsl:value-of select="$indent"/>
        <xsl:text>//leftmargin=</xsl:text>
        <xsl:value-of select="@page.leftmar div 100"/>
        <xsl:value-of select="$nl"/>
      </xsl:if>
    </xsl:if>
    <xsl:if test="@page.rightmar">
      <xsl:if test="@page.units='mm'">
        <xsl:value-of select="$indent"/>
        <xsl:text>//rightmargin=</xsl:text>
        <xsl:value-of select="@page.rightmar div 100"/>
        <xsl:value-of select="$nl"/>
      </xsl:if>
    </xsl:if>
    <xsl:if test="@page.topmar">
      <xsl:if test="@page.units='mm'">
        <xsl:value-of select="$indent"/>
        <xsl:text>//topmargin=</xsl:text>
        <xsl:value-of select="@page.topmar div 100"/>
        <xsl:value-of select="$nl"/>
      </xsl:if>
    </xsl:if>
    <xsl:if test="@page.botmar">
      <xsl:if test="@page.units='mm'">
        <xsl:value-of select="$indent"/>
        <xsl:text>//botmargin=</xsl:text>
        <xsl:value-of select="@page.botmar div 100"/>
        <xsl:value-of select="$nl"/>
      </xsl:if>
    </xsl:if>
    <xsl:if test="@spacing.system">
      <xsl:value-of select="$indent"/>
      <xsl:text>//scoresep=</xsl:text>
      <xsl:value-of select="@spacing.system"/>
      <xsl:value-of select="$nl"/>
    </xsl:if>
    <xsl:if test="@spacing.staff">
      <xsl:value-of select="$indent"/>
      <xsl:text>//staffsep=</xsl:text>
      <xsl:value-of select="@spacing.staff"/>
      <xsl:value-of select="$nl"/>
    </xsl:if>
    <xsl:if test="@text.size">
      <xsl:value-of select="$indent"/>
      <xsl:text>//size=</xsl:text>
      <xsl:choose>
        <xsl:when test="contains(@text.size,'.')">
          <xsl:value-of select="substring-before(@text.size,'.')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@text.size"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="$nl"/>
    </xsl:if>
    <xsl:if test="@lyric.size">
      <xsl:value-of select="$indent"/>
      <xsl:text>//lyricssize=</xsl:text>
      <xsl:choose>
        <xsl:when test="contains(@lyric.size,'.')">
          <xsl:value-of select="substring-before(@lyric.size,'.')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@lyric.size"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="$nl"/>
    </xsl:if>

    <!-- barlines through staffgrps? -->
    <xsl:if test="descendant::staffgrp[@barthru='true']">
      <xsl:value-of select="$indent"/>
      <xsl:text>barstyle=</xsl:text>
      <xsl:apply-templates select="staffgrp" mode="barlines"/>
      <xsl:value-of select="$nl"/>
    </xsl:if>

    <!-- Indicate brackets and braces -->
    <xsl:variable name="brackets">
      <xsl:apply-templates select="staffgrp" mode="bracket"/>
    </xsl:variable>
    <xsl:if test="replace($brackets,', $', '') != ''">
      <xsl:value-of select="$indent"/>
      <xsl:text>bracket=</xsl:text>
      <xsl:value-of select="replace($brackets,', $', '')"/>
      <xsl:value-of select="$nl"/>
    </xsl:if>
    <xsl:variable name="braces">
      <xsl:apply-templates select="staffgrp" mode="brace"/>
    </xsl:variable>
    <xsl:if test="replace($braces,', $', '') != ''">
      <xsl:value-of select="$indent"/>
      <xsl:text>brace=</xsl:text>
      <xsl:value-of select="replace($braces,', $', '')"/>
      <xsl:value-of select="$nl"/>
    </xsl:if>
    <xsl:value-of select="$nl"/>
    <xsl:apply-templates select="staffgrp|staffdef" mode="def"/>
    <xsl:choose>
      <xsl:when test="pghead1|pghead2|pgfoot1|pgfoot2">
        <xsl:apply-templates select="pghead1|pghead2|pgfoot1|pgfoot2"/>
      </xsl:when>
      <xsl:when test="preceding::filedesc/titlestmt/title[descendant::text()]">
        <xsl:text>header</xsl:text>
        <xsl:value-of select="$nl"/>
        <xsl:value-of select="$indent"/>
        <xsl:text>title </xsl:text>
        <xsl:value-of
          select="concat('&quot;',normalize-space(preceding::filedesc/titlestmt/title[descendant::text()][1]),'&quot;')"/>
        <xsl:value-of select="$nl"/>
        <xsl:value-of select="$indent"/>
        <xsl:text>title </xsl:text>
        <xsl:value-of
          select="concat('&quot;',normalize-space(preceding::filedesc/titlestmt/respstmt/*[name()='name' or name()='corpname' or name()='persname'][1]),'&quot;')"/>
        <xsl:value-of select="$nl"/>
        <xsl:value-of select="$nl"/>
      </xsl:when>
    </xsl:choose>

    <xsl:if
      test="//note[@coloration='inverse']|//chord[@coloration='inverse']|//nota[@coloration='inverse']">
      <xsl:value-of select="$indent"/>
      <xsl:text>headshapes</xsl:text>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="$indent"/>
      <xsl:value-of select="$indent"/>
      <xsl:text>"mei:blk" "4n 4n 4n 4n"</xsl:text>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="$indent"/>
      <xsl:value-of select="$indent"/>
      <xsl:text>"mei:wht" "2n 2n 2n 2n"</xsl:text>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="$nl"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="staffgrp" mode="barlines">
    <xsl:if test="@barthru='true'">
      <xsl:value-of select="staffdef[1]/@n"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="staffdef[last()]/@n"/>
      <xsl:if
        test="following-sibling::staffgrp[@barthru='true']|staffgrp[@barthru='true']">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:apply-templates select="staffgrp[@barthru='true']" mode="barlines"/>
  </xsl:template>

  <xsl:template match="scoredef" mode="MIDI">
    <xsl:for-each select="descendant::staffdef">
      <xsl:choose>
        <xsl:when test="layerdef">
          <xsl:for-each select="layerdef">
            <xsl:if test="@midi.channel or @midi.instr">
              <xsl:value-of select="$indent"/>
              <xsl:text>midi </xsl:text>
              <xsl:value-of select="../@n"/>
              <xsl:text> </xsl:text>
              <xsl:value-of select="@n"/>
              <xsl:text>: </xsl:text>
            </xsl:if>
            <xsl:for-each select="@*[starts-with(name(),'midi.')]">
              <xsl:if test="name()='midi.channel'">
                <xsl:text>0 "channel=</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>";</xsl:text>
              </xsl:if>
              <xsl:if test="name()='midi.instr'">
                <xsl:text>0 "program=</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>";</xsl:text>
              </xsl:if>
              <xsl:if test="position() != last()">
                <xsl:text> </xsl:text>
              </xsl:if>
            </xsl:for-each>
            <xsl:value-of select="$nl"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="@midi.channel or @midi.instr">
            <xsl:value-of select="$indent"/>
            <xsl:text>midi </xsl:text>
            <xsl:value-of select="@n"/>
            <xsl:text> 1-3: </xsl:text>
            <xsl:for-each select="@*[starts-with(name(),'midi.')]">
              <xsl:if test="name()='midi.channel'">
                <xsl:text>0 "channel=</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>";</xsl:text>
              </xsl:if>
              <xsl:if test="name()='midi.instr'">
                <xsl:text>0 "program=</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>";</xsl:text>
              </xsl:if>
              <xsl:if test="position() != last()">
                <xsl:text> </xsl:text>
              </xsl:if>
            </xsl:for-each>
            <xsl:value-of select="$nl"/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="pghead1|pghead2|pgfoot1|pgfoot2">
    <xsl:choose>
      <xsl:when test="name()='pghead1'">
        <xsl:text>header</xsl:text>
      </xsl:when>
      <xsl:when test="name()='pghead2'">
        <xsl:text>header2</xsl:text>
      </xsl:when>
      <xsl:when test="name()='pgfoot1'">
        <xsl:text>footer</xsl:text>
      </xsl:when>
      <xsl:when test="name()='pgfoot2'">
        <xsl:text>footer2</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:value-of select="$nl"/>
    <xsl:apply-templates select="//tr"/>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="tr">
    <xsl:value-of select="$indent"/>
    <xsl:text>title </xsl:text>
    <xsl:apply-templates/>
    <xsl:value-of select="$nl"/>
    <!-- <xsl:if test="ancestor::pghead1 or ancestor::pghead2">
      <xsl:value-of select="$indent"/><xsl:text>title ""</xsl:text><xsl:value-of select="$nl"/>
    </xsl:if> -->
  </xsl:template>

  <xsl:template match="td">
    <xsl:text>"</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>"</xsl:text>
    <xsl:if test="position()!=last()">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="rend">
    <xsl:choose>
      <xsl:when test="@fontstyle='ital' and @fontweight='bold'">
        <xsl:text>\f(times boldital)</xsl:text>
      </xsl:when>
      <xsl:when test="@fontstyle='ital'">
        <xsl:text>\f(times ital)</xsl:text>
      </xsl:when>
      <xsl:when test="@fontweight='bold'">
        <xsl:text>\f(times bold)</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="@fontsize">
      <xsl:text>\s(</xsl:text>
      <xsl:choose>
        <xsl:when test="contains(@fontsize,'.')">
          <xsl:value-of select="substring-before(@fontsize,'.')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@fontsize"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="lb">
    <xsl:text>\n</xsl:text>
  </xsl:template>

  <xsl:template match="staffgrp" mode="def">
    <xsl:apply-templates select="staffdef|staffgrp" mode="def"/>
  </xsl:template>

  <xsl:template match="staffgrp" mode="bracket">
    <xsl:if test="@symbol='bracket'">
      <xsl:value-of select="staffdef[position()=1]/@n"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="staffdef[position()=last()]/@n"/>
      <xsl:if test="@label.full or @label.abbr">
        <xsl:if
          test="not(contains(@label.full,'MusicXML Part') or contains(@label.full,'Part_'))">
          <xsl:text> (</xsl:text>
          <xsl:text>"</xsl:text>
          <xsl:value-of select="replace(@label.full,'&#xD;&#xA;','\\n')"/>
          <xsl:text>",</xsl:text>
          <xsl:text>"</xsl:text>
          <xsl:value-of select="replace(@label.abbr,'&#xD;&#xA;','\\n')"/>
          <xsl:text>"</xsl:text>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:text>, </xsl:text>
    </xsl:if>
    <!-- process grpsym children -->
    <xsl:for-each select="grpsym[@symbol='bracket']">
      <xsl:value-of select="@start"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="@end"/>
      <xsl:if test="@label.full or @label.abbr">
        <xsl:if
          test="not(contains(@label.full,'MusicXML Part') or contains(@label.full,'Part_'))">
          <xsl:text> (</xsl:text>
          <xsl:text>"</xsl:text>
          <xsl:value-of select="replace(@label.full,'&#xD;&#xA;','\\n')"/>
          <xsl:text>",</xsl:text>
          <xsl:text>"</xsl:text>
          <xsl:value-of select="replace(@label.abbr,'&#xD;&#xA;','\\n')"/>
          <xsl:text>"</xsl:text>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:text>, </xsl:text>
    </xsl:for-each>
    <!-- process staffgrp children -->
    <xsl:apply-templates select="staffgrp" mode="bracket"/>
  </xsl:template>

  <xsl:template match="staffgrp" mode="brace">
    <xsl:if test="@symbol='brace'">
      <xsl:value-of select="staffdef[position()=1]/@n"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="staffdef[position()=last()]/@n"/>
      <xsl:if test="@label.full or @label.abbr">
        <xsl:if
          test="not(contains(@label.full,'MusicXML Part') or contains(@label.full,'Part_'))">
          <xsl:text> (</xsl:text>
          <xsl:text>"</xsl:text>
          <xsl:value-of select="replace(@label.full,'&#xD;&#xA;','\\n')"/>
          <xsl:text>",</xsl:text>
          <xsl:text>"</xsl:text>
          <xsl:value-of select="replace(@label.abbr,'&#xD;&#xA;','\\n')"/>
          <xsl:text>"</xsl:text>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:text>, </xsl:text>
    </xsl:if>
    <!-- process grpsym children -->
    <xsl:for-each select="grpsym[@symbol='brace']">
      <xsl:value-of select="@start"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="@end"/>
      <xsl:if test="@label.full or @label.abbr">
        <xsl:if
          test="not(contains(@label.full,'MusicXML Part') or contains(@label.full,'Part_'))">
          <xsl:text> (</xsl:text>
          <xsl:text>"</xsl:text>
          <xsl:value-of select="replace(@label.full,'&#xD;&#xA;','\\n')"/>
          <xsl:text>",</xsl:text>
          <xsl:text>"</xsl:text>
          <xsl:value-of select="replace(@label.abbr,'&#xD;&#xA;','\\n')"/>
          <xsl:text>"</xsl:text>
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:text>, </xsl:text>
    </xsl:for-each>
    <!-- process staffgrp children -->
    <xsl:apply-templates select="staffgrp" mode="brace"/>
  </xsl:template>

  <xsl:template name="mupstrings">
    <xsl:param name="outer"/>
    <xsl:param name="list"/>
    <xsl:param name="count"/>
    <xsl:choose>
      <xsl:when test="count($list) gt 0">
        <xsl:value-of select="replace($outer,'[0-9]','')"/>
        <xsl:call-template name="mupstrings2">
          <xsl:with-param name="outer" select="$outer"/>
          <xsl:with-param name="list" select="$list"/>
          <xsl:with-param name="count" select="$count"/>
        </xsl:call-template>
        <xsl:value-of select="replace($outer,'[^0-9]','')"/>
        <xsl:text> </xsl:text>
        <xsl:call-template name="mupstrings">
          <xsl:with-param name="outer" select="$list[position()=1]"/>
          <xsl:with-param name="list" select="$list[position()!=1]"/>
          <xsl:with-param name="count" select="$count"/>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="mupstrings2">
    <xsl:param name="outer"/>
    <xsl:param name="list"/>
    <xsl:param name="count"/>
    <xsl:choose>
      <xsl:when test="count($list) gt 0">
        <xsl:variable name="pname"
          select="replace($list[position()=1],'[0-9]','')"/>
        <xsl:variable name="outerpname" select="replace($outer,'[0-9]','')"/>
        <xsl:choose>
          <xsl:when test="$pname eq $outerpname">
            <xsl:call-template name="mupstrings2">
              <xsl:with-param name="outer" select="$outer"/>
              <xsl:with-param name="list" select="$list[position()!=1]"/>
              <xsl:with-param name="count" select="$count + 1"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="mupstrings2">
              <xsl:with-param name="outer" select="$outer"/>
              <xsl:with-param name="list" select="$list[position()!=1]"/>
              <xsl:with-param name="count" select="$count"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of
          select="for $i in (1 to $count) return &quot;&apos;&quot;"
        />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="staffdef" mode="def">
    <xsl:text>staff </xsl:text>
    <xsl:value-of select="@n"/>
    <xsl:value-of select="$nl"/>
    <xsl:if test="clef.shape='TAB' or @tab.strings">
      <xsl:value-of select="$indent"/>
      <xsl:text>//tab input staff</xsl:text>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="$indent"/>
      <xsl:text>//in order to produce MIDI output, create a note staff above this one and</xsl:text>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="$indent"/>
      <xsl:text>//copy and any ifdef MIDI statements to it</xsl:text>
      <xsl:value-of select="$nl"/>
    </xsl:if>

    <!-- Clef -->
    <xsl:if test="@clef.line or @clef.shape or @tab.strings">
      <xsl:choose>
        <xsl:when test="@clef.shape='TAB' or @tab.strings">
          <xsl:value-of select="$indent"/>
          <xsl:text>stafflines=tab</xsl:text>
          <xsl:choose>
            <xsl:when test="@tab.strings">
              <xsl:choose>
                <xsl:when
                  test="not(contains(@tab.strings,&quot;&apos;&quot;))">
                  <xsl:variable name="list"
                    select="reverse(tokenize(@tab.strings,' '))"/>
                  <xsl:variable name="tabstrings">
                    <xsl:call-template name="mupstrings">
                      <xsl:with-param name="outer" select="$list[position()=1]"/>
                      <xsl:with-param name="list" select="$list[position()!=1]"/>
                      <xsl:with-param name="count" select="0"/>
                    </xsl:call-template>
                    <xsl:value-of select="$list[position()=last()]"/>
                  </xsl:variable>
                  <xsl:variable name="tabstrings2"
                    select="replace($tabstrings,&quot; &apos;&quot;,&quot;&apos;&quot;)"/>
                  <xsl:variable name="tabstrings3"
                    select="replace($tabstrings2,&quot;_&quot;,&quot;&apos;&quot;)"/>
                  <xsl:text> (</xsl:text>
                  <xsl:value-of select="reverse(tokenize($tabstrings3,' '))"/>
                  <xsl:text>)</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text> (</xsl:text>
                  <xsl:value-of select="@tab.strings"/>
                  <xsl:text>)</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text> (e5 b4 g4 d4 a3 e'3)</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="@clef.shape='perc'">
          <xsl:value-of select="$indent"/>
          <xsl:text>stafflines=5drum</xsl:text>
        </xsl:when>
        <xsl:when test="@clef.shape='G' and @clef.line='1'">
          <xsl:value-of select="$indent"/>
          <xsl:text>clef=</xsl:text>
          <xsl:text>frenchviolin</xsl:text>
        </xsl:when>
        <xsl:when test="@clef.shape='G' and @clef.line='2'">
          <xsl:value-of select="$indent"/>
          <xsl:text>clef=</xsl:text>
          <xsl:if test="@clef.trans='8va'">
            <xsl:text>8</xsl:text>
          </xsl:if>
          <xsl:text>treble</xsl:text>
          <xsl:if test="@clef.trans='8vb'">
            <xsl:text>8</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:when test="@clef.shape='C' and @clef.line='1'">
          <xsl:value-of select="$indent"/>
          <xsl:text>clef=</xsl:text>
          <xsl:text>soprano</xsl:text>
        </xsl:when>
        <xsl:when test="@clef.shape='C' and @clef.line='2'">
          <xsl:value-of select="$indent"/>
          <xsl:text>clef=</xsl:text>
          <xsl:text>mezzosoprano</xsl:text>
        </xsl:when>
        <xsl:when test="@clef.shape='C' and @clef.line='3'">
          <xsl:value-of select="$indent"/>
          <xsl:text>clef=</xsl:text>
          <xsl:text>alto</xsl:text>
        </xsl:when>
        <xsl:when test="@clef.shape='C' and @clef.line='4'">
          <xsl:value-of select="$indent"/>
          <xsl:text>clef=</xsl:text>
          <xsl:text>tenor</xsl:text>
        </xsl:when>
        <xsl:when test="@clef.shape='C' and @clef.line='5'">
          <xsl:value-of select="$indent"/>
          <xsl:text>clef=</xsl:text>
          <xsl:text>baritone</xsl:text>
        </xsl:when>
        <xsl:when test="@clef.shape='F' and @clef.line='4'">
          <xsl:value-of select="$indent"/>
          <xsl:text>clef=</xsl:text>
          <xsl:text>bass</xsl:text>
        </xsl:when>
      </xsl:choose>
      <xsl:value-of select="$nl"/>
    </xsl:if>

    <!-- Staff label -->
    <xsl:choose>
      <xsl:when
        test="@label.full and not(contains(@label.full,'MusicXML Part') or contains(@label.full,'Part_'))">
        <xsl:value-of select="$indent"/>
        <xsl:text>label="</xsl:text>
        <xsl:value-of select="replace(@label.full,'&#xD;&#xA;','\\n')"/>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="$nl"/>
      </xsl:when>
      <xsl:when
        test="contains(@label.full,'MusicXML Part') or contains(@label.full,'Part_')">
        <xsl:value-of select="$indent"/>
        <xsl:text>label=""</xsl:text>
        <xsl:value-of select="$nl"/>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="@label.abbr">
      <xsl:value-of select="$indent"/>
      <xsl:text>label2="</xsl:text>
      <xsl:value-of select="replace(@label.abbr,'&#xD;&#xA;','\\n')"/>
      <xsl:text>"</xsl:text>
      <xsl:value-of select="$nl"/>
    </xsl:if>

    <!-- Staff key signature -->
    <xsl:if test="@key.sig">
      <xsl:if
        test="@key.sig != following::scoredef[1]/@key.sig or count(following::scoredef) = 0">
        <xsl:value-of select="$indent"/>
        <xsl:text>key=</xsl:text>
        <xsl:choose>
          <xsl:when test="@key.sig='0'">
            <xsl:text>0&#x0026;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of
              select="replace(replace(@key.sig,'f','&#x0026;'),'s','#')"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$nl"/>
      </xsl:if>
    </xsl:if>

    <!-- Pedal style -->
    <xsl:variable name="thisstaff">
      <xsl:value-of select="@n"/>
    </xsl:variable>
    <xsl:if test="following::pedal[@style='pedstar'][@staff=$thisstaff]">
      <xsl:value-of select="$indent"/>
      <xsl:text>pedstyle=pedstar</xsl:text>
      <xsl:value-of select="$nl"/>
    </xsl:if>

    <!-- Transposition -->
    <xsl:if test="@trans.semi">
      <xsl:call-template name="transposition"/>
    </xsl:if>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template name="transposition">
    <xsl:value-of select="$indent"/>
    <xsl:text>ifdef MIDI</xsl:text>
    <xsl:value-of select="$nl"/>
    <xsl:value-of select="$indent"/>
    <xsl:value-of select="$indent"/>
    <xsl:text>transpose=</xsl:text>
    <xsl:choose>
      <xsl:when test="@trans.semi &gt;= 0">
        <xsl:text>up </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>down </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="@trans.semi=0">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=0">
            <xsl:text>per 1</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=1">
            <xsl:text>dim 2</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>per 1 //dim 2</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=1">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=0">
            <xsl:text>aug 1</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=1">
            <xsl:text>min 2</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>aug 1 //min 2</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=2">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=1">
            <xsl:text>maj 2</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=2">
            <xsl:text>dim 3</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>maj 2 //dim 3</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=3">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=1">
            <xsl:text>aug 2</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=2">
            <xsl:text>min 3</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>aug 2 //min 3</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=4">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=2">
            <xsl:text>maj 3</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=3">
            <xsl:text>dim 4</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>maj 3 //dim 4</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=5">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=2">
            <xsl:text>aug 3</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=3">
            <xsl:text>per 4</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>aug 3 //per 4</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=6">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=3">
            <xsl:text>aug 4</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=4">
            <xsl:text>dim 5</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>aug 4 //dim 5</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=7">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=4">
            <xsl:text>per 5</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=5">
            <xsl:text>dim 6</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>per 5 //dim 6</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=8">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=4">
            <xsl:text>aug 5</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=5">
            <xsl:text>min 6</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>aug 5 //min 6</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=9">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=5">
            <xsl:text>maj 6</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=6">
            <xsl:text>dim 7</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>maj 6 //dim 7</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=10">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=5">
            <xsl:text>aug 6</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=6">
            <xsl:text>min 7</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>aug 6 //min 7</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=11">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=6">
            <xsl:text>maj 7</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=7">
            <xsl:text>dim 8</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>maj 7 //dim 8</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=12">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=0">
            <xsl:text>per 8</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=1">
            <xsl:text>dim 9</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>per 8 //dim 9</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=13">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=0">
            <xsl:text>aug 8</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=1">
            <xsl:text>min 9</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>aug 8 //min 9</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=14">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=1">
            <xsl:text>maj 9</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=2">
            <xsl:text>dim 10</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>maj 9 //dim 10</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=15">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=1">
            <xsl:text>aug 9</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=2">
            <xsl:text>min 10</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>aug 9 //min 10</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=16">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=2">
            <xsl:text>maj 10</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=3">
            <xsl:text>dim 11</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>maj 10 //dim 11</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=17">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=2">
            <xsl:text>aug 10</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=3">
            <xsl:text>per 11</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>aug 10 //per 11</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=18">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=3">
            <xsl:text>aug 11</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=4">
            <xsl:text>dim 12</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>aug 11 //dim 12</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=19">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=4">
            <xsl:text>per 12</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=5">
            <xsl:text>dim 13</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>per 12 //dim 13</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=20">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=4">
            <xsl:text>aug 12</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=5">
            <xsl:text>min 13</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>aug 12 //min 13</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=21">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=5">
            <xsl:text>maj 13</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=6">
            <xsl:text>dim 14</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>maj 13 //dim 14</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=22">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=5">
            <xsl:text>aug 13</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=6">
            <xsl:text>min 14</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>aug 13 //min 14</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=23">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=6">
            <xsl:text>maj 14</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=7">
            <xsl:text>dim 15</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>maj 14 //dim 15</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="abs(@trans.semi)=24">
        <xsl:choose>
          <xsl:when test="abs(@trans.diat)=0">
            <xsl:text>per 15</xsl:text>
          </xsl:when>
          <xsl:when test="abs(@trans.diat)=1">
            <xsl:text>dim 16</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>per 15 //dim 16</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
    <xsl:value-of select="$nl"/>
    <xsl:if test="not(@trans.diat)">
      <xsl:value-of select="$indent"/>
      <xsl:value-of select="$indent"/>
      <xsl:text>//Hand-editing of the transpose parameter may be required.</xsl:text>
      <xsl:value-of select="$nl"/>
    </xsl:if>
    <xsl:value-of select="$indent"/>
    <xsl:text>endif</xsl:text>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="section">
    <xsl:if
      test="not(scoredef[@meter.count and @meter.unit] or preceding::scoredef[@meter.count and @meter.unit])">
      <xsl:variable name="sumdur">
        <xsl:value-of
          select="sum(measure[1]/staff[1]/layer[1]//*[@dur.ges]/@dur.ges)"/>
      </xsl:variable>
      <xsl:variable name="ppq">
        <xsl:choose>
          <xsl:when test="preceding::staffdef[@n='1'][@midi.div]">
            <xsl:value-of
              select="preceding::staffdef[@n='1'][@midi.div][1]/@midi.div"/>
          </xsl:when>
          <xsl:when test="descendant::staffdef[@n='1'][@midi.div]">
            <xsl:value-of
              select="descendant::staffdef[@n='1'][@midi.div][1]/@midi.div"/>
          </xsl:when>
          <xsl:when test="descendant::note[@dur='4' and @dur.ges]">
            <xsl:value-of
              select="following::note[@dur='4' and @dur.ges][1]/@dur.ges"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>96</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:text>score</xsl:text>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="$indent"/>
      <xsl:text>time=</xsl:text>
      <xsl:value-of select="$sumdur div $ppq"/>
      <xsl:text>/4n</xsl:text>
      <xsl:value-of select="$nl"/>
    </xsl:if>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="fermata">
    <xsl:if test="not(@source) or contains(string(@source),$source)">
      <xsl:value-of select="$indent"/>
      <xsl:text>mussym </xsl:text>
      <xsl:value-of select="@place"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@staff"/>
      <!-- Vertical offset -->
      <xsl:if test="@vo">
        <xsl:text> dist </xsl:text>
        <xsl:value-of select="@vo"/>
        <xsl:text>!</xsl:text>
      </xsl:if>
      <xsl:text>: </xsl:text>
      <xsl:choose>
        <xsl:when test="not(@tstamp)">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:when test="@tstamp=0">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="round-half-to-even(@tstamp,3)"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text> "</xsl:text>
      <xsl:choose>
        <xsl:when test="@form='inv' or @place='below'">
          <xsl:text>\(uferm)</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>\(ferm)</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>";</xsl:text>
      <xsl:value-of select="$nl"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tempo|dir">
    <xsl:if test="not(@source) or contains(string(@source),$source)">
      <xsl:value-of select="$indent"/>
      <xsl:choose>
        <xsl:when
          test="matches(.,'&#x1D110;') or matches(.,'&#x1D111;')">
          <xsl:text>mussym </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>rom </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="@place"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@staff"/>
      <!-- Vertical offset -->
      <xsl:if test="@vo">
        <xsl:text> dist </xsl:text>
        <xsl:value-of select="@vo"/>
        <xsl:text>!</xsl:text>
      </xsl:if>
      <xsl:text>: </xsl:text>
      <xsl:choose>
        <xsl:when test="not(@tstamp)">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:when test="@tstamp=0">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="round-half-to-even(@tstamp,3)"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text> "</xsl:text>
      <xsl:variable name="content">
        <xsl:apply-templates/>
      </xsl:variable>
      <xsl:value-of select="normalize-space($content)"/>
      <xsl:text>";</xsl:text>
      <xsl:value-of select="$nl"/>
      <xsl:if test="name(.)='tempo' and @value &gt; 0">
        <xsl:value-of select="$indent"/>
        <xsl:text>midi all: </xsl:text>
        <xsl:value-of select="round-half-to-even(@tstamp,3)"/>
        <xsl:text> "tempo=</xsl:text>
        <xsl:value-of select="@value"/>
        <xsl:text>";</xsl:text>
        <xsl:value-of select="$nl"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="tstamp2beat">
    <xsl:variable name="thisstaff">
      <xsl:value-of select="@staff"/>
    </xsl:variable>
    <xsl:variable name="ppq">
      <xsl:choose>
        <xsl:when test="preceding::staffdef[@n=$thisstaff][@midi.div]">
          <xsl:value-of
            select="preceding::staffdef[@n=$thisstaff][@midi.div][1]/@midi.div"
          />
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>96</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="meter.unit">
      <xsl:choose>
        <xsl:when test="preceding::*[@meter.unit]/@meter.unit">
          <xsl:value-of select="preceding::*[@meter.unit][1]/@meter.unit"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>4</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$meter.unit = 4">
        <xsl:value-of select="round-half-to-even(@tstamp div $ppq,3)"/>
      </xsl:when>
      <xsl:when test="$meter.unit != 4">
        <xsl:value-of
          select="round-half-to-even((@tstamp div $ppq) * ($meter.unit div 4),3)"
        />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="verse">
    <xsl:param name="total"/>
    <xsl:param name="count"/>
    <xsl:for-each select="layer[descendant::verse]">
      <xsl:variable name="versestring">
        <xsl:for-each select="beam|note|chord">
          <xsl:choose>
            <xsl:when test="(name()='chord' or name()='note') and not(@grace)">
              <xsl:if test="verse/syl">
                <xsl:value-of select="verse[@n=$count]/syl"/>
                <xsl:choose>
                  <xsl:when test="verse[@n=$count]/syl/@con='d'">
                    <xsl:text>-</xsl:text>
                  </xsl:when>
                  <xsl:when test="verse[@n=$count]/syl/@con='u'">
                    <xsl:text>_</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text> </xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:if>
            </xsl:when>
            <xsl:when test="name()='beam'">
              <xsl:for-each select="beam|note|chord">
                <xsl:choose>
                  <xsl:when
                    test="(name()='chord' or name()='note') and not(@grace)">
                    <xsl:if test="verse/syl">
                      <xsl:value-of select="verse[@n=$count]/syl"/>
                      <xsl:choose>
                        <xsl:when test="verse[@n=$count]/syl/@con='d'">
                          <xsl:text>-</xsl:text>
                        </xsl:when>
                        <xsl:when test="verse[@n=$count]/syl/@con='u'">
                          <xsl:text>_</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:text> </xsl:text>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:if>
                  </xsl:when>
                </xsl:choose>
              </xsl:for-each>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>
      <xsl:text>"</xsl:text>
      <xsl:value-of select="normalize-space($versestring)"/>
      <xsl:text>";</xsl:text>
      <xsl:value-of select="$nl"/>
    </xsl:for-each>
    <xsl:if test="$count &lt; $total">
      <xsl:call-template name="verse">
        <xsl:with-param name="count">
          <xsl:value-of select="$count + 1"/>
        </xsl:with-param>
        <xsl:with-param name="total">
          <xsl:value-of select="$total"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="measure">
    <xsl:if
      test="contains(name(preceding-sibling::*[not(comment())][1]), 'def') or count(preceding-sibling::measure)=0">
      <xsl:text>music</xsl:text>
      <xsl:value-of select="$nl"/>
      <xsl:if test="ancestor::section[1]/@restart='true'">
        <xsl:value-of select="$indent"/>
        <xsl:text>restart</xsl:text>
        <xsl:value-of select="$nl"/>
      </xsl:if>
    </xsl:if>
    <xsl:value-of select="$indent"/>
    <xsl:text>// m. </xsl:text>
    <xsl:value-of select="@n"/>
    <xsl:value-of select="$nl"/>

    <!-- Process initial MIDI settings in 1st measure -->
    <xsl:if test="count(preceding::measure)=0">
      <xsl:apply-templates
        select="preceding::scoredef[count(preceding::scoredef)=0]" mode="MIDI"/>
    </xsl:if>

    <xsl:apply-templates select="staff"/>
    <xsl:apply-templates
      select="annot|arpeg|dir|dynam|fermata|hairpin|phrase|reh|slur|tempo|mordent|trill|turn"/>
    <xsl:apply-templates select="staff//halfmrpt" mode="draw"/>
    <xsl:apply-templates select="pedal">
      <xsl:sort select="@tstamp" data-type="number"/>
      <xsl:sort select="@dir" order="descending" data-type="text"/>
    </xsl:apply-templates>

    <!-- lyrics -->
    <xsl:for-each select="staff[descendant::verse]">
      <xsl:value-of select="$indent"/>
      <xsl:text>lyrics below </xsl:text>
      <xsl:value-of select="@n"/>
      <xsl:text>: </xsl:text>

      <!-- create duration string -->
      <xsl:for-each select="layer[descendant::verse]">
        <xsl:for-each select="beam|chord|note|rest|space">
          <xsl:choose>
            <xsl:when
              test="name()='chord' or name()='note' or name()='rest' or name()='space'">
              <xsl:if test="not(@grace)">
                <xsl:call-template name="tupletstart"/>
                <xsl:choose>
                  <xsl:when test="@dur">
                    <xsl:choose>
                      <xsl:when test="@dur='breve'">
                        <xsl:text>1/2</xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="@dur"/>
                      </xsl:otherwise>
                    </xsl:choose>
                    <xsl:call-template name="makedots"/>
                  </xsl:when>
                  <xsl:when test="@dur.ges">
                    <xsl:call-template name="quantization"/>
                  </xsl:when>
                </xsl:choose>
                <xsl:if test="not(descendant::syl)">
                  <xsl:text>s</xsl:text>
                </xsl:if>
                <xsl:text>;</xsl:text>
                <xsl:call-template name="tupletendlyrics"/>
              </xsl:if>
            </xsl:when>
            <xsl:when test="name()='beam'">
              <xsl:for-each select="chord|note|rest">
                <xsl:if test="not(@grace)">
                  <xsl:call-template name="tupletstart"/>
                  <xsl:value-of select="@dur"/>
                  <xsl:call-template name="makedots"/>
                  <xsl:if test="not(descendant::syl)">
                    <xsl:text>s</xsl:text>
                  </xsl:if>
                  <xsl:text>;</xsl:text>
                  <xsl:call-template name="tupletendlyrics"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </xsl:for-each>

      <!-- lyric string -->
      <xsl:variable name="lyricstring">
        <xsl:variable name="versecount">
          <xsl:value-of
            select="count(layer[descendant::verse]/*[verse][1]/verse)"/>
        </xsl:variable>
        <xsl:call-template name="verse">
          <xsl:with-param name="count">1</xsl:with-param>
          <xsl:with-param name="total">
            <xsl:value-of select="$versecount"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="normalize-space(replace($lyricstring,'[ ]+',' '))"/>
      <xsl:value-of select="$nl"/>
    </xsl:for-each>

    <!-- Process all slurs in the last measure, looking for cross-staff,
      grace to grace-note, or non-grace to grace-note slurs. -->
    <xsl:if test="count(following::measure)=0">
      <xsl:apply-templates
        select="preceding::*[name()='phrase' or name()='slur']" mode="special"/>
    </xsl:if>

    <xsl:value-of select="$indent"/>
    <!-- right bar line -->
    <xsl:variable name="bar_style">
      <xsl:choose>
        <xsl:when test="@right='dashed'">
          <xsl:text>dashed bar</xsl:text>
        </xsl:when>
        <xsl:when test="@right='dotted'">
          <xsl:text>dotted bar</xsl:text>
        </xsl:when>
        <xsl:when test="@right='dbl'">
          <xsl:text>dblbar</xsl:text>
        </xsl:when>
        <xsl:when test="@right='dbldashed'">
          <xsl:text>dashed dblbar</xsl:text>
        </xsl:when>
        <xsl:when test="@right='dbldotted'">
          <xsl:text>dotted dblbar</xsl:text>
        </xsl:when>
        <xsl:when test="@right='end'">
          <xsl:text>endbar</xsl:text>
        </xsl:when>
        <xsl:when test="@right='invis'">
          <xsl:text>invisbar</xsl:text>
        </xsl:when>
        <xsl:when test="@right='rptstart'">
          <xsl:text>repeatstart</xsl:text>
        </xsl:when>
        <xsl:when test="@right='rptboth'">
          <xsl:text>repeatboth</xsl:text>
        </xsl:when>
        <xsl:when test="@right='rptend'">
          <xsl:text>repeatend</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>bar</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when
        test="not(contains($bar_style,'repeat')) and following::measure[1]/@left='rptstart'">
        <xsl:text>(</xsl:text>
        <xsl:value-of select="$bar_style"/>
        <xsl:text>) repeatstart</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$bar_style"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="number(@n) and following::measure">
      <xsl:text> mnum=</xsl:text>
      <xsl:value-of select="@n + 1"/>
    </xsl:if>
    <!-- ending designation -->
    <xsl:variable name="ending">
      <xsl:apply-templates select="following::measure[1]"
        mode="ending_start_next_measure"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$ending != ''">
        <xsl:value-of select="$ending"/>
      </xsl:when>
      <xsl:when test="@xml:id=parent::ending/measure[last()]/@xml:id">
        <xsl:text> endending</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:value-of select="$nl"/>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="annot">
    <xsl:value-of select="$indent"/>
    <xsl:text>//</xsl:text>
    <xsl:text> staff: </xsl:text>
    <xsl:value-of select="@staff"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="reh">
    <xsl:value-of select="$indent"/>
    <xsl:text>rom </xsl:text>
    <xsl:value-of select="@place"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@staff"/>
    <xsl:text>: </xsl:text>
    <xsl:value-of select="@tstamp"/>
    <xsl:text> </xsl:text>
    <xsl:text>"</xsl:text>
    <xsl:choose>
      <xsl:when test="@enclose='box'">
        <xsl:text>\[</xsl:text>
      </xsl:when>
      <xsl:when test="@enclose='circle'">
        <xsl:text>\{</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="rend">
        <xsl:apply-templates select="rend"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="@enclose='box'">
        <xsl:text>\]</xsl:text>
      </xsl:when>
      <xsl:when test="@enclose='circle'">
        <xsl:text>\}</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:text>";</xsl:text>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="mordent|trill|turn">
    <!-- test for accidental above symbol -->
    <xsl:if test="@accidupper !=''">
      <xsl:value-of select="$indent"/>
      <xsl:text>mussym </xsl:text>
      <xsl:value-of select="@place"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@staff"/>
      <xsl:text>: </xsl:text>
      <xsl:value-of select="@tstamp"/>
      <xsl:text> </xsl:text>
      <xsl:choose>
        <xsl:when test="@accidupper='s'">
          <xsl:text>"\(sharp)"</xsl:text>
        </xsl:when>
        <xsl:when test="@accidupper='f'">
          <xsl:text>"\(flat)"</xsl:text>
        </xsl:when>
        <xsl:when test="@accidupper='ss'">
          <xsl:text>"\(sharp)\(sharp)"</xsl:text>
        </xsl:when>
        <xsl:when test="@accidupper='x'">
          <xsl:text>"\(dblsharp)"</xsl:text>
        </xsl:when>
        <xsl:when test="@accidupper='ff'">
          <xsl:text>"\(dblflat)"</xsl:text>
        </xsl:when>
        <xsl:when test="@accidupper='n'">
          <xsl:text>"\(nat)"</xsl:text>
        </xsl:when>
      </xsl:choose>
      <xsl:text>;</xsl:text>
      <xsl:value-of select="$nl"/>
    </xsl:if>

    <!-- output symbol -->
    <xsl:value-of select="$indent"/>
    <xsl:text>mussym </xsl:text>
    <xsl:value-of select="@place"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@staff"/>
    <xsl:text>: </xsl:text>
    <xsl:choose>
      <xsl:when test="name()='turn' and @delayed='yes'">
        <xsl:value-of select="@tstamp + .5"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@tstamp"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="name()='mordent'">
        <!-- mup's symbols for mordent (w/o vertical line) and inverted mordent
             (w/ vertical line) are backwards from Read. -->
        <xsl:choose>
          <xsl:when test="@form='inv'">
            <xsl:text>"\(mor)</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>"\(invmor)</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@long='yes'">
          <xsl:text>\b   \(mor)</xsl:text>
        </xsl:if>
        <xsl:text>"</xsl:text>
      </xsl:when>
      <xsl:when test="name()='trill'">
        <xsl:text>"\(tr)"</xsl:text>
      </xsl:when>
      <xsl:when test="name()='turn'">
        <xsl:choose>
          <xsl:when test="@form='inv'">
            <xsl:text>"\(invturn)"</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>"\(turn)"</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="$nl"/>

    <!-- test for accidental below symbol -->
    <xsl:if test="@accidlower!=''">
      <xsl:value-of select="$indent"/>
      <xsl:text>mussym </xsl:text>
      <xsl:value-of select="@place"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@staff"/>
      <xsl:text>: </xsl:text>
      <xsl:value-of select="@tstamp"/>
      <xsl:text> </xsl:text>
      <xsl:choose>
        <xsl:when test="@accidlower='s'">
          <xsl:text>"\(sharp)"</xsl:text>
        </xsl:when>
        <xsl:when test="@accidlower='f'">
          <xsl:text>"\(flat)"</xsl:text>
        </xsl:when>
        <xsl:when test="@accidlower='ss'">
          <xsl:text>"\(sharp)\(sharp)"</xsl:text>
        </xsl:when>
        <xsl:when test="@accidlower='x'">
          <xsl:text>"\(dblsharp)"</xsl:text>
        </xsl:when>
        <xsl:when test="@accidlower='ff'">
          <xsl:text>"\(dblflat)"</xsl:text>
        </xsl:when>
        <xsl:when test="@accidlower='n'">
          <xsl:text>"\(nat)"</xsl:text>
        </xsl:when>
      </xsl:choose>
      <xsl:text>;</xsl:text>
      <xsl:value-of select="$nl"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="getdurattr">
    <xsl:value-of select="@dur"/>
  </xsl:template>

  <xsl:template match="arpeg">
    <!-- roll 1 1 to 1 2: 1; -->
    <xsl:value-of select="$indent"/>
    <xsl:text>roll </xsl:text>
    <xsl:choose>
      <xsl:when test="@dir='up'">
        <xsl:text>up </xsl:text>
      </xsl:when>
      <xsl:when test="@dir='down'">
        <xsl:text>down </xsl:text>
      </xsl:when>
    </xsl:choose>
    <!-- start staff and layer -->
    <xsl:choose>
      <xsl:when test="count(tokenize(distinct-values(@staff),' ')) = 1">
        <xsl:value-of select="@staff"/>
        <xsl:choose>
          <xsl:when test="count(tokenize(distinct-values(@layer), ' ')) = 1">
            <xsl:text> </xsl:text>
            <xsl:value-of select="@layer"/>
          </xsl:when>
          <xsl:when
            test="count(tokenize(distinct-values(@layer), ' ')) &gt; 1">
            <xsl:text> </xsl:text>
            <xsl:value-of
              select="substring-before(string(distinct-values(@layer)),' ')"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="count(tokenize(distinct-values(@staff),' ')) &gt; 1">
        <xsl:value-of
          select="substring-before(string(distinct-values(@staff)),' ')"/>
        <xsl:choose>
          <xsl:when test="count(tokenize(distinct-values(@layer), ' ')) = 1">
            <xsl:text> </xsl:text>
            <xsl:value-of select="@layer"/>
          </xsl:when>
          <xsl:when
            test="count(tokenize(distinct-values(@layer), ' ')) &gt; 1">
            <xsl:text> </xsl:text>
            <xsl:value-of
              select="substring-before(string(distinct-values(@layer)),' ')"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
    <xsl:text> to </xsl:text>
    <!-- end staff and layer -->
    <xsl:choose>
      <xsl:when test="count(tokenize(distinct-values(@staff),' ')) = 1">
        <xsl:value-of select="@staff"/>
        <xsl:choose>
          <xsl:when test="count(tokenize(distinct-values(@layer), ' ')) = 1">
            <xsl:text> </xsl:text>
            <xsl:value-of select="@layer"/>
          </xsl:when>
          <xsl:when
            test="count(tokenize(distinct-values(@layer), ' ')) &gt; 1">
            <xsl:text> </xsl:text>
            <xsl:value-of
              select="substring-after(string(distinct-values(@layer)),' ')"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="count(tokenize(distinct-values(@staff),' ')) &gt; 1">
        <xsl:value-of
          select="substring-after(string(distinct-values(@staff)),' ')"/>
        <xsl:choose>
          <xsl:when test="count(tokenize(distinct-values(@layer), ' ')) = 1">
            <xsl:text> </xsl:text>
            <xsl:value-of select="@layer"/>
          </xsl:when>
          <xsl:when
            test="count(tokenize(distinct-values(@layer), ' ')) &gt; 1">
            <xsl:text> </xsl:text>
            <xsl:value-of
              select="substring-after(string(distinct-values(@layer)),' ')"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
    <xsl:text>: </xsl:text>
    <xsl:value-of select="round-half-to-even(@tstamp,3)"/>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="phrase|slur">
    <xsl:choose>
      <xsl:when test="count(tokenize(@staff, '\s+')) &gt; 1">
        <!-- Slur must be drawn using startid and endid in last measure -->
        <xsl:value-of select="$indent"/>
        <xsl:text>// cross-staff slur encoded in last measure</xsl:text>
        <xsl:value-of select="$nl"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- Inspect notes of attachment -->
        <xsl:variable name="thisstart">
          <xsl:value-of select="@startid"/>
        </xsl:variable>
        <xsl:variable name="thisend">
          <xsl:value-of select="@endid"/>
        </xsl:variable>
        <xsl:variable name="starttype">
          <xsl:value-of select="//note[@xml:id=$thisstart]/@grace"/>
        </xsl:variable>
        <xsl:variable name="endtype">
          <xsl:value-of select="//note[@xml:id=$thisend]/@grace"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$starttype != '' and $endtype != ''">
            <!-- Slur must be drawn using startid and endid in last measure -->
            <xsl:value-of select="$indent"/>
            <xsl:text>// grace to grace note slur encoded in last measure</xsl:text>
            <xsl:value-of select="$nl"/>
          </xsl:when>
          <xsl:when test="$starttype != '' and $endtype = ''">
            <!-- grace to non-grace note, using @dur, counting grace
            notes preceding the non-grace note -->
            <xsl:value-of select="$indent"/>
            <xsl:text>phrase </xsl:text>
            <xsl:value-of select="@place"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@staff"/>
            <xsl:text>: </xsl:text>
            <xsl:choose>
              <xsl:when test="@tstamp">
                <xsl:value-of select="round-half-to-even(@tstamp, 3)"/>
              </xsl:when>
              <xsl:when test="@dur">
                <xsl:value-of select="round-half-to-even(@dur, 3)"/>
              </xsl:when>
            </xsl:choose>
            <xsl:text>(-</xsl:text>
            <xsl:variable name="thislayer">
              <xsl:value-of select="generate-id(preceding::note[@xml:id=$thisend]/ancestor::layer)"/>
            </xsl:variable>
            <xsl:value-of
              select="count(preceding::note[@xml:id=$thisend]/preceding::note[@grace][ancestor::layer[generate-id()=$thislayer]][preceding::note[@xml:id=$thisstart]]) + 1"/>
            <xsl:text>) til </xsl:text>
            <xsl:choose>
              <xsl:when test="@dur">
                <xsl:choose>
                  <xsl:when test="contains(@dur, '+')">
                    <xsl:value-of select="substring-before(@dur, '+')"/>
                    <xsl:text> + </xsl:text>
                    <xsl:value-of
                      select="round-half-to-even(number(substring-after(@dur, '+')),3)"
                    />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="round-half-to-even(@dur,3)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="@tstamp">
                <xsl:value-of select="@tstamp"/>
              </xsl:when>
            </xsl:choose>
            <xsl:text>;</xsl:text>
            <xsl:value-of select="$nl"/>
          </xsl:when>
          <xsl:when test="$starttype = '' and $endtype = ''">
            <!-- non-grace to non-grace note, use @tstamp and @dur -->
            <xsl:value-of select="$indent"/>
            <xsl:text>phrase </xsl:text>
            <xsl:value-of select="@place"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@staff"/>
            <xsl:text>: </xsl:text>
            <xsl:value-of select="round-half-to-even(@tstamp, 3)"/>
            <xsl:text> til </xsl:text>
            <xsl:if test="contains(@dur, '+')">
              <xsl:value-of select="substring-before(@dur, '+')"/>
              <xsl:text> + </xsl:text>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="contains(@dur, '+')">
                <xsl:value-of
                  select="round-half-to-even(number(substring-after(@dur, '+')), 3)"
                />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="round-half-to-even(@dur, 3)"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:text>;</xsl:text>
            <xsl:value-of select="$nl"/>
          </xsl:when>
          <xsl:when test="$starttype = '' and $endtype != ''">
            <xsl:choose>
              <xsl:when
                test="count(preceding::note[@xml:id=$thisend]/following-sibling::note[not(@grace)]) = 0">
                <!-- Mup doesn't support grace notes as the last items in a measure -->
                <xsl:value-of select="$indent"/>
                <xsl:text>// Mup doesn't support grace notes as the last items in a measure; slur not encoded</xsl:text>
                <xsl:value-of select="$nl"/>
              </xsl:when>
              <xsl:otherwise>
                <!-- Slur must be drawn using startid and endid in last measure -->
                <xsl:value-of select="$indent"/>
                <xsl:text>// non-grace to grace note slur encoded in last measure</xsl:text>
                <xsl:value-of select="$nl"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="phrase|slur" mode="special">
    <xsl:variable name="thisstart">
      <xsl:value-of select="@startid"/>
    </xsl:variable>
    <xsl:variable name="thisend">
      <xsl:value-of select="@endid"/>
    </xsl:variable>
    <xsl:variable name="starttype">
      <xsl:value-of select="//note[@xml:id=$thisstart]/@grace"/>
    </xsl:variable>
    <xsl:variable name="endtype">
      <xsl:value-of select="//note[@xml:id=$thisend]/@grace"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="count(tokenize(@staff, '\s+')) &gt; 1">
        <!-- Slur must be drawn using startid and endid in last measure -->
        <xsl:call-template name="drawslur"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- Inspect notes of attachment -->
        <xsl:choose>
          <xsl:when test="$starttype != '' and $endtype != ''">
            <!-- Slur must be drawn using startid and endid in last measure -->
            <xsl:call-template name="drawslur"/>
          </xsl:when>
          <xsl:when test="$starttype != '' and $endtype = ''">
            <!-- grace to non-grace note, using @dur, counting grace
            notes preceding the non-grace note -->
            <!-- Do nothing!  Slur already handled in phrase|slur template -->
          </xsl:when>
          <xsl:when test="$starttype = '' and $endtype = ''">
            <!-- non-grace to non-grace note, use @tstamp and @dur -->
            <!-- Do nothing!  Slur already handled in phrase|slur template -->
          </xsl:when>
          <xsl:when test="$starttype = '' and $endtype != ''">
            <xsl:choose>
              <xsl:when
                test="count(preceding::note[@xml:id=$thisend]/following-sibling::note[not(@grace)]) = 0">
                <!-- Mup doesn't support grace notes as the last items in a measure -->
                <!-- Do nothing!  Slur already handled in phrase|slur template -->
              </xsl:when>
              <xsl:otherwise>
                <!-- Slur must be drawn using startid and endid in last measure -->
                <xsl:call-template name="drawslur"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="drawslur">
    <xsl:value-of select="$indent"/>
    <xsl:text>medium curve (_</xsl:text>
    <xsl:value-of select="@startid"/>
    <xsl:text>.x, _</xsl:text>
    <xsl:value-of select="@startid"/>
    <xsl:text>.y</xsl:text>
    <xsl:choose>
      <xsl:when test="@place='below'">
        <xsl:text>-3</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>+3</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>) to (_</xsl:text>
    <xsl:value-of select="@endid"/>
    <xsl:text>.x, _</xsl:text>
    <xsl:value-of select="@endid"/>
    <xsl:text>.y</xsl:text>
    <xsl:choose>
      <xsl:when test="@place='below'">
        <xsl:text>-3</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>+3</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>) bulge </xsl:text>
    <xsl:if test="@place='below'">
      <xsl:text>-</xsl:text>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@bulge">
        <xsl:value-of select="@bulge"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>8</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="pedal">
    <xsl:value-of select="$indent"/>
    <xsl:text>pedal </xsl:text>
    <xsl:value-of select="@place"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="@staff"/>
    <xsl:text>: </xsl:text>
    <xsl:choose>
      <xsl:when test="@tstamp=0">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="round-half-to-even(@tstamp,3)"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="@dir='up'">
      <xsl:text>*</xsl:text>
    </xsl:if>
    <xsl:text>;</xsl:text>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="dynam">
    <xsl:if test="not(@source) or contains(string(@source),$source)">
      <xsl:value-of select="$indent"/>
      <xsl:text>boldital </xsl:text>
      <xsl:value-of select="@place"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@staff"/>

      <!-- Vertical offset -->
      <xsl:if test="@vo">
        <xsl:text> dist </xsl:text>
        <xsl:value-of select="@vo"/>
        <xsl:text>!</xsl:text>
      </xsl:if>

      <xsl:text>: </xsl:text>
      <xsl:choose>
        <xsl:when test="not(@tstamp)">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:when test="@tstamp=0">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="round-half-to-even(@tstamp,3)"/>
        </xsl:otherwise>
      </xsl:choose>

      <!-- Horizontal offset -->
      <xsl:if test="@ho">
        <xsl:text> [</xsl:text>
        <xsl:value-of select="@ho"/>
        <xsl:text>]</xsl:text>
      </xsl:if>
      <xsl:text> "</xsl:text>
      <xsl:variable name="content">
        <xsl:apply-templates/>
      </xsl:variable>
      <xsl:value-of select="normalize-space($content)"/>
      <xsl:text>";</xsl:text>
      <xsl:value-of select="$nl"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="hairpin">
    <xsl:if test="not(@source) or contains(string(@source),$source)">
      <xsl:value-of select="$indent"/>
      <xsl:choose>
        <xsl:when test="@form='cres'">
          <xsl:text>&lt; </xsl:text>
        </xsl:when>
        <xsl:when test="@form='dim'">
          <xsl:text>&gt; </xsl:text>
        </xsl:when>
      </xsl:choose>
      <xsl:value-of select="@place"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@staff"/>
      <xsl:text>: </xsl:text>
      <xsl:choose>
        <xsl:when test="@tstamp=0">
          <xsl:text>1</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="round-half-to-even(@tstamp,3)"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text> til </xsl:text>
      <xsl:choose>
        <xsl:when test="contains(@dur, '+')">
          <xsl:value-of select="substring-before(@dur, '+')"/>
          <xsl:text> + </xsl:text>
          <xsl:value-of
            select="round-half-to-even(number(substring-after(@dur,'+')),3)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="round-half-to-even(@dur,3)"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>;</xsl:text>
      <xsl:value-of select="$nl"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="dur2beat">
    <xsl:variable name="thisstaff">
      <xsl:value-of select="@staff"/>
    </xsl:variable>
    <xsl:variable name="ppq">
      <xsl:choose>
        <xsl:when test="preceding::staffdef[@n=$thisstaff][@midi.div]">
          <xsl:value-of
            select="preceding::staffdef[@n=$thisstaff][@midi.div][1]/@midi.div"
          />
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>96</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="meter.unit">
      <xsl:choose>
        <xsl:when test="preceding::*[@meter.unit]/@meter.unit">
          <xsl:value-of select="preceding::*[@meter.unit][1]/@meter.unit"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>4</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="dur">
      <xsl:value-of select="number(substring-after(@dur,'+'))"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$dur=0">
        <xsl:text>0</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="number($meter.unit) = 4">
            <xsl:value-of select="round-half-to-even($dur div $ppq, 3)"/>
          </xsl:when>
          <xsl:when test="number($meter.unit) != 4">
            <xsl:value-of
              select="round-half-to-even(($dur div $ppq) * ($meter.unit div 4), 3)"
            />
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="measure" mode="ending_start_next_measure">
    <xsl:if test="@xml:id=parent::ending/measure[1]/@xml:id">
      <xsl:text> ending</xsl:text>
      <xsl:text> "</xsl:text>
      <xsl:value-of select="parent::ending/@n"/>
      <xsl:text>"</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="pb">
    <xsl:if test="count(preceding::pb) != 0">
      <xsl:text>newpage //p. </xsl:text>
      <xsl:value-of select="count(preceding::pb) + 1"/>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="$nl"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="sb">
    <xsl:if test="name(preceding-sibling::*[1]) != 'pb'">
      <xsl:text>newscore</xsl:text>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="$nl"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="staff">
    <xsl:choose>
      <xsl:when test="layer">
        <xsl:apply-templates select="layer[not(@visible='no')]"/>
      </xsl:when>
      <xsl:when test="app">
        <xsl:apply-templates
          select="app|beam|chord|clefchange|ftrem|groupetto|halfmrpt|mrest|mrpt|mspace|note|pad|rest|space|tuplet"/>
        <xsl:value-of select="$nl"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$indent"/>
        <xsl:value-of select="@n"/>
        <xsl:text>: </xsl:text>
        <xsl:apply-templates
          select="beam|chord|clefchange|ftrem|groupetto|halfmrpt|mrest|mrpt|mspace|note|pad|rest|space|tuplet"/>
        <xsl:value-of select="$nl"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="choice">
    <xsl:apply-templates select="orig"/>
  </xsl:template>

  <xsl:template match="orig">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="subst">
    <xsl:apply-templates select="corr"/>
  </xsl:template>

  <xsl:template match="corr">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="ftrem">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="app">
    <xsl:apply-templates select="rdg[contains(string(@source),$source)]"/>
  </xsl:template>

  <xsl:template match="rdg">
    <xsl:choose>
      <xsl:when test="layer">
        <xsl:apply-templates select="layer[not(@visible='no')]"/>
      </xsl:when>
      <xsl:when test="app">
        <xsl:apply-templates select="app"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$indent"/>
        <xsl:value-of select="ancestor::staff/@n"/>
        <xsl:text>: </xsl:text>
        <xsl:apply-templates
          select="beam|chord|clefchange|ftrem|groupetto|halfmrpt|mrest|mrpt|mspace|note|pad|rest|space|tuplet"
        />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="layer">
    <xsl:value-of select="$indent"/>
    <xsl:value-of select="../@n"/>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="@n">
        <xsl:value-of select="@n"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="position()"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>: </xsl:text>
    <xsl:apply-templates
      select="beam|chord|clefchange|ftrem|groupetto|halfmrpt|mrest|mrpt|mspace|note|pad|rest|space|tuplet|choice|subst"/>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="beam">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="pad">
    <xsl:text>[pad </xsl:text>
    <xsl:value-of select="@num"/>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="tuplet">
    <xsl:text>{</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>}</xsl:text>
    <xsl:if test="@num.place">
      <xsl:text> </xsl:text>
      <xsl:value-of select="@num.place"/>
    </xsl:if>
    <xsl:if test="@num.format='count'">
      <xsl:text> </xsl:text>
      <xsl:choose>
        <xsl:when test="@num">
          <xsl:value-of select="@num"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="count(note[not(@grace)])"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="@num.visible='no'">
      <xsl:text>n</xsl:text>
    </xsl:if>
    <xsl:text>;</xsl:text>
  </xsl:template>

  <xsl:template match="chord">
    <xsl:call-template name="tupletstart"/>
    <xsl:call-template name="artic"/>
    <xsl:call-template name="chord_style"/>
    <xsl:choose>
      <xsl:when test="@dur='breve'">
        <xsl:text>1/2</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@dur"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="makedots"/>

    <xsl:apply-templates
      select="note[not(@staff)] | note[@staff=ancestor::staff/@n]"/>
    <xsl:if test="note[@staff != ancestor::staff/@n]">
      <xsl:text> with </xsl:text>
      <xsl:apply-templates select="note[@staff != ancestor::staff/@n]"/>
      <xsl:choose>
        <xsl:when
          test="note[@staff != ancestor::staff/@n][1] &gt; ancestor::staff/@n">
          <xsl:text> above</xsl:text>
        </xsl:when>
        <xsl:when
          test="note[@staff != ancestor::staff/@n][1] &lt; ancestor::staff/@n">
          <xsl:text> below</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:if>

    <!-- inter-chord attributes -->
    <xsl:variable name="interchord">
      <xsl:if test="@tie='i' or @tie='m'">
        <xsl:if test="@tie.rend">
          <xsl:value-of select="@tie.rend"/>
        </xsl:if>
        <xsl:text> tie</xsl:text>
        <xsl:if test="@tie.dir">
          <xsl:text> </xsl:text>
          <xsl:value-of select="@tie.dir"/>
        </xsl:if>
        <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:call-template name="ftrem"/>
      <xsl:call-template name="beaming"/>
    </xsl:variable>
    <xsl:if test="replace($interchord, ', $', '') != ''">
      <xsl:value-of select="replace(replace($interchord, ', $', ''),'[ ]+',' ')"
      />
    </xsl:if>
    <xsl:text>; </xsl:text>
    <xsl:call-template name="tupletend"/>
  </xsl:template>

  <xsl:template match="note">
    <xsl:call-template name="tupletstart"/>
    <xsl:call-template name="artic"/>
    <xsl:call-template name="note_style"/>
    <xsl:choose>
      <xsl:when test="@dur">
        <xsl:choose>
          <xsl:when test="@dur='breve'">
            <xsl:text>1/2</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@dur"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="@dur.ges">
        <xsl:call-template name="quantization"/>
      </xsl:when>
      <xsl:when test="parent::chord">
        <!-- Do nothing.  Duration handled in chord template. -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="preceding::note[@dur][1]/@dur"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="makedots"/>

    <xsl:choose>
      <xsl:when test="@tab.string and @tab.fret">
        <xsl:variable name="stringcount">
          <xsl:value-of
            select="count(tokenize(preceding::staffdef[@tab.strings][1]/@tab.strings,' '))"
          />
        </xsl:variable>
        <!-- <xsl:value-of select="@tab.string"/> -->
        <xsl:variable name="stringnum">
          <xsl:value-of select="@tab.string"/>
        </xsl:variable>
        <xsl:variable name="stringname">
          <xsl:value-of
            select="for $token in ($stringnum to $stringnum) return
           tokenize(preceding::staffdef[@tab.strings][1]/@tab.strings, ' ')[$token]"
          />
        </xsl:variable>
        <xsl:variable name="stringname2">
          <xsl:value-of select="replace($stringname,'[0-9]','')"/>
        </xsl:variable>
        <xsl:value-of
          select="replace($stringname2,&quot;_&quot;,&quot;&apos;&quot;)"/>
        <xsl:value-of select="@tab.fret"/>
      </xsl:when>
      <xsl:when test="@pname">
        <xsl:value-of select="@pname"/>
      </xsl:when>
      <xsl:when test="@pname.ges">
        <xsl:value-of select="@pname.ges"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="preceding::note[@pname][1]/@pname"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
      <xsl:when test="@accid">
        <xsl:value-of
          select="replace(replace(@accid,'f','&#x0026;'),'s','#')"/>
      </xsl:when>
      <xsl:when test="@accid.editorial and not(@accid)">
        <xsl:if test="@accid.enclose">
          <xsl:text>(</xsl:text>
        </xsl:if>
        <xsl:value-of
          select="replace(replace(@accid.editorial,'f','&#x0026;'),'s','#')"/>
        <xsl:if test="@accid.enclose">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:when>
      <xsl:when test="accid">
        <xsl:if test="accid/@enclose">
          <xsl:text>(</xsl:text>
        </xsl:if>
        <xsl:value-of
          select="replace(replace(accid/@value,'f','&#x0026;'),'s','#')"/>
        <xsl:if test="accid/@enclose">
          <xsl:text>)</xsl:text>
        </xsl:if>
      </xsl:when>
    </xsl:choose>

    <xsl:choose>
      <xsl:when test="@tab.string and @tab.fret">
        <!-- Do nothing! -->
      </xsl:when>
      <xsl:when test="@oct">
        <xsl:value-of select="@oct"/>
      </xsl:when>
      <xsl:when test="@oct.ges">
        <xsl:value-of select="@oct.ges"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="preceding::note[@oct][1]/@oct"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="@size='cue'">
      <xsl:if test="not(../@size='cue')">
        <xsl:text>?</xsl:text>
      </xsl:if>
    </xsl:if>

    <xsl:if test="@tie='i' or @tie='m'">
      <xsl:text>~</xsl:text>
      <xsl:if test="@tie.dir">
        <xsl:text> </xsl:text>
        <xsl:value-of select="@tie.dir"/>
      </xsl:if>
    </xsl:if>

    <xsl:variable name="thisid">
      <xsl:value-of select="@xml:id"/>
    </xsl:variable>
    <xsl:if
      test="following::*[@startid=$thisid or @endid=$thisid] or preceding::*[@startid=$thisid or @endid=$thisid]">
      <xsl:text> =_</xsl:text>
      <xsl:value-of select="@xml:id"/>
      <xsl:text> </xsl:text>
    </xsl:if>

    <!-- <xsl:if test="@grace">
      <xsl:variable name="id">
        <xsl:value-of select="@xml:id"/>
      </xsl:variable>
      <xsl:variable name="idnext">
        <xsl:value-of select="following::note[1]/@xml:id"/>
      </xsl:variable>
      <xsl:if test="following::slur[@startid=$id and @endid=$idnext]">
        <xsl:variable name="direction">
          <xsl:value-of
            select="following::slur[@startid=$id and @endid=$idnext]/@place"/>
        </xsl:variable>
        <xsl:text>&lt;</xsl:text>
        <xsl:value-of select="following::note[1]/@pname"/>
        <xsl:value-of select="following::note[1]/@oct"/>
        <xsl:text>&gt;</xsl:text>
        <xsl:choose>
          <xsl:when test="$direction='above'">
            <xsl:text>up</xsl:text>
          </xsl:when>
          <xsl:when test="$direction='below'">
            <xsl:text>down</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
    </xsl:if> -->
    <xsl:call-template name="ftrem"/>
    <xsl:if test="@coloration='inverse'">
      <xsl:call-template name="coloration">
        <xsl:with-param name="dur">
          <xsl:choose>
            <xsl:when test="@dur">
              <xsl:value-of select="@dur"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="ancestor::*[@dur][1]/@dur"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    <xsl:if test="not(name(..)='chord')">
      <xsl:call-template name="beaming"/>
    </xsl:if>
    <xsl:if test="not(name(..)='chord')">
      <xsl:text>;</xsl:text>
    </xsl:if>
    <xsl:call-template name="tupletend"/>
  </xsl:template>

  <xsl:template name="coloration">
    <xsl:param name="dur"/>
    <xsl:choose>
      <xsl:when test="$dur='2' or $dur='1'">
        <xsl:text> hs "mei:blk" </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text> hs "mei:wht" </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="ftrem">
    <xsl:if test="parent::ftrem">
      <xsl:if test="position()=1 and not(@grace)">
        <xsl:text> alt </xsl:text>
        <xsl:value-of select="parent::ftrem/@slash"/>
        <!-- <xsl:call-template name="makedots"/> -->
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="tupletstart">
    <xsl:if test="starts-with(@tuplet, 'i') and not(ancestor::tuplet)">
      <xsl:text>{</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="tupletend">
    <xsl:if test="starts-with(@tuplet, 't') and not(ancestor::tuplet)">
      <xsl:text>}</xsl:text>
      <xsl:variable name="id">
        <xsl:value-of select="@xml:id"/>
      </xsl:variable>
      <xsl:if test="following::tupletspan[@endid=$id]/@num.place">
        <xsl:text> </xsl:text>
        <xsl:value-of select="following::tupletspan[@endid=$id]/@num.place"/>
      </xsl:if>
      <xsl:if test="following::tupletspan[@endid=$id]/@num">
        <xsl:text> </xsl:text>
        <xsl:value-of select="following::tupletspan[@endid=$id]/@num"/>
        <xsl:choose>
          <xsl:when
            test="following::tupletspan[@endid=$id]/@num.visible!='false'">
            <xsl:if
              test="following::tupletspan[@endid=$id]/@bracket.visible!='true'">
              <xsl:text>num</xsl:text>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>n</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="following::tupletspan[@endid=$id]/@dur">
          <xsl:choose>
            <xsl:when test="following::tupletspan[@endid=$id]/@dots">
              <xsl:text> </xsl:text>
              <xsl:value-of select="following::tupletspan[@endid=$id]/@dur"/>
              <xsl:call-template name="makedots"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>,</xsl:text>
              <xsl:value-of
                select="replace(normalize-space(following::tupletspan[@endid=$id]/@dur), ' ','+')"
              />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:if>
      <xsl:text>; </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="tupletendlyrics">
    <xsl:if test="starts-with(@tuplet, 't')">
      <xsl:text>}</xsl:text>
      <xsl:variable name="id">
        <xsl:value-of select="@xml:id"/>
      </xsl:variable>
      <xsl:if test="following::tupletspan[@endid=$id]/@num">
        <xsl:text> </xsl:text>
        <xsl:value-of
          select="substring-before(following::tupletspan[@endid=$id]/@num,':')"
        />
      </xsl:if>
      <xsl:if test="following::tupletspan[@endid=$id]/@num.visible='no'">
        <xsl:text>n</xsl:text>
      </xsl:if>
      <xsl:text>; </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="chord_style">
    <xsl:variable name="chord_style">
      <xsl:if test="@grace">
        <xsl:text>grace;</xsl:text>
      </xsl:if>
      <xsl:if test="@size='cue'">
        <xsl:text>cue;</xsl:text>
      </xsl:if>
      <xsl:if test="contains(@stem.mod,'slash')">
        <xsl:text>slash </xsl:text>
        <xsl:value-of select="substring-before(@stem.mod,'slash')"/>
        <xsl:text>;</xsl:text>
      </xsl:if>
      <xsl:if test="@stem.dir">
        <xsl:if test="not(@grace)">
          <xsl:value-of select="@stem.dir"/>
          <xsl:text>;</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="@coloration='inverse'">
        <xsl:call-template name="coloration">
          <xsl:with-param name="dur">
            <xsl:choose>
              <xsl:when test="@dur">
                <xsl:value-of select="@dur"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="ancestor::*[@dur][1]/@dur"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:text>;</xsl:text>
      </xsl:if>
      <xsl:if test="@stem.len=0">
        <xsl:text>len 0</xsl:text>
      </xsl:if>

      <!-- non-zero stem lengths have to be converted to mup units -->
      <!-- <xsl:if test="@stem.len>0">
        <xsl:text>len X</xsl:text>
        </xsl:if> -->

    </xsl:variable>
    <xsl:if test="$chord_style != ''">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="replace($chord_style, ';$', '')"/>
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="note_style">
    <xsl:variable name="note_style">
      <xsl:if test="@grace">
        <xsl:text>grace;</xsl:text>
      </xsl:if>
      <!-- <xsl:if test="@size='cue'">
        <xsl:text>cue;</xsl:text>
        </xsl:if> -->
      <xsl:if test="@ho">
        <xsl:text>ho </xsl:text>
        <xsl:value-of select="@ho"/>
        <xsl:text>;</xsl:text>
      </xsl:if>
      <xsl:if test="contains(@stem.mod,'slash')">
        <xsl:text>slash </xsl:text>
        <xsl:value-of select="substring-before(@stem.mod,'slash')"/>
        <xsl:text>;</xsl:text>
      </xsl:if>
      <xsl:if test="@stem.dir">
        <xsl:if test="not(@grace)">
          <xsl:value-of select="@stem.dir"/>
          <xsl:text>;</xsl:text>
        </xsl:if>
      </xsl:if>
      <xsl:if test="@stem.len=0">
        <xsl:text>len 0;</xsl:text>
      </xsl:if>
      <!-- non-zero stem lengths have to be converted to mup units -->
      <!-- <xsl:if test="@stem.len>0">
        <xsl:text>len X</xsl:text>
      </xsl:if> -->
    </xsl:variable>
    <xsl:if test="$note_style != ''">
      <xsl:text>[</xsl:text>
      <xsl:value-of select="replace($note_style, ';$', '')"/>
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="artic">
    <xsl:variable name="artics">
      <xsl:choose>
        <xsl:when test="@artic='acc'">
          <xsl:text>&gt;,</xsl:text>
        </xsl:when>
        <xsl:when test="@artic='stacc'">
          <xsl:text>.,</xsl:text>
        </xsl:when>
        <xsl:when test="@artic='ten'">
          <xsl:text>-,</xsl:text>
        </xsl:when>
        <xsl:when test="@artic='stacciss'">
          <xsl:text>"\(wedge)",</xsl:text>
        </xsl:when>
        <xsl:when test="@artic='marc'">
          <xsl:text>^,</xsl:text>
        </xsl:when>
        <xsl:when test="@artic='marc-stacc'">
          <xsl:text>.,^,</xsl:text>
        </xsl:when>
        <xsl:when test="@artic='loure'">
          <xsl:text>-,</xsl:text>
        </xsl:when>
        <xsl:when test="@artic='spicc'">
          <xsl:text>.,</xsl:text>
        </xsl:when>
        <xsl:when test="@artic='dnbow'">
          <xsl:text>"\(dnbow)",</xsl:text>
        </xsl:when>
        <xsl:when test="@artic='upbow'">
          <xsl:text>"\(upbow)",</xsl:text>
        </xsl:when>
        <xsl:when test="@artic='harm'">
          <xsl:text>"\(dim)",</xsl:text>
        </xsl:when>
        <xsl:when test="@artic='open'">
          <xsl:text>"o",</xsl:text>
        </xsl:when>
        <xsl:when test="@artic='stop'">
          <xsl:text>"+",</xsl:text>
        </xsl:when>
        <xsl:when test="@artic='dbltongue'">
          <xsl:text>"..",</xsl:text>
        </xsl:when>
        <xsl:when test="@artic='trpltongue'">
          <xsl:text>"...",</xsl:text>
        </xsl:when>
        <xsl:when test="@artic='heel'">
          <xsl:text>"\s(-3)\f(HB)U",</xsl:text>
        </xsl:when>
        <xsl:when test="@artic='toe'">
          <xsl:text>"\(acc_hat)",</xsl:text>
        </xsl:when>
      </xsl:choose>
      <xsl:for-each
        select="artic[not(@source) or contains(string(@source),$source)]">
        <xsl:choose>
          <xsl:when test="@value='acc'">
            <xsl:text>&gt;,</xsl:text>
          </xsl:when>
          <xsl:when test="@value='stacc'">
            <xsl:text>.,</xsl:text>
          </xsl:when>
          <xsl:when test="@value='ten'">
            <xsl:text>-,</xsl:text>
          </xsl:when>
          <xsl:when test="@value='stacciss'">
            <xsl:text>"\(wedge)",</xsl:text>
          </xsl:when>
          <xsl:when test="@value='marc'">
            <xsl:text>^,</xsl:text>
          </xsl:when>
          <xsl:when test="@value='marc-stacc'">
            <xsl:text>.,^,</xsl:text>
          </xsl:when>
          <xsl:when test="@value='loure'">
            <xsl:text>-,</xsl:text>
          </xsl:when>
          <xsl:when test="@value='spicc'">
            <xsl:text>.,</xsl:text>
          </xsl:when>
          <xsl:when test="@value='dnbow'">
            <xsl:text>"\(dnbow)",</xsl:text>
          </xsl:when>
          <xsl:when test="@value='upbow'">
            <xsl:text>"\(upbow)",</xsl:text>
          </xsl:when>
          <xsl:when test="@value='harm'">
            <xsl:text>"\(dim)",</xsl:text>
          </xsl:when>
          <xsl:when test="@value='open'">
            <xsl:text>"o",</xsl:text>
          </xsl:when>
          <xsl:when test="@value='stop'">
            <xsl:text>"+",</xsl:text>
          </xsl:when>
          <xsl:when test="@value='dbltongue'">
            <xsl:text>"..",</xsl:text>
          </xsl:when>
          <xsl:when test="@value='trpltongue'">
            <xsl:text>"...",</xsl:text>
          </xsl:when>
          <xsl:when test="@value='heel'">
            <xsl:text>"\s(-3)\f(HB)U",</xsl:text>
          </xsl:when>
          <xsl:when test="@value='toe'">
            <xsl:text>"\(acc_hat)",</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="$artics != ''">
      <xsl:text>[with </xsl:text>
      <xsl:value-of select="replace($artics, ',$', '')"/>
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mrest">
    <xsl:text>mr;</xsl:text>
  </xsl:template>

  <xsl:template match="mrpt">
    <xsl:text>mrpt;</xsl:text>
  </xsl:template>

  <xsl:template match="mspace">
    <xsl:text>ms;</xsl:text>
  </xsl:template>

  <xsl:template match="halfmrpt">
    <xsl:choose>
      <xsl:when test="@expand='yes'">
        <xsl:choose>
          <xsl:when test="child::*">
            <xsl:apply-templates/>
          </xsl:when>
          <xsl:when test="preceding-sibling::*">
            <xsl:apply-templates select="preceding-sibling::*"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="thisstaff">
              <xsl:value-of select="ancestor::staff/@n"/>
            </xsl:variable>
            <xsl:apply-templates
              select="ancestor::measure/preceding::measure[staff[@n=$thisstaff and
                                 child::*[not(name()='halfmrpt')]]][1]/
                                 staff[@n=$thisstaff]/*[not(name()='halfmrpt')]"
            />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="id">
          <xsl:choose>
            <xsl:when test="@xml:id">
              <xsl:value-of select="@xml:id"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="generate-id()"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:text>[=_</xsl:text>
        <xsl:value-of select="$id"/>
        <xsl:text>]</xsl:text>
        <xsl:choose>
          <xsl:when test="@dur">
            <xsl:choose>
              <xsl:when test="@dur='breve'">
                <xsl:text>1/2</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@dur"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="unit">
              <xsl:value-of
                select="preceding::scoredef[@meter.unit][1]/@meter.unit"/>
            </xsl:variable>
            <xsl:variable name="count">
              <xsl:value-of
                select="preceding::scoredef[@meter.count][1]/@meter.count div 2"
              />
            </xsl:variable>
            <xsl:value-of select="($count * 4) div $unit"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>s;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="halfmrpt" mode="draw">
    <xsl:if test="not(@expand='yes')">
      <xsl:value-of select="$indent"/>
      <xsl:variable name="id">
        <xsl:choose>
          <xsl:when test="@xml:id">
            <xsl:value-of select="@xml:id"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="generate-id()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:text>print (_</xsl:text>
      <xsl:value-of select="$id"/>
      <xsl:text>.x, _</xsl:text>
      <xsl:value-of select="$id"/>
      <xsl:text>.y) "\(measrpt)"</xsl:text>
      <xsl:value-of select="$nl"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="rest">
    <xsl:call-template name="tupletstart"/>
    <xsl:call-template name="rest_style"/>
    <xsl:choose>
      <xsl:when test="@dur">
        <xsl:choose>
          <xsl:when test="@dur='breve'">
            <xsl:text>1/2</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@dur"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="makedots"/>
      </xsl:when>
      <xsl:when test="@dur.ges">
        <xsl:call-template name="quantization"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of
          select="preceding::*[name()='note' or name()='rest' or name()='chord' and @dur][1]/@dur"
        />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>r</xsl:text>
    <xsl:call-template name="beaming"/>
    <xsl:text>; </xsl:text>
    <xsl:call-template name="tupletend"/>
  </xsl:template>

  <xsl:template name="rest_style">
    <xsl:if test="@vo">
      <xsl:text>[dist </xsl:text>
      <xsl:value-of select="@vo"/>
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="space">
    <xsl:call-template name="tupletstart"/>
    <xsl:choose>
      <xsl:when test="@dur">
        <xsl:choose>
          <xsl:when test="@dur='breve'">
            <xsl:text>1/2</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@dur"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="makedots"/>
      </xsl:when>
      <xsl:when test="@dur.ges">
        <xsl:call-template name="quantization"/>
      </xsl:when>
    </xsl:choose>
    <xsl:text>s</xsl:text>
    <xsl:call-template name="beaming"/>
    <xsl:text>; </xsl:text>
    <xsl:call-template name="tupletend"/>
  </xsl:template>

  <xsl:template name="quantization">
    <xsl:variable name="thisstaff">
      <xsl:value-of select="ancestor::staff[1]/@n"/>
    </xsl:variable>
    <xsl:variable name="ppq">
      <xsl:choose>
        <xsl:when test="preceding::staffdef[@n=$thisstaff][@midi.div]">
          <xsl:value-of
            select="preceding::staffdef[@n=$thisstaff][@midi.div][1]/@midi.div"
          />
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>96</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- Build lookup table -->
    <xsl:variable name="clicks4">
      <xsl:value-of select="$ppq"/>
    </xsl:variable>
    <xsl:variable name="clicks1">
      <xsl:value-of select="$clicks4 * 4"/>
    </xsl:variable>
    <xsl:variable name="clicks2">
      <xsl:value-of select="$clicks4 * 2"/>
    </xsl:variable>
    <xsl:variable name="clicks8">
      <xsl:value-of select="$clicks4 div 2"/>
    </xsl:variable>
    <xsl:variable name="clicks16">
      <xsl:value-of select="$clicks4 div 4"/>
    </xsl:variable>
    <xsl:variable name="clicks32">
      <xsl:value-of select="$clicks4 div 8"/>
    </xsl:variable>
    <xsl:variable name="clicks64">
      <xsl:value-of select="$clicks4 div 16"/>
    </xsl:variable>
    <xsl:variable name="clicks128">
      <xsl:value-of select="$clicks4 div 32"/>
    </xsl:variable>
    <xsl:variable name="clicks256">
      <xsl:value-of select="$clicks4 div 64"/>
    </xsl:variable>
    <xsl:variable name="clicks512">
      <xsl:value-of select="$clicks4 div 128"/>
    </xsl:variable>
    <xsl:variable name="clicks1024">
      <xsl:value-of select="$clicks4 div 256"/>
    </xsl:variable>

    <!-- dotted values -->
    <xsl:variable name="clicks1dot">
      <xsl:value-of select="$clicks1 + $clicks1 div 2"/>
    </xsl:variable>
    <xsl:variable name="clicks2dot">
      <xsl:value-of select="$clicks2 + $clicks2 div 2"/>
    </xsl:variable>
    <xsl:variable name="clicks4dot">
      <xsl:value-of select="$clicks4 + $clicks4 div 2"/>
    </xsl:variable>
    <xsl:variable name="clicks8dot">
      <xsl:value-of select="$clicks8 + $clicks8 div 2"/>
    </xsl:variable>
    <xsl:variable name="clicks16dot">
      <xsl:value-of select="$clicks16 + $clicks16 div 2"/>
    </xsl:variable>
    <xsl:variable name="clicks32dot">
      <xsl:value-of select="$clicks32 + $clicks32 div 2"/>
    </xsl:variable>
    <xsl:variable name="clicks64dot">
      <xsl:value-of select="$clicks64 + $clicks64 div 2"/>
    </xsl:variable>
    <xsl:variable name="clicks128dot">
      <xsl:value-of select="$clicks128 + $clicks128 div 2"/>
    </xsl:variable>
    <xsl:variable name="clicks256dot">
      <xsl:value-of select="$clicks256 + $clicks256 div 2"/>
    </xsl:variable>
    <xsl:variable name="clicks512dot">
      <xsl:value-of select="$clicks512 + $clicks512 div 2"/>
    </xsl:variable>

    <!-- double dotted values -->
    <xsl:variable name="clicks1dot2">
      <xsl:value-of select="$clicks1 + ($clicks1 div 2) + ($clicks1 div 4)"/>
    </xsl:variable>
    <xsl:variable name="clicks2dot2">
      <xsl:value-of select="$clicks2 + ($clicks2 div 2) + ($clicks2 div 4)"/>
    </xsl:variable>
    <xsl:variable name="clicks4dot2">
      <xsl:value-of select="$clicks4 + ($clicks4 div 2) + ($clicks4 div 4)"/>
    </xsl:variable>
    <xsl:variable name="clicks8dot2">
      <xsl:value-of select="$clicks8 + ($clicks8 div 2) + ($clicks8 div 4)"/>
    </xsl:variable>
    <xsl:variable name="clicks16dot2">
      <xsl:value-of select="$clicks16 + ($clicks16 div 2) + ($clicks16 div 4)"/>
    </xsl:variable>
    <xsl:variable name="clicks32dot2">
      <xsl:value-of select="$clicks32 + ($clicks32 div 2) + ($clicks32 div 4)"/>
    </xsl:variable>
    <xsl:variable name="clicks64dot2">
      <xsl:value-of select="$clicks64 + ($clicks64 div 2) + ($clicks32 div 4)"/>
    </xsl:variable>
    <xsl:variable name="clicks128dot2">
      <xsl:value-of
        select="$clicks128 + ($clicks128 div 2) + ($clicks128 div 4)"/>
    </xsl:variable>
    <xsl:variable name="clicks256dot2">
      <xsl:value-of
        select="$clicks256 + ($clicks256 div 2) + ($clicks256 div 4)"/>
    </xsl:variable>

    <!-- triplet values -->
    <xsl:variable name="clicks3">
      <xsl:value-of select="$clicks1 div 3"/>
    </xsl:variable>
    <xsl:variable name="clicks6">
      <xsl:value-of select="$clicks2 div 3"/>
    </xsl:variable>
    <xsl:variable name="clicks12">
      <xsl:value-of select="$clicks4 div 3"/>
    </xsl:variable>
    <xsl:variable name="clicks24">
      <xsl:value-of select="$clicks8 div 3"/>
    </xsl:variable>
    <xsl:variable name="clicks48">
      <xsl:value-of select="$clicks16 div 3"/>
    </xsl:variable>
    <xsl:variable name="clicks96">
      <xsl:value-of select="$clicks32 div 3"/>
    </xsl:variable>
    <xsl:variable name="clicks192">
      <xsl:value-of select="$clicks64 div 3"/>
    </xsl:variable>
    <xsl:variable name="clicks384">
      <xsl:value-of select="$clicks128 div 3"/>
    </xsl:variable>
    <xsl:variable name="clicks768">
      <xsl:value-of select="$clicks256 div 3"/>
    </xsl:variable>

    <xsl:choose>
      <!-- Undotted note values -->
      <xsl:when test="@dur.ges = $clicks1">1</xsl:when>
      <xsl:when test="@dur.ges = $clicks2">2</xsl:when>
      <xsl:when test="@dur.ges = $clicks4">4</xsl:when>
      <xsl:when test="@dur.ges = $clicks8">8</xsl:when>
      <xsl:when test="@dur.ges = $clicks16">16</xsl:when>
      <xsl:when test="@dur.ges = $clicks32">32</xsl:when>
      <xsl:when test="@dur.ges = $clicks64">64</xsl:when>
      <xsl:when test="@dur.ges = $clicks128">128</xsl:when>
      <xsl:when test="@dur.ges = $clicks256">256</xsl:when>

      <!-- Dotted note values -->
      <xsl:when test="@dur.ges = $clicks1dot">1.</xsl:when>
      <xsl:when test="@dur.ges = $clicks2dot">2.</xsl:when>
      <xsl:when test="@dur.ges = $clicks4dot">4.</xsl:when>
      <xsl:when test="@dur.ges = $clicks8dot">8.</xsl:when>
      <xsl:when test="@dur.ges = $clicks16dot">16.</xsl:when>
      <xsl:when test="@dur.ges = $clicks32dot">32.</xsl:when>
      <xsl:when test="@dur.ges = $clicks64dot">64.</xsl:when>
      <xsl:when test="@dur.ges = $clicks128dot">128.</xsl:when>
      <xsl:when test="@dur.ges = $clicks256dot">256.</xsl:when>
      <xsl:when test="@dur.ges = $clicks512dot">512.</xsl:when>

      <!-- Double dotted note values -->
      <xsl:when test="@dur.ges = $clicks1dot2">1..</xsl:when>
      <xsl:when test="@dur.ges = $clicks2dot2">2..</xsl:when>
      <xsl:when test="@dur.ges = $clicks4dot2">4..</xsl:when>
      <xsl:when test="@dur.ges = $clicks8dot2">8..</xsl:when>
      <xsl:when test="@dur.ges = $clicks16dot2">16..</xsl:when>
      <xsl:when test="@dur.ges = $clicks32dot2">32..</xsl:when>
      <xsl:when test="@dur.ges = $clicks64dot2">64..</xsl:when>
      <xsl:when test="@dur.ges = $clicks128dot2">128..</xsl:when>
      <xsl:when test="@dur.ges = $clicks256dot2">256..</xsl:when>

      <!-- Quantize triplets to next smaller undotted value. -->
      <xsl:when test="@dur.ges = $clicks3">
        <xsl:value-of select="$clicks2"/>
      </xsl:when>
      <xsl:when test="@dur.ges = $clicks6">
        <xsl:value-of select="$clicks4"/>
      </xsl:when>
      <xsl:when test="@dur.ges = $clicks12">
        <xsl:value-of select="$clicks8"/>
      </xsl:when>
      <xsl:when test="@dur.ges = $clicks24">
        <xsl:value-of select="$clicks16"/>
      </xsl:when>
      <xsl:when test="@dur.ges = $clicks48">
        <xsl:value-of select="$clicks32"/>
      </xsl:when>
      <xsl:when test="@dur.ges = $clicks96">
        <xsl:value-of select="$clicks64"/>
      </xsl:when>
      <xsl:when test="@dur.ges = $clicks192">
        <xsl:value-of select="$clicks128"/>
      </xsl:when>

      <!-- If nothing else has matched so far, quantize to the next smaller undotted value. -->
      <xsl:when test="@dur.ges > number($clicks1)">1</xsl:when>
      <xsl:when
        test="@dur.ges > number($clicks2) and @dur.ges &lt; number($clicks1)"
        >2</xsl:when>
      <xsl:when
        test="@dur.ges > number($clicks4) and @dur.ges &lt; number($clicks2)"
        >4</xsl:when>
      <xsl:when
        test="@dur.ges > number($clicks8) and @dur.ges &lt; number($clicks4)"
        >8</xsl:when>
      <xsl:when
        test="@dur.ges > number($clicks16) and @dur.ges &lt; number($clicks8)"
        >16</xsl:when>
      <xsl:when
        test="@dur.ges > number($clicks32) and @dur.ges &lt; number($clicks16)"
        >32</xsl:when>
      <xsl:when
        test="@dur.ges > number($clicks64) and @dur.ges &lt; number($clicks32)"
        >64</xsl:when>
      <xsl:when
        test="@dur.ges > number($clicks128) and @dur.ges &lt; number($clicks64)"
        >128</xsl:when>
      <xsl:when
        test="@dur.ges > number($clicks256) and @dur.ges &lt; number($clicks128)"
        >256</xsl:when>
      <xsl:when
        test="@dur.ges > number($clicks512) and @dur.ges &lt; number($clicks256)"
        >512</xsl:when>
      <xsl:when
        test="@dur.ges > number($clicks1024) and @dur.ges &lt; number($clicks512)"
        >256</xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="clefchange">
    <xsl:text>&lt;&lt;staff </xsl:text>
    <xsl:if test="@line or @shape">
      <xsl:text>clef=</xsl:text>
      <xsl:choose>
        <!-- add other clefs here later! -->
        <xsl:when test="@shape='G' and @line='2'">
          <xsl:text>treble</xsl:text>
        </xsl:when>
        <xsl:when test="@shape='C' and @line='3'">
          <xsl:text>alto</xsl:text>
        </xsl:when>
        <xsl:when test="@shape='C' and @line='4'">
          <xsl:text>tenor</xsl:text>
        </xsl:when>
        <xsl:when test="@shape='F' and @line='4'">
          <xsl:text>bass</xsl:text>
        </xsl:when>
      </xsl:choose>
      <xsl:text>&gt;&gt; </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="makedots">
    <xsl:choose>
      <xsl:when test="@dots=1">
        <xsl:text>.</xsl:text>
      </xsl:when>
      <xsl:when test="@dots=2">
        <xsl:text>..</xsl:text>
      </xsl:when>
      <xsl:when test="@dots=3">
        <xsl:text>...</xsl:text>
      </xsl:when>
      <xsl:when test="@dots=4">
        <xsl:text>....</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="beaming">
    <xsl:if test="parent::beam or ancestor::beam">
      <xsl:choose>
        <xsl:when test="position()=1 and not(@grace)">
          <xsl:text> bm</xsl:text>
          <xsl:if test="parent::beam/@with">
            <xsl:text> with staff </xsl:text>
            <xsl:value-of select="parent::beam/@with"/>
          </xsl:if>
        </xsl:when>
        <xsl:when test="@breaksec">
          <xsl:text> esbm</xsl:text>
        </xsl:when>
        <xsl:when test="position()=last() and not(@grace)">
          <xsl:text> ebm</xsl:text>
        </xsl:when>
      </xsl:choose>
      <!-- <xsl:if test="position()=1 and not(@grace)">
        <xsl:text> bm</xsl:text>
        <xsl:if test="parent::beam/@with">
          <xsl:text> with staff </xsl:text>
          <xsl:value-of select="parent::beam/@with"/>
        </xsl:if>
      </xsl:if>
      <xsl:if test="position()=last() and not(@grace)">
        <xsl:text> ebm</xsl:text>
      </xsl:if> -->
    </xsl:if>
  </xsl:template>

  <!-- Text nodes are space-normalized. -->
  <xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

  <xsl:template match="div">
    <xsl:value-of select="$nl"/>
    <xsl:text>block</xsl:text>
    <xsl:value-of select="$nl"/>
    <xsl:text>paragraph "</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$nl"/>
    <xsl:value-of select="$nl"/>
    <xsl:if test="preceding::measure">
      <xsl:text>music</xsl:text>
      <xsl:value-of select="$nl"/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
