(in-package :cl-user)
(defpackage :calimero.output
  (:use :cl)

  (:import-from :trivia #:match)
  (:import-from :serapeum #:push-end)
  (:import-from :metabang-bind #:bind)

  (:import-from :calimero.data #:string-data #:array-data #:string-values)

  (:export :make-output))
(in-package :calimero.output)

;; TODO not only string values
;; TODO should also be able to be on multiple lines
(defun print-arrays (arrays)
  "Generates a format string that pads to the longest of each column, then prints all the arrays using that format string."
  (bind (((:flet max-length (&rest xs)) (apply #'max (mapcar #'length xs)))
         (strings (mapcar #'string-values arrays))
         (lengths (apply #'mapcar #'max-length strings))
         (control (format nil "[~~{~{~~~da~^ | ~}~~}]~~%" lengths)))
    (dolist (array arrays)
      (format t control (string-values array)))))

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
