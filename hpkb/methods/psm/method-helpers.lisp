(in-package "EVALUATION")

;;; Since this is defined to be the CYC package which shadows the
;;; symbol "list", this seems to be the easiest solution for writing
;;; code here:

#-mcl (setf (symbol-function 'list) (symbol-function 'common-lisp:list))

(defparameter *plan-annotations* nil
  "List of information stored about expect methods.")

;;; This is a convenience function that used to be in critiques.plans
(defmacro defplan (name &key capability result-type method primitivep
		    post-processing annotations)
  `(progn (push '((name ,name) 
	        (capability ,capability) 
	        (result-type ,result-type)
	        (method ,method)
	        (primitivep ,primitivep)
	        (post-processing ,post-processing)
	        )
	      *domain-plans*)
	(push (cons ',name ',annotations) *plan-annotations*)))

(defun get-annotation (plan-name annotation)
  (assoc annotation (cdr (assoc plan-name *plan-annotations*))))

;;; I couldn't find one for doing time points, which seems unwieldy
;;; otherwise.
(defmacro make-time-point (name day 
			 &optional
			 (month 'may)
			 (year 1998)
			 (hour 0)
			 (minute 0)
			 (second 0))
  `(tellm (about ,name time-point
	       (time-point.day ,day) (time-point.month-name ,month)
	       (time-point.year ,year)
	       (time-point.hour ,hour)
	       (time-point.minute ,minute)
	       (time-point.second ,second))))

;;; I redefine adding numbers to fail if its arguments are not numbers.
;;; This makes the backtracking work when we don't have complete
;;; information.
(defun primitive-add-numbers (&rest args)
  (let* ((args (if (and (= (length args) 1)
		    (listp (first args)))
	         (first args)
	       args))
         (clean-args (remove-if-not #'numberp args)))
    (cond ((equal args clean-args)
	 (let ((real-args (if (listp (car args)) (car args) args)))
	   (apply #'+ real-args)))
	(t
	 (signal-new-ps-error '(invalid-args not-number primitive-method-execution)
			  'primitive-add-numbers
			  (list args)
			  "RECOVERY: This is a deliberately failing add")
	 (error)))))

;;; Same for primitive-is-greater-or-equal-than
(defun primitive-is-greater-or-equal-than (n1 n2)
  (cond ((and (numberp n1) (numberp n2))
         (if (>= n1 n2)
	   'TRUE
	   'FALSE))
        (t
         (signal-new-ps-error '(invalid-args not-number primitive-method-execution)
                              'primitive-is-greater-or-equal-than
                              (list n1 n2)
                              "RECOVERY: deliberately fails")
         'UNKNOWN)))


 
(defun primitive-equality-of-objects (a b)
  (if (equal a b) 'true 'false))

(defun primitive-no-amount-needed (objective resource)
  (if (kb-get-values 'amount-needed objective resource)
      'false
    'true))

(defun primitive-set-member (element set)
  (if (member element set)
      'true
    'false))

(defun primitive-count-the-elements (set)
  (length set))

(defun primitive-find-the-instances (c)
  (cond ((kb-concept-p c)
         (mapcar #'kb-find-object-name (loom:get-instances c)))
        ((and (listp c) (equal (car c) 'spec-of))
         ;; This is refined by the result-refiner code.
         '(set-of (inst-of top-domain-concept)))
        (t nil)))

(defun result-refiner-set-of (c)
  `(set-of (inst-of ,(if (symbolp c) c (get-name c)))))

;;; Used to store results
;;; No longer used since I'm using the critique ontology
(defvar *evaluation-results* (list :head))

(defun clean-store ()
  (setf *evaluation-results* (list :head)))

(defun store-result (value relation &rest arguments)
  ;; (store-path path value)
  ;; currently the compiler returns the result of post-processing. Oops.
  (if (= (length arguments) 1)
      (kb-add-value (first arguments) relation value)
    ;; currently hard to store a result for a n-ary relation with n > 2
    (eval `(tellm (,relation ,@arguments ,value))))
  value)

(defun store-path (path value &optional (point-so-far *evaluation-results*))
  (unless (assoc (car path) (cdr point-so-far))
    (push (list (car path)) (cdr point-so-far)))
  (if (null (cdr path))
      (push value (cdr (assoc (car path) (cdr point-so-far))))
    (store-path (cdr path) value (assoc (car path) (cdr point-so-far)))))

(defun store-if (test value relation &rest arguments)
  (if test
      (store-result instance relation arguments)))

;;; Given a plan to evaluate, create evaluation structures for each
;;; evaluation-aspect and remove any other evaluation structures.
;;; This should read the structures and analyses required from somewhere
;;; in Loom but that's for later.
;;; This function must return the plan, because it is called as a
;;; primitive method in methods.lisp.

(defparameter *evaluations*
  '((feasibility-evaluation-structure
     inadequate-forces-for-task-critique
     inadequate-forces-critique
     )
    (correctness-evaluation-structure
     all-arrayed-forces-owned-critique
     all-forces-arrayed-critique)
    (completeness-evaluation-structure
     main-effort-identified-critique
     reserve-identified-critique
     security-identified-critique
     rear-identified-critique
     fire-task-identified-critique
     )))


(defun set-up-evaluation-aspects (plan)
  ;; first, clear out the old evaluation aspects
  (dolist (estruc (get-values plan 'evaluation-aspect))
    (remove-value plan 'evaluation-aspect estruc))
  ;; next add new ones based on the global *evaluations*
  (dolist (aspect-and-factors *evaluations*)
    (let ((new-evaluation-structure 
	 (kb-define-instance (intern (symbol-name (gensym (symbol-name (first aspect-and-factors)))))
			 (first aspect-and-factors))))
      (kb-add-value plan 'evaluation-aspect new-evaluation-structure)
      (dolist (factor (cdr aspect-and-factors))
        (let ((new-critique 
	     (kb-define-instance
	      (intern (symbol-name (gensym (symbol-name factor))))
	      factor)))
	(format t "Adding ~S to ~S~%" new-critique new-evaluation-structure)
	(kb-add-value new-evaluation-structure 'factor new-critique)))))
  plan)
  

;;; Would be great to just use "copy-instance", but it tells me
;;; the original thing isn't a "classified instance".
(defun replicate-critique (?critique)
  (let* ((crit-type (first (most-specific-concepts (get-types ?critique))))
         (new-crit  (createm nil crit-type)))
    ;; install the new critique as a factor of the same evaluation structure.
    (add-value (first (get-matching-instances '(evaluation-structure)
				      `((factor ,?critique))))
	     'factor new-crit)
    new-crit))


(defun add-to-evaluation (result critique plan-or-task &optional mode)
  (format t "~%Adding value ~S to critique ~S mode ~S on plan ~S~%"
	result critique mode plan-or-task)
  (add-value critique 'violated result)
  (add-value critique 'violation-info expect::*current-open*))

(defun add-to-task-evaluation (result critique task mode)
  (add-value (find-analysis-for-object critique task) 'violated result))

;;; really grandchild, but I don't want to re-load the methods just for
;;; a different helper name.
(defun add-grandchild-result-as-analysis-estimate (critique)
  (let* ((child (first (expect::enode-children expect::*current-open*)))
         (grandchild (if child (first (expect::enode-children child))))
         (child-result (if grandchild (expect::get-enode-result grandchild))))
    (if child-result
        (add-value critique 'analysis-estimate child-result))))
    
  
;;; This is the first storage function called on a task, so we create
;;; the new critique here.
(defun store-usage-estimate-for-task-set (value set-of-tasks resource-check)
  (dolist (task set-of-tasks)
    ;; create a critique for each task, since this is the first time
    ;; information is stored for this resource check.
    (let ((crit (replicate-critique resource-check)))
      (add-value crit 'analysis-object task)
      (add-value crit 'normal-value value)
      (add-value crit 'normal-value-info expect::*current-open*)
      )))

(defun store-availability-estimate-for-task (value object resource-check)
  ;; find the critique that points to this task.
  (let ((crit (find-analysis-for-object resource-check object)))
    (cond (crit
	 (add-value crit 'analysis-estimate value)
	 (add-value crit 'estimate-info expect::*current-open*))
	(t
	 (format t "~%Warning: no critique found like ~S performed on ~S~%"
	         resource-check object)))))

(defun find-analysis-for-object (analysis ?object)
  (let ((poss-analyses
         (get-matching-instances (most-specific-concepts (get-types analysis))
			   `((analysis-object ,?object))))
        (coa (get-value ?object 'coa-of-ce)))
    ;; If there is no coa-of-ce, this is not a critical event so it's
    ;; the main task. That is hooked up to the wrong COA, so instead get
    ;; the operation and find the COA that points to it.
    (unless coa
      (setf coa
	  (first (eval `(retrieve ?coa 
			      (for-some (?op) 
				      (and (|taskOfOperation| ?op ,?object)
					 (the-coa-operation ?coa ?op))))))))
    (format t "COA is ~S~%" coa)
    (some #'(lambda (an)
	    (active-analysis-of-coa coa an))
	poss-analyses)))

;;; An analysis is an active analysis of a COA if the analysis is a
;;; factor of some evaluation structure in the COA
(defun active-analysis-of-coa (coa analysis)
  (some #'(lambda (e-structure)
	  (active-analysis-of-evaluation-structure
	   e-structure analysis))
        (get-values coa 'evaluation-aspect)))

(defun active-analysis-of-evaluation-structure (e-structure analysis)
  (or (first (member analysis (get-values e-structure 'factor)))
      (some #'(lambda (sub-structure)
	      (active-analysis-of-evaluation-structure
	       sub-structure e-structure))
	  (get-values e-structure 'sub-evaluation-structure))))


