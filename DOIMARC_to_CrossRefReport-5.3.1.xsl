<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
	xmlns="http://www.crossref.org/schema/5.3.1" xmlns:cr="http://www.crossref.org/schema/5.3.1"
	xmlns:f="http://functions" xmlns:isodates="http://iso"  xmlns:local="http://www.local.gov/namespace"
	xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	exclude-result-prefixes="cr f isodates local marc xd xlink xs xsi"
	xpath-default-namespace="http://www.loc.gov/marc21/slim">
	<xsl:output version="1.0" encoding="UTF-8" method="xml" indent="yes" name="CrossRef"/>
	<xsl:strip-space elements="*"/>
	
	<xd:doc scope="stylesheet">
		<xd:desc>
			<xd:p><xd:b>Created on:</xd:b> November 7, 2023</xd:p>
			<xd:p><xd:b>Last updated:</xd:b> November 7, 2023</xd:p>
			<xd:p><xd:b>Authors:</xd:b> Carlos Martinez III and Amanda Xu</xd:p>
			<xd:p>Transform MARC XML into CrossRef's 5.3.1 report schema</xd:p>
		</xd:desc>
	</xd:doc>
	
	<!-- includes -->
	<xd:doc scope="component">
		<xd:desc>
			<xd:p><xd:b>NAL-MARC21slimUtils.xsl</xd:b>External stylesheet containing XSLT functions.</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:include href="NAL-MARC21slimUtils.xsl"/>
	<xsl:include href="commons/functions.xsl"/>
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
	
	<xd:doc>
		<xd:desc>
			<xd:p>Add CrossRef's <xd:b>sequence</xd:b> attribute to names.</xd:p>
		</xd:desc>
		<xd:param name="theElement">The context element.</xd:param>
	</xd:doc>
	<xsl:function name="f:addSequence" as="xs:string">
		<xsl:param name="theElement"/>
		<xsl:sequence select="
			if ($theElement[@tag = '100' or @tag = '110' or @tag = '111'])
			then ('first')
			else ('additional')"/>
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

<!-- Templates -->	
	<xd:doc>
		<xd:desc>
			<xd:p><xd:b>root template</xd:b>contains xsl:result-document to generate CrossRef
				report</xd:p>
		</xd:desc>
	</xd:doc>
	<xsl:template match="/">
		<xsl:result-document version="1.0" method="xml" format="CrossRef" 
			href="{substring-before(base-uri(),tokenize(base-uri(),'/')[last()])}/{replace(base-uri(),'(.*/)(.*)(\.xml)','$2')}_{'mrc2CrossRef'}.xml">
			<doi_batch xmlns="http://www.crossref.org/schema/5.3.1" xsl:exclude-result-prefixes="cr">
				<xsl:namespace name="xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:namespace>
				<xsl:attribute name="version">5.3.1</xsl:attribute>
				<xsl:attribute name="xsi:schemaLocation"
					select="normalize-space('http://www.crossref.org/schema/5.3.1 https://www.crossref.org/schemas/crossref5.3.1.xsd')"/>
				<xsl:call-template name="head"/>
				<body>
					<xsl:choose>
						<xsl:when test="marc:collection">
							<xsl:apply-templates select="marc:collection/marc:record"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="marc:record"/>
						</xsl:otherwise>
					</xsl:choose>
				</body>
			</doi_batch>
		</xsl:result-document>
	</xsl:template>

	<!-- head element -->
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

	<xd:doc>
		<xd:desc> Build marc:collection </xd:desc>
	</xd:doc>
	<xsl:template match="marc:collection">
			<xsl:apply-templates select="marc:record"/>
	</xsl:template>

	<xd:doc>
		<xd:desc>Builds marc:record </xd:desc>
	</xd:doc>
	<xsl:template match="marc:record">
			<report-paper>
				<!-- Adds appropriate namespaces and schema declaration if root is marc:record -->
				<xsl:if test="/marc:record">
					<xsl:namespace name="xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:namespace>
					<xsl:attribute name="xsi:schemaLocation">http://www.crossref.org/schema/5.3.1 https://www.crossref.org/schemas/crossref5.3.1.xsd</xsl:attribute>
				</xsl:if>
				<!-- language -->
				<report-paper_metadata>
					<xsl:attribute name="language">
						<xsl:apply-templates select="marc:controlfield[@tag = '008']" mode="lang"/>
					</xsl:attribute>					
			    <!-- contributors -->
					<contributors>
						<xsl:apply-templates select="marc:datafield[@tag = '100']" mode="name"/>
						<xsl:apply-templates select="marc:datafield[@tag = '700'][not(marc:subfield[@code = 't'])]" mode="name"/>
						<xsl:apply-templates select="marc:datafield[@tag = '110']" mode="name"/>
						<xsl:apply-templates select="marc:datafield[@tag = '710'][not(marc:subfield[@code = 't'])]" mode="name"/>
						<xsl:apply-templates select="marc:datafield[@tag = '111']" mode="name"/>
						<xsl:apply-templates select="marc:datafield[@tag = '711'][not(marc:subfield[@code = 't'])]" mode="name"/>
					</contributors>					
				<!-- titles -->
					<titles><xsl:apply-templates select="marc:datafield[@tag='245']" mode="title"/></titles>
				<!-- abstract -->
					<xsl:apply-templates select="marc:datafield[@tag='520']/marc:subfield[@code='a']"/>
				<!-- publisher -->				
						<xsl:call-template name="publication_date"/>
						<xsl:apply-templates select="marc:datafield[@tag = '264']" mode="publisher"/>
				<!-- doi/hdl -->
					<doi_data>
						<xsl:apply-templates select="marc:datafield[@tag='024']/marc:subfield[@code='a']" mode="doi"/> 
				    	<xsl:apply-templates select="marc:datafield[@tag='856']/marc:subfield[@code='u']" mode="resource"/>
					</doi_data>
				</report-paper_metadata>
			</report-paper>
	</xsl:template>
	
	<!-- language -->
	<xd:doc>
		<xd:desc> 008 - Language elements </xd:desc>
	</xd:doc>
	<xsl:template match="marc:controlfield[@tag = '008']" mode="lang">
		<!-- Isolates position 35-37 in controlfield 008 -->
		<xsl:variable name="controlField008-35-37"
			select="normalize-space(translate(substring(., 36, 3), '|#', ''))"/>
		<!-- Outputs language element based on value in position 35-37 -->
		<xsl:if test="$controlField008-35-37 != ''">
			<xsl:value-of select="local:isoTwo2One(substring(., 36, 3))"/>
		</xsl:if>
	</xsl:template>
	
	<!-- name templates -->
	<xd:doc>
		<xd:desc>100 - main entry | 700 - added entry - personal name </xd:desc>
	</xd:doc>
	<xsl:template match="marc:datafield[@tag = '100'][not(marc:subfield[@code = 't'])] |
		marc:datafield[@tag = '700'][not(marc:subfield[@code = 't'])]" mode="name">
		<xsl:variable name="role" select="local:stripPunctuation(normalize-space(marc:subfield[@code = 'e'][1]))"/> 
		<xsl:variable name="valid" as="xs:boolean" select="$role=('author', 'editor', 'chair', 'reviewer', 'review-assistant', 'stats-reviewer', 'reviewer-external', 'reader', 'translator')"/>
		<person_name sequence="{f:addSequence(.)}">
			<xsl:attribute name="contributor_role">
				<xsl:choose>
					<xsl:when test="$valid">
						<xsl:value-of select="$role"/>
					</xsl:when>
					<!-- in absence of a valid roleTerm 'author' is selected." -->
					<xsl:otherwise>
						<xsl:value-of select="'author'"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
			<!-- given -->
			<xsl:for-each select="marc:subfield[@code = 'a']">
				<given_name>					
					<xsl:value-of
						select="
						local:stripPunctuation(
						normalize-space(
						substring-after(
						local:subfieldSelect(parent::*, 'aq'), ',')))"/>
				</given_name>
				<!-- surname -->
				<surname>
					<xsl:value-of
						select="normalize-space(
						substring-before(
						local:subfieldSelect(parent::*, 'aq'), ','))"/>
				</surname>
			</xsl:for-each>
			<!--removed terms of address -->
			<xsl:apply-templates select="marc:subfield[@code = 'u']" mode="affiliation"/>
			<xsl:apply-templates select="marc:subfield[@code = '1']" mode="nameIdentifier"/>
		</person_name>
	</xsl:template>

	<xd:doc>
		<xd:desc>110/710 - main entry - corporate name</xd:desc>
	</xd:doc>
	<xsl:template match="marc:datafield[@tag = '110'] | marc:datafield[@tag = '710'][not(marc:subfield[@code = 't'])]" mode="name">
		<xsl:if test="marc:subfield[@code != 't']">
			<organization sequence="{f:addSequence(.)}" contributor_role="{'author'}">
				<!-- name -->
				<xsl:for-each select="marc:subfield[@code = 'a'] | marc:subfield[@code = 'b']">
					<xsl:value-of xml:space="preserve" select="local:stripPunctuation(normalize-space(.))"/>
				</xsl:for-each>
				<xsl:if
					test="marc:subfield[@code = 'c'] or marc:subfield[@code = 'd'] or marc:subfield[@code = 'n']">
					<namePart>
						<xsl:value-of xml:space="preserve" select="substring-before(local:subfieldSelect(., 'cdn'), ',')"/>
					</namePart>
				</xsl:if>
				<!-- 1.20 role removed -->
				<xsl:apply-templates select="marc:subfield[@code = '1']" mode="nameIdentifier"/>
			</organization>
		</xsl:if>
	</xsl:template>


	<xd:doc>
		<xd:desc> 111/711 - main entry - meeting name </xd:desc>
	</xd:doc>
	<xsl:template match="marc:datafield[@tag = '111'] | marc:datafield[@tag = '711'][not(marc:subfield[@code = 't'])]" mode="name">
		<xsl:if test="marc:subfield[@code != 't']">
			<name type="conference">
				<xsl:apply-templates select="marc:subfield[@code = '0'][. != '']" mode="valueURI"/>
				<!-- conference -->
				<conference>
					<xsl:value-of select="local:subfieldSelect(., 'acdenq')"/>
				</conference>
				<xsl:apply-templates select="marc:subfield[@code = '1'][. != '']" mode="nameIdentifier"/>
			</name>
		</xsl:if>
	</xsl:template>
	

	<!-- affiliation -->
	<xd:doc>
		<xd:desc>affiliation</xd:desc>
	</xd:doc>
	<xsl:template match="marc:subfield[@code = 'u']" mode="affiliation">
		<affiliations>
			<institution>
				<institution_name>
					<xsl:copy-of select="normalize-space(
						local:stripPunctuation(.))"/>
				</institution_name>
			</institution>
		</affiliations>
	</xsl:template>

	<!-- ORCID -->	
	<xd:doc>
		<xd:desc>ORCID</xd:desc>
	</xd:doc>
	<xsl:template match="marc:subfield[@code = '1']" mode="nameIdentifier">
		<ORCID>
			<xsl:value-of select="."/>
		</ORCID>
	</xsl:template>

	<!-- title main entry -->
	<xd:doc>
		<xd:desc> 245 title main entry </xd:desc>
	</xd:doc>
	<xsl:template match="marc:datafield[@tag='245']" mode="title">
		<!-- $b basis for selection other subfields-->
			<xsl:variable name="title">
				<xsl:choose>
					<xsl:when test="marc:subfield[@code='b']">
						<!-- subfields abfgks -->						
						<xsl:value-of select="local:specialSubfieldSelect(.,'','b','afgks','')"/>
					</xsl:when>
					<xsl:otherwise>						
						<xsl:value-of select="local:subfieldSelect(.,'abfgks')"/>				
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<!-- title -->
					<title>
						<xsl:value-of select="local:stripPunctuation($title)"/>
					</title>
			<!-- Subtitle -->
			<xsl:apply-templates select="marc:subfield[@code='b']" mode="title"/>
			<!-- Part number -->
			<xsl:apply-templates select="marc:subfield[@code='n']" mode="title"/>
			<!-- Part name -->
			<xsl:apply-templates select="marc:subfield[@code='p'][1]" mode="title"/>
	</xsl:template>
		
	<!-- subtitle ($b) -->
	<xd:doc>
		<xd:desc> $b subtitle </xd:desc>
	</xd:doc>
	<xsl:template match="marc:subfield[@code='b']" mode="title">
		<subtitle>
			<!-- NOTE: uses specialSubfieldSelect, which I don't know that we need -->
			<xsl:value-of
				select="local:stripPunctuation(local:specialSubfieldSelect(parent::*,'b','b','','afgk'))"
			/>
		</subtitle>
	</xsl:template>
	
	
 <!-- partNumber ($n) -->
	<xd:doc>
		<xd:desc> $n title, partNumber </xd:desc>
	</xd:doc>
	<xsl:template match="marc:subfield[@code='n']" mode="title">
		<xsl:variable name="partNumber">
			<xsl:choose>
				<xsl:when
					test="parent::*[@tag='245'] or parent::*[@tag='240'] or parent::*[@tag='130'] or parent::*[@tag='730']">
					<xsl:value-of
						select="local:specialSubfieldSelect(parent::*,'n','n','','fgkdlmor')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($partNumber) &gt; 0">
			<partNumber>
				<xsl:value-of select="local:stripPunctuation($partNumber)"/>
			</partNumber>
		</xsl:if>
	</xsl:template>
	
	<!-- partNumber ($p)-->
	<xd:doc>
		<xd:desc> $p title, partName </xd:desc>
	</xd:doc>
	<xsl:template match="marc:subfield[@code='p']" mode="title">
		<xsl:variable name="partName">
			<xsl:choose>
				<xsl:when
					test="parent::*[@tag='245'] or parent::*[@tag='240'] or parent::*[@tag='130'] or parent::*[@tag='730']">
					<xsl:value-of
						select="local:specialSubfieldSelect(parent::*,'p','p','','fgkdlmor')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:if test="string-length($partName) &gt; 0">
			<partName>
				<xsl:value-of select="local:stripPunctuation($partName)"/>
			</partName>
		</xsl:if>
	</xsl:template>


<!-- abstract -->
	<xd:doc>
		<xd:desc>abstract</xd:desc>
	</xd:doc>
	<xsl:template match="marc:datafield[@tag='520']/marc:subfield[@code='a']">
		<abstract xmlns="http://www.ncbi.nlm.nih.gov/JATS1">
			<p>
				<xsl:value-of select="local:stripPunctuation(.)"/>
			</p>
		</abstract>
	</xsl:template>
	
	<!-- publication_date -->
	<xd:doc>
		<xd:desc> publication_date from MARC 008</xd:desc>
	</xd:doc>
	<xsl:template name="publication_date"> 
		<!-- analyze string to build w3cdtf dates -->
		<xsl:analyze-string select="substring(marc:controlfield[@tag = '008'], 1, 15)"
			regex="(\d+)(\w)(\d+)">
			<xsl:matching-substring>
				<publication_date media_type="online">					
					<xsl:choose>
						<!-- MM-DD-YYYY -->
						<xsl:when test="matches(regex-group(3), '\d{8}')">
							<month><xsl:number value="substring(regex-group(3), 5, 2)" format="01"/></month>
							<day><xsl:number value="substring(regex-group(3), 7, 2)" format="01"/></day>							
							<year><xsl:number value="substring(regex-group(3), 1, 4)" format="0001"/> </year>						
						</xsl:when>
						<!-- MM-YYYY -->
						<xsl:when test="matches(regex-group(3), '\d{6}')">
							<month><xsl:number value="substring(regex-group(3), 5, 2)" format="01"/></month>
							<year><xsl:number value="substring(regex-group(3), 1, 4)" format="0001"/></year>	
						</xsl:when>
						<!-- YYYY -->
						<xsl:otherwise>
							<year><xsl:number value="substring(regex-group(3), 1, 4)" format="0001"/></year>
						</xsl:otherwise>
					</xsl:choose>
				</publication_date>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:template>	
	
<!-- publisher -->
	<xd:doc>
		<xd:desc> publisher </xd:desc>
	</xd:doc>
	<xsl:template match="marc:datafield[@tag  = '264']" mode="publisher">
		<publisher>
		<publisher_name>
			<xsl:value-of select="local:stripPunctuation(normalize-space(marc:subfield[@code='b']))"/>
		</publisher_name>
		<publisher_place>
			<xsl:choose>
				<xsl:when test="matches(marc:subfield[@code='a'], '\[.*\?\]\s?:?')">
					<xsl:apply-templates select="replace(marc:subfield[@code='a'], '(\[)(.*)(\?\])(\s:?\s?)', '$2')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(local:stripPunctuation(marc:subfield[@code='a']))"/>
				</xsl:otherwise>
			</xsl:choose>
		</publisher_place>
	   </publisher>
	</xsl:template>
	
<!-- DOI -->
	<xd:doc>
		<xd:desc>DOI</xd:desc>
	</xd:doc>
	<xsl:template match="marc:datafield[@tag='024']/marc:subfield[@code='a']" mode="doi">
		<xsl:if test="matches(. ,'\d{2}\.\d{5}/\d{4}\.\d{7}\.\S+')">
			<doi>						
				<xsl:value-of select="."/>
			</doi>
		</xsl:if>
	</xsl:template>

<!-- handle -->
	<xd:doc>
		<xd:desc>NAL Handle</xd:desc>
	</xd:doc>
	<xsl:template match="marc:datafield[@tag='856']/marc:subfield[@code='u']" mode="resource">
		<xsl:if test="starts-with(. ,'https://handle.nal.usda.gov')">
			<resource>						
	  		<xsl:value-of select="."/>
			</resource>
		</xsl:if>
	</xsl:template>


</xsl:stylesheet>
