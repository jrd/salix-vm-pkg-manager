#!/bin/sh
F=$(mktemp)
wget --no-check-certificate -T 10 -q "$1" -O "$F"
md5sum=$(cat "$F"|md5sum|cut -d' ' -f1)
cat "$F" | grep -q '/thunar-vcs-plugin-[^<]*\.tar\.bz2</a'
if [ $? -eq 0 ]; then
  cat "$F" | grep '/thunar-vcs-plugin-[^<]*\.tar\.bz2</a' | sed 's:.*/thunar-vcs-plugin-\([^<]*\)\.tar\.bz2</a.*:\1:' | sort -r -V | head -n 1
else
  if [ "$2" = "$md5sum" ]; then
    echo '0'
  else
    echo '-1'
  fi
fi
rm -f "$F"