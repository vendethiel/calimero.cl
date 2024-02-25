(in-package :cl-user)
(defpackage :calimero.plugin-sh
  (:use :cl)

  (:import-from :defstar #:defun*)
  (:import-from :uiop)

  (:import-from :calimero.util #:dlambda)
  (:import-from :calimero.myclass #:make@)
  (:import-from :calimero.command #:make-simple-command #:make-nested-command)
  (:import-from :calimero.plugin #:plugin)
  (:import-from :calimero.repl #:repl #:cwd)

  (:export :make-plugin-sh))
(in-package :calimero.plugin-sh)

(defun* cmd-echo ((shell repl) parts)
  (lambda (emit)
    (funcall emit :data (format nil "~{~a~^ ~}~%" parts))
    (dlambda)))

(defun* cmd-cwd ((shell repl) parts)
  (if (not (null parts))
      (error "Cannot have arguments to `cwd'~%"))
  (lambda (emit)
    (funcall emit :data (format nil "~a~%" (cwd shell)))
    (dlambda)))

;; XXX DSL like
;(with-input (emit emit-data)
;  (emit-data "NYI")
;  ())

(defun* list-directory ((dir pathname) emit)
  (dolist (file (uiop:directory-files dir))
    (funcall emit :data file)))

(defun* cmd-ls ((shell repl) parts)
  (lambda (emit)
    (if (null parts)
       (list-directory (cwd shell) emit)
       (funcall emit :data "NYI~%"))
    (dlambda)))

(defun* cmd-cat ((shell repl) parts)
  (lambda (emit)
    (dlambda
     ((:data data) (funcall emit :data data)))))

(defun make-handler ()
  (let ((subcommands
         (list
          (make-simple-command "echo" #'cmd-echo)
          (make-simple-command "cwd"  #'cmd-cwd)
          (make-simple-command "ls"   #'cmd-ls)
          (make-simple-command "cat"  #'cmd-cat))))
    (make-nested-command "sh commands" subcommands)))

(defun make-plugin-sh ()
  (make-instance 'plugin
                 :handler (make-handler)
                 :name "calimero.sh"
                 :description "Calimero's Bash-like commands plugin"))
