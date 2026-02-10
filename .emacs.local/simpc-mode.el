;;; simpc-mode.el --- Simple C/C++ programming mode

;; Copyright (C) 2024

;; Author: User
;; Keywords: c, languages

;; This file is NOT part of GNU Emacs.

;;; Commentary:

;; A simple major mode for editing C/C++ code.
;; Based on cc-mode but with simplified configuration.

;;; Code:

(require 'cc-mode)

(defvar simpc-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c C-c") 'compile)
    (define-key map (kbd "C-c C-f") 'simpc-format-function)
    map)
  "Keymap for simpc-mode.")

(defvar simpc-mode-syntax-table
  (let ((st (make-syntax-table)))
    ;; C/C++ style comments
    (modify-syntax-entry ?/ ". 124b" st)
    (modify-syntax-entry ?* ". 23" st)
    (modify-syntax-entry ?\n "> b" st)
    ;; Angle brackets for C++ templates
    (modify-syntax-entry ?< "(>" st)
    (modify-syntax-entry ?> ")<" st)
    ;; Underscore as word constituent
    (modify-syntax-entry ?_ "w" st)
    st)
  "Syntax table for simpc-mode.")

(defvar simpc-font-lock-keywords
  `((,(regexp-opt
       '("int" "char" "float" "double" "void" "short" "long"
         "unsigned" "signed" "const" "volatile" "static" "extern"
         "auto" "register" "typedef" "struct" "union" "enum"
         "if" "else" "while" "do" "for" "switch" "case"
         "default" "break" "continue" "return" "goto" "sizeof"
         ;; C++ keywords
         "class" "public" "private" "protected" "virtual"
         "inline" "template" "typename" "namespace" "using"
         "new" "delete" "operator" "friend" "explicit"
         "mutable" "throw" "try" "catch" "bool" "true" "false")
       'symbols)
     . font-lock-keyword-face)
    (,(regexp-opt
       '("int8_t" "int16_t" "int32_t" "int64_t"
         "uint8_t" "uint16_t" "uint32_t" "uint64_t"
         "size_t" "ssize_t" "ptrdiff_t" "NULL")
       'symbols)
     . font-lock-type-face)
    ;; Function names
    ("\\([a-zA-Z_][a-zA-Z0-9_]*\\)\\s-*(" 1 font-lock-function-name-face)
    ;; Preprocessor directives
    ("^\\s-*#\\s-*\\(include\\|define\\|ifdef\\|ifndef\\|endif\\|else\\|elif\\|undef\\|pragma\\|error\\|warning\\)\\>"
     1 font-lock-preprocessor-face)
    ;; String includes
    ("#include\\s-+\\(<[^>]+>\\|\"[^\"]+\"\\)" 1 font-lock-string-face)
    ;; Numbers
    ("\\b\\(0x[0-9a-fA-F]+\\|0[0-7]*\\|[1-9][0-9]*\\|0\\)\\(u\\|U\\|l\\|L\\|ul\\|UL\\|ll\\|LL\\|ull\\|ULL\\)?\\b"
     . font-lock-constant-face))
  "Font lock keywords for simpc-mode.")

(defun simpc-format-function ()
  "Format the current buffer using astyle."
  (interactive)
  (when (executable-find "astyle")
    (let ((saved-line (line-number-at-pos)))
      (shell-command-on-region
       (point-min)
       (point-max)
       "astyle --style=kr"
       nil t)
      (goto-line saved-line)
      (message "Formatted with astyle"))))

;;;###autoload
(define-derived-mode simpc-mode prog-mode "SimPC"
  "Simple major mode for editing C/C++ code.

\{simpc-mode-map}"
  :syntax-table simpc-mode-syntax-table
  (setq-local font-lock-defaults '(simpc-font-lock-keywords))
  (setq-local comment-start "// ")
  (setq-local comment-end "")
  (setq-local comment-start-skip "//+\\s-*")
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 4)
  (setq-local c-basic-offset 4)
  ;; Use c-indent-line-or-region for indentation
  (setq-local indent-line-function 'c-indent-line-or-region)
  (run-hooks 'simpc-mode-hook))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.[ch]\\(pp\\)?\\'" . simpc-mode))
(add-to-list 'auto-mode-alist '("\\.[b]\\'" . simpc-mode))

(provide 'simpc-mode)

;;; simpc-mode.el ends here
