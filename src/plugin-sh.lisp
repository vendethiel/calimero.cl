(in-package :cl-user)
(defpackage :calimero.plugin-sh
  (:use :cl)

  (:import-from :calimero.myclass #:make@)

  (:import-from :calimero.command #:make-simple-command #:make-nested-command)
  (:import-from :calimero.plugin #:plugin)

  (:export :make-plugin-sh))
(in-package :calimero.plugin-sh)

(defun echo (shell parts)
  (format t "~{~a~^ ~}~%" parts))

(defun make-handler ()
  (let ((subcommands
         (list
          (make-simple-command "echo" #'echo))))
    (make-nested-command "sh commands" subcommands)))

(defun make-plugin-sh ()
  (make-instance 'plugin
                 :handler (make-handler)
                 :name "calimero.sh"
                 :description "Calimero's Bash-like commands plugin"))
