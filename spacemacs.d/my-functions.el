(defun say-hello ()
  "Example of an interactive function"
  (interactive)
  (message "Hello World"))

;; ref : https://www.emacswiki.org/emacs/KillingBuffers#toc2
(setq not-to-kill-buffer-list '("*scratch*" "#emacs" "*Messages*" "irc.freenode.net:6667"))
(defun maybe-kill-buffer (buffer)
  (when (not (member buffer not-to-kill-buffer-list))
    (kill-buffer buffer)))
(defun maybe-kill-all-buffers ()
  (interactive)
  (mapc 'maybe-kill-buffer (delq (current-buffer) (buffer-list))))

(setq-default phil-window-resize-step-size 4)
(defun set-window-resize-keys ()
  "Sets hotkeys to resize windows like in tmux"
  (define-key evil-normal-state-map (kbd "C-w C-j")
    (lambda () (interactive) (evil-window-increase-height phil-window-resize-step-size)))
  (define-key evil-normal-state-map (kbd "C-w C-l")
    (lambda () (interactive) (evil-window-increase-width phil-window-resize-step-size)))
  (define-key evil-normal-state-map (kbd "C-w C-h")
    (lambda () (interactive) (evil-window-decrease-width phil-window-resize-step-size)))
  (define-key evil-normal-state-map (kbd "C-w C-k")
    (lambda () (interactive) (evil-window-decrease-height phil-window-resize-step-size)))
  )

;; TODO tailor these to be more useful
;; Could have 'C-a /' do a projectile-dired
;; But 'C-w /' could do something else
(defun split-find ()
  (interactive)
  (split-window-below-and-focus)
  (helm-find-files-1 "."))
(defun split-buffers ()
  (interactive)
  (split-window-below-and-focus)
  (helm-buffers-list))
(defun vsplit-find ()
  (interactive)
  (split-window-right-and-focus)
  (helm-find-files-1 "."))
(defun vsplit-buffers ()
  (interactive)
  (split-window-right-and-focus)
  (helm-buffers-list))
(defun set-split-open-keys ()
  (define-key evil-normal-state-map (kbd "SPC b -") 'split-buffers)
  (define-key evil-normal-state-map (kbd "SPC b /") 'vsplit-buffers)
  (define-key evil-normal-state-map (kbd "SPC f -") 'split-find)
  (define-key evil-normal-state-map (kbd "SPC f /") 'vsplit-find)
  )

(defun custom-prefix-example ()
  "An example of defining a prefix"
  (define-prefix-command 'my-custom-prefix)
  (define-key my-custom-prefix (kbd "s") 'say-hello)
  (define-key evil-insert-state-map (kbd "C-o") my-custom-prefix))

(defun bind-insert-mode-window-change-keys ()
  "This allows for changing windows without having to get out of insert mode
  which is the same behavior one would get in a TMUX-vim setupk.
  It has the added bonus that C-w doesn't erase words in insert mode.
  It also has the advantage of leaving your buffer in whatever mode it's in.
  This is super useful for shells where you pretty much always want to be in
  insert mode."
  (global-set-key (kbd "C-a") evil-window-map)
  (define-key evil-insert-state-map (kbd "C-w") evil-window-map)
  (define-key evil-insert-state-map (kbd "C-w /") 'split-window-right)
  (define-key evil-insert-state-map (kbd "C-w -") 'split-window-below)

  (define-key evil-insert-state-map (kbd "C-a") evil-window-map)
  (define-key evil-normal-state-map (kbd "C-a") evil-window-map)
  (define-key evil-insert-state-map (kbd "C-a /") 'split-window-right)
  (define-key evil-insert-state-map (kbd "C-a -") 'split-window-below)
  (define-key evil-normal-state-map (kbd "C-a /") 'split-window-right)
  (define-key evil-normal-state-map (kbd "C-a -") 'split-window-below)
  )

(defun insert-date ()
  (interactive)
  (let ((timestamp (format-time-string "[%Y-%m-%d %H:%M]")))
    (insert timestamp)))

(defun new-note (name)
  "Create a new org-mode notes file in standard location"
  (interactive
   (let ((timestamp (format-time-string "%Y-%m-%d")))
     (list (read-string (concat "New note name : (default " timestamp ") ") "" nil timestamp))))
  (switch-to-buffer (concat "~/Dropbox/Notes/Notes_BUCKET/Notes_" name ".org"))
  (set-visited-file-name (concat "~/Dropbox/Notes/Notes_BUCKET/Notes_" name ".org"))
  (org-mode)
  (evil-insert-state)
  (yas-insert-snippet "nn"))
(defun new-mail (name)
  "Create a new org-mode notes file in standard location"
  (interactive
   (let ((timestamp (format-time-string "%Y-%m-%d")))
     (list (read-string (concat "New note name : (default " timestamp ") ") "" nil timestamp))))
  (switch-to-buffer (concat "~/Dropbox/Notes/Email/email_" name ".org"))
  (set-visited-file-name (concat "~/Dropbox/Notes/Email/email_" name ".org"))
  (org-mode)
  (evil-insert-state)
  (yas-insert-snippet "nn"))

(defmacro make-goto-function (name directory)
  `(defun ,(intern name) ()
     (interactive)
     (helm-find-files-1 ,directory)))
(make-goto-function "notes" "~/Dropbox/Notes/Notes_BUCKET/")
(make-goto-function "wnotes" "~/Dropbox/Notes/CMC/Notes_BUCKET/")
(make-goto-function "github" "~/Documents/GitHub/")
(make-goto-function "dropbox" "~/Dropbox")
(make-goto-function "poly" "~/Dropbox/PolyMtl_AUT2018/")
(make-goto-function "philconfig" "~/.philconfig/")
(make-goto-function "workspace" "~/workspace/")
(defmacro make-open-function (name file)
  `(defun ,(intern name) ()
     (interactive)
     (find-file ,file)))
(make-open-function "wmd" "~/Dropbox/Notes/Notes_BUCKET/wmd.org")
(make-open-function "wmdw" "~/Dropbox/Notes/CMC/Notes_BUCKET/wmd.org")
(make-open-function "mnotes" "~/Dropbox/PartageAvecPhil/Notes_Phil.org")

(defun put-header ()
  (interactive)
  ;; Could have some better code to find the text in the line.
  (move-beginning-of-line 1)
  (when (equal (thing-at-point 'word) "static") (forward-word))
  (forward-word)
  (forward-char)
  (when (equal (thing-at-point 'char) "*") (forward-char))
  (evil-yank-characters (point) (line-end-position))
  (move-beginning-of-line 1)
  (let ((w "static"))
    (while (or (equal w "static") (equal w "int") (equal w "void"))
      (previous-line)
      (setq w (thing-at-point 'word))))
  (move-end-of-line 1)
  (insert "\n")
  (yas-insert-snippet)
  (evil-insert-state))

(defun surround-strings (start end start-string end-string)
  (save-excursion (goto-char end)
                  (insert end-string)
                  (goto-char start)
                  (insert start-string)))
(defun org-make-code-block (lang start end)
  (surround-strings start
                    end
                    (concat "#+BEGIN_SRC " lang "\n")
                    "#+END_SRC\n"))
(defun org-make-code-block-command (lang start end)
  (interactive (list (read-string "Enter a language (default C): " "" nil "c")
                     (region-beginning)
                     (region-end)))
  (org-make-code-block lang start end))
(defun paste-between-strings (start-string end-string)
  (save-excursion
    (insert (concat start-string
                    (car kill-ring)
                    end-string))))
(defun org-paste-code-block-command(lang)
  (interactive (list (read-string "Enter a language (default C): " "" nil "c")))
  (paste-between-strings (concat "#+BEGIN_SRC " lang "\n") "#+END_SRC\n")
  )
(defun org-set-make-code-block-key ()
  (define-key evil-visual-state-map (kbd "C-o") 'org-make-code-block-command)
  ;; (define-key evil-normal-state-map (kbd "C-o") 'org-paste-code-block-command)
  )

;; Stuff relating to org-publish
(defun setup-org-publish ()
  (require 'ox-man)
  (require 'ox-md)
  (require 'ox-publish)
  (setq-default markdown-open-command "chromium-browser")
  (setq org-publish-project-alist
        '(("org-notes"
           :base-directory "~/Dropbox/Notes/Notes_BUCKET/"
           :base-extension "org"
           :publishing-directory "~/Documents/Notes/published"
           :recursive t
           ;; :publishing-function org-html-publish-to-html
           :publishing-function org-twbs-publish-to-html
           :headline-levels 4
           :auto-preamble t)
          ("org-static"
           :base-directory "~/Documents/Notes/Notes_BUCKET"
           :base-extension "css\\/js\\/jpg"
           :publishing-directory "~/Documents/Notes/published"
           :recursive t
           :publishing-function org-publish-attachment)
          ("org"
           :components ("org-notes" "org-static")))
        )
  ;; Use pipes for subprocess communication
  ;; This is because withoug this, in org-mode 'C-c C-e h' did not open
  ;; the exported file.  With this it does.
  ;; REF: https://askubuntu.com/questions/646631/emacs-doesnot-work-with-xdg-open
  ;; Note: People in the reference say that this breaks using gnuplot with org-mode.
  ;; See comments on the answer that gives this line.
  (setq process-connection-type nil)
  )
(defun advise-org-global-cycle ()
  (advice-add 'org-global-cycle :after #'evil-scroll-line-to-center))
(defun configure-org-mode ()
  (setq org-directory "~/Dropbox/Notes/"
        org-mobile-files '("~/Dropbox/Notes/CMC"
                           "~/Dropbox/Notes/Email"
                           "~/Dropbox/Notes/Notes_BUCKET"
                           "~/Dropbox/Notes/gtd")
        org-mobile-inbox-for-pull "~/Dropbox/Notes/Notes_BUCKET/org-mobile-inbox.org"
        org-mobile-directory "~/Dropbox/Apps/MobileOrg/")
  (setq org-insert-heading-respect-content t)
  (setq org-M-RET-may-split-line nil)
  (define-key evil-normal-state-map (kbd "SPC n n") 'new-note)
  (define-key evil-normal-state-map (kbd "C-c n") 'new-note)
  (add-hook 'org-mode-hook (lambda ()
                             (setq-local evil-shift-width 4)
                             (setq-local tab-width 4)
                             (setq-local org-indent-indentation-per-level 4)))
  (advise-org-global-cycle)
  (add-hook 'org-mode-hook 'org-set-make-code-block-key)
  (setq org-default-notes-file "~/Dropbox/Notes/gtd/GTD_InTray.org")
  )

(defun c-mode-set-comment-indent-style ()
  ;; ref : https://www.emacswiki.org/emacs/AutoFillMode
  (auto-fill-mode 1)
  (set (make-local-variable 'fill-nobreak-predicate)
       (lambda ()
         (not (eq (get-text-property (point) 'face)
                  'font-lock-comment-face)))))

(defun configure-c-mode ()
  ;; See : http://blog.binchen.org/posts/easy-indentation-setup-in-emacs-for-web-development.html
  (add-hook 'c-mode-common-hook 'c-mode-set-comment-indent-style)
  ;; (setq-default comment-auto-fill-only-comments t)
  (add-hook 'c-mode-hook (lambda () (c-set-style "linux"))))

(defun configure-evil-escape-sequence ()
  ;; Typing 'jk' fast will exit inser-mode
  (setq-default evil-escape-key-sequence "jk")
  (setq-default evil-escape-delay 0.3)
  ;; Disable for some states and modes
  (push 'visual evil-escape-excluded-states)
  (push 'magit-status-mode evil-escape-excluded-major-modes)
  (push 'magit-diff-mode evil-escape-excluded-major-modes)
  (push 'grep-mode evil-escape-excluded-major-modes)
  (push 'neotree-mode evil-escape-excluded-major-modes)
  )

;; TODO Try to make this work
;; (defun org-find-header (header)
;;   (interactive (list (read-string "Enter a header : " "" nil "c")))
;;   (evil-search (concat "\\\\*+ " header)))

(defun configure-gtd ()
  (setq gtd-directory
        (cond ((member (user-real-login-name) '("afsmpca")) "~/Dropbox/Notes/CMC/gtd/")
              ((member (user-real-login-name) '("pcarphin" "phcarb")) "~/Dropbox/Notes/gtd/")))

  (setq gtd-in-tray-file (concat gtd-directory "GTD_InTray.org")
        gtd-next-actions-file (concat gtd-directory "GTD_NextActions.org")
        gtd-project-list-file (concat gtd-directory "GTD_ProjectList.org")
        gtd-reference-file (concat gtd-directory "GTD_Reference.org")
        gtd-someday-maybe-file (concat gtd-directory "GTD_SomedayMaybe.org")
        gtd-tickler-file (concat gtd-directory "GTD_Tickler.org")
        gtd-journal-file (concat gtd-directory "GTD_Journal.org"))

  (setq org-agenda-custom-commands '(("p" "At Poly" tags-todo "at_poly"
                                      ((org-agenda-overriding-header "At Poly")))
                                     ("h" "At House" tags-todo "at_house"
                                      ((org-agenda-overriding-header "At House")))
                                     ("o" "Out and about" tags-todo "at_out"
                                      ((org-agenda-overriding-header "Out and about actions")))
                                     )
        org-agenda-files '("~/Dropbox/Notes/gtd/")
        org-capture-templates '(("i" "GTD Input" entry (file+headline gtd-in-tray-file "GTD Input Tray") "* GTD-IN %?\n %i\n %a" :kill-buffer t)
                                ("a" "Action" entry (file+headline gtd-next-actions-file "Next Actions") "* GTD-ACTION %?\n Created on %U\n" :kill-buffer t)
                                ("p" "Project" entry (file+headline gtd-project-list-file "Current Projects") "* GTD-PROJECT %?\n Created on %U\n" :kill-buffer t)
                                ("r" "Reference" entry (file+headline gtd-reference-file "New") "* GTD-PROJECT %?\n Created on %U\n" :kill-buffer t)
                                ("s" "Someday Maybe" entry (file+headline gtd-someday-maybe-file "Someday Maybe") "* GTD-SOMEDAY_MAYBE %?\n Created on %U\n" :kill-buffer t)
                                ("j" "Journal" entry (file+olp+datetree gtd-journal-file ) "* %?\nEntered on %U\n  %i\n  %a" :kill-buffer t))
                                ;; Note that you can make the datetree be filed  under another heading
                                ;;("j" "Journal" entry (file+olp+datetree gtd-journal-file "A LEVEL 1 HEADING" "A LEVEL 2 HEADING" ...) ... ))
        ;; TODO This should add the GTD keywords to org-todo-keywords rather than setting it.
        org-todo-keywords '((sequence "TODO" "WAITING" "VERIFY" "|" "DONE")
                            (sequence "GTD-IN(i)" "GTD-CLARIFY(c)" "GTD-PROJECT(p)"
                                      "GTD-SOMEDAY-MAYBE(s)" "GTD-ACTION(a)" "GTD-NEXT-ACTION(n)"
                                      "GTD-WAITING(w)" "|" "GTD-REFERENCE(r)" "GTD-DELEGATED(g)" "GTD-DONE(d)"))

        org-enforce-todo-checkbox-dependencies t
        org-enforce-todo-dependencies t
        org-log-done 'note)

  (define-prefix-command 'gtd)
  (defun gtd-open-in-tray () (interactive) (find-file gtd-in-tray-file))
  (defun gtd-open-next-actions () (interactive) (find-file gtd-next-actions-file))
  (defun gtd-open-projects-list () (interactive) (find-file gtd-project-list-file))
  (defun gtd-open-references () (interactive) (find-file gtd-reference-file))
  (defun gtd-open-someday-maybe () (interactive) (find-file gtd-someday-maybe-file))
  (defun gtd-open-tickler () (interactive) (find-file gtd-tickler-file))
  (defun gtd-open-journal () (interactive) (find-file gtd-journal-file))
  (defun gtd-dashboard () (interactive) (persp-load-state-from-file "gtd"))
  (define-key gtd (kbd "d") 'gtd-dashboard)
  (define-key gtd (kbd "i") 'gtd-open-in-tray)
  (define-key gtd (kbd "p") 'gtd-open-projects-list)
  (define-key gtd (kbd "s") 'gtd-open-someday-maybe)
  (define-key gtd (kbd "a") 'gtd-open-next-actions)
  (define-key gtd (kbd "r") 'gtd-open-references)
  (define-key gtd (kbd "t") 'gtd-open-tickler)
  (define-key gtd (kbd "j") 'gtd-open-journal)
  (define-key evil-normal-state-map (kbd "SPC a g") 'gtd)
  )
