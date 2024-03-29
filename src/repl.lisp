(in-package :cl-user)
(uiop:define-package :calimero.repl
  (:import-from :trivial-types #:proper-list) ; alexandria:proper-list is more for debug purposes
  (:import-from :alexandria #:if-let)
  (:import-from :defstar #:defun*)

  (:import-from :calimero.oo #:defclass* #:defcondition*)
  (:import-from :calimero.data #:string->data #:string-value)
  (:import-from :calimero.error #:calimero-error)
  (:import-from :calimero.command #:handle-command)
  (:import-from :calimero.parse #:parse-line)
  (:import-from :calimero.output #:make-output)
  (:import-from :calimero.plugin #:plugin #:handler)

  (:export #:repl))
(in-package :calimero.repl)

;(use-syntax punch-syntax)

(defclass* repl ()
  ((plugins nil :type (proper-list plugin))
   (cwd :type pathname)))

(defcondition* command-not-found (calimero-error)
  ())

;;(defmethod error-components ahashmap ((err command-not-found))
;;  )

; XXX stolen from the cookbook, try to see if that's available somewhere else.
(defun prompt-new-value (prompt)
  (format *query-io* prompt) ;; *query-io*: the special stream to make user queries.
  (force-output *query-io*)  ;; Ensure the user sees what he types.
  (list (read *query-io*)))  ;; We must return a list.

(defun* feed ((shell repl) (line string))
  (let* ((instrs (parse-line line))
         (commands (mapcar
                    (lambda (parts)
                      (restart-case
                          (block handled
                            (dolist (plugin (plugins shell))
                              (if-let (command (handle-command (handler plugin) shell parts))
                                      (return-from handled command)))
                            (error 'command-not-found))
                        (empty-forwarding-command ()
                          :report "Skip this part of the command, act like a forwarding pipe"
                          (lambda (emit)
                            (lambda (&rest r)
                              (apply emit r))))
                        (compile-command-instead (value)
                          :report "Manual command definition"
                          :interactive (lambda ()
                                         (prompt-new-value "Please enter the code for the command: "))
                          (eval value))))
                    instrs))
         (pipe (reduce #'funcall commands :initial-value (make-output) :from-end t)))
    (funcall pipe :done)))
