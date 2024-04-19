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
       