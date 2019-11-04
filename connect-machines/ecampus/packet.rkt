#lang racket
(require (only-in file/md5 md5)
         (for-syntax racket/syntax)
         )
(provide (all-defined-out)(all-from-out file/md5))

;;;;;;;;;;;;;;;;;;;;;;;;tool;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (ip-string->bit s)
  (apply string-append(map (lambda(x)(number->string (string->number x) 2))(regexp-match* #rx"[0-9]+" s))))
;;;;;;;;;;;;;;;;;;;;;;;field;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (packet-field-full id  leng value)
  (if value
  (bytes-append (bytes id leng) value)
  #""))
(define (packet-field-simple id value)
   (packet-field-full id (+ 2 (bytes-length value)) value))
(define packet-field
  (case-lambda
    ((id  leng value)(packet-field-full id  leng value ))
    ((id value)(packet-field-simple id value))))

;;;;;;;;;;;;;;;;;;;;;;id-table;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define id-table #hasheq((UserName . #x01)
                         (nas_port . #x05)
                         (Nas_identifier . #x20)
                         (acct_session_time . #x2e)
                         (Broadcast . #x0a)
                         (Framed_ip_netmask . #x09)
                         (acct_session_id . #x2c)
                         (acct_authentic . #x2d)
                         (nas_port_type . #x3d)
                         (Service_type . #x06)
                         (Framed_protocol . #x07)
                         (FramedIpAddress . #x08)
                         (CallingStationId . #x1f)
                         (acct_status_type . #x28)
                         (ChapChallenge . #x3c)
                         (FramedRoute . #x16)
                         (Chap_password . #x03)
                         (Chap . #x10) ))
(define (Find-id name)
  (hash-ref id-table name))


;;;;;;;;;;;;;;;;;;;;;;;;;;define-field;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-syntax define-field
  (syntax-rules()
    ((_ name name-value)
     (define (name )
       (packet-field (Find-id (quote name))(name-value))))
    ((_ name name-value leng)
     (define (name )
       (let((b(packet-field  (Find-id (quote name)) leng(name-value)))
            (r (make-bytes leng)))
         (bytes-copy! r 0 b)
        ; (write r)
         r)))))
(define-syntax (define-field&value syntax-object)
  (syntax-case syntax-object()
    ((_ name value)
     (with-syntax  ([value-name (format-id syntax-object "~a-value" (syntax->datum #'name))])
     #'(begin 
         (define value-name (make-parameter value))
         (define-field name value-name))))
    ((_ name value leng)
     (with-syntax  ([value-name (format-id syntax-object "~a-value" (syntax->datum #'name))])
     #'(begin 
         (define value-name (make-parameter value))
         (define-field name value-name leng))))
    
    ))
  
;;;values and fields
;(define Nas_identifier-value (make-parameter #"eCampus2.0.40.16"))
(define-field&value Nas_identifier  #"eCampus2.0.40.16")
;请求状态 
(define-field&value acct_status_type (bytes 0 0 0 1))

;;;接入认证 0x2d
(define acct_authentic-value (make-parameter (bytes 0 0 0 1)))
(define-field  acct_authentic acct_authentic-value)
;;;nas端口类型 0x3d
(define nas_port_type-value (make-parameter (bytes 0 0 0 #x0f)))
(define-field  nas_port_type nas_port_type-value)
;;nas 端口 0x05 0x00,0x00,0x00,0x03 为国内外资源，0x00,0x00,0x00,0x01 为校内资源
(define nas_port-value (make-parameter (make-bytes 4 0)))
(define-field  nas_port nas_port-value)
;;对话维持时间 0x2e
(define acct_session_time-value (make-parameter (make-bytes 4 0)))
(define-field  acct_session_time acct_session_time-value)
;广播地址 (define (get-my-Broadcast)#f)
(define Broadcast-value (make-parameter (bytes 0 0 0 0)))
(define-field Broadcast  Broadcast-value)
;子网掩码 (define (get-my-netmask)#f)
(define Framed_ip_netmask-value (make-parameter (bytes 0 0 0 0)))
(define-field Framed_ip_netmask  Framed_ip_netmask-value)
;;;服务类型
(define Service_type-value (make-parameter(bytes 0 0 0 2)))
(define-field Service_type  Service_type-value)

;帧协议 
(define Framed_protocol-value (make-parameter (bytes 0 0 0 1)))
(define-field Framed_protocol  Framed_protocol-value)
;ip地址 #x08
;(define (get-my-ip)  #f)
(define FramedIpAddress-value (make-parameter (bytes 0 0 0 0)))
(define-field FramedIpAddress  FramedIpAddress-value)

;网卡mac
;(define(get-my-mac)#f)
(define CallingStationId-value (make-parameter (make-bytes 14 0)))
(define-field CallingStationId  CallingStationId-value)
;;;挑战字
(define ChapChallenge-value (make-parameter (make-bytes 32 0)));32位随机
(define-field ChapChallenge  ChapChallenge-value)
;会话标识id 0x2c 与ip地址有关 parameter 只有一层
;断开重连 此项要改变
(define(acct_session_id-value) (bytes-append (md5 (FramedIpAddress-value)#f)
                                                            #"_"
                                                            (subbytes (ChapChallenge-value) 0 15)))
(define-field  acct_session_id acct_session_id-value)
;本地路由 (define(get-my-FramedRoute)#f)  0x31,0x37,0x32,0x2e,0x31,0x39,0x31,0x2e,0x31 172.19.91.1
(define FramedRoute-value (make-parameter  #"172.19.91.1"))
(define-field FramedRoute  FramedRoute-value)

(define  UserName-value (make-parameter (make-bytes 9 0)))
(define-field UserName UserName-value 11)

(define Password (make-parameter #"000000"))
(define (Chap_password-fields)
  (let((chap_password-id (Find-id 'Chap_password))
       (chap_password-length (+ 3 16))
       (chap-id (Find-id 'Chap)))
  (bytes-append (bytes chap_password-id chap_password-length  chap-id)
                (md5 (bytes-append (bytes chap-id)
                                   (Password)
                                   (ChapChallenge-value))#F))))

(define  Request (make-parameter (bytes #x01)))
(define  Identifier (make-parameter (bytes #x00)))
(define  Packet-length (make-parameter (bytes #x00 #xa1)))
(define  Authenticator (make-parameter (make-bytes 16 0)));随机16字节认证字
;;;;;;;;;;;;;;;;;;;;;;;包构造;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;接入请求;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define(Packet-Access)
  (parameterize([Request (bytes #x01)]
                [Identifier (bytes #x66)]
                [Packet-length (bytes #x00 #xa1)])
  (bytes-append  
     (Request);    //接入请求报文 0x01
     (Identifier);   //发送接入请求报文时，该值为一字节随机值，用以标识，其他时候为0
     (Packet-length); //包长度 161字节 0x00a1
     (Authenticator); //随机16字节认证字
     (UserName)
     (Nas_identifier)
     (CallingStationId)
     (Chap_password-fields)
     (ChapChallenge)
     (Broadcast)
     (FramedIpAddress)
     (Framed_ip_netmask)
     (FramedRoute)
     (Service_type)
     (Framed_protocol))))

;;;;;;;;;;;;;;;;;;;;;;计费请求;;;;;;;;;;;;;;;;;;;;;;;;;;
(define (Packet-accounting-public)
  (parameterize([Request (bytes #x04)]
                [Identifier (bytes #x00)]
                [Authenticator (make-bytes 16 0)])
   (bytes-append  
     (Request);    //接入请求报文 0x01
     (Identifier);   //发送接入请求报文时,该值为一字节随机值,用以标识,其他时候为0
     (Packet-length); //包长度 161字节 0x00a1
     (Authenticator); //随机16字节认证字
     (UserName)
     (Nas_identifier)
     (CallingStationId)
     (acct_status_type)
     (FramedIpAddress)
     (acct_session_id)
     (acct_authentic)
     (nas_port_type)
     (nas_port))))

(define(Packet-accounting-request)
  (parameterize([Packet-length (bytes #x00 #x81)])
  (Packet-accounting-public)))

(define (number->bytes num)
  (bytes (bitwise-bit-field num 32 40)
         (bitwise-bit-field num 16 32)
         (bitwise-bit-field num 8 16)
         (bitwise-bit-field num 0 8)
         ))
;;;;;;;;;;;;;;;;;计费维持;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define(Packet-accounting-update time) 
  (parameterize([Packet-length (bytes #x00 #x87)]
                [acct_session_time-value (number->bytes time)])
    (bytes-append
     (Packet-accounting-public)
    (acct_session_time)
    )))

(define (make-Packet-accounting-update-keep time)
  (parameterize([acct_status_type-value  #"0003"])
    (Packet-accounting-update time)))

(define (make-Packet-accounting-update-stop time)
  (parameterize([acct_status_type-value #"0002"])
    (Packet-accounting-update time)))
 ; (make-Packet-accounting-update-keep 0)