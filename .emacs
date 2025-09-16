;;; .emacs --- Emacs configuration

;;; Commentary:

;;; Code:

(require 'package)

;; Add MELPA and other important archives
(setq package-archives
	  '(("gnu"   . "https://elpa.gnu.org/packages/")
		("melpa" . "https://melpa.org/packages/")
		("org"   . "https://orgmode.org/elpa/")))

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;; Allow tabs for indentation
(setq-default indent-tabs-mode t)
;; Make tab characters display as 4 spaces wide
(setq-default tab-width 4)
;;In C mode, make TAB key insert an actual tab character
(require 'cc-mode)
(define-key c-mode-map (kbd "TAB") 'self-insert-command)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
   [default default default italic underline success warning error])
 '(ansi-color-names-vector
   ["#2e3436" "#a40000" "#4e9a06" "#c4a000" "#204a87" "#5c3566" "#729fcf"
	"#eeeeec"])
 '(custom-enabled-themes '(tsdh-dark))
 '(debug-on-error t)
 '(indicate-empty-lines t)
 '(inhibit-startup-screen t)
 '(ispell-dictionary nil)
 '(package-selected-packages '(company flycheck magit tide))
 '(tab-bar-show t)
 '(window-divider-default-places t))

(defun tab-bar-sync-active-tab-to-background ()
  "Make active tab in `tab-bar-mode` match the buffer background."
  (when (display-graphic-p) ;;only if using a GUI where colors work
	(let* ((bg (face-attribute 'default :background (selected-frame))))
	  ;; Set active tab to have same background
	  (set-face-attribute 'tab-bar-tab nil
						  :background bg
						  :foreground (face-attribute 'default :foreground (selected-frame))
						  :box nil
						  :underline nil
						  )
	  )))

;; Run tab-bar background on startup
(add-hook 'tab-bar-mode-hook #'tab-bar-sync-active-tab-to-background)
;; Run tab-bar background when theme changes
(advice-add 'load-theme :after (lambda (&rest _) (tab-bar-sync-active-tab-to-background)))


(defun move-line-up()
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

(defun ft_term()
  "Launch `term` using /bin/bash."
  (interactive)
  (term "/bin/bash"))

(electric-pair-mode 1)
(defvar electric-pair-pairs nil
  "List of extra pairs for `electric-pair-mode'.")
(setq electric-pair-pairs '(
							(?\{ . ?\})
							(?\( . ?\))
							(?\[ . ?\])
							(?\" . ?\")
							(?\' . ?\')
							(?\< . ?\>)
							(?\` . ?\`)
							))

(setq switch-to-buffer-in-dedicated-window 'ignore)

(defun my-startup-layout ()
  "set up three-window layout. Top-left shows file (if any) or *scratch*."
  (let ((top (selected-window))
        bottom right)
    (setq bottom (split-window-below -8))
    (setq right  (split-window-right -10))

    ;; Top-left: file buffer (if loading a file), else *scratch*
    (select-window top)
    (if buffer-file-name
        (switch-to-buffer (current-buffer)) ;; keep the file buffer
      (switch-to-buffer "*scratch*"))

    ;; Top-right: Dired
    (select-window right)
    (dired default-directory)
    (set-window-dedicated-p (selected-window) t)

    ;; Bottom: Terminal
    (select-window bottom)
    (if (fboundp 'vterm) (vterm) (ansi-term (getenv "SHELL")))
    (set-window-dedicated-p (selected-window) t)

    (select-window top)
  ))

;; Run this after Emacs has opened buffers for files from command line
(add-hook 'window-setup-hook #'my-startup-layout)


;; Show hidden files
(setq x-gtk-show-hidden-files t)
(setq dired-listing-switches "-a")

(add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.ts\\'" . web-mode))

(declare-function flycheck-add-next-checker "flycheck")
(declare-function flycheck-add-mode "flycheck")

(use-package company
  :ensure t)

;; Set Flycheck
(use-package flycheck
  :ensure t
  :init
  (global-flycheck-mode t)
  :config
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  )

;; Ensure Magit is available
(use-package magit
  :ensure t)

;; keybinding to quickly diff current buffer vs HEAD
(defun my-git-diff-current-file ()
  "Show git diff of current file vs HEAD."
  (interactive)
  (if (and buffer-file-name (vc-backend buffer-file-name))
	  (magit-diff-buffer-file)
	(message "Not a Git-controlled file.")))

(global-set-key (kbd "C-c g d") #'my-git-diff-current-file)

(provide '.emacs)
;;; .emacs ends here
