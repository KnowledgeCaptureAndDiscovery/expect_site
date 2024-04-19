(in-package "EXPECT")

(setf *domain-plans*
  '( 
    
   ((name estimate-fill-crater)
 (capability (estimate
                (obj (?t is (spec-of time)))
                (for (?c is (inst-of fill-crater)))
                ))
 (result-type (inst-of number))
 (method (divide
            (obj (estimate
                    (obj (spec-of dirt-volume))
                    (for (crater-of ?c))))
	    (by (estimate 
		 (obj (spec-of earthmoving-rate))
		 (for (crater-of ?c))
		 )
		)
	    )
	 )
 )

  ((name estimate-narroe-gap-with-bulldozer)
 (capability (estimate
                (obj (?t is (spec-of time)))
                (for (?n is (inst-of narrow-gap-with-bulldozer)))
                ))
 (result-type (inst-of number))
 (method (divide
            (obj (estimate
                    (obj (spec-of dirt-volume))
                    (for (obstacle-of ?n))
		    (for (bank-of ?n))
		    (for desired-width ?n)))
	    (by (estimate 
		 (obj (spec-of earthmoving-rate))
		 (for (region-of ?n))
		 )
		)
	    )
	 )
 )
((name estimate-earthmoving-rate)
 (capability (estimate
                (obj (?r is (spec-of earthmoving-rate)))
                (for (?r is (inst-of geographical-region)))
                ))
 (result-type (inst-of number))
 (method (multiply
            (obj 250)
	    (by (estimate (for (soil-of ?r)))
		)
	    )
	 )
 )
    
    ((name primitive-find-adjustment-rate-for-soil)
 (primitivep t)
 (capability (estimate (for (?s is (inst-of earth-stuff))))
                )
 (result-type (inst-of number))
 (method (primitive-find-adjustment-rate-for-soil ?s))
     )
    
   
   ((name estimate-crater-volume1)
 (capability (estimate
	      (obj (?v is (spec-of dirt-volume)))
                (for (?c is (inst-of crater)))
                ))
 (result-type (inst-of number))
 (method (multiply
	  (obj 1/12)
	  (by (multiply
	       (obj 3.141592)
	       (by (multiply
		    (obj (height-of-object ?c))
		    (by (multiply
			 (obj (width-of-object ?c))
			 (by (length-of-object ?c)))
			)
		    )
		   )
	       )
	      )
	  )
	 )
    )
((name estimate-gap-volume)
 (capability (estimate
	      (obj (?v is (spec-of dirt-volume)))
                (for (?g is (inst-of geographical-gap)))
                (for (?b is (inst-of geographical-bank)))
                (for (?d is (inst-of number)))
                ))
 (result-type (inst-of number))
 (method (multiply
	  (obj 8)
	  (by (multiply
		 (obj (height-of-object ?b))
		 (by (subtract
		      (obj ?d)
		      (from (width-of-object ?g))))
		 )
		)
	    )
	 )
 )


))

;; 63