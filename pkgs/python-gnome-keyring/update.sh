#!/bin/sh
cd $(dirname "$0")
url=$(cat url)
F=$(mktemp)
wget --no-check-certificate -T 10 -q "$url" -O "$F"
md5sum=$(cat "$F"|md5sum|cut -d' ' -f1)
[ -s "$F" ]
if [ $? -eq 0 ]; then
  ver=$(cat "$F" | python -c 'import sys,json;data=json.loads(sys.stdin.read());print data[2]["gnome-python-desktop"][-1];')
  echo "$md5sum" > md5sum
  echo "$ver" > version
fi
rm -f "$F"
