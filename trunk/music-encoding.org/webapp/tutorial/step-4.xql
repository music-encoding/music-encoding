xquery version "1.0";
(: 
    step-4.xql
    
    step 4 of the tutorial
    
    author: Daniel Röwenstrunk
:)

declare namespace transform="http://exist-db.org/xquery/transform";
let $example := <section>
                <measure n="1">
	               <staff>
                  <layer>
                     <note pname="c" oct="5" dur="4"/>
                     <note pname="c" oct="5" dur="4"/>
                  </layer>
               </staff>
        	</measure>
        	<measure n="2">
        	   <staff>
                  <layer>
                     <note pname="g" oct="5" dur="4"/>
                     <note pname="g" oct="5" dur="4"/>
                  </layer>
               </staff>
	       </measure>
	       </section>
return

<div xmlns="http://www.w3.org/1999/xhtml" id="content">
    <h1>Step 4: measures</h1>
    <p>Now we are able to encode a simple melody, but there should be more than just one measure (by the way: you can count the measures).</p>
    <img src="/pix/tutorial/tutorial_step4.png" style="display: block; margin: 0px auto 10px auto;" alt="Ah, vous dirai-je Maman"/>
    {transform:transform($example, doc("/db/webapp/xml-pretty-print.xsl"), ())}
    <p>Names or numbers always find their place in the attribute called "n", where we have placed our counting.</p>
</div>