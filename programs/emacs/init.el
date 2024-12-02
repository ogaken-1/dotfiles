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
  (use-package leaf :ensure t)
  (leaf leaf-keywords
    :ensure t
    :init
    (leaf blackout :ensure t)
    :config
    (leaf-keywords-init)))

(leaf leaf-convert
  :doc "Convert many format to leaf format"
  :ensure t)

(leaf cus-edit
  :doc "tools for customizing Emacs and Lisp pacakges"
  :custom `((custom-file . ,(locate-user-emacs-file "custom.el"))))

(leaf cus-start
  :doc "define customization properties of builtins"
  :preface
  (defun c/redraw-frame nil
    (interactive)
    (redraw-frame))
  :bind (("M-ESC ESC" . c/redraw-frame))
  :custom '((user-full-name . "Kento Ogata")
	        (user-mail-address . "k.ogata1013@gmail.com")
	        (user-login-name . "ogaken")
	        (create-lockfiles . nil)
	        (tab-width . 4)
	        (debug-on-error . t)
	        (init-file-debug . t)
	        (frame-resize-pixelwise . t)
	        (enable-recursive-minibuffers . t)
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
	        (menu-bar-mode . t)
	        (tool-bar-mode . nil)
	        (scroll-bar-mode . nil)
	        (indent-tabs-mode . nil)))

(leaf autorevert
  :doc "revert buffers when files on disk change"
  :global-minor-mode global-auto-revert-mode)

(leaf delsel
  :doc "delete selection if you insert"
  :global-minor-mode delete-selection-mode)

(leaf paren
  :doc "highlight matching paren"
  :global-minor-mode show-paren-mode)

(leaf simple
  :doc "basic editing commands for Emacs"
  :custom ((kill-read-only-ok . t)
           (kill-whole-line . t)
           (eval-expression-print-length . nil)
           (eval-expression-print-length . nil)))

(leaf files
  :doc "file input and output commands for Emacs"
  :global-minor-mode auto-save-visited-mode
  :custom `((auto-save-file-name-transforms . '((".*" ,(locate-user-emacs-file "backup/") t)))
            (backup-directory-alist . '((".*" . ,(locate-user-emacs-file "backup"))
                                        (,tramp-file-name-regexp . nil)))
            (version-control . t)
            (delete-old-versions . t)
            (auto-save-visited-interval . 1)))

(leaf startup
  :doc "process Emacs shell arguments"
  :custom `((auto-save-list-file-prefix . ,(locate-user-emacs-file "backup/.saves-"))))

(leaf savehist
  :doc "Save minibuffer history"
  :custom `((savehist-file . ,(locate-user-emacs-file "savehist")))
  :global-minor-mode t)

(leaf flymake
  :doc "A universal on-the-fly syntax checker"
  :bind ((prog-mode-map
          ("M-n" . flymake-goto-next-error)
          ("M-p" . flymake-goto-prefv-error))))

(leaf which-key
  :doc "Display available keybindings in popup"
  :ensure t
  :global-minor-mode t)

(leaf exec-path-from-shell
  :doc "Get environment variables such as $PATH from shell"
  :ensure t
  :defun (exec-path-from-shell-initialize)
  :custom ((exec-path-from-shell-check-startup-files)
           (exec-path-from-shell-variables . '("PATH" "GOPATH" "JAVA_HOME" "DOTNET_ROOT")))
  :config  (exec-path-from-shell-initialize))

(leaf vertico
  :doc "VERTical Interactive COmpletion"
  :ensure t
  :global-minor-mode t)

(leaf marginalia
  :doc "Enrich existing commands with completion annotations"
  :ensure t
  :global-minor-mode t)

(leaf consult
  :doc "Consulting completing-read"
  :ensure t
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
  (leaf consult-ls-git
    :doc "Consult integration for git"
    :ensure t)
  (leaf consult-ghq
    :doc "Ghq interface using consult"
    :ensure t))

(leaf affe
  :doc "Asynchronous Fuzzy Finder for Emacs"
  :ensure t
  :custom ((affe-highlight-function . 'orderless-highlight-matches)
           (affe-regexp-function . 'orderless-pattern-compiler))
  :bind (("C-M-s r" . affe-grep)
         ("C-M-s f" . affe-bind)))

(leaf orderless
  :doc "Completion style for matching regexp in any order"
  :ensure t
  :custom ((completion-styles . '(orderless))
           (completion-category-defaults . nil)
           (completion-category-overrides . '((file (styles partial-completion))))))

(leaf embark-consult
  :doc "Consult integration for Embark"
  :ensure t
  :bind ((minibuffer-mode-map
          :package emacs
          ("M-." . embark-dwim)
          ("C-." . embark-act))))

(leaf embark
  :doc "Conveniently act on minibuffer completions."
  :ensure t
  :bind (("C-." . embark-act)))

(leaf corfu
  :doc "COmpletion in Region FUnction"
  :ensure t
  :global-minor-mode global-corfu-mode corfu-popupinfo-mode
  :custom ((corfu-auto . t)
           (corfu-auto-delay . 0)
           (corfu-auto-prefix . 1)
           (corfu-popupinfo-delay . nil)) ; manual
  :bind ((corfu-map
          ("C-s" . corfu-insert-separator))))

(leaf cape
  :doc "Completion At Point Extensions"
  :ensure t
  :config
  (add-to-list 'completion-at-point-functions #'cape-file))

(leaf eglot
  :doc "The Emacs Client for LSP servers"
  :hook ((csharp-mode-hook . eglot-ensure))
  :custom ((eldoc-echo-area-use-multiple-line-p . nil)
           (eglot-connect-timeout . 600)
           (eglot-server-programs . '((csharp-mode . ("OmniSharp" "-lsp"))))))

(leaf eglot-booster
  :when (executable-find "emacs-lsp-booster")
  :vc (:url "https://github.com/jdtsmith/eglot-booster")
  :global-minor-mode t)

(leaf puni
  :doc "Parentheses Universalistic"
  :ensure t
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
         ("M-z" . puni-squeeze))
  :config
  (leaf elec-pair
    :doc "Automatic parenthesis pairing"
    :global-minor-mode electric-pair-mode))

(leaf magit
  :doc "A Git porcelain inside Emacs."
  :ensure t
  :bind ("C-x g" . magit-status))

(leaf direnv
  :doc "Direnv integration."
  :ensure t
  :global-minor-mode t)

(leaf recentf
  :doc "keep track of recently opened files"
  :global-minor-mode t)

(set-language-environment "Japanese")
(set-frame-font "CaskaydiaCove NFM")
(load-theme 'modus-operandi t)

(leaf nix-ts-mode
  :doc "Major mode for Nix expressions, powered by tree-sitter"
  :ensure t)

(leaf ddskk
  :doc "Simple Kana to Kanji conversion program"
  :ensure t
  :bind ("C-x C-j" . skk-mode)
  :custom `((skk-use-azik . t)
            (skk-azik-keyboard-type . "us101")
            (skk-jisyo . ,(string-join `(,(getenv "XDG_DATA_HOME") "skk" "user-jisyo") "/"))
            (skk-jisyo-code . "utf-8")
            (skk-egg-like-newline . t))
  :init
  (leaf ddskk-posframe
    :doc "Show Henkan tooltip for ddskk via posframe"
    :ensure t
    :global-minor-mode t))

(leaf ace-window
  :doc "Quickly switch windows"
  :ensure t
  :bind ([remap other-window] . ace-window)
  :custom ((ace-window-posframe-mode . t)
           (aw-keys . '(?a ?s ?d ?f ?g ?h ?j ?k ?l))))

(leaf org-mode
  :doc "Outline-based notes management and organizer"
  :tag "builtin"
  :bind (("C-c c" . org-capture)
         ("C-c a" . org-agenda))
  :config
  (add-to-list 'org-babel-load-languages '(shell . t)))

(leaf perfect-margin
  :doc "Auto center windows, works with line numbers"
  :ensure t
  :global-minor-mode t)

(leaf spacious-padding
  :doc "Increase the padding/spacing of frames and windows"
  :ensure t
  :global-minor-mode t)

(leaf doom-modeline
  :doc "A minimal and modern mode-line"
  :ensure t
  :hook (after-init-hook . doom-modeline-mode)
  :custom ((nerd-icons-font-family . "CaskaydiaCove")))

(leaf editorconfig
  :doc "EditorConfig Emacs Plugin"
  :ensure t)

(leaf git-gutter-fringe
  :doc "Fringe version of git-gutter.el"
  :ensure t
  :global-minor-mode global-git-gutter-mode)

(provide 'init)

;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; init.el ends here
