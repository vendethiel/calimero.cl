(in-package :cl-user)
(uiop:define-package :calimero.error
  (:import-from :calimero.oo #:defcondition* #:ahashmap)

  (:export :calimero-error :error-components))
(in-package :calimero.error)

(defcondition* calimero-error (error)
  ())

;; TODO :report that uses serapeum:pophash to extract what it can, and dump the other keys


(defgeneric error-components (err)
  (:documentation "Returns the different parts of a calimero error")
  (:method-combination ahashmap))

