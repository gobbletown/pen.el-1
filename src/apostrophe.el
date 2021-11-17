(defun apostrophe-start-chatbot-from-selection (text)
  (interactive (list (pen-screen-or-selection)))

  (let* ((sme (pf-who-is-the-subject-matter-expert-for-/1 text))
         (blurb (pf-generate-wiki-blurb-for-a-famous-person/1 sme)))
    (sps (cmd "apostrophe" sme "" blurb))))

(provide 'pen-apostrophe)