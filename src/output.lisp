(in-package :cl-user)
(defpackage :calimero.output
  (:use :cl)

  (:import-from :trivia #:match)
  (:import-from :serapeum #:push-end #:op #:drop-suffix #:nest)
  (:import-from :defstar #:defun*)
  (:import-from :metabang-bind #:bind)
  (:import-from :str #:repeat #:replace-all #:lines)

  (:import-from :calimero.data
                #:data
                #:string-data #:string-value
                #:number-data
                #:array-data #:array-elements)

  (:export :make-output))
(in-package :calimero.output)

(defun transpose (xs)
  (apply #'mapcar #'list xs))

(defun print-arrays (s arrays)
  "Generates a format string that pads to the longest of each column, then prints all the arrays using that format string."
  (bind (((:flet max-length (&rest cells))
          (loop :for cell :in cells
                :maximizing (loop :for line :in (lines cell)
                                  :maximizing (length line))))
         ((:flet lines-upto (n))
          (lambda (cell)
            (loop :repeat (1+ n)
                  :for cur := (lines cell)
                    :then (cdr cur)
                  :collect (or (car cur) ""))))

         (strings (mapcar (op (mapcar #'stringify _)) arrays))

         (lengths (apply #'mapcar #'max-length strings))
         (control (format nil "|~~{~{~~~da~^|~}~~}|~~%" lengths))

         (sep-control (replace-all "|" "+" control))
         (sep (format nil sep-control (mapcar (op (repeat _ "-")) lengths))))

    (dolist (xs strings)
      (let* ((newline-counts (mapcar (op (count #\Newline _)) xs))
             (max-newlines (reduce #'max newline-counts))
             (padded (mapcar (lines-upto max-newlines) xs))
             (lines (transpose padded)))
        (write-string sep s)
        (dolist (line lines)
          (format s control line))))
    (write-string sep s)))

;; XXX maybe `make-output-to' should receive more "formal" data,
;;     and we should have an adapter so that it accepts :emit/:done from a pipe?
(defun output-array-elements (xs)
  (nest
   (drop-suffix '(#\Newline))
   (with-output-to-string (s))
   (loop :with output = (make-output-to s)
         :for x :in xs
         :do (funcall output :emit x)
         :finally (funcall output :done))))

(defun* stringify (value)
  :returns string
  (match value
    ((string-data :value s) s)
    ((number-data :value n) (write-to-string n))
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
