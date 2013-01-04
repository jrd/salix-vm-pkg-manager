#!/bin/sh
cd $(dirname "$0")
url=$(cat url)
F=$(mktemp)
wget --no-check-certificate -T 10 -q "$url" -O "$F"
md5sum=$(cat "$F"|md5sum|cut -d' ' -f1)
cat "$F" | grep -q '>Version [^<]*</font'
if [ $? -eq 0 ]; then
  ver=$(cat "$F" | grep '>Version [^<]*</font' | sed 's:.*>Version \([^<]*\)</font.*:\1:' | sort -r -V | head -n 1)
  echo "$md5sum" > md5sum
  echo "$ver" > version
fi
rm -f "$F"
