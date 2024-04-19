(in-package "EXPECT")

;;; ************************************
;;; build capability tree
;;; build method sub-method tree (global instead of
;;;                               being driven by top-level-goal)
;;; ************************************
;;;
;;; collect undefined goals, and they become system-defined goals
;;; build goal tree, including system-defined-goals.
;;; when there are similar goals, ia create a new system-defined-goal
;;; for a subsumer of the similar goals.

;;;


;; TTD signal error when duplicate exists

(defun find-mkb-method (plan-name)
  (cadr (assoc plan-name *mkb-method-list*)))

;;; **************************************************************
;;; find subgoals in the body and return result type
;;; **************************************************************
(defvar *rfmls-unmatched*)
(defvar *partial-match* nil)
(defvar *system-created-goals* nil)
(defvar *rfml-used* nil)

(defvar *adding-system-defined-goals*)

;;; need to be refined
(defun find-potential-arg-result-type (arg-expr expr)
  (let ((cat (car expr)))
    (cond ((lexicon-goal-p cat)
	   (find-potential-goal-arg-result-type cat))
	  ((or (eq cat 'and) (eq cat 'or) (eq cat 'not))
	   '(inst-of boolean))
	  ((and (eq cat 'if)
		(tree-equal (second expr) arg-expr))
	   '(inst-of boolean))
	  ((and (eq cat 'when)
		(tree-equal (second-expr) arg-expr))
	   '(inst-of boolean))
	  (t 'undefined))
    ))
	
(defun find-potential-goal-arg-result-type (goal-name)
  (cond ((or (kb-subsumes-p 'arithmetic-operation goal-name)
	     (equal goal-name 'is-less-or-equal)
	     (equal goal-name 'count-elements)
	     (equal goal-name 'is-greater-or-equal))
	 '(inst-of number))
	(t 'undefined))
  )

(defun find-subgoals-and-compute-edt (body cap name expected-result)
  (if *mkb-very-verbose*
     (format *terminal-io* "~% START find-subgoals-and-edt ~%  body:~S ~%  cap:~S ~%"
             body cap))
  (let ((temp
  (cond
   ((null body) '())
   ((lexicon-variable-p body)
    (find-edt-for-var body (find-vars-assoc-list cap)))
   ((kb-instance-p body) body)
   ((edt-p body) body)
   ((not (listp body)) 'unknown)  ;; this should not happen!
   ((lexicon-goal-p (car body))
    (let ((param-list (cdr body)) 
	  (simplified-params nil))
      (dolist (param param-list)
	(setq simplified-params
	      (append simplified-params
		  (list (list (first param)
			    (find-subgoals-and-compute-edt (second param)
							   cap name 
							   (find-potential-goal-arg-result-type (car body))))))))
      (let* ((simplified-body (append (list (car body)) simplified-params))
	     (result-obtained
	      (find-result-type-of-goal simplified-body name expected-result)))
	(push (list simplified-body result-obtained) *subgoals*)
	result-obtained)))
      
   ((lexicon-relation-p (car body))
    (let ((param-list (cdr body)) (simplified-params nil))
      (dolist (param param-list)
	;;(format *terminal-io* "~% param:~S" param)
	(setq simplified-params
	      (append simplified-params
		      (list (find-subgoals-and-compute-edt param cap name 'undefined)))))
      ;(format *terminal-io* "~% rel : ~S ~%  simplified params ~S" (car body) simplified-params)
      (let ((edt (find-rel-range-edt (car body)
				     (mapcar #'get-base-concept simplified-params))))
	(if (and (member-of-tree simplified-params 'set-of)
		 (not (set-p edt)))
	    (make-edt-set edt)
	  edt))
      )
    )
   (t (find-subgoals-and-compute-edt-special body cap name expected-result)))
  ))
   (if *mkb-very-verbose*
      (format *terminal-io* "~% find-subgoals-and-edt ~%  body:~S ~%  cap:~S ~% --> ~S"
	      body cap temp))
  temp)
  )


(defun some-args-undefined (args)
  (if (null args)
      nil
    (let ((arg-edt (second (first args))))
	(cond ((or (equal 'undefined arg-edt)
		   (equal '(set-of (undefined)) arg-edt)
		   (equal '(set-of undefined) arg-edt))
	       't)
	      (t (some-args-undefined (rest args)))))))

;;; compute edt of given goal description using mkb-capability-tree
(defun find-result-type-of-goal (goal plan-name expected-result)
  (setq *partial-match* nil)
  ;(format *terminal-io* "********** reset partial-match 1 ")
  ;(format *terminal-io* "~% ### find-result-type-of-goal ~S for ~S" goal plan-name)
  (cond (;;(member 'undefined (mapcar #'second (rest goal)))
	 (some-args-undefined (rest goal))
	 ;; assume 'undefined is the most specific concept of all
	 ;;   and '(any-of thing) is most general
	 (let ((subsumer (find-parent-to-match goal)))
	   (if (not (equal subsumer *mkb-capability-tree-root*))
	       (add-mkb-method-possible-user (get-goal-node-mkb-method subsumer)
					     plan-name)) )
	 'undefined)
	(t ;; args are all defined
	 (setq *rfmls-unmatched* nil)
	 (if *mkb-verbose*
	     (format *terminal-io* "~% *rfmls-unmatched* reset in find-result-type-of-goal"))

	 (let ((subsumers (relaxed-find-parents goal)))
	   (cond ((null subsumers)
		  ;;(format *terminal-io* "~%  create undefined ~S" goal)
		  (create-undefined-goal goal plan-name
					 expected-result *rfmls-unmatched*)
		  (if *mkb-very-verbose*
		      (format *terminal-io* "~% ### *mkb-undefined-goal-list*: ~S"
			      *mkb-undefined-goal-list*))
		  ;(format *terminal-io* "~% add system goal -- ~S" goal)
		  (pushnew goal *system-created-goals* :test #'equal)
		  'undefined
		  )
		 (t
		  (let ((result-edt 'undefined))
		    (dolist (subsumer subsumers)
		      (if *mkb-verbose*
			  (format *terminal-io* "~% ** for subsumer ~S : relaxed? ~S "
				  subsumer *partial-match*))
		      (let ((mkb-method (get-goal-node-mkb-method subsumer)))
			(when (not (null mkb-method)) ;; when not a system defined goal
			  (cond (*partial-match*
				 (pushnew plan-name (mkb-method-possible-users mkb-method))
				 (create-undefined-goal goal plan-name expected-result
							*rfmls-unmatched*)
				 )
				(t
				 (set-mkb-method-possible-users
				  mkb-method
				  (delete plan-name (mkb-method-possible-users mkb-method)))
				 (pushnew plan-name (mkb-method-users mkb-method))
				 ;;**??? should it be combined with the current result??
				 (setq result-edt (mkb-find-common-edt
						   result-edt
						   (get-mkb-method-expected-result
						    mkb-method))))))))
		    (setq result-edt
			  ;; needs to be modified based on *default-preferences*
			  (if (and *rfml-used* ;; from rfml
				   (member 'set *rfml-used*) ;; this is hack
				   (not (eq 'undefined result-edt)))
			      (make-edt-set result-edt) ;; this is wrong
			    result-edt))
			    
		    )))))))


;;; ***************************************************************
;;; find subsumers in mkb-capability-tree
;;; ***************************************************************

(defun get-not-set-result (result-type)
  (cond ((eq 'undefined result-type)
	 'undefined)
	((not (set-p result-type))
	 'undefined)
	((intensional-p result-type)
	 (second result-type))
	(t ;; extensional set
	 (first result-type))))

;; if any of rgoal fails, the whole reformualation fails
;;   and the goal becomes possible-user (instead of users)
;;   of the computed parents 
(defun find-parent-based-on-covering-rfml (rgoals)
  (if (null rgoals)
      nil
    (let* ((rgoal (first rgoals))
	   (parent (find-parent-to-match rgoal))
	   (subsumers
	    (cond ((equal parent *mkb-capability-tree-root*)
		   (find-parents-from-rfml rgoal))
		  (t (list parent))))
	   (other-parents (find-parent-based-on-covering-rfml (rest rgoals))))
      (cond ((null subsumers)
	     (setq *partial-match* t) 
	     (setq *rfmls-unmatched* ;
		   (pushnew (first rgoals) *rfmls-unmatched* :test #'equal))
	     other-parents)
	    (t (union subsumers other-parents :test #'equal))))))

(defun find-parent-based-on-set-rfml (rgoals)
  (if (null rgoals)
      nil
    (let* ((rgoal (first rgoals))
	   (parent (find-parent-to-match rgoal)))
      (cond ((equal parent *mkb-capability-tree-root*)
	     (let ((subsumers
		    (find-parent-based-on-set-rfml (rest rgoals))))
	       (if (null subsumers)
		   (find-parents-from-rfml rgoal)
		 subsumers
		 )
	     ))
	    (t
	     (list parent))))))
	
;;; try reformulation
(defun relaxed-find-parents (sgoal)
  (setq *rfml-used* nil)
  (let ((subsumer (find-parent-to-match sgoal)))
    (cond ((equal subsumer *mkb-capability-tree-root*)
	   ;(setq *rfml-used* '(t)) ;; this is hack
	   (find-parents-from-rfml sgoal))
	  (t
	   (list subsumer)
	     ))
    ))

;; try 1) set, 2) covering or input
(defun find-parents-from-rfml (sgoal)
  (if *mkb-very-verbose*
      (format *terminal-io* "~% rfml for GOAL: ~S" sgoal))
  (let* ((sgoals (mapcar #'caadr 
		  (generate-set-reformulations-for-goal sgoal nil)))
	 (parents-from-set-rfml
	  (find-parent-based-on-set-rfml sgoals)))
    (if *mkb-very-verbose*
        (format *terminal-io* "~% set rfml for ~S ==>  ~S" sgoals parents-from-set-rfml))
    (cond ((and (not *partial-match*)
		(not (null parents-from-set-rfml)))
	   (push 'set *rfml-used*)
	   parents-from-set-rfml)
	  (t
	   (let* ((cgoals-list
		   (mapcar #'cadr
			   (generate-covering-reformulations-for-goal sgoal nil)))
		  (parents-from-covering-rfml
		   (find-parents-from-covering-rfml cgoals-list)))
	     (cond ((and (not *partial-match*)
			 (not (null parents-from-covering-rfml)))
		    (push 'covering *rfml-used*)
		    parents-from-covering-rfml)
		   (t
		    (union parents-from-set-rfml
			   parents-from-covering-rfml :test #'equal))))))
    ))

(defun find-parents-from-covering-rfml (cgoals-list)
  (if (null cgoals-list)
      nil
  (let* ((cgoals (first cgoals-list))
	 (parents (find-parent-based-on-covering-rfml cgoals)))
    (cond ((and (not (null *partial-match*))
		(not (null parents)))
	   parents)
	  (t (find-parents-from-covering-rfml (rest cgoals-list)))))))


;; find most specialized ancester which is defined as a capability
(defun find-defined-subsumer (goal-node)
  (cond ((equal *mkb-capability-tree-root* goal-node)
	 goal-node)
	((eq 't (get-goal-node-defined-p goal-node))
	 goal-node)
	(t (find-defined-subsumer (get-goal-node-parent goal-node))))
  )

;; find most specialized subsumer which is defined as capability of a method
(defun find-parent (sgoal)
  (find-parent-1 sgoal (list *mkb-capability-tree-root*) nil)
  )
  

(defun find-parent-to-match (sgoal)
  (let ((goal-node
	 (find-parent-1 sgoal (list *mkb-capability-tree-root*) nil)))
    (find-defined-subsumer goal-node)
    ))

(defun find-parent-1 (sgoal cands parent)
  (cond ((null cands) parent)
	((or (equal (first cands) *mkb-capability-tree-root*)
	     (goal-subsumed--create-system-goal sgoal
			    (get-goal-node-goal (first cands))))
	 (if *mkb-very-verbose*
	     (format *terminal-io* "~% ~S is subsumed by ~S~%"
		 sgoal (get-goal-node-goal (first cands))))
	 (find-parent-1 sgoal (get-goal-node-children (first cands))
			(first cands)))
	(t (find-parent-1 sgoal (rest cands) parent))))


;; check action name, arg types
(defun goal-subsumed (sub super)
  (let ((superconcepts (kb-get-superconcepts (first sub))))
    (cond ((and (null (rest super)) ;; system defined action-name
		(or (member (first super) superconcepts)
		    (eq (first sub) (first super))))
	   't)
	  ((not (eq (first sub) (first super)))
	   nil) 
	  (t 
	   (args-subsumed (rest sub) (rest super))))))

(defun get-all-super-goal-concepts (goal-concept)
  (let ((result nil)
	(super-concepts
	 (kb-get-superconcepts goal-concept)))
    (dolist (c super-concepts)
      (when (not (eq 'expect-action c))
	(push c result)
	(setq result (union result
			    (get-all-super-goal-concepts c)))))
      result))
	   
;; check goal subsumption,
;; when action name is the same and the args are compatible,
;;   create system goal as a side effect
(defun goal-subsumed--create-system-goal (sub super)
  (if *mkb-very-verbose*
      (format *terminal-io* "~% goal subsumed?: ~S ~S" sub super))
  (let ((super-actions (get-all-super-goal-concepts (first sub))))
    (cond ((and (null (rest super)) ;; system defined action-name
		(or (member (first super) super-actions)
		    (eq (first sub) (first super))))
	   t)
	  ((and (not (member (first super) super-actions))
		(not (eq (first sub) (first super))))     ;; check action-name
	   nil)
	  ((not (args-compatible (rest sub) (rest super)))
	   nil)
	  (t
	   ;; create a subsumer as a goal
	   (cond ((args-subsumed (rest sub) (rest super))
		  t)
		 ((or (member 'undefined (flatten (rest sub)))
		      (member 'undefined (flatten (rest super))))
		  nil)
		 ;;((is-there-inst-or-desc-arg (append (rest sub)
		 ;;(rest super)))
		 ;; nil)
		 (t
		  ;; when adding user-defined goals,
		  ;;  check if add more goals can be added
		  ;;  to organize the goal hierarchy
		  (if (null *adding-system-defined-goals*)
			(create-subsumer-as-system-goal sub super))
		    nil))))))

(defun mkb-find-common-edt-list (args)
  (if (not (listp args))
      'undefined
    (let* ((x (first args))
	 (y (second args))
	 (more-args (cddr args))
	 (result (mkb-find-common-edt x y)))
      (if more-args
	(mkb-find-common-edt-list (cons result more-args))
        result))
    ))

(defun mkb-find-common-edt (arg-a arg-b)
  (let ((a (remove-inst-or-desc arg-a))
        (b (remove-inst-or-desc arg-b)))
    (cond ((or (null a) (equal a 'undefined))
	 b)
	((or (null b) (equal b 'undefined))
	 a)
	((or (equal a '(any-of thing))
	     (equal b '(any-of thing)))
	 '(any-of thing))
	((or (and (concept-based-p a)
		  (instance-based-p b))
	     (and (instance-based-p a)
		  (concept-based-p b))
	     (and (set-p a)
		  (not (set-p b)))
	     (and (not (set-p a))
		  (set-p b)))
	 '(any-of thing))
	(t (find-common-edt a b)))))
	  
	      

(defun common-edt-of-args (args-a args-b)
  ;(format *terminal-io* "~% common-edt-of-args : ~S ~S" args-a args-b)
  (cond ((null args-a) nil)
	(t (append
	      (list (append (list (caar args-a))
			    (list '(any-of thing)))) ;; make simple ones only
	      (common-edt-of-args (rest args-a) (rest args-b))))))
#|
(defun common-edt-of-args (args-a args-b)
  ;(format *terminal-io* "~% common-edt-of-args : ~S ~S" args-a args-b)
  (cond ((null args-a) nil)
	(t (append
	      (list (append (list (caar args-a))
			    (list (mkb-find-common-edt (cadar args-a)
						   (cadar args-b)))));; TTD
	      (common-edt-of-args (rest args-a) (rest args-b))))))
|#
(defun create-subsumer-as-system-goal (sub super)

  (let ((subsumer (append (list
			   (kb-most-specific-subsumer (first sub) (first super)))
			  (common-edt-of-args (rest sub) (rest super)))))
    (when (and (not (equal sub subsumer))
	       (not (equal super subsumer))
	       (not (member subsumer *system-created-goals* :test #'equal)))
      (if *mkb-verbose*
	(format *terminal-io* "~% create-subsumer-as-system-goal : ~S" subsumer)
	)
      (pushnew subsumer *system-created-goals*)
      subsumer))
)

(defun edt-compatible (arg-x arg-y)
  (let ((x (remove-inst-or-desc arg-x))
        (y (remove-inst-or-desc arg-y)))
    (cond ((or (equal x 'undefined)
	     (equal y 'undefined))
	 t)
	((and (listp x)
	      (listp y))
	 (or (equal (first x) (first y))
	     (equal (first x) 'any-of)
	     (equal (first y) 'any-of)))
	((or (and (concept-based-p x)
		(concept-based-p y))
	     (and (instance-based-p x)
		(instance-based-p y)))
	 t)
	((equal x y)
	 t)
	(t nil))))
       
        

(defun args-compatible (args-sub args-super)
  (cond ((and (null args-sub) (null args-super))
	 t)
	((or (null args-sub) (null args-super))
	 nil)
	((not (eq (caar args-sub) (caar args-super))) ; check param name
	 nil)
	((not (edt-compatible (remove-set-of (cadar args-sub))
			  (remove-set-of (cadar args-super))))
	 nil)
	(t 
	 (args-compatible (rest args-sub) (rest args-super)))
))      
(defun remove-set-of (edt)
  (if (intensional-set-p edt)
      (second edt)
    edt))
      
(defun args-subsumed (args-sub args-super)
  (cond ((and (null args-sub) (null args-super))
	 (if *mkb-very-verbose* (format *terminal-io* "~% both null args"))
	 t)
	((or (null args-sub) (null args-super))
	 (if *mkb-very-verbose*
	     (format *terminal-io* "~% one of them null args"))
	 nil)
	((and (eq (caar args-sub) (caar args-super))
	      (equal (mkb-find-common-edt (cadar args-sub) (cadar args-super))
		   (remove-inst-or-desc (cadar args-super))))
	 (if *mkb-very-verbose*
	     (format *terminal-io* "~% subsumed param  ~S ~S"
		 (cadar args-sub) (cadar args-super)))
	 (args-subsumed (rest args-sub) (rest args-super)))

	;; find relaxed match with set rfml;;;
	;;((equal (mkb-find-common-edt (remove-set-of (cadar args-sub))
	;;			 (remove-set-of (cadar args-super)))
	;;	(cadar (remove-set-of args-super)))
	;; (setq *partial-match* t)
	;; (args-subsumed (rest args-sub) (rest args-super)))
	(t
	 (if *mkb-very-verbose*
	     (format *terminal-io* "~% not subsumed param  ~S ~S"
		 (cadar args-sub) (cadar args-super)))
	 nil)))
	

      

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  add a node to capability-tree
;; check if the current goal can subsume any decendents of the parent
;; and add those as children
(defun add-goal-in-sub-tree (goal parent children)
  (if *mkb-verbose*
      (format *terminal-io* "~% add-goal-in-subtree:~S ~% children: ~S"
	  (get-goal-node-goal goal) (mapcar #'get-goal-node-goal children)
	  ))
  (let ((subsumee nil))
    (dolist (child children)
      (when (goal-subsumed (get-goal-node-goal child)
			   (get-goal-node-goal goal))
	(set-goal-node-parent child goal)
	(push child subsumee)))
    (if *mkb-verbose*
	(format *terminal-io* "~% subsumee:~S" (mapcar #'get-goal-node-goal subsumee)))
    (when (not (null subsumee)) 
      (set-goal-node-children parent
			      (set-difference children subsumee
					      :test #'equal))
      (set-goal-node-children goal subsumee))
    (first (add-child-to-goal-node parent goal))))

(defun add-goal-node (simplified-goal mkb-method defined-p)
  (let ((parent (find-parent simplified-goal)))
    (if *mkb-verbose*
        (format *terminal-io* "~%parent of ~S is ~%   == ~S"
	      simplified-goal (get-goal-node-goal parent))
      )
    (cond ((equal simplified-goal (get-goal-node-goal parent))
	   ;(format *terminal-io* "~% same goal exists")
	   (when (not (null defined-p)) ;; when adding new mkb-method
	     (cond ((eq 't (get-goal-node-defined-p parent)) ;; already defined by another mkb-method
		    (signal-message 'goal-exist (get-mkb-method-name
						  (get-goal-node-mkb-method parent))
				    simplified-goal))
		   (t  
		    (set-goal-node-defined-p parent 't)
		    (set-goal-node-mkb-method parent mkb-method))))
	   parent)
	  (t (let ((goal-node (make-goal-node
			       :goal simplified-goal
			       :mkb-method mkb-method
			       :parent parent
			       :defined-p defined-p))
		   (super-goal-concepts
		    (kb-get-superconcepts (first simplified-goal))))
	       
	       (add-goal-in-sub-tree goal-node parent
				     (get-goal-node-children parent))

	       ;; organize goal concepts in capability hierarchy
	       ;; by adding super goal concepts in the hierarchy
	       (if (and (equal parent *mkb-capability-tree-root*)
			(not (equal super-goal-concepts '(expect-action))))
		   (dolist (c super-goal-concepts)
		     (add-goal-node (list c) nil nil)))
	       goal-node
	       
	       )))))


      
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun find-vars-assoc-list (plan-capability)
  (mapcan #'(lambda (p)
	      (if (and (listp (second p))
		       (lexicon-variable-p (first (second p))))
		  (list (cons (caadr p) (car (cddadr p))))))
	  (cdr plan-capability)))

(defun find-edt-for-var (var assoc-list)
  (if *mkb-very-verbose*
      (format *terminal-io* "~% ~S in ~S~%" var assoc-list))
  (cdr (assoc var assoc-list)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; simplify goal by dropping vars;;;;;;
(defun simplify-goal (code)
  (cond
   ((null code) '())
   ((and (not (listp (car code))) (lexicon-variable-p (car code)))
    (if (= (length code) 3)
	(third code)
      '()))
   ((listp (car code))
    (append (list (simplify-goal (car code))) (simplify-goal (cdr code))))
   (t
    (append (list (car code)) (simplify-goal (cdr code)))))
  )






;;; ***************************************************************
;;;

(defun compute-plan-result (plan &optional (old nil))
  (let ((cap (get-plan-capability plan))
	(name (get-plan-name plan))
	(body (get-plan-method plan)))
    (if old (delete-reference-in-method-list name))
    (find-subgoals-and-compute-edt body cap name 'undefined)
  ))

;;; ***************************************************************
;;;  functions to update undefined goal list, when a method is added
;;; ***************************************************************
;;;
;;; for each goal callers
;;; recompute the result for the whole body -- not so efficient now
(defun revise-undefined-goal-list (mkb-method)
  (let ((plan-names
	 (find-undefined-goal-callers mkb-method)))
    (dolist (plan-name plan-names)
      (let ((method (find-mkb-method plan-name))
	    (*subgoals* nil))
	(let ((edt (compute-plan-result (get-mkb-method-plan method))))
	  (if *mkb-verbose*
	      (format *terminal-io* "~% new subgoals for:~S  is --- ~S~%"
		      (get-mkb-method-name method) *subgoals*))
	  (set-mkb-method-subgoals method *subgoals*)
	  (set-mkb-method-current-result method edt)
	  (if (not (equal 'undefined edt))
	      (revise-undefined-goal-list method))
	)))))
    

;; find users of the newly defined goal, and remove them from
;; *mkb-undefined-goals*
(defun find-undefined-goal-callers (mkb-method)
  (let ((goal (get-mkb-method-goal mkb-method))
	(result nil) (undefined-goals nil)
	(name (get-mkb-method-name mkb-method)))
    (dolist (ug *mkb-undefined-goal-list*)
      (let ((goal-desc (get-undefined-goal-goal ug)))
      (cond ((or (goal-subsumed (get-undefined-goal-goal ug) goal) ;;*****
		 (rfml-subsumed ug mkb-method))
	     (let ((users (get-undefined-goal-callers ug))
		   (goal-node (find-parent goal-desc)))
	       ;; retract the system defined goal-node in capability tree
	       (if (and (equal (get-goal-node-goal goal-node) goal-desc)
			(null (get-goal-node-defined-p goal-node)))
		   (delete-goal-node-in-goal-tree goal-node))
	       
	       (setf result (union users result))
	       (if *partial-match* 
		 (set-mkb-method-possible-users mkb-method
				(union (set-difference users  ;; non-recurive
						(list name))
				       (mkb-method-possible-users mkb-method)))
		 (set-mkb-method-users mkb-method
				(union (set-difference users ;; non-recurive
						(list name))
				       (mkb-method-users mkb-method))))))
	    (t
             ;; rlx match (ignore args) ;; 8/99
	     ;(if (goal-subsumed goal-desc goal t)
	     ;	 (set-mkb-method-possible-users mkb-method
		;		(union (set-difference
		;			(get-undefined-goal-callers ug)
		;			(list name))
		;		       (mkb-method-possible-users mkb-method))))
	     (if *mkb-verbose* (format *terminal-io* "~% ug added again ~S" ug))
	     (push ug undefined-goals)))))
    (setq *mkb-undefined-goal-list* undefined-goals)
    ;(format *terminal-io* "~% NEW UNDEFINED GOALS ~% ~S" undefined-goals)
    result))

(defun add-user-defined-goal (simplified-goal mkb-method defined-p)
  (setq *adding-system-defined-goals* nil)
  (add-goal-node simplified-goal mkb-method defined-p)
  )

(defun add-system-defined-goals ()
  (setq *adding-system-defined-goals* t)
  (dolist (sg *system-created-goals*)
    (if *mkb-verbose*
	(format *terminal-io* "~% $$  add-system-defined-goal ~S" sg)
      )
    (add-goal-node sg nil nil))
  )

;; check if reformulations of given undefined goal are subsumed by defined goals
;;  including the goal of the new method.
(defun rfml-subsumed (undefined-goal mkb-method)
  (let ((goal (get-undefined-goal-goal undefined-goal))
	(new-goal (get-mkb-method-goal mkb-method))
	(callers (get-undefined-goal-callers undefined-goal))
	(name (get-mkb-method-name mkb-method)))
    (cond ((equal goal new-goal)
	   nil)
	  ((and (member name callers)
		(= 1 (length callers)))
	   nil)
	  ((not (eq (first goal) (first new-goal))) ;; different action-name
	   nil)
	  ((not (args-compatible (rest goal) (rest new-goal)))
	   nil)
	  (t
	   (setq *partial-match* nil)
	   (setq *rfmls-unmatched* nil)
	   (let* ((subsumers (find-parents-from-rfml goal))  ;; recompute rfml
		  )
	     
	     (cond ((null subsumers) ;;; check if the new method participated???
		    nil)
		   (*partial-match* ;; not fully subsumed
		    (dolist (subsumer subsumers)
		      (let ((mkb-method (get-goal-node-mkb-method subsumer)))
			(when (not (null mkb-method)) ;; when not a system defined goal
			   (set-mkb-method-possible-users mkb-method
			    (union (set-difference callers (list name)) ;; assume non-recursive 
				   (mkb-method-possible-users mkb-method))))))
		    (if (not (equal *rfmls-unmatched*
				    (get-undefined-goal-unmatched-rfmls undefined-goal)))
			(set-undefined-goal-unmatched-rfmls undefined-goal *rfmls-unmatched*))

		    nil)
		   (t
		    ;;(format *terminal-io* "~%rfml-subsumed ~S ~S" goal new-goal)
		    't))
	     
	)))))
