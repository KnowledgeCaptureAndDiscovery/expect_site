(in-package "EXPECT")

(setf *domain-plans*
  '( 
((name estimate-time-to-fill-crater  )
(capability (estimate 
	     (obj (?t is (spec-of time))) 
	     (for (?f is (inst-of fill-crater)))))  
(result-type (inst-of number))
(method (divide 
	 (obj (estimate 
	       (obj (spec-of dirt-volume))
	       (of ?f)))
	 (by 
	  (estimate
	   (obj (spec-of earthmoving-rate))
	   (of ?f)))))
)

((name estimate-dirt-volume  )
(capability (estimate 
	     (obj (?v is (spec-of dirt-volume))) 
	     (of (?f is (inst-of fill-crater)))))  
(result-type (inst-of number))
(method 
 (multiply 
  (obj (height-of-object (crater-of ?f)))
  (by 
   (multiply 
    (obj
     (multiply
      (obj 1/12)
      (by 3.141592)))
    (by 
     (multiply
      (obj (width-of-object (crater-of ?f)))
      (by (length-of-object (crater-of ?f)))))))))
)

((name estimate-earthmoving-rate )
(capability (estimate 
	     (obj (?r is (spec-of earthmoving-rate))) 
	     (of (?f is (inst-of fill-crater))))) 
(result-type (inst-of number))
(method 
 (multiply 
  (obj 250)
  (by (find 
       (obj (spec-of adjustment-rate))
       (of (soil-of (crater-of ?f)))))))
)

((name find-adjustment-rate-for-soil )
(primitivep t)
(capability (find 
	     (obj (?a is (spec-of adjustment-rate))) 
	     (of (?s is (inst-of earth-stuff))))) 
(result-type (inst-of number))
(method (primitive-find-adjustment-rate-for-soil ?s))
)

((name estimate-time-to-narrow-gap )
(capability (estimate 
	     (obj (?t is (spec-of time))) 
	     (for (?b is (inst-of narrow-gap-with-bulldozer))))) 
(result-type (inst-of number))
(method (divide
	 (obj (estimate
	  (obj (spec-of dirt-volume))
	  (of (bank-of ?b))
	  (with (obstacle-of ?b))
	  (with ?b)))
	(by 
	 (estimate
	  (obj (spec-of earthmoving-rate))
	  (of (region-of ?b))))))
)

((name estimate-earthmoving-rate-for-bulldozer)
(capability (estimate 
	     (obj (?r is (spec-of earthmoving-rate))) 
	     (of (?g is (inst-of geographical-region))))) 
(result-type (inst-of number))
(method (multiply
	 (obj 250)
	 (by (find
	      (obj (spec-of adjustment-rate))
	      (of (soil-of ?g))))))
)

((name estimate-dirt-volume-for-bulldozer)
(capability (estimate 
	     (obj (?v is (spec-of dirt-volume))) 
	     (of (?b is (inst-of geographical-bank))) 
	     (with (?g is (inst-of geographical-gap))) 
	     (with (?n is (inst-of narrow-gap-with-bulldozer)))))
(result-type (inst-of number))
(method (multiply
	 (obj (subtract 
	       (obj (desired-width ?n))
	       (from (width-of-object ?g))))
	 (by 
	  (multiply 
	   (obj 8)
	   (by (height-of-object ?b))))))
)
))