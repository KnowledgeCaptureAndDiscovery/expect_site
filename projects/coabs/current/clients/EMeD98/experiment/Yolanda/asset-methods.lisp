(in-package "EXPECT")

(setf *domain-plans*
 '(   
((name method2578  )
(capability (estimate (obj (?v2582 is (spec-of opcon-time))) 
		      (for (?v2583 is (set-of (inst-of asset)))))  )
(result-type (inst-of number))
(method   
 (find (obj (spec-of maximum))
       (of (find (obj (spec-of opcon-time))
		 (for ?v2583))))
)
)

((name method2577  )
(capability (estimate (obj (?v2582 is (spec-of time))) 
		      (for (?v2583 is (inst-of move-asset)))))  
(result-type (inst-of number))
(method   
 (add (obj (estimate (obj (spec-of opcon-time))
		     (for (asset-of ?v2583))))
      (to (estimate (obj (spec-of moving-time))
		    (for (asset-of ?v2583))
		    (to (destination ?v2583))
)))
)
)


((name method2664  )
(capability (find (obj (?v2671 is (spec-of opcon-time))) 
		  (for (?a is (inst-of asset)))))  
(result-type (inst-of number) )
(method   
 (if (is-it-a (obj ?a)
	      (of (spec-of corps-level-asset)))
     then 4
     else 2)

)
)

((name method2686  )
(capability (estimate (obj (?v2689 is (spec-of moving-time))) 
		      (for (?a is (set-of (inst-of asset))))
		      (to (?l is (inst-of location))
)))  
(result-type (inst-of number))
(method   
 (find (obj (spec-of maximum))
       (of (find (obj (spec-of moving-time))
		 (for ?a)
		 (to ?l)))
)
))

((name method2734  )
(capability (find (obj (?v2738 is (spec-of moving-time))) 
		  (for (?a is (inst-of asset))) (to (?l is (inst-of location)))))  
(result-type (inst-of number))
(method   

(divide (obj (find (obj (spec-of moving-distance))
		   (from (object-found-in-location ?a))
		   (to ?l)))
	(by 60000))
)
)


((name method2741  )
(capability (find (obj (?v2757 is (spec-of moving-distance))) 
		  (from (?l1 is (inst-of location))) 
		  (to (?l2 is (inst-of location)))))  
(result-type (inst-of number))
(primitivep t)
(method   
 (find-distance ?l1 ?l2)

)
)
))