;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "L-Nafaryus"
      user-mail-address "l.nafaryus@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(setq confirm-kill-emacs nil)

(after! mu4e
  (setq +mu4e-gmail-accounts '(("l.nafaryus@gmail.com" . "/gmail-main")))

  (auth-source-pass-enable)
  (setq auth-source-debug t)
  (setq auth-source-do-cache nil)
  (setq auth-sources '(password-store))

  ;; don't need to run cleanup after indexing for gmail
  (setq mu4e-index-cleanup nil)
  ;; because gmail uses labels as folders we can use lazy check since
  ;; messages don't really "move"
  (setq mu4e-index-lazy-check t)

  (set-email-account! "l.nafaryus@gmail.com"
    '((mu4e-sent-folder       . "/gmail-main/[Gmail]/Sent Mail")
      (mu4e-drafts-folder     . "/gmail-main/[Gmail]/Drafts")
      (mu4e-trash-folder      . "/gmail-main/[Gmail]/Trash")
      (mu4e-refile-folder     . "/gmail-main/[Gmail]/All Mail")
      (smtpmail-smtp-user     . "l.nafaryus@gmail.com")
      (smtpmail-local-domain . "gmail.com")
      (smtpmail-default-smtp-server . "smtp.gmail.com")
      (smtpmail-smtp-server . "smtp.gmail.com")
      (smtpmail-smtp-service . 587)
      (mu4e-compose-signature . "---\nL-Nafaryus"))
    t)

  (setq mu4e-context-policy 'ask-if-none)
  (setq mu4e-compose-context-policy 'always-ask)
  ;; viewing options
  (setq mu4e-view-show-addresses t)
  ;; Do not leave message open after it has been sent
  (setq message-kill-buffer-on-exit t)
  ;; Don't ask for a 'context' upon opening mu4e
  (setq mu4e-context-policy 'pick-first)
  ;; Don't ask to quit
  (setq mu4e-confirm-quit nil)
  (setq mu4e-attachment-dir  "~/.mail/.attachments")

  (require 'mu4e-alert)

  (setq mu4e-alert-interesting-mail-query "flag:unread AND maildir:/gmail-main/Inbox")

  (mu4e-alert-enable-mode-line-display)

  (defun refresh-mu4e-alert-mode-line ()
    (interactive)
    (mu4e~proc-kill)
    (async-shell-command "mbsync -a")
    (mu4e-alert-enable-mode-line-display)
    (mu4e-alert-enable-notifications)
  )

  (run-with-timer 0 60 'refresh-mu4e-alert-mode-line)
)

(after! projectile
  (setq projectile-require-project-root nil)
  (setq projectile-project-search-path '("~/projects"))
)

(after! meson-mode
    (add-hook 'meson-mode-hook 'company-mode)
)
