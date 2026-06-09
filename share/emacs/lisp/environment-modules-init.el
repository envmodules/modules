;;; environment-modules-init.el --- Autoload modulefile-mode  -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; Activate modulefile-mode.  Use first line of file to recognize file type.

;;; Code:

(add-to-list 'magic-mode-alist '("#%Module" . modulefile-mode))

(autoload 'modulefile-mode "modulefile-mode"
  "Major mode for editing Modulefile scripts." t)

;;; environment-modules-init.el ends here
