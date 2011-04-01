xquery version "1.0";
(: 
    step-12.xql
    
    step 12 of the tutorial
    
    author: Daniel Röwenstrunk
:)

declare namespace transform="http://exist-db.org/xquery/transform";
let $example := <score>
                <scoredef meter.count="2" meter.unit="4" meter.sym="common">
                  <staffgrp>
                     <staffdef n="1" xml:id="s1" label.full="right hand" clef.line="2"
                        clef.shape="G"/>
                     <staffdef n="2" xml:id="s2" label.full="left hand" clef.line="4" clef.shape="F"
                     />
                  </staffgrp>
               </scoredef>
               <section>
                  <measure n="1">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_1_1_1_1" pname="c" oct="5" dur="4"/>
                           <note xml:id="t_e_1_1_1_2" pname="c" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_1_2_1_1" pname="c" oct="3" dur="4"/>
                           <note xml:id="t_e_1_2_1_2" pname="c" oct="3" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="2">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_2_1_1_1" pname="g" oct="5" dur="4"/>
                           <note xml:id="t_e_2_1_1_2" pname="g" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_2_2_1_1" pname="e" oct="4" dur="4"/>
                           <note xml:id="t_e_2_2_1_2" pname="c" oct="4" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="3">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_3_1_1_1" pname="a" oct="5" dur="4"/>
                           <note xml:id="t_e_3_1_1_2" pname="a" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_3_2_1_1" pname="f" oct="4" dur="4"/>
                           <note xml:id="t_e_3_2_1_2" pname="c" oct="4" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="4">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_4_1_1_1" pname="g" oct="5" dur="4"/>
                           <note xml:id="t_e_4_1_1_2" pname="g" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_4_2_1_1" pname="e" oct="4" dur="4"/>
                           <note xml:id="t_e_4_2_1_2" pname="c" oct="4" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="5">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_5_1_1_1" pname="f" oct="5" dur="4"/>
                           <note xml:id="t_e_5_1_1_2" pname="f" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_5_2_1_1" pname="d" oct="4" dur="4"/>
                           <note xml:id="t_e_5_2_1_2" pname="b" oct="4" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="6">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_6_1_1_1" pname="e" oct="5" dur="4"/>
                           <note xml:id="t_e_6_1_1_2" pname="e" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_6_2_1_1" pname="c" oct="4" dur="4"/>
                           <note xml:id="t_e_6_2_1_2" pname="a" oct="4" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="7">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_7_1_1_1" pname="d" oct="5" dur="4"/>
                           <beam>
                              <note xml:id="t_e_7_1_1_2" pname="d" oct="5" dur="8" dots="1"/>
                              <note xml:id="t_e_7_1_1_3" pname="e" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_7_2_1_1" pname="f" oct="3" dur="4"/>
                           <note xml:id="t_e_7_2_1_2" pname="g" oct="3" dur="4"/>
                        </layer>
                     </staff>
                     <trill staff="1" startid="t_e_7_1_1_2"/>
                  </measure>
                  <measure n="8" right="rptboth">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_8_1_1_1" pname="c" oct="5" dur="2"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_8_2_1_1" pname="c" oct="3" dur="2"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="9">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_9_1_1_1" pname="g" oct="5" dur="4"/>
                           <note xml:id="t_e_9_1_1_2" pname="g" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_9_2_1_1" pname="e" oct="4" dur="4"/>
                           <note xml:id="t_e_9_2_1_2" pname="g" oct="3" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="10">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_10_1_1_1" pname="f" oct="5" dur="4"/>
                           <note xml:id="t_e_10_1_1_2" pname="f" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_10_2_1_1" pname="d" oct="4" dur="4"/>
                           <note xml:id="t_e_10_2_1_2" pname="g" oct="4" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="11">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_11_1_1_1" pname="e" oct="5" dur="4"/>
                           <note xml:id="t_e_11_1_1_2" pname="e" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_11_2_1_1" pname="c" oct="4" dur="4"/>
                           <note xml:id="t_e_11_2_1_2" pname="g" oct="3" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="12">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_12_1_1_1" pname="d" oct="5" dur="4"/>
                           <note xml:id="t_e_12_1_1_2" pname="d" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_12_2_1_1" pname="b" oct="3" dur="4"/>
                           <note xml:id="t_e_12_2_1_2" pname="g" oct="3" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="13">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_13_1_1_1" pname="g" oct="5" dur="4"/>
                           <note xml:id="t_e_13_1_1_2" pname="g" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_13_2_1_1" pname="e" oct="4" dur="4"/>
                           <note xml:id="t_e_13_2_1_2" pname="g" oct="3" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="14">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_14_1_1_1" pname="f" oct="5" dur="4"/>
                           <note xml:id="t_e_14_1_1_2" pname="f" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_14_2_1_1" pname="d" oct="4" dur="4"/>
                           <note xml:id="t_e_14_2_1_2" pname="g" oct="4" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="15">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_15_1_1_1" pname="e" oct="5" dur="4"/>
                           <beam>
                              <note xml:id="t_e_15_1_1_2" pname="e" oct="5" dur="8" dots="1"/>
                              <note xml:id="t_e_15_1_1_3" pname="f" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_15_2_1_1" pname="c" oct="4" dur="4"/>
                           <beam>
                              <note xml:id="t_e_15_2_1_2" pname="c" oct="4" dur="8" dots="1"/>
                              <note xml:id="t_e_15_2_1_3" pname="d" oct="4" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="16">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_16_1_1_1" pname="e" oct="5" dur="4"/>
                           <note xml:id="t_e_16_1_1_2" pname="d" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_16_2_1_1" pname="c" oct="4" dur="4"/>
                           <note xml:id="t_e_16_2_1_2" pname="b" oct="3" dur="4"/>
                        </layer>
                        <layer n="2">
                           <note xml:id="t_e_16_2_2_1" pname="g" oct="3" dur="2"/>
                        </layer>
                     </staff>
                     <slur staff="1" startid="t_e_16_1_1_1" endid="t_e_16_1_1_2"/>
                     <slur staff="2" startid="t_e_16_2_1_1" endid="t_e_16_2_1_2"/>
                  </measure>
                  <measure n="17">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_17_1_1_1" pname="c" oct="5" dur="4"/>
                           <note xml:id="t_e_17_1_1_2" pname="c" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_17_2_1_1" pname="c" oct="3" dur="4"/>
                           <note xml:id="t_e_17_2_1_2" pname="c" oct="3" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="18">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_18_1_1_1" pname="g" oct="5" dur="4"/>
                           <note xml:id="t_e_18_1_1_2" pname="g" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_18_2_1_1" pname="e" oct="4" dur="4"/>
                           <note xml:id="t_e_18_2_1_2" pname="c" oct="4" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="19">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_19_1_1_1" pname="a" oct="5" dur="4"/>
                           <note xml:id="t_e_19_1_1_2" pname="a" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_19_2_1_1" pname="f" oct="4" dur="4"/>
                           <note xml:id="t_e_19_2_1_2" pname="c" oct="4" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="20">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_20_1_1_1" pname="g" oct="5" dur="4"/>
                           <note xml:id="t_e_20_1_1_2" pname="g" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_20_2_1_1" pname="e" oct="4" dur="4"/>
                           <note xml:id="t_e_20_2_1_2" pname="c" oct="4" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="21">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_21_1_1_1" pname="f" oct="5" dur="4"/>
                           <note xml:id="t_e_21_1_1_2" pname="f" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_21_2_1_1" pname="d" oct="4" dur="4"/>
                           <note xml:id="t_e_21_2_1_2" pname="b" oct="4" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="22">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_22_1_1_1" pname="e" oct="5" dur="4"/>
                           <note xml:id="t_e_22_1_1_2" pname="e" oct="5" dur="4"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_22_2_1_1" pname="c" oct="4" dur="4"/>
                           <note xml:id="t_e_22_2_1_2" pname="a" oct="4" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="23">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_23_1_1_1" pname="d" oct="5" dur="4"/>
                           <beam>
                              <note xml:id="t_e_23_1_1_2" pname="d" oct="5" dur="8" dots="1"/>
                              <note xml:id="t_e_23_1_1_3" pname="e" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_23_2_1_1" pname="f" oct="3" dur="4"/>
                           <note xml:id="t_e_23_2_1_2" pname="g" oct="3" dur="4"/>
                        </layer>
                     </staff>
                     <trill staff="1" startid="t_e_23_1_1_2"/>
                  </measure>
                  <measure n="24" right="rptend">
                     <staff n="1">
                        <layer n="1">
                           <note xml:id="t_e_24_1_1_1" pname="c" oct="5" dur="2"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="t_e_24_2_1_1" pname="c" oct="3" dur="2"/>
                        </layer>
                     </staff>
                     <fermata staff="1" tstamp="3"/>
                  </measure>
               </section>
               </score>
return

<div xmlns="http://www.w3.org/1999/xhtml" id="content">
    <h1>Step 12: the whole theme</h1>
    <p>Now you can encode the whole theme. Therefore it is, of course, usefull to define the meter and the clefs as well, you do that in the scoredef and staffdef elements as follows. Fermatas (in measure 24) are anchored with ids as well or with the use of a timestamp. We chose the <span class="mono">tstamp</span> attribute here just to show this concept as well. We place the fermata with the timestamp value of 3 to the right barline.</p>
    <p>Because it is not possible to take the same id twice in one document and considering that the Neue Mozart Ausgabe renumbers every variation from the beginning, we enlarge the ids with a "t" for "theme".</p>
    <img src="/pix/tutorial/tutorial_step12.png" style="display: block; margin: 0px auto 10px auto;" alt="Ah, vous dirai-je Maman"/>
    {transform:transform($example, doc("/db/webapp/xml-pretty-print.xsl"), <parameters><param name="hideNamespace" value="true"/></parameters>)}
</div>