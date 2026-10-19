#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Replace GNU with Rust
alias ls='eza --icons=auto'
alias cat='bat -pp'

# Colorize GNU 
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'

alias sudo='sudo-rs'
alias doas='sudo-rs'

PS1='[\u@\h \W]\$ '

export MOZ_USE_XINPUT2=1
export EDITOR=vim
export MAKEFLAGS="-j$(nproc)"

__prompt_command() {
    local exit_code=$?
    local reset='\[\e[0m\]'
    local green='\[\e[1;32m\]'
    local cyan='\[\e[1;36m\]'
    local magenta='\[\e[1;35m\]'
    local red='\[\e[1;31m\]'

    local path="${PWD/#$HOME/\~}"
    (( ${#path} > 30 )) && path="…${path: -29}"

    local status=''
    (( exit_code != 0 )) && status="${red}${exit_code}${reset} "

    PS1="${status}${green}\u${reset}@${cyan}\h${reset} ${magenta}${path}${reset} \$ "
}
PROMPT_COMMAND=__prompt_command


# export PATH="~/.cargo/bin/:${PATH}"
# export PATH="~/.config/bin/:${PATH}"
alias w++='g++ -std=c++17 -Wall -Wextra -Wpedantic -Weffc++ -Wold-style-cast -g'

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

function f() {
	local proc="$1"
	"$proc" "$(fzf)"
}


[[ -r /usr/share/bash-completion/bash_completion ]] && \
  . /usr/share/bash-completion/bash_completion

fastfetch
