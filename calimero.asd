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
               #:arrow-macros ; Clojure style macros
               #:cl-punch ; Scala-style lambdas with ^(foo _) <https://github.com/windymelt/cl-punch>
               #:closer-mop ; MOP compat layer
               #:trivial-types ; More types
               #:defstar ; Proper typed definitions <https://github.com/lisp-maintainers/defstar>
               #:fn ; Lambda macros
               #:for ; Iteration library <https://shinmera.github.io/for>
               #:fset ; Collection library <http://www.ergy.com/FSet.html>
               #:modf ; Immutable updates <https://github.com/smithzvk/modf>
              ;  #:generic-cl ; Generic operators <https://alex-gutev.github.io/generic-cl>
               #:named-readtables ; Isolated readtables
               #:str ; String helpers
               #:trivia ; Pattern matching
               #:cl-readline ; Readline bindings
               )

  ;; Project stucture.
  :serial t
  :components ((:module "src"
                        :serial t
                        :components ((:file "repl")
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