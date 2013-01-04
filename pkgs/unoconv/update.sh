#!/bin/sh
cd $(dirname "$0")
url=$(cat url)
F=$(mktemp)
wget --no-check-certificate -T 10 -q "$url" -O "$F"
md5sum=$(cat "$F"|md5sum|cut -d' ' -f1)
cat "$F" | grep -q 'or grab the latest <b>[^>]*</b> tarball at'
if [ $? -eq 0 ]; then
  ver=$(cat "$F" | grep 'or grab the latest <b>[^>]*</b> tarball at' | sed 's:.*or grab the latest <b>\([^>]*\)</b> tarball at.*:\1:')
  echo "$md5sum" > md5sum
  echo "$ver" > version
fi
rm -f "$F"
