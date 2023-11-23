<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:mods="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="xs mods"
    version="2.0">
    <xsl:output method="xml" name="combine"/>
    <xsl:variable name="collection" as="node()*"
        select="collection('collection-index.xml')"/>
    <xsl:template match="/">
        <xsl:result-document exclude-result-prefixes="xs mods" method="xml" version="1.0"
            encoding="UTF-8" indent="yes" format="combine"
            href="{substring-before(base-uri(),tokenize(base-uri(),'/')[last()])}/recompile/{replace(base-uri(),'(.*/)(.*)(\.xml)','$2')}.mods.xml">
            <modsCollection xmlns="http://www.loc.gov/mods/v3"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-7.xsd">
                <xsl:copy-of copy-namespaces="no" select="$collection//mods:mods"/>
            </modsCollection>
        </xsl:result-document>
    </xsl:template>
</xsl:stylesheet>