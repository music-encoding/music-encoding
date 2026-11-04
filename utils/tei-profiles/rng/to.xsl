<?xml version="1.0" encoding="UTF-8"?>
<!--
  MEI profile for the TEI Stylesheets' ODD to RELAX NG conversion.

  Picked up by lib/stylesheets/rng/build-to.xml via
  ${profiledir}/${profile}/rng/to.xsl (see target build-rng in build.xml).
  Imports the TEI's odd2relax.xsl and overrides templates where MEI needs
  different behaviour.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:rng="http://relaxng.org/ns/structure/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:tools="no:where"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="#all" version="3.0">

  <!-- import base conversion style -->
  <xsl:import href="../../../lib/stylesheets/odds/odd2relax.xsl"/>

  <!--
    Fix for pass4 cleanup in odd2relax.xsl: the original template only checks
    for direct rng:value / rng:name children, so a choice that merely wraps
    other choices of values gets replaced by rng:empty. This happens whenever a
    dataSpec's content is an alternate of dataRefs pointing to closed valLists
    (e.g. data.DURATION → data.DURATION.cmn | data.DURATION.mensural).
    Here descendants are taken into account, too.
  -->
  <xsl:template match="rng:choice[.//rng:value or .//rng:name] | rng:group[.//rng:value or .//rng:name]" mode="pass4">
    <xsl:element name="{name()}" namespace="http://relaxng.org/ns/structure/1.0">
      <xsl:apply-templates mode="pass4" select="*|@*|processing-instruction()|comment()|text()"/>
    </xsl:element>
  </xsl:template>

  <!--
    Keep datatypes as named patterns: odd2relax.xsl replaces every
    dataRef/@key with the content of the referenced dataSpec (inlining), so
    the dataSpec definitions end up unused and get zapped. Instead, emit a
    reference to the dataSpec's define (prefixed like teiodds.xsl names it).
    Inlining is still needed when a restriction applies, as a pattern facet
    can only be attached to rng:data, not to a rng:ref; in that case and for
    undefined keys fall back to the original template.
  -->
  <xsl:template match="tei:dataRef[@key]" mode="#default tangle">
    <xsl:param name="restriction"/>
    <xsl:variable name="spec" select="key('LOCALIDENTS', @key)[self::tei:dataSpec][1]"/>
    <xsl:choose>
      <xsl:when test="$spec and not(@restriction) and not($restriction)">
        <rng:ref name="{if ($spec/@prefix) then $spec/@prefix else $generalPrefix}{@key}"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match>
          <xsl:with-param name="restriction" select="$restriction"/>
        </xsl:next-match>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Remove redundant rng:group wrappers. odd2relax.xsl maps every tei:sequence
    to rng:group, even where the parent pattern already groups its children
    implicitly (RELAX NG spec, section 4.12), e.g.
      <zeroOrMore><group>a b*</group></zeroOrMore>
    instead of
      <zeroOrMore>a b*</zeroOrMore>
    Both forms are equivalent; this only shortens the output.

    This runs on the result of pass4 for each define, i.e. after the TEI
    cleanup has unwrapped or killed patterns, so the rules see the final
    tree. A group is dropped when
      1. it has exactly one pattern child (allowed in any context), or
      2. its effective parent groups its children implicitly. Sequence is
         associative, so this is safe whatever the siblings are.
    Groups under choice, interleave, attribute, start and except are kept
    whenever they have more than one pattern child, because there they
    hold the sequence together as one unit.
  -->
  <xsl:template match="rng:define" mode="pass4">
    <xsl:variable name="result">
      <xsl:next-match/>
    </xsl:variable>
    <xsl:apply-templates select="$result/node()" mode="tools:flattenGroups"/>
  </xsl:template>

  <xsl:template match="node() | @*" mode="tools:flattenGroups">
    <xsl:copy>
      <xsl:apply-templates select="node() | @*" mode="tools:flattenGroups"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="rng:group[tools:isRedundantGroup(.)]" mode="tools:flattenGroups">
    <xsl:apply-templates select="node()" mode="tools:flattenGroups"/>
  </xsl:template>

  <!-- patterns whose child patterns form an implicit group -->
  <xsl:variable name="tools:implicitGroupContexts" as="xs:string+"
    select="('group', 'zeroOrMore', 'oneOrMore', 'optional', 'element', 'define', 'list', 'mixed')"/>

  <xsl:function name="tools:isRedundantGroup" as="xs:boolean">
    <xsl:param name="group" as="element(rng:group)"/>
    <xsl:variable name="context" select="tools:effectiveParent($group)"/>
    <xsl:sequence select="count($group/rng:*) eq 1
      or ($context instance of element() and namespace-uri($context) eq 'http://relaxng.org/ns/structure/1.0'
          and local-name($context) = $tools:implicitGroupContexts)"/>
  </xsl:function>

  <!--
    The parent a group's content ends up in: climbs past ancestor groups that
    are dropped themselves, so a group(a, b) inside a dropped single-child
    group inside a choice is seen as a child of the choice and kept.
  -->
  <xsl:function name="tools:effectiveParent" as="node()?">
    <xsl:param name="node" as="element()"/>
    <xsl:variable name="parent" select="$node/.."/>
    <xsl:sequence select="if ($parent instance of element(rng:group) and tools:isRedundantGroup($parent))
      then tools:effectiveParent($parent)
      else $parent"/>
  </xsl:function>

</xsl:stylesheet>
