(in-package "EXPECT")
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Main function (nl-edit-menu). When called with either a plan name or the plan
;; structure, will return a parsed structure of the plan in the following format:
;;
;; ((METHOD-NAME ("nl form of name" METHOD-NAME index NIL))
;;  (METHOD-CAPABILITY ("nl form of capability" CAPABILITY-CODE index <children>))   
;;  (METHOD-BODY ("nl form of body" BODY-CODE index <children>)))
;;
;; The structure of all the lists have the same representation;ie. they are 4-element
;; lists with the first element being the nl form, the sencond being the code that generates
;; this nl form, the third is a unique index number and the last element is a list (4-ele)
;; of all its children (NIL when there are no children. So all calls made to functions will
;; return 4-elements lists only or the caller function will convert them to the correct format.
;; An example of a 4-ele list would be :
;;    (" " (OBJ (?S IS (SET-OF (SPEC-OF SHIP)))) 4
;;     ((" " OBJ 5 NIL)
;;      ("the ships" (SET-OF (SPEC-OF SHIP)) 6 NIL)))
;; In this example we can see the power of hierarchical decomposition of the code
;; provides a way for the user to look at/select unique chunks of code that they 
;; may want to replace. This framework allows for the code to be decomposed while
;; still retaining its (the code's) ability to generate meaningful english text.
;; So a method (example taken from the Transportation-Small domain) to find available ships
;; which looks like (NIL slots removed):
;;
;; NAME               FIND-SHIPS-AVAILABLE
;; CAPABILITY
;;    (FIND (OBJ (?S IS (SET-OF (SPEC-OF SHIP))))
;;          (AVAILABLE-IN (?PORT1 IS (INST-OF SEAPORT)))
;;      (TO (?PORT2 IS (INST-OF SEAPORT))))
;; RESULT             (SET-OF (INST-OF SHIP))
;; METHOD
;;    (FILTER (OBJ (R-SHIPS ?PORT1))
;;     (WITH (DETERMINE-WHETHER (OBJ (R-SHIPS ?PORT1)) (FITS-IN ?PORT2))))
;; CAPABILITY-NL      "find the ships available in a seaport to a seaport"
;;
;; will generate the following parsed structure 
;;
;;((METHOD-NAME ("find ships available" FIND-SHIPS-AVAILABLE 1 NIL))
;; (METHOD-CAPABILITY
;;  (" "
;;   (FIND (OBJ (?S IS (SET-OF (SPEC-OF SHIP))))
;;         (AVAILABLE-IN (?PORT1 IS (INST-OF SEAPORT)))
;;     (TO (?PORT2 IS (INST-OF SEAPORT))))
;;   2
;;   (("find" FIND 3 NIL)
;;    (" " (OBJ (?S IS (SET-OF (SPEC-OF SHIP)))) 4
;;     ((" " OBJ 5 NIL) ("the ships" (SET-OF (SPEC-OF SHIP)) 6 NIL)))
;;    (" " (AVAILABLE-IN (?PORT1 IS (INST-OF SEAPORT))) 7
;;     ((" available in" AVAILABLE-IN 8 NIL)
;;      ("the first seaport" (INST-OF SEAPORT) 9 NIL)))
;;    (" " (TO (?PORT2 IS (INST-OF SEAPORT))) 10
;;     ((" to" TO 11 NIL) ("the second seaport" (INST-OF SEAPORT) 12 NIL))))))
;; (METHOD-BODY
;;  (" "
;;   (FILTER (OBJ (R-SHIPS ?PORT1))
;;    (WITH (DETERMINE-WHETHER (OBJ (R-SHIPS ?PORT1)) (FITS-IN ?PORT2))))
;;   13
;;   (("filter" FILTER 14 NIL)
;;    (" " (OBJ (R-SHIPS ?PORT1)) 15
;;     ((" " OBJ 16 NIL)
;;      (" " (R-SHIPS ?PORT1) 17
;;       (("the ships of" R-SHIPS 18 NIL)
;;        ("the first seaport" ?PORT1 19 NIL)))))
;;    (" " (WITH (DETERMINE-WHETHER (OBJ (R-SHIPS ?PORT1)) (FITS-IN ?PORT2))) 20
;;     ((" with" WITH 21 NIL)
;;      (" " (DETERMINE-WHETHER (OBJ (R-SHIPS ?PORT1)) (FITS-IN ?PORT2)) 22
;;       (("determine whether" DETERMINE-WHETHER 23 NIL)
;;        (" " (OBJ (R-SHIPS ?PORT1)) 24
;;         ((" " OBJ 25 NIL)
;;          (" " (R-SHIPS ?PORT1) 26
;;           (("the ships of" R-SHIPS 27 NIL)
;;            ("the first seaport" ?PORT1 28 NIL)))))
;;        (" " (FITS-IN ?PORT2) 29
;;         ((" fits in" FITS-IN 30 NIL)
;;          ("the second seaport" ?PORT2 31 NIL)))))))))))
;;
;; The " " nl stings provide a way for the users to select extended chunks of code that
;; they can modify. They also at times represent objects that have no direct nl translation.
;; Thus the natural language for the method is the concatination of all the first elements
;; (the nl string) of all the lists in order (follow the indeces).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; This file also contains functions that will take a plan, user specified changes and
;; then will make the changes and commit them. Note: all functions that start with 
;; grate-linked-nl-<specific name> will return the 4-ele list.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Variable decleration section
(defvar *indx* 0 "Index used for counter")
(defvar *loc* 0 "temp var used to replace nth")
(defvar *vars-assoc-list* nil "Assoc list for substitution of vars in body with type from capability")
(defvar *on-body* nil "flag for knowing if the nl gen is on the body")


;; Main function call. Initially the parsed plan structure has all its indeces set to -1.
;; Then "add-indexig" is called that changes all the -1s to unique numbers
(defun nl-edit-menu (plan)
    (add-indexing (modify-format (gen-linked-nl-desc-plan plan))))

;; This is used to get the final parsed structure into the structure shown in the example
(defun modify-format (lst)
  (list
   (list 'method-name (first lst))
   (list 'method-capability (second lst))
   (list 'method-body (third lst))))

;; Main function that will take the changes, the plan and the nl-parsed structure and then
;; commit the changes. The structure of changes that is formed in frame-window.lisp has the
;; following format; where method-section is either the capability or the body and alt-selection
;; is the type of alternative chosen (goal or variable or relation...)
;; ((METHOD-SECTION ("nl stirng" code index <clildren>))
;;  (ALT-SELECTION ("nl string" code -1 <children>)))
(defun commit-nl-changes (plan changes nl-code)
  (let (( place (my-member (second (second (first changes)))
		       (cdr (assoc (first (first changes)) nl-code))))
        (selected-code (second (second (first changes))))
        (modified-code (second (second (second changes)))))
    (if (eq (length place) 1)
        (make-nl-changes-in-plan plan (caar changes)
			   (list (list selected-code modified-code)))
      (let ((new-code (replace-nth
		   selected-code
		   (+ 1 (position (third (second (first changes))) place))
		   (if (equal (first (first changes)) 'method-capability)
		       (get-plan-capability plan)
		     (get-plan-method plan))
		   modified-code)))
        (if (equal (first (first changes)) 'method-capability)
	  (set-plan-capability plan new-code)
	(set-plan-method plan new-code))))))

;; This function will make the changes globally in a section of code (the capability, the body, etc)
(defun make-nl-changes-in-plan (plan section changes)
  (cond
   ((equal section 'METHOD-CAPABILITY)
    (set-plan-capability plan (build-similar-capability
			 (get-plan-capability plan)
			 changes)))
   ((equal section 'METHOD-BODY)
    (set-plan-method plan (build-similar-method
		       (get-plan-method plan)
		       changes)))))

;; The function that will generate the parsed nl structure of the capability and the method body
(defun gen-linked-nl-desc-plan (plan-name-or-struct)
  (let* ((s-plan (if (symbolp plan-name-or-struct)
		 (ka-find-plan plan-name-or-struct)
	         plan-name-or-struct)))
    (setf *on-body* nil)
    (setf *vars-assoc-list*
	(mapcan #'(lambda (p)
		  (if (and (listp (second p))
			 (lexicon-variable-p (first (second p))))
		      (list (cons (caadr p) (car (cddadr p))))))
	        (cdr (get-plan-capability (coerce-to-plan-struc s-plan)))))
    (list
     (list (grate-nl-desc-goal-name (get-plan-name s-plan)) (get-plan-name s-plan) '-1 nil)
     ;; the part for the capability
     (list " " (get-plan-capability s-plan) '-1
	 (cons (list (grate-nl-desc-goal-name (car (get-plan-capability s-plan)))
		   (car (get-plan-capability s-plan))
		   -1 nil)
	
	       (mapcar #'(lambda (a)
		         (list " " a -1
			     (grate-linked-nl-desc-goal-arg
			      a nil
			      (member (car a)
				    (repeated-arg-concepts
				     (cdr (get-plan-capability s-plan)))))))
		     (cdr (get-plan-capability s-plan)))))
     ;; The part for the method body.
     (grate-linked-nl-desc-plan-method s-plan))))

;; This is called on the arguments of the goal
(defun grate-linked-nl-desc-goal-arg (goal-arg
			        &optional (generic-p nil) (repeated-p nil))
  (let ((param-name (car goal-arg))
        (param-type (find-mod-arg-type goal-arg)))
    (when (and (equal param-name 'OBJ)
	     (or (lexicon-concept-p param-type)
	         (and (listp param-type)
		    (equal (car param-type) 'spec-of))))
	         
      (setq generic-p nil))
    (list (list
	 (grate-nl-desc-param-name param-name) param-name '-1 'nil)
	(list
	 (if (eq (car param-type) 'inst)
	     (format nil "the ~A" 
	     (grate-nl-desc-type (cadr param-type)
			     generic-p repeated-p (equal param-name 'OBJ)))
	 (format nil "~A~A ~A"
	         ;;Oops, see  grate-linked-nl-desc-expanded-method for what's going on below
	         (subseq (grate-nl-desc-type
		        (cadr param-type) generic-p repeated-p (equal param-name 'OBJ))
		       0 3) ;only the "the "
	         (if (or (not (lexicon-variable-p (car param-type)))
		       (eq (find-nth-occ-name (car param-type)) 0)) ""
		 (format nil " ~:R" (find-nth-occ-name (car param-type))))
	         (subseq (grate-nl-desc-type
		        (cadr param-type) generic-p repeated-p (equal param-name 'OBJ))
		       4))) ;all but the "the "
	 (cadr param-type)
	 '-1
	 'nil))
	))

;; This function is called to get the parsed structue of the method-body..
;; The parsing of the capability and the method body are slightly different.
;; Refer to places that the *on-body* flag is checked..
(defun grate-linked-nl-desc-plan-method (plan)
  (let ((expanded-method (get-plan-method (coerce-to-plan-struc plan))))
    (setf *on-body* t)
    (cond ((not (listp expanded-method)) ; when there is an instance to return
	 (grate-linked-nl-desc-type expanded-method))
	((listp (car expanded-method)) ; this is for plans that lose the value of a step.
				; these plans are not grammatical.  This is for KA.
	 (list " " expanded-method -1
	       (list
	        (grate-linked-nl-desc-expanded-method-plus-heading
	         (car expanded-method))
	        (list ", and then" nil -1 nil)
	        (grate-linked-nl-desc-expanded-method-plus-heading
	         (cadr expanded-method)))))
	(t
	 (grate-linked-nl-desc-expanded-method-plus-heading expanded-method)))))


;; Called to generate the nl for the type (edt).
;; l can be either (spec-of c), (inst-of c), (set-of (inst-of c)),
;; (set-of (spec-of c)), or an instance
(defun grate-linked-nl-desc-type (l &optional
			    (generic-p nil)
			    (repeated-p nil)
			    (direct-object-p nil))
  (let ((text-list
         (if (not (listp l))
	   (grate-linked-nl-desc-instance-name l)
	 (let ((left l)
	       (plural nil))
	   (cond
	    ;; (set-p (list (car left)))
	    ;; To remove references to '(spec-of desc-of set-of inst-of) by using the functions
	    ;; in the shared/edts.lisp file but quite not what is needed here
		((equal (car left) 'set-of)
		(setq plural "s")
		(setq left (cadr left)))
	         (t
		(setq plural "")))
	   (let ((name-string
		(car (grate-linked-nl-desc-concept-name (cadr left)))))
	     (format nil "~A ~A~A" 
		   (if repeated-p 
		       (if generic-p
			 (format nil "another")
		         (format nil "the other"))
		     (if generic-p 
		         (if (string-equal plural "s")
			   (if direct-object-p
			       (format nil "the")
			     (format nil "several"))
			 (if (member (char name-string 0) 
				   '(#\a #\e #\i #\o #\u)
				   :test #'char-equal)
			     (format nil "an")
			   (format nil "a")))
		       (format nil "the")))
		   name-string
		   plural))))))
    (if (and (listp l) (eq (length l) 3))
        (list text-list (third l) '-1 'nil)
      (list text-list l '-1 'nil))))


;; Concept names parse into themselves..
(defun grate-linked-nl-desc-concept-name (c)
  (cons (print-pretty-string (format nil "~A" c)) (list c)))

;; Function for instance names checks if the name starts with "instance-...."
;; if so, it just removes it and then returns the rest of the name.
(defun grate-linked-nl-desc-instance-name (i)
  (let ((i-name (format nil "~A" i))
        (i-real-name nil))
    (cond ((and (> (length i-name) 9)
	      (string= (string-downcase (subseq i-name 0 9))
		     "instance-"))
	 (setq i-real-name (subseq i-name 9)))
	(t
	 (setq i-real-name i-name)))
    (list (string-capitalize (print-pretty-string i-real-name)) i '-1 'nil)
    ))

;; Adds a dummy "retrieve". Its a dummy 'cause the code matching the nl string is set to nil
(defun adjust-heading-for-linked-expanded-method (expanded-method desc)
  (if (lexicon-relation-p (car expanded-method))
      ;; If it's a relation, add the "retrieve" word as a new child in
      ;; front of the other children, with no attached code.
      (push (list "retrieve" nil -1 nil)
	  (fourth desc)))
  desc)

;; Caller function for the one above
(defun grate-linked-nl-desc-expanded-method-plus-heading (expanded-method)
  (let ((desc (grate-linked-nl-desc-expanded-method expanded-method)))
    (adjust-heading-for-linked-expanded-method expanded-method desc)))


(defun grate-linked-nl-desc-expanded-method (m &optional (repeated-p nil))
  (let ((result nil))
    (when (not (null m))
      (cond
       ((and *on-body* (lexicon-variable-p m))
        (setq result
	    (list (get-spl-text-for-vars m) m '-1 'nil)))
       ((and (not *on-body*) (lexicon-variable-p m))
        (setq result
	    (list (get-spl-text-for-vars m) m '-1 'nil)))
       ((not (listp m))   ;; when there is an instance name
         ;; this function always returns a list of items.
        (setq result (grate-linked-nl-desc-instance-name m)))
       ((equal 'spec-of (car m))
        (setq result (list (grate-linked-nl-desc-type m) m '-1 'nil)))
       ((lexicon-relation-p (car m))
        (setq result (grate-linked-nl-desc-rel-embedded-in-method m repeated-p)))
       ((lexicon-goal-p (car m))
        (setq result (grate-linked-nl-desc-goal-in-method m)))
       ((equal 'filter (car m))
        (setq result (grate-linked-nl-desc-goal-in-method m)))
       ((equal 'if (car m))
        (setq result (grate-linked-nl-desc-if m)))
       ((or (equal 'append-elts (car m))
	  (equal 'append (car m)))
        (setq result (grate-linked-nl-desc-append-elts m)))
       ((equal 'and (car m))
        (setq result (grate-linked-nl-desc-and m)))
       ((equal 'or (car m))
        (setq result (grate-linked-nl-desc-or m)))
       ((equal 'not (car m))
        (setq result (grate-linked-nl-desc-not m)))
       ((equal 'catch (car m))
        (setq result (grate-linked-nl-desc-catch&fail m)))
       ((and *on-body* (lexicon-variable-p (car m)))
        (setq result
	    (list
	     ;; Note the next call should not be to grate-linked-nl-desc
	     ;; 'cause we are creating the 4-ele list here..
	     ;; Another really neat thing happening here is that when we refer to
	     ;; a var (especially in the body), we to refer to it as "the first seaport"
	     ;; and not ?port1. This is done by looking at the type of the var
	     ;; (from *vars-assoc-list*) and then seeing how many such vars are there
	     ;; ('cause we do not want to refer to port1 as the first seaport if there
	     ;; is only one seaport!). The "~:R" allows for "1" to be printed as "first",
	     ;; "2" as "second"...
	     (format nil "~A ~A ~A"
		   (subseq
		    (grate-nl-desc-type
		     (if (listp (cdr (assoc (car m) *vars-assoc-list*)))
		         (cadr (assoc (car m) *vars-assoc-list*))
		       (cdr (assoc (car m) *vars-assoc-list*)))
		     nil repeated-p)
		    0 3)
		   (if (eq (find-nth-occ-name (car m)) 0) ""
		     (format nil "~:R" (find-nth-occ-name (car m))))
		   (subseq
		    (grate-nl-desc-type
		     (if (listp (cdr (assoc (car m) *vars-assoc-list*)))
		         (cadr (assoc (car m) *vars-assoc-list*))
		       (cdr (assoc (car m) *vars-assoc-list*))))
		    4))
	     (car m) '-1 'nil)))
       ((and (not *on-body*) (lexicon-variable-p (car m)))
        (setq result
	    (list (get-spl-text-for-vars (car m)) (car m) '-1 'nil)))

       ((and (not *on-body*) (lexicon-variable-p m))
        (setq result
	    ;; The reference here to get-spl-text-for-var does something similar to
	    ;; what was described above for variables
	    (list (get-spl-text-for-vars m) m '-1 'nil)))
       (t
        (setq result (list " " m '-1 'nil)))))
    result))


(defun grate-linked-nl-desc-if (l)
  (list " " l '-1
        (list (list "if" nil -1 nil)
	    (grate-linked-nl-desc-expanded-method (second l))
	    (list "then" nil -1 nil)
	    (grate-linked-nl-desc-expanded-method (fourth l))
	    (list "else" nil -1 nil)
	    (grate-linked-nl-desc-expanded-method (sixth l)))))

(defun grate-linked-nl-desc-append-elts (l)
  (list
   " " l '-1
   (cons (format nil "append ~A~{ and ~A~}"
	         (list " " (second l) '-1 (grate-nl-desc-expanded-method (second l)))
	         (mapcar #'(lambda (arg)
		             (list " " arg '-1 (grate-linked-nl-desc-expanded-method arg)))
		         (cddr l)))
         (list " " (second l) '-1 (list (cons (second l)
		                              (mapcar #'(lambda (arg)
			                                  (grate-linked-nl-desc-expanded-method arg))
                                                      mess))))))); this needs cleaning up - Jim

;;
(defun grate-linked-nl-desc-and (l)
  (list
   (list (format nil "check that all of the following are true") 'and -1 'nil)
   (list " " (second l) -1
         (car (last (grate-linked-nl-desc-goal-arg-in-method (second l)))))
   (list " " (third l) -1
         (car (last (grate-linked-nl-desc-goal-arg-in-method (third l)))))))

;;
(defun grate-linked-nl-desc-or (l)
  (list
   (list (format nil "check that at least one of the following are true") 'or -1 'nil)
   (list " " (second l) -1
         (car (last (grate-linked-nl-desc-goal-arg-in-method (second l)))))
   (list " " (third l) -1
         (car (last (grate-linked-nl-desc-goal-arg-in-method (third l)))))))

;;
(defun grate-linked-nl-desc-not (l)
  (list
   (list (format nil "check that it is not true that") 'not -1 nil)
   (grate-linked-nl-desc-goal-arg-in-method (second l))))


;; Format needs changing (to 4-ele list structure). SR.
(defun grate-linked-nl-desc-catch&fail (l)
  (list " " l '-1 (cons (format nil "check that if ~A fails, then ~A is true"
	      (grate-nl-desc-expanded-method (second l))
	      (grate-nl-desc-expanded-method (cadr (third l))))
        (list (second l) (cadr (third l))))))


(defun grate-linked-nl-desc-goal-embedded-in-method (l)
  (list " " l '-1
        (list (list "the result of a method to" nil -1 nil)
	    (grate-nl-desc-goal-in-method l))))



(defun grate-linked-nl-desc-rel-embedded-in-method (l &optional (repeated-p nil))
  (list " " l -1
        (list
         (list (grate-nl-desc-relation-name (car l)) (car l) '-1 'nil)
         (if (lexicon-variable-p (cadr l))
	   (list (get-spl-text-for-vars (cadr l)) (cadr l) '-1 'nil)
	 (grate-linked-nl-desc-expanded-method (cadr l))))))



(defun grate-linked-nl-desc-goal-in-method (goal)
  (let ((repeated (repeated-arg-concepts (cdr goal))))
    (list " " goal -1
	(cons
	 (list
	  (grate-nl-desc-goal-name (car goal)) (car goal)
	  '-1 'nil)
	 (mapcar #'(lambda (a)
		   (grate-linked-nl-desc-goal-arg-in-method
		    a (member (car a) repeated)))
	         (cdr goal))))))


(defun grate-linked-nl-desc-goal-arg-in-method (goal-arg &optional (repeated-p nil))
  (let ((param-name (car goal-arg)))
    (list " "
	goal-arg
	'-1
	(cond
	 ((not (listp (second goal-arg))) ; ex: (obj inst-30)
	  (append ;;list
	   (list (list (grate-nl-desc-param-name param-name) param-name '-1 'nil))
	   (list (if (lexicon-variable-p (second goal-arg))
	       (grate-linked-nl-desc-expanded-method
	        (second goal-arg) repeated-p)
	     (grate-linked-nl-desc-instance-name (second goal-arg))))
	   (if (equal (length goal-arg) '3)
	       (grate-linked-nl-desc-instance-name (third goal-arg))))) ;ex:(equal param-name 'OBJ)
;; To remove references to '(spec-of desc-of set-of inst-of) by using the functions
;; in the shared/edts.lisp file but quite does not do what I need here..
	 ((member (caadr goal-arg) '(spec-of desc-of set-of inst-of))	  
	  ;; ((intensional-p (caadr goal-arg))

	  (list (list (grate-nl-desc-param-name param-name) param-name '-1 'nil)
	        (grate-linked-nl-desc-type (cadr goal-arg) nil repeated-p)))
	 ((member (car goal-arg) '(and or not catch))
	  (grate-linked-nl-desc-expanded-method goal-arg))
	 (t
	  (list
	   (list (grate-nl-desc-param-name param-name) param-name '-1 'nil)
	   (grate-linked-nl-desc-expanded-method (cadr goal-arg) repeated-p)))))))



(defun grate-nl-desc-param-name (param-name)
  (string-downcase
   (if (not (equal param-name 'OBJ))
       (print-pretty-string (format nil " ~A" param-name))
     (format nil " "))))


;;;;;;;;;;;;;;;;;
;;;Util functions
;;;;;;;;;;;;;;;;

;; Replaces the nth occ ("pos") of "inst" in "code" with "rep"
;; the func is struc-preserving (the 4-ele list structure)  &
;; nth is counted from left to right
(defun replace-nth (inst pos code rep)
  (progn
    (setf *loc* pos)
    (replnth inst code rep)))

(defun replnth (inst code repl)
  (cond
   ((null code) '())
   ((equal inst (car code))
    (if (eq *loc* 1)
      (progn
        (decf *loc*)
        (cons repl (cdr code)))
      (progn
        (decf *loc*)
        (cons (car code) (replnth inst (cdr code) repl)))))
   ((listp (car code)) (append
		    (list (replnth inst (car code) repl))
		    (if (not (listp (cdr code)))
		    (replnth inst (list (cdr code)) repl)
		    (replnth inst (cdr code) repl))))
   (t (cons (car code) (replnth inst (cdr code) repl))))) 


;; Returns a list of positions of the ele in the lst
;; with the lst struct being : ( ("nl"  <code>  index <children>) .. ... )
(defun my-member (ele lst)
  (cond
   ((null lst) '())
   ((and (listp lst) (listp (first lst)))
    (append (my-member ele (car lst)) (my-member ele (cdr lst))))
   ((and (listp lst) (stringp (first lst)))
    (if (equal ele (second lst)) (list (third lst))
      (my-member ele (cdr lst))))
   (T (my-member ele (cdr lst)))))


;; The following adds an indexing to a list of type (("nl"  <code> -1 <children>) .. ...)
;; to return an indexed list of (("nl" <code> 1 <children>).... ("nl" <code> 13 <children>)  ...)
(defun add-indexing (lst)
  (reset)
  (add-index lst))

(defun add-index (lst)
  (cond
   ((null lst) '())
   ((symbolp lst) lst)
   ((listp (car lst)) (append (list (add-index (car lst))) (add-index (cdr lst))))
   ((eq (car lst) -1) (append (list (counter)) (add-index (cdr lst))))
   (t (append (list (car lst)) (add-index (cdr lst))))))


;; Counter is used by add-indexing to get the new index
(defun counter ()  (incf *indx*))
(defun reset () (setf *indx* 0))

;; Bind just conses the two elements an is used to bind the nl to its code
(defun bind (nl-desc code-desc)
  (cons nl-desc code-desc))

;; This function is used to modify the code such that:
;; skips variables if needed:
;; Enter FIND-ARG-TYPE (OBJ INSTANCE-4)
;; Exit FIND-ARG-TYPE INSTANCE-4
;; Enter FIND-ARG-TYPE (OF (INST-OF COA))
;; Exit FIND-ARG-TYPE (INST-OF COA)
;; where arg could be one of the above
(defun find-mod-arg-type (arg)
  (cond ((not (listp (cadr arg)))
         (cadr arg))
        ((lexicon-variable-p (caadr arg))
         (list (caadr arg) (car (cddadr arg))))    ;;No! ; skip variables
        (t (cadr arg))))


(defun expand-plan-method-with-vars (plan)
  ;; NOTE: the vars-assoc-list is a list of cons cells, which is what
  ;; sublis takes as the first parameter.  That's why the mapcar conses
  ;; the vars and their types. (I changed it to a mapcan so it wouldn't
  ;; fail - if it fails the KA crashes. Jim)
  (let ((vars-assoc-list
         (mapcan #'(lambda (p)
		 (if (listp (cadr p))
		     (list (cons (caadr p) (car (cddadr p))))))
	       (cdr (get-plan-capability (coerce-to-plan-struc plan))))))
    (sublis (var-subst vars-assoc-list)
	  (get-plan-method (coerce-to-plan-struc plan)))))

;; called from function above and essentially walks thru the *vars-assoc-list*
;; and for all variables in the assoc list it will append the variable name to the
;; end of the assoc-list
(defun var-subst (var-lst)
  (cond
   ((null var-lst) '())
   ((lexicon-variable-p (car var-lst))
    (list (append var-lst (list (car var-lst)))))
   ((not (listp (car var-lst))) (list var-lst))
   (t
    (append (var-subst (car var-lst))
	  (var-subst (cdr var-lst))))))

;; Returns a list of all the assocs in an assoc list (used on *vars-assoc-list*)
(defun gather-assocs (a-lst)
  (cond
   ((null a-lst) '())
   (t (cons (cdr (car a-lst)) (gather-assocs (cdr a-lst))))))

;; Returns a list of all the assoc-keys in an assoc list (used on *vars-assoc-list*)
(defun gather-akeys (a-lst)
  (cond
   ((null a-lst) '())
   (t (cons (first (car a-lst)) (gather-akeys (cdr a-lst))))))

;; Returns a (T/NIL) list of positions of membership
(defun is-member (ele lst)
  (cond
   ((null lst) '())
   (t (append
       (if (equal ele (car lst)) (list 't) (list 'nil))
       (is-member ele (cdr lst))))))

;; Returns the position of the occurance of var-name in the *vars-assoc-list*
;; but returns 0 if there is only one
(defun find-nth-occ-name (var-name)
  (let*
      ((name-assoc (cdr (assoc var-name *vars-assoc-list*)))
       (rest-alist (gather-assocs *vars-assoc-list*))
       (member-list (is-member name-assoc rest-alist)))
    (if (eq (count 'T member-list) 1) 0
      (+ (count 'T member-list
	      :start 0
	      :end (position var-name (gather-akeys *vars-assoc-list*)))
         1))))


;; This function is called with variables for a spl nl generation; when we refer to
;; a var (especially in the body), we to refer to it as "the first seaport"
;; and not ?port1. This is done by looking at the type of the var
;; (from *vars-assoc-list*) and then seeing how many such vars are there
;; ('cause we do not want to refer to port1 as the first seaport if there
;; is only one seaport!). The "~:R" allows for "1" to be printed as "first",
;; "2" as "second"...
(defun get-spl-text-for-vars (var)
  (format nil "~A~A ~A"
	(subseq (grate-nl-desc-type (cdr (assoc var *vars-assoc-list*))) 0 3)
	(if (eq (find-nth-occ-name var) 0) ""
	  (format nil " ~:R" (find-nth-occ-name var)))
	(subseq (grate-nl-desc-type (cdr (assoc var *vars-assoc-list*))) 4)))


;; nl gen for the result of a plan quite does not give me what I need. needs change.
;; (set-of (inst-of boolean)) -> ("the booleans" (set-of (inst-of boolean)) -1 nil)
(defun grate-linked-nl-result (plan-name)
  (let ((result (get-plan-result (ka-find-plan plan-name))))
    (grate-linked-nl-desc-type result)))
