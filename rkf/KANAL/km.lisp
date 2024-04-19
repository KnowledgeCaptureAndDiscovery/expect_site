;;; FILE: README
;;; KM - The Knowledge Machine - Build Date:  Mon Jul 3 07:51:47 PDT 2000

#|
======================================================================
	KM - THE KNOWLEDGE MACHINE - INFERENCE ENGINE 1.4.0 (beta-50)
======================================================================

Copyright (C) 2000 Peter Clark and Bruce Porter

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation; either version2 of the License, or any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY: without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public Licence
for more details.

You should have received a copy of the GNU General Public Licence along with
this program; if not, write to the Free Software Foundation, Inc., 
59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

Contact information:
Peter Clark, m/s 7L66, Boeing, PO Box 3707, Seattle, WA 98124-2207, USA.
	peter.e.clark@boeing.com
Bruce Porter, m/s C0500, Dept Computer Science, Univ Texas at Austin, 
	Austin, TX 78712, USA. porter@cs.utexas.edu

If you would like a copy of this software issued under a different licence
(e.g., with different redistribution conditions) please contact the authors.

A copy of the GNU licence can be found at the end of this file (or in
the file LICENCE if disassembled into its constitutent files), or
by typing (licence) at the Lisp or KM prompts when running KM.

======================================================================

The source code, manuals, and a test suite of examples for the most
recent version of KM are available at 

	http://www.cs.utexas.edu/users/mfkb/km.html

Check this site for RELEASE NOTES and the CURRENT VERSION of KM.

======================================================================
		USING THIS FILE:
======================================================================

Save this file as (say) km.lisp, then load it into your favorite Lisp 
environment:
	% lisp
	> (load "km")

For greatly increased efficiency, make a compiled version of this file:
	% lisp
	> (load "km.lisp")	;;; <== You *must* do this before compiling!
	> (compile-file "km")	;;;			see [1] below.
Now
	> (load "km")		
will load the faster, compiled version in future.

[1] *Note* you will need to load km.lisp first before compiling, so that
    the reader macro #$ is recognized by compile-file.

To start the query interpreter running, type (km):
	> (km)
	KM> 

See the User Manual and Reference Manual for instructions on using KM,
and building knowledge bases. The manuals are available at:

	http://www.cs.utexas.edu/users/mfkb/km.html

======================================================================
	VERSIONING
======================================================================
History:
v1.0 Original
v1.1 Important syntactic changes, as reflected in the manual
v1.1.1 A couple of extra error-checking routines added
v1.2.0 New form for defined concepts. Add "the" and "forc" primitives.
	Old "the" becomes "that".
v1.2.1 Fix inverse slot bug with case-sensitivity turned off.
v1.2.2 Fix :set bug
v1.3.0 Redefine also-has as has, remove has. Extended to reason with
	contexts ("Situations"). Add in quote and km-eval primitives. 
	Fix bug in 'the average of...' and in instance classification.
v1.3.1 Fix minor save-kb and reload-kb bug.
v1.3.2 Add situation hierarchies. local situation info now merges with,
	rather than overrides, global KB info.
v1.3.3 Fixed subtle undesirable behaviour in set unification. (showme ...)
	now lets user know if object is bound. save-kb saves binding list.
v1.3.4 Add do-script and ignore-result commands
v1.3.5 v1.3.4 changed (A & B) to bind A->B, not B->A. We undo this change
       due to a dependency I hadn't spotted in the original order.
v1.3.6 Fix bug to ensure instance-of projects over multiple situations.
v1.3.7 Added (watchsituations <n>) for situation-specific tracing.
v1.4.0 Fundamental rewrite of the low-level KB access mechanism. Numberous
	minor tidyings up (see manual), debugger added, handling of
	descriptions (intensional representations) made more explicit.

======================================================================
		READING/EDITING THE SOURCE:
======================================================================

The following file is a machine-built concatenation of the various files
in the KM inference system. It can be loaded or compiled directly into
Lisp, deconcatenation is not necessary for running KM.

Although you can read/edit the below code all in this one file, it is
very large and unweildy; you may prefer to break it up into the 
(approx 20) constituent files which it comprises. You can break it up
either manually, looking for the ";;; FILE: <file>" headers
below which denote the start of different files in this concatenation,
OR use the Perl unpacker below which automatically cut this big file 
into its consistutent files.

Warning: The code is largely undocumented! 

Peter Clark
pclark@cs.utexas.edu

======================================================================
	DISASSEMBLING THIS CONCATENATION INTO ITS CONSTITUENT FILES:
======================================================================

Note you don't have to disassemble km.lisp to use KM. However, if you
want to read/edit the code, you might find it helpful to break it up:

  1. cut and paste the short Perl script below to a file, eg called
	"disassemble"
  2. Make sure the first line is
		#!/usr/local/bin/perl
     and edit this path /usr/local/bin/perl as needed to point to the 
	local version of Perl.
  3. Make the file executable:
	% chmod a+x disassemble
  4. Now disassemble km.lisp:
	% disassemble km.lisp

This will populate the current directory with the approx. 20 Lisp files
constituting the KM system.

------------------------------ cut here ------------------------------
#!/usr/local/bin/perl
# Splits file with internal file markers of the form:
# ;;; FILE: <filename>
# into individual files in the current directory.
# Outputs to stdout information about processing.
# require 5.0;
$lineno = 0 ;
if ($#ARGV != 0) { die "Usage: $0 filename.";}	# 1 and only 1 arg
$fn = shift(@ARGV);

open(PACKED, "<$fn") || die "Could not open file $fn\n ";
$_ = <PACKED>; $lineno += 1;	# Read first line, and count it
chop;
($junk, $outfile) = split (/:/);

unless ($junk != /^;;; FILE/o) {
	die "Missing file tag ;;; FILE: Line number $lineno."
}
# Open file for writing

unless (open (OUTFILE, ">$outfile")) {
	die "Could not open file $outfile for writing.";
	}
print "$outfile created\n";
while (<PACKED>) {
	$lineno += 1;
	($junk, $outfile) = split (/:/);
	if ($junk =~ /^;;; FILE/o) {	
		close (OUTFILE);
		chop($outfile);
		unless (open (OUTFILE, ">$outfile")) {
	die "Could not open file $outfile for writing.  Line number $lineno.";
		}
		print "$outfile created\n";
	}
	else {
		print (OUTFILE $_);
	}
}
close(PACKED);
close(OUTFILE);
print "Completed without errors. Processed $lineno lines of input from $fn.\n";
------------------------------ cut here ------------------------------
|#
;;; FILE:  header.lisp

;;; File: header.lisp
;;; Purpose: Set some compilation flags etc.

;;; Personal preference
(setq *print-case* :downcase)

;;; Dispatch mechanism not "compiled" be default, unless compiled-handlers.lisp is included.
(defparameter *compile-handlers* nil)

;;; ======================================================================
;;;		DECLARATION OF CONSTANTS
;;; ======================================================================

;;; This is really a constant, but I *really* don't want to put the definition
;;; here! It's setq'ed in interpreter.lisp.
(defparameter *km-handler-alist* nil)

(defconstant *var-marker-char* #\_)
(defconstant *var-marker-string* "_")
(defconstant *proto-marker-string* (concatenate 'string *var-marker-string* "Proto"))		; ie. "_Proto"
(defconstant *fluent-instance-marker-string* (concatenate 'string *var-marker-string* "Some"))	; ie. "_Some" 
(defconstant *km-version* "1.4.0 (beta-50)")
(defconstant *year* "2000")

(defparameter *km-handler-function* nil)	; used in compiler.lisp
; (defconstant *global-situation* '#$*Global)   ; Put in case.lisp, AFTER #$ is defined. Note, need #$ 
; (defconstant *tag-slot* '#$:tag)		; to allow case-sensitivity to be switched off.

;;; ------------------------------

; from prototypes.lisp - move this to AFTER #$ declaration in case.lisp
;(defconstant *slots-not-to-clone-for* '#$(protopart-of protoparts prototypes prototype-of #|source|# instance-of cloned-from))

;;; --------------------
;;; Optimization flags: note which bits of machinery are in use.
;;; --------------------

(defparameter *are-some-definitions* nil)	
(defparameter *classes-using-assertions-slot* nil)
(defparameter *are-some-prototypes* nil)
(defparameter *are-some-subslots* nil)
(defparameter *are-some-constraints* nil)

;;; --------------------

(defvar *curr-prototype* nil)		; For prototype mode
(defparameter *show-comments* t)	; for tracing
(defparameter *use-inheritance* t)	; Applied in get-slotvals.lisp

(defvar *new-approach* t)	; need to work on this a bit more - disable it for now.
;;; FILE:  htextify.lisp

;;; File: htextify.lisp
;;; Author: Peter Clark
;;; Purpose: Dummy function, to suppress compiler warning.
;;; This function is referenced but inaccessible in stand-alone KM.

(defun htextify (concept &optional concept-phrase &key action window)
  (declare (ignore concept concept-phrase action window)))



;;; FILE:  case.lisp

;;; File: case.lisp
;;; Author: Peter Clark
;;; Purpose: Case-sensitive handling for KM
;;; This is togglable via the *case-sensitivity* global variable (default t)

;;; defconstant gives ugly warnings during compilation!
(defparameter *case-sensitivity* t)

;;; ======================================================================
;;;			READING
;;; ======================================================================

(defun case-sensitive-read (&optional stream (eof-err-p t) eof-val rec-p)
  (cond (*case-sensitivity*
	 (let ( (old-readtable-case (readtable-case *readtable*)) )
	   (handler-case
	    (prog2
		(setf (readtable-case *readtable*) :preserve)
		(read stream eof-err-p eof-val rec-p)
	      (setf (readtable-case *readtable*) old-readtable-case))
	    (error (error)			; make sure readtable-case gets reset!
		   (setf (readtable-case *readtable*) old-readtable-case)
		   (error "during case-sensitive-read (premature end-of-file?)~%       ~s" error)))))
	(t (read stream eof-err-p eof-val rec-p))))

(defun hash-dollar-reader (stream subchar arg)
  (declare (ignore subchar arg))
  (case-sensitive-read stream t nil t))

(set-dispatch-macro-character #\# #\$ #'hash-dollar-reader)

;;; ======================================================================
;;;			WRITING
;;; ======================================================================

#|
This version of format *doesn't* put || around symbols, but *does* put
"" around strings. This is impossible to do with the normal format, as
|| and "" can only be suppressed in unison (via the *print-escape*
variable). There's no other way round that I can see besides the below.

> ([km-]format t "~a" (case-sensitive-read))
(The BIG big "car" 2)

produces:
  *case-sensitivity*  *print-case*	format ~a		km-format ~a		format ~s			km-format ~s
	t		:upcase		(The BIG big car 2)	(The BIG big "car" 2)   (|The| BIG |big| "car" 2)	(|The| BIG |big| "\"car\"" 2)
	t		:downcase	(the big big car 2)	(The BIG big "car" 2)
	nil		:upcase		(THE BIG BIG car 2)	(THE BIG BIG "car" 2)
	nil		:downcase	(the big big car 2)	(the big big "car" 2)	

(defun test (x)
  (setq *print-case* :upcase)
  (km-format t "km-format: ~a~%" x)
  (format t "format:   ~a~%" x)
  (setq *print-case* :downcase)
  (km-format t "km-format: ~a~%" x)
  (format t "format:   ~a~%" x))
|#

(defun km-format (stream string &rest args)
  (cond (*case-sensitivity*
	 (let ( (old-print-case *print-case*) )
	   (prog2
	       (setq *print-case* :upcase)	; :upcase really means "case-sensitively"
	       (apply #'format (cons stream 
				     (cons string (mapcar #'add-quotes args))))
	     (setq *print-case* old-print-case))))
	(t (apply #'format (cons stream 
				 (cons string (mapcar #'add-quotes args)))))))

;;; For prettiness, we normally remove || when printing. But, this has the side-effect of also
;;; removing quotes, so we must add those back in -- and also add back in || if the symbol
;;; contains special characters "() ,;:".
;;; (the "cat") -> (the "\"cat\"")
(defun add-quotes (obj)
  (cond ((null obj) nil)
	((listp obj) (mapcar #'add-quotes obj))
	((stringp obj) (format nil "~s" obj)) 		; (concat "\"" obj "\"") <- Insufficient for "a\"b"
	((and (symbolp obj)
	      (intersection (explode (symbol-name obj)) '(#\( #\) #\  #\, #\; #\:)))
	 (concat "|" (symbol-name obj) "|"))
;;;	((eq obj '#$:set) (cond (*case-sensitivity* ":set") (t ":SET"))) ; (symbol-name ':set) loses the ":"
;;;	((eq obj '#$:args) (cond (*case-sensitivity* ":args") (t ":ARGS")))
;;;	((eq obj '#$:seq) (cond (*case-sensitivity* ":seq") (t ":SEQ")))
;;;	((eq obj '#$:triple) (cond (*case-sensitivity* ":triple") (t ":TRIPLE")))
	((keywordp obj) (concat ":" (symbol-name obj)))		; better!
	(t obj)))

;;; "Tool" -> |Tool| (case-sensitivity on); |TOOL| (case-sensitivity off)
(defun string-to-frame (string)
  (cond ((string= string "") nil)
	(*case-sensitivity* (intern string))
	(t (intern (string-upcase string)))))

;;; Like built-in string, except does a downcase if we don't care about case sensitivity
;;; |Tool| -> "Tool" (case-sensitivity on); "tool" (case-sensitivity off)
(defun km-string (symbol)
  (cond (*case-sensitivity* (symbol-name symbol))
	(t (string-downcase symbol))))

;;; Inverse suffix must obey case-sensitive restrictions
(defconstant *inverse-suffix* (cond (*case-sensitivity* "-of") (t "-OF")))
(defconstant *length-of-inverse-suffix* (length *inverse-suffix*))

;;; Must define this *after* case-sensitivity is set.
(defconstant *global-situation* '#$*Global)
(defconstant *slots-not-to-clone-for* '#$(protopart-of protoparts prototypes prototype-of #|source|# instance-of cloned-from))
; no longer used (defconstant *tag-slot* '#$:tag)

#|
======================================================================
		UNQUOTING: KM's own mechanism
		=============================
This isn't very elegant, I'd rather use the traditional `, Lisp syntax, but
this will have to do**. Note the complication that #, always returns a
LIST of instances, so we have to be careful to splice them in appropriately.
Added #@ to do splicing. (a #@b) = (a . #,b)

However, we need to make it a reader macro so that KM will respond to
embedded #, which would otherwise be unprocessed, eg. a handler for "," 
won't even reach the embedded unit in:
	KM> (Pete has (owns (`(a Car with (age ,(the Number)))))) 
	but a macro character will:
	KM> (Pete has (owns ('(a Car with (age #,(the Number))))))

** The mechanism needs to be vendor-independent, but the handling of `, is
vendor-specific. Allegro names these two symbols as excl:backquote and
excl:bq-comma; Harlequin preprocesses the expressions in the reader, so
that `(a b ,c) is pre-converted to (list 'a 'b c).

======================================================================

This *doesn't* require pairing with backquote `.
Usage:
KM> (:set (a Car) (a Car))
(_Car13 _Car14)

KM> '(:set (a Car) (a Car))
('(:set (a Car) (a Car)))

KM> '(:set (a Car) #,(a Car))
('(:set (a Car) (_Car16)))		<= note undesirable () around _Car16

KM> '(:set (a Car) . #,(a Car))		<= use . #, to slice item at end of list
('(:set (a Car) _Car17))
|#

(defun hash-comma-reader (stream subchar arg)
  (declare (ignore subchar arg))
  (list 'unquote (case-sensitive-read stream t nil t)))

(set-dispatch-macro-character #\# #\, #'hash-comma-reader)

; No! Don't need this.
;(defun hash-at-reader (stream subchar arg)
;  (declare (ignore subchar arg))
;  (list 'unquote-splice (case-sensitive-read stream t nil t)))

;(set-dispatch-macro-character #\# #\@ #'hash-at-reader)

;;; FILE:  interpreter.lisp

;;; File: interpreter.lisp
;;; Author: Peter Clark
;;; Date: July 1994
;;; Purpose: KM Query Language interpreter

(defparameter *exhaustive-forward-chaining* nil)

; (defvar *spy-point* nil)
(defconstant *multidepth-path-default-searchdepth* 5)
(defconstant *additional-keywords* '#$(* Self QUOTE UNQUOTE))	; used for (scan-kb) in frame-io.lisp.
(defconstant *infinity* 999999)
(defconstant *km-lisp-exprs*  		;; functions passed onto Lisp
  '(save-kb reset-kb write-kb #|reload-kb+ load-kb+|# #|write-kb-here  I guess we don't need this...|#
    show-context checkkbon checkkboff show-bindings version
    show-obj-stack reset-done install-all-subclasses scan-kb
    disable-classification enable-classification
    fail-quietly fail-noisily 
    instance-of-is-fluent instance-of-is-nonfluent
    taxonomy eval setq tracekm untracekm licence
    #|watchsituationson watchsituationsoff watchsituations|#
    comments nocomments #|think|#
    new-situation global-situation))
(defconstant *downcase-km-lisp-exprs* 
  (mapcar #'(lambda (expr) (intern (string-downcase expr))) *km-lisp-exprs*))
(defconstant *reserved-keywords* 
  '#$(a some must-be-a mustnt-be-a print format km-format an instance
	every the the1 the2 the3 theN of forall forall2 with where theoneof theoneof2
	the+ a+ evaluate-paths clone a-prototype
	oneof oneof2 It It2 if then else allof allof2 and or not is & && &? &+ #|&&?|# &! &&! = == === /= + - / ^
	> >= < <= isa #|expand-text add-clones-to in-which|#
	are includes thelast :set :seq :args :triple showme-here showme showme-all evaluate-all quote
	delete evaluate has-value andify make-sentence make-phrase #|pluralize|#
	every has must is-superset-of covers subsumes has-definition numberp 
	trace untrace fluent-instancep at-least at-most exactly constraint <> graph reverse
	in-situation in-every-situation do do-and-next
	curr-situation ignore-result do-script new-context))

;;; Don't add cloned prototype name to the stack!!
; (defconstant *commands-not-to-stack-result-for* '#$(clone))

; from frame-io.lisp, as we want to reference it here
(defconstant *built-in-classes-with-nonfluent-instances-relation* '#$(Situation Slot Partition))

;;; --------------------
;;; Change to 'error for test-suite
(defparameter *top-level-fail-mode* 'fail)
;(defun fail-noisily () (setq *top-level-fail-mode* 'error))
;(defun fail-quietly () (setq *top-level-fail-mode* 'fail))
(defun fail-noisily () (make-transaction '(setq *top-level-fail-mode* error)) t)
(defun fail-quietly () (make-transaction '(setq *top-level-fail-mode* fail)) t)

;;; --------------------
  
(defun interactive-km ()
  (reset-inference-engine)
  (print-km-prompt)
  (let ( (query (case-sensitive-read)) )
    (cond ((eq query '#$q))
	  ((null query) (km))
	  (t (let ( (answer (catch 'km-abort (prog1 
						 (km query :fail-mode *top-level-fail-mode*)
					       (cond (*exhaustive-forward-chaining* (exhaustively-forward-chain)))))) )
	       (cond ((eq answer 'km-abort) (format t "(Execution aborted)~%NIL~%"))
		     ((and (listp query)				; handle case-sensitivity for keywords in load-kb
			   (member (first query) '(load-kb #$load-kb reload-kb #$reload-kb)))
		      (scan-kb))
		     (t (km-format t "~a~%" answer))))
	     (princ (report-statistics))
;;;	     (cond (*frame-accessp* (report-frame-access-count)))
	     (terpri)
	     (interactive-km)))))

;;; Same as non-interactive km, except also shows statistics on CPU usage etc.
;;; Used by loadkb.lisp.
(defun km+ (kmexpr &key (fail-mode *top-level-fail-mode*))
  (reset-inference-engine)
  (let ( (results (km kmexpr :fail-mode fail-mode)) )	; new: fail-mode 'fail
    (km-format t "~a~%" results)
    (princ (report-statistics))
    (terpri)
    results))

(defun print-km-prompt (&optional (stream t))
  (cond ((and (am-in-local-situation) (am-in-prototype-mode))
	 (report-error 'user-error "You are in both prototype-mode and in a Situation, which isn't allowed!~%"))
;  (cond ((and (am-in-prototype-mode) (am-in-local-situation)) (km-format stream "[prototype-mode, ~a] KM> " (curr-situation)))
        ((am-in-prototype-mode) (km-format stream "[prototype-mode] KM> "))
	((am-in-local-situation) (km-format stream "[~a] KM> " (curr-situation)))
	(t (km-format stream "KM> "))))

;;; ======================================================================
;;;		KM HANDLER METHODS
;;; ======================================================================

;;; (km): TWO MODES:
;;; 		(km) 	     will call (interactive-km)
;;; 		(km <expr>) will evaluate <expr> 
;;;
;;; km evaluates the expression (a path) which is given to it, and returns a
;;; list of instances which the path points to.
;;; <expr> must be either an INSTANCE or a PATH. (NB: A list of instances is 
;;; treated as a path. If you do want a set, you must precede the list by the 
;;; keyword ":set")
;;;
;;; Fail-modes: If km fails to find a referent at the end of the path,
;;; it can either fail quietly and return nil (:fail-mode 'fail), or
;;; gives a warning (:fail-mode 'error). 'error is very useful for debugging
;;; the KB.

;;; Wrapper, to maintain a stack and check for looping
(defun km (&optional (kmexpr 'ask-user) &key (fail-mode 'error) (check-for-looping t))
#|
I really should get this working more!
  (cond
   ((and *spy-point* 
	 (not (tracep))
	 (listp kmexpr)
	 (eq (length kmexpr) 4)
	 (eq (second kmexpr) (second *spy-point*))
	 (symbolp (fourth kmexpr))
	 (isa (fourth kmexpr) (fourth *spy-point*)))
    (setq *trace* t)
    (setq *interactive-trace* t)))
|#
  (cond
   ((eq kmexpr 'ask-user) (interactive-km))
   ((member kmexpr '#$((tracekm) (TRACEKM) (trace) (TRACE)) :test #'equal) 
    (reset-trace-depth)
    (tracekm)
    '#$(t))
   ((member kmexpr '#$((untracekm) (UNTRACEKM) (untrace) (UNTRACE)) :test #'equal) 
    (reset-trace-depth)
    (untracekm)
    '#$(t))
   ((and (listp kmexpr)				; handle case-sensitivity for keywords in load-kb
	 (member (first kmexpr) '(load-kb #$load-kb reload-kb #$reload-kb)))
    (process-load-expression kmexpr)
    '#$(t))
   ((and (listp kmexpr) (member (car kmexpr) *km-lisp-exprs*)) 
    (eval kmexpr) 
    '#$(t))
   ((and (listp kmexpr) (member (car kmexpr) *downcase-km-lisp-exprs*)) 
    (eval (cons (intern (string-upcase (car kmexpr))) (rest kmexpr)))
    '#$(t))
   ((and (am-in-local-situation) (am-in-prototype-mode))
    (report-error 'user-error "You are in both prototype-mode and in a Situation, which isn't allowed!~%"))
   ((and check-for-looping
	 (looping-on kmexpr))			; LOOPING! Defined in stack.lisp
    (km-trace 'comment "Looping on ~a!" kmexpr)
    (let ( (cexpr (canonicalize kmexpr)) )
      (cond ((and (minimatch cexpr '#$(the ?slot of ?instance))  ; SPECIAL CASE: (the <slot> of <instance>)
		  (symbolp (second cexpr))			 ; Do the best you can (even if incomplete!)
		  (is-km-term (fourth cexpr)))		; [1]
	     (let* ( (instance (fourth cexpr))
		     (slot (second cexpr))
		     (vals (get-vals instance slot)) )	; no remove-constraints, as [1] prevents exprs with constraints in
	       (km-trace 'comment "Just using values found so far, = ~a..." vals)
;	       (km-format t "PEC LOOPING! Just using values found so far, = ~a..." vals)
	       (cond ((every #'is-km-term vals) vals)
		     (t (let ( (new-vals (km (vals-to-val vals) :fail-mode 'fail)) ) ; vals may be an expression! ? see test-suite/looping.km for discussion
			  (put-vals instance slot new-vals :install-inversesp nil) ; constraints will be added + note-done when loop is unwound to 
			  new-vals)))))						  ;							upper calling level
	    ((and (triplep kmexpr)
		  (val-unification-operator (second kmexpr)))	; (a &/&?/&! b): Inductive proof: Can assume (X &? Y) when proving (X &? Y)
	     (km-trace 'comment "Assuming ~a to prove ~a (ie. Inductive proof)" kmexpr kmexpr)
;	     (list (first kmexpr)))		; may be an expression!!
#|NEW|#	     (cond ((eq (second kmexpr) '&?) '#$(t))
		   ((kb-objectp (first kmexpr)) (list (first kmexpr)))
		   ((kb-objectp (third kmexpr)) (list (third kmexpr)))))
			; otherwise hope NIL won't generate an error...
;	     (km (first kmexpr)))		; NEW
	    ((and (triplep kmexpr)
		  (set-unification-operator (second kmexpr)))	; (a &&/&&?/&&! b): Inductive proof: Can assume (X &&? Y) when proving (X &&? Y)
	     (km-trace 'comment "Assuming ~a to prove ~a (ie. Inductive proof)" kmexpr kmexpr)	; Result must be at least (append X Y), duplicates
;	     (append (first kmexpr) (third kmexpr)))						; will be removed later.

; 6.19.00 - &&? obsolete now
;	     (cond ((eq (second kmexpr) '&&?) '#$(t))
;		   (t (remove-if-not #'kb-objectp (append (first kmexpr) (third kmexpr))))))
#|NEW|#	     (remove-if-not #'kb-objectp (append (first kmexpr) (third kmexpr))))
	     
;	     (km (vals-to-val (append (first kmexpr) (third kmexpr)))))						; will be removed later.
	    (t (km-trace 'comment "Giving up...)" kmexpr)
	       nil))))
   ((or (null kmexpr)   	 ; fast handling of these special cases, copied from *km-handler-function*
	(eq kmexpr '#$nil)	 ; This IS allowed to fail quietly
	(constraint-exprp kmexpr))
    (cond ((eq fail-mode 'error) (report-error 'user-error "No values found for ~a!~%" kmexpr)))
    nil)
   ((and (atom kmexpr)
	 (not (no-reserved-keywords (list kmexpr))))	; User error! Contains keywords, so fail out
    nil)
   ((and (atom kmexpr)		 ; fast handling, and also don't clutter up the program trace with reflexive calls
	 (eq (dereference kmexpr) kmexpr))		; Is this the reflexive case? see
    (list kmexpr))					; Yes! So just reflect. Otherwise, trace and deref in km0, see [2]
   ((and (km-structured-list-valp kmexpr)	; same, for (:args ...). Again to avoid 
	 (every #'atom (rest kmexpr))		; cluttering up the trace.
; I think this add-to-stack slipped through the cracks! Comment it out now 6.9.00
;	 (or (mapc #'(lambda (v) (cond ((kb-objectp v) (add-to-stack v)))) (rest kmexpr)) t)
	 (equal (dereference kmexpr) kmexpr))
    (list kmexpr))
   (t (prog2
	  (km-push kmexpr)
	  (km0 kmexpr :fail-mode fail-mode)
	(km-pop)))))

;;; (km0 ...)
;;; [1] Note we can't do a remove duplicates, as we often need duplicate
;;; entries in. Eg. ("remove" _car1 "and put" _car1 "into the furnace")
(defun km0 (kmexpr &key (fail-mode 'error))
  (increment-count '*inferences*)
  (let* 
    ( (users-goal (km-trace 'call "-> ~a" kmexpr))
      (answer 
        (cond ((eq users-goal 'fail) nil)
	      (t (remove-dup-instances			; NOTE includes dereferencing
		  (remove nil
			  (cond ((atom kmexpr) (list kmexpr))		; [2]: Checks for keywords and add-to-stack in km [1] above
				(*compile-handlers* (funcall *km-handler-function* fail-mode kmexpr))           ; COMPILED DISPATCH MECHANISM
				(t (let ( (handler (find-handler kmexpr *km-handler-alist* :fail-mode 'fail)) ) ; INTERPRETED DISPATCH MECHANISM
				     (apply (first handler) (cons fail-mode (second handler))))))))))) )
    (cond ((and (null answer)
		(eq fail-mode 'error)) (report-error 'user-error "No values found for ~a!~%" kmexpr)))
    (process-km0-result answer kmexpr :fail-mode fail-mode)))

;;; This allows handling of redo and fail options when tracing.
(defun process-km0-result (answer kmexpr &key (fail-mode 'error))
  (let ( (users-response
	  (cond (answer (km-trace 'exit "<- ~a~30T~a" answer (truncate-string (km-format nil "~a" kmexpr))))
		(t
		 ;; KANAL: collect failed exprs in preconditions
		 (if *test-preconditions*
		       (add-failed-expr kmexpr))
		 (km-trace 'fail "<- FAIL!~30T~a" (truncate-string (km-format nil "~a" kmexpr)))))) )
    (cond ((eq users-response 'redo)
	   (reset-done)
	   (km0 kmexpr :fail-mode fail-mode))
	  ((eq users-response 'fail)
	   (increment-trace-depth)					; put *depth* back to where it was
	   (process-km0-result nil kmexpr :fail-mode fail-mode))
	  (t answer))))

;;; ----------------------------------------

;;; Expected to return EXACTLY *one* value, otherwise a warning is generated.
(defun km-unique (kmexpr &key (fail-mode 'error))
  (let ( (vals (km kmexpr :fail-mode fail-mode)) )
    (cond ((singletonp vals) (first vals))
	  (vals (report-error 'user-error
"Expression ~a was expected to return a single value,
but it returned multiple values ~a!
Just taking the first...(~a) ~%" kmexpr vals (first vals))
		(first vals))
	  ((eq fail-mode 'error) 
	   (report-error 'user-error "Expression ~a didn't return a value!~%" kmexpr)))))

;;; ======================================================================

;;; Handle case-sensitivity and quoted morphism table in load-kb expression
;;; (load-kb "foo.km" :verbose t :with-morphism '((a -> 1) (b -> 2)))
(defun process-load-expression (load-expr0)
  (let ( (load-expr (sublis '((#$:verbose . :verbose)				; :verbose -> :VERBOSE etc.
			      (#$:eval-instances . :eval-instances)
			      (#$:with-morphism . :with-morphism))
			    load-expr0)) )
    (case (first load-expr)
	  ((load-kb #$load-kb) (apply #'load-kb0 (rest load-expr)))
	  ((reload-kb #$reload-kb) (apply #'reload-kb0 (rest load-expr))))))

;;; ======================================================================

;;; The association list is a set of pairs of form (pattern function).
;;; Function gets applied to the values of variables in pattern, the
;;; values stored in a list in the order they were encountered 
;;; when (depth-first) traversing the km expression.

;;; Below: two alternative ways of embedding Lisp code
;;; `,#'(lambda () ....) 	<- marginally faster, but can't be manipulated
;;; '(lambda (...))
;;; 4.15.99 Changed `(a ,frame with . ,slotsvals) to `(a ,frame with ,@slotsvals), as Lucid problem
;;; for writing out the flattened-out code:
;;; 	(write '`(a ,frame with . ,slotsvals)) -> `(A ,FRAME WITH EXCL::BQ-COMMA SLOTSVALS) = Lucid-specific!!
;;; 	(write '`(a ,frame with ,@slotsvals)) -> `(A ,FRAME WITH ,@SLOTSVALS) = readable by other Lisps

;;; v1.4.0 - order in terms of utility for speed!

(setq
  *km-handler-alist*
  '(
;;; [1] NEW: Here make another top level call, so 
;;;	(i) the trace is easier to follow during debugging
;;;	(ii) the looping checker jumps in at the right moment
;;; [2] This is a bit of a hack; with looping, e.g. another query higher in the stack for (((a Cat)) && (the cats of Sue)),
;;;     KM may possibly return structured answers e.g. ((a Cat) (the cats of Sue)). Need to remove the non-evaluated ones (urgh).
;;;     See test-suite/restaurant.km for the source of this patch.
;;; [3] New! Remove the transitivity incompleteness described in the user manual
    ( (#$the ?slot #$of ?frameadd)  
      (lambda (fmode0 slot frameadd)
	(cond ((structured-slotp slot)
	       (follow-multidepth-path (km frameadd :fail-mode fmode0)   ; start-values
				   slot '* :fail-mode fmode0))	     ; target-class = *
	      (t (let* ( (fmode (cond ((built-in-aggregation-slot slot) 'fail)
				      (t fmode0)))
; OLD			 (frames (km frameadd :fail-mode fmode)) )
; Now we at least see the looping and collect cached values
 			 (frames (cond ((every #'is-simple-km-term (val-to-vals frameadd))
					(remove-dup-instances (val-to-vals frameadd)))		; includes dereferencing
				       (t (km frameadd :fail-mode fmode :check-for-looping nil)))) ) 	; [3]
		   (cond ((not (equal frames (val-to-vals frameadd)))
			  (remove-if-not #'is-km-term (km `#$(the ,SLOT of ,(VALS-TO-VAL FRAMES)) :fail-mode fmode)))	; [1], [2]
			 (t (remove-if-not #'is-km-term (km-multi-slotvals frames slot :fail-mode fmode)))))))) )	; [2]

    ( (#$a ?class)
      (lambda (_fmode class) (declare (ignore  _fmode)) (list (create-instance class))) )

    ( (#$a ?class #$with &rest)
      (lambda (_fmode class slotsvals) 
	   (declare (ignore  _fmode)) 
	   (cond ((are-slotsvals slotsvals)
		  (list (create-instance class slotsvals))))) )

;;; Internal -- for RKF prototype synthesis
;    ( (#$a-protoinstance ?class)
;      (lambda (_fmode class) (declare (ignore  _fmode)) (list (create-instance class nil *proto-marker-string*))) )
;
;    ( (#$a-protoinstance ?class #$with &rest)
;      (lambda (_fmode class slotsvals) 
;	   (declare (ignore  _fmode)) 
;	   (cond ((are-slotsvals slotsvals)
;		  (list (create-instance class slotsvals *proto-marker-string*))))) )

#| 
Remove this now - require user to explicitly use "assertions" slot
;;; Special rewrite for situations:
;;;    (a Situation in-which '(Fred has (leg (*Broken))) '(Joe has (feeling (*Sad))))
;;; -> (a Situation with (assertions ('(Fred has (leg (*Broken))) '(Joe has (feeling (*Sad))))))
    ( (#$a ?situation-class #$in-which &rest)
      (lambda (fmode situation-class assertions)
;	(print assertions)
	(cond ((not (is-subclass-of situation-class '#$Situation))
	       (report-error 'user-error "~a:~%   Can't do this! (~a is not a subclass of Situation!)~%" 
			     `#$(a ,SITUATION-CLASS in-which ,@ASSERTIONS) situation-class))
	      ((some #'(lambda (assertion) (not (descriptionp assertion))) assertions)
	       (report-error 'user-error "~a:~%   `in-which' must be followed by a list of quoted assertions!
   e.g. (a Situation in-which '(Fred has (leg (*Broken))) '(Joe has (feeling (*Sad))))~%"
			     `#$(a ,SITUATION-CLASS in-which ,@ASSERTIONS) situation-class))
	      (t (km `#$(a ,SITUATION-CLASS with (assertions ,ASSERTIONS)) :fail-mode fmode)))))
|#

;;; Define fluent-instances:
    ( (#$some ?class)
      (lambda (_fmode class) 
	(declare (ignore  _fmode)) 
	(list (create-instance class nil *fluent-instance-marker-string*))) )	; svs = nil, fluent-instance string = "Some"

    ( (#$some ?class #$with &rest)
      (lambda (_fmode class slotsvals) 
	   (declare (ignore  _fmode)) 
	   (cond ((are-slotsvals slotsvals)
		  (list (create-instance class slotsvals *fluent-instance-marker-string*))))) ) ; fluent-instance string = "Some"

;;; ======================================================================
;;;		PROTOTYPES	- Experimental!
;;; ======================================================================

    ( (#$a-prototype ?class)
      (lambda (fmode class) 
	(km `#$(a-prototype ,CLASS with) :fail-mode fmode)) )		; rewrite, errors caught below

    ( (#$a-prototype ?class #$with &rest)
      (lambda (_fmode class slotsvals) 
	   (declare (ignore  _fmode)) 
	   (cond ((am-in-local-situation)
		  (report-error 'user-error "Can't enter prototype mode when in a Situation!~%"))
		 ((am-in-prototype-mode)
		  (report-error 'user-error 
	    "~a~%Attempt to enter prototype mode while already in prototype mode (not allowed)!~%Perhaps you are missing an (end-prototype)?"
	    			`#$(a-prototype ,CLASS with ,@SLOTSVALS)))
	         ((are-slotsvals slotsvals)
		  (new-context)
		  (make-transaction 
		    `(setq *curr-prototype* 
			,(create-instance class 
					 `#$((prototype-of (,CLASS)) 
					     ,(COND (SLOTSVALS `(definition ('(a ,CLASS with ,@SLOTSVALS))))
						    (T `(definition ('(a ,CLASS)))))
					     ,@SLOTSVALS)
					 *proto-marker-string*)))			; ie. "_Proto"
		  (add-val *curr-prototype* '#$protoparts *curr-prototype*)		; consistency
		  (setq *are-some-prototypes* t)		; optimization flag
		  (list *curr-prototype*)))) )

    ( (#$end-prototype)
      (lambda (_fmode)
	(declare (ignore _fmode))
;	(eval-instances)
;	(eval-instances)
;	(setq *curr-prototype* nil)
	(make-transaction '(setq *curr-prototype* nil))
	(global-situation)
	(new-context)
	'#$(t)) )

    ( (#$clone ?expr)
      (lambda (fmode expr)
	(let ( (source (km-unique expr)) )
	  (cond (source (list (clone source)))))) )

#| Appears to be obsolete
    ( (#$add-clones-to ?expr)
      (lambda (fmode expr)
	(let ( (source (km-unique expr)) )
	  (cond (source (unify-in-prototypes source)
			(list source))))) )
|#

    ( (#$evaluate-paths) 
      (lambda (_fmode)
	(declare (ignore _fmode))
	(eval-instances)
	'#$(t)) )

;;; ======================================================================

;;; This for internal use only
    ( (#$fluent-instancep ?expr)				 ; largely for debugging
      (lambda (fmode expr) 
	(cond ((fluent-instancep (km-unique expr :fail-mode fmode)) '#$(t)))) )

    ( (#$default-fluent-status &rest)
      (lambda (fmode rest)
	(declare (ignore fmode))
	(default-fluent-status (first rest))) )

;;; ----------------------------------------------------------------------
;;; Type constraints don't get evaluated.

    ( (#$must-be-a ?class) (lambda (_fmode _class) (declare (ignore  _fmode _class)) nil))

    ( (#$must-be-a ?class #$with &rest)
      (lambda (_fmode _class slotsvals) 
	   (declare (ignore  _fmode _class)) 
	   (are-slotsvals slotsvals)				; Syntax check
	   nil))

    ( (#$mustnt-be-a ?class) (lambda (_fmode _class) (declare (ignore  _fmode _class)) nil))

    ( (#$mustnt-be-a ?class #$with &rest)
      (lambda (_fmode _class slotsvals) 
	   (declare (ignore  _fmode _class)) 
	   (are-slotsvals slotsvals)				; Syntax check
	   nil))

;;; New 1.4.0-beta10:
    ( (<> ?val) (lambda (_fmode _val) (declare (ignore  _fmode _val)) nil))	; ie. means isn't val

    ( (#$constraint ?expr)			; constraints tested elsewhere
      (lambda (_fmode _expr)
	(declare (ignore _fmode _expr))))

    ( (#$set-constraint ?expr)			; constraints tested elsewhere
      (lambda (_fmode _expr)
	(declare (ignore _fmode _expr))))

    ( (#$at-least ?n ?class)
      (lambda (_fmode _n _class)
	(declare (ignore _fmode _n _class))) )

    ( (#$at-most ?n ?class)
      (lambda (_fmode _n _class)
	(declare (ignore _fmode _n _class))) )

    ( (#$exactly ?n ?class)
      (lambda (_fmode _n _class)
	(declare (ignore _fmode _n _class))) )

    ; ----------------------------------------

    ; ============================
    ; AUGMENTING MEMBER PROPERTIES
    ; ============================

#|
Still to be implemented...
    ( (#$rule ?rule (#$every ?cexpr #$has &rest))
      (lambda (_fmode rule cexpr slotsvals)
	   (declare (ignore  _fmode))
	   (let ( (class (km-unique cexpr)) )
	     (cond ((not (kb-objectp class))
;		    (km-format t "ERROR! ~a~%" `(#$rule ,rule (#$every ,cexpr #$has ,@slotsvals)))
;		    (km-format t "ERROR! ~a isn't/doesn't evaluate to a class name.~%" cexpr))
		   ((are-slotsvals slotsvals)		; check
		    (add-slotsvals class slotsvals 'member-properties rule)
		    (mapc #'un-done (all-instances class))
		    (list class))))))
|#

    ( (#$every ?cexpr #$has &rest)
      (lambda (_fmode cexpr slotsvals)
	   (declare (ignore  _fmode))
	   (let ( (class (km-unique cexpr)) )
	     (cond ((not (kb-objectp class))
		    (report-error 'user-error "~a~%~a isn't/doesn't evaluate to a class name.~%"
				  `(#$every ,cexpr #$has ,@slotsvals) cexpr))
		   ((are-slotsvals slotsvals)		; check
		    (add-slotsvals class slotsvals 'member-properties nil)		; install-inversesp = nil
		    (cond ((and (assoc '#$assertions slotsvals)
				(not (member class *classes-using-assertions-slot*)))
;			   (setq *classes-using-assertions-slot* (cons class *classes-using-assertions-slot*))))
			   (make-transaction `(setq *classes-using-assertions-slot* ,(cons class *classes-using-assertions-slot*)))))
		    (mapc #'un-done (all-instances class))
		    (list class))))))

    ; =========================
    ; AUGMENTING OWN PROPERTIES
    ; =========================

;;; [1] not used (yet). The goal was to distinguish primary ("notable") links which the prototype asserted,
;;; from secondary links which the prototype had to build to reach objects for the primary links. For example,
;;; want to highlight that (for a prototype flying plane) the engine is status on, but not that the plane
;;; has an engine, even though both assertions are part of the prototype graph.
    ( (?instance-expr #$has &rest)
      (lambda (_fmode instance-expr slotsvals)
	   (declare (ignore  _fmode))
	   (let ( (instance (km-unique instance-expr)) )
	     (cond ((not (kb-objectp instance))
		    (report-error 'user-error "~a~%~a isn't/doesn't evaluate to a KB object name.~%"
				  `(,instance-expr #$has ,@slotsvals) instance-expr))
		   ((are-slotsvals slotsvals)	; check
		    (add-slotsvals instance slotsvals 'own-properties)
		    (un-done instance)		; In case redefinition	  - now in put-slotsvals; Later: No!!
		    (classify instance)		; Because it's an instance
#|new|#		    (cond ((am-in-prototype-mode) 
			   ; (eval-instances)
			   (km '#$(evaluate-paths))))	; new: route through query interpreter for tracing and also loop detection
		    (list instance))))) )
#| [1]		    (cond ((am-in-prototype-mode)
			   (let ( (evaluated-slotsvals
				   (mapcar #'(lambda (slotvals) 
					       (cond ((some #'(lambda (val) (not (is-simple-km-term val))) (vals-in slotvals))
						      (list (slot-in slotvals) (km `#$(the ,(SLOT-IN SLOTVALS) of ,INSTANCE))))
						     (t slotvals)))
					   slotsvals)) )
			     (add-slotsvals instance evaluated-slotsvals 'notable-properties))))
		    (list instance))))))
|#
    ;;; ----------------------------------------------------------------------
    ;;;	 UNIFICIATION - now off-load to special procedure in lazy-unify.lisp
    ;;; ----------------------------------------------------------------------

    ( (?xs && &rest)
      (lambda (fmode xs rest)
	(declare (ignore _fmode))
	(lazy-unify-&-expr `(,xs && ,@rest) :joiner '&&)) )

    ( (?x & &rest)
      (lambda (fmode x rest)
	(declare (ignore _fmode))
	(lazy-unify-&-expr `(,x & ,@rest) :joiner '&)) )

    ( (?xs === &rest)
      (lambda (fmode xs rest)
	(declare (ignore _fmode))
	(lazy-unify-&-expr `(,xs === ,@rest) :joiner '===)) )

    ( (?x == &rest)
      (lambda (fmode x rest)
	(declare (ignore _fmode))
	(lazy-unify-&-expr `(,x == ,@rest) :joiner '==)) )

;;; These variants do eager unification
    ( (?xs &&! &rest)
      (lambda (fmode xs rest)
	(declare (ignore _fmode))
	(lazy-unify-&-expr `(,xs &&! ,@rest) :joiner '&&!)) )

    ( (?x &! &rest)
      (lambda (fmode x rest)
	(declare (ignore _fmode))
	(lazy-unify-&-expr `(,x &! ,@rest) :joiner '&!)) )

;;; NEW VERSION: Avoids creating then deleting the temporary frame
    ( (?x &? ?y)			; *tests* unification. No side effects. Returns a better unification expression if successful.
      (lambda (_fmode x y)
	(declare (ignore _fmode))
	(cond ((is-existential-expr y) (let ( (xf (km-unique x :fail-mode 'fail)) )
					(cond ((null xf) '#$(t))
					      ((unifiable-with-existential-expr xf y) '#$(t)))))
	      ((is-existential-expr x) (let ( (yf (km-unique y :fail-mode 'fail)) )
					(cond ((null yf) '#$(t))
					      ((unifiable-with-existential-expr yf x) '#$(t)))))
	      (t (let ( (xv (km-unique x :fail-mode 'fail)) )
		   (cond ((null xv) '#$(t))
			 (t (let ( (yv (km-unique y :fail-mode 'fail)) )
			      (cond ((null yv) '#$(t))
				    ((try-lazy-unify xv yv) '#$(t)))))))))))		; return "t" if successful

;;; ---------- Unification, but with classes-subsumep constraint turned ON

;;; If unification fails, it returns NIL but no error is printed out.
;;; &+ is more restricted than & (at least for now), it won't nicely break up nested
;;; expressions.
;;; For INTERNAL KM USE ONLY
    ( (?x &+ ?y)
      (lambda (fmode x y)
	(let ( (unification (lazy-unify-exprs x y :classes-subsumep t :fail-mode fmode)) )
	  (cond (unification (list unification))
		((eq fmode 'error) 
		 (report-error 'user-error "Unification (~a &+ ~a) failed!~%" x y))))) )

;;; ----------

#|
; No longer used -- instead &&? really only makes sense in the context of slot-values.
    ( (?xs &&? ?ys)			; *tests* unification. No side effects.	Returns t if unification will be successful.
      (lambda (_fmode xs ys)
	(declare (ignore _fmode))
	(cond 
	 ((or (null xs)
	      (null ys)) '#$(t))
	 (t (let ( (constraints (append (find-constraints xs 'plural)		; 'plural as vs1 is a list of values, not a single value/expr
					(find-constraints ys 'plural))) )
	      (cond (constraints (let ( (xvs (km (vals-to-val xs) :fail-mode 'fail))		; IF some constraints there...
					(yvs (km (vals-to-val ys) :fail-mode 'fail)) )
				   (cond ((and (test-constraints xvs constraints) 	; THEN better check them first!
					       (test-constraints yvs constraints))
					  '#$(t)))))
		    (t '#$(t))))))))
|#

;;; ----------------------------------------

;;; This is a special case where we do allow delistification.
;;;	"(the x of y) = z" is okay [strictly should be (the x of y) = (z)]
    ( (?x = ?y) (lambda (fmode x y)
		     (let ( (xv (km x :fail-mode fmode))
			    (yv (km y :fail-mode fmode)) )
		       (cond ((or (equal xv yv)
				  (and (singletonp xv) (equal (first xv) yv))
				  (and (singletonp yv) (equal (first yv) xv))
				  (set-equal xv yv))		; nice! v1.3 required order-equality
			      '(#$t))))) )


    ( (#$the ?class ?slot #$of ?frameadd)
      (lambda (fmode0 class slot frameadd)
	   (cond ((structured-slotp slot)
		  (follow-multidepth-path (km frameadd :fail-mode fmode0)   ; start-values
				      slot class :fail-mode fmode0))
		 (t (let* ( (fmode (cond ((built-in-aggregation-slot slot) 'fail)
					 (t fmode0))) )
		      (vals-in-class (km `#$(the ,SLOT of ,FRAMEADD) :fail-mode fmode)
				     class))))) )

;;; ======================================================================
;;;		SITUATIONS: Pass these KM commands straight to Lisp
;;; Note if these are issued directly from Lisp, then the KM exprs have to be quoted.
;;; ======================================================================

    ( (#$in-situation ?situation-expr)
      (lambda (_fmode situation-expr)
	   (declare (ignore _fmode))
	   (in-situation situation-expr)) )

    ( (#$in-situation ?situation (#$the ?slot #$of ?frame))	; special fast handling of this: If
      (lambda (_fmode situation slot frame)			; the slot-vals are already computed ([1])
	   (declare (ignore _fmode))				; then just do a lookup ([2])
	   (cond ((and (kb-objectp situation)
		       (isa situation '#$Situation)
		       (already-done frame slot situation))			; [1] 
		  (remove-constraints (get-vals frame slot 'own-properties situation)))	; [2]
		 (t (in-situation situation `#$(the ,SLOT of ,FRAME))))) )

    ( (#$in-situation ?situation-expr ?km-expr)
      (lambda (_fmode situation-expr km-expr)
	   (declare (ignore _fmode))
	   (in-situation situation-expr km-expr)) )

;;; ----------------------------------------

    ( (#$do ?action-expr)
      (lambda (_fmode action-expr)
	   (declare (ignore _fmode))
	   (list (do-action action-expr))) )			; NB do-action returns a SINGLE value (a situation), not a list.

    ( (#$do-and-next ?action-expr)
      (lambda (_fmode action-expr)
	   (declare (ignore _fmode))
	   (list (do-action action-expr :change-to-next-situation t))) )

;;; Now returns the list of successful actions
    ( (#$do-script ?script)
      (lambda (fmode script)
	   (km `#$(forall (the actions of ,SCRIPT) (do-and-next It)) 
	       :fail-mode fmode)) )

;;; ----------------------------------------

   ( (#$assert ?triple-expr)
      (lambda (_fmode triple-expr)
	(declare (ignore _fmode))
	(let ( (triple (km-unique triple-expr :fail-mode 'fail)) )
	  (cond ((not (km-triplep triple))
		 (report-error 'user-error "(assert ~a): ~a should evaluate to a triple! (evaluated to ~a instead)!~%"
			       triple-expr triple))
		(t (km `#$(,(ARG1OF TRIPLE) has (,(ARG2OF TRIPLE) (,(ARG3OF TRIPLE))))))))) )

    ( (#$is-true ?triple-expr)
      (lambda (_fmode triple-expr)
	(declare (ignore _fmode))
	(let ( (triple (km-unique triple-expr :fail-mode 'fail)) )
	  (cond ((not (km-triplep triple))
		 (report-error 'user-error "(assert ~a): ~a should evaluate to a triple! (evaluated to ~a instead)!~%"
			       triple-expr triple))
		(t (km `#$((the ,(ARG2OF TRIPLE) of ,(ARG1OF TRIPLE)) includes ,(ARG3OF TRIPLE)) :fail-mode 'fail))))) )

    ( (#$all-true ?triples-expr)
      (lambda (_fmode triples-expr)
	(declare (ignore _fmode))
	(let ( (triples (km triples-expr :fail-mode 'fail)) )
	  (cond ((every #'(lambda (triple)
			    (km `#$(is-true ,TRIPLE) :fail-mode 'fail))
			triples)
		 '#$(t))))))

    ( (#$some-true ?triples-expr)
      (lambda (_fmode triples-expr)
	(declare (ignore _fmode))
	(let ( (triples (km triples-expr :fail-mode 'fail)) )
	  (cond ((some #'(lambda (triple)
			   (km `#$(is-true ,TRIPLE) :fail-mode 'fail))
		       triples)
		 '#$(t))))))

;;; ----------------------------------------

    ( #$(next-situation)
	(lambda (_fmode)
	     (declare (ignore _fmode))
	     (cond ((am-in-local-situation) (list (do-action nil :change-to-next-situation t)))
		   (t (report-error 'user-error "Can only do (next-situation) from within a situation!~%")))))

    ( #$(curr-situation)
	(lambda (_fmode)
	     (declare (ignore _fmode))
	     (list (curr-situation))) )

    ( (#$ignore-result ?expr)		; return t always
      (lambda (fmode expr)
	   (km expr :fail-mode 'fail) nil))

    ; Important v1.3.8 addition!
    ; expr should be an assertional expression
    ( (#$in-every-situation ?situation-class ?expr)
      (lambda (fmode situation-class km-expr)
	   (cond ((not (is-subclass-of situation-class '#$Situation))
		  (report-error 'user-error "~a:~%   Can't do this! (~a is not a subclass of Situation!)~%" 
				`#$(in-every-situation ,SITUATION-CLASS ,KM-EXPR) situation-class))
		 (t (let ( (modified-expr (sublis '#$((TheSituation . Self) (Self . SubSelf)) km-expr)) )
		      (km `#$(in-situation ,*GLOBAL-SITUATION*
					   (every ,SITUATION-CLASS has (assertions (',MODIFIED-EXPR)))) :fail-mode fmode))))) )

;;; ----------------------------------------

    ( (#$graph ?expr)
      (lambda (fmode expr)
	(graph (km-unique expr :fail-mode fmode))))

    ( (#$graph ?expr ?depth)
      (lambda (fmode expr depth)
	(cond ((not (integerp depth))
	       (report-error 'user-error "Depth for graph must be an integer (was ~a)!~%" depth))
	      (t (graph (km-unique expr :fail-mode fmode) depth)))))

;;; ======================================================================
;;;		CONTEXTS - Very experimental!!
;;; These are distinct from situations. A situation is a version of the KB.
;;; A context is where just the participant instances are visible.
;;; ======================================================================

    ( #$(new-context)
	(lambda (_fmode)
	     (declare (ignore _fmode))
	     (clear-obj-stack)			; NEW. Let obj-stack be the context
	     '#$(t)) )

;;; ======================================================================
;;;	the ordering of the remaining handers is arbitrary
;;; ======================================================================

;;; ========================================
;;;	QUICK SEARCH OF THE STACK (previously was "the" rather than "that")
;;; ========================================

;;; Now merged into the single framework of subsumption checking.
    ( (#$thelast ?frame)
      (lambda (_fmode frame) (declare (ignore  _fmode)) 
	   (let ( (last-instance (search-stack frame)) )
	     (cond (last-instance (list last-instance))))) )

;;; ========================================
;;;  FIND OBJECTS BY SUBSUMPTION CHECKING
;;; ========================================

    ( (#$every ?frame)
      (lambda (fmode frame) (km `(#$every ,frame #$with) :fail-mode fmode)) )

    ( (#$every ?frame #$with &rest)
      (lambda (_fmode frame slotsvals) 
	   (declare (ignore  _fmode))
	   (cond 
	    ((are-slotsvals slotsvals)
	     (let ( (existential-expr
		          (cond ((and (null slotsvals) (pathp frame)) 	  ; eg. (the (porter owns car))
				 (path-to-existential-expr frame))
				(t `(#$a ,frame #$with ,@slotsvals)))) )
	       (find-subsumees existential-expr))))) )	; NB Don't search the whole *obj-stack*; v1.3.8 yes do!

;;; (the ...)  -- expects a unique answer

;;; REDEFINITIONS: 
;;;	(the ...) -> (find-the ...)
;;;	(forc (the ...)) -> (the ...)

;;; 2.29.00 - the below is more verbose,  to give better error messages during debugging.
;;; (The earlier version just send (the X) -> (the X with ...) -> (km-unique (every X with ...)), but then error messages were unintuitive)

    ( (#$the ?frame)
      (lambda (fmode frame) 
	(declare (ignore fmode))
	(let ( (answer (km `(#$every ,frame) :fail-mode 'fail)) )
	  (cond ((null answer)
		 (report-error 'user-error "No values found for expression ~a!~%" `#$(the ,FRAME)))
		((not (singletonp answer))
		 (report-error 'user-error "Expected a single value for expression ~a, but found multiple values ~a!~%" `#$(the ,FRAME) answer))
		(t answer)))))

    ( (#$the ?frame #$with &rest)
      (lambda (fmode frame slotsvals)
	(declare (ignore fmode))
	   (let ( (answer (km `(#$every ,frame #$with ,@slotsvals) :fail-mode 'fail)) )
	     (cond ((null answer) 
		    (report-error 'user-error "No values found for expression ~a!~%" `#$(the ,FRAME with ,@SLOTSVALS)))
		   ((not (singletonp answer))
		    (report-error 'user-error "Expected a single value for expression ~a, but found multiple values ~a!~%" 
				  `#$(the ,FRAME with ,@SLOTSVALS) answer))
		   (t answer)))))

;;; Find-or-create Three forms for forc:
;;; (forc (the (porter owns car)))		; (forc (the ...)) and (forc (a ...)) are synonymous
;;; (forc (the car with (owns-by (porter))))
;;; (forc (porter owns car)

;;; Rewrites, to allow path notation to be used...
    ( (#$the+ ?slot #$of ?frameadd)  
      (lambda (_fmode slot frameadd)
	(declare (ignore _fmode))
	(km `#$(the+ Thing with (,(INVERT-SLOT SLOT) (,FRAMEADD))))))

    ( (#$the+ ?class ?slot #$of ?frameadd)
      (lambda (_fmode class slot frameadd)
	(declare (ignore _fmode))
	(km `#$(the+ ,CLASS with (,(INVERT-SLOT SLOT) (,FRAMEADD))))))

   ( (#$the+ ?frame)
     (lambda (fmode frame) (km `(#$the+ ,frame #$with) :fail-mode fmode)) )

    ( (#$the+ ?frame #$with &rest)
      (lambda (_fmode frame slotsvals) 
	    (declare (ignore  _fmode))
;	    (cond 
;	     ((km `(#$the ,frame #$with ,@slotsvals) :fail-mode 'fail))	  ; OLD: (the ... with ...) *always* generates error on failure, so bypass this.
	    (let ( (val (km-unique `(#$every ,frame #$with ,@slotsvals) :fail-mode 'fail)) )	; NEW		; PS don't surpress error for (the ...)!
	      (cond 
	       (val (list val))
	       ((are-slotsvals slotsvals)
		(let ( (existential-expr
			(cond ((and (null slotsvals) (pathp frame)) 	  ; eg. (a (porter owns car))
			       (path-to-existential-expr frame))
			      (t `(#$a ,frame #$with ,@slotsvals)))) )
		  (mapcar #'eval-instance (km existential-expr))))))) )	; [1]

   ( (#$a+ &rest)							; a+ is synonym for the+
     (lambda (fmode rest) (km `(#$the+ ,@rest) :fail-mode fmode)) )

;;; [1] above: Do an eval-instance forces inverses in! For example, doing 
;;;    (the+ Leg with (part-of ((the Dog with (owned-by (Bruce))))))
;;; should not just return _Leg2, but also add (Bruce owns _Dog3), and (_Dog3 parts _Leg2)

    ; ----------------------------------------

    ; ==========================
    ; DEFINING MEMBER PROPERTIES
    ; ==========================

    ( (#$every ?cexpr #$has-definition &rest)
      (lambda (_fmode cexpr slotsvals)
	   (declare (ignore  _fmode))
	   (let ( (class (km-unique cexpr)) )
	     (cond ((not (kb-objectp class))
		    (report-error 'user-error "~a~%~a isn't/doesn't evaluate to a class name.~%"
				  `(#$every ,cexpr #$has-definition ,@slotsvals) cexpr))
		   ((are-slotsvals slotsvals)
		    (add-slotsvals class slotsvals 'member-definition nil)	; install-inversep = nil
		    (point-parents-to-defined-concept class (vals-in (assoc '#$instance-of slotsvals)) 'member-definition)
		    (setq *are-some-definitions* t)
		    (mapc #'un-done (all-instances class))
		    (list class))))))  


    ; =======================
    ; DEFINING OWN PROPERTIES
    ; =======================

    ( (?instance-expr #$has-definition &rest)
      (lambda (_fmode instance-expr slotsvals)
	   (declare (ignore  _fmode))
	   (let ( (instance (km-unique instance-expr)) )
	     (cond ((not (kb-objectp instance))
		    (report-error 'user-error "~a~%~a isn't/doesn't evaluate to a KB object name.~%" 
				  `(#$every ,instance-expr #$has-definition ,@slotsvals) instance-expr))
		   ((are-slotsvals slotsvals)	; check
 		    (add-slotsvals instance slotsvals 'own-definition)
		    (point-parents-to-defined-concept instance (vals-in (assoc '#$instance-of slotsvals)) 'own-definition)
		    (setq *are-some-definitions* t)
		    (un-done instance)		; In case redefinition	- now in put-slotsvals; Later: no!!!
		    (classify instance)		; Because it's an instance
		    (list instance))))) )

   ; ----------------------------------------

    ( (#$if ?condition #$then ?action)
      (lambda (fmode condition action)
	   (km `(#$if ,condition #$then ,action #$else nil) :fail-mode fmode)) )

    ( (#$if ?condition #$then ?action #$else ?altaction)
      (lambda (fmode condition action altaction)
	   (let ( (test-result (km condition :fail-mode 'fail)) )
	     (cond ((not (member test-result '#$(NIL f F))) (km action :fail-mode fmode))
		   (t (km altaction :fail-mode fmode))))))

    ( (?x > ?y) (lambda (_fmode x y)
		     (declare (ignore  _fmode))
		     (let ( (xval (km-unique x :fail-mode 'error))
			    (yval (km-unique y :fail-mode 'error)) )
		       (cond ((and (numberp xval) (numberp yval) (> xval yval))
			      '#$(t))))) )

    ( (?x < ?y) (lambda (_fmode x y)
		     (declare (ignore  _fmode))
		     (let ( (xval (km-unique x :fail-mode 'error))
			    (yval (km-unique y :fail-mode 'error)) )
		       (cond ((and (numberp xval) (numberp yval) (< xval yval))
			      '#$(t))))) )

    ( (?x >= ?y) (lambda (_fmode x y)
		     (declare (ignore  _fmode))
		     (let ( (xval (km-unique x :fail-mode 'error))
			    (yval (km-unique y :fail-mode 'error)) )
		       (cond ((and (numberp xval) (numberp yval) (>= xval yval))
			      '#$(t))))) )

    ( (?x <= ?y) (lambda (_fmode x y)
		     (declare (ignore  _fmode))
		     (let ( (xval (km-unique x :fail-mode 'error))
			    (yval (km-unique y :fail-mode 'error)) )
		       (cond ((and (numberp xval) (numberp yval) (<= xval yval))
			      '#$(t))))) )

    ( (?x /= ?y) (lambda (fmode x y)
		      (cond ((not (equal (km x :fail-mode fmode)
					 (km y :fail-mode fmode)))
			     '#$(t)))) )

    ; ----------------------------------------

    ( (?x #$isa ?y) (lambda (fmode x y)
		       (let ( (xval (km-unique x :fail-mode fmode)) )
			 (cond ((atom y) (cond ((isa xval y) '#$(t))))		; Quick try first
			       ((isa xval (km-unique y :fail-mode fmode)) '#$(t))))) )

    ; ----------------------------------------

    ( (?x #$and &rest) (lambda (_fmode x y)
			    (declare (ignore  _fmode))
			    (and (km x :fail-mode 'fail)
				 (km y :fail-mode 'fail))) )

    ( (?x #$or &rest) (lambda (_fmode x y)
			 (declare (ignore  _fmode))
			 (or (and (not (on-km-stackp x))
				  (km x :fail-mode 'fail))
			     (km y :fail-mode 'fail))) )

    ( (#$not ?x) (lambda (_fmode x)
		      (declare (ignore  _fmode))
		      (cond ((not (km x :fail-mode 'fail)) '#$(t)))) )

    ( (#$numberp ?x) (lambda (_fmode x)
			  (declare (ignore  _fmode))
			  (cond ((numberp (km x :fail-mode 'fail)) '#$(t)))) )

;;; ======================================================================
;;;		SUBSUMPTION TESTING
;;; ======================================================================

;;; NEW
    ( (?x #$subsumes ?y) 
      (lambda (_fmode x y)
	   (declare (ignore  _fmode))
	   (let ( (yv (km y :fail-mode 'fail)) )
	     (cond ((null yv) '#$(t))
		   (t (let ( (xv (km x :fail-mode 'fail)) )
			(cond ((and (not (null xv))
				    (subsumes xv yv))
			       '#$(t)))))))))

    ( (?x #$covers ?y) 
      (lambda (_fmode x y)
	   (declare (ignore  _fmode))
	   (let ( (yv (km-unique y :fail-mode 'fail)) )
	     (cond ((null yv) '#$(t))
		   (t (let ( (xv (km x :fail-mode 'fail)) )
			(cond ((and (not (null xv))
				    (covers xv yv))
			       '#$(t)))))))))

    ( (?x #$is ?y) 
      (lambda (_fmode x y)
	   (declare (ignore  _fmode))
	   (let ( (xv (km-unique x :fail-mode 'fail)) )
	     (cond ((null xv) nil)
		   (t (let ( (yv (km-unique y :fail-mode 'fail)) )
			(cond ((and (not (null yv))
				    (is xv yv)) '#$(t)))))))))

;;; ======================================================================


#| KM1.4.0 - beta-11
    ( (?xs #$includes ?y) 
      (lambda (_fmode xs y)
	   (declare (ignore  _fmode))
	   (let ( (subsumed (find-if #'(lambda (x) (subsumes y x)) (km xs :fail-mode 'fail))) )
	     (cond (subsumed (list subsumed))))))
|#

;;; Redefine for KM1.4.0
    ( (?xs #$includes ?y) 
      (lambda (_fmode xs y)
	   (declare (ignore  _fmode))
	   (cond ((member (km-unique y) (km xs :fail-mode 'fail)) '#$(t)))))

    ( (?xs #$is-superset-of ?ys) 
      (lambda (_fmode xs ys)
	   (declare (ignore  _fmode))
	   (cond ((subsetp (km ys :fail-mode 'fail) (km xs :fail-mode 'fail)) '#$(t)))))

;;; ======================================================================
;;;		ALLOF/ONEOF etc.
;;; ======================================================================

;;; > (a man with (parts ((a arm) (a leg) (a arm))))
;;; _man1187
;;; > (allof ((_man1187 parts)) where (it isa arm))
;;; (_arm1188 _arm1190) 
    ( (#$allof ?set #$where ?test)	
      (lambda (fmode set test)
	   (km `(#$forall ,set #$where ,test (#$It)) :fail-mode fmode)))  ; equivalent

;;; New for KM1.4.0 beta-12    
    ( (#$allof ?set #$must ?test)	
      (lambda (fmode set test)
	(cond ((every #'(lambda (instance) 
			  (km (subst Instance '#$It test) :fail-mode 'fail)) 
		      (km set :fail-mode 'fail))
	       '#$(t)))))

;;; New for KM1.4.0 beta-18
    ( (#$allof ?set #$where ?test2 #$must ?test)	
      (lambda (fmode set test2 test)
	(cond ((every #'(lambda (instance) 
			  (km (subst Instance '#$It test) :fail-mode 'fail))
		      (km `#$(allof ,SET where ,TEST2) :fail-mode 'fail))
	       '#$(t)))))

    ( (#$oneof ?set #$where ?test)	
      (lambda (fmode set test)
	(let ( (answer (find-if #'(lambda (member)
				    (km (subst member '#$It test) :fail-mode 'fail))
				(km set :fail-mode 'fail))) )
	  (cond (answer (list answer))))) )

;;; New  1.4 - check to ensure there's a single value
    ( (#$theoneof ?set #$where ?test)	
      (lambda (fmode set test)
	   (let ( (val (km-unique `(#$forall ,set #$where ,test (#$It)) :fail-mode fmode)) )  ; equivalent
	     (cond (val (list val))))) )

    ( (#$forall ?set ?value)
      (lambda (fmode set value)
	   (km `(#$forall ,set #$where t ,value) :fail-mode fmode)))  ; equivalent

; not used any more
;    ( (#$forone ?set ?value)
;      (lambda (fmode set value)
;	   (km `(#$forone ,set #$where t ,value) :fail-mode fmode)))  ; equivalent
    
    ( (#$forall ?set #$where ?constraint ?value)
      (lambda (_fmode set constraint value)
	   (declare (ignore  _fmode))
	   (remove nil
	    (my-mapcan #'(lambda (member)
			   (cond ((km (subst member '#$It constraint) :fail-mode 'fail)
				  (km (subst member '#$It value) :fail-mode 'fail))))
		       (km set :fail-mode 'fail)))) )

;    ( (#$forone ?set #$where ?constraint ?value)
;      (lambda (_fmode set constraint value)
;	   (declare (ignore  _fmode))
;	   (some #'(lambda (member)
;		     (cond ((km (subst member '#$It constraint) :fail-mode 'fail)
;			    (km (subst member '#$It value) :fail-mode 'fail))))
;		 (km set :fail-mode 'fail))))

;;; To allow nesting, we also have forall2, whose referents are "it2"
    ( (#$allof2 ?set #$where ?test)	
      (lambda (fmode set test)
	   (km `(#$forall2 ,set #$where ,test (#$It2)) :fail-mode fmode)))  ; equivalent

;;; New for KM1.4.0 beta-12    
    ( (#$allof2 ?set #$must ?test)	
      (lambda (fmode set test)
	(cond ((every #'(lambda (instance) 
			  (km (subst Instance '#$It2 test) :fail-mode 'fail)) 
		      (km set :fail-mode 'fail))
	       '#$(t)))))

;;; New for KM1.4.0 beta-18
    ( (#$allof2 ?set #$where ?test2 #$must ?test)	
      (lambda (fmode set test2 test)
	(cond ((every #'(lambda (instance) 
			  (km (subst Instance '#$It2 test) :fail-mode 'fail))
		      (km `#$(allof2 ,SET where ,TEST2) :fail-mode 'fail))
	       '#$(t)))))

    ( (#$oneof2 ?set #$where ?test)	
      (lambda (fmode set test)
	(let ( (answer (find-if #'(lambda (member)
				    (km (subst member '#$It2 test) :fail-mode 'fail))
				(km set :fail-mode 'fail))) )
	  (cond (answer (list answer))))) )

    ( (#$forall2 ?set ?value)
      (lambda (fmode set value)
	   (km `(#$forall2 ,set #$where t ,value) :fail-mode fmode)))  ; equivalent

;    ( (#$forone2 ?set ?value)
;      (lambda (fmode set value)
;	   (km `(#$forone2 ,set #$where t ,value) :fail-mode fmode)))  ; equivalent
    
    ( (#$theoneof2 ?set #$where ?test)	
      (lambda (fmode set test)
	   (let ( (val (km-unique `(#$forall2 ,set #$where ,test (#$It2)) :fail-mode fmode)) )  ; equivalent
	     (cond (val (list val))))) )

    ( (#$forall2 ?set #$where ?constraint ?value)
      (lambda (_fmode set constraint value)
	   (declare (ignore  _fmode))
	   (remove 'nil
	    (my-mapcan #'(lambda (member)
			   (cond ((km (subst member '#$It2 constraint) :fail-mode 'fail)
				  (km (subst member '#$It2 value) :fail-mode 'fail))))
		       (km set :fail-mode 'fail)))) )

;    ( (#$forone2 ?set #$where ?constraint ?value)
;      (lambda (_fmode set constraint value)
;	   (declare (ignore  _fmode))
;	   (some #'(lambda (member)
;		     (cond ((km (subst member '#$It2 constraint) :fail-mode 'fail)
;			    (km (subst member '#$It2 value) :fail-mode 'fail))))
;		 (km set :fail-mode 'fail))))

;;; Given a function with zero arguments, KM will automatically evalute it.
    ( (function ?lispcode)		;;; NB NOT #$function, as we mean Lisp FUNCTION (#')
      (lambda (_fmode lispcode) 
	   (declare (ignore  _fmode))
	   (listify (funcall (eval (list 'function lispcode))))) )	; lispcode can return a val, or list of vals

;;; Redundant now - remove in later versions
;    ( (#$remove-dups ?expr)
;      (lambda (fmode expr)
;	(km expr :fail-mode fmode)) )

;;; ======================================================================
;;;		MULTIARGUMENT PREDICATES
;;; ======================================================================

;;; Shorthands
    ( (#$the1 ?slot #$of ?frameadd)  
      (lambda (fmode slot frameadd)
	(km `#$(the1 of (the ,SLOT of ,FRAMEADD)) :fail-mode fmode)) )

    ( (#$the2 ?slot #$of ?frameadd)  
      (lambda (fmode slot frameadd)
	(km `#$(the2 of (the ,SLOT of ,FRAMEADD)) :fail-mode fmode)) )

    ( (#$the3 ?slot #$of ?frameadd)  
      (lambda (fmode slot frameadd)
	(km `#$(the3 of (the ,SLOT of ,FRAMEADD)) :fail-mode fmode)) )

;;; ----------

;;; [1] New: tolerate (the1 of x), where x isn't structured
    ( (#$the1 #$of ?frameadd)  
      (lambda (fmode frameadd)
	(let ( (multiargs (km frameadd :fail-mode fmode)) )
	  (mapcar #'(lambda (multiarg)
		      (cond ((km-structured-list-valp multiarg) (arg1of multiarg))
			    (t multiarg)))							; [1]
		  multiargs))) )
;	  (cond ((every #'km-structured-list-valp multiargs) (mapcar #'arg1of multiargs))
;		(t (report-error 'user-error "~a! the1 expects multi-argument values for ~a, but got ~a instead!~%"
;				 `#$(the1 of ,FRAMEADD)  frameadd multiargs))))) )

    ( (#$the2 #$of ?frameadd)  
      (lambda (fmode frameadd)
	(let ( (multiargs (km frameadd :fail-mode fmode)) )
	  (mapcar #'(lambda (multiarg)
		      (cond ((km-structured-list-valp multiarg) (arg2of multiarg))))		; nil otherwise
		  multiargs))) )
;	  (cond ((every #'km-structured-list-valp multiargs) (mapcar #'arg2of multiargs))
;		(t (report-error 'user-error "~a! the2 expects multi-argument values for ~a, but got ~a instead!~%"
;				 `#$(the2 of ,FRAMEADD)  frameadd multiargs))))) )

    ( (#$the3 #$of ?frameadd)  
      (lambda (fmode frameadd)
	(let ( (multiargs (km frameadd :fail-mode fmode)) )
	  (mapcar #'(lambda (multiarg)
		      (cond ((km-structured-list-valp multiarg) (arg3of multiarg))))	; nil otherwise
		  multiargs))) )

;	  (cond ((every #'km-structured-list-valp multiargs) (mapcar #'arg3of multiargs))
;		(t (report-error 'user-error "~a! the3 expects multi-argument values for ~a, but got ~a instead!~%"
;				 `#$(the3 of ,FRAMEADD)  frameadd multiargs))))) )

    ( (#$theN ?nexpr #$of ?frameadd)  
      (lambda (fmode nexpr frameadd)
	(let ( (n (km-unique nexpr))
	       (multiargs (km frameadd :fail-mode fmode)) )
	  (cond ((or (not (integerp n))
		     (< n 1))
		 (report-error 'user-error "Doing ~a. ~a should evaluate to a non-negative integer!~%" `#$(the ,NEXPR of ,FRAMEADD) nexpr))
		(t (mapcar #'(lambda (multiarg)
			       (cond ((km-structured-list-valp multiarg) (elt multiarg n))
				     ((eq n 1) multiarg)))					; nil otherwise
			   multiargs))))) )

;	        ((every #'km-structured-list-valp multiargs) 
;		 (mapcar #'(lambda (seq) (and (< n (length seq)) 		; NB (:seq 1 2 3) has 3 (not 4) elements
;					      (elt seq n))) multiargs))
;		(t (report-error 'user-error "~a! theN expects multi-argument values for ~a, but got ~a instead!~%"
;			      `#$(the3 of ,FRAMEADD)  frameadd multiargs))))) )

;;; ======================================================================
;;;		ARITHMETIC
;;; ======================================================================

;;; Change default right-association precidence to left-association precedence, for
;;; cases where it makes a difference and appropriate:
   ( (?x ^ ?y ^ &rest) (lambda (fm x y rest) (km `((,x ^ ,y) ^ ,@rest) :fail-mode fm)) )
   ( (?x ^ ?y + &rest) (lambda (fm x y rest) (km `((,x ^ ,y) + ,@rest) :fail-mode fm)) )
   ( (?x ^ ?y - &rest) (lambda (fm x y rest) (km `((,x ^ ,y) - ,@rest) :fail-mode fm)) )
   ( (?x ^ ?y / &rest) (lambda (fm x y rest) (km `((,x ^ ,y) / ,@rest) :fail-mode fm)) )
   ( (?x ^ ?y * &rest) (lambda (fm x y rest) (km `((,x ^ ,y) * ,@rest) :fail-mode fm)) )

   ( (?x / ?y + &rest) (lambda (fm x y rest) (km `((,x / ,y) + ,@rest) :fail-mode fm)) )
   ( (?x / ?y - &rest) (lambda (fm x y rest) (km `((,x / ,y) - ,@rest) :fail-mode fm)) )
   ( (?x / ?y / &rest) (lambda (fm x y rest) (km `((,x / ,y) / ,@rest) :fail-mode fm)) )
   ( (?x / ?y * &rest) (lambda (fm x y rest) (km `((,x / ,y) * ,@rest) :fail-mode fm)) )

   ( (?x * ?y + &rest) (lambda (fm x y rest) (km `((,x * ,y) + ,@rest) :fail-mode fm)) )
   ( (?x * ?y - &rest) (lambda (fm x y rest) (km `((,x * ,y) - ,@rest) :fail-mode fm)) )
   ( (?x * ?y / &rest) (lambda (fm x y rest) (km `((,x * ,y) / ,@rest) :fail-mode fm)) )

   ( (?x - ?y - &rest) (lambda (fm x y rest) (km `((,x - ,y) - ,@rest) :fail-mode fm)) )
   ( (?x - ?y + &rest) (lambda (fm x y rest) (km `((,x - ,y) + ,@rest) :fail-mode fm)) )

   ( (?x + ?y - &rest) (lambda (fm x y rest) (km `((,x + ,y) - ,@rest) :fail-mode fm)) )

;;; ----------------------------------------

   ( (?expr + &rest) (lambda (fmode expr rest) 
			  (let ( (x (km-unique expr :fail-mode fmode)) 
				 (y (km-unique rest :fail-mode fmode)) )
			    (cond ((and (numberp x) (numberp y)) (list (+ x y)))))))
   ( (?expr - &rest) (lambda (fmode expr rest) 
			  (let ( (x (km-unique expr :fail-mode fmode)) 
				 (y (km-unique rest :fail-mode fmode)) )
			    (cond ((and (numberp x) (numberp y)) (list (- x y)))))))
   ( (?expr * &rest) (lambda (fmode expr rest) 
			  (let ( (x (km-unique expr :fail-mode fmode)) 
				 (y (km-unique rest :fail-mode fmode)) )
			    (cond ((and (numberp x) (numberp y)) (list (* x y)))))))
   ( (?expr / &rest) (lambda (fmode expr rest) 
			  (let ( (x (km-unique expr :fail-mode fmode)) 
				 (y (km-unique rest :fail-mode fmode)) )
			    (cond ((number-eq x 0) 0)
				  ((number-eq y 0) *infinity*)
			          ((and (numberp x) (numberp y)) (list (/ x y)))))))

   ( (?expr1 ^ ?expr2) (lambda (fmode expr1 expr2) 
			  (let ( (x (km-unique expr1 :fail-mode fmode)) 
				 (y (km-unique expr2 :fail-mode fmode)) )
			    (cond ((and (numberp x) (numberp y)) (list (expt x y)))))))

; shouldn't be needed now
;    ( #$:set
;      (lambda (_fmode) (declare (ignore _fmode)) nil) )

;;; also handled in faster mechanism directly in km0. Leave it here for completeness
    ( #$nil 
      (lambda (_fmode) (declare (ignore _fmode)) nil) )

    ( nil		; ie. NIL
      (lambda (_fmode) (declare (ignore _fmode)) nil) )

    ( (#$:set &rest)					; for :set, just remove :set tag to return a list
      (lambda (fmode exprs) 				; km will do the dereferencing and remove the duplicates later
	   (declare (ignore fmode))
	   (my-mapcan #'(lambda (expr) (km expr :fail-mode 'fail)) exprs)) )


    ( (#$:seq &rest)					; for :seq, build a one-element long structure
      (lambda (fmode exprs) 
	   (declare (ignore fmode))
	   (let ( (sequence (my-mapcan #'(lambda (expr)  (km expr :fail-mode 'fail)) exprs)) )
	     (cond (sequence `#$((:seq ,@SEQUENCE)))))) )

    ( (#$:args &rest)					; for :seq, build a one-element long structure
      (lambda (fmode exprs) 
	   (declare (ignore fmode))
	   (let ( (sequence (my-mapcan #'(lambda (expr)  (km expr :fail-mode 'fail)) exprs)) )
	     (cond (sequence `#$((:args ,@SEQUENCE)))))) )

    ( (#$:triple ?frame-expr ?slot-expr ?val-expr)
      (lambda (fmode frame-expr slot-expr val-expr)
	   (let ( (frame (km-unique frame-expr :fail-mode fmode))
		  (slot (km-unique slot-expr :fail-mode fmode)) 
		  (val (vals-to-val (km val-expr :fail-mode fmode))) )
	     (list (list #$:triple frame slot val)))) )

    ( (#$showme ?km-expr)
      (lambda (_fmode km-expr)
	   (declare (ignore _fmode))
	   (showme km-expr)) )

    ( (#$showme-all ?km-expr)
      (lambda (_fmode km-expr)
	   (declare (ignore _fmode))
	   (showme-all km-expr)) )

    ( (#$evaluate-all ?km-expr)
      (lambda (_fmode km-expr)
	   (declare (ignore _fmode))
	   (evaluate-all km-expr)) )

    ( (#$showme-here ?km-expr)
      (lambda (_fmode km-expr)
	   (declare (ignore _fmode))
	   (showme km-expr (list (curr-situation)))) )

    ( (quote ?expr)
       (lambda (fmode expr) 
	 (let ( (processed-expr (process-unquotes expr :fail-mode 'fail)) )
	   (cond (processed-expr (list (list 'quote processed-expr)))))) )

    ( (unquote ?expr)
       (lambda (fmode expr) 
	 (report-error 'user-error "Doing #,~a: You can't unquote something without it first being quoted!~%" expr)) )

;;; For Adam Farquhar - 12/9/98 now it *does* delete inverses
    ( (#$delete ?km-expr)
       (lambda (fmode km-expr)
	    (mapcar #'delete-frame (km km-expr :fail-mode fmode))) )

    ( (#$evaluate ?expr)		; Can't use eval, as that's a Lisp call!
       (lambda (fmode expr) 
	    (let ( (quoted-exprs (km expr :fail-mode fmode)) )
	      (remove nil
	      (my-mapcan #'(lambda (quoted-expr)
			  (cond ((member quoted-expr '#$(f F)) nil)
				((and (pairp quoted-expr)
				      (eq (first quoted-expr) 'quote))
				 (km (second quoted-expr) :fail-mode fmode))
				(t (report-error 'user-error 
						 "(evaluate ~a)~%evaluate should be given a quoted expression to evaluate!~%"
						 quoted-expr))))
		      quoted-exprs)))) )

    ( (#$exists ?frame)
      (lambda (fmode frame) 
	(report-error 'user-warning "(exists ~a): (exists <expr>) has been renamed (has-value <expr>) in KM 1.4.~%       Please update your KB! Continuing...~%" frame)
	(km `#$(has-value ,FRAME) :fail-mode fmode)) )

    ( (#$has-value ?frame)
      (lambda (_fmode frame) (declare (ignore  _fmode)) (km frame :fail-mode 'fail)) )

    ( (#$print ?expr)
      (lambda (_fmode expr) 
	(declare (ignore _fmode)) 
	(let ( (vals (km expr :fail-mode 'fail)) )
	  (km-format t "~a~%" vals)
	  vals )))

    ( (#$format ?flag ?string &rest)
      (lambda (_fmode flag string arguments) 
	(declare (ignore _fmode)) 
	(cond ((eq flag '#$t)
	       (apply #'format `(t ,string ,@(mapcar #'(lambda (arg) (km arg :fail-mode 'fail)) arguments)))
	      '#$(t))
	      ((member flag '#$(nil NIL))
	       (list (apply #'format `(nil ,string ,@(mapcar #'(lambda (arg) (km arg :fail-mode 'fail)) arguments)))))
	      (t (report-error 'user-error "~a: Second argument must be `t' or `nil', not `~a'!~%" 
			       `(#$format ,flag ,string ,@arguments) flag)))) )
	       
    ( (#$km-format ?flag ?string &rest)
      (lambda (_fmode flag string arguments) 
	(declare (ignore _fmode)) 
	(cond ((eq flag '#$t)
	       (apply #'km-format `(t ,string ,@(mapcar #'(lambda (arg) (km arg :fail-mode 'fail)) arguments)))
	      '#$(t))
	      ((member flag '#$(nil NIL))
	       (list (apply #'km-format `(nil ,string ,@(mapcar #'(lambda (arg) (km arg :fail-mode 'fail)) arguments)))))
	      (t (report-error 'user-error "~a: Second argument must be `t' or `nil', not `~a'!~%" 
			       `(#$km-format ,flag ,string ,@arguments) flag)))) )
	       
;    ( (tell (quote (?frame ?slot ?val)))
;      (lambda (_fmode frame slot val)
;	   (declare (ignore  _fmode))
;	   (set-val frame slot val)
;	   t) )

;;; (_car1) -> (_car1)
;;; (_car1 _car2) -> (_car1 "and" _car2)
;;; (_car1 _car2 _car3) -> (_car1 "," _car2 ", and" _car3)
    ( (#$andify ?expr)			
      (lambda (fmode expr) 
	(list (cons '#$:seq (andify (km expr :fail-mode fmode))))) )		; to avoid removing duplicate ", "s

; not used any more...
;    ( (#$expand-text ?expr)
;      (lambda (fmode expr) 
;	(let ( (expanded (expand-text (km expr :fail-mode fmode))) )
;	  (cond (expanded (list expanded))))) )

;;; [1] 6.9.00 - allow the subquery to fail quietly. The parent call can handle it as an error, if it so desires.
    ( (#$make-sentence ?expr)
      (lambda (_fmode expr)
	   (declare (ignore _fmode))
;	   (let ( (text (km expr)) )		; should now return one or more sequences ((:seq "Print" ..) (:seq ...))
#|[1]|#	   (let ( (text (km expr :fail-mode 'fail)) )		; should now return zero or more sequences ((:seq "Print" ..) (:seq ...))
	     (make-comment (km-format nil "anglifying ~a" text))	; show the user the original
	     (list (make-sentence text)))) )					; return the concatenation
;	     (mapcar #'make-sentence text))) )	; return the concatenation

    ( (#$make-phrase ?expr)			; This version *doesn't* capitalize
      (lambda (_fmode expr)
	   (declare (ignore _fmode))
	   (let ( (text (km expr :fail-mode 'fail)) )	; should now return zero or more sequences ((:seq "Print" ..) (:seq ...))
	     (make-comment (km-format nil "anglifying ~a" text))	; show the user the original
	     (list (make-phrase text)))) )
;	     (mapcar #'(lambda (item)
;			 (make-phrase item))
;		     text))) )			; return the concatenation

    ( (#$pluralize ?expr)
      (lambda (fmode expr)
	(report-error 'user-error 
		      "(pluralize ~a): pluralize is no longer defined in KM1.4 - use \"-s\" suffix instead!~%" expr)) )

;;; ======================================================================

    ( (#$an #$instance #$of &rest)
      (lambda (_fmode rest)
	   (declare (ignore  _fmode))
	   (mapcar #'create-instance (km rest :fail-mode 'fail))))

; Experimental: Make the mapping explicit.
;    ( (#$import ?expr)
;      (lambda (_fmode expr)
;	   (declare (ignore  _fmode))
;	   (let* ( (theory (km expr))
;		   (source-file (km `#$(the source-file of ,THEORY)))
;		   (base-symbols (km `#$(the named of (the morphism of ,THEORY))))
;		   (target-symbols (km `#$(the refers-to of (the morphism of ,THEORY))))
;		   (mapping-table (transpose (list target-symbols
;						   (duplicate '<- (length base-symbols))
;						   base-symbols))) )
;	     (make-comment (km-format nil "Doing ~a" `(load-kb ,source-file :with-morphism ,mapping-table)))
;	     (load-kb source-file :with-morphism mapping-table))) )

    ( (#$reverse ?seq-expr)
      (lambda (fmode seq-expr)
	(let ( (seq (km-unique seq-expr :fail-mode fmode)) )
	  (cond ((null seq) nil)
		((km-seqp seq)
		 (list (cons '#$:seq (reverse (rest seq)))))
		(t (report-error 'user-error 
				 "Attempting to reverse a non-sequence ~a!~%[Sequences should be of the form (:seq <e1> ... <en>)]~%" 
				 seq-expr))))))

;;; [1] below: NEW: Here make another top level call, so 
;;;	(i) the trace is easier to follow during debugging
;;;	(ii) the looping checker jumps in at the right moment

    ( ?path
      (lambda (fmode0 path)
	   (cond ((atom path) 					; An instance/class evaluates to itself
                  (cond						; (This case is duplicated in km0 for efficiency)
		        ((no-reserved-keywords (list path)) 	; else no-reserved-keywords prints error
			 (list path))))
		 ((not (listp path))
		  (report-error 'program-error "Failed to find km handler for ~a!~%" path))
		 ((not (no-reserved-keywords path)) nil)	; ie. check that there are no reserved keywords
		 ((singletonp path) (km (car path) :fail-mode fmode0))
		 ((oddp (length path))      ; ODDP case: (last-el path) is a class, which filters the values
		  (cond ((structured-slotp (last-el (butlast path)))
			 (follow-multidepth-path 				        ; QUOTED PATH
			     (km (butlast (butlast path)) :fail-mode fmode0)    ; start-values
			     (last-el (butlast path))			        ; slot
			     (last-el path)				        ; target-class
			     :fail-mode fmode0))
			(t (vals-in-class (km (butlast path) :fail-mode fmode0) ; REGULAR PATH
					  (last-el path)))))
		 ((evenp (length path))     ; EVENP case: (last-el path) is a slot, which generates values
		  (let* ( (frameadd (cond ((pairp path) (first path))		; (f s) -> f
					  (t (butlast path))))			; (f s f' s') -> (f s f')
			  (slot (last-el path)) )
		    (cond ((structured-slotp slot)
			   (follow-multidepth-path (km frameadd :fail-mode fmode0) 
					       slot '* :fail-mode fmode0))   ; target-class = *
			  (t (let* ( (fmode (cond ((built-in-aggregation-slot slot) 'fail)
						  (t fmode0))) 
				     (frames (km frameadd :fail-mode fmode)) )
			       (cond ((not (equal frames (val-to-vals frameadd)))
				      (km `#$(,(VALS-TO-VAL FRAMES) ,SLOT) :fail-mode fmode))	; [1]
				     (t (km-multi-slotvals frames slot :fail-mode fmode)))))))))) )

    )
  )

;;; ======================================================================
;;;		QUOTED PATHS eg.  (Delta owns Plane (part *) Wing) 
;;;
;;; a quoted path is of form: 
;;;		(...... <slot-structure> <target-class>)
;;; where <slot-structure> is of the form 
;;;		(<slot> *)
;;;   or 	(<slot> * <depth-limit>)
;;; ======================================================================

;;; here path is necessarily an ODD length, thus the last element is a target CLASS.
(defun structured-slotp (slot) 
  (and (listp slot) (eq (second slot) '*)))

(defun follow-multidepth-path (values structured-slot target-class &key (fail-mode 'error))
  (let ( (slot (first structured-slot))
	 (depth-limit (or (third structured-slot) *multidepth-path-default-searchdepth*)) )
    (cond ((null values) nil)
	  ((not (integerp depth-limit))
	   (report-error 'user-error "Non-integer depth ~a given for slot-structure ~a in quoted path!~%" 
			 depth-limit structured-slot))
	  ((< depth-limit 1)
	   (report-error 'user-error "Depth ~a given for slot-structure ~a in quoted path must be >= 1!~%" 
			 depth-limit structured-slot))
	  (t (km (vals-to-val (multidepth-path-expr (vals-to-val values) slot target-class depth-limit))
		 :fail-mode fail-mode)))))

(defun multidepth-path-expr (path slot target-class depth-limit)
  (cond ((<= depth-limit 0) nil)
	((neq target-class '*)
	 (cons `#$(the ,TARGET-CLASS ,SLOT of ,PATH)
	       (multidepth-path-expr `#$(the ,SLOT of ,PATH) slot target-class (1- depth-limit))))
	(t (cons `#$(the ,SLOT of ,PATH)
		 (multidepth-path-expr `#$(the ,SLOT of ,PATH) slot target-class (1- depth-limit))))))
  
;;; ======================================================================
;;;		ACCESS TO THE KNOWLEDGE-BASE
;;; These functions make the bridge between km expressions (see
;;; *km-handler-alist* below) and the KB access function get-global.
;;; ======================================================================

;;; ---------------------------------------
;;;   1. The basic routine for getting slot values is km-multi-slotvals.
;;;	 It is given a *list* of frames, and gets their values.
;;; ----------------------------------------

;;; (km-multi-slotvals frames slot):
;;; frames will always be a list.
;;; Find and concatenate the vals of slot for frames.
;;; MUST return a *list* of values.  <- ?? Oct 97: No!
;;; Some special handling for slots like "sum" etc. which instead of
;;; 	looking up values of frames they *sum* the frames (which of
;;; 	course must thus be numbers)
(defun km-multi-slotvals (frames0 slot &key (fail-mode 'error))
  (declare (ignore fail-mode))
  (let ( (frames (mapcar #'dereference frames0)) )
    (cond ((no-reserved-keywords frames)		; check for syntax errors
	   (km-multi-slotvals0 frames slot)))))

;;; Returns a *LIST* of values   ((car) && (joe bad xd))
(defun km-multi-slotvals0 (frames slot)   
  (cond 
   ((not (check-isa-slot-object slot)) nil)
   ((and (eq slot '#$number) (null frames)) '(0))
;  ((null frames) nil)		No! Let aggregation of zero items continue
   (t (case slot
	(#$sum (aggregate-vals #'+ frames))
	(#$min (aggregate-vals #'min frames))
	(#$max (aggregate-vals #'max frames))
	(#$unification (km (val-sets-to-expr (mapcar #'list frames) t) :fail-mode 'fail))	; t = single-valuedp
	(#$set-unification (km (val-sets-to-expr (mapcar #'list frames)) :fail-mode 'fail))	; less aggressive; not really getting sets
	(#$first (list (first frames)))
	(#$second (list (second frames)))
	(#$third (list (third frames)))
	(#$fourth (list (fourth frames)))
	(#$fifth (list (fifth frames)))
;	(#$sixth (list (sixth frames)))
;	(#$seventh (list (seventh frames)))
;	(#$eighth (list (eighth frames)))
;	(#$ninth (list (ninth frames)))
;	(#$tenth (list (tenth frames)))
	(#$last (last frames)) 
	(#$average (cond ((and (every #'numberp frames)
			       (not (null frames)))
			  (list (/ (aggregate-vals #'+ frames) (length frames))))
			 (t (km '#$(a Number)))))
	(#$difference (aggregate-vals #'- frames))
	(#$product (aggregate-vals #'* frames))
	(#$quotient (aggregate-vals #'/ frames))
	(#$number (list (length frames)))
#|
	(#$name (let 		; convert a *list* of frames into a single string. (name *must* return a single string)
		    ( (frame-names (my-mapcan #'(lambda (el) 
						  (let ( (stringlist (km-slotvals el '#$name :fail-mode 'fail)) )
						    (cond ((null stringlist) nil)
							  ((and (singletonp stringlist)
								(stringp (first stringlist)) stringlist))
							  (t (report-error 'user-error
						 "(the name of ~a) must be a string! (was ~a)~%(Perhaps you should use `make-phrase'?) Ignoring it...~%" 
									   el stringlist)))))
					      frames)) )
		  (cond (frame-names (list (concat-list (andify frame-names)))))))
|#
	(t (cond 
	    ((isa slot '#$Aggregation-Slot)
	     (let ( (quoted-function-name (km-unique `#$(the aggregation-function of ,SLOT) :fail-mode 'fail)) )
	       (cond 
		((not quoted-function-name)
		 (report-error 'user-error "No aggregation-function definition given for the Aggregation-Slot ~a!~%" slot))
		((not (quotep quoted-function-name))
		 (report-error 'user-error 
			   "Function definition for Aggregation-Slot ~a should be a~%quoted function (eg. \"(sum has (aggregation-function ('#'+)))\"~%"
			   slot))
		(t (let ( (function (eval (second quoted-function-name))) )
		     (cond 
		      ((not (functionp function))
		       (report-error 'user-error
			     "Function definition for Aggregation-Slot ~a should be~%a function! (eg. \"(sum has (aggregation-function ('#'+)))\"~%" 
			     slot))
		      (t (list (apply function (list frames))))))))))
	    ((null frames) nil)
	    ((singletonp frames) (km-slotvals (first frames) slot :fail-mode 'fail))
	    (t (my-mapcan 				 ; Deduping and dereferencing done later
		#'(lambda (frame)
;;; OLD		    (km-slotvals frame slot :fail-mode 'fail))
#|NEW|#		    (km `#$(the ,SLOT of ,FRAME) :fail-mode 'fail)) ; NEW: Route via top-level KM call for clarity during tracing
		frames))))))))				       ; by end of top-level km fn

(defun aggregate-vals (function vals)
  (cond ((and (null vals) (not (eq function #'+))) (km '#$(a Number)))	; just for #'+, allow zero arguments.
	((every #'numberp vals) (list (apply function vals)))
	(t (km '#$(a Number)))))

;;; ---------------------------------------
;;;   2. The auxiliary routine for getting the value of a slot is km-slotvals,
;;;	 which gets the slot values on a single frame. This is only used by
;;;	 kulti-slotvals.
;;; ----------------------------------------

;;; (km-slotvals frame slot)
;;;   - slot is atomic. Frame may be a kb-instance (including (:set ...) (:triple ...)) or a string or number
;;;   - return the evaluated *list* of values for the slot of frame.
;;; NOTE: frame is already assumed to be dereferenced (using dereference)
;;;     before this procedure is called. 
;;; This procedure first filters special cases, then calls km-slotvals-from-kb
;;;	for handling standard queries.
(defun km-slotvals (frame slot &key (fail-mode 'error))
  (cond ((null frame) nil)
	((km-triplep frame)			 ; special handling for triples, eg.
	 (case slot 				 ; (the name of (:triple *john wants *cash))
	       (#$name  (list (name frame)))  	 ; returns "john wants cash"
	       (#$frame (list (second frame)))	 ; (the frame of <frame>)
	       (#$slot  (list (third frame)))	 ; (the  slot of <frame>)
	       (#$value (val-to-vals (fourth frame)))
	       (t       (report-error 'user-error "I don't know how to take the ~a of a triple ~a!~%" slot frame))))
#|	((and (eq slot '#$name) (km-seqp frame))	       ; convert a sequence into a string
	 (list (concat-list 
		(andify (my-mapcan #'(lambda (el) 
				       (let ( (stringlist (km `#$(the name of ,EL) :fail-mode 'fail)) )
					 (cond ((and (singletonp stringlist)
						     (stringp (first stringlist)) stringlist))
					       (t (report-error 'user-error 
						"(the name of ~a) must be a string! (was ~a)~%(Perhaps you should use `make-phrase'?) Ignoring it...~%"
						                el stringlist)))))
				   (rest frame))))))
|#      ((km-argsp frame)						; (the age of (:args Pete Clark)) -> (the age of Pete)
	 (km `#$(the ,SLOT of ,(SECOND FRAME)) :fail-mode fail-mode))	
	((eq slot '#$elements)
	 (cond ((not (km-structured-list-valp frame))
		(report-error 'user-error "Trying to find the elements of a non-structured value ~a!~%Continuing, returning (~a)...~%" frame frame)
		(list frame))
	       (t (rest frame))))			; strip :seq off
	((km-seqp frame)
	 (list (cons '#$:seq (my-mapcan #'(lambda (el) 
					    (km `#$(the ,SLOT of ,EL) :fail-mode fail-mode)) 
					(rest frame)))))
	((class-descriptionp frame :fail-mode 'fail)			; eg. '(every Dog)
	 (case slot
	       (#$instance-of '#$(Class))
	       (#$superclasses (list (first (minimatch frame ''#$(every ?class &REST)))))
	       (t (report-error 'user-error "Sorry! I don't know how to compute the ~a of the class ~a!~%" frame slot))))
	((listp frame)
	 (report-error 'user-error "Trying to get a slot value of a list of frames,~%rather than a single frame. slot: ~a. frame: ~a.~%" slot frame))
	((case slot
	       (#$abs   (list (cond ((numberp frame)   (abs frame)) (t frame))))
	       (#$log   (list (cond ((numberp frame)   (log frame)) (t frame))))
	       (#$exp   (list (cond ((numberp frame)   (exp frame)) (t frame))))
	       (#$sqrt  (list (cond ((numberp frame)  (sqrt frame)) (t frame))))
	       (#$floor (list (cond ((numberp frame) (floor frame)) (t frame))))))
	((and (not (kb-objectp frame)) (eq slot '#$name)) (list (name frame)))
;	((member slot '#$(superclasses supersituations)) ; For these slots...
;	 (find-vals frame slot))		; do a fast get (ascending situation tree only if necessary)
	((eq slot '#$instance-of)	  (immediate-classes frame))
	((eq slot '#$classes)             (immediate-classes frame))	; approx a synonym for instance-of
	((eq slot '#$superclasses)        (immediate-superclasses frame))
	((eq slot '#$supersituations)     (immediate-supersituations frame))
	((eq slot '#$all-instances)       (all-instances frame))
	((eq slot '#$all-prototypes)      (all-prototypes frame))
	((eq slot '#$all-classes)         (all-classes frame))
	((eq slot '#$all-superclasses)    (all-superclasses frame))
	((eq slot '#$all-subclasses)      (all-subclasses frame))
	((eq slot '#$all-supersituations) (all-supersituations frame))
	((eq slot '#$all-subslots)        (all-subslots frame))
	((and (eq slot '#$instances) 	; Optimize for subclasses of Situation, Slot, Partition
	      (fluentp '#$instances)
	      (some #'(lambda (class) (is-subclass-of frame class)) *built-in-classes-with-nonfluent-instances-relation*))   ; i.e. (Situation Slot Partition)
;slow	 (km `#$(in-situation ,*GLOBAL-SITUATION* (the instances of ,FRAME)) :fail-mode 'fail))
#|fast|# (let ( (answer (get-vals frame '#$instances 'own-properties *global-situation*)) )
	   (cond ((eq frame '#$Situation) (cons *global-situation* answer))
		 (t answer))))
	((and (eq slot '#$instances)
	      (neq frame '#$Situation)
	      (inv-assoc frame (built-in-instance-of-links)))	  	; e.g. Boolean -> {t,f}
	 (mapcan #'(lambda (instance+class) (cond ((eq (second instance+class) frame) (list (first instance+class))))) (built-in-instance-of-links)))
	((and (already-done frame slot)		; Already done! So just retrieve cached value...
	      (let ( (values (remove-constraints (get-vals frame slot))) )
		(cond ((notany #'fluent-instancep values)	 ;;; UNLESS you've fluent-instances (in which case you should recompute)
		       (km-trace 'comment "(Retrieving answer computed and cached earlier:")
		       (km-trace 'comment " (the ~a of ~a) = ~a))" slot frame values)
;		       (km-format t "PEC (Retrieving answer computed and cached earlier:~%")
;		       (km-format t "PEC (the ~a of ~a) = ~a))" slot frame values)
		       values)))))
#| Below was uncommented, but I think I *do* want this, to prevent a global rule on an instance's slot being clobbered
   by computing a NIL value for that slot in the global situation. |#
	((and (situation-specificp slot) (am-in-global-situation)) 
;	 (report-error 'user-warning "Ignoring attempt to compute (the ~a of ~a), whose value is situation-specific, in the global situation.~%"
;				       slot frame))
	 (km-trace 'comment "Ignoring attempt to compute (the ~a of ~a), whose value is situation-specific, in the global situation."
		   slot frame))
;; Yikes!! This looks right but isn't: Although the *result* should be stored globally, the *computation* should be done in the local situation,
;; as it may require other (constant) local values which haven't been asserted in the global situation.
;;	((and (not (fluentp slot)) (am-in-local-situation))
;;	 (km `#$(in-situation ,*GLOBAL-SITUATION* (the ,SLOT of ,FRAME)) :fail-mode fail-mode))
	((and (kb-objectp frame) (km-slotvals-from-kb frame slot :fail-mode fail-mode)))
	((eq slot '#$name)				; failed to compute it so generate it
	 (let ( (name (name frame)) )
	   (cond (name (put-vals frame slot (list name) :install-inversesp nil)
		       (list name)))))
	((not (kb-objectp frame))
	 (report-error 'user-error "(the ~a of ~a): Attempt to find a property of a non-kb-object ~a!~%" slot frame frame))))

;;; ======================================================================
;;;		GENERAL UTILITIES
;;; ======================================================================

(defun remove-dups (expr &optional &key (fail-mode 'error))
  (remove-dup-instances (km expr :fail-mode fail-mode)))

;;; (vals-in-class vals class): Return only those vals which are in class.
(defun vals-in-class (vals class)
  (cond ((eq class '*) vals)
	(t (remove-if-not #'(lambda (val) (isa val class)) vals))))

(defun no-reserved-keywords (vals)
  (cond ((not (intersection vals *reserved-keywords*)))
	(t (report-error 'user-error 
"Keyword(s) ~a found where concept name(s) were expected, within a
list of ~a KM expressions: ~a
(Error = missing parentheses?)~%"
			 (concat-list (commaify (mapcar #'princ-to-string (intersection vals *reserved-keywords*))))
;			 (mapcar #'list (intersection vals *reserved-keywords*))
		         (length vals)
                         (concat-list (commaify (mapcar #'princ-to-string vals)))))))
;                         (mapcar #'list vals)))))

;;; ======================================================================
;;;		Evaluate unquoted bits in a quoted expression:
;;; ======================================================================

;;; RETURNS a *single* km value (including possibly a (:set ...) expression)
(defun process-unquotes (expr &key (fail-mode 'fail))
  (cond ((null expr) nil)
	((not (listp expr)) expr)
	((eq (first expr) 'unquote)
	 (cond ((not (pairp expr))
		(report-error 'user-error "Unquoted structure ~a should be a pair!~%" expr))
	       (t (vals-to-val (km (second expr) :fail-mode fail-mode)))))
	(t (cons (process-unquotes (first expr))
		 (process-unquotes (rest expr))))))


;;; FILE:  get-slotvals.lisp

;;; File: get-slotvals.lisp
;;; Author: Peter Clark
;;; Date: Separated out April 1999
;;; Purpose: Basic searching for the value of a slot

;;; ----------
;;; Control use of inheritance...
;(defparameter *use-inheritance* t)		; moved to header.lisp

(defun use-inheritance ()
  (and *use-inheritance*
       (not (am-in-prototype-mode))))			; no inheritance within prototype mode
;;; ----------

#|
The length and ugliness of the below code is mainly due to the desire to
put in good tracing facilities for the user, rather than the get-slotvals
procedure being intrinsically complicated.

There are five sources of information for finding a slot's value:

  1. PROJECTION: from the previous situation
  2. SUBSLOTS: find values in the slot's subslots.
  3. SUPERSITUATIONS: Import value(s) from the current situation's supersituations.
  4. LOCAL VALUES: currently on the slot
  5. INHERITANCE: inherit rules from the instance's classes.

There are two caveats:
  1. We want to make an intermediate save of the results of 1-4 before adding in 5,
	to avoid a special case of looping during subsumption checks.
  2. If the slot is single-valued, then the projected value (1) should not be 
	automatically combined in. Instead, (2-5) should first be computed, then
 	if (1) is consistent with the combination of (2-5), it should be then unified 
	in, otherwise discarded.
     The procedure which handles this special case of projection is maybe-project-value.

----------------------------------------

The procedure was rewritten in April 99 to show more clearly to the user what KM
was doing during the trace, although it makes the actual source code less clear (perhaps?).
|#

;;; ======================================================================
		     
(defun km-slotvals-from-kb (instance slot &key fail-mode &aux (n 0))	; n for tracing purposes
 (declare (ignore fail-mode))

;;; Do some up-front classification...
; (cond ((and *classification-enabled* *are-some-definitions*)
;	(new-classify0 instance slot)))
								; PRELIMINARIES
  (let* ( (single-valuedp (single-valued-slotp slot))		; (i) get the slot type
	  (multivaluedp (not single-valuedp))

	  (rule-sets0 (cond ((use-inheritance) (bind-self (collect-rule-sets instance slot) instance))))     ; 2D search up classes and sitns
	  (rule-constraints (mapcan #'find-constraints-in-exprs rule-sets0))		     ; from classes
	  (instance-expr-sets (bind-self (collect-instance-expr-sets instance slot) instance))
	  (instance-constraints (mapcan #'find-constraints-in-exprs instance-expr-sets))     ; from instance in curr-situation AND its supersituations
	  (constraints (append rule-constraints instance-constraints))

;;; ---------- 1. PROJECTION ----------
;;; [1] NB subslots of prev-situation used for hypothetical reasoning

	  (try-projectionp (and (am-in-local-situation)
				(projectable slot instance)
				(prev-situation (curr-situation))))
  	  (projected-vals0 (cond (try-projectionp
				  (cond ((tracep)
					 (setq n (1+ n))
					 (km-trace 'comment "(~a) Look in previous situation" n)))
				  (km-slotvals-via-projection instance slot))))

	  (projected-vals (cond ((and constraints projected-vals0)
				    (cond ((and (tracep) (not (traceunifyp)))
					   (prog2 (suspend-trace) (filter-using-constraints projected-vals0 constraints) (unsuspend-trace)))
					  (t (km-trace 'comment "(~ab) Test projected values against constraints ~a" n constraints)
					     (filter-using-constraints projected-vals0 constraints))))
				(t projected-vals0)))

	  (_project1-dummy (cond ((and (tracep)
				       try-projectionp
				       (not (equal projected-vals0 projected-vals))
				       (km-trace 'comment "    Discarding projected values ~a (conflicts with constraints ~a)"
						 (set-difference projected-vals0 projected-vals) constraints)))))
	  (_project2-dummy (cond ((and projected-vals 
				       multivaluedp)		; projection may fail later for single-valued slots (see maybe-project-val below)
				  (let ( (prev-situation (prev-situation (curr-situation))) )
				    (make-comment (km-format nil "Projected (the ~a of ~a) = ~a from ~a to ~a"
							     slot instance projected-vals prev-situation (curr-situation)))))))

;;; ---------- 2. SUBSLOTS ----------

	  (subslots (immediate-subslots slot))
	  (subslot-vals (cond (subslots
			       (cond ((tracep)
				      (setq n (1+ n))
				      (km-trace 'comment "(~a) Look in subslot(s)" n)))
; No! Sibling vals shouldn't unify!
; 			       (km (val-sets-to-expr
;				    (mapcar #'(lambda (subslot) `#$((the ,SUBSLOT of ,INSTANCE))) subslots)
;				    single-valuedp)
#|Correct|#		       (km (vals-to-val
				    (mapcar #'(lambda (subslot) `#$(the ,SUBSLOT of ,INSTANCE)) subslots))
				   :fail-mode 'fail))))

;;; ---------- 3. SUPERSITUATIONS ----------

#|
[1] For non-fluents, although we ensure that values of slot will be stored in
*Global (by put-slotvals in frame-io.lisp), we must also ensure that any direct *side effects*
during the computation are *also* stored in *Global. This is because all the expr sets 
necessarily came from *Global in the first place, but we (below) skip doing the computation
in *Global by default for non-fluents.
[Note we don't *only* do the computation in *Global, as the local situation alone may have the
 extra information we need to compute the slot's values.]
The only side-effect I can think of is *instance creation* (with the side-effect of asserting
an instance-of link). So we check for the presence of this in the exprs (which necessarily
all come from *Global, as the slot is a non fluent).
Note indirect side-effects will be handled automatically by a recursive call to KM.
|#
;;; [2] If the slot's a fluent, then we should apply the rules in the global situation to
;;;     make sure the global situation gets updated.
;;;     If it isn't, then we don't need to bother as the result will be posted back to
;;;     the global situation anyway. We collect the "global values" and "global rules" 
;;;     later on and apply them locally here. *EXCEPT* for Events -- where we might not
;;;     apply the global rules locally (if the action's not been carried out yet). 
;;;   QN: What about unactualized actions, where we want to test preconditions? We may
;;;       want to apply global rules to local data to find the action's slot-values, but
;;;	  we block this later at [**]. So we'll miss some info.
;;;     For Events, although their slots are non-fluents, we still might want to collect
;;; blocked, so in this special case we must look up 
	  (supersituations0 (immediate-supersituations (curr-situation)))
	  (supersituations (cond ((and supersituations0
				       (situation-specificp slot))
				  (remove *global-situation* supersituations0))
				 (t supersituations0)))
	  (supersituation-vals (cond ((and supersituations 
					   (or (fluentp slot)	; If the slot isn't a fluent, then supersituations won't contribute anything
					       (isa instance '#$Event)	; [2]
					       (contains-some-existential-exprs rule-sets0)
					       (contains-some-existential-exprs instance-expr-sets)))
				      (cond ((tracep)
					     (setq n (1+ n))
					     (km-trace 'comment "(~a) Look in supersituation(s)" n)))
				      (remove-fluent-instances
				       (km (val-sets-to-expr
					   (mapcar #'(lambda (sitn) `#$((in-situation ,SITN (the ,SLOT of ,INSTANCE))))
						   supersituations)
					   single-valuedp)
					  :fail-mode 'fail)))))


;;; ---------- 3 1/2. PROTOTYPES (EXPERIMENTAL) ----------

#| Merge in relevant prototypes. Then in step 4, the local values will find the merged-in prototype values. |#

	  (_clones-dummy (cond ((and *are-some-prototypes*
				     (not (member slot *slots-not-to-clone-for*))
;				     (not (am-in-prototype-mode))			; NEW: DISABLE cloning when in prototype mode
				     (use-inheritance)
				     (not (prototypep instance)))			; NEW: Don't clone a prototype onto another prototype!
				(unify-in-prototypes instance slot))))

;;; ---------- 4. LOCAL VALUES ----------

	  (local-vals-exprs (let ( (local-situation (cond ((fluentp slot) (curr-situation))
						  (t *global-situation*))) )
			      (bind-self
			       (or (get-vals instance slot 'own-properties local-situation)     ; This disjunct should be in get-vals-
				   (get-vals instance slot 'own-definition local-situation))    ; in-situation, not here,+ should be conj!
			       instance)))
	  (local-vals (cond (local-vals-exprs
			      (cond ((tracep)				 ;     val, eg. from lazy unification)
				     (setq n (1+ n))
				     (km-trace 'comment "(~a) Local value(s): ~a" n (vals-to-val local-vals-exprs))))
			      (cond ((and (singletonp local-vals-exprs)			 ; (a) no evaluation necessary
					  (atom (first local-vals-exprs))
					  (eq (dereference (first local-vals-exprs)) (first local-vals-exprs)))
				     local-vals-exprs)
				    (t 				 ; (b) some evaluation necesary (eg. path in local slot)
				     (km (vals-to-val local-vals-exprs) :fail-mode 'fail))))))

;;; ---------- 5. INHERIT RULES FROM CLASSES ----------

;;; [1] Special case: Normally we don't pass rules on instances down the situation hierarchy -- rather, we evaluate
;;; them in their home situation, and pass the *result* down the situation hierarchy (see 3. SUPERSITUATIONS later).
;;; However, a special case is for situation-specific rules, whose value will *vary* depending on the situation. 
;;; As a result, we must pass down the rules, not their evaluations, and then evaluate them locally. We do this here.
;;; We assume all situation-specific rules are authored in the global situation, not some intermediate supersituation.

;;; Computed earlier
;;;	  (rule-sets0 (bind-self (collect-rule-sets instance slot) instance))     ; 2D search up classes and situations trees
	  (rule-sets00 (cond ((situation-specificp slot)			 ; [1]
			    (let ( (global-exprset-on-instance (get-vals instance slot 'own-properties *global-situation*)) )
			      (cond (global-exprset-on-instance (cons (bind-self global-exprset-on-instance instance) rule-sets0))
				    (t rule-sets0))))
			   (t rule-sets0)))
	  (rule-sets (cond ((and rule-sets00
				 (am-in-local-situation)
				 (isa instance '#$Event)    ; [**]
                                 (neq slot '#$is-possible) ;; KANAL: hack for precondition test!
				 (neq (curr-situation) (before-situation instance)))
			    (cond ((null (before-situation instance))
;;(format *terminal-io* "rule-sets00:~S~%" rule-sets00)
				   (km-trace 'comment "(Don't re-evaluate inherited rules ~a for ~a in this situation,~%   as I don't know if this is the situation where this event will occur!)" 
					     (val-sets-to-expr rule-sets00 single-valuedp) instance))
				  (t (km-trace 'comment "(Don't re-evaluate inherited rules~%        ~a~%        for ~a in the current situation ~a,~%        as this event wasn't done in this situation (was done in ~a instead)!)"
					       (val-sets-to-expr rule-sets00 single-valuedp) instance (curr-situation)
					       (before-situation instance))))
			    nil)
			   (t rule-sets00)))

; for debugging  (_d (km-format t "rule-sets = ~a, rule-sets0 = ~a~%" rule-sets rule-sets0))
	  (_rule-sets-dummy (cond ((not (use-inheritance)) (km-trace 'comment "(No inherited rules (Inheritance is turned off))"))
				  ((and (tracep)
					rule-sets)
				   (setq n (1+ n))
				   (cond ((inherit-with-overrides-slotp slot)
					  (km-trace 'comment "(~a) Lowest rules, from inheritance with over-rides: ~a" 
						    n (val-sets-to-expr rule-sets single-valuedp)))
					 (t (km-trace 'comment "(~a) From inheritance: ~a" n (val-sets-to-expr rule-sets single-valuedp)))))))

;;; ---------- (1 or 2)-4. INTERMEDIATE COMBINE AND SAVE OF VALS (but not rules) ----------

#| SPECIAL CASE: Storing intermediate result.
   Now we store the intermediate result, in case when applying the rules we need to see 
   what we've got so far. [Case in point: _Engine23 from supersituation, (a Engine with 
   (connects ((the parts of ...)))) from classes, and if we fail to show (a Engine.. ) 
   subsumes _Engine23 due to subsumption check, we still want to assert _Engine23].

;;; [1] projecting a single-valued slot is done *later*
|#

	  (n-first-source (cond ((and try-projectionp single-valuedp) 2) (t 1)))   ; [1]
	  (n-sources (length 
		      (remove nil 
			      (list try-projectionp subslots supersituations local-vals-exprs rule-sets))))
	  (val-sets (remove-duplicates
		     (remove nil `(,(cond (multivaluedp projected-vals))  ; val-sets *EXCLUDES* rule-sets
				   ,subslot-vals		
				   ,supersituation-vals
				   ,local-vals))
;				   ,@cloned-valsets))		; now merged in at set 3 1/2
		     :test #'equal))

;	  (_dummy4 (km-format t "DEBUG: val-sets = ~a~%" val-sets))

;;; POSSIBLY WANT CONSTRAINT CHECKING HERE TOO (TO AVOID INTERMEDIATE INCORRECT SAVE)

	  (vals (cond ((null val-sets) nil)		  	      ; NO val sets found
		      ((singletonp val-sets)			      ; ONE val set found
		       (put-vals instance slot (first val-sets))      ; <== the intermediate save!!!
		       (first val-sets))
		      (t (cond ((neq n-first-source (1- n-sources))
				(km-trace 'comment "(~a-~a) Combine ~a-~a together" 
					  n-first-source (1- n-sources) n-first-source (1- n-sources))))
			 (let ( (vals0 (km (val-sets-to-expr val-sets single-valuedp) :fail-mode 'fail)) )	; NB No constraints enforced yet
			   (put-vals instance slot vals0) 	          ; <== the intermediate save!!!
			   vals0))))

;;; ---------- (1 or 2)-4 & 5. FOLD IN RULES ----------

;	  (all-vals0 (cond ((and (or rule-sets instance-constraints)	; step is only necessary if there *are* some rules or constraints, of course
; ?? why instance-constraints? They get pulled out anyway with the km call

; Special case above (see "5. INHERIT RULES FROM CLASSES"), where there may be some rule-sets, even with no inheritance, namely
; the global-exprset-on-instance
;	  (all-vals0 (cond ((and rule-sets				; step is only necessary if there *are* some rules or constraints, of course
;				 (use-inheritance))			; NEW!! Turn off inheritance when in prototype mode!!

;; The semantics of evaluate-rule-sets-with-overrides is aweful! So avoid this variant
;	  (all-vals0 
;	   (cond ((inherit-with-overrides-slotp slot)
;		  (cond (vals (cond (rule-sets (km-trace 'comment 
;							 "(Ignore rules, as there are local values and the slot is an inherit-with-overrides slot)")))
;			      vals)
;			(t (evaluate-rule-sets-with-overrides instance slot))))
;		 (rule-sets (cond (vals				; 			(NB rule-constraints are necessarily in rule-sets!)
;				   (km-trace 'comment "(~a-~a) Combine ~a-~a together" 
;					     n-first-source n-sources n-first-source n-sources)))
; OLD			    (km (val-sets-to-expr (append (cons vals rule-sets) (mapcar #'list instance-constraints)) single-valuedp)
;#|NEW|#		    (km (val-sets-to-expr (cons vals rule-sets) single-valuedp)
;				:fail-mode 'fail))
;		 (t vals)))

	  (all-vals00 
	   (cond ((and vals (inherit-with-overrides-slotp slot))
		  (cond (rule-sets (km-trace 'comment 
					     "(Ignore rules, as there are local values and the slot is an inherit-with-overrides slot)")))
		  vals)
		 (rule-sets (cond (vals				; 			(NB rule-constraints are necessarily in rule-sets!)
				   (km-trace 'comment "(~a-~a) Combine ~a-~a together" 
					     n-first-source n-sources n-first-source n-sources)))
; OLD			    (km (val-sets-to-expr (append (cons vals rule-sets) (mapcar #'list instance-constraints)) single-valuedp)
#|NEW|#			    (km (val-sets-to-expr (cons vals rule-sets) single-valuedp)
				:fail-mode 'fail))
		 (t vals)))

	 (all-vals0
	  (cond (all-vals00
		 (let ( (recursive-rulesets (remove-if-not #'(lambda (ruleset)
							       (recursive-ruleset instance slot ruleset))
							   rule-sets)) )
		   (cond
		    (recursive-rulesets
		     (km-trace 'comment
			       "Recursive ruleset(s) ~a encountered~%...retrying them now some other values have been computed!" recursive-rulesets)
		     (put-vals instance slot all-vals00)
		     (km (val-sets-to-expr (cons all-vals00 rule-sets) single-valuedp)
			 :fail-mode 'fail))
		    (t all-vals00))))))

;;; ---------- 1-5. CONDITIONAL PROJECTION OF SINGLE-VALUED SLOT'S VALUE ----------

	  (all-vals1
	     (cond (multivaluedp all-vals0)		; multivalued case: already handled
		   (t (maybe-project-value projected-vals 		; single-valued case: combine only if compatible
					   all-vals0 slot instance n-sources)))) 

;; No! Constraint-checking done in && procedure
;; Later: Yes! Do it here! && misses constraint-checking for non-&& cases
	  (all-vals (cond (constraints				; note all-vals1 can be nil; we might coerce new vals to appear!
			     (cond ((and (tracep) (not (traceconstraintsp)))
				    (prog2 (suspend-trace) (enforce-constraints all-vals1 constraints) (unsuspend-trace)))
				   (t (km-trace 'comment "(~ab) Test values against constraints ~a" n constraints)
				      (enforce-constraints all-vals1 constraints))))
			  (t all-vals1)))

	  (local-constraints (find-constraints-in-exprs local-vals-exprs))	; now fold back in any local value constraints for the save
;	  (_dum (km-format t "local-constraints = ~a~%" local-constraints))
	  (all-vals-and-constraints
	          (cond (local-constraints
			 (cond (single-valuedp (list (vals-to-&-expr (append all-vals local-constraints))))
			       (t (append all-vals local-constraints))))
			(t all-vals))) )

    (declare (ignore _rule-sets-dummy _project1-dummy _project2-dummy _all-vals-dummy _clones-dummy))
    (put-vals instance slot all-vals-and-constraints)		; store result, even if NIL [2]
    (note-done instance slot)					; flag instance.slot done
    (check-slot instance slot all-vals)				; optional error-checking
    (note-done instance slot)					; flag instance.slot done
    all-vals))

#| 
Special case: If looping, then all-vals-and-constraints might be a STRUCTURE, rather than kb-objects.
In this case, we must filter off the structures, as get-vals is required to return only kb-objects. We also
must defer noting this slot as done -- a future retry might enable these structures to evaluate. 

This patch was later moved elsewhere into the interpreter.lisp code, see (remove-if-not #'is-km-term ...) test in (#$the ?slot of #$expr).
See the example in test-suite/restaurant.km for the explanation of this patch.
    (cond ((every #'is-km-term all-vals) 
	   (check-slot instance slot all-vals)				; optional error-checking
	   (note-done instance slot)					; flag instance.slot done
	   all-vals)
	  (t (remove-if-not #'is-km-term all-vals)))))
|#

;;; (recursive-ruleset '#$_Car23 '#$parts '#$(_Engine3 (the parts of (the parts of _Car23))))
;;; -> t
;;; This is using cheap tricks to check for recursive rules! If it accidentally makes a 
;;; mistake it's not an error, just an inefficiency.
(defun recursive-ruleset (instance slot ruleset)
  (search `#$(,SLOT of ,INSTANCE) (flatten ruleset)))

#|
(defun recursive-ruleset (instance slot ruleset)
  (some #'(lambda (rule) (recursive-rule instance slot rule)) ruleset))

(defun recursive-rule (instance slot rule)
  (cond ((equal rule `#$(the ,SLOT of ,INSTANCE)))
	((and (listp rule) 
	      (some #'(lambda (rule-part) (recursive-rule instance slot rule-part)) rule)))))
|#
;;; ======================================================================
;;;		TEMPORAL PROJECTION CODE
;;; ======================================================================

;;; Look up the slotvals from the previous situation (if any).
;;; Assume test "(and (am-in-local-situation) (projectable slot instance))" has already been passed.
(defun km-slotvals-via-projection (instance slot)
  (let ( (prev-situation (prev-situation (curr-situation))) )
    (cond (prev-situation (remove-fluent-instances (km `#$(in-situation ,PREV-SITUATION (the ,SLOT of ,INSTANCE)) :fail-mode 'fail)))
	  ((tracep) (km-trace 'comment "    (Can't compute what ~a's previous situation is)" (curr-situation))))))

;;; For single-valued slots only. Only project a value if it unifies with the local value.
;;; Returns a singleton list of the resulting (possibly unified) value.
(defun maybe-project-value (projected-values local-values slot instance n-sources)
  (cond 
   ((null projected-values) local-values)
   ((equal projected-values local-values) local-values)
   (t (let ( (prev-situation (prev-situation (curr-situation)))
	     (projected-value (first projected-values))
	     (local-value (first local-values)) )
	(cond
	  ((>= (length projected-values) 2)
	   (km-format t "ERROR! Projected multiple values ~a for the single-valued slot `~a' on instance ~a!~%"  
		      projected-values slot instance)
	   (km-format t "ERROR! Discarding all but the first value (~a)...~%" (first projected-values))))
	(cond 
	  ((>= (length local-values) 2)
	   (km-format t "ERROR! Found multiple values ~a for the single-valued slot `~a' on instance ~a!~%"
		      local-values slot instance)
	   (km-format t "ERROR! Discarding all but the first value (~a)...~%" (first local-values))))
	(cond ((null local-value) 
	       (km-trace 'comment "(1-~a) Projecting (the ~a of ~a) = (~a) from ~a" n-sources slot instance projected-value prev-situation)
	       (make-comment (km-format nil "Projected (the ~a of ~a) = (~a) from ~a to ~a"
					slot instance projected-value prev-situation (curr-situation)))
	       (list projected-value))
	      (t (let ( (unified (lazy-unify projected-value local-value)) )
		   (cond (unified 
			  (km-trace 'comment "(1-~a) Projecting and unifying (the ~a of ~a) = (~a) from ~a" 
				 n-sources slot instance projected-value prev-situation)
			  (make-comment (km-format nil "Projected (the ~a of ~a) = (~a) from ~a to ~a"
						   slot instance projected-value prev-situation (curr-situation)))
			  (list unified))		; return projected-value if can unify...
			 (t (km-trace 'comment "(1-~a) Discarding projected value (the ~a of ~a) = (~a) (conflicts with new value (~a))" 
				   n-sources slot instance projected-value local-value)
			    (list local-value))))))))))		; otherwise discard projected-value.

;;; If a slot has no value in a situation, and it's projectable, then assume the
;;; value in the previous situation still applies.
;;; Note that KM doesn't distinguish "unknown" vs. "no value". By default, 
;;; no conclusion is taken to mean "unknown", unless the slot is labeled as
;;; having property "complete", in which case it is taken to mean "no value",
;;; and hence shouldn't be projected.
;;; [1] If we *assert* the value NIL for a instance's slot, we don't want to project
;;; previously non-nil values into this slot. So we make a situation-specific
;;; assertion that this slot is complete for this instance, as shown in [1]
(defun projectable (slot instance)
;;  (and (not (member slot '#$(prev-situation next-situation)))	; prevent looping
  (and (not (isa instance '#$Situation))		; don't project prev-situation, next-situation, etc.
       (not (slotp instance))
       (inertial-fluentp slot)))
;      (not (complete-slotp slot))))

;;; FILE:  frame-io.lisp

;;; File: frame-io.lisp
;;; Author: Peter Clark
;;; Date: August 1994
;;; Purpose: Low-level interface to the KM data structures

#|
======================================================================
	PRIMARY EXPORTED FUNCTIONS (incomplete list)
======================================================================

set/get functions all operate on the *local* situation *only*. They
  are low-level calls to be used by the KM system, and should never be
  used directly unless you are *sure* you're only going to be ever working
  in the Global situation.
 	(add-val instance slot val [install-inversesp situation])
 	(delete-val instance slot val [uninstall-inversesp situation])	 ; not used by KM, but by auxiliary s/w
 	(delete-slot instance slot [facet situation])

	(get-vals instance slot [facet situation])
 	(put-vals instance slot vals [&key facet install-inversesp situation])

	(add-slotsvals instance slotsvals [facet install-inverses situation])

	(get-slotsvals frame [facet situation])
	(put-slotsvals frame [slotsvals facet install-inversesp situation])
	(point-parents-to-defined-concept frame slotsvals facet)
	(create-instance class [slotsvals prefix-string])

find functions will do a quick climb of the situation hierarchy (via
  superclass links), stopping at the first values found. This is used
  for special fast-access methods (eg. "superclasses") and to prevent
  looping. They shouldn't be used for general KB access.
NOTE: if you use find-vals on a slot, then you *must* declare it to be in
*built-in-atomic-vals-only-slots*, so that lazy-unify will append rather than &&
values together! (You can get away without for slots just containing 't', but better not).

	(find-vals frame slot [facet start-situation])
	(find-slotsvals frame [facet start-situation])

scan all supersituations and classes for rules:
	(collect-rule-sets instance slot [start-situation])
	(collect-instance-expr-sets instance slot [start-situation])
	(collect-constraints-on-instance instance slot [start-situation])
	(collect-rule-sets-on-classes classes slot [start-situation])

other:
;	(exists frame [start-situation])	       ; look in local + accessible situations
	(known-frame frame)			       ; Replace "exists", to be more explicit about what exists means
	(has-situation-specific-info frame situation)  ; look in local situation only
	(instance-of instance class)
	(is-subclass-of instance class)
	(immediate-classes instance)
	(immediate-superclasses class)
	(immediate-subclasses class)
	(immediate-supersituations situation)
	(immediate-subslots slot)
	(all-instances class)
	(all-prototypes class)
	(all-classes instance)
	(all-superclasses class)
	(all-subclasses class)
	(all-supersituations situation)
	(all-subslots slot)

======================================================================
|#

(defconstant *all-facets* '(own-properties member-properties own-definition member-definition))
(defconstant *valid-cardinalities* '#$(1-to-N 1-to-1 N-to-1 N-to-N))
(defconstant *default-cardinality* '#$N-to-N)

;;; ======================================================================
;;;	These classes/instances have delayed evaluation assertions
;;;	attached, listed on their "assertions" slot. When a new
;;;	instance is created, the assertions are made. Typically, it
;;;     will be just Situation classes that have this property.
;;; ======================================================================

;;; Instances of these classes will have their assertions made at creation time
; (defvar *classes-using-assertions-slot* nil) now in header.lisp

;;; ======================================================================
;;; 		DECLARE BUILT-IN OBJECTS
;;; ======================================================================

;;; These special functions map a SET of values onto a new value.
(defconstant *built-in-aggregation-slots*
  '#$(min max average
      first second third fourth fifth 
;     sixth seventh eighth ninth tenth 	<- bit excessive!
      last unification set-unification
      sum difference product quotient number))
   
(defconstant *built-in-single-valued-slots* 
  (append 
   '#$(domain range cardinality aggregation-function #|complete|#
	      inverse inverse2 inverse3 situation-specific inherit-with-overrides fluent-status
	      prev-situation #|print-name name|#			; name no longer special
	      prev-situation ; but not next-situation (S can have multiple S'-A pairs)
	      after-situation-of ; but not before-situation-of (S can be before multiple A-S' pairs)
	      before-situation after-situation 
	      protopart-of prototype-of definition 
	      abs log exp sqrt floor aggregation-function)
   *built-in-aggregation-slots*))

(defconstant *built-in-multivalued-slots* 
  '#$(superclasses subclasses instances instance-of add-list del-list pcs-list ncs-list
      supersituations subsituations subslots superslots next-situation
      domain-of range-of fluent-status-of
      protoparts prototypes cloned-from
      #|text|# #|name print-name <-- should be single-valued!!|# 
      name		; 3.6.00 now allow structures for name, to be stringified later by make-sentence
      #|terms <- no longer built-in |#
      elements ;;; for busting up sequences into their elements
      members  ;;; (used for defining Partitions)
      classes all-instances all-prototypes all-classes all-superclasses all-subclasses all-supersituations all-subslots
      assertions))

#|
(defconstant *built-in-complete-slots* '#$(add-list del-list))
PROBLEM! if make them complete, then we get into trouble with
do-script, which with multiple actions assumes the actions (hence the
add-list and del-lists) will be projected accross multiple situations! |#


;(defconstant *built-in-inertial-fluent-slots* '#$(instance-of instances))
(defparameter *built-in-inertial-fluent-slots* nil)	; let's try this for now...
;;; This can be over-ridden...
(defconstant *built-in-non-inertial-fluent-slots*  '#$(add-list del-list pcs-list ncs-list))

;;; Let's allow the user to toggle these...
(defun instance-of-is-nonfluent () (setq *built-in-inertial-fluent-slots* nil))
(defun instance-of-is-fluent () (setq *built-in-inertial-fluent-slots* '#$(instance-of instances)))


;;; For instances of these classes, KM *assumes* that the instances/instance-of relation will *not*
;;; vary between situations, and thus will only read and write to the global situation.
; put in interpreter.lisp, so it can be loaded before use
;(defconstant *built-in-classes-with-nonfluent-instances-relation* '#$(Situation Slot))

;;; the rest are all non-fluents

;;; EXPRESSIONLESS SLOTS:
;;; The following slots can't have KM expressions as values, only
;;; atomic values. This is because they are accessed by optimized access methods
;;; (find-vals, get-vals) which assume atomic values and make no attempt to 
;;; evaluate any expressions found there. Also, their values are not unified together,
;;; they are set unioned, which means that find-vals will encounter a list of values,
;;; not a to-be-unifed value expression.
(defconstant *built-in-atomic-vals-only-slots* 
; no longer used  (cons *tag-slot*
	'#$(domain range cardinality #|complete|#
		   inverse inverse2 inverse3 situation-specific inherit-with-overrides superclasses subclasses instances
		   instance-of supersituations members cloned-from domain-of range-of
		   subsituations subslots superslots
		   fluent-status situation-specific))

;;; REMOVE-SUBSUMERS-SLOTS:
;;; These slots have classes as their values. For these slots, KM considers any subsuming values to
;;; be redundant and remove them, eg. (Car Vehicle) -> (Car).
(defconstant *built-in-remove-subsumers-slots* '#$(instance-of superclasses))

;;; REMOVE-SUBSUMEES-SLOTS:
;;; These slots have classes as their values. For these slots, KM considers any subsumed values to
;;; be redundant and remove them, eg. (Car Vehicle) -> (Vehicle).
(defconstant *built-in-remove-subsumees-slots* '#$(subclasses))

;;; These better be complete!
;(defconstant *built-in-complete-slots* '#$(prev-situation next-situation)

(defconstant *built-in-situation-specific-slots* '#$(add-list del-list pcs-list ncs-list))

(defconstant *built-in-slots*
  (append *built-in-single-valued-slots* 
	  *built-in-multivalued-slots*))

;;; Only these built-in slots are allowed to have constraint expressions on them
(defconstant *built-in-slots-with-constraints* '#$(instance-of))

(defconstant *built-in-classes*
  '#$(Integer Number Thing Slot Aggregation-Slot String Class Situation Boolean Partition Cardinality Fluent-Status Event))		; Event is new!

;;; Otherwise, the built-in class has superclasses Thing
(defconstant *built-in-superclass-links*
  '#$((Integer Number)
      (Aggregation-Slot Slot)))

(defconstant *built-in-instance-of-links*	; in addition to built-in Slots, which are instance-of Slot
  `#$((t Boolean)
      (f Boolean)
      (*Fluent Fluent-Status)
      (*Non-Fluent Fluent-Status)
      (*Inertial-Fluent Fluent-Status)
      (,*GLOBAL-SITUATION* Situation)))

;;; Make a fn to allow reference in an earlier file without problem
(defun built-in-instance-of-links () *built-in-instance-of-links*)	

(defconstant *valid-fluent-statuses* '#$(*Fluent *Inertial-Fluent *Non-Fluent))

(defconstant *built-in-instances*
  (append *valid-cardinalities* *valid-fluent-statuses* `#$(t f ,*GLOBAL-SITUATION*)))

(defconstant *built-in-frames* 
  (append *built-in-slots*
	  *built-in-classes* 
	  *built-in-instances*))

;;; don't track inverses of these slots:
;;; [1] This is important, to stop the clone source being added to the object stack as a side-effect.
(defconstant *non-inverse-recording-slot*
; no longer used  (cons *tag-slot*
	'#$(definition cardinality aggregation-function #|complete|# add-list del-list pcs-list ncs-list
	     cloned-from #|label|# 							; [1]
	     situation-specific inherit-with-overrides #|duplicate-valued|# 
	     name #|text print-name terms|#)) ;;; no! inverse2 inverse3
      
;;; eg. DON'T record inverses for boolean T/F, eg. (T has (open-of (Box1))
(defconstant *non-inverse-recording-concept* *built-in-instances*)

;;; Return a string
(defun built-in-concept (concept) (member concept *built-in-frames*))

(defun built-in-slot (slot) (member slot *built-in-slots*))

(defun built-in-aggregation-slot (slot) (member slot *built-in-aggregation-slots*))

(defun non-inverse-recording-slot (slot) (member slot *non-inverse-recording-slot*))

(defun non-inverse-recording-concept (concept) (member concept *non-inverse-recording-concept*))

(defun built-in-concept-type (concept)
  (cond ((member concept *built-in-single-valued-slots*) "single-valued slot")
	((member concept *built-in-multivalued-slots*) "multivalued slot")
	((member concept *built-in-classes*) "class")
	((member concept *built-in-instances*) "instance")))

(defun atomic-vals-only-slotp (slot) (member slot *built-in-atomic-vals-only-slots*))
(defun remove-subsumers-slotp (slot) (member slot *built-in-remove-subsumers-slots*))
(defun remove-subsumees-slotp (slot) (member slot *built-in-remove-subsumees-slots*))

;;; ======================================================================

(defconstant *val-constraint-keywords* '#$(must-be-a mustnt-be-a <> constraint))
(defconstant *set-constraint-keywords* '#$(at-least at-most exactly set-constraint))
(defconstant *constraint-keywords* (append *val-constraint-keywords* *set-constraint-keywords*))

;;; ======================================================================

;;; Situations
(defvar *curr-situation* *global-situation*)

;;; ======================================================================

(defvar *classification-enabled* t)

(defun enable-classification () (setq *classification-enabled* t))
(defun disable-classification () (setq *classification-enabled* nil))

;;; ======================================================================

;;; Format ((<slot> <subslot-list>) (<slot> <subslot-list>) .... )
(defconstant *built-in-subslots* nil)

(defconstant *built-in-inverses*
  '#$((inverse inverse)				; important!!
      (inverse2 inverse2)	
      (inverse3 inverse3)	
      (instances instance-of)
      (instance-of instances)
      (subslots superslots)
      (superslots subslots)
      (subclasses superclasses)
      (superclasses subclasses)
      (supersituations subsituations)
      (subsituations supersituations)
      (prototypes prototype-of)
      (prototype-of prototypes)
      (protoparts protopart-of)
      (protopart-of protoparts)
      (next-situation prev-situation)
      (prev-situation next-situation)))

(defconstant *built-in-inverse2s* '#$(
      (next-situation after-situation)		; <S S' A>  -> <A S' S>
      (after-situation next-situation)
      (prev-situation before-situation)		; <S' S A> -> <A S S'>
      (before-situation prev-situation)))
	
;;; ======================================================================
;;;			COREFERENTIALITY
;;; ======================================================================

#|
Some frames are, in fact, typed variables. They are denoted by having
a name which begins with "_", eg _person34 is a "variable frame" of type 
person. Variable frames can be bound to other frames. The unifier
(km/lazy-unify.lisp) is the thing which does the unifying.
|#

;;; bind: RESULT is irrelevant, only the side-effect is important.
;;; [1] Feb 2000 - check to prevent circular bindings
(defun bind (frame1 frame2) 
  (cond ((neq (dereference frame1) (dereference frame2))	; [1]
	 ; (setf (get frame1 'binding) frame2))))
	 (make-transaction `(bind ,frame1 ,frame2)))))

(defun get-binding (frame) (get frame 'binding))

(defun bound (frame1) (get frame1 'binding))

;;; ----------

;;; [1] frame may be a structure (eg. (:triple a b c), (x <- y), '(the size of _Situation23)) as well as an atom, hence recurse
(defun dereference (frame)
  (cond ((symbolp frame)
	 (let ( (binding (get-binding frame)) )
	   (cond (binding (dereference binding))
		 (t frame))))
	((listp frame)				; [1]
	 (mapcar #'dereference frame))
	(t frame)))

(defun show-bindings ()
  (mapcar #'show-binding (get-all-objects)) (terpri) t)

(defun unbind ()
  (mapcar #'(lambda (frame) (bind frame  nil)) (get-all-objects)) t)

(defun show-binding (frame)
  (cond ((get frame 'binding) 
	 (terpri) (km-format t "~a" frame) (show-binding0 (get-binding frame)))))

(defun show-binding0 (frame)
  (cond (frame (km-format t " -> ~a" frame)
	       (cond ((symbolp frame) (show-binding0 (get-binding frame)))))))

#|
;;; Faster, but requires carrying around blist...
;;; So that subst can be used to dereference whole structures
;;; (sublis <binding-alist> <structure>)
(defun binding-alist ()
  (mapcan #'(lambda (object)
	      (cond ((bound object) (list (cons object (dereference object))))))
	  (get-all-objects)))

;;; Slow if binding-alist isn't provided
(defun dereference-expr (expr &optional (binding-alist (binding-alist)))
  (sublis binding-alist expr))
|#

;;; ======================================================================
;;;		FRAME STRUCTURES (as defined in KM)
;;; ======================================================================
;;; A frame structure is the basic data structure which KM stores/retrieves
;;; (using getobj/putobj, defined in km/myload.lisp). The data structures
;;; are stored using LISP property lists, in the LISP property list DB.
;;;
;;;  SYMBOL   PROPERTY		VALUE (the slotsvals)
;;;	car   own-properties	( (color (*red)) (wheels (4)) )

(defun slot-in (slotvals) (first slotvals))

(defun vals-in (slotvals) 
  (cond ((listp (second slotvals)) (second slotvals))
	(t (report-error 'user-error
"Somewhere in the KB, the slot `~a' was given a single value `~a'
rather than a list of values! (Missing parentheses?)
The answer to the current query may thus not be valid!~%"
		         (first slotvals) (second slotvals)))))

(defun make-slotvals (slot vals) (list slot vals))

(defun are-slotsvals (slotsvals)
  (cond ((and (listp slotsvals)
	      (every #'(lambda (slotvals)
			 (cond ((and (pairp slotvals) 
				     (symbolp (slot-in slotvals))
				     (listp (vals-in slotvals))
				     (no-reserved-keywords (vals-in slotvals)))
				(cond ((some #'(lambda (val) (and (listp val) (member (first val) *constraint-keywords*))) (vals-in slotvals))
				       (setq *are-some-constraints* t)))
				(cond ((member (slot-in slotvals) '#$(subslots superslots)) (setq *are-some-subslots* t)))     ; optimization flag
				t)))
		     slotsvals)))
	(t (report-error 'user-error "Bad structure ~a for slot-values!~%Should be of form (s1 (v1 ... vn)) (s2 (...)) ...)~%" 
			 slotsvals))))

;;; ======================================================================
;;; 		KB SET UTILITIES
;;; Below is the only bit of code which defines the internal storage
;;; of the KB -- for now, it's (setf <frame> 'kb <alist>).
;;; ======================================================================

;;; add-val: add a value to a instance's slot. 
;;; EXCEPT NB new value is simply added, not unified
;;;   [Reason: Don't want *red:: color-of: ((_car1) && (_car2) && (_car3))]
;;; [1] Unfortunately this won't catch all redundancies. Consider:
;;;     Suppose I say x isa y1, then x is a y2, then y1 is a y2.
;;;     The redundancy in x's superclasses won't be spotted. Soln = call (install-all-subclasses)
;;;	to recompute the taxonomy without redundancy.
;;; RETURNS: irrelevant and discarded
(defun add-val (instance slot val &optional (install-inversesp t) (situation (curr-situation)))
  (let* ( (oldvals0 (get-vals instance slot 'own-properties situation))
	  (oldvals1 (remove-dup-instances oldvals0))    ; rem-dups does dereference also
	  (oldvals (cond ((single-valued-slotp slot) (un-andify oldvals1))
			 (t oldvals1))) )
    (cond ((null oldvals) (put-vals instance slot (list val) :install-inversesp install-inversesp :situation situation))
     	  ((and (member val oldvals :test #'equal)	; val is already there...
		(not (equal oldvals0 oldvals1)))	; but oldvals are not fully dereferenced...
	   (put-vals instance slot oldvals1  		; so just update references
		     :install-inversesp nil :situation situation))
     	  ((member val oldvals :test #'equal))		; val is already there, everything uptodate
	  ((single-valued-slotp slot) 
	   (put-vals instance slot 
		     (list (vals-to-&-expr (append oldvals (list val)))) 
		     :install-inversesp nil 		 ; install-inversesp would be ineffective here, as we've a STRUCTURE 
		     :situation situation)		
	   (cond (install-inversesp 
		  (install-inverses instance slot (list val) situation)))	  ; NOW do it manually for the new value...
	   (un-done instance))							  ; 1.4.0-beta8: Don't forget this! Important!!
	  ((remove-subsumers-slotp slot)	  				  ; eg. instance-of, superclasses. See [1]	
	   (cond ((some #'(lambda (oldval) (is-subclass-of oldval val)) oldvals)) ; don't need it!
		 (t (put-vals instance slot 
;;; Unnecessary overwork! ->  (remove-subsumers (cons val oldvals))
#|NEW|#			      (cons val (remove-if #'(lambda (oldval) (is-subclass-of val oldval)) oldvals))
			      :install-inversesp install-inversesp :situation situation))))
	  ((remove-subsumees-slotp slot)					  ; eg. subclasses
	   (cond ((some #'(lambda (oldval) (is-subclass-of val oldval)) oldvals)) ; don't need it!
		 (t (put-vals instance slot 
;;; Unnecessary overwork! ->  (remove-subsumees (cons val oldvals)) 
#|NEW|#			      (cons val (remove-if #'(lambda (oldval) (is-subclass-of oldval val)) oldvals))
			      :install-inversesp install-inversesp :situation situation))))
	  (t (put-vals instance slot (cons val oldvals) :install-inversesp install-inversesp :situation situation)))))

;;; ======================================================================
;;; (put-vals instance slot vals [&key facet install-inversesp situation])
;;; ======================================================================

;;; IF vals is nil, this will delete a slot (and its value) from a instance. Doesn't remove inverse links or
;;; scan through situations. NOTE: vals can validly be NIL, in the case where (i) lazy-unify may put a *path* 
;;; on an instance's slot, then (ii) it later is evaluated to NIL. So in that case, a put-vals with NIL will 
;;; remove that cached path.
(defun put-vals (instance slot vals &key (facet 'own-properties) (install-inversesp t) (situation (curr-situation)))
  (cond 
   ((member instance *reserved-keywords*)
    (report-error 'user-error "Attempt to use keyword `~a' as the name of a frame/slot (not allowed!)~% Doing (~a has (~a ~a))~%"
		  instance instance slot vals))
   ((not (kb-objectp instance))
    (report-error 'program-error "Attempting to assert information on a non-kb-object ~a...~%Ignoring the slot-vals (~a ~a)~%" 
		  instance slot vals))
   ((eq slot '#$complete)				; temp error message for a while
    (report-error 'user-error "KM 1.4.0-beta36 and later: The `complete' slot has been renamed - you should change your KB as follows:~%       `(<slot> has (complete (t)))' should be replaced with `(<slot> has (fluent-status (*Fluent)))'!"))
   (t (let* ( (target-situation (cond ((eq situation *global-situation*) *global-situation*)	; efficiency: Avoid needless lookups for (fluentp slot)
				      ((not (fluentp slot)) *global-situation*)
				      ((and (eq slot '#$instance-of)
					    (some #'(lambda (val)
						      (some #'(lambda (class) (is-subclass-of val class)) 	; e.g. (put-vals _Sit1 instance-of Situation)
							    *built-in-classes-with-nonfluent-instances-relation*)) ;				   ^^ val ^^
						  vals))
				       *global-situation*)
				      ((and (eq slot '#$instances)
					    (some #'(lambda (class) (is-subclass-of instance class))		; e.g. (put-vals Situation instances _Sit1)
						  *built-in-classes-with-nonfluent-instances-relation*))	;		 ^instance^
				       *global-situation*)
				      (t situation)))
	      (old-slotsvals (get-slotsvals instance facet target-situation)) 
	      (old-vals (vals-in (assoc slot old-slotsvals))) )
	(cond ((not (isa slot '#$Slot))					; Do this *after* checking instance-of above!
	       (add-val slot '#$instance-of '#$Slot t *global-situation*)))		; install-inversesp = t
	(cond 
	 ((equal vals old-vals) vals)
	 (t (let ( (putobj-facet (curr-situation-facet facet target-situation)) )
	      (cond ((not (known-frame instance)) (add-to-stack instance)))	; new, 3.7.00
	      (cond ((null vals) 
		     (putobj instance (remove-if #'(lambda (slotvals) (eq (slot-in slotvals) slot)) old-slotsvals) putobj-facet))
		    (t (putobj instance (update-assoc-list old-slotsvals (make-slotvals slot vals)) putobj-facet)
		       (cond ((and (member facet '(own-definition own-properties))
				   install-inversesp)
			      (install-inverses instance slot (set-difference vals old-vals) target-situation)))
		       ))))))))
  instance)

(defun put-slotsvals (frame &optional slotsvals (facet 'own-properties) (install-inversesp t) (situation (curr-situation)))
  (mapc #'(lambda (slotvals)
	    (put-vals frame (slot-in slotvals) (vals-in slotvals) :facet facet :install-inversesp install-inversesp :situation situation))
	slotsvals)
  frame)

;;; --------------------

(defun delete-slot (instance slot &optional (facet 'own-properties) (situation (curr-situation)))
  (put-vals instance slot nil :install-inversesp nil :facet facet :situation situation))

;;; Not used by KM, but used by auxiliary s/w
(defun delete-val (instance slot val &optional (uninstall-inversesp t) (situation (curr-situation)))
  (let* ( (oldvals0 (get-vals instance slot 'own-properties situation))
	  (oldvals1 (remove-dup-instances oldvals0))    ; rem-dups does dereference also
	  (oldvals (cond ((single-valued-slotp slot) (un-andify oldvals1))
			 (t oldvals1))) )
    (cond ((not (member val oldvals))
	   (km-format t "Warning! Trying to delete non-existent value ~a on (the ~a of ~a)!~%" val slot instance))
	  ((single-valued-slotp slot) 
	   (put-vals instance slot (vals-to-&-expr (remove val oldvals)) :install-inversesp nil :situation situation)
						; uninstall-inversesp would be ineffective here, as we've a STRUCTURE 
	   (cond (uninstall-inversesp (uninstall-inverses instance slot (list val) situation)))	  ; NOW do it manually for the new val
	   (un-done instance))							  ; 1.4.0-beta8: Don't forget this! Important!!
	  (t (put-vals instance slot (remove val oldvals) :install-inversesp nil :situation situation)
	     (cond (uninstall-inversesp (uninstall-inverses instance slot (list val) situation))))))) ; NOW do it manually for  new val

;;; ======================================================================
;;;		LOCAL ACCESS TO A SLOT'S VALUES
;;; ======================================================================

#|
OPPORTUNISTIC GET:
find-vals looks on the facet of the current situation. If nothing is there,
then it goes up to the supersituation. It acts as a quick and direct access
to a frame's values, and *assumes* that the user isn't placing conflicting
in different situations. Things like the superclasses link should be 
accessed with get-vals. Use of find-vals rather than get-global prevents
looping for certain problematic queries (eg. superclasses).

This should be reasonably robust with situations: If I create a Dog in a Situation,
then this will automatically assert (Dog has (instances (<instances from supersituations> <new Dog>))),
thus adding the Dogs in the global situation. If I don't create a Dog in a Situation,
then find-vals will just progress up to the supersituation to find the Dogs. However,
this could possibly return an incomplete list if a situation has multiple supersituations.

HOWEVER: It will miss instances that are *projected* from earlier situations, but
don't exist in the global situation. We should create these beasties in the global situation,
I think.

NOTE: For non-fluent slots, it's slightly redundant to climb the situation hierarchy as there will
only be information at the top (Global) situation. However, I'll leave this minor redundancy here
for simplicity, and also to avoid possible looping with find-vals calling fluentp, calling find-vals etc.
|#

#|
========================================
   This extension more complete but much slower...
========================================
EXTENDED 4.21.00 to look both in classes and subslots, for various special cases. May as well
be thorough here, rather than handling all these special things on a case-by-case basis.

LOOPING CONCERNS:
 [1] supersituations/subsituations are NOT fluents, so no looping here.
 [2] subslots: special check to avoid finding the subslots of subslots etc.
 [3] instance-of: special check to avoid finding the instance-of to find the instance-of.

(defun find-vals (frame slot &optional (facet 'own-properties) (situation (curr-situation)))
  (cond 
   ((null situation) (report-error 'program-error "Null situation in get-vals!~%"))
   ((get-vals frame slot facet situation))		; Quick lookahead -- just try local value...
   ((and (neq frame '#$Thing)
	 (not (member frame '#$(subslots superslots instance-of instances supersituations subsituations superclasses subclasses))))
    (let ( (all-situations (cond ((and (neq situation *global-situation*)
				       (fluentp slot))
				  (cons situation (all-supersituations situation)))	; [1]
				 (t (list *global-situation*))))
	   (all-slots (cond ((eq slot '#$subslots) (list slot))
			    (t (cons slot (all-subslots slot))))) )							; [2]
	  (or (some #'(lambda (subslot)
			(some #'(lambda (supersituation)
				  (get-vals frame subslot facet supersituation))
			      all-situations))
		    all-slots)
	      (and (eq facet 'own-properties)
		   (some #'(lambda (class)
			     (some #'(lambda (subslot)
				       (some #'(lambda (supersituation)
						 (get-vals class subslot 'member-properties supersituation))
					     all-situations))
				   all-slots))
			 (cond ((not (member slot '#$(instance-of superclasses))) (all-classes frame))))))))))		; [3]
|#

(defun find-vals (frame slot &optional (facet 'own-properties) (situation (curr-situation)))
  (cond ((null situation) (report-error 'program-error "Null situation in get-vals!~%"))
	((get-vals frame slot facet situation))		; Try local value...
	((and (neq situation *global-situation*)				; ...otherwise climb sitn tree.
	      (some #'(lambda (supersituation)
			(find-vals frame slot facet supersituation))
		    (immediate-supersituations situation))))
	((eq slot '#$fluent)							; [1] Special case where we *do* want to use subslots
	 (find-vals frame '#$inertial-fluent facet situation))))

;;; Ensure there's at most one. Fail quietly (:fail-mode 'fail) or noisily (:fail-mode 'error).
;;; Inconsistently, here I'm using keys rather than optional arguments for facet and situation, as can't mix the two (urgh),
;;; and fail-mode should always be a key.
(defun find-unique-val (frame slot &key (facet 'own-properties) (situation (curr-situation)) (fail-mode 'error))
  (let ( (vals (find-vals frame slot facet situation)) )
    (cond ((singletonp vals) (first vals))
	  (vals (report-error 'user-error 
			      "(the ~a of ~a) should have at most one value,~%but it returned multiple values ~a!~%Just taking the first...(~a) ~%" 
			      slot frame vals (first vals))
		(first vals))
	  ((eq fail-mode 'error) 
	   (report-error 'user-error "No value found for the ~a of ~a!~%" slot frame)))))

;;; Now redirect, always use subslots
;(defun find-unique-val-using-subslots (frame slot &key (fail-mode 'error))
;  (find-unique-val frame slot :fail-mode fail-mode))

#|
;;; Unlike find-unique-val, this version *also* looks down the subslot hierarchy. 
;;; It's used to fast-find the prev-situation of a situation, as subslots of prev-situation 
;;; are used in hypothetical reasoning.
(defun find-unique-val-using-subslots (frame slot &key (fail-mode 'error))
  (or (find-unique-val frame slot :fail-mode 'fail)
      (some #'(lambda (subslot)
		(find-unique-val frame subslot :fail-mode 'fail))
	    (all-subslots slot))
      (cond ((eq fail-mode 'error)
	     (report-error 'user-error "No value found for the ~a of ~a!~%" slot frame) nil))))
|#

;;; This *doesn't* climb the supersituation hierarchy -- need to do this to stop looping
;;; find-vals -> supersituation -> find-vals -> supersituation....
(defun get-vals (frame slot &optional (facet 'own-properties) (situation (curr-situation)))
  (cond ((and (symbolp slot) (is-km-term frame))
	 (vals-in (assoc slot (get-slotsvals frame facet situation))))
	((not (symbolp slot))
	 (report-error 'user-error "Doing (the ~a of ~a) - the slot name `~a' should be a symbol!~%" slot frame slot))
	(t (report-error 'user-error "Doing (the ~a of ~a) - the frame name `~a' should be a symbol!~%" slot frame frame))))

;;; ---------- analagous for get whole slotsvals set ----------

;;; This is needed ONLY for getting all the 'own-definition or 'member-definition properties.
;;; It opportunistically climbs until it finds a definition, ignoring multiple ones.
(defun find-slotsvals (frame &optional (facet 'own-properties) (situation (curr-situation)))
  (cond ((null situation) (report-error 'program-error "Null situation in get-slotsvals!~%"))
	((get-slotsvals frame facet situation))		; Try local value...
	((neq situation *global-situation*)
	 (some #'(lambda (supersituation)
		   (find-slotsvals frame facet supersituation))
	       (immediate-supersituations situation)))))

(defun get-slotsvals (frame &optional (facet 'own-properties) (situation (curr-situation)))
  (getobj frame (curr-situation-facet facet situation)))

;;; ----------------------------------------
;;; NEW - same thing, but just deal with member properties. A "ruleset" is a list of expressions on 
;;; some class's slot, which should be applied to instances of that class.
;;; Here we collect both `assertional' and `definitional' rules; it'd be nice to ignore the definitional
;;; rules, or just take them if no assertional rules, but that would be incomplete wrt. the intended
;;; semantics.
;;; We have to search in two dimensions: (1) up the isa hierarchy and (2) up the situation hierarchy.


#| 
NEW: IF   supersituation S1 yields the rule (a ...)
     AND  instance exists in S1
     THEN it is redundant to also evaluate the expression in situation,
	  as it will already have been evaluated in S1 and passed to instance through
          "situation inheritance".

So, we return two values:
  (<expr1> ...)		; exprs to evaluate in situation
  (<expr1> ...)		; redundant expressions (will already have been evaluated in supersituations)
|#
;;; ---------- search ALL situations and classes

(defun collect-rule-sets (instance slot &optional (situation (curr-situation)))
  (cond ((inherit-with-overrides-slotp slot)
	 (collect-rule-sets-with-overrides slot (immediate-classes instance) 
					   (cond ((and (neq situation *global-situation*)
						       (fluentp slot))
						  (list situation))
						 (t (list *global-situation*)))))
	(t (let ( (all-situations (cond ((and (neq situation *global-situation*)
					      (fluentp slot))
					 (cons situation (all-supersituations situation)))
					(t (list *global-situation*))))
		  (all-classes (all-classes instance)) )
	     (collect-rule-sets2 slot all-classes all-situations)))))

;;; ---------- STOP after you've found something

;;; Slots are declared to use this by setting their "inherit-with-overrides" property to t
(defun collect-rule-sets-with-overrides (slot classes situations &key (try-supersituationsp t))
  (cond ((collect-rule-sets2 slot classes situations))
	((and (not (equal classes '#$(Thing)))
	      (collect-rule-sets-with-overrides slot (my-mapcan #'immediate-superclasses classes) situations :try-supersituationsp nil)))
	((and try-supersituationsp
	      (not (equal situations (list *global-situation*))))
	 (collect-rule-sets-with-overrides slot classes (my-mapcan #'immediate-supersituations situations)))))

;;; ----------

#|
The below is semantically aweful! Better is the first version (above)
(defun collect-rule-sets (instance slot &optional (situation (curr-situation)))
  (let ( (all-situations (cond ((and (neq situation *global-situation*)
				     (fluentp slot))
				(cons situation (all-supersituations situation)))
			       (t (list *global-situation*))))
	 (all-classes (all-classes instance)) )
    (collect-rule-sets2 slot all-classes all-situations)))

;;; Ascend the taxonomy, STOP after you've found values
(defun evaluate-rule-sets-with-overrides (instance slot &optional (situation (curr-situation)))
  (evaluate-rule-sets-with-overrides2 instance slot (immediate-classes instance) (list situation) :try-supersituationsp t))

(defun evaluate-rule-sets-with-overrides2 (instance slot classes situations &key (try-supersituationsp t))
  (let ( (rule-sets (bind-self (collect-rule-sets2 slot classes situations) instance)) )
    (cond ((and rule-sets 
		(or (km-trace 'comment "Inherit with overrides - try evaluating rules ~a from classes ~a" 
			      (val-sets-to-expr rule-sets (single-valued-slotp slot)) classes) t)
		(km (val-sets-to-expr rule-sets (single-valued-slotp slot)) :fail-mode 'fail)))	; found an answer -- so stop!!
	  ((not (equal classes '#$(Thing)))
	   (evaluate-rule-sets-with-overrides2 instance slot (my-mapcan #'immediate-superclasses classes) situations :try-supersituationsp nil))
	  ((and try-supersituationsp
		(not (equal situations (list *global-situation*))))
	   (evaluate-rule-sets-with-overrides2 instance slot classes (my-mapcan #'immediate-supersituations situations))))))
|#

;;; ----------
;;; Find all the rule sets on all the classes in all the situations
(defun collect-rule-sets2 (slot classes situations)
  (remove-duplicates (remove nil 				; tidy up answer...
			     (mapcan #'(lambda (situation)
					 (mapcan #'(lambda (class) (get-rule-sets-in-situation class slot situation)) classes))
				     situations))					; (includes situation)
		     :test #'equal :from-end t))

;;; (Essentially a synonym for get-vals)
;;; IS MAPCAN-SAFE
(defun get-rule-sets-in-situation (class slot situation)
  (list (get-vals class slot 'member-properties situation)	; make a list, for mapcan (above)
	(get-vals class slot 'member-definition situation)))

;;; Climb up situation hierarchy collecting instance data
(defun collect-instance-expr-sets (instance slot &optional (situation (curr-situation)))
  (let ( (all-situations (cond ((and (neq situation *global-situation*)
				     (fluentp slot))
				(cons situation (all-supersituations situation)))
			       (t (list *global-situation*)))) )
    (remove-duplicates (remove nil			        ; tidy up answer
       (mapcar #'(lambda (situation)
		   (get-vals instance slot 'own-properties situation))
	       all-situations))
		       :test #'equal :from-end t)))

;;; ----------

;;; Find all the constraints on an instance's slot.
;;; NOTE: This won't collect constraints on subslots
(defun collect-constraints-on-instance (instance slot &optional (situation (curr-situation)))
  (cond ((and *are-some-constraints*								; optimization flag
	      (or (member slot *built-in-slots-with-constraints*)
		  (not (member slot *built-in-slots*))))
	 (let* ( (rule-sets (bind-self (collect-rule-sets instance slot situation) instance))    ; 2D search up classes and sitns
		 (rule-constraints (mapcan #'find-constraints-in-exprs rule-sets))	; from classes
		 (val-constraints (mapcan #'find-constraints-in-exprs 			; from instance in curr-situation + its supersituations
					  (collect-instance-expr-sets instance slot situation))) )
	   (remove-duplicates (append rule-constraints val-constraints) :test #'equal)))))

;;; Same, but start at classes
;;; [1] all-superclasses0 like all-superclasses, except *excludes* Thing and includes Class.
;;;	Perfect!
(defun collect-rule-sets-on-classes (classes slot &optional (situation (curr-situation)))
  (let* ( (all-situations (cond ((and (neq situation *global-situation*)
				      (fluentp slot))
				 (cons situation (all-supersituations situation)))
				(t (list *global-situation*))))
	  (all-classes (my-mapcan #'all-superclasses0 classes)) )   ; [1]
    (remove nil 				; tidy up answer...
	    (mapcan #'(lambda (situation)
			(mapcan #'(lambda (class) (get-rule-sets-in-situation class slot situation)) all-classes))
		    all-situations)		; (includes situation)
	    :test #'equal :from-end t)))

;;; ----------

;;; Local to the slot AND situation
(defun local-constraints (instance slot &optional (situation (curr-situation)))
  (cond 
   (*are-some-constraints*								; optimization flag
    (find-constraints-in-exprs (bind-self
				(or (get-vals instance slot 'own-properties situation)     ; This disjunct should be in get-vals-
				    (get-vals instance slot 'own-definition situation))    ; in-situation, not here,+ should be conj!
				instance)))))

;;; ======================================================================
;;; 		ADDITIONAL UTILITIES
;;; ======================================================================

;;; For backward compatibility...get rid of this in dependent files!
;(defun   known-frame (frame) (exists frame))
;(defun unknown-frame (frame) (not (exists frame)))

#|
;;; An object exists, from the point of view of a situation, if it's either in
;;; the global situation or in that local situation [but not in some other local situation].
;;; NB This is faster than searching the kb-objects list every time
(defun exists (frame &optional (situation (curr-situation)))
; (or (member frame (unfiltered-obj-stack))			; unfiltered stack NO! frame may be on stack, but *not* in situation
; (or (bound frame)						; Similarly no! frame may be bound but *not* in situation 
;								; (assume its already derefed)
 (or  (has-situation-specific-info frame *global-situation*)	; [1] look in *Global
      (built-in-concept frame)					
      (exists2 frame situation)))

;;; Recursively ascend supersituation hierarchy until object is found
(defun exists2 (frame situation)
  (cond ((neq situation *global-situation*)			; already done above at [1]
	 (or (has-situation-specific-info frame situation)
	     (some #'(lambda (supersituation)
		       (exists2 frame supersituation)) 
		   (immediate-supersituations situation))))))
|#

;;; 3.7.00 - No!! Existence is more complicated than that!!!!!
;;; There's a whole philosophical issue here. For now, it simply exists if it has a frame, ie. is on the (get-all-objects) list
;;; Existence in a situation is meaningless.

; This definition is now in loadkb.lisp
;(defun known-frame (fname)
;  (cond ((kb-objectp frame) (gethash fname *kb-objects*))
;	(t (report-error 'program-error "Attempt to check existence of a non kb-object ~a!~%" fname))))

;;; ----------

(defun has-situation-specific-info (frame situation)
  (some #'(lambda (prop-list) 
	    (getobj frame (curr-situation-facet prop-list situation)))
	*all-facets*))

;;; ======================================================================
;;;		SPECIAL FACET FOR BOOK-KEEPING OF DEFINITIONS
;;; ======================================================================

(defun point-parents-to-defined-concept (frame parents facet)
  (let ( (defined-children-facet (cond ((eq facet 'own-definition) 'defined-instances)
				       (t 'defined-subclasses))) )
    (cond ((null parents)
	   (report-error 'user-error "~a:
Definition for ~a must include an `instance-of' slot,
declaring the most general superclass of ~a.
Continuing, but ignoring definition...~%" frame frame frame))
	  (t (mapcar #'(lambda (parent)
			 (let ( (children (get parent defined-children-facet)) )
			   (cond ((eq facet 'member-definition)   ; Prologue: add the implied taxonomic link
				  (km `(,frame #$has (#$superclasses (,parent))))))
			   (make-comment (km-format nil "Noting definition for ~a..." frame))
			   (cond ((member frame children))	  ; already got this definition
				 (t ;(setf (get parent defined-children-facet) (cons frame children))
				    (make-transaction `(setf ,parent ,defined-children-facet ,(cons frame children)))
				    ))))
		     parents)))))

;;; ======================================================================
;;; Adding (not replacing) new values to the originals...
;;; ======================================================================

;;; [1] Factor out 'Self' at load-time for own properties.
(defun add-slotsvals (instance add-slotsvals &optional (facet 'own-properties) (install-inversesp t) (situation (curr-situation)))
  (mapc #'(lambda (add-slotvals)
		(let* ( (slot (slot-in add-slotvals))
			(old-vals (get-vals instance slot facet situation))
			(new-vals (cond ((null old-vals) (vals-in add-slotvals))
					(t (compute-new-vals slot old-vals (vals-in add-slotvals))))) )
		  (put-vals instance slot new-vals :facet facet :install-inversesp install-inversesp :situation situation)))
	(cond ((member facet '(own-properties own-definition)) 		; [1]
	       (bind-self add-slotsvals instance))
	      (t add-slotsvals))))

#|
NOTE: These are older comments from an earlier version compute-new-slotsvals, not compute-new-vals.
;;; NB: Preserves original ordering if no updates are required, so we can detect no change
> (compute-new-slotsvals '((s1 (a b)) (s2 (c d))) '((s2 (d e)) (s3 (f g))))
((s1 (a b)) (s2 (c d e)) (s3 (f g)))
>  (compute-new-slotsvals '((s1 (a b)) (s2 (c d e)) (s3 (f g))) '((s2 (d e)) (s3 (f g))))
((s1 (a b)) (s2 (c d e)) (s3 (f g)))
[1] This could be made more efficient by only doing pair-wise subsumption tests between old-vals and extra-vals,
    rather than all possible pairings. See more efficient version in add-val, earlier.
[2] Defined in subsumes.lisp. NB *only* do this check for own properties! 
	Why: Originally becuase the remove-subsuming-exprs check evaluates the expressions!
[3] Now we do a two-way check: if old-expr subsumes new-expr, or new-expr subsumes old-expr, then remove the subsumer.
    This is just a generalized case of remove-subsumers [1b], preserving which was in which set.

FILTER above at [2]:
More time consuming, but more thorough. Can skip this if you really want, to avoid this
rather unusual instance-specific problem.
IF there are any instances in old-vals AND a new-val expression subsumes that
instance THEN don't add the new-val expression to the description.
	KM> (Pete has (owns ((a Dog))))
	KM> (Pete owns)
	_Dog40
	KM> (Pete has (owns ((a Dog))))
	KM> (Pete owns)
	_Dog40				; was (_Dog40 _Dog41) in 1.3.7
	KM> (Pete has (owns ((a Dog) (a Dog))))
	(_Dog40 _Dog41)			; was just _Dog40 in beta version of 1.3.8
|#

(defun compute-new-vals (slot old-vals0 add-vals)
  (let* ( (old-vals	 (cond ((single-valued-slotp slot) (un-andify old-vals0))		; ((a & b)) -> (a b)
			       (t old-vals0)))
	  (extra-vals   (ordered-set-difference add-vals old-vals :test #'equal)) )
    (cond (extra-vals (cond
		       ((remove-subsumers-slotp slot) (remove-subsumers (append old-vals extra-vals)))  ; [1]
		       ((remove-subsumees-slotp slot) (remove-subsumees (append old-vals extra-vals)))
		       ((atomic-vals-only-slotp slot) (remove-dup-instances (append old-vals extra-vals)))
		       (t (let* ( (non-subsumers (remove-subsuming-exprs extra-vals old-vals :allow-coercion t)) ; [2]
				  (final-extra-vals (remove-subsuming-exprs old-vals non-subsumers :allow-coercion t))    ; [3]
				  (revised-vals (append final-extra-vals non-subsumers)) )
			    (cond ((single-valued-slotp slot)
				   (list (vals-to-&-expr revised-vals)))
				  (t revised-vals))))))
	  (t old-vals0))))

;;; ======================================================================
;;;		NEW FRAME CREATION
;;; create-instance -- just generate a new instance frame and hook it into the isa hierarchy.
;;; ======================================================================

;;; (create-instance 'person '((legs (3))))
;;; creates a new instance of person eg. _person30, with slot-values:
;;;		(generalizations (person)) (legs (3))
;;;
;;; `parent' can be either a symbol or a string
;;; This creates a new, anonymous subframe of parent, and attaches slotsvals
;;; to the new frame. :instance denotes that the frame is an instance, and
;;; hence its name is prefixed with an instance marker (eg. "_" in "_person31")

;;; Apr 99: If fluent-instancep is t, then a fluent instance is created, denoted by using
;;; the prefix-string "_Some". Fluents aren't passed between situations (Strictly they
;;; should be copied and renamed, but it's easier to simply rebuild them in the
;;; new situation from the (some ...) expression).

(defun create-instance (parent0 &optional slotsvals0 (prefix-string (cond ((am-in-prototype-mode) *proto-marker-string*) 
									  (t *var-marker-string*))))
  (let ( (parent (dereference parent0))
	 (slotsvals (dereference slotsvals0)) )
    (cond 
        ((kb-objectp parent) 
;	     (eq parent '#$Number))	; the one valid class which *isn't* a KB object	; WHY NOT???
	 (create-named-instance (create-instance-name parent prefix-string) parent slotsvals))
;;; NEW 2.29.00: Handle descriptions as class objects
	((class-descriptionp parent :fail-mode 'fail)
	 (let* ( (dclass+dslotsvals (or (minimatch parent ''#$(every ?class))
					(minimatch parent ''#$(every ?class with &REST))))
		 (dclass (first dclass+dslotsvals))
		 (dslotsvals (second dclass+dslotsvals)) )
	   (create-named-instance (create-instance-name dclass prefix-string) dclass (append dslotsvals slotsvals))))
	(t (report-error 'user-error "Class name must be a symbol or quoted class description! (was ~a)~%" parent)))))

;;; Here I know the name of the new frame to create
;;; [1] to handle (a Car with (instance-of (Expensive-Thing)))
;;; [2] Use add-slotsvals, rather than put-slotsvals, to make sure the non-fluent assertions are made in the global situation.
;;;     In addition, unify-with-existential-expr calls this, even though the old instance exists.
;;; [3] No - global assertions are on a slot-by-slot basis.
;;; [4] Make sure we add instance-of Event first, so slots are later recognized as Event slots!
(defun create-named-instance (newframe parent &optional slotsvals0)
  (cond 
   ((not (kb-objectp newframe))
    (report-error 'user-error "Ignoring slots on non-kb-object ~a...~%Slots: ~a~%" newframe slotsvals0))
   (t (let* ( (extra-classes (vals-in (assoc '#$instance-of slotsvals0)))	; [1]
	      (slotsvals1 (update-assoc-list slotsvals0 
					     (list '#$instance-of (remove-subsumers (cons parent extra-classes)))))
	      (slotsvals (bind-self slotsvals1 newframe)) )
;	(cond ((is-subclass-of parent '#$Situation) 	; all situation assertions are done in Global context	[3]
;              (add-slotsvals newframe slotsvals 'own-properties t *global-situation*))		; [3]
;	      (t (add-slotsvals newframe slotsvals)))						; [2]
	(cond ((and (neq (curr-situation) *global-situation*)
		    (some #'(lambda (class) (is-subclass-of class '#$Event)) 
			  (cons parent extra-classes)))
	       (add-slotsvals newframe slotsvals 'own-properties t *global-situation*))
	      (t (add-slotsvals newframe slotsvals)))			; [2]
	(cond ((am-in-prototype-mode) 
	       (add-val newframe '#$protopart-of (curr-prototype) t *global-situation*)))  ; install-inverses = t; Note in GLOBAL situation
#|NEW|#	(make-assertions newframe slotsvals)	; MOVED from situations only
	(un-done newframe)		; in case it's a redefinition	MOVED to put-slotsvals Later: No!
	(classify newframe)		; must now classify it
	newframe))))

;;; [gentemp = gensym + intern in current package]
;;; [1] Consider the user saves a KB, then reloads it in a new session. As the gentemp
;;; counter starts form zero again, there's a small chance it will re-create the name
;;; of an already used frame, so we need to check for this.
(defun create-instance-name (parent &optional (prefix-string (cond ((am-in-prototype-mode) *proto-marker-string*) 
								   (t *var-marker-string*))))
  (cond ((and (checkkbp) (not (known-frame parent)))
	 (report-error 'user-warning "Class ~a not declared in KB.~%" parent)))
  (let ( (instance-name (gentemp (concat prefix-string (symbol-name parent)))) )
    (cond ((known-frame instance-name) (create-instance-name parent prefix-string))		; [1]
	  (t instance-name))))

;;; ------------------------------
;;;	NEW: If build a situation, make its assertions
;;; ------------------------------

;;; Generalized to cover any new instance. SubSelf is only used for Situations, as a holder for Self.
;;; For situations, assertions are meant to be made *in* the situation they're in.
;;; [1] (second ...) to strip off the (quote ...)
(defun make-assertions (instance &optional slotsvals)
  (cond ((or (and *classes-using-assertions-slot*
		  (intersection (all-classes instance) *classes-using-assertions-slot*))
	     (assoc '#$assertions slotsvals))			; has local assertions
	 (let ( (assertions (subst '#$Self '#$SubSelf (km `#$(the assertions of ,INSTANCE) :fail-mode 'fail))) )
	   (mapc #'(lambda (assertion) 
		     (cond ((not (quotep assertion))
			    (report-error 'user-error "Unquoted assertion ~a on ~a! Ignoring it...~%" assertion instance))
			   (t (let ( (situated-assertion (cond ((isa instance '#$Situation) `#$(in-situation ,INSTANCE ,(SECOND ASSERTION))) ; [1]
							       (t (second assertion)))) )
				(make-comment (km-format nil "Evaluating ~a" situated-assertion))
				(km situated-assertion)))))
		 assertions)))))

;;; ======================================================================
;;;		THE DONE LIST
;;; The purpose of this list is to prevent recomputation of cached values.
;;; Here KM records which slot-values have been computed. If KM subsequently
;;; need those slot-values, it just does a lookup rather than a recomputation.
;;; note-done and reset-done are called by interpreter.lisp.
;;; Aug 98: We have to note "done in a situation", note just "done". Just 
;;; because KM knows X's age in Sitn1, doesn't mean it knows it in Sitn2!
;;; ======================================================================

;;;    SYMBOL  PROPERTY  VALUE (list of already computed slots)
;;;    _Car1   done     (age wheels)
;;; Aug 98: Modify this so we note done in a situation, rather than globally done.
;;;    SYMBOL  PROPERTY  VALUE (list of already computed slots and situations)
;;;    _Car1   done     ((age *Global) (wheels Sitn1) (age Sitn1) (age Sitn2) (wheels *Global))

;;; *done* also keeps a list of all the frames touched by note-done, so that we know what
;;; to return to do do *undone*. 
;;; 1.4.0 Use (get-all-objects) - less efficient but that's okay, it's a rare operation.
;;; (defvar *done* nil)

(defun note-done (frame slot &optional (situation (curr-situation)))
  (cond ((kb-objectp frame)
	 (let ( (done-so-far (get frame 'done)) )
	   (cond ((member (list slot situation)  done-so-far :test #'equal))
		 (t ;;; (cond ((not (member frame *done*)) (setq *done* (cons frame *done*))))
		    (setf (get frame 'done) (cons (list slot situation) done-so-far))))))))

(defun already-done (frame slot &optional (situation (curr-situation)))
  (and (kb-objectp frame) 
       (member (list slot situation) (get frame 'done) :test #'equal)))

(defun un-done (frame) (remprop frame 'done))

;;; (defun reset-done () (mapc #'un-done *done*) (setq *done* nil) t)
(defun reset-done () (mapc #'un-done (get-all-objects)) t)

(defun show-done ()
  (mapc #'(lambda (frame)
	    (cond ((get frame 'done)
		   (km-format t "~a:~%" frame)
		   (mapc #'(lambda (slot+situations) 
			     (km-format t "     ~a~20T [in ~a]~%" (first slot+situations) (second slot+situations)))
			 (gather-by-key (get frame 'done))))))
	(get-all-objects))
  t)

;;; ======================================================================
;;;			(RE)CLASSIFICATION OF INSTANCES
;;; ======================================================================

#|
If it's a new/redefined frame, should classify it.
If it has extra values through unification, should reclassify it.
If it has an extra value through installation of inverses, do reclassify it
	(see kb/test1.kb)
If it is just having existing expressions computed into values, don't reclassify it.
|#

;;; Wrapper to limit tracing....
;;; [1] slot as option: Generally not used -- but if given, only consider possible-new-parent classes which have some 
;;; explicit to offer for slot's value.
(defun classify (instance &optional slot)			
  (cond ((and *classification-enabled* *are-some-definitions* (tracep) (not (traceclassifyp))) 
	 (suspend-trace)
	 (classify0 instance slot)
	 (unsuspend-trace))
	((and *classification-enabled* *are-some-definitions*) (classify0 instance slot))))

(defun classify0 (instance &optional slot)
  (cond 
   ((not (kb-objectp instance))
    (report-error 'user-error "Attempt to classify a non-kb-object ~a!~%" instance))
   ((is-an-instance instance)				; NEW: Don't try classifying Classes!
    (let ( (all-parents  (all-classes instance)) )  ; (immediate-classes ...) would
						      ; be faster but incomplete
	(cond ((some #'(lambda (parent)
			 (or (classify-as-member instance parent slot)
			     (classify-as-coreferential instance parent slot)))
		     all-parents)	    ; if success, then must re-iterate, as the success
	       (classify0 instance)))))))    ; may make previously failed classifications now succeed

;;; ----------------------------------------------------------------------
;;; (I) CLASSIFY INSTANCE AS BEING A MEMBER OF A CLASS
;;; ----------------------------------------------------------------------

(defun classify-as-member (instance parent &optional slot)
  (some #'(lambda (possible-new-parent)
	    (cond ((and (not (isa instance possible-new-parent))   ; already done!
			(or (null slot) (find-vals possible-new-parent slot 'member-properties)))	; must have something to offer
		   (try-classifying instance possible-new-parent))))
	(get parent 'defined-subclasses)))

;;; The hierarchy looks:       parent (eg. put)
;;;                           /                \
;;;                  instance (eg. _put12)      possible-new-parent (eg. tell)
;;;
;;; [1] Remove unifiable-with-expr -- this shortcut wasn't working as it doesn't check constraints on the classes (here Thing)
;;; [2] must check class consistency also!
(defun try-classifying (instance possible-new-parent)
  (cond ((satisfies-definition instance possible-new-parent)
;	 (cond ((unifiable-with-expr instance `#$(a Thing with . ,(FIND-SLOTSVALS POSSIBLE-NEW-PARENT 'MEMBER-PROPERTIES)))	; New test!
;	 (cond ((km `#$(,INSTANCE &? (a Thing with . ,(FIND-SLOTSVALS POSSIBLE-NEW-PARENT 'MEMBER-PROPERTIES))) :fail-mode 'fail)  ; new test [1]
	 (cond ((km `#$(,INSTANCE &? (a ,POSSIBLE-NEW-PARENT with 
					,@(FIND-SLOTSVALS POSSIBLE-NEW-PARENT 'MEMBER-PROPERTIES))) :fail-mode 'fail)  ; new test [1,2]
		(add-immediate-class instance possible-new-parent) t)
	       (t (make-comment (km-format nil "~a satisfies definition of ~a,"  instance possible-new-parent))
		  (make-comment "...but classes/properties clash!! So reclassification not made."))))))

(defun add-immediate-class (instance new-immediate-parent)
 (let* ( (old-classes (immediate-classes instance))
	 (new-classes (remove-subsumers (cons new-immediate-parent old-classes))) )
   (make-comment (km-format nil "~a satisfies definition of ~a," instance new-immediate-parent))
   (make-comment (km-format nil "so changing ~a's classes from ~a to ~a" instance old-classes new-classes))
   (put-vals instance '#$instance-of new-classes)
;  (cond ((isa instance '#$Situation) (make-situation-specific-assertions instance)))
   (make-assertions instance)	; test later	
   (un-done instance)))		; all vals to be recomputed now - now in add-slotsvals; later: No!

;;; (satisfies-definition '_get32 'db-lookup)
;;; Can we make _get32, a specialization of get, into a specialization of
;;; db-lookup?
(defun satisfies-definition (instance class)
  (km-trace 'comment "CLASSIFY: ~a has just been created/modified. Is ~a now a ~a?" 
	 instance instance class)
  (let* ( (description (bind-self `'#$(a Thing with . ,(FIND-SLOTSVALS CLASS 'MEMBER-DEFINITION)) instance)) ; NEW: add quote '
	  (satisfiedp (km `#$(,INSTANCE is ,DESCRIPTION) :fail-mode 'fail)) )
    (cond (satisfiedp (km-trace 'comment "CLASSIFY: ~a *is* a ~a!" instance class))
	  (t (km-trace 'comment "CLASSIFY: ~a is not a ~a." instance class)))
    satisfiedp))

;;; ----------------------------------------------------------------------
;;; (II) CLASSIFY INSTANCE AS BEING COREFERENTIAL WITH ANOTHER INSTANCE
;;; ----------------------------------------------------------------------

#|
This is for equating coreferential instances, eg.

	bright-color IS red

	(Red has
	   (definition (((Self isa Color) and ((Self is) = Bright)))))

	(a Color with (is (Bright)))
	-> _Color32 unifies with Red
	-> Red

BUT: Suppose an instance satisfies *two* different instances' definitions?
In fact, KM will prevent you doing this. The first classification will cause
_Color34 to be unified to Red. The second will classify Red as Another-red,
but the unification of these two isn't permitted.
|#

(defun classify-as-coreferential (instance0 parent &optional slot)
  (let ( (instance (dereference instance0)) )
    (some #'(lambda (possible-coreferential-instance)
	      (cond ((and (not (eq instance possible-coreferential-instance))   ; already done!
			  (or (null slot) (find-vals possible-coreferential-instance slot 'own-properties))) ; must have something to offer
		     (try-equating instance possible-coreferential-instance))))
	  (get parent 'defined-instances))))

(defun try-equating (instance possible-coreferential-instance)
  (cond ((satisfies-definition2 instance possible-coreferential-instance)
	 (unify-with-instance instance possible-coreferential-instance))))

; [1]. Just doing (X & Y) doesn't fail, 
(defun unify-with-instance (instance possible-coreferential-instance)
  (make-comment (km-format nil "~a satisfies definition of ~a," instance possible-coreferential-instance))
  (make-comment (km-format nil "so unifying ~a with ~a" instance possible-coreferential-instance))
  (cond ((km `(,instance & ,possible-coreferential-instance))
	 (un-done instance))		; all vals to be recomputed now - now in put-slotsvals via lazy-unify. Later: no!
	(t (report-error 'user-error "~a satisfies definition of ~a but won't unify with it!~%"
			 instance possible-coreferential-instance))))

(defun satisfies-definition2 (instance poss-coref-instance)
  (km-trace 'comment "CLASSIFY: ~a has just been created/modified. Is ~a now = ~a?" 
	 instance instance poss-coref-instance)
  (let* ( (description (bind-self `'#$(a Thing with . ,(FIND-SLOTSVALS POSS-COREF-INSTANCE 'OWN-DEFINITION)) instance)) ; NEW: add quote '
	  (satisfiedp (km `#$(,INSTANCE is ,DESCRIPTION) :fail-mode 'fail)) )
    (cond (satisfiedp (km-trace 'comment "CLASSIFY: ~a = ~a!" instance poss-coref-instance))
	  (t (km-trace 'comment "CLASSIFY: ~a \= ~a." instance poss-coref-instance)))
    satisfiedp))

;;; ======================================================================
;;;			TAXONOMIC OPERATIONS
;;; ======================================================================


;;; check frame isa genframe. Returns frame.
;;; (isa x x)	returns nil
(defun isa (instance class &optional (situation (curr-situation)))
  (instance-of instance class situation))	; synonym

(defun instance-of (instance target-class &optional (situation (curr-situation)))
  (let ( (its-classes (immediate-classes instance situation)) )
    (cond ((member target-class its-classes) instance)
	  ((and (not (null its-classes))
		(some #'(lambda (its-class) (is-subclass-of its-class target-class))
		      its-classes))
	   instance))))

(defun is-subclass-of (class target-class)
    (cond ((eq class target-class) class)
	  ((eq class '#$Thing) nil)
	  (t (let ( (superclasses (immediate-superclasses class)) )
	       (cond ((member target-class superclasses) class)
		     ((and (not (null superclasses))
			   (some #'(lambda (superclass) (is-subclass-of superclass target-class))
				 superclasses))
		      class))))))

;;; Shadow of KM. Find immediate generalizations of a frame.
;;; The top generalization is #$Thing
;;; [1] instance-of is treated as a *Non-Fluent for Slots and Situations, and so we must also check the global
;;;     situation here. For cases where it's a fluent, it's value will be cached in the local situation.
(defun immediate-classes (instance &optional (situation (curr-situation)))
  (cond ((integerp instance) '(#$Integer))
   	((numberp instance) '(#$Number))
	((assoc instance *built-in-instance-of-links*)	; e.g. t -> Boolean
	 (list (second (assoc instance *built-in-instance-of-links*))))
;	((eq instance '#$*Global) '(#$Situation))
	((member instance *built-in-slots*) '#$(Slot))
	((stringp instance) '(#$String))
	((not (inertial-fluentp '#$instance-of)) ; allow redefinition of this thing
	 (or (remove-constraints (append (cond (*are-some-definitions* (get-vals instance '#$instance-of 'own-definition *global-situation*)))
					 (get-vals instance '#$instance-of 'own-properties *global-situation*)))
	     '#$(Thing)))
	((eq situation *global-situation*)
	 (or (remove-constraints (append (cond (*are-some-definitions* (get-vals instance '#$instance-of 'own-definition situation)))
					 (get-vals instance '#$instance-of 'own-properties situation)))
	     '#$(Thing)))
	((already-done instance '#$instance-of situation) 
	 (or (get-vals instance '#$instance-of 'own-properties situation) 
	     (get-vals instance '#$instance-of 'own-properties *global-situation*) 	; [1]
	     '#$(Thing)))
	(t (prog1
	       (immediate-classes0 instance situation)
	     (note-done instance '#$instance-of situation)))))

;;; REVISED: We must do more work here when there are situations.
(defun immediate-classes0 (instance &optional (situation (curr-situation)))
  (let* ( (local-classes-and-constraints (get-vals instance '#$instance-of 'own-properties situation))
	  (local-constraints (remove-if-not #'constraint-exprp local-classes-and-constraints))
	  (supersituation-classes (my-mapcan #'(lambda (supersituation)
						 (immediate-classes instance supersituation))
					     (immediate-supersituations situation)))
	  (projected-classes (projected-classes instance situation local-constraints))
	  (definitional-classes (cond (*are-some-definitions* (get-vals instance '#$instance-of 'own-definition situation)))) )
    (cond ((some #'(lambda (class)				;	 [1] Local Classes are *NOT* a complete list
		     (and (neq class '#$Thing)
			  (not (member class local-classes-and-constraints))))
		 (append supersituation-classes projected-classes definitional-classes))
	   (let* ( (local-classes (remove-constraints local-classes-and-constraints))
		   (all-classes (remove-subsumers (append local-classes supersituation-classes projected-classes definitional-classes))) )
	     (put-vals instance '#$instance-of (append local-constraints all-classes) :situation situation)		; note-done is done above
	     all-classes))
	  ((remove-constraints local-classes-and-constraints))			; [2] Local Classes *ARE* a complete list
	  ((and (checkkbp) (not (known-frame instance)))
	   (report-error 'user-warning "Object ~a not declared in KB.~%" instance)
	   '(#$Thing))
; Hmm...can we get rid of automatically computed meta-classes?
;	  ((find-vals instance '#$superclasses) 
;	   (put-vals instance '#$instance-of '(#$Class) :situation situation)		; note-done is done above
;	   '(#$Class))
	  (t (cond ((checkkbp) 
		    (report-error 'user-warning "Parent (superclasses/instance-of) for ~a not declared.~%" instance)))
	     '(#$Thing)))))

(defun projected-classes (instance situation local-classes-and-constraints)
  (let ( (prev-situation (prev-situation situation)) )
    (cond (prev-situation (filter-using-constraints (immediate-classes instance prev-situation) local-classes-and-constraints)))))

;;; ======================================================================

(defun immediate-superclasses (class)
  (cond ((eq class '#$Thing) nil)
	((member class *built-in-classes*)
	 (or (rest (assoc class *built-in-superclass-links*))		; e.g. (immediate-superclasses '#$Integer) -> (Number)
	     '#$(Thing)))
	((get-vals class '#$superclasses 'own-properties *global-situation*)) ; necessarily will be in global situation, as superclasses is a non-fluent slot
	((and (checkkbp) (not (known-frame class)))
	 (report-error 'user-warning "Class ~a not declared in KB.~%" class)
	 '(#$Thing))
;	((is-an-instance class) nil)
	((checkkbp) 
	 (report-error 'user-warning "superclasses not declared for `~a'.~%I'll assume superclass `Thing'.~%" class)
	 '(#$Thing))
	(t '(#$Thing))))

(defun immediate-subclasses (class)
;  (find-vals class '#$subclasses))
  (cond ((eq class '#$Thing) (subclasses-of-thing))
	((get-vals class '#$subclasses 'own-properties *global-situation*))	; necc. will be in global situation
	((inv-assoc class *built-in-superclass-links*) 				; e.g. (immediate-subclasses '#$Number) -> (Integer)
	 (list (first (inv-assoc class *built-in-superclass-links*))))))

;;; ----------
;;; Returns subclasses of Thing, excluding built-in classes which aren't ever used in the KB.
;;; Here we infer subclasses for those unplaced classes.
;;; [1,2,3] Three pieces of evidence that the object is a class: [1] it has subclasses [2] it has instances [3] it's a built-in class.
;;; [4] These two built-in classes *don't* have Thing as their superclass.
;;; [5] Special case: If Integer (say) is explicitly in the KB, but Number isn't, then we should introduce Number in the retrieved
;;; 	taxonomy for printing and question-answering.
(defun subclasses-of-thing ()
  (let* ( (all-objects (dereference (get-all-objects)))
	  (unplaced-classes+instances				; + includes classes explicitly directly under Thing
	   (remove-if #'(lambda (concept)
			  (let ( (superclasses (get-vals concept '#$superclasses 'own-properties *global-situation*)) )
			    (or (and superclasses 
				     (not (equal superclasses '#$(Thing))))		   ; ie. is placed (and not under Thing)
				(assoc concept *built-in-superclass-links*))))   	   ; [4], e.g. Integer, Aggregation-Slot
		      all-objects))
	  (all-situations (all-situations))
	  (unplaced-classes (remove-if-not #'(lambda (concept)
					       (or (get-vals concept '#$subclasses 'own-properties *global-situation*)	   ; [1]
						   (some #'(lambda (situation)
							     (get-vals concept '#$instances 'own-properties situation))	   ; [2]
							 all-situations)
						   (member concept *built-in-classes*)))				   ; [3]
					   unplaced-classes+instances)) 
	  (extra-classes (my-mapcan #'(lambda (class-superclass) 							   ; [5]
					(cond ((and (member (first class-superclass) all-objects)
						    (not (member (second class-superclass) unplaced-classes)))
					       (rest class-superclass))))
				    *built-in-superclass-links*)) )
    (remove '#$Thing (append extra-classes unplaced-classes))))

;;; ----------

;(defun immediate-subslots (slot)
;  (cond ((undeclared-slot slot) nil)		; supposed to be for efficiency, but slows it down!
;	(t (find-vals slot '#$subslots))))

(defun immediate-subslots (slot)
  (cond ; there are none yet ! ((second (assoc slot *built-in-subslots*)))
	(*are-some-subslots* 			; optimization flag (worth it?)
	 (find-vals slot '#$subslots))))

;;; NB *doesn't* include slot.
(defun all-subslots (slot)
  (let ( (immediate-subslots (immediate-subslots slot)) )
    (append immediate-subslots (mapcan #'all-subslots immediate-subslots))))

;;; ======================================================================
;;;		IMMEDIATE SLOTVALS VIA PROJECTION
;;; To avoid getting stuck in a loop, we *don't* call KM recursively.
;;; This is a optimized version of km-slotvals-via-projection in
;;; interpreter.lisp, which doesn't evaluate expressions or import info
;;; from supersituations. It's here just to project instance-of relationships.
;;; ======================================================================

;;; NEW: Look back N situations
;;; This ASSUMES we are already in a local situation.
(defun immediate-classes-via-projection (instance)
  (fast-slotvals-via-projection instance '#$instance-of (curr-situation)))

;;; Value is either [1] in prev-situation or [2] recursively look in previous situations.
;;; NOTE: When we've found a value, don't look back any further!
;;; [3] remove constraint exprs: case in point: (X has (instance-of ((<> Rabbit)))) - we *don't* want to project this.
;;; This slightly more advanced version checks <> constraints e.g. for instance-of (which is all this is ever used for)
;;; [3] Cache the results!
;;; [4] This revised version doesn't use find-vals (see test-suite/inherit.km) as 
;;; 	find-vals itself doesn't use projection. Thus KM misses values which should be
;;;     projected into a supersituation. So instead, we copy the bits of find-vals we want here.
;;;	This version is written with slot = instance-of in mind, so we *ignore*
;;;	subslots and classes, which find-vals normally covers.
(defun fast-slotvals-via-projection (instance slot situation &optional done-sitns)
 (cond 
  ((member situation done-sitns) nil)					; looping check
  (t (let* ( 
; [4]	     (curr-vals-and-constraints (find-vals instance slot 'own-properties situation))
	     (curr-vals-and-constraints
	      (or (get-vals instance slot 'own-properties situation)
		  (some #'(lambda (supersituation)
			    (fast-slotvals-via-projection instance slot supersituation))
			(all-supersituations situation))))
	     (curr-vals (remove-if #'constraint-exprp curr-vals-and-constraints))
	     (prev-situation (prev-situation situation))
	     (projected-vals (or curr-vals
				 (and prev-situation
				      (fast-slotvals-via-projection instance slot prev-situation (cons situation done-sitns))))) )  ; [2]
       (cond ((and (null curr-vals) 					; no values in situation [3]
		   projected-vals)					; but were some in previous situation
;;		   curr-vals-and-constraints)				; and curr situation *does* have constraints, so 
	      ; NOTE: curr-vals-and-constraints NECESSARILY are all constraints, and curr-vals is NIL
	      (let ( (new-vals (filter-using-constraints projected-vals curr-vals-and-constraints)) )
		(cond (new-vals
		       (put-vals instance slot (append new-vals curr-vals-and-constraints) :situation situation)
		       (note-done instance slot situation)
		       new-vals))))
	     (t projected-vals))))))
#|
;;; [1] Misses inheritance! Probably not important, but better cover that case -> [2]
;;; [2] km-unique, as may be a path there (unlikely!, did in previous test suites though)
;;; [3] Don't consider it an error to be missing a :args structure, so we can say (Y1999 has (next-situation (Y2000))) for short.
(defun prev-situation (situation)
; (let ( (prev-situation-args-structure 
;	          (get-vals situation '#$prev-situation 'own-properties *global-situation*)) ) ; eg ((:args _Sit23 _Action23)) [1]
  (let ( (prev-situation-args-structure 
	     (km-unique (find-unique-val situation '#$prev-situation :situation *global-situation* :fail-mode 'fail) ; eg ((:args _Sit23 _Action23)) [2]
			:fail-mode 'fail)) )										; [3]
    (cond ((km-argsp prev-situation-args-structure)
	   (arg1of prev-situation-args-structure))
	  (t prev-situation-args-structure))))	
|#

;;; [1] Misses inheritance! Probably not important, but better cover that case -> [2]
;;; [2] km-unique, as may be a path there (unlikely!, did in previous test suites though)
;;; [3] Don't consider it an error to be missing a :args structure, so we can say (Y1999 has (next-situation (Y2000))) for short.
(defun prev-situation (situation)
 (let ( (prev-situation-args-structures 
	          (get-vals situation '#$prev-situation 'own-properties *global-situation*)) ) ; eg ((:args _Sit23 _Action23)) [1]
;  (let ( (prev-situation-args-structure 
;	     (km-unique (find-unique-val situation '#$prev-situation :situation *global-situation* :fail-mode 'fail) ; eg ((:args _Sit23 _Action23)) [2]
;			:fail-mode 'fail)) )										; [3]
   (cond ((null prev-situation-args-structures) nil)
	 ((singletonp prev-situation-args-structures)
	  (let ( (prev-situation-args-structure (km-unique (first prev-situation-args-structures) :fail-mode 'fail)) )
	    (cond ((not (equal prev-situation-args-structure 
			       (first prev-situation-args-structures)))
		   (put-vals situation '#$prev-situation (list prev-situation-args-structure)
			     :situation *global-situation*)
		   (note-done situation '#$prev-situation *global-situation*)))
	    (cond ((km-argsp prev-situation-args-structure)
;		   (km-format t "prev-situation-args-structures = ~a~%" prev-situation-args-structures)
		   (arg1of prev-situation-args-structure))
		  (t prev-situation-args-structure))))
	 (t (report-error 'user-error "Situation ~a has multiple previous situations, but that isn't allowed!~%  (~a has (prev-situation ~a))~%"
			  situation prev-situation-args-structures)))))

;;; ========================================

;;; before-situation of an event
(defun before-situation (event)
 (let ( (before-situation-args-structures 
	          (get-vals event '#$before-situation 'own-properties *global-situation*)) ) ; eg ((:args _Sit23 _Action23)) [1]
;  (let ( (before-situation-args-structure 
;	     (km-unique (find-unique-val event '#$before-situation :situation *global-situation* :fail-mode 'fail) ; eg ((:args _Sit23 _Action23)) [2]
;			:fail-mode 'fail)) )										; [3]
   (cond ((null before-situation-args-structures) nil)
	 ((singletonp before-situation-args-structures)
	  (let ( (before-situation-args-structure (km-unique (first before-situation-args-structures) :fail-mode 'fail)) )
	    (cond ((not (equal before-situation-args-structure 
			       (first before-situation-args-structures)))
		   (put-vals event '#$before-situation (list before-situation-args-structure)
			     :situation *global-situation*)
		   (note-done event '#$before-situation *global-situation*)))
	    (cond ((km-argsp before-situation-args-structure)
;		   (km-format t "before-situation-args-structures = ~a~%" before-situation-args-structures)
		   (arg1of before-situation-args-structure))
		  (t before-situation-args-structure))))
	 (t (report-error 'user-error "Action ~a has multiple before situations, but that isn't allowed!~%  (~a has (before-situation ~a))~%"
			  event before-situation-args-structures)))))

;;; ----------

#|
(defun fast-slotvals-via-projection (instance slot situation &optional done-sitns)
 (cond 
  ((member situation done-sitns) nil)					; looping check
  (t (let ( (prev-situation-args-structure (get-vals situation '#$prev-situation 'own-properties *global-situation*)) ) ; eg ((:args _Sit23 _Action23))
       (cond ((and prev-situation-args-structure
;new		   (minimatch prev-situation-args-structure '((#$:args ?situation ?action))))
;new	      (let* ( (prev-situation (second (first prev-situation-args-structure)))
#|old|#	      )
#|old|#	      (let* ( (prev-situation (first prev-situation-args-structure))
		      (projected-vals (or (find-vals instance slot 'own-properties prev-situation)      ; [1]
					  (fast-slotvals-via-projection instance slot prev-situation (cons situation done-sitns)))) )  ; [2]
		(cond (projected-vals
		       (let ( (curr-situation (curr-situation)) 
			      (projected-vals2 (remove-if #'constraint-exprp projected-vals)) )		; [3]
			 (cond (projected-vals2
				(cond ((neq situation curr-situation) (change-to-situation situation)))
				(put-vals instance slot projected-vals2)
				(note-done instance slot)
				(cond ((neq situation curr-situation) (change-to-situation curr-situation)))
				projected-vals2))))))))))))
|#
;;; ======================================================================

(defun bind-self (expr self) (subst self '#$Self expr))

;;; Returns the most specific class(es) in a list
;;; (remove-subsumers '(car vehicle car tree)) -> (car tree)
;;; NOTE preserves order, so if there are no subsumers, then (remove-subsumers x) = x.
(defun remove-subsumers (classes)
  (remove-duplicates
   (remove-if #'(lambda (class)
		  (some #'(lambda (other-class) 
			    (and (not (eq other-class class))
				 (is-subclass-of other-class class)))	 classes))
	      classes)
   :from-end t))

;;; Returns the most general class(es) in a list
;;; (remove-subsumees '(car vehicle car tree)) -> (vehicle tree)
;;; NOTE preserves order, so if there are no subsumees, then (remove-subsumees x) = x.
(defun remove-subsumees (classes)
  (remove-duplicates
   (remove-if #'(lambda (class)
		  (some #'(lambda (other-class) 
			    (and (neq other-class class)
				 (is-subclass-of class other-class)))	 classes))
	      classes)
   :from-end t))

;;; (classes-subsume-classes '(vehicle expensive-thing) '(car very-expensive-thing))
;;; AND
;;; (classes-subsume-classes '(vehicle expensive-thing) '(car very-expensive-thing wheeled-thing))
;;; case [1] should never be necessary, but just in case...

;(defun classes-subsume-classes (classes1 classes2)
;  (let ( (trimmed-classes2 (remove-subsumers classes2)) )	; [1] eg. (car thing) -> (car)
;    (subsetp trimmed-classes2 (remove-subsumers (append classes1 trimmed-classes2)))))

;;; Or more efficiently...every class1 has some class2 which is a subclass of it.
(defun classes-subsume-classes (classes1 classes2)
  (every #'(lambda (class1)
	     (some #'(lambda (class2) (is-subclass-of class2 class1))
		   classes2))
	 classes1))

;;; ======================================================================
;;;		AND FOR NORMAL SPECIALIZATION LINKS
;;; ======================================================================

(defun all-classes (instance)
  (cons '#$Thing (remove-duplicates (mapcan #'all-superclasses0 (immediate-classes instance)))))

;;; ----------

;;; This *doesn't* include class in the list
(defun all-superclasses (class) 
  (cond ((neq class '#$Thing)
	 (cons '#$Thing (remove-duplicates (my-mapcan #'all-superclasses0 (immediate-superclasses class)))))))

;;; Returns a *list* of superclasses, *including* class, but *not* including #$Thing, and possibly with duplicates.
(defun all-superclasses0 (class)
  (cond ((eq class '#$Thing) nil)		; for efficiency. #$Thing is added by all-superclasses above
	(t (cons class (my-mapcan #'all-superclasses0 (immediate-superclasses class))))))

;;; ----------

;;; This *doesn't* include class in the list
(defun all-subclasses (class) 
  (remove-duplicates (mapcan #'all-subclasses0 (immediate-subclasses class))))

;;; Returns a *list* of subclasses, *including* class, but *not* including #$Thing, and possibly with duplicates.
(defun all-subclasses0 (class)
  (cons class (mapcan #'all-subclasses0 (immediate-subclasses class))))

;;; ----------

;;; Unlike the other all-** functions, all-supersituations *INCLUDES* the original situation.
;;; I also insist *global-situation* is included in the list, even if not explicitly listed as a 
;;; supersituation.
(defun all-supersituations (situation) 
  (cond ((neq situation *global-situation*)
	 (cons *global-situation* (remove-duplicates 
				   (mapcan #'all-supersituations0 (immediate-supersituations situation)))))))

;;; Returns a *list* of situations, including situation but NOT including *global-situation*.
(defun all-supersituations0 (situation)
  (cond ((eq situation *global-situation*) nil)	  ; For efficiency. *global-situation* is added by all-supersituations
	(t (cons situation (mapcan #'all-supersituations0 (immediate-supersituations situation))))))

;;; ======================================================================
;;;			ALL-INSTANCES: find all instances of a class
;;; ======================================================================
#|
Includes dereferencing (in remove-dup-instances).
This is only used for:
	- (all-situations)
	- Handling a user's all-instances query
	- (mapc #'un-done (all-instances class))  after an (every ...) assertion. But this isn't quite
		right, we want to undo instances in class within a situation only too.
        - (all-instances '#$Slot), for (showme-all instance) and (evaluate-all instance)
	- we should really use it for Partition also; sigh...
Thus, we can get away being inefficient!!
|#
;(defun all-instances (class)
;  (remove-dup-instances
;   (append (find-vals class '#$instances)		- efficient, but incomplete
;	    (mapcan #'all-instances (find-vals class '#$subclasses)))))

; [1] optimize for these three classes (Slot, Partition, Situation)
(defun all-instances (class)
  (cond ((or (member class *built-in-classes-with-nonfluent-instances-relation*)     ; [1]
	     (some #'(lambda (superclass) (is-subclass-of class superclass))
		   *built-in-classes-with-nonfluent-instances-relation*))
	 (all-instances-via-getvals class))
	(t (all-instances-via-km class))))

; fast - used internally by KM
(defun all-instances-via-getvals (class)
  (remove-dup-instances
   (append (get-vals class '#$instances 'own-properties *global-situation*)
	   (my-mapcan #'all-instances-via-getvals (immediate-subclasses class)))))

; slower - not used internally 
(defun all-instances-via-km (class)
  (remove-dup-instances
   (append (km `#$(the instances of ,CLASS) :fail-mode 'fail)		; [1] less efficient, but complete (does projection + constraint enforcement)
	   (my-mapcan #'all-instances-via-km (immediate-subclasses class)))))

;;; ----------

(defun all-prototypes (class)
  (remove-dup-instances
   (append (find-vals class '#$prototypes)
	   (mapcan #'all-prototypes (immediate-subclasses class)))))
;	   (mapcan #'all-prototypes (find-vals class '#$subclasses)))))

;;; ----------------------------------------

;;; Return a list of all situations used in the current session.
;;; It includes doing dereferencing (in all-instances)
;;; [1] Strictly, should be remove-dup-instances; however all-instances has already done this (including dereferencing), so we just need to make sure 
;;;	we don't have *global-situation* in twice.
(defun all-situations () 
  (cond ((am-in-global-situation)
	 (remove-duplicates (cons *global-situation* (all-instances '#$Situation)) :from-end t))		; [1]
	(t (let ( (curr-situation (curr-situation)) )
	     (change-to-situation *global-situation*)
	     (prog1
		 (remove-duplicates (cons *global-situation* (all-instances '#$Situation)) :from-end t)		; [1]
	       (change-to-situation curr-situation))))))

;;; [1] NB Can't do a get-vals, as find-vals calls immediate-situations and we'd have a loop!
;;; We assume all situation facts and relationships are asserted in the global situation.
;;; A test in create-named-instance helps ensure this is maintained. We also check local for safety ([2]).
(defun immediate-supersituations (situation)
  (cond ((eq situation *global-situation*) nil)
	(t (or (get-vals situation '#$supersituations 'own-properties *global-situation*)
	       (get-vals situation '#$supersituations 'own-properties (curr-situation))
	       (list *global-situation*)))))

;;; ======================================================================
;;;				PARTITIONS
;;; ======================================================================
#|
Declaration of partitions (mutually exclusive sets of classes):
KM> (a Partition with
       (members (Physobj Information-Bearing-Object)))

To see if two classes are disjoint, in KM we'd do:
KM> (exists (oneof (the instances of Partition)
	     where (    ((the members of It) includes <CLASS1>)
		    and ((the members of It) includes <CLASS2>)
		    and (<CLASS1> /= <CLASS2>))))

Here we encode a fast, lightweight version of this query.
|#
;;; Can make it a teensy bit faster by passing partitions, rather than recomputing them
;;; per call to disjoint-classes.
(defun disjoint-classes (class1 class2)
  (and (neq class1 class2)
       (some #'(lambda (partition)
		 (let ( (partition-members (get-vals partition '#$members 'own-properties *global-situation*)) )
		   (and (member class1 partition-members)
			(member class2 partition-members))))
	     (all-instances '#$Partition))))

;;; classes1 and classes2 are disjoint if it's impossible for something to be
;;; BOTH a member of all of classes1 AND all of classes2.
;;; This is true if there exists some member of classes1 and some member of
;;; classes2 which are disjoint (mutually exclusive). This is a potentially
;;; computationally expensive thing to compute, the way I've done it here.
;(defun disjoint-class-sets (classes1 classes2) 
;    (some #'(lambda (class1)
;	      (some #'(lambda (class2) (disjoint-classes class1 class2 partitions)) classes2))
;	  classes1))

(defun disjoint-class-sets (classes1 classes2)
  (and (not (equal classes1 classes2))
       (not (subsetp classes1 classes2))
       (not (subsetp classes2 classes1))
       (some #'(lambda (partition)
		 (let ( (partition-members (get-vals partition '#$members 'own-properties *global-situation*)) )
		   (intersection classes2 (set-difference partition-members classes1))))
	     (all-instances '#$Partition))))

;;; Compatible: Classes mustn't be disjoint, and may have a subsumption requirement also.
;;; Note: The subsumption requirement isn't that the instance is subsumed by a class,
;;;	  but that one set of classes is subsumed by another.
;;; [1] all-superclasses0 is like all-superclasses, except it INCLUDES class, and MAY NOT 
;;;     include Thing unless Thing is explicitly declared as a superclass. This is exactly 
;;;     what we want here!
(defun compatible-classes (&key instance1 instance2 classes1 classes2 classes-subsumep)
  (let ( (immediate-classes1 
	  (or classes1
	      (and instance1 (immediate-classes instance1))
	      (report-error 'program-error "compatible-classes: missing instance/classes for instance1!~%")))
	 (immediate-classes2 
	  (or classes2
	      (and instance2 (immediate-classes instance2))
	      (report-error 'program-error "compatible-classes: missing instance/classes for instance2!~%"))) )
    (cond (classes-subsumep
	   (or (classes-subsume-classes immediate-classes1 immediate-classes2)
	       (classes-subsume-classes immediate-classes2 immediate-classes1)))
	  (t (not (disjoint-class-sets (my-mapcan #'all-superclasses0 immediate-classes1) ; [1]
				       (my-mapcan #'all-superclasses0 immediate-classes2)))))))

;;; ======================================================================
;;;			SLOTS: Cardinalities
;;; ======================================================================

(defconstant *default-default-fluent-status* '#$*Inertial-Fluent)	; this is the reset value after a (reset-kb)
;(defconstant *default-default-fluent-status* '#$*Fluent) ; neah, don't change this!
(defparameter *default-fluent-status* *default-default-fluent-status*)	; user can change this

(defun default-fluent-status (&optional status)
  (cond ((null status) 
	 (km-format t "By default, slots have fluent-status = ~a.~%" *default-fluent-status*)
	 '#$(t))
        ((member status *valid-fluent-statuses*) 
;	 (setq *default-fluent-status* status)
	 (make-transaction `(setq *default-fluent-status* ,status))
	 (km-format t "By default, slots now have fluent-status = ~a.~%" *default-fluent-status*)
	 '#$(t))
	(t (report-error 'user-error "Invalid default-fluent-status `~a'! (Must be one of ~a)~%" status *valid-fluent-statuses*))))

;;; ----------

(defun fluentp (slot)
  (case *default-fluent-status* 
	(#$*Non-Fluent 		      (member (fluent-status slot)
					      '#$(*Fluent *Inertial-Fluent)))
	(#$(*Fluent *Inertial-Fluent) (neq (fluent-status slot)
					   '#$*Non-Fluent))))

(defun inertial-fluentp (slot)
  (case *default-fluent-status* 
	(#$(*Non-Fluent *Fluent) (eq (fluent-status slot)
				     '#$*Inertial-Fluent))
	(#$*Inertial-Fluent      (not (member (fluent-status slot)
					      '#$(*Non-Fluent *Fluent))))))
    
;;; ----------

;;; [1] I could save a little CPU time with this
;;; but this would remove the error check for inconsistent status. 
;;; Even better would be to cache the whole fluentp result. But I don't think I need these
;;; optimizations for now.
;; [2] Provide *either* an instance *or* a set of classes (of a non-created instance) to 
;;;	see if it's an event.
;;; [3] These are add-list, del-list, pcs-list, ncs-list. In this case, allow user override if he/she wants.
(defun fluent-status (slot)
  (cond 
   ((member slot *built-in-inertial-fluent-slots*) '#$*Inertial-Fluent)
   ((member slot *built-in-slots*) '#$*Non-Fluent)
   ((let ( (fluent-status1 (find-unique-val slot '#$fluent-status :fail-mode 'fail)) 
	     (fluent-status2 #|(cond ((not fluent-status1) [1] |# (find-unique-val (invert-slot slot) '#$fluent-status :fail-mode 'fail)) )
	(cond ((and fluent-status1 (not (member fluent-status1 *valid-fluent-statuses*)))
	       (report-error 'user-error "Invalid fluent-status `~a' on slot `~a'! (Should be one of: ~a)~%" 
			     fluent-status1 slot *valid-fluent-statuses*))
	      ((and fluent-status2 (not (member fluent-status2 *valid-fluent-statuses*)))
	       (report-error 'user-error "Invalid fluent-status `~a' on slot `~a'! (Should be one of: ~a)~%" 
			     fluent-status2 (invert-slot slot) *valid-fluent-statuses*))
	      ((and fluent-status1 fluent-status2 (neq fluent-status1 fluent-status2))
	       (report-error 'user-error "Inconsistent declaration of fluent-status! ~a has fluent-status ~a, but ~a has fluent-status ~a.~%" 
			     slot fluent-status1 (invert-slot slot) fluent-status2))
	      (t (or fluent-status1 fluent-status2)))))
   ((member slot *built-in-non-inertial-fluent-slots*) '#$*Fluent)))		; [3]


;;; ----------

#|
;; Provide *either* an instance *or* a set of classes (of a non-created instance)
(defun is-event (instance &key classes)
  (or (and instance (isa instance '#$Event))
      (and classes (some #'(lambda (class) 
			     (is-subclass-of class '#$Event))
			 classes))
      (and (null instance) (null classes)
	   (report-error 'program-error "(is-event ...): Missing both instance and classes!~%"))))
|#
;;; ----------

#|
(defun global-only-instancep (instance)
  (find-vals instance '#$global-only))
|#

(defun situation-specificp (slot)
  (or (member slot *built-in-situation-specific-slots*)
      (and (not (member slot *built-in-slots*))	   ; quicker than doing find-vals for these
	   (find-vals slot '#$situation-specific))))

(defun single-valued-slotp (slot) 
  (member (slot-cardinality slot) '#$(1-to-1 N-to-1)))

(defun multivalued-slotp (slot) (not (single-valued-slotp slot)))

(defun inherit-with-overrides-slotp (slot) (get-vals slot '#$inherit-with-overrides 'own-properties *global-situation*))

;(defun complete-slotp (slot) 
;  (or (member slot *built-in-complete-slots*)
;      (not (inertial-fluentp slot))))
;      (find-vals slot '#$complete)))

;;; Rather inefficient, I shouldn't need to do 2 kb-accesses for every slot query to see if it's single-valued or not!
(defun slot-cardinality (slot)
  (cond 
   ((member slot *built-in-single-valued-slots*) '#$N-to-1)
   ((member slot *built-in-multivalued-slots*) '#$N-to-N)
   ((or (slot-cardinality2 slot)
	(invert-cardinality (slot-cardinality2 (invert-slot slot)))
	*default-cardinality*))))

(defun slot-cardinality2 (slot)
  (case slot
    (t (let ( (cardinalities (find-vals slot '#$cardinality)) )
	 (cond ((null cardinalities) nil) 		; was *default-cardinality* - but I need to check the slot's inverse first!
	       (t (cond ((>= (length cardinalities) 2)
			 (report-error 'user-error "More than one cardinality ~a declared for slot ~a!Just taking the first ...~%" 
				       cardinalities slot)))
		  (cond ((not (member (first cardinalities) *valid-cardinalities*))
			 (report-error 'user-error 
				       "Invalid cardinality ~a declared for slot ~a.~%(Should be one of ~a). Assuming default ~a instead~%" 
				       (first cardinalities) slot *valid-cardinalities* *default-cardinality*)
			 *default-cardinality*)
			(t (first cardinalities)))))))))

(defun invert-cardinality (cardinality)
  (cond ((eq cardinality nil) nil)
	((eq cardinality '#$1-to-N) '#$N-to-1)
	((eq cardinality '#$N-to-1) '#$1-to-N)
	((eq cardinality '#$N-to-N) '#$N-to-N)
	((eq cardinality '#$1-to-1) '#$1-to-1)
	(t (report-error 'user-error "Invalid cardinality ~a used in KB~%(Should be one of ~a)~%" cardinality *valid-cardinalities*)
	   cardinality)))

;;; ======================================================================
;;;			SLOTS: Inverses
;;; ======================================================================

;;; Install inverses for a full frame structure. 
;;; We only install inverses where the val is an atomic instance, and is on
;;; the top-level frame (rather than an embedded unit)
; NO LONGER USED
;(defun install-all-inverses (frame slotsvals &optional (situation (curr-situation)))
;  (mapc #'(lambda (slotvals)
;	    (install-inverses frame (slot-in slotvals) (vals-in slotvals) situation))
;	slotsvals))

#|
Automatic installation of inverse links:
eg. (install-inverses '*Fred 'loves '(*Sue))
will install the triple  (*Sue loves-of (*Fred)) in the KB.

[1] NOTE: special case for slot declarations:
	(install-inverses 'from 'inverse '(to))
want to assert   
	(to (inverse (from)) (instance-of (Slot)))
not just
	(to (inverse (from))) 		; KM think's its a Class by default
and also (situation-specific (t)) if the forward slot is situation-specific.
This is justified because we know inverse's domain and range are Slot.

[2] Complication with Situations and projection: 
  If   Fred loves {Sue,Mary}
  Then we km-assert Mike loves Mary,
  Then when we install-inverses, we assert Mary loves-of Mike, which over-rides
	(and prevents projection of) the old value of Mary loves-of Fred. So
  	we have to prevent installation of inverses for projected facts, or
	project the inverses also somehow.
  This has now been fixed; partial information is now merged with, rather than 
    	over-rides, projected information.

With multiargument values, this is rather intricate...
    (install-inverses Fred loves (:args Sue lots))
  -> (install-inverse (:args Sue lots) loved-by Fred)
   ->  (install-inverse Sue loved-by (:args Fred lots))				Assert
   AND POSSIBLY (install-inverse lots amount-of-love-given-to (:args Sue Fred))	Assert
   AND IF SO, ALSO (install-inverses lots amount-of-love-given-to (:args Sue Fred))
    ->  (install-inverse Sue receives-love-of-amount (:args lots Fred))		Assert
     AND POSSIBLY (install-inverse Fred gives-amount-of-love (:args lots Sue))
     AND IF SO, ALSO (install-inverses Fred gives-amount-of-love (:args lots Sue))
    -> ...
 
|#
(defun install-inverses (frame slot vals &optional (situation (curr-situation)))
  (cond ((not (listp vals))
	 (report-error 'program-error "Non-list ~a passed to (install-inverses ~a ~a ~a)!~%" vals frame slot vals))
        ((not (non-inverse-recording-slot slot))
	 (let ( (invslot (invert-slot slot)) )
	   (mapc #'(lambda (val)
		     (install val invslot frame slot situation))
		 vals)))))

#|
Install a link (invframe0 invslot invval).
This basically does an add-val, except it also does:
   1. If invframe0 is a Slot, and we're declaring an inverse, then KM also copies the situation-specific property
   		from the invframe0's inverse to this frame.
   2. If invframe0 is a multi-argument structure (:args v1 v2), then as well as asserting (invframe0 invslot v1)
		we also assert (invframe0 inv2slot v2), and possibly (invframe0 inv3slot v3).
Note that to make sure inverses of inverse2's are installed, we set install-inversesp to t if invval is a (:args v1 v2)
  structure [1]. This will eventually terminate, as the "don't already know it" test fails:
		(not (member invval (find-vals invframe invslot 'own-properties situation) :test #'equal))) ; don't already know it
|#
(defun install (invframe0 invslot invval slot &optional (situation (curr-situation)))
  (let ( (invframe (dereference invframe0)) )
    (cond ((and (kb-objectp invframe)
		(not (non-inverse-recording-concept invframe))    		; eg. don't want boolean (T has (open-of (Box1))
		(not (member invval (find-vals invframe invslot 'own-properties situation) :test #'equal)))  ; don't already know it
	   (let ( (install-inversesp (km-argsp invval)) )			    ; [1] nil, unless a :args structure, in which case iterate
	     (add-val invframe invslot invval install-inversesp situation))	    ;     so all inverses are installed.
	   (cond ((member slot '#$(inverse inverse2 inverse3))			    ; See earlier
		  (add-val invframe '#$instance-of '#$Slot t situation)
		  (cond ((find-vals invval '#$situation-specific 'own-properties situation) ; copy situation-specific property from if given
			 (add-val invframe '#$situation-specific 
				  (find-vals invval '#$situation-specific 'own-properties situation)
				  t situation)))))
	   (classify invframe))		; reclassify
	  ((km-argsp invframe)							; multiargument value, eg. Fred loves (:args Sue lots)
	   (install (second invframe) invslot 				; do first argument...    Sue loved-by (:args Fred lots)
			    `#$(:args ,INVVAL ,@(REST (REST INVFRAME))) slot situation)   
	   (cond ((and (third invframe)						; do second argument...    lots love-given-to (:args Sue Fred)
		       (or (assoc slot *built-in-inverse2s*)
			   (find-unique-val slot '#$inverse2 :fail-mode 'fail)))
		  (let ( (inv2slot (or (second (assoc slot *built-in-inverse2s*))
				       (find-unique-val slot '#$inverse2)))
			 (modified-args `#$(:args ,(SECOND INVFRAME) ,INVVAL ,@(REST (REST (REST INVFRAME))))) )	;  (:args Sue Fred)
		    (install (third invframe) inv2slot modified-args slot situation))))
	   (cond ((and (fourth invframe)							; do third argument
		       (find-unique-val slot '#$inverse3 :fail-mode 'fail))
		  (let ( (inv3slot (find-unique-val slot '#$inverse3))
			 (modified-args `#$(:args ,(SECOND INVFRAME) ,(THIRD INVFRAME) ,INVVAL ,@(REST (REST (REST (REST INVFRAME)))))) )
		    (install (fourth invframe) inv3slot modified-args slot situation))))))))

;;; ----------

;;; Undo the operation:
(defun uninstall-inverses (frame slot vals &optional (situation (curr-situation)))
  (cond ((not (non-inverse-recording-slot slot))		
	 (let ( (invslot (invert-slot slot)) )
	   (mapc #'(lambda (val0)
		     (let ( (val (dereference val0)) )
		       (cond ((and (kb-objectp val)
				   (not (non-inverse-recording-concept val))    ; eg. don't want boolean
				   						; (T has (open-of (Box1))
				   (member frame (find-vals val invslot 'own-properties situation)))
			      (let ( (new-vals (remove frame (find-vals val invslot 'own-properties situation))) )
				(put-vals val invslot new-vals :install-inversesp nil :situation situation))))))	; install-inversesp = nil
		 vals)))))


;;; ----------
;;; Evaluate local expressions, with the intension that inverses will
;;; be installed. Used by forc function in interpreter.lisp
;;; MUST return instance as a result.
;;; We just deal with slotsvals in the current situation.

(defun eval-instance (instance)
  (eval-instances (list instance))
  instance)

;;; Note, we have to keep recurring until a stable state is reached. Just checking for newly created
;;; instances isn't good enough -- some expansions may cause delayed unifications, without creating new instances.
(defun eval-instances (&optional (instances (obj-stack)) (n 0))
  (cond 
   ((null instances) nil)
   ((>= n 100) 
    (report-error 'user-error "eval-instances in frame-io.lisp!~%Recursion is causing an infinite graph to be generated! Giving up...~%"))
   (t (let ( (obj-stack (obj-stack)) )
	(mapc #'simple-eval-instance instances)
	(cond (;(not (am-in-prototype-mode))
	       (use-inheritance)
	       (mapc #'unify-in-prototypes instances)
	       (mapc #'classify instances))
	      (t 			; ie. (am-in-prototype-mode)
	       (mapc #'eval-constraints instances)))	   			; expand (<> (the Car)) -> (<> _ProtoCar23)
	(eval-instances (set-difference (obj-stack) obj-stack) (1+ n))))))	; process newly created instances

;   (t (let ( (expansion-done? (remove nil (mapcar #'simple-eval-instance instances))) )
;	(cond (expansion-done? (eval-instances (obj-stack) (1+ n))))))))

(defun eval-constraints (instance)
  (mapc #'(lambda (slotvals)
	    (let ( (new-vals (mapcar #'(lambda (val)
					 (cond ((and (pairp val)
						     (eq (first val) '<>))
						(list '<> (km-unique (second val))))
					       (t val)))
				     (vals-in slotvals))) )
	      (cond ((not (equal slotvals new-vals))
		     (put-vals instance (slot-in slotvals) new-vals :install-inversesp nil)))))
	(get-slotsvals instance)))

;;; [1] More conservative - only evaluate paths, rather than force inheritance when only atomic instances are present.
;;; return t if some expansion was done, to make sure we get everything!
(defun simple-eval-instance (instance) 
  (remove nil
	  (mapcar #'(lambda (slotvals) 
		      (cond ((some #'(lambda (val) 
				       (and (not (is-simple-km-term val))
					    (not (constraint-exprp val))))
; for debugging				    (or (km-format t "expanding (~a has (~a (~a)))...~%" instance (slot-in slotvals) val) t)
				   (vals-in slotvals))	; [1]

			     (km `#$(the ,(SLOT-IN SLOTVALS) of ,INSTANCE) :fail-mode 'fail)
			     t)))
		  (get-slotsvals instance))))

;;; ----------------------------------------

;;; *inverse-suffix* = "-of" (case-sensitivity on) "-OF" (case-sensitivity off)
(defun invert-slot (slot)
  (cond	((second (assoc slot *built-in-inverses*)))	; use built-in declarations
	((not (check-isa-slot-object slot)) nil)
        ((first (find-vals slot '#$inverse)))		; look up declared inverse
	(t (let ( (str-slot (symbol-name slot)) )		; default computation of inverse
	     (cond ((and (> (length str-slot) 3)
			 (ends-with str-slot *inverse-suffix*)) 		; "parts-of"
		    (intern (trim-from-end str-slot *length-of-inverse-suffix*)))
		   (t (intern (concat str-slot *inverse-suffix*))))))))

;;; ======================================================================
;;;		SLOTS: Check conformance with slot declarations
;;; ======================================================================

(defun check-isa-slot-object (slot)
  (cond ((listp slot)
	 (report-error 'user-error "Non-atomic slot ~a encountered! (Missing parentheses in expression?)~%" slot))
	((numberp slot)
	 (report-error 'user-error "Numbers can't be used as slots! (A slot named `~a' was encountered)~%" slot))
	((not (slot-objectp slot))
	 (report-error 'user-error "Invalid slot name `~a' encountered! (Slots should be symbols)~%" slot))
	(t)))		; otherwise, it's a slot!

(defun check-slot (frame slot values)
  (cond 
   ((not (checkkbp)))
   ((built-in-concept slot))
   ((undeclared-slot slot))
   (t (let ( (domain (or (find-unique-val slot '#$domain :fail-mode 'fail)
			 (find-unique-val (invert-slot slot) '#$range :fail-mode 'fail)))
	     (range  (or (find-unique-val slot '#$range :fail-mode 'fail)
			 (find-unique-val (invert-slot slot) '#$domain :fail-mode 'fail))) )
	(cond ((not domain) (report-error 'user-warning "Domain for slot ~a not declared.~%" slot))
	      ((not (known-frame domain)) 
	       (report-error 'user-warning "Domain ~a for slot ~a not declared in KB.~%" domain slot))
	      ((instance-of frame domain))
	      (t (report-error 'user-warning "(~a has (~a ~a))~%Domain violation! Frame ~a is not in declared domain ~a of ~a!~%"
			       frame slot values frame domain slot)))
	(cond ((not range) (report-error 'user-warning "Range for slot ~a not declared.~%" slot))
	      ((not (known-frame range)) 
	       (report-error 'user-warning "Range ~a for slot ~a not declared in KB.~%" range slot))
	      (t (mapc #'(lambda (value)
			   (cond ((km-argsp value)
				  (cond ((not (instance-of (second value) range))
					 (report-error 'user-warning "(~a has (~a ~a))~%Range violation! First item ~a is not in declared range ~a!~%"
						       frame slot values (second value) range)))
				  (cond ((and (find-unique-val slot '#$range2 :fail-mode 'fail)
					      (not (instance-of (second value) 
								(find-unique-val slot '#$range2 :fail-mode 'fail))))
					 (report-error 'user-warning "(~a has (~a ~a))~%Range violation! Second item ~a is not in declared range ~a!~%"
						       frame slot values (second value) range))))
				 ((not (instance-of value range))
				  (report-error 'user-warning "(~a has (~a ~a))~%Range violation! Value ~a is not in declared range ~a!~%"
						frame slot values value range))))
		       values)))))))

(defun undeclared-slot (slot)
  (cond ((not (symbolp slot)) 
	 (report-error 'user-error "Non-slot ~a found where a slot was expected!~%" slot) t)
	((and (not (known-frame slot)) 
	      (not (known-frame (invert-slot slot)))
	      (not (built-in-concept slot)))
	 (cond ((checkkbp) (report-error 'user-warning "Slot ~a (or inverse ~a) not declared.~%" 
					 slot (invert-slot slot))))
	 t)))

;;; ======================================================================
;;;		AND FOR NORMAL SPECIALIZATION LINKS
;;; ======================================================================

#|
We assume the superclasses are correctly installed.
put-vals will avoid most redundancy in the superclasses link, but unfortunately
not all (see comments on put-vals above).
The subclasses links can still get redundancies in, for example:
	KM> (Car has (superclasses (Vehicle)))
	KM> (Nissan has (superclasses (Vehicle)))
	KM> (Nissan has (superclasses (Car)))
	KM> (showme 'Nissan)
	(Nissan has (superclasses (Car)))		; OK
	KM> (showme 'Vehicle)
	(Vehicle has (subclasses (Nissan Car)))		; Not OK

Call (install-all-subclasses) to recompute the taxonomy without redundancies.
|#


(defun install-all-subclasses ()
; (format t "Removing all old subclasses...~%")
  (mapc #'remove-subclasses (cons '#$Thing (get-all-objects)))
; (format t "Removing redundancies in superclass links...~%")
  (mapc #'remove-redundant-superclasses (get-all-objects)))
; (format t "Recomputing and adding subclasses...~%")  
;  (mapc #'install-subclasses (get-all-objects)) t)

(defun remove-subclasses (class)
  (cond ((not (anonymous-instancep class))	; ignore anonymous things
	 (delete-slot class '#$subclasses))))

#|
;;; [1] IF something is an instance-of something, AND it has no superclasses, THEN we ignore it
(defun install-subclasses (class)
  (cond ((kb-objectp class)
	 (let* ( (superclasses (immediate-superclasses class))
		 (actual-superclasses (cond ((and (equal superclasses '#$(Thing))
						  (find-vals class '#$instance-of)) nil)	; [1]
					    (t superclasses))) )
	   (mapc #'(lambda (genclass)
		     (add-val genclass '#$subclasses class nil))	; NEW: install-inversesp = nil for efficiency
		 actual-superclasses)))))
|#

;;; [1] don't install subclass links here, as we do that in the next stage anyway!
;;; We could do the subclass links here instead, if we could force put-vals to *always* set the
;;; vals (Currently, it only sets vals if the new vals /= old vals).
(defun remove-redundant-superclasses (class)
  (let* ( (superclasses (get-vals class '#$superclasses 'own-properties *global-situation*))
	  (minimal-superclasses (or (remove-subsumers superclasses)
				    (rest (assoc class *built-in-superclass-links*)))) )		; eg. Integer -> (Number)
    (cond ((not (equal superclasses minimal-superclasses))
	   (put-vals class '#$superclasses minimal-superclasses :install-inversesp nil))) ; [1]
    (mapc #'(lambda (superclass)
	      (add-val superclass '#$subclasses class nil *global-situation*))		; install-inversesp = nil
	  minimal-superclasses)))

;;; ======================================================================
;;;			THE SITUATION MECHANISM
;;; ======================================================================

;;; [1] Note we don't dereference *curr-situation*, in case it's bound to *Global.
;;; If it is bound to global, we want to (i) change *curr-situation* to point to
;;; *Global directly and (ii) by a subtle interaction, (reset-kb) get's messed up
;;; otherwise: If we leave *curr-situation* as (say) _S2, thinking it's *Global 
;;; (as it's bound to *Global), but then do an (unbind), we're then left apparently
;;; in a (now unbound) _S2!

;;; Must return a list of values (here, just a singleton) for consistency
(defun global-situation () 
  (cond ((neq *curr-situation* *global-situation*)		; [1]
	 (in-situation *global-situation*))
	(t (list *global-situation*))))

;;; A KM function passed to Lisp:
;;; NB 2.12.99 dereference added!!!
(defun curr-situation () (dereference *curr-situation*))

(defun in-situation (situation-expr &optional km-expr)
  (cond ((and (tracep) (not (traceothersituationsp)))
	 (prog2
	     (suspend-trace)
	     (in-situation0 situation-expr km-expr)
	   (unsuspend-trace)))
	(t (in-situation0 situation-expr km-expr))))

;;; [1] The special case which *is* allowed, of an (in-situation *Global ...) issued when within a prototype, will be caught earlier by [2].
(defun in-situation0 (situation-expr &optional km-expr)
  (let* ( (situation-structure (km-unique situation-expr :fail-mode 'fail))
	  (situation (cond ((km-argsp situation-structure) (arg1of situation-structure))	; e.g. situation-expr = (the next-situation of ...)
			   (t situation-structure))) )						; e.g. situation-expr = (a Situation)
    (cond ((eq situation (curr-situation))			; [2]
	   (cond ((neq (curr-situation) *curr-situation*)
		  (change-to-situation (curr-situation))))	; in case *curr-situation* is bound, but not eq, to (curr-situation)
	   (cond (km-expr (km km-expr :fail-mode 'fail))
		 (t (list (curr-situation)))))
	  ((am-in-prototype-mode)				; [1]
	   (report-error 'user-error "Trying to do ~a: Can't enter a situation when you're in prototype mode!~%" 
			 (cond (km-expr `#$(in-situation ,SITUATION-EXPR ,KM-EXPR))
			       (t `#$(in-situation ,SITUATION-EXPR)))))
	  ((or (not situation) 
	       (not (kb-objectp situation)))
	   (report-error 'user-error "~a doesn't evaluate to a Situation (results in ~a instead)!~%" situation-expr situation-structure))
	  ((not (isa situation '#$Situation))
	   (report-error 'user-error "~a doesn't evaluate to a Situation (~a isn't declared an instance of Situation)!~%" 
			 situation-expr situation))
	  ((not km-expr)   
	   (cond ((and (kb-objectp situation-expr)
		       (neq situation-expr situation))
		  (make-comment (km-format nil "Situation ~a is bound to situation ~a" situation-expr situation))))
	   (make-comment (km-format nil "Changing to situation ~a" situation))
	   (list (change-to-situation situation)))		; must return a list of values, for consistency
	  (t (let ( (curr-situation (curr-situation)) )
	       (km-trace 'comment "")			; does a nl
	       (km-trace 'comment "Temporarily changing to situation ~a..." situation)
	       (change-to-situation situation)
	       (prog1
		   (km km-expr :fail-mode 'fail)
		 (change-to-situation curr-situation)
		 (km-trace 'comment "Exiting situation ~a, and returning to situation ~a." situation curr-situation)
		 (km-trace 'comment "")))))))


(defun am-in-global-situation () (eq (curr-situation) *global-situation*))
(defun am-in-local-situation () (neq (curr-situation) *global-situation*))
(defun change-to-situation (situation) 
  (make-transaction `(setq *curr-situation* ,situation)))

#|
BELOW -- Neah, leave the default alone -- changing the default adds
as many confusions as it removes.
(defvar *user-warned-about-new-default-fluent-status* nil)
(defun change-to-situation (situation) 
  (cond ((and *show-comments*
	      (not *user-warned-about-new-default-fluent-status*)
	      (neq situation *global-situation*))
	 (km-format t "
   ===================================================================
   MESSAGE: Situations: Important change in KM 1.4.0-beta48 and later:
   ===================================================================
In KM1.4.0-beta48 and later, the default fluent-status of slots is now
*Fluent (i.e. non-inertial fluent), rather than *Inertial-Fluent. This means
that now, by default, slot-values will *NOT* be projected (i.e. persist) 
from one situation to another, unless the user explicitly declares the
slot an *Inertial-Fluent. To do this, set the slot's fluent-status to 
*Inertial-Fluent, e.g.

        KM> (location has
              (instance-of (Slot))
              (fluent-status (*Inertial-Fluent)))

See the KM Situations Manual at http://www.cs.utexas.edu/users/mfkb/km.html
for details. This change was made to ensure the user does not accidentally 
allow indirect effects (ramifications) of actions to be projected (see the 
Situations Manual for more discussion). If you really wish to change the 
default fluent status back to how it was in KM1.4.0-beta47 and earlier 
(not recommended), then do (default-fluent-status *Inertial-Fluent).
   ===================================================================
")
	 (setq *user-warned-about-new-default-fluent-status* t)))
  (make-transaction `(setq *curr-situation* ,situation)))
|#


;;; next-situation will create a new situation which is at the next-situation relation
;;; to the situation given. 
;;; NOTE: if the future-pointing-slot is single-valued, then next-situation will
;;; first try and FIND the next-situation rather than create a new one (which will
;;; necessarily need to be unified in).
;;; action is an INSTANCE (it better be!)
(defun next-situation (action) ;  &optional (future-pointing-slot '#$next-situation))
    (cond ((am-in-global-situation)
	   (report-error 'user-error "You must be in a Situation to create a next-situation!~%"))
	  (t (let ( (curr-situation (curr-situation))
		    (new-situation (make-new-situation)) )
;		     (new-situation (or (and (single-valued-slotp future-pointing-slot)
;					     (km-unique `#$(in-situation *Global (the ,FUTURE-POINTING-SLOT of ,CURR-SITUATION)) :fail-mode 'fail))
;					(make-new-situation)))
;		    (past-pointing-slot (invert-slot future-pointing-slot)) )
;	       (cond ((neq future-pointing-slot '#$next-situation)
;		      (in-situation *global-situation*
;				    `#$(,PAST-POINTING-SLOT has 	; register user-defined past-pointing slot
;					    (instance-of (Slot))
;					    (cardinality (N-to-1))
;					    (situation-specific (t))
;					    (superslots (prev-situation))))))
	       (cond ((null action)
		      (in-situation *global-situation* 
			   `#$(,NEW-SITUATION has 
			 	(instance-of (Situation))
;			 	(,PAST-POINTING-SLOT (,CURR-SITUATION)))))	 ; inverse auto-installed
			 	(prev-situation ((:args ,CURR-SITUATION ,ACTION))))))		 ; inverse auto-installed
		     (t (in-situation *global-situation* 
			   `#$(,NEW-SITUATION has 
			 	(instance-of (Situation))
;			 	(,PAST-POINTING-SLOT (,CURR-SITUATION))))))))))  ; inverse auto-installed
			 	(prev-situation ((:args ,CURR-SITUATION ,ACTION)))))))))))	 ; inverse auto-installed

(defun new-situation () (in-situation (make-new-situation)))

(defun make-new-situation () 
  (first (in-situation *global-situation* `#$(a Situation with (supersituations (,*GLOBAL-SITUATION*))))))
    
;;; always t for now -- disable this verification step
(defun isa-situation-facet (situation) (declare (ignore situation)) t)

;;; facet refers to a global property list, for storing data.
;;; In the global situation, we refer to that facet directly. In a local
;;; situation, we create a situation-specific property list storing that data.
;;; The facet "own-properties" in _Sitn1 becomes "own-properties_Sitn1".
;;; To avoid computing this symbol many times, I cache it using get/setf:
;;;	SYMBOL		PROPERTY   VALUE
;;;	own-properties  _Sitn1     own-properties_Sitn1
;;; This simply caches the concatenation of these two symbols into a third
;;; symbol, hopefully being more efficient than reconcatenating and interning
;;; the symbols' strings!
;;; 3.25.99 - time on test suite goes up from 20 to 37 secs without this caching!
;;; Looks like it's doing something useful...

(defun curr-situation-facet (facet &optional (curr-situation (curr-situation)))
  (cond ((eq curr-situation *global-situation*) facet)
	((get facet curr-situation))
	(t (setf (get facet curr-situation) 
		 (intern (concat (symbol-name facet) (symbol-name curr-situation)))))))

;;; ======================================================================
;;;		SITUATION TRANSITIONS:
;;; ======================================================================

;;; Effects can be either quoted propositions or :triple statements (take your pick!)
;;;
;;; a PROPOSITION is a structure of the form (:triple F S V), where V may be (:set a b)
;;;
;;; Note we must precompute all the effects *before* actually making them, to avoid one 
;;; effect being considered as part of the initial situation for calculating another.
;;; [1] Need to create the next situation *before* computing the pcs etc., or else they
;;; won't be computed!
(defun do-action (action-expr &key #|(future-pointing-slot '#$next-situation)|# change-to-next-situation)
  (let ( (old-situation (curr-situation)) )
    (cond ((am-in-global-situation)
	   (make-comment (km-format nil "Ignoring (do-action ~a) in global situation:" action-expr))
	   (make-comment "Can only execute actions in local situations"))
	  (t (let ( (action (cond (action-expr (km-unique action-expr :fail-mode 'fail)))) )
	       (cond 
		((not action)
		 (make-comment "Doing null action...")
;		 (in-situation (next-situation nil future-pointing-slot)))
		 (in-situation (next-situation nil)))
		(t (km-trace 'comment "Computing the effects of action ~a..." action)
		   (let* ( (next-situation (next-situation action))  ; [1] 
			   (pcs-list (find-propositions action '#$pcs-list))
			   (ncs-list (find-propositions action '#$ncs-list))
			   (add-list (find-propositions action '#$add-list))
			   (del-list (find-propositions action '#$del-list))
			   (pcs-blk-list (block-list pcs-list)) 
			   (add-blk-list (block-list add-list)) )
		     (km-trace 'comment "Now assert the effects of action ~a..." action)
		     (cond ((or ncs-list pcs-blk-list pcs-list)
			    (km-trace 'comment "Preconditions of ~a which must be true in the old situation (~a)..." action old-situation)))
		     (mapc #'(lambda (ncs-item) (km-assert ncs-item :mode '#$del)) ncs-list)
		     (mapc #'(lambda (blk-item) (km-assert blk-item :mode '#$add)) pcs-blk-list)
		     (mapc #'(lambda (pcs-item) (km-assert pcs-item :mode '#$add)) pcs-list)
;		     (in-situation (next-situation action future-pointing-slot))
		     (cond ((or del-list add-blk-list add-list)
			    (km-trace 'comment "Effects of ~a in the new situation (~a)..." 
				      action next-situation)))
		     (in-situation next-situation)
		     (mapc #'(lambda (del-item) (km-assert del-item :mode '#$del)) del-list)
		     (mapc #'(lambda (blk-item) (km-assert blk-item :mode '#$add)) add-blk-list)
		     (mapc #'(lambda (add-item) (km-assert add-item :mode '#$add)) add-list))))
	       (prog1
		   (curr-situation)
		 (cond ((not change-to-next-situation) (in-situation old-situation)))))))))

;;; [1] KM1.4.0-beta17: If slot is single-valued, and (F S OldV) in prev-situation, and (F S V)
;;; 	in new situation, then we must also add (OldV InvS (<> F)) otherwise (OldV InvS F) will
;;;	be projected.
(defun block-list (add-list)
  (remove-dup-instances
   (mapcan #'(lambda (proposition)				; [1]
	       (let ( (frame (second proposition))
		      (slot (third proposition))
		      (val (fourth proposition)) )	; necessarily a singleton, if slot is single-valued
		 (cond ((single-valued-slotp slot)
			(cond ((not (atom val))
			       (report-error 'user-error 
				      "do-action trying to assert multiple values for single-valued slot!~%Trying to assert ~a for (the ~a of ~a)!~%" 
				      (val-to-vals val) slot frame))
			      (t (mapcar #'(lambda (val0)
					     (list '#$:triple val0 (invert-slot slot) (list '<> frame)))
					 (remove val (km `#$(the ,SLOT of ,FRAME) :fail-mode 'fail)))))))))
	   add-list)))

;;; NOTE: we assume that the three elements in the proposition have already been evaluated by KM
;;; 	(by find-propositions below).
(defun km-assert (proposition &key mode)	; mode = '#$add or '#$del
  (cond ((km-triplep proposition)
	 (let* ( (frame (second proposition))
		 (slot  (third proposition))
		 (inv-slot (invert-slot slot))
		 (values (val-to-vals (fourth proposition))) )
	   (case mode
		 (#$add (km `#$(,FRAME has (,SLOT ,VALUES))))	 ; inverses installed automatically. 
		 (#$del (mapc #'(lambda (value)
				  (km `#$(,FRAME has (,SLOT ((<> ,VALUE)))))
				  (cond ((and (kb-objectp value)
					      (kb-objectp slot)
					      (not (non-inverse-recording-slot slot))
					      (not (non-inverse-recording-concept value)))
					 (km `#$(,VALUE has (,INV-SLOT ((<> ,FRAME))))))))
			      values))
		 (t (report-error 'program-error "Unknown km-assert mode `~a'!~%" mode)))))
	(t (report-error 'user-error "~a-list contains a non-proposition `~a'!~%Ignoring it...~%" mode proposition))))

;;; Convert (a Triple with ...) to :triple notation.
;;; slot is expected to be either #$add-list or #$del-list
(defun find-propositions (action slot)
  (mapcar #'convert-to-triple (km `#$(the ,SLOT of ,ACTION) :fail-mode 'fail)))

(defun convert-to-triple (triple)
  (cond ((km-triplep triple) triple)
	((isa triple '#$Triple)
	 (list '#$:triple
	       (km-unique `#$(the frame of ,TRIPLE))
	       (km-unique `#$(the  slot of ,TRIPLE))
	       (vals-to-val (km `#$(the value of ,TRIPLE) :fail-mode 'fail))))
	(t (report-error 'user-error "Non-triple ~s found in add-list or del-list of an action!~%" triple))))

;;; ======================================================================
;;;			DELETING FRAMES
;;; ======================================================================

;;; Note that delete-frame will *ALSO* remove the bindings for it.
;;; So if X is bound to Y, is bound to Z (X -> Y -> Z), and we delete frame Y,
;;; then we also delete the binding that Y -> Z, and thus X is left hanging
;;; (pointing to invisible Y). Thus must be very careful when deleting a single
;;; frame!

(defun delete-frame (frame)
  (mapc #'(lambda (situation)
	    (mapc #'(lambda (slotvals)
		      (let ( (slot (first slotvals))
			     (vals (second slotvals)) )
			(uninstall-inverses frame slot vals situation)))
		  (get-slotsvals frame 'own-properties situation)))
	(all-situations))
  (remove-from-stack frame)
  (delete-frame-structure frame))

(defun scan-kb ()
  (let* ( (declared-symbols (get-all-objects))
	  (all-objects (flatten (mapcar #'(lambda (situation)
					  (mapcar #'(lambda (concept)
						      (mapcar #'(lambda (facet)
								  (get-slotsvals concept facet situation))
							      *all-facets*))
						  declared-symbols))
				      (all-situations))))
	  (all-symbols (remove-duplicates (remove-if-not #'kb-objectp all-objects)))
	  (user-symbols (set-difference all-symbols (append *built-in-frames* 
							    *km-lisp-exprs* 
							    *downcase-km-lisp-exprs*
							    *reserved-keywords*
							    *additional-keywords*)))
	  (undeclared-symbols (remove-if #'(lambda (symbol) (or (member symbol declared-symbols)
								(member (invert-slot symbol) declared-symbols)))
					 user-symbols)) )
    (cond (undeclared-symbols
	   (km-format t "A cursory check of the KB shows (at least) these symbols were undeclared:~%" (length undeclared-symbols))
	   (mapc #'(lambda (symbol) (km-format t "   ~a~%" symbol)) 
		 (sort undeclared-symbols #'string< :key #'symbol-name))
	   (format t "----- end -----~%")))
; Remove this confusing message
;	  (t (km-format t "(No All the symbols in the KB have frames declared for them)~%")))
    '#$(t)))


;;; FILE:  trace.lisp

;;; File: trace.lisp
;;; Author: Peter Clark
;;; Date: Separated out Apr 1999
;;; Purpose: Debugging facilities for KM

;;; encapsulate checking flag
(defparameter *check-kb* nil)
(defun checkkbon ()  (setq *check-kb* t))
(defun checkkboff () (setq *check-kb* nil))
(defun checkkbp () *check-kb*)

;;; ======================================================================
;;;		    FOR TRACING EXECUTION
;;; ======================================================================

(defvar *trace* nil)
(defvar *trace-classify* nil)
(defvar *trace-other-situations* nil)
(defvar *trace-unify* nil)
(defvar *trace-subsumes* nil)
(defvar *trace-constraints* nil)
(defvar *suspended-trace* nil)
(defvar *interactive-trace* nil)
(defvar *depth* 0)

(defun tracekm () 
  (reset-trace) 
  (cond (*trace* (format t "(Tracing of KM is already switched on)~%"))
	(t (format t "(Tracing of KM switched on)~%") (setq *trace* t) (setq *interactive-trace* t)))
  t)

(defun untracekm () 
  (reset-trace)
  (cond (*trace* (format t "(Tracing of KM switched off)~%") (setq *trace* nil) (setq *interactive-trace* nil))
	(t (format t "(Tracing of KM is already switched off)~%")))
  t)

(defun reset-trace () 
  (cond ((or *trace* *interactive-trace*)   ; user may have temporarily switched off either of these during last tracing.
	 (setq *interactive-trace* t)
	 (setq *trace* t)))
;  (setq *depth* 0) 			; new - trace might be reset in middle of computation, so don't do this!
  (setq *suspended-trace* nil) 
  (setq *trace-classify* nil)
  (setq *trace-subsumes* nil)
  (setq *trace-other-situations* nil)
  (setq *trace-unify* nil)
  (setq *trace-constraints* nil)
  t)

(defun reset-trace-depth ()
  (setq *depth* 0))

(defun tracep () *trace*)
(defun traceunifyp () *trace-unify*)
(defun tracesubsumesp () *trace-subsumes*)
(defun traceclassifyp () *trace-classify*)
(defun traceconstraintsp () *trace-constraints*)
(defun traceothersituationsp () *trace-other-situations*)


;;; ======================================================================
;;;		     THE TRACE UTILITY
;;; ======================================================================

#|
OWN NOTES:
depth = 0
  call (the parts of *MyCar) -> depth = 1
NOW: suppose I type "s":
	- suspend-trace = 1, trace = nil
EXIT.
Next: if CALL then depth goes up to 2.
      if FAIL, or EXIT then depth stays 1, and suspend-trace -> nil, trace -> t.
	on exit, depth will go back down to 0.
      if COMMENT, depth is unchanged, and trace/suspend-trace is unchanged.

If I type "n", trace is permenantly switched off, EXCEPT *interactive-trace* is left on.
If I type "z", *interactive-trace* is switched permanently off, EXCEPT *trace* is left on.
|#

(defun km-trace (mode string &rest args)
  (cond ((eq mode 'call) (increment-trace-depth)))
; The below condition is now achievable, if an error triggers the debugger to be switched on.
; (cond ((and *suspended-trace* (< *depth* *suspended-trace*))		; debug message
;	 (report-error 'program-error "trace depth somehow crept below that at which trace was suspended! Continuing...~%")))
  (cond ((and (not *trace*)
	      (not (eq mode 'comment))
	      *suspended-trace*
	      (<= *depth* *suspended-trace*))	; would be eq, but I want to continue if debug message above sounds.
	 (unsuspend-trace)))
  (prog1					; reset *depth* for FAIL/EXIT *after* messages, but return result of messages.
      (cond (*trace* (km-trace2 mode string args)))
    (cond ((or (eq mode 'exit)(eq mode 'fail)) (decrement-trace-depth)))))

(defun km-trace2 (mode string args)
; (format t "~vT" *depth*)			; Bug in Harlequin lisp causes this not to tab properly!
  (format t "~a" *depth*)
  (format t (spaces (- (1+ *depth*) (length (princ-to-string *depth*)))))
  (cond ((eq mode 'comment) (format t " ")))		   ; extra space tabulation for comments
  (apply #'km-format `(t ,string . ,args))		   ; ie. (km-format t string arg1 ... argn)
  (cond ((and *interactive-trace* (neq mode 'comment))
	 (let ( (debug-option (read-line t nil nil)) )
	   (cond ((string= debug-option "s")
		  (cond ((eq mode 'call) 		   ; don't suspend on an EXIT, or depth will immediately creep below
			 (suspend-trace))))		   ; the suspended depth
		 ((string= debug-option "S")
		  (cond ((eq mode 'call) 		   
			 (suspend-trace (1- *depth*)))))
		 ((string= debug-option "o") (untracekm))
		 ((string= debug-option "-A")
		  (format t "(Will no longer trace absolutely everything)~%")
		  (setq *trace-classify* nil)
		  (setq *trace-subsumes* nil)
		  (setq *trace-other-situations* nil)
		  (setq *trace-unify* nil)
		  (setq *trace-constraints* nil)
		  (km-trace2 mode string args))
		 ((string= debug-option "a") (throw 'km-abort 'km-abort))
		 ((string= debug-option "A") (untracekm) (throw 'km-abort 'km-abort))
		 ((string= debug-option "r")
		  (cond ((eq mode 'call)   		   ; strictly redundant to redo on a call (ie. before it's even been tried)
			 (km-trace2 mode string args))
			(t 'redo)))
		 ((string= debug-option "n") (setq *trace* nil) (setq *suspended-trace* nil))
		 ((string= debug-option "f") 'fail)
		 ((string= debug-option "g") (show-km-stack) (km-trace2 mode string args))
		 ((string= debug-option "z") (setq *interactive-trace* nil))

		 ((string= debug-option "+A") 
		  (format t "(Will now trace absolutely everything)~%")
		  (setq *trace-other-situations* t)
		  (setq *trace-subsumes* t)
		  (setq *trace-unify* t)
		  (setq *trace-constraints* t)
		  (setq *trace-classify* t)
		  (km-trace2 mode string args))
		 ((string= debug-option "+S") 
		  (format t "(Will now show more detailed trace in other situations)~%")
		  (setq *trace-other-situations*   t) (km-trace2 mode string args))
		 ((string= debug-option "-S") 
		  (format t "(Will no longer show a detailed trace in other situations)~%")
		  (setq *trace-other-situations* nil) (km-trace2 mode string args))

		 ; This is for my own debugging, and not advertised to the user
		 ((string= debug-option "+M") 
		  (format t "(Will now show more detailed trace for some subsumption tests)~%")
		  (setq *trace-subsumes*   t) (km-trace2 mode string args))
		 ((string= debug-option "-M") 
		  (format t "(Will no longer show more detailed trace for some subsumption tests)~%")
		  (setq *trace-subsumes* nil) (km-trace2 mode string args))

		 ((string= debug-option "+U") 
		  (format t "(Will now show a more detailed trace during unification)~%")
		  (setq *trace-unify*   t) (km-trace2 mode string args))
		 ((string= debug-option "-U") 
		  (format t "(Will no longer show a detailed trace during unification)~%")
		  (setq *trace-unify* nil) (km-trace2 mode string args))
		 ((string= debug-option "+C") 
		  (format t "(Will now show a more detailed trace during constraint checking)~%")
		  (setq *trace-constraints* t) (km-trace2 mode string args))
		 ((string= debug-option "-C") 
		  (format t "(Will no longer show a detailed trace during constraint checking)~%")
		  (setq *trace-constraints* nil) (km-trace2 mode string args))
		 ((string= debug-option "+X") 
		  (format t "(Will now show more detailed trace during classification)~%")
		  (setq *trace-classify*   t) (km-trace2 mode string args))
		 ((string= debug-option "-X") 
		  (format t "(Will no longer show a detailed trace during classification)~%")
		  (setq *trace-classify* nil) (km-trace2 mode string args))

		 ((starts-with debug-option "d ")
		  (format t "----------------------------------------~%~%")
		  (showme-frame (intern (trim-from-start debug-option 2)))
		  (format t "----------------------------------------~%")
		  (km-trace2 mode string args))
		 ((and (string/= debug-option "")
		       (string/= debug-option "c")) 
		  (print-trace-options) 
		  (km-trace2 mode string args)))))
	(t (format t "~%"))))

(defun increment-trace-depth () (setq *depth* (1+ *depth*)))
(defun decrement-trace-depth () (setq *depth* (1- *depth*)))

#|
;;; Iterate again, making sure counters stay unchanged.
(defun retrace (mode string &optional args)
  (cond ((eq mode 'call) (setq *depth* (1- *depth*))))	   ; (<- as it will be immediately incremented again)  
  (apply #'km-trace `(,mode ,string . ,args)))		   ; ie. (km-trace mode string arg1 ... argn)
|#


#|
THIS IS WHAT QUINTUS PROLOG GIVES YOU
Debugging options:
 <cr>   creep      p      print         r [i]  retry i      @    command
  c     creep      w      write         f [i]  fail i       b    break
  l     leap       d      display                           a    abort
  s [i] skip i                                              h    help
  z     zip        g [n]  n ancestors   +      spy pred     ?    help
  n     nonstop    < [n]  set depth     -      nospy pred   =    debugging
  q     quasi-skip .      find defn     e      raise_exception
|#

(defun print-trace-options ()
  (format t "----------------------------------------
Debugging options during the trace:
 <cr>,c   creep       - single step forward
  s       skip        - jump to completion of current subgoal
  S       big skip    - jump to completion of parent subgoal
  r       retry       - redo the current subgoal
  n       nonstop     - switch off trace for remainder of this query
  a       abort       - return to top-level prompt
  A       abort & off - return to top-level prompt AND switch off tracer
  o       trace off   - permenantly switch off trace 
  f       fail        - return NIL for current goal (use with caution!)
  z       zip         - complete query with noninterative trace
  g       goal stack  - print goal stack
  d <f>   display <f> - display (showme) frame <f>
  h,?     help        - this message

Also to show additional detail (normally not shown) for this query *only*:
  +S      in other situation(s)
  +U      during unification
  +C      during constraint checking
  +X      during classification
  +A      trace absolutely everything
  +M	  during subsumption testing
  -S,-U,-C,-X,-A,-M to unshow

Or from the KM prompt: 
  KM> (trace)     switches on debugger
  KM> (untrace)   switches off the debugger
----------------------------------------
"))

#|
An abbreviated list:
Debugging options:                              Also show detailed inference:
 <cr>,c   creep      f    fail                  +C  during classification
  s       skip       z    zip (noninterative)   +S  in other situation(s)
  r       retry      g    show goal stack       +U  during unification
  n       nonstop    d F  display frame F       -C,-S,-U to unshow
  o       trace off  S    big skip (to completion of parent goal)
  h,?     help 
|#

#|
NB MUSTN'T suspend/unsuspend unless trace was already on
This is ok:
  (cond ((and (tracep) (not (traceclassifyp))) (prog2 (suspend-trace) <foo> (unsuspend-trace)))
	(t <foo>))
This is not!
  (prog2 (suspend-trace) <foo> (unsuspend-trace))
because the (unsuspend-trace) will restart the trace, even if the 
trace was already off ie. (suspend-trace) had no effect.

NOTE!! <foo> MUSTN'T be a function returning multiple values! prog2 
seems to strip all but the first value off!
|#

;;; Suspend trace until exit the call at depth *depth*
(defun suspend-trace (&optional (depth *depth*))
  (setq *suspended-trace* depth)
  (setq *trace* nil))

;;; If we suspended the trace, but then the debugger kicked in again automatically, and
;;; then we switched off the trace (option "n"), we *don't* want to switch it back on again!
(defun unsuspend-trace ()
  (cond (*suspended-trace* 
	 (setq *suspended-trace* nil)
	 (setq *trace* t))))

;;; ======================================================================
;;;		COMMENTS
;;; ======================================================================

(defun make-comment (comment)
  (cond (*show-comments* (format t "(COMMENT: ~a)~%" comment))))

(defun comments () 
  (cond (*show-comments* (format t "(Display of comments is already switched on)~%"))
	(t (format t "(Display of comments is switched on)~%") (setq *show-comments* t)))
  t)

(defun nocomments () 
  (cond (*show-comments* (format t "(Display of comments is switched off)~%") (setq *show-comments* nil))
	(t (format t "(Display of comments is already switched off)~%")))
  t)

;;; ======================================================================
;;;		ERRORS
;;; ======================================================================

(defun report-error (error-type string &rest args)
 ;; KANAL : make error report silent (for now)
 ;;   1) in some cases, nil doesn't mean an error in K Analysis
 ;;   2) don't switch to debugger in K analysis
 (unless *in-k-analysis*
   (case error-type
	(user-error (format t "ERROR! "))
	(user-warning (format t "WARNING! "))
	(program-error (format t "PROGRAM ERROR! "))
	(nodebugger-error (format t "ERROR! "))
	(t (format t "ERROR! Error in report-error! Unrecognized error type ~a!~%" error-type)))
  (apply #'km-format `(t ,string ,@args))
  (cond ((member error-type '(user-error program-error))
	 (cond ((and (not *trace*)
		     (not *suspended-trace*))
		(format t "
	-------------------------
	**Switching on debugger** 
Options include:
  g: to see the goal stack
  r: to retry current goal
  a: to abort
  o: to switch off debugger
  A: abort & off - return to top-level prompt AND switch off tracer
  ?: to list more options
	-------------------------

")))
	 (setq *trace* t) (setq *interactive-trace* t) (setq *suspended-trace* nil)))
 )
  nil)



;;; FILE:  lazy-unify.lisp

;;; File: lazy-unify.lisp
;;; Author: Peter Clark
;;; Date: Sept 1994, revised (debugged!) Jan 1995, rewritten 1996.
;;; Purpose: How do you unify two complex graphs which essentially connect
;;; 	to the entire KB? This clever solution is based on delayed (lazy)
;;;	evaluation of the unification.

(defun val-unification-operator (x) (member x '(& &? &! &+ ==)))
(defun set-unification-operator (x) (member x '(&& #|&&?|# &&! ===)))
(defun unification-operator (x) (member x '(& &? &! && #|&&?|# &&! &+ == ===)))

#|
(lazy-unify '_Person1 '_Professor1)
Returns NIL if they won't unify. Does a quick check on slot-val compatibility,
so that IF there's a single-valued slot AND there's a value on each instance
AND those values are atomic AND they are unifiable THEN the unification fails.

In addition, we add a classes-subsumep mode:
  If it's T (used for &&) then the classes of one instance must *subsume* the classes of another. 
	Thus cat & dog won't unify.
  If it's NIL (used for &) then the classes are assumed mergable, eg. pet & fish will unify
	to (superclasses (pet fish)).

eagerlyp: if true, then do eager rather than lazy unification, ie. don't leave any & or && residues on frames, 
 just atomic values.
|#
(defparameter *see-unifications* nil)

(defun lazy-unify (instancename1 instancename2 &key classes-subsumep eagerlyp)
 (let* ( (instance1 (dereference instancename1))		; Might be redundant to deref, but just in case!
	 (instance2 (dereference instancename2)) 
	 (unification (lazy-unify0 instance1 instance2 :classes-subsumep classes-subsumep :eagerlyp eagerlyp)) )
    (cond ((and unification 
;		*see-unifications*
		(not (equal instance1 instance2))
		(not (null instance1))
		(not (null instance2)))
	   (make-comment 
	    (km-format nil "(~a ~a ~a) unified to be ~a" instancename1 (cond (classes-subsumep '&&) (eagerlyp '&!) (t '&))
		       instancename2 unification))))
    unification))

;;; [1] NOTE failure to unify an element means the whole unification should fail
(defun lazy-unify0 (instancename1 instancename2 &key classes-subsumep eagerlyp)
; (let ( (instance1 (dereference instancename1))		; Might be redundant to deref, but just in case!
;	(instance2 (dereference instancename2)) )		; DONE EARLIER NOW
  (let ( (instance1 instancename1)
	 (instance2 instancename2) )
  (cond 
   ((equal instance1 instance2) instance1)	; already unified
   ((null instance1) instance2)
   ((null instance2) instance1)
   ((or (km-structured-list-valp instance1)
	(km-structured-list-valp instance2))
    (cond ((not (km-structured-list-valp instance1)) (lazy-unify (list (first instance2) instance1) instance2  			; x & (:args x y)
								 :classes-subsumep classes-subsumep :eagerlyp eagerlyp))
	  ((not (km-structured-list-valp instance2)) (lazy-unify instance1 (list (first instance1) instance2)			; (:args x y) & x
								 :classes-subsumep classes-subsumep :eagerlyp eagerlyp))
	  ((eq (first instance1) (first instance2))
	   (let ( (unification (cons (first instance1)						; eg. ":seq"
				     (mapcar #'(lambda (pair)
						 (lazy-unify (first pair) (second pair) :classes-subsumep classes-subsumep))
					     (rest (transpose (list instance1 instance2)))))) )	; ((:seq :seq) (i1 e1) (i2 e2) ... )
	     (cond ((not (member nil unification)) unification))))))						; [1]
   (t (lazy-unify2 instance1 instance2 :classes-subsumep classes-subsumep :eagerlyp eagerlyp)))))

;;; [3] This is where the result is finally stored in memory
(defun lazy-unify2 (instance1 instance2 &key classes-subsumep eagerlyp)
  (multiple-value-bind 
   (unified-name sitn+svs-pairs binding-list)
   (try-lazy-unify2 instance1 instance2 :classes-subsumep classes-subsumep :eagerlyp eagerlyp)	; (1) TRY IT...
   (cond (unified-name										; (2) DO IT!
	  (cond ((kb-objectp unified-name)   ; don't do stuff for numbers & strings!
		 (let ( (curr-situation (curr-situation)) )
		   (mapc #'(lambda (sitn+svs)
			     (change-to-situation (first sitn+svs))
			     (put-slotsvals unified-name (second sitn+svs) 'own-properties))	; [3]
			 sitn+svs-pairs)
		   (change-to-situation curr-situation))))
	  (cond ((isa unified-name '#$Situation)
; equalities are now global	      (cond ((am-in-local-situation)
;					     (km-format t "WARNING! You should unify situations in the global situation!~%")))
		 (cond ((and (isa instance1 '#$Situation) (isa instance2 '#$Situation))
			(make-comment (km-format nil "Unifying situations ~a & ~a" instance1 instance2))))
		 (copy-situation-contents instance1 unified-name)
		 (copy-situation-contents instance2 unified-name)))
	  (mapc #'(lambda (binding)
		    (bind (first binding) (second binding))) binding-list)
	  (cond ((kb-objectp unified-name)
		 (un-done unified-name)   ; all vals to be recomputed now - now in put-slotsvals; Later: no!
		 (classify unified-name)))  ; reclassify
	  unified-name))))

;;; --------------------

#|
Returns, via a call to try-lazy-unify2, three values:
	1. the instancename of the unification
	2. a list of (situation slotsvals) pairs, of the unified structure for each situation
	3. a list of (instance1 instance2) variable binding pairs
OR nil if the unification fails. 
|#
(defun try-lazy-unify (instancename1 instancename2 &key classes-subsumep eagerlyp)
 (let ( (instance1 (dereference instancename1))		; Might be redundant to deref, but just in case!
	(instance2 (dereference instancename2)) )
  (cond 
   ((equal instance1 instance2) instance1)	; already unified
   ((null instance1) instance2)
   ((null instance2) instance1)
   ((or (km-structured-list-valp instance1)
	(km-structured-list-valp instance2))
    (cond ((not (km-structured-list-valp instance1)) (try-lazy-unify (list (first instance2) instance1) instance2  		; x & (:args x y)
								 :classes-subsumep classes-subsumep :eagerlyp eagerlyp))
	  ((not (km-structured-list-valp instance2)) (try-lazy-unify instance1 (list (first instance1) instance2)		; (:args x y) & x
								 :classes-subsumep classes-subsumep :eagerlyp eagerlyp))
	  ((eq (first instance1) (first instance2))
	   (every #'(lambda (pair)
		      (try-lazy-unify (first pair) (second pair) :classes-subsumep classes-subsumep :eagerlyp eagerlyp))
		  (rest (transpose (list instance1 instance2)))))))	; ((:seq :seq) (i1 e1) (i2 e2) ... )
   (t (try-lazy-unify2 instance1 instance2 :classes-subsumep classes-subsumep :eagerlyp eagerlyp)))))

#|
try-lazy-unify2: This function has no side effects.
Returns three values:
	1. the instancename of the unification
	2. a list of (situation slotsvals) pairs, of the unified structure for each situation
	3. a list of (instance1 instance2) variable binding pairs
OR nil if the unification fails. 
|#
(defun try-lazy-unify2 (instance1 instance2 &key classes-subsumep eagerlyp)
  (multiple-value-bind
      (unified-name bindings)
      (unify-names instance1 instance2 classes-subsumep)
    (cond (unified-name
	   (let ( (sitn-svs-pairs (unified-svs instance1 instance2 :classes-subsumep classes-subsumep :eagerlyp eagerlyp)) )
	     (cond ((neq sitn-svs-pairs 'fail)
		    (values unified-name sitn-svs-pairs bindings))))))))
		     
;;; ----------------------------------------

;;; Returns a list of (situation unified-svs) pairs for unifying i1 and i2
;;;      OR 'fail, if a problem was encountered
(defun unified-svs (i1 i2 &key (situations (all-situations)) classes-subsumep eagerlyp)
  (let ( (sitn-svs-pairs (mapcar #'(lambda (situation)
				     (unified-svs-in-situation i1 i2 situation :classes-subsumep classes-subsumep :eagerlyp eagerlyp))
				 situations)) )
    (cond ((not (member 'fail sitn-svs-pairs)) sitn-svs-pairs)
	  (t 'fail))))

;;; [1] This is critical, as lazy-unify-slotsvals drags in constraints from whatever the current situation is!
;;; [2] change-to-situation doesn't make-comments.
(defun unified-svs-in-situation (i1 i2 situation &key classes-subsumep eagerlyp)
  (let ( (curr-situation (curr-situation)) )
    (cond ((neq situation curr-situation) (change-to-situation situation)))			; [1], [2]
    (multiple-value-bind
      (successp unified-svs)
      (lazy-unify-slotsvals i1 i2
			    (get-slotsvals i1 'own-properties situation)   ; (don't need bind-self as
			    (get-slotsvals i2 'own-properties situation)   ; frames are instances)
			    :classes-subsumep classes-subsumep :eagerlyp eagerlyp)
      (cond ((neq situation curr-situation) (change-to-situation curr-situation)))		; [1]
      (cond (successp (list situation unified-svs))
	    (t 'fail)))))

;;; ----------------------------------------

;;; Returns (i) unified value (ii) extra binding list elements
;;; In the case of two anonymous instances A and B, then B points to A, ie. get B->A,
;;; not A->B. Three items of code depend on this ordering:
;;;    1. (load-kb ...), so that a statement like (_X2 == _X1) binds _X1 
;;;       to point to _X2, and not vice-versa. (The writer prints the master
;;;	  object first, then the bound synonym second).
;;;    2. overall-expr-for-slot, global-expr-for-slot, and local-expr-for-slot
;;;	  in interpreter.lisp assumes this binding order (see that 
;;;	  file for notes), putting *Global instances before situation-specific
;;;	  ones.
;;;    3. get-unified-all puts local instances before inherited expressions,
;;;	  so that the local instance names persist.
;;; [1] I don't know why, but I enforced the classes-subsumep constraint *always* for
;;;     non-kb-objects. This means (100 & (a Coordinate)) fails, which I don't think it should.
(defun unify-names (instance1 instance2 classes-subsumep)
  (cond ((eq  instance1 instance2) (values instance1 nil)) 			; (*car2 & *car2)
 	((and (not (kb-objectp instance1))					; ("a" & _string23) [1]
	      (anonymous-instancep instance2))
	 (cond ((immediate-classes-subsume instance1 instance2)
		(values instance1 (list (list instance2 instance1))))))
 	((and (not (kb-objectp instance2))					; (_string23 & "a") [1]
	      (anonymous-instancep instance1))
	 (cond ((immediate-classes-subsume instance2 instance1)
		(values instance2 (list (list instance1 instance2))))))
					    ;;; else, if it's not of the above special 
					    ;;; cases, check they are unifiable (based on classes)
	((and (named-instancep instance1) (named-instancep instance2)) nil)	; (*f & *g), ("a" & "b") FAILS
	((compatible-classes :instance1 instance1 :instance2 instance2 :classes-subsumep classes-subsumep) ; two KB objects, >= 1 anonymous
										; then create binding list as needed.
	 (cond 									; (X & Y): special cases where Y takes precidence:
	       ((or (named-instancep instance2)					; (_person12 & *fred)	return *fred
		    (and (fluent-instancep instance1) 					; (_someCar12 & _Car2)  return _Car2
			 (anonymous-instancep instance2)))
		(values instance2 (list (list instance1 instance2))))
	       (t (values instance1 (list (list instance2 instance1))))))))	; ELSE (X & Y) return X 

;;; (immediate-classes-subsume '123 '_number3)   -> t    because _number3 isa number
(defun immediate-classes-subsume (instance1 instance2)
  (let ( (immediate-classes1 (immediate-classes instance1)) 
	 (immediate-classes2 (immediate-classes instance2)) )
    (classes-subsume-classes immediate-classes2 immediate-classes1)))

#|
superceded by compatible-classes in frame-io.lisp
(defun passes-subsumption-test (instance1 instance2 classes-subsumep)
  (cond (classes-subsumep
	 (or (immediate-classes-subsume instance1 instance2)
	     (immediate-classes-subsume instance2 instance1)))
	(t (not (disjoint-class-sets (all-classes instance1) 
				     (all-classes instance2))))))
|#
;;; ======================================================================
;;;		UNIFICATION OF SLOTSVALS
;;; ======================================================================
#|
Unification with constraint checking:

_Person1			_Person2
--------			--------
  pets: Dog			  pets: Dog	(must-be-a Animal)
	---				---
 	  color: Red			  color: Blue

&&: Must check the first-level slots, that the values satisfy the
    constraints. The search for constraints is global, and if any are found
    then the search for values is global also. 
    If there are no constraints, then && is guaranteed to succeed and so 
    doesn't need to be computed.

&: As well as checking the first-level slot constraints, lazy-unify-vals does a
   &? check, which recursively checks that the second-level slot constraints
   are satisfied (eg. if color is single-valued, that Red and Blue are 
   unifiable). Note that a second-level check isn't needed with &&.

[1] As well as explicit constraints, there are also partition constraints which 
    must be checked for &, which means we must do an aggressive (the slot of X)
    for & operations, regardless of whether constraints are found or not.

Note we only check/perform unification for slots which explicitly occur on either
i1 or i2. All other slots are ignored.

lazy-unify-slotsvals
--------------------
Returns two values
 - t or nil, depending on whether unification was successful
   (If nil, then the unified slotsvals are partial and can be discarded)
 - the unified slotsvals
This was extended in Aug 99 to include constraint checking, so that the procedure
will fail if there's a constraint violation (even if only one instance actually has
a slot value).

[1] It's only with eagerlyp that lazy-unify-vals will evaluate the unification and squish out the constraints (thus they need to be reinstalled)

|#
(defun lazy-unify-slotsvals (i1 i2 svs1 svs2 &key cs1 cs2 classes-subsumep eagerlyp (check-constraintsp t))
  (cond
   ((and (endp svs1)
	 (endp svs2)))	; ie. return (values t nil)
   (t (let* ( (sv1  (first svs1))
	      (slot (or (first sv1) 		; work through svs1 first. When done, 
			(first (first svs2))))	; work through remaining svs2.
	      (exprs1 (second sv1))
	      (sv2 (assoc slot svs2))
	      (exprs2 (second sv2))
	      (rest-svs2 (remove-if #'(lambda (a-sv2)
					(eq slot (car a-sv2)))
				    svs2)) )
	(cond ((and (null exprs1) (null exprs2)) ; vals both null, so drop the slot
	       (lazy-unify-slotsvals i1 i2 (rest svs1) rest-svs2 :cs1 cs1 :cs2 cs2 :classes-subsumep classes-subsumep :eagerlyp eagerlyp
				     :check-constraintsp check-constraintsp))
	      ((or (not check-constraintsp)
		   (check-slotvals-constraints slot i1 i2 exprs1 exprs2 :cs1 cs1 :cs2 cs2 :eagerlyp eagerlyp))
	       (let ( (unified-vals (lazy-unify-vals slot exprs1 exprs2 :classes-subsumep classes-subsumep :eagerlyp eagerlyp)) )
		 (cond (unified-vals			;; else fail (return NIL)
			(multiple-value-bind
			 (successp unified-rest)
			 (lazy-unify-slotsvals i1 i2 (rest svs1) rest-svs2 :cs1 cs1 :cs2 cs2 
					       :classes-subsumep classes-subsumep :eagerlyp eagerlyp :check-constraintsp check-constraintsp)
			 (values successp (cons (list slot unified-vals) unified-rest))))))))))))

; move this into lazy-unify-vals
;			 (cond (successp
;				(let ( (new-vals (cond ((and eagerlyp *are-some-constraints*)				; [1]
;							(reinstate-constraints slot unified-vals exprs1 exprs2))
;						       (t unified-vals))) )
;				  (values successp (cons (list slot new-vals) unified-rest)))))))))))))))

#|
======================================================================
	check-slotvals-constraints
======================================================================
This function has no side-effects. It's purpose is to check the unified slot values are consistent with
constraints. This requires KM doing a bit of work, both to find the constraints and find the slot values
themselves in some cases.

[2] suppose unify Group1 in S1 and S2. We are currently in S1, but Group1 only has location in S2.
while svs2 contains that location information, doing another query will get rid of it, so vs2 = nil, and hence the
unification is nil.
[2] ALSO for unifiable-with-slotsvals test
[3] May 2000: We also allow this to be called with i1, i2 = NIL. This occurs
    when we want to just merge two structures together (from merge-slotsvals), or merge
    a structure with an instance (from unifiable/unify-with-existential-expr)
    IF WE DO THIS, THOUGH, then we *must* supply the class for the missing instance,
    so we can still gather the inherited constraints for the structure. This is done
    via cs1 and cs2.
BUT: we also have a problem. If we are dealing with a structure (i2 = nil), then we don't just 
     need the inherited constraints, we also need the inherited slot-values, as these may 
     clash with constraints on/inherited by i1.
     And suppose these inherited expressions refer to Self? We've no Self to evaluate them for!

	(a Person with			   &? (a Person-With-Favorite-Color-Red with
	  (likes ((<> *Red))))			   (likes ((the favorite-color of Self))))
								^^ need to evaluate this path!
SOLUTION might be to collect expr sets.
[6] What if EXPR contains Self? Simplest: Ignore them. This means the constraints will not be
tested, but we won't "lose things" in the KB. Better would be to add a tmp-i creation and
deletion again (sigh) to be thorough.
[5] What if EXPR contains an existential? Don't want to litter the KB with temporary instances!!
So ignore them again.

[4] We *only* want to pull in generalizations if we are checking constraints!
This is a compromise between always getting just the local values, and always pulling in the inherited values.
Version2 causes looping with unifying prototypes (see test-suite/outstanding/protobug.km), it's generally a dangerous and
expensive thing to do inheritance as part of unification computation.
[7] Note, we have to use (collect-constraints-on-instance i1...), rather than look in exprs1, because there may
    be constraints on i1 in a supersituation.
|#
(defun check-slotvals-constraints (slot i1 i2 exprs1 exprs2 &key cs1 cs2 eagerlyp)
  (let* 
    ( (cs1-expr-sets (cond (cs1 (remove-if #'contains-self-keyword						; [6]
					   (cons exprs1 (collect-rule-sets-on-classes cs1 slot))))
			   (t (list exprs1))))				; in case eagerlyp, we just do val-sets-to-expr
      (cs2-expr-sets (cond (cs2 (remove-if #'contains-self-keyword
					   (cons exprs2 (collect-rule-sets-on-classes cs2 slot))))
			   (t (list exprs2))))
      (constraints (remove-duplicates 
		    (append (cond (i1 (collect-constraints-on-instance i1 slot)) ; [3], [7]
				  (cs1 (mapcan #'find-constraints-in-exprs cs1-expr-sets))
				  (t (report-error 'program-error "Missing both instance1 and class1 in lazy-unify-slotsvals!~%")))
			    (cond (i2 (collect-constraints-on-instance i2 slot))
				  (cs2 (mapcan #'find-constraints-in-exprs cs2-expr-sets))
				  (t (report-error 'program-error "Missing both instance2 and class2 in lazy-unify-slotsvals!~%"))))
		    :test #'equal)) )
;		   (km-format t "constraints = ~a~%" constraints)
    (cond ((and (not constraints)				; no constraints...
		(or (multivalued-slotp slot)		
		    (null exprs1)   ; [1] for single-valued, may be partition constraints 
		    (null exprs2))  ;  to check if there are *both* exprs1 and exprs2. Here I'm
				    ; not looking for & checking inferred values (incompleteness)
		(not eagerlyp)))
	  (t (km-trace 'comment "Unify: Checking constraints on the ~a slot..." slot)			; [4]
;	     (km-format t "i1 = ~a, slot = ~a, cs1-expr-sets = ~a~%" i1 slot cs1-expr-sets)
;	     (km-format t "i2 = ~a, slot = ~a, cs2-expr-sets = ~a~%" i2 slot cs2-expr-sets)
	     (let* ( (vs1 (cond ((and i1 (or constraints (single-valued-slotp slot)) (not eagerlyp))
				 (km `#$(the ,SLOT of ,I1) :fail-mode 'fail))
				(t (km (val-sets-to-expr (remove-if #'contains-some-existential-exprs cs1-expr-sets)) 	; [5]
				       :fail-mode 'fail))))
		     (vs2 (cond ((and i2 (or constraints (single-valued-slotp slot)) (not eagerlyp))
				 (km `#$(the ,SLOT of ,I2) :fail-mode 'fail))
				(t (km (val-sets-to-expr (remove-if #'contains-some-existential-exprs cs2-expr-sets))
				       :fail-mode 'fail)))) )
;		     (_d (km-format t "vs1 = ~a, vs2 = ~a~%" vs1 vs2))
	       (cond 
		((and (test-constraints vs1 constraints)
		      (test-constraints vs2 constraints)))
		(t (cond ((and i1 i2) (km-trace 'comment "Instances ~a and ~a won't unify [constraint violation on slot `~a':" i1 i2 slot))
			 (i1 (km-trace 'comment "Instance ~a won't unify with structure ~a [constraint violation on slot `~a':" i1 cs1 slot))
			 (i2 (km-trace 'comment "Instance ~a won't unify with structure ~a [constraint violation on slot `~a':" i2 cs2 slot))
			 (t (km-trace 'comment "Structures ~a and ~a won't unify [constraint violation on slot `~a':" cs1 cs2 slot)))
		   (km-trace 'comment "  constraints ~a violated by value(s) in ~a.]" constraints (append vs1 vs2)))))))))

;;; ======================================================================
;;;		LAZY-UNIFY-VALS
;;; ======================================================================

#|
lazy-unify-vals: One of the vs1 or vs2 may be nil, **but not both**
		 RETURNS NIL if they CAN'T be unified for some reason.
(_v1) (_v2) -> ((_v1 & _v2))
((a cat)) ((a hat)) -> (((a cat) & ((a hat)))
[1]: and-append returns a (singleton) LIST of expressions, but we just want to pass a SINGLE expression to KM.
[2] If this unification fails, it doesn't mean a KB error, it just means that the two parent instances can't be unified.
    The failure is passed up to lazy-unify-slotsvals above, and the unification aborted. lazy-unify-slotsvals returns successp NIL.
[3]: KM necessarily returns either NIL or a singleton list here.
[4]: In the special case of ((<> foo) &! (<> bar)), an answer of NIL from evaluating the expression *doesn't* constitute failure of the
	unification.
[5]: Not an error, but would like to tidy this up: ((<> foo) &&! (<> bar)) should be reduced to ((<> foo) (<> bar))
|#
(defun lazy-unify-vals (slot vs1 vs2 &key classes-subsumep eagerlyp) 
  (declare (ignore classes-subsumep))  ; now classes-subsumep is redundant. Remove at later date.
 (cond ((null vs2) vs1)			; NB With more aggressive constraint checking, we won't just deal with local values but 
	((null vs1) vs2)		;    compute global values, to check there's no constraint violation. = too expensive??
	((equal vs1 vs2) vs1)
	((remove-subsumers-slotp slot) (remove-subsumers (append vs1 vs2)))				; eg. instance-of, superclasses
	((remove-subsumees-slotp slot) (remove-subsumees (append vs1 vs2)))				; eg. subclasses
	((atomic-vals-only-slotp slot) (remove-dup-instances (append vs1 vs2)))	; optimized access methods assume atomic values only.
	((single-valued-slotp slot)
	 (cond ((or (not (singletonp vs1))
		    (not (singletonp vs2)))
		(report-error 'user-error 
			 "A single-valued slot has multiple values!~%Doing unification (~a & ~a)~%Continuing with just the first values (~a & ~a)~%" 
			      vs1 vs2 (first vs1) (first vs2))))
	 (cond ((km `(,(first vs1) &? ,(first vs2)) :fail-mode 'fail)			; [2]
		(cond (eagerlyp 
		       (let ( (new-vals (km (vals-to-val (and-append (list (first vs1)) '&! (list (first vs2))))    ; eagerly -> do it!  [1],[3]
					    :fail-mode 'fail)) )						    ; [4]
			 (cond ((not *are-some-constraints*) new-vals)
			       ((or new-vals
				    (and (null (remove-constraints vs1))					    ; [4]
					 (null (remove-constraints vs2))))
				(val-to-vals (vals-to-&-expr (remove-duplicates (append new-vals
											(find-constraints-in-exprs vs1) 
											(find-constraints-in-exprs vs2))
										:test #'equal)))))))
		      (t (and-append (list (first vs1)) '& (list (first vs2))))))))
;;	(eagerlyp (and-append vs1 '&&! vs2))						; [5]
#|NEW|#	(eagerlyp (let ( (vs1-vals (remove-constraints vs1))				; see note [7] under lazy-unify-expr-sets
			 (vs2-vals (remove-constraints vs2))
			 (vs1-constraints (find-constraints-in-exprs vs1))
			 (vs2-constraints (find-constraints-in-exprs vs2)) )
		    (cond ((null vs1-vals) (append vs2-vals vs1-constraints vs2-constraints))
			  ((null vs2-vals) (append vs1-vals vs1-constraints vs2-constraints))
			  (t (append (and-append vs1-vals '&&! vs2-vals) vs1-constraints vs2-constraints)))))
; OLD	(eagerlyp (let ( (new-vals (km (vals-to-val (and-append vs1 '&&! vs2)) :fail-mode 'fail)) )			; eagerly -> do it! [1]
;		    (cond ((not *are-some-constraints*) new-vals)
;			  ((or new-vals
;			       (and (null (remove-constraints vs1))
;				    (null (remove-constraints vs2))))						; [4]
;			   (remove-duplicates (append new-vals
;						      (find-constraints-in-exprs vs1) 
;						      (find-constraints-in-exprs vs2))
;					      :test #'equal)))))
        (t (and-append vs1 '&& vs2))))

;;; ---------
#|
;;; This function re-inserts the local constraints into the unified expressions
;;; [1] multi-valued slot, [2] single-valued slot
;;; [1] (reinstate-constraints '#$foo '(x y) '#$((<> z) (<> p)) '#$((must-be-a C)))  -> #$(x y (<> z) (<> p) (must-be-a c))
;;; [2] (reinstate-constraints '#$foo '((x & y)) '#$((<> z) (<> p)) '#$((must-be-a C))) -> ((x & y & (<> z) & (<> p) & (must-be-a c)))
(defun reinstate-constraints (slot unified-vals exprs1 exprs2)
  (let ( (local-constraints (append (find-constraints-in-exprs exprs1) (find-constraints-in-exprs exprs2))) )
    (cond ((not local-constraints) unified-vals)
	  ((single-valued-slotp slot) 
	   (list (vals-to-&-expr (remove-duplicates (append (un-andify unified-vals) local-constraints) :test #'equal))))
	  (t (remove-duplicates (append unified-vals local-constraints) :test #'equal)))))
|#


#|
; NEW:
	 (cond ((km `#$((the ,SLOT of ,I1) &?  (the ,SLOT of ,I2)) :fail-mode 'fail)	; returns a shorter unification expression (or fails).
		(and-append (list (first vs1)) '& (list (first vs2))))))
; OLD	(t (km `(,vs1 &&? ,vs2) :fail-mode 'fail))))
; NEW:
	v1s the slot of i1
	v2s the slot of i2
	THEN do &&


	((km `#$((the ,SLOT of ,I1) &&? (the ,SLOT of ,I2)) :fail-mode 'fail)
	 (and-append vs1 '&& vs2))))
|#

; OLD	   (let ( (v1 (first vs1))
; OLD		  (v2 (first vs2)) )
;#|NEW|#	   (km-trace 'comment "Seeing if values for single-valued slot `~a' are unifiable..." slot)
;#|NEW|#	   (km-trace 'comment "(Values are: ~a and ~a)" (first vs1) (first vs2))
;#|NEW|#	   (let ( (v1 (km-unique (first vs1) :fail-mode 'fail))
;#|NEW|#		  (v2 (km-unique (first vs2) :fail-mode 'fail)) )
;	     (cond ((and (atom v1) (atom v2))		    ; Check for inconsistency
;		    (let ( (vv1 (dereference v1))    ; just in this special case	; DEREF NOT NECESSARY WITH NEW
;			   (vv2 (dereference v2)) )  ; of two named single values.
;		      (cond ((and (named-instancep vv1)
;				  (named-instancep vv2))
;			     (cond ((equal vv1 vv2) (list vv1))))   ; else FAIL (nil)
; OLD			    (t 
;#|NEW|#			    ((km `(,vv1 &? ,vv2) :fail-mode 'fail)	; test feasibility of unification
;			     (and-append (list vv1) '& (list vv2))))))
;		   (t (and-append (list v1) '& (list v2))))))))

;;; ======================================================================
;;; 		LAZY-UNIFY-EXPRS
;;; Does a subsumption check first
;;; ======================================================================

;;; Must be an & expr, ie. either (a & b), or ((a b) && (c d))
;;; The arguments to &/&& may themselves be &/&& expressions, 
;;; 	eg. ((a & b) & c),  
;;;	    ( (((a b) && (c d))) && (e f) )
;;; [ Note  (  ((a b) && (c d))  && (e f) ) is illegal, as the args to && must be a *list* of expressions ]
;;; ALWAYS returns a list of values (necessarily singleton, for '&)
(defun lazy-unify-&-expr (expr &key (joiner '&) (fail-mode 'error))
  (let* ( ; (constraints (find-constraints expr))		OLD
	  (constraints nil)					; DISABLE now! - move to get-slotvals.lisp
	  (unified0 (lazy-unify-&-expr0 expr :joiner joiner :fail-mode fail-mode))
	  (unified (cond ((val-unification-operator joiner) (list unified0)) 	; must listify for &
			 (t unified0)))
	  (checked (cond (constraints (enforce-constraints unified constraints))
			 (t unified))) )
    (remove nil checked)))

(defun lazy-unify-&-expr0 (expr &key (joiner '&) (fail-mode 'error))
  (cond ((and (tracep) (not (traceunifyp)))
	 (prog2 (suspend-trace) (lazy-unify-&-expr1 expr :joiner joiner :fail-mode fail-mode) (unsuspend-trace)))
	(t (lazy-unify-&-expr1 expr :joiner joiner :fail-mode fail-mode))))

;;; Input: A & or && expression. Output: a value (&) or value set (&&)
(defun lazy-unify-&-expr1 (expr &key (joiner '&) (fail-mode 'error))
  (cond ((null expr) nil)
	((and (listp expr)
	      (eq (second expr) joiner))		; either (a & b) or (a & b & c)
	 (cond ((>= (length expr) 4)
		(cond ((neq (fourth expr) joiner)
		       (report-error 'user-error "Badly formed unification expression ~a encountered during unification!~%" expr)))
		(let ( (revised-expr (cond		 ; (a & b & c) -> ((a & b) & c),  (as && bs && cc) -> (((as && bs)) & c)  [NB extra () for &&]
				      ((val-unification-operator joiner)
				       `( (,(first expr)  ,joiner ,(third expr))   ,joiner ,@(rest (rest (rest (rest expr))))))
				      ((set-unification-operator joiner)
				       `(((,(first expr) ,joiner ,(third expr)))   ,joiner ,@(rest (rest (rest (rest expr)))))))) )
		  (lazy-unify-&-expr1 revised-expr :joiner joiner :fail-mode fail-mode)))
	       ((val-unification-operator joiner)
		(lazy-unify-exprs (lazy-unify-&-expr1 (first expr) :joiner joiner :fail-mode fail-mode) 
				  (lazy-unify-&-expr1 (third expr) :joiner joiner :fail-mode fail-mode)
				  :eagerlyp (eq joiner '&!) :fail-mode fail-mode))
	       ((set-unification-operator joiner)
		(lazy-unify-expr-sets (lazy-unify-&-expr1 (first expr) :joiner joiner :fail-mode fail-mode) 
				      (lazy-unify-&-expr1 (third expr) :joiner joiner :fail-mode fail-mode)
				      :eagerlyp (eq joiner '&&!) :fail-mode fail-mode))))
	((and (singletonp expr)				; special case: (((a b) && (c d))) [NB double parentheses] -> (a b c d) 
	      (listp (first expr))			; This comes if I do (((set1 && set2)) && set3)
	      (set-unification-operator joiner)		; Note: ((set1 && set2) && set3) is badly formed! (&& takes a *set* of expressions)
	      (eq (second (first expr)) joiner))		
	 (lazy-unify-&-expr1 (first expr) :joiner joiner :fail-mode fail-mode))
	(t expr)))

;;; ======================================================================
;;; 	    UNIFICATION OF TWO EXPRESSIONS
;;; Returns an ATOM. Must be listified to return to KM
;;; This *DOESN'T* enforce type constraints
;;; ======================================================================

;;; [1] Classify does a &, then does (undone X), which rechecks the classification a second time.
;;; Thus classify needs to know if & fails, or else it will loop repeatedly rechecking the classification.
;;; Thus we make lazy-unify-exprs return NIL rather than have a recovery attempt if there's a problem.
;;; [2] fail-mode = fail, not error here, as we want to report the error at the lazy-unify-exprs
;;;	level, not here.
(defun lazy-unify-exprs (x y &key eagerlyp classes-subsumep (fail-mode 'error))
  (cond ((and (null x) (null y)) nil)
	((null x) (km-unique y :fail-mode 'fail))		; [2]
	((null y) (km-unique x :fail-mode 'fail))
	((is-existential-expr y)
	 (let ( (xf (km-unique x :fail-mode 'fail)) )
	   (cond ((null xf) (km-unique y :fail-mode 'fail))
		 (t (unify-with-existential-expr xf y :classes-subsumep classes-subsumep :eagerlyp eagerlyp
						 :fail-mode fail-mode)))))
	((is-existential-expr x)
	 (let ( (yf (km-unique y :fail-mode 'fail)) )
	   (cond ((null yf) (km-unique x :fail-mode 'fail))
		 (t (unify-with-existential-expr yf x :classes-subsumep classes-subsumep :eagerlyp eagerlyp
						 :fail-mode fail-mode)))))
	(t (let ( (xf (km-unique x :fail-mode 'fail))
		  (yf (km-unique y :fail-mode 'fail)) )
	     (cond 
	      ((null xf) yf)
	      ((null yf) xf)
	      ((and (is-km-term xf) (is-km-term yf))
	       (cond ((lazy-unify xf yf :eagerlyp eagerlyp :classes-subsumep classes-subsumep))
		     ((eq fail-mode 'error)
		      (report-error 'user-error "Unification (~a ~a ~a) failed!~%" xf 
				    (cond (eagerlyp '&!) (classes-subsumep '&+) (t '&)) yf)
#| NEW - give up [1] |#		   nil)))		
	      ((eq fail-mode 'error)
	       (report-error 'user-error 
			     "Arguments in a unification expression should be unique KM objects!~%Doing (~a ~a ~a) [ie. (~a ~a ~a)]~%" 
			     x (cond (eagerlyp '&!) (classes-subsumep '&+) (t '&)) y
			     xf (cond (eagerlyp '&!) (classes-subsumep '&+) (t '&)) yf)))))))

#| older version
The above calls on unify-with-existential-expr to avoid creating and then deleting a Skolem constant.
This turns out to be important for enforcing (must-be-a ...) constraints.
(defun lazy-unify-exprs (x y &key eagerlyp)
  (cond ((and (null x) (null y)) nil)
	((null x) (km-unique y :fail-mode 'fail))
	((null y) (km-unique x :fail-mode 'fail))
	(t (let ( (xf (km-unique x :fail-mode 'fail)) )	; don't complain if no value found
	     (cond 
	      ((null xf) (km-unique y :fail-mode 'fail))
	      ((and (is-existential-expr y)
		    (km `#$(,XF is ',Y) :fail-mode 'fail)) xf)	; NEW: add quote '
	      (t (let ( (yf (km-unique y :fail-mode 'fail)) )
		   (cond ((null yf) xf)
			 ((and (is-km-term xf) (is-km-term yf))
			  (cond ((lazy-unify xf yf :eagerlyp eagerlyp))
				(t (report-error 'user-error "Unification (~a ~a ~a) failed!~%" xf (cond (eagerlyp '&!) (t '&)) yf)
				   nil)))		; ;NEW - give up [1]
			 (t (report-error 'user-error 
					  "Arguments in a unification expression should be unique KM objects!~%Doing (~a ~a ~a) [ie. (~a ~a ~a)]~%" 
					  x (cond (eagerlyp '&!) (t '&)) y
					  xf (cond (eagerlyp '&!) (t '&)) yf))))))))))
|#

;;; ======================================================================
;;;		LAZY-UNIFY-EXPR-SETS
;;; Handling of expressions: Here KM limits the evaluation of the second expression list,
;;; so as to avoid creating unnecessary instances and simplify the proof trace.
;;; HOWEVER: This is extremely cryptic to watch in the normal execution of KM,
;;; so hide it from the user!!
;;; ======================================================================

;;; Allows us to switch off KM's heuristic unification mechanism
(defparameter *no-heuristic-unification* nil)

#|
						((_Door178 _Door179 _Cat23 _Bumper176) && ((a Cat) (MyCar has-door) (a Door) (a Door))  
  [1] evaluate any non-existential exprs		((_Door178 _Door179 _Cat23 _Bumper176) && ((a Cat) _Door178 (a Door) (a Door)))
  [2] remove duplicates				(_Door178) APPEND ((_Door179 _Cat23 _Bumper176) && ((a Cat) (a Door) (a Door))
  [3] remove subsuming elements  		(_Door178 _Door179 _Cat23) APPEND ((_Bumper176) && ((a Door)))
  [4] evaluate the remaining exprs		(_Door178 _Door179 _Cat23) APPEND ((_Bumper176) && (_Door180))
  [5] unify the result				(_Door178 _Door179 _Cat23 _Bumper176 _Door180)

[6] NOTE this is guaranteed to succeed, as there are no constraints here (constraints are on expressions in situ on slots)

[7] Eager set unification: previous error:
	(_Move3 _Enter4) &&! (_Enter5)
     With :eagerlyp passed to lazy-unify-sets, thus to lazy-unify-vals, I *force* _Enter5 and _Move3 to unify, even if there's a 
	constraint violation. Urgh!
    Really I need a two-pass implementation:
	  (i) Do a &&
	  (ii) Evaluate the subexpression unifications & / &&
(((_Car1 with (color (_Red1 _Green1))) _Toy1) &&! ((_Car2 with (color (_Green2)))))
 -> ((_Car12 with (color (((_Red1 _Green1) &&! _Green2)))) _Toy1)
  -> need to map through all the slot-values of the unifications, looking for &&! and executing them.
     Will this catch them all? I *think* so.  Note &! CAN be executed within lazy-unify-slotvals, as this IS unambiguous, and thus
	we don't need this two-pass approach.
     I haven't accounted for multiple situations, though.
|#

(defun lazy-unify-expr-sets (exprs1 exprs2 &key eagerlyp (fail-mode 'error))
  (declare (ignore fail-mode))							; [6]
  (let ( (set1 (km (vals-to-val exprs1) :fail-mode 'fail)) )
    (cond 
     ((null set1) (km (vals-to-val exprs2) :fail-mode 'fail))
     ((not (listp exprs2))
      (report-error 'user-error "(~a && ~a): Second argument should be a set of values, but just found a single value ~a!~%"
		    exprs1 exprs2 exprs2))
     (t (let* 
	    ( (set2 (my-mapcan #'(lambda (expr)					; [1] evaluate definite exprs in set2
				   (cond ((or (not (is-existential-expr expr)) 
					      *no-heuristic-unification*)
					  (km expr :fail-mode 'fail))
					 (t (list expr))))
			       exprs2))
	      (shared-elements (ordered-intersection set1 set2))		; [2]
	      (reduced-set1 (ordered-set-difference set1 shared-elements))	
	      (reduced-set2 (ordered-set-difference set2 shared-elements)) )
;	  (multiple-value-bind
;	   (more-reduced-set1 more-reduced-set2 more-shared-elements)
;	   (do-forced-unifications reduced-set1 reduced-set2 :eagerlyp eagerlyp)
	  (let ( (more-reduced-set1 reduced-set1)			; cut out the forced unifications...
		 (more-reduced-set2 reduced-set2)
		 (more-shared-elements nil) )
	   (multiple-value-bind
	    (remainder-set2 remainder-set1 subsumed-set1)			; [3]
; PC	    (remove-subsuming-exprs more-reduced-set2 more-reduced-set1)	; (expects exprs first, instances next)
; PC - Can I get away with :allow-coeercion t?? What will the effect be?
#|PC|#	    (remove-subsuming-exprs more-reduced-set2 more-reduced-set1 :allow-coercion *new-approach*) 

	    (let* ( (new-set2 (my-mapcan #'(lambda (expr)			; [4] now evaluate (remaining) existential exprs in set2
					     (cond ((is-existential-expr expr)
						    (km expr :fail-mode 'fail))
						   (t (list expr))))
					 remainder-set2))
; [7] OLD	    (unified (lazy-unify-sets remainder-set1 new-set2 :eagerlyp eagerlyp)) ) ; [5]
;	      (append shared-elements more-shared-elements subsumed-set1 unified))))))))))
#| NEW |#	    (unified (lazy-unify-sets remainder-set1 new-set2))
		    (final-result (append shared-elements more-shared-elements subsumed-set1 unified)) )
 	        (cond (eagerlyp (mapc #'eagerly-evaluate-exprs final-result)))
		final-result))))))))

;;; This implements the eager evaluation of sub-unified expressions.
(defun eagerly-evaluate-exprs (instance &optional (situation (curr-situation)))
  (mapc #'(lambda (slotvals)
	    (cond ((minimatch (vals-in slotvals) '((?x &&! ?y) &rest))
		   (km `#$(the ,(SLOT-IN SLOTVALS) of ,INSTANCE) :fail-mode 'fail))))
	(get-slotsvals instance 'own-properties situation)))

#| 
INPUT: set1 set2
RETURNS: three values:
	- shorter set1
	- shorter set2
	- list of items which unified via forcing (through the :tag slot) 
|#
#|
No longer used...
(defun do-forced-unifications (set1 exprs2 &key eagerlyp)
  (cond ((endp set1) (values nil exprs2 nil))
	(t (let* ( (val1 (first set1))
		   (val1-tags (find-vals val1 *tag-slot*))
		   (matches (remove-if-not #'(lambda (expr) 
						    (intersection (tags-in-expr expr) val1-tags))
						exprs2))
		   (val2 (first matches))
		   (val2-tags (cond (val2 (tags-in-expr val2)))) )
	     (cond ((null matches)
		    (multiple-value-bind
		     (reduced-set1 reduced-exprs2 unifications)
		     (do-forced-unifications (rest set1) exprs2)
		     (values (cons val1 reduced-set1) reduced-exprs2 unifications)))
		   ((>= (length matches) 2)
		    (report-error 'user-error "Tagging error! ~a's ~a values ~a state it should unify with multiple, distinct values:~%       ~a!~%" 
				  val1 *tag-slot* val1-tags matches))
		   ((not (is-consistent (append val1-tags val2-tags)))
		    (report-error 'user-error 
				  "Tag inconsistency! ~a and ~a have tags both forcing and disallowing unification!~%       Tag sets were: ~a and ~a~%"
				  val1 val2 val1-tags val2-tags))
		   (t (cond ((is-existential-expr val2)							; UNIFY! Result = val1
			     (cond ((is0 val1 val2)							; val2 subsumes val1, so no unification needed....
				    (cond ((set-difference val2-tags val1-tags)				; ...except for tranferring the tags.
					   (km `(,val1 #$has (,*tag-slot* ,val2-tags))))))
				   (t (lazy-unify val1 (km-unique val2) :eagerlyp eagerlyp))))		; otherwise we do unify them
			    (t (lazy-unify val1 val2 :eagerlyp eagerlyp)))
		      (multiple-value-bind
		       (reduced-set1 reduced-exprs2 unifications)
		       (do-forced-unifications (rest set1) (remove val2 exprs2 :test #'equal))
		       (values reduced-set1 reduced-exprs2 (cons val1 unifications)))))))))

;;; ----------

;;; expr is necessarily an *instance* or an *existential expr*
(defun tags-in-expr (expr)
  (cond ((kb-objectp expr) (find-vals expr *tag-slot*))
	(t (let ( (class+slotsvals (is-existential-expr expr)) )
	     (cond (class+slotsvals (vals-in (assoc *tag-slot* (second class+slotsvals)))))))))
|#

;;; ======================================================================
;;;		LAZY-UNIFY-SETS
;;; Here KM makes a plausible guess as to which members of the sets should
;;; be coreferential.
;;; Is an ***auxiliary function*** to lazy-unify-expr-sets, not called from
;;; anywhere else in KM.
;;; ======================================================================

#|
(lazy-unify-sets set1 set2)
For the members which *will* unify, actually do the unification.
Below does not allow *different* set1s to unify with the *same* set2.
Both sets must be lists of instances. They will already have been dereferenced before this point.
[1] need :count 1, so that ((Open) && (Open Open)) = (Open Open), not just (Open)
[2] Need to first remove duplicate, named instances, so that
	((*MyCar) && (_Car2 *MyCar))  = (_Car2 *MyCar), not (*MyCar)
MAR99: Why just named?
	((_Car3) && (_Car2 _Car3))  = (_Car2 _Car3), not (_Car3)
|#
(defun lazy-unify-sets (set1 set2 &key eagerlyp)
  (cond 
   (*no-heuristic-unification* (remove-dup-atomic-instances (append set1 set2)))
   (t (let ( (shared-elements (ordered-intersection set1 set2)) )
	(cond (shared-elements 			; [2]
	       (append shared-elements 
		       (lazy-unify-sets2 (ordered-set-difference set1 shared-elements)
					 (ordered-set-difference set2 shared-elements)
					 :eagerlyp eagerlyp)))
	      (t (lazy-unify-sets2 set1 set2 :eagerlyp eagerlyp)))))))
   
(defun lazy-unify-sets2 (set1 set2 &key eagerlyp)
  (cond ((endp set1) set2)
	((endp set2) set1)
; NEW: Experimental interactive version: - spot ambiguities
;	(t (let* ( (unifees (remove-if-not #'(lambda (set2el)
;						(try-lazy-unify (first set1) set2el :classes-subsumep t :eagerlyp eagerlyp))
;					    set2))
;		   (unifee (cond ((>= (length unifees) 2)
;				   (let ( (target (menu-ask (km-format nil "Ambiguous unification! What should ~a equal?" (first set1))
;							    (append unifees '("None of the above")))) )
;				     (cond ((string/= target "None of the above") target))))
;				  (t (first unifees))))
;		   (unifier (cond (unifee (km-unique `(,(first set1) & ,unifee))))) )
; OLD
	(t (let ( (unifier (find-if #'(lambda (set2el)
					(lazy-unify (first set1) set2el :classes-subsumep t :eagerlyp eagerlyp))
				    set2)) )
; back to original code...
	     (cond (unifier (cons unifier (lazy-unify-sets (rest set1) 
							   (remove unifier set2 :count 1)
							   :eagerlyp eagerlyp)))  ; [1]
		   (t (cons (first set1) (lazy-unify-sets (rest set1) set2
							  :eagerlyp eagerlyp))))))))
	     

;;; ======================================================================
;;;	MACHINERY FOR REMOVING DUPLICATES WHEN &'ing TOGETHER STUFF
;;; ======================================================================

#|
and-append: 
 - Takes two *sets* of values. For &, those sets will necessarily be singletons.
 - Returns a *set* containing a *single* value, = the unification of those 
	two sets (either using & or && as specified in the call).

This simple task ends up being surprisingly tricky to implement correctly...

;;; without duplicates
(and-append '(a) '& '(b)) 		;-> ((a & b))
(and-append '(a) '& '((b & c))) 	;-> ((a & b & c))
(and-append '((a & b)) '& '((c & d))) 	;-> ((a & b & c & d))

;;; with duplicates
(and-append '(a) '& '((b & a))) 	;-> ((b & a))
(and-append '((b & a)) '& '(a)) 	;-> ((b & a))
(and-append '((a & b)) '& '((c & a))) 	;-> (( b & c & a))

The critical property is that repeated and'ing doesn't make the list grow indefinitely:
(and-append '(a) '& '(b))		;-> ((a & b))
(and-append '((a & b)) '& '(b))		;-> ((a & b))
(and-append '(a b) '&& '(c d))		;-> (((a b) && (c d)))
(and-append '(((a b) && (c d))) '&& '(c d)) ;-> (((a b) && (c d)))

Inputs get converted to call and-append2 as follows:
(((a b) && (c d)))      (((a b) && (e f))) [1a] -> ((a b) && (c d))     ((a b) && (e f))
((a & b))		((a & c))	   [1b] -> (a & b)		(a & c)
(((a b) && (c d)))      (a b)		   [2a] -> ((a b) && (c d))     ((a b))
((a & b))		(a)		   [2b] -> (a & b)		(a)
(a b)			(c d)		   [3a] -> returns  ((a b) && (c d))
(a)			(c)		   [3b] -> returns  (a & b)
|#
(defun and-append (xs and-symbol ys)
  (cond ((and (singletonp xs) 			; (((a b) && (c d)))    (((a b) && (e f))) [1a]
	      (and-listp (first xs) and-symbol) ; ((a & b))		((a & c))	   [1b]
	      (singletonp ys) 
	      (and-listp (first ys) and-symbol))
	 (list (and-append2 (first xs) and-symbol (first ys))))
	((and (singletonp xs) 			; (((a b) && (c d)))    (a b)		   [2a]
	      (and-listp (first xs) and-symbol)) ; ((a & b))		(a)		   [2b]
	 (list (and-append2 (first xs) and-symbol (do-setify ys and-symbol))))
	((and (singletonp ys) 			; (a b)			(((a b) && (c d))) [2a]
	      (and-listp (first ys) and-symbol)) ; (a)			((a & b))	   [2b]
	 (list (and-append2 (do-setify xs and-symbol) and-symbol (first ys))))
	((set-unification-operator and-symbol)	; (a b)			(c d)		   [3a]
	 (list (list xs and-symbol ys)))
	((val-unification-operator and-symbol)	; (a)			(c)		   [3b]
	 (list (list (first xs) and-symbol (first ys))))
	(t (report-error 'user-error "Unknown case for (ands-append ~a ~a ~a)~%!" xs and-symbol ys))))

(defun do-setify (set and-symbol)
  (cond ((set-unification-operator and-symbol) (list set))
	(t set)))
				
;;; Here x and y are lists of conjoined values. Note how non-and-lists have been ()'ed
;;; (and-append2 '(a)   '& '(a & b))
;;; (and-append2 '((a)) '&& '((a) && (b)))
;;; eg. (and-(a & b),  or (a)  but not  a
(defun and-append2 (x and-symbol y)
  (cond ((null x) y)					; termination
	((and (not (singletonp x))
	      (not (and (> (length x) 2)
			(eq (second x) and-symbol))))
	 (report-error 'program-error "and-append2 given a badly formed list (not an and-list!)~%Doing (and-append2 ~a ~a ~a)~%" x and-symbol y))
	((and-member (first x) y and-symbol)
	 (and-append2 (rest (rest x)) and-symbol y))
	(t (cons (first x)
		 (cons and-symbol 
		       (and-append2 (rest (rest x)) and-symbol y))))))

; (and-listp '(a & b) '&)  -->   t
; (and-listp '((a) && (b)) '&&)  -->   t
(defun and-listp (list and-symbol) 
  (and (listp list)
       (> (length list) 2)
       (eq (second list) and-symbol)))

(defun and-member (el list and-symbol)
  (cond ((equal el (first list)))
	((singletonp list) nil)
	((and (> (length list) 2)
	      (eq (second list) and-symbol))
	 (and-member el (rest (rest list)) and-symbol))
	(t (report-error 'program-error 
			 "and-member given a badly formed list (not an and-list!)~%Doing (and-member ~a ~a ~a)~%" el list and-symbol))))

;;; ======================================================================
;;;		UNIFYING SITUATIONS
;;; ======================================================================
#|
An extra step is required besides unifying the frames themselves, namely unifying
their situational contents.
|#
;;; source and target are instances
(defun copy-situation-contents (source-sitn target-sitn)
  (cond ((eq source-sitn target-sitn))
	((not (isa source-sitn '#$Situation)))
	((not (kb-objectp target-sitn))
	 (report-error 'user-error "Can't copy ~a's contents to target situation ~a, as ~a isn't a KB object!~%"
		       source-sitn target-sitn target-sitn))
	(t (let ( (curr-situation (curr-situation))
		  (objects-to-copy (remove-if-not #'(lambda (instance) 
						      (has-situation-specific-info instance source-sitn))
						  (get-all-objects))) )
	     (in-situation target-sitn)			; Change to target...
	     (mapc #'(lambda (instance)
		       (merge-slotsvals instance source-sitn target-sitn :facet 'own-properties)
		       (merge-slotsvals instance source-sitn target-sitn :facet 'member-properties))
		   objects-to-copy)
	     (mapc #'un-done objects-to-copy)	; - now in put-slotsvals via merge-slotsvals; Later: No!
	     (mapc #'classify objects-to-copy)
	     (in-situation curr-situation)))))		; Change back...

;;; ----------

;;; (No result passed back)
;;; [1] The inverses will be installed anyway when the other frames in the situation are merged.
;;; [2] here we just merge the *structures*, which is why i1 and i2 are nil
(defun merge-slotsvals (instance source-sitn target-sitn &key classes-subsumep (facet 'own-properties))
  (let ( (source-svs (get-slotsvals instance facet source-sitn))
	 (target-svs (get-slotsvals instance facet target-sitn)) )
    (cond 
     (source-svs
      (multiple-value-bind
       (successp unified-svs)
;      (lazy-unify-slotsvals instance instance source-svs target-svs :classes-subsumep classes-subsumep)
       (lazy-unify-slotsvals nil nil source-svs target-svs 			; [2]
			     :cs1 (immediate-classes instance source-sitn)
			     :cs2 (immediate-classes instance target-sitn)
			     :classes-subsumep classes-subsumep 
			     :check-constraintsp nil)
       (cond (successp 
	      (cond ((not (equal unified-svs target-svs))
		     (put-slotsvals instance unified-svs facet nil target-sitn))))		; install-inversesp = nil [1]
	     (t (report-error 'user-error 
			      "Failed to unify ~a's slot-values of ~a in ~a~%with its slot-values ~a in ~a!~%Dropping these values...~%"
			      instance source-svs source-sitn target-svs target-sitn))))))))

;;; ======================================================================
;;;		UNIFIABLE-WITH-EXPR
;;; ======================================================================

;;; 5.3.00 remove this, replace with &? as it ignores constraints attached to class.

#|
unifiable-with-existential-expr: This is like the &? operator, except its second argument is
an expression rather than an instance. It uses the same comparison machinery 
(lazy-unify-slotsvals) as &?, except enters it a bit lower down (lazy-unify-slotsvals,
rather than try-lazy-unify), and without actually creating a temporary Skolem 
instance denoting expr.

Unifiable - eventually should merge with subsumes.
EXPR = necessarily '(a Class with slotsvals)), for now
[1] Technically, we unify in *every* situation, but of course the existential-expr is invisible in other situations so we'd just
    be unifying instance with nil for all other situations = redundant.
[2] Merging an instance with a structure, so i2 = NIL
[3] for multiple classes in expr, e.g., (a Car with (instance-of (Expensive-Thing)) (...))
[4] Optimization: (_Agent3 & (a Agent)) shouldn't test all the constraints on _Agent3's slots!
|#
(defun unifiable-with-existential-expr (instance expr &key classes-subsumep)
  (let ( (class+slotsvals (bind-self (is-existential-expr expr) instance)) )   ; [1]
    (cond (class+slotsvals				;;; 1. An INDEFINITE expression
	   (let* ( (class (first class+slotsvals))		;;;    (so do subsumption)
		   (slotsvals (second class+slotsvals)) 
		   (extra-classes (vals-in (assoc '#$instance-of slotsvals))) ) ; [3]
	     (are-slotsvals slotsvals)						; inc. look for constraints in slots 
	     (cond 
	      ((and (null slotsvals)
		    (isa instance class)) instance)	; [4]
	      ((and ;(can-be-a instance class)
		(compatible-classes :instance1 instance :classes2 (list class)
				    :classes-subsumep classes-subsumep)
		(cond ((am-in-local-situation)
			(let ( (local (remove-if-not #'(lambda (slotvals) 
							 (fluentp (slot-in slotvals))) slotsvals))
			       (global (remove-if #'(lambda (slotvals)
						      (fluentp (slot-in slotvals))) slotsvals)) 
			       (curr-situation (curr-situation)) )
			  (and (lazy-unify-slotsvals instance nil (get-slotsvals instance) local 
						     :cs2 (remove-constraints
							   (cons class extra-classes))
						     :classes-subsumep classes-subsumep)
			       (prog2
				   (change-to-situation *global-situation*)
				   (lazy-unify-slotsvals instance nil (get-slotsvals instance) global
						     :cs2 (remove-constraints
							   (cons class extra-classes))
						     :classes-subsumep classes-subsumep)
				 (change-to-situation curr-situation)))))
		      (t (lazy-unify-slotsvals instance nil (get-slotsvals instance) slotsvals 
					       :cs2 (remove-constraints
						     (cons class extra-classes))
					       :classes-subsumep classes-subsumep))))))))	; only unify in curr sitn [1], [2]
	  (t (report-error 'program-error "unifiable-with-existential-expr() in lazy-unify.lisp wasn't given an existential expr!~%   (was ~a instead)~%"
			   expr)))))

;;; This unifies instance with an existential expr *without* creating then subsequently deleting a Skolem 
;;; constant for that existential expr. It's rather a lot of code just to save extra instance creation,
;;; but useful for must-be-a constraints. 
;;; IF successful returns INSTANCE, if not returns NIL.
;;; [1] creation routine is largely copied from create-named-instance in frame-io.lisp
;;; [2] this subsumption test is new, from remove-subsuming-exprs. It avoids creating
;;;     unnecessary structures e.g. if (Pete has (owns (_Car0))) then:
;;;		(unify-with-existential-expr Pete '#$(a Person with (owns ((a Car)))))
;;;	would otherwise have resulted in (Pete has (owns (((_Car0) && ((a Car)))))).
;;; [2b]    PC  - beta48 - so why is that a problem? You just defer resolving the && until later!
;;; [3] Merging an instance with a structure, so i2 = NIL
;;; NOTE: This unification is *only* done in the local situation.
;;; [4] Optimization: (_Agent3 & (a Agent)) shouldn't test all the constraints on _Agent3's slots!
(defun unify-with-existential-expr (instance expr &key eagerlyp classes-subsumep (fail-mode 'error))
  (cond 
   ((and (fluent-instancep instance)			; special case: (_SomePerson23 & (a Person)) -> _Person35, a definite object
	 (neq (first expr) '#$some))
    (let ( (val (km-unique expr :fail-mode 'fail)) )
      (cond (eagerlyp (km `(,instance &! ,val) :fail-mode fail-mode))
	    (t (km `(,instance & ,val) :fail-mode fail-mode)))))
   ((and (not *new-approach*)
	 (km `#$(,INSTANCE is ',EXPR) :fail-mode 'fail) instance))   	; [2], [2b]
   (t (let ( (class+slotsvals (bind-self (is-existential-expr expr) instance)) )   ; [1]
	(cond (class+slotsvals				;;; 1. An INDEFINITE expression
	       (let ( (class (first class+slotsvals))		;;;    (so do subsumption)
		      (slotsvals0 (second class+slotsvals)) )
		 (are-slotsvals slotsvals0)						; inc. look for constraints in slots 
		 (cond ((and (null slotsvals0)
			     (isa instance class)) instance)	; [4]
		       ((compatible-classes :instance1 instance :classes2 (list class)
					    :classes-subsumep classes-subsumep)
			(cond 
			 ((not (kb-objectp instance)) instance) ; e.g. (1 & (a Coordinate))
			 (t (let ( (extra-classes (vals-in (assoc '#$instance-of slotsvals0))) )	; [1]
			      (or (unify-with-slotsvals2 instance (cons class extra-classes)
				     slotsvals0 :classes-subsumep classes-subsumep
				     :eagerlyp eagerlyp)
				  (cond ((eq fail-mode 'error)
					 (report-error 'user-error 
						       "Unification (~a & ~a) failed!~%" 
						       instance expr)
					 nil)))))))
		       ((eq fail-mode 'error)
			(cond (classes-subsumep
			       (report-error 'user-error "Unification (~a &+ ~a) failed! (Classes of one do not subsume classes of the other)~%" instance expr))
			      (t (report-error 'user-error "Unification (~a & ~a) failed! (Classes are incompatible)~%" instance expr)))))))
	      (t (report-error 'program-error "unify-with-existential-expr() in lazy-unify.lisp wasn't given an existential expr!~%   (was ~a instead)~%"
				  expr)))))))

(defun unify-with-slotsvals2 (instance classes slotsvals &key classes-subsumep eagerlyp)
  (cond 
   ((am-in-local-situation)
    (let* ( (local0 (remove-if-not #'(lambda (slotvals) (fluentp (slot-in slotvals))) slotsvals))
	    (global0 (remove-if #'(lambda (slotvals) (fluentp (slot-in slotvals))) slotsvals))
	    (local (cond ((fluentp '#$instance-of)
			  (update-assoc-list local0 `#$(instance-of ,CLASSES)))
			 (t local0)))
	    (global (cond ((not (fluentp '#$instance-of))
			   (update-assoc-list global0 `#$(instance-of ,CLASSES)))
			  (t global0)))
	    (curr-situation (curr-situation)) )
      (multiple-value-bind
       (successp1 unified-svs1)
       (lazy-unify-slotsvals instance nil (get-slotsvals instance) local
			     :cs2 (remove-constraints classes)
			     :classes-subsumep classes-subsumep ; [3]
			     :eagerlyp eagerlyp)
       (cond 
	(successp1
	 (change-to-situation *global-situation*)
	 (multiple-value-bind
	  (successp2 unified-svs2)
	  (lazy-unify-slotsvals instance nil (get-slotsvals instance) global
				:cs2 (remove-constraints classes)
				:classes-subsumep classes-subsumep ; [3]
				:eagerlyp eagerlyp)
	  (cond 
	   ((and successp1 successp2)
	    (cond ((not (equal unified-svs2 (get-slotsvals instance)))
		   (mapc #'(lambda (slotvals) (put-vals instance (slot-in slotvals) 
							(vals-in slotvals))) unified-svs2) ; [1]
		   (cond ((some #'(lambda (class) (is-subclass-of class '#$Situation)) classes)
			  (make-assertions instance unified-svs2)))))
	    (change-to-situation curr-situation)
	    (cond ((not (equal unified-svs1 (get-slotsvals instance)))
		   (mapc #'(lambda (slotvals) (put-vals instance (slot-in slotvals) 
							(vals-in slotvals))) unified-svs1) ; [1]
		   (cond ((some #'(lambda (class) (is-subclass-of class '#$Situation)) classes)
			  (make-assertions instance unified-svs1)))))
	    (un-done instance)
	    (classify instance)
	    instance))))))))
   (t (multiple-value-bind
       (successp unified-svs)
       (lazy-unify-slotsvals instance nil (get-slotsvals instance) 
			     (update-assoc-list slotsvals `#$(instance-of ,CLASSES))
			     :cs2 (remove-constraints classes)
			     :classes-subsumep classes-subsumep ; [3]
			     :eagerlyp eagerlyp)
       (cond (successp 
	      (cond ((not (equal unified-svs (get-slotsvals instance)))
		     (mapc #'(lambda (slotvals) 
			       (put-vals instance (slot-in slotvals) (vals-in slotvals))) 
			   unified-svs)	; [1]
		     (cond ((some #'(lambda (class) (is-subclass-of class '#$Situation)) classes)
			    (make-assertions instance unified-svs)))
		     (un-done instance)
		     (classify instance)))
	      instance))))))

;;; FILE:  constraints.lisp

;;; File: constraints.lisp
;;; Author: Peter Clark
;;; Date: 1999
;;; Purpose: Constraint checking/enforcement mechanism for KM

;;; ======================================================================
;;;		  CONSTRAINT CHECKING / ENFORCEMENT
;;; ======================================================================

;;; This will *REMOVE VIOLATORS* (but not necessarily fail) if a constraint is violated.
;;; It should be used as a filter, not as a test. For a test, use are-consistent-with-constraints
;;; instead.
;;; This has no side-effects. Returns a reduced list of values
;;; THIS ASSUME VALS IS A LIST OF ATOMS, IE. ANY KM EVALUATION HAS ALREADY BEEN PERFORMED.
(defun filter-using-constraints (vals constraints)
  (cond ((null constraints) vals)
	((and (tracep) (not (traceconstraintsp))) 
	 (prog2 
	     (suspend-trace) 
	     (filter-using-constraints0 vals constraints) 
	   (unsuspend-trace)))
	(t (km-trace 'comment "Testing constraints ~a" constraints)
	   (filter-using-constraints0 vals constraints))))

(defun filter-using-constraints0 (vals constraints)
  (remove-if-not #'(lambda (val) (is-consistent-with-val-constraints val constraints)) vals))

;;; ----------------------------------------

;;; Returns T/NIL. Here, we have vals and constraints mixed, and in principle could check
;;; constraints are mutually consistent also.
(defun is-consistent (vals+constraints0)
  (cond ((null vals+constraints0) t)
	(t (let ( (vals+constraints (remove-dup-instances vals+constraints0)) )
	     (and (every #'(lambda (constraint)
			     (or (not (set-constraint-exprp constraint))
				 (is-consistent-with-set-constraint vals+constraints constraint)))
			 vals+constraints)
		  (every #'(lambda (val) (is-consistent-with-val-constraints val vals+constraints)) vals+constraints))))))

;;; ----------------------------------------

;;; This will *FAIL* if a constraint is violated  
;;; Returns T/NIL.
(defun test-constraints (vals0 constraints)
  (cond ((or (null constraints) (null vals0)) t)
	(t (let ( (vals (remove-dup-instances vals0)) )		; does dereferencing etc.
	     (and (every #'(lambda (constraint)
			     (or (not (set-constraint-exprp constraint))
				 (is-consistent-with-set-constraint vals constraint)))
			 constraints)
		  (every #'(lambda (val) (is-consistent-with-val-constraints val constraints)) vals))))))

(defun is-consistent-with-val-constraints (val constraints)
  (and val 
       (every #'(lambda (constraint) 
		  (or (not (val-constraint-exprp constraint))
		      (is-consistent-with-val-constraint val constraint)))
	      constraints)))

;;; [1] ignore for now - could look for mutually inconsistent constraints later
(defun is-consistent-with-val-constraint (val constraint)
  (cond ((constraint-exprp val))	; [1]
	(t (case (first constraint)
;		 (#$must-be-a (unifiable-with-expr val `#$(a ,@(REST CONSTRAINT))))		; not complete enough, and may loop!!
		 (#$must-be-a (km `#$(,VAL &? (a ,@(REST CONSTRAINT))) :fail-mode 'fail))
		 (#$mustnt-be-a (km `#$(not (,VAL is '(a ,@(REST CONSTRAINT)))) :fail-mode 'fail))
		 (<> (cond ((is-km-term (second constraint))
			    (neq val (second constraint)))
			   (t (km `#$(,VAL /= ,(SECOND CONSTRAINT)) :fail-mode 'fail))))
		 (#$constraint (km (subst val '#$TheValue (second constraint)) :fail-mode 'fail))
		 (t (report-error 'user-error "Unrecognized form of constraint ~a~%" constraint))))))

;;; [1] this computation is seemingly (but insignificantly) inefficient here, and could be moved earlier.
;;; But: it is a place-holder, where we might later want to check for mutually inconsistent constraints later.
(defun is-consistent-with-set-constraint (vals0 constraint)
  (let ( (vals (remove-if #'constraint-exprp vals0)) )	; [1]
    (case (first constraint)
	  (#$at-least t)				; can always add in instances
	  (#$exactly (is-consistent-with-set-constraint vals (cons '#$at-most (rest constraint))))  ; rewrite
	  (#$at-most (let ( (n (second constraint))
			    (class (third constraint)) )
		       (<= (length (remove-if-not #'(lambda (val) (isa val class)) vals))
			   n)))
	  (#$set-constraint (cond ((km (subst (vals-to-val vals) '#$TheValues (second constraint)) :fail-mode 'fail))
				  (t (report-error 'user-error
						   "set-constraint violation!~%~a failed test ~a. Continuing anyway...~%" 
						   vals (second constraint))
				     t))))))

;;; ------------------------------

;;; Returns revised vals, after constraints have been enforced
;;; This one will do coersion, as well as testing.
;;; This assume vals is a list of atoms, ie. any km evaluation has already been performed.

(defun enforce-constraints (vals constraints)
  (cond ((and (tracep) (not (traceconstraintsp)))
	 (prog2 (suspend-trace) (enforce-constraints0 vals constraints) (unsuspend-trace)))
	(t (km-trace 'comment "Enforcing constraints ~a" constraints)
	   (enforce-constraints0 vals constraints))))

;;; ******* NOTE!! **********
;;; 9/7/99: Disable the set-valued constraints! It's causing too many problems! See constraints.README
;;; We now reduce it to test-constraints for set-valued constraints.
;;; 9/17/99: Put it back again, then hurriedly take it out again (see enforcement-problem.km)
(defun enforce-constraints0 (vals constraints)
; ENFORCEMENT VERSION
  (enforce-set-constraints
   (remove-if-not #'(lambda (val) (enforce-val-constraints val constraints)) vals)		; revised vals
   constraints))
; TESTING ONLY VERSION
; (let ( (newvals (remove-if-not #'(lambda (val) (enforce-val-constraints val constraints)) vals)) )
;   (mapc #'(lambda (constraint)				; test but don't enforce set constraints, for now
;	     (cond ((not (set-constraint-exprp constraint)))
;		   ((is-consistent-with-set-constraint newvals constraint))
;		   (t (report-error 'user-error "Constraint violation! Values ~a conflict with constraint ~a!~%"
;				    newvals constraint))))
;	 constraints)
;   newvals))
  
(defun enforce-val-constraints (val constraints)
  (and val (every #'(lambda (constraint) 
		      (or (not (val-constraint-exprp constraint))
			  (enforce-val-constraint val constraint)
			  (report-error 'user-error "Constraint violation! Discarding value ~a (conflicts with ~a)~%"
					val constraint)))
		  constraints)))

;;; 5.3.00 add :fail-mode 'fail to report error later
(defun enforce-val-constraint (val constraint)
  (case (first constraint)
    (#$must-be-a (km `#$(,VAL & (a ,@(REST CONSTRAINT))) :fail-mode 'fail))
    (#$mustnt-be-a (km `#$(not (,VAL is '(a ,@(REST CONSTRAINT)))) :fail-mode 'fail))
    (<> (cond ((is-km-term (second constraint))
	       (neq val (second constraint)))
	      (t (km `#$(,VAL /= ,(SECOND CONSTRAINT)) :fail-mode 'fail))))
    (#$constraint (km (subst val '#$TheValue (second constraint)) :fail-mode 'fail))
    (t (report-error 'user-error "Unrecognized form of constraint ~a~%" constraint))))

(defun enforce-set-constraints (vals constraints)
  (cond ((endp constraints) vals)
	((val-constraint-exprp (first constraints))		; skip these
	 (enforce-set-constraints vals (rest constraints)))
	(t (enforce-set-constraints (enforce-set-constraint vals (first constraints))
				    (rest constraints)))))

;;; Just do this reduced version
(defun enforce-set-constraint (vals constraint)
  (let ( (forced-class (first (or (minimatch constraint '#$(at-most 1 ?class)) 	
				  (minimatch constraint '#$(exactly 1 ?class))))) ) 	
    (cond (forced-class
	   (let ( (vals-in-class (remove-if-not #'(lambda (val) (isa val forced-class)) vals)) )
	     (cond ((> (length vals-in-class) 1)
		    (make-comment (km-format nil "Unifying values ~a (forced by constraint (at-most 1 ~a)"
					     vals-in-class forced-class))
		    (cons (km-unique (vals-to-&-expr vals-in-class))
			  (set-difference vals vals-in-class)))
		   (t vals))))
	  (t vals))))


#|
PROBLEMS! see test-suite/outstanding/enforcement-problem.km
(defun enforce-set-constraint (vals constraint)
  (let* ( (n (second constraint))
	  (class (third constraint))
	  (count (length (remove-if-not #'(lambda (val) (isa val class)) vals))) )
    (case (first constraint)
	  (#$at-least (cond ((>= count n) vals)
			    (t (prog1 
				   (append vals (loop repeat (- n count) collect (km-unique `#$(a ,CLASS)))) ; classes missing so create them!!
				 (km-format t "CREATED a ~a!~%" class)))))
	  (#$exactly (cond ((= count n) vals)
			   ((> count n) 
			    (report-error 'user-error
	                       "set-constraint violation! Found ~a ~a(s), but should be~%exactly ~a! Values were: ~a. Ignoring extras...~%" 
			       count class n vals)
			    (remove-if #'(lambda (val) (isa val class)) vals :from-end t :count (- count n)))
			   ((< count n)
			    (prog1 
				(append vals (loop repeat (- n count) collect (km-unique `#$(a ,CLASS)))) ; classes missing so create them!!
			      (make-comment (km-format nil "CREATED a ~a!~%" class))))))
	  (#$at-most (cond ((<= count n) vals)
			   (t (report-error 'user-error 
					    "set-constraint violation! Found ~a ~a(s), but should be~%at-most ~a! Values were: ~a. Ignoring extras...~%"
					    count class n vals)
			      (remove-if #'(lambda (val) (isa val class)) vals :from-end t :count (- count n)))))
	  (#$set-constraint (cond ((km (subst (vals-to-val vals) '#$TheValues (second constraint)) :fail-mode 'fail) vals)
				  (t (report-error 'user-error "set-constraint violation!~%~a failed test ~a. Continuing anyway...~%" 
						   vals (second constraint))
				     vals))))))
|#

;;; FILE:  kbutils.lisp

;;; File: kbutils.lisp
;;; Author: Peter Clark
;;; Date: Separated out Mar 1995
;;; Purpose: Basic utilities for KM

;;; ======================================================================
;;; 		RECOGNITION OF INSTANCES
;;; ======================================================================

; no longer used
; (defun tag-slotp (slot) (eq slot *tag-slot*))

(defun slotp (slot) 
  (and (symbolp slot) 
       (member slot (get-vals '#$slot '#$instances *global-situation*))))
;       (isa slot '#$Slot)))	; too slow, and recursive [see NOTE at end]
       

;;; Check is' a valid slot
(defun slot-objectp (slot) (symbolp slot))

;;; Rather crude approximation of a test...
(defun pathp (path) (listp path))

;;; Anything which is considered to be fully evaluated in KM. 
;;; 345, "a", pete, #'print, '(every Dog), (:triple Sue loves John), (<> 23)
(defun is-km-term (concept)
  (or (atom concept)		; includes: 1 'a "12" nil
      (descriptionp concept)
      (km-structured-list-valp concept)
      (functionp concept)
      (constraint-exprp concept)))

(defun is-simple-km-term (concept)
  (or (and (atom concept)		; includes: 1 'a "12" nil
	   (not (member concept *reserved-keywords*)))
      (descriptionp concept)
      (functionp concept)))

;; Proves that it's *definitely* a class; however, some other objects may also
;; be classes too (eg. if they haven't been declared).
;; 1999: I've arranged these tests for speed
(defun classp (class)
  (or (member class *built-in-classes*)
      (and (kb-objectp class)
	   (or (find-vals class '#$superclasses)
	       (and (not (find-vals class '#$instance-of))		; fast check for being an instance!
		    (or (find-vals class '#$instances)
			(find-vals class 'member-properties)
			(find-vals class 'member-definition)
			(find-vals class '#$subclasses)))))))


;;; Proves (just about) it's definitely an instance, though there may
;;; be other instances which fail this test.
(defun is-an-instance (instance)
  (or (anonymous-instancep instance)
      (numberp instance)
      (stringp instance)
      (functionp instance)
      (descriptionp instance)
      (km-structured-list-valp instance)
      (and (is-km-term instance)
	   (or (find-vals instance '#$instance-of 'own-properties)
	       (find-vals instance '#$instance-of 'own-definition)))))

;; Time consuming!
;	   (not (classp instance)))))   ; just in case #$instance-of is a class-metaclass relation

;;; _car12
(defun anonymous-instancep (instance0)
  (let ( (instance (dereference instance0)) )
    (and (symbolp instance)
	 (char= (first-char (symbol-name instance)) *var-marker-char*))))

;;; 345, "a", pete, #'print
(defun named-instancep (instance) (not (anonymous-instancep instance)))

(defun fluent-instancep (instance)
  (and (symbolp instance)
       (starts-with (symbol-name instance) *fluent-instance-marker-string*)))

(defun remove-fluent-instances (instances) (remove-if #'fluent-instancep instances))

;;; pete, _car12
;;; Objects which will have frames in the KB about them
(defun kb-objectp (instance) 
  (and (symbolp instance) 
      (not (member instance '#$(nil NIL :seq :args :triple)))))	; later: allow stuff on 't'!

;;; A *structured value* is a CONTAINER of values, collected together. It *doesn't*
;;; include quoted expressions.
;;; NOTE a SET isn't a structured value, it's a set of values!!
(defun km-structured-list-valp (val)
  (and (listp val) (member (first val) '#$(:seq :args :triple))))

(defun km-triplep (triple) 
  (and (listp triple) (= (length triple) 4) (eq (first triple) #$:triple)))

;;; recognize sequences eg. (:seq a b c)
(defun km-seqp (seq)
  (and (listp seq) (eq (first seq) '#$:seq)))

;;; recognize a single expression as a set eg. (:set a b c)
(defun km-setp (set)
  (and (listp set) (eq (first set) '#$:set)))

(defun km-argsp (args)
  (and (listp args) (eq (first args) '#$:args)))

;;; Accessing (:args ...) structures:
(defun arg1of (arg-structure) (second arg-structure))		; (:args a b) -> a
(defun arg2of (arg-structure) (third arg-structure))		; (:args a b) -> b
(defun arg3of (arg-structure) (fourth arg-structure))		; (:args a b) -> b

(defun remove-dup-instances (instances)
  (remove-duplicates (dereference instances) :test #'kb-instance-equal :from-end t))

;;; This is twice as fast, but won't remove duplicate structures, e.g., (:triple ...) 
;;; It relies on the fact that (dereference ...) will create a copy of instances, which is necessarily a list
(defun remove-dup-atomic-instances (instances)
 (delete-duplicates (dereference instances) :from-end t))

;;; "equal" isn't quite what we want, as we *don't* remove duplicate numeric entries. Is this a bad idea??
;;; I suspect in other places in the code, duplicate numbers are removed as I've used equal not kb-instance-equal (eg. during lazy unify).
(defun kb-instance-equal (i1 i2)
  (and (equal i1 i2) (not (numberp i1))))

; Old def -- definition??
;(defun kb-instance-equal (i1 i2)
;  (and (equal i1 i2) 
;       (or (symbolp i1)		; (kb-objectp i1)	ERROR! should remove dups for non-kb-objects t f!
;	   (km-structured-list-valp i1))))

;;; Only expressions of the form (a ... [with ...]) return a situation-invariant answer.
;;; This is used to block passing these *expressions* between situations, to avoid redundant computation 
;;;     of identities. The result of their evaluation *will* be passed between situations, still, of course.
(defun situation-invariant-exprp (expr)
  (and (listp expr) (eq (first expr) '#$a)))

(defun constraint-exprp (expr)
  (or (val-constraint-exprp expr)
      (set-constraint-exprp expr)))

(defun val-constraint-exprp (expr)
  (and (listp expr) 
       (member (first expr) *val-constraint-keywords*)))

(defun set-constraint-exprp (expr)
  (and (listp expr) 
       (member (first expr) *set-constraint-keywords*)))

;;; Returns non-nil if expr contains (at least) one of symbols.
(defun contains-some-existential-exprs (exprs)
  (contains-some exprs '#$(a an)))

;;; ======================================================================

(defun val-to-vals (val)
  (cond ((null val) nil)
	((eq val '#$nil) nil)
	((and (listp val)
	      (eq (first val) '#$:set))
	 (rest val))
	(t (list val))))  ; val must be an atom (eg. _Car23) or a single expression, eg. (a Car) 
			  ; so we simply wrap it in a list (_Car23), or ((a Car))

(defun vals-to-val (vals)
  (cond ((singletonp vals) (first vals))
	((null vals) nil)
	((listp vals) (cons '#$:set vals))
	(t (report-error 'user-error "Expecting a set of values, but just found a single value ~a!~%" vals))))

;;; ======================================================================
;;; 		val-sets-to-expr
;;; ======================================================================
;;;     GIVEN a LIST of SETS of VALS (ie. some val-sets)
;;;     RETURNS a *SINGLE* expression which KM can evaluate, denoting the combination.
;;; single-valuedp = *:   (val-sets-to-expr '((a)) ) -> a
;;; single-valuedp = *:   (val-sets-to-expr '((a b)) ) -> (:set a b)
;;; single-valuedp = T:   (val-sets-to-expr '((a) (b) (c)) 't)  -> (a & b & c)
;;; single-valuedp = T:   (val-sets-to-expr '((a b) (c)) 't) -> ERROR! and (a & c)
;;; single-valuedp = NIL: (val-sets-to-expr '((a b) (b) (c d))) -> ((a b) && (b) && (c d))
(defun val-sets-to-expr (exprs0 &optional single-valuedp)
  (let ( (exprs (remove-duplicates (remove nil exprs0) :test #'equal :from-end t)) )
    (cond ((null exprs) nil)
	  ((singletonp exprs) (vals-to-val (first exprs)))
	  (t (val-sets-to-expr0 exprs single-valuedp)))))

(defun val-sets-to-expr0 (exprs &optional single-valuedp)
  (cond 
   ((endp exprs) nil)
   ((null (first exprs)) (val-sets-to-expr0 (rest exprs) single-valuedp))
   ((not (listp (first exprs)))
    (report-error 'user-error "val-sets-to-expr0: Single value ~a found where list of values expected! Listifying it...~%" (first exprs))
    (val-sets-to-expr0 (cons (list (first exprs)) (rest exprs))))
   (t (let ( (first-item (cond (single-valuedp 
				(cond ((not (singletonp (first exprs)))		; error! (a b) found 
				       (report-error 'user-error 
						     "Multiple values ~a found for single-valued slot!~%Assuming they should be unified...~%"
						     (first exprs))
				       (vals-to-&-expr (first exprs)))		; (a b) -> (a & b)	(single-valued slot)
				      (t (first (first exprs)))))		; (a)   -> a		(single-valued slot)
			       (t (first exprs))))				; (a b c) -> (a b c)	(multivalued slot)
	     (linked-rest (val-sets-to-expr0 (rest exprs) single-valuedp))
	     (joiner (cond (single-valuedp '&) (t '&&))) )
	(cond ((null linked-rest) (list first-item))
	      (t (cons first-item (cons joiner linked-rest))))))))

;;; ======================================================================
;;;		FLATTENING '&' AND '&&' EXPRESSIONS
;;; ======================================================================

;;; vals should be either nil, or a SINGLETON list of one KM expression eg. (a), ((a & b)).
;;; RETURNS the component values as a list, eg. (a), (a b)
(defun un-andify (vals)
  (cond ((null vals) nil)
	((singletonp vals) (&-expr-to-vals (first vals)))
	(t (report-error 'nodebugger-error "Multiple values ~a found for single-valued slot!~%Assuming they should be unified...~%" vals)
	   (my-mapcan #'&-expr-to-vals vals))))

;;; (&-expr-to-vals '(x & y & z)) -> (x y z)
;;; (&-expr-to-vals '((a Car) & (a Dog))) -> ((a Car) (a Dog)))
;;; (&-expr-to-vals '(a Car)) -> ((a Car))	<- NB listify
;;; (&-expr-to-vals 'x) -> (x)			<- NB listify
;;; (&-expr-to-vals '((a & (b & d)) & (e & (f & g)))) -> (a b c d e f g)    <- NB nested 
;;; (&-expr-to-vals '(x & y z))			<- ERROR!
(defun &-expr-to-vals (expr)
  (cond ((null expr) nil)
	((and (listp expr) (eq (second expr) '&))
	 (cond ((eq (fourth expr) '&)				; (x & y & ...)
		(&-expr-to-vals `(,(first expr) & ,(rest (rest expr)))))
	       (t (cond ((neq (length expr) 3)
			 (report-error 'user-error "Illegally formed expression ~a encountered!~%Continuing with just ~a...~%" 
				       expr (subseq expr 0 3))))
		  (append (&-expr-to-vals (first expr)) (&-expr-to-vals (third expr))))))
	(t (list expr))))

;;; nil -> nil, (a) -> a, (a b c) -> (a & b & c)
(defun vals-to-&-expr (vals &key (joiner '&) (first-time-through t))
  (cond ((null vals) nil)
	((singletonp vals) 
	 (cond (first-time-through (first vals)) 
	       (t vals)))
	(t `(,(first vals) ,joiner ,@(vals-to-&-expr (rest vals) :joiner joiner :first-time-through nil)))))

;;; ----------------------------------------
;;;	Digging out the constraints...
;;; ----------------------------------------

#|
Call with a SINGLE EXPRESSION. It will further call itself with either with
          (a) a single value, with :joiner = &
   or     (b) a list of values, with :joiner = &&
RETURNS the constraints embedded in the expression.

Shown below, where numbers denote things passing constraint-exprp test. 
A test procedure is in find-constraints.lisp, a multivalued version of the below.

	EXPRESSION				==>	CONSTRAINTS
	(a & 1 & 2)					(1 2)
	(a & 1 & 2 & (3 & d))				(1 2 3)
	(a & 1 & 2 & (3 & (d & 4)))			(1 2 3 4)
	((a 1) && (b 2))				(1 2)
	((a 1 b) && (c 2 d))				(1 2)
	((a 1 b) && (c 2 d) && (e f))			(1 2)
	((a 1 b) && (((c 2 d) && (e f))))		(1 2)
	((a 1 b) && (((c 2 d) && (e f 3))))		(1 2 3)
	((a 1 b) && (((c 2 d) && (e f 3) && (4))))	(1 2 3 4)
	a						nil
	((((a 1) && (b 2)) d e) && (c 3))		(3)
	((((a 1) && (b 2)) d 4) && (c 3))		(4 3)
	((((a 1) && (b 2))) && (c 3))			(1 2 3)
|#

(defun find-constraints-in-exprs (exprs) (find-constraints exprs 'plural))

;;; *MAPCAN-SAFE*
;;; a, (a & b) (as && bs)   plurality = singular.
;;; (a) 		    plurality = plural (1 member).
;;; (a b) 		    plurality = plural (2 members).
;;; ((a b)) 		    plurality = plural (1 member).
;;; Note: (must-be-a Car)   plurality = singular   is a constraint,
;;;   but (must-be-a Car)   plurality = plural    isn't a constraint, it's two values "must-be-a" and "Car".
;;; Result is newly created list, so it is safe to mapcan over it.
(defun find-constraints (expr &optional (plurality 'singular))	; ie. a single expr given
  (cond ((null expr) nil)
	((and (listp expr)
;	      (member (second expr) '(& &&)))
	      (unification-operator (second expr)))
	 (cond ((>= (length expr) 4)
		(cond ((not ; (member (fourth expr) '(& &&)))
			    (unification-operator (fourth expr)))
		       (report-error 'user-error "Badly formed unification expression ~a!~%" expr)))
		(find-constraints `(,(first expr) ,(second expr) ,(rest (rest expr))) 'singular))    ; (a & b & c) -> (a & (b & c))

	       (t (let ( (next-plurality (cond (; (eq (second expr) '&) 'singular)   ; & takes a value as arg, && takes a list of values
						(val-unification-operator (second expr)) 'singular)
					       (t 'plural))) )
		    (append (find-constraints (first expr) next-plurality)
			    (find-constraints (third expr) next-plurality))))))
	((and (eq plurality 'singular)		; & -> a single value/expr is given
	      (constraint-exprp expr))
	 (list expr))
	((and (eq plurality 'plural)		; special case - allowed to recurse if only one member
	      (singletonp expr))
	 (find-constraints (first expr) 'singular))
	((and (eq plurality 'plural)			; && -> a list of values is given
	      (listp expr))
	 (remove-if-not #'constraint-exprp expr))))

;;; ----------

;;; This is to remove constraints from a POST-EVALUATED expression ONLY. A post-evaluated expression is
;;;   single-valued slots: either a single value, or a single value &'ed with constraints
;;;			   eg. (1) -> (1), ((a & (must-be x))) -> (a)
;;;   multivalued slots:   a list of values + constraints eg. (1 2 (must-be y)) -> (1 2)
;;; RETURNS: A list of values
;;; (remove-constraints '#$((a & (must-be-a c)))) -> '#$(a)
;;; (remove-constraints '#$(a b (must-be-a c))) -> '#$(a b)
(defun remove-constraints (vals)
  (cond ((null vals) nil)
	((and (singletonp vals)
	      (listp (first vals)) 
;	      (eq (second (first vals)) '&))					; single-valued-slot format ((a & (must-be b)))
	      (val-unification-operator (second (first vals))))
	 (remove-if #'constraint-exprp (&-expr-to-vals (first vals))))
	(t (remove-if #'constraint-exprp vals))))

;;; ======================================================================
;;;		RECOGNIZING DESCRIPTIONS
;;; ======================================================================

(defun descriptionp (expr) (quotep expr))
    
;;; '(a Cat) -> t	   
(defun instance-descriptionp (expr &key (fail-mode 'error))
  (cond 
   ((descriptionp expr)
    (cond 
     ((is-existential-expr (unquote expr)))
     ((km-triplep (unquote expr)))		; <--- Bit of a fudge here: subsumes also handles triples as if they were descriptions
     ((eq fail-mode 'error)
      (cond 
       ((eq (first (unquote expr)) '#$every)	; '(every Cat) -> ERROR
	(report-error 'user-error "Expecting an instance description '(a ...), but found a class~%description ~a instead!~%" expr))
       (t (report-error 'user-error "Expecting an instance description '(a ...), but found~%description ~a instead!~%" expr))))))
   ((eq fail-mode 'error)
    (report-error 'user-error "Expecting a quoted instance description '(a ...), but found an unquoted~%expression ~a instead!~%" expr))))

(defun class-descriptionp (expr &key (fail-mode 'error))
  (cond 
   ((descriptionp expr) 
    (cond
     ((minimatch expr ''#$(every ?class)))
     ((minimatch expr ''#$(every ?class with &REST)))
     ((eq fail-mode 'error)
      (cond 
       ((eq (first (unquote expr)) '#$a)	; '(every Cat) -> ERROR
	(report-error 'user-error "Expecting a class description '(every ...), but found an instance~%description ~a instead!~%" expr))
       (t (report-error 'user-error "Expecting a class description '(every ...), but found~%description ~a instead!~%" expr))))))
   ((eq fail-mode 'error)
    (report-error 'user-error "Expecting a quoted class description '(every ...), but found an unquoted~%expression ~a instead!~%" expr))))


#|
Note: slotp using isa causes recursion:

edit      ed   edit the source for the current stack frame
EOF            either :pop or :exit
error     err  print the last error message
evalmode  eval examine or set evaluation mode
exit      ex   exit and return to the shell
find      fin  find the stack frame calling the function `func'
focus     fo   focus the top level on a process
frame     fr   print info about current frame
[type return for next page or an integer to set the page length] 
function  fun  print and set * to the function object of this frame
help      he   print this text -- use `:help cmd-name' for more info
hide      hid  hide functions or types of stack frames
history   his  print the most recently typed user inputs
inspect   i    inspect a lisp object
kill      ki   kill a process
ld             load one or more files
ldb            Turn on/off low-level debugging
local     loc  print the value of a local (interpreted or compiled) variable
macroexpand ma call macroexpand on the argument, and pretty print it
optimize  opt  interactively set compiler optimizations
package   pa   go into a package
pop            pop up `n' (default 1) break levels
popd           cd into the previous entry on directory stack
printer-variables pri Interactively set printer control variables
processes pro  List all processes
prt            pop-and-retry the last expression which caused an error
pushd     pu   cd to a directory, pushing the directory on to the stack
pwd       pw   print the process current working directory
reset     res  return to the top-most break level
restart   rest restart the function in the current frame
return    ret  return values from the current frame
[type return for next page or an integer to set the page length] 
scont     sc   step `n' forms before stopping
set-local set-l  set the value of a local variable
sover     so   eval the current step form, with stepping turned off
step      st   turn on or off stepping
top       to   Zoom at the newest frame on the stack.
trace     tr   trace the function arguments
unarrest  unar revoke the debugging arrest reason on a process
unhide    unh  unhide functions or types of stack frames
untrace   untr stop tracing some or all functions
up             move up `n' (default 1) stack frames
who-binds who-b find bindings of a variable
who-calls who-c find callers of a function
who-references who-r find references to a variable
who-sets  who-s find setters of a variable
who-uses  who-u find references, bindings and settings of a variable
zoom      zo   print the runtime stack
[1c] USER(11): :zo 30
Error: &key list isn't even.
  [condition type: program-error]

Restart actions (select using :continue):
 0: continue computation
 1: Return to Top Level (an "abort" restart)
[2] USER(12): :pop
Previous error: Stack overflow (signal 1000)
If continued, continue computation
[1c] USER(12): :zo :depth 30
Error: Illegal keyword given: :depth.
  [condition type: program-error]

Restart actions (select using :continue):
 0: continue computation
 1: Return to Top Level (an "abort" restart)
[2] USER(13): :pop
Previous error: Stack overflow (signal 1000)
If continued, continue computation
[1c] USER(13): :zo :count 50
Evaluation stack:

... 10 more (possibly invisible) newer frames ...

   ((:internal immediate-classes0 0) |*Global|)
   (mapcar #<Closure # @ #x85709ba> (|*Global|))
   (my-mapcan #<Closure # @ #x85709ba> (|*Global|))
   (immediate-classes0 |Box| |_Situation1|)
   (immediate-classes |Box|)
   (instance-of |Box| |Slot|)
   (isa |Box| |Slot|)
   (slotp |Box|)
   (stackable |Box|)
   (add-to-stack |Box|)
   (put-vals |Box| |instance-of| ...)
   (immediate-classes0 |Box| |_Situation1|)
   (immediate-classes |Box|)
   (instance-of |Box| |Slot|)
   (isa |Box| |Slot|)
   (slotp |Box|)
   (stackable |Box|)
   (add-to-stack |Box|)
   (put-vals |Box| |instance-of| ...)
   (immediate-classes0 |Box| |_Situation1|)
   (immediate-classes |Box|)
   (instance-of |Box| |Slot|)
   (isa |Box| |Slot|)
   (slotp |Box|)
   (stackable |Box|)
 ->(add-to-stack |Box|)
   (put-vals |Box| |instance-of| ...)
   (immediate-classes0 |Box| |_Situation1|)
   (immediate-classes |Box|)
   (instance-of |Box| |Slot|)
   (isa |Box| |Slot|)
   (slotp |Box|)
   (stackable |Box|)
|#


;;; FILE:  stack.lisp

;;; File: stack.lisp
;;; Author: Peter Clark
;;; Date: 1994
;;; Purpose: Maintenance of the stack

(defvar *obj-stack* ())
(defvar *km-stack* ())

;;; ----------

;;; synonym
(defun new-context () (clear-obj-stack))

(defun clear-km-stack () (setq *km-stack* nil))
(defun clear-obj-stack () (make-transaction '(setq *obj-stack* nil)))
(defun km-stack () *km-stack*)

(defun km-push (expr) 
  (setq *km-stack* (cons (item-to-stack expr) *km-stack*)))

(defun km-pop ()
  (prog1
      (first *km-stack*)
    (setq *km-stack* (rest *km-stack*))))

;;; ======================================================================
;;; 		THE EXPRESSION STACK
;;; ======================================================================

#| 
Looping problem with disjuncts!!! I failed to fix this
  Suppose we ask X, and X <- Y or Z, and Y <- X.
  KM will give up on Y, even if Z can compute it. This is a problem, because then
  Y might be projected from the previous situation!

The problem is that KM's triggers too easily. If, when calculating X, I hit a 
non-deterministic choice-point and take branch 1 of 2 (say), then hit a call to 
calculate X again, KM *should* continue, but this time take branch 2 of 2 at the 
same choice-point. Instead, KM just gives up. A fix would be to (i) identify 
non-deterministic choice-points (ii) mark them in the stack and (iii) steer as above.

We can do this with a REVISED LOOPING CHECK:
IF  the current call C' matches an earlier call C
THEN abort
UNLESS there is an "or" clause between C and C'.

#$or clauses: Select an option which ISN'T in the current stack (see interpreter.lisp).
|#

(defun looping-on (expr) (on-km-stackp expr))			; old version

#|
(defun looping-on (expr) 					; new, more sophisticated version
  (and (on-km-stackp expr)
       (not (intermediate-or-clause *km-stack* (item-to-stack expr)))))

(defun intermediate-or-clause (stack expr)
  (cond ((equal (first stack) expr) nil)
	((minimatch (first stack) '((?x #$or &rest) ?situation)))
	(t (intermediate-or-clause (rest stack) expr))))
|#

(defun on-km-stackp (expr)
  (member (item-to-stack expr) *km-stack* :test #'stack-equal))		; more efficient

(defun stack-equal (item1 item2)
  (and (equal (first item1) (first item2))		; match canonicalized expressions
       (eq (second item1) (second item2))))		; match situation

#|
Here we canonicalize the item for stacking.
Must add a note of the current situation.
|#
(defun item-to-stack (expr) (list (canonicalize expr) (curr-situation) expr))

;;; [2] Must canonicalize the two forms of paths:
;;;	(_Car23 parts) -> stack as (the parts of _Car23)
(defun canonicalize (expr)
  (cond ((and (pairp expr)
	      (not (member (first expr) *reserved-keywords*)))
	 (list `#$(the ,(SECOND EXPR) of ,(FIRST EXPR))))
	((and (triplep expr)
	      (set-unification-operator (second expr)))			; fold &, &?, &!, &&, &&?, &&! into a single canonical form
	 (list (first expr) 'unified-with (third expr)))
	((and (triplep expr)						; fold &, &?, &!, &&, &&?, &&! into a single canonical form
	      (val-unification-operator (second expr))
	      (neq (second expr) '&+))					; EXCEPT: This *is* a valid subgoal of &&
	 (list (list (first expr)) 'unified-with (list (third expr))))
	(t expr)))

;;; (a && b) (a & b) 

;;; ----------------------------------------
;;;	DISPLAY OF EXPRESSION STACK
;;; ----------------------------------------

#|
  <- (_Chassis70)             "(the body-parts of *MyCar)"
  (3) Look in supersituation(s)
  -> (in-situation *Global (the parts of *MyCar))g
----------------------------------------

 CURRENT GOAL STACK IS AS FOLLOWS:
 -> (the parts of *MyCar)                              [called in _Situation69]
  -> (in-situation *Global (the parts of *MyCar))      [called in _Situation69]

|#

(defun show-km-stack (&optional (stream t))
  (let ( (show-situationsp (some #'(lambda (item) (neq (second item) *global-situation*)) (km-stack))) )
    (format stream "--------------------~%~%")
    (format stream " CURRENT GOAL STACK IS AS FOLLOWS:~%")
    (show-km-stack2 (reverse (km-stack)) 1 show-situationsp stream)
    (format stream "~%--------------------~%")))

(defun show-km-stack2 (stack depth show-situationsp &optional (stream t))
  (cond ((endp stack) nil)
	(t (let* ( (item (first stack))
		   (expr (third item))
		   (situation (second item)) )
	     (km-format stream "~vT-> ~a" depth expr)
	     (cond (show-situationsp (km-format stream "~vT[called in ~a]~%" 55 situation))
		   (t (format stream "~%")))
	     (show-km-stack2 (rest stack) (1+ depth) show-situationsp stream)))))

;;; ======================================================================
;;;		THE OBJECT STACK
;;; ======================================================================

;;; Note we filter out duplicates and classes at access time (obj-stack), rather than 
;;; build-time (here), for efficiency.
(defun add-to-stack (instance)
   (cond ((and (not (member instance *obj-stack*))
	       (stackable instance))
	  (make-transaction `(setq *obj-stack* ,(cons instance *obj-stack*))))))

(defconstant *unstackable-kb-instances* '#$(t))

(defun stackable (instance)
  (and (kb-objectp instance)
       (not (classp instance))
       (not (slotp instance))
       (not (member instance *unstackable-kb-instances*))))

(defun remove-from-stack (instance)
  (make-transaction `(setq *obj-stack* ,(remove instance (obj-stack)))))

;;; ----------------------------------------

;;; Find the first instance on *obj-stack* in class
(defun search-stack (class) 
   (find-if #'(lambda (instance) (isa instance class)) *obj-stack*))

;;; ----------

;;; (defun show-km-stack () ...)  See debug.lisp
(defun show-obj-stack () (show-stack (obj-stack)))

(defun show-context () (show-stack (obj-stack)))
;;; Not used
;(defun showme-context () (showme (vals-to-val (reverse (obj-stack)))) t)

(defun unfiltered-obj-stack () *obj-stack*)

;;; Clean it up first!
;;; This is inefficient -- better to check we don't add classes or slots at add-time,
;;; in add-to-stack.
;(defun obj-stack () 
;  (setq *obj-stack* (remove-if #'(lambda (item)
;				   (or (classp item)
;				       (slotp item)))
;			       (remove-dup-atomic-instances *obj-stack*))))

(defun obj-stack () 
  (let ( (clean-stack (remove-dup-atomic-instances *obj-stack*)) )
    (cond ((not (equal clean-stack *obj-stack*)) 
	   (make-transaction `(setq *obj-stack* ,clean-stack))))
    clean-stack))

#|
(defun obj-stack () 
  (let ( (clean-stack (remove-dup-atomic-instances *obj-stack*)) )
    (cond ((some #'(lambda (item) (or (classp item) (slotp item))) clean-stack)
	   (setq *obj-stack* (remove-if #'(lambda (item)
					    (or (classp item)
						(slotp item)))
					clean-stack)))
	  ((equal clean-stack *obj-stack*) *obj-stack*)
	  (t (setq *obj-stack* clean-stack)))))
|#

(defun show-stack (stack)
   (mapcar #'(lambda (instance) (km-format t "   ~a~%" instance)) stack) t)

(defun showme (km-expr &optional (situations (all-situations)))
  (let* ( (frames (km km-expr))
	  (frame (first frames)) )
    (cond ((and (singletonp frames)
		(neq km-expr frame)
		(kb-objectp km-expr)	; ie. _Car23
		(is-km-term frame))	; eg. _Car23, or "MyCar"
	   (km-format t ";;; (~a is bound to ~a)~%~%" km-expr frame)))
    (cond ((singletonp frames) (showme-frame frame situations))
	  (t (mapc #'(lambda (frame) 
		       (showme-frame frame situations)
		       (princ ";;; ----------")
		       (terpri)
		       (terpri))
		   frames)))
    frames))

(defun showme-frame (frame &optional (situations (all-situations)))
  (cond ((not (is-km-term frame))
	 (report-error 'nodebugger-error "Doing (showme-frame ~a) - the frame name `~a' should be a KB term!~%" frame frame))
	(t (princ (write-frame frame situations)))))

;;; ======================================================================

;;; This shows all valid slots!
(defun showme-all (km-expr &optional (situations (all-situations)))
  (let* ( (frames (km km-expr))
	  (frame (first frames)) )
    (cond ((and (singletonp frames)
		(neq km-expr frame)
		(kb-objectp km-expr)	; ie. _Car23
		(is-km-term frame))	; eg. _Car23, or "MyCar"
	   (km-format t ";;; (~a is bound to ~a)~%~%" km-expr frame)))
    (cond ((singletonp frames) (showme-all-frame frame situations))
	  (t (mapc #'(lambda (frame) 
		       (showme-all-frame frame situations)
		       (princ ";;; ----------")
		       (terpri)
		       (terpri))
		   frames)))
    frames))

(defun showme-all-frame (instance &optional (situations (all-situations)))
  (cond ((not (is-km-term instance))
	 (report-error 'nodebugger-error "Doing (showme-all-frame ~a) - the instance name `~a' should be a KB term!~%" instance instance))
	(t (mapc #'(lambda (situation)
		     (showme-all-frame-in-situation instance situation))
		 situations)
	   t)))

(defun showme-all-frame-in-situation (instance situation)
  (cond ((eq situation *global-situation*) (km-format t "(~a has~%" instance))
	(t (km-format t "(in-situation ~a~% (~a has~%" instance)))
  (mapc #'(lambda (slot)
	    (let ( (domain (or (km-unique `#$(the domain of ,SLOT) :fail-mode 'fail) '#$Thing)) )
	      (cond ((instance-of instance domain)
		     (let* ( (rule-sets (bind-self (collect-rule-sets instance slot) instance))
			     (instance-expr-sets (bind-self (collect-instance-expr-sets instance slot) instance))
			     (all-sets (remove-duplicates (append instance-expr-sets rule-sets) :test #'equal :from-end t))
			     (joiner (cond ((single-valued-slotp slot) '&) 
					   (t '&&))) )
		       (cond ((null all-sets) (km-format t "  (~a ())~%" slot))
			     ((singletonp all-sets) (km-format t "  (~a ~a)~%" slot (first all-sets)))
			     (t (print-slot-exprs slot all-sets joiner))))))))
	(sort (copy-list (all-instances '#$Slot)) #'string< :key #'symbol-name))		; copy list just to be safe, as sort is destructive
  (cond ((eq situation *global-situation*) (km-format t ")~%~%"))
	(t (km-format t "))~%~%"))))

(defun print-slot-exprs (slot all-sets joiner &key (first-time-through t))
  (cond (first-time-through
	 (case joiner
	       (&  (km-format t "  (~a (  " slot))
	       (&& (km-format t "  (~a (   " slot))))
	(t (km-format t (spaces (+ 5 (length (symbol-name slot)))))
	   (km-format t "~a " joiner)))
  (cond ((single-valued-slotp slot) (km-format t "~a" (vals-to-&-expr (first all-sets))))
	(t (km-format t "~a" (first all-sets))))
  (cond ((null all-sets)
	 (report-error 'program-error "Null all-sets in print-slot-exprs (stack.lisp!)~%"))
	((singletonp all-sets) (format t ")~%"))
	(t (format t "~%")
	   (print-slot-exprs slot (rest all-sets) joiner :first-time-through nil))))

;;; ======================================================================

;;; This shows all valid slots!
(defun evaluate-all (km-expr &optional (situations (all-situations)))
  (let* ( (frames (km km-expr))
	  (frame (first frames)) )
    (cond ((and (singletonp frames)
		(neq km-expr frame)
		(kb-objectp km-expr)	; ie. _Car23
		(is-km-term frame))	; eg. _Car23, or "MyCar"
	   (km-format t ";;; (~a is bound to ~a)~%~%" km-expr frame)))
    (cond ((singletonp frames) (evaluate-all-frame frame situations))
	  (t (mapc #'(lambda (frame) 
		       (evaluate-all-frame frame situations)
		       (princ ";;; ----------")
		       (terpri)
		       (terpri))
		   frames)))
    frames))

(defun evaluate-all-frame (instance &optional (situations (all-situations)))
  (cond ((not (is-km-term instance))
	 (report-error 'nodebugger-error "Doing (evaluate-all-frame ~a) - the instance name `~a' should be a KB term!~%" instance instance))
	(t (mapc #'(lambda (situation)
		     (evaluate-all-frame-in-situation instance situation))
		 situations)
	   t)))

(defun evaluate-all-frame-in-situation (instance situation)
  (cond ((eq situation *global-situation*) (km-format t "(~a has~%" instance))
	(t (km-format t "(in-situation ~a~% (~a has~%" instance)))
  (mapc #'(lambda (slot)
	    (let ( (domain (or (km-unique `#$(the domain of ,SLOT) :fail-mode 'fail) '#$Thing)) )
	      (cond ((instance-of instance domain)
		     (let ( (vals (km `#$(the ,SLOT of ,INSTANCE) :fail-mode 'fail)) )
		       (cond ((null vals) (km-format t "  (~a ())~%" slot))
			     (t (km-format t "  (~a ~a)~%" slot vals))))))))
	(sort (copy-list (all-instances '#$Slot)) #'string< :key #'symbol-name))		; copy list just to be safe, as sort is destructive
  (cond ((eq situation *global-situation*) (km-format t ")~%~%"))
	(t (km-format t "))~%~%"))))




;;; FILE:  stats.lisp

;;; File: stats.lisp
;;; Author: Peter Clark
;;; Date: August 1994
;;; Purpose: Keep track and report various inference statistics

#|
General, useful facility
(defun time-it (function)
  (reset-statistics)
  (print (eval function))
  (print (report-statistics))
  t)
|#

(defun reset-statistics ()
  (reset-count '*inferences*)
  (reset-count '*kb-access*)
  (reset-count '*cpu-time*))
; (reset-frame-access-count)

(defun report-statistics ()
    (let ( (cpu-time (- (get-internal-run-time) (current-count '*cpu-time*))) )
      (concat 
       (format nil "(~a inferences and ~a kb-accesses in ~,1F sec"
	      (current-count '*inferences*)
      	      (current-count '*kb-access*)
	      (/ cpu-time internal-time-units-per-second))  ; itups = a system constant
       (cond ((not (eq cpu-time 0))
	      (format nil " [~a lips, ~a kaps]"
	      (floor (/ (* internal-time-units-per-second
			   (current-count '*inferences*)) cpu-time))
 	      (floor (/ (* internal-time-units-per-second
			   (current-count '*kb-access*)) cpu-time)))))
       (format nil ")~%"))))

;;; ---------- interface to the inference counter

(defvar *inferences* 0)
(defvar *kb-access* 0)
(defvar *cpu-time* 0)

;;;(defun reset-count (counter) (setq counter 0))
;;;(defun increment-count (counter) (setq counter (+ counter 1)))
;;;(defun current-count (counter) counter)
  
(defun reset-count (counter)
  (cond ((eq counter '*inferences*) (setq *inferences* 0))
	((eq counter '*kb-access*) (setq *kb-access* 0))
	((eq counter '*cpu-time*) (setq *cpu-time* (get-internal-run-time)))))

(defun increment-count (counter)
  (cond ((eq counter '*inferences*) (setq *inferences* (+ *inferences* 1)))
	((eq counter '*kb-access*) (setq *kb-access* (+ *kb-access* 1)))))

(defun current-count (counter)
  (cond ((eq counter '*inferences*) *inferences*)
	((eq counter '*kb-access*) *kb-access*)
	((eq counter '*cpu-time*) *cpu-time*)))

(defun set-count (counter val)
  (cond ((eq counter '*inferences*) (setq *inferences* val))
	((eq counter '*kb-access*) (setq *kb-access* val))
	((eq counter '*cpu-time*) (setq *cpu-time* val))))

;;; FILE:  anglify.lisp

;;; File: anglify.lisp
;;; Author: Peter Clark
;;; Date: Separated out Aug 1994
;;; Purpose: Concatenation and customisation of text-fragments

; If nil then 3 -> "3". If t then 3 -> "the value 3"
(defparameter *verbose-number-to-text* nil)	

;;; ======================================================================
;;;		CONCATENATING TEXT FRAGMENTS TOGETHER NICELY
;;; ======================================================================

#|
make-phrase/make-sentence:
INPUT: Can be either a single KM expression, or a :set / :seq of KM expressions -- make-sentence will
flatten them out and doesn't care. :set and :seq flags are ignored, and sequence is preserved.
RETURNS: A string built from these fragments, possibly capitalized and with a terminator added.

If a KM instance is included in the input, then this function will recursively replace it by (the name of <instance>)
until (the name of <instance>) just returns <instance>. This typically happens when <instance> is a class name:
	-> (the name of _Dog3) constructs (:seq "a" Dog), then calls itself again for instances in this expression
  	  -> (the name of Dog) -> Dog			; fixed point
	  <- Dog
	<- (:seq "a" Dog)

NOTE: :htmlify flag isn't used by KM, but might be by the user if (i) he/she makes a top-level call to 
	make-phrase/make-sentence, and (ii) he/she redefines (make-name ...) to respond to a :htmlify t flag.
|#
(defun make-phrase (text &key htmlify)
  (make-sentence text :capitalize nil :terminator "" :htmlify htmlify))

(defun make-sentence (text &key (capitalize t) (terminator ".") htmlify)
  (let ( (new-string (concat-list 
		      (spacify
		       (remove nil
			(mapcar #'(lambda (i)
				    (cond 
				     ((null i) nil)
				     ((stringp i) i)
				     ((numberp i) (princ-to-string i))
				     ((member i '#$(:seq :set :triple)) nil)
				     ((symbolp i) (string-downcase i))
				     (t (report-error 'user-error "make-sentence/phrase: Don't know how to convert ~a to a string!~%" i))))
				(flatten (listify (expand-text text :htmlify htmlify)))))))) )
    (cond ((null new-string) "")
	  (t (let ( (terminated-string (cond ((not (ends-with new-string terminator)) (concat new-string terminator))
					     (t new-string))) )
	       (cond (capitalize (capitalize terminated-string))
		     (t terminated-string)))))))

#|
expand-text: This function takes a KM structure or atom, eg. a (:seq ...) structure, and recursively expands
it to more primitive fragments using calls to (name ...). It eventually bottoms out when (name X) returns X. An
example of the expansion might be:
   (:seq _Engine23 "has purpose" _Purpose24)
-> (:seq (:seq "a" Engine) "has purpose" ("a" Propelling "whose object is" _Airplane25))
-> (:seq (:seq "a" Engine) "has purpose" ("a" Propelling "whose object is" (:seq "a" Airplane)))   [<= final result]
   
where (name _Engine23) -> (:seq "a" Engine)
      (name _Purpose24) -> ("a" Propelling "whose object is" _Airplane24)
      (name _Airplane25) -> (:seq "a" Airplane)
|#
(defun expand-text (item &key htmlify (depth 0))
  (let ( (expanded (remove '#$:seq (flatten (expand-text0 item :htmlify htmlify :depth depth)))) )
    (cond ((null expanded) nil)
	  ((singletonp expanded) (first expanded))
	  (t (cons '#$:seq expanded)))))

(defun expand-text0 (item &key htmlify (depth 0))
  (cond ((> depth 100)
	 (report-error 'user-error "make-sentence/phrase: Infinite recursion when generating name for ~a!~%" item))
	((stringp item) item)
	((numberp item)
	 (cond (*verbose-number-to-text* (list "the value" item))
	       (t item)))
	((listp item)
	 (mapcar #'(lambda (i) (expand-text0 i :htmlify htmlify :depth (1+ depth))) item))
	((member item '#$(:seq :set)) item)
	((or (kb-objectp item) 
	     (km-triplep item))
	 (let ( (name (name item)) )
	   (cond ((equal name item) item)
		 (t (expand-text0 name :depth (1+ depth))))))
	(t (report-error 'user-error "make-sentence/phrase: Bad element `~a' encountered!!~%" item))))

#|
;;; The htmlify flag is passed here in case the user wants to redefine make-name to actually do something with the flag!
(defun make-name (item &key htmlify)
  (declare (ignore htmlify))
  (let ( (names (km `#$(the name of ,ITEM) :fail-mode 'fail)) )
    (cond ((singletonp names) 
	   (cond ((stringp (first names)) (first names))
		 (t (report-error 'user-error "make-sentence/phrase: (the name of ~a) should return a string,~%but it returned ~a instead!~%"
				  item (first names)))))
	  ((null names) "???")
	  (t (report-error 'user-error "make-sentence/phrase: (the name of ~a) should return a single string,~%but it returned ~a instead!~%"
			   item names)))))
|#

;;; This could be written a million times better!
;;; words = A flattened list of strings.
;;; Periods must be a separate string (".") for capitalization to work
;;; properly.
(defun spacify (words)
  (cond ((null words) nil)
	((singletonp words) words)
	((white-space-p (second words) :whitespace-chars '(#\Space #\Tab))	; (but not #\Newline)
	 (spacify (cons (first words) (rest (rest words)))))
	((string= (first words) ".")
	 (cond ((and (string= (second words) (string #\Newline))
		     (not (null (third words))))
		(cons (first words) 
		      (cons (second words) 
			    (spacify (cons (capitalize (third words)) (rest (rest (rest words))))))))
	       (t (cons ". " (spacify (cons (capitalize (second words))
					    (rest (rest words))))))))
	((char= (first-char (second words)) #\-)	;; Special character, which forces no space
	 (cons (first words)
	       (spacify (cons (butfirst-char (second words))
				    (rest (rest words))))))
	(t (cons (first words)
		 (cons (a-space (first words) (second words))
		       (spacify (rest words)))))))

;;; "dog" -> "Dog"
(defun capitalize (string)
  (concat (string-upcase (first-char string)) (butfirst-char string)))

;;; Crude!
;;; (a-space "cat" "dog") -> " "
;;; (a-space "cat" " dog") -> ""
;;; (a-space "cat " "dog") -> ""
(defun a-space (word1 word2)
  (cond ((no-following-spaces  (last-char word1)) "")
	((no-preceeding-spaces (first-char word2)) "")
	(t " ")))

(defun no-following-spaces (char)
  (member char '( #\( #\  )))

(defun no-preceeding-spaces (char)
  (member char '( #\' #\) #\. #\, #\ )))

;;; ======================================================================
;;;			NAMES OF FRAMES
;;; ======================================================================
#|
Revised March 2000.
Name returns a (possibly nested) list of fragments, which together produce a top-level name
for an object. name *doesn't* call itself recursively.

To recursively expand the name for objects, use make-phrase or make-sentence. These two functions
recursively convert symbols to their name structures, and then flatten, stringify, and concatenate 
the result.
|#

(defun name (concept &key htmlify)
  (cond ((tracep) (prog2 (suspend-trace) (name0 concept :htmlify htmlify) (unsuspend-trace)))
	(t (name0 concept :htmlify htmlify))))

;;; [1] to prevent situation-specific instances all inheriting name "the thing" from the global situation!
(defun name0 (concept &key htmlify)
  (cond ((stringp concept) concept)
	((numberp concept) (princ-to-string concept))
	((prototypep concept) (prototype-name concept :htmlify htmlify))			; <== new
	((km-triplep concept) (triple-name concept))
	((let ( (name (km `#$(the name of ,CONCEPT) :fail-mode 'fail)) )
	   (cond 
	    ((singletonp name) (first name))
	    ((not (null name)) 
	     (make-comment (km-format nil "Warning! ~a has multiple name expressions ~a!~%     Continuing just using the first (~a)..."
				      concept name (first name)))
	     (first name)))))
	((km-unique `#$(the name of ,CONCEPT) :fail-mode 'fail))
	((symbol-starts-with concept #\*)		; "*pete" -> "pete"
	 (butfirst-char (string-downcase concept)))
	((anonymous-instancep concept)
	 (cond ((not (equal (immediate-classes concept) '#$(Thing)))	; else return NIL [1]
		(anonymous-instance-name concept :htmlify htmlify))))
	(t concept)))
;	       (string-downcase concept)))))

(defun anonymous-instance-name (concept &key htmlify)
  (declare (ignore htmlify))
;  (concat "the " (name (first (immediate-classes concept)))))
  `(#$:seq "the" ,(name (first (immediate-classes concept)))))

;;; ----------

(defun prototype-name (concept &key htmlify)
  (declare (ignore htmlify))
  (cond ((not (prototypep concept))
	 (report-error 'user-error "Trying to generate prototype name of non-prototype ~a!~%" concept))
	((prototype-rootp concept)
	 (or (km-unique `#$(the name of ,CONCEPT) :fail-mode 'fail)
	     (let ( (parent (first (immediate-classes concept))) )
;	       (concat "a " (name parent)))))		; Should really print out qualifications to prototype too
	       `(#$:seq "a" ,(name parent)))))
;	 (let ( (parent (first (immediate-classes concept)))
;		(activity-type (km-unique `#$(the activity-type of ,CONCEPT) :fail-mode 'fail)) )
;	   (cond (activity-type (concat "a " (name parent) " when " (name activity-type)))
;		 (t (concat "a " (name parent))))))
	(t `(#$:seq "the" ,(name (first (immediate-classes concept))) 
		  "of" ,(prototype-name (km-unique `#$(the protopart-of of ,CONCEPT)))))))
;	(t (concat "the " (name (first (immediate-classes concept))) 
;		   " of " (prototype-name (km-unique `#$(the protopart-of of ,CONCEPT)))))))

;;; ----------

#|
CL-USER> (triple-name '#$(:triple *pete owns (:set *money *goods *food)))
(:|seq| "pete" |owns| (:|seq| "money" ", " "goods" ", and " "food"))
CL-USER> (triple-name '#$(:triple *pete believes (:triple *joe owns *goods)))
(:|seq| "pete" |believes| (:|seq| "joe" |owns| "goods"))
|#
(defun triple-name (triple &key htmlify)
  (let ( (vals (val-to-vals (fourth triple))) )
    (list '#$:seq
	  (name (second triple) :htmlify htmlify)		; ("pete")
	  (name (third triple) :htmlify htmlify)		; ("owns")
	  (cond ((null vals) nil)
		((singletonp vals) (name (first vals) :htmlify htmlify))
		(t (cons '#$:seq
			 (andify (mapcar #'(lambda (v) (name v :htmlify htmlify)) vals))))))))




;;; FILE:  writer.lisp

;;; File: writer.lisp
;;; Author: Peter Clark
;;; Date: Mar 1996 spliced out Feb 1997
;;; Purpose: Copy of updated write-frame from server/frame-dev.lisp

(defconstant *special-symbol-alist*
  '( (quote "'")
     (function "#'")
     (unquote "#,")
     (unquote-splice "#@") ))

;     ("BACKQUOTE" "`")
;     ("BQ-COMMA" ",")))

;;; frame can be *any* valid KM term, including strings, numbers, sets, sequences, functions, and normal frames.
(defun write-frame (frame &optional (situations (all-situations)) htmlify)
  (cond 
   ((and (kb-objectp frame) (bound frame)) (km-format nil ";;; (~a is bound to ~a)~%~%" frame (dereference frame)))
   (t (let ( (frame-string (write-frame0 frame situations htmlify)) )
	(cond ((string/= frame-string "") frame-string)
	      ((built-in-concept-type frame)
	       (concat (km-format nil ";;; (Concept ~a is a built-in " frame)
		       (built-in-concept-type frame)
		       (format nil ")~%~%")))
	      ((equal situations (all-situations))
	       (km-format nil ";;; (Concept ~a is not declared anywhere in the KB)~%~%" frame))
	      ((singletonp situations)
	       (km-format nil ";;; (Concept ~a is not declared in the situation ~a)~%~%" frame (first situations)))
	      (t (km-format nil ";;; (Concept ~a is not declared in the situations: ~a)~%~%" frame situations)))))))


(defun write-frame0 (frame &optional (situations (all-situations)) htmlify)
  (cond ((stringp frame) (km-format nil ";;; (~a is a string)~%~%" frame))
	((numberp frame) (km-format nil ";;; (~a is a number)~%~%" frame))
	((descriptionp frame) (km-format nil ";;; (~a is a quoted expression)~%~%" frame))
	((km-seqp frame) (km-format nil ";;; (~a is a sequence)~%~%" frame))
	((km-setp frame) (km-format nil ";;; (~a is a set)~%~%" frame))
	((km-argsp frame) (km-format nil ";;; (~a is an argument list)~%~%" frame))
	((functionp frame) (km-format nil ";;; (~a is a Lisp function)~%~%" frame))
	((kb-objectp frame) 
	 (concat-list 
	  (append
	   (write-situation-specific-assertions frame htmlify)
	   (mapcar #'(lambda (situation) 
		       (write-frame-in-situation frame situation htmlify))
		   situations))))
	(t (report-error 'user-error "~a is not a KB object!~%" frame))))

(defun write-situation-specific-assertions (situation-class &optional htmlify)
  (cond 
   ((is-subclass-of situation-class '#$Situation)
    (let ( (assertions (second (assoc '#$assertions 
				      (get-slotsvals situation-class 'member-properties *global-situation*)))) )
      (cond (assertions
	     (mapcar #'(lambda (assertion)
			 (cond ((not (quotep assertion))
				(report-error 'user-error "Unquoted assertion ~a in situation-class ~a! Ignoring it...~%" 
					      assertion situation-class) "")
			       (t (let ( (modified-assertion (sublis '#$((SubSelf . Self) (Self . TheSituation)) (second assertion))) )
				    (concat (km-format nil "(in-every-situation ")
					    (objwrite situation-class htmlify)
					    (km-format nil "~%  (")
					    (objwrite modified-assertion htmlify)
					    (km-format nil ")~%~%"))))))
		     assertions)))))))

(defun write-frame-in-situation (frame situation &optional htmlify)
  (let ( (own-props (get-slotsvals frame 'own-properties    situation))
	 (mbr-props (get-slotsvals frame 'member-properties situation))
	 (own-defn  (get-slotsvals frame 'own-definition    situation))
	 (mbr-defn  (get-slotsvals frame 'member-definition situation)) )
    (concat
     (cond (own-defn  (concat-list (flatten (write-frame2 frame situation own-defn  nil '#$has-definition htmlify)))))
     (cond ((and own-props (not (and (singletonp own-props) (eq (first (first own-props)) '#$assertions))))	; filter out these!
	    (concat-list (flatten (write-frame2 frame situation own-props nil '#$has htmlify)))))
     (cond (mbr-defn  (concat-list (flatten (write-frame2 frame situation mbr-defn  '#$every '#$has-definition htmlify)))))
     (cond ((and mbr-props (not (and (singletonp mbr-props) (eq (first (first mbr-props)) '#$assertions))))	; filter out these!
	    (concat-list (flatten (write-frame2 frame situation mbr-props '#$every '#$has htmlify))))))))

(defun write-frame2 (frame situation slotsvals0 quantifier joiner &optional htmlify)
  (let ( (slotsvals (dereference slotsvals0))
	 (tab (cond ((eq situation *global-situation*) 0)
		    (t 2))) )
    (list (cond ((neq situation *global-situation*)
		 (concat (km-format nil "(in-situation ") 
			 (objwrite situation htmlify)
			 (km-format nil "~%"))))
	  (cond ((not (eq tab 0)) (format nil "~vT" tab)))    ; (format nil "~vT" 0) prints one space (Lisp bug?)
	  (cond (quantifier (km-format nil "(~a " quantifier))  	; "(every "
		(t "("))
	  (objwrite frame htmlify)
	  (km-format nil " ~a " joiner)				; "has" or "has-definition"
	  (write-slotsvals slotsvals (+ tab 2) htmlify)
	  ")"
	  (cond ((neq situation *global-situation*) ")"))
	  (format nil "~%~%"))))

(defun write-slotsvals (slotsvals &optional (tab 2) htmlify)
  (mapcar #'(lambda (slotvals) (write-slotvals slotvals tab htmlify)) slotsvals))

(defun write-slotvals (slotvals &optional (tab 2) htmlify)
  (cond ((null slotvals) (format nil " ()"))
	((eq (slot-in slotvals) '#$assertions) "")
	(t (list (format nil "~%~vT(" tab)
		 (objwrite (slot-in slotvals) htmlify) 
		 " "
		 (write-vals (remove-dup-instances (vals-in slotvals))
			     (+ tab 3 (length (km-format nil "~a" (slot-in slotvals))))
			     htmlify)
		 (cond ((> (length slotvals) 2)
			(report-error 'user-error "Extra element(s) in slotvals list!~%~a. Ignoring them...~%" slotvals)))
		 ")"))))


(defun write-vals (vals &optional (tab 2) htmlify)
  (cond ((null vals) "()")
	(t (list "("
		 (objwrite (first vals) htmlify)
		 (mapcar #'(lambda (val)
			     (list (format nil "~%~vT" tab) (objwrite val htmlify)))
			 (rest vals))
		 ")"))))

(defun write-kmexpr (kmexpr _tab htmlify) (declare (ignore _tab)) (objwrite kmexpr htmlify))

;;; convert to strings to remove package info:
;;; [1c] USER(143): (first '`(the ,car))
;;; excl::backquote
(defun objwrite (expr htmlify)
  (cond ((atom expr) (objwrite2 expr htmlify))
	((and (pairp expr) 
	      (symbolp (first expr))
	      (assoc (first expr) *special-symbol-alist*))
	 (let ( (special-symbol-str (second (assoc (first expr) *special-symbol-alist*))) )
	   (list special-symbol-str (objwrite (second expr) htmlify))))
	((listp expr)
	 (list "("
	       (objwrite (first expr) htmlify)
	       (mapcar #'(lambda (item)
			   (list " " (objwrite item htmlify)))
		       (rest expr))
	       ")"))
	(t (report-error 'user-error "Don't know how to (objwrite ~a)!~%" expr))))

;;; Default server action, when interfaced with Web browser. Not used in KM stand-alone
(defparameter *html-action* '"frame")
; (defparameter *html-window* '"target=right")
(defparameter *html-window* '"")

;;; The primitive write operation
;;; [1] Include ||s: (symbol-name '|the dog|) -> "the dog", while (km-format nil "~a" '|the dog|) -> "|the dog|".
(defun objwrite2 (expr htmlify &key (action *html-action*) (window *html-window*))
  (cond ((and htmlify (kb-objectp expr) (known-frame expr)) 		; with KM only, htmlify is always nil 
	 (htextify expr (km-format nil "~a" expr) :action action :window window)) ; [1]
	((eq expr nil) "()")
	(t (km-format nil "~a" expr))))


;;; FILE:  taxonomy.lisp

;;; File: taxonomy.lisp
;;; Author: Peter Clark
;;; Date: April 96
;;; Purpose: Print out the frame hierarchy
;;; Warning: Frighteningly inefficient.

(defvar *indent-increment* 3)
(defvar *prune-points* nil)
(defvar *ignore-items* nil)
(defvar *maxdepth* 9999)

;; for backward compatibility
(defun print-tax () (taxonomy) t)

(defun taxonomy () (write-lines (make-tax)) t)

;;; Rather ugly -- returns two values
;;; (i) a list of strings, = the taxonomy
;;; (ii) a list of all the concepts processed (= all of them)
(defun make-tax (&optional (current-node '#$Thing) 
			   nodes-done 
			   (relation-to-descend '#$subclasses) 
			   (tab 0)
			   htmlify)
  (declare (ignore current-node nodes-done))				; obsolete, now
  (cond ((eq relation-to-descend '#$subclasses) (install-all-subclasses))) 
  (let* ( (all-objects (dereference (get-all-objects)))
	  (top-classes (immediate-subclasses '#$Thing)) )
     (multiple-value-bind
      (strings all-nodes-done)
      (make-taxes (sort (remove '#$Thing top-classes) #'string< :key #'symbol-name) nil relation-to-descend (+ tab *indent-increment*) htmlify)
      (let ( (unplaceds (remove-if-not #'named-instancep 
				       (set-difference all-objects (cons '#$Thing all-nodes-done)))) )
	(append (cons "Thing" strings)
		(mapcar #'(lambda (unplaced)
			    (tax-obj-write unplaced *indent-increment* htmlify :instancep '?))
			(sort unplaceds #'string< :key #'symbol-name)))))))

(defun make-tax0 (current-node nodes-done relation-to-descend tab htmlify)
  (let ( (item-text (tax-obj-write current-node tab htmlify)) )
    (cond ((member current-node *ignore-items*)
	   (values (list item-text
			 (format nil "~vTignoring children..." 
				 (+ tab *indent-increment*)))
		   nodes-done))
	  (t (let* ( (all-instances  (km `#$(the instances of ,CURRENT-NODE) :fail-mode 'fail))
		     (named-instances (remove-if-not #'named-instancep all-instances))
		     (instances-text (mapcar #'(lambda (instance)
						 (tax-obj-write instance (+ tab *indent-increment*) htmlify :instancep t)) 
					     (sort named-instances #'string< :key #'symbol-name)))
		     (specs (sort (km `#$(the ,RELATION-TO-DESCEND #$of ,CURRENT-NODE) :fail-mode 'fail)
				  #'string<
				  :key #'symbol-name)) )			; alphabetical order
	       (cond ((and specs (member current-node nodes-done))
		      (values (list item-text
				    (format nil "~vT..." 
					    (+ tab *indent-increment*)))
			      nodes-done))
		     (t (multiple-value-bind
			 (string new-nodes-done)
			 (make-taxes specs (cons current-node (append all-instances nodes-done)) relation-to-descend
				     (+ tab *indent-increment*) htmlify)
			 (values (cons item-text (cons instances-text string)) new-nodes-done)))))))))

(defun make-taxes (current-nodes nodes-done relation-to-descend tab htmlify)
  (cond ((not (listp current-nodes)) (values nil nodes-done))	; in case of a syntax error in the KB
	((endp current-nodes) (values nil nodes-done))
	((> (/ tab *indent-increment*) *maxdepth*)
	 (values (list (format nil "~vT...more..." 
			       (+ tab *indent-increment*)))
		 nodes-done))
	((not (atom (first current-nodes)))   			; in case of a syntax error in the KB
	 (make-taxes (rest current-nodes) nodes-done relation-to-descend tab htmlify))
	((or (anonymous-instancep (first current-nodes))		; don't show anonymous instances
	     (not (kb-objectp (first current-nodes))))			; or numbers or strings
	 (make-taxes (rest current-nodes) nodes-done relation-to-descend tab htmlify))
	(t (multiple-value-bind
	    (string mid-nodes-done)
	    (make-tax0 (first current-nodes) nodes-done relation-to-descend tab htmlify)
	    (multiple-value-bind
	     (strings new-nodes-done)
	     (make-taxes (rest current-nodes) mid-nodes-done relation-to-descend tab htmlify)
	     (values (list string strings) new-nodes-done))))))
     
(defun tax-obj-write (concept tab htmlify &key instancep)
  (concat 
   (cond ((eq tab 0) "")
	 ((eq instancep '?) (format nil "?~a" (spaces (1- tab))))  ; Unfortunately, (format nil "~vT" 0) = " " not ""
	 ((eq instancep t) (format nil "I~a" (spaces (1- tab))))  ; Unfortunately, (format nil "~vT" 0) = " " not ""
	 (t (format nil "~vT" tab)))  ; Unfortunately, (format nil "~vT" 0) = " " not ""
   (objwrite2 concept htmlify)))
;   (cond (htmlify (htextify concept (symbol-name concept) :action '"frame")) ; htmlify always nil for KM only
;	 (t (km-format nil "~a" concept)))))

       

	 

;;; FILE:  subsumes.lisp

;;; File: subsumes.lisp
;;; Author: Peter Clark
;;; Purpose: Checking subsumption. This is slightly tricky to do properly.
;;; In this implementation, no unification is performed.

#|
Note we want to distinguish between
 a. "The car owned by a person." (the car with (owner ((a person))))
 b. "The car owned by person23." (the car with (owner ( _person23)))

We could evaluate (a person) to create a Skolem, and then do unification
with a subsumption flag in, but this doesn't work -- case a. and b. are
indistinguishable, but we'd want unification with _person24 (say) to succeed 
in case a. and fail in b.

Handler for (the X with SVs) in interpreter.lisp:
-------------------------------------------------
  1. call subsumes (a X with SVs) to return an answer.
  2. If no answer returned, call (a X with SVs) to create it.

The base algorithm:
-------------------
;;; where subsumer-expr is form '(a Class with SlotsVals)
(defun is0 (subsumee-instance subsumer-expr)
1. find an object O of type Class (person)
2. for each slot S on person
    a. compute vals Vs of O.S
      for each expr in the value of person.S     
	 IF expr is of form "(a ?class)" or "(a ?class with &rest)"
	 THEN foreach V in Vs
		call (subsumes expr V) until success (removing V from Vs?)
	 ELSE i. evaluate expr to find OVs
	      ii. check OVs is a subset of Vs (and if so remove OVs from Vs?)
		  (Note we're *not* allowing unification to occur)
3. If success, then return Subsumee-Instance
|#

;;; > (find-subsumees '(a Car with (color (Red))))
(defun find-subsumees (existential-expr &optional (candidates (find-candidates existential-expr)))
  (remove-if-not #'(lambda (candidate-instance) 
		     (is0 candidate-instance existential-expr))
		 candidates))

;;; ------------------------------
#|
Finding all candidate instances which the existential expression might be referring to.
There are two ways of doing this:
	(a Car with 
	   (owned-by (Porter))
	   (color (Brown))
	   (age (10))
  	   (parts ((a Steering-wheel with (color (Red))))))
  1. follow inverse links (Porter owns Car), (Brown color-of), (10 age-of)
     However, this is incomplete for two reasons:
	(i) the implicit (instance-of (Car)) relation isn't searched -- but we
		can add it in.
	(ii) it will miss some items starting with non-symbols, eg. (10 age-of).
  2. The answer(s) must be in the intersection of the answers returned, subject to:
	- we better also add (all-instance-of Car) to the set
	- if no instances are returned by a particular inversing, then we'll
		ignore it (assuming either it was a non-symbolic frame, or 
		the evaluator has somehow failed to cache the answer even though
		it's there).
     INCOMPLETENESS: Suppose (Brown color-of) *does* return some values, but
	  not including this Car (eg. this Car is an embedded unit? We'll
	  fail then. Depends on how complete/efficient we want this.
 Now we just do this simple version below:
|#
(defun find-candidates (existential-expr)
  (let* 
    ( (class+slotsvals (is-existential-expr existential-expr :fail-mode 'error))  ; [1]
      (class (first class+slotsvals))
      (slotsvals (second class+slotsvals)) )
    (mapc #'(lambda (slotvals)         	      	  ; this will force some evaluation
	      (find-candidates2 class slotvals))  ; of relevant frames
	  slotsvals)
;;; (all-instances class)))
;;; NEW: Only instances on obj-stack are possible candidates, so obj-stack defines the context
    (remove-if-not #'(lambda (instance) (isa instance class)) (obj-stack))))

;;; STRIPPED VERSION:
(defun find-candidates2 (class slotvals)
  (let* ( (slot (first slotvals))
 	  (invslot (invert-slot slot))
	  (vexprs (second slotvals)) )
     (mapc #'(lambda (vexpr)
	       (cond ((is-existential-expr vexpr)
		      (mapc #'(lambda (val) 
				(km `(#$the ,class ,invslot #$of ,val) :fail-mode 'fail))
			    (find-subsumees vexpr)))
		     (t (km `(#$the ,class ,invslot #$of ,vexpr) :fail-mode 'fail))))  ; [2]
	   vexprs)))

#|
 ======================================================================
		SUBSUMPTION TESTING
 ======================================================================

This below table gives the rules for transforming different forms of the expression
into the BASE IMPLEMENTATION for "is0":

SUBSUMES:
	('(every X) subsumes '(every Y))	== ('(a Y) is '(a X))
	('(every X) subsumes {I1,..,In})	== (allof {I1,..,In} must ('(every X) covers It))
	({I1,..,In} subsumes '(every Y))	== ERROR
	({I1,..,In} subsumes {J1,..,Jn})	== ({I1,..,In} is-superset-of {J1,..,Jn})
COVERS:
	('(every X) covers '(a Y))    ==    ('(a Y) is '(a X))
	('(every X) covers    I  )    ==    (I is '(a X))
	({I1,..,In} covers '(a Y))    ==    (has-value (oneof {I1,..,In} where (It is '(a Y))))
	({I1,..,In} covers    I  )    ==    ({I1,..,In} includes I)
IS:
	('(a Y) is '(a X))	 ==     gensym a YI, (YI is '(a X)), delete YI
	('(a Y) is   I   )	 ==     ERROR
	(  I    is '(a X))	 == 	*****BASE IMPLEMENTATION***** : (is0 I '(a X))
	(  I1   is   I2  )	 ==     (I1 = I2)

We also have to be careful: With (Animal subsumes Dog), we must be sure that the
set (Animal) is recognized as a class description, not a set of instances. To do 
this, we convert (say) Dog to '(every Dog).
|#

(defun subsumes (xs ys)
  (let ( (x-desc (vals-to-class-description xs))
	 (y-desc (vals-to-class-description ys)) )
    (cond ((and x-desc y-desc) 				        ; ('(every X) subsumes '(every Y)) == ('(a Y) is '(a X))
	   (is (every-to-a y-desc) (every-to-a x-desc)))
	  (x-desc 						; ('(every X) subsumes {I1,..,In}) == (allof {I1,..,In} 
	   (km `#$(allof ,(VALS-TO-VAL YS) must (,X-DESC covers It)) :fail-mode 'fail))    ;           must ('(every X) covers It))
	  (y-desc						; ({I1,..,In} subsumes '(every Y)) == ERROR
	   (report-error 'user-error "Doing (~a subsumes ~a)~%Can't test if a set subsumes an expression!~%" xs ys))
	  (t 							; ({I1,..,In} subsumes {J1,..,Jn}) == ({I1,..,In} is-superset-of {J1,..,Jn})
	   (km `#$(,(VALS-TO-VAL XS) is-superset-of ,(VALS-TO-VAL YS)) :fail-mode 'fail)))))

(defun covers (xs y)
  (let ( (x-desc (vals-to-class-description xs))
	 (y-desc (cond ((and (descriptionp y) (instance-descriptionp y)) y))) )		; instance-descriptionp will report error if necc.
    (cond ((and x-desc y-desc)					; ('(every X) covers '(a Y))    ==    ('(a Y) is '(a X))
	   (km `#$(,Y-DESC is ,(EVERY-TO-A X-DESC)) :fail-mode 'fail))
	  (x-desc						; ('(every X) covers    I  )    ==    (I is '(a X))
	   (km `#$(,Y is ,(EVERY-TO-A X-DESC)) :fail-mode 'fail))
	  (y-desc						; ({I1,..,In} covers '(a Y))    ==    (has-value (oneof {I1,..,In} 
	   (km `#$(has-value (oneof ,(VALS-TO-VAL XS) where (It is ,Y-DESC))) :fail-mode 'fail))   ;  where (It is '(a Y)))
	  (t 			       				; ({I1,..,In} covers    I  )    ==    ({I1,..,In} includes I)
	   (km `#$(,(VALS-TO-VAL XS) includes ,Y))))))

;;; [1]: Hmmm....We can't always guarantee KM will clean up after itself, as the computation [1a] may create additional 
;;; instances which *aren't* deleted by the tidy-up [1b]. Could use a subsituation??
(defun is (x y)
  (cond 
   ((equal y ''#$(a Class))				; SPECIAL CASE - for metaclasses:  '(every Dog) is '(a Class)
    (cond ((or (class-descriptionp x :fail-mode 'fail) (symbolp x)))	; succeed
	  (t (report-error 'user-error "Doing (~a is ~a)~%~a doesn't appear to be a class or class description.~%" x y x))))
   (t (let ( (x-desc (cond ((and (descriptionp x) (instance-descriptionp x)) x)))
	     (y-desc (cond ((and (descriptionp y) (instance-descriptionp y)) y))) )
	(cond ((and x-desc y-desc)					; ('(a X) is '(a Y))	 ==     gensym a XI, (XI is '(a Y)), delete XI
	       (let ( (tmp-i (km-unique (unquote x-desc))) )
;		 (km-format t "tmp-i ~a created!~%" tmp-i)
		 (prog1
		     (km `#$(,TMP-I is ,Y-DESC) :fail-mode 'fail) ; [1a]
		   (delete-frame tmp-i))))	   		  ; [1b]
	      (x-desc						; ('(a X) is   I   )	 ==     ERROR
	       (report-error 'user-error "Doing (~a is ~a)~%Can't test if an expression is `subsumed' by an instance!~%" x y))
	      (y-desc						; (  I    is '(a Y))	 == 	*****BASE IMPLEMENTATION*****
	       (is0 x (unquote y-desc)))
	      (t (km `#$(,X = ,Y) :fail-mode 'fail)))))))		; (  I1   is   I2  )	 ==     (I1 = I2)
	   
(defun vals-to-class-description (classes)
  (cond ((and (singletonp classes)
	      (kb-objectp (first classes))
	      (not (is-an-instance (first classes))))
	 `#$'(every ,(FIRST CLASSES)))					; (Dog) -> '(every Dog)
	((and (singletonp classes)
	      (descriptionp (first classes))
	      (let ( (val (unquote (first classes))) )
		(cond ((and (listp val)
			    (eq (first val) '#$every))
		       (first classes))					; ('(every Dog)) -> '(every Dog)
		      ((and (kb-objectp val)
			    (not (is-an-instance val)))
		       (report-error 'user-warning "You don't need to quote atomic class ~a. Unquoting it and continuing...~%" (first classes))
		       `#$'(every ,VAL))					; 'Dog -> '(every Dog)		    
		      ((instance-descriptionp (first classes) :fail-mode 'fail)
		       (report-error 'user-error 
				     "Expecting a class description '(every ...), but found an instance~%description ~a instead!~%" 
				     (first classes)))
		      (t (report-error 'user-error "Subsumption with ~a:~%Don't know how to do subsumption with this kind of expression!~%" 
				       (first classes)))))))))
									; otherwise, NIL	

;;; '(every Cat) -> '(a Cat)
(defun every-to-a (expr) `'(#$a ,@(rest (unquote expr))))

;;; ======================================================================
;;;	BASE IMPLEMENTATION FOR SUBSUMPTION TESTING: COMPARE AN INSTANCE WITH A DESCRIPTION
;;; ======================================================================

#|
[1] bind-self done for queries like:
CL-USER> (is0 '#$_rectangle0
	      '#$(a rectangle with (length ((Self width))) 
				   (width ((Self length)))))

MARCH 1999: CORRECTION! bind-self must be done *before* calling is0,
	as expr may be an embedded expression (thus Self refers to the 
	embedding frame).
[2] NB if no value in subsumer, then it *doesn't* subsume everything!!
NOTE: expr is UNQUOTED here, to allow easy recursive calling of is0

[3] del-list  
      expr     (:triple  Self   position (a Position))		    (a Position) is a single value
      instance (:triple _Light1 position (the position of _Light1)) is going to return a *list* of values for the third argument

|#
(defun is0 (instance expr)
  (cond ((and (km-structured-list-valp instance)
	      (km-structured-list-valp expr)
	      (eq (length instance) (length expr))
	      (eq (first instance) (first expr)))
	 (cond ((km-triplep instance)
		(and (is0 (second instance) (second expr))
		     (is0 (third instance)  (third expr))
		     (some #'(lambda (val) (is0 val (fourth expr))) 	; See [3] above
			   (val-to-vals (fourth instance)))))
	       (t (every #'(lambda (pair)
			     (is0 (first pair) (second pair)))
			 (rest (transpose (list instance expr)))))))	; ((:seq :seq) (i1 e1) (i2 e2) ... )

; Below [1], bind-self *may* appear redundant. However, expr
; *may* contain Self, if it came from a top-level query eg.
; 	KM> ((a Person with (owns (Self))) is (a Person with (owns (Self))))
;     (cond 
;      ((not (contains-self-keyword expr))
;	(km-format t "ERROR! Don't know how what `Self' refers to in the expression~%")
;	(km-format t "ERROR! ~a~%" expr))

	 (t (let ( (class+slotsvals (bind-self (is-existential-expr expr) instance)) )   ; [1]
	      (cond (class+slotsvals				;;; 1. An INDEFINITE expression
		     (cond ((and (fluent-instancep instance)			;;; NOTE a fluent-instance _SomePerson23 CAN'T be subsumed by
				 (eq (first expr) '#$a)) nil)		;;; 	 a non-fluent-instance (a ...)
			   (t (let ( (class (first class+slotsvals))		;;;    (so do subsumption)
				     (slotsvals (second class+slotsvals)) )
				(and (isa instance class)
				     (are-slotsvals slotsvals)		; syntax check
				     (every #'(lambda (slotvals) 
						(slotvals-subsume slotvals instance)) slotsvals))))))
		    ((constraint-exprp expr)
		     (test-constraints (list instance) (list expr)))
;;;		    (t (let ( (definite-val (km-unique expr :fail-mode 'error)) )  ;;; 2. a DEFINITE expression
;;; Why 'error above?? 
		    (t (let ( (definite-val (km-unique expr :fail-mode 'fail)) )  ;;; 2. a DEFINITE expression
			 (cond ((null definite-val) nil)	; [2]		    ;;;    (so do equality)
			       (t (equal definite-val instance))))))))))

;;; Perhaps rather slow?
;;; Returns 't' in the keyword 'Self' occurs in expr, nil otherwise.
(defun contains-self-keyword (expr)
  (cond ((null expr) nil)
	((eq expr '#$Self))
	((listp expr) 
	 (or (contains-self-keyword (first expr))
	     (contains-self-keyword (rest expr))))))

;;; (slotvals-subsume <subsumer> <subsumee>
;;; [1] is a quick, common lookahead, for calls like:
;;;	(slotvals-subsume '#$(connects ((the Engine parts of _Car23))) '#$_Car23)
;;; where the connects of _Car23 is exactly ((the Engine parts of _Car23)).
;;; [2] Don't count constraints! eg. Want (<> 20) to subsume () !
;;;     Thus, we abort if (the foo of Self) - NIL, on the assumption that (the foo of Self) will return at least one item (?).
;;;	BUT: (((the foo of Self) _Car3) now is considered to subsume 
;;; [3] It would be redundant to check if see-constraints are violated by ser-vals, as see-vals must necessarily be a superset of ser-vals!
;;;     The only case this doesn't hold is for the special `tag' slot. And in any case, see-constraints have been already removed by the
;;;	KM call at [4b]!
;;; [4a] Do a find-vals rather than a (km ...) call, as we *do* want to preserve constraints here in the
;;;      special case of tags.
(defun slotvals-subsume (slotvals instance)
  (let* ( (slot (first slotvals)) 
          (ser-exprs (second slotvals)) )
    (cond 
     ((some #'(lambda (situation)							; [1]
		(equal ser-exprs (get-vals instance slot 'own-properties situation)))
	    (cons (curr-situation) (all-supersituations (curr-situation)))))
     ((not (situation-specificp slot))							; otherwise fail it out
      (cond
; tag slots no longer used
;       ((and (tag-slotp slot) *are-some-constraints*)
;	(is-consistent (append ser-exprs (find-vals instance slot))))  			; [4a]
       (t (let ( (see-vals (km `#$(the ,SLOT of ,INSTANCE) :fail-mode 'fail)) )		; [4b]
	    (cond ((<= (length (remove-if #'constraint-exprp ser-exprs)) (length see-vals))	; quick look-ahead check [2]
		   (cond ((eq slot '#$instance-of) 			; special case
			  (classes-subsume-classes ser-exprs see-vals))	; assume no evaln needed
			 (t (let ( (constraints (find-constraints-in-exprs ser-exprs)) )
			      (and (test-constraints see-vals constraints)			; [3]
				   (vals-subsume (cond ((single-valued-slotp slot) 
							(&-expr-to-vals (first ser-exprs)))  ; eg. ((a Car) & (must-be-a Dog))
						       (t ser-exprs))
						 see-vals))))))))))))))

;;; GIVEN: some expressions, and some values
;;; RETURN t if *every* expression subsumes some (different) value in values.
;;; Notes:
;;; [1]: if expr includes, say, (a car), then consider it to subsume the first 
;;; instance of car in the subsumee.
;;; [2]: Don't remove ser-vals from see-vals, as subsumer may have several
;;; exprs which evaluate to the *same* instance:
;;; eg. in (expr1 expr2), expr1 evals to (x1 x2) and expr2 evaluates (x2 x3)
;;; But if we remove (x1 x2) from see-vals (x1 x2 x3 x4) we get (x3 x4),
;;; and now (subsetp '(x2 x3) '(x3 x4)) undesirably fails, even though x2
;;; is known to be in the full set see-vals.
(defun vals-subsume (ser-exprs see-vals)
  (cond 
   ((endp ser-exprs))			; success!!
   ((equal ser-exprs see-vals))		; quick success - don't need to recurse
   (t (let ( (ser-expr (first ser-exprs)) )
	(cond ((is-existential-expr ser-expr)
	       (let ( (see-val (first (find-subsumees ser-expr see-vals))) ) ; [1]
		 (cond (see-val (vals-subsume (rest ser-exprs) 
					      (remove see-val see-vals))))))
	      (t (let ( (ser-vals (km ser-expr :fail-mode 'fail)) )
		   (cond ((subsetp ser-vals see-vals)
			  (vals-subsume (rest ser-exprs) see-vals))))))))))  ; [2]

;;; ======================================================================
;;;		UTILS
;;; ======================================================================

;;; If expr is an existential expr, this returns a list (<class> <slotsvals>) of
;;; the existential expr's structure.
;;; (is-existential-expr '(a car with (age (old)))) ->  (car ((age (old))))
(defun is-existential-expr (expr &key (fail-mode 'fail))
  (cond ((minimatch expr '(#$a ?class)))
	((minimatch expr '(#$a ?class #$with &rest)))
	((minimatch expr '(#$some ?class)))			; NEW
	((minimatch expr '(#$some ?class #$with &rest)))
	((eq fail-mode 'error)
	 (report-error 'user-error "Bad expression in subsumption testing ~a~%(Should be one of (a ?class) or (a ?class with &rest)).~%" expr))))

;;; ======================================================================
;;; Syntactic sugar: 
;;; Can say	(the (Self parts Wing parts Engine))	; the engine of a wing
;;; as well as (and equivalently)
;;;	        (the Engine with (parts-of ((a Wing with (parts-of (Self))))))
;;; ======================================================================

#|
> (path-to-existential-expr '(airplane01 parts wing))
(a wing with (parts-of (airplane01)))
> (path-to-existential-expr '(airplane01 parts wing parts edp))
(a edp with (parts-of ((a wing with (parts-of (airplane01))))))
> (path-to-existential-expr '(airplane01 parts wing parts))
(a thing with (parts-of ((a wing with (parts-of (airplane01))))))
|#
(defun path-to-existential-expr (path &optional (prep '#$a))
  (path-to-existential-expr2 (rest path) (first path) prep))

(defun path-to-existential-expr2 (path embedded-unit prep)
  (cond ((endp path) embedded-unit)
	(t  (let* ( (slot (first path))
		    (class (cond ((eq (second path) '*) '#$Thing)
				 ((second path))
				 (t '#$Thing)))
		    (rest-rest-path (rest (rest path)))
		    (preposition (cond (rest-rest-path '#$a) (t prep)))
		    (new-embedded-unit `(,preposition ,class with 
						      (,(invert-slot slot) (,embedded-unit)))) )
	      (path-to-existential-expr2 (rest (rest path)) new-embedded-unit prep)))))

;;; ======================================================================
;;;		REMOVE SUBSUMING EXPRESSIONS
;;;	This is called by (compute-new-slotsvals old-slotsvals old-slotsvals) in frame-io.lisp
;;; ======================================================================
#|
remove-subsuming-exprs:
GIVEN: 
   "exprs"     - a set of existential exprs (plus some other exprs)
   "instances" - a set of instances (plus some other exprs)

 Returns three values: 
	   - the existential exprs (plus other exprs) not subsuming any instances
	   - the instances (plus other exprs) not subsumed by any existential expr
	   - the instances which were subsumed

CL-USER> (remove-subsuming-exprs '#$((a Cat) (a Door))
				 '#$(_Door178 (a Elephant) _Bumper176))
((a Cat))
((a Elephant) _Bumper176)
(_Door178)
[1] an instance can only be subsumed by *one* expr
[2] route this query through the KM interpreter, so the user can trace it if necessary
    BUT: 9.8.99 is very confusing to the user! Hide it instead.

NOTE!! This routine should have NO SIDE EFFECTS, beyond evaluating definite paths already present.

Apr 99: What we'd also like is:
CL-USER> (remove-subsuming-exprs '#$((a Cat) (a Door) (a Elephant))
				 '#$(_Door178 (a Elephant with (size (Big))) _Bumper176))
  CURRENT IMPLEMENTATION				DESIRED 
((a Cat) (a Elephant))			 	((a Cat))				  ; non-subsumers
((a Elephant with size (Big)) _Bumper176)	(_Bumper176)				  ; non-subsumed
(_Door178)					((a Elephant with (size (Big))) _Door178) ; subsumed

[3] is more aggressive, it will cause a "hidden" instance to be actually created for purposes of testing, then discarded

[4] This extra check to ensure (a Big-Engine) "subsumes" (_Engine23). This is modifying "subsuming" to mean
    "subsumes including allowing coercion". Note that (_Engine23) and (_Engine24) still *shouldn't* result in
    any removals, ie. we're *not* doing unification.
   eg. consider (Red color-of _Engine23) then (Red color-of _Engine24) ; don't want to unify the Engines.

[4b] NOTE We have to exclude subsumption checks which include reference to Self, because the answer to the
     subsumption check depends on the instance in question!
- PC This can only come with instances entered from the user, not from lazy-unifiable-expr-sets (where bind-self has
  PC necessarily already been conducted).

[5] Clean up the junk, so as not to pollute the object stack.

[6] Incorrect behaviour: 
 ('(a Car) is '(a Car with (age ((the foo of Self)))))  -> NIL	; correct
but
 (every Car has (age ((a Thing))))
 ('(a Car) is '(a Car with (age ((the foo of Self)))))  -> t    ; incorrect!
This is because KM treats this as equivalent to 
 ((a Car) is '(a Car with (age ((the foo of Self)))))
which is wrong!!!
|#
(defun remove-subsuming-exprs (exprs instances &key allow-coercion)
 (cond ((and (tracep) (not (tracesubsumesp)))
	(suspend-trace)
	(multiple-value-bind
	 (non-subsumers non-subsumed subsumed)
	 (remove-subsuming-exprs0 exprs instances :allow-coercion allow-coercion)
	 (unsuspend-trace)
	 (values non-subsumers non-subsumed subsumed)))
       (t (remove-subsuming-exprs0 exprs instances :allow-coercion allow-coercion))))

(defun remove-subsuming-exprs0 (exprs instances &key allow-coercion)
  (cond 
   ((or (null exprs) (null instances)) (values exprs instances nil))
   (t (let* 
	  ( (subsumed-instance 
	     (cond ((or (is-existential-expr (first exprs))
			(km-triplep (first exprs)))
		    (find-if #'(lambda (instance) 
				 (cond 
				  ((is-an-instance instance)
				   (or 
;;; PC CAN I safely get rid of this expensive and 
;;; PC confusing test? -> ...turns out for big KBs, it's actually cheaper to do this test!
				       (cond ((not *new-approach*) (km `#$(,INSTANCE is ',(FIRST EXPRS)) :fail-mode 'fail)))
				       (and allow-coercion				; [4]
#| hmm...|#				    (or (is-existential-expr (first exprs))
						(km-triplep (first exprs)))		; really, should be any structured value (?)
					    (not (contains-self-keyword (first exprs)))	; [4b]
					    (km `(,instance &+ ,(first exprs)) :fail-mode 'fail)
					    )))

;					    (compatible-classes :instance1 instance
;								:classes2 (list (second expr))
;								:classes-subsumep t)
; we can get away without a tmp-i: &? just checks unifiability, with classes-subsumep constraint,
; by routing &+ through unifiable-with-existential-expr and unify-with-existential-expr.
;					    (let ( (tmp-i (km-unique (first exprs))) )
;					      (cond ((km `(,instance & ,tmp-i) :fail-mode 'fail))
;						    (t (delete-frame tmp-i) nil))))	; [5]
;				       ))

				  ((and (is-existential-expr instance)
					(not (contains-self-keyword (first exprs))))		; [6]
				   (km `#$(',INSTANCE is ',(FIRST EXPRS)) :fail-mode 'fail)))) ; NEW
			     instances))))
	    (instances0 (cond (subsumed-instance (remove subsumed-instance instances))
			      (t instances))) )
	(multiple-value-bind
	 (unused-exprs unused-instances subsumed-instances)
	 (remove-subsuming-exprs0 (rest exprs) instances0 :allow-coercion allow-coercion)
	 (cond (subsumed-instance (values unused-exprs unused-instances 
					  (cons subsumed-instance subsumed-instances)))
	       (t (values (cons (first exprs) unused-exprs) unused-instances subsumed-instances))))))))

;;; Quick lookahead for _Engine23 (a Engine) : the immediate-classes of _Engine23 must subsume or be subsumed by Engine.
;;; If this test fails, then we needn't proceed further.
;;; expr is necessarily of the form (a <class>), or (a <class> with ...)
;(defun classes-subsumep-test (instance expr)
;  (let ( (i-classes (immediate-classes instance)) 
;	 (e-classes (list (second expr))) )
;    (or (classes-subsume-classes e-classes i-classes)
;	(classes-subsume-classes i-classes e-classes))))

;(defun classes-subsumep-test (i-classes e-classes)
;  (or (equal i-classes e-classes)				; for efficiency
;      (classes-subsume-classes e-classes i-classes)
;      (classes-subsume-classes i-classes e-classes)))

;;; ======================================================================
;;; Compute most general specialization(s) of a concept description
;;; Used for KM> (the-class-of ...) expressions.
;;; Not used for now.
;;; ======================================================================

#|
The class has to be input as an instance expression.
mgs returns the most general class(es) subsumed by that expression.
The algorithm searches down the taxonomy (general-to-specific) from the
class provided, until it hits candidates. Instances are not searched.

The algorithm is similar to finding subsumed instances, except the 
candidates are classes, and we instant-ify them.

CL-USER> (mgs '#$(a Physobj with (produces (*Electricity))))
(Power-Supply)

;;; Return most general class(es) subsumed by existential-expr.
(defun mgs (existential-expr)
  (let* 
    ( (class+slotsvals (is-existential-expr existential-expr :fail-mode 'error)) 
      (class (first class+slotsvals)) )
    (cond (class (remove-duplicates (mgs2 existential-expr class))))))

;;; Return most general subclass(es) of class subsumed by existential-expr.
(defun mgs2 (existential-expr class)
  (mapcan #'(lambda (subclass)					; WAS my-mapcan - #'mapcan safe here!
	      (cond ((is0 (km-unique `#$(a ,SUBCLASS)) existential-expr) (list subclass))
		    (t (mgs2 existential-expr subclass))))	
  (km `#$(the subclasses of ,CLASS) :fail-mode 'fail)))
|#

		   



;;; FILE:  prototypes.lisp

;;; File: prototypes.lisp
;;; Author: Peter Clark
;;; Date: May 1999
;;; Purpose: Knowledge Representation using Prototypes -- the answer to life!

;;; Used for cloning itself: Don't follow these slots when cloning the prototype graph.
(defconstant *unclonable-slots* '#$(protopart-of prototype-of protoparts prototypes cloned-from definition))

;;; Used by get-slotvals.lisp. DON'T use cloning as a method for finding vals for these slots.
;(defconstant *slots-not-to-clone-for* '#$(protopart-of protoparts prototypes prototype-of #|source|# instance-of cloned-from))

;;; ----------

; (defvar *curr-prototype* nil)		; in header.lisp
(defun am-in-prototype-mode () *curr-prototype*)
(defun curr-prototype () *curr-prototype*)

(defun in-prototype    (concept) (find-unique-val concept '#$protopart-of :fail-mode 'fail))
(defun prototype-rootp (concept) (find-unique-val concept '#$prototype-of :fail-mode 'fail))
(defun prototypep (concept) 
  (or (in-prototype concept) 
      (prototype-rootp concept)))

; Not used any more.
;;; concept /= generic, but a special case of it.
;(defun qualified-prototypep (concept)
;  (and (prototype-rootp concept)
;       (find-vals concept '#$activity-type)))

;;; ======================================================================
;;;			LAZY CLONING:
;;;	We only clone prototypes which have a value for the slot of interest.
;;; ======================================================================

; No longer used - instead clone the whole prototype and unify in.
;(defun find-and-clone-valsets (instance slot)
;  (mapcar #'(lambda (clone)
;	      (find-vals clone slot))
;	  (find-and-clone-prototypes instance slot)))

;;; No result, but has side-effect of folding in prototypes
;;; [1] Slightly hacky! This prevents the prototype itself being added to the object stack as a side-effect of put-slotsvals
;;; [2] To prevent looping: (the parts of X) -> clone ProtoX -> unify X & CloneX -> (the parts of X) -> clone ProtoX etc.
;;;  		By flagging the instance as cloned-from <protos> BEFORE unification, we won't reclone while unifying.
;;;		Note the clones are already flagged as cloned-from <proto> during their creation.
;;;	We access via add-val rather than KM, to avoid it appearing in the trace.
;;; [3] :fail-mode 'fail: clone may fail if looping, where building a clone involves making assertions, which *if in prototype evironment*
;;;	will be eagerly evaluated, which may require unification, which itself may invoke cloning.
;;; [4] by adding cloned-from before unification ([2]), the unification will bring the prototype names into the current context.
;;;	So we better remove them again!
#|
;(defun unify-in-prototypes (instance slot)
;  (let* ( (prototypes (applicable-prototypes instance slot))
;	  (clones (remove nil (mapcar #'(lambda (prototype) 
;					  (prog1 
;					      (km-unique `#$(clone ,PROTOTYPE) :fail-mode 'fail) ; [3] route through query interpreter for tracing
;					    (remove-from-stack prototype)))			 ; remove side-effect, to stop looping! [2]
;				      prototypes))) )
;    (cond (clones (mapc #'(lambda (prototype) 
;			    (add-val instance '#$cloned-from prototype)) 
;			prototypes) 						; [2] install-inversesp = nil by defn of cloned-from
;		  (km (vals-to-&-expr (cons instance clones) :joiner '&!))	; route through query interpreter
;		  (mapc #'(lambda (prototype) (remove-from-stack prototype)) prototypes)   ; [4]
;		  (make-comment (km-format nil "Built clones ~a of ~a to find (the ~a of ~a)" clones prototypes slot instance))))))
|#
;;; Sequential version... This should ultimately terminate!!
;;; If slot is nil, then all prototypes are unified in. Returned result is irrelevant (nil).
(defun unify-in-prototypes (instance0 &optional slot)
  (let* ( (instance (dereference instance0))				; identity may change with each iteration
	  (prototypes (applicable-prototypes instance slot)) )
    (cond (prototypes (unify-in-prototype instance slot (first prototypes))
		      (unify-in-prototypes instance slot)))))

;;; [4] KM 1.4.0-beta32, we substantially simplified prototypes so that a prototype will never draw any external information in
;;; when building a prototype, so the problem [3] never occurs.
;;; The implementation of (obj-stack), called by remove-from-stack, is terrifyingly inefficient!!!!
;;; sequential version no longer may get into these looping problems
(defun unify-in-prototype (instance slot prototype)
  (let ( (clone (km-unique `#$(clone ,PROTOTYPE))) )				; [3] route through query interpreter for tracing
; [4]    (remove-from-stack prototype)						; remove side-effect, to stop looping! [2]
    (make-comment 
     (cond ((null slot)
	      (km-format nil "Cloned ~a~28T  -> ~a~%~43Tto find all info about ~a" prototype clone instance))
	   (t (km-format nil "Cloned ~a~28T  -> ~a~%~43Tto find (the ~a of ~a)" prototype clone slot instance))))
    (add-val instance '#$cloned-from prototype) 				; [2] install-inversesp = nil by defn of cloned-from
    (km `(,instance &! ,clone))						 	; route through query interpreter
; [4]    (remove-from-stack prototype)))
    ))


;;; We only clone prototype roots, not things which are *in* a prototype
;(defun find-and-clone-prototypes (instance slot)
;  (mapcar #'clone (applicable-prototypes instance slot)))

;;; Returns a list of prototypes which can validly provide values of slot for instance
;;; NB We must do the "already-done" test *after* the suitable-for-cloning work, because suitable-for-cloning may
;;; itself create new prototypes when doing the subsumption check!
;;; [1] If P1 and P2 are prototypes to clone, but P2 is already cloned from P1, then don't reclone P1!
;;;     I assume you can't get mutual dependencies, where P1 is cloned from P2, is cloned from P1.
(defun applicable-prototypes (instance slot)
  (remove-if-not #'(lambda (prototype) 
		     (suitable-for-cloning instance slot prototype))
		 (my-mapcan #'(lambda (class) (find-vals class '#$prototypes)) (all-classes instance))))

; No longer used
;;; Returns a list of prototypes which can provide values of slot for instance, valid for a particular context only
;(defun qualified-prototypes (instance slot)
;  (let* ( (all-classes (all-classes instance))
;	  (all-prototypes (remove-if-not #'prototypep (my-mapcan #'(lambda (class)
;								     (find-vals class '#$instances))
;								 all-classes)))
;	  (qualified-prototypes (remove-if-not #'(lambda (prototype)
;						   (find-vals prototype slot))		
;					       all-prototypes)) )
;    qualified-prototypes))

;;; Should we clone prototype to find the slot of instance?
;;; [1] This is comparing just along one dimension of "context space"
;;; [2] It's not obvious, but we only ever need to clone a prototype *once* per instance, namely in the highest supersituation in which that
;;; 	instance is an instance-of the prototype class. In any next-situations, the values will then be projected. In any new-situations,
;;;	the instance will have no known instance-of relationship, and thus the cloning wouldn't be valid anyway.
(defun suitable-for-cloning (instance slot prototype)
;  (declare (ignore slot))	; New
  (and (neq instance prototype)			; don't clone yourself!
       (prototype-rootp prototype)		; 1. Is a prototype
       (or 					; Ignore constraint 2 -- it may provide other valuable info!!
	   (null slot)
	   (some #'(lambda (subslot)		; 2. Has something to offer about the slot of interest
		     (find-vals prototype subslot))
		 (cons slot (all-subslots slot)))
	   )
       (neq prototype (curr-prototype))		; 4. don't clone curr prototype to help answer query during building curr prototype!
      (not (member prototype (get-vals instance '#$cloned-from 'own-properties *global-situation*)))	; global, as cloned-from is a non-fluent.  [2]
;       (not (member prototype (km `#$(the cloned-from of ,INSTANCE) :fail-mode 'fail))) ; allow cloned-from to project, to avoid re-cloning in all sitns
					        ; 5. do subsumption check, to make sure instance satisfies prototype's qualifications
       (km `(,instance #$is ,(find-unique-val prototype '#$definition)) :fail-mode 'fail)))

; older, pre-subsumption check version:       
;       (or (not (find-vals prototype '#$activity-type)) ; only clone if the prototype's activity |> the instances activity [1]
;	   (eq (find-vals instance '#$activity-type) (find-vals prototype '#$activity-type))
;	   (classes-subsume-classes (find-vals instance '#$activity-type) (find-vals prototype '#$activity-type)))


#|
 ======================================================================
			CLONING
A prototype is an anonymous prototype instance, connected to a network of other
instances, which can be both:
	- anonymous prototype instances
	- named instances

Cloning involves building a copy of this network, with prototype instances
replaced with new anonymous instances.

Note that cloning DOESN'T do any evaluation of expressions, they are just 
cloned as is.
 ======================================================================
|#

;(defvar *cloning* nil)

;;; clone returns the cloned instance, and (if you're interested) the mapping-alist from proto-instances to cloned-instances.
(defun clone (prototype)
 (cond ((tracep)
	(suspend-trace)
	(multiple-value-bind
	 (clone mapping-alist)
	 (clone0 prototype)
	 (unsuspend-trace)
	 (values clone mapping-alist)))
       (t (clone0 prototype))))

#|
[1] prevents trying to clone P to find info about a clone of P.
Later: instead of flagging "nil" here, I added cloned-from as a non-inverse-recording slot, to prevent this problem in general.
For example: I1 & Clone1, where Clone1 has cloned-from X, results in X being added to the object stack when the unified result
is asserted into memory and the inverses are automatically installed.

[2] This call to km causes redundant work: Suppose my clone is
	(:set
	  (_ProtoCar1 has (parts (_ProtoEngine1)))			  ; (i)
	  (_ProtoEngine1 has (parts-of (_ProtoCar1 _ProtoTransmission1))) ; (ii)
	  ...)
(i) will assert both _ProtoCar1 and the inverse link (_ProtoEngine1 parts-of _ProtoCar1)
Then at (ii), because _ProtoEngine1 already has some slotsvals, KM will merge in rather than just assert the
given slotsvals. And this merging can be computationally complex (?) [though I think my optimizations filters these out]?
But worse: If we load a prototype while in prototype mode, (<i> has <slotsvals>) will be followed by an (evaluate-paths), 
which is killingly expensive and unnecessary!

A put-slotsvals will work fine here, it will clober any old values (eg. any earlier-installed inverses), but that's
fine as the new values should necessarily include those old values.

[3] It's not clear that we really need to keep these protopart links, (they could be recomputed by a search algorithm if really
necessary). I'll leave them for now, as I went to all the trouble!.

RETURNS: two values: the clone name, and also the mappings from proto-instances to the cloned instances
|#
(defun clone0 (prototype)
;  (setq *cloning* t)
  (cond 
   ((not (prototypep prototype))
    (report-error 'user-error "Attempt to clone a non-prototype ~a!~%" prototype))
   (t
    (multiple-value-bind
     (clones mapping-alist)			; clones = list of KM expressions to build them. mappings = list of (<orig-object> . <clone>) pairs
     (build-clones prototype)				; compute what clones would look like
     (let* ( (clone-of-prototype (rest (assoc prototype mapping-alist))) ; find the clone of the ROOT instance (not its embedded instances)
; 	     (_dummy (make-comment (km-format nil "Clone of prototype ~a = ~a" prototype clone-of-prototype)))
;; No longer can do cloning from within a prototype itself
;	     (revised-clones (cond ((am-in-prototype-mode)		; If making a new prototype NEWP...
;				    (mapcar #'(lambda (clone)		; then add a note that each clone is part of NEWP...
;					      (let* ( (name+slotsvals (minimatch clone '(?name #$has &rest)))
;						      (clone-name (first name+slotsvals))
;						      (slotsvals (second name+slotsvals)) )
;						`#$(,CLONE-NAME has (protopart-of (,(CURR-PROTOTYPE))) ,@SLOTSVALS)))	; [3]
;					  clones))
;				 (t clones))) )
	     (revised-clones clones) )			; New - revisions moved into build-clone below
;      (km (cons '#$:set revised-clones))			; actually build clones [2]
;       (mapc #'(lambda (clonename+slotsvals+situation)		; expr = (<clone-name> <slotsvals> <situation>)
;		 (let ( (clone-name (first clonename+slotsvals+situation))
;			(slotsvals (second clonename+slotsvals+situation))
;			(situation (third clonename+slotsvals+situation)) )
;		   (add-slotsvals clone-name slotsvals 'own-properties t situation)))	 ; install-inverses = t; eg. (I instance-of C), we *do* need
;	     revised-clones)								 ; inverse (C instances I) installed
       (mapc #'(lambda (clonename+slotsvals)		; expr = (<clone-name> <slotsvals>)		; NEW drop <situation>
		 (let ( (clone-name (first clonename+slotsvals))
			(slotsvals (second clonename+slotsvals)) )
		   (add-slotsvals clone-name slotsvals 'own-properties t)))	 ; install-inverses = t; eg. (I instance-of C), we *do* need
	     revised-clones)								 ; inverse (C instances I) installed
;      (add-val clone-of-prototype '#$cloned-from prototype nil *global-situation*) ; install-inverses = nil [1]
       (add-val clone-of-prototype '#$cloned-from prototype) 			; install-inverses = nil [1]
       (values clone-of-prototype mapping-alist))))))				; return clone of prototype

#| ======================================================================
   build-clones: Redefined Mar 2000, rather than walking the clone graph,
   we know all the proto-instances already as they're stored on the protoparts slot of the
   clone root!
    Returns two values:
	- a list of (<clone-name> <slotsvals> <situation>) triples
	- the clone-instance mapping, a list of (<protoname> . <clone-name>) acons's.
====================================================================== |#

;;; This was originally meant to allow prototypes to include some situation-specific components, but this generates errors when cloning!

(defun build-clones (prototype)
  (let* ( (protoparts (km `#$(the protoparts of ,PROTOTYPE))) 	; includes prototype	e.g. (_ProtoCar1 _ProtoWheel2)
	  (clone-names (mapcar #'(lambda (protopart)
				   (create-instance-name (first (immediate-classes protopart))))
			       protoparts))
	  (mapping-alist (pairlis protoparts clone-names)) )		; (pairlis '(_ProtoCar1 _ProtoWheel2) '(_Car3 _Wheel4)) ->
    (values (remove nil (mapcar #'(lambda (protopart)				; 	((_ProtoCar1 . _Car3) (_ProtoWheel2 . _Wheel4))
				    (build-clone protopart mapping-alist))	; nil: some protoparts need no assertions
				protoparts))
	    mapping-alist)))

(defun build-clone (prototype mapping-alist)
  (let* ( (clone-name (rest (assoc prototype mapping-alist)))
	  (slotsvals (get-slotsvals prototype 'own-properties *global-situation*))		; now prototypes are *only* in the global situation
	  (new-slotsvals (remove-if #'(lambda (svs) 
					(member (slot-in svs) *unclonable-slots*))
				    slotsvals)) )
    (cond (new-slotsvals
	   (list clone-name (sublis mapping-alist (dereference new-slotsvals)))))))

#|
Original code...
(defun build-clones (prototype)
  (let* ( (all-situations (all-situations))			; includes dereferencing
	  (protoparts (km `#$(the protoparts of ,PROTOTYPE))) 	; includes prototype	e.g. (_ProtoCar1 _ProtoWheel2)
	  (clone-names (mapcar #'(lambda (protopart)
				   (create-instance-name (first (immediate-classes protopart))))
			       protoparts))
	  (mapping-alist (pairlis protoparts clone-names)) )		; (pairlis '(_ProtoCar1 _ProtoWheel2) '(_Car3 _Wheel4)) ->
    (values (mapcan #'(lambda (protopart)				; 	((_ProtoCar1 . _Car3) (_ProtoWheel2 . _Wheel4))
			(remove nil
				(mapcar #'(lambda (situation)
					    (build-clone protopart situation mapping-alist))
					all-situations)))
		    protoparts)
	    mapping-alist)))

(defun build-clone (prototype situation mapping-alist)
  (let* ( (clone-name (rest (assoc prototype mapping-alist)))
	  (slotsvals (get-slotsvals prototype 'own-properties situation))
	  (new-slotsvals (remove-if #'(lambda (svs) 
					(member (slot-in svs) *unclonable-slots*))
				    slotsvals)) )
    (cond (new-slotsvals
	   (let ( (situation-clone (cond ((eq situation *global-situation*) situation)
					 ((rest (assoc situation mapping-alist)))
					 (t (report-error 'user-error "Proto-instance ~a exists in a non-proto-situation ~a! (Not allowed!)~%"
						  prototype situation)))) )
	     (list clone-name (sublis mapping-alist (dereference new-slotsvals)) situation-clone))))))
|#




;;; FILE:  graph.lisp

;;; File: graph.lisp
;;; Author: Peter Clark
;;; Date: 5.25.99 modified 6.15.00 to traverse graphs breadth-first rather than depth-first
;;; Purpose: Draw out instance graphs

(defconstant *indent* 4)
(defvar *ungraphable-slots* '#$(protoparts))	; may get modified by an application

(defun graph (instance0 &optional (max-depth 10))
  (let ( (instance (dereference instance0)) )
    (cond ((not (null instance)) 
	   (graph-instances (list instance) (nodes-to-descend instance) max-depth)))
    (list instance)))

(defun graph-instances (instances to-descend max-depth &optional (situation (curr-situation)) (tab 1) (first-item t))
  (cond ((endp instances))
	(t (let* ( (instance (first instances))
		   (slotsvals (cond ((is-an-instance instance)
				     (dereference
				      (get-slotsvals instance 'own-properties situation))))) )
	     (cond ((not first-item) (km-format t "~vT" tab instance)))
	     (km-format t "~a" instance)
	     (cond ((and (> max-depth 0) 
			 (member instance (first to-descend)))
		    (format t "~%")
		    (graph-slotsvals slotsvals (rest to-descend) (1- max-depth) situation (+ tab *indent*)))
		   ((some #'(lambda (slotvals) (not (ungraphable (slot-in slotvals)))) slotsvals)
		    (format t "...~%"))
		   (t (format t "~%")))
	     (graph-instances (rest instances) to-descend max-depth situation tab nil)))))


(defun graph-slotsvals (slotsvals to-descend max-depth &optional (situation (curr-situation)) (tab 1))
  (cond ((endp slotsvals))
	(t (let* ( (slotvals (first slotsvals))
		   (slot (first slotvals))
		   (vals (second slotvals)) )
	     (cond ((not (ungraphable slot))
		    (km-format t "~vT~a: " tab slot)
		    (graph-instances vals to-descend max-depth situation (+ tab (length (symbol-name slot)) 2))
		    (graph-slotsvals (rest slotsvals) to-descend max-depth situation tab))
		   (t (graph-slotsvals (rest slotsvals) to-descend max-depth situation tab)))))))
	     
(defun ungraphable (slot)
  (or (member slot *ungraphable-slots*)
      (and (member slot *built-in-slots*)
#|except|# (not (member slot '#$(next-situation prev-situation instance-of add-list del-list))))))

(defun reverse-slotp (slot) 
  (and (> (length (symbol-name slot)) 3)
       (ends-with (symbol-name slot) *inverse-suffix*))) 		; "parts-of"

;;; ======================================================================

#|
Virus1
------
  subevents: Arrive1
	     Arrive2
	     Arrive3
	     -------
	       agent: Agent1
	       patient-of: Agent2
			   ------
	                     patient: Agent3
			     patient-of: Agent3
	     Arrive4
	     Arrive5...
|#

;;; Given an instance, return the list of values to further descend at each depth in the display.
;;; Returns a list ( (Arrive1 Arrive2 Arrive3) (Agent1 Agent2) ( ....) )
;;;		      ^^ to descend at level 0   ^^ to descend even further at level 1     etc.
;;; This is guaranteed to terminate (as the # of instances in the KB is finite).
(defun nodes-to-descend (instance &optional (situation (curr-situation)))
  (cons (list instance) (nodes-to-descend0 (list instance) situation (list instance))))

(defun nodes-to-descend0 (instances &optional (situation (curr-situation)) done)
  (let* ( (vals-to-display (remove-duplicates
			    (my-mapcan #'(lambda (instance)				; all vals in all slots of all instances
					   (cond ((kb-objectp instance)
						  (my-mapcan #'(lambda (slotvals)
								 (cond ((not (ungraphable (slot-in slotvals)))
									(vals-in slotvals))))
							     (dereference (get-slotsvals instance 'own-properties situation))))))
				       instances)))
	  (nodes-to-descend (set-difference vals-to-display done)) )
    (cond (nodes-to-descend 
	   (cons nodes-to-descend (nodes-to-descend0 nodes-to-descend situation (append vals-to-display done)))))))

;;; FILE:  think.lisp

;;; File: think.lisp :-)
;;; Author: Peter Clark
;;; Date: Dec 1999
;;; Purpose: Experimental, exhaustive forward-chaining on all instances in the object stack


(defun build (km-expr)
  (new-context)
  (let ( (seed (km-unique km-expr)) )
    (cond ((or (prototypep seed)
	       (not (anonymous-instancep seed)))
	   (km-format t "ERROR! ~a should return an anonymous instance!~%" km-expr))
	  (t (exhaustively-forward-chain)
	     (dereference seed)))))

;;; This avoids inefficient recomputing of obj-stack each time
(defun exhaustively-forward-chain (&optional (todo (obj-stack)) done)
  (cond ((endp todo)
;	 (format t ".")
	 (let ( (new-todo (set-difference (obj-stack) done)) )	
	   (cond (new-todo (exhaustively-forward-chain new-todo done)))))
	(t (let* ( (next-instance0 (first todo)) 
		   (next-instance (dereference next-instance0)) )
	     (cond ((and (not (member next-instance done))
			 (anonymous-instancep next-instance)
			 (not (prototypep next-instance)))
		    (unify-in-prototypes next-instance)))
	     (exhaustively-forward-chain (rest todo) (cons next-instance0 done))))))
;;; FILE:  loadkb.lisp

;;; File: loadkb.lisp
;;; Author: Peter Clark
;;; Date: 21st Oct 1994

(defvar *current-renaming-alist* nil)
(defvar *stats* nil)			; internal back door for keeping records

;;; ======================================================================
;;;			LOADING A KB
;;; ======================================================================

#|
load-kb Options:
   :verbose t	       		    - print out evaluation of expressions during load (useful for debugging a KB)
   :with-morphism <table> 	    - Experimental: table is a list of <old-symbol new-symbol> pairs.
				      Occurences of old-symbol are syntactically changed to new-symbol before 
				      evaluation. See note [1] below.
   :eval-instances t		    - Force recursive evaluation of the slot-val expressions on the instances. 
				      As a result, this creates the instance graph eagerly rather than lazily.
   :in-global t			    - Evaluate expressions in the global situation, not the current situation.

[1] SYMBOL RENAMING:
  This isn't quite right: a new symbol renaming table over-rides, rather than augments,
  any earlier symbol table. Also it's rather ugly with the global variable...update later...
  (load-kb "fred.km" :verbose t :with-morphism '((Node Elec-Device) (Arc Wire)))
  Symbol renaming is performed as a purely syntactic preprocessing step.
|#

;;; This prints out CPU times after loading.
;(defun load-kb+ (file &key verbose with-morphism eval-instances (in-global t))
;  (reset-statistics)
;  (reset-trace)
;  (reset-trace-depth)
;  (load-kb file :verbose verbose :with-morphism with-morphism 
;	   :eval-instances eval-instances :in-global in-global)
;  (setq *stats* (cons (list file (report-statistics)) *stats*))
;  (princ (report-statistics))
;  (terpri))

;;; This is a top-level call by the user, issued from the USER> rather than KM>
;;; prompt. As a result, we must mimic the initializations that the KM> prompt gives,
;;; and in particular CATCH any throws from the user aborting from the debugger.
(defun load-kb (file &key verbose with-morphism eval-instances)
  (reset-inference-engine)
  (let ( (answer (catch 'km-abort (load-kb0 file :verbose verbose :with-morphism with-morphism :eval-instances eval-instances))) )
    (cond ((eq answer 'km-abort) (format t "(Execution aborted)~%NIL~%"))
	  (t (km-format t "~a~%" answer))))
	     (princ (report-statistics))
	     (terpri))

;;; This is the version called from the KM> prompt or load-kb (above). 
;;; in-global is permenantly t, for now
(defun load-kb0 (file &key verbose with-morphism eval-instances (in-global t))
  (format t "Reading ~a...~%" file)
  (let ( (renaming-alist (cond (with-morphism (setq *current-renaming-alist*	
							   (triples-to-alist with-morphism))
						     *current-renaming-alist*)
			       (t *current-renaming-alist*)))
	 (stream (open file :direction :input :if-does-not-exist nil)) )
;;    (format t "DEBUG loading ~a with rename table ~a...~%" file renaming-alist)
    (cond ((null stream) (report-error 'nodebugger-error "No such file ~a!~%" file))
	  (t (cond (in-global (global-situation)))		; change to the global situation
	     (load-exprs (case-sensitive-read stream nil nil) stream verbose renaming-alist eval-instances)
	     (close stream)
	     (reset-done)			; remove all `already computed' flags
	     (cond (with-morphism (setq *current-renaming-alist* nil)))
	     (format t "~a read!~%" file))))
  t)

(defun load-exprs (expr stream &optional verbose renaming-alist eval-instances)
  (let ( (renamed-expr (rename-symbols expr renaming-alist)) )
    (cond ((null renamed-expr))
	  ((and (listp renamed-expr)
		(eq (first renamed-expr) '#$symbol-renaming-table))
	   (format t "(Symbol renaming table encountered and will be conformed to)~%")
	   (load-exprs (case-sensitive-read stream nil nil) 
		         stream verbose (triples-to-alist (second renamed-expr)) eval-instances))
	  (t (let ( (results (cond (verbose (print-km-prompt)
					   (km-format t " ~a~%" renamed-expr)
					   (km+ renamed-expr :fail-mode *top-level-fail-mode*))
				  (t (km renamed-expr :fail-mode *top-level-fail-mode*)))) )
	       (cond ((or eval-instances (am-in-prototype-mode))
		      (eval-instances results))))
	     (load-exprs (case-sensitive-read stream nil nil) 
			 stream verbose renaming-alist eval-instances)))))

(defun rename-symbols (expr renaming-alist) (sublis renaming-alist expr))

;;; '((1 -> a) (2 -> b)) -> ((1 . a) (2 . b))
;;;	                      ^   ^
;;;		           local global 
;;; We do this conversion so that we can use built-in sublis to do the symbol renaming.
(defun triples-to-alist (triples) 
  (cond ((quotep triples) (triples-to-alist (unquote triples)))
	((or (not (listp triples))
	     (not (every #'(lambda (x) (and (triplep x)
					    (symbolp (first x))
					    (eq (second x) '->)))
;					    (symbolp (third x))))
			 triples)))
	 (report-error 'nodebugger-error 
		       ":with-morphism: renaming table should be a list of triples of the form~% ((OldS1 -> NewS1) (OldS2 -> NewS2) ...)~%"))
	(t (mapcar #'(lambda (triple) 
	      (cond ((not (triplep triple))
		     (report-error 'nodebugger-error 
				   "Non-triple found in the symbol renaming table!~%Non-triple was: ~a. Ignoring it...~%" triple))
		    (t (cons (first triple) (third triple)))))
		   triples))))

;;; ----------------------------------------
;; Useful macro, callable from top-level prompt.
(defun reload-kb (file &key verbose with-morphism eval-instances)
  (reset-kb)
  (load-kb file :verbose verbose 
	        :with-morphism with-morphism 
		:eval-instances eval-instances))

;;; Same, callable from within KM
(defun reload-kb0 (file &key verbose with-morphism eval-instances)
  (reset-kb)
  (load-kb0 file :verbose verbose 
	        :with-morphism with-morphism 
		:eval-instances eval-instances))



;(defun reload-kb+ (file &key verbose with-morphism eval-instances (in-global t))
;  (reset-kb)
;  (load-kb+ file :verbose verbose 
;	        :with-morphism with-morphism 
;		:eval-instances eval-instances
;		:in-global in-global))

;;; For my own bench-marking purposes
(defun out-it (file)
  (let ( (stream (tell file)) )
	(mapcar #'(lambda (file+speed) 
		    (format stream "~a~60vT~a" (first file+speed) (second file+speed))) 
		*stats*)
	(close stream)))

;;; ======================================================================
;;;		LOWEST-LEVEL ACCESS TO THE PROPERTY LISTS
;;; ======================================================================

;;; Converted to using hash table for KB-objects thanks to Adam Farquhar
(defvar *kb-objects* (make-hash-table :test #'eq))

(defun getobj (name facet)
  (cond ((and (not (member facet *all-facets*))
	      (not (isa-situation-facet facet)))
	 (report-error 'program-error "(getobj ~a ~a) Don't recognize facet ~a!~%(Should be one of ~a)~%"
		       name facet facet *all-facets*))
	((kb-objectp name)   
	 (increment-count '*kb-access*)
	 (get name facet))
	((is-km-term name) nil)		; Valid get, but no attributes. This includes 1 'a "12" (:seq a b c) #'+ (:set a b c)
	(t (report-error 'program-error "Accessing frame ~a - the frame name `~a' should be an atom!~%" name name))))

;;; To DELETE an object, now use delete-frame (above).
;;; (putobj nil won't remove object from *kb-objects*)
(defun putobj (fname slotsvals facet)
  (cond ((and (not (member facet *all-facets*)) 
	      (not (isa-situation-facet facet)))
	 (report-error 'program-error "(putobj ~a ~a) Don't recognize facet ~a!~%(Should be one of ~a)~%" fname facet facet *all-facets*))
	(slotsvals ; (setf (get fname facet) slotsvals)        ;put it on the p-list
		   (make-transaction `(setf ,fname ,facet ,slotsvals))        ;put it on the p-list
		   (cond ((not (gethash fname *kb-objects*))
			  ; (setf (gethash fname *kb-objects*) t)
			  (make-transaction `(add-to-kb ,fname))
			  )))
	(t (remprop fname facet))))

#|
 ======================================================================
 	TRANSACTION PROCESSOR - ROUTE ALL LOW-LEVEL DATA I/O THROUGH HERE
 EXCEPT: 
   - note-done operations (for now), as these are just temporary flags
   - caching of facet + situation symbol concatenations (in curr-situation-facet)
   - optimization flags, such as *are-some-constraints*, *are-some-subslots*, etc.
   - tracing flags
   - the goal stack *km-stack*
   - statistics counters
   - the *check-kb* flag

This is paving the way for a roll-back mechanism in KM
 ======================================================================

TRANSACTION			EXECUTION
(setf frame facet slotsvals)    (setf (get frame facet) slotsvals)
(add-to-kb fname)		(setf (gethash fname *kb-objects*) t)
(bind frame1 frame2)		(setf (get frame1 'binding) frame2)
(setf parent defined-children-facet children)
				(setf (get parent defined-children-facet) children)
(setq var val)			(setq var val)
|#

(defun make-transaction (transaction)
  (case (first transaction)
	(setf	    (setf (get (second transaction) (third transaction)) (fourth transaction)))
	(add-to-kb  (setf (gethash (second transaction) *kb-objects*) t))
	(bind       (setf (get (second transaction) 'binding) (third transaction)))
	(setq	    (case (second transaction)
			  (*default-fluent-status* (setq *default-fluent-status* (third transaction)))
			  (*curr-situation* (setq *curr-situation* (third transaction)))
			  (*curr-prototype* (setq *curr-prototype* (third transaction)))
			  (*classes-using-assertions-slot* (setq *classes-using-assertions-slot* (third transaction)))
			  (*obj-stack* (setq *obj-stack* (third transaction)))
			  (*top-level-fail-mode* (setq *top-level-fail-mode* (third transaction)))
			  (t (report-error 'program-error "make-transaction: Attempt to setq unrecognized variable ~a!" (second transaction)))))
	(t (report-error 'program-error "make-transaction: Unrecognized transaction type ~a!" transaction))))

;;; ======================================================================

;;; NEW (using hash table)
(defun get-all-objects ()
  (let ((results nil))
    (maphash #'(lambda (k v)
               (declare (ignore v))
               (push k results))
            *kb-objects*)
    results))

(defun delete-frame-structure (fname) 
  (remprops fname) 
  (remhash fname *kb-objects*)
  fname)

;;; Rename this from "exists"; it really means fname is a known frame (Is an error to try this check for numbers and strings)
(defun known-frame (fname)
  (cond ((kb-objectp fname)
	 (or (gethash fname *kb-objects*)
	     (built-in-concept fname)))
	(t (report-error 'program-error "known-frame: Attempt to check if a non kb-object ~a is a frame!~%" fname))))

;; --------------------

(defun reset-kb ()
  (global-situation)
  (instance-of-is-nonfluent)			; set it back
  (format t "Resetting KM...~%")
  (mapc #'(lambda (frame) (delete-frame-structure frame))
	(get-all-objects))  	
  (clear-obj-stack)
  (setq *curr-prototype* nil)
  (setq *classes-using-assertions-slot* nil)	; optimization flag
  (setq *are-some-subslots* nil)		; optimization flag
  (setq *are-some-prototypes* nil)		; optimization flag
  (setq *are-some-definitions* nil)		; optimization flag
  (setq *are-some-constraints* nil)		; optimization flag
  (setq *default-fluent-status* *default-default-fluent-status*)
; (reset-inference-engine)		; no, want to keep inference counter going!
  (clear-km-stack)
  (reset-trace)
  (reset-trace-depth)
  (reset-done)
  t)

(defun reset-inference-engine ()
  (clear-km-stack)
  (reset-statistics)
  (reset-trace)
  (reset-trace-depth)
  (reset-done))

;;; ======================================================================
;;;			SAVING A KB
;;; ======================================================================

(defun save-kb (file)
  (let ( (stream (tell file)) )
    (write-kb stream)
    (close stream)
    (format t "~a saved!~%" file) t))

(defun write-kb-here () 
  (write-kb *standard-output* 
	    (remove-if #'(lambda (obj) 
;			   (or (built-in-concept obj)
			   (not (has-situation-specific-info obj (curr-situation))))
		       (get-all-objects))
	    (list (curr-situation))))

(defun write-kb (&optional (stream *standard-output*) (objects (get-all-objects)) situations0)
  (cond 
   ((and (not (streamp stream))
	 (not (eq stream t)))
    (report-error 'nodebugger-error 
		  "write-kb given a non-stream as an argument!~%(Use (save-kb \"myfile\") to save KB to the file called \"myfile\")~%"))
   (t (let ( (situations (or situations0 (all-situations))) )
	(format stream "~%;;; Current state of the KB (~a, KM ~a)~%" (now) *km-version*)
	(cond ((singletonp situations0) (km-format stream ";;; Showing data for situation ~a only.~%~%" (first situations0)))
	      (situations0 (km-format stream "Showing data for situations ~a only.~%~%" situations0))
	      (t (format stream "~%(reset-kb)~%")
		 (cond (*are-some-definitions* (km-format stream "~%(disable-classification)     ;;; (Temporarily disable while rebuilding KB state)~%")))
		 (cond (*built-in-inertial-fluent-slots* (km-format stream "~%(instance-of-is-fluent)~%")))
		 (format stream "~%;;; ----------~%~%")
		 ))
	(let ( (nconcepts 
		   (length 
	 	       (remove nil 
			      (mapcar #'(lambda (concept)
					  (cond ((not (bound concept))
						 (princ (write-frame concept situations) stream) 
						 (princ ";;; ----------" stream) 
						 (terpri stream) 
						 (terpri stream) t)))
				      (sort-objects-for-writing objects))))) )
	  (write-state-variables stream)
	  (format stream ";;; --- end (~a frames written) ---~%~%"  nconcepts))))))

;;; Various variables about the current state, to write back so we can pick up 
;;; where we left off if we reload...
;;; [1] The commented-out parameters will be reset automatically at KB reload time.
(defun write-state-variables (&optional (stream t))
  (cond ((or *obj-stack* *curr-prototype*
	     *are-some-prototypes* *are-some-definitions*
	     (neq *default-fluent-status* *default-default-fluent-status*)
	     (am-in-local-situation))
	 (km-format stream "
;;; ----------------------------------------
;;;	STATE-SPECIFIC PARAMETER VALUES
;;; ----------------------------------------

")
	 (cond (*obj-stack* (km-format stream "(SETQ *OBJ-STACK*~% '~a)~%" (dereference *obj-stack*))))
	 (cond (*curr-prototype* (km-format stream "(SETQ *CURR-PROTOTYPE* '~a)~%" (dereference *curr-prototype*))))
; [1]
;        (cond (*classes-using-assertions-slot* (km-format stream "(SETQ *CLASSES-USING-ASSERTIONS-SLOT* '~a)~%" (dereference *classes-using-assertions-slot*))))
;        (cond (*are-some-subslots* (km-format stream "(SETQ *ARE-SOME-SUBSLOTS* '~a)~%" *are-some-subslots*)))
	 (cond (*are-some-prototypes* (km-format stream "(SETQ *ARE-SOME-PROTOTYPES* '~a)~%" *are-some-prototypes*)))
;        (cond (*are-some-definitions* (km-format stream "(SETQ *ARE-SOME-DEFINITIONS* '~a)~%" *are-some-definitions*)))
;        (cond (*are-some-constraints* (km-format stream "(SETQ *ARE-SOME-CONSTRAINTS* '~a)~%" *are-some-constraints*)))
	 (cond ((neq *default-fluent-status* *default-default-fluent-status*)
		(km-format stream "(default-fluent-status ~a)~%" *default-fluent-status*)))
	 (cond (*are-some-definitions* (km-format stream "~%(enable-classification)     ;;; (Re-enable it after restoring KB state)~%")))
	 (cond ((am-in-local-situation) (km-format stream "~%(in-situation ~a)~%" (curr-situation))))	 
	 (km-format stream "~%"))
	(t (km-format stream "
;;; (There are no state-specific parameter values)

"))))

;;; ------------------------------

; [1] copy-seq as sort is destructive!
; [2] When reading (in-situation <S> ...) KM will check S is a situation, we
;     must ensure Situations are written out *first* so the check is passed at reload time.
(defun sort-objects-for-writing (objects)
  (let* ( (prototypes (km '#$(the prototypes of (the all-subclasses of Thing)) :fail-mode 'fail))
	  (situation-classes (cond ((member '#$Situation objects) (cons '#$Situation (all-subclasses '#$Situation)))))
	  (situation-instances (remove-if-not #'(lambda (situation)		; [2]
						  (isa situation '#$Situation))
					      objects))
	  (rest-objects (set-difference objects (append prototypes situation-classes situation-instances))) )
    (append (sort (copy-seq situation-classes) #'string-lessp)			
	    (sort (copy-seq situation-instances) #'string-lessp)			
	    (sort (copy-seq prototypes) #'string-lessp)			
	    (sort (copy-seq rest-objects) #'string-lessp))))

;;; ======================================================================
;;;		FAST-LOADING OF FILES
;;; ======================================================================

#|
These fast-loading functions directly access the KB database, rather than through
calls to KM. This fast-loading is limited:
  (i) no inverses are installed. This includes subclass-superclass links!!
  (ii) detecting of redundant assertions by checking for duplicates, rather
	than subsumees.
  (iii) all slots asssumed multivalued
|#

(defun fastload-kb (km-file)
  (format t "Fast-loading ~a...~%" km-file)
  (let ( (stream (see km-file)) )
    (loop while (fastload-expr (case-sensitive-read stream nil nil)))
    (close stream))
  (format t "~a read!~%" km-file))

(defun fastload-expr (item)
  (cond ((null item) nil)
	((not (eq (second item) '#$has)) 
	 (report-error 'nodebugger-error "fastload-kb doesn't know how to process expression ~a! Ignoring it...~%" item) 
	 t)    ; t to continue to next item
	(t (fast-add-slotsvals (first item) (rest (rest item))))))

;;; Faster version of frame-io.lisp routine
(defun fast-add-slotsvals (instance add-slotsvals)
  (let* ( (old-slotsvals (get instance 'own-properties))
	  (new-slotsvals (fast-compute-new-slotsvals old-slotsvals add-slotsvals)) )
    (cond ((equal old-slotsvals new-slotsvals))      ; no changes needed
	  (t (setf (get instance 'own-properties) new-slotsvals)
	     (cond ((not (gethash instance *kb-objects*))
		    (setf (gethash instance *kb-objects*) t))))))
  instance)

(defun fast-compute-new-slotsvals (old-slotsvals add-slotsvals)
  (cond ((null old-slotsvals) add-slotsvals)
	(t (let* ( (old-slotvals (first old-slotsvals))
		   (slot	 (slot-in old-slotvals))
		   (old-vals	 (vals-in old-slotvals))
		   (add-vals	 (vals-in (assoc slot add-slotsvals)))
		   (extra-vals   (ordered-set-difference add-vals old-vals :test #'equal))
		   (new-vals 	 (append old-vals extra-vals)) )	; faster than subsumption checks in frame-io.lisp
     	     (cons (make-slotvals slot new-vals)
		   (fast-compute-new-slotsvals (rest old-slotsvals)
					       (remove-if #'(lambda (sv) 
							      (eq (car sv) slot)) 
							  add-slotsvals)))))))

;;; FILE:  minimatch.lisp

;;; File: minimatch.lisp
;;; Author: Peter Clark
;;; Date: August 1994
;;; Purpose: Simplistic pattern-matching (see examples below)
;;; The system matches items with variables, returning a list of the
;;; matched items. All variables are anonymous.

;;; Mini-matching -- doesn't keep an explicit binding list, but just the
;;; values which matched with variables, in order.
;;; (minimatch 'x 'y) => nil
;;; (minimatch '(a b c) '(a ?x ?y)) => (b c)
;;; (minimatch '(a b c) '(a ?x ?x)) => (b c)
;;; (minimatch '(a b) '(a b)) => t
;;; (minimatch '(a b c (d e)) '(a b ?x (?y ?z))) => (c d e)
;;; (minimatch '(a b c (d e)) '(a b ?x ?y)) => (c (d e))
;;; (minimatch '(a b c (d e)) '(a b &rest) => ((c (d e)))

(defun mv-minimatch (item pattern)
  (values-list (minimatch item pattern)))

;;; Must distinguish failure (nil) and no bindings (t)
(defun minimatch (item pattern)
   (cond 
      ((varp pattern) (list item))
      ((equal pattern '(&rest)) (list item))
      ((varp item) 't)				; var in item matches any, but not added
      ((atom pattern)				; to binding list.
       (cond ((equal item pattern) 't)))
      ((and (listp item) (not (null item)))
       (let ( (carmatch (minimatch (car item) (car pattern))) )
	    (cond (carmatch
		   (join-binds carmatch
			       (minimatch (cdr item) (cdr pattern)))))))))

(defun join-binds (binds1 binds2)
   (cond ((null binds1) nil)
	 ((null binds2) nil)
         ((equal binds1 't) binds2)
	 ((equal binds2 't) binds1)
	 (t (append binds1 binds2))))


#|
;;; Cache the common variable names in km/interpreter.lisp for efficiency...
(defconstant *cached-variable-names*
  '(?frame ?frameadd ?expr ?exprs ?slot ?class ?f ?s ?v ?name ?condition 
    ?action ?x ?y ?set ?constraint ?value ?test ?lispcode ?command ?path
    ?lispcode ?future-pointing-slot ?action-expr
    ?situation-expr ?val-expr ?slot-expr ?frame-expr ?ys ?constraint
    ?value ?test ?set ?altaction ?action ?condition ?y ?frameadd ?slot
    ?cexpr ?a ?class ?km-expr ?expr1 ?expr ?xs ?x ?frame ?path
    ?instance-expr))

SLOW - obsolete now
(defun varp (var)
  (and (symbolp var)
       (or (member var *cached-variable-names*)
	   (char= (first-char (string var)) #\?)))

;;; Adam Farquhar's faster version, with type-checking
(defun varp (var)
  (and (symbolp var)
       (char=
       #\?
       (char (the string (symbol-name (the symbol var))) 0))))
|#

;;; Modified faster version thanks to Adam Farquhar!
(defun varp (var)
  (and (symbolp var)
       (symbol-starts-with var #\?)))

(defun find-pattern (list pattern)
  (cond ((endp list) nil)
	((minimatch (first list) pattern))
	(t (find-pattern (rest list) pattern))))

;;; ======================================================================
;;;	USE OF THE MINIMATCHER TO SELECT A LAMBDA EXPRESSION
;;; ======================================================================

;;; find-handler -- returns the function and argument list to handle an expr
;;; (find-handler '(the house of john) *km-handler-alist*) =>
;;;    (#'(lambda (slot path) (getval slot path)) (house john))

(defun find-handler (expr handler-alist &key (fail-mode 'warn))
  (cond ((endp handler-alist)
	 (cond ((eq fail-mode 'warn)
		(format t "ERROR! Can't find handler for expression ~a!~%"
			expr) nil)))
	(t (let* ( (pattern+handler (first handler-alist))
		   (pattern (first  pattern+handler))
		   (handler (second pattern+handler))
		   (bindings (minimatch expr pattern)) )
	     (cond ((eq bindings 't) (list handler nil))
		   (bindings (list handler bindings))
		   (t (find-handler expr (rest handler-alist) :fail-mode fail-mode)))))))

;;; Default method of applying
;;; Or could apply with extra args, eg.
;;; 	(apply (first handler) (cons depth (second handler)))
(defun apply-handler (handler) 
  (apply (first handler) (second handler)))

(defun find-and-apply-handler (expr handler-alist &key (fail-mode 'warn))
  (let ( (handler (find-handler expr handler-alist :fail-mode fail-mode)) )
    (cond (handler (apply-handler handler)))))
  
;;; ======================================================================
;;;		SAME, EXCEPT FOR STRINGS
;;; ======================================================================

(defun mv-string-match (string pattern)
  (values-list (string-match string pattern)))

;;; (string-match "the cat sat" '("the" ?cat "sat")) --> (" cat ")
;;; (string-match "the cat sat" '(?var "the" ?cat "sat")) --> ("" " cat ")
(defun string-match (string pattern)
  (let ( (pattern-el (first pattern)) )
    (cond ((and (null pattern) (string= string "")) 't)
          ((stringp pattern-el)
	   (cond ((string= string pattern-el :end1 (length pattern-el))
		  (string-match (subseq string (length pattern-el))
				(cdr pattern)))))
	  ((and (varp pattern-el)
		(singletonp pattern)) (list string))
	  ((and (varp pattern-el)
		(stringp (second pattern)))
	   (let ( (end-string-posn (search (second pattern) string)) )
	     (cond (end-string-posn
		    (cons-binding
		     (subseq string 0 end-string-posn)
		     (string-match (subseq string
					 (+ end-string-posn
					    (length (second pattern))))
				   (cddr pattern)))))))
	  (t (format t "ERROR! (string-match ~s ~s) bad syntax!~%"
		     string pattern) nil))))

;;; binding or bindings = nil imply match-failure
(defun cons-binding (binding bindings)
  (cond ((null bindings) nil)
	((null binding) nil)
	((equal bindings 't) (list binding))
	(t (cons binding bindings))))

;;; FILE:  utils.lisp

;;; File: utils.lisp
;;; Author: Peter Clark
;;; Date: 1994
;;; Purpose: General Lisp utilities

;;; (flatten '((a b) (c (d e))))  ->  (a b c d e)
;;; (flatten 'a) -> (a)
(defun flatten (list)
  (cond ((null list) nil)
	((atom list) (list list))
	(t (my-mapcan #'flatten list))))

;;; ----------

(defun listify (atom)
   (cond ((listp atom) atom)
	 (t (list atom))))

;;; (append-list '((1 2) (3 4))) => (1 2 3 4)
(defun append-list (list) (apply #'append list))

;;; ----------------------------------------

#|
;;; (my-split-if '(1 2 3 4) #'evenp) => ((2 4) (1 3))
;;; (mapcar #'append-list (transpose (mapcar #'(lambda (seq) (my-split-if seq #'evenp)) '((1 2 3 4) (5 6 7 8) ...))))
;;; [PEC: ?? but why not just do (my-split-if (append '((1 2 3 4) (5 6 7 8) ...)) #'evenp) ?
;;; ((2 4 6 8) (1 3 5 7))
(defun my-split-if (sequence function)
  (cond ((endp sequence) nil)
	(t (let ( (pass+fail (my-split-if (rest sequence) function)) )
	     (cond ((funcall function (first sequence))
		    (list (cons (first sequence) (first pass+fail)) (second pass+fail)))
		   (t (list (first pass+fail) (cons (first sequence) (second pass+fail)))))))))
|#

;;; Rewrite and rename. This time, returns multiple values (i) those passing the text (ii) those failing
;;; (partition '(1 2 3 4) #'evenp) => (2 4) (1 3)
;;; ((2 4 6 8) (1 3 5 7))
(defun partition (sequence function)
  (cond ((endp sequence) nil)
	(t (multiple-value-bind 
	    (pass fail)
	    (partition (rest sequence) function)
	    (cond ((funcall function (first sequence))
		   (values (cons (first sequence) pass) fail))
		  (t (values pass (cons (first sequence) fail))))))))

;;; ======================================================================
;;;			SOME *-EQUAL FUNCTIONS
;;; ======================================================================

;;; unlike assoc, item can be a structure
;;; > (assoc-equal '(a b) '(((a b) c) (d e)))
(defun assoc-equal (item alist)
  (cond ((endp alist) nil)
	((equal item (first (first alist))) (first alist))
	(t (assoc-equal item (rest alist)))))

(defun member-equal (item list)
  (cond ((endp list) nil)
	((equal item (first list)) list)
	(t (member-equal item (rest list)))))

;;; ======================================================================
;;;		MAPPING FUNCTIONS
;;; ======================================================================

;;; my-mapcan: non-destructive version of mapcan
(defun my-mapcan (function args)
  (apply #'append (mapcar function args)))

;; eg. (map-recursive #'string-upcase '("as" ("asd" ("df" "df") "ff")))
;;     ("AS" ("ASD" ("DF" "DF") "FF"))
(defun map-recursive (function tree)
  (cond ((null tree) nil)
	((not (listp tree)) (funcall function tree))
	(t (cons (map-recursive function (car tree))
		 (map-recursive function (cdr tree))))))

;;; ----------------------------------------

#|
KM> (defun demo (x) (cond ((> x 0) (values x (* x x)))))
KM> (some #'demo '(-1 3 2))
3
KM> (multiple-value-some #'demo '(-1 3 2))
3
9
|#
;;; This just written for two-valued arguments
(defun multiple-value-some (fn arg-list)
  (cond ((endp arg-list) nil)
	(t (multiple-value-bind
	       (x y)
	       (apply fn (list (first arg-list)))
	     (cond (x (values x y))
		   (t (multiple-value-some fn (rest arg-list))))))))

;;; ======================================================================
;;;		GENERAL UTILITIES
;;; ======================================================================

(defvar *tell-stream* t)
(defvar *see-stream* t)
(defvar *append-stream* t)

;;; Check you don't close the stream "t"
(defun close-stream (stream) (cond ((streamp stream) (close stream))))

;;; (see) and (tell) open files with my standard default modes.
;;; They also cache the stream, just in case an error occurs during
;;; interpretation (otherwise you've lost the handle on the stream).
;;; t will send to std output, nil will output to nothing.
(defun tell (file) 
  (cond ((null file) nil) 
	((eq file t) (format t "(Sending output to standard output)~%") t)
	(t (setq *tell-stream* (open file
			    :direction :output
			    :if-exists :supersede
			    :if-does-not-exist :create)))))

(defun told () (close-stream *tell-stream*) (setq *tell-stream* t))

(defun see (file) (setq *see-stream* (open file :direction :input)))

(defun seen () (close-stream *see-stream*) (setq *see-stream* t))

(defun tell-append (file) 
  (cond ((null file) nil) 
	((eq file t) (format t "(Sending output to standard output)~%") t)
	(t (setq *append-stream* (open file
				    :direction :output
				    :if-exists :append
				    :if-does-not-exist :create)))))

(defun told-append () (close-stream *append-stream*) (setq *append-stream* t))

;;; Useful for finding mis-matching parentheses
(defun read-and-print (file)
  (let ( (stream (see file)) )
    (read-and-print2 stream)
    (close stream)))

(defun read-and-print2 (stream)
  (let ( (sexpr (read stream nil nil)) )
    (cond (sexpr (print sexpr) (read-and-print2 stream)))))

;;; Bug(?) in CL: (read-string <string> nil nil) should return nil if <string> is an incomplete s-expr (e.g. "\""cat")
;;; but in practice generates an eof error regardless. (What I wanted to do was a read-string followed by integerp test).
(defun my-parse-integer (string)
  (multiple-value-bind
   (integer n-chars)
   (parse-integer string :junk-allowed t)
   (cond ((eq (length (princ-to-string integer)) n-chars) integer))))

;;; ----------------------------------------
;;; 	READ AN ENTIRE FILE INTO A LIST:
;;; ----------------------------------------
;;; Returns a list of strings
(defun read-file (file &optional (type 'string)) 
  (cond ((not (member type '(string sexpr case-sensitive-sexpr)))
	 (format t "ERROR! Unrecognized unit-type ~s in read-file!~%" type))
	(t (read-stream (see file) type))))

(defun read-stream (stream &optional (type 'string))
  (prog1
      (read-lines (read-unit stream type) stream type)
    (close stream)))

(defun read-lines (line &optional (stream t) (type 'string))
  (cond ((null line) nil)
	(t (cons line (read-lines (read-unit stream type) stream type)))))

(defun read-unit (&optional (stream t) (type 'string))
  (case type
	(string (read-line stream nil nil))
	(sexpr  (read      stream nil nil))
	(case-sensitive-sexpr (case-sensitive-read stream nil nil))))	; defined in case.lisp

;;; ------------------------------

(defun write-file (file lines)
  (let ( (stream (tell file)) )
    (write-lines lines stream)
    (close-stream stream)))

#|
;;; Works, but apply-recursive can be *very* slow as it's interpreted
(defun write-lines (lines &optional (stream t))
  (apply-recursive #'(lambda (line)
		       (format stream "~a~%" line))
		   lines))
|#

(defun write-lines (structure &optional (stream t))
  (cond
   ((null structure) nil)
   ((atom structure) (format stream "~a~%" structure))
   ((and (listp structure)
	 (null (first structure)))
    (write-lines (rest structure) stream))
   ((listp structure)
    (cons (write-lines (first structure) stream)
	  (write-lines (rest structure) stream)))
   (t (format t "ERROR! Don't know how to do write-lines on structure:~%")
      (format t "ERROR! ~s~%" structure))))



;(defun write-lines (lines &optional (stream t))
;  (cond
;   ((null lines))
;   ((atom lines) (format stream "~a~%" lines))
;   ((listp lines)
;    (write-lines (car lines) stream)
;    (write-lines (cdr lines) stream))
;   (t (format t "ERROR! Don't know how to do write-lines on structure:~%")
;      (format t "ERROR! ~s~%" lines))))

; ----------

(defun apply-recursive (function structure)
  (cond
   ((null structure) nil)
   ((atom structure) (funcall function structure))
   ((listp structure)
    (cons (apply-recursive function (first structure))
	  (apply-recursive function (rest structure))))
   (t (format t "ERROR! Don't know how to apply-recursive on structure:~%")
      (format t "ERROR! ~s~%" structure))))

;;; ======================================================================

(defun print-list (list) (mapcar #'print list) t)

(defun neq (a b) (not (eq a b)))

;;; (nlist 3) --> (1 2 3)
(defun nlist (nmax &optional (n 1))
  (cond ((<= nmax 0) nil)
	((>= n nmax) (list n))
	(t (cons n (nlist nmax (1+ n))))))

;;; (duplicate 'hi 2) ==> (hi hi)
(defun duplicate (item length)
  (make-sequence 'list length :initial-element item))

; Better: use ~vT directive in format
; BUT!! Bug under Harlequin - column counter doesn't get reset by a <nl> from
; user (as a result of a read-line or read).
(defun spaces (n)
  (make-sequence 'string n :initial-element #\ ))
;
; (defun tab (n &optional (stream t))
;    (cond ((<= n 0) t)
;          ( t (format stream " ") (tab (- n 1) stream))))

;;; ======================================================================

(defun transpose (list)
  (cond ((every #'null list) nil)
	(t (cons (mapcar #'first list) 
		 (transpose (mapcar #'rest list))))))

;;; ======================================================================


;;; 22nd Aug: had to rewrite this. Checking the cadr is non-null doesn't
;;; reliably test there's a second element (eg. if the 2nd el is nil).

(defun singletonp (list) (and (listp list)(eq (length list) 1)))
(defun      pairp (list) (and (listp list)(eq (length list) 2)))

; triple has different repn in KM, namely with a :triple prefix
(defun    triplep (list) (and (listp list)(eq (length list) 3)))

;;; ======================================================================

;;; (a) -> a
(defun delistify (list)
   (cond ((singletonp list)(car list))
	 (t list)))

(defun last-el (list) (car (last list)))

(defun last-but-one-el (list) (car (last (butlast list))))

;;; ======================================================================

;;; (quotep ''hi) --> t
(defun quotep (expr)
  (cond ((and (listp expr) (eq (length expr) 2) (eq (car expr) 'quote)))))

;;; ======================================================================

;;; Preserve order of list
;;; (The basic Lisp function is set-difference)
(defun ordered-set-difference (list set &key (test #'eq))
  (remove-if #'(lambda (el) (member el set :test test)) list))

;;; Preserve order of first list
(defun ordered-intersection (list set &key (test #'eq))
  (remove-if-not #'(lambda (el) (member el set :test test)) list))

;;; Returns the first elememt of set1 which is in set2, or nil otherwise.
(defun intersects (set1 set2)
  (first (some #'(lambda (el) (member el set2)) set1)))

;;; ======================================================================
;;;		DICTIONARY FUNCTIONS
;;; ======================================================================

;;; Inefficient but non-destructive!
;;; KM> (gather-by-key '((a 1) (b 2) (a 3) (b 4)))
;;; ((b (4 2)) (a (3 1)))
;;; KM> (gather-by-key '((a 1) (b 2) (a 3) (b 4) (c) (b)))
;;; ((b (4 2)) (a (3 1)) (c ()))
(defun gather-by-key (pairs &optional dict)
  (cond ((endp pairs) dict)
	(t (let* ((pair (first pairs))
		  (key (first pair))
		  (val (second pair))
		  (vals (first (rest (assoc key dict :test #'equal))))
		  (restdict (remove-if #'(lambda (pair) (equal (first pair) key)) dict)))
	     (cond (val (gather-by-key (rest pairs)
				       (cons (list key (cons val vals)) restdict)))
		   (t (gather-by-key (rest pairs)
				     (cons (list key vals) restdict))))))))

;;; (ordered-gather-by-key '((a 1) (a 2) (b 3) (b 4) (c 5) (a 6) (a 7) (d 8)))
;;;	-> ((a (1 2)) (b (3 4)) (c (5)) (a (6 7)) (d (8)))
;;; NOTE duplicate (a ...) entries, if (a ...) entries aren't consecutive
(defun ordered-gather-by-key (pairs)
  (cond ((endp pairs) nil)
	(t (let ( (pair (first pairs)) )
	     (cond ((equal (first pair) (first (second pairs)))
		    (let* ( (gathered-rest (ordered-gather-by-key (rest pairs)))
			    (next-gathered-pair (first gathered-rest)) )
		      (cons (list (first next-gathered-pair) 			; pair = (a x), next-gathered-pair (a (d e)) -> (c (x d e))
				  (cons (second pair) (second next-gathered-pair)))
			    (rest gathered-rest))))
		   (t (cons (list (first pair) (rest pair))		; (a b) -> (a (b))
			    (ordered-gather-by-key (rest pairs)))))))))

;;; Takes an *ordered* list of items, and counts occurences of each one.
;;; (ordered-count '("a" "a" "b" "c")) -> (("a" 2) ("b" 1) ("c" 1))
(defun ordered-count (list &optional counts-so-far)
  (cond ((endp list) (reverse counts-so-far))
	((equal (first list) (first (first counts-so-far)))
	 (ordered-count (rest list) (cons (list (first list) (1+ (second (first counts-so-far))))
					  (rest counts-so-far))))
	(t (ordered-count (rest list) (cons (list (first list) 1) counts-so-far)))))

;;; ----------
				  
(defun number-eq (n1 n2)
  (and (numberp n1) 
       (numberp n2) 
       (<= (- n1 n2)  0.0000001)
       (>= (- n1 n2) -0.0000001)))


(defun list-intersection (list)
  (cond ((null list) nil)
	((singletonp list) (first list))
	(t (list-intersection (cons (intersection (first list) 
						  (second list)) 
				    (rest (rest list)))))))

;;; ----------

;;; (rank-sort list rank-function)
;;; rank-function generates a rank (a number) for each element in list, and then list is returned sorted,
;;; lowest rank first. This constrasts with Lisp's sort, where function is a *two* argument
;;; predicate for comparing two elements in list.
;;; rank-sort is non-destructive on list.
;;; CL-USER> (rank-sort '("cat" "the" "elephant" "a") #'length)
;;; ("a" "cat" "the" "elephant")
(defun rank-sort (list function) 
  (mapcar #'second (assoc-sort (transpose (list (mapcar function list) list)))))

(defun assoc-sort (list) (sort list #'pair-less-than))

(defun pair-less-than (pair1 pair2) (< (first pair1) (first pair2)))

(defun symbol-less-than (pair1 pair2) (string< (symbol-name pair1) (symbol-name pair2)))

;;; ----------

(defvar *tmp-counter* 0)

(defun reset-trace-at-iteration () (setq *tmp-counter* 0))

(defun trace-at-iteration (n) 
  (setq *tmp-counter* (1+ *tmp-counter*))
  (cond ((eq (mod *tmp-counter* n) 0) 
	 (format t "~a..." *tmp-counter*))))

(defun curr-iteration () *tmp-counter*)

;;; ======================================================================
;;;		       PROPERTY LISTS
;;; ======================================================================

;;; Remove *all* properties on the property list
(defun remprops (symbol)
  (mapc #'(lambda (indicator) 
	    (remprop symbol indicator)) 
	(odd-elements (symbol-plist symbol))))

;;; (odd-elements '(1 2 3 4 5)) -> (1 3 5)
(defun odd-elements (list)
  (cond ((endp list) nil)
	(t (cons (first list) (odd-elements (rest (rest list)))))))

;;; (even-elements '(1 2 3 4 5)) -> (2 4)
(defun even-elements (list) (odd-elements (rest list)))

;;; ======================================================================

;;; (Could also define set-eq if I need it)
;;; CL-USER> (set-equal '("a" b) '(b "a")) -> t
;;; CL-USER> (set-equal '(a b) '(b a b))   -> nil
;(defun set-equal (set1 set2)
;  (cond ((and (endp set1) (endp set2)) t)
;	((member (first set1) set2 :test #'equal)
;	 (set-equal (rest set1) (remove (first set1) set2 :test #'equal :count 1)))))

(defun multiple-value-mapcar (function list)
  (cond ((endp list) nil)
	(t (multiple-value-bind
	    (x y)
	    (funcall function (first list))
	    (multiple-value-bind
	     (xs ys)
	     (multiple-value-mapcar function (rest list))
	     (values (cons x xs) (cons y ys)))))))

(defun unquote (expr)
  (cond ((quotep expr) (second expr))
	(t (format t "Warning! Unquote received an already unquoted expression!~%") expr)))

(defun quotify (item) (list 'quote item))

;;; (set-equal '(a b) '(b a)) -> t
;;; (set-equal '("a" "b") '("b" "a")) -> t
;;; (set-equal '("a" "b") '("b" "a" "a")) -> t
(defun set-equal (set1 set2) (not (set-exclusive-or set1 set2 :test #'equal)))

;;; ----------

(defun update-assoc-list (assoc-list new-pair)
  (cond ((endp assoc-list) (list new-pair))
;	((string= (first (first assoc-list)) (first new-pair))
	((equal (first (first assoc-list)) (first new-pair))	; revised 12.16.99
	 (cons new-pair (rest assoc-list)))
	(t (cons (first assoc-list) (update-assoc-list (rest assoc-list) new-pair)))))

;;; Same, but matches with *second* argument
;;; (assoc 'a '((a b) (c e))) -> (a b)
;;; (inv-assoc 'b '((a b) (c e))) -> (a b)
;;; NOTE!! Common Lisp rassoc might be a better choice, doing the same thing but with dotted pairs
;;; (rassoc 'b '((a . b) (c . e))) -> (a . b)
(defun inv-assoc (key assoc-list &key (test #'eq))
  (cond ((endp assoc-list) nil)
	((apply test (list (second (first assoc-list)) key)) (first assoc-list))
	(t (inv-assoc key (rest assoc-list) :test test))))

;;; ----------

;;; (insert-delimeter '(a b c) 'cat) -> (a cat b cat c)
(defun insert-delimeter (list delimeter)
  (cond ((endp list) list)
	((singletonp list) list)
	((cons (first list) (cons delimeter (insert-delimeter (rest list) delimeter))))))

;;; ----------

;;; Returns non-nil if expr contains (at least) one of symbols.
;;; (contains-some '(a b (c d)) '(d e))  -> true
(defun contains-some (expr symbols)
  (or (member expr symbols)
      (and (listp expr) 
	   (some #'(lambda (el) (contains-some el symbols)) expr))))

;;; FILE:  strings.lisp

;;; File: strings.lisp
;;; Author: Peter Clark
;;; Date: August 1994
;;; Purpose: String manipulation with Lisp

(defconstant *mass-nouns* '("air" "water" "these"))
(defconstant *tmp-shell-file* "/tmp/tmp-clarkp")
; (defconstant *max-concat-length* 500)	; Lisp implementation constraint - Lucid
(defconstant *max-concat-length* 255)	; Lisp implementation constraint - Harlequin!
(defconstant *whitespace-chars* '(#\Space #\Tab #\Newline #\Return #\Linefeed #\Page))

;;; (a b) -> "(a b)"		       
(defun truncate-string (string &optional (maxlen 60))
  (cond ((not (stringp string)) 
	 (format t "ERROR! Non-string given to truncate-string in utils.lisp!~%")
	 string)
	((< (length string) maxlen) string)
	(t (concat (subseq string 0 maxlen) "..."))))

;;; ======================================================================

;;; (split-at "abcde" "bc") ---> "a" and "de"
;;; (split-at "abcde" "xx") ---> nil
(defun split-at (string substring)
  (let ( (start (search substring string)) )
    (cond (start (values (subseq string 0 start)
			 (subseq string (+ start (length substring))))))))

(defun contains (string substring)
  (search substring string))

(defun right-of (string substring)
  (multiple-value-bind 
   (left right)
   (split-at string substring)
   (declare (ignore left))
   right))

(defun left-of (string substring)
  (split-at string substring))		; just ignore second return value

;;; ======================================================================

;;; shorthand
(defun concat (&rest list) (my-concat list (length list)))
(defun concat-list  (list) (my-concat list (length list)))

; > (my-concat '("a" "b" "c" "d" "e" "f" "g" "h") 8)
; "abcdefgh"
(defun my-concat (list len)
  (cond ((<= len *max-concat-length*) 
	 (apply #'concatenate (cons 'string list)))
	(t (concatenate 'string
			(apply #'concatenate (cons 'string (subseq list 0 *max-concat-length*)))
			(my-concat (subseq list *max-concat-length*)
				   (- len *max-concat-length*))))))
; --------------------

;;; contains only whitespace
(defun white-space-p (string &key (whitespace-chars *whitespace-chars*))
  (white-space2-p string 0 (length string) whitespace-chars))

(defun white-space2-p (string n nmax whitespace-chars)
  (cond ((eq n nmax))
	((member (char string n) whitespace-chars :test #'char=)
	 (white-space2-p string (+ n 1) nmax whitespace-chars))))
  
;;; ======================================================================
;;;		STRING-TO-LIST   
;;; This nifty little utility breaks a string up into its word
;;; and delimeter components. Always starts with delimeter:


;;; (string-to-list '"the cat, sat on t-he m/at ")
;;; ==> ("" "the" " " "cat" ", " "sat" " " "on" " " "t-he" " " "m/at" " ")
;;; ======================================================================

(defun string-to-words (string)
  (remove-delimeters (string-to-list string)))

(defun string-to-list (string)
  (scan-to 'alphanum string 0 0 (length string)))

(defun scan-to (type string m n nmax)
  (cond ((eq n nmax) (list (subseq string m n)))		; reached the end.
	(t (let ( (curr-char (char string n))
		  (next-char (cond ((< (1+ n) nmax) (char string (1+ n)))
				   (t #\ ))) )
	     (cond ((and (is-type curr-char type)
			 (not (embedded-delimeter curr-char next-char type)))
		    (cons (subseq string m n)
			  (scan-to (invert-type type) string n n nmax)))
		   (t (scan-to type string m (1+ n) nmax)))))))

;;; This is a special-purpose bit of code which makes sure "." within
;;; a string (eg. "Section 2.2.1") is *not* categorized as a delimeter.
(defun embedded-delimeter (curr-char next-char type)
  (declare (ignore type))
  (and (char= curr-char #\.)
       (alphanumericp next-char)))

;;; type is 'alphanum or 'delimeter
(defun is-type (char type)
  (cond ((eq type 'alphanum) (not (delimeter char)))
	(t (delimeter char))))

;;; 5/7/99: *Do* want to break up software/hardware into two words.
;;; (defun delimeter (char)
;;;  (and (not (alphanumericp char))
;;;       (not (char= char #\-))
;;;       (not (char= char #\/))))
(defun delimeter (char) (not (alphanumericp char)))

(defun invert-type (type)
  (cond ((eq type 'delimeter) 'alphanum)
	(t 'delimeter)))

;;; Remove the delimeter components:

(defun remove-delimeters (list)
  (cond ((eq (cdr list) nil) nil)		;;; length 0 or 1
	(t (cons (cadr list) (remove-delimeters (cddr list))))))

;;; ======================================================================

;; " a " -> "a "
;; "  " -> ""
(defun remove-leading-whitespace (string) 
  (string-left-trim *whitespace-chars* string))

(defun remove-trailing-whitespace (string) 
  (string-right-trim *whitespace-chars* string))

;;; " a " -> "a"
(defun trim-whitespace (string)
  (string-trim *whitespace-chars* string))

;;; " a " -> t
(defun contains-whitespace (string)
  (some #'(lambda (char) (find char string)) *whitespace-chars*))

(defun whitespace-char (char) (member char *whitespace-chars* :test #'char=))
  
;;; ======================================================================

;;; mapchar; like mapcar, except it maps a function onto every
;;; character of a string rather than every element in a list.
;;; This should probably be a macro rather than a function.

(defun mapchar (function string) (mapcar function (explode string)))

(defun explode (string)
  (loop for i from 0 to (1- (length string))
	collect (char string i)))

(defun implode (charlist)
  (concat-list (mapcar #'string charlist)))

;;; ======================================================================

;;; copied from Denys, and modified...

(defun break-string-at (string break-char)
  (loop
    for start = 0 then end
    and end = 0
    while (setq start (position-if-not
		       #'(lambda (char) (char= char break-char))
		       string :start start))
    do    (setq end (position-if
		     #'(lambda (char) (char= char break-char))
		     string :start start))
    collecting (subseq string start end)
    while end))

;;; ======================================================================

;;; (commaed-list '("a" "b" "c")) -> ("a" ", " "b" ", " "c")
(defun commaed-list (list &optional (delimeter " ,"))
  (cond ((endp list) nil)
	((singletonp list) list)
	(t (cons (car list) (cons delimeter (commaed-list (cdr list) delimeter))))))

;;; Previously called spaced-list  
;;; (spaced-string '("a" "b" "c")) -> ("a b c")
(defun spaced-string (list) (concat-list (spaced-list list)))

(defun spaced-list (list)
  (cond ((endp list) nil)
	((singletonp list) list)
	(t (cons (first list) (cons " " (spaced-list (rest list)))))))
  
;;; ----------

(defun first-char (string) (cond ((string/= string "") (char string 0))))
(defun  last-char (string) (cond ((string/= string "") (char string (- (length string) 1)))))

;;; (butlast-char "cats") -> "cat"
(defun butlast-char (string)
  (cond ((string/= string "") (subseq string 0 (1- (length string))))))

(defun butfirst-char (string)
  (cond ((string/= string "") (subseq string 1 (length string)))))

;;; (ends-with "abcde" "de") -> t
;;; Modified June 1999, to work with lists too (ends-with '(a b c d) '(c d))
(defun ends-with (string substr)
  (and (>= (length string) (length substr))
       (equal (subseq string (- (length string) (length substr)))
		substr)))

;;; (starts-with "step 10" "step") -> t
;;; Modified June 1999, to work with lists too (starts-with '(a b c d) '(a b))
(defun starts-with (string substr)
  (and (>= (length string) (length substr))
       (equal (subseq string 0 (length substr))
		substr)))

;;; Trim n characters from the end of string
(defun trim-from-end (string n)
  (subseq string 0 (- (length string) n)))

(defun trim-from-start (string n)
  (subseq string n (length string)))

(defun symbol-starts-with (symbol char)
  (char= char (char (symbol-name symbol) 0)))

;;; ----------

(defun variants (word) 
  (cond ((and (ends-with word "ing")
	      (>= (length word) 7))		; avoid trimming "wing", "sting", "string"
	 (list (trim-from-end word 3)))
;	((and (ends-with word "ion") 
;	      (>= (length word) 5))
;	 (list (trim-from-end word 3)))		; avoid trimming "lion" (but will trim, "mission", "action")
;	((ends-with word "able") (list (trim-from-end word 4)))
;	((ends-with word "yse") (list (trim-from-end word 1)))
;	((ends-with word "ysis") (list (trim-from-end word 2)))
	(t (remove-duplicates (list word (singular word) (plural word) (gerund (singular word))) :test #'string=))))


(defun root-form (word) 
  (cond ((ends-with word "ing") (trim-from-end word 3))
	(t (singular word))))

;;; Input: plural of a word.
;;; Very heuristic... We miss a few plural words whose singular form ends in a;i;o;u eg.
;;; "macros", "silos", "emus", and singular a few singluar words ending with "es" eg.
;;; "Les" (I can't think of a better example). Also things like "avionics" get the "s"
;;; mistakenly (?) trimmed.
;;; NOTE capitalized words are *not* trimmed - we'll assume they are acronyms.
(defun singular (word)
  (cond 
   ((mass-noun word) word)
   ((ends-with word "sses") (trim-from-end word 2))	; "masses" -> "mass"
   ((ends-with word "ss") word)				; "mass" -> "mass"
   ((ends-with word "as") word)				; "atlas" -> "atlas"
   ((ends-with word "is") word)				; "prognisis" -> "prognosis"
   ((ends-with word "os") word)				; "asbestos" -> "asbestos"
   ((ends-with word "us") word)				; "apparatus" -> "apparatus"
   ((ends-with word "ies") (concat (trim-from-end word 3) "y")) ; "bodies" -> "body"
   ((ends-with word "s") (trim-from-end word 1))		; "moments" -> "moment"
   (t word)))

(defun plural (word)
  (cond 
   ((mass-noun word) word)
   ((ends-with word "ss") (concat word "es"))		; "mass" -> "masses"
   ((ends-with word "y") (concat (trim-from-end word 1) "ies")) ; "body" -> "bodies"
   ((ends-with word "s") word)				; "moments" -> "moments"
   (t (concat word "s"))))

;;; expects singular of a word in.
(defun gerund (word)
  (cond 
   ((ends-with word "e") (concat (trim-from-end word 1) "ing")) ; "warehouse" -> "warehousing"
   (t (concat word "ing"))))

(defun mass-noun (word)
  (member word *mass-nouns* :test #'string=))

;;; If all capitals, then preserve case (eg. for acronyms). Otherwise, downcase it.
(defun normalize-case (word)
  (cond ((string= word "A") "a")			; special case, for "A car"
	((string= word (string-upcase word)) word)
	((and (char= (last-char word) #\s)		; "RATs" -> RATs
	      (string= (butlast-char word) (string-upcase (butlast-char word)))
	      (string/= word "As")
	      (string/= word "Is"))
	 word)
	(t (string-downcase word))))

(defun is-acronym (word) 
  (let ( (singular-word (singular word)) )
    (string= singular-word (string-upcase singular-word))))

;;; ----------------------------------------
;;; (double-quotify-list '("cat" "the big cat")) -> '("cat" "\"the big cat\"")
(defun double-quotify-list (words &optional (delim-chars '(#\ )))
  (cond ((stringp words) (double-quotify words delim-chars))
	(t (mapcar #'(lambda (word)
		       (double-quotify word delim-chars))
		   words))))

(defun double-quotify (word &optional (delim-chars '(#\ )))
  (cond ((some #'(lambda (char)
		   (member char delim-chars :test #'char=))
	       (explode word))
	 (concat "\"" word "\""))
	(t word)))

;;; ======================================================================
;;;	Break up a string into pieces, preserving quoted adjacencies
;;; 	and trimming leading/ending white-space.
;;; ======================================================================

#| (break-up (string '|    aadsf a  " " "" "the cat" 1/2 a"b"c  de"f|))
("aadsf" 
 "a" 
 " " 
 "the cat" 
 "1/2" 
 "a" 
 "b" 
 "c" 
 "de" 
 "f")
|#
;;; NOTE: delim-chars MUSTN'T be a '"'
(defun break-up (string &optional (delim-chars '(#\ )))
  (break-up2 string 0 0 (length string) nil delim-chars))	  ; nil means "not in quotes"

(defun break-up2 (string m n nmax quotep &optional (delim-chars '(#\ )))
  (cond ((and (eq n nmax) (eq m n)) nil)			  ; ignore trailing white-space
	((eq n nmax) (list (subseq string m n)))		  ; reached the end.
	(t (let ( (curr-char (char string n)) )
	     (cond ((and (not quotep)				  ; is an unquoted leading white-space...
			 (member curr-char delim-chars :test #'char=)
			 (eq m n))
		    (break-up2 string (1+ n) (1+ n) nmax quotep delim-chars)) ; ... so ignore it
		   ((and (char= curr-char #\")			  ; A start-quote or end-quote
			 (eq m n))				  ; without a current word
		    (break-up2 string (1+ n) (1+ n) nmax 
			       (cond ((char= curr-char #\") (not quotep))
				     (t quotep))
			       delim-chars))
		   ((or (and (not quotep) 
			     (member curr-char delim-chars :test #'char=)) ; Ending delimeter = an unquoted space...
			(char= curr-char #\"))			  ; or an open-quote or a close-quote
		    (cons (subseq string m n)
			  (break-up2 string (1+ n) (1+ n) nmax 
				     (cond ((char= curr-char #\") (not quotep))
					   (t quotep))
				     delim-chars)))
		   (t (break-up2 string m (1+ n) nmax quotep delim-chars)))))))

;;; ----------

;;; (_car1) -> (_car1)
;;; (_car1 _car2) -> (_car1 "and" _car2)
;;; (_car1 _car2 _car3) -> (_car1 "," _car2 ", and" _car3)
(defun andify (vals)
  (case (length vals)
	(0 nil)
	(1 vals)
	(2 (list (first vals) " and " (second vals)))
	(3 (list (first vals) ", " (second vals) ", and " (third vals)))
	(t (cons (first vals) (cons ", " (andify (rest vals)))))))

(defun orify (vals)
  (case (length vals)
	(0 nil)
	(1 vals)
	(2 (list (first vals) " or " (second vals)))
	(3 (list (first vals) ", " (second vals) ", or " (third vals)))
	(t (cons (first vals) (cons ", " (orify (rest vals)))))))

;;; (commaify '(a b c d)) -> ("A, " "B, " "C, " "D")
(defun commaify (vals)
  (cond ((endp vals) nil)
	((singletonp vals) (list (string (first vals))))
	(t (cons (concat (string (first vals)) ", ") (commaify (rest vals))))))

;;; ----------

;;; (add-escapes "a+b"" '(#\+ #\") -> "a\+b\""
(defun add-escapes (string specials)
  (cond ((not (stringp string))
	 (format t "ERROR! add-escapes: argument ~s isn't a string!~%" string))
	(t (concat-list (mapcar #'(lambda (char)
				    (cond ((member char specials) (concat "\\" (string char)))
					  (t (string char))))
				(explode string))))))

;;; (now) -> "22/4/1999 11:49.24"
(defun now ()  
  (multiple-value-bind 
      (s m h d mo y)
      (get-decoded-time)
    (format nil "~s/~s/~s ~s:~s.~s" d mo y h m s)))

;;; (hostname) -> "thumper"
;;; Very crude, Allegro-specific implementation!
(defun hostname ()
  (first (result-of-shell-command "uname -n")))

;;; NB Beware of file collisions if using this with multiple, simultaneous Lisp processes running.
;;; Returns a list of ASCII strings.
(defun result-of-shell-command (command)
  (prog2
      (run-shell-command (concatenate 'string command " >! " *tmp-shell-file*))
      (read-file *tmp-shell-file*)
    (run-shell-command (concatenate 'string "rm " *tmp-shell-file*))))

;;; (common-startstring '("emergency" "emergencies")) -> "emergenc"
(defun common-startstring (strings)
  (cond ((singletonp strings) (first strings))
	(t (subseq (first strings) 0 (loop 
				       for i from 0 to (1- (apply #'min (mapcar #'length strings)))
				       until (some #'(lambda (string) 
						       (char/= (char string i) 
							       (char (first strings) i)))
						   (rest strings))
				       finally (return i))))))

;;; "a b c" -> "c", "a" -> "a" 
(defun last-word (string)
  (subseq string (1+ (or (search " " string :from-end t) -1))))

;;; ----------

;;; ("cat" "dog") -> ("cat" " " "dog")
(defun insert-spaces (words) 
  (insert-delimeter words " "))				; in utils.lisp

#|
(defun insert-spaces (words) 
  (cond ((endp words) nil)
	((singletonp words) words)
	(t (cons (first words) (cons " " (insert-spaces (rest words)))))))
|#
;;; FILE: compiler.lisp

;;; File: compiler.lisp
;;; Author: Adam Farquhar (afarquhar@slb.com)
;;; Date: 1998
;;; Purpose: Partially flatten the code for the KM dispatch mechanism, which 
;;;	in limited tests gives a 10%-30% speed-up in execution speed.

;;; Many thanks to Adam Farquhar for this neat bit of coding!!

(defun reuse-cons (a b ab)
  (if (and (eql a (car ab))
	   (eql b (cdr ab)))
      ab
      (cons a b)))

(defun variables-in (x)
  (let ((vars nil))
    (labels ((vars-in (x)
	       (cond
		 ((consp x)
		  (vars-in (first x))
		  (vars-in (rest x)))
		 ((varp x)
		  (pushnew x vars))
		 ((eql x '&rest)
		  (pushnew 'rest vars)))))
      (vars-in x)
      (nreverse vars))))
	       

(defun args-to-symbol (&rest args)
  (intern (string-upcase (format nil "~{~a~}" args))))

(defun add-quote-if-needed (x)
  "Quote X if necessary."
  (if (or (numberp x)
	  (stringp x)
	  (and (consp x) (eql (first x) 'quote))
	  (keywordp x))
      x
      (list 'quote x)))

;; See Norvig pg. 180ff for description of Delay, Force.

(defstruct delay (value nil)(function nil))
(defmacro delay (&rest body)
  `(make-delay :function #'(lambda () . ,body)))
(defun force (x)
  (if (not (delay-p x))
      x
      (progn
	(when (delay-function x)
	  (setf (delay-value x)
		(funcall (delay-function x)))
	  (setf (delay-function x) nil)
	  (delay-value x)))))

;;; Rule Compiler
;;;

(defvar *bindings* nil
  "Alist (pattern-var . binding), used for rule compilation.")


(defun compile-rule (pattern consequent var)
  (let ((*bindings* nil))
    `(lambda (,var)
      ,(compile-expr var pattern consequent))))

(defun compile-rules (rules var)
  "A rules is of the form (pat code) where code may reference vars in pat."
  (reduce
   #'merge-code
   (loop for (pattern consequent) in rules
	 collect (compile-rule pattern consequent var))))

(defun compile-expr (var pattern consequent)
  (cond
    ((assoc pattern *bindings* :test #'eq)
     `(when (equal ,var ,(cdr (assoc pattern *bindings*)))
       ,(force consequent)))
    ((varp pattern)
     (push (cons pattern var) *bindings*)
     ;; `(let ((,pattern ,var)) ,(force consequent))
     ;; do nothing, the consequent needs to get the bindings and use
     ;; it!
     (force consequent)
     )
    ((atom pattern)
     `(when (eql ,var ,(add-quote-if-needed pattern))
       ,(force consequent)))
    (t
     (compile-list var pattern consequent)
     )))

(defun compile-list (var pattern consequent)
  (let ((L (args-to-symbol var 'l))
	(r (args-to-symbol var 'r)))
    (if (consp pattern)
	(if (equal pattern '(&rest))
	    (progn
	      ;;(push (cons 'rest `(list ,var)) *bindings*)
	      (push (cons 'rest var) *bindings*)
	      (force consequent))
	    `(when (consp ,var)
	      (let ((,L (first ,var))
		    (,R (rest  ,var)))
		,(compile-expr
		  L (first pattern)
		  (delay (compile-expr R (rest pattern) consequent))))))
      `(when (null (cdr ,var))
	     (let ((,L (first ,var)))
	       ,(compile-expr
		 L (first pattern) consequent))))))

(defun mergeable (a b)
  ;; (f x y) (f x z) => (f x (merge y z))
  ;; also handles our when, let (only one element in body)
  (and (listp a) (listp b)
       (= (length a) (length b) 3)
       (equal (first a) (first b))
       (equal (second a) (second b))))

(defun merge-code (a b)
  ;; A and B are pieces of code generated by the pattern
  ;; compiler. Merge them (disjunctively) together.
  (cond
     ((mergeable a b)
      ;; (f x y) (f x z) => (f x (merge y z))
      ;; also handles our when, let (only one element in body)
       (list (first a)
	     (second a)
	     (merge-code (third a) (third b))))

     ((and (consp a) (eql 'or (first a)))
      ;; want to try to merge in with some interesting disjunct if
      ;; possible
      (let ((pos (position-if #'(lambda (x) (mergeable b x)) a)))
	(cond
	  ((null pos)
	   ;; just add b as a disjunct
	   (if (and (consp b) (eql 'or (first b)))
	       `(or ,@(rest a) ,@(rest b))
	       `(or ,@(rest a) ,b)))
	  (t
	   ;; merge b with one of a's disjuncts
	   `(,@(subseq a 0 pos)
	     ,(merge-code (nth pos a) b)
	     ,@(subseq a (1+ pos)))))))
     (t
      `(or ,a ,b))))

;;;
;;; KM Handler compilation
;;;

#|
#+ignore(defun dereference-expr (x)
  ;; note depending on the compiler, this can be slow.
  (if (consp x)
      (reuse-cons
       (dereference-expr (first x))
       (dereference-expr (rest  x))
       x)
      (dereference x)))
|#
#|
;;; Move to interpreter lisp
(defun dereference-expr (x)
  ;; This is fundamentally WRONG, but is the existing 1.2 behavior.
  (if (consp x)
      (mapcar #'dereference x)
      (dereference x)))
|#

; (defparameter *km-handler-function* nil) - now in header.lisp
; no more (defparameter *custom-km-handler-function* nil)

(defun reset-handler-functions ()
  (format t "Compiling KM dispatch mechanism...")
  (setq *km-handler-function*
	(compile-handlers *km-handler-alist*))
  (format t "done!~%"))
; no more  (setq *custom-km-handler-function*
; no more	(compile-handlers *custom-km-handlers*)))

(defparameter *trace-rules* nil)

(defun trace-rule (rule-pattern fact bindings)
  (format *trace-output*
   "Rule ~s is being applied to ~s with bindings ~s."
    rule-pattern fact bindings))

(defun compile-handlers (handlers &key code-only)
  "Compile the handler-alist Handlers.  If code-only is T, then just
return the code without invoking the compiler on it."
  (if (null handlers)
      (if code-only
          nil
          #'(lambda (fmode X) (declare (ignore X fmode)) nil))
      (let ((code
             (reduce
              #'merge-code
              (loop
               for (pattern closure)
               in handlers
               collect
               `(lambda (fmode x)
		 (block km-handler .
			,(cddr
			  (compile-rule
			   pattern
			   (delay

; OLD			    `(let ()
;			       (when *trace-rules*
;				(trace-rule ',pattern X (list ,@(bindings-for pattern))))
;			      (return-from km-handler
;				(funcall
;				 ',closure fmode
;				 ,@(bindings-for pattern)))))

#|NEW|#			   `(return-from km-handler
				(funcall
				 ',closure fmode
				 ,@(bindings-for pattern))))

			   'x))))))))
        (if code-only
            code (compile nil code)))))

(defun bindings-for (pattern)
   (loop for var in (variables-in pattern)
	 collect (cdr (assoc var *bindings*))))

#|
;;; AUX FUNCTIONS FROM KM SOURCE
;;; This is defined in km.lisp already. Need this for stand-alone compiler.
(defun varp (var)
  (and (symbolp var)
       (char=
       #\?
       (char (the string (symbol-name (the symbol var))) 0))))
|#


(defun faster ()
  (format t "(Redundant command - the dispatch mechanism is now automatically compiled in KM1.4)~%"))

;;; for development mode, when the compiled code isn't there.
(defun faster-dev ()
  (cond (*compile-handlers* 
	 (format t "(The dispatch mechanism is already compiled)~%") t)
	(t (reset-handler-functions)
	   (setq *compile-handlers* t))))

(defconstant *compiled-handlers-file* "compiled-handlers.lisp")

(defun write-compiled-handlers ()
  (let* ( (anonymous-function (compile-handlers *km-handler-alist* :code-only t))
	  (named-function `(defun compiled-km-handler-function (fmode x) . 
			     ,(rest (rest anonymous-function))))		   ; strip off "(lambda (fmode x) ..."
	  (stream (tell *compiled-handlers-file*)) )
    (format stream "
;;; File: compiled-handlers.lisp
;;; Author: MACHINE GENERATED FILE, generated by compiler.lisp (author Adam Farquahar)
;;; This file was generated by (write-compiled-handlers) in compiler.lisp.
;;; This partially flattens the code assigned to *km-handler-list*, which results in
;;; 10%-30% faster execution (10%-30%) at run-time. Loading of this file is optional, 
;;; KM will be slower if it's not loaded. For the legible, unflattened source of this
;;; flattened code, see the file interpreter.lisp.
;;;
;;; ==================== START OF MACHINE-GENERATED FILE ====================

;;; New: must switch OFF compiled handlers for case-insensitive usage
;;; (setq *compile-handlers* t)
(setq *compile-handlers* *case-sensitivity*)

")
   (write named-function :stream stream)
   (format stream "

(setq *km-handler-function* #'compiled-km-handler-function)

;;; This file was generated by (write-compiled-handlers) in compiler.lisp.
;;; This partially flattens the code assigned to *km-handler-list*, which results in
;;; 10%-30% faster execution (10%-30%) at run-time. Loading of this file is optional, 
;;; KM will be slower if it's not loaded. For the legible, unflattened source of this
;;; flattened code, see the file interpreter.lisp.

;;; ==================== END OF MACHINE-GENERATED FILE ====================

")
   (close stream)
   (format t "Compiled handlers written to the file ~a~%" *compiled-handlers-file*)))


;;; FILE: compiled-handlers.lisp

;;; File: compiled-handlers.lisp
;;; Author: MACHINE GENERATED FILE, generated by compiler.lisp (author Adam Farquahar)
;;; This file was generated by (write-compiled-handlers) in compiler.lisp.
;;; This partially flattens the code assigned to *km-handler-list*, which results in
;;; 10%-30% faster execution (10%-30%) at run-time. Loading of this file is optional, 
;;; KM will be slower if it's not loaded. For the legible, unflattened source of this
;;; flattened code, see the file interpreter.lisp.
;;;
;;; ==================== START OF MACHINE-GENERATED FILE ====================

;;; New: must switch OFF compiled handlers for case-insensitive usage
;;; (setq *compile-handlers* t)
(setq *compile-handlers* *case-sensitivity*)

(defun compiled-km-handler-function (fmode x)
  (block km-handler
    (or (when (consp x)
          (let ((xl (first x)) (xr (rest x)))
            (or (when (eql xl '|the|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (or (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (or (when
                                   (eql xrrl '|of|)
                                   (when
                                    (consp xrrr)
                                    (let
                                     ((xrrrl (first xrrr))
                                      (xrrrr (rest xrrr)))
                                     (when
                                      (eql xrrrr 'nil)
                                      (return-from
                                       km-handler
                                       (funcall
                                        '(lambda
                                          (fmode0 slot frameadd)
                                          (cond
                                           ((structured-slotp slot)
                                            (follow-multidepth-path

                                             (km

                                              frameadd
                                              :fail-mode

                                              fmode0)
                                             slot
                                             '*

                                             :fail-mode
                                             fmode0))
                                           (t
                                            (let*
                                             ((fmode
                                               (cond
                                                ((built-in-aggregation-slot
                                                  slot)
                                                 'fail)
                                                (t fmode0)))
                                              (frames
                                               (cond
                                                ((every
                                                  #'is-simple-km-term
                                                  (val-to-vals
                                                   frameadd))
                                                 (remove-dup-instances
                                                  (val-to-vals
                                                   frameadd)))
                                                (t
                                                 (km

                                                  frameadd
                                                  :fail-mode

                                                  fmode
                                                  :check-for-looping
                                                  nil)))))
                                             (cond
                                              ((not
                                                (equal
                                                 frames
                                                 (val-to-vals
                                                  frameadd)))
                                               (remove-if-not

                                                #'is-km-term
                                                (km

                                                 `(|the|
                                                   ,slot
                                                   |of|
                                                   ,(vals-to-val
                                                     frames))
                                                 :fail-mode

                                                 fmode)))
                                              (t
                                               (remove-if-not

                                                #'is-km-term
                                                (km-multi-slotvals

                                                 frames
                                                 slot

                                                 :fail-mode
                                                 fmode))))))))
                                        fmode
                                        xrl
                                        xrrrl))))))
                                  (when
                                   (consp xrrr)
                                   (let
                                    ((xrrrl (first xrrr))
                                     (xrrrr (rest xrrr)))
                                    (when
                                     (eql xrrrl '|of|)
                                     (when
                                      (consp xrrrr)
                                      (let
                                       ((xrrrrl (first xrrrr))
                                        (xrrrrr (rest xrrrr)))
                                       (when
                                        (eql xrrrrr 'nil)
                                        (return-from
                                         km-handler
                                         (funcall
                                          '(lambda
                                            (fmode0
                                             class
                                             slot
                                             frameadd)
                                            (cond
                                             ((structured-slotp slot)
                                              (follow-multidepth-path

                                               (km

                                                frameadd
                                                :fail-mode

                                                fmode0)
                                               slot
                                               class

                                               :fail-mode
                                               fmode0))
                                             (t
                                              (let*
                                               ((fmode
                                                 (cond
                                                  ((built-in-aggregation-slot
                                                    slot)
                                                   'fail)
                                                  (t fmode0))))
                                               (vals-in-class
                                                (km

                                                 `(|the|
                                                   ,slot
                                                   |of|
                                                   ,frameadd)
                                                 :fail-mode

                                                 fmode)
                                                class)))))
                                          fmode
                                          xrl
                                          xrrl
                                          xrrrrl))))))))
                                  (when
                                   (eql xrrl '|with|)
                                   (return-from
                                    km-handler
                                    (funcall
                                     '(lambda
                                       (fmode frame slotsvals)
                                       (declare (ignore fmode))
                                       (let
                                        ((answer
                                          (km

                                           `(|every|
                                             ,frame
                                             |with|
                                             ,@slotsvals)
                                           :fail-mode

                                           'fail)))
                                        (cond
                                         ((null answer)
                                          (report-error
                                           'user-error
                                           "No values found for expression ~a!~%"
                                           `(|the|
                                             ,frame
                                             |with|
                                             ,@slotsvals)))
                                         ((not (singletonp answer))
                                          (report-error
                                           'user-error
                                           "Expected a single value for expression ~a, but found multiple values ~a!~%"
                                           `(|the|
                                             ,frame
                                             |with|
                                             ,@slotsvals)
                                           answer))
                                         (t answer))))
                                     fmode
                                     xrl
                                     xrrr))))))
                          (when (eql xrr 'nil)
                            (return-from km-handler
                              (funcall '(lambda
                                         (fmode frame)
                                         (declare (ignore fmode))
                                         (let
                                          ((answer
                                            (km

                                             `(|every| ,frame)
                                             :fail-mode

                                             'fail)))
                                          (cond
                                           ((null answer)
                                            (report-error
                                             'user-error
                                             "No values found for expression ~a!~%"
                                             `(|the| ,frame)))
                                           ((not (singletonp answer))
                                            (report-error
                                             'user-error
                                             "Expected a single value for expression ~a, but found multiple values ~a!~%"
                                             `(|the| ,frame)
                                             answer))
                                           (t answer))))
                                       fmode xrl)))))))
                (when (eql xl '|a|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (or (when (eql xrr 'nil)
                            (return-from km-handler
                              (funcall '(lambda
                                         (_fmode class)
                                         (declare (ignore _fmode))
                                         (list
                                          (create-instance class)))
                                       fmode xrl)))
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrl '|with|)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (_fmode class slotsvals)
                                    (declare (ignore _fmode))
                                    (cond
                                     ((are-slotsvals slotsvals)
                                      (list
                                       (create-instance
                                        class
                                        slotsvals)))))
                                  fmode
                                  xrl
                                  xrrr)))))))))
                (when (eql xl '|some|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (or (when (eql xrr 'nil)
                            (return-from km-handler
                              (funcall '(lambda
                                         (_fmode class)
                                         (declare (ignore _fmode))
                                         (list
                                          (create-instance
                                           class
                                           nil
                                           *fluent-instance-marker-string*)))
                                       fmode xrl)))
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrl '|with|)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (_fmode class slotsvals)
                                    (declare (ignore _fmode))
                                    (cond
                                     ((are-slotsvals slotsvals)
                                      (list
                                       (create-instance
                                        class
                                        slotsvals
                                        *fluent-instance-marker-string*)))))
                                  fmode
                                  xrl
                                  xrrr)))))))))
                (when (eql xl '|a-prototype|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (or (when (eql xrr 'nil)
                            (return-from km-handler
                              (funcall '(lambda
                                         (fmode class)
                                         (km

                                          `(|a-prototype|
                                            ,class
                                            |with|)
                                          :fail-mode

                                          fmode))
                                       fmode xrl)))
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrl '|with|)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (_fmode class slotsvals)
                                    (declare (ignore _fmode))
                                    (cond
                                     ((am-in-local-situation)
                                      (report-error
                                       'user-error
                                       "Can't enter prototype mode when in a Situation!~%"))
                                     ((am-in-prototype-mode)
                                      (report-error
                                       'user-error
                                       "~a~%Attempt to enter prototype mode while already in prototype mode (not allowed)!~%Perhaps you are missing an (end-prototype)?"
                                       `(|a-prototype|
                                         ,class
                                         |with|
                                         ,@slotsvals)))
                                     ((are-slotsvals slotsvals)
                                      (new-context)
                                      (make-transaction
                                       `(setq
                                         *curr-prototype*
                                         ,(create-instance
                                           class
                                           `((|prototype-of| (,class))
                                             ,(cond
                                               (slotsvals
                                                `(|definition|
                                                  ('(|a|
                                                     ,class
                                                     |with|
                                                     ,@slotsvals))))
                                               (t
                                                `(|definition|
                                                  ('(|a| ,class)))))
                                             ,@slotsvals)
                                           *proto-marker-string*)))
                                      (add-val
                                       *curr-prototype*
                                       '|protoparts|
                                       *curr-prototype*)
                                      (setq *are-some-prototypes* t)
                                      (list *curr-prototype*))))
                                  fmode
                                  xrl
                                  xrrr)))))))))
                (when (eql xl '|end-prototype|)
                  (when (eql xr 'nil)
                    (return-from km-handler
                      (funcall '(lambda
                                 (_fmode)
                                 (declare (ignore _fmode))
                                 (make-transaction
                                  '(setq *curr-prototype* nil))
                                 (global-situation)
                                 (new-context)
                                 '(|t|))
                               fmode))))
                (when (eql xl '|clone|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (fmode expr)
                                     (let
                                      ((source (km-unique expr)))
                                      (cond
                                       (source
                                        (list (clone source))))))
                                   fmode xrl))))))
                (when (eql xl '|evaluate-paths|)
                  (when (eql xr 'nil)
                    (return-from km-handler
                      (funcall '(lambda
                                 (_fmode)
                                 (declare (ignore _fmode))
                                 (eval-instances)
                                 '(|t|))
                               fmode))))
                (when (eql xl '|fluent-instancep|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (fmode expr)
                                     (cond
                                      ((fluent-instancep
                                        (km-unique

                                         expr

                                         :fail-mode
                                         fmode))
                                       '(|t|))))
                                   fmode xrl))))))
                (when (eql xl '|default-fluent-status|)
                  (return-from km-handler
                    (funcall '(lambda (fmode rest)
                                (declare (ignore fmode))
                                (default-fluent-status (first rest)))
                             fmode xr)))
                (when (eql xl '|must-be-a|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (or (when (eql xrr 'nil)
                            (return-from km-handler
                              (funcall '(lambda
                                         (_fmode _class)
                                         (declare
                                          (ignore _fmode _class))
                                         nil)
                                       fmode xrl)))
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrl '|with|)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (_fmode _class slotsvals)
                                    (declare (ignore _fmode _class))
                                    (are-slotsvals slotsvals)
                                    nil)
                                  fmode
                                  xrl
                                  xrrr)))))))))
                (when (eql xl '|mustnt-be-a|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (or (when (eql xrr 'nil)
                            (return-from km-handler
                              (funcall '(lambda
                                         (_fmode _class)
                                         (declare
                                          (ignore _fmode _class))
                                         nil)
                                       fmode xrl)))
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrl '|with|)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (_fmode _class slotsvals)
                                    (declare (ignore _fmode _class))
                                    (are-slotsvals slotsvals)
                                    nil)
                                  fmode
                                  xrl
                                  xrrr)))))))))
                (when (eql xl '<>)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode _val)
                                     (declare (ignore _fmode _val))
                                     nil)
                                   fmode xrl))))))
                (when (eql xl '|constraint|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode _expr)
                                     (declare (ignore _fmode _expr)))
                                   fmode xrl))))))
                (when (eql xl '|set-constraint|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode _expr)
                                     (declare (ignore _fmode _expr)))
                                   fmode xrl))))))
                (when (eql xl '|at-least|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (consp xrr)
                        (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                          (when (eql xrrr 'nil)
                            (return-from km-handler
                              (funcall '(lambda
                                         (_fmode _n _class)
                                         (declare
                                          (ignore _fmode _n _class)))
                                       fmode xrl xrrl))))))))
                (when (eql xl '|at-most|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (consp xrr)
                        (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                          (when (eql xrrr 'nil)
                            (return-from km-handler
                              (funcall '(lambda
                                         (_fmode _n _class)
                                         (declare
                                          (ignore _fmode _n _class)))
                                       fmode xrl xrrl))))))))
                (when (eql xl '|exactly|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (consp xrr)
                        (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                          (when (eql xrrr 'nil)
                            (return-from km-handler
                              (funcall '(lambda
                                         (_fmode _n _class)
                                         (declare
                                          (ignore _fmode _n _class)))
                                       fmode xrl xrrl))))))))
                (when (eql xl '|every|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (or (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (or (when
                                   (eql xrrl '|has|)
                                   (return-from
                                    km-handler
                                    (funcall
                                     '(lambda
                                       (_fmode cexpr slotsvals)
                                       (declare (ignore _fmode))
                                       (let
                                        ((class (km-unique cexpr)))
                                        (cond
                                         ((not (kb-objectp class))
                                          (report-error
                                           'user-error
                                           "~a~%~a isn't/doesn't evaluate to a class name.~%"
                                           `(|every|
                                             ,cexpr
                                             |has|
                                             ,@slotsvals)
                                           cexpr))
                                         ((are-slotsvals slotsvals)
                                          (add-slotsvals
                                           class
                                           slotsvals
                                           'member-properties
                                           nil)
                                          (cond
                                           ((and
                                             (assoc

                                              '|assertions|
                                              slotsvals)
                                             (not
                                              (member

                                               class
                                               *classes-using-assertions-slot*)))
                                            (make-transaction
                                             `(setq
                                               *classes-using-assertions-slot*
                                               ,(cons
                                                 class
                                                 *classes-using-assertions-slot*)))))
                                          (mapc
                                           #'un-done
                                           (all-instances class))
                                          (list class)))))
                                     fmode
                                     xrl
                                     xrrr)))
                                  (when
                                   (eql xrrl '|with|)
                                   (return-from
                                    km-handler
                                    (funcall
                                     '(lambda
                                       (_fmode frame slotsvals)
                                       (declare (ignore _fmode))
                                       (cond
                                        ((are-slotsvals slotsvals)
                                         (let
                                          ((existential-expr
                                            (cond
                                             ((and
                                               (null slotsvals)
                                               (pathp frame))
                                              (path-to-existential-expr
                                               frame))
                                             (t
                                              `(|a|
                                                ,frame
                                                |with|
                                                ,@slotsvals)))))
                                          (find-subsumees
                                           existential-expr)))))
                                     fmode
                                     xrl
                                     xrrr)))
                                  (when
                                   (eql xrrl '|has-definition|)
                                   (return-from
                                    km-handler
                                    (funcall
                                     '(lambda
                                       (_fmode cexpr slotsvals)
                                       (declare (ignore _fmode))
                                       (let
                                        ((class (km-unique cexpr)))
                                        (cond
                                         ((not (kb-objectp class))
                                          (report-error
                                           'user-error
                                           "~a~%~a isn't/doesn't evaluate to a class name.~%"
                                           `(|every|
                                             ,cexpr
                                             |has-definition|
                                             ,@slotsvals)
                                           cexpr))
                                         ((are-slotsvals slotsvals)
                                          (add-slotsvals
                                           class
                                           slotsvals
                                           'member-definition
                                           nil)
                                          (point-parents-to-defined-concept
                                           class
                                           (vals-in
                                            (assoc

                                             '|instance-of|
                                             slotsvals))
                                           'member-definition)
                                          (setq
                                           *are-some-definitions*
                                           t)
                                          (mapc
                                           #'un-done
                                           (all-instances class))
                                          (list class)))))
                                     fmode
                                     xrl
                                     xrrr))))))
                          (when (eql xrr 'nil)
                            (return-from km-handler
                              (funcall '(lambda
                                         (fmode frame)
                                         (km

                                          `(|every| ,frame |with|)
                                          :fail-mode

                                          fmode))
                                       fmode xrl)))))))
                (when (consp xr)
                  (let ((xrl (first xr)) (xrr (rest xr)))
                    (or (when (eql xrl '|has|)
                          (return-from km-handler
                            (funcall '(lambda
                                       (_fmode instance-expr slotsvals)
                                       (declare (ignore _fmode))
                                       (let
                                        ((instance
                                          (km-unique instance-expr)))
                                        (cond
                                         ((not (kb-objectp instance))
                                          (report-error
                                           'user-error
                                           "~a~%~a isn't/doesn't evaluate to a KB object name.~%"
                                           `(,instance-expr
                                             |has|
                                             ,@slotsvals)
                                           instance-expr))
                                         ((are-slotsvals slotsvals)
                                          (add-slotsvals
                                           instance
                                           slotsvals
                                           'own-properties)
                                          (un-done instance)
                                          (classify instance)
                                          (cond
                                           ((am-in-prototype-mode)
                                            (km '(|evaluate-paths|))))
                                          (list instance)))))
                                     fmode xl xrr)))
                        (when (eql xrl '&&)
                          (return-from km-handler
                            (funcall '(lambda
                                       (fmode xs rest)
                                       (declare (ignore _fmode))
                                       (lazy-unify-&-expr

                                        `(,xs && ,@rest)

                                        :joiner
                                        '&&))
                                     fmode xl xrr)))
                        (when (eql xrl '&)
                          (return-from km-handler
                            (funcall '(lambda
                                       (fmode x rest)
                                       (declare (ignore _fmode))
                                       (lazy-unify-&-expr

                                        `(,x & ,@rest)

                                        :joiner
                                        '&))
                                     fmode xl xrr)))
                        (when (eql xrl '===)
                          (return-from km-handler
                            (funcall '(lambda
                                       (fmode xs rest)
                                       (declare (ignore _fmode))
                                       (lazy-unify-&-expr

                                        `(,xs === ,@rest)

                                        :joiner
                                        '===))
                                     fmode xl xrr)))
                        (when (eql xrl '==)
                          (return-from km-handler
                            (funcall '(lambda
                                       (fmode x rest)
                                       (declare (ignore _fmode))
                                       (lazy-unify-&-expr

                                        `(,x == ,@rest)

                                        :joiner
                                        '==))
                                     fmode xl xrr)))
                        (when (eql xrl '&&!)
                          (return-from km-handler
                            (funcall '(lambda
                                       (fmode xs rest)
                                       (declare (ignore _fmode))
                                       (lazy-unify-&-expr

                                        `(,xs &&! ,@rest)

                                        :joiner
                                        '&&!))
                                     fmode xl xrr)))
                        (when (eql xrl '&!)
                          (return-from km-handler
                            (funcall '(lambda
                                       (fmode x rest)
                                       (declare (ignore _fmode))
                                       (lazy-unify-&-expr

                                        `(,x &! ,@rest)

                                        :joiner
                                        '&!))
                                     fmode xl xrr)))
                        (when (eql xrl '&?)
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrr 'nil)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (_fmode x y)
                                    (declare (ignore _fmode))
                                    (cond
                                     ((is-existential-expr y)
                                      (let
                                       ((xf
                                         (km-unique

                                          x

                                          :fail-mode
                                          'fail)))
                                       (cond
                                        ((null xf) '(|t|))
                                        ((unifiable-with-existential-expr

                                          xf
                                          y)
                                         '(|t|)))))
                                     ((is-existential-expr x)
                                      (let
                                       ((yf
                                         (km-unique

                                          y

                                          :fail-mode
                                          'fail)))
                                       (cond
                                        ((null yf) '(|t|))
                                        ((unifiable-with-existential-expr

                                          yf
                                          x)
                                         '(|t|)))))
                                     (t
                                      (let
                                       ((xv
                                         (km-unique

                                          x

                                          :fail-mode
                                          'fail)))
                                       (cond
                                        ((null xv) '(|t|))
                                        (t
                                         (let
                                          ((yv
                                            (km-unique

                                             y

                                             :fail-mode
                                             'fail)))
                                          (cond
                                           ((null yv) '(|t|))
                                           ((try-lazy-unify xv yv)
                                            '(|t|))))))))))
                                  fmode
                                  xl
                                  xrrl))))))
                        (when (eql xrl '&+)
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrr 'nil)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (fmode x y)
                                    (let
                                     ((unification
                                       (lazy-unify-exprs

                                        x
                                        y

                                        :classes-subsumep
                                        t
                                        :fail-mode
                                        fmode)))
                                     (cond
                                      (unification (list unification))
                                      ((eq fmode 'error)
                                       (report-error
                                        'user-error
                                        "Unification (~a &+ ~a) failed!~%"
                                        x
                                        y)))))
                                  fmode
                                  xl
                                  xrrl))))))
                        (when (eql xrl '=)
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrr 'nil)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (fmode x y)
                                    (let
                                     ((xv (km x :fail-mode fmode))
                                      (yv (km y :fail-mode fmode)))
                                     (cond
                                      ((or
                                        (equal xv yv)
                                        (and
                                         (singletonp xv)
                                         (equal (first xv) yv))
                                        (and
                                         (singletonp yv)
                                         (equal (first yv) xv))
                                        (set-equal xv yv))
                                       '(|t|)))))
                                  fmode
                                  xl
                                  xrrl))))))
                        (when (eql xrl '|has-definition|)
                          (return-from km-handler
                            (funcall '(lambda
                                       (_fmode instance-expr slotsvals)
                                       (declare (ignore _fmode))
                                       (let
                                        ((instance
                                          (km-unique instance-expr)))
                                        (cond
                                         ((not (kb-objectp instance))
                                          (report-error
                                           'user-error
                                           "~a~%~a isn't/doesn't evaluate to a KB object name.~%"
                                           `(|every|
                                             ,instance-expr
                                             |has-definition|
                                             ,@slotsvals)
                                           instance-expr))
                                         ((are-slotsvals slotsvals)
                                          (add-slotsvals
                                           instance
                                           slotsvals
                                           'own-definition)
                                          (point-parents-to-defined-concept
                                           instance
                                           (vals-in
                                            (assoc

                                             '|instance-of|
                                             slotsvals))
                                           'own-definition)
                                          (setq
                                           *are-some-definitions*
                                           t)
                                          (un-done instance)
                                          (classify instance)
                                          (list instance)))))
                                     fmode xl xrr)))
                        (when (eql xrl '>)
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrr 'nil)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (_fmode x y)
                                    (declare (ignore _fmode))
                                    (let
                                     ((xval
                                       (km-unique x :fail-mode 'error))
                                      (yval
                                       (km-unique

                                        y

                                        :fail-mode
                                        'error)))
                                     (cond
                                      ((and
                                        (numberp xval)
                                        (numberp yval)
                                        (> xval yval))
                                       '(|t|)))))
                                  fmode
                                  xl
                                  xrrl))))))
                        (when (eql xrl '<)
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrr 'nil)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (_fmode x y)
                                    (declare (ignore _fmode))
                                    (let
                                     ((xval
                                       (km-unique x :fail-mode 'error))
                                      (yval
                                       (km-unique

                                        y

                                        :fail-mode
                                        'error)))
                                     (cond
                                      ((and
                                        (numberp xval)
                                        (numberp yval)
                                        (< xval yval))
                                       '(|t|)))))
                                  fmode
                                  xl
                                  xrrl))))))
                        (when (eql xrl '>=)
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrr 'nil)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (_fmode x y)
                                    (declare (ignore _fmode))
                                    (let
                                     ((xval
                                       (km-unique x :fail-mode 'error))
                                      (yval
                                       (km-unique

                                        y

                                        :fail-mode
                                        'error)))
                                     (cond
                                      ((and
                                        (numberp xval)
                                        (numberp yval)
                                        (>= xval yval))
                                       '(|t|)))))
                                  fmode
                                  xl
                                  xrrl))))))
                        (when (eql xrl '<=)
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrr 'nil)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (_fmode x y)
                                    (declare (ignore _fmode))
                                    (let
                                     ((xval
                                       (km-unique x :fail-mode 'error))
                                      (yval
                                       (km-unique

                                        y

                                        :fail-mode
                                        'error)))
                                     (cond
                                      ((and
                                        (numberp xval)
                                        (numberp yval)
                                        (<= xval yval))
                                       '(|t|)))))
                                  fmode
                                  xl
                                  xrrl))))))
                        (when (eql xrl '/=)
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrr 'nil)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (fmode x y)
                                    (cond
                                     ((not
                                       (equal
                                        (km x :fail-mode fmode)
                                        (km y :fail-mode fmode)))
                                      '(|t|))))
                                  fmode
                                  xl
                                  xrrl))))))
                        (when (eql xrl '|isa|)
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrr 'nil)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (fmode x y)
                                    (let
                                     ((xval
                                       (km-unique x :fail-mode fmode)))
                                     (cond
                                      ((atom y)
                                       (cond ((isa xval y) '(|t|))))
                                      ((isa
                                        xval
                                        (km-unique y :fail-mode fmode))
                                       '(|t|)))))
                                  fmode
                                  xl
                                  xrrl))))))
                        (when (eql xrl '|and|)
                          (return-from km-handler
                            (funcall '(lambda
                                       (_fmode x y)
                                       (declare (ignore _fmode))
                                       (and
                                        (km x :fail-mode 'fail)
                                        (km y :fail-mode 'fail)))
                                     fmode xl xrr)))
                        (when (eql xrl '|or|)
                          (return-from km-handler
                            (funcall '(lambda
                                       (_fmode x y)
                                       (declare (ignore _fmode))
                                       (or
                                        (and
                                         (not (on-km-stackp x))
                                         (km x :fail-mode 'fail))
                                        (km y :fail-mode 'fail)))
                                     fmode xl xrr)))
                        (when (eql xrl '|subsumes|)
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrr 'nil)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (_fmode x y)
                                    (declare (ignore _fmode))
                                    (let
                                     ((yv (km y :fail-mode 'fail)))
                                     (cond
                                      ((null yv) '(|t|))
                                      (t
                                       (let
                                        ((xv (km x :fail-mode 'fail)))
                                        (cond
                                         ((and
                                           (not (null xv))
                                           (subsumes xv yv))
                                          '(|t|))))))))
                                  fmode
                                  xl
                                  xrrl))))))
                        (when (eql xrl '|covers|)
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrr 'nil)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (_fmode x y)
                                    (declare (ignore _fmode))
                                    (let
                                     ((yv
                                       (km-unique y :fail-mode 'fail)))
                                     (cond
                                      ((null yv) '(|t|))
                                      (t
                                       (let
                                        ((xv (km x :fail-mode 'fail)))
                                        (cond
                                         ((and
                                           (not (null xv))
                                           (covers xv yv))
                                          '(|t|))))))))
                                  fmode
                                  xl
                                  xrrl))))))
                        (when (eql xrl '|is|)
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrr 'nil)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (_fmode x y)
                                    (declare (ignore _fmode))
                                    (let
                                     ((xv
                                       (km-unique x :fail-mode 'fail)))
                                     (cond
                                      ((null xv) nil)
                                      (t
                                       (let
                                        ((yv
                                          (km-unique

                                           y

                                           :fail-mode
                                           'fail)))
                                        (cond
                                         ((and
                                           (not (null yv))
                                           (is xv yv))
                                          '(|t|))))))))
                                  fmode
                                  xl
                                  xrrl))))))
                        (when (eql xrl '|includes|)
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrr 'nil)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (_fmode xs y)
                                    (declare (ignore _fmode))
                                    (cond
                                     ((member

                                       (km-unique y)
                                       (km xs :fail-mode 'fail))
                                      '(|t|))))
                                  fmode
                                  xl
                                  xrrl))))))
                        (when (eql xrl '|is-superset-of|)
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrr 'nil)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (_fmode xs ys)
                                    (declare (ignore _fmode))
                                    (cond
                                     ((subsetp

                                       (km ys :fail-mode 'fail)
                                       (km xs :fail-mode 'fail))
                                      '(|t|))))
                                  fmode
                                  xl
                                  xrrl))))))
                        (when (eql xrl '^)
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (or (when
                                   (consp xrrr)
                                   (let
                                    ((xrrrl (first xrrr))
                                     (xrrrr (rest xrrr)))
                                    (or
                                     (when
                                      (eql xrrrl '^)
                                      (return-from
                                       km-handler
                                       (funcall
                                        '(lambda
                                          (fm x y rest)
                                          (km

                                           `((,x ^ ,y) ^ ,@rest)
                                           :fail-mode

                                           fm))
                                        fmode
                                        xl
                                        xrrl
                                        xrrrr)))
                                     (when
                                      (eql xrrrl '+)
                                      (return-from
                                       km-handler
                                       (funcall
                                        '(lambda
                                          (fm x y rest)
                                          (km

                                           `((,x ^ ,y) + ,@rest)
                                           :fail-mode

                                           fm))
                                        fmode
                                        xl
                                        xrrl
                                        xrrrr)))
                                     (when
                                      (eql xrrrl '-)
                                      (return-from
                                       km-handler
                                       (funcall
                                        '(lambda
                                          (fm x y rest)
                                          (km

                                           `((,x ^ ,y) - ,@rest)
                                           :fail-mode

                                           fm))
                                        fmode
                                        xl
                                        xrrl
                                        xrrrr)))
                                     (when
                                      (eql xrrrl '/)
                                      (return-from
                                       km-handler
                                       (funcall
                                        '(lambda
                                          (fm x y rest)
                                          (km

                                           `((,x ^ ,y) / ,@rest)
                                           :fail-mode

                                           fm))
                                        fmode
                                        xl
                                        xrrl
                                        xrrrr)))
                                     (when
                                      (eql xrrrl '*)
                                      (return-from
                                       km-handler
                                       (funcall
                                        '(lambda
                                          (fm x y rest)
                                          (km

                                           `((,x ^ ,y) * ,@rest)
                                           :fail-mode

                                           fm))
                                        fmode
                                        xl
                                        xrrl
                                        xrrrr))))))
                                  (when
                                   (eql xrrr 'nil)
                                   (return-from
                                    km-handler
                                    (funcall
                                     '(lambda
                                       (fmode expr1 expr2)
                                       (let
                                        ((x
                                          (km-unique

                                           expr1

                                           :fail-mode
                                           fmode))
                                         (y
                                          (km-unique

                                           expr2

                                           :fail-mode
                                           fmode)))
                                        (cond
                                         ((and (numberp x) (numberp y))
                                          (list (expt x y))))))
                                     fmode
                                     xl
                                     xrrl)))))))
                        (when (eql xrl '/)
                          (or (when (consp xrr)
                                (let
                                 ((xrrl (first xrr)) (xrrr (rest xrr)))
                                 (when
                                  (consp xrrr)
                                  (let
                                   ((xrrrl (first xrrr))
                                    (xrrrr (rest xrrr)))
                                   (or
                                    (when
                                     (eql xrrrl '+)
                                     (return-from
                                      km-handler
                                      (funcall
                                       '(lambda
                                         (fm x y rest)
                                         (km

                                          `((,x / ,y) + ,@rest)
                                          :fail-mode

                                          fm))
                                       fmode
                                       xl
                                       xrrl
                                       xrrrr)))
                                    (when
                                     (eql xrrrl '-)
                                     (return-from
                                      km-handler
                                      (funcall
                                       '(lambda
                                         (fm x y rest)
                                         (km

                                          `((,x / ,y) - ,@rest)
                                          :fail-mode

                                          fm))
                                       fmode
                                       xl
                                       xrrl
                                       xrrrr)))
                                    (when
                                     (eql xrrrl '/)
                                     (return-from
                                      km-handler
                                      (funcall
                                       '(lambda
                                         (fm x y rest)
                                         (km

                                          `((,x / ,y) / ,@rest)
                                          :fail-mode

                                          fm))
                                       fmode
                                       xl
                                       xrrl
                                       xrrrr)))
                                    (when
                                     (eql xrrrl '*)
                                     (return-from
                                      km-handler
                                      (funcall
                                       '(lambda
                                         (fm x y rest)
                                         (km

                                          `((,x / ,y) * ,@rest)
                                          :fail-mode

                                          fm))
                                       fmode
                                       xl
                                       xrrl
                                       xrrrr))))))))
                              (return-from km-handler
                                (funcall
                                 '(lambda
                                   (fmode expr rest)
                                   (let
                                    ((x
                                      (km-unique

                                       expr

                                       :fail-mode
                                       fmode))
                                     (y
                                      (km-unique

                                       rest

                                       :fail-mode
                                       fmode)))
                                    (cond
                                     ((number-eq x 0) 0)
                                     ((number-eq y 0) *infinity*)
                                     ((and (numberp x) (numberp y))
                                      (list (/ x y))))))
                                 fmode
                                 xl
                                 xrr))))
                        (when (eql xrl '*)
                          (or (when (consp xrr)
                                (let
                                 ((xrrl (first xrr)) (xrrr (rest xrr)))
                                 (when
                                  (consp xrrr)
                                  (let
                                   ((xrrrl (first xrrr))
                                    (xrrrr (rest xrrr)))
                                   (or
                                    (when
                                     (eql xrrrl '+)
                                     (return-from
                                      km-handler
                                      (funcall
                                       '(lambda
                                         (fm x y rest)
                                         (km

                                          `((,x * ,y) + ,@rest)
                                          :fail-mode

                                          fm))
                                       fmode
                                       xl
                                       xrrl
                                       xrrrr)))
                                    (when
                                     (eql xrrrl '-)
                                     (return-from
                                      km-handler
                                      (funcall
                                       '(lambda
                                         (fm x y rest)
                                         (km

                                          `((,x * ,y) - ,@rest)
                                          :fail-mode

                                          fm))
                                       fmode
                                       xl
                                       xrrl
                                       xrrrr)))
                                    (when
                                     (eql xrrrl '/)
                                     (return-from
                                      km-handler
                                      (funcall
                                       '(lambda
                                         (fm x y rest)
                                         (km

                                          `((,x * ,y) / ,@rest)
                                          :fail-mode

                                          fm))
                                       fmode
                                       xl
                                       xrrl
                                       xrrrr))))))))
                              (return-from km-handler
                                (funcall
                                 '(lambda
                                   (fmode expr rest)
                                   (let
                                    ((x
                                      (km-unique

                                       expr

                                       :fail-mode
                                       fmode))
                                     (y
                                      (km-unique

                                       rest

                                       :fail-mode
                                       fmode)))
                                    (cond
                                     ((and (numberp x) (numberp y))
                                      (list (* x y))))))
                                 fmode
                                 xl
                                 xrr))))
                        (when (eql xrl '-)
                          (or (when (consp xrr)
                                (let
                                 ((xrrl (first xrr)) (xrrr (rest xrr)))
                                 (when
                                  (consp xrrr)
                                  (let
                                   ((xrrrl (first xrrr))
                                    (xrrrr (rest xrrr)))
                                   (or
                                    (when
                                     (eql xrrrl '-)
                                     (return-from
                                      km-handler
                                      (funcall
                                       '(lambda
                                         (fm x y rest)
                                         (km

                                          `((,x - ,y) - ,@rest)
                                          :fail-mode

                                          fm))
                                       fmode
                                       xl
                                       xrrl
                                       xrrrr)))
                                    (when
                                     (eql xrrrl '+)
                                     (return-from
                                      km-handler
                                      (funcall
                                       '(lambda
                                         (fm x y rest)
                                         (km

                                          `((,x - ,y) + ,@rest)
                                          :fail-mode

                                          fm))
                                       fmode
                                       xl
                                       xrrl
                                       xrrrr))))))))
                              (return-from km-handler
                                (funcall
                                 '(lambda
                                   (fmode expr rest)
                                   (let
                                    ((x
                                      (km-unique

                                       expr

                                       :fail-mode
                                       fmode))
                                     (y
                                      (km-unique

                                       rest

                                       :fail-mode
                                       fmode)))
                                    (cond
                                     ((and (numberp x) (numberp y))
                                      (list (- x y))))))
                                 fmode
                                 xl
                                 xrr))))
                        (when (eql xrl '+)
                          (or (when (consp xrr)
                                (let
                                 ((xrrl (first xrr)) (xrrr (rest xrr)))
                                 (when
                                  (consp xrrr)
                                  (let
                                   ((xrrrl (first xrrr))
                                    (xrrrr (rest xrrr)))
                                   (when
                                    (eql xrrrl '-)
                                    (return-from
                                     km-handler
                                     (funcall
                                      '(lambda
                                        (fm x y rest)
                                        (km

                                         `((,x + ,y) - ,@rest)
                                         :fail-mode

                                         fm))
                                      fmode
                                      xl
                                      xrrl
                                      xrrrr)))))))
                              (return-from km-handler
                                (funcall
                                 '(lambda
                                   (fmode expr rest)
                                   (let
                                    ((x
                                      (km-unique

                                       expr

                                       :fail-mode
                                       fmode))
                                     (y
                                      (km-unique

                                       rest

                                       :fail-mode
                                       fmode)))
                                    (cond
                                     ((and (numberp x) (numberp y))
                                      (list (+ x y))))))
                                 fmode
                                 xl
                                 xrr)))))))
                (when (eql xl '|in-situation|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (or (when (eql xrr 'nil)
                            (return-from km-handler
                              (funcall '(lambda
                                         (_fmode situation-expr)
                                         (declare (ignore _fmode))
                                         (in-situation situation-expr))
                                       fmode xrl)))
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (or (when
                                   (consp xrrl)
                                   (let
                                    ((xrrll (first xrrl))
                                     (xrrlr (rest xrrl)))
                                    (when
                                     (eql xrrll '|the|)
                                     (when
                                      (consp xrrlr)
                                      (let
                                       ((xrrlrl (first xrrlr))
                                        (xrrlrr (rest xrrlr)))
                                       (when
                                        (consp xrrlrr)
                                        (let
                                         ((xrrlrrl (first xrrlrr))
                                          (xrrlrrr (rest xrrlrr)))
                                         (when
                                          (eql xrrlrrl '|of|)
                                          (when
                                           (consp xrrlrrr)
                                           (let
                                            ((xrrlrrrl (first xrrlrrr))
                                             (xrrlrrrr (rest xrrlrrr)))
                                            (when
                                             (eql xrrlrrrr 'nil)
                                             (when
                                              (eql xrrr 'nil)
                                              (return-from
                                               km-handler
                                               (funcall
                                                '(lambda
                                                  (_fmode
                                                   situation
                                                   slot
                                                   frame)
                                                  (declare
                                                   (ignore _fmode))
                                                  (cond
                                                   ((and
                                                     (kb-objectp
                                                      situation)
                                                     (isa
                                                      situation
                                                      '|Situation|)
                                                     (already-done
                                                      frame
                                                      slot
                                                      situation))
                                                    (remove-constraints
                                                     (get-vals
                                                      frame
                                                      slot
                                                      'own-properties
                                                      situation)))
                                                   (t
                                                    (in-situation
                                                     situation
                                                     `(|the|
                                                       ,slot
                                                       |of|
                                                       ,frame)))))
                                                fmode
                                                xrl
                                                xrrlrl
                                                xrrlrrrl))))))))))))))
                                  (when
                                   (eql xrrr 'nil)
                                   (return-from
                                    km-handler
                                    (funcall
                                     '(lambda
                                       (_fmode situation-expr km-expr)
                                       (declare (ignore _fmode))
                                       (in-situation
                                        situation-expr
                                        km-expr))
                                     fmode
                                     xrl
                                     xrrl))))))))))
                (when (eql xl '|do|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode action-expr)
                                     (declare (ignore _fmode))
                                     (list (do-action action-expr)))
                                   fmode xrl))))))
                (when (eql xl '|do-and-next|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode action-expr)
                                     (declare (ignore _fmode))
                                     (list
                                      (do-action

                                       action-expr

                                       :change-to-next-situation
                                       t)))
                                   fmode xrl))))))
                (when (eql xl '|do-script|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (fmode script)
                                     (km

                                      `(|forall|
                                        (|the| |actions| |of| ,script)
                                        (|do-and-next| |It|))
                                      :fail-mode

                                      fmode))
                                   fmode xrl))))))
                (when (eql xl '|assert|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode triple-expr)
                                     (declare (ignore _fmode))
                                     (let
                                      ((triple
                                        (km-unique

                                         triple-expr

                                         :fail-mode
                                         'fail)))
                                      (cond
                                       ((not (km-triplep triple))
                                        (report-error
                                         'user-error
                                         "(assert ~a): ~a should evaluate to a triple! (evaluated to ~a instead)!~%"
                                         triple-expr
                                         triple))
                                       (t
                                        (km

                                         `(,(arg1of triple)
                                           |has|
                                           (,(arg2of triple)
                                            (,(arg3of triple)))))))))
                                   fmode xrl))))))
                (when (eql xl '|is-true|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode triple-expr)
                                     (declare (ignore _fmode))
                                     (let
                                      ((triple
                                        (km-unique

                                         triple-expr

                                         :fail-mode
                                         'fail)))
                                      (cond
                                       ((not (km-triplep triple))
                                        (report-error
                                         'user-error
                                         "(assert ~a): ~a should evaluate to a triple! (evaluated to ~a instead)!~%"
                                         triple-expr
                                         triple))
                                       (t
                                        (km

                                         `((|the|
                                            ,(arg2of triple)
                                            |of|
                                            ,(arg1of triple))
                                           |includes|
                                           ,(arg3of triple))
                                         :fail-mode

                                         'fail)))))
                                   fmode xrl))))))
                (when (eql xl '|all-true|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode triples-expr)
                                     (declare (ignore _fmode))
                                     (let
                                      ((triples
                                        (km

                                         triples-expr
                                         :fail-mode

                                         'fail)))
                                      (cond
                                       ((every
                                         #'(lambda
                                            (triple)
                                            (km

                                             `(|is-true| ,triple)
                                             :fail-mode

                                             'fail))
                                         triples)
                                        '(|t|)))))
                                   fmode xrl))))))
                (when (eql xl '|some-true|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode triples-expr)
                                     (declare (ignore _fmode))
                                     (let
                                      ((triples
                                        (km

                                         triples-expr
                                         :fail-mode

                                         'fail)))
                                      (cond
                                       ((some
                                         #'(lambda
                                            (triple)
                                            (km

                                             `(|is-true| ,triple)
                                             :fail-mode

                                             'fail))
                                         triples)
                                        '(|t|)))))
                                   fmode xrl))))))
                (when (eql xl '|next-situation|)
                  (when (eql xr 'nil)
                    (return-from km-handler
                      (funcall '(lambda
                                 (_fmode)
                                 (declare (ignore _fmode))
                                 (cond
                                  ((am-in-local-situation)
                                   (list
                                    (do-action

                                     nil

                                     :change-to-next-situation
                                     t)))
                                  (t
                                   (report-error
                                    'user-error
                                    "Can only do (next-situation) from within a situation!~%"))))
                               fmode))))
                (when (eql xl '|curr-situation|)
                  (when (eql xr 'nil)
                    (return-from km-handler
                      (funcall '(lambda
                                 (_fmode)
                                 (declare (ignore _fmode))
                                 (list (curr-situation)))
                               fmode))))
                (when (eql xl '|ignore-result|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (fmode expr)
                                     (km expr :fail-mode 'fail)
                                     nil)
                                   fmode xrl))))))
                (when (eql xl '|in-every-situation|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (consp xrr)
                        (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                          (when (eql xrrr 'nil)
                            (return-from km-handler
                              (funcall '(lambda
                                         (fmode
                                          situation-class
                                          km-expr)
                                         (cond
                                          ((not
                                            (is-subclass-of
                                             situation-class
                                             '|Situation|))
                                           (report-error
                                            'user-error
                                            "~a:~%   Can't do this! (~a is not a subclass of Situation!)~%"
                                            `(|in-every-situation|
                                              ,situation-class
                                              ,km-expr)
                                            situation-class))
                                          (t
                                           (let
                                            ((modified-expr
                                              (sublis

                                               '((|TheSituation|
                                                  . |Self|)
                                                 (|Self| . |SubSelf|))
                                               km-expr)))
                                            (km

                                             `(|in-situation|
                                               ,*global-situation*
                                               (|every|
                                                ,situation-class
                                                |has|
                                                (|assertions|
                                                 (',modified-expr))))
                                             :fail-mode

                                             fmode)))))
                                       fmode xrl xrrl))))))))
                (when (eql xl '|graph|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (or (when (eql xrr 'nil)
                            (return-from km-handler
                              (funcall '(lambda
                                         (fmode expr)
                                         (graph
                                          (km-unique

                                           expr

                                           :fail-mode
                                           fmode)))
                                       fmode xrl)))
                          (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrr 'nil)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (fmode expr depth)
                                    (cond
                                     ((not (integerp depth))
                                      (report-error
                                       'user-error
                                       "Depth for graph must be an integer (was ~a)!~%"
                                       depth))
                                     (t
                                      (graph
                                       (km-unique

                                        expr

                                        :fail-mode
                                        fmode)
                                       depth))))
                                  fmode
                                  xrl
                                  xrrl)))))))))
                (when (eql xl '|new-context|)
                  (when (eql xr 'nil)
                    (return-from km-handler
                      (funcall '(lambda
                                 (_fmode)
                                 (declare (ignore _fmode))
                                 (clear-obj-stack)
                                 '(|t|))
                               fmode))))
                (when (eql xl '|thelast|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode frame)
                                     (declare (ignore _fmode))
                                     (let
                                      ((last-instance
                                        (search-stack frame)))
                                      (cond
                                       (last-instance
                                        (list last-instance)))))
                                   fmode xrl))))))
                (when (eql xl '|the+|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (or (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (or (when
                                   (eql xrrl '|of|)
                                   (when
                                    (consp xrrr)
                                    (let
                                     ((xrrrl (first xrrr))
                                      (xrrrr (rest xrrr)))
                                     (when
                                      (eql xrrrr 'nil)
                                      (return-from
                                       km-handler
                                       (funcall
                                        '(lambda
                                          (_fmode slot frameadd)
                                          (declare (ignore _fmode))
                                          (km

                                           `(|the+|
                                             |Thing|
                                             |with|
                                             (,(invert-slot slot)
                                              (,frameadd)))))
                                        fmode
                                        xrl
                                        xrrrl))))))
                                  (when
                                   (consp xrrr)
                                   (let
                                    ((xrrrl (first xrrr))
                                     (xrrrr (rest xrrr)))
                                    (when
                                     (eql xrrrl '|of|)
                                     (when
                                      (consp xrrrr)
                                      (let
                                       ((xrrrrl (first xrrrr))
                                        (xrrrrr (rest xrrrr)))
                                       (when
                                        (eql xrrrrr 'nil)
                                        (return-from
                                         km-handler
                                         (funcall
                                          '(lambda
                                            (_fmode
                                             class
                                             slot
                                             frameadd)
                                            (declare (ignore _fmode))
                                            (km

                                             `(|the+|
                                               ,class
                                               |with|
                                               (,(invert-slot slot)
                                                (,frameadd)))))
                                          fmode
                                          xrl
                                          xrrl
                                          xrrrrl))))))))
                                  (when
                                   (eql xrrl '|with|)
                                   (return-from
                                    km-handler
                                    (funcall
                                     '(lambda
                                       (_fmode frame slotsvals)
                                       (declare (ignore _fmode))
                                       (let
                                        ((val
                                          (km-unique

                                           `(|every|
                                             ,frame
                                             |with|
                                             ,@slotsvals)

                                           :fail-mode
                                           'fail)))
                                        (cond
                                         (val (list val))
                                         ((are-slotsvals slotsvals)
                                          (let
                                           ((existential-expr
                                             (cond
                                              ((and
                                                (null slotsvals)
                                                (pathp frame))
                                               (path-to-existential-expr
                                                frame))
                                              (t
                                               `(|a|
                                                 ,frame
                                                 |with|
                                                 ,@slotsvals)))))
                                           (mapcar
                                            #'eval-instance
                                            (km existential-expr)))))))
                                     fmode
                                     xrl
                                     xrrr))))))
                          (when (eql xrr 'nil)
                            (return-from km-handler
                              (funcall '(lambda
                                         (fmode frame)
                                         (km

                                          `(|the+| ,frame |with|)
                                          :fail-mode

                                          fmode))
                                       fmode xrl)))))))
                (when (eql xl '|a+|)
                  (return-from km-handler
                    (funcall '(lambda (fmode rest)
                                (km `(|the+| ,@rest) :fail-mode fmode))
                             fmode xr)))
                (when (eql xl '|if|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (consp xrr)
                        (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                          (when (eql xrrl '|then|)
                            (when (consp xrrr)
                              (let ((xrrrl (first xrrr))
                                    (xrrrr (rest xrrr)))
                                (or
                                 (when
                                  (eql xrrrr 'nil)
                                  (return-from
                                   km-handler
                                   (funcall
                                    '(lambda
                                      (fmode condition action)
                                      (km

                                       `(|if|
                                         ,condition
                                         |then|
                                         ,action
                                         |else|
                                         nil)
                                       :fail-mode

                                       fmode))
                                    fmode
                                    xrl
                                    xrrrl)))
                                 (when
                                  (consp xrrrr)
                                  (let
                                   ((xrrrrl (first xrrrr))
                                    (xrrrrr (rest xrrrr)))
                                   (when
                                    (eql xrrrrl '|else|)
                                    (when
                                     (consp xrrrrr)
                                     (let
                                      ((xrrrrrl (first xrrrrr))
                                       (xrrrrrr (rest xrrrrr)))
                                      (when
                                       (eql xrrrrrr 'nil)
                                       (return-from
                                        km-handler
                                        (funcall
                                         '(lambda
                                           (fmode
                                            condition
                                            action
                                            altaction)
                                           (let
                                            ((test-result
                                              (km

                                               condition
                                               :fail-mode

                                               'fail)))
                                            (cond
                                             ((not
                                               (member

                                                test-result
                                                '(nil |f| f)))
                                              (km

                                               action
                                               :fail-mode

                                               fmode))
                                             (t
                                              (km

                                               altaction
                                               :fail-mode

                                               fmode)))))
                                         fmode
                                         xrl
                                         xrrrl
                                         xrrrrrl)))))))))))))))))
                (when (eql xl '|not|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode x)
                                     (declare (ignore _fmode))
                                     (cond
                                      ((not (km x :fail-mode 'fail))
                                       '(|t|))))
                                   fmode xrl))))))
                (when (eql xl '|numberp|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode x)
                                     (declare (ignore _fmode))
                                     (cond
                                      ((numberp
                                        (km x :fail-mode 'fail))
                                       '(|t|))))
                                   fmode xrl))))))
                (when (eql xl '|allof|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (consp xrr)
                        (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                          (or (when (eql xrrl '|where|)
                                (when
                                 (consp xrrr)
                                 (let
                                  ((xrrrl (first xrrr))
                                   (xrrrr (rest xrrr)))
                                  (or
                                   (when
                                    (eql xrrrr 'nil)
                                    (return-from
                                     km-handler
                                     (funcall
                                      '(lambda
                                        (fmode set test)
                                        (km

                                         `(|forall|
                                           ,set
                                           |where|
                                           ,test
                                           (|It|))
                                         :fail-mode

                                         fmode))
                                      fmode
                                      xrl
                                      xrrrl)))
                                   (when
                                    (consp xrrrr)
                                    (let
                                     ((xrrrrl (first xrrrr))
                                      (xrrrrr (rest xrrrr)))
                                     (when
                                      (eql xrrrrl '|must|)
                                      (when
                                       (consp xrrrrr)
                                       (let
                                        ((xrrrrrl (first xrrrrr))
                                         (xrrrrrr (rest xrrrrr)))
                                        (when
                                         (eql xrrrrrr 'nil)
                                         (return-from
                                          km-handler
                                          (funcall
                                           '(lambda
                                             (fmode set test2 test)
                                             (cond
                                              ((every
                                                #'(lambda
                                                   (instance)
                                                   (km

                                                    (subst

                                                     instance
                                                     '|It|
                                                     test)
                                                    :fail-mode

                                                    'fail))
                                                (km

                                                 `(|allof|
                                                   ,set
                                                   |where|
                                                   ,test2)
                                                 :fail-mode

                                                 'fail))
                                               '(|t|))))
                                           fmode
                                           xrl
                                           xrrrl
                                           xrrrrrl))))))))))))
                              (when (eql xrrl '|must|)
                                (when
                                 (consp xrrr)
                                 (let
                                  ((xrrrl (first xrrr))
                                   (xrrrr (rest xrrr)))
                                  (when
                                   (eql xrrrr 'nil)
                                   (return-from
                                    km-handler
                                    (funcall
                                     '(lambda
                                       (fmode set test)
                                       (cond
                                        ((every
                                          #'(lambda
                                             (instance)
                                             (km

                                              (subst

                                               instance
                                               '|It|
                                               test)
                                              :fail-mode

                                              'fail))
                                          (km set :fail-mode 'fail))
                                         '(|t|))))
                                     fmode
                                     xrl
                                     xrrrl))))))))))))
                (when (eql xl '|oneof|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (consp xrr)
                        (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                          (when (eql xrrl '|where|)
                            (when (consp xrrr)
                              (let ((xrrrl (first xrrr))
                                    (xrrrr (rest xrrr)))
                                (when
                                 (eql xrrrr 'nil)
                                 (return-from
                                  km-handler
                                  (funcall
                                   '(lambda
                                     (fmode set test)
                                     (let
                                      ((answer
                                        (find-if

                                         #'(lambda
                                            (member)
                                            (km

                                             (subst member '|It| test)
                                             :fail-mode

                                             'fail))
                                         (km set :fail-mode 'fail))))
                                      (cond (answer (list answer)))))
                                   fmode
                                   xrl
                                   xrrrl)))))))))))
                (when (eql xl '|theoneof|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (consp xrr)
                        (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                          (when (eql xrrl '|where|)
                            (when (consp xrrr)
                              (let ((xrrrl (first xrrr))
                                    (xrrrr (rest xrrr)))
                                (when
                                 (eql xrrrr 'nil)
                                 (return-from
                                  km-handler
                                  (funcall
                                   '(lambda
                                     (fmode set test)
                                     (let
                                      ((val
                                        (km-unique

                                         `(|forall|
                                           ,set
                                           |where|
                                           ,test
                                           (|It|))

                                         :fail-mode
                                         fmode)))
                                      (cond (val (list val)))))
                                   fmode
                                   xrl
                                   xrrrl)))))))))))
                (when (eql xl '|forall|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (consp xrr)
                        (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                          (or (when (eql xrrr 'nil)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (fmode set value)
                                    (km

                                     `(|forall| ,set |where| t ,value)
                                     :fail-mode

                                     fmode))
                                  fmode
                                  xrl
                                  xrrl)))
                              (when (eql xrrl '|where|)
                                (when
                                 (consp xrrr)
                                 (let
                                  ((xrrrl (first xrrr))
                                   (xrrrr (rest xrrr)))
                                  (when
                                   (consp xrrrr)
                                   (let
                                    ((xrrrrl (first xrrrr))
                                     (xrrrrr (rest xrrrr)))
                                    (when
                                     (eql xrrrrr 'nil)
                                     (return-from
                                      km-handler
                                      (funcall
                                       '(lambda
                                         (_fmode set constraint value)
                                         (declare (ignore _fmode))
                                         (remove

                                          nil
                                          (my-mapcan
                                           #'(lambda
                                              (member)
                                              (cond
                                               ((km

                                                 (subst

                                                  member
                                                  '|It|
                                                  constraint)
                                                 :fail-mode

                                                 'fail)
                                                (km

                                                 (subst

                                                  member
                                                  '|It|
                                                  value)
                                                 :fail-mode

                                                 'fail))))
                                           (km set :fail-mode 'fail))))
                                       fmode
                                       xrl
                                       xrrrl
                                       xrrrrl))))))))))))))
                (when (eql xl '|allof2|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (consp xrr)
                        (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                          (or (when (eql xrrl '|where|)
                                (when
                                 (consp xrrr)
                                 (let
                                  ((xrrrl (first xrrr))
                                   (xrrrr (rest xrrr)))
                                  (or
                                   (when
                                    (eql xrrrr 'nil)
                                    (return-from
                                     km-handler
                                     (funcall
                                      '(lambda
                                        (fmode set test)
                                        (km

                                         `(|forall2|
                                           ,set
                                           |where|
                                           ,test
                                           (|It2|))
                                         :fail-mode

                                         fmode))
                                      fmode
                                      xrl
                                      xrrrl)))
                                   (when
                                    (consp xrrrr)
                                    (let
                                     ((xrrrrl (first xrrrr))
                                      (xrrrrr (rest xrrrr)))
                                     (when
                                      (eql xrrrrl '|must|)
                                      (when
                                       (consp xrrrrr)
                                       (let
                                        ((xrrrrrl (first xrrrrr))
                                         (xrrrrrr (rest xrrrrr)))
                                        (when
                                         (eql xrrrrrr 'nil)
                                         (return-from
                                          km-handler
                                          (funcall
                                           '(lambda
                                             (fmode set test2 test)
                                             (cond
                                              ((every
                                                #'(lambda
                                                   (instance)
                                                   (km

                                                    (subst

                                                     instance
                                                     '|It2|
                                                     test)
                                                    :fail-mode

                                                    'fail))
                                                (km

                                                 `(|allof2|
                                                   ,set
                                                   |where|
                                                   ,test2)
                                                 :fail-mode

                                                 'fail))
                                               '(|t|))))
                                           fmode
                                           xrl
                                           xrrrl
                                           xrrrrrl))))))))))))
                              (when (eql xrrl '|must|)
                                (when
                                 (consp xrrr)
                                 (let
                                  ((xrrrl (first xrrr))
                                   (xrrrr (rest xrrr)))
                                  (when
                                   (eql xrrrr 'nil)
                                   (return-from
                                    km-handler
                                    (funcall
                                     '(lambda
                                       (fmode set test)
                                       (cond
                                        ((every
                                          #'(lambda
                                             (instance)
                                             (km

                                              (subst

                                               instance
                                               '|It2|
                                               test)
                                              :fail-mode

                                              'fail))
                                          (km set :fail-mode 'fail))
                                         '(|t|))))
                                     fmode
                                     xrl
                                     xrrrl))))))))))))
                (when (eql xl '|oneof2|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (consp xrr)
                        (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                          (when (eql xrrl '|where|)
                            (when (consp xrrr)
                              (let ((xrrrl (first xrrr))
                                    (xrrrr (rest xrrr)))
                                (when
                                 (eql xrrrr 'nil)
                                 (return-from
                                  km-handler
                                  (funcall
                                   '(lambda
                                     (fmode set test)
                                     (let
                                      ((answer
                                        (find-if

                                         #'(lambda
                                            (member)
                                            (km

                                             (subst member '|It2| test)
                                             :fail-mode

                                             'fail))
                                         (km set :fail-mode 'fail))))
                                      (cond (answer (list answer)))))
                                   fmode
                                   xrl
                                   xrrrl)))))))))))
                (when (eql xl '|forall2|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (consp xrr)
                        (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                          (or (when (eql xrrr 'nil)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (fmode set value)
                                    (km

                                     `(|forall2| ,set |where| t ,value)
                                     :fail-mode

                                     fmode))
                                  fmode
                                  xrl
                                  xrrl)))
                              (when (eql xrrl '|where|)
                                (when
                                 (consp xrrr)
                                 (let
                                  ((xrrrl (first xrrr))
                                   (xrrrr (rest xrrr)))
                                  (when
                                   (consp xrrrr)
                                   (let
                                    ((xrrrrl (first xrrrr))
                                     (xrrrrr (rest xrrrr)))
                                    (when
                                     (eql xrrrrr 'nil)
                                     (return-from
                                      km-handler
                                      (funcall
                                       '(lambda
                                         (_fmode set constraint value)
                                         (declare (ignore _fmode))
                                         (remove

                                          'nil
                                          (my-mapcan
                                           #'(lambda
                                              (member)
                                              (cond
                                               ((km

                                                 (subst

                                                  member
                                                  '|It2|
                                                  constraint)
                                                 :fail-mode

                                                 'fail)
                                                (km

                                                 (subst

                                                  member
                                                  '|It2|
                                                  value)
                                                 :fail-mode

                                                 'fail))))
                                           (km set :fail-mode 'fail))))
                                       fmode
                                       xrl
                                       xrrrl
                                       xrrrrl))))))))))))))
                (when (eql xl '|theoneof2|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (consp xrr)
                        (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                          (when (eql xrrl '|where|)
                            (when (consp xrrr)
                              (let ((xrrrl (first xrrr))
                                    (xrrrr (rest xrrr)))
                                (when
                                 (eql xrrrr 'nil)
                                 (return-from
                                  km-handler
                                  (funcall
                                   '(lambda
                                     (fmode set test)
                                     (let
                                      ((val
                                        (km-unique

                                         `(|forall2|
                                           ,set
                                           |where|
                                           ,test
                                           (|It2|))

                                         :fail-mode
                                         fmode)))
                                      (cond (val (list val)))))
                                   fmode
                                   xrl
                                   xrrrl)))))))))))
                (when (eql xl 'function)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode lispcode)
                                     (declare (ignore _fmode))
                                     (listify
                                      (funcall
                                       (eval
                                        (list 'function lispcode)))))
                                   fmode xrl))))))
                (when (eql xl '|the1|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (or (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrl '|of|)
                                (when
                                 (consp xrrr)
                                 (let
                                  ((xrrrl (first xrrr))
                                   (xrrrr (rest xrrr)))
                                  (when
                                   (eql xrrrr 'nil)
                                   (return-from
                                    km-handler
                                    (funcall
                                     '(lambda
                                       (fmode slot frameadd)
                                       (km

                                        `(|the1|
                                          |of|
                                          (|the| ,slot |of| ,frameadd))
                                        :fail-mode

                                        fmode))
                                     fmode
                                     xrl
                                     xrrrl))))))))
                          (when (eql xrl '|of|)
                            (when (consp xrr)
                              (let ((xrrl (first xrr))
                                    (xrrr (rest xrr)))
                                (when
                                 (eql xrrr 'nil)
                                 (return-from
                                  km-handler
                                  (funcall
                                   '(lambda
                                     (fmode frameadd)
                                     (let
                                      ((multiargs
                                        (km

                                         frameadd
                                         :fail-mode

                                         fmode)))
                                      (mapcar
                                       #'(lambda
                                          (multiarg)
                                          (cond
                                           ((km-structured-list-valp
                                             multiarg)
                                            (arg1of multiarg))
                                           (t multiarg)))
                                       multiargs)))
                                   fmode
                                   xrrl))))))))))
                (when (eql xl '|the2|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (or (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrl '|of|)
                                (when
                                 (consp xrrr)
                                 (let
                                  ((xrrrl (first xrrr))
                                   (xrrrr (rest xrrr)))
                                  (when
                                   (eql xrrrr 'nil)
                                   (return-from
                                    km-handler
                                    (funcall
                                     '(lambda
                                       (fmode slot frameadd)
                                       (km

                                        `(|the2|
                                          |of|
                                          (|the| ,slot |of| ,frameadd))
                                        :fail-mode

                                        fmode))
                                     fmode
                                     xrl
                                     xrrrl))))))))
                          (when (eql xrl '|of|)
                            (when (consp xrr)
                              (let ((xrrl (first xrr))
                                    (xrrr (rest xrr)))
                                (when
                                 (eql xrrr 'nil)
                                 (return-from
                                  km-handler
                                  (funcall
                                   '(lambda
                                     (fmode frameadd)
                                     (let
                                      ((multiargs
                                        (km

                                         frameadd
                                         :fail-mode

                                         fmode)))
                                      (mapcar
                                       #'(lambda
                                          (multiarg)
                                          (cond
                                           ((km-structured-list-valp
                                             multiarg)
                                            (arg2of multiarg))))
                                       multiargs)))
                                   fmode
                                   xrrl))))))))))
                (when (eql xl '|the3|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (or (when (consp xrr)
                            (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                              (when (eql xrrl '|of|)
                                (when
                                 (consp xrrr)
                                 (let
                                  ((xrrrl (first xrrr))
                                   (xrrrr (rest xrrr)))
                                  (when
                                   (eql xrrrr 'nil)
                                   (return-from
                                    km-handler
                                    (funcall
                                     '(lambda
                                       (fmode slot frameadd)
                                       (km

                                        `(|the3|
                                          |of|
                                          (|the| ,slot |of| ,frameadd))
                                        :fail-mode

                                        fmode))
                                     fmode
                                     xrl
                                     xrrrl))))))))
                          (when (eql xrl '|of|)
                            (when (consp xrr)
                              (let ((xrrl (first xrr))
                                    (xrrr (rest xrr)))
                                (when
                                 (eql xrrr 'nil)
                                 (return-from
                                  km-handler
                                  (funcall
                                   '(lambda
                                     (fmode frameadd)
                                     (let
                                      ((multiargs
                                        (km

                                         frameadd
                                         :fail-mode

                                         fmode)))
                                      (mapcar
                                       #'(lambda
                                          (multiarg)
                                          (cond
                                           ((km-structured-list-valp
                                             multiarg)
                                            (arg3of multiarg))))
                                       multiargs)))
                                   fmode
                                   xrrl))))))))))
                (when (eql xl '|theN|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (consp xrr)
                        (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                          (when (eql xrrl '|of|)
                            (when (consp xrrr)
                              (let ((xrrrl (first xrrr))
                                    (xrrrr (rest xrrr)))
                                (when
                                 (eql xrrrr 'nil)
                                 (return-from
                                  km-handler
                                  (funcall
                                   '(lambda
                                     (fmode nexpr frameadd)
                                     (let
                                      ((n (km-unique nexpr))
                                       (multiargs
                                        (km

                                         frameadd
                                         :fail-mode

                                         fmode)))
                                      (cond
                                       ((or (not (integerp n)) (< n 1))
                                        (report-error
                                         'user-error
                                         "Doing ~a. ~a should evaluate to a non-negative integer!~%"
                                         `(|the| ,nexpr |of| ,frameadd)
                                         nexpr))
                                       (t
                                        (mapcar
                                         #'(lambda
                                            (multiarg)
                                            (cond
                                             ((km-structured-list-valp
                                               multiarg)
                                              (elt multiarg n))
                                             ((eq n 1) multiarg)))
                                         multiargs)))))
                                   fmode
                                   xrl
                                   xrrrl)))))))))))
                (when (eql xl :|set|)
                  (return-from km-handler
                    (funcall '(lambda (fmode exprs)
                                (declare (ignore fmode))
                                (my-mapcan
                                 #'(lambda
                                    (expr)
                                    (km expr :fail-mode 'fail))
                                 exprs))
                             fmode xr)))
                (when (eql xl :|seq|)
                  (return-from km-handler
                    (funcall '(lambda (fmode exprs)
                                (declare (ignore fmode))
                                (let
                                 ((sequence
                                   (my-mapcan
                                    #'(lambda
                                       (expr)
                                       (km expr :fail-mode 'fail))
                                    exprs)))
                                 (cond
                                  (sequence `((:|seq| ,@sequence))))))
                             fmode xr)))
                (when (eql xl :|args|)
                  (return-from km-handler
                    (funcall '(lambda (fmode exprs)
                                (declare (ignore fmode))
                                (let
                                 ((sequence
                                   (my-mapcan
                                    #'(lambda
                                       (expr)
                                       (km expr :fail-mode 'fail))
                                    exprs)))
                                 (cond
                                  (sequence `((:|args| ,@sequence))))))
                             fmode xr)))
                (when (eql xl :|triple|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (consp xrr)
                        (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                          (when (consp xrrr)
                            (let ((xrrrl (first xrrr))
                                  (xrrrr (rest xrrr)))
                              (when (eql xrrrr 'nil)
                                (return-from
                                 km-handler
                                 (funcall
                                  '(lambda
                                    (fmode
                                     frame-expr
                                     slot-expr
                                     val-expr)
                                    (let
                                     ((frame
                                       (km-unique

                                        frame-expr

                                        :fail-mode
                                        fmode))
                                      (slot
                                       (km-unique

                                        slot-expr

                                        :fail-mode
                                        fmode))
                                      (val
                                       (vals-to-val
                                        (km

                                         val-expr
                                         :fail-mode

                                         fmode))))
                                     (list
                                      (list
                                       :|triple|
                                       frame
                                       slot
                                       val))))
                                  fmode
                                  xrl
                                  xrrl
                                  xrrrl))))))))))
                (when (eql xl '|showme|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode km-expr)
                                     (declare (ignore _fmode))
                                     (showme km-expr))
                                   fmode xrl))))))
                (when (eql xl '|showme-all|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode km-expr)
                                     (declare (ignore _fmode))
                                     (showme-all km-expr))
                                   fmode xrl))))))
                (when (eql xl '|evaluate-all|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode km-expr)
                                     (declare (ignore _fmode))
                                     (evaluate-all km-expr))
                                   fmode xrl))))))
                (when (eql xl '|showme-here|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode km-expr)
                                     (declare (ignore _fmode))
                                     (showme
                                      km-expr
                                      (list (curr-situation))))
                                   fmode xrl))))))
                (when (eql xl 'quote)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (fmode expr)
                                     (let
                                      ((processed-expr
                                        (process-unquotes

                                         expr

                                         :fail-mode
                                         'fail)))
                                      (cond
                                       (processed-expr
                                        (list
                                         (list
                                          'quote
                                          processed-expr))))))
                                   fmode xrl))))))
                (when (eql xl 'unquote)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (fmode expr)
                                     (report-error
                                      'user-error
                                      "Doing #,~a: You can't unquote something without it first being quoted!~%"
                                      expr))
                                   fmode xrl))))))
                (when (eql xl '|delete|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (fmode km-expr)
                                     (mapcar
                                      #'delete-frame
                                      (km km-expr :fail-mode fmode)))
                                   fmode xrl))))))
                (when (eql xl '|evaluate|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (fmode expr)
                                     (let
                                      ((quoted-exprs
                                        (km expr :fail-mode fmode)))
                                      (remove

                                       nil
                                       (my-mapcan
                                        #'(lambda
                                           (quoted-expr)
                                           (cond
                                            ((member

                                              quoted-expr
                                              '(|f| f))
                                             nil)
                                            ((and
                                              (pairp quoted-expr)
                                              (eq
                                               (first quoted-expr)
                                               'quote))
                                             (km

                                              (second quoted-expr)
                                              :fail-mode

                                              fmode))
                                            (t
                                             (report-error
                                              'user-error
                                              "(evaluate ~a)~%evaluate should be given a quoted expression to evaluate!~%"
                                              quoted-expr))))
                                        quoted-exprs))))
                                   fmode xrl))))))
                (when (eql xl '|exists|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (fmode frame)
                                     (report-error
                                      'user-warning
                                      "(exists ~a): (exists <expr>) has been renamed (has-value <expr>) in KM 1.4.~%       Please update your KB! Continuing...~%"
                                      frame)
                                     (km

                                      `(|has-value| ,frame)
                                      :fail-mode

                                      fmode))
                                   fmode xrl))))))
                (when (eql xl '|has-value|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode frame)
                                     (declare (ignore _fmode))
                                     (km frame :fail-mode 'fail))
                                   fmode xrl))))))
                (when (eql xl '|print|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode expr)
                                     (declare (ignore _fmode))
                                     (let
                                      ((vals
                                        (km expr :fail-mode 'fail)))
                                      (km-format t "~a~%" vals)
                                      vals))
                                   fmode xrl))))))
                (when (eql xl '|format|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (consp xrr)
                        (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                          (return-from km-handler
                            (funcall '(lambda
                                       (_fmode flag string arguments)
                                       (declare (ignore _fmode))
                                       (cond
                                        ((eq flag '|t|)
                                         (apply
                                          #'format
                                          `(t
                                            ,string
                                            ,@(mapcar
                                               #'(lambda
                                                  (arg)
                                                  (km

                                                   arg
                                                   :fail-mode

                                                   'fail))
                                               arguments)))
                                         '(|t|))
                                        ((member flag '(|nil| nil))
                                         (list
                                          (apply
                                           #'format
                                           `(nil
                                             ,string
                                             ,@(mapcar
                                                #'(lambda
                                                   (arg)
                                                   (km

                                                    arg
                                                    :fail-mode

                                                    'fail))
                                                arguments)))))
                                        (t
                                         (report-error
                                          'user-error
                                          "~a: Second argument must be `t' or `nil', not `~a'!~%"
                                          `(|format|
                                            ,flag
                                            ,string
                                            ,@arguments)
                                          flag))))
                                     fmode xrl xrrl xrrr)))))))
                (when (eql xl '|km-format|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (consp xrr)
                        (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                          (return-from km-handler
                            (funcall '(lambda
                                       (_fmode flag string arguments)
                                       (declare (ignore _fmode))
                                       (cond
                                        ((eq flag '|t|)
                                         (apply
                                          #'km-format
                                          `(t
                                            ,string
                                            ,@(mapcar
                                               #'(lambda
                                                  (arg)
                                                  (km

                                                   arg
                                                   :fail-mode

                                                   'fail))
                                               arguments)))
                                         '(|t|))
                                        ((member flag '(|nil| nil))
                                         (list
                                          (apply
                                           #'km-format
                                           `(nil
                                             ,string
                                             ,@(mapcar
                                                #'(lambda
                                                   (arg)
                                                   (km

                                                    arg
                                                    :fail-mode

                                                    'fail))
                                                arguments)))))
                                        (t
                                         (report-error
                                          'user-error
                                          "~a: Second argument must be `t' or `nil', not `~a'!~%"
                                          `(|km-format|
                                            ,flag
                                            ,string
                                            ,@arguments)
                                          flag))))
                                     fmode xrl xrrl xrrr)))))))
                (when (eql xl '|andify|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (fmode expr)
                                     (list
                                      (cons
                                       ':|seq|
                                       (andify
                                        (km expr :fail-mode fmode)))))
                                   fmode xrl))))))
                (when (eql xl '|make-sentence|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode expr)
                                     (declare (ignore _fmode))
                                     (let
                                      ((text
                                        (km expr :fail-mode 'fail)))
                                      (make-comment
                                       (km-format
                                        nil
                                        "anglifying ~a"
                                        text))
                                      (list (make-sentence text))))
                                   fmode xrl))))))
                (when (eql xl '|make-phrase|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (_fmode expr)
                                     (declare (ignore _fmode))
                                     (let
                                      ((text
                                        (km expr :fail-mode 'fail)))
                                      (make-comment
                                       (km-format
                                        nil
                                        "anglifying ~a"
                                        text))
                                      (list (make-phrase text))))
                                   fmode xrl))))))
                (when (eql xl '|pluralize|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (fmode expr)
                                     (report-error
                                      'user-error
                                      "(pluralize ~a): pluralize is no longer defined in KM1.4 - use \"-s\" suffix instead!~%"
                                      expr))
                                   fmode xrl))))))
                (when (eql xl '|an|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrl '|instance|)
                        (when (consp xrr)
                          (let ((xrrl (first xrr)) (xrrr (rest xrr)))
                            (when (eql xrrl '|of|)
                              (return-from km-handler
                                (funcall
                                 '(lambda
                                   (_fmode rest)
                                   (declare (ignore _fmode))
                                   (mapcar
                                    #'create-instance
                                    (km rest :fail-mode 'fail)))
                                 fmode
                                 xrrr)))))))))
                (when (eql xl '|reverse|)
                  (when (consp xr)
                    (let ((xrl (first xr)) (xrr (rest xr)))
                      (when (eql xrr 'nil)
                        (return-from km-handler
                          (funcall '(lambda
                                     (fmode seq-expr)
                                     (let
                                      ((seq
                                        (km-unique

                                         seq-expr

                                         :fail-mode
                                         fmode)))
                                      (cond
                                       ((null seq) nil)
                                       ((km-seqp seq)
                                        (list
                                         (cons
                                          ':|seq|
                                          (reverse (rest seq)))))
                                       (t
                                        (report-error
                                         'user-error
                                         "Attempting to reverse a non-sequence ~a!~%[Sequences should be of the form (:seq <e1> ... <en>)]~%"
                                         seq-expr)))))
                                   fmode xrl)))))))))
        (when (eql x '|nil|)
          (return-from km-handler
            (funcall '(lambda (_fmode) (declare (ignore _fmode)) nil)
                     fmode)))
        (when (eql x 'nil)
          (return-from km-handler
            (funcall '(lambda (_fmode) (declare (ignore _fmode)) nil)
                     fmode)))
        (return-from km-handler
          (funcall '(lambda (fmode0 path)
                      (cond ((atom path)
                             (cond ((no-reserved-keywords (list path))
                                    (list path))))
                            ((not (listp path))
                             (report-error 'program-error
                                           "Failed to find km handler for ~a!~%"
                                           path))
                            ((not (no-reserved-keywords path)) nil)
                            ((singletonp path)
                             (km (car path) :fail-mode fmode0))
                            ((oddp (length path))
                             (cond ((structured-slotp
                                     (last-el (butlast path)))
                                    (follow-multidepth-path

                                     (km

                                      (butlast (butlast path))
                                      :fail-mode

                                      fmode0)
                                     (last-el (butlast path))
                                     (last-el path)

                                     :fail-mode
                                     fmode0))
                                   (t
                                    (vals-in-class
                                     (km

                                      (butlast path)
                                      :fail-mode

                                      fmode0)
                                     (last-el path)))))
                            ((evenp (length path))
                             (let* ((frameadd
                                     (cond
                                      ((pairp path) (first path))
                                      (t (butlast path))))
                                    (slot (last-el path)))
                               (cond
                                ((structured-slotp slot)
                                 (follow-multidepth-path

                                  (km frameadd :fail-mode fmode0)
                                  slot
                                  '*

                                  :fail-mode
                                  fmode0))
                                (t
                                 (let*
                                  ((fmode
                                    (cond
                                     ((built-in-aggregation-slot slot)
                                      'fail)
                                     (t fmode0)))
                                   (frames
                                    (km frameadd :fail-mode fmode)))
                                  (cond
                                   ((not
                                     (equal
                                      frames
                                      (val-to-vals frameadd)))
                                    (km

                                     `(,(vals-to-val frames) ,slot)
                                     :fail-mode

                                     fmode))
                                   (t
                                    (km-multi-slotvals

                                     frames
                                     slot

                                     :fail-mode
                                     fmode))))))))))
                   fmode x)))))

(setq *km-handler-function* #'compiled-km-handler-function)

;;; This file was generated by (write-compiled-handlers) in compiler.lisp.
;;; This partially flattens the code assigned to *km-handler-list*, which results in
;;; 10%-30% faster execution (10%-30%) at run-time. Loading of this file is optional, 
;;; KM will be slower if it's not loaded. For the legible, unflattened source of this
;;; flattened code, see the file interpreter.lisp.

;;; ==================== END OF MACHINE-GENERATED FILE ====================

;;; FILE: licence.lisp

;;; File: licence.lisp
;;; Author: Peter Clark
;;; Date: 2000
;;; Purpose: Recite GPL to the user.

(defun licence ()
  (format t "
		    GNU GENERAL PUBLIC LICENSE
		       Version 2, June 1991

 Copyright (C) 1989, 1991 Free Software Foundation, Inc.
                       59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

			    Preamble

  The licenses for most software are designed to take away your
freedom to share and change it.  By contrast, the GNU General Public
License is intended to guarantee your freedom to share and change free
software--to make sure the software is free for all its users.  This
General Public License applies to most of the Free Software
Foundation's software and to any other program whose authors commit to
using it.  (Some other Free Software Foundation software is covered by
the GNU Library General Public License instead.)  You can apply it to
your programs, too.

  When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
this service if you wish), that you receive source code or can get it
if you want it, that you can change the software or use pieces of it
in new free programs; and that you know you can do these things.

  To protect your rights, we need to make restrictions that forbid
anyone to deny you these rights or to ask you to surrender the rights.
These restrictions translate to certain responsibilities for you if you
distribute copies of the software, or if you modify it.

  For example, if you distribute copies of such a program, whether
gratis or for a fee, you must give the recipients all the rights that
you have.  You must make sure that they, too, receive or can get the
source code.  And you must show them these terms so they know their
rights.

  We protect your rights with two steps: (1) copyright the software, and
(2) offer you this license which gives you legal permission to copy,
distribute and/or modify the software.

  Also, for each author's protection and ours, we want to make certain
that everyone understands that there is no warranty for this free
software.  If the software is modified by someone else and passed on, we
want its recipients to know that what they have is not the original, so
that any problems introduced by others will not reflect on the original
authors' reputations.

  Finally, any free program is threatened constantly by software
patents.  We wish to avoid the danger that redistributors of a free
program will individually obtain patent licenses, in effect making the
program proprietary.  To prevent this, we have made it clear that any
patent must be licensed for everyone's free use or not licensed at all.

  The precise terms and conditions for copying, distribution and
modification follow.

		    GNU GENERAL PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. This License applies to any program or other work which contains
a notice placed by the copyright holder saying it may be distributed
under the terms of this General Public License.  The \"Program\", below,
refers to any such program or work, and a \"work based on the Program\"
means either the Program or any derivative work under copyright law:
that is to say, a work containing the Program or a portion of it,
either verbatim or with modifications and/or translated into another
language.  (Hereinafter, translation is included without limitation in
the term \"modification\".)  Each licensee is addressed as \"you\".

Activities other than copying, distribution and modification are not
covered by this License; they are outside its scope.  The act of
running the Program is not restricted, and the output from the Program
is covered only if its contents constitute a work based on the
Program (independent of having been made by running the Program).
Whether that is true depends on what the Program does.

  1. You may copy and distribute verbatim copies of the Program's
source code as you receive it, in any medium, provided that you
conspicuously and appropriately publish on each copy an appropriate
copyright notice and disclaimer of warranty; keep intact all the
notices that refer to this License and to the absence of any warranty;
and give any other recipients of the Program a copy of this License
along with the Program.

You may charge a fee for the physical act of transferring a copy, and
you may at your option offer warranty protection in exchange for a fee.

  2. You may modify your copy or copies of the Program or any portion
of it, thus forming a work based on the Program, and copy and
distribute such modifications or work under the terms of Section 1
above, provided that you also meet all of these conditions:

    a) You must cause the modified files to carry prominent notices
    stating that you changed the files and the date of any change.

    b) You must cause any work that you distribute or publish, that in
    whole or in part contains or is derived from the Program or any
    part thereof, to be licensed as a whole at no charge to all third
    parties under the terms of this License.

    c) If the modified program normally reads commands interactively
    when run, you must cause it, when started running for such
    interactive use in the most ordinary way, to print or display an
    announcement including an appropriate copyright notice and a
    notice that there is no warranty (or else, saying that you provide
    a warranty) and that users may redistribute the program under
    these conditions, and telling the user how to view a copy of this
    License.  (Exception: if the Program itself is interactive but
    does not normally print such an announcement, your work based on
    the Program is not required to print an announcement.)

These requirements apply to the modified work as a whole.  If
identifiable sections of that work are not derived from the Program,
and can be reasonably considered independent and separate works in
themselves, then this License, and its terms, do not apply to those
sections when you distribute them as separate works.  But when you
distribute the same sections as part of a whole which is a work based
on the Program, the distribution of the whole must be on the terms of
this License, whose permissions for other licensees extend to the
entire whole, and thus to each and every part regardless of who wrote it.

Thus, it is not the intent of this section to claim rights or contest
your rights to work written entirely by you; rather, the intent is to
exercise the right to control the distribution of derivative or
collective works based on the Program.

In addition, mere aggregation of another work not based on the Program
with the Program (or with a work based on the Program) on a volume of
a storage or distribution medium does not bring the other work under
the scope of this License.

  3. You may copy and distribute the Program (or a work based on it,
under Section 2) in object code or executable form under the terms of
Sections 1 and 2 above provided that you also do one of the following:

    a) Accompany it with the complete corresponding machine-readable
    source code, which must be distributed under the terms of Sections
    1 and 2 above on a medium customarily used for software interchange; or,

    b) Accompany it with a written offer, valid for at least three
    years, to give any third party, for a charge no more than your
    cost of physically performing source distribution, a complete
    machine-readable copy of the corresponding source code, to be
    distributed under the terms of Sections 1 and 2 above on a medium
    customarily used for software interchange; or,

    c) Accompany it with the information you received as to the offer
    to distribute corresponding source code.  (This alternative is
    allowed only for noncommercial distribution and only if you
    received the program in object code or executable form with such
    an offer, in accord with Subsection b above.)

The source code for a work means the preferred form of the work for
making modifications to it.  For an executable work, complete source
code means all the source code for all modules it contains, plus any
associated interface definition files, plus the scripts used to
control compilation and installation of the executable.  However, as a
special exception, the source code distributed need not include
anything that is normally distributed (in either source or binary
form) with the major components (compiler, kernel, and so on) of the
operating system on which the executable runs, unless that component
itself accompanies the executable.

If distribution of executable or object code is made by offering
access to copy from a designated place, then offering equivalent
access to copy the source code from the same place counts as
distribution of the source code, even though third parties are not
compelled to copy the source along with the object code.

  4. You may not copy, modify, sublicense, or distribute the Program
except as expressly provided under this License.  Any attempt
otherwise to copy, modify, sublicense or distribute the Program is
void, and will automatically terminate your rights under this License.
However, parties who have received copies, or rights, from you under
this License will not have their licenses terminated so long as such
parties remain in full compliance.

  5. You are not required to accept this License, since you have not
signed it.  However, nothing else grants you permission to modify or
distribute the Program or its derivative works.  These actions are
prohibited by law if you do not accept this License.  Therefore, by
modifying or distributing the Program (or any work based on the
Program), you indicate your acceptance of this License to do so, and
all its terms and conditions for copying, distributing or modifying
the Program or works based on it.

  6. Each time you redistribute the Program (or any work based on the
Program), the recipient automatically receives a license from the
original licensor to copy, distribute or modify the Program subject to
these terms and conditions.  You may not impose any further
restrictions on the recipients' exercise of the rights granted herein.
You are not responsible for enforcing compliance by third parties to
this License.

  7. If, as a consequence of a court judgment or allegation of patent
infringement or for any other reason (not limited to patent issues),
conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot
distribute so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you
may not distribute the Program at all.  For example, if a patent
license would not permit royalty-free redistribution of the Program by
all those who receive copies directly or indirectly through you, then
the only way you could satisfy both it and this License would be to
refrain entirely from distribution of the Program.

If any portion of this section is held invalid or unenforceable under
any particular circumstance, the balance of the section is intended to
apply and the section as a whole is intended to apply in other
circumstances.

It is not the purpose of this section to induce you to infringe any
patents or other property right claims or to contest validity of any
such claims; this section has the sole purpose of protecting the
integrity of the free software distribution system, which is
implemented by public license practices.  Many people have made
generous contributions to the wide range of software distributed
through that system in reliance on consistent application of that
system; it is up to the author/donor to decide if he or she is willing
to distribute software through any other system and a licensee cannot
impose that choice.

This section is intended to make thoroughly clear what is believed to
be a consequence of the rest of this License.

  8. If the distribution and/or use of the Program is restricted in
certain countries either by patents or by copyrighted interfaces, the
original copyright holder who places the Program under this License
may add an explicit geographical distribution limitation excluding
those countries, so that distribution is permitted only in or among
countries not thus excluded.  In such case, this License incorporates
the limitation as if written in the body of this License.

  9. The Free Software Foundation may publish revised and/or new versions
of the General Public License from time to time.  Such new versions will
be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

Each version is given a distinguishing version number.  If the Program
specifies a version number of this License which applies to it and \"any
later version\", you have the option of following the terms and conditions
either of that version or of any later version published by the Free
Software Foundation.  If the Program does not specify a version number of
this License, you may choose any version ever published by the Free Software
Foundation.

  10. If you wish to incorporate parts of the Program into other free
programs whose distribution conditions are different, write to the author
to ask for permission.  For software which is copyrighted by the Free
Software Foundation, write to the Free Software Foundation; we sometimes
make exceptions for this.  Our decision will be guided by the two goals
of preserving the free status of all derivatives of our free software and
of promoting the sharing and reuse of software generally.

			    NO WARRANTY

  11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE PROGRAM \"AS IS\" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
REPAIR OR CORRECTION.

  12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.

		     END OF TERMS AND CONDITIONS
"))
;;; FILE: LICENCE
#|
		    GNU GENERAL PUBLIC LICENSE
		       Version 2, June 1991

 Copyright (C) 1989, 1991 Free Software Foundation, Inc.
                       59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 Everyone is permitted to copy and distribute verbatim copies
 of this license document, but changing it is not allowed.

			    Preamble

  The licenses for most software are designed to take away your
freedom to share and change it.  By contrast, the GNU General Public
License is intended to guarantee your freedom to share and change free
software--to make sure the software is free for all its users.  This
General Public License applies to most of the Free Software
Foundation's software and to any other program whose authors commit to
using it.  (Some other Free Software Foundation software is covered by
the GNU Library General Public License instead.)  You can apply it to
your programs, too.

  When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
this service if you wish), that you receive source code or can get it
if you want it, that you can change the software or use pieces of it
in new free programs; and that you know you can do these things.

  To protect your rights, we need to make restrictions that forbid
anyone to deny you these rights or to ask you to surrender the rights.
These restrictions translate to certain responsibilities for you if you
distribute copies of the software, or if you modify it.

  For example, if you distribute copies of such a program, whether
gratis or for a fee, you must give the recipients all the rights that
you have.  You must make sure that they, too, receive or can get the
source code.  And you must show them these terms so they know their
rights.

  We protect your rights with two steps: (1) copyright the software, and
(2) offer you this license which gives you legal permission to copy,
distribute and/or modify the software.

  Also, for each author's protection and ours, we want to make certain
that everyone understands that there is no warranty for this free
software.  If the software is modified by someone else and passed on, we
want its recipients to know that what they have is not the original, so
that any problems introduced by others will not reflect on the original
authors' reputations.

  Finally, any free program is threatened constantly by software
patents.  We wish to avoid the danger that redistributors of a free
program will individually obtain patent licenses, in effect making the
program proprietary.  To prevent this, we have made it clear that any
patent must be licensed for everyone's free use or not licensed at all.

  The precise terms and conditions for copying, distribution and
modification follow.

		    GNU GENERAL PUBLIC LICENSE
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

  0. This License applies to any program or other work which contains
a notice placed by the copyright holder saying it may be distributed
under the terms of this General Public License.  The "Program", below,
refers to any such program or work, and a "work based on the Program"
means either the Program or any derivative work under copyright law:
that is to say, a work containing the Program or a portion of it,
either verbatim or with modifications and/or translated into another
language.  (Hereinafter, translation is included without limitation in
the term "modification".)  Each licensee is addressed as "you".

Activities other than copying, distribution and modification are not
covered by this License; they are outside its scope.  The act of
running the Program is not restricted, and the output from the Program
is covered only if its contents constitute a work based on the
Program (independent of having been made by running the Program).
Whether that is true depends on what the Program does.

  1. You may copy and distribute verbatim copies of the Program's
source code as you receive it, in any medium, provided that you
conspicuously and appropriately publish on each copy an appropriate
copyright notice and disclaimer of warranty; keep intact all the
notices that refer to this License and to the absence of any warranty;
and give any other recipients of the Program a copy of this License
along with the Program.

You may charge a fee for the physical act of transferring a copy, and
you may at your option offer warranty protection in exchange for a fee.

  2. You may modify your copy or copies of the Program or any portion
of it, thus forming a work based on the Program, and copy and
distribute such modifications or work under the terms of Section 1
above, provided that you also meet all of these conditions:

    a) You must cause the modified files to carry prominent notices
    stating that you changed the files and the date of any change.

    b) You must cause any work that you distribute or publish, that in
    whole or in part contains or is derived from the Program or any
    part thereof, to be licensed as a whole at no charge to all third
    parties under the terms of this License.

    c) If the modified program normally reads commands interactively
    when run, you must cause it, when started running for such
    interactive use in the most ordinary way, to print or display an
    announcement including an appropriate copyright notice and a
    notice that there is no warranty (or else, saying that you provide
    a warranty) and that users may redistribute the program under
    these conditions, and telling the user how to view a copy of this
    License.  (Exception: if the Program itself is interactive but
    does not normally print such an announcement, your work based on
    the Program is not required to print an announcement.)

These requirements apply to the modified work as a whole.  If
identifiable sections of that work are not derived from the Program,
and can be reasonably considered independent and separate works in
themselves, then this License, and its terms, do not apply to those
sections when you distribute them as separate works.  But when you
distribute the same sections as part of a whole which is a work based
on the Program, the distribution of the whole must be on the terms of
this License, whose permissions for other licensees extend to the
entire whole, and thus to each and every part regardless of who wrote it.

Thus, it is not the intent of this section to claim rights or contest
your rights to work written entirely by you; rather, the intent is to
exercise the right to control the distribution of derivative or
collective works based on the Program.

In addition, mere aggregation of another work not based on the Program
with the Program (or with a work based on the Program) on a volume of
a storage or distribution medium does not bring the other work under
the scope of this License.

  3. You may copy and distribute the Program (or a work based on it,
under Section 2) in object code or executable form under the terms of
Sections 1 and 2 above provided that you also do one of the following:

    a) Accompany it with the complete corresponding machine-readable
    source code, which must be distributed under the terms of Sections
    1 and 2 above on a medium customarily used for software interchange; or,

    b) Accompany it with a written offer, valid for at least three
    years, to give any third party, for a charge no more than your
    cost of physically performing source distribution, a complete
    machine-readable copy of the corresponding source code, to be
    distributed under the terms of Sections 1 and 2 above on a medium
    customarily used for software interchange; or,

    c) Accompany it with the information you received as to the offer
    to distribute corresponding source code.  (This alternative is
    allowed only for noncommercial distribution and only if you
    received the program in object code or executable form with such
    an offer, in accord with Subsection b above.)

The source code for a work means the preferred form of the work for
making modifications to it.  For an executable work, complete source
code means all the source code for all modules it contains, plus any
associated interface definition files, plus the scripts used to
control compilation and installation of the executable.  However, as a
special exception, the source code distributed need not include
anything that is normally distributed (in either source or binary
form) with the major components (compiler, kernel, and so on) of the
operating system on which the executable runs, unless that component
itself accompanies the executable.

If distribution of executable or object code is made by offering
access to copy from a designated place, then offering equivalent
access to copy the source code from the same place counts as
distribution of the source code, even though third parties are not
compelled to copy the source along with the object code.

  4. You may not copy, modify, sublicense, or distribute the Program
except as expressly provided under this License.  Any attempt
otherwise to copy, modify, sublicense or distribute the Program is
void, and will automatically terminate your rights under this License.
However, parties who have received copies, or rights, from you under
this License will not have their licenses terminated so long as such
parties remain in full compliance.

  5. You are not required to accept this License, since you have not
signed it.  However, nothing else grants you permission to modify or
distribute the Program or its derivative works.  These actions are
prohibited by law if you do not accept this License.  Therefore, by
modifying or distributing the Program (or any work based on the
Program), you indicate your acceptance of this License to do so, and
all its terms and conditions for copying, distributing or modifying
the Program or works based on it.

  6. Each time you redistribute the Program (or any work based on the
Program), the recipient automatically receives a license from the
original licensor to copy, distribute or modify the Program subject to
these terms and conditions.  You may not impose any further
restrictions on the recipients' exercise of the rights granted herein.
You are not responsible for enforcing compliance by third parties to
this License.

  7. If, as a consequence of a court judgment or allegation of patent
infringement or for any other reason (not limited to patent issues),
conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot
distribute so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you
may not distribute the Program at all.  For example, if a patent
license would not permit royalty-free redistribution of the Program by
all those who receive copies directly or indirectly through you, then
the only way you could satisfy both it and this License would be to
refrain entirely from distribution of the Program.

If any portion of this section is held invalid or unenforceable under
any particular circumstance, the balance of the section is intended to
apply and the section as a whole is intended to apply in other
circumstances.

It is not the purpose of this section to induce you to infringe any
patents or other property right claims or to contest validity of any
such claims; this section has the sole purpose of protecting the
integrity of the free software distribution system, which is
implemented by public license practices.  Many people have made
generous contributions to the wide range of software distributed
through that system in reliance on consistent application of that
system; it is up to the author/donor to decide if he or she is willing
to distribute software through any other system and a licensee cannot
impose that choice.

This section is intended to make thoroughly clear what is believed to
be a consequence of the rest of this License.

  8. If the distribution and/or use of the Program is restricted in
certain countries either by patents or by copyrighted interfaces, the
original copyright holder who places the Program under this License
may add an explicit geographical distribution limitation excluding
those countries, so that distribution is permitted only in or among
countries not thus excluded.  In such case, this License incorporates
the limitation as if written in the body of this License.

  9. The Free Software Foundation may publish revised and/or new versions
of the General Public License from time to time.  Such new versions will
be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

Each version is given a distinguishing version number.  If the Program
specifies a version number of this License which applies to it and "any
later version", you have the option of following the terms and conditions
either of that version or of any later version published by the Free
Software Foundation.  If the Program does not specify a version number of
this License, you may choose any version ever published by the Free Software
Foundation.

  10. If you wish to incorporate parts of the Program into other free
programs whose distribution conditions are different, write to the author
to ask for permission.  For software which is copyrighted by the Free
Software Foundation, write to the Free Software Foundation; we sometimes
make exceptions for this.  Our decision will be guided by the two goals
of preserving the free status of all derivatives of our free software and
of promoting the sharing and reuse of software generally.

			    NO WARRANTY

  11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
REPAIR OR CORRECTION.

  12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES.

		     END OF TERMS AND CONDITIONS

|#
;;; FILE: initkb.lisp

;;; File: initkb.lisp
;;; Author: Peter Clark
;;; Purpose: Initialize the KB (directive). This file is loaded last.

(reset-kb)

(defun version () 
  (format t "      ====================================================~%")
  (format t "      KM - THE KNOWLEDGE MACHINE - INFERENCE ENGINE v~a~%" *km-version*)
  (format t "      ====================================================~%")
  (format t "Copyright (C) ~a Peter Clark and Bruce Porter. KM comes with ABSOLUTELY~%" *year*)
  (format t "NO WARRANTY. This is free software, and you are welcome to redistribute it~%")
  (format t "under certain conditions. Type (licence) for details.~%~%")
  t)

(version)
(format t "Documentation at http://www.cs.utexas.edu/users/mfkb/km.html~%")
(format t "Type (km) for the KM interpreter prompt!~%")

#|
======================================================================
		APPENDIX
======================================================================


FUNCTIONS:
	(own-expr-sets instance slot [situation])
	(inherited-expr-sets instance slot [situation])

--------------------

(own-expr-sets instance slot [situation])
 - If situation's aren't used, returns a list ((expr1 ... exprN)) where 
   exprI are the KM expressions directly on instance's slot.
 - If situations are used, it collects the expressions on instance's slot
   for situation s + each of situation's supersituations s',s'', etc.. Returns a list
	((expr11 ... expr1N) (expr21 ... expr2N) ...)
   where (expr11 ... expr1N) are expressions on instance's slot in s, 
	 (expr21 ... expr2N) are expressions on instance's slot in s', 
	 etc.
   NOTE: This function doesn't tell you which situation each expression set came
   from.

(inherited-expr-sets instance slot [situation])
 - For each class of instance [and for each supersituation of situation], get
   the set of expressions on instance's slot. Return a list of these expression sets.
   NOTE: This function doesn't tell you which class+situation each expression 
   set came from.

EXAMPLE:	
GIVEN:	(every Vehicle has (parts ((a Engine))))
	(Car has (superclasses (Vehicle)))
	(every Car has (parts ((a Engine) (a Chassis))))
	(*MyCar has 
	  (instance-of (Car))
	  (parts ((a Bumper-Sticker) (a Furry-Dice))))

	(*Situation1 has (instance-of (Situation)))
	(in-situation *Situation1 (*MyCar has (parts ((a Radio)))))

THEN:	CL-USER> (own-expr-sets '#$*MyCar '#$parts)
	(((a Bumper-Sticker) (a Furry-Dice)))		; from *MyCar

	CL-USER> (inherited-expr-sets '#$*MyCar '#$parts)
	(((a Engine) (a Chassis)) 			; from Car
	 ((a Engine)))					; from Vehicle

	CL-USER> (own-expr-sets '#$*MyCar '#$parts '#$*Situation1)
	(((a Radio))	     				; from *MyCar (in *Situation1)
         ((a Bumper-Sticker) (a Furry-Dice)))		; from *MyCar (in global situation)

To combine and evaluate these expressions, simply do a KM call for (the parts of *MyCar).
|#

(defun own-expr-sets (instance slot &optional (situation (curr-situation)))
  (bind-self (collect-instance-expr-sets instance slot situation) instance))

(defun inherited-expr-sets (instance slot &optional (situation (curr-situation)))
  (bind-self (collect-rule-sets instance slot situation) instance))