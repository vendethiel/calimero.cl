(in-package :cl-user)
(defpackage :calimero.plugin
  (:use :cl)

  (:import-from :calimero.oo #:defclass*)
  (:import-from :calimero.command #:command)

  (:export :plugin))
(in-package :calimero.plugin)

(defclass* plugin ()
  ((name :type string)
   (description :type string)
   (handler :type command)))

