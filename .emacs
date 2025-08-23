;;Allow tabs for indentation
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
 '(custom-enabled-themes '(leuven-dark))
 '(package-selected-packages '(flycheck)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(require 'package)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(use-package flycheck
	     :ensure t
	     :init (global-flycheck-mode))
