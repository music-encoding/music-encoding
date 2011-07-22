xquery version "1.0";
(: 
    search.xql
    
    This file is for searching
    
    author: Daniel Röwenstrunk
:)

declare namespace exist="http://exist.sourceforge.net/NS/exist";

import module  namespace kwic="http://exist-db.org/xquery/kwic";

declare function local:getHref($div) {
	if($div/@class = 'tagDoc')
    then(concat('/documentation/tagLibrary/', substring-after($div/data(@id), 'tagDesc_')))
    else(concat('/', local:getSiteHref(concat('sites/', util:document-name($div)))))
};

declare function local:getName($div) {
    if($div/@class = 'tagDoc')
    then(concat('Tag Library - ', '&lt;', substring-after($div/data(@id), 'tagDesc_'), '&gt;'))
    else(local:getSite(concat('sites/', util:document-name($div)))/data(@name))
};

declare function local:getSiteHref($uri) {
    let $site := local:getSite($uri)
    return
    
    if($site[local-name(./..) eq 'site'])
    then(concat($site/../data(@id), '/', $site/data(@id)))
    else($site/data(@id))
};

declare function local:getSite($uri) {
	doc('/db/webapp/sitemap.xml')/sitemap//site[./@ref = $uri]
};


let $query := request:get-parameter('query', '')
return

<div xmlns="http://www.w3.org/1999/xhtml" id="mainframe" class="oneColumn">
    <div id="content">
        <h1>Search result</h1>

{
if($query != '')
then (
    for $div in collection('/db/webapp/sites')/div[ft:query(., $query)] | collection('/db/webapp/tagLibrary')/div[ft:query(., $query)]
    let $expanded  := kwic:expand($div)
    order by ft:score($div) descending
    return
    	<div class="resultPage">
    		<a class="pageLink" href="{local:getHref($div)}">{local:getName($div)}</a>
    		{
    		for $p in $expanded//*[.//exist:match]
    		return
    			kwic:summarize($p, <config xmlns="" width="35" link="{local:getHref($div)}" />)
    	}</div>
    )
else()
    }

    </div>
</div>