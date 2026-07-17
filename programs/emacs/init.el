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
                       ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                       ("melpa" . "https://melpa.org/packages/")
                       ("org" . "https://orgmode.org/elpa/"))))

(eval-when-compile
  (package-initialize)
  (use-package leaf
    :ensure t))

(eval-and-compile
  (leaf leaf-keywords
    :ensure t
    :config
    (leaf hydra :ensure t)
    (leaf-keywords-init)))

(leaf leaf-convert
  :doc "Convert many format to leaf format"
  :ensure t)

(leaf cus-edit
  :doc "tools for customizing Emacs and Lisp pacakges"
  :tag "builtin"
  :custom ((custom-file . `,(locate-user-emacs-file "custom.el")))
  :config (if (file-exists-p custom-file)
              (load custom-file)))

(defmacro c/with-hook (hook &rest body)
  "`add-hook' の処理を `lambda' でアレするwrapper"
  (declare (indent 1))
  `(add-hook ',hook (lambda () ,@body)))

(leaf cus-start
  :doc "define customization properties of builtins"
  :tag "builtin"
  :preface
  (defun c/redraw-frame nil
    (interactive)
    (redraw-frame))
  :bind (("M-ESC ESC" . #'c/redraw-frame))
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
            (show-trailing-whitespace . t)))

(leaf face-remap
  :doc "Functions for managing `face-remapping-alist'."
  :tag "builtin"
  :bind ("C-c +" . hydra-text-scale/body)
  :hydra (hydra-text-scale (:hint nil) "
Text scale:
  _i_: increase    _q_: quit
  _d_: decrease
"
                           ("i" #'text-scale-increase)
                           ("d" #'text-scale-decrease)
                           ("q" nil :color blue)))

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
          ("M-n" . #'flymake-goto-next-error)
          ("M-p" . #'flymake-goto-prev-error))))

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
  :after minibuffer
  :global-minor-mode t)

(leaf marginalia
  :doc "Enrich existing commands with completion annotations"
  :ensure t
  :after vertico
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
         ([remap switch-to-buffer] . #'consult-buffer)                 ; C-x b
         ([remap project-switch-to-buffer] . #'consult-project-buffer) ; C-x p b
         ([remap find-file-read-only] . #'consult-recent-file)         ; C-x C-r

         ;; M-b bindings (goto-map)
         ([remap goto-line] . #'consult-goto-line) ; M-g g
         ([remap imenu] . #'consult-imenu) ; M-g i
         ("M-g f" . #'consult-flymake)

         ;; C-M-s bindings
         ("C-s" . #'c/consult-line) ; isearch-forward
         ("C-M-s" . nil) ; isearch-forward-regexp
         ("C-M-s s" . #'isearch-forward)
         ("C-M-s C-s" . #'isearch-forward-regexp)
         ("C-M-s r" . #'consult-ripgrep)

         ;; minibuffer local bindings
         (minibuffer-local-map
          :package emacs
          ("C-r" . #'consult-history)))
  :init
  (leaf consult-ghq
    :doc "Ghq interface using consult"
    :ensure t
    :bind ([remap project-switch-project] . #'consult-ghq-switch-project)))

(leaf affe
  :doc "Asynchronous Fuzzy Finder for Emacs"
  :ensure t
  :custom ((affe-highlight-function . #'orderless-highlight-matches)
           (affe-regexp-function . #'orderless-pattern-compiler))
  :bind (("C-M-s r" . #'affe-grep)
         ("C-M-s f" . #'affe-find)))

(leaf f
  :doc "Modern API for working with files and directories."
  :commands f-join)

(leaf migemo
  :doc "Japanese incremental search through dynamic pattern expansion"
  :ensure t
  :custom `((migemo-dictionary . `,(f-join (getenv "HOME") ".nix-profile/share/migemo/utf-8/migemo-dict"))
            (migemo-user-dictionary . nil)
            (migemo-regex-dictionary . nil)
            (migemo-coding-system . 'utf-8-unix))
  :defun migemo-init migemo-get-pattern
  :init (autoload #'migemo-get-pattern "migemo")
  :defer-config (migemo-init))

(leaf orderless
  :doc "Completion style for matching regexp in any order"
  :ensure t
  :custom ((completion-styles . '(orderless))
           (completion-category-defaults . nil)
           (completion-category-overrides . '((file (styles partial-completion))
                                              ;; consult-lineでorderless+migemoによるマッチを使う
                                              (consult-location (styles orderless+migemo)))))
  :require orderless
  :config
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
                                 orderless-migemo))))

(leaf embark
  :doc "Conveniently act on minibuffer completions."
  :ensure t
  :bind (("C-." . #'embark-act)
         (minibuffer-mode-map
          :package emacs
          ("M-." . #'embark-dwim)
          ("C-." . #'embark-act)))
  :init
  (leaf embark-consult
    :doc "Consult integration for Embark"
    :ensure t))


(leaf corfu
  :doc "COmpletion in Region FUnction"
  :ensure t
  :global-minor-mode global-corfu-mode corfu-popupinfo-mode
  :custom ((corfu-auto . t)
           (corfu-auto-delay . 0)
           (corfu-auto-prefix . 1)
           (corfu-popupinfo-delay . nil)) ; manual
  :bind ((corfu-map
          ("C-s" . #'corfu-insert-separator))))

(leaf corfu-terminal
  :doc "Corfu popup on terminal."
  :added "2025-04-30"
  ;; emacs31ではtuiでのchild framesがサポートされたので不要になる
  :emacs< 31
  :ensure t
  :unless (display-graphic-p)
  :after corfu
  :hook corfu-mode-hook)

(leaf cape
  :doc "Completion At Point Extensions"
  :ensure t
  :config
  (add-to-list 'completion-at-point-functions #'cape-file))

(leaf lsp-mode
  :doc "Emacs client/library for the Language Server Protocol."
  :added "2025-11-29"
  :ensure t
  :hook ((go-ts-mode-hook . lsp-deferred)
         (typst-ts-mode-hook . lsp-deferred))
  :custom (lsp-completion-provider . :none)  ; 補完でcorfuを動かす
  :config
  (add-to-list 'lsp-language-id-configuration '(typst-ts-mode . "typst"))
  (lsp-register-client
   (make-lsp-client
    :new-connection (lsp-stdio-connection "tinymist")
    :activation-fn (lsp-activate-on "typst")
    :server-id 'tinymist)))

(leaf lsp-ui
  :doc "UI modules for lsp-mode."
  :added "2025-11-29"
  :ensure t
  :custom ((lsp-ui-peek-enable . t)
           (lsp-ui-doc-enable . t)))

(leaf yasnippet
  :doc "Yet another snippet extension for Emacs."
  :added "2025-12-02"
  :hook (prog-mode-hook . yas-minor-mode)
  :config
  (yas-reload-all))

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
         ("C-<right>" . #'puni-slurp-forward)
         ("C-<left>" . #'puni-barf-forward)
         ("M-(" . #'puni-wrap-round)
         ("M-s" . #'puni-splice)
         ("M-r" . #'puni-raise)
         ("M-U" . #'puni-splice-killing-backward)
         ("M-z" . #'puni-squeeze)))

(leaf paredit
  :doc "Minor mode for editing parentheses."
  :added "2025-07-31"
  :ensure t
  :hook (lisp-mode-hook emacs-lisp-mode-hook))

(leaf elec-pair
  :doc "Automatic parenthesis pairing"
  :tag "builtin"
  :global-minor-mode electric-pair-mode)

(leaf magit
  :doc "A Git porcelain inside Emacs."
  :ensure t
  :bind ("C-x g" . #'magit-status))

(leaf magit-delta
  :doc "Use Delta when displaying diffs in Magit."
  :ensure t
  :added "2025-06-06"
  :hook (magit-mode-hook))

(leaf direnv
  :doc "Direnv integration."
  :ensure t
  :global-minor-mode t)

(leaf recentf
  :doc "keep track of recently opened files"
  :tag "builtin"
  :global-minor-mode t
  :preface
  ;; recentfをMRWにする
  ;; `org-agenda' する度にrecentfのリストが機能しなくなるのがつらい
  (defun my-recentf-no-track-find-file-hook (&rest r)
    "`recentf-mode'がファイルを開いたときにも記録してしまうのを止める"
    (when recentf-mode
      (remove-hook 'find-file-hook 'recentf-track-opened-file)))
  (advice-add 'recentf-mode :after #'my-recentf-no-track-find-file-hook))

(leaf mule-cmds
  :doc "commands for multilingual environment."
  :tag "builtin"
  :config
  (set-language-environment "Japanese"))

(leaf theme
  :doc "Color theme of emacs."
  :added "2025-04-30"
  :config
  (leaf zenburn-theme
    :doc "A low contrast color theme for Emacs"
    :added "2024-12-07"
    :ensure t)
  (leaf catppuccin-theme
    :doc "Catppuccin for Emacs - 🍄 Soothing pastel theme for Emacs"
    :added "2025-01-11"
    :ensure t)
  (leaf doom-themes
    :doc "An opinionated pack of modern color-themes."
    :added "2025-06-04"
    :ensure t)
  (load-theme 'doom-homage-white t))

(leaf nix-mode
  :doc "Major mode for editing .nix files"
  :ensure t)

(leaf web-mode
  :doc "Major mode for editing web templates"
  :ensure t
  :custom ((web-mode-engines-alist . '(("razor" . "\\.razor\\'"))))
  :mode
  ("\\.html?\\'" . web-mode)
  ("\\.cshtml?\\'" . web-mode)
  ("\\.razor\\'" . web-mode))

(leaf typescript-ts-mode
  :doc "tree sitter support for TypeScript"
  :tag "builtin"
  :mode
  ("\\.tsx\\'" . tsx-ts-mode)
  ("\\.ts\\'" . typescript-ts-mode)
  ("\\.mts\\'" . typescript-ts-mode)
  :custom (typescript-ts-mode-indent-offset . 2))

(leaf treesit
  :doc "tree-sitter utilities"
  :tag "builtin"
  :custom (treesit-font-lock-level . 4))

(leaf treesit-auto
  :doc "Automatically use tree-sitter enhanced major modes"
  :ensure t
  :custom (treesit-auto-install . t)
  :global-minor-mode global-treesit-auto-mode)

(leaf tree-sitter
  :doc "Incremental parsing system"
  :ensure t
  :hook ((typescript-ts-mode tsx-ts-mode) . tree-sitter-hl-mode)
  :global-minor-mode global-tree-sitter-mode)

(leaf go-ts-mode
  :doc "tree-sitter support for Go."
  :added "2025-12-02"
  :tag "builtin" "go"
  :mode ("\\.go\\'"))

(leaf tree-sitter-langs
  :doc "Grammar bundle for tree-sitter"
  :ensure t
  :after tree-sitter)

(leaf astro-ts-mode
  :doc "Major mode for editing Astro templates"
  :ensure t)

(leaf yaml-mode
  :doc "Major mode for editing YAML files"
  :ensure t)

(leaf basic-mode
  :doc "Major mode for editing BASIC code"
  :ensure t
  :mode ("\\.vb\\'" . basic-generic-mode))

(defun c/skk-jisyo-files (&optional dict-dir)
  "List SKK dictionary files in `dict-dir'."
  (let ((dict-dir (or dict-dir
                      ;; home-managerで配置される場所がデフォルト
                      (f-join (getenv "HOME") ".nix-profile/share/skk"))))
    (directory-files dict-dir t "SKK-JISYO" t)))

(leaf ddskk
  :doc "Simple Kana to Kanji conversion program"
  :ensure t
  :custom `((skk-use-azik . t)
            (skk-azik-keyboard-type . "us101")
            (skk-jisyo . ,(f-join (or (getenv "XDG_DATA_HOME") "~/.local/share") "skk" "user-jisyo"))
            (skk-extra-jisyo-file-list . `,(c/skk-jisyo-files))
            (skk-jisyo-code . "utf-8")
            (skk-egg-like-newline . nil)
            (skk-dcomp-activate . t)
            ;; vimのskkと個人辞書を共有しているため、頻繁に書き込みをしないと競合する。
            ;; 人間の制約があるため、同時タイミングでの書き込みは発生し得ないので考慮しなくて良い。
            (skk-save-jisyo-instantly . t))
  :init
  (leaf ddskk-posframe
    :doc "Show Henkan tooltip for ddskk via posframe"
    :ensure t
    :when (display-graphic-p)
    :global-minor-mode t))

(leaf c/C-j-dwim-mode
  :doc "C-jを入力したときにコメントや文字列の中であれば `skk-mode' を起動する."
  :added "2025-07-23"
  :init
  (defun c/C-j-dwim ()
    (interactive)
    (let ((syntax-info (syntax-ppss)))
      (cond
       ;; `prog-mode' かつ (コメント内または文字列内) の場合は `skk-mode'
       ((and (derived-mode-p 'prog-mode)
             (or (nth 4 syntax-info)    ; コメント内
                 (nth 3 syntax-info)))  ; 文字列内
        (skk-mode 1))
       ;; `text-mode' を継承している場合、常に `skk-mode'
       ((derived-mode-p 'text-mode)
        (skk-mode 1))
       ;; `emacs-lisp-mode' では `eval-print-last-sexp'
       ((derived-mode-p 'emacs-lisp-mode)
        (eval-print-last-sexp))
       ;; org-mode no tag completion
       ((eq major-mode #'minibuffer-mode)
        (skk-mode 1))
       ;; デフォルト動作: `newline-and-indent'
       (t (newline-and-indent)))))
  (defvar c/C-j-dwim-map (make-sparse-keymap)
    "Smart C-j keymap.")
  (define-key c/C-j-dwim-map (kbd "C-j") 'c/C-j-dwim)
  (define-minor-mode c/C-j-dwim-mode
    "Smart C-j minor mode."
    :global t
    :init-value t
    :lighter ""
    :keymap c/C-j-dwim-map)
  (add-to-list 'emulation-mode-map-alists
               `((c/C-j-dwim-mode . ,c/C-j-dwim-map)))
  :global-minor-mode t)

(leaf ace-window
  :doc "Quickly switch windows"
  :ensure t
  :bind ([remap other-window] . #'ace-window)
  :custom ((aw-keys . '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))
  :defer-config
  (when (display-graphic-p)
    (ace-window-posframe-mode)))

(leaf org-mode
  :doc "Outline-based notes management and organizer"
  :tag "builtin"
  :bind (("C-c c" . org-capture)
         ("C-c a" . org-agenda))
  :custom ((org-todo-keywords . '((type
                                   "TODO(t)" "PENDING(p)" "SCHEDULED(s)" "REVIEW(r)" "ASSIGNED(a)"
                                   "|"
                                   "DONE(d)" "CANCELED(c@)")))
           (org-log-done . 'time)
           (org-log-reschedule . 'note)
           (org-log-redeadline . 'note)
           (org-log-into-drawer . "LOGBOOK")
           (org-startup-folded . 'content)
           (org-enforce-todo-dependencies . t)
           (org-enforce-todo-checkbox-dependencies . t)
           (org-src-preserve-indentation . t))
  :defvar org-babel-load-languages
  :config
  (add-to-list 'org-babel-load-languages '(shell . t)))

(leaf org-super-agenda
  :doc "Supercharge your agenda."
  :added "2025-07-18"
  :ensure t
  :init
  (with-eval-after-load 'org-agenda
    (org-super-agenda-mode 1)
    (defun c/org-agenda-format (item)
      "`org-super-agenda' での1行の書式を決定する。"
      (if-let* ((marker (get-text-property 0 'org-marker item))
                (buffer (marker-buffer marker)))
          (with-current-buffer buffer
            (save-excursion
              (goto-char marker)
              (if-let* ((props (c/org-agenda-collect-properties))
                        (formatter (c/org-agenda-make-formatter props)))
                  (concat item "\t" formatter)
                item)))
        item))
    (defun c/org-agenda-collect-properties ()
      "現在位置のエントリからアジェンダ関連のプロパティを収集する。"
      (seq-reduce
       (lambda (acc prop-def)
         (if-let* ((prop-name (plist-get prop-def :property))
                   (prop-value (org-entry-get (point) prop-name)))
             (plist-put acc (plist-get prop-def :key) prop-value)
           acc))
       c/org-agenda-property-definitions
       '()))
    (defun c/org-agenda-make-formatter (props)
      "`props' (収集されたプロパティ) からフォーマット文字列を生成する。"
      (when-let* ((parts (seq-keep
                          (lambda (prop-def)
                            (when-let* ((key (plist-get prop-def :key))
                                        (value (plist-get props key))
                                        (formatter (plist-get prop-def :formatter))
                                        (label (plist-get prop-def :label)))
                              (funcall formatter label value)))
                          c/org-agenda-property-definitions))
                  (parts))
        (mapconcat 'identity parts " ")))
    (defvar c/org-agenda-property-definitions
      '((:property "SCHEDULED"
                   :key :scheduled
                   :label "s"
                   :formatter c/org-agenda-format-date-label)
        (:property "DEADLINE"
                   :key :deadline
                   :label "d"
                   :formatter c/org-agenda-format-date-label))
      "agenda itemのプロパティ定義。
各定義は以下の要素を持つplist:
- :property :: Orgプロパティ名
- :key :: 内部で使用するキー
- :label :: 表示用ラベル
- :formatter :: (label value) を受け取り文字列を返す関数")
    (defun c/org-agenda-format-date-label (label value)
      "日付プロパティを [`label':`date'] 形式でフォーマットする。"
      (when-let ((element (org-timestamp-from-string value)))
        (let* ((year (org-element-property :year-start element))
               (month (org-element-property :month-start element))
               (day (org-element-property :day-start element))
               (hour-start (org-element-property :hour-start element))
               (minute-start (org-element-property :minute-start element))
               (hour-end (org-element-property :hour-end element))
               (minute-end (org-element-property :minute-end element))
               (date-part (format "%04d-%02d-%02d" year month day))
               (timestamp-text (cond
                                ((and hour-start minute-start hour-end minute-end)
                                 (format "%s %02d:%02d-%02d:%02d"
                                         date-part hour-start minute-start hour-end minute-end))
                                ((and hour-start minute-start)
                                 (format "%s %02d:%02d" date-part hour-start minute-start))
                                (t date-part))))
          (format "[%s:%s]" label timestamp-text)))))
  :custom (org-super-agenda-groups . '((:log t)
                                       (:auto-group t)
                                       (:name "Scheduled Today:" :scheduled today)
                                       (:name "Due Today:" :deadline today)
                                       (:name "Overdue:" :deadline past :transformer c/org-agenda-format)
                                       (:name "Due Soon:" :deadline future :transformer c/org-agenda-format)
                                       (:name "Schduled:" :scheduled future :transformer c/org-agenda-format)
                                       (:name "Someday:" :todo "TODO")
                                       (:name "Pending:" :todo "PENDING")
                                       (:name "Done:" :todo "DONE")
                                       (:discard (:anything t)))))

(leaf org-pomodoro
  :doc "Pomodoro implementation for org-mode."
  :added "2025-05-27"
  :ensure t)

(leaf ox-typst
  :doc "Typst Back-End for Org Export Engine."
  :added "2025-05-26"
  :ensure t
  :after org
  :config
  (add-to-list 'org-export-backends 'typst))

(leaf ox-hugo
  :doc "Hugo Markdown Back-End for Org Export Engine."
  :added "2025-05-26"
  :ensure t
  :after org
  :config
  (add-to-list 'org-export-backends 'hugo))

(leaf ob-mermaid
  :doc "Org-babel support for mermaid evaluation."
  :added "2025-07-05"
  :ensure t
  :commands org-babel-execute:mermaid
  :init
  (with-eval-after-load 'org-src
    (add-to-list 'org-src-lang-modes '("mermaid" . mermaid))))

(leaf mermaid-mode
  :doc "Major mode for working with mermaid graphs."
  :added "2025-07-05"
  :ensure t
  :mode ("\\.mermaid\\'" "\\.mmd\\'"))

(leaf htmlize
  :doc "Convert buffer text and decorations to HTML."
  :added "2025-07-07"
  :ensure t)

(leaf org-modern
  :doc "Modern looks for Org."
  :ensure t
  :hook org-mode-hook)

(leaf dashboard
  :doc "A startup screen extracted from Spacemacs"
  :ensure t
  :custom ((dashboard-items . '((recents . 10))))
  :config
  ;; daemonのときはstartupでdashboardを表示しても意味ない
  (dashboard-setup-startup-hook)
  (if (daemonp)
      (setq initial-buffer-choice
            (lambda () (get-buffer-create dashboard-buffer-name)))))

(leaf spacious-padding
  :doc "Increase the padding/spacing of frames and windows"
  :ensure t
  :global-minor-mode t)

(leaf doom-modeline
  :doc "A minimal and modern mode-line"
  :ensure t
  :hook (after-init-hook . doom-modeline-mode)
  :custom ((nerd-icons-font-family . "CaskaydiaCove")
           (doom-modeline-buffer-file-name-style . 'truncate-with-project)
           (doom-modeline-icon . t)
           (doom-modeline-major-mode-icon . nil)
           (doom-modeline-minor-modes . nil)))

(leaf editorconfig
  :doc "EditorConfig Emacs Plugin"
  :ensure t
  :global-minor-mode t)

(leaf git-gutter-fringe
  :doc "Fringe version of git-gutter.el"
  :ensure t
  :global-minor-mode global-git-gutter-mode
  :custom ((git-gutter:ask-p . nil))
  :bind ("C-c g" . #'hydra-git-gutter/body)
  :hydra (hydra-git-gutter (:hint nil)
                           "
Git gutter:
  _n_: next hunk        _s_: stage hunk     _q_: quit
  _p_: previous hunk    _u_: revert hunk
                      _C-p_: popup hunk
"
                           ("n" #'git-gutter:next-hunk)
                           ("p" #'git-gutter:previous-hunk)
                           ("s" #'git-gutter:stage-hunk)
                           ("u" #'git-gutter:revert-hunk)
                           ("C-p" #'git-gutter:popup-hunk)
                           ("q" nil :color blue)))

(leaf reformatter
  :doc "Define commands which run reformatters on the current buffer"
  :ensure t
  :config
  (reformatter-define stylua
    :program "stylua" :args '("-"))
  (reformatter-define nixfmt
    :program "nixfmt" :args '("-"))
  :hook ((nix-mode-hook . nixfmt-on-save-mode)))

(leaf ppp
  :doc "Extended pretty printer for Emacs Lisp."
  :ensure t)

(leaf inf-ruby
  :doc "Run a Ruby process in a buffer."
  :added "2025-04-30"
  :ensure t
  :hook ((ruby-mode-hook . inf-ruby-minor-mode)
         (ruby-ts-mode-hook . inf-ruby-minor-mode)))

(leaf rubocop
  :doc "An Emacs interface for RuboCop."
  :added "2025-04-30"
  :ensure t
  :hook ((ruby-mode-hook . rubocop-mode)
         (ruby-ts-mode-hook . rubocop-mode)))

(leaf ruby-electric
  :doc "Minor mode for electrically editing ruby code."
  :added "2025-04-30"
  :ensure t
  :hook ((ruby-mode-hook . ruby-electric-mode)
         (ruby-ts-mode-hook . ruby-electric-mode))
  :custom ((ruby-electric-expand-delimiters-list . nil)))

(leaf typst-ts-mode
  :doc "Tree Sitter support for Typst."
  :added "2025-05-31"
  :ensure t
  :custom ((typst-ts-indent-offset . 2)))

(leaf markdown-ts-mode
  :doc "Major mode for Markdown using Treesitter"
  :added "2025-04-24"
  :ensure t
  :mode ("\\.md\\'")
  :config
  (add-to-list 'treesit-language-source-alist '(markdown "https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown/src"))
  (add-to-list 'treesit-language-source-alist '(markdown-inline "https://github.com/tree-sitter-grammars/tree-sitter-markdown" "split_parser" "tree-sitter-markdown-inline/src")))

(leaf neotree
  :doc "A tree plugin like NerdTree for Vim."
  :added "2025-04-28"
  :ensure t)

(leaf calendar
  :doc "calendar functions."
  :added "2025-07-31"
  :tag "builtin"
  :custom ((calendar-mark-holidays-flag . t)
           (calendar-month-header . '(propertize
                                      (format "%d年 %s月" year month)
                                      'font-lock-face 'calendar-month-header))
           (calendar-day-header-array . ["日" "月" "火" "水" "木" "金" "土"])
           (calendar-day-name-array . ["日" "月" "火" "水" "木" "金" "土"])))

(leaf japanese-holidays
  :doc "Calendar functions for the Japanese calendar."
  :added "2025-07-31"
  :ensure t
  :after calendar
  :require t
  :config
  (setq calendar-holidays (append japanese-holidays holiday-local-holidays holiday-other-holidays)))

(leaf undo-fu
  :doc "Undo helper with redo."
  :added "2025-08-12"
  :ensure t
  :bind (([remap undo] . #'undo-fu-only-undo)
         ([remap undo-redo] . #'undo-fu-only-redo)))

(leaf vundo
  :doc "Visual undo tree."
  :added "2025-08-12"
  :ensure t
  :custom ((vundo-glyph-alist . vundo-unicode-symbols)))

(leaf highlight-indent-guides
  :doc "Minor mode to highlight indentation."
  :added "2025-08-17"
  :ensure t
  :hook (prog-mode-hook yaml-mode-hook)
  :custom ((highlight-indent-guides-method . 'column)
           (highlight-indent-guides-auto-enabled . t)
           (highlight-indent-guides-responsive . t)))

(provide 'init)

;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; init.el ends here
