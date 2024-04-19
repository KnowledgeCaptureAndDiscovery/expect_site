(in-package "EXPECT")
(export '(def-expect-action))

;;; *************************************
;;; Switches for the Matcher: ***********
;;; *************************************

(defun mt-verbose ()
  (setq *mt-verbose* t)
  t)

(defun mt-very-verbose ()
  (setq *mt-verbose* 2)
  t)

(defun mt-quiet ()
  (setq *mt-verbose* nil)
  t)

(defun mt-verbose-p ()
  *mt-verbose*)

(defun mt-very-verbose-p ()
  (and *mt-verbose*
      (equal *mt-verbose* 2)))




;;; ************************************************************************
;;; ************************************************************************
;;;
;;;               EXPECT PLAN GOAL MATCHER
;;;
;;; The top level call to the matcher is the function match-goal below.
;;;
;;;    example: (mt-match-goal '(find-seaports (obj (inst-of location))))
;;;
;;; The function mt-match-goal has a goal as an argument.  It is called from 
;;; the problem solver, and it returns ONE plan structure and ONE list of
;;; bindings for the plan.
;;; 
;;; It calls find-matches, which parses the goal, translates it, and looks
;;; for both exact and more general matches.  mt-match-goal picks the first
;;; one, which is the one that is more specific.  find-matches is based
;;; on the function find-and-match.
;;; -----------------------------------------------------------------------
;;; 
;;; (matching) starts a menu-based dialogue with the relaxed matcher.
;;; -----------------------------------------------------------------------
;;; 
;;; There is a sample demo for the matcher and the relaxed 
;;; matcher in trace.txt and trace-relaxed.txt.
;;; -----------------------------------------------------------------------
;;; 
;;; goal-structures.lisp contains structures for creating a list of 
;;; achievable goals (one for each plan).  
;;; 
;;; The function new-achievable-goal with arguments (plan-name
;;; capability-description) parses and creates a new goal structure
;;; together with its Loom representation, and adds it to the list of
;;; achievable goals.
;;; 
;;; The function delete-achievable-goal plan-name deletes a goal.
;;;
;;; def-expect-action is what should be used to define actions 
;;; that do not have plans associated with them.  
;;;
;;;    example: (def-expect-action  'calculate :is 'expect-action)
;;;             (def-expect-action  'find-airport :is 'find)
;;;
;;; ************************************************************************
;;; ************************************************************************


(defun shared-mt-get-goal-tree ()
  ;;(loom-get-concept 'expect-action)
  ;; kb-functions all take the symbol too, and get-concept isn't
  ;; currently available from kb-functions.
  'expect-action)

(defun shared-mt-find-plan-in-goal-concept (goal)
  (first (kb-get-values 'plan-annotation goal)))



(defun shared-mt-match-goal (goal)
  (when (mt-verbose-p)
    (format *terminal-io* "~%shared-mt-match-goal: goal: ~s~%" goal))

  (let* ((found (find-matches goal))
         (exact (car found))
         (first-exact (car exact)))	; pick the first of the plans matched
    (when (mt-very-verbose-p)
      (format *terminal-io* "~%shared-mt-match-goal: found ")
      (pprint found *terminal-io*))
    (if first-exact
        (let* ((achievable-structure (first first-exact))
	     (bindings (second first-exact)))
	(when (mt-verbose-p)
	  (format *terminal-io* "~%shared-mt-match-goal: exact ~s~%"
		first-exact)
	  (format *terminal-io* "~%shared-mt-match-goal: bindings ~s~%"
		bindings))
	(let* ((ps-plan (find-ps-plan (get-achievable-goal-name achievable-structure)))
	       (b-noduplicates (reverse-translate-bindings bindings))
	       (b-fixedduplicates (fix-duplicates-in-sets goal b-noduplicates ps-plan)))
	  (list ps-plan b-fixedduplicates)))
       nil)
    ))

(defun fix-duplicates-in-sets (goal b-noduplicates ps-plan)
  (let ((possible-set (eq 'SET-OF-INST (caadar b-noduplicates)))
        (dup-list (cadadr goal)))
    (if possible-set
        (list (list (first (first b-noduplicates)) (list (first (second (first b-noduplicates))) (cadadr goal))))
      b-noduplicates))
)


(defun find-matches (goal &optional (get-more-general nil))
  (when (mt-verbose-p)
    (format *terminal-io* "~%find-matches: goal: ~s~%" goal))

  (let ((concept (gethash goal *goal+concepts-tbl*))) 
    (cond (concept
	 (when (mt-very-verbose-p)
	   (format *terminal-io*
		 "~%find-matches: from hash table: ~s~%" concept))
	 concept)
	(t 
	 (setq concept (find-matches1 goal get-more-general))
	 (when concept
	   (setf (gethash goal *goal+concepts-tbl*) concept)
	   (when (mt-very-verbose-p)
	     (format *terminal-io*
		   "~%find-matches: from loom hierarchy: ~s~%" concept))
	   concept)))))


(defun find-matches1 (goal &optional (get-more-general nil))
  (let ((parsed-goal (parse-goal goal)))
    (when (mt-very-verbose-p)
      (format *terminal-io* "~%find-matches1: parsed-goal ~s~%" parsed-goal))
    (when parsed-goal
      (let*
	((translated-goal (translate-action parsed-goal))
	 (goal-con (kb-define-concept nil translated-goal))
	 (achievable-goals
	  (find-achievable-goals translated-goal goal-con get-more-general))
	 (exact (first achievable-goals))
	 (more-general (second achievable-goals)))
        (when (mt-very-verbose-p)
	(format *terminal-io* "~%find-matches1: exact ~s~%" exact)
	(format *terminal-io* "~%find-matches1: more-general ~s~%"
	        more-general))
        (setq exact (match-goal-list exact goal-con))
        (when get-more-general 
	(setq more-general (match-goal-list more-general goal-con)))
        (when (mt-very-verbose-p)
	(format *terminal-io* "~%find-matches1: returned ~s~%"
	        (list exact more-general)))
        (list exact more-general)))))

(defun reverse-translate-bindings (b)
  (mapcar #'(lambda (binding)
	    (list (first binding)
		(reverse-translate (first (second binding)))))
	b))


(defun reverse-translate (con)
  (when (mt-verbose-p)
    (format *terminal-io* "~%reverse-translate: con: ~s~%" con))

  (let ((description-type (description-type con))
        (description-concept (description-concept con))
        (description-names nil))
    (cond ((eql 'INSTANCE-DESCRIPTION description-type)
	 `(inst-of ,description-concept))
	((eql 'CONCEPT-DESCRIPTION description-type)
	 `(spec-of ,description-concept))
	((eql 'INSTANCE-SET description-type)
	 `(set-of (inst-of ,description-concept)))
	((eql 'CONCEPT-SET description-type)
	 `(set-of (spec-of ,description-concept)))
	;; Altered to only call description-names if it will be used.
	(t (setf description-names (description-names con))
	   (cond ((eql 'SPECIFIC-INSTANCE-DESCRIPTION description-type)
		`(inst ,(first description-names)))
	         ((eql 'SPECIFIC-CONCEPT-DESCRIPTION description-type)
		`(desc ,(first description-names)))
	         ((eql 'EXTENSIONAL-INSTANCE-SET description-type)
		`(set-of-inst ,description-names))
	         ((eql 'EXTENSIONAL-CONCEPT-SET description-type)
		`(set-of-desc ,description-names))
	         )))))


; ************************************************************************

(defun shared-mt-initialize-matcher ()
  (clrhash *goal+concepts-tbl*)
  (setq *achievable-goals* nil))

(defun shared-mt-initialize-search ()
  (clrhash *goal+concepts-tbl*))

(defun shared-mt-load-expect-defs ()
  (let ((*standard-output* *terminal-io*)
        (*error-output* *terminal-io*))
    (load (make-pathname :name "loom-base.lisp" 
                         :directory (append (pathname-directory *expect-pathname-default*)
                                      (list "matcher"))))))
;;
;; create a new achievable goal structure and add it to the list
;; of *achievable-goals*, if goal name is not defined, it will 
;; define it as an EXPECT-action.
;;
(defun shared-mt-new-achievable-goal (plan-name action-form)
  (when (mt-verbose-p)
    (format *terminal-io* "~%shared-mt-new-achievable-goal: plan-name: ~s~%"
	  plan-name))
  (when (mt-very-verbose-p)
    (format *terminal-io* "~%shared-mt-new-achievable-goal: action-form: ~s~%"
	  action-form))
  
  ;; action-form = capability
  (setq *mt-errors* nil)
  (cond ((not (and (symbolp plan-name) (listp action-form)))
         ;;(format *terminal-io* "~%not a legal form - by MT. ~%")
         (signal-mt-parser-error 'no-mt-parse-found plan-name action-form))
        (t
         (unless (kb-concept-p (first action-form))
	 (def-expect-action (first action-form) :is 'Expect-Action))
         (let ((ag (create-achievable-goal plan-name action-form)))
	 (unless *mt-errors*
	   (add-achievable-goal ag)))))
  *mt-errors*)

;; when called, a plan-name is pased, so plan-name = goal-name
(defun shared-mt-remove-achievable-goal (goal-name)
  (when (mt-verbose-p)
    (format *terminal-io* "~%shared-mt-remove-achievable-goal: goal-name: ~s~%"
	  goal-name))

  (setq *achievable-goals* 
        (delete-if #'(lambda (elt)
		   (when (equal (first elt) goal-name)
		     ;; delete the loom concept for the goal-name
		     (kb-delete-object
		      (get-achievable-goal-concept (second elt)))
		     t))
	         *achievable-goals*)))


;; ***********************************************************************
;; ***********************************************************************
;; ***********************************************************************  

(defun mt-match-goal-new (x)

  ;; ##################################################################
  ;; ##################################################################
  ;; NOTE: This is a huge hack that was needed to deal with NIL as
  ;;        an argument to goals.  Currently, the matcher is not
  ;;        able to represent NIL as a goal parameter.  -- yg 12/20/95
  ;; ###########
  ;; begin hack

  (cond ((equal x '(DETERMINE-WHETHER-THERE-ARE-NO (OBJ NIL)))
         (when (ps-verbose-p)
	     (format *terminal-io* "~% ###### Warning: Using hack by YG in mt-match-goal-new, should be fixed ~% "))
         (list (list (find-ps-plan 'DETERMINE-WHETHER-THERE-ARE-NO)
		 '((?L NIL)))))
        ((equal x '(DETERMINE-WHETHER-THERE-IS-NO (OBJ NIL)))
         (when (ps-verbose-p)
	     (format *terminal-io* "~% ###### Warning: Using hack by YG in mt-match-goal-new, should be fixed ~% "))
         (list (list (find-ps-plan 'DETERMINE-WHETHER-THERE-IS-NO)
		 '((?L NIL)))))
        ((equal x '(THERE-ARE-NOT-ANY (OBJ NIL)))
         (when (ps-verbose-p)
	     (format *terminal-io* "~% ###### Warning: Using hack by YG in mt-match-goal-new, should be fixed ~% "))
         (list (list (find-ps-plan 'THERE-ARE-NOT-ANY)
		 '((?L NIL)))))
        ((equal x '(THERE-ARE-ANY (OBJ NIL)))
         (when (ps-verbose-p)
	     (format *terminal-io* "~% ###### Warning: Using hack by YG in mt-match-goal-new, should be fixed ~% "))
         (list (list (find-ps-plan 'THERE-ARE-ANY)
		 '((?L NIL)))))
        ((equal x '(DETERMINE-WHETHER-THERE-ARE-ANY (OBJ NIL)))
         (when (ps-verbose-p)
	     (format *terminal-io* "~% ###### Warning: Using hack by YG in mt-match-goal-new, should be fixed ~% "))
         (list (list (find-ps-plan 'DETERMINE-WHETHER-THERE-ARE-ANY)
		 '((?L NIL)))))

        ((equal x '(count-the-elements (obj nil)))
         (when (ps-verbose-p)
	 (format *terminal-io* "~% ###### Warning: Using hack by YG in mt-match-goal-new, should be fixed ~% "))
         (list (list (find-ps-plan 'count-the-elements)
		 '((?s nil)))))

        ((and (listp x)
	    (equal (car x) 'determine-whether)
	    (member '(is-a set-member) x :test #'equal)
	    (member '(of nil) x :test #'equal))
         (list (list (find-ps-plan 'set-member)
		 `((?s nil) (?el ,(second (assoc 'obj (cdr x))))
		   (?p set-member)))))

        (t
         (mt-match-goal-new-1 x)))
   
  ;; end hack
  ;; ###########
  ;; ##################################################################
  ;; ##################################################################
  )

(defun mt-match-goal-new-1 (x)
  (convert-from-matcher-format (mt-match-goal (convert-to-matcher-format x))))

(defun convert-to-matcher-format (g)
  (cons (get-verb-goal g)
        (mapcar #'convert-param-to-matcher-format
	      (get-params-goal g))))

(defun convert-param-to-matcher-format (p)
  (list (get-param-name p)
        (convert-edt-to-matcher-format (get-param-edt p))))

;;; This is changed to support the normal matcher.
(defun convert-edt-to-matcher-format (edt)
  (if ;;(intensional-p edt)
      t
      edt
    (cond ((and (instance-based-p edt)
	      (set-p edt))
	 (list 'set-of-inst edt))
	((and (instance-based-p edt)
	      (not (set-p edt)))
	 (list 'inst edt))
	((and (concept-based-p edt)
	      (set-p edt))
	 (list 'set-of-desc edt))
	((and (concept-based-p edt)
	      (not (set-p edt)))
	 (list 'desc edt)))))

(defun convert-from-matcher-format (p+b)
  (when p+b
    (list
     (list (first p+b)
	 (mapcar #'convert-binding-from-matcher-format
	         (second p+b))))))

(defun convert-binding-from-matcher-format (b)
  (list (first b)
        (convert-edt-from-matcher-format (second b))))

(defun convert-edt-from-matcher-format (edt)
  (if (and edt
	 (listp edt)
	 (member (first edt) '(inst desc set-of-inst set-of-desc)))
      (second edt)
    edt))
