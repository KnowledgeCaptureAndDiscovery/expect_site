(in-package "EXPECT")

(setf *domain-plans*
  '( 
    
((name estimate-time-to-move-asset)
 (capability (estimate
	      (obj (?t is (spec-of time)))
	      (for (?s is (inst-of move-asset)))
	      ))
 (result-type (inst-of number))
 (method (add 
	  (obj
	   (find
	    (obj (spec-of maximum))
	    (of (estimate (obj (spec-of moving-time))
			  (for (asset-of ?s))
			  (to (destination ?s)))
		)
	    )
	   )
	  (to
	   (find
	    (obj (spec-of maximum))
	    (of (estimate (obj (spec-of opcon-time))
			  (for (asset-of ?s))))
	    )
	   ) 
	  )
	 )
 )
((name estimate-moving-time-of-asset  )
(capability (estimate (obj (?v is (spec-of moving-time))) 
		      (for (?a is (inst-of asset))) 
		      (to (?l is (inst-of location)))))
(result-type (inst-of number))
(method  (divide 
	  (obj
	   (estimate (obj (spec-of moving-distance))
		     (from (object-found-in-location ?a))
		     (to ?l)
		     )
	   )
	  (by 60000)
	  )
	 )
)

((name find-distance)
 (primitivep t)
 (capability (estimate (obj (?d is (spec-of moving-distance))) 
		       (from (?f is (inst-of location))) 
		       (to (?t is (inst-of location)))))
(result-type (inst-of number))
(method (find-distance ?f ?t)  )
)


((name estimate-opcon-time-of-asset)
(capability (estimate (obj (?v is (spec-of opcon-time)))
		      (for (?a is (inst-of asset)))))  
(result-type (inst-of number))
(method (if (is-it-a (obj ?a)
		     (of (spec-of corps-level-asset)))
	    then 4.0
	    else 2.0))
)
))

;; 40