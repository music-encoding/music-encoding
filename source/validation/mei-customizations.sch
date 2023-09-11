<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
    <sch:ns prefix="rng" uri="http://relaxng.org/ns/structure/1.0"/>
    
    <sch:let name="schematron.path" value="string(document-uri(.))"/>
    <sch:let name="mei.source.folder" value="substring-before($schematron.path,'/customizations/') || '/source/'"/>
    <sch:let name="mei.source.path" value="$mei.source.folder || 'mei-source.xml'"/>
    <sch:let name="mei.source" value="document($mei.source.path)"/>
    
    <!-- CHECK IF MEI SOURCE IS IN EXPECTED LOCATION AND AVAILABLE -->
    <sch:pattern id="check_source_available">
        <sch:rule context="tei:TEI">
            <sch:assert test="doc-available($mei.source.path)" role="error">The MEI Source file is not available at the expected location of <sch:value-of select="$mei.source.path"/></sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- CHECK IF ATTRIBUTE CLASSES ARE AVAILABLE AND IN CORRECT MODULE -->
    <sch:pattern id="check_att_classSpecs">
        <sch:rule context="tei:classSpec[@type = 'atts'][not(@mode = 'add')]">
            <sch:let name="ident" value="@ident"/>
            <sch:let name="module" value="@module"/>
            <sch:let name="exists" value="$ident = $mei.source//tei:classSpec[@type = 'atts']/@ident"/>
            <sch:assert test="$exists">There is no attribute class with name "<sch:value-of select="$ident"/>".</sch:assert>
            <sch:assert test="not($exists) or $module = $mei.source//tei:classSpec[@ident = $ident]/@module">Attribute class "<sch:value-of select="$ident"/>" is not in module "<sch:value-of select="$module"/>", but in module "<sch:value-of select="$mei.source//tei:classSpec[@ident = $ident]/@module"/>".</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- CHECK IF MODEL CLASSES ARE AVAILABLE AND IN CORRECT MODULE -->
    <sch:pattern id="check_model_classSpecs">
        <sch:rule context="tei:classSpec[@type = 'model'][not(@mode = 'add')]">
            <sch:let name="ident" value="@ident"/>
            <sch:let name="module" value="@module"/>
            <sch:let name="exists" value="$ident = $mei.source//tei:classSpec[@type = 'model']/@ident"/>
            <sch:assert test="$exists">There is no model class with name "<sch:value-of select="$ident"/>".</sch:assert>
            <sch:assert test="not($exists) or $module = $mei.source//tei:classSpec[@ident = $ident]/@module">Model class "<sch:value-of select="$ident"/>" is not in module "<sch:value-of select="$module"/>", but in module "<sch:value-of select="$mei.source//tei:classSpec[@ident = $ident]/@module"/>".</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- CHECK IF MODULES ARE AVAILABLE -->
    <sch:pattern id="check_moduleRef">
        <sch:rule context="tei:moduleRef[@key]">
            <sch:let name="moduleKey" value="@key"/>
            <sch:assert test="$moduleKey = $mei.source//tei:moduleSpec/@ident">There is no module "<sch:value-of select="$moduleKey"/>" in MEI.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- CHECK IF ELEMENTS ARE PROPERLY INCLUDED AND EXCEPTED FROM MODULES -->
    <sch:pattern id="check_moduleRef_includesExcepts">
        <sch:rule context="tei:moduleRef[@key and (@include or @except)]">
            <sch:let name="moduleKey" value="@key"/>
            <sch:let name="all.elements.in.module" value="$mei.source//tei:elementSpec[@module = $moduleKey]/@ident"/>
            <sch:let name="included.elements" value="tokenize(normalize-space(@include),' ')"/>
            <sch:let name="false.inclusions" value="$included.elements[not(. = $all.elements.in.module)]"/>
            <sch:let name="excepted.elements" value="tokenize(normalize-space(@except),' ')"/>
            <sch:let name="false.exceptions" value="$excepted.elements[not(. = $all.elements.in.module)]"/>
            <sch:assert test="not(@include) or count($false.inclusions) = 0">The following elements are not available in <sch:value-of select="$moduleKey"/>: <sch:value-of select="string-join((for $error in $false.inclusions return ($error || ' (should be: ' || $mei.source//tei:elementSpec[@ident = $error]/@module || ')')), ', ')"/>.</sch:assert>
            <sch:assert test="not(@except) or count($false.exceptions) = 0">The following elements are not available in <sch:value-of select="$moduleKey"/>: <sch:value-of select="string-join((for $error in $false.exceptions return ($error || ' (should be: ' || $mei.source//tei:elementSpec[@ident = $error]/@module || ')')), ', ')"/>.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- CHECK IF A CLASS REFERENCED BY classes/memberOf IS AVAILABLE -->
    <sch:pattern id="check_memberOf_key_available">
        <sch:let name="classenames.source" value="$mei.source//tei:classSpec/@ident"/>
        <sch:let name="classnames.customization" value="//tei:classSpec/@ident[@mode = 'add']"/>
        <sch:let name="classnames.deleted" value="//tei:classSpec[@mode = 'delete']/@ident"/>
        <sch:rule context="tei:classes/tei:memberOf">
            <sch:assert test="@key = ($classenames.source, $classnames.customization)">The referenced class "<sch:value-of select="@key"/>" does neither exist in your source, nor in your customization.</sch:assert>
            <sch:report role="warning" test="@key = $classnames.deleted">The referenced class "<sch:value-of select="@key"/>" has been deleted from your customization.</sch:report>
        </sch:rule>
    </sch:pattern>
</sch:schema>
