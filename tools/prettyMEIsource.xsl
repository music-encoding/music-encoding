<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
  xmlns:mei="http://www.music-encoding.org/ns/mei" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema">

  <!-- This stylesheet sorts mei-source. -->

  <xsl:template match="/">
    <xsl:apply-templates mode="copy"/>
  </xsl:template>

  <xsl:template match="schemaSpec" mode="copy">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:text>&#xa;&#xa;</xsl:text>
      <xsl:comment>
        <xsl:text> MODULES </xsl:text>
      </xsl:comment>
      <xsl:apply-templates select="moduleSpec" mode="copy">
        <xsl:sort select="@ident"/>
      </xsl:apply-templates>

      <xsl:text>&#xa;&#xa;</xsl:text>
      <xsl:comment>
        <xsl:text> PARAMETER ENTITIES </xsl:text>
      </xsl:comment>
      <xsl:apply-templates select="macroSpec[@type='pe']" mode="copy">
        <xsl:sort select="translate(@ident, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
          'abcdefghijklmnopqrstuvwxyz')"/>
      </xsl:apply-templates>

      <!--<xsl:for-each-group select="macroSpec[@type='pe']" group-by="@module">
      <xsl:sort select="translate(@module,'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        'abcdefghijklmnopqrstuvwxyz')"/>
      <xsl:text>&#xa;&#xa;</xsl:text>
      <xsl:comment>
        <xsl:value-of select="concat(' ', @module, ' ')"/>
      </xsl:comment>
      <xsl:apply-templates select="current-group()" mode="copy">
        <xsl:sort select="translate(@ident, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
          'abcdefghijklmnopqrstuvwxyz')"/>
      </xsl:apply-templates>
    </xsl:for-each-group>-->

      <xsl:text>&#xa;&#xa;</xsl:text>
      <xsl:comment>
        <xsl:text> DATATYPES </xsl:text>
      </xsl:comment>
      <xsl:apply-templates select="macroSpec[@type='dt']" mode="copy">
        <xsl:sort select="translate(@ident, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
          'abcdefghijklmnopqrstuvwxyz')"/>
      </xsl:apply-templates>

      <!--<xsl:for-each-group select="macroSpec[@type='dt']" group-by="@module">
      <xsl:sort select="translate(@module,'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        'abcdefghijklmnopqrstuvwxyz')"/>
      <xsl:text>&#xa;&#xa;</xsl:text>
      <xsl:comment>
        <xsl:value-of select="concat(' ', @module, ' ')"/>
      </xsl:comment>
      <xsl:apply-templates select="current-group()" mode="copy">
        <xsl:sort select="translate(@ident, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
          'abcdefghijklmnopqrstuvwxyz')"/>
      </xsl:apply-templates>
    </xsl:for-each-group>-->

      <xsl:text>&#xa;&#xa;</xsl:text>
      <xsl:comment>
        <xsl:text> ATTRIBUTE CLASSES </xsl:text>
      </xsl:comment>
      <xsl:apply-templates select="classSpec[@type='atts']" mode="copy">
        <xsl:sort select="translate(@ident, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
          'abcdefghijklmnopqrstuvwxyz')"/>
      </xsl:apply-templates>

      <!--<xsl:for-each-group select="classSpec[@type='atts']" group-by="@module">
      <xsl:sort select="translate(@module,'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        'abcdefghijklmnopqrstuvwxyz')"/>
      <xsl:text>&#xa;&#xa;</xsl:text>
      <xsl:comment>
        <xsl:value-of select="concat(' ', @module, ' ')"/>
      </xsl:comment>
      <xsl:apply-templates select="current-group()" mode="copy">
        <xsl:sort select="translate(@ident, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
          'abcdefghijklmnopqrstuvwxyz')"/>
      </xsl:apply-templates>
    </xsl:for-each-group>-->

      <xsl:text>&#xa;&#xa;</xsl:text>
      <xsl:comment>
        <xsl:text> MODEL CLASSES </xsl:text>
      </xsl:comment>
      <xsl:apply-templates select="classSpec[@type='model']" mode="copy">
        <xsl:sort select="translate(@ident, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
          'abcdefghijklmnopqrstuvwxyz')"/>
      </xsl:apply-templates>

      <!--<xsl:for-each-group select="classSpec[@type='model']" group-by="@module">
      <xsl:sort select="translate(@module,'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        'abcdefghijklmnopqrstuvwxyz')"/>
      <xsl:text>&#xa;&#xa;</xsl:text>
      <xsl:comment>
        <xsl:value-of select="concat(' ', @module, ' ')"/>
      </xsl:comment>
      <xsl:apply-templates select="current-group()" mode="copy">
        <xsl:sort select="translate(@ident, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
          'abcdefghijklmnopqrstuvwxyz')"/>
      </xsl:apply-templates>
    </xsl:for-each-group>-->

      <xsl:text>&#xa;&#xa;</xsl:text>
      <xsl:comment>
        <xsl:text> ELEMENTS </xsl:text>
      </xsl:comment>
      <xsl:apply-templates select="elementSpec" mode="copy">
        <xsl:sort select="translate(@ident, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
          'abcdefghijklmnopqrstuvwxyz')"/>
      </xsl:apply-templates>

      <!--<xsl:for-each-group select="elementSpec" group-by="@module">
      <xsl:sort select="translate(@module,'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        'abcdefghijklmnopqrstuvwxyz')"/>
      <xsl:text>&#xa;&#xa;</xsl:text>
      <xsl:comment>
        <xsl:value-of select="concat(' ', @module, ' ')"/>
      </xsl:comment>
      <xsl:apply-templates select="current-group()" mode="copy">
        <xsl:sort select="translate(@ident, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
          'abcdefghijklmnopqrstuvwxyz')"/>
      </xsl:apply-templates>
    </xsl:for-each-group>-->

    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()" mode="copy">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="copy"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
