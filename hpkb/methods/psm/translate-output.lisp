;;;
;;; This file contains routines to translate the output from problem-solving
;;; into the format required by SAIC. Although it's in the psm directory it 
;;; contains code that's specific to the COA domain.
;;; Jim Blythe, May 99
;;;

(in-package "EVALUATION")

(defparameter *expl-file-break-patterns*
  '(
    (any
     (check-not-arrayed (obj ?unit) (in ?coa) (for ?critique))
     any
     ("Check if ~S is arrayed" '?unit))

    (any
     (find-not-owned (obj ?unit) (by ?upper-unit) (for ?critique))
     any
     ("Check if ~S is available to ~S" '?unit '?upper-unit))

    (evaluate-task-force
     (is-greater-or-equal
      (obj (estimate (obj amount-used)
		 (of ?inadequate-forces-for-task-critique)
		 (needed-by-set (find (plan-tasks-sharing ?inadequate-forces-for-task-critique)
				  (with ?task)))))
      (than (estimate (obj ?inadequate-forces-for-task-critique)
		  (available-to ?task))))
     evaluate-task-set
     ("Force ratio for critical event ~S" '?task)
     )

    (evaluate-task-set
     (estimate (obj (spec-of combat-power)) 
	     (of ?unit)
	     (with-respect-to ?task))
     estimate-unit-cp
     ("Combat power of ~S during ~S" '?unit '?task)
     )

    (evaluate-task-set
     (estimate (obj amount-used)
	     (of ?inadequate-forces-critique)
	     (needed-by-set 
	      (find (plan-tasks-sharing ?inadequate-forces-critique)
		  (with ?task))))
     required-force-ratio
     ("Force ratio required for ~S" '?task)
     )

    (estimate-unit-cp
     (estimate (obj (spec-of combat-power))
	     (of ?unit)
	     (for-type ?type)
	     (with (|echelonOfUnit| ?unit))
	     (during-task ?t))
     estimate-unit-cp
     ("Combat power of ~S" '?unit)
     )

    (estimate-unit-cp
     (estimate (obj (spec-of remaining-strength))
	     (of ?unit)
	     (for ?task))
     estimate-remnants
     ("Estimate strength of ~S at the time of ~S" 
      '?unit '?task))
    )
  "A list of 4-element lists, each of which contains a symbolic name for
the phase of the trace, a goal pattern for the break-point, a symbolic
name for the new phase of the trace and a print statement to describe
the new phase. In each phase, when we encounter a goal node matching any
break pattern that is given for this phase, we start a new file, add an
href in the current file and change phase. See write-expl-r for
details.")
	 
(defvar *nodes-in-separate-files* nil
  "List of nodes for which we have already generated separate files. If
we are generating seperates, then always just refer to that file when we
encounter this node.")

(defvar *top-level-in-html* nil
  "If nil, the top level of the critique is generated as plain
text. This is the format that COA Cat needs. Otherwise, the top level is
generated in html like the lower levels, so the whole critique can be
read with an html client.")


;;; filename can be a string, defaults to standard output.
(defun write-output (&optional coa (filename t) (full-trace t)
			 (natural-language nil)
			 (generate-separate-files nil))
  (if (and (not coa)
	 (boundp '*exe-top-level-goal*)
	 (listp *exe-top-level-goal*)
	 (eq (first *exe-top-level-goal*) 'evaluate)
	 (assoc 'obj (cdr *exe-top-level-goal*))
	 (listp (assoc 'obj (cdr *exe-top-level-goal*))))
      (setf coa (second (assoc 'obj (cdr *exe-top-level-goal*)))))
  (setf *nodes-in-separate-files* nil)
  (if (eq filename t)
      (dolist (evaluation-structure (get-values coa 'evaluation-aspect))
        (write-evaluation-structure coa evaluation-structure filename 
			      full-trace natural-language
			      generate-separate-files))
    (with-open-file (out filename :direction :output
		     :if-does-not-exist :create)
		(dolist (evaluation-structure 
		         (get-values coa 'evaluation-aspect))
		  (write-evaluation-structure coa evaluation-structure 
					out full-trace 
					natural-language
					generate-separate-files)))))


(defun write-evaluation-structure (coa evaluation-structure out full-trace
			         natural-language 
			         generate-separate-files)
  (dolist (analysis (get-values evaluation-structure 'factor))
    (write-analysis coa evaluation-structure analysis out full-trace 
		natural-language generate-separate-files))
  (dolist (sub-structure 
	 (get-values evaluation-structure 'sub-evaluation-structure))
    (write-evaluation-structure coa sub-structure out full-trace 
			  natural-language
			  generate-separate-files)))


(defun write-analysis (coa evaluation-structure analysis out full-trace
		       natural-language generate-separate-files)
  (let ((?self analysis))
    (declare (special ?self))
    ;; Don't print the prototype inadequate-forces-critique
    (when (and (or (ask (inadequate-forces-for-task-critique ?self))
	         (ask (inadequate-forces-critique ?self)))
	     (null (get-value ?self 'analysis-object)))
      (return-from write-analysis nil))

    (format out ";;</P><P>Critique ~S is a ~S</P><P>~%"
	  (get-name analysis)
	  (get-name (first (most-specific-concepts
			(get-types analysis)))))
    (html-newline out)
    (format out "(newCritique ~S ~A~%"
	  (get-name analysis)
	  (get-name (first (most-specific-concepts
			(get-types evaluation-structure)))))
    (html-newline out)
    (let ((description (get-value analysis 'description)))
      (when description
        (format out "  (description \"~A\")~%" (eval `(format nil ,@description)))
        (html-newline out)))
    (let ((question (get-value analysis 'analysis-question)))
      (when question
        (format out "  (question ~S ~A \"~A\")~%" 
	      (get-value analysis 'analysis-pq)
	      (get-value analysis 'analysis-spec)
	      (eval `(format nil ,@question)))
        (html-newline out)))
    (format out "  (priority ~S)~%"
	  (get-value analysis 'priority))
    (html-newline out)
    (format out "  (violated ~S)~%"
	  (get-name (get-value analysis 'violated)))
    (html-newline out)
    (when (and (ask (resource-check ?self))
	     (not (ask (inadequate-forces-critique ?self))))
      (format out "  (value ~S)~%"
	    (get-value analysis 'analysis-estimate))
      (html-newline out)
      (format out "  (normalValue ~S)~%"
	    (get-value analysis 'normal-value))
      (html-newline out)
      )
    (format out "  (source expect-critiquer)~%")
    (html-newline out)
    (when (and (ask (resource-check ?self))
	     (not (ask (inadequate-forces-critique ?self))))
      (format out "  (reasons \"The critique is ~:[~;not ~]violated because the value is ~S and the required value is ~S\")~%"
	  (equal (get-value analysis 'violated) (fi false))
	  (get-value analysis 'analysis-estimate)
	  (get-value analysis 'normal-value))
      (html-newline out))
    (format out "  (formalReasons ")
    (if (and (ask (resource-check ?self))
	   (not (ask (inadequate-forces-critique ?self))))
        (format out "\"The critique is ~:[~;not ~]violated because the value is ~S and the required value is ~S~%"
	  (equal (get-value analysis 'violated) (fi false))
	  (get-value analysis 'analysis-estimate)
	  (get-value analysis 'normal-value))
      (format out "\"~%"))
    (html-newline out)
    (when full-trace
      (cond ((ask (inadequate-forces-critique ?self))
	   (write-explanation coa evaluation-structure analysis out
			  (get-value analysis 'violation-info)
			  natural-language generate-separate-files
			  'evaluate-task-force))
	  ((ask (resource-check ?self))
	   (html-newline out)
	   (format out 
		 "~%How I arrived at the required value for this task:~%")
	   (html-newline out)
	   (write-explanation coa evaluation-structure analysis out
			  (get-value analysis 'normal-value-info)
			  natural-language generate-separate-files)
	   (html-newline out)
	   (format out 
		 "~%How I arrived at the estimated value for this task:~%")
	   (html-newline out)
	   (when (ask (inadequate-forces-for-task-critique ?self))
	     (combat-power-overview analysis out natural-language)
	     (format out "Detailed description:~%")
	     (html-newline out))
	   (write-explanation coa evaluation-structure analysis out
			  (get-value analysis 'estimate-info) 
			  natural-language generate-separate-files
			  'evaluate-task-set))
	  ((ask (global-completeness-critique ?self))
	   (write-explanation coa evaluation-structure analysis out
			  (find-descendant-with-goal 
			   'find-fillers
			   (get-value analysis 'violation-info))
			  natural-language generate-separate-files))
	  ((ask (all-forces-arrayed-critique ?self))
	   (write-explanation coa evaluation-structure analysis out
			  (find-descendant-with-goal 
			   'find-unarrayed
			   (get-value analysis 'violation-info))
			  natural-language generate-separate-files))
	  (t
	   (write-explanation coa evaluation-structure analysis out
			  (get-value analysis 'violation-info)
			  natural-language generate-separate-files))))
    (format out "\")~%")		; ends formalReasons
    (format out "  )~%;;------------~%~%") ; ends the critique
    (html-newline out) (html-newline out)
    ))


(defun write-explanation (coa evaluation-structure analysis out exe-node natural-language generate-separate-files
			&optional phase)
  (write-explanation-of-trace out)	; a few lines on how to read the trace
  (let ((expect::*clim* nil))		; shouldn't matter any more but..
    (write-expl-r exe-node 0 out natural-language
	        phase
	        *top-level-in-html*
	        ;; but it's easier to read with t.
	        generate-separate-files)))

;;; This function gives a point of entry for the explanation generator
;;; that is independent of the critique ontology

(defun write-explanation-with-root (&optional (node expect::*ps-tree*) 
				     (stream *terminal-io*)
				     natural-language
				     phase 
				     generate-separate-files)
  (let ((expect::*clim* nil))
    (write-expl-r node 0 stream natural-language 
	        phase
	        nil
	        generate-separate-files)))

;;; Based on print-tree-summary-short-success.
(defun write-expl-r (&optional (n expect::*ps-tree*) (level 0)
			 (stream *terminal-io*) natural-language
			 phase in-html
			 generate-separate-files)
  (when (and n (not (equal (expect::get-node-result n) 'dont-care)))
    (let ((skipped (skip-explanation-for-node-p n))
	pattern-bindings)
      (unless skipped
        (when (not (equal (expect::get-node-expr n) 
		      (expect::get-node-expanded-expr n)))
	(coa-print-node-expr-for-tree-summary nil n level stream natural-language in-html)
	)
        (print-node-ee-for-tree-summary 
         nil n level stream nil
         (not (equal (expect::get-node-expr n) 
		 (expect::get-node-expanded-expr n)))
         natural-language in-html)
        ;; also print the result here, even if the current node
        ;; has children.
        (coa-print-node-result-for-tree-summary nil n level stream in-html)
        #|
        (when (or (expect::get-node-children n)
	        (and (expect::get-enode-current n)
		   (expect::get-node-children 
		    (expect::get-enode-current n))))
	(print-indent-for-node level stream)
	(coa-print-node-short n 0 stream)
	(format stream " subproblems:~%")
	)
|#)
      (cond ((and generate-separate-files
	        (expect::enode-p n)
	        (setf pattern-bindings
		    (match-phase-break-pattern (expect::get-node-expr n)
					 phase)))
	   (let* ((old-phase-info (first pattern-bindings))
		(bindings (first (second pattern-bindings)))
		(new-phase (third old-phase-info))
		(new-file  (format nil "~A.html"
			         (symbol-name (gensym "SUB-EXPL"))))
		(new-level 0))
	     ;; If the node was skipped, make sure to print it
	     (when skipped
	       (when (not (equal (expect::get-node-expr n) 
			     (expect::get-node-expanded-expr n)))
	         (coa-print-node-expr-for-tree-summary 
		nil n level stream natural-language in-html))
	       (print-node-ee-for-tree-summary 
	        nil n level stream nil
	        (not (equal (expect::get-node-expr n) 
			(expect::get-node-expanded-expr n)))
	        natural-language in-html)
	       (coa-print-node-result-for-tree-summary 
	        nil n level stream in-html)
	       )
	     (print-indent-for-node level stream in-html)
	     (format stream "<A HREF=\"~A\">more details</A>~%"
		   new-file)
	     (if in-html (format stream "<BR>~%"))
	     (with-open-file (new-stream new-file
				   :direction :output
				   :if-does-not-exist :create)
                 (format new-stream "<HTML>~%<TITLE>~A</TITLE>~%<BODY BGCOLOR=\"#FFFFFF\">~%"
		     (eval `(format nil ,@(sublis
				       bindings
				       (fourth old-phase-info)))))
	       ;; Put a summary at the top of the new file
	       (format new-stream "<H1>~A</H1>~%"
		     (eval `(format nil ,@(sublis
				       bindings
				       (fourth old-phase-info)))))
	       ;; repeat this node in the new file
	       (when (not (equal (expect::get-node-expr n) 
			     (expect::get-node-expanded-expr n)))
	         (coa-print-node-expr-for-tree-summary 
		nil n new-level new-stream natural-language t))
	       (print-node-ee-for-tree-summary 
	        nil n new-level new-stream nil
	        (not (equal (expect::get-node-expr n) 
			(expect::get-node-expanded-expr n)))
	        natural-language t)
	       (coa-print-node-result-for-tree-summary 
	        nil n new-level new-stream t)
	       ;; then write the recursive part in the new streamm
	       (write-expl-children n new-level new-stream natural-language 
			        new-phase t
			        generate-separate-files skipped)
	       (format new-stream "</BODY></HTML>"))))
	  (t
	   (write-expl-children 
	    n level stream natural-language phase in-html
	    generate-separate-files skipped)
	   ))
    )))

(defun write-expl-children (n level stream natural-language 
			phase in-html 
			generate-separate-files
			skipped)
  (mapcar #'(lambda (c)
	    (when (not (expect::node-has-failed-p c))
	      (write-expl-r c (if skipped level (+ 1 level))
			stream natural-language
			phase in-html
			generate-separate-files)))
	(expect::get-node-children n))
  (when (and (expect::enode-p n)
	   (expect::get-enode-current n))
    (if (and (expect::get-enode-current n)
	   (expect::get-node-children (expect::get-enode-current n)))
        (mapcar #'(lambda (c)
		(when (not (expect::node-has-failed-p c))
		  (write-expl-r c (if skipped level (+ 1 level))
			      stream natural-language
			      phase in-html
			      generate-separate-files)))
	      (expect::get-node-children 
	       (expect::get-enode-current n)))
      ;; I used to print the node result here but no longer do.
      ))
  )

(defun match-phase-break-pattern (expr phase)
  "Determine if some pattern for this phase matches the expr"
  (some #'(lambda (break-pattern-template)
	  (if (or (eq (first break-pattern-template) phase)
		(eq (first break-pattern-template) 'any))
	      (let ((match (match-break-pattern expr (second break-pattern-template))))
	        (if match (list break-pattern-template match)))))
        *expl-file-break-patterns*))

(defun match-break-pattern (expr pattern &optional bindings)
  (cond ((and (symbolp expr) (not (varp expr)) (eq expr pattern))
         (list bindings))
        ((and (symbolp expr) (symbolp pattern) (varp pattern)
	    (assoc pattern bindings)
	    (eq expr (cdr (assoc pattern bindings))))
         (list bindings))
        ((and (symbolp expr) (symbolp pattern) (varp pattern)
	    (not (assoc pattern bindings)))
         (list (cons (cons pattern expr) bindings)))
        ((and (listp expr)
	    (listp pattern)
	    (= (length expr) (length pattern))
	    (mapcar #'(lambda (sub-expr sub-pattern)
		      (let ((match (match-break-pattern sub-expr sub-pattern bindings)))
		        (setf bindings (first match ))
		        (unless match
			(return-from match-break-pattern nil))))
		  expr pattern))
         (list bindings))
        (t nil)))

(defun varp (symbol)
  (char= (elt (symbol-name symbol) 0) #\?))

(defun print-node-ee-for-tree-summary (mark n level stream
				    &optional (mark-rfml-p nil)
				    (mark-as-expansion t)
				    natural-language in-html)
  (print-indent-for-node level stream in-html)
  (when mark (format stream " "))
  (coa-print-node-short n 0 stream in-html)
  (when (and mark-rfml-p
	   (expect::enode-p n)
	   (expect::get-enode-current n)
	   (member (expect::get-anode-type 
		  (expect::get-enode-current n))
		 expect::*rfml-kinds*))
    (format stream "*"))
  (if mark-as-expansion
      (format stream " expands to:")
    (format stream ":"))  ; otherwise it's the first time the node is mentioned.
  ;; Print a retrieval node differently.
  (if (and (not natural-language)
	 (expect::get-enode-current n)
	 (equal (expect::get-anode-type (expect::get-enode-current n))
	        'retrieve))
      (format stream " retrieve"))
  (format stream " ~A" 
	(if natural-language
	    (grate-nl-expr (expect::get-node-expanded-expr n))
	  (expect::get-node-expanded-expr n)))
  (if in-html (format stream "<BR>"))
  (format stream "~%"))

(defun coa-print-node-short (n level stream in-html)
  (let ((name (expect::get-node-name n)))
    ;; get rid of the "exe-en" or "exe-an" (will be wrong for a ps node)
    (format stream "Node ~A" (subseq name 6))))


(defun print-indent-for-node (level stream in-html)
  (when (> level 0)
    (format stream 
	  (if in-html "&nbsp;&nbsp;" "  ")))
  (do ((i 0 (1+ i)))
      ((= i level))
    (format stream
	  (if in-html "&nbsp;&nbsp;" " ") ;;"| "
	  )))

(defun coa-print-node-expr-for-tree-summary (mark n level stream natural-language in-html)
  (print-indent-for-node level stream in-html)
  (when mark (format stream "~A" mark))
  (coa-print-node-short n 0 stream in-html)
  (format stream ": ~A"
	(if natural-language
	    (grate-nl-expr (expect::get-node-expr n))
	  (expect::get-node-expr n)))
  (if in-html
      (format stream "<BR>"))
  (format stream "~%"))

(defun coa-print-node-result-for-tree-summary (mark n level stream in-html)
  (print-indent-for-node level stream in-html)
  (when mark (format stream " "))
  (coa-print-node-short n 0 stream in-html)
  (format stream " result: ~A" (expect::get-node-result n))
  (let ((source (enode-plan-annotation n :source)))
    ;; Print the source of the method if this enode was computed
    ;; from a method that had a declared source.
    (if source
        (format stream " [Source used: ~A]" 
	      (if (and in-html (string= (subseq (second source) 0 2) "KF"))
		(compute-ikd-ref (second source))
		(second source))
	      )))
  (if in-html (format stream "<BR>"))
  (format stream "~%"))

(defun compute-ikd-ref (kf-string)
  (let ((kf (read-from-string (subseq kf-string 3))))
    (format nil "<A HREF=\"http://www.alphatech.com/protected/hpkb/ikd/sources/Knowledge_Fragments/KF_~S.html#~S\">~A</A>"
	  (floor (/ kf 100))
	  kf
	  kf-string)))

(defun expect::print-indent-for-node (level stream)
  (when (> level 0)
    (format stream "  "))
  (do ((i 0 (1+ i)))
      ((= i level))
    (format stream " " ;;"| "
	  )))

(defun expect::crop-to-fit-line (string chars &optional left)
  string)

(defun write-explanation-of-trace (stream)
  (format stream
	"** In the following trace, the indentation of nodes represents~%")
  (html-newline stream)
  (format stream "** solving a subproblem.~%")
  (html-newline stream))

(defun html-newline (stream)
  (if *top-level-in-html*
      (format stream "~%<BR>~%")))

;;; Using the NL code to generate a sentence for the expressions in the
;;; problem execution tree.
(defun grate-nl-expr (expression)
  (string-from-indexed-nl-form
   (expect::grate-linked-nl-desc-expanded-method-plus-heading 
    ;; Too many problems with this to add it at the last minute..
    ;;(expect::pre-process-body-for-nl expression)
    expression
    )))

;;; Based on present-indexed-nl-form

(defvar *replace-columns* 80)
(defvar *last-printed-element-was-white-space* nil)
(defvar expect::*section* nil)

(defun string-from-indexed-nl-form (form &optional (printed-width 0))
  (if (> printed-width *replace-columns*)
      (progn
        (setf printed-width 0)
        ;;(terpri stream)
        ))
  (cond ((or (not (listp form))
	   (not (stringp (car form))))
         (let ((string (format nil "[~S]" form)))
	 ;;(princ string stream)
	 ;;(+ printed-width (length string))
	 string
	 ))
        (t
         (let ((string (format nil "~A~A"
			 (if (equal (car form) " ")
			     ;;*last-printed-element-was-white-space*
			     ""
			   " ")
			 (if (equal (car form) " ")
			     ""
			   (car form)))))
	 (declare (special string))
	 (incf printed-width (+ (length (car form)) 1))
	 (if *last-printed-element-was-white-space*
	     (incf printed-width))
	 (setf *last-printed-element-was-white-space*
	       (char= (elt (car form) (1- (length (car form))))
		    #\Space))
	 #|
	 (dolist (child (fourth form))
	   (setf printed-width
	         (present-indexed-nl-form child stream section old
				    printed-width))
	   )|#
	 (eval `(concatenate 'string
			 string
			 ,@(mapcar #'(lambda (child)
				     (string-from-indexed-nl-form
				      child printed-width))
				 (fourth form))))
	 ))))

;;; If an enode is calcuated with a method (so its current
;;; is an anode for the method), return the method name

(defun enode-underlying-method (node)
  (let ((current (expect::get-enode-current node))
        info plan)
    (if (and current
	   (eq (expect::anode-type current) 'method)
	   (setf info (expect::get-anode-info current))
	   (setf plan (expect::method-info-struc-method info)))
        (expect::ps-plan-name plan))))

;;; Given an enode that is calculated with a method (so its current
;;; is an anode for the method), get a plan annotation for the method.

(defun enode-plan-annotation (node annotation)
  (let ((method-name (enode-underlying-method node)))
    (if method-name
        (get-annotation method-name annotation))))
    

;;; Find a descendant of a node whose expr is a goal with the given name
(defun find-descendant-with-goal (goal node)
  (cond ((and (expect::enode-p node)
	    (eq (first (expect::get-node-expr node)) goal))
         node)
        (node
         (some #'(lambda (child)
	         (find-descendant-with-goal goal child))
	     (cons (if (expect::enode-p node)
		     (expect::get-enode-current node))
		 (expect::get-node-children node))))))

;;; Find all descendants with the goal 
;;; Note - doesn't find descendants that match that are themselves
;;; descended from descendants that match, just finds all the tops
;;; of those chains.
(defun find-all-descendants-with-goal (goal node)
  (cond ((and (expect::enode-p node)
	    (eq (first (expect::get-node-expr node)) goal))
         (list node))
        (node
         (mapcan #'(lambda (child)
	         (find-all-descendants-with-goal goal child))
	     (cons (if (expect::enode-p node)
		     (expect::get-enode-current node))
		 (expect::get-node-children node))))))

;;; Decide whether the specific info at this node should be ommitted
;;; from the explanation (although its children may be included).
(defun skip-explanation-for-node-p (node)
  (let ((expr (expect::get-enode-expr node))
        (expanded (expect::get-enode-expanded-expr node)))
    (if (expect::enode-p node)
        (or (enode-plan-annotation node :skip-in-explanation)
	  (member (first expr)
		'(filter append))
	  (and (eq (first expr) 'if)
	       (eq (fourth expr) 'true)
	       (eq (sixth expr) 'false))
	  ;; Skip adding a set of one element
	  ;; (add (obj (1)))
	  (and (eq (first expanded) 'add)
	       (listp (second (second expanded)))
	       (= (length (second (second expanded))) 1))
	  ;; Skip multiplying a set of one element
	  ;; (multiply (obj (1)))
	  (and (eq (first expanded) 'multiply)
	       (listp (second (second expanded)))
	       (= (length (second (second expanded))) 1))
	  ;; Skip finding the max of a set of one element
	  ;; (find (obj (spec-of expect::maximum)) (of (1)))
	  (and (eq (first expanded) 'find)
	       (equal (second expanded) '(obj (spec-of expect::maximum)))
	       (list (second (third expanded)))
	       (equal (length (second (third expanded))) 1))
	  (match-break-pattern 
	   expr '(is-it-a (obj ?unit) (of |ModernMilitaryUnit-Deployable|)))
	  ;; Leave out all the set reformulation nodes. This one might be
	  ;; too sweeping, I'm checking the results by hand
	  #| It was too sweeping!	;
	  (and (expect::get-enode-current node)
	  (eq (expect::get-anode-type (expect::get-enode-current node))
	  'expect::set))
	  |#
	  ;; Don't print WHO retrievals since they're easy to spot in the 
	  ;; expansion.
	  (eq (first expr) 'who)
	  (eq (first expr) '|equipmentOfUnit|)
	  (eq (first expr) '|echelonOfUnit|)
	  (eq (first expr) 'sub-unit)
	  (eq (first expr) 'all-events-before)
	  (eq (first expr) 'checked-resource)
	  ))))

;;; Try to generate a short "explanation overview" for combat power critiques.

(defun combat-power-overview (critique out natural-language-p)
  (let ((root (if critique (get-value critique 'estimate-info))))
    (when root
      (format out "Overview of combat power explanation:~%")
      (let* ((divide (find-descendant-with-goal 'divide root))
	   (divexpr (if divide (expect::get-enode-expanded-expr divide)))
	   (blue-power (second (assoc 'obj (cdr divexpr))))
	   (red-power (second (assoc 'by (cdr divexpr)))))
        (format out "Force ratio is ~S because Blue combat power is ~S and Red is ~S~%"
	      (expect::get-enode-result divide) blue-power red-power)
        (format out "Contributions to Blue combat power:~%")
        (print-combat-power-contributions
         (find-child-with-result blue-power divide) out)
        ;; of course if red and blue have identical numbers, this won't work.
        (format out "Contributions to Red combat power:~%")
        (print-combat-power-contributions
         (find-child-with-result red-power divide) out))
      )))


(defun find-child-with-result (result node)
  (some #'(lambda (child)
	  (if (equal (expect::get-enode-result child) result)
	      child))
        (expect::get-enode-children node)))

;;; Should run through all the children that are bottom-level
;;; combat powers and print them.
(defun print-combat-power-contributions (node out)
  (find-and-print-combat-powers node out nil))

;;; The recursive part - look at all the children and print out
;;; the "important" ones.
(defun find-and-print-combat-powers (node out divide-by-four-p)
  (cond ((null node) nil)
        ((not (expect::enode-p node))
         nil)
        (t
         (let ((expr (expect::get-enode-expr node)))
	 (cond ((and expr
		   (eq (first expr) 'find)
		   (equal (assoc 'obj (cdr expr))
			'(obj (spec-of combat-power)))
		   (not (listp (second (assoc 'with (cdr expr)))))
		   (assoc 'with-respect-to (cdr expr)))
	        ;; have expanded equipment and chosen one
	        (format out "~S (~A)~%"
		      (if divide-by-four-p
			(/ (expect::get-enode-result node) 4)
		        (expect::get-enode-result node))
		      (second (assoc 'with (cdr expr)))
		      ))
	       ((and expr
		   (eq (first expr) 'find)
		   (equal (assoc 'obj (cdr expr))
			'(obj (spec-of combat-power)))
		   (assoc 'with (cdr expr))
		   (listp (second (assoc 'with (cdr expr))))
		   (eq (first (second (assoc 'with (cdr expr))))
		       '|equipmentOfUnit|)
		   (assoc 'with-respect-to (cdr expr)))
	        ;; about to get the equipment
	        (format out "    ~A:  "
		      (second (second (assoc 'with (cdr expr))))))
	       ((and expr
		   (eq (first expr) 'divide)
		   (equal (second (assoc 'by (cdr expr))) 4))
	        ;; This is a company so we're dividing by 4
	        ;; Please forgive the kruft!!
	        (setf divide-by-four-p t))
	       ((and expr
		   (eq (first expr) 'compute-attrition)
		   )
	        (let ((before-value (second (assoc 'obj (cdr (expect::get-enode-expanded-expr node)))))
		    (after-value (expect::get-enode-result node)))
		(if (equal before-value after-value)
		    (format out "  The following group of forces sum to ~S~%"
			  after-value 
			  )
		    (format out "  The following forces sum to ~S after attrition (~S before attrition):~%"
			after-value before-value
			))
		))
	       )
	 )))
  (if node
      (dolist (child (cons (expect::get-enode-current node)
		       (expect::get-enode-children node)))
        (find-and-print-combat-powers child out divide-by-four-p))))


;;; Preparing for input

;;; Can use the following type keywords:
;;; :coa - evaluate a coa
;;; :cp-available - estimate the available combat power for a critical event

(defun set-goal (&key (type :coa) object)
  (cond ((eq type :coa)
         (unless object
	 (setf object (choose-coa)))
         (if object
	   (setf *exe-top-level-goal* `(evaluate (obj ,object)))))
        ((eq type :cp-available)
         (unless object
	 (setf object (choose-critical-event-or-main-op)))
         (if object
	   (setf *exe-top-level-goal* 
	         `(estimate (obj (inst-of inadequate-forces-for-task-critique))
			(available-to ,object)))))
        ((eq type :unit-cp)
         (unless object
	 (setf object 
	       (choose-candidate (mapcar #'get-name (retrieve ?u (military-unit ?u))))))
         (let ((task (choose-candidate (mapcar #'get-name (retrieve ?t (task-action ?t))))))
	 (if (and object task)
	     (setf *exe-top-level-goal*
		 `(estimate (obj combat-power)
			  (of ,object)
			  (with-respect-to ,task))))))
        ))
        

(defun choose-coa ()
  (choose-candidate (mapcar #'get-name (retrieve ?c (coa ?c)))))

(defun choose-critical-event-or-main-op ()
  (choose-candidate 
   (mapcar #'get-name 
	 (append
	  (retrieve ?ce (for-some (?coa) (and (coa ?coa)
				        (critical-event-of ?coa ?ce))))
	  (retrieve ?maintask (for-some (?coa) (and (coa ?coa)
					    (for-some (?mo)
						    (and (main-operation-of ?coa ?mo)
						         (|taskOfOperation| ?mo ?maintask))))))
	  ))))
  
(defun choose-candidate (candidates)
  (do ((res nil))
      ((and res (numberp res) (>= res 0) (<= res (length candidates)))
       (unless (zerop res)
         (elt candidates (1- res))))
    (format t "Enter the number for your choice (or zero to escape)~%")
    (dotimes (i (length candidates))
      (format t "~S: ~S~%" (1+ i) (elt candidates i)))
    (format t "> ")
    (setf res (read))))

