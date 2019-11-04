#lang racket
;---------------------------------------------
(require "../loger/loger.rkt"
         "../configurator/main.rkt")
(define (random-bytes len)
  (let((b (make-bytes len)))
    (for([i (in-range len)])
      (bytes-set! b i (random 256)))
    b))
(define(ip-string->bytes s)
  (apply bytes (map string->number (regexp-match* #rx"[0-9]+" s))))
(define(get-udp-local-ip udp)
  (call-with-values (lambda()(udp-addresses   udp))(lambda(x y) (ip-string->bytes x))))

;--------------------------------------------


(provide (all-defined-out)
         (all-from-out "../loger/loger.rkt"
         "../configurator/main.rkt"))