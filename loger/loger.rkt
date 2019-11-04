#lang racket
;log
(require racket/date)

(define-syntax-rule (format-file-name spath)
  (parameterize ([date-display-format 'iso-8601])
    (regexp-replace #rx"\\*" spath (date->string (current-date)))))

(define-syntax-rule (open-log-file log-file)
  (begin (when (and (not (file-exists? log-file))
                   (path-only log-file))
          (make-directory* (path-only log-file)))
  (open-output-file log-file #:exists 'append)))

(define(write-log loger prefix info)
  (fprintf loger "[~a | ~s: ~s]\n\r" (date->string (current-date)#t) prefix info))

(define (display-log loger prefix info)
  (fprintf loger "[~a | ~a ~a]\n\r" (date->string (current-date)#t) prefix info))

(struct loger(path writer)
  #:property prop:procedure 
  (lambda(self prefix info)
    (call-with-output-file
        (loger-path self)
      (lambda(out)
       ((loger-writer self) out prefix info))
       #:exists 'append)))
  
(provide (all-defined-out))
     
