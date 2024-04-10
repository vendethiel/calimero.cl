(in-package :cl-user)
(uiop:define-package :calimero.error
  (:import-from :serapeum #:pophash)
  (:import-from :for #:for)
  (:import-from :named-readtables #:in-readtable)

  (:import-from :calimero.util #:syntax)
  (:import-from :calimero.oo #:defcondition* #:ahashmap)

  (:export #:calimero-error #:error-components))
(in-package :calimero.error)

(in-readtable syntax)

(defcondition* calimero-error (error)
  ()
  (:report (lambda (e s)
             (let* ((c (error-components e))
                    (message (pophash :message c))
                    (command (pophash :command c)))
               (format s "~a~a~%"
                       (or message "Generic Error")
                       (if command
                           #?" in ${command}"
                           ""))
               (for (((k v) over c))
                  (format s "  ~a: ~a~%" k v))))))

(defgeneric error-components (err)
  (:documentation "Returns the different parts of a calimero error as an alist. Not mutated.")
  (:method-combination ahashmap)
  (:method ahashmap ((err calimero-error))
    (list)))
