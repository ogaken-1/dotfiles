(require 'cl-macs)

(defun extract-leaf-symbols-with-ensure (file)
  "Extract all symbols from (leaf ...) forms with :ensure t in FILE."
  (with-temp-buffer
    (insert-file-contents file)
    (let (result)
      (cl-labels ((process-form (form)
                    "Process a form recursively."
                    (when (and (listp form) (eq (car form) 'leaf))
                      (let ((symbol (cadr form))
                            (props (cddr form)))
                        (when (plist-get props :ensure)
                          (push symbol result)))
                      (dolist (item form)
                        (when (listp item)
                          (process-form item))))))
        (while (not (eobp))
          (let ((form (ignore-errors (read (current-buffer)))))
            (when form
              (process-form form)))))
      (delete-dups (reverse result)))))

(defun print-symbols (symbols)
  "Print each SYMBOL in SYMBOLS on a new line."
  (dolist (symbol symbols)
    (princ (symbol-name symbol))
    (terpri)))

(let ((file (car command-line-args-left)))
  (if (not file)
      (message "Usage: emacs --batch -l %s <file>" load-file-name)
    (print-symbols (extract-leaf-symbols-with-ensure file))))
