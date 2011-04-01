function openSteppedContentToC() {
    if(!$('fullToC').visible()) {
        $('openFullToCText').update('Close Table of Contents');
        Effect.SlideDown('fullToC', {queue: 'end'});
    }    
    else {
        $('openFullToCText').update('Open Table of Contents');
        Effect.SlideUp('fullToC', {queue: 'end'});
    }    
}