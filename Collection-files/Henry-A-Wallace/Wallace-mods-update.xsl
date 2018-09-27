<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:saxon="http://saxon.sf.net/"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:cdm="http://www.oclc.org/contentdm"
    exclude-result-prefixes="xs"  extension-element-prefixes="saxon"
    version="2.0">
    
    <!-- Template for cleanup of ContentDM-to-MODS crosswalk output prior to ingest to Islandora.  -->
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:strip-space elements="*"/>
    
    
    <!-- identity transform to copy through all nodes (except those with specific templates modifying them) -->    
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
    
    <!-- updates -->
    <!-- fix values of typeOfResource to conform to MODS schema. -->
    <!-- To date only case issues -->
    <xsl:template match="mods:typeOfResource" exclude-result-prefixes="#all">
        <typeOfResource xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="lower-case(normalize-space(.))"/></typeOfResource>
    </xsl:template>
    
    <!-- simultaneous cleanup of subjects with more than one topic and topic values that need to be split -->
    <xsl:template match="mods:subject[mods:topic and not(mods:name)]" exclude-result-prefixes="#all">
        <xsl:variable name="subject-attributes" select="@*"/>
        <xsl:for-each select="mods:topic">
            <xsl:for-each select="tokenize(.,';')">
                <subject xmlns="http://www.loc.gov/mods/v3">
                    <xsl:copy-of select="$subject-attributes"/>
                    <topic><xsl:value-of select="normalize-space(.)"/></topic>
                </subject>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="mods:subject[not(mods:topic) and mods:name]" exclude-result-prefixes="#all">
        <xsl:variable name="subject-attributes" select="@*"/>
        <xsl:for-each select="mods:name/mods:namePart[normalize-space()]">
            <xsl:variable name="namepart-siblings" select="*[not(self::mods:namePart)]"/>
            <xsl:for-each select="tokenize(.,';')">
                <subject xmlns="http://www.loc.gov/mods/v3">
                    <xsl:copy-of select="$subject-attributes"/>
                    <name>
                        <namePart><xsl:value-of select="normalize-space(.)"/></namePart>
                        <!-- each name should include the namepart siblings -->
                        <xsl:apply-templates select="$namepart-siblings"/>
                    </name>
                </subject>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>   
    
    <!--  
             whether ';' present or not, tokenizing on it will work correctly
             this approach negates approach using multiple templates to handle
             multiple namePart and nameParts with ';'
        -->
    <xsl:template match="mods:mods/mods:name[mods:namePart[normalize-space()]]" exclude-result-prefixes="#all">
        <xsl:variable name="name-attributes" select="@*"/>
        <!-- store sibling elements, e.g. role -->
        <xsl:variable name="namepart-siblings" select="*[not(self::mods:namePart)]"/>
        <xsl:for-each select="mods:namePart">
            <xsl:for-each select="tokenize(.,';')">
                <name xmlns="http://www.loc.gov/mods/v3">
                    <xsl:copy-of select="$name-attributes"/>
                    <namePart><xsl:value-of select="normalize-space(.)"/></namePart>
                    <!-- each name should include the namepart siblings -->
                    <xsl:apply-templates select="$namepart-siblings"/>
                </name>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <!--to tokenize temporal subjects-->
    <xsl:template match="mods:subject[mods:temporal]" exclude-result-prefixes="#all">
        <xsl:variable name="subject-attributes" select="@*"/>
        <xsl:for-each select="mods:temporal">
            <xsl:for-each select="tokenize(.,';')">
                <subject xmlns="http://www.loc.gov/mods/v3">
                    <xsl:copy-of select="$subject-attributes"/>
                    <temporal><xsl:value-of select="normalize-space(.)"/></temporal>
                </subject>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>  
    
    <!--to tokenize geographic subjects-->
    <xsl:template match="mods:subject[mods:geographic]" exclude-result-prefixes="#all">
        <xsl:variable name="subject-attributes" select="@*"/>
        <xsl:for-each select="mods:geographic">
            <xsl:for-each select="tokenize(.,';')">
                <subject xmlns="http://www.loc.gov/mods/v3">
                    <xsl:copy-of select="$subject-attributes"/>
                    <geographic><xsl:value-of select="normalize-space(.)"/></geographic>
                </subject>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>         
    
    <!--   to tokenize genre-->
    <xsl:template match="mods:genre" exclude-result-prefixes="#all">
        <xsl:variable name="genre-attributes" select="@*"/>
        <xsl:for-each select="tokenize(.,';')">
            <genre xmlns="http://www.loc.gov/mods/v3">
                <xsl:copy-of select="$genre-attributes"/>
                <xsl:value-of select="normalize-space(.)"/>
            </genre>
        </xsl:for-each>
    </xsl:template>
    
    <!--   to tokenize publishers -->
    <xsl:template match="mods:originInfo[mods:publisher]" exclude-result-prefixes="#all">
        <xsl:variable name="originInfo-attributes" select="@*"/>
        <xsl:for-each select="mods:publisher">
            <xsl:for-each select="tokenize(.,';')">
                <originInfo xmlns="http://www.loc.gov/mods/v3">
                    <xsl:copy-of select="$originInfo-attributes"/>
                    <publisher><xsl:value-of select="normalize-space(.)"/></publisher>
                </originInfo>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    
    
    <!-- conflate latitude and longitude into a single /mods/subject/cartographics/coordinates
         Note that this relies on the mapping having both in the same /mods/subject, and in the correct order.
    -->
    <xsl:template match="mods:subject[count(mods:cartographics/mods:coordinates[normalize-space()]) = 2]" exclude-result-prefixes="#all">
        <subject xmlns="http://www.loc.gov/mods/v3">
            <cartographics>
                <coordinates><xsl:value-of select="concat(mods:cartographics/mods:coordinates[1],', ',mods:cartographics/mods:coordinates[2])"/></coordinates>
            </cartographics>
        </subject>
    </xsl:template>
    
    <!-- demo geo parsing -->
    <xsl:template match="mods:subject/mods:geographic" exclude-result-prefixes="#all">
        <xsl:variable name="geo-raw" select="normalize-space(.)"/>
        <xsl:variable name="geo-cooked" select="replace($geo-raw,'\s*--\s*','--')"/>
        <xsl:variable name="token-count" select="count(tokenize($geo-cooked,'--'))"/>
        <xsl:choose> 
            <xsl:when test="$token-count = 4">
                <hierarchicalGeographic xmlns="http://www.loc.gov/mods/v3">
                    <country><xsl:value-of select="tokenize($geo-cooked,'--')[1]"/></country>
                    <state><xsl:value-of select="tokenize($geo-cooked,'--')[2]"/></state>
                    <county><xsl:value-of select="tokenize($geo-cooked,'--')[3]"/></county>
                    <city><xsl:value-of select="tokenize($geo-cooked,'--')[4]"/></city>
                </hierarchicalGeographic>
            </xsl:when>
            <xsl:when test="$token-count = 3">
                <hierarchicalGeographic xmlns="http://www.loc.gov/mods/v3">
                    <country><xsl:value-of select="tokenize($geo-cooked,'--')[1]"/></country>
                    <state><xsl:value-of select="tokenize($geo-cooked,'--')[2]"/></state>
                    <city><xsl:value-of select="tokenize($geo-cooked,'--')[3]"/></city>
                </hierarchicalGeographic>
            </xsl:when>
            <xsl:when test="$token-count = 2">
                <hierarchicalGeographic xmlns="http://www.loc.gov/mods/v3">
                    <country><xsl:value-of select="tokenize($geo-cooked,'--')[1]"/></country>
                    <state><xsl:value-of select="tokenize($geo-cooked,'--')[2]"/></state>
                </hierarchicalGeographic>
            </xsl:when>
            
            <!-- always have default processing -->
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | *| text() | comment() | processing-instruction()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- child objects should have title of their parents -->
    <xsl:template match="mods:mods[mods:relatedItem[@otherType = 'isChildOf']]/mods:titleInfo/mods:title" exclude-result-prefixes="#all">
        <!-- get parent title -->
        <xsl:variable name="parent-id" select="ancestor::mods:mods/mods:relatedItem[@otherType = 'isChildOf']/mods:identifier"/>
        <xsl:variable name="parent-title" select="ancestor::mods:modsCollection/mods:mods[mods:identifier[@type = 'islandora'][. = $parent-id]]/mods:titleInfo[not(@type)][1]/mods:title"/>
        <title xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="$parent-title"/></title>
    </xsl:template>
    
    <!-- target collections in the uni namespace -->
    <xsl:template match="mods:relatedItem[@otherType='islandoraCollection']/mods:identifier" exclude-result-prefixes="#all">
        <identifier xmlns="http://www.loc.gov/mods/v3"><xsl:value-of select="replace(.,'islandora:','uni:')"/></identifier>
    </xsl:template>
    
    <!-- conflate height and width? Unit = inches -->
    <xsl:template match="mods:physicalDescription[mods:extent[@unit = 'height'][normalize-space()] and mods:extent[@unit = 'width'][normalize-space()]]" exclude-result-prefixes="#all">
        <!--<xsl:template match="mods:physicalDescription/mods:extent" exclude-result-prefixes="#all">-->
        <physicalDescription xmlns="http://www.loc.gov/mods/v3">
            <!-- process all other children -->
            <xsl:apply-templates select="*[not(self::mods:extent[matches(@unit,'(height|width)')])]"/>
            <!-- build new extent -->
            <!--<extent><xsl:value-of select="concat(mods:physicalDescription/mods:extent[1],' x ',mods:physicalDescription/mods:extent[2], ' cm')"/></extent>-->
            
            <extent><xsl:value-of select="concat(mods:extent[@unit = 'height'], ' × ', mods:extent[@unit = 'width'], ' inches')"/></extent>
        </physicalDescription>
    </xsl:template>
    <!--</xsl:template>-->
    
    <!-- remove some empty elements -->
    <xsl:template match="mods:name[not(mods:namePart[normalize-space()])]
        | mods:genre[not(normalize-space())]
        | mods:extent[not(normalize-space())]
        | mods:physicalDescription[not(*[normalize-space()])]
        | mods:subject[mods:cartographics][not(mods:cartographics/mods:coordinates[normalize-space()])]
        | mods:typeOfResource[not(normalize-space())]
        | mods:language[not(mods:languageTerm[normalize-space()])]
        | mods:relatedItem/mods:extension/*:FULLTEXT[not(normalize-space())]
        | mods:accessCondition[not(normalize-space())]
        | mods:note[not(normalize-space())]
        | mods:relatedItem[@type = 'host'][mods:identifier[@type = 'collectionName'] or not(*)]
        | mods:relatedItem[@otherType = 'FULLTEXTDatastream'][normalize-space(mods:extension) = '']"/>
</xsl:stylesheet> 
