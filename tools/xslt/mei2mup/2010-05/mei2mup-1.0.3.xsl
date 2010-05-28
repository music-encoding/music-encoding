<?xml version="1.0" encoding="UTF-8"?>

<!-- ************************************************************** -->
<!--
  NAME:     2mup.xsl (version 1.0.3)

  NOTICE:   Copyright (c) 2010 by the Music Encoding Initiative (MEI)
            Council.
  
            Licensed under the Educational Community License, Version
            2.0 (the "License"); you may not use this file except in
            compliance with the License. You may obtain a copy of the
            License at http://www.osedu.org/licenses/ECL-2.0.
            
            Unless required by applicable law or agreed to in writing,
            software distributed under the License is distributed on
            an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
            KIND, either express or implied. See the License for the
            specific language governing permissions and limitations
            under the License.
            
            This is a derivative work based on earlier versions of the
            schema copyright (c) 2001-2006 Perry Roland and the Rector
            and Visitors of the University of Virginia; licensed under
            the Educational Community License version 1.0.
  
  CONTACT:  contact@music-encoding.org 
-->

<!DOCTYPE xsl:stylesheet [
]>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:mei="http://www.music-encoding.org/ns/mei"
  xmlns:saxon="http://saxon.sf.net/" exclude-result-prefixes="saxon">

  <xsl:strip-space elements="*"/>
  <xsl:variable name="progname">
    <xsl:text>mei2mup.xsl</xsl:text>
  </xsl:variable>
  <xsl:variable name="progversion">
    <xsl:text>v. 1.0.3</xsl:text>
  </xsl:variable>
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
  <xsl:template match="mei:meihead">
    <xsl:for-each select="mei:filedesc/mei:titlestmt[descendant::text()]">
      <xsl:text>// </xsl:text>
      <xsl:for-each select="mei:title">
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:if test="position() !=last()">
          <xsl:text>, </xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:value-of select="$nl"/>
      <xsl:for-each select="mei:respstmt[descendant::text()]">
        <xsl:text>// </xsl:text>
        <xsl:for-each select="*">
          <xsl:value-of select="normalize-space(.)"/>
          <xsl:if test="position()!=last()">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:value-of select="$nl"/>
      </xsl:for-each>
    </xsl:for-each>

    <xsl:for-each select="mei:filedesc/mei:pubstmt[descendant::text()]">
      <xsl:for-each select="*">
        <xsl:text>// </xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:value-of select="$nl"/>
      </xsl:for-each>
    </xsl:for-each>

    <xsl:for-each select="mei:filedesc/mei:sourcedesc[descendant::text()]">
      <xsl:value-of select="$nl"/>
      <xsl:for-each select="mei:source">
        <xsl:text>// Source </xsl:text>
        <xsl:value-of select="position()"/>
        <xsl:text>: </xsl:text>
        <xsl:for-each select="mei:titlestmt">
          <xsl:for-each select="mei:title">
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:if test="position() !=last()">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:for-each>
          <xsl:value-of select="$nl"/>
          <xsl:for-each select="mei:respstmt">
            <xsl:text>// </xsl:text>
            <xsl:for-each select="*">
              <xsl:value-of select="normalize-space(.)"/>
              <xsl:if test="position()!=last()">
                <xsl:text>, </xsl:text>
              </xsl:if>
            </xsl:for-each>
            <xsl:value-of select="$nl"/>
          </xsl:for-each>
        </xsl:for-each>
        <xsl:for-each select="mei:pubstmt">
          <xsl:for-each select="*">
            <xsl:text>// </xsl:text>
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:value-of select="$nl"/>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:for-each>

    <xsl:for-each select="mei:encodingdesc[mei:projectdesc[descendant::text()]]">
      <xsl:value-of select="$nl"/>
      <xsl:text>// Encoding description: </xsl:text>
      <xsl:for-each select="mei:projectdesc[descendant::text()]">
        <xsl:value-of select="$nl"/>
        <xsl:for-each select="mei:p">
          <xsl:text>// </xsl:text>
          <xsl:value-of select="normalize-space(.)"/>
          <xsl:value-of select="$nl"/>
        </xsl:for-each>
      </xsl:for-each>
      <xsl:text>// Converted to Mup using </xsl:text>
      <xsl:value-of select="$progname"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="$progversion"/>
      <xsl:value-of select="$nl"/>
    </xsl:for-each>

    <xsl:for-each select="mei:profiledesc[descendant::text()]">
      <xsl:for-each select="mei:langusage">
        <xsl:value-of select="$nl"/>
        <xsl:text>// Languages: </xsl:text>
        <xsl:for-each select="mei:language">
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
      <xsl:for-each select="mei:classification">
        <xsl:for-each select="mei:classcode[descendant::text()]">
          <xsl:text>// Class. code </xsl:text>
          <xsl:value-of select="position()"/>
          <xsl:text>: </xsl:text>
          <xsl:value-of select="normalize-space(.)"/>
          <xsl:value-of select="$nl"/>
        </xsl:for-each>
        <xsl:for-each select="mei:keywords[descendant::text()]">
          <xsl:text>// </xsl:text>
          <xsl:for-each select="mei:term[descendant::text()]">
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:if test="@classcode">
              <xsl:variable name="thisclasscode">
                <xsl:value-of select="@classcode"/>
              </xsl:variable>
              <xsl:text> [</xsl:text>
              <xsl:for-each select="//mei:classcode[@xml:id=$thisclasscode]">
                <xsl:value-of
                  select="count(preceding-sibling::mei:classcode) + 1"/>
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
      <xsl:value-of select="$nl"/>
    </xsl:for-each>
    <xsl:value-of select="$nl"/>

    <xsl:if test="not(following::mei:scoredef/mei:pghead1)">
      <xsl:text>header</xsl:text>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="$indent"/>
      <xsl:text>title </xsl:text>
      <xsl:value-of
        select="concat('&quot;',normalize-space(mei:filedesc/mei:titlestmt/mei:title[descendant::text()][1]),'&quot;')"/>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="$indent"/>
      <xsl:text>title </xsl:text>
      <xsl:value-of
        select="concat('&quot;',normalize-space(mei:filedesc/mei:titlestmt/mei:respstmt/*[not(name()='resp')][1]),'&quot;')"/>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="$nl"/>
    </xsl:if>
  </xsl:template>

  <!-- MEI body element -->
  <xsl:template match="mei:body">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- front matter -->
  <xsl:template match="mei:front">
    <xsl:text>// front matter not yet implemented</xsl:text>
    <xsl:value-of select="$nl"/>
  </xsl:template>
  <xsl:template match="mei:back">
    <xsl:text>// back matter not yet implemented</xsl:text>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="mei:music">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="mei:mdiv">
    <xsl:apply-templates select="mei:score"/>
  </xsl:template>

  <xsl:template match="mei:score">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="mei:scoredef">
    <xsl:text>score</xsl:text>
    <xsl:value-of select="$nl"/>
    <!-- floating voices, pack factor, scale, and measure numbering set in first scoredef -->
    <xsl:if test="count(preceding::mei:scoredef)=0">
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
    <xsl:if test="mei:staffgrp">
      <xsl:value-of select="$indent"/>
      <xsl:text>staffs=</xsl:text>
      <xsl:value-of select="count(.//mei:staffdef)"/>
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

    <!-- Layout and size info included but currently ignored due to problems
         converting MusicXML units -->
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
    <xsl:if test="descendant::mei:staffgrp[@barthru='true']">
      <xsl:value-of select="$indent"/>
      <xsl:text>barstyle=</xsl:text>
      <xsl:apply-templates select="mei:staffgrp" mode="barlines"/>
      <xsl:value-of select="$nl"/>
    </xsl:if>

    <!-- Indicate brackets and braces -->
    <xsl:variable name="brackets">
      <xsl:apply-templates select="mei:staffgrp" mode="bracket"/>
    </xsl:variable>
    <xsl:if test="replace($brackets,', $', '') != ''">
      <xsl:value-of select="$indent"/>
      <xsl:text>bracket=</xsl:text>
      <xsl:value-of select="replace($brackets,', $', '')"/>
      <xsl:value-of select="$nl"/>
    </xsl:if>
    <xsl:variable name="braces">
      <xsl:apply-templates select="mei:staffgrp" mode="brace"/>
    </xsl:variable>
    <xsl:if test="replace($braces,', $', '') != ''">
      <xsl:value-of select="$indent"/>
      <xsl:text>brace=</xsl:text>
      <xsl:value-of select="replace($braces,', $', '')"/>
      <xsl:value-of select="$nl"/>
    </xsl:if>
    <xsl:value-of select="$nl"/>
    <xsl:apply-templates select="mei:staffgrp|mei:staffdef"/>
    <xsl:apply-templates
      select="mei:pghead1|mei:pghead2|mei:pgfoot1|mei:pgfoot2"/>

    <xsl:if
      test="//mei:note[@coloration='inverse']|//mei:chord[@coloration='inverse']">
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

  <xsl:template match="mei:staffgrp" mode="barlines">
    <xsl:if test="@barthru='true'">
      <xsl:value-of select="mei:staffdef[1]/@n"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="mei:staffdef[last()]/@n"/>
      <xsl:if
        test="following-sibling::mei:staffgrp[@barthru='true']|mei:staffgrp[@barthru='true']">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:apply-templates select="mei:staffgrp[@barthru='true']" mode="barlines"
    />
  </xsl:template>

  <xsl:template match="mei:scoredef" mode="MIDI">
    <xsl:for-each select="descendant::mei:instrdef">
      <xsl:if test="@midi.channel or @midi.instrnum">
        <xsl:value-of select="$indent"/>
        <xsl:text>midi </xsl:text>
        <xsl:value-of select="ancestor::mei:staffdef/@n"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="ancestor::mei:layerdef/@n"/>
        <xsl:text>: </xsl:text>
      </xsl:if>
      <xsl:for-each select="@*[starts-with(name(),'midi.')]">
        <xsl:if test="name()='midi.channel'">
          <xsl:text>0 "channel=</xsl:text>
          <xsl:value-of select="."/>
          <xsl:text>";</xsl:text>
        </xsl:if>
        <xsl:if test="name()='midi.instrnum'">
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
  </xsl:template>

  <xsl:template match="mei:pghead1|mei:pghead2|mei:pgfoot1|mei:pgfoot2">
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
    <xsl:apply-templates select="descendant::mei:tr"/>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="mei:tr">
    <xsl:value-of select="$indent"/>
    <xsl:text>title </xsl:text>
    <xsl:apply-templates/>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="mei:td">
    <xsl:text>"</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>"</xsl:text>
    <xsl:if test="position()!=last()">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:rend">
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

  <xsl:template match="mei:lb">
    <xsl:text>\n</xsl:text>
  </xsl:template>

  <xsl:template match="mei:staffgrp">
    <xsl:apply-templates select="mei:staffdef|mei:staffgrp"/>
  </xsl:template>

  <xsl:template match="mei:staffgrp" mode="bracket">
    <xsl:if test="@symbol='bracket'">
      <xsl:value-of select="mei:staffdef[position()=1]/@n"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="mei:staffdef[position()=last()]/@n"/>
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
    <xsl:for-each select="mei:grpsym[@symbol='bracket']">
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
    <xsl:apply-templates select="mei:staffgrp" mode="bracket"/>
  </xsl:template>

  <xsl:template match="mei:staffgrp" mode="brace">
    <xsl:if test="@symbol='brace'">
      <xsl:value-of select="mei:staffdef[position()=1]/@n"/>
      <xsl:text>-</xsl:text>
      <xsl:value-of select="mei:staffdef[position()=last()]/@n"/>
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
    <xsl:for-each select="mei:grpsym[@symbol='brace']">
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
    <xsl:apply-templates select="mei:staffgrp" mode="brace"/>
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

  <xsl:template match="mei:staffdef">
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
        test="@key.sig != following::mei:scoredef[1]/@key.sig or count(following::mei:scoredef) = 0">
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
    <xsl:if test="following::mei:pedal[@style='pedstar'][@staff=$thisstaff]">
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

  <xsl:template match="mei:section">
    <xsl:if
      test="not(mei:scoredef[@meter.count and @meter.unit] or preceding::mei:scoredef[@meter.count and @meter.unit])">
      <xsl:variable name="sumdur">
        <xsl:value-of
          select="sum(mei:measure[1]/mei:staff[1]/mei:layer[1]//*[@dur.ges]/@dur.ges)"
        />
      </xsl:variable>
      <xsl:variable name="ppq">
        <xsl:choose>
          <xsl:when test="preceding::mei:staffdef[@n='1'][@ppq]">
            <xsl:value-of select="preceding::mei:staffdef[@n='1'][@ppq][1]/@ppq"
            />
          </xsl:when>
          <xsl:when test="descendant::mei:staffdef[@n='1'][@ppq]">
            <xsl:value-of
              select="descendant::mei:staffdef[@n='1'][@ppq][1]/@ppq"/>
          </xsl:when>
          <xsl:when test="descendant::mei:note[@dur='4' and @dur.ges]">
            <xsl:value-of
              select="following::mei:note[@dur='4' and @dur.ges][1]/@dur.ges"/>
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

  <xsl:template match="mei:fermata">
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

  <xsl:template match="mei:tempo|mei:dir">
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
      <xsl:text>"</xsl:text>
      <xsl:if test="@dur">
        <xsl:text> til </xsl:text>
        <xsl:value-of select="@dur"/>
      </xsl:if>
      <xsl:text>;</xsl:text>
      <xsl:value-of select="$nl"/>
      <xsl:if test="name(.)='tempo' and @bpm &gt; 0">
        <xsl:value-of select="$indent"/>
        <xsl:text>midi all: </xsl:text>
        <xsl:value-of select="round-half-to-even(@tstamp,3)"/>
        <xsl:text> "tempo=</xsl:text>
        <xsl:value-of select="@bpm"/>
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
        <xsl:when test="preceding::mei:staffdef[@n=$thisstaff][@ppq]">
          <xsl:value-of
            select="preceding::mei:staffdef[@n=$thisstaff][@ppq][1]/@ppq"/>
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
    <xsl:for-each select="mei:layer[descendant::mei:verse]">
      <xsl:variable name="versestring">
        <xsl:for-each select="mei:beam|mei:note|mei:chord">
          <xsl:choose>
            <xsl:when test="(name()='chord' or name()='note') and not(@grace)">
              <xsl:if test="mei:verse/mei:syl">
                <xsl:value-of select="verse[@n=$count]/syl"/>
                <xsl:choose>
                  <xsl:when test="mei:verse[@n=$count]/mei:syl/@con='d'">
                    <xsl:text>-</xsl:text>
                  </xsl:when>
                  <xsl:when test="mei:verse[@n=$count]/mei:syl/@con='u'">
                    <xsl:text>_</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text> </xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:if>
            </xsl:when>
            <xsl:when test="name()='beam'">
              <xsl:for-each select="mei:beam|mei:note|mei:chord">
                <xsl:choose>
                  <xsl:when
                    test="(name()='chord' or name()='note') and not(@grace)">
                    <xsl:if test="mei:verse/mei:syl">
                      <xsl:value-of select="mei:verse[@n=$count]/mei:syl"/>
                      <xsl:choose>
                        <xsl:when test="mei:verse[@n=$count]/mei:syl/@con='d'">
                          <xsl:text>-</xsl:text>
                        </xsl:when>
                        <xsl:when test="mei:verse[@n=$count]/mei:syl/@con='u'">
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

  <xsl:template match="mei:measure">
    <xsl:if
      test="contains(name(preceding-sibling::*[not(comment())][1]), 'def') or count(preceding-sibling::mei:measure)=0">
      <xsl:text>music</xsl:text>
      <xsl:value-of select="$nl"/>
      <xsl:if test="ancestor::mei:section[1]/@restart='true'">
        <!-- Mup doesn't allow rptstart and restart on the same measure. -->
        <xsl:value-of select="$indent"/>
        <xsl:choose>
          <xsl:when test="@left='rptstart'">
            <xsl:text>newscore;</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>restart</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:value-of select="$nl"/>
      </xsl:if>
    </xsl:if>
    <xsl:if test="count(preceding::mei:measure) = 0 and @left='rptstart'">
      <!-- Because Mup doesn't handle left barlines, create a phony measure
      containing only space just to set the right barline. -->
      <xsl:value-of select="$indent"/>
      <xsl:text>// empty measure just to get the initial repeat sign</xsl:text>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="$indent"/>
      <xsl:text>1 1: ms;</xsl:text>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="$indent"/>
      <xsl:text>repeatstart</xsl:text>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="$nl"/>
    </xsl:if>
    <xsl:value-of select="$indent"/>
    <xsl:text>// m. </xsl:text>
    <xsl:value-of select="@n"/>
    <xsl:value-of select="$nl"/>

    <!-- Process initial MIDI settings in 1st measure -->
    <xsl:if test="count(preceding::mei:measure)=0">
      <xsl:apply-templates
        select="preceding::mei:scoredef[count(preceding::mei:scoredef)=0]"
        mode="MIDI"/>
    </xsl:if>

    <xsl:apply-templates select="mei:staff"/>
    <xsl:apply-templates
      select="mei:annot|mei:arpeg|mei:dir|mei:dynam|mei:fermata|mei:hairpin|mei:phrase|mei:reh|mei:slur|mei:tempo|mei:mordent|mei:trill|mei:turn"/>
    <xsl:apply-templates select="mei:staff//mei:halfmrpt" mode="draw"/>
    <xsl:apply-templates select="mei:pedal">
      <xsl:sort select="@tstamp" data-type="number"/>
      <xsl:sort select="@dir" order="descending" data-type="text"/>
    </xsl:apply-templates>

    <!-- lyrics -->
    <xsl:for-each select="mei:staff[descendant::mei:verse]">
      <xsl:for-each select="mei:layer[descendant::mei:verse]">
        <xsl:for-each-group select="descendant::mei:verse" group-by="@n">
          <xsl:variable name="versenum">
            <xsl:value-of select="current-grouping-key()"/>
          </xsl:variable>
          <xsl:value-of select="$indent"/>
          <xsl:text>lyrics below </xsl:text>
          <xsl:value-of select="ancestor::mei:staff/@n"/>
          <xsl:text>: </xsl:text>
          <xsl:for-each select="ancestor::mei:layer">
            <xsl:for-each
              select="descendant::mei:note[not(@grace)]|descendant::mei:chord[not(@grace)]|
              descendant::mei:rest|descendant::mei:space">
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
              <xsl:if test="not(descendant::mei:syl)">
                <xsl:text>s</xsl:text>
              </xsl:if>
              <xsl:text>;</xsl:text>
              <xsl:call-template name="tupletendlyrics"/>
            </xsl:for-each>

            <xsl:text> "</xsl:text>
            <xsl:variable name="lyricstring">
              <xsl:for-each select="descendant::mei:syl">
                <xsl:if test="ancestor::mei:verse/@n=$versenum">
                  <xsl:value-of select="."/>
                  <xsl:choose>
                    <xsl:when test="@con='d'">
                      <xsl:text>-</xsl:text>
                    </xsl:when>
                    <xsl:when test="@con='u'">
                      <xsl:text>_</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text> </xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:value-of select="normalize-space($lyricstring)"/>
            <xsl:text>";</xsl:text>
          </xsl:for-each>
          <xsl:text> </xsl:text>
          <xsl:value-of select="$nl"/>
        </xsl:for-each-group>
      </xsl:for-each>
    </xsl:for-each>

    <!-- Process all slurs in the last measure, looking for cross-staff,
      grace to grace-note, or non-grace to grace-note slurs. Also, process
      all tie elements in the last measure.
    -->
    <xsl:if test="count(following::mei:measure)=0">
      <xsl:apply-templates select="preceding::mei:phrase|preceding::mei:slur"
        mode="special"/>
      <xsl:apply-templates select="preceding::mei:tie" mode="special"/>
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
        test="not(contains($bar_style,'repeat')) and following::mei:measure[1]/@left='rptstart'">
        <xsl:text>(</xsl:text>
        <xsl:value-of select="$bar_style"/>
        <xsl:text>) repeatstart</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$bar_style"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="number(@n) and following::mei:measure">
      <xsl:text> mnum=</xsl:text>
      <xsl:value-of select="@n + 1"/>
    </xsl:if>
    <!-- ending designation -->
    <xsl:variable name="ending">
      <xsl:apply-templates select="following::mei:measure[1]"
        mode="ending_start_next_measure"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$ending != ''">
        <xsl:value-of select="$ending"/>
      </xsl:when>
      <xsl:when test="@xml:id=parent::mei:ending/mei:measure[last()]/@xml:id">
        <xsl:text> endending</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:value-of select="$nl"/>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="mei:annot">
    <xsl:value-of select="$indent"/>
    <xsl:text>//</xsl:text>
    <xsl:text> staff: </xsl:text>
    <xsl:value-of select="@staff"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="mei:reh">
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
      <xsl:when test="mei:rend">
        <xsl:apply-templates select="mei:rend"/>
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

  <xsl:template match="mei:mordent|mei:trill|mei:turn">
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
    <!-- Vertical offset -->
    <xsl:if test="@vo">
      <xsl:text> dist </xsl:text>
      <xsl:value-of select="@vo"/>
      <xsl:text>!</xsl:text>
    </xsl:if>
    <xsl:text>: </xsl:text>
    <xsl:choose>
      <xsl:when test="name()='turn' and @delayed='yes'">
        <xsl:value-of select="@tstamp + .5"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@tstamp"/>
      </xsl:otherwise>
    </xsl:choose>
    <!-- Horizontal offset -->
    <xsl:if test="@ho">
      <xsl:text> [</xsl:text>
      <xsl:value-of select="@ho"/>
      <xsl:text>]</xsl:text>
    </xsl:if>
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
        <xsl:if test="@dur">
          <xsl:text> til </xsl:text>
          <xsl:value-of select="@dur"/>
        </xsl:if>
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

  <xsl:template match="mei:arpeg">
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

  <xsl:template match="mei:phrase|mei:slur">
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
          <xsl:value-of select="//mei:note[@xml:id=$thisstart]/@grace"/>
        </xsl:variable>
        <xsl:variable name="endtype">
          <xsl:value-of select="//mei:note[@xml:id=$thisend]/@grace"/>
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
              <xsl:value-of
                select="generate-id(preceding::mei:note[@xml:id=$thisend]/ancestor::mei:layer)"
              />
            </xsl:variable>
            <xsl:value-of
              select="count(preceding::mei:note[@xml:id=$thisend]/preceding::mei:note[@grace][ancestor::mei:layer[generate-id()=$thislayer]][preceding::mei:note[@xml:id=$thisstart]]) + 1"/>
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
            <xsl:value-of select="@curvedir"/>
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
                test="count(preceding::mei:note[@xml:id=$thisend]/following-sibling::mei:note[not(@grace)]) = 0">
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

  <xsl:template match="mei:tie" mode="special">
    <xsl:call-template name="drawtie"/>
  </xsl:template>

  <xsl:template name="drawtie">
    <xsl:value-of select="$indent"/>
    <xsl:text>medium curve (_</xsl:text>
    <xsl:value-of select="@startid"/>
    <xsl:text>.x, _</xsl:text>
    <xsl:value-of select="@startid"/>
    <xsl:text>.y</xsl:text>
    <xsl:choose>
      <xsl:when test="@place='below'">
        <xsl:text>-1.75</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>+1.75</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>) to (_</xsl:text>
    <xsl:value-of select="@endid"/>
    <xsl:text>.x, _</xsl:text>
    <xsl:value-of select="@endid"/>
    <xsl:text>.y</xsl:text>
    <xsl:choose>
      <xsl:when test="@place='below'">
        <xsl:text>-1.75</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>+1.75</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>) bulge </xsl:text>
    <xsl:if test="@place='below' or @bulge &lt; 0">
      <xsl:text>-</xsl:text>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@bulge">
        <xsl:value-of select="abs(@bulge)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="mei:phrase|mei:slur" mode="special">
    <xsl:variable name="thisstart">
      <xsl:value-of select="@startid"/>
    </xsl:variable>
    <xsl:variable name="thisend">
      <xsl:value-of select="@endid"/>
    </xsl:variable>
    <xsl:variable name="starttype">
      <xsl:value-of select="//mei:note[@xml:id=$thisstart]/@grace"/>
    </xsl:variable>
    <xsl:variable name="endtype">
      <xsl:value-of select="//mei:note[@xml:id=$thisend]/@grace"/>
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
                test="count(preceding::mei:note[@xml:id=$thisend]/following-sibling::mei:note[not(@grace)]) = 0">
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
    <xsl:if test="@place='below' or @bulge &lt; 0">
      <xsl:text>-</xsl:text>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@bulge">
        <xsl:value-of select="abs(@bulge)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>8</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="mei:pedal">
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

  <xsl:template match="mei:dynam">
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

  <xsl:template match="mei:hairpin">
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
        <xsl:when test="preceding::mei:staffdef[@n=$thisstaff][@ppq]">
          <xsl:value-of
            select="preceding::mei:staffdef[@n=$thisstaff][@ppq][1]/@ppq"/>
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

  <xsl:template match="mei:measure" mode="ending_start_next_measure">
    <xsl:if test="@xml:id=parent::mei:ending/mei:measure[1]/@xml:id">
      <xsl:text> ending</xsl:text>
      <xsl:text> "</xsl:text>
      <xsl:value-of select="parent::mei:ending/@n"/>
      <xsl:text>"</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:pb">
    <xsl:if test="count(preceding::mei:pb) != 0">
      <xsl:text>newpage //p. </xsl:text>
      <xsl:value-of select="count(preceding::mei:pb) + 1"/>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="$nl"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:sb">
    <xsl:if test="name(preceding-sibling::*[1]) != 'pb'">
      <xsl:text>newscore</xsl:text>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="$nl"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:staff">
    <xsl:choose>
      <xsl:when test="mei:layer">
        <xsl:apply-templates select="mei:layer[not(@visible='no')]"/>
      </xsl:when>
      <xsl:when test="mei:app">
        <xsl:apply-templates
          select="mei:app|mei:beam|mei:chord|mei:clefchange|mei:ftrem|mei:groupetto|mei:halfmrpt|mei:mrest|mei:mrpt|mei:mspace|mei:note|mei:pad|mei:rest|mei:space|mei:tuplet"/>
        <xsl:value-of select="$nl"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$indent"/>
        <xsl:value-of select="@n"/>
        <xsl:text>: </xsl:text>
        <xsl:apply-templates
          select="mei:beam|mei:chord|mei:clefchange|mei:ftrem|mei:groupetto|mei:halfmrpt|mei:mrest|mei:rpt|mei:space|mei:note|mei:pad|mei:rest|mei:space|mei:tuplet"/>
        <xsl:value-of select="$nl"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:choice">
    <xsl:apply-templates select="mei:orig"/>
  </xsl:template>

  <xsl:template match="mei:orig">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="mei:subst">
    <xsl:apply-templates select="mei:corr"/>
  </xsl:template>

  <xsl:template match="mei:corr">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="mei:ftrem">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="mei:app">
    <xsl:apply-templates select="mei:rdg[contains(string(@source),$source)]"/>
  </xsl:template>

  <xsl:template match="mei:rdg">
    <xsl:choose>
      <xsl:when test="mei:layer">
        <xsl:apply-templates select="mei:layer[not(@visible='no')]"/>
      </xsl:when>
      <xsl:when test="mei:app">
        <xsl:apply-templates select="mei:app"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$indent"/>
        <xsl:value-of select="ancestor::mei:staff/@n"/>
        <xsl:text>: </xsl:text>
        <xsl:apply-templates
          select="mei:beam|mei:chord|mei:clefchange|mei:ftrem|mei:groupetto|mei:halfmrpt|mei:mrest|mei:mrpt|mei:mspace|mei:note|mei:pad|mei:rest|mei:space|mei:tuplet"
        />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:layer">
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
      select="mei:beam|mei:chord|mei:clefchange|mei:ftrem|mei:groupetto|mei:halfmrpt|mei:mrest|mei:mrpt|mei:mspace|mei:note|mei:pad|mei:rest|mei:space|mei:tuplet|mei:choice|mei:subst"/>
    <xsl:value-of select="$nl"/>
  </xsl:template>

  <xsl:template match="mei:beam">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="mei:pad">
    <xsl:text>[pad </xsl:text>
    <xsl:value-of select="@num"/>
    <xsl:text>]</xsl:text>
  </xsl:template>

  <xsl:template match="mei:tuplet">
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
          <xsl:value-of select="count(mei:note[not(@grace)])"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="@num.visible='no'">
      <xsl:text>n</xsl:text>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@dur">
        <xsl:text>,</xsl:text>
        <xsl:value-of select="@dur"/>
        <xsl:if test="@dots">
          <xsl:call-template name="makedots"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <!-- Convert numbase to duration -->
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>;</xsl:text>
  </xsl:template>

  <xsl:template match="mei:chord">
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
      select="mei:note[not(@staff)] | mei:note[@staff=ancestor::mei:staff/@n]"/>
    <xsl:if test="mei:note[@staff != ancestor::mei:staff/@n]">
      <xsl:text> with </xsl:text>
      <xsl:apply-templates select="mei:note[@staff != ancestor::mei:staff/@n]"/>
      <xsl:choose>
        <xsl:when
          test="mei:note[@staff != ancestor::mei:staff/@n][1] &gt; ancestor::mei:staff/@n">
          <xsl:text> above</xsl:text>
        </xsl:when>
        <xsl:when
          test="mei:note[@staff != ancestor::mei:staff/@n][1] &lt; ancestor::mei:staff/@n">
          <xsl:text> below</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:if>

    <!-- inter-chord attributes -->
    <xsl:variable name="interchord">
      <xsl:if test="@tie='i' or @tie='m'">
        <!-- Mup will ignore a tie if the 2nd note/chord isn't in the same
          layer. Therefore, the <tie> element can be used safely as a
          replacement in this case. However, a check should be added here
          to look for end points that are in the same layer, so that if
          there is a <tie> element used for this same tie and Mup can draw
          it using the 'tie' syntax, the tie won't be rendered twice. -->
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

  <xsl:template match="mei:note">
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
      <xsl:when test="parent::mei:chord">
        <!-- Do nothing.  Duration handled in chord template. -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="preceding::mei:note[@dur][1]/@dur"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="makedots"/>

    <xsl:choose>
      <xsl:when test="@tab.string and @tab.fret">
        <xsl:variable name="stringcount">
          <xsl:value-of
            select="count(tokenize(preceding::mei:staffdef[@tab.strings][1]/@tab.strings,' '))"
          />
        </xsl:variable>
        <xsl:variable name="stringnum">
          <xsl:value-of select="@tab.string"/>
        </xsl:variable>
        <xsl:variable name="stringname">
          <xsl:value-of
            select="for $token in ($stringnum to $stringnum) return
            tokenize(preceding::mei:staffdef[@tab.strings][1]/@tab.strings, ' ')[$token]"
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
        <xsl:if test="@staff and not(parent::mei:chord)">
          <xsl:text> with </xsl:text>
        </xsl:if>
        <xsl:value-of select="@pname"/>
      </xsl:when>
      <xsl:when test="@pname.ges">
        <xsl:if test="@staff and not(parent::mei:chord)">
          <xsl:text> with </xsl:text>
        </xsl:if>
        <xsl:value-of select="@pname.ges"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="@staff and not(parent::mei:chord)">
          <xsl:text> with </xsl:text>
        </xsl:if>
        <xsl:value-of select="preceding::mei:note[@pname][1]/@pname"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
      <xsl:when test="@accid">
        <xsl:value-of
          select="replace(replace(@accid,'f','&#x0026;'),'s','#')"/>
      </xsl:when>
      <!-- Mup allows only parentheses as enclosing signs for a
        cautionary accidental. -->
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
      <xsl:when test="mei:accid">
        <xsl:if test="mei:accid/@enclose">
          <xsl:text>(</xsl:text>
        </xsl:if>
        <xsl:value-of
          select="replace(replace(mei:accid/@accid,'f','&#x0026;'),'s','#')"/>
        <xsl:if test="mei:accid/@enclose">
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
        <xsl:value-of select="preceding::mei:note[@oct][1]/@oct"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="@size='cue'">
      <xsl:if test="not(../@size='cue')">
        <xsl:text>?</xsl:text>
      </xsl:if>
    </xsl:if>

    <xsl:if test="@tie='i' or @tie='m'">
      <!-- Mup will ignore a tie if the 2nd note isn't in the same layer.
      Therefore, the <tie> element can be used safely as a replacement in
      this case. However, a check should be added here to look for end points
      that are in the same layer, so that if there is a <tie> element used for
      this same tie and Mup can draw it using the '~' syntax, the tie won't be
      rendered twice. -->
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

    <xsl:if test="@staff and not(parent::mei:chord)">
      <xsl:variable name="thisstaff">
        <xsl:value-of select="ancestor::mei:staff/@n"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="@staff > $thisstaff">
          <xsl:text> below </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text> above </xsl:text>
        </xsl:otherwise>
      </xsl:choose>
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
    <xsl:if test="parent::mei:ftrem">
      <xsl:if test="position()=1 and not(@grace)">
        <xsl:text> alt </xsl:text>
        <xsl:value-of select="parent::mei:ftrem/@slash"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="tupletstart">
    <xsl:if test="starts-with(@tuplet, 'i') and not(ancestor::mei:tuplet)">
      <xsl:text>{</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template name="tupletend">
    <xsl:if test="starts-with(@tuplet, 't') and not(ancestor::mei:tuplet)">
      <xsl:text>}</xsl:text>
      <xsl:variable name="id">
        <xsl:value-of select="@xml:id"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="following::mei:tupletspan[@endid=$id]/@num.place">
          <xsl:text> </xsl:text>
          <xsl:value-of
            select="following::mei:tupletspan[@endid=$id][1]/@num.place"/>
        </xsl:when>
      </xsl:choose>
      <xsl:if test="following::mei:tupletspan[@endid=$id]/@num">
        <xsl:text> </xsl:text>
        <xsl:value-of select="following::mei:tupletspan[@endid=$id][1]/@num"/>
        <xsl:choose>
          <xsl:when
            test="following::mei:tupletspan[@endid=$id]/@num.visible='true'">
            <xsl:if
              test="following::mei:tupletspan[@endid=$id]/@bracket.visible='false'">
              <xsl:text>num</xsl:text>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>n</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="following::mei:tupletspan[@endid=$id]/@dur">
            <xsl:choose>
              <xsl:when test="following::mei:tupletspan[@endid=$id][1]/@dots">
                <xsl:text>,</xsl:text>
                <xsl:value-of
                  select="following::mei:tupletspan[@endid=$id][1]/@dur"/>
                <xsl:for-each select="following::mei:tupletspan[@endid=$id][1]">
                  <xsl:call-template name="makedots"/>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>,</xsl:text>
                <xsl:value-of
                  select="replace(normalize-space(following::mei:tupletspan[@endid=$id][1]/@dur), ' ','+')"
                />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="following::mei:tupletspan[@endid=$id]/@numbase">
              <!-- Mup can't handle numbase, only dur.
                   Can numbase be converted to a duration? -->
              <!-- <xsl:text>,</xsl:text>
              <xsl:value-of select="following::tupletspan[@endid=$id]/@numbase"
              /> -->
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
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
      <xsl:if test="following::mei:tupletspan[@endid=$id]/@num">
        <xsl:text> </xsl:text>
        <xsl:value-of select="following::mei:tupletspan[@endid=$id]/@num"/>
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
        <xsl:when test="@artic='ten-stacc'">
          <xsl:text>-,.,</xsl:text>
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
        select="mei:artic[not(@source) or contains(string(@source),$source)]">
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
          <xsl:when test="@artic='ten-stacc'">
            <xsl:text>-,.,</xsl:text>
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
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="$artics != ''">
      <xsl:text>[with </xsl:text>
      <xsl:value-of select="replace($artics, ',$', '')"/>
      <xsl:text>]</xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:mrest">
    <xsl:text>mr;</xsl:text>
  </xsl:template>

  <xsl:template match="mei:mrpt">
    <xsl:text>mrpt;</xsl:text>
  </xsl:template>

  <xsl:template match="mei:mspace">
    <xsl:text>ms;</xsl:text>
  </xsl:template>

  <xsl:template match="mei:halfmrpt">
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
              <xsl:value-of select="ancestor::mei:staff/@n"/>
            </xsl:variable>
            <xsl:apply-templates
              select="ancestor::mei:measure/preceding::mei:measure[staff[@n=$thisstaff and
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
                select="preceding::mei:scoredef[@meter.unit][1]/@meter.unit"/>
            </xsl:variable>
            <xsl:variable name="count">
              <xsl:value-of
                select="preceding::mei:scoredef[@meter.count][1]/@meter.count div 2"
              />
            </xsl:variable>
            <xsl:value-of select="($count * 4) div $unit"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:text>s;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:halfmrpt" mode="draw">
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

  <xsl:template match="mei:rest">
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

  <xsl:template match="mei:space">
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
      <xsl:value-of select="ancestor::mei:staff[1]/@n"/>
    </xsl:variable>
    <xsl:variable name="ppq">
      <xsl:choose>
        <xsl:when test="preceding::mei:staffdef[@n=$thisstaff][@ppq]">
          <xsl:value-of
            select="preceding::mei:staffdef[@n=$thisstaff][@ppq][1]/@ppq"/>
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

  <xsl:template match="mei:clefchange">
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
    <!-- Mup doesn't allow dotted grace notes -->
    <xsl:if test="@dots and @grace">
      <xsl:message>Dots on grace notes in measure <xsl:value-of
          select="ancestor::measure/@n"/> ignored.</xsl:message>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@dots=1 and not(@grace)">
        <xsl:text>.</xsl:text>
      </xsl:when>
      <xsl:when test="@dots=2 and not(@grace)">
        <xsl:text>..</xsl:text>
      </xsl:when>
      <xsl:when test="@dots=3 and not(@grace)">
        <xsl:text>...</xsl:text>
      </xsl:when>
      <xsl:when test="@dots=4 and not(@grace)">
        <xsl:text>....</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="beaming">
    <xsl:if test="parent::mei:beam or ancestor::mei:beam">
      <xsl:choose>
        <xsl:when
          test="count(preceding-sibling::*[name()='note' or name()='chord' or name()='rest' or name()='space'])=0 and not(@grace)">
          <xsl:text> bm</xsl:text>
          <xsl:if test="parent::mei:beam/@beam.with">
            <xsl:text> with staff </xsl:text>
            <xsl:value-of select="parent::mei:beam/@beam.with"/>
          </xsl:if>
        </xsl:when>
        <xsl:when test="@breaksec">
          <xsl:text> esbm</xsl:text>
        </xsl:when>
        <xsl:when test="position()=last() and not(@grace)">
          <xsl:text> ebm</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- Text nodes are space-normalized. -->
  <xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>

  <xsl:template match="mei:div">
    <xsl:value-of select="$nl"/>
    <xsl:text>block</xsl:text>
    <xsl:value-of select="$nl"/>
    <xsl:text>paragraph "</xsl:text>
    <xsl:apply-templates/>
    <xsl:text>"</xsl:text>
    <xsl:value-of select="$nl"/>
    <xsl:value-of select="$nl"/>
    <xsl:if test="preceding::mei:measure">
      <xsl:text>music</xsl:text>
      <xsl:value-of select="$nl"/>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
