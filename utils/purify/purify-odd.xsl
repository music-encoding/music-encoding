<?xml version="1.0" encoding="UTF-8"?>
<!--
  Driver for purify.xsl: purifies one ODD file (mei-source.xml or a
  customization) together with the definitions it depends on.

  Run with the ODD as global context item and the initial template, e.g.
    java -jar saxon.jar -s:customizations/mei-basic.xml -it -xsl:purify-odd.xsl
         base-dir=/path/to/repo staging-dir=/tmp/x [source=...] [external=true]

  Dependencies are resolved by following
    - xi:include/@href
    - moduleRef/@key (looked up as moduleSpec in the source of the schemaSpec)
    - @source of elementSpec, classSpec, macroSpec, dataSpec, specGrpRef
      (att.readFrom) and specGrpRef/@target
  The source of a schemaSpec (@source, or the $source parameter when it has
  none) is read as context only: it supplies the moduleSpecs and the other
  definitions purify.xsl looks at, but is not itself transformed.

  Only local files (file: URIs) inside $base-dir are transformed and written
  to $staging-dir (mirroring their path relative to $base-dir), and only when
  purify actually changes them. Dependencies are only transformed with
  external=true. Anything that cannot be followed (remote URLs, tei: URIs,
  moduleRef/@url, missing files) is reported.

  The principal output is a report, one line per file or reference.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:pd="urn:x-mei:purify-odd" xmlns:xi="http://www.w3.org/2001/XInclude"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all" version="3.0">

  <xsl:import href="purify.xsl"/>

  <!-- the report; transformed files are serialized with the "odd" format -->
  <xsl:output method="text"/>
  <xsl:output name="odd" method="xml" indent="yes" encoding="UTF-8"/>

  <!-- absolute path of the repository root; only files below it are written -->
  <xsl:param name="base-dir" as="xs:string" required="yes"/>
  <!-- absolute path of the directory transformed files are written to -->
  <xsl:param name="staging-dir" as="xs:string" required="yes"/>
  <!-- absolute path of the source used for a schemaSpec without @source -->
  <xsl:param name="source" as="xs:string" select="''"/>
  <!-- transform dependencies as well, not only the ODD itself -->
  <xsl:param name="external" as="xs:boolean" select="false()"/>

  <xsl:variable name="base-uri" select="pd:dir-uri($base-dir)"/>
  <xsl:variable name="staging-uri" select="pd:dir-uri($staging-dir)"/>
  <xsl:variable name="source-uri" select="if ($source = '') then () else pd:path-uri($source)"/>
  <!-- (document-uri() is empty for the -s source) -->
  <xsl:variable name="odd-uri" select="string(base-uri(/))"/>

  <!-- ****************************************************************** -->
  <!-- Paths and URIs                                                     -->
  <!-- ****************************************************************** -->

  <xsl:function name="pd:path-uri" as="xs:string">
    <xsl:param name="path" as="xs:string"/>
    <xsl:sequence select="'file:' || string-join(tokenize($path, '/') ! encode-for-uri(.), '/')"/>
  </xsl:function>

  <xsl:function name="pd:dir-uri" as="xs:string">
    <xsl:param name="path" as="xs:string"/>
    <xsl:sequence select="replace(pd:path-uri($path), '([^/])$', '$1/')"/>
  </xsl:function>

  <!-- resolve a reference against its element; unresolvable values (e.g.
       broken URIs) are returned as they are and end up in the report -->
  <xsl:function name="pd:resolve" as="xs:string">
    <xsl:param name="ref" as="xs:string"/>
    <xsl:param name="context" as="node()"/>
    <xsl:try>
      <xsl:sequence select="string(resolve-uri(normalize-space($ref), base-uri($context)))"/>
      <xsl:catch>
        <xsl:sequence select="$ref"/>
      </xsl:catch>
    </xsl:try>
  </xsl:function>

  <xsl:function name="pd:is-local" as="xs:boolean">
    <xsl:param name="uri" as="xs:string"/>
    <xsl:sequence select="starts-with($uri, 'file:') and doc-available($uri)"/>
  </xsl:function>

  <xsl:function name="pd:rel" as="xs:string">
    <xsl:param name="uri" as="xs:string"/>
    <xsl:sequence select="if (starts-with($uri, $base-uri)) then substring-after($uri, $base-uri) else $uri"/>
  </xsl:function>

  <!-- ****************************************************************** -->
  <!-- References                                                         -->
  <!-- ****************************************************************** -->

  <!-- A reference: @kind is "input" (the ODD), "dep" (a file of definitions
       making up the ODD), "ctx" (read as context only) or "none" (not
       followed, only reported). -->
  <xsl:function name="pd:ref" as="element(pd:ref)">
    <xsl:param name="kind" as="xs:string"/>
    <xsl:param name="uri" as="xs:string?"/>
    <xsl:param name="via" as="xs:string"/>
    <xsl:param name="from" as="node()?"/>
    <pd:ref kind="{$kind}" uri="{$uri}" via="{$via}" from="{if ($from) then pd:rel(string(base-uri($from))) else ''}"/>
  </xsl:function>

  <xsl:function name="pd:xincludes" as="element(pd:ref)*">
    <xsl:param name="d" as="document-node()"/>
    <xsl:param name="kind" as="xs:string"/>
    <xsl:for-each select="$d//xi:include[@href][not(@parse = 'text')]">
      <xsl:sequence select="pd:ref($kind, pd:resolve(@href, .), 'xi:include', .)"/>
    </xsl:for-each>
  </xsl:function>

  <!-- the URIs of a document and everything it includes -->
  <xsl:function name="pd:include-closure" as="xs:string*">
    <xsl:param name="todo" as="xs:string*"/>
    <xsl:param name="done" as="xs:string*"/>
    <xsl:variable name="u" select="head($todo)"/>
    <xsl:choose>
      <xsl:when test="empty($todo)">
        <xsl:sequence select="$done"/>
      </xsl:when>
      <xsl:when test="$u = $done or not(pd:is-local($u))">
        <xsl:sequence select="pd:include-closure(tail($todo), $done)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="pd:include-closure((tail($todo), pd:xincludes(doc($u), 'ctx')/@uri), ($done, $u))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- the source a schemaSpec reads from: @source, else the $source param
       (unless that is the document itself, e.g. mei-source.xml) -->
  <xsl:function name="pd:schema-source" as="xs:string?">
    <xsl:param name="schemaSpec" as="element(schemaSpec)?"/>
    <xsl:sequence select="if ($schemaSpec/@source) then pd:resolve($schemaSpec/@source, $schemaSpec)
                          else $source-uri[. ne string(base-uri(root($schemaSpec)))]"/>
  </xsl:function>

  <!-- all references of a file of definitions -->
  <xsl:function name="pd:refs" as="element(pd:ref)*">
    <xsl:param name="d" as="document-node()"/>

    <xsl:sequence select="pd:xincludes($d, 'dep')"/>

    <xsl:for-each select="$d//(elementSpec | classSpec | macroSpec | dataSpec | specGrpRef)[@source]">
      <xsl:sequence select="pd:ref('dep', pd:resolve(@source, .), '@source on ' || local-name(), .)"/>
    </xsl:for-each>
    <xsl:for-each select="$d//specGrpRef[@target][not(starts-with(@target, '#'))]">
      <xsl:sequence select="pd:ref('dep', pd:resolve(replace(@target, '#.*$', ''), .), 'specGrpRef/@target', .)"/>
    </xsl:for-each>

    <xsl:for-each select="$d//schemaSpec">
      <xsl:variable name="src" select="pd:schema-source(.)"/>
      <xsl:sequence select="if (exists($src))
                            then pd:ref('ctx', $src, if (@source) then 'schemaSpec/@source' else 'schemaSpec without @source: --source', .)
                            else pd:ref('none', (), 'schemaSpec ' || @ident || ' without @source: TEI default source, not followed', .)"/>
    </xsl:for-each>

    <xsl:for-each select="$d//moduleRef[@url]">
      <xsl:sequence select="pd:ref('none', pd:resolve(@url, .), 'moduleRef/@url (RELAX NG), not followed', .)"/>
    </xsl:for-each>
    <xsl:for-each select="$d//moduleRef[@key]">
      <xsl:variable name="key" select="string(@key)"/>
      <xsl:variable name="src" select="if (@source) then pd:resolve(@source, .) else pd:schema-source(ancestor::schemaSpec[1])"/>
      <xsl:variable name="hits" select="pd:include-closure($src, ())[doc(.)//moduleSpec[@ident = $key]]"/>
      <xsl:sequence select="if (exists($hits))
                            then $hits ! pd:ref('dep', ., 'moduleRef ' || $key, current())
                            else pd:ref('none', $src, 'moduleRef ' || $key || ': no moduleSpec found in source', .)"/>
    </xsl:for-each>
  </xsl:function>

  <!-- Walk all references, starting with the ODD. A document already
       visited as dep is not visited again; one visited as ctx only is
       visited again as dep (it is then transformed, too). -->
  <xsl:function name="pd:walk" as="element(pd:ref)*">
    <xsl:param name="todo" as="element(pd:ref)*"/>
    <xsl:param name="seen" as="xs:string*"/>
    <xsl:param name="acc" as="element(pd:ref)*"/>
    <xsl:variable name="r" select="head($todo)"/>
    <xsl:variable name="mode" select="if ($r/@kind = 'ctx') then 'ctx' else 'dep'"/>
    <xsl:variable name="key" select="$mode || ' ' || $r/@uri"/>
    <xsl:choose>
      <xsl:when test="empty($todo)">
        <xsl:sequence select="$acc"/>
      </xsl:when>
      <xsl:when test="$r/@kind = 'none' or not(pd:is-local($r/@uri)) or $key = $seen
                      or ($mode = 'ctx' and ('dep ' || $r/@uri) = $seen)">
        <xsl:sequence select="pd:walk(tail($todo), $seen, ($acc, $r))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="d" select="doc($r/@uri)"/>
        <xsl:variable name="new" select="if ($mode = 'ctx') then pd:xincludes($d, 'ctx') else pd:refs($d)"/>
        <xsl:sequence select="pd:walk((tail($todo), $new), ($seen, $key), ($acc, $r))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:variable name="refs" select="pd:walk(pd:ref('input', $odd-uri, 'input', ()), (), ())"/>

  <xsl:variable name="local" select="$refs[@kind ne 'none'][pd:is-local(@uri)]"/>
  <xsl:variable name="dep-uris" select="distinct-values($local[@kind = ('input', 'dep')]/@uri)"/>
  <xsl:variable name="ctx-uris" select="distinct-values($local[@kind = 'ctx']/@uri)[not(. = $dep-uris)]"/>

  <!-- purify.xsl looks at every definition of the ODD and its sources -->
  <xsl:variable name="all-modules" as="document-node()*" select="($dep-uris, $ctx-uris) ! doc(.)"/>

  <!-- ****************************************************************** -->
  <!-- Transform and report                                               -->
  <!-- ****************************************************************** -->

  <xsl:template name="xsl:initial-template">
    <xsl:for-each select="$dep-uris">
      <xsl:variable name="uri" select="."/>
      <xsl:variable name="d" select="doc($uri)"/>
      <xsl:variable name="label" select="if ($uri = $odd-uri) then 'odd' else 'dependency'"/>
      <xsl:choose>
        <xsl:when test="$uri ne $odd-uri and not($external)">
          <xsl:value-of select="'skipped     ' || pd:rel($uri) || '  (dependency, use --external)&#10;'"/>
        </xsl:when>
        <xsl:when test="not(starts-with($uri, $base-uri))">
          <xsl:value-of select="'not written ' || $uri || '  (outside ' || $base-dir || ')&#10;'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="result" as="document-node()">
            <xsl:document>
              <xsl:apply-templates select="$d"/>
            </xsl:document>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="deep-equal($d/*, $result/*)">
              <xsl:value-of select="'unchanged   ' || pd:rel($uri) || '  (' || $label || ')&#10;'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:result-document href="{$staging-uri || pd:rel($uri)}" format="odd">
                <xsl:sequence select="$result"/>
              </xsl:result-document>
              <xsl:value-of select="'purified    ' || pd:rel($uri) || '  (' || $label || ')&#10;'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>

    <xsl:for-each select="$ctx-uris">
      <xsl:value-of select="'context     ' || pd:rel(.) || '  (read only)&#10;'"/>
    </xsl:for-each>

    <xsl:for-each-group select="$refs[@kind = 'none' or not(pd:is-local(@uri))]" group-by="string-join((@uri, @via), ' ')">
      <xsl:variable name="why" select="if (@kind = 'none') then @via
                                       else if (starts-with(@uri, 'file:')) then @via || ': missing or not well-formed'
                                       else @via || ': not a local file, not followed'"/>
      <xsl:value-of select="'external    ' || (if (@uri != '') then pd:rel(@uri) || '  ' else '')
                            || '(' || $why || '; in ' || string-join(distinct-values(current-group()/@from), ', ') || ')&#10;'"/>
    </xsl:for-each-group>
  </xsl:template>

</xsl:stylesheet>
