<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm"
    exclude-result-prefixes="xs"  extension-element-prefixes="saxon"
    version="2.0">
    
    <!-- Template to change subcollections to compounds. -->
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>

    <xsl:strip-space elements="*"/>
    
    <!-- change collections to compound parents -->
    <xsl:template match="mods:relatedItem[@otherType = 'islandoraCModel'][. = 'islandora:collectionCModel']/mods:identifier" exclude-result-prefixes="#all">
        <identifier xmlns="http://www.loc.gov/mods/v3">islandora:compoundCModel</identifier>
    </xsl:template>
    
    <!-- change any object not mapping to the root collection by modifying its collection membership 
         to an isChildOf relationship -->
    <!-- subcollection PIDS always contain '_' so this is the test. -->
    <xsl:template match="mods:mods/mods:relatedItem[@otherType = 'islandoraCollection']" exclude-result-prefixes="#all">
        <xsl:choose>
            <xsl:when test="matches(mods:identifier,'_')">
                <relatedItem xmlns="http://www.loc.gov/mods/v3" otherType="isChildOf">
                    <xsl:copy-of select="mods:identifier"/>
                </relatedItem>
            </xsl:when>
            <xsl:otherwise><xsl:copy-of select="."/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- identity transform to copy through all nodes (except those with specific templates modifying them -->    
    <xsl:template match="/" exclude-result-prefixes="#all">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="* | @*" exclude-result-prefixes="#all">
        <xsl:copy>
            <xsl:apply-templates select="@* | *| text() | comment() | processing-instruction()"/>
        </xsl:copy>
    </xsl:template>

    <!-- keep comments and PIs						-->
    <xsl:template match="comment() | processing-instruction()">
        <xsl:copy-of select="."/>
    </xsl:template>
    
   
</xsl:stylesheet>
