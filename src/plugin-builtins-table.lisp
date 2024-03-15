(in-package :cl-user)
(defpackage :calimero.plugin-builtins.table
  (:use :cl)

  (:import-from :serapeum #:op)
  (:import-from :defstar #:defun*)
  (:import-from :trivia #:match)

  (:import-from :calimero.data
                #:string-data #:string-value
                #:array-data
                #:table-data #:kv->data)
  (:import-from :calimero.command
                #:make-simple-command #:make-nested-command
                #:command-specific-error
                #:cmd)
  (:import-from :calimero.repl #:repl)

  (:export :make-table-builtins))
(in-package :calimero.plugin-builtins.table)

(defun* cmd-with-keys ((shell repl) parts)
  (unless (every (op (typep _ 'string-data)) parts)
    (error 'command-specific-error
           :command "table with-keys"
           :message "Table keys can only be strings"))
  (let ((keys (mapcar #'string-value parts)))
    (cmd (emit)
      (((list :emit (array-data :elements values))
        ;; XXX proper error message, for now, kv->data will check for us
        (emit (kv->data keys values)))))))

(defun* cmd-get ((shell repl) parts)
  (let ((key (match parts
               ((list (string-data :value s)) s)
               ((list*) (error 'command-specific-error
                               :command "table get"
                               :message "Single column name expected")))))
    (cmd (emit)
      (((list :emit (table-data :keys keys :values values))
        (let ((idx (position key keys :test #'equal)))
          ;; XXX error if `(null idx)'/`(not idx)'
          (if idx
            (emit (nth idx values)))))))))

(defun make-table-builtins ()
  (let ((subcommands
          (list
           (make-simple-command "get" #'cmd-get)
           (make-simple-command "with-keys" #'cmd-with-keys))))
    (make-nested-command "table commands" subcommands)))
