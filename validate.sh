#!/bin/bash

# note: can just validate a set of files with regex e.g. '.*4[0-9][0-9][0-9][0-9]-v[1-9].xml' | sort`
for xmlfile in `find ./output -type f -regex '.*.xml' | sort`
do
  cp $xmlfile texture/data/kitchen-sink/manuscript.xml
  cd texture
  output=$(node make build:test-assets && node --require esm test/Persistence.test.js)
  cd ..
  # check for pass or fail
  if [[ $output =~ '# ok'$ ]]; then
    echo "PASS: $xmlfile"
  else
    echo "FAIL: $xmlfile"
    output_detail="$1"
    if [[ $output_detail =~ ^'detail'$ ]]; then
      echo "$output"
    fi
  fi

done
