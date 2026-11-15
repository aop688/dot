# ~/.bash_profile

[ -f ~/.profile ] && . ~/.profile

case $- in
  *i*) [ -f ~/.bashrc ] && . ~/.bashrc ;;
esac

maxbright() {
  osascript <<'APPLESCRIPT'
repeat 16 times
  tell application "System Events" to key code 144
end repeat
APPLESCRIPT
}
