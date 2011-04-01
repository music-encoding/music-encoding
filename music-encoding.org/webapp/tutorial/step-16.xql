xquery version "1.0";
(: 
    step-16.xql
    
    step 16 of the tutorial
    
    author: Daniel Röwenstrunk
:)

declare namespace transform="http://exist-db.org/xquery/transform";
let $example := <section>
                  <measure n="1">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_1_1_1_1" pname="d" oct="5" dur="16"/>
                              <note xml:id="v1_e_1_1_1_2" pname="c" oct="5" dur="16"/>
                              <note xml:id="v1_e_1_1_1_3" pname="b" oct="4" dur="16"/>
                              <note xml:id="v1_e_1_1_1_4" pname="c" oct="5" dur="16"/>
                           </beam>
                           <beam>
                              <note xml:id="v1_e_1_1_1_5" pname="b" oct="4" dur="16"/>
                              <note xml:id="v1_e_1_1_1_6" pname="c" oct="5" dur="16"/>
                              <note xml:id="v1_e_1_1_1_7" pname="b" oct="4" dur="16"/>
                              <note xml:id="v1_e_1_1_1_8" pname="c" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="v1_e_1_2_1_1" pname="c" oct="3" dur="4"/>
                           <note xml:id="v1_e_1_2_1_2" pname="c" oct="4" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="2">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_2_1_1_1" pname="a" oct="5" dur="16"/>
                              <note xml:id="v1_e_2_1_1_2" pname="g" oct="5" dur="16"/>
                              <note xml:id="v1_e_2_1_1_3" pname="f" oct="5" dur="16" accid="s"/>
                              <note xml:id="v1_e_2_1_1_4" pname="g" oct="5" dur="16"/>
                           </beam>
                           <beam>
                              <note xml:id="v1_e_2_1_1_5" pname="f" oct="5" dur="16" accid.ges="s"/>
                              <note xml:id="v1_e_2_1_1_6" pname="g" oct="5" dur="16"/>
                              <note xml:id="v1_e_2_1_1_7" pname="f" oct="5" dur="16" accid.ges="s"/>
                              <note xml:id="v1_e_2_1_1_8" pname="g" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="v1_e_2_2_1_1" pname="e" oct="4" dur="4"/>
                           <note xml:id="v1_e_2_2_1_2" pname="c" oct="4" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="3">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_3_1_1_1" pname="g" oct="5" dur="16" accid="s"/>
                              <note xml:id="v1_e_3_1_1_2" pname="a" oct="5" dur="16"/>
                              <note xml:id="v1_e_3_1_1_3" pname="c" oct="6" dur="16"/>
                              <note xml:id="v1_e_3_1_1_4" pname="b" oct="5" dur="16"/>
                           </beam>
                           <beam>
                              <note xml:id="v1_e_3_1_1_5" pname="d" oct="6" dur="16"/>
                              <note xml:id="v1_e_3_1_1_6" pname="c" oct="6" dur="16"/>
                              <note xml:id="v1_e_3_1_1_7" pname="b" oct="5" dur="16"/>
                              <note xml:id="v1_e_3_1_1_8" pname="a" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="v1_e_3_2_1_1" pname="f" oct="4" dur="4"/>
                           <note xml:id="v1_e_3_2_1_2" pname="c" oct="4" dur="4"/>
                        </layer>
                     </staff>
                     <slur staff="2" startid="v1_e_1_2_1_2" endid="v1_e_3_2_1_2"/>
                  </measure>
                  <measure n="4">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_4_1_1_1" pname="a" oct="5" dur="16"/>
                              <note xml:id="v1_e_4_1_1_2" pname="g" oct="5" dur="16" accid="n"/>
                              <note xml:id="v1_e_4_1_1_3" pname="e" oct="6" dur="16"/>
                              <note xml:id="v1_e_4_1_1_4" pname="d" oct="6" dur="16"/>
                           </beam>
                           <beam>
                              <note xml:id="v1_e_4_1_1_5" pname="c" oct="6" dur="16"/>
                              <note xml:id="v1_e_4_1_1_6" pname="b" oct="5" dur="16"/>
                              <note xml:id="v1_e_4_1_1_7" pname="a" oct="5" dur="16"/>
                              <note xml:id="v1_e_4_1_1_8" pname="g" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <chord xml:id="v1_e_4_2_1_1" dur="4">
                              <note pname="c" oct="4"/>
                              <note pname="c" oct="4"/>
                           </chord>
                           <rest xml:id="v1_e_4_2_1_2" dur="8" dots="1"/>
                           <note xml:id="v1_e_4_2_1_3" pname="c" oct="4" dur="16" accid="s"/>
                        </layer>
                     </staff>
                     <slur staff="1" startid="v1_e_4_1_1_1" endid="v1_e_4_1_1_2"/>
                  </measure>
                  <measure n="5">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_5_1_1_1" pname="g" oct="5" dur="16"/>
                              <note xml:id="v1_e_5_1_1_2" pname="f" oct="5" dur="16"/>
                              <note xml:id="v1_e_5_1_1_3" pname="d" oct="6" dur="16"/>
                              <note xml:id="v1_e_5_1_1_4" pname="c" oct="6" dur="16"/>
                           </beam>
                           <beam>
                              <note xml:id="v1_e_5_1_1_5" pname="b" oct="5" dur="16"/>
                              <note xml:id="v1_e_5_1_1_6" pname="a" oct="5" dur="16"/>
                              <note xml:id="v1_e_5_1_1_7" pname="g" oct="5" dur="16"/>
                              <note xml:id="v1_e_5_1_1_8" pname="f" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="v1_e_5_2_1_1" pname="d" oct="4" dur="4"/>
                           <rest xml:id="v1_e_5_2_1_2" dur="8" dots="1"/>
                           <note xml:id="v1_e_5_2_1_3" pname="b" oct="3" dur="16"/>
                        </layer>
                     </staff>
                     <slur staff="1" startid="v1_e_5_1_1_1" endid="v1_e_5_1_1_2"/>
                  </measure>
                  <measure n="6">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_6_1_1_1" pname="f" oct="5" dur="16"/>
                              <note xml:id="v1_e_6_1_1_2" pname="e" oct="5" dur="16"/>
                              <note xml:id="v1_e_6_1_1_3" pname="c" oct="6" dur="16"/>
                              <note xml:id="v1_e_6_1_1_4" pname="b" oct="5" dur="16"/>
                           </beam>
                           <beam>
                              <note xml:id="v1_e_6_1_1_5" pname="a" oct="5" dur="16"/>
                              <note xml:id="v1_e_6_1_1_6" pname="g" oct="5" dur="16"/>
                              <note xml:id="v1_e_6_1_1_7" pname="f" oct="5" dur="16"/>
                              <note xml:id="v1_e_6_1_1_8" pname="e" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="v1_e_6_2_1_1" pname="c" oct="4" dur="4" accid="n"/>
                           <rest xml:id="v1_e_6_2_1_2" dur="8" dots="1"/>
                           <note xml:id="v1_e_6_2_1_3" pname="a" oct="3" dur="16"/>
                        </layer>
                     </staff>
                     <slur staff="1" startid="v1_e_6_1_1_1" endid="v1_e_6_1_1_2"/>
                  </measure>
                  <measure n="7">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_7_1_1_1" pname="d" oct="5" dur="8"/>
                              <note xml:id="v1_e_7_1_1_2" pname="a" oct="5" dur="8"/>
                              <note xml:id="v1_e_7_1_1_3" pname="g" oct="5" dur="8"/>
                              <note xml:id="v1_e_7_1_1_4" pname="b" oct="4" dur="8"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="v1_e_7_2_1_1" pname="f" oct="3" dur="4"/>
                           <note xml:id="v1_e_7_2_1_2" pname="g" oct="3" dur="4"/>
                        </layer>
                     </staff>
                     <slur staff="1" startid="v1_e_7_1_1_2" endid="v1_e_7_1_1_3"/>
                  </measure>
                  <ending n="1">
                     <measure n="8" right="rptend" control="true">
                        <staff n="1">
                           <layer n="1">
                              <note xml:id="v1_e_8_1_1_1" pname="c" oct="5" dur="4"/>
                              <rest xml:id="v1_e_8_1_1_2" dur="4"/>
                           </layer>
                        </staff>
                        <staff n="2">
                           <layer n="1">
                              <beam>
                                 <note xml:id="v1_e_8_2_1_1" pname="c" oct="4" dur="8"/>
                                 <note xml:id="v1_e_8_2_1_2" pname="g" oct="3" dur="8"/>
                                 <note xml:id="v1_e_8_2_1_3" pname="e" oct="3" dur="8"/>
                                 <note xml:id="v1_e_8_2_1_4" pname="g" oct="3" dur="8"/>
                              </beam>
                           </layer>
                        </staff>
                     </measure>
                  </ending>
                  <ending n="2">
                     <measure n="8">
                        <staff n="1">
                           <layer n="1">
                              <note xml:id="v1_e_8_1_1_3" pname="c" oct="5" dur="4"/>
                              <rest xml:id="v1_e_8_1_1_4" dur="4"/>
                           </layer>
                        </staff>
                        <staff n="2">
                           <layer n="1">
                              <note xml:id="v1_e_8_2_1_5" pname="c" oct="4" dur="4"/>
                              <note xml:id="v1_e_8_2_1_6" pname="c" oct="3" dur="4"/>
                           </layer>
                        </staff>
                     </measure>
                  </ending>
                  <measure n="9" left="rptstart" control="true">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_9_1_1_1" pname="a" oct="5" dur="16"/>
                              <note xml:id="v1_e_9_1_1_2" pname="g" oct="5" dur="16"/>
                              <note xml:id="v1_e_9_1_1_3" pname="f" oct="5" dur="16" accid="s"/>
                              <note xml:id="v1_e_9_1_1_4" pname="g" oct="5" dur="16"/>
                           </beam>
                           <beam>
                              <note xml:id="v1_e_9_1_1_5" pname="f" oct="5" dur="16" accid.ges="s"/>
                              <note xml:id="v1_e_9_1_1_6" pname="g" oct="5" dur="16"/>
                              <note xml:id="v1_e_9_1_1_7" pname="a" oct="5" dur="16"/>
                              <note xml:id="v1_e_9_1_1_8" pname="g" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="v1_e_9_2_1_1" pname="e" oct="4" dur="4"/>
                           <note xml:id="v1_e_9_2_1_2" pname="g" oct="3" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="10">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_10_1_1_1" pname="g" oct="5" dur="16"/>
                              <note xml:id="v1_e_10_1_1_2" pname="f" oct="5" dur="16" accid="n"/>
                              <note xml:id="v1_e_10_1_1_3" pname="e" oct="5" dur="16"/>
                              <note xml:id="v1_e_10_1_1_4" pname="f" oct="5" dur="16"/>
                           </beam>
                           <beam>
                              <note xml:id="v1_e_10_1_1_5" pname="e" oct="5" dur="16"/>
                              <note xml:id="v1_e_10_1_1_6" pname="f" oct="5" dur="16"/>
                              <note xml:id="v1_e_10_1_1_7" pname="g" oct="5" dur="16"/>
                              <note xml:id="v1_e_10_1_1_8" pname="f" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="v1_e_10_2_1_1" pname="d" oct="4" dur="4"/>
                           <note xml:id="v1_e_10_2_1_2" pname="g" oct="3" dur="4"/>
                        </layer>
                     </staff>
                     <slur staff="2" startid="v1_e_9_2_1_1" endid="v1_e_10_2_1_2"/>
                  </measure>
                  <measure n="11">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_11_1_1_1" pname="f" oct="5" dur="16"/>
                              <note xml:id="v1_e_11_1_1_2" pname="e" oct="5" dur="16"/>
                              <note xml:id="v1_e_11_1_1_3" pname="d" oct="5" dur="16" accid="s"/>
                              <note xml:id="v1_e_11_1_1_4" pname="e" oct="5" dur="16"/>
                           </beam>
                           <beam>
                              <note xml:id="v1_e_11_1_1_5" pname="d" oct="5" dur="16" accid.ges="s"/>
                              <note xml:id="v1_e_11_1_1_6" pname="e" oct="5" dur="16"/>
                              <note xml:id="v1_e_11_1_1_7" pname="f" oct="5" dur="16"/>
                              <note xml:id="v1_e_11_1_1_8" pname="e" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="v1_e_11_2_1_1" pname="c" oct="4" dur="4"/>
                           <note xml:id="v1_e_11_2_1_2" pname="g" oct="3" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="12">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_12_1_1_1" pname="e" oct="5" dur="16"/>
                              <note xml:id="v1_e_12_1_1_2" pname="d" oct="5" dur="16" accid="n"/>
                              <note xml:id="v1_e_12_1_1_3" pname="c" oct="5" dur="16" accid="s"/>
                              <note xml:id="v1_e_12_1_1_4" pname="d" oct="5" dur="16"/>
                           </beam>
                           <beam>
                              <note xml:id="v1_e_12_1_1_5" pname="c" oct="5" dur="16" accid.ges="s"/>
                              <note xml:id="v1_e_12_1_1_6" pname="d" oct="5" dur="16"/>
                              <note xml:id="v1_e_12_1_1_7" pname="e" oct="5" dur="16"/>
                              <note xml:id="v1_e_12_1_1_8" pname="d" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_12_2_1_1" pname="f" oct="4" dur="4"/>
                              <note xml:id="v1_e_12_2_1_2" pname="g" oct="3" dur="4"/>
                           </beam>
                        </layer>
                     </staff>
                     <slur staff="2" startid="v1_e_11_2_1_1" endid="v1_e_12_2_1_2"/>
                  </measure>
                  <measure n="13">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_13_1_1_1" pname="a" oct="5" dur="16"/>
                              <note xml:id="v1_e_13_1_1_2" pname="g" oct="5" dur="16"/>
                              <note xml:id="v1_e_13_1_1_3" pname="f" oct="5" dur="16" accid="s"/>
                              <note xml:id="v1_e_13_1_1_4" pname="g" oct="5" dur="16"/>
                           </beam>
                           <beam>
                              <note xml:id="v1_e_13_1_1_5" pname="e" oct="6" dur="16"/>
                              <note xml:id="v1_e_13_1_1_6" pname="c" oct="6" dur="16"/>
                              <note xml:id="v1_e_13_1_1_7" pname="a" oct="5" dur="16"/>
                              <note xml:id="v1_e_13_1_1_8" pname="g" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <chord xml:id="v1_e_13_2_1_1" dur="2">
                              <note pname="g" oct="3"/>
                              <note pname="e" oct="4"/>
                           </chord>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="14">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_14_1_1_1" pname="g" oct="5" dur="16"/>
                              <note xml:id="v1_e_14_1_1_2" pname="f" oct="5" dur="16" accid="n"/>
                              <note xml:id="v1_e_14_1_1_3" pname="e" oct="5" dur="16"/>
                              <note xml:id="v1_e_14_1_1_4" pname="f" oct="5" dur="16"/>
                           </beam>
                           <beam>
                              <note xml:id="v1_e_14_1_1_5" pname="d" oct="6" dur="16"/>
                              <note xml:id="v1_e_14_1_1_6" pname="b" oct="5" dur="16"/>
                              <note xml:id="v1_e_14_1_1_7" pname="g" oct="5" dur="16"/>
                              <note xml:id="v1_e_14_1_1_8" pname="f" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <chord xml:id="v1_e_14_2_1_1" dur="2">
                              <note pname="g" oct="3"/>
                              <note pname="d" oct="4"/>
                           </chord>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="15">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_15_1_1_1" pname="f" oct="5" dur="16"/>
                              <note xml:id="v1_e_15_1_1_2" pname="e" oct="5" dur="16"/>
                              <note xml:id="v1_e_15_1_1_3" pname="d" oct="5" dur="16" accid="s"/>
                              <note xml:id="v1_e_15_1_1_4" pname="e" oct="5" dur="16"/>
                           </beam>
                           <beam>
                              <note xml:id="v1_e_15_1_1_5" pname="c" oct="6" dur="16"/>
                              <note xml:id="v1_e_15_1_1_6" pname="g" oct="5" dur="16"/>
                              <note xml:id="v1_e_15_1_1_7" pname="f" oct="5" dur="16"/>
                              <note xml:id="v1_e_15_1_1_8" pname="e" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <chord xml:id="v1_e_15_2_1_1" dur="4">
                              <note pname="g" oct="3"/>
                              <note pname="c" oct="4"/>
                           </chord>
                           <rest xml:id="v1_e_15_2_1_2" dur="8" dots="1"/>
                           <note xml:id="v1_e_15_2_1_3" pname="c" oct="4" dur="16"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="16">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_16_1_1_1" pname="g" oct="5" dur="8" dots="1"/>
                              <note xml:id="v1_e_16_1_1_2" pname="e" oct="5" dur="16"/>
                           </beam>
                           <note xml:id="v1_e_16_1_1_3" pname="d" oct="5" dur="4" accid="n"/>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_16_2_1_1" pname="e" oct="4" dur="8" dots="1"/>
                              <note xml:id="v1_e_16_2_1_2" pname="c" oct="4" dur="16"/>
                           </beam>
                           <note xml:id="v1_e_16_2_1_3" pname="b" oct="3" dur="4"/>
                        </layer>
                        <layer n="2">
                           <note xml:id="v1_e_16_2_2_1" pname="g" oct="3" dur="2"/>
                        </layer>
                     </staff>
                     <slur staff="1" startid="v1_e_16_1_1_1" endid="v1_e_16_1_1_3"/>
                     <slur staff="2" startid="v1_e_16_2_1_1" endid="v1_e_16_2_1_3"/>
                  </measure>
                  <measure n="17">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_17_1_1_1" pname="d" oct="5" dur="16"/>
                              <note xml:id="v1_e_17_1_1_2" pname="c" oct="5" dur="16"/>
                              <note xml:id="v1_e_17_1_1_3" pname="b" oct="4" dur="16"/>
                              <note xml:id="v1_e_17_1_1_4" pname="c" oct="5" dur="16"/>
                           </beam>
                           <beam>
                              <note xml:id="v1_e_17_1_1_5" pname="b" oct="4" dur="16"/>
                              <note xml:id="v1_e_17_1_1_6" pname="c" oct="5" dur="16"/>
                              <note xml:id="v1_e_17_1_1_7" pname="b" oct="4" dur="16"/>
                              <note xml:id="v1_e_17_1_1_8" pname="c" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="v1_e_17_2_1_1" pname="c" oct="3" dur="4"/>
                           <note xml:id="v1_e_17_2_1_2" pname="c" oct="4" dur="4"/>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="18">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_18_1_1_1" pname="a" oct="5" dur="16"/>
                              <note xml:id="v1_e_18_1_1_2" pname="g" oct="5" dur="16"/>
                              <note xml:id="v1_e_18_1_1_3" pname="f" oct="5" dur="16" accid="s"/>
                              <note xml:id="v1_e_18_1_1_4" pname="g" oct="5" dur="16"/>
                           </beam>
                           <beam>
                              <note xml:id="v1_e_18_1_1_5" pname="f" oct="5" dur="16" accid.ges="s"/>
                              <note xml:id="v1_e_18_1_1_6" pname="g" oct="5" dur="16"></note>
                              <note xml:id="v1_e_18_1_1_7" pname="f" oct="5" dur="16"></note>
                              <note xml:id="v1_e_18_1_1_8" pname="g" oct="5" dur="16"></note>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="v1_e_18_2_1_1" pname="e" oct="4" dur="4"></note>
                           <note xml:id="v1_e_18_2_1_2" pname="c" oct="4" dur="4"></note>
                        </layer>
                     </staff>
                  </measure>
                  <measure n="19">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_19_1_1_1" pname="g" oct="5" dur="16" accid="s"></note>
                              <note xml:id="v1_e_19_1_1_2" pname="a" oct="5" dur="16"></note>
                              <note xml:id="v1_e_19_1_1_3" pname="c" oct="6" dur="16"></note>
                              <note xml:id="v1_e_19_1_1_4" pname="b" oct="5" dur="16"></note>
                           </beam>
                           <beam>
                              <note xml:id="v1_e_19_1_1_5" pname="d" oct="6" dur="16"></note>
                              <note xml:id="v1_e_19_1_1_6" pname="c" oct="6" dur="16"></note>
                              <note xml:id="v1_e_19_1_1_7" pname="b" oct="5" dur="16"></note>
                              <note xml:id="v1_e_19_1_1_8" pname="a" oct="5" dur="16"></note>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="v1_e_19_2_1_1" pname="f" oct="4" dur="4"></note>
                           <note xml:id="v1_e_19_2_1_2" pname="c" oct="4" dur="4"></note>
                        </layer>
                     </staff>
                     <slur staff="2" startid="v1_e_17_2_1_2" endid="v1_e_19_2_1_2"/>
                  </measure>
                  <measure n="20">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_20_1_1_1" pname="a" oct="5" dur="16"/>
                              <note xml:id="v1_e_20_1_1_2" pname="g" oct="5" dur="16" accid="n"/>
                              <note xml:id="v1_e_20_1_1_3" pname="e" oct="6" dur="16"/>
                              <note xml:id="v1_e_20_1_1_4" pname="d" oct="6" dur="16"/>
                           </beam>
                           <beam>
                              <note xml:id="v1_e_20_1_1_5" pname="c" oct="6" dur="16"/>
                              <note xml:id="v1_e_20_1_1_6" pname="b" oct="5" dur="16"/>
                              <note xml:id="v1_e_20_1_1_7" pname="a" oct="5" dur="16"/>
                              <note xml:id="v1_e_20_1_1_8" pname="g" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <chord xml:id="v1_e_20_2_1_1" dur="4">
                              <note pname="c" oct="4"/>
                              <note pname="c" oct="4"/>
                           </chord>
                           <rest xml:id="v1_e_20_2_1_2" dur="8" dots="1"/>
                           <note xml:id="v1_e_20_2_1_3" pname="c" oct="4" dur="16" accid="s"/>
                        </layer>
                     </staff>
                     <slur staff="1" startid="v1_e_20_1_1_1" endid="v1_e_20_1_1_2"/>
                  </measure>
                  <measure n="21">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_21_1_1_1" pname="g" oct="5" dur="16"/>
                              <note xml:id="v1_e_21_1_1_2" pname="f" oct="5" dur="16"/>
                              <note xml:id="v1_e_21_1_1_3" pname="d" oct="6" dur="16"/>
                              <note xml:id="v1_e_21_1_1_4" pname="c" oct="6" dur="16"/>
                           </beam>
                           <beam>
                              <note xml:id="v1_e_21_1_1_5" pname="b" oct="5" dur="16"/>
                              <note xml:id="v1_e_21_1_1_6" pname="a" oct="5" dur="16"/>
                              <note xml:id="v1_e_21_1_1_7" pname="g" oct="5" dur="16"/>
                              <note xml:id="v1_e_21_1_1_8" pname="f" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="v1_e_21_2_1_1" pname="d" oct="4" dur="4"/>
                           <rest xml:id="v1_e_21_2_1_2" dur="8" dots="1"/>
                           <note xml:id="v1_e_21_2_1_3" pname="b" oct="3" dur="16"/>
                        </layer>
                     </staff>
                     <slur staff="1" startid="v1_e_21_1_1_1" endid="v1_e_21_1_1_2"/>
                  </measure>
                  <measure n="22">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_22_1_1_1" pname="f" oct="5" dur="16"/>
                              <note xml:id="v1_e_22_1_1_2" pname="e" oct="5" dur="16"/>
                              <note xml:id="v1_e_22_1_1_3" pname="c" oct="6" dur="16"/>
                              <note xml:id="v1_e_22_1_1_4" pname="b" oct="5" dur="16"/>
                           </beam>
                           <beam>
                              <note xml:id="v1_e_22_1_1_5" pname="a" oct="5" dur="16"/>
                              <note xml:id="v1_e_22_1_1_6" pname="g" oct="5" dur="16"/>
                              <note xml:id="v1_e_22_1_1_7" pname="f" oct="5" dur="16"/>
                              <note xml:id="v1_e_22_1_1_8" pname="e" oct="5" dur="16"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="v1_e_22_2_1_1" pname="c" oct="4" dur="4" accid="n"/>
                           <rest xml:id="v1_e_22_2_1_2" dur="8" dots="1"/>
                           <note xml:id="v1_e_22_2_1_3" pname="a" oct="3" dur="16"/>
                        </layer>
                     </staff>
                     <slur staff="1" startid="v1_e_22_1_1_1" endid="v1_e_22_1_1_2"/>
                  </measure>
                  <measure n="23">
                     <staff n="1">
                        <layer n="1">
                           <beam>
                              <note xml:id="v1_e_23_1_1_1" pname="d" oct="5" dur="8"/>
                              <note xml:id="v1_e_23_1_1_2" pname="a" oct="5" dur="8"/>
                              <note xml:id="v1_e_23_1_1_3" pname="g" oct="5" dur="8"/>
                              <note xml:id="v1_e_23_1_1_4" pname="b" oct="4" dur="8"/>
                           </beam>
                        </layer>
                     </staff>
                     <staff n="2">
                        <layer n="1">
                           <note xml:id="v1_e_23_2_1_1" pname="f" oct="3" dur="4"/>
                           <note xml:id="v1_e_23_2_1_2" pname="g" oct="3" dur="4"/>
                        </layer>
                     </staff>
                     <slur staff="1" startid="v1_e_23_1_1_2" endid="v1_e_23_1_1_3"/>
                  </measure>
                  
                     <measure n="24" right="rptend" control="true">
                        <staff n="1">
                           <layer n="1">
                              <note xml:id="v1_e_24_1_1_3" pname="c" oct="5" dur="4"/>
                              <rest xml:id="v1_e_24_1_1_4" dur="4"/>
                           </layer>
                        </staff>
                        <staff n="2">
                           <layer n="1">
                              <note xml:id="v1_e_24_2_1_5" pname="c" oct="4" dur="4"/>
                              <note xml:id="v1_e_24_2_1_6" pname="c" oct="3" dur="4"/>
                           </layer>
                        </staff>
                        <fermata staff="1" tstamp="3"/>
                     </measure>
               </section>
return

<div xmlns="http://www.w3.org/1999/xhtml" id="content">
    <h1>Step 16: variation I</h1>
    <p>Now you can encode the entire variation I. To distinguish the notes from those in the theme, their ids begin always with v1. NB: Slurs can include notes in a single bar as well as notes of several bars.</p>
    <img src="/pix/tutorial/tutorial_step16.png" style="display: block; margin: 0px auto 10px auto;" alt="Ah, vous dirai-je Maman"/>
    {transform:transform($example, doc("/db/webapp/xml-pretty-print.xsl"), <parameters><param name="hideNamespace" value="true"/></parameters>)}
</div>