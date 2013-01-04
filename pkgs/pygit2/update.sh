#!/bin/sh
cd $(dirname "$0")
url=$(cat url)
F=$(mktemp)
wget --no-check-certificate -T 10 -q "$url" -O "$F"
md5sum=$(cat "$F"|md5sum|cut -d' ' -f1)
cat "$F" | grep -q 'a href="/libgit2/pygit2/zipball/v[0-9][^"]*" title="v'
if [ $? -eq 0 ]; then
  ver=$(cat "$F" | grep 'a href="/libgit2/pygit2/zipball/v[0-9][^"]*" title="v' | sed 's:.*title="v\([^"]*\)".*:\1:' | grep -v -i 'alpha\|beta\|rc' | head -n 1)
  echo "$md5sum" > md5sum
  echo "$ver" > version
fi
rm -f "$F"
