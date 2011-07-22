xquery version "1.0";
(: 
    step-6.xql
    
    step 6 of the tutorial
    
    author: Daniel Röwenstrunk
:)

declare namespace transform="http://exist-db.org/xquery/transform";
let $example := <measure n="7">
                     <staff>
                        <layer>
                           <note pname="d" oct="5" dur="4"/>
                           <note pname="d" oct="5" dur="8" dots="1"/>
                           <note pname="e" oct="5" dur="16"/>
                        </layer>
                     </staff>
                  </measure>
return

<div xmlns="http://www.w3.org/1999/xhtml" id="content">
    <h1>Step 6: dotted rhythm</h1>
    <p>Back to Mozart! In measure 7, there is a dotted rhythm.</p>
    <img src="/pix/tutorial/tutorial_step6.png" style="display: block; margin: 0px auto 10px auto;" alt="Ah, vous dirai-je Maman"/>
    <p>The number of dots can be stored in the dots attribute of a note:</p>
    {transform:transform($example, doc("/db/webapp/xml-pretty-print.xsl"), ())}
</div>