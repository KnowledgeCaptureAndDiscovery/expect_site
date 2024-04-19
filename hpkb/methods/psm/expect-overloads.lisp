;;;
;;; This file contains definitions that overwrite Expect functions. 
;;; They'll migrate into the release version eventually.
;;; 

(in-package "EXPECT")

;;; The default cutoff of 500 nodes isn't enough for the force ratio
;;; check for three critical events.
(setf *search-cutoff* 999999999)

(defvar *modify-psm-library-methods-p* nil
  "If non-nil, user sees PSM library methods in the menus to modify a method")

;;; Modified to filter out the library methods if 
;;; *modify-psm-library-methods-p* is nil (the default).
;;; Originally defined in clim-do-menu-items.lisp

(defun make-capanl&name-list ()
  (if *show-primitive-plans-in-menu*
      (append 
       (mapcar #'(lambda (p-nm)
	         (list (get-plan-capability-nl p-nm)
		     :value (get-plan-name p-nm)))
	     (if *modify-psm-library-methods-p*
	         (find-all-non-primitive-domain-plans)
	       (remove-if #'(lambda (plan)
			  (member (plan-name plan)
				*psm-library-method-names*))
		        (find-all-non-primitive-domain-plans))))
       (list (list "Primitive methods: " :value nil))
       (mapcar #'(lambda (p-nm)
	         (list (get-plan-capability-nl p-nm)
		     :value (get-plan-name p-nm)))
	     (if *modify-psm-library-methods-p*
	         (find-all-primitive-domain-plans)
	       (remove-if #'(lambda (plan)
			  (member (plan-name plan)
				*psm-library-method-names*))
		        (find-all-primitive-domain-plans)))))
    (mapcar #'(lambda (p-nm)
	      (list (get-plan-capability-nl (ka-find-plan p-nm))
		  :value p-nm))
	  (if *modify-psm-library-methods-p*
	      (ka-find-all-plan-names)
	    (remove-if #'(lambda (name)
		         (member name *psm-library-method-names*))
		     (ka-find-all-plan-names))))))

