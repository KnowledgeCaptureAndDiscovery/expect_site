(in-package "EXPECT")

(defun need-to-highlight-result (gr-node)
  (need-to-highlight-result-1
   (get-goal-relation-node-result-obtained gr-node)
   (get-goal-relation-node-result gr-node)
   ))

(defun need-to-highlight-result-1 (current-result expected-result)
  (if (eq 'undefined current-result)
      t
    (let ((edt (mkb-find-common-edt current-result expected-result)))
      (if (equal-edts-p edt expected-result) ;; current-result is subsumed by
	                                     ;; expected-result
	  nil
	t))))


(defun get-nl-description-of-capability (plan-name-in-string)
  (let ((*package* (find-package "EXPECT")))
    (get-nl-description-of-capability-1 (read-from-string plan-name-in-string))))

(defun get-nl-description-of-capability-1 (plan-name)
  (let ((plan (ka-find-plan plan-name *mkb-method-kb*)))
      (if (null plan)
	""
        (generate-nl-description-of-goal (get-plan-capability plan)))))

(defun get-goal-relation-node-desc (gr-node)
  (let ((name (get-goal-relation-node-source gr-node)))
    (cond ((null name)
	   (if (get-goal-relation-node-system-proposed gr-node)
	       (generate-nl-description-of-goal
		(get-goal-relation-node-goal gr-node))
	     nil))
	  ;((or (eq name 'set)
	  ;     (eq name 'covering-or-input))
	  ; name)
	  (t (generate-nl-description-of-goal
	      (get-goal-relation-node-goal gr-node))))))

(defun translate-possible-user-desc (user-desc)
  (if (listp user-desc)
      (if (not (null (second user-desc)))
	(format nil "~A  ~% for subgoal: ~A"
	        (generate-nl-description-of-goal
		  (get-goal-relation-node-goal (second user-desc)))
	        (first user-desc))
        "")
    (get-nl-description-of-capability-1 user-desc)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; for system proposed nodes in goal relation tree
(defun get-system-proposed-name (gr-node)
  (if (get-goal-relation-node-system-proposed gr-node)
      (get-goal-relation-node-source gr-node)
    nil))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; get method description in NL
(defun find-plan-in-kb (plan-name)
  (let ((plan (ka-find-plan plan-name *mkb-method-kb*)))
    (if (null plan)
	(ka-find-plan plan-name)
      plan)))
	      
(defun get-nl-description-of-method (plan-name-in-string)
  (let ((*package* (find-package "EXPECT")))
    (get-nl-description-of-method-1 (read-from-string plan-name-in-string))))

(defun get-nl-description-of-method-1 (plan-name)
  (let ((plan (find-plan plan-name *mkb-method-kb*)))
      (if (null plan)
	""
        (generate-nl-description-of-plan plan))))

#|
(defun get-goal-relation-node-body-desc (gr-node)
  (let ((plan-name (get-goal-relation-node-source gr-node)))
    (if (null plan-name)
	""
      (let ((plan (find-plan-in-kb plan-name)))
	 (if (null plan)
	     (let ((goal (get-goal-relation-node-goal gr-node)))
	       (if (null goal)
		   ""
		 (generate-nl-description-of-goal goal)))
	   (get-nl-from-linked-desc (grate-linked-nl-desc-plan-method plan))))))
  )
|#

;; encode eol with # for client side
(defun get-goal-relation-node-body-desc-in-xml (gr-node)
  (let ((desc (get-goal-relation-node-body-desc gr-node)))
    (if (stringp desc)
	(replace-char #\Newline #\# desc)
	desc))
  )
#|
(defun get-goal-relation-node-body-desc-in-xml (gr-node)
  (let ((desc (get-goal-relation-node-body-desc gr-node)))
    (if (stringp desc)
	(replace-char #\, #\Space
		      (replace-char #\Newline #\# desc))
	desc))
  )
|#

(defun get-goal-relation-node-body-desc (gr-node)
  (let ((plan-name (get-goal-relation-node-source gr-node))
	(node (find-node-in-tree (get-goal-relation-node-id gr-node))))
    (if (null plan-name)
	""
      (let ((plan (find-plan-in-kb plan-name)))
	 (cond ((null plan)
		(if (or (eq plan-name 'set)
			(eq plan-name 'covering-or-input))
		    plan-name ;; rfml node
		 "") ;; undefined method
		)
	       ((and (anode-p node)
		     (eq (get-anode-type node) 'METHOD)
		     (get-anode-info node))
		(let ((bindings (get-method-info-struc-bindings
				 (get-anode-info node))))
		  (set-nl-vars-assoc-list plan)
		  (generate-nl-desc-of-expr
		   (substitute-bindings bindings (get-plan-method plan)))))
	       (t
		 (set-nl-vars-assoc-list plan)
		 (get-nl-from-linked-desc
		  (grate-linked-nl-desc-plan-method plan)))))))
  )

(defun get-nl-from-linked-desc (elt-list)
  (get-nl-from-linked-desc-1 "" elt-list))

(defun get-nl-from-linked-desc-1 (result elt-list)
  (setq result (format nil "~A ~A" result (first elt-list)))
  (dolist (child (fourth elt-list))
    (setq result (get-nl-from-linked-desc-1 result child)))
  result)
	

(defun get-nl-description-of-method-result (plan-name-in-string)
  (let ((*package* (find-package "EXPECT")))
     (if (invalid-lisp-object plan-name-in-string)
	 ""
       (get-nl-description-of-method-result-1 
	(read-from-string plan-name-in-string))))
  )

(defun get-nl-description-of-method-result-1 (plan-name)
  (let ((plan (ka-find-plan plan-name)))
    (if (not (null plan))
	(get-nl-desc-of-data-type-1 (get-plan-result plan)))))

    
(defun get-nl-description-of-data-type (data-type-in-string)
  (let ((*package* (find-package "EXPECT")))
    (if (invalid-lisp-object data-type-in-string)
	""
      (get-nl-desc-of-data-type-1 (read-from-string data-type-in-string))))
  )

;; get generic description
(defun get-nl-desc-of-data-type-1 (data-type) 
  (grate-nl-desc-type data-type 't)
  )

;; get nl for node expr
(defun generate-nl-desc-of-node (node-name)
  (generate-nl-desc-of-expr (get-node-expr node-name)))

;; get nl for general expression
(defun generate-nl-desc-of-expr (expr)
  (get-nl-from-linked-desc (grate-linked-nl-desc-expr expr))
  )

(defun grate-linked-nl-desc-expr (expanded-method)
 
    (setf *on-body* T)
    ;; I don't know why these special cases exist and aren't handled by
    ;; the general body routine. But since they trap a variable and
    ;; treat it differently, I'm adding an extra case for now.
    (cond 
	
     (nil
      (list "primitive" nil -1 nil))
     ((and (listp expanded-method) (listp (car expanded-method)))
      ;; this is for plans that lose the value of a step.  these
      ;; plans are not grammatical.  This is for KA.
      (list " " expanded-method -1
	    (list
	     (grate-linked-nl-desc-expanded-method-plus-heading
	      (pre-process-body-for-nl (car expanded-method)))
	     (list ",
 and then" nil -1 nil)
	     (grate-linked-nl-desc-expanded-method-plus-heading
	      (pre-process-body-for-nl (cadr expanded-method))))))
     (t
      (grate-linked-nl-desc-expanded-method-plus-heading 
       (pre-process-body-for-nl expanded-method)))))

(defun generate-nl-desc-of-method-sub-expr (method-name expr)
  (let ((plan (ka-find-plan method-name)))
    (progn 
      (set-nl-vars-assoc-list plan)
      (get-nl-from-linked-desc
       (grate-linked-nl-method-sub-expr plan expr))
      ))
  )
(defun grate-linked-nl-method-sub-expr (plan expr)
  (let* ((ps (coerce-to-plan-struc plan))
         (expanded-method expr))
     (setf *on-body* T)
    ;; I don't know why these special cases exist and aren't handled by
    ;; the general body routine. But since they trap a variable and
    ;; treat it differently, I'm adding an extra case for now.
    (cond 
	
     ((primitive-plan-p ps)
	 (list "primitive" nil -1 nil))
     ((and (listp expanded-method) (listp (car expanded-method)))
      ;; this is for plans that lose the value of a step.  these
      ;; plans are not grammatical.  This is for KA.
      (list " " expanded-method -1
	    (list
	     (grate-linked-nl-desc-expanded-method-plus-heading
	      (pre-process-body-for-nl (car expanded-method)))
	     (list ",
 and then" nil -1 nil)
	     (grate-linked-nl-desc-expanded-method-plus-heading
	      (pre-process-body-for-nl (cadr expanded-method))))))
     (t
      (grate-linked-nl-desc-expanded-method
       (pre-process-body-for-nl expanded-method)))))
  )

