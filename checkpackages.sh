#!/bin/sh
cd $(dirname "$0")
C_NONE="\e[0m"
C_RED="\e[31;1m"
C_GREEN="\e[32;1m"
C_YELLOW="\e[33;1m"
C_BLUE="\e[34;1m"
C_WHITE="\e[37;1m"
C_GRAY="\e[37;0m"
grep -v '^[ \t]*#' packages.txt | grep -v '^[ \t]*$' | while read p; do
  todo=0
  [ -z "$1" ] && todo=1
  for arg in $@; do if [ "$p" = "$arg" ]; then todo=1; break; fi; done
  if [ $todo -eq 1 ]; then
    echo -en "${C_BLUE}[ ] Checking $p...${C_NONE}\r\e[50C"
    if [ -d "pkgs/$p" ]; then
      if [ ! -e pkgs/"$p"/getlastversion.sh -o ! -e pkgs/"$p"/url ]; then
        echo -en "${C_RED}Fail"
        echo -e "\r${C_RED}\e[1CX\e[11C$p\n    You must provide 'pkgs/$p/getlastversion.sh' and 'pkgs/$p/url'.${C_NONE}"
      else
        url=$(cat pkgs/"$p"/url 2>/dev/null)
        md5=$(cat pkgs/"$p"/md5sum 2>/dev/null)
        ver=$(cat pkgs/"$p"/version 2>/dev/null)
        ret=$(sh pkgs/"$p"/getlastversion.sh "$url" "$md5")
        if [ "$ret" = "-1" ]; then
          echo -en "${C_YELLOW}a new version is probably available"
          echo -e "\r${C_YELLOW}\e[1C%\e[11C$p${C_NONE}"
        elif [ "$ret" = "0" ]; then
          echo -en "${C_GREEN}seems up to date (${C_GRAY}$ver${C_GREEN})"
          echo -e "\r${C_GREEN}\e[1C*\e[11C$p${C_NONE}"
        else
          if [ "$ver" = "$ret" ]; then
            echo -en "${C_GREEN}up to date (${C_GRAY}$ver${C_GREEN})"
            echo -e "\r${C_GREEN}\e[1C-\e[11C$p${C_NONE}"
          else
            echo -en "${C_YELLOW}a new version (${C_WHITE}$ret${C_YELLOW}) is available (was ${C_GRAY}$ver${C_YELLOW})"
            echo -e "\r${C_YELLOW}\e[1CX\e[11C$p${C_NONE}"
          fi
        fi
      fi
    else
      echo -en "${C_RED}Fail"
      echo -e "\r${C_RED}\e[1CX\e[11C$p\n  ${C_WHITE}pkgs/$p doesn't exist, will create it. You must provide 'getlastversion.sh' and 'url' in it.${C_NONE}"
      mkdir -p pkgs/"$p"
    fi
  fi
done
