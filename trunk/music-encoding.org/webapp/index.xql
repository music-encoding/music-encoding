xquery version "1.0";
(: 
    index.xql
    
    This file is the main content file for the mei website
    
    author: Daniel Röwenstrunk
:)

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace util="http://exist-db.org/xquery/util";

declare option exist:serialize "method=xhtml media-type=text/html omit-xml-declaration=no indent=yes 
        doctype-public=-//W3C//DTD&#160;XHTML&#160;1.0&#160;Strict//EN
        doctype-system=http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd";

declare function local:getMenuOne($siteID) {
    
    let $site := if(doc('/db/webapp/sitemap.xml')/sitemap/site[@id eq $siteID])
                    then($siteID)
                    else(doc('/db/webapp/sitemap.xml')/sitemap//site[@id eq $siteID]/ancestor::site/@id)
                    
    return
    
    for $s in doc('/db/webapp/sitemap.xml')/sitemap/site
	return
	   if($s/@id eq $site)
	   then(<div id="{$s/@id}" class="tab active"><a href="/{$s/@id}">{$s/string(@name)}</a></div>)
	   else(<div id="{$s/@id}" class="tab"><a href="/{$s/@id}">{$s/string(@name)}</a></div>)
};

declare function local:getMenuTwo($siteID) {
    
    let $site := if(doc('/db/webapp/sitemap.xml')/sitemap/site[@id eq $siteID])
                    then($siteID)
                    else(doc('/db/webapp/sitemap.xml')/sitemap//site[@id eq $siteID]/ancestor::site/@id)
                    
    return

    for $s in doc('/db/webapp/sitemap.xml')/sitemap/site[@id eq $site]/site
	return
	   if($s/@id eq $siteID)
	   then(<div id="{$s/@id}" class="tab active"><a href="/{$site}/{$s/@id}">{$s/string(@name)}</a></div>)
	   else(<div id="{$s/@id}" class="tab"><a href="/{$site}/{$s/@id}">{$s/string(@name)}</a></div>)
};

declare function local:getSiteContent($siteID) {
    if($siteID = 'search')
    then(util:eval(xs:anyURI('xmldb:exist:///db/webapp/search.xql')))
    else if($siteID = 'sitemap')
    then(util:eval(xs:anyURI('xmldb:exist:///db/webapp/sitemap.xql')))
    else if($siteID = 'contact')
    then(doc('/db/webapp/contact.xml'))
    else(local:getSiteFromSitemap($siteID))
};

declare function local:getSiteFromSitemap($siteID) {
    let $ref := doc('/db/webapp/sitemap.xml')/sitemap//site[@id eq $siteID]/data(@ref)
    return 
        if(ends-with($ref, '.xml'))
        then(doc(concat('/db/webapp/', $ref)))
        else(util:eval(xs:anyURI(concat('xmldb:exist:///db/webapp/', $ref))))
};

let $site := if(ends-with(request:get-parameter('site', 'home'), '/'))
                then(substring-before(request:get-parameter('site', 'home'), '/'))
                else(request:get-parameter('site', 'home'))

return

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de" lang="de">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Music Encoding Initiative</title>
	<link rel="stylesheet" href="/css/main.css" type="text/css" charset="utf-8" />
	<link rel="stylesheet" href="/css/xmlPrettyPrint.css" type="text/css" charset="utf-8" />
	<script type="text/javascript" src="/js/prototype.js" charset="utf-8"></script>
	<script type="text/javascript" src="/js/scriptaculous.js?load=effects,dragdrop,slider"></script>
	<script type="text/javascript" src="/js/main.js"></script>

</head>
<body>
	<div id="outerframe">
		<div id="header">
		    <div id="logo"></div>
			<h1>The Music Encoding Initiative</h1>
			<h2>…modelling music notation with XML</h2>
			<div id="headmenu">
			    {
				    local:getMenuOne($site)
				}
			</div>
			<div id="submenu">
				{
				    local:getMenuTwo($site)
				}
			</div>
			<div id="search">
				<input id="searchInput" type="text"/>
				<div id="searchIcon" onclick="doSearchClick();"></div>
			</div>
		</div>

        {
            local:getSiteContent($site)
        }

        <div id="footer">
				<a href="/sitemap" class="footerLink">Sitemap</a> | 
				<a href="/contact" class="footerLink">Contact</a>
			</div>
	</div>
	
    <script type="text/javascript" charset="utf-8">
        <!--
        
            window.searchFocus = false;
        
            $('searchInput').observe('keyup', doSearch);
            
            $('searchInput').observe('focus', function(e) {
                window.searchFocus = true;
            });
            
            $('searchInput').observe('blur', function(e) {
                window.searchFocus = false;
            });
        
            function doSearch(e) {
                if(Prototype.Browser.Gecko && this.window != focus()) return;
                if(!window.searchFocus) return;
                
                var trimmed = $('searchInput').value.replace(/^\s+|\s+$/g,"");

                if(e.target.id == 'searchInput' && e.keyCode == 13 && trimmed != '')
                    location.href = '/search/' + trimmed;
            }

            function doSearchClick() {
                var trimmed = $('searchInput').value.replace(/^\s+|\s+$/g,"");

                if(trimmed != '')
                    location.href = '/search/' + trimmed;
            }
        -->
    </script>
</body>
</html>