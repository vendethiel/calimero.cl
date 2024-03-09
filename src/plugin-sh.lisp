(in-package :cl-user)
(defpackage :calimero.plugin-sh
  (:use :cl)

  (:import-from :defstar #:defun*)
  (:import-from :alexandria-2 #:line-up-last)
  (:import-from :uiop)

  (:import-from :calimero.myclass #:make@)
  (:import-from :calimero.data #:string->data #:string-values)
  (:import-from :calimero.command
                #:make-simple-command #:make-nested-command
                #:cmd #:cmd_
                #:command-specific-error)
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
      (error 'command-specific-error
             :command "cwd"
             :message "Cannot have arguments to `cwd'~%"))
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
    (((list :emit data)
      (emit data)))))

(defun* cmd-wc ((shell repl) parts)
  ;; TODO options
  (if (not (null parts))
      (error 'command-specific-error
             :command "wc"
             :message "Cannot have arguments to `wc'~%"))
  (let ((lines 0))
    (cmd (emit)
      (((list :emit data)
        (incf lines))

       ((list :done)
        (line-up-last
         lines
         write-to-string
         string->data
         emit))))))

(defun make-handler ()
  (let ((subcommands
         (list
          (make-simple-command "echo" #'cmd-echo)
          (make-simple-command "cwd"  #'cmd-cwd)
          (make-simple-command "ls"   #'cmd-ls)
          (make-simple-command "cat"  #'cmd-cat)
          (make-simple-command "wc"   #'cmd-wc))))
    (make-nested-command "sh commands" subcommands)))

(defun make-plugin-sh ()
  (make-instance 'plugin
                 :handler (make-handler)
                 :name "calimero.sh"
                 :description "Calimero's Bash-like commands plugin"))
