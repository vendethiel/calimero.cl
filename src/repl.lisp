(in-package :cl-user)
(defpackage :calimero.repl
  (:use :cl)

  (:import-from :defstar #:defun*)
  (:import-from :metabang.bind #:bind)
  (:import-from :trivial-types #:proper-list) ; XXX alexandria:proper-list?

  (:import-from :calimero.myclass #:defclass* #:make@)
  (:import-from :calimero.command #:handle-command)
  (:import-from :calimero.plugin #:plugin #:handler)
  (:import-from :calimero.plugin-sh #:make-plugin-sh)

  (:export #:start-repl))
(in-package :calimero.repl)

; cl-punch:enable-punch-syntax
; TODO defstar:*use-closer-mop?*

(defclass* repl ()
  ((plugins nil :type (proper-list plugin))))

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

(defun start-repl ()
  (let* ((plugins (list (make-plugin-sh))) ; TODO dynamic plugin loading
         (shell (make@ 'repl (plugins))))
    (block loop
      (do ((i 0 (1+ i)))
          (nil)
        (format t "user:~a $ " i)
        (force-output)
        (multiple-value-bind (line end) (read-line *standard-input* nil)
          (if end
              (return-from loop)
              (progn
                (feed shell line)
                (force-output))))))))
