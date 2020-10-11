;;; test.el --- tests for elfeed -*- lexical-binding: t; -*-

(require 'ert)

(ert-deftest test-simple ()
  (should (equal 4 (/ 8 2))))
