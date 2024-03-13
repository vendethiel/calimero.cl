(in-package :cl-user)
(defpackage :calimero.output
  (:use :cl)

  (:import-from :trivia #:match)
  (:import-from :serapeum #:push-end)
  (:import-from :metabang-bind #:bind)

  (:import-from :calimero.data
                #:string-data #:string-values
                #:number-data
                #:array-data)

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
  (bind (cur-array
         ((:flet fits-array (e))
          (or (null cur-array)
              (= (car cur-array) (length e))))
         ((:flet add-to-array (e))
          (if cur-array
              (push-end e (cadr cur-array))
              (setf cur-array (list (length e) (list e)))))
         ((:flet print-flush-array ())
          (when cur-array
            (print-arrays (cadr cur-array))
            (setf cur-array nil)))

         cur-coll
         ((:flet fits-coll (e))
          nil)
         ((:flet add-to-coll (e))
          (when cur-coll))
         ((:flet print-flush-coll ())
          (when cur-coll

            (setf cur-coll nil)))

         ((:flet print-flush ())
          (print-flush-array)
          (print-flush-coll)))
    (lambda (&rest xs)
      (match xs
        ((list :emit (string-data :value s))
         (print-flush)
         (format t "~a~%" s))

        ((list :emit (number-data :value n))
         (print-flush)
         (format t "~d~%" n))

        ((list :emit (array-data :elements e))
         (cond
           ((fits-array e)
            (add-to-array e))

           (t
            ;; print and start a new array with the new size
            (print-flush)
            (add-to-array e))))

        ((list :done)
         (print-flush))))))
