(in-package :cl-user)
(defpackage :calimero.data
  (:use :cl)

  (:import-from :defstar :defun*)
  (:import-from :trivial-types #:proper-list)

  (:import-from :calimero.myclass #:defclass* #:make@ #:defcondition*)

  (:export :data
           :string-data :string->data :string-value
           :number-data :number->data :number-value
           :array-data :array->data :array-elements
           :table-data :kv->data))
(in-package :calimero.data)

(defclass* data ()
  ())

(defcondition* data-error (error)
  ((message :type string)))

(defclass* string-data (data)
  ((value :type string
          :reader string-value)))

(defun* string->data ((value string))
  :returns 'string-data
  (make@ 'string-data (value)))

(defclass* number-data (data)
  ((value :type number
          :reader number-value)))

(defun* number->data ((value number))
  :returns 'number-data
  (make@ 'number-data (value)))

(defclass* array-data (data)
  ((elements :reader array-elements)))

(defun* array->data ((elements proper-list))
  :returns 'array-data
  (make@ 'array-data (elements)))

(defclass* table-data (data)
  ((keys :reader table-keys :type (proper-list 'string))
   (values :reader table-values :type (proper-list 'data))))

(defun* kv->data ((keys proper-list) (values proper-list))
  :returns 'table-data
  (unless (= (length keys) (length values))
    (error "Table has unmatched keys and values"))
  (make@ 'table-data (keys values)))
