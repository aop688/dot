# ~/.profile
# 登录 shell 的通用环境变量（POSIX sh 语法，sh/bash/dash 均可读取）。
# 这里只放 export 的环境变量，不要放 alias、函数、shopt、PS1 等交互设置——那些放 ~/.bashrc。

export BASH_SILENCE_DEPRECATION_WARNING=1

# locale
export LANG=en_US.UTF-8

# Homebrew（设置 PATH、MANPATH、INFOPATH、HOMEBREW_PREFIX 等）
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# GNU coreutils 覆盖 macOS 自带的 BSD 版本
if [ -d /opt/homebrew/opt/coreutils/libexec/gnubin ]; then
  export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:$PATH"
  export MANPATH="/opt/homebrew/opt/coreutils/libexec/gnuman:$MANPATH"
fi

#export PATH="/usr/local/opt/ncurses/bin:$PATH"
#export PATH="/usr/local/opt/m4/bin:$PATH"

#export C_INCLUDE_PATH="$(brew --prefix openssl)/include"
#export LIBRARY_PATH="$(brew --prefix openssl)/lib"

#export PYENV_ROOT="$HOME/.pyenv"
#[ -d "$PYENV_ROOT/bin" ] && export PATH="$PYENV_ROOT/bin:$PATH"
#eval "$(pyenv init -)"   # 这一行是交互设置，启用时放到 ~/.bashrc

### proxy setup（从系统代理设置读取）
#export http_proxy=`scutil --proxy | awk '/HTTPEnable/ { enabled = $3; } /HTTPProxy/ { server = $3; } /HTTPPort/ { port = $3; } END { if (enabled == "1") { print "http://" server ":" port; } }'`
#export https_proxy=`scutil --proxy | awk '/HTTPSEnable/ { enabled = $3; } /HTTPSProxy/ { server = $3; } /HTTPSPort/ { port = $3; } END { if (enabled == "1") { print "https://" server ":" port; } }'`
#export all_proxy=`scutil --proxy | awk '/SOCKSEnable/ { enabled = $3; } /SOCKSProxy/ {server = $3;} /SOCKSPort/ { port = $3 } END { if ( enabled == "1") { print "socks://" server ":" port; }}'`

# uv
export PATH="$HOME/.local/bin:$PATH"
# 私密变量（HF_TOKEN 等）放在不纳入仓库的 ~/.secrets
[ -f ~/.secrets ] && . ~/.secrets
