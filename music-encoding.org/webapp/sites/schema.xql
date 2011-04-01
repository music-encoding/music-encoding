xquery version "1.0";
declare namespace transform="http://exist-db.org/xquery/transform";

let $example1 := <mei xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.music-encoding.org/ns/mei http://music-encoding.org/mei/schemata/2010-05/xsd/mei-all.xsd" xmlns="http://www.music-encoding.org/ns/mei"/>
let $example2 := <mei xmlns="http://www.music-encoding.org/ns/mei"/>
let $example3 := <mei xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.music-encoding.org/ns/mei http://music-encoding.org/mei/schemata/2010-05/xsd/mei-all.xsd" xmlns="http://www.music-encoding.org/ns/mei"/>
return

<div xmlns="http://www.w3.org/1999/xhtml" id="mainframe" class="oneColumn">
    <div id="content">
        <h1>Schema – Release 2010-05</h1>
        <p>
           The Music Encoding Initiative (MEI) schema is a set of rules for
           recording the intellectual and physical characteristics of music
           notation documents so that the information contained in them may be
           searched, retrieved, displayed, and exchanged in a predictable and
           platform-independent manner.
        </p>
        <p>
           The schema is provided in both RelaxNG (RNG) and W3C (XSD) schema forms.
           Both versions consist of a driver file (mei-all), modules (such as
           analysis, cmnOrnaments, etc.) and auxiliary files (defaultClassDecls and
           datatypes).
        </p>
        <h3>Example 1</h3>
        <p>
           The XSD schema may be associated with an MEI document via the xmlns,
           xmlns:xsi, and xsi:schemaLocation attributes of the document element.
           The schemaLocation attribute pairs the MEI namespace and the location of
           the schema file on your computer.
        </p>
        {transform:transform($example1, doc("/db/webapp/xml-pretty-print.xsl"), <parameters><param name="showProcessingInstructions" value='&lt;?xml version="1.0" encoding="UTF-8"?&gt;'/></parameters>)}
        <h3>Example 2</h3>
        <p>
           An RNG schema, however, is usually invoked using an XML processing
              instruction.
        </p>
        {transform:transform($example2, doc("/db/webapp/xml-pretty-print.xsl"), <parameters><param name="showProcessingInstructions" value='&lt;?xml version="1.0" encoding="UTF-8"?&gt;&lt;?oxygen RNGSchema="http://music-encoding.org/mei/schemata/2010-05/rng/mei-all.rng" type="xml"?&gt;'/></parameters>)}
        <h3>Example 3</h3>
        <p>
           Additional MEI rules that cannot be expressed in either schema language,
           referred to as co-constraints, are provided in a separate file
           (coConstraints). In the RNG version, these rules are contained in an RNG
           fragment (coConstraints.rng) that is invoked by the mei-all file.
           However, in the XSD version of the schema, co-constraints are not
           referenced by the mei-all driver file. A schematron schema
           (coConstraints.sch) must be associated with the MEI document separately
           via a processing instruction.
        </p>
        {transform:transform($example3, doc("/db/webapp/xml-pretty-print.xsl"), <parameters><param name="showProcessingInstructions" value='&lt;?xml version="1.0" encoding="UTF-8"?&gt;&lt;?oxygen SCHSchema="http://music-encoding.org/mei/schemata/2010-05/xsd/coConstraints.sch"?&gt;'/></parameters>)}
        <p>
           In addition to the schema, two eXtensible stylesheet language (XSL)
           styles are provided. The musicxml2mei stylesheet is for converting time-
           wise MusicXML files to MEI, while the mei2mup stylesheet converts MEI-
           encoded material to Mup (Music Publisher) for rendering. Both tools are
           provided as experiments in creating migration paths to and from MEI.
           Neither is a complete implementation. Post-processing of the output of
           these stylesheets may be necessary to create valid and meaningful MEI or
           Mup files.
        </p>
    </div>
</div>