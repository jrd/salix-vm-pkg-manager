#!/bin/sh
cd $(dirname "$0")
d32=buildpkg32_14.0/pkg
d64=buildpkg64_14.0/pkg
if [ -z "$1" ]; then
  echo "syntax: $(basename "$0") package-name"
  exit 1
fi
pkg="$1"
cmd="./slkbuild-postgen"
# $1: package path
# $2: true if should generate .sug file too
# $3: true if should generate .con file too
# $4: true if this is the first arch to be shown
show_32() {
  pkgpath="$1"
  options=''
  [ "$2" = "true" ] && options="$options -sug"
  [ "$3" = "true" ] && options="$options -con"
  [ "$4" = "true" ] && filter='cat' || filter='tail -n+3'
  "$cmd" $options "$pkgpath" | $filter | sed "s/'''Homepage:'''/Homepage:/; s/'''Package:'''/Package 32:/; s/'''Log:'''/Log 32:/; s/'''Buildscript and source:'''/Buildscript and source 32:/"
}
show_64() {
  pkgpath="$1"
  options=''
  [ "$2" = "true" ] && options="$options -sug"
  [ "$3" = "true" ] && options="$options -con"
  [ "$4" = "true" ] && filter='cat' || filter='tail -n+3'
  "$cmd" $options "$pkgpath" | $filter | sed "s/'''Homepage:'''/Homepage:/; s/'''Package:'''/Package 64:/; s/'''Log:'''/Log 64:/; s/'''Buildscript and source:'''/Buildscript and source 64:/"
}
if [ -e $d32/$pkg ]; then
  archref=$d32
else
  if [ -e $d64/$pkg ]; then
    archref=$d64
  else
    echo "$pkg doesn't exist in $d32 nor $d64."
    exit 2
  fi
fi
firstone=true
if [ -d "$d32/$pkg" ]; then
  sug=false
  [ -e "$d32/$pkg/$pkg"-*.sug ] && sug=true
  con=false
  [ -e "$d32/$pkg/$pkg"-*.con ] && con=true
  show_32 "$d32/$pkg" "$sug" "$con" "$firstone"
  firstone=false
fi
if [ -d "$d64/$pkg" ]; then
  sug=false
  [ -e "$d64/$pkg/$pkg"-*.sug ] && sug=true
  con=false
  [ -e "$d64/$pkg/$pkg"-*.con ] && con=true
  show_64 "$d64/$pkg" "$sug" "$con" "$firstone"
  firstone=false
fi
