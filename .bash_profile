# ~/.bash_profile

[ -f ~/.profile ] && . ~/.profile

case $- in
  *i*) [ -f ~/.bashrc ] && . ~/.bashrc ;;
esac
