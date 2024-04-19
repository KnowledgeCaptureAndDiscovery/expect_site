
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

get-expected-effects-for-model (model-instance)
 return value: nil or km expr

get-expected-effects-for-event (model-instance step)
 return value: nil or km expr

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
                :soft-precondition
                  Failure to meet "soft preconditions" does not terminate simulation.
                :inexplicit-soft-precondition
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
5) reason: why

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
	  USER::*reserved-keywords*
	  USER::inherited-rule-sets
	  USER::own-rule-sets
	  USER::*error-report-silent* 
	  USER::*trace-log*
	  USER::*trace-log-on*
	  USER::make-sentence
	  USER::make-phrase
	  USER::global-situation
	  USER::*global-situation*
	  USER::all-situations
	  USER::write-frame
	  USER::get-slotsvals
	  USER::own-properties
	  USER::member-properties
;;	  USER::pretty
;;	  shaken::get-expected-effects-for-model
	  ) )

(defvar *expressions-failed* nil)
(defvar *in-k-analysis* nil)

;; value can be no-interaction or use-interaction-plan
(defvar *interaction-mode* 'use-interaction-plan) 

;; value can be 'primitive-steps-only or 'all-steps
(defvar *execution-mode* 'primitive-steps-only)

(defvar *initial-state-specified* nil)

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

(defvar *simulation-mode* 'sadl)
(defvar *all-executable-events* nil) ;; store events for efficiency

(defun simulate-steps-and-find-failed-events (model-instance start-situation)
  (setq *simulation-mode* 'sadl)
  (setq *failed-event-info* nil)
  (setq *next-event-exprs* nil)
  (goto start-situation)
  ;(get-events-to-be-removed *current-model-instance*)
  (when (init-km) 
    (collect-all-temporal-info)
    (generate-subevent-info-item)
    (if (equal  *simulation-mode* 'sadl)
	(simulate-steps-with-sadl
	 (find-first-primitive-events model-instance)
	 start-situation)
      (simulate-events (find-first-primitive-events model-instance)
		       start-situation))
    *failed-event-info*
    )
  )

;; needed to retrieve right prev-event vals
;; because of incompleteness in KM's reasoning
(defun init-km()
  (cond ((equal (setq *all-executable-events* (get-all-executable-events))
		'fail)
	 nil)
	(t
	 (mapcar #'get-next-events *all-executable-events*)
	 (mapcar #'get-subevents (append *all-executable-events* (list *current-model-instance*))))
	)
  )

(defun document-kanal()
  (kanal-html-format "<h1>Test Knowledge</h1><hr><ul><br>~%" )
  (kanal-html-format "<font color=\"green\">SHAKEN simulates your process model and checks several things:<p>
<li>Check what happens before and after each step (the conditions and effects
of each step) by running a simulation
<br>e.g.: before executing Attach, check if virus is located near the cell
<br>   after Breach the plasma membrane of the cell is broken
<li>Check that all the overall <b>expected effects</b> (specified by you) are obtained
<br>e.g.: after virus-invade-cell, viral-nucleic-acid is located in the
cytoplasm
<li>Check correctness of <b>assumptions</b> (especially initial conditions)
<br>e.g., no location was specified for the virus, I'll assume it is next to the
cell
<li>Check combinations of substeps (execution paths) that are possible
<li>Check steps that are never reached during simulation
<li>Check how each step enables other steps to take place
<li>Check if there are loops

<hr>

For each of these checks, SHAKEN will report
<li>checks and assumptions that seemed ok
<li>errors,i.e., serious problems that you should fix.</font>
 <font color=\"red\"> Errors are shown in <b>Red</b></font><font color=\"green\">.
<li>warnings/notes, i., e., things it wants you to take a look at so you decide
for yourself whether there is a problem or not). </font><font color=\"orange\">Warnings and notes are
shown in <b>Orange</b></font><font color=\"green\">.
<p>
For each error or warning, you can ask SHAKEN to show you a list of
suggestions for how to fix them.  You can pick one of these suggested fixes,
or you can decide to fix the problem in a different way.  SHAKEN will take
you to the knowledge editor window in either case.</font><hr>
" )
  )

(defun init-test-process-model (process-model)
  (K-analysis-on)
  (cond (*current-model-instance*
	 (list *current-model-instance* *start-situation*))
	(t
	 (goto-global-situation)
	 (let* ((start-situation (create-situation))
		(model-instance  (create-instance process-model start-situation)))
	   ;;(add-ordering-info model-instance) ; for the old component library
	   (setq *current-model-instance* model-instance)
	   (list model-instance start-situation))))
  )

(defun test-process-model ()
  (let* ((process-model *model-to-test*)
         (model-instance&start-situation (init-test-process-model process-model))
         (model-instance (first model-instance&start-situation))
         (start-situation (second model-instance&start-situation))
         (test-instance model-instance ;; test the whole model for now
			;(if (equal *interaction-mode* 'use-interaction-plan)
			;    (choose-substep process-model model-instance start-situation)
			;  model-instance)
			))
    (when test-instance
      (kanal-format "~%~% ===============================================")
      (kanal-format "~% Start testing ~S with ~%   ~S in ~S~%"
		    process-model model-instance start-situation)
      (kanal-html-format "<h1>Knowledge Analysis for ~A</h1> <p>Analysis performed at ~A</p><hr><ul>~%"
			      process-model (get-time-in-string))
      (document-kanal)
      ;(get-missing-links test-instance)

      ;; use expected effects from previous run unless this is with a new instance
      ;(if (and *old-model-instance* (not (equal *old-model-instance* *current-model-instance*)))
      ;    (setq *kanal-expected-effects* nil))
      (setq *old-model-instance* *current-model-instance*)
      
      (let ((failed-event-info (simulate-steps-and-find-failed-events
				test-instance start-situation)))
	(kanal-html-format "~%</ul>~%")
	(format t ">reporting simulated paths~%")
	(report-simulated-paths)
	(format t "<done reporting paths~%")
	(cond ((null failed-event-info);; no failed events
	       (find-unachieved-expected-effects process-model)
	       (format t "<done finding unachieved exp.effs~%")
	       )
	      (t nil))
	(format t ">reporting causal links and loops~%")
	(report-causal-links)
	(format t "<done reporting causal links~%")
	(report-loops)
	(format t "<done reporting loops~%")
	))
    (K-analysis-off))
    (format t "<done testing process model~%")
  )

(defun is-a-type (instance superclass)
    (let ((conceptlist (get-role-values-with-checking "instance-of" instance nil))
          (returnval nil))
          ;(format t "Checking conceptlist ~S~%" conceptlist)
	  (dolist (concept conceptlist)
                  (if (subconcept? concept superclass) 
		      (setq returnval t)))
	  returnval
     )
)

(defun is-a-place (instance)
    (let ((conceptlist (get-role-values-with-checking "instance-of" instance nil))
          (returnval nil))
          ;(format t "Checking conceptlist ~S~%" conceptlist)
	  (dolist (concept conceptlist)
                  (if (subconcept? concept '#$Terrain)
		      (setq returnval t)))
	  returnval
     )
)

(defun military-unit-p (instance)
    (let ((conceptlist (get-role-values-with-checking "instance-of" instance nil))
          (returnval nil))
          ;(format t "Checking conceptlist ~S~%" conceptlist)
	  (dolist (concept conceptlist)
                  (if (subconcept? concept '#$Military-Unit)
		      (setq returnval t)))
	  returnval
     )
)

(defun check-if-action (instance)
    (let ((conceptlist (get-role-values-with-checking "instance-of" instance nil))
          (returnval nil))
          ;(format t "Checking conceptlist ~S~%" conceptlist)
	  (dolist (concept conceptlist)
                  (if (subconcept? concept '#$Action)
		      (setq returnval t)))
	  returnval
     )
)

(defun get-missing-links (instance)
   (let* ((participants (get-role-values-with-checking "participants" instance nil))
          (events (remove-if-not #'check-if-action participants))
	  (missing-links nil))
      (dolist (event events)
	  (if (and (null (test-expr `(#$:triple ,event #$subevent-of ,instance)))
	           (not (equal event instance)))
	       (setq missing-links (append missing-links (list event)))))
      (if missing-links
          (generate-error-checker-item missing-links
			':missing-link
			':warning nil
			*model-to-test*)))
)

;(defun get-missing-links (instance)
;   (let* ((participants (get-role-values-with-checking "participants" instance nil))
;          (events (remove-if-not #'check-if-action participants)))
;   (format t "Events : ~S~%" events)
;   )
;)


;;; ======================================================================
;;;		Propose Fixes
;;; ======================================================================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; this table stores effects of all the actions.
;;; the table is used in finding the actions that
;;;  can affect role values of an object

(defvar *action-effect-table* nil)
(defvar *state-effect-table* nil)
(defun build-action-table ()
  (setq *action-effect-table* nil)
  
  (if *trace* (untracekm))
  (setq *error-report-silent* t)

  (let ((new-situation (create-situation)))
    (goto new-situation)
  (dolist (action (get-all-core-actions))
    (let ((action-instance (create-instance action))
	  (primary-roles (get-primary-roles action))
	  (effects nil))
      ;; create instances for the primary roles and then 
      ;;  compute the effects based on them
      (dolist (role primary-roles)
	(if (null (get-role-values action-instance role))
	    (assert-role-value action-instance role (create-a-thing))))

      ;; make the preconditions as true
      (dolist (pc (get-preconditions action-instance))
	(if (null (test-expr pc))
	    (assert-triple pc)))
      
      ;; note: a hack to handle KM's State' components
      ;(check-resulting-states action-instance)
      (setq effects (list (generalize-effect-list
			   (get-assertions action-instance))
			  (generalize-effect-list
			   (get-deletions action-instance))))
      (push (list action effects) *action-effect-table*)
      ;(format t "~% effects: ~S" effects)
      ;(format t "~% table: ~S" *action-effect-table*)
      )))
  (setq *error-report-silent* nil)
  (kanal-format "~% action-effect-table:~% ~S~%" *action-effect-table*)
  *action-effect-table*
  )

(defun build-state-table ()
  (setq *state-effect-table* nil)
  (dolist (state (get-all-states))
    (push (list state (get-role-values state '#$caused-by-class)
		(get-role-values state '#$defeated-by-class))
	  *state-effect-table*))
  *state-effect-table*
  )



(defun generalize-effect-list (triples)
  (mapcar #'(lambda (triple)
	      (let* ((affected-object (get-object triple))
		     (affected-things (get-concepts-from-instance affected-object)))
		
		
		  (list (first triple)
			affected-things
			(get-role triple)
			(get-val triple))))
	  triples))

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
    (list (generalize-effect-list
	   (get-assertions action-instance))
	(generalize-effect-list
	 (get-deletions action-instance)))
    ))

#|
;; check if there are defined effects of the action type in the component lib
(defun check-if-there-are-defined-effects (action)
  (let ((found (assoc action *action-effect-table*))
	(effects nil))
    (if found
	(seq effects (second found))
      (setq effects (compute-add-del-lists-1 action)))
    (if (and (null (first effects)) (null (second effects)))
	nil
      t)))
|#
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
(defun suggest-to-add-steps-that-can-achieve-the-effect (object role val failed-step)
  
  (kanal-html-format-verbose "<br> ..............................................................~%")
  (kanal-format-verbose "~%     .. checking if there are missing steps .. ~%")
  (kanal-html-format-verbose "<br> ..checking if there are missing steps .. ~%")
  (if (complex-type val)
      (suggest-to-add-steps-that-can-achieve-the-state object role val failed-step))
  (if (not (state-test val))
      (suggest-to-add-steps-that-can-change-role-value object role val failed-step))
  )
  

(defun suggest-to-add-steps-that-can-achieve-the-state (object role val failed-step)
  (let ((proposed-actions nil))
    (cond ((mustnt-be-type val)
	   (setq proposed-actions (find-actions-that-can-delete-state val))
	   )
	  ((or (must-be-type val) (be-type val))
	   (setq proposed-actions (find-actions-that-can-assert-state val))
	   )
	  )
    (dolist (action proposed-actions)
      (kanal-format-verbose
       " proposed fix : add a ~S step before step ~S to change ~S of ~S~%" action failed-step role object)
      (kanal-html-format-verbose
       "<br> <font color=\"blue\">proposed fix</font> : add a ~S step before step ~S to change ~S of ~S~%"
       action failed-step role object)
      (generate-fix-item
       (list 'add action 'before failed-step 'to-make role 'of object 'become val) 
       ':add-step-before-step)
      )
    (when (null proposed-actions) 
      (kanal-format-verbose "       -> no step addition to change state applicable~%")
      (kanal-html-format-verbose  "<br>       -> no step addition to change state applicable~%<br>")
      )
    ))
  

(defun suggest-to-add-steps-that-can-change-role-value (object role val failed-step)
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
		  " proposed fix : add a ~S step with ~S as ~S to change the ~S of ~S~%"
		  p-action description-of-vals val role object)
		 (kanal-html-format-verbose
		  " <br><font color=\"blue\">proposed fix<font> : add a ~S step with ~S as ~S to change the ~S of ~S~%"
		  p-action description-of-vals val role object)
		 (generate-fix-item
		  (list 'add p-action '{with description-of-vals 'as val '} 'to-make role 'of object 'become val) 
		  ':add-step)
		 )
		(t;; case of unachieved precondition
		 (kanal-format-verbose
		  " proposed fix : add a ~S step with ~S as ~S before step ~S to change ~S of ~S~%"
		  p-action description-of-vals val failed-step role object)
		 (kanal-html-format-verbose
		   "<br> <font color=\"blue\">proposed fix</font> : add a ~S step with ~S as ~S before step ~S to change ~S of ~S~%"
		  p-action description-of-vals val failed-step role object)
		 (generate-fix-item
		  (list 'add p-action '{with description-of-vals 'as val '}
		        'before failed-step 'to-make role 'of object 'become val) 
		  ':add-step-before-step)
		 ))
	    ))
    
      
      (when (null proposed-actions) 
	(kanal-format-verbose "       -> no step addition applicable~%")
        (kanal-html-format-verbose  "<br>       -> no step addition applicable~%<br>")
      )
    )
  )


(defun step-can-change-role-value-of-object (action-instance object role)
  (let* ((concepts (get-concepts-from-instance object))
        ;;(add-del-lists (union (get-assertions action-instance)
        ;;		      (get-deletions action-instance)))
	(action (get-concept-from-instance action-instance))
        (add-list (union (get-assertions action-instance)
			 (first (second (assoc action
					       *action-effect-table*)))))
        )
    ;; consider added effects only for now
    (effects-can-change-role-value-of-object action add-list concepts object role)
    ))


;; returns the values of the effects that can chage the role value
(defun effects-can-change-role-value-of-object (action effects concepts object role)
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
	    (setq result (append result (list (list (compute-object-roles-to-be-changed action role )))))))  )
    (remove-duplicates result :test #'equal)))

(defun action-can-change-role-value-of-object (action object role)
  (let* ((concepts (get-concepts-from-instance object))
         (add-del-lists (compute-add-del-lists action))
         (add-list (first add-del-lists))
         ;;(del-list (second add-del-lists))
         )
    ;;(format t "~% FOR concepts:~S    affects: ~S~%" concepts affects)
    ;; consider added effects only for new action
    (action-effects-can-change-role-value-of-object action add-list concepts object role)
    ))

(defun action-effects-can-change-role-value-of-object (action effects concepts object role)
  (let ((result nil))
    (dolist (effect effects)
      (let ((affected-concepts (get-object effect))
	    (affected-role (get-role effect))
	   )
        ;;(format t "affected thing:~S~%" affected-things)
        (if (and (equal-objects role affected-role)
		 (or (null object)
		     (null concepts);; invalid object description?
		     (intersection concepts
				   (union affected-concepts
					  (get-all-subconcepts affected-concepts)))))
	  (setq result
		(append result (list (list (compute-object-roles-to-be-changed action role )))))) ))
    (remove-duplicates result :test #'equal)))

;; This needs to be modified,
;; we need to access this kind of info from component library when it is ready

(defun compute-object-roles-to-be-changed (action role)
  (case action
    ((#$|Move| #$|Traverse| #$|Carry| #$|Fall| #$|Emit| #$|Absorb| #$|Take-In| #$|Take-Up| #$|Move-Into| #$|Move-To| #$|Leave| #$|Exit| #$|Enter| #$|Go-To| #$|Move-Through| #$|Move-Out-Of| #$|Slide| #$|Goto| #$|Move-From|)
       (if (equal role '#$|location|)
	   '#$|destination|
	   (list 'the role 'of '#$|destination|)))
    (#$|Add| '#$|base|)
    (#$|Produce| '#$|raw-material|)
    ((#$|Breach| #$|Divide| #$|Copy| #$|Duplicate| #$|Deliver| #$|Obtain| #$|Give| #$|Supply| #$|Feed| #$|Relinquish| #$|Obtain| #$|Lose| #$|Transfer| #$|Receive|) '#$|object|)
    ((#$|Collide| #$|Make-Contact| #$|Store|) (list '#$|object| 'and '#$|base|))
    (otherwise 'roles)
    )
  )

(defun find-actions-that-can-change-role-value (object role)
  (find-actions-that-can-change-role-value-1 object role (get-concept-action)))

(defun find-actions-that-can-change-role-value-1 (object role concept)
  (let ((actions (get-subclasses concept)) 
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
;; Suggest to modify previous steps that can achieve the effect
;;  1  Find current steps that can potentially achieve the effect
;;  2  Suggest to the user to modify the step

(defun suggest-to-modify-steps-that-can-achieve-the-effect (object role val failed-step steps-before)
  
  (kanal-html-format-verbose "<br> ..............................................................~%")
  (kanal-format-verbose "~%     .. checking if steps can be modified .. ~%")
  (kanal-html-format-verbose  "~%<br>     .. checking if steps can be modified ..<br> ~%")
  (if (complex-type val)
      (suggest-to-modify-steps-that-can-achieve-the-state object role val failed-step steps-before))
  (if (not (state-test val))
      (suggest-to-modify-steps-that-can-change-role-value object role val failed-step steps-before))
  )
    

(defun suggest-to-modify-steps-that-can-achieve-the-state (object role val failed-step steps-before)
  (dolist (step steps-before)
    (let ((asserted? (step-asserted-the-object step object role val))
	  (deleted? (step-deleted-the-object step object role val)))
      (cond ((mustnt-be-type val)
	     (cond ((equal asserted? 'same)
		    (kanal-format-verbose " proposed fix : delete or modify ~S step since it asserted the state~%" step)
		    (kanal-html-format-verbose
		     " <font color=\"blue\">proposed fix</font> : delete or modify ~S step since it asserted the state<br>" step)
		    (generate-fix-item (list 'delete-or-modify step) ':delete-or-modify-step "the step asserted the state")
		    )
		   ((equal deleted? 'similar)
		    (kanal-format-verbose " proposed fix : modify ~S step so that it can delete the state~%" step)
		    (kanal-html-format-verbose
		     " <font color=\"blue\">proposed fix</font> : modify ~S step so that it can delete the state<br>" step)
		    (generate-fix-item (list 'modify step) ':modify-step "the step may be able to delete the state")
		    )
		   ))
	    ((or (must-be-type val) (be-type val))
	     (cond ((equal deleted? 'same)
		    (kanal-format-verbose " proposed fix : delete or modify ~S step since it deleted the state~%" step)
		    (kanal-html-format-verbose
		     " <font color=\"blue\">proposed fix</font> : delete or modify ~S step since it delete the state<br>" step)
		    (generate-fix-item (list 'delete-or-modify step) ':delete-or-modify-step "the step deleted the state")
		    )
		   ((equal asserted? 'similar)
		    (kanal-format-verbose " proposed fix : modify ~S step so that it can assert the state~%" step)
		    (kanal-html-format-verbose
		     " <font color=\"blue\">proposed fix</font> : modify ~S step so that it can assert the state<br>" step)
		    (generate-fix-item (list 'modify step) ':modify-step "the step may be able to assert the state")))
	     ))
      )))

(defun suggest-to-modify-steps-that-can-change-role-value (object role val failed-step steps-before)
  (let ((affected-actions (find-prev-steps-that-can-change-role-value 
		       object role steps-before)))
    (dolist (action-and-vals affected-actions)
	  (let* ((p-action (first action-and-vals))
	         (effect-vals (second action-and-vals))
	         (description-of-vals (make-sentence-for-vals effect-vals))
	         ;;(expected-val (make-sentence (pretty (evaluate-expr val))))
	         )
	    (cond ((null failed-step);; case of unachieved expected effect
		 (kanal-format-verbose " proposed fix : modify ~S step with ~S as ~S to change ~S of ~S~%"
				   p-action description-of-vals val role object)
		 (kanal-html-format-verbose
		  " <font color=\"blue\">proposed fix</font> : modify ~S step with ~S as ~S to change ~S of ~S~%"
		  p-action description-of-vals val role object)
		 (generate-fix-item (list 'modify p-action '{with description-of-vals 'as val '} 'to-make role 'of object 'become val) ':modify-step))
		(t;; case of unachieved precondition
		 (kanal-format-verbose " proposed fix : modify a ~S with ~S as ~S step before step ~S to change ~S of ~S~%"
				   p-action description-of-vals val failed-step role object)
		 (kanal-html-format-verbose
		  " <font color=\"blue\">proposed fix</font> : modify a ~S with ~S as ~S step before step ~S to change ~S of ~S~%"
		  p-action description-of-vals val failed-step role object)
		 (generate-fix-item (list 'modify p-action '{with description-of-vals 'as val '} 'before failed-step 'to-make role 'of object 'become val) 
				':modify-step) ))
	    ))
    (when (null affected-actions)
	(kanal-format-verbose "       -> no step modification applicable~%")
	(kanal-html-format-verbose "<br>       -> no step modification applicable<br>~%"))
    )
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; when the preconditions is like this
;; (:triple OBJ SLOT1 (mustnt-be-a CLASS with (SLOT2 VALS)))
;; we propose to add a step that can delete instances of this
;;         (a-CLASS SLOT2 VALS)
;;         (a-CLASS (inverse-of SLOT1) OBJ)
(defun find-actions-that-can-delete-state (val)
  (let* ((the-state (second val))
	   (effect-found (assoc the-state *state-effect-table*)))
    (if effect-found
	  (third effect-found)
      nil)
    )
  )

(defun step-asserted-the-object (step obj role val)
  (let ((the-obj (second val))
	(slot1 (get-inverse role))
	(add-list (get-assertions step))
	(result nil))
    (dolist (add-item add-list)
      (let ((obj-in-add-item (get-object add-item)))
	;(format t "~% add-item ~S" add-item)
	(when (and ;(isa-state obj-in-add-item)
	       (equal-objects the-obj (get-concept-from-instance obj-in-add-item))
	       (equal-objects slot1 (get-role add-item)))
	  (if (equal-objects obj (get-val add-item))
	      (setq result 'same)
	    (if (not (equal result 'same))
		(setq result 'similar))))))
    result)
  )

    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; when the preconditions is like this
;; (:triple OBJ SLOT1 (must-be-a CLASS with (SLOT2 VALS))) or 
;; (:triple OBJ SLOT1 (a CLASS with (SLOT2 VALS)))
;; we propose to add a step that can add instances of this
;;         (a-CLASS SLOT2 VALS)
;;         (a-CLASS (inverse-of SLOT1) OBJ)
(defun find-actions-that-can-assert-state (val)
  (let* ((the-state (second val))
	 (effect-found (assoc the-state *state-effect-table*)))
    (if effect-found
	(second effect-found)
      nil)
    )
  )

(defun step-deleted-the-object (step obj role val)
  (let ((the-obj (second val))
	(slot1 (get-inverse role))
	(del-list (get-deletions step))
	(result nil))
    (dolist (del-item del-list)
      (let ((obj-in-del-item (get-object del-item)))
	(when (and ;(isa-state obj-in-del-item)
		 (equal-objects the-obj (get-concept-from-instance obj-in-del-item))
		 (equal-objects slot1 (get-role del-item)))
	  (if (equal-objects obj (get-val del-item))
	      (setq result 'same)
	    (if (not (equal result 'same))
		(setq result 'similar))))))
    result)
  )

;; the above don't work for steps not executed yet, so I am using this hack for now.
(defun step-can-delete-the-object (step obj role val)
  (let* ((the-obj (second val))
	 (action-type (first (third (assoc the-obj *state-effect-table*))))
	 )
    (if (and action-type
	     (isa-class step action-type)
	     (or (member obj (get-role-values step '#$object))
		 (member obj (get-role-values step '#$base))
		 (member obj (get-role-values step '#$abuts))
		 (member obj (get-role-values step '#$agent))))
	't
      nil)))

(defun step-can-assert-the-object (step obj role val)
  (let* ((the-obj (second val))
	 (action-type (first (second (assoc the-obj *state-effect-table*))))
	 )
    (if (and action-type
	     (isa-class step action-type)
	     (or (member obj (get-role-values step '#$object))
		 (member obj (get-role-values step '#$base))
		 (member obj (get-role-values step '#$abuts))
		 (member obj (get-role-values step '#$agent))))
	't
      nil)))

(defun complex-type (val)
  (or (mustnt-be-type val)
      (must-be-type val)
      (be-type val)))

(defun path-type (ele)
  (if (and (listp ele) (listp (nth 3 ele)))
      (if (or (equal (nth 2 ele) '#$|of|) (equal (nth 2 ele) '#$|with|))
	  T)))

(defun mustnt-be-type (val)
  (and (listp val)
       (equal (first val) '#$|mustnt-be-a|)))
(defun must-be-type (val)
  (and (listp val)
       (equal (first val) '#$|must-be-a|)))
(defun be-type (val)
  (and (listp val)
       (equal (first val) '#$|a|)))

(defun state-test (val)
  (and (listp val)
       (subconcept? (second val) '#$State)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Suggest that there are missing ordering constraints in the process model
;;  1  Find an action (or actions) that may have an effect
;;	(or effects) that undid the expected effect
;;     Find an action (or actions) that asserts the expected effect
;;  2  Suggest to the user to insert an ordering constraint
;;     in order to maintain the expected effect where needed
(defun suggest-to-change-ordering-between-steps (object role val
						 steps-before failed-step steps-after
						 )
  
  (kanal-html-format-verbose "<br> ..............................................................~%")
  (kanal-format-verbose "~%     .. checking if ordering changes may fix the problem .. ")
  (kanal-html-format-verbose
   "~%<br>     .. checking if ordering changes may fix the problem .. <br>")
  (let* ((prev-steps-that-undid-effect
	 (find-prev-steps-that-undid-effect object role val steps-before))
	(following-steps-that-can-reinstantiate-effect
	 (find-following-steps-that-can-reinstantiate-effect
			    object role val steps-after))
	(affected-steps
	 (union prev-steps-that-undid-effect following-steps-that-can-reinstantiate-effect))
	)
    
    (cond ((null affected-steps) ;(or (null affected-steps) (null (second affected-steps)))
	   
	   (kanal-format-verbose "~%       -> no ordering change applicable~%")
	   (kanal-html-format-verbose
	    "~%<br>       -> no ordering change applicable<br>~%"))
	  (t
	   
	     (kanal-format-verbose "~% proposed fix : check the ordering among these steps ")
	     (mapcar #'print-step affected-steps)
	     (kanal-format-verbose "~%  because they changed the value of ~S"  role)
	     (kanal-html-format-verbose "~%<br> <font color=\"blue\">proposed fix</font>: check the ordering among these steps ~{~%<br>~S~}~%"
					affected-steps)
	     (kanal-html-format-verbose "<br>because the changed the value of ~S~%"
					role)
	   
	  
	   (propose-to-change-ordering-with-prev-steps prev-steps-that-undid-effect failed-step
						       object role val)
	   (propose-to-change-ordering-with-following-steps following-steps-that-can-reinstantiate-effect
							    failed-step object role val)
	       
	   )
	  )
    )
  (kanal-format-verbose "~%")
  (kanal-html-format-verbose "~%<br>~%")
  )

;; to do 9/30/01
;; if they are not in the same level, the
(defun propose-to-change-ordering-with-prev-steps (affected-steps failed-step object role val)
  (if (null failed-step)
      affected-steps
    (dolist (step affected-steps)
      (let ((ordered-steps (find-ordered-steps step failed-step)))
	(if ordered-steps
	    (generate-fix-item (list 'change-or-add-link-between-steps
				     ordered-steps
				    'to-make role 'of object 'become val)
			      ':change-or-add-link-between-steps))))
 ))
(defun propose-to-change-ordering-with-following-steps (affected-steps failed-step object role val)
  (if (null failed-step)
      affected-steps
    (dolist (step affected-steps)
      (let ((ordered-steps (find-ordered-steps failed-step step)))
	(if ordered-steps
	    (generate-fix-item (list 'change-or-add-link-between-steps
				     ordered-steps
				    'to-make role 'of object 'become val)
			      ':change-or-add-link-between-steps))))
 ))

(defun find-prev-steps-that-undid-effect (object role val steps-before) 
  (let ((result nil))
    (dolist (step steps-before)
      (if (step-undid-effect step object role val)
	  (setq result (append result (list step)))
	))
    result
    )
  )

(defun step-undid-effect (step object role val)
  (if (complex-type val)
      (step-undid-the-state step object role val)
    (step-undid-the-role-value step object role val)))

(defun step-undid-the-state (step object role val)
  (let ((asserted? (step-asserted-the-object step object role val))
	(deleted? (step-deleted-the-object step object role val)))
    (cond ((mustnt-be-type val)
	   (when (equal asserted? 'same)
	     (kanal-format-verbose "~% proposed fix : move ~S step after the failed step since it made the state fail~%" step)
	     (kanal-html-format-verbose "<p> proposed fix : move ~S step after the failed step since it made the state fail</p>" step)
	     't
	     )
	   )
	  
	  ((or (must-be-type val) (be-type val))
	   (when (equal deleted? 'same)
	     (kanal-format-verbose "~% proposed fix : move ~S step after the failed step since it made the state fail~%" step)
	     (kanal-html-format-verbose "<p> proposed fix : move ~S step after the failed step since it made the state fail</p>" step)
	     't
	     )))
    ))

(defun step-undid-the-role-value (step object role val)
  (let ((del-list (get-deletions step))
	(result nil))
    ;(format t "~% del list of ~S:~S ~%" step del-list)
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

(defun find-prev-steps-that-can-change-role-value (object role steps-before)
  (let ((result nil))
    (dolist (step steps-before)
      (let ((values-of-effects (step-can-change-role-value-of-object step object role)))
	(if values-of-effects ;; step can add the effect
	    (setq result (append result (list (list step values-of-effects))))
	  )))
    result
    )
  )

(defun find-following-steps-that-can-reinstantiate-effect (object role val steps-after)
  (let ((result nil))
    (dolist (step steps-after)
      (if (step-reinstantiate-effect step object role val)
	  (setq result (append result (list step)))
	))
    result
    )
  )

;; (:triple _Bacterial-Polymerase980 object-of  (mustnt-be-a Be-Restrained))
;; del-list: (:triple _Be-Restrained1033 object _Bacterial-Polymerase980)
(defun step-reinstantiate-effect (step object role val)
  (if (complex-type val)
      (step-reinstantiate-the-state step object role val)
    (step-reinstantiate-the-role-value step object role val)))

(defun step-reinstantiate-the-state (step object role val)
  (let ((asserted? (step-can-assert-the-object step object role val))
	(deleted? (step-can-delete-the-object step object role val)))
    (cond ((mustnt-be-type val)
	   (when  deleted? 
	       (kanal-format-verbose "~% proposed fix : move ~S step before the failed step since it can delete the state~%" step)
	       (kanal-html-format-verbose "<p> proposed fix : move ~S step before the failed step since it can delete the state</p>" step)
	       't))
	  ((or (must-be-type val) (be-type val))
	   (when asserted? 
	       (kanal-format-verbose "~% proposed fix : move ~S step before the failed step since it can assert the state~%" step)
	       (kanal-html-format-verbose "<p> proposed fix : move ~S step before the failed step since it can assert the state</p>" step)
	       't)))
    ))
  
(defun step-reinstantiate-the-role-value (step object role val)
  (let ((add-list (get-assertions step))
	(result nil))
    (dolist (affect add-list)
      (let* ((affected-object (second affect))
	     (affected-role (third affect))
	     (affected-thing (fourth affect)))
	(if (and (equal-objects role affected-role)
		 (equal-objects object affected-object)
		 (equal-objects val affected-thing))
	    (setq result 't))))
    result)
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; handling exprs 
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
(defvar *expected-effects-for-steps* nil)
(defvar *model-to-test*  nil)
(defvar *current-model-instance* nil)
(defvar *start-situation* nil)
(defvar *what-to-simulate* nil) ;; a substep of current model to be tested

(defun find-unachieved-expected-effects (process-model)
  (kanal-format "~%~%  ************************************************")
  (kanal-format "~%                check expected effects")
  (kanal-format "~%  ************************************************")
  (kanal-format "~%    we check each simulated path~%~%")

  (kanal-html-format "<hr><h2>Check expected effects</h2>~%")
  (kanal-html-format "<p>We check each simulated path</p>~%<ul>~%")

  (let ((effects-not-achieved-in-all-paths nil))
    (dolist (path *paths-simulated*)
      (let ((deleted-effects
	   (event-info-all-deleted-effects (first (last path))))
	  (added-effects
	   (event-info-all-added-effects (first (last path))))
	  (last-situation (get-next-situation (first (last path)))))
        (unless (and (null added-effects) (null deleted-effects))
	(kanal-format "~%  ------------------------------------------------")
	(kanal-format "~%    The overall effects for path")
	(kanal-format "~%        ~S" (mapcar #'get-event path))
	(kanal-format "~%  ------------------------------------------------")
	(kanal-format "~%   added:   ~%")
	(print-items-with-space 13 (mapcar #'first added-effects))
	(kanal-format "~%   deleted: ~%")
	(print-items-with-space 13 (mapcar #'first deleted-effects))

	(kanal-html-format "~%<li><p>The overall effects for path ~S</p>~%"
		         (mapcar #'get-event path))
	(kanal-html-format "<ul><li>Added: <br>~%")
	(dolist (add (mapcar #'first added-effects))
	        (kanal-html-format "~S<br>~%" add))
	(kanal-html-format "</li>~%<li>Deleted: <br>~%")
	(dolist (add (mapcar #'first deleted-effects))
	        (kanal-html-format "~S<br>~%" add))
	(kanal-html-format "</li></ul>~%")
	)
	(let ((expected-effects (find-expected-effects-for-model process-model))
	      (effects-not-achieved nil))
	  (cond ((null expected-effects)
	         (kanal-format "~%  .............................................")
	         (kanal-format "~% The expected effects for ~a is not specified yet!~%" process-model)
	         (kanal-html-format "<p>No expected effects for ~A are specified yet.</p>~%"
			        process-model)
	         )
	        (t
	         (kanal-format "~%  These are expected results of a ~S~%" process-model)
	         (kanal-format "  (We assume that the user entered these using the Dialog Window)~%")
	         ;;(mapcar #'print-description expected-effects)
	         (make-sentence expected-effects)
	         (kanal-html-format "<br>These are expected effects of a ~S~%"
			        process-model)
	         (kanal-html-format "<br>  (We assume that the user entered these using the Dialog Window)<br>~%")
	         (kanal-format "~%  .............................................")
	         (kanal-format "~%                  results")
	         (kanal-format "~%  .............................................~%")
		 (setq negflag 0)
	         (dolist (effect expected-effects)
		   (cond ((not (listp effect))
		          (setq negflag 1))
		     (t 
		      (cond ((equal negflag 1)
		             (setq negflag 0))
		      (t
		       (collect-failed-exprs-on)
		       (cond ((test-expr effect last-situation)
		          (kanal-format "~% ~S" effect)
		          (kanal-format "      -> the effect is achieved!~%")
		          (kanal-html-format "<br>~S~%" effect)
		          (kanal-html-format "<br>      -> the effect is achieved!~%")
		          (collect-failed-exprs-off)
		          ;;(kanal-format "~%failed expressions ~S~%" *expressions-failed*)
		  	 ;changed :error to :warning (amit agarwal)
		          (generate-error-checker-item (list (convert-roles-to-eng effect))
		 			       ':expected-effect ':warning 't process-model)
		         )
		         ((invalid-triple effect :expected-effect process-model)
		          t)
		         (t
		          (kanal-format "~% ~S" effect)
		          (kanal-format "      => the effect is NOT achieved <=~%")
		          (kanal-html-format "<br><font color=\"red\">~S~%" effect)
		          (kanal-html-format "<br>      -> the effect is NOT achieved</font>~%")
		 	  ;changed :error to :warning (amit agarwal)
		          (generate-error-checker-item (list (convert-roles-to-eng effect))
		 			       ':expected-effect ':warning nil process-model)
		          (collect-failed-exprs-off)
		          ;;(propose-fixes-for-unachieved-effects)
		          ;;(setq effects-not-achieved
		          ;;(append effects-not-achieved (list (list effect *expressions-failed*))))
		          (setq effects-not-achieved
			    (append effects-not-achieved (list effect)))
		          ))
		       ))))
		    )
	         (cond ((null effects-not-achieved)
		      (kanal-format "~% ALL THE EXPECTED EFFECTS ARE ACHIEVED!~%")
		      (kanal-html-format "~%<br> <font color=\"blue\">ALL THE EXPECTED EFFECTS ARE ACHIEVED.</font>~%")
		      ;;(generate-error-checker-item expected-effects
		      ;;			     ':expected-effect ':error 't process-model)
		      nil)
		     (t
		      (setq effects-not-achieved-in-all-paths
			  (union effects-not-achieved-in-all-paths
			         effects-not-achieved))
			
		      effects-not-achieved)))
	        )
	  )
	(kanal-html-format "~%</li>~%")
	))
    (kanal-html-format "~%</ul>~%")
    effects-not-achieved-in-all-paths
    ))
	
(defun get-inverse-inequality-role (role)
  (cond ((equal role '>) 
         '<)
        ((equal role '<) 
	 '>)
	((equal role '>=) 
	 '<=)
	((equal role '<=)
	 '>=)
	((equal role '=) 
	 '=)
	((equal role '/=)
	 '/=))
  )

(defun inequality-role (role)
  (or (equal role '>) (equal role '<) (equal role '>=) (equal role '<=)
		     (equal role '=) (equal role '/=))
  )

(defun inequality-eng-role (role)
  (or (string-equal role 'greater-than) (string-equal role 'less-than) (string-equal role 'is-greater-or-equal) 
      (string-equal role 'is-less-or-equal) (string-equal role 'is-equal) (string-equal role 'is-not-equal))
  )

(defun invalid-triple (triple type event )
  (when (equal (first triple) '#$:triple)
   (let* ((object (get-object triple)) 
	 (role (get-role triple))
	 (object-val (evaluate-expr object))
	 (role-val (evaluate-expr role)))
    (cond ((and object-val role-val)
	   nil)
	  ((and (null object-val) (null role-val))
	   (generate-error-checker-item `(OBJECT-FIELD - ,object  and ROLE-FIELD - ,role  of ,triple) :invalid-expr ':error nil (list type event))
	   (kanal-format "~% ERROR: the object and role field of ~S is null~%" triple)
	   (kanal-html-format
	    "~%<br> <font color=\"red\">ERROR: the object and role field of ~S is null</font>~%"
	    triple)
	   t)
	  ((null object-val)
	   (generate-error-checker-item `(OBJECT-FIELD - ,object of ,triple) :invalid-expr ':error nil (list type event))
	   (kanal-format "~% ERROR: the object field of ~S is null~%" triple)
	   (kanal-html-format
	    "~%<br> <font color=\"red\">ERROR: the object field of ~S is null</font>~%"
	    triple)
	   t
	   )
	  ((not (inequality-role role))
	   (generate-error-checker-item `(ROLE-FIELD - ,role of ,triple) :invalid-expr ':error nil (list type event))
	   (kanal-format "~% ERROR: the role field of ~S is null~%" triple)
	   (kanal-html-format
	    "~%<br> <font color=\"red\">ERROR: the role field of ~S is null</font>~%"
	    triple)
	   t))))
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
     (and (cond ((and (inequality-role role-name1)  (inequality-role role-name2))
                 (equal role-name2 (get-inverse-inequality-role role-name1)))
                ((or (inequality-role role-name1)  (inequality-role role-name2))
		  nil)
		(t
                 (equal-objects role-name2 (get-inverse role-name1))))
	  (equal-objects value1 object2)
	  (equal-objects value2 object1))
     (and (cond ((and (inequality-role role-name1)  (inequality-role role-name2))
                 (equal role-name2 role-name1))
                ((or (inequality-role role-name1)  (inequality-role role-name2))
		  nil)
		(t
                 (equal-objects role-name2 role-name1)))
	  (equal-objects object1 object2)
	  (equal-objects value1 value2)))
    ))
	
(defun find-expected-effects-for-model (model)
  (if (equal *interaction-mode* 'use-interaction-plan)
      (cdr (assoc model *all-expected-effects*))
    (get-kanal-expected-effects-for-event *current-model-instance* *current-model-instance*))
  )

;; 
(defun effects-achieve-condition (effects condition)
  (let ((obj (get-object condition))
	(role (get-role condition))
	(val (get-val condition)))
    (cond ((complex-val val)
	   (let ((targets (get-role-values obj role))
		 (achieve nil))
	     (dolist (target targets)
	       (if (and (isa-class target (second val)) (satisfy-constraints target (cdddr val))
			(effects-achieve-condition effects `(#$:triple ,obj ,role ,target)))
		   (setq achieve 't)))
	     achieve))
	  (t
	   (let ((achieve nil))
	     (dolist (effect effects)
	       (if (effect-equivalent effect condition)
		   (setq achieve 't)))
	     achieve)
	   )
	)
    )
  )
(defun satisfy-constraints (obj constraints)
  (let ((satisfy 't))
    (dolist (constraint constraints)
      (let ((role (first constraint))
	    (vals (mapcar #'evaluate-expr (second constraint))))
	(dolist (val vals)
	  (if (null (test-expr `(#$:triple ,obj ,role ,val)))
	      (setq satisfy nil)))))
    satisfy))

;;; ----------------------------------------------------------------------
;;; check expected effects for a step (event)

(defun check-expected-effects-of-event (event situation)
  (kanal-format "~%~%  --- checking expected effects of event~%")
  (kanal-html-format "<hr><h2>Check expected effects of event</h2>~%")

  ;(format t "~%--------- CALLING SRI FUNCTION get-expected-effects-for-event -----------~%")
  (let* ((effects-not-achieved nil)
	 (model *model-to-test*)
	 (expected-effects (get-kanal-expected-effects-for-event *current-model-instance* event)))
  ;(format t "~%--------- BACK FROM get-expected-effects-for-event -----------~%~%")

    (when (null expected-effects)
      (kanal-format "~%~%  --- no effect specified~%")
      (kanal-html-format "<hr><h2>no effect specified</h2>~%"))
    (setq negflag 0)
    (dolist (effect expected-effects)
      ;(format t "~%EFFECT ********** ~S ~% ~S~%" effect situation)
      (cond ((not (listp effect))
         (setq negflag 1))
      (t 
        (cond ((equal negflag 1)
          (setq negflag 0)) ;; TODO : should handle the negative events as well
        (t
          (cond ((test-expr effect situation)
	     ;(format t "effect ************* ~% ~S" effect)
	     (kanal-format "~% ~S" effect)
	     (show-triples (list effect))
	     (kanal-format "      -> the effect is achieved!~%")
	     (kanal-html-format "<br>~S~%" effect)
	     (kanal-html-format "<br>      -> the effect is achieved!~%")
	     (collect-failed-exprs-off)
	     ;;(kanal-format "~%failed expressions ~S~%" *expressions-failed*)
	     ;changed :error to :warning (amit agarwal)
	     (generate-error-checker-item (list (convert-roles-to-eng effect))
					  ':expected-effect-for-step ':warning 't
					  (list event situation))
	     )
	    ((invalid-triple effect :expected-effect model)
	     t)
	    (t
	     (kanal-format "~% ~S" effect)
	     (kanal-format "      => the effect is NOT achieved <=~%")
	     (kanal-html-format "<br><font color=\"red\">~S~%" effect)
	     (kanal-html-format "<br>      -> the effect is NOT achieved</font>~%")
	     ;changed :error to :warning (amit agarwal)
	     (generate-error-checker-item (list (convert-roles-to-eng effect))
					  ':expected-effect-for-step ':warning nil
					  (list event situation))
	     (collect-failed-exprs-off)
	     ;;(propose-fixes-for-unachieved-effects)
	     ;;(setq effects-not-achieved
	     ;;(append effects-not-achieved (list (list effect *expressions-failed*))))
	     (setq effects-not-achieved
		   (append effects-not-achieved (list effect)))
	     )
	    )))))
      )
    effects-not-achieved
    )
  )

;;; ======================================================================
;;;		Find loops
;;; ======================================================================

;;; find loops
(defun loop-found (event path)
  (let* ((event-path (mapcar #'get-event path))
         (sequence-after-event (member event event-path)))
    (cond ((and sequence-after-event 
            (check-overlapping-loops event-path *loops-found*)) ; Don't add overlapping loops
	 (kanal-format "~%~% WARNING (loop found): This path already have the event ~S" event)
	 (kanal-format "~%     ~S" event-path)
	 (kanal-format "~%   Loop in the path:")
	 (kanal-format "~%      ~S" (append sequence-after-event (list event)))
	 (kanal-html-format "<br><font color=\"red\">WARNING (loop found): This path already has the event ~S"
			event)
	 (kanal-html-format "~%<br>     ~S" event-path)
	 (kanal-html-format "~%<br>   Loop in the path:")
	 (kanal-html-format "~%<br>      ~S" (append sequence-after-event (list event)))
	 (setq *loops-found* (append *loops-found*
			         (list (append sequence-after-event (list event)))))
	 t)
	(t nil)
	))
  )

(defun report-loops ()
  (when *paths-simulated*
  (kanal-format "~%~%  ************************************************")
  (kanal-format "~%          Summary of Loops Found")
  (kanal-format "~%  ************************************************")
  (kanal-html-format "<hr><h2>Summary of Loops Found</h2>")
  (cond ((null *loops-found*)
	 (generate-error-checker-item nil
				      ':loop
				      ':warning
				      't
				      *model-to-test*)
	 (kanal-format "~%       -->  NO LOOP FOUND! ~%")
	 (kanal-html-format "<br>  <font color=\"blue\">No loop found!</font>~%")
	 )
	(t (generate-error-checker-item *loops-found*
					':loop
					':warning
					nil
					*model-to-test*)
	   (mapcar #'(lambda (loop)
		     (kanal-format "~%   ~S" (mapcar #'get-concept-name loop))
		     (kanal-html-format "~%<br>   ~S"
				    (mapcar #'get-concept-name loop)))
		   *loops-found*)
	   (kanal-format "~%")
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
;; 3) type: one of :precondition :expected-effect :loop :max-loops :redundant-sequence, ...
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

(defun find-fixes-for-failed-precondition (triple failed-step)
  (let* ((object (second triple))
	(role (third triple))
	(val (fourth triple))
	(steps-before-failed-step (find-steps-before failed-step))
	(steps-after-failed-step (set-difference *all-executable-events*
				     (union steps-before-failed-step (list failed-step)))))
   (when (not (inequality-role role))
    (kanal-format-verbose "~% ..............................................................")
    (kanal-format-verbose "~%   checking how to change ~S value of ~S .. " role object)
    (kanal-format-verbose "~% ..............................................................~%")
    (kanal-html-format-verbose "~%<br> ..............................................................~%")
    (kanal-html-format-verbose "~%<br>checking how to change ~S value of ~S<br>~%"
			 role object)
    
    ;; 1. Suggest that there are missing steps in the process model
    (suggest-to-add-steps-that-can-achieve-the-effect object role val failed-step)
    ;; 2. Suggest to modify current steps in the process model
    (suggest-to-modify-steps-that-can-achieve-the-effect object role val 
							 failed-step
							 steps-before-failed-step)
    ;; 3. Suggest that there are missing ordering constraints
    (suggest-to-change-ordering-between-steps object role val 
					      steps-before-failed-step
					      failed-step
					      steps-after-failed-step)
    ;; 4. Suggest to delete the step whose preconditions were not achieved	     		       
    (kanal-format-verbose "~% ..............................................................")
    (kanal-format-verbose "~%   checking if there are unnecessary steps .. ~%")
    (kanal-format-verbose " ..............................................................~%")
    (kanal-format-verbose "~% proposed fix :  delete or modify ~S~%"  failed-step)
    (kanal-html-format-verbose "<br> ..............................................................~%")
    (kanal-html-format-verbose "~%<br>checking  if there are unnecessary steps  <br>~%")
    (kanal-html-format-verbose
     "<br><font color=\"blue\">proposed fix:</font> delete or modify ~S~%"
     failed-step)
    (if (not (state-test val))
	(suggest-to-modify-slot-values object role val))
    (generate-fix-item (list 'delete-or-modify failed-step) ':delete-or-modify-step)
    )
  )
  )

(defun complex-val (val)
  (or (mustnt-be-type val) (must-be-type val) (be-type val)))

(defun suggest-to-modify-slot-values (obj role val)
  (when (complex-val val)
    (let ((vals (get-role-values-of-type obj role (second val)))
	  (slot-vals (cdddr val)))
      (if (null vals) ;; implicit condition case
	  ;(generate-fix-item `(modify ,(mapcar #'first slot-vals) of ,(second val) (,role of ,obj)) :modify-role-assignments)
	  ;(generate-fix-item '(modify role assignments) :modify-role-assignments)
	  nil  ;; I am not sure if you to propose to modify objects that are not exist
      (cond ((mustnt-be-type val) ; mustnt-be
	     (dolist (type-obj vals)
	       (let ((conditions-satisfied t))
		 (dolist (slot-val slot-vals)
		   (if (null
			(test-expr `(#$:triple ,type-obj ,(first slot-val) ,(second slot-val))))
			(setq conditions-satisfied nil)))
		 (if conditions-satisfied
		     (mapcar #'(lambda (role)
				 (propose-to-modify-role-assignment role type-obj))
			     (mapcar #'first slot-vals))))))
	    (t ; must-be or be
	     (dolist (type-obj vals)
	       (dolist (slot-val slot-vals)
		 (if (null (test-expr `(#$:triple ,type-obj (first slot-val) (second slot-val))))
		     (propose-to-modify-role-assignment (first slot-val) type-obj)
		     ))
	       ))))))
  (propose-to-modify-role-assignment role obj)
  )

(defun propose-to-modify-role-assignment (role obj)
  (generate-fix-item (list 'modify role 'of obj) :modify-role-assignment)
  )

(defun find-fixes-for-unachieved-effect (triple step)
  (let* ((object (second triple))
	(role (third triple))
	(val (fourth triple))
	(steps-before (if step
			 (find-steps-before step)
		       *all-executable-events*))
	(steps-after (if step
			 (set-difference *all-executable-events*
				     (union steps-before (list step)))
			 nil))
	)
   (when (not (inequality-role role))
      
    (kanal-format-verbose "~% ..............................................................")
    (kanal-format-verbose "~%   checking how to change ~S value of ~S .. " role object)
    (kanal-format-verbose "~% ..............................................................~%")
    (kanal-html-format-verbose "~% ..............................................................~%")

    (kanal-html-format-verbose "~%<br>checking how to change ~S value of ~S<br>~%"
			 role object)
    
    ;; 1. Suggest that there are missing steps in the process model
    (suggest-to-add-steps-that-can-achieve-the-effect object role val nil)
    ;; 2. Suggest to modify current steps in the process model
    (suggest-to-modify-steps-that-can-achieve-the-effect object role val nil steps-before)
    ;; 3. Suggest that there are missing ordering constraints
    (suggest-to-change-ordering-between-steps object role val steps-before nil steps-after)

  ))
)
(defun find-fixes-for-undoable-event (event)
  (generate-fix-item (list 'change-or-add-link-between-steps-for-undoable-event event) ':change-or-add-link-between-steps)
  )


(defun find-fixes-for-delete-error (constraint event)
  ;check-with-jerome (generate-fix-item (list 'modify event 'to-delete-other-than constraint) ':modify-step)
  (generate-fix-item (list 'modify 'role-assignments 'of event 'to-delete-other-than constraint) ':modify-step)
  (generate-fix-item (list 'modify-events-before event 'to-assert constraint) ':modify-steps)
  )

(defun find-fixes-for-unreached-events (events path)
  (generate-fix-item (list 'change-or-add-link-between-steps-for-unreached-events events) ':change-or-add-link-between-steps)
  
  )

(defun find-roles-involved (instance desc)
  (cond ((null desc) nil)
	((atom desc) nil)
	((and (equal (first desc) '#$the)
	      (equal (third desc) '#$of)
	      (equal (fourth desc) instance))
	 (list (second desc)))
	(t
	 (append (find-roles-involved instance (first desc))
		 (find-roles-involved instance (rest desc)))))
  )
#|
(defun find-fixes-for-effectless-event (event)
  (let* ((del-list-desc (get-role-description event '#$del-list))
	 (roles (remove-duplicates (find-roles-involved event del-list-desc))))
    (if del-list-desc
	(generate-fix-item  `(items to be removed were defined as the following  ,del-list-desc -- modify-or-assert ,roles of ,event so that we can remove something)
			    :modify-role-values-to-delete-something)))
  (let* ((add-list-desc (get-role-description event '#$add-list))
	 (roles (remove-duplicates (find-roles-involved event add-list-desc))))
    (if add-list-desc
	(generate-fix-item `(items to be asserted were defined as the following  ,add-list-desc -- modify-or-assert ,roles of ,event so that we can assert something)
		       :modify-role-values-to-add-something)))
  (generate-fix-item (list 'modify event 'to-achieve-something) ':modify-step)
  
  )
|#
(defun find-fixes-for-effectless-event (event)
  (let* ((del-list-desc (get-role-description event '#$del-list))
	 (roles (remove-duplicates (find-roles-involved event del-list-desc))))
    (if del-list-desc
	(mapcar #'(lambda (role)
		    (propose-to-modify-role-assignment role event)) roles)))
  (let* ((add-list-desc (get-role-description event '#$add-list))
	 (roles (remove-duplicates (find-roles-involved event add-list-desc))))
    (if add-list-desc
	(mapcar #'(lambda (role)
		    (propose-to-modify-role-assignment role event)) roles)))
  (generate-fix-item (list 'modify event 'to-achieve-something) ':modify-step)
  
  )

(defun find-fixes-for-invalid-expr (expr source)
  (generate-fix-item (list 'modify-expr expr 'in (first source) 'of (second source)) ':modify-step)
  
  )

(defun find-fixes-for-not-exist (expr source)
  ; todo:need to check shaken side (generate-fix-item (list 'add expr 'as (first source) 'of (second source)) ':add-expr)
  (generate-fix-item (list 'add (first source) 'of (second source)) ':add-expr)
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

(defun find-fixes-for-missing-first-subevent (event-info)
  (let ((event (first event-info))
	(subevents (second event-info)))
    (generate-fix-item (list 'specify 'the 'first-subevent 'of event) ':add-first-event)
  ))

(defun find-fixes-for-not-parallel-events (source)
  (generate-fix-item (list 'delete-or-modify 'ordering 'between (first source) 'and (second source)) ':delete-or-modify-link))

(defun find-fixes-for-missing-subevent (event-info)
  (let ((event (first event-info))
	(first-subevent (second event-info)))
    (generate-fix-item (list 'make first-subevent 'a 'subevent 'of event) ':add-subevent)
  ))

(defun create-fix-item (fix type why &optional (source nil))
  (let ((fix-item nil))
    (setq fix-item (acons 'fix fix fix-item))
    (setq fix-item (acons 'type type fix-item))
    ;(setq fix-item (acons 'why why fix-item))
    (setq fix-item (acons 'source source fix-item))
    fix-item
    )
  )

(defun generate-general-fix-item (description &optional (type nil) (source nil))
  (if (null type)
      (generate-fix-item description ':general)
    (generate-fix-item description type nil source))
  )

(defun generate-fix-item (fix type &optional (why nil) (source nil))
  (let ((fix-item (create-fix-item fix type why source)))
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
  (let* ((new-item
	 (generate-error-checker-item-1 exprs type level success source))
	 (success (cdr (assoc 'success new-item))))
    (when new-item
      (if (null success)
	  (kanal-html-format "<br> ==> please see the bottom of this page for suggestions<br>~%" ))
      ;(kanal-format "~% ==  These are the fixes for this problem~%")
      ;(get-proposed-fixes (cdr (assoc 'id new-item)))
      )
    *error-checker-items*)
  )

(defun generate-error-checker-item-1 (exprs type level success source)
  (let ((new-item (create-error-item exprs type level success source)))
    (cond ((not (member new-item *error-checker-items* :test #'equal-error-item))
	   (setq *error-checker-items*
		 (append *error-checker-items*
			 (list new-item)))
	   new-item)
	  (t nil)))
  )

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

(defun show-all-error-checker-items-and-fixes ()
  (kanal-format "~%====================================")
  (kanal-format  "~% Error Items and Their Fixes~%")
  (kanal-format "====================================~%")
  (kanal-html-format "<hr><h2>Error items and their fixes</h2>~%<ul>~%")
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
    (kanal-format "~% there-are-failed-events: ~S~%" there-are-failed-events)
    (kanal-format "~% there-are-unreached-events: ~S~%" there-are-unreached-events
    |#
    (dolist (item *error-checker-items*)
	  (when (null (cdr (assoc 'success item)))
	    ;; have to cache and store proposed-fixes at the right
	    ;; moment, because it prints stuff. Jim.
	    (let ((proposed-fixes nil))
	      (kanal-html-format "~%<br><br><li>")
	      ;(kanal-html-format "~%<p>~S</p>~%" item)
	      (pretty-print-error-item item)
	      (kanal-format "~%~S ~%" item)   
	      (kanal-format "~%==> fixes ~S ~%" 
	       (setf proposed-fixes
		   (get-proposed-fixes (cdr (assoc 'id item)))))
	      ;; don't know if we need this again - Jim.
	      #|(kanal-html-format "==> fixes ~{~S<br>~%~}</li>~%"
			     proposed-fixes)|#
	      ))))
  (kanal-html-format "~%</ul>~%")
  
  (kanal-format "~%~%======================")
  (kanal-format "~% Info Items~%")
  (kanal-format "======================~%")
  (kanal-format "~S ~%" *info-items* )

  (kanal-html-format "<h2>Info items</h2>~%")
  (kanal-html-format "<ul>~{<br><li>~S</li>~%~}~%</ul>~%" *info-items*)
  
  )

(defun get-causal-links-from-kanal-results (kanal-results)
  (if (null kanal-results)
      nil
    (if (equal (cdr (assoc 'type (first kanal-results))) ':causal-links)
	(cdr (assoc 'content (first kanal-results)))
      (get-causal-links-from-kanal-results (rest kanal-results))))
  )

(defun get-simulated-paths-from-kanal-results (kanal-results)
  (if (null kanal-results)
      nil
    (if (equal (cdr (assoc 'type (first kanal-results))) ':simulated-paths)
	(cdr (assoc 'content (first kanal-results)))
      (get-simulated-paths-from-kanal-results (rest kanal-results))))
  )
(defun get-simulated-paths-info-from-kanal-results (kanal-results)
  (if (null kanal-results)
      nil
    (if (equal (cdr (assoc 'type (first kanal-results))) ':simulated-paths-info)
	(cdr (assoc 'content (first kanal-results)))
      (get-simulated-paths-info-from-kanal-results (rest kanal-results))))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; when the condition checks necessity of the step and it failed
;;;  e.g., Make-Contact checks if the object and the base is already in contact
(defun failed-condition-checks-necessity (error-id)
  (let ((error-item (find-error-item error-id)))
    (when (and (equal ':precondition (cdr (assoc 'type error-item)))
	       (null (cdr (assoc 'success error-item))))
    (unnecessary-step (first (cdr (assoc 'constraint error-item)))
		      (cdr (assoc 'source error-item)))
    ))
  )

(defun unnecessary-step (failed-precondition event)
  (let ((val (get-val failed-precondition))
	(add-list (get-assertions event))
	(result nil))
  (if (mustnt-be-type val)
      (let ((the-state (second val)))
	(dolist (add-item add-list)
	  (if (and
	       (isa-class (get-object add-item) the-state)
	       (equal-objects (get-inverse (get-role failed-precondition))
			     (get-role add-item))
	       (equal-objects (get-val add-item)
			     (get-object failed-precondition)))
	      (setq result 't)
	    ))))
  result
  ))



;;; ======================================================================
;;;		utilities 
;;; ======================================================================
;
(defvar *kanal-silent* nil) ;; make kanal silent
(defvar *kanal-verbose* nil) ;; make kanal verbose than usual

;; this can be used to control the level of details printed 
(defun kanal-format-verbose (string &rest args)
  (if (null string)
      (apply #'kanal-format-verbose args)
  (when (and (not *kanal-silent*) *kanal-verbose*)
    (apply #'format (cons *kanal-log-stream* ;; use *kanal-log-stream* instead of stream
			  (cons string args))))))

(defun kanal-format (string &rest args)
  (if (null string)
      (apply #'kanal-format args)
  (when (not *kanal-silent*)
    (apply #'format (cons *kanal-log-stream* ;; use *kanal-log-stream* instead of stream
			  (cons string args))))))

;;; This one sends information to the stream where an html output is
;;; being built up.  Jim, 6/19/01.
(defun kanal-html-format (string &rest args)
  (apply #'format `(,*kanal-html-file-stream* ,string ,@args)))

(defun kanal-html-format-verbose (string &rest args)
  (when *kanal-verbose*
        (apply #'format `(,*kanal-html-file-stream* ,string ,@args))))


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


(defun print-description (effect)
  (kanal-format "~%  ")
  (kanal-format (first effect)))


(defun print-step (step)
  (kanal-format "~%  action ~S" step)
  )


(defun print-indent (level)
  (do ((i 0 (1+ i)))
      ((= i level))
    (kanal-format " ")))

(defun print-items-with-space (nspace items)
  (dolist (item items)
    (print-indent nspace)
    (kanal-format "~S~%" item))
  )

(defun pretty (obj)
  (if (null obj)
      'none
    obj))

(defun get-log-file-name ()
  (let* ((time (multiple-value-list (decode-universal-time (get-universal-time))))
	 (year (nth 5 time))
	 (month (nth 4 time))
	 (day (nth 3 time)))
  (format nil "kanal-log-~4d~2,'0D~2,'0D.log" year month day))
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

(defun get-role-values-of-type (instance role type)
  (let ((vals (get-role-values instance role))
	(result nil))
    (dolist (val vals)
      (if (isa-class val type)
	  (setq result (append result (list val)))))
    result)
  )

(defun get-role-values (instance role &optional (situation nil))
  (if situation
      (km-k `(#$in-situation ,situation (#$the ,role #$of ,instance)))
    (km-k `(#$the ,role #$of ,instance)))
  )

(defun get-roles-and-vals (instance situation)
  (get-slotsvals instance 'own-properties situation)
  )

(defun get-add-list (instance situation)
  (get-role-values instance '#$add-list situation))

(defun get-del-list (instance situation)
  (get-role-values instance '#$del-list situation))

(defun get-concept-definition-info (instance) ;; two level up
  (let* ((concepts (get-concepts-from-instance instance))
	 (superclasses (km-k `(#$the #$superclasses #$of ,concepts)))
	 (result nil))
    (dolist (concept (union concepts superclasses))
      (setq result (append result
			   (get-slotsvals concept 'member-properties 'user::|*Global|)))
      )
    result
    )
  )
  

(defun assert-role-value (instance role val)
  (km-k `(,instance #$has (,role (,val)))))

;; to prevent unification
(defun assert-another-role-value (instance role val)
  (km-k `(,instance #$also-has (,role (,val)))))

(defun get-concepts-from-instance (instance)
  (km-k `(#$the #$instance-of #$of ,instance)))

(defun get-concept-from-instance (instance)
  (km-unique-k `(#$the #$instance-of #$of ,instance)))

(defun get-subclasses (concept)
  (km-k `(#$the #$subclasses #$of ,concept))
  )

(defun subconcept? (sub super)
  ;(format t ":triple ~S all-super-classes ~S~%" sub super)
  (test-expr `(#$:triple ,sub #$all-superclasses ,super))
  )

(defun get-concept-name (step)
  (get-concept-from-instance step))

(defvar *all-subconcepts-used* nil)
(defun get-all-subconcepts (concepts)
  (let ((look-up-result (assoc concepts *all-subconcepts-used*)))
    (cond ((null look-up-result)
	   (let ((result (km-k `(#$the #$all-subclasses #$of ,concepts))))
	     (setq *all-subconcepts-used*
		   (acons concepts result *all-subconcepts-used*))
	     result))
	  (t ;(format t "~% lookup: concept found ~S~%" concepts)
	     (cdr look-up-result)))
  ))

(defun get-inverse (role)
  (km-unique-k `(#$the #$inverse #$of ,role)))

(defun create-a-thing ()
  (create-instance '#$Thing))

(defun create-a-state ()
  (create-instance '#$State))

(defun isa-state (obj)
  (isa-class obj '#$State)
  )

(defun isa-event (obj)
  (isa-class obj '#$Event)
  )

(defun isa-class (obj class)
  (and (not (member obj *reserved-keywords*))
       (test-expr `(#$:triple ,obj #$instance-of ,class)))
  )

(defun get-role-description (obj role)
  (or (caar (inherited-rule-sets obj role))
      (caar (own-rule-sets obj role)))
  )

(defun get-role-descriptions (obj role)
  (or (car (inherited-rule-sets obj role))
      (car (own-rule-sets obj role)))
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

(defun find-situation (instance)
  (find-situation-1 instance (all-situations)))
(defun find-situation-1 (instance situations)
  (cond ((null situations)
	 nil)
	((equal (first situations) *global-situation*) ;; skip global situation
	 (find-situation-1 instance (rest situations)))
	(t (if (get-roles-and-vals instance (first situations))
	       (first situations)
	     (find-situation-1 instance (rest situations))))
	 )
  )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  expressions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun equal-objects (obj1 obj2)
  (km-k `(,obj1 #$= ,obj2)))

(defun test-expr (expr &optional (situation nil))  ;; test a triple
    (if situation 
	(km-k `(#$in-situation ,situation (#$is-true ,expr)))
      (km-k `(#$is-true ,expr))))
#|  
(defun test-expr (expr &optional (situation nil))  ;; test a triple
  (if (numberp (get-object expr))
      (evaluate-arithmetic-expr (rest expr))
    (if situation 
	(km-k `(#$in-situation ,situation (#$is-true ,expr)))
      (km-k `(#$is-true ,expr))))
  )
|#

(defun evaluate-expr (expr &optional (situation nil))
   (if (inequality-role expr) 
        expr
        (if situation
          (km-k `(#$in-situation ,situation ,expr))
          (km-k `(,expr)))
    ))

(defun has-value (result)
  (km-k `(#$has-value , result)))

(defun evaluate-arithmetic-expr (expr)
  (let ((operator (second expr)))
    (case operator
      (#$is-less
       (evaluate-expr (list (first expr) '< (third expr))))
      (#$is-less-or-equal
       (evaluate-expr (list (first expr) '<= (third expr))))
      (#$is-greater
       (evaluate-expr (list (first expr) '> (third expr))))
      (#$is-equal
       (evaluate-expr (list (first expr) '= (third expr))))
      (#$is-not-equal
       (evaluate-expr (list (first expr) '/= (third expr))))
      (#$is-greater-or-equal
       (evaluate-expr (list (first expr) '>= (third expr))))
      ))
  )
(defun show-triples (triples)
  (dolist (triple triples)
    (let ((object (get-object triple)) 
	   (role (get-role triple))
	   (val (get-val triple))
	   )
    (kanal-format "~% ~S : (~S ~S ~S)" triple
		  (if (atom object) object (evaluate-expr object))
		  (if (atom role) role (evaluate-expr role))
		  (if (atom val) val (evaluate-expr val)))
    )))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; preconditions & effects
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun get-preconditions (event)
  (remove-if #'triple-too-general
	     (remove-duplicates (km-k `(#$the #$pcs-list #$of ,event)) :test #'equal))
  )
(defun get-soft-preconditions (event)
  (remove-if #'triple-too-general
	     (remove-duplicates (km-k `(#$the #$soft-pcs-list #$of ,event)) :test #'equal))
  )

(defun get-assertions (action-instance)
  (get-role-values action-instance '#$add-list))

(defun get-deletions (action-instance)
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

(defun get-all-core-actions ()
  (set-difference
   (km-k `#$(the all-subclasses of Action))
   (km-k `#$(the all-subclasses of Domain-Concept))))

(defun get-all-states ()
  (km-k `#$(the all-subclasses of State)))

(defun get-concept-action ()
  (km-k `#$(Action))  )

(defun check-object (obj)
  (km-k `(#$showme ,obj))) 

(defun print-concept (concept)
  (princ (write-frame concept) *kanal-log-stream*)
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
      (when (not (numberp obj))
	(if situation 
	    (km-k `(#$in-situation ,situation ((#$a #$Thing #$with (,role (,val))) #$& ,obj)))
	  (km-k `((#$a #$Thing #$with (,role (,val))) #$& ,obj)))
	)))

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

(defun pretty-print-error-item (error-item)
  (let ((type (cdr (assoc 'type error-item)))
	(source (cdr (assoc 'source error-item)))
	(constraint (cdr (assoc 'constraint error-item)))
	)
    (case type
      ((:inexplicit-precondition :inexplicit-soft-precondition)
       (let ((triple (first constraint))
	     (failed-step source))
	 (kanal-html-format "NOTE: For step ~S the following was not known to be either true or false, but we assume it is true:<br> ~S" failed-step triple)
	 ))
      ((:precondition :soft-precondition)
       (let ((triple (first constraint))
	     (failed-step source))
	 (kanal-html-format "ERROR: For step ~S the following was not true:<br> ~S" failed-step triple)
	 ))
      (:unnecessary-link
       	 (kanal-html-format "NOTE: These seemed to be unnecessary ~S given the definitions currently I have about the steps<br> ~S <br> " constraint source)
	 )
      (:unreached-events
       	 (kanal-html-format "NOTE: These steps ~S were not reached in simulating the path ~S <br> " constraint source)
	 )
      (:missing-first-subevent
       	 (kanal-html-format "ERROR: the first-subevent of ~S isn't defined<br>~%" (first source))
	 )
      (:missing-subevent
       	 (kanal-html-format "ERROR: ~S is the first-subevent but not subevent of ~S<br>~%"
			    (second source)
			    (first source))
	 )
      (:not-parallel
       (kanal-html-format "ERROR: There is an ordering between parellel steps: (~S before ~S)<br>~%"
			  (first source)
			  (second source))
       )
      (:missing-link
       	 (kanal-html-format "ERROR: the ~S link of ~S isn't defined<br>~%" constraint source)
	 )
      (:no-effect
       	 (kanal-html-format "NOTE: no effect was produced by the ~S step<br>~%" source)
	 )
      (:expected-effect
       	 (kanal-html-format "NOTE: Expectation failed:<br> ~S was not achieved<br>~%" constraint)
	 )
      (:expected-effect-for-step
       	 (kanal-html-format "NOTE: Expectation failed:<br> ~S was not achieved<br>~%" constraint)
	 )
      (:undoable-event
       	 (kanal-html-format "ERROR: Steps ~S were undoable<br>~%" source)
	 )
      (:cannot-delete
       	 (kanal-html-format "NOTE: ~S could not be deleted because it was not true in executing ~S<br>~%" constraint source)
	 )
      (:not-exist
       (kanal-html-format "ERROR: ~S isn't defined<br>~%" constraint)
       )
      (:invalid-expr
       (kanal-html-format "ERROR: ~S is null <br>~%" constraint)
       )
      (:loop
       (kanal-html-format "NOTE: Loops were found:<br> ~S <br>~%" constraint)
       )
      (:max-loops
       (kanal-html-format "NOTE: The limit on maximum number of loops [~S] was violated <br> ~S <br>~%" *maxloops* constraint)
       )
      (:temporal-loop
       (kanal-html-format "NOTE: Temporal loop found: <br> ~S <br>~%" constraint)
       )
      (otherwise (kanal-html-format "~%<p>~S</p>~%" error-item))
      )
    )
  )

(defun too-general (obj)
  (member 'user::|Tangible-Entity| (get-concepts-from-instance obj)))
(defun triple-too-general (triple)
  (let ((obj (get-object triple))
	(val (get-val triple)))
    (or (and (atom obj)
	     (too-general obj))
	(and (atom val)
	     (too-general obj))))
  )

;;; ======================================================================
;;;		API to Shaken
;;; ======================================================================

(defvar *kanal-log-stream* nil)
(defvar *kanal-html-file-stream* nil)
(defvar *test-with-closed-world-assumption* t)
(defvar *current-results* nil)
(defvar *old-model-instance* nil)

(defun init-kanal ()
  (setq *kanal-log-stream* (make-string-output-stream)) 
  ;(setq *kanal-log-stream* *trace-output*)
  (build-action-table)
  (build-state-table))

;; SRI wanted to pass skolem instance instead of concept
(defun test-knowledge (model-info &key (cwa nil) (input-type 'concept) (initial-state t) (cached-results nil))
  (kanal-format "~%~% ===============================================")
  (kanal-format "~% start test-knowledge ~%~S~%~%" (get-time-in-string))

  ;(setq cl-user::*recursive-classification* nil)
  ;(setq cl-user::*indirect-classification* nil)
  ;(setq cl-user::*backtrack-after-testing-unification* nil)

  (let ((cl-user::*recursive-classification* nil)
        (cl-user::*indirect-classification* nil)
        (cl-user::*backtrack-after-testing-unification* nil))

  (cond ((and cached-results *current-results*)
        *current-results*)
      (t 
        (km `(#$no-sanity-checks))

        (cond ((equal input-type 'concept)
	   (print-concept model-info)
	   (setq *model-to-test* model-info)
	   (setq *current-model-instance* nil)
	   (setq *start-situation* nil)
	   )
	(t ; input-type is 'instance
	   (let ((model-instance (first model-info))
	       (start-situation (second model-info)))
	     (setq *current-model-instance* model-instance)
	     (setq *model-to-test* (get-concept-from-instance model-instance))
	     (when (null start-situation)
	       (setq start-situation (find-situation model-instance))
	       (when (null start-situation) ;; situation not still found
	         (goto-global-situation)
	         (setq start-situation (create-situation))))
	     (setq *start-situation* start-situation)
	     ;; Assuming that shaken will setup the initial state
	     (print-concept *model-to-test*))
	   ))
      (setq *initial-state-specified* initial-state)
      (setq *events-already-checked* nil)
      (kanal-html-format "<html><title>Knowledge analysis</title><body bgcolor=\"#ffffff\">")
      (init-test)
      ;(setq *kanal-verbose* t)
      (setq *all-subconcepts-used* nil)
  
      (setq *interaction-mode* 'no-interaction)
      ;(setq *execution-mode* 'primitive-steps-only)
      ;; Ken Barker asked for this. Jim.
      (setq *execution-mode* 'all-steps)
      (if (null cwa) 
          (setq *test-with-closed-world-assumption* nil)
        (setq *test-with-closed-world-assumption* t)
        )
   
      (initialize-test-options)
      (test-process-model)
      (kanal-format "~% Test Output ~%~S" (append *error-checker-items* *info-items*))
      ;(show-all-error-checker-items-and-fixes)
      (kanal-html-format "~%</body></html>~%")
      (format t "~% adding event info after simulation ------~%")
      (add-event-info-after-simulation)
      (format t "~%----- KANAL simulation complete.... rendering into XML ------~%~%")
      (setq *current-results* (append *error-checker-items* *info-items*))
      ))
  )
)

;;; I find this a useful entry function. Jim

(defun test-to-file (concept file &optional html-file)
  (with-open-file (*kanal-log-stream* file :direction :output
			        :if-exists :rename-and-delete)
    (cond (html-file
	 (with-open-file (*kanal-html-file-stream* html-file :direction :output
					   :if-exists :rename-and-delete)
		       (test-knowledge concept)))
	(t
	 (setf *kanal-html-file-stream* nil)
	 (test-knowledge concept)))))


(defun get-proposed-fixes (error-id)
  (kanal-format "~%~% --------------------")
  (kanal-format "~% ~S -- Getting fixes for ~S~%" (get-time-in-string) error-id)
  ;;(kanal-html-format "Getting fixes for ~S<br>~%" error-id)
  (setq *fix-items* nil)
  (setq *error-report-silent* t)
  (let* ((error-item (find-error-item error-id))
	 (type (cdr (assoc 'type error-item)))
	 (source (cdr (assoc 'source error-item)))
	 (sourcec nil))
    (if (listp source)
        (setq source (first source)))
    (setq sourcec (evaluate-expr `(#$the #$instance-of #$of ,source)))
    ;(format t "sources : ~S ~S~%" source sourcec)
    (if (cdr (assoc 'success error-item))  ;; no need to fix
	nil
      (case type
	((:precondition :inexplicit-precondition :soft-precondition :inexplicit-soft-precondition)
	 (generate-general-fix-item "Add steps that can achieve the failed condition")
	 (generate-general-fix-item "Modify previous steps so that they achieve the failed condition")
	 (generate-general-fix-item "Check if some previous steps delete the condition, then change the ordering so they occur after the current step")
	 (generate-general-fix-item "Check the role assignments and modify the current step")
	 ;(generate-general-fix-item "Modify the current step")
	 (generate-general-fix-item "Create a special case of the action" ':edit-background-k sourcec)

	 (find-fixes-for-failed-precondition
	  (first (cdr (assoc 'constraint error-item))) ;; triples
	  source)
	 )
	(:expected-effect
	 (generate-general-fix-item "Add steps that can achieve the effect")
	 (generate-general-fix-item "Modify previous steps so that they achieve the effect")
	 (generate-general-fix-item "Check the ordering among the steps to see if some previous steps undo the condition")
	 (generate-general-fix-item "Create a special case of the action" ':edit-background-k sourcec)

	 (find-fixes-for-unachieved-effect
	  (first (cdr (assoc 'constraint error-item))) nil) ;; triples
	 )
	(:expected-effect-for-step
	 (generate-general-fix-item "Add steps that can achieve the effect")
	 (generate-general-fix-item "Modify previous steps so that they achieve the effect")
	 (generate-general-fix-item "Check the ordering among the steps to see if some previous steps undo the condition")
	 (generate-general-fix-item "Check the role assignments and modify the current step")
	 (generate-general-fix-item "Create a special case of the action" ':edit-background-k sourcec)

	 (find-fixes-for-unachieved-effect
	  (first (get-field 'constraint error-item)) (first (get-field 'source error-item)) )
	 )
	(:undoable-event
	 (generate-general-fix-item "Add or modify next-event/subevent/first-subevent links among the steps")
	 ;(find-fixes-for-undoable-event source)
	 )
	(:missing-link
	 (generate-general-fix-item "Specify the role value of the object")
	 (find-fixes-for-missing-link (cdr (assoc 'constraint error-item)) source)
	 )
	(:missing-first-subevent
	 (generate-general-fix-item "Specify the first-subevent of the event")
	 (find-fixes-for-missing-first-subevent source)
	 )
	(:missing-subevent
	 (generate-general-fix-item "Make the first-subevent a subevent of the event")
	 (find-fixes-for-missing-subevent source)
	 )
	(:cannot-delete
	 (generate-general-fix-item "Modify the role assignments of the step")
	 (generate-general-fix-item "Modify previous steps to assert the condition")
	 (find-fixes-for-delete-error (cdr (assoc 'constraint error-item)) source)
	 )
	(:unreached-events
	 (generate-general-fix-item "Add or modify next-event/subevent/first-subevent links among the steps so that they refer to the unreached steps")
	 ;(find-fixes-for-unreached-events (cdr (assoc 'constraint error-item)) source)
	 )
	(:no-effect
	 (generate-general-fix-item "Modify the role assignments of the step")
	 (generate-general-fix-item "Modify the step")
	 (find-fixes-for-effectless-event source)
	 )
	(:invalid-expr
	 (find-fixes-for-invalid-expr (cdr (assoc 'constraint error-item)) source)
	 )
	(:not-exist
	 (generate-general-fix-item "Specify the role value of the object")
	 (find-fixes-for-not-exist (cdr (assoc 'constraint error-item)) source)
	 )
	(:loop
	 (generate-general-fix-item "Modify or delete the next-event links among the steps involved in the loop")
	 (find-fixes-for-loop (cdr (assoc 'constraint error-item)) source)
	  )
	(:not-parallel
	 (generate-general-fix-item "Modify or delete the next-event links between the parallel events")
	 (find-fixes-for-not-parallel-events source)
	  )
	(:unnecessary-link
	 (generate-general-fix-item "Modify or delete next-event constraint")
	 (find-fixes-for-unnecessary-link  (cdr (assoc 'constraint error-item)) source)
	 )
	)
      ))
  (setq *error-report-silent* nil)
  (kanal-format "~% FIX ITEMS ~%~S" *fix-items*)
  (kanal-html-format "<br>Fix details: <ul>~{<li>~S</li>~%~}</ul>~%"
		 *fix-items*)
  *fix-items*
  )

  ;; km does not give full info of event before execution(?)
(defun add-event-info-after-simulation ()
  (dolist (path *paths-simulated*)
    (dolist (event-info path)
      (let ((event (get-event event-info))
	    (prev-situation (get-prev-situation event-info))
	    (next-situation (get-next-situation event-info))
	    )
	(generate-info-item :event-info-before-execution
			    (clean-roles-and-vals
			     (get-roles-and-vals event prev-situation))
			    (list event prev-situation))
	;(format t "over here ~S~%" prev-situation)
	;(check-step-effects (get-add-list event prev-situation)
	;                    (get-del-list event prev-situation) event 
	;		     prev-situation next-situation)
	))))

(defun clean-roles-and-vals (roles-and-vals)
  (let ((result nil))
    (dolist (role-vals roles-and-vals)
      (let ((role (first role-vals))
	    (vals (second role-vals)))
	(when (not (or (equal role '#$pcs-list)
		       (equal role '#$soft-pcs-list)
		       (equal role '#$add-list)
		       (equal role '#$del-list)))
	  (setq vals (remove-if #'too-general
				vals))
	  (if vals (setq result (append result (list (list role vals)))))
	  )
       ))
    result
    ))
		   

(defun property-value-p (instance)
    (if (and instance (not (listp instance)))
    (let ((conceptlist (get-role-values-with-checking "instance-of" instance nil))
          (returnval nil))
          ;(format t "Checking conceptlist ~S~%" conceptlist)
	  (dolist (concept conceptlist)
                  (if (subconcept? concept '#$Property-Value)
		      (setq returnval t)))
	  returnval
     ))
)

(defun engagement-military-task-p (instance)
    (if instance
    (let ((conceptlist (get-role-values-with-checking "instance-of" instance nil))
          (returnval nil))
          ;(format t "Checking conceptlist ~S~%" conceptlist)
	  (dolist (concept conceptlist)
                  (if (subconcept? concept '#$Engagement-Military-Task)
		      (setq returnval t)))
	  returnval
     ))
)


;; Additions for the expected effects interface

(defvar *kanal-expected-effects* nil)
(defvar *kanal-units* nil)
(defvar *kanal-places* nil)
(defvar *kanal-subevents* nil)

(defun get-all-military-units (instance)
   (let ((participants (get-role-values-with-checking "participants" instance nil)))
         (remove-if-not #'military-unit-p participants)))


(defun get-all-places (instance)
   (let ((participants (get-role-values-with-checking "participants" instance nil)))
         (remove-if-not #'is-a-place participants)))


(defun get-expected-effects-data (instance)
    ;; Make sure that those steps which are to be unified are not shown
    ;(get-events-to-be-removed instance)
    (let ((subevents nil)
          (units nil)
          (places nil))
          (cond (*kanal-units*
                 (setq units *kanal-units*)
                 (setq places *kanal-places*)
                 (setq subevents *kanal-subevents*))
                (t
                 (setq *kanal-units* (setq units (get-all-military-units instance)))
                 (setq *kanal-places* (setq places (get-all-places instance)))
                 (setq *kanal-subevents* (setq subevents (get-all-subevents instance)))
          ))
          (list (list ':effects *kanal-expected-effects*)
                (list ':subevents subevents)
	        (list ':units units)
		(list ':places places))
     ))


(defun my-string-to-list (str)
   (cond ((not (stringp str)) 
          str)
         (t
           (do* ((stringstream (make-string-input-stream str))
                 (result nil (cons next result))
                 (next (read stringstream nil 'eos)
                       (read stringstream nil 'eos)))
                ((equal next 'eos) (reverse result)))
          )
    ))


(defun kanal-change-effect (effect op)
     (setq effect (car (my-string-to-list (format nil "#$~A" effect))))
     (setq *old-model-instance* *current-model-instance*)
     (cond ((string-equal op 'add)
            ;; Remove if this is a duplicate
            (setq *kanal-expected-effects*
               (remove-if #'(lambda (ef) (equal effect ef)) *kanal-expected-effects*))
            (setq *kanal-expected-effects* (append *kanal-expected-effects* (list effect))))
           ((string-equal op 'delete)
            (dolist (eff effect)
               (setq *kanal-expected-effects*
                  (remove-if #'(lambda (ef) (equal eff ef)) *kanal-expected-effects*))))
           (t
            (setq *kanal-expected-effects* nil)
            (setq *kanal-units* nil)
            (setq *kanal-places* nil)
            (setq *kanal-subevents* nil)
           ))
)

(defun convert-roles-to-eng (effect) 
    (let ((role (third effect)))
       (case role
         (#$> (setq role '#$greater-than))
         (#$< (setq role '#$less-than))
         (#$>= (setq role '#$is-greater-or-equal))
         (#$<= (setq role '#$is-less-or-equal))
         (#$= (setq role '#$is-equal))
         (#$/= (setq role '#$is-not-equal))
       )
       (list (first effect) (second effect) role (fourth effect))
    ))

(defun convert-roles (effect) 
    (let ((role (third effect)))
       (case role
         (#$greater-than (setq role '>))
         (#$less-than (setq role '<))
         (#$is-greater-or-equal (setq role '>=))
         (#$is-less-or-equal (setq role '<=))
         (#$is-equal (setq role '=))
         (#$is-not-equal (setq role '/=))
       )
       (list (first effect) (second effect) role (fourth effect))
    ))
            
;; Tries to return expected effects entered from 
;; the COA expected effect selection interface, otherwise returns
;; the standard SRI expected effects
(defun get-kanal-expected-effects-for-event (model event)
    (cond ((is-a-type model '#$COA)
           (mapcar #'convert-roles
	           (remove-if #'(lambda (ef) (equal ef nil))
                      (mapcar #'(lambda (effect) 
                        (if (equal (first effect) event)
                           (second effect))) *kanal-expected-effects*))))
          (t 
           (get-expected-effects-for-event model event))
    ))

