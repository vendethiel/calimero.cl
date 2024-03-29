(in-package :cl-user)
(uiop:define-package :calimero.plugin-builtins
  (:import-from :calimero.error )
  (:import-from :calimero.repl #:repl)
  (:import-from :calimero.plugin #:plugin)
  (:import-from :calimero.command
                #:make-prefix-command #:make-nested-command)
  (:import-from :calimero.plugin-builtins.array #:make-array-builtins)
  (:import-from :calimero.plugin-builtins.table #:make-table-builtins)

  (:export :make-plugin-builtins))
(in-package :calimero.plugin-builtins)

(defun make-handler ()
  (let ((subcommands
          (list
           (make-prefix-command "array commands" "array" (make-array-builtins))
           (make-prefix-command "table commands" "table" (make-table-builtins)))))
    (make-nested-command "builtin commands" subcommands)))

(defun make-plugin-builtins ()
  (make-instance 'plugin
                 :handler (make-handler)
                 :name "calimero builtins"
                 :description "Calimero builtins"))
