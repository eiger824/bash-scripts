# Reload bashrc
alias bashf5='source ~/.bashrc'

# Git aliases
alias gl='git log'
alias gs='git status'
alias gd='git diff'
alias gb='git branch'
alias gc='git checkout'

alias qq='exit'

if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	alias ls='ls --color=auto'
	alias grep='grep -n --color=auto'
	alias fgrep='fgrep -n --color=auto'
	alias egrep='egrep -n --color=auto'
fi

# Listing aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Use htop instead of top
alias top='htop'

alias bye='xfce4-session-logout --logout'

# Sort some outputs
alias lsmod='lsmod | sort'
alias env='env | sort'

# Complete output when cat-ing
alias ccat='cat -nA $1'

alias count='wc -l'

alias sl='sl -e'

alias ec='echo Return code was: $?'

complete -W "\`\grep -oE '^[a-zA-Z0-9_-]+:([^=]|$)' *file | sed 's/[^a-zA-Z0-9_-]*$//'\`" make
