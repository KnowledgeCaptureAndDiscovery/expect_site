(in-package "EXPECT")

(setf *domain-plans*
  '( 
((name estimate-time-to-move-assets)
 (capability (estimate
                (obj (?t is (spec-of time)))
                (for (?s is (inst-of move-asset)))
                ))
 (result-type (inst-of number))
 (method (add (obj (estimate (obj (spec-of time))
			 (for (asset-of ?s))))
	      (to (find (obj (spec-of maximum))
			(of (estimate
			     (obj (spec-of time))
			     (for (asset-of ?s))
			     (to (destination ?s))))))))
 )

((name estimate-opcon-time-for-all)
 (capability (estimate (obj (?t is (spec-of time)))
		       (for (?s is (set-of (inst-of asset))))))
 (result-type (inst-of number))
 (method (find (obj (spec-of maximum))
	       (of (estimate (obj (spec-of opcon-time))
			     (for ?s)))))
 )
((name estimate-opcon-time-for-each)
 (capability (estimate (obj (?t is (spec-of opcon-time)))
		       (for (?s is (inst-of asset)))))
 (result-type (inst-of number))
 (method (if (is-it-a (obj ?s)
		      (of corps-level-asset))
	     then 4
	     else 2))
 )

((name find-distance)
 (primitivep t)
 (capability (find (from (?t is (inst-of location)))
		   (to (?s is (inst-of location)))))
 (result-type (inst-of number))
 (method (find-distance ?t ?s))
)



((name estimate-moving-time-for-each-asset)
 (capability (estimate (obj (?t is (spec-of time)))
		       (for (?s is (inst-of asset)))
		       (to (?u is (inst-of location)))))
 (result-type (inst-of number))
 (method (divide (obj (find (from (object-found-in-location ?s))
			    (to ?u)))
		 (by 60000)))
 )
))

;; 46