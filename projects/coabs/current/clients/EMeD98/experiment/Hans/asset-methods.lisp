(in-package "EXPECT")

(setf *domain-plans*
 '(
((name estimate-time-to-move-asset)
 (capability (estimate
                (obj (?t is (spec-of time)))
                (for (?s is (inst-of move-asset)))
                ))
 (result-type (inst-of number))
 (method 
  (add (obj (estimate (obj (spec-of opcon-time))
		      (for ?s)))
       (to (estimate (obj (spec-of moving-time))
		     (for ?s))))))

((name estimate-opcon-time-to-move-one-asset)
 (capability (estimate
                (obj (?t is (spec-of opcon-time)))
                (for (?s is (inst-of asset)))
                ))
 (result-type (inst-of number))
 (method 
  (if (is-it-a (obj ?s) (of corp-level-asset))
      then 4.0
      else 2.0)))


((name estimate-opcon-time-to-move-asset)
 (capability (estimate
                (obj (?t is (spec-of opcon-time)))
                (for (?s is (inst-of move-asset)))
                ))
 (result-type (inst-of number))
 (method 
  (find (obj (spec-of maximum))
	(of (estimate
	     (obj (spec-of opcon-time))
	     (for (asset-of ?s)))))))

((name estimate-moving-time-to-move-one-asset)
 (capability (estimate
                (obj (?t is (spec-of moving-time)))
                (for (?s is (inst-of asset)))
		(to (?d is (inst-of location)))))
 (result-type (inst-of number))
 (method 
  (divide (obj (find (obj (inst-of moving-distance))
		     (from (object-found-in-location ?s))
		     (to ?d)))
	  (by 60000))))

((name find-distance-between-locations)
 (primitivep t)
 (capability (find (obj (?d is (inst-of moving-distance)))
		   (from (?o is (inst-of location)))
		   (to (?d is (inst-of location)))))
 (result-type (inst-of number))
 (method (find-distance ?o ?d))
)

((name estimate-moving-time-to-move-asset)
 (capability (estimate
                (obj (?t is (spec-of moving-time)))
                (for (?s is (inst-of move-asset)))))
 (result-type (inst-of number))
 (method 
  (find (obj (spec-of maximum))
	(of (estimate
	     (obj (spec-of moving-time))
	     (for (asset-of ?s))
	     (to (destination ?s)))))))
))
;; 55 axioms