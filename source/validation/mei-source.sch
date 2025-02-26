<?xml version="1.0" encoding="UTF-8"?>
<sch:schema queryBinding="xslt2" xmlns:sch="http://purl.oclc.org/dsdl/schematron">
    <sch:ns prefix="tei" uri="http://www.tei-c.org/ns/1.0"/>
    <sch:ns prefix="rng" uri="http://relaxng.org/ns/structure/1.0"/>

    <sch:pattern id="check_gi_references">
        <sch:rule context="tei:gi">
            <sch:assert role="error"
                test="exists(@scheme)"
                >A &lt;gi&gt; element needs to specify the @scheme which is used. Usually this will have a value of "MEI".</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="check_gi_scheme_MEI_references">
        <sch:rule context="tei:gi[@scheme = 'MEI']">
            <sch:let name="ident_vals" value="//tei:elementSpec/@ident/string()"/>
            <sch:assert role="error" test=" some $ident in $ident_vals satisfies ($ident = text()/string())">
                A &lt;gi scheme="MEI"&gt;<sch:value-of select="text()"/>&lt;/gi&gt; references an element unknown to MEI. It has to match an //elementSpec/@ident.</sch:assert>
        </sch:rule>
        <sch:p>A &lt;gi&gt; in the MEI scheme must reference a value from &lt;elementSpec&gt;/@ident.</sch:p>
    </sch:pattern>

    
    <sch:pattern id="check_ident_type_references">
        <sch:rule context="tei:ident">
            <sch:assert role="error"
                test="exists(@type)"
                >An &lt;ident&gt; element needs to specify its @type. This is usually "class".</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="check_ident_type_class_references">
        <sch:rule context="tei:ident[@type = 'class']">
            <sch:let name="ident_vals" value="//tei:classSpec[@type = ('atts', 'model')]/@ident/string()"/>
            <sch:assert role="error"
                test="
                    some $ident in $ident_vals
                        satisfies ($ident = text()/string())"
                >The &lt;<sch:name/>&gt; contains text which is not declared in any
                &lt;classSpec&gt;/@ident.</sch:assert>
            <sch:p>The text value of &lt;ident&gt; must be equal to at least one value of
                &lt;classSpec&gt;/@ident.</sch:p>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="check_specDesc">
        <sch:rule context="tei:specDesc">
            <sch:assert role="error"
                test="exists(@key)"
                >A &lt;specDesc&gt; element needs to specify a @key.</sch:assert>
            <sch:let name="key" value="string(@key)"/>
            <sch:let name="elements" value="//tei:elementSpec/@ident/string()"/>
            <sch:let name="atts" value="//tei:classSpec[@type ='atts']/@ident/string()"/>
            <sch:let name="models" value="//tei:classSpec[@type ='model']/@ident/string()"/>
            <sch:let name="macros" value="//tei:macroSpec[@type ='pe']/@ident/string()"/>
            <sch:assert role="error"
                test="$key = $elements or $key = $atts or $key = $models or $key = $macros">
                The &lt;specDesc&gt; referencing "<sch:value-of select="$key"/>" is broken: There is no such thing in the specs.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="check_memberOf">
        <sch:rule context="tei:memberOf">
            <sch:assert role="error"
                test="exists(@key)"
                >A &lt;memberOf&gt; element needs to specify a @key.</sch:assert>
            <sch:let name="key" value="string(@key)"/>
            <sch:let name="atts" value="//tei:classSpec[@type ='atts']/@ident/string()"/>
            <sch:let name="models" value="//tei:classSpec[@type ='model']/@ident/string()"/>
            <sch:let name="macros" value="//tei:macroSpec[@type ='pe']/@ident/string()"/>
            <sch:assert role="error"
                test="$key = $atts or $key = $models or $key = $macros">
                The &lt;memberOf&gt; referencing "<sch:value-of select="$key"/>" is broken: There is no such thing in the specs.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="check_rngRef">
        <sch:rule context="rng:ref">
            <sch:assert role="error"
                test="exists(@name)"
                >An &lt;rng:ref&gt; element needs to specify a @name.</sch:assert>
            <sch:let name="name" value="string(@name)"/>
            <sch:let name="elements" value="//tei:elementSpec/@ident/string()"/>
            <sch:let name="models" value="//tei:classSpec[@type = 'model']/@ident/string()"/>
            <sch:let name="macros" value="//tei:macroSpec[@type ='pe']/@ident/string()"/>
            <sch:let name="datatypes" value="//tei:macroSpec[@type ='dt']/@ident/string()"/>
            <sch:assert role="error"
                test="$name = $elements or $name = $models or $name = $macros or $name = $datatypes or $name = ('svg', 'svg_svg')">
                The &lt;rng:ref&gt; to "<sch:value-of select="$name"/>" is broken: There is no such thing in the specs.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- memberOf @key -->
    <!-- rng:ref @name -->

    <sch:pattern id="check_ptr_target">
        <sch:rule context="tei:ptr">
            <sch:assert role="error"
                test="exists(@target)"
                >A &lt;ptr&gt; element needs to specify a @target.</sch:assert>
        </sch:rule>
    </sch:pattern>

    <sch:pattern id="check_ptr_target_references">
        <sch:rule context="tei:ptr[starts-with(@target, '#')]">
            <sch:let name="div_IDs" value="//tei:div/@xml:id/string()"/>
            <sch:let name="target" value="substring-after(@target, '#')"/>
            <sch:assert role="error" test="some $id in $div_IDs satisfies ($id = $target)">
                The &lt;<sch:name/>&gt; points to <sch:value-of select="@target"/> which wasn't declared in a &lt;div&gt;/xml:id.</sch:assert>
        </sch:rule>
    </sch:pattern>

    <!-- check whether att.class names conform to some general principles -->
    <sch:pattern id="attClassNames">
        <sch:rule context="tei:classSpec[@type = 'atts']/@ident">
            <sch:assert test="not(ends-with(., '.visual'))">For consistency reasons, the att.class "<sch:value-of
                    select="."/>" in the "<sch:value-of select="parent::tei:classSpec/@module"/>" module has to be
                renamed to "<sch:value-of select="replace(., '\.visual', '.vis')"/>".</sch:assert>
            <sch:assert test="not(ends-with(., '.logical'))">For consistency reasons, the att.class "<sch:value-of
                    select="."/>" in the "<sch:value-of select="parent::tei:classSpec/@module"/>" module has to be
                renamed to "<sch:value-of select="replace(., '\.logical', '.log')"/>".</sch:assert>
            <sch:assert test="not(ends-with(., '.gestural'))">For consistency reasons, the att.class "<sch:value-of
                    select="."/>" in the "<sch:value-of select="parent::tei:classSpec/@module"/>" module has to be
                renamed to "<sch:value-of select="replace(., '\.gestural', '.ges')"/>".</sch:assert>
            <sch:assert test="not(ends-with(., '.analytical'))">For consistency reasons, the att.class "<sch:value-of
                    select="."/>" in the "<sch:value-of select="parent::tei:classSpec/@module"/>" module has to be
                renamed to "<sch:value-of select="replace(., '\.analytical', '.anl')"/>".</sch:assert>
        </sch:rule>
    </sch:pattern>

    <!-- check whether modules are handled properly -->
    <sch:pattern id="moduleStructure">
        <sch:rule context="tei:specGrp//@module">
            <sch:assert test=". = ancestor::tei:specGrp/tei:moduleSpec/@ident">
                The <sch:value-of select="parent::*/local-name()"/> "<sch:value-of select="parent::*/@ident"/>" with
                @module="<sch:value-of select="."/>"  must not be stored in the 
                <sch:value-of select="ancestor::tei:specGrp/tei:moduleSpec/@ident"/>.xml file, but in <sch:value-of select="."/>.xml.
            </sch:assert>
        </sch:rule>
        <sch:rule context="tei:classSpec[@type = 'atts']">
            <sch:assert test="not(ends-with(@ident,'.vis')) or @module = 'MEI.visual'">
                Visual domain attribute class "<sch:value-of select="@ident"/>" needs to be put into the MEI.visual module
                and must be moved from <sch:value-of select="@module"/>.xml to the MEI.visual.xml file.
            </sch:assert>
            <sch:assert test="not(ends-with(@ident,'.ges')) or @module = 'MEI.gestural'">
                Gestural domain attribute class "<sch:value-of select="@ident"/>" needs to be put into the MEI.gestural module
                and must be moved from <sch:value-of select="@module"/>.xml to the MEI.gestural.xml file.
            </sch:assert>
            <sch:assert test="not(ends-with(@ident,'.anl')) or @module = 'MEI.analytical'">
                Analytical domain attribute class "<sch:value-of select="@ident"/>" needs to be put into the MEI.analytical module
                and must be moved from <sch:value-of select="@module"/>.xml to the MEI.analytical.xml file.
            </sch:assert>
        </sch:rule>
    </sch:pattern>

    <!-- check that each chapter in the guidelines body has an @xml:id -->
    <sch:pattern id="div">
        <sch:rule context="tei:div[ancestor::tei:body]">
            <sch:assert role="error" test="@xml:id">The &lt;<sch:name/>&gt; has no @xml:id.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- check whether things are referenced somewhere -->
    <sch:pattern id="unused_objects">
        <sch:rule context="tei:classSpec[@type = 'atts']">
            <sch:let name="all.memberships" value="//tei:memberOf/string(@key)"/>
            <sch:let name="ident" value="@ident"/>
            <sch:assert test="$ident = $all.memberships" role="warning">
                <sch:value-of select="$ident"/> is not used by any &lt;memberOf key="<sch:value-of select="$ident"/>"/&gt; element. Is it really necessary?
            </sch:assert>
        </sch:rule>
        <sch:rule context="tei:classSpec[@type = 'model']">
            <sch:let name="all.memberships" value="//tei:memberOf/string(@key)"/>
            <sch:let name="all.refs" value="//rng:ref/string(@name)"/>
            <sch:let name="ident" value="@ident"/>
            <sch:assert test="$ident = $all.memberships or $ident = $all.refs" role="warning">
                <sch:value-of select="$ident"/> is not used by any &lt;memberOf key="<sch:value-of select="$ident"/>"/&gt; or &lt;rng:ref name="<sch:value-of select="$ident"/>"/&gt;element. Is it really necessary?
            </sch:assert>
        </sch:rule>
        <sch:rule context="tei:macroSpec[@type = 'pe']">
            <sch:let name="all.refs" value="//rng:ref/string(@name)"/>
            <sch:let name="ident" value="@ident"/>
            <sch:assert test="$ident = $all.refs" role="warning">
                <sch:value-of select="$ident"/> is not used by any &lt;rng:ref name="<sch:value-of select="$ident"/>"/&gt;element. Is it really necessary?
            </sch:assert>
        </sch:rule>
        <sch:rule context="tei:elementSpec">
            <sch:let name="all.refs" value="//rng:ref/string(@name)"/>
            <sch:let name="models" value=".//tei:memberOf[starts-with(@key, 'model.')]/@key"/>
            <sch:let name="ident" value="@ident"/>
            <sch:assert test="$ident = $all.refs or count($models) gt 0" role="warning">
                Element &lt;<sch:value-of select="$ident"/>&gt; seems not to be used by either a &lt;rng:ref name="<sch:value-of select="$ident"/>"/&gt; and isn't member of any model class. Is it really necessary?
            </sch:assert>
        </sch:rule>
        <sch:rule context="tei:macroSpec[@type = 'dt']">
            <sch:let name="all.refs" value="//rng:ref/string(@name)"/>
            <sch:let name="all.macroRefs" value="//tei:macroRef/string(@key)"/>
            <sch:let name="ident" value="@ident"/>
            <sch:assert test="$ident = $all.refs or $ident = $all.macroRefs" role="warning">
               <sch:value-of select="$ident"/> seems not to be used by any &lt;rng:ref name="<sch:value-of select="$ident"/>"/&gt; or &lt;macroRef key="<sch:value-of select="$ident"/>"/&gt;. Is it really necessary?
            </sch:assert>
        </sch:rule>
    </sch:pattern>

</sch:schema>
