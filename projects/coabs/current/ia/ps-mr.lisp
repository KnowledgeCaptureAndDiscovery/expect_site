(in-package "EXPECT")

; ***************************************************************************
; build method-relation tree based on PS-tree
; ***************************************************************************

(defvar *mkb-ps-method-relation-tree-root* nil)
(defvar *building-mkb-ps-method-relation-tree* nil)

(defvar *mkb-current-node-list* nil) ;; temporary variable to build MR tree
                                     ;; a list of most recent goal-relation-nodes
                                     ;; for all level in the MR tree
(defvar *usable-goal-nodes* nil) ;; goals with incomplete reformulation
                                 ;; it is used find-methods-potentially-used-with-rfml

(defun get-node-source (n)
  (let ((type (get-anode-type n)))
    (cond ((equal 'method type)
	   (get-plan-name 
	    (get-method-info-struc-method (get-anode-info n))))
	 ;(let ((expr (get-node-expr n)))
	 ;  (if (null expr)
	 ;      (get-plan-name
	 ;       (get-method-info-struc-method (get-anode-info n)))
	 ;    (generate-nl-description-of-goal expr))))
	((equal 'covering type)
	 'covering-or-input)
	(t type))))
#|
(defun get-node-body (n)
  (let ((type (get-anode-type n)))
    (cond ((equal 'method type)
	   (get-node-subexpr n))
	  (t nil))))
|#
(defun get-node-body (n)
  (let ((type (get-anode-type n)))
    (cond ((equal 'method type)
	   (let ((bindings (get-method-info-struc-bindings
			    (get-anode-info n)))
		 (plan (get-ps-plan-plan
			(get-method-info-struc-method (get-anode-info n)))))
	     (if (null plan)
		 nil
	       (substitute-bindings bindings (get-plan-method plan)))
	   ))
	  (t nil))))


(defun get-node-capability (n name)
  (let ((type (get-anode-type n)))
    (cond ((equal 'method type)
	   (get-plan-capability (ka-find-plan name)))
	  (t nil))))
	   

(defun ps-add-goal-relation-node (n level subgoals)
  (let* ((node-source (get-node-source n))
	 (node (make-goal-relation-node
	       :source node-source
	       :id  (get-node-name n)
	       :goal (get-node-expr n)
	       :capability (get-node-capability n node-source)
	       :body (get-node-body n)
	       :result (compute-node-expected-result n)
	       :result-obtained (get-node-valid-result n)
	       :possible-users  nil ;; TTD
	       :subgoals subgoals
	       :system-proposed nil ;; TTD?
	       :children nil)))
    (add-gr-node-to-gr-tree node n level)
    ))

(defun add-gr-node-to-gr-tree (node n level)
  (let ((parent (nth level *mkb-current-node-list*)))
    (add-goal-relation-node-child parent node)
    (if (> (length *mkb-current-node-list*) (+ 1 level))
	(setf (nth (+ 1 level) *mkb-current-node-list*) node)
      (setf *mkb-current-node-list*
	    (append *mkb-current-node-list* (list node))))
    ))


; build method-relation tree based on PS-tree
#|
(defun ps-build-method-relation-tree ()
  (setq *show-all-rfml* nil)
  (ps-build-method-relation-tree-1 *ps-tree*)
  (find-usable-methods-with-rfml)
  (find-usable-methods-with-partial-match)
  (find-unused-methods-and-extend-mr-tree)
)
|#

(defun ps-build-method-relation-tree ()
  (setq *show-all-rfml* nil)
  (ps-build-method-relation-tree-1 *ps-tree*)
  (find-usable-methods-with-rfml)
  (find-usable-methods-with-partial-match)
 ; (find-unused-methods-and-extend-mr-tree)
)

(defun ps-build-method-relation-tree-all ()
  (setq *show-all-rfml* 't)
  (ps-build-method-relation-tree-1 *ps-tree*)
  (find-usable-methods-with-partial-match)
;  (find-unused-methods-and-extend-mr-tree)
)

(defun ps-build-method-relation-tree-1 (root)
  (setq *mkb-ps-method-relation-tree-root* (make-goal-relation-node
					     :source nil
  					     :children nil))
  (setq *mkb-current-node-list* nil)
  (setq *mkb-ps-undefined-goal-list* nil)
  (push *mkb-ps-method-relation-tree-root* 
	*mkb-current-node-list*) ; level -1
  (setq *building-mkb-ps-method-relation-tree* t)
 ;(print-tree-goals root)
  (display-tree-goals root 0 (make-string-output-stream))
  (setq *building-mkb-ps-method-relation-tree* nil)
)


(defun find-possible-users (node)
  (let* ((ps-node (find-node-in-tree
	         (get-goal-relation-node-id node)))
         (method-nodes (find-method-nodes-that-originated-node ps-node)))
    (mapcar #'(lambda (mn)
	      (find-possible-user-info mn ps-node)) method-nodes)))


(defun find-possible-user-info (method-node org-node)
  (let* ((subgoals (mapcar #'first (find-node-subgoals method-node)))
        (org-subgoals (find-subgoals-originating-node subgoals org-node)))
    (list org-subgoals (get-ps-plan-name
		    (get-method-info-struc-method
		     (get-anode-info method-node))))))

;; find the subgoal that originated the node 
(defun find-subgoals-originating-node (subgoals node)
  (let ((result nil))
    (dolist (goal subgoals)
      (when (not (member 'undefined (flatten goal)))
        (if (goal-originated-node goal (list node))
	  (push goal result))))
    result))

;; check if given goal originated at least one of the given nodes
(defun goal-originated-node (goal nodes)
  (cond ((null nodes)
         nil)
        ((and (enode-p (first nodes))
	    (equal (get-enode-expanded-expr (first nodes))
		 goal))
         t)
        (t (goal-originated-node goal (union (get-node-parents (first nodes))
				     (rest nodes) :test #'equal)))
        ))

(defun add-method-relation-sub-tree (root)
  (let ((org-tree-root *mkb-ps-method-relation-tree-root*))
    (setq *show-all-rfml* nil)
    (ps-build-method-relation-tree-1 root)
    (let ((new-children (get-goal-relation-node-children 
			*mkb-ps-method-relation-tree-root*)))
      (dolist (c new-children)
        (when (not (child-of-node c org-tree-root))
	;(if *problem-solver-verbose* (format *terminal-io* "~% added child ~S" c))
	(set-goal-relation-node-possible-users c
				         (find-possible-users c))
	(add-goal-relation-node-child org-tree-root c)

	;(if *problem-solver-verbose* (format *terminal-io* "~% NEW ~% ~S" org-tree-root))
	))
      )
    (setq *mkb-ps-method-relation-tree-root* org-tree-root))
  )


(defun find-ps-node-in-method-relation-tree (name current)
  (if (string-equal name (get-goal-relation-node-id current))
       current
    (let ((children (get-goal-relation-node-children current)))
      (dolist (c children)
	(let ((result (find-ps-node-in-method-relation-tree name c)))
	  (when result
	    (return result)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; find-methods-potentially-used-with-rfml
(defun find-usable-methods-with-rfml()
  (setq *usable-goal-nodes* nil)
  (collect-usable-goal-nodes nil *ps-tree*)
  (dolist (n *usable-goal-nodes*)
    (find-nontrivial-children-and-build-tree n))
)

(defun find-nontrivial-children-and-build-tree (anode)
  (let ((children (get-node-children anode))
        (result nil))
    (dolist (c children)
      (when (or (get-node-children c)
	      (eq (get-enode-expanded c) 'result)
	      (any-anode-has-match c))
        (when (not (member c result :test #'equal))
	(setq result (push c result))
	(add-method-relation-sub-tree c)
	;(if *problem-solver-verbose* (format *terminal-io* "~% nontrivial children ~S" c))
	))
      )
    result))


(defun add-trivial-anode (n)
  (when (not (member n *usable-goal-nodes* :test #'equal))
      (push n *usable-goal-nodes*)
      (if *problem-solver-verbose* (format *terminal-io* "~% anode become trivial ~S" n))))

(defun collect-usable-goal-nodes (trivial n)
  (cond (n
	 (if (and (anode-p n) (get-node-children n)
		  (not (equal (get-anode-type n) 'method))
		  (not (equal (get-anode-type n) 'input))
		  (null trivial) 
		  (not (non-trivial-node n)))
	     (add-trivial-anode n))
         (mapcar #'(lambda (c)
                     (collect-usable-goal-nodes trivial c))
		  (get-node-children n))
         (when (enode-p n)
           (when (get-enode-current n)
	     (let ((c (get-enode-current n)))
	       (cond ((or (equal (get-anode-type c) 'method)
			 (and (member (get-anode-type c) *rfml-kinds*)
			      (get-anode-info c)))
		      (collect-usable-goal-nodes nil c))
		     (t ;(if (null trivial)
			;    (if *problem-solver-verbose* (format *terminal-io* "~% became trivial ~S" n)))
			(collect-usable-goal-nodes 't c)))))
	   (when (get-enode-failed n)
             (mapcar #'(lambda (f)
			 (cond ((or (equal (get-anode-type f) 'method)
				     (and (member (get-anode-type f) *rfml-kinds*)
					  (get-anode-info f)))
				  (collect-usable-goal-nodes nil f ))
			       (t ;(if (and (not (equal n *ps-tree*)) 
				    ;	     (null trivial))
				    ;	(if *problem-solver-verbose* (format *terminal-io* "~% became trivial ~S" n)))
				(collect-usable-goal-nodes 't f))))
		     (get-enode-failed n)))
           (when (get-enode-not-tried n)
             nil)))
        (t
         nil)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; find usable-methods-with-partial-match
;;
(defun find-usable-methods-with-partial-match ()
  (setq *mkb-ps-potential-match-for-incomplete-goals*
	(make-goal-relation-node
	 :source nil
	 :children nil))
  (let* ((goals-with-undefined-params
	  (find-goals-with-undefined-params
	   *mkb-ps-method-relation-tree-root* nil))
         (gr-nodes (mapcar #'find-partial-match-and-create-gr-node
		       goals-with-undefined-params)))
    (mapcar #'(lambda (node)
	      (if (not (null node))
		(add-goal-relation-node-child
		 *mkb-ps-potential-match-for-incomplete-goals*
		 node)))
	    gr-nodes))
)

(defun find-goals-with-undefined-params (gr-node result)
  (if (null gr-node)
      result
    (let ((goals (get-goal-relation-node-subgoals gr-node)))
      ;(if *problem-solver-verbose* (format *terminal-io* "~%subgoals:~S" goals))
      (if (not (null (get-goal-relation-node-body gr-node))) ;; method node
         (dolist (g goals)
	 (if (and (member 'UNDEFINED (flatten (first g)))
		  (not (member (list (first g) gr-node) result
			       :test #'equal)))
	     (push (list (first g) gr-node) result))))
      (dolist (c (get-goal-relation-node-children gr-node))
        (setq result (find-goals-with-undefined-params c result)))
      result
      )
    
    ))

;; igoal-desc is (goal gr-node)
(defun find-partial-match-and-create-gr-node (igoal-desc)
  (let* ((igoal (first igoal-desc)) ;; incomplete goal descrition
         (matched-goal-node (find-parent-to-match igoal)))
    (if (null matched-goal-node)
        nil
      (let ((mkb-method (get-goal-node-mkb-method matched-goal-node)))
        (when (not (null mkb-method))
	  (let ((source (get-mkb-method-name mkb-method))
	        (goal (get-goal-node-goal matched-goal-node))
	        (body (get-mkb-method-body mkb-method))
	        (capability (get-plan-capability
			 (get-mkb-method-plan mkb-method)))
	        (result (get-mkb-method-expected-result mkb-method)))
	    (make-goal-relation-node
	     :source source ;(generate-nl-description-of-plan-capability
		   ; (get-mkb-method-plan mkb-method))
	     :capability capability
	     :id (gentemp "goal")
	     :goal goal
	     :body body
	     :result result
	     :system-proposed t
	     :possible-users (list igoal-desc))))))))
	        
	  
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; find user defined but not used methods in method relation tree
;;

(defun find-unused-methods-and-extend-mr-tree ()
  (let ((ps-unused-method-names
         (mapcar #'get-plan-name-in-error-condition
	       (find-agenda-items-with-code 'unused-plan)))
        (methods-in-tree
         (find-method-names-in-method-relation-tree
	*mkb-ps-method-relation-tree-root* nil)))
    (let* ((unused-method-names
	  (set-difference ps-unused-method-names
		        methods-in-tree))
	 (ps-mr-nodes
	  (build-ps-tree-for-unused-methods unused-method-names
				      nil)))
      ;; add ps-mr-trees into *mkb-ps-method-relation-tree-root*
      (mapcar #'(lambda (node)
	      (if (not (null node))
		(add-goal-relation-node-child *mkb-ps-method-relation-tree-root*
				      node)))
	  ps-mr-nodes))
    )
  )

(defun find-method-names-in-method-relation-tree (root result)
  (let ((ps-node (find-node-in-tree
	        (get-goal-relation-node-id root)))
        (source (get-goal-relation-node-source root)))
    (if (and (not (null ps-node))
	   (equal (get-anode-type ps-node) 'method)
	   (not (member source result)))
        (push source result))
    (dolist (child (get-goal-relation-node-children root))
      (setq result
	  (find-method-names-in-method-relation-tree child result))))
  result)

(defun find-methods-not-in-tree (method-names tree-top)
  (let ((methods-in-tree
         (find-method-names-in-method-relation-tree
	tree-top nil)))
    (set-difference method-names methods-in-tree))
  )

(defun build-a-tree-for-method (method-name)
  (let ((mkb-node
         (find-goal-relation-node-in-mkb-mr-tree method-name)))
    (copy-tree mkb-node))
  )

(defun build-ps-tree-for-unused-methods (method-names trees)
  (let ((new-method-names
         (if (null trees)
	   method-names
	 (find-methods-not-in-tree method-names (first trees)))))
    (cond ((null new-method-names)
	 trees)
	(t
	 (let ((new-tree
	        (build-a-tree-for-method (first new-method-names))))
	   (build-ps-tree-for-unused-methods (rest new-method-names)
				       (push new-tree trees))))
	)))

;;;;;;;;;;;;
;; node stuff

(defun find-method-nodes-that-originated-node (n)
  (remove-duplicates
   (find-method-nodes-that-originated-node-1 n) :test #'equal))
 
(defun find-method-nodes-that-originated-node-1 (n)
  (if n
    (let* ((parents-method (remove-if-not
                            #'(lambda (p)
                                (and (anode-p p)
                                     (equal (get-anode-type p)
                                            'METHOD)))
                             (get-node-parents n)))
         (parents-no-method (set-difference (get-node-parents n)
                                              parents-method))
         (method-nodes
          (remove-if
            #'null
            (mapcar #'(lambda (an)
                      (if (and (get-anode-info an)
                             (get-method-info-struc-method
                              (get-anode-info an)))
                        an
                        nil))
                  parents-method))))
      ;(if *problem-solver-verbose* (format *terminal-io* "~% parents-method: ~S" parents-method))
      ;(if *problem-solver-verbose* (format *terminal-io* "~% parents-no-method: ~S" parents-no-method))
      (append method-nodes
            (remove-duplicates
             (mapcan #'find-method-nodes-that-originated-node-1
                   parents-no-method) :test #'equal))
      )
    nil))


