#!/bin/bash

# texture clone and install
if [ ! -d texture ]; then
    git clone https://github.com/elifesciences/texture
fi
cd texture

# for now checkout a specific commit that is compatible
git reset --hard d65a0bfeb73a7a332511d269981e8d5bc8c01e36
npm install
node make clean
node make build:schema schema:texture-article build:lib build:test-assets
cd ..

# elife-article-xml clone and install
if [ ! -d elife-article-xml ]; then
    git clone https://github.com/elifesciences/elife-article-xml
fi
cd elife-article-xml
git pull origin master
cd ..
