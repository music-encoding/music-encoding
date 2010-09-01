xquery version "1.0";
(: 
    romaService
    
    author: Daniel Röwenstrunk
:)

declare namespace exist="http://exist.sourceforge.net/NS/exist";
declare namespace transform="http://exist-db.org/xquery/transform";

declare option exist:serialize "method=xhtml media-type=text/html omit-xml-declaration=no indent=yes 
        doctype-public=-//W3C//DTD&#160;XHTML&#160;1.0&#160;Strict//EN
        doctype-system=http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd";


<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="de" lang="de">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>Roma2 Webservice for MEI</title>
</head>
<body>
    <div style="margin: 100px auto; width:500px;">
        <h1 style="font-size: 12pt;">Roma2 Webservice for MEI Customizations</h1>
        <form action="process.xql" method="post" enctype="multipart/form-data">
            <p>MEI source file: <input name="source" type="file" size="50" maxlength="100000"/></p>
            <p>MEI customization: <input name="customization" type="file" size="50" maxlength="100000"/></p>
            <input type="submit" value="process" style="align: right;"/>
        </form>
    </div>
</body>
</html>