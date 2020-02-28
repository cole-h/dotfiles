;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; system setup and friends
;; (toggle-debug-on-quit)
;; (toggle-debug-on-error)
;; (doom/toggle-debug-mode)

(setq user-full-name "Cole Helbling"
      user-mail-address "cole.e.helbling@gmail.com"

      max-lisp-eval-depth 400
      max-specpdl-size 650

      ;; scroll-preserve-screen-position t
      ;; scroll-margin 200
      ;; scroll-conservatively 101
      )

;; modes and friends
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
;; (global-undo-tree-mode -1)
;; (global-display-fill-column-indicator-mode)
(evil-unimpaired-mode)

;; loading and friends
(load! "funcs.el")
;; (load! "+jetbrainsmono.el")

;; functions and friends

;; setq and friends
(setq display-line-numbers-type 'relative
      doom-modeline-lsp nil
      inhibit-read-only t
      mouse-wheel-progressive-speed nil
      tab-always-indent 'complete
      which-key-idle-delay 0.4

      ;; lsp-ui-doc-enable nil
      ccls-args '("-v=2" "-log-file=/tmp/ccls.log")
      +workspaces-on-switch-project-behavior t

      magit-repository-directories '(("~/workspace/vcs" . 1)
                                     ("~/workspace/langs" . 1)
                                     ("~/doom-emacs" . 0))
      magit-save-repository-buffers nil
      transient-values '((magit-commit "--gpg-sign=B37E0F2371016A4C")
                         (magit-rebase "--autosquash" "--gpg-sign=B37E0F2371016A4C")
                         (magit-pull "--rebase" "--gpg-sign=B37E0F2371016A4C"))

      password-cache-expiry (* 4 (* 60 60)) ;; because my machine is secure enough

      ivy-count-format ""
      ivy-display-style nil
      ivy-extra-directories nil
      ivy-magic-tilde nil)

;; after! and friends
(after! recentf
  ;; don't add secure, tmp files to recents
  (add-to-list 'recentf-exclude "^/dev/shm/"))
(after! company
  (setq company-minimum-prefix-length 2
        company-tooltip-limit 10
        company-idle-delay 0.2
        ;; company-lsp-cache-candidates 'auto
        ;; company-dabbrev-downcase nil
        ))
(after! doom-modeline
  (doom-modeline-def-modeline 'main
    '(bar modals window-number matches buffer-info remote-host buffer-position selection-info)
    '(misc-info persp-name irc mu4e github debug input-method buffer-encoding lsp major-mode process vcs checker)))
(after! evil
  (setq evil-want-fine-undo t
        evil-ex-substitute-global nil
        ;; evil-emacs-state-cursor '("SkyBlue2" box)
        ;; evil-insert-state-cursor '("chartreuse3" (bar . 2))
        ;; evil-motion-state-cursor '("plum3" box)
        ;; evil-normal-state-cursor '("DarkGoldenrod2" box)
        ;; evil-operator-state-cursor 'evil-half-cursor
        ;; evil-replace-state-cursor '("chocolate" (hbar . 2))
        ;; evil-visual-state-cursor '("gray" (hbar . 2))
  ))
(after! evil-magit
  (setq evil-magit-use-z-for-folds t))
(after! evil-escape
  (setq evil-escape-inhibit t))
(after! hl-todo
  (setq hl-todo-keyword-faces '(("TODO" . "#ecbe7b")
                                ("FIXME" . "#ff6c6b")
                                ("NOTE" . "#98be65")
                                ("XXX" . "red"))))
(after! magit
  (setq magit-display-buffer-function 'magit-display-buffer-traditional
        magit-completing-read-function 'ivy-completing-read
        magit-revision-headers-format (concat magit-revision-headers-format "\n%GG"))
  (set-popup-rule! "^.*magit" :slot -1 :side 'bottom :size 15 :select t))
;; (after! ivy
;;   (add-to-list 'ivy-sort-functions-alist
;;                '(counsel-recentf . file-newer-than-file-p)))
(after! org
  (remove-hook 'org-tab-first-hook #'+org|cycle-only-current-subtree)
  (setq org-log-states-order-reversed t
        org-ellipsis " ▼ "
        org-bullets-bullet-list '(">")
        org-hide-emphasis-markers t
        org-todo-keywords
        '((sequence
           "TODO(t!)" "NEXT(n!)" "ONGOING(o!)" "BLOCKED(b!)"
           "DELEGATE(g!)" "DELEGATED(G!)" "FOLLOWUP(f!)"
           "BACKLOG(T!)" "IDEA(i!)" "|" "CANCELED(c!)" "DONE(d!)"))))
(after! undohist
  (setq undohist-ignored-files '("\\.gpg\\'"
                                 "COMMIT_EDITMSG"
                                 file-remote-p)))
(after! rustic
  ;; workaround from https://github.com/hlissner/doom-emacs/pull/2466
  (require 'smartparens-rust)
  (defun curly-space (&rest _ignored)
    "Correctly format if you hit space inside of {}"
    (left-char 1)
    (insert " "))
  (defun smooth-curly-block (&rest _ignored)
    "Correctly format if you hit enter inside of ({})"
    (newline)
    (indent-according-to-mode)
    (forward-line -1)
    (indent-according-to-mode))
  (setq rustic-format-on-save t
        rustic-lsp-server 'rust-analyzer
        fill-column 100)
  (sp-local-pair 'rustic-mode "({" "})" :post-handlers '((smooth-curly-block "RET")))
  (sp-local-pair 'rustic-mode "{" "}" :post-handlers '((curly-space "SPC") (smooth-curly-block "RET"))))
(after! smartparens
  ;; remove autoclosing of escaped quotes
  (sp-pair "\\\"" "\\\"" :actions :rem)
  ;; remove autoclosing of double quotes
  (sp-pair "\"" "\"" :actions :rem)
  ;; remove autoclosing of single quotes
  ;; (sp-pair "'" "'" :actions :rem) ;; haskell mode doesn't like this
  ;; remove autoclosing of curly braces
  (sp-pair "{" "}" :actions :rem)
  ;; remove autoclosing of parentheses unless in elisp
  (sp-pair "(" ")" :actions :rem))
  ;; (sp-pair "(" ")" :when '(eq major-mode 'emacs-lisp-mode)))
;; (after! base16-theme
;;   ;; I don't want any italics/slanted characters in my modeline
;;   (custom-set-faces! '(mode-line-emphasis :slant normal)))
(after! magit-todos
  (cl-defun magit-todos-jump-to-item (&key peek (item (oref (magit-current-section) value)))
    "Show current item.
If PEEK is non-nil, keep focus in status buffer window."
    (interactive)
    (let* ((status-window (selected-window))
           (buffer (magit-todos--item-buffer item)))
      (ace-window 1)
      (switch-to-buffer buffer)
      (magit-todos--goto-item item)
      (when (derived-mode-p 'org-mode)
        (org-show-entry))
      (when peek
        (select-window status-window)))))
(after! prescient
  (setq ivy-posframe-border-width 1))
(after! (nix-mode lsp-mode)
  (add-to-list 'lsp-language-id-configuration '(nix-mode . "nix"))
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection '("rnix-lsp"))
                    :major-modes '(nix-mode)
                    :server-id 'nix)))
(after! centaur-tabs
  (setq centaur-tabs-cycle-scope 'tabs))

;; map! and friends
;; (map! :n "u" #'undo-fu-only-undo)
;; (map! :n "\C-r" #'undo-fu-only-redo)
(map! :g "M-<up>" #'drag-stuff-up)
(map! :g "M-<down>" #'drag-stuff-down)
;; (map! :nv "[e" #'drag-stuff-up)
;; (map! :nv "]e" #'drag-stuff-down)
(map! :n "j" #'evil-next-visual-line)
(map! :n "k" #'evil-previous-visual-line)
(map! :n "<down>" #'evil-next-visual-line)
(map! :n "<up>" #'evil-previous-visual-line)
(map! :v "s" #'evil-surround-region)
(map! (:after company :map company-active-map
        "<tab>" #'company-complete-selection
        "<ret>" nil))
(map! (:after ivy :map ivy-minibuffer-map
        "<tab>" #'ivy-alt-done
        "<left>" #'ivy-backward-delete-char
        "<right>" #'ivy-alt-done))
(map! :leader :desc "Kill Emacs" :n "qQ" #'save-buffers-kill-emacs)
(map! :leader :desc "Switch to alternate buffer" :n "," #'vin/alternate-buffer)
;; (map! :after evil :n "M-D" #'vin/replace-or-delete-pair) ;; Henrik fixed cs(> so, no longer necessary

;; SPC f p c -> config, SPC f p i -> init, SPC f p p -> packages, SPC f p f -> funcs
(map! :leader "fp" nil
      (:prefix ("fp" . "private")
        :desc "Go to private init.el" :g "i" #'vin/find-init
        :desc "Go to private config.el" :g "c" #'vin/find-config
        :desc "Go to private packages.el" :g "p" #'vin/find-packages
        :desc "Go to private funcs.el" :g "f" #'vin/find-funcs))

;; (map! :leader "fe" nil
;;       (:prefix ("fe" . "doom")
;;         ;; :desc "Find file in emacs.d" :g "f" #'+default/find-in-emacsd ;; default
;;         :desc "Update Doom" :g "U" #'doom//update
;;         :desc "Refresh Doom" :g "R" #'doom//refresh))

;; add-hook! and friends
;; TODO: https://with-emacs.com/posts/ui-hacks/show-matching-lines-when-parentheses-go-off-screen/
(add-hook!
 'ediff-cleanup-hook #'vin/ediff-janitor
 'emacs-lisp-mode-hook #'aggressive-indent-mode
 'text-mode-hook (visual-line-mode 1)
 'rustic-mode-hook #'((rainbow-delimiters-mode 1)
                      (#'adjust-rust-company-backends)
                      ;; (lsp-rust-analyzer-inlay-hints-mode 1)
                      )
 'focus-out-hook 'save-buffer
 ;; 'helm-minibuffer-set-up-hook #'vin/helm-hide-minibuffer-maybe
 )

;; advice-add and friends
(advice-add 'evil-ex-search-next :after #'vin/center-on-search)
(advice-add 'evil-ex-search-previous :after #'vin/center-on-search)
;; (advice-add 'undohist-save-1 :before-while
;;             (defun undohist-only-save-file-buffers+ (&rest _)
;;               (and (buffer-file-name (current-buffer))
;;                    (undohist-recover-file-p (buffer-file-name (current-buffer))))))
;; (advice-add 'evil-paste-after :around #'vin/replace-fancy-quotes)
(advice-add #'lsp--lv-message :override #'ignore)
;; (defadvice! restrict-lv-window-height (orig-fn &rest args)
;;   :around #'lv-message
;;   (cl-letf* ((old-fit-window-to-buffer (symbol-function #'fit-window-to-buffer))
;;              ((symbol-function #'fit-window-to-buffer)
;;               (lambda (&optional window _max-height min-height max-width min-width preserve-size)
;;                 (funcall old-fit-window-to-buffer
;;                          ;; window (/ (frame-height) 2) min-height
;;                          10
;;                          max-width min-width preserve-size))))
;;     (apply orig-fn args)))
(defadvice! let-semi-white (orig-fn &rest args)
  :around #'evil-forward-word-begin
  :around #'evil-forward-word-end
  :around #'evil-backward-word-begin
  :around #'evil-backward-word-end
  (let ((table (copy-syntax-table (syntax-table))))
    ;; (modify-syntax-entry ?: "-" table)
    (modify-syntax-entry ?_ "w" table)
    (with-syntax-table table
      (apply orig-fn args))))
;; Thanks Henrik :-) https://github.com/hlissner/doom-emacs/commit/c6ebf4b4be9d555fb2ae71143a71444b0fa7fe11
