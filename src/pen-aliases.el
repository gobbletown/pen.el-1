(require 'pcase)

(defalias 're-match-p 'string-match)
(defalias 'pen-empty-string-p 's-blank?)
(defalias 'tv 'pen-tv)
(defalias 'etv 'pen-etv)
(defalias 'f-basename 'f-filename)
(defalias 'region2string 'buffer-substring)
(defalias 'let-values 'pcase-let)
(defalias 'string-or 'str-or)
(defalias 'get-top-level 'projectile-project-root)
(defalias 'current-buffer-name 'buffer-name)

(provide 'pen-aliases)