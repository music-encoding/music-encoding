<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
    <sch:ns prefix="rng" uri="http://relaxng.org/ns/structure/1.0"/>
    
    <sch:let name="customization.path" value="string(document-uri(.))"/>
    <sch:let name="mei.source.path" value=" resolve-uri('../mei-source.xml')"/>
    <sch:let name="mei.source" value="document($mei.source.path)"/>
    
    <sch:pattern id="abstract-rules">
        <sch:rule abstract="true" id="get.source">
            <sch:let name="schemaSpec.source.path" value="resolve-uri(ancestor-or-self::tei:schemaSpec/@source, document-uri(/root()))"/>
            <sch:let name="ident" value="@ident"/>
            <sch:let name="module" value="@module"/>
            <sch:let name="module.spec" value="ancestor-or-self::tei:schemaSpec//*[@ident = $module] | ancestor-or-self::tei:schemaSpec//*[@key = $module]"/>
            <sch:let name="module.source.path" value="resolve-uri($module.spec/@source, document-uri(/root()))"/>
            <sch:let name="this.source.path" value="resolve-uri(@source, document-uri(/root()))"/>
            <sch:let name="applicable.source.path" value="if (@source) then
                                                              if (doc-available($this.source.path)) then
                                                                  $this.source.path
                                                              else 'error'
                                                          else if (doc-available($module.source.path)) then
                                                            $module.source.path
                                                          else if (doc-available($schemaSpec.source.path)) then
                                                            $schemaSpec.source.path
                                                          else $mei.source.path"/>
            <sch:let name="applicable.source.doc" value="doc($applicable.source.path)"/>
            <sch:report role="info" test="true()">applicable source: <sch:value-of select="$applicable.source.path"/></sch:report>
        </sch:rule>
    </sch:pattern>
    
    <!-- CHECK IF MEI SOURCE IS IN EXPECTED LOCATION AND AVAILABLE -->
    <sch:pattern id="check_source_available">
        <sch:rule context="tei:schemaSpec">
            <sch:extends rule="get.source"/>
            <sch:assert role="warning" test="doc-available($applicable.source.path)">The applicable MEI Source file is not available at the expected location of <sch:value-of select="$applicable.source.path"/></sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- CHECK IF ATTRIBUTE CLASSES ARE AVAILABLE AND IN CORRECT MODULE -->
    <sch:pattern id="check_att_classSpecs">
        <sch:rule context="tei:classSpec[@type = 'atts']">
            <sch:extends rule="get.source"/>
            <sch:let name="exists" value="$ident = $applicable.source.doc//tei:classSpec[@type = 'atts']/@ident"/>
            <sch:assert test="$exists">There is no attribute class with name "<sch:value-of select="$ident"/>".</sch:assert>
            <sch:assert test="not($exists) or $module = $applicable.source.doc//tei:classSpec[@ident = $ident]/@module">Attribute class "<sch:value-of select="$ident"/>" is not in module "<sch:value-of select="$module"/>", but in module "<sch:value-of select="$applicable.source.doc//tei:classSpec[@ident = $ident]/@module"/>".</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- CHECK IF MODEL CLASSES ARE AVAILABLE AND IN CORRECT MODULE -->
    <sch:pattern id="check_model_classSpecs">
        <sch:rule context="tei:classSpec[@type = 'model']">
            <sch:extends rule="get.source"/>
            <sch:let name="exists" value="$ident = $applicable.source.doc//tei:classSpec[@type = 'model']/@ident"/>
            <sch:assert test="$exists">There is no model class with name "<sch:value-of select="$ident"/>".</sch:assert>
            <sch:assert test="not($exists) or $module = $applicable.source.doc//tei:classSpec[@ident = $ident]/@module">Model class "<sch:value-of select="$ident"/>" is not in module "<sch:value-of select="$module"/>", but in module "<sch:value-of select="$applicable.source.doc//tei:classSpec[@ident = $ident]/@module"/>".</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- CHECK IF MODULES ARE AVAILABLE -->
    <sch:pattern id="check_moduleRef">
        <sch:rule context="tei:moduleRef[@key]">
            <sch:extends rule="get.source"/>
            <sch:let name="moduleKey" value="@key"/>
            <sch:let name="exists" value="$moduleKey = $applicable.source.doc//tei:moduleSpec/@ident"/>
            <sch:assert test="$exists">There is no module "<sch:value-of select="$moduleKey"/>".</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- CHECK IF ELEMENTS ARE PROPERLY INCLUDED AND EXCEPTED FROM MODULES -->
    <sch:pattern id="check_moduleRef_includesExcepts">
        <sch:rule context="tei:moduleRef[@key and (@include or @except)]">
            <sch:extends rule="get.source"/>
            <sch:let name="moduleKey" value="@key"/>
            <sch:let name="all.elements.in.module" value="$applicable.source.doc//tei:elementSpec[@module = $moduleKey]/@ident"/>
            <sch:let name="included.elements" value="tokenize(normalize-space(@include),' ')"/>
            <sch:let name="false.inclusions" value="$included.elements[not(. = $all.elements.in.module)]"/>
            <sch:let name="excepted.elements" value="tokenize(normalize-space(@except),' ')"/>
            <sch:let name="false.exceptions" value="$excepted.elements[not(. = $all.elements.in.module)]"/>
            <sch:assert test="not(@include) or count($false.inclusions) = 0">The following elements are not available in <sch:value-of select="$moduleKey"/>: <sch:value-of select="string-join((for $error in $false.inclusions return ($error || ' (should be: ' || $applicable.source.doc//tei:elementSpec[@ident = $error]/@module || ')')), ', ')"/>.</sch:assert>
            <sch:assert test="not(@except) or count($false.exceptions) = 0">The following elements are not available in <sch:value-of select="$moduleKey"/>: <sch:value-of select="string-join((for $error in $false.exceptions return ($error || ' (should be: ' || $applicable.source.doc//tei:elementSpec[@ident = $error]/@module || ')')), ', ')"/>.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
</sch:schema>
