<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
    <!-- The input JSON file -->
    <xsl:param name="org">
        <xsl:value-of select="affiliation|namePart|originInfo"/>
    </xsl:param>
    <xsl:param name="input" select="json-doc(concat('https://api.ror.org/organizations?affiliation=', encode-for-uri($org)))"/>
    
    <!-- The initial template that process the JSON -->
    <xsl:template name="xsl:initial-template">
        <xsl:apply-templates select="json-to-xml(unparsed-text($input))"/>
    </xsl:template>
</xsl:stylesheet>