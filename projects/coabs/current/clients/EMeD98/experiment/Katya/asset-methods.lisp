(in-package "EXPECT")
 
(setf *domain-plans*
 '(
((name find-opcon-time-for-an-asset)
(capability (estimate (obj (?t is (spec-of opcon-time))) 
		      (for (?a is (inst-of asset)))))
(result-type (inst-of number)) 
(method (if (is-it-a (obj ?a)
		     (of (spec-of corps-level-asset)))
	    then 4
	    else 2))
)

((name find-opcon-time-for-all-assets)
(capability (estimate (obj (?t is (spec-of opcon-time))) 
		      (for (?a is (inst-of move-asset)))))
(result-type (inst-of number)) 
(method (find      
	 (obj (spec-of maximum))
	 (of (estimate (obj (spec-of opcon-time))
		       (for (asset-of ?a))))))
)

((name find-moving-distance-of-an-asset)
 (primitivep t)
 (capability (estimate
	      (obj (?d is (spec-of moving-distance)))
	      (from (?l1 is (inst-of location)))
	      (to (?l2 is (inst-of location)))))
 (result-type (inst-of number))
 (method (find-distance (?l1 ?l2)))
)

((name find-moving-time-of-all-assets)
(capability (estimate (obj (?t is (spec-of moving-time))) 
		      (for (?a is (inst-of move-asset)))))
(result-type (inst-of number)) 
(method (find      
	 (obj (spec-of maximum))
	 (of (estimate
	      (obj (spec-of moving-time))
	      (for (asset-of ?a))
	      (to (destination ?a))))))
)

((name estimate-time-to-move-assets)
(capability (estimate (obj (?t  is (spec-of time))) 
		      (for (?a is (inst-of move-asset)))))
(result-type (inst-of number))
(method (add (obj (estimate (obj (spec-of moving-time)) 
			    (for ?a)))
	     (to (estimate (obj (spec-of opcon-time)) 
			   (for ?a)))))
)

((name find-moving-time-of-an-asset)
 (capability (estimate
	      (obj (?t is (spec-of moving-time)))
	      (for (?a is (inst-of asset)))
	      (to (?l2 is (inst-of location)))))
 (result-type (inst-of number))
 (method (divide (obj (estimate
	      (obj (spec-of moving-distance))
	      (from (object-found-in-location ?a))
	      (to ?l2)))
		 (by 60000)))
)
))