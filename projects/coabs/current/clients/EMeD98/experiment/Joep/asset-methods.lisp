(in-package "EXPECT")

(setf *domain-plans*
  '( 

 ((name estimate-opcon-set2 )
(capability (estimate (obj (?time is (spec-of opcon-time))) (of (?asset is (set-of (inst-of asset))))))  
(result-type (inst-of number))
(method (find
                (obj (spec-of maximum))
                (of (estimate (obj (spec-of opcon-time))
			      (for ?asset)))
                ))  )

((name estimatye-one-asset )
(capability (estimate (obj (?opcon-time is (spec-of opcon-time))) (for (?asset is (inst-of asset)))))  
(result-type (inst-of number ))
(method (if (is-it-a (obj ?asset  )
		     (of (spec-of corps-level-asset)))
	    then 4
	    else 2)))

((name estimate-moving-times)
 (capability (estimate (obj (?time2 is (spec-of moving-time))) 
		       (with (?move-asset is (inst-of move-asset)))
		       (of (?asset is (set-of (inst-of asset))))))
 (result-type (inst-of number))
 (method (find
            (obj (spec-of maximum))
            (of (estimate
                   (obj (spec-of moving-time))
		   (with ?move-asset)
                   (for ?asset)
                   ))
            ))
)

((name estimate-move-asset-to-place  )
(capability (estimate (obj (?tim is (spec-of time))) (for (?move-asset is (inst-of move-asset)))))  
(result-type (inst-of number))
(method (add (obj (estimate (obj (spec-of opcon-time))
			    (of (asset-of ?move-asset))))
	     (to (estimate (obj (spec-of moving-time))
			   (with ?move-asset)
			   (of (asset-of ?move-asset)))))))


((name estimate-moving-an-asset )
(capability (estimate (obj (?time is (spec-of moving-time)))
		      (with (?move-asset is (inst-of move-asset))) 
		      (for (?asset is (inst-of asset)))))  
(result-type (inst-of number))
(method (divide (obj (find (obj (spec-of moving-distance))
			   (from (object-found-in-location ?asset))
			   (to (destination ?move-asset))))
		(by 60000))))

((name compute-distance  )
(capability (find (obj (?distance is (spec-of moving-distance))) (from (?A is (inst-of location))) (to (?B is (inst-of location)))))  
(result-type (inst-of number))
(method  (find-distance ?A ?B))
(primitivep t)
)

))