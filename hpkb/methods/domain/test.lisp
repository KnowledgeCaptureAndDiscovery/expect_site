(setq *exe-top-level-goals* 
  '(

;    (estimate (obj (spec-of combat-power))
;	      (of |RedTankBn1|)
;	      (with-respect-to |Fix1|))
;    (estimate (obj (spec-of combat-power))
;     (of |RedMechRegt1|)
;     (with-respect-to |Fix1|))
	  
;    (estimate (obj (spec-of combat-power))
;     (of |BlueMechBgd1|)
;     (with-respect-to |Fix1|))

    (estimate (obj force-ratio)
     (available-to |Defeat-MilitaryTask-task1|))
    
    (estimate (obj amount)
     (of force-ratio)
     (needed-by-set |Defeat-MilitaryTask-task1|))

    (estimate (obj (spec-of combat-power))
     (of |BlueMechBgd2|)
     (with-respect-to |Defeat-MilitaryTask-task1|))
    
    (estimate (obj (spec-of combat-power))
     (of |BlueTankBgd1|)
     (with-respect-to |Defeat-MilitaryTask-task1|))
    
    (estimate (obj (spec-of combat-power))
     (of |RedMechRegt2|)
     (with-respect-to |Defeat-MilitaryTask-task1|))
    (estimate (obj (spec-of combat-power))
     (of |RedTankBn1|)
     (with-respect-to |Defeat-MilitaryTask-task1|))
    
    
;    (estimate (obj force-ratio)
;     (available-to |Fix1|))
    
;    (estimate (obj amount)
;     (of force-ratio)
;     (needed-by-set |Fix1|))

    (evaluate (obj example-coa))
	  
	  )
	)
