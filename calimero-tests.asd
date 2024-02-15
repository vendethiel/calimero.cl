(in-package :asdf-user)
(defsystem "calimero-tests"
  :description "Test suite for the calimero system"
  :author "vendethiel <vendethiel@hotmail.fr>"
  :version "0.0.1"
  :depends-on (:calimero
               :fiveam)
  :license "BSD"
  :serial t
  :components ((:module "tests"
                        :serial t
                        :components ((:file "packages")
                                     (:file "test-calimero"))))

  ;; The following would not return the right exit code on error, but still 0.
  ;; :perform (test-op (op _) (symbol-call :fiveam :run-all-tests))
  )
