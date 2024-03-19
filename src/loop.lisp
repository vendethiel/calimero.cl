(in-package :cl-user)
(defpackage :calimero.loop
  (:use :cl)

  (:import-from :uiop)

  (:import-from :calimero.oo #:make@)
  (:import-from :calimero.repl #:repl #:feed)
  (:import-from :calimero.plugin-sh #:make-plugin-sh)
  (:import-from :calimero.plugin-builtins #:make-plugin-builtins)

  (:export #:start-repl))
(in-package :calimero.loop)

(defun start-repl ()
  (let* ((plugins (list (make-plugin-sh)
                        (make-plugin-builtins))) ; TODO dynamic plugin loading
         (cwd (uiop:getcwd))
         (shell (make@ 'repl (plugins cwd))))
    (do ((i 0 (1+ i)))
        (nil)
      (format t "user:~a $ " i)
      (force-output)
      (multiple-value-bind (line end) (read-line *standard-input* nil)
        (if end
          (return)
          (restart-case (feed shell line)
            (skip ()
              :report "Skip this command entirely"
              nil)))))))
