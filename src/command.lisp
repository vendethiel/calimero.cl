33M(in-package :cl-user)
(defpackage :calimero.command
  (:use :cl)

  (:import-from :alexandria #:if-let)

  (:import-from :calimero.util #:dlambda)
  (:import-from :calimero.myclass #:defclass* #:make@)

  (:export :command
           :handle-command
           :make-dynamic-command
           :make-nested-command
           :make-prefix-command
           :make-simple-command))
(in-package :calimero.command)

(defclass* command ()
  ((name :type string)))

(defgeneric handle-command (command shell args)
  (:documentation "Try to handle a command. Returns t if handled, nil if not handled."))

(defclass* dynamic-command (command)
  ((handler)))

(defun make-dynamic-command (name handler)
  (make@ 'dynamic-command (name handler)))

(defmethod handle-command ((command dynamic-command) shell args)
  (funcall (handler command) shell args))

(defclass* nested-command (command)
  ((subcommands :type (proper-list command))))

(defun make-nested-command (name subcommands)
  (make@ 'nested-command (name subcommands)))

(defmethod handle-command ((command nested-command) shell args)
  (dolist (subcommand (subcommands command))
    (if-let (handled (handle-command subcommand shell args))
            (return handled))))

(defclass* prefix-command (command)
  ((prefix :type string)
   (subcommand :type command)))

(defun make-prefix-command (name prefix subcommand)
  (make@ 'prefix-command (name prefix subcommand)))

(defmethod handle-command ((command prefix-command) shell args)
  (if (string-equal (prefix command) (car args))
      (handle-command (subcommand command) shell (cdr args))))

(defun make-simple-command (prefix handler)
  (let ((subcommand (make@ 'dynamic-command (handler))))
    (make@ 'prefix-command (prefix subcommand))))
