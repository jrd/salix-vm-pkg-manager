#!/bin/sh
cd $(dirname $0)
pkg="$1"
BuildDir=~/Build
PkgDir=~/pkg
RemoteDir=~/Remote/salix
if [ -z "$pkg" ]; then
  echo "$0 package1 package2 ..."
  exit 1
fi
while [ -n "$pkg" ]; do
  echo -e "\nPublishing [$pkg]"
  if [ -e "$BuildDir"/"$pkg" ]; then
    [ -e "$PkgDir"/"$pkg" ] && rm -rf "$PkgDir"/"$pkg"
    cp -rv "$BuildDir"/"$pkg" "$PkgDir"/
    (
      cd "$BuildDir"/"$pkg"/
      slkbuild >/dev/null
    )
    sed -i '/^package=.*/ a\
return' "$BuildDir"/"$pkg"/build-"$pkg".sh
    . "$BuildDir"/"$pkg"/build-"$pkg".sh
    rm "$BuildDir"/"$pkg"/build-"$pkg".sh
    if [ -z "$arch" ]; then
      case "$(uname -m)" in
        i?86) arch=i486 ;;
        arm*) arch=arm ;;
        *) arch=$(uname -m) ;;
      esac
    fi
    connect.sh
    mkdir -p "$RemoteDir"/"$pkg"/"$pkgver-$arch-$pkgrel"
    rsync --inplace --progress -r "$BuildDir"/"$pkg"/* "$RemoteDir"/"$pkg"/"$pkgver-$arch-$pkgrel"/
    echo "$pkg published."
    shift
    pkg="$1"
  else
    echo "$BuildDir/$pkg n'existe pas"
    exit 1
  fi
done
echo "All published !"
