#!/bin/bash


#
#  usage:
#  sh icon.sh ./xxx.jpg
#  or
#  sh icon.sh ./xxx.png
#
#  will create AppIcon.appiconset in the same folder.
#


rm -rf AppIcon.appiconset 
mkdir AppIcon.appiconset

file=$1


if [ ! -f "$file" ]; then
echo $file not exist.
exit
fi

suffix=${file##*.}


content='{"images":['

arr=("16" "32" "128" "256" "512")  
  
for var in ${arr[@]}  
do
	sips -Z $var $file --out "AppIcon.appiconset/"$var"-1."$suffix        > /dev/null 2>&1
	sips -Z $[$var*2] $file --out "AppIcon.appiconset/"$var"-2."$suffix   > /dev/null 2>&1

	s='{"size":"'$var'x'$var'","idiom":"mac","filename":"'$var'-1.'$suffix'","scale":"1x"},{"size":"'$var'x'$var'","idiom":"mac","filename":"'$var'-2.'$suffix'","scale":"2x"},'
	content=$content$s
done

content=${content%?}
content=$content'],"info":{"version":1,"author":"http://zhangxi.me"}}'

touch AppIcon.appiconset/Contents.json
echo $content  > AppIcon.appiconset/Contents.json

echo "create AppIcon.appiconset success"


