#lang racket
(require "../tool.rkt"
         "packet.rkt"
         "../interface.rkt"
         "configurations.rkt"
         "exn-handle.rkt"
          file/md5)


;连接状态机
(define machine%
  (class* object% (machine-interface<%>)
    (field [online-flag #f]
           [*username* ""]
           [*resource-port* 0]
           [*password* ""]
           [*hwadder* ""]
           [*framedroute* ""]
           [receive-buffer (make-bytes 100)]
           [socket (udp-open-socket)]
           [time 0]
           [connect-thread #f]
           [online-thread #f]
           )
    (define/public(login username password resource-port)
       (let((random-buf (random-bytes 32)))
                       [Identifier (bytes (random 256))]
                      ;[Framed_ip_netmask-value (string->bytes/utf-8 netmask)]
                       [UserName-value (string->bytes/utf-8 username)]
                       [Password (string->bytes/utf-8 password)]
                       [nas_port-value (bytes 0 0 0 (+ 1 resource-port))]
                       [FramedRoute-value (string->bytes/utf-8 framedroute)]
                       [ChapChallenge-value (md5  random-buf  #t)]
                       [Authenticator (md5  random-buf #f)]
                       [CallingStationId-value (string->bytes/utf-8 hwadder)]
                       [FramedIpAddress-value (get-udp-local-ip  (let()
                                                        (udp-connect! socket remote-ip  accessport) socket))]
         (call/cc (lambda(return)
                       (udp-connect! socket remote-ip  accessport)
                       (debug-loger "send" (Packet-Access))
                       (udp-send  socket (Packet-Access))
                       (udp-receive/timeout! socket receive-buffer ecampus_timeout)
                       (debug-loger  "respond" receive-buffer)
                       (respond-handle receive-buffer accessacept)
                        (reset-buffer!)
                       (info-loger  "access accept by server" username)
                       (udp-connect! socket remote-ip  accountingport)
                       (udp-send socket (Packet-accounting-request))
                       (debug-loger  "send" (Packet-accounting-request))
                       (udp-receive/timeout! socket receive-buffer ecampus_timeout)
                       (debug-loger  "respond" receive-buffer)
                       (respond-handle receive-buffer accountingrespond)
                       (reset-buffer!)
                       (info-loger  "Accounting Request by server" username)
                       (info-loger  "Login Success!" username)
                       (set! *username* username)
                       (set! *password* password)
                       (set! *resource-port* resource-port)
                       (set! *hwadder* hwadder)
                       (set! *framedroute* framedroute)
                       (set! online-flag #t)
                       (set!  connect-thread
                              (thread (lambda()
                                                      (start-accounting! remote-ip accountingport make-Packet-accounting-update-keep))))
                       (return 0)))))
    
    (define/private(start-accounting! remote-ip remote-port maker)
      (let loop()
      (sleep connect-gap)
      (set! time (+ time connect-gap))
       (debug-loger  "send" (maker time))
       (udp-send socket (maker time))
       (udp-receive/timeout! socket receive-buffer ecampus_timeout)
       (unless (= (get-respond-state  receive-buffer) accountingrespond)
         (set! online-flag #f))
       (reset-buffer!)
       (debug-loger  "respond" receive-buffer)
       (loop)))
    (define(start-online-keeper*)
      (set! online-thread
       (thread (lambda()
                (let loop()
                  (sleep 1)
                  (unless online-flag 
                    (login *username* *password* *resource-port* *hwadder* *framedroute*))
                  (loop))))))
                    
    (define/private(reset-buffer!)
      (set! receive-buffer (make-bytes 100)))
    (define/public(logout)
      (when  connect-thread (kill-thread connect-thread))
      (when online-thread (kill-thread online-thread))
      (info-loger  "send Logout Request to serve:" *username*)
      (debug-loger  "send" (make-Packet-accounting-update-stop time))
      (udp-send socket (make-Packet-accounting-update-stop time)) 
      (udp-receive/timeout! socket receive-buffer ecampus_timeout)
      (respond-handle  receive-buffer accountingrespond)
      (debug-loger  "respond" receive-buffer)
      (info-loger   "Logout Request accept by serve:" *username*)
      (info-loger  "Logout Success!:" *username*)
      (info-loger  "connect time:" time)
      )
    (define/public(ifonline-flag)
      online-flag)
    (define/public(reset-resource-port! port)
      (unless (equal? port *resource-port*)
      (logout)
      (login *username* *password* port *hwadder* *framedroute*)))
    (super-new)
    ))
  

(provide machine%  info-log-file debug-log-file
         (all-from-out "exn-handle.rkt"))
;(save-main-config!)