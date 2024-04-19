(in-package "EXPECT")

(setf *domain-plans*
  '( 
    
((name estimate-compute-volume)
 (capability (estimate (obj (?v is (spec-of dirt-volume))) (of (?f is (inst-of crater)))))
 (result-type (inst-of number))
 (method (multiply (obj (multiply
			 (obj (multiply
			       (obj (multiply
				     (obj (multiply
					   (obj (multiply
						 (obj 3.141592) (by 0.5)))
					   (by 0.5)))
				     (by (width-of-object ?f))))
			       (by (length-of-object ?f))))
			 (by 1/3)))
		   (by (height-of-object ?f)))))

((name estimate-time-to-fill-crater)
(capability (estimate (obj (?t is (spec-of time)))
		      (for (?f is (inst-of fill-crater)))))
(result-type (inst-of number))
(method (divide (obj (estimate
		      (obj (spec-of dirt-volume))
		      (of (crater-of ?f))))
		(by (estimate
			  (obj (spec-of earthmoving-rate))
			  (of (crater-of ?f))))))
)


((name find-adjustment-rate-for-soil2)
 (capability (find (obj (?ad is (spec-of adjustment-rate)))
                   (of (?s is (inst-of earth-stuff)))))
 (result-type (inst-of number))
 (method (primitive-find-adjustment-rate-for-soil ?s))
 (primitivep t))


((name compute-earthmoving-rate)
 (capability (estimate (obj (?er is (spec-of earthmoving-rate)))
		       (of (?f is (inst-of geographical-region)))))
(result-type (inst-of number))
(method (multiply (obj 250)
		  (by (find (obj (spec-of adjustment-rate))
			    (of (soil-of ?f))))))
)

((name estimate-time-to-narrow-gap)
 (capability (estimate (obj (?t is (spec-of time)))
		       (for (?f is (inst-of narrow-gap-with-bulldozer)))))
 (result-type (inst-of number))
 (method (divide (obj (estimate
		       (obj (spec-of dirt-volume))
		       (of (bank-of ?f))
		       (to (obstacle-of ?f))
		       (with (desired-width ?f))))
		 (by (estimate
		      (obj (spec-of earthmoving-rate))
		      (of (region-of ?f))))))
 )
((name compute-narrow-gap-dirt-volume)
 (capability (estimate (obj (?v is (spec-of dirt-volume)))
		       (of (?gb is (inst-of geographical-bank)))
		       (to (?gg is (inst-of geographical-gap)))
		       (with (?n is (inst-of number)))))
 (result-type (inst-of number))
 (method (multiply (obj (multiply
			 (obj (subtract (obj (width-of-object ?gg))
					(from ?n)))
			 (by 8)))
		   (by (height-of-object ?gb))))
 )
))

;; 67 axioms