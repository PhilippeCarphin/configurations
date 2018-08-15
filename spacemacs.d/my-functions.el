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
(defun split-open ()
  (interactive)
  (split-window-below-and-focus)
  (helm-recentf))
(defun vsplit-open ()
  (interactive)
  (split-window-right-and-focus)
  (ido-dired))

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
  (let ((timestamp (format-time-string "%Y-%m-%d")))
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

(defun notes ()
  "Open helm-find-files in a the notes directory"
  (interactive)
  (helm-find-files-1 "~/Dropbox/Notes/Notes_BUCKET/"))
(defun wnotes ()
  "Open helm-find-files in a the notes directory"
  (interactive)
  (helm-find-files-1 "~/Dropbox/Notes/CMC/CMC_Notes/"))
(defun github ()
  "Open helm-find-files in a the notes directory"
  (interactive)
  (helm-find-files-1 "~/Documents/GitHub/"))
(defun philconfig ()
  "Open helm-find-files in a the notes directory"
  (interactive)
  (helm-find-files-1 "~/.philconfig"))
(defun workspace ()
  "Open helm-find-files in a the notes directory"
  (interactive)
  (helm-find-files-1 "~/workspace"))
(defun wmd ()
  "Open helm-find-files in a the notes directory"
  (interactive)
  (find-file "~/Dropbox/Notes/Notes_BUCKET/wmd.org"))
(defun wmdw ()
  "Open helm-find-files in a the notes directory"
  (interactive)
  (find-file "~/Dropbox/Notes/CMC/CMC_Notes/wmd.org"))
;; I have no idea what I'm doing.
;; (defmacro make-quick-open-function (name directory)
;;   (lambda (name directory) (defun name ()
;;     (interactive)
;;     helm-find-files directory)))
;;
;; (make-quick-open-function 'github "~/Documents/GitHub")
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
  (surround-strings start end
                    (concat "#+BEGIN_SRC " lang "\n")
                    "#+END_SRC\n"))
(defun org-make-code-block-command (lang start end)
  (interactive (list (read-string "Enter a language (default C): " "" nil "c") (region-beginning) (region-end)))
  (org-make-code-block lang start end))
(defun org-set-make-code-block-key ()
  (define-key evil-visual-state-map (kbd "C-o") 'org-make-code-block-command))

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
  (add-hook 'org-mode-hook (lambda ()
                             (setq-local evil-shift-width 4)
                             (setq-local tab-width 4)
                             (setq-local org-indent-indentation-per-level 4)))
  (advise-org-global-cycle)
  (add-hook 'org-mode-hook 'org-set-make-code-block-key)
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
  )

;; TODO Try to make this work
;; (defun org-find-header (header)
;;   (interactive (list (read-string "Enter a header : " "" nil "c")))
;;   (evil-search (concat "\\\\*+ " header)))
