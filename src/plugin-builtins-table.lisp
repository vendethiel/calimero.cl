(in-package :cl-user)
(defpackage :calimero.plugin-builtins.table
  (:use :cl)

  (:import-from :serapeum #:op)
  (:import-from :defstar #:defun*)

  (:import-from :calimero.data
                #:string-data #:string-value
                #:array-data
                #:kv->data)
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

(defun make-table-builtins ()
  (let ((subcommands
          (list
           (make-simple-command "with-keys" #'cmd-with-keys))))
    (make-nested-command "table commands" subcommands)))
