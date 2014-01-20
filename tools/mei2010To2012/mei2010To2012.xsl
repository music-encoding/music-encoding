<?xml version="1.0" encoding="UTF-8"?>

<!--
Copyright (c) 2014, Peter Stadler
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this
  list of conditions and the following disclaimer in the documentation and/or
  other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-->

<xsl:stylesheet xmlns:mei="http://www.music-encoding.org/ns/mei"
    xmlns="http://www.music-encoding.org/ns/mei" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="2.0">
    <xsl:output indent="yes" encoding="UTF-8" method="xml" omit-xml-declaration="no"/>
    <xsl:param name="warning" select="true()"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="mei:accessdesc">
        <xsl:element name="accessRestrict">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:acqsource">
        <xsl:element name="acqSource">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:addressline">
        <xsl:element name="addrLine">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:altmeiid">
        <xsl:element name="altId">
            <xsl:apply-templates select="@*"/>
            <xsl:if test="$warning">
                <xsl:comment>Transformation for element "altmeiid" needs tweaking</xsl:comment>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:anchoredtext">
        <xsl:element name="anchoredText">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:appinfo">
        <xsl:element name="appInfo">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:barline">
        <xsl:element name="barLine">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:beamspan">
        <xsl:element name="beamSpan">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:beatrpt">
        <xsl:element name="beatRpt">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:blockquote">
        <xsl:element name="quote">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:btrem">
        <xsl:element name="bTrem">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:changedesc">
        <xsl:element name="changeDesc">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:chanpr">
        <xsl:element name="chanPr">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:chorddef">
        <xsl:element name="chordDef">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:chordmember">
        <xsl:element name="chordMember">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:chordtable">
        <xsl:element name="chordTable">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:classcode">
        <xsl:element name="classCode">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:clefchange">
        <xsl:element name="clef">
            <xsl:apply-templates select="@* except (@tstamp, @staff, @layer)"/>
            <xsl:if test="@tstamp or @staff or @layer">
                <xsl:if test="$warning">
                    <xsl:comment>attributes @tstamp, @staff, @layer not longer supported on mei:clef</xsl:comment>
                </xsl:if>
            </xsl:if>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:corpname">
        <xsl:element name="corpName">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:editionstmt">
        <xsl:element name="editionStmt">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:editorialdecl">
        <xsl:element name="editorialDecl">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:encodingdesc">
        <xsl:element name="encodingDesc">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:eventlist">
        <xsl:element name="eventList">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:exhibithist">
        <xsl:element name="exhibHist">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:extptr">
        <xsl:element name="ptr">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:extref">
        <xsl:element name="ref">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:figdesc">
        <xsl:element name="figDesc">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:filedesc">
        <xsl:element name="fileDesc">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:fingerprint">
        <xsl:if test="$warning">
            <xsl:comment>use of mei:fingerprint deprecated.</xsl:comment>
        </xsl:if>
    </xsl:template>

    <xsl:template match="mei:ftrem">
        <xsl:element name="fTrem">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:geogname">
        <xsl:element name="geogName">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:grpsym">
        <xsl:element name="grpSym">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:halfmrpt">
        <xsl:element name="halfmRpt">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:handlist">
        <xsl:element name="handList">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:handshift">
        <xsl:element name="handShift">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:harppedal">
        <xsl:element name="harpPedal">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:instrdef">
        <xsl:element name="instrDef">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:instrgrp">
        <xsl:element name="instrGrp">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:keyaccid">
        <xsl:element name="keyAccid">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:keysig">
        <xsl:element name="keySig">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:keywords">
        <xsl:element name="termList">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:langusage">
        <xsl:element name="langUsage">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:layerdef">
        <xsl:element name="layerDef">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:meicorpus">
        <xsl:element name="meiCorpus">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:meihead">
        <xsl:element name="meiHead">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:metatext">
        <xsl:element name="metaText">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:mrest">
        <xsl:element name="mRest">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:mrpt">
        <xsl:element name="mRpt">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:mrpt2">
        <xsl:element name="mRpt2">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:mspace">
        <xsl:element name="mSpace">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:multirest">
        <xsl:element name="multiRest">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:multirpt">
        <xsl:element name="multiRpt">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:noteoff">
        <xsl:element name="noteOff">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:noteon">
        <xsl:element name="noteOn">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:notesstmt">
        <xsl:element name="notesStmt">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:periodname">
        <xsl:element name="periodName">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:persname">
        <xsl:element name="persName">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="mei:pgdesc">
        <xsl:element name="pgDesc">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:pgfoot1">
        <xsl:element name="pgFoot">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:pgfoot2">
        <xsl:element name="pgFoot2">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:pghead1">
        <xsl:element name="pgHead">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:pghead2">
        <xsl:element name="pgHead2">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:physdesc">
        <xsl:element name="physDesc">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:physloc">
        <xsl:element name="physLoc">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:physmedium">
        <xsl:element name="physMedium">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:profiledesc">
        <xsl:element name="workDesc">
            <xsl:apply-templates select="@*"/>
            <xsl:element name="work">
                <xsl:if test="mei:creation or mei:eventlist">
                    <xsl:element name="history">
                        <xsl:apply-templates select="mei:creation | mei:eventlist"/>
                    </xsl:element>
                </xsl:if>
                <xsl:apply-templates select="mei:langusage"/>
                <xsl:apply-templates select="mei:classification"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:projectdesc">
        <xsl:element name="projectDesc">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:pubstmt">
        <xsl:element name="pubStmt">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:respstmt">
        <xsl:element name="respStmt">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:revisiondesc">
        <xsl:element name="revisionDesc">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:samplingdecl">
        <xsl:element name="samplingDecl">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:scoredef">
        <xsl:element name="scoreDef">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:seqnum">
        <xsl:element name="seqNum">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:seriesstmt">
        <xsl:element name="seriesStmt">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:sourcedesc">
        <xsl:element name="sourceDesc">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:staffdef">
        <xsl:element name="staffDef">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:staffgrp">
        <xsl:element name="staffGrp">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:stdvals">
        <xsl:element name="stdVals">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:stylename">
        <xsl:element name="styleName">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:symboldef">
        <xsl:element name="symbolDef">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:symboltable">
        <xsl:element name="symbolTable">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:sysreq">
        <xsl:element name="sysReq">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:titlepage">
        <xsl:element name="titlePage">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:titlestmt">
        <xsl:element name="titleStmt">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:treatmenthist">
        <xsl:element name="treatHist">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:treatmentsched">
        <xsl:element name="treatSched">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:trkname">
        <xsl:element name="trkName">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:tupletspan">
        <xsl:element name="tupletSpan">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="mei:userestrict">
        <xsl:element name="useRestrict">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="@complete"><!--to do--></xsl:template>
    <xsl:template match="@entityref"><!--to do--></xsl:template>
    <xsl:template match="@href"><!--to do--></xsl:template>
    <xsl:template match="@id">
        <xsl:attribute name="xml:id" select="."/>
    </xsl:template>
    <xsl:template match="@label.full"><!--to do--></xsl:template>
    <xsl:template match="@lang">
        <xsl:attribute name="xml:lang" select="."/>
    </xsl:template>
    <xsl:template match="@mediacontent"><!--to do--></xsl:template>
    <xsl:template match="@medialength"><!--to do--></xsl:template>
</xsl:stylesheet>
