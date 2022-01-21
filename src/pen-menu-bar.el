;; Known issues:
;; - To select from a menu, while in the terminal
;;   you must drag the mouse across the menu item you want

(tool-bar-mode -1) ; "M-x tool-bar-mode"
(toggle-scroll-bar -1)

(defset menu-bar-file-menu
  (let ((menu (make-sparse-keymap "File")))

    ;; The "File" menu items
    (bindings--define-key menu [exit-emacs]
      '(menu-item "Quit" save-buffers-kill-terminal
                  :help "Save unsaved buffers, then exit"))

    (bindings--define-key menu [separator-exit]
      menu-bar-separator)

    (unless (featurep 'ns)
      (bindings--define-key menu [close-tab]
        '(menu-item "Close Tab" tab-close
                    :visible (fboundp 'tab-close)
                    :help "Close currently selected tab"))
      (bindings--define-key menu [make-tab]
        '(menu-item "New Tab" tab-new
                    :visible (fboundp 'tab-new)
                    :help "Open a new tab"))

      (bindings--define-key menu [separator-tab]
        menu-bar-separator))

    ;; Don't use delete-frame as event name because that is a special
    ;; event.
    (bindings--define-key menu [delete-this-frame]
      '(menu-item "Delete Frame" delete-frame
                  :visible (fboundp 'delete-frame)
                  :enable (delete-frame-enabled-p)
                  :help "Delete currently selected frame"))
    (bindings--define-key menu [make-frame-on-monitor]
      '(menu-item "New Frame on Monitor..." make-frame-on-monitor
                  :visible (fboundp 'make-frame-on-monitor)
                  :help "Open a new frame on another monitor"))
    (bindings--define-key menu [make-frame-on-display]
      '(menu-item "New Frame on Display..." make-frame-on-display
                  :visible (fboundp 'make-frame-on-display)
                  :help "Open a new frame on another display"))
    (bindings--define-key menu [make-frame]
      '(menu-item "New Frame" make-frame-command
                  :visible (fboundp 'make-frame-command)
                  :help "Open a new frame"))

    (bindings--define-key menu [separator-frame]
      menu-bar-separator)

    (bindings--define-key menu [one-window]
      '(menu-item "Remove Other Windows" delete-other-windows
                  :enable (not (one-window-p t nil))
                  :help "Make selected window fill whole frame"))

    (bindings--define-key menu [new-window-on-right]
      '(menu-item "New Window on Right" split-window-right
                  :enable (and (menu-bar-menu-frame-live-and-visible-p)
                               (menu-bar-non-minibuffer-window-p))
                  :help "Make new window on right of selected one"))

    (bindings--define-key menu [new-window-below]
      '(menu-item "New Window Below" split-window-below
                  :enable (and (menu-bar-menu-frame-live-and-visible-p)
                               (menu-bar-non-minibuffer-window-p))
                  :help "Make new window below selected one"))

    (bindings--define-key menu [separator-window]
      menu-bar-separator)

    (bindings--define-key menu [recover-session]
      '(menu-item "Recover Crashed Session" recover-session
                  :enable
                  (and auto-save-list-file-prefix
                       (file-directory-p
                        (file-name-directory auto-save-list-file-prefix))
                       (directory-files
                        (file-name-directory auto-save-list-file-prefix)
                        nil
                        (concat "\\`"
                                (regexp-quote
                                 (file-name-nondirectory
                                  auto-save-list-file-prefix)))
                        t))
                  :help "Recover edits from a crashed session"))
    (bindings--define-key menu [revert-buffer]
      '(menu-item "Revert Buffer" revert-buffer
                  :enable (or (not (eq revert-buffer-function
                                       'revert-buffer--default))
                              (not (eq
                                    revert-buffer-insert-file-contents-function
                                    'revert-buffer-insert-file-contents--default-function))
                              (and buffer-file-number
                                   (or (buffer-modified-p)
                                       (not (verify-visited-file-modtime
                                             (current-buffer))))))
                  :help "Re-read current buffer from its file"))
    (bindings--define-key menu [write-file]
      '(menu-item "Save As..." write-file
                  :enable (and (menu-bar-menu-frame-live-and-visible-p)
                               (menu-bar-non-minibuffer-window-p))
                  :help "Write current buffer to another file"))
    (bindings--define-key menu [save-buffer]
      '(menu-item "Save" save-buffer
                  :enable (and (buffer-modified-p)
                               (buffer-file-name)
                               (menu-bar-non-minibuffer-window-p))
                  :help "Save current buffer to its file"))

    (bindings--define-key menu [separator-save]
      menu-bar-separator)


    (bindings--define-key menu [kill-buffer]
      '(menu-item "Close" kill-this-buffer
                  :enable (kill-this-buffer-enabled-p)
                  :help "Discard (kill) current buffer"))
    (bindings--define-key menu [insert-file]
      '(menu-item "Insert File..." insert-file
                  :enable (menu-bar-non-minibuffer-window-p)
                  :help "Insert another file into current buffer"))
    (bindings--define-key menu [dired]
      '(menu-item "Open Directory..." dired
                  :enable (menu-bar-non-minibuffer-window-p)
                  :help "Read a directory, to operate on its files"))
    (bindings--define-key menu [open-file]
      '(menu-item "Open File..." menu-find-file-existing
                  :enable (menu-bar-non-minibuffer-window-p)
                  :help "Read an existing file into an Emacs buffer"))
    (bindings--define-key menu [new-file]
      '(menu-item "Visit New File..." find-file
                  :enable (menu-bar-non-minibuffer-window-p)
                  :help "Specify a new file's name, to edit the file"))

    menu))

(defset menu-bar-help-menu
  (let ((menu (make-sparse-keymap "Help")))
    (bindings--define-key menu [about-gnu-project]
      '(menu-item "About GNU" describe-gnu-project
                  :help "About the GNU System, GNU Project, and GNU/Linux"))
    (bindings--define-key menu [about-emacs]
      '(menu-item "About Emacs" about-emacs
                  :help "Display version number, copyright info, and basic help"))
    (bindings--define-key menu [sep4]
      menu-bar-separator)
    (bindings--define-key menu [describe-no-warranty]
      '(menu-item "(Non)Warranty" describe-no-warranty
                  :help "Explain that Emacs has NO WARRANTY"))
    (bindings--define-key menu [describe-copying]
      '(menu-item "Copying Conditions" describe-copying
                  :help "Show the Emacs license (GPL)"))
    (bindings--define-key menu [getting-new-versions]
      '(menu-item "Getting New Versions" describe-distribution
                  :help "How to get the latest version of Emacs"))
    (bindings--define-key menu [sep2]
      menu-bar-separator)
    (bindings--define-key menu [external-packages]
      '(menu-item "Finding Extra Packages" view-external-packages
                  :help "How to get more Lisp packages for use in Emacs"))
    (bindings--define-key menu [find-emacs-packages]
      '(menu-item "Search Built-in Packages" finder-by-keyword
                  :help "Find built-in packages and features by keyword"))
    (bindings--define-key menu [more-manuals]
      `(menu-item "More Manuals" ,menu-bar-manuals-menu))
    (bindings--define-key menu [emacs-manual]
      '(menu-item "Read the Emacs Manual" info-emacs-manual
                  :help "Full documentation of Emacs features"))
    (bindings--define-key menu [describe]
      `(menu-item "Describe" ,menu-bar-describe-menu))
    (bindings--define-key menu [search-documentation]
      `(menu-item "Search Documentation" ,menu-bar-search-documentation-menu))
    (bindings--define-key menu [sep1]
      menu-bar-separator)
    (bindings--define-key menu [emacs-psychotherapist]
      '(menu-item "Emacs Psychotherapist" doctor
                  :help "Our doctor will help you feel better"))
    (bindings--define-key menu [send-emacs-bug-report]
      '(menu-item "Send Bug Report..." report-emacs-bug
                  :help "Send e-mail to Emacs maintainers"))
    (bindings--define-key menu [emacs-manual-bug]
      '(menu-item "How to Report a Bug" info-emacs-bug
                  :help "Read about how to report an Emacs bug"))
    (bindings--define-key menu [emacs-known-problems]
      '(menu-item "Emacs Known Problems" view-emacs-problems
                  :help "Read about known problems with Emacs"))
    (bindings--define-key menu [emacs-news]
      '(menu-item "Emacs News" view-emacs-news
                  :help "New features of this version"))
    (bindings--define-key menu [emacs-faq]
      '(menu-item "Emacs FAQ" view-emacs-FAQ
                  :help "Frequently asked (and answered) questions about Emacs"))

    (bindings--define-key menu [emacs-tutorial-language-specific]
      '(menu-item "Emacs Tutorial (choose language)..."
                  help-with-tutorial-spec-language
                  :help "Learn how to use Emacs (choose a language)"))
    (bindings--define-key menu [emacs-tutorial]
      '(menu-item "Emacs Tutorial" help-with-tutorial
                  :help "Learn how to use Emacs"))

    ;; In macOS it's in the app menu already.
    ;; FIXME? There already is an "About Emacs" (sans ...) entry in the Help menu.
    (and (featurep 'ns)
         (not (eq system-type 'darwin))
         (bindings--define-key menu [info-panel]
           '(menu-item "About Emacs..." ns-do-emacs-info-panel)))
    menu))


(defset menu-bar-pen-menu
  (let ((menu (make-sparse-keymap "🖊  Pen.el")))
    (bindings--define-key menu [pen-acolyte-dired-penel]
      '(menu-item "Go to Pen.el directory" pen-acolyte-dired-penel
                  :help "Go to Pen.el source code"))
    (bindings--define-key menu [mi-pen-reload]
      '(menu-item "Reload Pen.el config, engines and prompts" pen-reload
                  :help "Reload Pen.el config, engines and prompts"))
    (bindings--define-key menu [mi-pen-start-hidden-terminal]
      '(menu-item "Start hidden human terminal" pen-start-hidden-terminal
                  :help "When a human is prompted, it will appear in the hidden terminal"))
    (bindings--define-key menu [mi-pen-reload-config-file]
      '(menu-item "Reload individual config file" pen-reload-config-file
                  :help "This is useful for editing Pen.el source and reloading"))
    (bindings--define-key menu [mi-pen-start-gui-web-browser]
      '(menu-item "Start Pen.el in a GUI web browser" pen-start-gui-web-browser
                  :help "Start Pen.el in a GUI web browser"))
    (bindings--define-key menu [mi-pen-of-imagination]
      '(menu-item "The pen of imagination - |:ϝ∷¦ϝ" pen-of-imagination
                  :help "The pen of imagination - |:ϝ∷¦ϝ"))
    (bindings--define-key menu [cancel-menu]
      '(menu-item "Cancel" identity-command
                  :help "Cancel out of this menu"))
    menu))

(defset menu-bar-daemons-menu
  (let ((menu (make-sparse-keymap "Daemons")))
    (bindings--define-key menu [pen-reload-all]
      '(menu-item "Reload Pen.el config, engines and prompts for all daemons" pen-reload-all
                  :help "Reload Pen.el config, engines and prompts for all daemons"))

    (bindings--define-key menu [cancel-menu]
      '(menu-item "Cancel" identity-command
                  :help "Cancel out of this menu"))
    menu))

(defset menu-bar-apostrophe-menu
  (let ((menu (make-sparse-keymap "Apostrophe")))
    (bindings--define-key menu [apostrophe-start-chatbot-from-name]
      '(menu-item "Start chatbot from their name" apostrophe-start-chatbot-from-name
                  :help "Speak to someone, given their name"))
    (bindings--define-key menu [mi-apostrophe-start-chatbot-from-selection]
      '(menu-item "Start chatbot from selection" apostrophe-start-chatbot-from-selection
                  :help "Suggest some subject-matter-experts for the selected text, and speak to them"))

    (bindings--define-key menu [cancel-menu]
      '(menu-item "Cancel" identity-command
                  :help "Cancel out of this menu"))
    menu))

(defset menu-bar-cterm-menu
  (let ((menu (make-sparse-keymap "ComplexTerm")))
    (bindings--define-key menu [mi-cterm-start]
      '(menu-item "Start cterm (Pen.el wrapping a host terminal)" cterm-start
                  :help "Pen.el wraps your host's terminal to provide augmented intelligence"))
    (bindings--define-key menu [mi-pet-start]
      '(menu-item "Start pet (Pen.el wrapping a terminal within the docker container)" pet-start
                  :help "Pen.el wraps your host's terminal to provide augmented intelligence"))
    (bindings--define-key menu [cancel-menu]
      '(menu-item "Cancel" identity-command
                  :help "Cancel out of this menu"))
    menu))

(defset menu-bar-channel-menu
  (let ((menu (make-sparse-keymap "Chann.el")))
    (bindings--define-key menu [mi-channel-chatbot-from-name]
      '(menu-item "Channel a chatbot to control your terminal" channel-chatbot-from-name
                  :help "A chatbot takes command of your host terminal"))
    (bindings--define-key menu [cancel-menu]
      '(menu-item "Cancel" identity-command
                  :help "Cancel out of this menu"))
    menu))

(defset menu-bar-ii-menu
  (let ((menu (make-sparse-keymap "Imaginary Interpreter")))
    (bindings--define-key menu [mi-pen-start-imaginary-interpreter]
      '(menu-item "Start an imaginary interpreter" pen-start-imaginary-interpreter
                  :help "Start an imaginary interpreter, given the name/language"))
    (bindings--define-key menu [cancel-menu]
      '(menu-item "Cancel" identity-command
                  :help "Cancel out of this menu"))
    menu))

(defset menu-bar-mtp-menu
  (let ((menu (make-sparse-keymap "MadTeaParty")))
    (bindings--define-key menu [pen-mtp-connect-with-name]
      '(menu-item "Spawn a new user in Mad Tea-Party" pen-mtp-connect-with-name
                  :help "This starts an irc client for new user to Mad Tea-Party"))
    (bindings--define-key menu [cancel-menu]
      '(menu-item "Cancel" identity-command
                  :help "Cancel out of this menu"))
    menu))

(defset menu-bar-paracosm-menu
  (let ((menu (make-sparse-keymap "Paracosm")))
    (bindings--define-key menu [from-name]
      '(menu-item "Switch brain" pen-org-brain-switch-brain
                  :help "Switch brain"))
    (bindings--define-key menu [cancel-menu]
      '(menu-item "Cancel" identity-command
                  :help "Cancel out of this menu"))
    menu))

(defset menu-bar-esp-menu
  (let ((menu (make-sparse-keymap "ESP")))
    (bindings--define-key menu [mi-lsp]
      '(menu-item "Start LSP (Language Server Protocol)" lsp
                  :help "Start LSP in current buffer"))
    (bindings--define-key menu [mi-esp]
      '(menu-item "Start ESP (Extra Sensory Perception)" lsp
                  :help "Start ESP in current buffer"))
    (bindings--define-key menu [cancel-menu]
      '(menu-item "Cancel" identity-command
                  :help "Cancel out of this menu"))
    menu))

(defset menu-bar-prompts-menu
  (let ((menu (make-sparse-keymap "Prompts")))
    (bindings--define-key menu [mi-pen-acolyte-dired-prompts]
      '(menu-item "Go to prompts" pen-acolyte-dired-prompts
                  :help "Go to prompts source directory"))
    (bindings--define-key menu [mi-pen-generate-prompt-functions]
      '(menu-item "Generate prompt functions" pen-generate-prompt-functions
                  :help "Regenerate prompt functions"))
    (bindings--define-key menu [cancel-menu]
      '(menu-item "Cancel" identity-command
                  :help "Cancel out of this menu"))
    menu))

(defset menu-bar-engines-menu
  (let ((menu (make-sparse-keymap "Engines")))
    (bindings--define-key menu [mi-pen-load-engines]
      '(menu-item "Reload engines" pen-load-engines
                  :help "Reload engines from YAML"))
    (bindings--define-key menu [mi-pen-acolyte-dired-engines]
      '(menu-item "Go to engines directory" pen-acolyte-dired-engines
                  :help "Go to engines source directory"))
    (bindings--define-key menu [cancel-menu]
      '(menu-item "Cancel" identity-command
                  :help "Cancel out of this menu"))
    menu))

(defset menu-bar-history-menu
  (let ((menu (make-sparse-keymap "History")))
    (bindings--define-key menu [mi-pen-continue-from-hist]
      '(menu-item "Continue prompt from history" pen-continue-from-hist
                  :help "Continue prompt from history"))
    (bindings--define-key menu [cancel-menu]
      '(menu-item "Cancel" identity-command
                  :help "Cancel out of this menu"))
    menu))

(defset menu-bar-inkwell-menu
  (let ((menu (make-sparse-keymap "Inkw.el 𑑛")))
    (bindings--define-key menu [mi-pen-go-to-prompt-for-ink]
      '(menu-item "Go to prompt for ink" pen-go-to-prompt-for-ink
                  :help "When the cursor is on some ink, go to the prompt that generated it"))
    (bindings--define-key menu [mi-pen-go-to-engine-for-ink]
      '(menu-item "Go to engine for ink" pen-go-to-engine-for-ink
                  :help "When the cursor is on some ink, go to the engine that generated it"))
    (bindings--define-key menu [mi-ink-get-properties-here]
      '(menu-item "Get ink properties at cursor" ink-get-properties-here
                  :help "When the cursor is on some ink, display the ink source"))
    (bindings--define-key menu [cancel-menu]
      '(menu-item "Cancel" identity-command
                  :help "Cancel out of this menu"))
    menu))

(defset menu-bar-lookingglass-menu
  (let ((menu (make-sparse-keymap "🔍 LookingGlass")))
    (bindings--define-key menu [mi-lg-render]
      '(menu-item "Render" lg-render
                  :help "Render to HTML"))
    (bindings--define-key menu [mi-lg-search]
      '(menu-item "Search" lg-search
                  :help "Search selected passage for URLs"))
    (bindings--define-key menu [mi-lg-eww]
      '(menu-item "Go to URL" lg-eww
                  :help "Go to URL"))
    (bindings--define-key menu [mi-lg-fz-history]
      '(menu-item "URL History" lg-fz-history
                  :help "Look through history of URLs"))
    (bindings--define-key menu [cancel-menu]
      '(menu-item "Cancel" identity-command
                  :help "Cancel out of this menu"))
    menu))

(defset menu-bar-protocol-menu
  (let ((menu (make-sparse-keymap "࿋  Semiosis Protocol")))
    (bindings--define-key menu [mi-pen-connect-semiosis-protocol]
      '(menu-item "Connect to network" pen-connect-semiosis-protocol
                  :help "Connect Pen.el to the Semiosis Protocol"))
    (bindings--define-key menu [cancel-menu]
      '(menu-item "Cancel" identity-command
                  :help "Cancel out of this menu"))
    menu))

(defset menu-bar-pensieve-menu
  (let ((menu (make-sparse-keymap "PenSieve")))
    (bindings--define-key menu [mi-pensieve-mount-dir]
      '(menu-item "Mount a new pensieve" pensieve-mount-dir
                  :help "Given the name of the pensieve, mount it on the host and navigate to it"))
    (bindings--define-key menu [mi-pen-go-to-pensieves]
      '(menu-item "Go to pensieves" pen-go-to-pensieves
                  :help "Go to pensieves directory with dired"))
    (bindings--define-key menu [cancel-menu]
      '(menu-item "Cancel" identity-command
                  :help "Cancel out of this menu"))
    menu))

(defset menu-bar-melee-menu
  (let ((menu (make-sparse-keymap "🍓 Melee")))
    (bindings--define-key menu [mi-melee-start-immitation-game]
      '(menu-item "Immitation game" melee-start-immitation-game
                  :help "Start game of immitation"))
    (bindings--define-key menu [cancel-menu]
      '(menu-item "Cancel" identity-command
                  :help "Cancel out of this menu"))
    menu))

(if (pen-snq "inside-docker-p")
    (progn
      (bindings--define-key global-map [menu-bar file] nil)
      (bindings--define-key global-map [menu-bar edit] nil)
      (bindings--define-key global-map [menu-bar options] nil)
      ;; (bindings--define-key global-map [menu-bar buffers] nil)
      ;; (remove-hook 'menu-bar-update-hook 'menu-bar-update-buffers)
      (bindings--define-key global-map [menu-bar tools] nil)

      (bindings--define-key global-map [menu-bar pen]
        (cons "Pen" menu-bar-pen-menu))

      (bindings--define-key global-map [menu-bar daemons]
        (cons "Daemons" menu-bar-daemons-menu))

      (bindings--define-key global-map [menu-bar cterm]
        (cons "ct" menu-bar-cterm-menu))

      (bindings--define-key global-map [menu-bar melee]
        (cons "Melee" menu-bar-melee-menu))

      (bindings--define-key global-map [menu-bar channel]
        (cons "Chann" menu-bar-channel-menu))

      (bindings--define-key global-map [menu-bar ii]
        (cons "𝑖i" menu-bar-ii-menu))

      (bindings--define-key global-map [menu-bar apostrophe]
        (cons "Ink" menu-bar-inkwell-menu))

      (bindings--define-key global-map [menu-bar mtp]
        (cons "MTP" menu-bar-mtp-menu))

      (bindings--define-key global-map [menu-bar paracosm]
        (cons "Cosm" menu-bar-paracosm-menu))

      (bindings--define-key global-map [menu-bar esp]
        (cons "ESP" menu-bar-esp-menu))

      (bindings--define-key global-map [menu-bar prompts]
        (cons "Prompts" menu-bar-prompts-menu))

      (bindings--define-key global-map [menu-bar engines]
        (cons "Engines" menu-bar-engines-menu))

      (bindings--define-key global-map [menu-bar history]
        (cons "Hist" menu-bar-history-menu))

      (bindings--define-key global-map [menu-bar inkwell]
        (cons "Ink" menu-bar-inkwell-menu))

      (bindings--define-key global-map [menu-bar lookingglass]
        (cons "LG" menu-bar-lookingglass-menu))

      (bindings--define-key global-map [menu-bar pensieve]
        (cons "Sieve" menu-bar-pensieve-menu))

      (bindings--define-key global-map [menu-bar protocol]
        (cons "Protocol" menu-bar-protocol-menu))))

(defset tty-menu-navigation-map
  (let ((map (make-sparse-keymap)))
    ;; The next line is disabled because it breaks interpretation of
    ;; escape sequences, produced by TTY arrow keys, as tty-menu-*
    ;; commands.  Instead, we explicitly bind some keys to
    ;; tty-menu-exit.
    ;;(define-key map [t] 'tty-menu-exit)

    ;; The tty-menu-* are just symbols interpreted by term.c, they are
    ;; not real commands.
    (dolist (bind '((keyboard-quit . tty-menu-exit)
                    (keyboard-escape-quit . tty-menu-exit)
                    ;; The following two will need to be revised if we ever
                    ;; support a right-to-left menu bar.
                    (forward-char . tty-menu-next-menu)
                    (backward-char . tty-menu-prev-menu)
                    (right-char . tty-menu-next-menu)
                    (left-char . tty-menu-prev-menu)
                    (next-line . tty-menu-next-item)
                    (previous-line . tty-menu-prev-item)
                    (newline . tty-menu-select)
                    (newline-and-indent . tty-menu-select)
		                (menu-bar-open . tty-menu-exit)))
      (substitute-key-definition (car bind) (cdr bind)
                                 map (current-global-map)))

    ;; The bindings of menu-bar items are so that clicking on the menu
    ;; bar when a menu is already shown pops down that menu.
    (define-key map [menu-bar t] 'tty-menu-exit)

    (define-key map [?\C-r] 'tty-menu-select)
    (define-key map [?\C-j] 'tty-menu-select)
    (define-key map [return] 'tty-menu-select)
    (define-key map [linefeed] 'tty-menu-select)
    (menu-bar-define-mouse-key map 'mouse-1 'tty-menu-select)
    (menu-bar-define-mouse-key map 'drag-mouse-1 'tty-menu-select)
    (menu-bar-define-mouse-key map 'mouse-2 'tty-menu-select)
    (menu-bar-define-mouse-key map 'drag-mouse-2 'tty-menu-select)
    (menu-bar-define-mouse-key map 'mouse-3 'tty-menu-select)
    (menu-bar-define-mouse-key map 'drag-mouse-3 'tty-menu-select)
    (menu-bar-define-mouse-key map 'wheel-down 'tty-menu-next-item)
    (menu-bar-define-mouse-key map 'wheel-up 'tty-menu-prev-item)
    (menu-bar-define-mouse-key map 'wheel-left 'tty-menu-prev-menu)
    (menu-bar-define-mouse-key map 'wheel-right 'tty-menu-next-menu)
    ;; The following 6 bindings are for those whose text-mode mouse
    ;; lack the wheel.
    (menu-bar-define-mouse-key map 'S-mouse-1 'tty-menu-next-item)
    (menu-bar-define-mouse-key map 'S-drag-mouse-1 'tty-menu-next-item)
    (menu-bar-define-mouse-key map 'S-mouse-2 'tty-menu-prev-item)
    (menu-bar-define-mouse-key map 'S-drag-mouse-2 'tty-menu-prev-item)
    (menu-bar-define-mouse-key map 'S-mouse-3 'tty-menu-prev-item)
    (menu-bar-define-mouse-key map 'S-drag-mouse-3 'tty-menu-prev-item)
    ;; The down-mouse events must be bound to tty-menu-ignore, so that
    ;; only releasing the mouse button pops up the menu.
    (menu-bar-define-mouse-key map 'down-mouse-1 'tty-menu-ignore)
    ;; Don't change this until I can figure it out properly
    ;; For the moment, if in the terminal, drag across a menu item to select it
    ;; (menu-bar-define-mouse-key map 'down-mouse-1 'tty-menu-select)
    (menu-bar-define-mouse-key map 'down-mouse-2 'tty-menu-ignore)
    (menu-bar-define-mouse-key map 'down-mouse-3 'tty-menu-ignore)
    (menu-bar-define-mouse-key map 'C-down-mouse-1 'tty-menu-ignore)
    (menu-bar-define-mouse-key map 'C-down-mouse-2 'tty-menu-ignore)
    (menu-bar-define-mouse-key map 'C-down-mouse-3 'tty-menu-ignore)
    (menu-bar-define-mouse-key map 'mouse-movement 'tty-menu-mouse-movement)
    map))

(provide 'pen-menu-bar)