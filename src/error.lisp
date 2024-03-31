(in-package :cl-user)
(uiop:define-package :calimero.error
  (:import-from :serapeum #:pophash)

  (:import-from :calimero.oo #:defcondition* #:ahashmap)

  (:export :calimero-error :error-components))
(in-package :calimero.error)

(named-readtables:in-readtable :interpol-syntax)


(defcondition* calimero-error (error)
  ()
  (:report (lambda (e s)
             (let* ((c (error-components e))
                    (message (pophash "message" c))
                    (command (pophash "command" c)))
               (format s "~a~a"
                       (or message "Generic Error")
                       (if command
                           #?" in ${command}"
                           ""))))))

(defgeneric error-components (err)
  (:documentation "Returns the different parts of a calimero error")
  (:method-combination ahashmap)
  (:method ahashmap ((err calimero-error))
    '()))
