<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
    <sch:ns prefix="rng" uri="http://relaxng.org/ns/structure/1.0"/>

    <sch:pattern id="check_rngChoice">
        <sch:rule context="rng:choice">
            <sch:assert role="error" test="count(*) > 1">An &lt;rng:choice&gt; element hast to contain more than one option to choose from.</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="check_teiConstraintSpec_ident">
        <sch:rule context="tei:constraintSpec">
            <sch:assert role="error" test="@ident != preceding::tei:constraintSpec/@ident">The @ident on constraintSpec has to be unique across all of mei-source.xml.</sch:assert>
        </sch:rule>
    </sch:pattern>


</sch:schema>
