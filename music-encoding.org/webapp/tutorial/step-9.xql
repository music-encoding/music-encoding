xquery version "1.0";
(: 
    step-9.xql
    
    step 9 of the tutorial
    
    author: Daniel Röwenstrunk
:)

declare namespace transform="http://exist-db.org/xquery/transform";
let $example := <measure n="7">
                     <staff n="1">
                        <layer>
                           <note xml:id="e_7_1_1" pname="d" oct="5" dur="4"/>
                           <beam>
                              <note xml:id="e_7_1_2" pname="d" oct="5" dur="8" dots="1"/>
                              <note xml:id="e_7_1_3" pname="e" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer>
                           <note xml:id="e_7_2_1" pname="f" oct="3" dur="4"/>
                           <note xml:id="e_7_2_2" pname="g" oct="3" dur="4"/>
                        </layer>
                     </staff>
                     <trill staff="1" startid="e_7_1_2"/>
                  </measure>
                  
return

<div xmlns="http://www.w3.org/1999/xhtml" id="content">
    <h1>Step 9: IDs, trill</h1>
    <p>To anchor the trill in the right hand (see measure 7 in last step) to the second note, it is necessary to give the note a unique identifier. It is possible to assign identifiers (or ids, for short) only when necessary, but your encoding will be more elegant if you give an id to every musical event. Ids may have semantic meaning or they may not. If you choose semantic ids, it may be useful to construct them as follows: e_7_1_2 (e=event, 7=measure, 1=staff, 2= second event in the staff).</p>
    {transform:transform($example, doc("/db/webapp/xml-pretty-print.xsl"), <parameters><param name="hideNamespace" value="true"/></parameters>)}
    <p>The trill itself is represented by the trill element and is associated with a staff (in this case the first). There are also some more attributes (startid, endid and others) to specify the relation of the trill to one or more events within the staff.</p>
</div>