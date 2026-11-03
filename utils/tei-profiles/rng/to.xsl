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

</xsl:stylesheet>
