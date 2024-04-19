(in-package "EXPECT")
;;; *******************************************************
;;; collect goals in special forms 
;;; *******************************************************

(defun find-subgoals-and-compute-edt-special (expr cap name expected-result)
  (let ((cat (parser-find-syntactic-category expr)))
    (case cat
      (if (find-subgoals-if-expr expr cap name expected-result))
      (when (find-subgoals-when-expr expr cap name expected-result))
      ((append append-elts) (find-subgoals-append-expr expr cap name expected-result))
      (union (find-subgoals-union-expr expr cap name expected-result))
      (catch (find-subgoals-catch-expr expr cap name expected-result))
      (and (find-subgoals-and-expr expr cap name expected-result))
      (or (find-subgoals-or-expr expr cap name expected-result))
      (not (find-subgoals-not-expr expr cap name expected-result))
      (block (find-subgoals-block-expr expr cap name expected-result))
      (filter (find-subgoals-filter-expr expr cap name expected-result))
      (otherwise expr)
      )))

;; return then-expr result	
(defun find-subgoals-if-expr (expr cap name expected-result)  
  (let ((cond-expr (second expr))
        (then-expr (fourth expr))
        (else-expr (sixth expr)))	    
    (find-subgoals-and-compute-edt cond-expr cap name '(inst-of boolean))
    (find-subgoals-and-compute-edt else-expr cap name expected-result)
    (find-subgoals-and-compute-edt then-expr cap name expected-result)))

(defun find-subgoals-when-expr (expr cap name expected-result)  
  (let ((cond-expr (second expr))
        (then-expr (third expr)))
    (find-subgoals-and-compute-edt cond-expr cap name '(inst-of boolean))
    (find-subgoals-and-compute-edt then-expr cap name expected-result)))

;; return set-of common-edt
(defun find-subgoals-append-expr (expr cap name expected-result)
  (let* ((element-type
	  (cond ((not (set-p expected-result))
		 'undefined)
		((intensional-p expected-result)
		 (second expected-result))
		(t ;; extensional set
		 (mkb-find-common-edt-list expected-result))))
         (args (rest expr))
         (common-edt (mkb-find-common-edt-list
		  (mapcar #'(lambda (arg)
			      (find-subgoals-and-compute-edt 
			       arg cap name element-type))
			args))))
    (if common-edt
        (append '(set-of) (list (list common-edt)))
      'undefined)))

(defun find-subgoals-union-expr (expr cap name expected-result)
  (find-subgoals-append-expr expr cap name expected-result))

(defun find-subgoals-catch-expr (expr cap name expected-result)
  (let ((result (find-subgoals-and-compute-edt (second expr) cap name expected-result)))
    (if (eq result 'fail) ;; until it is known as fail, use the catch expr
      (find-subgoals-and-compute-edt
       (second (assoc 'fail (cddr expr))) cap name expected-result)
      result)))

(defun find-subgoals-and-expr (expr cap name expected-result)
  (let ((param-list (cdr expr)) (simplified-params nil))
      (dolist (param param-list)
	(setq simplified-params
	      (append simplified-params
		    (list (find-subgoals-and-compute-edt
			   param cap name '(inst-of boolean)))))))
  '(inst-of boolean))

(defun find-subgoals-or-expr (expr cap name expected-result)
  (let ((param-list (cdr expr)) (simplified-params nil))
      (dolist (param param-list)
	(setq simplified-params
	      (append simplified-params
		    (list (find-subgoals-and-compute-edt
			   param cap name '(inst-of boolean)))))))
  '(inst-of boolean))

(defun find-subgoals-not-expr (expr cap name expected-result)
  (find-subgoals-and-compute-edt (second expr) cap name '(inst-of boolean))
  '(inst-of boolean))

(defun find-subgoals-block-expr (expr cap name expected-result)
  (find-subgoals-and-compute-edt (first (last expr)) cap name expected-result))


;; (filter (obj expr) (with expr))
;;              ^^^^
;; compute result type only
(defun find-subgoals-filter-expr (expr cap name expected-result)
  (let ((with-result
         (find-subgoals-and-compute-edt (second (third expr)) cap name expected-result))
        (obj-result
         (find-subgoals-and-compute-edt (second (second expr)) cap name expected-result)))
    (if (not (set-p obj-result))
        (make-edt-set obj-result)
      obj-result)
    )
  )





