(in-package "EXPECT")

(setf *domain-plans*
 '(     
((name estimate-earthmoving-rate-for-soil)
 (capability
  (estimate (obj (?r is (spec-of earthmoving-rate)))
	    (for (?s is (inst-of earth-stuff)))))
(result-type (inst-of number))
(method (multiply
	 (obj 250)
	 (by (find (obj (spec-of adjustment-rate))
		   (for ?s)))))
)

((name find-adjustment-rate-for-soil)
 (primitivep t)
 (capability (find (obj (?r is (spec-of adjustment-rate)))
		   (for (?s is (inst-of earth-stuff)))))
(result-type (inst-of number))
(method (primitive-find-adjustment-rate-for-soil ?s))
)


((name find-dirt-volume-for-crater)
 (capability (find (obj (?v is (spec-of dirt-volume)))
		   (for (?c is (inst-of crater)))))
 (result-type (inst-of number))
 (method
  (multiply
   (obj 1/3)
   (by (multiply
	(obj (height-of-object ?c))
	(by (multiply
	     (obj 3.14)
	     (by (multiply
		  (obj 1/4)
		  (by (multiply
		       (obj (width-of-object ?c))
		       (by (length-of-object ?c))))))))))))
)

((name estimate-time-to-fill-crater)
 (capability
  (estimate (obj (?t is (spec-of time)))
	    (for (?c is (inst-of fill-crater)))))
 (result-type (inst-of number))
 (method
  (divide (obj (find (obj (spec-of dirt-volume))
		     (for (crater-of ?c))))
	  (by (estimate
	       (obj (spec-of earthmoving-rate))
	       (for (soil-of (crater-of ?c)))))))
 )


((name estimate-time-to-narrow-gap-with-bulldozer)
 (capability (estimate (obj (?t is (spec-of time)))
		       (for (?s is (inst-of narrow-gap-with-bulldozer)))))
 (result-type (inst-of number))
 (method
  (divide
   (obj (find (obj (spec-of dirt-volume))
	      (for ?s)))
   (by (estimate
	(obj (spec-of earthmoving-rate))
	(for (soil-of (region-of ?s)))))))
)

((name find-dirt-volume-to-narrow-gap)
 (capability (find (obj (?v is (spec-of dirt-volume)))
		   (for (?s is (inst-of narrow-gap-with-bulldozer)))))
 (result-type (inst-of number))
 (method
  (multiply
   (obj (height-of-object (bank-of ?s)))
   (by (multiply
	(obj 8)
	(by (subtract (obj (width-of-object (obstacle-of ?s)))
		      (from (desired-width ?s))))))))
)
))

;; 61 axioms