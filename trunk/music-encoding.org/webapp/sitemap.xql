xquery version "1.0";
(: 
    sitemap.xql
    
    This file generates a sitemap
    
    author: Daniel Röwenstrunk
:)

declare namespace exist="http://exist.sourceforge.net/NS/exist";

declare function local:generateSitemap() {
    for $site in doc('/db/webapp/sitemap.xml')/sitemap/site
    return (
        <li><a href="/{$site/data(@id)}">{$site/data(@name)}</a></li>,
        if(exists($site/site))
        then(
            <li>
            <ul>
                {
                for $site2 in $site/site
                return
                    <li><a href="/{$site/data(@id)}/{$site2/data(@id)}">{$site2/data(@name)}</a></li>
                }
            </ul>
            </li>
        )
        else()
    )
};

<div xmlns="http://www.w3.org/1999/xhtml" id="mainframe" class="oneColumn">
    <div id="content">
        <h1>Sitemap</h1>

        <ul class="sitemap">
        {
            local:generateSitemap()
        }
        </ul>
    </div>
</div>