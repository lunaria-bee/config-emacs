;; Keybindings ;;
(with-eval-after-load "c-mode"
  ;; prevent c-mode from overriding my-keys
  (define-key c-mode-keymap (kbd "C-d") nil))

;; Hide/Show Mode ;;
(add-hook 'c++-mode-hook 'hs-minor-mode)
(add-hook 'c-mode-hook 'hs-minor-mode)
(add-hook 'java-mode-hook 'hs-minor-mode)
