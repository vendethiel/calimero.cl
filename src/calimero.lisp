(in-package :cl-user)
(defpackage :calimero
  (:use :cl)
  (:import-from :calimero.repl #:start-repl)
  (:export #:main))
(in-package :calimero)

(defun help ()
  (format t "~&Usage:

  calimero~&"))

(defun %main (argv)
  "Parse CLI args."
  (when (member "-h" argv :test #'equal)
    ;; To properly parse command line arguments, use a third-party library such as
    ;; clingon, unix-opts, defmain, adopt… when needed.
    (help)
    (uiop:quit))
  (start-repl))

(defun main ()
  "Entry point for the executable.
  Reads command line arguments."
  ;; uiop:command-line-arguments returns a list of arguments (sans the script name).
  ;; We defer the work of parsing to %main because we call it also from the Roswell script.
  (%main (uiop:command-line-arguments)))
