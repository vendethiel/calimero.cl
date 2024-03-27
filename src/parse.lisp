(in-package :cl-user)
(uiop:define-package :calimero.parse
  (:import-from :defstar #:defun*)

  (:import-from :calimero.data #:data #:string->data #:number->data)

  (:export :parse-line))
(in-package :calimero.parse)

(defun* parse ((part string))
  :returns 'data
  (handler-case
      (number->data (parse-integer part))
    (parse-error ()
      (string->data part))))

; TODO proper parsing
(defun* parse-arguments ((line string))
  (mapcar #'parse
          (str:split " " (str:trim line) :omit-nulls t)))

(defun* parse-line ((line string))
  (mapcar #'parse-arguments (str:split "|" line)))
