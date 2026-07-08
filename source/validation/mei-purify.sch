<?xml version="1.0" encoding="UTF-8"?>
<!--
Author: Benjamin W. Bohl

This schematron is intended to be run associated with the MEI source files:
  * mei-source.xml
  * modules/
  * guidelines

This is being done automatically through Apache Ant and GitHub Actions for each pull request.
Moreover it is associated with the above files to be part of the standard validation
if editors support schematron validation.

The intent of this schematron is to give hints for preparing the conversion to pureODD.

-->
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
    <sch:ns prefix="rng" uri="http://relaxng.org/ns/structure/1.0"/>

    <sch:pattern id="check_rngChoice">
        <sch:rule context="rng:choice">
            <sch:assert role="warning" test="count(*) > 1">A &lt;rng:choice&gt; element has to contain more than one option to choose from.</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="check_teiConstraintSpec_ident">
        <sch:rule context="tei:constraintSpec">
          <sch:let name="precedingIdents" value="preceding::tei:constraintSpec/@ident"></sch:let>
            <sch:assert role="warning" test="if ($precedingIdents != ()) then @ident != $precedingIdents else true()">The @ident (<sch:value-of select="@ident"/>) on constraintSpec has to be unique across all of mei-source.xml. (<sch:value-of select="$precedingIdents"/>)</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="check_teiContent">
        <sch:rule context="tei:content">
            <sch:report role="warning" test="count(*) gt 1">The content definition must not contain more than one element.</sch:report>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="check_teiDatatype">
        <sch:rule context="tei:datatype">
            <sch:report role="warning" test="rng:choice">A &lt;tei:datatype&gt; must not contain a &lt;rng:choice&gt; as a child element. If you need alternative values from other datatypes or want to extend a datatype, please define a new datatype and reference it.</sch:report>
        </sch:rule>
    </sch:pattern>

</sch:schema>
