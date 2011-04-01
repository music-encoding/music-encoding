xquery version "1.0";
(: 
    tagLibrary.xql
    
    This file is the tag library
    
    author: Daniel Röwenstrunk
:)

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace xhtml="http://www.w3.org/1999/xhtml";

declare function local:getTagEntries($selected) {
    for $tag in collection('/db/webapp/tagLibrary')/xhtml:div
    return
        local:getTagEntry($tag, substring-after($tag/@id, 'tagDesc_'), substring-after($tag/@id, 'tagDesc_') = $selected)
};

declare function local:getTagEntry($tag, $id, $selected) {
    if($selected)
    then(<li id="tagMenu_{$id}" class="tagMenu selected marked" onclick="location.href = '/documentation/tagLibrary/{$id}'">&lt;{$id}&gt;</li>)
    else(<li id="tagMenu_{$id}" class="tagMenu" onclick="location.href = '/documentation/tagLibrary/{$id}'">&lt;{$id}&gt;</li>)
};

let $selected := request:get-parameter('tag', '')
return

<div xmlns="http://www.w3.org/1999/xhtml" id="mainframe" class="twoColumns">
    <div id="leftColumn">
        <h1>Tag Library</h1>
        <div id="filter">
            <input id="filterInput" type="text"/>
            <div id="filterIcon"></div>
        </div>
        <div id="leftColumnContent">
            <ul>
            {
                local:getTagEntries($selected)
            }
            </ul>
        </div>	
    </div>
    <div id="content">
        {
            doc(concat('/db/webapp/tagLibrary/tagDesc_', $selected, '.xml'))
        }
    </div>
    <script type="text/javascript" charset="utf-8">
    
        if('{$selected}' != '')
            scrollToTag('.selected');
        
    <!--

        document.observe('keyup', checkArrows);
    
        $('filterInput').observe('keyup', search);
    
        function search(e) {
            var tags = $$('.tagMenu');
            tags.each(function(tag) {
                if(tag.id.replace('tagMenu_', '').toLowerCase().indexOf($('filterInput').value.toLowerCase()) != -1)
                    tag.show();
                else
                    tag.hide();
            });
        }
    
        function checkArrows(e) {
        
            if(window.searchFocus) return;
            if(Prototype.Browser.Gecko && this.window != focus()) return;
        
            if(e.keyCode == 38) {
                var marked = $$('.tagMenu.marked');
                if(marked.length == 0) {
                    getLast().addClassName('marked');
                    scrollToTag('.marked');
                
                }else if(!marked[0].visible()) {
                    var newMarked = getLast();
                    
                    if(newMarked) {
                        marked[0].removeClassName('marked');
                        newMarked.addClassName('marked');
                        
                        scrollToTag('.marked');
                    }
                
                }else {
                    var newMarked = getPrev(marked[0]);
                    
                    if(newMarked) {
                        marked[0].removeClassName('marked');
                        newMarked.addClassName('marked');
                        
                        scrollToTag('.marked');
                    }
                }
                
            }else if(e.keyCode == 40) {
                var marked = $$('.tagMenu.marked');
                
                if(marked.length == 0) {
                    getFirst().addClassName('marked');
                    scrollToTag('.marked');
                    
                }else if(!marked[0].visible()) {
                    var newMarked = getFirst();

                    if(newMarked) {
                        marked[0].removeClassName('marked');
                        newMarked.addClassName('marked');
                        
                        scrollToTag('.marked');
                    }
                
                }else {
                    var newMarked = getNext(marked[0]);

                    if(newMarked) {
                        marked[0].removeClassName('marked');
                        newMarked.addClassName('marked');
                        
                        scrollToTag('.marked');
                    }
                }
                
            }else if(e.keyCode == 13) {
                var marked = $$('.tagMenu.marked');
                
                if(marked.length != 0)
                    if(marked[0].visible())
                        location.href = '/documentation/tagLibrary/' + marked[0].id.substring('tagMenu_'.length);
            }
        }
    
        function scrollToTag(type) {
            var selected = $$('.tagMenu' + type);
        
            if(selected.length != 0)
                $('leftColumnContent').scrollTop = selected[0].positionedOffset().top - 18;
        }
        
        function getFirst() {
            var first = $$('.tagMenu')[0];
            if(!first.visible())
                first = getNext(first);
                
            return first;
        }
        
        function getLast() {
            var last = $$('.tagMenu')[$$('.tagMenu').length - 1];
            if(!last.visible())
                last = getPrev(last);
                
            return last;
        }
        
        function getNext(elem) {
            var next = elem.next('li');
            if(next) {
                if(!next.visible())
                    next = getNext(next);
                    
                return next;
            }else
            
            var hasVisible = false;
            
            $$('.tagMenu').each(function(tag) {
                if(tag.visible()) {
                    hasVisible = true;
                    throw $break;
                }
            });
            
            if(hasVisible)            
                return getFirst();
        }
        
        function getPrev(elem) {
            var prev = elem.previous('li');
            if(prev) {
                if(!prev.visible())
                    prev = getPrev(prev);
                
                return prev;
            }else

            var hasVisible = false;
            
            $$('.tagMenu').each(function(tag) {
                if(tag.visible()) {
                    hasVisible = true;
                    throw $break;
                }
            });
            
            if(hasVisible)            
                return getLast();
        }
    
    -->
    
    </script>
</div>
