(in-package "EXPECT")
 
(setf *domain-plans*
 '(   
((name compute-volume-for-gap)
 (capability (estimate
                (obj (?v is (spec-of dirt-volume)))
                (for (?s is (inst-of narrow-gap-with-bulldozer)))
                ))
 (result-type (inst-of number))
 (method 
  (multiply (obj (height-of-object (bank-of ?s)))
	    (by (multiply (obj 8)
			  (by (subtract (obj (width-of-object (obstacle-of ?s)))
					 (from (desired-width ?s))))))))
)
  
((name estimate-time-to-move-dirt)
 (capability (estimate
	      (obj (?t is (spec-of time)))
	      (for (?s is (inst-of workaround-step)))
	      ))
 (result-type (inst-of number))
 (method 
  (divide (obj (estimate (obj (spec-of dirt-volume))
			 (for ?s)))
	  (by (multiply (obj (estimate (obj (spec-of earthmoving-rate))
				       (for ?s)))
			(by (estimate (obj (spec-of adjustment-rate))
				      (for ?s)))))))
 )

((name compute-volume-for-crater)
 (capability (estimate
                (obj (?v is (spec-of dirt-volume)))
                (for (?s is (inst-of fill-crater)))
                ))
 (result-type (inst-of number))
 (method 
  (multiply
   (obj 1/12)
   (by (multiply 
	(obj 3.141592)
	(by (multiply 
	     (obj (height-of-object (crater-of ?s)))
	     (by (multiply 
		  (obj  (width-of-object (crater-of ?s)))
		  (by (length-of-object (crater-of ?s)))))))))))
)

((name estimate-standard-earthmoving-rate)
 (capability (estimate
	      (obj (?t is (spec-of earthmoving-rate)))
	      (for (?s is (inst-of workaround-step)))
	      ))
 (result-type (inst-of number))
 (method 
  250)
)

((name estimate-adjustment-rate-for-narrow-gap-with-bulldozer)
 (capability (estimate
	      (obj (?t is (spec-of adjustment-rate)))
	      (for (?s is (inst-of narrow-gap-with-bulldozer)))
	      ))
 (result-type (inst-of number))
 (method 
  (find (obj (spec-of adjustment-rate))
	    (of (soil-of (region-of ?s)))))
 )

((name estimate-adjustment-rate-for-fill-crater)
 (capability (estimate
	      (obj (?t is (spec-of adjustment-rate)))
	      (for (?s is (inst-of fill-crater)))
	      ))
 (result-type (inst-of number))
 (method 
  (find (obj (spec-of adjustment-rate))
	    (of (soil-of (crater-of ?s)))))
 )

((name find-adjustment-rate-for-soil)
 (primitivep t)
 (capability (find
                (obj (?a is (spec-of adjustment-rate)))
                (of (?e is (inst-of earth-stuff)))
                ))
 (result-type (inst-of number))
 (method (primitive-find-adjustment-rate-for-soil ?e))
)
))