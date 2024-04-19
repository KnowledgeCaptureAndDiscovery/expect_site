(in-package "EXPECT")

(setf *domain-plans*
  '( 
    
    ((name find-maximum-opcon-time )
(capability (find (obj (?ot is (spec-of opcon-time))) (of (?a is (inst-of asset)))))  
(result-type (inst-of number))
(method (if (is-it-a (obj ?a)
		     (of (spec-of corps-level-asset)))
	    then 4
	    else 2
	    )))


((name estimate-time-to-move-asset)
 (capability (estimate
                (obj (?t is (spec-of time)))
                (for (?m is (inst-of move-asset)))
                ))
 (result-type (inst-of number))
 (method (add
            (obj (find
                    (obj (spec-of maximum))
                    (of (find
                           (obj (spec-of opcon-time))
                           (of ( asset-of ?m))
                           ))
                     ))
               (to (find
                      (obj (spec-of maximum))
                      (of (find
                             (obj (spec-of moving-time))
                             (of ( asset-of ?m))
                             (with (destination ?m))
                             ))
                       ))
                 ))
 )

((name find-moving-time)
(capability (find (obj (?mt is (spec-of moving-time))) (of (?a is (inst-of asset)))
		  (with (?d is (inst-of location)))))  
(result-type (inst-of number))
(method (divide (obj (find (obj (spec-of moving-distance)) (from ?d) (to (object-found-in-location ?a))))
		(by 60000))))

((name primitive-moving-time)		    
 (capability (find (obj (?md is (spec-of moving-distance))) (from (?loc1 is (inst-of location))) (to (?loc2 is (inst-of location)))))
 (result-type (inst-of number))
 (method (find-distance ?loc1 ?loc2))
 (primitivep t))

))

;; 40 axioms