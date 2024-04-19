;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Jihie Kim, 1999

;; This should be re-examined
;; generate xml output for errors in agenda
;;   -- OTHER errors: errors unrelated with method relations
;;   -- Method-Relation errors: 
 
(in-package "EXPECT")

(defvar *agenda-removed* nil)


(defun mark-removed-agenda (error)
  (push error *agenda-removed*)
  nil)

(defun get-other-errors()
  (setq *agenda-removed* nil)
  (remove-if
   #'null
   (mapcar #'(lambda (error)
	       (let ((error-code (get-error-code-in-error-condition error)))
		 (cond ((or (eq error-code 'unused-plan)
			    (eq error-code 'no-plan-found))
			(mark-removed-agenda error))
		       ((eq error-code 'missing-role-value) ;; filter this message
			nil)
		       (t error))))
	   *agenda*
	  ))
  )

(defun get-other-error-messages (&key context)
  (let* ((*package* (find-package "EXPECT"))
	(agenda (get-other-errors)))
    (get-error-messages agenda))
  )

(defun get-method-relation-errors (&key context)
   (let ((*package* (find-package "EXPECT")))
     (get-error-messages  *agenda-removed*))
  )


(defun mkb-get-text-description-in-error (error)
   (let ((error-code (get-error-code-in-error-condition error)))
     (if (or (eq error-code 'unused-var)
	     (eq error-code 'missing-role-value))
	 (format nil "Warning: ~A"  (get-text-description-in-error-condition error))
       (format nil "Error: ~A"  (get-text-description-in-error-condition error))
       )))


;;;;;;;
;; organize agenda based on the sources (methods,instance)
;; if an agenda is related with multiple methods, they appear in
;; multiple places
;; Output: a list of method-name, tex-description of method
;;          and its list of (agenda-text-description agenda)

;; TTD: add item-number in the result
(defun organize-agenda (agenda)
  (let ((methods nil)  ;; methods related to the problem
	(instances nil) ;; instances related to the problem
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
	   (push (list (list method-name) a-item nil) agenda-info))
	 )
	((new-expect-action goal-exist cannot-parse-capability)
	 (let ((method-name (second (get-parameters-in-error-condition a-item))))
	   (pushnew method-name methods)
	   (push (list (list method-name) a-item nil) agenda-info))
	 )
	((missing-role-value over-general-type)
	 (let ((list-of-methods-and-node
		(third (get-parameters-in-error-condition a-item)))
	       (sources nil)
	       (nodes nil))
	   (dolist (methods-and-node list-of-methods-and-node)
	     (dolist (method (first methods-and-node))
	       (when (ka-find-plan method) 
		 (pushnew method methods)  ;; for all the methods
		 (pushnew method sources)))
	     (dolist (node (find-method-nodes-that-originated-node
			    (find-node-in-tree (second methods-and-node))))
	       (pushnew node nodes))
	     ) ;; for the methods related to this agenda
	   (push (list sources a-item nodes) agenda-info)
	   )
	 )
	(no-plan-found
	 (let ((mnames (find-name-of-methods-that-originated-node
			(second (get-parameters-in-error-condition a-item)))))
	   (setq methods (union methods mnames))
	   (push (list mnames a-item nil) agenda-info)))
	;; these will probably from instance editor??
	((;undefined-concept-in-instance
	  undefined-role-in-instance invalid-role-in-instance)
	 (let ((iname (first (get-parameters-in-error-condition a-item))))
	   (pushnew iname instances)
	   (push (list (list iname) a-item nil) agenda-info))
	 )
	((invalid-args invalid-result invalid-expr)
	 (let* ((node (get-node-in-error-condition a-item))
		(mnames (find-method-names-from-node node))
		(sources nil))
	   (dolist (source mnames)
	     (pushnew source methods)
	     (pushnew source sources))
	   (push (list sources a-item nil) agenda-info))
	 )
	(otherwise nil)
	))
    
    ;; phase 2: organize agenda based on method-name that originated the problem
    ;;      the result is organized agenda
    ;;         a list of ('method method-name method-description
    ;;                            a list of (agenda-id agenda-description))
    (dolist (method-name methods)
      (let ((agenda-on-method nil))
	(dolist (item agenda-info)
	  (if (and (ka-find-plan method-name)
		   (member method-name (first item) :test #'equal))
	      (push (list (get-item-name-of-error-condition (second item))
			  (generate-nl-desc-of-agenda-for-ia (second item))
			  (find-how-to-fix-problem method-name (second item))
			  (third item))
		    agenda-on-method)))
	(push (list 'method
		     method-name
		     (format nil "problems in how to do this: ~A"
			     (get-plan-capability-nl (ka-find-plan method-name)))
		     agenda-on-method) organized-agenda))
      )
    ;; phase 2': organize rest of agenda based on instances
    (dolist (instance-name instances)
      (let ((agenda-on-instance nil))
	(dolist (item agenda-info)
	  (if (member instance-name (first item))
	      (push (list (get-item-name-of-error-condition (second item))
			  (generate-nl-desc-of-agenda-for-ia (second item))
			  (list (list 'edit-instance instance-name))
			  (third item))
		    agenda-on-instance)))
	(push (list 'instance
		    instance-name
		    (format nil "problems with instance ~A" instance-name)
		    agenda-on-instance)
	      organized-agenda))
      )
    
    organized-agenda)
    )

(defun find-proposed-method-name-for-undefined-goal (node-name)
  (let ((result nil))
    (dolist (ug *mkb-ps-undefined-goal-list*) 
      (if (member node-name
		  (get-node-parents
		   (get-undefined-goal-ps-node ug)) :test #'name-equal)
	  (setq result (get-undefined-goal-id ug)))
      )
    result
  ))

(defun find-how-to-fix-problem (method-name agenda-item)
  (let ((code (get-error-code-in-error-condition agenda-item)))
    (cond ((or (eq code 'missing-role-value)
	       (eq code 'over-general-type))
	   (list (list 'edit-instance
		       (first (get-parameters-in-error-condition agenda-item)))
		 (list 'edit-method method-name)
		 ))
	  ((eq code 'no-plan-found)
	   (let ((proposed-name
		  (find-proposed-method-name-for-undefined-goal
		   (second (get-parameters-in-error-condition agenda-item)))))
	     (if proposed-name
		 (list (list 'create-method proposed-name)
		       (list 'edit-method method-name))
	       (list (list 'edit-method method-name))))
	   )
	  (t 
	   (list (list 'edit-method method-name))))
    )
  )

(defun find-method-names-from-node (n)
   (if (and (anode-p n)
		(equal (get-anode-type n) 'METHOD)
		(get-anode-info n)
		(get-method-info-struc-method (get-anode-info n)))
       (list
	  (get-ps-plan-name
	   (get-method-info-struc-method (get-anode-info n))))
     (find-name-of-methods-that-originated-node n)))

;; NL description of the agenda, excluding the methods description
;;   (methods description will be in the parent)
(defun generate-nl-desc-of-agenda-for-ia (item)
  ;; encode eol with # for client side
  (replace-char #\Newline #\#
		(generate-nl-desc-of-agenda-for-ia-1 item))
  )

(defun generate-nl-desc-of-agenda-for-ia-1 (item)
  (let ((code (get-error-code-in-error-condition item))
	(params (get-parameters-in-error-condition item)))
    (case code
      ((no-parse-found no-mt-parse-found)
       (format nil "I cannot understand ~A"
	       (generate-nl-desc-of-expr (second params))))
      (more-than-one-parse
       (format nil "~A has several interpretations (ambiguous)"
	       (generate-nl-desc-of-expr (second params))))
      (result-lost
       (format nil "the result of ~A is never used"
	       (generate-nl-desc-of-expr (second params))))
      (unused-plan (format nil "The method is never used"))
      (unused-var
       (format nil "~A is not used"
	       (generate-nl-desc-of-method-sub-expr (first params)
						    (second params))))
      (duplicated-var ;; wont happend with structured-editor and nl-editor
       (format nil "~A is declared twice"
	       (generate-nl-desc-of-method-sub-expr (first params)
						    (second params))))
      (undeclared-var "") ;; wont happend with structured-editor and nl-editor
      (undefined-word (format nil "I cannot understand ~A" (second params)))
      ((undefined-concept-in-instance undefined-role-in-instance
				      invalid-role-in-instance)
       (get-text-description-in-error-condition item)
       )
      (no-plan-found
       (format nil
	       "I do not know how to do this: ~A ~%  I need to know for this:~A"
	       (generate-nl-desc-of-expr (first params))
	       (generate-nl-desc-of-node (find-node-in-tree (second params))))

       )
      (missing-role-value
       (format nil
	       "I need to know ~A ~A because it is needed to do: ~%  ~{~A~}"
	       (grate-nl-desc-relation-name (second params))
	       (grate-nl-desc-instance-name (first params))
	       (mapcar #'(lambda (p)
			   (generate-nl-desc-of-node (find-node-in-tree (second p))))
		       (third params))) ;; node

       )
      (over-general-type 
       (format nil
	       "I need to know if ~A is a ~A because it is needed to do: ~%  ~{~A~}"
	       (grate-nl-desc-instance-name (first params))
	       (grate-nl-desc-concept-name (second params))
	       (mapcar #'(lambda (p)
			   (generate-nl-desc-of-node (find-node-in-tree (second p))))
		       (third params))) ;; node

       )
      ((invalid-args invalid-result invalid-expr)
       (format nil "description '~A'~% has invalid result"
	       (generate-nl-desc-of-expr (first params))))
      (otherwise (get-text-description-in-error-condition item))
      )
    ))