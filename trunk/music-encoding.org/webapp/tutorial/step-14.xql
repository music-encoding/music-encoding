xquery version "1.0";
(: 
    step-14.xql
    
    step 14 of the tutorial
    
    author: Daniel Röwenstrunk
:)

declare namespace transform="http://exist-db.org/xquery/transform";
let $example := <measure n="4">
                     <staff n="2">
                        <layer n="1">
                           <chord dur="4">
                              <note pname="c" oct="4"/>
                              <note pname="e" oct="4"/>
                           </chord>
                           <rest dur="8" dots="1"/>
                           <note pname="c" oct="4" dur="16" accid="s"/>
                        </layer>
                     </staff>
                  </measure>
return

<div xmlns="http://www.w3.org/1999/xhtml" id="content">
    <h1>Step 14: chords, rests</h1>
    <p>If there are simultaneous notes with the same rhythm, you can encode them as chords with a single duration. NB: rests work like notes; but, of course, you don't have to indicate a pitch or an octave.</p>
    <img src="/pix/tutorial/tutorial_step14.png" style="display: block; margin: 0px auto 10px auto;" alt="Ah, vous dirai-je Maman"/>
    {transform:transform($example, doc("/db/webapp/xml-pretty-print.xsl"), ())}
</div>