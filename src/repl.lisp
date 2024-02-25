(in-package :cl-user)
(defpackage :calimero.repl
  (:use :cl)

  (:import-from :trivial-types #:proper-list) ; alexandria:proper-list is more for debug purposes
  (:import-from :alexandria #:if-let)
  (:import-from :defstar #:defun*)

  (:import-from :calimero.myclass #:defclass*)
  (:import-from :calimero.command #:handle-command)
  (:import-from :calimero.plugin #:plugin #:handler)

  (:export #:repl))
(in-package :calimero.repl)

(cl-punch:enable-punch-syntax)
; TODO defstar:*use-closer-mop?*

(defclass* repl ()
  ((plugins nil :type (proper-list plugin))
   (cwd :type pathname)))

; TODO proper parsing
(defun* parse-line ((line string))
  (:returns (proper-list (proper-list string)))
  (mapcar ^(str:split " " (str:trim _) :omit-nulls t)
          (str:split "|" line)))

(defun* feed ((shell repl) (line string))
  (let* ((instrs (parse-line line))
         (output (lambda (&rest xs) (format t "output: ~{~a~^, ~}~%" xs))) ; TODO (:data value)
         (commands (mapcar
                    (lambda (parts)
                      (block handled
                        (dolist (plugin (plugins shell))
                          (if-let (command (handle-command (handler plugin) shell parts))
                                  (return-from handled command)))
                        (error "No handler found :(~%"))) ;; TODO signal condition
                    instrs))
         (pipe (reduce #'funcall commands :initial-value output :from-end t)))
    (funcall pipe :done)))
