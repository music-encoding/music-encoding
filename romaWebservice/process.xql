xquery version "1.0";
(: 
    romaService
    
    author: Daniel Röwenstrunk
:)

declare namespace exist = "http://exist.sourceforge.net/NS/exist";
declare namespace request = "http://exist-db.org/xquery/request";
declare namespace response = "http://exist-db.org/xquery/response";
declare namespace util = "http://exist-db.org/xquery/util";
declare namespace xmldb = "http://exist-db.org/xquery/xmldb";
declare namespace transform = "http://exist-db.org/xquery/transform";

(:declare option exist:serialize "method=xml media-type=text/plain omit-xml-declaration=no indent=yes";
:)
declare option exist:serialize "method=xml media-type=application/x-unknown omit-xml-declaration=no indent=yes";

let $meiSource := util:parse(util:binary-to-string(request:get-uploaded-file-data('source')))
let $meiCustom := util:parse(util:binary-to-string(request:get-uploaded-file-data('customization')))

let $meiSourceFilename := request:get-uploaded-file-name('customization')
let $meiSourceTempFilename := concat(util:uuid(), '_', $meiSourceFilename)

let $store := xmldb:store('/db/romaService/temp', $meiSourceTempFilename, $meiSource)
let $sourceRedirect := concat('http://', request:get-server-name(), ':', request:get-server-port(), substring-before(request:get-uri(), 'process.xql'), 'temp/', $meiSourceTempFilename)

let $response := response:set-header("Content-Disposition", concat("attachment; filename=", replace($meiSourceFilename, '.xml', '.rng')))

let $currentDir := 'file:///var/opt/tei/'

let $simpleODD := transform:transform($meiCustom, concat($currentDir, 'odds2/odd2odd.xsl'), <parameters>
                        <param name="selectedSchema" value="mei"/>
                        <param name="currentDirectory" value="{concat($currentDir, 'odds2')}"/>
                        <param name="TEIC" value="true"/>
                        <param name="defaultSource" value="{$sourceRedirect}"/>
                    </parameters>)

let $resultRNG := transform:transform($simpleODD, concat($currentDir, 'odds2/odd2relax.xsl'), <parameters>
                        <param name="selectedSchema" value="mei"/>
                        <param name="TEIC" value="true"/>
                    </parameters>)

let $delete := xmldb:remove('/db/romaService/temp', $meiSourceTempFilename)

return $resultRNG
