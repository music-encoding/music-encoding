xquery version "1.0";
(: 
    step-5.xql
    
    step 5 of the tutorial
    
    author: Daniel Röwenstrunk
:)

declare namespace transform="http://exist-db.org/xquery/transform";
let $example := <section>
                  <measure n="1">
                     <staff>
                        <layer>
                           <note pname="c" oct="4" dur="4">
                              <syl>Mor</syl>
                           </note>
                           <note pname="c" oct="4" dur="4">
                              <syl>gen</syl>
                           </note>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="2">
                     <staff>
                        <layer>
                           <note pname="g" oct="4" dur="4">
                              <syl>kommt</syl>
                           </note>
                           <note pname="g" oct="4" dur="4">
                              <syl>der</syl>
                           </note>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="3">
                     <staff>
                        <layer>
                           <note pname="a" oct="4" dur="4">
                              <syl>Weih</syl>
                           </note>
                           <note pname="a" oct="4" dur="4">
                              <syl>nachts</syl>
                           </note>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="4">
                     <staff>
                        <layer>
                           <note pname="g" oct="4" dur="2">
                              <syl>mann</syl>
                           </note>
                        </layer>
                     </staff>
                  </measure>
               </section>
               
let $example2 :=  <layer>
                   <note pname="c" oct="4" dur="4">
                      <syl wordpos="i">Mor</syl>
                   </note>
                   <note pname="c" oct="4" dur="4">
                      <syl wordpos="t">gen</syl>
                   </note>
                </layer>
return

<div xmlns="http://www.w3.org/1999/xhtml" id="content">
    <h1>Step 5: text underlay</h1>
    <p>This melody is also used in the German Christmas song "Morgen kommt der Weihnachtsmann" (in this case it might be better to put it an octave down). The text is encoded in separate syllables; each of them are elements within the note.</p>
    {transform:transform($example, doc("/db/webapp/xml-pretty-print.xsl"), ())}
    <p>Of course, if there are more syllables than one in a word, it makes sense to indicate, whether they are in the initial, middle, or terminal position. This information goes into the wordpos attribute.</p>
    {transform:transform($example2, doc("/db/webapp/xml-pretty-print.xsl"), ())}
</div>