(in-package :cl-user)
(defpackage :calimero.data
  (:use :cl)

  (:import-from :defstar :defun*)
  (:import-from :trivial-types #:proper-list)

  (:import-from :calimero.myclass #:defclass* #:make@ #:defcondition*)

  (:export :data
           :string-data :string->data :string-value
           :number-data :number->data :number-value
           :array-data :array->data :array-elements))
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
  ((pairs :reader table-pairs)))

(defun* table-keys ((table table-data))
  nil)

(defun* table-values ((table table-data))
  nil)
