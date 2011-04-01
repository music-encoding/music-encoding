xquery version "1.0";
(: 
    step-8.xql
    
    step 8 of the tutorial
    
    author: Daniel Röwenstrunk
:)

declare namespace transform="http://exist-db.org/xquery/transform";
let $example := <measure n="7">
                     <staff n="1">
                        <layer>
                           <note pname="d" oct="5" dur="4"/>
                           <beam>
                              <note pname="d" oct="5" dur="8" dots="1"/>
                              <note pname="e" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer>
                           <note pname="f" oct="3" dur="4"/>
                           <note pname="g" oct="3" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
return

<div xmlns="http://www.w3.org/1999/xhtml" id="content">
    <h1>Step 8: multiple staves</h1>
    <p>Of course, you may add the second staff for the left hand, as well. You just have to add a second staff in the measure.</p>
    <img src="/pix/tutorial/tutorial_step8.png" style="display: block; margin: 0px auto 10px auto;" alt="Ah, vous dirai-je Maman"/>
    {transform:transform($example, doc("/db/webapp/xml-pretty-print.xsl"), ())}
</div>