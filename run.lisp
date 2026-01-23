(require "asdf")
(load "calimero.asd")

(asdf:load-system "calimero")

(in-package :calimero)
(main)
;(handler-case
;    (main)
;  (error (c)
;    (format *error-output* "~&An error occured: ~a~&" c)
;    (uiop:quit 1)))
