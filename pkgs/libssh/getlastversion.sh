#!/bin/sh
F=$(mktemp)
wget --no-check-certificate -T 10 -q "$1" -O "$F"
md5sum=$(cat "$F"|md5sum|cut -d' ' -f1)
cat "$F" | grep -q '<h2 class="entry-title"><a .*>libssh .*</a></h2>'
if [ $? -eq 0 ]; then
  cat "$F" | grep '<h2 class="entry-title"><a .*>libssh .*</a></h2>' | sed 's:.*<h2 class="entry-title"><a .*>libssh \(.*\)</a></h2>.*:\1:' | sort -r -V | head -n 1
else
  if [ "$2" = "$md5sum" ]; then
    echo '0'
  else
    echo '-1'
  fi
fi
rm -f "$F"
