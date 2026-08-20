;;; modulefile-mode.el --- Modulefile editing commands for Emacs -*- lexical-binding: t; -*-

;; Author: Laurent Besson <laurent.42.besson@gmail.com>
;; Maintainer: Laurent Besson <laurent.42.besson@gmail.com>
;; Created: June 12, 2025
;; Version: 1.0
;; Tested with: ((emacs "24")
;; Keywords: Modules, modulefile
;; URL: https://modules.readthedocs.io/en/latest/index.html

;; This file is part of Environment Modules

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 2 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; modulefile-mode is a major mode for highlighting modulefile syntax.
;; It derives from tcl-mode as modulefile is based on this language.
;; It colorizes modulefile commands and variables:
;; * font-lock-keyword-face is used to colorize Modulefile commands
;; * font-lock-preprocessor-face is used to colorize Modulefile specific
;;   variables (these variables will not be highlighted the same way as
;;   regular Tcl variables)

;;; Installation:

;; Copy this file into your Emacs package search directory and add the
;; following lines to your Emacs configuration file:

;; ;; Use first line of file to recognize file type
;; (add-to-list 'magic-mode-alist '("#%Module" . modulefile-mode))
;; (autoload 'modulefile-mode "modulefile-mode"
;;    "Major mode for editing Modulefile scripts." t)

;;; Code:

(define-derived-mode modulefile-mode tcl-mode "Modulefile"
  "Major mode for editing Modulefile scripts."
  (font-lock-add-keywords 'modulefile-mode
    '(("\\<\\(add-property\\|always-load\\|append-path\\|chdir\\|complete\\|conflict\\|depends-on-any\\|depends-on\\|extensions\\|family\\|getenv\\|getvariant\\|haveDynamicMPATH\\|hide-modulefile\\|hide-version\\|is-avail\\|is-loaded\\|is-saved\\|is-used\\|lsb-release\\|module-alias\\|module-forbid\\|module-help\\|module-hide\\|module-info\\|module-tag\\|module-version\\|module-virtual\\|module-warn\\|module-whatis\\|module\\|modulepath-ignore\\|modulepath-label\\|prepend-path\\|prereq-all\\|prereq-any\\|prereq\\|provide\\|pushenv\\|remove-path\\|reportError\\|reportWarning\\|require-fullname\\|set-alias\\|set-function\\|setenv\\|source-sh\\|system\\|uname\\|uncomplete\\|unset-alias\\|unset-function\\|unsetenv\\|variant\\|versioncmp\\|x-resource\\)\\>" . font-lock-keyword-face))
  )
  (font-lock-add-keywords 'modulefile-mode
    '(("\\<\\(ModulesVersion\\|ModulesCurrentModulefile\\|ModuleToolVersion\\|ModuleVariant\\|ModuleTool\\)\\>" . font-lock-preprocessor-face))
  )
)

(provide 'modulefile-mode)
