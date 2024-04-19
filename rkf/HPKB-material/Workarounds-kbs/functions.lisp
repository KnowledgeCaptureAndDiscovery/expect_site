;;; Support functions for the planner.
(in-package "USER")

;;; This one allows us to change the bridge types tried by changing the
;;; variable *use-method*. Setting it to "bridge" effectively turns
;;; it off (except it ignores civilian-bridge and still disallows ford).
(defvar *use-method* 'avlb-bridge
  "Can be bound to a bridge type or \"ford\". The planner will attempt
to use only this type of bridge. If there are no bridges of this type it
is ignored - this is probably not the right behaviour.")

(defvar *use-storeys* nil
  "If set to 1 or 2, will force single or double storey MGB's respectively.")

(defvar *use-ford-site* nil
  "If set to the name of a geographical-gap, forces the fording operators
to use that gap. If set to nil there is no control.")

(defun preferred-method-is-ford ()
  (eq *use-method* 'ford))

(defun preferred-bridge-type (var)
  (unless (member *use-method* '(ford raft road-segment))
    (type-of-object-gen var *use-method*)))

(defun preferred-raft-type (var)
  (if (eq *use-method* 'raft)
      (type-of-object-gen var *use-raft*)))

;;; These should use the type hierarchy directly, so they won't need to
;;; be altered if we add new bridge types.
(defun preferred-bridge-is-floating ()
  (member *use-method*
	'(ribbon-bridge m4t6)))

(defun preferred-bridge-is-fixed ()
  (member *use-method*
	'(avlb-bridge tmm-bridge bailey-bridge mgb m4t6-fixed-bridge
		    civilian-bridge)))

(defun no-instances-of-preferred-bridge ()
  (unless (member *use-method* '(ford raft road-segment))
    (null (preferred-bridge-type '<b>))))

(defun preferred-ford-site (var)
  (if *use-ford-site*
      (if (p4::strong-is-var-p var)
	`((( ,var . ,(p4::object-name-to-object var *current-problem-space*))))
        (eq (p4::prodigy-object-name var) *use-ford-site*))
    nil))

;;; gen-storeys-mgb can be used to force 1 or 2 storeys via the
;;; *use-storeys* variable. If this is nil, it will try both.
(defun gen-storeys-mgb (var)
  (cond ((null *use-storeys*)
         (list 1 2))
        ((numberp *use-storeys*)
         (list *use-storeys*))))

(defun oname (object)
  (p4::prodigy-object-name object))

(defun varp (symbol)
  (and (symbolp symbol)
       (char= (elt (symbol-name symbol) 0) #\<)))

;;; This function fails if given a variable. The variable that uses this
;;; is then forced to be bound before this function is called, probably
;;; from the goal.
(defun bound-from-goal (value)
  (not (varp value)))

;;; This version of gfp doesn't have nested brackets, needed for the
;;; standard release version of Prodigy.
#| (but I've now changed the version of prodigy)
(defun gfp (predicate-name &rest args)
  (gen-from-pred
   (cons predicate-name
         (mapcar #'(lambda (arg)
		 (if (p4::prodigy-object-p arg)
		     (p4::prodigy-object-name arg)
		   arg))
	       args))))
|#

(defun either-approach (gap approach-var)
  (if (p4::strong-is-var-p approach-var)
      (append (gen-from-pred `(left-approach ,(oname gap) <x>))
	    (gen-from-pred `(right-approach ,(oname gap) <x>))
	    (gen-from-pred `(approach-of ,(oname gap) <x>)))
    (if (member approach-var
	      (mapcan #'(lambda (slot)
		        (mapcar #'cdar (known `(,slot ,(oname gap) <x>))))
		    '(left-approach right-approach approach-of)))
        t)))

;;; None of these arithmetic checks are very flexible generators.
(defun more-than-two-thirds (small big)
  (>= (* 3 small) (* 2 big)))

(defun gen-min (n1 n2 var)
  (list (min n1 n2)))

(defun gen-from-difference (x y z)
  (if (p4::strong-is-var-p z)
      (list (- x y))
    (= z (- x y))))

(defun gen-from-sum (x y z)
  (if (p4::strong-is-var-p z)
      (list (+ x y))
    (= z (+ x y))))

(defun gen-zero-if-needed (var)
  (if (p4::strong-is-var-p var)
      (list 0)
    t))

(defun gen-desired-length (bridge gap-width gen-var)
  (cond ((eq (p4::type-name (p4::prodigy-object-type bridge))
	   'mgb)
         (list (+ gap-width 2)))
        ((eq (p4::type-name (p4::prodigy-object-type bridge))
	   'bailey-bridge)
         (list (+ gap-width 4)))	; 12 feet
        (t (list gap-width))))

;;; Check the width is less than num if it's either an m4t6,
;;; otherwise succeed
(defun m4t6-less-width (width bridge max-width)
  (if (member (p4::type-name (p4::prodigy-object-type bridge))
	    '( m4t6-fixed-bridge))	; used to include avlb
      (< width max-width)
    t))

;;; For an avlb or tmm, check that either the width is less than 10 +
;;; max-width, or the river width is less than the max width (then we
;;; can cut down to some point half way).

(defun avlb-or-tmm-ok-to-bridge (gap width bridge)
  (if (member (p4::type-name (p4::prodigy-object-type bridge))
	    '(avlb-bridge tmm-bridge))
      (let* ((max-length (cdaar (known `(max-length ,(oname bridge) <x>))))
	   (max-width (if max-length (+ 9 max-length))))
        (or (< width max-width)
	  (let* ((river (cdaar (known `(river-of ,(oname gap) <r>))))
	         (river-width (cdaar (known `(width-of-object
				        ,(oname river) <w>)))))
	    (and river-width
	         (< river-width max-length)))))
    t))

#|
(defun gen-traffic-class-m4t6 (gap current var)
  (list (some #'(lambda (triple)
	        (if (and (>= current (first triple))
		       (<= current (second triple)))
		  (third triple)))
	    '((0 1.2 75)
	      (1.2 2 70)
	      (2 2.5 60)
	      (2.5 2.7 45)
	      (2.7 3 30)
	      (3 99999 0)))))
|#

(defun gen-traffic-class-m4t6 (gap current var)
  (list (some #'(lambda (triple)
	        (if (and (>= current (first triple))
		       (<= current (second triple)))
		  (third triple)))
	    ;; Table C-12 FM90-13 for reinforced, tracked vehicles
	    '((0    2   75)
	      (2   2.5   70)
	      (2.5  3.5  30)
	      (3.5   999999  0)))))

(defun gen-traffic-class-ribbon (bridge current var)
  (list (some #'(lambda (triple)
	        (if (and (>= current (first triple))
		       (<= current (second triple)))
		  (third triple)))
            '((0    0.9   75)
              (0.9  1.2   75)
              (1.2  1.5   70)
              (1.5  1.75  70)
              (1.75  2    70)
              (2     2.5  60)
              (2.5   2.7  45)
              (2.7    3   30)
              (3   999999  0)))))

;;; Given a fixed bridge and a required traffic class, generate a
;;; maximum length

;;; NOTE: jim: i need to know the bridge type in this function
;;;        & if it is mgb i need to know how many stories :(
(defun gen-max-bridge-length (bridge requtrafficclass var)
  (let ((result
         (cond ((eq (p4::type-name (p4::prodigy-object-type bridge))
		'avlb-bridge)
	      17)
	     ((eq (p4::type-name (p4::prodigy-object-type bridge))
		'tmm-bridge)
	      28)
	     ((eq (p4::type-name (p4::prodigy-object-type bridge))
		'm4t6-fixed-bridge)
	      (if (< requtrafficclass 70)
		9.1
	        0))
	     ((eq (p4::type-name (p4::prodigy-object-type bridge)) 'mgb)
	      ;; We don't know the number of stories at this point, so let's
	      ;; assume 2 to get the maximum bridge length. Later on we
	      ;; compute the bays after choosing the number of stories, so
	      ;; that function gets used to reject 1-storey if it won't work.
	      (if nil;;(= 1 stories)
		(some #'(lambda (triple)
			(if (and (>= requtrafficclass (first triple))
			         (<= requtrafficclass (second triple)))
			    (third triple)))
		      '((0   40    11.6)
		        (40  70     9.8)
		        (70  999999   nil)))
	        ;; now the double story
	        (some #'(lambda (triple)
		        (if (and (>= requtrafficclass (first triple))
			       (<= requtrafficclass (second triple)))
			  (third triple)))
		    '((0   40    38.8)
		      (40  50    35.1)
		      (50  70    30)
		      ;; NOTE: table C-17 FM90-13 says 31.4 instead of
		      ;; 30, but we have an assumption that for tanks
		      ;; (70T) gap must be < 30m
		      (70  999999   nil)))))
	     ((eq (p4::type-name (p4::prodigy-object-type bridge)) 'bailey-bridge)
	      #|(some #'(lambda (triple)
		      (if (and (>= requtrafficclass (first triple))
			     (<= requtrafficclass (second triple)))
			(third triple)))
		  '((0   45    27.4)   ; DS
		    (45  55    24.3)   ; DS
		    (55  60    21.3)   ; DS
		    (60   65   18.2)   ; DS
		    (65   70   15.2)   ; DS
		    (70   80   24.3)   ; TS
		    (80   90   33.5)   ; TD
		    (90  999999   nil)))|#
	      60.96		; !
	      )
	     (t nil))))
    (if result (list result))))


;;; At the moment assumes var is a variable. 
(defun gen-max-floating-bridge-length (bridge var)
  (cond ((eq (p4::type-name (p4::prodigy-object-type bridge)) 'ribbon-bridge)
         (p4::internal-gfp '<length> 'max-length bridge '<length>))
        ((eq (p4::type-name (p4::prodigy-object-type bridge)) 'm4t6)
         (let ((num-companies (compute-number-of-m4t6-companies)))
	 (list 
	  (cond ((= num-companies 0) 0)
	        ((= num-companies 1) 76)
	        ((= num-companies 2) 152)
	        (t 366)))))))

;;; Assume one-one relationship between m4t6's and companies.
(defun compute-number-of-m4t6-companies ()
  (length (type-of-object-gen '<x> 'm4t6)))


;;; note: Jim: this is called compute-bays in the operator, pls change that
;;; also: if it returns zero, then it is not feasible <======
;;;

(defun compute-mgb-bays (stories length requtrclass var)
  (let ((result (some #'(lambda (triple)
		      (if (and (>= length (first triple))
			     (<= length (second triple)))
			(third triple)))
		  (if (= 1 stories)
		      '((0     7.9     4)
		        (7.9   9.8     5)
		        (9.8    11.6   6)
		        (11.6  999999  nil)) ; was 0
		    ;; now the double story
		    '((0      11.6   nil) ; was 0
		      ;;   NOTE: table C-15 FM90-13 says 11.3, but
		      ;;   single story would be preferrable because
		      ;;   it takes less time to assemble
		      (11.6   13.1   2)
		      (13.1  14.9   3)
		      (14.9   16.8   4)
		      (16.8  18.6   5)
		      (18.6   20.4   6)
		      (20.4   22.3   7)
		      (22.3   24   8)
		      (24   26.9   9)
		      (26.9   27.7   10)
		      (27.7   29.6   11)
		      (29.6   30   12)
		      ;; NOTE: table C-17 FM90-13 says 31.4 instead
		      ;; of 30, but we have an assumption that for
		      ;; tanks (70T) gap must be < 30m
		      (30   33.2   13)
		      (33.2   35.1   14)
		      (35.1   36.9   15)
		      (36.9   38.8   16)
		      (38.8   999999  nil)))))) ; was 0
    (if result (list result))))

;;; NOTE: jim: I think we don't pass the variable in the operator
;;; also: if it returns zero, then it is not feasible <======
#|(defun compute-bailey-type (length requtrafficclass var)
  (let ((result (some #'(lambda (triple)
		      (if (and (>= requtrafficclass (first triple))
			     (<= requtrafficclass (second triple)))
			(third triple)))
		  '((0   40   2)
		    (40  70   2)
		    (70  80   3)
		    (80  90   5)))))
    (if result (list result))))|#

(defun compute-bailey-type (length requtrafficclass var)
  (let ((result
         (cond ((and (>= length 0)
		 (<= length 15.24)) ; 50)) feet
	      (cond ((and (>= requtrafficclass 0)
		        (<= requtrafficclass 70))
		   2)
		  ((and (>= requtrafficclass 70)
		        (<= requtrafficclass 9999))
		   nil)))
	     ((and (>= length 15.24)	; 50)
		 (<= length 18.2))	; 60))
	      (cond ((and (>= requtrafficclass 0)
		        (<= requtrafficclass 65))
		   2)
		  ((and (>= requtrafficclass 65)
		        (<= requtrafficclass 9999))
		   nil)))
	     ((and (>= length 18.2)	; 60)
		 (<= length 21.3))  ; 70))
	      (cond ((and (>= requtrafficclass 0)
		        (<= requtrafficclass 60))
		   2)
		  ((and (>= requtrafficclass 60)
		        (<= requtrafficclass 99999))
		   nil)))
	     ((and (>= length 21.3)	;  70)
		 (<= length 24.3))	; 80))
	      (cond ((and (>= requtrafficclass 0)
		        (<= requtrafficclass 55))
		   2)
		  ((and (>= requtrafficclass 55)
		        (<= requtrafficclass 80))
		   3)
		  ((and (>= requtrafficclass 80)
		        (<= requtrafficclass 99999))
		   nil)))
	     ((and (>= length 24.3)	; 80)
		 (<= length 27.4))	; 90))
	      (cond ((and (>= requtrafficclass 0)
		        (<= requtrafficclass 45))
		   2)
		  ((and (>= requtrafficclass 45)
		        (<= requtrafficclass 65))
		   3)
		  ((and (>= requtrafficclass 65)
		        (<= requtrafficclass 99999))
		   nil)))
	     ((and (>= length 27.4)	; 90)
		 (<= length 30.48)) ; 100))
	      (cond ((and (>= requtrafficclass 0)
		        (<= requtrafficclass 30))
		   2)
		  ((and (>= requtrafficclass 30)
		        (<= requtrafficclass 55))
		   3)
		  ((and (>= requtrafficclass 55)
		        (<= requtrafficclass 80))
		   4)
		  ((and (>= requtrafficclass 80)
		        (<= requtrafficclass 99999))
		   nil)))
	     ((and (>= length 30.48)	; 100)
		 (<= length 33.5))	; 110))
	      (cond ((and (>= requtrafficclass 0)
		        (<= requtrafficclass 40))
		   3)
		  ((and (>= requtrafficclass 40)
		        (<= requtrafficclass 70))
		   4)
		  ((and (>= requtrafficclass 70)
		        (<= requtrafficclass 90))
		   5)
		  ((and (>= requtrafficclass 90)
		        (<= requtrafficclass 99999))
		   nil)))
	     ((and (>= length 33.5)	; 110)
		 (<= length 36.4))	; 120))
	      (cond ((and (>= requtrafficclass 0)
		        (<= requtrafficclass 55))
		   4)
		  ((and (>= requtrafficclass 55)
		        (<= requtrafficclass 80))
		   5)
		  ((and (>= requtrafficclass 80)
		        (<= requtrafficclass 99999))
		   nil)))
	     ((and (>= length 36.4)	; 120)
		 (<= length 39.58))	; 130))
	      (cond ((and (>= requtrafficclass 0)
		        (<= requtrafficclass 45))
		   4)
		  ((and (>= requtrafficclass 45)
		        (<= requtrafficclass 60))
		   5)
		  ((and (>= requtrafficclass 60)
		        (<= requtrafficclass 80))
		   6)
		  ((and (>= requtrafficclass 80)
		        (<= requtrafficclass 99999))
		   nil)))
	     ((and (>= length 39.58)  ; 130)
		 (<= length 42.6))  ; 140))
	      (cond ((and (>= requtrafficclass 0)
		        (<= requtrafficclass 55))
		   5)
		  ((and (>= requtrafficclass 55)
		        (<= requtrafficclass 70))
		   6)
		  ((and (>= requtrafficclass 70)
		        (<= requtrafficclass 99999))
		   nil)))
	     ((and (>= length 42.6)	; 140)
		 (<= length 45.72))	; 150))
	      (cond ((and (>= requtrafficclass 0)
		        (<= requtrafficclass 45))
		   5)
		  ((and (>= requtrafficclass 45)
		        (<= requtrafficclass 60))
		   6)
		  ((and (>= requtrafficclass 60)
		        (<= requtrafficclass 99999))
		   nil)))
	     ((and (>= length 45.72)	; 150)
		 (<= length 48.6))  ; 160))
	      (cond ((and (>= requtrafficclass 0)
		        (<= requtrafficclass 55))
		   6)
		  ((and (>= requtrafficclass 55)
		        (<= requtrafficclass 75))
		   7)
		  ((and (>= requtrafficclass 75)
		        (<= requtrafficclass 99999))
		   nil)))
	     ((and (>= length 48.6)	; 160)
		 (<= length 51.78)) ; 170))
	      (cond ((and (>= requtrafficclass 0)
		        (<= requtrafficclass 50))
		   6)
		  ((and (>= requtrafficclass 50)
		        (<= requtrafficclass 70))
		   7)
		  ((and (>= requtrafficclass 70)
		        (<= requtrafficclass 99999))
		   nil)))
	     ((and (>= length 51.78)	; 170)
		 (<= length 54.78)) ; 180))
	      (cond ((and (>= requtrafficclass 0)
		        (<= requtrafficclass 45))
		   6)
		  ((and (>= requtrafficclass 45)
		        (<= requtrafficclass 60))
		   7)
		  ((and (>= requtrafficclass 60)
		        (<= requtrafficclass 99999))
		   nil)))
	     ((and (>= length 54.78)  ; 180)
		 (<= length 57.88))	; 190))
	      (cond ((and (>= requtrafficclass 0)
		        (<= requtrafficclass 55))
		   7)
		  ((and (>= requtrafficclass 55)
		        (<= requtrafficclass 99999))
		   nil)))
	     ((and (>= length 57.88)  ; 190)
		 (<= length 60.96)) ; 200))
	      (cond ((and (>= requtrafficclass 0)
		        (<= requtrafficclass 40))
		   7)
		  ((and (>= requtrafficclass 40)
		        (<= requtrafficclass 99999))
		   nil)))
	     )))
    (if result (list result))))

;;; 0 means no solution.
#|
;;; This version replaced with one below, changing the assumptions on the
;;; m4t6 raft
(defun gen-raft-bays (raft river-current load-class num-bay-var)
  (list 
   (cond ((eq (p4::type-name (p4::prodigy-object-type raft))
	    'ribbon-bridge)
	;; FM 5-34 table 7-7, assuming longitudinal rafting.
	;; (which is the same as C-7 in FM 90-13)
	(cond ((<= river-current 1.5)
	       (cond ((<= load-class 45)
		    3)
		   ((<= load-class 70)
		    4)
		   ((<= load-class 75)
		    5)
		   (t 0)))
	     ((<= river-current 2)
	      (cond ((<= load-class 40)
		   3)
		  ((<= load-class 60)
		   4)
		  ((<= load-class 70)
		   5)
		  (t 0)))
	     ((<= river-current 2.5)
	      (cond ((<= load-class 60)
		   4)
		  ((<= load-class 70)
		   5)
		  (t 0)))
	     ((<= river-current 2.7)
	      (cond ((<= load-class 55)
		   4)
		  ((<= load-class 60)
		   5)
		  ((<= load-class 70)
		   6)
		  (t 0)))
	     ((<= river-current 3)
	      (cond ((<= load-class 45)
		   4)
		  ((<= load-class 60)
		   5)
		  ((<= load-class 70)
		   6)
		  (t 0)))))
         ((eq (p4::type-name (p4::prodigy-object-type raft))
	    'm4t6)
	;; FM 90-13, table C-9m assuming normal crossing type and
	;; wheeled vehicles.
	(cond ((<= river-current 1.5)
	       (cond ((<= load-class 50)
		    4)
		   ((<= load-class 55)
		    5)
		   ((<= load-class 65)
		    6)
		   (t 0)))
	      ((<= river-current 2)
	       (cond ((<= load-class 45)
		    4)
		   ((<= load-class 50)
		    5)
		   ((<= load-class 65)
		    6)
		   (t 0)))
	      ((<= river-current 2.5)
	       (cond ((<= load-class 40)
		    4)
		   ((<= load-class 45)
		    5)
		   ((<= load-class 65)
		    6)
		   (t 0)))
	      ((<= river-current 3.5)
	       (cond ((<= load-class 65)
		    6)
		   (t 0))))))))
|#
(defun gen-raft-bays (raft river-current load-class num-bay-var)
  (list 
   (cond ((eq (p4::type-name (p4::prodigy-object-type raft))
	    'ribbon-bridge)
	;; FM 5-34 table 7-7, assuming longitudinal rafting.
	;; (which is the same as C-7 in FM 90-13)
	(cond ((<= river-current 1.5)
	       (cond ((<= load-class 45)
		    3)
		   ((<= load-class 70)
		    4)
		   ((<= load-class 75)
		    5)
		   (t 0)))
	     ((<= river-current 2)
	      (cond ((<= load-class 40)
		   3)
		  ((<= load-class 60)
		   4)
		  ((<= load-class 70)
		   5)
		  (t 0)))
	     ((<= river-current 2.5)
	      (cond ((<= load-class 60)
		   4)
		  ((<= load-class 70)
		   5)
		  (t 0)))
	     ((<= river-current 2.7)
	      (cond ((<= load-class 55)
		   4)
		  ((<= load-class 60)
		   5)
		  ((<= load-class 70)
		   6)
		  (t 0)))
	     ((<= river-current 3)
	      (cond ((<= load-class 45)
		   4)
		  ((<= load-class 60)
		   5)
		  ((<= load-class 70)
		   6)
		  (t 0)))))
         ((eq (p4::type-name (p4::prodigy-object-type raft))
	    'm4t6)
	;; FM 90-13, table C-9m assuming reinforced crossing type and
	;; tracked vehicles.
	(cond ((<= river-current 1.5)
	       (cond ((<= load-class 55)
		    4)
		   ((<= load-class 65)
		    5)
		   ((<= load-class 70)
		    6)
		   (t 0)))
	      ((<= river-current 2)
	       (cond ((<= load-class 55)
		    4)
		   ((<= load-class 65)
		    5)
		   ((<= load-class 70)
		    6)
		   (t 0)))
	      ((<= river-current 2.5)
	       (cond ((<= load-class 50)
		    4)
		   ((<= load-class 60)
		    5)
		   ((<= load-class 70)
		    6)
		   (t 0)))
	      ((<= river-current 3.5)
	       (cond ((<= load-class 40)
		      4)
		     ((<= load-class 50)
		      5) 
		     ((<= load-class 60)
		      6)
		   (t 0))))))))



;;; Finding nearby stuff.

;;; This is a bindings function.
(defun bank-near-approach (approach bank)
  (let (gap found-bank)
    (cond ((setf gap (cdaar (known `(left-approach <gap> ,(oname approach)))))
	 (setf found-bank
	       (cdaar (known `(left-bank ,(oname gap) <bank>)))))
	((setf gap (cdaar (known `(right-approach <gap> ,(oname approach)))))
	 (setf found-bank
	       (cdaar (known `(right-bank ,(oname gap) <bank>))))))
    (if (varp bank)
        (list found-bank)
      (eq bank found-bank))))

;;; Test that the aproach is near the region, or generate the approach
;;; near the region.
(defun near-approach (region approach)
  (let ((region-type (p4::type-name (p4::prodigy-object-type region))))
    (cond ((eq region-type 'geographical-approach)
	 (if (p4::strong-is-var-p approach)
	     (list region)
	   (eq region approach)))
	((eq region-type 'geographical-bank)
	 (let ((gap nil)
	       (true-approach nil))
	   (cond ((setf gap (cdaar (known `(left-bank <g> ,(oname region)))))
		(setf true-approach
		      (cdaar (known `(left-approach ,(oname gap) <a>)))))
	         ((setf gap (cdaar (known `(right-bank <g> ,(oname region)))))
		(setf true-approach
		      (cdaar (known `(right-approach ,(oname gap) <a>))))))
	   (if (p4::strong-is-var-p approach)
	       (list true-approach)
	     (eq approach true-approach))))
	((eq region-type 'tunnel-opening)
	 ;; Make use of arbitrary information we added for tunnel
	 ;; openings because Eric's input is ambiguous.
	 (let ((true-approach
	        (cdaar (known `(approach-of ,(oname region) <a>)))))
	   (if (p4::strong-is-var-p approach)
	       (list true-approach)
	     (eq approach true-approach))))
	((eq region-type 'body-of-water)
	 (let ((gap (cdaar (known `(river-of <gap> ,(oname region))))))
	   (either-approach gap approach)))
	 )))

;;; Here's the version for a control rule. You can't use this unless the
;;; region is bound.

(defun near-approach-cr (region approach)
  (if (p4::strong-is-var-p approach)
      (let ((res (first (near-approach region approach))))
        `( ( ( ,approach . ,res ) ) ))
    (near-approach region approach)))

;;; Given an approach of a gap, generate the equivalent approach of a
;;; potentially different gap. gap, approach and other-gap should
;;; already be bound.
(defun approaches-on-same-side-of-river (gap approach other-gap other-approach)
  (let ((found-approach
         (cond ((known `(left-approach ,(oname gap) ,(oname approach)))
	      (cdaar (known `(left-approach ,(oname other-gap) <x>))))
	     ((known `(right-approach ,(oname gap) ,(oname approach)))
	      (cdaar (known `(right-approach ,(oname other-gap) <x>)))))))
    (if (varp other-approach)
        (list found-approach)
      (eq other-approach found-approach))))

;;; This tests that there is no obstacle between points a and b, for
;;; move-military-unit
(defun nothing-between (a b)
  (and (null (known `(between <x> ,(oname a) ,(oname b))))
       (null (known `(between <x> ,(oname b) ,(oname a))))))

;;; This tests that the given crater is not between points a and b
;;; (assuming it's specified directly). Everything must be bound.
(defun crater-not-between (crater a b)
  (and (null (known `(between ,(oname crater) ,(oname a) ,(oname b))))
       (null (known `(between ,(oname crater) ,(oname b) ,(oname a))))))

;;; Find out if two craters are adjacent by finding out if, apart from
;;; each other, they have the same craters between themselves and the
;;; reference town.

(defun craters-between (town crater)
  (mapcar #'cdar
	(p4::match-lhs
	 `(and (between <c> ,(oname town) ,(oname crater))
	       (type-of-object <c> crater))
	 t)))

(defun same-craters-between (town c1 c2)
  (let ((craters-between-town-and-c1
         (delete c2 (craters-between town c1)))
        (craters-between-town-and-c2
         (delete c1 (craters-between town c2))))
    ;; check they're the same set.
    (and (= (length craters-between-town-and-c2)
	  (length craters-between-town-and-c1))
         (null (set-difference craters-between-town-and-c1
			 craters-between-town-and-c2)))))

(defun adjacent-crater (c1 c2)
  (let ((town (cdaar (type-of-object-gen '<x> 'city))))
    (same-craters-between town c1 c2)))

;;; both town and crater must be bound.
(defun nearest-crater-to-city (town crater)
  (null (craters-between town crater)))

;;; Find the approach on the same side of a crater as a given location.
(defun approach-on-same-side-of-crater (crater location approach-var)
  (let ((true-approach
         (cond ((eq (p4::type-name (p4::prodigy-object-type location)) 'city)
	      ;; Look for a direct between statement
	      (some #'(lambda (approach)
		      (if (known `(between ,(oname approach)
				       ,(oname location)
				       ,(oname crater)))
			approach))
		  (gen-from-pred `(approach-of ,(oname crater) <a>))))
	     ;; for the approach of another crater.
	     ((eq (p4::type-name (p4::prodigy-object-type location)) 'geographical-approach)
	      (let* ((crater2 (first (gen-from-pred `(approach-of <c> ,location))))
		   (town (cdaar (p4::match-lhs `(and (between ,(oname crater2)
						      <t>
						      ,(oname crater))
					       (type-of-object <t> city))
					 t))))
	        (if (eq crater2 crater)
		  location
		(cdaar (p4::match-lhs `(and (between <a> ,(oname town) ,(oname crater))
				        (type-of-object <a> geographical-approach))
				  t)))))
	     )))
    (if (p4::strong-is-var-p approach-var)
        `( ( ( ,approach-var . ,true-approach )))
      (eq approach-var true-approach))))

	        
	      

;;; location is either a town or an approach (it's where the bridge
;;; currently is). Both must be bound.
(defun same-side-of-river (location approach)
  (or (eq location approach)
      (and (not (eq (p4::type-name (p4::prodigy-object-type location))
		'geographical-approach))
	 (not (known `(between <x> ,(oname location) ,(oname approach)))))))

(defun feature-of (location feature)
  (let ((true-feature (or (cdaar (known `(feature-of ,(oname location) <f>)))
		      location)))
    (if (varp feature)
        (list true-feature)
      (eq feature true-feature))))


(defun not-mined (region)
  (not (known `(mined ,(oname region)))))

;;; Could probably right this directly in the constraints but I can't
;;; think how right now.
(defun dry-or-not-mined (river)
  (or (known `(wetness ,(oname river) dry))
      (not-mined river)))

(defun not-rock (soil)
  (not (eq (oname soil) 'rock)))


(defun need-to-deslope (actual-height max-height actual-slope max-slope)
  (or
  (> actual-height max-height)
  (> actual-slope max-slope)
  )
  )
	         

;;; These are control rule meta-predicates, so they return bindings
;;; lists.

;;; Since we move units to approaches, "nearby" equipment means what is
;;; found on either approach
(defun nearby-equipment (region type var)
  (let (gap road-segment)
    (cond ((eq (p4::type-name (p4::prodigy-object-type region)) 'body-of-water)
	 ;; for a river
	 nil)
	;; for something with a gap (a gap, approach or bank)
	((setf gap (find-gap-for-region region))
	 (if (p4::strong-is-var-p var)
	     (apply #'append
		  (mapcar #'(lambda (slot)
			    (equipment-at-location
			     (first (gen-from-pred `(,slot ,gap <x>)))
			     type
			     var))
			'(left-approach right-approach left-bank
				      right-bank)))
	   (some #'(lambda (slot)
		   (equipment-at-location
		    (first (gen-from-pred `(,slot ,gap <x>)))
		    type
		    var))
	         '(left-approach right-approach left-bank right-bank))))
	;; for a crater, take anything on any approach of any crater
	;; on the road segment.
	((setf road-segment (find-road-segment-for-region region))
	 (if (p4::strong-is-var-p var)
	     (apply #'append
		  (mapcar #'(lambda (crater)
			    (apply #'append
				 (mapcar #'(lambda (approach)
					   (equipment-at-location
					    approach type var))
				         (gen-from-pred
					`(approach-of ,(oname crater) <x>)))))
			(gen-from-pred `(in-region <c> ,(oname road-segment)))))
	   (some #'(lambda (crater)
		   (some #'(lambda (approach)
			   (equipment-at-location approach type var))
		         (gen-from-pred
			`(approach-of ,(oname crater) <x>))))
	         (gen-from-pred `(in-region <c> ,(oname road-segment))))))
		   
	)))

;;; Need this because the control rule matcher doesn't do foralls.
(defun no-nearby-equipment (region type)
  (null (nearby-equipment region type '<var>)))

(defun find-gap-for-region (region-obj)
  (let ((region (oname region-obj)))
    (cond ((eq (p4::type-name (p4::prodigy-object-type region-obj))
	     'geographical-approach)
	 (let ((gap (cdaar (or (known `(left-approach <gap> ,region))
			   (known `(right-approach <gap> ,region))))))
	   (if gap
	       (p4::prodigy-object-name gap))))
	((eq (p4::type-name (p4::prodigy-object-type region-obj))
	     'geographical-bank)
	 ;; assume we'll find a gap
	 (p4::prodigy-object-name
	  (cdaar (or (known `(left-bank <gap> ,region))
		   (known `(right-bank <gap> ,region))))))
	((member (p4::type-name (p4::prodigy-object-type region-obj))
	         '(geographical-gap ford-site))
	 region))))

(defun find-road-segment-for-region (region-obj)
  (cond ((eq (p4::type-name (p4::prodigy-object-type region-obj))
	   'crater)
         (cdaar (known `(in-region ,(oname region-obj) <rs>))))
        ((eq (p4::type-name (p4::prodigy-object-type region-obj))
	   'geographical-approach)
         (find-road-segment-for-region
	(first (gen-from-pred `(approach-of <c> ,region-obj)))))
        ;; need to deal with more types eventually.
        (t nil)))
	    

;;; Find equipment of the required type at that location. Simple enough
;;; to write directly in a control rule, but it's useful to have it in a
;;; subroutine.
(defun equipment-at-location (location type var)
  (p4::match-lhs `(and (object-found-in-location ,var ,(oname location))
		   (type-of-object ,var ,type))
	       t))

;;; Control rules in prodigy can't handle unbound variables.
(defun no-equipment-at-location (location type)
  (not (equipment-at-location location type '<eq-loc-var>)))
    

;;; equipment and units

;;; So far must be fully bound
(defun unit-has-control-of-equipment (unit item)
  (or (and (p4::match-lhs `(and (mission-equipment ,(oname unit) <collection>)
			  (group-members <collection> ,(oname item)))
		      t)
	 ;; don't want to return bindings for variables not mentioned
	 ;; in input.
	 t)
      (some #'(lambda (subordinate-unit)
	      (unit-has-control-of-equipment subordinate-unit item))
	  (mapcar #'cdar
		(known `(subordinate-unit ,(oname unit) <sub>))))))

;;; type is a symbol, from plow-equip-type
(defun unit-has-no-equipment-of-type (unit type)
  (let ((all-objs (mapcar #'cdar (type-of-object-gen '<x> type))))
    (not (some #'(lambda (obj) (unit-has-control-of-equipment unit obj))
	     all-objs))))


;;; Handy retrieval function.
(defun all-about (object)
  (if (symbolp object)
      (setf object (p4::object-name-to-object object *current-problem-space*)))
  (maphash #'(lambda (pred ht)
	     (maphash #'(lambda (args lit)
		        (if (and (p4::literal-state-p lit)
			       (position object (p4::literal-arguments lit)))
			  (print lit)))
		    ht))
	 (p4::problem-space-assertion-hash *current-problem-space*)))

#|
(defun expensive-candidate-goal (goal)
  (test-match-goals goal
		(p4::give-me-all-pending-goals *current-node*)))
|#

(defun walk-up-trace-to-find-bridge (bridge)
  ;; yikes!
  (let ((true-bridge (find-bridge-in-goal-or-op
		  (goal-node-ancestor *current-node*))))
    (if (and true-bridge (p4::strong-is-var-p bridge))
        (list true-bridge)
      (eq bridge true-bridge))))

(defun goal-node-ancestor (node)
  (if (p4::goal-node-p node)
      node
    (goal-node-ancestor (p4::nexus-parent node))))

(defun find-bridge-in-goal-or-op (node)
  (cond ((equal (p4::nexus-name node) 2)
         nil)
        ((p4::goal-node-p node)
         (let ((goal (p4::goal-node-goal node)))
	 (if (and (eq (p4::literal-name goal) 'trafficable)
		(= (length (p4::literal-arguments goal)) 3)
		(or 
		 (p4::object-type-p
		  (elt (p4::literal-arguments goal) 0)
		  (p4::type-name-to-type 'bridge
				     *current-problem-space*))
		 (p4::object-type-p
		  (elt (p4::literal-arguments goal) 0)
		  (p4::type-name-to-type 'civilian-bridge
				     *current-problem-space*))))
	     (elt (p4::literal-arguments goal) 0)
	   (find-bridge-in-goal-or-op
	    (first (p4::goal-node-introducing-operators node))))))
        ((p4::binding-node-p node)
         (let* ((instantiated-op (p4::binding-node-instantiated-op node))
	      (operator (p4::instantiated-op-op instantiated-op)))
	 (if (member (p4::rule-name operator)
		   '(move-across-gap-with-fixed-bridge
		     move-across-gap-with-floating-bridge))
	     (iop-value instantiated-op '<bridge>)
	   (find-bridge-in-goal-or-op
	    (p4::nexus-parent (p4::nexus-parent node))))))))
		     

;;; This version is used in control rules
(defun plan-to-use-bridge (bridge-var)
  (let ((planned-bridge (find-bridge-in-goal-or-op
		     (goal-node-ancestor *current-node*))))
  (if (p4::strong-is-var-p bridge-var)
      (if planned-bridge
	`( ( ( ,bridge-var . ,planned-bridge) ) ))
    (eq bridge-var planned-bridge))))


(defun gen-rubble (end rubble)
  (let ((true-rubble (or (cdaar (known `(in-region <x> ,end)))
		     (p4::object-name-to-object 'no-rubble
					  *current-problem-space*))))
    (eq rubble true-rubble)))

;;; Similarly, there is no river current for a dry river bed, so I need
;;; to generate 0 in that case.

(defun gen-river-current (river gen-var)
  (if (p4::strong-is-var-p gen-var)
      (list (or (cdaar (known `(river-current ,(oname river) <x>)))
	      0))))

;;; These functions reduce the amount of control rules needed to talk about
;;; preferring nearby equipment to plow rubble.
(defun plow-equip-type (gen-var)
  (mapcar #'(lambda (type) `((,gen-var . ,type)))
	'(military-dozer tank-plow m88)))

(defun plow-op-for (type op-var)
  (let ((wanted-op (case type
		 (military-dozer 'dozer-plow-rubble)
		 (tank-plow 'tank-plow-rubble)
		 (m88 'm88-plow-rubble))))
    (if (p4::strong-is-var-p op-var)
        `(((,op-var . ,wanted-op)))
      (eq (p4::rule-name op-var) wanted-op))))

(defun crater-equip-type (gen-var)
  (mapcar #'(lambda (type) `((,gen-var . ,type)))
	'(avlb-bridge tmm-bridge military-dozer tank-plow m88)))

(defun crater-op-for (type op-var)
  nil)

(defun bad-move-for-crater (var)
  (mapcar #'(lambda (op)
	    `((,var . ,(p4::rule-name-to-rule op *current-problem-space*))))
	'(move-asset-across-fixed-bridge
	  move-asset-across-floating-bridge
	  move-asset-across-gap-by-fording-it
	  move-asset-across-ford-different-from-gap
	  move-asset-across-gap
	  move-asset-around-tunnel
	  move-asset-across-raft
	  )))
	  
	  

(defun only-city-with-crater-stuff (var)
  (let ((all-towns (mapcar #'cdar (type-of-object-gen '<c> 'city)))
        (the-town nil))
    (dolist (city all-towns)
      (if (city-has-crater-stuff city)
	(if the-town
	    (return-from only-city-with-crater-stuff nil)
	  (setf the-town city))))
    (if the-town
        (if (p4::strong-is-var-p var)
	  `( ( ( ,var . ,the-town )))
	(eq the-town var)))
    ))

(defun city-has-crater-stuff (city)
  (some #'(lambda (type)
	  (equipment-at-location city type '<x>))
        '(avlb-bridge tmm-bridge m88 tank-plow military-dozer)))



(defun non-magic-move (op)
  (let ((non-magic-ops '(move-asset-across-fixed-bridge
		     move-asset-across-floating-bridge
		     move-asset-across-ford-different-from-gap
		     move-asset-across-gap-by-fording-it)))
    (if (p4::strong-is-var-p op)
        (mapcar #'(lambda (move)
		`(( ,op . ,move)))
	      non-magic-ops)
      (if (member (p4::rule-name op) non-magic-ops)
	t))))


;;; Get (or test) the value of some variable from an instantiated
;;; operator.

(defun inst-val (var instop val)
  (let ((valobj (elt (p4::instantiated-op-values instop)
		 (position var (p4::rule-vars
			      (p4::instantiated-op-op instop))))))
    (if (p4::strong-is-var-p val)
        (list			; list of possible bindings
         (list (cons val		; the one bindings list
		 (if (p4::prodigy-object-p valobj)
		     (oname valobj)
		   valobj))))
      (eq val valobj))))


;;; An instantiated operator matched with (candidate-bindings <b>) is
;;; a list. Sigh. So, this works for that.
(defun elt-val (i list val)
  (if (p4::strong-is-var-p val)
      (list (list (cons val (elt list i))))
    (eq val (elt list i))))

;;; This is an easier and more robust way to get a value out from the
;;; list of values corresponding to an operator than just to know the
;;; index as in elt-val above. Here we give the variable name and the
;;; operator and the function figures out the index. More readable,
;;; and if the index changes we live.

(defun op-val (bindings op-name var-name val-var)
  (let ((op (p4::rule-name-to-rule op-name *current-problem-space*)))
    (elt-val (position var-name (p4::rule-vars op)) bindings val-var)))


;;; And to be handled in matcher-interface, we turn it back to a
;;; bindings list.
(defun list-to-bindings (bindings opname var)
  (let ((op (p4::rule-name-to-rule opname *current-problem-space*)))
    (list (list (cons var
		  (mapcar #'cons (p4::operator-vars op) bindings))))))
