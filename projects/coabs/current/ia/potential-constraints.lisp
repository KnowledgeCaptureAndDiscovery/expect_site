(in-package "EXPECT")

;; ********************************************
;; keep additional constraints introduced by user
;; but not apply them to the problem solving yet
;; ********************************************
;; < data structure>
;; *mkb-ps-potential-match-for-incomplete-goals*
;; *applied-potential-match*
;; change the expected results in *mkb-ps-undefined-goal-list*

;; use dummy method created for undefined methods

;;;;;;;;;;;;;;
;; propagate constraints from partial match
;;
;; *mkb-ps-potential-match-for-incomplete-goals*
;; *applied-potential-match*
;; change the expected results in *mkb-ps-undefined-goal-list*

;; assume gr-node is a method anode
(defun propagate-constraint (gr-node org-goal new-goal result-type)
  (let* ((subgoals (get-goal-relation-node-subgoals gr-node))
	 (sgoal (caar (last subgoals))))
    ;; currently, we exploit top expr only
    (if *problem-solver-verbose* (format *terminal-io* "~%sgoal:~S ~%org-goal:~S" sgoal org-goal))
    (when (equal sgoal org-goal)
      (do ((params (rest sgoal) (rest params))
	   (cgoals (butlast subgoals) (rest cgoals))
	   (new-params (rest new-goal) (rest new-params)))
	  ((null params))
	(if *problem-solver-verbose* (format *terminal-io* "~%params:~S ~%cgoals:~S ~%new-params:~S"
		params cgoals new-params))
	(if (eq 'undefined (second (car params)))
	    (propagate-constraint-1 (get-goal-relation-node-children gr-node)
				  ;; goal expr  ;; new expected result
				  (caar cgoals) (second (car new-params)))))
      (set-goal-relation-node-subgoals gr-node
				       (append (butlast subgoals)
					       (list (list new-goal result-type))))
      )))

(defun propagate-constraint-1 (gr-nodes goal-expr new-expected-result)
  (let ((gr-node (find-gr-node-with-goal goal-expr gr-nodes)))
    (when (eq 't (get-goal-relation-node-system-proposed gr-node))
      (set-goal-relation-node-result gr-node new-expected-result)
      (let ((undefined-goal
	     (undefined-method-node
	      (find-node-in-tree (get-goal-relation-node-id gr-node)))))
	(set-undefined-goal-expected-result undefined-goal
					    new-expected-result))))
  )

(defun find-gr-node-with-goal (goal-expr gr-nodes)
  (cond ((null gr-nodes)
	 (if *problem-solver-verbose* (format *terminal-io* "~% this shouldn't happen: cannot find-gr-node-with-goal"))
	 nil)
	((equal goal-expr (get-goal-relation-node-goal
			   (first gr-nodes)))
	 (first gr-nodes))
	(t (find-gr-node-with-goal goal-expr (rest gr-nodes)))))

; call (find-usable-methods-with-partial-match) first
;; TTD: change possible-users to possible-user
(defun propagate-constraint-from-potential-match (id)
  (let ((node (find-node-for-partial-match-info id)))
    (if (not (null node))
	(propagate-constraint-from-potential-match-1 node)))
  (find-usable-methods-with-partial-match)
  )
(defun propagate-constraint-from-potential-match-1 (node)
  (let ((info (first ;;??? TTD 
	       (get-goal-relation-node-possible-users node)))
	(new-goal (get-goal-relation-node-goal node)))
    (propagate-constraint (second info)  ;; gr-node
			  (first info)   ;; original goal
			  new-goal
			  (get-goal-relation-node-result node))
    (push (list (first info) new-goal
		(get-goal-relation-node-goal (second info)))
	  *applied-potential-match*))
  (produce-xml-method-tree-1  *mkb-ps-method-relation-tree-root*)
  )

(defun find-node-for-partial-match-info (id)
  (let ((nodes (get-goal-relation-node-children
		*mkb-ps-potential-match-for-incomplete-goals*)))
    (car (mapcan #'(lambda (c)
		(and (equal id (format nil "~A" (get-goal-relation-node-id c)))
		     (list c)))
	    nodes))))

;;; maybe we don't need this?
;;; applies the *applied-potential-match*


(defun apply-selected-potential-matches ()
  (find-usable-methods-with-partial-match)
  (mapcar #'(lambda (c) (apply-selected-potential-match c))
	  *applied-potential-match*)
  )

(defun apply-selected-potential-match (info)
  (let ((old-goal (first info))
	(new-goal (second info))
	(user (third info)))
    (let ((node
	   (find-node-for-potential-match-info old-goal new-goal user
				(get-goal-relation-node-children
				*mkb-ps-potential-match-for-incomplete-goals*))))
      (if (not (null node))
	  (propagate-constraint-from-potential-match-1 node))
      )))

(defun find-node-for-potential-match-info (old-goal new-goal user nodes)
  (if (null nodes)
      nil
    (let ((info (first 
		 (get-goal-relation-node-possible-users (first nodes))))
	  (n-goal (get-goal-relation-node-goal (first nodes))))
      (if (and (equal (get-goal-relation-node-goal (second info))
		      user)
	       (equal old-goal (first info))
	       (equal new-goal n-goal))
	  (first nodes)
	(find-node-for-potential-match old-goal new-goal user
				       (rest nodes)))))
  )


;; keep a list of applied potential match
;; as a pair (old-expr new-expr)
;; and keep gr-node in the potential match info

;; keep a list of mappings from incomplete expr
;; to gr-node that has the expr as a subgoal
;; the list will change everytime MR tree is newly built
;;
;; the list can be used to keep propagating constraints, even after
;; the ps-tree has changed




#|
(defun find-usable-methods-with-partial-match-and-apply ()
  (find-incomplete-goals-and-modify-tree
   *mkb-ps-method-relation-tree-root* nil)
)

(defun find-incomplete-goals-and-modify-tree (gr-node result)
  (when (not (null gr-node))
    (if (not (null (get-goal-relation-node-body gr-node))) ;; method node
	(let ((goals (get-goal-relation-node-subgoals gr-node))
	      (method-name (get-goal-relation-node-source gr-node)))
	  (dolist (g goals)
	    (when (and (member 'UNDEFINED (flatten (first g)))
		       (not (member (list (first g) method-name) result
				    :test #'equal)))
	      (push (list (first g) method-name gr-node) result)
	      (find-partial-match-and-modify-tree (first result) gr-node)))))
    (dolist (c (get-goal-relation-node-children gr-node))
      (setq result (find-incomplete-goals-and-modify-tree c result))))
  result)


;;; really new one
(defun find-partial-match-and-expand-tree (igoal-desc gr-node)
  (let* ((igoal (first igoal-desc)) ;; incomplete goal descrition
         (matched-goal-node (find-parent-to-match igoal)))
    (when (not (null matched-goal-node))
      (let ((mkb-method (get-goal-node-mkb-method matched-goal-node)))
        (when (not (null mkb-method))
)))))

|#