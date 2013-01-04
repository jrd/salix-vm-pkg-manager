#!/bin/bash

cd $(dirname $0)
export LANG=C

if [ -f ~/.metagen.lock ];then
  echo "Another metagen.sh instance seems to be running!"
  echo "Check with ps and remove the ~/.metagen.lock file if it is leftover somehow."
  exit 1
else
  touch ~/.metagen.lock
fi

function color {
  case "$1" in
    normal)
      echo -en '\033[00m'
      ;;
    red)
      echo -en '\033[31m'
      ;;
    green)
      echo -en '\033[32m'
      ;;
  esac
}

function info1 {
  echo ''
  color red
  echo "*** $1 ***"
  color normal
}

function info2 {
  color green
  echo "$1"
  color normal
}

function gen_packages_txt {
  info1 'PACKAGES.TXT'
  echo '' > PACKAGES.TXT
  for meta in `find . -path ./salixlive -prune -o -type f -name '*.meta' -print | sort`; do
    info2 "$meta"
    cat $meta >> PACKAGES.TXT
  done
  cat PACKAGES.TXT | gzip -9 -c - > PACKAGES.TXT.gz
}

function gen_meta {
  unset REQUIRED CONFLICTS SUGGESTS
  if [ ! -f $1 ]; then
    echo "File not found: $1"
    exit 1;
  fi
  if [ "`echo $1|grep -E '(.*{1,})\-(.*[\.\-].*[\.\-].*).t[glx]z[ ]{0,}$'`" == "" ]; then
    return;
  fi
  NAME=$(echo $1|sed -re "s/(.*\/)(.*.t[glx]z)$/\2/")
  LOCATION=$(echo $1|sed -re "s/(.*)\/(.*.t[glx]z)$/\1/")
  if [[ `echo $1 | grep "tgz$"` ]]; then
    SIZE=$( expr `gunzip -l $1 |tail -1|awk '{print $1}'` / 1024 )
    USIZE=$( expr `gunzip -l $1 |tail -1|awk '{print $2}'` / 1024 )
  elif [[ `echo $1 | grep "t[lx]z$"` ]]; then
    SIZE=$( expr `ls -l $1 | awk '{print $5}'` / 1024 )
    #USIZE is only an appoximation, nothing similar to gunzip -l for lzma yet
    USIZE=$[$SIZE * 4 ]
  fi
  
  METAFILE=${NAME%t[glx]z}meta
  
  if test -f $LOCATION/${NAME%t[glx]z}dep
  then
    REQUIRED="`cat $LOCATION/${NAME%t[glx]z}dep`"
  fi
  if test -f $LOCATION/${NAME%t[glx]z}con
  then
    CONFLICTS="`cat $LOCATION/${NAME%t[glx]z}con`"
  fi
  if test -f $LOCATION/${NAME%t[glx]z}sug
  then
    SUGGESTS="`cat $LOCATION/${NAME%t[glx]z}sug`"
  fi
  echo "PACKAGE NAME:  $NAME" > $LOCATION/$METAFILE
  if [ -n "$DL_URL" ]; then
    echo "PACKAGE MIRROR:  $DL_URL" >> $LOCATION/$METAFILE
  fi
  echo "PACKAGE LOCATION:  $LOCATION" >> $LOCATION/$METAFILE
  echo "PACKAGE SIZE (compressed):  $SIZE K" >> $LOCATION/$METAFILE
  echo "PACKAGE SIZE (uncompressed):  $USIZE K" >> $LOCATION/$METAFILE
  echo "PACKAGE REQUIRED:  $REQUIRED" >> $LOCATION/$METAFILE
  echo "PACKAGE CONFLICTS:  $CONFLICTS" >> $LOCATION/$METAFILE
  echo "PACKAGE SUGGESTS:  $SUGGESTS" >> $LOCATION/$METAFILE
  echo "PACKAGE DESCRIPTION:" >> $LOCATION/$METAFILE
  if test -f $LOCATION/${NAME%t[glx]z}txt
  then
    cat $LOCATION/${NAME%t[glx]z}txt |grep -E '[^[:space:]]*\:'|grep -v '^#' >> $LOCATION/$METAFILE
  else
    if [[ `echo $1 | grep "tgz$"` ]]; then
      tar xfO $1 install/slack-desc |grep -E '[^[:space:]]*\:'|grep -v '^#' >> $LOCATION/$METAFILE
      tar xfO $1 install/slack-desc |grep -E '[^[:space:]]*\:'|grep -v '^#' > $LOCATION/${NAME%t[glx]z}txt
    elif [[ `echo $1 | grep "t[lx]z$"` ]]; then
      xz -c -d $1 | tar xO install/slack-desc |grep -E '[^[:space:]]*\:'|grep -v '^#' >> $LOCATION/$METAFILE
      xz -c -d $1 | tar xO install/slack-desc |grep -E '[^[:space:]]*\:'|grep -v '^#' > $LOCATION/${NAME%t[glx]z}txt
    fi
  fi
  echo "" >> $LOCATION/$METAFILE
}


case "$1" in
  pkg)
    if [ -n "$2" ]; then
      gen_meta $2
    else
      echo "$0 [pkg [file]|all|new|PACKAGESTXT|md5]"
    fi
  ;;
  all)
    info1 'metagen all'
    for pkg in `find . -path ./salixlive -prune -o -type f -name '*-[0-9][a-z]*.t[glx]z' -print`; do
      info2 "$pkg"
      gen_meta "$pkg"
    done
    gen_packages_txt
  ;;
  new)
    cp PACKAGES.TXT .p
    cp CHECKSUMS.md5 .c
    find . -path ./salixlive -prune -o -type f -name '*-[0-9][a-z]*.t[glx]z' -print | while read pkg; do
      meta=${pkg%t[glx]z}meta
      md5=${pkg%t[glx]z}md5
      if [ ! -f $meta ]; then
        info2 "$pkg"
        gen_meta "$pkg"
      fi
      if [ ! -f $md5 ]; then
        info2 "$md5"
        md5sum ${pkg} | sed "s|  \.\(.*\)/\(.*\)|  \2|" > $md5
      fi
      f=$(basename "$pkg")
      frexp=$(echo "$f"|sed 's|\.|\\.|g')
      if ! grep -q "^PACKAGE NAME:  $frexp" .p; then
        grep '^PACKAGE NAME:' .p > .p1
        echo "PACKAGE NAME:  $f" >> .p1
        sort .p1 > .p2
        next=$(grep "^PACKAGE NAME:  $f" -A1 .p2 | tail -n+2)
        if [ -z "$next" ]; then
          cat "$meta" >> .p
        else
          n=$(sed -n "/$next/=" .p)
          n1=$(($n - 1))
          head -n$n1 .p > .p2
          cat "$meta" >> .p2
          tail -n+$n .p >> .p2
          mv .p2 .p
        fi
        cat $md5 | sed "s|$(basename ${pkg})|${pkg}|" >> .c
      fi
    done
    cp .p PACKAGES.TXT
    cat PACKAGES.TXT | gzip -9 -c - > PACKAGES.TXT.gz
    sort -k2 .c > CHECKSUMS.md5
    cat CHECKSUMS.md5 | gzip -9 -c - > CHECKSUMS.md5.gz
    rm -f .p .p1 .p2 .c
  ;;
  PACKAGESTXT)
    gen_packages_txt
  ;;
  md5)
    info1 'metagen md5'
    echo '' > CHECKSUMS.md5
    for pkg in `find . -path ./salixlive -prune -o -type f -name '*-[0-9][a-z]*.t[glx]z' -print | sort`; do
      if [ ! -f ${pkg%t[glx]z}md5 ]; then
        info2 "$pkg"
        md5sum ${pkg} | sed "s|  \.\(.*\)/\(.*\)|  \2|" > ${pkg%t[glx]z}md5
      fi
      cat ${pkg%t[glx]z}md5 | sed "s|`basename ${pkg}`|${pkg}|" >> CHECKSUMS.md5
    done
    cat CHECKSUMS.md5 | gzip -9 -c - > CHECKSUMS.md5.gz
  ;;
  *)
    echo "$0 [pkg [file]|all|new|PACKAGESTXT|MD5]"
    echo "$0 [miss|provide] pattern"
  ;;
esac

rm ~/.metagen.lock

