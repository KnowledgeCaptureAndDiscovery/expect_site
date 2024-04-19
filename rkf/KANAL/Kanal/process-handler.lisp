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

(defvar *next-event-exprs* nil)

;; Modification to allow no-initial-state execution 
;; of all branches :varun
(defun get-next-events (event)
  (if *initial-state-specified*
     (get-role-values-with-checking "next-event" event nil)
     (get-unexecuted-conditional-next-events event)))

(defun get-unexecuted-conditional-next-events (event)
  (let* ((next-event-exprs (cadr (assoc event *next-event-exprs*)))
         (next-events nil))

      (cond ((null next-event-exprs) 
	     (setq next-event-exprs (get-role-descriptions event (find-symbol-in-kb "next-event")))
	     (setq *next-event-exprs* (append *next-event-exprs* (list (append (list event next-event-exprs)))))))

      ;; Call the function anyway to set the correct values of prev-event
      (get-role-values-with-checking "next-event" event nil)
      ;; Get all possible next-events
      (dolist (next-event-expr next-event-exprs)
        (cond ((not (listp next-event-expr))
	         ;; this is a event instance
	         (setq next-events (append next-events (list next-event-expr))))
	       ((and (not (listp (first next-event-expr)))
	            (not (string-equal (first next-event-expr) 'if)))
	         ;; this is not an expression
	         (setq next-events (append next-events (evaluate-expr next-event-expr))))
	       (t
	         ;; this is an expression
	         (setq next-events (append next-events (evaluate-expr (fourth next-event-expr))))
	         (setq next-events (append next-events (evaluate-expr (sixth next-event-expr)))))))
      ;; Remove those next-events that have been executed
      (remove-if #'has-been-done next-events)
  ))

(defun get-prev-events (event)
  (get-role-values-with-checking "prev-event" event nil))

(defun get-subevents (event)
  (get-role-values-with-checking "subevent" event nil)
  ) 

(defun get-first-subevents (event)
     (get-role-values-with-checking "first-subevent" event nil)
 )

(defun get-disjunctive-next-events (event)
  (get-role-values-with-checking "disjunctive-next-events" event nil))

(defun get-primitive-events (event)
  (get-role-values-with-checking "primitive-actions" event nil))

#|
(defun get-all-subevents (event)
  (get-role-values-with-checking "all-subevents" event nil))
 
|#
(defun get-all-events-involved (process-model)
  nil)

(defun execute-step (event)
  (km-k `(#$do-and-next ,event)))

;;; =================================================================
;;; modification of get-all-subevents for additional checking
;;;

;; checking if every first-subevent is also subevent
(defun get-all-subevents (event)
  (let ((look-up-result (assoc event *all-subconcepts-used*)))  ;; for efficiency
    (cond ((null look-up-result)
	   (let ((result  (get-all-subevents-1 event nil)))
	     (when (not (equal result 'fail))
	       (setq result (remove-duplicates result))
	       (setq *all-subconcepts-used*
		   (acons event result *all-subconcepts-used*)))
	     result))
	  (t ;(format t "~% lookup:event found ~S~%" event)
	     (cdr look-up-result)))
    )
  )



(defun get-all-subevents-1 (event ancestors)
  (cond ((null event)
	 nil)
	(t
	 (let* ((first-subevents (get-first-subevents-with-checking event))
		(subevents (get-subevents event))
		(first-subevents-that-are-not-subevents
		 (set-difference first-subevents subevents))
		(subevents-in-ancestors (intersection subevents ancestors))
		)
	   (cond 
	    (subevents-in-ancestors ;; subevents are also ancestors
	     (mapcar #'(lambda (e)
			 (generate-error-checker-item 'subevent
						      :subevent-loop
						      :error nil
						      (list e e)))
		     subevents-in-ancestors)
	     'fail)
	   
	    ((member event subevents) ; the event is a subevent of itself
	     (generate-error-checker-item 'subevent
					  :subevent-loop
					  :error nil
					  (list event event))
	     'fail)
		  
	    (first-subevents-that-are-not-subevents
	     (mapcar #'(lambda (e)
			 (generate-error-checker-item 'ordering
						      :missing-subevent
						      :error nil
						      (list event e)))
		     first-subevents-that-are-not-subevents)
	     ;; instead of returning 'fail, we assume assume that
	     ;; first-subevents-that-are-not-subevents are subevents and proceed 6/11/02 Jihie
	     (let ((new-ancestors (append ancestors (list event)))
		   (new-subevents (append subevents first-subevents-that-are-not-subevents))
		   (result (append subevents first-subevents-that-are-not-subevents)))
		 (dolist (e new-subevents)
		   (when (not (equal result 'fail))
		     (let ((sub-subs (get-all-subevents-1 e new-ancestors)))
		       (if (equal sub-subs 'fail)
			   (setq result 'fail)
			 (setq result (union result sub-subs))))))
		 result)
	     ;;'fail 
	     )
	    (t (let ((new-ancestors (append ancestors (list event)))
		     (result subevents))
		 (dolist (e subevents)
			(when (not (equal result 'fail))
			  (let ((sub-subs (get-all-subevents-1 e new-ancestors)))
			    (if (equal sub-subs 'fail)
				(setq result 'fail)
			      (setq result (union result sub-subs))))))
		      result))
		 ))))
		      
  )


;;; ======================================================================
;;; sub functions needed for KANAL to find step ordering

;;; 
;;; to do: why do we need this? - we may just use *paths-simulated*
;;;  find steps that are executed before the current step
(defun find-steps-before (step &optional (prev-event-finder #'find-prev-events))
  (rest (remove-duplicates (find-steps-before-1 (list step) nil prev-event-finder)))
  )

(defun find-steps-before-1 (current-steps steps-visited-so-far
					  &optional (prev-event-finder #'find-prev-events))
  (let* ((steps-visited steps-visited-so-far) ;; to avoid loop
	 (steps (set-difference current-steps steps-visited))
	 (new-prev-events nil))
    (cond ((null current-steps)
	   steps-visited)
	  (t
	   (if (not (equal steps current-steps))
	       (format t "~% steps : ~S ~S" steps current-steps)) ;; debugging
	   (dolist (step steps)
	     (let ((prev-events (apply prev-event-finder (list step))))
	       (setq steps-visited (append steps-visited (list step)))
	       (setq new-prev-events (append new-prev-events prev-events))))
	   (find-steps-before-1 (set-difference
				 (remove-duplicates new-prev-events) steps-visited)
				steps-visited prev-event-finder)
	   ))
    ))


;; this returns two steps that are ordered (by next-events links),
;; regardless of how the steps are visited during the simulation
(defun find-ordered-steps (pstep nstep)
  (let ((all-substeps-of-nstep (get-all-subevents nstep)))
    (if (member pstep all-substeps-of-nstep)
	;; there is no ordering because it is a substep	
	nil
      (find-ordered-steps-1 pstep nstep)))
  )

(defun find-ordered-steps-aux (pstep nsteps)
  (if (null nsteps)
      nil
    (let ((result (find-ordered-steps-1 pstep (first nsteps))))
      (if result
	  result
	(find-ordered-steps-aux pstep (rest nsteps)))
      )
    ))

(defun find-ordered-steps-1 (pstep nstep)
  (let ((prev-steps-of-nstep (find-steps-before nstep #'get-prev-events)))
    (if (member pstep prev-steps-of-nstep)
	(list pstep nstep) ;; they are in the same level
      (let ((result nil))
	(dolist (np-step prev-steps-of-nstep)
	  (when (member pstep (get-all-subevents np-step))
	    (setq result (list np-step nstep))
	    (format t  "~% found ordering-> result : ~S" result)
	    )
	  )
	(if result
	    result
	  ;; need to go a level up
	  (find-ordered-steps-aux pstep (get-parent-events nstep))
	  )
	)))
  )


;; todo -- use this format
;(defun general-compute (fixed-item items eval-function)
;  (if (null items)
;      nil
;    (let ((result (apply eval-function (list fixed-item (first item)))))
;      (if result
;	  result
;	(general-test fixed-item (rest items) eval-function))
;      )))


;;; ======================================================================
;;;		Handle Preconditions
;;; ======================================================================

    
(defun get-role-values-with-checking (role-name obj required)
  (let* ((role (find-symbol-in-kb role-name))
	 (vals (get-role-values obj role)))
    (cond ((null vals)
	   (let ((val-desc (get-role-description obj role)))
	     (when (and required (not (null val-desc)))
	       (kanal-format-verbose "~% ERROR (missing definition)~%")
	       (kanal-format-verbose "  ~S isn't defined~%" val-desc)
	       (kanal-html-format-verbose "<br> <font color=\"red\">ERROR (missing definition)<br>~%")
	       (kanal-html-format-verbose "  ~S isn't defined</font>~%"
				    val-desc)
	       (generate-error-checker-item ;; val-desc
		                            (list #$the role #$of obj)
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
(defun test-preconditions (preconditions situation soft? &optional (event nil))
  (let ((failed-preconditions nil)
        (invalid-preconditions nil)
        (inexplicit-preconditions nil))
    ;(format t "~S ~a ~%" preconditions situation)
    (when event
	(if soft?
	    (kanal-format "~&   soft preconditions: ~%")
	  (kanal-format "~&    preconditions: ~%"))
	(show-triples preconditions)
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
			   (not (inequality-role (get-role triple)))
			   (triple-consistent-with-kb triple situation))
		      (if soft?
			  (generate-error-checker-item (list triple) ':inexplicit-soft-precondition ':warning nil event)
			(generate-error-checker-item (list triple) ':inexplicit-precondition ':warning nil event))
		      
		      ;(assert-triple triple situation)
		      (kanal-format 
				"~% WARNING: ~% ~S ~%  ~S ~%     is not explicitly true but consistent with the KB" 
				triple
				(make-sentence-for-triple triple))
		      ;(kanal-format 
		      ;	"~%    => we will assume it is true and continue ..~%~%")
		      (kanal-format 
				"~%    => we will ignore it and continue ..~%~%")
		      (kanal-html-format "<font color=~S>WARNING: <br>~S<br>~S<br>is not explicitly true, but consistent with the KB~%"
				     *dark-orange*
				     triple (make-sentence-for-triple triple))
		      (kanal-html-format 
		       "<br>    so we will ignore it and continue<br></font>~%")
		      (push triple inexplicit-preconditions)
		      )
		     (t 
		      (if soft?
			  ;changed :error to :warning, ( amit agarwal)
			  (generate-error-checker-item	(list triple) ':soft-precondition ':warning nil (list event situation))) 
		      (push triple failed-preconditions))))
	   (collect-failed-exprs-off))))
					;(format t "~&   precondition:~S ~%  --> ~S~%"   preconditions result)
    (list failed-preconditions invalid-preconditions inexplicit-preconditions)
    )
  )

(defun k-set-difference (list1 list2)
  (remove-if #'(lambda(l) (member l list2)) list1))

(defun k-union (list1 list2)
  (let ((ulist nil))
        (dolist (l (append list1 list2))
	   (if (not (member l ulist))
	       (setq ulist (append ulist (list l))))
	)
	ulist
  ))

;;; ======================================================================
;;;  Simulate with SADL-S
;;; ======================================================================

(defun simulate-steps-with-sadl (steps-to-execute situation)
  (format t "steps : ~S~%" steps-to-execute)

  (if (null steps-to-execute)
      'done
  (let* ((doable-steps (find-doable-steps steps-to-execute))
	 (undoable-steps (k-set-difference steps-to-execute
					 doable-steps))
	 (simulation-result nil)
	 (curr-situation nil)
	 )

    (cond ((null doable-steps)
	   ;; there might be loop also
	   (cond (undoable-steps
	          (format t "~%cannot progress~%   [steps ~a were undoable this iteration...]~%" 
			 undoable-steps)
	          (mapcar #'check-loops-from-step undoable-steps)
	          (kanal-format nil "~%cannot progress~%   [steps ~a were undoable this iteration...]~%" 
			        undoable-steps)
	          (kanal-html-format "<br><font color=\"red\">cannot progress~%   [steps ~a were undoable this iteration...]</font>" 
			      undoable-steps)
	          (generate-error-checker-item nil :undoable-event :error nil undoable-steps)
	          (format t "generated an error-item~%")
	    ))
	   nil)
	  (t
	    (let ((step-selected-to-check nil)
                 (step-selected-to-execute nil)
	         (start-time '(> 9999999))
	         (end-time '(> 9999999)))


             ;*********************************
	     ; Get the step to be checked
	     ;*********************************

             ; Out of all the doable steps, find the one with the earliest 
	     ; start time (and one which hasn't already been checked),
	     ; -- This will have it's preconditions checked
	     (dolist (step doable-steps)
	        (let ((step-start-time (get-start-time-from-km step)))
		     (cond ((and
		            (not (member step *events-already-checked*))
		            (< (second step-start-time) (second start-time)))
		                (setq step-selected-to-check step)
		                (setq start-time step-start-time)))))

             ;*********************************
	     ; Get the step to be executed
	     ;*********************************

             ; we find the step with the earliest end time 
	     ; (and which has been checked) from the list of doable steps
	     ; -- that one will be executed (i.e. effects applied)
             (dolist (step doable-steps)
	        (let ((step-end-time (get-end-time-from-km step)))
		     (cond ((and
		            (member step *events-already-checked*)
		            (< (second step-end-time) (second end-time)))
		            (setq step-selected-to-execute step)
		            (setq end-time step-end-time)))))

             ; execute and apply the effects (maybe different from the step that was checked for preconditions)
	     ; -- If this step ends before the next step starts execute this

             (cond ((and step-selected-to-execute
	                 (<= (second end-time) (second start-time)))

	              ;; If a step can be executed right now
		      (format t "~S :: ~S ends now; executing~%" end-time step-selected-to-execute)
	              (setq simulation-result 
		          (execute-step-and-check-effects step-selected-to-execute situation nil 
			         (get-start-time-from-km step-selected-to-execute)))
                      (cond
	                  ((equal simulation-result 'fail) nil)
	                  ((equal simulation-result 'max-loops-found)
	                    (let ((events-simulated (mapcar #'get-event *max-loops-path*)))
	                       (generate-error-checker-item events-simulated 
		                   ':max-loops ':warning nil *model-to-test*))
	                    nil);; do something
	                  (t ;; step executed fine
	                   (setq curr-situation simulation-result)
	                   (simulate-steps-with-sadl
		            (k-union 
		                (k-set-difference doable-steps (list step-selected-to-execute)) ; rest of the doable-steps
		                undoable-steps)
		            curr-situation)))
		   )
                   ((and step-selected-to-check
	                 (< (second start-time) (second end-time)))

                     ; If the preconditions need to be checked now

	             (format t "~S :: ~S starts now ; checking preconditions~%" start-time step-selected-to-check)
	             (check-all-preconditions step-selected-to-check situation nil start-time)
	             (setq *events-already-checked* (append (list step-selected-to-check) *events-already-checked*))
	             (simulate-steps-with-sadl 
		         (k-union (append 
		             (filter-out-top-event (find-next-events step-selected-to-check)) ; next-events
		             doable-steps)
		             undoable-steps)
			 situation)
		   )
	     )))
   ))))


(defun get-end-time-from-km (event)
    (cond ((get-event-end-time event)
           (list 'EQ (get-event-end-time event)))
          (t
             (let ((duration (second (assoc event *event-duration-assoc*))))
                (if (not duration)
                    (setq duration 0))
                (list 'EQ (+ duration (second (get-start-time-from-km event))))
             )
	  ))
    )

;; Get the start times
;; IF START-TIME information not present
;; -- Inherit from the parent event
;; -- If absent there too, derive from prev-event
(defun get-start-time-from-km (event)
    (let ((start-time (second (car 
                     (km `(#$the #$value #$of 
                           (#$the #$start-time #$of 
                            (#$the #$time #$of ,event))))))))
         (cond ((not start-time)
	        (let ((superevent (car (km `(#$the #$subevent-of #$of ,event)))))
		      (if superevent
		          (setq start-time (second (get-start-time-from-km superevent)))))))
	(if start-time
            (list 'EQ start-time)
            (get-max-start-time event))
    ))

;; Start time format : (> 1 *hour) or (= 1 *hour)
(defun get-start-time-hours (event)
    ;(second (assoc event (reverse *start-times-list*)))
    (let ((start-time nil))
       (mapcar #'(lambda (path)
                   (dolist (p path)
		      (if (equal (get-event p) event)
		          (if (get-start-time p)
		              (setq start-time (get-start-time p))))))
       *paths-simulated*)
       start-time
    ))


;; TODO 
;; - handle signs (>, =)
;; - handle other temporal events as well
(defun get-max-start-time (event)
   (let ((start-time 0)
         (start-time-sign 'GT)
         (prev-events (find-prev-events event)))
         (mapcar #'(lambda (ev)
	           (let ((new-start-time (get-start-time-hours ev))
	                 (new-duration (second (assoc ev *event-duration-assoc*))))
		          (if (and (numberp (second new-start-time)) (numberp new-duration))
	                      (cond ((> (+ (second new-start-time) new-duration) start-time)
		                 (setq start-time (+ (second new-start-time) new-duration))
		                 (setq start-time-sign (first new-start-time))
			       ))
			      ;duration not specified .. - default to 0
			      (if (numberp (second new-start-time))
			        (setq start-time (+ (second new-start-time))))
			  )))
	        (union prev-events (cdr (assoc event *prev-list*))))
	 (list start-time-sign start-time)
   ))


(defun has-been-checked (event)
   (member event *events-already-checked*))

;; remove all feedback events in the check (i.e. both next and prev)
;; - Done to allow loops :varun
;; -- TODO :: only check for those steps without any temporal info.
(defun find-doable-steps (steps)
  ;(format t "steps : ~S~%" steps)
  (let ((filtered-steps nil))
     ;; Remove feedback events (found from the next-event/prev-event slots)
     ;(setq filtered-steps (remove-if-not
     ; #'(lambda (step)
     ;     (every #'has-been-checked (remove-feedback-events (find-prev-events step) step))) steps))

     ;; Remove feedback events (found from temporal relations)
     ;(setq filtered-steps (remove-if-not
     ; #'(lambda (st)
     ;     (every #'has-been-checked (remove-feedback-temporal-events 
;	                         (cdr (assoc st *prev-list*)) st))) filtered-steps))
    ;(format t "doable steps : ~S~%" filtered-steps)
     ;filtered-steps
     steps
  ))

(defun remove-feedback-events (prev-events event)
  (let ((all-forward-events (cdr (get-all-next-events event nil))))
       (remove-if #'(lambda (ev) (member ev all-forward-events)) prev-events)))

(defun remove-feedback-temporal-events (prev-events event)
  (let ((all-forward-events (cdr (assoc event *all-next-list*))))
       (remove-if #'(lambda (ev) (member ev all-forward-events)) prev-events)))

;; Get all next-events (recursively) 
;; - Done to remove feedback events from the list of prev-events
;;   that are checked for execution (in find-doable-steps) :varun
(defun get-all-next-events (event evlist)
  (let ((next-events (get-next-events event)))
      (cond ((and (member event evlist) (member event next-events))
             (setq evlist (append evlist next-events)))
            ((member event evlist) nil)
            (t 
              ;; If not a loop so far, append the event to the evlist
	      (setq evlist (append evlist (list event)))
              (cond ((null next-events) nil)
                (t 
		   ;; If the next-events are not null, find them out and append them too
                   (mapcar #'(lambda (ev) (setq evlist (get-all-next-events ev evlist))) next-events)))))
      evlist
  ))
       
;; Function used to remove redundant loops from the 
;; final *loops-found* list :varun
(defun check-overlapping-loops (path loops-found)
  (let ((no-overlap t))
     (mapcar #'(lambda (p)
            (if (subsetp p path :test 'equal) (setq no-overlap nil)))
     loops-found)
    no-overlap
  ))

(defun check-loops-from-step (step)
  (check-following-steps-for-loop (list step)))

(defun check-following-steps-for-loop (path)
  (let ((next-events (find-next-events (car (last path)))))
    (dolist (e next-events)
      (cond ((member e path) ;; already visited
             (cond ((check-overlapping-loops path *loops-found*) ;; Don't add overlapping loops
	         (kanal-format "~% loop found to ~S~%" e)
	         (format t "~% loop found to ~S~%" e)
	         (setq *loops-found*
		   (append *loops-found* (list (append path (list e)))))
	         (generate-error-checker-item (list (append path (list e)))
					  ':loop
					  ':warning
					  nil *model-to-test*))
	     ))
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
	 ;(format t "~&End of simulation!~%")
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
(defun simulate-events-1 (event-situation-list)
  (let* ((doable-events (find-doable-events event-situation-list))
         (undoable-events (set-difference event-situation-list doable-events
					  :test #'equal))
         (doable-event (first doable-events))
         (curr-situation nil)
         (simulation-result nil)
         (next-events nil))
    (kanal-format "~% simulate-events-1 ~S~%"
		  event-situation-list)

    ;; simulate the doable event
    (cond ((null doable-event)
	 (kanal-format "~%~% THERE IS NO EXECUTABLE EVENT!~%")
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
	   "~%   [Events ~a were undoable this iteration...]~%" 
	   (mapcar #'first undoable-events))
	  (kanal-html-format "~%<br> Events ~A were undoable this iteration.<br>~%"
			     (mapcar #'first undoable-events)))
      (let* ((next-events-to-simulate 
	      (remove-duplicates
	       (append next-events (rest doable-events) undoable-events)
	       :test #'equal :from-end t)))
        (cond ((equal event-situation-list next-events-to-simulate)
	       (kanal-format "Cannot progress -- end the simulation~%")
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
(defun check-delete-list (del-list situation event)
  (dolist (del-item del-list)
    (when (and (fourth del-item) ;; checking non-nil value
	       (null (test-expr del-item situation)))
      (kanal-format "~% WARNING :cannot-delete~%")
      (kanal-format "~%  ~S cannot be deleted because it's not true in the current situation" del-item)
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
(defun check-step-effects (add-list del-list event prev-situation next-situation)
  (let* ((effects (filter-out-null-effects add-list del-list))
	 (added-effects (first effects))
	 (deleted-effects (second effects)))
    ;(format t "~S~%" event)
    ;(format t "~S~%" added-effects)
    ;(format t "~S~%" deleted-effects)
    ;(format t "~S~%" (current-situation))
    (cond ((and (null added-effects)
		(null deleted-effects)
		(null (get-subevents event))
		(action-type-has-effects-defined event)
		)
	   (kanal-format "~%~% WARNING : no effect was produced by ~S~%"  event)
	   (kanal-html-format "~%<br><font color=~S> WARNING : no effect was produced by ~S</font><br>~%"
			      *dark-orange* event)
	   (generate-error-checker-item nil
					':no-effect
					':warning
					nil
					(list event prev-situation next-situation)))
	  (t
	   (generate-error-checker-item (list (remove-if #'triple-too-general
							 added-effects)
					      (remove-if #'triple-too-general
							 deleted-effects))
					':no-effect
					':warning
					t
					(list event prev-situation next-situation)))
	  )
  
    ))

;; this is a hack to avoid 'no-effect' warnings for the actions
;; that don't have any effects defined.
(defun action-type-has-effects-defined (event)
  (and (not (isa-class event '#$Recognize))
       (not (isa-class event '#$Perceive)))
  )

(defun filter-out-null-effects (add-list del-list)
  (list 
   (remove-if #'(lambda (effect)
		  (null (get-val effect))) add-list)
	      
   (remove-if #'(lambda (effect)
		  (null (get-val effect))) del-list)
   ))
	    

#| 
(defun filter-out-null-effects (add-list del-list)
  (list 
   (remove-if #'(lambda (effect)
		  (and (null (get-val effect))
		       (null (related-effect-exist (get-object effect) (get-role effect) del-list))))
	      add-list)
   (remove-if #'(lambda (effect)
		  (and (null (get-val effect))
		       (null (related-effect-exist (get-object effect) (get-role effect) add-list))))
	      del-list)))
(defun filter-out-null-effects (effect-list)
  (remove-if #'(lambda (effect)
		 (null (get-val effect))) effect-list))
|#
(defun related-effect-exist (obj role effect-list)
  (let ((result nil))
    (dolist (effect effect-list)
      (if (and (equal-objects (get-object effect) obj)
	       (equal-objects (get-role effect) role))
	  (setq result t)))
    result))


(defun execute-step-and-check-effects (event situation disjunctive? &optional start-time)
     (if situation (goto situation))
     (let* ((del-list (get-triple-values (get-deletions event)))
	   (add-list (get-triple-values (get-assertions event)))
	   (curr-situation (current-situation))
	   (prev-situation (cadr (assoc event *event-start-situation*))))

           ;(if (null prev-situation) 
	       (setq prev-situation curr-situation)
	   ;)

	   (kanal-format "~% ... EXECUTE ~a in ~a..." event curr-situation)
	   (kanal-html-format "~%<br> EXECUTE ~a in ~a~%" event curr-situation)
	   
	   ;(format t "Executing event ~S~%" event)
           ;(format t "-- before executing.. object : ~S~%" (km `(#$the #$object #$of ,event)))
	   (execute-step event)
           ;(format t "-- after executing.. object : ~S~%" (km `(#$the #$object #$of ,event)))
	   ;(format t "Executed event ~S~%" event)
	   (check-delete-list del-list curr-situation event)
	   ;(format t "Checking step effects~%")

	   (kanal-html-format "<br><br><font color=\"blue\"><b>Checking Effects:</b></font><br>~%")
	   (kanal-format "~%      deleting ~S" del-list)
	   (kanal-html-format "~%<br>      <font color=\"blue\">deleting</font>~%")
	   (if del-list
	       (kanal-html-format "<pre>~{~S~%~}</pre>" del-list)
	     (kanal-html-format ".. nothing to delete"))
	   (kanal-format "~%      adding ~S" add-list)
	   (kanal-html-format "~%<br>      <font color=\"blue\">adding</font>~%")
	   (if add-list
	       (kanal-html-format "<pre>~{~S~%~}</pre>" add-list)
	     (kanal-html-format ".. nothing to add"))

	   (setq curr-situation (current-situation))

	   (check-step-effects add-list del-list event prev-situation curr-situation)

	   ;added by amit agarwal (8/1/2002)
	   (generate-info-item :time-varying-properties-info
			   (mapcar #'(lambda (agobj) 
			     (list agobj (list-properties-agobj event agobj 
			                  curr-situation prev-situation add-list del-list)))
			   (get-agents-and-objects event))
			    event)
	   ;(format t "Checking expected effects of event~%")
	   (check-expected-effects-of-event event curr-situation)
	   ;(format t "Checked expected effects of event~%")
	   (kanal-format " becoming ~a~%" curr-situation)
	    
	   (cond ((null 
		 (collect-simulated-event event situation curr-situation
				      del-list add-list start-time))
		   (kanal-html-format "</li>~%")
		   'max-loops-found)
	         (t
		;;  kanal checks delete list only for the first
		;;  occurrence of the same event
		;(check-delete-list del-list prev-situation event)
		(kanal-html-format "</li>~%")
		(current-situation)))
     )
)

(defvar *event-start-situation* nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; this function really executes the given step
;;;
(defun check-all-preconditions (event situation disjunctive? &optional start-time)
  (when disjunctive?
        (kanal-format "~%~% ++++++++++++++++++++++++++++++++++++++")
        (kanal-format "~%  Start simulating a disjunctive path~%")
        (kanal-format " ++++++++++++++++++++++++++++++++++++++~%")
        (kanal-html-format "<strong>Start simulating a disjunctive path</strong>~%")
        )
  (kanal-format "~%~%  -----------------------------------------------------------")
  (kanal-format "~%  step: ~S ~S" event (get-role-values event #$'called))
  (kanal-format "~%  -----------------------------------------------------------~%")
  
  (kanal-html-format "<br><br><li><strong>Step: ~A</strong><br>" event)
  (if situation (goto situation))

  ;; BEFORE checking the preconditions.. modify the available-force-ratio 
  (cond ((is-a-type event '#$Engagement-Military-Task)
      (let ((max-combat-power (get-max-combat-power event))
            (enemy-combat-power (get-full-enemy-combat-power event))
	    (frdescription nil) (enemy nil))

         ;; Make sure that the available force ratio is overwritten BEFORE
	 ;; any queries to the available force ratio -- or else the axiom will fire
	 ;; and we'll end up with multiple available force ratio values
	 (setq enemy (car (km `(#$the #$enemy #$of ,event))))
	 ;(format t "~%---------Event : ~S------------~%" event)
	 ;(format t "Situation : ~S~%" situation)
	 ;(format t "Enemy : ~S~%" enemy)
	 ;(format t "Remaining Strength : ~S~%" (km `(#$the #$value #$of (#$the #$remaining-strength #$of ,enemy))))

         (cond ((and (and max-combat-power enemy-combat-power) (> enemy-combat-power 0))
            (setq force-ratio (/ max-combat-power enemy-combat-power))
            (km `(,event #$has (#$available-force-ratio 
                        ((#$a #$Available-Force-Ratio-Value #$with 
			    (#$value ((#$:pair ,force-ratio ()))
			    )
			)))))
	 ))

          (setq frdescription (get-force-ratio-description event))
	  (generate-info-item :force-ratio-explanation
                        (car frdescription) event)
	  (generate-info-item :unit-timeline
                        (get-unit-timeline event) event)
	  (generate-info-item :combat-power-timeline
                        (list (get-combat-power-timeline event) (second frdescription)) event)
      )
   ))

  (setq *event-start-situation* (append *event-start-situation* (list (list event (current-situation)))))

  (let* ((preconditions (get-preconditions event))
	 (soft-preconditions (get-soft-preconditions event))
         (curr-situation (current-situation))
         (test-results (test-preconditions preconditions curr-situation nil event))
	 (test-soft-pcs-results (test-preconditions soft-preconditions curr-situation t event))
         (failed-preconditions (first test-results))
         (invalid-preconditions (second test-results))
         (inexplicit-preconditions (third test-results))
	 (succeeded-preconditions
	  (set-difference preconditions
			  (append invalid-preconditions
				 inexplicit-preconditions
				 failed-preconditions) :test #'equal))

	 (failed-soft-preconditions (first test-soft-pcs-results))
         (invalid-soft-preconditions (second test-soft-pcs-results))
         (inexplicit-soft-preconditions (third test-soft-pcs-results))
	 (succeeded-soft-preconditions
	  (set-difference soft-preconditions
			  (append invalid-soft-preconditions
				 inexplicit-soft-preconditions
				 failed-soft-preconditions) :test #'equal))

         (succeeded-preconditions-all
	  (union succeeded-preconditions succeeded-soft-preconditions))
	   )

    ;(format t "-- before concept-definition.. ~S ~%" event)
    (generate-info-item :concept-definition-info-before-execution
			(get-concept-definition-info event) event)

    ;(if (engagement-military-task-p event)
;	(generate-info-item :force-ratio-explanation
;                        (get-force-ratio-description event) event))

    (cond (failed-preconditions
	 (kanal-format "   failed preconditions: ~S~%"  failed-preconditions)
	 (kanal-html-format "<br><font color=\"red\">Failed preconditions:~%")
	 (kanal-html-format "<pre>~S</pre></font><br>~%"
			failed-preconditions)
	 ;;(kanal-format "~% the step was not performed because of unachieved preconditions~%")
	 ;;(propose-fixes-for-failed-preconditions)
	 (dolist (pc failed-preconditions)
	         (generate-error-checker-item
		(list pc) ':precondition ':error nil (list event curr-situation)))
	 (setq *failed-event-info*
	       (list ':precondition event failed-preconditions))
	 (kanal-html-format "</li>~%")
	 (generate-info-item :event-info-before-execution
			    (get-roles-and-vals event curr-situation)
			    (list event curr-situation))
	 'fail
	 )
	(invalid-preconditions
	 (kanal-html-format "</li>~%")
	 'fail)
	(t
	 (when succeeded-preconditions-all
	       (kanal-format "~&   succeeded preconditions:~S ~%" succeeded-preconditions-all)
	       (kanal-html-format "<font color=\"blue\">Succeeded preconditions:</font>~%")
	       (kanal-html-format "<pre>~{~S~%~}</pre> ~%"
			      succeeded-preconditions-all)
	       (generate-error-checker-item succeeded-preconditions-all ':precondition ':error 't (list event curr-situation))
	       (find-causal-link succeeded-preconditions-all curr-situation event)
	       )

	 )
	)
    ;; close the list item for this event.
    ;;
    ))

		  
;; filter out the top event for the model itself
(defun filter-out-top-event (events) 
  (remove-if #'(lambda (event)
	       (member *model-to-test* (get-concepts-from-instance event)))
	   events))


#|  this was used to simulate a linear sequence of events
    we don't use this anymore
(defun simulate-linear-actions (events start-situation)
  (let ((curr-situation start-situation))
    (if (null events)
	(kanal-format "~% there is no substep " )
      (progn (kanal-format "~% These are the sub-steps: ~%")
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

(defun report-causal-links ()
  (when *causal-links*
    (generate-info-item :causal-links
			*causal-links*
			*model-to-test*)
    (kanal-format "~%~%  ************************************************")
    (kanal-format "~%          Summary of Causal Links")
    (kanal-format "~%  ************************************************")
    (kanal-html-format "<h2>Summary of causal links</h2>~%")
    (mapcar #'(lambda (causal-link)
	      (kanal-format "~% ~S enabled ~S by achieving or asserting (for inexplicit preconditions)~%    ~S"
			(first causal-link)
			(second causal-link)
			(third causal-link))
	      (kanal-html-format "~%<br> ~S enabled ~S by achieving or asserting (for inexplicit preconditions)~%    ~S"
			(first causal-link)
			(second causal-link)
			(third causal-link)))
	    *causal-links* )
    (kanal-format "~%~%")))

;; 
;; To find the step that achieved the precondition, find previous situations
;;  where the preconditions BECOME satisfied (i.e., the preconditions were false before)
;;  (? is there a way of using achieved effects of the previous steps instead?)
;;
;; we assume only one prev situation because
;;  conjunctive prev events are linearized as described below
;;  disjunctive prev events are simulatend in different situations as described below
#|
(defun find-causal-link (preconditions situation event)
  (let ((prev-situations (previous-situation situation)))
    (if (or (null prev-situations) (eq '|t| preconditions))
	nil
      (let* ((prev-situation-info (first prev-situations))
	     (prev-event (third prev-situation-info))
	     (prev-situation (second prev-situation-info))
	     (failed-preconditions (first
				    (test-preconditions preconditions prev-situation nil))))
	(cond ((null failed-preconditions) ;; not failed
	       (find-causal-link preconditions prev-situation event))
	      (t ;; event made the expr succeed
	       (let ((new-causal-link (list prev-event event failed-preconditions)))
		 (if (not (member new-causal-link *causal-links* :test #'equal))
		     (setq *causal-links* (append *causal-links*
						  (list new-causal-link)))))
	       (kanal-format "~%~% ***** ~S enabled ~S by achieving or asserting (for inexplicit preconditions)~%    ~S~%"
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
|#

;effects-achieve-condition (effects condition)
(defun find-causal-link (preconditions situation event)
  (let ((prev-situations (previous-situation situation)))
    (if (or (null prev-situations) (eq '|t| preconditions))
	nil
      (let* ((prev-situation-info (first prev-situations))
	     (prev-event (third prev-situation-info))
	     (prev-situation (second prev-situation-info))
	     (add-list (get-assertions prev-event))
	     (del-list (get-deletions prev-event))
	     (satisfied-conditions nil))
	(dolist (cond preconditions)
	  (cond ((mustnt-be-type (get-val cond))
		 (if (effects-achieve-condition del-list cond)
		     (setq satisfied-conditions (append satisfied-conditions (list cond)))))
		(t
		 (if (effects-achieve-condition add-list cond)
		     (setq satisfied-conditions (append satisfied-conditions (list cond)))))))
	(cond (satisfied-conditions
	       (let ((new-causal-link (list prev-event event satisfied-conditions)))
		 (if (not (member new-causal-link *causal-links* :test #'equal))
		     (setq *causal-links* (append *causal-links*
						  (list new-causal-link)))))
	       (kanal-format "~%~% ***** ~S enabled ~S by achieving or asserting ~%    ~S~%"
			     prev-event event satisfied-conditions)
	       (kanal-html-format "~%<br> ***** ~S enabled ~S by achieving or asserting ~%    ~S<br>~%"
				  prev-event event satisfied-conditions)
	       (find-causal-link (set-difference preconditions satisfied-conditions)
				 prev-situation event) )
	      (t (find-causal-link preconditions prev-situation event))))))
 
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

(defun get-first-subevents-with-checking (event)
  (let ((result (get-first-subevents event)))
    (check-if-not-parallel result)
    result))

(defun check-if-not-parallel (events)
  (dolist (e1 events)
    (dolist (e2 events)
      (when (member e2 (get-next-events e1))
	(kanal-format "~%there is an ordering between parellel events (~S before ~S) ~%" e1 e2)
	  (generate-error-checker-item 'ordering
				       :not-parallel
				       :error nil
				       (list e1 e2))))))


;;; ======================================================================
;;;		Get sequences of actions to simulate
;;; ======================================================================

;; we assume that the simulation will execute primitive events
;; this function finds the first primitive events
(defun find-first-primitive-events-wrapper (event)
  (find-first-primitive-events event t))

;; todo : this needs to be cleaned up
(defun find-first-primitive-events (event &optional (flag nil))
  (let ((first-subevents (get-first-subevents-with-checking event))
        (subevents (get-subevents event)))
  (if (and flag (equal event *current-model-instance*))
      nil
    (cond ((and (null first-subevents);; primitive event itself
		(null subevents))
	   (if (and (not flag) (equal event *current-model-instance*)) ;modified by amit agarwal
	       nil
	     (list event)))
	  ((null first-subevents);; this shouldn't happen
	   
	    
	   (kanal-format "~% WARNING (missing first subevent)~%")
	   (kanal-format "  the first event of ~S isn't defined~%" event)
	   (kanal-format "  the system cannot execute these subevents: ~S~%" subevents)
	   (kanal-html-format "<br><font color=~S>WARNING (missing first subevent)<br>~%"
			      *dark-orange*)
	   (kanal-html-format "  the first event of ~S isn't defined<br>~%" event)
	   (kanal-html-format "  the system cannot execute these subevents: ~S</font>~%" subevents)
	   (generate-error-checker-item 'ordering
					;; was :missing-link, but
					;; this is more descriptive.
					:missing-first-subevent
					:error nil
					(list event subevents))
	   ;;(add-ordering-info event) ;; use the ordering in the subevents list
	   ;;(find-first-primitive-events (first subevents))
	   (list event))
	(t
	 (mapcan #'find-first-primitive-events-wrapper first-subevents)
	 )))
    ))

(defun find-last-primitive-events (event)
  (let* ((subevents (get-subevents event))
	 (last-subevents (find-last-subevents subevents)))
    (cond ((or (null subevents)   ;; primitive event itself 
	       (null (get-first-subevents-with-checking event ))) ;; missing ordering info: todo
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
  (remove-duplicates (find-next-events-1 event) :test #'equal-objects))

(defun find-next-events-1 (event)
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
(defvar *paths-simulated* nil) ;; list of list of event-info
(defvar *causal-links-for-paths* nil)
(defvar *loops-found* nil)

;; Keep a Limit on the number of maximum loops allowed: varun
(defvar *maxloops* 20)
(defvar *max-loops-path* nil) ;; list of (event situation) pair in the max-loop-path
(defvar *temporal-loops-found* nil)

(defstruct (event-info
	    (:print-function print-event-info))
  event
  prev-situation
  next-situation
  all-added-effects
  all-deleted-effects
  start-time
  )

(defun print-event-info (event-info-struc &optional (stream 
*kanal-log-stream*) (debug-level *print-level*))
   (declare (ignore debug-level))
   (let ((*kanal-log-stream* stream))
     (kanal-format "~%[ Event Info ~%  path: ~S ~%  prev-situation: ~S 
  next-situation ~S ~%  added effects(accumulated):   ~S ~%  deleted effects(accumulated): ~S 
  start-time ~S ~%]"
		  (get-event event-info-struc)
		  (get-prev-situation event-info-struc)
		  (get-next-situation event-info-struc)
		  (get-all-added-effects event-info-struc)
		  (get-all-deleted-effects event-info-struc)
		  (get-start-time event-info-struc))))


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
(defun get-start-time (event-info)  
     (event-info-start-time event-info))

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

;; -- Additions to find out if the event loop is 
;;    still continuing after a limit (*maxloops*) :varun

;; get number of occurences of an event in a list
(defun get-num-event-occurences (event evlist)
   (let ((num-event 0))
        (mapcar #'(lambda (ev)
                (if (equal event ev) (setq num-event (+ num-event 1))))
	        evlist)
        num-event
   ))

;; Checks if the number of occurences of an event in the path
;; are greater than the number of maximum loops allowed: varun
(defun check-max-loops (event path)
   (if (> (get-num-event-occurences event (mapcar #'get-event path)) *maxloops*) t nil))


;; -- Changed to take allow the path to continue if a loop is found
;;    & stop if the loop has executed more the *maxloops* times  :varun
(defun collect-simulated-event (event prev-situation next-situation
			        del-list add-list start-time &optional (stream *kanal-log-stream*))
  ;(format t "in collect-simulated-event ~%")
  (let ((paths-containing-prev-event
         (find-paths-containing-situation prev-situation))
        (new-event-info (make-event-info
		     :event event
		     :prev-situation prev-situation
		     :next-situation next-situation))
        (max-loops-found nil) (loops-found nil))
    (cond ((or (null *paths-simulated*) (null paths-containing-prev-event))
	 (add-path-to-simulated-paths (list (update-event-info-for-effects
				       new-event-info
				       del-list
				       add-list
				       start-time
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


			(if (loop-found event path) (setq loops-found t))
			(cond ((check-max-loops event path) ;; Changed by Varun
			       (setq max-loops-found t)
			       (setq *max-loops-path* path)
			       (goto prev-situation);; go back to the earlier situation
			       (setq result (append result (list path))))
			      (t 
			       ;; TODO TO BE MODIFIED TO INSERT SORTED RATHER THAN APPEND
			       (setq result
				   (append result
					 (list (append path
						     (list (update-event-info-for-effects
							  new-event-info
							  del-list add-list
				                          start-time
							  last-event-info)))))))))
		         (t;; containing the event (because of disjunctive branches)
			(let ((initial-sequence
			       (find-initial-sequence-ends-with prev-situation path)))
			  (setq result (append result (list path)));; add the original path info
			  (when (not (member initial-sequence paths-before-prev-event :test #'equal))
			        (setq paths-before-prev-event (push initial-sequence paths-before-prev-event))
			        (setq last-event-info (first (last initial-sequence)))

				;; Changed by Varun
			        (if (loop-found event initial-sequence) (setq loops-found t))
				(format t "loops :: ~S~%" loops-found)
			        (cond ((check-max-loops event initial-sequence)
				     (goto prev-situation);; go back to the earlier situation
			             (setq *max-loops-path* initial-sequence)
				     (setq max-loops-found t))
				    (t 
				     ;; TODO TO BE MODIFIED TO INSERT SORTED RATHER THAN APPEND
				     (setq result
					 (append result
					         (list (append initial-sequence
							   (list (update-event-info-for-effects
								new-event-info del-list add-list start-time
								last-event-info))))))))))))))
	   (setq *paths-simulated* result))))
				;(report-simulated-paths)
    ;(format t "back from collect-simulated-event ~%")
    (if max-loops-found
        nil
	(if loops-found
	   'loop
      *paths-simulated*))
    ))

;;===========================================
;; Start of additions for Handling temporal
;; relations...
;; ... will be documented more later...
;; :varun
;;===========================================

;; Lists for storing temporal info
(defvar *time-event-assoc* nil)
(defvar *event-time-assoc* nil)
(defvar *event-duration-assoc* nil)
(defvar *next-list* nil) ;; List of next-events
(defvar *all-next-list* nil) ;; List of all next-events (recursive)
(defvar *prev-list* nil) ;; List of previous events
(defvar *during-list* nil)
(defvar *start-times-list* nil)

;; This will fill up the associative lists above
(defun collect-all-temporal-info()
    (setq *time-event-assoc* nil)
    (setq *event-time-assoc* nil)
    (setq *event-duration-assoc* nil)
    (setq *next-list* nil)
    (setq *prev-list* nil)
    (setq *during-list* nil)
    (setq *start-times-list* nil)
    (setq *temporal-loops-found* nil)
    (let ((event-list (get-all-executable-events)))
          (mapcar #'create-time-slots-if-absent event-list)
          (mapcar #'get-event-time-assoc event-list)
          (mapcar #'get-event-duration-assoc event-list)
          (mapcar #'collect-event-temporal-info event-list))

    (merge-during-and-next-lists)
    (mapcar #'construct-prev-list *next-list*)
    (setq *all-next-list* (mapcar #'(lambda (item) 
                                    (get-recursive-next-events (car item) nil)) *next-list*))

    (mapcar #'get-temporal-loops *all-next-list*)
    (if *temporal-loops-found*
       (generate-error-checker-item *temporal-loops-found*
					  ':temporal-loop
					  ':warning
					  nil *model-to-test*)))

(defun create-time-slots-if-absent (event)
  (let ((timeval (get-role-values-with-checking "time" event nil)))
       (if timeval nil
           (km-k `(,event #$has (#$time ((#$a #$Time-Interval))))))
  ))
   
;; Add a loop warning, if a next-event is also a previous-event
(defun get-temporal-loops (next-list-elem)
  (let* ((event (car next-list-elem))
         (next-events (cdr next-list-elem))
         (prev-events (cdr (assoc event *prev-list*))))

       (dolist (ev prev-events)
	 (cond ((and (member ev next-events)
	        (not (assoc event *temporal-loops-found*)))
	        (setq *temporal-loops-found* 
		      (append (list (list event ev)) *temporal-loops-found*)))))
  ))

;; Get all next-events recursively
(defun get-recursive-next-events (event evlist)
  (let ((next-events (cdr (assoc event *next-list*))))
      (cond ((member event evlist) nil)
            (t 
              ;; If not a loop so far, append the event to the evlist
	      (setq evlist (append evlist (list event)))
              (cond ((null next-events) nil)
                (t 
		   ;; If the next-events are not null, find them out and append them too
                   (mapcar #'(lambda (ev) (setq evlist (get-recursive-next-events ev evlist))) next-events)))))
  evlist
  ))

;; Construct prev-event list from next-event list
(defun construct-prev-list (next-list-elem)
   (let* ((event (car next-list-elem))
          (next-events (cdr next-list-elem)))

       (dolist (ev next-events)
          ;; If A is before B,C & D
	  ;; - Then B is after A, C is after A & D is after A
          (let ((cur-prev-events (cdr (assoc ev *prev-list*))))
             (if cur-prev-events
               (setq *prev-list* (remove-if #'(lambda (li) (equal (car li) ev)) *prev-list*)))
	       (setq cur-prev-events (append (list event) cur-prev-events))
	       (setq *prev-list* (append *prev-list* (list (append (list ev) cur-prev-events))))))
   ))


;; Merge during-event list and next-event list
;; Keep merging till there is no difference
(defun merge-during-and-next-lists ()
   (let* ((old-next-list *next-list*))
      (mapcar #'merge-during-item-with-next-list *during-list*)
      (setq *next-list* (mapcar #'remove-duplicates *next-list*))
      (if (not (equal old-next-list *next-list*)) 
          (merge-during-and-next-lists))
   ))
	  
;; Actual merging of the during-event with the next-events
(defun merge-during-item-with-next-list (during-list-elem)
   (let* ((event (car during-list-elem))
          (during-events (cdr during-list-elem))
	  (next-list *next-list*)
	  (cur-next-events (assoc event next-list)))

       (dolist (dev during-events)
          ;; If A is during B , and , B is before D
          ;; - Then A is also before D
          (let ((next-events (cdr (assoc dev *next-list*))))
             (if cur-next-events
                (setq *next-list* (remove-if #'(lambda (li) (equal (car li) event)) *next-list*)))
	     (cond (next-events 
	       (setq cur-next-events (append next-events cur-next-events))
	       (setq *next-list* (append *next-list* (list (append (list event) cur-next-events)))))))

          ;; If A is during B , and , D is before B
          ;; - Then D is also before A
	  (dolist (elem next-list)
	     (let ((ev (car elem))
	        (cur-next-events (cdr elem)))
	           (cond ((member dev cur-next-events)
                          (setq *next-list* (remove-if #'(lambda (li) (equal (car li) ev)) *next-list*))
	                  (setq cur-next-events (append (list event) cur-next-events))
	                  (setq *next-list* (append *next-list* (list (append (list ev) cur-next-events))))))))
   )))

;; Make associative arrays for event-duration pairs
 (defun get-event-duration-assoc (event)
   (let ((duration (get-role-values-with-checking "duration" event nil))
         (durationval nil))
        (cond (duration
	      (setq durationval (cadar (get-role-values-with-checking "value" duration nil)))
              (setq *event-duration-assoc* 
               (append *event-duration-assoc* (list (list event durationval))))))
  ))

;; Make associative arrays for event-timeval pairs
(defun get-event-time-assoc (event)
  (let ((timeval (get-role-values-with-checking "time" event nil)))
    (setq *time-event-assoc* (append *time-event-assoc* (list (append timeval (list event)))))
    (setq *event-time-assoc* (append *event-time-assoc* (list (append (list event) timeval))))
  ))


;; Get role values (before, during) for all the timevals
(defun get-all-role-values (timevals role)
   (let ((return-timevals nil))
      (dolist (tv timevals)
         (setq return-timevals (append return-timevals (get-role-values-with-checking role tv nil))))
      return-timevals
   ))

;; Get events from the timevalues (from the associative arrays)
(defun get-events-from-timevals (timevals)
    (let ((events nil))
	(setq events (mapcar #'(lambda (tv) (cadr (assoc tv *time-event-assoc*))) timevals))
	events
    ))

;; Makes associative lists for storing 
;; - the events that occur before an event (*next-list*)
;; - the events that occur during an event (*during-list*)
;; These lists are merged to form a larger *next-list* later: varun
;; TODO - Only 'before', 'after' and 'during' being used right now
;; (Note: after is taken care of by being defined as inverse of before in the km)

(defun collect-event-temporal-info (event)
  (let* ((timevals (cdr (assoc event *event-time-assoc*)))
	 (next-events (get-events-from-timevals (get-all-role-values timevals "before")))
	 (during-events (get-events-from-timevals (get-all-role-values timevals "during")))
	 (cur-next-events (cdr (assoc event *next-list*)))
	 (cur-during-events (cdr (assoc event *during-list*))))

         ;; Handle "before"
         (cond (next-events 
            (if cur-next-events
                (setq *next-list* (remove-if #'(lambda (li) (equal (car li) event)) *next-list*)))
	    (setq cur-next-events (append next-events cur-next-events))
	    (setq *next-list* (append *next-list* (list (append (list event) cur-next-events))))))

         ;; Handle "during"
         (cond (during-events 
            (if cur-during-events
                (setq *during-list* (remove-if #'(lambda (li) (equal (car li) event)) *during-list*)))
	    (setq cur-during-events (append during-events cur-during-events))
	    (setq *during-list* (append *during-list* (list (append (list event) cur-during-events))))))
  ))

;; End of additions : varun (6/24/2002)
;;=====================================

(defun get-simulated-paths ()
    (mapcar #'(lambda (path)
		(mapcar #'get-event path))
     *paths-simulated*)
  )

(defun get-all-executable-events (&optional (instance *current-model-instance*))
  (if (equal *execution-mode* 'primitive-steps-only)
      (get-primitive-events instance)
;modified by amit agarwal
;in case of missing subevents get-all-subevents returns nil
    (let ((aee (get-all-subevents instance)))
      (if aee
	  aee
	(let* ((participants (get-role-values-with-checking "participants" instance nil))
	       (events (remove-if-not #'check-if-action participants))
	       (missing-links nil))
	   (dolist (event events)
	     (if (and (null (test-expr `(#$:triple ,event #$subevent-of ,instance)))
		      (not (equal event instance)))
		 (setq missing-links (append missing-links (list event)))))
	   missing-links))))
  )

(defvar *events-to-be-removed* nil)
(defvar *events-already-checked* nil)

(defun get-events-to-be-removed (instance)
   (let* ((events (get-all-subevents instance))
          (cmpevents (cdr events)))
          (setq *events-to-be-removed* nil)
          (dolist (event events)
             (let ((evstarttime (km `(#$the #$value #$of (#$the #$start-time #$of (#$the #$time #$of ,event)))))
                   (evduration (km `(#$the #$value #$of (#$the #$duration #$of ,event))))
                   (evenemy (km `(#$the #$enemy #$of ,event)))
                   (evinstance (km `(#$the #$instance-of #$of ,event)))
                   (isoktoadd nil))
                (dolist (cmpevent cmpevents)
                  (let ((evsttime (km `(#$the #$value #$of (#$the #$start-time #$of (#$the #$time #$of ,cmpevent)))))
                        (evdur (km `(#$the #$value #$of (#$the #$duration #$of ,cmpevent))))
                        (evin (km `(#$the #$instance-of #$of ,cmpevent)))
                        (evenem (km `(#$the #$enemy #$of ,cmpevent))))
                        (cond ((and evsttime evdur evenem evin
                               (equal evsttime evstarttime) (equal evduration evdur) (equal evenemy evenem) (equal evin evinstance))
                            (let ((evagent (append (km `(#$the #$agent #$of ,cmpevent)) (km `(#$the #$agent #$of ,event)))))
                                 ;(format t "(km `(,~S #$has (#$agent ,~S))))~%" event evagent)
                                 (km `(,event #$has (#$agent ,evagent)))
                                 ;(format t "--> ~S~%" (km `(#$the #$agent #$of ,event)))
                                 )
                            (format t "merging ~S  && ~S to -> ~S ~%" event cmpevent event)
                            (format t "Enemy : ~S  && Enemy : ~S~%" evenemy evenem)
                            (setq *events-to-be-removed* (append *events-to-be-removed* (list cmpevent)))
                            (setq *events-to-be-removed* (append *events-to-be-removed* (get-all-subevents cmpevent)))
                        ))
                  ))
             (setq cmpevents (cdr cmpevents)))
          )
	  ;(format t "events to be removed :: ~S~%" *events-to-be-removed*)
          ;; Remove the events to be removed from *all-subconcepts-used* (which is used by get-all-subevents)
          (setq *all-subconcepts-used* 
                 (mapcar #'(lambda (li)
                     (remove-if #'(lambda (ev) (member ev *events-to-be-removed*)) li))
                 *all-subconcepts-used*))
                            
          ;; Remove the events to be removed from KM
          (mapcar #'(lambda (ev)
                    (km `(#'(#$LAMBDA () (#$DELETE-FRAME ',ev))))) *events-to-be-removed*)
    ))

                               
(defun list-start-times (path)
     (let* ((event (get-event path)) 
            (times (append (list event) (get-start-time path)))
            (duration (cadr (assoc event *event-duration-assoc*))))
        (append times (list duration)))
)



;; Start of Changes to take care of parallel events
;; -varun

(defun get-event-start-time (event)
     (car (km `(#$the1 #$of (#$the #$value #$of (#$the #$start-time #$of (#$the #$time #$of ,event))))))
)

(defun get-event-end-time (event)
     (car (km `(#$the1 #$of (#$the #$value #$of (#$the #$end-time #$of (#$the #$time #$of ,event))))))
)

(defun get-unit-combat-power (unit)
    (car (km `(#$the1 #$of (#$the #$value #$of (#$the #$relative-combat-power #$of ,unit)))))
)

(defun get-full-enemy-combat-power (event)
      (km-unique-k `(#$the #$sum #$of
               (#$forall-bag
	          (#$the #$bag #$of
                     (#$:set
                      (#$the #$enemy #$of ,event)
                      (#$forall2
                        (#$the #$supported-by-military-unit #$of 
                           (#$the #$enemy #$of ,event))
                       #$It2)
	             ))
	          (#$the1 #$of (#$the #$value #$of (#$the #$relative-combat-power #$of #$It))))))
)

(defun earlier-start-time? (event1 event2)
   (< (get-event-start-time event1) 
      (get-event-start-time event2)))

(defun earlier-end-time? (event1 event2)
   (< (get-event-end-time event1) 
      (get-event-end-time event2)))


;; Get all other events occuring while the passed event is occuring 
;;   (overlapped/overlapping tasks)

(defun get-simultaneous-events (event)
    (let* ((subevents (get-all-subevents *current-model-instance*))
          (event-start (get-event-start-time event))
          (event-end (get-event-end-time event))
          (event-enemy (km `(#$the #$enemy #$of ,event)))
	  (simultaneous-events nil))

          (dolist (subevent subevents)
              (let ((subevent-start (get-event-start-time subevent))
                    (subevent-end (get-event-end-time subevent))
                    (subevent-enemy (km `(#$the #$enemy #$of ,subevent))))

                    ;; Process only if there is some temporal information
		    ;(format t "testing for ~S ~S and ~S ~S~%" event-start event-end subevent-start subevent-end)
                    (cond ((and (and event-start event-end event-enemy subevent-start subevent-end subevent-enemy)
		                (not (equal event subevent))
				(equal event-enemy subevent-enemy)
                                (or 
				  (and (<= event-start subevent-start) (>= event-end subevent-end))
				  (and (>= event-start subevent-start) (<= event-end subevent-end))
				  (and (> event-start subevent-start) (< event-start subevent-end))
				  (and (> event-end subevent-start) (< event-end subevent-end))
				))
		           ;(format t "got something~%")
			   (setq simultaneous-events (append simultaneous-events (list subevent))))
		     )
	      )
          )
	  simultaneous-events
    ))


(defun get-temporal-subevents (event)
    (let* ((subevents (get-all-subevents *current-model-instance*))
          (event-start (get-event-start-time event))
          (event-end (get-event-end-time event))
          (event-enemy (km `(#$the #$enemy #$of ,event)))
	  (simultaneous-events nil))

          (dolist (subevent subevents)
              (let ((subevent-start (get-event-start-time subevent))
                    (subevent-end (get-event-end-time subevent))
                    (subevent-enemy (km `(#$the #$enemy #$of ,subevent))))

                    ;; Process only if there is some temporal information
		    ;(format t "testing for ~S ~S and ~S ~S~%" event-start event-end subevent-start subevent-end)
                    (cond ((and (and event-start event-end event-enemy subevent-start subevent-end subevent-enemy)
		                (not (equal event subevent))
				(and (< event-start subevent-start) (> event-end subevent-end))
				(equal event-enemy subevent-enemy))
		           ;(format t "got something~%")
			   (setq simultaneous-events (append simultaneous-events (list subevent))))
		     )
	      )
          )
	  simultaneous-events
    ))

;; Get the units involved in a task (EXCLUDING PARALLEL TASKS)
;; -- includes the task agents ( & the supporting tasks ??)
;; -- currrently just returning the agent
;; -- could return a union of the agent and the supporting units ??

(defun get-involved-units (event)
   (km `(#$the #$agent #$of ,event))
)

(defun is-instance-of (instance concept)
   (member concept (km `(#$the #$instance-of #$of ,instance))))

;(defun mark-extra-direct-support (unitlist)
;   (let ((newunitlist nil))
;      (dolist (item unitlist)
;          (let* ((time (first item)) 
;	         (units (second item)) 
;		 (newunits nil))
;	         (dolist (unit units)
;                   (if (and (is-instance-of unit '#$Direct-Support-Artillery-Battalion)
;		            (subsetp (km `(#$the #$supports-military-unit #$of ,unit)) units))
;		       (setq newunits (append newunits (list (list unit 'removed))))
;		       (setq newunits (append newunits (list (list unit 'ok))))
;		       ))
;		 (if newunits
;		    (setq newunitlist (append newunitlist (list (list time newunits)))))
;	  ))
;      newunitlist
;   ))

(defun mark-extra-direct-support (unitlist)
   (let ((newunitlist nil))
      (dolist (item unitlist)
          (let* ((time (first item)) 
	         (units (second item)) 
		 (newunits nil))
	         (dolist (unit units)
		   (let ((support-to (km `(#$the #$supports-military-unit #$of ,unit))))
                        (if (and (is-instance-of unit '#$Direct-Support-Artillery-Battalion)
		                 (subsetp support-to units)
			         (or (is-instance-of (car support-to) '#$Armored-Brigade)
                                     (is-instance-of (car support-to) '#$Tank-Brigade)))
		            (setq newunits (append newunits (list (list unit 'removed))))
		            (setq newunits (append newunits (list (list unit 'ok))))
		       )))
		 (if newunits
		    (setq newunitlist (append newunitlist (list (list time newunits)))))
	  ))
      newunitlist
   ))

(defun remove-extra-direct-support (unitlist)
   (let ((newunitlist nil))
      (dolist (item unitlist)
          (let* ((time (first item)) 
	         (units (second item)) 
		 (newunits units))
	         (dolist (unit units)
		   (let ((support-to (km `(#$the #$supports-military-unit #$of ,unit))))
                        (if (and (is-instance-of unit '#$Direct-Support-Artillery-Battalion)
		                 (subsetp support-to units)
			         (or (is-instance-of (car support-to) '#$Armored-Brigade)
                                     (is-instance-of (car support-to) '#$Tank-Brigade)))
		            (setq newunits (k-set-difference newunits (list unit)))
		       )))
		 (if newunits
		    (setq newunitlist (append newunitlist (list (list time newunits)))))
	  ))
      newunitlist
   ))

(defun update-unit-list (unit-list current-time current-units) 
    (let ((newlist nil))
         (dolist (li unit-list)
	         (if (not (equal (car li) current-time))
		     (setq newlist (append newlist (list li)))))
	 (append newlist (list (list current-time current-units)))
    ))
;; Get the variation of units involved (in an attack on an enemy) during an event 
;; -- returns a list of the form ((7.75 (_Armored-Brigade2342 ..)) (8.0 (_Aviation-Battalion2323 ...)) .. ) 
;;    indicating time & the list of units involved at that time

(defun get-event-timeline (event &optional (unitevent? nil) (mark-units? nil))
   (let* ((start-time-sorted-events (sort (append (list event) (get-simultaneous-events event)) #'earlier-start-time?))
          (end-time-sorted-events (sort (append (list event) (get-simultaneous-events event)) #'earlier-end-time?))
	  (current-units (get-involved-units event))
	  (unit-list nil)
	  (unit-event-map nil)
	  (current-time (get-event-start-time event))
	  (ending-time (get-event-end-time event)))

          ;; Process all event starts with a start-time before the start-time of the event
	  (dolist (next-event start-time-sorted-events)
	      (cond ((< (get-event-start-time next-event) current-time)
		      (setq current-units (union current-units (get-involved-units next-event)))
	              (setq start-time-sorted-events (cdr start-time-sorted-events))
	              (setq unit-event-map (append unit-event-map 
		                           (list (list current-time next-event (get-involved-units next-event)))))
	      ))
	  )
	  (setq unit-list (update-unit-list unit-list current-time current-units))

	  ;(format t "events :: ~S~%" start-time-sorted-events)

          ;; Process all event starts
	  (dolist (next-event start-time-sorted-events)
	     (let* ((next-event-start-time (get-event-start-time next-event)))
	       ;(format t "~S: next starting event : ~S~%" next-event-start-time next-event)

	       ;; Check if the next-ending-event ends
	       ;; earlier than the start time of the next-event (starting event)
	       ;; -- update current-time and current-units
	       (dolist (next-ending-event end-time-sorted-events)
	          (let* ((next-ending-event-time (get-event-end-time next-ending-event)))
	            (cond ((<= next-ending-event-time next-event-start-time)
	                   (setq current-time next-ending-event-time)
		           (setq current-units (set-difference current-units (get-involved-units next-ending-event)))
		           (setq end-time-sorted-events (cdr end-time-sorted-events))
	                   (setq unit-list (update-unit-list unit-list current-time current-units))
	                   ;(format t "unit-list : ~S ~%" unit-list)
	            ))))

	       ;; See the next parallel event 
	       ;;  -- update current time
	       ;;  -- add it's combat power to current
	       (setq current-time next-event-start-time)
	       (setq current-units (union current-units (get-involved-units next-event)))
	       (setq unit-list (update-unit-list unit-list current-time current-units))
	       (setq unit-event-map (append unit-event-map 
	                           (list (list current-time next-event (get-involved-units next-event)))))
	       ;(format t "unit-list : ~S ~%" unit-list)
	  ))

	  ;(format t "unit-list : ~S ~%" unit-list)
	  ;(format t "events left out :: ~S ~%" end-time-sorted-events)

          ;; Process all remaining ending events
	  (dolist (next-ending-event end-time-sorted-events)
	      (let ((next-event-end-time (get-event-end-time next-ending-event)))
	         (cond ((< next-event-end-time ending-time)
	                 ;; See the next ending event 
	                 ;;  -- update current time
	                 ;;  -- subtract it's combat power from current
			 ;(format t "~S (~S) ends at ~S ~%" next-ending-event next-event-end-time (get-involved-units next-ending-event))
			 ;(format t "current units : ~S~%" current-units)
	                 (setq current-time next-event-end-time)
	                 (setq current-units (set-difference current-units (get-involved-units next-ending-event)))
	                 (setq unit-list (update-unit-list unit-list current-time current-units))
	         ))
	  ))

	  ;(format t "unit-list : ~S ~%" unit-list)

	  (dolist (ul unit-list)
	      (if (> (get-num-event-occurences (car ul) (mapcar #'car unit-list)) 1)
	          (setq unit-list (k-set-difference unit-list (list ul)))))

          (if mark-units?
	     (setq unit-list (mark-extra-direct-support unit-list))
	     (setq unit-list (remove-extra-direct-support unit-list))
	  )
          (setq unit-list (sort unit-list #'earlier-time?))
          (setq unit-event-map (sort unit-event-map #'earlier-time?))
	  (if unitevent?
	      (list unit-list unit-event-map)
	      unit-list
	  )
    )
)

(defun earlier-time? (l1 l2)
   (< (car l1) 
      (car l2)))


(defun get-combat-power-timeline (event)
   (let ((timeline nil))
         (setq timeline 
	     (mapcar #'(lambda (item) 
               (let ((combat-power 0)
	             (units (cadr item)))
		     (mapcar #'(lambda (unit) 
		               (setq combat-power (+ combat-power (get-unit-combat-power unit)))) units)
		     (list (round-real (car item)) (round-real combat-power))))
             (get-event-timeline event)))
	 (setq timeline (append timeline (list (list (second (get-end-time-from-km event)) ()))))
	 timeline 
   ))


(defun get-unit-information (unit start-time unitevent)
    (let ((part-of-event nil)
          (unit-info (get-combat-power-description unit)))
          (dolist (item unitevent)
	       (if (and (equal (first item) start-time)
	                (member unit (third item)))
	           (setq part-of-event (second item))))
	  (append (list (format nil "Is part of ~A" (p-english part-of-event))) unit-info)
    ))


(defun get-unit-timeline (event)
   (let* ((fulltimeline (get-event-timeline event t t))
          (timeline (car fulltimeline))
          (unitsinaction nil)
	  (unitlist nil)
	  (unitlaststart nil))
         ;(setq timeline '( (1.0 (Brig1)) (1.5 (Brig1 Brig2)) (2.5 (Brig1 Brig2 Brig3)) 
	 ;                  (3.5 (Brig1 Brig2 Brig3 Avn1)) (4.0 (Brig1 Brig2 Brig3))
	 ;		   (4.5 (Brig1 Brig3 Avn1)) (5.5 (Brig1)) (6.0 nil)))
         ;
	 (setq timeline (append timeline (list (list (second (get-end-time-from-km event)) ()))))
	 ;(format t "timeline :: ~S~%" timeline)

	 (dolist (item timeline)
	     (let* ((time (round-real (car item)))
	            (units (mapcar #'car (cadr item)))
		    (unitsin (k-set-difference units unitsinaction))
		    (unitsout (k-set-difference unitsinaction units)))
	     (setq unitsinaction units)

	     (dolist (in unitsin)
	            (setq unitlaststart (append unitlaststart (list (list in time)))))
	     ;(format t "time :: ~S~%" time)
	     ;(format t "units in :: ~S~%" unitsin)
	     ;(format t "units out :: ~S~%" unitsout)
	     ;(format t "last start :: ~S~%" unitlaststart)

	     (dolist (out unitsout)
	         (let ((start (assoc out unitlaststart)))
	            ;(format t "removing from last start :: ~S ~S~%" unitlaststart start)
		    (setq unitlaststart (remove-if #'(lambda (it) (equal it start)) unitlaststart))
	            ;(format t "new last start :: ~S~%" unitlaststart)
	            (setq unitlist (append unitlist (list (list out (cadr (assoc out (cadr (assoc (cadr start) timeline))))
		                                                    (round-real (get-unit-combat-power out)) 
		                                                    (list (cadr start) time)
								    (get-unit-information out (cadr start) (second fulltimeline))))))
		 ))
	     ))
	 unitlist
   ))

(defun get-max-combat-power (event)
   (let* ((event-timeline (get-event-timeline event))
          (max-combat-power 0))
	  (dolist (item event-timeline)
	     (let ((transient-combat-power 0)
	           (units (cadr item)))
		 (mapcar #'(lambda (unit) (setq transient-combat-power (+ transient-combat-power (get-unit-combat-power unit)))) units)
		 (if (> transient-combat-power max-combat-power)
		     (setq max-combat-power transient-combat-power)
		 ))
	  )
	  max-combat-power
    ))

		  
           

(defvar *already-found-subevents* nil)
;added by Amit Agarwal  (5/30/2002)
(defun list-subevents (event)
  (format t "[#] for event ~S~%" event)
  (let* ((subevents (get-subevents event))
         (tsubevents (get-temporal-subevents event))
	 (allsubevents (set-difference (union subevents tsubevents) *already-found-subevents*)))
     (format t "--> ~S~%" allsubevents)
     (setq *already-found-subevents* (union *already-found-subevents* allsubevents))
     (if allsubevents
         (list event allsubevents))
  ))

;added by Amit Agarwal (8/1/2002)
(defun get-agents-and-objects (event)
  (let ((agents (get-role-values event '#$agent))
	(objects (get-role-values event '#$object))
	);(unitAssignedToTask (get-role-values event '#$unitAssignedToTask)))
    (union agents objects)
    )
  )

;added by Amit Agarwal (8/2/2002)
(defun list-properties-agobj (event instance situation prev-situation addlist dellist)
  (if (military-unit-p instance)
    (let ((properties (get-roles-and-vals instance situation))
	(prev-properties (get-roles-and-vals instance prev-situation))
	;(addlist (get-role-values event '#$add-list situation))
	;(dellist (get-role-values event '#$del-list situation))
	(aplist nil)
	(coords nil)
	(dplist nil))

    (dolist (property prev-properties)
      (setq coords nil)
      (cond ((string-equal (first property) 'location)
        ;; FIXME : change... USE f-coordinate
        (setq coords (cdr (km-unique-k `(#$in-situation ,prev-situation (#$the #$f-coordinate #$of ,instance)))))
        (if (not coords) (setq coords (rkf::get-nusketch-coordinate instance)))))
      (cond ((or (string-equal (first property) 'location) 
                 (string-equal (first property) 'remaining-strength))

                 (when (is-present-in-add-del instance (car property) (append addlist dellist))
                       (if (and (string-equal (first property) 'remaining-strength)
                                (not (numberp (second property))))
		           (let ((propval (second property)))
		                (setq propval 
				   (car (km `(#$in-situation ,prev-situation (#$the1 #$of (#$the #$value #$of ,propval))))))
				(if (null propval)
				    (setq propval 1))
				(setq property (list (first property) propval))
				))

	               ;(setq dplist (append dplist (list property)))	
	               (setq dplist (append dplist (list (append property (list coords)))))
	         )
             )
      ))

    (dolist (property properties)
      (setq coords nil)
      (cond ((string-equal (first property) 'location)
        ;; FIXME : change... USE f-coordinate
        (setq coords (cdr (km-unique-k `(#$in-situation ,situation (#$the #$f-coordinate #$of ,instance)))))
        (if (not coords) (setq coords (rkf::get-nusketch-coordinate instance)))))
      (cond ((or (string-equal (first property) 'location) 
                 (string-equal (first property) 'remaining-strength))

                 (when (is-present-in-add-del instance (car property) (append addlist dellist))
                       (if (and (string-equal (first property) 'remaining-strength)
                                (not (numberp (second property))))
		           (let ((propval (second property)))
		                (setq propval 
				   (car (km `(#$in-situation ,situation (#$the1 #$of (#$the #$value #$of ,propval))))))
				(if (null propval)
				    (setq propval 1))
				(setq property (list (first property) propval))
				))

	               ;(setq aplist (append aplist (list property)))
	               (setq aplist (append aplist (list (append property (list coords)))))
	         )
	      )
      ))

    (if (or dplist aplist)
        (list dplist aplist)
        nil)
  )))

;added by Amit Agarwal (8/2/2002)
(defun is-present-in-add-del (instance property add-del)
  (let ((present nil))
    (dolist (item add-del)
      (if (and (equal (get-role item) property) (equal (get-object item) instance))
	  (setq present t)
	)
      )
    present
    )
  )

(defun generate-subevent-info-item()
	(format t "~%listing subevents~%")
	(generate-info-item :subevents
		(mapcar #'list-subevents (get-all-subevents *current-model-instance*))
		*model-to-test*)
)

(defun get-start-time-value (item)
    (second (get-start-time item)))

(defun report-simulated-paths ()
  (cond ((null *paths-simulated*)
         (kanal-format "~% There was no simulation path~%~%")
	 (kanal-html-format "<br> There was no simulation path<br>")
	 (generate-error-checker-item *all-executable-events*
			        ':unreached-events
			        ':warning nil
			        'no-simulation-path-exist)
	 ; generated to get a class definition for the model-to-test
	 ; in the xml output
         (generate-info-item :simulated-paths nil *model-to-test*)
         nil)
        (t 
	 (format t ">setting simulated paths~%")
         (generate-info-item :simulated-paths
		         (mapcar #'(lambda (path)
				 (let ((event-list (mapcar #'get-event (sort path #'< :key #'get-start-time-value))))
				   (check-unnecessary-ordering-constraints event-list)
				   event-list))
			       *paths-simulated*)
		         *model-to-test*)

	 (format t ">populating simulated paths info~%")
	 (generate-info-item :simulated-paths-info
			     *paths-simulated*
			     *model-to-test*)

;; added by Varun
	 (format t ">populating event start times~%")
         (generate-info-item :event-start-times
		         (mapcar #'(lambda (path)
				     (mapcar #'list-start-times path))
			       *paths-simulated*)
		         *model-to-test*)


;-----------------
         (kanal-format "~%~%  ************************************************")
         (kanal-format "~%          Summary of Paths Simulated")
         (kanal-format "~%  ************************************************")
         (kanal-format "~%~%  These are the simulated paths: ~%")
      
         (kanal-html-format "<hr><h2>Summary of alternative paths simulated</h2>~%<ul>~%")
      
         (mapcar #'(lambda (path)
		 (let* ((events (mapcar #'get-event path))
		        (unreached-events
		         (set-difference 
			*all-executable-events* events)))
		   (kanal-format "     ~S~%" events)
		   (kanal-html-format "<li>~S~%" events)
		   (when unreached-events
		         (kanal-format "~% ~S ~% were not reached in this path~%~%"
				   unreached-events)
		         (kanal-html-format "<br>~S were not reached in this path~%"
				        unreached-events)
			 (generate-error-checker-item unreached-events
					        ':unreached-events
					        ':warning nil
					        (if (and *failed-event-info*
							 (equal (first *failed-event-info*) ':precondition))
						    (list 'failed-condition (second *failed-event-info*))
						  (list 'missing-ordering-constraint)))
		         
		         )
		   (kanal-html-format "</li>~%")
		   )
		 )
	       *paths-simulated*)
         (kanal-html-format "</ul>~%")
	 (format t "<done reporting simulated paths~%")
         )))


(defun check-unnecessary-ordering-constraints (event-list)
  nil)
#| COA specific, we are not showing :unnecessary-link - jihie
(defun check-unnecessary-ordering-constraints (event-list)
  (let ((result (check-unnecessary-ordering-constraints-1 event-list nil)))
    (if result
	(generate-error-checker-item 'ordering
				     ':unnecessary-link
				     ':warning nil
				     result)))
  )
|#


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

(defun cancelled-equivalent-effect-in-del-list (effect prev-deleted-effects)
  (let ((new-del-list nil)
	(found-equivalent-effect nil))
    (dolist (del-effect-info prev-deleted-effects)
      (let ((del-effect (first del-effect-info)))
	(cond ((or (equal effect del-effect)
		   (effect-equivalent effect del-effect))
	       (setq found-equivalent-effect t)
	       (kanal-format "~%      canceling effects: adding ~S ~%         which has been deleted by earlier (or current) action ~S"
			 effect (second del-effect-info))
	       (kanal-html-format "~%<br>      canceling effects: adding ~S ~%         which has been deleted by earlier (or current) action ~S"
			      effect (second del-effect-info)))
	      (t 
	       (setq new-del-list (append new-del-list (list del-effect-info))))))
      )
    (if found-equivalent-effect
	 new-del-list
      nil)))

(defun cancelled-equivalent-effect-in-add-list (effect prev-added-effects )
  (let ((new-add-list nil)
	(found-equivalent-effect nil))
    (dolist (added-effect-info prev-added-effects)
      (let ((add-effect (first added-effect-info)))
	(cond ((or (equal effect add-effect)
		   (effect-equivalent effect add-effect))
	       (setq found-equivalent-effect t)
	       (kanal-format "~%      canceling effects: deleting ~S ~%         which has been added by earlier (or current) action ~S"
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

(defun update-event-info-for-effects (new-event-info del-list add-list start-time prev-event-info)
  (let ((all-added-effects (get-all-added-effects prev-event-info))
	(all-deleted-effects (get-all-deleted-effects prev-event-info))
	(event (get-event new-event-info)))
    (dolist (del-effect (set-difference del-list add-list :test #'equal))
      (let ((added-effects-changed-after-cancelling
	     (cancelled-equivalent-effect-in-add-list
			   del-effect all-added-effects)))
	(if added-effects-changed-after-cancelling
	    (setq all-added-effects added-effects-changed-after-cancelling)
	  (if (not (member (list del-effect event) all-deleted-effects :test #'equal))
	      (setq all-deleted-effects
		    (append all-deleted-effects (list (list del-effect event))))))))
    (dolist (added-effect (set-difference add-list del-list :test #'equal))
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
    (setf (event-info-start-time new-event-info) start-time)
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




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  Additional Functions to support Q/A (Process-Type Questions)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun objects-participate (object-classes event)
  (find-roles-played object-classes event))

(defun objects-participate-as-input (object-classes event)
  (find-roles-played object-classes event 'input))	    

(defun intermediate-products-participate-as-input (results event)
  (find-roles-played-by-objects results event 'input)
  )

(defun get-products-of-event (event)
  (let ((roles-vals (get-roles-and-vals-of-event event))
	(products nil))
    (dolist (role-vals roles-vals)
      (if (match-role-type (first role-vals) 'output)
	  (dolist (val (second role-vals))
	    (if (atom val) ;; consider  |result| and |resulting-state|
		(setq products (append products (list val)))))))
    products
    )
  )

(defun find-role-vals (role roles-vals)
  (if (null roles-vals)
      nil
    (if (equal role (first (first roles-vals)))
	(second (first roles-vals))
      (find-role-vals role (rest roles-vals)))
    )
  )

(defun get-effects-of-event-from-path (event added-effects-info-from-path deleted-effects-info-from-path)
  (let ((added-effects-from-event nil)
	(deleted-effects-from-event nil))
   
      (dolist (add-info added-effects-info-from-path)
	  (if (and (equal event (second add-info))
		   (not (null (get-val (first add-info))))) ;; remove null value effects
	      (push (first add-info) added-effects-from-event)))
      (dolist (del-info deleted-effects-info-from-path)
	  (if (equal event (second del-info))
	      (push (first del-info) deleted-effects-from-event)))
    (list added-effects-from-event deleted-effects-from-event)
    )
  )

(defun merge-effects (effects1 effects2)
  (list (union (first effects1) (first effects2) :test #'equal)
	(union (second effects1) (second effects2) :test #'equal))
  )

(defun get-effects-of-event (event)
  (let ((roles-vals (get-roles-and-vals-of-event event))
	)
    (list (find-role-vals '#$add-list roles-vals)
	  (find-role-vals '#$del-list roles-vals))
    )
  )

(defun match-role-type (role role-type)
  (cond ((null role-type) ;; any type is fine
	 't)
	((equal role-type 'input)
	 (not (or (equal role 'user::|result|)
		  (equal role 'user::|resulting-state|)
		  (equal role 'user::|add-list|)
		  (equal role 'user::|del-list|)
		  (equal role 'user::|pcs-list|)))
	 )
	((equal role-type 'output)
	 (or (equal role 'user::|result|)
		  (equal role 'user::|resulting-state|)
		  (equal role 'user::|add-list|)
		  ;(equal role 'user::|del-list|)
		  )
	 )
	(t
	 't)
  ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; find enabled event transitively and returns a list of
;;    1 an-enabling-event
;;    2 an-enabled-event
;;    3 a list of
;;        triples-achieved/asserted-by-the-enabling-event
;; EXAMPLE:
;; (find-enabled-events-in-path user::|_Move-Out-Of1273|
;;      ((user::|_Move-Out-Of1273| user::|_Move-Into1274| ((:|triple| user::|_Tangible-Entity1275| user::|location| user::|_Place1354|)))
;;       (user::|_Attach1268| user::|_Move-Out-Of1273| ((:|triple| user::|_Be-Attached-To1300| user::|object| user::|_Tangible-Entity1269|))))
;;      (user::|_Attach1268| user::|_Breach1297| user::|_Traverse1299| user::|_Penetrate1270| user::|_Move-Out-Of1273| user::|_Move-Into1274|))
;; =>
;; ((user::|_Move-Out-Of1273| user::|_Move-Into1274| ((:|triple| user::|_Tangible-Entity1275| user::|location| user::|_Place1354|))))
;;
(defun find-enabled-events-in-path (event all-causal-links-found-from-kanal path)
  (let ((result nil))
    (dolist (causal-link all-causal-links-found-from-kanal)
      (if (and (or ;; the enabling event is the same as the event
		   (equal (first causal-link) event)
		   ;; the enabling event is the same as one of the enabled events found
		   (member (first causal-link) (mapcar #'first result)))
	       (member (second causal-link) path)) ;; the enabled event is in the path
	  (setq result (append result (list causal-link))))
      )
    result
    )
  )
(defun find-enabled-events (event all-causal-links-found-from-kanal)
  (let ((result nil))
    (dolist (causal-link all-causal-links-found-from-kanal)
      (if (or (equal (first causal-link) event)
	      (member (first causal-link) (mapcar #'first result)))
	  (setq result (append result (list causal-link))))
      )
    result
    )
  )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; this returns a list of roles 
;; EXAMPLE:
;; (find-roles-played (user::|Viral-DNA| user::|Viral-Nucleic-Acid|) user::|_Move-Into1149|)
;; =>
;; (user::|object|)
(defun find-roles-played (object-classes event &optional (role-type nil))
  (let ((roles-vals (get-roles-and-vals-of-event event))
	(result nil))
    (dolist (role-vals roles-vals)
      (if (match-role-type (first role-vals) role-type)
	  (let ((matched-role-player nil))
	    (dolist (val (second role-vals))
	      (if (and (atom val) ;; only consider atoms (and not triples) for now
		       (intersection (get-concepts-from-instance val) object-classes))
		  (setq matched-role-player val)))
	    (if matched-role-player
		(setq result (append result (list (first role-vals)))))
	    )))
      result
    ))

(defun find-roles-played-by-objects (objects event &optional (role-type nil))
  (if objects 
      (let ((roles-vals (get-roles-and-vals-of-event event))
	    (result nil))
	(dolist (role-vals roles-vals)
	  (if (match-role-type (first role-vals) role-type)
	      (let ((matched-role-player nil))
		(dolist (val (second role-vals))
		  (if (and (atom val) ;; only consider atoms (and not triples) for now
			   (member val objects))
		      (setq matched-role-player val)))
		(if matched-role-player
		    (setq result (append result (list (first role-vals)))))
		)))
	result
	)
    nil
    )
  )

(defun get-roles-and-vals-of-event (event)
  (let ((before-situation (cadar
			   (get-role-values event #$'before-situation))))
    (get-roles-and-vals event before-situation)
    )
  )

