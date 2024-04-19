;; **********************
;;  3/23 
;; **********************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; in kanal.lisp


;; based on Jerome's suggestion
(defun find-error-item-1 (error-id error-items)
  (assert error-items (error-id) "The error id ~A was not found" 
error-id)
  (if (equal (cdr (assoc 'id (first error-items)))
	     error-id)
      (first error-items)
    (find-error-item-1 error-id (rest error-items))))

(defun init-kanal ()
  (setq *kanal-log-stream* (make-string-output-stream)) 
  ;(setq *kanal-log-stream* *trace-output*)
  (build-action-table))

;; **********************
;;  3/26 
;; **********************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;kanal.lisp:

;; testing preconditions
(defun triple-consistent-with-kb (triple &optional (situation nil))
  (let ((obj (get-object triple))
	(role (get-role triple))
	(val (get-val triple)))
    (if situation 
      (km-k `(#$in-situation ,situation ((#$a #$Thing with (,role (,val))) #$&? ,obj)))
    (km-k `((#$a #$Thing with (,role (,val))) #$&? ,obj)))
    ))

(defun assert-triple (triple &optional (situation nil))
  (let ((obj (get-object triple))
	(role (get-role triple))
	(val (get-val triple)))
    (if situation 
      (km-k `(#$in-situation ,situation ((#$a #$Thing with (,role (,val))) #$& ,obj)))
    (km-k `((#$a #$Thing with (,role (,val))) #$& ,obj)))
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; process-handler.lisp
(defun simulate-step (event situation disjunctive? &optional (stream *kanal-log-stream*))
  (when disjunctive?
    (kanal-format stream "~%~% ++++++++++++++++++++++++++++++++++++++")
    (kanal-format stream "~%  Start simulating a disjunctive path~%")
    (kanal-format stream " ++++++++++++++++++++++++++++++++++++++~%"))
  (kanal-format stream "~%~%  -----------------------------------------------------------")
  (kanal-format stream "~%  step: ~S" event)
  (kanal-format stream "~%  -----------------------------------------------------------~%")
  
  (goto situation)
  (let* ((preconditions (get-preconditions event))
	 (curr-situation (current-situation))
	 (test-results (test-preconditions preconditions curr-situation event))
	 (failed-preconditions (first test-results))
	 (invalid-preconditions (second test-results))
	 (inexplicit-preconditions (third test-results))
	 (succeeded-preconditions (set-difference preconditions inexplicit-preconditions :test #'equal))
	 )
    
    
    (cond (failed-preconditions
	   (kanal-format stream "   failed preconditions: ~S~%"  failed-preconditions)
	   ;(kanal-format stream "~% the step was not performed because of unachieved preconditions~%")
	   ;(propose-fixes-for-failed-preconditions)
	   (dolist (pc failed-preconditions)
	     (generate-error-checker-item
	      (list pc) ':precondition ':error nil event))
	   (setq *failed-event-info*
		 (list ':precondition event failed-preconditions))
	   'fail
	   )
	  (invalid-preconditions
	   'fail)
	  (t
	   (when succeeded-preconditions
	       (kanal-format stream "~&   succeeded preconditions:~S ~%" succeeded-preconditions)
	       (generate-error-checker-item succeeded-preconditions ':precondition ':error 't event)
	       (find-causal-link succeeded-preconditions curr-situation event)
	       )
	   
	   (kanal-format stream "~% ... EXECUTE ~a in ~a..." event curr-situation)
	   (let ((del-list (get-triple-values
			    (get-the-del-list event)))
		 (add-list (get-triple-values
			    (get-the-add-list event)))
		 (prev-situation curr-situation))  
	     (execute-step event)
	   
	     
	     ;(check-delete-list del-list curr-situation event stream)
	     (check-step-effects add-list del-list event stream)
	     (kanal-format stream "~%      deleting ~S" del-list)
	     (kanal-format stream "~%      adding ~S" add-list)
	     
	     (setq curr-situation (current-situation))
	     (kanal-format stream " becoming ~a~%" curr-situation)
	    
	     (cond ((null
		     (collect-simulated-event event situation curr-situation
					      del-list add-list))
		    
		    'loop-found)
		   (t
		    ;; todo: currently loops are detected but not executed
		    ;;  and kanal checks delete list only for the first
		    ;;  occurrence of the same event
		    (check-delete-list del-list prev-situation event stream)
		    (current-situation)))
	     )
	   )
	  )
    ))

;; info on step effects
(defun check-step-effects (add-list del-list event &optional (stream *kanal-log-stream*))
  (cond ((and (null add-list)
	      (null del-list))
	 (kanal-format stream "~%~% WARNING : no effect was produced by ~S~%"  event)
	 (generate-error-checker-item nil
				      ':no-effect
				      ':warning
				      nil
				      event))
	(t
	 (generate-error-checker-item (list add-list del-list)
				      ':no-effect
				      ':warning
				      t
				      event))
    )
  
  )

;; ================================================================
;; After T2
;; ================================================================

;; **********************
;;  4/3/2001
;; **********************
;;  record time info in the log
;;  record the definition of the model tested in the log

(import '(
	  USER::write-frame
	  ) )

(defun get-time-in-string ()
  (multiple-value-bind
   (s m h d mo y) (get-decoded-time)
   (format nil "~d/~d/~d  ~d:~d:~d" y mo d h m s)))

(defun print-concept (concept &optional (stream *kanal-log-stream*))
  (princ (write-frame concept) stream)
  )

(defun test-knowledge (concept &key (cwa nil))
  (kanal-format *kanal-log-stream* "~%~% ===============================================")
  (kanal-format *kanal-log-stream* "~% start test-knowledge ~%~S~%~%" (get-time-in-string))
  (print-concept concept  *kanal-log-stream*)
  (init-test)
  (setq *kanal-verbose* t)
  (setq *model-to-test* concept)
  (setq *interaction-mode* 'no-interaction)
  (setq *execution-mode* 'primitive-steps-only)
  ;(setq *execution-mode* 'all-steps)
  (if (null cwa) 
      (setq *test-with-closed-world-assumption* nil)
    (setq *test-with-closed-world-assumption* t)
    )
   
  (initialize-test-options)
  (test-process-model)
  (kanal-format *kanal-log-stream* "~% Test Output ~%~S" (append *error-checker-items* *info-items*))
  (append *error-checker-items* *info-items*)
  )

(defun get-proposed-fixes (error-id)
  (kanal-format *kanal-log-stream* "~%~% ===============================================")
  (kanal-format *kanal-log-stream* "~% ~S -- Getting fixes for ~S~%" (get-time-in-string) error-id)
  (setq *fix-items* nil)
  (setq *error-report-silent* t)
  (let* ((error-item (find-error-item error-id))
	 (type (cdr (assoc 'type error-item)))
	 (source (cdr (assoc 'source error-item))))
    (if (cdr (assoc 'success error-item))  ;; no need to fix
	nil
      (case type
	((:precondition :inexplicit-precondition)
	 (find-fixes-for-failed-precondition
	  (first (cdr (assoc 'constraint error-item))) ;; triples
	  source)
	 )
	(:expected-effect
	 (find-fixes-for-unachieved-effect
	  (first (cdr (assoc 'constraint error-item)))) ;; triples
	 )
	(:undoable-event
	 (find-fixes-for-undoable-event source)
	 )
	(:missing-link
	 (find-fixes-for-missing-link (cdr (assoc 'constraint error-item)) source)
	 )
	(:cannot-delete
	 (find-fixes-for-delete-error (cdr (assoc 'constraint error-item)) source)
	 )
	(:unreached-events
	 (find-fixes-for-unreached-events (cdr (assoc 'constraint error-item)) source)
	 )
	(:no-effect
	 (find-fixes-for-effectless-event source)
	 )
	(:invalid-expr
	 (find-fixes-for-invalid-expr (cdr (assoc 'constraint error-item)) source)
	 )
	(:not-exist
	 (find-fixes-for-not-exist (cdr (assoc 'constraint error-item)) source)
	 )
	(:loop
	 (find-fixes-for-loop (cdr (assoc 'constraint error-item)) source)
	  )
	(:unnecessary-link
	 (find-fixes-for-unnecessary-link  (cdr (assoc 'constraint error-item)) source)
	 )
	)
      ))
  (setq *error-report-silent* nil)
  (kanal-format nil "~% FIX ITEMS ~%~S" *fix-items*)
  *fix-items*
  )

;; **********************
;;  4/4/2001
;; **********************

(defun check-unnecessary-ordering-constraints-1 (event-list results-so-far)
  
  (let ((current (first event-list))
	(step-after (first (rest event-list)))
	(result results-so-far))
    (when event-list 
      (if step-after 
	  (unless (enabled? current step-after)
	    (setq result (append result (list (list current 'before step-after))))))
      (setq result (check-unnecessary-ordering-constraints-1 (rest event-list) result))
      )
    result)
  )