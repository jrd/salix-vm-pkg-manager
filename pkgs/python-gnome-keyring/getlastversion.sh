#!/bin/sh
F=$(mktemp)
wget --no-check-certificate -T 10 -q "$1" -O "$F"
md5sum=$(cat "$F"|md5sum|cut -d' ' -f1)
[ -s "$F" ]
if [ $? -eq 0 ]; then
  cat "$F" | python -c 'import sys,json;data=json.loads(sys.stdin.read());print data[2]["gnome-python-desktop"][-1];'
else
  if [ "$2" = "$md5sum" ]; then
    echo '0'
  else
    echo '-1'
  fi
fi
rm -f "$F"
