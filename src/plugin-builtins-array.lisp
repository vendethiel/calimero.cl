(in-package :cl-user)
(defpackage :calimero.plugin-builtins.array
  (:use :cl)

  (:import-from :serapeum #:push-end)
  (:import-from :defstar #:defun*)
  (:import-from :trivia #:match)

  (:import-from :calimero.plugin #:plugin)
  (:import-from :calimero.data #:array->data #:array-data #:number-data)
  (:import-from :calimero.command
                #:make-simple-command #:make-nested-command #:make-prefix-command
                #:command-specific-error
                #:cmd #:cmd_)
  (:import-from :calimero.repl #:repl)

  (:export :make-array-builtins))
(in-package :calimero.plugin-builtins.array)

(defun* single-number-arg (parts &optional cmd)
  (match parts
    ((list (number-data :value n))
     n)

    (_ (when cmd
         (error 'command-specific-error
                :command cmd
                :message (format nil "A single numeric argument is expected. Got: ~{~a~^ ~}" parts))
         (error "TODO generic error")))))

(defun* cmd-of ((shell repl) parts)
  (cmd_ (emit)
    (emit (array->data parts))))

(defun* cmd-take ((shell repl) parts)
  (let ((limit (single-number-arg parts "array take")))
    (cmd (emit)
      (((list :emit (array-data :elements xs))
        (emit (array->data (subseq xs 0 limit))))))))

(defun* cmd-drop ((shell repl) parts)
  (let ((limit (single-number-arg parts "array drop")))
    (cmd (emit)
      (((list :emit (array-data :elements xs))
        (emit (array->data (subseq xs limit))))))))

(defun* cmd-gather ((shell repl) parts)
  (if (not (null parts))
      (error 'command-specific-error
             :command "array gather"
             :message "Cannot have arguments to `array gather'~%"))
  (let (xs)
    (cmd (emit)
      (((list :emit data)
        (push-end data xs))

      ((list :done)
       (emit (array->data xs)))))))

(defun* cmd-spread ((shell repl) parts)
  (if (not (null parts))
      (error 'command-specific-error
             :command "array gather"
             :message "Cannot have arguments to `array gather'~%"))
  (cmd (emit)
    (((list :emit (array-data :elements xs))
      (dolist (x xs)
        (emit x))))))

(defun* cmd-as-batch ((shell repl) parts)
  "Batch elements. Like as-group, but produces a partial array if there are leftover elements."
  (let ((limit (single-number-arg parts "array as-batch"))
        xs)
    (cmd (emit)
      (((list :emit data)
        (push-end data xs)
        (when (>= (length xs) limit)
          (emit (array->data xs))
          (setf xs nil)))

       ((list :done)
        (when xs
          (emit (array->data xs))))))))

(defun* cmd-as-group ((shell repl) parts)
  "Groups elements. Like as-batch, but discards leftover elements."
  (let ((limit (single-number-arg parts "array as-roup"))
        xs)
    (cmd (emit)
      (((list :emit data)
        (push-end data xs)
        (when (>= (length xs) limit)
          (emit (array->data xs))
          (setf xs nil)))))))

(defun make-array-builtins ()
  (let ((subcommands
          (list
           (make-simple-command "of"        #'cmd-of)
           (make-simple-command "take"      #'cmd-take)
           (make-simple-command "drop"      #'cmd-drop)
           (make-simple-command "as-batch"  #'cmd-as-batch)
           (make-simple-command "as-group"  #'cmd-as-group)
           (make-simple-command "spread"    #'cmd-spread)
           (make-simple-command "gather"    #'cmd-gather))))
    (make-nested-command "array commands" subcommands)))
