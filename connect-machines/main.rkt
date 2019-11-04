#lang racket
(require (prefix-in ecampus: "ecampus/main.rkt")
         (prefix-in pppoe: "pppoe/main.rkt"))

(provide (all-from-out 
           "ecampus/main.rkt"
           "pppoe/main.rkt"))