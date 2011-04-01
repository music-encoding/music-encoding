xquery version "1.0";
(: 
    step-7.xql
    
    step 7 of the tutorial
    
    author: Daniel Röwenstrunk
:)

declare namespace transform="http://exist-db.org/xquery/transform";
let $example := <measure n="7">
                     <staff>
                        <layer>
                           <note pname="d" oct="5" dur="4"/>
                           <beam>
                              <note pname="d" oct="5" dur="8" dots="1"/>
                              <note pname="e" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                  </measure>
return

<div xmlns="http://www.w3.org/1999/xhtml" id="content">
    <h1>Step 7: beams</h1>
    <p>As an attentive reader you realized that the last step was incomplete, right? The dotted 8th note and the 16th note are beamed. Beams are realized as a kind of grouping element around the affected notes.</p>
    <img src="/pix/tutorial/tutorial_step6.png" style="display: block; margin: 0px auto 10px auto;" alt="Ah, vous dirai-je Maman"/>
    <p>And the correct encoding is:</p>
    {transform:transform($example, doc("/db/webapp/xml-pretty-print.xsl"), ())}
</div>