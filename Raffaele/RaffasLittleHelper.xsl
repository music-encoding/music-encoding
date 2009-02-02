<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <!-- RV 02/09 -->
    <!-- THIS SCRIPT IS HELPING ME TO CLEANUP MY MEI FILE FOR SYRINX -->
    <!-- THERE ARE TWO STEPS, EACH ONE OPERATES ON THE OUTPUT OF THE PREVIOUS -->
    <!-- STEP 1: Fix ids and store old ones for correspondances 
         STEP 2: id correspondances (hairpin, tuplet2, dynam), Beams, simple handling of slurs attributes from phrase elements -->
    
    <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
    <xsl:strip-space elements="*"/>
    
    <!--Remember to turn off the DTD before running the LittleHelper! -->
    
    <!-- Global variables -->
    <xsl:variable name="step1">
        <xsl:call-template name="one"/>
    </xsl:variable>
    <xsl:variable name="step2">
        <xsl:apply-templates select="$step1" mode="step2"/>
    </xsl:variable>
    
    <!-- STEP 1 -->
    <!-- Fix ids and store old ones for correspondances -->
    
    <!-- Generic copy-everything template (adapted from TEI wiki)-->
    <xsl:template match="*|@*|processing-instruction()|comment()" mode="step1">
        <xsl:copy>
            <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()" mode="step1"/>
        </xsl:copy>
    </xsl:template>  
    
    <!-- fix ids in measures -->
    <xsl:template match="measure" mode="step1">
        <xsl:variable name="measureNum" select="@n"/>
        <measure>
            <xsl:sequence select="@*[not(local-name()='id')]"/>
            <xsl:attribute name="old_id" select="@id"/>
            <xsl:attribute name="id">
                <xsl:text>m</xsl:text><xsl:value-of select="$measureNum"/>
            </xsl:attribute>
            <xsl:apply-templates mode="step1"/>
        </measure>
    </xsl:template>
    
    <!-- fix ids in notes -->
    <xsl:template match="note" mode="step1">
        <xsl:variable name="measureNum" select="ancestor::measure/@n"/>
        <xsl:variable name="cur_measure" select="generate-id(ancestor::measure)"/>
        <note>
            <xsl:sequence select="@*[not(local-name()='id')]"/> 
            <xsl:attribute name="old_id" select="@id"/>
            <xsl:attribute name="id">
                <xsl:text>m</xsl:text><xsl:value-of select="$measureNum"/>n<xsl:value-of select="count(preceding::note[generate-id(ancestor::measure) = $cur_measure])+1"/>
            </xsl:attribute>
            <xsl:apply-templates mode="step1"/>
        </note>
    </xsl:template>
    
    <xsl:template name="one">
        <xsl:apply-templates select="/" mode="step1"/>
    </xsl:template>
    
    <!-- STEP 2 -->
    <!-- id correspondances (hairpin, tuplet2, dynam), Beams, Phrases. -->
    
    <!-- Generic copy-everything template (adapted from TEI wiki)-->
    <xsl:template match="*|@*|processing-instruction()|comment()" mode="step2">
        <xsl:choose>
            <xsl:when test="name() = 'old_id' or name() = 'def'"></xsl:when>
           <xsl:otherwise> 
               <xsl:copy>
                    <xsl:apply-templates select="*|@*|text()|processing-instruction()|comment()" mode="step2"/>
               </xsl:copy>
           </xsl:otherwise>
        </xsl:choose>
    </xsl:template>  
    
    <!-- amend the id correspondances in hairpins, tuplets2 and dynam and clean up -->
    <xsl:template match="haripin" mode="step2">
        <hairpin>
            <xsl:for-each select="@*">
                <xsl:if test="local-name() != 'start' or local-name() != 'end' or local-name() != 'y1'
                           or local-name() != 'dur' or local-name() != 'width'">
                    <xsl:sequence select="."/>
                </xsl:if>
            </xsl:for-each>
            <xsl:if test="@start">
                <xsl:attribute name="startid">
                    <xsl:value-of select="ancestor::measure//note[@old_id=.]/@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@end">
                <xsl:attribute name="endid">
                    <xsl:value-of select="ancestor::measure//note[@old_id=.]/@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates mode="step2"/>
        </hairpin>
    </xsl:template>
    
    <xsl:template match="tuplet2" mode="step2">
        <tuplet2>
            <xsl:for-each select="@*">
                <xsl:if test="local-name() != 'start' or local-name() != 'end' or local-name() != 'num.visible'">
                    <xsl:sequence select="."/>
                </xsl:if>
            </xsl:for-each>
           
            <xsl:if test="@start">
                <xsl:attribute name="startid">
                    <xsl:value-of select="ancestor::measure//note[@old_id=.]/@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@end">
                <xsl:attribute name="endid">
                    <xsl:value-of select="ancestor::measure//note[@old_id=.]/@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="num.visible">
                <xsl:choose>
                    <xsl:when test="@num.visible = 'yes'">
                            <xsl:text>true</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                           <xsl:text>false</xsl:text> 
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates mode="step2"/>
        </tuplet2>
    </xsl:template>
    
    <xsl:template match="dynam" mode="step2">
        <dynam>
            <xsl:for-each select="@*">
                <xsl:if test="local-name() != 'start' or local-name() != 'end'">
                    <xsl:sequence select="."/>
                </xsl:if>
            </xsl:for-each>
           
            <xsl:if test="@start">
                <xsl:attribute name="startid">
                    <xsl:value-of select="ancestor::measure//note[@old_id=.]/@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:if test="@end">
                <xsl:attribute name="endid">
                    <xsl:value-of select="ancestor::measure//note[@old_id=.]/@id"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates mode="step2"/>
        </dynam>
    </xsl:template>
    
    <!-- Change beams from elements to attributes (works fine with Syrinx because there aren't beams over measure breaks)-->
    <xsl:template match="beam" mode="step2">
        
        <xsl:for-each select="note">
            <xsl:variable name="old_id" select="@old_id"/>
            
                <note>
                    <xsl:choose>
                        <xsl:when test="@slur">
                            <xsl:sequence select="@*[not(local-name()='old_id')]"/>
                            <xsl:attribute name="beam">
                                <xsl:choose>
                                    <xsl:when test="not(preceding-sibling::note)">
                                        <xsl:text>i1</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="not(following-sibling::note)">
                                        <xsl:text>f1</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>m1</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:apply-templates mode="step2"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="@*[not(local-name()='old_id')]"/>
                            <xsl:attribute name="beam">
                                <xsl:choose>
                                    <xsl:when test="not(preceding-sibling::note)">
                                        <xsl:text>i1</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="not(following-sibling::note)">
                                        <xsl:text>f1</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>m1</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            
                                <xsl:for-each select="ancestor::measure/phrase">
                                    <xsl:choose>
                                        <xsl:when test="@start = $old_id">
                                            <xsl:attribute name="slur"><xsl:text>i1</xsl:text></xsl:attribute>
                                        </xsl:when>
                                        <xsl:when test="@end = $old_id">
                                            <xsl:attribute name="slur"><xsl:text>f1</xsl:text></xsl:attribute>
                                        </xsl:when>
                                    </xsl:choose>
                                    
                                </xsl:for-each>
                            
                            <xsl:apply-templates mode="step2"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </note>
            
        </xsl:for-each>
    </xsl:template>
  
    

    <!-- OUTPUTTING -->
    
    <xsl:template match="/">
        <xsl:sequence select="$step2"/>
    </xsl:template>


</xsl:stylesheet>
