#!/bin/sh
cd $(dirname "$0")
url=$(cat url)
F=$(mktemp)
wget --no-check-certificate -T 10 -q "$url" -O "$F"
md5sum=$(cat "$F"|md5sum|cut -d' ' -f1)
cat "$F" | grep -q 'href='"'"'postgis-.*\.tar\.gz'"'"
if [ $? -eq 0 ]; then
  ver=$(cat "$F" | grep 'href='"'"'postgis-.*\.tar\.gz'"'" | sed 's/.*href='"'"'postgis-\(.*\)\.tar\.gz'"'"'.*/\1/' | grep -v -i 'rc\|svn' | sort -r -V | head -n 1)
  echo "$md5sum" > md5sum
  echo "$ver" > version
fi
rm -f "$F"
