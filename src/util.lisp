(in-package :cl-user)
(defpackage :calimero.util
  (:use :cl)

  (:import-from :alexandria #:with-gensyms #:destructuring-case #:make-keyword)

  (:export #:dlambda #:delambda
           #:make-upcase-keyword))
(in-package :calimero.util)

(defun make-upcase-keyword (kw)
  (make-keyword (string-upcase kw)))

; TODO defstar:*use-closer-mop?*

(defmacro dlambda (&body body)
  (with-gensyms ((data "data"))
    `(lambda (&rest ,data)
       (destructuring-case ,data
                           ,@body
                           ((&rest rest)
                            ; ignore unhandled messages
                            ; (if you need to handle it, just have your own (&rest))
                            nil)))))

(defmacro delambda (&body body)
  (with-gensyms ((data "data"))
    `(lambda (&rest ,data)
       (destructuring-case ,data
                           ,@body
                           ((&rest rest)
                            ; ignore unhandled messages
                            ; (if you need to handle it, just have your own (&rest))
                            (error "No match for this edlambda"))))))
