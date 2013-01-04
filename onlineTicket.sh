#!/bin/sh
cd $(dirname "$0")
tmp=$(mktemp -d)
if [ -z "$2" ]; then
  echo "syntax: $(basename "$0") 32|64 url1 url2 ..."
  exit 1
fi
arch="$1"
shift
cmd="$PWD"/slkbuild-postgen
# $1: package path
# $2: true if should generate .sug file too
# $3: true if should generate .con file too
# $4: arch
show() {
  pkgpath="$1"
  options=''
  [ "$2" = "true" ] && options="$options -sug"
  [ "$3" = "true" ] && options="$options -con"
  echo "$cmd" $options "$pkgpath" | sed "s/'''Homepage:'''/Homepage:/; s/'''Package:'''/Package $4:/; s/'''Log:'''/Log $4:/; s/'''Buildscript and source:'''/Buildscript and source $4:/"
  "$cmd" $options "$pkgpath" | sed "s/'''Homepage:'''/Homepage:/; s/'''Package:'''/Package $4:/; s/'''Log:'''/Log $4:/; s/'''Buildscript and source:'''/Buildscript and source $4:/"
}
(
  cd $tmp
  wget "$@"
  sug=false
  [ -e *-*.sug ] && sug=true
  con=false
  [ -e *-*.con ] && con=true
  show "$tmp"/SLKBUILD "$sug" "$con" "$arch"
)
rm -rf $tmp
