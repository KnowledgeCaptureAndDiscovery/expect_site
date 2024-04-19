;;; ======================================================================
;;;		Process and Simulation Handler
;;; ======================================================================
;;; File: process-handler.lisp
;;; Author: Jihie Kim
;;; Date:  Thu Mar 22 15:44:36 PST 2001

(in-package "KANAL")

(defvar *dark-orange* "#ff9933"
  "An orage colour that is readable on a white background in a web page")

;;; ======================================================================
;;;		API to event structure
;;;
;;;  these functions are used in running simulations
;;; ======================================================================

(defun get-parent-events (event)
  ;; role was "parent-event", but the inverse of "subevent" is "subevent-of"
  (get-role-values-with-checking "subevent-of" event nil)
  )

(defun get-next-events (event)
  (get-role-values-with-checking "next-event" event nil))

(defun get-prev-events (event)
  (get-role-values-with-checking "prev-event" event nil))

(defun get-subevents (event)
  (get-role-values-with-checking "subevent" event nil)
  ) 

(defun get-first-subevents (event)
  (get-role-values-with-checking "first-subevent" event nil))

(defun get-disjunctive-next-events (event)
  (get-role-values-with-checking "disjunctive-next-events" event nil))

(defun get-primitive-events (event)
  (get-role-values-with-checking "primitive-actions" event nil))

(defun get-all-subevents (event)
  (get-role-values-with-checking "all-subevents" event nil))


(defun execute-step (event)
  (km-k `(#$do-and-next ,event)))



;;; ======================================================================
;;;		Handle Preconditions
;;; ======================================================================

#|
(defun get-role-values-with-checking (role obj required &optional (stream *kanal-log-stream*))
  (let ((vals (get-role-values obj role)))
    (cond ((null vals)
	   (let ((val-desc (get-role-description obj role)))
	     (cond ((null val-desc) 
		    (when required
		      (kanal-format stream "~% WARNING (missing constraints)~%")
		      (kanal-format stream "  the ~S of ~S isn't defined~%" role obj)
		      (generate-error-checker-item role
						   ':missing-link
						   ':error
						   nil
						   obj)))
		   (t (kanal-format stream "~% ERROR (missing definition)~%")
		      (kanal-format stream "  ~S isn't defined~%" val-desc)
		      (generate-error-checker-item val-desc
						 ':not-exist
						 ':error
						 nil
						 (list role obj)))
		   ))
	   nil
	   )
	  (t
	   vals)))
	   
  )
|#
    
(defun get-role-values-with-checking (role-name obj required &optional (stream *kanal-log-stream*))
  (let* ((role (find-symbol-in-kb role-name))
	 (vals (get-role-values obj role)))
    (cond ((null vals)
	   (let ((val-desc (get-role-description obj role)))
	     (when (and required (not (null val-desc)))
	       (kanal-format-verbose stream "~% ERROR (missing definition)~%")
	       (kanal-format-verbose stream "  ~S isn't defined~%" val-desc)
	       (kanal-html-format-verbose "<br> <font color=\"red\">ERROR (missing definition)<br>~%")
	       (kanal-html-format-verbose "  ~S isn't defined</font>~%"
				    val-desc)
	       (generate-error-checker-item val-desc
					    ':not-exist
					    ':error
					    nil
					    (list role obj)))
	     )
	   nil
	   )
	  (t
	   vals)))
	   
  )


;;; if event is not nil, test the preconditions' validity
(defun test-preconditions (preconditions situation &optional (event nil))
  (let ((failed-preconditions nil)
        (invalid-preconditions nil)
        (inexplicit-preconditions nil))
    (when event
	(kanal-format *kanal-log-stream* "~&   preconditions:~S ~%~%" preconditions)
	(kanal-html-format "<br><font color=\"blue\"><b>Checking Preconditions:</b></font>~%")
	(if (null preconditions)
	    (kanal-html-format " .. there are no preconditions<br>~%")
	  (kanal-html-format "<pre>~{~S~%~}</pre>~%"  preconditions)))
    (dolist (triple preconditions)
      (cond ((and event (invalid-triple triple :precondition event))
	   (push triple invalid-preconditions))
	  (t
	   (collect-failed-exprs-on)
	   (if (null (test-expr triple situation))
	       (cond ((and (null *test-with-closed-world-assumption*)
		         event
		         (triple-consistent-with-kb triple situation))
		    (generate-error-checker-item (list triple) ':inexplicit-precondition ':warning nil event)
		    (let ((object (second triple))
			(role (third triple))
			(val (fourth triple)))
		      (assert-triple triple situation)
		      (kanal-format *kanal-log-stream* 
				"~% WARNING: ~% ~S ~%  ~S ~%     is not explicitly true but consistent with the KB" 
				triple
				(make-sentence-for-triple triple))
		      (kanal-format *kanal-log-stream* 
				"~%    => we will assume it is true and continue ..~%~%")
		      (kanal-html-format "<font color=~S>WARNING: <br>~S<br>~S<br>is not explicitly true, but consistent with the KB~%"
				     *dark-orange*
				     triple (make-sentence-for-triple triple))
		      (kanal-html-format 
		       "<br>    so we will assume it is true and continue<br></font>~%"))
		    (push triple inexplicit-preconditions)
		    )
		   (t 
		    (push triple failed-preconditions))))
	   (collect-failed-exprs-off))))
				;(format t "~&   precondition:~S ~%  --> ~S~%"   preconditions result)
    (list failed-preconditions invalid-preconditions inexplicit-preconditions)
    )
  )

;;; ======================================================================
;;;  Simulate with SADL-lite until we can fully support SADL
;;; ======================================================================
;;;  we consider next-event link as conjunctive.
;;;  ... need more documentation here ...
;;;
;;; 

(defun simulate-steps-with-sadl-lite (steps-to-execute situation)
  (if (null steps-to-execute)
      'done
	    
  (let* ((doable-steps (find-doable-steps steps-to-execute))
	 (undoable-steps (set-difference steps-to-execute
					 doable-steps))
	 (simulation-result nil)
	 (curr-situation nil)
	 )
    (cond ((null doable-steps)
	   ;; there might be loop also
	   (mapcar #'check-loops-from-step undoable-steps)
	   (kanal-format nil "~%cannot progress~%   [steps ~a were undoable this iteration...]~%" 
			 undoable-steps)
	   (kanal-html-format "~%cannot progress~%   [steps ~a were undoable this iteration...]~%" 
			      undoable-steps)
	   (generate-error-checker-item nil :undoable-event :error nil undoable-steps)
	   nil)
	  ((let ((step-selected (first doable-steps)))
	     (setq simulation-result (simulate-step step-selected situation nil))
	     (cond
	      ((equal simulation-result 'fail) nil)
	      ((equal simulation-result 'loop-found)
	       nil);; do something
	      (t ;; step executed fine
	       (setq curr-situation simulation-result)
	       (simulate-steps-with-sadl-lite
		(union (append (rest doable-steps)
			       undoable-steps)
		       (filter-out-top-event
			(find-next-events step-selected)))
		curr-situation))))))
  )))

(defun find-doable-steps (steps)
  (remove-if-not
   #'(lambda (step)
       (every #'has-been-done (find-prev-events step)))
   steps)
  )
(defun check-loops-from-step (step)
  (check-following-steps-for-loop (list step)))

(defun check-following-steps-for-loop (path)
  (let ((next-events (find-next-events (last path))))
    (dolist (e next-events)
      (cond ((member e path) ;; already visited
	     (kanal-format nil "~% loop found to ~S~%" e)
	     (setq *loops-found*
		   (append *loops-found* (list (append path (list e)))))
	     (generate-error-checker-item (list (append path (list e)))
					  ':loop
					  ':warning
					  nil *model-to-test*))
	    (t 
	     (check-following-steps-for-loop (append path (list e)))))
      
      )))
;;; ======================================================================
;;;  Simulate using the ordering constraints and disjunctive links 
;;; ======================================================================
;;;  representation used
;;;    next-event
;;;    prev-event
;;;    disjunctive-next-events
;;;    disjunctive-prev-events
;;;
;;  1. find the first primitive events
;;  2. find the next events
;;     if there are multiple disjunctive events, simulate all the branches 
;;     if there are multiple conjunctive events, simulate the events
;;        and make sure all the previous conjuctive events are done before
;;
;;
;; The details are described at the end of this file


;;; Jim: this function used to treat multiple first-subevents in a
;;; process as disjunctive, since each of the events is put on a
;;; different path. When they are used by UT, they are intended to be
;;; conjunctive. I am augmenting the events so that, effectively, the
;;; first-subevents that are not chosen are available in the same way as
;;; conjunctive next-events, so they can be added to the path. By
;;; leaving all the paths, I'm ensuring that some of the different
;;; possible orders are examined: typically I think only one ordering is
;;; examined for conjunctive next-steps.
(defun simulate-events (events start-situation)
  (cond ((null events) 
	 ;;(format t "~&End of simulation! ~%")
         start-situation)
        (t 
         (simulate-events-1 
	  (make-event-situation-list events start-situation nil)))))

(defun make-event-situation-list (events situation disjunctive?)
  (mapcar #'(lambda (event)
	      (list event situation disjunctive?
		    (unless disjunctive?
		      (remove event events)) ; the other next events - Jim.
		    ))
	  events))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; decide which step to execute based on conjuctive/disjunctive links
;;;  - a modification of simulate-events function from Peter Clark 
;;;
(defun simulate-events-1 (event-situation-list &optional (stream *kanal-log-stream*))
  (let* ((doable-events (find-doable-events event-situation-list))
         (undoable-events (set-difference event-situation-list doable-events
					  :test #'equal))
         (doable-event (first doable-events))
         (curr-situation nil)
         (simulation-result nil)
         (next-events nil))
    (kanal-format *kanal-log-stream* "~% simulate-events-1 ~S~%"
		  event-situation-list)

    ;; simulate the doable event
    (cond ((null doable-event)
	 (kanal-format stream "~%~% THERE IS NO EXECUTABLE EVENT!~%")
	 (kanal-html-format "<br><font color=\"red\"><strong>There is no executable event!</strong></font>~%")
	 )
	  (t
	   (setq simulation-result 
	     (simulate-step (first doable-event) (second doable-event)
			    (third doable-event)))))

    ;; compute next events 
    (cond ((equal simulation-result 'loop-found)
	   (unless (third doable-event);; non disjunctive loop
	     (setq next-events
	       (append 
		(make-event-situation-list
		 (find-next-events-in-loop (first doable-event))
		 (second doable-event) nil)
		next-events))))
	  ((equal simulation-result 'fail) nil)
	  (t 
	   (setq curr-situation simulation-result)
	   ;; depth first, disjunctive events first, for now.
	   (setq next-events
	     (append (make-event-situation-list
		      (filter-out-top-event
		       (find-next-disjunctive-events
		        (first doable-event)))
		      curr-situation t)
		     next-events))
	   (setq next-events 
	     (append (make-event-situation-list
		      (filter-out-top-event
		       (find-next-events (first doable-event)))
		      curr-situation nil)
		     next-events))
	   ;; Jim: adding the other events here
	   (setf next-events
	     (append (make-event-situation-list
		      (fourth doable-event)
		      curr-situation nil)
		     next-events))))
    
    ;; if the action was executed successfully, progress
    (unless (equal simulation-result 'fail) 
      (when undoable-events
	  (kanal-format 
	   stream "~%   [Events ~a were undoable this iteration...]~%" 
	   (mapcar #'first undoable-events))
	  (kanal-html-format "~%<br> Events ~A were undoable this iteration.<br>~%"
			     (mapcar #'first undoable-events)))
      (let* ((next-events-to-simulate 
	      (remove-duplicates
	       (append next-events (rest doable-events) undoable-events)
	       :test #'equal :from-end t)))
        (cond ((equal event-situation-list next-events-to-simulate)
	       (kanal-format stream "Cannot progress -- end the simulation~%")
	       (kanal-html-format "Cannot progress -- end the simulation~%")
	       (dolist (event (mapcar #'first event-situation-list))
		 (generate-error-checker-item
		  nil :undoable-event :error nil event)
		 (setq *failed-event-info*
		   (list :undoable-event event nil)))
	       nil)
	      ((if next-events-to-simulate 
		   (setq simulation-result
		     (simulate-events-1 next-events-to-simulate)))))))
    simulation-result))

     

;;; If there's an after situation, then it's been done.
#|
(defun has-been-done (event)
  (or (has-value (get-after-situation event))
      (every #'has-been-done (get-subevents event)))
      ) 
|#
(defun has-been-done (event)
  (let ((result nil))
    (dolist (path *paths-simulated*)
      (let ((events-simulated (mapcar #'get-event path)))
	(if (member event events-simulated)
	    (setq result 't)
	  )))
    result))

;;; check if all the conjuctive previous events have been done
(defun find-doable-events (event-situation-list)
  (remove-if-not
   #'(lambda (event-situation)
       (every #'has-been-done (get-prev-events (first event-situation))))
   event-situation-list)
  )


;; check if the items to be deleted are in fact true in the current situation 
(defun check-delete-list (del-list situation event &optional (stream *kanal-log-stream*))
  (dolist (del-item del-list)
    (when (and (fourth del-item) ;; checking non-nil value
	       (null (test-expr del-item situation)))
      (kanal-format stream "~% WARNING :cannot-delete~%")
      (kanal-format stream "~%  ~S cannot be deleted because it's not true in the current situation" del-item)
      (kanal-html-format "<br><font color=~S> WARNING: ~S cannot be deleted because it's not true in the current situation</font><br>"
		     *dark-orange* del-item)
      (generate-error-checker-item del-item
				   ':cannot-delete
				   ':warning
				   nil
				   event)
      )
    )
  )

;;; check if there is no effect produced by the step
;;; Only warn if there are no child steps, we're not bothered by
;;; non-primitive events with no effects - Jim.
(defun check-step-effects (add-list del-list event &optional (stream *kanal-log-stream*))
  (cond ((and (null add-list)
	      (null del-list)
	      (null (get-subevents event))
	      )
	 (kanal-format stream "~%~% WARNING : no effect was produced by ~S~%"  event)
	 (kanal-html-format "~%<br><font color=~S> WARNING : no effect was produced by ~S</font><br>~%"
			*dark-orange* event)
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; this function really execute the given step
;;;
(defun simulate-step (event situation disjunctive? &optional (stream *kanal-log-stream*))
  (when disjunctive?
        (kanal-format stream "~%~% ++++++++++++++++++++++++++++++++++++++")
        (kanal-format stream   "~%  Start simulating a disjunctive path~%")
        (kanal-format stream   " ++++++++++++++++++++++++++++++++++++++~%")
        (kanal-html-format "<strong>Start simulating a disjunctive path</strong>~%")
        )
  (kanal-format stream "~%~%  -----------------------------------------------------------")
  (kanal-format stream "~%  step: ~S" event)
  (kanal-format stream "~%  -----------------------------------------------------------~%")

  (kanal-html-format "<br><br><li><strong>Step: ~A</strong><br>" event)

  (if situation (goto situation))
  (let* ((preconditions (get-preconditions event))
         (curr-situation (current-situation))
         (test-results (test-preconditions preconditions curr-situation event))
         (failed-preconditions (first test-results))
         (invalid-preconditions (second test-results))
         (inexplicit-preconditions (third test-results))
         (succeeded-preconditions
	(set-difference preconditions inexplicit-preconditions
		      :test #'equal)))
    
    (cond (failed-preconditions
	 (kanal-format stream "   failed preconditions: ~S~%"  failed-preconditions)
	 (kanal-html-format "<br><font color=\"red\">Failed preconditions:~%")
	 (kanal-html-format "<pre>~S</pre></font><br>~%"
			failed-preconditions)
	 ;;(kanal-format stream "~% the step was not performed because of unachieved preconditions~%")
	 ;;(propose-fixes-for-failed-preconditions)
	 (dolist (pc failed-preconditions)
	         (generate-error-checker-item
		(list pc) ':precondition ':error nil event))
	 (setq *failed-event-info*
	       (list ':precondition event failed-preconditions))
	 (kanal-html-format "</li>~%")
	 'fail
	 )
	(invalid-preconditions
	 (kanal-html-format "</li>~%")
	 'fail)
	(t
	 (when succeeded-preconditions
	       (kanal-format stream "~&   succeeded preconditions:~S ~%" succeeded-preconditions)
	       (kanal-html-format "<font color=\"blue\">Succeeded preconditions:</font>~%")
	       (kanal-html-format "<pre>~{~S~%~}</pre> ~%"
			      succeeded-preconditions)
	       (generate-error-checker-item succeeded-preconditions ':precondition ':error 't event)
	       (find-causal-link succeeded-preconditions curr-situation event)
	       )
	 (kanal-format stream "~% ... EXECUTE ~a in ~a..." event curr-situation)
	 (kanal-html-format "~%<br> EXECUTE ~a in ~a~%"
			event curr-situation)
	 (let ((del-list (get-triple-values
		        (get-the-del-list event)))
	       (add-list (get-triple-values
		        (get-the-add-list event)))
	       (prev-situation curr-situation))
	   (execute-step event)
	   ;;(check-delete-list del-list curr-situation event stream)
	   (check-step-effects add-list del-list event stream)
	   (kanal-html-format "<br><br><font color=\"blue\"><b>Checking Effects:</b></font><br>~%")
	   (kanal-format stream "~%      deleting ~S" del-list)
	   (kanal-html-format "~%<br>      <font color=\"blue\">deleting</font>~%")
	   (if del-list
	       (kanal-html-format "<pre>~{~S~%~}</pre>" del-list)
	     (kanal-html-format ".. nothing to delete"))
	   (kanal-format stream "~%      adding ~S" add-list)
	   (kanal-html-format "~%<br>      <font color=\"blue\">adding</font>~%")
	   (if add-list
	       (kanal-html-format "<pre>~{~S~%~}</pre>" add-list)
	     (kanal-html-format ".. nothing to add"))
  
	   (setq curr-situation (current-situation))
	   (kanal-format stream " becoming ~a~%" curr-situation)
	    
	   (cond ((null
		 (collect-simulated-event event situation curr-situation
				      del-list add-list))
		(kanal-html-format "</li>~%")
		'loop-found)
	         (t
		;; todo: currently loops are detected but not executed
		;;  and kanal checks delete list only for the first
		;;  occurrence of the same event
		(check-delete-list del-list prev-situation event stream)
		(kanal-html-format "</li>~%")
		(current-situation)))
	   )
	 )
	)
    ;; close the list item for this event.
    ;;
    ))

		  

;; filter out the top event for the model itself
(defun filter-out-top-event (events) 
  (remove-if #'(lambda (event)
	       (equal (get-concept-from-instance event) *model-to-test*))
	   events))


#|  this was used to simulate a linear sequence of events
    we don't use this anymore
(defun simulate-linear-actions (events start-situation &optional (stream *kanal-log-stream*))
  (let ((curr-situation start-situation))
    (if (null events)
	(kanal-format stream "~% there is no substep " )
      (progn (kanal-format stream "~% These are the sub-steps: ~%")
	     (print-items-with-space 25 events)))
    (dolist (event events)
      (when curr-situation ;; preconditions of actions not failed
	(setq curr-situation (simulate-step event curr-situation))))
    curr-situation)
  )
|#

;;; ======================================================================
;;;		Compute Causal Links
;;; ======================================================================

;; this collects causal links
(defvar *causal-links* nil)

(defun get-causal-links ()
  *causal-links*)

(defun report-causal-links (&optional (stream *kanal-log-stream*))
  (when *causal-links*
    (generate-info-item :causal-links
			*causal-links*
			*model-to-test*)
    (kanal-format stream "~%~%  ************************************************")
    (kanal-format stream "~%          Summary of Causal Links")
    (kanal-format stream "~%  ************************************************")
    (kanal-html-format "<h2>Summary of causal links</h2>~%")
    (mapcar #'(lambda (causal-link)
	      (kanal-format stream "~% ~S enabled ~S by achieving or asserting (for inexplicit preconditions)~%    ~S"
			(first causal-link)
			(second causal-link)
			(third causal-link))
	      (kanal-html-format "~%<br> ~S enabled ~S by achieving or asserting (for inexplicit preconditions)~%    ~S"
			(first causal-link)
			(second causal-link)
			(third causal-link)))
	    *causal-links* )
    (kanal-format stream "~%~%")))

;; 
;; To find the step that achieved the precondition, find previous situations
;;  where the preconditions BECOME satisfied (i.e., the preconditions were false before)
;;  (? is there a way of using achieved effects of the previous steps instead?)
;;
;; we assume only one prev situation because
;;  conjunctive prev events are linearized as described below
;;  disjunctive prev events are simulated in different situations as described below
(defun find-causal-link (preconditions situation event &optional (stream *kanal-log-stream*))
  (let ((prev-situations (previous-situation situation)))
    (if (or (null prev-situations) (eq '|t| preconditions))
	nil
      (let* ((prev-situation-info (first prev-situations))
	     (prev-event (third prev-situation-info))
	     (prev-situation (second prev-situation-info))
	     (failed-preconditions (first
				    (test-preconditions preconditions prev-situation))))
	(cond ((null failed-preconditions) ;; not failed
	       (find-causal-link preconditions prev-situation event))
	      (t ;; event made the expr succeed
	       (let ((new-causal-link (list prev-event event failed-preconditions)))
		 (if (not (member new-causal-link *causal-links* :test #'equal))
		     (setq *causal-links* (append *causal-links*
						  (list new-causal-link)))))
	       (kanal-format stream "~%~% ***** ~S enabled ~S by achieving or asserting (for inexplicit preconditions)~%    ~S~%"
		       prev-event event failed-preconditions)
	       (kanal-html-format "~%<br> ***** ~S enabled ~S by achieving or asserting (for inexplicit preconditions)~%    ~S<br>~%"
		       prev-event event failed-preconditions)
	       ;; check satisfied sub-exprs to find the steps enabled them
	       (let ((satisfied-sub-exprs (find-satisfied-subexpr preconditions)))
		 (dolist (expr satisfied-sub-exprs)
		   (find-causal-link expr prev-situation event))))))
      ))
  *causal-links*
  )


;; when the preconditions failed, find the subexpressions that are still satisfied
(defun find-satisfied-subexpr (expr)
  (let ((satisfied-exprs
	 (mapcar #'third  ;; get km expr
		  (remove-if-not #'(lambda (item)
				     (and (not (null (fourth item)))
					  (equal 'exit (second item))
					  ;; exclude failure from projection
					  (not (member '#$in-situation (flatten item)))))
				 *trace-log*)))
	(result nil))
    (dolist (s-expr satisfied-exprs)
      (when (member s-expr expr :test #'equal)
	(let ((expr-found nil))
	  (dolist (e result)
	    (if (or (equal s-expr e) ;; same expression
		    (member s-expr e :test #'equal)
		    (equivalent-expr s-expr e))
		(setq expr-found t)))
	  (if (null expr-found)
	      (setq result (append result (list s-expr)))))))
    result)
  )


;;; ======================================================================
;;;		Get sequences of actions to simulate
;;; ======================================================================

;; we assume that the simulation will execute primitive events
;; this function finds the first primitive events
#|
(defun find-first-primitive-events (event  &optional (stream *terminal-io*))
  (let ((first-subevents (get-first-subevents event ))
	(subevents (get-subevents event)))
    (cond ((and (null first-subevents) ;; primitive event itself
		(null subevents))
	   (list event)) 
	  ((null first-subevents);; this shouldn't happen
	   (let ((first-subevents-desc (get-role-description event 
							     (find-symbol-in-kb "first-subevent"))))
	     (cond ((null first-subevents-desc)
		    (kanal-format stream "~% WARNING (missing ordering constraints)~%")
		    (kanal-format stream "  the first-subevent of ~S isn't defined~%" event)
		    (kanal-format stream "  so the system choose the first defined subevent~%")
		    (generate-error-checker-item 'first-subevent
						 ':missing-link
						 ':error
						 nil
						 event)
		    (find-first-primitive-events (first subevents)))
		   (t nil)))
	   )
	  (t 
	   (mapcan #'find-first-primitive-events first-subevents)))
    ))
|#
;; todo : this needs to be cleaned up
(defun find-first-primitive-events (event  &optional (stream *kanal-log-stream*))
  (let ((first-subevents (get-first-subevents event))
        (subevents (get-subevents event)))
    (cond ((and (null first-subevents);; primitive event itself
	      (null subevents))
	 (list event)) 
	((null first-subevents);; this shouldn't happen
	 (let ((first-subevents-desc
	        (get-role-description
	         event (find-symbol-in-kb "first-subevent"))))
	   (cond ((null first-subevents-desc)
		(kanal-format stream "~% WARNING (missing first subevent)~%")
		(kanal-format stream "  the first event of ~S isn't defined~%" event)
		(kanal-format stream "  the system cannot execute these subevents: ~S~%" subevents)
		(kanal-html-format "<br><font color=~S>WARNING (missing first subevent)<br>~%"
			         *dark-orange*)
		(kanal-html-format "  the first event of ~S isn't defined<br>~%" event)
		(kanal-html-format "  the system cannot execute these subevents: ~S<br>~%" subevents)
		(generate-error-checker-item 'ordering
				         ;; was :missing-link, but
				         ;; this is more descriptive.
				         :missing-first-subevent
				         :error nil
				         (list event subevents))
		;;(add-ordering-info event) ;; use the ordering in the subevents list
		;;(find-first-primitive-events (first subevents))
		(list event))
	         (t nil)))
	 )
	(t 
	 (mapcan #'find-first-primitive-events first-subevents)))))

(defun find-last-primitive-events (event)
  (let* ((subevents (get-subevents event))
	 (last-subevents (find-last-subevents subevents)))
    (cond ((or (null subevents)   ;; primitive event itself 
	       (null (get-first-subevents event ))) ;; missing ordering info: todo
	   (list event)) 
	  ((null last-subevents) ;; this shouldn't happen
	   (find-last-primitive-events (first (last subevents))))
	  (t 
	   (mapcan #'find-last-primitive-events last-subevents)))
    ))

(defun find-last-subevents (subevents)
  (remove-if #'(lambda (event)
		 (or (get-next-events event)
		     (get-disjunctive-next-events event)))
	     subevents)
  )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; these functions are used when only primitive (leaf) events are executed
;;;
(defun find-next-primitive-events (event)
  (if (null event)
      nil
    (let ((next-events (get-next-events event)))
      (cond ((null next-events)
	   (mapcan #'find-next-primitive-events (get-parent-events event)))
	  (t
	   (mapcan #'find-first-primitive-events next-events))))))

(defun find-prev-primitive-events (event)
  (if (null event)
      nil
    (let ((parent-events (get-parent-events event))
	  (prev-events (get-prev-events event)))
      (cond ((null prev-events)
	     ;(if (null parent-events) ;; top event
		; (find-last-primitive-events event)
	       (mapcan #'find-prev-primitive-events parent-events))
	    (t
	     (mapcan #'find-last-primitive-events prev-events))))))

(defun find-next-disjunctive-primitive-events (event)
  (if (null event)
      nil
    (let ((next-events (get-next-events event))
	(disjunctive-next-events (get-disjunctive-next-events event)))
      (cond (disjunctive-next-events
	   (mapcan #'find-first-primitive-events disjunctive-next-events))
	  ((null next-events);; last node without disjunctive-next-events
	   (mapcan #'find-next-disjunctive-primitive-events
		 (get-parent-events event)))
	  (t nil)))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; These functions are used when all the events are executed
;;;   - execute children before parents
;;;
(defun find-next-events-including-parents (event)
  (let ((next-events (get-next-events event)))
    (cond ((and (null next-events)
		(null (find-next-disjunctive-events event))) ;; the last event
	   (get-parent-events event))
	  (t
	   (mapcan #'find-first-primitive-events next-events))))
  )


(defun find-prev-events-including-children (event)
  (let ((subevents (get-subevents event))
	(prev-events (get-prev-events event)))
    (cond (subevents
	   (find-last-subevents subevents)
	   )
	  (prev-events
	   prev-events)
	  (t	; no subevents, no prev events
	   (find-prev-events-of-ancestor event))
	  )))

(defun find-prev-events-of-ancestor (event)
  (let* ((parent-events (get-parent-events event))
	 (prev-events-of-parents 
	  (mapcan #'(lambda (e)
		     (get-prev-events e)) parent-events)))
    (cond ((null parent-events)
	   nil)
	  ((null prev-events-of-parents)
	   (mapcan #'find-prev-events-of-ancestor parent-events)
	   )
	  (t prev-events-of-parents)
	  )))

(defun find-next-disjunctive-events-1 (event)
  (let ((disjunctive-next-events
	 (get-disjunctive-next-events event)))
    (cond (disjunctive-next-events
	   (mapcan #'find-first-primitive-events disjunctive-next-events))
	  (t nil))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun find-next-events (event)
  (if (null event)
      nil
    (if (equal *execution-mode* 'primitive-steps-only)
      (find-next-primitive-events event)
    (find-next-events-including-parents event))))

(defun find-next-events-in-loop (event)
  (let ((parent-events (get-parent-events event)))
    (if (equal *execution-mode* 'primitive-steps-only)
	(mapcan #'find-next-primitive-events parent-events)
      parent-events)))
		     
(defun find-prev-events (event)
  (if (null event)
      nil
    (if (equal *execution-mode* 'primitive-steps-only)
      (find-prev-primitive-events event)
    (find-prev-events-including-children event))))

(defun find-next-disjunctive-events (event) ; todo
  (if (null event)
      nil
    (if (equal *execution-mode* 'primitive-steps-only)
	(find-next-disjunctive-primitive-events event)
      (find-next-disjunctive-events-1 event))
    )
  )

;;; ======================================================================
;;;		Bookkeeping
;;;    
;;;  o Find paths in the model using simulation
;;;  o Find overall effects for each path
;;; ======================================================================

;; this collects disjunctive paths simulated
(defvar *paths-simulated* nil) ;; list of list of (event situation) pair
(defvar *loops-found* nil)

(defstruct (event-info
	    (:print-function print-event-info))
  event
  prev-situation
  next-situation
  all-added-effects
  all-deleted-effects
  )

;;; I changed this to print to the same stream that it is called with
;;; (kanal-format ignores the stream argument and always prints to
;;; *kanal-log-stream*, which makes things really hard to follow,
;;; lists look empty when they're not, and so on) - Jim
(defun print-event-info (event-info-struc &optional (stream *kanal-log-stream*)
					  (debug-level *print-level*))
  (declare (ignore debug-level))
  (format stream "~%[ Event Info ~% path: ~S ~% prev-situation: ~S ~% next-situation ~S ~% added effects(accumulated):   ~S ~% deleted effects(accumulated): ~S~%]"
	  (get-event event-info-struc)
	  (get-prev-situation event-info-struc)
	  (get-next-situation event-info-struc)
	  (get-all-added-effects event-info-struc)
	  (get-all-deleted-effects event-info-struc))
  )

(defun get-event (event-info)  (event-info-event event-info))
(defun get-all-added-effects (event-info)
  (if (null event-info)
      nil
    (event-info-all-added-effects event-info)))

(defun get-all-deleted-effects (event-info)
  (if (null event-info)
      nil
    (event-info-all-deleted-effects event-info)))
(defun get-prev-situation (event-info) (event-info-prev-situation event-info))
(defun get-next-situation (event-info) (event-info-next-situation event-info))

(defun add-path-to-simulated-paths (path)
  (setq *paths-simulated* (append *paths-simulated* (list path))))

(defun find-paths-containing-situation (situation)
  (remove-if-not #'(lambda (path)
		     (if (member situation
				 (mapcar #'get-next-situation path))
			 t
		       nil)) 
		 *paths-simulated*))

(defun find-initial-sequence-ends-with (situation path)
  (let ((situations (mapcar #'get-next-situation path)))
    (subseq path 0 (+ (position situation situations) 1)) )
  )


(defun collect-simulated-event (event prev-situation next-situation
			        del-list add-list &optional (stream *kanal-log-stream*))
 
  (let ((paths-containing-prev-event
         (find-paths-containing-situation prev-situation))
        (new-event-info (make-event-info
		     :event event
		     :prev-situation prev-situation
		     :next-situation next-situation))
        (loops-found nil))
    (cond ((or (null *paths-simulated*) (null paths-containing-prev-event))
	 (add-path-to-simulated-paths (list (update-event-info-for-effects
				       new-event-info
				       del-list
				       add-list
				       nil))))
	(t
	 ;; add paths not containing the event first
	 (let ((result (set-difference *paths-simulated*
				 paths-containing-prev-event
				 :test #'equal))
	       (paths-before-prev-event nil);; This is used for checking duplication for disjunctions.
	       ;; When there are more than two disjunctive paths (e.g. three paths)
	       ;; from a situation, and when the third one is added, there are
	       ;; already two paths containing the same prev event
	       )
	   (dolist (path paths-containing-prev-event)
		 (let ((last-event-info (first (last path))))
		   (cond ((equal prev-situation
			       (get-next-situation last-event-info));; ends with the event
			(cond ((loop-found event path)
			       (setq loops-found t)
			       (goto prev-situation);; go back to the earlier situation
			       (setq result (append result (list path))))
			      (t 
			       (setq result
				   (append result
					 (list (append path
						     (list (update-event-info-for-effects
							  new-event-info
							  del-list add-list
							  last-event-info)))))))))
		         (t;; containing the event (because of disjunctive branches)
			(let ((initial-sequence
			       (find-initial-sequence-ends-with prev-situation path)))
			  (setq result (append result (list path)));; add the original path info
			  (when (not (member initial-sequence paths-before-prev-event :test #'equal))
			        (setq paths-before-prev-event (push initial-sequence paths-before-prev-event))
			        (setq last-event-info (first (last initial-sequence)))
			        (cond ((loop-found event initial-sequence)
				     (goto prev-situation);; go back to the earlier situation
				     (setq loops-found t))
				    (t 
				     (setq result
					 (append result
					         (list (append initial-sequence
							   (list (update-event-info-for-effects
								new-event-info del-list add-list
								last-event-info))))))))))))))
	   (setq *paths-simulated* result))))
				;(report-simulated-paths)
    (if loops-found
        nil
      *paths-simulated*)
    ))

(defun get-simulated-paths ()
    (mapcar #'(lambda (path)
		(mapcar #'get-event path))
     *paths-simulated*)
  )

(defun get-all-executable-events ()
  (if (equal *execution-mode* 'primitive-steps-only)
      (get-primitive-events *current-model-instance*)
    (get-all-subevents *current-model-instance*))
  )
  

(defun report-simulated-paths (&optional (stream *kanal-log-stream*))
  (cond ((null *paths-simulated*)
         (generate-error-checker-item *all-executable-events*
			        ':unreached-events
			        ':warning nil
			        'no-simulation-path-exist)
         nil)
        (t 
    
         (generate-info-item :simulated-paths
		         (mapcar #'(lambda (path)
				 (let ((event-list (mapcar #'get-event path)))
				   (check-unnecessary-ordering-constraints event-list)
				   event-list))
			       *paths-simulated*)
		         *model-to-test*)
         (kanal-format stream "~%~%  ************************************************")
         (kanal-format stream "~%          Summary of Paths Simulated")
         (kanal-format stream "~%  ************************************************")
         (kanal-format stream "~%~%  These are the simulated paths: ~%")
      
         (kanal-html-format "<hr><h2>Summary of alternative paths simulated</h2>~%<ul>~%")
      
         (mapcar #'(lambda (path)
		 (let* ((events (mapcar #'get-event path))
		        (unreached-events
		         (set-difference 
			*all-executable-events* events)))
		   (kanal-format stream "     ~S~%" events)
		   (kanal-html-format "<li>~S~%" events)
		   (when unreached-events
		         (generate-error-checker-item unreached-events
					        ':unreached-events
					        ':warning nil
					        (if (and *failed-event-info*
							 (equal (first *failed-event-info*) ':precondition))
						    (list 'failed-condition (second *failed-event-info*))
						  (list 'missing-ordering-constraint)))
		         (kanal-format stream "~% ~S ~% were not reached in this path~%~%"
				   unreached-events)
		         (kanal-html-format "<br>~S were not reached in this path~%"
				        unreached-events)
		         )
		   (kanal-html-format "</li>~%")
		   )
		 )
	       *paths-simulated*)
         (kanal-html-format "</ul>~%")
         )))

(defun check-unnecessary-ordering-constraints (event-list)
  (let ((result (check-unnecessary-ordering-constraints-1 event-list nil)))
    (if result
	(generate-error-checker-item 'ordering
				     ':unnecessary-link
				     ':warning nil
				     result)))
  )



(defun check-unnecessary-ordering-constraints-1 (event-list results-so-far)
  
  (let ((current (first event-list))
	(steps-after (rest event-list))
	(result results-so-far))
    (when event-list
      (dolist (step-after steps-after)
	(let ((next-event-in-order (find-next-event-in-order current step-after)))
	  (if (and next-event-in-order ;; there is an ordering between the two steps
		 (not (enabled? current step-after))
		 (not (a-subevent? current step-after))
		 ;; when there are subevents and
		 ;; there is no explicit ordering between them and the next events
		 (not (member (list current 'before next-event-in-order) result
			      :test #'equal))
		 )
	      (setq result (append result (list (list current 'before next-event-in-order)))))))
      (setq result (check-unnecessary-ordering-constraints-1 (rest event-list) result)))
   
    result)
  )
#| 
(defun check-unnecessary-ordering-constraints-1 (event-list results-so-far)
  
  (let ((current (first event-list))
	(step-after (first (rest event-list)))
	(result results-so-far))
    (when event-list 
      (if step-after 
	  (if (and (not (enabled? current step-after))
		   (not (a-subevent? current step-after)))
	    (setq result (append result
				 (list (list current 'before 
					     (find-next-event-in-order current step-after)))))))
      (setq result (check-unnecessary-ordering-constraints-1 (rest event-list) result))
      )
    result)
  )
|#
(defun find-next-event-in-order (step1 step2)
  (cond ((null step2)
	 nil) 
	((member step2 (get-next-events step1))
	 step2)
	(t
	 (let ((result nil))
	   (dolist (pstep (get-parent-events step2))
	     (let ((next-step (find-next-event-in-order step1 pstep)))
	       (if (and next-step
			;; there was not explicit ordering between the steps
			;; (e.g. conjunctive events)
			(not (equal next-step *current-model-instance*)))
		   (setq result next-step))))
	   result))))

(defun a-subevent? (subevent event)
  (member subevent (get-all-subevents event)))

(defun enabled? (step-before step-after)
  (let ((result nil))
    (dolist (causal-link *causal-links*)
      (if (and (equal (first causal-link) step-before)
	       (equal (second causal-link) step-after))
	  (setq result t)))
    result))

(defun cancelled-equivalent-effect-in-del-list (effect prev-deleted-effects &optional (stream *kanal-log-stream*))
  (let ((new-del-list nil)
	(found-equivalent-effect nil))
    (dolist (del-effect-info prev-deleted-effects)
      (let ((del-effect (first del-effect-info)))
	(cond ((or (equal effect del-effect)
		   (effect-equivalent effect del-effect))
	       (setq found-equivalent-effect t)
	       (kanal-format stream "~%      canceling effects: adding ~S ~%         which has been deleted by earlier (or current) action ~S"
			 effect (second del-effect-info))
	       (kanal-html-format "~%<br>      canceling effects: adding ~S ~%         which has been deleted by earlier (or current) action ~S"
			      effect (second del-effect-info)))
	      (t 
	       (setq new-del-list (append new-del-list (list del-effect-info))))))
      )
    (if found-equivalent-effect
	 new-del-list
      nil)))

(defun cancelled-equivalent-effect-in-add-list (effect prev-added-effects
						       &optional (stream *kanal-log-stream*))
  (let ((new-add-list nil)
	(found-equivalent-effect nil))
    (dolist (added-effect-info prev-added-effects)
      (let ((add-effect (first added-effect-info)))
	(cond ((or (equal effect add-effect)
		   (effect-equivalent effect add-effect))
	       (setq found-equivalent-effect t)
	       (kanal-format stream "~%      canceling effects: deleting ~S ~%         which has been added by earlier (or current) action ~S"
		       effect (second added-effect-info))
	       (kanal-html-format "~%<br>      canceling effects: deleting ~S ~%         which has been added by earlier (or current) action ~S"
		       effect (second added-effect-info)))
	      (t 
	       (setq new-add-list (append new-add-list (list added-effect-info))))))
      )
    (if found-equivalent-effect
	 new-add-list
      nil)))
#|
(defun update-event-info-for-effects (new-event-info del-list add-list prev-event-info)
  (cond ((null prev-event-info) ;; no prev event
	 (let ((all-added-effects nil)
	       (all-deleted-effects nil)
	       (event (get-event new-event-info)))
	   (dolist (added-effect add-list)
	     (setq all-added-effects
		   (append all-added-effects (list (list added-effect event)))))
		   (setf (event-info-all-deleted-effects new-event-info)
			 (list del-effect (get-event new-event-info))))
	   (dolist (del-effect del-list)
	     (setq all-deleted-effects
		   (append all-deleted-effects (list (list del-effect event)))))
	   (setf (event-info-all-deleted-effects new-event-info) all-deleted-effects)
	   (setf (event-info-all-added-effects new-event-info) all-added-effects)
	   new-event-info)
	(t (update-event-info-for-effects-with-prev-event-info
	    new-event-info del-list add-list prev-event-info))))
|#    
(defun update-event-info-for-effects (new-event-info del-list add-list prev-event-info)
  (let ((all-added-effects (get-all-added-effects prev-event-info))
	(all-deleted-effects (get-all-deleted-effects prev-event-info))
	(event (get-event new-event-info)))
    (dolist (del-effect del-list)
      (let ((added-effects-changed-after-cancelling
	     (cancelled-equivalent-effect-in-add-list
			   del-effect all-added-effects)))
	(if added-effects-changed-after-cancelling
	    (setq all-added-effects added-effects-changed-after-cancelling)
	  (if (not (member (list del-effect event) all-deleted-effects :test #'equal))
	      (setq all-deleted-effects
		    (append all-deleted-effects (list (list del-effect event))))))))
    (dolist (added-effect add-list)
      (let ((deleted-effects-changed-after-cancelling
	     (cancelled-equivalent-effect-in-del-list
			   added-effect all-deleted-effects)))
	(if deleted-effects-changed-after-cancelling
	    (setq all-deleted-effects deleted-effects-changed-after-cancelling)
	  (if (not (member (list added-effect event) all-added-effects :test #'equal))
	      (setq all-added-effects
		    (append all-added-effects (list (list added-effect event))))))))
    (setf (event-info-all-deleted-effects new-event-info) all-deleted-effects)
    (setf (event-info-all-added-effects new-event-info) all-added-effects)
    new-event-info))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Details of how to find sequences of actions to simulate
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#|
Eg1.
              S3' - S4' 
             /        \
     S1 - S2           S5 - S6    (from left to right)
             \        /
              S3" - S4"
 where S2 is followed by two conjunctive subprocesses

this can be simulated like this:
S1->S2->S3'->S4'->S3"->S4"->S5->S6

Eg2. with the graph looking like this, with disjunctive (//) actions A3' or A3":


               A3' - A4' 
             //        \
     A1 - A2           A5 - A6    (from left to right)
             \\        /
               A3" - A4"

You'd get an envisionment with one branch:

			  S3 -A4'-> S4 -A5-> S5 -A6-> S6
			 /
			A3'
		       /
   S0 -A1-> S1 -A2-> S2 
		       \
			A3"
			 \
			  S7 -A4"-> S8 -A5-> S9 -A6-> S10
|#


