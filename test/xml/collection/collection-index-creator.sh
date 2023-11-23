#!/bin/bash

declare -r XML_FILE="collection-index-sample.xml"

[ -f ${XML_FILE} ] && : > ${XML_FILE}

for directory_name in $(ls -F . | grep '/' | sed 's|/||')
do
   echo -e "<collection>" >> ${XML_FILE}
   dirfiles=$(ls -A ${directory_name})
   if [ "${dirfiles}" ] ; then
      for files in ${dirfiles}
      do
         echo -e "\t<doc href=\"${files/.*}.xml\"></doc>" >> ${XML_FILE}
      done
   fi
   echo -e "</collection>" >> ${XML_FILE}
done