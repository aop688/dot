# ~/.bashrc
# 交互式 bash 的设置：shell 选项、提示符、alias、函数、补全。
# 非登录的交互 bash 直接读取本文件；登录 bash 由 ~/.bash_profile 加载本文件。

[[ $- != *i* ]] && return

shopt -s checkwinsize # Make bash check its window size after a process completes
shopt -s cmdhist      # properly save multi-line commands
shopt -s histappend   # append instead of overwrite history
shopt -s lithist      # don't replace newlines with semicolons in history
shopt -s cdspell      # fix typos when changing directories
shopt -u hostcomplete # disable hostname completion, which is fine but

[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

__my_ps1() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    echo "  $branch"
  fi
}

PS1='\[\033[01;32m\]\u@\h:\[\033[01;34m\]\w \$\[\033[00m\] '


export CLICOLOR=1
export LSCOLORS="exfxcxdxCxegedabagacad"
export LS_COLORS="ex=01;32:di=01;34:ln=01;36"


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

[ -f ~/.aliases ] && . ~/.aliases
