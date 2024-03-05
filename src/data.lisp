(in-package :cl-user)
(defpackage :calimero.data
  (:use :cl)

  (:import-from :defstar :defun*)

  (:import-from :calimero.myclass #:defclass* #:make@)

  (:export :data
           :string-data :string->data :string-value :string-values))
(in-package :calimero.data)

(defclass* data ()
  ())

(defclass* string-data (data)
  ((value :type string
          :reader string-value)))

(defun* string->data ((value string))
  ;:returns 'string-data ; XXX why does this not work?
  (make@ 'string-data (value)))

(defun string-values (parts)
  (mapcar (lambda (part)
            (if (typep part 'string-data)
                (string-value part)
                (error "Echo can only print string(s)")))
          parts))
