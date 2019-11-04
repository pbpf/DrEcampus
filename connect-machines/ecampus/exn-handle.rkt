
#lang racket

;异常处理机制
(struct exn:fail:connect-machine exn:fail (code respond))

(define (get-message-value bf)
 (subbytes bf 22 (+ 22 (get-message-length bf))))
(define (get-respond-state bf)
  (bytes-ref bf 0))
(define (get-message-state bf)
  (bytes-ref bf 20))
(define (get-message-length bf)
  (bytes-ref bf 21))

(define(respond-handle bf need)
  (unless(= (get-respond-state bf) need)
    (raise (exn:fail:connect-machine ""  (current-continuation-marks) (get-message-state bf) (get-message-value bf)))))

(define(udp-receive/timeout! buffer port timeout)
  (let((rc(udp-receive!-evt  buffer port)))
   (sync/timeout timeout rc)))

                     

(provide (all-defined-out))