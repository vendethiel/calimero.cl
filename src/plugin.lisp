(in-package :cl-user)
(uiop:define-package :calimero.plugin
  (:import-from :calimero.oo #:defclass*)
  (:import-from :calimero.command #:command)

  (:export #:plugin))
(in-package :calimero.plugin)

(defclass* plugin ()
  ((name :type string
         :initform (error "plugin's :name cannot be nil"))
   (description :type string
                :initform (error "plugin's :description cannot be nil"))
   (handler :type command
         :initform (error "plugin's :handler cannot be nil"))))

