(in-package "KANAL")

(defvar *kanal-xml-stream* (make-string-output-stream))

(defun kanal-xml-format (string &rest args)
  (apply #'format (cons *kanal-xml-stream* 
			(cons string args)))
  )


;;; ==========================================================
;;; get error-items and info-items
;;; ==========================================================

(defun kanal-result-to-xml (kanal-output &optional *kanal-xml-stream*)
  (let ((cl-user::*recursive-classification* nil)
        (cl-user::*indirect-classification* nil)
        (cl-user::*backtrack-after-testing-unification* nil))
  (kanal-xml-output-header)
  (mapcar #'kanal-item-to-xml kanal-output)
  (kanal-xml-output-footer)
  )
)



(defun kanal-item-to-xml (item)
  (if (info-item? item)
      (kanal-info-item-to-xml item)
    (kanal-error-item-to-xml item))
  )


(defun kanal-info-item-to-xml (info-item)
  ;(format t "info item :: ~S~%" info-item)
  (kanal-xml-info-item-header)
  (let ((type (get-field 'type info-item))
	(id (get-field 'id info-item))
	(source (get-field 'source info-item))
	(content (get-field 'content info-item))
	(situation nil)
	)

    (when (or (equal type :event-info-before-execution)
	    nil)
           (setq situation (cadr source))
           (setq source (car source)))

    (kanal-xml-item 'type type situation)
    (kanal-xml-item 'source source situation)
    (kanal-xml-list-content type content situation)    
    (kanal-xml-item 'id id  situation)
    (if (equal type :simulated-paths)
	(setf add-subevents t)
      )
    )
  (kanal-xml-info-item-footer)
  )



(defun kanal-error-item-to-xml (error-item)
  (kanal-xml-error-item-header)
  ;(format t "error item :: ~S~%" error-item)
  (let ((type (get-field 'type error-item))
	(level (get-field 'level error-item))
	(source (get-field 'source error-item))
	(constraint (get-field 'constraint error-item))
	(success (get-field 'success error-item))
	(id (get-field 'id error-item))
	(situation nil)
	(next-situation nil)
	)

    ;; Situation information for specific items
    (when (or (equal type :expected-effect-for-step)
            (equal type :precondition)
	    (equal type :soft-precondition))
           (setq situation (second source))
           (setq source (first source)))

    (when (equal type :no-effect)
          (setq next-situation (third source))
          (setq situation (second source))
          (setq source (first source)))

    (kanal-xml-item 'type type situation)
    (kanal-xml-item 'success success situation)
    (kanal-xml-list-source type source)
    (kanal-xml-list-constraint type source constraint situation next-situation)
    (kanal-xml-item 'level level situation)
    (kanal-xml-item 'id id situation)

    (if (and (not success) (not (and (equal type :unreached-events) (and (listp source) (> (length source) 1)))))
	(kanal-xml-item-user-input type))
    )
  (kanal-xml-error-item-footer)
  )



;added by amit agarwal (5/24/2002)
(defun kanal-xml-item-user-input (error-type)
  (kanal-xml-user-input-header)
  (case error-type
    ((:no-effect :missing-subevent :missing-first-subevent :missing-link :unreached-events :cannot-delete :not-parallel :precondition :soft-precondition)
     (kanal-xml-user-input-item-header 'HREF)
     (kanal-xml-user-input-href (format nil "Click here for suggestions"))
     (kanal-xml-user-input-item-footer)
     )
    ((:expected-effect :expected-effect-for-step)
     (kanal-xml-user-input-item-header 'HREF)
     (kanal-xml-user-input-href (format nil "Click here to find help for fixing this error"))
     (kanal-xml-user-input-item-footer)
     )
    ((:inexplicit-precondition :inexplicit-soft-precondition)
     (kanal-xml-user-input-item-header 'HREF)
     (kanal-xml-user-input-href (format nil "If this is in fact false, click here for suggestions"))
     (kanal-xml-user-input-item-footer)
     )
    ((:loop :max-loops :temporal-loop)
     )
    (:unnecessary-link
     (kanal-xml-user-input-item-header 'HREF)
     (kanal-xml-user-input-href (format nil "Click here for suggestions"))
     (kanal-xml-user-input-item-footer)
     )
    )
  (kanal-xml-user-input-footer)
  )





;added by amit agarwal (5/24/2002)
(defun kanal-xml-user-input-button (button-type display)
  (kanal-xml-item-header 'button-type)
  (kanal-xml-format button-type)
  (kanal-xml-item-footer 'button-type)
  (kanal-xml-item-header 'display)
  (kanal-xml-format display)
  (kanal-xml-item-footer 'display)
  )



;added by amit agarwal (5/24/2002)

(defun kanal-xml-user-input-href (display)
  (kanal-xml-item-header 'display)
  (kanal-xml-format display)
  (kanal-xml-item-footer 'display)
  )

(defun kanal-xml-item (name content &optional (situation nil))
  (kanal-xml-item-header name)

  (ignore-errors 
  (cond ((stringp content)
	 (kanal-xml-format content)
	 )
	((equal content '>)
	 (kanal-xml-format "greater than")
	 )
	((equal content '<)
	 (kanal-xml-format "less than")
	 )
	((equal content '>=)
	 (kanal-xml-format "greater than or equal to")
	 )
	((equal content '<=)
	 (kanal-xml-format "less than or equal to")
	 )
	((equal content '=)
	 (kanal-xml-format "equal to")
	 )
	((equal content 'user::<>)
	 (kanal-xml-format "not equal to ")
	 )
	((and (listp content) (equal (cadr content) 'user::&))
	      (kanal-xml-item 'list-item (km-k content))
	 )
	((typep content 'number)
	 (kanal-xml-format (write-to-string content))
	 )
	((typep content 'boolean)
	 (kanal-xml-format (write-to-string content))
	 )
	((atom content)
	 (kanal-xml-format1 (ignore-errors (rkf::generate-text content)))
	 ;(if (and content (isa-event content))
	 ;    (kanal-xml-format1 (rkf::frame2english content))
	 ;  (kanal-xml-format1 (rkf::frame2english content)))
	 )
	((equal (first content) ':|triple|)
;	 (format t "~%this shoudl not happen")
	 (kanal-xml-format1 (triple2english content situation))
	 )
	((path-type content)
	 (kanal-xml-format1 (ignore-errors (rkf::generate-text content)))
	 )
	(t
	 (dolist (list-item content)
	   (kanal-xml-item 'list-item list-item situation)
	   ))
	))
  (kanal-xml-item-footer name)
  )



(defun kanal-xml-list-source (error-type source)
  (kanal-xml-item-header 'source)
  (case error-type
    (:unnecessary-link
     (if (listp source)
	 (dolist (item source)
	   (kanal-xml-item-header 'unnecessary-link)
	   (kanal-xml-format1 (ignore-errors (rkf::frame2english (first item))))
	   (kanal-xml-format " before ")
	   (kanal-xml-format1 (ignore-errors (rkf::frame2english (third item))))
	   (kanal-xml-item-footer 'unnecessary-link)))

     )
    (:invalid-expr
     (when (listp source)
					;(kanal-xml-format1 (rkf::frame2english (first source)))
       (kanal-xml-format1 (ignore-errors (rkf::frame2english (second source))))
       )
     )
    ((:subevent-loop :missing-subevent :not-exist :not-parallel :undoable-event )
     (cond ((listp source)
	    (dolist (item source)
	      (kanal-xml-item-header 'list-item)
	      (kanal-xml-format1 (ignore-errors (rkf::frame2english item)))
	      (kanal-xml-item-footer 'list-item)
	      ))
	   ((stringp source)
	    (source))
	   ((atom source)
	    (kanal-xml-format1 (ignore-errors (rkf::frame2english source))))
	   )
     )
    ((:missing-first-subevent)
     (kanal-xml-format1 (ignore-errors (rkf::frame2english (first source))))
     (if (listp (second source))
	 (dolist (item (second source))
	   (kanal-xml-item-header 'list-item)
	   (kanal-xml-format1 (ignore-errors (rkf::frame2english item)))
	   (kanal-xml-item-footer 'list-item)
	   )
       )
     )

    (otherwise       
     (if (listp source)
	 (dolist (item source)
	   (kanal-xml-format1 (ignore-errors (rkf::frame2english item)))
	   )
     (kanal-xml-format1 (ignore-errors (rkf::frame2english source)))))
    )
  (kanal-xml-item-footer 'source)
  )



(defun kanal-xml-list-constraint (error-type source constraint &optional (situation nil) &optional (next-situation nil))
  (kanal-xml-item-header 'constraint)
  (case error-type
    (:precondition
     (if (listp constraint)
	 (dolist (item constraint)
	   (kanal-xml-item-header 'precondition)
	   (kanal-xml-format1 (triple2english item situation))
	   (kanal-xml-item-footer 'precondition)))
     )
    ((:inexplicit-precondition :inexplicit-soft-precondition :soft-precondition)
     (if (listp constraint)
	 (dolist (item constraint)
	   (kanal-xml-item-header 'precondition)
	   (kanal-xml-format1 (triple2english item situation))
	   (kanal-xml-item-footer 'precondition)))
     )
    (:no-effect
     (when (listp constraint) 
       ;(format t "~S & ~S~%" situation next-situation)
       (dolist (item (first constraint)) ;;add-list
	 (kanal-xml-item-header 'add-item)
	 (kanal-xml-format1 (triple2english item next-situation))
	 (kanal-xml-item-footer 'add-item))
       (dolist (item (second constraint)) ;;del-list
	 (kanal-xml-item-header 'del-item)
	 (kanal-xml-format1 (triple2english item situation))
	 (kanal-xml-item-footer 'del-item))
       )
     )
    ((:expected-effect :expected-effect-for-step)
     (if (and (listp constraint) (not (equal (second constraint) '-)))
	 (dolist (item constraint)
	   (if (and (listp item) (equal (second item) '-))
	       (let ()
		(kanal-xml-item-header 'negated-expected-effect)
      		(kanal-xml-format1 (triple2english (car item) situation))
		(kanal-xml-item-footer 'negated-expected-effect)
		)
	     (let ()
	        (kanal-xml-item-header 'expected-effect)
	        (kanal-xml-format1 (triple2english item situation))
	        (kanal-xml-item-footer 'expected-effect)
	      )))
       (let ()
	   (kanal-xml-item-header 'negated-expected-effect)
	   (kanal-xml-format1 (triple2english (car constraint) situation))
	   (kanal-xml-item-footer 'negated-expected-effect)
	)
     ))
    ((:missing-first-subevent :missing-subevent :undoable-event
      :unnecessary-link  :not-parallel)
     (kanal-xml-format1 (ignore-errors (rkf::frame2english constraint)))
     )
    (:cannot-delete
;modified by amit agarwal
	   (kanal-xml-item-header 'cannot-delete)
	   (kanal-xml-format1 (triple2english constraint situation))
	   (kanal-xml-item-footer 'cannot-delete)
     )
    (:not-exist
     (kanal-xml-format1 (ignore-errors (rkf::path2english constraint)))
     )
    ((:loop :max-loops :temporal-loop)
      (when (not (null constraint))
	(dolist (loop constraint)
	  (kanal-xml-item 'loop loop)
	  )
	))
    ((:unreached-events :missing-link)
     (when (and (not (null constraint)) (listp constraint))
       (dolist (event constraint)
	 (kanal-xml-item 'event event)
	 )
       )
     )
    (:invalid-expr
     (if (listp constraint)
	 (kanal-xml-format1 (triple2english (first (last constraint)) situation))
     )
    ))
  (kanal-xml-item-footer 'constraint)
  )

(defun show-combat-power-timeline (fulltimeline)
  (let ((timeline (car fulltimeline))
        (timelinedetails (second fulltimeline)))
    (dolist (item timeline)
        (kanal-xml-item-header 'item)
        (kanal-xml-item 'time (first item))
        (kanal-xml-item 'value (second item))
        (kanal-xml-item 'description (assoc (first item) timelinedetails))
        (kanal-xml-item-footer 'item)
    )
  ))

(defun show-unit-timeline (timeline)
  (dolist (item timeline)
      (kanal-xml-item-header 'unit)
      (kanal-xml-item 'id (first item))
      (kanal-xml-item 'okflag (second item))
      (kanal-xml-item 'relative_combat_power (third item))
      (kanal-xml-item-header 'time)
      (kanal-xml-item 'start (first (fourth item)))
      (kanal-xml-item 'end (second (fourth item)))
      (kanal-xml-item-footer 'time)
      (kanal-xml-item 'description (fifth item))
      (kanal-xml-item-footer 'unit)
  ))

(defun kanal-xml-list-content (info-type content &optional (situation nil))
  (kanal-xml-item-header 'content)
  (case info-type
    (:simulated-paths
     (kanal-xml-item 'path content)
     )
    (:event-info-before-execution
     (dolist (item content)
       (kanal-xml-item-header 'info-item)
       (kanal-xml-item 'name (car item) situation)
       (kanal-xml-item 'detail (cdr item) situation)
       (kanal-xml-item-footer 'info-item))
     )
    (:concept-definition-info-before-execution
     )
    (:force-ratio-explanation
       (kanal-xml-item 'text content)
    )
    (:combat-power-timeline
       (show-combat-power-timeline content)
    )
    (:unit-timeline
       (show-unit-timeline content)
    )
    (:time-varying-properties-info
     (dolist (item content)
       (kanal-xml-item-header 'agent-object)
       (kanal-xml-item 'name (car item))
       (kanal-xml-item-header 'old-properties)       
       (dolist (property (caadr item))
	 (kanal-xml-item-header 'property)
	 (kanal-xml-item 'property-name (car property))
	 (kanal-xml-item 'property-value (cadr property))
	 (if (third property)
	     (kanal-xml-item 'coords (format nil "~S" (third property))))
	 (kanal-xml-item-footer 'property)
	 )
       (kanal-xml-item-footer 'old-properties)

       (kanal-xml-item-header 'new-properties)       
       (dolist (property (cadadr item))
	 (kanal-xml-item-header 'property)
	 (kanal-xml-item 'property-name (car property))
	 (kanal-xml-item 'property-value (cadr property))
	 (if (third property)
	     (kanal-xml-item 'coords (format nil "~S" (third property))))
	 (kanal-xml-item-footer 'property)
	 )
       (kanal-xml-item-footer 'new-properties)

       (kanal-xml-item-footer 'agent-object)
       )
     )
    (:event-start-times
     (dolist (start-time (car content))
       (kanal-xml-item-header 'start-time)
       (kanal-xml-item 'event (car start-time))
       (kanal-xml-item 'operator (cadr start-time))
       (kanal-xml-item 'value (caddr start-time))
       (kanal-xml-item 'duration (cadddr start-time))
       (kanal-xml-item-footer 'start-time)
       )
     )

    ; added by Amit Agarwal (5/30/2002)
    (:subevents
     (dolist (content-item content)
       (when content-item
	 (kanal-xml-item-header 'list-item)
	 (kanal-xml-item 'event (car content-item)) 
	 (kanal-xml-item-header 'subevents)
	 (dolist (subevent (cadr content-item))
	   (kanal-xml-item 'subevent subevent)
	   )
	 (kanal-xml-item-footer 'subevents)
	 (kanal-xml-item-footer 'list-item)
	 )
       )
     )

    (:causal-links
     (dolist (causal-link content)
       (kanal-xml-item-header 'link)
       (kanal-xml-item 'event (first causal-link))
       (kanal-xml-item 'event (second causal-link))
       (kanal-xml-item 'conditions (third causal-link))
       (kanal-xml-item-footer 'link))
     )
    )
  
   (kanal-xml-item-footer 'content)
  )



(defun info-item? (item)
  (let ((id-in-string (format nil "~A" (get-field 'id item))))
    (if (eq (aref id-in-string 0) #\i) ;; starts with letter i
	't
      nil)))



(defun kanal-xml-output-header ()
  (kanal-xml-format "~&<KANAL-OUTPUT>~%"))


(defun kanal-xml-output-footer ()
  (kanal-xml-format "~&</KANAL-OUTPUT>~%"))


(defun kanal-xml-error-item-header ()
  (kanal-xml-format "~&<ERROR>~%"))


(defun kanal-xml-error-item-footer ()
  (kanal-xml-format "~&</ERROR>~%"))


(defun kanal-xml-info-item-header ()
  (kanal-xml-format "~&<INFO>~%"))


(defun kanal-xml-info-item-footer ()
  (kanal-xml-format "~&</INFO>~%"))


(defun kanal-xml-user-input-header ()
  (kanal-xml-format "~&<USER-INPUT>~%"))


(defun kanal-xml-user-input-footer ()
  (kanal-xml-format "~&</USER-INPUT>~%"))

(defun kanal-xml-user-input-item-header (type)
  (kanal-xml-format (format nil "~&<USER-INPUT-ITEM TYPE=\"~a\">~%" type)))


(defun kanal-xml-user-input-item-footer ()
  (kanal-xml-format "~&</USER-INPUT-ITEM>~%"))


(defun kanal-xml-item-header (name)
  (kanal-xml-format (format nil "~&<~a>" name)))


(defun kanal-xml-item-footer (name)
  (kanal-xml-format (format nil "~&</~a>~%" name)))


(defun kanal-xml-format1 (expr)
  (kanal-xml-format (format nil "~a" expr)))


(defun test-kanal-xml ()
  (kanal-result-to-xml *current-results* *terminal-io*))


(defun flatten1 (frame)
   (if (listp frame)
      (mapcar #'(lambda (el)
              (if (listp el)
	          (car (evaluate-expr el))
		  el)) frame)
      frame
      ))



(defun removethe1 (frame)
    (if (listp frame)
    (if (string-equal (first frame) 'the1)
        (third frame)
	frame)
    ))


;; TODO : change to using ONLY 
;;  (rkf::axiom2english (cdr content) :situation situation)
(defun triple2english (content &optional (situation nil))
  ;(format t "triple :: ~S~%" content)
  (cond
   ((inequality-eng-role (third content))
      (let ((value1 (ignore-errors (rkf::path2english (removethe1 (second content)))))
	    (op (third content))
            (value2 (car (evaluate-expr (fourth content) situation))))
	    (format nil "~A ~A ~A" value1 op value2)))
   ((inequality-role (third content))
      (let ((value1 (car (evaluate-expr (second content) situation)))
	    (op (third content))
            (value2 (car (evaluate-expr (fourth content) situation))))
	    (format nil "The available-force-ratio (~A) ~A The required-force-ratio (~A)" 
	     (round-real value1) op (round-real value2))
	    ))
   ((property-value-p (car (evaluate-expr (fourth content))))
      (let ((indiv (second content))
            (role (third content))
            (value (fourth content)) (value-number nil))
            (if situation
              (setq value-number (car (km `(#$in-situation ,situation
	                               (#$the1 #$of (#$the #$value #$of ,value))))))
              (setq value-number (car (km `(#$the1 #$of (#$the #$value #$of ,value))))))
              ;(format t "---------- Calling RKF::axiom2english  for ~S--------------~%" 
	       ;         (list indiv role value-number))
	      (setq result (ignore-errors (rkf::axiom2english (list indiv role value-number) :situation situation)))
              ;(format t "---------- Back from RKF::axiom2english --------------~%")
	      result
	    ))
    (t 
      ;(format t "---------- Calling RKF::axiom2english  for ~S--------------~%" content)
      (setq result (ignore-errors (rkf::axiom2english (cdr content) :situation situation)))
      ;(format t "---------- Back from RKF::axiom2english --------------~%")
      result)
    ))



(defun triple2english_var (content &optional (situation nil))
  (let ((retval nil))
  (cond
   ((inequality-role (third content))
      (let ((one (flatten1 (second content)))
	    (two (flatten1 (third content)))
	    (three (flatten1 (fourth content)))
	    (onedisp nil)(threedisp nil))
	(cond ((inequality-role two)
	       (if (not (typep one 'number))
	         (setq onedisp (ignore-errors (rkf::path2english (removethe1 one))))
		 (setq onedisp one))
	       (if (not (typep three 'number))
		 (setq threedisp (ignore-errors (rkf::path2english (removethe1 three))))
		 (setq threedisp three))

	       (setq one (evaluate-expr one situation))
	       (if (subconcept? (km `(#$the #$instance-of #$of ,one)) '#$Property-Value)
	           (setq one (cadar (evaluate-expr `(#$the #$value #$of ,one) situation))))

	       (setq three (evaluate-expr three situation))
	       (if (subconcept? (km `(#$the #$instance-of #$of ,three)) '#$Property-Value)
	           (setq three (cadar (evaluate-expr `(#$the #$value #$of ,three) situation))))

	       (setq retval (format nil "~A (~S) ~S ~A (~S)" 
		     onedisp
		     one
		     two 
		     threedisp
		     three
		     ))
               ;(format t "returning ~S~%" retval)
	       )
	      (t 
	       (setq retval (ignore-errors (rkf::axiom2english (list one two three))))))
	))
   (t
    (setq retval (ignore-errors (rkf::axiom2english (cdr content))))
    )
  )
  retval
  )
)



;;; ==========================================================
;;; get fixes for a error
;;; ==========================================================

(defun kanal-fixes-to-xml (item-id &optional stream)
  (if stream (setq *kanal-xml-stream* stream))
  (kanal-xml-item-header 'fixes)
  (rkf::with-xml-dictionary (*kanal-xml-stream*)
  (let ((fixes (get-proposed-fixes item-id)))
    (dolist (fix fixes)
      (let ((type (get-field 'type fix))
	    (content (get-field 'fix fix))
	    (source (get-field 'source fix))
	    )
	(kanal-xml-item-header 'fix-item)
	(kanal-xml-item 'type type)
	(case type
	  (:edit-background-k
	   (kanal-xml-item 'content content)
	   (kanal-xml-item 'source source)
	   )
	  (:general
	   (kanal-xml-item 'content content))
	  (otherwise
	   (kanal-xml-item 'content content))
	  ))
          (kanal-xml-item-footer 'fix-item)
	  )
    ))
  (kanal-xml-item-footer 'fixes) 
  )



(defun test-fix-xml ()
  (let ((test-item nil))
    (dolist (item *current-results*)
      (if (and (not (info-item? item))
	       (null (get-field  'success item)))
	  (setq test-item item)))
    (cond ((null test-item)
	   'no-error)
	  (t 
	   (kanal-fixes-to-xml (get-field 'id test-item))
	   (get-output-stream-string *kanal-xml-stream*)
	   ))
    )
  )



(defun get-detailed-description (expr)
  (when
      (and (listp expr) (equal (nth 2 expr) '#$|of|) (atom (nth 3 expr)))
      (get-role-description (nth 3 expr) (nth 1 expr))
   )
  )



(defun show-triple-value (triple)
    (let ((object (get-object triple)) 
   (role (get-role triple))
   (val (get-val triple))
   )
    (when (or (listp object) (listp val) (lisp role))
            (list 
  (if (atom object) object (evaluate-expr object))
  (if (atom role) role (evaluate-expr role))
  (if (atom val) val (evaluate-expr val))))
    ))



;;; ==========================================================
;;; get subevents, units, places for the coa expected effects
;;; interface
;;; ==========================================================

(defun kanal-effects-to-xml (root-individual &optional stream)
  ;; Set some variables to speed up kanal
  (let ((cl-user::*recursive-classification* nil)
        (cl-user::*indirect-classification* nil)
        (cl-user::*backtrack-after-testing-unification* nil))

  (if stream (setq *kanal-xml-stream* stream))
  (format stream "~%")
  (rkf::with-xml-dictionary (*kanal-xml-stream*)
    (kanal-xml-item-header 'expected-effects-data)
    (let ((effect-data (get-expected-effects-data root-individual)))
     (dolist (data effect-data)
       (let ((type (car data))
	    (content (cadr data)) 
	    (english nil))
         (case type
	    (:effects
               (kanal-xml-item-header 'data)
	       (kanal-xml-item 'type type)
               (dolist (steffect content)
                  (let ((step (first steffect))
                        (effect (second steffect)))
                    (kanal-xml-item-header 'effect)
                    (kanal-xml-item 'step step)
                    ;; an effect is of type - (:triple _object110 _role111 _object112)
                    ;; TODO :: really bad hack here for inequality-roles
                    (cond ((inequality-eng-role (third effect))
                           (setq english (format nil "~A ~A ~A" 
                                           (rkf::path2english (removethe1 (second effect))) 
					            (third effect) (fourth effect))))
                          (t
                           (setq english (rkf::axiom2english (cdr effect)))))
                    (kanal-xml-item 'effectenglish english)
                    (kanal-xml-item 'effectkm (format nil "~S" (list step effect)))
                    (kanal-xml-item-footer 'effect)))
               (kanal-xml-item-footer 'data)
            )
	    ((:units :places :subevents)
               (kanal-xml-item-header 'data)
	       (kanal-xml-item 'type type)
	       (kanal-xml-item 'content content)
               (kanal-xml-item-footer 'data)
	    )
	 )
       ))
    )
   (format t "finished generating EE xml~%")
   (kanal-xml-item-footer 'expected-effects-data))
   (format stream "~%")
   ))
