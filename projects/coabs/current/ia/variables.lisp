(in-package "EXPECT")

;;; ************************************
;;; mkb collects methods before commited to ka and ps
;;; ************************************

(defvar *mkb-verbose* nil)
(defvar *mkb-very-verbose* nil)

(defvar *mkb-method-kb* nil)

(defvar *local-method-errors* nil)

(defvar *temporary-concepts* nil)

(defvar *mkb-messages* nil)
(defvar *all-messages* nil)

(defvar *defining-system-plans* nil)
(defvar *user-defined-methods--name* nil)
(defvar *system-defined-methods--name* nil)


(defvar *mkb-method-list* nil) ;; list of mkb-methods

(defvar *mkb-ps-potential-match-for-incomplete-goals* nil)
(defvar *applied-potential-match* nil)
(defvar *mkb-undefined-goals-from-rfml* nil)
(defvar *ps-undefined-goals* nil)

(defun mkb-start-method-edit()
  (setq *mkb-method-list* nil)
  (setq *mkb-capability-tree-root* (make-goal-node
				  :goal nil
				  ))
  (setq *mkb-method-relation-tree-root* (make-goal-relation-node
				 :source nil
				 :children nil))
  (setq *mkb-undefined-goal-list* nil)
  (setq *mkb-undefined-goals-from-rfml* nil)
  (setq *ps-undefined-goals* nil)
  (setq *partial-match* nil)
  (setq *defining-system-plans* nil)
  (setq *user-defined-methods--name* nil)
  (setq *system-defined-methods--name* nil)
  (setq *mkb-ps-undefined-goal-list* nil)
  (setq *mkb-ps-potential-match-for-incomplete-goals* nil)
  (setq *applied-potential-match* nil)
  
  (setq *mkb-ps-method-relation-tree-root* nil)
  (setq *building-mkb-ps-method-relation-tree* nil)
  (setq *mkb-current-node-list* nil)
  (setq *usable-goal-nodes* nil)
  )
(defun mkb-delete-user-defined-methods() 
  (dolist (method-desc *mkb-method-list*)
	  (if (not (get-mkb-method-system-p (second method-desc)))
	      (delete-plan (format nil "~S" (first method-desc)))))
)

(defun mkb-delete-system-defined-methods() 
  (dolist (method-desc *mkb-method-list*)
	  (if (get-mkb-method-system-p (second method-desc))
	      (delete-plan (format nil "~S" (first method-desc)))))
)

;;*******************************************************************
;;; data structure for methods in progress
;;; this structure will be shared for different views of methods
;;; such as 1) capability hierarchy,
;;;         2) method-submethod relationship
;;;         3) missing methods
;;*******************************************************************



(defstruct (mkb-method  ;; how methods can be used in problem solving
	    (:print-function print-mkb-method))
  name               ; method name
  goal               ; simplified goal
  expected-result    ; result type
  current-result     ; computed edt based on curent ontology and other methods
  users              ; list of plan names that use this goal in the body
  possible-users     ; users after reformulation
  subgoals           ; subgoals in the body
  undefined-subgoals ; undefined subgoals in the body
  plan               ; ka plan
  system-p           ; system defined or user defined
  )

(defun print-mkb-method (mkb-method-struc &optional (stream *terminal-io*)
					  (debug-level *print-level*))
  (declare (ignore debug-level))
  (format stream "~%[ mkb-method: id: ~S;~% goal: ~S;~% expected-result: ~S;~% current-result: ~S;~% users: ~S;~% possible-users: ~S;~% subgoals: ~S;~% system-p: ~S;~%]"
	  (get-mkb-method-name mkb-method-struc)
	  (get-mkb-method-goal mkb-method-struc)
	  (get-mkb-method-expected-result mkb-method-struc)
	  (get-mkb-method-current-result mkb-method-struc)
	  (get-mkb-method-users mkb-method-struc)
	  (get-mkb-method-possible-users mkb-method-struc)
	  (get-mkb-method-subgoals mkb-method-struc)
	  (get-mkb-method-system-p mkb-method-struc)
	  )
  )

(defun get-mkb-method-name (mkb-method)
  (mkb-method-name mkb-method))

(defun set-mkb-method-name (mkb-method value)
  (setf (mkb-method-name mkb-method) value))

(defun get-mkb-method-goal (mkb-method)
  (mkb-method-goal mkb-method))

(defun set-mkb-method-goal (mkb-method value)
  (setf (mkb-method-goal mkb-method) value))

(defun get-mkb-method-expected-result (mkb-method)
  (mkb-method-expected-result mkb-method))

(defun set-mkb-method-expected-result (mkb-method value)
  (setf (mkb-method-expected-result mkb-method) value))

(defun get-mkb-method-current-result (mkb-method)
  (mkb-method-current-result mkb-method))

(defun set-mkb-method-current-result (mkb-method value)
  (setf (mkb-method-current-result mkb-method) value))

(defun get-mkb-method-users (mkb-method)
  (mkb-method-users mkb-method))

(defun set-mkb-method-users (mkb-method value)
  (setf (mkb-method-users mkb-method) value))

(defun get-mkb-method-possible-users (mkb-method)
  (mkb-method-possible-users mkb-method))

(defun set-mkb-method-possible-users (mkb-method value)
  (setf (mkb-method-possible-users mkb-method) value))

(defun add-mkb-method-possible-user (mkb-method value)
  (pushnew value (mkb-method-possible-users mkb-method)))
;;  (set-mkb-method-possible-users mkb-method
;;   (append (list value) (get-mkb-method-possible-users mkb-method))))

(defun get-mkb-method-undefined-subgoals (mkb-method)
  (mkb-method-undefined-subgoals mkb-method))

(defun set-mkb-method-undefined-subgoals (mkb-method value)
  (setf (mkb-method-undefined-subgoals mkb-method) value))

(defun get-mkb-method-subgoals (mkb-method)
  (mkb-method-subgoals mkb-method))

(defun set-mkb-method-subgoals (mkb-method value)
  (setf (mkb-method-subgoals mkb-method) value))

(defun get-mkb-method-plan (mkb-method)
  (mkb-method-plan mkb-method))

(defun set-mkb-method-plan (mkb-method value)
  (setf (mkb-method-plan mkb-method) value))

(defun get-mkb-method-system-p (mkb-method)
  (mkb-method-system-p mkb-method))

(defun get-mkb-method-capability (mkb-method)
  (let ((plan (get-mkb-method-plan mkb-method)))
    (if (null plan)
	nil
      (get-plan-capability plan))))

(defun get-mkb-method-body (mkb-method)
  (let ((plan (get-mkb-method-plan mkb-method)))
    (if (null plan)
	nil
      (get-plan-method plan))))
	      
;;*******************************************************************
;;; data structure for maintaining capability hierarchy
;;*******************************************************************
(defstruct (goal-node
	     (:print-function print-goal-node))
  goal          ; simplified goal
  desc          ; goal description in NL
  mkb-method    ; pointer to the mkb-method, if there is a method
  children      ; list of children with the same structure
  parent        ; one parent
  defined-p     ; if the goal is defined as capability
  )

#|
(defun print-goal-node (goal-node-struc &optional (stream *terminal-io*)
			    (debug-level *print-level*))
  (declare (ignore debug-level))
  (format stream "~%[ goal-node: goal: ~S;~% children: ~S;~% capability?: ~S;~%]"
	  (get-goal-node-goal goal-node-struc)
	  (get-goal-node-children goal-node-struc)
	  (get-goal-node-defined-p goal-node-struc)
	  ))
|#
(defun print-goal-node (goal-node-struc &optional (stream *terminal-io*)
			    (debug-level *print-level*))
  (declare (ignore debug-level))
  (format stream "~%[ goal-node: goal: ~S;~% method: ~S;~%]"
	  (get-goal-node-goal goal-node-struc)
	  (get-goal-node-mkb-method goal-node-struc)
	  ;(get-goal-node-defined-p goal-node-struc)
	  ;(get-goal-node-children goal-node-struc)
	  ))

(defun get-goal-node-goal (goal-node)
  (goal-node-goal goal-node))

(defun set-goal-node-goal (goal-node value)
  (setf (goal-node-goal goal-node) value))

(defun get-goal-node-children (goal-node)
  (goal-node-children goal-node))

(defun set-goal-node-children (goal-node value)
  (setf (goal-node-children goal-node) value))

(defun get-goal-node-desc (goal-node)
  (goal-node-desc goal-node))

(defun set-goal-node-desc (goal-node value)
  (setf (goal-node-desc goal-node) value))

(defun get-goal-node-parent (goal-node)
  (goal-node-parent goal-node))

(defun set-goal-node-parent (goal-node value)
  (setf (goal-node-parent goal-node) value))

(defun get-goal-node-mkb-method (goal-node)
  (goal-node-mkb-method goal-node))

(defun set-goal-node-mkb-method (goal-node value)
  (setf (goal-node-mkb-method goal-node) value))

(defun get-goal-node-defined-p (goal-node)
  (goal-node-defined-p goal-node))

(defun set-goal-node-defined-p (goal-node value)
  (setf (goal-node-defined-p goal-node) value))

(defun add-child-to-goal-node (goal-node child)
  (setf (goal-node-children goal-node)
	(push child (goal-node-children goal-node))))

(defun get-goal-node-definer (goal-node)
  (if (eq goal-node *mkb-capability-tree-root*)
      nil
    (let ((mkb-method (get-goal-node-mkb-method goal-node)))
      (if (null mkb-method)
	  'system
	(get-mkb-method-name mkb-method)))
    ))

(defvar *mkb-capability-tree-root* (make-goal-node
				  :goal nil
				  ))


;;; *******************************************************
;;; build goal caller-callee tree 
;;; *******************************************************
(defstruct (goal-relation-node
	    (:print-function print-goal-relation-node))
  source      ;; method name or rfml type
  id          ;; ps node name, if the tree is built from ps-tree
              ;; otherwise, same as source
  goal
  capability  ;; used for method node only
  body        ;; used for method node only
  result
  result-obtained
  possible-users
  subgoals
  mkb-method
  children
  system-proposed
  )

(defun print-goal-relation-node (goal-relation-node &optional (stream *terminal-io*)
			    (debug-level *print-level*))
  (declare (ignore debug-level))
  (format stream "~%[ goal-relation-node: name: ~S;~% id: ~S;~% goal: ~S;~% body: ~S;~% expected-result: ~S;~% result-obtained: ~S;~% possible-callers: ~S;~% subgoals: ~S;~% system-proposed: ~S;~% children: ~S;~%]"
  ;(format stream "~%[ goal-relation-node: name: ~S;~% id: ~S;~% goal: ~S;~% body: ~S;~% expected-result: ~S;~% result-obtained: ~S;~% possible-callers: ~S;~% subgoals: ~S;~% system-proposed: ~S;~%]"
	  (get-goal-relation-node-source goal-relation-node)
	  (get-goal-relation-node-id goal-relation-node)
	  (get-goal-relation-node-goal goal-relation-node)
	  (get-goal-relation-node-body goal-relation-node)
	  (get-goal-relation-node-result goal-relation-node)
	  (get-goal-relation-node-result-obtained goal-relation-node)
	  (get-goal-relation-node-possible-users goal-relation-node)
	  (get-goal-relation-node-subgoals goal-relation-node)
	  (get-goal-relation-node-system-proposed goal-relation-node)
	  (get-goal-relation-node-children goal-relation-node)
	  
	  ))

(defun get-goal-relation-node-source (goal-relation-node)
  (goal-relation-node-source goal-relation-node))

(defun get-goal-relation-node-id (goal-relation-node)
  (goal-relation-node-id goal-relation-node))

(defun get-goal-relation-node-goal (goal-relation-node)
  (goal-relation-node-goal goal-relation-node))

(defun get-goal-relation-node-capability (goal-relation-node)
  (goal-relation-node-capability goal-relation-node))

(defun get-goal-relation-node-body (goal-relation-node)
  (goal-relation-node-body goal-relation-node))

(defun get-goal-relation-node-children (goal-relation-node)
  (goal-relation-node-children goal-relation-node))

(defun get-goal-relation-node-system-proposed (goal-relation-node)
  (goal-relation-node-system-proposed goal-relation-node))

(defun get-goal-relation-node-result (goal-relation-node)
  (goal-relation-node-result goal-relation-node))

(defun get-goal-relation-node-result-obtained (goal-relation-node)
  (goal-relation-node-result-obtained goal-relation-node))

(defun get-goal-relation-node-mkb-method (goal-relation-node)
  (goal-relation-node-mkb-method goal-relation-node))

(defun get-goal-relation-node-possible-users (goal-relation-node)
  (goal-relation-node-possible-users goal-relation-node))

(defun set-goal-relation-node-possible-users (goal-relation-node value)
  (setf (goal-relation-node-possible-users goal-relation-node) value))

(defun set-goal-relation-node-result (goal-relation-node value)
  (setf (goal-relation-node-result goal-relation-node) value))

(defun set-goal-relation-node-subgoals (goal-relation-node value)
  (setf (goal-relation-node-subgoals goal-relation-node) value))

(defun get-goal-relation-node-info (goal-relation-node)
  (append (get-goal-relation-node-goal goal-relation-node)
	  (get-goal-relation-node-body goal-relation-node)))

(defun get-goal-relation-node-subgoals (goal-relation-node)
  (goal-relation-node-subgoals goal-relation-node))

(defun add-child-to-goal-relation-node (child parent)
  (if (not (member child (get-goal-relation-node-children parent) :test #'equal))
      (setf (goal-relation-node-children parent)
	    (push child (goal-relation-node-children parent))))
  )

(defvar *mkb-method-relation-tree-root* (make-goal-relation-node
				 :source nil
				 :children nil))


;;*******************************************************************
;;; data structure for maintaining undefined goals
;;*******************************************************************
(defstruct (undefined-goal
	     (:print-function print-undefined-goal))
  goal            ; simplified goal
  expected-result ;
  rfml-types      ; not used?
  ps-node         ; pointer to the ps node that needed the goal
  callers         ; names of mkb-methods that has this as a subgoal
  id              ; system-generated id (starts with "method")
  unmatched-rfmls  ; reformulations
  all-rfmls
  capability-sketch
  )

(defun print-undefined-goal (undefine-goal-struc
			     &optional (stream *terminal-io*)
			     (debug-level *print-level*))
  (declare (ignore debug-level))
  (format stream "~%[ undefined-goal: goal: ~S;~% system-name: ~S;~% expected-result: ~S;~% callers: ~S;~% unmatched-rfmls: ~S;~% ps-node: ~S;~%]"
	  (get-undefined-goal-goal undefine-goal-struc)
	  (get-undefined-goal-id undefine-goal-struc)
	  (get-undefined-goal-expected-result undefine-goal-struc)
	  (get-undefined-goal-callers undefine-goal-struc)
	  (get-undefined-goal-unmatched-rfmls undefine-goal-struc)
	  (get-undefined-goal-ps-node undefine-goal-struc)
	  ))

(defun get-undefined-goal-goal (undefined-goal)
  (undefined-goal-goal undefined-goal))

(defun set-undefined-goal-goal (undefined-goal value)
  (setf (undefined-goal-goal undefined-goal) value))

(defun get-undefined-goal-expected-result (undefined-goal)
  (undefined-goal-expected-result undefined-goal))

(defun set-undefined-goal-expected-result (undefined-goal value)
  (setf (undefined-goal-expected-result undefined-goal) value))

(defun get-undefined-goal-callers (undefined-goal)
  (undefined-goal-callers undefined-goal))

(defun set-undefined-goal-callers (undefined-goal value)
  (setf (undefined-goal-callers undefined-goal) value))

(defun get-undefined-goal-rfml-types (undefined-goal)
  (undefined-goal-rfml-types undefined-goal))

(defun set-undefined-goal-rfml-types (undefined-goal value)
  (setf (undefined-goal-rfml-types undefined-goal) value))

(defun get-undefined-goal-unmatched-rfmls (undefined-goal)
  (undefined-goal-unmatched-rfmls undefined-goal))

(defun set-undefined-goal-unmatched-rfmls (undefined-goal value)
  (setf (undefined-goal-unmatched-rfmls undefined-goal) value))

(defun get-undefined-goal-capability-sketch (undefined-goal)
  (undefined-goal-capability-sketch undefined-goal))

(defun set-undefined-goal-capability-sketch (undefined-goal value)
  (setf (undefined-goal-capability-sketch undefined-goal) value))

#|
(defun get-undefined-goal-all-rfmls (undefined-goal)
  (undefined-goal-all-rfmls undefined-goal))

(defun set-undefined-goal-all-rfmls (undefined-goal value)
  (setf (undefined-goal-all-rfmls undefined-goal) value))
|#
(defun get-undefined-goal-ps-node (undefined-goal)
  (undefined-goal-ps-node undefined-goal))

(defun get-undefined-goal-id (undefined-goal)
  (undefined-goal-id undefined-goal))


(defvar *mkb-undefined-goal-list* nil) ;; goals not defined

(defun find-undefined-goal (goal undefined-goal-list)
  (cond ((null undefined-goal-list)
	 nil)
	((equal goal (get-undefined-goal-goal (first undefined-goal-list)))
	 (first undefined-goal-list))
	(t (find-undefined-goal goal (rest undefined-goal-list)))
	))

(defun delete-undefined-goal (goal caller)
  (let ((result nil))
    (dolist (undefined-goal *mkb-undefined-goal-list*)
      (cond ((equal goal (get-undefined-goal-goal undefined-goal))
	     (set-undefined-goal-callers undefined-goal
	      (remove caller (get-undefined-goal-callers undefined-goal)))
	     (if (not (null (get-undefined-goal-callers undefined-goal)))
		 (push undefined-goal result)))
	    (t (push undefined-goal result))))
    (setq *mkb-undefined-goal-list* result)
  ))

(defun add-undefined-goal-caller (undefined-goal value)
  (if (not (member value
		   (get-undefined-goal-callers undefined-goal)))
      (push value (undefined-goal-callers undefined-goal))))

(defun add-undefined-goal-callers (undefined-goal values)
  (dolist (value values)
    (add-undefined-goal-caller undefined-goal value)))

;(defun reformulations-of-goal (goal)
;  (let ((rfmls (union (cadar (generate-set-reformulations-for-goal goal nil))
;		      (cadar (generate-covering-reformulations-for-goal goal nil)))))
;    (if (not (null rfmls))
;	(append rfmls (mapcan #'reformulations-of-goal rfmls))))
;  
;  )

(defun create-undefined-goal (goal caller expected-result
				   &optional rfml-unmatched)
  (let ((ugoal (find-undefined-goal goal *mkb-undefined-goal-list*)))
    (cond ((null ugoal)
	   (if (not (member 'undefined (flatten goal)))
	       (push (make-undefined-goal
		      :goal goal
		      :expected-result expected-result
		      :callers (list caller)
		      :id (gentemp "_method")
		      :unmatched-rfmls rfml-unmatched
		      :capability-sketch
		      (create-goal-desc-from-simplified-goal goal)
		      )
		     *mkb-undefined-goal-list*)
	     (if *problem-solver-verbose* (format *terminal-io* "~% tried to add invalid undefined-goal ~S"
		     goal))))
	  (t (add-undefined-goal-caller ugoal caller)))
    ))


;;*******************************************************************
(defun find-goal-relation-node-in-mkb-mr-tree (method-name)
  (find-goal-relation-node method-name
		(get-goal-relation-node-children
		 *mkb-method-relation-tree-root*)))

(defun find-goal-relation-node (name cands)
  (if *mkb-very-verbose*
      (if *problem-solver-verbose* (format *terminal-io* "~% find-goal-relation-node for ~S" name)))
  (if (null cands) ;; this should not happen
      (if *problem-solver-verbose* (format *terminal-io* "~% ERROR::could not find node for ~S" name))
    
    (let ((cand (first cands)))
      (cond ((eq (get-goal-relation-node-source cand) name)
	   cand)
	  (t (find-goal-relation-node name (append (get-goal-relation-node-children cand)
					   (rest cands))))))))
;;; rebuild  *mkb-method-relation-tree-root*

  
(defun build-method-relation-tree ()
  (setq *mkb-method-relation-tree-root* (make-goal-relation-node
				 :source nil
				 :children nil))
  (dolist (g-info (reorder-defined-goals *mkb-method-list*))
    (if *mkb-verbose*
	(if *problem-solver-verbose* (format *terminal-io* "~% create method-relation node for ~S" g-info)))
    (let* ((mkb-method (second g-info))
	   (plan (get-mkb-method-plan mkb-method))
	   (method-name (first g-info))
	   (goal-relation-node
	    (make-goal-relation-node
	     :source method-name
	     :id method-name
	     :goal (get-mkb-method-goal mkb-method)
	     :capability (get-plan-capability plan)
	     :body (if (null (get-mkb-method-system-p mkb-method)) (get-plan-method plan))
	     :result (get-plan-result plan)
	     :result-obtained (get-mkb-method-current-result mkb-method)
	     :subgoals (get-mkb-method-subgoals mkb-method)
	     :mkb-method mkb-method
	     :children nil))
	   (possible-users (remove method-name ;; avoid loop in the tree
		    (get-mkb-method-possible-users mkb-method)))
	   (users (remove method-name          ;; avoid loop in the tree
			  (get-mkb-method-users mkb-method))))
      (cond ((and (null users) (null possible-users))
	     (add-child-to-goal-relation-node goal-relation-node *mkb-method-relation-tree-root*))
	    (t
	     (dolist (user users)
	       (let ((user-node (find-goal-relation-node user
					 (get-goal-relation-node-children
					  *mkb-method-relation-tree-root*))))
		 (add-child-to-goal-relation-node goal-relation-node user-node)))
	     (if (not (null possible-users))
		 (let ((possible-node
			(make-goal-relation-node
			 :source method-name
			 :id method-name
			 :goal (get-mkb-method-goal mkb-method)
			 :capability (get-plan-capability plan)
			 :body (if (null (get-mkb-method-system-p mkb-method)) (get-plan-method plan))
			 :result (get-plan-result plan)
			 :result-obtained (get-mkb-method-current-result mkb-method)
			 :subgoals (get-mkb-method-subgoals mkb-method)
			 :possible-users (get-mkb-method-possible-users mkb-method)
			 :mkb-method mkb-method
			 :children nil)))
		   (dolist (p-user possible-users)
		     (let ((p-user-node (find-goal-relation-node p-user
					 (get-goal-relation-node-children
					  *mkb-method-relation-tree-root*))))
		       (add-child-to-goal-relation-node possible-node p-user-node))))))))
		     )
  *mkb-method-relation-tree-root* 
  )
    
;; reorder methods in *mkb-method-list* so that callers come before callees
(defun reorder-defined-goals (goals)
  (add-defined-goals-to-reordered-list goals nil))

(defun add-defined-goals-to-reordered-list (new-goals current-result)
  (let ((result current-result))
    (dolist (goal new-goals)
      (if *mkb-very-verbose*
	(if *problem-solver-verbose* (format *terminal-io* "~% compute for ~S" (first goal)))  )
      (when (or (null (get-mkb-method-system-p (second goal)))
	      (not (null (get-mkb-method-users (second goal))))
	      (not (null (get-mkb-method-possible-users (second goal)))))
        (let ((users (remove (first goal) ;; avoid loop in the tree
			     (union (get-mkb-method-possible-users (second goal))
				    (get-mkb-method-users (second goal))))))
	(if (not (member (first goal) (mapcar #'car result)))
	    (cond ((null users)
		 ;;(if *problem-solver-verbose* (format *terminal-io* "~% add top level ~S" (first goal)))
		 (push goal result))
		((subsetp users (mapcar #'car result))
		 ;;(if *problem-solver-verbose* (format *terminal-io* "~% add after users ~S" (first goal)))
		 (setq result (append result (list goal))))
		(t
		 ;;(if *problem-solver-verbose* (format *terminal-io* "~% insert users and add ~S" (first goal)))
		 ;(format *terminal-io* "~% insert users ~S and add ~S" users (first goal))
		 (let ((updated-goals
		        (add-defined-goals-to-reordered-list
		         (mapcar #'(lambda (g-name)
				 (assoc g-name
				        *mkb-method-list*))
			       users)
		         result)))
		   ;; when at least one user is actually added 
		   ;; in the updated result, add the current goal
		   (when (not (equal result updated-goals))
		     (setq result (append updated-goals (list goal)))))
		 ))))
		     

        ;;(if *problem-solver-verbose* (format *terminal-io* "~% result:~S" result))
        ))
    result))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; for undefined goals
(defun create-stub-method (undefined-goal)
  (let ((goal (first undefined-goal)))
    (list '(name method-name)
	  (create-goal-desc-from-simplified-goal goal)
	  '(result-type ( ))
	  '(method ( )))
    ))
	  
(defun create-goal-desc-from-simplified-goal (goal)
  (let ((goal-name (car goal))
	(params (cdr goal))
	(result nil))
    (dolist (param params)
      (setq result
	    (append result
		    (list
		     (list
		      (first param)
		      (cond ((listp (second param))
			     (list (gentemp "?v")
				   'is (second param)))
			    ((kb-instance-p (second param))
			     (list 'inst (second param)))
			    (t ;; concept without "spec-of"
			     (list (gentemp "?v")
				   'is (list 'spec-of (second param)))))
			     
		      )))
      ))
    (list 'capability (append (list goal-name) result)))
  
)



;;;;;;;;;;
;;; temporary
;(defvar *my-domain-plans* nil)

;;;;;;;;;;;;;;;;;;;;;;;;
;;; utilities for goal-relation-nodes built from ps-tree

(defun add-goal-relation-node-child (node child)
  (if (not (member child (get-goal-relation-node-children node)))
      (setf (goal-relation-node-children node)
	    (append (goal-relation-node-children node) (list child)))))

(defun member-in-node-set (node nodes)
  (cond ((null nodes)
         nil)
        ((equal (get-goal-relation-node-id node)
	      (get-goal-relation-node-id (first nodes)))
         't)
        (t (member-in-node-set node (rest nodes)))))
	      
(defun child-of-node (node parent)
  (member-in-node-set node (get-goal-relation-node-children parent)))

;;;;;;;;;;;;;;;;;

(defun undefined-p (result)
  (or (null result)
      (eq result 'undefined)))
