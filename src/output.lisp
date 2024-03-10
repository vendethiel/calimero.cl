(in-package :cl-user)
(defpackage :calimero.output
  (:use :cl)

  (:import-from :trivia #:match)
  (:import-from :serapeum #:push-end)

  (:import-from :calimero.data #:string-data #:array-data #:string-values)

  (:export :make-output))
(in-package :calimero.output)

(defun print-arrays (arrays)
  ;; TODO compute column size
  ;; TODO not only string values
  (dolist (array arrays)
    (format t "[~{~a~^ | ~}]~%" (string-values array))))

(defun make-output ()
    (let (cur-array)
      (lambda (&rest xs)
        (match xs
          ((list :emit (string-data :value s))
           (format t "~a~%" s))

          ((list :emit (array-data :elements e))
           (cond
             ((null cur-array)
              (setf cur-array (list (length e) (list e))))

             ((= (car cur-array) (length e))
              (push-end e (cadr cur-array)))

             (t
              (print-arrays (cadr cur-array))
              (setf cur-array nil))))

          ((list :done)
           (when cur-array
             (print-arrays (cadr cur-array))))))))
