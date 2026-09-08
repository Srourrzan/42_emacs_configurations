;;; .emacs --- Emacs configuration

;;; Commentary:
;; Configuration for C, GTK4, SQLite, Meson, TOML development.

;;; Code:

;; -----------------------------------------------------------------------------
;; 1. Package Initialization
;; -----------------------------------------------------------------------------
(add-to-list 'load-path "~/.emacs.d/42ammn")
(load-file "~/.emacs.d/test.el")

(require 'package)

(setq package-archives
      '(("gnu"   . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")
        ("org"   . "https://orgmode.org/elpa/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

;; -----------------------------------------------------------------------------
;; 2. Custom Faces and Variables (Managed by Emacs Customize)
;; -----------------------------------------------------------------------------
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 )

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#2e3436" "#a40000" "#4e9a06" "#c4a000" "#204a87" "#5c3566" "#729fcf" "#eeeeec"])
 '(column-number-mode t)
 '(custom-enabled-themes '(modus-operandi-tinted))
 '(debug-on-error t)
 '(display-battery-mode t)
 '(fringe-mode '(nil . 0) nil (fringe))
 '(global-display-line-numbers-mode t)
 '(global-tab-line-mode t)
 '(indicate-empty-lines t)
 '(inhibit-startup-screen t)
 '(ispell-dictionary nil)
 '(package-selected-packages '(company flycheck magit rust-mode sr-speedbar tide toml-mode meson-mode web-mode vterm))
 '(speedbar-use-images t)
 '(tab-bar-mode t)
 '(tab-bar-show t)
 '(tool-bar-size 5)
 '(window-divider-default-places t))

;; -----------------------------------------------------------------------------
;; 3. Global Editor Behavior & UI
;; -----------------------------------------------------------------------------
(setq-default tool-bar-button-margin 1)
(setq-default truncate-lines t)
(setq switch-to-buffer-in-dedicated-window 'ignore)
(setq speedbar-directory-unshown-regexp "^$\\.\\.?$") ;; Fixed regex syntax

;; Allow tabs for indentation globally
(setq-default indent-tabs-mode t)
(setq-default tab-width 4)

;; Show hidden files in GUI and Dired
(setq x-gtk-show-hidden-files t)
(setq dired-listing-switches "-a")

;; Simplified Electric Pair Mode (natively handles all standard pairs)
(electric-pair-mode 1)

;; -----------------------------------------------------------------------------
;; 4. Language-Specific Hooks & Configurations
;; -----------------------------------------------------------------------------

;; --- Rust ---
(require 'rust-mode)
(add-hook 'rust-mode-hook
          (lambda ()
            (setq indent-tabs-mode nil)
            (prettify-symbols-mode)))
(setq rust-format-on-save t)

;; --- Python ---
(defun cust-python-indent-config ()
  (setq indent-tabs-mode nil)
  (setq tab-width 4)
  (setq python-indent-offset 4))

(add-hook 'python-mode-hook #'cust-python-indent-config)
(add-hook 'python-mode-hook
          (lambda ()
            (add-hook 'before-save-hook 'untabify nil t)))

;; --- C / C++ (Meson/GTK4/SQLite Stack) ---
(require 'cc-mode)
;; Removed the broken 'self-insert-command' TAB override.
;; This new hook ensures smart indentation while STILL using hard tabs of width 4.
(add-hook 'c-mode-hook
          (lambda ()
			;; Apply the custom GNOME/GTK style
			(c-set-style "gnu")
			(setq c-basic-offset 2)
			(setq indent-tabs-mode nil)
			(c-set-offset 'substatement-open 0)
            ;; Set Meson as the default compile command locally for C files
            (setq-local compile-command "meson compile -C build")
			;; Enable LSP (Eglot) for GTK4/SQLite intellisense
            (eglot-ensure)))

(add-hook 'c++-mode-hook 'eglot-ensure)

;; -----------------------------------------------------------------------------
;; 5. Custom Functions & Keybindings
;; -----------------------------------------------------------------------------

(defun move-line-up ()
  "Move the current line up."
  (interactive)
  (transpose-lines 1)
  (forward-line -2)
  (indent-according-to-mode))

(defun move-line-down ()
  "Move down the current line."
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1)
  (indent-according-to-mode))

(global-set-key (kbd "M-<up>") 'move-line-up)
(global-set-key (kbd "M-<down>") 'move-line-down)

(defun ft_term ()
  "Launch `term` using /bin/bash."
  (interactive)
  (term "/bin/bash"))

(defun my-git-diff-current-file ()
  "Show git diff of current file vs HEAD."
  (interactive)
  (if (and buffer-file-name (vc-backend buffer-file-name))
      (magit-diff-buffer-file)
    (message "Not a Git-controlled file.")))

(global-set-key (kbd "C-c g d") #'my-git-diff-current-file)

;; Tab-bar background syncing
(defun tab-bar-sync-active-tab-to-background ()
  "Make active tab in `tab-bar-mode` match the buffer background."
  (when (display-graphic-p)
    (let* ((bg (face-attribute 'default :background (selected-frame))))
      (set-face-attribute 'tab-bar-tab nil
                          :background bg
                          :foreground (face-attribute 'default :foreground (selected-frame))
                          :box nil
                          :underline nil))))

(add-hook 'tab-bar-mode-hook #'tab-bar-sync-active-tab-to-background)
(advice-add 'load-theme :after (lambda (&rest _) (tab-bar-sync-active-tab-to-background)))

;; -----------------------------------------------------------------------------
;; 6. Startup Layout
;; -----------------------------------------------------------------------------
(defun my-startup-layout ()
  "Set up three-window layout. Top-left shows file (if any) or *scratch*."
  (let ((top (selected-window))
        bottom)
    (setq bottom (split-window-below -8))

    ;; Top-left: file buffer (if loading a file), else *scratch*
    (select-window top)
    (if buffer-file-name
        (switch-to-buffer (current-buffer))
      (switch-to-buffer "*scratch*"))

    ;; Top-right: sr-speedbar
    (when (fboundp 'sr-speedbar-open)
      (sr-speedbar-open)) ;; FIXED: Removed broken (speedbar default-directory) call

    ;; Bottom: Terminal
    (select-window bottom)
    (cond
     ((and (fboundp 'vterm) (require 'vterm nil t))
      (vterm))
     (t
      (ansi-term (getenv "SHELL"))))
    (set-window-dedicated-p (selected-window) t)

    ;; Return to top-left window
    (select-window top)
    (set-window-dedicated-p (selected-window) nil)))

(add-hook 'window-setup-hook #'my-startup-layout)

;; -----------------------------------------------------------------------------
;; 7. Package Configurations (use-package)
;; -----------------------------------------------------------------------------

(use-package vterm
  :ensure t
  :commands vterm
  :config
  (setq vterm-always-compile-module t))

(use-package sr-speedbar
  :ensure t
  :commands sr-speedbar-open
  :config
  (setq sr-speedbar-right-side t)
  (setq sr-speedbar-width 15)
  (setq sr-speedbar-show-hidden t) ;; FIXED: Typo was sr-sppedbar-show-hidden
  (setq speedbar-show-unknown-files t))

(use-package web-mode
  :ensure t
  :mode ("\\.tsx?\\'"))

(use-package company
  :ensure t
  :config
  (global-company-mode t)) ;; FIXED: Added global activation

(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode t)
  :config
  (setq flycheck-check-syntax-automatically '(save mode-enabled)))

(use-package magit
  :ensure t)

;; --- Meson & TOML Support (Robust setup) ---
(use-package meson-mode
  :ensure t
  :mode ("meson\\.build\\'"
         "meson\\.options\\'"
         "meson_options\\.txt\\'"))

(use-package toml-mode
  :ensure t
  :mode "\\.toml\\'")

;; -----------------------------------------------------------------------------
;; 8. Work in Progress / Commented Out Code
;; -----------------------------------------------------------------------------
;; (defvar c-current-func-overlay nil
;;   "Overlay used to highlight current C/C++ function region.")

;; (defface c-func-highlight-face
;;   '((t :background "#333333"))
;;   "Face for highlight current C/C++ function.")

;; (defun c-highlight-current-function ()
;;   "Highlight the current C/C++ function in the buffer."
;;   (when (derived-mode-p 'c-mode 'c++-mode 'objc-mode)
;;     (let ((start (save-excursion (c-beginning-of-defun) (point)))
;;           (end (save-excursion (c-end-of-defun) (point))))
;;       (if (and start end (> end start))
;;           (if (overlayp c-current-func-overlay)
;;               (move-overlay c-current-func-overlay start end)
;;             (setq c-current-func-overlay
;;                   (make-overlay start end)))
;;         (when (overlayp c-current-func-overlay)
;;           (delete-overlay c-current-func-overlay)
;;           (setq c-current-func-overlay nil)))
;;       (when (overlayp c-current-func-overlay)
;;         (overlay-put c-current-func-overlay 'face 'c-func-highlight-face)))))

;; (defun c-enable-current-func-highlight ()
;;   "Enable highlight of current c/c++ function in an active buffer."
;;   (add-hook 'post-command-hook #'c-highlight-current-function nil t))

;; (add-hook 'c-mode-common-hook #'c-enable-current-func-highlight)

;; -----------------------------------------------------------------------------
(provide '.emacs)
;;; .emacs ends here
