<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:json="http://www.w3.org/2005/xpath-functions"
    xmlns:search="temp.search"
    exclude-result-prefixes="xs math xd tei json search"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jul 10, 2021</xd:p>
            <xd:p><xd:b>Author:</xd:b> Johannes Kepper</xd:p>
            <xd:p>This XSLT generates the search index for use with fuse.js. It prepares an index for
                the MEI Guidelines and Specs.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:function name="search:getIndex" as="node()">
        <xsl:variable name="elements" as="element(json:map)*">
            <xsl:for-each select="$mei.source//tei:elementSpec">
                <xsl:variable name="current.element" select="." as="element(tei:elementSpec)"/>
                <map xmlns="http://www.w3.org/2005/xpath-functions">
                    <string key="ident"><xsl:value-of select="$current.element/@ident"/></string>
                    <string key="desc"><xsl:value-of select="normalize-space(string-join($current.element/tei:desc//text(),' '))"/></string>
                    <string key="remarks"><xsl:value-of select="normalize-space(string-join($current.element/tei:remarks//text(),' '))"/></string>
                    <string key="url"><xsl:value-of select="'elements/' || $current.element/@ident || '.html'"/></string>
                    <string key="type">element</string>
                </map>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="macros" as="element(json:map)*">
            <xsl:for-each select="$mei.source//tei:macroSpec[@type = 'pe']">
                <xsl:variable name="current.macro.group" select="." as="element(tei:macroSpec)"/>
                <map xmlns="http://www.w3.org/2005/xpath-functions">
                    <string key="ident"><xsl:value-of select="$current.macro.group/@ident"/></string>
                    <string key="desc"><xsl:value-of select="normalize-space(string-join($current.macro.group/tei:desc//text(),' '))"/></string>
                    <string key="remarks"><xsl:value-of select="normalize-space(string-join($current.macro.group/tei:remarks//text(),' '))"/></string>
                    <string key="url"><xsl:value-of select="'macro-groups/' || $current.macro.group/@ident || '.html'"/></string>
                    <string key="type">macroGroup</string>
                </map>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="models" as="element(json:map)*">
            <xsl:for-each select="$mei.source//tei:classSpec[@type = 'model']">
                <xsl:variable name="current.model.class" select="." as="element(tei:classSpec)"/>
                <map xmlns="http://www.w3.org/2005/xpath-functions">
                    <string key="ident"><xsl:value-of select="$current.model.class/@ident"/></string>
                    <string key="desc"><xsl:value-of select="normalize-space(string-join($current.model.class/tei:desc//text(),' '))"/></string>
                    <string key="remarks"><xsl:value-of select="normalize-space(string-join($current.model.class/tei:remarks//text(),' '))"/></string>
                    <string key="url"><xsl:value-of select="'model-classes/' || $current.model.class/@ident || '.html'"/></string>
                    <string key="type">modelClass</string>
                </map>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="attributes" as="element(json:map)*">
            <xsl:for-each select="$mei.source//tei:classSpec[@type = 'atts']">
                <xsl:variable name="current.att.class" select="." as="element(tei:classSpec)"/>
                <map xmlns="http://www.w3.org/2005/xpath-functions">
                    <string key="ident"><xsl:value-of select="$current.att.class/@ident"/></string>
                    <string key="desc"><xsl:value-of select="normalize-space(string-join($current.att.class/tei:desc//text(),' '))"/></string>
                    <string key="remarks"><xsl:value-of select="normalize-space(string-join($current.att.class/tei:remarks//text(),' '))"/></string>
                    <string key="url"><xsl:value-of select="'attribute-classes/' || $current.att.class/@ident || '.html'"/></string>
                    <string key="type">attClass</string>
                </map>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="datatypes" as="element(json:map)*">
            <xsl:for-each select="$mei.source//tei:macroSpec[@type = 'dt']">
                <xsl:variable name="current.data.type" select="." as="element(tei:macroSpec)"/>
                <map xmlns="http://www.w3.org/2005/xpath-functions">
                    <string key="ident"><xsl:value-of select="$current.data.type/@ident"/></string>
                    <string key="desc"><xsl:value-of select="normalize-space(string-join($current.data.type/tei:desc//text(),' '))"/></string>
                    <string key="remarks"><xsl:value-of select="normalize-space(string-join($current.data.type/tei:remarks//text(),' '))"/></string>
                    <string key="url"><xsl:value-of select="'data-types/' || $current.data.type/@ident || '.html'"/></string>
                    <string key="type">dataType</string>
                </map>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="chapters" as="element(json:map)*">
            <xsl:for-each select="$chapters/descendant-or-self::tei:div">
                <xsl:variable name="current.chapter" select="." as="element(tei:div)"/>
                <xsl:variable name="level1" select="$current.chapter/ancestor-or-self::tei:div[@type = 'div1']/@xml:id || '.html'" as="xs:string"/>
                <xsl:variable name="level2" select="if($current.chapter[@type = 'div1']) then('') else('#' || $current.chapter/@xml:id)" as="xs:string"/>
                
                <!-- desc has a higher priority -->
                <xsl:variable name="desc" select="'' || string-join(distinct-values(('', $current.chapter/tei:p//tei:gi[@scheme = 'MEI']/text(), $current.chapter/tei:p//tei:specDesc/string(@key))),' ')" as="xs:string"/>
                <xsl:variable name="remarks" select="'' || normalize-space(string-join($current.chapter/(tei:p, tei:list, tei:table)//text(),' '))" as="xs:string"/>
                
                <xsl:variable name="label" select="$all.chapters/descendant-or-self::chapter[@xml:id = $current.chapter/@xml:id]/concat(@number,' ',@head)" as="xs:string"/>
                
                <map xmlns="http://www.w3.org/2005/xpath-functions">
                    <string key="ident"><xsl:value-of select="$label"/></string>
                    <string key="desc"><xsl:value-of select="$desc"/></string>
                    <string key="remarks"><xsl:value-of select="$remarks"/></string>
                    <string key="url"><xsl:value-of select="'content/' || $level1 || $level2"/></string>
                    <string key="type">chapter</string>
                </map>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="index" as="element(json:array)">
            <array xmlns="http://www.w3.org/2005/xpath-functions">
                <xsl:sequence select="$elements"/>
                <xsl:sequence select="$macros"/>
                <xsl:sequence select="$models"/>
                <xsl:sequence select="$attributes"/>
                <xsl:sequence select="$datatypes"/>
                <xsl:sequence select="$chapters"/>
            </array>
        </xsl:variable>
        
        <xsl:sequence select="$index"/>
        
        <!-- 
        
            <xsl:sequence select="json:xml-to-json($index.xml)"/>
        
        -->
        
    </xsl:function>
    
    <xsl:function name="search:getJavascript" as="text()">
        <xsl:text disable-output-escaping="yes" >
            /* SEARCH */
            const searchOptions = {
                // isCaseSensitive: false,
                includeScore: true,
                shouldSort: true,
                includeMatches: true,
                // findAllMatches: false,
                minMatchCharLength: 3,
                // location: 0,
                threshold: 0.1,
                // distance: 100,
                // useExtendedSearch: false,
                ignoreLocation: true,
                ignoreFieldNorm: false,
                keys: [
                    { name:"ident",
                      weight: 10 },
                    { name:"desc",
                      weight: 2 },
                    { name:"remarks",
                      weight: 1 }
                ]
            };
            
            //initialize search
            let fuse = new Fuse(searchIndex, searchOptions);
            let searchReady = true;
            
            const searchButton1 = document.querySelector('#submitSearchButtonSide');
            const searchButton2 = document.querySelector('#submitSearchButtonTop');
            const searchInput1 = document.querySelector('#search_input');
            const searchInput2 = document.querySelector('#search_inputTop');
            const searchModal = document.querySelector('#searchResultsModal');
            const searchModalCloseBtn = document.querySelector('#searchModalCloseBtn');
            const searchModalCloseBg = document.querySelector('#searchModalCloseBg');
            const searchModalCloseLink = document.querySelector('#searchModalCloseLink');
            const searchResultsBox = document.querySelector('#searchResultsBox');
            
            function search(pattern) {
                
                let results = fuse.search(pattern)
                console.log(results)
                
                searchResultsBox.innerHTML = '';
                
                document.querySelector('#searchPattern').innerText = pattern;
                
                const pathAdjust = (reducedLevels) ? './' : '../';
                
                results.forEach(hit => {
                    let div = document.createElement('div')
                    div.classList.add('searchHit')
                    div.setAttribute('data-score', hit.score)
                    let a = document.createElement('a')
                    a.setAttribute('href', pathAdjust + hit.item.url)
                    a.classList.add(hit.item.type)
                    a.innerHTML = "&amp;lt;" + hit.item.ident + "&amp;gt;"
                    div.append(a)
                    
                    if(hit.item.type === 'chapter') {
                        
                        let remarksHits = hit.matches.filter(m => m.key === 'remarks')
                        if(remarksHits.length > 0) {
                        
                            let firstI = remarksHits[0].indices[0][0];
                            let dist = remarksHits[0].indices[0][1] - remarksHits[0].indices[0][0] + 1;
                            let startRaw = firstI - 40;
                            
                            let hitLength = 140;
                            
                            let offset = (0 > startRaw)? 40 - firstI : 0;
                            let startCleaned = startRaw + offset;
                            
                            let prefix = (startCleaned > 0) ? '…': '';
                            let postfix = (remarksHits[0].value.length > hitLength + dist) ? '…': '';
                            
                            let snippet = remarksHits[0].value.substr(startCleaned, hitLength + dist);
                            
                            let pre = prefix + snippet.substr(0, 40 - offset);
                            let match = snippet.substr(40 - offset, dist);
                            let post = snippet.substr(40 - offset + dist) + postfix;
                            
                            let preview = document.createElement('div')
                            preview.classList.add('searchPreview')
                            preview.setAttribute('data-snippet', snippet)
                            
                            let preSpan = document.createElement('span')
                            preSpan.innerHTML = pre
                            preview.append(preSpan)
                            let matchSpan = document.createElement('span')
                            matchSpan.classList.add('match')
                            matchSpan.innerHTML = match
                            preview.append(matchSpan)
                            let postSpan = document.createElement('span')
                            postSpan.innerHTML = post
                            preview.append(postSpan)
                            
                            div.append(preview)
                        }
                    }
                    
                    
                    
                    searchResultsBox.append(div)
                })
                
                searchModal.classList.add('active');
            }
            
            function initSideSearch(e) {
                e.preventDefault();
                const val = searchInput1.value;
                if(!val.length > 2) {
                    return false;
                }
                search(val)
            }
            
            function initTopSearch(e) {
                e.preventDefault();
                const val = searchInput2.value;
                if(!val.length > 2) {
                    return false;
                }
                search(val)
            }
            
            function closeSearch(e) {
                e.preventDefault();
                searchModal.classList.remove('active');
            }
            
            searchInput1.addEventListener('keypress', e => {
                if (e.key === 'Enter') {
                  initSideSearch(e)
                }
            });
            
            searchInput2.addEventListener('keypress', e => {
                if (e.key === 'Enter') {
                  initTopSearch(e)
                }
            });
            
            searchButton1.addEventListener('click', initSideSearch)
            searchButton2.addEventListener('click', initTopSearch)
            searchModalCloseBtn.addEventListener('click',closeSearch)
            searchModalCloseBg.addEventListener('click',closeSearch)
            searchModalCloseLink.addEventListener('click',closeSearch)
            
        </xsl:text>
    </xsl:function>
</xsl:stylesheet>