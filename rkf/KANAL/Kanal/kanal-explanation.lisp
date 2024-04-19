(in-package "KANAL")


(defun p-english (object)
  (cond ((null object)
         "unknown")
        ((listp object)
         (mapcar #'rkf::frame2english object))
	(t
         (rkf::frame2english object)))
  )

(defun round-real (x)
  (if (numberp x)
      (/ (round (* 100.0 x)) 100.0)
    x))

     
(defun get-force-ratio-condition-description (task)
  (let ((result nil)
	(agent-rcps nil)
	(enemy-rcps nil)
	(agents (km-k `(#$the #$agent #$of ,task)))
	(enemies (km-k `(#$the #$enemy #$of ,task)))
	(available-force-ratio (km-unique-k `(#$the1 #$of (#$the #$value #$of
						       (#$the #$available-force-ratio
							      #$of ,task)))))
	(required-force-ratio (km-unique-k `(#$the1 #$of (#$the #$value #$of
						       (#$the #$required-force-ratio
							      #$of ,task)))))
	(agent-supporting-unit-exists nil)
	(enemy-supporting-unit-exists nil)
	)
    (dolist (agent agents)
      (let ((supporting-units (km-k `(#$the #$supported-by-military-unit #$of ,agent)))

	    (allegiance (km-unique-k `(#$the #$value #$of (#$the #$allegiance #$of ,agent))))
	    (remaining-strength (km-unique-k `(#$the1 #$of (#$the #$value #$of
						       (#$the #$remaining-strength
							      #$of ,agent)))))
	    (equipment (km-k `(#$the #$Military-Equipment #$possesses #$of ,agent)))
	    (default-combat-power (km-unique-k `(#$the1 #$of (#$the #$value #$of
							 (#$the #$default-combat-power
								#$of ,agent)))))
	    (unit-type (km-k `(#$the #$instance-of #$of ,agent)))
	    (relative-combat-power (km-unique-k `(#$the1 #$of (#$the #$value #$of
							 (#$the #$relative-combat-power
								#$of ,agent))))))
	
	(setq result
		 (append result
			 (list (format nil "For agent ~A [ ~A ], (allegiance is ~A), its equipment is ~A so the default combat power is ~A"
				       (p-english agent) (p-english unit-type)
				       (p-english allegiance)
				       (p-english equipment)
				       (round-real default-combat-power))
			       (if remaining-strength
				   (format nil "~% Since its remaining strength is ~A the relative combat power is (~A * ~A) = ~A"
					   (round-real remaining-strength)
					   (round-real default-combat-power) (round-real remaining-strength) (round-real relative-combat-power))
				 (format nil "~% Since its remaining strength is by default 1, the relative combat power is ~A" (round-real relative-combat-power))))))
	(setq agent-rcps (append agent-rcps (list relative-combat-power)))
	(when supporting-units
	  (setq agent-supporting-unit-exists t)
	  (dolist (unit supporting-units)
	    (let ((u-rcp (km-unique-k `(#$the1 #$of (#$the #$value #$of
							 (#$the #$relative-combat-power
								#$of ,unit)))))
		  (u-equipment (km-k `(#$the #$Military-Equipment #$possesses #$of ,unit)))
		  (u-default-combat-power (km-unique-k `(#$the1 #$of (#$the #$value #$of
							 (#$the #$default-combat-power
								#$of ,unit)))))
		  (u-remaining-strength (km-unique-k `(#$the1 #$of (#$the #$value #$of
						       (#$the #$remaining-strength
							      #$of ,unit)))))
		  )

	      (if u-remaining-strength
		  (setq result
		    (append result (list (format nil "~%  Supporting unit ~A with equipment ~A has relative combat power ~A (~A * ~A)"
						 (p-english unit) (p-english u-equipment)
						 (round-real u-rcp)
						 (round-real u-remaining-strength) (round-real u-default-combat-power) 
						 ))))
		(setq result
		    (append result (list (format nil "~%  Supporting unit ~A with equipment ~A has relative combat power ~A"
						 (p-english unit) (p-english u-equipment)
						 (round-real u-rcp)
						
						 )))))
	      (setq agent-rcps (append agent-rcps (list u-rcp))))))
						 
	)
      )

    ;; i do enemies separately since there are still some problems in the translation output (e.g. no allegiance given for some units)
    (dolist (agent enemies)
      (let ((supporting-units (km-k `(#$the #$supported-by-military-unit #$of ,agent)))
            (allegiance (km-unique-k `(#$the #$value #$of (#$the #$allegiance #$of ,agent))))
	    (remaining-strength (km-unique-k `(#$the1 #$of (#$the #$value #$of
						       (#$the #$remaining-strength
							      #$of ,agent)))))
	    (equipment (km-k `(#$the #$Military-Equipment #$possesses #$of ,agent)))
	    (default-combat-power (km-unique-k `(#$the1 #$of (#$the #$value #$of
							 (#$the #$default-combat-power
								#$of ,agent)))))
	    (unit-type (km-k `(#$the #$instance-of #$of ,agent)))
	    (relative-combat-power (km-unique-k `(#$the1 #$of (#$the #$value #$of
							 (#$the #$relative-combat-power
								#$of ,agent))))))
	
	(setq result
		 (append result
			 (list (format nil "For enemy ~A [ ~A ] , (allegiance is ~A), its equipment is ~A so the default combat power is ~A"
				       (p-english agent) (p-english unit-type)
				       (p-english allegiance)
				       (p-english equipment)
				       (round-real default-combat-power))
			       (if remaining-strength
				   (format nil "~% Since its remaining strength is ~A the relative combat power is (~A * ~A) = ~A"
					   (round-real remaining-strength)
					   (round-real default-combat-power) (round-real remaining-strength) (round-real relative-combat-power))
				 (format nil "~% Since its remaining strength is by default 1, the relative combat power is ~A" (round-real relative-combat-power))))))
	
	(setq enemy-rcps (append enemy-rcps (list relative-combat-power)))

        (when supporting-units
	  (setq enemy-supporting-unit-exists t)
	  (dolist (unit supporting-units)
	    (let ((u-rcp (km-unique-k `(#$the1 #$of (#$the #$value #$of
							 (#$the #$relative-combat-power
								#$of ,unit)))))
		  (u-equipment (km-k `(#$the #$Military-Equipment #$possesses #$of ,unit)))
		  (u-default-combat-power (km-unique-k `(#$the1 #$of (#$the #$value #$of
							 (#$the #$default-combat-power
								#$of ,unit)))))
		  (u-remaining-strength (km-unique-k `(#$the1 #$of (#$the #$value #$of
						       (#$the #$remaining-strength
							      #$of ,unit)))))
		  )

	      (if u-remaining-strength
		  (setq result
		    (append result (list (format nil "~%  Enemy Supporting unit ~A with equipment ~A has relative combat power ~A (~A * ~A)"
						 (p-english unit) (p-english u-equipment)
						 (round-real u-rcp)
						 (round-real u-remaining-strength) (round-real u-default-combat-power) 
						 ))))
		(setq result
		    (append result (list (format nil "~%  Enemy Supporting unit ~A with equipment ~A has relative combat power ~A"
						 (p-english unit) (p-english u-equipment)
						 (round-real u-rcp)
						
						 )))))
	      (setq enemy-rcps (append enemy-rcps (list u-rcp)))))))
      )
    
    (cond ((and agent-supporting-unit-exists enemy-supporting-unit-exists)
           (setq result (append result (list (format nil "So the available force ratio of ~A is ~%(sum of agent relative-combat-power + sum of supporting combat power)/(sum of enemy relative-combat-power + sum of enemy supporting combat power) = ~% sum of ~A/ sum of ~A = ~A ~% The required force ratio of the task is ~A" (p-english task) (round-real agent-rcps) (round-real enemy-rcps) (round-real available-force-ratio) (round-real required-force-ratio))))))
          (agent-supporting-unit-exists
           (setq result (append result (list (format nil "So the available force ratio of ~A is ~%(sum of agent relative-combat-power + sum of supporting combat power)/(sum of enemy relative-combat-power) = ~% sum of ~A/ sum of ~A = ~A ~% The required force ratio of the task is ~A" (p-english task) (round-real agent-rcps) (round-real enemy-rcps) (round-real available-force-ratio) (round-real required-force-ratio))))))
          (enemy-supporting-unit-exists
           (setq result (append result (list (format nil "So the available force ratio of ~A is ~%(sum of agent relative-combat-power)/(sum of enemy relative-combat-power + sum of enemy supporting combat power) = ~% sum of ~A/ sum of ~A = ~A ~% The required force ratio of the task is ~A" (p-english task) (round-real agent-rcps) (round-real enemy-rcps) (round-real available-force-ratio) (round-real required-force-ratio))))))
          (t
           (setq result (append result (list (format nil "So the available force ratio of ~A is ~%(sum of agent relative-combat-power)/(sum of enemy relative-combat-power) = ~% sum of ~A/ sum of ~A = ~A ~% The required force ratio of the task is ~A" (p-english task) (round-real agent-rcps) (round-real enemy-rcps) (round-real available-force-ratio) (round-real required-force-ratio))))))
     )
     result
))


(defun get-combat-power-description (unit)
  (let ((result nil)
	(allegiance (km-unique-k `(#$the #$value #$of (#$the #$allegiance #$of ,unit))))
	(remaining-strength (km-unique-k `(#$the1 #$of (#$the #$value #$of
						       (#$the #$remaining-strength
							      #$of ,unit)))))
	(equipment (km-k `(#$the #$Military-Equipment #$possesses #$of ,unit)))
	(default-combat-power (km-unique-k `(#$the1 #$of (#$the #$value #$of
							 (#$the #$default-combat-power
								#$of ,unit)))))
	(unit-type (km-k `(#$the #$instance-of #$of ,unit)))
	(relative-combat-power (km-unique-k `(#$the1 #$of (#$the #$value #$of
							 (#$the #$relative-combat-power
								#$of ,unit))))))
	
	(setq result
		 (append result
			 (list (format nil "For unit ~A [ ~A ], (allegiance is ~A), its equipment is ~A so the default combat power is ~A"
				       (p-english unit) (p-english unit-type)
				       (p-english allegiance)
				       (p-english equipment)
				       (round-real default-combat-power))
			       (if remaining-strength
				   (format nil "Since its remaining strength is ~A the relative combat power is (~A * ~A) = ~A"
					   (round-real remaining-strength)
					   (round-real default-combat-power) (round-real remaining-strength) (round-real relative-combat-power))
				 (format nil "Since its remaining strength is by default 1, the relative combat power is ~A" (round-real relative-combat-power))))))
	result
  ))


(defun get-full-enemy-combat-power-description (event)
   (let ((enemies (km-k `(#$the #$enemy #$of ,event)))
         (result nil))

         (dolist (unit enemies)
          (let ((supporting-units (km-k `(#$the #$supported-by-military-unit #$of ,unit))))
	    (setq result (append result
	               (get-combat-power-description unit)))
            (when supporting-units
	      (dolist (unit supporting-units)
	        (if (not (member unit enemies))
	        (let ((u-rcp (km-unique-k `(#$the1 #$of (#$the #$value #$of
							 (#$the #$relative-combat-power
								#$of ,unit)))))
		      (u-equipment (km-k `(#$the #$Military-Equipment #$possesses #$of ,unit)))
		      (u-default-combat-power (km-unique-k `(#$the1 #$of (#$the #$value #$of
							     (#$the #$default-combat-power
								#$of ,unit)))))
		      (u-remaining-strength (km-unique-k `(#$the1 #$of (#$the #$value #$of
						           (#$the #$remaining-strength
							          #$of ,unit)))))
		      )

	          (if u-remaining-strength
		      (setq result
		        (append result (list (format nil "Enemy Supporting unit ~A with equipment ~A has relative combat power ~A (~A * ~A)"
						     (p-english unit) (p-english u-equipment)
						     (round-real u-rcp)
						     (round-real u-remaining-strength) (round-real u-default-combat-power) 
						     ))))
		      (setq result
		        (append result (list (format nil "Enemy Supporting unit ~A with equipment ~A has relative combat power ~A"
						    (p-english unit) (p-english u-equipment)
						    (round-real u-rcp)
						    )))))
	     ))))
        ))
	result
  ))


(defun get-force-ratio-description (event)
  (let* ((timeline (get-event-timeline event))
         (max-combat-power (get-max-combat-power event))
         (enemies (km `(#$the #$enemy #$of ,event)))
         (enemy-combat-power (get-full-enemy-combat-power event))
         (available-force-ratio (car (km `(#$the1 #$of ($#the $#value $of (#$the #$available-force-ratio #$of ,event))))))
         (result nil)
	 (instresult nil))
        
	(dolist (instant timeline)
	    (let ((combat-power 0)
	          (timeprefix "")
		  (tresult nil))

	          (if (> (length timeline) 1)
		      (setq timeprefix (format nil "At time ~A : " (car instant))))

		  (mapcar #'(lambda (unit) 
		             (setq combat-power 
			           (+ combat-power (get-unit-combat-power unit)))) 
		  (cadr instant))

	         (setq tresult (append tresult
	                 (list (format nil "~AUnits involved are ~A"
			           timeprefix  (mapcar #'p-english (cadr instant))))))

	         (dolist (unit (cadr instant))
	              (setq tresult (append tresult
			                (get-combat-power-description unit))))

	         (setq tresult (append tresult
	                 (list (format nil "Therefore, ~Atotal relative-combat-power is : ~A"
			           timeprefix  (round-real combat-power) ))))

	         (setq instresult (append instresult (list (list (car instant) tresult))))
		 (setq result (append result tresult))
            )
	 )

         (if (> (length timeline) 1)
	     (setq result (append result
	         (list (format nil "Maximum relative-combat-power during the event is : ~A"
		         (round-real max-combat-power) )))))

	 (setq result (append result
	         (list (format nil "Enemies : ~A"
		         (mapcar #'p-english enemies) ))))

	 (setq result (append result
	         (get-full-enemy-combat-power-description event)))

	 (setq result (append result
	         (list (format nil "So the available-force-ratio is : ~A / ~A = ~A"
		         (round-real max-combat-power) (round-real enemy-combat-power) (round-real (/ max-combat-power enemy-combat-power))))))

	 (list result instresult)
   ))


