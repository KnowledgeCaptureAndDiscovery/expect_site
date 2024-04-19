(in-package "KANAL")


(defun p-english (object)
  (if (null object)
      "unknown"
    (rkf::frame2english object)))

     
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
	(supporting-unit-exists nil)
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
				       default-combat-power)
			       (if remaining-strength
				   (format nil "~% Since its remaining strength is ~A the relative combat power is (~A * ~A) = ~A"
					   remaining-strength
					   default-combat-power remaining-strength relative-combat-power)
				 (format nil "~% Since its remaining strength is by default 1, the relative combat power is ~A" relative-combat-power)))))
	(setq agent-rcps (append agent-rcps (list relative-combat-power)))
	(when supporting-units
	  (setq supporting-unit-exists t)
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
						 u-rcp
						 u-remaining-strength u-default-combat-power 
						 ))))
		(setq result
		    (append result (list (format nil "~%  Supporting unit ~A with equipment ~A has relative combat power ~A"
						 (p-english unit) (p-english u-equipment)
						 u-rcp
						
						 )))))
	      (setq agent-rcps (append agent-rcps (list u-rcp))))))

						 
	)
      )

    ;; i do enemies separately since there are still some problems in the translation output (e.g. no allegiance given for some units)
    (dolist (agent enemies)
      (let ((allegiance (km-unique-k `(#$the #$value #$of (#$the #$allegiance #$of ,agent))))
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
				       default-combat-power)
			       (if remaining-strength
				   (format nil "~% Since its remaining strength is ~A the relative combat power is (~A * ~A) = ~A"
					   remaining-strength
					   default-combat-power remaining-strength relative-combat-power)
				 (format nil "~% Since its remaining strength is by default 1, the relative combat power is ~A" relative-combat-power)))))
	
	(setq enemy-rcps (append enemy-rcps (list relative-combat-power))))
      )
    
    (if supporting-unit-exists
     (setq result (append result (list (format nil "So the available force ratio of ~A is ~%(sum of agent relative-combat-power + sum of supporting combat power)/(sum of enemy relative-combat-power) = ~% sum of ~A/ sum of ~A = ~A ~% The required force ratio of the task is ~A" (p-english task) agent-rcps enemy-rcps available-force-ratio required-force-ratio))))
     (setq result (append result (list (format nil "So the available force ratio of ~A is ~%(sum of agent relative-combat-power)/(sum of enemy relative-combat-power) = ~% sum of ~A/ sum of ~A = ~A ~% The required force ratio of the task is ~A" (p-english task) agent-rcps enemy-rcps available-force-ratio required-force-ratio))))
     )
     result
	    
))
    
