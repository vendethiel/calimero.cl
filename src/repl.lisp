(in-package :cl-user)
(defpackage :calimero.repl
  (:use :cl)

  (:import-from :trivial-types #:proper-list) ; XXX alexandria:proper-list?
  (:import-from :defstar #:defun*)

  (:import-from :calimero.myclass #:defclass*)
  (:import-from :calimero.command #:handle-command)
  (:import-from :calimero.plugin #:plugin #:handler)

  (:export #:repl))
(in-package :calimero.repl)

; cl-punch:enable-punch-syntax
; TODO defstar:*use-closer-mop?*

(defclass* repl ()
  ((plugins nil :type (proper-list plugin))
   (cwd :type pathname)))

; TODO proper parsing
(defun* parse-line ((line string))
  (:returns (proper-list string))
  (str:split " " line :omit-nulls t))

(defun* feed ((shell repl) (line string))
  (let ((parts (parse-line line)))
    (block handled
      (dolist (plugin (plugins shell))
        (if (handle-command (handler plugin) shell parts)
            (return-from handled)))
      (format t "No handler found :(~%"))))
