(in-package :cl-user)
(defpackage :calimero.plugin-builtins
  (:use :cl)

  (:import-from :defstar #:defun*)
  (:import-from :serapeum #:push-end)

  (:import-from :calimero.plugin #:plugin)
  (:import-from :calimero.data #:array->data #:array-data)
  (:import-from :calimero.command
                #:make-simple-command #:make-nested-command #:make-prefix-command
                #:cmd #:cmd_)
  (:import-from :calimero.repl #:repl)

  (:export :make-plugin-builtins))
(in-package :calimero.plugin-builtins)

(defun* cmd-of ((shell repl) parts)
  (cmd_ (emit)
    (emit (array->data parts))))

(defun* cmd-take ((shell repl) parts)
  ;; TODO check args
  (let ((limit 3))
    (cmd (emit)
      (((list :emit (array-data :elements xs))
        (emit (array->data (subseq xs 0 limit))))))))

(defun* cmd-drop ((shell repl) parts)
  ;; TODO check args
  (let ((limit 3))
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

(defun* cmd-batch ((shell repl) parts)
  "Batch elements. At :done, produces a partial array."
  ;; TODO check args
  (let ((limit 3)
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

(defun* cmd-group ((shell repl) parts)
  "Batch elements. Discards leftover elements."
  ;; TODO check args
  (let ((limit 3)
        xs)
    (cmd (emit)
      (((list :emit data)
        (push-end data xs)
        (when (>= (length xs) limit)
          (emit (array->data xs))
          (setf xs nil)))))))

(defun make-array-commands ()
  (let ((subcommands
          (list
           (make-simple-command "of"     #'cmd-of)
           (make-simple-command "take"   #'cmd-take)
           (make-simple-command "drop"   #'cmd-drop)
           (make-simple-command "batch"  #'cmd-batch)
           (make-simple-command "group"  #'cmd-group)
           (make-simple-command "spread" #'cmd-spread)
           (make-simple-command "gather" #'cmd-gather))))
    (make-nested-command "array commands" subcommands)))

(defun make-handler ()
  (let ((subcommands
          (list
           (make-prefix-command "array commands" "array" (make-array-commands)))))
    (make-nested-command "builtin commands" subcommands)))

(defun make-plugin-builtins ()
  (make-instance 'plugin
                 :handler (make-handler)
                 :name "calimero builtins"
                 :description "Calimero builtins"))
