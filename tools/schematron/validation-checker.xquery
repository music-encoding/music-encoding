xquery version "1.0" encoding "UTF-8";
declare option saxon:output "omit-xml-declaration=yes";
declare option saxon:output "method=text";
let $errors := //*:failed-assert
for $error in $errors
let $location := $error/@location
let $text := normalize-space($error/*:text/text())
return concat("Error: ", $text, "&#xA;Location: ", $location, "&#xA;-------&#xA;")
