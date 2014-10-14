(load "5_14_to_5_22.scm")

(describe "Register machine simulator"
  (it "tracks the number of instructions executed"
    (lambda ()
      (load "book_code/ch5-regsim.scm")

      (define factorial-machine
	(make-machine
	 '(n continue val)
	 (list
	  (list '= =)
	  (list '- -)
	  (list '* *))
	 '((perform (op initialize-stack))
	   (assign continue (label fact-done))
	  fact-loop
	   (test (op =) (reg n) (const 1))
	   (branch (label base-case))
	   (save continue)
	   (save n)
	   (assign n (op -) (reg n) (const 1))
	   (assign continue (label after-fact))
	   (goto (label fact-loop))
	  after-fact
	   (restore n)
	   (restore continue)
	   (assign val (op *) (reg n) (reg val))
	   (goto (reg continue))
	  base-case
	   (assign val (const 1))
	   (goto (reg continue))
	  fact-done
	   )
	 ))

      (set-register-contents! factorial-machine 'n 1)
      (start factorial-machine)
      (assert (= (get-instruction-count factorial-machine) 6))

      (set-register-contents! factorial-machine 'n 6)
      (start factorial-machine)
      (assert (= (get-instruction-count factorial-machine) 61))
      ))


  (it "prints out every instruction that was executed"
    (lambda ()
      (load "book_code/ch5-regsim.scm")

      (define factorial-machine
	(make-machine
	 '(n continue val)
	 (list
	  (list '= =)
	  (list '- -)
	  (list '* *))
	 '((perform (op initialize-stack))
	   (assign continue (label fact-done))
	   fact-loop
	   (test (op =) (reg n) (const 1))
	   (branch (label base-case))
	   (save continue)
	   (save n)
	   (assign n (op -) (reg n) (const 1))
	   (assign continue (label after-fact))
	   (goto (label fact-loop))
	   after-fact
	   (restore n)
	   (restore continue)
	   (assign val (op *) (reg n) (reg val))
	   (goto (reg continue))
	   base-case
	   (assign val (const 1))
	   (goto (reg continue))
	   fact-done
	   ))
	)

      (set-register-contents! factorial-machine 'n 2)
      (enable-instruction-tracing factorial-machine)

      (assert
       (equal?
	(with-output-to-string
	  (lambda  () (start factorial-machine)))
	"
(perform (op initialize-stack))
(assign continue (label fact-done))
fact-loop
(test (op =) (reg n) (const 1))
(branch (label base-case))
(save continue)
(save n)
(assign n (op -) (reg n) (const 1))
(assign continue (label after-fact))
(goto (label fact-loop))
fact-loop
(test (op =) (reg n) (const 1))
(branch (label base-case))
base-case
(assign val (const 1))
(goto (reg continue))
after-fact
(restore n)
(restore continue)
(assign val (op *) (reg n) (reg val))
(goto (reg continue))
fact-done"
       ))
     ))

  (it "can trace register assignments"
    (lambda ()
      (load "book_code/ch5-regsim.scm")

      (define register-machine
	(make-machine
	 '(traced untraced)
	 '()
	 '(
	   a-label
	   (assign traced (const 3))
	   (assign untraced (const 5))

	   (assign traced (const 8))
	   )))

      (enable-register-tracing (get-register register-machine 'traced))

      (assert
       (equal?
	(with-output-to-string
	  (lambda () (start register-machine)))
	"
(Register traced is being assigned 3 from the previous value: *unassigned*)
(Register traced is being assigned 8 from the previous value: 3)"
	  ))


      ))

  )