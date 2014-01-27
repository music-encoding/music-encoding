<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns="http://www.loc.gov/MARC21/slim" xmlns:mei="http://www.music-encoding.org/ns/mei"
  xmlns:marc="http://www.loc.gov/MARC21/slim" exclude-result-prefixes="marc mei">
  <xsl:output method="xml" encoding="UTF-8" indent="yes" media-type="text/xml"/>
  <xsl:strip-space elements="*"/>

  <!-- Parameters -->
  <!-- PARAM: agency_code 
    The MARC organization code for the agency creating the MARC record. -->
  <xsl:param name="agency_code"/>
  <!-- PARAM: model_path
    Path to the MARC XML schema -->
  <xsl:param name="model_path"
    >http://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd</xsl:param>

  <!-- Global variables -->
  <!-- version -->
  <xsl:variable name="version">
    <xsl:text>1.0 ALPHA</xsl:text>
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

  <!-- Utilities -->
  <xsl:template name="controlField">
    <xsl:param name="tag"/>
    <xsl:param name="value"/>
    <controlfield tag="{$tag}">
      <xsl:value-of select="$value"/>
    </controlfield>
  </xsl:template>

  <xsl:template name="indicators">
    <xsl:param name="ind1" xml:space="preserve">&#32;</xsl:param>
    <xsl:param name="ind2" xml:space="preserve">&#32;</xsl:param>
    <xsl:attribute name="ind1">
      <xsl:value-of select="$ind1"/>
    </xsl:attribute>
    <xsl:attribute name="ind2">
      <xsl:value-of select="$ind2"/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="leader">
    <!-- currently produces a generic (read, not very useful) leader -->
    <xsl:text>&#xA;&#x9;</xsl:text>
    <xsl:comment>&#32;Leader value MUST BE EDITED!&#32;</xsl:comment>
    <xsl:text>&#xA;</xsl:text>
    <leader>00000ncm&#32;a22000004u&#32;4500</leader>
  </xsl:template>

  <xsl:template name="subfield">
    <xsl:param name="code"/>
    <xsl:param name="value"/>
    <xsl:param name="delimiter"/>
    <subfield code="{$code}">
      <xsl:value-of select="$value"/>
      <xsl:value-of select="$delimiter"/>
    </subfield>
  </xsl:template>

  <!-- Main ouput template -->
  <xsl:template match="/">
    <xsl:apply-templates select="//mei:meiHead"/>
  </xsl:template>

  <xsl:template match="mei:meiHead">
    <xsl:if test="$model_path != ''">
      <xsl:processing-instruction name="xml-model">
        <xsl:value-of select="concat('&#32;href=&quot;', $model_path, '&quot;')"/>
      </xsl:processing-instruction>
    </xsl:if>
    <xsl:comment>
      <xsl:text>MARC generated by mei2marc.xsl version </xsl:text>
      <xsl:value-of select="$version"/>
    </xsl:comment>

    <record>
      <xsl:apply-templates select="mei:fileDesc"/>
    </record>
  </xsl:template>

  <xsl:template match="mei:fileDesc">
    <!-- LEADER -->
    <xsl:call-template name="leader"/>

    <!-- CONTROL FIELDS -->
    <!-- 001 (Control number), 003 (Control number identifier) -->
    <xsl:choose>
      <xsl:when test="../@xml:id">
        <xsl:call-template name="controlField">
          <xsl:with-param name="tag">001</xsl:with-param>
          <xsl:with-param name="value">
            <xsl:value-of select="../@xml:id"/>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:if test="not($agency_code='')">
          <xsl:call-template name="controlField">
            <xsl:with-param name="tag">003</xsl:with-param>
            <xsl:with-param name="value">
              <xsl:value-of select="$agency_code"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="../mei:altId[1]" mode="id001"/>
      </xsl:otherwise>
    </xsl:choose>

    <!-- 005 (Date/Time of latest transaction) -->
    <xsl:call-template name="controlField">
      <xsl:with-param name="tag">005</xsl:with-param>
      <xsl:with-param name="value">
        <xsl:value-of select="format-dateTime(current-dateTime(),
          '[Y][M02][D02][H02][m02][s02].[f1,1-1]')"/>
      </xsl:with-param>
    </xsl:call-template>

    <!-- DATA FIELDS -->
    <!-- 031 (Musical incipit) -->
    <xsl:apply-templates select="//mei:incip[mei:incipText[not(contains(@analog, 'marc:246'))]]"/>

    <!-- 035 (System control number) -->
    <xsl:choose>
      <xsl:when test="../@xml:id">
        <xsl:apply-templates select="../mei:altId" mode="id035"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="../mei:altId[position() &gt; 1]" mode="id035"/>
      </xsl:otherwise>
    </xsl:choose>

    <!-- 040 (Language of cataloging -->
    <xsl:if test="../@xml:lang">
      <xsl:apply-templates select="../@xml:lang"/>
    </xsl:if>

    <!-- 041 (Language) -->
    <xsl:apply-templates select="../mei:workDesc/mei:work/mei:langUsage"/>

    <!-- 045 (Date of composition) -->
    <xsl:apply-templates select="../mei:workDesc" mode="compositionDate"/>

    <!-- 048 (Number of musical instruments or voices code) -->
    <xsl:apply-templates select="//mei:work/mei:perfMedium/mei:instrumentation"/>

    <!-- 050, 082, 090 (Call numbers)-->
    <xsl:apply-templates select="//mei:classification//mei:term[contains(@analog, 'marc:090') or
      contains(@analog, 'marc:050') or contains(@analog, 'marc:082')]"/>

    <!-- 100, 110 (Main entry) -->
    <xsl:apply-templates select="mei:titleStmt/mei:respStmt/mei:persName[contains(@analog,
      'marc:100') or contains(@role, 'creator') or contains(@role, 'composer')] |
      mei:titleStmt/mei:respStmt/mei:corpName[contains(@analog, 'marc:110') or contains(@role,
      'creator') or contains(@role, 'composer')]"/>

    <!-- 240 (Uniform title) -->
    <xsl:choose>
      <xsl:when test="mei:titleStmt/mei:title[contains(@analog, 'marc:240') or contains(@type,
        'uniform')]">
        <xsl:apply-templates select="mei:titleStmt/mei:title[contains(@analog, 'marc:240') or
          contains(@type, 'uniform')]"/>
      </xsl:when>
    </xsl:choose>

    <!-- 245 (Title) -->
    <xsl:apply-templates select="mei:titleStmt"/>

    <!-- 246 (First line of text) -->
    <xsl:apply-templates select="//mei:incip[mei:incipText[contains(@analog, 'marc:246')]] |
      //mei:incip[count(mei:incipText)=count(mei:*)][1]"/>

    <!-- 260 (Imprint) -->
    <xsl:apply-templates select="mei:pubStmt"/>

    <!-- 300 (Physical description) -->

    <!-- 490 (Series statement) -->
    <xsl:apply-templates select="mei:seriesStmt"/>

    <!-- 500 (General note) -->
    <xsl:apply-templates select="../mei:encodingDesc/mei:projectDesc"/>
    <xsl:apply-templates select="../mei:encodingDesc/mei:samplingDecl"/>

    <!-- 505 (Contents note) -->
    <xsl:apply-templates select="mei:sourceDesc/mei:source/mei:contents"/>

    <!-- 650 (Subject added entry) -->
    <xsl:apply-templates select="//mei:classification//mei:term[contains(@analog, 'marc:650')]"/>

    <!-- 700, 710 (Added entries) -->
    <xsl:apply-templates select="mei:titleStmt/mei:respStmt/mei:persName[contains(@analog,
      'marc:700')]"/>
    <xsl:apply-templates select="mei:titleStmt/mei:respStmt/mei:corpName[contains(@analog,
      'marc:710')]"/>
    <xsl:apply-templates select="mei:titleStmt/mei:respStmt/mei:persName[not(@analog) and
      not(contains(@role, 'creator') or contains(@role, 'composer'))]"/>
    <xsl:apply-templates select="mei:titleStmt/mei:respStmt/mei:corpName[not(@analog) and
      not(contains(@role, 'creator') or contains(@role, 'composer'))]"/>
    <xsl:apply-templates select="mei:seriesStmt/mei:respStmt/mei:persName |
      mei:seriesStmt/mei:respStmt/mei:corpName"/>
  </xsl:template>

  <xsl:template match="mei:altId | mei:*[contains(@analog, 'marc:001')]" mode="id001">
    <!-- 001 (Control number) -->
    <xsl:call-template name="controlField">
      <xsl:with-param name="tag">001</xsl:with-param>
      <xsl:with-param name="value">
        <xsl:value-of select="normalize-space(.)"/>
      </xsl:with-param>
    </xsl:call-template>
    <!-- 003 (Control number identifier) -->
    <xsl:if test="not($agency_code='')">
      <xsl:call-template name="controlField">
        <xsl:with-param name="tag">003</xsl:with-param>
        <xsl:with-param name="value">
          <xsl:value-of select="$agency_code"/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:altId" mode="id035">
    <!-- 035 (System control number) -->
    <xsl:variable name="tag" select="'035'"/>
    <datafield>
      <xsl:attribute name="tag" select="$tag"/>
      <xsl:call-template name="indicators"/>
      <xsl:call-template name="subfield">
        <xsl:with-param name="code">a</xsl:with-param>
        <xsl:with-param name="value">
          <xsl:if test="not($agency_code='')">
            <xsl:value-of select="concat('(', $agency_code, ')')"/>
          </xsl:if>
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:with-param>
      </xsl:call-template>
    </datafield>
  </xsl:template>

  <xsl:template match="mei:contents">
    <xsl:variable name="tag" select="'505'"/>
    <datafield>
      <xsl:attribute name="tag" select="$tag"/>
      <xsl:call-template name="indicators">
        <xsl:with-param name="ind1">0</xsl:with-param>
        <xsl:with-param name="ind2">
          <xsl:choose>
            <xsl:when test="mei:contentItem">
              <xsl:text>0</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>&#32;</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:choose>
        <xsl:when test="mei:contentItem">
          <xsl:for-each select="mei:contentItem">
            <xsl:call-template name="subfield">
              <xsl:with-param name="code">t</xsl:with-param>
              <xsl:with-param name="value">
                <xsl:value-of select="normalize-space(.)"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="subfield">
            <xsl:with-param name="code">a</xsl:with-param>
            <xsl:with-param name="value">
              <xsl:value-of select="mei:p"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </datafield>
  </xsl:template>

  <xsl:template match="mei:corpName">
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@analog">
          <xsl:value-of select="substring(substring-after(@analog, ':'), 1, 3)"/>
        </xsl:when>
        <xsl:otherwise>710</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <datafield>
      <xsl:attribute name="tag" select="$tag"/>
      <xsl:call-template name="indicators"/>
      <xsl:choose>
        <!-- Only text; subfield |a only -->
        <xsl:when test="count(mei:*) = 0">
          <xsl:call-template name="subfield">
            <xsl:with-param name="code">a</xsl:with-param>
            <xsl:with-param name="value">
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <!-- Mixed content; split into multiple subfields -->
        <xsl:otherwise>
          <xsl:call-template name="subfield">
            <xsl:with-param name="code">a</xsl:with-param>
            <xsl:with-param name="value">
              <xsl:value-of select="normalize-space(text())"/>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:if test="mei:date">
            <xsl:call-template name="subfield">
              <xsl:with-param name="code">d</xsl:with-param>
              <xsl:with-param name="value">
                <xsl:value-of select="mei:date"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="@dbkey">
        <xsl:call-template name="subfield">
          <xsl:with-param name="code">0</xsl:with-param>
          <xsl:with-param name="value">
            <xsl:value-of select="@dbkey"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="ancestor::mei:respStmt/mei:resp or @role">
        <xsl:variable name="role">
          <xsl:choose>
            <xsl:when test="ancestor::mei:respStmt/mei:resp">
              <xsl:choose>
                <xsl:when test="matches(ancestor::mei:respStmt/mei:resp, 'encoder')">
                  <xsl:text>markup editor</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="ancestor::mei:respStmt/mei:resp"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="matches(@role, 'encoder')">
                  <xsl:text>markup editor</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="@role"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="relatorCode">
          <xsl:value-of select="$marcRelList/marc:relator[.=$role]/@code"/>
        </xsl:variable>
        <xsl:if test="not($relatorCode = '')">
          <xsl:call-template name="subfield">
            <xsl:with-param name="code">4</xsl:with-param>
            <xsl:with-param name="value">
              <xsl:value-of select="$relatorCode"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
    </datafield>
  </xsl:template>

  <xsl:template match="mei:fileDesc/mei:pubStmt">
    <xsl:variable name="tag" select="'260'"/>
    <datafield>
      <xsl:attribute name="tag" select="$tag"/>
      <xsl:call-template name="indicators"/>
      <xsl:call-template name="subfield">
        <xsl:with-param name="code">a</xsl:with-param>
        <xsl:with-param name="value">
          <xsl:variable name="pubPlace">
            <xsl:choose>
              <xsl:when test="mei:pubPlace">
                <xsl:value-of select="mei:pubPlace"/>
              </xsl:when>
              <xsl:when test="mei:address">
                <xsl:for-each select="mei:address[1]">
                  <xsl:for-each select="mei:addrLine">
                    <xsl:value-of select="normalize-space(.)"/>
                    <xsl:if test="position() != last()">
                      <xsl:text>, &#32;</xsl:text>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:for-each>
              </xsl:when>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="not($pubPlace = '')">
              <xsl:value-of select="normalize-space($pubPlace)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>[s.l.]</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="subfield">
        <xsl:with-param name="code">b</xsl:with-param>
        <xsl:with-param name="value">
          <xsl:variable name="publisher">
            <xsl:choose>
              <xsl:when test="mei:publisher">
                <xsl:value-of select="mei:publisher"/>
              </xsl:when>
              <xsl:when test="mei:respStmt/mei:corpName">
                <xsl:value-of select="mei:respStmt/mei:corpName"/>
              </xsl:when>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="not($publisher = '')">
              <xsl:value-of select="normalize-space($publisher)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>[s.n.]</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="subfield">
        <xsl:with-param name="code">c</xsl:with-param>
        <xsl:with-param name="value">
          <xsl:variable name="date">
            <xsl:choose>
              <xsl:when test="contains(mei:date, '-')">
                <xsl:value-of select="substring-before(mei:date, '-')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="mei:date"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="not($date = '')">
              <xsl:value-of select="$date"/>
            </xsl:when>
            <xsl:otherwise>[n.d.]</xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </datafield>
  </xsl:template>

  <xsl:template match="mei:incip">
    <xsl:choose>
      <xsl:when test="mei:incipText[contains(@analog, 'marc:246')] or
        count(mei:incipText)=count(mei:*)">
        <xsl:variable name="tag" select="'246'"/>
        <datafield>
          <xsl:attribute name="tag" select="$tag"/>
          <xsl:call-template name="indicators"/>
          <xsl:if test="mei:incipText/@label">
            <xsl:call-template name="subfield">
              <xsl:with-param name="code">i</xsl:with-param>
              <xsl:with-param name="value">
                <xsl:value-of select="replace(mei:incipText/@label, '[\.:,;\+/ ]+$', '')"/>
                <xsl:text>:</xsl:text>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="subfield">
              <xsl:with-param name="code">a</xsl:with-param>
              <xsl:with-param name="value">
                <xsl:value-of select="mei:incipText"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
        </datafield>
      </xsl:when>
      <!-- MARC only supports Plaine and Easie or DARMS -->
      <xsl:when test="mei:incipCode[@form='plaineAndEasie' or @form='DARMS']">
        <xsl:variable name="tag" select="'031'"/>
        <xsl:variable name="form" select="mei:incipCode/@form"/>
        <datafield>
          <xsl:attribute name="tag" select="$tag"/>
          <xsl:call-template name="indicators"/>
          <xsl:if test="@n">
            <xsl:call-template name="subfield">
              <xsl:with-param name="code">a</xsl:with-param>
              <xsl:with-param name="value">
                <xsl:value-of select="@n"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:if test="@label">
            <xsl:call-template name="subfield">
              <xsl:with-param name="code">d</xsl:with-param>
              <xsl:with-param name="value">
                <xsl:value-of select="@label"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
          <xsl:call-template name="subfield">
            <xsl:with-param name="code">p</xsl:with-param>
            <xsl:with-param name="value">
              <xsl:value-of select="mei:incipCode[@form=$form][1]"/>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:for-each select="mei:incipText">
            <xsl:call-template name="subfield">
              <xsl:with-param name="code">t</xsl:with-param>
              <xsl:with-param name="value">
                <xsl:value-of select="normalize-space(.)"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
          <xsl:call-template name="subfield">
            <xsl:with-param name="code">2</xsl:with-param>
            <xsl:with-param name="value">
              <xsl:choose>
                <xsl:when test="$form='plaineAndEasie'">
                  <xsl:text>pe</xsl:text>
                </xsl:when>
                <xsl:when test="$form='DARMS'">
                  <xsl:text>da</xsl:text>
                </xsl:when>
              </xsl:choose>
            </xsl:with-param>
          </xsl:call-template>
        </datafield>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="mei:instrumentation">
    <xsl:variable name="tag" select="'048'"/>
    <xsl:variable name="authority">
      <xsl:choose>
        <!-- MARC or IAML code list referenced in @authority -->
        <xsl:when test="descendant-or-self::mei:*/@authority">
          <xsl:value-of select="descendant-or-self::mei:*[@authority][1]/@authority"/>
        </xsl:when>
        <!-- MARC or IAML code list referenced in @authURI -->
        <xsl:when test="descendant-or-self::mei:*/@authURI">
          <xsl:choose>
            <xsl:when test="descendant-or-self::mei:*[@authURI][1]/@authURI=
              'http://www.loc.gov/standards/valuelist/marcmusperf.html'">
              <xsl:text>marcmusperf</xsl:text>
            </xsl:when>
            <xsl:when test="descendant-or-self::mei:*[@authURI][1]/@authURI=
              'http://www.iaml.info/en/activities/cataloguing/unimarc/medium'">
              <xsl:text>iamlmp</xsl:text>
            </xsl:when>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <!-- Attempt to determine authority from codes/values in instrVoice? -->
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <datafield>
      <xsl:attribute name="tag" select="$tag"/>
      <xsl:call-template name="indicators">
        <xsl:with-param name="ind1" xml:space="preserve">&#32;</xsl:with-param>
        <xsl:with-param name="ind2">
          <xsl:choose>
            <xsl:when test="$authority='marcmusperf'">
              <xsl:text>&#32;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>7</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:for-each select="//mei:instrVoice">
        <xsl:variable name="term" select="."/>
        <xsl:variable name="subfield">
          <xsl:choose>
            <xsl:when test="not(@solo='true')">
              <xsl:text>a</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>b</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="subfield">
          <xsl:with-param name="code">
            <xsl:value-of select="$subfield"/>
          </xsl:with-param>
          <xsl:with-param name="value">
            <xsl:choose>
              <xsl:when test="@code">
                <xsl:value-of select="@code"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:variable name="codeFromList">
                  <xsl:choose>
                    <xsl:when test="$marcMusPerfList/marc:instr[lower-case(.)=lower-case($term)]">
                      <xsl:value-of
                        select="$marcMusPerfList/marc:instr[lower-case(.)=lower-case($term)]/@code"
                      />
                    </xsl:when>
                    <xsl:when test="$iamlMusPerfList/marc:instr[lower-case(.)=lower-case($term)]">
                      <xsl:value-of
                        select="$iamlMusPerfList/marc:instr[lower-case(.)=lower-case($term)]/@code"
                      />
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="$term"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="$codeFromList"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="@count">
                <xsl:value-of select="format-number(@count, '00')"/>
              </xsl:when>
              <xsl:when test="@solo='true'">
                <xsl:value-of select="format-number(1, '00')"/>
              </xsl:when>
              <xsl:when test="matches(., '^[0-9]+&#32;')">
                <xsl:value-of select="format-number(number(substring-before(., '&#32;')), '00')"/>
              </xsl:when>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:if test="$authority='iamlmp'">
        <xsl:call-template name="subfield">
          <xsl:with-param name="code">
            <xsl:text>2</xsl:text>
          </xsl:with-param>
          <xsl:with-param name="value">
            <text>iamlmp</text>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </datafield>
  </xsl:template>

  <xsl:template match="mei:langUsage">
    <xsl:variable name="tag" select="'041'"/>
    <datafield>
      <xsl:attribute name="tag" select="$tag"/>
      <xsl:call-template name="indicators"/>
      <xsl:for-each select="mei:language">
        <xsl:variable name="thisID">
          <xsl:value-of select="@xml:id"/>
        </xsl:variable>
        <xsl:variable name="thisTerm">
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:variable>
        <xsl:call-template name="subfield">
          <xsl:with-param name="code">h</xsl:with-param>
          <xsl:with-param name="value">
            <xsl:choose>
              <xsl:when test="$marcLangList/marc:lang[@code=lower-case($thisID)]">
                <xsl:value-of select="$marcLangList/marc:lang[@code=lower-case($thisID)]/@code"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of
                  select="$marcLangList/marc:lang[lower-case(.)=lower-case($thisTerm)]/@code"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </datafield>
  </xsl:template>

  <xsl:template match="mei:meiHead/@xml:lang">
    <xsl:variable name="tag" select="'040'"/>
    <xsl:variable name="thisLang">
      <xsl:value-of select="normalize-space(.)"/>
    </xsl:variable>
    <xsl:if test="$marcLangList/marc:lang[@code=lower-case($thisLang)]">
      <datafield>
        <xsl:attribute name="tag" select="$tag"/>
        <xsl:call-template name="indicators"/>
        <xsl:if test="not($agency_code='')">
          <xsl:call-template name="subfield">
            <xsl:with-param name="code">a</xsl:with-param>
            <xsl:with-param name="value">
              <xsl:value-of select="$agency_code"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
        <xsl:call-template name="subfield">
          <xsl:with-param name="code">b</xsl:with-param>
          <xsl:with-param name="value">
            <xsl:value-of select="$marcLangList/marc:lang[@code=lower-case($thisLang)]/@code"/>
          </xsl:with-param>
        </xsl:call-template>
      </datafield>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mei:persName">
    <xsl:variable name="tag">
      <xsl:choose>
        <xsl:when test="@analog">
          <xsl:value-of select="substring(substring-after(@analog, ':'), 1, 3)"/>
        </xsl:when>
        <xsl:when test="contains(@role, 'composer') or contains(@role, 'creator')">
          <xsl:text>100</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>700</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <datafield>
      <xsl:attribute name="tag" select="$tag"/>
      <xsl:call-template name="indicators"/>
      <xsl:choose>
        <!-- Only text; subfield |a only -->
        <xsl:when test="count(mei:*) = 0">
          <xsl:call-template name="subfield">
            <xsl:with-param name="code">a</xsl:with-param>
            <xsl:with-param name="value">
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <!-- Mixed content; split into multiple subfields -->
        <xsl:otherwise>
          <xsl:call-template name="subfield">
            <xsl:with-param name="code">a</xsl:with-param>
            <xsl:with-param name="value">
              <xsl:variable name="name">
                <xsl:value-of select="normalize-space(text())"/>
              </xsl:variable>
              <xsl:value-of select="normalize-space($name)"/>
            </xsl:with-param>
          </xsl:call-template>
          <xsl:if test="mei:date">
            <xsl:call-template name="subfield">
              <xsl:with-param name="code">d</xsl:with-param>
              <xsl:with-param name="value">
                <xsl:value-of select="mei:date"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="@dbkey">
        <xsl:call-template name="subfield">
          <xsl:with-param name="code">0</xsl:with-param>
          <xsl:with-param name="value">
            <xsl:value-of select="@dbkey"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
      <xsl:if test="ancestor::mei:respStmt/mei:resp or @role">
        <xsl:variable name="role">
          <xsl:choose>
            <xsl:when test="ancestor::mei:respStmt/mei:resp[matches(., 'encoder')]">
              <xsl:text>markup editor</xsl:text>
            </xsl:when>
            <xsl:when test="matches(@role, 'encoder')">
              <xsl:text>markup editor</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@role"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="relatorCode">
          <xsl:value-of select="$marcRelList/marc:relator[.=$role]/@code"/>
        </xsl:variable>
        <xsl:if test="not($relatorCode = '')">
          <xsl:call-template name="subfield">
            <xsl:with-param name="code">4</xsl:with-param>
            <xsl:with-param name="value">
              <xsl:value-of select="$relatorCode"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:if>
      </xsl:if>
    </datafield>
  </xsl:template>

  <xsl:template match="mei:projectDesc">
    <xsl:variable name="tag" select="'500'"/>
    <datafield>
      <xsl:attribute name="tag" select="$tag"/>
      <xsl:call-template name="indicators"/>
      <xsl:call-template name="subfield">
        <xsl:with-param name="code">a</xsl:with-param>
        <xsl:with-param name="value">
          <xsl:value-of select="concat('&quot;', normalize-space(.), '&quot;')"/>
        </xsl:with-param>
      </xsl:call-template>
    </datafield>
  </xsl:template>

  <xsl:template match="mei:samplingDecl">
    <xsl:variable name="tag" select="'500'"/>
    <datafield>
      <xsl:attribute name="tag" select="$tag"/>
      <xsl:call-template name="indicators"/>
      <xsl:call-template name="subfield">
        <xsl:with-param name="code">a</xsl:with-param>
        <xsl:with-param name="value">
          <xsl:value-of select="concat('&quot;', normalize-space(.), '&quot;')"/>
        </xsl:with-param>
      </xsl:call-template>
    </datafield>
  </xsl:template>

  <xsl:template match="mei:seriesStmt">
    <xsl:variable name="tag" select="'490'"/>
    <datafield>
      <xsl:attribute name="tag" select="$tag"/>
      <xsl:call-template name="indicators">
        <xsl:with-param name="ind1">0</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="subfield">
        <xsl:with-param name="code">a</xsl:with-param>
        <xsl:with-param name="value">
          <xsl:value-of select="mei:title"/>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:if test="mei:biblScope">
        <xsl:call-template name="subfield">
          <xsl:with-param name="code">v</xsl:with-param>
          <xsl:with-param name="value">
            <xsl:value-of select="mei:biblScope"/>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:if>
    </datafield>
  </xsl:template>

  <xsl:template match="mei:term">
    <xsl:variable name="tag" select="substring-after(@analog, ':')"/>
    <datafield>
      <xsl:attribute name="tag" select="$tag"/>
      <xsl:call-template name="indicators"/>
      <xsl:call-template name="subfield">
        <xsl:with-param name="code">a</xsl:with-param>
        <xsl:with-param name="value">
          <xsl:value-of select="normalize-space(.)"/>
        </xsl:with-param>
      </xsl:call-template>
    </datafield>
  </xsl:template>

  <xsl:template match="mei:title[@type='uniform' or @analog='marc:240']">
    <xsl:variable name="tag" select="'240'"/>
    <datafield>
      <xsl:attribute name="tag" select="$tag"/>
      <xsl:call-template name="indicators"/>
      <xsl:choose>
        <xsl:when test="mei:title[matches(@analog, 'marc:\d\d\d[a-z]')]">
          <xsl:for-each select="mei:title[matches(@analog, 'marc:\d\d\d[a-z]')]">
            <xsl:variable name="code">
              <xsl:value-of select="substring(@analog, string-length(@analog), 1)"/>
            </xsl:variable>
            <xsl:call-template name="subfield">
              <xsl:with-param name="code">
                <xsl:value-of select="$code"/>
              </xsl:with-param>
              <xsl:with-param name="value">
                <xsl:value-of select="normalize-space(.)"/>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="subfield">
            <xsl:with-param name="code">a</xsl:with-param>
            <xsl:with-param name="value">
              <xsl:value-of select="normalize-space(.)"/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </datafield>
  </xsl:template>

  <xsl:template match="mei:titleStmt">
    <xsl:variable name="tag" select="'245'"/>
    <datafield>
      <xsl:attribute name="tag" select="$tag"/>
      <xsl:call-template name="indicators"/>
      <xsl:call-template name="subfield">
        <xsl:with-param name="code">a</xsl:with-param>
        <xsl:with-param name="value">
          <xsl:choose>
            <xsl:when test="mei:title[@type='proper' or @analog='marc:245']">
              <xsl:value-of select="mei:title[@type='proper' or @analog='marc:245']"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="mei:title[not(@type='uniform' or @type='subtitle')][1]"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="subfield">
        <xsl:with-param name="code">b</xsl:with-param>
        <xsl:with-param name="value">
          <xsl:choose>
            <xsl:when test="mei:title[@type='proper' or @analog='marc:245']">
              <xsl:value-of select="mei:title[not(@type='proper' or @analog='marc:245') and
                not(@type='uniform')]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="mei:title[not(@type='uniform')][position() &gt; 1]"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </datafield>
  </xsl:template>

  <xsl:template match="mei:workDesc" mode="compositionDate">
    <!-- All dates are assumed to be C.E.! -->
    <xsl:variable name="workCreation">
      <xsl:copy-of select="mei:work/mei:history/mei:creation/mei:date"/>
    </xsl:variable>
    <xsl:if test="$workCreation/mei:date">
      <xsl:variable name="tag" select="'045'"/>
      <datafield>
        <xsl:attribute name="tag" select="$tag"/>
        <xsl:variable name="dateType">
          <xsl:choose>
            <!-- order of tests *is significant* -->
            <xsl:when test="count($workCreation/mei:date[mei:date]) &gt; 0 or
              (($workCreation/mei:date/@notbefore != $workCreation/mei:date/@notafter) or
              ($workCreation/mei:date/@notafter != $workCreation/mei:date/@notbefore))">
              <!-- date range -->
              <xsl:text>2</xsl:text>
            </xsl:when>
            <xsl:when test="count($workCreation/mei:date[not(mei:date)]) &gt; 1">
              <!-- multiple dates -->
              <xsl:text>1</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <!-- single date -->
              <xsl:text>0</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:call-template name="indicators">
          <xsl:with-param name="ind1">
            <xsl:value-of select="$dateType"/>
          </xsl:with-param>
          <xsl:with-param name="ind2" xml:space="preserve">&#32;</xsl:with-param>
        </xsl:call-template>
        <xsl:choose>
          <xsl:when test="$dateType = '2'">
            <!-- date range -->
            <xsl:call-template name="subfield">
              <xsl:with-param name="code">b</xsl:with-param>
              <xsl:with-param name="value">
                <xsl:text>d</xsl:text>
                <xsl:choose>
                  <!-- first date contains a date element with @notbefore attribute -->
                  <xsl:when test="$workCreation/mei:date[mei:date][1]/mei:date[1]/@notbefore">
                    <xsl:value-of
                      select="substring($workCreation/mei:date[mei:date][1]/mei:date[1]/@notbefore,
                      1, 4)"/>
                  </xsl:when>
                  <!-- first date contains a date element with some content -->
                  <xsl:when test="$workCreation/mei:date[mei:date][1]/mei:date[1]/text()">
                    <xsl:value-of select="$workCreation/mei:date[mei:date][1]/mei:date[1]"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <!-- first date has @notbefore attribute -->
                    <xsl:value-of select="substring($workCreation/mei:date[1]/@notbefore, 1, 4)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="subfield">
              <xsl:with-param name="code">b</xsl:with-param>
              <xsl:with-param name="value">
                <xsl:text>d</xsl:text>
                <xsl:choose>
                  <!-- first date contains multiple date elements, the last of which has @notafter attribute -->
                  <xsl:when
                    test="$workCreation/mei:date[mei:date][1]/mei:date[position()=last()]/@notafter">
                    <xsl:value-of
                      select="substring($workCreation/mei:date[mei:date][1]/mei:date[position()=last()]/@notafter,
                      1, 4)"/>
                  </xsl:when>
                  <!-- first date contains multiple date elements, the last of which has content -->
                  <xsl:when
                    test="$workCreation/mei:date[mei:date][1]/mei:date[position()=last()]/text()">
                    <xsl:value-of
                      select="$workCreation/mei:date[mei:date][1]/mei:date[position()=last()]"/>
                  </xsl:when>
                  <!-- first date has @notafter attribute -->
                  <xsl:otherwise>
                    <xsl:value-of select="substring($workCreation/mei:date[1]/@notafter, 1, 4)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
          <xsl:when test="$dateType = '1'">
            <!-- multiple dates -->
            <xsl:for-each select="$workCreation/mei:date[not(mei:date)]">
              <xsl:call-template name="subfield">
                <xsl:with-param name="code">b</xsl:with-param>
                <xsl:with-param name="value">
                  <xsl:text>d</xsl:text>
                  <xsl:choose>
                    <!-- single date element with @isodate attribute -->
                    <xsl:when test="@isodate">
                      <xsl:value-of select="substring(@isodate, 1, 4)"/>
                    </xsl:when>
                    <!-- single date element with content -->
                    <xsl:otherwise>
                      <xsl:value-of select="normalize-space(.)"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="$dateType = '0'">
            <!-- single date -->
            <xsl:call-template name="subfield">
              <xsl:with-param name="code">b</xsl:with-param>
              <xsl:with-param name="value">
                <xsl:text>d</xsl:text>
                <xsl:choose>
                  <xsl:when test="$workCreation/mei:date[not(mei:date)]/text()">
                    <xsl:value-of select="$workCreation/mei:date[not(mei:date)]"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="substring(@isodate, 1, 4)"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
            </xsl:call-template>
          </xsl:when>
        </xsl:choose>
      </datafield>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
