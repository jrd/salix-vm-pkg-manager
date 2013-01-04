#!/bin/sh
cd $(dirname "$0")
VER=0.1
C_NONE="\e[0m"
C_RED="\e[31;1m"
C_GREEN="\e[32;1m"
C_YELLOW="\e[33;1m"
C_BLUE="\e[34;1m"
C_WHITE="\e[37;1m"

syntax() {
  echo "$0 ACTION package1 package2 ..."
  echo "ACTION:"
  echo "  - url: show the URL"
  echo "  - openurl: open the URL"
  echo "  - version: show the version"
  echo "  - all: show all info"
}
version() {
  echo "version: $VER"
  echo "copyright: Cyrille Pontvieux <jrd@enialis.net>"
  echo "licence: GPLv2+"
}
error() {
  echo "$1" >&2
  echo
  syntax
  exit 1
}

ACTION=''
PKGS=()
while [ -n "$1" ]; do
  case "$1" in
    -h|--help)
      shift
      syntax
      exit 0
      ;;
    -v|--version)
      shift
      version
      exit 0
      ;;
    url|openurl|version)
      ACTION="$1"
      shift
      ;;
    all)
      ACTION="url version"
      shift
      ;;
    *)
      if [ -n "$ACTION" -a -d pkgs/"$1" ]; then
        PKGS=("${PKGS[@]}" "$1")
      else
        error "action $1 not recognized"
      fi
      shift
      ;;
  esac
done
if [ ${#PKGS[@]} -eq 0 ]; then
  syntax
  exit 1
fi
for p in "${PKGS[@]}"; do
  [ "$ACTION" != "openurl" ] && echo "$p:"
  for a in $ACTION; do
    case "$a" in
      url)
        echo -n "  url: "
        cat pkgs/"$p"/url
        ;;
      openurl)
        xdg-open $(cat pkgs/"$p"/url)
        ;;
      version)
        echo -n "  ver: "
        cat pkgs/"$p"/version
        ;;
      *)
        error "action $a not recognized"
        ;;
    esac
  done
done
