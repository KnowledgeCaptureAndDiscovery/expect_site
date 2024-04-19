(in-package "EXPECT")

(setf *domain-plans*
 '(
   ((name estimate-fill-crater)
(capability (estimate (obj (?t is (spec-of time)))
		      (for (?s is (inst-of fill-crater)))))
(result-type (inst-of number))
(method 
 (divide (obj (compute (obj (spec-of dirt-volume))
		       (of (crater-of ?s))))
	 (by (compute (obj (spec-of earthmoving-rate))
		      (of (crater-of ?s)))))

)
)

((name compute-crater-dirt)
(capability (compute (obj (?d is (spec-of dirt-volume)))
		     (of (?c is (inst-of crater)))))
(result-type (inst-of number))
(method 
 (multiply (obj 1/3)
	   (by (multiply (obj (height-of-object ?c))
			 (by (compute (obj (spec-of area))
				      (for ?c))))))

)
)


((name compute-earthmoving-rate)
(capability (compute (obj (?r is (spec-of earthmoving-rate)))
		     (of (?g is (inst-of geographical-region)))))
(result-type (inst-of number))
(method 
 (multiply (obj 250)
	   (by (find (obj (spec-of adjustment-rate))
		     (for (soil-of ?g)))))


)
)

((name find-adjustment-rate)
(capability (find (obj (?r is (spec-of adjustment-rate)))
		  (for (?e is (inst-of earth-stuff)))))
(result-type (inst-of number))
(primitivep t)
(method 
 (primitive-find-adjustment-rate-for-soil ?e)

)
)

((name estimate-narrow-gap)
(capability (estimate (obj (?t is (spec-of time)))
		      (for (?s is (inst-of narrow-gap-with-bulldozer)))))
(result-type (inst-of number))
(method 
 (divide (obj (compute (obj (spec-of dirt-volume))
		       (of (obstacle-of ?s))
		       (in (bank-of ?s))
		       (to (desired-width ?s))))
	 (by (compute (obj (spec-of earthmoving-rate))
		      (of (region-of ?s)))))


)
)

((name compute-gap-volume)
(capability 
 (compute (obj (?d is (spec-of dirt-volume)))
	  (of (?g is (inst-of geographical-gap)))
	  (in (?b is (inst-of geographical-bank)))
	  (to (?w is (inst-of number))))
)
(result-type (inst-of number))
(method 
 (multiply (obj (height-of-object ?b))
	   (by (multiply (obj 8)
			 (by (subtract (obj ?w)
				       (from (width-of-object ?g)))))))

)
)

((name compute-crater-area)
(capability (compute (obj (?a is (spec-of area)))
		     (for (?c is (inst-of crater)))))
(result-type (inst-of number))
(method 
 (multiply (obj 3.14)
	   (by (multiply (obj 1/2)
			 (by (multiply (obj 1/2)
				       (by (multiply (obj (width-of-object ?c))
						     (by (length-of-object ?c)))))))))

)
)
))