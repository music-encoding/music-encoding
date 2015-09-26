<?xml version="1.0" encoding="UTF-8"?>

<!DOCTYPE xsl:stylesheet [
<!ENTITY beamstart   "&#xE501;">
<!ENTITY beamend     "&#xE502;">
<!ENTITY tupletstart "&#xE503;">
<!ENTITY tupletend   "&#xE504;">
]>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://music-encoding.org/tools/musicxml2mei"
  xmlns:functx="http://www.functx.com" exclude-result-prefixes="mei xs f functx"
  xmlns:saxon="http://saxon.sf.net/" extension-element-prefixes="saxon">

  <!-- parameters -->

  <!-- PARAM:rng_model_path -->
  <!-- This points to the 2.1.1 bugfix release tag -->
  <xsl:param name="rng_model_path"
    >https://raw.githubusercontent.com/music-encoding/music-encoding/b9dff53ad25203cfe43fa6b68eab6fad6d2a088e/schemata/mei-all.rng</xsl:param>

  <!-- PARAM:sch_model_path -->
  <xsl:param name="sch_model_path"
    >https://raw.githubusercontent.com/music-encoding/music-encoding/b9dff53ad25203cfe43fa6b68eab6fad6d2a088e/schemata/mei-all.rng</xsl:param>

  <!-- PARAM:layout
      This parameter defines the degree of layout information transformed into MEI. Possible values are:
      'preserve': All layout information available in the MusicXML file will be converted to MEI
      'strip': All layout information, including page formatting etc., will be stripped
      'pageLayout': Only information about the general formatting setup will be kept
  -->
  <xsl:param name="layout" select="'strip'"/>

  <!-- PARAM:formeWork
      This parameter decides if credit-words, page heads, etc. will be preserved or not. Values are:
      'preserve': All pageHeads etc. will be included
      'strip': All credits in the music branch will be stripped
  -->
  <xsl:param name="formeWork" select="'strip'"/>

  <!-- PARAM:keepAttributes 
      This parameter indicates whether redundant attributes for beams, tuplets and syls should be preserved.
  -->
  <xsl:param name="keepAttributes" select="'false'"/>

  <!-- PARAM:generateMIDI 
      This parameter indicates whether MIDI-relevant data should be preserved.
  -->
  <xsl:param name="generateMIDI" select="'false'"/>

  <!-- PARAM:articStyle
      This parameter defines how to handle articulation. Possible values are:
      'elem': Articulation is preserved using <artic>
      'attr': Articulation is preserved using @artic
      'both': Articulation is included both as an element and an attribute
  -->
  <xsl:param name="articStyle" select="'elem'"/>

  <!-- PARAM:accidStyle
      This parameter defines how to handle accidentals. Possible values are:
      'elem': Accidentals are preserved using <accid>
      'attr': Accidentals are preserved using @accid
      'both': Accidentals are included both as an element and an attribute
  -->
  <xsl:param name="accidStyle" select="'attr'"/>

  <!-- PARAM:tieStyle
      This parameter defines how to handle ties. Possible values are:
      'elem': Ties are preserved using <tie>
      'attr': Ties are preserved using @tie
      'both': Ties are included both as an element and an attribute
  -->
  <xsl:param name="tieStyle" select="'attr'"/>

  <!-- PARAM:labelStyle
      This parameter defines how to handle labels on staffDefs and groups. Possible values are:
      'elem': Labels are encoded using <label>…</label> and <label><abbr>…</abbr></label>
      'attr': Labels are preserved using @label and @label.abbr
      'both': Labels are included both as an element and an attribute
  -->
  <xsl:param name="labelStyle" select="'attr'"/>

  <!-- PARAM:keepRights
      This parameter defines how to treat the rights statement for the MEI file. If set to 'true', then
      the rights statement in the MusicXML file is used as the value of the fileDesc/availability/useRestrict
      element. Otherwise, the rights statement given in the source MusicXML file is discarded.
  -->
  <xsl:param name="keepRights" select="'false'"/>

  <xsl:character-map name="delimiters">
    <xsl:output-character character="&beamstart;" string="&lt;beam&gt;"/>
    <xsl:output-character character="&beamend;" string="&lt;/beam&gt;"/>
    <xsl:output-character character="&tupletstart;" string="&lt;tuplet&gt;"/>
    <xsl:output-character character="&tupletend;" string="&lt;/tuplet&gt;"/>
  </xsl:character-map>

  <xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="no" standalone="no"
    use-character-maps="delimiters"/>
  <xsl:strip-space elements="*"/>

  <!-- global variables -->

  <xsl:variable name="nl">
    <xsl:text>&#xa;</xsl:text>
  </xsl:variable>
  <xsl:variable name="progName">
    <xsl:text>musicxml2mei</xsl:text>
  </xsl:variable>
  <xsl:variable name="progVersion">
    <xsl:text>v. 3.0</xsl:text>
  </xsl:variable>
  <xsl:variable name="midiNamesPitched">
    <!-- ordered list of General MIDI program names (program numbers 0-127) -->
    <instrName>Acoustic_Grand_Piano</instrName>
    <instrName>Bright_Acoustic_Piano</instrName>
    <instrName>Electric_Grand_Piano</instrName>
    <instrName>Honky-tonk_Piano</instrName>
    <instrName>Electric_Piano_1</instrName>
    <instrName>Electric_Piano_2</instrName>
    <instrName>Harpsichord</instrName>
    <instrName>Clavi</instrName>
    <instrName>Celesta</instrName>
    <instrName>Glockenspiel</instrName>
    <instrName>Music_Box</instrName>
    <instrName>Vibraphone</instrName>
    <instrName>Marimba</instrName>
    <instrName>Xylophone</instrName>
    <instrName>Tubular_Bells</instrName>
    <instrName>Dulcimer</instrName>
    <instrName>Drawbar_Organ</instrName>
    <instrName>Percussive_Organ</instrName>
    <instrName>Rock_Organ</instrName>
    <instrName>Church_Organ</instrName>
    <instrName>Reed_Organ</instrName>
    <instrName>Accordion</instrName>
    <instrName>Harmonica</instrName>
    <instrName>Tango_Accordion</instrName>
    <instrName>Acoustic_Guitar_nylon</instrName>
    <instrName>Acoustic_Guitar_steel</instrName>
    <instrName>Electric_Guitar_jazz</instrName>
    <instrName>Electric_Guitar_clean</instrName>
    <instrName>Electric_Guitar_muted</instrName>
    <instrName>Overdriven_Guitar</instrName>
    <instrName>Distortion_Guitar</instrName>
    <instrName>Guitar_harmonics</instrName>
    <instrName>Acoustic_Bass</instrName>
    <instrName>Electric_Bass_finger</instrName>
    <instrName>Electric_Bass_pick</instrName>
    <instrName>Fretless_Bass</instrName>
    <instrName>Slap_Bass_1</instrName>
    <instrName>Slap_Bass_2</instrName>
    <instrName>Synth_Bass_1</instrName>
    <instrName>Synth_Bass_2</instrName>
    <instrName>Violin</instrName>
    <instrName>Viola</instrName>
    <instrName>Cello</instrName>
    <instrName>Contrabass</instrName>
    <instrName>Tremolo_Strings</instrName>
    <instrName>Pizzicato_Strings</instrName>
    <instrName>Orchestral_Harp</instrName>
    <instrName>Timpani</instrName>
    <instrName>String_Ensemble_1</instrName>
    <instrName>String_Ensemble_2</instrName>
    <instrName>SynthStrings_1</instrName>
    <instrName>SynthStrings_2</instrName>
    <instrName>Choir_Aahs</instrName>
    <instrName>Voice_Oohs</instrName>
    <instrName>Synth_Voice</instrName>
    <instrName>Orchestra_Hit</instrName>
    <instrName>Trumpet</instrName>
    <instrName>Trombone</instrName>
    <instrName>Tuba</instrName>
    <instrName>Muted_Trumpet</instrName>
    <instrName>French_Horn</instrName>
    <instrName>Brass_Section</instrName>
    <instrName>SynthBrass_1</instrName>
    <instrName>SynthBrass_2</instrName>
    <instrName>Soprano_Sax</instrName>
    <instrName>Alto_Sax</instrName>
    <instrName>Tenor_Sax</instrName>
    <instrName>Baritone_Sax</instrName>
    <instrName>Oboe</instrName>
    <instrName>English_Horn</instrName>
    <instrName>Bassoon</instrName>
    <instrName>Clarinet</instrName>
    <instrName>Piccolo</instrName>
    <instrName>Flute</instrName>
    <instrName>Recorder</instrName>
    <instrName>Pan_Flute</instrName>
    <instrName>Blown_Bottle</instrName>
    <instrName>Shakuhachi</instrName>
    <instrName>Whistle</instrName>
    <instrName>Ocarina</instrName>
    <instrName>Lead_1_square</instrName>
    <instrName>Lead_2_sawtooth</instrName>
    <instrName>Lead_3_calliope</instrName>
    <instrName>Lead_4_chiff</instrName>
    <instrName>Lead_5_charang</instrName>
    <instrName>Lead_6_voice</instrName>
    <instrName>Lead_7_fifths</instrName>
    <instrName>Lead_8_bass_and_lead</instrName>
    <instrName>Pad_1_new_age</instrName>
    <instrName>Pad_2_warm</instrName>
    <instrName>Pad_3_polysynth</instrName>
    <instrName>Pad_4_choir</instrName>
    <instrName>Pad_5_bowed</instrName>
    <instrName>Pad_6_metallic</instrName>
    <instrName>Pad_7_halo</instrName>
    <instrName>Pad_8_sweep</instrName>
    <instrName>FX_1_rain</instrName>
    <instrName>FX_2_soundtrack</instrName>
    <instrName>FX_3_crystal</instrName>
    <instrName>FX_4_atmosphere</instrName>
    <instrName>FX_5_brightness</instrName>
    <instrName>FX_6_goblins</instrName>
    <instrName>FX_7_echoes</instrName>
    <instrName>FX_8_sci-fi</instrName>
    <instrName>Sitar</instrName>
    <instrName>Banjo</instrName>
    <instrName>Shamisen</instrName>
    <instrName>Koto</instrName>
    <instrName>Kalimba</instrName>
    <instrName>Bagpipe</instrName>
    <instrName>Fiddle</instrName>
    <instrName>Shanai</instrName>
    <instrName>Tinkle_Bell</instrName>
    <instrName>Agogo</instrName>
    <instrName>Steel_Drums</instrName>
    <instrName>Woodblock</instrName>
    <instrName>Taiko_Drum</instrName>
    <instrName>Melodic_Tom</instrName>
    <instrName>Synth_Drum</instrName>
    <instrName>Reverse_Cymbal</instrName>
    <instrName>Guitar_Fret_Noise</instrName>
    <instrName>Breath_Noise</instrName>
    <instrName>Seashore</instrName>
    <instrName>Bird_Tweet</instrName>
    <instrName>Telephone_Ring</instrName>
    <instrName>Helicopter</instrName>
    <instrName>Applause</instrName>
    <instrName>Gunshot</instrName>
  </xsl:variable>
  <xsl:variable name="midiNamesUnpitched">
    <!-- ordered list of General MIDI percussion instrument names (key numbers 35-81) -->
    <instrName>Acoustic_Bass_Drum</instrName>
    <instrName>Bass_Drum_1</instrName>
    <instrName>Side_Stick</instrName>
    <instrName>Acoustic_Snare</instrName>
    <instrName>Hand_Clap</instrName>
    <instrName>Electric_Snare</instrName>
    <instrName>Low_Floor_Tom</instrName>
    <instrName>Closed_Hi_Hat</instrName>
    <instrName>High_Floor_Tom</instrName>
    <instrName>Pedal_Hi-Hat</instrName>
    <instrName>Low_Tom</instrName>
    <instrName>Open_Hi-Hat</instrName>
    <instrName>Low-Mid_Tom</instrName>
    <instrName>Hi-Mid_Tom</instrName>
    <instrName>Crash_Cymbal_1</instrName>
    <instrName>High_Tom</instrName>
    <instrName>Ride_Cymbal_1</instrName>
    <instrName>Chinese_Cymbal</instrName>
    <instrName>Ride_Bell</instrName>
    <instrName>Tambourine</instrName>
    <instrName>Splash_Cymbal</instrName>
    <instrName>Cowbell</instrName>
    <instrName>Crash_Cymbal_2</instrName>
    <instrName>Vibraslap</instrName>
    <instrName>Ride_Cymbal_2</instrName>
    <instrName>Hi_Bongo</instrName>
    <instrName>Low_Bongo</instrName>
    <instrName>Mute_Hi_Conga</instrName>
    <instrName>Open_Hi_Conga</instrName>
    <instrName>Low_Conga</instrName>
    <instrName>High_Timbale</instrName>
    <instrName>Low_Timbale</instrName>
    <instrName>High_Agogo</instrName>
    <instrName>Low_Agogo</instrName>
    <instrName>Cabasa</instrName>
    <instrName>Maracas</instrName>
    <instrName>Short_Whistle</instrName>
    <instrName>Long_Whistle</instrName>
    <instrName>Short_Guiro</instrName>
    <instrName>Long_Guiro</instrName>
    <instrName>Claves</instrName>
    <instrName>Hi_Wood_Block</instrName>
    <instrName>Low_Wood_Block</instrName>
    <instrName>Mute_Cuica</instrName>
    <instrName>Open_Cuica</instrName>
    <instrName>Mute_Triangle</instrName>
    <instrName>Open_Triangle</instrName>
  </xsl:variable>
  <xsl:variable name="scorePPQ">
    <xsl:variable name="staffPPQvalues">
      <xsl:choose>
        <xsl:when test="//measure[1]//attributes/divisions">
          <xsl:for-each select="//measure[1]">
            <xsl:copy-of select="part[1]/attributes/divisions"/>
            <xsl:for-each select="part[position() &gt; 1]">
              <xsl:for-each
                select="attributes[divisions[not(.=preceding::part/attributes/divisions)]]/divisions">
                <xsl:sort data-type="number"/>
                <xsl:copy-of select="."/>
              </xsl:for-each>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:when>
        <!-- Supply ppq based on duration of first note? -->
        <!--<xsl:when test="//measure[1]//note[duration]">
        </xsl:when>-->
        <xsl:otherwise>
          <xsl:variable name="errorMessage">
            <xsl:text>Conversion requires attributes/divisions in m.
              1</xsl:text>
          </xsl:variable>
          <xsl:message terminate="yes">
            <xsl:value-of select="normalize-space($errorMessage)"/>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="count($staffPPQvalues//divisions) = 1">
        <xsl:value-of select="$staffPPQvalues//divisions[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="leastCommonMultiple">
          <xsl:with-param name="in">
            <xsl:copy-of select="$staffPPQvalues"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="defaultLayout">
    <xsl:choose>
      <xsl:when test="score-timewise">
        <xsl:apply-templates select="score-timewise/part-list" mode="layout"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="errorMessage">The source file is not a time-wise MusicXML
          file!</xsl:variable>
        <xsl:message terminate="yes">
          <xsl:value-of select="normalize-space($errorMessage)"/>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- 'Match' templates -->
  <xsl:template match="/">
    <xsl:if test="$rng_model_path != ''">
      <xsl:processing-instruction name="xml-model">
        <xsl:value-of select="concat('&#32;href=&quot;', $rng_model_path, '&quot;')"/>
        <xsl:text> type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
      </xsl:processing-instruction>
      <xsl:value-of select="$nl"/>
    </xsl:if>

    <xsl:if test="$sch_model_path != ''">
      <xsl:processing-instruction name="xml-model">
        <xsl:value-of select="concat('&#32;href=&quot;', $sch_model_path, '&quot;')"/>
        <xsl:text> type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:text>
      </xsl:processing-instruction>
      <xsl:value-of select="$nl"/>
    </xsl:if>

    <xsl:variable name="firstRun">
      <mei xmlns="http://www.music-encoding.org/ns/mei" meiversion="2013">
        <xsl:apply-templates select="score-timewise" mode="header"/>
        <xsl:apply-templates select="score-timewise" mode="music"/>
      </mei>
    </xsl:variable>

    <!-- DEBUG: Uncommenting the following lines will force the output to
      contain only the results of "firstRun" processing -->
    <!--<xsl:copy-of select="$firstRun"/>
    <xsl:message terminate="yes">Stopped after firstRun results</xsl:message>-->

    <xsl:variable name="secondRun">
      <xsl:apply-templates select="$firstRun" mode="postProcess"/>
    </xsl:variable>

    <xsl:apply-templates select="$secondRun" mode="cleanUp"/>

  </xsl:template>

  <xsl:template match="*" mode="insertSpace">
    <!-- Insert a time-filling space -->
    <xsl:if test="not(@grace)">
      <space xmlns="http://www.music-encoding.org/ns/mei">
        <xsl:attribute name="xml:id">
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
        <xsl:copy-of select="@tstamp.ges|@dur|@dots|@dur.ges|@part|@layer|@staff"/>
        <xsl:choose>
          <xsl:when test="@beam">
            <xsl:copy-of select="@beam"/>
          </xsl:when>
          <xsl:when test="*[@beam]">
            <xsl:copy-of select="*[@beam][1]/@beam"/>
          </xsl:when>
        </xsl:choose>
      </space>
    </xsl:if>
  </xsl:template>

  <xsl:template match="accidental-mark" mode="stage1.amlist">
    <!-- Accidentals attached to ornaments -->
    <xsl:variable name="accidPlace">
      <xsl:choose>
        <xsl:when test="@placement='above'">
          <xsl:choose>
            <xsl:when test="not(preceding-sibling::accidental-mark[1]/@placement = 'above')">
              <xsl:text>accidupper</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>accidlower</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="@placement='below'">
          <xsl:choose>
            <xsl:when test="not(preceding-sibling::accidental-mark[1]/@placement = 'below')">
              <xsl:text>accidlower</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>accidupper</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="count(ancestor::*[1]/accidental-mark) &gt; 1">
              <!-- More than one accidental-mark -->
              <xsl:choose>
                <xsl:when test="count(preceding-sibling::accidental-mark) = 0">
                  <!-- First accidental-mark -->
                  <xsl:text>accidupper</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <!-- Not first accidental-mark -->
                  <xsl:choose>
                    <xsl:when test="preceding-sibling::accidental-mark/@placement='below'">
                      <xsl:text>accidupper</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text>accidlower</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <!-- Single accidental-mark -->
              <xsl:text>accidupper</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="matches(normalize-space(.), '^sharp$') or matches(normalize-space(.),
      '^natural$') or matches(normalize-space(.), '^flat$') or matches(normalize-space(.),
      '^double-sharp$') or matches(normalize-space(.), '^double-flat$') or
      matches(normalize-space(.), '^sharp-sharp$')or matches(normalize-space(.),
      '^flat-flat$') or matches(normalize-space(.), '^natural-sharp$') or
      matches(normalize-space(.), '^natural-flat$') or matches(normalize-space(.),
      '^flat-down$') or matches(normalize-space(.), '^flat-up$') or
      matches(normalize-space(.), '^natural-down$') or matches(normalize-space(.),
      '^natural-up$') or matches(normalize-space(.), '^sharp-down$') or
      matches(normalize-space(.), '^sharp-up$') or matches(normalize-space(.),
      '^triple-sharp$') or matches(normalize-space(.), '^triple-flat$') or
      matches(normalize-space(.), '^quarter-flat$') or matches(normalize-space(.),
      '^three-quarters-flat$') or matches(normalize-space(.), '^quarter-sharp$') or
      matches(normalize-space(.), '^three-quarters-sharp$')">
      <xsl:attribute name="{$accidPlace}">
        <xsl:choose>
          <xsl:when test="normalize-space(.) = 'sharp'">
            <xsl:text>s</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'natural'">
            <xsl:text>n</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'flat'">
            <xsl:text>f</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'double-sharp'">
            <xsl:text>x</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'double-flat'">
            <xsl:text>ff</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'sharp-sharp'">
            <xsl:text>ss</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'flat-flat'">
            <xsl:text>ff</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'natural-sharp'">
            <xsl:text>ns</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'natural-flat'">
            <xsl:text>nf</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'flat-down'">
            <xsl:text>fd</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'flat-up'">
            <xsl:text>fu</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'quarter-flat'">
            <xsl:text>fu</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'three-quarters-flat'">
            <xsl:text>fd</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'quarter-sharp'">
            <xsl:text>sd</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'three-quarters-sharp'">
            <xsl:text>su</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'natural-down'">
            <xsl:text>nd</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'natural-up'">
            <xsl:text>nu</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'sharp-down'">
            <xsl:text>sd</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'sharp-up'">
            <xsl:text>su</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'triple-sharp'">
            <xsl:text>ts</xsl:text>
          </xsl:when>
          <xsl:when test="normalize-space(.) = 'triple-flat'">
            <xsl:text>tf</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="not(matches(normalize-space(.), '^sharp$') or matches(normalize-space(.),
      '^natural$') or matches(normalize-space(.), '^flat$') or matches(normalize-space(.),
      '^double-sharp$') or matches(normalize-space(.), '^double-flat$') or
      matches(normalize-space(.), '^sharp-sharp$')or matches(normalize-space(.),
      '^flat-flat$') or matches(normalize-space(.), '^natural-sharp$') or
      matches(normalize-space(.), '^natural-flat$') or matches(normalize-space(.),
      '^flat-down$') or matches(normalize-space(.), '^flat-up$') or
      matches(normalize-space(.), '^natural-down$') or matches(normalize-space(.),
      '^natural-up$') or matches(normalize-space(.), '^sharp-down$') or
      matches(normalize-space(.), '^sharp-up$') or matches(normalize-space(.),
      '^triple-sharp$') or matches(normalize-space(.), '^triple-flat$') or
      matches(normalize-space(.), '^quarter-flat$') or matches(normalize-space(.),
      '^three-quarters-flat$') or matches(normalize-space(.), '^quarter-sharp$') or
      matches(normalize-space(.), '^three-quarters-sharp$'))">
      <xsl:if test="normalize-space() != ''">
        <xsl:variable name="measureNum">
          <xsl:value-of select="ancestor::measure/@number"/>
        </xsl:variable>
        <xsl:variable name="warning">
          <xsl:value-of select="concat(upper-case(substring($accidPlace, 6, 1)),
            substring($accidPlace, 7), '&#32;', 'accidental value (', ., ') not supported')"/>
        </xsl:variable>
        <xsl:message>
          <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
            ').'))"/>
        </xsl:message>
        <xsl:comment>
          <xsl:value-of select="normalize-space(concat($warning, '.'))"/>
        </xsl:comment>
      </xsl:if>
    </xsl:if>
    <!-- Include accidentals that apply to this ornament; that is,
    they follow this ornament, but precede any other ornament -->
    <xsl:for-each select="following-sibling::*[1]">
      <xsl:if test="local-name()='accidental-mark'">
        <xsl:apply-templates select="." mode="stage1.amlist"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="accidental-mark" mode="stage1.amlist.empty">
    <xsl:if test="normalize-space() = ''">
      <xsl:variable name="measureNum">
        <xsl:value-of select="ancestor::measure/@number"/>
      </xsl:variable>
      <xsl:variable name="warning">
        <xsl:text>Empty accidental-mark element not transcoded</xsl:text>
      </xsl:variable>
      <xsl:message>
        <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
          ').'))"/>
      </xsl:message>
      <xsl:comment>
        <xsl:value-of select="normalize-space(concat($warning, '.'))"/>
      </xsl:comment>
    </xsl:if>
    <xsl:for-each select="following-sibling::*[1]">
      <xsl:if test="local-name()='accidental-mark'">
        <xsl:apply-templates select="." mode="stage1.amlist.empty"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="attributes" mode="stage1">
    <!-- check for MusicXML attributes that don't begin a measure -->
    <xsl:if test="count(following-sibling::*[not(local-name()='barline')])=0 or
      preceding-sibling::note or preceding-sibling::forward or preceding-sibling::chord">
      <xsl:if test="divisions">
        <xsl:variable name="measureNum">
          <xsl:value-of select="ancestor::measure/@number"/>
        </xsl:variable>
        <xsl:variable name="errorMessage">
          <xsl:text>Cannot process mid-measure change of divisions</xsl:text>
        </xsl:variable>
        <xsl:message terminate="yes">
          <xsl:value-of select="normalize-space(concat($errorMessage, ' (m. ',
            $measureNum, ').'))"/>
        </xsl:message>
      </xsl:if>
      <xsl:if test="key">
        <xsl:variable name="measureNum">
          <xsl:value-of select="ancestor::measure/@number"/>
        </xsl:variable>
        <xsl:variable name="warning">
          <xsl:text>Mid-measure change of key and/or mode ignored</xsl:text>
        </xsl:variable>
        <xsl:message>
          <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
            ').'))"/>
        </xsl:message>
      </xsl:if>
      <xsl:if test="time">
        <xsl:variable name="measureNum">
          <xsl:value-of select="ancestor::measure/@number"/>
        </xsl:variable>
        <xsl:variable name="warning">
          <xsl:text>Mid-measure change of time signature ignored</xsl:text>
        </xsl:variable>
        <xsl:message>
          <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
            ').'))"/>
        </xsl:message>
      </xsl:if>
      <xsl:if test="staff-details/staff-lines">
        <xsl:variable name="measureNum">
          <xsl:value-of select="ancestor::measure/@number"/>
        </xsl:variable>
        <xsl:variable name="warning">
          <xsl:text>Mid-measure change of stafflines ignored</xsl:text>
        </xsl:variable>
        <xsl:message>
          <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
            ').'))"/>
        </xsl:message>
      </xsl:if>
      <xsl:for-each select="clef">
        <clef xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:attribute name="xml:id">
            <xsl:value-of select="generate-id()"/>
          </xsl:attribute>
          <xsl:variable name="partID">
            <xsl:value-of select="ancestor::part[1]/@id"/>
          </xsl:variable>
          <xsl:variable name="partStaff">
            <xsl:choose>
              <xsl:when test="@number">
                <xsl:value-of select="@number"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="part">
            <xsl:value-of select="$partID"/>
          </xsl:attribute>
          <xsl:attribute name="layer">
            <xsl:choose>
              <!-- Mid-measure attributes are preceded by note/rest -->
              <xsl:when test="following::note[1]/voice">
                <xsl:value-of select="following::note[1]/voice"/>
              </xsl:when>
              <!-- Measure-ending attributes have no following sibling notes -->
              <xsl:when test="preceding::note[1]/voice">
                <xsl:value-of select="preceding::note[1]/voice"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>1</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:attribute name="staff">
            <xsl:call-template name="getStaffNum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partStaff">
                <xsl:value-of select="$partStaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="tstamp">
            <xsl:call-template name="tstamp.ges2beat">
              <xsl:with-param name="tstamp.ges">
                <xsl:call-template name="getTimestamp.ges"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="tstamp.ges">
            <xsl:call-template name="getTimestamp.ges"/>
          </xsl:attribute>
          <xsl:attribute name="shape">
            <xsl:choose>
              <xsl:when test="sign='percussion'">
                <xsl:text>perc</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="sign"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:attribute name="line">
            <xsl:value-of select="line"/>
          </xsl:attribute>
          <xsl:if test="clef-octave-change">
            <xsl:if test="abs(number(clef-octave-change)) != 0">
              <xsl:attribute name="dis">
                <xsl:choose>
                  <xsl:when test="abs(number(clef-octave-change)) = 2">15</xsl:when>
                  <xsl:when test="abs(number(clef-octave-change)) = 1">8</xsl:when>
                </xsl:choose>
              </xsl:attribute>
              <xsl:attribute name="dis.place">
                <xsl:choose>
                  <xsl:when test="number(clef-octave-change) &lt; 0">
                    <xsl:text>below</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>above</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
            </xsl:if>
          </xsl:if>
        </clef>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template match="backup" mode="stage1">
    <!-- This is a no-op! Backup elements don't require any action in MEI. -->
  </xsl:template>

  <xsl:template match="credit-words[@default-y]">
    <anchoredText xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:if test="../credit-type">
        <xsl:attribute name="n" select="replace(normalize-space(../credit-type), '\s', '_')"/>
      </xsl:if>
      <xsl:attribute name="x">
        <xsl:value-of select="format-number(@default-x div 5, '###0.####')"/>
      </xsl:attribute>
      <xsl:attribute name="y">
        <xsl:value-of select="format-number(@default-y div 5, '###0.####')"/>
      </xsl:attribute>
      <xsl:variable name="content">
        <xsl:choose>
          <xsl:when test="matches(../credit-type, '^page number$') or matches(.,
            '^[0-9]+$')">
            <xsl:processing-instruction name="pageNum"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:choose>
              <xsl:when test="@xml:space='preserve'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="normalize-space(.)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="@font-family or @font-style or @font-size or @font-weight or @letter-spacing
          or @line-height or @justify or @halign or @valign or @color or @rotation or
          @xml:space or @underline or @overline or @line-through or @dir or
          @enclosure!='none'">
          <xsl:call-template name="wrapRend">
            <xsl:with-param name="in">
              <xsl:copy-of select="$content"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$content"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="following-sibling::credit-words[not(@default-y)]"/>
    </anchoredText>
  </xsl:template>

  <xsl:template match="credit-words[not(@default-y)]">
    <lb xmlns="http://www.music-encoding.org/ns/mei"/>
    <xsl:variable name="content">
      <xsl:choose>
        <xsl:when test="matches(../credit-type, '^page number$') or matches(.,
          '^[0-9]+$')">
          <xsl:processing-instruction name="pageNum"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="@xml:space='preserve'">
              <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="@font-family or @font-style or @font-size or @font-weight or @letter-spacing
        or @line-height or @justify or @halign or @valign or @color or @rotation or
        @xml:space or @underline or @overline or @line-through or @dir or
        @enclosure!='none'">
        <xsl:call-template name="wrapRend">
          <xsl:with-param name="in">
            <xsl:copy-of select="$content"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$content"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="defaults">
    <!-- Process various font options -->
    <xsl:for-each select="music-font">
      <xsl:attribute name="music.name">
        <xsl:value-of select="@font-family"/>
      </xsl:attribute>
      <xsl:attribute name="music.size">
        <xsl:value-of select="@font-size"/>
        <!-- <xsl:text>pt</xsl:text> -->
      </xsl:attribute>
    </xsl:for-each>
    <xsl:for-each select="word-font">
      <xsl:attribute name="text.name">
        <xsl:value-of select="@font-family"/>
      </xsl:attribute>
      <xsl:attribute name="text.size">
        <xsl:value-of select="@font-size"/>
        <!-- <xsl:text>pt</xsl:text> -->
      </xsl:attribute>
    </xsl:for-each>
    <xsl:for-each select="lyric-font">
      <xsl:attribute name="lyric.name">
        <xsl:value-of select="@font-family"/>
      </xsl:attribute>
      <xsl:attribute name="lyric.size">
        <xsl:value-of select="@font-size"/>
        <!-- <xsl:text>pt</xsl:text> -->
      </xsl:attribute>
    </xsl:for-each>
    <!-- The most useful measure of distance for layout purposes is a
      "virtual unit", which is defined as half the distance between the
      vertical center point of a staff line and that of an adjacent staff line.
      So that virtual unit values can be translated into real-world measurements
      later, the real-world height of a virtual unit must be recorded here. -->
    <xsl:for-each select="scaling">
      <xsl:variable name="mm">
        <xsl:value-of select="millimeters"/>
      </xsl:variable>
      <xsl:attribute name="vu.height">
        <xsl:value-of select="$mm div 8"/>
        <xsl:text>mm</xsl:text>
      </xsl:attribute>
    </xsl:for-each>
    <!-- Page layout options -->
    <xsl:for-each select="page-layout">
      <xsl:attribute name="page.height">
        <xsl:value-of select="format-number(page-height div 5, '###0.####')"/>
        <!-- <xsl:text>vu</xsl:text> -->
      </xsl:attribute>
      <xsl:attribute name="page.width">
        <xsl:value-of select="format-number(page-width div 5,'###0.####')"/>
        <!-- <xsl:text>vu</xsl:text> -->
      </xsl:attribute>
      <xsl:for-each select="page-margins[1]">
        <xsl:attribute name="page.leftmar">
          <xsl:value-of select="format-number(left-margin div 5, '###0.####')"/>
          <!-- <xsl:text>vu</xsl:text> -->
        </xsl:attribute>
        <xsl:attribute name="page.rightmar">
          <xsl:value-of select="format-number(right-margin div 5, '###0.####')"/>
          <!-- <xsl:text>vu</xsl:text> -->
        </xsl:attribute>
        <xsl:attribute name="page.topmar">
          <xsl:value-of select="format-number(top-margin div 5, '###0.####')"/>
          <!-- <xsl:text>vu</xsl:text> -->
        </xsl:attribute>
        <xsl:attribute name="page.botmar">
          <xsl:value-of select="format-number(bottom-margin div 5, '###0.####')"/>
          <!-- <xsl:text>vu</xsl:text> -->
        </xsl:attribute>
      </xsl:for-each>
    </xsl:for-each>
    <!-- System layout options -->
    <xsl:for-each select="system-layout">
      <xsl:for-each select="system-margins">
        <xsl:attribute name="system.leftmar">
          <xsl:value-of select="format-number(left-margin div 5, '###0.####')"/>
          <!-- <xsl:text>vu</xsl:text> -->
        </xsl:attribute>
        <xsl:attribute name="system.rightmar">
          <xsl:value-of select="format-number(right-margin div 5, '###0.####')"/>
          <!-- <xsl:text>vu</xsl:text> -->
        </xsl:attribute>
      </xsl:for-each>
      <xsl:for-each select="system-distance">
        <xsl:attribute name="spacing.system">
          <xsl:value-of select="format-number(. div 5, '###0.####')"/>
          <!-- <xsl:text>vu</xsl:text> -->
        </xsl:attribute>
      </xsl:for-each>
      <xsl:for-each select="top-system-distance">
        <xsl:attribute name="system.topmar">
          <xsl:value-of select="format-number(. div 5, '###0.####')"/>
          <!-- <xsl:text>vu</xsl:text> -->
        </xsl:attribute>
      </xsl:for-each>
    </xsl:for-each>
    <!-- Staff layout options -->
    <!-- The smallest value of staff-distance is used with the assumption
      that additional space can be added programmatically when necessary to
      avoid collisions. -->
    <xsl:if test="staff-layout">
      <xsl:attribute name="spacing.staff">
        <xsl:value-of select="format-number(min(staff-layout/staff-distance) div 5, '###0.####')"/>
        <!-- <xsl:text>vu</xsl:text> -->
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template match="direction" mode="stage1">
    <!-- Some MusicXML direction types are not handled yet. -->
    <xsl:for-each select="direction-type/accordion-registration |
      direction-type/bracket[@type='start'] | direction-type/dashes[@type='start'] |
      direction-type/eyeglasses | direction-type/harp-pedals | direction-type/image |
      direction-type/other-direction | direction-type/percussion | direction-type/scordatura |
      direction-type/string-mute">
      <xsl:variable name="dirType">
        <xsl:value-of select="local-name(.)"/>
      </xsl:variable>
      <xsl:variable name="measureNum">
        <xsl:value-of select="ancestor::measure/@number"/>
      </xsl:variable>
      <xsl:variable name="warning">
        <xsl:value-of select="concat(upper-case(substring($dirType, 1, 1)), substring($dirType,
          2))"/>
        <xsl:text> not transcoded</xsl:text>
      </xsl:variable>
      <xsl:message>
        <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
          ').'))"/>
      </xsl:message>
      <xsl:comment>
        <xsl:value-of select="normalize-space(concat($warning, '.'))"/>
      </xsl:comment>
    </xsl:for-each>
    <!-- Create appropriate elements for the directions that are processed -->
    <xsl:variable name="dirType">
      <xsl:choose>
        <xsl:when test="direction-type/dynamics | direction-type/words[matches(., '^cresc') or
          matches(., '^decresc') or matches(., '^diminuendo') or matches(., '^dim\.')]">
          <xsl:text>dynam</xsl:text>
        </xsl:when>
        <xsl:when test="direction-type/octave-shift[not(@type='stop')]">
          <xsl:text>octave</xsl:text>
        </xsl:when>
        <xsl:when test="direction-type/pedal[not(@type='continue')]">
          <xsl:text>pedal</xsl:text>
        </xsl:when>
        <xsl:when test="direction-type/rehearsal">
          <xsl:text>reh</xsl:text>
        </xsl:when>
        <xsl:when test="direction-type/metronome or sound[@tempo]">
          <xsl:text>tempo</xsl:text>
        </xsl:when>
        <xsl:when test="direction-type/wedge[not(@type='stop')]">
          <xsl:text>hairpin</xsl:text>
        </xsl:when>
        <xsl:when test="direction-type/words[text()] | direction-type/principal-voice |
          direction-type/coda | direction-type/segno">
          <xsl:text>dir</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>NULL</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$dirType != 'NULL'">
      <xsl:element name="{$dirType}" namespace="http://www.music-encoding.org/ns/mei">
        <xsl:if test="$dirType='dynam'">
          <xsl:attribute name="label">direction</xsl:attribute>
        </xsl:if>
        <xsl:call-template name="tstampAttrs"/>
        <!--<xsl:attribute name="startid">
          <xsl:value-of select="generate-id(following::note[1])"/>
        </xsl:attribute>-->
        <xsl:for-each select="direction-type/*[@relative-x or @relative-y][1]">
          <xsl:call-template name="positionRelative"/>
        </xsl:for-each>
        <xsl:if test="not($dirType = 'octave')">
          <xsl:attribute name="place">
            <xsl:choose>
              <xsl:when test="@placement">
                <xsl:value-of select="@placement"/>
              </xsl:when>
              <xsl:when test="$dirType = 'dynam' or $dirType = 'pedal' or $dirType = 'hairpin'">
                <xsl:text>below</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>above</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:if>
        <xsl:variable name="partID">
          <xsl:value-of select="ancestor::part[1]/@id"/>
        </xsl:variable>
        <xsl:variable name="partStaff">
          <xsl:choose>
            <xsl:when test="staff">
              <xsl:value-of select="staff"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="staff">
          <xsl:call-template name="getStaffNum">
            <xsl:with-param name="partID">
              <xsl:value-of select="$partID"/>
            </xsl:with-param>
            <xsl:with-param name="partStaff">
              <xsl:value-of select="$partStaff"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:attribute>
        <!-- direction-specific attributes -->
        <xsl:choose>
          <xsl:when test="$dirType = 'dynam'">
            <xsl:if test="sound[@dynamics &gt; 0]">
              <xsl:attribute name="val">
                <xsl:value-of select="round((sound/@dynamics * .01) * 90)"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$dirType = 'tempo'">
            <xsl:if test="direction-type/metronome/per-minute">
              <!-- Genuine metronome marking -->
              <xsl:if test="direction-type/metronome/beat-unit">
                <xsl:attribute name="mm.unit">
                  <xsl:for-each select="direction-type/metronome/beat-unit">
                    <xsl:call-template name="notatedDuration"/>
                  </xsl:for-each>
                </xsl:attribute>
              </xsl:if>
              <xsl:if test="direction-type/metronome/beat-unit-dot">
                <xsl:attribute name="mm.dots">
                  <xsl:value-of select="count(direction-type/metronome/beat-unit-dot)"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:attribute name="mm">
                <xsl:value-of select="direction-type/metronome/per-minute"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="sound[@tempo]">
              <xsl:attribute name="midi.tempo">
                <xsl:value-of select="round(sound[@tempo]/@tempo)"/>
                <xsl:if test="contains(sound/@tempo, '.')">
                  <xsl:variable name="measureNum">
                    <xsl:value-of select="ancestor::measure/@number"/>
                  </xsl:variable>
                  <xsl:variable name="warning">
                    <xsl:text>Sound/tempo value rounded to integer value</xsl:text>
                  </xsl:variable>
                  <xsl:message>
                    <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
                      ').'))"/>
                  </xsl:message>
                </xsl:if>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$dirType = 'octave'">
            <xsl:attribute name="dis">
              <xsl:choose>
                <xsl:when test="not(direction-type/octave-shift/@size)">
                  <xsl:value-of select="8"/>
                  <xsl:variable name="measureNum">
                    <xsl:value-of select="ancestor::measure/@number"/>
                  </xsl:variable>
                  <xsl:variable name="warning">
                    <xsl:text>Missing octave displacement value; defaulted to '8'</xsl:text>
                  </xsl:variable>
                  <xsl:message>
                    <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
                      ').'))"/>
                  </xsl:message>
                </xsl:when>
                <xsl:when test="direction-type/octave-shift/@size='8' or
                  direction-type/octave-shift/@size='15' or direction-type/octave-shift/@size='22'">
                  <xsl:value-of select="direction-type/octave-shift/@size"/>
                </xsl:when>
                <xsl:otherwise>
                  <!-- Bad value for @size; choose closest logical value -->
                  <xsl:variable name="newDispValue">
                    <xsl:choose>
                      <xsl:when test="(abs(direction-type/octave-shift/@size - 8) &lt;
                        abs(direction-type/octave-shift/@size - 15)) and
                        (abs(direction-type/octave-shift/@size - 8) &lt;
                        abs(direction-type/octave-shift/@size - 22))">
                        <!-- 8 is closest to the value of @size -->
                        <xsl:value-of select="8"/>
                      </xsl:when>
                      <xsl:when test="(abs(direction-type/octave-shift/@size - 15) &lt;
                        abs(direction-type/octave-shift/@size - 8)) and
                        (abs(direction-type/octave-shift/@size - 15) &lt;
                        abs(direction-type/octave-shift/@size - 22))">
                        <!-- 15 is closest to the value of @size -->
                        <xsl:value-of select="15"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <!-- 22 is closest to the value of @size -->
                        <xsl:value-of select="22"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <xsl:value-of select="$newDispValue"/>
                  <xsl:variable name="measureNum">
                    <xsl:value-of select="ancestor::measure/@number"/>
                  </xsl:variable>
                  <xsl:variable name="warning">
                    <xsl:value-of select="concat('Unknown octave displacement value; substituted
                      &quot;', $newDispValue, '&quot;')"/>
                  </xsl:variable>
                  <xsl:message>
                    <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
                      ').'))"/>
                  </xsl:message>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="dis.place">
              <xsl:choose>
                <xsl:when test="direction-type/octave-shift/@type='up'">below</xsl:when>
                <xsl:when test="direction-type/octave-shift/@type='down'">above</xsl:when>
              </xsl:choose>
            </xsl:attribute>
          </xsl:when>
          <xsl:when test="$dirType = 'pedal'">
            <xsl:attribute name="dir">
              <xsl:choose>
                <xsl:when test="direction-type/pedal/@type='start'">down</xsl:when>
                <xsl:when test="direction-type/pedal/@type='stop'">up</xsl:when>
                <xsl:when test="direction-type/pedal/@type='change'">bounce</xsl:when>
              </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="style">
              <xsl:choose>
                <xsl:when test="direction-type/pedal/@line='yes'">line</xsl:when>
                <xsl:otherwise>pedstar</xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </xsl:when>
          <xsl:when test="$dirType = 'hairpin'">
            <xsl:choose>
              <xsl:when test="direction-type/wedge/@type='crescendo'">
                <xsl:attribute name="form">cres</xsl:attribute>
              </xsl:when>
              <xsl:when test="direction-type/wedge/@type='diminuendo'">
                <xsl:attribute name="form">dim</xsl:attribute>
                <xsl:if test="direction-type/wedge/@spread">
                  <xsl:attribute name="opening">
                    <xsl:value-of select="format-number(direction-type/wedge/@spread div 5,
                      '###0.####')"/>
                  </xsl:attribute>
                </xsl:if>
              </xsl:when>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
        <!-- attributes based on end marker -->
        <xsl:variable name="startMeasureID">
          <xsl:value-of select="generate-id(ancestor::measure[1])"/>
        </xsl:variable>
        <xsl:variable name="startMeasurePos">
          <xsl:for-each select="//measure">
            <xsl:if test="generate-id()=$startMeasureID">
              <xsl:value-of select="position()"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="partID">
          <xsl:value-of select="ancestor::part/@id"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$dirType = 'octave'">
            <xsl:choose>
              <xsl:when test="direction-type/octave-shift/@number">
                <xsl:variable name="octaveNum">
                  <xsl:value-of select="direction-type/octave-shift/@number"/>
                </xsl:variable>
                <xsl:for-each
                  select="following::direction[direction-type/octave-shift[@number=$octaveNum
                  and @type='stop'] and ancestor::part/@id=$partID][1]">
                  <xsl:variable name="endMeasureID">
                    <xsl:value-of select="generate-id(ancestor::measure[1])"/>
                  </xsl:variable>
                  <xsl:variable name="endMeasurePos">
                    <xsl:for-each select="//measure">
                      <xsl:if test="generate-id()=$endMeasureID">
                        <xsl:value-of select="position()"/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:variable>
                  <xsl:variable name="endGestural">
                    <xsl:call-template name="getTimestamp.ges"/>
                  </xsl:variable>
                  <xsl:variable name="endBeat">
                    <xsl:call-template name="tstamp.ges2beat">
                      <xsl:with-param name="tstamp.ges">
                        <xsl:choose>
                          <!-- Using <offset> instead of @default-x -->
                          <xsl:when test="number(offset)">
                            <xsl:value-of select="format-number(number($endGestural) +
                              number(offset), '###0.###')"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="number($endGestural)"/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:variable>
                  <xsl:attribute name="tstamp2">
                    <xsl:value-of select="$endMeasurePos - $startMeasurePos"/>
                    <xsl:text>m+</xsl:text>
                    <xsl:value-of select="$endBeat"/>
                  </xsl:attribute>
                  <xsl:attribute name="endid">
                    <xsl:value-of select="generate-id(preceding::note[1])"/>
                  </xsl:attribute>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <!-- End of octave-shift follows start -->
                  <xsl:when test="following::direction[direction-type/octave-shift[@type='stop']
                    and ancestor::part/@id=$partID]">
                    <xsl:for-each
                      select="following::direction[direction-type/octave-shift[@type='stop']
                      and ancestor::part/@id=$partID][1]">
                      <xsl:variable name="endMeasureID">
                        <xsl:value-of select="generate-id(ancestor::measure[1])"/>
                      </xsl:variable>
                      <xsl:variable name="endMeasurePos">
                        <xsl:for-each select="//measure">
                          <xsl:if test="generate-id()=$endMeasureID">
                            <xsl:value-of select="position()"/>
                          </xsl:if>
                        </xsl:for-each>
                      </xsl:variable>
                      <xsl:variable name="endMeasureID">
                        <xsl:value-of select="generate-id(ancestor::measure[1])"/>
                      </xsl:variable>
                      <xsl:variable name="endMeasurePos">
                        <xsl:for-each select="//measure">
                          <xsl:if test="generate-id()=$endMeasureID">
                            <xsl:value-of select="position()"/>
                          </xsl:if>
                        </xsl:for-each>
                      </xsl:variable>
                      <xsl:variable name="endGestural">
                        <xsl:call-template name="getTimestamp.ges"/>
                      </xsl:variable>
                      <xsl:variable name="endBeat">
                        <xsl:call-template name="tstamp.ges2beat">
                          <xsl:with-param name="tstamp.ges">
                            <xsl:choose>
                              <!-- Using <offset> instead of @default-x -->
                              <xsl:when test="number(offset)">
                                <xsl:value-of select="format-number(number($endGestural) +
                                  number(offset), '###0.###')"/>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:value-of select="number($endGestural)"/>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:with-param>
                        </xsl:call-template>
                      </xsl:variable>
                      <xsl:attribute name="tstamp2">
                        <xsl:value-of select="$endMeasurePos - $startMeasurePos"/>
                        <xsl:text>m+</xsl:text>
                        <xsl:value-of select="$endBeat"/>
                      </xsl:attribute>
                      <xsl:attribute name="endid">
                        <xsl:value-of select="generate-id(preceding::note[1])"/>
                      </xsl:attribute>
                      <xsl:variable name="measureNum">
                        <xsl:value-of select="ancestor::measure/@number"/>
                      </xsl:variable>
                      <xsl:variable name="warning">
                        <xsl:text>End point of octave shift may not be accurate</xsl:text>
                      </xsl:variable>
                      <xsl:message>
                        <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
                          ').'))"/>
                      </xsl:message>
                      <xsl:comment>
                        <xsl:value-of select="normalize-space(concat($warning, '.'))"/>
                      </xsl:comment>
                    </xsl:for-each>
                  </xsl:when>
                  <!-- End of octave-shift precedes start -->
                  <xsl:otherwise>
                    <xsl:for-each
                      select="preceding::direction[direction-type/octave-shift[@type='stop']
                      and ancestor::part/@id=$partID][1]">
                      <xsl:variable name="endMeasureID">
                        <xsl:value-of select="generate-id(ancestor::measure[1])"/>
                      </xsl:variable>
                      <xsl:variable name="endMeasurePos">
                        <xsl:for-each select="//measure">
                          <xsl:if test="generate-id()=$endMeasureID">
                            <xsl:value-of select="position()"/>
                          </xsl:if>
                        </xsl:for-each>
                      </xsl:variable>
                      <xsl:variable name="endMeasureID">
                        <xsl:value-of select="generate-id(ancestor::measure[1])"/>
                      </xsl:variable>
                      <xsl:variable name="endMeasurePos">
                        <xsl:for-each select="//measure">
                          <xsl:if test="generate-id()=$endMeasureID">
                            <xsl:value-of select="position()"/>
                          </xsl:if>
                        </xsl:for-each>
                      </xsl:variable>
                      <xsl:variable name="endGestural">
                        <xsl:call-template name="getTimestamp.ges"/>
                      </xsl:variable>
                      <xsl:variable name="endBeat">
                        <xsl:call-template name="tstamp.ges2beat">
                          <xsl:with-param name="tstamp.ges">
                            <xsl:choose>
                              <!-- Using <offset> instead of @default-x -->
                              <xsl:when test="number(offset)">
                                <xsl:value-of select="format-number(number($endGestural) +
                                  number(offset), '###0.###')"/>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:value-of select="number($endGestural)"/>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:with-param>
                        </xsl:call-template>
                      </xsl:variable>
                      <xsl:attribute name="tstamp2">
                        <xsl:value-of select="$endMeasurePos - $startMeasurePos"/>
                        <xsl:text>m+</xsl:text>
                        <xsl:value-of select="$endBeat"/>
                      </xsl:attribute>
                      <xsl:attribute name="endid">
                        <xsl:value-of select="generate-id(preceding::note[1])"/>
                      </xsl:attribute>
                      <xsl:variable name="measureNum">
                        <xsl:value-of select="ancestor::measure/@number"/>
                      </xsl:variable>
                      <xsl:variable name="warning">
                        <xsl:text>End point of octave shift may not be accurate</xsl:text>
                      </xsl:variable>
                      <xsl:message>
                        <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
                          ').'))"/>
                      </xsl:message>
                      <xsl:comment>
                        <xsl:value-of select="normalize-space(concat($warning, '.'))"/>
                      </xsl:comment>
                    </xsl:for-each>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$dirType = 'hairpin'">
            <xsl:variable name="hairpinForm">
              <xsl:value-of select="direction-type/wedge/@type"/>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="direction-type/wedge/@number">
                <xsl:variable name="hairpinNum">
                  <xsl:value-of select="direction-type/wedge/@number"/>
                </xsl:variable>
                <xsl:for-each select="following::direction[direction-type/wedge[@number=$hairpinNum
                  and @type='stop'] and ancestor::part/@id=$partID][1]">
                  <xsl:variable name="endMeasureID">
                    <xsl:value-of select="generate-id(ancestor::measure[1])"/>
                  </xsl:variable>
                  <xsl:variable name="endMeasurePos">
                    <xsl:for-each select="//measure">
                      <xsl:if test="generate-id()=$endMeasureID">
                        <xsl:value-of select="position()"/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:variable>
                  <xsl:variable name="endGestural">
                    <xsl:call-template name="getTimestamp.ges"/>
                  </xsl:variable>
                  <xsl:variable name="endBeat">
                    <xsl:call-template name="tstamp.ges2beat">
                      <xsl:with-param name="tstamp.ges">
                        <xsl:choose>
                          <!-- Using <offset> instead of @default-x -->
                          <xsl:when test="number(offset)">
                            <xsl:value-of select="format-number(number($endGestural) +
                              number(offset), '###0.###')"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="number($endGestural)"/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:variable>
                  <xsl:attribute name="tstamp2">
                    <xsl:value-of select="$endMeasurePos - $startMeasurePos"/>
                    <xsl:text>m+</xsl:text>
                    <xsl:value-of select="$endBeat"/>
                  </xsl:attribute>
                  <xsl:attribute name="endid">
                    <xsl:value-of select="generate-id(preceding::note[1])"/>
                  </xsl:attribute>
                  <xsl:if test="direction-type/wedge/@spread and $hairpinForm = 'crescendo'">
                    <xsl:attribute name="opening">
                      <xsl:value-of select="format-number(direction-type/wedge/@spread div 5,
                        '###0.####')"/>
                    </xsl:attribute>
                  </xsl:if>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:for-each select="following::direction[direction-type/wedge[@type='stop'] and
                  ancestor::part/@id=$partID][1]">
                  <xsl:variable name="endMeasureID">
                    <xsl:value-of select="generate-id(ancestor::measure[1])"/>
                  </xsl:variable>
                  <xsl:variable name="endMeasurePos">
                    <xsl:for-each select="//measure">
                      <xsl:if test="generate-id()=$endMeasureID">
                        <xsl:value-of select="position()"/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:variable>
                  <xsl:variable name="endMeasureID">
                    <xsl:value-of select="generate-id(ancestor::measure[1])"/>
                  </xsl:variable>
                  <xsl:variable name="endMeasurePos">
                    <xsl:for-each select="//measure">
                      <xsl:if test="generate-id()=$endMeasureID">
                        <xsl:value-of select="position()"/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:variable>
                  <xsl:variable name="endGestural">
                    <xsl:call-template name="getTimestamp.ges"/>
                  </xsl:variable>
                  <xsl:variable name="endBeat">
                    <xsl:call-template name="tstamp.ges2beat">
                      <xsl:with-param name="tstamp.ges">
                        <xsl:choose>
                          <!-- Using <offset> instead of @default-x -->
                          <xsl:when test="number(offset)">
                            <xsl:value-of select="format-number(number($endGestural) +
                              number(offset), '###0.###')"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:value-of select="number($endGestural)"/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:variable>
                  <xsl:attribute name="tstamp2">
                    <xsl:value-of select="$endMeasurePos - $startMeasurePos"/>
                    <xsl:text>m+</xsl:text>
                    <xsl:value-of select="$endBeat"/>
                  </xsl:attribute>
                  <xsl:attribute name="endid">
                    <xsl:value-of select="generate-id(preceding::note[1])"/>
                  </xsl:attribute>
                  <xsl:if test="direction-type/wedge/@spread and $hairpinForm = 'crescendo'">
                    <xsl:attribute name="opening">
                      <xsl:value-of select="format-number(direction-type/wedge/@spread div 5,
                        '###0.####')"/>
                    </xsl:attribute>
                  </xsl:if>
                </xsl:for-each>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
        <!-- directives with content -->
        <xsl:if test="$dirType = 'dynam' or $dirType = 'dir' or $dirType = 'reh' or $dirType =
          'tempo'">
          <!-- Remove this warning once midi.tempo allows decimal values! -->
          <xsl:if test="$dirType = 'tempo' and contains(sound/@tempo, '.')">
            <xsl:variable name="warning">
              <xsl:text>midi.tempo value rounded to integer value</xsl:text>
            </xsl:variable>
            <xsl:comment>
              <xsl:value-of select="normalize-space(concat($warning, '.'))"/>
            </xsl:comment>
          </xsl:if>
          <xsl:if test="$dirType = 'dir'">
            <xsl:attribute name="label">
              <xsl:variable name="dirTypes">
                <xsl:for-each select="direction-type/*">
                  <xsl:sort select="local-name()"/>
                  <xsl:copy-of select="."/>
                </xsl:for-each>
              </xsl:variable>
              <xsl:variable name="dirLabel">
                <xsl:for-each select="$dirTypes/*">
                  <xsl:if test="local-name() != local-name(preceding-sibling::*[1])">
                    <xsl:value-of select="local-name()"/>
                    <xsl:if test="position() != last()">
                      <xsl:text>&#32;</xsl:text>
                    </xsl:if>
                  </xsl:if>
                </xsl:for-each>
              </xsl:variable>
              <xsl:value-of select="$dirLabel"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates select="direction-type/*" mode="stage1"/>
        </xsl:if>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="direction-type/coda | direction-type/dynamics | direction-type/metronome
    | direction-type/principal-voice | direction-type/rehearsal | direction-type/segno |
    direction-type/words" mode="stage1">
    <xsl:variable name="content">
      <xsl:choose>
        <xsl:when test="local-name() = 'coda'">
          <xsl:text>&#x1D10C;</xsl:text>
          <xsl:comment>[coda]</xsl:comment>
        </xsl:when>
        <xsl:when test="local-name() = 'dynamics'">
          <xsl:for-each select="*">
            <xsl:choose>
              <xsl:when test="local-name()='other-dynamics'">
                <xsl:value-of select="."/>
                <xsl:if test="position() != last()">
                  <xsl:text>&#32;</xsl:text>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="local-name()"/>
                <xsl:if test="position() != last()">
                  <xsl:text>&#32;</xsl:text>
                </xsl:if>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="local-name() = 'metronome'">
          <xsl:if test="@parentheses='yes'">
            <xsl:text>(</xsl:text>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="count(beat-unit) &gt; 1">
              <!-- Metric modulation -->
              <xsl:for-each select="beat-unit[1]">
                <xsl:call-template name="notatedDurationUnicode"/>
                <xsl:for-each
                  select="following-sibling::beat-unit-dot[count(preceding-sibling::beat-unit) = 1]">
                  <xsl:text>&#x1D16D;</xsl:text>
                  <xsl:comment>[dot]</xsl:comment>
                </xsl:for-each>
              </xsl:for-each>
              <xsl:text>=</xsl:text>
              <xsl:for-each select="beat-unit[2]">
                <xsl:call-template name="notatedDurationUnicode"/>
                <xsl:for-each select="following-sibling::beat-unit-dot">
                  <xsl:text>&#x1D16D;</xsl:text>
                  <xsl:comment>[dot]</xsl:comment>
                </xsl:for-each>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <!-- Metronome marking -->
              <xsl:for-each select="beat-unit">
                <xsl:call-template name="notatedDurationUnicode"/>
              </xsl:for-each>
              <xsl:for-each select="beat-unit-dot">
                <xsl:text>&#x1D16D;</xsl:text>
                <xsl:comment>[dot]</xsl:comment>
              </xsl:for-each>
              <xsl:text>=</xsl:text>
              <xsl:value-of select="per-minute"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="@parentheses='yes'">
            <xsl:text>)</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:when test="local-name() = 'principal-voice'">
          <xsl:choose>
            <xsl:when test="@type='start' and @symbol='Hauptstimme'">
              <xsl:text>&#x1D1A6;</xsl:text>
              <xsl:comment>[Hauptstimme]</xsl:comment>
            </xsl:when>
            <xsl:when test="@type='start' and @symbol='Nebenstimme'">
              <xsl:text>&#x1D1A7;</xsl:text>
              <xsl:comment>[Nebenstimme]</xsl:comment>
            </xsl:when>
            <xsl:when test="@type='start' and @symbol='plain'">
              <xsl:text>&#x250C;</xsl:text>
              <xsl:comment>[bracket begin]</xsl:comment>
            </xsl:when>
            <xsl:when test="@type='stop'">
              <xsl:text>&#x2510;</xsl:text>
              <xsl:comment>[bracket end]</xsl:comment>
            </xsl:when>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="local-name() = 'rehearsal'">
          <xsl:choose>
            <xsl:when test="@xml-space='preserve'">
              <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="ancestor::direction-type[following-sibling::direction-type[not(dashes) and
            not(bracket)]]">
            <xsl:text>&#32;</xsl:text>
          </xsl:if>
        </xsl:when>
        <xsl:when test="local-name() = 'segno'">
          <xsl:text>&#x1D10B;</xsl:text>
          <xsl:comment>[segno]</xsl:comment>
        </xsl:when>
        <xsl:when test="local-name() = 'words'">
          <xsl:choose>
            <xsl:when test="@xml-space='preserve'">
              <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="ancestor::direction-type[following-sibling::direction-type[not(dashes) and
            not(bracket)]]">
            <xsl:text>&#32;</xsl:text>
          </xsl:if>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="@font-family or @font-style or @font-size or @font-weight or @letter-spacing
        or @line-height or @justify or @halign or @valign or @color or @rotation or
        @xml:space or @underline or @overline or @line-through or @dir or @enclosure!='none' or
        (local-name()='rehearsal' and not(@enclosure))">
        <xsl:call-template name="wrapRend">
          <xsl:with-param name="in">
            <xsl:copy-of select="$content"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$content"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="figured-bass" mode="stage1">
    <!-- Handle figured-bass indications -->
    <harm xmlns="http://www.music-encoding.org/ns/mei">
      <!-- Tstamp attributes -->
      <xsl:call-template name="tstampAttrs"/>
      <!-- MusicXML doesn't allow @placement on figured-bass -->
      <xsl:attribute name="place">
        <xsl:text>below</xsl:text>
      </xsl:attribute>
      <xsl:variable name="partID">
        <xsl:value-of select="ancestor::part[1]/@id"/>
      </xsl:variable>
      <xsl:variable name="partStaff">1</xsl:variable>
      <xsl:attribute name="staff">
        <xsl:call-template name="getStaffNum">
          <xsl:with-param name="partID">
            <xsl:value-of select="$partID"/>
          </xsl:with-param>
          <xsl:with-param name="partStaff">
            <xsl:value-of select="$partStaff"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:call-template name="positionRelative"/>
      <fb>
        <xsl:for-each select="figure">
          <f>
            <xsl:if test="extend">
              <xsl:attribute name="extender">
                <xsl:text>true</xsl:text>
              </xsl:attribute>
            </xsl:if>
            <xsl:variable name="content">
              <xsl:if test="../@parentheses='yes'">
                <xsl:text>(</xsl:text>
              </xsl:if>
              <xsl:call-template name="figure"/>
              <xsl:if test="../@parentheses='yes'">
                <xsl:text>)</xsl:text>
              </xsl:if>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="ancestor::figured-bass[@font-family or @font-style or @font-size or
                @font-weight or @letter-spacing or @line-height or @justify or @halign
                or @valign or @color or @rotation or @xml:space or @underline or
                @overline or @line-through or @dir or @enclosure!='none']">
                <xsl:for-each select="ancestor::figured-bass">
                  <xsl:call-template name="wrapRend">
                    <xsl:with-param name="in">
                      <xsl:copy-of select="$content"/>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy-of select="$content"/>
              </xsl:otherwise>
            </xsl:choose>
          </f>
        </xsl:for-each>
      </fb>
    </harm>
  </xsl:template>

  <xsl:template match="forward" mode="stage1">
    <!-- Forward skips in time have to be filled with space in MEI when 
         they are followed by events; i.e., notes -->
    <xsl:if test="following-sibling::note">
      <xsl:variable name="thisPart">
        <xsl:value-of select="ancestor::part/@id"/>
      </xsl:variable>
      <xsl:variable name="ppq">
        <xsl:choose>
          <xsl:when test="ancestor::part[attributes/divisions]">
            <xsl:value-of select="ancestor::part[attributes/divisions]/attributes/divisions"/>
          </xsl:when>
          <xsl:when test="preceding::part[@id=$thisPart and attributes/divisions]">
            <xsl:value-of select="preceding::part[@id=$thisPart and
              attributes/divisions][1]/attributes/divisions"/>
          </xsl:when>
          <xsl:when test="following::part[@id=$thisPart and attributes/divisions]">
            <xsl:value-of select="following::part[@id=$thisPart and
              attributes/divisions][1]/attributes/divisions"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$scorePPQ"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="meterCount">
        <xsl:choose>
          <xsl:when test="ancestor::part[attributes/time/beats]/attributes/time/beats">
            <xsl:value-of
              select="saxon:evaluate(ancestor::part[attributes/time/beats]/attributes/time/beats)"/>
          </xsl:when>
          <xsl:when test="preceding::part[@id=$thisPart and attributes/time]">
            <xsl:value-of select="saxon:evaluate(preceding::part[@id=$thisPart and
              attributes/time][1]/attributes/time/beats)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="sum(ancestor::part/note/duration) div $ppq"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="meterUnit">
        <xsl:choose>
          <xsl:when test="ancestor::part[@id=$thisPart and
            attributes/time/beat-type]/attributes/time/beat-type">
            <xsl:value-of select="ancestor::part[@id=$thisPart and
              attributes/time/beat-type]/attributes/time/beat-type"/>
          </xsl:when>
          <xsl:when test="preceding::part[@id=$thisPart and attributes/time]">
            <xsl:value-of select="preceding::part[@id=$thisPart and
              attributes/time][1]/attributes/time/beat-type"/>
          </xsl:when>
          <xsl:otherwise>4</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="measureDuration">
        <xsl:call-template name="measureDuration">
          <xsl:with-param name="meterCount">
            <xsl:value-of select="$meterCount"/>
          </xsl:with-param>
          <xsl:with-param name="meterUnit">
            <xsl:value-of select="$meterUnit"/>
          </xsl:with-param>
          <xsl:with-param name="ppq">
            <xsl:value-of select="$ppq"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="spaceType">
        <xsl:choose>
          <xsl:when test="duration = $measureDuration">
            <xsl:text>mSpace</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>space</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:element name="{$spaceType}" xmlns="http://www.music-encoding.org/ns/mei">
        <xsl:attribute name="xml:id">
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
        <xsl:attribute name="tstamp.ges">
          <xsl:call-template name="getTimestamp.ges"/>
        </xsl:attribute>

        <!-- The duration of the space in musical terms isn't required for the conversion of 
          MusicXML to MEI, but it may be necessary for processing the MEI file. -->
        <xsl:variable name="dur">
          <xsl:call-template name="quantizedDuration">
            <xsl:with-param name="duration">
              <xsl:value-of select="duration"/>
            </xsl:with-param>
            <xsl:with-param name="ppq">
              <xsl:value-of select="$ppq"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="matches($dur, '\.')">
            <xsl:attribute name="dur">
              <xsl:value-of select="substring-before($dur, '.')"/>
            </xsl:attribute>
            <xsl:attribute name="dots">
              <xsl:value-of select="string-length(substring-after($dur, substring-before($dur,
                '.')))"/>
            </xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="dur">
              <xsl:value-of select="$dur"/>
            </xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="gesturalDuration"/>
        <xsl:call-template name="assignPart-Layer-Staff-Beam-Tuplet"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template match="harmony" mode="stage1">
    <!-- Handle harmony indications -->
    <harm xmlns="http://www.music-encoding.org/ns/mei">
      <!-- Tstamp attributes -->
      <xsl:call-template name="tstampAttrs"/>
      <xsl:attribute name="place">
        <xsl:choose>
          <xsl:when test="@placement">
            <xsl:value-of select="@placement"/>
          </xsl:when>
          <xsl:otherwise>above</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:variable name="partID">
        <xsl:value-of select="ancestor::part[1]/@id"/>
      </xsl:variable>
      <xsl:variable name="partStaff">1</xsl:variable>
      <xsl:attribute name="staff">
        <xsl:call-template name="getStaffNum">
          <xsl:with-param name="partID">
            <xsl:value-of select="$partID"/>
          </xsl:with-param>
          <xsl:with-param name="partStaff">
            <xsl:value-of select="$partStaff"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:call-template name="positionRelative"/>
      <xsl:variable name="content">
        <xsl:call-template name="harmLabel"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="@font-family or @font-style or @font-size or @font-weight or @letter-spacing
          or @line-height or @justify or @halign or @valign or @color or @rotation or
          @xml:space or @underline or @overline or @line-through or @dir or
          @enclosure!='none'">
          <xsl:call-template name="wrapRend">
            <xsl:with-param name="in">
              <xsl:copy-of select="$content"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$content"/>
        </xsl:otherwise>
      </xsl:choose>
    </harm>
  </xsl:template>

  <xsl:template match="lyric" mode="stage1">
    <!-- Lyric sub-elements of note -->
    <verse xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:attribute name="n">
        <xsl:choose>
          <xsl:when test="@number">
            <xsl:value-of select="@number"/>
          </xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>

      <!-- Relative vertical placement attributes go on verse -->
      <xsl:if test="@relative-y">
        <xsl:attribute name="vo">
          <xsl:value-of select="format-number(@relative-y div 5, '###0.####')"/>
          <!-- <xsl:text>vu</xsl:text> -->
        </xsl:attribute>
      </xsl:if>

      <xsl:for-each select="text">
        <syl>
          <xsl:choose>
            <xsl:when test="../syllabic='begin'">
              <xsl:attribute name="wordpos">i</xsl:attribute>
              <xsl:attribute name="con">d</xsl:attribute>
            </xsl:when>
            <xsl:when test="../syllabic='middle'">
              <xsl:attribute name="wordpos">m</xsl:attribute>
              <xsl:attribute name="con">d</xsl:attribute>
            </xsl:when>
            <xsl:when test="../syllabic='end'">
              <xsl:attribute name="wordpos">t</xsl:attribute>
              <xsl:if test="../extend">
                <xsl:attribute name="con">u</xsl:attribute>
              </xsl:if>
            </xsl:when>
            <xsl:when test="../syllabic='single'">
              <xsl:if test="../extend">
                <xsl:attribute name="con">u</xsl:attribute>
              </xsl:if>
            </xsl:when>
          </xsl:choose>

          <!-- Horizontal placement attributes go on syl -->
          <xsl:if test="../@default-x">
            <xsl:attribute name="x">
              <xsl:value-of select="format-number(../@default-x div 5, '###0.####')"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="../@relative-x">
            <xsl:attribute name="ho">
              <xsl:value-of select="format-number(../@relative-x div 5, '###0.####')"/>
              <!-- <xsl:text>vu</xsl:text> -->
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="../@justify">
            <xsl:attribute name="halign">
              <xsl:value-of select="../@justify"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:call-template name="fontProperties"/>
          <xsl:call-template name="color"/>
          <xsl:value-of select="."/>
        </syl>
      </xsl:for-each>
      <xsl:if test="end-line">
        <lb/>
      </xsl:if>
      <xsl:if test="end-paragraph">
        <lb type="end-paragraph"/>
      </xsl:if>
    </verse>
  </xsl:template>

  <xsl:template match="measure" mode="measContent">
    <!-- Process each measure -->
    <!-- Page breaks and system breaks precede the measure. -->
    <xsl:if test="part[print/@new-page='yes']">
      <pb xmlns="http://www.music-encoding.org/ns/mei">
        <xsl:if test="normalize-space(part[print/@new-page='yes'][1]/print/@page-number) != ''">
          <xsl:attribute name="n">
            <xsl:value-of select="part[print/@new-page='yes'][1]/print/@page-number"/>
          </xsl:attribute>
        </xsl:if>
      </pb>
    </xsl:if>
    <xsl:if test="part[print/@new-system='yes']">
      <sb xmlns="http://www.music-encoding.org/ns/mei"/>
    </xsl:if>

    <!-- Score-level info precedes the measure. -->
    <xsl:if test="part/attributes[not(preceding-sibling::note) and
      not(preceding-sibling::forward)][time or key] | part[print[page-layout or
      system-layout]]">
      <scoreDef xmlns="http://www.music-encoding.org/ns/mei">
        <!-- Time signature -->
        <xsl:if test="count(preceding::measure) &gt; 0">
          <!-- Ignore time signature in the first measure since it's already been recorded in /score/scoreDef. -->
          <xsl:if test="part/attributes[1]/time">
            <xsl:if test="part/attributes[1]/time/senza-misura">
              <xsl:attribute name="meter.rend">invis</xsl:attribute>
            </xsl:if>
            <xsl:if test="count(part/attributes/time/beats) = 1">
              <!-- simple time signature -->
              <xsl:attribute name="meter.count">
                <xsl:value-of
                  select="part[attributes/time/beats][1]/attributes[time/beats][1]/time/beats"/>
              </xsl:attribute>
              <xsl:attribute name="meter.unit">
                <xsl:value-of
                  select="part[attributes/time/beats][1]/attributes[time/beats][1]/time/beat-type"/>
              </xsl:attribute>
              <xsl:choose>
                <xsl:when test="part/attributes[1]/time/@symbol='common'">
                  <xsl:attribute name="meter.sym">common</xsl:attribute>
                  <xsl:if test="not(part[attributes[1]/time/@symbol]/attributes/time/beats=4) or
                    not(part[attributes[1]/time/@symbol]/attributes/time/beat-type=4)">
                    <xsl:variable name="measureNum">
                      <xsl:value-of select="@number"/>
                    </xsl:variable>
                    <xsl:variable name="warning">
                      <xsl:text>Common time symbol does not match time signature</xsl:text>
                    </xsl:variable>
                    <xsl:message>
                      <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
                        ').'))"/>
                    </xsl:message>
                  </xsl:if>
                </xsl:when>
                <xsl:when test="part/attributes[1]/time/@symbol='cut'">
                  <xsl:attribute name="meter.sym">cut</xsl:attribute>
                  <xsl:if test="not(part[attributes[1]/time/@symbol]/attributes/time/beats=2) or
                    not(part[attributes[1]/time/@symbol]/attributes/time/beat-type=2)">
                    <xsl:variable name="measureNum">
                      <xsl:value-of select="@number"/>
                    </xsl:variable>
                    <xsl:variable name="warning">
                      <xsl:text>Cut time symbol does not match time signature</xsl:text>
                    </xsl:variable>
                    <xsl:message>
                      <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
                        ').'))"/>
                    </xsl:message>
                  </xsl:if>
                </xsl:when>
                <xsl:when test="part/attributes[1]/time/@symbol='single-number'">
                  <xsl:attribute name="meter.rend">num</xsl:attribute>
                </xsl:when>
              </xsl:choose>
            </xsl:if>
          </xsl:if>
        </xsl:if>

        <!-- Key signature -->
        <xsl:if test="count(preceding::measure) &gt; 0">
          <!-- Ignore key signature in the first measure since it's already been recorded in /score/scoreDef. -->
          <xsl:if test="part/attributes[not(preceding-sibling::note) and
            not(preceding-sibling::forward) and not(transpose)][key/key-step]">
            <xsl:variable name="measureNum">
              <xsl:value-of select="@number"/>
            </xsl:variable>
            <xsl:variable name="warning">
              <xsl:text>Non-traditional key signature not transcoded (score)</xsl:text>
            </xsl:variable>
            <xsl:message>
              <xsl:value-of select="normalize-space(concat($warning, ' (m.', $measureNum, ').'))"/>
            </xsl:message>
          </xsl:if>
          <xsl:if test="part/attributes[not(preceding-sibling::note) and
            not(preceding-sibling::forward) and not(transpose)][key]">
            <xsl:variable name="keySig">
              <xsl:value-of select="part[attributes[not(preceding-sibling::note) and
                not(preceding-sibling::forward) and not
                (transpose)]/key[not(@number)]][1]/attributes[not(preceding-sibling::note) and
                not(preceding-sibling::forward) and not (transpose)]/key[not(@number)][1]/fifths"/>
            </xsl:variable>
            <!-- Key mode -->
            <xsl:variable name="scoreMode">
              <xsl:value-of select="attributes[not(transpose) and key][1]/key[1]/mode"/>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$keySig=''">
                <xsl:attribute name="key.sig">
                  <xsl:text>0</xsl:text>
                </xsl:attribute>
              </xsl:when>
              <xsl:when test="number($keySig)=0">
                <xsl:attribute name="key.sig">
                  <xsl:value-of select="$keySig"/>
                </xsl:attribute>
              </xsl:when>
              <xsl:when test="number($keySig) &gt; 0">
                <xsl:attribute name="key.sig"><xsl:value-of select="$keySig"/>s</xsl:attribute>
              </xsl:when>
              <xsl:when test="number($keySig) &lt; 0">
                <xsl:attribute name="key.sig">
                  <xsl:value-of select="abs(number($keySig))"/>f</xsl:attribute>
              </xsl:when>
            </xsl:choose>
            <xsl:if test="part/attributes[not(preceding-sibling::note) and
              not(preceding-sibling::forward) and not(transpose)]/key/mode">
              <xsl:attribute name="key.mode">
                <xsl:value-of select="part[attributes[not(preceding-sibling::note)
                  and not(preceding-sibling::forward) and
                  not(transpose)]/key/mode][1]/attributes[not(preceding-sibling::note) and
                  not(preceding-sibling::forward) and not(transpose)]/key/mode"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:if>
        </xsl:if>

        <!-- Page layout info -->
        <xsl:for-each select="part[print/page-layout][1]/print/page-layout">
          <xsl:for-each select="page-height">
            <xsl:attribute name="page.height">
              <xsl:value-of select="format-number(. div 5, '###0.####')"/>
              <!-- <xsl:text>vu</xsl:text> -->
            </xsl:attribute>
          </xsl:for-each>
          <xsl:for-each select="page-width">
            <xsl:attribute name="page.width">
              <xsl:value-of select="format-number(. div 5, '###0.####')"/>
              <!-- <xsl:text>vu</xsl:text> -->
            </xsl:attribute>
          </xsl:for-each>
          <xsl:for-each select="page-margins">
            <xsl:attribute name="page.leftmar">
              <xsl:value-of select="format-number(left-margin div 5, '###0.####')"/>
              <!-- <xsl:text>vu</xsl:text> -->
            </xsl:attribute>
            <xsl:attribute name="page.rightmar">
              <xsl:value-of select="format-number(right-margin div 5, '###0.####')"/>
              <!-- <xsl:text>vu</xsl:text> -->
            </xsl:attribute>
            <xsl:attribute name="page.topmar">
              <xsl:value-of select="format-number(top-margin div 5, '###0.####')"/>
              <!-- <xsl:text>vu</xsl:text> -->
            </xsl:attribute>
            <xsl:attribute name="page.botmar">
              <xsl:value-of select="format-number(bottom-margin div 5, '###0.####')"/>
              <!-- <xsl:text>vu</xsl:text> -->
            </xsl:attribute>
          </xsl:for-each>
        </xsl:for-each>

        <!-- System layout info -->
        <xsl:for-each select="part[print/system-layout][1]/print/system-layout">
          <xsl:for-each select="system-margins">
            <xsl:attribute name="system.leftmar">
              <xsl:value-of select="format-number(left-margin div 5, '###0.####')"/>
              <!-- <xsl:text>vu</xsl:text> -->
            </xsl:attribute>
            <xsl:attribute name="system.rightmar">
              <xsl:value-of select="format-number(right-margin div 5, '###0.####')"/>
              <!-- <xsl:text>vu</xsl:text> -->
            </xsl:attribute>
          </xsl:for-each>
          <xsl:for-each select="system-distance">
            <xsl:attribute name="spacing.system">
              <xsl:value-of select="format-number(. div 5, '###0.####')"/>
              <!-- <xsl:text>vu</xsl:text> -->
            </xsl:attribute>
          </xsl:for-each>
          <xsl:for-each select="top-system-distance">
            <xsl:attribute name="system.topmar">
              <xsl:value-of select="format-number(. div 5, '###0.####')"/>
              <!-- <xsl:text>vu</xsl:text> -->
            </xsl:attribute>
          </xsl:for-each>
        </xsl:for-each>

        <!-- Provide multiple time signatures as elements, but ignore first measure -->
        <xsl:if test="part/attributes[time/beats] and count(preceding::measure) &gt; 0">
          <xsl:choose>
            <xsl:when test="count(part[1]/attributes[time/beats]/time/beats) &gt; 1">
              <meterSigGrp>
                <xsl:attribute name="func">
                  <xsl:choose>
                    <xsl:when test="part[1]/attributes[time/beats]/time/interchangeable">
                      <xsl:text>interchanging</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text>mixed</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
                <xsl:for-each select="part[1]/attributes[time/beats]/time/beats">
                  <meterSig>
                    <xsl:attribute name="count">
                      <xsl:value-of select="."/>
                    </xsl:attribute>
                    <xsl:attribute name="unit">
                      <xsl:value-of select="following-sibling::beat-type[1]"/>
                    </xsl:attribute>
                  </meterSig>
                </xsl:for-each>
              </meterSigGrp>
            </xsl:when>
          </xsl:choose>
        </xsl:if>
      </scoreDef>
    </xsl:if>

    <!-- Staff-level info -->
    <xsl:if test="count(preceding::measure) &gt; 0">
      <!-- Ignore staff-level info in the first measure since it's already been recorded in /score/scoreDef. -->
      <xsl:for-each select="part[attributes[not(preceding-sibling::note) and
        not(preceding-sibling::forward)][clef or divisions or key or staff-details[*] or
        transpose] or print[*]]">
        <!-- ID of this part -->
        <xsl:variable name="partID">
          <xsl:value-of select="@id"/>
        </xsl:variable>

        <!-- Concert key -->
        <xsl:variable name="scoreFifths">
          <xsl:choose>
            <!-- Concert key given in the current measure -->
            <xsl:when test="attributes[not(transpose) and key][1]/key">
              <xsl:value-of select="attributes[not(transpose) and
                key][1]/key[1]/fifths"/>
            </xsl:when>
            <xsl:otherwise>
              <!-- Concert key provided in a prior measure -->
              <xsl:value-of select="preceding::part[attributes[not(transpose) and
                key]][1]/attributes/key[1]/fifths"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- Mode of concert key -->
        <xsl:variable name="scoreMode">
          <xsl:choose>
            <!-- Concert key mode given in the current measure -->
            <xsl:when test="attributes[not(transpose) and key][1]/key">
              <xsl:value-of select="attributes[not(transpose) and key][1]/key[1]/mode"/>
            </xsl:when>
            <xsl:otherwise>
              <!-- Concert key provided in a prior measure -->
              <xsl:value-of select="preceding::part[attributes[not(transpose) and
                key]][1]/attributes/key[1]/mode"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="local-name($defaultLayout//*[@xml:id=$partID]) = 'staffDef'">
            <!-- Part has only 1 staff -->
            <!-- Gather staff qualities -->
            <xsl:variable name="staffAttrib">
              <xsl:copy-of select="print/staff-layout"/>
              <xsl:copy-of select="print/part-name-display"/>
              <xsl:copy-of select="print/part-abbreviation-display"/>
              <xsl:copy-of select="attributes/clef"/>
              <xsl:copy-of select="attributes/divisions"/>
              <xsl:copy-of select="attributes/key"/>
              <xsl:copy-of select="attributes/staff-details"/>
              <xsl:copy-of select="attributes/transpose"/>
            </xsl:variable>

            <!--<xsl:value-of select="$nl"/>
              <xsl:comment>StaffAttrib <xsl:value-of select="$partID"/></xsl:comment>
              <xsl:value-of select="$nl"/>
              <xsl:copy-of select="$staffAttrib"/>-->

            <xsl:variable name="staffDefTemp">
              <!-- Gather staff-specific qualities -->
              <xsl:for-each select="$defaultLayout//*[@xml:id=$partID]">
                <staffDef>
                  <xsl:variable name="thisStaff">
                    <xsl:value-of select="position()"/>
                  </xsl:variable>
                  <xsl:copy-of select="@n"/>
                  <xsl:copy-of select="$staffAttrib/*[number(@number) = $thisStaff]"/>
                  <xsl:copy-of select="$staffAttrib/clef[not(@number)][1]"/>
                  <xsl:copy-of select="$staffAttrib/divisions"/>
                  <xsl:copy-of select="$staffAttrib/key[not(@number)][1]"/>
                  <xsl:copy-of select="$staffAttrib/staff-details[1]"/>
                  <xsl:copy-of select="$staffAttrib/staff-layout[1]"/>
                  <xsl:copy-of select="$staffAttrib/transpose[not(@number)][1]"/>
                  <xsl:copy-of select="$staffAttrib/part-name-display"/>
                  <xsl:copy-of select="$staffAttrib/part-abbreviation-display"/>
                </staffDef>
              </xsl:for-each>
            </xsl:variable>

            <!--<xsl:value-of select="$nl"/>
              <xsl:comment>StaffDefTemp <xsl:value-of select="$partID"/></xsl:comment>
              <xsl:value-of select="$nl"/>
              <xsl:copy-of select="$staffDefTemp"/>-->

            <!-- Process staff-specific qualities -->
            <xsl:for-each select="$staffDefTemp/staffDef[*]">
              <staffDef xmlns="http://www.music-encoding.org/ns/mei">
                <xsl:copy-of select="@n"/>
                <!-- part name -->
                <!-- staff label as attribute -->
                <xsl:if test="part-name-display[normalize-space(text()) != '']">
                  <xsl:attribute name="label">
                    <xsl:value-of select="replace(replace(normalize-space(part-name-display),
                      'flat', '&#x266d;'), 'sharp', '&#x266f;')"/>
                  </xsl:attribute>
                </xsl:if>
                <!-- abbreviated staff label as attribute -->
                <xsl:if test="part-abbreviation-display[normalize-space(text()) != '']">
                  <xsl:attribute name="label.abbr">
                    <xsl:value-of
                      select="replace(replace(normalize-space(part-abbreviation-display),
                      'flat', '&#x266d;'), 'sharp', '&#x266f;')"/>
                  </xsl:attribute>
                </xsl:if>
                <!-- number of staff lines -->
                <xsl:for-each select="staff-details/staff-lines">
                  <xsl:attribute name="lines">
                    <xsl:choose>
                      <xsl:when test=". != ''">
                        <xsl:value-of select="."/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="5"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                </xsl:for-each>
                <!-- clef -->
                <xsl:choose>
                  <xsl:when test="normalize-space(clef/sign) != ''">
                    <xsl:for-each select="clef">
                      <xsl:choose>
                        <!-- percussion clef -->
                        <xsl:when test="sign='percussion'">
                          <xsl:attribute name="clef.shape">perc</xsl:attribute>
                        </xsl:when>
                        <!-- TAB "clef" -->
                        <xsl:when test="sign='TAB'">
                          <xsl:attribute name="clef.shape">TAB</xsl:attribute>
                        </xsl:when>
                        <!-- No clef provided -->
                        <xsl:when test="sign='none'">
                          <xsl:attribute name="clef.visible">false</xsl:attribute>
                        </xsl:when>
                        <!-- "normal" clef -->
                        <xsl:otherwise>
                          <xsl:attribute name="clef.line">
                            <xsl:value-of select="line"/>
                          </xsl:attribute>
                          <xsl:attribute name="clef.shape">
                            <xsl:value-of select="sign"/>
                          </xsl:attribute>
                          <xsl:if test="clef-octave-change">
                            <xsl:if test="abs(number(clef-octave-change)) != 0">
                              <xsl:attribute name="clef.dis">
                                <xsl:choose>
                                  <xsl:when test="abs(number(clef-octave-change)) = 2">15</xsl:when>
                                  <xsl:when test="abs(number(clef-octave-change)) = 1">8</xsl:when>
                                </xsl:choose>
                              </xsl:attribute>
                              <xsl:attribute name="clef.dis.place">
                                <xsl:choose>
                                  <xsl:when test="number(clef-octave-change) &lt; 0">
                                    <xsl:text>below</xsl:text>
                                  </xsl:when>
                                  <xsl:otherwise>
                                    <xsl:text>above</xsl:text>
                                  </xsl:otherwise>
                                </xsl:choose>
                              </xsl:attribute>
                            </xsl:if>
                          </xsl:if>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:if test="@print-object='no'">
                        <xsl:attribute name="clef.visible">false</xsl:attribute>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:when>
                </xsl:choose>
                <!-- staff key signature -->
                <xsl:if test="key">
                  <xsl:variable name="keySig">
                    <xsl:value-of select="key/fifths"/>
                  </xsl:variable>
                  <xsl:choose>
                    <xsl:when test="number($keySig)=0">
                      <xsl:attribute name="key.sig">
                        <xsl:value-of select="$keySig"/>
                      </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="number($keySig) &gt; 0">
                      <xsl:attribute name="key.sig"><xsl:value-of select="$keySig"
                        />s</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="number($keySig) &lt; 0">
                      <xsl:attribute name="key.sig"><xsl:value-of select="abs($keySig)"
                        />f</xsl:attribute>
                    </xsl:when>
                  </xsl:choose>
                  <!-- staff key mode -->
                  <xsl:if test="key/mode and key/mode != $scoreMode">
                    <xsl:attribute name="key.mode">
                      <xsl:value-of select="key/mode"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="key/@print-object='no'">
                    <xsl:attribute name="key.sig.show">false</xsl:attribute>
                  </xsl:if>
                </xsl:if>

                <!-- tuning for TAB staff -->
                <xsl:if test="staff-details/staff-tuning">
                  <xsl:attribute name="tab.strings">
                    <xsl:variable name="tabStrings">
                      <xsl:for-each select="staff-details/staff-tuning">
                        <xsl:sort select="@line" order="descending"/>
                        <xsl:variable name="thisString">
                          <xsl:value-of select="tuning-step"/>
                        </xsl:variable>
                        <xsl:value-of select="translate(tuning-step,'ABCDEFG','abcdefg')"/>
                        <xsl:value-of select="tuning-octave"/>
                        <xsl:text>&#32;</xsl:text>
                      </xsl:for-each>
                    </xsl:variable>
                    <xsl:value-of select="normalize-space($tabStrings)"/>
                  </xsl:attribute>
                </xsl:if>
                <!-- staff transposition -->
                <xsl:choose>
                  <!-- transposed -->
                  <xsl:when test="transpose">
                    <xsl:attribute name="trans.semi">
                      <xsl:choose>
                        <xsl:when test="transpose/octave-change">
                          <xsl:variable name="octaveChange">
                            <xsl:value-of select="transpose[1]/octave-change"/>
                          </xsl:variable>
                          <xsl:variable name="chromatic">
                            <xsl:value-of select="transpose[1]/chromatic"/>
                          </xsl:variable>
                          <xsl:value-of select="$chromatic + (12 * $octaveChange)"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="transpose[1]/chromatic"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:attribute>
                    <xsl:if test="transpose/diatonic">
                      <xsl:attribute name="trans.diat">
                        <xsl:value-of select="transpose[1]/diatonic"/>
                      </xsl:attribute>
                    </xsl:if>
                  </xsl:when>
                  <!-- transposed by capo -->
                  <xsl:when test="staff-details/capo">
                    <xsl:attribute name="trans.semi">
                      <xsl:value-of select="staff-details[capo]/capo"/>
                    </xsl:attribute>
                  </xsl:when>
                </xsl:choose>
                <!-- ppq -->
                <xsl:for-each select="divisions">
                  <xsl:if test="number(.) != $scorePPQ">
                    <xsl:attribute name="ppq">
                      <xsl:value-of select="."/>
                    </xsl:attribute>
                  </xsl:if>
                </xsl:for-each>
                <!-- staff spacing -->
                <xsl:for-each select="staff-layout/staff-distance">
                  <xsl:attribute name="spacing">
                    <xsl:value-of select="format-number(. div 5, '###0.####')"/>
                    <!-- <xsl:text>vu</xsl:text> -->
                  </xsl:attribute>
                </xsl:for-each>
                <!-- staff size -->
                <xsl:for-each select="staff-details[staff-size][1]/staff-size">
                  <xsl:attribute name="scale">
                    <xsl:value-of select="."/>
                    <xsl:text>%</xsl:text>
                  </xsl:attribute>
                </xsl:for-each>
                <xsl:if test="staff-details/@print-object">
                  <xsl:attribute name="visible">
                    <xsl:choose>
                      <xsl:when test="staff-details/@print-object='no'">
                        <xsl:text>false</xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text>true</xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                </xsl:if>
                <!-- staff labels as elements -->
                <xsl:if test="part-name-display[normalize-space(text()) != '']">
                  <label>
                    <xsl:value-of select="replace(replace(normalize-space(part-name-display),
                      'flat', '&#x266d;'), 'sharp', '&#x266f;')"/>
                  </label>
                </xsl:if>
                <xsl:if test="part-abbreviation-display[normalize-space(text()) != '']">
                  <label>
                    <abbr>
                      <xsl:value-of
                        select="replace(replace(normalize-space(part-abbreviation-display),
                        'flat', '&#x266d;'), 'sharp', '&#x266f;')"/>
                    </abbr>
                  </label>
                </xsl:if>
              </staffDef>
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="local-name($defaultLayout//*[@xml:id=$partID]) = 'staffGrp'">
            <!-- Part has multiple staves -->
            <!-- Gather staff qualities -->
            <xsl:variable name="staffAttrib">
              <xsl:copy-of select="print/staff-layout"/>
              <xsl:copy-of select="attributes/clef"/>
              <xsl:copy-of select="attributes/divisions"/>
              <xsl:copy-of select="attributes/key"/>
              <xsl:copy-of select="attributes/staff-details"/>
              <xsl:copy-of select="attributes/transpose"/>
            </xsl:variable>

            <!--<xsl:value-of select="$nl"/>
              <xsl:comment>StaffAttrib <xsl:value-of select="$partID"/></xsl:comment>
              <xsl:value-of select="$nl"/>
              <xsl:copy-of select="$staffAttrib"/>-->

            <!-- Gather staff-specific qualities -->
            <xsl:variable name="staffDefTemp">
              <xsl:for-each select="$defaultLayout//*[@xml:id=$partID]/*[local-name()='staffDef']">
                <staffDef>
                  <xsl:variable name="thisStaff">
                    <xsl:value-of select="position()"/>
                  </xsl:variable>
                  <xsl:copy-of select="@n"/>
                  <xsl:copy-of select="$staffAttrib/*[number(@number) = $thisStaff]"/>
                  <xsl:if test="not($staffAttrib/clef[number(@number) = $thisStaff])">
                    <xsl:copy-of select="$staffAttrib/clef[not(@number)][1]"/>
                  </xsl:if>
                  <xsl:if test="not($staffAttrib/key[number(@number) = $thisStaff])">
                    <xsl:copy-of select="$staffAttrib/key[not(@number)][1]"/>
                  </xsl:if>
                  <xsl:if test="not($staffAttrib/staff-details[number(@number) = $thisStaff])">
                    <xsl:copy-of select="$staffAttrib/staff-details[not(@number)][1]"/>
                  </xsl:if>
                  <xsl:if test="not($staffAttrib/staff-layout[number(@number) = $thisStaff])">
                    <xsl:copy-of select="$staffAttrib/staff-layout[not(@number)][1]"/>
                  </xsl:if>
                  <xsl:if test="not($staffAttrib/transpose[number(@number) = $thisStaff])">
                    <xsl:copy-of select="$staffAttrib/transpose[not(@number)][1]"/>
                  </xsl:if>
                  <xsl:copy-of select="$staffAttrib/divisions"/>
                </staffDef>
              </xsl:for-each>
            </xsl:variable>

            <!-- <xsl:value-of select="$nl"/>
              <xsl:comment>StaffDefTemp <xsl:value-of select="$partID"/></xsl:comment>
              <xsl:value-of select="$nl"/>
              <xsl:copy-of select="$staffDefTemp"/>-->

            <!-- Process staff-specific qualities -->
            <xsl:for-each select="$staffDefTemp/staffDef[*]">
              <staffDef xmlns="http://www.music-encoding.org/ns/mei">
                <xsl:copy-of select="@n"/>
                <!-- number of staff lines -->
                <xsl:for-each select="staff-details/staff-lines">
                  <xsl:attribute name="lines">
                    <xsl:choose>
                      <xsl:when test=". != ''">
                        <xsl:value-of select="."/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="5"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                </xsl:for-each>
                <!-- clef -->
                <xsl:choose>
                  <xsl:when test="normalize-space(clef/sign) != ''">
                    <xsl:for-each select="clef">
                      <xsl:choose>
                        <!-- percussion clef -->
                        <xsl:when test="sign='percussion'">
                          <xsl:attribute name="clef.shape">perc</xsl:attribute>
                        </xsl:when>
                        <!-- TAB "clef" -->
                        <xsl:when test="sign='TAB'">
                          <xsl:attribute name="clef.shape">TAB</xsl:attribute>
                        </xsl:when>
                        <!-- No clef provided -->
                        <xsl:when test="sign='none'">
                          <xsl:attribute name="clef.visible">false</xsl:attribute>
                        </xsl:when>
                        <!-- "normal" clef -->
                        <xsl:otherwise>
                          <xsl:attribute name="clef.line">
                            <xsl:value-of select="line"/>
                          </xsl:attribute>
                          <xsl:attribute name="clef.shape">
                            <xsl:value-of select="sign"/>
                          </xsl:attribute>
                          <xsl:if test="clef-octave-change">
                            <xsl:if test="abs(number(clef-octave-change)) != 0">
                              <xsl:attribute name="clef.dis">
                                <xsl:choose>
                                  <xsl:when test="abs(number(clef-octave-change)) = 2">15</xsl:when>
                                  <xsl:when test="abs(number(clef-octave-change)) = 1">8</xsl:when>
                                </xsl:choose>
                              </xsl:attribute>
                              <xsl:attribute name="clef.dis.place">
                                <xsl:choose>
                                  <xsl:when test="number(clef-octave-change) &lt; 0">
                                    <xsl:text>below</xsl:text>
                                  </xsl:when>
                                  <xsl:otherwise>
                                    <xsl:text>above</xsl:text>
                                  </xsl:otherwise>
                                </xsl:choose>
                              </xsl:attribute>
                            </xsl:if>
                          </xsl:if>
                        </xsl:otherwise>
                      </xsl:choose>
                      <xsl:if test="@print-object='no'">
                        <xsl:attribute name="clef.visible">false</xsl:attribute>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:when>
                </xsl:choose>
                <!-- staff key signature -->
                <xsl:if test="key">
                  <xsl:variable name="keySig">
                    <xsl:value-of select="key/fifths"/>
                  </xsl:variable>
                  <xsl:choose>
                    <xsl:when test="number($keySig)=0">
                      <xsl:attribute name="key.sig">
                        <xsl:value-of select="$keySig"/>
                      </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="number($keySig) &gt; 0">
                      <xsl:attribute name="key.sig"><xsl:value-of select="$keySig"
                        />s</xsl:attribute>
                    </xsl:when>
                    <xsl:when test="number($keySig) &lt; 0">
                      <xsl:attribute name="key.sig"><xsl:value-of select="abs($keySig)"
                        />f</xsl:attribute>
                    </xsl:when>
                  </xsl:choose>
                  <!-- staff key mode -->
                  <xsl:if test="key/mode and key/mode != $scoreMode">
                    <xsl:attribute name="key.mode">
                      <xsl:value-of select="key/mode"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="key/@print-object='no'">
                    <xsl:attribute name="key.sig.show">false</xsl:attribute>
                  </xsl:if>
                </xsl:if>
                <!--</xsl:if>-->
                <!-- tuning for TAB staff -->
                <xsl:if test="staff-details/staff-tuning">
                  <xsl:attribute name="tab.strings">
                    <xsl:variable name="tabStrings">
                      <xsl:for-each select="staff-details/staff-tuning">
                        <xsl:sort select="@line" order="descending"/>
                        <xsl:variable name="thisString">
                          <xsl:value-of select="tuning-step"/>
                        </xsl:variable>
                        <xsl:value-of select="translate(tuning-step,'ABCDEFG','abcdefg')"/>
                        <xsl:value-of select="tuning-octave"/>
                        <xsl:text>&#32;</xsl:text>
                      </xsl:for-each>
                    </xsl:variable>
                    <xsl:value-of select="normalize-space($tabStrings)"/>
                  </xsl:attribute>
                </xsl:if>
                <!-- staff transposition -->
                <xsl:choose>
                  <!-- transposed -->
                  <xsl:when test="transpose">
                    <xsl:attribute name="trans.semi">
                      <xsl:choose>
                        <xsl:when test="transpose/octave-change">
                          <xsl:variable name="octaveChange">
                            <xsl:value-of select="transpose[1]/octave-change"/>
                          </xsl:variable>
                          <xsl:variable name="chromatic">
                            <xsl:value-of select="transpose[1]/chromatic"/>
                          </xsl:variable>
                          <xsl:value-of select="$chromatic + (12 * $octaveChange)"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of select="transpose[1]/chromatic"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:attribute>
                    <xsl:if test="transpose/diatonic">
                      <xsl:attribute name="trans.diat">
                        <xsl:value-of select="transpose[1]/diatonic"/>
                      </xsl:attribute>
                    </xsl:if>
                  </xsl:when>
                  <!-- transposed by capo -->
                  <xsl:when test="staff-details/capo">
                    <xsl:attribute name="trans.semi">
                      <xsl:value-of select="staff-details[capo]/capo"/>
                    </xsl:attribute>
                  </xsl:when>
                </xsl:choose>
                <!-- ppq -->
                <xsl:for-each select="divisions">
                  <xsl:if test="number(.) != $scorePPQ">
                    <xsl:attribute name="ppq">
                      <xsl:value-of select="."/>
                    </xsl:attribute>
                  </xsl:if>
                </xsl:for-each>
                <!-- staff spacing -->
                <xsl:for-each select="staff-layout/staff-distance">
                  <xsl:attribute name="spacing">
                    <xsl:value-of select="format-number(. div 5, '###0.####')"/>
                    <!-- <xsl:text>vu</xsl:text> -->
                  </xsl:attribute>
                </xsl:for-each>
                <!-- staff size -->
                <xsl:for-each select="staff-details[staff-size][1]/staff-size">
                  <xsl:attribute name="scale">
                    <xsl:value-of select="."/>
                    <xsl:text>%</xsl:text>
                  </xsl:attribute>
                </xsl:for-each>
                <xsl:if test="staff-details/@print-object">
                  <xsl:attribute name="visible">
                    <xsl:choose>
                      <xsl:when test="staff-details/@print-object='no'">
                        <xsl:text>false</xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text>true</xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                </xsl:if>
              </staffDef>
            </xsl:for-each>
          </xsl:when>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>

    <xsl:variable name="measure">
      <measure xmlns="http://www.music-encoding.org/ns/mei">
        <!-- number -->
        <xsl:attribute name="n">
          <xsl:value-of select="@number"/>
        </xsl:attribute>
        <!-- metrical conformance -->
        <xsl:if test="@implicit='yes'">
          <xsl:attribute name="metcon">false</xsl:attribute>
        </xsl:if>
        <!-- generated ID -->
        <xsl:attribute name="xml:id">
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
        <xsl:choose>
          <!-- When the *following measure* has its left barline attribute set, make that the right
            attribute on *this* measure -->
          <xsl:when test="following-sibling::measure[1]/part/barline[@location='left']/bar-style">
            <xsl:variable name="barStyle">
              <xsl:value-of select="following-sibling::measure[1]/part[1]/barline/bar-style"/>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$barStyle='dotted'">
                <xsl:attribute name="right">dotted</xsl:attribute>
              </xsl:when>
              <xsl:when test="$barStyle='dashed'">
                <xsl:attribute name="right">dashed</xsl:attribute>
              </xsl:when>
              <xsl:when test="$barStyle='light-light'">
                <xsl:attribute name="right">dbl</xsl:attribute>
              </xsl:when>
              <xsl:when test="$barStyle='heavy-light'">
                <xsl:choose>
                  <xsl:when
                    test="following-sibling::measure[1]/part/barline/repeat/@direction='forward'">
                    <xsl:choose>
                      <xsl:when test="part/barline/repeat/@direction='backward'">
                        <xsl:attribute name="right">rptboth</xsl:attribute>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:attribute name="right">rptstart</xsl:attribute>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="right">dbl</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="$barStyle='light-heavy'">
                <xsl:choose>
                  <xsl:when test="part/barline/repeat/@direction='backward'">
                    <xsl:attribute name="right">rptend</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="right">end</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="$barStyle='heavy-heavy'">
                <xsl:choose>
                  <xsl:when test="part/barline/repeat/@direction='backward' and
                    following-sibling::measure[1]/part/barline/repeat/@direction='forward'">
                    <xsl:attribute name="right">rptboth</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="right">dbl</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="$barStyle='none'">
                <xsl:attribute name="right">invis</xsl:attribute>
              </xsl:when>
            </xsl:choose>
          </xsl:when>
          <!-- Set this measure's right attribute when the *following measure* doesn't have a left
            barline specified -->
          <xsl:when test="part/barline[@location='right']/bar-style">
            <xsl:variable name="barStyle">
              <xsl:value-of select="part[1]/barline/bar-style"/>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="$barStyle='dotted'">
                <xsl:attribute name="right">dotted</xsl:attribute>
              </xsl:when>
              <xsl:when test="$barStyle='dashed'">
                <xsl:attribute name="right">dashed</xsl:attribute>
              </xsl:when>
              <xsl:when test="$barStyle='light-light'">
                <xsl:attribute name="right">dbl</xsl:attribute>
              </xsl:when>
              <xsl:when test="$barStyle='light-heavy'">
                <xsl:choose>
                  <xsl:when test="part/barline/repeat/@direction='backward'">
                    <xsl:choose>
                      <xsl:when
                        test="following-sibling::measure[1]/part/barline/repeat/@direction='forward'">
                        <xsl:attribute name="right">rptboth</xsl:attribute>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:attribute name="right">rptend</xsl:attribute>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="right">end</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="$barStyle='heavy-light'">
                <xsl:choose>
                  <xsl:when
                    test="following-sibling::measure[1]/part/barline/repeat[@direction='forward']">
                    <xsl:attribute name="right">rptstart</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="right">dbl</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="$barStyle='heavy-heavy'">
                <xsl:choose>
                  <xsl:when test="part/barline/repeat[@direction='backward'] and
                    following-sibling::measure[1]/part/barline/repeat[@direction='forward']">
                    <xsl:attribute name="right">rptboth</xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="right">dbl</xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="$barStyle='none'">
                <xsl:attribute name="right">invis</xsl:attribute>
              </xsl:when>
            </xsl:choose>
          </xsl:when>
          <!-- This stylesheet doesn't handle a barline in the middle of a measure -->
        </xsl:choose>

        <!-- Set left attribute -->
        <xsl:if test="part/barline[@location='left']/bar-style">
          <xsl:variable name="lbarStyle">
            <xsl:value-of select="part/barline/bar-style"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$lbarStyle='dotted'">
              <xsl:attribute name="left">dotted</xsl:attribute>
            </xsl:when>
            <xsl:when test="$lbarStyle='dashed'">
              <xsl:attribute name="left">dashed</xsl:attribute>
            </xsl:when>
            <xsl:when test="$lbarStyle='light-light'">
              <xsl:attribute name="left">dbl</xsl:attribute>
            </xsl:when>
            <xsl:when test="$lbarStyle='light-heavy'">
              <xsl:choose>
                <xsl:when test="part/barline/repeat/@direction='backward'">
                  <xsl:choose>
                    <xsl:when
                      test="preceding-sibling::measure[1]/part/barline/repeat/@direction='backward'">
                      <xsl:attribute name="left">rptend</xsl:attribute>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:attribute name="left">end</xsl:attribute>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="right">end</xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="$lbarStyle='heavy-light'">
              <xsl:choose>
                <xsl:when test="part/barline/repeat/@direction='forward'">
                  <xsl:attribute name="left">rptstart</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="left">dbl</xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="$lbarStyle='heavy-heavy'">
              <xsl:choose>
                <xsl:when test="part/barline/repeat/@direction='forward' and
                  preceding-sibling::measure[1]/part/barline/repeat/@direction='backward'">
                  <xsl:attribute name="left">rptboth</xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="left">dbl</xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="$lbarStyle='none'">
              <xsl:attribute name="left">invis</xsl:attribute>
            </xsl:when>
          </xsl:choose>
        </xsl:if>

        <!-- Set left attribute if bar-style is not present -->
        <xsl:if test="part/barline[@location='left'][repeat]">
          <xsl:choose>
            <xsl:when test="part/barline/repeat/@direction='forward'">
              <xsl:attribute name="left">rptstart</xsl:attribute>
            </xsl:when>
            <xsl:when test="part/barline/repeat/@direction='forward' and
              preceding-sibling::measure[1]/part/barline/repeat/@direction='backward'">
              <xsl:attribute name="left">rptboth</xsl:attribute>
            </xsl:when>
          </xsl:choose>
        </xsl:if>

        <!-- Set right attribute -->
        <xsl:if test="part/barline[@location='right'][repeat]">
          <xsl:choose>
            <xsl:when test="part/barline/repeat/@direction='backward'">
              <xsl:attribute name="right">rptend</xsl:attribute>
            </xsl:when>
            <xsl:when test="part/barline/repeat/@direction='backward' and
              following-sibling::measure[1]/part/barline/repeat/@direction='forward'">
              <xsl:attribute name="right">rptboth</xsl:attribute>
            </xsl:when>
          </xsl:choose>
        </xsl:if>

        <!-- Copy the measure width -->
        <xsl:if test="@width">
          <xsl:attribute name="width">
            <xsl:value-of select="format-number(@width div 5, '###0.####')"/>
            <!-- <xsl:text>vu</xsl:text> -->
          </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="$nl"/>

        <!-- Process measure contents -->
        <xsl:for-each select="part">
          <!-- Events -->
          <xsl:for-each-group select="note[not(chord)] | attributes | backup | forward"
            group-ending-with="backup">
            <xsl:apply-templates select="current-group()" mode="stage1"/>
          </xsl:for-each-group>
        </xsl:for-each>

        <xsl:for-each select="part">
          <!-- Control events -->
          <xsl:variable name="controlevents">
            <xsl:apply-templates select="direction" mode="stage1"/>
            <xsl:apply-templates select="sound[@tempo]" mode="stage1"/>
            <xsl:apply-templates select="figured-bass | harmony" mode="stage1"/>
            <xsl:apply-templates select="note[not(chord) and (notations/arpeggiate or
              notations/non-arpeggiate)]" mode="stage1.arpeg"/>
            <xsl:apply-templates select="note/beam[.='begin']" mode="stage1"/>
            <xsl:apply-templates select="note/notations/articulations/*" mode="stage1.dir"/>
            <xsl:apply-templates select="note/notations/technical/*" mode="stage1.dir"/>
            <xsl:apply-templates select="note/notations/dynamics" mode="stage1"/>
            <xsl:apply-templates select="note/notations/fermata" mode="stage1"/>
            <xsl:apply-templates select="note/notations/ornaments" mode="stage1"/>
            <xsl:apply-templates select="note/notations/slur[@type='start']" mode="stage1"/>
            <!-- note/notations/slur[@type='continue'] -->
            <xsl:apply-templates select="note/notations/tied[@type='start']" mode="stage1"/>
            <xsl:apply-templates select="note/notations/tuplet[@type='start']" mode="stage1"/>
          </xsl:variable>
          <xsl:copy-of select="$controlevents"/>
        </xsl:for-each>
      </measure>
    </xsl:variable>
    <!--<xsl:copy-of select="$measure"/>-->

    <!-- Further process $measure -->
    <xsl:for-each select="$measure/mei:measure">
      <measure xmlns="http://www.music-encoding.org/ns/mei">
        <xsl:copy-of select="@*"/>
        <xsl:variable name="measureNum">
          <xsl:value-of select="@n"/>
        </xsl:variable>
        <!-- Group events by MusicXML partID -->
        <xsl:for-each-group
          select="mei:chord|mei:clef|mei:note|mei:rest|mei:space|mei:mRest|mei:multiRest|mei:mSpace"
          group-by="@part">
          <xsl:variable name="byPart">
            <part>
              <xsl:attribute name="n">
                <xsl:value-of select="current-grouping-key()"/>
              </xsl:attribute>
              <xsl:for-each-group select="current-group()" group-by="@layer">
                <layer>
                  <xsl:attribute name="n">
                    <xsl:value-of select="current-grouping-key()"/>
                  </xsl:attribute>
                  <xsl:copy-of select="current-group()"/>
                </layer>
              </xsl:for-each-group>
            </part>
          </xsl:variable>
          <!--<xsl:copy-of select="$byPart"/>-->

          <xsl:variable name="byStaff">
            <xsl:for-each select="$byPart/mei:part">
              <!-- Wrap staff element around each layer -->
              <xsl:for-each select="mei:layer">
                <xsl:variable name="thisStaff">
                  <xsl:choose>
                    <xsl:when test="contains(*[1]/@staff, ' ')">
                      <xsl:value-of select="substring-before(*[1]/@staff, ' ')"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="*[1]/@staff"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <staff xmlns="http://www.music-encoding.org/ns/mei">
                  <xsl:attribute name="n">
                    <xsl:value-of select="$thisStaff"/>
                  </xsl:attribute>
                  <layer>
                    <xsl:attribute name="n">
                      <xsl:value-of select="@n"/>
                    </xsl:attribute>
                    <xsl:for-each select="*">
                      <xsl:copy-of select="."/>
                    </xsl:for-each>
                  </layer>
                </staff>
              </xsl:for-each>
            </xsl:for-each>
          </xsl:variable>
          <!--<xsl:copy-of select="$byStaff"/>-->

          <xsl:variable name="byStaff2">
            <!-- Group staves, then group contained layers -->
            <xsl:for-each-group select="$byStaff/mei:staff" group-by="@n">
              <!--<xsl:variable name="thisStaff">
                <xsl:value-of select="@n"/>
              </xsl:variable>-->
              <staff xmlns="http://www.music-encoding.org/ns/mei">
                <xsl:attribute name="n">
                  <xsl:value-of select="current-grouping-key()"/>
                </xsl:attribute>
                <xsl:for-each select="current-group()">
                  <xsl:for-each select="mei:layer">
                    <layer>
                      <xsl:for-each select="*">
                        <xsl:variable name="thisElement">
                          <xsl:value-of select="local-name(.)"/>
                        </xsl:variable>
                        <xsl:element name="{$thisElement}">
                          <xsl:copy-of select="@*[local-name() != 'staff' and local-name() != 'part'
                            and local-name() != 'layer']"/>
                          <xsl:if test="@staff != ancestor::mei:staff/@n">
                            <xsl:copy-of select="@staff"/>
                          </xsl:if>
                          <xsl:copy-of select="*"/>
                        </xsl:element>
                      </xsl:for-each>
                    </layer>
                  </xsl:for-each>
                </xsl:for-each>
              </staff>
            </xsl:for-each-group>
          </xsl:variable>
          <!--<xsl:copy-of select="$byStaff2"/>-->

          <xsl:variable name="byStaff3">
            <!-- Renumber layers -->
            <xsl:for-each select="$byStaff2/mei:staff">
              <staff xmlns="http://www.music-encoding.org/ns/mei">
                <xsl:copy-of select="@*"/>
                <xsl:for-each select="mei:layer">
                  <layer>
                    <xsl:attribute name="n">
                      <xsl:value-of select="count(preceding-sibling::mei:layer) + 1"/>
                    </xsl:attribute>
                    <xsl:copy-of select="@*"/>
                    <xsl:for-each select="*">
                      <xsl:copy-of select="."/>
                    </xsl:for-each>
                  </layer>
                </xsl:for-each>
              </staff>
            </xsl:for-each>
          </xsl:variable>
          <!--<xsl:copy-of select="$byStaff3"/>-->

          <xsl:variable name="byStaff4">
            <!-- Insert space when @tstamp.ges on first event of the layer != 0 -->
            <xsl:for-each select="$byStaff3/mei:staff">
              <staff xmlns="http://www.music-encoding.org/ns/mei">
                <xsl:copy-of select="@*"/>
                <xsl:for-each select="mei:layer">
                  <layer>
                    <xsl:copy-of select="@*"/>
                    <xsl:for-each select="*">
                      <xsl:choose>
                        <xsl:when test="position()=1 and @tstamp.ges &gt; 0">
                          <xsl:comment>
                            <xsl:text>Inserted space</xsl:text>
                          </xsl:comment>
                          <xsl:value-of select="$nl"/>
                          <space>
                            <xsl:attribute name="xml:id">
                              <xsl:value-of select="generate-id()"/>
                            </xsl:attribute>
                            <xsl:attribute name="tstamp.ges">0</xsl:attribute>
                            <!-- The duration of the space in musical terms isn't required 
                              for the conversion of MusicXML to MEI, but it may be necessary 
                              for processing the MEI file. -->
                            <xsl:variable name="dur">
                              <xsl:call-template name="quantizedDuration">
                                <xsl:with-param name="duration">
                                  <xsl:value-of select="number(@tstamp.ges)"/>
                                </xsl:with-param>
                                <xsl:with-param name="ppq">
                                  <xsl:variable name="thisPart">
                                    <xsl:value-of select="ancestor::part/@id"/>
                                  </xsl:variable>
                                  <xsl:choose>
                                    <xsl:when test="ancestor::part[attributes/divisions]">
                                      <xsl:value-of
                                        select="ancestor::part[attributes/divisions]/attributes/divisions"
                                      />
                                    </xsl:when>
                                    <xsl:when test="preceding::part[@id=$thisPart and
                                      attributes/divisions]">
                                      <xsl:value-of select="preceding::part[@id=$thisPart and
                                        attributes/divisions][1]/attributes/divisions"/>
                                    </xsl:when>
                                    <xsl:when test="following::part[@id=$thisPart and
                                      attributes/divisions]">
                                      <xsl:value-of select="following::part[@id=$thisPart and
                                        attributes/divisions][1]/attributes/divisions"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                      <xsl:value-of select="$scorePPQ"/>
                                    </xsl:otherwise>
                                  </xsl:choose>
                                </xsl:with-param>
                              </xsl:call-template>
                            </xsl:variable>
                            <xsl:choose>
                              <xsl:when test="matches($dur, '\.')">
                                <xsl:attribute name="dur">
                                  <xsl:value-of select="substring-before($dur, '.')"/>
                                </xsl:attribute>
                                <xsl:attribute name="dots">
                                  <xsl:value-of select="string-length(substring-after($dur,
                                    substring-before($dur,
                                    '.')))"/>
                                </xsl:attribute>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:attribute name="dur">
                                  <xsl:value-of select="$dur"/>
                                </xsl:attribute>
                              </xsl:otherwise>
                            </xsl:choose>
                            <xsl:attribute name="dur.ges">
                              <xsl:value-of select="@tstamp.ges"/>
                              <xsl:text>p</xsl:text>
                            </xsl:attribute>
                          </space>
                          <xsl:copy-of select="."/>
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:copy-of select="."/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:for-each>
                  </layer>
                </xsl:for-each>
              </staff>
            </xsl:for-each>
          </xsl:variable>
          <xsl:copy-of select="$byStaff4"/>

          <!-- KEEP THIS TO GENERATE strict byStaff organization! -->
          <!-- Further process $byPart: create staff and layer elements. -->
          <!--<xsl:variable name="byStaff">
            <xsl:for-each select="$byPart/mei:part">
              <xsl:variable name="thisPart">
                <xsl:value-of select="@n"/>
              </xsl:variable>
              <xsl:for-each select="mei:layer">
                <xsl:variable name="thisLayer">
                  <xsl:value-of select="@n"/>
                </xsl:variable>
                <xsl:variable name="staves">
                  <xsl:value-of select="distinct-values(*/@staff)"/>
                </xsl:variable>
                <xsl:variable name="countStaves">
                  <xsl:value-of select="count(distinct-values(*/@staff))"/>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="$countStaves=1">
                    <!-\- The 'voice' lies on a single staff -\->
                    <xsl:for-each select="distinct-values(*/@staff)">
                      <staff xmlns="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="n">
                          <xsl:value-of select="."/>
                        </xsl:attribute>
                        <xsl:copy-of
                          select="$byPart/mei:part[@n=$thisPart]/mei:layer[@n=$thisLayer]/*"/>
                      </staff>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-\- The 'voice' crosses staves -\->
                    <xsl:for-each select="distinct-values(*/@staff)">
                      <xsl:variable name="thisStaff">
                        <xsl:value-of select="."/>
                      </xsl:variable>
                      <staff xmlns="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="n">
                          <xsl:value-of select="$thisStaff"/>
                        </xsl:attribute>
                        <xsl:for-each
                          select="$byPart/mei:part[@n=$thisPart]/mei:layer[@n=$thisLayer]/*[local-name()='note'
                          or local-name()='chord' or local-name()='mRest' or local-name()='rest' or local-name()='space' or
                          local-name()='clef']">
                          <!-\- Fill the unused time on 'the other staves' with space -\->
                          <xsl:choose>
                            <xsl:when test="@staff=$thisStaff">
                              <xsl:copy-of select="."/>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:apply-templates select="." mode="insertSpace"/>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:for-each>
                      </staff>
                    </xsl:for-each>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:for-each>
          </xsl:variable>-->
          <!--<xsl:copy-of select="$byStaff"/>-->

          <!-- Further process $byStaff: sort by staff, then by layer -->
          <!--<xsl:variable name="byStaff2">
            <xsl:for-each select="$byStaff/mei:staff">
              <xsl:sort select="@n"/>
              <staff xmlns="http://www.music-encoding.org/ns/mei">
                <xsl:copy-of select="@*"/>
                <xsl:for-each-group select="child::*" group-by="@layer">
                  <xsl:sort select="current-grouping-key()"/>
                  <layer>
                    <xsl:attribute name="n">
                      <xsl:value-of select="current-grouping-key()"/>
                    </xsl:attribute>
                    <xsl:copy-of select="current-group()"/>
                  </layer>
                </xsl:for-each-group>
              </staff>
            </xsl:for-each>
          </xsl:variable>
          <xsl:copy-of select="$byStaff2"/>-->

          <!--<xsl:for-each select="$byStaff2/mei:staff">
            <xsl:for-each select="mei:layer">
              <xsl:if test="count(*[starts-with(@beam, 'i')]) != count(*[starts-with(@beam, 't')])">
                <xsl:variable name="errorMessage">
                  <xsl:text>Beam not terminated! (m. </xsl:text>
                  <xsl:value-of select="$measureNum"/>
                  <xsl:text>, s. </xsl:text>
                  <xsl:value-of select="ancestor::mei:staff/@n"/>
                  <xsl:text>, v. </xsl:text>
                  <xsl:value-of select="@n"/>
                  <xsl:text>)</xsl:text>
                </xsl:variable>
                <xsl:message terminate="yes">
                  <xsl:value-of select="normalize-space($errorMessage)"/>
                </xsl:message>
              </xsl:if>
              <xsl:if test="count(*[starts-with(@tuplet, 'i')]) != count(*[starts-with(@tuplet,
                't')])">
                <xsl:variable name="errorMessage">
                  <xsl:text>Tuplet not terminated! (m. </xsl:text>
                  <xsl:value-of select="$measureNum"/>
                  <xsl:text>, s. </xsl:text>
                  <xsl:value-of select="ancestor::mei:staff/@n"/>
                  <xsl:text>, v. </xsl:text>
                  <xsl:value-of select="@n"/>
                  <xsl:text>)</xsl:text>
                </xsl:variable>
                <xsl:message terminate="yes">
                  <xsl:value-of select="normalize-space($errorMessage)"/>
                </xsl:message>
              </xsl:if>
            </xsl:for-each>
          </xsl:for-each>-->

          <!-- Further process $byStaff2: create beam and tuplet elements -->
          <!--<xsl:variable name="byStaff3">
            <xsl:for-each-group select="$byStaff2/mei:staff" group-by="@n">
              <xsl:variable name="thisStaff">
                <xsl:value-of select="current-grouping-key()"/>
              </xsl:variable>
              <xsl:variable name="staffLayer">
                <staff xmlns="http://www.music-encoding.org/ns/mei">
                  <xsl:copy-of select="@*"/>
                  <xsl:copy-of select="$byStaff2/mei:staff[@n=$thisStaff]/mei:layer"/>
                </staff>
              </xsl:variable>
              <xsl:for-each select="$staffLayer/mei:staff">
                <staff xmlns="http://www.music-encoding.org/ns/mei">
                  <xsl:copy-of select="@*"/>
                  <xsl:for-each select="mei:layer">
                    <xsl:sort select="@n"/>
                    <layer>
                      <xsl:copy-of select="@*[not(local-name()='n')]"/>
                      <xsl:attribute name="n">
                        <xsl:value-of select="position()"/>
                      </xsl:attribute>
                      <xsl:if test="*[@tstamp.ges][1]/@tstamp.ges != 0">
                        <!-\- If the 1st event in the layer doesn't have a timestamp of 0, insert space. -\->
                        <!-\- DEBUG: -\->
                        <xsl:message>Timestamp on 1st event is not 0!</xsl:message>
                        <space>
                          <xsl:attribute name="xml:id">
                            <xsl:value-of select="generate-id(*[@tstamp.ges][1]/@tstamp.ges)"/>
                          </xsl:attribute>
                          <xsl:attribute name="tstamp.ges">0</xsl:attribute>
                          <xsl:attribute name="dur.ges">
                            <xsl:value-of select="*[@tstamp.ges][1]/@tstamp.ges"/>
                            <xsl:text>p</xsl:text>
                          </xsl:attribute>
                        </space>
                      </xsl:if>

                      <xsl:for-each select="*">
                        <xsl:choose>
                          <!-\- starts beam -\->
                          <xsl:when test="starts-with(@beam, 'i')">
                            <xsl:variable name="beamLevel">
                              <xsl:value-of select="substring(@beam, 2)"/>
                            </xsl:variable>
                            <xsl:choose>
                              <!-\- also starts tuplet -\->
                              <xsl:when test="starts-with(@tuplet, 'i')">
                                <xsl:variable name="endBeam" as="xs:integer">
                                  <xsl:value-of
                                    select="count(following-sibling::*[starts-with(@beam,
                                    concat('t',$beamLevel))][1]/preceding-sibling::*)+1"/>
                                </xsl:variable>
                                <xsl:variable name="tupletLevel">
                                  <xsl:value-of select="substring(@tuplet, 2)"/>
                                </xsl:variable>
                                <xsl:variable name="endTuplet" as="xs:integer">
                                  <xsl:value-of
                                    select="count(following-sibling::*[starts-with(@tuplet,
                                    concat('t', $tupletLevel))][1]/preceding-sibling::*)+1"/>
                                </xsl:variable>
                                <xsl:choose>
                                  <!-\- beam and tuplet end simultaneously, beam is superfluous -\->
                                  <xsl:when test="$endBeam = $endTuplet">
                                    <xsl:text>&tupletstart;</xsl:text>
                                    <xsl:copy-of select="."/>
                                  </xsl:when>
                                  <!-\- tuplet ends before beam, open beam first -\->
                                  <xsl:when test="$endTuplet &lt; $endBeam">
                                    <xsl:text>&beamstart;&tupletstart;</xsl:text>
                                    <xsl:copy-of select="."/>
                                  </xsl:when>
                                  <!-\- tuplet ends after beam, open tuplet first -\->
                                  <xsl:when test="$endTuplet &gt; $endBeam">
                                    <xsl:text>&tupletstart;&beamstart;</xsl:text>
                                    <xsl:copy-of select="."/>
                                  </xsl:when>
                                </xsl:choose>
                              </xsl:when>
                              <!-\- starts beam, but not tuplet -\->
                              <xsl:otherwise>
                                <xsl:text>&beamstart;</xsl:text>
                                <xsl:copy-of select="."/>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:when>
                          <!-\- ends beam -\->
                          <xsl:when test="starts-with(@beam,'t')">
                            <xsl:variable name="beamLevel">
                              <xsl:value-of select="substring(@beam, 2)"/>
                            </xsl:variable>
                            <xsl:choose>
                              <!-\- also ends tuplet -\->
                              <xsl:when test="starts-with(@tuplet, 't')">
                                <xsl:variable name="startBeam" as="xs:integer">
                                  <xsl:value-of
                                    select="count(preceding-sibling::*[starts-with(@beam,
                                    concat('i', $beamLevel))][1]/preceding-sibling::*)+1"/>
                                </xsl:variable>
                                <xsl:variable name="tupletLevel">
                                  <xsl:value-of select="substring(@tuplet, 2)"/>
                                </xsl:variable>
                                <xsl:variable name="startTuplet" as="xs:integer">
                                  <xsl:value-of
                                    select="count(preceding-sibling::*[starts-with(@tuplet,
                                    concat('i', $tupletLevel))][1]/preceding-sibling::*)+1"/>
                                </xsl:variable>
                                <xsl:choose>
                                  <!-\- beam and tuplet start simultaneously, beam is superfluous -\->
                                  <xsl:when test="$startBeam = $startTuplet">
                                    <xsl:copy-of select="."/>
                                    <xsl:text>&tupletend;</xsl:text>
                                  </xsl:when>
                                  <!-\- tuplet starts before beam, close beam first -\->
                                  <xsl:when test="$startTuplet &lt; $startBeam">
                                    <xsl:copy-of select="."/>
                                    <xsl:text>&beamend;&tupletend;</xsl:text>
                                  </xsl:when>
                                  <!-\- tuplet starts after beam, close tuplet first -\->
                                  <xsl:when test="$startTuplet &gt; $startBeam">
                                    <xsl:copy-of select="."/>
                                    <xsl:text>&tupletend;&beamend;</xsl:text>
                                  </xsl:when>
                                </xsl:choose>
                              </xsl:when>
                              <!-\- ends beam, but not tuplet -\->
                              <xsl:otherwise>
                                <xsl:copy-of select="."/>
                                <xsl:text>&beamend;</xsl:text>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:when>
                          <!-\- starts tuplet, but not beam -\->
                          <xsl:when test="starts-with(@tuplet, 'i')">
                            <xsl:text>&tupletstart;</xsl:text>
                            <xsl:copy-of select="."/>
                          </xsl:when>
                          <!-\- ends tuplet, but not beam -\->
                          <xsl:when test="starts-with(@tuplet, 't')">
                            <xsl:copy-of select="."/>
                            <xsl:text>&tupletend;</xsl:text>
                          </xsl:when>
                          <!-\- no beam or tuplet, or middle notes of beam and tuplet -\->
                          <xsl:otherwise>
                            <xsl:copy-of select="."/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:for-each>
                    </layer>
                  </xsl:for-each>
                </staff>
              </xsl:for-each>
            </xsl:for-each-group>
          </xsl:variable>
          <xsl:copy-of select="$byStaff3"/>-->

        </xsl:for-each-group>

        <!-- Copy controlevents -->
        <xsl:for-each select="mei:annot|mei:arpeg|mei:beamSpan|mei:bend|mei:dir|mei:dynam|
          mei:fermata|mei:gliss|mei:hairpin|mei:harm|mei:lyrics|mei:midi|
          mei:mordent|mei:octave|mei:pedal|mei:reh|mei:slur|mei:tempo|mei:tie|
          mei:trill|mei:tupletSpan|mei:turn">
          <!-- Sort control events by timestamp, staff, and element name -->
          <xsl:sort select="number(@tstamp)"/>
          <xsl:sort select="number(@staff)"/>
          <xsl:sort select="local-name()"/>
          <xsl:choose>
            <xsl:when test="local-name()='beamSpan' or local-name()='hairpin' or local-name()='slur'
              or local-name()='tie' or local-name()='tupletSpan'">
              <xsl:choose>
                <xsl:when test="@tstamp2 or @dur or @dur.ges or @endid!=''">
                  <xsl:copy-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="warning">
                    <xsl:text>Unterminated </xsl:text>
                    <xsl:value-of select="local-name()"/>
                  </xsl:variable>
                  <xsl:call-template name="warningPhase2">
                    <xsl:with-param name="warning">
                      <xsl:value-of select="$warning"/>
                    </xsl:with-param>
                    <xsl:with-param name="measureNum">
                      <xsl:value-of select="$measureNum"/>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>

        <!-- Copy graphic primitives -->
        <xsl:copy-of select="curve|line"/>

        <!-- Copy comments -->
        <xsl:for-each select="comment()">
          <xsl:copy-of select="."/>
          <xsl:value-of select="$nl"/>
        </xsl:for-each>

      </measure>
    </xsl:for-each>

  </xsl:template>

  <xsl:template match="mei:chord" mode="chordThis">
    <!-- Copy some note attributes to the parent chord -->
    <xsl:variable name="chordThis2">
      <chord xmlns="http://www.music-encoding.org/ns/mei">
        <xsl:attribute name="xml:id">
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>

        <!-- Copy note attributes that always rightfully belong to the whole chord -->
        <xsl:copy-of select="mei:note[@dots][1]/@dots | mei:note[@dur][1]/@dur |
          mei:note[@dur.ges][1]/@dur.ges | mei:note[@stem.dir][1]/@stem.dir |
          mei:note[@stem.len][1]/@stem.len | mei:note[@tstamp.ges][1]/@tstamp.ges |
          mei:note[@tuplet][1]/@tuplet"/>

        <!-- Copy these attrs if even *only one* of the notes has the attr -->
        <xsl:if test="mei:note[@fermata]">
          <xsl:copy-of select="mei:note[@fermata][1]/@fermata"/>
        </xsl:if>
        <xsl:if test="mei:note[@grace]">
          <xsl:copy-of select="mei:note[@grace][1]/@grace"/>
        </xsl:if>
        <xsl:if test="mei:note[@beam]">
          <xsl:copy-of select="mei:note[@beam][1]/@beam"/>
        </xsl:if>
        <xsl:if test="mei:note[@stem.x]">
          <xsl:copy-of select="mei:note[@stem.x][1]/@stem.x"/>
        </xsl:if>
        <xsl:if test="mei:note[@artic]">
          <xsl:copy-of select="mei:note[@artic][1]/@artic"/>
        </xsl:if>

        <!-- Copy these attrs if *all* notes have the the same value for the attribute -->
        <xsl:if test="count(mei:note[@part])=count(mei:note)">
          <xsl:if test="count(distinct-values(mei:note/@part))=1">
            <xsl:copy-of select="mei:note[@part][1]/@part"/>
          </xsl:if>
        </xsl:if>
        <xsl:if test="count(mei:note[@staff])=count(mei:note)">
          <xsl:if test="count(distinct-values(mei:note/@staff))=1">
            <xsl:copy-of select="mei:note[@staff][1]/@staff"/>
          </xsl:if>
        </xsl:if>
        <xsl:if test="count(mei:note[@layer])=count(mei:note)">
          <xsl:if test="count(distinct-values(mei:note/@layer))=1">
            <xsl:copy-of select="mei:note[@staff][1]/@layer"/>
          </xsl:if>
        </xsl:if>
        <xsl:if test="count(mei:note[@size])=count(mei:note)">
          <xsl:if test="count(distinct-values(mei:note/@size))=1">
            <xsl:copy-of select="mei:note[@size][1]/@size"/>
          </xsl:if>
        </xsl:if>
        <xsl:if test="count(mei:note[@instr])=count(mei:note)">
          <xsl:if test="count(distinct-values(mei:note/@instr))=1">
            <xsl:copy-of select="mei:note[@instr][1]/@instr"/>
          </xsl:if>
        </xsl:if>
        <xsl:if test="count(mei:note[@beam])=count(mei:note)">
          <xsl:if test="count(distinct-values(mei:note/@beam))=1">
            <xsl:copy-of select="mei:note[@beam][1]/@beam"/>
          </xsl:if>
        </xsl:if>
        <xsl:if test="count(mei:note[@tie])=count(mei:note)">
          <xsl:if test="count(distinct-values(mei:note/@tie))=1">
            <xsl:copy-of select="mei:note[@tie][1]/@tie"/>
          </xsl:if>
        </xsl:if>
        <xsl:if test="count(mei:note[@grace.time])=count(mei:note)">
          <xsl:if test="count(distinct-values(mei:note/@grace.time))=1">
            <xsl:copy-of select="mei:note[@grace.time][1]/@grace.time"/>
          </xsl:if>
        </xsl:if>
        <xsl:if test="count(mei:note[@headshape])=count(mei:note)">
          <xsl:if test="count(distinct-values(mei:note/@headshape))=1">
            <xsl:copy-of select="mei:note[@headshape][1]/@headshape"/>
          </xsl:if>
        </xsl:if>
        <xsl:if test="count(mei:note[@x])=count(mei:note)">
          <xsl:if test="count(distinct-values(mei:note/@x))=1">
            <xsl:copy-of select="mei:note[@x][1]/@x"/>
          </xsl:if>
        </xsl:if>

        <!-- Copy notes -->
        <xsl:copy-of select="mei:note"/>
      </chord>
    </xsl:variable>
    <xsl:apply-templates select="$chordThis2/mei:chord" mode="thinNoteAttributes"/>
  </xsl:template>

  <xsl:template match="mei:chord" mode="thinNoteAttributes">
    <!-- Eliminate note attributes copied to parent chord -->
    <chord xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:copy-of select="@*"/>
      <xsl:variable name="sortedStaff">
        <xsl:perform-sort select="distinct-values(mei:note/@staff)">
          <xsl:sort select="." data-type="number"/>
        </xsl:perform-sort>
      </xsl:variable>
      <xsl:attribute name="staff">
        <xsl:value-of select="$sortedStaff"/>
      </xsl:attribute>
      <xsl:variable name="sortedLayer">
        <xsl:perform-sort select="distinct-values(mei:note/@layer)">
          <xsl:sort select="." data-type="number"/>
        </xsl:perform-sort>
      </xsl:variable>
      <xsl:attribute name="layer">
        <xsl:value-of select="$sortedLayer"/>
      </xsl:attribute>
      <xsl:copy-of select="mei:note/mei:artic"/>
      <xsl:for-each select="mei:note">
        <xsl:sort select="@staff"/>
        <xsl:sort select="@layer"/>
        <note xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:copy-of select="@xml:id"/>
          <xsl:for-each select="@*">
            <xsl:variable name="thisAttr">
              <xsl:value-of select="local-name(.)"/>
            </xsl:variable>
            <!-- Copy any other note attributes (except @id which was handled above) that
            don't already exist on the parent chord -->
            <xsl:if test="not(ancestor::mei:chord/@*[name()=$thisAttr])">
              <xsl:copy-of select="."/>
            </xsl:if>
          </xsl:for-each>
          <!-- Copy children of the note except artic -->
          <xsl:copy-of select="child::*[not(local-name()='artic')]"/>
        </note>
      </xsl:for-each>
    </chord>
  </xsl:template>

  <xsl:template match="mei:staffDef|mei:staffGrp|part-group" mode="numberStaves">
    <!-- Number staves -->
    <xsl:choose>
      <xsl:when test="local-name()='staffDef'">
        <staffDef xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:attribute name="n">
            <xsl:value-of select="count(preceding::mei:staffDef) + 1"/>
          </xsl:attribute>
          <xsl:copy-of select="@*|node()"/>
        </staffDef>
      </xsl:when>
      <xsl:when test="local-name()='staffGrp'">
        <staffGrp xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:copy-of select="@*|mei:label|mei:instrDef"/>
          <xsl:for-each select="mei:staffDef">
            <staffDef xmlns="http://www.music-encoding.org/ns/mei">
              <xsl:attribute name="n">
                <xsl:value-of select="count(preceding::mei:staffDef) + 1"/>
              </xsl:attribute>
              <xsl:copy-of select="@*|node()"/>
            </staffDef>
          </xsl:for-each>
        </staffGrp>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="note" mode="arpegContinue">
    <xsl:value-of select="generate-id()"/>
    <xsl:if test="following-sibling::note[1][chord and notations/arpeggiate]">
      <xsl:text>&#32;</xsl:text>
      <xsl:apply-templates select="following-sibling::note[1]" mode="arpegContinue"/>
    </xsl:if>
  </xsl:template>

  <!--<xsl:template match="note" mode="arpegLayer">
    <xsl:choose>
      <xsl:when test="voice">
        <xsl:value-of select="voice"/>
      </xsl:when>
      <xsl:otherwise>1</xsl:otherwise>
    </xsl:choose>
    <xsl:if test="following-sibling::note[1][chord and notations/arpeggiate]">
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="following-sibling::note[1]" mode="arpegLayer"/>
    </xsl:if>
  </xsl:template>-->

  <xsl:template match="note" mode="arpegStaff">
    <xsl:variable name="partID">
      <xsl:value-of select="ancestor::part[1]/@id"/>
    </xsl:variable>
    <xsl:variable name="partStaff">
      <xsl:choose>
        <xsl:when test="staff">
          <xsl:value-of select="staff"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="getStaffNum">
      <xsl:with-param name="partID">
        <xsl:value-of select="$partID"/>
      </xsl:with-param>
      <xsl:with-param name="partStaff">
        <xsl:value-of select="$partStaff"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="following-sibling::note[1][chord and notations/arpeggiate]">
      <xsl:text>&#32;</xsl:text>
      <xsl:apply-templates select="following-sibling::note[1]" mode="arpegStaff"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="note" mode="nonarpegContinue">
    <xsl:value-of select="generate-id()"/>
    <xsl:if test="following-sibling::note[1][chord]">
      <xsl:text>&#32;</xsl:text>
      <xsl:apply-templates select="following-sibling::note[1]" mode="nonarpegContinue"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="note" mode="nonarpegStaff">
    <xsl:variable name="partID">
      <xsl:value-of select="ancestor::part[1]/@id"/>
    </xsl:variable>
    <xsl:variable name="partStaff">
      <xsl:choose>
        <xsl:when test="staff">
          <xsl:value-of select="staff"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="getStaffNum">
      <xsl:with-param name="partID">
        <xsl:value-of select="$partID"/>
      </xsl:with-param>
      <xsl:with-param name="partStaff">
        <xsl:value-of select="$partStaff"/>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:if test="following-sibling::note[1][chord]">
      <xsl:text>&#32;</xsl:text>
      <xsl:apply-templates select="following-sibling::note[1]" mode="arpegStaff"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="note" mode="oneNote">
    <!-- Create a note/rest element -->
    <xsl:choose>
      <xsl:when test="rest">
        <xsl:variable name="thisPart">
          <xsl:value-of select="ancestor::part/@id"/>
        </xsl:variable>
        <xsl:variable name="ppq">
          <xsl:choose>
            <xsl:when test="ancestor::part[attributes/divisions]">
              <xsl:value-of select="ancestor::part[attributes/divisions]/attributes/divisions[1]"/>
            </xsl:when>
            <xsl:when test="preceding::part[@id=$thisPart and attributes/divisions]">
              <xsl:value-of select="preceding::part[@id=$thisPart and
                attributes/divisions][1]/attributes/divisions"/>
            </xsl:when>
            <xsl:when test="following::part[@id=$thisPart and attributes/divisions]">
              <xsl:value-of select="following::part[@id=$thisPart and
                attributes/divisions][1]/attributes/divisions"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$scorePPQ"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="meterCount">
          <xsl:choose>
            <xsl:when test="ancestor::part[attributes/time/beats]/attributes/time/beats">
              <xsl:value-of
                select="saxon:evaluate(ancestor::part[attributes/time/beats]/attributes/time/beats)"
              />
            </xsl:when>
            <xsl:when test="preceding::part[@id=$thisPart and attributes/time]">
              <xsl:value-of select="saxon:evaluate(preceding::part[@id=$thisPart and
                attributes/time][1]/attributes/time/beats)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="sum(ancestor::part/note/duration) div $ppq"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="meterUnit">
          <xsl:choose>
            <xsl:when test="ancestor::part[@id=$thisPart and
              attributes/time/beat-type]/attributes/time/beat-type">
              <xsl:value-of select="ancestor::part[@id=$thisPart and
                attributes/time/beat-type]/attributes/time/beat-type"/>
            </xsl:when>
            <xsl:when test="preceding::part[@id=$thisPart and attributes/time]">
              <xsl:value-of select="preceding::part[@id=$thisPart and
                attributes/time][1]/attributes/time/beat-type"/>
            </xsl:when>
            <xsl:otherwise>4</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="measureDuration">
          <xsl:call-template name="measureDuration">
            <xsl:with-param name="meterCount">
              <xsl:value-of select="$meterCount"/>
            </xsl:with-param>
            <xsl:with-param name="meterUnit">
              <xsl:value-of select="$meterUnit"/>
            </xsl:with-param>
            <xsl:with-param name="ppq">
              <xsl:value-of select="$ppq"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="restType">
          <xsl:choose>
            <!-- whole rest and no other events present -->
            <xsl:when test="type='whole' and
              count(preceding-sibling::note)+count(following-sibling::note)=0">
              <xsl:text>mRest</xsl:text>
            </xsl:when>
            <!-- has type (visual duration) -->
            <xsl:when test="type">
              <xsl:text>rest</xsl:text>
            </xsl:when>
            <!-- no type, multi-measure rest -->
            <xsl:when
              test="preceding-sibling::attributes[measure-style/multiple-rest][1]/measure-style/multiple-rest">
              <xsl:choose>
                <xsl:when test="count(ancestor::measure/part) &gt; 1">
                  <xsl:variable name="measureNum">
                    <xsl:value-of select="ancestor::measure/@number"/>
                  </xsl:variable>
                  <xsl:variable name="errorMessage">
                    <xsl:text>Cannot convert multi-measure rests when there is more than one &lt;part&gt;</xsl:text>
                  </xsl:variable>
                  <xsl:message terminate="yes">
                    <xsl:value-of select="normalize-space(concat($errorMessage, ' (m. ',
                      $measureNum, ').'))"/>
                  </xsl:message>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>multiRest</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <!-- no type, but rest duration equals measure duration -->
            <xsl:when test="duration = $measureDuration">
              <xsl:text>mRest</xsl:text>
            </xsl:when>
            <!-- no type, but rest claims measure duration -->
            <xsl:when test="rest/@measure='yes'">
              <xsl:choose>
                <xsl:when test="duration = $measureDuration">
                  <xsl:text>mRest</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>rest</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <!-- all other cases -->
            <xsl:otherwise>
              <xsl:text>rest</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:element name="{$restType}" namespace="http://www.music-encoding.org/ns/mei">
          <xsl:attribute name="xml:id">
            <xsl:value-of select="generate-id()"/>
          </xsl:attribute>
          <xsl:attribute name="tstamp.ges">
            <xsl:call-template name="getTimestamp.ges"/>
          </xsl:attribute>
          <xsl:choose>
            <xsl:when test="$restType='multiRest'">
              <xsl:attribute name="n">
                <xsl:value-of
                  select="preceding-sibling::attributes[measure-style/multiple-rest][1]/measure-style/multiple-rest"
                />
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="type">
              <xsl:attribute name="dur">
                <xsl:for-each select="type">
                  <xsl:call-template name="notatedDuration"/>
                </xsl:for-each>
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="dur">
                <xsl:call-template name="quantizedDuration">
                  <xsl:with-param name="duration">
                    <xsl:value-of select="duration"/>
                  </xsl:with-param>
                  <xsl:with-param name="ppq">
                    <xsl:value-of select="$ppq"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:variable>
              <xsl:attribute name="dur">
                <xsl:value-of select="replace($dur, '\..*$', '')"/>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:call-template name="notatedDot"/>
          <xsl:call-template name="fermata"/>
          <xsl:if test="duration">
            <xsl:choose>
              <xsl:when test="$restType='multiRest'">
                <xsl:attribute name="dur.ges">
                  <xsl:value-of select="$measureDuration *
                    preceding-sibling::attributes[measure-style/multiple-rest][1]/measure-style/multiple-rest"/>
                  <xsl:text>p</xsl:text>
                </xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="gesturalDuration"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
          <xsl:call-template name="assignPart-Layer-Staff-Beam-Tuplet"/>
          <!--<xsl:call-template name="positionRelative"/>-->
          <xsl:call-template name="restvo"/>
          <xsl:call-template name="size"/>
          <xsl:call-template name="enclosingChars"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <!-- This is a 'pitched' or 'unpitched' note; i.e., not a rest. -->
        <note xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:attribute name="xml:id">
            <xsl:value-of select="generate-id()"/>
          </xsl:attribute>
          <xsl:attribute name="tstamp.ges">
            <xsl:call-template name="getTimestamp.ges"/>
          </xsl:attribute>
          <xsl:if test="@print-object='no'">
            <xsl:attribute name="visible">false</xsl:attribute>
          </xsl:if>

          <!-- Grace note -->
          <xsl:if test="grace">
            <xsl:choose>
              <xsl:when test="grace/@steal-time-following">
                <xsl:attribute name="grace">acc</xsl:attribute>
                <xsl:attribute name="grace.time">
                  <xsl:value-of select="replace(grace/@steal-time-following, '%', '')"/>
                  <xsl:text>%</xsl:text>
                </xsl:attribute>
                <xsl:if test="grace/@slash='yes'">
                  <xsl:attribute name="stem.mod">1slash</xsl:attribute>
                </xsl:if>
              </xsl:when>
              <xsl:when test="grace/@steal-time-previous">
                <xsl:attribute name="grace">unacc</xsl:attribute>
                <xsl:attribute name="grace.time">
                  <xsl:value-of select="replace(grace/@steal-time-previous, '%', '')"/>
                  <xsl:text>%</xsl:text>
                </xsl:attribute>
                <xsl:if test="grace/@slash='yes'">
                  <xsl:attribute name="stem.mod">1slash</xsl:attribute>
                </xsl:if>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="grace">unknown</xsl:attribute>
                <xsl:if test="grace/@slash='yes'">
                  <xsl:attribute name="stem.mod">1slash</xsl:attribute>
                </xsl:if>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>

          <!-- Notated pitch -->
          <xsl:choose>
            <xsl:when test="pitch">
              <xsl:attribute name="pname">
                <xsl:value-of select="lower-case(pitch/step)"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <!-- This note is unpitched, e.g., for unpitched percussion or of indeterminate pitch. -->
              <xsl:attribute name="pname">
                <xsl:value-of select="lower-case(unpitched/display-step)"/>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>

          <!-- Notated accidental in attribute. -->
          <xsl:if test="accidental">
            <xsl:choose>
              <xsl:when test="contains(accidental, 'slash)') or contains(accidental, 'sori') or
                contains(accidental, 'koron') or matches(accidental, '(sharp|flat)-[0-9]')">
                <xsl:variable name="measureNum">
                  <xsl:value-of select="ancestor::measure/@number"/>
                </xsl:variable>
                <xsl:variable name="warning">
                  <xsl:text>Middle-Eastern accidentals ignored</xsl:text>
                </xsl:variable>
                <xsl:message>
                  <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
                    ').'))"/>
                </xsl:message>
              </xsl:when>
              <xsl:otherwise>
                <xsl:attribute name="accid">
                  <xsl:choose>
                    <xsl:when test="accidental = 'sharp'">s</xsl:when>
                    <xsl:when test="accidental = 'natural'">n</xsl:when>
                    <xsl:when test="accidental = 'flat'">f</xsl:when>
                    <xsl:when test="accidental = 'double-sharp'">x</xsl:when>
                    <xsl:when test="accidental = 'double-flat'">ff</xsl:when>
                    <xsl:when test="accidental = 'sharp-sharp'">ss</xsl:when>
                    <xsl:when test="accidental = 'flat-flat'">ff</xsl:when>
                    <xsl:when test="accidental = 'natural-sharp'">ns</xsl:when>
                    <xsl:when test="accidental = 'natural-flat'">nf</xsl:when>
                    <xsl:when test="accidental = 'quarter-flat'">fu</xsl:when>
                    <xsl:when test="accidental = 'quarter-sharp'">sd</xsl:when>
                    <xsl:when test="accidental = 'three-quarters-sharp'">su</xsl:when>
                    <xsl:when test="accidental = 'three-quarters-flat'">fd</xsl:when>
                    <xsl:when test="accidental = 'triple-sharp'">ts</xsl:when>
                    <xsl:when test="accidental = 'triple-flat'">tf</xsl:when>
                  </xsl:choose>
                </xsl:attribute>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>

          <!-- Notated/performed octave -->
          <xsl:choose>
            <xsl:when test="pitch">
              <xsl:variable name="thisPart">
                <xsl:value-of select="ancestor::part/@id"/>
              </xsl:variable>
              <xsl:variable name="partStaff">
                <xsl:choose>
                  <xsl:when test="staff">
                    <xsl:value-of select="staff"/>
                  </xsl:when>
                  <xsl:otherwise>1</xsl:otherwise>
                </xsl:choose>
              </xsl:variable>
              <xsl:variable name="octaveShift">
                <xsl:value-of select="count(preceding::octave-shift[not(@type='stop') and
                  ancestor::part/@id=$thisPart]) -
                  count(preceding::octave-shift[@type='stop' and ancestor::part/@id=$thisPart])"/>
              </xsl:variable>
              <xsl:choose>
                <xsl:when test="$octaveShift &gt; 0">
                  <xsl:variable name="shift">
                    <xsl:variable name="size">
                      <xsl:value-of select="number(preceding::octave-shift[not(@type='stop') and
                        ancestor::part/@id=$thisPart][1]/@size)"/>
                    </xsl:variable>
                    <xsl:choose>
                      <xsl:when test="$size='8'">1</xsl:when>
                      <xsl:when test="$size='15'">2</xsl:when>
                      <xsl:when test="$size='22'">3</xsl:when>
                      <xsl:otherwise>
                        <!-- Bad value for @size; choose closest logical value -->
                        <xsl:choose>
                          <xsl:when test="(abs($size - 8) &lt; abs($size
                            - 15)) and (abs($size - 8) &lt; abs($size -
                            22))">
                            <!-- 8 is closest to the value of @size -->
                            <xsl:value-of select="1"/>
                          </xsl:when>
                          <xsl:when test="(abs($size - 15) &lt;
                            abs($size - 8)) and (abs($size - 15) &lt;
                            abs($size - 22))">
                            <!-- 15 is closest to the value of @size -->
                            <xsl:value-of select="2"/>
                          </xsl:when>
                          <xsl:otherwise>
                            <!-- 22 is closest to the value of @size -->
                            <xsl:value-of select="3"/>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <xsl:variable name="direction">
                    <xsl:value-of select="preceding::octave-shift[not(@type='stop') and
                      ancestor::part/@id=$thisPart][1]/@type"/>
                  </xsl:variable>
                  <xsl:choose>
                    <xsl:when test="$direction='down'">
                      <xsl:attribute name="oct">
                        <xsl:value-of select="pitch/octave - $shift"/>
                      </xsl:attribute>
                    </xsl:when>
                    <xsl:when test="$direction='up'">
                      <xsl:attribute name="oct">
                        <xsl:value-of select="pitch/octave + $shift"/>
                      </xsl:attribute>
                    </xsl:when>
                  </xsl:choose>
                  <xsl:attribute name="oct.ges">
                    <xsl:value-of select="pitch/octave"/>
                  </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="oct">
                    <xsl:value-of select="pitch/octave"/>
                  </xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <!-- This note is of indeterminate pitch. -->
              <xsl:attribute name="oct">
                <xsl:value-of select="unpitched/display-octave"/>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>

          <!-- String tablature -->
          <xsl:if test="notations/technical/string[normalize-space(text()) != '']">
            <xsl:attribute name="tab.string">
              <xsl:value-of select="notations/technical/string"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="notations/technical/fret[normalize-space(text()) != '']">
            <xsl:attribute name="tab.fret">
              <xsl:choose>
                <xsl:when test="matches(notations/technical/fret, '0')">
                  <xsl:text>o</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="notations/technical/fret"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </xsl:if>
          <!-- Should hammer-on and pull-off generate values in @slur? -->
          <!--<xsl:if test="notations/technical/*[local-name()='hammer-on' or local-name()='pull-off']">
            <!-\- hammer-on and pull-off indicate methods for connecting, i.e., slurring, notes -\->
            <xsl:attribute name="slur">
              <xsl:for-each select="notations/technical/*[local-name()='hammer-on' or
                local-name()='pull-off'][@type='start'][1]">
                <xsl:text>i</xsl:text>
              </xsl:for-each>
              <xsl:for-each select="notations/technical/*[local-name()='hammer-on' or
                local-name()='pull-off'][@type='stop'][1]">
                <xsl:if test="../*[local-name()='hammer-on' or
                  local-name()='pull-off'][@type='start']">
                  <xsl:text>&#32;</xsl:text>
                </xsl:if>
                <xsl:text>t</xsl:text>
              </xsl:for-each>
            </xsl:attribute>
          </xsl:if>-->

          <!-- Note attributes -->
          <xsl:variable name="notatedDuration">
            <xsl:for-each select="type[1]">
              <xsl:call-template name="notatedDuration"/>
            </xsl:for-each>
          </xsl:variable>
          <xsl:if test="$notatedDuration != ''">
            <xsl:attribute name="dur">
              <xsl:value-of select="$notatedDuration"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:call-template name="notatedDot"/>
          <xsl:call-template name="fermata"/>
          <xsl:call-template name="artics"/>
          <xsl:call-template name="gesturalDuration"/>
          <xsl:call-template name="assignPart-Layer-Staff-Beam-Tuplet"/>
          <!--<xsl:call-template name="positionRelative"/>-->
          <xsl:call-template name="size"/>
          <xsl:call-template name="color"/>
          <xsl:call-template name="enclosingChars"/>

          <!-- Notated tie in attribute:
               I'm using notations/tied here instead of note/tie because note/tie
               doesn't provide indication of middle notes in a tie, only start and stop.
               None of the current MusicXML examples record the position of ties. -->
          <xsl:choose>
            <xsl:when test="notations/tied/@type='start' and notations/tied/@type='stop'">
              <xsl:attribute name="tie">m</xsl:attribute>
            </xsl:when>
            <xsl:when test="notations/tied/@type='start'">
              <xsl:attribute name="tie">i</xsl:attribute>
            </xsl:when>
            <xsl:when test="notations/tied/@type='stop'">
              <xsl:attribute name="tie">t</xsl:attribute>
            </xsl:when>
          </xsl:choose>

          <!-- Stem attributes: direction and length
               MusicXML uses a text value of 'none' to record a zero-length stem, but
               stem/@relative-y or @default-y to record non-zero stem length. -->
          <xsl:choose>
            <xsl:when test="stem='up'">
              <xsl:attribute name="stem.dir">up</xsl:attribute>
            </xsl:when>
            <xsl:when test="stem='down'">
              <xsl:attribute name="stem.dir">down</xsl:attribute>
            </xsl:when>
            <xsl:when test="stem='none'">
              <xsl:attribute name="stem.len">0</xsl:attribute>
            </xsl:when>
            <xsl:when test="stem='double'">
              <!-- MEI doesn't allow 'double' stems because this is an indication
                of multiple layers. -->
            </xsl:when>
          </xsl:choose>
          <!-- Stem length calcultion is BROKEN! -->
          <!-- <xsl:if test="stem/@default-y != 0">
            <xsl:attribute name="stem.len">
              <xsl:value-of select="format-number(stem/@default-y div 5,
                '###0.####')"/>
              <!-\- <xsl:text>vu</xsl:text> -\->
            </xsl:attribute>
          </xsl:if> -->

          <!-- Bowed tremolo -->
          <xsl:if test="notations/ornaments/tremolo">
            <xsl:attribute name="stem.mod">
              <xsl:value-of select="notations/ornaments/tremolo[1]"/>
              <xsl:text>slash</xsl:text>
            </xsl:attribute>
          </xsl:if>

          <!-- Notehead shape -->
          <!-- It's not usually necessary in CMN to be explicit about 
          whether a notehead is filled or not since the shape ought to
          be filled if the duration is <= quarter and open otherwise. -->
          <xsl:choose>
            <xsl:when test="notehead='slash'">
              <xsl:attribute name="headshape">
                <xsl:text>slash</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='triangle'">
              <xsl:attribute name="headshape">
                <xsl:text>isotriangle</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='diamond'">
              <xsl:attribute name="headshape">
                <xsl:text>diamond</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='square'">
              <xsl:attribute name="headshape">
                <xsl:text>rectangle</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='cross'">
              <xsl:attribute name="headshape">
                <xsl:text>cross</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='x'">
              <xsl:attribute name="headshape">
                <xsl:text>x</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='circle-x'">
              <xsl:attribute name="headshape">
                <xsl:text>circlex</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='inverted triangle'">
              <xsl:attribute name="headshape">
                <xsl:text>isotriangle</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='arrow down'">
              <xsl:attribute name="headshape">
                <xsl:text>isotriangle</xsl:text>
              </xsl:attribute>
              <!-- Mup doesn't support centered stems -->
              <xsl:attribute name="stem.pos">
                <xsl:text>center</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='arrow up'">
              <xsl:attribute name="headshape">
                <xsl:text>isotriangle</xsl:text>
              </xsl:attribute>
              <!-- Mup doesn't support centered stems -->
              <xsl:attribute name="stem.pos">
                <xsl:text>center</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='slashed'">
              <xsl:variable name="measureNum">
                <xsl:value-of select="ancestor::measure/@number"/>
              </xsl:variable>
              <xsl:variable name="warning">
                <xsl:text>Notehead 'slashed' not supported</xsl:text>
              </xsl:variable>
              <xsl:message>
                <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
                  ').'))"/>
              </xsl:message>
              <xsl:attribute name="headshape">
                <xsl:text>addslash</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='back slashed'">
              <xsl:variable name="measureNum">
                <xsl:value-of select="ancestor::measure/@number"/>
              </xsl:variable>
              <xsl:variable name="warning">
                <xsl:text>Notehead 'back slashed' not supported</xsl:text>
              </xsl:variable>
              <xsl:message>
                <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
                  ').'))"/>
              </xsl:message>
              <xsl:attribute name="headshape">
                <xsl:text>addbackslash</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='normal'">
              <!-- Regular notehead, nothing to do! -->
            </xsl:when>
            <xsl:when test="notehead='cluster'">
              <xsl:attribute name="headshape">
                <xsl:choose>
                  <xsl:when test="notehead/@filled='yes'">
                    <xsl:text>blbox</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>whbox</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='none'">
              <xsl:attribute name="headshape">
                <xsl:text>blank</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='do'">
              <xsl:attribute name="headshape">
                <xsl:text>isotriangle</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='re'">
              <xsl:attribute name="headshape">
                <xsl:text>semicircle</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='mi'">
              <xsl:attribute name="headshape">
                <xsl:text>diamond</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='fa'">
              <xsl:attribute name="headshape">
                <xsl:text>righttriangle</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='so'">
              <!-- Regular notehead, nothing to do! -->
            </xsl:when>
            <xsl:when test="notehead='la'">
              <xsl:attribute name="headshape">
                <xsl:text>rectangle</xsl:text>
              </xsl:attribute>
            </xsl:when>
            <xsl:when test="notehead='ti'">
              <xsl:attribute name="headshape">
                <xsl:text>piewedge</xsl:text>
              </xsl:attribute>
            </xsl:when>
          </xsl:choose>

          <!-- Gestural accidentals in attribute -->
          <xsl:variable name="thisPitch">
            <xsl:value-of select="pitch/step"/>
          </xsl:variable>
          <xsl:variable name="thisOctave">
            <xsl:value-of select="pitch/octave"/>
          </xsl:variable>

          <xsl:choose>
            <xsl:when test="accidental">
              <!-- Accidental already in effect on this note -->
            </xsl:when>
            <xsl:when test="pitch/alter">
              <xsl:choose>
                <xsl:when test="pitch/alter = 2">
                  <xsl:attribute name="accid.ges">ss</xsl:attribute>
                </xsl:when>
                <xsl:when test="pitch/alter = 1.5">
                  <xsl:attribute name="accid.ges">su</xsl:attribute>
                </xsl:when>
                <xsl:when test="pitch/alter = 1">
                  <xsl:attribute name="accid.ges">s</xsl:attribute>
                </xsl:when>
                <xsl:when test="pitch/alter = .5">
                  <xsl:attribute name="accid.ges">sd</xsl:attribute>
                </xsl:when>
                <xsl:when test="pitch/alter = -.5">
                  <xsl:attribute name="accid.ges">fu</xsl:attribute>
                </xsl:when>
                <xsl:when test="pitch/alter = -1">
                  <xsl:attribute name="accid.ges">f</xsl:attribute>
                </xsl:when>
                <xsl:when test="pitch/alter = -1.5">
                  <xsl:attribute name="accid.ges">fd</xsl:attribute>
                </xsl:when>
                <xsl:when test="pitch/alter = -2">
                  <xsl:attribute name="accid.ges">ff</xsl:attribute>
                </xsl:when>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="preceding-sibling::note[pitch/step=$thisPitch and
              pitch/octave=$thisOctave and accidental]">
              <xsl:variable name="precedingAccidental">
                <xsl:value-of select="preceding-sibling::note[pitch/step=$thisPitch and
                  pitch/octave=$thisOctave and accidental][1]/accidental"/>
              </xsl:variable>

              <xsl:choose>
                <xsl:when test="contains($precedingAccidental, 'slash)') or
                  contains($precedingAccidental, 'sori') or
                  contains($precedingAccidental, 'koron') or matches($precedingAccidental,
                  '(sharp|flat)-[0-9]')">
                  <xsl:variable name="measureNum">
                    <xsl:value-of select="ancestor::measure/@number"/>
                  </xsl:variable>
                  <xsl:variable name="warning">
                    <xsl:text>Middle-Eastern accidentals ignored</xsl:text>
                  </xsl:variable>
                  <xsl:message>
                    <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
                      ').'))"/>
                  </xsl:message>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:attribute name="accid.ges">
                    <xsl:choose>
                      <xsl:when test="$precedingAccidental = 'sharp'">s</xsl:when>
                      <xsl:when test="$precedingAccidental = 'natural'">n</xsl:when>
                      <xsl:when test="$precedingAccidental = 'flat'">f</xsl:when>
                      <xsl:when test="$precedingAccidental = 'double-sharp'">x</xsl:when>
                      <xsl:when test="$precedingAccidental = 'double-flat'">ff</xsl:when>
                      <xsl:when test="$precedingAccidental = 'sharp-sharp'">ss</xsl:when>
                      <xsl:when test="$precedingAccidental = 'flat-flat'">ff</xsl:when>
                      <xsl:when test="$precedingAccidental = 'natural-sharp'">ns</xsl:when>
                      <xsl:when test="$precedingAccidental = 'natural-flat'">nf</xsl:when>
                      <xsl:when test="$precedingAccidental = 'flat-down'">fd</xsl:when>
                      <xsl:when test="$precedingAccidental = 'flat-up'">fu</xsl:when>
                      <xsl:when test="$precedingAccidental = 'natural-down'">nd</xsl:when>
                      <xsl:when test="$precedingAccidental = 'natural-up'">nu</xsl:when>
                      <xsl:when test="$precedingAccidental = 'sharp-down'">sd</xsl:when>
                      <xsl:when test="$precedingAccidental = 'sharp-up'">su</xsl:when>
                      <xsl:when test="$precedingAccidental = 'triple-sharp'">ts</xsl:when>
                      <xsl:when test="$precedingAccidental = 'triple-flat'">tf</xsl:when>
                    </xsl:choose>
                  </xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
          </xsl:choose>

          <!-- Instrument assignment -->
          <xsl:if test="instrument">
            <xsl:attribute name="instr">
              <xsl:value-of select="instrument/@id"/>
            </xsl:attribute>
            <xsl:variable name="noteNum">
              <xsl:value-of select="instrument/@id"/>
            </xsl:variable>
            <xsl:if test="preceding::midi-instrument[@id=$noteNum]/midi-unpitched">
              <xsl:attribute name="pnum">
                <xsl:value-of select="preceding::midi-instrument[@id=$noteNum][1]/midi-unpitched"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:if>

          <!-- Lyrics in attribute -->
          <xsl:if test="lyric">
            <xsl:attribute name="syl">
              <xsl:for-each select="lyric">
                <xsl:value-of select="text"/>
                <xsl:if test="syllabic='begin' or syllabic='middle'">
                  <xsl:text>-</xsl:text>
                </xsl:if>
                <xsl:if test="extend">
                  <xsl:text>_</xsl:text>
                </xsl:if>
                <xsl:if test="position() != last()">
                  <xsl:text>//</xsl:text>
                </xsl:if>
              </xsl:for-each>
            </xsl:attribute>
          </xsl:if>

          <!-- Create note sub-elements -->
          <xsl:call-template name="accidentals"/>
          <xsl:call-template name="articulations"/>
          <xsl:apply-templates select="lyric[text]" mode="stage1"/>

        </note>
        <!-- Test to see if following note is also part of the chord. -->
        <xsl:if test="following-sibling::note[1][chord]">
          <xsl:apply-templates select="following-sibling::note[1][chord]" mode="oneNote"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="enclosingChars">
    <!-- Chararacters that enclose a note or rest -->
    <xsl:if test="notehead/@parentheses='yes'">
      <xsl:attribute name="enclose">paren</xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template match="note[not(chord)]" mode="stage1">
    <!-- Non-chord tones -->
    <xsl:choose>
      <xsl:when test="following-sibling::note[1][chord]">
        <xsl:variable name="chordThis">
          <chord xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:apply-templates select="." mode="oneNote"/>
          </chord>
        </xsl:variable>
        <xsl:apply-templates select="$chordThis/mei:chord" mode="chordThis"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="oneNote"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="note[not(chord) and notations/arpeggiate]" mode="stage1.arpeg">
    <!-- Arpeggiated chords -->
    <arpeg xmlns="http://www.music-encoding.org/ns/mei">
      <!-- Tstamp attributes -->
      <xsl:call-template name="tstampAttrs"/>
      <!-- Attributes based on starting note -->
      <!-- Unfortunately, @startid isn't allowed on arpeg yet! However,
      adding it is necessary in order to mark arpeg as a "note-attached"
      control event. -->
      <!--<xsl:attribute name="startid">
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>-->
      <xsl:variable name="plist">
        <xsl:apply-templates select="." mode="arpegContinue"/>
      </xsl:variable>
      <xsl:attribute name="plist">
        <xsl:value-of select="$plist"/>
      </xsl:attribute>
      <!-- Record explicit arpeggio direction; arpeg indications
      without explicit direction "default" to convention, such as
      "same direction as preceding arpeggio". -->
      <xsl:if test="notations/arpeggiate/@direction">
        <xsl:attribute name="order">
          <xsl:value-of select="notations/arpeggiate/@direction"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:for-each select="notations/arpeggiate">
        <xsl:call-template name="positionRelative"/>
      </xsl:for-each>

      <!-- Arpeggiate across which staves? -->
      <xsl:attribute name="staff">
        <xsl:variable name="arpegStaves">
          <xsl:apply-templates select="." mode="arpegStaff"/>
        </xsl:variable>
        <xsl:value-of select="distinct-values(tokenize($arpegStaves, ' '))"/>
      </xsl:attribute>

      <!-- Arpeggiate across which layers? -->
      <!-- Layer must be determined later in "clean-up" step -->
      <!--<xsl:attribute name="layer">
        <xsl:variable name="arpegLayers">
          <xsl:apply-templates select="." mode="arpegLayer"/>
        </xsl:variable>
        <xsl:value-of select="distinct-values(tokenize($arpegLayers, ' '))"/>
      </xsl:attribute>-->
    </arpeg>
  </xsl:template>

  <xsl:template match="note[not(chord) and notations/non-arpeggiate]" mode="stage1.arpeg">
    <!-- Chords marked as "non-arpeggiated" -->
    <arpeg xmlns="http://www.music-encoding.org/ns/mei">
      <!-- Tstamp attributes -->
      <xsl:call-template name="tstampAttrs"/>
      <!-- Attributes based on starting note -->
      <!-- Unfortunately, @startid isn't allowed on arpeg yet! However,
      adding it is necessary in order to mark arpeg as a "note-attached"
      control event. -->
      <!--<xsl:attribute name="startid">
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>-->
      <xsl:variable name="plist">
        <xsl:apply-templates select="." mode="nonarpegContinue"/>
      </xsl:variable>
      <xsl:attribute name="plist">
        <xsl:value-of select="$plist"/>
      </xsl:attribute>
      <xsl:attribute name="order">
        <xsl:text>nonarp</xsl:text>
      </xsl:attribute>
      <xsl:for-each select="notations/non-arpeggiate">
        <xsl:call-template name="positionRelative"/>
      </xsl:for-each>

      <!-- Arpeggiate across which staves? -->
      <xsl:attribute name="staff">
        <xsl:variable name="arpegStaves">
          <xsl:apply-templates select="." mode="nonarpegStaff"/>
        </xsl:variable>
        <xsl:value-of select="distinct-values(tokenize($arpegStaves, ' '))"/>
      </xsl:attribute>

      <!-- Arpeggiate across which layers? -->
      <!-- Layer must be determined later in "clean-up" step -->
      <!--<xsl:attribute name="layer">
        <xsl:variable name="arpegLayers">
          <xsl:apply-templates select="." mode="arpegLayer"/>
        </xsl:variable>
        <xsl:value-of select="distinct-values(tokenize($arpegLayers, ' '))"/>
      </xsl:attribute>-->
    </arpeg>
  </xsl:template>

  <xsl:template match="note/beam[.='begin']" mode="stage1">
    <!-- Only primary beams are significant in MEI -->
    <!-- @number defaults to 1 -->
    <xsl:if test="@number = '1'">
      <beamSpan xmlns="http://www.music-encoding.org/ns/mei">
        <!-- Tstamp attributes -->
        <xsl:attribute name="xml:id" select="generate-id()"/>
        <xsl:for-each select="ancestor::note">
          <xsl:call-template name="tstampAttrs"/>
          <!-- Attributes based on starting note -->
          <xsl:attribute name="startid">
            <xsl:value-of select="generate-id()"/>
          </xsl:attribute>
        </xsl:for-each>
        <xsl:if test="@fan">
          <xsl:attribute name="rend">
            <xsl:choose>
              <xsl:when test="@fan='rit'">
                <xsl:text>rit</xsl:text>
              </xsl:when>
              <xsl:when test="@fan='accel'">
                <xsl:text>acc</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>norm</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:if>
        <!-- Attributes based on ending note -->
        <xsl:variable name="startMeasureID">
          <xsl:value-of select="generate-id(ancestor::measure[1])"/>
        </xsl:variable>
        <xsl:variable name="startMeasurePos">
          <xsl:for-each select="//measure">
            <xsl:if test="generate-id()=$startMeasureID">
              <xsl:value-of select="position()"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="partID">
          <xsl:value-of select="ancestor::part[1]/@id"/>
        </xsl:variable>
        <xsl:variable name="partStaff">
          <xsl:choose>
            <xsl:when test="ancestor::note/staff">
              <xsl:value-of select="ancestor::note/staff"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="staff1">
          <xsl:call-template name="getStaffNum">
            <xsl:with-param name="partID">
              <xsl:value-of select="$partID"/>
            </xsl:with-param>
            <xsl:with-param name="partStaff">
              <xsl:value-of select="$partStaff"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:variable>
        <xsl:for-each select="following::note[beam[@number='1'] = 'end'][1]">
          <xsl:variable name="endMeasureID">
            <xsl:value-of select="generate-id(ancestor::measure[1])"/>
          </xsl:variable>
          <xsl:variable name="endMeasurePos">
            <xsl:for-each select="//measure">
              <xsl:if test="generate-id()=$endMeasureID">
                <xsl:value-of select="position()"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:attribute name="tstamp2">
            <xsl:value-of select="$endMeasurePos - $startMeasurePos"/>
            <xsl:text>m+</xsl:text>
            <xsl:call-template name="tstamp.ges2beat">
              <xsl:with-param name="tstamp.ges">
                <xsl:call-template name="getTimestamp.ges"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="endid">
            <xsl:value-of select="generate-id()"/>
          </xsl:attribute>
          <xsl:variable name="partStaff2">
            <xsl:choose>
              <xsl:when test="staff">
                <xsl:value-of select="staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="staff2">
            <xsl:call-template name="getStaffNum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partStaff">
                <xsl:value-of select="$partStaff2"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <xsl:attribute name="staff">
            <xsl:value-of select="$staff1"/>
            <xsl:if test="$staff2 != $staff1">
              <xsl:text>&#32;</xsl:text>
              <xsl:value-of select="$staff2"/>
            </xsl:if>
          </xsl:attribute>
        </xsl:for-each>
      </beamSpan>
    </xsl:if>
  </xsl:template>

  <xsl:template match="note/notations/articulations/*" mode="stage1.dir">
    <xsl:choose>
      <xsl:when test="local-name()='breath-mark' or local-name()='caesura' or
        local-name()='stress' or local-name()='unstress'">
        <!-- Create control events -->
        <!-- Because breath-mark can contain text, it is transcoded as <dir>
        instead of <breath> in order to retain its content -->
        <dir xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:attribute name="label">
            <xsl:value-of select="local-name()"/>
          </xsl:attribute>
          <xsl:attribute name="tstamp">
            <xsl:call-template name="tstamp.ges2beat">
              <xsl:with-param name="tstamp.ges">
                <xsl:call-template name="getTimestamp.ges"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="tstamp.ges">
            <xsl:for-each select="ancestor::note[1]">
              <xsl:call-template name="getTimestamp.ges"/>
            </xsl:for-each>
          </xsl:attribute>
          <xsl:variable name="partID">
            <xsl:value-of select="ancestor::part[1]/@id"/>
          </xsl:variable>
          <xsl:variable name="partstaff">
            <xsl:choose>
              <xsl:when test="ancestor::note[1]/staff">
                <xsl:value-of select="ancestor::note[1]/staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="staff">
            <xsl:call-template name="getStaffNum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partStaff">
                <xsl:value-of select="$partstaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="place">
            <xsl:choose>
              <xsl:when test="@placement != ''">
                <xsl:value-of select="@placement"/>
              </xsl:when>
              <xsl:otherwise>above</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:attribute name="startid">
            <xsl:for-each select="ancestor::note[1]">
              <xsl:value-of select="generate-id()"/>
            </xsl:for-each>
          </xsl:attribute>
          <xsl:call-template name="positionRelative"/>
          <xsl:variable name="content">
            <xsl:choose>
              <xsl:when test="local-name()='breath-mark'">
                <xsl:choose>
                  <xsl:when test="matches(., 'tick')">
                    <xsl:text>'</xsl:text>
                  </xsl:when>
                  <xsl:when test="matches(., 'comma')">
                    <xsl:text>,</xsl:text>
                  </xsl:when>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="local-name()='caesura'">
                <xsl:text>//</xsl:text>
              </xsl:when>
              <xsl:when test="local-name()='stress'">
                <xsl:text>&#x0301;</xsl:text>
              </xsl:when>
              <xsl:when test="local-name()='unstress'">
                <xsl:text>&#x23D1;</xsl:text>
              </xsl:when>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="@font-family or @font-style or @font-size or @font-weight or
              @letter-spacing or @line-height or @justify or @halign or @valign or @color or
              @rotation or @xml:space or @underline or @overline or @line-through or @dir or
              @enclosure!='none'">
              <xsl:call-template name="wrapRend">
                <xsl:with-param name="in">
                  <xsl:copy-of select="$content"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$content"/>
            </xsl:otherwise>
          </xsl:choose>
        </dir>
      </xsl:when>
      <xsl:when test="local-name()='accent' or local-name()='detached-legato' or
        local-name()='doit' or local-name()='falloff' or local-name()='plop' or
        local-name()='spiccato' or local-name()='staccatissimo' or local-name()='staccato'
        or local-name()='strong-accent' or local-name()='tenuto'">
        <!-- Do nothing; these are handled as note-level articulations -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="measureNum">
          <xsl:value-of select="ancestor::measure/@number"/>
        </xsl:variable>
        <xsl:variable name="warning">
          <xsl:value-of select="concat(upper-case(substring(local-name(.),1,1)),
            substring(local-name(.),2), ' not transcoded')"/>
        </xsl:variable>
        <xsl:message>
          <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
            ').'))"/>
        </xsl:message>
        <xsl:comment>
          <xsl:value-of select="normalize-space(concat($warning, '.'))"/>
        </xsl:comment>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="note/notations/technical/*" mode="stage1.dir">
    <!-- Some MusicXML technical indications are directives in MEI -->
    <xsl:choose>
      <xsl:when test="local-name()='fingering' or local-name()='pluck' or local-name()='tap'">
        <dir xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:attribute name="label">
            <xsl:if test="local-name()='fingering'">
              <xsl:if test="@substitution='yes'">
                <xsl:text>subst. </xsl:text>
              </xsl:if>
              <xsl:if test="@alternate='yes'">
                <xsl:text>alt. </xsl:text>
              </xsl:if>
            </xsl:if>
            <xsl:value-of select="local-name()"/>
          </xsl:attribute>
          <xsl:attribute name="tstamp">
            <xsl:call-template name="tstamp.ges2beat">
              <xsl:with-param name="tstamp.ges">
                <xsl:for-each select="ancestor::note[1]">
                  <xsl:call-template name="getTimestamp.ges"/>
                </xsl:for-each>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="tstamp.ges">
            <xsl:for-each select="ancestor::note[1]">
              <xsl:call-template name="getTimestamp.ges"/>
            </xsl:for-each>
          </xsl:attribute>
          <xsl:variable name="partID">
            <xsl:value-of select="ancestor::part[1]/@id"/>
          </xsl:variable>
          <xsl:variable name="partstaff">
            <xsl:choose>
              <xsl:when test="ancestor::note[1]/staff">
                <xsl:value-of select="ancestor::note[1]/staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="staff">
            <xsl:call-template name="getStaffNum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partStaff">
                <xsl:value-of select="$partstaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="place">
            <xsl:choose>
              <xsl:when test="@placement != ''">
                <xsl:value-of select="@placement"/>
              </xsl:when>
              <xsl:otherwise>above</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:attribute name="startid">
            <xsl:for-each select="ancestor::note[1]">
              <xsl:value-of select="generate-id()"/>
            </xsl:for-each>
          </xsl:attribute>
          <xsl:call-template name="positionRelative"/>
          <xsl:variable name="content">
            <xsl:value-of select="normalize-space(.)"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="@font-family or @font-style or @font-size or @font-weight or
              @letter-spacing or @line-height or @justify or @halign or @valign or @color or
              @rotation or @xml:space or @underline or @overline or @line-through or @dir or
              @enclosure!='none'">
              <xsl:call-template name="wrapRend">
                <xsl:with-param name="in">
                  <xsl:copy-of select="$content"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$content"/>
            </xsl:otherwise>
          </xsl:choose>
        </dir>
      </xsl:when>
      <xsl:when test="(local-name()='hammer-on' or local-name()='pull-off') and @type='start'">
        <dir xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:attribute name="label">
            <xsl:value-of select="local-name()"/>
          </xsl:attribute>
          <!-- timestamp for the hammer-on/pull-off corresponds to the *ending note* -->
          <xsl:attribute name="tstamp">
            <xsl:call-template name="tstamp.ges2beat">
              <xsl:with-param name="tstamp.ges">
                <xsl:for-each
                  select="following::note[notations/technical/*[local-name()=local-name(.)
                  and @type='stop']][1]">
                  <xsl:call-template name="getTimestamp.ges"/>
                </xsl:for-each>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <!-- timestamp.ges for the hammer-on/pull-off corresponds to the *ending note* -->
          <xsl:attribute name="tstamp.ges">
            <xsl:for-each select="following::note[notations/technical/*[local-name()=local-name(.)
              and @type='stop']][1]">
              <xsl:call-template name="getTimestamp.ges"/>
            </xsl:for-each>
          </xsl:attribute>
          <xsl:variable name="partID">
            <xsl:value-of select="ancestor::part[1]/@id"/>
          </xsl:variable>
          <xsl:variable name="partstaff">
            <xsl:choose>
              <xsl:when test="ancestor::note[1]/staff">
                <xsl:value-of select="ancestor::note[1]/staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="staff">
            <xsl:call-template name="getStaffNum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partStaff">
                <xsl:value-of select="$partstaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="place">
            <xsl:choose>
              <xsl:when test="@placement != ''">
                <xsl:value-of select="@placement"/>
              </xsl:when>
              <xsl:otherwise>above</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:attribute name="startid">
            <xsl:for-each select="ancestor::note[1]">
              <xsl:value-of select="generate-id()"/>
            </xsl:for-each>
          </xsl:attribute>
          <xsl:for-each select="following::note[notations/technical/*[local-name()=local-name(.) and
            @type='stop']][1]">
            <xsl:attribute name="endid">
              <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
          </xsl:for-each>
          <xsl:call-template name="positionRelative"/>
          <xsl:variable name="content">
            <xsl:choose>
              <xsl:when test="node()">
                <xsl:copy-of select="node()"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:comment>empty</xsl:comment>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="@font-family or @font-style or @font-size or @font-weight or
              @letter-spacing or @line-height or @justify or @halign or @valign or @color or
              @rotation or @xml:space or @underline or @overline or @line-through or @dir or
              @enclosure!='none'">
              <xsl:call-template name="wrapRend">
                <xsl:with-param name="in">
                  <xsl:copy-of select="$content"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$content"/>
            </xsl:otherwise>
          </xsl:choose>
        </dir>
      </xsl:when>
      <xsl:when test="(local-name()='hammer-on' or local-name()='pull-off') and
        @type='stop'">
        <!-- Do nothing; end points are handled at same time as start points -->
      </xsl:when>
      <xsl:when test="local-name()='double-tongue' or local-name()='down-bow' or
        local-name()='fingernails' or local-name()='harmonic' or local-name()='heel' or
        local-name()='open-string' or local-name()='snap-pizzicato' or local-name()='stopped'
        or local-name()='toe' or local-name()='triple-tongue' or local-name()='up-bow'">
        <!-- Do nothing; these are handled as note-level articulations -->
      </xsl:when>
      <xsl:when test="local-name()='fret' or local-name()='string'">
        <!-- Do nothing; these are handled as note attributes -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="measureNum">
          <xsl:value-of select="ancestor::measure/@number"/>
        </xsl:variable>
        <xsl:variable name="warning">
          <xsl:value-of select="concat(upper-case(substring(local-name(.),1,1)),
            substring(local-name(.),2), ' not transcoded')"/>
        </xsl:variable>
        <xsl:message>
          <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
            ').'))"/>
        </xsl:message>
        <xsl:comment>
          <xsl:value-of select="normalize-space(concat($warning, '.'))"/>
        </xsl:comment>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="note/notations/dynamics" mode="stage1">
    <!-- Dynamics -->
    <dynam xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:attribute name="label">notation</xsl:attribute>
      <!-- Attributes based on starting note -->
      <xsl:for-each select="ancestor::note">
        <xsl:call-template name="tstampAttrs"/>
        <xsl:variable name="partID">
          <xsl:value-of select="ancestor::part/@id"/>
        </xsl:variable>
        <xsl:variable name="partStaff">
          <xsl:choose>
            <xsl:when test="staff">
              <xsl:value-of select="staff"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="staff">
          <xsl:call-template name="getStaffNum">
            <xsl:with-param name="partID">
              <xsl:value-of select="$partID"/>
            </xsl:with-param>
            <xsl:with-param name="partStaff">
              <xsl:value-of select="$partStaff"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:attribute name="startid">
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:attribute name="place">
        <xsl:choose>
          <xsl:when test="@placement != ''">
            <xsl:value-of select="@placement"/>
          </xsl:when>
          <xsl:otherwise>below</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:call-template name="positionRelative"/>
      <xsl:variable name="content">
        <xsl:for-each select="*">
          <xsl:choose>
            <xsl:when test="local-name()='other-dynamics'">
              <xsl:value-of select="."/>
              <xsl:if test="position() != last()">
                <xsl:text>&#32;</xsl:text>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="local-name()"/>
              <xsl:if test="position() != last()">
                <xsl:text>&#32;</xsl:text>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="@font-family or @font-style or @font-size or @font-weight or @letter-spacing
          or @line-height or @justify or @halign or @valign or @color or @rotation or
          @xml:space or @underline or @overline or @line-through or @dir or
          @enclosure!='none'">
          <xsl:call-template name="wrapRend">
            <xsl:with-param name="in">
              <xsl:copy-of select="$content"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="$content"/>
        </xsl:otherwise>
      </xsl:choose>
    </dynam>
  </xsl:template>

  <xsl:template match="note/notations/fermata" mode="stage1">
    <fermata xmlns="http://www.music-encoding.org/ns/mei">
      <!-- Attributes based on starting note -->
      <xsl:for-each select="ancestor::note">
        <xsl:call-template name="tstampAttrs"/>
        <xsl:variable name="partID">
          <xsl:value-of select="ancestor::part/@id"/>
        </xsl:variable>
        <xsl:variable name="partStaff">
          <xsl:choose>
            <xsl:when test="staff">
              <xsl:value-of select="staff"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="staff">
          <xsl:call-template name="getStaffNum">
            <xsl:with-param name="partID">
              <xsl:value-of select="$partID"/>
            </xsl:with-param>
            <xsl:with-param name="partStaff">
              <xsl:value-of select="$partStaff"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:attribute>
        <xsl:attribute name="startid">
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:attribute name="place">
        <xsl:choose>
          <xsl:when test="@type='upright'">above</xsl:when>
          <xsl:when test="@type='inverted'">below</xsl:when>
          <xsl:otherwise>above</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:call-template name="positionRelative"/>
      <xsl:attribute name="form">
        <xsl:choose>
          <xsl:when test="@type='inverted'">
            <xsl:text>inv</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>norm</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:if test="not(normalize-space(.)='')">
        <xsl:choose>
          <xsl:when test="normalize-space(.)='normal'">
            <xsl:attribute name="shape">curved</xsl:attribute>
          </xsl:when>
          <xsl:when test="normalize-space(.)='square'">
            <xsl:attribute name="shape">square</xsl:attribute>
          </xsl:when>
          <!-- Value 'angular' not yet supported in MEI -->
          <xsl:when test="normalize-space(.)='angled'">
            <!--<xsl:attribute name="shape">angular</xsl:attribute>-->
            <xsl:variable name="measureNum">
              <xsl:value-of select="ancestor::measure/@number"/>
            </xsl:variable>
            <xsl:variable name="warning">
              <xsl:text>Angled fermata not supported</xsl:text>
            </xsl:variable>
            <xsl:message>
              <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
                ').'))"/>
            </xsl:message>
            <xsl:comment>
              <xsl:value-of select="normalize-space(concat($warning, '.'))"/>
            </xsl:comment>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
    </fermata>
  </xsl:template>

  <xsl:template match="note/notations/ornaments" mode="stage1">
    <!-- Sound suggestions currently ignored -->
    <!-- Trill -->
    <xsl:for-each select="trill-mark">
      <trill xmlns="http://www.music-encoding.org/ns/mei">
        <!-- Attributes based on starting note -->
        <xsl:for-each select="ancestor::note">
          <xsl:call-template name="tstampAttrs"/>
          <xsl:variable name="partID">
            <xsl:value-of select="ancestor::part/@id"/>
          </xsl:variable>
          <xsl:variable name="partStaff">
            <xsl:choose>
              <xsl:when test="staff">
                <xsl:value-of select="staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="staff">
            <xsl:call-template name="getStaffNum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partStaff">
                <xsl:value-of select="$partStaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="startid">
            <xsl:value-of select="generate-id()"/>
          </xsl:attribute>
        </xsl:for-each>
        <xsl:attribute name="place">
          <xsl:choose>
            <xsl:when test="@placement != ''">
              <xsl:value-of select="@placement"/>
            </xsl:when>
            <xsl:otherwise>above</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:call-template name="positionRelative"/>
        <!-- Include accidentals that apply to this ornament; that is,
        they follow this ornament, but precede any other ornament -->
        <xsl:for-each select="following-sibling::*[1]">
          <xsl:if test="local-name()='accidental-mark'">
            <xsl:apply-templates select="." mode="stage1.amlist"/>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="following-sibling::*[1]">
          <xsl:if test="local-name()='accidental-mark'">
            <xsl:apply-templates select="." mode="stage1.amlist.empty"/>
          </xsl:if>
        </xsl:for-each>
      </trill>
    </xsl:for-each>
    <!-- Turns -->
    <xsl:for-each select="turn|delayed-turn|inverted-turn">
      <turn xmlns="http://www.music-encoding.org/ns/mei">
        <!-- Tstamp attributes -->
        <xsl:for-each select="ancestor::note">
          <xsl:call-template name="tstampAttrs"/>
          <xsl:variable name="partID">
            <xsl:value-of select="ancestor::part/@id"/>
          </xsl:variable>
          <xsl:variable name="partStaff">
            <xsl:choose>
              <xsl:when test="staff">
                <xsl:value-of select="staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="staff">
            <xsl:call-template name="getStaffNum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partStaff">
                <xsl:value-of select="$partStaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="startid">
            <xsl:value-of select="generate-id()"/>
          </xsl:attribute>
        </xsl:for-each>
        <!-- Attributes based on starting note -->
        <xsl:if test="local-name()='delayed-turn'">
          <xsl:attribute name="delayed">true</xsl:attribute>
        </xsl:if>
        <xsl:if test="local-name()='inverted-turn'">
          <xsl:attribute name="form">inv</xsl:attribute>
        </xsl:if>
        <xsl:attribute name="place">
          <xsl:choose>
            <xsl:when test="@placement != ''">
              <xsl:value-of select="@placement"/>
            </xsl:when>
            <xsl:otherwise>above</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:call-template name="positionRelative"/>
        <!-- Include accidentals that apply to this ornament; that is,
        they follow this ornament, but precede any other ornament -->
        <xsl:for-each select="following-sibling::*[1]">
          <xsl:if test="local-name()='accidental-mark'">
            <xsl:apply-templates select="." mode="stage1.amlist"/>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="following-sibling::*[1]">
          <xsl:if test="local-name()='accidental-mark'">
            <xsl:apply-templates select="." mode="stage1.amlist.empty"/>
          </xsl:if>
        </xsl:for-each>
      </turn>
    </xsl:for-each>
    <!-- Mordents and shakes -->
    <xsl:for-each select="mordent|inverted-mordent|shake">
      <mordent xmlns="http://www.music-encoding.org/ns/mei">
        <xsl:if test="local-name()='shake'">
          <xsl:attribute name="label">
            <xsl:value-of select="local-name()"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:for-each select="ancestor::note">
          <xsl:call-template name="tstampAttrs"/>
          <xsl:variable name="partID">
            <xsl:value-of select="ancestor::part/@id"/>
          </xsl:variable>
          <xsl:variable name="partStaff">
            <xsl:choose>
              <xsl:when test="staff">
                <xsl:value-of select="staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="staff">
            <xsl:call-template name="getStaffNum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partStaff">
                <xsl:value-of select="$partStaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="startid">
            <xsl:value-of select="generate-id()"/>
          </xsl:attribute>
        </xsl:for-each>
        <xsl:if test="local-name()='mordent' or local-name()='inverted-mordent'">
          <xsl:if test="@long='yes'">
            <xsl:attribute name="long">true</xsl:attribute>
          </xsl:if>
        </xsl:if>
        <xsl:attribute name="place">
          <xsl:choose>
            <xsl:when test="@placement != ''">
              <xsl:value-of select="@placement"/>
            </xsl:when>
            <xsl:otherwise>above</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:if test="local-name()='inverted-mordent' or local-name()='shake'">
          <xsl:attribute name="form">inv</xsl:attribute>
        </xsl:if>
        <xsl:call-template name="positionRelative"/>
        <!-- Include accidentals that apply to this ornament; that is,
        they follow this ornament, but precede any other ornament -->
        <xsl:for-each select="following-sibling::*[1]">
          <xsl:if test="local-name()='accidental-mark'">
            <xsl:apply-templates select="." mode="stage1.amlist"/>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="following-sibling::*[1]">
          <xsl:if test="local-name()='accidental-mark'">
            <xsl:apply-templates select="." mode="stage1.amlist.empty"/>
          </xsl:if>
        </xsl:for-each>
      </mordent>
    </xsl:for-each>
    <!-- Schleifer -->
    <xsl:for-each select="schleifer">
      <dir xmlns="http://www.music-encoding.org/ns/mei">
        <xsl:attribute name="label">
          <xsl:value-of select="local-name()"/>
        </xsl:attribute>
        <!-- Attributes based on starting note -->
        <xsl:for-each select="ancestor::note">
          <xsl:call-template name="tstampAttrs"/>
          <xsl:variable name="partID">
            <xsl:value-of select="ancestor::part/@id"/>
          </xsl:variable>
          <xsl:variable name="partStaff">
            <xsl:choose>
              <xsl:when test="staff">
                <xsl:value-of select="staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:attribute name="staff">
            <xsl:call-template name="getStaffNum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partStaff">
                <xsl:value-of select="$partStaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="startid">
            <xsl:value-of select="generate-id()"/>
          </xsl:attribute>
          <xsl:attribute name="place">
            <xsl:choose>
              <xsl:when test="@placement != ''">
                <xsl:value-of select="@placement"/>
              </xsl:when>
              <xsl:otherwise>above</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:for-each>
        <xsl:call-template name="positionRelative"/>
        <!-- Include accidentals that apply to this ornament; that is,
        they follow this ornament, but precede any other ornament -->
        <xsl:for-each select="following-sibling::*[1]">
          <xsl:if test="local-name()='accidental-mark'">
            <xsl:apply-templates select="." mode="stage1.amlist"/>
          </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="following-sibling::*[1]">
          <xsl:if test="local-name()='accidental-mark'">
            <xsl:apply-templates select="." mode="stage1.amlist.empty"/>
          </xsl:if>
        </xsl:for-each>
      </dir>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="note/notations/slur[@type='start']" mode="stage1">
    <slur xmlns="http://www.music-encoding.org/ns/mei">
      <!-- Tstamp attributes -->
      <xsl:for-each select="ancestor::note">
        <xsl:call-template name="tstampAttrs"/>
        <xsl:attribute name="startid">
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
      </xsl:for-each>
      <!-- Attributes based on starting note -->
      <xsl:choose>
        <xsl:when test="@orientation or @placement">
          <xsl:attribute name="curvedir">
            <xsl:choose>
              <xsl:when test="@orientation='under' or @placement='below'">
                <xsl:text>below</xsl:text>
              </xsl:when>
              <xsl:when test="@orientation='over' or @placement='above'">
                <xsl:text>above</xsl:text>
              </xsl:when>
            </xsl:choose>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="ancestor::note/stem">
          <xsl:attribute name="curvedir">
            <xsl:choose>
              <xsl:when test="ancestor::note/stem='up'">
                <xsl:text>below</xsl:text>
              </xsl:when>
              <xsl:when test="ancestor::note/stem='down'">
                <xsl:text>above</xsl:text>
              </xsl:when>
            </xsl:choose>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="measureNum">
            <xsl:value-of select="ancestor::measure/@number"/>
          </xsl:variable>
          <xsl:variable name="warning">
            <xsl:text>Slur curve direction undetermined</xsl:text>
          </xsl:variable>
          <xsl:message>
            <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
              ').'))"/>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="@line-type='dashed' or @line-type='dotted' or @line-type='solid'">
        <xsl:attribute name="rend">
          <xsl:choose>
            <xsl:when test="@line-type='solid'">
              <xsl:text>narrow</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@line-type"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:if>
      <xsl:variable name="bezierStart">
        <xsl:value-of select="@bezier-x"/>
        <xsl:text>&#32;</xsl:text>
        <xsl:value-of select="@bezier-y"/>
      </xsl:variable>
      <xsl:if test="@default-y">
        <xsl:attribute name="startvo">
          <xsl:value-of select="format-number(@default-y div 5, '###0.####')"/>
        </xsl:attribute>
      </xsl:if>
      <!-- Attributes based on ending note -->
      <!-- @number defaults to 1 -->
      <xsl:variable name="slurNum">
        <xsl:value-of select="@number"/>
      </xsl:variable>
      <xsl:variable name="startMeasureID">
        <xsl:value-of select="generate-id(ancestor::measure[1])"/>
      </xsl:variable>
      <xsl:variable name="startMeasurePos">
        <xsl:for-each select="//measure">
          <xsl:if test="generate-id()=$startMeasureID">
            <xsl:value-of select="position()"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="partID">
        <xsl:value-of select="ancestor::part[1]/@id"/>
      </xsl:variable>
      <xsl:variable name="partStaff">
        <xsl:choose>
          <xsl:when test="ancestor::note[1]/staff">
            <xsl:value-of select="ancestor::note[1]/staff"/>
          </xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="staff1">
        <xsl:call-template name="getStaffNum">
          <xsl:with-param name="partID">
            <xsl:value-of select="$partID"/>
          </xsl:with-param>
          <xsl:with-param name="partStaff">
            <xsl:value-of select="$partStaff"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:choose>
        <!-- When slur crosses staves, ending note may actually precede starting note in 
          the encoded order of the file -->
        <xsl:when test="preceding::note[notations/slur[@type='stop' and @number=$slurNum] and
          ancestor::part/@id=$partID and generate-id(ancestor::measure[1])=$startMeasureID]
          and not(following::note[notations/slur[@type='stop' and @number=$slurNum] and
          ancestor::part/@id=$partID and generate-id(ancestor::measure[1])=$startMeasureID])">
          <xsl:variable name="startTimestamp.ges">
            <xsl:for-each select="ancestor::note">
              <xsl:call-template name="getTimestamp.ges"/>
            </xsl:for-each>
          </xsl:variable>
          <xsl:for-each select="preceding::note[notations/slur[@type='stop' and
            @number=$slurNum] and ancestor::part[1]/@id=$partID and
            generate-id(ancestor::measure[1])=$startMeasureID][1]">
            <xsl:variable name="endTimestamp.ges">
              <xsl:call-template name="getTimestamp.ges"/>
            </xsl:variable>
            <xsl:choose>
              <xsl:when test="($endTimestamp.ges - $startTimestamp.ges) &gt; 0">
                <xsl:attribute name="tstamp2">
                  <xsl:text>0m+</xsl:text>
                  <xsl:call-template name="tstamp.ges2beat">
                    <xsl:with-param name="tstamp.ges">
                      <xsl:value-of select="$endTimestamp.ges"/>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:attribute>
                <xsl:attribute name="endid">
                  <xsl:value-of select="generate-id()"/>
                </xsl:attribute>
                <xsl:if test="notations/slur[@type='stop' and @number=$slurNum]/@default-y">
                  <xsl:attribute name="endvo">
                    <xsl:value-of select="format-number(notations/slur[@type='stop' and
                      @number=$slurNum]/@default-y div 5, '###0.####')"/>
                  </xsl:attribute>
                </xsl:if>
                <xsl:variable name="bezierEnd">
                  <xsl:value-of select="notations/slur[@type='stop' and
                    @number=$slurNum]/@bezier-x"/>
                  <xsl:text>&#32;</xsl:text>
                  <xsl:value-of select="notations/slur[@type='stop' and
                    @number=$slurNum]/@bezier-y"/>
                </xsl:variable>
                <xsl:if test="concat($bezierStart,$bezierEnd) != '&#32;&#32;'">
                  <xsl:attribute name="bezier">
                    <xsl:value-of select="$bezierStart"/>
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="$bezierEnd"/>
                  </xsl:attribute>
                </xsl:if>
                <xsl:variable name="partStaff2">
                  <xsl:choose>
                    <xsl:when test="staff">
                      <xsl:value-of select="staff"/>
                    </xsl:when>
                    <xsl:otherwise>1</xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:variable name="staff2">
                  <xsl:call-template name="getStaffNum">
                    <xsl:with-param name="partID">
                      <xsl:value-of select="$partID"/>
                    </xsl:with-param>
                    <xsl:with-param name="partStaff">
                      <xsl:value-of select="$partStaff2"/>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:variable>
                <xsl:attribute name="staff">
                  <xsl:value-of select="$staff1"/>
                  <xsl:if test="$staff2 != $staff1">
                    <xsl:text>&#32;</xsl:text>
                    <xsl:value-of select="$staff2"/>
                  </xsl:if>
                </xsl:attribute>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="following::note[notations/slur[@type='stop' and
                    @number=$slurNum] and ancestor::part[1]/@id=$partID][1]">
                    <xsl:for-each select="following::note[notations/slur[@type='stop' and
                      @number=$slurNum] and ancestor::part[1]/@id=$partID][1]">
                      <xsl:variable name="endMeasureID">
                        <xsl:value-of select="generate-id(ancestor::measure[1])"/>
                      </xsl:variable>
                      <xsl:variable name="endMeasurePos">
                        <xsl:for-each select="//measure">
                          <xsl:if test="generate-id()=$endMeasureID">
                            <xsl:value-of select="position()"/>
                          </xsl:if>
                        </xsl:for-each>
                      </xsl:variable>
                      <xsl:attribute name="tstamp2">
                        <xsl:value-of select="$endMeasurePos - $startMeasurePos"/>
                        <xsl:text>m+</xsl:text>
                        <xsl:call-template name="tstamp.ges2beat">
                          <xsl:with-param name="tstamp.ges">
                            <xsl:call-template name="getTimestamp.ges"/>
                          </xsl:with-param>
                        </xsl:call-template>
                      </xsl:attribute>
                      <xsl:attribute name="endid">
                        <xsl:value-of select="generate-id()"/>
                      </xsl:attribute>
                      <xsl:if test="notations/slur/@default-y">
                        <xsl:attribute name="endvo">
                          <xsl:value-of
                            select="format-number(notations/slur[@type='stop']/@default-y div 5,
                            '###0.####')"/>
                        </xsl:attribute>
                      </xsl:if>
                      <xsl:variable name="bezierEnd">
                        <xsl:value-of select="notations/slur[@type='stop']/@bezier-x"/>
                        <xsl:text>&#32;</xsl:text>
                        <xsl:value-of select="notations/slur[@type='stop']/@bezier-y"/>
                      </xsl:variable>
                      <xsl:if test="concat($bezierStart,$bezierEnd) != '&#32;&#32;'">
                        <xsl:attribute name="bezier">
                          <xsl:value-of select="$bezierStart"/>
                          <xsl:text>&#32;</xsl:text>
                          <xsl:value-of select="$bezierEnd"/>
                        </xsl:attribute>
                      </xsl:if>
                      <xsl:variable name="partStaff2">
                        <xsl:choose>
                          <xsl:when test="staff">
                            <xsl:value-of select="staff"/>
                          </xsl:when>
                          <xsl:otherwise>1</xsl:otherwise>
                        </xsl:choose>
                      </xsl:variable>
                      <xsl:variable name="staff2">
                        <xsl:call-template name="getStaffNum">
                          <xsl:with-param name="partID">
                            <xsl:value-of select="$partID"/>
                          </xsl:with-param>
                          <xsl:with-param name="partStaff">
                            <xsl:value-of select="$partStaff2"/>
                          </xsl:with-param>
                        </xsl:call-template>
                      </xsl:variable>
                      <xsl:attribute name="staff">
                        <xsl:value-of select="$staff1"/>
                        <xsl:if test="$staff2 != $staff1">
                          <xsl:text>&#32;</xsl:text>
                          <xsl:value-of select="$staff2"/>
                        </xsl:if>
                      </xsl:attribute>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:variable name="partID">
                      <xsl:value-of select="ancestor::part[1]/@id"/>
                    </xsl:variable>
                    <xsl:variable name="partStaff">
                      <xsl:choose>
                        <xsl:when test="ancestor::note[1]/staff">
                          <xsl:value-of select="ancestor::note[1]/staff"/>
                        </xsl:when>
                        <xsl:otherwise>1</xsl:otherwise>
                      </xsl:choose>
                    </xsl:variable>
                    <xsl:attribute name="staff">
                      <xsl:call-template name="getStaffNum">
                        <xsl:with-param name="partID">
                          <xsl:value-of select="$partID"/>
                        </xsl:with-param>
                        <xsl:with-param name="partStaff">
                          <xsl:value-of select="$partStaff"/>
                        </xsl:with-param>
                      </xsl:call-template>
                    </xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:when>
        <!-- Ending note follows starting note in encoding order -->
        <xsl:when test="following::note[notations/slur[@type='stop' and @number=$slurNum] and
          ancestor::part[1]/@id=$partID][1]">
          <xsl:for-each select="following::note[notations/slur[@type='stop' and
            @number=$slurNum] and ancestor::part[1]/@id=$partID][1]">
            <xsl:variable name="endMeasureID">
              <xsl:value-of select="generate-id(ancestor::measure[1])"/>
            </xsl:variable>
            <xsl:variable name="endMeasurePos">
              <xsl:for-each select="//measure">
                <xsl:if test="generate-id()=$endMeasureID">
                  <xsl:value-of select="position()"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:attribute name="tstamp2">
              <xsl:value-of select="$endMeasurePos - $startMeasurePos"/>
              <xsl:text>m+</xsl:text>
              <xsl:call-template name="tstamp.ges2beat">
                <xsl:with-param name="tstamp.ges">
                  <xsl:call-template name="getTimestamp.ges"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="endid">
              <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <xsl:if test="notations/slur[@type='stop']/@default-y">
              <xsl:attribute name="endvo">
                <xsl:value-of select="format-number(notations/slur[@type='stop']/@default-y div
                  5, '###0.####')"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:variable name="bezierEnd">
              <xsl:value-of select="notations/slur[@type='stop']/@bezier-x"/>
              <xsl:text>&#32;</xsl:text>
              <xsl:value-of select="notations/slur[@type='stop']/@bezier-y"/>
            </xsl:variable>
            <xsl:if test="concat($bezierStart,$bezierEnd) != '&#32;&#32;'">
              <xsl:attribute name="bezier">
                <xsl:value-of select="$bezierStart"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="$bezierEnd"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:variable name="partStaff2">
              <xsl:choose>
                <xsl:when test="staff">
                  <xsl:value-of select="staff"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="staff2">
              <xsl:call-template name="getStaffNum">
                <xsl:with-param name="partID">
                  <xsl:value-of select="$partID"/>
                </xsl:with-param>
                <xsl:with-param name="partStaff">
                  <xsl:value-of select="$partStaff2"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:variable>
            <xsl:attribute name="staff">
              <xsl:value-of select="$staff1"/>
              <xsl:if test="$staff2 != $staff1">
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="$staff2"/>
              </xsl:if>
            </xsl:attribute>
          </xsl:for-each>
        </xsl:when>
        <!-- Slur continued by following sibling -->
        <xsl:when test="following-sibling::slur[@type='continue']">
          <xsl:attribute name="staff">
            <xsl:call-template name="getStaffNum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partStaff">
                <xsl:value-of select="$partStaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="endid">
            <xsl:value-of select="generate-id(ancestor::note)"/>
          </xsl:attribute>
          <xsl:variable name="measureNum">
            <xsl:value-of select="ancestor::measure/@number"/>
          </xsl:variable>
          <xsl:variable name="warning">
            <xsl:text>Slur duration undetermined</xsl:text>
          </xsl:variable>
          <xsl:if test="following-sibling::slur[@type='continue' and @number=$slurNum and
            @default-x]">
            <xsl:attribute name="endho">
              <xsl:value-of select="format-number(following-sibling::slur[@type='continue' and
                @number=$slurNum and @default-x]/@default-x div 5, '###0.####')"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="following-sibling::slur[@type='continue' and @number=$slurNum and
            @default-y]">
            <xsl:attribute name="endvo">
              <xsl:value-of select="format-number(following-sibling::slur[@type='continue' and
                @number=$slurNum and @default-y]/@default-y div 5, '###0.####')"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:comment>
            <xsl:value-of select="normalize-space(concat($warning, '.'))"/>
          </xsl:comment>
          <xsl:message>
            <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
              ').'))"/>
          </xsl:message>
        </xsl:when>
      </xsl:choose>
    </slur>
  </xsl:template>

  <xsl:template match="note/notations/tied[@type='start']" mode="stage1">
    <tie xmlns="http://www.music-encoding.org/ns/mei">
      <!-- Timestamp attributes -->
      <xsl:for-each select="ancestor::note">
        <xsl:call-template name="tstampAttrs"/>
        <xsl:attribute name="startid">
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
      </xsl:for-each>
      <!-- Attributes based on starting note -->
      <xsl:choose>
        <xsl:when test="@orientation='under' or @placement='below' or ancestor::note/stem='up'">
          <xsl:attribute name="curvedir">
            <xsl:text>below</xsl:text>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="@orientation='over' or @placement='above' or ancestor::note/stem='down'">
          <xsl:attribute name="curvedir">
            <xsl:text>above</xsl:text>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="measureNum">
            <xsl:value-of select="ancestor::measure/@number"/>
          </xsl:variable>
          <xsl:variable name="warning">
            <xsl:text>Tie curve direction undetermined</xsl:text>
          </xsl:variable>
          <xsl:message>
            <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
              ').'))"/>
          </xsl:message>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="@line-type='dashed' or @line-type='dotted' or @line-type='solid'">
        <xsl:attribute name="rend">
          <xsl:choose>
            <xsl:when test="@line-type='solid'">
              <xsl:text>narrow</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@line-type"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:if>
      <xsl:variable name="bezierStart">
        <xsl:value-of select="@bezier-x"/>
        <xsl:text>&#32;</xsl:text>
        <xsl:value-of select="@bezier-y"/>
      </xsl:variable>
      <xsl:if test="@default-y">
        <xsl:attribute name="startvo">
          <xsl:value-of select="format-number(@default-y div 5, '###0.####')"/>
        </xsl:attribute>
      </xsl:if>
      <!-- Attributes based on ending note -->
      <xsl:variable name="startMeasureID">
        <xsl:value-of select="generate-id(ancestor::measure[1])"/>
      </xsl:variable>
      <xsl:variable name="startMeasurePos">
        <xsl:for-each select="//measure">
          <xsl:if test="generate-id()=$startMeasureID">
            <xsl:value-of select="position()"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="partID">
        <xsl:value-of select="ancestor::part[1]/@id"/>
      </xsl:variable>
      <xsl:variable name="partStaff">
        <xsl:choose>
          <xsl:when test="ancestor::note/staff">
            <xsl:value-of select="ancestor::note/staff"/>
          </xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="staff1">
        <xsl:call-template name="getStaffNum">
          <xsl:with-param name="partID">
            <xsl:value-of select="$partID"/>
          </xsl:with-param>
          <xsl:with-param name="partStaff">
            <xsl:value-of select="$partStaff"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="pitch">
        <xsl:choose>
          <xsl:when test="ancestor::note/pitch/step">
            <xsl:value-of select="ancestor::note/pitch/step"/>
          </xsl:when>
          <xsl:when test="ancestor::note/unpitched/display-step">
            <xsl:value-of select="ancestor::note/unpitched/display-step"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="octave">
        <xsl:choose>
          <xsl:when test="ancestor::note/pitch/octave">
            <xsl:value-of select="ancestor::note/pitch/octave"/>
          </xsl:when>
          <xsl:when test="ancestor::note/unpitched/display-octave">
            <xsl:value-of select="ancestor::note/unpitched/display-octave"/>
          </xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="voice">
        <xsl:value-of select="ancestor::note/voice"/>
      </xsl:variable>
      <!-- Ignore <tied type="stop">, just look for next pitch -->
      <xsl:choose>
        <!-- Look for same note in same voice -->
        <xsl:when test="following::note[ancestor::part[1]/@id=$partID][(pitch/step=$pitch and
          pitch/octave=$octave and voice=$voice) or (unpitched/display-step=$pitch and
          unpitched/display-octave=$octave and voice=$voice)]">
          <xsl:for-each select="following::note[ancestor::part[1]/@id=$partID][(pitch/step=$pitch
            and pitch/octave=$octave and voice=$voice) or (unpitched/display-step=$pitch
            and unpitched/display-octave=$octave and voice=$voice)][1]">
            <xsl:variable name="endMeasureID">
              <xsl:value-of select="generate-id(ancestor::measure[1])"/>
            </xsl:variable>
            <xsl:variable name="endMeasurePos">
              <xsl:for-each select="//measure">
                <xsl:if test="generate-id()=$endMeasureID">
                  <xsl:value-of select="position()"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:attribute name="tstamp2">
              <xsl:value-of select="$endMeasurePos - $startMeasurePos"/>
              <xsl:text>m+</xsl:text>
              <xsl:call-template name="tstamp.ges2beat">
                <xsl:with-param name="tstamp.ges">
                  <xsl:call-template name="getTimestamp.ges"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="endid">
              <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <xsl:if test="notations/tied[@type='stop']/@default-y">
              <xsl:attribute name="endvo">
                <xsl:value-of select="format-number(notations/tied[@type='stop']/@default-y div 5,
                  '###0.####')"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:variable name="bezierEnd">
              <xsl:value-of select="notations/tied[@type='stop']/@bezier-x"/>
              <xsl:text>&#32;</xsl:text>
              <xsl:value-of select="notations/tied[@type='stop']/@bezier-y"/>
            </xsl:variable>
            <xsl:if test="concat($bezierStart,$bezierEnd) != '&#32;&#32;'">
              <xsl:attribute name="bezier">
                <xsl:value-of select="$bezierStart"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="$bezierEnd"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:variable name="partStaff2">
              <xsl:choose>
                <xsl:when test="staff">
                  <xsl:value-of select="staff"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="staff2">
              <xsl:call-template name="getStaffNum">
                <xsl:with-param name="partID">
                  <xsl:value-of select="$partID"/>
                </xsl:with-param>
                <xsl:with-param name="partStaff">
                  <xsl:value-of select="$partStaff2"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:variable>
            <xsl:attribute name="staff">
              <xsl:value-of select="$staff1"/>
              <xsl:if test="$staff2 != $staff1">
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="$staff2"/>
              </xsl:if>
            </xsl:attribute>
          </xsl:for-each>
        </xsl:when>
        <!-- Look for same note in any voice -->
        <xsl:when test="following::note[ancestor::part[1]/@id=$partID][(pitch/step=$pitch and
          pitch/octave=$octave) or (unpitched/display-step=$pitch and
          unpitched/display-octave=$octave)]">
          <xsl:for-each select="following::note[ancestor::part[1]/@id=$partID][(pitch/step=$pitch
            and pitch/octave=$octave) or (unpitched/display-step=$pitch and
            unpitched/display-octave=$octave)][1]">
            <xsl:variable name="endMeasureID">
              <xsl:value-of select="generate-id(ancestor::measure[1])"/>
            </xsl:variable>
            <xsl:variable name="endMeasurePos">
              <xsl:for-each select="//measure">
                <xsl:if test="generate-id()=$endMeasureID">
                  <xsl:value-of select="position()"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:attribute name="tstamp2">
              <xsl:value-of select="$endMeasurePos - $startMeasurePos"/>
              <xsl:text>m+</xsl:text>
              <xsl:call-template name="tstamp.ges2beat">
                <xsl:with-param name="tstamp.ges">
                  <xsl:call-template name="getTimestamp.ges"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="endid">
              <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <xsl:if test="notations/tied[@type='stop']/@default-y">
              <xsl:attribute name="endvo">
                <xsl:value-of select="format-number(notations/tied[@type='stop']/@default-y div 5,
                  '###0.####')"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:variable name="bezierEnd">
              <xsl:value-of select="notations/tied[@type='stop']/@bezier-x"/>
              <xsl:text>&#32;</xsl:text>
              <xsl:value-of select="notations/tied[@type='stop']/@bezier-y"/>
            </xsl:variable>
            <xsl:if test="concat($bezierStart,$bezierEnd) != '&#32;&#32;'">
              <xsl:attribute name="bezier">
                <xsl:value-of select="$bezierStart"/>
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="$bezierEnd"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:variable name="partStaff2">
              <xsl:choose>
                <xsl:when test="staff">
                  <xsl:value-of select="staff"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="staff2">
              <xsl:call-template name="getStaffNum">
                <xsl:with-param name="partID">
                  <xsl:value-of select="$partID"/>
                </xsl:with-param>
                <xsl:with-param name="partStaff">
                  <xsl:value-of select="$partStaff2"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:variable>
            <xsl:attribute name="staff">
              <xsl:value-of select="$staff1"/>
              <xsl:if test="$staff2 != $staff1">
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="$staff2"/>
              </xsl:if>
            </xsl:attribute>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
    </tie>
  </xsl:template>

  <xsl:template match="note/notations/tuplet[@type='start']" mode="stage1">
    <tupletSpan xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:attribute name="xml:id" select="generate-id()"/>
      <!-- Tstamp attributes -->
      <xsl:for-each select="ancestor::note">
        <xsl:call-template name="tstampAttrs"/>
        <!-- Attributes based on starting note -->
        <xsl:attribute name="startid">
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
        <xsl:if test="time-modification/actual-notes">
          <xsl:attribute name="num">
            <xsl:value-of select="time-modification/actual-notes"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="time-modification/normal-notes">
          <xsl:attribute name="numbase">
            <xsl:value-of select="time-modification/normal-notes"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:for-each>
      <xsl:choose>
        <xsl:when test="@show-number">
          <xsl:attribute name="num.visible">
            <xsl:choose>
              <xsl:when test="@show-number='none'">
                <xsl:text>false</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>true</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="@show-number">
          <xsl:choose>
            <xsl:when test="@show-number != 'none'">
              <xsl:attribute name="num.format">
                <xsl:choose>
                  <xsl:when test="@show-number='both'">
                    <xsl:text>ratio</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>count</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
            </xsl:when>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="num.format">
            <xsl:text>count</xsl:text>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="@placement">
        <xsl:attribute name="num.place">
          <xsl:value-of select="@placement"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@bracket">
        <xsl:attribute name="bracket.visible">
          <xsl:choose>
            <xsl:when test="@bracket='no'">
              <xsl:text>false</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>true</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        <xsl:if test="@placement and @bracket and @bracket != 'no'">
          <xsl:attribute name="bracket.place">
            <xsl:value-of select="@placement"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:if>

      <!-- Attributes based on ending note -->
      <xsl:variable name="startMeasureID">
        <xsl:value-of select="generate-id(ancestor::measure[1])"/>
      </xsl:variable>
      <xsl:variable name="startMeasurePos">
        <xsl:for-each select="//measure">
          <xsl:if test="generate-id()=$startMeasureID">
            <xsl:value-of select="position()"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="partID">
        <xsl:value-of select="ancestor::part[1]/@id"/>
      </xsl:variable>
      <xsl:variable name="partStaff">
        <xsl:choose>
          <xsl:when test="staff">
            <xsl:value-of select="staff"/>
          </xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="staff1">
        <xsl:call-template name="getStaffNum">
          <xsl:with-param name="partID">
            <xsl:value-of select="$partID"/>
          </xsl:with-param>
          <xsl:with-param name="partStaff">
            <xsl:value-of select="$partStaff"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="@number">
          <!-- Numbered tuplet -->
          <xsl:variable name="tupletNum">
            <xsl:value-of select="@number"/>
          </xsl:variable>
          <xsl:for-each select="following::note[notations/tuplet[@number=$tupletNum and
            @type='stop']][1]">
            <xsl:variable name="endMeasureID">
              <xsl:value-of select="generate-id(ancestor::measure[1])"/>
            </xsl:variable>
            <xsl:variable name="endMeasurePos">
              <xsl:for-each select="//measure">
                <xsl:if test="generate-id()=$endMeasureID">
                  <xsl:value-of select="position()"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:attribute name="tstamp2">
              <xsl:value-of select="$endMeasurePos - $startMeasurePos"/>
              <xsl:text>m+</xsl:text>
              <xsl:call-template name="tstamp.ges2beat">
                <xsl:with-param name="tstamp.ges">
                  <xsl:call-template name="getTimestamp.ges"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="endid">
              <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <xsl:variable name="partStaff2">
              <xsl:choose>
                <xsl:when test="staff">
                  <xsl:value-of select="staff"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="staff2">
              <xsl:call-template name="getStaffNum">
                <xsl:with-param name="partID">
                  <xsl:value-of select="$partID"/>
                </xsl:with-param>
                <xsl:with-param name="partStaff">
                  <xsl:value-of select="$partStaff2"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:variable>
            <xsl:attribute name="staff">
              <xsl:value-of select="$staff1"/>
              <xsl:if test="$staff2 != $staff1">
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="$staff2"/>
              </xsl:if>
            </xsl:attribute>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <!-- Tuplet not numbered, just take the next tuplet-ending note -->
          <xsl:for-each select="following::note[notations/tuplet[@type='stop']][1]">
            <xsl:variable name="endMeasureID">
              <xsl:value-of select="generate-id(ancestor::measure[1])"/>
            </xsl:variable>
            <xsl:variable name="endMeasurePos">
              <xsl:for-each select="//measure">
                <xsl:if test="generate-id()=$endMeasureID">
                  <xsl:value-of select="position()"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:attribute name="tstamp2">
              <xsl:value-of select="$endMeasurePos - $startMeasurePos"/>
              <xsl:text>m+</xsl:text>
              <xsl:call-template name="tstamp.ges2beat">
                <xsl:with-param name="tstamp.ges">
                  <xsl:call-template name="getTimestamp.ges"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="endid">
              <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <xsl:variable name="partStaff2">
              <xsl:choose>
                <xsl:when test="staff">
                  <xsl:value-of select="staff"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="staff2">
              <xsl:call-template name="getStaffNum">
                <xsl:with-param name="partID">
                  <xsl:value-of select="$partID"/>
                </xsl:with-param>
                <xsl:with-param name="partStaff">
                  <xsl:value-of select="$partStaff2"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:variable>
            <xsl:attribute name="staff">
              <xsl:value-of select="$staff1"/>
              <xsl:if test="$staff2 != $staff1">
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="$staff2"/>
              </xsl:if>
            </xsl:attribute>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </tupletSpan>
  </xsl:template>

  <!--<xsl:template match="note/notations/tuplet[@type='start']" mode="stage1">
    <xsl:choose>
      <xsl:when test="not(@number)">
        <xsl:variable name="measureNum">
          <xsl:value-of select="ancestor::measure/@number"/>
        </xsl:variable>
        <xsl:variable name="warning">
          <xsl:text>Tuplet without number attribute not transcoded</xsl:text>
        </xsl:variable>
        <xsl:message>
          <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
            ').'))"/>
        </xsl:message>
        <xsl:comment>
          <xsl:value-of select="normalize-space(concat($warning, '.'))"/>
        </xsl:comment>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="tupletNum">
          <xsl:value-of select="@number"/>
        </xsl:variable>
        <tupletSpan xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:attribute name="xml:id" select="generate-id()"/>
          <!-\- Tstamp attributes -\->
          <xsl:for-each select="ancestor::note">
            <xsl:call-template name="tstampAttrs"/>
            <!-\- Attributes based on starting note -\->
            <xsl:attribute name="startid">
              <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <xsl:if test="time-modification/actual-notes">
              <xsl:attribute name="num">
                <xsl:value-of select="time-modification/actual-notes"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="time-modification/normal-notes">
              <xsl:attribute name="numbase">
                <xsl:value-of select="time-modification/normal-notes"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:for-each>
          <xsl:choose>
            <xsl:when test="@show-number">
              <xsl:attribute name="num.visible">
                <xsl:choose>
                  <xsl:when test="@show-number='none'">
                    <xsl:text>false</xsl:text>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>true</xsl:text>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
            </xsl:when>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="@show-number">
              <xsl:choose>
                <xsl:when test="@show-number != 'none'">
                  <xsl:attribute name="num.format">
                    <xsl:choose>
                      <xsl:when test="@show-number='both'">
                        <xsl:text>ratio</xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text>count</xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                </xsl:when>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="num.format">
                <xsl:text>count</xsl:text>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="@placement">
            <xsl:attribute name="num.place">
              <xsl:value-of select="@placement"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@bracket">
            <xsl:attribute name="bracket.visible">
              <xsl:choose>
                <xsl:when test="@bracket='no'">
                  <xsl:text>false</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>true</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:if test="@placement and @bracket and @bracket != 'no'">
              <xsl:attribute name="bracket.place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:if>

          <!-\- Attributes based on ending note -\->
          <xsl:variable name="startMeasureID">
            <xsl:value-of select="generate-id(ancestor::measure[1])"/>
          </xsl:variable>
          <xsl:variable name="startMeasurePos">
            <xsl:for-each select="//measure">
              <xsl:if test="generate-id()=$startMeasureID">
                <xsl:value-of select="position()"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:variable name="partID">
            <xsl:value-of select="ancestor::part[1]/@id"/>
          </xsl:variable>
          <xsl:variable name="partStaff">
            <xsl:choose>
              <xsl:when test="staff">
                <xsl:value-of select="staff"/>
              </xsl:when>
              <xsl:otherwise>1</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:variable name="staff1">
            <xsl:call-template name="getStaffNum">
              <xsl:with-param name="partID">
                <xsl:value-of select="$partID"/>
              </xsl:with-param>
              <xsl:with-param name="partStaff">
                <xsl:value-of select="$partStaff"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:variable>
          <xsl:for-each select="following::note[notations/tuplet[@number=$tupletNum and
            @type='stop']][1]">
            <xsl:variable name="endMeasureID">
              <xsl:value-of select="generate-id(ancestor::measure[1])"/>
            </xsl:variable>
            <xsl:variable name="endMeasurePos">
              <xsl:for-each select="//measure">
                <xsl:if test="generate-id()=$endMeasureID">
                  <xsl:value-of select="position()"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:variable>
            <xsl:attribute name="tstamp2">
              <xsl:value-of select="$endMeasurePos - $startMeasurePos"/>
              <xsl:text>m+</xsl:text>
              <xsl:call-template name="tstamp.ges2beat">
                <xsl:with-param name="tstamp.ges">
                  <xsl:call-template name="getTimestamp.ges"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
            <xsl:attribute name="endid">
              <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
            <xsl:variable name="partStaff2">
              <xsl:choose>
                <xsl:when test="staff">
                  <xsl:value-of select="staff"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:variable name="staff2">
              <xsl:call-template name="getStaffNum">
                <xsl:with-param name="partID">
                  <xsl:value-of select="$partID"/>
                </xsl:with-param>
                <xsl:with-param name="partStaff">
                  <xsl:value-of select="$partStaff2"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:variable>
            <xsl:attribute name="staff">
              <xsl:value-of select="$staff1"/>
              <xsl:if test="$staff2 != $staff1">
                <xsl:text>&#32;</xsl:text>
                <xsl:value-of select="$staff2"/>
              </xsl:if>
            </xsl:attribute>
          </xsl:for-each>
        </tupletSpan>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template> -->

  <xsl:template match="part/sound[@tempo]" mode="stage1">
    <tempo xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:attribute name="midi.tempo">
        <xsl:value-of select="round(@tempo)"/>
        <xsl:if test="contains(@tempo, '.')">
          <xsl:variable name="measureNum">
            <xsl:value-of select="ancestor::measure/@number"/>
          </xsl:variable>
          <xsl:variable name="warning">
            <xsl:text>Tempo value rounded to integer value</xsl:text>
          </xsl:variable>
          <xsl:message>
            <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
              ').'))"/>
          </xsl:message>
        </xsl:if>
      </xsl:attribute>
      <xsl:attribute name="tstamp">
        <xsl:call-template name="tstamp.ges2beat">
          <xsl:with-param name="tstamp.ges">
            <xsl:call-template name="getTimestamp.ges"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:attribute>
      <xsl:attribute name="tstamp.ges">
        <xsl:call-template name="getTimestamp.ges"/>
      </xsl:attribute>
      <xsl:variable name="partID">
        <xsl:value-of select="ancestor::part[1]/@id"/>
      </xsl:variable>
      <xsl:variable name="partStaff">
        <xsl:choose>
          <xsl:when test="@number">
            <xsl:value-of select="@number"/>
          </xsl:when>
          <xsl:otherwise>1</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:attribute name="staff">
        <xsl:call-template name="getStaffNum">
          <xsl:with-param name="partID">
            <xsl:value-of select="$partID"/>
          </xsl:with-param>
          <xsl:with-param name="partStaff">
            <xsl:value-of select="$partStaff"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:attribute>
    </tempo>
  </xsl:template>

  <xsl:template match="part-group[@type='start']" mode="grpSym">
    <!-- Create stand-off staff grouping symbols -->
    <grpSym level="{@number}">
      <xsl:variable name="groupSym">
        <xsl:value-of select="normalize-space(group-symbol)"/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$groupSym = 'brace' or $groupSym = 'bracket' or $groupSym = 'line' or
          $groupSym = 'none'">
          <xsl:attribute name="symbol">
            <xsl:value-of select="normalize-space(group-symbol)"/>
          </xsl:attribute>
        </xsl:when>
        <!-- "square" mapped to "bracket" -->
        <xsl:when test="$groupSym='square'">
          <xsl:attribute name="symbol">
            <xsl:text>bracket</xsl:text>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <!-- Do nothing! Other values ignored. -->
        </xsl:otherwise>
      </xsl:choose>
      <xsl:attribute name="start">
        <xsl:value-of select="following-sibling::mei:staffDef[1]/@n"/>
      </xsl:attribute>
      <xsl:variable name="level">
        <xsl:value-of select="@number"/>
      </xsl:variable>
      <xsl:attribute name="end">
        <xsl:for-each select="following-sibling::part-group[@type='stop' and @number=$level][1]">
          <xsl:value-of select="preceding-sibling::mei:staffDef[1]/@n"/>
        </xsl:for-each>
      </xsl:attribute>
      <!-- group label as attribute -->
      <xsl:if test="group-name[normalize-space(text()) != ''] or
        group-name-display[normalize-space(text()) != '']">
        <xsl:attribute name="label">
          <xsl:choose>
            <xsl:when test="group-name-display">
              <xsl:value-of select="replace(replace(normalize-space(group-name-display), 'flat',
                '&#x266d;'), 'sharp', '&#x266f;')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="group-name"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:if>
      <!-- abbreviated group label as attribute -->
      <xsl:if test="group-abbreviation[normalize-space(text()) != ''] or
        group-abbreviation-display[normalize-space(text()) != '']">
        <xsl:attribute name="label.abbr">
          <xsl:choose>
            <xsl:when test="group-abbreviation-display">
              <xsl:value-of select="replace(replace(normalize-space(group-abbreviation-display),
                'flat', '&#x266d;'), 'sharp', '&#x266f;')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="group-abbreviation"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="group-barline='yes'">
        <xsl:attribute name="barthru">
          <xsl:text>true</xsl:text>
        </xsl:attribute>
      </xsl:if>
      <!-- group label as element -->
      <xsl:if test="group-name[normalize-space(text()) != ''] or
        group-name-display[normalize-space(text()) != '']">
        <label xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:choose>
            <xsl:when test="group-name-display">
              <xsl:value-of select="replace(replace(normalize-space(group-name-display), 'flat',
                '&#x266d;'), 'sharp', '&#x266f;')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="group-name[@font-family or @font-style or @font-size or
                  @font-weight or @letter-spacing or @line-height or @justify or @halign or @valign
                  or @color or @rotation or @xml:space or @underline or @overline or @line-through
                  or @dir or @enclosure!='none']">
                  <xsl:for-each select="group-name[@font-family or @font-style or @font-size or
                    @font-weight or @letter-spacing or @line-height or @justify or @halign or
                    @valign or @color or @rotation or @xml:space or @underline
                    or @overline or @line-through or @dir or @enclosure!='none']">
                    <xsl:call-template name="wrapRend">
                      <xsl:with-param name="in">
                        <xsl:value-of select="group-name"/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="group-name"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </label>
      </xsl:if>
      <xsl:if test="group-abbreviation[normalize-space(text()) != ''] or
        group-abbreviation-display[normalize-space(text()) != '']">
        <label xmlns="http://www.music-encoding.org/ns/mei">
          <abbr>
            <xsl:choose>
              <xsl:when test="group-abbreviation-display">
                <xsl:value-of select="replace(replace(normalize-space(group-abbreviation-display),
                  'flat', '&#x266d;'), 'sharp', '&#x266f;')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:choose>
                  <xsl:when test="group-abbreviation[@font-family or @font-style or @font-size or
                    @font-weight or @letter-spacing or @line-height or @justify or @halign or
                    @valign or @color or @rotation or @xml:space or @underline or
                    @overline or @line-through or @dir or @enclosure!='none']">
                    <xsl:for-each select="group-abbreviation[@font-family or @font-style or
                      @font-size or @font-weight or @letter-spacing or
                      @line-height or @justify or @halign or @valign or @color
                      or @rotation or @xml:space or @underline or @overline or
                      @line-through or @dir or @enclosure!='none']">
                      <xsl:call-template name="wrapRend">
                        <xsl:with-param name="in">
                          <xsl:value-of select="group-abbreviation"/>
                        </xsl:with-param>
                      </xsl:call-template>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="group-abbreviation"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </abbr>
        </label>
      </xsl:if>
    </grpSym>
  </xsl:template>

  <xsl:template match="part-group" mode="layout">
    <xsl:copy-of select="."/>
  </xsl:template>

  <xsl:template match="part-list" mode="layout">
    <xsl:variable name="scoreGroupsNotBroken" as="xs:boolean">
      <xsl:value-of select="every $groupStart in //part-list/part-group[@stype='start']
        satisfies($groupStart/following-sibling::part-group[@type='stop' and
        @number=$groupStart/@number])"/>
    </xsl:variable>
    <!--<xsl:message>scoreGroupsNotBroken: <xsl:value-of select="$scoreGroupsNotBroken"/></xsl:message>-->
    <xsl:variable name="scoreGroupsRanges" as="node()*">
      <xsl:for-each select="part-group[@type = 'start']">
        <range>
          <xsl:variable name="num" select="@number"/>
          <xsl:attribute name="start" select="count(preceding-sibling::score-part) + 0.5"/>
          <xsl:variable name="stop" select="following-sibling::part-group[@type='stop' and
            @number = $num][1]"/>
          <xsl:attribute name="stop" select="count($stop/preceding-sibling::score-part) + 0.5"/>
          <xsl:attribute name="num" select="$num"/>
        </range>
      </xsl:for-each>
    </xsl:variable>
    <!--<xsl:message>scoreGroupsRangesCount: <xsl:value-of select="count($scoreGroupsRanges)"/></xsl:message>-->
    <xsl:variable name="scoreRangesOverlaps" as="xs:boolean*">
      <xsl:for-each select="$scoreGroupsRanges">
        <xsl:variable name="start" select="number(@start)"/>
        <xsl:variable name="stop" select="number(@stop)"/>
        <xsl:value-of select="not(exists($scoreGroupsRanges[(number(@start) lt $start and
          number(@stop) gt $start and number(@stop) lt $stop) or (number(@start) gt $start
          and number(@start) lt $stop and number(@stop) gt $stop)]))"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="scoreRangesAreFine" select="every $x in $scoreRangesOverlaps satisfies ($x
      eq true())" as="xs:boolean"/>
    <!--<xsl:message>scoreRangesAreFine: <xsl:value-of select="$scoreRangesAreFine"/></xsl:message>-->
    <xsl:choose>
      <xsl:when test="$scoreRangesAreFine">
        <!-- No overlapping staff groups -->
        <xsl:variable name="outerStaffGrp">
          <staffGrp xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:variable name="tempTree">
              <!-- Create staffDef elements, copy part-group elements -->
              <xsl:apply-templates select="score-part|part-group" mode="layout"/>
            </xsl:variable>
            <xsl:variable name="tempTree2">
              <!-- Number staves -->
              <xsl:apply-templates select="$tempTree" mode="numberStaves"/>
            </xsl:variable>
            <!-- Emit staffGrp and staffDef elements already created -->
            <xsl:copy-of select="$tempTree2/mei:staffGrp|$tempTree2/mei:staffDef"/>
            <!-- Create stand-off staff grouping symbols -->
            <xsl:apply-templates select="$tempTree2/part-group[@type='start' and group-symbol]"
              mode="grpSym"/>
          </staffGrp>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$outerStaffGrp//grpSym">
            <!-- If there are stand-off grouping symbols, resolve them -->
            <xsl:call-template name="resolveGrpSym">
              <xsl:with-param name="in">
                <xsl:copy-of select="$outerStaffGrp"/>
              </xsl:with-param>
              <xsl:with-param name="maxLevel">
                <xsl:value-of select="number(max($outerStaffGrp//grpSym/@level))"/>
              </xsl:with-param>
              <xsl:with-param name="pass" select="number(1)"/>
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <!-- If there are no stand-off grouping symbols, processing of layout info is complete -->
            <xsl:copy-of select="$outerStaffGrp"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <!-- Overlapping staff groups -->
        <xsl:variable name="warning">Overlapping staff groups ignored</xsl:variable>
        <xsl:message>
          <xsl:value-of select="normalize-space($warning)"/>
        </xsl:message>
        <xsl:comment>
          <xsl:value-of select="normalize-space($warning)"/>
        </xsl:comment>
        <xsl:variable name="outerStaffGrp">
          <staffGrp xmlns="http://www.music-encoding.org/ns/mei">
            <xsl:variable name="tempTree">
              <!-- Create staffDef elements, copy part-group elements -->
              <xsl:apply-templates select="score-part" mode="layout"/>
            </xsl:variable>
            <xsl:variable name="tempTree2">
              <!-- Number staves -->
              <xsl:apply-templates select="$tempTree" mode="numberStaves"/>
            </xsl:variable>
            <!-- Emit staffGrp and staffDef elements already created -->
            <xsl:copy-of select="$tempTree2/mei:staffDef"/>
          </staffGrp>
        </xsl:variable>
        <xsl:copy-of select="$outerStaffGrp"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="score-part" mode="layout">
    <!-- Create staffDef elements -->
    <xsl:variable name="partID">
      <xsl:value-of select="@id"/>
    </xsl:variable>
    <xsl:variable name="staves">
      <xsl:choose>
        <xsl:when test="following::measure[1]/part[@id=$partID]/attributes/staves">
          <xsl:value-of select="max(following::measure[1]/part[@id=$partID]/attributes/staves)"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$staves=1">
        <!-- When the part uses a single staff, create a staffDef element, get its
          attributes by calling staffInitialAttributes, then make a child instrument
          definition. -->
        <staffDef xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:attribute name="xml:id">
            <xsl:value-of select="$partID"/>
          </xsl:attribute>
          <!-- staff label as attribute -->
          <xsl:if test="part-name[normalize-space(text()) != ''] or
            part-name-display[normalize-space(text()) != '']">
            <xsl:attribute name="label">
              <xsl:choose>
                <xsl:when test="part-name-display">
                  <xsl:value-of select="replace(replace(normalize-space(part-name-display), 'flat',
                    '&#x266d;'), 'sharp', '&#x266f;')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="part-name"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </xsl:if>
          <!-- abbreviated staff label as attribute -->
          <xsl:if test="part-abbreviation[normalize-space(text()) != ''] or
            part-abbreviation-display[normalize-space(text()) != '']">
            <xsl:attribute name="label.abbr">
              <xsl:choose>
                <xsl:when test="part-abbreviation-display">
                  <xsl:value-of select="replace(replace(normalize-space(part-abbreviation-display),
                    'flat', '&#x266d;'), 'sharp', '&#x266f;')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="part-abbreviation"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </xsl:if>
          <xsl:call-template name="staffInitialAttributes">
            <xsl:with-param name="partID">
              <xsl:value-of select="$partID"/>
            </xsl:with-param>
            <xsl:with-param name="staffNum"/>
          </xsl:call-template>

          <!-- staff labels as elements -->
          <xsl:if test="part-name[normalize-space(text()) != ''] or
            part-name-display[normalize-space(text()) != '']">
            <label xmlns="http://www.music-encoding.org/ns/mei">
              <xsl:choose>
                <xsl:when test="part-name-display">
                  <xsl:value-of select="replace(replace(normalize-space(part-name-display), 'flat',
                    '&#x266d;'), 'sharp', '&#x266f;')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="part-name[@font-family or @font-style or @font-size or
                      @font-weight or @letter-spacing or @line-height or @justify or @halign or
                      @valign or @color or @rotation or @xml:space or@underline or @overline
                      or @line-through or @dir or @enclosure!='none']">
                      <xsl:for-each select="part-name[@font-family or @font-style or @font-size or
                        @font-weight or @letter-spacing or @line-height or @justify or @halign or
                        @valign or @color or @rotation or @xml:space or @underline
                        or @overline or @line-through or @dir or @enclosure!='none']">
                        <xsl:call-template name="wrapRend">
                          <xsl:with-param name="in">
                            <xsl:value-of select="part-name"/>
                          </xsl:with-param>
                        </xsl:call-template>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="part-name"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </label>
          </xsl:if>
          <xsl:if test="part-abbreviation[normalize-space(text()) != ''] or
            part-abbreviation-display[normalize-space(text()) != '']">
            <label xmlns="http://www.music-encoding.org/ns/mei">
              <abbr>
                <xsl:choose>
                  <xsl:when test="part-abbreviation-display">
                    <xsl:value-of
                      select="replace(replace(normalize-space(part-abbreviation-display),
                      'flat', '&#x266d;'), 'sharp', '&#x266f;')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:choose>
                      <xsl:when test="part-abbreviation[@font-family or @font-style or @font-size or
                        @font-weight or @letter-spacing or @line-height or @justify or @halign or
                        @valign or @color or @rotation or @xml:space or @underline or @overline or
                        @line-through or @dir or @enclosure!='none']">
                        <xsl:for-each select="part-abbreviation[@font-family or @font-style or
                          @font-size or @font-weight or @letter-spacing or
                          @line-height or @justify or @halign or @valign or
                          @color or @rotation or @xml:space or @underline or
                          @overline or @line-through or @dir or @enclosure!='none']">
                          <xsl:call-template name="wrapRend">
                            <xsl:with-param name="in">
                              <xsl:value-of select="part-abbreviation"/>
                            </xsl:with-param>
                          </xsl:call-template>
                        </xsl:for-each>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="part-abbreviation"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
              </abbr>
            </label>
          </xsl:if>

          <!-- instrument definition -->
          <xsl:choose>
            <xsl:when test="midi-instrument">
              <xsl:for-each select="midi-instrument">
                <instrDef xmlns="http://www.music-encoding.org/ns/mei">
                  <xsl:variable name="thisID">
                    <xsl:value-of select="@id"/>
                  </xsl:variable>
                  <xsl:attribute name="xml:id">
                    <xsl:value-of select="@id"/>
                  </xsl:attribute>
                  <xsl:if test="midi-channel">
                    <xsl:attribute name="midi.channel">
                      <xsl:value-of select="midi-channel"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="midi-program">
                    <!-- MusicXML uses 1-based program numbers. Convert to 0-based. -->
                    <xsl:variable name="midiProgram">
                      <xsl:value-of select="number(midi-program)"/>
                    </xsl:variable>
                    <xsl:attribute name="midi.instrnum">
                      <xsl:value-of select="$midiProgram - 1"/>
                    </xsl:attribute>
                    <xsl:choose>
                      <xsl:when test="midi-channel != 10">
                        <xsl:if test="$midiNamesPitched/instrName[position()=$midiProgram] != ''">
                          <!-- Get MIDI instrument name from $midiNamesPitched -->
                          <xsl:attribute name="midi.instrname">
                            <xsl:value-of
                              select="$midiNamesPitched/instrName[position()=$midiProgram]"/>
                          </xsl:attribute>
                        </xsl:if>
                      </xsl:when>
                      <xsl:when test="midi-channel = 10">
                        <xsl:attribute name="label">
                          <xsl:value-of
                            select="preceding::score-instrument[@id=$thisID]/instrument-name"/>
                        </xsl:attribute>
                        <!-- Get MIDI instrument name from $midiNamesUnpitched -->
                        <xsl:variable name="midiUnpitched">
                          <xsl:value-of select="number(midi-unpitched) - 35"/>
                        </xsl:variable>
                        <xsl:if test="$midiNamesUnpitched/instrName[position()=$midiUnpitched] !=
                          ''">
                          <xsl:attribute name="midi.instrname">
                            <xsl:value-of
                              select="$midiNamesUnpitched/instrName[position()=$midiUnpitched]"/>
                          </xsl:attribute>
                        </xsl:if>
                      </xsl:when>
                    </xsl:choose>
                  </xsl:if>
                  <xsl:if test="volume">
                    <xsl:attribute name="midi.volume">
                      <!-- Map MusicXML volume values to MIDI -->
                      <xsl:value-of select="min((127, round(127 * .01 * volume)))"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="pan">
                    <xsl:attribute name="midi.pan">
                      <xsl:choose>
                        <!-- MIDI doesn't recognize a 360-degree sound field -->
                        <xsl:when test="pan = 180 or pan = -180">
                          <xsl:value-of select="0"/>
                        </xsl:when>
                        <!-- Map degree value into 0 - 127 range -->
                        <xsl:otherwise>
                          <xsl:value-of select="round((127 div 360) * (pan + 180))"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:attribute>
                  </xsl:if>
                </instrDef>
              </xsl:for-each>
            </xsl:when>
          </xsl:choose>

          <!-- CREATE LAYERDEFS HERE? -->

        </staffDef>
      </xsl:when>
      <xsl:otherwise>
        <!-- When there's more than one staff in the part, create a staffGrp and midi instrument
             definition(s) for the group, then the required number of MEI staffDef elements. -->
        <staffGrp xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:attribute name="xml:id">
            <xsl:value-of select="$partID"/>
          </xsl:attribute>
          <!-- Single part with multiple staves always uses a curly brace -->
          <xsl:attribute name="symbol">brace</xsl:attribute>
          <!-- group label as attribute -->
          <xsl:if test="part-name[normalize-space(text()) != ''] or
            part-name-display[normalize-space(text()) != '']">
            <xsl:attribute name="label">
              <xsl:choose>
                <xsl:when test="part-name-display">
                  <xsl:value-of select="replace(replace(normalize-space(part-name-display), 'flat',
                    '&#x266d;'), 'sharp', '&#x266f;')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="part-name"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </xsl:if>
          <!-- abbreviated group label as attribute -->
          <xsl:if test="part-abbreviation[normalize-space(text()) != ''] or
            part-abbreviation-display[normalize-space(text()) != '']">
            <xsl:attribute name="label.abbr">
              <xsl:choose>
                <xsl:when test="part-abbreviation-display">
                  <xsl:value-of select="replace(replace(normalize-space(part-abbreviation-display),
                    'flat', '&#x266d;'), 'sharp', '&#x266f;')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="part-abbreviation"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </xsl:if>
          <!-- group label as element -->
          <xsl:if test="part-name[normalize-space(text()) != ''] or
            part-name-display[normalize-space(text()) != '']">
            <label xmlns="http://www.music-encoding.org/ns/mei">
              <xsl:choose>
                <xsl:when test="part-name-display">
                  <xsl:value-of select="replace(replace(normalize-space(part-name-display), 'flat',
                    '&#x266d;'), 'sharp', '&#x266f;')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="part-name[@font-family or @font-style or @font-size or
                      @font-weight or @letter-spacing or @line-height or @justify or @halign or
                      @valign or @color or @rotation or @xml:space or@underline or @overline
                      or @line-through or @dir or @enclosure!='none']">
                      <xsl:for-each select="part-name[@font-family or @font-style or @font-size or
                        @font-weight or @letter-spacing or @line-height or @justify or @halign or
                        @valign or @color or @rotation or @xml:space or @underline
                        or @overline or @line-through or @dir or @enclosure!='none']">
                        <xsl:call-template name="wrapRend">
                          <xsl:with-param name="in">
                            <xsl:value-of select="part-name"/>
                          </xsl:with-param>
                        </xsl:call-template>
                      </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="part-name"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:otherwise>
              </xsl:choose>
            </label>
          </xsl:if>
          <xsl:if test="part-abbreviation[normalize-space(text()) != ''] or
            part-abbreviation-display[normalize-space(text()) != '']">
            <label xmlns="http://www.music-encoding.org/ns/mei">
              <abbr>
                <xsl:choose>
                  <xsl:when test="part-abbreviation-display">
                    <xsl:value-of
                      select="replace(replace(normalize-space(part-abbreviation-display),
                      'flat', '&#x266d;'), 'sharp', '&#x266f;')"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:choose>
                      <xsl:when test="part-abbreviation[@font-family or @font-style or @font-size or
                        @font-weight or @letter-spacing or @line-height or @justify or @halign or
                        @valign or @color or @rotation or @xml:space or @underline or @overline or
                        @line-through or @dir or @enclosure!='none']">
                        <xsl:for-each select="part-abbreviation[@font-family or @font-style or
                          @font-size or @font-weight or @letter-spacing or
                          @line-height or @justify or @halign or @valign or
                          @color or @rotation or @xml:space or @underline or
                          @overline or @line-through or @dir or @enclosure!='none']">
                          <xsl:call-template name="wrapRend">
                            <xsl:with-param name="in">
                              <xsl:value-of select="part-abbreviation"/>
                            </xsl:with-param>
                          </xsl:call-template>
                        </xsl:for-each>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="part-abbreviation"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:otherwise>
                </xsl:choose>
              </abbr>
            </label>
          </xsl:if>

          <!-- instrument definition -->
          <xsl:for-each select="midi-instrument">
            <instrDef xmlns="http://www.music-encoding.org/ns/mei">
              <xsl:variable name="thisID">
                <xsl:value-of select="@id"/>
              </xsl:variable>
              <xsl:attribute name="xml:id">
                <xsl:value-of select="@id"/>
              </xsl:attribute>
              <xsl:if test="midi-channel">
                <xsl:attribute name="midi.channel">
                  <xsl:value-of select="midi-channel"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:if test="midi-program">
                <!-- It appears that MusicXML is using 1-based program numbers. Convert to 0-based. -->
                <xsl:variable name="midiProgram">
                  <xsl:value-of select="number(midi-program)"/>
                </xsl:variable>
                <xsl:attribute name="midi.instrnum">
                  <xsl:value-of select="$midiProgram - 1"/>
                </xsl:attribute>
                <xsl:choose>
                  <xsl:when test="midi-channel != 10">
                    <xsl:if test="$midiNamesPitched/instrName[position()=$midiProgram] != ''">
                      <!-- Get MIDI instrument name from $midiNamesPitched -->
                      <xsl:attribute name="midi.instrname">
                        <xsl:value-of select="$midiNamesPitched/instrName[position()=$midiProgram]"
                        />
                      </xsl:attribute>
                    </xsl:if>
                  </xsl:when>
                  <xsl:when test="midi-channel = 10">
                    <xsl:attribute name="label">
                      <xsl:value-of
                        select="preceding::score-instrument[@id=$thisID]/instrument-name"/>
                    </xsl:attribute>
                    <!-- Get MIDI instrument name from $midiNamesUnpitched -->
                    <xsl:variable name="midiUnpitched">
                      <xsl:value-of select="number(midi-unpitched) - 35"/>
                    </xsl:variable>
                    <xsl:if test="$midiNamesUnpitched/instrName[position()=$midiUnpitched] != ''">
                      <xsl:attribute name="midi.instrname">
                        <xsl:value-of
                          select="$midiNamesUnpitched/instrName[position()=$midiUnpitched]"/>
                      </xsl:attribute>
                    </xsl:if>
                  </xsl:when>
                </xsl:choose>
              </xsl:if>
              <xsl:if test="volume">
                <xsl:attribute name="midi.volume">
                  <!-- Map MusicXML volume values to MIDI -->
                  <xsl:value-of select="min((127, round(127 * .01 * volume)))"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:if test="pan">
                <xsl:attribute name="midi.pan">
                  <xsl:choose>
                    <!-- MIDI doesn't recognize a 360-degree sound field -->
                    <xsl:when test="pan = 180 or pan = -180">
                      <xsl:value-of select="0"/>
                    </xsl:when>
                    <!-- Map degree value into 0 - 127 range -->
                    <xsl:otherwise>
                      <xsl:value-of select="round((127 div 360) * (pan + 180))"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
              </xsl:if>
            </instrDef>
          </xsl:for-each>
          <xsl:call-template name="makeStaff">
            <xsl:with-param name="partID">
              <xsl:value-of select="$partID"/>
            </xsl:with-param>
            <xsl:with-param name="needed">
              <xsl:value-of select="$staves"/>
            </xsl:with-param>
          </xsl:call-template>
        </staffGrp>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="score-timewise" mode="header">
    <meiHead xmlns="http://www.music-encoding.org/ns/mei">
      <fileDesc>
        <xsl:call-template name="titleStmt"/>
        <pubStmt>
          <xsl:if test="$keepRights = 'true' and identification/rights">
            <availability>
              <useRestrict>
                <xsl:value-of select="identification/rights"/>
              </useRestrict>
            </availability>
          </xsl:if>
        </pubStmt>
        <sourceDesc>
          <source>
            <xsl:call-template name="titleStmt"/>
            <pubStmt>
              <xsl:if test="identification/rights">
                <availability>
                  <useRestrict>
                    <xsl:value-of select="identification/rights"/>
                  </useRestrict>
                </availability>
              </xsl:if>
            </pubStmt>
            <xsl:if test="count(distinct-values(//*/@xml:lang)) &gt; 0">
              <langUsage>
                <xsl:for-each select="distinct-values(//*/@xml:lang)">
                  <!-- Identify all the languages used anywhere in the document. -->
                  <language>
                    <xsl:attribute name="xml:id">
                      <xsl:value-of select="."/>
                    </xsl:attribute>
                  </language>
                </xsl:for-each>
              </langUsage>
            </xsl:if>

            <xsl:if test="identification/encoding/software |
              identification/miscellaneous/miscellaneous-field">
              <notesStmt>
                <xsl:if test="identification/encoding/software">
                  <!-- MusicXML file encoding description -->
                  <annot>
                    <xsl:text>Source MusicXML file created </xsl:text>
                    <xsl:if test="identification/encoding/encoder">
                      <xsl:text>by </xsl:text>
                      <xsl:for-each select="identification/encoding/encoder">
                        <xsl:value-of select="."/>
                        <xsl:if test="count(following-sibling::encoder) &gt; 1">
                          <xsl:text>, </xsl:text>
                        </xsl:if>
                        <xsl:if test="count(following-sibling::encoder) = 1">
                          <xsl:choose>
                            <xsl:when test="count(preceding-sibling::encoder) = 0">
                              <xsl:text> and </xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:text>, and </xsl:text>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:if>
                      </xsl:for-each>
                      <xsl:text>&#32;</xsl:text>
                    </xsl:if>
                    <xsl:text>using </xsl:text>
                    <xsl:for-each select="identification/encoding/software">
                      <xsl:value-of select="."/>
                      <xsl:if test="count(following-sibling::software) &gt; 1">
                        <xsl:text>, </xsl:text>
                      </xsl:if>
                      <xsl:if test="count(following-sibling::software) = 1">
                        <xsl:choose>
                          <xsl:when test="count(preceding-sibling::software) = 0">
                            <xsl:text> and </xsl:text>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:text>, and </xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:if>
                    </xsl:for-each>
                    <xsl:if test="identification/encoding/encoding-date">
                      <xsl:text> on </xsl:text>
                      <date>
                        <xsl:value-of select="identification/encoding/encoding-date"/>
                      </date>
                    </xsl:if>
                    <xsl:text>.</xsl:text>
                  </annot>
                  <xsl:if test="identification/encoding/encoding-description">
                    <annot>
                      <xsl:value-of select="identification/encoding/encoding-description"/>
                    </annot>
                  </xsl:if>
                </xsl:if>
                <xsl:for-each select="identification/miscellaneous/miscellaneous-field">
                  <annot>
                    <xsl:attribute name="label">
                      <xsl:value-of select="@name"/>
                    </xsl:attribute>
                    <xsl:value-of select="normalize-space(.)"/>
                  </annot>
                </xsl:for-each>
              </notesStmt>
            </xsl:if>
          </source>
        </sourceDesc>
      </fileDesc>
      <!-- MEI file encoding description in encodingDesc -->
      <encodingDesc>
        <editorialDecl>
          <normalization>
            <p>Calculation of @tstamp and @tstamp2 values on control events, such as dir, dynam,
              hairpin, etc., includes MusicXML offset values.</p>
            <p>The parameters for musicxml2mei.xsl were set as follows: <list>
                <li>accidStyle: "<xsl:value-of select="$accidStyle"/>", </li>
                <li>articStyle: "<xsl:value-of select="$articStyle"/>", </li>
                <li>formeWork: "<xsl:value-of select="$formeWork"/>", </li>
                <li>generateMIDI: "<xsl:value-of select="$generateMIDI"/>", </li>
                <li>keepAttributes: "<xsl:value-of select="$keepAttributes"/>", </li>
                <li>keepRights: "<xsl:value-of select="$keepRights"/>", </li>
                <li>labelStyle: "<xsl:value-of select="$labelStyle"/>", </li>
                <li>layout: "<xsl:value-of select="$layout"/>", </li>
                <li>tieStyle: "<xsl:value-of select="$tieStyle"/>"</li>
              </list></p>
          </normalization>
        </editorialDecl>
        <!--<projectDesc>
          <p>
            <xsl:text>Transcoded from a MusicXML </xsl:text>
            <xsl:if test="@version">
              <xsl:text>version </xsl:text>
              <xsl:value-of select="@version"/>
              <xsl:text>&#32;</xsl:text>
            </xsl:if>
            <xsl:text>file on </xsl:text>
            <date>
              <xsl:value-of select="format-date(current-date(), '[Y]-[M02]-[D02]')"/>
            </date>
            <xsl:text>using an XSLT stylesheet (</xsl:text>
            <xsl:value-of select="$progName"/>
            <xsl:text>&#32;</xsl:text>
            <xsl:value-of select="$progVersion"/>
            <xsl:text>).</xsl:text>
          </p>
        </projectDesc>-->
        <xsl:if test="matches(work/work-title, '[\(\[].*[\)\]]') or matches(movement-title,
          '[\(\[].*[\)\]]') or matches(work/work-title, 'excerpt', 'i') or
          matches(movement-title, 'excerpt', 'i') or matches(work/work-title,
          'pages?&#32;', 'i') or matches(movement-title, 'pages?&#32;', 'i')">
          <xsl:variable name="warning">Sampling declaration may be necessary.</xsl:variable>
          <xsl:message>
            <xsl:value-of select="normalize-space($warning)"/>
          </xsl:message>
          <xsl:comment>
            <xsl:value-of select="normalize-space($warning)"/>
          </xsl:comment>
        </xsl:if>
      </encodingDesc>
      <xsl:if test="work/*">
        <workDesc>
          <work>
            <xsl:call-template name="titleStmt"/>
          </work>
        </workDesc>
      </xsl:if>
      <revisionDesc xmlns="http://www.music-encoding.org/ns/mei">
        <!--<xsl:if test="identification/encoding/software">
          <change n="1">
            <respStmt>
              <xsl:for-each select="identification/encoding/encoder">
                <name xmlns="http://www.music-encoding.org/ns/mei">
                  <xsl:value-of select="."/>
                </name>
              </xsl:for-each>
            </respStmt>
            <changeDesc>
              <p>
                <xsl:text>MusicXML file created</xsl:text>
                <xsl:if test="identification/encoding/software">
                  <xsl:text> using </xsl:text>
                </xsl:if>
                <xsl:for-each select="identification/encoding/software">
                  <xsl:value-of select="."/>
                  <xsl:if test="count(following-sibling::software) &gt; 1">
                    <xsl:text>, </xsl:text>
                  </xsl:if>
                  <xsl:if test="count(following-sibling::software) = 1">
                    <xsl:choose>
                      <xsl:when test="count(preceding-sibling::software) = 0">
                        <xsl:text> and </xsl:text>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:text>, and </xsl:text>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:if>
                </xsl:for-each>
              </p>
            </changeDesc>
            <date>
              <xsl:value-of select="identification/encoding/encoding-date"/>
            </date>
          </change>
        </xsl:if> -->
        <change n="1">
          <respStmt/>
          <changeDesc>
            <p>
              <xsl:text>Transcoded from a MusicXML </xsl:text>
              <xsl:if test="@version">
                <xsl:text>version </xsl:text>
                <xsl:value-of select="@version"/>
                <xsl:text>&#32;</xsl:text>
              </xsl:if>
              <xsl:text>file </xsl:text>
              <xsl:text>using an XSLT stylesheet (</xsl:text>
              <xsl:value-of select="$progName"/>
              <xsl:text>&#32;</xsl:text>
              <xsl:value-of select="$progVersion"/>
              <xsl:text>).</xsl:text>
            </p>
          </changeDesc>
          <date>
            <xsl:value-of select="format-date(current-date(), '[Y]-[M02]-[D02]')"/>
          </date>
        </change>
      </revisionDesc>
    </meiHead>
  </xsl:template>

  <xsl:template match="score-timewise" mode="music">
    <music xmlns="http://www.music-encoding.org/ns/mei">
      <body>
        <mdiv>
          <score>
            <scoreDef>
              <xsl:attribute name="ppq">
                <xsl:value-of select="$scorePPQ"/>
              </xsl:attribute>
              <!-- Look in first measure for score-level meter signature -->
              <xsl:if test="descendant::measure[1]/part/attributes[time/senza-misura]">
                <xsl:attribute name="meter.rend">invis</xsl:attribute>
              </xsl:if>
              <xsl:if test="descendant::measure[1]/part/attributes[time/beats]">
                <xsl:choose>
                  <xsl:when
                    test="count(descendant::measure[1]/part[1]/attributes[time/beats]/time/beats)
                    = 1">
                    <xsl:attribute name="meter.count">
                      <xsl:value-of
                        select="descendant::measure[1]/part[attributes/time/beats][1]/attributes/time/beats"
                      />
                    </xsl:attribute>
                    <xsl:if test="descendant::measure[1]/part[1]/attributes[time/beat-type]">
                      <xsl:attribute name="meter.unit">
                        <xsl:value-of
                          select="descendant::measure[1]/part[attributes/time/beat-type][1]/attributes/time/beat-type"
                        />
                      </xsl:attribute>
                    </xsl:if>
                    <xsl:variable name="symbol">
                      <xsl:value-of
                        select="descendant::measure[1]/part[attributes/time/@symbol][1]/attributes/time/@symbol"
                      />
                    </xsl:variable>
                    <xsl:choose>
                      <xsl:when test="$symbol='common'">
                        <xsl:attribute name="meter.sym">common</xsl:attribute>
                        <xsl:if
                          test="not(descendant::measure[1]/part[attributes/time/@symbol][1]/attributes/time/beats=4)
                          or
                          not(descendant::measure[1]/part[attributes/time/@symbol][1]/attributes/time/beat-type=4)">
                          <xsl:variable name="measureNum">
                            <xsl:value-of select="1"/>
                          </xsl:variable>
                          <xsl:variable name="warning">
                            <xsl:text>Common time symbol does not match time signature</xsl:text>
                          </xsl:variable>
                          <xsl:message>
                            <xsl:value-of select="normalize-space(concat($warning, ' (m. ',
                              $measureNum, ').'))"/>
                          </xsl:message>
                        </xsl:if>
                      </xsl:when>
                      <xsl:when test="$symbol='cut'">
                        <xsl:attribute name="meter.sym">cut</xsl:attribute>
                        <xsl:if
                          test="not(descendant::measure[1]/part[attributes/time/@symbol][1]/attributes/time/beats=2)
                          or
                          not(descendant::measure[1]/part[attributes/time/@symbol][1]/attributes/time/beat-type=2)">
                          <xsl:variable name="measureNum">
                            <xsl:value-of select="1"/>
                          </xsl:variable>
                          <xsl:variable name="warning">
                            <xsl:text>Cut time symbol does not match time signature</xsl:text>
                          </xsl:variable>
                          <xsl:message>
                            <xsl:value-of select="normalize-space(concat($warning, ' (m. ',
                              $measureNum, ').'))"/>
                          </xsl:message>
                        </xsl:if>
                      </xsl:when>
                      <xsl:when test="$symbol='single-number'">
                        <xsl:attribute name="meter.rend">num</xsl:attribute>
                      </xsl:when>
                    </xsl:choose>
                  </xsl:when>
                </xsl:choose>
              </xsl:if>
              <!-- Look in first measure for score-level key signature and mode -->
              <xsl:if test="descendant::measure[1]/part/attributes[not(transpose)]/key/key-step">
                <xsl:variable name="warning">
                  <xsl:text>Non-traditional key signature not transcoded (score)</xsl:text>
                </xsl:variable>
                <xsl:message>
                  <xsl:value-of select="normalize-space(concat($warning, '.'))"/>
                </xsl:message>
              </xsl:if>
              <xsl:if test="descendant::measure[1]/part/attributes[not(transpose)]/key">
                <xsl:variable name="keySig">
                  <xsl:value-of select="descendant::measure[1]/part[attributes[not(transpose) and
                    key]][1]/attributes/key/fifths"/>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="$keySig=''">
                    <xsl:attribute name="key.sig">
                      <xsl:text>0</xsl:text>
                    </xsl:attribute>
                  </xsl:when>
                  <xsl:when test="number($keySig)=0">
                    <xsl:attribute name="key.sig">
                      <xsl:value-of select="$keySig"/>
                    </xsl:attribute>
                  </xsl:when>
                  <xsl:when test="number($keySig) &gt; 0">
                    <xsl:attribute name="key.sig"><xsl:value-of select="$keySig"/>s</xsl:attribute>
                  </xsl:when>
                  <xsl:when test="number($keySig) &lt; 0">
                    <xsl:attribute name="key.sig">
                      <xsl:value-of select="abs($keySig)"/>f</xsl:attribute>
                  </xsl:when>
                </xsl:choose>
                <xsl:if test="descendant::measure[1]/part/attributes[not(preceding-sibling::note)
                  and not(preceding-sibling::forward) and not(transpose)]/key/mode">
                  <xsl:attribute name="key.mode">
                    <xsl:value-of
                      select="descendant::measure[1]/part[attributes[not(preceding-sibling::note)
                      and not(preceding-sibling::forward) and
                      not(transpose)]/key/mode][1]/attributes[not(preceding-sibling::note) and
                      not(preceding-sibling::forward) and not(transpose)]/key/mode"/>
                  </xsl:attribute>
                </xsl:if>
              </xsl:if>
              <!-- If any staves are not printed, then staff optimization is in effect. -->
              <xsl:if test="//measure/part/attributes/staff-details/@print-object='no'">
                <xsl:attribute name="optimize">true</xsl:attribute>
              </xsl:if>
              <!-- Look in first measure for other score-level attributes -->
              <xsl:apply-templates select="defaults"/>

              <!-- Provide multiple time signatures as elements -->
              <xsl:if test="descendant::measure[1]/part/attributes[time/beats]">
                <xsl:choose>
                  <xsl:when
                    test="count(descendant::measure[1]/part[1]/attributes[time/beats]/time/beats)
                    &gt; 1">
                    <meterSigGrp>
                      <xsl:attribute name="func">
                        <xsl:choose>
                          <xsl:when
                            test="descendant::measure[1]/part[1]/attributes[time/beats]/time/interchangeable">
                            <xsl:text>interchanging</xsl:text>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:text>mixed</xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:attribute>
                      <xsl:for-each
                        select="descendant::measure[1]/part[1]/attributes[time/beats]/time/beats">
                        <meterSig>
                          <xsl:attribute name="count">
                            <xsl:value-of select="."/>
                          </xsl:attribute>
                          <xsl:attribute name="unit">
                            <xsl:value-of select="following-sibling::beat-type[1]"/>
                          </xsl:attribute>
                        </meterSig>
                      </xsl:for-each>
                    </meterSigGrp>
                  </xsl:when>
                </xsl:choose>
              </xsl:if>

              <!-- Create page headers and footers -->
              <xsl:if test="credit">
                <xsl:call-template name="credits"/>
              </xsl:if>

              <!-- Copy already-calculated layout here -->
              <xsl:copy-of select="$defaultLayout"/>
            </scoreDef>

            <!-- Process score measures -->
            <!-- Measures are grouped based on criteria in the group-ending-with attribute -->
            <xsl:for-each-group select="measure"
              group-ending-with="measure[part/barline/repeat[@direction='backward'] or
              following-sibling::measure[1][part/barline[@location='left']/repeat[@direction='forward']]
              or part/barline/ending[@type='stop' or @type='discontinue'] or
              part/barline[@location='right']/bar-style='light-light' or
              following-sibling::measure[1][part/barline/ending[@type='start']] or
              following-sibling::measure[1][part/attributes[time or key]]]">

              <!-- Other potential (sub?) section-ending conditions:
following-sibling::measure[1][print/page-layout] or
following-sibling::measure[1][print/system-layout] or
following-sibling::measure[1][print/staff-layout] or
following-sibling::measure[1][print/measure-layout] or
following-sibling::measure[1][attributes[staves]] or
following-sibling::measure[1][attributes[not(preceding-sibling::note)]] -->

              <!-- Create sections/endings based on the grouping of measures -->
              <xsl:choose>
                <xsl:when test="part/barline/ending[@type='start']">
                  <ending>
                    <xsl:attribute name="n">
                      <xsl:choose>
                        <xsl:when test="part/barline/ending[@type='start'] != ''">
                          <xsl:value-of
                            select="part[barline/ending[@type='start']][1]/barline[ending[@type='start']][1]/ending"
                          />
                        </xsl:when>
                        <xsl:otherwise>
                          <xsl:value-of
                            select="part[barline/ending[@type='start']][1]/barline[ending[@type='start']][1]/ending/@number"
                          />
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:attribute>
                    <xsl:for-each-group select="current-group()"
                      group-starting-with="measure[part/attributes[time or key]]">
                      <xsl:apply-templates select="current-group()" mode="measContent"/>
                    </xsl:for-each-group>
                  </ending>
                </xsl:when>
                <xsl:otherwise>
                  <section>
                    <xsl:for-each-group select="current-group()"
                      group-starting-with="measure[part/attributes[time or key]]">
                      <xsl:apply-templates select="current-group()" mode="measContent"/>
                    </xsl:for-each-group>
                  </section>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each-group>
          </score>
        </mdiv>
      </body>
    </music>
  </xsl:template>

  <!-- Functions -->
  <!-- f:hex2integer provided by Thomas Weber -->
  <xsl:function name="f:hex2integer" as="xs:integer*">
    <!-- Accepts hexstrings of arbitrary length as argument (only integer precision is the limit) 
         Also can take a sequence of hex strings. Then will return a sequence of integers. -->
    <xsl:param name="hex" as="xs:string*"/>
    <xsl:for-each select="$hex">
      <xsl:variable name="hexLength" select="string-length()"/>
      <!-- "string-length(substring-before(..))" gets us the value of the byte -->
      <xsl:sequence select="string-length(substring-before('0123456789ABCDEF',
        upper-case(substring(.,$hexLength,1)) (: this returns the last (lowest) byte :) ))
        (: Now we look for higher bytes and add them, if present :) + (if($hexLength gt 1)
        then 16 * f:hex2integer(substring(.,1,$hexLength - 1)) (: recurse, stripping last (lowest)
        byte :) else 0)"/>
    </xsl:for-each>
  </xsl:function>

  <!-- Named templates -->
  <xsl:template name="aarrggbb2css" as="xs:string">
    <!-- Provided by Thomas Weber -->
    <!-- Expects parameter of form '#aarrggbb' -->
    <xsl:param name="aarrggbb" as="xs:string"/>
    <xsl:value-of select="('rgba(', for $startByte in (4,6,8) (: Red, green and blue start at
      byte 4, 6 and 8 :) return concat( (: In each iteration, :)
      f:hex2integer(substring($aarrggbb,$startByte,2)), (: ... return the decimal value :) ','
      (: ... and a trailing comma :) ), format-number(f:hex2integer(substring($aarrggbb,2,2)) div
      255, '0.00'), (: alpha value is between 0 and 1 => divide by 255 :) ')' )" separator=""/>
  </xsl:template>

  <xsl:template name="accidentals">
    <!-- Accidentals in elements so that exact placement can be recorded -->
    <xsl:for-each select="accidental | notations/accidental-mark">
      <xsl:variable name="thisAccid">
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:variable>
      <accid xmlns="http://www.music-encoding.org/ns/mei">
        <xsl:choose>
          <xsl:when test="@editorial='yes'">
            <xsl:attribute name="func">edit</xsl:attribute>
          </xsl:when>
          <xsl:when test="@cautionary='yes'">
            <xsl:attribute name="func">caution</xsl:attribute>
          </xsl:when>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="@parentheses='yes'">
            <xsl:attribute name="enclose">paren</xsl:attribute>
          </xsl:when>
          <xsl:when test="@bracket='yes'">
            <xsl:attribute name="enclose">brack</xsl:attribute>
          </xsl:when>
        </xsl:choose>
        <xsl:choose>
          <xsl:when test="contains($thisAccid, 'slash)') or contains($thisAccid, 'sori') or
            contains($thisAccid, 'koron') or matches($thisAccid, '(sharp|flat)-[0-9]')">
            <xsl:variable name="measureNum">
              <xsl:value-of select="ancestor::measure/@number"/>
            </xsl:variable>
            <xsl:variable name="warning">
              <xsl:text>Middle-Eastern accidentals ignored</xsl:text>
            </xsl:variable>
            <xsl:message>
              <xsl:value-of select="normalize-space(concat($warning, ' (m. ', $measureNum,
                ').'))"/>
            </xsl:message>
            <xsl:comment>
              <xsl:value-of select="normalize-space(concat($warning, '.'))"/>
            </xsl:comment>
          </xsl:when>
          <xsl:otherwise>
            <xsl:attribute name="accid">
              <xsl:choose>
                <xsl:when test="$thisAccid = 'sharp'">s</xsl:when>
                <xsl:when test="$thisAccid = 'natural'">n</xsl:when>
                <xsl:when test="$thisAccid = 'flat'">f</xsl:when>
                <xsl:when test="$thisAccid = 'double-sharp'">x</xsl:when>
                <xsl:when test="$thisAccid = 'double-flat'">ff</xsl:when>
                <xsl:when test="$thisAccid = 'sharp-sharp'">ss</xsl:when>
                <xsl:when test="$thisAccid = 'flat-flat'">ff</xsl:when>
                <xsl:when test="$thisAccid = 'natural-sharp'">ns</xsl:when>
                <xsl:when test="$thisAccid = 'natural-flat'">nf</xsl:when>
                <xsl:when test="$thisAccid = 'flat-down'">fd</xsl:when>
                <xsl:when test="$thisAccid = 'flat-up'">fu</xsl:when>
                <xsl:when test="$thisAccid = 'natural-down'">nd</xsl:when>
                <xsl:when test="$thisAccid = 'natural-up'">nu</xsl:when>
                <xsl:when test="$thisAccid = 'sharp-down'">sd</xsl:when>
                <xsl:when test="$thisAccid = 'sharp-up'">su</xsl:when>
                <xsl:when test="$thisAccid = 'triple-sharp'">ts</xsl:when>
                <xsl:when test="$thisAccid = 'triple-flat'">tf</xsl:when>
              </xsl:choose>
            </xsl:attribute>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="not(normalize-space(@placement) = '')">
          <xsl:attribute name="place">
            <xsl:value-of select="normalize-space(@placement)"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:call-template name="positionRelative"/>
        <xsl:call-template name="fontProperties"/>
        <xsl:call-template name="color"/>
      </accid>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="artics">
    <!-- Populates the artic attribute on note. Use the articulations
    template for artic sub-elements. -->
    <xsl:variable name="articlist">
      <xsl:for-each select="notations/articulations/*[not(local-name()='breath-mark' or
        local-name()='caesura' or local-name()='stress' or local-name()='unstress' or
        local-name()='other-articulation')]">
        <!-- In MEI breath marks, caesura, and metrical indications (stress and unstress)
          are treated elsewhere as directives. Other-articulation is not currently transcoded. -->
        <xsl:choose>
          <xsl:when test="local-name()='accent'">
            <xsl:text>acc</xsl:text>
          </xsl:when>
          <xsl:when test="local-name()='detached-legato'">
            <xsl:text>ten-stacc</xsl:text>
          </xsl:when>
          <xsl:when test="local-name()='doit'">
            <xsl:text>doit</xsl:text>
          </xsl:when>
          <xsl:when test="local-name()='falloff'">
            <xsl:text>fall</xsl:text>
          </xsl:when>
          <xsl:when test="local-name()='plop'">
            <xsl:text>plop</xsl:text>
          </xsl:when>
          <!-- Scoop and rip are not equivalent; scoop not currently
          supported in MEI. This test can be reinstated after 'scoop'
          is added to data.ARTICULATION. -->
          <!--<xsl:when test="local-name()='scoop'">
            <xsl:text>rip</xsl:text>
          </xsl:when>-->
          <xsl:when test="local-name()='spiccato'">
            <xsl:text>spicc</xsl:text>
          </xsl:when>
          <xsl:when test="local-name()='staccatissimo'">
            <xsl:text>stacciss</xsl:text>
          </xsl:when>
          <xsl:when test="local-name()='staccato'">
            <xsl:text>stacc</xsl:text>
          </xsl:when>
          <xsl:when test="local-name()='strong-accent'">
            <xsl:text>marc</xsl:text>
          </xsl:when>
          <xsl:when test="local-name()='tenuto'">
            <xsl:text>ten</xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:text>&#32;</xsl:text>
      </xsl:for-each>
      <xsl:for-each select="notations/technical/*[not(local-name()='arrow' or
        local-name()='bend' or local-name()='fingering' or local-name()='fret' or
        local-name()='hammer-on' or local-name()='handbell' or local-name()='hole' or
        local-name()='other-technical' or local-name()='pluck' or local-name()='pull-off' or
        local-name()='string' or local-name()='tap' or local-name()='thumb-position')]">
        <!-- String and fret indications are handled elsewhere as note attributes. Fingering,
          pluck, hammer-on, pull-off, and tap indications are treated elsewhere as directives.
          The remaining elements above are not currently transcoded. -->
        <xsl:choose>
          <xsl:when test="local-name()='double-tongue'">
            <xsl:text>dbltongue</xsl:text>
          </xsl:when>
          <xsl:when test="local-name()='down-bow'">
            <xsl:text>dnbow</xsl:text>
          </xsl:when>
          <xsl:when test="local-name()='fingernails'">
            <xsl:text>fingernail</xsl:text>
          </xsl:when>
          <xsl:when test="local-name()='harmonic'">
            <xsl:text>harm</xsl:text>
          </xsl:when>
          <xsl:when test="local-name()='heel'">
            <xsl:text>heel</xsl:text>
          </xsl:when>
          <xsl:when test="local-name()='open-string'">
            <xsl:text>open</xsl:text>
          </xsl:when>
          <!-- In MusicXML 'pluck' is an indication of fingering, not articulation -->
          <xsl:when test="local-name()='snap-pizzicato'">
            <xsl:text>snap</xsl:text>
          </xsl:when>
          <xsl:when test="local-name()='stopped'">
            <xsl:text>stop</xsl:text>
          </xsl:when>
          <!-- Because it can contain text, tap is converted to a directive -->
          <xsl:when test="local-name()='toe'">
            <xsl:text>toe</xsl:text>
          </xsl:when>
          <xsl:when test="local-name()='triple-tongue'">
            <xsl:text>trpltongue</xsl:text>
          </xsl:when>
          <xsl:when test="local-name()='up-bow'">
            <xsl:text>upbow</xsl:text>
          </xsl:when>
        </xsl:choose>
        <xsl:text>&#32;</xsl:text>
      </xsl:for-each>
    </xsl:variable>
    <xsl:if test="normalize-space($articlist) != ''">
      <xsl:attribute name="artic">
        <xsl:value-of select="normalize-space($articlist)"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="articulations">
    <!-- Creates artic sub-elements so that placement of the articulations
    can be recorded. -->
    <xsl:for-each select="notations/articulations/*[not(local-name()='breath-mark' or
      local-name()='caesura' or local-name()='stress' or local-name()='unstress' or
      local-name()='other-articulation' or local-name()='scoop')]">
      <!-- Breath marks, caesura, stress, and unstress are treated elsewhere as directives.
        Other-articulation and scoop are not currently transcoded. -->
      <artic xmlns="http://www.music-encoding.org/ns/mei">
        <xsl:choose>
          <xsl:when test="local-name()='accent'">
            <xsl:attribute name="artic">acc</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="local-name()='detached-legato'">
            <xsl:attribute name="artic">ten-stacc</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="local-name()='doit'">
            <xsl:attribute name="artic">doit</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="local-name()='falloff'">
            <xsl:attribute name="artic">fall</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="local-name()='plop'">
            <xsl:attribute name="artic">plop</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <!-- Scoop and rip are not equivalent; scoop not currently
          supported in MEI. This test can be reinstated after 'scoop'
          is added to data.ARTICULATION. -->
          <!--<xsl:when test="local-name()='scoop'">
            <xsl:attribute name="artic">rip</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>-->
          <xsl:when test="local-name()='spiccato'">
            <xsl:attribute name="artic">spicc</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="local-name()='staccatissimo'">
            <xsl:attribute name="artic">stacciss</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="local-name()='staccato'">
            <xsl:attribute name="artic">stacc</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="local-name()='strong-accent'">
            <xsl:attribute name="artic">marc</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="local-name()='tenuto'">
            <xsl:attribute name="artic">ten</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
        <xsl:call-template name="positionRelative"/>
        <xsl:call-template name="fontProperties"/>
        <xsl:call-template name="color"/>
      </artic>
    </xsl:for-each>
    <xsl:for-each select="notations/technical/*[not(local-name()='arrow' or
      local-name()='bend' or local-name()='fingering' or local-name()='fret' or
      local-name()='hammer-on' or local-name()='handbell' or local-name()='hole' or
      local-name()='other-technical' or local-name()='pluck' or local-name()='pull-off' or
      local-name()='string' or local-name()='tap' or local-name()='thumb-position' or
      local-name()='scoop')]">
      <!-- String and fret indications are handled elsewhere as note attributes. Fingering,
        pluck, hammer-on, pull-off and tap indications are treated elsewhere as directives. 
        The remaining elements above are not currently transcoded. -->
      <artic xmlns="http://www.music-encoding.org/ns/mei">
        <xsl:choose>
          <xsl:when test="local-name()='double-tongue'">
            <xsl:attribute name="artic">dbltongue</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="local-name()='down-bow'">
            <xsl:attribute name="artic">dnbow</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="local-name()='fingernails'">
            <xsl:attribute name="artic">fingernail</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="local-name()='harmonic'">
            <xsl:attribute name="artic">harm</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="local-name()='heel'">
            <xsl:attribute name="artic">heel</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="local-name()='open-string'">
            <xsl:attribute name="artic">open</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="local-name()='snap-pizzicato'">
            <xsl:attribute name="artic">snap</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="local-name()='stopped'">
            <xsl:attribute name="artic">stop</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <!-- Because it can contain text, tap is converted to a directive -->
          <xsl:when test="local-name()='toe'">
            <xsl:attribute name="artic">toe</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="local-name()='triple-tongue'">
            <xsl:attribute name="artic">trpltongue</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
          <xsl:when test="local-name()='up-bow'">
            <xsl:attribute name="artic">upbow</xsl:attribute>
            <xsl:if test="@placement != ''">
              <xsl:attribute name="place">
                <xsl:value-of select="@placement"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
        <xsl:call-template name="positionRelative"/>
        <xsl:call-template name="fontProperties"/>
        <xsl:call-template name="color"/>
      </artic>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="assignPart-Layer-Staff-Beam-Tuplet">
    <!-- Creates part, layer, staff, beam, and tuplet attributes -->
    <xsl:variable name="partID">
      <xsl:value-of select="ancestor::part[1]/@id"/>
    </xsl:variable>

    <!-- Part assignment -->
    <xsl:attribute name="part">
      <xsl:value-of select="$partID"/>
    </xsl:attribute>

    <!-- Staff assignment -->
    <xsl:variable name="partStaff">
      <xsl:choose>
        <xsl:when test="staff">
          <xsl:value-of select="staff"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="staff">
      <xsl:call-template name="getStaffNum">
        <xsl:with-param name="partID">
          <xsl:value-of select="$partID"/>
        </xsl:with-param>
        <xsl:with-param name="partStaff">
          <xsl:value-of select="$partStaff"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:attribute>

    <!-- Layer (voice) assignment -->
    <!-- This is a voice within a part, not a layer on a staff as in MEI. -->
    <xsl:variable name="thisVoice">
      <xsl:choose>
        <xsl:when test="voice">
          <xsl:value-of select="voice"/>
        </xsl:when>
        <xsl:otherwise>1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:attribute name="layer">
      <xsl:value-of select="$thisVoice"/>
    </xsl:attribute>

    <!-- Beam assignment -->
    <!-- MEI only records the start, continuation, and end of the primary beam -->
    <xsl:choose>
      <xsl:when test="beam[@number='1']='begin'">
        <xsl:variable name="beamLevel">
          <xsl:value-of select="max(((count(preceding-sibling::*[beam[@number='1']='begin' and
            voice=$thisVoice]) + 1) - count(preceding-sibling::*[beam[@number='1']='end' and
            voice=$thisVoice]), 1))"/>
        </xsl:variable>
        <xsl:attribute name="beam">
          <xsl:text>i</xsl:text>
          <xsl:value-of select="$beamLevel"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="beam[@number ='1']='continue'">
        <xsl:variable name="beamLevel">
          <xsl:value-of select="max((count(preceding-sibling::*[beam[@number='1']='begin' and
            voice=$thisVoice]) - count(preceding-sibling::*[beam[@number='1']='end' and
            voice=$thisVoice]), 1))"/>
        </xsl:variable>
        <xsl:attribute name="beam">
          <xsl:text>m</xsl:text>
          <xsl:value-of select="$beamLevel"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="beam[@number='1']='end'">
        <xsl:variable name="beamLevel">
          <xsl:value-of select="max((count(preceding-sibling::*[beam[@number='1']='begin' and
            voice=$thisVoice]) - count(preceding-sibling::*[beam[@number='1']='end' and
            voice=$thisVoice]), 1))"/>
        </xsl:variable>
        <xsl:attribute name="beam">
          <xsl:text>t</xsl:text>
          <xsl:value-of select="$beamLevel"/>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="rest and (preceding-sibling::*[beam][1]/beam='begin' or
        preceding-sibling::*[beam][1]/beam='continue') and
        (following-sibling::*[beam][1]/beam='end' or following-sibling::*[beam][1]/beam='continue')">
        <!-- In MusicXML rests under a beam do not have a 'continue' beam element so this data has to be supplied. -->
        <xsl:if test="preceding-sibling::*[beam][1]/voice=$thisVoice and
          following-sibling::*[beam][1]/voice=$thisVoice">
          <xsl:variable name="beamLevel">
            <xsl:value-of select="max((count(preceding-sibling::*[beam[@number='1']='begin' and
              voice=$thisVoice]) - count(preceding-sibling::*[beam[@number='1']='end' and
              voice=$thisVoice]), 1))"/>
          </xsl:variable>
          <xsl:attribute name="beam">
            <xsl:text>m</xsl:text>
            <xsl:value-of select="$beamLevel"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:when>
    </xsl:choose>

    <!-- Tuplet attribute -->
    <xsl:choose>
      <xsl:when test="notations/tuplet">
        <xsl:attribute name="tuplet">
          <xsl:choose>
            <!-- this note is marked as start of tuplet -->
            <xsl:when test="notations/tuplet[@type='start']">
              <xsl:text>i</xsl:text>
            </xsl:when>
            <!-- this note is marked as end of tuplet -->
            <xsl:when test="notations/tuplet[@type='stop']">
              <xsl:text>t</xsl:text>
            </xsl:when>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="preceding::note[notations/tuplet][1]/notations/tuplet/@number">
              <xsl:value-of select="preceding::note[notations/tuplet][1]/notations/tuplet/@number"/>
            </xsl:when>
            <xsl:otherwise>1</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="time-modification">
        <xsl:variable name="thisVoice">
          <xsl:value-of select="voice"/>
        </xsl:variable>
        <xsl:attribute name="tuplet">
          <xsl:choose>
            <!-- when explicit start and stop siblings it's a middle note -->
            <xsl:when
              test="preceding-sibling::note[voice=$thisVoice]/notations/tuplet[@type='start'] and
              following-sibling::note[voice=$thisVoice]/notations/tuplet[@type='stop']">
              <xsl:text>m</xsl:text>
              <xsl:choose>
                <xsl:when test="preceding::note[voice=$thisVoice and
                  notations/tuplet][1]/notations/tuplet/@number">
                  <xsl:value-of select="preceding::note[voice=$thisVoice and
                    notations/tuplet][1]/notations/tuplet/@number"/>
                </xsl:when>
                <xsl:otherwise>1</xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <!-- when implied start and stop siblings and next note is also modified, it's a middle note -->
            <xsl:when test="preceding-sibling::note[1][voice=$thisVoice]/time-modification and
              following-sibling::note[1][voice=$thisVoice]/time-modification">
              <xsl:text>m1</xsl:text>
            </xsl:when>
            <!-- no explicit or implied start sibling, it's an initial note -->
            <xsl:when
              test="not(preceding-sibling::note[1][voice=$thisVoice]/notations/tuplet[@type='start'])
              and not(preceding-sibling::note[1][voice=$thisVoice]/time-modification)">
              <xsl:text>i1</xsl:text>
            </xsl:when>
            <!-- no explicit or implied stop sibling, it's a terminal note -->
            <xsl:when
              test="not(following-sibling::note[1][voice=$thisVoice]/notations/tuplet[@type='stop'])
              and not(following-sibling::note[1][voice=$thisVoice]/time-modification)">
              <xsl:text>t1</xsl:text>
            </xsl:when>
          </xsl:choose>
        </xsl:attribute>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="color">
    <xsl:choose>
      <xsl:when test="matches(normalize-space(@color), '(#[0-9A-Fa-f]{8,8})')">
        <!-- convert MusicXML CSS4 color value to CSS3 rgba value -->
        <xsl:attribute name="color">
          <xsl:call-template name="aarrggbb2css">
            <xsl:with-param name="aarrggbb">
              <xsl:value-of select="@color"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:attribute>
      </xsl:when>
      <xsl:when test="matches(normalize-space(@color),
        '^#[0-9A-Fa-f]{6,6}$|^aqua$|^black$|^blue$|^fuchsia$|^gray$|^green$|^lime$|^maroon$|^navy$|^olive$|^purple$|^red$|^silver$|^teal$|^white$|^yellow')">
        <!-- pass through hex and named color values -->
        <xsl:attribute name="color">
          <xsl:value-of select="normalize-space(@color)"/>
        </xsl:attribute>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="credits">
    <!-- Process MusicXML credit elements -->
    <xsl:variable name="pageHeight">
      <xsl:value-of select="defaults/page-layout/page-height"/>
    </xsl:variable>
    <xsl:variable name="credits">
      <xsl:if test="credit[number(@page)=1]/credit-words[@default-y &gt; ($pageHeight div 2)]">
        <pgHead xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:for-each select="credit[number(@page)=1]/credit-words[@default-y &gt; ($pageHeight
            div 2)]">
            <xsl:apply-templates select="."/>
          </xsl:for-each>
        </pgHead>
      </xsl:if>
      <xsl:if test="credit[number(@page)=1]/credit-words[@default-y &lt; ($pageHeight div 2)]">
        <pgFoot xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:for-each select="credit[number(@page)=1]/credit-words[@default-y &lt; ($pageHeight
            div 2)]">
            <xsl:apply-templates select="."/>
          </xsl:for-each>
        </pgFoot>
      </xsl:if>
      <xsl:if test="credit[number(@page)=2]/credit-words[@default-y &gt; ($pageHeight div 2)]">
        <pgHead2 xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:for-each select="credit[number(@page)=2]/credit-words[@default-y &gt; ($pageHeight
            div 2)]">
            <xsl:apply-templates select="."/>
          </xsl:for-each>
        </pgHead2>
      </xsl:if>
      <xsl:if test="credit[number(@page)=2]/credit-words[@default-y &lt; ($pageHeight div 2)]">
        <pgFoot2 xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:for-each select="credit[number(@page)=2]/credit-words[@default-y &lt; ($pageHeight
            div 2)]">
            <xsl:apply-templates select="."/>
          </xsl:for-each>
        </pgFoot2>
      </xsl:if>
    </xsl:variable>
    <xsl:copy-of select="$credits/mei:pgHead"/>
    <xsl:copy-of select="$credits/mei:pgHead2"/>
    <xsl:copy-of select="$credits/mei:pgFoot"/>
    <xsl:copy-of select="$credits/mei:pgFoot2"/>
  </xsl:template>

  <xsl:template name="fermata">
    <!-- Create fermata attribute -->
    <xsl:for-each select="notations/fermata[1]">
      <xsl:attribute name="fermata">
        <xsl:choose>
          <xsl:when test="@type='upright'">above</xsl:when>
          <xsl:when test="@type='inverted'">below</xsl:when>
          <xsl:otherwise>above</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="figure">
    <xsl:if test="prefix">
      <xsl:analyze-string select="prefix"
        regex="(flat|flat-flat|sharp|sharp-sharp|double-sharp|natural|slash)">
        <xsl:matching-substring>
          <xsl:choose>
            <xsl:when test="matches(., 'sharp-sharp')">
              <xsl:text>&#x266F;&#x266F;</xsl:text>
              <xsl:comment>[sharp-sharp]</xsl:comment>
            </xsl:when>
            <xsl:when test="matches(., 'flat-flat')">
              <xsl:text>&#x1D12B;</xsl:text>
              <xsl:comment>[flat-flat]</xsl:comment>
            </xsl:when>
            <xsl:when test="matches(., 'double-sharp')">
              <xsl:text>&#x1D12A;</xsl:text>
              <xsl:comment>[double sharp]</xsl:comment>
            </xsl:when>
            <xsl:when test="matches(., 'sharp')">
              <xsl:text>&#x266F;</xsl:text>
              <xsl:comment>[sharp]</xsl:comment>
            </xsl:when>
            <xsl:when test="matches(., 'flat')">
              <xsl:text>&#x266D;</xsl:text>
              <xsl:comment>[flat]</xsl:comment>
            </xsl:when>
            <xsl:when test="matches(., 'natural')">
              <xsl:text>&#x266E;</xsl:text>
              <xsl:comment>[natural]</xsl:comment>
            </xsl:when>
            <xsl:when test="matches(., 'slash')">
              <xsl:text>/</xsl:text>
            </xsl:when>
          </xsl:choose>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:value-of select="."/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:if>
    <xsl:value-of select="figure-number"/>
    <xsl:if test="suffix">
      <xsl:analyze-string select="suffix"
        regex="(flat|flat-flat|sharp|sharp-sharp|double-sharp|natural|slash)">
        <xsl:matching-substring>
          <xsl:choose>
            <xsl:when test="matches(., 'sharp-sharp')">
              <xsl:text>&#x266F;&#x266F;</xsl:text>
              <xsl:comment>[sharp-sharp]</xsl:comment>
            </xsl:when>
            <xsl:when test="matches(., 'flat-flat')">
              <xsl:text>&#x1D12B;</xsl:text>
              <xsl:comment>[flat-flat]</xsl:comment>
            </xsl:when>
            <xsl:when test="matches(., 'double-sharp')">
              <xsl:text>&#x1D12A;</xsl:text>
              <xsl:comment>[double sharp]</xsl:comment>
            </xsl:when>
            <xsl:when test="matches(., 'sharp')">
              <xsl:text>&#x266F;</xsl:text>
              <xsl:comment>[sharp]</xsl:comment>
            </xsl:when>
            <xsl:when test="matches(., 'flat')">
              <xsl:text>&#x266D;</xsl:text>
              <xsl:comment>[flat]</xsl:comment>
            </xsl:when>
            <xsl:when test="matches(., 'natural')">
              <xsl:text>&#x266E;</xsl:text>
              <xsl:comment>[natural]</xsl:comment>
            </xsl:when>
            <xsl:when test="matches(., 'slash')">
              <xsl:text>/</xsl:text>
            </xsl:when>
          </xsl:choose>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:value-of select="."/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:if>
  </xsl:template>

  <xsl:template name="fontProperties">
    <!-- Font name, size, style, and weight -->
    <xsl:if test="@font-family">
      <xsl:attribute name="fontfam">
        <xsl:value-of select="normalize-space(@font-family)"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@font-size">
      <xsl:attribute name="fontsize">
        <xsl:value-of select="@font-size"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@font-style">
      <xsl:attribute name="fontstyle">
        <xsl:choose>
          <xsl:when test="contains(@font-style, 'ital')">
            <xsl:text>italic</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@font-style"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@font-weight ">
      <xsl:attribute name="fontweight">
        <xsl:value-of select="@font-weight"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="gesturalDuration">
    <!-- Create attribute for gestural duration -->
    <xsl:attribute name="dur.ges">
      <xsl:choose>
        <xsl:when test="grace">
          <xsl:text>0</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="duration"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>p</xsl:text>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="getStaffNum">
    <!-- Assign a staff number from $defaultLayout -->
    <xsl:param name="partID">P1</xsl:param>
    <xsl:param name="partStaff">1</xsl:param>
    <xsl:choose>
      <xsl:when test="local-name($defaultLayout//*[@xml:id=$partID])='staffDef'">
        <xsl:value-of select="$defaultLayout//*[@xml:id=$partID]/@n"/>
      </xsl:when>
      <xsl:when test="local-name($defaultLayout//*[@xml:id=$partID])='staffGrp'">
        <xsl:value-of
          select="$defaultLayout//*[@xml:id=$partID]//mei:staffDef[position()=$partStaff]/@n"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="getTimestamp.ges">
    <!-- Assign a gestural timestamp. -->
    <xsl:variable name="durSum">
      <xsl:choose>
        <xsl:when test="local-name(.)='clef'">
          <xsl:variable name="durSumTemp">
            <xsl:value-of select="sum(../preceding-sibling::note[not(chord)]/duration) +
              sum(../preceding-sibling::forward/duration) -
              sum(../preceding-sibling::backup/duration)"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$durSumTemp &lt; 0">0</xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$durSumTemp"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="durSumTemp">
            <xsl:value-of select="sum(preceding-sibling::note[not(chord)]/duration) +
              sum(preceding-sibling::forward/duration) - sum(preceding-sibling::backup/duration)"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$durSumTemp &lt; 0">0</xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$durSumTemp"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="./chord or (local-name(.)='direction' and
        following-sibling::*[1][local-name()='note' and chord])">
        <xsl:value-of select="format-number($durSum -
          preceding-sibling::note[not(chord)][1]/duration, '###0.####')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="format-number($durSum, '###0.####')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="greatestCommonDenominator">
    <!-- Calculate greatest common denominator -->
    <xsl:param name="a"/>
    <xsl:param name="b"/>
    <xsl:variable name="min">
      <xsl:value-of select="min(($a, $b))"/>
    </xsl:variable>
    <xsl:variable name="max">
      <xsl:value-of select="max(($a, $b))"/>
    </xsl:variable>
    <xsl:variable name="x">
      <xsl:value-of select="$max - $min"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$x = 0">
        <xsl:value-of select="$min"/>
      </xsl:when>
      <xsl:when test="$x = $min">
        <xsl:value-of select="$x"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="greatestCommonDenominator">
          <xsl:with-param name="a">
            <xsl:value-of select="$min"/>
          </xsl:with-param>
          <xsl:with-param name="b">
            <xsl:value-of select="$x"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="harmLabel">
    <xsl:value-of select="normalize-space(root/root-step)"/>
    <xsl:choose>
      <xsl:when test="root/root-alter = 2">
        <xsl:text>&#x1D12A;</xsl:text>
      </xsl:when>
      <xsl:when test="root/root-alter = 1">
        <xsl:text>&#x266F;</xsl:text>
      </xsl:when>
      <xsl:when test="root/root-alter = -1">
        <xsl:text>&#x266D;</xsl:text>
      </xsl:when>
      <xsl:when test="root/root-alter = -2">
        <xsl:text>&#x1D12B;</xsl:text>
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="kind/@text">
        <xsl:value-of select="kind/@text"/>
      </xsl:when>
      <xsl:when test="kind">
        <xsl:choose>
          <xsl:when test="kind='minor'">
            <xsl:text>m</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmLabelQuality"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'augmented'">
            <xsl:text>aug</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmLabelQuality"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'diminished'">
            <xsl:text>dim</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmLabelQuality"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'dominant'">
            <xsl:text>7</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmLabelQuality"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'major-seventh'">
            <xsl:text>maj7</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmLabelQuality"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'minor-seventh'">
            <xsl:text>m7</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmLabelQuality"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'diminished-seventh'">
            <xsl:text>dim7</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmLabelQuality"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'augmented-seventh'">
            <xsl:text>aug7</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmLabelQuality"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'half-diminished'">
            <xsl:text>dim(m7</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:call-template name="harmLabelQuality"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'major-minor'">
            <xsl:text>m(maj7</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:call-template name="harmLabelQuality"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'major-sixth'">
            <xsl:text>6</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmLabelQuality"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'minor-sixth'">
            <xsl:text>m6</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmLabelQuality"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'dominant-ninth'">
            <xsl:text>9</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmLabelQuality"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'major-ninth'">
            <xsl:text>maj7(maj9</xsl:text>
            <xsl:call-template name="harmLabelQuality"/>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'minor-ninth'">
            <xsl:text>m(m9</xsl:text>
            <xsl:call-template name="harmLabelQuality"/>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'dominant-11th'">
            <xsl:text>11</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmLabelQuality"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'major-11th'">
            <xsl:text>maj9(add11</xsl:text>
            <xsl:text>(</xsl:text>
            <xsl:call-template name="harmLabelQuality"/>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'minor-11th'">
            <xsl:text>m9(add11</xsl:text>
            <xsl:call-template name="harmLabelQuality"/>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'dominant-13th'">
            <xsl:text>13</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmLabelQuality"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'major-13th'">
            <xsl:text>maj11(add13</xsl:text>
            <xsl:call-template name="harmLabelQuality"/>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'minor-13th'">
            <xsl:text>m11(add13</xsl:text>
            <xsl:call-template name="harmLabelQuality"/>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'suspended-second'">
            <xsl:text>sus2</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmLabelQuality"/>
            </xsl:if>
          </xsl:when>
          <xsl:when test="normalize-space(kind) = 'suspended-fourth'">
            <xsl:text>sus4</xsl:text>
            <xsl:if test="degree/degree-alter">
              <xsl:text>(</xsl:text>
              <xsl:call-template name="harmLabelQuality"/>
            </xsl:if>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="bass">
      <xsl:text>/</xsl:text>
      <xsl:value-of select="normalize-space(bass/bass-step)"/>
      <xsl:choose>
        <xsl:when test="bass/bass-alter = 2">
          <xsl:text>&#x1D12A;</xsl:text>
        </xsl:when>
        <xsl:when test="bass/bass-alter = 1">
          <xsl:text>&#x266F;</xsl:text>
        </xsl:when>
        <xsl:when test="bass/bass-alter = -1">
          <xsl:text>&#x266D;</xsl:text>
        </xsl:when>
        <xsl:when test="bass/bass-alter = -2">
          <xsl:text>&#x1D12B;</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="harmLabelQuality">
    <xsl:for-each select="degree[degree-alter]">
      <xsl:choose>
        <xsl:when test="degree-alter = 2">
          <xsl:text>&#x1D12A;</xsl:text>
        </xsl:when>
        <xsl:when test="degree-alter = 1">
          <xsl:text>&#x266F;</xsl:text>
        </xsl:when>
        <xsl:when test="degree-alter = -1">
          <xsl:text>&#x266D;</xsl:text>
        </xsl:when>
        <xsl:when test="degree-alter = -2">
          <xsl:text>&#x1D12B;</xsl:text>
        </xsl:when>
      </xsl:choose>
      <xsl:value-of select="degree-value"/>
    </xsl:for-each>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template name="leastCommonMultiple">
    <!-- Calculate least common multiple -->
    <xsl:param name="in"/>
    <xsl:choose>
      <xsl:when test="count($in//divisions) &gt; 2">
        <xsl:variable name="out">
          <xsl:for-each select="$in//divisions[position() &lt; last()]">
            <xsl:variable name="a">
              <xsl:value-of select="."/>
            </xsl:variable>
            <xsl:variable name="b">
              <xsl:value-of select="following-sibling::divisions[1]"/>
            </xsl:variable>
            <xsl:variable name="y">
              <xsl:call-template name="greatestCommonDenominator">
                <xsl:with-param name="a">
                  <xsl:value-of select="$a"/>
                </xsl:with-param>
                <xsl:with-param name="b">
                  <xsl:value-of select="$b"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:variable>
            <divisions>
              <xsl:value-of select="($a * $b) div $y"/>
            </divisions>
          </xsl:for-each>
        </xsl:variable>
        <xsl:call-template name="leastCommonMultiple">
          <xsl:with-param name="in">
            <xsl:copy-of select="$out"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="a">
          <xsl:value-of select="$in//divisions[1]"/>
        </xsl:variable>
        <xsl:variable name="b">
          <xsl:value-of select="$in//divisions[2]"/>
        </xsl:variable>
        <xsl:variable name="y">
          <xsl:call-template name="greatestCommonDenominator">
            <xsl:with-param name="a">
              <xsl:value-of select="$a"/>
            </xsl:with-param>
            <xsl:with-param name="b">
              <xsl:value-of select="$b"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="($a * $b) div $y"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="makeStaff">
    <!-- Create the desired number of staves for a part. -->
    <xsl:param name="partID"/>
    <xsl:param name="needed">1</xsl:param>
    <xsl:param name="made">0</xsl:param>
    <xsl:if test="$made &lt; $needed">
      <staffDef xmlns="http://www.music-encoding.org/ns/mei">
        <xsl:call-template name="staffInitialAttributes">
          <xsl:with-param name="partID">
            <xsl:value-of select="$partID"/>
          </xsl:with-param>
          <xsl:with-param name="staffNum">
            <xsl:value-of select="string($made + 1)"/>
          </xsl:with-param>
        </xsl:call-template>
      </staffDef>
      <xsl:call-template name="makeStaff">
        <xsl:with-param name="partID">
          <xsl:value-of select="$partID"/>
        </xsl:with-param>
        <xsl:with-param name="needed">
          <xsl:value-of select="$needed"/>
        </xsl:with-param>
        <xsl:with-param name="made">
          <xsl:value-of select="$made + 1"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="measureDuration">
    <!-- Calculate duration of a measure in ppq units -->
    <xsl:param name="meterCount"/>
    <xsl:param name="meterUnit"/>
    <xsl:param name="ppq"/>
    <!--DEBUG:-->
    <!--<xsl:variable name="errorMessage">
      <xsl:text>m. </xsl:text>
      <xsl:value-of select="ancestor::measure/@number"/>
      <xsl:text>, part </xsl:text>
      <xsl:value-of select="ancestor::part/@id"/>
      <xsl:text>: meterCount=</xsl:text>
      <xsl:value-of select="$meterCount"/>
      <xsl:text>, meterUnit=</xsl:text>
      <xsl:value-of select="$meterUnit"/>
      <xsl:text>, ppq=</xsl:text>
      <xsl:value-of select="$ppq"/>
    </xsl:variable>
    <xsl:message>
      <xsl:value-of select="$errorMessage"/>
    </xsl:message>-->
    <xsl:choose>
      <xsl:when test="$meterUnit = 1">
        <xsl:value-of select="($meterCount * 4) * $ppq"/>
      </xsl:when>
      <xsl:when test="$meterUnit = 2">
        <xsl:value-of select="($meterCount * $meterUnit) * $ppq"/>
      </xsl:when>
      <xsl:when test="$meterUnit = 4">
        <xsl:value-of select="$meterCount * $ppq"/>
      </xsl:when>
      <xsl:when test="$meterUnit &gt; 4">
        <xsl:value-of select="($meterCount div ($meterUnit div 4)) * $ppq"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="notatedDot">
    <!-- Notated dotted attribute -->
    <xsl:if test="dot">
      <xsl:attribute name="dots">
        <xsl:value-of select="count(dot)"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="notatedDuration">
    <!-- Notated duration derived from type element -->
    <xsl:choose>
      <xsl:when test="normalize-space(.) = 'long'">
        <xsl:text>long</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space(.) = 'breve'">
        <xsl:text>breve</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space(.) = 'whole'">
        <xsl:text>1</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space(.) = 'half'">
        <xsl:text>2</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space(.) = 'quarter'">
        <xsl:text>4</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space(.) = 'eighth'">
        <xsl:text>8</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:analyze-string select="normalize-space(.)" regex="^([0-9]+)(.*)$">
          <xsl:matching-substring>
            <xsl:value-of select="regex-group(1)"/>
          </xsl:matching-substring>
        </xsl:analyze-string>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="notatedDurationUnicode">
    <!-- Notated duration as Unicode character, derived from type element -->
    <xsl:choose>
      <xsl:when test="normalize-space(.) = 'long'">
        <xsl:text>&#x1D1B7;</xsl:text>
        <xsl:comment>[long]</xsl:comment>
      </xsl:when>
      <xsl:when test="normalize-space(.) = 'breve'">
        <xsl:text>&#x1D15C;</xsl:text>
        <xsl:comment>[breve]</xsl:comment>
      </xsl:when>
      <xsl:when test="normalize-space(.) = 'whole'">
        <xsl:text>&#x1D15D;</xsl:text>
        <xsl:comment>[whole]</xsl:comment>
      </xsl:when>
      <xsl:when test="normalize-space(.) = 'half'">
        <xsl:text>&#x1D15E;</xsl:text>
        <xsl:comment>[half]</xsl:comment>
      </xsl:when>
      <xsl:when test="normalize-space(.) = 'quarter'">
        <xsl:text>&#x1D15F;</xsl:text>
        <xsl:comment>[quarter]</xsl:comment>
      </xsl:when>
      <xsl:when test="normalize-space(.) = 'eighth'">
        <xsl:text>&#x1D160;</xsl:text>
        <xsl:comment>[8th]</xsl:comment>
      </xsl:when>
      <xsl:when test="normalize-space(.) = '16'">
        <xsl:text>&#x1D161;</xsl:text>
        <xsl:comment>[16th]</xsl:comment>
      </xsl:when>
      <xsl:when test="normalize-space(.) = '32'">
        <xsl:text>&#x1D162;</xsl:text>
        <xsl:comment>[32nd]</xsl:comment>
      </xsl:when>
      <xsl:when test="normalize-space(.) = '64'">
        <xsl:text>&#x1D163;</xsl:text>
        <xsl:comment>[64th]</xsl:comment>
      </xsl:when>
      <xsl:when test="normalize-space(.) = '128'">
        <xsl:text>&#x1D164;</xsl:text>
        <xsl:comment>[128th]</xsl:comment>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="quantizedDuration">
    <!-- Calculate quantized value (in ppq units) -->
    <xsl:param name="ppq"/>
    <xsl:param name="duration"/>
    <!-- Build lookup table -->
    <!-- undotted values -->
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
    <xsl:variable name="clicks2048">
      <xsl:value-of select="$clicks4 div 512"/>
    </xsl:variable>

    <!-- dotted values -->
    <xsl:variable name="clicks1dot">
      <xsl:value-of select="$clicks1 + ($clicks1 div 2)"/>
    </xsl:variable>
    <xsl:variable name="clicks2dot">
      <xsl:value-of select="$clicks2 +( $clicks2 div 2)"/>
    </xsl:variable>
    <xsl:variable name="clicks4dot">
      <xsl:value-of select="$clicks4 + ($clicks4 div 2)"/>
    </xsl:variable>
    <xsl:variable name="clicks8dot">
      <xsl:value-of select="$clicks8 + ($clicks8 div 2)"/>
    </xsl:variable>
    <xsl:variable name="clicks16dot">
      <xsl:value-of select="$clicks16 + ($clicks16 div 2)"/>
    </xsl:variable>
    <xsl:variable name="clicks32dot">
      <xsl:value-of select="$clicks32 + ($clicks32 div 2)"/>
    </xsl:variable>
    <xsl:variable name="clicks64dot">
      <xsl:value-of select="$clicks64 + ($clicks64 div 2)"/>
    </xsl:variable>
    <xsl:variable name="clicks128dot">
      <xsl:value-of select="$clicks128 + ($clicks128 div 2)"/>
    </xsl:variable>
    <xsl:variable name="clicks256dot">
      <xsl:value-of select="$clicks256 + ($clicks256 div 2)"/>
    </xsl:variable>
    <xsl:variable name="clicks512dot">
      <xsl:value-of select="$clicks512 + ($clicks512 div 2)"/>
    </xsl:variable>
    <xsl:variable name="clicks1024dot">
      <xsl:value-of select="$clicks1024 + ($clicks1024 div 2)"/>
    </xsl:variable>
    <xsl:variable name="clicks2048dot">
      <xsl:value-of select="$clicks2048 + ($clicks2048 div 2)"/>
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
      <xsl:value-of select="$clicks128 + ($clicks128 div 2) + ($clicks128 div 4)"/>
    </xsl:variable>
    <xsl:variable name="clicks256dot2">
      <xsl:value-of select="$clicks256 + ($clicks256 div 2) + ($clicks256 div 4)"/>
    </xsl:variable>
    <xsl:variable name="clicks512dot2">
      <xsl:value-of select="$clicks512 + ($clicks512 div 2) + ($clicks512 div 4)"/>
    </xsl:variable>
    <xsl:variable name="clicks1024dot2">
      <xsl:value-of select="$clicks1024 + ($clicks1024 div 2) + ($clicks1024 div 4)"/>
    </xsl:variable>
    <xsl:variable name="clicks2048dot2">
      <xsl:value-of select="$clicks2048 + ($clicks2048 div 2) + ($clicks2048 div 4)"/>
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

    <!-- Evaluate $duration against the lookup table -->
    <xsl:choose>
      <!-- Undotted note values -->
      <xsl:when test="$duration = $clicks1">1</xsl:when>
      <xsl:when test="$duration = $clicks2">2</xsl:when>
      <xsl:when test="$duration = $clicks4">4</xsl:when>
      <xsl:when test="$duration = $clicks8">8</xsl:when>
      <xsl:when test="$duration = $clicks16">16</xsl:when>
      <xsl:when test="$duration = $clicks32">32</xsl:when>
      <xsl:when test="$duration = $clicks64">64</xsl:when>
      <xsl:when test="$duration = $clicks128">128</xsl:when>
      <xsl:when test="$duration = $clicks256">256</xsl:when>
      <xsl:when test="$duration = $clicks512">512</xsl:when>
      <xsl:when test="$duration = $clicks1024">1024</xsl:when>
      <xsl:when test="$duration = $clicks2048">2048</xsl:when>

      <!-- Dotted note values -->
      <xsl:when test="$duration = $clicks1dot">1.</xsl:when>
      <xsl:when test="$duration = $clicks2dot">2.</xsl:when>
      <xsl:when test="$duration = $clicks4dot">4.</xsl:when>
      <xsl:when test="$duration = $clicks8dot">8.</xsl:when>
      <xsl:when test="$duration = $clicks16dot">16.</xsl:when>
      <xsl:when test="$duration = $clicks32dot">32.</xsl:when>
      <xsl:when test="$duration = $clicks64dot">64.</xsl:when>
      <xsl:when test="$duration = $clicks128dot">128.</xsl:when>
      <xsl:when test="$duration = $clicks256dot">256.</xsl:when>
      <xsl:when test="$duration = $clicks512dot">512.</xsl:when>
      <xsl:when test="$duration = $clicks1024dot">1024.</xsl:when>
      <xsl:when test="$duration = $clicks2048dot">2048.</xsl:when>

      <!-- Double dotted note values -->
      <xsl:when test="$duration = $clicks1dot2">1..</xsl:when>
      <xsl:when test="$duration = $clicks2dot2">2..</xsl:when>
      <xsl:when test="$duration = $clicks4dot2">4..</xsl:when>
      <xsl:when test="$duration = $clicks8dot2">8..</xsl:when>
      <xsl:when test="$duration = $clicks16dot2">16..</xsl:when>
      <xsl:when test="$duration = $clicks32dot2">32..</xsl:when>
      <xsl:when test="$duration = $clicks64dot2">64..</xsl:when>
      <xsl:when test="$duration = $clicks128dot2">128..</xsl:when>
      <xsl:when test="$duration = $clicks256dot2">256..</xsl:when>
      <xsl:when test="$duration = $clicks512dot2">512..</xsl:when>
      <xsl:when test="$duration = $clicks1024dot2">1024..</xsl:when>
      <xsl:when test="$duration = $clicks2048dot2">2048..</xsl:when>

      <!-- Quantize triplets to next smaller undotted value -->
      <xsl:when test="$duration = $clicks3">
        <xsl:value-of select="$clicks2"/>
      </xsl:when>
      <xsl:when test="$duration = $clicks6">
        <xsl:value-of select="$clicks4"/>
      </xsl:when>
      <xsl:when test="$duration = $clicks12">
        <xsl:value-of select="$clicks8"/>
      </xsl:when>
      <xsl:when test="$duration = $clicks24">
        <xsl:value-of select="$clicks16"/>
      </xsl:when>
      <xsl:when test="$duration = $clicks48">
        <xsl:value-of select="$clicks32"/>
      </xsl:when>
      <xsl:when test="$duration = $clicks96">
        <xsl:value-of select="$clicks64"/>
      </xsl:when>
      <xsl:when test="$duration = $clicks192">
        <xsl:value-of select="$clicks128"/>
      </xsl:when>
      <xsl:when test="$duration = $clicks384">
        <xsl:value-of select="$clicks256"/>
      </xsl:when>
      <xsl:when test="$duration = $clicks768">
        <xsl:value-of select="$clicks512"/>
      </xsl:when>

      <!-- If nothing else has matched so far, quantize to the next smaller undotted value. -->
      <xsl:when test="$duration > number($clicks1)">1</xsl:when>
      <xsl:when test="$duration > number($clicks2) and $duration &lt; number($clicks1)">2</xsl:when>
      <xsl:when test="$duration > number($clicks4) and $duration &lt; number($clicks2)">4</xsl:when>
      <xsl:when test="$duration > number($clicks8) and $duration &lt; number($clicks4)">8</xsl:when>
      <xsl:when test="$duration > number($clicks16) and $duration &lt; number($clicks8)"
        >16</xsl:when>
      <xsl:when test="$duration > number($clicks32) and $duration &lt; number($clicks16)"
        >32</xsl:when>
      <xsl:when test="$duration > number($clicks64) and $duration &lt; number($clicks32)"
        >64</xsl:when>
      <xsl:when test="$duration > number($clicks128) and $duration &lt; number($clicks64)"
        >128</xsl:when>
      <xsl:when test="$duration > number($clicks256) and $duration &lt; number($clicks128)"
        >256</xsl:when>
      <xsl:when test="$duration > number($clicks512) and $duration &lt; number($clicks256)"
        >512</xsl:when>
      <xsl:when test="$duration > number($clicks1024) and $duration &lt; number($clicks512)"
        >256</xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="positionRelative">
    <!-- Create positional attributes -->
    <xsl:if test="@relative-x">
      <xsl:attribute name="ho">
        <xsl:value-of select="format-number(@relative-x div 5, '###0.####')"/>
        <!-- <xsl:text>vu</xsl:text> -->
      </xsl:attribute>
    </xsl:if>
    <!--<xsl:if test="@default-x and not(@relative-x)">
      <xsl:attribute name="ho">
        <xsl:value-of select="format-number(@default-x div 5, '###0.####')"/>
      </xsl:attribute>
    </xsl:if>-->
    <xsl:if test="@relative-y">
      <xsl:attribute name="vo">
        <xsl:value-of select="format-number(@relative-y div 5, '###0.####')"/>
        <!-- <xsl:text>vu</xsl:text> -->
      </xsl:attribute>
    </xsl:if>
    <!--<xsl:if test="@default-y and not(@relative-y)">
      <xsl:attribute name="vo">
        <xsl:value-of select="format-number(@default-y div 5, '###0.####')"/>
      </xsl:attribute>
    </xsl:if>-->
  </xsl:template>

  <xsl:template name="resolveGrpSym">
    <!-- Wrap staff definitions w/ staffGrp elements; called recursively as long as there 
      are grpSym elements in the tree fragment passed to it -->
    <xsl:param name="in"/>
    <xsl:param name="maxLevel"/>
    <xsl:param name="pass"/>
    <!--<xsl:message>pass = <xsl:value-of select="$pass"/></xsl:message>
    <xsl:message>in = <xsl:value-of select="$in"/></xsl:message>
    <xsl:message>maxLevel = <xsl:value-of select="$maxLevel"/></xsl:message>-->

    <xsl:variable name="newOuterStaffGrp">
      <staffGrp xmlns="http://www.music-encoding.org/ns/mei">
        <xsl:for-each select="$in/mei:staffGrp">
          <xsl:for-each select="mei:staffDef | mei:staffGrp">
            <xsl:choose>
              <xsl:when test="local-name()='staffDef'">
                <xsl:variable name="thisStaff">
                  <xsl:value-of select="number(@n)"/>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="following::grpSym[number(@level)=$pass and
                    number(@start)=$thisStaff]">
                    <xsl:variable name="start">
                      <xsl:value-of select="following::grpSym[number(@level)=$pass and
                        number(@start)=$thisStaff]/@start"/>
                    </xsl:variable>
                    <xsl:variable name="end">
                      <xsl:value-of select="following::grpSym[number(@level)=$pass and
                        number(@start)=$thisStaff]/@end"/>
                    </xsl:variable>
                    <staffGrp xmlns="http://www.music-encoding.org/ns/mei">
                      <xsl:copy-of select="following::grpSym[number(@level)=$pass and
                        number(@start)=$thisStaff]/@symbol"/>
                      <xsl:copy-of select="following::grpSym[number(@level)=$pass and
                        number(@start)=$thisStaff]/@barthru"/>
                      <xsl:copy-of select="following::grpSym[number(@level)=$pass and
                        number(@start)=$thisStaff]/@label"/>
                      <xsl:copy-of select="following::grpSym[number(@level)=$pass and
                        number(@start)=$thisStaff]/@label.abbr"/>
                      <xsl:copy-of select="following::grpSym[number(@level)=$pass and
                        number(@start)=$thisStaff]/mei:label"/>
                      <xsl:copy-of select="."/>
                      <xsl:copy-of select="following-sibling::mei:staffDef[number(@n) &lt;= $end] |
                        following-sibling::mei:staffGrp[mei:staffDef[number(@n) &lt;= $end]]"/>
                    </staffGrp>
                  </xsl:when>
                  <xsl:when test="following::grpSym[number(@level)=$pass and number(@start) &lt;=
                    $thisStaff and number(@end) &gt;=$thisStaff]">
                    <!-- This node is in the range defined by a grpSym for this pass and has already been copied -->
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:copy-of select="."/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="local-name()='staffGrp'">
                <xsl:variable name="thisStaff">
                  <xsl:value-of select="number(mei:staffDef[1]/@n)"/>
                </xsl:variable>
                <xsl:choose>
                  <xsl:when test="following::grpSym[number(@level)=$pass and
                    number(@start)=$thisStaff]">
                    <xsl:variable name="start">
                      <xsl:value-of select="following::grpSym[number(@level)=$pass and
                        number(@start)=$thisStaff]/@start"/>
                    </xsl:variable>
                    <xsl:variable name="end">
                      <xsl:value-of select="following::grpSym[number(@level)=$pass and
                        number(@start)=$thisStaff]/@end"/>
                    </xsl:variable>
                    <staffGrp xmlns="http://www.music-encoding.org/ns/mei">
                      <xsl:copy-of select="following::grpSym[number(@level)=$pass and
                        number(@start)=$thisStaff]/@symbol"/>
                      <xsl:copy-of select="following::grpSym[number(@level)=$pass and
                        number(@start)=$thisStaff]/@barthru"/>
                      <xsl:copy-of select="following::grpSym[number(@level)=$pass and
                        number(@start)=$thisStaff]/@label"/>
                      <xsl:copy-of select="following::grpSym[number(@level)=$pass and
                        number(@start)=$thisStaff]/@label.abbr"/>
                      <xsl:copy-of select="following::grpSym[number(@level)=$pass and
                        number(@start)=$thisStaff]/mei:label"/>
                      <xsl:copy-of select="."/>
                      <xsl:copy-of select="following-sibling::mei:staffDef[number(@n) &lt;= $end] |
                        following-sibling::mei:staffGrp[mei:staffDef[number(@n) &lt;= $end]]"/>
                    </staffGrp>
                  </xsl:when>
                  <xsl:when test="following::grpSym[number(@level)=$pass and number(@start) &lt;=
                    $thisStaff and number(@end) &gt;=$thisStaff]">
                    <!-- This node is in the range defined by a grpSym for this pass and has already been copied -->
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:copy-of select="."/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
            </xsl:choose>
          </xsl:for-each>
        </xsl:for-each>
        <xsl:for-each select="$in/mei:staffGrp/grpSym[@level != $pass]">
          <!-- Pass through any grpSym elements not processed in this pass -->
          <xsl:copy-of select="."/>
        </xsl:for-each>
      </staffGrp>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$pass &lt;= $maxLevel">
        <!-- Recurse -->
        <xsl:call-template name="resolveGrpSym">
          <xsl:with-param name="in">
            <xsl:copy-of select="$newOuterStaffGrp"/>
          </xsl:with-param>
          <xsl:with-param name="maxLevel">
            <xsl:value-of select="number($maxLevel)"/>
          </xsl:with-param>
          <xsl:with-param name="pass" select="number($pass + 1)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <!-- Remove redundant outer staffGrp element -->
        <!-- Emit the new outer staffGrp element -->
        <xsl:choose>
          <xsl:when test="count($newOuterStaffGrp/mei:staffGrp/*) = 1">
            <xsl:copy-of select="$newOuterStaffGrp/mei:staffGrp/mei:staffGrp"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="$newOuterStaffGrp"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="restvo">
    <!-- Record vertical offset of rest in terms of staff location -->
    <!-- Values in display-step and display-octave are copied to
      ploc and oloc attributes. -->
    <xsl:if test="rest/display-step">
      <xsl:attribute name="ploc">
        <xsl:value-of select="lower-case(rest/display-step)"/>
      </xsl:attribute>
      <xsl:attribute name="oloc">
        <xsl:value-of select="rest/display-octave"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="size">
    <!-- Notehead size -->
    <xsl:if test="cue or type/@size='cue'">
      <xsl:attribute name="size">cue</xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="staffInitialAttributes">
    <!-- Collect staff attributes from the first measure. -->
    <xsl:param name="partID"/>
    <xsl:param name="staffNum"/>
    <xsl:variable name="scoreFifths">
      <xsl:value-of select="following::part[attributes[not(preceding-sibling::note) and
        not(preceding-sibling::forward) and
        not(transpose)]/key/mode][1]/attributes[not(preceding-sibling::note) and
        not(preceding-sibling::forward) and not(transpose)]/key/fifths"/>
    </xsl:variable>
    <xsl:variable name="scoreMode">
      <xsl:value-of select="following::part[attributes[not(transpose) and
        key]][1]/attributes[not(transpose) and key]/key/mode"/>
    </xsl:variable>
    <xsl:for-each select="following::measure[1]/part[@id=$partID]/attributes">
      <xsl:choose>
        <xsl:when test="$staffNum=''">
          <!-- number of staff lines -->
          <xsl:attribute name="lines">
            <xsl:choose>
              <xsl:when test="staff-details/staff-lines">
                <xsl:choose>
                  <xsl:when test="staff-details[staff-lines][1]/staff-lines != ''">
                    <xsl:value-of select="staff-details[staff-lines][1]/staff-lines"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="5"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="5"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <!-- clef -->
          <xsl:choose>
            <xsl:when test="normalize-space(clef/sign) != ''">
              <xsl:for-each select="clef[1]">
                <xsl:choose>
                  <!-- percussion clef -->
                  <xsl:when test="sign='percussion'">
                    <xsl:attribute name="clef.shape">perc</xsl:attribute>
                  </xsl:when>
                  <!-- TAB "clef" -->
                  <xsl:when test="sign='TAB'">
                    <xsl:attribute name="clef.shape">TAB</xsl:attribute>
                  </xsl:when>
                  <!-- No clef provided -->
                  <xsl:when test="sign='none'">
                    <xsl:attribute name="clef.visible">false</xsl:attribute>
                  </xsl:when>
                  <!-- "normal" clef -->
                  <xsl:otherwise>
                    <xsl:attribute name="clef.line">
                      <xsl:value-of select="line"/>
                    </xsl:attribute>
                    <xsl:attribute name="clef.shape">
                      <xsl:value-of select="sign"/>
                    </xsl:attribute>
                    <xsl:if test="clef-octave-change">
                      <xsl:if test="abs(number(clef-octave-change)) != 0">
                        <xsl:attribute name="clef.dis">
                          <xsl:choose>
                            <xsl:when test="abs(number(clef-octave-change)) = 2">15</xsl:when>
                            <xsl:when test="abs(number(clef-octave-change)) = 1">8</xsl:when>
                          </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="clef.dis.place">
                          <xsl:choose>
                            <xsl:when test="number(clef-octave-change) &lt; 0">
                              <xsl:text>below</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:text>above</xsl:text>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:attribute>
                      </xsl:if>
                    </xsl:if>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="@print-object='no'">
                  <xsl:attribute name="clef.visible">false</xsl:attribute>
                </xsl:if>
              </xsl:for-each>
            </xsl:when>
            <!-- If no clef, then default to G on line 2 -->
            <xsl:otherwise>
              <xsl:attribute name="clef.line">2</xsl:attribute>
              <xsl:attribute name="clef.shape">G</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <!-- staff key signature-->
          <xsl:if test="key">
            <xsl:variable name="keySig">
              <xsl:value-of select="key/fifths"/>
            </xsl:variable>
            <xsl:if test="$keySig != $scoreFifths">
              <xsl:choose>
                <xsl:when test="$keySig=0">
                  <xsl:attribute name="key.sig">
                    <xsl:value-of select="$keySig"/>
                  </xsl:attribute>
                </xsl:when>
                <xsl:when test="$keySig &gt; 0">
                  <xsl:attribute name="key.sig"><xsl:value-of select="$keySig"/>s</xsl:attribute>
                </xsl:when>
                <xsl:when test="$keySig &lt; 0">
                  <xsl:attribute name="key.sig"><xsl:value-of select="abs($keySig)"
                    />f</xsl:attribute>
                </xsl:when>
              </xsl:choose>
              <!-- staff key mode -->
              <xsl:if test="key/mode and key/mode != $scoreMode">
                <xsl:attribute name="key.mode">
                  <xsl:value-of select="key/mode"/>
                </xsl:attribute>
              </xsl:if>
            </xsl:if>
            <xsl:if test="key/@print-object='no'">
              <xsl:attribute name="key.sig.show">false</xsl:attribute>
            </xsl:if>
          </xsl:if>
          <!-- tuning for TAB staff -->
          <xsl:if test="staff-details/staff-tuning">
            <xsl:attribute name="tab.strings">
              <xsl:variable name="tabStrings">
                <xsl:for-each select="staff-details/staff-tuning">
                  <xsl:sort select="@line" order="descending"/>
                  <xsl:variable name="thisString">
                    <xsl:value-of select="tuning-step"/>
                  </xsl:variable>
                  <xsl:value-of select="translate(tuning-step,'ABCDEFG','abcdefg')"/>
                  <xsl:value-of select="tuning-octave"/>
                  <xsl:text>&#32;</xsl:text>
                </xsl:for-each>
              </xsl:variable>
              <xsl:value-of select="normalize-space($tabStrings)"/>
            </xsl:attribute>
          </xsl:if>
          <!-- staff transposition -->
          <xsl:choose>
            <!-- transposed -->
            <xsl:when test="transpose">
              <xsl:attribute name="trans.semi">
                <xsl:choose>
                  <xsl:when test="transpose/octave-change">
                    <xsl:variable name="octaveChange">
                      <xsl:value-of select="transpose[1]/octave-change"/>
                    </xsl:variable>
                    <xsl:variable name="chromatic">
                      <xsl:value-of select="transpose[1]/chromatic"/>
                    </xsl:variable>
                    <xsl:value-of select="$chromatic + (12 * $octaveChange)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="transpose[1]/chromatic"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <xsl:if test="transpose/diatonic">
                <xsl:attribute name="trans.diat">
                  <xsl:value-of select="transpose[1]/diatonic"/>
                </xsl:attribute>
              </xsl:if>
            </xsl:when>
            <!-- transposed by capo -->
            <xsl:when test="staff-details/capo">
              <xsl:attribute name="trans.semi">
                <xsl:value-of select="staff-details[capo]/capo"/>
              </xsl:attribute>
            </xsl:when>
          </xsl:choose>
          <!-- ppq -->
          <xsl:for-each select="divisions">
            <xsl:if test="number(.) != $scorePPQ">
              <xsl:attribute name="ppq">
                <xsl:value-of select="."/>
              </xsl:attribute>
            </xsl:if>
          </xsl:for-each>
          <!-- staff visibility -->
          <xsl:if test="staff-details/@print-object='no'">
            <xsl:attribute name="visible">false</xsl:attribute>
          </xsl:if>
          <!-- staff size -->
          <xsl:if test="staff-details/staff-size">
            <xsl:attribute name="scale">
              <xsl:value-of select="staff-details[staff-size][1]/staff-size"/>
              <xsl:text>%</xsl:text>
            </xsl:attribute>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <!-- number of staff lines -->
          <xsl:attribute name="lines">
            <xsl:choose>
              <xsl:when test="staff-details[@number=string($staffNum)]/staff-lines">
                <xsl:choose>
                  <xsl:when test="staff-details[@number=string($staffNum)]/staff-lines != ''">
                    <xsl:value-of select="staff-details[@number=string($staffNum)]/staff-lines"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="5"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="5"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <!-- clef -->
          <xsl:choose>
            <xsl:when test="normalize-space(clef[@number=string($staffNum)]/sign) != ''">
              <xsl:for-each select="clef[@number=string($staffNum)]">
                <xsl:choose>
                  <!-- percussion clef -->
                  <xsl:when test="sign='percussion'">
                    <xsl:attribute name="clef.shape">perc</xsl:attribute>
                  </xsl:when>
                  <!-- TAB "clef" -->
                  <xsl:when test="sign='TAB'">
                    <xsl:attribute name="clef.shape">TAB</xsl:attribute>
                  </xsl:when>
                  <!-- No clef provided -->
                  <xsl:when test="sign='none'">
                    <xsl:attribute name="clef.visible">false</xsl:attribute>
                  </xsl:when>
                  <!-- "normal" clef -->
                  <xsl:otherwise>
                    <xsl:attribute name="clef.line">
                      <xsl:value-of select="line"/>
                    </xsl:attribute>
                    <xsl:attribute name="clef.shape">
                      <xsl:value-of select="sign"/>
                    </xsl:attribute>
                    <xsl:if test="clef-octave-change">
                      <xsl:if test="abs(number(clef-octave-change)) != 0">
                        <xsl:attribute name="clef.dis">
                          <xsl:choose>
                            <xsl:when test="abs(number(clef-octave-change)) = 2">15</xsl:when>
                            <xsl:when test="abs(number(clef-octave-change)) = 1">8</xsl:when>
                          </xsl:choose>
                        </xsl:attribute>
                        <xsl:attribute name="clef.dis.place">
                          <xsl:choose>
                            <xsl:when test="number(clef-octave-change) &lt; 0">
                              <xsl:text>below</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:text>above</xsl:text>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:attribute>
                      </xsl:if>
                    </xsl:if>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="@print-object='no'">
                  <xsl:attribute name="clef.visible">false</xsl:attribute>
                </xsl:if>
              </xsl:for-each>
            </xsl:when>
            <!-- If no clef, then default to G on line 2 -->
            <xsl:otherwise>
              <xsl:attribute name="clef.line">2</xsl:attribute>
              <xsl:attribute name="clef.shape">G</xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
          <!-- staff key signature-->
          <xsl:if test="key">
            <xsl:variable name="keySig">
              <xsl:choose>
                <xsl:when test="key[@number=string($staffNum)]">
                  <xsl:value-of select="key[@number=string($staffNum)]/fifths"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="key[1]/fifths"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:if test="$keySig != $scoreFifths">
              <xsl:choose>
                <xsl:when test="$keySig=0">
                  <xsl:attribute name="key.sig">
                    <xsl:value-of select="$keySig"/>
                  </xsl:attribute>
                </xsl:when>
                <xsl:when test="$keySig &gt; 0">
                  <xsl:attribute name="key.sig"><xsl:value-of select="$keySig"/>s</xsl:attribute>
                </xsl:when>
                <xsl:when test="$keySig &lt; 0">
                  <xsl:attribute name="key.sig"><xsl:value-of select="abs($keySig)"
                    />f</xsl:attribute>
                </xsl:when>
              </xsl:choose>
              <!-- staff key mode -->
              <xsl:if test="key/mode">
                <xsl:variable name="keyMode">
                  <xsl:choose>
                    <xsl:when test="key[@number=string($staffNum)]">
                      <xsl:value-of select="key[@number=string($staffNum)]/mode"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="key[1]/mode"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:if test="$keyMode != $scoreMode">
                  <xsl:attribute name="key.mode">
                    <xsl:value-of select="$keyMode"/>
                  </xsl:attribute>
                </xsl:if>
              </xsl:if>
              <xsl:if test="key/@print-object='no'">
                <xsl:attribute name="key.sig.show">false</xsl:attribute>
              </xsl:if>
            </xsl:if>
          </xsl:if>
          <!-- tuning for TAB staff -->
          <xsl:if test="staff-details[@number=string($staffNum)]/staff-tuning">
            <xsl:attribute name="tab.strings">
              <xsl:variable name="tabStrings">
                <xsl:for-each select="staff-details[@number=string($staffNum)]/staff-tuning">
                  <xsl:sort select="@line" order="descending"/>
                  <xsl:variable name="thisString">
                    <xsl:value-of select="tuning-step"/>
                  </xsl:variable>
                  <xsl:value-of select="translate(tuning-step,'ABCDEFG','abcdefg')"/>
                  <xsl:value-of select="tuning-octave"/>
                  <xsl:text>&#32;</xsl:text>
                </xsl:for-each>
              </xsl:variable>
              <xsl:value-of select="normalize-space($tabStrings)"/>
            </xsl:attribute>
          </xsl:if>
          <!-- staff transposition -->
          <xsl:choose>
            <!-- transposed -->
            <xsl:when test="transpose[@number=string($staffNum)]">
              <xsl:attribute name="trans.semi">
                <xsl:choose>
                  <xsl:when test="transpose[@number=string($staffNum)]/octave-change">
                    <xsl:variable name="octaveChange">
                      <xsl:value-of select="transpose[@number=string($staffNum)]/octave-change"/>
                    </xsl:variable>
                    <xsl:variable name="chromatic">
                      <xsl:value-of select="transpose[@number=string($staffNum)]/chromatic"/>
                    </xsl:variable>
                    <xsl:value-of select="$chromatic + (12 * $octaveChange)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="transpose[@number=string($staffNum)]/chromatic"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <xsl:if test="transpose[@number=string($staffNum)]/diatonic">
                <xsl:attribute name="trans.diat">
                  <xsl:value-of select="transpose[@number=string($staffNum)]/diatonic"/>
                </xsl:attribute>
              </xsl:if>
            </xsl:when>
            <!-- transposed by capo -->
            <xsl:when test="staff-details[@number=string($staffNum)]/capo">
              <xsl:attribute name="trans.semi">
                <xsl:value-of select="staff-details[@number=string($staffNum)]/capo"/>
              </xsl:attribute>
            </xsl:when>
          </xsl:choose>
          <!-- ppq -->
          <xsl:for-each select="divisions">
            <xsl:if test="number(.) != $scorePPQ">
              <xsl:attribute name="ppq">
                <xsl:value-of select="."/>
              </xsl:attribute>
            </xsl:if>
          </xsl:for-each>
          <!-- staff visibility -->
          <xsl:if test="staff-details[@number=string($staffNum)]/@print-object='no'">
            <xsl:attribute name="visible">false</xsl:attribute>
          </xsl:if>
          <!-- staff size -->
          <xsl:if test="staff-details[@number=string($staffNum)]/staff-size">
            <xsl:attribute name="scale">
              <xsl:value-of select="staff-details[@number=string($staffNum) and
                staff-size][1]/staff-size"/>
              <xsl:text>%</xsl:text>
            </xsl:attribute>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    <xsl:choose>
      <xsl:when test="$staffNum = '' and
        following::measure[1]/part[@id=$partID]/print/staff-layout/staff-distance">
        <xsl:for-each
          select="following::measure[1]/part[@id=$partID]/print/staff-layout/staff-distance[1]">
          <xsl:attribute name="spacing">
            <xsl:value-of select="format-number(. div 5, '###0.####')"/>
            <!-- <xsl:text>vu</xsl:text> -->
          </xsl:attribute>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each
          select="following::measure[1]/part[@id=$partID]/print/staff-layout[string(@number)=$staffNum]/staff-distance">
          <xsl:attribute name="spacing">
            <xsl:value-of select="format-number(. div 5, '###0.####')"/>
            <!-- <xsl:text>vu</xsl:text> -->
          </xsl:attribute>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="titleStmt">
    <!-- Create titleStmt element -->
    <titleStmt xmlns="http://www.music-encoding.org/ns/mei">
      <title>
        <xsl:if test="normalize-space(work/work-title) != ''">
          <xsl:attribute name="label">
            <xsl:text>work</xsl:text>
          </xsl:attribute>
          <xsl:value-of select="normalize-space(replace(work/work-title, '^\[[^\]]*\](.+)$', '$1'))"
          />
        </xsl:if>
        <xsl:if test="normalize-space(work/work-number) != ''">
          <xsl:if test="normalize-space(work/work-title) != '' or
            normalize-space(movement-title) != ''">
            <xsl:text>, </xsl:text>
          </xsl:if>
          <identifier type="workNum">
            <xsl:value-of select="normalize-space(work/work-number)"/>
          </identifier>
        </xsl:if>
        <xsl:if test="normalize-space(movement-number) != ''">
          <xsl:if test="normalize-space(work/work-title) != '' or normalize-space(work/work-number)
            != ''">
            <xsl:text>, </xsl:text>
          </xsl:if>
          <identifier type="mvtNum">
            <xsl:if test="number(normalize-space(movement-number))">
              <xsl:text>no. </xsl:text>
            </xsl:if>
            <xsl:value-of select="normalize-space(movement-number)"/>
          </identifier>
        </xsl:if>
        <xsl:if test="normalize-space(movement-title) != ''">
          <xsl:choose>
            <xsl:when test="normalize-space(work/work-title) != '' or
              normalize-space(work/work-number) != '' or
              normalize-space(movement-number) != ''">
              <xsl:text>, </xsl:text>
              <title>
                <xsl:attribute name="label">
                  <xsl:text>movement</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="normalize-space(replace(movement-title, '^\[[^\]]*\](.+)$',
                  '$1'))"/>
              </title>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="label">
                <xsl:text>movement</xsl:text>
              </xsl:attribute>
              <xsl:value-of select="normalize-space(replace(movement-title, '^\[[^\]]*\](.+)$',
                '$1'))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </title>
      <xsl:if test="identification/creator">
        <respStmt>
          <xsl:for-each select="identification/creator">
            <!-- name + @role -->
            <name>
              <xsl:if test="normalize-space(@type) !=''">
                <xsl:attribute name="role">
                  <xsl:value-of select="@type"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:value-of select="normalize-space(.)"/>
            </name>
            <!-- TEI-like respStmt content -->
            <!--<xsl:if test="not(@type='')">
              <resp>
                <xsl:value-of select="@type"/>
              </resp>
            </xsl:if>
            <name>
              <xsl:value-of select="normalize-space(.)"/>
            </name>-->
          </xsl:for-each>
        </respStmt>
      </xsl:if>
      <!--<xsl:for-each select="identification/creator[@type='composer' or @type='arranger' or
        @type='librettist' or @type='lyricist']">
        <xsl:element name="{@type}">
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:element>
      </xsl:for-each>
      <xsl:if test="identification/creator[not(@type='arranger') and not(@type='composer') and
        not(@type='librettist') and not(@type='lyricist')]">
        <respStmt>
          <xsl:for-each select="identification/creator[not(@type='arranger') and
            not(@type='composer') and not(@type='librettist') and not(@type='lyricist')]">
            <xsl:value-of select="$nl"/>
            <xsl:if test="not(@type='')">
              <resp>
                <xsl:value-of select="@type"/>
              </resp>
            </xsl:if>
            <name>
              <xsl:value-of select="normalize-space(.)"/>
            </name>
          </xsl:for-each>
        </respStmt>
      </xsl:if>-->
    </titleStmt>
  </xsl:template>

  <xsl:template name="tstampAttrs">
    <!-- Create tstamp attributes for MEI directives -->
    <xsl:variable name="tstampGestural">
      <xsl:call-template name="getTimestamp.ges"/>
    </xsl:variable>
    <xsl:attribute name="tstamp">
      <xsl:call-template name="tstamp.ges2beat">
        <xsl:with-param name="tstamp.ges">
          <xsl:choose>
            <!-- Using offset until it can be determined when to use @default-x -->
            <xsl:when test="number(offset)">
              <xsl:value-of select="format-number(number($tstampGestural) +
                number(offset), '###0.####')"/>
            </xsl:when>
            <!--<xsl:when test="number(ancestor::direction[1]/offset) and
              not(ancestor::direction[1]/direction-type/dynamics/@default-x)">
              <xsl:value-of select="number($tstampGestural) + number(ancestor::direction[1]/offset)"
              />
            </xsl:when>-->
            <xsl:otherwise>
              <xsl:value-of select="format-number(number($tstampGestural), '###0.####')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:attribute>
    <xsl:attribute name="tstamp.ges">
      <xsl:choose>
        <xsl:when test="number(offset[@sound='yes'])">
          <xsl:value-of select="$tstampGestural + number(offset[@sound='yes'])"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$tstampGestural"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="tstamp.ges2beat">
    <!-- Convert tstamp.ges value to musical time. -->
    <xsl:param name="tstamp.ges"/>
    <xsl:variable name="thisPart">
      <xsl:value-of select="ancestor::part/@id"/>
    </xsl:variable>
    <xsl:variable name="ppq">
      <xsl:choose>
        <xsl:when test="ancestor::part[attributes/divisions]">
          <xsl:value-of select="ancestor::part[attributes/divisions]/attributes/divisions"/>
        </xsl:when>
        <xsl:when test="preceding::part[@id=$thisPart and attributes/divisions]">
          <xsl:value-of select="preceding::part[@id=$thisPart and
            attributes/divisions][1]/attributes/divisions"/>
        </xsl:when>
        <xsl:when test="following::part[@id=$thisPart and attributes/divisions]">
          <xsl:value-of select="following::part[@id=$thisPart and
            attributes/divisions][1]/attributes/divisions"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$scorePPQ"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="meterUnit">
      <xsl:choose>
        <xsl:when test="count(ancestor::part[@id=$thisPart and
          attributes/time/beat-type]/attributes/time/beat-type) &gt; 1">
          <xsl:value-of select="max(ancestor::part[@id=$thisPart and
            attributes/time/beat-type]/attributes/time/beat-type)"/>
        </xsl:when>
        <xsl:when test="ancestor::part[@id=$thisPart and
          attributes/time/beat-type]/attributes/time/beat-type">
          <xsl:value-of select="ancestor::part[@id=$thisPart and
            attributes/time/beat-type]/attributes/time/beat-type"/>
        </xsl:when>
        <xsl:when test="preceding::part[@id=$thisPart and attributes/time/beat-type]">
          <xsl:value-of select="preceding::part[@id=$thisPart and
            attributes/time][1]/attributes/time/beat-type"/>
        </xsl:when>
        <xsl:otherwise>4</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$meterUnit = 4">
        <xsl:value-of select="format-number(1 + ($tstamp.ges div $ppq), '###0.####')"/>
      </xsl:when>
      <xsl:when test="$meterUnit != 4">
        <xsl:value-of select="format-number(1 + ($tstamp.ges div $ppq) * ($meterUnit div 4),
          '###0.####')"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="warningPhase2">
    <xsl:param name="warning"/>
    <xsl:param name="measureNum"/>
    <xsl:message>
      <xsl:value-of select="normalize-space(concat($warning, ' (m.', $measureNum, ').'))"/>
    </xsl:message>
    <xsl:comment>
      <xsl:value-of select="normalize-space(concat($warning, '.'))"/>
    </xsl:comment>
    <xsl:comment>
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="local-name()"/>
      <xsl:text> </xsl:text>
      <xsl:for-each select="@*">
        <xsl:value-of select="name()"/>
        <xsl:text>="</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>"</xsl:text>
        <xsl:if test="position()!=last()">
          <xsl:text>&#32;</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>/&gt;</xsl:text>
    </xsl:comment>
  </xsl:template>

  <xsl:template name="wrapRend">
    <!-- Wrap text with positional or renditional attributes w/ MEI rend element -->
    <xsl:param name="in"/>
    <rend xmlns="http://www.music-encoding.org/ns/mei">
      <!-- Individual attributes first -->
      <xsl:call-template name="fontProperties"/>
      <xsl:choose>
        <xsl:when test="@halign">
          <xsl:attribute name="halign">
            <xsl:value-of select="@halign"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:when test="@justify">
          <xsl:attribute name="halign">
            <xsl:value-of select="@justify"/>
          </xsl:attribute>
        </xsl:when>
      </xsl:choose>
      <xsl:if test="@valign">
        <xsl:copy-of select="@valign"/>
      </xsl:if>
      <xsl:if test="@rotation">
        <xsl:copy-of select="@rotation"/>
      </xsl:if>
      <xsl:call-template name="color"/>
      <xsl:copy-of select="@xml:lang"/>
      <xsl:copy-of select="@xml:space"/>
      <!-- Other properties go in @rend -->
      <xsl:if test="@underline or @overline or @line-through or @dir or @enclosure!='none' or
        @letter-spacing or @line-height or @print-object='no' or (local-name()='rehearsal' and
        not(@enclosure))">
        <xsl:variable name="rendValue">
          <xsl:if test="@underline">
            <xsl:text>underline</xsl:text>
            <xsl:text>(</xsl:text>
            <xsl:value-of select="@underline"/>
            <xsl:text>)&#32;</xsl:text>
          </xsl:if>
          <xsl:if test="@overline">
            <xsl:text>overline</xsl:text>
            <xsl:text>(</xsl:text>
            <xsl:value-of select="@overline"/>
            <xsl:text>)&#32;</xsl:text>
          </xsl:if>
          <xsl:if test="@line-through">
            <xsl:text>line-through</xsl:text>
            <xsl:text>(</xsl:text>
            <xsl:value-of select="@line-through"/>
            <xsl:text>)&#32;</xsl:text>
          </xsl:if>
          <xsl:if test="@letter-spacing">
            <xsl:text>letter-spacing</xsl:text>
            <xsl:text>(</xsl:text>
            <xsl:value-of select="format-number(@letter-spacing, '###0.####')"/>
            <xsl:text>)&#32;</xsl:text>
          </xsl:if>
          <xsl:if test="@line-height">
            <xsl:text>line-height</xsl:text>
            <xsl:text>(</xsl:text>
            <xsl:value-of select="format-number(@line-height, '###0.####')"/>
            <xsl:text>)&#32;</xsl:text>
          </xsl:if>
          <xsl:if test="@dir">
            <xsl:value-of select="@dir"/>
            <xsl:text>&#32;</xsl:text>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="@enclosure = 'rectangle' or @enclosure = 'square'">
              <xsl:text>box&#32;</xsl:text>
            </xsl:when>
            <xsl:when test="@enclosure = 'oval' or @enclosure = 'circle'">
              <xsl:text>circle&#32;</xsl:text>
            </xsl:when>
            <xsl:when test="@enclosure = 'triangle'">
              <xsl:text>tbox&#32;</xsl:text>
            </xsl:when>
            <xsl:when test="@enclosure = 'diamond'">
              <xsl:text>dbox&#32;</xsl:text>
            </xsl:when>
            <!-- Even without @enclosure, rehearsal marks are boxed by default. -->
            <xsl:when test="not(@enclosure) and local-name()='rehearsal'">
              <xsl:text>box&#32;</xsl:text>
            </xsl:when>
          </xsl:choose>
          <xsl:if test="@print-object='no'">
            <xsl:text>none</xsl:text>
          </xsl:if>
        </xsl:variable>
        <xsl:if test="normalize-space($rendValue) != ''">
          <xsl:attribute name="rend">
            <xsl:value-of select="normalize-space($rendValue)"/>
          </xsl:attribute>
        </xsl:if>
      </xsl:if>
      <xsl:copy-of select="$in"/>
    </rend>
  </xsl:template>

  <!-- PostProcessing templates -->

  <xsl:function name="f:getNext">
    <xsl:param name="current" as="node()"/>
    <xsl:param name="endID" as="xs:string"/>

    <xsl:copy-of select="$current"/>

    <xsl:choose>
      <xsl:when test="$current/following-sibling::mei:*[1]/@xml:id eq $endID">
        <xsl:copy-of select="$current/following-sibling::mei:*[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="f:getNext($current/following-sibling::mei:*[1],$endID)"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:function>

  <xsl:function name="f:getElems">
    <xsl:param name="start" as="node()"/>
    <xsl:param name="end" as="node()"/>

    <xsl:copy-of select="f:getNext($start,$end/@xml:id)"/>

  </xsl:function>

  <xsl:template match="mei:beamSpan" mode="postProcess">

    <xsl:variable name="start" select="if(id(@startid)/parent::mei:chord)
      then(id(@startid)/parent::mei:chord) else(id(@startid))"/>
    <xsl:variable name="end" select="if(id(@endid)/parent::mei:chord)
      then(id(@endid)/parent::mei:chord) else(id(@endid))"/>
    <xsl:variable name="sameStaff" select="$start/ancestor::mei:measure/@xml:id =
      $end/ancestor::mei:measure/@xml:id and $start/ancestor::mei:staff/@n =
      $end/ancestor::mei:staff/@n and $start/ancestor::mei:layer/@n = $end/ancestor::mei:layer/@n"
      as="xs:boolean"/>

    <xsl:choose>
      <xsl:when test="$sameStaff">
        <xsl:variable name="elems" select="f:getElems($start,$end)" as="node()*"/>

        <!-- TODO: what about rests, different beams, etc.? -->
        <xsl:variable name="allBeamed" select="every $elem in $elems satisfies ($elem/@beam or
          @grace)" as="xs:boolean"/>

        <xsl:choose>
          <xsl:when test="not($allBeamed)">
            <xsl:copy>
              <xsl:apply-templates select="node() | @*" mode="#current"/>
              <xsl:attribute name="plist" select="concat('#',string-join($elems[@beam]/@xml:id,'
                #'))"/>
            </xsl:copy>
          </xsl:when>
          <xsl:otherwise>
            <!-- This <beamSpan> will be expressed as <beam> instead. -->
          </xsl:otherwise>
        </xsl:choose>

      </xsl:when>
      <xsl:otherwise>
        <!-- not everything attached to the beam is in|on the same measure / staff / layer -->
        <xsl:copy>
          <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
        <xsl:comment>@plist couldn't be added automatically</xsl:comment>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <xsl:function name="functx:sort-as-numeric" as="item()*">
    <xsl:param name="seq" as="item()*"/>

    <xsl:for-each select="$seq">
      <xsl:sort select="number(.)"/>
      <xsl:copy-of select="."/>
    </xsl:for-each>

  </xsl:function>

  <xsl:function name="functx:value-except" as="xs:anyAtomicType*">
    <xsl:param name="arg1" as="xs:anyAtomicType*"/>
    <xsl:param name="arg2" as="xs:anyAtomicType*"/>

    <xsl:sequence select="distinct-values($arg1[not(.=$arg2)])"/>

  </xsl:function>

  <xsl:template match="mei:layer" mode="postProcess">
    <xsl:variable name="measure" select="ancestor::mei:measure"/>

    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>

      <xsl:variable name="beamsResolved">
        <xsl:for-each select="node()">
          <xsl:choose>
            <xsl:when test="starts-with(@beam,'i') and not(@grace)">
              <xsl:variable name="num" select="substring(@beam,2)"/>
              <xsl:choose>
                <xsl:when test="following-sibling::mei:*[@beam = concat('t',$num)]">
                  <xsl:variable name="end" select="following-sibling::mei:*[@beam =
                    concat('t',$num)][1]"/>
                  <xsl:variable name="elems" select="f:getElems(.,$end)" as="node()*"/>
                  <xsl:variable name="allBeamed" select="every $elem in $elems satisfies
                    ($elem[ends-with(@beam,$num)] or $elem/@grace)" as="xs:boolean"/>
                  <xsl:choose>
                    <xsl:when test="$allBeamed">
                      <beam xmlns="http://www.music-encoding.org/ns/mei">
                        <xsl:attribute name="xml:id" select="generate-id()"/>
                        <xsl:apply-templates select="$elems" mode="#current"/>
                      </beam>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:apply-templates select="." mode="#current"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="." mode="#current"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="starts-with(@beam,'m') and not(@grace)">
              <xsl:variable name="num" select="substring(@beam,2)"/>
              <xsl:choose>
                <xsl:when test="preceding-sibling::mei:*//@beam[. = concat('i',$num)] and
                  following-sibling::mei:*//@beam[. = concat('t',$num)]">

                  <xsl:variable name="start" select="preceding-sibling::mei:*[@beam =
                    concat('i',$num)][1]"/>
                  <xsl:variable name="end" select="following-sibling::mei:*[@beam =
                    concat('t',$num)][1]"/>
                  <xsl:variable name="elems" select="f:getElems($start,$end)" as="node()*"/>
                  <xsl:variable name="allBeamed" select="every $elem in $elems satisfies
                    ($elem[ends-with(@beam,$num)] or $elem/@grace)" as="xs:boolean"/>
                  <xsl:choose>
                    <xsl:when test="$allBeamed"/>
                    <xsl:otherwise>
                      <xsl:apply-templates select="." mode="#current"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="." mode="#current"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="@grace">
              <xsl:choose>
                <xsl:when test="preceding-sibling::mei:*//@beam">

                  <xsl:variable name="prec" select="preceding-sibling::mei:*//@beam"/>
                  <xsl:variable name="num" select="substring($prec[1],2)"/>
                  <xsl:variable name="elem" select="." as="node()"/>

                  <xsl:choose>
                    
                    <xsl:when test="count($elem/preceding-sibling::mei:*//@beam[starts-with(.,'i')]) gt count($elem/preceding-sibling::mei:*//@beam[starts-with(.,'t')]) 
                      and $elem/preceding-sibling::mei:*//@beam[starts-with(.,'i')][1]/@beam = concat('i',$num)
                      and $elem/following-sibling::mei:*//@beam[. = concat('t',$num)]">
                    
                    <!--<xsl:when test="following-sibling::mei:*//@beam[. = concat('t',$num)]">-->
                      <xsl:variable name="start" select="preceding-sibling::mei:*[.//@beam =
                        concat('i',$num)][1]"/>
                      <xsl:variable name="end" select="following-sibling::mei:*[.//@beam =
                        concat('t',$num)][1]"/>
                      <xsl:variable name="elems" select="f:getElems($start,$end)" as="node()*"/>
                      <xsl:variable name="allBeamed" select="every $elem in $elems satisfies
                        ($elem[ends-with(@beam,$num)] or $elem/@grace)" as="xs:boolean"/>
                      <xsl:choose>
                        <xsl:when test="$allBeamed"/>
                        <xsl:otherwise>
                          <xsl:apply-templates select="." mode="#current"/>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:apply-templates select="." mode="#current"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="." mode="#current"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>

            <xsl:when test="starts-with(@beam,'t') and not(@grace)">
              <xsl:variable name="num" select="substring(@beam,2)"/>
              <xsl:choose>
                <xsl:when test="preceding-sibling::mei:*[@beam = concat('i',$num)]">
                  <xsl:variable name="start" select="preceding-sibling::mei:*[@beam =
                    concat('i',$num)][1]"/>
                  <xsl:variable name="elems" select="f:getElems($start,.)" as="node()*"/>
                  <xsl:variable name="allBeamed" select="every $elem in $elems satisfies
                    ($elem[ends-with(@beam,$num)] or $elem/@grace)" as="xs:boolean"/>
                  <xsl:choose>
                    <xsl:when test="$allBeamed"/>
                    <xsl:otherwise>
                      <xsl:apply-templates select="." mode="#current"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates select="." mode="#current"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="." mode="#current"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="not($beamsResolved//@tuplet)">
          <xsl:copy-of select="$beamsResolved"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="$beamsResolved/*">
            <xsl:choose>
              <xsl:when test=".//@tuplet[starts-with(.,'i')]">

                <xsl:choose>
                  <xsl:when test="count(.//@tuplet[starts-with(.,'i')]) = 1">
                    <xsl:variable name="num" select="substring(.//@tuplet[starts-with(.,'i')],2)"/>
                    <xsl:choose>
                      <xsl:when test=".//mei:*[@tuplet =
                        concat('i',$num)]/preceding-sibling::mei:*[starts-with(@tuplet,'t')]">
                        <!-- If the first @tuplet in a beam is an end (@tuplet="t1"), it should have been handled by the element opening it. -->
                      </xsl:when>

                      <xsl:when test=".//@tuplet[. = concat('t',$num)] and local-name(.) eq 'beam'">
                        <xsl:choose>
                          <xsl:when test="./child::mei:*[1][@tuplet = concat('i',$num)] and
                            ./child::mei:*[last()][@tuplet = concat('t',$num)]">

                            <xsl:variable name="startChild" select="./child::mei:*[@tuplet =
                              concat('i',$num)]"/>
                            <xsl:variable name="endChild" select="./child::mei:*[@tuplet =
                              concat('t',$num) and preceding-sibling::mei:*[@tuplet =
                              concat('i',$num)]][1]"/>
                            <xsl:variable name="tupChilds"
                              select="f:getElems($startChild,$endChild)"/>
                            <xsl:variable name="tuppable" select="every $elem in $tupChilds
                              satisfies(@tuplet[ends-with(.,$num)] or @grace)"/>

                            <xsl:choose>
                              <xsl:when test="$tuppable">
                                <tuplet xmlns="http://www.music-encoding.org/ns/mei">
                                  <xsl:variable name="id" select="@xml:id"/>
                                  <xsl:variable name="tupletSpan"
                                    select="./ancestor::mei:measure//mei:tupletSpan[@startid = $id]"/>
                                  <xsl:copy-of select="$tupletSpan/@num | $tupletSpan/@numbase |
                                    $tupletSpan/@num.visible | $tupletSpan/@bracket.visible"/>
                                  <xsl:attribute name="tupletRef" select="$tupletSpan/@xml:id"/>
                                  <xsl:copy-of select="."/>
                                </tuplet>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:copy-of select="."/>
                              </xsl:otherwise>
                            </xsl:choose>

                          </xsl:when>
                          <xsl:otherwise>
                            <!-- A tuplet sits inside a beam, but does not fill it completely -->

                            <xsl:variable name="startChild" select="./child::mei:*[@tuplet =
                              concat('i',$num)]"/>
                            <xsl:variable name="endChild" select="./child::mei:*[@tuplet =
                              concat('t',$num) and preceding-sibling::mei:*[@tuplet =
                              concat('i',$num)]][1]"/>
                            <xsl:variable name="tupChilds"
                              select="f:getElems($startChild,$endChild)"/>
                            <xsl:variable name="tuppable" select="every $elem in $tupChilds
                              satisfies(@tuplet[ends-with(.,$num)] or @grace)"/>

                            <xsl:choose>
                              <xsl:when test="$tuppable">
                                <beam xmlns="http://www.music-encoding.org/ns/mei">
                                  <xsl:copy-of
                                    select="./child::mei:*[following-sibling::mei:*[starts-with(@tuplet,'i')]]"/>
                                  <tuplet xmlns="http://www.music-encoding.org/ns/mei">
                                    <xsl:variable name="id" select="@xml:id"/>
                                    <xsl:variable name="tupletSpan"
                                      select="./ancestor::mei:measure//mei:tupletSpan[@startid =
                                      $id]"/>
                                    <xsl:copy-of select="$tupletSpan/@num | $tupletSpan/@numbase |
                                      $tupletSpan/@num.visible | $tupletSpan/@bracket.visible"/>
                                    <xsl:attribute name="tupletRef" select="$tupletSpan/@xml:id"/>
                                    <xsl:copy-of select="$tupChilds"/>
                                  </tuplet>
                                  <xsl:copy-of
                                    select="./child::mei:*[preceding-sibling::mei:*[starts-with(@tuplet,'t')
                                    and preceding-sibling::mei:*[starts-with(@tuplet,'i')]]]"/>
                                </beam>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:copy-of select="."/>
                              </xsl:otherwise>
                            </xsl:choose>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:when>

                      <xsl:when test="./following-sibling::mei:*//@tuplet[. = concat('t',$num)]">

                        <xsl:variable name="end" select="./following-sibling::mei:*[.//@tuplet[. =
                          concat('t',$num)]][1]"/>
                        <xsl:variable name="elems" select="f:getElems(.,$end)" as="node()*"/>
                        <xsl:variable name="notes" select="$elems/descendant-or-self::mei:note" as="node()*"/>
                        
                        <xsl:variable name="tuppable" select="(every $note in $notes satisfies
                          ($note/@tuplet[ends-with(.,$num)] or 
                          $note/@grace))
                          and
                          count($notes[@tuplet and starts-with(@tuplet,'i')]) =
                          count($notes[@tuplet and starts-with(@tuplet,'t')])
                          " as="xs:boolean"/>
                          
                        <xsl:choose>
                          <xsl:when test="$tuppable">
                            <tuplet xmlns="http://www.music-encoding.org/ns/mei">
                              <xsl:variable name="id" select="if(local-name() = 'beam') then(child::mei:*[1]/@xml:id) else(@xml:id)"/>
                              <xsl:variable name="tupletSpan"
                                select="$measure//mei:tupletSpan[@startid = $id]"/>

                              <xsl:copy-of select="$tupletSpan/@num | $tupletSpan/@numbase |
                                $tupletSpan/@num.visible | $tupletSpan/@bracket.visible"/>
                              <xsl:attribute name="tupletRef" select="$tupletSpan/@xml:id"/>
                              <xsl:copy-of select="$elems"/>
                            </tuplet>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:copy-of select="."/>
                            <xsl:variable name="tupletStartID">
                              <xsl:value-of select="descendant::*[1]/@xml:id"/>
                            </xsl:variable>
                            <xsl:message>
                              <xsl:value-of select="normalize-space(concat('The tuplet starting with ', $tupletStartID, ' could not be resolved.'))"/>
                            </xsl:message>
                            <xsl:message select="$elems"/>
                          </xsl:otherwise>
                        </xsl:choose>

                      </xsl:when>

                      <xsl:otherwise>
                        <xsl:copy-of select="."/>
                      </xsl:otherwise>
                    </xsl:choose>

                  </xsl:when>
                  <xsl:otherwise>
                    <!-- more than one tuplet start contained -->

                    <xsl:variable name="starts" select=".//mei:*[starts-with(@tuplet,'i')]"/>
                    <xsl:variable name="stops" select=".//mei:*[starts-with(@tuplet,'t')]"/>

                    <xsl:choose>
                      <xsl:when test="count($starts) = count($stops) and
                        .//@tuplet[1][starts-with(.,'i')]">
                        <beam xmlns="http://www.music-encoding.org/ns/mei">
                          <xsl:copy-of select=".//mei:*[@tuplet][1]/preceding-sibling::mei:*"/>
                          <xsl:for-each select="$starts">
                            <xsl:variable name="end"
                              select="./following-sibling::mei:*[starts-with(@tuplet,'t')][1]"/>
                            <xsl:variable name="elems" select="f:getElems(.,$end)"/>
                            <xsl:variable name="num" select="substring(@tuplet,2)"/>
                            <xsl:variable name="tuppable" select="every $elem in $elems satisfies
                              ends-with(@tuplet,$num)"/>

                            <xsl:choose>
                              <xsl:when test="$tuppable">
                                <tuplet xmlns="http://www.music-encoding.org/ns/mei">
                                  <xsl:variable name="id" select="@xml:id"/>
                                  <xsl:variable name="tupletSpan"
                                    select="$measure//mei:tupletSpan[@startid = $id]"/>

                                  <xsl:copy-of select="$tupletSpan/@num | $tupletSpan/@numbase |
                                    $tupletSpan/@num.visible | $tupletSpan/@bracket.visible"/>
                                  <xsl:attribute name="tupletRef" select="$tupletSpan/@xml:id"/>
                                  <xsl:copy-of select="$elems"/>
                                </tuplet>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:copy-of select="$elems"/>
                              </xsl:otherwise>
                            </xsl:choose>

                            <xsl:if test="$end/following-sibling::mei:*[1][not(@tuplet)]">
                              <xsl:variable name="nextStart"
                                select="$end/following-sibling::mei:*[starts-with(@tuplet,'i')]"/>
                              <xsl:choose>
                                <xsl:when test="$nextStart">
                                  <xsl:copy-of
                                    select="f:getElems($end/following-sibling::mei:*[1],$nextStart/preceding-sibling::mei:*[1])"
                                  />
                                </xsl:when>
                                <xsl:otherwise>
                                  <xsl:copy-of select="following-sibling::mei:*"/>
                                </xsl:otherwise>
                              </xsl:choose>
                            </xsl:if>

                          </xsl:for-each>
                        </beam>
                      </xsl:when>

                    </xsl:choose>


                    <!--<xsl:copy-of select="."/>
                    <xsl:message select="' more than one tuplet start contained '"></xsl:message>-->
                  </xsl:otherwise>

                </xsl:choose>
              </xsl:when>

              <xsl:when test="starts-with(@tuplet,'m') or (local-name(.) = 'beam' and (every $child
                in . satisfies(starts-with(@beam,'m'))))">
                <!-- This situation must be dealt by the tuplet-start case. Also, there must be no situation with @tuplet="mX", but not "iX" or "tX". -->
              </xsl:when>

              <xsl:when test=".//@tuplet[starts-with(.,'t')]">
                <!--<xsl:message>deal with end of tuplet (<xsl:value-of select="concat(string(@xml:id),' ',string(local-name(.)))"/>)</xsl:message>-->
                <!-- This sitation should be handled by the tuplet opening scenario. -->
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy-of select="."/>
              </xsl:otherwise>

            </xsl:choose>


          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>


    </xsl:copy>
  </xsl:template>

  <xsl:template match="@startid" mode="postProcess">
    <xsl:variable name="target" select="id(.)"/>
    <xsl:choose>
      <xsl:when test="parent::mei:beamSpan and local-name($target) eq 'note' and
        $target/parent::mei:chord">
        <xsl:attribute name="startid" select="concat('#',$target/parent::mei:chord/@xml:id)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="startid" select="concat('#',.)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@endid" mode="postProcess">
    <xsl:variable name="target" select="id(.)"/>
    <xsl:choose>
      <xsl:when test="parent::mei:beamSpan and local-name($target) eq 'note' and
        $target/parent::mei:chord">
        <xsl:attribute name="endid" select="concat('#',$target/parent::mei:chord/@xml:id)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="endid" select="concat('#',.)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@plist" mode="postProcess">
    <xsl:attribute name="plist" select="concat('#',string-join(tokenize(.,' '),' #'))"/>
  </xsl:template>


  <!-- First cleanup step (in postProcess phase), according to selected parameters -->

  <xsl:template match="@ppq" mode="postProcess">
    <xsl:if test="$generateMIDI != 'false'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@*[starts-with(local-name(),'midi')]" mode="postProcess">
    <xsl:if test="$generateMIDI != 'false'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="mei:instrDef" mode="postProcess">
    <xsl:if test="$generateMIDI != 'false'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@*[starts-with(local-name(),'page')]" mode="postProcess">
    <xsl:if test="$layout = ('preserve', 'pageLayout')">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@*[starts-with(local-name(),'system')]" mode="postProcess">
    <xsl:if test="$layout = ('preserve', 'pageLayout')">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@*[starts-with(local-name(),'lyric')]" mode="postProcess">
    <xsl:if test="$layout = ('preserve', 'pageLayout')">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@*[starts-with(local-name(),'text')]" mode="postProcess">
    <xsl:if test="$layout = ('preserve', 'pageLayout')">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@*[starts-with(local-name(),'music')]" mode="postProcess">
    <xsl:if test="$layout = ('preserve','pageLayout')">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@*[starts-with(local-name(),'spacing')]" mode="postProcess">
    <xsl:if test="$layout = ('preserve','pageLayout')">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:staffDef/@scale" mode="postProcess">
    <xsl:if test="$layout eq 'preserve'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="mei:staffDef/@visible" mode="postProcess">
    <xsl:if test="$layout eq 'preserve'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@ho" mode="postProcess">
    <xsl:if test="$layout eq 'preserve'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@vo" mode="postProcess">
    <xsl:if test="$layout eq 'preserve'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@val" mode="postProcess">
    <xsl:if test="$layout eq 'preserve'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@vu.height" mode="postProcess">
    <xsl:if test="$layout eq 'preserve'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@width" mode="postProcess">
    <xsl:if test="$layout eq 'preserve'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@tstamp.ges" mode="postProcess">
    <xsl:if test="$generateMIDI != 'false'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@dur.ges" mode="postProcess">
    <xsl:if test="$generateMIDI != 'false'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@fontsize" mode="postProcess">
    <xsl:if test="$layout eq 'preserve'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@fontweight" mode="postProcess">
    <xsl:if test="$layout eq 'preserve'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@startvo" mode="postProcess">
    <xsl:if test="$layout eq 'preserve'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@endvo" mode="postProcess">
    <xsl:if test="$layout eq 'preserve'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@startho" mode="postProcess">
    <xsl:if test="$layout eq 'preserve'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@endho" mode="postProcess">
    <xsl:if test="$layout eq 'preserve'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@bezier" mode="postProcess">
    <xsl:if test="$layout eq 'preserve'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="mei:rend[not(@*[not(starts-with(local-name(),'font'))])]" mode="postProcess">
    <xsl:choose>
      <xsl:when test="$layout eq 'preserve'">
        <xsl:copy>
          <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="child::node()" mode="#current"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:pgHead" mode="postProcess">
    <xsl:if test="$formeWork = 'preserve'">
      <xsl:copy>
        <xsl:apply-templates select="node() | @*" mode="#current"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <xsl:template match="mei:pgFoot" mode="postProcess">
    <xsl:if test="$formeWork = 'preserve'">
      <xsl:copy>
        <xsl:apply-templates select="node() | @*" mode="#current"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <xsl:template match="mei:pgHead2" mode="postProcess">
    <xsl:if test="$formeWork = 'preserve'">
      <xsl:copy>
        <xsl:apply-templates select="node() | @*" mode="#current"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <xsl:template match="mei:pgFoot2" mode="postProcess">
    <xsl:if test="$formeWork = 'preserve'">
      <xsl:copy>
        <xsl:apply-templates select="node() | @*" mode="#current"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:artic" mode="postProcess">
    <xsl:if test="$articStyle = ('elem','both')">
      <xsl:copy>
        <xsl:apply-templates select="@* | node()" mode="#current"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@artic[not(local-name(parent::mei:*) = 'artic')]" mode="cleanUp">
    <xsl:if test="$articStyle = ('attr','both')">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:accid" mode="postProcess">
    <xsl:if test="$accidStyle = ('elem','both')">
      <xsl:copy>
        <xsl:apply-templates select="@* | node()" mode="#current"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@accid[not(local-name(parent::mei:*) = 'accid')]" mode="cleanUp">
    <xsl:if test="$accidStyle = ('attr','both')">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:tie" mode="cleanUp">
    <xsl:if test="$tieStyle = ('elem','both')">
      <xsl:copy>
        <xsl:apply-templates select="@* | node()" mode="#current"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@tie" mode="cleanUp">
    <xsl:if test="$tieStyle = ('attr','both')">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@beam" mode="cleanUp">
    <xsl:if test="$keepAttributes != 'false'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@tuplet" mode="cleanUp">
    <xsl:if test="$keepAttributes != 'false'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="@syl" mode="postProcess">
    <xsl:if test="$keepAttributes != 'false'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:scoreDef[count(@*) = 0 and count(child::mei:*) = 0]" mode="postProcess"/>
  <xsl:template match="mei:staffDef[count(@* except @n) = 0 and count(child::mei:*) = 0]"
    mode="postProcess"/>

  <xsl:template match="mei:scoreDef//mei:label" mode="postProcess">
    <xsl:if test="$labelStyle = ('elem','both')">
      <xsl:copy>
        <xsl:apply-templates select="@* | node()" mode="#current"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <xsl:template match="mei:scoreDef//@label" mode="postProcess">
    <xsl:if test="$labelStyle = ('attr','both')">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  <xsl:template match="mei:scoreDef//@label.abbr" mode="postProcess">
    <xsl:if test="$labelStyle = ('attr','both')">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="node() | @* | processing-instruction()" mode="postProcess">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>


  <!-- Final cleanup step, removing all remaining conversion artifacts and resolving nested beamed grace notes -->

  <xsl:template match="mei:beam/mei:note[@grace and starts-with(@beam,'i')]" mode="cleanUp">
    <xsl:variable name="end" select="following-sibling::mei:note[@grace and starts-with(@beam,'t')]"/>
    <xsl:variable name="elems" select="f:getElems(.,$end)"/>
    <xsl:variable name="num" select="substring(@beam,2)"/>
    <xsl:choose>
      <xsl:when test="every $elem in $elems satisfies (ends-with(@beam,$num))">
        <beam xmlns="http://www.music-encoding.org/ns/mei">
          <xsl:copy-of select="$elems"/>
        </beam>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:beam/mei:note[@grace and starts-with(@beam,'m')]" mode="cleanUp">
    <xsl:variable name="start" select="preceding-sibling::mei:note[@grace and
      starts-with(@beam,'i')]"/>
    <xsl:variable name="end" select="following-sibling::mei:note[@grace and starts-with(@beam,'t')]"/>
    <xsl:variable name="elems" select="f:getElems($start,$end)"/>
    <xsl:variable name="num" select="substring(@beam,2)"/>
    <xsl:choose>
      <xsl:when test="every $elem in $elems satisfies (ends-with(@beam,$num))"/>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:beam/mei:note[@grace and starts-with(@beam,'t')]" mode="cleanUp">
    <xsl:variable name="start" select="preceding-sibling::mei:note[@grace and
      starts-with(@beam,'i')]"/>
    <xsl:variable name="elems" select="f:getElems($start,.)"/>
    <xsl:variable name="num" select="substring(@beam,2)"/>
    <xsl:choose>
      <xsl:when test="every $elem in $elems satisfies (ends-with(@beam,$num))"/>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:beamSpan" mode="cleanUp">
    <xsl:variable name="startID" select="substring(@startid,2)"/>
    <xsl:variable name="start" select="parent::mei:measure//mei:note[@grace and parent::mei:beam and
      @xml:id = $startID]"/>

    <xsl:variable name="endID" select="substring(@endid,2)"/>
    <xsl:variable name="end" select="parent::mei:measure//mei:note[@grace and parent::mei:beam and
      @xml:id = $endID]"/>

    <xsl:variable name="sameBeam" select="$start/following-sibling::mei:note[@xml:id = $endID]"/>
    <xsl:choose>
      <xsl:when test="$start and $end and $sameBeam and (every $note in f:getElems($start,$end)
        satisfies $note/@beam)"/>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="node() | @*" mode="#current"/>
        </xsl:copy>
      </xsl:otherwise>

    </xsl:choose>

  </xsl:template>

  <xsl:template match="mei:beam/@xml:id" mode="cleanUp"/>
  <xsl:template match="mei:tuplet/@tupletRef" mode="cleanUp"/>

  <xsl:template match="mei:tupletSpan[@xml:id = //mei:tuplet/@tupletRef]" mode="cleanUp"/>
  <xsl:template match="mei:tupletSpan/@xml:id" mode="cleanUp"/>
  <xsl:template match="mei:beamSpan/@xml:id" mode="cleanUp"/>

  <xsl:template match="@role[. = 'poet']" mode="cleanUp">
    <xsl:attribute name="role" select="'lyricist'"/>
  </xsl:template>

  <!-- JK: Are the following templates generally useful? -->
  <xsl:template match="mei:scoreDef[not(exists(mei:staffGrp)) and
    local-name(following-sibling::mei:*[1]) = 'staffDef']" mode="cleanUp">
    <xsl:variable name="nextMeasureID" select="following-sibling::mei:measure[1]/@xml:id"/>
    <xsl:variable name="staffDefs"
      select="following-sibling::mei:staffDef[following-sibling::mei:measure[@xml:id =
      $nextMeasureID]]"/>

    <xsl:variable name="initialScoreDef" select="ancestor::mei:score/mei:scoreDef[1]/mei:staffGrp"/>

    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
      <xsl:apply-templates select="$initialScoreDef" mode="resolveScoreDef">
        <xsl:with-param name="staffDefs" select="$staffDefs" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:staffGrp" mode="resolveScoreDef">
    <xsl:copy>
      <xsl:apply-templates select="@* except (@xml:id,@label,@label.abbr)" mode="cleanUp"/>
      <xsl:apply-templates select="child::mei:*" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mei:staffDef" mode="resolveScoreDef">
    <xsl:param name="staffDefs" tunnel="yes"/>
    <xsl:variable name="n" select="@n"/>
    <xsl:variable name="changedDef" select="$staffDefs[@n = $n]"/>
    <xsl:copy-of select="$changedDef"/>
  </xsl:template>

  <xsl:template match="mei:staffDef[not(exists(ancestor::mei:staffGrp)) and
    preceding-sibling::mei:scoreDef]" mode="cleanUp">
    <xsl:variable name="scoreDef" select="preceding-sibling::mei:scoreDef[1]"/>
    <xsl:variable name="nextMeasureID" select="$scoreDef/following-sibling::mei:measure[1]/@xml:id"/>

    <!-- If this staffDef sits between the preceding scoreDef and its following measure, it is handled inside the scoreDef -->
    <xsl:if test="$nextMeasureID != following-sibling::mei:measure[1]/@xml:id">
      <xsl:copy>
        <xsl:apply-templates select="node() | @*" mode="#current"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:staffGrp[ancestor::mei:staffGrp and count(mei:staffGrp) = 1 and
    count(mei:*) = 1]" mode="cleanUp">
    <xsl:apply-templates select="*" mode="#current"/>
  </xsl:template>

  <xsl:template match="mei:scoreDef[not(exists(@* | child::node()))]" mode="cleanUp"/>

  <xsl:template match="node() | @* |processing-instruction()" mode="cleanUp">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="#current"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
