;; https://github.com/semiosis/ink.el

;; *( is so it will work in YAML. However, it
;; still requires escaping, so now it's just to
;; differentiate from regular text properties,
;; but the differentiation serves no useful
;; purpose.

(defface ink-task
  '((t :foreground "#d2268b"
       :background "#2e2e2e"
       :weight bold
       :underline t))
  "Face representing text to be interpreted with respect to an LM."
  :group 'ink-faces)

(defface ink-generated
  '((t :foreground "#8bd226"
       :background "#2e2e2e"
       :weight normal
       :slant italic
       :underline t))
  "Face representing text that has been generated by an LM."
  :group 'ink-faces)

(defface ink-unknown
  '((t :foreground "#8b26d2"
       :background "#2e2e2e"
       :weight normal
       :slant italic
       :underline t))
  "Face."
  :group 'ink-faces)

;; When you save in one, the other is updated
(define-derived-mode ink-mode fundamental-mode "Ink"
  "Ink mode"
  :after-hook
  (progn
    (add-hook 'write-contents-functions #'ink-mode-before-save-hook)))

;; See the ink source.
;; This mode is not meant as a regular editing/prompting environment.
;; Rather, it's like looking at HTML source.
(define-derived-mode ink-source-mode emacs-lisp-mode "Ink source"
  "Ink source mode"
  :after-hook
  (progn
    (add-hook 'write-contents-functions #'ink-source-mode-before-save-hook)
    (ink-decode-source-buffer)))

(add-to-list 'auto-mode-alist '("\\.ink\\'" . ink-source-mode))

;; (add-to-list 'auto-mode-alist '("\\.ink\\'" . ink-edit-mode))

(defun pen-open-ink (&optional fp)
  (if (not fp)
      (setq fp (get-path)))
  (let* ((dn (f-dirname fp))
         (bn (basename fp))
         (fn (file-name-sans-extension bn))
         (ext (file-name-extension bn)))
    (cond ((or (string-equal "ink" ext)
               (string-equal "INK" ext)))
          (ink-decode-source-buffer))))

;; (add-hook 'find-file-hooks 'pen-open-ink)
;; (remove-hook 'find-file-hooks 'pen-open-ink)

(defun ink-mode-before-save-hook (&optional args)
  ;; (throw 'ink-mode-save-source t)
  (when (eq major-mode 'ink-mode)
    (let* ((ink
            (ink-encode-from-textprops (pen-textprops-in-region-or-buffer)))
           (b (current-buffer))
           (bufn (s-replace-regexp "^\\*\\(.*\\)\\*$" "\\1" (buffer-name)))
           (bn (basename bufn)))
      (kill-buffer b)
      (with-current-buffer (switch-to-buffer bn)
        (erase-buffer)
        (insert ink)
        (beginning-of-buffer)
        (save-buffer))
      ;; (error "abort real save")
      ;; (throw 'ink-mode-save-source t)
      )
    t))

(defun ink-source-mode-before-save-hook (&optional args)
  (when (eq major-mode 'ink-source-mode)
    (ink-decode-source-buffer)
    nil))

(defun ink-mode-after-save-hook ()
  (when (eq major-mode 'ink-mode)
    ;; Write back to the original .ink buffer
    ;; (ink-decode-source-buffer)
    ))

(add-hook 'after-save-hook #'ink-mode-after-save-hook)

;; TODO The combination of doing both of these here may result in less duplication and less random changing of the file
;; - filter only properties I want
;; - sort
;; TODO
;; - clear all
(defun pen-textprops-in-region-or-buffer ()
  (if (region-active-p)
      (format "%S" (buffer-substring (region-beginning) (region-end)))
    (format "%S" (buffer-string))))

;; TODO Ensure that only a particular list of text properties are preserved
(defun ink-encode-from-textprops (s)
  (interactive (list (pen-textprops-in-region-or-buffer)))
  (let ((ink s))
    (if (interactive-p)
        (if (pen-selected-p)
            (pen-region-filter (eval `(lambda (s) ,ink)))
          (pen-etv ink))
      ink)))

(defun ink-encode-from-data (text &optional data)
  (interactive (list (pen-selection) pen-last-prompt-data))

  (if (sor text)
      (if pen-ink-disabled
          text
          (progn
            (let* ((text (or
                          text
                          (pen-selection)))
                   (data (or data
                             pen-last-prompt-data))

                   (data (cl-loop for atp in data collect
                               (let ((k (car atp))
                                     (v (cdr atp)))
                                 (if (stringp k)
                                     (setq k (intern k))
                                   k)
                                 (cons k v))))
                   ;; TODO Convert all data keys from strings into symbols (if they were string)
                   )

              (if (interactive-p)
                  (progn
                    (pen-alist-setcdr
                     'data 'PEN_ENGINE
                     (read-string-hist "engine: "
                                       (cdr (assoc 'PEN_ENGINE data))))
                    (pen-alist-setcdr
                     'data 'PEN_LANGUAGE
                     (read-string-hist "language: "
                                       (cdr (assoc 'PEN_LANGUAGE data))))
                    (pen-alist-setcdr
                     'data 'PEN_TOPIC
                     (read-string-hist "topic: "
                                       (or
                                        (cdr (assoc 'PEN_TOPIC data))
                                        (pen-topic t)))))))

            (if (not (sor (cdr (assoc 'PEN_ENGINE data))))
                (pen-alist-setcdr 'data 'PEN_ENGINE "OpenAI GPT-3"))
            (if (not (sor (cdr (assoc 'PEN_LANGUAGE data))))
                (pen-alist-setcdr 'data 'PEN_LANGUAGE "English"))

            ;; (cond
            ;;  ((and
            ;;    (assoc "INK_TYPE" data)
            ;;    (string-equal
            ;;     "generated"
            ;;     (or (sor (cdr (assoc "INK_TYPE" data)))
            ;;         "")))
            ;;   (setq data (asoc-merge data '((face ink-generated)))))
            ;;  ((and
            ;;    (assoc "INK_TYPE" data)
            ;;    (string-equal
            ;;     "task"
            ;;     (or (sor (cdr (assoc "INK_TYPE" data)))
            ;;         "")))
            ;;   (setq data (asoc-merge data '((face ink-task))))))

            (let* ((ink
                    (let ((ink)
                          (start 0)
                          (end))
                      (setq end (length text))
                      (cl-loop for p in data do
                            (let* ((key (car p))
                                   (val (cdr p))
                                   (key
                                    (if (stringp key)
                                        (setq key (intern key))
                                      key)))
                              (put-text-property start end key val text)))
                      (setq ink (format "%S" text))
                      ink))
                   (ink ink))
              (if (interactive-p)
                  (if (pen-selected-p)
                      (pen-region-filter (eval `(lambda (s) ,ink)))
                    (pen-etv ink))
                ink))))
    ""))

(defun ink-propertise (s)
  (ink-decode (ink-encode-from-data s pen-last-prompt-data)))
(defalias 'ink-propertize 'ink-propertise)

(comment
 (defun ink-remove-bad-properties ()
   (interactive)
   (remove-text-properties
    (point-min)
    (point-max)
    (let ((lst (ink-list-all-bad-properties (buffer-string))))
      (-interleave lst (make-list (length lst) nil)))))

 ;; (pen-etv (pps (ink-list-all-properties (buffer-string))))
 ;; (pen-etv (pps (ink-list-all-bad-properties (pen-selected-text nil t))))
 (defun ink-list-all-bad-properties (s)
   (-filter
    (lambda (e)
      (not (string-match "^PEN_" (str (car e)))))
    (-uniq
     (flatten-once
      (cl-loop for inl in (object-intervals s)
               collect
               (cl-loop for (p v) on (nth 2 inl) while v
                        collect
                        (list p v)))))))

 (defun ink-depropertize (ink)
   ink
   ;; (ink-decode-source-buffer)
   ))

(defun ink-list-all-bad-properties (s)
   (-filter
    (lambda (e)
      (not (string-match "^PEN_" (str (car e)))))
    (-uniq
     (flatten-once
      (cl-loop for inl in (object-intervals s)
               collect
               (cl-loop for (p v) on (nth 2 inl) while v
                        collect
                        (list p v)))))))

(defun ink-list-all-properties-for-selection (&optional s)
  (interactive (list (pen-selected-text nil t)))

  (if (not s)
      (setq s (pen-selected-text nil t)))

  (-filter
   (lambda (e)
     (string-match "^PEN_" (str (car e))))
   (-uniq
    (flatten-once
     (cl-loop for inl in (object-intervals s)
              collect
              (cl-loop for (p v) on (nth 2 inl) while v
                       collect
                       (list p v)))))))

(defun ink-decode (text)
  ;; Do not use (pen-selection t)
  ;; This assumes the text is visibly encoded
  (interactive (list (pen-selection)))

  (if (sor text)
      (let* ((text (if (string-match "#(" text)
                       ;; (pen-etv (q text))
                       (pen-eval-string text)
                     text)))
        (if (interactive-p)
            (if (pen-selected-p)
                (pen-region-filter (eval `(lambda (s) ,text)))
              (pen-etv text))
          text))
    ""))

(defun ink-decode-source-buffer ()
  (interactive)
  ;; TODO Go over a buffer and add face text properties / overlays
  ;; For whenever ink-type is found.
  (if (eq major-mode 'ink-source-mode)
      (let* ((s (ink-decode (buffer-string)))
             (fp (buffer-file-name))
             (bufname (concat "*" fp "*")))
        (let ((bexists (buffer-exists bufname)))
          (with-current-buffer (switch-to-buffer bufname)
            (if (or (not bexists)
                    (yn "Reload from .ink?"))
                (progn
                  (erase-buffer)
                  (insert s)
                  (beginning-of-buffer)))
            (ink-mode)
            (current-buffer))))))

(defun pen-next-ink ()
  (interactive)
  (pen-next-prop-change 'PEN_PROMPT))

(defun pen-prev-ink ()
  (interactive)
  (pen-prev-prop-change 'PEN_PROMPT))

(defun ink-get-properties-here (&optional start end)
  "Remove flyspell overlays in region."
  (interactive
   (list
    (if mark-active (region-beginning) (point))
    (if mark-active (region-end) (point))))

  (if (not start)
      (setq start
            (if mark-active
                (region-beginning)
              (point))))

  (if (not end)
      (setq end
            (if mark-active
                (region-end)
              start)))

  (if (and
       (< 1 start)
       (eq start end))
      (setq start (- start 1)))

  (let ((props
         (cond
          ((is-ink-p start)
           (append
            '(face ink-generated)
            '(INK_TYPE "generated")
            (-flatten (ink-list-all-properties-for-selection (buffer-substring start end)))))
          ((ink-flows-here-p start)
           (append
            '(face ink-generated)
            '(INK_TYPE "generated")
            (-flatten (ink-list-all-properties-for-selection (buffer-substring (- start 1) (- end 1)))))))))

    (if (and
         props
         (interactive-p))
        (etv props)
      props)))

(defun pen-on-change (start end length &optional content-change-event-fn)
  "Executed when a file is changed.
Added to `after-change-functions'."
  ;; Note:
  ;;
  ;; Each function receives three arguments: the beginning and end of the region
  ;; just changed, and the length of the text that existed before the change.
  ;; All three arguments are integers. The buffer that has been changed is
  ;; always the current buffer when the function is called.
  ;;
  ;; The length of the old text is the difference between the buffer positions
  ;; before and after that text as it was before the change. As for the
  ;; changed text, its length is simply the difference between the first two
  ;; arguments.
  ;;
  ;; So (47 54 0) means add    7 chars starting at pos 47
  ;; So (47 47 7) means delete 7 chars starting at pos 47
  (ignore-errors
    (save-match-data
      (if (is-ink-p start)
          (let ((inhibit-quit t)
                (props
                 (append
                  '(face ink-generated)
                  '(INK_TYPE "generated")
                  (-flatten (ink-list-all-properties-for-selection (buffer-substring start end)))))
                (time-diff (- (time-to-seconds) (cdr (assoc "PEN_GEN_TIME" pen-last-prompt-data)))))

            (if (not (pen-regex-at-point-p (cdr (assoc "PEN_RESULT" pen-last-prompt-data)) t))
                (progn (message "removing")
                       (remove-text-properties start end props))
              (message "%s" (cdr (assoc "PEN_RESULT" pen-last-prompt-data)))
              ;; This method doesn't really work well, because I may take a while to make the selection
              ;; (if (< 10 time-diff)
              ;;     ;; Remove properties from text changed, if it was manually changed
              ;;     (remove-text-properties start end props))
              )

            ;; To do this, compare the time of the last prompt
            ;; If it was more than 1 second ago, then remove properties

            ;; (message "%s" (concat "edit" (buffer-substring start end)))
            )))))

;; 1 is the point (not zero) when the cursor
;; is at the beginning of the buffer
(defun is-ink-p (&optional p)
  "If at the end, doesn't flow"
  (if (not p)
      (setq p (point)))

  (if (< 0 p)
      (eq 'ink-generated (get-text-property p 'face))))

(defun ink-flows-here-p (&optional p)
  (if (not p)
      (setq p (point)))

  (setq p (- p 1))

  (is-ink-p p))
(defalias 'is-ink-before-p 'ink-flows-here-p)

;; TODO Figure out a way of adding this to buffers that have ink
;; I think I have to do a check, actually
(defun pen-add-ink-change-hook ()
  (interactive)
  (add-hook 'after-change-functions 'pen-on-change nil t))

(provide 'pen-ink)
