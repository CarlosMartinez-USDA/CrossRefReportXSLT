# CrossRefReportXSLT
Upgrading DOIMODS-to-CrossRefReport-4.4.2 to 5.3.1, introducing development of DOIMARC-to-CrossRefReport-5.3.1

The CrossRef Reporting schema has undergone 2 major upgrades since the development of the stylesheet that process version 4.4.2. Thus, some updates to the eporting XSLT be made periodically. The current transformation responsible for 
MODSDOI_to_CrossRefReport20230608.xsl adheres to the CrossRef Reporting Schema 4.4.2. 

There have been 2 major upgrades to the Reporting Schema since 4.4.2. The version numbers and changes are listed below

## Version 4.8.1
(i.e.  Changes from  4.4.2)
-   refactoring of schema
-   relax regex rules for email addresses
-   allow ISBN beginning with 979
-   update imported JATS schema to v. 1.3
-   relax regex rules for  `<given_name>`  element.

## Version 5.3.1
(i.e. Changes from 4.8.1)

-   replace  `<affiliation>`  tag with  `<affiliations>`  tag to support new affiliations structure
-   add  `<institution_id>`  element to support ROR and other org IDs
-   make either  `<institution_id>`  or  `<institution_name>`  required within institution metadata
-   relax regex rules for  `<given_name>`  element



## restructuring of affiliation metadata
### in update 5.3.1 
 - `<affiliation>` singular became `<affiliations>` plural
 -  works well for instances where a  contributor is affiliated with more than one institution.
 - Thus a new subelement is introduced:
 - `<institution>` is a container tag for two identifying sub-elements:
	  1. <institution_name> 
	   2. <institution_id> - element to support ROR and other org IDs.
- Either the `<institution_name>` or `<institution_id>` is required for an affiliation to be valid. 
