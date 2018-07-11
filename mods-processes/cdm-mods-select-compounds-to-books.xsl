<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm"
    exclude-result-prefixes="xs"  extension-element-prefixes="saxon"
    version="2.0">
    
    <!-- xsl stylesheet to show selective conversion of compound objects and children into books and book pages -->
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:strip-space elements="*"/>
    
    <!-- create key to identify parent records with for child cModel updates -->
    <xsl:key name="mods-by-pid" match="mods:mods" use="mods:identifier[@type = 'islandora']"/>
    
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
    
    
    <!-- Selectively change cmodel of compounds to books, and their children into pages. -->
    <xsl:template match="mods:mods/mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier[. = 'islandora:compoundCModel']" exclude-result-prefixes="#all">
        <!-- Here is where the selection takes place. xsl:when statements can be added to have multiple criteria. -->
        <xsl:choose>
            <!-- e.g. when the title of the MODS record contains 'scrapbook' it becomes a book -->
            <xsl:when test="../../mods:titleInfo/mods:title[contains(lower-case(.),'scrapbook')]">
                <identifier xmlns="http://www.loc.gov/mods/v3">islandora:bookCModel</identifier>
                <xsl:message>BOOOKIEEEEE!!!!</xsl:message>
            </xsl:when>
            <!-- if not it stays a compound -->
            <xsl:otherwise>
                <identifier xmlns="http://www.loc.gov/mods/v3">islandora:compoundCModel</identifier>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Selectively change children of compounds to pages of books. 
         YOUR CRITERIA MUST MATCH that used for compounds to books (preceding)
    -->
    <xsl:template match="mods:mods[mods:relatedItem[@otherType = 'isChildOf']]/mods:relatedItem[@otherType = 'islandoraCModel']/mods:identifier" exclude-result-prefixes="#all">
        <!-- When the parent of this child is being changed to a book cmodel, this child becomes page -->
        <!-- Get the parent ID -->
        <xsl:variable name="parent-id" select="normalize-space(ancestor::mods:mods/mods:relatedItem[@otherType = 'isChildOf']/mods:identifier/text())"/>
        <!-- Get the parent record for reference -->
        <xsl:variable name="parent-record" select="key('mods-by-pid',$parent-id,ancestor::mods:modsCollection)"/>
        <xsl:choose>
            <!-- Here is where the selection takes place. -->
            <xsl:when test="$parent-record/mods:titleInfo/mods:title[contains(lower-case(.),'scrapbook')]">
                <identifier xmlns="http://www.loc.gov/mods/v3">islandora:pageCModel</identifier>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | *| text() | comment() | processing-instruction()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- Selectively change the relationship to the parent record. 
         YOUR CRITERIA MUST MATCH that used for compounds to books (preceding)
    -->
    <xsl:template match="mods:mods/mods:relatedItem[@otherType = 'isChildOf']" exclude-result-prefixes="#all">
        <!-- When the parent of this child is being turned into a book, this relationship should be changed to isPageOf -->
        <!-- Get the parent ID -->
        <xsl:variable name="parent-id" select="normalize-space(mods:identifier/text())"/>
        <!-- Get the parent record for reference -->
        <xsl:variable name="parent-record" select="key('mods-by-pid',$parent-id,ancestor::mods:modsCollection)"/>
        <xsl:choose>
            <!-- Here is where the selection takes place. -->
            <xsl:when test="$parent-record/mods:titleInfo/mods:title[contains(lower-case(.),'scrapbook')]">
                <relatedItem xmlns="http://www.loc.gov/mods/v3" otherType="isPageOf">
                    <xsl:apply-templates select="@*[name() != 'otherType'] | * | text() | comment() | processing-instruction()"/>
                </relatedItem>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | * | text() | comment() | processing-instruction()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>