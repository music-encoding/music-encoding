xquery version "1.0";
(: 
    step-1.xql
    
    first step of the tutorial
    
    author: Daniel Röwenstrunk
:)

declare namespace transform="http://exist-db.org/xquery/transform";

let $example := <score>
               <section>
                  <measure>
                     <staff>
                        <layer>
                           <note/>
                        </layer>
                     </staff>
                  </measure>
               </section>
            </score>
return

<div xmlns="http://www.w3.org/1999/xhtml" id="content">
    <h1>Step 1: a note</h1>
    <p>The most basic feature in music notation is probably a note. To indicate a note, it is required to define a score with a section, a measure, a staff and a layer within the staff.</p>
    {transform:transform($example, doc("/db/webapp/xml-pretty-print.xsl"), ())}
    <p>The score element indicates the full score view of a piece (as opposed to a collection of separate parts). A section is a container for actual music data and will be used to separate the variations in our piece. The measure element contains at least one staff which again contains at least one layer. Layers are used to separately encode multiple voices occurring on a single staff.</p>
</div>