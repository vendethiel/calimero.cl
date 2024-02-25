(in-package :cl-user)
(defpackage :calimero.data
  (:use :cl)

  (:import-from :calimero.myclass #:defclass*)

  (:export #:empty-data #:table-data #:list-data))
(in-package :calimero.data)

(defclass* data ()
  ())
