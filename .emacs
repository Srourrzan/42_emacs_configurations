;;; .emacs --- Emacs configuration

;;; Commentary:

;;; Code:

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
   ["#2e3436" "#a40000" "#4e9a06" "#c4a000" "#204a87" "#5c3566" "#729fcf" "#eeeeec"])
 '(custom-enabled-themes '(tsdh-dark))
 '(debug-on-error t)
 '(indicate-empty-lines t)
 '(inhibit-startup-screen t)
 '(ispell-dictionary nil)
 '(tab-bar-show t)
 '(window-divider-default-places t))

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
(setq electric-pair-pairs '(
							(?\{ . ?\})
							(?\( . ?\))
							(?\[ . ?\])
							(?\" . ?\")
							(?\' . ?\')
							))

(setq switch-to-buffer-in-dedicated-window 'ignore)

(add-hook 'after-init-hook
          (lambda ()
            ;;(delete-other-windows) ;; start clean

            ;; Split into top and bottom
            (let ((top (selected-window))
                  bottom right)
              (setq bottom (split-window-below -8)) ;; bottom window
              (setq right (split-window-right -10))  ;; top-right window

              ;; Top-left = *scratch*
              (select-window top)
              (switch-to-buffer "*scratch*")

              ;; Top-right = Dired
              (select-window right)
              (dired default-directory)

              ;; Bottom = terminal
              (select-window bottom)
              (if (fboundp 'vterm)
                  (vterm)
                (ansi-term (getenv "SHELL")))
			  ;; Lock this window to always show the terminal buffer
			  (set-window-dedicated-p (selected-window) t)
			  )))

;; Show hidden files
(setq x-gtk-show-hidden-files t)
(setq dired-listing-switches "-a")

(provide '.emacs)
;;; .emacs ends here
