(in-package :cl-user)
(defpackage :calimero.command
  (:use :cl)

  (:import-from :alexandria #:if-let #:with-gensyms #:proper-list-p #:last-elt)
  (:import-from :trivia #:match)
  (:import-from :metabang-bind #:bind)

  (:import-from :calimero.util #:dlambda #:make-upcase-keyword)
  (:import-from :calimero.myclass #:defclass* #:make@ #:defcondition*)
  (:import-from :calimero.data #:string-data #:string-value #:string-values)

  (:export :command
           :handle-command
           :make-dynamic-command
           :make-nested-command
           :make-prefix-command
           :make-simple-command
           :cmd :cmd_
           :command-error :command-specific-error))
(in-package :calimero.command)

(cl-punch:enable-punch-syntax)

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

(defcondition* command-error (error)
  ((message :type string)))

(defcondition* command-specific-error (command-error)
  ((command :type string)))

;; TODO command arity error

(defmacro cmd (syms &body body)
  (if (proper-list-p syms)
      (with-gensyms (fwd args)
        (bind (((:flet sym-to-flet (sym))
                `(,sym (&rest xs) (apply ,fwd ,(make-upcase-keyword sym) xs)))
               (flets (mapcar #'sym-to-flet syms)))
              `(lambda (,fwd)
                 (flet (,@flets)
                   ,@(butlast body)
                   (lambda (&rest ,args)
                     (match ,args
                       ,@(last-elt body)

                       ((list :emit _)
                         nil) ;; If the function didn't handle :emit, explicitly discard it

                       ((list :done)
                        nil) ;; :done is handled specially

                       ((list* _)
                         (apply ,fwd ,args)))

                     ;; the function itself didn't request (done)
                     ;; (one example would be some async code, that would delay its :done)
                     (when (and (equal :done (car ,args))
                                ,(notany ^(string-equal _ "DONE") syms))
                       (funcall ,fwd :done)))))))
              (error 'command-error :message "Proper invocation is `(cmd (names...) ...)'")))

;; Same as cmd, but with an empty match at the end
(defmacro cmd_ (syms &body body)
  `(cmd ,syms ,@body ()))
