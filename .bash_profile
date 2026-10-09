# ~/.bash_profile
# bash 登录 shell 只读这个文件（不会再读 ~/.profile 和 ~/.bashrc），
# 所以在这里手动加载：环境变量来自 ~/.profile，交互设置来自 ~/.bashrc。

[ -f ~/.profile ] && . ~/.profile

case $- in
  *i*) [ -f ~/.bashrc ] && . ~/.bashrc ;;
esac
