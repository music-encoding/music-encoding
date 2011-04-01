xquery version "1.0";
(: 
    step-10.xql
    
    step 10 of the tutorial
    
    author: Daniel Röwenstrunk
:)

declare namespace transform="http://exist-db.org/xquery/transform";

let $example := <measure n="8" right="rptboth">
                     <staff n="1">
                        <layer>
                           <note xml:id="e_8_1_1" pname="c" oct="5" dur="2"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer>
                           <note xml:id="e_8_2_1" pname="c" oct="3" dur="2"/>
                        </layer>
                     </staff>
                  </measure>
return

<div xmlns="http://www.w3.org/1999/xhtml" id="content">
    <h1>Step 10: barlines, repetition sign</h1>
    <p>At the end of measure 8, we find the repetition sign, e.g. a special form of a bar line. We can indicate the function of this bar line through the use of the <span class="mono">right</span> attribute on measure:</p>
    <img src="/pix/tutorial/tutorial_step10.png" style="display: block; margin: 0px auto 10px auto;" alt="Ah, vous dirai-je Maman"/>
    {transform:transform($example, doc("/db/webapp/xml-pretty-print.xsl"), <parameters><param name="hideNamespace" value="true"/></parameters>)}
</div>