(in-package :cl-user)
(uiop:define-package :calimero.util
  (:import-from :alexandria #:with-gensyms #:destructuring-case)
  (:import-from :serapeum #:find-keyword)
  (:import-from :named-readtables #:defreadtable)
  (:import-from :cl-punch)
  (:import-from :defstar)

  (:export #:dlambda #:delambda
           #:make-upcase-keyword
           #:hash-table-merge-alist #:syntax))
(in-package :calimero.util)

(defreadtable syntax
    (:merge :modern :interpol-syntax cl-punch::punch-syntax))

;; XXX use serapeum:merge-tables + alexandria:alist-hash-table? (though that copies)
(defun hash-table-merge-alist (table alist)
  (dolist (cons alist)
    (setf (gethash (car cons) table) (cadr cons)))
  table)

(defun make-upcase-keyword (kw)
  (find-keyword (string-upcase kw)))

(setf defstar:*use-closer-mop?* t)

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
                            ; error on unhandled messages
                            ; (if you need to ignore it, just have your own (&rest))
                            (error "No match for this edlambda"))))))
