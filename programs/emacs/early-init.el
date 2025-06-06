(eval-when-compile
  (require 'leaf))

(leaf gc
  :tag "builtin"
  :custom `((gc-cons-threshold . ,(* 10 gc-cons-threshold))
            (garbage-collection-messages . nil)))

(leaf frame
  :doc "define customization properties of builtins"
  :tag "builtin"
  :custom
  (tool-bar-mode . nil)
  (menu-bar-mode . nil)
  (scroll-bar-mode . nil)
  (indent-tabs-mode . nil)
  ;; 起動時にframeがresizeされるのが抑制されてちょっと動きがスッキリする
  (frame-inhibit-implied-resize . t)
  (inhibit-startup-screen . t)
  :config
  ;; Use nf patched cascadia code if avalilable.
  (let '(font "CaskaydiaCove NFM")
    (if (fontp font)
        (set-frame-font font))))

(leaf tab-bar
  :doc "frame-local tabs with named persistent window configurations."
  :added "2025-06-04"
  :tag "builtin"
  :custom ((tab-bar-new-tab-choice . "*scratch*")
           (tab-bar-mode . t)))
