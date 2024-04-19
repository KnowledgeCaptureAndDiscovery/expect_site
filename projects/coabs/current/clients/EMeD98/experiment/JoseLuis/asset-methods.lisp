(in-package "EXPECT")
 
(setf *domain-plans*
 '(   
((name find-distance)
 (primitivep t)
 (capability (find
                (from (?from is (inst-of location)))
                (to (?to is (inst-of location)))
                ))
 (result-type (inst-of number))
 (method (find-distance ?from ?to))
)

((name estimate-time-to-move-asset)
 (capability (estimate
	      (obj (?t is (spec-of time)))
	      (for (?s is (inst-of move-asset)))
	      ))
 (result-type (inst-of number))
 (method 
  (add (obj (find (obj (spec-of maximum))
		  (of (estimate (obj (spec-of opcon-time))
				(for (asset-of ?s))))))
       (to (find (obj (spec-of maximum))
		 (of (estimate (obj (spec-of moving-time))
			       (for (asset-of ?s))
			       (to (destination ?s))))))
				    
       ))
 )

((name estimate-asset-opcon-time  )
 (capability (estimate (obj (?ot is (spec-of opcon-time))) 
		       (for (?a is (inst-of asset))))) 
 (result-type (inst-of number))
 (method   
  (if (is-it-a (obj ?a)
	       (of (spec-of corps-level-asset)))
      then 4
      else 2))
)

((name estimate-asset-moving-time  )
 (capability (estimate (obj (?mt is (spec-of moving-time)))
		       (for (?a is (inst-of asset))) 
		       (to (?to is (inst-of location))))) 
 (result-type (inst-of number))
 (method 
  (divide (obj (find (from (object-found-in-location ?a))
		     (to ?to)))
	  60000))
 )
))