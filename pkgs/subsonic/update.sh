#!/bin/sh
cd $(dirname "$0")
url=$(cat url)
F=$(mktemp)
wget --no-check-certificate -T 10 -q "$url" -O "$F"
md5sum=$(cat "$F"|md5sum|cut -d' ' -f1)
cat "$F" | grep -q '>Latest stable release &ndash; Subsonic [^<]*</th'
if [ $? -eq 0 ]; then
  ver=$(cat "$F" | grep '>Latest stable release &ndash; Subsonic [^<]*</th' | sed 's:.*>Latest stable release &ndash; Subsonic \([^<]*\)</th.*:\1:' | head -n 1)
  echo "$md5sum" > md5sum
  echo "$ver" > version
fi
rm -f "$F"
