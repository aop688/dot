;; Minimal Emacs Configuration

(setq custom-file "~/.emacs.custom.el")
(package-initialize)
(add-to-list 'load-path "~/.emacs.local/")

;; Package Management
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(defvar rc/package-contents-refreshed nil)
(defun rc/package-refresh-contents-once ()
  (unless rc/package-contents-refreshed
    (setq rc/package-contents-refreshed t)
    (package-refresh-contents)))
(defun rc/require-one-package (package)
  (unless (package-installed-p package)
    (rc/package-refresh-contents-once)
    (package-install package)))
(defun rc/require (&rest packages)
  (dolist (package packages)
    (rc/require-one-package package)))
(defun rc/require-theme (theme)
  (let ((theme-package (intern (concat (symbol-name theme) "-theme"))))
    (rc/require theme-package)
    (load-theme theme t)))
(rc/require 'dash 'dash-functional)
(require 'dash)
(require 'dash-functional)

;; macOS
(setq mac-command-modifier 'meta
      mac-option-modifier 'super
      ns-use-native-fullscreen t
      mouse-wheel-scroll-amount '(1 ((shift) . 5))
      mouse-wheel-progressive-speed nil)
(when (memq window-system '(mac ns))
  (rc/require 'exec-path-from-shell)
  (exec-path-from-shell-initialize))
(setq select-enable-clipboard t)

;; Appearance
(defun rc/get-default-font ()
  (cond ((eq system-type 'darwin) "Menlo-14")
        ((eq system-type 'windows-nt) "Consolas-13")
        ((eq system-type 'gnu/linux) "Iosevka-20")))
(add-to-list 'default-frame-alist `(font . ,(rc/get-default-font)))
(when (display-graphic-p)
  (tool-bar-mode 0)
  (scroll-bar-mode 0))
(menu-bar-mode 0)
(column-number-mode 1)
(show-paren-mode 1)
(rc/require-theme 'gruber-darker)
(set-face-attribute 'minibuffer-prompt nil :foreground "yellow")
(setq initial-scratch-message ";; Happy Hacking!\n")
(when (version<= "26.0.50" emacs-version)
  (setq display-line-numbers-type 'relative)
  (global-display-line-numbers-mode))

;; Basic Settings
(setq-default inhibit-splash-screen t
              make-backup-files nil
              tab-width 4
              indent-tabs-mode nil
              compilation-scroll-output 'first-error
              default-input-method "russian-computer")
(setq confirm-kill-emacs 'y-or-n-p
      visible-bell (equal system-type 'windows-nt))
(windmove-default-keybindings)
(setq x-alt-keysym 'meta)

;; ido & smex
(rc/require 'smex 'ido-completing-read+)
(require 'ido-completing-read+)
(ido-mode 1)
(ido-everywhere 1)
(ido-ubiquitous-mode 1)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

;; Dired
(require 'dired-x)
(setq dired-omit-files (concat dired-omit-files "\\|^\\..+$")
      dired-dwim-target t
      dired-listing-switches "-alh"
      dired-mouse-drag-files t)
(setq dired-use-ls-dired nil)

;; Helm
(rc/require 'helm)
(setq helm-ff-transformer-show-only-basename nil)
(global-set-key (kbd "C-c h x") 'helm-M-x)
(global-set-key (kbd "C-c h f") 'helm-find-files)
(global-set-key (kbd "C-c h b") 'helm-buffers-list)
(global-set-key (kbd "C-c h r") 'helm-recentf)
(global-set-key (kbd "C-c h g") 'helm-grep-do-git-grep)
(global-set-key (kbd "C-c h o") 'helm-occur)

;; Magit
(rc/require 'cl-lib 'magit)
(setq magit-auto-revert-mode nil)
(global-set-key (kbd "C-c m s") 'magit-status)
(global-set-key (kbd "C-c m l") 'magit-log)

;; Company
(rc/require 'company)
(global-company-mode)

;; YASnippet
(rc/require 'yasnippet)
(setq yas-snippet-dirs '("~/.emacs.snippets/"))
(yas-global-mode 1)

;; Multiple Cursors
(rc/require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
(global-set-key (kbd "C-\"") 'mc/skip-to-next-like-this)
(global-set-key (kbd "C-:") 'mc/skip-to-previous-like-this)

;; Paredit
(rc/require 'paredit)
(defun rc/turn-on-paredit () (paredit-mode 1))
(dolist (hook '(emacs-lisp-mode-hook clojure-mode-hook lisp-mode-hook
                common-lisp-mode-hook scheme-mode-hook racket-mode-hook))
  (add-hook hook 'rc/turn-on-paredit))

;; Move Text
(rc/require 'move-text)
(global-set-key (kbd "M-p") 'move-text-up)
(global-set-key (kbd "M-n") 'move-text-down)

;; C/C++
(setq-default c-basic-offset 4
              c-default-style '((java-mode . "java") (awk-mode . "awk") (other . "bsd")))
(add-hook 'c-mode-hook (lambda () (c-toggle-comment-style -1)))

;; simpc-mode
(add-to-list 'load-path "~/.emacs.d/simpc-mode/")
(require 'simpc-mode nil t)
(add-to-list 'auto-mode-alist '("\\.[hc]\\(pp\\)?\\'" . simpc-mode))
(add-to-list 'auto-mode-alist '("\\.[b]\\'" . simpc-mode))

(defun astyle-buffer (&optional justify)
  (interactive)
  (let ((saved-line-number (line-number-at-pos)))
    (shell-command-on-region (point-min) (point-max) "astyle --style=kr" nil t)
    (goto-line saved-line-number)))
(add-hook 'simpc-mode-hook
          (lambda () (setq-local fill-paragraph-function 'astyle-buffer)))

;; Compilation
(require 'compile)
(add-to-list 'compilation-error-regexp-alist
             '("\\([a-zA-Z0-9\\.]+\\)(\\([0-9]+\\)\\(,\\([0-9]+\\)\\)?) \\(Warning:\\)?" 1 2 (4) (5)))
(add-to-list 'display-buffer-alist
             '("\\*compilation\\*" (display-buffer-reuse-window display-buffer-at-bottom)
               (window-height . 0.3) (reusable-frames . visible)))

;; Whitespace
(setq whitespace-style '(face tabs spaces trailing space-before-tab newline indentation empty
                              space-after-tab space-mark tab-mark))
(defun rc/set-up-whitespace-handling ()
  (whitespace-mode 1)
  (add-to-list 'write-file-functions 'delete-trailing-whitespace))
(dolist (hook '(tuareg-mode-hook c++-mode-hook c-mode-hook simpc-mode-hook emacs-lisp-mode-hook
                java-mode-hook lua-mode-hook rust-mode-hook scala-mode-hook markdown-mode-hook
                haskell-mode-hook python-mode-hook erlang-mode-hook asm-mode-hook fasm-mode-hook
                go-mode-hook nim-mode-hook yaml-mode-hook))
  (add-hook hook 'rc/set-up-whitespace-handling))

;; Haskell
(rc/require 'haskell-mode)
(setq haskell-process-type 'cabal-new-repl haskell-process-log t)
(add-hook 'haskell-mode-hook 'haskell-indent-mode)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)
(add-hook 'haskell-mode-hook 'haskell-doc-mode)

;; TypeScript
(rc/require 'typescript-mode 'tide)
(add-to-list 'auto-mode-alist '("\\.mts\\'" . typescript-mode))
(defun rc/turn-on-tide-and-flycheck ()
  (tide-setup)
  (flycheck-mode 1))
(add-hook 'typescript-mode-hook 'rc/turn-on-tide-and-flycheck)

;; Assembly
(require 'basm-mode nil t)
(require 'fasm-mode nil t)
(add-to-list 'auto-mode-alist '("\\.asm\\'" . fasm-mode))

;; nXML
(add-to-list 'auto-mode-alist '("\\.html\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.xsd\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.ant\\'" . nxml-mode))

;; TRAMP
(setq tramp-auto-save-directory "/tmp")

;; PowerShell
(rc/require 'powershell)
(add-to-list 'auto-mode-alist '("\\.ps1\\'" . powershell-mode))
(add-to-list 'auto-mode-alist '("\\.psm1\\'" . powershell-mode))

;; LaTeX
(add-hook 'tex-mode-hook (lambda () (add-to-list 'tex-verbatim-environments "code")))
(setq font-latex-fontify-sectioning 'color)

;; Word Wrap
(defun rc/enable-word-wrap () (toggle-word-wrap 1))
(add-hook 'markdown-mode-hook 'rc/enable-word-wrap)

;; Emacs Lisp
(add-hook 'emacs-lisp-mode-hook
          (lambda () (local-set-key (kbd "C-c C-j") 'eval-print-last-sexp)))
(add-to-list 'auto-mode-alist '("Cask" . emacs-lisp-mode))
(add-hook 'emacs-lisp-mode-hook 'eldoc-mode)

;; Compilation Colorization
(require 'ansi-color)
(defun rc/colorize-compilation-buffer ()
  (read-only-mode 'toggle)
  (ansi-color-apply-on-region compilation-filter-start (point))
  (read-only-mode 'toggle))
(add-hook 'compilation-filter-hook 'rc/colorize-compilation-buffer)

;; Utility Functions
(global-set-key (kbd "C-x C-g") 'find-file-at-point)
(global-set-key (kbd "C-c i m") 'imenu)

(defun rc/buffer-file-name ()
  (if (equal major-mode 'dired-mode) default-directory (buffer-file-name)))

(defun rc/parent-directory (path)
  (file-name-directory (directory-file-name path)))

(defun rc/root-anchor (path anchor)
  (cond ((string= anchor "") nil)
        ((file-exists-p (concat (file-name-as-directory path) anchor)) path)
        ((string-equal path "/") nil)
        (t (rc/root-anchor (rc/parent-directory path) anchor))))

(defun rc/put-file-name-on-clipboard ()
  (interactive)
  (let ((filename (rc/buffer-file-name)))
    (when filename (kill-new filename) (message filename))))

(defun rc/clipboard-org-mode-file-link (anchor)
  (interactive "sRoot anchor: ")
  (let* ((root-dir (rc/root-anchor default-directory anchor))
         (org-mode-file-link (format "file:%s::%d"
                                     (if root-dir (file-relative-name (rc/buffer-file-name) root-dir)
                                       (rc/buffer-file-name))
                                     (line-number-at-pos))))
    (kill-new org-mode-file-link)
    (message org-mode-file-link)))

(defun rc/unfill-paragraph ()
  (interactive)
  (let ((fill-column 90002000))
    (fill-paragraph nil)))
(global-set-key (kbd "C-c M-q") 'rc/unfill-paragraph)

(defun rc/duplicate-line ()
  (interactive)
  (let ((column (- (point) (point-at-bol)))
        (line (string-remove-suffix "\n" (or (thing-at-point 'line t) ""))))
    (move-end-of-line 1)
    (newline)
    (insert line)
    (move-beginning-of-line 1)
    (forward-char column)))
(global-set-key (kbd "C-,") 'rc/duplicate-line)

(defun rc/insert-timestamp ()
  (interactive)
  (insert (format-time-string "(%Y%m%d-%H%M%S)" nil t)))
(global-set-key (kbd "C-x p d") 'rc/insert-timestamp)

(defun rc/rgrep-selected (beg end)
  (interactive (if (use-region-p) (list (region-beginning) (region-end))
                 (list (point-min) (point-min))))
  (rgrep (buffer-substring-no-properties beg end) "*" (pwd)))
(global-set-key (kbd "C-x p s") 'rc/rgrep-selected)

(defun rc/load-path-here ()
  (interactive)
  (add-to-list 'load-path default-directory))

(defconst rc/frame-transparency 85)
(defun rc/toggle-transparency ()
  (interactive)
  (let ((frame-alpha (frame-parameter nil 'alpha)))
    (if (or (not frame-alpha) (= (cadr frame-alpha) 100))
        (set-frame-parameter nil 'alpha `(,rc/frame-transparency ,rc/frame-transparency))
      (set-frame-parameter nil 'alpha '(100 100)))))

(defun bf-pretty-print-xml-region (begin end)
  (interactive "r")
  (save-excursion
    (nxml-mode)
    (goto-char begin)
    (while (search-forward-regexp ">[ \\t]*<" nil t)
      (backward-char) (insert "\n"))
    (indent-region begin end)))

;; Org Mode
(global-set-key (kbd "C-x a") 'org-agenda)
(global-set-key (kbd "C-c C-x j") 'org-clock-jump-to-current-clock)
(setq org-agenda-files '("~/Documents/Agenda/")
      org-export-backends '(md))

(setq org-agenda-custom-commands
      '(("u" "Unscheduled" tags "+personal-SCHEDULED={.+}-DEADLINE={.+}/!+TODO"
         ((org-agenda-sorting-strategy '(priority-down))))
        ("p" "Personal" ((agenda "" ((org-agenda-tag-filter-preset '("+personal"))))))
        ("w" "Work" ((agenda "" ((org-agenda-tag-filter-preset '("+work"))))))))

(defun rc/org-get-heading-name ()
  (nth 4 (org-heading-components)))

(defun rc/org-kill-heading-name-save ()
  (interactive)
  (let ((heading-name (rc/org-get-heading-name)))
    (kill-new heading-name)
    (message "Kill \"%s\"" heading-name)))
(global-set-key (kbd "C-x p w") 'rc/org-kill-heading-name-save)

(rc/require 'org-cliplink)
(global-set-key (kbd "C-x p i") 'org-cliplink)

(defun rc/cliplink-task ()
  (interactive)
  (org-cliplink-retrieve-title
   (substring-no-properties (current-kill 0))
   (lambda (url title)
     (insert (if title
                 (concat "* TODO " title "\n  [[" url "][" title "]]")
               (concat "* TODO " url "\n  [[" url "]]"))))))
(global-set-key (kbd "C-x p t") 'rc/cliplink-task)

(setq org-capture-templates
      '(("p" "Capture task" entry (file "~/Documents/Agenda/Tasks.org")
         "* TODO %?\n  SCHEDULED: %t\n")
        ("K" "Cliplink capture task" entry (file "~/Documents/Agenda/Tasks.org")
         "* TODO %(org-cliplink-capture) \n  SCHEDULED: %t\n" :empty-lines 1)))
(define-key global-map "\C-cc" 'org-capture)

;; Autocommit
(defvar rc/autocommit-local-locks (make-hash-table :test 'equal))

(defun rc/file-truename-nilable (filename)
  (when filename (file-truename filename)))

(defun rc/autocommit--id ()
  (let ((id (rc/file-truename-nilable (locate-dominating-file default-directory ".git"))))
    (unless id (error "%s is not inside of a git repository" default-directory))
    (unless (gethash id rc/autocommit-local-locks)
      (puthash id nil rc/autocommit-local-locks))
    id))

(defun rc/autocommit--get-lock (lock)
  (plist-get (gethash (rc/autocommit--id) rc/autocommit-local-locks) lock))

(defun rc/autocommit--set-lock (lock value)
  (puthash (rc/autocommit--id)
           (plist-put (gethash (rc/autocommit--id) rc/autocommit-local-locks) lock value)
           rc/autocommit-local-locks))

(defun rc/autocommit--toggle-lock (lock)
  (rc/autocommit--set-lock lock (not (rc/autocommit--get-lock lock))))

(defun rc/autocommit--create-dir-locals (file-name)
  (write-region "((nil . ((eval . (rc/autocommit-dir-locals)))))" nil file-name))

(defun rc/y-or-n-if (predicate question action)
  (when (or (not (funcall predicate)) (y-or-n-p question))
    (funcall action)))

(defun rc/autocommit-init-dir (&optional dir)
  (interactive "DAutocommit directory: ")
  (let ((file-name (concat (or dir default-directory) dir-locals-file)))
    (rc/y-or-n-if (-partial #'file-exists-p file-name)
                  (format "%s already exists. Replace it?" file-name)
                  (-partial #'rc/autocommit--create-dir-locals file-name))))

(defun rc/autocommit-dir-locals ()
  (interactive)
  (auto-revert-mode 1)
  (rc/autopull-changes)
  (add-hook 'after-save-hook 'rc/autocommit-changes nil 'make-it-local))

(defun rc/toggle-autocommit-offline ()
  (interactive)
  (rc/autocommit--toggle-lock 'autocommit-offline)
  (message (if (rc/autocommit--get-lock 'autocommit-offline)
               "[OFFLINE] Autocommit Mode" "[ONLINE] Autocommit Mode")))

(defun rc/autopull-changes ()
  (interactive)
  (unless (rc/autocommit--get-lock 'autopull-lock)
    (rc/autocommit--set-lock 'autopull-lock t)
    (if (rc/autocommit--get-lock 'autocommit-offline)
        (message "[OFFLINE] NOT Syncing the Agenda")
      (if (y-or-n-p (format "Sync the Agenda? [%s]" (rc/autocommit--id)))
          (progn (message (format "Syncing the Agenda [%s]" (rc/autocommit--id)))
                 (shell-command "git pull"))
        (rc/autocommit--set-lock 'autocommit-offline t)
        (message (format "[OFFLINE] NOT Syncing the Agenda [%s]" (rc/autocommit--id)))))))

(defun rc/run-commit-process (autocommit-directory)
  (let ((default-directory autocommit-directory))
    (start-process-shell-command
     (format "Autocommit-%s" autocommit-directory)
     (format "*Autocommit-%s*" autocommit-directory)
     (format (if (rc/autocommit--get-lock 'autocommit-offline)
                 "git add -A && git commit -m \"%s\""
               "git add -A && git commit -m \"%s\" && git push origin master")
             (format-time-string "Autocommit %s")))))

(defun rc/autocommit-beat (autocommit-directory process event)
  (message (if (rc/autocommit--get-lock 'autocommit-offline)
               "[OFFLINE] Autocommit: %s" "Autocommit: %s") event)
  (if (not (rc/autocommit--get-lock 'autocommit-changed))
      (rc/autocommit--set-lock 'autocommit-lock nil)
    (rc/autocommit--set-lock 'autocommit-changed nil)
    (set-process-sentinel (rc/run-commit-process autocommit-directory)
                          (-partial 'rc/autocommit-beat autocommit-directory))))

(defun rc/autocommit-changes ()
  (interactive)
  (if (rc/autocommit--get-lock 'autocommit-lock)
      (rc/autocommit--set-lock 'autocommit-changed t)
    (rc/autocommit--set-lock 'autocommit-lock t)
    (rc/autocommit--set-lock 'autocommit-changed nil)
    (set-process-sentinel (rc/run-commit-process (rc/autocommit--id))
                          (-partial 'rc/autocommit-beat (rc/autocommit--id)))))

;; Extra Modes
(rc/require 'scala-mode 'd-mode 'yaml-mode 'json-mode 'glsl-mode 'tuareg 'lua-mode 'less-css-mode
            'graphviz-dot-mode 'clojure-mode 'cmake-mode 'rust-mode 'csharp-mode 'nim-mode
            'jinja2-mode 'markdown-mode 'purescript-mode 'nix-mode 'dockerfile-mode 'toml-mode
            'nginx-mode 'kotlin-mode 'go-mode 'php-mode 'qml-mode 'ag 'elpy 'typescript-mode
            'rfc-mode 'sml-mode 'uxntal-mode 'proof-general)

;; Proof General
(add-hook 'coq-mode-hook
          (lambda () (local-set-key (kbd "C-c C-q C-n") 'proof-assert-until-point-interactive)))

;; Load Custom File
(load-file custom-file)
