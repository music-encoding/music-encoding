<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
    <sch:ns prefix="rng" uri="http://relaxng.org/ns/structure/1.0"/>
    
    <sch:let name="customization.path" value="string(document-uri(.))"/>
    <sch:let name="mei.source.path" value=" resolve-uri('../mei-source.xml')"/>
    <sch:let name="mei.source" value="document($mei.source.path)"/>
    
    <sch:pattern id="abstract-rules">
        <sch:rule abstract="true" id="get.source">
            <sch:let name="applicable.schemaSpec" value="(ancestor-or-self::tei:schemaSpec, //tei:schemaSpec[//tei:specGrpRef/@target = '#' || current()/ancestor-or-self::tei:specGrp/@xml:id])[1]">
                <!-- TODO: test with multiple schemSpecs referencing the same specGrp -->
            </sch:let>
            <sch:let name="schemaSpec.source.path" value="resolve-uri($applicable.schemaSpec/@source, document-uri(/root()))">
                <!-- on empty @source falls back to $customization.path -->
                <!-- TODO: add better fallbacks -->
                <!-- PROBLEM: if schemaSpec has no source will be $customization.path but default source might be applicable aka mei-source -->
            </sch:let>
            <sch:let name="ident" value="@ident"/>
            <sch:let name="key" value="@key"/>
            <sch:let name="module" value="if (@module) then
                                              @module
                                          else if ($applicable.schemaSpec//tei:classSpec[@ident = $key]) then
                                              $applicable.schemaSpec//tei:classSpec[@ident = $key]/@module
                                          else if (doc($schemaSpec.source.path)//tei:classSpec[@ident = $key]) then
                                              doc($schemaSpec.source.path)//tei:classSpec[@ident = $key]/@module
                                          else if ($applicable.schemaSpec//tei:classRef[@ident = $key][@source]) then
                                              $applicable.schemaSpec//tei:classRef[@ident = $key][@source]/@module
                                          else ()"/>
            <sch:let name="mode" value="@mode"/>
            <sch:let name="module.spec" value="if ($applicable.schemaSpec//tei:moduleSpec[@ident = $module]) then
                                                   $applicable.schemaSpec//tei:moduleSpec[@ident = $module]
                                               else if ($applicable.schemaSpec//tei:moduleRef[@key = $module]) then
                                                   $applicable.schemaSpec//tei:moduleRef[@key = $module]
                                               else if (//tei:moduleRef[@key = $module]) then
                                                   //tei:moduleRef[@key = $module]
                                               else if ($mei.source//tei:moduleRef[@key = $module]) then
                                                   $mei.source//tei:moduleRef[@key = $module]
                                               else ()
                "/><?TODO local moduleSpec ?>
            <sch:let name="module.source.path" value="if ($module.spec/@mode = 'add') then
                                                          $customization.path
                                                      else if ($module.spec/@source) then
                                                          resolve-uri($module.spec/@source, $customization.path)
                                                      else if ($schemaSpec.source.path != '') then
                                                            $schemaSpec.source.path
                                                      else $mei.source.path"/>
            <sch:let name="this.source.path" value="resolve-uri(@source, $customization.path)"/>
            <sch:let name="applicable.source.path" value="if ($mode = 'add') then
                                                              $customization.path
                                                          else if ($this.source.path != '') then
                                                                  $this.source.path
                                                          else if ($module.source.path != '') then
                                                            $module.source.path
                                                          else if ($schemaSpec.source.path != '') then
                                                            $schemaSpec.source.path
                                                          else $mei.source.path"/>
            <sch:let name="applicable.source.doc" value="if (doc-available($applicable.source.path)) then
                                                            doc($applicable.source.path)
                                                         else 'n.a.'"/>
            <sch:report role="info" test="true()">Validating <sch:name/> (<sch:value-of select="$ident | $key | $module"/>)</sch:report>
            <sch:report role="info" test="true()">applicable source path: <sch:value-of select="$applicable.source.path"/></sch:report>
            <sch:report role="error" test="$applicable.source.doc = 'n.a.'">The applicable source doc is not available at: <sch:value-of select="$applicable.source.path"/></sch:report>
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
    <sch:pattern id="check_moduleSpec">
        <sch:let name="moduleKey" value="@ident"/>
        <sch:rule context="tei:moduleSpec">
            <sch:assert test="@mode" role="warning">The "<sch:value-of select="$moduleKey"/>" <sch:name/> should have a @mode.</sch:assert>
        </sch:rule>
        <sch:rule context="tei:moduleSpec">
            <sch:extends rule="get.source"/>
            <sch:let name="moduleKey" value="@ident"/>
            <sch:let name="exists" value="$moduleKey = $applicable.source.doc//tei:moduleSpec/@ident"/>
            <sch:assert test="$exists">There is no module "<sch:value-of select="$moduleKey"/>".</sch:assert>
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
            <sch:assert test="not(@include) or count($false.inclusions) = 0">The following elements are not available in <sch:value-of select="$moduleKey"/>: <sch:value-of select="string-join((
                for $error in $false.inclusions return
                    concat($error, if($applicable.source.doc//tei:elementSpec[@ident = $error]/@module) then
                        ' (should be included in: ' || $applicable.source.doc//tei:elementSpec[@ident = $error]/@module || ')'
                        else ' (cannot be found in any module)')), ', ')"/>.</sch:assert>
            <sch:assert test="not(@except) or count($false.exceptions) = 0">The following elements are not available in <sch:value-of select="$moduleKey"/>: <sch:value-of select="string-join((
                for $error in $false.exceptions return
                    concat($error, if($applicable.source.doc//tei:elementSpec[@ident = $error]/@module) then
                        ' (should be excepted in: ' || $applicable.source.doc//tei:elementSpec[@ident = $error]/@module || ')'
                        else ' (cannot be found in any module)')), ', ')"/>.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- CHECK IF A CLASS REFERENCED BY classes/memberOf IS AVAILABLE -->
    <sch:pattern id="check_memberOf_key_available">
        <sch:rule context="tei:classes/tei:memberOf">
            <sch:extends rule="get.source"/>
            <sch:let name="classenames.mei.source" value="$mei.source//tei:classSpec/@ident"/>
            <sch:let name="classenames.applicable.source" value="$applicable.source.doc//tei:classSpec/@ident"/>
            <sch:let name="classnames.customization" value="//tei:classSpec[@mode = 'add']/@ident"/>
            <sch:let name="classnames.deleted" value="//tei:classSpec[@mode = 'delete']/@ident"/>
            <sch:assert test="@key = ($classenames.mei.source, $classenames.applicable.source, $classnames.customization)">The referenced class "<sch:value-of select="@key"/>" (module: <sch:value-of select="$module"/>) does neither exist in the applicable source (<sch:value-of select="$applicable.source.path"/>) nor in mei source (<sch:value-of select="$mei.source.path"/>) or in your customization (<sch:value-of select="$customization.path"/>).</sch:assert>
            <sch:report role="warning" test="@key = $classnames.deleted">The referenced class "<sch:value-of select="@key"/>" has been deleted from your customization. When converting the ODD to a schema the class will probably be zapped but you should remove the reference here or make sure it is not deleted from your customization.</sch:report>
        </sch:rule>
    </sch:pattern>
</sch:schema>
