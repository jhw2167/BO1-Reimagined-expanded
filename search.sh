#!/bin/bash

#searchs for string 'str' in directory 'dir' and copies valid files into new dir
#usage "./search my/file/path myString"

dir=$1
str=$2
dirOut='zzz_search'
out="${dirOut}/__search.txt"


mkdir $dirOut
grep --exclude-dir={$dirOut,Common} -rFni $dir -e "${str}" > $out
notepad $out


#copy each file where instance was found into our out dir
#while IFS='' read -r LINE || [ -n "${LINE}" ]; do
	#fp=${LINE%%:*}
	#echo $fp | tr ./ -
	#subdir=`echo $fp | tr ./ -`
	#echo "subdir is: ${subdir}"
	#mkdir "${dirOut}/${subdir}"
    #cp $fp "${dirOut}/${subdir}"
#done < $out
