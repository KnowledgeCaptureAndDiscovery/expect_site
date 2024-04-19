(in-package "EXPECT")

(setf *domain-plans*
 '(
   ((name estimate-time-to-fill-crater)
 (capability (estimate (obj (?t is (spec-of time))) 
		       (for (?f is (inst-of fill-crater)))))  
 (result-type (inst-of number))
 (method (divide
	  (obj (find
		(obj (spec-of dirt-volume))
		(of (crater-of ?f))
		)
	  )
	 (by (find
	      (obj (spec-of earthmoving-rate))
	      (for (soil-of (crater-of ?f)))
	     )
	 )
	)
 )
)

((name find-earth-volume)
 (capability (find 
	      (obj (?v is (spec-of dirt-volume))) 
	      (of (?c is (inst-of crater)))
	      )
 )  
 (result-type (inst-of number))
(method (multiply 
	 (obj (height-of-object ?c))
	 (by (multiply
	      (obj
	       (find (obj (spec-of area))
		     (of ?c)
		     )
	       )
	      (by 1/3)
	      )
	     )
 ))
)

((name find-area)
 (capability (find (obj (?a is (spec-of area))) 
		   (of (?c is (inst-of crater)))))  
(result-type (inst-of number))
(method (multiply 
	 (obj (multiply
	       (obj (multiply
		     (obj (width-of-object ?c))
	             (by 1/4)))
	       (by (length-of-object ?c))))
	 (by 3.14159))
)
)

((name find-earthmoving-rate  )
(capability (find (obj (?r is (spec-of earthmoving-rate))) 
		  (for (?s is (inst-of earth-stuff)))))  
(result-type (inst-of number))
(method (multiply 
	 (obj (find 
	       (obj (spec-of adjustment-rate))
	       (for ?s)))
	 (by 250))
)
)

((name find-adjustment-rate)
(capability (find (obj (?r is (spec-of adjustment-rate))) 
		  (for (?s is (inst-of earth-stuff)))))  
(result-type (inst-of number))
(method (primitive-find-adjustment-rate-for-soil ?s))
(primitivep t)
)

((name estimate-time-to-narrow-gap-with-bulldozer)
(capability (estimate (obj (?t is (spec-of time))) 
		      (for (?g is (inst-of narrow-gap-with-bulldozer)))))  
(result-type (inst-of number))
(method (divide
	  (obj (find
		(obj (spec-of dirt-volume))
		(of (obstacle-of ?g))
		(for (bank-of ?g))
		(with (desired-width ?g))
		)
	  )
	 (by (find
	      (obj (spec-of earthmoving-rate))
	      (for (soil-of (region-of ?g)))
	     )
	 )
	 )
)
)

((name find-dirt-volume-of-gap  )
(capability (find (obj (?v is (spec-of dirt-volume))) 
		  (of (?g is (inst-of geographical-gap)))
	    (for (?b is (inst-of geographical-bank)))
	    (with (?w is (inst-of number))))) 
(result-type (inst-of number))
(method (multiply
	 (obj (multiply
	       (obj 
		(height-of-object ?b))
	       (by (subtract
		    (obj (width-of-object ?w))
		    (from (width-of-object ?g))
		    )
		   )))
	       (by 8)
	       )
)
)
))