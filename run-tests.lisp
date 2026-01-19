(load "calimero.asd")
(load "calimero-tests.asd")

(asdf:load-system "calimero-tests")

(in-package :calimero-tests)

(uiop:quit (if (run-all-tests) 0 1))
