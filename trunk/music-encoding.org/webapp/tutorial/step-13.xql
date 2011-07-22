xquery version "1.0";
(: 
    step-13.xql
    
    step 13 of the tutorial
    
    author: Daniel Röwenstrunk
:)

declare namespace transform="http://exist-db.org/xquery/transform";
let $example := <measure n="2">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note pname="a" oct="5" dur="16"/>
                              <note pname="g" oct="5" dur="16"/>
                              <note pname="f" oct="5" dur="16" accid="s"/>
                              <note pname="g" oct="5" dur="16"/>
                           </beam>
                           <beam>
                              <note pname="f" oct="5" dur="16" accid.ges="s"/>
                              <note pname="g" oct="5" dur="16"/>
                              <note pname="f" oct="5" dur="16" accid.ges="s"/>
                              <note pname="g" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                  </measure>
return

<div xmlns="http://www.w3.org/1999/xhtml" id="content">
    <h1>Step 13: accidentals</h1>
    <p>To encode Variation I, we have to consider accidentals as well. They are considered as attributes for notes (f=flat, s=sharp, n=natural). It would be good practice to encode flats or sharps that are not written but define the sound of a note, as gestural accidentals (accid.ges).</p>
    <img src="/pix/tutorial/tutorial_step13.png" style="display: block; margin: 0px auto 10px auto;" alt="Ah, vous dirai-je Maman"/>
    {transform:transform($example, doc("/db/webapp/xml-pretty-print.xsl"), ())}
</div>