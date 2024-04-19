(in-package "EXPECT")

(setf *domain-plans*
  '( 
((name estimate-time-fill-gap)
(capability (estimate (obj (?time is (spec-of time)))
		      (for (?narrow-gap is (inst-of Narrow-gap-with-bulldozer)))))
(result-type (inst-of number))
(method (divide (obj (find (obj (spec-of earth-stuff))
			   (for ?narrow-gap)))
		(by (find (obj (spec-of earthmoving-rate))
			  (for (dozer-of ?narrow-gap))
			  (with (soil-of (region-of ?narrow-gap))))))))

((name estimate-earth-stuff-for-gap)
(capability (find (obj (?earth is (spec-of earth-stuff)))
			   (for (?narrow-gap is (inst-of narrow-gap-with-bulldozer)))))
(result (inst-of number))
(method (multiply 
	 (obj (multiply (obj (height-of-object (bank-of ?narrow-gap)))
			(by 8)))
	 (subtract (obj (desired-width ?narrow-gap))
		   (from (width-of-object (bank-of ?narrow-gap)))))))

((name get-earth-moving-rate)
(capability (find (obj (?rate is (spec-of earthmoving-rate)))
		  (for (?dozer is (inst-of military-dozer)))
		  (with (?soil is (inst-of earth-stuff)))))
(result-type (inst-of number))
(method
(multiply (obj 250)
	  (by (find (obj (spec-of adjustment-rate))
		    (for ?soil))))))

((name find-adjustment-rate)
(capability(find (obj (?rate is (spec-of adjustment-rate)))
		    (for (?soil is  (inst-of earth-stuff))) ))
(result-type (inst-of number))
(method (primitive-find-adjustment-rate-for-soil ?soil))
(primitivep t)
)

((name estimate-time-fill-crate)
(capability (estimate (obj (?time is (spec-of time)))
		      (for (?fill-crater is (inst-of fill-crater)))))
(result-type (inst-of number))
(method (divide (obj (find (obj (spec-of earth-stuff))
			   (for ?fill-crater)))
		(by (find (obj (spec-of earthmoving-rate))
			  (for (dozer-of ?fill-crater))
			  (with (soil-of (crater-of ?fill-crater))))))))


((name estimate-earth-stuff-for-crater)
(capability (find (obj (?earth is (spec-of earth-stuff)))
			   (for (?crater is (inst-of crater)))))
(result (inst-of number))
(method (multiply 
	 (obj (multiply (obj (height-of-object ?crater))
			(by 1/3)))
	 (by (estimate (obj (spec-of area))
		       (for ?crater))))))

((name estimatesurface-for-crater)
(capability (find (obj (?surface is (spec-of area)))
			   (for (?crater is (inst-of crater)))))
(result (inst-of number))
(method (multiply 
	 (obj (multiply 
	       (obj (multiply (obj (width-of-object ?crater))
			      (by 1/4)))
	       (by (length-of-object ?crater))))
	      (by 3.14))))

))