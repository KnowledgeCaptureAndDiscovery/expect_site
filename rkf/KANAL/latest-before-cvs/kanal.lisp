
#|
Jihie Kim 

 API

test-knowledge (concept)
 return value: a list of error items and simulation-info items

NOTE: we assume simulation executes primitive (leaf) steps only
NOTE: for precondition-tests, this reports
      succeeded precondition as well as failed preconditions

get-proposed-fixes (error-id)
 return value: a list of fixes for the error


 KANAL calls to Interaction Manager

get-expected-effects-for-model (concept)
 return value: nil or a km expr

[error item] 
1) ID 
2) constraint:  KM expressions (a list of KM expressions) or
                a list of loops found
3) type:  
      ERRORS 
                :precondition
                  NOTE: this implies failure of simulation
                :expected-effect
                :undoable-event (undoable because of ordering constraints,
		                  ex: previous events were not executed)
                  NOTE: this implies failure of simulation
                :invalid-expr (invalid triple with null obj or null role)
                :not-exist (ex: missing subevents which are refered by the model)

      WARNINGS
                :inexplicit-precondition (precondition is not explicitly satisfied 
		               but not inconsistent with the current KB)
                :unreached-events (unreached events in a simulation path
                                  because of ordering constraints (next-events,...))
		:missing-link
		   (ex: missing first-subevents definition for subevents)
		:cannot-delete (item in the del-list is not true)
		:no-effect (a step generates no effect (i.e, null del/add list))
		:loop
		:unnecessary-link
		(ex: the ordering constraints between steps are unnecessary because
		there are no explicit causal relationship between the steps)
	    
                :redundant-sequence, ...
         (replace :ordering and :causal-link by function calls to the 
          Process and Simulation Handler, like get-causal-links(),
	  find-next-events (event), get-simulated-paths (), ...)
4) level: :error or :warning
5) success: t or nil  ;;;; t means that the KM expression was satisfied
6) source: step or component

[info item] 
1) ID 
2) type: one of 
      :simulated-paths 
      :causal-links   

3) content: 
      :simulated-paths 
          a list of (list of events)
      :causal-links   
          a list of (ENABLING-STEP ENABLED-STEP TRIPLES)

4) source: concept/process-model

[fix item]
1) fix: fix instruction
2) type: one of
NOTE: in the content form, the upper-cased names are variables.

    :add-step - add an action when there is an unachieved effect
       content-form - (add ACTION {with ROLE-DESCRIPTION as VAL} to-make ROLE of OBJECT become VAL)

    :add-step-before-step - add an action for unachieved precondition
       content-form - (add ACTION {with ROLE-DESCRIPTION as VAL} before FAILED-STEP to-make ROLE of OBJECT become VALUE)
 example -
 ((type . :add-step-before-step)
  (fix add user::|Move| {with "The destination of the move" as
   (user::|the| user::|location| user::|of| (user::|the| user::|the-major-object| user::|of| user::|_Attach505|)) } before user::|_Attach505| to-make
   user::|location| of (user::|the| user::|the-minor-object| user::|of| user::|_Attach505|) become
   (user::|the| user::|location| user::|of| (user::|the| user::|the-major-object| user::|of| user::|_Attach505|))))

 
    :modify-step - modify a step
       content-form - (modify STEP {with PARTS-TO-BE-MODIFIED as VAL} to-make ROLE of OBJECT become VALUE)
              ;; in case of unachieved effect

            - (modify STEP {with PARTS-TO-BE-MODIFIED as VAL} before FAILED-STEP to-make ROLE of OBJECT become VALUE)
              ;; in case of failed precondition

            - (modify STEP to-delete-other-than TRIPLE)
              ;; TRIPLE cannot be deleted because it's not true in the current situation

            - (modify STEP to-achieve-something)
              ;; no effect was produced by the step

    :modify-steps - modify one or more steps
       content-form - (modify-events-before STEP to-assert TRIPLE)
              ;; TRIPLE cannot be deleted because it's not true in the current situation

    :modify-expr - modify expression(s) in a triple
       content-form - (modify-expr EXPR in SOURCE of STEP)
              ;; EXPR is (object-field OBJECT and role-field ROLE of TRIPLE) or
              ;;         (object-field OBJECT of TRIPLE)
              ;;         (role-field ROLE of TRIPLE)
              ;; currently the SOURCE is either :precondition or :expected-effect
              ;; STEP is either a step (:precondition case) or the process-model (:expected-effect case)

    :delete-or-modify-step
       content-form - (delete-or-modify FAILED-STEP)
               
    :change-or-add-link-between-steps (change/add ordering or subevent links between the actions)
       content-form - (change-or-add-link-between-steps-for-unreached-events UNREACHED-STEPS)
            - (change-or-add-link-between-steps-for-undoable-event UNDOABLE-STEPS)

    :add-link
       content-form - (add ROLE-DESC constraint for STEP(s))
       ;; example: (add ordering constraint for (Move-To1 Move-To2))

    :delete-or-modify-link
       content-form - (delete-or-modify ordering constraints in loops LOOPS-FOUND)
                    - (delete-or-modify ordering constraints in 
       ;; example: (delete ordering constraints in loops ((S1 S2 S1) (S2 S3 S4 S2)))
       ;; example: (delete ordering constraints in ((S1 before S2) (S4 before S6) ...)

    :add-expr
       content-form - (add EXPR as ROLE 'of OBJECT)
       ;; example: (fix add (|the| |Exit| |subevents| |of|
       ;;                      (|the| |Release| |subevent| |of|
       ;;                       (|the| |Deliver| |subevent| |of| |_TestVirusInvadesCell6|)))
       ;;                     as |next-event| of |_Degrade14|)

|#



;;; ======================================================================
;;;		K analysis
;;; ======================================================================
;;; File: kanal.lisp
;;; Author: Jihie Kim
;;; Date:  Thu Mar 22 15:44:36 PST 2001

(unless (find-package "KANAL") 
  (defpackage "KANAL"))

(in-package "KANAL")

(export '(test-knowledge 
          get-proposed-fixes))
(import '(
	  USER::km
	  USER::*km-package*
	  USER::*trace*
	  USER::km-unique
	  USER::km-format
	  USER::untracekm
	  USER::tracekm
	  USER::inherited-rule-sets
	  USER::own-rule-sets
	  USER::*error-report-silent* 
	  USER::*trace-log*
	  USER::*trace-log-on*
	  USER::make-sentence
	  USER::make-phrase
	  USER::global-situation
	  USER::write-frame
;;	  USER::pretty
;;	  shaken::get-expected-effects-for-model
	  ) )

(defvar *expressions-failed* nil)
(defvar *in-k-analysis* nil)

;; value can be no-interaction or use-interaction-plan
(defvar *interaction-mode* 'use-interaction-plan) 

;; value can be 'primitive-steps-only or 'all-steps
(defvar *execution-mode* 'primitive-steps-only)

(defun K-analysis-on ()
  (setq *in-k-analysis* t)
  (setq *expressions-failed* nil)
  (if *trace* (untracekm))
  (setq *paths-simulated* nil)
  (setq *loops-found* nil)
  (setq *causal-links* nil)
  (setq *error-report-silent* t)
 )


(defun K-analysis-off ()
  (setq *in-k-analysis* nil)
  (setq *error-report-silent* nil)
  )

(defun collect-failed-exprs-on ()
  (setq *expressions-failed* nil)
  (setq *trace-log* nil)
  (setq *trace-log-on* t)
  )

(defun collect-failed-exprs-off ()
  (setq *trace-log-on* nil)
  (let ((exprs
         (reverse
	(mapcar #'third;; get km expr
	        (remove-if-not #'(lambda (item)
			       (and (null (fourth item))
				  (equal 'exit (second item))
				  ;; exclude failure from projection
				  (not (member '#$in-situation (flatten item)))))
			   *trace-log*)))))
    ;;(format t "~% failed exprs:~S~%" exprs)
    (dolist (expr exprs);; remove the last
	  (add-failed-expr expr)))
  )


;;; ======================================================================
;;;  Test process knowledge using simulation
;;; ======================================================================

;; the checks can include:
;;   1. failed preconditions
;;   2. unachieved expected effects
;;   3. disjuctive branches
;;   4. redundancy
;;   5. loops
;;   6. ..



;; informs the first failed event during simulation : (fail-type, event, expressions)
;; this is used by the dialog planner
(defvar *failed-event-info* nil)


(defun simulate-steps-and-find-failed-events (model-instance start-situation)
  (setq *failed-event-info* nil)
  (goto start-situation)
  (simulate-events (find-first-primitive-events model-instance)
	         start-situation)
  *failed-event-info*
  )


(defun init-test-process-model (process-model)
  (K-analysis-on)
  (goto-global-situation)
  (let* ((start-situation (create-situation))
         (model-instance (create-instance process-model start-situation)))
    ;;(add-ordering-info model-instance) ; for the old component library
    (kanal-format *kanal-log-stream* "~%~% ===============================================")
    (kanal-format *kanal-log-stream* "~% Start testing ~S with ~%   ~S in ~S~%"
	        process-model model-instance start-situation)
    (list model-instance start-situation))
    
  )

(defun test-process-model (&optional (stream *kanal-log-stream*))
  (let* ((process-model *model-to-test*)
         (model-instance&start-situation (init-test-process-model process-model))
         (model-instance (first model-instance&start-situation))
         (start-situation (second model-instance&start-situation))
         (test-instance (if (equal *interaction-mode* 'use-interaction-plan)
		        (choose-substep process-model model-instance start-situation)
		      model-instance)))
    (when test-instance
	(setq *current-model-instance* test-instance)
	(let ((failed-event-info (simulate-steps-and-find-failed-events
			      test-instance start-situation)))
	  (report-simulated-paths)
	  (cond ((null failed-event-info);; no failed events
	         (find-unachieved-expected-effects process-model))
	        (t nil))
	       
	  (report-causal-links)
	  (report-loops)))
    (K-analysis-off))
  )


;;; ======================================================================
;;;		Propose Fixes
;;; ======================================================================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; this table stores effects of all the actions.
;;; the table is used in finding the actions that
;;;  can affect role values of an object

(defvar *action-effect-table* nil)
(defun build-action-table ()
  (setq *action-effect-table* nil)
  (if *trace* (untracekm))
  (setq *error-report-silent* t)
  (let ((new-situation (create-situation)))
    (goto new-situation)
	
  (dolist (action (get-all-actions))
    (let ((action-instance (create-instance action))
	  (primary-roles (get-primary-roles action))
	  (effects nil))
      ;; create instances for the primary roles and then 
      ;;  compute the effects based on them
      (dolist (role primary-roles)
	(if (null (get-role-values action-instance role))
	    (assert-role-value action-instance role (create-a-thing))))
	    
      (setq effects (list (get-the-add-list action-instance)
			  (get-the-del-list action-instance)))
      (push (list action effects) *action-effect-table*)
      ;(format t "~% effects: ~S" effects)
      ;(format t "~% table: ~S" *action-effect-table*)
      )))
  (setq *error-report-silent* nil)
  (kanal-format *kanal-log-stream* "~% action-effect-table:~% ~S~%" *action-effect-table*)
  *action-effect-table*
  )


;;; NOTE: these km calls are slow 
(defun compute-add-del-lists-1 (action);; concept
  (let ((action-instance (create-instance action))
        (primary-roles (get-primary-roles action)))
    (dolist (role primary-roles)
	  (if (null (get-role-values action-instance role))
	      (assert-role-value action-instance role (create-a-thing))))
    ;; changed from union by Jim on Jerome's suggestion. The code
    ;; calling this assumes the first element is the add list, not the
    ;; first effect.
    (list (get-the-add-list action-instance)
	(get-the-del-list action-instance))
    ))

(defun compute-add-del-lists (action)
  (let ((found (assoc action *action-effect-table*)))
    (cond (found
	 (cadr found))
	(t;; not found in the table
	 (let ((effects (compute-add-del-lists-1 action)))
	   (push (list action effects) *action-effect-table*)
	   effects
	   )))
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Suggest that there are missing steps in the process model
;;  1  Find components in the library that have the effect (or
;;	effects) needed by the failed action.
;;  2  Suggest to the user to insert one of these
;;	components somewhere within the current process model
;;	before the failed step.
(defun suggest-to-add-steps-that-can-achieve-the-effect (object role val failed-step
						    &optional (stream *kanal-log-stream*))
  
  (kanal-format-verbose stream "~%     .. checking if there are missing steps .. ~%")
  (let ((proposed-actions 
         (remove-duplicates (find-actions-that-can-change-role-value object role))))
    (dolist (action-and-vals proposed-actions)
	  (let* ((p-action (first action-and-vals))
	         (effect-vals (second action-and-vals))
	         (description-of-vals (make-sentence-for-vals effect-vals))
	         ;;(expected-val (make-sentence (pretty (evaluate-expr val))))
	         )
	    (cond ((null failed-step);; case of unachieved expected effect
		 (kanal-format-verbose
		  stream " proposed fix : add a ~S step with ~S as ~S to change the ~S of ~S~%"
		  p-action description-of-vals val role object)
		 (generate-fix-item
		  (list 'add p-action '{with description-of-vals 'as val '} 'to-make role 'of object 'become val) 
		  ':add-step)
		 )
		(t;; case of unachieved precondition
		 (kanal-format-verbose
		  stream " proposed fix : add a ~S step with ~S as ~S before step ~S to change ~S of ~S~%"
		  p-action description-of-vals val failed-step role object)
		 (generate-fix-item
		  (list 'add p-action '{with description-of-vals 'as val '}
		        'before failed-step 'to-make role 'of object 'become val) 
		  ':add-step-before-step)
		 ))
	    ))
    (if (null proposed-actions)
        (kanal-format-verbose stream "       -> no step addition applicable~%"))
    )
  )

(defun action-can-change-role-value-of-object (action object role)
  (let* ((concepts (get-concepts-from-instance object))
         (add-del-lists (compute-add-del-lists action))
         (add-list (first add-del-lists))
         ;;(del-list (second add-del-lists))
         )
    ;;(format t "~% FOR concepts:~S    affects: ~S~%" concepts affects)
    ;; consider added effects only for new action
    (can-change-role-value-of-object add-list concepts object role)
    ))



(defun step-can-change-role-value-of-object (action-instance object role)
  (let ((concepts (get-concepts-from-instance object))
        ;;(add-del-lists (union (get-the-add-list action-instance)
        ;;		      (get-the-del-list action-instance)))
        (add-list (get-the-add-list action-instance))
        )
    ;; consider added effects only for now
    (can-change-role-value-of-object add-list concepts object role)
    ))

;; returns the values of the effects that can chage the role value
(defun can-change-role-value-of-object (effects concepts object role)
  (let ((result nil))
    (dolist (effect effects)
      (let* ((affected-object (get-object effect))
	   (affected-role (get-role effect))
	   (affected-things (get-concepts-from-instance affected-object)))
        ;;(format t "affected thing:~S~%" affected-things)
        (if (and (equal-objects role affected-role)
	       (or (null object)
		 (null concepts);; invalid object description?
		 (intersection concepts
			     (union affected-things
				  (get-all-subconcepts affected-things)))))
	  (setq result (append result (list (list (get-val effect)))))))  )
    result))


(defun find-actions-that-can-change-role-value (object role)
  (find-actions-that-can-change-role-value-1 object role (get-concept-action)))

(defun find-actions-that-can-change-role-value-1 (object role concept)
  (let ((actions (get-subconcepts concept)) 
        (result nil))
    (dolist (action actions)
      (let ((values-of-effects (action-can-change-role-value-of-object action object role)))
        (if values-of-effects;; action can add the effect
	  (setq result (append result (list (list action values-of-effects))))
	(setq result (append result 
			 (find-actions-that-can-change-role-value-1 object role action))))))
    result
    ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Suggest to modify current steps that can achieve the effect
;;  1  Find current steps that can potentially achieve the effect
;;  2  Suggest to the user to modify the step

(defun suggest-to-modify-steps-that-can-achieve-the-effect (object role val failed-step
						       steps-before
						       &optional (stream *kanal-log-stream*))
  
  (kanal-format-verbose stream "~%     .. checking if steps can be modified .. ~%")
  (let ((affected-actions (find-current-steps-that-can-change-role-value 
		       object role steps-before)))
    (dolist (action-and-vals affected-actions)
	  (let* ((p-action (first action-and-vals))
	         (effect-vals (second action-and-vals))
	         (description-of-vals (make-sentence-for-vals effect-vals))
	         ;;(expected-val (make-sentence (pretty (evaluate-expr val))))
	         )
	    (cond ((null failed-step);; case of unachieved expected effect
		 (kanal-format-verbose stream " proposed fix : modify ~S step with ~S as ~S to change ~S of ~S~%"
				   p-action description-of-vals val role object)
		 (generate-fix-item (list 'modify p-action 'with description-of-vals 'as val 'to-make role 'of object 'become val) ':modify-step))
		(t;; case of unachieved precondition
		 (kanal-format-verbose stream " proposed fix : modify a ~S with ~S as ~S step before step ~S to change ~S of ~S~%"
				   p-action description-of-vals val failed-step role object)
		 (generate-fix-item (list 'modify p-action 'with description-of-vals 'as val 'before failed-step 'to-make role 'of object 'become val) 
				':modify-step) ))
	    ))
    (if (null affected-actions)
        (kanal-format-verbose stream "       -> no step modification applicable~%"))
    )
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Suggest that there are missing ordering constraints in the process model
;;  1  Find an action (or actions) that may have an effect
;;	(or effects) that undid the expected effect
;;     Find an action (or actions) that asserts the expected effect
;;  2  Suggest to the user to insert an ordering constraint
;;     in order to maintain the expected effect where needed
(defun suggest-to-change-ordering-between-steps (object role val failed-step
						 steps-before
						 &optional (stream *kanal-log-stream*))
  
  (kanal-format-verbose stream "~%     .. checking if ordering changes may fix the problem .. ")
  (let ((affected-actions (find-current-steps-that-undid-effect 
			   object role val steps-before)))
    (cond ((or (null affected-actions) (null (second affected-actions)))
	   (kanal-format-verbose stream "~%       -> no ordering change applicable~%"))
	  (t 
	   (kanal-format-verbose stream "~% proposed fix : check the ordering among these steps ")
	   (mapcar #'print-step affected-actions)
	   (kanal-format-verbose stream "~%  because they changed the value of ~S"  role)
	   (generate-fix-item (list 'change-or-add-link-between-steps affected-actions 'to-make role 'of object 'become val) 
			      ':change-or-add-link-between-steps)
	   ))
    )
  (kanal-format-verbose stream "~%")
  )

(defun find-current-steps-that-undid-effect (object role val steps-before) 
  (let ((result nil))
    (dolist (step steps-before)
      (if (step-undid-effect step object role val)
	  (setq result (append result (list step)))
	))
    result
    )
  )

(defun step-undid-effect (action-instance object role val)
  (let ((del-list (get-the-del-list action-instance))
	(result nil))
    ;(format t "~% del list of ~S:~S ~%" action-instance del-list)
    (dolist (affect del-list)
      (let* ((affected-object (second affect))
	     (affected-role (third affect))
	     (affected-thing (fourth affect)))
	(if (and (equal-objects role affected-role)
		 (equal-objects object affected-object)
		 (equal-objects val affected-thing))
	    (setq result 't))))
    result)
  )

(defun find-current-steps-that-can-change-role-value (object role steps-before)
  (let ((result nil))
    (dolist (step steps-before)
      (let ((values-of-effects (step-can-change-role-value-of-object step object role)))
	(if values-of-effects ;; step can add the effect
	    (setq result (append result (list (list step values-of-effects))))
	  )))
    result
    )
  )


(defun find-steps-before (step)
  (remove-duplicates (find-steps-before-1 (list step) nil))
  )
  
(defun find-steps-before-1 (current-steps current-result)
  (let ((result nil)
	(steps (set-difference current-steps current-result))) ;; to avoid loop
    (if (not (equal steps current-steps))
	(format t "~% steps : ~S ~S" steps current-steps)) ;; debugging
    (dolist (step steps)
      (let ((prev-events (find-prev-events step)))
	(setq result (append result prev-events))
	(setq result (append result
			      (find-steps-before-1 prev-events result)))
	))
    result)			    
  )

(defun add-failed-expr (kmexpr)
  (let ((subexpr-found nil))
    (dolist (expr *expressions-failed*)
      (cond ((or (equal expr kmexpr) ;; same expression
		 (member expr kmexpr :test #'equal))
	     (setq subexpr-found t))
	    ((equivalent-expr expr kmexpr) ;; equivalent
	     (setq subexpr-found expr))))
    (cond ((null subexpr-found)
	   (setq *expressions-failed*
		 (append *expressions-failed*
			 (list kmexpr))))
	  ((not (eq 't subexpr-found))  ;; found equivalent expression
	   (setq *expressions-failed*
		 (replace-element subexpr-found (more-complex subexpr-found kmexpr) 
				  *expressions-failed*))))
    )
  *expressions-failed*
  )

(defun equivalent-expr (kmexpr1 kmexpr2)
  (if (or (null kmexpr1) (null kmexpr2)) ;; either one of them are null
      (equal kmexpr1 kmexpr2)
    (let ((first1 (car kmexpr1))
	  (first2 (car kmexpr2)))
      (cond ((and (listp first1) (listp first2))
	     (and (equivalent-expr first1 first2)
		  (equivalent-expr (rest kmexpr1) (rest kmexpr2))))
	    ((and (atom first1) (atom first2))
	     (if (equal first1 first2)
		 (equivalent-expr (rest kmexpr1) (rest kmexpr2))
	       nil))
	    (t ;; either first1 or first2 is list
	     (and (equal-objects first1 first2)
		  (equivalent-expr (rest kmexpr1) (rest kmexpr2))))
	    )))
  )

;;; ======================================================================
;;;		Check Expected Effects
;;; ======================================================================

(defvar *all-expected-effects* nil)
(defvar *model-to-test*  nil)
(defvar *current-model-instance* nil)
(defvar *what-to-simulate* nil) ;; a substep of current model to be tested

(defun find-unachieved-expected-effects (process-model &optional (stream *kanal-log-stream*))
  (kanal-format stream "~%~%  ************************************************")
  (kanal-format stream "~%                check expected effects")
  (kanal-format stream "~%  ************************************************")
  (kanal-format stream "~%    we check each simulated path~%~%")
  (let ((effects-not-achieved-in-all-paths nil))
    (dolist (path *paths-simulated*)
      (let ((deleted-effects
	   (event-info-all-deleted-effects (first (last path))))
	  (added-effects
	   (event-info-all-added-effects (first (last path))))
	  (last-situation (get-next-situation (first (last path)))))
        (unless (and (null added-effects) (null deleted-effects))
	(kanal-format stream "~%  ------------------------------------------------")
	(kanal-format stream "~%    The overall effects for path")
	(kanal-format stream "~%        ~S" (mapcar #'get-event path))
	(kanal-format stream "~%  ------------------------------------------------")
	(kanal-format stream "~%   added:   ~%")
	(print-items-with-space 13 (mapcar #'first added-effects))
	(kanal-format stream "~%   deleted: ~%")
	(print-items-with-space 13 (mapcar #'first deleted-effects))
	
	(let ((expected-effects (find-expected-effects-for-model process-model))
	      (effects-not-achieved nil))
	  (cond ((null expected-effects)
	         (kanal-format stream "~%  .............................................")
	         (kanal-format stream "~% The expected effects for ~a is not specified yet!~%" process-model))
	        (t
	         (kanal-format stream "~%  These are expected results of a ~S~%" process-model)
	         (kanal-format stream "  (We assume that the user entered these using the Dialog Window)~%")
	         ;;(mapcar #'print-description expected-effects)
	         (make-sentence expected-effects)
	         (kanal-format stream "~%  .............................................")
	         (kanal-format stream "~%                  results")
	         (kanal-format stream "~%  .............................................~%")
	         (dolist (effect expected-effects)
		 (collect-failed-exprs-on)
		 (cond ((test-expr effect last-situation)
		        (kanal-format stream "~% ~S" effect)
		        (kanal-format stream "      -> the effect is achieved!~%")
		        (collect-failed-exprs-off)
		        ;;(kanal-format stream "~%failed expressions ~S~%" *expressions-failed*)
		        (generate-error-checker-item (list effect)
					       ':expected-effect ':error 't process-model)
		        )
		       ((invalid-triple effect :expected-effect process-model stream)
		        t)
		       (t
		        (kanal-format stream "~% ~S" effect)
		        (kanal-format stream "      => the effect is NOT achieved <=~%")
		        (generate-error-checker-item (list effect)
					       ':expected-effect ':error nil process-model)
		        (collect-failed-exprs-off)
		        ;;(propose-fixes-for-unachieved-effects)
		        ;;(setq effects-not-achieved
		        ;;(append effects-not-achieved (list (list effect *expressions-failed*))))
		        (setq effects-not-achieved
			    (append effects-not-achieved (list effect)))
		        )
		       )
		       )
	         (cond ((null effects-not-achieved)
		      (kanal-format stream "~% ALL THE EXPECTED EFFECTS ARE ACHIEVED!~%")
		      ;;(generate-error-checker-item expected-effects
		      ;;			     ':expected-effect ':error 't process-model)
		      nil)
		     (t
		      (setq effects-not-achieved-in-all-paths
			  (union effects-not-achieved-in-all-paths
			         effects-not-achieved))
			
		      effects-not-achieved)))
	        )
	  ))))
    effects-not-achieved-in-all-paths
    ))
	

(defun invalid-triple (triple type event &optional (stream *kanal-log-stream*))
  (let* ((object (get-object triple)) 
	 (role (get-role triple))
	 (object-val (evaluate-expr object))
	 (role-val (evaluate-expr role)))
    (cond ((and object-val role-val)
	   nil)
	  ((and (null object-val) (null role-val))
	   (generate-error-checker-item `(OBJECT-FIELD - ,object  and ROLE-FIELD - ,role  of ,triple) :invalid-expr ':error nil (list type event))
	   (kanal-format stream "~% ERROR: the object and role field of ~S is null~%" triple)
	   t)
	  ((null object-val)
	   (generate-error-checker-item `(OBJECT-FIELD - ,object of ,triple) :invalid-expr ':error nil (list type event))
	   (kanal-format stream "~% ERROR: the object field of ~S is null~%" triple)
	   t
	   )
	  (t
	   (generate-error-checker-item `(ROLE-FIELD - ,role of ,triple) :invalid-expr ':error nil (list type event))
	   (kanal-format stream "~% ERROR: the role field of ~S is null~%" triple)
	   t)))
	  
  )

(defun effect-equivalent (effect1 effect2)
  (let ((object1 (second effect1))
	(role-name1 (third effect1))
	(value1 (fourth effect1))
	(object2 (second effect2))
	(role-name2 (third effect2))
	(value2 (fourth effect2))
	)
    ;;(format t "~%(~S ~S ~S) vs (~S ~S ~S)" object1 role-name1 value1 object2 role-name2 value2)
    (or 
     (and (equal-objects role-name2 (get-inverse role-name1))
	  (equal-objects value1 object2)
	  (equal-objects value2 object1))
     (and (equal-objects role-name2 role-name1)
	  (equal-objects object1 object2)
	  (equal-objects value1 value2)))
    ))
	
(defun find-expected-effects-for-model (model)
  (if (equal *interaction-mode* 'use-interaction-plan)
      (cdr (assoc model *all-expected-effects*))
    (get-expected-effects-for-model model))
  )

;;; ======================================================================
;;;		Find loops
;;; ======================================================================

;;; find loops
(defun loop-found (event path &optional (stream *kanal-log-stream*))
  (let ((sequence-after-event (member event (mapcar #'get-event path))))
    (cond (sequence-after-event 
	   (kanal-format stream "~%~% WARNING (loop found): This path already have the event ~S" event)
	   (kanal-format stream "~%     ~S" (mapcar #'get-event path))
	   (kanal-format stream "~%   Loop in the path:")
	   (kanal-format stream "~%      ~S" (append sequence-after-event (list event)))
	   (setq *loops-found* (append *loops-found*
				       (list (append sequence-after-event (list event)))))
	   t)
	  (t nil)
	  ))
  )
(defun report-loops (&optional (stream *kanal-log-stream*))
  (when *paths-simulated*
  (kanal-format stream "~%~%  ************************************************")
  (kanal-format stream "~%          Summary of Loops Found")
  (kanal-format stream "~%  ************************************************")
  (cond ((null *loops-found*)
	 (generate-error-checker-item nil
				      ':loop
				      ':warning
				      't
				      *model-to-test*)
	 (kanal-format stream "~%       -->  NO LOOP FOUND! ~%"))
	(t (generate-error-checker-item *loops-found*
					':loop
					':warning
					nil
					*model-to-test*)
	   (mapcar #'(lambda (loop)
		       (kanal-format stream "~%   ~S" (mapcar #'get-concept-name loop)))
		   *loops-found*)
	   (kanal-format stream "~%")
	   ))
  ))

(defun initialize-test-options ()
  )
;;; ======================================================================
;;;		Error Checker Items, Info Items and Fix Items
;;; ======================================================================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; a list of error items where each error-item has
;; 1) ID 
;; 2) constraint:  KM expression
;; 3) type: one of :precondition :expected-effect :loop :redundant-sequence, ...
;;          (replace :ordering and :causal-link by function calls to the 
;;           Process and Simulation Handler, like get-causal-links(),
;; 	  find-next-events (event), get-simulated-paths (), ...)
;; 4) level: :error or :warning
;; 5) success: yes or no  ;;;; yes means that the KM expression was satisfied
;; 6) source: step or component
(defvar *error-checker-items* nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; [info item] 
;; 1) ID 
;; 2) type: one of :simulated-paths :causal-links etc.
;; 3) content: list of paths in :simulated-paths case
;;             list of causal links in :causal-link case where each causal link
;;                has (enabling event, enabled event, precondition)
;; 4) source: concept/process-model
(defvar *info-items* nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; a list of fix-items where each fix-item has
;; 1) fix: fix instruction
;; 2) type: one of :add-step :add-step-before-step :modify-step :delete-or-modify-step
;;		:change-ordering, ..
(defvar *fix-items* nil)

(defun init-test ()
  (setq *error-checker-items* nil)
  (setq *info-items* nil)
  )

(defun find-error-item (error-id)
  (find-error-item-1 error-id *error-checker-items*))

(defun find-error-item-1 (error-id error-items)
  (assert error-items (error-id) "The error id ~A was not found" 
error-id)
  (if (equal (cdr (assoc 'id (first error-items)))
	     error-id)
      (first error-items)
    (find-error-item-1 error-id (rest error-items))))


(defun find-fixes-for-failed-precondition (triple failed-step &optional (stream *kanal-log-stream*))
  (let ((object (second triple))
	(role (third triple))
	(val (fourth triple))
	(steps-before-failed-step (find-steps-before failed-step)))
    
    (kanal-format-verbose stream "~% ..............................................................")
    (kanal-format-verbose stream "~%   checking how to change ~S value of ~S .. " role object)
    (kanal-format-verbose stream "~% ..............................................................~%")
    
    ;; 1. Suggest that there are missing steps in the process model
    (suggest-to-add-steps-that-can-achieve-the-effect object role val failed-step)
    ;; 2. Suggest to modify current steps in the process model
    (suggest-to-modify-steps-that-can-achieve-the-effect object role val 
							 failed-step
							 steps-before-failed-step)
    ;; 3. Suggest that there are missing ordering constraints
    (suggest-to-change-ordering-between-steps object role val 
					      failed-step
					      steps-before-failed-step)
    ;; 4. Suggest to delete the step whose preconditions were not achieved	     		       
    (kanal-format-verbose stream "~% ..............................................................")
    (kanal-format-verbose stream "~%   checking if there are unnecessary steps .. ~%")
    (kanal-format-verbose stream " ..............................................................~%")
    (kanal-format-verbose stream "~% proposed fix :  delete or modify ~S~%"  failed-step)
    (generate-fix-item (list 'delete-or-modify failed-step) ':delete-or-modify-step)
    )
  )

(defun find-fixes-for-unachieved-effect (triple &optional (stream *kanal-log-stream*))
  (let ((object (second triple))
	(role (third triple))
	(val (fourth triple))
	(steps-before
	 (cond ((equal *execution-mode* 'primitive-steps-only)
		(find-last-primitive-events *current-model-instance*))
	       (t
		(find-prev-events-including-children *current-model-instance*))
	       )))
    (setq steps-before
      (remove-duplicates (append steps-before
				 (find-steps-before-1 steps-before nil))))
    
    (kanal-format-verbose stream "~% ..............................................................")
    (kanal-format-verbose stream "~%   checking how to change ~S value of ~S .. " role object)
    (kanal-format-verbose stream "~% ..............................................................~%")
    
    ;; 1. Suggest that there are missing steps in the process model
    (suggest-to-add-steps-that-can-achieve-the-effect object role val nil steps-before)
    ;; 2. Suggest to modify current steps in the process model
    (suggest-to-modify-steps-that-can-achieve-the-effect object role val nil steps-before)
    ;; 3. Suggest that there are missing ordering constraints
    (suggest-to-change-ordering-between-steps object role val nil steps-before)

  ))

(defun find-fixes-for-undoable-event (event)
  (generate-fix-item (list 'change-or-add-link-between-steps-for-undoable-event event) ':change-or-add-link-between-steps)
  )


(defun find-fixes-for-delete-error (constraint event)
  (generate-fix-item (list 'modify event 'to-delete-other-than constraint) ':modify-step)
  (generate-fix-item (list 'modify-events-before event 'to-assert constraint) ':modify-steps)
  )

(defun find-fixes-for-unreached-events (events path)
  (generate-fix-item (list 'change-or-add-link-between-steps-for-unreached-events events) ':change-or-add-link-between-steps)
  
  )

(defun find-fixes-for-effectless-event (event)
  (generate-fix-item (list 'modify event 'to-achieve-something) ':modify-step)
  
  )

(defun find-fixes-for-invalid-expr (expr source)
  (generate-fix-item (list 'modify-expr expr 'in (first source) 'of (second source)) ':modify-step)
  
  )

(defun find-fixes-for-not-exist (expr source)
  (generate-fix-item (list 'add expr 'as (first source) 'of (second source)) ':add-expr)
  )

(defun find-fixes-for-loop (expr source)
  (generate-fix-item (list 'delete-or-modify 'ordering 'constraints 'in 'loops expr) ':delete-or-modify-link)
  )

(defun find-fixes-for-unnecessary-link (role-desc source)
  (generate-fix-item (list 'delete-or-modify role-desc 'constraints 'in source) ':delete-or-modify-link)
  )

(defun find-fixes-for-missing-link (role-desc event)
  (generate-fix-item (list 'add role-desc 'constraint 'for event) ':add-link)
  )

(defun create-fix-item (fix type)
  (let ((fix-item nil))
    (setq fix-item (acons 'fix fix fix-item))
    (setq fix-item (acons 'type type fix-item))
    fix-item
    )
)

(defun generate-fix-item (fix type)
  (let ((fix-item (create-fix-item fix type)))
    (setq *fix-items* (append *fix-items* (list fix-item)))))

(defun get-field (key item)
  (cdr (assoc key item)))
		   
(defun error-type-is (item type)
  (equal (cdr (assoc 'type item)) type))

(defun create-error-item (exprs type level success source)
  (let ((new-id (gentemp "error-item-"))
	(error-item nil))
    (setq error-item (acons 'id new-id error-item))
    (setq error-item (acons 'constraint exprs error-item))
    (setq error-item (acons 'type type error-item))
    (setq error-item (acons 'level level error-item))
    (setq error-item (acons 'success success error-item))
    (setq error-item (acons 'source source error-item))
    error-item)
  )

(defun generate-error-checker-item (exprs type level success source)
  (let ((new-item (create-error-item exprs type level success source)))
    (if (not (member new-item *error-checker-items* :test #'equal-error-item)) 
	(setq *error-checker-items*
	  (append *error-checker-items*
		  (list (create-error-item exprs type level success source)))))
  *error-checker-items*
  ))

(defun equal-error-item (err-item1 err-item2)
  (and (equal (assoc 'type err-item1) (assoc 'type err-item2))
       (equal (assoc 'constraint err-item1) (assoc 'constraint err-item2))
       (equal (assoc 'source err-item1) (assoc 'source err-item2))
       ))
(defun create-info-item (type content source)
  (let ((new-id (gentemp "info-item-"))
	(info-item nil))
    (setq info-item (acons 'id new-id info-item))
    (setq info-item (acons 'type type info-item))
    (setq info-item (acons 'content content info-item))
    (setq info-item (acons 'source source info-item))
    info-item)
  )
(defun generate-info-item (type content source)
  (setq *info-items*
	(append *info-items*
		(list (create-info-item type content source))))
  *info-items*
  )

(defun show-all-error-checker-items-and-fixes (&optional (stream *kanal-log-stream*))
  (kanal-format stream "~%======================")
  (kanal-format stream "~% Error Checker Items~%")
  (kanal-format stream "======================~%")
  (let ((there-are-failed-events nil)
        (there-are-unreached-events nil))
    ;; checking interrelationships
    #|
    (dolist (item *error-checker-items*)
      (when (null (cdr (assoc 'success item)))
	(if (or (equal (cdr (assoc 'type item)) ':precondition)
		(equal (cdr (assoc 'type item)) ':undoable-event))
	    (setq there-are-failed-events 't))
	(if (equal (cdr (assoc 'type item)) ':unreached-events)
	    (setq there-are-unreached-events 't))))
    (kanal-format stream "~% there-are-failed-events: ~S~%" there-are-failed-events)
    (kanal-format stream "~% there-are-unreached-events: ~S~%" there-are-unreached-events
    |#
    (dolist (item *error-checker-items*)
	  (kanal-format stream "~%~S ~%" item)
	  (when (null (cdr (assoc 'success item)))
	        (if (not (or (and there-are-failed-events
			      (error-type-is item ':unreached-events))
			 (and there-are-unreached-events
			      (error-type-is item ':expected-effect))))
		  (kanal-format stream "==> fixes ~S ~%" 
			      (get-proposed-fixes (cdr (assoc 'id item)))))))
    )
  
  (kanal-format stream "~%~%======================")
  (kanal-format stream "~% Info Items~%")
  (kanal-format stream "======================~%")
  (kanal-format stream "~S ~%" *info-items* )
  
  )


;;; ======================================================================
;;;		utilities 
;;; ======================================================================
;
(defvar *kanal-silent* nil) ;; make kanal silent
(defvar *kanal-verbose* nil) ;; make kanal verbose than usual

;; this can be used to control the level of details printed 
(defun kanal-format-verbose (stream string &rest args)
  (when (and (not *kanal-silent*) *kanal-verbose*)
    (apply #'format (cons *kanal-log-stream* ;; use *kanal-log-stream* instead of stream
			  (cons string args)))))

(defun kanal-format (stream string &rest args)
  (when (not *kanal-silent*)
    (apply #'format (cons *kanal-log-stream* ;; use *kanal-log-stream* instead of stream
			  (cons string args)))))

(defun get-time-in-string ()
  (multiple-value-bind
   (s m h d mo y) (get-decoded-time)
   (format nil "~d/~d/~d  ~d:~d:~d" y mo d h m s)))

(defun flatten (lis)
  (cond ((null lis) nil)
        ((atom (car lis)) (cons (car lis) (flatten (cdr lis))))
        (t (append (flatten (car lis)) (flatten (cdr lis))))))
 
(defun more-complex (obj1 obj2)
  (let ((fobj1 (flatten obj1))
	(fobj2 (flatten obj2)))
    (if (> (length fobj1) (length fobj2))
	obj1
      obj2)))

(defun replace-element (from to list)
  (if (equal from to)
      list
    (let ((result nil))
      (dolist (item list)
	(if (equal item from)
	    (setq result (append result (list to)))
	  (setq result (append result (list item)))))
      result
      )
    )
  )


(defun print-description (effect &optional (stream *kanal-log-stream*))
  (kanal-format stream "~%  ")
  (kanal-format stream (first effect)))


(defun print-step (step &optional (stream *kanal-log-stream*))
  (kanal-format stream "~%  action ~S" step)
  )


(defun print-indent (level stream)
  (do ((i 0 (1+ i)))
      ((= i level))
    (kanal-format stream " ")))

(defun print-items-with-space (nspace items &optional (stream *kanal-log-stream*))
  (dolist (item items)
    (print-indent nspace stream)
    (kanal-format stream "~S~%" item))
  )


;;; ======================================================================
;;;		API to KM
;;; ======================================================================

;; km calls from KANAL go through these two functions
(defun km-k (arg)
  (km arg :fail-mode #$'fail))

(defun km-unique-k (arg)
  (km-unique arg :fail-mode #$'fail))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; concepts/roles/instances
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun create-instance (concept &optional (situation nil))
  (if situation
      (km-unique-k `(#$in-situation ,situation (#$a ,concept)))
    (km-unique-k `(#$a ,concept))))

(defun get-role-values (instance role)
  (km-k `(#$the ,role #$of ,instance)))

(defun assert-role-value (instance role val)
  (km-k `(,instance #$has (,role (,val)))))

;; to prevent unification
(defun assert-another-role-value (instance role val)
  (km-k `(,instance #$also-has (,role (,val)))))

(defun get-concepts-from-instance (instance)
  (km-k `(#$the #$instance-of #$of ,instance)))

(defun get-concept-from-instance (instance)
  (km-unique-k `(#$the #$instance-of #$of ,instance)))

(defun get-subconcepts (concept)
  (km-k `(#$the #$subclasses #$of ,concept))
  )

(defun get-concept-name (step)
  (get-concept-from-instance step))

(defun get-all-subconcepts (concepts)
  (km-k `(#$the #$all-subclasses #$of ,concepts)))

(defun get-inverse (role)
  (km-k `(#$the #$inverse #$of ,role)))

(defun create-a-thing ()
  (create-instance '#$Thing))

(defun get-role-description (obj role)
  (or (caar (inherited-rule-sets obj role))
      (caar (own-rule-sets obj role)))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; to handle situation
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun goto (situation)
  (km-k `(#$in-situation ,situation)))

(defun goto-global-situation ()
  (global-situation)) 

(defun create-situation ()
  (create-instance '#$Situation))

(defun current-situation ()
  (km-unique-k '#$(curr-situation)))

(defun previous-situation (situation)
  (km-k `(#$the #$prev-situation #$of ,situation)))

(defun get-after-situation (event)
  (km-k `(#$the #$after-situation #$of ,event)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  expressions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun equal-objects (obj1 obj2)
  (km-k `(,obj1 #$= ,obj2)))

(defun test-expr (expr &optional (situation nil))  ;; test a triple
  (if situation 
      (km-k `(#$in-situation ,situation (#$is-true ,expr)))
    (km-k `(#$is-true ,expr))))

(defun evaluate-expr (expr)
  (km-k `(,expr)))

(defun has-value (result)
  (km-k `(#$has-value , result)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; preconditions & effects
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun get-preconditions (event)
  (remove-duplicates (km-k `(#$the #$pcs-list #$of ,event)) :test #'equal)
  )

(defun get-the-add-list (action-instance)
  (get-role-values action-instance '#$add-list))

(defun get-the-del-list (action-instance)
  (get-role-values action-instance '#$del-list))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; km dependent
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun get-primary-roles (action)  
  ;; needed for building action table
  (km-k `(#$the #$primary-slot #$of ,action)))

(defun get-required-roles (action)  
  ;; needed for building action table
  (km-k `(#$the #$required-slot #$of ,action)))

(defun get-all-actions ()
  (km-k `#$(the all-subclasses of Action)))


(defun get-concept-action ()
  (km-k `#$(Action))  )

(defun check-object (obj)
  (km-k `(#$showme ,obj))) 

(defun print-concept (concept &optional (stream *kanal-log-stream*))
  (princ (write-frame concept) stream)
  )

(defun find-symbol-in-kb (symbol-name)
  (find-symbol symbol-name (find-package *km-package*))
  ;(find-symbol symbol-name (find-package :user))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; to handle triples 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun get-object (triple)
  (second triple))

(defun get-role (triple)
  (third triple))

(defun get-val (triple)
  (fourth triple))

(defun get-triple-values (triples)
  (mapcar #'(lambda (triple) 
	      (list (first triple)
		    (km-unique-k (get-object triple))
		    (km-unique-k (get-role triple))
		    (km-unique-k (get-val triple))))
	  triples))

;;; Changed with to #$with so the km query could be recognised - Jim 5/22/01.
(defun triple-consistent-with-kb (triple &optional (situation nil))
  (let ((obj (get-object triple))
        (role (get-role triple))
        (val (get-val triple)))
    (if situation 
        (km-k `(#$in-situation ,situation ((#$a #$Thing #$with (,role (,val))) #$&? ,obj)))
      (km-k `((#$a #$Thing #$with (,role (,val))) #$&? ,obj)))
    ))

(defun assert-triple (triple &optional (situation nil))
  (let ((obj (get-object triple))
	(role (get-role triple))
	(val (get-val triple)))
    (if situation 
      (km-k `(#$in-situation ,situation ((#$a #$Thing #$with (,role (,val))) #$& ,obj)))
    (km-k `((#$a #$Thing #$with (,role (,val))) #$& ,obj)))
    ))

(defun make-sentence-for-triple (triple)
  (let ((obj (get-object triple))
	(role (get-role triple))
	(val (get-val triple)))
    (make-sentence `((#$the ,role #$of ,obj)  is ,val))
    ))

(defun make-sentence-for-vals (vals)
  (let ((result (make-phrase (first vals))))
    (if (second vals)
	(dolist (val (rest vals))
	  (setq result (format nil "~A OR ~A" result (make-phrase val)))))
    result))

;;; ======================================================================
;;;		API to Shaken
;;; ======================================================================

(defvar *kanal-log-stream* nil)
(defvar *test-with-closed-world-assumption* t)

(defun init-kanal ()
  (setq *kanal-log-stream* (make-string-output-stream)) 
  ;(setq *kanal-log-stream* *trace-output*)
  (build-action-table))

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

;;; I find this a useful entry function. Jim

(defun test-to-file (concept file)
  (with-open-file (*kanal-log-stream* file :direction :output
			        :if-exists :rename-and-delete)
	        (test-knowledge concept)))



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

;;; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;;; Jerome: please delete these and replace with Shaken functions!!!!!!!
;;; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

(setq *all-expected-effects*
  '#$(
      (|Virus-Invades-Cell|
       .
       (
	(:triple (the Viral-Nucleic-Acid has-part of (the Virus agent of (thelast Virus-Invades-Cell)))
		 location
		 (the location of (the Cytoplasm has-part of 
				(the Cell object of (thelast Virus-Invades-Cell)))))
	
	)
       )
      (|Virus-Invades-Cell-trial|
       .
       (
	(:triple (the Viral-Nucleic-Acid has-part of (the Virus agent of (thelast Virus-Invades-Cell-trial)))
		 location
		 (the location of (the Cytoplasm has-part of 
				(the Cell object of (thelast Virus-Invades-Cell-trial)))))
	
	)
       )
      )
  )
(defun get-expected-effects-for-model (model)
  (cdr (assoc model *all-expected-effects*))
  )
