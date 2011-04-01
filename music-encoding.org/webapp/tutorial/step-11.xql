xquery version "1.0";
(: 
    step-11.xql
    
    step 11 of the tutorial
    
    author: Daniel Röwenstrunk
:)

declare namespace transform="http://exist-db.org/xquery/transform";
let $example := <measure n="16">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="e_16_1_1_1" pname="e" oct="5" dur="4"/>
                           <note xml:id="e_16_1_1_2" pname="d" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="e_16_2_1_1" pname="c" oct="4" dur="4"/>
                           <note xml:id="e_16_2_1_2" pname="b" oct="3" dur="4"/>
                        </layer>
                        <layer n="2">
                           <note xml:id="e_16_2_2_1" pname="g" oct="3" dur="2"/>
                        </layer>
                     </staff>
                     <slur staff="1" startid="e_16_1_1_1" endid="e_16_1_1_2"/>
                     <slur staff="2" startid="e_16_2_1_1" endid="e_16_2_1_2"/>
                  </measure>
return

<div xmlns="http://www.w3.org/1999/xhtml" id="content">
    <h1>Step 11: layers, slurs</h1>
    <p>In measure 16, because of the different rhythms, you have to distinguish in the left hand between two layers. Slurs are anchored by ids as well. You may include the layer in the semantic id of the note (after the staff-number).</p>
    <img src="/pix/tutorial/tutorial_step11.png" style="display: block; margin: 0px auto 10px auto;" alt="Ah, vous dirai-je Maman"/>
    {transform:transform($example, doc("/db/webapp/xml-pretty-print.xsl"), <parameters><param name="hideNamespace" value="true"/></parameters>)}
    <p>Slurs are related to staves in the same way as the trill in step 9. The attributes startid and endid are used here to indicate the beginning and the end of this feature, too.</p>
</div>