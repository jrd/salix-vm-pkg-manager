
# Check for bash
[ -z "$BASH_VERSION" ] && return

################################################################################

__publish() {
  local folder cur choice
  folder=$(dirname ${COMP_WORDS[0]})/buildpkg
  cur=${COMP_WORDS[COMP_CWORD]}
  choice="$(for d in "$folder"/*; do [ -d "$d" ] && echo "$d"; done | sed "s:$folder/::")"
  COMPREPLY=($(compgen -W '$choice' -- "$cur"))
}

################################################################################

complete -F __publish publish.sh
