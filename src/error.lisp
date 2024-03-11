(in-package :cl-user)
(defpackage :calimero.error
  (:use :cl)

  (:import-from :calimero.myclass #:defcondition* #:ahashmap)

  (:export :calimero-error :error-components))
(in-package :calimero.error)

(defcondition* calimero-error (error)
  ())

(defgeneric error-components (err)
  (:documentation "Returns the different parts of a calimero error")
  (:method-combination ahashmap))
