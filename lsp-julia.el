;;; lsp-julia.el --- Julia support for lsp-mode   -*- lexical-binding: t; -*-

;; Copyright (C) 2017 Martin Wolke, 2018 Adam Beckmeyer, 2019 Guido Kraemer

;; Author: Martin Wolke <vibhavp@gmail.com>
;;         Adam Beckmeyer <adam_git@thebeckmeyers.xyz>
;;         Guido Kraemer <gdkrmr@users.noreply.github.com>
;; Maintainer: Adam Beckmeyer <adam_git@thebeckmeyers.xyz>
;;             Guido Kraemer <gdkrmr@users.noreply.github.com>
;; Keywords: languages, tools
;; Version: 0.2.0
;; Package-Requires: ((emacs "25.1") (lsp-mode "6.0") (julia-mode "0.3"))
;; Keywords: languages, tools
;; URL: https://github.com/non-Jedi/lsp-julia

;;; License:

;; The MIT License (MIT)

;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be included in
;; all copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
;; THE SOFTWARE.

;;; Commentary:

;; This version of lsp-julia requires julia 1.3 to run.
;; Manual installation:

;; (require 'julia-mode)
;; (push "/path/to/lsp-julia" load-path)
;; (require 'lsp-julia)
;; (require 'lsp-mode)
;; ;; Configure lsp + julia
;; (add-hook 'julia-mode-hook #'lsp-mode)
;; (add-hook 'julia-mode-hook #'lsp)


;;; Code:

(require 'lsp-mode)
(require 'find-func)

(defconst lsp-julia--self-path
  (file-name-directory (find-library-name "lsp-julia")))

(defcustom lsp-julia-package-dir (concat lsp-julia--self-path "languageserver")
  "The path where `LanguageServer.jl' and friends are installed.
Set to nil if you want to use the globally installed versions."
  :type 'string
  :group 'lsp-julia)

(defcustom lsp-julia-default-environment "~/.julia/environments/v1.0"
  "The path to the default environment."
  :type 'string
  :group 'lsp-julia)

(defcustom lsp-julia-command "julia"
  "Command to invoke julia with."
  :type 'string
  :group 'lsp-julia)

(defcustom lsp-julia-flags (if lsp-julia-package-dir
                               `(,(concat "--project=" lsp-julia-package-dir)
                                 "--startup-file=no"
                                 "--history-file=no")
                             '("--startup-file=no"
                               "--history-file=no"))
  "List of additional flags to call julia with."
  :type '(repeat (string :tag "argument"))
  :group 'lsp-julia)

(defcustom lsp-julia-timeout 30
  "Time before symbol `lsp-mode' should assume julia just ain't gonna start."
  :type 'number
  :group 'lsp-julia)

(defcustom lsp-julia-default-depot ""
  "The default depot path, used if `JULIA_DEPOT_PATH' is unset."
  :type 'string
  :group 'lsp-julia)

(defun lsp-julia--get-root ()
  "Get the (Julia) project root directory of the current file."
  (let ((dir (locate-dominating-file default-directory "Project.toml")))
    (if dir (expand-file-name dir)
      (expand-file-name lsp-julia-default-environment))))

(defun lsp-julia--get-depot-path ()
  "Get the (Julia) depot path."
  (let ((dp (getenv "JULIA_DEPOT_PATH")))
    (if dp dp lsp-julia-default-depot)))

(defun lsp-julia--rls-command ()
  "The command to lauch the Julia Language Server."
  `(,lsp-julia-command
    ,@lsp-julia-flags
    ,(concat "-e using LanguageServer, Sockets, SymbolServer;"
             " server = LanguageServer.LanguageServerInstance("
             " stdin, stdout, false,"
             " \"" (lsp-julia--get-root) "\","
             " \"" (lsp-julia--get-depot-path) "\");"
             " server.runlinter = true;"
             " run(server);")))

(defconst lsp-julia--handlers
  '(("window/setStatusBusy" .
     (lambda (w _p)))
    ("window/setStatusReady" .
     (lambda(w _p)))))

(lsp-register-client
 (make-lsp-client :new-connection (lsp-stdio-connection 'lsp-julia--rls-command)
                  :major-modes '(julia-mode ess-julia-mode)
                  :server-id 'julia-ls))

(provide 'lsp-julia)
;;; lsp-julia.el ends here
