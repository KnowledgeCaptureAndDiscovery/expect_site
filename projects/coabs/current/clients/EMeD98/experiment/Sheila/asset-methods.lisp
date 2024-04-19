(in-package "EXPECT")

(setf *domain-plans*
 '(
   
((name estimate-time-to-move-asset)
 (capability (estimate
                (obj (?t is (spec-of time)))
                (for (?p is (inst-of move-asset)))
                ))
 (result-type (inst-of number))
 (method (add
	  (obj (find
		(obj (spec-of maximum))
		(of 
		 (find
		  (obj (spec-of opcon-time))
		  (of (asset-of ?p))))))
	  (to (find
	       (obj (spec-of maximum))
	       (of 
		(find
		 (obj (spec-of moving-time))
		 (of (asset-of ?p))
		 (to (destination ?p)))
	       )
	      )
	  )
	 )
 )
)

((name find-opcon-time-of-asset)
 (capability (find
	      (obj (?t is (spec-of opcon-time)))
	      (of (?a is (inst-of asset)))
	      ))
 (result-type (inst-of number))
 (method (if (is-it-a
	      (obj ?a)
	      (of (spec-of corps-level-asset)))
	     then 4
	     else 2))
)


((name find-moving-time-of-asset)
 (capability (find
	      (obj (?t is (spec-of moving-time)))
	      (of (?a is (inst-of asset)))
	      (to (?l is (inst-of location))))
 )
 (result-type (inst-of number))
 (method (divide
	  (obj (find 
		(obj (spec-of moving-distance))
		(from (object-found-in-location ?a))
		(to ?l)
	       )
	   )
	 (by 60000)
	 )
 )
)

((name find-moving-distance-of-asset)
 (capability (find 
	      (obj (?d is (spec-of moving-distance)))
	      (from (?b is (inst-of location)))
	      (to (?e is (inst-of location)))
	     )
 )
 (result-type (inst-of number))
 (method (find-distance ?b ?e))
 (primitivep t)
)

))