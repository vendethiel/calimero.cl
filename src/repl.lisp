(in-package :cl-user)
(defpackage :calimero.repl
  (:use :cl :arrow-macros :str)
  (:import-from :defstar #:defun*)
  (:export #:start-repl))
(in-package :calimero.repl)

; cl-punch:enable-punch-syntax

(defun* lolwat ((n real) (d real))
  (:returns (values integer integer))
  1)

(defun start-repl ()
  (->> "hello macros"
    str:upcase
    (format t)))