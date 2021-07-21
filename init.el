(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auth-source-save-behavior nil)
 '(custom-safe-themes
   '("e5b7b99ec658a89ec23bf88765c0720f04cacb0f994832f7044967bda7f15914" "d9046dcd38624dbe0eb84605e77d165e24fdfca3a40c3b13f504728bab0bf99d" default))
 '(org-agenda-files nil)
 '(package-selected-packages
   '(lsp-java lsp-ui yasnippet-snippets use-package flycheck dap-mode company)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; General Variables ;;
(setq inhibit-startup-screen 1)
(setq initial-frame-alist (quote ((fullscreen . maximized))))
(setq async-shell-command-buffer 'new-buffer)
(setq save-interprogram-paste-before-kill t)
(setq initial-buffer-choice (expand-file-name "~"))
(setq next-screen-context-lines 4)

;; Make Aliases Available in Subshell ;;
(unless (string-match-p (regexp-quote "mingw")
                        (emacs-version))
  (setq shell-file-name "bash")
  (setq shell-command-switch "-ic"))

;; Packages
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

;; fetch list of available packages
(unless package-archive-contents (package-refresh-contents))

;; install needed packages
(defvar luna/packages '(kivy-mode
                        rust-mode
                        slime
                        use-package))
(dolist (package luna/packages)
  (unless (package-installed-p package) (package-install package)))

(use-package company :ensure t)

(use-package dap-java :ensure nil)

(use-package dap-mode
  :ensure t
  :after (lsp-mode dap-java)
  :functions dap-hydra/nil
  :config
  (require 'dap-java)
  :bind (:map lsp-mode-map
              ("<f5>" . dap-debug)
              ("M-<f5>" . dap-hydra))
  :hook ((dap-mode . dap-ui-mode)
         (dap-session-created . (lambda (&_rest) (dap-hydra)))
         (dap-terminated . (lambda (&_rest) (dap-hyrda/nil)))))

(use-package flycheck :ensure t :init (global-flycheck-mode))

(use-package kivy-mode)

(use-package lsp-mode
  :ensure t
  :hook ((lsp-mode . lsp-enable-which-key-integration)
         (java-mode . #'lsp-deferred))
  :init (setq lsp-keymap-prefix "C-c l"
              lsp-enable-file-watchers nil
              read-process-output-max (expt 2 20)
              lsp-completion-provider :capf
              lsp-idle-delay 0.500)
  :config (progn (setq lsp-intelephense-multi-root nil)
                 (with-eval-after-load 'lsp-intelephense
                   (setf (lsp--client-multi-root (gethash 'iph lsp-clients)) nil))
                 (define-key lsp-mode-map (kbd "C-c l") lsp-command-map)))

(use-package lsp-java
  :ensure t
  :config (add-hook 'java-mode-hook 'lsp))

(use-package lsp-treemacs
  :ensure t
  :after (lsp-mode treemacs)
  :commands lsp-treemacs-errors-list
  :bind (:map lsp-mode-map
              ("M-9" . lsp-treemacs-errors-list)))

(use-package lsp-ui
  :ensure t
  :after (lsp-mode)
  :bind (:map lsp-ui-mode-map
              ([remap xref-find-definitions] . lsp-ui-peek-find-definitions)
              ([remap xref-find-references] . lsp-ui-peek-find-references))
  :init (setq lsp-ui-doc-delay 1.5
              lsp-ui-doc-position 'bottom
              lsp-ui-doc-max-width 100))

(use-package markdown-mode)

(use-package projectile
  :ensure t
  :init (projectile-mode +1)
  :config (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

(use-package rust-mode)

(use-package slime)

(use-package treemacs
  :ensure t
  :commands (treemacs))

(use-package which-key
  :ensure t
  :init (progn (which-key-setup-minibuffer)
               (which-key-mode)))

(use-package yasnippet :config (yas-global-mode))

(use-package yasnippet-snippets :ensure t)

;; Load ;;
(add-to-list 'load-path (expand-file-name "~/.emacs.d/external"))

(require 'dired-x)

(if (file-exists-p "renpy-mode/renpy.el")
    (load "renpy-mode/renpy.el"))
(if (file-exists-p "yaml-mode/yaml-mode.el")
    (load "yaml-mode/yaml-mode.el"))

(load "my-functions.el")
(load "my-keys.el")
(load "my-arduino.el")
(load "my-cc.el")
(load "my-c.el")
(load "my-dired.el")
(load "my-html.el")
(load "my-latex.el")
(load "my-man.el")
(load "my-matlab.el")
(load "my-org.el")
(load "my-python.el")
(load "my-shell.el")
(load "my-slime.el")
;; (load "my-tide.el")
(load "my-minor-modes.el")

;; async-shell-command ;;
(add-to-list 'display-buffer-alist (cons "\\*Async Shell Command\\*.*" (cons #'display-buffer-no-window nil)))

;; Aliases ;;
(defalias 'str= 'string=)
(defalias 'yes-or-no-p 'y-or-n-p) ; force y/n
(defalias 'async-shell-command 'dfp/async-shell-command) ; allow specifying output-buffer interactively
(setq ring-bell-function 'ignore)

;; Mode Settings ;;
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode 1)
(setq-default indent-tabs-mode nil)
(setq-default subword-mode 1)

;; Additional Settings for Tiling WMs ;;
(when (and (not (string-match-p (regexp-quote "mingw") ; if we are not on Windows
                                (emacs-version)))
           (or (string-match-p (regexp-quote "i3") (shell-command-to-string "echo $DESKTOP_SESSION"))         ; and if we are on i3
               (string-match-p (regexp-quote "sway") (shell-command-to-string "echo $DESKTOP_SESSION"))))      ; or sway
  (defalias 'quit-window 'delete-frame)                ; tiling WM-friendly settings
  (setf pop-up-frames t))

;; Final ;;
(load "my-appearance.el")
