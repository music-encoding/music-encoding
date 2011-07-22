xquery version "1.0";
(: 
    step-15.xql
    
    step 15 of the tutorial
    
    author: Daniel Röwenstrunk
:)

declare namespace transform="http://exist-db.org/xquery/transform";
let $example := <section>
                <ending n="1">
                     <measure n="8" right="rptend" control="true">
                        <staff n="1">
                           <layer n="1">
                              <note pname="c" oct="5" dur="4"/>
                              <rest dur="4"/>
                           </layer>
                        </staff>
                     </measure>
                  </ending>
                  <ending n="2">
                     <measure n="8">
                        <staff n="1">
                           <layer n="1">
                              <note pname="c" oct="5" dur="4"/>
                              <rest dur="4"/>
                           </layer>
                        </staff>
                     </measure>
                  </ending>
               </section>
return

<div xmlns="http://www.w3.org/1999/xhtml" id="content">
    <h1>Step 15: endings</h1>
    <p>In measure 8, there are two different endings, they are encoded with ending elements.</p>
    <img src="/pix/tutorial/tutorial_step15.png" style="display: block; margin: 0px auto 10px auto;" alt="Ah, vous dirai-je Maman"/>
    {transform:transform($example, doc("/db/webapp/xml-pretty-print.xsl"), ())}
</div>