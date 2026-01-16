export BASH_SILENCE_DEPRECATION_WARNING=1

#if [ $TERM_PROGRAM = 'iTerm.app' ]; then
#        alias less='less -m -N -g -i -J --underline-special --SILENT'
#        test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
#fi

#if [ $TERM_PROGRAM = 'Apple_Terminal' ]; then
#export PS1="\$(__my_ps1)\\$ "
#fi

# kitty ssh fix
[[ "$TERM" == "xterm-kitty" ]] && alias ssh="TERM=xterm-256color ssh"
# kitty icat
[[ "$TERM" == "xterm-kitty" ]] && alias icat="kitty +kitten icat --align=left"

if [ -n "$KITTY_PID" ]; then
  printf '\033]2;Kitty\007'
fi

set_kitty_title() {
  local home="${HOME%/}"
  local path="$PWD"

  if [[ "$path" == "$home" ]]; then
    path="~"
  elif [[ "$path" == "$home"/* ]]; then
    path="~${path#$home}"
  fi

  local branch=""
  if branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); then
    printf "\033]0;%s %s\007" "$path" "$branch"
  else
    printf "\033]0;%s\007" "$path"
  fi
}

if [[ -z "$PROMPT_COMMAND" ]]; then
  PROMPT_COMMAND="set_kitty_title"
else
  case "$PROMPT_COMMAND" in
  *set_kitty_title*) ;;
  *) PROMPT_COMMAND="${PROMPT_COMMAND%;};set_kitty_title" ;;
  esac
fi

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# shell options
shopt -s checkwinsize # Make bash check its window size after a process completes
shopt -s cmdhist      # properly save multi-line commands
shopt -s histappend   # append instead of overwrite history
shopt -s lithist      # don't replace newlines with semicolons in history
shopt -s cdspell      # fix typos when changing directories
shopt -u hostcomplete # disable hostname completion, which is fine but

__my_ps1() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    echo "  $branch"
  fi
}
#export CLICOLOR=1
#export LSCOLORS=ExGxgxgxBxFxFxbxbxExEx
#export PS1="\[\e[1;35m\]\w\[\e[33;1m\]\$(__my_ps1) \[\e[m\]\\$ "
#export LSCOLORS="CxfxcxdxCxegedabagacad"
#export PS1='\[\e[1;32m\]\u@\h:\w\$\[\e[m\] '
#export PS1='$(ret=$?; echo "\[\e[1;36m\]\w\[\e[33;1m\]$(__my_ps1) $(if [ $ret -eq 0 ]; then echo \[\e[32m\]❯\[\e[m\]; else echo \[\e[31m\]❯\[\e[m\]; fi)") '
export PS1='\w$(__my_ps1) ❯ '

#alias blea='brew leaves | xargs brew deps --installed --for-each | sed "s/^.*:/$(tput setaf 4)&$(tput sgr0)/"'
#alias bdeps='brew deps --tree --installed'
alias now="date '+%Y-%m-%d %H:%M:%S'"
alias aplay="clear && ls . | while read;do basename \"\$REPLY\";afplay -q 1 \"\$REPLY\";wait;done"

man() {
  LESS_TERMCAP_md=$'\e[1;34m' \
    LESS_TERMCAP_me=$'\e[0m' \
    LESS_TERMCAP_se=$'\e[0m' \
    LESS_TERMCAP_so=$'\e[1;36m' \
    LESS_TERMCAP_ue=$'\e[0m' \
    LESS_TERMCAP_us=$'\e[1;32m' \
    command man "$@"
}

lsnc() {
  lsof -i -n -P -c 16 | awk '{print $1 "\t\t" $9 "  " $10}' | uniq | grep -v COMMAND | egrep -v "\->127.0.0.1:.*"
}

function sha256sum() { openssl sha256 "$@" | awk '{print $2}'; }

# aliases
alias more='less'
alias ls="ls --color=auto"
alias rm="rm -i"
alias l="ls -alh"
alias df='df -h'
#alias la="ls -alh"
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"
alias clmod="find . -type f -print0 | xargs -0 chmod 644"
alias cldir="find . -type d -print0 | xargs -0 chmod 744"
alias clfile="clmod && cldir"
#alias mpv="/Applications/mpv.app/Contents/MacOS/mpv"
#alias x="/usr/local/bin/trojan -c /usr/local/etc/config.json"
alias x="~/.xray-core/xray"
alias pon="networksetup -setsocksfirewallproxystate Wi-Fi on;networksetup -setwebproxystate Wi-Fi on;networksetup -setsecurewebproxystate Wi-Fi on"
alias poff="networksetup -setsocksfirewallproxystate Wi-Fi off;networksetup -setwebproxystate Wi-Fi off;networksetup -setsecurewebproxystate Wi-Fi off"
alias epp="export https_proxy=http://127.0.0.1:1081;export http_proxy=http://127.0.0.1:1081;export all_proxy=socks5://127.0.0.1:1080"
alias batt="pmset -g batt"
alias ipen0="ipconfig getifaddr en0"
alias nosleep='caffeinate -d -i -t 1800'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
take() { mkdir -p "$1" && cd "$1"; }
alias cp='cp -v'
alias mv='mv -v'
#alias batt="pmset -g batt | grep -Eo '\d+%'"
ip() { ipconfig getifaddr "$1"; }
### Do the proxy setup
#export http_proxy=`scutil --proxy | awk '/HTTPEnable/ { enabled = $3; } /HTTPProxy/ { server = $3; } /HTTPPort/ { port = $3; } END { if (enabled == "1") { print "http://" server ":" port; } }'`
#export https_proxy=`scutil --proxy | awk '/HTTPSEnable/ { enabled = $3; } /HTTPSProxy/ { server = $3; } /HTTPSPort/ { port = $3; } END { if (enabled == "1") { print "https://" server ":" port; } }'`
#export PATH="/usr/local/opt/ncurses/bin:$PATH"
#export PATH="/usr/local/opt/m4/bin:$PATH"
#export all_proxy=`scutil --proxy | awk '/SOCKSEnable/ { enabled = $3; } /SOCKSProxy/ {server = $3;} /SOCKSPort/ { port = $3 } END { if ( enabled == "1") { print "socks://" server ":" port; }}'`

eval "$(/opt/homebrew/bin/brew shellenv)"

#export PYENV_ROOT="$HOME/.pyenv"
#[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
#eval "$(pyenv init -)"
