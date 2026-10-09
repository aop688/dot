# ~/.bashrc
# 交互式 bash 的设置：shell 选项、提示符、alias、函数、补全。
# 非登录的交互 bash 直接读取本文件；登录 bash 由 ~/.bash_profile 加载本文件。

# 非交互 shell（脚本、scp 等）直接返回
[[ $- != *i* ]] && return

# ---------------------------------------------------------------- shell options
shopt -s checkwinsize # Make bash check its window size after a process completes
shopt -s cmdhist      # properly save multi-line commands
shopt -s histappend   # append instead of overwrite history
shopt -s lithist      # don't replace newlines with semicolons in history
shopt -s cdspell      # fix typos when changing directories
shopt -u hostcomplete # disable hostname completion, which is fine but

# ---------------------------------------------------------------- completion
[[ -r "/opt/homebrew/etc/profile.d/bash_completion.sh" ]] && . "/opt/homebrew/etc/profile.d/bash_completion.sh"

# ---------------------------------------------------------------- prompt
__my_ps1() {
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    echo "  $branch"
  fi
}

# PS1 是 bash 专用的格式，不 export，避免子进程里的 sh/zsh 继承
PS1='\[\033[01;32m\]\u@\h:\[\033[01;34m\]\w \$\[\033[00m\] '
#PS1="\[\e[1;35m\]\w\[\e[33;1m\]\$(__my_ps1) \[\e[m\]\\$ "
#PS1='\[\e[1;32m\]\u@\h:\w\$\[\e[m\] '
#PS1='$(ret=$?; echo "\[\e[1;36m\]\w\[\e[33;1m\]$(__my_ps1) $(if [ $ret -eq 0 ]; then echo \[\e[32m\]❯\[\e[m\]; else echo \[\e[31m\]❯\[\e[m\]; fi)") '
#PS1='\w$(__my_ps1) \$ '

#export CLICOLOR=1
#export LSCOLORS=ExGxgxgxBxFxFxbxbxExEx
#export LSCOLORS="CxfxcxdxCxegedabagacad"

# ---------------------------------------------------------------- terminal
#if [ "$TERM_PROGRAM" = 'iTerm.app' ]; then
#        alias less='less -m -N -g -i -J --underline-special --SILENT'
#        test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"
#fi

#if [ "$TERM_PROGRAM" = 'Apple_Terminal' ]; then
#PS1="\$(__my_ps1)\\$ "
#fi

# 窗口标题：当前目录 + git 分支
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

# ---------------------------------------------------------------- aliases
# alias 和函数与 zsh 共用
[ -f ~/.aliases ] && . ~/.aliases
