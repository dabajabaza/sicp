; 5.23
; ========================================================================
;; I added the following to eceval
;;   (test (op cond?) (reg exp))
;;   (branch (label ev-cond))
;; ....
;; ev-cond
;;   (assign exp (op cond->if) (reg exp))
;;   (goto (label eval-dispatch))

(define x 9)
(cond ((> x 0) x)
      ((= x 0) (display zero) 0)
      (else (- x)))

;;; EC-Eval input:
(define x 9)

(total-pushes = 3 maximum-depth = 3)
;;; EC-Eval value:
ok

;;; EC-Eval input:
(cond ((> x 0) x)
      ((= x 0) (display zero) 0)
      (else (- x)))

(total-pushes = 11 maximum-depth = 8)
;;; EC-Eval value:
9


; 5.24
; ========================================================================
; See my changes to ch5-eceval.scm for my implementation of (cond).
(load "book_code/load-eceval.scm")
(define the-global-environment (setup-environment))
(start eceval)

(cond)
;;; EC-Eval value:
;; ()
(define x 9)
(cond (else (- x 1)))
;;; EC-Eval value:
;; 8

(define x 9)
(cond ((> x 10) x)
      ((= x 0) (+ x 2) (* x 2))
      ((= x 9) (+ x 1) (* x 10))
      (else (- x 1)))
;;; EC-Eval value:
;; 90

(define x 8)
(cond ((> x 10) x)
      ((= x 0) (+ x 2) (* x 2))
      ((= x 9) (+ x 1) (* x 10))
      (else (- x 1)))

;;; EC-Eval value:
;; 7

; 5.25
; ========================================================================
;; No!

; 5.26
; ========================================================================
(load "book_code/load-eceval.scm")
(define the-global-environment (setup-environment))
(start eceval)

(define (factorial n)
  (define (iter product counter)
    (if (> counter n)
        product
        (iter (* counter product)
              (+ counter 1))))
  (iter 1 1))

;;  EC-Eval input:
;; (factorial 3)

;; (total-pushes = 134 maximum-depth = 10)
;;  EC-Eval value:
;; 6

;;  EC-Eval input:
;; (factorial 4)

;; (total-pushes = 169 maximum-depth = 10)
;;  EC-Eval value:
;; 24

;;  EC-Eval input:
;; (factorial 5)

;; (total-pushes = 204 maximum-depth = 10)
;;  EC-Eval value:
;; 120

;;  EC-Eval input:
;; (factorial 6)

;; (total-pushes = 239 maximum-depth = 10)
;;  EC-Eval value:
;; 720

; a.  The maximum depth is 10.
; b. Total pushes = 64 + 35*(n - 1)

; 5.27
; ========================================================================
(load "book_code/load-eceval.scm")
(define the-global-environment (setup-environment))
(start eceval)

(define (factorial n)
  (if (= n 1)
      1
      (* (factorial (- n 1)) n)))

;; EC-Eval input:
;; (factorial 3)

;; (total-pushes = 80 maximum-depth = 18)
;; EC-Eval value:
;; 6

;; EC-Eval input:
;; (factorial 4)

;; (total-pushes = 112 maximum-depth = 23)
;; EC-Eval value:
;; 24

;; EC-Eval input:
;; (factorial 5)

;; (total-pushes = 144 maximum-depth = 28)
;; EC-Eval value:
;; 120

;; EC-Eval input:
;; (factorial 6)

;; (total-pushes = 176 maximum-depth = 33)
;; EC-Eval value:
;; 720

;; Maximum depth = 8 + 5*(n-1)
;; Total pushes = 16 * (2*n -1)

; 5.28
; ========================================================================
;; Replace the ev-sequence code with this:
;; ev-sequence
;;   (test (op no-more-exps?) (reg unev))
;;   (branch (label ev-sequence-end))
;;   (assign exp (op first-exp) (reg unev))
;;   (save unev)
;;   (save env)
;;   (assign continue (label ev-sequence-continue))
;;   (goto (label eval-dispatch))
;; ev-sequence-continue
;;   (restore env)
;;   (restore unev)
;;   (assign unev (op rest-exps) (reg unev))
;;   (goto (label ev-sequence))
;; ev-sequence-end
;;   (restore continue)
;;   (goto (reg continue))

(load "book_code/load-eceval.scm")
(define the-global-environment (setup-environment))
(start eceval)

(define (factorial n)
  (define (iter product counter)
    (if (> counter n)
        product
        (iter (* counter product)
              (+ counter 1))))
  (iter 1 1))

;; EC-Eval input:
;; (factorial 3)

;; (total-pushes = 144 maximum-depth = 23)
;; EC-Eval value:
;; 6

;; EC-Eval input:
;; (factorial 4)

;; (total-pushes = 181 maximum-depth = 26)
;; EC-Eval value:
;; 24

;; EC-Eval input:
;; (factorial 5)

;; (total-pushes = 218 maximum-depth = 29)
;; EC-Eval value:
;; 120

;; EC-Eval input:
;; (factorial 6)

;; (total-pushes = 255 maximum-depth = 32)
;; EC-Eval value:
;; 720

;; The maximum depth is 14 + 3n
;; The total pushes is 33 + 37n

(define (factorial n)
  (if (= n 1)
      1
      (* (factorial (- n 1)) n)))

;; EC-Eval input:
;; (factorial 1)

;; (total-pushes = 18 maximum-depth = 11)
;; EC-Eval value:
;; 1

;; EC-Eval input:
;; (factorial 2)

;; (total-pushes = 52 maximum-depth = 19)
;; EC-Eval value:
;; 2

;; EC-Eval input:
;; (factorial 3)

;; (total-pushes = 86 maximum-depth = 27)
;; EC-Eval value:
;; 6

;; The maximum depth is 3 + 8n
;; The total pushes is -16 + 34n

; 5.29
; ========================================================================
(load "book_code/load-eceval.scm")
(define the-global-environment (setup-environment))
(start eceval)

(define (fib n)
  (if (< n 2)
      n
      (+ (fib (- n 1)) (fib (- n 2)))))

;; EC-Eval input:
;; (fib 2)

;; (total-pushes = 72 maximum-depth = 13)
;; EC-Eval value:
;; 1

;; EC-Eval input:
;; (fib 3)

;; (total-pushes = 128 maximum-depth = 18)
;; EC-Eval value:
;; 2

;; EC-Eval input:
;; (fib 4)

;; (total-pushes = 240 maximum-depth = 23)
;; EC-Eval value:
;; 3

;; EC-Eval input:
;; (fib 1)

;; (total-pushes = 16 maximum-depth = 8)
;; EC-Eval value:
;; 1

;; a. The maximum depth is 5n + 3
;; b. The total pushes is. . .
;; s(4) = s(3) + s(2) + k == 240
;; s(4) = 128 + 72 + k == 240
;; k == 40

;; We know that s(1) is 16
;; and s(n) = a*fib(n+1) + b, so. . .
;; s(1) = a * fib(2) + b
;; 16 = a * fib(2) + b
;; 16 = a * 1 + b
;; 16 = a + b

;; s(2) = a * fib(3) + b
;; 72 = a * 2 + b
;; 72 = 2a + b

;; Now we get to solve simultaneous equations!
;; 72 - 16 = 2a - a + b - b
;; 72 - 16 == a
;; 56 == a

;; Plug that back into s(1) and we get
;; 16 = 56*1 + b
;; -40 = b

;; Total pushes is:
;; s(n) = 56*fib(n+1) - 40

; 5.30
; ========================================================================
;; a.
;; add the following to ch5-eceval-support.scm
;;(define (throw-exception type)
;;  (list 'EXCEPTION: type)
;;  )
;;
;;(define (exception? var)
;;  (tagged-list? var 'exception:))
;;
;;Change lookup-variable-value:
;;-        (error "Unbound variable" var)
;;+       (throw-exception "Unbound variable")
;;
;;Add the following to ch5-eceval.scm
;;    (list 'no-more-exps? no-more-exps?)	;for non-tail-recursive machine
;;+   (list 'exception? exception?)
;;
;;Then in ev-variable:
;; ev-variable
;;   (assign val (op lookup-variable-value) (reg exp) (reg env))
;;+  (test (op exception?) (reg val))
;;+  (branch (label signal-error))
;;   (goto (reg continue))

(load "book_code/load-eceval.scm")
(define the-global-environment (setup-environment))
(start eceval)

;; EC-Eval input:
;; x
;; (exception: Unbound variable)

;; EC-Eval input:
;; (+ x y)
;; (exception: Unbound variable)

;; EC-Eval input:
;; (define x 3)

;; (total-pushes = 3 maximum-depth = 3)
;; EC-Eval value:
;; ok

;; EC-Eval input:
;; x

;; (total-pushes = 0 maximum-depth = 0)
;; EC-Eval value:
;; 3

;; b.
;; Add the following to ch5-eceval-support.scm
;;  (define primitive-procedures
;; -  (list (list 'car car)
;; +  (list (list 'car car pair?)

;; (define (primitive-procedure-objects)
;; -  (map (lambda (proc) (list 'primitive (cadr proc)))
;; +  (map (lambda (proc)
;; +        (if (= (length proc) 3)
;; +            (list 'primitive (cadr proc) (caddr proc))
;; +            (list 'primitive (cadr proc) #f)))

;; -(define (apply-primitive-procedure proc args)
;; -  (apply-in-underlying-scheme
;; -   (primitive-implementation proc) args))
;; +(define (primitive-safety-check proc)
;; +  (caddr proc))
;; +
;; +(define (has-safety-check? proc)
;; +  (true? (caddr proc)))

;; +(define (is-safe-to-apply? proc args)
;; +  (if (has-safety-check? proc)
;; +      (apply-in-underlying-scheme (primitive-safety-check proc) args)
;; +      true))
;; +
;; +(define (apply-primitive-procedure proc args)
;; +  (if (is-safe-to-apply? proc args)
;; +      (apply-in-underlying-scheme
;; +       (primitive-implementation proc) args)
;; +      (throw-exception "Invalid argument")))

;; And also add this to ch5-eceval.scm
;;  primitive-apply
;;    (assign val (op apply-primitive-procedure)
;;                (reg proc)
;;                (reg argl))
;; +  (test (op exception?) (reg val))
;; +  (branch (label signal-error))

(load "book_code/load-eceval.scm")
(define the-global-environment (setup-environment))
(start eceval)

;; EC-Eval input:
;; (define x (cons 3 4))

;; (total-pushes = 11 maximum-depth = 8)
;; EC-Eval value:
;; ok

;; EC-Eval input:
;; (car x)

;; (total-pushes = 5 maximum-depth = 3)
;; EC-Eval value:
;; 3

;; EC-Eval input:
;; (define y 5)

;; (total-pushes = 3 maximum-depth = 3)
;; EC-Eval value:
;; ok

;; EC-Eval input:
;; (car y)
;; (exception: Invalid argument)
