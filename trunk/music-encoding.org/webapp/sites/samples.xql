xquery version "1.0";
(: 
    samples.xql
    
    This file provides the sample encodings
    
    author: Johannes Kepper
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

let $bmExamples := <toc>
                        <div xmlns="http://www.w3.org/1999/xhtml" id="mozartK581"><a href="/documentation/tutorial/intro">Mozart: Clarinet Quintet, K. 581</a></div>
                        <div xmlns="http://www.w3.org/1999/xhtml" id="mozartK331"><a href="/documentation/tutorial/intro">Mozart: Piano Sonata in A Major, K. 331</a></div>
                        <div xmlns="http://www.w3.org/1999/xhtml" id="anonSaltarello"><a href="/documentation/tutorial/intro">Anonymous: Saltarello</a></div>
                        <div xmlns="http://www.w3.org/1999/xhtml" id="telemannAria"><a href="/documentation/tutorial/intro">Telemann: Liebe! Liebe! Was ist schöner als die Liebe?</a></div>
                        <div xmlns="http://www.w3.org/1999/xhtml" id="anonChant"><a href="/documentation/tutorial/intro">Chant: Quem queritis</a></div>
                        <div xmlns="http://www.w3.org/1999/xhtml" id="binchoisMagnificat"><a href="/documentation/tutorial/intro">Binchois: Magnificat</a></div>
                   </toc>
                   
let $otherExamples := <toc>
                        <div xmlns="http://www.w3.org/1999/xhtml" id="brahmsWaltze"><a href="/documentation/tutorial/intro">Brahms: Waltze op.39,1</a></div>
                        <div xmlns="http://www.w3.org/1999/xhtml" id="webernOp27"><a href="/documentation/tutorial/intro">Webern: Op 27, second movement</a></div>
                      </toc>

return

<div xmlns="http://www.w3.org/1999/xhtml" id="mainframe" class="oneColumn">
    
    <div id="sampleLists">
    
    <div id="allSamples" style="display: none;">
        <div id="bmSamples">
            {
                for $c in $bmExamples/div
                return
                    $c
            }
        </div>
        
        <div id="otherSamples">
            {
                for $c in $otherExamples/div
                return
                    $c
            }
        </div>
    </div>
    
    </div>
    <div id="sampleBox">
        {util:eval(xs:anyURI(concat('xmldb:exist:///db/webapp/tutorial/', $selected, '.xql')))}
    </div>
</div>
