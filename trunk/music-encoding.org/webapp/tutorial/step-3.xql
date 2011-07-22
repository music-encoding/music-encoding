xquery version "1.0";
(: 
    step-3.xql
    
    step 3 of the tutorial
    
    author: Daniel Röwenstrunk
:)

declare namespace transform="http://exist-db.org/xquery/transform";

let $example := <layer>
                <note pname="c" oct="5" dur="4"/>
                <note pname="c" oct="5" dur="4"/>
	           </layer>
return

<div xmlns="http://www.w3.org/1999/xhtml" id="content">
    <h1>Step 3: sequence of notes</h1>
    <p>A layer in MEI holds a "stream of events", so this is the right place to add a second note:</p>
    {transform:transform($example, doc("/db/webapp/xml-pretty-print.xsl"), ())}
</div>