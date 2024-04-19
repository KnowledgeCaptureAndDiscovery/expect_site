;;; -*- Mode: Lisp; Package: RKF; Syntax: Ansi-Common-Lisp; Base: 10 -*-

(in-package :rkf)

;;; * Implement KANAL::KANAL-GET-ERRORS-XML to generate the XML for
;;;   the diagnosis that KANAL produces.
;;; * Implement KANAL::KANAL-GET-ERROR-FIX-XML to generate the XML to
;;;   display the fix for a particular error.

;;; The details of why this needs to be done are explained below.



;;; This file contains stub functions to demonstrate how KANAL will be
;;; invoked from the server. There are two pairs of functions here:

;;; * TEST-KNOWLEDGE-KANAL-GET-ERRORS-PRE and
;;;   TEST-KNOWLEDGE-KANAL-GET-ERRORS-POST

;;; * TEST-KNOWLEDGE-KANAL-GET-FIX-PRE and
;;;   TEST-KNOWLEDGE-KANAL-GET-FIX-POST

;;; Each pair constitutes a step. The first pair should be used by
;;; KANAL to produce XML containing the diagnostics for the given
;;; process. The second pair should produce the XML that describes the
;;; fix for a particular error. These functions work as follows: the
;;; PRE function is called when the user submits a process that must
;;; be tested. The PRE function receives this request, and generates
;;; the required XML, which is then returned to the client. The user
;;; then responds to this page, and then the POST function is called
;;; with the new arguments. The POST function checks the validity of
;;; the request, and calls the next step.

;;; The PRE and POST functions will be supplied by us. You will have
;;; to fill in the function KANAL::KANAL-GET-ERRORS-XML so that it
;;; prints out an XML document with the diagnostics. The function 
;;; KANAL::KANAL-GET-ERROR-FIX-XML should be implemented to produce
;;; the XML for a particular fix. Please let us know what you want
;;; here, this is just my first guess.



;;; To access these pages, use the following URL's, filling in the
;;; server address and the session identifier (which is your Shaken
;;; user name):

;;; http://<your-shaken-server>/imxml?next=test-knowledge-kanal-get-errors&sessionid=<your-sessionid>&individual=_Foo234
;;; http://<your-shaken-server>/imxml?next=test-knowledge-kanal-get-fix&sessionid=<your-sessionid>&individual=_Foo234&fixid=123

;;; You will have to view source in your browser to see anything.

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (find-package :kanal)
    (defpackage :kanal
      (:use :common-lisp))))

(defun ensure-kanal-output-file-location (sessionid type)
  (multiple-value-bind (sec min hour day month year) 
      (get-decoded-time)
    (declare (ignore sec min hour))
    (let ((dir (ensure-directory (make-user-directory-pathname sessionid "logs" nil))))
      (make-pathname :name (format nil "kanal-~A-~4,'0D~2,'0D~2,'0D" type year month day)
		     :type type
		     :defaults dir))))

(defun kanal-log-file (session-id)
  (ensure-kanal-output-file-location session-id "log"))

(defun kanal-html-file (session-id)
  (ensure-kanal-output-file-location session-id "html"))

(defun log-pre (stream sessionid errorid concept type reason logflag)
  (if logflag
      (with-open-file (kanal::*kanal-log-stream* (kanal-log-file sessionid)
		       :direction :output :if-does-not-exist :create :if-exists :append)
	(kanal::kanal-format nil "~%+++++++++++++++++++++++++++++++++~% user note on error: (session-id:~a) (concept:~a)    (type:~a)~% ~a ~% REASON:~a~%+++++++++++++++++++++++++++++++++~%~%"
			     sessionid concept type errorid reason)))
  (princ "<b>Do Not Close This Window !</b>" stream))

(defun activity-log-pre (stream sessionid concept logmessage)
   (let* ((a (multiple-value-list (get-decoded-time)))
          (timeval (format nil "~S:~S:~S (~S/~S/~S)" (third a) 
                (second a) (first a) (fifth a) (fourth a) (sixth a))))
           (with-open-file (kanal::*kanal-log-stream* (kanal-log-file sessionid)
		       :direction :output :if-does-not-exist :create :if-exists :append)
     	     (kanal::kanal-format nil 
	        "~%~%++++++++++ User Activity (concept ~a) ~a +++++++++++~% ~a~%" 
                    concept timeval logmessage))
  (princ "<b>Do Not Close This Window !</b>" stream)))

(defun test-knowledge-kanal-get-errors-pre (sessionid class root-individual message)
  ;; Generate some XML here
  ;; SESSIONID is the user's session identifier
  ;; CLASS is the process class that is to be diagnosed.
  ;; ROOT-INDIVIDUAL is the process instance that is to be diagnosed. It is an instance of CLASS.
  ;; MESSAGE is an error message string.
  (declare (ignore class))
  (let* ((stream alp::*output-stream*)
	 (log-file (kanal-log-file sessionid))
	 (html-log-file (kanal-html-file sessionid))
	 (alist `(("log-file" . ,(pathname-name log-file))
		  ("html-file" . ,(pathname-name html-log-file))
		  ,@(when message
		      `(("message" . ,message)))
		  ,@alp::*query-alist*))
	 (root-individual (okbc:coerce-to-individual root-individual :kb *base-kb*))
	 (topic-situation (cl-user::topic-situation-for root-individual))
	 (cl-user::*logging* nil))
    (shaken::with-cached-collected-paths ()
      (with-stylesheet-url-base (nil)
	(with-transformable-xml (stream "kanal-internal.xsl" alist)
	  (with-open-file (kanal::*kanal-log-stream* log-file
			   :direction :output :if-exists :append :if-does-not-exist :create)
	    (with-open-file (kanal::*kanal-html-file-stream* html-log-file
			     :direction :output :if-exists :supersede :if-does-not-exist :create)
	      (kanal::kanal-result-to-xml
					;kanal::*current-results*
	       (kanal:test-knowledge (list root-individual topic-situation)
				     :input-type 'kanal::instance)
	       stream))))))))

(defun test-knowledge-kanal-get-errors-post (stream sessionid class root-individual static)
  (cond (static
	 (execute-next-step test-knowledge-kanal-get-report stream sessionid 
			    (okbc:coerce-to-class class :kb *base-kb*)
			    (okbc:coerce-to-individual root-individual :kb *base-kb*)
			    nil))
	(t (error "Unhandled branch in test-knowledge-kanal-get-errors-post."))))

(defun create-kanal-report-archive (sessionid root-individual topic-situation alist)
  (let* ((stylesheet "kanal-internal-static.xsl")
	 (name "kanal-report")
	 (archive-dir (make-user-directory-pathname sessionid "qa" name))
	 (kanal-report-file (make-pathname :name name :type "xml" :defaults archive-dir)))
    (with-tgz-archive (archive-dir :if-exists :supersede :if-does-not-exist :create
				   :clean-up t :publish nil :archive-file-binding archive-file)
      (with-open-file (stream kanal-report-file :direction :output
		       :if-exists :error :if-does-not-exist :create)
	(shaken::with-cached-collected-paths ()
	  (with-stylesheet-url-base (t)
	    (with-transformable-xml (stream stylesheet alist)
	      (kanal::kanal-result-to-xml
	       (kanal:test-knowledge (list root-individual topic-situation)
				     :input-type 'kanal::instance :cached-results t)
	       stream)))))
      (copy-xml-support-files kanal-report-file stylesheet)
      archive-file)))

(defun test-knowledge-kanal-get-report-pre (stream sessionid class root-individual message)
  (declare (ignore class))
  (let* ((alist `(,@(when message
		      `(("message" . ,message)))
		  ,@*im-input-alist*))
         (root-individual (okbc:coerce-to-individual root-individual :kb *base-kb*))
	 (topic-situation (cl-user::topic-situation-for root-individual))
	 (cl-user::*logging* nil)
	 (archive-file (create-kanal-report-archive sessionid root-individual topic-situation alist)))
    (file->stream archive-file stream :element-type '(unsigned-byte 8))
    (delete-file archive-file)))

(defun kanal::kanal-get-error-fix-xml (stream sessionid fixid individual)
  (kanal::kanal-fixes-to-xml (kanal::find-symbol-in-kb fixid) stream)
  )

(defun test-knowledge-kanal-get-fix-pre (stream sessionid fixid individual message)
  ;; Similar in structure to TEST-KNOWLEDGE-KANAL-GET-ERRORS-PRE.
  ;; The XML header
  (princ "<?xml version=\"1.0\"?>" stream)
  (princ "<?xml-stylesheet type=\"text/xsl\" href=\"/xslt/kanalfix.xsl\"?>"
	 stream)
  ;; The stylesheet
  ;; Will be included in some future working version
  ;; (format stream "~&<?xml-stylesheet type=\"text/xsl\" href=\"~A\"?>"
  ;;         (xslt-stylesheet-url 'kanal-get-fix))
  ;; The XML document
  (format stream "~&<request-response sessionid=\"~A\" concept=\"~A\">" sessionid individual)
  ;; And there will be other stuff in here
  (kanal::kanal-get-error-fix-xml stream sessionid fixid individual)
  (format stream "~&</request-response>"))

(defun test-knowledge-kanal-get-fix-post (stream sessionid fixid)
  (declare (ignore stream sessionid fixid))
  ;; Again, probably not required for testing knowledge
  )

;; Interface for selecting expected effects for a COA 
;; (shorter form of select-expected-effect)

(defun select-coa-expected-effect-pre (stream sessionid class root-individual effect op message)
  (princ "<?xml version=\"1.0\"?>" stream)
  (princ "<?xml-stylesheet type=\"text/xsl\" href=\"/xslt/kanaleffects.xsl\"?>" stream)
  (format stream "~&<request-response sessionid=\"~A\" concept=\"~A\" root-individual=\"~A\">~%" sessionid class root-individual)
  (setq root-individual (okbc:coerce-to-individual root-individual :kb *base-kb*))
  (kanal::kanal-change-effect effect op)
  (kanal::kanal-effects-to-xml root-individual stream)
  (format stream "~&</request-response>")
  )

(defun select-coa-expected-effect-post (stream sessionid)
  (declare (ignore stream sessionid))
  )

;;; EOF
