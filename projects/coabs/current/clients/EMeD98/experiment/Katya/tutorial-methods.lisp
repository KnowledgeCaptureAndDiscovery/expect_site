((name estimate-each-avlb)
(capability (estimate (obj (?t is (spec-of time)))
		      (for (?b is (inst-of avlb)))))
(result-type (inst-of number))
(method (if (is-less-or-equal
	     (obj (emplacement-time ?b))
	     (than 0.5))
	    then 0.5
	    else (emplacement-time ?b)))
)

((name estimate-bridge)
 (capability (estimate (obj (?t is (spec-of time)))
		       (for (?s is (inst-of emplace-avlb)))))
(result-type (inst-of number))
(method (find (obj (spec-of maximum))
	      (of (estimate (obj (spec-of time))
			    (for (bridge-of ?s))))))
)