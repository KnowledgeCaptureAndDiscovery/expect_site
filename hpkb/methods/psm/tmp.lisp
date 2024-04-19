;;; Methods for the plan evaluation PSM.
;;; Last modified: May 3rd 99

;;; History:
;;; May 3rd 99: Changed post-processing to create analysis
;;;             items filling an evaluation-structure.
;;;             This aligns the PSM with the
;;;             critique ontology in evaluations.loom.


(setf tmp-plans
  '(

    ((name evaluate-plan)
     (capability (evaluate (obj (?p is (inst-of plan)))))
     (result-type (set-of (inst-of boolean))) ; need a more general type
     (pre-processing (set-up-evaluation-aspects ?p))
     (method (evaluate (obj (set-up-evaluation-aspects (obj ?p)))
		   (with-respect-to (evaluation-aspect ?p))
		   )))

    ;; This method calls a primitive function to install all the
    ;; evaluation-structure and analysis instances we need.
    ((name set-up-evaluation-aspects)
     (capability (set-up-evaluation-aspects (obj (?p is (inst-of plan)))))
     (result-type (inst-of plan))
     (primitivep t)
     (method (set-up-evaluation-aspects ?p)))

    ;; Evaluate a plan with respect to an evaluation structure
    ;; by looking at each sub-evaluation-structure and factor in turn.
    ((name evaluate-general-aspect)
     (capability (evaluate (obj (?p is (inst-of plan)))
		       (with-respect-to (?a is (inst-of evaluation-structure)))))
     (result-type (set-of (inst-of boolean)))
     (pre-processing (set-current-evaluation-structure ?a))
     ;; because of the pre-processing step, the order of the two subgoals matters.
     (method (combine (obj (evaluate (obj ?p) 
			        (with-respect-to (factor ?a))))
		  (with (evaluate (obj ?p) 
			       (with-respect-to 
			        (sub-evaluation-structure ?a)))))))

    ;; Evaluate a plan with respect to the aspect of resource-usage by
    ;; finding every resource possibly used in the plan. Each evaluation
    ;; gives true if there's a problem, false otherwise.
    ((name evaluate-all-resource-usage-in-a-plan)
     (capability (evaluate (obj (?p is (inst-of plan)))
		       (with-respect-to (inst resource-usage))))
     (result-type (set-of (inst-of boolean)))
     #|
     (method (if (determine-whether-there-are-any (obj (used-resource ?p)))
	       then (evaluate (obj ?p) (wrt (used-resource ?p)))
	       else (false)))
     |#
     (method (if (determine-whether-there-are-any
	        (obj (find-the-instances (of resource-check))))
	       then (evaluate (obj ?p)
			  (with-respect-to
			   (find-the-instances (of resource-check))))
	       else (false))))

    ;; Evaluate a plan wrt a resource by determining how much
    ;; information is available about the resource and the plan-tasks,
    ;; and performing the most detailed check possible.
    ((name evaluate-a-resource-in-a-plan)
     (capability (evaluate (obj (?p is (inst-of plan)))
		       (with-respect-to (?r is (inst-of resource-check)))))
     (result-type (inst-of boolean))
     (method
      (evaluate (obj ?p) (with-respect-to amount-used) (of ?r))
#|
Don't want to fall back on existence checks for the demo.
      (catch (evaluate (obj ?p) (with-respect-to amount-used) (of ?r))
        (fail (evaluate (obj ?p) (with-respect-to existence) (of ?r))))
|#
      #|(if (is-equal
	        (obj (estimate (obj ?r)
			   (available-to
			    (plan-tasks-to-be-inspected ?p))))
	        (to nil))
	       then (if (is-equal (obj (estimate (obj ?r) (available-to ?p)))
			      (to nil))
		      then (evaluate (obj ?p) (wrt existence) (of ?r))
		      else (evaluate (obj ?p) (wrt local-bound) (on ?r)))
	       else (evaluate (obj ?p) (wrt global-bound) (on ?r)))|#
      ))

    ((name evaluate-a-global-resource-globally)
     (capability (evaluate (obj (?p is (inst-of plan)))
		       (with-respect-to (?f is (spec-of amount-used)))
		       (of (?r is (inst-of global-resource)))))
     (result-type (inst-of boolean))
     (method
      (evaluate (obj ?p) (with-respect-to amount-used-by-whole-plan) (of ?r)))
     )

    ((name evaluate-a-local-resource-locally)
     (capability (evaluate (obj (?p is (inst-of plan)))
		       (with-respect-to (?f is (spec-of amount-used)))
		       (of (?r is (inst-of local-resource)))))
     (result-type (inst-of boolean))
     ;; This needs to use a different instance of the same local-resource
     ;; for each task/critical event.
     (method
      (evaluate (obj ?p) (with-respect-to amount-used-by-each-task) (of ?r)))
     )

    ;; Evaluate a plan wrt a consumable capacitated resource by
    ;; computing the resource usage and checking if it exceeds the
    ;; available amount.
    ((name evaluate-consumable-capacitated-resource)
     (capability (evaluate
	        (obj (?p is (inst-of plan)))
	        (with-respect-to (?f is (spec-of amount-used-by-whole-plan)))
	        (of (?r is (inst-of resource-check)))))
     (result-type (inst-of boolean))
     ;; assume it's an upper bound for now (easy to generalise).
     (method (is-greater-or-equal
	    (obj (estimate (obj amount-used) (of (checked-resource ?r)) (needed-by ?p)))
	    (than (estimate (obj amount-available) (of (checked-resource ?r)) (available-to ?p)))))
     (post-processing ;;(store-if ?method-result ?r ?p 'violated-constraint)
                      (add-to-evaluation ?method-result ?r ?p ?f)
		  ))

    ;; Evaluate a plan wrt a reusable capacitated resource by evaluating
    ;; each plan-task individually wrt the available amount.
    ((name evaluate-reusable-capacitated-resource)
     (capability (evaluate
	        (obj (?p is (inst-of plan)))
	        (with-respect-to (?f is (spec-of amount-used-by-each-task)))
	        (of (?r is (inst-of resource-check)))))
     (result-type (inst-of boolean))
     (method (determine-whether
	    (obj true) (is-a set-member)
	    (of (evaluate (obj ;;(plan-tasks-to-be-inspected ?p)
		         ;;(|Fix1|)	; for now
		         (critical-event-of ?p)
		         )
		        (with-respect-to amount-used) (of ?r)))))
     (post-processing ;;(store-if ?method-result ?r 'violated-constraint ?p)
                      (add-to-evaluation ?method-result ?r ?p ?f)
		  ))

    ;; Default method to combine amount of a resource used in a plan -
    ;; assume it's linear and sum the amount consumed by each plan-task.
    ((name estimate-linear-resource)
     (capability (estimate
	        (obj (?f is (spec-of amount-used)))
	        (of (?r is (inst-of linear-resource)))
	        (needed-by (?p is (inst-of plan)))))
     ;; Need to use result-refiner here to get value types.
     (result-type (inst-of number))
     (method (add (obj (estimate
		    (obj amount-used)
		    (of (checked-resource ?r))
		    (needed-by (plan-tasks-to-be-inspected ?p))))))
     ;;(post-processing (store-result ?method-result 'amount-needed ?p ?r))
     )

     ;; Evaluate a reusable capacitated resource on a plan-task. True
     ;; if there's a problem.
     ((name evaluate-reusable-capacitated-resource-on-plan-task)
      (capability (evaluate
	         (obj (?o is (inst-of |MilitaryEvent| ;;plan-task
				 )))
	         (with-respect-to (?f is (spec-of amount-used)))
	         (of (?r is (inst-of resource-check)))))
      (result-type (inst-of boolean))
      (method (is-greater-or-equal
	     (obj (estimate (obj amount-used)
			(of ?r)
			(needed-by-set (find (plan-tasks-sharing ?r)
					 (with ?o)))))
	     (than (estimate (obj ?r) (available-to ?o)))))
      (post-processing ;;(store-if ?method-result ?r 'violated-constraint ?o)))
       (add-to-task-evaluation ?method-result ?r ?o ?f)))

     ((name blurgh)
      (capability (estimate (obj (?o is (spec-of amount-used)))
		        (of (?r is (inst-of resource-check)))
		        (needed-by-set (?s is (set-of (inst-of |MilitaryEvent|
						        ;;plan-task
						        ))))))
      (result-type (inst-of number))
      ;; we have a mismatch here in "amount-used" and "amount". Also the
      ;; version in critiques.plans requires an inst-of MilitaryEvent
      ;; rather than a set, hence the maximum stuff.
      (method (find (obj (spec-of expect::maximum))
		(of (estimate (obj amount) (of (checked-resource ?r)) 
			    (needed-by ?s)))))
      (post-processing (store-usage-estimate-for-task-set ?method-result ?s ?r)))

     ((name blurgh2)
      (capability (estimate (obj (?r is (inst-of resource-check)))
		        (available-to (?o is (inst-of |MilitaryEvent|
					         ;;plan-task
					         )))))
      (result-type (inst-of number))
      (method (estimate (obj (checked-resource ?r)) (available-to ?o)))
      (post-processing (store-availability-estimate-for-task ?method-result ?o ?r)))

     ;; just broke this method out from the one above to be able to
     ;; store the intermediate result.
     ((name sum-set-of-plan-task-useages)
      (capability (estimate (obj (?f is (spec-of amount-used)))
		        (of (?r is (inst-of capacitated-resource)))
		        (needed-by-set
		         (?s is (set-of (inst-of |MilitaryEvent|
					    ;;plan-task
					    ))))
		        (considering (?o is (inst-of |MilitaryEvent| ;;plan-task
					        )))))
      (result-type (inst-of number))
      (method (add (obj (estimate (obj amount-used) (of (checked-resource ?r)) 
			    (needed-by ?s)))))
      ;;(post-processing (store-result ?method-result ?o ?r 'set-useage))
      )

     ;; Default method to find the plan-tasks sharing a capacititated
     ;; resource: assume it's completely reusable - each plan-task
     ;; shares with no others
     ((name default-find-plan-tasks-sharing-resource)
      (capability (find (plan-tasks-sharing (?r is (inst-of resource-check)))
		    (with (?o is (inst-of |MilitaryEvent| ;;plan-task
				       )))))
      (result-type (set-of (inst-of |MilitaryEvent| ;;plan-task
			       )))
      (primitivep t)
      (method (list ?o))
      (post-processing
       ;;(store-result ?method-result ?o ?r 'sharing-plan-tasks)
       ))

     ;; Another common default case - all plan-tasks from the same place
     ;; at the same time share the resource, otherwise it's reusable
     ((name default-find-plan-tasks-sharing-temporal-spatial-resource)
      (capability (find (plan-tasks-sharing (?r is (inst-of ts-resource)))
		    (with (?o is (inst-of plan-task)))))
      (result-type (set-of (inst-of plan-task)))
      (method (filter (obj (plan-tasks-to-be-inspected (in-plan ?o)))
		  (with (check-if (obj ?o)
			        (shares ?r)
			        (with 
			         (plan-tasks-to-be-inspected
				(in-plan ?o)))))))
      (post-processing
       ;;(store-result ?method-result ?o ?r 'sharing-plan-tasks)
       ))

     ((name check-plan-tasks-share-temporal-spatial-resource)
      (capability (check-if (obj (?o1 is (inst-of plan-task)))
		        (shares (?r is (inst-of ts-resource)))
		        (with (?o2 is (inst-of plan-task)))))
      (result-type (inst-of boolean))
      (method (and (is-equal (obj (resource-found-at ?o1))
		         (to (resource-found-at ?o2)))
	         (is-equal (obj (occurs ?o1)) (to (occurs ?o2))))))
     
     ;; Default method to estimate the amount of a resource available to
     ;; an plan-task - get the amount available to the plan. This
     ;; assumes the resource is globally allocated and completely
     ;; reusable.
     ((name default-estimate-capacitated-resource-available-to-plan-task)
      (capability (estimate
	         (obj (?r is (inst-of globally-allocated-resource)))
	         (available-to (?o is (inst-of plan-task)))))
      (result-type (inst-of number))
      (method (estimate (obj ?r) (available-to (in-plan ?o))))
      (post-processing ;;(store-result ?method-result ?o ?r 'available)
       ))
       
     ;; Discrete resources
     ((name evaluate-reusable-discrete-resource)
      (capability (evaluate
	         (obj (?p is (inst-of plan)))
	         (with-respect-to (?f is (spec-of existence)))
	         (of (?r is (inst-of resource-check)))))
      (result-type (inst-of boolean))
      (method (if (check-if (obj ?r) (available-to ?p))
	        then false
	        else 
	        (determine-whether-there-are-any
	         (obj (filter (obj (plan-tasks-to-be-inspected ?p))
			  (with (check-if (obj ?r)
				        (needed-by
				         (plan-tasks-to-be-inspected ?p)))))))))
      (post-processing ;;(store-result ?method-result ?p ?r 'violated)
       ))

     ;; Default method to evaluate a reusable discrete resource on an plan-task
     ;; This has now been replaced with the code above.
     ((name evaluate-reusable-discrete-resource-on-plan-task)
      (capability (evaluate
	         (obj (?o is (inst-of plan-task)))
	         (with-respect-to (?f is (spec-of existence)))
	         (of (?r is (inst-of resource-check)))))
      (result-type (inst-of boolean))
      ;; If it's needed, check it's available
      (method (if (check-if (obj ?r) (needed-by ?o))
	        then (check-if (obj ?r) (available-to (in-plan ?o)))
	        else true))
      (post-processing ;;(store-result ?method-result ?o ?r 'ok)
       ))

     ((name relation-check-reusable-discrete-resource-needed)
      (capability (check-if (obj
		         (?r is (inst-of directly-predictable-resource)))
		        (needed-by (?o is (inst-of plan-task)))))
      (result-type (inst-of boolean))
      (method (determine-whether (obj ?r) (is-a set-member)
			   (of (resource-needed ?o))))
      (post-processing ;;(store-result ?method-result ?o ?r 'needed)
       ))

     ((name relation-check-reusable-discrete-resource-available)
      (capability (check-if (obj
		         (?r is (inst-of directly-predictable-resource)))
		        (available-to (?p is (inst-of plan)))))
      (result-type (inst-of boolean))
      (method (determine-whether (obj ?r) (is-a set-member)
			   (of (resource-available ?p))))
      (post-processing ;;(store-result ?method-result ?p ?r 'available)
       ))

     ;; These default methods should use result refiners.

     ;; Default method for useage of capacitated resources. 
     ((name relation-estimate-capacitated-resource-for-plan-task)
      (capability (estimate (obj (?f is (spec-of amount-used)))
		        (of
		         (?r is (inst-of directly-predictable-resource)))
		        (needed-by (?o is (inst-of plan-task)))))
      (result-type (inst-of number))
      (method (amount-needed ?o ?r)))

     ((name check-no-amount-needed)
      (capability (check-no-amount-needed (obj (?o is (inst-of plan-task)))
				  (of (?r is (inst-of resource-check)))))
      (result-type (inst-of boolean))
      (primitivep t)
      (method (primitive-no-amount-needed ?o ?r)))

     ;; Default method for availability of capacitated resource.
     ((name relation-estimate-availability-of-capacitated-resource)
      (capability (estimate (obj (?f is (spec-of amount-available)))
		        (of
		         (?r is (inst-of directly-predictable-resource)))
		        (available-to (?p is (inst-of plan)))))
      (result-type (inst-of number))
      (method (supply ?r ?p)))

     ;; =========================================
     ;; Checking constraints other than resources
     ;; =========================================

     #|
((name check-constraints)
      (capability (evaluate (obj (?p is (inst-of plan)))
		        (with-respect-to (inst constraint-critiques))))
      (result-type (set-of (inst-of boolean)))
      (method (if (determine-whether-there-are-any
	         (obj (active-constraint ?p)))
	        then (evaluate (obj ?p) (with-respect-to (active-constraint ?p)))
	        else (false)))
      (post-processing (store-result ?method-result ?p 'constraint-critiques)))
|#

     ((name evaluate-global-constraint)
      (capability (evaluate (obj (?p is (inst-of plan)))
		        (with-respect-to (?c is (inst-of global-constraint)))))
      (result-type (inst-of boolean))
      (method (evaluate (obj ?p)
		    (with-respect-to ?c)))
      (post-processing (add-to-evaluation ?method-result ?c ?p)))

     ((name evaluate-global-completeness-critique)
      (capability (evaluate (obj (?p is (inst-of plan)))
		        (with-respect-to (?c is (inst-of global-completeness-critique)))))
      (result-type (inst-of boolean))
      (method (there-is-not-any (obj (find-fillers (of ?c) (in ?p)))))
      (post-processing (add-to-evaluation ?method-result ?c ?p)))

     #|
     ;; Evaluate a plan wrt a local constraint by checking each
     ;; plan-task in the plan.
     ((name evaluate-local-constraint)
      (capability (evaluate (obj (?p is (inst-of plan)))
		        (with-respect-to (?c is (inst-of local-constraint)))))
      (result-type (inst-of boolean))
      (method (determine-whether
	     (obj false) (is-a set-member)
	     (of (evaluate (obj (plan-tasks-to-be-inspected ?p))
		         (with-respect-to ?c)))))
      (post-processing
       ;;(store-result ?method-result ?p ?c 'constraint-violated)
       ))
|#

     ;; evaluate a bounds check on a military task by computing the
     ;; value, the bound and making the comparison. Will check an upper
     ;; bound, a lower bound or both depending on the class of the
     ;; bounds check.
     ((name evaluate-local-bounds-check)
      (capability (evaluate (obj (?task is (inst-of plan-task)))
		        (with-respect-to (?bc is (inst-of bounds-check)))))
      (result-type (inst-of boolean))
      (method
       (and (if (is-it-a (obj ?bc) (of upper-bound-check))
	      then
	    (evaluate (obj ?task) (with-respect-to upper-bound-check)
		    (on ?bc))
	    else true)
	  (if (is-it-a (obj ?bc) (of lower-bound-check))
	      then
	    (evaluate (obj ?task) (with-respect-to lower-bound-check)
		    (on ?bc))
	    else true))))

     ((name evaluate-local-upper-bound)
      (capability (evaluate (obj (?task is (inst-of plan-task)))
		        (with-respect-to 
		         (?ub is (spec-of upper-bound-check)))
		        (on (?bc is (inst-of bounds-check)))))
      (result-type (inst-of boolean))
      (method
       (is-less-or-equal
        (obj (estimate (obj amount-used) (of ?bc) (for ?task)))
        (than (estimate (obj upper-bound-value) (on ?bc) (for ?task))))))

     ((name evaluate-local-lower-bound)
      (capability (evaluate (obj (?task is (inst-of plan-task)))
		        (with-respect-to
		         (?lb is (spec-of lower-bound-check)))
		        (on (?bc is (inst-of bounds-check)))))
      (result-type (inst-of boolean))
      (method
       (is-greater-or-equal
        (obj (estimate (obj amount-used) (of ?bc) (for ?task)))
        (than (estimate (obj lower-bound-value) (on ?bc) (for ?task))))))

     ;; Default method to estimate the upper and lower bounds. The default method
     ;; queries the relation upper-bound or lower-bound on the bounds-check.
     ((name default-estimate-upper-bound)
      (capability (estimate (obj (?ub is (spec-of upper-bound-value)))
		        (on (?bc is (inst-of bounds-check)))
		        (for (?task is (inst-of plan-task)))))
      (result-type (inst-of number))
      (method (upper-bound ?bc)))
	  
     ((name default-estimate-lower-bound)
      (capability (estimate (obj (?lb is (spec-of lower-bound-value)))
		        (on (?bc is (inst-of bounds-check)))
		        (for (?task is (inst-of plan-task)))))
      (result-type (inst-of number))
      (method (lower-bound ?bc)))

     ;; Example of estimating the amount of a bounds check for a
     ;; task. Note that we only have to write this method for an
     ;; individual task, not the whole plan, because too-many-parents is
     ;; both an upper-bound-check and a local-constraint.
     ((name estimate-number-of-parents)
      (capability (estimate (obj (?f is (spec-of amount-used)))
		        (of (inst too-many-parents))
		        (for (?task is (inst-of plan-task)))))
      (result-type (inst-of number))
      (method (count-the-elements (obj (plan-task-parents ?task)))))
	  

     ;; Stub method to evaluate a constraint on an plan-task
     ;; by checking for a ternary relation
     ((name relation-evaluate-local-constraint-on-plan-task)
      (capability (evaluate
	         (obj (?o is (inst-of plan-task)))
	         (with-respect-to (?c is (inst-of directly-predictable-constraint)))))
      (result-type (inst-of boolean))
      (method (not (constraint-violated ?o ?c)))
      (post-processing ;;(store-result ?method-result ?o ?c 'constraint-ok)
       ))

     ;; This constraint is pretty universal so here it
     ;; is. too-many-parents is an instance of local-constraint, so the
     ;; method checks against an individual plan-task.
     ;; (It's now been redefined above as an instance of an upper-bound-check)
     #|((name check-not-too-many-parents)
      (capability (evaluate (obj (?o is (inst-of plan-task)))
		        (with-respect-to (inst too-many-parents))))
      (result-type (inst-of boolean))
      (method (is-less-or-equal
	     (obj (count-the-elements (obj (plan-task-parents ?o))))
	     (than (max-allowed-parents ?o))))
      (post-processing (store-result ?method-result ?o
			       'too-many-parents 'constraint-ok)))
|#

     ;; In many domains, plan-tasks can be grouped into strict
     ;; levels and any plan-task above the lowest level must have at
     ;; least one child.
     ((name check-children)
      (capability (evaluate (obj (?o is (inst-of plan-task)))
		        (with-respect-to (inst have-children))))
      (result-type (inst-of boolean))
      (method (if (is-it-a (obj ?o)
		       (of (spec-of plan-task-at-the-lowest-level)))
	        then true
	        else (determine-whether-there-are-any
		    (obj (plan-task-children ?o)))))
      ;;(post-processing (store-result ?method-result ?o
	;;		       'have-children 'constraint-ok))
      )

     ;; Similarly with parents
     ((name check-parents)
      (capability (evaluate (obj (?o is (inst-of plan-task)))
		        (with-respect-to (inst have-parents))))
      (result-type (inst-of boolean))
      (method (if (is-it-a (obj ?o)
		       (of (spec-of plan-task-at-the-highest-level)))
	        then true
	        else (determine-whether-there-are-any
		    (obj (plan-task-parents ?o)))))
      ;;(post-processing (store-result ?method-result ?o
	;;		       'have-parents 'constraint-ok))
      )

     
     ((name set-member)
      ;; used to use top-domain-concept, but can't if using planet.
      (capability (determine-whether
	         (obj (?el is (inst-of thing)))
	         (is-a (?p is (spec-of set-member)))
	         (of (?s is (set-of (inst-of thing))))))
      (result-type (inst-of boolean))
      (method (primitive-set-member ?el ?s))
      (primitivep t))

     ((name class-set-member)
      (capability (determine-whether
	         (obj (?el is (spec-of top-domain-concept)))
	         (is-a (?p is (spec-of set-member)))
	         (of (?s is (set-of (spec-of top-domain-concept))))))
      (result-type (inst-of boolean))
      (method (primitive-set-member ?el ?s))
      (primitivep t))

     ((name count-the-elements)
      (capability (count-the-elements
	         ;; can't use top-domain-concept
	         (obj (?s is (set-of (inst-of thing))))))
      (result-type (inst-of number))
      (primitivep t)
      (method (primitive-count-the-elements ?s)))

     ;; A more general version than the one in system-plans, which requires
     ;; its arguments to be numbers.
     ((name check-equality)
      (capability (is-equal (obj (?a is (inst-of top-domain-concept)))
		        (to (?b is (inst-of top-domain-concept)))))
      (result-type (inst-of boolean))
      (primitivep t)
      (method (primitive-equality-of-objects ?a ?b)))

     
     ;; From Andre's inspect2 domain
     ((name find-the-instances-of-a-concept)
      (capability (find-the-instances
	         (of (?c is (spec-of top-domain-concept)))))
      (result-type (set-of (inst-of top-domain-concept)))
      (result-refiner (result-refiner-set-of ?c))
      (primitivep t)
      (method (primitive-find-the-instances ?c)))

     ;; Since the system methods require things to be instances of
     ;; top-domain-concept, I need a more general versions when I use a
     ;; different theory (like planet).
     ((name is-it-an-instance-of-general)
      (capability (is-it-a
	         (obj (?i is (inst-of thing)))
	         (of  (?c is (spec-of thing)))
	         ))
      (result-type (inst-of boolean))
      (method (expect::primitive-is-it-an-instance-of ?i ?c))
      (primitivep t))

     ((name DETERMINE-WHETHER-THERE-ARE-ANY-general)
      (capability (determine-whether-there-are-any
	         (obj (?l is (set-of (inst-of thing))))
	         ))
      (result-type (inst-of boolean))
      (method (expect::primitive-determine-whether-there-are-any ?l))
      (primitivep t))

     ;; This is set union, but I don't want to use mathematical language.
     ((name COMBINE-GROUPS-OF-THINGS)
      (capability (combine (obj (?a is (set-of (inst-of thing))))
		       (with (?b is (set-of (inst-of thing))))))
      (result-type (set-of (inst-of thing)))
      (primitivep t)
      (method (append ?a ?b)))

     ;; Just a test.. that didn't work. The problem is that when the set
     ;; is nil, the matcher doesn't know what the elements of the set
     ;; should be, so we can't match (add (obj (set-of (inst-of number)))).
     ;; One solution is to add a specific method for nil, but I can't
     ;; figure out how to specify the capability. This will be a good example
     ;; for our improved expect language for empty sets and failed matches.
     #|
     ((name add-nothing)
      (capability (add (obj (?empty-set is nil))))
      (result-type (inst-of number))
      (result 0))
     |#

     ))

