;;; -*- Mode:Lisp; Package:LOOM -*-
;;; 
;;; This ontology is based on the translation of the
;;; job-assignment-generic ontology in the Ontolingua repository into
;;; Loom. The translated file was heavily modified, since it does not
;;; match the normal modelling framework of Loom. Also, it made
;;; reference to some general ontologies in Ontolingua that have a
;;; better translation into the built-in-ontology of Loom.

#|
(cond 
 ((not loom::*expect*)
  (in-package "JFACC"))
 (t (in-package "EXPECT")))
|#
(in-package "EVALUATION")
(use-package '("EXPECT" "PLANET"))
(loom::use-loom "EVALUATION" :dont-create-context-p t)
;;(in-package "EXPECT")

#|
(cond 
 ((not loom::*expect*)
  (when (and (not loom::*load-in-single-context*)
	   (find-context 'TIME-ONTOLOGY))
        (defcontext TIME-ONTOLOGY
	:theory
	(JFACC-ONTOLOGY)
	:creation-policy :classified-instance)
        
        (change-context 'TIME-ONTOLOGY)))
 (t (change-context 'INSPECT2))) 
|#

;;; Concept TIME-RANGE 
(defconcept time-range
  :is (:and domain-concept
	  (the time-range.start-time time-point)
	  (the time-range.duration duration)
	  (the time-range.end-time time-point)
;;	  (relates tp<
;;		 time-range.start-time
;;		 time-range.end-time)
;;            (relates tp+
;;                     time-range.start-time
;;                     time-range.duration
;;                     time-range.end-time) 
	  )
  :roles ((time-range.start-time :type time-point)
	(time-range.duration :type duration)
	(time-range.end-time :type time-point))
  :annotations
  ((documentation "TIME-RANGE denotes a certain period of time. It
consists of a start time, an end time. A start time must proceed an
end time.  Relations between TIME-RANGEs are defined after James
Allen's interval relations.")))


;;; Relation TIME-RANGE.START-TIME 
(defrelation time-range.start-time
  :is-primitive binary-tuple
  :domain time-range
  :range time-point
  :attributes (:single-valued)
  :arity 2
  :annotations
  ((documentation "(TR-START-TIME 'tr) denotes a start time of a time range tr.")))


;;; Relation TIME-RANGE.END-TIME 
(defrelation time-range.end-time
  :is-primitive binary-tuple
  :domain time-range
  :range time-point
  :attributes (:single-valued)
  :arity 2
  :annotations
  ((documentation "(TR-END-TIME 'tr) denotes an end time of a time range tr.")))


;;; Relation TIME-RANGE.DURATION 
(defrelation time-range.duration
  :is-primitive binary-tuple
  :domain time-range
  :range duration
  :attributes (:single-valued)
  :arity 2
  :annotations
  ((documentation "(TR-END-DURATION 'tr) denotes a duration of a time range tr.")))


;;; Relation BEFORE 
(defrelation before
  :is (:satisfies (?tr1 ?tr2)
	        (:and (time-range ?tr1)
		    (time-range ?tr2)
		    (tp< (time-range.end-time ?tr1)
		         (time-range.start-time ?tr2))))
  :domain time-range
  :range time-range
  :arity 2
  :annotations
  ((documentation "a time range ?tr1 preceeds a time range ?tr2.")))


;;; Relation AFTER 
(defrelation after
  :is (:satisfies (?tr1 ?tr2)
	        (:and (time-range ?tr1)
		    (time-range ?tr2)
		    (tp< (time-range.end-time ?tr2)
		         (time-range.start-time ?tr1))))
  :arity 2
  :domain time-range
  :range time-range
  :inverse before
  :annotations
  ((documentation "a time range ?tr1 succeeds a time range ?tr2.")))


;;; Relation MEETS 
(defrelation meets
  :is (:satisfies (?tr1 ?tr2)
	        (:and (time-range ?tr1)
		    (time-range ?tr2)
		    (tp= (time-range.end-time ?tr1)
		         (time-range.start-time ?tr2))))
  :arity 2
  :domain time-range
  :range time-range
  :annotations
  ((documentation "a time range ?tr1 ends at the same time a time
range ?tr2 starts.")))

;;; Relation EQUALS 
(defrelation equals
  :is (:satisfies (?tr1 ?tr2)
	        (:and (time-range ?tr1)
		    (time-range ?tr2)
		    (tp= (time-range.start-time ?tr1)
		         (time-range.start-time ?tr2))
		    (tp= (time-range.end-time ?tr1)
		         (time-range.end-time ?tr2))))
  :arity 2
  :domain time-range
  :range time-range
  :annotations
  ((documentation "a time range ?tr1 is identical to a time range ?tr2."))) 

;;; Relation DURING 
(defrelation during
  :is (:satisfies (?tr1 ?tr2)
	        (:and (time-range ?tr1)
		    (time-range ?tr2)
		    (tp> (time-range.start-time ?tr1)
		         (time-range.start-time ?tr2))
		    (tp< (time-range.end-time ?tr1)
		         (time-range.end-time ?tr2))))
  :arity 2
  :domain time-range
  :range time-range
  :annotations
  ((documentation "a time range ?tr1 is properly included in a time
range ?tr2.")))

;;; Relation OVERLAPS 
(defrelation overlaps
  :is (:satisfies (?tr1 ?tr2)
	        (:and (time-range ?tr1)
		    (time-range ?tr2)
		    (tp< (time-range.start-time ?tr1)
		         (time-range.start-time ?tr2))
		    (tp< (time-range.start-time ?tr2)
		         (time-range.end-time ?tr1))
		    (tp< (time-range.start-time ?tr1)
		         (time-range.end-time ?tr2))))
  :domain time-range
  :range time-range
  :annotations
  ((documentation "a time range ?tr1 and a time range ?tr2
overlap.")))

;;; Relation STARTS 
(defrelation starts
  :is (:satisfies (?tr1 ?tr2)
	        (:and (time-range ?tr1)
		    (time-range ?tr2)
		    (tp= (time-range.start-time ?tr1)
		         (time-range.start-time ?tr2))
		    (tp< (time-range.end-time ?tr1)
		         (time-range.end-time ?tr2))))
  :arity 2
  :domain time-range
  :range time-range
  :annotations
  ((documentation "a time range ?tr1 and a time range ?tr2 starts at
the same time and a duration of ?tr1 is shorter than that of ?tr2.")))

;;; Relation FINISHES 
(defrelation finishes
  :is (:satisfies (?tr1 ?tr2)
	        (:and (time-range ?tr1)
		    (time-range ?tr2)
		    (tp> (time-range.start-time ?tr1)
		         (time-range.start-time ?tr2))
		    (tp= (time-range.end-time ?tr1)
		         (time-range.end-time ?tr2))))
  :arity 2
  :domain time-range
  :range time-range
  :annotations
  ((documentation "a time range ?tr1 and a time range ?tr2 ends at the
same time and a duration of ?tr1 is shorter than that of ?tr2.")))

;;; Relation BEFORE= 
(defrelation before=
  :is (:satisfies (?tr1 ?tr2)
	        (:and (time-range ?tr1)
		    (time-range ?tr2)
		    (:or (before ?tr1 ?tr2)
		         (meets ?tr1 ?tr2))))
  :arity 2
  :domain time-range
  :range time-range)


;;; Relation AFTER= 
(defrelation after=
  :arity 2
  :domain time-range
  :range time-range)


;;; Relation DURING= 
(defrelation during=
  :arity 2
  :domain time-range
  :range time-range)


;;; Relation OVERLAPS= 
(defrelation overlaps=
  :arity 2
  :domain time-range
  :range time-range)


;;; Relation START= 
(defrelation start=
  :arity 2
  :domain time-range
  :range time-range)


;;; Relation FINISHES= 
(defrelation finishes=
  :arity 2
  :domain time-range
  :range time-range)


;;; Relation DISJOINT-TR 
(defrelation disjoint-tr
  :arity 2
  :domain time-range
  :range time-range
  :annotations
  ((documentation "time ranges ?tr1 and ?tr2 do not overlap")))


;;; Relation TR+ 
(defrelation tr+
  :is (:satisfies (?tr1 ?tr2 ?duration)
	        (:and
	         (= (time-range.start-time ?tr1)
		  (time-range.start-time ?tr2))
	         (= (tp+ (time-range.end-time ?tr1) ?duration)
		  (time-range.end-time ?tr2))))
  :attributes (:single-valued)
  :arity 3
  :annotations
  ((documentation "TR+ denotes a time range ?tr2 whose length is
longer that ?tr1 by a duration ?duration.")))


;;; Concept TIME-POINT 
(defconcept time-point
  :is-primitive domain-concept
  :annotations
  ((documentation "TIME denotes a certain point of time. It consists
of year, month, day, hour, minute, second, and a unit of time. Any
details smaller than a unit of a time are not defined. For example, if
a unit of time is 2 hour, values of time-minute and time-second are
meaningless.")))


;;; Concept YEAR-NUMBER 
(defconcept year-number
  :is-primitive (:and domain-concept integer)
  :annotations
  ((documentation "YEAR-NUMBER deontes a year of A.D.")))


;;; Concept MONTH-NUMBER 
(defconcept month-number
  :is (:and domain-concept (:through 1 12))
  :annotations
  ((documentation "MONTH-NUMBER denotes a month of a year.")))


;;; Concept MONTH-NAME 
(defconcept month-name
  :is (:and domain-concept
	  (:the-ordered-set january
			february
			march
			april
			may
			june
			july
			august
			september
			october
			november
			december))
  ;;  :characteristics (:circular)
  :annotations
  ((documentation "MONTH-NAME denotes a name of a month of a year.")))


;;; Concept DAY-NUMBER 
(defconcept day-number
  :is (:and domain-concept
	  (:through 1 31))
  :annotations
  ((documentation "DAY-NUMBER denotes a day of a month.")))


;;; Concept DAY-NAME 
(defconcept day-name
  :is (:and domain-concept
	  (:the-ordered-set sunday
			monday
			tuesday
			wednesday
			thursday
			friday
			saturday))
  ;;  :characteristics (:circular)
  :annotations
  ((documentation "DAY-NAME denotes a name of a day of a week.")))


;;; Concept HOUR-NUMBER 
(defconcept hour-number
  :is (:and domain-concept
	  (:through 0 23))
  :annotations
  ((documentation "HOUR-NUMBER denotes an hour of a day.")))


;;; Concept MINUTE-NUMBER 
(defconcept minute-number
  :is (:and domain-concept
	  (:through 0 59))
  :annotations
  ((documentation "MINUTE-NUMBER denotes a minute of a hour.")))


;;; Concept SECOND-NUMBER 
(defconcept second-number
  :is (:and domain-concept
	  (:through 0 59))
  :annotations
  ((documentation "SECOND-NUMBER denotes a second of a minute.")))


;;; Relation TIME-POINT.YEAR 
(defrelation time-point.year
  :is-primitive binary-tuple
  :domain time-point
  :range year-number
  :attributes (:single-valued)
  :arity 2
  :annotations
  ((documentation "TIME-POINT.YEAR denotes a year of a time point.")))


;;; Relation TIME-POINT.MONTH 
(defrelation time-point.month
  :is-primitive binary-tuple
  :domain time-point
  :range month-number
  :attributes (:single-valued)
  :arity 2
  :annotations
  ((documentation "TIME-POINT.MONTH denotes a month of a time point.")))


;;; Relation TIME-POINT.MONTH-NAME 
(defrelation time-point.month-name
  :is-primitive binary-tuple
  :domain time-point
  :range month-name
  :attributes (:single-valued)
  :arity 2
  :annotations
  ((documentation "TIME-POINT.MONTH-NAME denotes a name of a month of a time point.")))


;;; Relation TIME-POINT.DAY 
(defrelation time-point.day
  :is-primitive binary-tuple
  :domain time-point
  :range day-number
  :attributes (:single-valued)
  :arity 2
  :annotations
  ((documentation "TIME-POINT.DAY denotes a day of a time point.")))


;;; Relation TIME-POINT.DAY-NAME 
(defrelation time-point.day-name
  :is-primitive binary-tuple
  :domain time-point
  :range day-name
  :attributes (:single-valued)
  :arity 2
  :annotations
  ((documentation "TIME-POINT.DAY-NAME denotes a name of a day of a time point.")))


;;; Relation TIME-POINT.HOUR 
(defrelation time-point.hour
  :is-primitive binary-tuple
  :domain time-point
  :range hour-number
  :attributes (:single-valued)
  :arity 2
  :annotations
  ((documentation "TIME-POINT.HOUR denotes an hour of a time point.")))


;;; Relation TIME-POINT.MINUTE 
(defrelation time-point.minute
  :is-primitive binary-tuple
  :domain time-point
  :range minute-number
  :attributes (:single-valued)
  :arity 2
  :annotations
  ((documentation "TIME-POINT.MINUTE denotes a minute of a time point.")))


;;; Relation TIME-POINT.SECOND 
(defrelation time-point.second
  :is-primitive binary-tuple
  :domain time-point
  :range second-number
  :attributes (:single-valued)
  :arity 2
  :annotations
  ((documentation "TIME-SECOND denotes a second of a time point.")))


;;; Relation TIME-POINT.UNIT 
(defrelation time-point.unit
  :is-primitive binary-tuple
  :domain time-point
  :range duration
  :attributes (:single-valued)
  :arity 2
  :annotations
  ((documentation "TIME-UNIT denotes a unit of a time point.")))


;;; Relation TP= 
(defrelation tp=
  :is (:satisfies
       (?tp1 ?tp2)
       (:and (= (time-point.year ?tp1) (time-point.year ?tp2))
	   (= (time-point.month ?tp1) (time-point.month ?tp2))
	   (= (time-point.day ?tp1) (time-point.day ?tp2))
	   (= (time-point.hour ?tp1) (time-point.hour ?tp2))
	   (= (time-point.minute ?tp1) (time-point.minute ?tp2))
	   (= (time-point.second ?tp1) (time-point.second ?tp2))))
  :domain time-point
  :range time-point
  :arity 2
  :annotations
  ((documentation "A time point ?tp1 is equal to a time point ?tp2.")))

(defrelation time-point=
  :is tp=)


;;; Relation TP< 
(defrelation tp<
  :is (:satisfies
       (?tp1 ?tp2)
       (:or (< (time-point.year ?tp1) (time-point.year ?tp2))
	  (:and (= (time-point.year ?tp1) (time-point.year ?tp2))
	        (:or
	         (< (time-point.month ?tp1) (time-point.month ?tp2))
	         (:and
		(= (time-point.month ?tp1) (time-point.month ?tp2))
		(:or (< (time-point.day ?tp1) (time-point.day ?tp2))
		     (:and
		      (= (time-point.day ?tp1) (time-point.day ?tp2))
		      (:or
		       (< (time-point.hour ?tp1) (time-point.hour ?tp2))
		       (:and
		        (= (time-point.hour ?tp1)
			 (time-point.hour ?tp2))
		        (:or
		         (< (time-point.minute ?tp1)
			  (time-point.minute ?tp2))
		         (:and
			(= (time-point.minute ?tp1)
			   (time-point.minute ?tp2))
			(< (time-point.second ?tp1)
			   (time-point.second ?tp2)))))))))))))
  :arity 2
  :annotations
  ((documentation "a time point ?tp1 preceeds a time point ?tp2.")))

(defrelation time-point<
  :is tp<)

;;; Relation TP> 
(defrelation tp>
  :is
  (:inverse tp<)
  :arity 2
  :annotations
  ((documentation "inverse of TP<")))

(defrelation time-point>
  :is tp>)

;;; Relation TP+ 
(defrelation tp+
  :is-primitive n-ary-tuple
  :domains (time-point duration)
  :range time-point
  :attributes (:single-valued)
  :arity 3
  :annotations
  ((documentation "A difference between two time points ?tp1 and ?tp2
is a duration ?duration.")))

(defrelation time-point+
  :is tp+)

;;; Concept DURATION 
(defconcept duration
  :is (:and domain-concept
	  (:the duration.value integer)
	  (:the duration.measure temporal-measure))
  :roles ((duration.value :type integer :min 1 :max 1)
	(duration.measure :type temporal-measure :min 1 :max 1))
  :annotations
  ((documentation "DURATION denotes a period of time. It consists of a
value and a measure")))


;;; Relation DURATION.VALUE 
(defrelation duration.value
  :is-primitive binary-tuple
  :domain duration
  :range integer
  :attributes (:single-valued)
  :arity 2
  :annotations
  ((documentation "DURATION.VALUE returns a length of a duration in a cetain measure.")))

;;; Relation DURATION.MEASURE 
(defrelation duration.measure
  :is-primitive binary-tuple
  :domain duration
  :range temporal-measure
  :attributes (:single-valued)
  :arity 2
  :annotations
  ((documentation "DURATION.MEASURE returns a mesure of a length of a duration.")))


;;; Relation DR= 
(defrelation dr=
  :is-primitive binary-tuple
  :domain duration
  :range duration
  :arity 2
  :annotations
  ((documentation "Two durations have the same length.")))

(defrelation duration=
  :is dr=)


;;; Relation DR< 
(defrelation dr<
  :is-primitive binary-tuple
  :domain duration
  :range duration
  :arity 2
  :annotations
  ((documentation "A duration ?dr1 is shorter than a duration ?dr2.")))

(defrelation duration<
  :is dr<)


;;; Relation DR>
(defrelation dr>
  :is (:inverse dr<)
  :domain duration
  :range duration
  :arity 2)

(defrelation duration>
  :is dr>)


;;; Relation DR+
(defrelation dr+
  :is-primitive n-ary-tuple
  :domains (duration duration)
  :range duration
  :attributes (:single-valued)
  :arity 3)

(defrelation duration+
  :is dr+)


;;; Concept TEMPORAL-MEASURE 

(defconcept temporal-measure
  :is (:and domain-concept
	  (:one-of year month day hour minute second))
  :annotations
  ((documentation "TEMPORAL-MEASURE denotes a measure of a length of a
temporal interval.")))



;; These implicatiosn have to be in separate implies statements,
;; because (despite what the manual says) we can't add these as
;; constraints to the relations themselves.

;;; I took them out because I'm more interested in a KB that is simple
;;; to load and debug than in one that performs complex temporal reasoning
;;; (Jim).
#|
(implies before (:and before= disjoint-tr))

(implies after (:and after= disjoint-tr))

(implies meets (:and after= before= overlaps=))

(implies equals (:and during= start= finishes=))

(implies during during=)

(implies overlaps overlaps=)

(implies starts (:and during= start=))

(implies finishes (:and during= finishes=))
|#
