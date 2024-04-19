(in-package "EXPECT")

(defun shared-mt-match-goal (goal)
  (when (mt-verbose-p)
    (format *terminal-io* "~%shared-mt-match-goal: goal: ~s~%" goal))

  (let* ((found (find-matches goal))
         (exact (car found))
         (first-exact (car exact)))	; pick the first of the plans matched
    (when (mt-very-verbose-p)
      (format *terminal-io* "~%shared-mt-match-goal: found ")
      (pprint found *terminal-io*))
    (if first-exact
        (let* ((achievable-structure (first first-exact))
	     (bindings (second first-exact)))
	(when (mt-verbose-p)
	  (format *terminal-io* "~%shared-mt-match-goal: exact ~s~%"
		first-exact)
	  (format *terminal-io* "~%shared-mt-match-goal: bindings ~s~%"
		bindings))
	(let* ((ps-plan (find-ps-plan (get-achievable-goal-name achievable-structure)))
	       (b-noduplicates (reverse-translate-bindings bindings))
	       (b-fixedduplicates (fix-duplicates-in-sets goal b-noduplicates ps-plan)))
	  (list ps-plan b-fixedduplicates)))
      nil)
    ))

#|
The original here just lists out the first element in the bindings list
if it changes anything. We want all the bindings, and we should
change any of them that need it.

(defun fix-duplicates-in-sets (goal b-noduplicates ps-plan)
  (let ((possible-set (eq 'SET-OF-INST (caadar b-noduplicates)))
        (dup-list (cadadr goal)))
    (if possible-set
        (list (list (first (first b-noduplicates)) 
		(list (first (second (first b-noduplicates))) 
		      (cadadr goal))))
      b-noduplicates))
)
|#

(defun fix-duplicates-in-sets (goal b-noduplicates ps-plan)
  (mapcar #'(lambda (binding param)
	    (let ((possible-set (eq 'set-of-inst 
			        (first (second binding)))))
	      (if possible-set
		(list (first binding)
		      (list (first (second binding))
			  (second param)))
	        binding)))
	;; assume the bindings are in the same order as the goal arguments
	b-noduplicates
	(cdr goal)))




