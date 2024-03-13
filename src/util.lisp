(in-package :cl-user)
(defpackage :calimero.util
  (:use :cl)

  (:import-from :alexandria #:with-gensyms #:destructuring-case)
  (:import-from :serapeum #:find-keyword)

  (:export #:dlambda #:delambda
           #:make-upcase-keyword
           #:hash-table-merge-alist))
(in-package :calimero.util)

;; XXX use serapeum:merge-tables + alexandria:alist-hash-table? (though that copies)
(defun hash-table-merge-alist (table alist)
  (dolist (cons alist)
    (setf (gethash (car cons) table) (cdr cons)))
  table)

(defun make-upcase-keyword (kw)
  (find-keyword (string-upcase kw)))

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
