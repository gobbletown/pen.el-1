(require 'handle)

(handle '(prog-mode)
        :complete '()
        ;; This is for running the program
        :run '()
        :repls '()
        :formatters '()
        :refactor '()
        :debug '()
        :docfun '()
        :docs '(pf-get-documentation-for-syntax-given-screen/2)
        :docsearch '()
        :godec '()
        :godef '()
        :showuml '()
        :nextdef '()
        :prevdef '()
        :nexterr '()
        :preverr '()
        :rc '()
        :errors '()
        :assignments '()
        :references '()
        :definitions '()
        :implementations '())

(handle '(conf-mode feature-mode)
        :run '()
        :repls '()
        :formatters '()
        :docs '(pf-get-documentation-for-syntax-given-screen/2)
        :godef '()
        :docsearch '()
        :nextdef '()
        :prevdef '()
        :nexterr '()
        :preverr '())

(handle '(org-mode)
        :navtree '()
        :run '()
        :docs '(pf-get-documentation-for-syntax-given-screen/2)
        :nexterr '()
        :preverr '()
        :complete '()
        :rc '())

(handle '(text-mode)
        :nexterr '()
        :docs '(pf-get-documentation-for-syntax-given-screen/2)
        :preverr '())

(handle '(fundamental-mode)
        :nexterr '()
        :docs '(pf-get-documentation-for-syntax-given-screen/2)
        :preverr '())

(handle '(special-mode)
        :nexterr '()
        :docs '(pf-get-documentation-for-syntax-given-screen/2)
        :preverr '())

(handle '(comint-mode)
        :nexterr '()
        :docs '(pf-get-documentation-for-syntax-given-screen/2)
        :preverr '())

(provide 'pen-handle)