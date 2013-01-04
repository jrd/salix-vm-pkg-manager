#!/bin/sh
F=$(mktemp)
wget --no-check-certificate -T 10 -q "$1" -O "$F"
md5sum=$(cat "$F"|md5sum|cut -d' ' -f1)
cat "$F" | grep -q 'a href="/libgit2/pygit2/zipball/v[0-9][^"]*" title="v'
if [ $? -eq 0 ]; then
  cat "$F" | grep 'a href="/libgit2/pygit2/zipball/v[0-9][^"]*" title="v' | sed 's:.*title="v\([^"]*\)".*:\1:' | grep -v -i 'alpha\|beta\|rc' | head -n 1
else
  if [ "$2" = "$md5sum" ]; then
    echo '0'
  else
    echo '-1'
  fi
fi
rm -f "$F"
