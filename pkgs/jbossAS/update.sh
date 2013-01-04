#!/bin/sh
cd $(dirname "$0")
url=$(cat url)
F=$(mktemp)
wget --no-check-certificate -T 10 -q "$url" -O "$F"
md5sum=$(cat "$F"|md5sum|cut -d' ' -f1)
sed -i 's,<br/>,\0\n,g' "$F"
cat "$F" | grep -q '="http://download\.jboss\.org/jbossas/[^/]\+/.*/jboss-as-[0-9].*\.zip'
if [ $? -eq 0 ]; then
  ver=$(cat "$F" | grep '="http://download\.jboss\.org/jbossas/[^/]\+/.*/jboss-as-[0-9].*\.zip' | sed 's,.*="http://download.*/.*jboss-as-\([^"]*\)\.zip".*,\1,' | grep -v -i 'alpha\|beta\|m[0-9]\|rc' | head -n 1)
  echo "$md5sum" > md5sum
  echo "$ver" > version
fi
rm -f "$F"
