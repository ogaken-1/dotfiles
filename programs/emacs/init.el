;; This buffer is for text that is not saved, and for Lisp evaluation.
;; To create a file, visit it with C-x C-f and enter text in its buffer.

(eval-and-compile
  (when (or load-file-name byte-compile-current-file)
    (setq user-emacs-directory
          (expand-file-name
           (file-name-directory (or load-file-name byte-compile-current-file))))))

(eval-and-compile
  (customize-set-variable
   'package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("org" . "https://orgmode.org/elpa/")))
  (package-initialize)
  (leaf leaf-keywords
    :init
    (leaf blackout)
    :config
    (leaf-keywords-init)))

(leaf leaf-convert
  :doc "Convert many format to leaf format")

(leaf cus-edit
  :doc "tools for customizing Emacs and Lisp pacakges"
  :tag "builtin"
  :custom ((custom-file . `,(locate-user-emacs-file "custom.el")))
  :config (load custom-file))

(leaf cus-start
  :doc "define customization properties of builtins"
  :tag "builtin"
  :preface
  (defun c/redraw-frame nil
    (interactive)
    (redraw-frame))
  (defun c/posframe-available-p ()
    "Check if posframe is available and can be used."
    (and (fboundp 'posframe-show)
         (display-graphic-p)))
  :bind (("M-ESC ESC" . c/redraw-frame))
  :custom '((user-full-name . "Kento Ogata")
            (user-mail-address . "k.ogata1013@gmail.com")
            (user-login-name . "ogaken")
            (create-lockfiles . nil)
            (tab-width . 4)
            (debug-on-error . t)
            (init-file-debug . t)
            (frame-resize-pixelwise . t)
            (epnable-recursive-minibuffers . t)
            (history-length . 1000)
            (history-delete-duplicates . t)
            (scroll-preserve-screen-position . t)
            (scroll-conservatively . 100)
            (mouse-wheel-scroll-amount . '(1 ((control) . 5)))
            (ring-bell-function . 'ignore)
            (text-quoting-style . 'straight)
            (truncate-lines . t)
            (use-dialog-box . nil)
            (use-file-dialog . nil)
            (menu-bar-mode . nil)
            (tool-bar-mode . nil)
            (scroll-bar-mode . nil)
            (indent-tabs-mode . nil)
            (show-trailing-whitespace . t)
            ;; 起動時にframeがresizeされるのが抑制されてちょっと動きがスッキリする
            (frame-inhibit-implied-resize . t)))

(leaf autorevert
  :doc "revert buffers when files on disk change"
  :tag "builtin"
  :global-minor-mode global-auto-revert-mode)

(leaf delsel
  :doc "delete selection if you insert"
  :tag "builtin"
  :global-minor-mode delete-selection-mode)

(leaf paren
  :doc "highlight matching paren"
  :tag "builtin"
  :global-minor-mode show-paren-mode)

(leaf simple
  :doc "basic editing commands for Emacs"
  :tag "builtin"
  :custom ((kill-read-only-ok . t)
           (kill-whole-line . t)
           (eval-expression-print-length . nil)
           (eval-expression-print-length . nil)))

(leaf files
  :doc "file input and output commands for Emacs"
  :tag "builtin"
  :global-minor-mode auto-save-visited-mode
  :custom ((auto-save-file-name-transforms . `((".*" ,(locate-user-emacs-file "backup/") t)))
           (backup-directory-alist . `((".*" . ,(locate-user-emacs-file "backup"))
                                       (,tramp-file-name-regexp . nil)))
           (version-control . t)
           (delete-old-versions . t)
           (auto-save-visited-interval . 1)
           (auto-save-visited-mode . nil)))

(leaf startup
  :doc "process Emacs shell arguments"
  :tag "builtin"
  :custom ((auto-save-list-file-prefix . `,(locate-user-emacs-file "backup/.saves-"))))

(leaf savehist
  :doc "Save minibuffer history"
  :tag "builtin"
  :custom ((savehist-file . `,(locate-user-emacs-file "savehist")))
  :global-minor-mode t)

(leaf flymake
  :doc "A universal on-the-fly syntax checker"
  :tag "builtin"
  :bind ((prog-mode-map
          ("M-n" . flymake-goto-next-error)
          ("M-p" . flymake-goto-prev-error))))

(leaf which-key
  :doc "Display available keybindings in popup"
  :global-minor-mode t)

(leaf exec-path-from-shell
  :doc "Get environment variables such as $PATH from shell"
  :defun (exec-path-from-shell-initialize)
  :custom ((exec-path-from-shell-check-startup-files)
           (exec-path-from-shell-variables . '("PATH" "GOPATH" "JAVA_HOME" "DOTNET_ROOT")))
  :config  (exec-path-from-shell-initialize))

(leaf vertico
  :doc "VERTical Interactive COmpletion"
  :global-minor-mode t)

(leaf marginalia
  :doc "Enrich existing commands with completion annotations"
  :global-minor-mode t)

(leaf consult
  :doc "Consulting completing-read"
  :hook (completion-list-mode-hook . consult-preview-at-point-mode)
  :defun consult-line
  :preface
  (defun c/consult-line (&optional at-point)
    "Consult-line uses things-at-point if set C-u prefix."
    (interactive "P")
    (if at-point
        (consult-line (thing-at-point 'symbol))
      (consult-line)))
  :custom ((xref-show-xrefs-function . #'consult-xref)
           (xref-show-definitions-function . #'consult-xref)
           (consult-line-start-from-top . t))
  :bind (;; C-c bindings (mode-specific-map)
         ([remap switch-to-buffer] . consult-buffer)                 ; C-x b
         ([remap project-switch-to-buffer] . consult-project-buffer) ; C-x p b
         ([remap find-file-read-only] . consult-recent-file)         ; C-x C-r

         ;; M-b bindings (goto-map)
         ([remap goto-line] . consult-goto-line) ; M-g g
         ([remap imenu] . consult-imenu) ; M-g i
         ("M-g f" . consult-flymake)

         ;; C-M-s bindings
         ("C-s" . c/consult-line) ; isearch-forward
         ("C-M-s" . nil) ; isearch-forward-regexp
         ("C-M-s s" . isearch-forward)
         ("C-M-s C-s" . isearch-forward-regexp)
         ("C-M-s r" . consult-ripgrep)

         ;; minibuffer local bindings
         (minibuffer-local-map
          :package emacs
          ("C-r" . consult-history)))
  :init
  (leaf consult-ghq
    :doc "Ghq interface using consult"
    :bind ([remap project-switch-project] . consult-ghq-switch-project)))

(leaf affe
  :doc "Asynchronous Fuzzy Finder for Emacs"
  :custom ((affe-highlight-function . 'orderless-highlight-matches)
           (affe-regexp-function . 'orderless-pattern-compiler))
  :bind (("C-M-s r" . affe-grep)
         ("C-M-s f" . affe-find)))

(leaf migemo
  :doc "Japanese incremental search through dynamic pattern expansion"
  :custom `((migemo-dictionary . `,(getenv "MIGEMO_UTF8_DICT"))
            (migemo-user-dictionary . nil)
            (migemo-regex-dictionary . nil)
            (migemo-coding-system . 'utf-8-unix))
  :defun migemo-init migemo-get-pattern
  :init (autoload 'migemo-get-pattern "migemo.el")
  :defer-config (migemo-init))

(leaf orderless
  :doc "Completion style for matching regexp in any order"
  :custom ((completion-styles . '(orderless))
           (completion-category-defaults . nil)
           (completion-category-overrides . '((file (styles partial-completion))
                                              ;; consult-lineでorderless+migemoによるマッチを使う
                                              (consult-location (styles orderless+migemo)))))
  :config
  (eval-and-compile
    (require 'orderless)
    (defun orderless-migemo (component)
      "componentが2文字以上であればmigemoでパターンを作って返す"
      (if (length< component 2) ; 短い文字数でmigemoするとregexpが複雑になりすぎてやばい
          component
        (let ((pattern (migemo-get-pattern component)))
          (condition-case nil
              (progn (string-match-p pattern "") pattern)
            (invalid-regexp nil)))))
    (orderless-define-completion-style orderless+migemo
      (orderless-matching-styles '(orderless-literal
                                   orderless-regexp
                                   orderless-migemo)))))

(leaf embark
  :doc "Conveniently act on minibuffer completions."
  :bind (("C-." . embark-act)
         (minibuffer-mode-map
          :package emacs
          ("M-." . embark-dwim)
          ("C-." . embark-act)))
  :init
  (leaf embark-consult
    :doc "Consult integration for Embark"))


(leaf corfu
  :doc "COmpletion in Region FUnction"
  :global-minor-mode global-corfu-mode corfu-popupinfo-mode
  :custom ((corfu-auto . t)
           (corfu-auto-delay . 0)
           (corfu-auto-prefix . 1)
           (corfu-popupinfo-delay . nil)) ; manual
  :bind ((corfu-map
          ("C-s" . corfu-insert-separator))))

(leaf cape
  :doc "Completion At Point Extensions"
  :config
  (add-to-list 'completion-at-point-functions #'cape-file))

(leaf eglot
  :doc "The Emacs Client for LSP servers"
  :hook (((csharp-ts-mode-hook typescript-ts-mode-hook tsx-ts-mode-hook nix-mode-hook) . eglot-ensure))
  :custom ((eldoc-echo-area-use-multiple-line-p . nil)
           (eglot-connect-timeout . 60))
  :bind (("C-c r" . eglot-rename)
         ("C-c ." . eglot-code-actions))
  :defvar eglot-server-programs
  :defun eglot--server-info
  :config
  (eval-and-compile
    (defun c/eglot-server-configuration (server)
      "workspace/didChangeConfigurationのparams.settingsに渡すオブジェクトを返す"
      (pcase (plist-get (eglot--server-info server) :name)
        ("OmniSharp"
         '((:FormattingOptions . ((EnableEditorConfigSupport . t)
                                  (OrganizeImports . :json-false)))
           (:MsBuild . ((LoadProjectsOnDemand . :json-false)))
           (:RoslynExtensionsOptions . ((EnableAnalyzersSupport . t)
                                        (EnableImportCompletion . :json-false)
                                        (AnalyzeOpenDocumentsOnly . t)))))
        ("vtsls"
         '((:typescript . ((updateImportsOnFileMove . "always")))
           (:javascript . ((updateImportsOnFileMove . "always")))
           (:vtsls . ((experimental . ((completion . ((entriesLimit . 500)))  ; 最大候補数を制限しないとけっこう遅い
                                       (enableMoveToFileCodeAction . t)))))))))
    (defun c/set-eglot-server-program (modes command-list)
      "`eglot-server-programs'の一部を更新する"
      (if (assoc modes eglot-server-programs #'equal)
          (setf (alist-get modes eglot-server-programs nil nil #'equal)
                command-list)
        (add-to-list 'eglot-server-programs (cons modes command-list)))))
  (setq-default eglot-workspace-configuration #'c/eglot-server-configuration)
  (c/set-eglot-server-program
   '(csharp-ts-mode)
   `("OmniSharp" ; nixpkgsで入るomnisharpのコマンドは何故かOmniSharpになっている
     "--languageserver"
     "--zero-based-indices"
     "DotNet:enablePackageRestore=true"
     "--encoding" "utf-8"
     "--hostPID" ,(int-to-string (emacs-pid))))
  (c/set-eglot-server-program
   '((typescript-ts-mode :language-id "typescript")
     (tsx-ts-mode :language-id "typescriptreact"))
   '("vtsls" "--stdio"))
  (c/set-eglot-server-program '(nix-mode) '("nixd")))

(leaf eglot-booster
  :when (executable-find "emacs-lsp-booster")
  :after eglot
  :vc (:url "https://github.com/jdtsmith/eglot-booster")
  :global-minor-mode t)

(leaf puni
  :doc "Parentheses Universalistic"
  :global-minor-mode puni-global-mode
  :bind (puni-mode-map
         ;; default mapping
         ;; ("C-M-f" . puni-forward-sexp)
         ;; ("C-M-b" . puni-backward-sexp)
         ;; ("C-M-a" . puni-beginning-of-sexp)
         ;; ("C-M-e" . puni-end-of-sexp)
         ;; ("M-)" . puni-syntactic-forward-punct)
         ;; ("C-M-u" . backward-up-list)
         ;; ("C-M-d" . backward-down-list)
         ("C-<right>" . puni-slurp-forward)
         ("C-<left>" . puni-barf-forward)
         ("M-(" . puni-wrap-round)
         ("M-s" . puni-splice)
         ("M-r" . puni-raise)
         ("M-U" . puni-splice-killing-backward)
         ("M-z" . puni-squeeze)))

(leaf elec-pair
  :doc "Automatic parenthesis pairing"
  :tag "builtin"
  :global-minor-mode electric-pair-mode)

(leaf magit
  :doc "A Git porcelain inside Emacs."
  :bind ("C-x g" . magit-status))

(leaf direnv
  :doc "Direnv integration."
  :global-minor-mode t)

(leaf recentf
  :doc "keep track of recently opened files"
  :tag "builtin"
  :global-minor-mode t)

(set-language-environment "Japanese")
;; Use nf patched cascadia code if avalilable.
(let '(font "CaskaydiaCove NFM")
  (if (fontp font)
      (set-frame-font font)))

(leaf zenburn-theme
  :doc "A low contrast color theme for Emacs"
  :config (load-theme 'zenburn t))

(leaf nix-mode
  :doc "Major mode for editing .nix files")

(leaf web-mode
  :doc "Major mode for editing web templates"
  :custom ((web-mode-engines-alist . '(("razor" . "\\.razor\\'"))))
  :config
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.cshtml?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.razor?\\'" . web-mode)))

(leaf typescript-ts-mode
  :doc "tree sitter support for TypeScript"
  :tag "builtin"
  :mode (("\\.tsx\\'" . tsx-ts-mode)
         ("\\.ts\\'" . typescript-ts-mode))
  :custom (typescript-ts-mode-indent-offset . 2))

(leaf treesit
  :doc "tree-sitter utilities"
  :tag "builtin"
  :custom (treesit-font-lock-level . 4))

(leaf treesit-auto
  :doc "Automatically use tree-sitter enhanced major modes"
  :custom (treesit-auto-install . t)
  :global-minor-mode global-treesit-auto-mode)

(leaf tree-sitter
  :doc "Incremental parsing system"
  :hook ((typescript-ts-mode tsx-ts-mode) . tree-sitter-hl-mode)
  :global-minor-mode global-tree-sitter-mode)

(leaf tree-sitter-langs
  :doc "Grammar bundle for tree-sitter"
  :after tree-sitter)

(leaf astro-ts-mode
  :doc "Major mode for editing Astro templates")

(leaf yaml-mode
  :doc "Major mode for editing YAML files")

(leaf basic-mode
  :doc "Major mode for editing BASIC code"
  :config
  ;; デフォルトではvb.netのファイルをBASICだと認識してくれない
  (autoload 'basic-generic-mode "basic-mode" "Major mode for editing BASIC code." t)
  (add-to-list 'auto-mode-alist '("\\.vb\\'" . basic-generic-mode)))

(defun c/skk-jisyo-files ()
  "List SKK dictionary files in $SKK_DICT_DIRS."
  (let ((dict-dirs (split-string (or (getenv "SKK_DICT_DIRS") "") ":")))
    (seq-mapcat
     (lambda (dir)
       (when (file-directory-p dir)
         (directory-files-recursively dir "SKK-JISYO" t)))
     dict-dirs)))

(leaf ddskk
  :doc "Simple Kana to Kanji conversion program"
  :bind ("C-x C-j" . skk-mode)
  :custom `((skk-use-azik . t)
            (skk-azik-keyboard-type . "us101")
            (skk-jisyo . ,(string-join `(,(getenv "XDG_DATA_HOME") "skk" "user-jisyo") "/"))
            (skk-extra-jisyo-file-list . `,(c/skk-jisyo-files))
            (skk-jisyo-code . "utf-8")
            (skk-egg-like-newline . t))
  :init
  (leaf ddskk-posframe
    :doc "Show Henkan tooltip for ddskk via posframe"
    :when (c/posframe-available-p)
    :global-minor-mode t))

(leaf ace-window
  :doc "Quickly switch windows"
  :bind ([remap other-window] . ace-window)
  :custom ((ace-window-posframe-mode . `,(c/posframe-available-p))
           (aw-keys . '(?a ?s ?d ?f ?g ?h ?j ?k ?l))))

(leaf org-mode
  :doc "Outline-based notes management and organizer"
  :tag "builtin"
  :bind (("C-c c" . org-capture)
         ("C-c a" . org-agenda))
  :custom ((org-todo-keywords . '((type "TODO(t)" "PENDING(p)" "SCHEDULED(s)" "REVIEW(r)" "ASSIGNED(a)" "|" "DONE(d)")))
           (org-log-done . 'time)
           (org-log-reschedule . 'note)
           (org-log-redeadline . 'note)
           (org-log-into-drawer . "LOGBOOK")
           (org-startup-folded . t)
           (org-enforce-todo-dependencies . t)
           (org-enforce-todo-checkbox-dependencies . t))
  :defvar org-babel-load-languages
  :config
  (add-to-list 'org-babel-load-languages '(shell . t)))

(leaf org-modern
  :doc "Modern looks for Org."
  :global-minor-mode global-org-modern-mode)

(leaf dashboard
  :doc "A startup screen extracted from Spacemacs"
  :config (dashboard-setup-startup-hook))

(leaf spacious-padding
  :doc "Increase the padding/spacing of frames and windows"
  :global-minor-mode t)

(leaf doom-modeline
  :doc "A minimal and modern mode-line"
  :hook (after-init-hook . doom-modeline-mode)
  :custom ((nerd-icons-font-family . "CaskaydiaCove")))

(leaf editorconfig
  :doc "EditorConfig Emacs Plugin")

(leaf git-gutter-fringe
  :doc "Fringe version of git-gutter.el"
  :global-minor-mode global-git-gutter-mode)

(provide 'init)

;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; init.el ends here
