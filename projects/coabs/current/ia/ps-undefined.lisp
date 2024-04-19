(in-package "EXPECT")

;;; ************************************
;;; support functions to build method-relation tree based on PS-tree
;;; ************************************
(defvar *mkb-ps-undefined-goal-list* nil)

(defvar *show-all-rfml* nil)


;; *********************************
;; compute undefined capabilities
;; *********************************

(defun find-callers (anode)
  (let ((callers (remove-duplicates
		  (find-name-of-methods-that-originated-node
		   anode))))
    (if (null callers)
	(list 'top-level-goal-unachieved)
      callers)))

(defun get-rfml-type (node)
  (if (enode-p node)
      nil
    (let ((node-type (get-anode-type node)))
      (if (member node-type *rfml-kinds*)
	(list node-type)
        nil)))
  )

(defun find-rfmls-involved (n caller rfmls)
  (cond ((null n)
         nil)
        ;((and (anode-p n)
        ;	    (equal (get-node-type n) 'input))
        ; nil)
        (t
          (find-rfmls-involved-1 n caller rfmls))))

(defun find-rfmls-involved-1 (n caller rfmls) ;; rfml so far
  (let* ((parents-method (remove-if-not
			    #'(lambda (p)
				(and (anode-p p)
				     (equal (get-anode-type p)
					    'METHOD)))
			     (get-node-parents n)))
         (parents-no-method (set-difference (get-node-parents n)
					      parents-method))
         (method-names
	(remove-if
	 #'null
	 (mapcar #'(lambda (an)
		     (if (and (get-anode-info an)
			    (get-method-info-struc-method
			     (get-anode-info an)))
		         (get-ps-plan-name
			  (get-method-info-struc-method 
			   (get-anode-info an)))
		       nil))
	         parents-method))))

    (cond ((member caller method-names)
	 rfmls)
	((null parents-no-method)
	 nil)
	(t (mapcan
	    #'(lambda (p)
	        (find-rfmls-involved p caller
			         (append rfmls
				       (get-rfml-type p))))
	    parents-no-method
	    ))))

)

(defun find-rfmls-involved-for-caller (node caller)
  (let ((rfmls (find-rfmls-involved node caller nil)))
    (if (null rfmls)
        nil
      (list (list caller rfmls)))))

(defun compute-rfmls-for-callers (node callers)
  (subst 'covering-or-input 'covering 
         (mapcan #'(lambda (c)
		 (find-rfmls-involved-for-caller node c))
	       callers)))


;;;;;;;;;
;; warning : this may be a hack
;; these functions check if set rfml has a match
;; to not include the expr in the undefined goal list
(defun find-set-anode (anodes)
  (cond ((null anodes)
	 nil)
	((eq (get-anode-type (first anodes)) 'set)
	 (first anodes))
	(t (find-set-anode (rest anodes)))))

(defun check-if-set-anode-used (en)
  (let ((set-anode (find-set-anode (get-enode-failed en))))
    (if (null set-anode)
	nil
      (rfml-used set-anode)))
  )


;;**********************************************
;; find subgoals of enodes
;;**********************************************

(defun get-node-valid-result (node)
  (let ((result (get-node-result node)))
    (if (not (null result))
	result
      'undefined)))


;; record expanded-expr when some child failed
;; this can be used for proposing potential match
;; -- not used yet
(defun ia-add-node-has-failed (node reason)
  (when (and (enode-p node) (eq reason 'some-child-failed))
    (let ((new-expr (copy-tree (get-enode-expr node)))
	  (subexprs-and-results (mapcar #'(lambda (c)
                                          (list (get-enode-expr c)
                                                (get-node-valid-result c)
				        c))
                                      (get-node-children node))))
      (set-failed-expr node (find-expansion-of-expr new-expr subexprs-and-results)
		       
      ))
    ;;(find-node-subgoals node) ; test
    )
  (add-node-has-failed node reason)
)

(defun filter-out-relation-exprs (exprs-and-results)
  (let ((result nil))
    (dolist (e-r exprs-and-results)
      (let ((expr (first e-r)))
	(when (and (listp expr) (lexicon-goal-p (first expr)))
	  (push e-r result))))
    result))



(defun compute-node-subgoals (node)
  (when (not (null node))
    (let* ((expr (get-node-expanded-expr node))
	   (children (get-node-children node))
	   
	   (subexprs-and-results 
	    (filter-out-relation-exprs
	     (mapcar #'(lambda (c)
			 (list (if (get-enode-expanded-expr c)
				   (get-enode-expanded-expr c)
				   (get-enode-expr c))
			       (get-node-valid-result c)
			       ))
		     children))))
      ;(if *problem-solver-verbose* (format *terminal-io* "~% e-r: ~S " subexprs-and-results))
      (cond ((enode-p node)
	     (remove-duplicates
	      (let ((sub-subgoals nil))  ;; get sub-goals from children
	       (dolist (child children)
		 (setq sub-subgoals
			(append sub-subgoals (compute-node-subgoals child))))
	       (if (null expr)
		   (append sub-subgoals subexprs-and-results 
			   (filter-out-relation-exprs 
			    (list (list (get-failed-expr node) 'undefined))))
		 (append sub-subgoals subexprs-and-results 
			 (filter-out-relation-exprs 
			  (list (list expr (get-node-valid-result node)))))))
	      :test #'equal))
	  (t ; rfml
	   subexprs-and-results)))))

(defun find-node-subgoals (node)
   (cond ((null node)
	 nil)
	((and (anode-p node) 
	      (eq (get-anode-type node) 'method))
	 (compute-node-subgoals (first (get-node-children node))))
	((enode-p node)
	 nil)
	(t ;;rfml anodes
	 (compute-node-subgoals node)))
)

;;************************************
;; print functions
;;************************************
(defun print-node-subgoals-for-tree-summary (mark n level stream)
  (let ((subgoals (find-node-subgoals n)))
    (when (not (null subgoals))
      (print-indent-for-node level stream)
      (when mark (format stream " "))
      (print-node-short n 0 stream)
      (dolist (subgoal subgoals)
	(format stream "~%")
	(print-indent-for-node level stream)
	(format stream " **SUB-GOAL** ~A" subgoal))
      (format stream "~%"))
    subgoals
  ))


;;; updated 2/17/00
;; to directly use ps-tree to find undefined methods
(defun undefined-method-node (n)
  (when (and (anode-p n)
	     (equal (get-anode-type n) 'method)
	     (not (get-anode-info n))
	     (any-parent-failed n))
    (let ((ug-node 
	   (undefined-method-node-1 n *mkb-ps-undefined-goal-list*)))
      (if (null ug-node)
	  (create-ps-undefined-method n)
	ug-node))))

(defun create-ps-undefined-method (anode)
  (let ((callers (find-callers anode))
	(ugoal (get-anode-expr anode))
	(result (compute-node-expected-result anode))) ;;
    (first (push (make-undefined-goal
		     :goal ugoal
		     :expected-result result;; TTD
		     :callers callers
		     :ps-node anode
		     ;;(find-method-nodes-that-originated-node anode)
		     :rfml-types (compute-rfmls-for-callers anode callers)
		     :id (gentemp "method")
		     :capability-sketch
		     (create-goal-desc-from-simplified-goal ugoal)
		     )
	      *mkb-ps-undefined-goal-list*))))

(defun any-parent-failed (node)
  (let ((parents (get-node-parents node))
	(result nil))
    (dolist (parent parents)
      (if (undefined-p (get-node-result parent))
	  (setq result t)))
    result))

;;; end of update


(defun undefined-method-node-1 (n undefined-goals)
  (cond ((null undefined-goals)
	 nil)
	((equal n (get-undefined-goal-ps-node (first undefined-goals)))
	 (first undefined-goals))
	(t (undefined-method-node-1 n (rest undefined-goals)))))

(defun method-node-expanded (n)
  (or (eq (get-anode-expanded n) 'result)
      (get-anode-children n)))

(defun non-trivial-node (n)
  (cond ((anode-p n)
	 (cond ((eq (get-anode-type n) 'input)
	       	nil)
	       ((eq (get-anode-type n) 'method)
		(method-node-expanded n))
	       (t (if *show-all-rfml*
		      't
		    (rfml-used n)))))
	(t ;; enode
	 't)))
		
(defun trivial-node (n)
  (if (anode-p n)
      (non-trivial-node n)
    't))

;;;
(defun display-node-for-tree-goal (mark n level stream)
  (if (non-trivial-node n)
      (display-node-for-tree-goal-aux mark n level stream)
    ;; propose dummy method
    (let ((undefined-goal (undefined-method-node n)))
      (if (not (null undefined-goal))
	(let ((gr-node
	       (make-goal-relation-node
		:source (get-undefined-goal-id undefined-goal)
		:id (get-node-name n)
		:goal (get-undefined-goal-goal undefined-goal)
		:capability (get-node-expr n)
		:body nil
		:result (get-undefined-goal-expected-result undefined-goal)
		:system-proposed t)))
	  (print-label-for-tree-summary "*** NO METHOD FOUND ***"
					mark n level stream)
	  (add-gr-node-to-gr-tree gr-node n level))
	))
    )
)

(defun display-node-for-tree-goal-aux (mark n level stream)
    (print-node-expr-for-tree-summary  mark n level stream)
    (if *building-mkb-ps-method-relation-tree*
      (ps-add-goal-relation-node n level
			    (print-node-subgoals-for-tree-summary mark n level stream)
			    )
      (print-node-subgoals-for-tree-summary mark n level stream))
    (when (and (anode-p n)
	       (equal (get-anode-type n) 'method)
	       (not (get-anode-info n))
	       (not (equal mark "?")))
      (print-label-for-tree-summary "*** NO METHOD FOUND ***" mark n level stream))
  )

;
(defun display-anode-short (an &optional (level 0) (stream *terminal-io*))
  (when (not (eq (get-anode-type an) 'input))
    (when stream
      (print-indent-for-node level stream))
    (format stream "[~A: ~A~A" 
	    (if (eq (get-anode-type an) 'covering)
	      ""
	      (get-anode-name an))
	    (if (eq (get-anode-type an) 'covering)
		'covering-or-input
		(get-anode-type an))
	    (if (equal (get-anode-type an) 'RETRIEVE)
            (format nil "-~S]" 
                    (let ((mode (get-rel-info-struc-retrieval-mode 
                                   (get-anode-info an))))
                      (if (equal mode 'RANGE) 
			  'R 'V)))
            (format nil "]" (get-anode-info an))))
    )
)

;;;;;;;;;;; from print.lisp in ui
(defun display-tree-goals (&optional (n *ps-tree*) (level 0) (stream *terminal-io*))
  (when (and n 
	     (non-trivial-node n))
    (display-tree-goals-aux n level stream))
)

(defun display-tree-goals-aux (&optional (n *ps-tree*) (level 0) (stream *terminal-io*))
  (cond (n
         (mapcar #'(lambda (c)
                     (display-tree-goals c level stream))
		 (get-node-children n))
         (when (enode-p n)
	   ;; display failed nodes first, different from print-tree function
	   (when (get-enode-failed n)
             (mapcar #'(lambda (f)
			 (let ((l level))
			   (when (or (equal (get-anode-type f) 'method)
				     (and (member (get-anode-type f) *rfml-kinds*)
					  (get-anode-info f)))
			     (print-node-in-ui f
					       #'display-node-for-tree-goal
						(list 'X f level stream)
						stream)
			     (setf l (+ 1 l)))
			   (display-tree-goals f (+ 1 level) stream)))
		      (reverse (get-enode-failed n))))
           (when (get-enode-current n)
	     (let ((c (get-enode-current n))
		   (l level))
	       (when (or (equal (get-anode-type c) 'method)
			 (and (member (get-anode-type c) *rfml-kinds*)
			      (get-anode-info c)))
		 (print-node-in-ui c
				   #'display-node-for-tree-goal
				   (list '- c l stream)
				   stream)
		 (setf l (+ 1 l)))
	       (display-tree-goals c l stream)))
	   (when (get-enode-not-tried n)
             (mapcar #'(lambda (x)
			 (when (or (equal (get-anode-type x) 'method)
				   (and (member (get-anode-type x) *rfml-kinds*)
					(get-anode-info x)))
			   (print-node-in-ui x
					     #'display-node-for-tree-goal
					      (list '? x level stream)
					      stream)))
		      (get-enode-not-tried n)))))
        (t
         nil)))


;;***************************************
;; check if rfml is complete
;;***************************************

;; given a rfml anode, check if the subexprs are matched
(defun rfml-used (anode)
  (if (null (get-anode-children anode))
      nil
    (check-rfml-used (get-anode-children anode)))
)

(defun check-rfml-used (enodes)
  (cond ((null enodes)
	 't)
	((expr-matched (first enodes))
	 (check-rfml-used (rest enodes)))
	(t nil)))

(defun goal-expr-nodes (enode)
  (let ((children (get-enode-children enode)))
    (cond ((null children)
	   (list enode))
	  (t 
	   (let ((result nil))
	     (dolist (child children)
	       (if (eq (get-enode-type child) 'goal)
		   (append result (goal-expr-nodes child)))
))))))
	
;; to check if a subexpr is matched, 
;; first collect all the goal node in the subtree,
;; and then check if each of them can match a method
;;  or its subexpr are matched (recursively) 	  
(defun expr-matched (enode)
  (let ((result 't)
	(enodes (goal-expr-nodes enode)))
    ;(if *problem-solver-verbose* (format *terminal-io* "~% +++ enodes:~S" enodes))
    (dolist (node enodes)
      (setq result 
	    (and result (or (eq (get-enode-expanded node) 'result)
			    (any-anode-has-match node)))))
    result))
    


(defun any-anode-has-match (enode)
  (let ((result nil)
	(anodes (get-enode-failed enode)))
    (dolist (node anodes)
      (setq result
	    (or result 
		(cond ((eq (get-anode-type node) 'method)
		       (not (null (get-anode-children node))))
		      (t (rfml-used node))))))
    result))
  

;;***************************************
;; compute expected result
;; for all enodes and anodes
;;***************************************
;;; this should be extended in the future 
;;; to support other ways of computing expected result
;;;
;;  for the child of a method node which is an enode, 
;;    the expected result is the same as the defined result of the method
;;  if a method node (anode)'s parent has a known expected result,
;;    it will be the expected result of the method.

(defun find-common-result (edts)
  (let ((result 'undefined))
    (dolist (edt edts)
      (setq result (mkb-find-common-edt result edt)))
    result)
)

(defun compute-node-expected-result (node)
  (if (and (anode-p node)
	   (eq (get-anode-type node) 'METHOD)
	   (get-anode-info node))
      (find-result-method-as-defined
       (get-method-info-struc-method (get-anode-info node))
       (get-method-info-struc-bindings (get-anode-info node)))
    (let ((parents (get-node-parents node))
	  (edts nil))
      (dolist (parent parents)
	(push (find-expected-result parent node) edts))
      (find-common-result edts))
    ))
      
(defun find-expected-result (parent node)
  (cond ((and (anode-p parent) ;; parent is a method
	      (eq (get-anode-type parent) 'METHOD))
	 (compute-node-expected-result parent))
	((and (anode-p node)  ;; the node is an undefined method
	      (eq (get-anode-type node) 'METHOD))
	 (compute-node-expected-result parent))
	((and (anode-p node)  ;; the node is a covering or input rfml
	      (or (eq (get-anode-type node) 'COVERING)
		  (eq (get-anode-type node) 'INPUT)))
	 (compute-node-expected-result parent))
	((and (anode-p node)  ;; the node is a set rfml
	      (eq (get-anode-type node) 'SET))
	 (let ((parent-expected-result (compute-node-expected-result parent)))
	   (if (set-p parent-expected-result)
	       (second parent-expected-result)
	     'undefined)))
	((and (anode-p parent)  ;; the parent is a covering or input rfml
	      (or (eq (get-anode-type parent) 'COVERING)
		  (eq (get-anode-type parent) 'INPUT)))
	 (compute-node-expected-result parent))
	((and (anode-p parent)  ;; the parent is a set rfml
	      (eq (get-anode-type parent) 'SET))
	 (let ((parent-expected-result (compute-node-expected-result parent)))
	   (if (set-p parent-expected-result)
	       (second parent-expected-result)
	     'undefined)))
	((enode-p parent)
	 (find-potential-arg-result-type (get-node-expr node)
					 (get-node-expr parent)))
	(t 'undefined))
)

;;;;;;;;;;;;;;;;;;;;;;
;; create a template method for undefined goal
(defun create-template-method-for-undefined-goal (name-in-string)
   (let ((*package* (find-package "EXPECT")))
    (cond ((invalid-lisp-object name-in-string)
	   (signal-message 'invalid-expr nil name-in-string)
	   (add-messages *mkb-messages*)
	   (send-messages *mkb-messages* nil nil))
	  (t
	   (let ((result
		  (create-template-method-for-undefined-goal-1
		   (read-from-string name-in-string))))
	     (if (null result)
		(send-messages nil nil
			       (read-from-string name-in-string))
	       (send-messages nil t result))
	     )
	  ))))

(defun find-undefined-goal-with-proposed-method-name (name)
  (let ((the-ug nil))
    (dolist (ug *mkb-ps-undefined-goal-list*)
      (if (name-equal (get-undefined-goal-id ug)
		      name)
	  (setq the-ug ug)))
    the-ug))

(defun create-template-method-for-undefined-goal-1 (name)
  (let ((the-ug (find-undefined-goal-with-proposed-method-name name)))
    (cond ((null the-ug)
	   nil)
	  (t
	   (let ((new-plan 
		  (expect::create-plan
		   name
		   (second (get-undefined-goal-capability-sketch the-ug))
		   (get-undefined-goal-expected-result the-ug)
		   (create-instance-of-edt
		    (get-undefined-goal-expected-result the-ug)))))
	     (ka-process-plan-modification 
	      (list 'accept-plan new-plan))
	     name))
	     )))