(in-package :cl-user)
(defpackage :calimero.command
  (:use :cl)

  (:import-from :alexandria #:if-let)

  (:import-from :calimero.util #:dlambda)
  (:import-from :calimero.myclass #:defclass* #:make@)
  (:import-from :calimero.data #:string-data #:string-value)

  (:export :command
           :handle-command
           :make-dynamic-command
           :make-nested-command
           :make-prefix-command
           :make-simple-command))
(in-package :calimero.command)

(defclass* command ()
  ((name :type string)))

(defclass* dynamic-command (command)
  ((handler)))

(defun make-dynamic-command (name handler)
  (make@ 'dynamic-command (name handler)))

(defclass* nested-command (command)
  ((subcommands :type (proper-list command))))

(defun make-nested-command (name subcommands)
  (make@ 'nested-command (name subcommands)))

(defclass* prefix-command (command)
  ((prefix :type string)
   (subcommand :type command)))

(defun make-prefix-command (name prefix subcommand)
  (make@ 'prefix-command (name prefix subcommand)))

(defun make-simple-command (prefix handler)
  (let ((subcommand (make@ 'dynamic-command (handler))))
    (make@ 'prefix-command (prefix subcommand))))

(defgeneric handle-command (command shell args)
  (:documentation "Try to handle a command. Returns t if handled, nil if not handled.")

  (:method ((command dynamic-command) shell args)
    (funcall (handler command) shell args))

  (:method ((command nested-command) shell args)
    (dolist (subcommand (subcommands command))
      (if-let (handled (handle-command subcommand shell args))
          (return handled))))

  (:method ((command prefix-command) shell args)
    (let ((fst (car args)))
      (if (and (typep fst 'string-data) (string-equal (prefix command) (string-value fst)))
          (handle-command (subcommand command) shell (cdr args))))))
