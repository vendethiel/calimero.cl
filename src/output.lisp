(in-package :cl-user)
(uiop:define-package :calimero.output
  (:import-from :trivia #:match)
  (:import-from :serapeum #:push-end #:op #:drop-suffix #:nest)
  (:import-from :defstar #:defun*)
  (:import-from :metabang-bind #:bind)
  (:import-from :str #:repeat #:replace-all #:lines)

  (:import-from :calimero.oo #:defcondition*)
  (:import-from :calimero.data
                #:data
                #:string-data
                #:number-data
                #:array-data #:array-elements
                #:table-data)
  (:import-from :calimero.error #:calimero-error)

  (:export #:make-output))
(in-package :calimero.output)

(defun transpose (xs)
  (apply #'mapcar #'list xs))

(defun print-arrays (s arrays &key header)
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

         ((:flet make-control (fst mid lst))
          (format nil (concatenate 'string fst "~~{~{~~~da~^" mid "~}~~}" lst "~~%") lengths))

         ((:flet make-line (fst mid lst rep))
          (format nil
                  (make-control fst mid lst)
                  (mapcar (op (repeat _ rep)) lengths)))

         (table-control (make-control "┃" "┃" "┃"))
         (array-control (make-control "│" "│" "│"))

         (table-header-start (make-line "┏" "┬" "┓" "━"))
         (table-header-end (make-line "┡" "╇" "┩" "━"))
         (array-header (make-line "╭" "┰" "╮" "─"))
         (array-sep (make-line "├" "┼" "┤" "─"))
         (array-end (make-line "╰" "┴" "╯" "─")))

    (if header
        (progn
          (write-string table-header-start s)
          (format s table-control header)
          (write-string table-header-end s))
        (write-string array-header s))
    (let ((cur 0))
      (dolist (xs strings)
        (let* ((newline-counts (mapcar (op (count #\Newline _)) xs))
               (max-newlines (reduce #'max newline-counts))
               (padded (mapcar (lines-upto max-newlines) xs))
               (lines (transpose padded)))
          (dolist (line lines)
            (format s array-control line)))
        (incf cur)
        (if (= cur (length strings))
          (write-string array-end s)
          (write-string array-sep s))))))

(defun output-array-elements (xs)
  ;; XXX should this *always* print an array?
  ;;     seems like pretty, but less ambiguous
  ;;     it'd be `(print-arrays s (list xs))', similar to `output-kv'.
  (nest
   (drop-suffix '(#\Newline))
   (with-output-to-string (s))
   (loop :with output = (make-output-to s)
         :for x :in xs
         :do (funcall output :emit x)
         :finally (funcall output :done))))

(defun output-kv (k v)
  (nest
   (drop-suffix '(#\Newline))
   (with-output-to-string (s))
   (print-arrays s (list v) :header k)))

(defun* stringify (value)
  :returns 'string
  (match value
    ((string-data :value s) s)
    ((number-data :value n) (write-to-string n))
    ((array-data :elements xs) (output-array-elements xs))
    ((table-data :keys k :values v) (output-kv k v))))

;; XXX move this somewhere else, so that all commands can be wrapped in a check like this
;;     i.e. when we're folding all commands to build the pipeline
(defcondition* closed-pipe-error (calimero-error)
  ())

;; XXX maybe `make-output-to' should receive more "formal" data,
;;     and we should have an adapter so that it accepts :emit/:done from a pipe?
(defun make-output-to (target)
  (bind (cur-array
         cur-coll
         is-done

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

         ((:flet fits-coll (k))
          (or (null cur-coll)
              (equal (car cur-coll) k)))
         ((:flet add-to-coll (k v))
          (if cur-coll
            (push-end v (cadr cur-coll))
            (setf cur-coll (list k (list v)))))
         ((:flet print-flush-coll ())
          (when cur-coll
            (print-arrays target (cadr cur-coll) :header (car cur-coll))
            (setf cur-coll nil)))

         ((:flet print-flush ())
          (print-flush-array)
          (print-flush-coll)))
    (lambda (&rest xs)
      (when is-done
        (error 'closed-pipe-error))
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

        ((list :emit (table-data :keys keys :values values))
         (cond
           ((fits-coll keys)
            (add-to-coll keys values))

           (t
            ;; print and start a new coll with the new table
            (print-flush)
            (add-to-coll keys values))))

        ((list :done)
         (setq is-done t)
         (print-flush))))))

(defun make-output ()
  (make-output-to t))
