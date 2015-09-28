<?xml version="1.0" encoding="UTF-8"?>

<!--
	
	marc2mei.xsl - XSLT (2.0) stylesheet for transformation of MARC XML to MEI header XML
	
	Perry Roland <pdr4h@virginia.edu>
	Music Library
	University of Virginia
	
	For info on MARC XML, see http://www.loc.gov/marc/marcxml.html
	For info on the MEI header, see http://music-encoding.org
	For info on RISM, see http://www.rism-ch.org
	
	Based on:
	1. https://code.google.com/p/mei-incubator/source/browse/rism2mei/rism2mei-2012.xsl
	by Laurent Pugin <laurent.pugin@rism-ch.org> / Swiss RISM Office
	2. http://oreo.grainger.uiuc.edu/stylesheets/MARC_TEI-twc.xsl
	3. marc2tei.xsl - XSLT (1.0) stylesheet for transformation of MARC XML to TEI header 
	XML (TEI P4) by Greg Murray <gpm2a@virginia.edu> / Digital Library Production Services, 
	University of Virginia Library
	
-->

<xsl:stylesheet version="2.0" xmlns="http://www.music-encoding.org/ns/mei"
  xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:marc="http://www.loc.gov/MARC21/slim" exclude-result-prefixes="marc mei">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" media-type="text/xml"/>

  <!-- ======================================================================= -->
  <!-- PARAMETERS                                                              -->
  <!-- ======================================================================= -->

  <!-- path to rng -->
  <xsl:param name="rng_model_path"/>
  <!-- path to schematron -->
  <xsl:param name="sch_model_path"/>
  <!-- name of agency running the transform -->
  <xsl:param name="agency"/>
  <!-- agency code -->
  <xsl:param name="agency_code"/>
  <!-- output analog attributes -->
  <xsl:param name="analog">true</xsl:param>
  <!-- preserve main entry in file description -->
  <xsl:param name="fileMainEntryOnly">true</xsl:param>
  <!-- preserve main entry in description of work -->
  <xsl:param name="workMainEntryOnly">false</xsl:param>
  <!-- preserve local notes (59x) -->
  <xsl:param name="keepLocalNotes">true</xsl:param>

  <!-- ======================================================================= -->
  <!-- GLOBAL VARIABLES                                                        -->
  <!-- ======================================================================= -->

  <!-- program name -->
  <xsl:variable name="progname">
    <xsl:text>marc2mei.xsl</xsl:text>
  </xsl:variable>

  <!-- program version -->
  <xsl:variable name="version">
    <xsl:text>1.1 beta</xsl:text>
  </xsl:variable>

  <!-- MARC Instruments or Voices Codes -->
  <xsl:variable name="marcMusPerfList">
    <instr code="ba" class="Brass">Horn</instr>
    <instr code="bb" class="Brass">Trumpet</instr>
    <instr code="bc" class="Brass">Cornet</instr>
    <instr code="bd" class="Brass">Trombone</instr>
    <instr code="be" class="Brass">Tuba</instr>
    <instr code="bf" class="Brass">Baritone</instr>
    <instr code="bn" class="Brass">Unspecified brass</instr>
    <instr code="bu" class="Brass">Unknown</instr>
    <instr code="by" class="Brass">Ethnic</instr>
    <instr code="bz" class="Brass">Other brass</instr>
    <instr code="ca" class="Choruses">Mixed chorus</instr>
    <instr code="cb" class="Choruses">Women's chorus</instr>
    <instr code="cc" class="Choruses">Men's chorus</instr>
    <instr code="cd" class="Choruses">Children's chorus</instr>
    <instr code="cn" class="Choruses">Unspecified chorus</instr>
    <instr code="cu" class="Choruses">Unknown chorus</instr>
    <instr code="cy" class="Choruses">Ethnic chorus</instr>
    <instr code="ea" class="Electronic">Synthesizer</instr>
    <instr code="eb" class="Electronic">Tape</instr>
    <instr code="ec" class="Electronic">Computer</instr>
    <instr code="ed" class="Electronic">Ondes Martinot</instr>
    <instr code="en" class="Electronic">Unspecified electronic</instr>
    <instr code="eu" class="Electronic">Unknown electronic</instr>
    <instr code="ez" class="Electronic">Other electronic</instr>
    <instr code="ka" class="Keyboard">Piano</instr>
    <instr code="kb" class="Keyboard">Organ</instr>
    <instr code="kc" class="Keyboard">Harpsichord</instr>
    <instr code="kd" class="Keyboard">Clavichord</instr>
    <instr code="ke" class="Keyboard">Continuo</instr>
    <instr code="kf" class="Keyboard">Celeste</instr>
    <instr code="kn" class="Keyboard">Unspecified keyboard</instr>
    <instr code="ku" class="Keyboard">Unknown keyboard</instr>
    <instr code="ky" class="Keyboard">Ethnic keyboard</instr>
    <instr code="kz" class="Keyboard">Other keyboard</instr>
    <instr code="oa" class="Larger ensemble">Full orchestra</instr>
    <instr code="ob" class="Larger ensemble">Chamber orchestra</instr>
    <instr code="oc" class="Larger ensemble">String orchestra</instr>
    <instr code="od" class="Larger ensemble">Band</instr>
    <instr code="oe" class="Larger ensemble">Dance orchestra</instr>
    <instr code="of" class="Larger ensemble">Brass band</instr>
    <instr code="on" class="Larger ensemble">Unspecified ensemble</instr>
    <instr code="ou" class="Larger ensemble">Unknown ensemble</instr>
    <instr code="oy" class="Larger ensemble">Ethnic ensemble</instr>
    <instr code="oz" class="Larger ensemble">Other ensemble</instr>
    <instr code="pa" class="Percussion">Timpani</instr>
    <instr code="pb" class="Percussion">Xylophone</instr>
    <instr code="pc" class="Percussion">Marimba</instr>
    <instr code="pd" class="Percussion">Drum</instr>
    <instr code="pn" class="Percussion">Unspecified percussion</instr>
    <instr code="pu" class="Percussion">Unknown percussion</instr>
    <instr code="py" class="Percussion">Ethnic percussion</instr>
    <instr code="pz" class="Percussion">Other percussion</instr>
    <instr code="sa" class="Strings, bowed">Violin</instr>
    <instr code="sb" class="Strings, bowed">Viola</instr>
    <instr code="sc" class="Strings, bowed">Violoncello</instr>
    <instr code="sd" class="Strings, bowed">Double bass</instr>
    <instr code="se" class="Strings, bowed">Viol</instr>
    <instr code="sf" class="Strings, bowed">Viola d'amore</instr>
    <instr code="sg" class="Strings, bowed">Viola da gamba</instr>
    <instr code="sn" class="Strings, bowed">Unspecified bowed string</instr>
    <instr code="su" class="Strings, bowed">Unknown bowed string</instr>
    <instr code="sy" class="Strings, bowed">Ethnic bowed string</instr>
    <instr code="sz" class="Strings, bowed">Other bowed string</instr>
    <instr code="ta" class="Strings, plucked">Harp</instr>
    <instr code="tb" class="Strings, plucked">Guitar</instr>
    <instr code="tc" class="Strings, plucked">Lute</instr>
    <instr code="td" class="Strings, plucked">Mandolin</instr>
    <instr code="tn" class="Strings, plucked">Unspecified plucked string</instr>
    <instr code="tu" class="Strings, plucked">Unknown plucked string</instr>
    <instr code="ty" class="Strings, plucked">Ethnic plucked string</instr>
    <instr code="tz" class="Strings, plucked">Other plucked string</instr>
    <instr code="va" class="Voices">Soprano</instr>
    <instr code="vb" class="Voices">Mezzo Soprano</instr>
    <instr code="vc" class="Voices">Alto</instr>
    <instr code="vd" class="Voices">Tenor</instr>
    <instr code="ve" class="Voices">Baritone</instr>
    <instr code="vf" class="Voices">Bass</instr>
    <instr code="vg" class="Voices">Counter Tenor</instr>
    <instr code="vh" class="Voices">High voice</instr>
    <instr code="vi" class="Voices">Medium voice</instr>
    <instr code="vj" class="Voices">Low voice</instr>
    <instr code="vn" class="Voices">Unspecified voice</instr>
    <instr code="vu" class="Voices">Unknown voice</instr>
    <instr code="vy" class="Voices">Ethnic voice</instr>
    <instr code="wa" class="Woodwinds">Flute</instr>
    <instr code="wb" class="Woodwinds">Oboe</instr>
    <instr code="wc" class="Woodwinds">Clarinet</instr>
    <instr code="wd" class="Woodwinds">Bassoon</instr>
    <instr code="we" class="Woodwinds">Piccolo</instr>
    <instr code="wf" class="Woodwinds">English Horn</instr>
    <instr code="wg" class="Woodwinds">Bass clarinet</instr>
    <instr code="wh" class="Woodwinds">Recorder</instr>
    <instr code="wi" class="Woodwinds">Saxophone</instr>
    <instr code="wn" class="Woodwinds">Unspecified woodwind</instr>
    <instr code="wu" class="Woodwinds">Unknown woodwind</instr>
    <instr code="wy" class="Woodwinds">Ethnic woodwind</instr>
    <instr code="wz" class="Woodwinds">Other woodwind</instr>
    <instr code="zn">Unspecified instrument</instr>
    <instr code="zu">Unknown instrument</instr>
  </xsl:variable>

  <!-- IAML Medium of performance codes -->
  <xsl:variable name="iamlMusPerfList">
    <instr code="bah" class="Brass">alphorn</instr>
    <instr code="bbb" class="Brass">bombardino</instr>
    <instr code="bbd" class="Brass">bombardon</instr>
    <instr code="bbh" class="Brass">bersag horn</instr>
    <instr code="bbu" class="Brass">bugle</instr>
    <instr code="bca" class="Brass">carnyx</instr>
    <instr code="bcb" class="Brass">cimbasso</instr>
    <instr code="bch" class="Brass">cow horn</instr>
    <instr code="bcl" class="Brass">clarion</instr>
    <instr code="bco" class="Brass">cornet</instr>
    <instr code="bct" class="Brass">cornett</instr>
    <instr code="bcu" class="Brass">cornu</instr>
    <instr code="bdx" class="Brass">duplex</instr>
    <instr code="beu" class="Brass">euphonium</instr>
    <instr code="bhh" class="Brass">hunting horn</instr>
    <instr code="bho" class="Brass">horn</instr>
    <instr code="bht" class="Brass">herald's trumpet</instr>
    <instr code="bkb" class="Brass">keyed bugle</instr>
    <instr code="blu" class="Brass">lur</instr>
    <instr code="bol" class="Brass">oliphant</instr>
    <instr code="bop" class="Brass">ophicleide</instr>
    <instr code="bph" class="Brass">post horn</instr>
    <instr code="brh" class="Brass">russian horn</instr>
    <instr code="bse" class="Brass">serpent</instr>
    <instr code="bsh" class="Brass">shofar</instr>
    <instr code="bsx" class="Brass">salpinx</instr>
    <instr code="bta" class="Brass">tuba - antique</instr>
    <instr code="btb" class="Brass">trombone</instr>
    <instr code="btr" class="Brass">trumpet</instr>
    <instr code="btu" class="Brass">tuba</instr>
    <instr code="bvb" class="Brass">valved bugle</instr>
    <instr code="bwt" class="Brass">wagner tuba</instr>
    <instr code="bzz" class="Brass">brass - other</instr>
    <instr code="cch" class="Choruses">children's choir</instr>
    <instr code="cme" class="Choruses">men's choir</instr>
    <instr code="cmi" class="Choruses">mixed choir</instr>
    <instr code="cre" class="Choruses">reciting choir</instr>
    <instr code="cun" class="Choruses">choir - unspecified</instr>
    <instr code="cve" class="Choruses">vocal ensemble</instr>
    <instr code="cwo" class="Choruses">women's choir</instr>
    <instr code="czz" class="Choruses">choir - other</instr>
    <instr code="eco" class="Electronic">computer</instr>
    <instr code="ecs" class="Electronic">computerized musical station</instr>
    <instr code="ect" class="Electronic">computerized tape</instr>
    <instr code="eds" class="Electronic">digital space device</instr>
    <instr code="eea" class="Electronic">electro-acoustic device</instr>
    <instr code="eli" class="Electronic">live electronic</instr>
    <instr code="ely" class="Electronic">lyricon</instr>
    <instr code="ema" class="Electronic">ondes Martenot</instr>
    <instr code="eme" class="Electronic">meta-instrument</instr>
    <instr code="emu" class="Electronic">multimedial device</instr>
    <instr code="eos" class="Electronic">oscillator</instr>
    <instr code="esp" class="Electronic">space device</instr>
    <instr code="esy" class="Electronic">synthesizer</instr>
    <instr code="eta" class="Electronic">tape</instr>
    <instr code="eth" class="Electronic">theremin</instr>
    <instr code="eun" class="Electronic">electronic - unspecified</instr>
    <instr code="ezz" class="Electronic">electronic - other</instr>
    <instr code="kab" class="Keyboard">archicembalo</instr>
    <instr code="kac" class="Keyboard">accordion</instr>
    <instr code="kba" class="Keyboard">bandoneon</instr>
    <instr code="kca" class="Keyboard">carillon, with keyboard</instr>
    <instr code="kch" class="Keyboard">chordette</instr>
    <instr code="kcl" class="Keyboard">clavichord</instr>
    <instr code="kco" class="Keyboard">claviorgan</instr>
    <instr code="kcy" class="Keyboard">clavicytherium</instr>
    <instr code="kfp" class="Keyboard">fortepiano</instr>
    <instr code="kgl" class="Keyboard">glockenspiel, with keyboard</instr>
    <instr code="khm" class="Keyboard">harmonium</instr>
    <instr code="khp" class="Keyboard">harpsichord</instr>
    <instr code="kmp" class="Keyboard">melopiano</instr>
    <instr code="kor" class="Keyboard">organ</instr>
    <instr code="kpf" class="Keyboard">piano</instr>
    <instr code="kps" class="Keyboard">plucked string keyboard</instr>
    <instr code="kre" class="Keyboard">regals</instr>
    <instr code="ksi" class="Keyboard">sirenion</instr>
    <instr code="ksp" class="Keyboard">sostenente piano</instr>
    <instr code="kst" class="Keyboard">spinet</instr>
    <instr code="kun" class="Keyboard">keyboard - unspecified</instr>
    <instr code="kvg" class="Keyboard">virginal</instr>
    <instr code="kzz" class="Keyboard">keyboard - other</instr>
    <instr code="mah" class="Miscellaneous">aeolian harp</instr>
    <instr code="mbo" class="Miscellaneous">barrel organ</instr>
    <instr code="mbr" class="Miscellaneous">bullroarer</instr>
    <instr code="mbs" class="Miscellaneous">bass instrument - unspecified</instr>
    <instr code="mbw" class="Miscellaneous">musical bow</instr>
    <instr code="mbx" class="Miscellaneous">musical box</instr>
    <instr code="mcb" class="Miscellaneous">cristal Baschet</instr>
    <instr code="mck" class="Miscellaneous">chekker</instr>
    <instr code="mcl" class="Miscellaneous">musical clock</instr>
    <instr code="mco" class="Miscellaneous">continuo</instr>
    <instr code="mgh" class="Miscellaneous">glassharmonika</instr>
    <instr code="mgt" class="Miscellaneous">glass trumpet</instr>
    <instr code="mha" class="Miscellaneous">harmonica</instr>
    <instr code="mhg" class="Miscellaneous">hurdy-gurdy</instr>
    <instr code="mjh" class="Miscellaneous">jew's harp</instr>
    <instr code="mla" class="Miscellaneous">lamellaphone</instr>
    <instr code="mmc" class="Miscellaneous">monochord</instr>
    <instr code="mme" class="Miscellaneous">melodica</instr>
    <instr code="mmi" class="Miscellaneous">mirliton</instr>
    <instr code="mml" class="Miscellaneous">melodic instrument</instr>
    <instr code="mms" class="Miscellaneous">musical saw</instr>
    <instr code="moc" class="Miscellaneous">ocarina</instr>
    <instr code="mpo" class="Miscellaneous">polyphonic instrument</instr>
    <instr code="mpp" class="Miscellaneous">player piano</instr>
    <instr code="mra" class="Miscellaneous">rabab</instr>
    <instr code="mss" class="Miscellaneous">sound sculpture</instr>
    <instr code="msw" class="Miscellaneous">swanee whistle</instr>
    <instr code="mtf" class="Miscellaneous">tuning-fork</instr>
    <instr code="mui" class="Miscellaneous">instrument - unspecified</instr>
    <instr code="mun" class="Miscellaneous">instrument or voice - unspecified</instr>
    <instr code="mwd" class="Miscellaneous">wind instrument</instr>
    <instr code="mwh" class="Miscellaneous">whistle</instr>
    <instr code="mzz" class="Miscellaneous">other</instr>
    <instr code="oba" class="Ensembles">band</instr>
    <instr code="obi" class="Ensembles">big band</instr>
    <instr code="obr" class="Ensembles">brass band</instr>
    <instr code="ocb" class="Ensembles">cobla</instr>
    <instr code="och" class="Ensembles">chamber orchestra</instr>
    <instr code="oco" class="Ensembles">combo</instr>
    <instr code="odo" class="Ensembles">dance orchestra</instr>
    <instr code="ofu" class="Ensembles">full orchestra</instr>
    <instr code="oga" class="Ensembles">gamelan</instr>
    <instr code="oie" class="Ensembles">instrumental ensemble</instr>
    <instr code="oiv" class="Ensembles">vocal and instrumental ensemble</instr>
    <instr code="oja" class="Ensembles">jazz band</instr>
    <instr code="ope" class="Ensembles">percussion orchestra</instr>
    <instr code="orb" class="Ensembles">ragtime band</instr>
    <instr code="osb" class="Ensembles">steel band</instr>
    <instr code="ost" class="Ensembles">string orchestra</instr>
    <instr code="oun" class="Ensembles">orchestra - unspecified</instr>
    <instr code="owi" class="Ensembles">wind orchestra</instr>
    <instr code="ozz" class="Ensembles">orchestra - other</instr>
    <instr code="pab" class="Percussion">aeolian bells</instr>
    <instr code="pad" class="Percussion">arabian drum</instr>
    <instr code="pag" class="Percussion">agogo</instr>
    <instr code="pan" class="Percussion">anvil</instr>
    <instr code="pbb" class="Percussion">boobams</instr>
    <instr code="pbd" class="Percussion">bass drum</instr>
    <instr code="pbe" class="Percussion">tambourin de béarn</instr>
    <instr code="pbl" class="Percussion">bells</instr>
    <instr code="pbo" class="Percussion">bongos</instr>
    <instr code="pbp" class="Percussion">metal bells plate</instr>
    <instr code="pbr" class="Percussion">bronte</instr>
    <instr code="pca" class="Percussion">castanets</instr>
    <instr code="pcb" class="Percussion">cabaca</instr>
    <instr code="pcc" class="Percussion">chinese cymbals</instr>
    <instr code="pcg" class="Percussion">conga</instr>
    <instr code="pch" class="Percussion">chains</instr>
    <instr code="pci" class="Percussion">cimbalom</instr>
    <instr code="pco" class="Percussion">chocalho</instr>
    <instr code="pcr" class="Percussion">crash cymbal</instr>
    <instr code="pct" class="Percussion">crotales</instr>
    <instr code="pcu" class="Percussion">cuíca</instr>
    <instr code="pcv" class="Percussion">claves</instr>
    <instr code="pcw" class="Percussion">cowbell</instr>
    <instr code="pcy" class="Percussion">cymbal</instr>
    <instr code="pdr" class="Percussion">drum</instr>
    <instr code="pds" class="Percussion">drums</instr>
    <instr code="pfc" class="Percussion">finger cymbals</instr>
    <instr code="pfd" class="Percussion">friction drum</instr>
    <instr code="pfl" class="Percussion">flexatone</instr>
    <instr code="pgl" class="Percussion">glockenspiel</instr>
    <instr code="pgn" class="Percussion">gun</instr>
    <instr code="pgo" class="Percussion">gong</instr>
    <instr code="pgu" class="Percussion">güiro</instr>
    <instr code="pha" class="Percussion">hammer</instr>
    <instr code="phb" class="Percussion">handbell</instr>
    <instr code="phh" class="Percussion">hi-hat</instr>
    <instr code="pir" class="Percussion">intonarumori</instr>
    <instr code="pje" class="Percussion">jembe</instr>
    <instr code="pji" class="Percussion">jingles</instr>
    <instr code="pli" class="Percussion">lithophone</instr>
    <instr code="plj" class="Percussion">lujon</instr>
    <instr code="pmb" class="Percussion">marimba</instr>
    <instr code="pmc" class="Percussion">maracas</instr>
    <instr code="pmd" class="Percussion">military drum</instr>
    <instr code="pme" class="Percussion">metallophone</instr>
    <instr code="pnv" class="Percussion">nail violin</instr>
    <instr code="pra" class="Percussion">ratchett</instr>
    <instr code="prs" class="Percussion">rain stick</instr>
    <instr code="prt" class="Percussion">roto-toms</instr>
    <instr code="psc" class="Percussion">sizzle cymbals</instr>
    <instr code="pse" class="Percussion">sound-effect instrument</instr>
    <instr code="psl" class="Percussion">slit-drum</instr>
    <instr code="psm" class="Percussion">sistrum</instr>
    <instr code="psn" class="Percussion">sirene</instr>
    <instr code="psp" class="Percussion">sandpaper</instr>
    <instr code="pst" class="Percussion">steel drum</instr>
    <instr code="psw" class="Percussion">switch whip</instr>
    <instr code="pta" class="Percussion">tablas</instr>
    <instr code="ptb" class="Percussion">tabor</instr>
    <instr code="ptc" class="Percussion">turkish crescent</instr>
    <instr code="pte" class="Percussion">temple block</instr>
    <instr code="ptg" class="Percussion">tuned gong</instr>
    <instr code="pti" class="Percussion">timpani</instr>
    <instr code="ptl" class="Percussion">triangle</instr>
    <instr code="ptm" class="Percussion">thunder machine</instr>
    <instr code="pto" class="Percussion">tarol</instr>
    <instr code="ptr" class="Percussion">tambourine</instr>
    <instr code="ptt" class="Percussion">tom-tom</instr>
    <instr code="ptx" class="Percussion">txalaparta</instr>
    <instr code="pun" class="Percussion">percussion - unspecified</instr>
    <instr code="pvi" class="Percussion">vibraphone</instr>
    <instr code="pvs" class="Percussion">vibra-slap</instr>
    <instr code="pwh" class="Percussion">whip</instr>
    <instr code="pwm" class="Percussion">wind machine</instr>
    <instr code="pwo" class="Percussion">woodblocks</instr>
    <instr code="pxr" class="Percussion">xylorimba</instr>
    <instr code="pxy" class="Percussion">xylophone</instr>
    <instr code="pza" class="Percussion">zarb</instr>
    <instr code="pzz" class="Percussion">percussion - other</instr>
    <instr code="qce" class="Conductors">live electronic conductor</instr>
    <instr code="qch" class="Conductors">choir conductor, chorus master</instr>
    <instr code="qco" class="Conductors">conductor</instr>
    <instr code="qlc" class="Conductors">light conductor</instr>
    <instr code="qzz" class="Conductors">conductor - other</instr>
    <instr code="sar" class="Strings, bowed">arpeggione</instr>
    <instr code="sba" class="Strings, bowed">baryton</instr>
    <instr code="sbt" class="Strings, bowed">bassett</instr>
    <instr code="sbu" class="Strings, bowed">bumbass</instr>
    <instr code="scr" class="Strings, bowed">crwth</instr>
    <instr code="sdb" class="Strings, bowed">double bass</instr>
    <instr code="sdf" class="Strings, bowed">five-string double bass</instr>
    <instr code="sfi" class="Strings, bowed">fiddle, viol (family)</instr>
    <instr code="sgu" class="Strings, bowed">gusle</instr>
    <instr code="sli" class="Strings, bowed">lira da braccio</instr>
    <instr code="sln" class="Strings, bowed">lirone</instr>
    <instr code="sny" class="Strings, bowed">keyed fiddle</instr>
    <instr code="sob" class="Strings, bowed">octobass</instr>
    <instr code="spo" class="Strings, bowed">kit</instr>
    <instr code="spv" class="Strings, bowed">quinton</instr>
    <instr code="sre" class="Strings, bowed">rebec</instr>
    <instr code="stm" class="Strings, bowed">trumpet marine</instr>
    <instr code="sun" class="Strings, bowed">strings, bowed - unspecified</instr>
    <instr code="sva" class="Strings, bowed">viola</instr>
    <instr code="svc" class="Strings, bowed">cello</instr>
    <instr code="svd" class="Strings, bowed">viola d'amore</instr>
    <instr code="sve" class="Strings, bowed">violone</instr>
    <instr code="svg" class="Strings, bowed">viola da gamba</instr>
    <instr code="svl" class="Strings, bowed">violin</instr>
    <instr code="svp" class="Strings, bowed">viola pomposa</instr>
    <instr code="szz" class="Strings, bowed">strings, bowed - other</instr>
    <instr code="tal" class="Strings, plucked">archlute</instr>
    <instr code="tat" class="Strings, plucked">harp-psaltery</instr>
    <instr code="tbb" class="Strings, plucked">barbitos</instr>
    <instr code="tbi" class="Strings, plucked">biwa</instr>
    <instr code="tbj" class="Strings, plucked">banjo</instr>
    <instr code="tbl" class="Strings, plucked">balalaika</instr>
    <instr code="tbo" class="Strings, plucked">bouzouki</instr>
    <instr code="tch" class="Strings, plucked">chitarrone</instr>
    <instr code="tci" class="Strings, plucked">cittern</instr>
    <instr code="tcs" class="Strings, plucked">colascione</instr>
    <instr code="tct" class="Strings, plucked">citole</instr>
    <instr code="tcz" class="Strings, plucked">cobza</instr>
    <instr code="tgu" class="Strings, plucked">guitar</instr>
    <instr code="tha" class="Strings, plucked">harp</instr>
    <instr code="thg" class="Strings, plucked">hawaiian guitar</instr>
    <instr code="tih" class="Strings, plucked">Irish harp</instr>
    <instr code="tkh" class="Strings, plucked">kithara</instr>
    <instr code="tko" class="Strings, plucked">kora</instr>
    <instr code="tkt" class="Strings, plucked">koto</instr>
    <instr code="tlf" class="Strings, plucked">lute (family)</instr>
    <instr code="tlg" class="Strings, plucked">lyre-guitar</instr>
    <instr code="tlu" class="Strings, plucked">lute</instr>
    <instr code="tma" class="Strings, plucked">mandolin</instr>
    <instr code="tmd" class="Strings, plucked">mandore</instr>
    <instr code="tpi" class="Strings, plucked">pipa</instr>
    <instr code="tps" class="Strings, plucked">psaltery, plucked</instr>
    <instr code="tpx" class="Strings, plucked">phorminx</instr>
    <instr code="tqa" class="Strings, plucked">qanun</instr>
    <instr code="tsh" class="Strings, plucked">shamisen</instr>
    <instr code="tsi" class="Strings, plucked">sitār</instr>
    <instr code="tth" class="Strings, plucked">theorbo</instr>
    <instr code="ttn" class="Strings, plucked">tanbur</instr>
    <instr code="tud" class="Strings, plucked">'ud</instr>
    <instr code="tuk" class="Strings, plucked">ukulele</instr>
    <instr code="tun" class="Strings, plucked">strings, plucked - unspecified</instr>
    <instr code="tvi" class="Strings, plucked">vihuela</instr>
    <instr code="tzi" class="Strings, plucked">zither</instr>
    <instr code="tzz" class="Strings, plucked">strings, plucked - other</instr>
    <instr code="val" class="Voices">alto</instr>
    <instr code="vbr" class="Voices">baritone</instr>
    <instr code="vbs" class="Voices">bass</instr>
    <instr code="vca" class="Voices">child alto</instr>
    <instr code="vcl" class="Voices">contratenor altus</instr>
    <instr code="vcs" class="Voices">child soprano</instr>
    <instr code="vct" class="Voices">countertenor</instr>
    <instr code="vcv" class="Voices">child voice</instr>
    <instr code="vhc" class="Voices">haute-contre</instr>
    <instr code="vma" class="Voices">man's voice</instr>
    <instr code="vms" class="Voices">mezzosoprano</instr>
    <instr code="vrc" class="Voices">reciting child's voice</instr>
    <instr code="vre" class="Voices">reciting voice</instr>
    <instr code="vrm" class="Voices">reciting man's voice</instr>
    <instr code="vrw" class="Voices">reciting woman's voice</instr>
    <instr code="vso" class="Voices">soprano</instr>
    <instr code="vte" class="Voices">tenor</instr>
    <instr code="vun" class="Voices">voice - unspecified</instr>
    <instr code="vvg" class="Voices">vagans</instr>
    <instr code="vwo" class="Voices">woman's voice</instr>
    <instr code="vzz" class="Voices">voice - other</instr>
    <instr code="wau" class="Woodwinds">aulos</instr>
    <instr code="wba" class="Woodwinds">bassoon</instr>
    <instr code="wbh" class="Woodwinds">basset-horn</instr>
    <instr code="wbn" class="Woodwinds">bassanello</instr>
    <instr code="wbp" class="Woodwinds">bagpipe</instr>
    <instr code="wch" class="Woodwinds">chalumeau</instr>
    <instr code="wcl" class="Woodwinds">clarinet</instr>
    <instr code="wcm" class="Woodwinds">ciaramella</instr>
    <instr code="wcr" class="Woodwinds">cromorne</instr>
    <instr code="wdb" class="Woodwinds">double bassoon</instr>
    <instr code="wdi" class="Woodwinds">didjeridu</instr>
    <instr code="wdp" class="Woodwinds">doppione</instr>
    <instr code="wdu" class="Woodwinds">dulcian</instr>
    <instr code="wdv" class="Woodwinds">dvojnice</instr>
    <instr code="weh" class="Woodwinds">english horn</instr>
    <instr code="wfa" class="Woodwinds">flauto d'amore</instr>
    <instr code="wfg" class="Woodwinds">flageolet</instr>
    <instr code="wfi" class="Woodwinds">fife</instr>
    <instr code="wfl" class="Woodwinds">flute</instr>
    <instr code="wga" class="Woodwinds">tabor pipe</instr>
    <instr code="wge" class="Woodwinds">gemshorn</instr>
    <instr code="whp" class="Woodwinds">hornpipe</instr>
    <instr code="wmo" class="Woodwinds">mouth organ</instr>
    <instr code="wmu" class="Woodwinds">musette</instr>
    <instr code="wna" class="Woodwinds">ney</instr>
    <instr code="woa" class="Woodwinds">oboe d'amore</instr>
    <instr code="wob" class="Woodwinds">oboe</instr>
    <instr code="woh" class="Woodwinds">oboe da caccia</instr>
    <instr code="wpi" class="Woodwinds">piccolo</instr>
    <instr code="wpo" class="Woodwinds">pommer</instr>
    <instr code="wpp" class="Woodwinds">panpipes</instr>
    <instr code="wra" class="Woodwinds">racket</instr>
    <instr code="wre" class="Woodwinds">recorder</instr>
    <instr code="wro" class="Woodwinds">rothophone</instr>
    <instr code="wsa" class="Woodwinds">saxophone</instr>
    <instr code="wsh" class="Woodwinds">shakuhachi</instr>
    <instr code="wsn" class="Woodwinds">surnāy</instr>
    <instr code="wsr" class="Woodwinds">sarrusophone</instr>
    <instr code="wsu" class="Woodwinds">sordun</instr>
    <instr code="wun" class="Woodwinds">woodwind - unspecified</instr>
    <instr code="wvu" class="Woodwinds">vox humana</instr>
    <instr code="wzz" class="Woodwinds">woodwind - other</instr>
    <instr code="zab" class="Other performers">acrobat</instr>
    <instr code="zac" class="Other performers">child actor</instr>
    <instr code="zas" class="Other performers">silent actor</instr>
    <instr code="zat" class="Other performers">actor</instr>
    <instr code="zaw" class="Other performers">actress</instr>
    <instr code="zda" class="Other performers">dancer</instr>
    <instr code="zel" class="Other performers">light engineer</instr>
    <instr code="zes" class="Other performers">sound engineer</instr>
    <instr code="zju" class="Other performers">juggler</instr>
    <instr code="zmi" class="Other performers">mime</instr>
    <instr code="zwp" class="Other performers">walk-on part</instr>
    <instr code="zzz" class="Other performers">performer - other</instr>
  </xsl:variable>

  <!-- MARC Code List for Languages -->
  <xsl:variable name="marcLangList">
    <lang code="aar">Afar</lang>
    <lang code="abk">Abkhaz</lang>
    <lang code="ace">Achinese</lang>
    <lang code="ach">Acoli</lang>
    <lang code="ada">Adangme</lang>
    <lang code="ady">Adygei</lang>
    <lang code="afa">Afroasiatic (Other)</lang>
    <lang code="afh">Afrihili (Artificial language)</lang>
    <lang code="afr">Afrikaans</lang>
    <lang code="ain">Ainu</lang>
    <lang code="ajm" status="discontinued">Aljamía</lang>
    <lang code="aka">Akan</lang>
    <lang code="akk">Akkadian</lang>
    <lang code="alb">Albanian</lang>
    <lang code="ale">Aleut</lang>
    <lang code="alg">Algonquian (Other)</lang>
    <lang code="alt">Altai</lang>
    <lang code="amh">Amharic</lang>
    <lang code="ang">English, Old (ca. 450-1100)</lang>
    <lang code="anp">Angika</lang>
    <lang code="apa">Apache languages</lang>
    <lang code="ara">Arabic</lang>
    <lang code="arc">Aramaic</lang>
    <lang code="arg">Aragonese</lang>
    <lang code="arm">Armenian</lang>
    <lang code="arn">Mapuche</lang>
    <lang code="arp">Arapaho</lang>
    <lang code="art">Artificial (Other)</lang>
    <lang code="arw">Arawak</lang>
    <lang code="asm">Assamese</lang>
    <lang code="ast">Bable</lang>
    <lang code="ath">Athapascan (Other)</lang>
    <lang code="aus">Australian languages</lang>
    <lang code="ava">Avaric</lang>
    <lang code="ave">Avestan</lang>
    <lang code="awa">Awadhi</lang>
    <lang code="aym">Aymara</lang>
    <lang code="aze">Azerbaijani</lang>
    <lang code="bad">Banda languages</lang>
    <lang code="bai">Bamileke languages</lang>
    <lang code="bak">Bashkir</lang>
    <lang code="bal">Baluchi</lang>
    <lang code="bam">Bambara</lang>
    <lang code="ban">Balinese</lang>
    <lang code="baq">Basque</lang>
    <lang code="bas">Basa</lang>
    <lang code="bat">Baltic (Other)</lang>
    <lang code="bej">Beja</lang>
    <lang code="bel">Belarusian</lang>
    <lang code="bem">Bemba</lang>
    <lang code="ben">Bengali</lang>
    <lang code="ber">Berber (Other)</lang>
    <lang code="bho">Bhojpuri</lang>
    <lang code="bih">Bihari (Other) </lang>
    <lang code="bik">Bikol</lang>
    <lang code="bin">Edo</lang>
    <lang code="bis">Bislama</lang>
    <lang code="bla">Siksika</lang>
    <lang code="bnt">Bantu (Other)</lang>
    <lang code="bos">Bosnian</lang>
    <lang code="bra">Braj</lang>
    <lang code="bre">Breton</lang>
    <lang code="btk">Batak</lang>
    <lang code="bua">Buriat</lang>
    <lang code="bug">Bugis</lang>
    <lang code="bul">Bulgarian</lang>
    <lang code="bur">Burmese</lang>
    <lang code="byn">Bilin</lang>
    <lang code="cad">Caddo</lang>
    <lang code="cai">Central American Indian (Other)</lang>
    <lang code="cam" status="discontinued">Khmer</lang>
    <lang code="car">Carib</lang>
    <lang code="cat">Catalan</lang>
    <lang code="cau">Caucasian (Other)</lang>
    <lang code="ceb">Cebuano</lang>
    <lang code="cel">Celtic (Other)</lang>
    <lang code="cha">Chamorro</lang>
    <lang code="chb">Chibcha</lang>
    <lang code="che">Chechen</lang>
    <lang code="chg">Chagatai</lang>
    <lang code="chi">Chinese</lang>
    <lang code="chk">Chuukese</lang>
    <lang code="chm">Mari</lang>
    <lang code="chn">Chinook jargon</lang>
    <lang code="cho">Choctaw</lang>
    <lang code="chp">Chipewyan</lang>
    <lang code="chr">Cherokee</lang>
    <lang code="chu">Church Slavic</lang>
    <lang code="chv">Chuvash</lang>
    <lang code="chy">Cheyenne</lang>
    <lang code="cmc">Chamic languages</lang>
    <lang code="cop">Coptic</lang>
    <lang code="cor">Cornish</lang>
    <lang code="cos">Corsican</lang>
    <lang code="cpe">Creoles and Pidgins, English-based (Other)</lang>
    <lang code="cpf">Creoles and Pidgins, French-based (Other)</lang>
    <lang code="cpp">Creoles and Pidgins, Portuguese-based (Other)</lang>
    <lang code="cre">Cree</lang>
    <lang code="crh">Crimean Tatar</lang>
    <lang code="crp">Creoles and Pidgins (Other)</lang>
    <lang code="csb">Kashubian</lang>
    <lang code="cus">Cushitic (Other)</lang>
    <lang code="cze">Czech</lang>
    <lang code="dak">Dakota</lang>
    <lang code="dan">Danish</lang>
    <lang code="dar">Dargwa</lang>
    <lang code="day">Dayak</lang>
    <lang code="del">Delaware</lang>
    <lang code="den">Slavey</lang>
    <lang code="dgr">Dogrib</lang>
    <lang code="din">Dinka</lang>
    <lang code="div">Divehi</lang>
    <lang code="doi">Dogri</lang>
    <lang code="dra">Dravidian (Other)</lang>
    <lang code="dsb">Lower Sorbian</lang>
    <lang code="dua">Duala</lang>
    <lang code="dum">Dutch, Middle (ca. 1050-1350)</lang>
    <lang code="dut">Dutch</lang>
    <lang code="dyu">Dyula</lang>
    <lang code="dzo">Dzongkha</lang>
    <lang code="efi">Efik</lang>
    <lang code="egy">Egyptian</lang>
    <lang code="eka">Ekajuk</lang>
    <lang code="elx">Elamite</lang>
    <lang code="eng">English</lang>
    <lang code="enm">English, Middle (1100-1500)</lang>
    <lang code="epo">Esperanto</lang>
    <lang code="esk" status="discontinued">Eskimo languages</lang>
    <lang code="esp" status="discontinued">Esperanto</lang>
    <lang code="est">Estonian</lang>
    <lang code="eth" status="discontinued">Ethiopic</lang>
    <lang code="ewe">Ewe</lang>
    <lang code="ewo">Ewondo</lang>
    <lang code="fan">Fang</lang>
    <lang code="fao">Faroese</lang>
    <lang code="far" status="discontinued">Faroese</lang>
    <lang code="fat">Fanti</lang>
    <lang code="fij">Fijian</lang>
    <lang code="fil">Filipino</lang>
    <lang code="fin">Finnish</lang>
    <lang code="fiu">Finno-Ugrian (Other)</lang>
    <lang code="fon">Fon</lang>
    <lang code="fre">French</lang>
    <lang code="fri" status="discontinued">Frisian</lang>
    <lang code="frm">French, Middle (ca. 1300-1600)</lang>
    <lang code="fro">French, Old (ca. 842-1300)</lang>
    <lang code="frr">North Frisian</lang>
    <lang code="frs">East Frisian</lang>
    <lang code="fry">Frisian</lang>
    <lang code="ful">Fula</lang>
    <lang code="fur">Friulian</lang>
    <lang code="gaa">Gã</lang>
    <lang code="gae" status="discontinued">Scottish Gaelix</lang>
    <lang code="gag" status="discontinued">Galician</lang>
    <lang code="gal" status="discontinued">Oromo</lang>
    <lang code="gay">Gayo</lang>
    <lang code="gba">Gbaya</lang>
    <lang code="gem">Germanic (Other)</lang>
    <lang code="geo">Georgian</lang>
    <lang code="ger">German</lang>
    <lang code="gez">Ethiopic</lang>
    <lang code="gil">Gilbertese</lang>
    <lang code="gla">Scottish Gaelic</lang>
    <lang code="gle">Irish</lang>
    <lang code="glg">Galician</lang>
    <lang code="glv">Manx</lang>
    <lang code="gmh">German, Middle High (ca. 1050-1500)</lang>
    <lang code="goh">German, Old High (ca. 750-1050)</lang>
    <lang code="gon">Gondi</lang>
    <lang code="gor">Gorontalo</lang>
    <lang code="got">Gothic</lang>
    <lang code="grb">Grebo</lang>
    <lang code="grc">Greek, Ancient (to 1453)</lang>
    <lang code="gre">Greek, Modern (1453-)</lang>
    <lang code="grn">Guarani</lang>
    <lang code="gsw">Swiss German</lang>
    <lang code="gua" status="discontinued">Guarani</lang>
    <lang code="guj">Gujarati</lang>
    <lang code="gwi">Gwich'in</lang>
    <lang code="hai">Haida</lang>
    <lang code="hat">Haitian French Creole</lang>
    <lang code="hau">Hausa</lang>
    <lang code="haw">Hawaiian</lang>
    <lang code="heb">Hebrew</lang>
    <lang code="her">Herero</lang>
    <lang code="hil">Hiligaynon</lang>
    <lang code="him">Western Pahari languages</lang>
    <lang code="hin">Hindi</lang>
    <lang code="hit">Hittite</lang>
    <lang code="hmn">Hmong</lang>
    <lang code="hmo">Hiri Motu</lang>
    <lang code="hrv">Croatian</lang>
    <lang code="hsb">Upper Sorbian</lang>
    <lang code="hun">Hungarian</lang>
    <lang code="hup">Hupa</lang>
    <lang code="iba">Iban</lang>
    <lang code="ibo">Igbo</lang>
    <lang code="ice">Icelandic</lang>
    <lang code="ido">Ido</lang>
    <lang code="iii">Sichuan Yi</lang>
    <lang code="ijo">Ijo</lang>
    <lang code="iku">Inuktitut</lang>
    <lang code="ile">Interlingue</lang>
    <lang code="ilo">Iloko</lang>
    <lang code="ina">Interlingua (International Auxiliary Language Association)</lang>
    <lang code="inc">Indic (Other)</lang>
    <lang code="ind">Indonesian</lang>
    <lang code="ine">Indo-European (Other)</lang>
    <lang code="inh">Ingush</lang>
    <lang code="int" status="discontinued">Interlingua (International Auxiliary Language
      Association)</lang>
    <lang code="ipk">Inupiaq</lang>
    <lang code="ira">Iranian (Other)</lang>
    <lang code="iri" status="discontinued">Irish</lang>
    <lang code="iro">Iroquoian (Other)</lang>
    <lang code="ita">Italian</lang>
    <lang code="jav">Javanese</lang>
    <lang code="jbo">Lojban (Artificial language)</lang>
    <lang code="jpn">Japanese</lang>
    <lang code="jpr">Judeo-Persian</lang>
    <lang code="jrb">Judeo-Arabic</lang>
    <lang code="kaa">Kara-Kalpak</lang>
    <lang code="kab">Kabyle</lang>
    <lang code="kac">Kachin</lang>
    <lang code="kal">Kalâtdlisut</lang>
    <lang code="kam">Kamba</lang>
    <lang code="kan">Kannada</lang>
    <lang code="kar">Karen languages</lang>
    <lang code="kas">Kashmiri</lang>
    <lang code="kau">Kanuri</lang>
    <lang code="kaw">Kawi</lang>
    <lang code="kaz">Kazakh</lang>
    <lang code="kbd">Kabardian</lang>
    <lang code="kha">Khasi</lang>
    <lang code="khi">Khoisan (Other)</lang>
    <lang code="khm">Khmer</lang>
    <lang code="kho">Khotanese</lang>
    <lang code="kik">Kikuyu</lang>
    <lang code="kin">Kinyarwanda</lang>
    <lang code="kir">Kyrgyz</lang>
    <lang code="kmb">Kimbundu</lang>
    <lang code="kok">Konkani</lang>
    <lang code="kom">Komi</lang>
    <lang code="kon">Kongo</lang>
    <lang code="kor">Korean</lang>
    <lang code="kos">Kosraean</lang>
    <lang code="kpe">Kpelle</lang>
    <lang code="krc">Karachay-Balkar</lang>
    <lang code="krl">Karelian</lang>
    <lang code="kro">Kru (Other)</lang>
    <lang code="kru">Kurukh</lang>
    <lang code="kua">Kuanyama</lang>
    <lang code="kum">Kumyk</lang>
    <lang code="kur">Kurdish</lang>
    <lang code="kus" status="discontinued">Kusaie</lang>
    <lang code="kut">Kootenai</lang>
    <lang code="lad">Ladino</lang>
    <lang code="lah">Lahndā</lang>
    <lang code="lam">Lamba (Zambia and Congo)</lang>
    <lang code="lan" status="discontinued">Occitan (post 1500)</lang>
    <lang code="lao">Lao</lang>
    <lang code="lap" status="discontinued">Sami</lang>
    <lang code="lat">Latin</lang>
    <lang code="lav">Latvian</lang>
    <lang code="lez">Lezgian</lang>
    <lang code="lim">Limburgish</lang>
    <lang code="lin">Lingala</lang>
    <lang code="lit">Lithuanian</lang>
    <lang code="lol">Mongo-Nkundu</lang>
    <lang code="loz">Lozi</lang>
    <lang code="ltz">Luxembourgish</lang>
    <lang code="lua">Luba-Lulua</lang>
    <lang code="lub">Luba-Katanga</lang>
    <lang code="lug">Ganda</lang>
    <lang code="lui">Luiseño</lang>
    <lang code="lun">Lunda</lang>
    <lang code="luo">Luo (Kenya and Tanzania)</lang>
    <lang code="lus">Lushai</lang>
    <lang code="mac">Macedonian</lang>
    <lang code="mad">Madurese</lang>
    <lang code="mag">Magahi</lang>
    <lang code="mah">Marshallese</lang>
    <lang code="mai">Maithili</lang>
    <lang code="mak">Makasar</lang>
    <lang code="mal">Malayalam</lang>
    <lang code="man">Mandingo</lang>
    <lang code="mao">Maori</lang>
    <lang code="map">Austronesian (Other)</lang>
    <lang code="mar">Marathi</lang>
    <lang code="mas">Maasai</lang>
    <lang code="max" status="discontinued">Manx</lang>
    <lang code="may">Malay</lang>
    <lang code="mdf">Moksha</lang>
    <lang code="mdr">Mandar</lang>
    <lang code="men">Mende</lang>
    <lang code="mga">Irish, Middle (ca. 1100-1550)</lang>
    <lang code="mic">Micmac</lang>
    <lang code="min">Minangkabau</lang>
    <lang code="mis">Miscellaneous languages</lang>
    <lang code="mkh">Mon-Khmer (Other)</lang>
    <lang code="mla" status="discontinued">Malagasy</lang>
    <lang code="mlg">Malagasy</lang>
    <lang code="mlt">Maltese</lang>
    <lang code="mnc">Manchu</lang>
    <lang code="mni">Manipuri</lang>
    <lang code="mno">Manobo languages</lang>
    <lang code="moh">Mohawk</lang>
    <lang code="mol" status="discontinued">Moldavian</lang>
    <lang code="mon">Mongolian</lang>
    <lang code="mos">Mooré</lang>
    <lang code="mul">Multiple languages</lang>
    <lang code="mun">Munda (Other)</lang>
    <lang code="mus">Creek</lang>
    <lang code="mwl">Mirandese</lang>
    <lang code="mwr">Marwari</lang>
    <lang code="myn">Mayan languages</lang>
    <lang code="myv">Erzya</lang>
    <lang code="nah">Nahuatl</lang>
    <lang code="nai">North American Indian (Other)</lang>
    <lang code="nap">Neapolitan Italian</lang>
    <lang code="nau">Nauru</lang>
    <lang code="nav">Navajo</lang>
    <lang code="nbl">Ndebele (South Africa)</lang>
    <lang code="nde">Ndebele (Zimbabwe)</lang>
    <lang code="ndo">Ndonga</lang>
    <lang code="nds">Low German</lang>
    <lang code="nep">Nepali</lang>
    <lang code="new">Newari</lang>
    <lang code="nia">Nias</lang>
    <lang code="nic">Niger-Kordofanian (Other)</lang>
    <lang code="niu">Niuean</lang>
    <lang code="nno">Norwegian (Nynorsk)</lang>
    <lang code="nob">Norwegian (Bokmål)</lang>
    <lang code="nog">Nogai</lang>
    <lang code="non">Old Norse</lang>
    <lang code="nor">Norwegian</lang>
    <lang code="nqo">N'Ko</lang>
    <lang code="nso">Northern Sotho</lang>
    <lang code="nub">Nubian languages</lang>
    <lang code="nwc">Newari, Old</lang>
    <lang code="nya">Nyanja</lang>
    <lang code="nym">Nyamwezi</lang>
    <lang code="nyn">Nyankole</lang>
    <lang code="nyo">Nyoro</lang>
    <lang code="nzi">Nzima</lang>
    <lang code="oci">Occitan (post-1500)</lang>
    <lang code="oji">Ojibwa</lang>
    <lang code="ori">Oriya</lang>
    <lang code="orm">Oromo</lang>
    <lang code="osa">Osage</lang>
    <lang code="oss">Ossetic</lang>
    <lang code="ota">Turkish, Ottoman</lang>
    <lang code="oto">Otomian languages</lang>
    <lang code="paa">Papuan (Other)</lang>
    <lang code="pag">Pangasinan</lang>
    <lang code="pal">Pahlavi</lang>
    <lang code="pam">Pampanga</lang>
    <lang code="pan">Panjabi</lang>
    <lang code="pap">Papiamento</lang>
    <lang code="pau">Palauan</lang>
    <lang code="peo">Old Persian (ca. 600-400 B.C.)</lang>
    <lang code="per">Persian</lang>
    <lang code="phi">Philippine (Other)</lang>
    <lang code="phn">Phoenician</lang>
    <lang code="pli">Pali</lang>
    <lang code="pol">Polish</lang>
    <lang code="pon">Pohnpeian</lang>
    <lang code="por">Portuguese</lang>
    <lang code="pra">Prakrit languages</lang>
    <lang code="pro">Provençal (to 1500)</lang>
    <lang code="pus">Pushto</lang>
    <lang code="que">Quechua</lang>
    <lang code="raj">Rajasthani</lang>
    <lang code="rap">Rapanui</lang>
    <lang code="rar">Rarotongan</lang>
    <lang code="roa">Romance (Other)</lang>
    <lang code="roh">Raeto-Romance</lang>
    <lang code="rom">Romani</lang>
    <lang code="rum">Romanian</lang>
    <lang code="run">Rundi</lang>
    <lang code="rup">Aromanian</lang>
    <lang code="rus">Russian</lang>
    <lang code="sad">Sandawe</lang>
    <lang code="sag">Sango (Ubangi Creole)</lang>
    <lang code="sah">Yakut</lang>
    <lang code="sai">South American Indian (Other)</lang>
    <lang code="sal">Salishan languages</lang>
    <lang code="sam">Samaritan Aramaic</lang>
    <lang code="san">Sanskrit</lang>
    <lang code="sao" status="discontinued">Samoan</lang>
    <lang code="sas">Sasak</lang>
    <lang code="sat">Santali</lang>
    <lang code="scc" status="discontinued">Serbian</lang>
    <lang code="scn">Sicilian Italian</lang>
    <lang code="sco">Scots</lang>
    <lang code="scr" status="discontinued">Croatian</lang>
    <lang code="sel">Selkup</lang>
    <lang code="sem">Semitic (Other)</lang>
    <lang code="sga">Irish, Old (to 1100)</lang>
    <lang code="sgn">Sign languages</lang>
    <lang code="shn">Shan</lang>
    <lang code="sho" status="discontinued">Shona</lang>
    <lang code="sid">Sidamo</lang>
    <lang code="sin">Sinhalese</lang>
    <lang code="sio">Siouan (Other)</lang>
    <lang code="sit">Sino-Tibetan (Other)</lang>
    <lang code="sla">Slavic (Other)</lang>
    <lang code="slo">Slovak</lang>
    <lang code="slv">Slovenian</lang>
    <lang code="sma">Southern Sami</lang>
    <lang code="sme">Northern Sami</lang>
    <lang code="smi">Sami</lang>
    <lang code="smj">Lule Sami</lang>
    <lang code="smn">Inari Sami</lang>
    <lang code="smo">Samoan</lang>
    <lang code="sms">Skolt Sami</lang>
    <lang code="sna">Shona</lang>
    <lang code="snd">Sindhi</lang>
    <lang code="snh" status="discontinued">Sinhalese</lang>
    <lang code="snk">Soninke</lang>
    <lang code="sog">Sogdian</lang>
    <lang code="som">Somali</lang>
    <lang code="son">Songhai</lang>
    <lang code="sot">Sotho</lang>
    <lang code="spa">Spanish</lang>
    <lang code="srd">Sardinian</lang>
    <lang code="srn">Sranan</lang>
    <lang code="srp">Serbian</lang>
    <lang code="srr">Serer</lang>
    <lang code="ssa">Nilo-Saharan (Other)</lang>
    <lang code="sso" status="discontinued">Sotho</lang>
    <lang code="ssw">Swazi</lang>
    <lang code="suk">Sukuma</lang>
    <lang code="sun">Sundanese</lang>
    <lang code="sus">Susu</lang>
    <lang code="sux">Sumerian</lang>
    <lang code="swa">Swahili</lang>
    <lang code="swe">Swedish</lang>
    <lang code="swz" status="discontinued">Swazi</lang>
    <lang code="syc">Syriac</lang>
    <lang code="syr">Syriac, Modern</lang>
    <lang code="tag" status="discontinued">Tagalog</lang>
    <lang code="tah">Tahitian</lang>
    <lang code="tai">Tai (Other)</lang>
    <lang code="taj" status="discontinued">Tajik</lang>
    <lang code="tam">Tamil</lang>
    <lang code="tar" status="discontinued">Tatar</lang>
    <lang code="tat">Tatar</lang>
    <lang code="tel">Telugu</lang>
    <lang code="tem">Temne</lang>
    <lang code="ter">Terena</lang>
    <lang code="tet">Tetum</lang>
    <lang code="tgk">Tajik</lang>
    <lang code="tgl">Tagalog</lang>
    <lang code="tha">Thai</lang>
    <lang code="tib">Tibetan</lang>
    <lang code="tig">Tigré</lang>
    <lang code="tir">Tigrinya</lang>
    <lang code="tiv">Tiv</lang>
    <lang code="tkl">Tokelauan</lang>
    <lang code="tlh">Klingon (Artificial language)</lang>
    <lang code="tli">Tlingit</lang>
    <lang code="tmh">Tamashek</lang>
    <lang code="tog">Tonga (Nyasa)</lang>
    <lang code="ton">Tongan</lang>
    <lang code="tpi">Tok Pisin</lang>
    <lang code="tru" status="discontinued">Truk</lang>
    <lang code="tsi">Tsimshian</lang>
    <lang code="tsn">Tswana</lang>
    <lang code="tso">Tsonga</lang>
    <lang code="tsw" status="discontinued">Tswana</lang>
    <lang code="tuk">Turkmen</lang>
    <lang code="tum">Tumbuka</lang>
    <lang code="tup">Tupi languages</lang>
    <lang code="tur">Turkish</lang>
    <lang code="tut">Altaic (Other)</lang>
    <lang code="tvl">Tuvaluan</lang>
    <lang code="twi">Twi</lang>
    <lang code="tyv">Tuvinian</lang>
    <lang code="udm">Udmurt</lang>
    <lang code="uga">Ugaritic</lang>
    <lang code="uig">Uighur</lang>
    <lang code="ukr">Ukrainian</lang>
    <lang code="umb">Umbundu</lang>
    <lang code="und">Undetermined</lang>
    <lang code="urd">Urdu</lang>
    <lang code="uzb">Uzbek</lang>
    <lang code="vai">Vai</lang>
    <lang code="ven">Venda</lang>
    <lang code="vie">Vietnamese</lang>
    <lang code="vol">Volapük</lang>
    <lang code="vot">Votic</lang>
    <lang code="wak">Wakashan languages</lang>
    <lang code="wal">Wolayta</lang>
    <lang code="war">Waray</lang>
    <lang code="was">Washoe</lang>
    <lang code="wel">Welsh</lang>
    <lang code="wen">Sorbian (Other)</lang>
    <lang code="wln">Walloon</lang>
    <lang code="wol">Wolof</lang>
    <lang code="xal">Oirat</lang>
    <lang code="xho">Xhosa</lang>
    <lang code="yao">Yao (Africa)</lang>
    <lang code="yap">Yapese</lang>
    <lang code="yid">Yiddish</lang>
    <lang code="yor">Yoruba</lang>
    <lang code="ypk">Yupik languages</lang>
    <lang code="zap">Zapotec</lang>
    <lang code="zbl">Blissymbolics</lang>
    <lang code="zen">Zenaga</lang>
    <lang code="zha">Zhuang</lang>
    <lang code="znd">Zande languages</lang>
    <lang code="zul">Zulu</lang>
    <lang code="zun">Zuni</lang>
    <lang code="zxx">No linguistic content</lang>
    <lang code="zza">Zaza</lang>
  </xsl:variable>

  <!-- MARC Musical Form codes -->
  <xsl:variable name="marcFormList">
    <form code="an">anthems</form>
    <form code="bd">ballads</form>
    <form code="bg">bluegrass music</form>
    <form code="bl">blues</form>
    <form code="bt">ballets</form>
    <form code="ca">chaconnes</form>
    <form code="cb">chants, Other religions</form>
    <form code="cc">chant, Christian</form>
    <form code="cg">concerti grossi</form>
    <form code="ch">chorales</form>
    <form code="cl">chorale preludes</form>
    <form code="cn">canons and rounds</form>
    <form code="co">concertos</form>
    <form code="cp">chansons, polyphonic</form>
    <form code="cr">carols</form>
    <form code="cs">chance compositions</form>
    <form code="ct">cantatas</form>
    <form code="cy">country music</form>
    <form code="cz">canzonas</form>
    <form code="df">dance forms</form>
    <form code="dv">divertimentos, serenades, cassations, divertissements, and notturni</form>
    <form code="fg">fugues</form>
    <form code="fl">flamenco</form>
    <form code="fm">folk music</form>
    <form code="ft">fantasias</form>
    <form code="gm">gospel music</form>
    <form code="hy">hymns</form>
    <form code="jz">jazz</form>
    <form code="mc">musical revues and comedies</form>
    <form code="md">madrigals</form>
    <form code="mi">minuets</form>
    <form code="mo">motets</form>
    <form code="mp">motion picture music</form>
    <form code="mr">marches</form>
    <form code="ms">masses</form>
    <form code="mu">multiple forms</form>
    <form code="mz">mazurkas</form>
    <form code="nc">nocturnes</form>
    <form code="nn">not applicable</form>
    <form code="op">operas</form>
    <form code="or">oratorios</form>
    <form code="ov">overtures</form>
    <form code="pg">program music</form>
    <form code="pm">passion music</form>
    <form code="po">polonaises</form>
    <form code="pp">popular music</form>
    <form code="pr">preludes</form>
    <form code="ps">passacaglias</form>
    <form code="pt">part-songs</form>
    <form code="pv">pavans</form>
    <form code="rc">rock music</form>
    <form code="rd">rondos</form>
    <form code="rg">ragtime music</form>
    <form code="ri">ricercars</form>
    <form code="rp">rhapsodies</form>
    <form code="rq">requiems</form>
    <form code="sd">square dance music</form>
    <form code="sg">songs</form>
    <form code="sn">sonatas</form>
    <form code="sp">symphonic poems</form>
    <form code="st">studies and exercises</form>
    <form code="su">suites</form>
    <form code="sy">symphonies</form>
    <form code="tc">toccatas</form>
    <form code="tl">teatro lirico</form>
    <form code="ts">trio-sonatas</form>
    <form code="uu">unknown</form>
    <form code="vi">villancicos</form>
    <form code="vr">variations</form>
    <form code="wz">waltzes</form>
    <form code="za">zarzuelas</form>
    <form code="zz">other</form>
  </xsl:variable>

  <!-- IAML Musical Form codes -->
  <xsl:variable name="iamlFormList">
    <form code="abs">absolutio</form>
    <form code="acc">accademia</form>
    <form code="acl">acclamatio</form>
    <form code="acm">actus musicus</form>
    <form code="agn">agnus dei</form>
    <form code="ai#">air, vocal</form>
    <form code="ain">air, instrumental</form>
    <form code="aka">akathistos hymnos</form>
    <form code="ala">alba</form>
    <form code="alb">albumleaf</form>
    <form code="all">alleluia</form>
    <form code="alm">allemande</form>
    <form code="ame">amener</form>
    <form code="an#">anthem</form>
    <form code="ana">anagramma</form>
    <form code="ane">ante evangelium</form>
    <form code="ant">antiphon</form>
    <form code="app">applauso</form>
    <form code="ar#">aria</form>
    <form code="ara">arabesque</form>
    <form code="ari">ariette</form>
    <form code="ark">aurresku</form>
    <form code="arn">aria, instrumental</form>
    <form code="ars">arioso</form>
    <form code="aub">aubade</form>
    <form code="azm">azione musicale</form>
    <form code="azs">azione sacra</form>
    <form code="azt">azione teatrale</form>
    <form code="bac">baccanale</form>
    <form code="bad">badinage</form>
    <form code="bag">bagatelle</form>
    <form code="bai">baião</form>
    <form code="bal">ballo</form>
    <form code="bar">barcarole</form>
    <form code="bat">battaglia</form>
    <form code="bbp">bebop</form>
    <form code="bcs">berceuse</form>
    <form code="bd#">ballad</form>
    <form code="bde">ballade, vocal</form>
    <form code="bdi">ballade, instrumental</form>
    <form code="bea">beat</form>
    <form code="beg">béguine</form>
    <form code="ben">benedictus</form>
    <form code="bfm">barform</form>
    <form code="bg#">bluegrass</form>
    <form code="bgk">bugaku</form>
    <form code="bhn">bergreihen</form>
    <form code="bic">bicinium</form>
    <form code="bkb">black bottom</form>
    <form code="bkg">bänkelgesang</form>
    <form code="bkm">black music</form>
    <form code="bl#">blues</form>
    <form code="blc">cuban bolero</form>
    <form code="bll">ballata</form>
    <form code="blo">ballad opera</form>
    <form code="blt">bluette</form>
    <form code="bol">bolero</form>
    <form code="bou">bourrée</form>
    <form code="bra">branle</form>
    <form code="brg">bergamasque dance</form>
    <form code="brr">barriera</form>
    <form code="brt">bergerette</form>
    <form code="bru">brunette</form>
    <form code="bsd">basse danse</form>
    <form code="bst">boston</form>
    <form code="bt#">ballet</form>
    <form code="btd">boutade</form>
    <form code="bto">balletto</form>
    <form code="btq">batuque</form>
    <form code="bur">burlesque</form>
    <form code="bwg">boogie-woogie</form>
    <form code="byc">byzantine canon</form>
    <form code="cab">cabaletta</form>
    <form code="cac">caccia</form>
    <form code="cad">cadenza</form>
    <form code="cal">calata</form>
    <form code="can">can-can</form>
    <form code="cav">cavatina</form>
    <form code="cb#">chant, non christian</form>
    <form code="cc#">chant, christian</form>
    <form code="cch">catch</form>
    <form code="ccl">canticle</form>
    <form code="ccn">canción</form>
    <form code="cdg">chanson de geste</form>
    <form code="cdo">children opera</form>
    <form code="cdt">chanson de toile</form>
    <form code="cfr">confractorium</form>
    <form code="cg#">concerto grosso</form>
    <form code="cga">conga</form>
    <form code="ch#">choral</form>
    <form code="cha">cha-cha-cha</form>
    <form code="chc">chaconne</form>
    <form code="chh">cachucha</form>
    <form code="chn">charleston</form>
    <form code="cho">chamber opera</form>
    <form code="chp">character piece</form>
    <form code="chr">choir</form>
    <form code="chs">children's song</form>
    <form code="cht">chanson sentencieuse</form>
    <form code="chz">chiarenzana</form>
    <form code="ckw">cakewalk</form>
    <form code="cl#">choral prelude</form>
    <form code="cld">colinda</form>
    <form code="cli">choral, instrumental</form>
    <form code="cll">carosello</form>
    <form code="clu">clausula</form>
    <form code="cly">calypso</form>
    <form code="cmg">carmagnole</form>
    <form code="cmm">communion</form>
    <form code="cmn">carmen</form>
    <form code="cmp">completorium</form>
    <form code="cn#">canon</form>
    <form code="cnd">conductus</form>
    <form code="cnl">cantilena</form>
    <form code="cnr">canario</form>
    <form code="cns">canso</form>
    <form code="co#">concerto</form>
    <form code="cob">comédie-ballet</form>
    <form code="cop">concert piece</form>
    <form code="cou">couplet</form>
    <form code="cow">competition, examination work</form>
    <form code="cp#">chanson, polyphonic</form>
    <form code="cpl">copla</form>
    <form code="cpm">commedia per musica</form>
    <form code="cpr">caprice</form>
    <form code="cr#">carol</form>
    <form code="cra">carola</form>
    <form code="cre">credo</form>
    <form code="cri">carioca</form>
    <form code="crr">corrido</form>
    <form code="crt">corant</form>
    <form code="cs#">chance composition / aleatoric music</form>
    <form code="csa">csárdás</form>
    <form code="cse">chasse</form>
    <form code="csg">carnival song</form>
    <form code="csn">chanson, monodic</form>
    <form code="css">chanson spirituelle</form>
    <form code="cst">cassation</form>
    <form code="csy">chamber symphony</form>
    <form code="ct#">cantata</form>
    <form code="ctc">contacio</form>
    <form code="ctd">contredance</form>
    <form code="ctf">contrafactum</form>
    <form code="ctg">cantiga</form>
    <form code="cti">cantio</form>
    <form code="ctl">cotillon</form>
    <form code="cto">cento</form>
    <form code="ctp">counterpoint</form>
    <form code="cue">cueca</form>
    <form code="cy#">country music</form>
    <form code="cyd">country dance</form>
    <form code="cz#">canzona</form>
    <form code="czn">canzone</form>
    <form code="czp">canzone, polyphonic</form>
    <form code="czs">canzonetta spirituale</form>
    <form code="czt">canzonetta</form>
    <form code="dbl">double</form>
    <form code="dec">decimino</form>
    <form code="des">descort</form>
    <form code="dev">devozione</form>
    <form code="df#">dance form</form>
    <form code="dia">dialogue</form>
    <form code="dim">disco music</form>
    <form code="din">dramatic introduction</form>
    <form code="dix">dixieland</form>
    <form code="dmk">dumka</form>
    <form code="dod">dance of death</form>
    <form code="dox">doxology</form>
    <form code="drh">dreher</form>
    <form code="drs">drinking song</form>
    <form code="dsg">disguisings</form>
    <form code="dtr">dithyramb</form>
    <form code="dts">dramatic scherzo</form>
    <form code="due">duet</form>
    <form code="dui">duo</form>
    <form code="dv#">divertimento</form>
    <form code="eco">écossaise</form>
    <form code="egl">eglogue</form>
    <form code="ele">elevatio</form>
    <form code="elm">electroacoustic music</form>
    <form code="elx">electroacoustic mixed music</form>
    <form code="ely">elegy</form>
    <form code="ens">ensalada</form>
    <form code="ent">entrée</form>
    <form code="enw">english waltz</form>
    <form code="epo">epos</form>
    <form code="ept">epithalamium</form>
    <form code="est">estampie</form>
    <form code="ext">extravaganza</form>
    <form code="fad">fado</form>
    <form code="faf">fanfare</form>
    <form code="far">farce</form>
    <form code="fax">faux-bourdon</form>
    <form code="fea">feast</form>
    <form code="fg#">fugue</form>
    <form code="fin">finale</form>
    <form code="fla">flamenco</form>
    <form code="fls">flagellant song</form>
    <form code="fm#">folk music</form>
    <form code="fmm">masonic music</form>
    <form code="fnd">fandango</form>
    <form code="fnk">funk</form>
    <form code="fns">funeral song</form>
    <form code="fol">folie</form>
    <form code="for">forlana</form>
    <form code="fox">foxtrot</form>
    <form code="frd">farandole</form>
    <form code="frj">free jazz</form>
    <form code="fro">frottola</form>
    <form code="frs">fricassée</form>
    <form code="fso">folk song</form>
    <form code="ft#">fantasia</form>
    <form code="fum">funeral march</form>
    <form code="fur">furiant</form>
    <form code="fus">fusion</form>
    <form code="fvm">favola per musica</form>
    <form code="gai">gaillard</form>
    <form code="gal">galop</form>
    <form code="gas">gassenhauer</form>
    <form code="gav">gavotte</form>
    <form code="gch">genero chico</form>
    <form code="gig">gigue</form>
    <form code="gle">glee</form>
    <form code="glo">gloria</form>
    <form code="gm#">gospel music</form>
    <form code="gop">gopak</form>
    <form code="gos">goliard song</form>
    <form code="gra">gradual</form>
    <form code="gre">greghesca</form>
    <form code="gro">grand opéra</form>
    <form code="gym">gymel</form>
    <form code="gyp">gypsy song</form>
    <form code="hab">habanera</form>
    <form code="had">hadutanc</form>
    <form code="hal">halling</form>
    <form code="hem">heavy metal</form>
    <form code="hip">hip-hop</form>
    <form code="hit">hit</form>
    <form code="hoq">hoquetus</form>
    <form code="hpp">hornpipe</form>
    <form code="hrk">hard rock</form>
    <form code="hum">humoresque</form>
    <form code="hy#">hymn</form>
    <form code="hym">hymenaios</form>
    <form code="idy">idyll</form>
    <form code="iex">instrumental excerpts of an operatic or choreographic work</form>
    <form code="imp">imploratio</form>
    <form code="imu">impromptu</form>
    <form code="in#">intermezzo</form>
    <form code="inc">invocatio</form>
    <form code="ind">intrada</form>
    <form code="ing">ingressa</form>
    <form code="inm">incidental / theater music</form>
    <form code="int">introduction</form>
    <form code="inv">invention</form>
    <form code="iph">iporchema</form>
    <form code="ipp">improperia</form>
    <form code="iru">interlude</form>
    <form code="itd">intermedio</form>
    <form code="itn">intonation</form>
    <form code="itt">introit</form>
    <form code="ivu">invitatorium</form>
    <form code="jep">jeu parti</form>
    <form code="jgg">jigg</form>
    <form code="jig">jig</form>
    <form code="jot">jota</form>
    <form code="jub">jubilee</form>
    <form code="jus">justiniane</form>
    <form code="jz#">jazz</form>
    <form code="kld">koleda</form>
    <form code="kol">kolo</form>
    <form code="kra">krakowiak</form>
    <form code="kuj">kujawiak</form>
    <form code="kyr">kyrie</form>
    <form code="lai">lai</form>
    <form code="lam">lament</form>
    <form code="lau">lauda</form>
    <form code="lby">lullaby / cradle song</form>
    <form code="lds">liederspiel</form>
    <form code="ldy">lindy</form>
    <form code="lec">lectio</form>
    <form code="les">leise</form>
    <form code="lgu">langaus</form>
    <form code="li#">lied</form>
    <form code="lic">licenza</form>
    <form code="lid">liturgical drama</form>
    <form code="lir">lirica</form>
    <form code="lit">liturgy</form>
    <form code="lmz">lamentations</form>
    <form code="lnd">ländler</form>
    <form code="lod">lauds</form>
    <form code="lou">loure</form>
    <form code="lty">litany</form>
    <form code="luc">lucernario</form>
    <form code="lyh">liturgy of the hours</form>
    <form code="mat">matins</form>
    <form code="maz">mazur</form>
    <form code="mbm">mambo</form>
    <form code="mc#">musical revue and comedy</form>
    <form code="mcc">macchietta</form>
    <form code="md#">madrigal</form>
    <form code="mda">melodrama</form>
    <form code="mdc">madrigal comedy</form>
    <form code="mds">morceau de salon</form>
    <form code="mdy">melody</form>
    <form code="mgg">maggiolata</form>
    <form code="mgs">madrigale spirituale</form>
    <form code="mi#">minuet</form>
    <form code="mim">military march</form>
    <form code="mld">mélodie</form>
    <form code="mlg">malagueña</form>
    <form code="mls">melos</form>
    <form code="mmd">mimodramma</form>
    <form code="mme">musique mesurée</form>
    <form code="mmm">mumming</form>
    <form code="mmo">multimedia opera</form>
    <form code="mng">milonga</form>
    <form code="mnh">modinha</form>
    <form code="mo#">motet</form>
    <form code="mod">morris dance</form>
    <form code="mon">monferrina</form>
    <form code="mor">morality</form>
    <form code="mp#">moving picture music</form>
    <form code="mph">metamorphosis</form>
    <form code="mqu">masque</form>
    <form code="mr#">march</form>
    <form code="ms#">mass</form>
    <form code="msc">moresca</form>
    <form code="msq">masquerade</form>
    <form code="mst">mystery play</form>
    <form code="mtb">matachin</form>
    <form code="mth">method</form>
    <form code="mtp">moto perpetuo</form>
    <form code="mtz">mutanza</form>
    <form code="mu#">multiple forms</form>
    <form code="mum">musical moment</form>
    <form code="mun">muñeira</form>
    <form code="mus">musette</form>
    <form code="mut">musical theatre</form>
    <form code="mxx">maxixe</form>
    <form code="mym">military music</form>
    <form code="mz#">mazurka</form>
    <form code="nat">national anthem</form>
    <form code="nau">nauba</form>
    <form code="nc#">nocturne</form>
    <form code="nen">nenia</form>
    <form code="noe">noël</form>
    <form code="nom">nomos</form>
    <form code="non">nonet</form>
    <form code="nov">novellette</form>
    <form code="nry">nursery-rhyme</form>
    <form code="ntz">nachtanz</form>
    <form code="nwa">new age</form>
    <form code="nww">new wave</form>
    <form code="obk">oberek</form>
    <form code="oct">octet</form>
    <form code="ode">ode</form>
    <form code="ofd">officium defunctorum</form>
    <form code="off">offertorium</form>
    <form code="ogm">organum</form>
    <form code="ons">onestep</form>
    <form code="op#">opera</form>
    <form code="opb">opéra-ballet</form>
    <form code="opc">opéra-comique</form>
    <form code="opf">opéra bouffe</form>
    <form code="opm">opera semiseria</form>
    <form code="ops">opera seria</form>
    <form code="opt">operetta</form>
    <form code="opu">opera buffa</form>
    <form code="or#">oratorio</form>
    <form code="ora">oratio</form>
    <form code="orm">organ mass</form>
    <form code="ov#">overture</form>
    <form code="pad">pastoral drama</form>
    <form code="pae">paean</form>
    <form code="pbr">pibroch</form>
    <form code="pch">pastiche</form>
    <form code="pco">postcommunio</form>
    <form code="pdd">pas de deux</form>
    <form code="pdv">padovana</form>
    <form code="pdy">parody</form>
    <form code="pev">post evangelium</form>
    <form code="pf#">prelude and fugue</form>
    <form code="pg#">programme music</form>
    <form code="pgl">pavaniglia</form>
    <form code="phy">patriotic hymn</form>
    <form code="piv">piva</form>
    <form code="plc">planctus</form>
    <form code="ple">post lectionem</form>
    <form code="plk">polka</form>
    <form code="pll">penillon</form>
    <form code="plo">palotas</form>
    <form code="plr">plaisanterie</form>
    <form code="pls">plantation song</form>
    <form code="plt">plainte</form>
    <form code="plu">postlude</form>
    <form code="pm#">passion music</form>
    <form code="pmk">polka mazurka</form>
    <form code="pmm">pantomime</form>
    <form code="pnk">punk</form>
    <form code="po#">polonaise</form>
    <form code="pol">polo</form>
    <form code="pot">pot-pourri</form>
    <form code="pp#">popular music</form>
    <form code="pph">paraphrase</form>
    <form code="ppo">puppet opera</form>
    <form code="prd">prelude</form>
    <form code="pre">preghiera</form>
    <form code="prf">praefatio</form>
    <form code="prg">périgourdine</form>
    <form code="prl">prologue</form>
    <form code="prm">processional march</form>
    <form code="pro">proemium</form>
    <form code="prt">partimento</form>
    <form code="prz">profezia</form>
    <form code="ps#">passacaglia</form>
    <form code="psa">psalm</form>
    <form code="psd">paso doble</form>
    <form code="psl">pastourelle</form>
    <form code="psp">passepied</form>
    <form code="psr">pas redoublé</form>
    <form code="pst">pastoral</form>
    <form code="pt#">partsong</form>
    <form code="ptn">pater noster</form>
    <form code="ptt">partita</form>
    <form code="pv#">pavan</form>
    <form code="pzz">passamezzo</form>
    <form code="qav">quartet, vocal</form>
    <form code="qdl">quadrille</form>
    <form code="qiv">quintet, vocal</form>
    <form code="qua">quartet</form>
    <form code="qui">quintet</form>
    <form code="quo">quodlibet</form>
    <form code="rad">rada</form>
    <form code="ram">radio music</form>
    <form code="rao">radio opera</form>
    <form code="rap">rap</form>
    <form code="rc#">rock music</form>
    <form code="rct">récit</form>
    <form code="rd#">rondo</form>
    <form code="rde">rondeau</form>
    <form code="rdv">ranz des vaches</form>
    <form code="rdw">redowa</form>
    <form code="rec">recitative</form>
    <form code="ree">reel</form>
    <form code="rej">réjouissance</form>
    <form code="rem">réminiscence</form>
    <form code="rer">rêverie</form>
    <form code="res">responsorium</form>
    <form code="rev">revue</form>
    <form code="rg#">ragtime</form>
    <form code="rgg">reggae</form>
    <form code="rgl">reigenlied</form>
    <form code="rgr">ruggiero</form>
    <form code="rhb">rhythm and blues</form>
    <form code="rhl">rheinländer</form>
    <form code="ri#">ricercare</form>
    <form code="rig">rigaudon</form>
    <form code="ris">rispetto</form>
    <form code="rit">ritornello</form>
    <form code="rjk">rejdovak</form>
    <form code="rmc">romance (instrumental)</form>
    <form code="rmy">religious melody</form>
    <form code="rmz">romanza</form>
    <form code="rot">rota</form>
    <form code="rp#">rhapsody</form>
    <form code="rq#">requiem mass</form>
    <form code="rsc">romanesca</form>
    <form code="rsp">raspa</form>
    <form code="rtg">rotruenge</form>
    <form code="rtt">rotta</form>
    <form code="rue">rueda</form>
    <form code="rug">ruggero</form>
    <form code="rum">rumba</form>
    <form code="sad">sacred drama</form>
    <form code="sae">saeta</form>
    <form code="sai">sainete</form>
    <form code="san">sanctus</form>
    <form code="sar">sacra rappresentazione</form>
    <form code="scc">sacred cantata</form>
    <form code="scd">scholastic drama</form>
    <form code="sce">scene</form>
    <form code="sch">scherzo</form>
    <form code="scp">schuhplattler</form>
    <form code="scs">sacred song</form>
    <form code="sct">scat</form>
    <form code="sdh">schnadahüpfl</form>
    <form code="sdr">scherzo drammatico</form>
    <form code="sep">sepolcro</form>
    <form code="seq">sequence</form>
    <form code="sev">sevillana</form>
    <form code="sex">sextet</form>
    <form code="sft">sinfonietta</form>
    <form code="sg#">song</form>
    <form code="sgl">seguidilla</form>
    <form code="sha">shanty</form>
    <form code="shm">shimmy</form>
    <form code="si#">sinfonia</form>
    <form code="sic">siciliana</form>
    <form code="ska">ska</form>
    <form code="skt">sketch</form>
    <form code="sll">sallenda</form>
    <form code="slq">soliloquy</form>
    <form code="sls">salsa</form>
    <form code="slt">saltarello</form>
    <form code="smb">samba</form>
    <form code="sml">psalmellus</form>
    <form code="sn#">sonata</form>
    <form code="snd">serenade</form>
    <form code="snt">serenata</form>
    <form code="sol">solfeggio</form>
    <form code="sou">soul</form>
    <form code="sp#">symphonic poem</form>
    <form code="spi">spiritual</form>
    <form code="sps">social and political song</form>
    <form code="spt">septet</form>
    <form code="sq#">square dance</form>
    <form code="srb">sarabande</form>
    <form code="srd">sardana</form>
    <form code="srm">sarum</form>
    <form code="srv">sirventes</form>
    <form code="ssp">singspiel</form>
    <form code="sss">seises</form>
    <form code="st#">study, exercise</form>
    <form code="ste">schottische</form>
    <form code="sth">schottish</form>
    <form code="sto">stornello</form>
    <form code="str">strambotto</form>
    <form code="sts">strathspey</form>
    <form code="stt">saltarello tedesco</form>
    <form code="su#">suite</form>
    <form code="swi">swing</form>
    <form code="sww">song without words</form>
    <form code="sy#">symphony</form>
    <form code="syc">sinfonia concertante</form>
    <form code="syd">symphonie dramatique</form>
    <form code="sym">symbolum</form>
    <form code="syo">syomyo</form>
    <form code="tar">tarantella</form>
    <form code="tc#">toccata</form>
    <form code="tcn">trecanum</form>
    <form code="tct">tricotet</form>
    <form code="tdn">triodion</form>
    <form code="tem">techno music</form>
    <form code="ten">tenso</form>
    <form code="ter">terzet</form>
    <form code="tex">tex-mex</form>
    <form code="tfm">tafelmusik</form>
    <form code="thr">threnos</form>
    <form code="ths">third stream</form>
    <form code="tir">tirana</form>
    <form code="tmb">tambourin</form>
    <form code="tnc">trenchmore</form>
    <form code="tng">tango</form>
    <form code="tod">torch dance</form>
    <form code="tom">tombeau</form>
    <form code="ton">tonadilla</form>
    <form code="tou">tourney</form>
    <form code="tra">tract</form>
    <form code="trd">tourdion</form>
    <form code="trg">trishagion</form>
    <form code="tri">trio</form>
    <form code="trl">tragédie lyrique</form>
    <form code="trm">tricinium</form>
    <form code="tro">trope</form>
    <form code="trq">traquenard</form>
    <form code="trs">treatise</form>
    <form code="trt">transitorium</form>
    <form code="trz">trezza</form>
    <form code="ts#">triosonata</form>
    <form code="ttt">tattoo</form>
    <form code="tum">tumba</form>
    <form code="tvo">television opera</form>
    <form code="two">two-step</form>
    <form code="uuu">unknown form</form>
    <form code="vau">vaudeville</form>
    <form code="vil">villanelle</form>
    <form code="vir">virelai</form>
    <form code="vlc">villancico</form>
    <form code="vln">villanella</form>
    <form code="vlt">villotta</form>
    <form code="vly">voluntary</form>
    <form code="vnz">veneziana</form>
    <form code="voc">vocalise</form>
    <form code="vol">volta</form>
    <form code="vr#">variation</form>
    <form code="vra">verse, alleluia</form>
    <form code="vrg">verse, gradual</form>
    <form code="vri">verse, introit</form>
    <form code="vrl">versicle</form>
    <form code="vrr">verse, responsorium</form>
    <form code="vrs">verse</form>
    <form code="vsp">vespers</form>
    <form code="vvn">varsovienne</form>
    <form code="wem">wedding march</form>
    <form code="wom">world music</form>
    <form code="wsg">war song</form>
    <form code="wz#">waltz</form>
    <form code="yar">yaraví</form>
    <form code="zam">zamacueca</form>
    <form code="zap">zapateado</form>
    <form code="zar">zarzuela</form>
    <form code="zmb">zamba</form>
    <form code="zop">zoppa</form>
    <form code="zor">zortziko</form>
    <form code="zwi">zwiefacher</form>
    <form code="zz#">other form</form>
  </xsl:variable>

  <!-- MARC Relator codes -->
  <xsl:variable name="marcRelList">
    <relator code="abr">abridger</relator>
    <relator code="acp">art copyist</relator>
    <relator code="act">actor</relator>
    <relator code="adi">art director</relator>
    <relator code="adp">adapter</relator>
    <relator code="aft">author of afterword, colophon, etc.</relator>
    <relator code="anl">analyst</relator>
    <relator code="anm">animator</relator>
    <relator code="ann">annotator</relator>
    <relator code="ant">bibliographic antecedent</relator>
    <relator code="ape">appellee</relator>
    <relator code="apl">appellant</relator>
    <relator code="app">applicant</relator>
    <relator code="aqt">author in quotations or text abstracts</relator>
    <relator code="arc">architect</relator>
    <relator code="ard">artistic director</relator>
    <relator code="arr">arranger</relator>
    <relator code="art">artist</relator>
    <relator code="asg">assignee</relator>
    <relator code="asn">associated name</relator>
    <relator code="ato">autographer</relator>
    <relator code="att">attributed name</relator>
    <relator code="auc">auctioneer</relator>
    <relator code="aud">author of dialog</relator>
    <relator code="aui">author of introduction, etc.</relator>
    <relator code="aus">screenwriter</relator>
    <relator code="aut">author</relator>
    <relator code="bdd">binding designer</relator>
    <relator code="bjd">bookjacket designer</relator>
    <relator code="bkd">book designer</relator>
    <relator code="bkp">book producer</relator>
    <relator code="blw">blurb writer</relator>
    <relator code="bnd">binder</relator>
    <relator code="bpd">bookplate designer</relator>
    <relator code="brd">broadcaster</relator>
    <relator code="brl">braille embosser</relator>
    <relator code="bsl">bookseller</relator>
    <relator code="cas">caster</relator>
    <relator code="ccp">conceptor</relator>
    <relator code="chr">choreographer</relator>
    <relator code="clb" status="discontinued">collaborator</relator>
    <relator code="cli">client</relator>
    <relator code="cll">calligrapher</relator>
    <relator code="clr">colorist</relator>
    <relator code="clt">collotyper</relator>
    <relator code="cmm">commentator</relator>
    <relator code="cmp">composer</relator>
    <relator code="cmt">compositor</relator>
    <relator code="cnd">conductor</relator>
    <relator code="cng">cinematographer</relator>
    <relator code="cns">censor</relator>
    <relator code="coe">contestant-appellee</relator>
    <relator code="col">collector</relator>
    <relator code="com">compiler</relator>
    <relator code="con">conservator</relator>
    <relator code="cor">collection registrar</relator>
    <relator code="cos">contestant</relator>
    <relator code="cot">contestant-appellant</relator>
    <relator code="cou">court governed</relator>
    <relator code="cov">cover designer</relator>
    <relator code="cpc">copyright claimant</relator>
    <relator code="cpe">complainant-appellee</relator>
    <relator code="cph">copyright holder</relator>
    <relator code="cpl">complainant</relator>
    <relator code="cpt">complainant-appellant</relator>
    <relator code="cre">creator</relator>
    <relator code="crp">correspondent</relator>
    <relator code="crr">corrector</relator>
    <relator code="crt">court reporter</relator>
    <relator code="csl">consultant</relator>
    <relator code="csp">consultant to a project</relator>
    <relator code="cst">costume designer</relator>
    <relator code="ctb">contributor</relator>
    <relator code="cte">contestee-appellee</relator>
    <relator code="ctg">cartographer</relator>
    <relator code="ctr">contractor</relator>
    <relator code="cts">contestee</relator>
    <relator code="ctt">contestee-appellant</relator>
    <relator code="cur">curator</relator>
    <relator code="cwt">commentator for written text</relator>
    <relator code="dbp">distribution place</relator>
    <relator code="dfd">defendant</relator>
    <relator code="dfe">defendant-appellee</relator>
    <relator code="dft">defendant-appellant</relator>
    <relator code="dgg">degree granting institution</relator>
    <relator code="dis">dissertant</relator>
    <relator code="dln">delineator</relator>
    <relator code="dnc">dancer</relator>
    <relator code="dnr">donor</relator>
    <relator code="dpc">depicted</relator>
    <relator code="dpt">depositor</relator>
    <relator code="drm">draftsman</relator>
    <relator code="drt">director</relator>
    <relator code="dsr">designer</relator>
    <relator code="dst">distributor</relator>
    <relator code="dtc">data contributor</relator>
    <relator code="dte">dedicatee</relator>
    <relator code="dtm">data manager</relator>
    <relator code="dto">dedicator</relator>
    <relator code="dub">dubious author</relator>
    <relator code="edc">editor of compilation</relator>
    <relator code="edm">editor of moving image work</relator>
    <relator code="edt">editor</relator>
    <relator code="egr">engraver</relator>
    <relator code="elg">electrician</relator>
    <relator code="elt">electrotyper</relator>
    <relator code="eng">engineer</relator>
    <relator code="enj">enacting jurisdiction</relator>
    <relator code="etr">etcher</relator>
    <relator code="evp">event place</relator>
    <relator code="exp">expert</relator>
    <relator code="fac">facsimilist</relator>
    <relator code="fds">film distributor</relator>
    <relator code="fld">field director</relator>
    <relator code="flm">film editor</relator>
    <relator code="fmd">film director</relator>
    <relator code="fmk">filmmaker</relator>
    <relator code="fmo">former owner</relator>
    <relator code="fmp">film producer</relator>
    <relator code="fnd">funder</relator>
    <relator code="fpy">first party</relator>
    <relator code="frg">forger</relator>
    <relator code="gis">geographic information specialist</relator>
    <relator code="grt" status="discontinued">graphic technician</relator>
    <relator code="his">host institution</relator>
    <relator code="hnr">honoree</relator>
    <relator code="hst">host</relator>
    <relator code="ill">illustrator</relator>
    <relator code="ilu">illuminator</relator>
    <relator code="ins">inscriber</relator>
    <relator code="itr">instrumentalist</relator>
    <relator code="ive">interviewee</relator>
    <relator code="ivr">interviewer</relator>
    <relator code="inv">inventor</relator>
    <relator code="isb">issuing body</relator>
    <relator code="jud">judge</relator>
    <relator code="jug">jurisdiction governed</relator>
    <relator code="lbr">laboratory</relator>
    <relator code="lbt">librettist</relator>
    <relator code="ldr">laboratory director</relator>
    <relator code="led">lead</relator>
    <relator code="lee">libelee-appellee</relator>
    <relator code="lel">libelee</relator>
    <relator code="len">lender</relator>
    <relator code="let">libelee-appellant</relator>
    <relator code="lgd">lighting designer</relator>
    <relator code="lie">libelant-appellee</relator>
    <relator code="lil">libelant</relator>
    <relator code="lit">libelant-appellant</relator>
    <relator code="lsa">landscape architect</relator>
    <relator code="lse">licensee</relator>
    <relator code="lso">licensor</relator>
    <relator code="ltg">lithographer</relator>
    <relator code="lyr">lyricist</relator>
    <relator code="mcp">music copyist</relator>
    <relator code="mdc">metadata contact</relator>
    <relator code="mfp">manufacture place</relator>
    <relator code="mfr">manufacturer</relator>
    <relator code="mod">moderator</relator>
    <relator code="mon">monitor</relator>
    <relator code="mrb">marbler</relator>
    <relator code="mrk">markup editor</relator>
    <relator code="msd">musical director</relator>
    <relator code="mte">metal-engraver</relator>
    <relator code="mus">musician</relator>
    <relator code="nrt">narrator</relator>
    <relator code="opn">opponent</relator>
    <relator code="org">originator</relator>
    <relator code="orm">organizer of meeting</relator>
    <relator code="osp">onscreen presenter</relator>
    <relator code="oth">other</relator>
    <relator code="own">owner</relator>
    <relator code="pan">panelist</relator>
    <relator code="pat">patron</relator>
    <relator code="pbd">publishing director</relator>
    <relator code="pbl">publisher</relator>
    <relator code="pdr">project director</relator>
    <relator code="pfr">proofreader</relator>
    <relator code="pht">photographer</relator>
    <relator code="plt">platemaker</relator>
    <relator code="pma">permitting agency</relator>
    <relator code="pmn">production manager</relator>
    <relator code="pop">printer of plates</relator>
    <relator code="ppm">papermaker</relator>
    <relator code="ppt">puppeteer</relator>
    <relator code="pra">praeses</relator>
    <relator code="prc">process contact</relator>
    <relator code="prd">production personnel</relator>
    <relator code="pre">presenter</relator>
    <relator code="prf">performer</relator>
    <relator code="prg">programmer</relator>
    <relator code="prm">printmaker</relator>
    <relator code="prn">production company</relator>
    <relator code="pro">producer</relator>
    <relator code="prp">production place</relator>
    <relator code="prs">production designer</relator>
    <relator code="prt">printer</relator>
    <relator code="prv">provider</relator>
    <relator code="pta">patent applicant</relator>
    <relator code="pte">plaintiff-appellee</relator>
    <relator code="ptf">plaintiff</relator>
    <relator code="pth">patent holder</relator>
    <relator code="ptt">plaintiff-appellant</relator>
    <relator code="pup">publication place</relator>
    <relator code="rbr">rubricator</relator>
    <relator code="rce">recording engineer</relator>
    <relator code="rcd">recordist</relator>
    <relator code="rcp">addressee</relator>
    <relator code="rdd">radio director</relator>
    <relator code="red">redaktor</relator>
    <relator code="ren">renderer</relator>
    <relator code="res">researcher</relator>
    <relator code="rev">reviewer</relator>
    <relator code="rpc">radio producer</relator>
    <relator code="rps">repository</relator>
    <relator code="rpt">reporter</relator>
    <relator code="rpy">responsible party</relator>
    <relator code="rse">respondent-appellee</relator>
    <relator code="rsg">restager</relator>
    <relator code="rsp">respondent</relator>
    <relator code="rsr">restorationist</relator>
    <relator code="rst">respondent-appellant</relator>
    <relator code="rth">research team head</relator>
    <relator code="rtm">research team member</relator>
    <relator code="sad">scientific advisor</relator>
    <relator code="sce">scenarist</relator>
    <relator code="scl">sculptor</relator>
    <relator code="scr">scribe</relator>
    <relator code="sds">sound designer</relator>
    <relator code="sec">secretary</relator>
    <relator code="sgd">stage director</relator>
    <relator code="sgn">signer</relator>
    <relator code="sht">supporting host</relator>
    <relator code="sll">seller</relator>
    <relator code="sng">singer</relator>
    <relator code="spk">speaker</relator>
    <relator code="spn">sponsor</relator>
    <relator code="spy">second party</relator>
    <relator code="std">set designer</relator>
    <relator code="stg">setting</relator>
    <relator code="stl">storyteller</relator>
    <relator code="stm">stage manager</relator>
    <relator code="stn">standards body</relator>
    <relator code="str">stereotyper</relator>
    <relator code="srv">surveyor</relator>
    <relator code="tcd">technical director</relator>
    <relator code="tch">teacher</relator>
    <relator code="ths">thesis advisor</relator>
    <relator code="tld">television director</relator>
    <relator code="tlp">television producer</relator>
    <relator code="trc">transcriber</relator>
    <relator code="trl">translator</relator>
    <relator code="tyd">type designer</relator>
    <relator code="tyg">typographer</relator>
    <relator code="uvp">university place</relator>
    <relator code="vdg">videographer</relator>
    <relator code="voc" status="discontinued">vocalist</relator>
    <relator code="wac">writer of added commentary</relator>
    <relator code="wal">writer of added lyrics</relator>
    <relator code="wam">writer of accompanying material</relator>
    <relator code="wat">writer of added text</relator>
    <relator code="wdc">woodcutter</relator>
    <relator code="wde">wood engraver</relator>
    <relator code="wit">witness</relator>
  </xsl:variable>

  <!-- Name and Title Authority Source Codes -->
  <xsl:variable name="nameAuthList">
    <nameAuth code="abne">Autoridades de la Biblioteca Nacional de España</nameAuth>
    <nameAuth code="banqa">Fichier d'autorité local de Bibliothèque et Archives nationales du
      Québec</nameAuth>
    <nameAuth code="bibalex">Bibliotheca Alexandrina Name and Subject Authority file</nameAuth>
    <nameAuth code="conorsi">CONOR.SI(IZUM)</nameAuth>
    <nameAuth code="gkd">Gemeinsame Körperschaftsdatei</nameAuth>
    <nameAuth code="gnd">Gemeinsame Normdatei</nameAuth>
    <nameAuth code="hapi">HAPI Thesaurus and Name Authority, 1970-2000</nameAuth>
    <nameAuth code="hkcan">Hong Kong Chinese Authority File (Name)</nameAuth>
    <nameAuth code="lacnaf">Library and Archives Canada Name Authority File</nameAuth>
    <nameAuth code="naf">NACO Authority File</nameAuth>
    <nameAuth code="nalnaf">National Agricultural Library Name Authority File</nameAuth>
    <nameAuth code="nlmnaf">National Library of Medicine Name Authority File</nameAuth>
    <nameAuth code="nznb">New Zealand National Bibliographic</nameAuth>
    <nameAuth code="sanb">South African National Bibliography Authority File</nameAuth>
    <nameAuth code="ulan">Union List of Artist Names</nameAuth>
    <nameAuth code="unbisn">UNBIS Name Authority List</nameAuth>
  </xsl:variable>

  <!-- New line -->
  <xsl:variable name="nl">
    <xsl:text>&#xa;</xsl:text>
  </xsl:variable>

  <!-- ======================================================================= -->
  <!-- UTILITIES                                                               -->
  <!-- ======================================================================= -->

  <xsl:template name="analog">
    <xsl:param name="tag"/>
    <xsl:if test="$analog = 'true'">
      <xsl:attribute name="analog">
        <xsl:value-of select="concat('marc:', $tag)"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="chopPunctuation">
    <xsl:param name="chopString"/>
    <xsl:variable name="length" select="string-length($chopString)"/>
    <xsl:choose>
      <xsl:when test="$length = 0"/>
      <xsl:when test="contains('.:,;+/ ', substring($chopString, $length, 1))">
        <xsl:call-template name="chopPunctuation">
          <xsl:with-param name="chopString" select="substring($chopString, 1, $length - 1)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="not($chopString)"/>
      <xsl:otherwise>
        <xsl:value-of select="$chopString"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="classification">
    <xsl:variable name="classification"
      select="
        marc:datafield[@tag = '047' or @tag = '050' or
        @tag = '082' or @tag = '648' or @tag = '600' or @tag = '650' or @tag = '651' or @tag = '653' or
        @tag = '654' or @tag = '655' or @tag = '656' or @tag = '657' or @tag = '658' or @tag = '751' or
        @tag = '752' or (number(@tag) >= 90 and number(@tag) &lt;= 99)]"/>

    <xsl:if test="$classification">
      <!-- classification codes -->
      <classification>
        <xsl:variable name="classCodes">

          <!-- common schemes -->
          <xsl:if test="marc:datafield[@tag = '047' and marc:subfield[@code = '2'] = 'iamlmf']">
            <classCode xml:id="IFMC">IAML Form of Musical Composition</classCode>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag = '047' and @ind2 = ' ']">
            <classCode xml:id="MFMC">MARC Form of Musical Composition Code List</classCode>
          </xsl:if>
          <xsl:if test="marc:datafield[number(@tag) >= 90 and number(@tag) &lt;= 99]">
            <xsl:for-each select="marc:datafield[number(@tag) >= 90 and number(@tag) &lt;= 99]">
              <classCode xml:id="LocalNum{@tag}">Local Shelf Number (<xsl:value-of select="@tag"
                />)</classCode>
            </xsl:for-each>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag = '082']">
            <classCode xml:id="DDC">Dewey Decimal Classification Number</classCode>
          </xsl:if>
          <xsl:if test="marc:datafield[@tag = '050']">
            <classCode xml:id="LCCN">Library of Congress Classification Number</classCode>
          </xsl:if>
          <xsl:if
            test="
              marc:datafield[@tag = '600' or @tag = '648' or @tag = '650' or @tag = '651' or
              @tag = '653' or @tag = '654' or @tag = '655' or @tag = '656' or @tag = '657' or
              @tag = '658'][@ind2 = '0']">
            <classCode xml:id="LCSH">Library of Congress Subject Headings</classCode>
          </xsl:if>
          <xsl:if
            test="
              marc:datafield[@tag = '600' or @tag = '648' or @tag = '650' or @tag = '651' or
              @tag = '653' or @tag = '654' or @tag = '655' or @tag = '656' or @tag = '657' or
              @tag = '658'][@ind2 = '1']">
            <classCode xml:id="LCCL">Library of Congress Subject Headings for Children's
              Literature</classCode>
          </xsl:if>
          <xsl:if
            test="
              marc:datafield[@tag = '600' or @tag = '648' or @tag = '650' or @tag = '651' or
              @tag = '653' or @tag = '654' or @tag = '655' or @tag = '656' or @tag = '657' or
              @tag = '658'][@ind2 = '2']">
            <classCode xml:id="MeSH">Medical Subject Headings </classCode>
          </xsl:if>
          <xsl:if
            test="
              marc:datafield[@tag = '600' or @tag = '648' or @tag = '650' or @tag = '651' or
              @tag = '653' or @tag = '654' or @tag = '655' or @tag = '656' or @tag = '657' or
              @tag = '658'][@ind2 = '3']">
            <classCode xml:id="NALSA">National Agricultural Library Subject Authority
              file</classCode>
          </xsl:if>
          <xsl:if
            test="
              marc:datafield[@tag = '600' or @tag = '648' or @tag = '650' or @tag = '651' or
              @tag = '653' or @tag = '654' or @tag = '655' or @tag = '656' or @tag = '657' or
              @tag = '658'][@ind2 = '5']">
            <classCode xml:id="CSH">Canadian Subject Headings</classCode>
          </xsl:if>
          <xsl:if
            test="
              marc:datafield[@tag = '600' or @tag = '648' or @tag = '650' or @tag = '651' or
              @tag = '653' or @tag = '654' or @tag = '655' or @tag = '656' or @tag = '657' or
              @tag = '658'][@ind2 = '6']">
            <classCode xml:id="RVM">Répertoire de vedettes-matière</classCode>
          </xsl:if>

          <!-- record-defined schemes -->
          <xsl:for-each
            select="
              marc:datafield[(@tag = '600' or @tag = '650' or @tag = '651' or @tag = '653'
              or @tag = '657' or @tag = '751' or @tag = '752') and marc:subfield[@code = '2']]">
            <xsl:variable name="classScheme">
              <xsl:value-of select="marc:subfield[@code = '2']"/>
            </xsl:variable>
            <classCode>
              <xsl:attribute name="xml:id">
                <xsl:choose>
                  <xsl:when test="@tag = '751' or @tag = '752'">
                    <xsl:value-of select="upper-case(replace($classScheme, '&#32;', '_'))"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="replace($classScheme, '&#32;', '_')"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
              <xsl:choose>
                <xsl:when test="@tag = '751' or @tag = '752'">
                  <xsl:value-of select="$nameAuthList/mei:nameAuth[@code = $classScheme]"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="$classScheme"/>
                </xsl:otherwise>
              </xsl:choose>
            </classCode>
          </xsl:for-each>
        </xsl:variable>

        <!-- unique schemes -->
        <xsl:variable name="uniqueClassCodes">
          <xsl:for-each select="$classCodes/mei:classCode">
            <xsl:sort/>
            <xsl:if test="not(preceding-sibling::mei:classCode = .)">
              <xsl:copy-of select="."/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:copy-of select="$uniqueClassCodes"/>

        <termList>
          <xsl:variable name="sortedTerms">
            <xsl:apply-templates select="$classification"/>
          </xsl:variable>
          <xsl:variable name="uniqueTerms">
            <xsl:for-each select="$sortedTerms/mei:term">
              <xsl:if test="not(preceding-sibling::mei:term = .)">
                <xsl:copy-of select="."/>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:for-each select="$uniqueTerms/mei:term">
            <xsl:sort select="@analog"/>
            <xsl:sort/>
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </termList>
      </classification>
    </xsl:if>
  </xsl:template>

  <xsl:template name="subfieldSelect">
    <xsl:param name="codes"/>
    <xsl:param name="delimiter">
      <xsl:text>&#32;</xsl:text>
    </xsl:param>
    <xsl:param name="chop">
      <xsl:text>no</xsl:text>
    </xsl:param>
    <xsl:param name="element"/>
    <xsl:choose>
      <xsl:when test="string-length($element) > 0">
        <xsl:element name="{$element}">
          <xsl:variable name="str">
            <xsl:for-each select="marc:subfield">
              <xsl:if test="contains($codes, @code)">
                <xsl:choose>
                  <xsl:when test="$chop = 'no'">
                    <xsl:value-of select="text()"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:call-template name="chopPunctuation">
                      <xsl:with-param name="chopString">
                        <xsl:value-of select="text()"/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="$delimiter"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:value-of select="substring($str, 1, string-length($str) - string-length($delimiter))"
          />
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="str">
          <xsl:for-each select="marc:subfield">
            <xsl:if test="contains($codes, @code)">
              <xsl:choose>
                <xsl:when test="$chop = 'no'">
                  <xsl:value-of select="text()"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                      <xsl:value-of select="."/>
                    </xsl:with-param>
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:value-of select="$delimiter"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring($str, 1, string-length($str) - string-length($delimiter))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="workLang">
    <xsl:variable name="langCode">
      <xsl:value-of select="substring(marc:controlfield[@tag = '008'], 36, 3)"/>
    </xsl:variable>
    <xsl:if
      test="
        matches($langCode, '[a-z]{3}') or
        marc:datafield[@tag = '041']/marc:subfield[@code = 'h' or @code = 'n']">
      <langUsage>
        <xsl:if test="matches($langCode, '[a-z]{3}')">
          <language xml:id="{$langCode}">
            <xsl:call-template name="analog">
              <xsl:with-param name="tag">
                <xsl:value-of select="'008/35-37'"/>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:value-of select="$marcLangList/mei:lang[@code = $langCode]"/>
          </language>
        </xsl:if>
        <xsl:for-each
          select="
            marc:datafield[@tag = '041']/marc:subfield[@code = 'h' or @code = 'n'][. !=
            $langCode]">
          <xsl:variable name="langCode">
            <xsl:value-of select="."/>
          </xsl:variable>
          <language xml:id="{$langCode}">
            <xsl:call-template name="analog">
              <xsl:with-param name="tag">
                <xsl:value-of select="concat('041|', @code)"/>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:value-of select="$marcLangList/mei:lang[@code = $langCode]"/>
          </language>
        </xsl:for-each>
      </langUsage>
    </xsl:if>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- TOP-LEVEL TEMPLATE                                                      -->
  <!-- ======================================================================= -->

  <xsl:template match="/">
    <xsl:choose>
      <xsl:when test="//marc:record">
        <xsl:apply-templates select="//marc:record[1]"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>marc2mei.xsl: ERROR: No records found.</xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="marc:record">

    <!-- UNUSED -->
    <!--<xsl:variable name="leader" select="marc:leader"/>
    <xsl:variable name="leader6" select="substring($leader,7,1)"/>
    <xsl:variable name="leader7" select="substring($leader,8,1)"/>
    <xsl:variable name="controlField005" select="marc:controlfield[@tag='005']"/>
    <xsl:variable name="controlField008" select="marc:controlfield[@tag='008']"/>-->

    <xsl:if test="$rng_model_path != ''">
      <xsl:processing-instruction name="xml-model">
        <xsl:value-of select="concat('&amp;#32;href=&quot;', $rng_model_path, '&quot;')"/>
        <xsl:text> type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
      </xsl:processing-instruction>
      <xsl:value-of select="$nl"/>
    </xsl:if>

    <xsl:if test="$sch_model_path != ''">
      <xsl:processing-instruction name="xml-model">
        <xsl:value-of select="concat('&amp;#32;href=&quot;', $sch_model_path, '&quot;')"/>
        <xsl:text> type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:text>
      </xsl:processing-instruction>
      <xsl:value-of select="$nl"/>
    </xsl:if>

    <meiHead>
      <xsl:attribute name="meiversion">3.0.0</xsl:attribute>
      <xsl:if test="marc:datafield[@tag = '040']/marc:subfield[@code = 'b']">
        <xsl:attribute name="xml:lang">
          <xsl:value-of select="marc:datafield[@tag = '040']/marc:subfield[@code = 'b']"/>
        </xsl:attribute>
      </xsl:if>
      <fileDesc>

        <!-- file title(s) -->
        <titleStmt>
          <!-- title for electronic text (240 and 245) -->
          <xsl:apply-templates select="marc:datafield[@tag = '240' or @tag = '245']"
            mode="titleProper"/>

          <!-- statements of responsibility -->
          <xsl:variable name="respStmts">
            <xsl:apply-templates select="marc:datafield[@tag = '100' or @tag = '110']"/>
            <xsl:if test="not($fileMainEntryOnly = 'true')">
              <xsl:apply-templates select="marc:datafield[@tag = '700' or @tag = '710']"
                mode="respStmt"/>
            </xsl:if>
          </xsl:variable>
          <xsl:variable name="sortedRespStmts">
            <xsl:for-each select="$respStmts/mei:respStmt">
              <xsl:sort
                select="mei:*[local-name() = 'persName' or local-name() = 'corpName']/@analog"/>
              <xsl:sort/>
              <xsl:copy-of select="."/>
            </xsl:for-each>
          </xsl:variable>
          <xsl:for-each select="$sortedRespStmts/mei:respStmt">
            <xsl:if test="not(preceding-sibling::mei:respStmt = .)">
              <xsl:copy-of select="."/>
            </xsl:if>
          </xsl:for-each>
        </titleStmt>

        <!-- file edition statement -->
        <!-- UNUSED -->

        <!-- file extent -->
        <!-- UNUSED -->

        <!-- file publication statement -->
        <pubStmt>
          <!-- use <publisher> element? -->
          <respStmt>
            <corpName>
              <xsl:value-of select="$agency"/>
              <xsl:if test="$agency_code != ''">
                <xsl:text>&#32;</xsl:text>
                <xsl:text>(</xsl:text>
                <identifier authority="MARC Code List for Organizations">
                  <xsl:value-of select="$agency_code"/>
                </identifier>
                <xsl:text>)</xsl:text>
              </xsl:if>
            </corpName>
          </respStmt>
          <date>
            <xsl:value-of select="concat('[', format-date(current-date(), '[Y]'), ']')"/>
          </date>
        </pubStmt>

        <!-- file seriesStmt -->
        <!-- UNUSED -->

        <!-- sourceDesc -->
        <sourceDesc>
          <xsl:choose>
            <!-- single source if no fields with $3 -->
            <xsl:when test="count(//marc:subfield[@code = '3']) = 0">
              <source>
                <xsl:if test="$analog = 'true'">
                  <xsl:attribute name="xml:id">
                    <xsl:choose>
                      <xsl:when test="matches(marc:controlfield[@tag = '001'], '[\i-[:]][\c-[:]]*')">
                        <xsl:value-of select="marc:controlfield[@tag = '001']"/>
                      </xsl:when>
                      <xsl:when test="marc:datafield[@tag = '001']">
                        <!-- Records from Axel treat 001-009 as datafields, not controlfields -->
                        <xsl:value-of
                          select="
                            concat('_', replace(marc:datafield[@tag = '001'], '\s+',
                            ''))"
                        />
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="concat('_', marc:controlfield[@tag = '001'])"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                </xsl:if>

                <!-- system control number(s) -->
                <xsl:variable name="systemIDs" select="marc:datafield[@tag = '010' or @tag = '035']"/>
                <xsl:apply-templates select="$systemIDs"/>

                <!-- cataloging source -->
                <xsl:variable name="catalogingSource" select="marc:datafield[@tag = '040']"/>
                <xsl:apply-templates select="$catalogingSource"/>

                <!-- source title statement -->
                <titleStmt>

                  <!-- source title(s) -->
                  <xsl:apply-templates select="marc:datafield[@tag = '240' or @tag = '245']"
                    mode="diplomatic"/>

                  <!-- source statements of responsibility -->
                  <xsl:variable name="respStmts">
                    <xsl:apply-templates select="marc:datafield[@tag = '100' or @tag = '110']"/>
                    <xsl:apply-templates
                      select="
                        marc:datafield[@tag = '700' or
                        @tag = '710'][not(@ind2 = '2')]"
                      mode="respStmt"/>
                  </xsl:variable>
                  <xsl:variable name="sortedRespStmts">
                    <xsl:for-each select="$respStmts/mei:respStmt">
                      <xsl:sort
                        select="
                          mei:*[local-name() = 'persName' or
                          local-name() = 'corpName']/@analog"/>
                      <xsl:sort/>
                      <xsl:copy-of select="."/>
                    </xsl:for-each>
                  </xsl:variable>
                  <xsl:for-each select="$sortedRespStmts/mei:respStmt">
                    <xsl:if test="not(preceding-sibling::mei:respStmt = .)">
                      <xsl:copy-of select="."/>
                    </xsl:if>
                  </xsl:for-each>
                </titleStmt>

                <!-- source edition statement -->
                <xsl:if test="marc:datafield[@tag = '250']">
                  <editionStmt>
                    <xsl:apply-templates select="marc:datafield[@tag = '250']"/>
                  </editionStmt>
                </xsl:if>

                <!-- source pubStmt -->
                <xsl:if test="marc:datafield[@tag = '260' or @tag = '264']">
                  <pubStmt>
                    <xsl:apply-templates
                      select="
                        marc:datafield[@tag = '260' or
                        @tag = '264']"
                    />
                  </pubStmt>
                </xsl:if>

                <!-- source physDesc -->
                <xsl:if
                  test="
                    marc:datafield[@tag = '028' and @ind1 = '2'] or marc:datafield[@tag = '300'
                    or @tag = '306' or @tag = '561']">
                  <physDesc>
                    <xsl:apply-templates select="marc:datafield[@tag = '300']"/>
                    <xsl:apply-templates select="marc:datafield[@tag = '028'][@ind1 = '2']"/>
                    <xsl:apply-templates select="marc:datafield[@tag = '306']"/>
                    <xsl:apply-templates select="marc:datafield[@tag = '561']"/>
                  </physDesc>
                </xsl:if>

                <!-- source physLoc -->
                <xsl:apply-templates select="marc:datafield[@tag = '852']"/>

                <!-- source seriesStmt -->
                <xsl:apply-templates select="marc:datafield[@tag = '490']"/>

                <!-- source language(s) -->
                <xsl:variable name="langUsage" select="marc:datafield[@tag = '041']"/>
                <xsl:if test="$langUsage">
                  <langUsage>
                    <xsl:apply-templates select="$langUsage"/>
                  </langUsage>
                </xsl:if>

                <!-- source contents -->
                <xsl:choose>
                  <xsl:when
                    test="
                      marc:datafield[@tag = '700' or @tag = '730' or
                      @tag = '740'][@ind2 = '2']">
                    <contents>
                      <xsl:apply-templates
                        select="
                          marc:datafield[@tag = '700' or @tag = '730' or
                          @tag = '740'][@ind2 = '2']"
                        mode="contents"/>
                    </contents>
                  </xsl:when>
                  <xsl:when test="marc:datafield[@tag = '505']">
                    <contents>
                      <xsl:call-template name="analog">
                        <xsl:with-param name="tag">
                          <xsl:value-of select="'505'"/>
                        </xsl:with-param>
                      </xsl:call-template>
                      <xsl:choose>
                        <xsl:when
                          test="
                            count(distinct-values(marc:datafield[@tag = '505']/@ind1)) =
                            1">
                          <!-- all ind1 values are the same -->
                          <xsl:if
                            test="
                              not(distinct-values(marc:datafield[@tag = '505']/@ind1) =
                              '8')">
                            <!-- generate a label -->
                            <xsl:attribute name="label">
                              <xsl:choose>
                                <xsl:when
                                  test="
                                    distinct-values(marc:datafield[@tag = '505']/@ind1) =
                                    '1' and count(marc:datafield[@tag = '505']) = 1">
                                  <xsl:text>Incomplete contents</xsl:text>
                                </xsl:when>
                                <xsl:when
                                  test="
                                    distinct-values(marc:datafield[@tag = '505']/@ind1) =
                                    '2' and count(marc:datafield[@tag = '505']) = 1">
                                  <xsl:text>Partial contents</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                  <xsl:text>Contents</xsl:text>
                                </xsl:otherwise>
                              </xsl:choose>
                            </xsl:attribute>
                          </xsl:if>
                          <xsl:choose>
                            <xsl:when
                              test="
                                count(distinct-values(marc:datafield[@tag = '505']/@ind2))
                                = 1">
                              <!-- ind2 values are the same -->
                              <xsl:choose>
                                <xsl:when
                                  test="
                                    distinct-values(marc:datafield[@tag = '505']/@ind2) =
                                    '0'">
                                  <!-- "enhanced" contents -->
                                  <xsl:variable name="contentItems">
                                    <xsl:for-each select="marc:datafield[@tag = '505']">
                                      <xsl:value-of select="."/>
                                    </xsl:for-each>
                                  </xsl:variable>
                                  <xsl:analyze-string select="$contentItems" regex="--">
                                    <xsl:non-matching-substring>
                                      <contentItem>
                                        <xsl:value-of select="normalize-space(.)"/>
                                      </contentItem>
                                    </xsl:non-matching-substring>
                                  </xsl:analyze-string>
                                </xsl:when>
                                <xsl:otherwise>
                                  <!-- basic contents -->
                                  <p>
                                    <xsl:for-each select="marc:datafield[@tag = '505']">
                                      <xsl:value-of select="."/>
                                    </xsl:for-each>
                                  </p>
                                </xsl:otherwise>
                              </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                              <!-- ind2 values are NOT the same -->
                              <!-- treat as "basic" contents -->
                              <p>
                                <xsl:for-each select="marc:datafield[@tag = '505']">
                                  <xsl:value-of select="."/>
                                </xsl:for-each>
                              </p>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                          <!-- all ind1 values are NOT the same -->
                          <xsl:choose>
                            <xsl:when
                              test="
                                count(distinct-values(marc:datafield[@tag = '505']/@ind2))
                                = 1">
                              <!-- ind2 values are the same -->
                              <xsl:choose>
                                <xsl:when
                                  test="
                                    distinct-values(marc:datafield[@tag = '505']/@ind2) =
                                    '0'">
                                  <!-- "enhanced" contents -->
                                  <xsl:variable name="contentItems">
                                    <xsl:for-each select="marc:datafield[@tag = '505']">
                                      <xsl:value-of select="."/>
                                    </xsl:for-each>
                                  </xsl:variable>
                                  <xsl:analyze-string select="$contentItems" regex="--">
                                    <xsl:non-matching-substring>
                                      <contentItem>
                                        <xsl:value-of select="normalize-space(.)"/>
                                      </contentItem>
                                    </xsl:non-matching-substring>
                                  </xsl:analyze-string>
                                </xsl:when>
                                <xsl:otherwise>
                                  <!-- ind2 values are NOT the same -->
                                  <!-- treat as "basic" contents -->
                                  <p>
                                    <xsl:for-each select="marc:datafield[@tag = '505']">
                                      <xsl:call-template name="subfieldSelect">
                                        <xsl:with-param name="codes">a</xsl:with-param>
                                      </xsl:call-template>
                                    </xsl:for-each>
                                  </p>
                                </xsl:otherwise>
                              </xsl:choose>
                            </xsl:when>
                          </xsl:choose>
                        </xsl:otherwise>
                      </xsl:choose>
                    </contents>
                  </xsl:when>
                </xsl:choose>

                <!-- source notesStmt -->
                <xsl:variable name="notes">
                  <xsl:copy-of
                    select="
                      marc:datafield[@tag = '254' or @tag = '500' or
                      @tag = '504' or @tag = '506' or @tag = '510' or @tag = '520' or @tag = '525' or
                      @tag = '530' or @tag = '533' or @tag = '541' or @tag = '545' or @tag = '546' or
                      @tag = '555' or @tag = '563' or @tag = '580']"/>
                  <xsl:if test="$keepLocalNotes = 'true'">
                    <xsl:copy-of
                      select="
                        marc:datafield[@tag = '590' or @tag = '591' or
                        @tag = '592' or @tag = '593' or @tag = '594' or @tag = '596' or
                        @tag = '597' or @tag = '598' or @tag = '599']"
                    />
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$notes">
                  <notesStmt>
                    <xsl:apply-templates select="$notes/*"/>
                  </notesStmt>
                </xsl:if>

                <!-- source classification -->
                <xsl:call-template name="classification"/>

              </source>
            </xsl:when>

            <xsl:otherwise>
              <!-- source has multiple components; source contains data common to all
              components, componentGrp/source contains source-specific data -->
              <source>
                <xsl:if test="$analog = 'true'">
                  <xsl:attribute name="xml:id">
                    <xsl:choose>
                      <xsl:when test="matches(marc:controlfield[@tag = '001'], '[\i-[:]][\c-[:]]*')">
                        <xsl:value-of select="marc:controlfield[@tag = '001']"/>
                      </xsl:when>
                      <xsl:when test="marc:datafield[@tag = '001']">
                        <!-- Records from Axel treat 001-009 as datafields, not controlfields -->
                        <xsl:value-of
                          select="
                            concat('_', replace(marc:datafield[@tag = '001'], '\s+',
                            ''))"
                        />
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="concat('_', marc:controlfield[@tag = '001'])"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:attribute>
                </xsl:if>

                <!-- system control number(s) -->
                <xsl:variable name="systemIDs" select="marc:datafield[@tag = '010' or @tag = '035']"/>
                <xsl:apply-templates select="$systemIDs"/>

                <!-- cataloging source -->
                <xsl:variable name="catalogingSource" select="marc:datafield[@tag = '040']"/>
                <xsl:apply-templates select="$catalogingSource"/>

                <!-- source title statement -->
                <titleStmt>

                  <!-- source title(s) -->
                  <xsl:apply-templates select="marc:datafield[@tag = '240' or @tag = '245']"
                    mode="diplomatic"/>

                  <!-- source statements of responsibility -->
                  <xsl:variable name="respStmts">
                    <xsl:apply-templates select="marc:datafield[@tag = '100' or @tag = '110']"/>
                    <xsl:apply-templates
                      select="
                        marc:datafield[@tag = '700' or
                        @tag = '710'][not(@ind2 = '2')]"
                      mode="respStmt"/>
                  </xsl:variable>
                  <xsl:variable name="sortedRespStmts">
                    <xsl:for-each select="$respStmts/mei:respStmt">
                      <xsl:sort
                        select="
                          mei:*[local-name() = 'persName' or
                          local-name() = 'corpName']/@analog"/>
                      <xsl:sort/>
                      <xsl:copy-of select="."/>
                    </xsl:for-each>
                  </xsl:variable>
                  <xsl:for-each select="$sortedRespStmts/mei:respStmt">
                    <xsl:if test="not(preceding-sibling::mei:respStmt = .)">
                      <xsl:copy-of select="."/>
                    </xsl:if>
                  </xsl:for-each>
                </titleStmt>

                <!-- source edition statement -->
                <xsl:if test="marc:datafield[@tag = '250'][not(marc:subfield[@code = '3'])]">
                  <editionStmt>
                    <xsl:apply-templates
                      select="marc:datafield[@tag = '250'][not(marc:subfield[@code = '3'])]"/>
                  </editionStmt>
                </xsl:if>

                <!-- source pubStmt -->
                <xsl:if
                  test="
                    marc:datafield[@tag = '260' or
                    @tag = '264'][not(marc:subfield[@code = '3'])]">
                  <pubStmt>
                    <xsl:apply-templates
                      select="
                        marc:datafield[@tag = '260' or
                        @tag = '264'][not(marc:subfield[@code = '3'])]"
                    />
                  </pubStmt>
                </xsl:if>

                <!-- source physDesc -->
                <xsl:if
                  test="
                    marc:datafield[@tag = '028' and @ind1 = '2'] or marc:datafield[@tag = '300'
                    or @tag = '306' or @tag = '561'][not(marc:subfield[@code = '3'])]">
                  <physDesc>
                    <xsl:apply-templates
                      select="marc:datafield[@tag = '300'][not(marc:subfield[@code = '3'])]"/>
                    <xsl:apply-templates select="marc:datafield[@tag = '028'][@ind1 = '2']"/>
                    <xsl:apply-templates select="marc:datafield[@tag = '306']"/>
                    <xsl:apply-templates
                      select="marc:datafield[@tag = '561'][not(marc:subfield[@code = '3'])]"/>
                  </physDesc>
                </xsl:if>

                <!-- source physLoc -->
                <xsl:apply-templates
                  select="marc:datafield[@tag = '852'][not(marc:subfield[@code = '3'])]"/>

                <!-- source seriesStmt -->
                <xsl:apply-templates
                  select="marc:datafield[@tag = '490'][not(marc:subfield[@code = '3'])]"/>

                <!-- source contents -->
                <xsl:choose>
                  <xsl:when
                    test="
                      marc:datafield[@tag = '700' or @tag = '730' or
                      @tag = '740'][@ind2 = '2']">
                    <contents>
                      <xsl:apply-templates
                        select="
                          marc:datafield[@tag = '700' or @tag = '730' or
                          @tag = '740'][@ind2 = '2']"
                        mode="contents"/>
                    </contents>
                  </xsl:when>
                  <xsl:when test="marc:datafield[@tag = '505']">
                    <xsl:apply-templates select="marc:datafield[@tag = '505']"/>
                  </xsl:when>
                </xsl:choose>

                <!-- source language(s) -->
                <xsl:variable name="langUsage" select="marc:datafield[@tag = '041']"/>
                <xsl:if test="$langUsage">
                  <langUsage>
                    <xsl:apply-templates select="$langUsage"/>
                  </langUsage>
                </xsl:if>

                <!-- source notesStmt -->
                <xsl:variable name="notes">
                  <xsl:copy-of
                    select="
                      marc:datafield[@tag = '254' or @tag = '500' or
                      @tag = '504' or @tag = '506' or @tag = '510' or @tag = '520' or @tag = '525' or
                      @tag = '533' or @tag = '541' or @tag = '545' or @tag = '546' or @tag = '555' or
                      @tag = '563' or @tag = '580'][not(marc:subfield[@code = '3'])]"/>
                  <xsl:if test="$keepLocalNotes = 'true'">
                    <xsl:copy-of
                      select="
                        marc:datafield[@tag = '590' or @tag = '591' or
                        @tag = '592' or @tag = '593' or @tag = '594' or @tag = '596' or @tag = '597' or
                        @tag = '598' or @tag = '599'][not(marc:subfield[@code = '3'])]"
                    />
                  </xsl:if>
                </xsl:variable>
                <xsl:if test="$notes">
                  <notesStmt>
                    <xsl:apply-templates select="$notes/*"/>
                  </notesStmt>
                </xsl:if>

                <!-- source classification -->
                <xsl:call-template name="classification"/>

                <!-- source components -->
                <!-- $componentContent contains copy of datafields that have subfield 3 -->
                <xsl:variable name="componentContent">
                  <xsl:copy-of
                    select="
                      marc:datafield[@tag = '250' or @tag = '260' or
                      @tag = '264' or @tag = '300' or @tag = '490' or @tag = '500' or
                      @tag = '504' or @tag = '506' or @tag = '510' or @tag = '520' or
                      @tag = '521' or @tag = '524' or @tag = '530' or @tag = '533' or
                      @tag = '534' or @tag = '535' or @tag = '540' or @tag = '541' or
                      @tag = '542' or @tag = '544' or @tag = '546' or @tag = '561' or
                      @tag = '563' or @tag = '581' or @tag = '585' or @tag = '586' or
                      @tag = '852'][marc:subfield[@code = '3']]"/>
                  <xsl:if test="$keepLocalNotes = 'true'">
                    <xsl:copy-of
                      select="
                        marc:datafield[@tag = '590' or @tag = '591' or
                        @tag = '592' or @tag = '593' or @tag = '594' or @tag = '596' or
                        @tag = '597' or @tag = '598' or @tag = '599']"
                    />
                  </xsl:if>
                </xsl:variable>
                <componentGrp>
                  <xsl:for-each-group select="$componentContent/*"
                    group-by="marc:subfield[@code = '3']">
                    <xsl:sort select="current-grouping-key()"/>
                    <source>
                      <xsl:attribute name="label">
                        <xsl:value-of select="current-grouping-key()"/>
                      </xsl:attribute>

                      <!-- component edition statement -->
                      <xsl:if test="$componentContent/marc:datafield[@tag = '250']">
                        <editionStmt>
                          <xsl:apply-templates
                            select="$componentContent/marc:datafield[@tag = '250']"/>
                        </editionStmt>
                      </xsl:if>

                      <!-- component pubStmt -->
                      <xsl:if
                        test="
                          $componentContent/marc:datafield[@tag = '260' or
                          @tag = '264'][marc:subfield[@code = '3'] = current-grouping-key()]">
                        <pubStmt>
                          <xsl:apply-templates
                            select="
                              $componentContent/marc:datafield[@tag = '260'
                              or @tag = '264'][marc:subfield[@code = '3'] = current-grouping-key()]"
                          />
                        </pubStmt>
                      </xsl:if>

                      <!-- component physDesc -->
                      <xsl:if
                        test="
                          $componentContent/marc:datafield[@tag = '300' or
                          @tag = '561'][marc:subfield[@code = '3'] = current-grouping-key()]">
                        <physDesc>
                          <xsl:apply-templates
                            select="
                              $componentContent/marc:datafield[@tag = '300'
                              or @tag = '561'][marc:subfield[@code = '3'] = current-grouping-key()]"
                          />
                        </physDesc>
                      </xsl:if>

                      <!-- component physLoc -->
                      <xsl:apply-templates
                        select="
                          $componentContent/marc:datafield[@tag = '852'][marc:subfield[@code = '3']
                          = current-grouping-key()]"/>

                      <!-- component seriesStmt -->
                      <xsl:apply-templates
                        select="
                          $componentContent/marc:datafield[@tag = '490'][marc:subfield[@code = '3']
                          = current-grouping-key()]"/>

                      <!-- component notesStmt -->
                      <xsl:variable name="sourceNotes">
                        <xsl:copy-of
                          select="
                            $componentContent/marc:datafield[@tag = '254' or
                            @tag = '500' or @tag = '504' or @tag = '506' or @tag = '510' or @tag = '520' or
                            @tag = '525' or @tag = '530' or @tag = '533' or @tag = '541' or @tag = '545' or
                            @tag = '546' or @tag = '555' or @tag = '563' or
                            @tag = '580'][marc:subfield[@code = '3']]"/>
                        <xsl:if test="$keepLocalNotes = 'true'">
                          <xsl:copy-of
                            select="
                              $componentContent/marc:datafield[@tag = '590' or
                              @tag = '591' or @tag = '592' or @tag = '593' or @tag = '594' or
                              @tag = '596' or @tag = '597' or @tag = '598'][marc:subfield[@code = '3']]"
                          />
                        </xsl:if>
                      </xsl:variable>
                      <xsl:if test="$sourceNotes/*">
                        <notesStmt>
                          <xsl:apply-templates
                            select="
                              $sourceNotes/marc:*[marc:subfield[@code = '3']
                              = current-grouping-key()]"
                          />
                        </notesStmt>
                      </xsl:if>
                    </source>
                  </xsl:for-each-group>
                </componentGrp>
              </source>
            </xsl:otherwise>
          </xsl:choose>
        </sourceDesc>
      </fileDesc>

      <!-- encodingDesc -->
      <encodingDesc>
        <appInfo>
          <application>
            <xsl:attribute name="version">
              <xsl:value-of select="replace($version, '\s+', '_')"/>
            </xsl:attribute>
            <name>
              <xsl:value-of select="$progname"/>
            </name>
          </application>
        </appInfo>
      </encodingDesc>

      <!-- work description -->
      <workDesc>
        <work>
          <!-- work title(s) -->
          <titleStmt>
            <xsl:apply-templates
              select="marc:datafield[@tag = '130' or @tag = '240' or @tag = '245']"
              mode="titleProper"/>
            <!-- work statements of responsibility -->
            <xsl:variable name="respStmts">
              <xsl:apply-templates select="marc:datafield[@tag = '100' or @tag = '110']"/>
              <xsl:if test="not($workMainEntryOnly = 'true')">
                <xsl:apply-templates select="marc:datafield[@tag = '700' or @tag = '710']"
                  mode="respStmt"/>
              </xsl:if>
            </xsl:variable>
            <xsl:variable name="sortedRespStmts">
              <xsl:for-each select="$respStmts/mei:respStmt">
                <xsl:sort
                  select="
                    mei:*[local-name() = 'persName' or
                    local-name() = 'corpName']/@analog"/>
                <xsl:sort/>
                <xsl:copy-of select="."/>
              </xsl:for-each>
            </xsl:variable>
            <xsl:for-each select="$sortedRespStmts/mei:respStmt">
              <xsl:if test="not(preceding-sibling::mei:respStmt = .)">
                <xsl:copy-of select="."/>
              </xsl:if>
            </xsl:for-each>
          </titleStmt>

          <!-- work creation -->
          <xsl:variable name="creation_note"
            select="
              marc:datafield[(@tag = '045' and
              marc:subfield[@code = 'b']) or @tag = '508']"/>

          <!-- work incipits -->
          <xsl:apply-templates select="marc:datafield[@tag = '031']"/>
          <xsl:apply-templates
            select="
              marc:datafield[@tag = '246' and
              matches(marc:subfield[@code = 'i'], 'First\s+line\s+of\s+text', 'i')]"/>

          <!-- work eventList -->
          <xsl:variable name="events" select="marc:datafield[@tag = '511' or @tag = '518']"/>
          <xsl:if test="$creation_note or $events">
            <history>
              <xsl:if test="$creation_note">
                <creation>
                  <xsl:call-template name="analog">
                    <xsl:with-param name="tag">
                      <xsl:choose>
                        <xsl:when test="marc:datafield[@tag = '508']">
                          <xsl:value-of select="'508'"/>
                        </xsl:when>
                        <xsl:when test="marc:datafield[@tag = '045']">
                          <xsl:value-of select="'045'"/>
                        </xsl:when>
                      </xsl:choose>
                    </xsl:with-param>
                  </xsl:call-template>
                  <xsl:for-each select="marc:datafield[@tag = '508']">
                    <xsl:apply-templates select="."/>
                    <xsl:if test="position() != last()">
                      <xsl:text>;&#32;</xsl:text>
                    </xsl:if>
                  </xsl:for-each>
                  <xsl:if test="marc:datafield[@tag = '508'] and marc:datafield[@tag = '045']">
                    <xsl:text>&#32;</xsl:text>
                  </xsl:if>
                  <xsl:apply-templates select="marc:datafield[@tag = '045']"/>
                </creation>
              </xsl:if>
              <xsl:if test="$events">
                <eventList>
                  <xsl:apply-templates select="$events"/>
                </eventList>
              </xsl:if>
            </history>
          </xsl:if>

          <!-- work language(s) -->
          <xsl:if test="not(substring(marc:controlfield[@tag = '008'], 36, 3) = 'zxx')">
            <xsl:call-template name="workLang"/>
          </xsl:if>

          <!-- work cast list -->
          <xsl:variable name="instrumentation" select="marc:datafield[@tag = '048']"/>
          <xsl:variable name="castNotes" select="marc:datafield[@tag = '595']"/>
          <xsl:if test="$instrumentation or ($castNotes and $keepLocalNotes = 'true')">
            <perfMedium>
              <xsl:if test="$castNotes and $keepLocalNotes = 'true'">
                <castList>
                  <xsl:variable name="sortedCastList">
                    <xsl:apply-templates select="$castNotes">
                      <xsl:sort/>
                    </xsl:apply-templates>
                  </xsl:variable>
                  <xsl:variable name="uniqueItems">
                    <xsl:for-each select="$sortedCastList/mei:castItem">
                      <xsl:if test="not(preceding-sibling::mei:castItem = .)">
                        <xsl:copy-of select="."/>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:variable>
                  <xsl:for-each select="$uniqueItems/mei:castItem">
                    <xsl:sort select="@analog"/>
                    <xsl:copy-of select="."/>
                  </xsl:for-each>
                </castList>
              </xsl:if>
              <xsl:if test="$instrumentation">
                <instrumentation>
                  <xsl:apply-templates select="$instrumentation"/>
                </instrumentation>
              </xsl:if>
            </perfMedium>
          </xsl:if>
        </work>
      </workDesc>

      <!-- file revision history -->
      <revisionDesc>
        <change>
          <respStmt/>
          <changeDesc>
            <p>Header generated using <xsl:value-of select="$progname"/>, version <xsl:value-of
                select="$version"/></p>
          </changeDesc>
          <date>
            <xsl:attribute name="isodate">
              <xsl:value-of select="format-date(current-date(), '[Y]-[M02]-[D02]')"/>
            </xsl:attribute>
          </date>
        </change>
      </revisionDesc>
    </meiHead>
  </xsl:template>

  <!-- LC control number -->
  <xsl:template match="marc:datafield[@tag = '010']">
    <xsl:variable name="tag" select="@tag"/>
    <identifier>
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="$tag"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="subfieldSelect">
        <xsl:with-param name="codes">ab</xsl:with-param>
      </xsl:call-template>
    </identifier>
  </xsl:template>

  <!-- ISBN -->
  <xsl:template match="marc:datafield[@tag = '020']">
    <identifier type="isbn">
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="@tag"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="subfieldSelect">
        <xsl:with-param name="codes">a</xsl:with-param>
      </xsl:call-template>
    </identifier>
  </xsl:template>

  <!-- ISSN -->
  <xsl:template match="marc:datafield[@tag = '022']">
    <identifier type="issn">
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="@tag"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="subfieldSelect">
        <xsl:with-param name="codes">a</xsl:with-param>
      </xsl:call-template>
    </identifier>
  </xsl:template>

  <!-- Other standard number -->
  <xsl:template match="marc:datafield[@tag = '024']">
    <identifier>
      <xsl:variable name="identifierType">
        <xsl:choose>
          <xsl:when test="@ind1 = '0'">isrc</xsl:when>
          <xsl:when test="@ind1 = '1'">upc</xsl:when>
          <xsl:when test="@ind1 = '2'">ismn</xsl:when>
          <xsl:when test="@ind1 = '3'">ian</xsl:when>
          <xsl:when test="@ind1 = '4'">sici</xsl:when>
          <xsl:when test="@ind1 = '7'">other</xsl:when>
          <xsl:when test="@ind1 = '8'">unspecified</xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="identifierLabel">
        <xsl:choose>
          <xsl:when test="@ind1 = '0'">International Standard Recording Code</xsl:when>
          <xsl:when test="@ind1 = '1'">Universal Product Code</xsl:when>
          <xsl:when test="@ind1 = '2'">International Standard Music Number</xsl:when>
          <xsl:when test="@ind1 = '3'">International Article Number</xsl:when>
          <xsl:when test="@ind1 = '4'">Serial Item and Contribution Identifier</xsl:when>
          <xsl:when test="@ind1 = '7'">
            <xsl:value-of select="marc:subfield[@code = '2']"/>
          </xsl:when>
          <xsl:when test="@ind1 = '8'">unspecified</xsl:when>
        </xsl:choose>
      </xsl:variable>
      <xsl:attribute name="type">
        <xsl:value-of select="$identifierType"/>
      </xsl:attribute>
      <!--<xsl:attribute name="label">
        <xsl:value-of select="$identifierLabel"/>
      </xsl:attribute>-->
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="@tag"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="subfieldSelect">
        <xsl:with-param name="codes">a</xsl:with-param>
      </xsl:call-template>
    </identifier>
  </xsl:template>

  <!-- plate number (028) -->
  <xsl:template match="marc:datafield[@tag = '028']">
    <xsl:variable name="tag" select="@tag"/>
    <xsl:variable name="elementName">
      <xsl:choose>
        <xsl:when test="@ind1 = '2'">plateNum</xsl:when>
        <xsl:otherwise>identifier</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$elementName}">
      <xsl:if test="$elementName = 'identifier'">
        <xsl:variable name="identifierType">
          <xsl:choose>
            <xsl:when test="@ind1 = '0'">issue</xsl:when>
            <xsl:when test="@ind1 = '1'">matrix</xsl:when>
            <xsl:when test="@ind1 = '3'">otherMusic</xsl:when>
            <xsl:when test="@ind1 = '4'">videorecording</xsl:when>
            <xsl:when test="@ind1 = '5'">publisher</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="type">
          <xsl:value-of select="concat($identifierType, 'Number')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="@tag"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="subfieldSelect">
        <xsl:with-param name="codes">a</xsl:with-param>
      </xsl:call-template>
      <!-- plate number source -->
      <xsl:if test="marc:subfield[@code = 'b']">
        <xsl:text> (</xsl:text>
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">b</xsl:with-param>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <!-- incipit -->
  <xsl:template match="marc:datafield[@tag = '031']">
    <incip>
      <xsl:attribute name="n">
        <xsl:value-of
          select="
            normalize-space(concat(marc:subfield[@code = 'a'], '&#32;',
            marc:subfield[@code = 'b'], '&#32;', marc:subfield[@code = 'c']))"
        />
      </xsl:attribute>
      <xsl:attribute name="label">
        <xsl:choose>
          <xsl:when test="marc:subfield[@code = 'd']">
            <xsl:value-of select="marc:subfield[@code = 'd'][1]"/>
          </xsl:when>
          <xsl:when test="marc:subfield[@code = 'e']">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="marc:subfield[@code = 'e'][1]"/>
            <xsl:text>]</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:attribute>

      <!-- Not currently allowed; customization required -->
      <!-- <label>
        <xsl:choose>
          <xsl:when test="marc:subfield[@code='d']">
            <xsl:value-of select="marc:subfield[@code='d'][1]"/>
          </xsl:when>
          <xsl:when test="marc:subfield[@code='e']">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="marc:subfield[@code='e'][1]"/>
            <xsl:text>]</xsl:text>
          </xsl:when>
        </xsl:choose>
      </label>
      <xsl:if test="marc:subfield[@code='r']">
        <key>
          <xsl:variable name="key" select="marc:subfield[@code='r']"/>
          <xsl:choose>
            <!-\- minor key -\->
            <xsl:when test="matches(substring($key, 1, 1), '[a-g]')">
              <xsl:value-of select="translate(substring($key, 1, 1), 'abcdefg',
                'ABCDEFG')"/>
              <xsl:value-of select="normalize-space(substring($key, 2, 1))"/>
              <xsl:text> minor</xsl:text>
            </xsl:when>
            <!-\- major key -\->
            <xsl:when test="matches(substring($key, 1, 1), '[A-G]')">
              <xsl:value-of select="substring($key, 1, 1)"/>
              <xsl:value-of select="normalize-space(substring($key, 2, 1))"/>
              <xsl:text> major</xsl:text>
            </xsl:when>
            <!-\- coding error -\->
            <xsl:otherwise>
              <xsl:value-of select="$key"/>
              <xsl:comment>potential coding error?</xsl:comment>
            </xsl:otherwise>
          </xsl:choose>
        </key>
      </xsl:if>
      <xsl:if test="marc:subfield[@code='o']">
        <meter>
          <xsl:value-of select="upper-case(marc:subfield[@code='o'])"/>
        </meter>
      </xsl:if>
      <xsl:if test="count(marc:subfield[@code='d']) &gt; 1">
        <tempo>
          <xsl:variable name="tempo">
            <xsl:for-each select="marc:subfield[@code='d'][position() &gt; 1]">
              <xsl:value-of select="."/>
              <xsl:if test="position() != last()">
                <xsl:text>; </xsl:text>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:value-of select="normalize-space($tempo)"/>
        </tempo>
      </xsl:if> -->

      <xsl:if test="marc:subfield[@code = 'p']">
        <incipCode>
          <xsl:attribute name="form">
            <xsl:choose>
              <xsl:when test="marc:subfield[@code = '2'] = 'pe'">
                <xsl:text>plaineAndEasie</xsl:text>
              </xsl:when>
            </xsl:choose>
          </xsl:attribute>
          <xsl:call-template name="analog">
            <xsl:with-param name="tag">
              <xsl:value-of select="concat(@tag, '|p')"/>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:value-of select="marc:subfield[@code = 'p']"/>
        </incipCode>
      </xsl:if>
      <xsl:if test="marc:subfield[@code = 't']">
        <incipText>
          <xsl:call-template name="analog">
            <xsl:with-param name="tag">
              <xsl:value-of select="concat(@tag, '|t')"/>
            </xsl:with-param>
          </xsl:call-template>
          <p>
            <xsl:value-of select="marc:subfield[@code = 't']"/>
          </p>
        </incipText>
      </xsl:if>
    </incip>
  </xsl:template>

  <!-- system control number -->
  <xsl:template match="marc:datafield[@tag = '035']">
    <xsl:variable name="tag" select="@tag"/>
    <identifier>
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="$tag"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="subfieldSelect">
        <xsl:with-param name="codes">a</xsl:with-param>
      </xsl:call-template>
    </identifier>
  </xsl:template>

  <!-- source of cataloging -->
  <xsl:template match="marc:datafield[@tag = '040']">
    <xsl:variable name="tag" select="@tag"/>
    <xsl:for-each select="marc:subfield[@code = 'a' or @code = 'c' or @code = 'd']">
      <identifier>
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="concat($tag, '|', @code)"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:value-of select="."/>
      </identifier>
    </xsl:for-each>
  </xsl:template>

  <!-- language -->
  <xsl:template match="marc:datafield[@tag = '041']">
    <xsl:for-each select="marc:subfield[matches(@code, '[a-gjkm]')]">
      <language>
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="concat(../@tag, '|', @code)"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:attribute name="label">
          <xsl:choose>
            <xsl:when test="@code = 'a'">text/sound track</xsl:when>
            <xsl:when test="@code = 'b'">summary/abstract</xsl:when>
            <xsl:when test="@code = 'd'">sung/spoken text</xsl:when>
            <xsl:when test="@code = 'e'">libretto</xsl:when>
            <xsl:when test="@code = 'f'">table of contents</xsl:when>
            <xsl:when test="@code = 'g'">accompanying material</xsl:when>
            <xsl:when test="@code = 'h'">original</xsl:when>
            <xsl:when test="@code = 'k'">intermediate translation</xsl:when>
            <xsl:when test="@code = 'j'">subtitles/captions</xsl:when>
            <xsl:when test="@code = 'm'">original accompanying material</xsl:when>
            <xsl:when test="@code = 'n'">original libretto</xsl:when>
          </xsl:choose>
        </xsl:attribute>
        <xsl:variable name="langCode">
          <xsl:value-of select="."/>
        </xsl:variable>
        <xsl:value-of select="$marcLangList/mei:lang[@code = $langCode]"/>
      </language>
    </xsl:for-each>
  </xsl:template>

  <!-- date of composition -->
  <xsl:template match="marc:datafield[@tag = '045']">
    <!-- dates in 045 are assumed to be C.E. -->
    <!--<xsl:text>Date of composition:&#32;</xsl:text>-->
    <xsl:choose>
      <xsl:when test="@ind1 = ' ' and @ind2 = ' '">
        <!-- Not yet dealt with. -->
      </xsl:when>
      <xsl:when test="@ind1 = '0' or @ind1 = '1'">
        <xsl:for-each select="marc:subfield[@code = 'b']">
          <date>
            <xsl:attribute name="isodate">
              <xsl:value-of select="substring(., 2, 8)"/>
            </xsl:attribute>
            <xsl:call-template name="analog">
              <xsl:with-param name="tag">
                <xsl:value-of select="'045|b'"/>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:value-of select="substring(., 2)"/>
          </date>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="@ind1 = '2'">
        <xsl:variable name="sortedDates">
          <xsl:for-each select="marc:subfield[@code = 'b']">
            <xsl:sort/>
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </xsl:variable>
        <date>
          <xsl:attribute name="notbefore">
            <xsl:value-of select="substring($sortedDates/marc:subfield[@code = 'b'][1], 2, 8)"/>
          </xsl:attribute>
          <xsl:attribute name="notafter">
            <xsl:value-of
              select="substring($sortedDates/marc:subfield[@code = 'b'][position() = last()], 2, 8)"
            />
          </xsl:attribute>
          <xsl:for-each select="marc:subfield[@code = 'b']">
            <date>
              <xsl:call-template name="analog">
                <xsl:with-param name="tag">
                  <xsl:value-of select="'045|b'"/>
                </xsl:with-param>
              </xsl:call-template>
              <xsl:value-of select="substring(., 2)"/>
            </date>
          </xsl:for-each>
        </date>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- musical form -->
  <xsl:template match="marc:datafield[@tag = '047']">
    <xsl:variable name="ind2" select="@ind2"/>
    <xsl:variable name="classcode">
      <xsl:choose>
        <xsl:when test="$ind2 = ' '">
          <xsl:text>MFMC</xsl:text>
        </xsl:when>
        <xsl:when test="$ind2 = '7' and marc:subfield[@code = '2'] = 'iamlmf'">
          <xsl:text>IFMC</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="replace(marc:subfield[@code = '2'], '&#32;', '_')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:for-each select="marc:subfield[@code = 'a']">
      <term label="musForm">
        <xsl:if test="not($classcode = '')">
          <xsl:attribute name="classcode" select="concat('#', $classcode)"/>
        </xsl:if>
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="'047'"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:variable name="form">
          <xsl:value-of select="."/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="../@ind2 = '7' and ../marc:subfield[@code = '2'] = 'iamlmf'">
            <xsl:value-of select="$iamlFormList/mei:form[@code = $form]"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$marcFormList/mei:form[@code = $form]"/>
          </xsl:otherwise>
        </xsl:choose>
      </term>
    </xsl:for-each>
  </xsl:template>

  <!-- scoring -->
  <xsl:template match="marc:datafield[@tag = '048']">
    <instrVoiceList>
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="'048'"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="@ind2 = '7' and matches(marc:subfield[@code = '2'], 'iamlmp', 'i')">
          <!-- Use IAML Medium of Performance codes -->
          <xsl:attribute name="authority">iamlmp</xsl:attribute>
          <xsl:attribute name="authURI"
            >http://www.iaml.info/en/activities/cataloguing/unimarc/medium</xsl:attribute>
          <xsl:for-each select="marc:subfield[@code = 'a' or @code = 'b']">
            <instrVoice>
              <xsl:if test="@code = 'b'">
                <xsl:attribute name="solo">true</xsl:attribute>
              </xsl:if>
              <xsl:variable name="code048" select="substring(., 1, 3)"/>
              <xsl:variable name="num048" select="substring(., 4, 2)"/>
              <xsl:attribute name="code">
                <xsl:value-of select="$code048"/>
              </xsl:attribute>
              <xsl:if test="number($num048)">
                <xsl:attribute name="count">
                  <xsl:value-of select="number($num048)"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:value-of select="$iamlMusPerfList/mei:instr[@code = $code048]"/>
            </instrVoice>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <!-- Use MARC Instruments and Voices Code List -->
          <xsl:attribute name="authority">marcmusperf</xsl:attribute>
          <xsl:attribute name="authURI"
            >http://www.loc.gov/standards/valuelist/marcmusperf.html</xsl:attribute>
          <xsl:for-each select="marc:subfield[@code = 'a' or @code = 'b']">
            <instrVoice>
              <xsl:if test="@code = 'b'">
                <xsl:attribute name="solo">true</xsl:attribute>
              </xsl:if>
              <xsl:variable name="code048" select="substring(., 1, 2)"/>
              <xsl:variable name="num048" select="substring(., 3, 2)"/>
              <xsl:attribute name="code">
                <xsl:value-of select="$code048"/>
              </xsl:attribute>
              <xsl:if test="number($num048)">
                <xsl:attribute name="count">
                  <xsl:value-of select="number($num048)"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:value-of select="$marcMusPerfList/mei:instr[@code = $code048]"/>
            </instrVoice>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </instrVoiceList>
  </xsl:template>

  <!-- classification -->
  <xsl:template
    match="
      marc:datafield[@tag = '050' or @tag = '082' or @tag = '648' or @tag = '600' or
      @tag = '650' or @tag = '651' or @tag = '653' or @tag = '654' or @tag = '655' or @tag = '656' or
      @tag = '657' or @tag = '658' or (number(@tag) >= 90 and number(@tag) &lt;= 99)]">
    <xsl:variable name="tag" select="@tag"/>
    <xsl:variable name="label">
      <xsl:choose>
        <xsl:when test="$tag = '050'">callNum</xsl:when>
        <xsl:when test="$tag = '082'">callNum</xsl:when>
        <xsl:when test="number($tag) >= 90 and number($tag) &lt;= 99">callNum</xsl:when>
        <xsl:when test="$tag = '600'">persName</xsl:when>
        <xsl:when test="$tag = '650'">topic</xsl:when>
        <xsl:when test="$tag = '651'">geogName</xsl:when>
        <xsl:when test="$tag = '654'">facet</xsl:when>
        <xsl:when test="$tag = '655'">genreForm</xsl:when>
        <xsl:when test="$tag = '656'">occupation</xsl:when>
        <xsl:when test="$tag = '657'">function</xsl:when>
        <xsl:when test="$tag = '658'">curriculum</xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="ind2" select="@ind2"/>
    <xsl:variable name="classcode">
      <xsl:choose>
        <xsl:when test="$tag = '050'">LCCN</xsl:when>
        <xsl:when test="$tag = '082'">DDC</xsl:when>
        <xsl:when test="number($tag) >= 90 and number($tag) &lt;= 99">
          <xsl:value-of select="concat('LocalNum', $tag)"/>
        </xsl:when>
        <xsl:when test="$ind2 = '0'">LCSH</xsl:when>
        <xsl:when test="$ind2 = '1'">LCCL</xsl:when>
        <xsl:when test="$ind2 = '2'">MeSH</xsl:when>
        <xsl:when test="$ind2 = '3'">NALSA</xsl:when>
        <xsl:when test="$ind2 = '5'">CSH</xsl:when>
        <xsl:when test="$ind2 = '6'">RVM</xsl:when>
        <xsl:when test="$ind2 = '7'">
          <xsl:value-of select="replace(marc:subfield[@code = '2'], '&#32;', '_')"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <term>
      <xsl:if test="not($label = '')">
        <xsl:attribute name="label">
          <xsl:value-of select="$label"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="not($classcode = '')">
        <xsl:attribute name="classcode" select="concat('#', $classcode)"/>
      </xsl:if>
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="$tag"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="chopString">
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">
              <xsl:choose>
                <xsl:when test="$tag = '050' or $tag = '082'">
                  <xsl:text>ab</xsl:text>
                </xsl:when>
                <xsl:when test="number($tag) >= 90 and number($tag) &lt;= 99">
                  <xsl:text>abcdefghijklmnopqrstuvwxyz</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>abcdetvxyz</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="delimiter">
              <xsl:choose>
                <xsl:when
                  test="
                    $tag = '050' or $tag = '082' or number($tag) >= 90 and
                    number($tag) &lt;= 99">
                  <xsl:text>&#32;</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>,&#32;</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="chop">yes</xsl:with-param>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </term>
  </xsl:template>

  <!-- main entry -->
  <xsl:template match="marc:datafield[@tag = '100' or @tag = '110']">
    <xsl:variable name="tag">
      <xsl:value-of select="@tag"/>
    </xsl:variable>
    <!-- each name is contained within a <respStmt> to account for possible <resp>
      elements -->
    <respStmt>
      <xsl:choose>
        <xsl:when test="$tag = '110'">
          <!-- corporate name; use subfield a (non-repeatable) -->
          <corpName role="creator">
            <xsl:if test="marc:subfield[@code = '0']">
              <xsl:attribute name="dbkey">
                <xsl:value-of select="marc:subfield[@code = '0']"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="analog">
              <xsl:with-param name="tag">
                <xsl:value-of select="concat($tag, '|a')"/>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="subfieldSelect">
              <xsl:with-param name="codes">abcd</xsl:with-param>
            </xsl:call-template>
          </corpName>
        </xsl:when>
        <xsl:otherwise>
          <!-- personal name; use subfields a and d -->
          <persName role="creator">
            <xsl:if test="marc:subfield[@code = '0']">
              <xsl:attribute name="dbkey">
                <xsl:value-of select="marc:subfield[@code = '0']"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="analog">
              <xsl:with-param name="tag">
                <xsl:value-of select="concat($tag, '|a')"/>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:choose>
              <xsl:when test="marc:subfield[@code = 'd']">
                <xsl:call-template name="subfieldSelect">
                  <xsl:with-param name="codes">abcjq</xsl:with-param>
                </xsl:call-template>
                <xsl:text>&#32;</xsl:text>
                <date>
                  <xsl:call-template name="analog">
                    <xsl:with-param name="tag">
                      <xsl:value-of select="concat($tag, '|d')"/>
                    </xsl:with-param>
                  </xsl:call-template>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                      <xsl:value-of select="marc:subfield[@code = 'd']"/>
                    </xsl:with-param>
                  </xsl:call-template>
                </date>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="subfieldSelect">
                  <xsl:with-param name="codes">abcjq</xsl:with-param>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </persName>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="marc:subfield[@code = '4']">
          <xsl:apply-templates select="marc:subfield[@code = '4']" mode="respStmt"/>
        </xsl:when>
        <xsl:when test="marc:subfield[@code = 'e']">
          <xsl:apply-templates select="marc:subfield[@code = 'e']" mode="respStmt"/>
        </xsl:when>
      </xsl:choose>
    </respStmt>
  </xsl:template>

  <!-- uniform title -->
  <xsl:template match="marc:datafield[@tag = '130' or @tag = '240']" mode="titleProper">
    <xsl:variable name="tag" select="@tag"/>
    <title type="uniform">
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="$tag"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="chopString">
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">a</xsl:with-param>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>

      <!-- test for certain other subfields to append to main value -->
      <!-- some subfields are repeatable, so loop through all -->
      <xsl:for-each
        select="
          marc:subfield[@code = 'k' or @code = 'm' or @code = 'n' or @code = 'o' or
          @code = 'p' or @code = 'r' or @code = 's']">
        <xsl:choose>
          <xsl:when test="@code = 'r'">
            <!-- subfield r = 'Key for music'; add 'in' -->
            <xsl:text>, in </xsl:text>
            <xsl:choose>
              <xsl:when test="position() = last()">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:value-of select="."/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>, </xsl:text>
            <xsl:choose>
              <xsl:when test="position() = last()">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:value-of select="."/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </title>
  </xsl:template>

  <!-- Traditionally, "title proper" is the chief name of an item, including any 
    alternative title but excluding parallel titles and other title information.
    This template includes parallel titles, but ignores the statement of responsibility,
    inclusive or bulk dates, and physical medium, which are recorded elsewhere. -->
  <xsl:template match="marc:datafield[@tag = '245']" mode="titleProper">
    <title type="proper">
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="concat(@tag, '|a-b')"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:variable name="titleProper">
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">ab</xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="replace($titleProper, '\s*/\s*$', '')"/>
      <!-- test for certain other subfields to append to main value -->
      <!-- some subfields are repeatable, so loop through all -->
      <xsl:for-each select="marc:subfield[@code = 'n' or @code = 'p']">
        <xsl:text>, </xsl:text>
        <xsl:call-template name="chopPunctuation">
          <xsl:with-param name="chopString">
            <xsl:value-of select="."/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </title>
  </xsl:template>

  <!-- diplomatic title -->
  <xsl:template match="marc:datafield[@tag = '130' or @tag = '240' or @tag = '245']"
    mode="diplomatic">
    <title>
      <xsl:attribute name="type">
        <xsl:choose>
          <xsl:when test="@tag = '245'">
            <xsl:text>diplomatic</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>uniform</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:for-each select="marc:subfield[not(@code = '0' or @code = '6' or @code = '8')]">
        <title>
          <xsl:call-template name="analog">
            <xsl:with-param name="tag">
              <xsl:value-of select="concat(../@tag, '|', @code)"/>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:value-of select="."/>
        </title>
      </xsl:for-each>
    </title>
  </xsl:template>

  <!-- text incipit (246) -->
  <xsl:template
    match="
      marc:datafield[@tag = '246' and matches(marc:subfield[@code = 'i'],
      'First\s+line\s+of\s+text', 'i')]">
    <incip>
      <xsl:if test="marc:subfield[@code = 'a']">
        <incipText>
          <xsl:call-template name="analog">
            <xsl:with-param name="tag">
              <xsl:value-of select="concat(@tag, '|a')"/>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:attribute name="label">
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="marc:subfield[@code = 'i']"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:attribute>
          <p>
            <xsl:value-of select="marc:subfield[@code = 'a']"/>
          </p>
        </incipText>
      </xsl:if>
    </incip>
  </xsl:template>

  <!-- edition statement -->
  <xsl:template match="marc:datafield[@tag = '250']">
    <edition>
      <xsl:variable name="tag" select="@tag"/>
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="$tag"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="subfieldSelect">
        <xsl:with-param name="codes">ab</xsl:with-param>
      </xsl:call-template>
    </edition>
  </xsl:template>

  <!-- music presentation -->
  <xsl:template match="marc:datafield[@tag = '254']">
    <xsl:variable name="tag" select="@tag"/>
    <annot type="musical_presentation">
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="$tag"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="subfieldSelect">
        <xsl:with-param name="codes">a</xsl:with-param>
      </xsl:call-template>
    </annot>
  </xsl:template>

  <!-- publication statement -->
  <xsl:template match="marc:datafield[@tag = '260'] | marc:datafield[@tag = '264' and @ind2 = '1']">
    <xsl:for-each select="marc:subfield">
      <xsl:choose>
        <xsl:when test="@code = 'a'">
          <pubPlace>
            <xsl:call-template name="analog">
              <xsl:with-param name="tag">
                <xsl:value-of select="concat(../@tag, '|a')"/>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:value-of select="."/>
          </pubPlace>
        </xsl:when>
        <xsl:when test="@code = 'b'">
          <publisher>
            <xsl:call-template name="analog">
              <xsl:with-param name="tag">
                <xsl:value-of select="concat(../@tag, '|b')"/>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:value-of select="."/>
          </publisher>
        </xsl:when>
        <xsl:when test="@code = 'c'">
          <date>
            <xsl:call-template name="analog">
              <xsl:with-param name="tag">
                <xsl:value-of select="concat(../@tag, '|c')"/>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:value-of select="."/>
          </date>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
    <xsl:for-each select="marc:subfield[@code = 'e']">
      <xsl:variable name="thisManufacturer">
        <xsl:value-of select="generate-id(.)"/>
      </xsl:variable>
      <distributor>
        <geogName>
          <xsl:call-template name="analog">
            <xsl:with-param name="tag">
              <xsl:value-of select="concat(../@tag, '|e')"/>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:value-of select="$thisManufacturer"/>
        </geogName>
        <xsl:for-each select="../marc:subfield[@code = 'f' or @code = 'g']">
          <xsl:if
            test="generate-id(preceding-sibling::marc:subfield[@code = 'e'][1]) = $thisManufacturer">
            <xsl:choose>
              <xsl:when test="@code = 'f'">
                <name>
                  <xsl:call-template name="analog">
                    <xsl:with-param name="tag">
                      <xsl:value-of select="concat(../@tag, '|f')"/>
                    </xsl:with-param>
                  </xsl:call-template>
                  <xsl:value-of select="."/>
                </name>
              </xsl:when>
              <xsl:when test="@code = 'g'">
                <date>
                  <xsl:call-template name="analog">
                    <xsl:with-param name="tag">
                      <xsl:value-of select="concat(@tag, '|g')"/>
                    </xsl:with-param>
                  </xsl:call-template>
                  <xsl:value-of select="."/>
                </date>
              </xsl:when>
            </xsl:choose>
          </xsl:if>
        </xsl:for-each>
      </distributor>
    </xsl:for-each>
    <xsl:apply-templates
      select="../marc:datafield[@tag = '028'][marc:subfield[@code = 'a']][not(@ind1 = '2')]"/>
    <xsl:apply-templates
      select="
        ../marc:datafield[@tag = '020' or @tag = '022' or
        @tag = '024'][marc:subfield[@code = 'a']]"
    />
  </xsl:template>

  <!-- production, publication, distribution, etc. -->
  <xsl:template match="marc:datafield[@tag = '264'][not(@ind2 = '1')]">
    <xsl:variable name="resp">
      <xsl:choose>
        <xsl:when test="@ind2 = '2'">
          <xsl:text>distribution</xsl:text>
        </xsl:when>
        <xsl:when test="@ind2 = '3'">
          <xsl:text>manufacture</xsl:text>
        </xsl:when>
        <xsl:when test="@ind2 = '4'">
          <xsl:text>copyright</xsl:text>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="@ind2 = '2' or @ind2 = '3'">
      <respSmt>
        <resp>
          <xsl:value-of select="$resp"/>
        </resp>
        <xsl:for-each select="marc:subfield[@code = 'a']">
          <name>
            <xsl:call-template name="analog">
              <xsl:with-param name="tag">
                <xsl:value-of select="concat(../@tag, '|a')"/>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:value-of select="."/>
          </name>
        </xsl:for-each>
        <xsl:for-each select="marc:subfield[@code = 'b']">
          <name>
            <xsl:call-template name="analog">
              <xsl:with-param name="tag">
                <xsl:value-of select="concat(../@tag, '|b')"/>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:value-of select="."/>
          </name>
        </xsl:for-each>
      </respSmt>
    </xsl:if>
    <xsl:for-each select="marc:subfield[@code = 'c']">
      <date>
        <xsl:attribute name="label">
          <xsl:value-of select="concat($resp, ' date')"/>
        </xsl:attribute>
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="concat(../@tag, '|c')"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:value-of select="."/>
      </date>
    </xsl:for-each>
  </xsl:template>

  <!-- physical description -->
  <xsl:template match="marc:datafield[@tag = '300']">
    <xsl:if test="marc:subfield[@code = 'a']">
      <extent>
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="concat(@tag, '|a')"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">a</xsl:with-param>
        </xsl:call-template>
      </extent>
    </xsl:if>
    <xsl:if test="marc:subfield[@code = 'b']">
      <physMedium>
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="concat(@tag, '|b')"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">b</xsl:with-param>
        </xsl:call-template>
      </physMedium>
    </xsl:if>
    <xsl:if test="marc:subfield[@code = 'c']">
      <dimensions>
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="concat(@tag, '|c')"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">c</xsl:with-param>
        </xsl:call-template>
      </dimensions>
    </xsl:if>
    <xsl:if test="marc:subfield[@code = 'e']">
      <carrierForm>
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="concat(@tag, '|e')"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">e</xsl:with-param>
        </xsl:call-template>
      </carrierForm>
    </xsl:if>
  </xsl:template>

  <!-- playing time -->
  <xsl:template match="marc:datafield[@tag = '306']">
    <xsl:for-each select="marc:subfield[@code = 'a']">
      <extent>
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="concat(../@tag, '|a')"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:value-of
          select="
            concat(substring(., 1, 2), ':', substring(., 3, 2), ':', substring(.,
            5, 2))"
        />
      </extent>
    </xsl:for-each>
  </xsl:template>

  <!-- series title -->
  <xsl:template match="marc:datafield[@tag = '490']">
    <seriesStmt>
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="@tag"/>
        </xsl:with-param>
      </xsl:call-template>
      <title>
        <xsl:call-template name="chopPunctuation">
          <xsl:with-param name="chopString">
            <xsl:call-template name="subfieldSelect">
              <xsl:with-param name="codes">a</xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </title>
      <xsl:if test="marc:subfield[@code = 'v']">
        <biblScope>
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">v</xsl:with-param>
          </xsl:call-template>
        </biblScope>
      </xsl:if>
      <xsl:if test="marc:subfield[@code = 'x']">
        <identifier>
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">x</xsl:with-param>
          </xsl:call-template>
        </identifier>
      </xsl:if>
    </seriesStmt>
  </xsl:template>

  <!-- notes (5XX) -->
  <xsl:template
    match="
      marc:datafield[@tag = '500' or @tag = '504' or @tag = '506' or @tag = '510' or
      @tag = '520' or @tag = '521' or @tag = '524' or @tag = '525' or @tag = '530' or @tag = '533' or
      @tag = '534' or @tag = '535' or @tag = '540' or @tag = '541' or @tag = '542' or @tag = '545' or
      @tag = '546' or @tag = '555' or @tag = '563' or @tag = '580' or @tag = '581' or @tag = '585' or
      @tag = '586']">
    <xsl:variable name="tag" select="@tag"/>
    <xsl:variable name="annottype">
      <xsl:choose>
        <xsl:when test="$tag = '500'">general</xsl:when>
        <xsl:when test="$tag = '504'">bibliography</xsl:when>
        <!-- 505 (content note) matched separately -->
        <xsl:when test="$tag = '506'">access_restriction</xsl:when>
        <xsl:when test="$tag = '510'">reference</xsl:when>
        <!-- 511 (participant/performer) matched separately -->
        <!-- 518 (event date/time) matched separately -->
        <xsl:when test="$tag = '520'">summary</xsl:when>
        <xsl:when test="$tag = '524'">citation</xsl:when>
        <xsl:when test="$tag = '525'">supplementary_material</xsl:when>
        <xsl:when test="$tag = '530'">additional_form</xsl:when>
        <xsl:when test="$tag = '533'">reproduction</xsl:when>
        <xsl:when test="$tag = '534'">original_version</xsl:when>
        <xsl:when test="$tag = '535'">originals_location</xsl:when>
        <xsl:when test="$tag = '540'">use_restriction</xsl:when>
        <xsl:when test="$tag = '541'">acquisition</xsl:when>
        <xsl:when test="$tag = '542'">copyright_status</xsl:when>
        <xsl:when test="$tag = '544'">other_materials_location</xsl:when>
        <xsl:when test="$tag = '545'">biography</xsl:when>
        <xsl:when test="$tag = '546'">language</xsl:when>
        <xsl:when test="$tag = '555'">aid</xsl:when>
        <!-- 561 (provenance) matched separately -->
        <xsl:when test="$tag = '563'">binding</xsl:when>
        <xsl:when test="$tag = '580'">linking</xsl:when>
        <xsl:when test="$tag = '581'">publications</xsl:when>
        <xsl:when test="$tag = '585'">exhibitions</xsl:when>
        <xsl:when test="$tag = '586'">awards</xsl:when>
        <!-- Datafields 590-599 (local notes) matched separately -->
        <xsl:otherwise>[unspecified]</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <annot type="{$annottype}">
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="$tag"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="$tag = '506'">
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">af</xsl:with-param>
            <xsl:with-param name="delimiter">, </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$tag = '510'">
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">abcu</xsl:with-param>
            <xsl:with-param name="delimiter">, </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$tag = '530'">
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">abcd</xsl:with-param>
            <xsl:with-param name="delimiter">, </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$tag = '533'">
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">ad</xsl:with-param>
            <xsl:with-param name="delimiter">, </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$tag = '534'">
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">tabl</xsl:with-param>
            <xsl:with-param name="delimiter">, </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$tag = '535'">
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">acg</xsl:with-param>
            <xsl:with-param name="delimiter">, </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$tag = '541'">
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">acd</xsl:with-param>
            <xsl:with-param name="delimiter">, </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$tag = '542'">
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">lgd</xsl:with-param>
            <xsl:with-param name="delimiter">, </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$tag = '544'">
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">ac</xsl:with-param>
            <xsl:with-param name="delimiter">, </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">a</xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="marc:subfield[@code = '5']">
        <xsl:text> (</xsl:text>
        <xsl:value-of select="marc:subfield[@code = '5']"/>
        <xsl:text>)</xsl:text>
      </xsl:if>
    </annot>
  </xsl:template>

  <!-- contents note -->
  <!--<xsl:template match="marc:datafield[@tag='505']">
    <contents>
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="@tag"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:if test="not(@ind1='8')">
        <xsl:attribute name="label">
          <xsl:choose>
            <xsl:when test="@ind1='0'">
              <xsl:text>Contents</xsl:text>
            </xsl:when>
            <xsl:when test="@ind1='1'">
              <xsl:text>Incomplete contents</xsl:text>
            </xsl:when>
            <xsl:when test="@ind1='2'">
              <xsl:text>Partial contents</xsl:text>
            </xsl:when>
          </xsl:choose>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@ind2='0'">
          <xsl:variable name="contentItems">
            <xsl:value-of select="."/>
          </xsl:variable>
          <xsl:analyze-string select="$contentItems" regex="-\-">
            <xsl:non-matching-substring>
              <contentItem>
                <xsl:value-of select="normalize-space(.)"/>
              </contentItem>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:when>
        <xsl:otherwise>
          <p>
            <xsl:call-template name="subfieldSelect">
              <xsl:with-param name="codes">a</xsl:with-param>
            </xsl:call-template>
          </p>
        </xsl:otherwise>
      </xsl:choose>
    </contents>
  </xsl:template>-->

  <!-- creation note -->
  <xsl:template match="marc:datafield[@tag = '508']">
    <xsl:variable name="tag" select="@tag"/>
    <xsl:call-template name="subfieldSelect">
      <xsl:with-param name="codes">a</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- participants in event -->
  <xsl:template match="marc:datafield[@tag = '511']">
    <xsl:variable name="tag" select="@tag"/>
    <event>
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="$tag"/>
        </xsl:with-param>
      </xsl:call-template>
      <p>
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">a</xsl:with-param>
        </xsl:call-template>
      </p>
    </event>
  </xsl:template>

  <!-- event -->
  <xsl:template match="marc:datafield[@tag = '518']">
    <xsl:variable name="tag" select="@tag"/>
    <event>
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="$tag"/>
        </xsl:with-param>
      </xsl:call-template>
      <p>
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">a</xsl:with-param>
          <xsl:with-param name="delimiter">; </xsl:with-param>
        </xsl:call-template>
      </p>
    </event>
  </xsl:template>

  <!-- provenance -->
  <xsl:template match="marc:datafield[@tag = '561']">
    <xsl:variable name="tag" select="@tag"/>
    <provenance>
      <repository>
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="concat($tag, '|a')"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">a</xsl:with-param>
        </xsl:call-template>
      </repository>
    </provenance>
  </xsl:template>

  <!-- If the marc2mei59x.xsl module is unavailable, 59x fields are 
    output as MEI annotations. -->
  <!-- 59x (local notes) -->
  <xsl:template match="marc:datafield[starts-with(@tag, '59')]" priority="1">
    <annot type="local">
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="@tag"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:value-of select="normalize-space(.)"/>
    </annot>
  </xsl:template>

  <!-- contents -->
  <xsl:template match="marc:datafield[@tag = '700' or @tag = '730' or @tag = '740']" mode="contents">
    <xsl:variable name="tag" select="@tag"/>
    <contentItem>
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="$tag"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="subfieldSelect">
        <xsl:with-param name="codes">
          <xsl:choose>
            <xsl:when test="$tag = '700'">adt</xsl:when>
            <xsl:otherwise>a</xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </contentItem>
  </xsl:template>

  <!-- responsibility statement; added entry -->
  <xsl:template match="marc:datafield[@tag = '700' or @tag = '710']" mode="respStmt">
    <xsl:variable name="tag">
      <xsl:value-of select="@tag"/>
    </xsl:variable>
    <respStmt>
      <xsl:choose>
        <xsl:when test="$tag = '710'">
          <!-- corporate name; use subfield a (non-repeatable) -->
          <corpName>
            <xsl:if test="marc:subfield[@code = '0']">
              <xsl:attribute name="dbkey">
                <xsl:value-of select="marc:subfield[@code = '0']"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="analog">
              <xsl:with-param name="tag">
                <xsl:value-of select="concat($tag, '|a')"/>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="subfieldSelect">
              <xsl:with-param name="codes">abcd</xsl:with-param>
            </xsl:call-template>
          </corpName>
        </xsl:when>
        <xsl:otherwise>
          <!-- personal name -->
          <persName>
            <xsl:if test="marc:subfield[@code = '0']">
              <xsl:attribute name="dbkey">
                <xsl:value-of select="marc:subfield[@code = '0']"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:call-template name="analog">
              <xsl:with-param name="tag">
                <xsl:value-of select="concat($tag, '|a')"/>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:choose>
              <xsl:when test="marc:subfield[@code = 'd']">
                <xsl:call-template name="subfieldSelect">
                  <xsl:with-param name="codes">abcjq</xsl:with-param>
                </xsl:call-template>
                <xsl:text>&#32;</xsl:text>
                <date>
                  <xsl:call-template name="analog">
                    <xsl:with-param name="tag">
                      <xsl:value-of select="concat($tag, '|d')"/>
                    </xsl:with-param>
                  </xsl:call-template>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                      <xsl:value-of select="marc:subfield[@code = 'd']"/>
                    </xsl:with-param>
                  </xsl:call-template>
                </date>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="subfieldSelect">
                  <xsl:with-param name="codes">abcjq</xsl:with-param>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </persName>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="marc:subfield[@code = '4']">
          <xsl:apply-templates select="marc:subfield[@code = '4']" mode="respStmt"/>
        </xsl:when>
        <xsl:when test="marc:subfield[@code = 'e']">
          <xsl:apply-templates select="marc:subfield[@code = 'e']" mode="respStmt"/>
        </xsl:when>
      </xsl:choose>
    </respStmt>
  </xsl:template>

  <!-- associated place -->
  <xsl:template match="marc:datafield[@tag = '751' or @tag = '752']">
    <term>
      <xsl:variable name="tag" select="@tag"/>
      <xsl:attribute name="label">
        <xsl:text>place</xsl:text>
      </xsl:attribute>
      <xsl:if test="marc:subfield[@code = '2']">
        <xsl:attribute name="classCode">
          <xsl:value-of select="concat('#', upper-case(marc:subfield[@code = '2']))"/>
        </xsl:attribute>
      </xsl:if>
      <!-- @dbkey not permitted, but should be -->
      <!--<xsl:if test="marc:subfield[@code='0']">
        <xsl:attribute name="dbkey">
          <xsl:value-of select="marc:subfield[@code='0']"/>
        </xsl:attribute>
      </xsl:if>-->
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="$tag"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="chopString">
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">
              <xsl:choose>
                <xsl:when test="$tag = '751'">a</xsl:when>
                <xsl:when test="$tag = '752'">abcdefgh</xsl:when>
              </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="delimiter">, </xsl:with-param>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </term>
  </xsl:template>

  <!-- physical location -->
  <xsl:template match="marc:datafield[@tag = '852']">
    <xsl:variable name="tag" select="@tag"/>
    <physLoc>
      <xsl:if test="marc:subfield[@code = 'a' or @code = 'b' or @code = 'e']">
        <repository>
          <xsl:call-template name="analog">
            <xsl:with-param name="tag">
              <xsl:value-of select="$tag"/>
            </xsl:with-param>
          </xsl:call-template>
          <name>
            <xsl:value-of select="marc:subfield[@code = 'a']"/>
            <xsl:if test="marc:subfield[@code = 'b']">
              <xsl:text>, </xsl:text>
              <name>
                <xsl:value-of select="marc:subfield[@code = 'b']"/>
              </name>
            </xsl:if>
          </name>
          <xsl:for-each select="marc:subfield[@code = 'e']">
            <address>
              <addrLine>
                <xsl:for-each select="..">
                  <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">e</xsl:with-param>
                  </xsl:call-template>
                </xsl:for-each>
              </addrLine>
              <xsl:if test="../marc:subfield[@code = 'n']">
                <addrLine>
                  <identifier type="countryCode">
                    <xsl:call-template name="analog">
                      <xsl:with-param name="tag">
                        <xsl:value-of select="concat($tag, '|n')"/>
                      </xsl:with-param>
                    </xsl:call-template>
                    <xsl:for-each select="..">
                      <xsl:call-template name="subfieldSelect">
                        <xsl:with-param name="codes">n</xsl:with-param>
                      </xsl:call-template>
                    </xsl:for-each>
                  </identifier>
                </addrLine>
              </xsl:if>
            </address>
          </xsl:for-each>
        </repository>
      </xsl:if>
      <xsl:if test="marc:subfield[@code = 'c']">
        <identifier type="shelfLocation">
          <xsl:if test="marc:subfield[@code = '2']">
            <xsl:attribute name="authority">
              <xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">2</xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
          </xsl:if>
          <xsl:call-template name="analog">
            <xsl:with-param name="tag">
              <xsl:value-of select="concat($tag, '|c')"/>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">c</xsl:with-param>
          </xsl:call-template>
        </identifier>
      </xsl:if>
      <xsl:if test="marc:subfield[@code = 'j']">
        <identifier type="shelvingControlNumber">
          <xsl:if test="marc:subfield[@code = '2']">
            <xsl:attribute name="authority">
              <xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">2</xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
          </xsl:if>
          <xsl:call-template name="analog">
            <xsl:with-param name="tag">
              <xsl:value-of select="concat($tag, '|j')"/>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">j</xsl:with-param>
          </xsl:call-template>
        </identifier>
      </xsl:if>
      <xsl:if test="marc:subfield[matches(@code, 'khim')]">
        <identifier type="shelfLocation">
          <xsl:if test="marc:subfield[@code = '2']">
            <xsl:attribute name="authority">
              <xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">2</xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
          </xsl:if>
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">khim</xsl:with-param>
          </xsl:call-template>
        </identifier>
      </xsl:if>
      <xsl:if test="marc:subfield[@code = 'p']">
        <identifier type="shelfLocation">
          <xsl:if test="marc:subfield[@code = '2']">
            <xsl:attribute name="authority">
              <xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">2</xsl:with-param>
              </xsl:call-template>
            </xsl:attribute>
          </xsl:if>
          <xsl:call-template name="analog">
            <xsl:with-param name="tag">
              <xsl:value-of select="concat($tag, '|p')"/>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">p</xsl:with-param>
          </xsl:call-template>
        </identifier>
      </xsl:if>
      <xsl:if test="marc:subfield[@code = 't']">
        <identifier type="copy">
          <xsl:call-template name="analog">
            <xsl:with-param name="tag">
              <xsl:value-of select="concat($tag, '|t')"/>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">t</xsl:with-param>
          </xsl:call-template>
        </identifier>
      </xsl:if>
    </physLoc>
  </xsl:template>

  <!-- relator codes -->
  <xsl:template match="marc:subfield[@code = '4']" mode="respStmt">
    <xsl:variable name="code">
      <xsl:value-of select="."/>
    </xsl:variable>
    <resp code="{$code}">
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="concat(./@tag, '|4')"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="$marcRelList/mei:relator[@code = $code]">
          <xsl:value-of select="$marcRelList/mei:relator[@code = $code]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>[unknown]</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </resp>
  </xsl:template>

  <!-- relator terms -->
  <xsl:template match="marc:subfield[@code = 'e']" mode="respStmt">
    <xsl:variable name="term">
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="chopString">
          <xsl:value-of select="."/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <resp>
      <xsl:attribute name="code">
        <xsl:value-of select="$marcRelList/mei:relator[. = $term]/@code"/>
      </xsl:attribute>
      <xsl:call-template name="analog">
        <xsl:with-param name="tag">
          <xsl:value-of select="concat(../@tag, '|4')"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:value-of select="$term"/>
    </resp>
  </xsl:template>

  <!-- The default behavior for 9xx datafields is to serialize them
  as comments. -->
  <xsl:template match="marc:datafield[starts-with(@tag, '9')]">
    <xsl:comment>
      <xsl:value-of select="$nl"/>
      <xsl:value-of
        select="
          concat('&lt;marc:datafield tag=&quot;', @tag, '&quot; ind1=&quot;',
          @ind1, '&quot; ind2=&quot;', @ind2, '&quot;>')"/>
      <xsl:apply-templates select="marc:subfield"/>
      <xsl:value-of select="$nl"/>
      <xsl:value-of select="'&lt;/marc:datafield>'"/>
    </xsl:comment>
  </xsl:template>

  <xsl:template match="marc:subfield[starts-with(../@tag, '9')]">
    <xsl:value-of select="$nl"/>
    <xsl:value-of select="concat('&lt;marc:subfield code=&quot;', @code, '&quot;>')"/>
    <xsl:value-of select="."/>
    <xsl:value-of select="'&lt;/marc:subfield>'"/>
  </xsl:template>

  <!-- default template -->
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- 59x fields are handled by templates in the external file referenced in @href.
  If that file isn't available, 59x fields are output using <annot>. -->
  <xsl:include href="marc2mei59x.xsl"/>

</xsl:stylesheet>
