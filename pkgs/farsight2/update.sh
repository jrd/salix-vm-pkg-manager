#!/bin/sh
cd $(dirname "$0")
url=$(cat url)
F=$(mktemp)
wget --no-check-certificate -T 10 -q "$url" -O "$F"
md5sum=$(cat "$F"|md5sum|cut -d' ' -f1)
cat "$F" | grep -q 'farsight2-.*\.tar\.gz'
if [ $? -eq 0 ]; then
  ver=$(cat "$F" | grep 'farsight2-.*\.tar\.gz' | sed 's/.*farsight2-\(.*\)\.tar\.gz.*/\1/' | sort -r -V | head -n 1)
  echo "$md5sum" > md5sum
  echo "$ver" > version
fi
rm -f "$F"
