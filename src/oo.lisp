(in-package :cl-user)
(uiop:define-package :calimero.oo
  (:import-from :alexandria #:alist-hash-table #:with-gensyms)
  (:import-from :serapeum #:lret)
  (:import-from :nclasses #:define-class)

  (:import-from :calimero.util #:hash-table-merge-alist))
(in-package :calimero.oo)

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

;; XXX use serapeum:merge-tables?
;; XXX copy the :before/:after impl from https://github.com/sbcl/specializable/blob/a08048ce874a2a8c58e4735d88de3bf3da0de052/src/accept-specializer/accept-specializer.lisp#L225-L229?
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

;; XXX phashmap using serapeum:pairhash?

(export '(defclass* make@ ahashmap))
