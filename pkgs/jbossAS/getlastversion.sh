#!/bin/sh
F=$(mktemp)
wget --no-check-certificate -T 10 -q "$1" -O "$F"
md5sum=$(cat "$F"|md5sum|cut -d' ' -f1)
sed -i 's,<br/>,\0\n,g' "$F"
cat "$F" | grep -q '="http://download\.jboss\.org/jbossas/[^/]\+/.*/jboss-as-[0-9].*\.zip'
if [ $? -eq 0 ]; then
  cat "$F" | grep '="http://download\.jboss\.org/jbossas/[^/]\+/.*/jboss-as-[0-9].*\.zip' | sed 's,.*="http://download.*/.*jboss-as-\([^"]*\)\.zip".*,\1,' | grep -v -i 'alpha\|beta\|m[0-9]\|rc' | head -n 1
else
  if [ "$2" = "$md5sum" ]; then
    echo '0'
  else
    echo '-1'
  fi
fi
rm -f "$F"
