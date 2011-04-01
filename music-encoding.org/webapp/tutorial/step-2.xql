xquery version "1.0";
(: 
    step-2.xql
    
    second step of the tutorial
    
    author: Daniel Röwenstrunk
:)

declare namespace transform="http://exist-db.org/xquery/transform";
let $example := <note pname="c" oct="5" dur="4"/>
return

<div xmlns="http://www.w3.org/1999/xhtml" id="content">
    <h1>Step 2: a note with pitch, octave and duration</h1>
    <p>Pitch in combination with an octave and duration are elementary attributes of a note. In our example the first note of the right hand is a quarter C5 (see <a href="http://en.wikipedia.org/wiki/Scientific_pitch_notation" onclick="window.open(this.href); return false;">Wikipedia:Scientific pitch notation</a>):</p>
    <img src="/pix/tutorial/tutorial_step2.png" style="display: block; margin: 0px auto 10px auto;" alt="Ah, vous dirai-je Maman"/>
    <p>In MEI, this information is placed in attributes of the note element:</p>
    {transform:transform($example, doc("/db/webapp/xml-pretty-print.xsl"), ())}
    <p>The attribute pname takes the pitch names a to g and the oct attribute the octaves from 0 to 9. Duration in CMN (common Music Notation) can be one of the following: long, breve, 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, where 1 indicates a whole note, 2 a half, 4 a quarter and so on.</p>
</div>