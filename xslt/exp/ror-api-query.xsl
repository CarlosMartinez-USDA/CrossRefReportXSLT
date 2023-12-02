<?xml version="1.0" encoding="UTF-8"?>
   <xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:math="http://www.w3.org/2005/xpath-functions/math"
        xmlns:map="http://www.w3.org/2005/xpath-functions/map"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        exclude-result-prefixes="xs math" version="3.0">
        <xsl:output indent="yes" omit-xml-declaration="yes"/> <!--name="json"/>-->
 
       <xsl:param name="tunneled_org" as="xs:string"/>          
       <xsl:variable name="api_query" as="xs:string" select="json-doc(concat('https://api.ror.org/organizations?affiliation', encode-for-uri($tunneled_org)))"/>
   
<!--   <xsl:template match="/">
   <!-\- <xsl:result-document version="1.0" method="xml" format="json" encoding="UTF-8"
        href="{replace(base-uri(),'(.*/)(.*)(\.json)','$1')}A-{replace(base-uri(),'(.*/)(.*)(\.json)','$2')}_{position()}.xml">-\->
        <xsl:apply-templates select="data"/>
    <!-\-</xsl:result-document>-\->
</xsl:template>-->
    
       <xsl:template match="data">
        <xsl:copy-of select="json-to-xml(.)"/>
    </xsl:template>
    
       <xsl:template match="array" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
            <xsl:apply-templates select="map"/>
       </xsl:template>
       
       <xsl:template match="map" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
           <xsl:value-of select="
           $api_query
            =>parse-json()
            =>map:get(array/map[string[@key='name']=$tunneled_org]/string[@key='id'])"/>
       </xsl:template>
           
       <xsl:template match="*[@key]" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
           <xsl:element name="{@key}">
               <xsl:apply-templates/>
           </xsl:element>
       </xsl:template>
       
       <xsl:template match="array" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
           <xsl:apply-templates/>
       </xsl:template>
       
       <xsl:template match="array[@key]/*" xpath-default-namespace="http://www.w3.org/2005/xpath-functions">
           <xsl:element name="{../@key}">
               <xsl:apply-templates/>
           </xsl:element>
       </xsl:template>
       
       
                     
         </xsl:stylesheet>
