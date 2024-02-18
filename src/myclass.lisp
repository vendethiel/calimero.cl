(in-package :cl-user)
(defpackage :calimero.myclass
  (:use :cl)

  (:import-from :nclasses #:define-class))
(in-package :calimero.myclass)

(cl-reexport:reexport-from :nclasses
                           :include
                           '(:make*))

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

(defmacro make@ (class slots)
  `(make-instance ,class
                  ,@(mapcan (lambda (slot)
                              (if (consp slot)
                                  ; TODO check if it's if/when/unless or something
                                  slot
                                  (list (make-keyword slot) slot)))
                            slots)))

(export '(defclass* make@))
