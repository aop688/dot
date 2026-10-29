# ~/.zprofile
# zsh 登录 shell 读取。用 sh 模拟模式加载 ~/.profile 里的通用环境变量（含 Homebrew）。
[ -f ~/.profile ] && emulate sh -c '. ~/.profile'
