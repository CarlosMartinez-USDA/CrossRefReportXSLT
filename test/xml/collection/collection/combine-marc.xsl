<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:marc="http://www.loc.gov/marc21/slim"
    exclude-result-prefixes="xs marc"
    version="2.0">
    <xsl:output method="xml" name="combine"/>
    <!-- make sure your collection files are within a directory folder labeled "collection" -->
    <xsl:variable name="collection" as="node()*"
        select="collection('collection-index-sample.xml')"/>
    <xsl:template match="/">
        <xsl:result-document exclude-result-prefixes="xs marc" method="xml" version="1.0"
            encoding="UTF-8" indent="yes" format="combine"
            href="{substring-before(base-uri(),tokenize(base-uri(),'/')[last()])}/recompile/{replace(base-uri(),'(.*/)(.*)(\.xml)','$2')}.xml">
            <marc:collection xmlns="http://www.loc.gov/MARC21/slim"
                xmlns:marc="http://www.loc.gov/MARC21/slim"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://www.loc.gov/MARC21/slim https://www.loc.gov/standards/marcxml/schema/MARC21slim.xsd">
                <xsl:copy-of copy-namespaces="no" select="$collection"/>
            </marc:collection>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>