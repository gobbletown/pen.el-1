;; (require 'vuiet)

;; Need functions for listing music file types
(defvar music-extensions '(mp4 m4a webm mkv mp3))

(defun everynoise ()
  (interactive)
  (eww "https://everynoise.com/"))
(defalias 'random-music 'everynoise)

;; (syms2str music-extensions)
;; (list2str music-extensions)

(defun pen-kill-music ()
  (interactive)
  (ignore-errors (vuiet-stop))
  (pen-sn "pen-kill-music")
  (pen-sn "killall vlc"))

(cl-defun pen-play-video-path (fp &optional window-function external-cmd &key loop)
  (pen-kill-music)
  (if (not window-function)
      (setq window-function 'sps))
  (if (not (sor external-cmd))
      (setq external-cmd "play-video"))
  (if loop
      (setq external-cmd (pen-cmd "repeat.sh" external-cmd)))
  (shut-up
    (let ((use-tty-str (if use-tty "export USETTY=y; " "")))
      (eval `(,window-function (concat use-tty-str external-cmd " " (pen-q fp)) "-d")))))

(cl-defun pen-play-youtube-url (url &optional window-function &key loop)
  (pen-play-video-path url window-function "yt -v" :loop loop))

(cl-defun pen-play-movie (path &optional term-and-transcript use-tty &key loop)
  (setq path (pen-umn path))
  (pen-kill-music)
  (let ((use-tty-str (if use-tty "export USETTY=y; " ""))
        (play-function (if (string-match "\\bhttp" path)
                           'pen-play-youtube-url
                         'pen-play-video-path)))
    (if term-and-transcript
        (progn
          (eval `(,play-function path 'spv :loop ,loop))
          (sleep-for-for-for-for-for-for-for-for 0.1)
          (pen-sph (concat "readsubs " (pen-q path)) "-d"))
      (eval `(,play-function path))))
  nil)
(cl-defun pm (path &optional term-and-transcript &key loop)
  (pen-play-movie path term-and-transcript t :loop t))
(defalias 'play-video 'pen-play-movie)

(defun play-movie-with-transcript (path)
  (interactive (list (read-string-hist "youtube url: ")))
  (pen-play-movie path t))
(defalias 'pmt 'play-movie-with-transcript)

(defun pen-play-song (path &optional loop)
  (setq path (pen-umn path))

  (if loop
      (shut-up (eval `(pen-sn (cmd "pen-play-song" "-l" ,path)
                              nil nil nil t)))
    (shut-up (eval `(pen-sn (cmd "pen-play-song" ,path)
                            nil nil nil t))))
  nil)
(defalias 'ps 'pen-play-song)

(defun pen-play-playlist (path)
  (shut-up (eval ` (pen-snc (cmd "play-yt-playlist" ,path)
                            nil nil nil t)))
  nil)

(defun pen-get-yt-playlist (path)
  (interactive (list (read-string "path:")))

  (if (string-empty-p path) (setq path "[[https://www.youtube.com/playlist?list=PLGYGe2PKknX2kydiv28aq8dBXBWeJfxgg][The Lion King 2019 soundtrack - YouTube]]"))

  (let ((result (chomp (pen-sn (concat "pen-ci yt-list-playlist-urls " (pen-q path))))))
    (if (called-interactively-p 'any)
        (new-buffer-from-string result)
      result)))

(defun get-yt-playlist-json (path)
  (interactive (list (read-string "path:")))

  (if (string-empty-p path) (setq path "[[https://www.youtube.com/playlist?list=PLGYGe2PKknX2kydiv28aq8dBXBWeJfxgg][The Lion King 2019 soundtrack - YouTube]]"))

  (let ((result (chomp (pen-sn (concat "pen-ci yt-playlist-json " (pen-q path))))))
    (if (called-interactively-p 'any)
        (new-buffer-from-string result)
      result)))

(defun pen-org-clink-urls (ms)
  (interactive)

  (pen-sn "oc" ms))

(defalias 'oc 'pen-org-clink-urls)

(defun swordfish-ost ()
  (interactive)
  (pen-play-playlist "[[https://www.youtube.com/playlist?list=OLAK5uy_mPdRDb_IJmG3DDeOlSwI5_rKKtAEZogys][Swordfish The Album (Original Motion Picture Soundtrack) - YouTube]]"))

(defun clubbed-to-death ()
  (interactive)
  (pen-play-playlist "[[https://www.youtube.com/watch?v=pFS4zYWxzNA][clubbed to death - Matrix soundtrack - YouTube]]"))

(defun furious-angels ()
  (interactive)
  ;; (bld pen-play-song "$DUMP$NOTES/ws/music/furious-angels/Rob Dougan - Furious Angels-jtAmFKaThNE.m4a")
  (bld pen-play-song "[[https://www.youtube.com/watch?v=PJ8vJ2Qjuuc][Furious Angels - Rob Dougan - YouTube]]"))

(defun pen-ytsearch (query)
  (if (string-match-p "\\bhttps?:" query)
      (setq query (chomp (sh/xurls query)))
    (pen-cl-sn (concat "yt-search " (pen-q query)) :chomp t)))

(defun pen-search-play-yt (query-or-url &optional audioonly)
  (interactive (list (read-string-hist "yt play-song: " (my/selected-text))))

  (pen-kill-music)
  (if (string-match-p "\\bhttps?:" query-or-url)
      (setq query-or-url (chomp (sh/xurls query-or-url)))
    (setq query-or-url (pen-ytsearch query-or-url)))

  (if audioonly
      (shut-up (pen-cl-sn (concat "pen-play-song " (pen-q query-or-url)) :detach t :chomp t))
    (pen-sps (concat "yt -tty -v " (pen-q query-or-url)) "-d")))

(defalias 'yt 'pen-search-play-yt)

(defun yta (query-or-url)
  (interactive (list (read-string-hist "yt play-song: ")))

  (yt query-or-url t))
(defalias 'ya 'yta)

(defun search-play-yt-transcript (query-or-url &optional lang)
  (interactive (list (read-string-hist "youtube query-or-url: " (my/selected-text))))

  (pen-kill-music)
  (if (string-match-p "\\bhttps?:" query-or-url)
      (setq query-or-url (chomp (sh/xurls query-or-url)))
    (setq query-or-url (pen-ytsearch query-or-url)))

  (if (not lang)
      (setq lang "en"))

  (pen-spv (concat "yt -tty -v " (pen-q query-or-url)) "-d")
  (sleep-for-for-for-for-for-for-for-for 0.1)
  (rst query-or-url))

(defalias 'ytt 'search-play-yt-transcript)

(defun ytt-fr (query)
  (interactive (list (read-string-hist "youtube query: ")))
  (ytt query "fr"))

(defun ytt-it (query)
  (interactive (list (read-string-hist "youtube query: ")))
  (ytt query "it"))

(defun readsubs (url &optional do-etv)
  (interactive (list (read-string-hist "yt query: ")))

  (if (string-match "^\\[\\[http" url)
      (setq url (chomp (pen-snc "xurls" url))))

  (if (and (not (string-match "^http" url))
           (sor url))
      (setq url (pen-ytsearch url)))

  (setq do-etv
        (or
         do-etv
         (interactive-p)))

  (let ((transcript (pen-cl-sn (concat "unbuffer pen-ci readsubs " (pen-q url) " | cat") :chomp t)))
    (if do-etv
        (tvs transcript)
      transcript)))
(defalias 'rs 'readsubs)

(defun rst (url)
  (interactive (list (read-string-hist "yt query: ")))
  (tvs (readsubs url)))

(defun readsubs-fr (url)
  (interactive (read-string-hist "yt query: "))
  (pen-cl-sn (concat "unbuffer pen-ci readsubs.bak -l fr " (pen-q url) " | cat") :chomp t))

(defun mus-epic ()
  (interactive)
  "Search for epic music and play it."
  (pen-search-play-yt "epic music"))

(defun elements-of-life ()
  (interactive)
  (pen-play-song "[[https://www.youtube.com/watch?v=V9HKtPVms_Y][Tiesto elements of Life - YouTube]]"))

(defun prince-of-egypt-reprise ()
  (interactive)
  (pen-play-song "https://www.youtube.com/watch?v=E1rEmAQJ7EQ&t=415"))

(defun neverending-story ()
  (interactive)
  (bld pen-play-song "[[https://www.youtube.com/watch?v=heHdOTt_iGc&t][The Neverending Story (1984)  Soundtrack  - YouTube]]"))

(defun dark-knight-end-credits ()
  (interactive)
  (bld pen-play-song "[[https://www.youtube.com/watch?v=fTr89ENLZPc][The Dark Knight - End Credits Music (HQ) - YouTube]]"))

(defun dark-knight-theme ()
  (interactive)
  (bld pen-play-song "[[https://www.youtube.com/watch?v=w1B3Mgklfd0][Batman The Dark Knight Theme - Hans Zimmer - YouTube]]"))

(defun dark-knight-watchful-guardian ()
  "5 / 5"
  (interactive)
  (bld pen-play-song "[[https://www.youtube.com/watch?v=buejiFXN7Hw][Hans Zimmer - A Watchful Guardian The Dark Knight - YouTube]]"))

(defun william-tell-overture ()
  (interactive)
  (bld pen-play-song "[[https://www.youtube.com/watch?v=xoBE69wdSkQ][ROSSINI: William Tell Overture (full version) - YouTube]]"))
(defalias 'wto 'william-tell-overture)

(defun real-estate-its-real ()
  (interactive)
  (pen-play-song "[[https://youtu.be/4HWcViTXdYc][Real Estate - Its Real (Official Video) - YouTube]]"))

(defun pen-media-test ()
  (interactive)
  (pm "[[https://www.youtube.com/watch?v=ZqZdfxc-fq0][Simpsons - Planet of the Apes, the musical - YouTube]]"))