(in-package "EXPECT")

(setf *domain-plans*
  '( 

((name estimate-time-for-fill-crater )
(capability (estimate (obj (?v1905 is (spec-of time)))
 (for (?v1906 is (inst-of fill-crater)))))  
(result-type (inst-of number))
(method (divide (obj (estimate (obj (spec-of dirt-volume))
			       (for (crater-of ?v1906))))
		(by (estimate (obj (spec-of earthmoving-rate))
			      (of (dozer-of ?v1906))
			      (with (soil-of (crater-of ?v1906)))))))
)

((name estimate-time-for-narrow-gap-with-bulldozer)
(capability (estimate (obj (?v1905 is (spec-of time))) 
		      (for (?v1906 is (inst-of narrow-gap-with-bulldozer)))))  
(result-type (inst-of number))
(method (divide (obj (estimate (obj (spec-of dirt-volume))
			       (for ?v1906)))
		(by (estimate (obj (spec-of earthmoving-rate))
			      (of (dozer-of ?v1906))
			      (with (soil-of (region-of ?v1906)))))))
)


((name estimate-adjustment-rate-for-earth-stuff)
(capability (estimate (obj (?v2054 is (spec-of earthmoving-rate))) 
(of (?v2055 is (inst-of military-dozer))) 
(with (?v2056 is (inst-of earth-stuff)))))  
(result-type (inst-of number))
(method (multiply (obj 250)
		  (by (estimate (obj (spec-of adjustment-rate))
				(of ?v2056)))))
)

((name adjustment-rate-for-earth-stuff)
 (primitivep t)
(capability (estimate (obj (?v2078 is (spec-of adjustment-rate))) 
(of (?v2079 is (inst-of earth-stuff)))))  
(result-type (inst-of number))
(method (primitive-find-adjustment-rate-for-soil ?v2079)  )
)

((name estimate-volume-for-crater)
(capability (estimate (obj (?v2091 is (spec-of dirt-volume))) (for (?v2029 is (inst-of crater)))))  
(result-type (inst-of number) )
(method (multiply (obj 1/12)
		  (by (multiply (obj (height-of-object ?v2029))
				(by (multiply (obj 3.141592)
					      (by (multiply (obj (width-of-object ?v2029))
							    (by (length-of-object ?v2029))))))))))
)

((name estimate-volume-for-narrow-gap )
(capability (estimate (obj (?v2140 is (spec-of dirt-volume))) (for (?v2141 is (inst-of narrow-gap-with-bulldozer)))))  
(result-type (inst-of number))
(method (multiply (obj (height-of-object (bank-of ?v2141)))
		  (by (multiply (obj 8)
				(by (subtract (obj (desired-width ?v2141))
					      (from (width-of-object (obstacle-of ?v2141)))))))))
)

))

;; 63