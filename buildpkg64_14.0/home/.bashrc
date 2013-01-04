export PS1='\u[\W]\$ '
export PAGER="most"
export PATH=$PATH:$HOME/bin

if [ -f ~/.bash_aliases ]; then
	. ~/.bash_aliases
fi

if [ -d ~/.bash_completion.d ]; then
  for f in ~/.bash_completion.d/*; do
    [ -x $f ] && . $f
  done
fi
