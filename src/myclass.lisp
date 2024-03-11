(in-package :cl-user)
(defpackage :calimero.myclass
  (:use :cl)

  (:import-from :alexandria #:alist-hash-table #:with-gensyms)
  (:import-from :serapeum #:lret)
  (:import-from :nclasses #:define-class)

  (:import-from :calimero.util #:hash-table-merge-alist))
(in-package :calimero.myclass)

(cl-reexport:reexport-from :nclasses
                           :include
                           '(:make*
                             :defcondition*))

(defmacro defclass* (name supers slots &rest options)
  "`nclasses:define-class' with automatic types and always-dashed predicates."
  `(nclasses:define-class ,name ,supers ,slots
                          ,@(append
                             '((:automatic-types-p t)
                               (:export-accessor-names-p t)
                               (:export-predicate-name-p t)
                               (:predicate-name-transformer 'nclasses:always-dashed-predicate-name-transformer))
                             options)))

(defun make-keyword (name) (values (intern (string-upcase name) "KEYWORD")))

(defmacro make@ (class &body slots)
  `(make-instance ,class
                  ,@(mapcan (lambda (slot)
                              (if (consp slot)
                                  ; TODO check if it's if/when/unless or something
                                  (mapcan (lambda (w) (list (make-keyword w) w))
                                          slot)
                                  (list slot)))
                            slots)))

(define-method-combination ahashmap (&optional (order ':most-specific-first))
  ((around (:around))
   (primary (ahashmap) :order order :required t))
  (let ((form (if (rest primary)
                  (with-gensyms (table)
                    `(lret ((,table (make-hash-table)))
                       ,@(mapcar (lambda (method)
                                   `(hash-table-merge-alist ,table (call-method ,method)))
                                 primary)))
                  `(alist-hash-table (call-method ,(first primary))))))
    (if around
        `(call-method ,(first around)
                      (,@(rest around)
                       (make-method ,form)))
        form)))

(export '(defclass* make@ ahashmap))
