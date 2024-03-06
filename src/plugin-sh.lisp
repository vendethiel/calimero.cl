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
  (:import-from :calimero.command #:make-simple-command #:make-nested-command #:cmd #:cmd_)
  (:import-from :calimero.plugin #:plugin)
  (:import-from :calimero.repl #:repl #:cwd)

  (:export :make-plugin-sh))
(in-package :calimero.plugin-sh)

(defun* cmd-echo ((shell repl) parts)
  (let ((parts-string (string-values parts)))
    (cmd_ (emit)
      (line-up-last
       parts
       string-values
       (format nil "~{~a~^ ~}")
       string->data
       emit))))

(defun* cmd-cwd ((shell repl) parts)
  (if (not (null parts))
      (error "Cannot have arguments to `cwd'~%"))
  (cmd_ (emit)
    (line-up-last
     shell
     cwd
     namestring
     string->data
     emit)))

(defun* list-directory ((dir pathname) emit)
  (dolist (file (uiop:directory-files dir))
    (line-up-last
     file
     namestring
     string->data
     (funcall emit))))

(defun* cmd-ls ((shell repl) parts)
  (cmd_ (emit)
    (if (null parts)
        (list-directory (cwd shell) #'emit)
        (emit (string->data "NYI")))))

(defun* cmd-cat ((shell repl) parts)
  (cmd (emit)
    (((list :data data) (emit data)))))

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
