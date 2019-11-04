#lang racket
(require "configurator/main.rkt"
         "connect-machines/main.rkt"
         racket/gui
         racket/date
         file/zip
         file/unzip)

;主配置
(make-directory* "config")
(define-main-configurer main-config xml-configurer% 
                                'DrEcampus-configure
                                    "config\\frame-config.xml"
                                   (lambda(x)(void)))

(define-main-config user-language "english")

;语言配置


(define-sub-configurer  language-translate-config (main-config-init-sub 'language-translate))


;支持列表
(define-sub-configurer language-supported-config (main-config-init-sub 'language-supported))
;翻译



(define-init-configurer english-config (language-translate-config-init-sub 'english))

(define-init-configurer chinese-simplify-config (language-translate-config-init-sub 'chinese-simplify))

(init-language-supported-config! 'english "english")
(init-language-supported-config! 'chinese-simplify "简体中文")

(define current-language-native-format (get-language-supported-config (string->symbol user-language)))


(define-immutable-configurer  current-language-config (language-translate-config-immutable-sub (string->symbol user-language)))

(init-english-config! 'mainframe-label  "DrEcampus")
(init-chinese-simplify-config! 'mainframe-label "DrEcampus")
(define-current-language-config mainframe-label "DrEcampus")
(define mainframe (new frame%
                   [label  mainframe-label]
                   [width  250]
                   [height 100]
                   [style '(no-resize-border)]
                   [alignment '(center  center)]
                   
                   [x 500]
                   [y 270]
                   ))

(define menu-bar (new menu-bar%	 
   	 	[parent mainframe]))

;--------------------------------------------------------------
(init-english-config! 'file-label "file")
(init-chinese-simplify-config! 'file-label "文件")
(define-current-language-config  file-label "file")

(define file-menu (new menu%
             [label file-label]
             [parent menu-bar]
             ))


(init-english-config! 'load-file-label "load config file")
(init-chinese-simplify-config! 'load-file-label "载入配置文件")

(init-english-config! 'export-file-label "export config file")
(init-chinese-simplify-config! 'export-file-label "导出配置文件")

(define-current-language-config  load-file-label "load config file")

(define-current-language-config  export-file-label "export config file")

(define load-config-menu 
  (new menu-item%
             [label load-file-label]
             [parent file-menu]
             [callback (lambda(e c) 
                         (let([infile (get-file #f #f #f #f #f '()  '(("zip file" "*.zip")))])
                           (when infile
                             (copy-file infile "./config.zip")
                             (zip    (format "./config_back~a.zip" (current-seconds))"./config")
                             (delete-directory/files "./config")
                             (unzip "./config.zip")
                             (delete-file "./config.zip"))))]
             ))

(define export-config-menu 
  (new menu-item%
             [label  export-file-label]
             [parent file-menu]
             [callback (lambda(e c)
                         (let([out-file (put-file #f #f #f #f #f '()  '(("zip file" "*.zip")))])
                           (when out-file
                             (zip out-file "./config"))))]
             ))
;--------------------------------------------------------------
(init-english-config! 'view-label "view")
(init-chinese-simplify-config! 'view-label "查看")
(define-current-language-config  view-label "view")



(define view (new menu%
             [label view-label]
             [parent menu-bar]))
(init-english-config! 'loger-label "log")
(init-chinese-simplify-config! 'loger-label "日志")
(define-current-language-config loger-label "log")

(define-syntax-rule (format-file-name spath)
  (parameterize ([date-display-format 'iso-8601])
    (regexp-replace #rx"\\*" spath (date->string (current-date)))))
;
(define log-frame (new frame%
                   [label "log"]
                   [width  500]
                   [height 700]
                   ;[style '(no-resize-border)]
                   [alignment '(center  center)]
                   [x 500]
                   [y 270]
                   ))
(define log-text (new text%))
(define log-display(new editor-canvas% 
                        [parent log-frame]
                        [editor log-text]))

(define loger (new menu%	 
   	 	 [label loger-label]
   	 	 [parent view]))

(init-english-config! 'debug-loger-label "debuglog")
(init-chinese-simplify-config! 'debug-loger-label "debug日志")
(define-current-language-config debug-loger-label "debuglog")
(define debug-loger (new menu-item%
                         [label debug-loger-label]
   	 	         [parent loger]
                         [callback (lambda(e c)
                             (send log-text load-file ecampus:debug-log-file)
                             (send log-frame show #t))]))


(init-english-config! 'info-loger-label "infolog")
(init-chinese-simplify-config! 'info-loger-label "信息日志")
(define-current-language-config info-loger-label "infolog")
(define info-loger (new menu-item%
                         [label info-loger-label]
   	 	         [parent loger]
                         [callback (lambda(e c)
                             (send log-text load-file ecampus:info-log-file)
                             (send log-frame show #t))]))
;-------------------------------------------------------
(init-english-config! 'help-label "help?")
(init-chinese-simplify-config! 'help-label "帮助?")
(define-current-language-config help-label "help?")
(define help (new menu%
             [label help-label]
             [parent menu-bar]))
(init-english-config! 'language-label "language")
(init-chinese-simplify-config!  'language-label "语言")
(define-current-language-config language-label "language")

(define language (new menu%	 
   	 	 [label language-label]
   	 	 [parent help]
                 ))

(init-english-config! 'about-label "about")
(init-chinese-simplify-config! 'about-label "关于")
(define-current-language-config about-label "about")
(define about (new menu-item%	 
   	 	 [label about-label]
                 [parent help]
                 [callback (lambda(e c)(send about-frame show #t))]
                 ))

(define about-frame (new frame%	 
   	 	 [label about-label]
                 [parent mainframe]
                 [width  250]
                 [height 100]
                 [style '(no-resize-border)]
                 [alignment '(center  center)]
                 [x 500]
                 [y 270]
                 ))

(init-english-config!  'author-label "DrEcampus")
(init-chinese-simplify-config! 'author-label  "通用登录设备")
(define-current-language-config author-label "DrEcampus")


(define info(new message% [parent about-frame]
              [label author-label]))

(init-english-config! 'woring-string "woring!")
(init-english-config! 'error-string "error!")
(init-chinese-simplify-config! 'woring-string "警告!")
(init-chinese-simplify-config! 'error-string "错误!")
(init-english-config! 'accecpt-and-exit-string "accecpt and exit?")
(init-english-config! 'language-change-format-string "change frame language from ~a to ~a")
(init-chinese-simplify-config! 'language-change-format-string "将界面语言由 ~a 更改为 ~a")
(define-current-language-config language-change-format-string "change frame language from ~a to ~a")

(init-chinese-simplify-config! 'accecpt-and-exit-string "接受并退出?")
(define-current-language-config woring-string "woring!")
(define-current-language-config error-string "error!")
(define-current-language-config accecpt-and-exit-string "accecpt-and-exit")

(hash-for-each (language-supported-config-table)
               (lambda(a b)(send
                            (new menu-item% 
                            [label b]
                            [parent language]
                            [callback (lambda(e c)
                                        (let((answer(message-box woring-string  (format"~a\n~a"
                                                                                       (format language-change-format-string current-language-native-format b)
                                                                                       accecpt-and-exit-string)#f '(yes-no))))
                                          (when (eq? answer 'yes)
                                            (set-main-config!  'user-language (symbol->string a))
                                            (save-main-config!)
                                            ;(save-current-language-config!)
                                            (exit 0)
                                            )))])
                            enable
                            (if (eq? (string->symbol user-language)a)
                                #f
                                #t))
                                
                 )
          )


(define-main-config username-value "")

(init-english-config! 'username-label "UserName:  ")
(init-chinese-simplify-config! 'username-label "用户名:")

(define-current-language-config username-label "UserName:  ")

(define user-name (new text-field% 
                       [label username-label]
                       [parent mainframe]
                       [init-value username-value]
                       [vert-margin 10]
                       [horiz-margin 10]))

(init-english-config! 'password-label "PassWord:  ")
(init-chinese-simplify-config! 'password-label "密码:   ")
(define-current-language-config  password-label "PassWord:  ")

(define-main-config password-value "" )
  
(define password (new text-field% 
                       [label password-label]
                       [parent mainframe]
                       [style '(single  password)]
                       [init-value password-value]
                       [vert-margin 10]
                       [horiz-margin 10]))

(define resource-port-name-vector #("school" "intestine" "abroad"))
(define (resource-port-name->num name)
  (vector-member name resource-port-name-vector))

(define (num->resource-port-name num)
  (vector-ref resource-port-name-vector num))

(define-main-config resource-port-name "school")
(init-english-config! 'resource-port-label "resource port: ")
(init-chinese-simplify-config! 'resource-port-label "资源端口: ")
(define-current-language-config resource-port-label "resource port: ")

(init-english-config! 'resource-port-choices "school,intestine,abroad")
(init-chinese-simplify-config! 'resource-port-choices "校内,国内,国内外")
(define-current-language-config resource-port-choices "school,intestine,abroad")

(define choices-list (regexp-match* #rx"(?<=^|,).*?(?=,|$)" resource-port-choices))

(define resource-port
  (new choice% [label resource-port-label]
               [parent mainframe]
               [choices choices-list]
               [callback (lambda(e c)(send redirect-resource-port set-string-selection (send resource-port get-string-selection)))]
               [selection 0]
               [min-width 240]
               [min-height 10]
               [style '(horizontal-label)]
               [vert-margin 10]
               [horiz-margin 10]
               ))

(define pane (new pane% [parent mainframe]
                  [alignment '(left center)]
                  [vert-margin  13]
                  ))

(define start-time #f)
(define connect-machine (new ecampus:machine%))
(define(login-handle e)
  (let((code(ecampus:exn:fail:connect-machine-code e)))
    (case code 
      ((0)(message-box error-string "time out! Please check your network!"))
      ((27)(message-box error-string "username or password error!"))
      ((18)(message-box error-string (bytes->string/utf-8(ecampus:exn:fail:connect-machine-respond e))))
      (else (message-box error-string "Unknown error!")))))
(define (loginfunc)
  (with-handlers ([ecampus:exn:fail:connect-machine? login-handle])
    (when (zero? (send connect-machine login (send user-name get-value) (send password get-value) (send  resource-port get-selection)))
    (send mainframe show #f)
    (send loginframe show #t)
    (set! start-time(current-seconds)))
  ))

(init-english-config! 'login-label "LogIn")
(init-chinese-simplify-config! 'login-label "登录")
(define-current-language-config login-label "LogIn")
(define login(new button%
                  [label login-label]
                  [parent pane]
                  [callback (lambda(b e)(loginfunc))] 
                  [horiz-margin 130]
                  [style '(border  )]
                  ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(init-english-config! 'login-title "MyEcampus connected")
(init-chinese-simplify-config! 'login-title "MyEcampus 已连接")
 
(define-current-language-config login-title "MyEcampus connected")
(define loginframe (new frame% 
                   [label "MyEcampus"]
                   [width 200]
                   [height 170]
                   [style '(no-resize-border)]
                   [x 400]
                   [y 200]
                   ))

;----------------------

(define information(new message%
                        [parent loginframe]
                        [label login-title]
                        [vert-margin 10]
                        [horiz-margin 10]
                        ;[min-width 130]
                        ;[min-height 20]
                       ))


(init-english-config! 'redirect-resource-port-label "re direct to:")

(init-chinese-simplify-config! 'redirect-resource-port-label "重定向至: ")

(define-current-language-config redirect-resource-port-label "re direct to:")
(define redirect-resource-port
  (new choice% [label redirect-resource-port-label]
               [parent loginframe]
               [choices choices-list]
               [callback (lambda(e c)
                           (send connect-machine reset-resource-port! (send redirect-resource-port get-selection)))]
               [selection 0]
               [min-width 240]
               [min-height 10]
               [style '(horizontal-label)]
               [vert-margin 10]
               [horiz-margin 10]
               ))

;(init-english-config! login-title "MyEcampus connected")



(define (logoutfunc)
  (send connect-machine logout)
  (send mainframe show #t)
  (send loginframe show #f)
  (set! start-time #f ))



(init-english-config! 'logout-label "Logout")
(define-current-language-config logout-label "Logout")

(define logout(new button%
                  [label logout-label]
                  [parent loginframe]
                  [vert-margin  20]
                  [callback (lambda(b e)(logoutfunc))]
                  ))
(save-main-config!)
(send mainframe show #t)

