;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Jihie Kim, 1999

;;******************************************************************
;;******************************************************************
;; generate xml output for EMeD
;;   called by the Client
;;
;;   generate-xml-init-ia ;; initialize interdependency analyzer
;;   get-method-capability-tree
;;   get-method-relation-tree
;;   get-undefined-goal-list
;;   get-method-name-list
;;   get-system-defined-method-name-list
;;   get-user-defined-method-name-list
;;   get-searched-method-name-list
;;   get-methods-with-subsumers
;;   xml-get-rfmls-in-search
;;   xml-get-methods-matching-goal
;;   get-all-messages     ;; send agenda 
;;   get-organized-error-messages ;; organize agenda based on the methods
;;                                ;; which cause the problem
;;   get-ps-method-rel-tree-all
;;   get-ps-method-relation-subtree
;;******************************************************************
;;******************************************************************

(in-package "EXPECT")

;; simple acknowledgement
(defun produce-xml-ack-report (ack-type ack-message)
  (format nil "<?xml version=\"1.0\" standalone='yes'?>~%<!DOCTYPE ack>~%<ack type='~A'>~A</ack>" 
          ack-type
          ack-message)
  )


(defun generate-xml-init-ia (&key kb)
  (if (expect::initialize-ia :kb kb)
      (format nil  "~A"
	      (produce-xml-ack-report "initIA" ""))
    (produce-xml-error-report "IANotInitialized" ""))
  )

;;******************************************************************
;; check and fix input from the client
;;******************************************************************
;; get a symbol from input
(defun get-name-from-input (input)
  (typecase input
    (symbol input)
    (string (intern (string-upcase input)
		    (find-package "EXPECT")))
    (t (error "~A is not a symbol or string" input)
    )))


;; needs to be changed
(defun cannot-parse (capability name)
  (let ((action (and (listp capability) (first capability))))
    (when (and action (not (kb-concept-p action)))
      (def-expect-action action :is 'Expect-Action) 
      (kb-check-network)
      (signal-message 'new-expect-action name action)
      (mark-temporary-concept action)) ;;; the definition will be undone later, if needed
    (let ((parse-tree (parse-action capability)))
      (cond ((null parse-tree)
	     't)
	    ((member nil
		     (flatten (translate-action parse-tree)))
	     't)
	    (t
	     nil)))))

(defun invalid-lisp-object (input-in-string)
  (stringp (handler-case (read-from-string input-in-string)
			 (error (c)
				(format nil "ERROR: ~a" c)))))

;;*****************************************************************
;; check capability hierarchy
;******************************************************************
(defun get-method-capability-tree ()
  (produce-xml-capability-tree *mkb-capability-tree-root*  "goalNode"
		    #'get-goal-node-children
		    #'get-goal-node-definer
		    #'get-goal-node-defined-p
		    #'get-goal-node-goal
		    #'get-goal-node-desc)
  )

(defun produce-xml-capability-tree  (item node-name get-subs print-item-name print-item-defined-p
					  print-item-content print-item-desc &optional (level 0))
  (format nil "~%~VT<NODE>~A~{~A~}~%~VT</NODE>" 
          (* 3 level)
          (produce-xml-generic-element node-name 
                                       (list
					(list "name" (funcall print-item-name item))
					(list "package" (find-package-name
							 (funcall print-item-name item)))
					(list "defined-p" (funcall print-item-defined-p item))
					(list "desc" (funcall print-item-desc item))
					)
                                       (funcall print-item-content item))
          (loop for sub in (funcall get-subs item)
                collect (produce-xml-capability-tree sub node-name get-subs print-item-name
				print-item-defined-p print-item-content print-item-desc
				(+ 1 level)))
          (* 3 level)))
;******************************************************************
;; method sub-method relation tree
;;*****************************************************************

(defun get-method-relation-tree ()
  (produce-xml-method-tree-1   *mkb-method-relation-tree-root*)
  )

(defun produce-xml-method-tree-1 (root)
  (if (null root)
      (format nil "<?xml version=\"1.0\"?>~%no tree")
   (produce-xml-method-tree root
			    "goalInfoNode"
			    #'get-goal-relation-node-children
			    #'get-goal-relation-node-source
			    #'get-goal-relation-node-id
			    #'get-goal-relation-node-desc
			    #'get-goal-relation-node-goal
			    #'get-goal-relation-node-capability
			    #'get-goal-relation-node-result
			    #'get-goal-relation-node-result-obtained
			    #'get-goal-relation-node-body
			    #'get-goal-relation-node-body-desc-in-xml
			    #'get-goal-relation-node-possible-users
			    #'get-goal-relation-node-subgoals
			    #'get-system-proposed-name
			    #'need-to-highlight-result
			    )
  ))

(defun node-uses-new-method-p-1 (tree-node)
  (if (node-uses-new-method-p tree-node)
      't
    nil))


(defun produce-xml-method-tree (item node-name get-subs print-item-name
			       print-item-id
			       print-item-desc
			       print-goal print-capability
			       print-result print-edt print-body print-body-desc
			       print-possible-users
			       print-subgoals
			       print-system-proposed-name
			       print-highlight-result
			       &optional (level 0))
  (let ((expect-tree-node (find-node-in-tree (get-goal-relation-node-id item))))
  (format nil "~%~VT<gr-node>~A~{~A~}~%~VT</gr-node>" 
          (* 3 level)
          (produce-xml-generic-element node-name 
                      (list (list "method-name" (funcall print-item-name item))
     			   (list "package-name" (find-package-name
					    (funcall print-item-name item)))
			   (list "node-id" (funcall print-item-id item))
			   )
		      (produce-xml-generic-element "system-proposed-name" nil
						   (funcall print-system-proposed-name item))
		      (produce-xml-generic-element "edt" nil (funcall print-edt item))
		      (produce-xml-generic-element "result-expected" nil (funcall print-result item))
		      (produce-xml-generic-element "body" nil (funcall print-body item))
		      (produce-xml-generic-element "body-desc" nil (funcall print-body-desc item))
		      (produce-xml-generic-element "desc" nil (funcall print-item-desc item))
		      (produce-xml-generic-element "simplified-capability" nil (funcall print-goal item))
		      (produce-xml-generic-element "capability" nil (funcall print-capability item))
		      (produce-xml-generic-element "highlight-result" nil (funcall print-highlight-result item))
		      ;; FOR PSM Tool PSTree UI:  uses a method that has just been defined
		      (produce-xml-generic-element "using-new-method" nil
						   (node-uses-new-method-p-1
						    expect-tree-node))
		      ;;whether the node's children should be shown in the UI
		      (produce-xml-generic-element "expand" nil
						   (expand-node-in-ui-p
						    expect-tree-node))
		      
		      (produce-xml-possible-users (funcall print-possible-users item))
		      (produce-xml-subgoal-list (funcall print-subgoals item))
		      )
          (loop for sub in (funcall get-subs item)
                collect (produce-xml-method-tree sub node-name get-subs
				         print-item-name
					 print-item-id
					 print-item-desc
				         print-goal print-capability
				         print-result print-edt
				         print-body print-body-desc
					 print-possible-users
				         print-subgoals print-system-proposed-name
					 print-highlight-result
					 (+ 1 level)))
          (* 3 level)))
  )

(defun produce-xml-subgoal-list (subgoal-list)
  (format nil "~%~{~A~%~}"
	  (loop for item in subgoal-list
		collect (produce-xml-generic-element "subgoal" nil item))))

(defun produce-xml-possible-users (possible-users)
  (format nil "~%~{~A~%~}"
	  (loop for item in possible-users
		collect (produce-xml-generic-element "possible-user" nil
			   (translate-possible-user-desc item)))))

;;******************************************************************
;; undefined goal list
;;******************************************************************

(defun add-undefined-rfmls-of-undefined-goals (goals result)
  (if (null goals)
      result
      (cond
	((null (get-undefined-goal-unmatched-rfmls (first goals)))
	 (append (list (first goals))
		 (add-undefined-rfmls-of-undefined-goals (rest goals) result))
	 )
	(t ;; there are rfmls
	 (let ((new-ugoals nil)
	       (expected-result-of-original-goal
		(get-undefined-goal-expected-result (first goals))))
	   (dolist (rfml (get-undefined-goal-unmatched-rfmls (first goals)))
	     (setq new-ugoals
		   (append new-ugoals
			   (list
			    (make-undefined-goal
			     :goal (first rfml) ;; reformulated goal
			     :expected-result (if (eq 'covering (second rfml))
						  expected-result-of-original-goal
						(remove-set-of expected-result-of-original-goal))
			     :id (gentemp "_method")
			     :callers (second rfml) ;; rfml type
			     :capability-sketch
			     (create-goal-desc-from-simplified-goal (first rfml))
			     )))))
	   (append (list (first goals))
		   new-ugoals
		   (add-undefined-rfmls-of-undefined-goals (rest goals) result))))))
  )

				       
(defun get-undefined-goal-list ()
  (produce-xml-undefined-goal-list "undefined-goals" #'get-undefined-goal-goal
			     #'get-undefined-goal-callers #'get-undefined-goal-rfml-types
			     #'get-undefined-goal-expected-result
			     #'get-undefined-goal-capability-sketch
			     #'get-undefined-goal-id 
			     "goal"
			     (add-undefined-rfmls-of-undefined-goals *mkb-undefined-goal-list* nil))
  )

#|
(defun produce-xml-undefined-goal-list (tag-name print-goal print-users print-rfmls
				         print-expected-result print-capability
				         list-item-type list)
  (format nil "~%<~A>~%~{~A~%~}</~A>"
	  tag-name
          (loop for item in list
		collect (produce-xml-generic-element list-item-type
                                       (list (list "callers" (funcall print-users item))
				     (list "rfmls" (funcall print-rfmls item))
				     (list "expected-result" (funcall print-expected-result item))
				     (list "capability-desc" (funcall print-capability item))
				     )
                                       (funcall print-goal item)
				       )
		)
	  tag-name))
|#

(defun produce-xml-undefined-goal-list (tag-name print-goal print-users print-rfmls
				         print-expected-result print-capability
					 print-id
				         list-item-type list)
  (format nil "~%<~A>~%~{~A~%~}</~A>"
	  tag-name
          (loop for item in list
		collect (produce-xml-generic-element list-item-type
                                       (list (list "callers" (funcall print-users item))
				     ;(list "rfmls" (funcall print-rfmls item))
				     (list "expected-result" (funcall print-expected-result item))
				     (list "capability-desc" (funcall print-capability item))
				     (list "id" (funcall print-id item))
				     )
                                       (funcall print-goal item)
;				       (produce-xml-rfmls-list (funcall print-rfmls item)) ;;[**]
				       )
		)

	tag-name))

(defun produce-xml-rfmls-list (rfmls-list)
  (format nil "~%~{~A~%~}"
	  (loop for item in rfmls-list
		collect (produce-xml-generic-element "rfmls-for-method" nil
					       (format nil "~A -- ~A"
						     (second item) (first item))
					       ))))


;;******************************************************************
;; get method name list
;;******************************************************************

(defun get-system-defined-method-name-list ()
  (produce-xml-typed-list-element "mkb-method-names" nil "name" *system-defined-methods--name*)
  )

(defun get-user-defined-method-name-list ()
  (produce-xml-typed-list-element "mkb-method-names" nil "name" *user-defined-methods--name*)
  )

(defun get-method-name-list ()
  (produce-xml-typed-list-element "mkb-method-names" nil "name" (mapcar #'first *mkb-method-list*))
  )
;******************************************************************
(defun get-mkb-method-list ()
  ;(produce-xml-typed-list-element "mkb-methods" nil "method" (mapcar #'second *mkb-method-list*))
  (produce-xml-method-list "method-list"
			   #'get-mkb-method-name
			   #'get-mkb-method-capability
			   #'get-mkb-method-body
			   #'get-mkb-method-expected-result
			   #'get-mkb-method-system-p
			   "method"
			   (mapcar #'second *mkb-method-list*))
  )

(defun produce-xml-method-list (tag-name print-name print-goal
					 print-body print-expected-result
					 print-system-p
					 list-item-type list)
  (format nil "~%<~A>~%~{~A~%~}</~A>"
	  tag-name
          (loop for item in list
		collect (produce-xml-generic-element list-item-type
                                       (list (list "name" (funcall print-name item))
					     (list "body" (funcall print-body item))
					     (list "expected-result" (funcall print-expected-result item))
					     (list "system-p" (funcall print-system-p item))

					     )
                                       (funcall print-goal item)
				       )
		)
	  tag-name))


;******************************************************************
;; search method which has this in the capability, result-type, or body
;******************************************************************

(defun filter-words (words)
   (set-difference words
		   '("OBJ" "SPEC-OF" "INST-OF" "SET-OF" "OF" "FOR" "TO" "FROM")
		   :test #'equal))

(defun get-searched-method-name-list (searchString &key (potential-match nil))
  (let ((keywords (filter-words (find-words searchString)))
	(result-tag (if potential-match
			"search-results-potential"
		      "search-results")))
    (produce-xml-generic-element
     result-tag nil
     (produce-xml-typed-list-element "keywords" nil "keyword"
				     keywords)
     (produce-xml-typed-list-element "mkb-method-names" nil "name"
				     (search-methods keywords)))))

#|
(defun get-searched-method-name-list (searchString)
  (let ((keywords (filter-words (find-words searchString))))
    (produce-xml-typed-list-element "mkb-method-names"
				    (list (list "keywords" keywords))
				    "name"
				    (search-methods keywords)))
  )

(defun get-searched-method-name-list--potential (searchString)
  (let ((keywords (filter-words (find-words searchString))))
    (produce-xml-typed-list-element "mkb-method-names"
				    (list (list "keywords-potential" keywords))
				    "name-potential"
				    (search-methods keywords))
    ))
|#


(defun get-methods-with-subsumers (searchString &key (context (cc)))
  (let ((*package* (find-package "EXPECT")))
    (if (invalid-lisp-object searchString)
	(get-searched-method-name-list searchString :potential-match t)
      (let ((subsumers (kb-subsumers-by-level
			(get-name-from-input searchString) 2))) ;; check upto level 2
	(produce-xml-generic-element
	 "search-results" nil
	 (produce-xml-typed-list-element "keywords" nil "keyword"
					 subsumers)
	 (produce-xml-typed-list-element
	  "mkb-method-names" nil "name"
	  (find-methods-with-function subsumers #'check-if-match))
    )))))

(defun get-methods-with-subsumees (searchString &key (context (cc)))
  (let ((*package* (find-package "EXPECT")))
    (if (invalid-lisp-object searchString)
	(get-searched-method-name-list searchString :potential-match t)
      (let ((subsumees (kb-subsumees-by-level
			(get-name-from-input searchString) 2))) ;; check upto level 2
	(produce-xml-generic-element
	 "search-results" nil
	 (produce-xml-typed-list-element "keywords" nil "keyword"
					 subsumees)
	 (produce-xml-typed-list-element
	  "mkb-method-names" nil "name"
	  (find-methods-with-function subsumees #'check-if-match))
    )))))

#|
(defun xml-get-rfmls-in-search (searchString &key (context (cc)))
  (let ((*package* (find-package "EXPECT")))
    (produce-xml-typed-list-element "rfmls" nil "rfml"
				    (get-rfmls-in-search searchString))
    ))
|#

(defun xml-get-rfmls-in-search (searchString &key (context (cc)))
  (let ((*package* (find-package "EXPECT")))
    (produce-xml-rfmled-method-list "rfmls"
				    (get-rfmls-in-search searchString)
				    #'append
				    #'get-methods-containing-words
				    "name")
    ))

(defun produce-xml-rfmled-method-list (tag-name rfml-list get-result-fn get-method-fn item-tag)
  (produce-xml-generic-element
   "search-results" nil
   (format nil "~%<~A>~%~{~A~%~}</~A>"
	  tag-name
          (loop for item in rfml-list
		collect (produce-xml-generic-element "rfml" nil
                            (produce-xml-typed-list-element
			     "rfml-results" nil "rfml-result-item"
			     (funcall get-result-fn (rest item)))
			    (produce-xml-typed-list-element
			     "mkb-method-names" nil item-tag
			     (funcall get-method-fn (rest item)))
				       ))
	tag-name)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; search with goal description

;; get methods matching the goal
(defun xml-get-methods-matching-goal (goalDescInString &key (context (cc)))
  (let ((*package* (find-package "EXPECT")))
    (if (invalid-lisp-object goalDescInString)
	(get-searched-method-name-list goalDescInString :potential-match t)
      (let ((method-names (search-methods-matching-goal
			   (read-from-string goalDescInString))))
	(if (null method-names)
	    (get-searched-method-name-list goalDescInString :potential-match t)
	   (produce-xml-generic-element
	    "search-results" nil
	    (produce-xml-typed-list-element "mkb-method-names" nil "name"
					    method-names)))))))

(defun xml-get-method-matching-rfmlt-goal (goalDescInString &key (context (cc)))
  (let ((*package* (find-package "EXPECT")))
    (if (invalid-lisp-object goalDescInString)
	(get-searched-method-name-list goalDescInString :potential-match t)
      (let ((rfmled-exprs (append
			   (reexpress-with-reformulations-of-kind
			    (read-from-string goalDescInString) 'covering)
			   (reexpress-with-reformulations-of-kind
			    (read-from-string goalDescInString) 'set))))
	(produce-xml-rfmled-method-list
	 "rfmls"
	 rfmled-exprs
	 #'first
	 #'search-methods-matching-goals
	 "name"))
      )))

(defun xml-get-methods-subsumed-by-goal (goalDescInString &key (context (cc)))
  (let ((*package* (find-package "EXPECT")))
    (if (invalid-lisp-object goalDescInString)
	(get-searched-method-name-list goalDescInString :potential-match t)
      (let ((method-names (search-methods-subsumed-by-goal
			   (read-from-string goalDescInString))))
	(if (null method-names)
	    (get-searched-method-name-list goalDescInString :potential-match t)
	   (produce-xml-generic-element
	    "search-results" nil
	    (produce-xml-typed-list-element "mkb-method-names" nil "name"
					    method-names)))))))
      


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; test

(defun load-plan (plan-in-string &key context)
  (let ((*package* (find-package "EXPECT")))
    
    (let* ((form (read-from-string plan-in-string))
	  (result (process-store-plan (list (create-plan-from-desc form)))))
      result)))

(defun delete-all-plans (&key context)
  (let ((*package* (find-package "EXPECT")))
    (let ((names (mapcar #'first *plan-kb-current*)))
      (dolist (name names)
	(process-remove-plan (list name)))))
  (if *problem-solver-verbose* (format *terminal-io* "~%*plan-kb-current* : ~%~S" *plan-kb-current*))
  )

(defun describe-result (result)
  (cond ((null result)
	 (format nil "*****>  Sorry, cannot solve the problem yet"))
	((eq 'false  result)
	 (format nil "*****> The plan is rejected in that respect"))
	((or (eq 't result) (eq 'true result))
	 (format nil "*****> The plan is accepted in that respect"))
	(t 
	 (format nil "*****> The result is ~S" result))))

(defun  get-top-node-result (&key context)
  (let ((*package* (find-package "EXPECT")))
    (format nil "~%<~A>~A~%~%~A</~A>"
	    "result"
	    (generate-nl-description-of-goal (get-node-expr  *ps-tree*))
	    (describe-result (get-node-result *ps-tree*))
	    "result")))

(defun get-top-exe-result (&key context)
  (let ((*package* (find-package "EXPECT")))
    (format nil "~%<~A>~A~%~%~A</~A>"
	    "result"
	    (generate-nl-description-of-goal *exe-top-level-goal*)
	    (cond (*exe-top-level-goal*
		   (ka-process-exe-tree)
		   (describe-result (get-node-result *exe-tree*)))
		  (t
		   "~%Please select a problem.~%"))
	    "result")))

(defun get-simplified-goal (method)
  (let* ((*package* (find-package "EXPECT"))
	 (method-name (find-symbol (typecase method
                                     (symbol (symbol-name method))
				     (string (string-upcase method)) 
                                     (t (error "~A is not a symbol or string" method)))
                                   *package*))
	 (plan (ka-find-plan method-name)))
    (if *problem-solver-verbose* (format *terminal-io* "::method-name ~S" method-name))
    (if (not (null plan))
	(format nil "~%~A~%"
		(simplify-goal (get-plan-capability plan))
		)
      "")))

;;;;;;;;;;;;;;;;;;;;;;

(defun get-nl-of-capability (cap-in-string)
  (let ((*package* (find-package "EXPECT")))
    (if (invalid-lisp-object cap-in-string)
	""
      (let ((cap-in-list (read-from-string cap-in-string)))
	(generate-nl-description-of-goal cap-in-list)))))

;;******************************************************************
;; for structured editor
;;******************************************************************
(defun produce-xml-generic-element-downcase (tag-name parameter-list &rest contents)
  (format nil "<~A~A> ~{~A~} </~A>"
          tag-name
          (if parameter-list
            (loop with pls = ""
                  for (par-name par-value) in parameter-list
                  do (setq pls 
			   (concatenate 'string 
					(string-downcase (format nil " ~A=\"~A\"~%" par-name par-value))
					pls))
                  finally (return pls))
            "")
          (if (or (null contents)
                  (equal contents ""))
            ""
            contents)
          tag-name))


(defun produce-xml-edit-method-desc (method-name)
  (let ((method-desc (nl-edit-menu method-name)))
    (let ((name-desc (get-string-code-pairs (second (first method-desc))))
	  (cap-desc (get-string-code-pairs (second (second method-desc))))
	  (result-desc (get-string-code-pairs (second (third method-desc))))
	  (body-desc (get-string-code-pairs (second (fourth method-desc)))))
      (format nil "~%<~A>~%~A~%~A~%~A~%~A~%</~A>"
	      "method-desc"
	      (format nil "~%<~A>~%~{~A~%~}</~A>"
		      "name"
		      (loop for item in name-desc
			    collect (produce-xml-generic-element-downcase "item"
					  (list (list "desc" (first item))
						(list "code" (second item))
						(list "idx" (third item)))
					  item))
		      "name")
	      (format nil "~%<~A>~%~{~A~%~}</~A>"
		      "capability"
		      (loop for item in cap-desc
			    collect (produce-xml-generic-element-downcase "item"
					  (list (list "desc" (first item))
						(list "code" (second item))
						(list "idx" (third item)))
					  item))
		      "capability")
	      (format nil "~%<~A>~%~{~A~%~}</~A>"
		      "result"
		      (loop for item in result-desc
			    collect (produce-xml-generic-element-downcase "item"
					  (list (list "desc" (first item))
						(list "code" (second item))
						(list "idx" (third item)))
					  item))
		      "result")
	      (format nil "~%<~A>~%~{~A~%~}</~A>"
		      "body"
		      (loop for item in body-desc
			    collect (produce-xml-generic-element-downcase "item"
					  (list (list "desc" (first item))
						(list "code" (second item))
						(list "idx" (third item)))
					  item))
		      "body")
	      
	      "method-desc"))))

;;******************************************************************
;; generate method-relation tree, undefined goal-list, partial match
;;   from ps-tree
;;******************************************************************
(defun get-ps-method-relation-tree ()
  ;(ps-build-method-relation-tree)
  (produce-xml-method-tree-1  *mkb-ps-collected-mr-tree-root*)
  )

;; 
(defun get-ps-method-rel-tree-all ()
  ;(ps-build-method-relation-tree-all)
  (produce-xml-method-tree-1  *mkb-ps-method-relation-tree-root*)
  )


(defun get-undefined-goal-list-from-ps ()
  (produce-xml-undefined-goal-list "undefined-goals" #'get-undefined-goal-goal
			     #'get-undefined-goal-callers #'get-undefined-goal-rfml-types
			     #'get-undefined-goal-expected-result
			     #'get-undefined-goal-capability-sketch
			     #'get-undefined-goal-id 
			     "goal" *mkb-ps-undefined-goal-list*)
  )

(defun get-partial-match-for-incomplete-goals ()
  (produce-xml-method-tree-1  *mkb-ps-potential-match-for-incomplete-goals*)
  )

;;TTD link to the client
(defun get-collected-potential-match ()
  (produce-xml-method-tree-1  *mkb-ps-collected-potential-match*)
  )

(defun get-ps-method-relation-subtree (name-in-string)
  (if (null *mkb-ps-method-relation-tree-root*)
      (ps-build-method-relation-tree-all))
  (let ((gr-node
	 (find-ps-node-in-method-relation-tree name-in-string
					       *mkb-ps-method-relation-tree-root*)))
    (if (null gr-node) ""
      (produce-xml-method-tree-1 gr-node))))


;;******************************************************************
;; wrap error and warning messages from ia
;;******************************************************************

(defun send-messages (errors ka-processed-p plan-name)
  (format nil "<~A~A>~%~{~A~%~}</~A>"
	  ;(produce-xml-headers "methodEdit" "methodEditResult.dtd")
	  "response"
	  (concatenate 'string
		       (format nil " ~A=\"~A\"" "processed" ka-processed-p)
		       (format nil " ~A=\"~S\"" "plan-name" plan-name))

	  (loop for error in errors
		collect (format nil "<~A>~A</~A>"
				"error"
				(get-text-description-in-message error)
				"error"))
		       
	  "response"))

;;******************************************************************
;; send error messages from expect agenda
;;******************************************************************

(defun get-organized-error-messages  (&key context)
  (let* ((*package* (find-package "EXPECT"))
	 (organized-agenda (organize-agenda *agenda*)))
    (if *top-level-goal*
      (format nil "~%<all-error-list>~%~{~A~%~}</all-error-list>"
	      (loop for ag in organized-agenda
		    collect
		    (produce-xml-generic-element
		     "related-errors"
		     (list
		      (list "type" (first ag))
		      (list "name" (second ag))
		     ; (list "package" (find-package-name (second ag)))
		      (list "text" (third ag)))
		     
		     (generate-xml-agenda-list (fourth ag))))))
    ))
		
(defun generate-xml-agenda-list (agenda-info-list)
  (format nil "~%<agenda-list>~%~{~A~%~}</agenda-list>"
	  (loop for ag in agenda-info-list
		collect
		(produce-xml-generic-element "agenda"
		     (list
		      (list "agenda-id" (first ag))
		      (list "text" (second ag))
		      )
		     (generate-xml-related-method-nodes (fourth ag))
		     (generate-xml-how-to-fix-problem (third ag))))
	  
  ))

(defun describe-solution (solution)
  (let ((type (first solution))
	(name (second solution)))
    (case type
      (edit-method
       (format nil "change how to '~A' ?" (get-nl-description-of-capability-1 name)))
      (edit-instance
       (format nil "provide information about '~A' ?" name))
      (create-method
       (let ((the-ug (find-undefined-goal-with-proposed-method-name name)))
	 (if the-ug
	     (format nil "specify how to '~A' ?"
		     (generate-nl-desc-of-expr (get-undefined-goal-goal the-ug)))
	   ""))
       )
      )))

(defun generate-xml-how-to-fix-problem (solution-list)
   (format nil "~%<solution-list>~%~{~A~%~}</solution-list>"
	  (loop for solution in solution-list
		collect
		(produce-xml-generic-element "solution"
		     (list
		      (list "solution-type" (first solution))
		      (list "package" (find-package-name (second solution)))
		      (list "name" (second solution))
		      )
		     (describe-solution  solution)
	   ))
  ))

(defun generate-xml-related-method-nodes (nodes)
  (format nil "~%<node-list>~%~{~A~%~}</node-list>"
	  (loop for node in nodes
		collect
		(produce-xml-generic-element "ps-node"
		     (list
		      )
		     (get-node-name node)
	   ))
  ))



(defun get-all-messages  (&key context)
  (let ((*package* (find-package "EXPECT")))
    (get-error-messages *agenda*))
)
(defun get-error-messages (error-list)
 
	  (if *top-level-goal*
	      (format nil "~%<~A>~%~{~A~%~}</~A>"
			"error-list"
			(loop for ag in error-list
			      collect (format nil "<~A>~A</~A>"
				       "error"
				       (mkb-get-text-description-in-error ag)
				       "error"))
		 "error-list")
    " "))
  
(defun xml-dismiss-agenda-item (item-name-in-string)
  (cond ((invalid-lisp-object item-name-in-string)
	 (signal-message 'invalid-expr nil item-name-in-string)
	 (add-messages *mkb-messages*)
	 (send-messages *mkb-messages* nil nil))
	(t
	 (let ((agenda-item (find-agenda-item-with-item-name
			     (read-from-string item-name-in-string))))
	   (if (null agenda-item)
	       "failed to find agenda item"
	     (progn (dismiss-agenda-item agenda-item)
		    "ok"))))))