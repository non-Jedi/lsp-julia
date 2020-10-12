;;; test-lsp-julia.el --- tests for lsp-julia -*- lexical-binding: t; -*-

(require 'ert)
(require 'lsp-julia)

(ert-deftest lsp-julia-files-and-cmd-test ()
  (should (and (f-exists? lsp-julia-package-dir)
	       (not (eq (executable-find "julia") nil))
	       )))

(ert-deftest lsp-julia-server-test ()
  (find-file "./tests/sample.jl")
  (should (equal (lsp-buffer-language) "julia")))
;;; test-lsp-julia.el ends here
