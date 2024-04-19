(in-package "EXPECT")

;;; ************************************
;;; add, delete, update methods in mkb-list
;;; ************************************
;;;
;;;  update undefined-goal list,
;;;   capability tree


;;; list of subgoals called in a method body
(defvar *subgoals* nil)


;;; **************************************************************
;;; functions called to add a method
;;;
;;; 1. check if it can achieve any unresolved goals
;;; 2. compute subgoals based on the match
;;; 3. compute result type
(defun add-mkb-method (plan)
  (let ((cap (get-plan-capability plan))
	(name (get-plan-name plan))
	(result (get-plan-result plan))
	(body (get-plan-method plan))
	(*subgoals* nil))
    (let ((new-mkb-method (create-mkb-method name cap body result plan)))
      (if (primitive-plan-p plan)
	  ;; assume the primitive method will return the result type as defined
	  (set-mkb-method-current-result new-mkb-method result)
	(set-mkb-method-current-result new-mkb-method
				       (find-subgoals-and-compute-edt
					body cap name result))
	)
       (if *mkb-verbose*
	   (if *problem-solver-verbose* (format *terminal-io* "~% subgoal-for:~S is --- ~S~%"
		   (get-mkb-method-name new-mkb-method) *subgoals*))
	 )
      (set-mkb-method-subgoals new-mkb-method *subgoals*)
    
      (push (list name new-mkb-method) *mkb-method-list*)

      ;; add new goal in goal hierarchy
      (add-user-defined-goal (get-mkb-method-goal new-mkb-method) new-mkb-method 't) ;; capability-tree
      ;;(if *problem-solver-verbose* (format *terminal-io* "~% ****** before revise-undefined-goals ~% **~S"
	;;      *mkb-method-list*))
      
      (revise-undefined-goal-list new-mkb-method) ;; find users of the new method and
	                             ;; remove them from the list
      ;; add undefined subgoals the goal hierarchy
      ;;(dolist (goal *subgoals*)
	;;(when (and (equal 'undefined (second goal))
		;;   (not (member 'undefined (mapcar #'second (rest (first goal))))))
	 ;; (add-user-defined-goal (first goal) new-mkb-method nil)))

      (add-system-defined-goals)
      (if (null *defining-system-plans*)
	  (build-method-relation-tree)) ;; method-relation-tree
       )))


(defun create-mkb-method (name cap body result plan)
  (setq *system-created-goals* nil)
  (setq *subgoals* nil)
  (let* ((simplified-goal (simplify-goal cap))
	 (current-method
	  (make-mkb-method
	   :name name ;(generate-nl-description-of-plan-capability
	              ;plan)
	   :goal simplified-goal
	   :expected-result result
	   :current-result nil
	   :users nil
	   :possible-users nil
	   :subgoals nil
	   :undefined-subgoals nil
	   :plan plan
	   :system-p *defining-system-plans*)))
    (if (null *defining-system-plans*)
	(push name *user-defined-methods--name*)
      (push name *system-defined-methods--name*))
    current-method
    ))

(defun remove-mkb-method-in-list (name)
  (let ((result nil))
    (dolist (item *mkb-method-list*)
      (if (not (eq name (first item)))
	  (push item result)))
    (setq *mkb-method-list* result)))
    
;;; **************************************************************
;;; functions called to modify a method
;;;
(defun modify-mkb-method (new-plan old-plan)
  (delete-mkb-method old-plan)
  ;(if *problem-solver-verbose* (format *terminal-io* "~%before add new one ~S"  *mkb-undefined-goal-list*))
  (add-mkb-method new-plan)
)


;;; **************************************************************
;;; functions called to delete a method
;;;
(defun delete-mkb-method (plan)
  (let* ((cap (get-plan-capability plan))
	 (name (get-plan-name plan))
	 (mkb-method (find-mkb-method name))
	 (simplified-goal (simplify-goal cap))
	 (the-node (find-parent simplified-goal)))
    
    ;; delete the goal from *mkb-capability-tree-root*
    (if (equal simplified-goal (get-goal-node-goal the-node)) ;; found the node
	(delete-goal-node-in-goal-tree the-node)
      (if *problem-solver-verbose* (format *terminal-io* "~% not found ~S: ~% got ~S instead" simplified-goal
	      (get-goal-node-goal the-node))))

    (add-as-undefined-goal-if-called mkb-method)
    (delete-undefined-goal-from-method mkb-method)
    (delete-reference-in-method-list name)
    (remove-mkb-method-in-list name)

    (setq *user-defined-methods--name*
	  (delete name  *user-defined-methods--name*))

    (build-method-relation-tree) ;; rebuild  method-relation-tree
    *mkb-undefined-goal-list*

  ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;  delete a node in capability-tree
;;;  put children of the node as children of the parent
;;;
;; We assume a tree structure: a goal is subsumed by only one goal?
(defun delete-goal-node-in-goal-tree (node)
  (let ((parent (get-goal-node-parent node)))
	
    (cond ((null parent)
	   (if *problem-solver-verbose* (format *terminal-io* "~% ########## cannot find parent of goal ~S~%"
		   (get-goal-node-goal node)))
	   nil)
	  (t
	   ;(set-goal-node-children parent
	   ; (delete node (get-goal-node-children parent) :test #'equal))
	   (let ((children (get-goal-node-children node)))
	     (dolist (child children)
	       (set-goal-node-parent child parent)
	       (add-child-to-goal-node parent child))
	     )
	   (let ((new-children nil))
	     (dolist (ch (get-goal-node-children parent))
	       (if (not (equal (get-goal-node-goal ch) (get-goal-node-goal node)))
		   (push ch new-children))
	       )
	     (set-goal-node-children parent new-children))
	   (set-goal-node-parent node nil)
	   (set-goal-node-children node nil)
	   ))
    )
  )

;; ?
(defun remove-undefined-goals-created-for-subgoals (mkb-method)
  (let ((subgoals (get-mkb-method-subgoals mkb-method)))
    (dolist (subgoal subgoals) ;; subgoal in form (goal result-type)
      (if (equal 'undefined (second subgoal))
	  (delete-undefined-goal (first subgoal) 
				 (get-mkb-method-name mkb-method))))))
	  

;; the method becomes undefined, for the caller
(defun add-as-undefined-goal-if-called (mkb-method)
  (let ((callers (get-mkb-method-users mkb-method))
	(possible-callers (get-mkb-method-possible-users mkb-method)))
    (dolist (caller callers)
      (let* ((method (find-mkb-method caller))
	     (*subgoals* nil)
	     (edt (compute-plan-result (get-mkb-method-plan method) t)))
	;(if *problem-solver-verbose* (format *terminal-io* "~% revised subgoals for:~S  is --- ~S~%"
	;	(get-mkb-method-name method) *subgoals*))
	(remove-undefined-goals-created-for-subgoals method)
	(set-mkb-method-subgoals method *subgoals*)
	(set-mkb-method-current-result method edt)))))

(defun delete-undefined-goal-from-method (mkb-method)
  (let ((name (get-mkb-method-name mkb-method))
	(result nil))
    (dolist (ug *mkb-undefined-goal-list*)
      (let ((callers (get-undefined-goal-callers ug)))
	(cond ((= 1 (length callers))
	       (if (not (eq name (first callers)))
		   (push ug result)))
	      (t (push ug result)
		 (if (member name callers)
		     (set-undefined-goal-callers ug
				(delete name (get-undefined-goal-callers ug))))))))
    ;(if *problem-solver-verbose* (format *terminal-io* "~% NEW UNDEFINED GOALS AFTER DELETE~% ~S" result))
    (setq *mkb-undefined-goal-list* result)))


;; TTD: use method-relation-tree for efficiency
;;          - given the node for the method, remove names in the
;;              users field of the children methods, 
(defun delete-reference-in-method-list (name)
  (dolist (method-desc *mkb-method-list*)
    (let* ((mkb-method (second method-desc))
	   (users (get-mkb-method-users mkb-method))
	   (possible-users (get-mkb-method-possible-users mkb-method)))
      (if (member name users)
	  (set-mkb-method-users mkb-method (delete name users)))
      (if (member name possible-users)
	  (set-mkb-method-possible-users mkb-method (delete name possible-users)))
      )))
