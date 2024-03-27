(in-package :cl-user)
(uiop:define-package :calimero.plugin
  (:import-from :calimero.oo #:defclass*)
  (:import-from :calimero.command #:command)

  (:export :plugin))
(in-package :calimero.plugin)

(defclass* plugin ()
  ((name :type string)
   (description :type string)
   (handler :type command)))

