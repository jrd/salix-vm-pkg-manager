#!/bin/sh
cd $(dirname "$0")
url=$(cat url)
F=$(mktemp)
wget --no-check-certificate -T 10 -q "$url" -O "$F"
md5sum=$(cat "$F"|md5sum|cut -d' ' -f1)
cat "$F" | grep -q 'La dernière version de Gajim est'
if [ $? -eq 0 ]; then
  ver=$(cat "$F" | grep 'La dernière version de Gajim est' | sed 's:.*<strong>\(.*\)</strong>.*:\1:')
  echo "$md5sum" > md5sum
  echo "$ver" > version
fi
rm -f "$F"
