(defun find-result-type-of-goal-without-adding-plan (goal expected-result)
  (cond ((some-args-undefined (rest goal))
	 'undefined)
	(t ;; args are all defined
	 (let ((subsumers (relaxed-find-parents goal)))
	   (cond ((null subsumers)
		  'undefined
		  )
		 (t
		  (let ((result-edt 'undefined))
		    (dolist (subsumer subsumers)
		      (let ((mkb-method (get-goal-node-mkb-method subsumer)))
			(when (and (not (null mkb-method)) ;; when not a system defined goal
				   (null *partial-match*))
			  (setq result-edt (mkb-find-common-edt
					    result-edt
					    (get-mkb-method-expected-result
					     mkb-method))))))
		    (setq result-edt
			  ;; needs to be modified based on *default-preferences*
			  (if (and *rfml-used* ;; from rfml
				   (member 'set *rfml-used*) ;; this is hack
				   (not (eq 'undefined result-edt)))
			      (make-edt-set result-edt) ;; this is wrong
			    result-edt))
			    
		    )))))))


(defun organize-agenda (agenda)
  (let ((methods nil)
	(instances nil)
	(exprs nil)
	(agenda-info nil)
	(organized-agenda nil)) ;; list of (sources agenda-item)

    ;; phase 1: collect agenda based on source (method name)
    ;;          the result will be
    ;;                 a list of method-names that originate problems ; methods
    ;;                 a list of (method-name agenda) ; agenda-info
    (dolist (a-item agenda)
      (case (get-error-code-in-error-condition a-item)
	((no-mt-parse-found more-than-one-parse no-parse-found
		result-lost unused-plan not-found
		undeclared-var unused-var undefined-word
		duplicated-capability duplicated-var
		duplicated-method duplicated-method-name)
	 (let ((method-name (first (get-parameters-in-error-condition a-item))))
	   (pushnew method-name methods)
	   (push (list (list method-name) a-item) agenda-info))
	 )
	((new-expect-action goal-exist cannot-parse-capability)
	 (let ((method-name (second (get-parameters-in-error-condition a-item))))
	   (pushnew method-name methods)
	   (push (list (list method-name) a-item) agenda-info))
	 )
	((missing-role-value over-general-type)
	 (let ((list-of-methods-and-node
		(third (get-parameters-in-error-condition a-item)))
	       (sources nil))
	   (dolist (methods-and-node list-of-methods-and-node)
	     (dolist (method (first methods-and-node))
	       (when (ka-find-plan method) 
		 (pushnew method methods)  ;; for all the methods
		 (pushnew method sources)))) ;; for the methods related to this agenda
	   (push (list sources a-item) agenda-info)
	   )
	 )
	(no-plan-found
	 (let ((mnames (find-name-of-methods-that-originated-node
			(second (get-parameters-in-error-condition a-item)))))
	   (setq methods (union methods mnames))
	   (push (list mnames a-item) agenda-info)))
	((undefined-concept-in-instance undefined-role-in-instance invalid-role-in-instance)
	 (let ((iname (first (get-parameters-in-error-condition a-item))))
	   (pushnew iname instances)
	   (push (list (list iname) a-item) agenda-info))
	 )
	((invalid-args invalid-result invalid-expr)
	 (let* ((node (get-node-in-error-condition a-item))
		(mnames (find-method-names-from-node node))
		(sources nil))
	   (dolist (source mnames)
	     (pushnew source methods)
	     (pushnew source sources))
	   (push (list sources a-item) agenda-info))
	 )
	(otherwise nil)
	))
    
    (dolist (instance-name instances)
      (let ((agenda-on-instance nil))
	(dolist (item agenda-info)
	  (if (member instance-name (first item))
	      (push (second item) agenda-on-instance)))
	(push (list 'instance
		    instance-name
		    (format nil "problems with instance ~A" instance-name)
		    agenda-on-instance)
	      organized-agenda))
      )
    (dolist (expr exprs)
      (let ((agenda-on-expr nil))
	(dolist (item agenda-info)
	  (if (member expr (first item) :test #'equal)
	      (push (second item) agenda-on-expr)))
	(push (list 'expr
		    expr
		    (format nil "problems with expression ~A" expr)
		    agenda-on-expr)  ;;; To do
	      organized-agenda))
      
      )
    ;; phase 2: organize agenda based on method-name that originated the problem
    ;;      the result is organized agenda
    ;;         a list of ('method method-name method-description
    ;;                            a list of (agenda-id agenda-description))
    (dolist (method-name methods)
      (let ((agenda-on-method nil))
	(dolist (item agenda-info)
	  (if (and (ka-find-plan method-name)
		   (member method-name (first item) :test #'equal))
	      (push (second item) agenda-on-method)))
	(push (list 'method
		     method-name
		     (format nil "problems in how to do this: ~A"
			     (get-plan-capability-nl (ka-find-plan method-name)))
		     agenda-on-method) organized-agenda))
      )
    organized-agenda)
    )

(defun find-matches-based-on-set-rfml (rgoals)
  (if (null rgoals)
      nil
    (let* ((rgoal (first rgoals))
	   (parent (find-parent-to-match rgoal))
	   (subsumers
	    (cond ((equal parent *mkb-capability-tree-root*)
		   (find-matches-from-rfml rgoal))
		  (t (list parent)))))
      (if (null subsumers)
	  (find-matches-based-on-set-rfml (rest rgoals))
	subsumers))))
	     
(defun find-matches-based-on-covering-rfml (rgoals partial-match goals-unmatched)
  (let ((partial-match nil)
	(goals-unmatched nil))
    (if (null rgoals)
      nil
      (let* ((rgoal (first rgoals))
	     (parent (find-parent-to-match rgoal))
	     (subsumers
	      (cond ((equal parent *mkb-capability-tree-root*)
		     (find-matches-from-rfml rgoal))
		    (t (list parent))))
	     ;; try all of them
	     (other-matches (find-matches-based-on-covering-rfml (rest rgoals))))
	(cond ((null subsumers)
	       (setq partial-match t) ;; some covering rfmls didn't match
	       (setq goals-unmatched (pushnew rgoal goals-unmatched :test #'equal))
	       (list other-parents partial-match goals-unmatched))
	      (t
	       (list
		(union subsumers (first other-matches) :test #'equal)
		(second other-matches) ; partial match
		(third other-matches)  ; goals-unmatched
		)))))))

(defun get-all-rfmls (goal)
  (let ((ug (find-undefined-goal goal *mkb-undefined-goal-list*)))
    (cond ((null ug) ;; should not happen though
	   (generate-all-rfmls goal)
	  (t
	   (get-undefined-goal-all-rfmls ug))
	  ))))

(defun generate-all-rfmls (goal)
  (get-all-rfmls-1 goal nil))

(defun add-item (list item)
;  (format *terminal-io* "~% - item:~S" item)
  (when (not( null item))
    (append list (list item))))

(defun get-all-rfmls-1 (goal result)
  ;; (1) set rfml
  ;; (2) covering (or input) rfml
  ;; rfmls of results of (1) (2)
  ;(format *terminal-io* "~%goal:~S" goal)
  (let ((set-rfmlt-goals
	  (mapcar #'caadr 
		 (generate-set-reformulations-for-goal goal nil)))
	(covering-rfmlt-goals-list
	 (mapcar #'cadr
		 (generate-covering-reformulations-for-goal goal nil))))
    (dolist (rfmlt-goal set-rfmlt-goals)
      (if (not (member (list 'set rfmlt-goal) result :test #'equal))
	  (setq result (add-item result (list 'set rfmlt-goal)))))
    (dolist (rfmlt-goals covering-rfmlt-goals-list)
      (if (not (member (append (list 'covering) rfmlt-goals) result :test #'equal))
	  (setq result (add-item result (append (list 'covering) rfmlt-goals))))
      ;(format *terminal-io* "~%result:~S" result)
      )
    (dolist (rfmlt-goal set-rfmlt-goals)
      (setq result (get-all-rfmls-1 rfmlt-goal result)))
    (dolist (rfmlt-goals covering-rfmlt-goals-list)
      (let ((covering-result nil))
	(dolist (rfmlt-goal rfmlt-goals)
	  (setq covering-result
		(add-item covering-result
			  (get-all-rfmls-1 rfmlt-goal nil))))
	(if (and (not (null covering-result))
		 (not (member (append (list 'covering) covering-result)
			      result :test #'equal)))
	    (setq result (add-item result
				  (append (list 'covering) covering-result))))))
    ;(format *terminal-io* "~%result:~S" result)
    result)
  )


(defun find-matches-from-rfmls (sgoal rfmls)
  (let* ((rfml-item (first rfmls))
	 (type (first rfml-item)))
      (if (eq type 'set)
	  (let ((match (find-parent-to-match (second rfml-item))))
	    (cond ((equal match *mkb-capability-tree-root*)
		   (find-matches-from-rfmls (rest sgoal rfmsl)))
		  (t
		   (push 'set *rfml-used*)
		   match)))
	(dolist ()))))
		 
	     
(defun relaxed-find-matches (sgoal)
  (setq *rfml-used* nil)
  (let ((subsumer (find-parent-to-match sgoal)))
    (cond ((equal subsumer *mkb-capability-tree-root*)
	   ;(setq *rfml-used* '(t)) ;; this is hack
	   (setq *all-rfmls-of-current-goal* 
		 (generate-all-rfmls sgoal))
	   (find-matches-from-rfmls sgoal *all-rfmls-of-current-goal*))
	  (t
	   (list subsumer)
	     ))
    ))    
