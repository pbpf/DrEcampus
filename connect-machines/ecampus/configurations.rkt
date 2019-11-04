#lang racket
(require "../tool.rkt"
          file/md5)
;主配置
(make-directory* "config/ecampus/")
(make-directory* "log/debug/")
(make-directory* "log/info/")
(define-main-configurer main-config xml-configurer% 
                                'ecampus-configure 
                                    "config/ecampus/kernel-config.xml"
                                   (lambda(x)(void)))
(define-main-config server-host "127.0.0.1")
(define-main-config remote-ip "202.119.64.86")
;(define-main-config netmask "000")
(define-main-config framedroute"172.19.91.1")
(define-main-config hwadder "0000-0000-0000")
(define-main-config debug-log-file-pattern "log/debug/*.log")
(define debug-log-file (format-file-name debug-log-file-pattern))
(define debug-loger (loger debug-log-file write-log))
(define-main-config info-log-file-pattern "log/info/*.log")
(define info-log-file (format-file-name info-log-file-pattern))
(define info-loger  (loger info-log-file display-log))
(define-main-config server-port_s "45789")
(define server-port (string->number server-port_s))

(define-main-config accessacept_s "#x02")
(define-main-config accessreject_s "#x03")
(define-main-config accountingrespond_s "#x05")
(define accessacept (string->number accessacept_s))
(define-main-config accessport_s "1812")
(define accessport (string->number accessport_s))
(define accessreject (string->number accessreject_s))
(define accountingrespond (string->number accountingrespond_s ))
(define-main-config accountingport_s "1813")
(define accountingport (string->number accountingport_s))
(define-main-config connect-gap_s "100")
(define connect-gap (string->number connect-gap_s))
(define-main-config ecampus_timeout_s "7")
(define ecampus_timeout (string->number ecampus_timeout_s))
(save-main-config!)

(provide (all-defined-out))