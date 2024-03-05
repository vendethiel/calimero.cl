(in-package :cl-user)
(defpackage :calimero.plugin-sh
  (:use :cl)

  ;(:import-from :cl-syntax #:use-syntax)
  ;(:import-from :cl-punch #:punch-syntax)
  (:import-from :defstar #:defun*)
  (:import-from :alexandria-2 #:line-up-last)
  (:import-from :uiop)

  (:import-from :calimero.util #:dlambda)
  (:import-from :calimero.myclass #:make@)
  (:import-from :calimero.data #:string->data #:string-values)
  (:import-from :calimero.command #:make-simple-command #:make-nested-command)
  (:import-from :calimero.plugin #:plugin)
  (:import-from :calimero.repl #:repl #:cwd)

  (:export :make-plugin-sh))
(in-package :calimero.plugin-sh)

(defun* cmd-echo ((shell repl) parts)
  (let ((parts-string (string-values parts)))
    (lambda (emit)
      (line-up-last
       parts
       string-values
       (format nil "~{~a~^ ~}")
       string->data
       (funcall emit :data))
      (dlambda))))

(defun* cmd-cwd ((shell repl) parts)
  (if (not (null parts))
      (error "Cannot have arguments to `cwd'~%"))
  (lambda (emit)
    (line-up-last
     shell
     cwd
     namestring
     string->data
     (funcall emit :data))
    (dlambda)))

(defun* list-directory ((dir pathname) emit)
  (dolist (file (uiop:directory-files dir))
    (line-up-last
     file
     namestring
     string->data
     (funcall emit :data))))

(defun* cmd-ls ((shell repl) parts)
  (lambda (emit)
    (if (null parts)
       (list-directory (cwd shell) emit)
       (funcall emit :data (string->data "NYI")))
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
