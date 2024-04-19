;;;
;;; Add some routines to the application-specific menu to display
;;; the evaluation of a plan.
;;; Jim 4/19/98

(in-package "EXPECT")

(defvar *application-menu-items*
  '(("Display evaluation" (display-plan-evaluation))
    ("Load plan to inspect" (do-load-plan)
     "Ask for a plan name, load it and set the problem to evaluate it")
    ("Clear stored data" (clean-store)
     "Remove data stored during plan evaluation")
    )
  "This is a list of menu items for the application menu. The first element
of each list member is a string, which is the name that appears in the
menu. The second element is a form, which is evaluated when the item
is selected. If a third element is present and is a string, it is used as
the menu documentation, otherwise the name is repeated as the documentation")

(defvar *plan-menu-list* nil
  "This is a list of menu items for loading plans to inspect in a
particular domain. See the documentation for *application-menu-items*
for the syntax of the list")

;;; This function is called when you mouse on "application" in the
;;; standard UI menu panel.

(defun application-menu ()
  (clim-menu-list *application-menu-items* "Evaluation menu"))


;;; Display a plan evaluation, currently just by printing the value
;;; of *evaluation-results* in a window.

(defun display-plan-evaluation ()
  ;; I hate the default colours!
  (let* ((*new-window-background* clim::+white+)
         (*new-window-foreground* clim::+black+)
         (window-stream (make-window *ka* *ka-root* 'graph
			      "Result of plan evaluation")))
    (setf (clim:window-visibility window-stream) t)
    (clim:window-clear window-stream)
    (clim:with-text-style (window-stream (clim:make-text-style
				  :sans-serif :roman :large))
		      (print-plan-evaluation window-stream t)
		      (place-window-control-buttons window-stream))))


;;; Assume the current *exe-top-level-goal* shows the plan or object to
;;; be printed.
(defun print-plan-evaluation (&optional (stream *terminal-io*) in-clim)
  (let ((plan (second (assoc 'obj (cdr *exe-top-level-goal*))))
        (*print-case* :downcase))
    (format stream "Evaluation for plan ~S~%====================~%~%" plan)
    (let ((violated-constraints
	 (mapcan #'(lambda (c)
		   (if (eq (second (assoc 'constraint-violated (cdr c)))
			 'true)
		       (list (car c))))
	         (cdr (assoc plan (cdr *evaluation-results*)))))
	(ok-constraints
	 (mapcan #'(lambda (c)
		   (if (eq (second (assoc 'constraint-violated (cdr c)))
			 'false)
		       (list (car c))))
	         (cdr (assoc plan (cdr *evaluation-results*)))))
	(violated-resources
	 (mapcan #'(lambda (c)
		   (if (eq (second (assoc 'violated (cdr c)))
			 'true)
		       (list (car c))))
	         (cdr (assoc plan (cdr *evaluation-results*)))))
	(ok-resources
	 (mapcan #'(lambda (c)
		   (if (eq (second (assoc 'violated (cdr c)))
			 'false)
		       (list (car c))))
	         (cdr (assoc plan (cdr *evaluation-results*))))))
      (when violated-constraints
        (format stream "  Violated constraints: ")
        (print-bold-if-in-clim stream in-clim
			 (format nil "~S~%" violated-constraints)))
      (when ok-constraints
        (format stream "  Constraints that are ok: ~S~%" ok-constraints))
      (when violated-resources
        (format stream "  Violated resources: ")
        (print-bold-if-in-clim stream in-clim
			 (format nil "~S~%" violated-resources)))
      (when ok-resources
        (format stream "  Resources that are ok: ~S~%"
	      (mapcar #'(lambda (r)
		        (if (eq (second (assoc 'available
					 (cdr (assoc r (cdr (assoc plan (cdr *evaluation-results*)))))))
			      'true)
			  (list r 'existence)
			r))
		    ok-resources)))
      (format stream "~%")
      
      (when violated-constraints
        (dolist (vc violated-constraints)
	(let ((bad (mapcan
		  #'(lambda (obj)
		      (if (eq (second (assoc 'constraint-ok
				         (cdr (assoc vc
						 (cdr (assoc obj
							   (cdr *evaluation-results*)))))))
			    'false)
			(list obj)))
		  (kb-get-values 'plan-objectives-to-be-inspected plan))))
	  (format stream "Objectives violating constraint ")
	  (print-bold-if-in-clim stream in-clim (format nil "~S~%" vc))
	  (print-objectives-list stream bad in-clim))))
      
      (when violated-resources
        (dolist (vr violated-resources)
	(let ((bad (mapcan
		  #'(lambda (obj)
		      (let ((obj-spec
			   (cdr
			    (assoc
			     vr (cdr (assoc
				    obj
				    (cdr *evaluation-results*)))))))
		        (if (or (eq (second (assoc 'ok obj-spec))
				'false)
			      (eq (second (assoc 'needed obj-spec))
				'true))
			(list obj))))
		  (kb-get-values 'plan-objectives-to-be-inspected plan))))
	  (format stream "Objectives violating resource ")
	  (print-bold-if-in-clim stream in-clim (format nil "~S" vr))
	  (print-objectives-list stream bad in-clim))))
      
      (format stream "~%Summary of resource useage by objective:~%")
      (dolist (obj (kb-get-values 'plan-objectives-to-be-inspected plan))
        (if in-clim
	  (clim:with-output-as-presentation (stream obj 'clim-instance-name)
				      (format stream "  ~S~%" obj))
	(format stream "  ~S~%" obj))
        (dolist (slot (cdr (assoc obj (cdr *evaluation-results*))))
	(if (and (second (assoc 'available (cdr slot)))
	         (second (assoc 'set-useage (cdr slot))))
	    (format stream "    ~S: ~S shared useage of ~S available~%"
		  (first slot)
		  (second (assoc 'set-useage (cdr slot)))
		  (second (assoc 'available (cdr slot)))))
	(if (eq (second (assoc 'needed (cdr slot))) 'true)
	    (format stream "    ~S needed~%" (first slot)))))
      )))

(defun print-bold-if-in-clim (stream in-clim string)
  (if in-clim
      (clim:with-text-face (stream :bold) (princ string stream))
    (princ string stream)))

(defun print-objectives-list (stream obj-list in-clim)
  (cond (in-clim
         (dolist (obj obj-list)
	 (clim:with-output-as-presentation (stream obj 'clim-instance-name)
				     (format stream "~S " obj)))
         (format stream "~%"))
        (t (format stream "~S~%" obj-list))))

;;; Determine which plan is required from a menu list, and load it.  The
;;; menu list should be set in the customisation files for a specific
;;; domain. This will do more when I have decided how to load plans in
;;; general.
(defun do-load-plan ()
  (clim-menu-list *plan-menu-list* "Plan to load"))
