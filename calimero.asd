(in-package :asdf-user)

(defsystem "calimero"
  :author "vendethiel <vendethiel@hotmail.fr>"
  :version "0.0.1"
  :license "MIT"
  :description "Calimero is a Common Lisp Shell."
  :homepage "https://github.com/vendethiel/calimero.cl"
  :bug-tracker ""
  :source-control (:git "https://github.com/vendethiel/calimero.cl")

  ;; Dependencies.
  :depends-on (#:alexandria ; Utils
               #:serapeum ; More utils
               #:access ; Generic access lib
               #:cl-punch ; Scala-style lambdas with ^(foo _) <https://github.com/windymelt/cl-punch>
               #:closer-mop ; MOP compat layer
               #:trivial-types ; More types
               #:defstar ; Proper typed definitions <https://github.com/lisp-maintainers/defstar>
               #:nclasses
               #:fn ; Lambda macros
               #:for ; Iteration library <https://shinmera.github.io/for>
               #:fset ; Collection library <http://www.ergy.com/FSet.html>
               #:modf ; Immutable updates <https://github.com/smithzvk/modf>
              ;  #:generic-cl ; Generic operators <https://alex-gutev.github.io/generic-cl>
               #:named-readtables ; Isolated readtables
               #:str ; String helpers
               #:trivia ; Pattern matching
               ;#:cl-readline ; Readline bindings
               #:metabang-bind
               #:cl-reexport ; Brings in `cl-reexport:reexport-from' that's useful for custom stdlib-like packages
               #:uiop ; Portable I/O functions
               )

  ;; Project stucture.
  :serial t
  :components ((:module "src"
                        :serial t
                        :components ((:file "util")
                                     (:file "myclass")
                                     (:file "error")
                                     (:file "data")
                                     (:file "command")
                                     (:file "plugin")
                                     (:file "output")
                                     (:file "parse")
                                     (:file "repl")
                                     (:file "plugin-sh")
                                     (:file "plugin-builtins-array")
                                     (:file "plugin-builtins-table")
                                     (:file "plugin-builtins")
                                     (:file "loop")
                                     (:file "calimero"))))

  ;; Build a binary:
  ;; don't change this line.
  :build-operation "program-op"
  ;; binary name: adapt.
  :build-pathname "calimero"
  ;; entry point: here "main" is an exported symbol. Otherwise, use a double ::
  :entry-point "calimero:main")

;;;
;;; Conveniently add type declarations.
;;; Straight from Serapeum, only it is -> thus it conflicts with our arrow-macro.
;;;
; (deftype --> (args values)
;   "The type of a function from ARGS to VALUES.

;   From SERAPEUM (where it is -> and thus conflicts with our -> arrow-macro)."
;   `(function ,args ,values))

; (defmacro --> (function args values)
;   "Declaim the ftype of FUNCTION from ARGS to VALUES.

;      (--> mod-fixnum+ (fixnum fixnum) fixnum)
;      (defun mod-fixnum+ (x y) ...)

;   In pure CL, it would be:

;   (declaim (ftype (function (fixnum fixnum) fixnum) mod-fixnum+))
;   (defun mod-fixnum+ (x y) ...)

;   In CIEL, you can also use `defun*'.

;   From SERAPEUM (where it is -> and thus conflicts with our -> arrow-macro)."
;   `(declaim (ftype (--> ,args ,values) ,function)))
