;;; ======================================================================
;;;		K analysis
;;; ======================================================================
;;; Copyright (C) 2000 by Jihie Kim


(defvar *expressions-failed* nil)
(defvar *in-k-analysis* nil)
(defvar *test-preconditions* nil)
(defvar *added-effects* nil)
(defvar *deleted-effects* nil)

(defun K-analysis-on ()
  (setq *in-k-analysis* t)
  (setq *expressions-failed* nil)
  (setq *added-effects* nil)
  (setq *deleted-effects* nil)
  )
(defun K-analysis-off ()
  (setq *in-k-analysis* NIL)
  )
(defun test-preconditions-on ()
  (setq *expressions-failed* nil)
  (setq *test-preconditions* t)
  )
(defun test-preconditions-off ()
  (setq *test-preconditions* NIL)
  )

(defun get-preconditions (event)
  (or (caar (inherited-expr-sets event '|is-possible|))
      (caar (own-expr-sets event '|is-possible|)))
  )

(defun test-preconditions (|preconditions|)
  (let ((result nil))
    (test-preconditions-on)
    (setq result (km `#$,preconditions))
    (test-preconditions-off)
    (format t "~%   precondition:~S ~%  --> ~S~%"
	    |preconditions| result)
    result
  ))

(defun test-process-model (|process-model|)
  (K-analysis-on)
  (km `#$(global-situation))
  (let* ((|model-instance| (first (km `#$(a ,process-model))))
	 (|start-situation| (first (km '#$(a Situation))))
	 (events (km `#$(in-situation ,start-situation
			    (the actions of ,model-instance))))
	 (some-action-failed nil)
	 )
    (if (null events)
	(format t "~% there is no substep for ~S" |process-model|)
      (format t "~% all sub-steps: ~S~%" events))
    (km `#$(in-situation ,start-situation))
    (dolist (|event| events)
      (unless some-action-failed
	(format t "~%~%  -----------------------------------------------------------")
	(format t "~%  step: ~S" |event|)
	(format t "~%  -----------------------------------------------------------")
	(let
	    ;; get the precondition description
	    ((eval-results (test-preconditions
			    (get-preconditions |event|))))
	  (cond (eval-results
		 (format t "~% ... execute ~S..." |event|)
		 (km `#$(do-and-next ,event))
		 (format t "~%      deleted ~S" (collect-del-list
						 (km `#$(the del-list of ,event))))
		 (format t "~%      added ~S" (collect-add-list
					       (km `#$(the add-list of ,event))))
		 )
		(t
		 (format t "~% the step was not performed because of unachived preconditions~%")
		 (setq some-action-failed t)
		 (propose-fixes |event| events)
		 )
		)

	  )
	
	)
      
      )
    (format t "~% ************************************************")
    (format t "~%                 overall effects")
    (format t "~%  ************************************************")
    (format t "~%   added:   ~S" *added-effects*)
    (format t "~%   deleted: ~S" *deleted-effects*)    
    (K-analysis-off)
    )
  )

; (minimatch '(|the| |location| |of| |_Virus4|) '#$(the ?slot of ?instance))
;(symbolp '|location|)
(defun find-slots-tested (exprs)
  (let ((slots nil))
    (dolist (expr exprs)
      (cond 
	  ((minimatch expr '#$(the ?slot of ?instance))
	   (setq slots (append slots (list (second expr)))))
	  ((or (eq '= (second expr))
	       (eq '/= (second expr))) ;; equality tests
	   (setq slots (append slots
			       (find-slots-tested (list (first expr)
							(third expr))))))
	  (t nil) ;; do nothing for other expressions, for now
	  )

      )
    slots
    )
  )

(defun find-steps-before (step all-steps)
  (let ((result nil)
	(found nil))
    (dolist (s all-steps)
      (cond ((equal step s)
	     (setq found t))
	    ((not found)
	     (setq result (append result (list s))))
	    (t
	     nil)))
    (if found
	result
      nil))
  )

(defun add-failed-expr (kmexpr)
  (let ((subexpr-found nil))
    (dolist (expr *expressions-failed*)
      (if (member expr kmexpr :test #'equal)
	  (setq subexpr-found t)))
    (unless subexpr-found
      (setq *expressions-failed*
	    (append *expressions-failed*
		    (list kmexpr))))
    )
  )

(defun propose-fixes (failed-step all-steps)
  (format t "~% these are failed descritions:~%")
  (dolist (expr *expressions-failed*)
    (format t "~%  ~S~%" expr)
    )
  (let ((choice (menu-ask "What do you want to fix?" (append *expressions-failed*
							     (list "Go back to main menu")))))
    (cond ((and (stringp choice) (string= choice "Go back to main menu")) t)
	  (t 
	   (format t "~%~% ***** I would propose following fixes for the failure of ~%      ~S ~% " choice)
	   (let ((n_fix 0)
		 (fixes nil)
		 (slots-tested (find-slots-tested (list choice))))
	     
	     (dolist (|slot| slots-tested)
	       (format t "~% ..............................................................")
	       (format t "~%   checking how to change ~S value .. " |slot|)
	       (format t "~% ..............................................................~%")
	       
	       (format t "~%     .. checking if there are missing steps .. ~%")
	       (let ((proposed-actions (km `#$(forall (the subclasses of Change) where ((the affectedSlot of (the affect of (a It))) = ,slot) It))))
		 (dolist (p-action proposed-actions)
		   (format t " proposed fix ~S : add a ~S step before ~S to change the value of ~S~%"
			   (incf n_fix) p-action failed-step |slot|)
		   (setq fixes (append fixes (list (list 'add p-action 'before failed-step))))
		   )
		 (if (null proposed-actions)
		     (format t "       -> no step addition applicable~%"))
		 )

	       (format t "~%     .. checking if ordering changes may fix the problem .. ")
	       (let* ((|actions-before-failed-step| (find-steps-before failed-step all-steps))
		      (affected-actions (km `#$(forall ,actions-before-failed-step where ((the affectedSlot of (the affect of (a It))) = ,slot) It))))
		 (dolist (a-action affected-actions)
		   (format t "~% proposed fix ~S: check the ordering between step ~S and step ~S~% "
			   (incf n_fix) a-action failed-step)
		   (format t "~%   because ~S changed the value of ~S" a-action |slot|)
		   (setq fixes (append fixes (list (list 'change-ordering a-action failed-step))))
		   )
		 (if (null affected-actions)
		     (format t "~%       -> no ordering change applicable~%"))
		 )
	       (format t "~%")
	       )

	     		       
	     (format t "~% ..............................................................")
	     (format t "~%   checking if there are unnecessary steps .. ~%")
	     (format t " ..............................................................~%")
	     (format t "~% proposed fix ~S:  delete ~S~%" (incf n_fix) failed-step)
	     (setq fixes (append fixes (list (list 'delete failed-step))))
    
	     (let ((choice (menu-ask "What do you want to choose?"
				     (append
				      fixes
				      (list "Go back to main menu" ))
				     )))
	       (cond ((and (stringp choice) (string= choice "Go back to main menu")))
		     (t (perform-fix choice))
		      )

	       )
	     )
	   )
	  )))

(defun perform-fix (fix)
  (format t "~% ..............................................................")
  (format t "~%  the actual fixes are done using Concept Map window")
  (format t "~%    and the menues in the Dialog Window...~%")
  (format t " ..............................................................~%")
  (let ((fix-type (first fix)))  
    (cond ((eq fix-type 'add)
	   (if (eq '|Move| (second fix))
	       (format t "~%  ....sorry...~%    currently, we don't have a model for it~%")
	     (progn
	       (format t "~% assume a ~S step is added properly by the user~%" (second fix))
	       (setq *current-model-name* "NewVirusInvadesCell")
	       ))
	   )
	  ((eq fix-type 'delete)
	   (format t "~%  ....sorry...~%    currently, we don't have a model for it~%")
	   )
	  ((eq fix-type 'change-ordering)
	   )
	  (t
	   t))
    )
  )

(defun generate-number-sequence (n)
  (let ((result nil))
    (dotimes (count n result)
      (setq result (append result (list (+ count 1)))))
  ))

(defun create-an-instance-of-process-model (process-model-name-in-string)
  (km `#$(global-situation))
  (let ((|model| (find-symbol process-model-name-in-string)))
       (first (km `#$(a ,model)))))

(defun get-components-from-instances (steps)
  (let ((result nil))
    (dolist (|step| steps)
      (setq result (append result
			   (list
			    (format nil "~S"
				    (first (km `#$(the instance-of of ,step))))))))
    (remove-duplicates result)
    )
  )

;;; ======================================================================
;;;		Expected Effects
;;; ======================================================================

(defvar *expected-effects* nil)
(defvar *current-model-name*  "VirusInvadesCell")

(defun store-added-effect (effect)
  (setq *added-effect*
	(append *added-effect* (list effect))))

(defun store-deleted-effect (effect)
  (setq *deleted-effect*
	(append *deleted-effect* (list effect))))

(defun effect-equivalent (effect1 effect2)
  (let ((object1 (second effect1))
	(|slot-name1| (third effect1))
	(value1 (fourth effect1))
	(object2 (second effect2))
	(slot-name2 (third effect2))
	(value2 (fourth effect2))
	)
    (format t "~%(~S ~S ~S) vs (~S ~S ~S)" object1 |slot-name1| value1 object2 slot-name2 value2 )
    (and (equal (list slot-name2) (km `#$(the inverse of ,slot-name1)))
	 (equal value1 object2)
	 (equal object1 value2))
    ))
	 
(defun cancelled-equivalent-effect-in-del-list (effect)
  (let ((new-del-list nil)
	(found-equivalent-effect nil))
    (dolist (del-effect *deleted-effects*)
      (if (or (equal effect del-effect)
	      (effect-equivalent effect del-effect))
	  (setq found-equivalent-effect t)
	(setq new-del-list (append new-del-list (list del-effect)))))
    (setq *deleted-effects* new-del-list)
    found-equivalent-effect))
    
(defun cancelled-equivalent-effect-in-add-list (effect)
  (let ((new-add-list nil)
	(found-equivalent-effect nil))
    (dolist (added-effect *added-effects*)
      (if (or (equal effect added-effect)
	      (effect-equivalent effect added-effect))
	  (setq found-equivalent-effect t)
	(setq new-add-list (append new-add-list (list added-effect)))))
    (setq *added-effects* new-add-list)
    found-equivalent-effect))
	
(defun collect-add-list (add-list)
  (dolist (added-effect add-list)
    (unless (cancelled-equivalent-effect-in-del-list added-effect)
      (store-added-effect (added-effect))))
  add-list
  )

(defun collect-del-list (del-list)
  (dolist (deleted-effect del-list)
   (unless (cancelled-equivalent-effect-in-add-list deleted-effect)
      (store-deleted-effect (deleted-effect))))
  del-list
  )

(setq *expected-effects*
      (let ((|current-model| (find-symbol  *current-model-name*)))
  `#$(
      ("The DNA of the virus has replicates"
       (the replicates of (the Dna parts of (the agent of (thelast ,current-model))))
       )

      ("The ProteinCoat of the virus has been broken"
       (the broken of (the ProteinCoat parts of (the agent of (thelast ,current-model))))
       )
      ;("The Virus does not contain its Dna"???
      ; ((the contains of (the agent of (thelast ,current-model))) includes
      ;  (the Dna parts of (the agent of (thelast ,current-model))))
      ;)
      
  )))

(defun modify-expected-effects ()
  
  )

;;; ======================================================================
;;;		Interaction 
;;; ======================================================================

(defun do-test()
  (let* ((choices (if (equal *current-model-name*  "VirusInvadesCell")
		      (list "Test process model" "Add or delete expected effects" "Quit")
		    (list "Test process model" "Reset to the original model" "Quit")))
	 (choice (menu-ask "What do you want to do?" choices)) )
    ;(format t "choice: ~S" choice)
    (cond
     ((string= choice "Test process model") (start-test) (do-test))
     ((string= choice "Add or delete expected effects") (modify-expected-effects) (do-test))
     ((string= choice "Reset to the original model")
      (setq  *current-model-name*  "VirusInvadesCell")
      (start-test) (do-test)
      )
     ((string= choice "Quit"))
     (t t))))

(defun start-test ()

  (km `#$(global-situation))
  ;;; these should be set by the interaction manager  
  
  (let* ((|model| (find-symbol  *current-model-name*))
	 (|model-instance| (first (km `#$(a ,model))))
	 (|start-situation| (first (km '#$(a Situation))))
	 (substeps (km `#$(in-situation ,start-situation
			    (the actions of ,model-instance))))
	 (components (get-components-from-instances substeps))

	 ;; query
	 (step (menu-ask (format nil "What do you want to test for ~A?" *current-model-name*)
			  (append (list |model|) (butlast components)
				  (list "Go back to main menu")))))
    (cond
     ((and (stringp step) (string= step "Go back to main menu"))
      t)
     (t
      (test-process-model step)
      )
     )
    )
  )


;;; ======================================================================
;;;		MENU PROCESSING UTILITIES - by Peter Clark
;;; ======================================================================

(defun menu-ask (title options)
  (print-title title)
  (print-menu options)
  (menu-get options))

(defun print-title (title)
  (terpri)
  (format t title)
  (terpri))

(defun menu-get (options)
  (format t "      -> ")
  (let ( (answer (read)) )
    (cond ((and (integerp answer)
		(> answer 0)
		(<= answer (length options)))
	   (values (elt options (1- answer)) answer))
	  (t (format t "ERROR! You must enter an integer between 1 and ~a!~%~%" (length options))
	     (menu-get options)))))

;;; Returns the length of options
(defun print-menu (options &optional (n 1))
  (cond ((endp options) n)
	(t (cond ((stringp (first options)) (format t "   ~a. ~a~%" n (first options)))
		 (t (km-format t "   ~a. ~a~%" n (first options))))
	   (print-menu (rest options) (1+ n)))))
