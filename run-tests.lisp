
(load "calimero.asd")
(load "calimero-tests.asd")

(ql:quickload "calimero-tests")

(in-package :calimero-tests)

(uiop:quit (if (run-all-tests) 0 1))
