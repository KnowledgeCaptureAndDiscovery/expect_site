(in-package "EXPECT")
 
(setf *domain-plans*
 '(
((name compute-earth-volume-of-crater)
 (capability (find
                (obj (?v is (spec-of dirt-volume)))
                (of (?c is (inst-of crater)))))
  (result-type (inst-of number))
 (method (multiply (obj (height-of-object ?c))
		   (by (multiply (obj 1/3)
				 (by (multiply (obj 3.141592)
					       (by (multiply (obj 1/4)
						   (by (multiply (obj (width-of-object ?c))
								 (by (obj (length-of-object ?c))))
))))))))))


((name compute-eartg-moving-rate)
 (capability (estimate (obj (?emr is (spec-of earthmoving-rate)))
                (for (?c is (inst-of crater)))))
 (result-type (inst-of number))
 (method (multiply (obj (find
			 (obj (spec-of adjustment-rate))
			 (of (soil-of ?c))))
		   (by (obj 250))))
)



((name estimate-earth-moving-rate-of-gap)
 (capability (estimate (obj (?emr is (spec-of earthmoving-rate)))
                (for (?g is (inst-of geographical-region)))))
 (result-type (inst-of number))
 (method (multiply (obj (find
			 (obj (spec-of adjustment-rate))
			 (of (soil-of ?g))))
		   (by 250)))
)


((name estimate-dirt-volume-of-gap)
 (capability (estimate (obj (?v is (spec-of dirt-volume)))
                (for (?g is (inst-of narrow-gap-with-bulldozer)))))
 (result-type (inst-of number))
 (method (multiply (obj (height-of-object (bank-of ?g)))
		   (by (multiply (obj (subtract (obj (desired-width ?g))
						 (from (width-of-object (bank-of ?g)))))
				  (by 8)))))
 )

((name estimate-time-to-fill-gap)
 (capability (estimate (obj (?t is (spec-of time)))
                (for (?g is (inst-of narrow-gap-with-bulldozer)))))
 (result-type (inst-of number))
 (method (divide (obj (estimate (obj (spec-of dirt-volume))
				(for (?g))))
		 (by (estimate (obj (spec-of earthmoving-rate))
			       (for (region-of ?g))))))
)

((name estimate-adjustment-rate-of-soil)
 (primitivep t)
 (capability (find
                (obj (?ar is (spec-of adjustment-rate)))
                (of (?s is (inst-of earth-stuff)))))
  (result-type (inst-of number))
 (method (primitive-find-adjustment-rate-for-soil ?s))
)

((name estimate-time-to-fill-crater)
 (capability (estimate (obj (?t is (spec-of time)))
                (for (?c is (inst-of fill-crater)))))
 (result-type (inst-of number))
 (method (divide (obj (find (obj (spec-of dirt-volume))
			    (of (crater-of ?c))))
		 (by (estimate (obj (spec-of earthmoving-rate))
			       (for (crater-of ?c))))))
)
))