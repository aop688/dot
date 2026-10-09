(setq initial-frame-alist '((width . 148) (height . 46)))

(setenv "MACOSX_DEPLOYMENT_TARGET" "27.0")
(with-eval-after-load 'comp
  (add-to-list 'native-comp-driver-options "-mmacosx-version-min=27.0"))


;; 1. 指定使用 Homebrew 的 bash（放在最前面）
(setq shell-file-name "/opt/homebrew/bin/bash")          ; M-!、compile 等用
(setq explicit-shell-file-name "/opt/homebrew/bin/bash") ; M-x shell 用
(setenv "SHELL" "/opt/homebrew/bin/bash")                ; 让子进程也看到

;; 2. 用这个 bash 读取 profile，同步环境变量
(use-package exec-path-from-shell
  :ensure t
  :if (memq window-system '(mac ns))
  :config
  (setq exec-path-from-shell-shell-name "/opt/homebrew/bin/bash")
  (setq exec-path-from-shell-arguments '("-l"))  ; 以登录 shell 运行，会读 ~/.bash_profile
  ;; 需要同步的变量，按需增减
  (setq exec-path-from-shell-variables
        '("PATH" "MANPATH" "LANG" "LC_ALL"))
  (exec-path-from-shell-initialize))
