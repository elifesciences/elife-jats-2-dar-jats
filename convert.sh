#!/bin/bash

xml_file_list ()
{
  # get a list of the most recent version of each article .xml files
  # note: can just validate a set of files with regex e.g. '.*4[0-9][0-9][0-9][0-9]-v[1-9].xml' | sort`
  all_files=`find ./elife-article-xml/articles -type f -regex '.*.xml' | sort`
  prev_xml_file=""
  for xml_file in $all_files; do
    IFS='-' read -r -a xml_file_array <<< "$xml_file"
    article_id="${xml_file_array[@]: -2:1}"
    if [[ $prev_xml_file != "" ]]; then
      IFS='-' read -r -a prev_xml_file_array <<< "$prev_xml_file"
      prev_article_id="${prev_xml_file_array[@]: -2:1}"
    fi
    if [[ $article_id != $prev_article_id ]]; then
      echo "$prev_xml_file"
    fi
    prev_xml_file=$xml_file
  done
  # finish up echo the final file
  echo "$prev_xml_file"
}

for inputfile in $(xml_file_list)
do
  outputfile="./output/${inputfile##*/}"
  echo "converting $inputfile to $outputfile"
  #basex -b\$inputfile=$inputfile -b\$outputfile=$outputfile xquery/elife2dar.xq || { echo "failed converting $inputfile" ;}
  #basex -b\$inputfile=$inputfile xquery/elife2dar.xq > $outputfile || { echo "failed converting $inputfile" ;}
  zorba -e inputfile:=$inputfile -f xquery/elife2dar.xq > $outputfile || { echo "failed converting $inputfile" ;}
  #basex -b\$inputfile=$inputfile xquery/elife2dar.xq > $outputfile || { echo "failed converting $inputfile" ;}
done
