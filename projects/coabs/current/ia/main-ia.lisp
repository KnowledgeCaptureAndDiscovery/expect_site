(in-package "EXPECT")

;;; Author: Jihie Kim
;;; 
;;; ******************************************
;;; Switches for the Knowledge Acquisition ***
;;; ******************************************

;; todo: init given kb
(defun initialize-ia (&key kb)
  (setq *temporary-concepts* nil)
  (setq *local-method-errors* nil)
  (setq *mkb-method-kb* nil)
  (setq *mkb-messages* nil)
  (setq *all-messages* nil)
  (clean-method-kb)
  (mkb-start-method-edit)
  t
  )
   
(defun mkb-verbose ()
  (setq *mkb-verbose* t)
  t)

(defun mkb-quiet ()
  (setq *mkb-verbose* nil)
  t)

(defun mkb-verbose-p ()
  *mkb-verbose*)

(defun mark-temporary-concept (concept-name)
  (push concept-name *temporary-concepts*)
  )

(defun clean-method-kb ()
  (dolist (concept-name *temporary-concepts*)
    (kb-delete-concept concept-name))
  t
  )

;; load initial kb to mkb
(defun load-plan-kb-to-mkb (plan-kb)
  (let ((system-plan-names (ka-find-all-system-plan-names)))
    (dolist (ps-plan plan-kb)
      (if (not (member (car ps-plan) system-plan-names)) 
	  ;; exclude system method
	  (check-and-create-plan-1 (first (cdr ps-plan)) :each nil)
	))))
       
(defun mkb-load-all-system-plans ()

  (setq *defining-system-plans* 't)
  (mkb-load-plans *system-plans*)
  (setq *defining-system-plans* nil)
  )

;; called when loading a domain
(defun load-all-plans-to-ia ()
  ;(initialize-ia)
  ;(mkb-load-all-system-plans)
  ;(dolist (plan *domain-plans*)
  ;  (check-and-create-plan-1 (create-plan-from-desc plan) :each nil))
  (ps-build-method-relation-tree-all)
  )

(defun mkb-load-plans (plans-in-list)
  (dolist (plan plans-in-list)
    (let ((new-plan (create-plan-from-desc plan)))
      (add-new-plan-to-mkb new-plan))))

;;******************************************************************
;; add, modify, delete, check a method
;;******************************************************************

;;; this is called from the client to check plan syntax
(defun check-and-modify-plan (plan-in-string &key context (each 't))
   (let ((*package* (find-package "EXPECT"))
	(modified-p nil)
	(t-plan-name nil)
	)
     (setq *mkb-messages* nil)
     (if (invalid-lisp-object plan-in-string)
	 (signal-message 'invalid-expr nil nil)
       (let* ((plan-in-list (read-from-string plan-in-string))
	      (new-plan (create-plan-from-desc plan-in-list))
	      (plan-name (get-plan-name new-plan))
	      (old-plan (ka-find-plan plan-name *mkb-method-kb*))
	      (form-errors (get-errors-in-method-form new-plan)))
      
	 (cond ((null plan-name)
		(signal-message 'missing-id plan-name nil))
	       ((not (null form-errors)) ;; does not satisify basic form
		nil)
	       ((cannot-parse (get-plan-capability new-plan) plan-name)
		(signal-message 'cannot-parse-capability plan-name
				(get-plan-capability new-plan)))
	       (t 
		(setq modified-p 't)
		(if (null old-plan)
		    (signal-message 'not-found plan-name nil))
		(update-and-check-plan new-plan old-plan)
		))
	 (setq t-plan-name plan-name)
	 (if (and modified-p
		  each) ;; processing each method
	     (update-ps-relations))))
      (if *mkb-verbose* (if *problem-solver-verbose* (format *terminal-io* "~% errors: ~S" *mkb-messages*)))
      (add-messages *mkb-messages*)
      (send-messages *mkb-messages* modified-p t-plan-name))
   )

(defun get-errors-for-plan (plan-name-in-string &key context)
   (let ((*package* (find-package "EXPECT"))
	(t-plan-name nil)
	)
     (setq *mkb-messages* nil)
     (if (invalid-lisp-object plan-name-in-string)
	 (signal-message 'invalid-expr nil nil)
       (let* ((plan-name (read-from-string plan-name-in-string))
	      (ka-plan (ka-find-plan plan-name *mkb-method-kb*))
	      (form-errors (get-errors-in-method-form ka-plan)))
	 (cond ((null plan-name)
		(signal-message 'missing-id plan-name nil))
	       ((not (null form-errors)) ;; does not satisify basic form
		nil)
	       ((cannot-parse (get-plan-capability ka-plan) plan-name)
		(signal-message 'cannot-parse-capability plan-name
				(get-plan-capability ka-plan)))
	       (t 
		(setq *mkb-messages* (append *mkb-messages*
					     (psr-parse-plan-and-find-errors ka-plan)
					     (analyze-plan-locally ka-plan)
					     ))
		))
	 (setq t-plan-name plan-name)))
	 (if *mkb-verbose* (if *problem-solver-verbose* (format *terminal-io* "~% errors: ~S" *mkb-messages*)))
	 (add-messages *mkb-messages*)
	 (send-messages *mkb-messages* 't t-plan-name))
   )


;;; this is called from the client to check plan syntax
(defun modify-or-create-plan (plan-in-string &key context (each 't))
  (let ((*package* (find-package "EXPECT"))
	(processed-p nil)
	(t-plan-name nil)
	)
    (setq *mkb-messages* nil)
    (if (invalid-lisp-object plan-in-string)
	(signal-message 'invalid-expr nil nil)
      (let* ((plan-in-list (read-from-string plan-in-string))
	     (new-plan (create-plan-from-desc plan-in-list))
	     (plan-name (get-plan-name new-plan))
	     (old-plan (ka-find-plan plan-name *mkb-method-kb*)))

	(when (null (get-errors-in-method-form new-plan)) ;; satisifies basic form
	  (cond ((null plan-name)
		 (signal-message 'missing-id plan-name nil))
		((cannot-parse (get-plan-capability new-plan) plan-name)
		 (signal-message 'cannot-parse-capability plan-name
				 (get-plan-capability new-plan)))
		((null old-plan) ;; create a new plan
		 (setq processed-p 't)
		 (update-and-check-plan new-plan))
		(t               ;; modify existing plan
		 (setq processed-p 't)
		 (update-and-check-plan new-plan old-plan)
		 )))
	(setq t-plan-name plan-name)
	(if (and processed-p
		 each)        ;; processing each method
	    (update-ps-relations))))
    (if *mkb-verbose* (if *problem-solver-verbose* (format *terminal-io* "~% errors: ~S" *mkb-messages*)))
    (add-messages *mkb-messages*)
    (send-messages *mkb-messages* processed-p t-plan-name))
  )
	    
 
;; this is called from the client to check plan syntax
(defun check-and-create-plans (plans)
  (dolist (plan plans)
    (check-and-create-plan-1 (create-plan-from-desc plan)
			     :each nil))
  (update-ps-relations)
  )

(defun check-and-create-plan (plan-in-string &key context)
  (let ((*package* (find-package "EXPECT")))
    (cond ((invalid-lisp-object plan-in-string)
	   (signal-message 'invalid-expr nil plan-in-string)
	   (add-messages *mkb-messages*)
	   (send-messages *mkb-messages* nil nil))
	  (t (check-and-create-plan-1
	      (create-plan-from-desc
	       (let ((*package* (find-package "EVALUATION")))
		 (read-from-string plan-in-string)))
	       :context context)))
	))

(defun check-and-create-plan-1 (new-plan &key context (each 't))
    (let* ((plan-name (get-plan-name new-plan))
	   (old-plan (ka-find-plan plan-name *mkb-method-kb*))
	   (create-p nil))
      (setq *mkb-messages* nil)
      (if (null plan-name) ;; if there is no name, create one
	  (set-plan-name new-plan (gentemp "_method")))
      ;;(if *problem-solver-verbose* (format *terminal-io* "~% new plan ~S" new-plan))

      (when (null (get-errors-in-method-form new-plan)) ;; satisifies basic form
	(cond ((not (null old-plan))
	       (signal-message
		'duplicated-method-name (get-plan-name new-plan) nil))
	      ((mkb-find-same-method (create-desc-from-plan new-plan))
	       (signal-message
		'duplicated-method (get-plan-name new-plan) nil))
	      ((cannot-parse (get-plan-capability new-plan) plan-name)
	       (signal-message 'cannot-parse-capability plan-name
			       (get-plan-capability new-plan)))
	      (t (setq create-p 't)
		 (update-and-check-plan new-plan)
		 )))
      (if (and create-p
	       each)        ;; processing each method
	       (update-ps-relations))
      (if *mkb-verbose* (if *problem-solver-verbose* (format *terminal-io* "~% errors: ~S" *mkb-messages*)))
      (add-messages *mkb-messages*)
      (send-messages *mkb-messages* create-p plan-name)
      ))


;;;;;;;;;;;;;;;;;;;

(defun delete-plan (name-in-string &key context (each 't))
  (let ((*package* (find-package "EXPECT"))
	(delete-p nil)
	(name nil))
    (if (invalid-lisp-object name-in-string)
	(signal-message 'invalid-expr nil nil)
      (let* ((name (read-from-string name-in-string))
	     (plan (ka-find-plan name *mkb-method-kb*)))
	(setq *mkb-messages* nil)
	(cond ((null plan)
	       (signal-message 'not-found name nil))
	      (t (setq delete-p 't)
		 (delete-mkb-method plan)
		 (setq *mkb-method-kb* (remove name *mkb-method-kb*))
		 (if (ka-find-plan name)
		     (process-remove-plan (list name)))
		 (delete-messages-on-plan name)
		 ))
	(if (and delete-p
		 each)        ;; processing each method
	    (update-ps-relations))))
    (send-messages *mkb-messages* delete-p name)
  ))
    


(defun mkb-find-same-method (plan-desc)
  (mkb-find-same-method-1 plan-desc *mkb-method-kb*))

(defun mkb-find-same-method-1 (plan-desc methods)
  (if (null methods)
      nil
    (let ((old-plan-desc
	   (create-desc-from-plan (second (first methods)))))
      (cond ((equal plan-desc old-plan-desc)
	     (second (first methods)))
	    (t (mkb-find-same-method-1 plan-desc (rest methods)))))))


(defun get-errors-in-method-form (plan)
  (let ((errors nil)
	(plan-name (get-plan-name plan))
	(capability (get-plan-capability plan)))
    (cond ((null capability)
	   (setq errors (append errors
			       (list (signal-message 'missing-capability
						     plan-name nil)))))
	  ((not (and (symbolp plan-name) (listp capability)))
	   (setq errors (append errors
				(list (signal-message 'cannot-parse-capability
						      plan-name
						      capability)))))
	  (t nil))
    (if (null (get-plan-result plan))
	(setq errors (append errors
			     (list (signal-message 'missing-result-type
						   plan-name nil)))))
    (if (null (get-plan-method plan))
	(setq errors (append errors
			     (list (signal-message 'missing-method-body
						   plan-name nil)))))
    
    errors)
  )



(defun update-and-check-plan (plan &optional (old-plan nil))
  (if (null old-plan)
      (add-new-plan-to-mkb plan)
    (modify-plan-in-mkb plan old-plan))

  (process-store-plan (list plan)) ;; add or modify
                                   ;; remove duplicate error check
  (setq *mkb-messages* (append *mkb-messages*
			       *psr-errors*;remove duplicate error check ; (psr-parse-plan-and-find-errors plan)
                                           ;;; don't touch ontology!
			       *analyzer-errors* ;remove duplicate error check;(analyze-plan-locally plan)
			       )))



(defun add-new-plan-to-mkb (plan)
  (push (list (get-plan-name plan) plan) *mkb-method-kb*)
  (add-mkb-method plan))

(defun delete-messages-on-plan (name)
  (let ((result nil))
    (dolist (msg *all-messages*)
      (let ((plan-name
	     (if (mkb-message-p msg)
		 (mkb-message-plan-name msg)
	       (get-plan-name-in-error-condition msg))))
	(if (not (eq plan-name name))
	    (push msg result))))
    (setq *all-messages* result)
    ))

(defun modify-plan-in-mkb (new-plan old-plan)
  (let ((plan-name (get-plan-name old-plan)))
    (modify-mkb-method new-plan old-plan)
    (rplacd (assoc plan-name *mkb-method-kb*)
	    (list new-plan))
    (delete-messages-on-plan plan-name))
  )
  
;; TTD; sync KB: load methods into KA

(defun load-mkb-methods()
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; build new data structures
;;;     *mkb-ps-undefined-goal-list*
;;;     *mkb-ps-method-relation-tree-root* 
;;;     *mkb-ps-potential-match-for-incomplete-goals*

(defvar *mkb-ps-collected-mr-tree-root* nil)
(defvar *mkb-ps-collected-potential-match* nil)

(defun update-ps-relations ()
  (setq *applied-potential-match* nil) ;; currently, we are not using this
  (ka-process-ps-tree)
  ;(ps-build-method-relation-tree)
  ;; this is a hack
  ;(setq *mkb-ps-collected-mr-tree-root*
	;*mkb-ps-method-relation-tree-root*)
  ;; TTD use this for propagating constraints...
  ;(setq *mkb-ps-collected-potential-match*
	;*mkb-ps-potential-match-for-incomplete-goals*)
  (ps-build-method-relation-tree-all)
  )

#|
;; for this experiment
(defun update-ps-relations ()
  (ka-process-ps-tree)
  )
|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; post processing of NL edit operation (6/2000)

(defun post-process-nl-edit-for-ia (method-name-in-string)
  (if (invalid-lisp-object method-name-in-string)
      (signal-message 'invalid-expr nil nil)
    (let ((method-name (read-from-string method-name-in-string)))
      (if (ka-find-plan method-name)
	  (update-and-check-plan (ka-find-plan method-name)
				 (ka-find-plan method-name *mkb-method-kb*)))
      ))
  (update-ps-relations)
  "done")


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  for the methods add/modify by 'shared-ka-process-plan-modification'
;;   to inform interaction analyzer about method changes
;; 
(defun process-plan-in-ia (command)
  (let* ((command-operation (first command))
	 (args (rest command))
	 )
    (case command-operation
      (accept-new-plan 
       (add-new-plan-to-mkb (first args))
       )
      ((accept-plan substitute-plan)
       (let* ((plan (first args))
	      (old-plan (ka-find-plan (get-plan-name plan) *mkb-method-kb*)))
	 (if old-plan
	     (modify-plan-in-mkb plan old-plan)
	   (add-new-plan-to-mkb plan)))
       )
      (remove-plan
       (let ((bad-plan-name (first args)))
	 (when (ka-find-plan bad-plan-name *mkb-method-kb*)
	   (delete-mkb-method plan)
	   ))
       )
      ((change-steps-in-plan add-param-in-capability-to-plan
	remove-step-from-plan add-to-plan-new-step add-to-plan-step-similar-to
	add-to-plan-check-also-new-step add-to-plan-check-also-step-similar-to
	)
       ;;
       ;;(let ((old-plan (ka-find-plan (get-plan-name plan) *mkb-method-kb*)))
       ;; (if old-plan
       ;;     (modify-plan-in-mkb plan old-plan)
       ;;   (add-new-plan-to-mkb plan)))
       )
      )

    ))