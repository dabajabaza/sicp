; 4.1
; ========================================================================
(define (no-operands? ops) (null? ops))
(define (first-operand ops) (car ops))
(define (rest-operands ops) (cdr ops))
(define (eval exp env) exp)

(define (list-of-values-right-to-left exps env)
  (if (no-operands? exps)
      '()
      (let ((left (eval (first-operand exps) env))
	    (right (list-of-values-right-to-left (rest-operands exps) env)))
      (cons right left))))

(define (list-of-values-left-to-right exps env)
  (if (no-operands? exps)
      '()
      (let ((left (eval (first-operand exps) env))
	    (right (list-of-values-left-to-right (rest-operands exps) env)))
      (cons left right))))

; 4.2
; ========================================================================
;; a. Louis' modified (eval) will erroneously consider (define x 3) to be
;; procedure application.  (application?) is implemented by checking if the
;; exp is a (pair?).

;; b.
(define (operator exp) (car exp))
(define (louis-application? exp)
  (eq? (operator exp) 'call))

; 4.3
; ========================================================================
(define (true? x)
  (not (eq? x false)))
(define (false? x)
  (eq? x false))
(define (operator exp) (car exp))
(define (operands exp) (cdr exp))
(define (empty-list? exp)
  (eq? exp '()))
(define (self-evaluating? exp)
  (cond ((number? exp) true)
        ((string? exp) true)
	((empty-list? exp) true)
	((boolean? exp) true)
        (else false)))

(define put 2d-put!)
(define get 2d-get)

(define (install-if-package)
  (define (if-predicate exp) (cadr exp))
  (define (if-consequent exp) (caddr exp))
  (define (if-alternative exp)
    (if (not (null? (cdddr exp)))
	(cadddr exp)
	'false))

  (define (eval-if exp env)
    (if (true? (eval (if-predicate exp) env))
	(eval (if-consequent exp) env)
	(eval (if-alternative exp) env)))

  (put 'eval 'if eval-if)

  'if-package-installed)

(install-if-package)

(define (eval exp env)
  (cond ((self-evaluating? exp) exp)
        ((variable? exp) (lookup-variable-value exp env))
	((get 'eval (operator exp)) ((get 'eval (operator exp)) exp env))
	(else
         (error "Unknown expression type -- EVAL" exp))))

; 4.4
; ========================================================================
(define (install-and-package)
  (define (and-predicate exp) (car exp))

  (define (eval-and exp env)
    (define (iter expression)
      (cond ((null? expression) true)
	    ((true? (eval (and-predicate expression) env)) (iter (cdr expression)))
	    (else false)))

    (iter (cdr exp))
    )

  (put 'eval 'and eval-and)

  'and-package-installed)

(install-and-package)

(define (install-or-package)
  (define (or-predicate exp) (car exp))

  (define (eval-or exp env)
    (define (iter expression)
      (cond ((null? expression) false)
	    ((true? (eval (or-predicate expression) env)) true)
	    (else (iter (cdr expression)))))

    (iter (cdr exp))
    )

  (put 'eval 'or eval-or)

  'or-package-installed)

(install-or-package)

; 4.5
; ========================================================================
(define (make-if predicate consequent alternative)
  (list 'if predicate consequent alternative))

(define (last-exp? seq) (null? (cdr seq)))
(define (first-exp seq) (car seq))
(define (sequence->exp seq)
  (cond ((null? seq) seq)
        ((last-exp? seq) (first-exp seq))
        (else (make-begin seq))))
(define (make-begin seq) (cons 'begin seq))

(define (install-cond-package)
  (define (cond-clauses exp) (cdr exp))
  (define (cond-else-clause? clause)
    (eq? (cond-predicate clause) 'else))
  (define (cond-predicate clause) (car clause))
  (define (cond-actions clause) (cdr clause))
  (define (cond-test-recipient-clause? clause)
    (eq? (car (cond-actions clause)) '=>))
  (define (cond-recipient clause)
    (caddr clause))

  (define (expand-clauses clauses)
    (if (null? clauses)
	'false                          ; no else clause
	(let ((first (car clauses))
	      (rest (cdr clauses)))
	  (if (cond-else-clause? first)
	      (if (null? rest)
		  (sequence->exp (cond-actions first))
		  (error "ELSE clause isn't last -- COND->IF"
			 clauses))
	      (if (cond-test-recipient-clause? first)
		  (let ((function (cond-recipient first)))
		    (make-if (cond-predicate first)
			     (cons function (list (cond-predicate first)))
			     #f))
		  (make-if (cond-predicate first)
			   (sequence->exp (cond-actions first))
			   (expand-clauses rest)))))))

  (define (cond->if exp)
    (expand-clauses (cond-clauses exp)))

  (put 'transform 'cond cond->if)

  (put 'eval 'cond
       (lambda (exp env)
	 (eval (cond->if exp) env)))

  'cond-package-installed)

(install-cond-package)

(define (transform exp)
  ((get 'transform (operator exp)) exp))

; 4.6
; ========================================================================
(define (make-lambda parameters body)
  (cons 'lambda (cons parameters body)))

(define (install-let-package)
  (define (let-expressions clause)
    (cadr clause))
  (define (let-body clause)
    (cddr clause))
  (define (let-variables clause)
    (map car (let-expressions clause)))
  (define (let-values clause)
    (map cadr (let-expressions clause)))

  (define (let->combination exp)
    (cons
     (make-lambda
      (let-variables exp)
      (let-body exp))
     (let-values exp)))

  (put 'transform 'let let->combination)
  (put 'eval 'let (lambda (exp env)
		    (eval
		     (let->combination exp)
		     env)))

  'let-package-installed)

(install-let-package)

(define (make-procedure parameters body env)
  (list 'procedure parameters body env))

(define (install-lambda-package)
  (define (lambda-parameters exp) (cadr exp))
  (define (lambda-body exp) (caddr exp)) ; Wow this really should be cddr.  Changing it here breaks every other function from the book that operates on lambdas.  Getting the list semantics right between every function seems like an annoying side effect of everything in Scheme being a list.

  (define (eval-lambda exp env)
    (make-procedure (lambda-parameters exp)
		    (lambda-body exp)
		    env))

  (put 'eval 'lambda eval-lambda)

  'lambda-package-installed)

(install-lambda-package)

; 4.7
; ========================================================================
(define (install-let*-package)
  (define (let*-expressions clause)
    (cadr clause))
  (define (let*-body clause)
    (caddr clause))
  (define (make-let expression body)
    (cons 'let (cons (list expression) (list body))))

  (define (let*->nested-lets exp)
    (define (make-nested-lets expressions body)
      (if (null? expressions)
	  body
	  (make-let
	   (car expressions)
	   (make-nested-lets (cdr expressions) body))))

    (make-nested-lets
     (let*-expressions exp)
     (let*-body exp)))

  (put 'transform 'let* let*->nested-lets)

  'let*-package-installed)

(install-let*-package)

;; You can't simply add (eval (let*->nested-lets exp) env) to the evaluator.
;; It expands the lets* into nested lets but then fails to transform them all
;; into (lambdas).  You wind up with an unusable statement. It looks like this:
;; (
;;  (lambda (x)
;;    (let ((y (+ x 2)))
;;      (let ((z (+ x y 5)))
;;        (* x z))))
;;  3)

; 4.8
; ========================================================================
(define (make-function-call function-name . variables)
  (if (null? variables)
      (list function-name)
      (apply list function-name variables)))

(define (make-define variable value)
  (if (pair? variable)
      (let ((function-name (car variable))
	    (variables (cdr variable))
	    (body value))
	(list 'define (cons function-name variables) body))
      (list 'define variable value)))

(define (install-let-package)
  (define (let-expressions clause)
    (cadr clause))
  (define (let-body clause)
    (cddr clause))
  (define (let-variables clause)
    (map car (let-expressions clause)))
  (define (let-values clause)
    (map cadr (let-expressions clause)))

  (define (named-let? clause)
    (symbol? (let-expressions clause)))
  (define (named-let-expressions clause)
    (caddr clause))
  (define (named-let-values clause)
    (map cadr (named-let-expressions clause)))
  (define (named-let-variables clause)
    (map car (named-let-expressions clause)))
  (define (named-let-body clause)
    (cadddr clause))
  (define (named-let-name clause)
    (cadr clause))

  (define (let->combination exp)
    (if (named-let? exp)
	(sequence->exp
	 (list
	  (make-define
	   (cons (named-let-name exp) (named-let-variables exp))
	   (named-let-body exp))
	  (apply make-function-call
	   (named-let-name exp)
	   (named-let-values exp))))
	(cons
	 (make-lambda
	  (let-variables exp)
	  (let-body exp))
	 (let-values exp))))

  (put 'transform 'let let->combination)
  (put 'eval 'let (lambda (exp env)
		    (eval
		     (let->combination exp)
		     env)))

  'let-package-installed)

(install-let-package)

; 4.9
; ========================================================================
(define (install-while-package)
  (define (while-conditional while-clause)
    (cadr while-clause))
  (define (while-expressions while-clause)
    (cddr while-clause))

  (define (while->iter exp)
    (make-define
     '(iter)
     (make-if
      (while-conditional exp)
      (sequence->exp (append (while-expressions exp) (list (make-function-call 'iter))))
      #f)))

  (put 'transform 'while while->iter)

  'while-package-installed)

(install-while-package)

; 4.10
; ========================================================================
(define (install-and-package)
  (define (and-predicate exp) (car exp))

  (define (eval-and exp env)
    (define (iter expression)
      (cond ((null? expression) true)
	    ((true? (eval (and-predicate expression) env)) (iter (cdr expression)))
	    (else false)))

    (iter (cdr exp))
    )

  (put 'eval '&& eval-and)

  'and-package-installed)

(install-and-package)

(define (install-or-package)
  (define (or-predicate exp) (car exp))

  (define (eval-or exp env)
    (define (iter expression)
      (cond ((null? expression) false)
	    ((true? (eval (or-predicate expression) env)) true)
	    (else (iter (cdr expression)))))

    (iter (cdr exp))
    )

  (put 'eval '|| eval-or)

  'or-package-installed)

(install-or-package)
