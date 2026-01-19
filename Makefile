LISP ?= sbcl

all: test

run:
	rlwrap $(LISP) --load run.lisp

build:
	$(LISP)	--non-interactive \
		--load calimero.asd \
		--eval '(ql:quickload :calimero)' \
		--eval '(asdf:make :calimero)'

test:
	$(LISP) --non-interactive \
		--load run-tests.lisp

test-debug:
	$(LISP) --load run-tests.lisp
