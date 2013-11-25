<?xml version="1.0" encoding="UTF-8"?>

<!--
	
	marc2mei-2013.xsl - XSLT (1.0) stylesheet for transformation of RISM MARC XML to MEI header XML
	
	Perry Roland <pdr4h@virginia.edu>
	Music Library
	University of Virginia
	Written: 2013-11-12
	Last modified: 2013-11-12
	
	For info on MARC XML, see http://www.loc.gov/marc/marcxml.html
	For info on the MEI header, see http://music-encoding.org
	For info on RISM, see http://www.rism-ch.org
	
	Based on:
	1. https://code.google.com/p/mei-incubator/source/browse/rism2mei/rism2mei-2012.xsl
	Laurent Pugin <laurent.pugin@rism-ch.org> / Swiss RISM Office 
	2. http://oreo.grainger.uiuc.edu/stylesheets/MARC_TEI-twc.xsl
	3. marc2tei.xsl - XSLT (1.0) stylesheet for transformation of MARC XML to TEI header XML (TEI P4)
	Greg Murray <gpm2a@virginia.edu> / Digital Library Production Services, University of Virginia Library
	
-->

<xsl:stylesheet version="2.0" xmlns="http://www.music-encoding.org/ns/mei"
  xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:marc="http://www.loc.gov/MARC21/slim" exclude-result-prefixes="marc mei">

  <xsl:output method="xml" encoding="UTF-8" indent="yes" media-type="text/xml"/>

  <!-- version -->
  <xsl:variable name="version">
    <xsl:text>1.0 beta</xsl:text>
  </xsl:variable>

  <!-- PARAMETERS -->
  <xsl:param name="rng_model_path"
    >http://music-encoding.googlecode.com/svn/tags/MEI2013_v2.1.0/schemata/mei-all.rng</xsl:param>
  <xsl:param name="sch_model_path"
    >http://music-encoding.googlecode.com/svn/tags/MEI2013_v2.1.0/schemata/mei-all.rng</xsl:param>
  <!-- agency name -->
  <xsl:param name="agency"/>
  <!-- agency code, could also be taken from 003 -->
  <xsl:param name="agency_code"/>
  <!-- output analog attributes -->
  <xsl:param name="analog">true</xsl:param>
  <!-- preserve main entry -->
  <xsl:param name="preserveMainEntry">true</xsl:param>

  <!-- ======================================================================= -->
  <!-- GLOBAL VARIABLES                                                        -->
  <!-- ======================================================================= -->
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
    <instr code="on" class="Larger ensemble">Unspecified esemble</instr>
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


  <!-- ======================================================================= -->
  <!-- UTILITIES                                                               -->
  <!-- ======================================================================= -->

  <xsl:template name="analog">
    <xsl:param name="tag"/>
    <xsl:attribute name="analog">
      <xsl:value-of select="concat('marc:', $tag)"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="datafield">
    <xsl:param name="tag"/>
    <xsl:param name="ind1">
      <xsl:text> </xsl:text>
    </xsl:param>
    <xsl:param name="ind2">
      <xsl:text> </xsl:text>
    </xsl:param>
    <xsl:param name="subfields"/>
    <datafield>
      <xsl:attribute name="tag">
        <xsl:value-of select="$tag"/>
      </xsl:attribute>
      <xsl:attribute name="ind1">
        <xsl:value-of select="$ind1"/>
      </xsl:attribute>
      <xsl:attribute name="ind2">
        <xsl:value-of select="$ind2"/>
      </xsl:attribute>
      <xsl:copy-of select="$subfields"/>
    </datafield>
  </xsl:template>

  <xsl:template name="subfieldSelect">
    <xsl:param name="codes"/>
    <xsl:param name="delimiter">
      <xsl:text> </xsl:text>
    </xsl:param>
    <xsl:param name="element"/>
    <xsl:choose>
      <xsl:when test="string-length($element) &gt; 0">
        <xsl:element name="{$element}">
          <xsl:variable name="str">
            <xsl:for-each select="marc:subfield">
              <xsl:if test="contains($codes, @code)">
                <xsl:value-of select="text()"/>
                <xsl:value-of select="$delimiter"/>
              </xsl:if>
            </xsl:for-each>
          </xsl:variable>
          <xsl:value-of select="substring($str,1,string-length($str)-string-length($delimiter))"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="str">
          <xsl:for-each select="marc:subfield">
            <xsl:if test="contains($codes, @code)">
              <xsl:value-of select="text()"/>
              <xsl:value-of select="$delimiter"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="substring($str,1,string-length($str)-string-length($delimiter))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="buildSpaces">
    <xsl:param name="spaces"/>
    <xsl:param name="char">
      <xsl:text> </xsl:text>
    </xsl:param>
    <xsl:if test="$spaces>0">
      <xsl:value-of select="$char"/>
      <xsl:call-template name="buildSpaces">
        <xsl:with-param name="spaces" select="$spaces - 1"/>
        <xsl:with-param name="char" select="$char"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="chopPunctuation">
    <xsl:param name="chopString"/>
    <xsl:variable name="length" select="string-length($chopString)"/>
    <xsl:choose>
      <xsl:when test="$length=0"/>
      <xsl:when test="contains('.:,;+/ ', substring($chopString,$length,1))">
        <xsl:call-template name="chopPunctuation">
          <xsl:with-param name="chopString" select="substring($chopString,1,$length - 1)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="not($chopString)"/>
      <xsl:otherwise>
        <xsl:value-of select="$chopString"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="chopPunctuationFront">
    <xsl:param name="chopString"/>
    <xsl:variable name="length" select="string-length($chopString)"/>
    <xsl:choose>
      <xsl:when test="$length=0"/>
      <xsl:when test="contains('.:,;/[ ', substring($chopString,1,1))">
        <xsl:call-template name="chopPunctuationFront">
          <xsl:with-param name="chopString" select="substring($chopString,2,$length - 1)"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="not($chopString)"/>
      <xsl:otherwise>
        <xsl:value-of select="$chopString"/>
      </xsl:otherwise>
    </xsl:choose>
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
    <xsl:call-template name="meiHead"/>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- MAIN OUTPUT TEMPLATE                                                    -->
  <!-- ======================================================================= -->

  <xsl:template name="meiHead">

    <!-- UNUSED -->
    <!--<xsl:variable name="leader" select="marc:leader"/>
    <xsl:variable name="leader6" select="substring($leader,7,1)"/>
    <xsl:variable name="leader7" select="substring($leader,8,1)"/>
    <xsl:variable name="controlField005" select="marc:controlfield[@tag='005']"/>
    <xsl:variable name="controlField008" select="marc:controlfield[@tag='008']"/>-->

    <xsl:if test="$rng_model_path != ''">
      <xsl:processing-instruction name="xml-model">
        <xsl:value-of select="concat('&#32;href=&quot;', $rng_model_path, '&quot;')"/>
        <xsl:text> type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
      </xsl:processing-instruction>
    </xsl:if>
    <xsl:if test="$sch_model_path != ''">
      <xsl:processing-instruction name="xml-model">
        <xsl:value-of select="concat('&#32;href=&quot;', $sch_model_path, '&quot;')"/>
        <xsl:text> type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:text>
      </xsl:processing-instruction>
    </xsl:if>

    <meiHead>
      <xsl:attribute name="meiversion">2013</xsl:attribute>
      <xsl:if test="marc:datafield[@tag='040']/marc:subfield[@code='b']">
        <xsl:attribute name="xml:lang">
          <xsl:value-of select="marc:datafield[@tag='040']/marc:subfield[@code='b']"/>
        </xsl:attribute>
      </xsl:if>
      <altId analog="marc:001">
        <xsl:apply-templates select="marc:controlfield[@tag='001']"/>
      </altId>
      <fileDesc>

        <!-- file title(s) -->
        <titleStmt>
          <!-- title for electronic text (240 and 245) -->
          <xsl:apply-templates select="marc:datafield[@tag='240' or @tag='245']"/>
          <title type="subtitle">an electronic transcription</title>

          <!-- statements of responsibility -->
          <xsl:variable name="respStmts">
            <xsl:apply-templates select="marc:datafield[@tag='100' or @tag='110']"/>
            <xsl:if test="not($preserveMainEntry = 'true')">
              <xsl:apply-templates select="marc:datafield[@tag='700' or @tag='710']"/>
            </xsl:if>
          </xsl:variable>
          <xsl:variable name="sortedRespStmts">
            <xsl:for-each select="$respStmts/mei:respStmt">
              <xsl:sort select="mei:*[local-name()='persName' or local-name()='corpName']/@analog"/>
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

        <!-- edtStmt -->
        <!-- UNUSED -->

        <!-- extent -->
        <!-- UNUSED -->

        <!-- publication statement -->
        <pubStmt>
          <xsl:call-template name="pubStmt"/>
        </pubStmt>

        <!-- seriesStmt -->
        <!-- UNUSED -->

        <!-- notesStmt-->
        <xsl:variable name="notes" select="marc:datafield[@tag='500' or @tag='506' or
          @tag='510' or @tag='520' or @tag='525' or @tag='533' or @tag='541' or @tag='545' or
          @tag='546' or @tag='555' or @tag='561' or @tag='563' or @tag='580' or @tag='591' or
          @tag='594' or @tag='596' or @tag='597' or @tag='598']"/>
        <xsl:variable name="musicPresentation" select="datafield[@tag='254']"/>
        <xsl:if test="$notes or $musicPresentation">
          <notesStmt>
            <xsl:apply-templates select="$notes"/>
            <xsl:apply-templates select="$musicPresentation"/>
          </notesStmt>
        </xsl:if>

        <!-- sourceDesc -->
        <sourceDesc>
          <xsl:choose>
            <!-- if no fields with $3, there's a single source -->
            <xsl:when test="count(//marc:subfield[@code='3'])=0">
              <source>
                <!-- pubStmt -->
                <xsl:apply-templates select="marc:datafield[@tag='260']"/>
                <!-- physDesc -->
                <xsl:apply-templates select="marc:datafield[@tag='300']"/>
                <!-- seriesStmt -->
                <xsl:apply-templates select="marc:datafield[@tag='490']"/>
                <!-- contentNote -->
                <xsl:apply-templates select="marc:datafield[@tag='505']"/>
                <!-- language(s) of the source material -->
                <xsl:variable name="langUsage" select="marc:datafield[@tag='041']"/>
                <xsl:if test="$langUsage">
                  <langUsage>
                    <xsl:apply-templates select="$langUsage"/>
                  </langUsage>
                </xsl:if>

                <!-- notesStmt -->
                <xsl:if test="marc:datafield[@tag='590' or @tag='592' or @tag='593']">
                  <notesStmt>
                    <xsl:apply-templates select="marc:datafield[@tag='590' or @tag='592' or
                      @tag='593']"/>
                  </notesStmt>
                </xsl:if>
              </source>
            </xsl:when>
            <xsl:otherwise>
              <!-- group 260, 300, 490, 590, 592, and 593 on subfield 3 -->
              <xsl:for-each-group select="marc:datafield[@tag='260' or @tag='300' or @tag='490' or
                @tag='590' or @tag='592' or @tag='593'][marc:subfield[@code='3']]"
                group-by="marc:subfield[@code='3']">
                <xsl:sort select="current-grouping-key()"/>
                <source>
                  <xsl:attribute name="label">
                    <xsl:value-of select="current-grouping-key()"/>
                  </xsl:attribute>
                  <xsl:variable name="sourceContent">
                    <xsl:for-each select="current-group()">
                      <xsl:apply-templates select="."/>
                    </xsl:for-each>
                  </xsl:variable>
                  <xsl:copy-of select="$sourceContent/*[not(local-name()='annot')]"/>
                  <notesStmt>
                    <xsl:copy-of select="$sourceContent/*[local-name()='annot']"/>
                  </notesStmt>
                </source>
              </xsl:for-each-group>
            </xsl:otherwise>
          </xsl:choose>
        </sourceDesc>
      </fileDesc>

      <!-- encodingDesc -->
      <encodingDesc>
        <appInfo>
          <application>
            <xsl:attribute name="version">
              <xsl:value-of select="$version"/>
            </xsl:attribute>
            <name>marc2mei-2013.xsl</name>
          </application>
        </appInfo>
      </encodingDesc>

      <!-- workDesc -->
      <workDesc>
        <work>

          <!-- work title(s) -->
          <titleStmt>
            <xsl:apply-templates select="marc:datafield[@tag='130' or @tag='240']"/>
            <xsl:if test="not(marc:datafield[@tag='130' or @tag='240'])">
              <xsl:apply-templates select="marc:datafield[@tag='245']"/>
            </xsl:if>

            <!-- statements of responsibility -->
            <xsl:variable name="respStmts">
              <xsl:apply-templates select="marc:datafield[@tag='100' or @tag='110']"/>
              <xsl:apply-templates select="marc:datafield[@tag='700' or @tag='710']"/>
            </xsl:variable>
            <xsl:variable name="sortedRespStmts">
              <xsl:for-each select="$respStmts/mei:respStmt">
                <xsl:sort select="mei:*[local-name()='persName' or local-name()='corpName']/@analog"/>
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

          <!-- creation -->
          <xsl:variable name="creation_note" select="marc:datafield[@tag='045' or @tag='508']"/>

          <!-- incipits -->
          <xsl:variable name="incipits" select="marc:datafield[@tag='031']"/>
          <xsl:if test="$incipits">
            <xsl:apply-templates select="$incipits"/>
          </xsl:if>

          <!-- eventList -->
          <xsl:variable name="events" select="marc:datafield[@tag='511' or @tag='518']"/>
          <xsl:if test="$creation_note or $events">
            <history>
              <xsl:if test="$creation_note">
                <creation>
                  <xsl:if test="$analog='true'">
                    <xsl:call-template name="analog">
                      <xsl:with-param name="tag">
                        <xsl:value-of select="'508'"/>
                      </xsl:with-param>
                    </xsl:call-template>
                  </xsl:if>
                  <xsl:for-each select="marc:datafield[@tag='508']">
                    <xsl:apply-templates select="."/>
                    <xsl:if test="position() != last()">
                      <xsl:text>;&#32;</xsl:text>
                    </xsl:if>
                  </xsl:for-each>
                  <xsl:apply-templates select="marc:datafield[@tag='045']"/>
                </creation>
              </xsl:if>
              <xsl:if test="$events">
                <eventList>
                  <xsl:apply-templates select="$events"/>
                </eventList>
              </xsl:if>
            </history>
          </xsl:if>

          <!-- language of the work -->
          <xsl:variable name="langUsage" select="marc:datafield[@tag='041'][marc:subfield[@code='a'
            or @code='d' or @code='e']]"/>
          <xsl:if test="$langUsage">
            <langUsage>
              <xsl:apply-templates select="$langUsage"/>
            </langUsage>
          </xsl:if>

          <!-- cast list -->
          <xsl:variable name="instrumentation" select="marc:datafield[@tag='048']"/>
          <xsl:variable name="castNotes" select="marc:datafield[@tag='595']"/>
          <xsl:if test="$instrumentation or $castNotes">
            <perfMedium>
              <xsl:if test="$castNotes">
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

          <!-- contents -->
          <xsl:variable name="contents" select="marc:datafield[@tag='730' or @tag='740']"/>
          <xsl:if test="$contents">
            <contents>
              <xsl:apply-templates select="$contents" mode="contents"/>
            </contents>
          </xsl:if>

          <!-- classification -->
          <xsl:variable name="classification" select="marc:datafield[@tag='050' or @tag='082' or
            @tag='090' or @tag='648' or @tag='650' or @tag='651' or @tag='653' or @tag='654' or
            @tag='655' or @tag='656' or @tag='657' or @tag='658']"/>

          <xsl:if test="$classification">
            <!-- classification codes -->
            <classification>
              <xsl:variable name="classCodes">

                <!-- common schemes -->
                <xsl:if test="marc:datafield[@tag='090']">
                  <classCode n="-3" xml:id="LocalNum">Local Classification Number</classCode>
                </xsl:if>
                <xsl:if test="marc:datafield[@tag='082']">
                  <classCode n="-2" xml:id="DDC">Dewey Decimal Classification Number</classCode>
                </xsl:if>
                <xsl:if test="marc:datafield[@tag='050']">
                  <classCode n="-1" xml:id="LCCN">Library of Congress Classification
                    Number</classCode>
                </xsl:if>
                <xsl:if test="marc:datafield[@tag='648' or @tag='650' or
                  @tag='651' or @tag='653' or @tag='654' or @tag='655' or
                  @tag='656' or @tag='657' or @tag='658'][@ind2='0']">
                  <classCode n="0" xml:id="LCSH">Library of Congress Subject Headings</classCode>
                </xsl:if>
                <xsl:if test="marc:datafield[@tag='648' or @tag='650' or
                  @tag='651' or @tag='653' or @tag='654' or @tag='655' or
                  @tag='656' or @tag='657' or @tag='658'][@ind2='1']">
                  <classCode n="1" xml:id="LCCL">Library of Congress Subject Headings for Children's
                    Literature</classCode>
                </xsl:if>
                <xsl:if test="marc:datafield[@tag='648' or @tag='650' or
                  @tag='651' or @tag='653' or @tag='654' or @tag='655' or
                  @tag='656' or @tag='657' or @tag='658'][@ind2='2']">
                  <classCode n="2" xml:id="MeSH">Medical Subject Headings </classCode>
                </xsl:if>
                <xsl:if test="marc:datafield[@tag='648' or @tag='650' or
                  @tag='651' or @tag='653' or @tag='654' or @tag='655' or
                  @tag='656' or @tag='657' or @tag='658'][@ind2='3']">
                  <classCode n="3" xml:id="NALSA">National Agricultural Library Subject Authority
                    file</classCode>
                </xsl:if>
                <xsl:if test="marc:datafield[@tag='648' or @tag='650' or
                  @tag='651' or @tag='653' or @tag='654' or @tag='655' or
                  @tag='656' or @tag='657' or @tag='658'][@ind2='5']">
                  <classCode n="5" xml:id="CSH">Canadian Subject Headings</classCode>
                </xsl:if>
                <xsl:if test="marc:datafield[@tag='648' or @tag='650' or
                  @tag='651' or @tag='653' or @tag='654' or @tag='655' or
                  @tag='656' or @tag='657' or @tag='658'][@ind2='6']">
                  <classCode n="6" xml:id="RVM">Répertoire de vedettes-matière</classCode>
                </xsl:if>

                <!-- record-defined schemes -->
                <xsl:for-each select="marc:datafield[@tag='650' or @tag='651' or
                  @tag='653' or @tag='657'][marc:subfield[@code='2']]">
                  <xsl:variable name="classScheme">
                    <xsl:value-of select="marc:subfield[@code='2']"/>
                  </xsl:variable>
                  <classCode>
                    <xsl:attribute name="xml:id">
                      <xsl:value-of select="replace($classScheme, '&#32;', '_')"/>
                    </xsl:attribute>
                    <xsl:value-of select="$classScheme"/>
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

              <!-- sort based on @n; record-defined schemes will bubble
              to the top of the list, schemes provided in this stylesheet
              will sink to the bottom but remain in the order of their
              coded value in MARC. -->
              <xsl:for-each select="$uniqueClassCodes/mei:classCode">
                <xsl:sort select="number(@n)"/>
                <xsl:copy>
                  <xsl:copy-of select="@* except(@n)"/>
                  <xsl:value-of select="."/>
                </xsl:copy>
              </xsl:for-each>

              <termList>
                <xsl:variable name="sortedTerms">
                  <xsl:apply-templates select="$classification">
                    <xsl:sort/>
                  </xsl:apply-templates>
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
                  <xsl:copy-of select="."/>
                </xsl:for-each>
              </termList>
            </classification>
          </xsl:if>

        </work>
      </workDesc>
    </meiHead>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- title (130, 240, 245, 246, 730, 740)                                    -->
  <!-- ======================================================================= -->

  <!-- uniform title 130, 240, 730, 740 (subfields a, k, m, n, o, p, r) -->
  <xsl:template match="marc:datafield[@tag='130' or @tag='240']">
    <!-- main title: subfield a (non-repeatable) -->
    <xsl:variable name="tag" select="@tag"/>
    <title type="uniform">
      <xsl:if test="$analog='true'">
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="$tag"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="chopString">
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">a</xsl:with-param>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>

      <!-- test for certain other subfields to append to main value -->
      <!-- some subfields are repeatable, so loop through all -->
      <xsl:for-each select="marc:subfield[@code='k' or @code='m' or @code='n' or @code='o' or
        @code='p' or @code='r']">
        <xsl:choose>
          <xsl:when test="@code='r'">
            <!-- subfield r = 'Key for music'; add 'in' -->
            <xsl:text>, in </xsl:text>
            <xsl:value-of select="."/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </title>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='730' or @tag='740']" mode="contents">
    <xsl:variable name="tag" select="@tag"/>
    <contentItem>
      <xsl:if test="$analog='true'">
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="$tag"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="chopString">
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">a</xsl:with-param>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </contentItem>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='730' or @tag='740']" mode="analytics">
    <!-- analytic title: subfield a (non-repeatable) -->
    <xsl:variable name="tag" select="@tag"/>
    <work>
      <xsl:attribute name="n">
        <xsl:value-of select="concat('c', position())"/>
      </xsl:attribute>
      <titleStmt>
        <title level="a">
          <xsl:if test="$analog='true'">
            <xsl:call-template name="analog">
              <xsl:with-param name="tag">
                <xsl:value-of select="$tag"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:call-template name="chopPunctuation">
            <xsl:with-param name="chopString">
              <xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">a</xsl:with-param>
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>

          <!-- test for certain other subfields to append to main value -->
          <!-- some subfields are repeatable, so loop through all -->
          <xsl:for-each select="marc:subfield[@code='k' or @code='m' or @code='n' or @code='o' or
            @code='p' or @code='r']">
            <xsl:choose>
              <xsl:when test="@code='r'">
                <!-- subfield r = 'Key for music'; add 'in' -->
                <xsl:text>, in </xsl:text>
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>, </xsl:text>
                <xsl:value-of select="."/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </title>
      </titleStmt>
    </work>
  </xsl:template>

  <!-- diplomatic title 245, 246 (subfields a, b) -->
  <xsl:template match="marc:datafield[@tag='245']">
    <!-- main title: subfield a (non-repeatable) -->
    <title type="diplomatic">
      <xsl:if test="$analog='true'">
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="@tag"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="chopString">
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">ab</xsl:with-param>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </title>
  </xsl:template>

  <!-- series title -->
  <xsl:template match="marc:datafield[@tag='490']">
    <seriesStmt>
      <xsl:if test="$analog='true'">
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="@tag"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <title>
        <xsl:call-template name="chopPunctuation">
          <xsl:with-param name="chopString">
            <xsl:call-template name="subfieldSelect">
              <xsl:with-param name="codes">a</xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </title>
      <xsl:if test="marc:subfield[@code='v']">
        <biblScope>
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">v</xsl:with-param>
          </xsl:call-template>
        </biblScope>
      </xsl:if>
      <xsl:if test="marc:subfield[@code='x']">
        <identifier>
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">x</xsl:with-param>
          </xsl:call-template>
        </identifier>
      </xsl:if>
    </seriesStmt>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- Main Entry (100, 110)                                                   -->
  <!-- ======================================================================= -->

  <xsl:template match="marc:datafield[@tag='100' or @tag='110']">
    <xsl:variable name="tag">
      <xsl:value-of select="@tag"/>
    </xsl:variable>
    <!-- each name is contained within a <respStmt> to account for possible <resp>
      elements -->
    <respStmt>
      <xsl:choose>
        <xsl:when test="$tag='110'">
          <!-- corporate name; use subfield a (non-repeatable) -->
          <corpName role="creator">
            <xsl:if test="marc:subfield[@code='0']">
              <xsl:attribute name="dbkey">
                <xsl:value-of select="marc:subfield[@code='0']"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="$analog='true'">
              <xsl:call-template name="analog">
                <xsl:with-param name="tag">
                  <xsl:value-of select="$tag"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="marc:subfield[@code='d']">
                <xsl:value-of select="marc:subfield[@code='a']"/>
                <xsl:text>&#32;</xsl:text>
                <date>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                      <xsl:value-of select="marc:subfield[@code='d']"/>
                    </xsl:with-param>
                  </xsl:call-template>
                </date>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:value-of select="marc:subfield[@code='a']"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </corpName>
        </xsl:when>
        <xsl:otherwise>
          <!-- personal name; use subfields a and d -->
          <persName role="creator">
            <xsl:if test="marc:subfield[@code='0']">
              <xsl:attribute name="dbkey">
                <xsl:value-of select="marc:subfield[@code='0']"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="$analog='true'">
              <xsl:call-template name="analog">
                <xsl:with-param name="tag">
                  <xsl:value-of select="$tag"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="marc:subfield[@code='d']">
                <xsl:value-of select="marc:subfield[@code='a']"/>
                <xsl:text>&#32;</xsl:text>
                <date>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                      <xsl:value-of select="marc:subfield[@code='d']"/>
                    </xsl:with-param>
                  </xsl:call-template>
                </date>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:value-of select="marc:subfield[@code='a']"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
          </persName>
        </xsl:otherwise>
      </xsl:choose>
    </respStmt>
    <xsl:if test="marc:subfield[@code='e']">
      <resp>
        <xsl:for-each select="marc:subfield[@code='e']">
          <xsl:call-template name="chopPunctuation">
            <xsl:with-param name="chopString">
              <xsl:value-of select="."/>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:if test="position() != last()">
            <xsl:text>, </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </resp>
    </xsl:if>

  </xsl:template>

  <!-- ======================================================================= -->
  <!-- respStmt (700, 710)                                                     -->
  <!-- ======================================================================= -->

  <xsl:template match="marc:datafield[@tag='700' or @tag='710']">
    <xsl:variable name="tag">
      <xsl:value-of select="@tag"/>
    </xsl:variable>

    <respStmt>
      <xsl:choose>
        <xsl:when test="$tag='710'">
          <!-- corporate name; use subfield a (non-repeatable) -->
          <corpName>
            <xsl:if test="marc:subfield[@code='0']">
              <xsl:attribute name="dbkey">
                <xsl:value-of select="marc:subfield[@code='0']"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="$analog='true'">
              <xsl:call-template name="analog">
                <xsl:with-param name="tag">
                  <xsl:value-of select="$tag"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="marc:subfield[@code='d']">
                <xsl:value-of select="marc:subfield[@code='a']"/>
                <xsl:text>&#32;</xsl:text>
                <date>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                      <xsl:value-of select="marc:subfield[@code='d']"/>
                    </xsl:with-param>
                  </xsl:call-template>
                </date>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="chopPunctuation">
                  <xsl:with-param name="chopString">
                    <xsl:value-of select="marc:subfield[@code='a']"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates select="marc:subfield[@code='4']" mode="respStmt"/>
          </corpName>
        </xsl:when>
        <xsl:otherwise>
          <!-- personal name -->
          <persName>
            <xsl:if test="marc:subfield[@code='0']">
              <xsl:attribute name="dbkey">
                <xsl:value-of select="marc:subfield[@code='0']"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="$analog='true'">
              <xsl:call-template name="analog">
                <xsl:with-param name="tag">
                  <xsl:value-of select="$tag"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="marc:subfield[@code='d']">
                <xsl:value-of select="marc:subfield[@code='a']"/>
                <xsl:text>&#32;</xsl:text>
                <date>
                  <xsl:call-template name="chopPunctuation">
                    <xsl:with-param name="chopString">
                      <xsl:value-of select="marc:subfield[@code='d']"/>
                    </xsl:with-param>
                  </xsl:call-template>
                </date>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="marc:subfield[@code='a']"/>
              </xsl:otherwise>
            </xsl:choose>
          </persName>
          <xsl:apply-templates select="marc:subfield[@code='4']" mode="respStmt"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="marc:subfield[@code='e']">
        <resp>
          <xsl:for-each select="marc:subfield[@code='e']">
            <xsl:call-template name="chopPunctuation">
              <xsl:with-param name="chopString">
                <xsl:value-of select="."/>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:if test="position() != last()">
              <xsl:text>, </xsl:text>
            </xsl:if>
          </xsl:for-each>
        </resp>
      </xsl:if>
    </respStmt>
  </xsl:template>

  <!-- relator codes for 700 and 710 -->
  <xsl:template match="marc:subfield[@code='4']" mode="respStmt">
    <resp>
      <xsl:variable name="code">
        <xsl:value-of select="."/>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="$code = 'arr'">arranger</xsl:when>
        <xsl:when test="$code = 'art'">artist</xsl:when>
        <xsl:when test="$code = 'asn'">associated name</xsl:when>
        <xsl:when test="$code = 'aut'">author</xsl:when>
        <xsl:when test="$code = 'bnd'">binder</xsl:when>
        <xsl:when test="$code = 'bsl'">bookseller</xsl:when>
        <xsl:when test="$code = 'ccp'">conceptor</xsl:when>
        <xsl:when test="$code = 'chr'">choreographer</xsl:when>
        <xsl:when test="$code = 'clb'">collaborator</xsl:when>
        <xsl:when test="$code = 'cmp'">composer</xsl:when>
        <xsl:when test="$code = 'cnd'">conductor</xsl:when>
        <xsl:when test="$code = 'cns'">censor</xsl:when>
        <xsl:when test="$code = 'com'">compiler</xsl:when>
        <xsl:when test="$code = 'cst'">costume designer</xsl:when>
        <xsl:when test="$code = 'dnc'">dancer</xsl:when>
        <xsl:when test="$code = 'dnr'">donor</xsl:when>
        <xsl:when test="$code = 'dte'">dedicatee</xsl:when>
        <xsl:when test="$code = 'dub'">dubious</xsl:when>
        <xsl:when test="$code = 'edt'">editor</xsl:when>
        <xsl:when test="$code = 'egr'">engraver</xsl:when>
        <xsl:when test="$code = 'fmo'">former owner</xsl:when>
        <xsl:when test="$code = 'ill'">illustrator</xsl:when>
        <xsl:when test="$code = 'itr'">instrumentalist</xsl:when>
        <xsl:when test="$code = 'lbt'">librettist</xsl:when>
        <xsl:when test="$code = 'ltg'">lithograph</xsl:when>
        <xsl:when test="$code = 'lyr'">lyricist</xsl:when>
        <xsl:when test="$code = 'otm'">event organizer</xsl:when>
        <xsl:when test="$code = 'pat'">patron</xsl:when>
        <xsl:when test="$code = 'pbl'">publisher</xsl:when>
        <xsl:when test="$code = 'ppm'">paper maker</xsl:when>
        <xsl:when test="$code = 'prd'">production personnel</xsl:when>
        <xsl:when test="$code = 'prf'">performer</xsl:when>
        <xsl:when test="$code = 'prt'">printer</xsl:when>
        <xsl:when test="$code = 'scr'">scribe</xsl:when>
        <xsl:when test="$code = 'trl'">translator</xsl:when>
        <xsl:when test="$code = 'voc'">vocalist</xsl:when>
        <xsl:otherwise>[unknown]</xsl:otherwise>
      </xsl:choose>
    </resp>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- pubStmt (001, 005)                                                      -->
  <!-- ======================================================================= -->

  <xsl:template name="pubStmt">
    <!-- use <publisher> element? -->
    <respStmt>
      <corpName>
        <xsl:value-of select="$agency"/>
        <xsl:if test="$agency_code != ''">
          <xsl:text>&#32;</xsl:text>
          <identifier authority="MARC Code List for Organizations">
            <xsl:value-of select="$agency_code"/>
          </identifier>
        </xsl:if>
      </corpName>
    </respStmt>
    <date>
      <xsl:choose>
        <xsl:when test="marc:controlfield[@tag='005']">
          <xsl:variable name="pubdate" select="substring(marc:controlfield[@tag='005'],1,4)"/>
          <xsl:value-of select="concat('[', $pubdate, ']')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('[', format-date(current-date(), '[Y]'), ']')"/>
        </xsl:otherwise>
      </xsl:choose>
    </date>
  </xsl:template>

  <xsl:template match="marc:controlfield[@tag='001']">
    <!-- record ID -->
    <xsl:value-of select="."/>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- notesStmt (254, 5xx)                                               -->
  <!-- ======================================================================= -->

  <!-- music presentation (254) -->
  <xsl:template match="marc:datafield[@tag='254']">
    <xsl:variable name="tag" select="@tag"/>
    <annot type="musical_presentation" n="{$tag}">
      <xsl:call-template name="subfieldSelect">
        <xsl:with-param name="codes">a</xsl:with-param>
      </xsl:call-template>
    </annot>
  </xsl:template>

  <!-- notes (5XX) -->
  <xsl:template match="marc:datafield[@tag='500' or @tag='506' or @tag='510' or @tag='520' or
    @tag='525' or @tag='533' or @tag='541' or @tag='545' or @tag='546' or @tag='555' or
    @tag='561' or @tag='563' or @tag='580' or @tag='591' or @tag='596' or @tag='597' or
    @tag='598']">
    <xsl:variable name="tag" select="@tag"/>
    <xsl:variable name="annottype">
      <xsl:choose>
        <xsl:when test="$tag = '500'">general</xsl:when>
        <!--<xsl:when test="$tag = '505'">content</xsl:when>-->
        <xsl:when test="$tag = '506'">access</xsl:when>
        <xsl:when test="$tag = '510'">reference</xsl:when>
        <xsl:when test="$tag = '520'">summary</xsl:when>
        <xsl:when test="$tag = '525'">supplementary_material</xsl:when>
        <xsl:when test="$tag = '533'">reproduction</xsl:when>
        <xsl:when test="$tag = '541'">acquisition</xsl:when>
        <xsl:when test="$tag = '545'">biography</xsl:when>
        <xsl:when test="$tag = '546'">language</xsl:when>
        <xsl:when test="$tag = '555'">aid</xsl:when>
        <xsl:when test="$tag = '561'">provenance</xsl:when>
        <xsl:when test="$tag = '563'">binding</xsl:when>
        <xsl:when test="$tag = '580'">linking</xsl:when>
        <xsl:when test="$tag = '591'">local</xsl:when>
        <xsl:when test="$tag = '596'">local</xsl:when>
        <xsl:when test="$tag = '597'">local</xsl:when>
        <xsl:when test="$tag = '598'">local</xsl:when>

        <!-- RISM specifications for 59x fields -->
        <!--
        <xsl:when test="$tag = '591'">olim</xsl:when>
        <xsl:when test="$tag = '596'">rism_reference</xsl:when>
        <xsl:when test="$tag = '597'">binding</xsl:when>
        <xsl:when test="$tag = '598'">original_parts</xsl:when>
        -->

        <xsl:otherwise>[unspecified]</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <annot type="{$annottype}">
      <xsl:if test="$analog='true'">
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="$tag"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$tag='541'">
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">acd</xsl:with-param>
            <xsl:with-param name="delimiter">, </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$tag='591'">
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">a4</xsl:with-param>
            <xsl:with-param name="delimiter">, </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">a</xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </annot>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='505']">
    <contents>
      <xsl:if test="$analog='true'">
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="@tag"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
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
      <p>
        <xsl:call-template name="chopPunctuation">
          <xsl:with-param name="chopString">
            <xsl:call-template name="subfieldSelect">
              <xsl:with-param name="codes">a</xsl:with-param>
            </xsl:call-template>
          </xsl:with-param>
        </xsl:call-template>
      </p>
    </contents>
  </xsl:template>

  <!-- scoring information (594) -->
  <xsl:template match="marc:datafield[@tag='594']">
    <xsl:variable name="tag" select="@tag"/>
    <annot type="scoring">
      <xsl:if test="$analog='true'">
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="$tag"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:variable name="delimiter">
        <xsl:text>; </xsl:text>
      </xsl:variable>
      <!-- cat everything into the $str variable -->
      <xsl:variable name="str">
        <xsl:for-each select="marc:subfield">
          <xsl:variable name="code">
            <xsl:value-of select="@code"/>
          </xsl:variable>
          <xsl:variable name="scoring">
            <xsl:choose>
              <xsl:when test="$code = 'a'">Solo voice</xsl:when>
              <xsl:when test="$code = 'b'">Additional solo voice</xsl:when>
              <xsl:when test="$code = 'c'">Choir voice</xsl:when>
              <xsl:when test="$code = 'd'">Additional choir voice</xsl:when>
              <xsl:when test="$code = 'e'">Solo intrument</xsl:when>
              <xsl:when test="$code = 'f'">Strings</xsl:when>
              <xsl:when test="$code = 'g'">Woodwinds</xsl:when>
              <xsl:when test="$code = 'h'">Brasses</xsl:when>
              <xsl:when test="$code = 'i'">Plucked instruments</xsl:when>
              <xsl:when test="$code = 'k'">Percussion</xsl:when>
              <xsl:when test="$code = 'l'">Keyboards</xsl:when>
              <xsl:when test="$code = 'm'">Other instruments</xsl:when>
              <xsl:when test="$code = 'n'">Basso continuo</xsl:when>
              <xsl:otherwise>[unspecified]</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <!-- cat the values: -->
          <xsl:value-of select="$scoring"/>
          <xsl:text>: </xsl:text>
          <xsl:value-of select="text()"/>
          <xsl:value-of select="$delimiter"/>
        </xsl:for-each>
      </xsl:variable>
      <!-- truncate the last delimiter -->
      <xsl:value-of select="substring($str,1,string-length($str)-string-length($delimiter))"/>
    </annot>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='595']">
    <xsl:variable name="tag" select="@tag"/>
    <castItem xmlns="http://www.music-encoding.org/ns/mei">
      <xsl:if test="$analog='true'">
        <!-- Unfortunately, castItem doesn't allow @analog, so we have to abuse @label -->
        <xsl:attribute name="label">
          <xsl:value-of select="concat('marc:', $tag)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:call-template name="subfieldSelect">
        <xsl:with-param name="codes">a</xsl:with-param>
      </xsl:call-template>
    </castItem>
  </xsl:template>


  <!-- ======================================================================= -->
  <!-- sourceDesc (028, 041, 260, 300, 590, 592, 593)                          -->
  <!-- ======================================================================= -->

  <!-- plate number (028) -->
  <xsl:template match="marc:datafield[@tag='028']">
    <xsl:variable name="tag" select="@tag"/>
    <xsl:variable name="elementName">
      <xsl:choose>
        <xsl:when test="@ind1='2'">plateNum</xsl:when>
        <xsl:otherwise>identifier</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{$elementName}">
      <xsl:if test="$elementName='identifier'">
        <xsl:variable name="identifierType">
          <xsl:choose>
            <xsl:when test="@ind1='0'">issue</xsl:when>
            <xsl:when test="@ind1='1'">matrix</xsl:when>
            <xsl:when test="@ind1='3'">otherMusic</xsl:when>
            <xsl:when test="@ind1='4'">videorecording</xsl:when>
            <xsl:when test="@ind1='5'">publisher</xsl:when>
          </xsl:choose>
        </xsl:variable>
        <xsl:attribute name="type">
          <xsl:value-of select="concat($identifierType, 'Number')"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="$analog='true'">
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="@tag"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="subfieldSelect">
        <xsl:with-param name="codes">a</xsl:with-param>
      </xsl:call-template>
      <!-- plate number source -->
      <xsl:if test="marc:subfield[@code='b']">
        <xsl:text> (</xsl:text>
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">b</xsl:with-param>
        </xsl:call-template>
        <xsl:text>)</xsl:text>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='041']">
    <xsl:for-each select="marc:subfield[matches(@code, '[a-z]')]">
      <language>
        <xsl:if test="$analog='true'">
          <xsl:call-template name="analog">
            <xsl:with-param name="tag">
              <xsl:value-of select="concat(../@tag, @code)"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:attribute name="label">
          <xsl:choose>
            <xsl:when test="@code='a'">text/sound track</xsl:when>
            <xsl:when test="@code='b'">summary/abstract</xsl:when>
            <xsl:when test="@code='d'">sung/spoken text</xsl:when>
            <xsl:when test="@code='e'">libretto</xsl:when>
            <xsl:when test="@code='f'">table of contents</xsl:when>
            <xsl:when test="@code='g'">accompanying material</xsl:when>
            <xsl:when test="@code='h'">original</xsl:when>
            <xsl:when test="@code='k'">intermediate translation</xsl:when>
            <xsl:when test="@code='j'">subtitles/captions</xsl:when>
            <xsl:when test="@code='m'">original accompanying material</xsl:when>
            <xsl:when test="@code='n'">original libretto</xsl:when>
          </xsl:choose>
        </xsl:attribute>
        <xsl:value-of select="."/>
      </language>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='260']">
    <pubStmt>
      <xsl:if test="$analog='true'">
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="@tag"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <pubPlace>
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">a</xsl:with-param>
        </xsl:call-template>
      </pubPlace>
      <publisher>
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">b</xsl:with-param>
        </xsl:call-template>
      </publisher>
      <xsl:call-template name="subfieldSelect">
        <xsl:with-param name="codes">c</xsl:with-param>
        <xsl:with-param name="element">date</xsl:with-param>
      </xsl:call-template>
      <xsl:if test="marc:subfield[@code='e' or @code='f' or @code='g']">
        <distributor>
          <xsl:if test="marc:subfield[@code='e']">
            <xsl:call-template name="subfieldSelect">
              <xsl:with-param name="codes">e</xsl:with-param>
              <xsl:with-param name="element">geogName</xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">f</xsl:with-param>
            <xsl:with-param name="element">name</xsl:with-param>
          </xsl:call-template>
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">g</xsl:with-param>
            <xsl:with-param name="element">date</xsl:with-param>
          </xsl:call-template>
        </distributor>
      </xsl:if>
      <xsl:apply-templates select="../marc:datafield[@tag='028'][not(@ind1='2')]"/>
    </pubStmt>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='300']">
    <physDesc>
      <xsl:if test="marc:subfield[@code='a']">
        <extent>
          <xsl:choose>
            <xsl:when test="matches(marc:subfield[@code='b'], 'digital')">
              <xsl:if test="$analog='true'">
                <xsl:call-template name="analog">
                  <xsl:with-param name="tag">
                    <xsl:value-of select="concat(@tag, 'ab')"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:if>
              <xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">ab</xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:when test="marc:subfield[@code='b'] and
              not(substring(../marc:controlfield[@tag='007'], 1, 1) = 's')">
              <xsl:if test="$analog='true'">
                <xsl:call-template name="analog">
                  <xsl:with-param name="tag">
                    <xsl:value-of select="concat(@tag, 'ab')"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:if>
              <xsl:call-template name="subfieldSelect">
                <xsl:with-param name="codes">ab</xsl:with-param>
                <xsl:with-param name="delimiter">;&#32;</xsl:with-param>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="$analog='true'">
                <xsl:call-template name="analog">
                  <xsl:with-param name="tag">
                    <xsl:value-of select="concat(@tag, 'a')"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">a</xsl:with-param>
                  </xsl:call-template>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </extent>
      </xsl:if>
      <xsl:if test="marc:subfield[@code='b'][not(matches(., 'digital'))]">
        <xsl:choose>
          <xsl:when test="substring(../marc:controlfield[@tag='007'], 1, 1) = 's'">
            <playingSpeed>
              <xsl:if test="$analog='true'">
                <xsl:call-template name="analog">
                  <xsl:with-param name="tag">
                    <xsl:value-of select="concat(@tag, 'b')"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:if>
              <xsl:call-template name="chopPunctuation">
                <xsl:with-param name="chopString">
                  <xsl:call-template name="subfieldSelect">
                    <xsl:with-param name="codes">b</xsl:with-param>
                  </xsl:call-template>
                </xsl:with-param>
              </xsl:call-template>
            </playingSpeed>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="marc:subfield[@code='c']">
        <dimensions>
          <xsl:if test="$analog='true'">
            <xsl:call-template name="analog">
              <xsl:with-param name="tag">
                <xsl:value-of select="concat(@tag, 'c')"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">c</xsl:with-param>
          </xsl:call-template>
        </dimensions>
      </xsl:if>
      <xsl:if test="marc:subfield[@code='e']">
        <carrierForm>
          <xsl:if test="$analog='true'">
            <xsl:call-template name="analog">
              <xsl:with-param name="tag">
                <xsl:value-of select="concat(@tag, 'e')"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">e</xsl:with-param>
          </xsl:call-template>
        </carrierForm>
      </xsl:if>
      <xsl:apply-templates select="../marc:datafield[@tag='028'][@ind1='2']"/>
      <xsl:apply-templates select="../marc:datafield[@tag='306']"/>
    </physDesc>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='590' or @tag='592' or @tag='593']">
    <annot>
      <xsl:if test="$analog='true'">
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="@tag"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:value-of select="normalize-space(.)"/>
    </annot>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='306']">
    <xsl:for-each select="marc:subfield[@code='a']">
      <extent label="Playing time">
        <xsl:if test="$analog='true'">
          <xsl:call-template name="analog">
            <xsl:with-param name="tag">
              <xsl:value-of select="concat(../@tag, 'a')"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:value-of select="concat(substring(., 1, 2), ':', substring(., 3, 2), ':', substring(.,
          5, 2))"/>
      </extent>
    </xsl:for-each>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- profileDesc (508, 511, 518, 650, 651, 653, 657)                         -->
  <!-- ======================================================================= -->

  <!-- creation note (508) -->
  <xsl:template match="marc:datafield[@tag='508']">
    <xsl:variable name="tag" select="@tag"/>
    <xsl:call-template name="subfieldSelect">
      <xsl:with-param name="codes">a</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- classification (050, 082, 090, 648, 650, 651, 653, 654, 655, 656, 657, 658) -->
  <xsl:template match="marc:datafield[@tag='050' or @tag='082' or @tag='090' or @tag='648' or
    @tag='650' or @tag='651' or @tag='653' or @tag='654' or @tag='655' or @tag='656' or
    @tag='657' or @tag='658']">
    <xsl:variable name="tag" select="@tag"/>
    <xsl:variable name="label">
      <xsl:choose>
        <xsl:when test="$tag = '050'">callNum</xsl:when>
        <xsl:when test="$tag = '082'">callNum</xsl:when>
        <xsl:when test="$tag = '090'">callNum</xsl:when>
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
        <xsl:when test="$tag = '090'">LocalNum</xsl:when>
        <xsl:when test="$ind2 = '0'">LCSH</xsl:when>
        <xsl:when test="$ind2 = '1'">LCCL</xsl:when>
        <xsl:when test="$ind2 = '2'">MeSH</xsl:when>
        <xsl:when test="$ind2 = '3'">NALSA</xsl:when>
        <xsl:when test="$ind2 = '5'">CSH</xsl:when>
        <xsl:when test="$ind2 = '6'">RVM</xsl:when>
        <xsl:when test="$ind2 = '7'">
          <xsl:value-of select="replace(marc:subfield[@code='2'], '&#32;', '_')"/>
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
      <xsl:if test="$analog='true'">
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="$tag"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:call-template name="chopPunctuation">
        <xsl:with-param name="chopString">
          <xsl:call-template name="subfieldSelect">
            <xsl:with-param name="codes">
              <xsl:choose>
                <xsl:when test="$tag = '050'">
                  <xsl:text>ab</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>a</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:with-param>
      </xsl:call-template>
    </term>
  </xsl:template>

  <!-- participants in event -->
  <xsl:template match="marc:datafield[@tag='511']">
    <xsl:variable name="tag" select="@tag"/>
    <event>
      <xsl:if test="$analog='true'">
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="$tag"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <p>
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">a</xsl:with-param>
        </xsl:call-template>
      </p>
    </event>
  </xsl:template>

  <!-- notes (518) -->
  <xsl:template match="marc:datafield[@tag='518']">
    <xsl:variable name="tag" select="@tag"/>
    <event>
      <xsl:if test="$analog='true'">
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="$tag"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <p>
        <xsl:call-template name="subfieldSelect">
          <xsl:with-param name="codes">a</xsl:with-param>
          <xsl:with-param name="delimiter">; </xsl:with-param>
        </xsl:call-template>
      </p>
    </event>
  </xsl:template>

  <!-- ======================================================================= -->
  <!-- incipit (031)                                                           -->
  <!-- ======================================================================= -->

  <xsl:template match="marc:datafield[@tag='031']">
    <incip>
      <xsl:attribute name="n">
        <xsl:value-of select="normalize-space(concat(marc:subfield[@code='a'], '&#32;',
          marc:subfield[@code='b'], '&#32;', marc:subfield[@code='c']))"/>
      </xsl:attribute>
      <xsl:attribute name="label">
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
      </xsl:attribute>
      <xsl:if test="$analog='true'">
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="'031'"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
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
      <xsl:if test="marc:subfield[@code='p']">
        <incipCode>
          <xsl:attribute name="form">
            <xsl:choose>
              <xsl:when test="marc:subfield[@code='2']='pe'">
                <xsl:text>plaineAndEasie</xsl:text>
              </xsl:when>
            </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="marc:subfield[@code='p']"/>
        </incipCode>
      </xsl:if>
      <xsl:if test="marc:subfield[@code='t']">
        <incipText>
          <p>
            <xsl:value-of select="marc:subfield[@code='t']"/>
          </p>
        </incipText>
      </xsl:if>
    </incip>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='045']">
    <!-- dates in 045 are assumed to be C.E. -->
    <xsl:text>Date of composition:&#32;</xsl:text>
    <xsl:choose>
      <xsl:when test="@ind1 = '0' or @ind1 = '1'">
        <xsl:for-each select="marc:subfield[@code='b']">
          <date>
            <xsl:if test="$analog='true'">
              <xsl:call-template name="analog">
                <xsl:with-param name="tag">
                  <xsl:value-of select="'045b'"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:if>
            <xsl:value-of select="substring(., 2)"/>
          </date>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="@ind1 = '2'">
        <xsl:variable name="sortedDates">
          <xsl:for-each select="marc:subfield[@code='b']">
            <xsl:sort/>
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </xsl:variable>
        <date>
          <xsl:attribute name="notbefore">
            <xsl:value-of select="substring($sortedDates/marc:subfield[@code='b'][1], 2, 8)"/>
          </xsl:attribute>
          <xsl:attribute name="notafter">
            <xsl:value-of
              select="substring($sortedDates/marc:subfield[@code='b'][position()=last()], 2, 8)"/>
          </xsl:attribute>
          <xsl:for-each select="marc:subfield[@code='b']">
            <date>
              <xsl:if test="$analog='true'">
                <xsl:call-template name="analog">
                  <xsl:with-param name="tag">
                    <xsl:value-of select="'045b'"/>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:if>
              <xsl:value-of select="substring(., 2)"/>
            </date>
          </xsl:for-each>
        </date>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="marc:datafield[@tag='048']">
    <instrVoiceGrp>
      <xsl:if test="$analog='true'">
        <xsl:call-template name="analog">
          <xsl:with-param name="tag">
            <xsl:value-of select="'045b'"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@ind2='7' and matches(marc:subfield[@code='2'], 'iamlmp', 'i')">
          <!-- Use IAML Medium of Performance codes -->
          <xsl:attribute name="authority">iamlmp</xsl:attribute>
          <xsl:attribute name="authURI"
            >http://www.iaml.info/en/activities/cataloguing/unimarc/medium</xsl:attribute>
          <xsl:for-each select="marc:subfield[@code='a' or @code='b']">
            <instrVoice>
              <xsl:if test="@code='b'">
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
              <xsl:value-of select="$iamlMusPerfList//mei:instr[@code=$code048]"/>
            </instrVoice>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <!-- Use MARC Instruments and Voices Code List -->
          <xsl:attribute name="authority">marcmusperf</xsl:attribute>
          <xsl:attribute name="authURI"
            >http://www.loc.gov/standards/valuelist/marcmusperf.html</xsl:attribute>
          <xsl:for-each select="marc:subfield[@code='a' or @code='b']">
            <instrVoice>
              <xsl:if test="@code='b'">
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
              <xsl:value-of select="$marcMusPerfList//mei:instr[@code=$code048]"/>
            </instrVoice>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </instrVoiceGrp>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
