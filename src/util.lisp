(in-package :cl-user)
(defpackage :calimero.util
  (:use :cl)

  (:import-from :alexandria #:with-gensyms #:destructuring-case)

  (:export #:dlambda #:delambda))
(in-package :calimero.util)

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
