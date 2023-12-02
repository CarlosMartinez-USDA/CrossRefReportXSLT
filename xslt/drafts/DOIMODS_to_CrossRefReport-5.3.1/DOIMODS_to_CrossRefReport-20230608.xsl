<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:mods="http://www.loc.gov/mods/v3" 
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:f="http://functions"
    xmlns:isodates="http://iso"
    xmlns="http://www.crossref.org/schema/4.4.2"
    xsi:schemaLocation="http://www.crossref.org/schemas/crossref4.4.2.xsd"    
    exclude-result-prefixes="f xd xlink xs mods xsi isodates"    
    version="2.0"
    xpath-default-namespace="http://www.loc.gov/mods/v3"
    >    
    <xsl:output method="xml" indent="yes" encoding="UTF-8"  />
    
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Sep 5, 2019</xd:p>
            <xd:p><xd:b>Last updated: </xd:b> October 1, 2020</xd:p>
            <xd:p><xd:b>Author:</xd:b> Rachel Donahue and Amanda Xu</xd:p>
            <xd:p>Transform DOI MODS formatted files into CrossRef's report schema</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>Include external stylesheets.</xd:p>
            <xd:ul>
                <xd:li><xd:b>common.xsl:</xd:b> templates shared across all stylesheets</xd:li>
                <xd:li><xd:b>params.xsl:</xd:b> parameters shared across all stylesheets</xd:li>
                <xd:li><xd:b>functions.xsl: </xd:b>functions shared across all stylesheets</xd:li>
            </xd:ul>
        </xd:desc>
    </xd:doc>
    <xsl:include href="commons/common.xsl"/>
    <xsl:include href="commons/params.xsl"/>
    <xsl:include href="commons/functions.xsl"/>
    
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:p><xd:b>depositorName, depositorEmail</xd:b></xd:p>
            <xd:p>Parameters used to allow depositor name and email address to be set at run-time in oXygen, rather than hardcoding within the stylesheet.</xd:p>            
        </xd:desc>
    </xd:doc>
    <xsl:param name="depositorName"/>
    <xsl:param name="depositorEmail"/>
    
    <xd:doc>
        <xd:desc><xd:p>Function used to create a value for the timestamp element</xd:p></xd:desc>
    </xd:doc>
    
    <xsl:function name="f:createTimestamp">
        <xsl:variable name="date" select="adjust-date-to-timezone(current-date(), ())"/>
        <xsl:variable name="time" select="adjust-time-to-timezone(current-time(), ())"/>
        <xsl:variable name="tempdatetime" select="concat($date, '', $time)"/>
        <xsl:variable name="datetime" select="translate($tempdatetime, ':-.', '')"/>
        <xsl:value-of select="$datetime"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Add CrossRef's <xd:b>sequence</xd:b> attribute to names.</xd:p>
        </xd:desc>
        <xd:param name="theElement">The context element.</xd:param>
    </xd:doc>
    <xsl:function name="f:addSequence">
        <xsl:param name="theElement"/>
        <xsl:choose>
            <xsl:when test="$theElement/@usage = 'primary'">first</xsl:when>
            <xsl:otherwise>additional</xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Function to split a single w3cdtf/iso date into month, day, and year elements.</xd:p>
            <xd:p><xd:b>Usage:</xd:b> xsl:copy-of select="f:splitDates(.)</xd:p>
        </xd:desc>
        <xd:param name="dateString">The element with the date string</xd:param>
    </xd:doc>
    <xsl:function name="f:splitDates">
        <xsl:param name="dateString"/>
        <xsl:variable name="tokenizedDate" select="tokenize($dateString/text(), '-')"/>        
        <xsl:if test="count($tokenizedDate) > 1">
            <month><xsl:value-of select="$tokenizedDate[2]"/></month>
        </xsl:if>
        <xsl:if test="count($tokenizedDate) = 3">
            <day><xsl:value-of select="$tokenizedDate[3]"/></day>
        </xsl:if>
        <year><xsl:value-of select="$tokenizedDate[1]"/></year>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p><xd:b>mods</xd:b> must be in a separate template to prevent namespace problems</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">        
        <xsl:apply-templates select="mods"/>
    </xsl:template>
    
    
    <xsl:template match="/mods">
        <doi_batch xmlns:cr="http://www.crossref.org/schema/4.4.2" xsl:exclude-result-prefixes="cr">
            
            <xsl:namespace name="xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:namespace>
            <xsl:attribute name="xsi:schemaLocation">http://www.crossref.org/schema/4.4.2 http://www.crossref.org/schema/deposit/crossref4.4.2.xsd</xsl:attribute>
            <xsl:attribute name="version">4.4.2</xsl:attribute>
            <head>
                <doi_batch_id>
                    <xsl:value-of select="concat('report_paper', '-', current-dateTime())"/>
                </doi_batch_id>              
                
                <timestamp>
                    <xsl:value-of select="f:createTimestamp()"/>
                </timestamp>
                <depositor>
                    <depositor_name><xsl:value-of select="$depositorName"/></depositor_name>
                    <email_address><xsl:value-of select="$depositorEmail"/></email_address>
                </depositor>
                
                <registrant>National Agricultural Library</registrant>
            </head>
            
            <body>            
                <report-paper>
                    <report-paper_metadata>
                        <xsl:choose>
                            <xsl:when test="language/languageTerm[@type = 'code']">
                                <xsl:variable name="langCode" select="normalize-space(language/languageTerm[@type = 'code']/text())"/>
                                <xsl:attribute name="language"><xsl:value-of select="f:isoTwo2One($langCode)"/></xsl:attribute>
                            </xsl:when>
                        </xsl:choose>
                        <xsl:choose>
                            <xsl:when test="name">
                                <contributors>
                                    <xsl:apply-templates select="name" mode="contributor"/>
                                </contributors>
                            </xsl:when>
                        </xsl:choose>                        
                        <titles>
                            <xsl:apply-templates select="titleInfo/title"/>
                            <xsl:apply-templates select="titleInfo/subTitle"/>
                        </titles>
                        <xsl:apply-templates select="abstract"/>
                        <xsl:apply-templates select="originInfo/dateIssued[@encoding='w3cdtf']"/>
                        <xsl:apply-templates select="originInfo"/>
                        <xsl:apply-templates select="name[@type='corporate']"/>
                        <xsl:call-template name="doiData"/>
                    </report-paper_metadata>            
                </report-paper>            
            </body>
        </doi_batch>             
    </xsl:template>
    
    <xsl:template match="titleInfo/title">
        <title><xsl:value-of select="."/></title>
    </xsl:template>
    
    <xsl:template match="titleInfo/subTitle">
        <subtitle><xsl:value-of select="."/></subtitle>
    </xsl:template>
    
    <xsl:template match="name[@type='personal']" mode="contributor">        
        <person_name sequence="{f:addSequence(.)}">            
            <xsl:attribute name="contributor_role"><xsl:value-of select="lower-case(role/roleTerm)"/></xsl:attribute>
            <given_name><xsl:value-of select="namePart[@type='given']"/></given_name>
            <surname><xsl:value-of select="namePart[@type='family']"/></surname> 
            <xsl:apply-templates select="affiliation"/>
            <xsl:apply-templates select="nameIdentifier[@type='orcid']"/>
        </person_name>
    </xsl:template>
    
    <xsl:template match="name[@type='corporate']" mode="contributor">        
        <organization contributor_role="author" sequence="{f:addSequence(.)}"><xsl:value-of select="namePart"/></organization>
    </xsl:template>
    
    <xsl:template match="nameIdentifier[@type='orcid']">
        <ORCID><xsl:value-of select="."/></ORCID>
    </xsl:template>
    
    <xsl:template match="affiliation">
        <affiliation><xsl:value-of select="."/></affiliation>
    </xsl:template>
    
    <xsl:template match="name[@type='corporate']">
        <institution><institution_name><xsl:value-of select="namePart"/></institution_name></institution>
    </xsl:template>
    
    <xsl:template match="originInfo/dateIssued[@encoding='w3cdtf']">
        <publication_date media_type="online">
            <xsl:copy-of select="f:splitDates(.)"/>
        </publication_date>
    </xsl:template>
    
    <xsl:template match="originInfo">
        <publisher>
            <publisher_name><xsl:value-of select="publisher"/></publisher_name>
            <xsl:apply-templates select="place/placeTerm[@type='text']"/>
        </publisher>
    </xsl:template>
    
    <xsl:template match="place/placeTerm[@type='text']">
        <publisher_place><xsl:value-of select="."/></publisher_place>
    </xsl:template>
    
    <xsl:template match="abstract">
        <abstract xmlns="http://www.ncbi.nlm.nih.gov/JATS1">
            <p><xsl:value-of select="."/></p>
        </abstract>
    </xsl:template>
    
    <xsl:template name="doiData">
        <doi_data>
            <doi><xsl:value-of select="identifier[@type='doi']"/></doi>
            <resource><xsl:value-of select="extension/location/url[@displayLabel='CrossRef DOI Landing Page']"/></resource>
        </doi_data>
    </xsl:template>
</xsl:stylesheet>