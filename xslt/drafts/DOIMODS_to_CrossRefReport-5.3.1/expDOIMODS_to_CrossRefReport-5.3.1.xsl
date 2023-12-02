<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns="http://www.crossref.org/schema/5.3.1" xmlns:cr="http://www.crossref.org/schema/5.3.1"
    xmlns:f="http://functions" xmlns:fr="http://www.crossref.org/fundref.xsd" xmlns:isodates="http://iso" 
    xmlns:jats="http://www.ncbi.nlm.nih.gov/JATS1"  xmlns:local="http://www.local.gov/namespace" 
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://www.crossref.org/schema/5.3.1 http://www.crossref.org/schemas/crossref5.3.1.xsd"
    exclude-result-prefixes="cr f fr isodates jats local mml mods xd xlink xs xsi"
    xpath-default-namespace="http://www.loc.gov/mods/v3">

    <xsl:output version="1.0" encoding="UTF-8" method="xml" indent="yes" name="CrossRef"/>
    <xsl:strip-space elements="*"/>
        
   
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b>Sep 5, 2019</xd:p>
            <xd:p><xd:b>Authors:</xd:b> Rachel Donahue, Amanda Xu and Carlos Martinez</xd:p>
            <xd:ul>
                <xd:li><xd:p><xd:b>Maintenance note:</xd:b>10/24/2023, Added revision log.</xd:p></xd:li>
                <xd:li><xd:p>October 1, 2020</xd:p></xd:li>
                <xd:li><xd:p>October 24, 2023</xd:p></xd:li>
            </xd:ul>
            <xd:p>Transform DOI MODS formatted files into CrossRef's report schema</xd:p>
        </xd:desc>
    </xd:doc>
   
    <!-- 
       Revision Log: Increment each revision, briefly describe the change, initial and date.
    
        Revision 1.10 - Commented out <institution_name>. Information is redundant to publisher_name. 
        Revision 1.09 - Predicate @eventType added to originInfo to get publisher info
        Revision 1.08 - Conditionals and modes added to choose between corporate body and contributors 
	    Revision 1.07 - Added conditional processing for modsCollection and for single mods documents
	    Revision 1.06 - Created call-template "head" for non-matching elements 
	    Revision 1.05 - Added "fr jats mml" namespaces to header based on "best-practice-examples/report.5.3.0.xml"
		Revision 1.04 - Added xsl:result-document instruction to root template
		Revision 1.03 - updated f:addSequence() to use xpath sequencing.
    	Revision 1.02 - Added revision log - cm3 - 2023/10/24
        Revision 1.01 - Edited. 
   -->
    

    <!-- includes -->
    <xd:doc scope="component">
        <xd:desc>
            <xd:p><xd:b>NAL-MARC21slimUtils.xsl</xd:b>External stylesheet containing XSLT functions.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:include href="NAL-MARC21slimUtils.xsl"/>
    <!-- global parameters -->
    <xd:doc scope="component">
        <xd:desc>
            <xd:p>
                <xd:b>depositorName, depositorEmail</xd:b>
            </xd:p>
            <xd:p>Parameters used to allow depositor name and email address to be set at run-time in
                oXygen, rather than hardcoding within the stylesheet.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:param name="depositorName"/>
    <xsl:param name="depositorEmail"/>

    <!-- CrossRef specific functions -->
    <xd:doc>
        <xd:desc>  
            <xd:p>Function used to create a value for the timestamp element</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="f:createTimestamp">
        <xsl:variable name="date" select="adjust-date-to-timezone(current-date(), ())"/>
        <xsl:variable name="time" select="adjust-time-to-timezone(current-time(), ())"/>
        <xsl:variable name="tempdatetime" select="concat($date, '', $time)"/>
        <xsl:variable name="datetime" select="translate($tempdatetime, ':-.', '')"/>
        <xsl:value-of select="$datetime"/>
    </xsl:function>

    <!--1.02 -->
    <xd:doc>
        <xd:desc>
            <xd:p>Add CrossRef's <xd:b>sequence</xd:b> attribute to names.</xd:p>
        </xd:desc>
        <xd:param name="theElement">The context element.</xd:param>
    </xd:doc>
    <xsl:function name="f:addSequence" as="xs:string">
        <xsl:param name="theElement"/>
        <xsl:sequence select="
                if ($theElement/@usage = 'primary')
                then ('first')
                else ('additional')"/>
    </xsl:function>


    <xd:doc>
        <xd:desc>
        <xd:p>Function to split a single w3cdtf/iso date into month, day, and year
            elements.</xd:p>
            <xd:p><xd:b>Usage:</xd:b> xsl:copy-of select="f:splitDates(.)</xd:p></xd:desc>
    <xd:param name="dateString">The element with the date string</xd:param>
    </xd:doc>
    <xsl:function name="f:splitDates">
        <xsl:param name="dateString"/>
        <xsl:variable name="tokenizedDate" select="tokenize($dateString/text(), '-')"/>
        <xsl:if test="count($tokenizedDate) > 1">
            <month>
                <xsl:value-of select="$tokenizedDate[2]"/>
            </month>
        </xsl:if>
        <xsl:if test="count($tokenizedDate) = 3">
            <day>
                <xsl:value-of select="$tokenizedDate[3]"/>
            </day>
        </xsl:if>
        <year>
            <xsl:value-of select="$tokenizedDate[1]"/>
        </year>
    </xsl:function>

<!--Templates -->
    <xd:doc>
        <xd:desc>
            <xd:p><xd:b>root template</xd:b>contains xsl:result-document to generate CrossRef
                report</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="/">
        <xsl:result-document version="1.0" method="xml" format="CrossRef"
            href="{substring-before(base-uri(),tokenize(base-uri(),'/')[last()])}/{replace(base-uri(),'(.*/)(.*)(\.xml)','$2')}_{'mods2CrossRef'}.xml">
            <doi_batch xmlns="http://www.crossref.org/schema/5.3.1" xsl:exclude-result-prefixes="cr"> 
            <xsl:namespace name="xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:namespace>
                <xsl:attribute name="version">5.3.1</xsl:attribute>
                <xsl:attribute name="xsi:schemaLocation" select="normalize-space('http://www.crossref.org/schema/5.3.1 https://www.crossref.org/schemas/crossref5.3.1.xsd')"/>
                <xsl:call-template name="head"/>
                <body>
                    <xsl:choose>
                        <xsl:when test="modsCollection">
                            <xsl:apply-templates select="modsCollection/mods"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:apply-templates select="mods"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </body>
            </doi_batch>
        </xsl:result-document>
    </xsl:template>

    <!-- 1.06 -->
    <xd:doc>
        <xd:desc>
            <xd:p><xd:b>head</xd:b>called in root template.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="head">
        <head>
            <doi_batch_id>
                <xsl:value-of select="concat('report_paper', '-', current-dateTime())"/>
            </doi_batch_id>
            <timestamp>
                <xsl:value-of select="f:createTimestamp()"/>
            </timestamp>
            <depositor>
                <depositor_name>
                    <xsl:value-of select="$depositorName"/>
                </depositor_name>
                <email_address>
                    <xsl:value-of select="$depositorEmail"/>
                </email_address>
            </depositor>
            <registrant>National Agricultural Library</registrant>
        </head>
    </xsl:template>

    <!-- 1.07 -->
    <xd:doc>
        <xd:desc>
            <xd:p><xd:b>modsCollection</xd:b>for each modsCollection/mods record apply the mods
                template</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="modsCollection">
        <xsl:for-each select="modsCollection/mods">
            <xsl:apply-templates select="mods"/>
        </xsl:for-each>
    </xsl:template>


    <xd:doc>
        <xd:desc>
            <xd:p><xd:b>mods</xd:b>must be in a separate template to prevent namespace problems.
                Primary transformation template</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="mods">
        <report-paper>
            <report-paper_metadata>
                <xsl:choose>
                    <xsl:when test="language/languageTerm[@type = 'code']">
                        <xsl:variable name="langCode"
                            select="normalize-space(language/languageTerm[@type = 'code']/text())"/>
                        <xsl:attribute name="language">
                            <xsl:value-of select="local:isoTwo2One($langCode)"/>
                        </xsl:attribute>
                    </xsl:when>
                </xsl:choose>
                <!--1.08-->
                <contributors>                      
                    <xsl:apply-templates select="name[@type = 'personal']" mode="contributor"/> 
                    <xsl:apply-templates select="name[@type = 'corporate']" mode="contributor"/>
                </contributors>
                <titles>
                    <xsl:apply-templates select="titleInfo/title"/>
                    <xsl:apply-templates select="titleInfo/subTitle"/>
                </titles>
                <xsl:apply-templates select="abstract"/>
                <xsl:apply-templates select="originInfo/dateIssued[@encoding = 'w3cdtf']"/>
                <!-- 1.09 -->
                <xsl:apply-templates select="originInfo[@eventType = 'publisher']"/>
 <!--  1.10 --><xsl:apply-templates select="name[@type = 'corporate']" mode="ror_org"/>
               <xsl:apply-templates select="map"/>
                <xsl:call-template name="doiData"/>
            </report-paper_metadata>
        </report-paper>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p>titleInfo</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="titleInfo/title">
        <title>
            <xsl:value-of select="."/>
        </title>
    </xsl:template>

    <xd:doc>
        <xd:desc>subTitle</xd:desc>
    </xd:doc>
    <xsl:template match="titleInfo/subTitle">
        <subtitle>
            <xsl:value-of select="."/>
        </subtitle>
    </xsl:template>


    <xd:doc>
        <xd:desc>
            <xd:ul>
                <xd:li> <xd:p><xd:b>personal_name</xd:b></xd:p></xd:li>
                <xd:li> <xd:p><xd:b><xd:i>@sequence:</xd:i></xd:b> 
                    denotes the "first" and "additional" contributors.personal_name</xd:p></xd:li>
                <xd:li> <xd:p><xd:b><xd:i>@contributor_role (updated in 5.3.1):</xd:i></xd:b> This update limits the roles of contributors 
                    to the nine included below. </xd:p></xd:li>
            </xd:ul>   
        </xd:desc>
    </xd:doc>
    <xsl:template match="name[@type = 'personal']" mode="contributor">
        <xsl:variable name="role" select="role[1]/roleTerm"/>        <!-- 1.11 -->
        <xsl:variable name="valid" as="xs:boolean" select="$role=('author', 'editor', 'chair', 'reviewer', 'review-assistant', 'stats-reviewer', 'reviewer-external', 'reader', 'translator')"/> 
        <person_name sequence="{f:addSequence(.)}">           
            <xsl:attribute name="contributor_role">  
            <xsl:choose>
                    <xsl:when test="$valid">                       
                       <xsl:value-of select="$role"/>                        
                    </xsl:when>
                   <!-- 1.18 adding second condition for usage of primary investigtor -->
                   <xsl:when test="'primary investigator'">                     
                       <xsl:value-of select="'author'"/>                       
                   </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$role"/>
                        <xsl:message terminate="no" select="concat('Warning! Invalid value of: &quot; ', $role, ' &quot; was selected. ', 'Only one of the following values may be selected: author, editor, chair, reviewer, review-assistant, stats-reviewer, reviewer-external, reader, translator.' )"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <given_name>
                <xsl:value-of select="namePart[@type = 'given']"/>
            </given_name>
            <surname>
                <xsl:value-of select="namePart[@type = 'family']"/>
            </surname>
            <xsl:apply-templates select="affiliation"/>
            <xsl:apply-templates select="nameIdentifier[@type = 'orcid']"/>
        </person_name>
    </xsl:template>

    <xd:doc>
        <xd:desc>corporate body</xd:desc>
    </xd:doc>
    <xsl:template match="name[@type = 'corporate']" mode="contributor">
        <organization sequence="{f:addSequence(.)}" contributor_role="author" >
            <xsl:value-of select="local:stripPunctuation(namePart)"/>
        </organization>
    </xsl:template>

    <xd:doc>
        <xd:desc>ORCID id</xd:desc>
    </xd:doc>
    <xsl:template match="nameIdentifier[@type = 'orcid']">
        <ORCID>
            <xsl:value-of select="."/>
        </ORCID>
    </xsl:template>

    <xd:doc>
        <xd:desc><xd:p><xd:b>affiliations:(update 5.3.1)</xd:b></xd:p>
            <xd:ul>
             <xd:li>replace &lt;affiliation&gt; tag with  &lt;affiliations&gt; tag to support new affiliations structure</xd:li>
             <xd:li>add &lt;institution_id&gt; element to support ROR and other org IDs</xd:li>
             <xd:li>make either  &lt;institution_id&gt; or  &lt;institution_name&gt; required within institution metadata</xd:li>
            </xd:ul>
        </xd:desc>
    </xd:doc>
    <xsl:template match="affiliation">
        <affiliations>
            <institution>
                <institution_name>
                    <xsl:value-of select="local:stripPunctuation(.)"/>
                </institution_name>
            </institution>
        </affiliations>
    </xsl:template>
        
     
    <xd:doc>
        <xd:desc>institution_id for publisher</xd:desc>
    </xd:doc>
    <xsl:template match="name[@type = 'corporate']">
        <institution>
            <institution_name>
                <xsl:value-of select="local:stripPunctuation(namePart)"/>
            </institution_name>
        </institution>
    </xsl:template>

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="originInfo/dateIssued[@encoding = 'w3cdtf']">
        <publication_date media_type="online">
            <xsl:copy-of select="f:splitDates(.)"/>
        </publication_date>
    </xsl:template>

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="originInfo[@eventType = 'publisher']">
        <publisher>
                <publisher_name>
                    <xsl:value-of select="local:stripPunctuation(publisher)"/>
                </publisher_name>
            <publisher_place>
                <xsl:choose>
                    <xsl:when test="matches(place/placeTerm, '\[.*\?\]\s?:?')">
            <xsl:apply-templates select="replace(place/placeTerm, '(\[)(.*)(\?\])(\s?:?)', '$2')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(local:stripPunctuation(place/placeTerm))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </publisher_place>
        </publisher>
    </xsl:template>

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="place/placeTerm[@type = 'text']">
            <xsl:value-of select="normalize-space(local:stripPunctuation(.))"/>
    </xsl:template>

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="abstract">
        <abstract xmlns="http://www.ncbi.nlm.nih.gov/JATS1">
            <p>
                <xsl:value-of select="local:stripPunctuation(.)"/>
            </p>
        </abstract>
    </xsl:template>

    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template name="doiData">
        <doi_data>
            <doi>
                <xsl:value-of select="identifier[@type = 'doi']"/>
            </doi>
            <resource>
                <xsl:value-of select="concat('https://handle.nal.usda.gov/', identifier[@type = 'hdl'])"/>
            </resource>
        </doi_data>
    </xsl:template>
    <xd:doc>
        <xd:desc/>
        <xd:param name="orgName"/>
    </xd:doc>
    <xsl:template match="name[@type='corporate']" mode="ror_org">
        <xsl:param name="orgName" tunnel="yes"/>
        <xsl:if test="namePart">
            <institution_id>
                <xsl:apply-templates select="array/map">
                    <xsl:with-param name="org">
                        <xsl:value-of select="array/map[string[@key='name']=$orgName]/string[@key='id']"/>"/>                  
                    </xsl:with-param>
                </xsl:apply-templates>
            </institution_id>
        </xsl:if>
    </xsl:template>
  <!--  <xd:doc>
        <xd:desc> ror_api_query </xd:desc>
        <xd:param name="org"/>
    </xd:doc>
    <xsl:template match="institution_name" mode="ror_org">
        <xsl:param name="org" as="xs:string" tunnel="yes"/>
        <insitution_id>
         
        </insitution_id>
    </xsl:template> -->
    <xd:doc>
        <xd:desc></xd:desc>
    </xd:doc>
    <xsl:template match="array" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <xsl:apply-templates select="map"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
        <xd:param name="org"/>
    </xd:doc>
    <xsl:template match="map" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <xsl:param name="org" as="xs:string"/>          
        <xsl:variable name="api_query" select="json-doc(concat('https://api.ror.org/organizations?affiliation', encode-for-uri($org)))"/>
        <xsl:value-of select="
            $api_query
            =>parse-json()
            =>map:get(array/map[string[@key='name']=$org]/string[@key='id'])"/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="*[@key]" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <xsl:element name="{@key}">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="array" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xd:doc>
        <xd:desc/>
    </xd:doc>
    <xsl:template match="array[@key]/*" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
        <xsl:element name="{../@key}">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    
    
</xsl:stylesheet>
