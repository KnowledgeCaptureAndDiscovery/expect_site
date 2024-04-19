;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Jihie Kim, 1999
;; EMeD messages (error and warning)

(in-package "EXPECT")

(defstruct mkb-message
  plan-name
  code        ; see list of error codes in *message-table*
  type        ; error or warning
  parameters        ; parameters of the function that signals the error
  text-description  ; some text that can be displayed to the user
  suggestions  
  )

(defun get-text-description-in-mkb-message (mkb-message)
  (mkb-message-text-description mkb-message))

(defun get-message-type-in-mkb-message (mkb-message)
  (mkb-message-type mkb-message))

(defun mkb-error-p (message)
  (let ((type (get-message-type-in-mkb-message message)))
    (if (eq type 'error)
	t
      nil))
  )

(defun get-text-description-in-message (message)
  (cond ((error-condition-p message) 
	 (concatenate 'string "** LOCAL ERROR ** "
		      (get-text-description-in-error-condition message)))
	((eq 'cannot-parse-capability (mkb-message-code message))
	 (concatenate 'string "** PARSER ERROR ** "
		      (get-text-description-in-mkb-message message)))
	((mkb-error-p message)
	 (concatenate 'string "** FORM ERROR ** "
		      (get-text-description-in-mkb-message message)))
	(t (concatenate 'string " WARNING :"
			(get-text-description-in-mkb-message message)))))

(defun find-message-in-table (code)
  (assoc code *error-table*))

 
(defun get-message-code (desc)
  (first desc))

(defun mkb-get-text-description (desc obj plan-name)
  (let ((params (get-params-of-error-desc desc)))
    (cond ((null params)
	   (get-text-description desc))
	  ((eq 'plan-name (first params))
	   (format nil (get-text-description desc) plan-name))
	  ((= (length params) 1)
	   (format nil (get-text-description desc) obj))
	  (t (format nil (get-text-description desc)
		     obj plan-name))))
  )

(defun add-messages (messages)
  (dolist (msg messages)
    (cond ((error-condition-p msg)
	   (push msg *all-messages*))
	  ((eq 'new-expect-action (mkb-message-code msg))
	   (push msg *all-messages*))
	  (t nil))))


(defun signal-message (code plan-name obj)
  (when (mkb-verbose-p) 
    (if *problem-solver-verbose* (format *terminal-io* "~% MKB: Adding plan analyzer message for ~S, plan-name ~S and obj ~S"
	  code plan-name obj)))
  (let* ((desc (find-message-in-table code))
	 (text-description (mkb-get-text-description desc obj plan-name))
	 (type (get-type desc))
	 (new-message (make-mkb-message
		       :plan-name           plan-name
		       :code                code
		       :type                type
		       :text-description    text-description
		       :parameters          (get-params-of-error-desc desc)
		       :suggestions         (get-what-can-be-done desc)
		       )
		      )
	)

    (setq *mkb-messages* (append (list new-message) *mkb-messages*))
    new-message))


