#
# ~/.bashrc
#

# Configure fnm for alpine
type fnm &> /dev/null && eval "$(fnm env --shell bash)"
[[ "$(gcc -dumpmachine)" == 'x86_64-unknown-linux-gnu' ]] && export FNM_ARCH=x64-musl

export PATH="$HOME/go/bin:$PATH"

[[ -z "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# If not running interactively, don't do more
[[ $- != *i* ]] && return

# Replace GNU with Rust
alias ls='eza --icons=auto'
alias cat='bat -pp'

# Verbose
alias cp='cp -v'
alias mv='mv -v'
alias rm='rm -v'
alias ln='ln -v'
alias rmdir='rmdir -v'
alias chmod='chmod -v'
alias chown='chown -v'

# Colorize GNU 
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'

alias doas='sudo'
alias vim='nvim'

alias shared='sshfs shipon:/home/otro /mnt/lysator; gocryptfs /mnt/lysator/shared.encrypted /mnt/shared'

PS1='[\u@\h \W]\$ '

export MOZ_USE_XINPUT2=1
export QT_QPA_PLATFORMTHEME=qt5ct:qt6ct

export EDITOR=nvim
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


alias w++='g++ -std=c++17 -Wall -Wextra -Wpedantic -Weffc++ -Wold-style-cast -g'

function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

function s() {
	local proc="$1"
	"$proc" "$(sk)"
}


[[ -r /usr/share/bash-completion/bash_completion ]] && \
  . /usr/share/bash-completion/bash_completion


type fastfetch &> /dev/null && fastfetch

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
