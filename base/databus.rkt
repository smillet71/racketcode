#lang racket 

; 
(require "component.rkt")

;
(provide databus%)

; definition of a suscriber/publisher object 
(define databus%
  (class object% 
    
    ; initialization arguments
    (init)                
    
    ; fields ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (define topics (make-hash))
    
    ; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ; superclass initialization
    (super-new)                
    
    ; accessors ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    (define/public (get-topics) topics)
    (define/public (has-topic topic) 
      (if (hash-has-key? topics topic)
          #t
          #f))
    
    ; methods ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    ; subscribe to a topic
    (define/public (subscribe subscriber topic) 
      (when (not (is-a? subscriber component%))
        (error "databus:subscribe - subscriber shoud be a component"))
      (if (hash-has-key? topics topic)
          (let ((subscribers (hash-ref topics topic)))
            (hash-set! topics topic (cons subscriber subscribers)))
          (let ((subscribers (list subscriber)))
            (hash-set! topics topic subscribers))))
    
    ; unsubscribe from a topic
    ; topic is remover if no more subscribers
    (define/public (unsubscribe subscriber topic) 
      (when (not (is-a? subscriber component%))
        (error "databus:unsubscribe - subscriber shoud be a component"))
      (when (hash-has-key? topics topic)
          (let ((subscribers (hash-ref topics topic)))
            (set! subscribers (remove subscriber subscribers))
            (if (null? subscribers) 
                (hash-remove! topics topic)
                (hash-set! topics topic subscribers))))
      )
    
    ; send a msg to subscribers of a particular topic
    (define/public (send-msg topic msg) 
      (when (hash-has-key? topics topic)
        (let ((subscribers (hash-ref topics topic)))
          (map (lambda (component) (send component receive topic msg)) 
               subscribers))))
    
    
    ))