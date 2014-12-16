#!/bin/bash

function read_dom ()
{
    local IFS=\>
    read -d \< ENTITY CONTENT
    local ret=$?
    TAG_NAME=${ENTITY%% *}
    ATTRIBUTES=${ENTITY#* }
	CONTENT=`echo "$CONTENT" | sed 's/&lt;/</g' | sed 's/&gt;/>/g' | sed 's/&amp;/\&/g'`
    return $ret
}

if [[ $# < 3 ]]; then
	echo "usage: $0 [-d] <template file> <config file>"
	exit 0;
fi

cfile=${3%.*}.c
hfile=${3%.*}.h

while read_dom; do
	if [[ ! -z $TAG_NAME && ! -z ${TAG_NAME%%/*} ]]; then
		if [[ $TAG_NAME == c_file_template ]]; then
			ofile=$cfile
		elif [[ $TAG_NAME == h_file_template ]]; then 
			ofile=$hfile
		fi
		echo "$CONTENT" | sed 's/&lt;/</g' | sed 's/&gt;/>/g' | sed 's/&amp;/\&/g' > $ofile
	fi
done < $2

#cat template.xml | sed 's/<.*>//g' | sed 's/&lt;/</g' | sed 's/&gt;/>/g' | sed 's/&amp;/\&/g' > $cfile

while read_dom; do
	if [[ ! -z $TAG_NAME && ! -z ${TAG_NAME%%/*} ]]; then
		sed -i "s/%$TAG_NAME%/$CONTENT/g" $cfile
		sed -i "s/%$TAG_NAME%/$CONTENT/g" $hfile
	fi
done < $3

sed -i "s/%INCLUDE_FILENAME%/$hfile/g" $cfile
hfile_cap=`echo "${hfile^^*}" | sed 's/\./_/g'`
sed -i "s/%INCLUDE_FILENAME_CAP%/$hfile_cap/g" $hfile
