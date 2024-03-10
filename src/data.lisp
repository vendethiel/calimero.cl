(in-package :cl-user)
(defpackage :calimero.data
  (:use :cl)

  (:import-from :defstar :defun*)

  (:import-from :calimero.myclass #:defclass* #:make@ #:defcondition*)

  (:export :data
           :string-data :string->data :string-value :string-values
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

(defun string-values (parts)
  (mapcar (lambda (part)
            (if (typep part 'string-data)
                (string-value part)
                (error 'data-error :message "Echo can only print string(s)")))
          parts))


(defclass* array-data (data)
  ((elements :reader array-elements)))

(defun* array->data ((elements cons))
  :returns 'array-data
  (make@ 'array-data (elements)))

(defclass* table-data (data)
  ((pairs :reader table-pairs)))

(defun* table-keys ((table table-data))
  nil)

(defun* table-values ((table table-data))
  nil)
