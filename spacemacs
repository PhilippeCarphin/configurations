;; -*- mode: emacs-lisp -*-
;; This file is loaded by Spacemacs at startup.
;; It must be stored in your home directory.


(defun dotspacemacs/layers ()
  "Configuration Layers declaration.
You should not put any user code in this function besides modifying the variable
values."
  (setq-default
   ;; Base distribution to use. This is a layer contained in the directory
   ;; `+distribution'. For now available distributions are `spacemacs-base'
   ;; or `spacemacs'. (default 'spacemacs)
   dotspacemacs-distribution 'spacemacs
   ;; Lazy installation of layers (i.e. layers are installed only when a file
   ;; with a supported type is opened). Possible values are `all', `unused'
   ;; and `nil'. `unused' will lazy install only unused layers (i.e. layers
   ;; not listed in variable `dotspacemacs-configuration-layers'), `all' will
   ;; lazy install any layer that support lazy installation even the layers
   ;; listed in `dotspacemacs-configuration-layers'. `nil' disable the lazy
   ;; installation feature and you have to explicitly list a layer in the
   ;; variable `dotspacemacs-configuration-layers' to install it.
   ;; (default 'unused)
   dotspacemacs-enable-lazy-installation 'unused
   ;; If non-nil then Spacemacs will ask for confirmation before installing
   ;; a layer lazily. (default t)
   dotspacemacs-ask-for-lazy-installation t
   ;; If non-nil layers with lazy install support are lazy installed.
   ;; List of additional paths where to look for configuration layers.
   ;; Paths must have a trailing slash (i.e. `~/.mycontribs/')
   dotspacemacs-configuration-layer-path '()
   ;; List of configuration layers to load.
   dotspacemacs-configuration-layers
   '(
     markdown
     twitter
     gtags
     go
     vimscript
     javascript
     (org :variables
          org-agenda-files '("~/Dropbox/Notes/Notes_BUCKET/")
          org-directory "~/Dropbox/Notes/Notes_BUCKET/"
          org-mobile-inbox-for-pull "~/Dropbox/Notes/Notes_BUCKET/org-mobile-inbox.org"
          org-mobile-directory "~/Dropbox/Apps/MobileOrg/"
          )
     osx
     html
     (colors :variables
             colors-colorize-identifiers 'variables
             colors-enable-nyan-cat-progress-bar (display-graphic-p)
             )
     ;; I don't know if it was pip-installing flake8 or adding this variable
     ;; that gave me python syntax checking TODO : Find out
     (python :variables
             python-test-runner 'pytest)
     erc ;; IRC layer
     ;; (ycmd :variables ycmd-server-command '("python" "/users/pcarphin/.local/share/ycmd/"))
     (auto-completion :variables
                   auto-completion-return-key-behavior 'nil
                   auto-completion-tab-key-behavior 'complete
                   auto-completion-complete-with-key-sequence "fd"
                   auto-completion-complete-with-key-sequence-delay 0.3
                   auto-completion-enable-snippets-in-popup t
                   auto-completion-private-snippets-directory nil
                   )
     (c-c++ :variables
            c-c++-enable-clang-support t
            c-comment-continuation-stars t
            )
     ;; It is necessary to install wakatime using pip
     ;; pip install wakatime
     (wakatime :variables
               wakatime-api-key "806875af-9b0b-47b0-bcdc-f940ce434c86"
               wakatime-cli-path "~/.local/bin/wakatime"
               )
     ;; ----------------------------------------------------------------
     ;; Example of useful layers you may want to use right away.
     ;; Uncomment some layer names and press <SPC f e R> (Vim style) or
     ;; <M-m f e R> (Emacs style) to install them.
     ;; ----------------------------------------------------------------
     helm
     better-defaults
     emacs-lisp
     git
     markdown
     (shell :variables
            shell-default-height 10
            shell-default-position 'bottom)
     (spell-checking :variables
                     spell-checking-enable-auto-dictionary t
                     spell-checking-enable-by-default nil
                     enable-flyspell-auto-completion t)
     syntax-checking
     version-control
     )
   ;; List of additional packages that will be installed without being
   ;; wrapped in a layer. If you need some configuration for these
   ;; packages, then consider creating a layer. You can also put the
   ;; configuration in `dotspacemacs/user-config'.
   dotspacemacs-additional-packages '(ox-twbs ergoemacs-mode cmake-ide)
   ;; A list of packages that cannot be updated.
   dotspacemacs-frozen-packages '()
   ;; A list of packages that will not be installed and loaded.
   dotspacemacs-excluded-packages '()
   ;; Defines the behaviour of Spacemacs when installing packages.
   ;; Possible values are `used-only', `used-but-keep-unused' and `all'.
   ;; `used-only' installs only explicitly used packages and uninstall any
   ;; unused packages as well as their unused dependencies.
   ;; `used-but-keep-unused' installs only the used packages but won't uninstall
   ;; them if they become unused. `all' installs *all* packages supported by
   ;; Spacemacs and never uninstall them. (default is `used-only')
   dotspacemacs-install-packages 'used-only))

(defun dotspacemacs/init ()
  "Initialization function.
This function is called at the very startup of Spacemacs initialization
before layers configuration.
You should not put any user code in there besides modifying the variable
values."
  ;; This setq-default sexp is an exhaustive list of all the supported
  ;; spacemacs settings.
  (setq-default
   ;; If non nil ELPA repositories are contacted via HTTPS whenever it's
   ;; possible. Set it to nil if you have no way to use HTTPS in your
   ;; environment, otherwise it is strongly recommended to let it set to t.
   ;; This variable has no effect if Emacs is launched with the parameter
   ;; `--insecure' which forces the value of this variable to nil.
   ;; (default t)
   dotspacemacs-elpa-https t
   ;; Maximum allowed time in seconds to contact an ELPA repository.
   dotspacemacs-elpa-timeout 5
   ;; If non nil then spacemacs will check for updates at startup
   ;; when the current branch is not `develop'. Note that checking for
   ;; new versions works via git commands, thus it calls GitHub services
   ;; whenever you start Emacs. (default nil)
   dotspacemacs-check-for-update nil
   ;; If non-nil, a form that evaluates to a package directory. For example, to
   ;; use different package directories for different Emacs versions, set this
   ;; to `emacs-version'.
   dotspacemacs-elpa-subdirectory nil
   ;; One of `vim', `emacs' or `hybrid'.
   ;; `hybrid' is like `vim' except that `insert state' is replaced by the
   ;; `hybrid state' with `emacs' key bindings. The value can also be a list
   ;; with `:variables' keyword (similar to layers). Check the editing styles
   ;; section of the documentation for details on available variables.
   ;; (default 'vim)
   dotspacemacs-editing-style 'vim
   ;; If non nil output loading progress in `*Messages*' buffer. (default nil)
   dotspacemacs-verbose-loading nil
   ;; Specify the startup banner. Default value is `official', it displays
   ;; the official spacemacs logo. An integer value is the index of text
   ;; banner, `random' chooses a random text banner in `core/banners'
   ;; directory. A string value must be a path to an image format supported
   ;; by your Emacs build.
   ;; If the value is nil then no banner is displayed. (default 'official)
   dotspacemacs-startup-banner 'official
   ;; List of items to show in startup buffer or an association list of
   ;; the form `(list-type . list-size)`. If nil then it is disabled.
   ;; Possible values for list-type are:
   ;; `recents' `bookmarks' `projects' `agenda' `todos'."
   ;; List sizes may be nil, in which case
   ;; `spacemacs-buffer-startup-lists-length' takes effect.
   dotspacemacs-startup-lists '((recents . 5)
                                (projects . 7))
   ;; True if the home buffer should respond to resize events.
   dotspacemacs-startup-buffer-responsive t
   ;; Default major mode of the scratch buffer (default `text-mode')
   dotspacemacs-scratch-mode 'text-mode
   ;; List of themes, the first of the list is loaded when spacemacs starts.
   ;; Press <SPC> T n to cycle to the next theme in the list (works great
   ;; with 2 themes variants, one dark and one light)
   dotspacemacs-themes '(spacemacs-dark
                         spacemacs-light)
   ;; If non nil the cursor color matches the state color in GUI Emacs.
   dotspacemacs-colorize-cursor-according-to-state t
   ;; Default font, or prioritized list of fonts. `powerline-scale' allows to
   ;; quickly tweak the mode-line size to make separators look not too crappy.
   dotspacemacs-default-font '("Menlo"
                               ;; Note: the size will not take effect if the
                               ;; font is not found
                               :size 18.0
                               :weight normal
                               :width normal
                               :powerline-scale 1.1)
   ;; The leader key
   dotspacemacs-leader-key "SPC"
   ;; The key used for Emacs commands (M-x) (after pressing on the leader key).
   ;; (default "SPC")
   dotspacemacs-emacs-command-key "SPC"
   ;; The key used for Vim Ex commands (default ":")
   dotspacemacs-ex-command-key ":"
   ;; The leader key accessible in `emacs state' and `insert state'
   ;; (default "M-m")
   dotspacemacs-emacs-leader-key "M-m"
   ;; Major mode leader key is a shortcut key which is the equivalent of
   ;; pressing `<leader> m`. Set it to `nil` to disable it. (default ",")
   dotspacemacs-major-mode-leader-key ","
   ;; Major mode leader key accessible in `emacs state' and `insert state'.
   ;; (default "C-M-m")
   dotspacemacs-major-mode-emacs-leader-key "C-M-m"
   ;; These variables control whether separate commands are bound in the GUI to
   ;; the key pairs C-i, TAB and C-m, RET.
   ;; Setting it to a non-nil value, allows for separate commands under <C-i>
   ;; and TAB or <C-m> and RET.
   ;; In the terminal, these pairs are generally indistinguishable, so this only
   ;; works in the GUI. (default nil)
   dotspacemacs-distinguish-gui-tab nil
   ;; If non nil `Y' is remapped to `y$' in Evil states. (default nil)
   dotspacemacs-remap-Y-to-y$ nil
   ;; If non-nil, the shift mappings `<' and `>' retain visual state if used
   ;; there. (default t)
   dotspacemacs-retain-visual-state-on-shift t
   ;; If non-nil, J and K move lines up and down when in visual mode.
   ;; (default nil)
   dotspacemacs-visual-line-move-text nil
   ;; If non nil, inverse the meaning of `g' in `:substitute' Evil ex-command.
   ;; (default nil)
   dotspacemacs-ex-substitute-global nil
   ;; Name of the default layout (default "Default")
   dotspacemacs-default-layout-name "Default"
   ;; If non nil the default layout name is displayed in the mode-line.
   ;; (default nil)
   dotspacemacs-display-default-layout t
   ;; If non nil then the last auto saved layouts are resume automatically upon
   ;; start. (default nil)
   dotspacemacs-auto-resume-layouts t
   ;; Size (in MB) above which spacemacs will prompt to open the large file
   ;; literally to avoid performance issues. Opening a file literally means that
   ;; no major mode or minor modes are active. (default is 1)
   dotspacemacs-large-file-size 1
   ;; Location where to auto-save files. Possible values are `original' to
   ;; auto-save the file in-place, `cache' to auto-save the file to another
   ;; file stored in the cache directory and `nil' to disable auto-saving.
   ;; (default 'cache)
   dotspacemacs-auto-save-file-location 'cache
   ;; Maximum number of rollback slots to keep in the cache. (default 5)
   dotspacemacs-max-rollback-slots 5
   ;; If non nil, `helm' will try to minimize the space it uses. (default nil)
   dotspacemacs-helm-resize nil
   ;; if non nil, the helm header is hidden when there is only one source.
   ;; (default nil)
   dotspacemacs-helm-no-header nil
   ;; define the position to display `helm', options are `bottom', `top',
   ;; `left', or `right'. (default 'bottom)
   dotspacemacs-helm-position 'bottom
   ;; Controls fuzzy matching in helm. If set to `always', force fuzzy matching
   ;; in all non-asynchronous sources. If set to `source', preserve individual
   ;; source settings. Else, disable fuzzy matching in all sources.
   ;; (default 'always)
   dotspacemacs-helm-use-fuzzy 'always
   ;; If non nil the paste micro-state is enabled. When enabled pressing `p`
   ;; several times cycle between the kill ring content. (default nil)
   dotspacemacs-enable-paste-transient-state nil
   ;; Which-key delay in seconds. The which-key buffer is the popup listing
   ;; the commands bound to the current keystroke sequence. (default 0.4)
   dotspacemacs-which-key-delay 0.4
   ;; Which-key frame position. Possible values are `right', `bottom' and
   ;; `right-then-bottom'. right-then-bottom tries to display the frame to the
   ;; right; if there is insufficient space it displays it at the bottom.
   ;; (default 'bottom)
   dotspacemacs-which-key-position 'bottom
   ;; If non nil a progress bar is displayed when spacemacs is loading. This
   ;; may increase the boot time on some systems and emacs builds, set it to
   ;; nil to boost the loading time. (default t)
   dotspacemacs-loading-progress-bar t
   ;; If non nil the frame is fullscreen when Emacs starts up. (default nil)
   ;; (Emacs 24.4+ only)
   dotspacemacs-fullscreen-at-startup t
   ;; If non nil `spacemacs/toggle-fullscreen' will not use native fullscreen.
   ;; Use to disable fullscreen animations in OSX. (default nil)
   dotspacemacs-fullscreen-use-non-native nil
   ;; If non nil the frame is maximized when Emacs starts up.
   ;; Takes effect only if `dotspacemacs-fullscreen-at-startup' is nil.
   ;; (default nil) (Emacs 24.4+ only)
   dotspacemacs-maximized-at-startup nil
   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's active or selected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-active-transparency 90
   ;; A value from the range (0..100), in increasing opacity, which describes
   ;; the transparency level of a frame when it's inactive or deselected.
   ;; Transparency can be toggled through `toggle-transparency'. (default 90)
   dotspacemacs-inactive-transparency 90
   ;; If non nil show the titles of transient states. (default t)
   dotspacemacs-show-transient-state-title t
   ;; If non nil show the color guide hint for transient state keys. (default t)
   dotspacemacs-show-transient-state-color-guide t
   ;; If non nil unicode symbols are displayed in the mode line. (default t)
   dotspacemacs-mode-line-unicode-symbols t
   ;; If non nil smooth scrolling (native-scrolling) is enabled. Smooth
   ;; scrolling overrides the default behavior of Emacs which recenters point
   ;; when it reaches the top or bottom of the screen. (default t)
   dotspacemacs-smooth-scrolling t
   ;; Control line numbers activation.
   ;; If set to `t' or `relative' line numbers are turned on in all `prog-mode' and
   ;; `text-mode' derivatives. If set to `relative', line numbers are relative.
   ;; This variable can also be set to a property list for finer control:
   ;; '(:relative nil
   ;;   :disabled-for-modes dired-mode
   ;;                       doc-view-mode
   ;;                       markdown-mode
   ;;                       org-mode
   ;;                       pdf-view-mode
   ;;                       text-mode
   ;;   :size-limit-kb 1000)
   ;; (default nil)
   dotspacemacs-line-numbers nil
   ;; Code folding method. Possible values are `evil' and `origami'.
   ;; (default 'evil)
   dotspacemacs-folding-method 'evil
   ;; If non-nil smartparens-strict-mode will be enabled in programming modes.
   ;; (default nil)
   dotspacemacs-smartparens-strict-mode nil
   ;; If non-nil pressing the closing parenthesis `)' key in insert mode passes
   ;; over any automatically added closing parenthesis, bracket, quote, etc…
   ;; This can be temporary disabled by pressing `C-q' before `)'. (default nil)
   dotspacemacs-smart-closing-parenthesis nil
   ;; Select a scope to highlight delimiters. Possible values are `any',
   ;; `current', `all' or `nil'. Default is `all' (highlight any scope and
   ;; emphasis the current one). (default 'all)
   dotspacemacs-highlight-delimiters 'all
   ;; If non nil, advise quit functions to keep server open when quitting.
   ;; (default nil)
   dotspacemacs-persistent-server nil
   ;; List of search tool executable names. Spacemacs uses the first installed
   ;; tool of the list. Supported tools are `ag', `pt', `ack' and `grep'.
   ;; (default '("ag" "pt" "ack" "grep"))
   dotspacemacs-search-tools '("ag" "pt" "ack" "grep")
   ;; The default package repository used if no explicit repository has been
   ;; specified with an installed package.
   ;; Not used for now. (default nil)
   dotspacemacs-default-package-repository nil
   ;; Delete whitespace while saving buffer. Possible values are `all'
   ;; to aggressively delete empty line and long sequences of whitespace,
   ;; `trailing' to delete only the whitespace at end of lines, `changed'to
   ;; delete only whitespace for changed lines or `nil' to disable cleanup.
   ;; (default nil)
   dotspacemacs-whitespace-cleanup nil
   ))

(defun dotspacemacs/user-init ()
  "Initialization function for user code.
It is called immediately after `dotspacemacs/init', before layer configuration
executes.
 This function is mostly useful for variables that need to be set
before packages are loaded. If you are unsure, you should try in setting them in
`dotspacemacs/user-config' first."
  )

(defun center-point-vertically (&optional arg)
  (evil-scroll-line-to-center (line-number-at-pos)))
(defun advise-org-global-cycle ()
  (advice-add 'org-global-cycle :after #'evil-scroll-line-to-center))

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

(defun say-hello ()
  "Example of an interactive function"
  (interactive)
  (message "Hello World"))

(defun rebind-key-todo ()
  "Message to remind me of something"
  (interactive)
  (async-shell-command "git gui")
  (shell-command "gitk")
  (message "TODO Rebind this key to something else (See spacemacs file)"))

(defun set-c-indent-behavior (tab-width)
  "Set the behavior of indentation in C mode to tab-width"
  (setq-local evil-shift-width tab-width)
  (setq-local c-basic-offset tab-width))

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
  (define-key evil-insert-state-map (kbd "C-w /") (lambda () (interactive) (split-window-right)))
  (define-key evil-insert-state-map (kbd "C-w -") (lambda () (interactive) (split-window-below)))

  (define-key evil-insert-state-map (kbd "C-a") evil-window-map)
  (define-key evil-normal-state-map (kbd "C-a") evil-window-map)
  (define-key evil-insert-state-map (kbd "C-a /") (lambda () (interactive) (split-window-right)))
  (define-key evil-insert-state-map (kbd "C-a -") (lambda () (interactive) (split-window-below)))
  (define-key evil-normal-state-map (kbd "C-a /") (lambda () (interactive) (split-window-right)))
  (define-key evil-normal-state-map (kbd "C-a -") (lambda () (interactive) (split-window-below)))
  )

(defun new-note (name)
  "Create a new org-mode notes file in standard location"
  (interactive
   (list
    (read-string "New note name : "
                 (apply #'concat (map 'list #'int-to-string (calendar-current-date))))))
  (switch-to-buffer (concat "~/Dropbox/Notes/Notes_BUCKET/Notes_" name ".org"))
  (set-visited-file-name (concat "~/Dropbox/Notes/Notes_BUCKET/Notes_" name ".org"))
  (org-mode)
  (evil-insert-state)
  (yas-insert-snippet "nn"))
(defun c-mode-set-comment-indent-style ()
  ;; ref : https://www.emacswiki.org/emacs/AutoFillMode
  (auto-fill-mode 1)
  (set (make-local-variable 'fill-nobreak-predicate)
       (lambda ()
         (not (eq (get-text-property (point) 'face)
                  'font-lock-comment-face))))
  )

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

(defun dotspacemacs/user-config ()
  "Configuration function for user code.
This function is called at the very end of Spacemacs initialization after
layers configuration.
This is the place where most of your configurations should be done. Unless it is
explicitly specified that a variable should be set before a package is loaded,
you should place your code here."

  (require 'ox-man)
  (require 'ox-md)
  (setq-default scroll-margin 10)
  (define-key evil-normal-state-map [mouse-8] 'previous-buffer)
  (define-key evil-normal-state-map [mouse-9] 'next-buffer)

  (set-window-resize-keys)

  ;; TODO I tried to set this variable in the layers part but that didn't work
  (setq-default org-default-notes-file "~/Dropbox/Notes/Notes_BUCKET/org-capture.org")
  (bind-insert-mode-window-change-keys)

  ;; This value is used when hard wrapping lines with M-x or automatically
  (setq-default fill-column 80)

  ;; I like automatic hard wrapping so this:
  ;; ref : https://www.emacswiki.org/emacs/AutoFillMode
  ;; See : http://blog.binchen.org/posts/easy-indentation-setup-in-emacs-for-web-development.html
  (add-hook 'text-mode-hook 'turn-on-auto-fill)
  (add-hook 'c-mode-common-hook 'c-mode-set-comment-indent-style)
  ;; (setq-default comment-auto-fill-only-comments t)
  (add-hook 'c-mode-hook (lambda () (c-set-style "linux")))

  (add-hook 'org-mode-hook (lambda ()
                             (setq-local evil-shift-width 4)
                             (setq-local tab-width 4)
                             (setq-local org-indent-indentation-per-level 4)))
  (advise-org-global-cycle)
  (add-hook 'org-mode-hook 'org-set-make-code-block-key)

  ;; Typing 'jk' fast will exit inser-mode
  (setq-default evil-escape-key-sequence "jk")
  (setq-default evil-escape-delay 0.3)

  ;; Automatically follow symlinks when they point to a version controlled
  ;; source file.
  (setq-default vc-follow-symlinks t)

  ;; Stuff relating to org-publish
  (require 'ox-publish)
  (setq org-publish-project-alist
        '(
          ("org-notes"
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
           :components ("org-notes" "org-static"))
          ))
  ;; Use pipes for subprocess communication
  ;; This is because withoug this, in org-mode 'C-c C-e h' did not open
  ;; the exported file.  With this it does.
  ;; REF: https://askubuntu.com/questions/646631/emacs-doesnot-work-with-xdg-open
  ;; Note: People in the reference say that this breaks using gnuplot with org-mode.
  ;; See comments on the answer that gives this line.
  (setq process-connection-type nil)

  (global-company-mode)
  )

;; Do not write anything past this comment. This is where Emacs will
;; auto-generate custom variable definitions.
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (twittering-mode cmake-ide levenshtein helm-gtags ggtags go-guru go-eldoc company-go go-mode ergoemacs-mode vimrc-mode dactyl-mode pdf-tools tablist web-beautify livid-mode skewer-mode simple-httpd json-mode json-snatcher json-reformat js2-refactor multiple-cursors js2-mode js-doc company-tern tern coffee-mode wakatime-mode reveal-in-osx-finder pbcopy osx-trash osx-dictionary launchctl erc-yt erc-view-log erc-social-graph erc-image erc-hl-nicks org-mobile-sync web-mode tagedit slim-mode scss-mode sass-mode pug-mode helm-css-scss haml-mode emmet-mode company-web web-completion-data key-chord rainbow-mode rainbow-identifiers color-identifiers-mode org-gcal yapfify pyvenv pytest pyenv-mode py-isort pip-requirements live-py-mode hy-mode dash-functional helm-pydoc cython-mode anaconda-mode pythonic ws-butler winum which-key volatile-highlights vi-tilde-fringe uuidgen use-package toc-org spaceline powerline restart-emacs request rainbow-delimiters popwin persp-mode pcre2el paradox spinner org-plus-contrib org-bullets open-junk-file neotree move-text macrostep lorem-ipsum linum-relative link-hint indent-guide hydra hungry-delete hl-todo highlight-parentheses highlight-numbers parent-mode highlight-indentation helm-themes helm-swoop helm-projectile helm-mode-manager helm-make projectile pkg-info epl helm-flx helm-descbinds helm-ag google-translate golden-ratio flx-ido flx fill-column-indicator fancy-battery eyebrowse expand-region exec-path-from-shell evil-visualstar evil-visual-mark-mode evil-unimpaired evil-tutor evil-surround evil-search-highlight-persist evil-numbers evil-nerd-commenter evil-mc evil-matchit evil-lisp-state smartparens evil-indent-plus evil-iedit-state iedit evil-exchange evil-escape evil-ediff evil-args evil-anzu anzu evil goto-chg undo-tree eval-sexp-fu highlight elisp-slime-nav dumb-jump f dash s diminish define-word column-enforce-mode clean-aindent-mode bind-map bind-key auto-highlight-symbol auto-compile packed aggressive-indent adaptive-wrap ace-window ace-link ace-jump-helm-line helm avy helm-core popup async))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
