xquery version "1.0";
(: 
    tutorial.xql
    
    This file provides the tutorial
    
    author: Daniel Röwenstrunk
:)

declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare function local:getNextTitle($item) {
    if(exists($item/following-sibling::xhtml:div))
    then($item/following-sibling::xhtml:div[1]/xhtml:a/text())
    else()
};

declare function local:getPrevTitle($item) {
    if(exists($item/preceding-sibling::xhtml:div))
    then($item/preceding-sibling::xhtml:div[1]/xhtml:a/text())
    else()
};

declare function local:getLinkNext($item) {
    if(exists($item/following-sibling::xhtml:div))
    then(concat("location.href='/documentation/tutorial/", $item/following-sibling::xhtml:div[1]/data(@id), "'"))
    else()
};

declare function local:getLinkPrev($item) {
    if(exists($item/preceding-sibling::xhtml:div))
    then(concat("location.href='/documentation/tutorial/", $item/preceding-sibling::xhtml:div[1]/data(@id), "'"))
    else()
};

let $selected := request:get-parameter('step', 'intro')

let $toc := <toc>
                <div xmlns="http://www.w3.org/1999/xhtml" id="intro"><a href="/documentation/tutorial/intro">Introduction</a></div>
                <!--<div xmlns="http://www.w3.org/1999/xhtml" id="toc"><a href="/documentation/tutorial/toc">Overview</a></div>-->
                <div xmlns="http://www.w3.org/1999/xhtml" id="step-1"><a href="/documentation/tutorial/step-1">Step 1: a note</a></div>
                <div xmlns="http://www.w3.org/1999/xhtml" id="step-2"><a href="/documentation/tutorial/step-2">Step 2: a note with pitch, octave and duration</a></div>
                <div xmlns="http://www.w3.org/1999/xhtml" id="step-3"><a href="/documentation/tutorial/step-3">Step 3: sequence of notes</a></div>
                <div xmlns="http://www.w3.org/1999/xhtml" id="step-4"><a href="/documentation/tutorial/step-4">Step 4: measures</a></div>
                <div xmlns="http://www.w3.org/1999/xhtml" id="step-5"><a href="/documentation/tutorial/step-5">Step 5: text underlay</a></div>
                <div xmlns="http://www.w3.org/1999/xhtml" id="step-6"><a href="/documentation/tutorial/step-6">Step 6: dotted rhythm</a></div>
                <div xmlns="http://www.w3.org/1999/xhtml" id="step-7"><a href="/documentation/tutorial/step-7">Step 7: beams</a></div>
                <div xmlns="http://www.w3.org/1999/xhtml" id="step-8"><a href="/documentation/tutorial/step-8">Step 8: multiple staves</a></div>
                <div xmlns="http://www.w3.org/1999/xhtml" id="step-9"><a href="/documentation/tutorial/step-9">Step 9: IDs, trill</a></div>
                <div xmlns="http://www.w3.org/1999/xhtml" id="step-10"><a href="/documentation/tutorial/step-10">Step 10: barlines, repetition sign</a></div>
                <div xmlns="http://www.w3.org/1999/xhtml" id="step-11"><a href="/documentation/tutorial/step-11">Step 11: layers, slurs</a></div>
                <div xmlns="http://www.w3.org/1999/xhtml" id="step-12"><a href="/documentation/tutorial/step-12">Step 12: the whole theme</a></div>
                <div xmlns="http://www.w3.org/1999/xhtml" id="step-13"><a href="/documentation/tutorial/step-13">Step 13: accidentals</a></div>
                <div xmlns="http://www.w3.org/1999/xhtml" id="step-14"><a href="/documentation/tutorial/step-14">Step 14: chords, rests</a></div>
                <div xmlns="http://www.w3.org/1999/xhtml" id="step-15"><a href="/documentation/tutorial/step-15">Step 15: endings</a></div>
                <div xmlns="http://www.w3.org/1999/xhtml" id="step-16"><a href="/documentation/tutorial/step-16">Step 16: variation I</a></div>
            </toc>

return

<div xmlns="http://www.w3.org/1999/xhtml" id="mainframe" class="oneColumn">
    <div id="smallToC">
        <div id="stepRewind" 
            class="{if(exists($toc/xhtml:div[@id = $selected]/preceding-sibling::xhtml:div)) then() else(string('inactive'))}" 
            title="{local:getPrevTitle($toc/xhtml:div[@id = $selected])}"
            onclick="{local:getLinkPrev($toc/xhtml:div[@id = $selected])}"/>
            
        <div id="breadcrumb">
            <span class="step">
                <a href="/documentation/tutorial">Tutorial</a>
            </span>
        </div>
        <div id="currentPage">{$toc/xhtml:div[./@id = $selected]/xhtml:a/text()}</div>
        <div id="openFullToC">
            <a id="openFullToCText" href="javascript:openSteppedContentToC();">Open Table of Contents</a>
        </div>
        
        <div id="stepForward" 
            class="{if(exists($toc/xhtml:div[@id = $selected]/following-sibling::div)) then() else(string('inactive'))}" 
            title="{local:getNextTitle($toc/xhtml:div[@id = $selected])}"
            onclick="{local:getLinkNext($toc/xhtml:div[@id = $selected])}"/>
            
    </div>
    <div id="fullToC" style="display: none;">
        <div>
            {
                for $c in $toc/div
                return
                    $c
            }
        </div>
    </div>
    <div id="steppedContent">
        {util:eval(xs:anyURI(concat('xmldb:exist:///db/webapp/tutorial/', $selected, '.xql')))}
    </div>
</div>
