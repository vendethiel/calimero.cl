(in-package :cl-user)
(defpackage :calimero.plugin-sh
  (:use :cl)

  (:import-from :defstar #:defun*)
  (:import-from :uiop)

  (:import-from :calimero.myclass #:make@)
  (:import-from :calimero.command #:make-simple-command #:make-nested-command)
  (:import-from :calimero.plugin #:plugin)
  (:import-from :calimero.repl #:repl #:cwd)

  (:export :make-plugin-sh))
(in-package :calimero.plugin-sh)

(defun* cmd-echo ((shell repl) parts)
  (format t "~{~a~^ ~}~%" parts))

(defun* cmd-cwd ((shell repl) parts)
  (if (not (null parts))
      1) ; TODO error
  (format t "~a~%" (cwd shell)))

(defun* list-directory ((dir pathname))
  (dolist (file (uiop:directory-files dir))
    (format t "~a~&" file)))

(defun* cmd-ls ((shell repl) parts)
  (if (null parts)
      (list-directory (cwd shell))
      (format t "NYI~%")))

(defun make-handler ()
  (let ((subcommands
         (list
          (make-simple-command "echo" #'cmd-echo)
          (make-simple-command "cwd"  #'cmd-cwd)
          (make-simple-command "ls"   #'cmd-ls))))
    (make-nested-command "sh commands" subcommands)))

(defun make-plugin-sh ()
  (make-instance 'plugin
                 :handler (make-handler)
                 :name "calimero.sh"
                 :description "Calimero's Bash-like commands plugin"))
