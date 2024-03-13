(in-package :cl-user)
(defpackage :calimero.output
  (:use :cl)

  (:import-from :trivia #:match)
  (:import-from :serapeum #:push-end #:op)
  (:import-from :metabang-bind #:bind)
  (:import-from :str #:trim-right)

  (:import-from :calimero.data
                #:data
                #:string-data #:string-value
                #:number-data
                #:array-data #:array-elements)

  (:export :make-output))
(in-package :calimero.output)

(defun print-arrays (s arrays)
  "Generates a format string that pads to the longest of each column, then prints all the arrays using that format string."
  (bind (((:flet max-length (&rest xs))
          (apply #'max (mapcar #'length xs)))
         (strings (mapcar (op (mapcar #'stringify _)) arrays))
         (lengths (apply #'mapcar #'max-length strings))
         (control (format nil "[~~{~{~~~da~^ | ~}~~}]~~%" lengths)))
    (dolist (array strings)
      (format s control array))))

;; XXX maybe `make-output-to' should receive more "formal" data,
;;     and we should have an adapter so that it accepts :emit/:done from a pipe?
(defun output-array-elements (xs)
  (trim-right ;; XXX only trim the last \n
   (with-output-to-string (s)
     (let ((output (make-output-to s)))
       (dolist (e xs)
         (funcall output :emit e))
       (funcall output :done)))))

(defun stringify (value)
  (match value
    ((string-data :value s) s)
    ((number-data :value n) n)
    ((array-data :elements xs) (output-array-elements xs))))

(defun make-output-to (target)
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
            (print-arrays target (cadr cur-array))
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
        ((list :emit (string-data :value x))
         (print-flush)
         (format target "~a~%" x))

        ((list :emit (number-data :value n))
         (print-flush)
         (format target "~d~%" n))

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

(defun make-output ()
  (make-output-to t))
