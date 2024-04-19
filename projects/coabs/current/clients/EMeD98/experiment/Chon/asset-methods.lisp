(in-package "EXPECT")

(setf *domain-plans*
  '( 
((name estimate-time-to-move-asset)
 (capability (estimate
                (obj (?t is (spec-of time)))
                (for (?s is (inst-of move-asset)))
                ))
 (result-type (inst-of number))
 (method (estimate
            (obj (spec-of time))
            (through (asset-of ?s))
	    (of ?s)
            ))
)

 

((name estimate-op-con-time)
 (capability (estimate
                (obj (?t is (spec-of time)))
                (for (?s is (inst-of asset)))
                ))
 (result-type (inst-of number))
 (method (if (is-it-a 
	      (obj ?s)
	      (of (spec-of corps-level-asset)))
	     then 4
	     else 2))
)

((name find-distance)
 (primitivep t)
 (capability (estimate
                (obj (?t is (spec-of moving-time)))
                (from (?l1 is (inst-of location)))
		(to (?l2 is (inst-of location)))
                ))
 (result-type (inst-of number))
 (method (find-distance ?l1 ?l2))
)

((name estimate-moving-time)
 (capability (estimate
                (obj (?t is (spec-of time)))
                (for (?s is (inst-of asset)))
		(of (?p is (inst-of move-asset)))
                ))
 (result-type (inst-of number))
 (method (divide 
	  (obj (estimate 
		(obj (spec-of moving-time)) 
		(from (object-found-in-location ?s))
		(to (destination ?p))))
	  (by 60000)))
)
((name estimate-max-time)
 (capability (estimate
                (obj (?t is (spec-of time)))
                (through (?s is (set-of (inst-of asset))))
		(of (?p is (inst-of move-asset)))
                ))
 (result-type (inst-of number))
 (method (add
	  (obj (find
            (obj (spec-of maximum))
            (of (estimate
		 (obj (spec-of time))
		 (for ?s)
		 (of ?p)))))
	  (to (find
	       (obj (spec-of maximum))
	       (of (estimate
		   (obj (spec-of time))
		   (for ?s)))))))
)


))