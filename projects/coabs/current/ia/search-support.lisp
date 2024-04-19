(in-package "EXPECT")

;; ********************************************
;; support "search" in EMeD
;; ********************************************


(defun check-if-match (searchFn list)
  (if (null list) nil
    (let ((item (first list)))
	(cond ((numberp item)
	       (check-if-match searchFn (rest list)))
	      ((and (stringp (symbol-name item))
		    (funcall searchFn (symbol-name item)))
	       t)
	      (t (check-if-match searchFn (rest list)))))))

(defun order-lists (new-list current-list)
  (append (intersection-2 new-list current-list)
	  (reverse (set-difference current-list new-list))
	  (reverse (set-difference new-list current-list))))

(defun search-methods (keywords)
  (let ((result nil))
    (dolist (word keywords)
      (setq result (order-lists (search-methods-1 word) result)))
    result))

(defun search-methods-1 (searchString)
  (let ((searchFn (let ((regex:*regex-case-sensitive-p* nil))
                     (compile nil (regex:regex-compile searchString))))
        (result nil))
    ;;(if *problem-solver-verbose* (format *terminal-io* "~% searchFn:~S" searchFn))
    (dolist (mkb-method  (mapcar #'second *mkb-method-list*))
      (let ((name (get-mkb-method-name mkb-method))
	    (items-in-goal (flatten (get-mkb-method-goal mkb-method)))
	    (items-in-result (flatten (get-mkb-method-expected-result mkb-method)))
	    (items-in-body (if (listp (get-mkb-method-body mkb-method))
			       (flatten (get-mkb-method-body mkb-method))
			     (list (get-mkb-method-body mkb-method)))))
	(if (or (check-if-match searchFn items-in-goal)
		;(check-if-match searchFn items-in-result)
		(check-if-match searchFn items-in-body))
	    (push name result))))
    result))
	  

;;******************************************************************
;; search based on super-concepts
;;******************************************************************
;; find subsumer/subsumee by level 2
;;
(defun kb-get-superconcepts-for-concepts (concepts)
  (let ((result nil))
    (dolist (c concepts)
      (setq result
	  (append result (kb-get-superconcepts c))))
    (remove-duplicates result))
  )

(defun kb-get-subconcepts-for-concepts (concepts)
  (let ((result nil))
    (dolist (c concepts)
      (setq result
	  (append result (kb-get-subconcepts c))))
    (remove-duplicates result))
  )

(defun kb-subsumers-by-level (x level)
  (if (or (not (numberp level))
	(< level 0))
      nil
    (let* ((result (if (kb-instance-p x)
		   (list (kb-most-specific-subsumer x))
		 (list x)))
	 (current result))
      (loop for i from 1 to level
        do
        (setq current (kb-get-superconcepts-for-concepts current))
        (setq result (append result current)))
      (setq result (remove-duplicates result))
      (if (kb-instance-p x)
	(append (list x) result)
        result)
      ))
  )
(defun kb-subsumees-by-level (x level)
  (if (or (not (numberp level))
	(< level 0))
      nil
    (let* ((result (if (kb-instance-p x)
		   (list (kb-most-specific-subsumer x))
		 (list x)))
	 (current result))
      (loop for i from 1 to level
        do
        (setq current (kb-get-subconcepts-for-concepts current))
        (setq result (append result current)))
      (setq result (remove-duplicates result))
      (if (kb-instance-p x)
	(append (list x) result)
        result)
      ))
  )

(defun kb-subsumes-p-by-level (level x y)
  (let ((subsumers (kb-subsumers-by-level y level)))
    (member x subsumers)
  ))
(defun kb-subsumed-p-by-level (level x y)
  (let ((subsumees (kb-subsumees-by-level y level)))
    (member x subsumees)
  ))
;;;;;;;;;;;;;;;;;;

(defun check-match-with-candidates (candidates list)
  (if (null list)
      nil
    (let ((item (first list)))
      (cond ((numberp item)
	     (check-match-with-candidates candidates (rest list)))
	    ((member item candidates)
	     t)
	    (t (check-match-with-candidates candidates (rest list)))))))

(defun find-methods-with-function (keys searchFunction)
  (let ((result nil))
     (dolist (mkb-method  (mapcar #'second *mkb-method-list*))
      (let ((name (get-mkb-method-name mkb-method))
	    (items-in-goal (flatten (get-mkb-method-goal mkb-method)))
	    (items-in-result (flatten (get-mkb-method-expected-result mkb-method)))
	    (items-in-body (if (listp (get-mkb-method-body mkb-method))
			       (flatten (get-mkb-method-body mkb-method))
			     (list (get-mkb-method-body mkb-method)))))
	(if (or (check-match-with-candidates keys items-in-goal)
		;(check-match-with-candidates keys items-in-result)
		(check-match-with-candidates keys items-in-body))
	    (pushnew name result))))
    result))

;;******************************************************************
;; FOR MATCH MAKER   ***********************************************
;;******************************************************************

;;******************************************************************
;; find methods with reformulated concepts/relations
;;******************************************************************
(defun get-rfmls-in-search (c)
  (kb-get-partitions&members (get-name-from-input c)))

;; check capability only
(defun get-methods-containing-words (word-list)
  (let ((result nil))
    (dolist (mkb-method  (mapcar #'second *mkb-method-list*))
      (let ((name (get-mkb-method-name mkb-method))
	    (items-in-goal (flatten (get-mkb-method-goal mkb-method))))
	(if (intersection word-list items-in-goal)
	    (push name result))))
    result)	    
  )

;;******************************************************************
;; find methods matching goal description
;;******************************************************************

(defun search-methods-matching-goal (goal-desc)
  (let ((ps-methods+bindings (mt-match-goal-new goal-desc)))
    (mapcar #'(lambda (ps-method+bindings)
		(get-ps-method-name (first ps-method+bindings)))
	    ps-methods+bindings)))
#|
(defun search-methods-matching-goal (goal-desc)
  (let ((ps-methods+bindings 
	 (union (shared-mt-match-goal-general goal-desc)
		(shared-mt-match-goal-exact goal-desc) :test #'equal)))
    (mapcar #'(lambda (ps-method+bindings)
		(get-ps-method-name (first ps-method+bindings)))
	    ps-methods+bindings)))
|#
(defun search-methods-matching-goals (goals-in-list-list)
   (mapcan #'search-methods-matching-goal (first goals-in-list-list)))

(defun search-methods-subsumed-by-goal (goal-desc)
  (let ((ps-methods+bindings
	 (shared-mt-match-goal-specific goal-desc)))
    (mapcar #'(lambda (ps-method+bindings)
		(get-ps-method-name (first ps-method+bindings)))
	    ps-methods+bindings)))
