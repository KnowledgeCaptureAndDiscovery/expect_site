(let ((*always-remove-p* t))
  (create-problem-space 'workarounds :current t))

;;; There are so many arity changes it's not worth printing them all.
;;; This variable recognises :error and :warn as values and ignores the rest.
(setf p4::*behaviour-on-arity-change* :nothing)

(pset :depth-bound 1000)

(ptype-of military-unit :top-type)
(ptype-of headquarter-company military-unit)
(ptype-of armored-company military-unit)
(ptype-of support-company military-unit)
(ptype-of engineer-company military-unit)
(ptype-of infantry-brigade military-unit)
(ptype-of infantry-division military-unit)
(ptype-of corps military-unit)
(ptype-of squad military-unit)
(ptype-of mortar-platoon military-unit)
(ptype-of recon-platoon military-unit)
(ptype-of support-platoon military-unit)
(ptype-of headquarter-unit military-unit)
(ptype-of armored-battalion military-unit)
(ptype-of support-battalion military-unit)

(ptype-of vehicle :top-type)
(ptype-of m35a2 vehicle)


(ptype-of place :top-type)

(ptype-of geographical-region place)
(ptype-of geographical-gap geographical-region)
(ptype-of geographical-approach geographical-region)
(ptype-of geographical-bank geographical-region)
(ptype-of body-of-water geographical-region)
(ptype-of city geographical-region)	; ?

(ptype-of tunnel geographical-region)
(ptype-of tunnel-opening geographical-region)

(ptype-of ford-site geographical-gap)

(ptype-of minefield geographical-region)

;;; Added for the modification phase
(ptype-of road-segment geographical-region)
(ptype-of crater geographical-region)

;;; should be a less flat hierarchy, no doubt.
(ptype-of engineering-equipment :top-type)
(ptype-of M60A1 engineering-equipment)
(ptype-of M113 engineering-equipment)
(ptype-of GENERIC-IRANIAN-LIGHT-WHEELED-VEHICLE engineering-equipment)
(ptype-of M88 engineering-equipment)
(ptype-of GENERIC-IRANIAN-HEAVY-WHEELED-VEHICLE engineering-equipment)
(ptype-of TANK-PLOW engineering-equipment)
(ptype-of TANK-BLADE engineering-equipment)
(ptype-of BANGALORE-TORPEDO engineering-equipment)
(ptype-of EXPLOSIVES engineering-equipment)
(ptype-of MILITARY-DOZER engineering-equipment)
(ptype-of MILITARY-LOADER engineering-equipment)
(ptype-of MILITARY-CRANE engineering-equipment)
(ptype-of BEB engineering-equipment)
(ptype-of RIBBON-BRIDGE-BAY engineering-equipment)
(ptype-of RIBBON-BRIDGE-RAMP engineering-equipment)
(ptype-of CEV engineering-equipment)
(ptype-of MICLIC engineering-equipment)
(ptype-of EIGHT-PERSON-RAFT engineering-equipment)
(ptype-of THREE-PERSON-RAFT engineering-equipment)

(ptype-of civilian-bridge :top-type)
(ptype-of bridge engineering-equipment)

(ptype-of military-fixed-bridge bridge)
(ptype-of floating-bridge bridge)

(ptype-of avlb-bridge military-fixed-bridge)
(ptype-of mgb military-fixed-bridge)
(ptype-of m4t6-fixed-bridge military-fixed-bridge)
(ptype-of bailey-bridge military-fixed-bridge)

;;; added for the modification phase
(ptype-of tmm-bridge military-fixed-bridge)

(ptype-of Ribbon-Bridge floating-bridge)
(ptype-of m4t6 floating-bridge)

(ptype-of equipment-collection :top-type)

(ptype-of feature :top-type)

(ptype-of country :top-type)
(pinstance-of IRAN country)

(ptype-of soil-type :top-type)
(pinstance-of loam gravel sand rock clay soil-type)

(ptype-of vegetation-type :top-type)
(pinstance-of desertscrub cultivated none vegetation-type)

(ptype-of rubble :top-type)
(pinstance-of no-rubble rubble)

(ptype-of wetness-level :top-type)
(pinstance-of wet dry intermittent wetness-level)

(infinite-type Number #'numberp)

;;; OPERATORS ==============================


;;; Moving stuff ==============================

(Operator MOVE-MILITARY-UNIT
 (params <unit> <old-loc> <new-loc>)
 (preconds
  ((<unit> military-unit)
   ;;(<feature> Feature)  p5 has no features, but I want to move units
   ;; don't require a loc since none of the interesting units originally
   ;; has one in p5.lisp
   (<old-loc> (and city (gfp (object-found-in-location <unit> <old-loc>))))
   ;; this is set from the goal.
   (<new-loc> (and place (diff <old-loc> <new-loc>)
	         (nothing-between <old-loc> <new-loc>))
	    ;;(and place (value-of 'left-approach <feature> <new-loc>))
	    )
   (<feature-destination-of>
    (and geographical-region
         (feature-of <new-loc> <feature-destination-of>)))
   )
  (and
   (operational-control <unit>)
   ))
 ;; This is inefficient (since I don't constrain the values of
 ;; <collection> and <item>) but it works. Might make it more efficient
 ;; later, but the difference makes planning go from 0.5 seconds to 1.5
 ;; seconds so it's not a high priority.
  (effects
   ((<collection> equipment-collection
	        #|(and equipment-collection
		   (gfp 'mission-equipment <unit> <collection>))|#
	        )
    (<item> engineering-equipment
	  #|(and engineering-equipment
	       (gfp 'group-members <collection> <item>))|#
	  ))
   ((del (object-found-in-location <unit> <old-loc>))
    (add (object-found-in-location <unit> <new-loc>))
    (if (and (mission-equipment <unit> <collection>)
	   (group-members <collection> <item>))
        ((del (object-found-in-location <item> <old-loc>))
         (add (object-found-in-location <item> <new-loc>))))
    ;;(add (available-at-feature <unit> <feature>))
    ;; all equipment moves with the unit - see inference rule below.
    )))

(inference-rule EQUIPMENT-FOUND-WITH-UNIT
  (params <unit> <equipment> <location>)
  (preconds
   ((<equipment> engineering-equipment)
    (<collection> (and equipment-collection
		   (gfp (group-members <collection> <equipment>))))
    (<unit> (and military-unit
	       (gfp (mission-equipment <unit> <collection>))))
    (<old-loc> (and city ; place
		(gfp (object-found-in-location <equipment> <old-loc>))))
    (<location> place))
   (and (object-found-in-location <unit> <location>)))
  (effects ()
	 ((del (object-found-in-location <equipment> <old-loc>))
	  (add (object-found-in-location <equipment> <location>)))))

(Operator GET-OPERATIONAL-CONTROL-OF-UNIT
 (params <unit>)
 (preconds
  ((<unit> military-unit)
   )
  (and))
 (effects
  ()
  ((add (operational-control <unit>))
   )))


;;; There are control rules to make sure the most sensible of these next
;;; two operators is picked. If you can use a bridge you prefer to,
;;; unless the option being tested is fording.

;;; NOTE: Jim: in move-asset-across-bridge: a precondition is that
;;; bridge is NOT mined - this is handled by the "trafficable"
;;; precondition.

(Operator MOVE-ASSET-ACROSS-FIXED-BRIDGE
 (params <bridge> <asset> <old-loc> <destination>)
 (preconds
  ((<bridge> (or civilian-bridge military-fixed-bridge))
   (<gap> Geographical-Gap)
   (<asset> engineering-equipment)
   (<destination> (and geographical-approach
		   (either-approach <gap> <destination>)))
   (<old-loc> (and geographical-approach
                   (gfp (object-found-in-location <asset> <old-loc>))
	         (either-approach <gap> <old-loc>)
	         (diff <destination> <old-loc>)))
   )
  (and
   ;;(trafficable <bridge> <gap> <unit>)
   (emplaced <bridge> <gap>)
   (~ (mined <bridge>))
   (~ (mined <old-loc>))
   (~ (in-use <asset>))
   ))
 (effects
  ()
  ((del (object-found-in-location <asset> <old-loc>))
   (add (object-found-in-location <asset> <destination>))
   (add (in-use <asset>))
  )))

(Operator MOVE-ASSET-ACROSS-FLOATING-BRIDGE
 (params <bridge> <asset> <old-loc> <destination>)
 (preconds
  ((<bridge> floating-bridge)
   (<gap> Geographical-Gap)
   (<asset> engineering-equipment)
   (<destination> (and geographical-approach
		   (either-approach <gap> <destination>)))
   (<old-loc> (and geographical-approach
                   (gfp (object-found-in-location <asset> <old-loc>))
	         (either-approach <gap> <old-loc>)
	         (diff <destination> <old-loc>)))
   (<unit> Military-unit)
   )
  (and
   ;;(trafficable <bridge> <gap> <unit>)
   (emplaced <bridge> <gap>)
   (desloped <gap> <old-loc>)
   (~ (mined <old-loc>))
   (~ (in-use <asset>))
   ))
 (effects
  ()
  ((del (object-found-in-location <asset> <old-loc>))
   (add (object-found-in-location <asset> <destination>))
   (add (in-use <asset>))
  )))

(Operator MOVE-ASSET-ACROSS-RAFT
 (params <raft> <asset> <old-loc> <destination>)
 (preconds
  ((<raft> floating-bridge)
   (<gap> Geographical-Gap)
   (<asset> engineering-equipment)
   (<destination> (and geographical-approach
		   (either-approach <gap> <destination>)))
   (<old-loc> (and geographical-approach
                   (gfp (object-found-in-location <asset> <old-loc>))
	         (either-approach <gap> <old-loc>)
	         (diff <destination> <old-loc>)))
   (<unit> Military-unit)
   )
  (and
   ;;(trafficable <bridge> <gap> <unit>)
   ;;(emplaced <bridge> <gap>)
   (assembled-raft <raft> <gap> <unit>)
   (desloped <gap> <old-loc>)
   (~ (mined <old-loc>))
   (~ (in-use <asset>))
   ))
 (effects
  ()
  ((del (object-found-in-location <asset> <old-loc>))
   (add (object-found-in-location <asset> <destination>))
   (add (in-use <asset>))
  )))

;;; I need two copies of this operator, one with the same ford as a gap
;;; and one with a different ford from the gap, because Prodigy can't
;;; handle having the same goal mentioned twice in the preconditions.
(Operator MOVE-ASSET-ACROSS-FORD-DIFFERENT-FROM-GAP
  (params <gap> <ford> <asset> <old-loc> <destination>)
  (preconds
   ((<gap> Geographical-gap)
    (<ford> (and Geographical-gap (diff <gap> <ford>)))
    (<asset> engineering-equipment)
    (<destination> (and Geographical-approach
		    (either-approach <gap> <destination>)))
    (<old-loc> (and geographical-approach
                   (gfp (object-found-in-location <asset> <old-loc>))
	         (either-approach <gap> <old-loc>)
	         (diff <destination> <old-loc>)))
    (<ford-near-approach>
     (and geographical-approach
	(approaches-on-same-side-of-river
	 <gap> <old-loc> <ford> <ford-near-approach>)))
    (<river> (and body-of-water
	        (gfp (river-of <ford> <river>))
	        (dry-or-not-mined <river>)))
    (<river-current> (and number
		      ;;(gfp (river-current <river> <river-current>))
		      (gen-river-current <river> <river-current>)
		      (< <river-current> 1.5))) ; 1.5MPS
    (<river-depth> (and number
		    (gfp (water-depth <river> <river-depth>))
		    ;; Should be 0.75 if there are wheeled vehicles,
		    ;; 1.2 otherwise.
		    (< <river-depth> 1.2)))
    )
   (and
    (~ (mined <old-loc>))
    (~ (mined <ford-near-approach>))
    (~ (mined <river>))
    (~ (in-use <asset>))
    ))
  (effects
   ()
   ((del (object-found-in-location <asset> <old-loc>))
    (add (object-found-in-location <asset> <destination>))
    (add (in-use <asset>))
   )))

(Operator MOVE-ASSET-ACROSS-GAP-BY-FORDING-IT
  (params <gap> <asset> <old-loc> <destination>)
  (preconds
   ((<gap> Geographical-gap)
    ;;(<ford> (and Geographical-gap (diff <gap> <ford>)))
    (<asset> engineering-equipment)
    (<destination> (and Geographical-approach
		    (either-approach <gap> <destination>)))
    (<old-loc> (and geographical-approach
                   (gfp (object-found-in-location <asset> <old-loc>))
	         (either-approach <gap> <old-loc>)
	         (diff <destination> <old-loc>)))
    (<river> (and body-of-water
	        (gfp (river-of <ford> <river>))
	        (dry-or-not-mined <river>)))
    (<river-current> (and number
		      ;;(gfp (river-current <river> <river-current>))
		      (gen-river-current <river> <river-current>)
		      (< <river-current> 1.5))) ; 1.5MPS
    (<river-depth> (and number
		    (gfp (water-depth <river> <river-depth>))
		    ;; see notes at move-asset-across-ford-different-from-gap
		    (< <river-depth> 1.2)))
    )
   (and
    (~ (mined <old-loc>))
    (~ (mined <river>))
    (~ (in-use <asset>))
    ))
  (effects
   ()
   ((del (object-found-in-location <asset> <old-loc>))
    (add (object-found-in-location <asset> <destination>))
    (add (in-use <asset>))
   )))
	
	

(Operator NARROW-GAP-WITH-BULLDOZER
 (params <bdz> <gap> <old-width> <new-width>)
 (preconds
  ((<bdz> military-dozer)
   (<cur-bdz-loc> (and place
		   (gfp (object-found-in-location <bdz> <cur-bdz-loc>))))
   (<gap> Geographical-Gap)
   (<approach> (and Geographical-approach
		(either-approach <gap> <approach>)
		(nothing-between <cur-bdz-loc> <approach>)))
   (<bank> (and Geographical-bank
	      (bank-near-approach <approach> <bank>)))
   (<bridge> Civilian-Bridge)		; only need this for Jihie
   (<old-width> (and Number
		 (gfp (width-of-object <gap> <old-width>))))
   (<new-width> (and Number
		 (< <new-width> <old-width>)
		 (more-than-two-thirds <new-width> <old-width>)))
   (<difference> (and Number (gen-from-difference <old-width> <new-width>
					<difference>)
		  ;; can't be more than 10 (6/22)
		  (<= <difference> 10)))
   ;; Don't do this if the missing-span-length is less than the gap-width.
   (<msl> (and number (gfp (missing-span-length <bridge> <msl>))
	     (>= <msl> <old-width>)))
   )
  (and
   (object-found-in-location <bdz> <approach>)
   (cross-section <bridge> <gap>)
   (~ (in-use <bdz>))
   ))
  (effects
   ()
   ((del (width-of-object <gap> <old-width>))
    (add (width-of-object <gap> <new-width>))
    ;; These postconditions might come back when we go for combined
    ;; narrowing and desloping.
    ;;(add (profile-of-gap <gap> <new-width> <new-bank-height>))
    ;;(add (desloped <gap> <bank> <new-bank-height> 25))
    (add (in-use <bdz>))
    ;; This is so we don't narrow the gap and then do "minor prep"
    (del (has-rubble <bank>))
    (add (minor-prep <bank>))
    )))

(Operator NARROW-GAP-BY-CUTTING-DOWN-BANK
 (params <bdz> <gap> <new-width>)
 (preconds
  ((<bdz> military-dozer)
   (<gap> Geographical-Gap)
   (<old-width> (and Number
		 (gfp (width-of-object <gap> <old-width>))))
   (<target-bridge> (and avlb-bridge	; should probably allow tmm as well
		     (walk-up-trace-to-find-bridge <target-bridge>)))
   (<river> (and body-of-water (gfp (river-of <gap> <river>))))
   (<river-width> (and Number (gfp (width-of-object <river> <river-width>))))
   (<new-width> (and Number
		 ;; so can't subgoal on has-rubble or minor-prep
		 (bound-from-goal <new-width>) 
		 (< <new-width> <old-width>)
		 (< <river-width> <new-width>)))
   (<cur-bdz-loc> (and Place (gfp (object-found-in-location
			     <bdz> <cur-bdz-loc>))))
   (<near-approach> (and Geographical-approach
		     (either-approach <gap> <near-approach>)
		     (nothing-between <cur-bdz-loc> <near-approach>)))
   ;; these are for Jihie
   (<near-bank> (and Geographical-bank
		 (bank-near-approach <near-approach> <near-bank>)))
   (<far-approach> (and Geographical-approach
		    (either-approach <gap> <far-approach>)
		    (diff <near-approach> <far-approach>)))
   (<far-bank> (and Geographical-bank
		(bank-near-approach <far-approach> <far-bank>)))
   )
  (and
   (object-found-in-location <bdz> <near-approach>)
   (~ (in-use <bdz>))
   ))
 (effects
  ()
  ((del (width-of-object <gap> <old-width>))
   (add (width-of-object <gap> <new-width>))
   (add (in-use <bdz>))
   (del (has-rubble <near-bank>))
   (add (minor-prep <near-bank>)))))


;;; If the msl is less than gap width, ie we are crossing bridge damage,
;;; then assert that the gap width is as small as the missing bridge
;;; section. This is because the emplace operators think they have to
;;; narrow the gap but they don't in that case.
(Inference-Rule WIDTH-OK-FOR-BRIDGE-DAMAGE
 (params <gap> <gap-width> <civvy-bridge> <msl>)
 (preconds
  ((<gap> Geographical-gap)
   (<desired-width> Number)
   (<installed-bridge> (and military-fixed-bridge
		        (walk-up-trace-to-find-bridge <installed-bridge>)))
   (<gap-width> (and number
		 (gfp (width-of-object <gap> <gap-width>))))
   (<civvy-bridge> (and Civilian-bridge
		    (gfp (cross-section <civvy-bridge> <gap>))))
   (<msl> (and number (gfp (missing-span-length <civvy-bridge> <msl>))
	     (< <msl> <gap-width>)
	     (<= <msl> <desired-width>))))
  (and))
 (effects ()
	((add (width-of-object <gap> <desired-width>)))))

;;; The emplace operators will ask for a larger width when (for example)
;;; the MGB was built with a +2 margin.
(Inference-rule LARGER-WIDTH-OK
 (params <gap> <gap-width> <desired-width>)
 (preconds
  ((<gap> Geographical-gap)
   (<desired-width> Number)
   (<gap-width> (and number
		 (gfp (width-of-object <gap> <gap-width>))
		 (> <desired-width> <gap-width>))))
  (and))
 (effects ()
	((add (width-of-object <gap> <desired-width>)))
	))

;;; Rubble ==============================

(Operator DOZER-PLOW-RUBBLE
 (params <loc> <bdz> <a>)
 (preconds
  ((<loc> Geographical-Region)
   (<a> (and Geographical-approach
	   (near-approach <loc> <a>)))
   (<bdz> military-dozer)
   )
  (and
   (object-found-in-location <bdz> <a>)
   (~ (in-use <bdz>))
   ))
 (effects
  ()
  ((del (has-rubble <loc>))
   (add (minor-prep <loc>))
   (add (in-use <bdz>)))))

(Operator M88-PLOW-RUBBLE
 (params <loc> <m88>)
 (preconds
  ((<loc> Geographical-Region)
   (<a> (and Geographical-approach
	   (near-approach <loc> <a>)))
   (<m88> m88)
   )
  (and
   (object-found-in-location <m88> <a>)
   (~ (in-use <m88>))
   ))
 (effects
  ()
  ((del (has-rubble <loc>))
   (add (minor-prep <loc>))
   (add (in-use <m88>)))))


(Operator TANK-PLOW-RUBBLE
 (params <loc> <tank-plow>)
 (preconds
  ((<loc> Geographical-Region)
   (<a> (and Geographical-approach
	   (near-approach <loc> <a>)))
   (<tank-plow> tank-plow)
   )
  (and
   (object-found-in-location <tank-plow> <a>)
   (mounted <tank-plow>)
   (~ (in-use <tank-plow>))
   ))
 (effects
  ()
  ((del (has-rubble <loc>))
   (add (minor-prep <loc>))
   (add (in-use <tank-plow>)))))


(Operator MOUNT-TANK-PLOW
 (params <tank-plow>)
 (preconds
  ((<tank-plow> tank-plow)
   )
  ( and
    (~ (in-use <tank-plow>))  
   ))
 (effects
  ()
  ((add (mounted <tank-plow>))
   (add (in-use <tank-plow>))
   )))


;;; Bridges ==============================


(inference-rule WIDTH-IS-SMALLER-OR-EQUAL
  (params <region> <threshold>)
  (preconds
   ((<region> Geographical-Region)
    (<width> (and Number (gfp (width-of-object <region> <width>))))
    (<threshold> (and Number (<= <width> <threshold>))))
   (and))
  (effects ()
	 ((add (smaller-or-equal-width <region> <threshold>)))))

;;; This inference rule chooses to try to make the width equal to the
;;; threshold if it is currently too wide. May lose completenes if
;;; a point below the threshold should really be chosen.
(inference-rule MAKE-WIDTH-SMALLER-OR-EQUAL
  (params <region> <threshold>)
  (preconds
   ((<region> Geographical-Region)
    (<width> (and Number (gfp (width-of-object <region> <width>))))
    ;; Only match rule when the width is greater.
    (<threshold> (and Number (> <width> <threshold>))))
   (width-of-object <region> <threshold>))
  (effects () ((add (smaller-or-equal-width <region> <threshold>)))))


(Operator MOVE-ACROSS-GAP-WITH-FIXED-BRIDGE
 (params <gap> <bridge> <unit>)
 (preconds
  ((<bridge> (or civilian-bridge military-fixed-bridge))
   (<gap> geographical-gap)
   (<unit> military-unit)
   (<left-bank> (and geographical-bank
                     (gfp (left-bank <gap> <left-bank>))))
   (<right-bank> (and geographical-bank
		  (gfp (right-bank <gap> <right-bank>))))
   (<left-approach> (and geographical-approach
		     (gfp (left-approach <gap> <left-approach>))))
   (<right-approach> (and geographical-approach
		      (gfp (right-approach <gap> <right-approach>)))))
  (and
   (trafficable <bridge> <gap> <unit>)
   (~ (mined <left-approach>))
   (~ (mined <right-approach>))
   (~ (has-rubble <left-bank>))
   (~ (has-rubble <right-bank>))
   ))
 (effects ()
	((add (crossable <gap> <bridge> <unit>))
	 ;; This more general postcondition is the top-level goal
	 (add (crossable <gap> <unit>))
	 )))

(Operator MOVE-ACROSS-GAP-WITH-FLOATING-BRIDGE
 (params <gap> <bridge> <unit>)
 (preconds
  ((<bridge> floating-bridge)
   (<gap> geographical-gap)
   (<unit> military-unit)
   (<left-bank> (and geographical-bank
                     (gfp (left-bank <gap> <left-bank>))))
   (<right-bank> (and geographical-bank
		  (gfp (right-bank <gap> <right-bank>))))
   (<left-approach> (and geographical-approach
		     (gfp (left-approach <gap> <left-approach>))))
   (<right-approach> (and geographical-approach
		      (gfp (right-approach <gap> <right-approach>)))))
  (and
   (trafficable <bridge> <gap> <unit>)
   (~ (mined <left-approach>))
   (~ (mined <right-approach>))
   (minor-prep <left-bank>)
   (minor-prep <right-bank>)))
 (effects ()
	((add (crossable <gap> <bridge> <unit>))
	 ;; This more general postcondition is the top-level goal
	 (add (crossable <gap> <unit>))
	 )))

;;; This does the same as both FLOATING-BRIDGE-TRAFFICABLE and
;;; MOVE-ACROSS-GAP-WITH-FLOATING-BRIDGE
(Inference-rule RAFT-TRAFFICABLE
 (params <raft> <gap> <unit>)
 (preconds
  ((<raft> floating-bridge)
   (<max-bank-height> (and Number
		       (gfp (max-bank-height <raft> <max-bank-height>))))
   (<max-current> (and Number
		   (gfp (max-current <raft> <max-current>))))
   (<min-water-depth> (and Number
		       (gfp (min-water-depth <raft> <min-water-depth>))))
   (<gap> geographical-gap)
   (<river> (and body-of-water
	       (gfp (river-of <gap> <river>))
	       (not-mined <river>)))
   (<water-width> (and Number (gfp (width-of-object <river> <water-width>))
		   (>= <water-width> 50)))
   (<river-current> (and Number (gfp (river-current <river> <river-current>))
		     (<= <river-current> <max-current>)))
   (<river-depth> (and Number (gfp (water-depth <river> <river-depth>))
		   (>= <river-depth> <min-water-depth>)))
   (<left-bank> (and geographical-bank
		 (gfp (left-bank <gap> <left-bank>))))
   (<right-bank> (and geographical-bank
		 (gfp (right-bank <gap> <right-bank>))))
   (<unit> military-unit)
   )
  (and
   (assembled-raft <raft> <gap> <unit>)
   ;; turning these off for now - can't get to the opposite bank
   ;; - should I allow to raft across the bank?
   (desloped <gap> <left-bank> <max-bank-height> <max-bank-height> 25)
   (desloped <gap> <right-bank> <max-bank-height> <max-bank-height> 25)
   )
  )
 (effects
  ()
  ((add (crossable <gap> <raft> <unit>))
   (add (crossable <gap> <unit>))
   )))

(Inference-Rule CIVILIAN-BRIDGE-TRAFFICABLE
 (params <bridge> <gap> <unit>)
 (preconds
  ((<gap> geographical-gap)
   (<unit> military-unit)
   (<bridge> (and civilian-bridge
                  (gfp (cross-section <bridge> <gap>))
	        ;; this ensures it is the original civilian bridge
                  ))
   )
  (and
   #|(or (~ (exists ((<msl> (and Number
                                 (gfp (missing-span-length <bridge> <msl>)))))
	        (missing-span-length <bridge> <msl>)))
       (missing-span-length <bridge> 0))|#
   ;; this predicate is always asserted in the input by my translation function
   (missing-span-length <bridge> 0)
   (~ (mined <bridge>))
   ))
 (effects
  ()
  ((add (trafficable <bridge> <gap> <unit>))
   ;; add this so we can move assets across to derubble etc
   (add (emplaced <bridge> <gap>))
   )))


(Inference-Rule FLOATING-BRIDGE-TRAFFICABLE-OVER-ENTIRE-GAP
 (params <bridge> <gap> <unit>)
 (preconds
  ((<bridge> floating-bridge)
   (<max-bank-height> (and Number
		       (gfp (max-bank-height <bridge> <max-bank-height>))))
   (<max-current> (and Number
		   (gfp (max-current <bridge> <max-current>))))
   (<min-water-depth> (and Number
		       (gfp (min-water-depth <bridge> <min-water-depth>))))
   (<gap> geographical-gap)
   (<gap-width> (and number
                     (gfp (width-of-object <gap> <gap-width>))
		 ;;(>= <gap-width> 50) see water width
		 ))
   (<river> (and body-of-water
	       (gfp (river-of <gap> <river>))
	       (not-mined <river>)))	; need to add this
   (<water-width> (and Number (gfp (width-of-object <river> <water-width>))
		   (>= <water-width> 50)))
   (<river-current> (and Number (gfp (river-current <river> <river-current>))
		     (<= <river-current> <max-current>)))
   (<river-depth> (and Number (gfp (water-depth <river> <river-depth>))
		   (>= <river-depth> <min-water-depth>)))
   (<left-bank> (and geographical-bank
		 (gfp (left-bank <gap> <left-bank>))))
   (<right-bank> (and geographical-bank
		 (gfp (right-bank <gap> <right-bank>))))
   (<max-bridge-length>
    (and Number
         ;;(gfp (max-length <bridge> <max-bridge-length>))
         (gen-max-floating-bridge-length <bridge> <max-bridge-length>)
         (>= <max-bridge-length> <water-width>)))
   (<unit> military-unit)
   )
  (and
   (emplaced <bridge> <gap> <water-width> <unit>)	; used to be <gap-width>
   (desloped <gap> <left-bank> <max-bank-height> <max-bank-height> 25)
   (desloped <gap> <right-bank> <max-bank-height> <max-bank-height> 25)
   )
  )
 (effects
  ()
  ((add (trafficable <bridge> <gap> <unit>))
   )))

(Inference-Rule FLOATING-BRIDGE-TRAFFICABLE-OVER-LITTLE-BIT-OF-GAP
 (params <bridge> <gap> <unit>)
 (preconds
  ((<bridge> floating-bridge)
   (<max-bank-height> (and Number
		       (gfp (max-bank-height <bridge> <max-bank-height>))))
   (<max-current> (and Number
		   (gfp (max-current <bridge> <max-current>))))
   (<min-water-depth> (and Number
		       (gfp (min-water-depth <bridge> <min-water-depth>))))
   (<gap> geographical-gap)
   (<gap-width> (and number
                     (gfp (width-of-object <gap> <gap-width>))
		 ;;(>= <gap-width> 50) see water width
		 ))
   (<river> (and body-of-water
	       (gfp (river-of <gap> <river>))
	       (not-mined <river>)))
   (<water-width> (and Number (gfp (width-of-object <river> <water-width>))
		   (>= <water-width> 50)))
   (<river-current> (and Number (gfp (river-current <river> <river-current>))
		     (<= <river-current> <max-current>)))
   (<river-depth> (and Number (gfp (water-depth <river> <river-depth>))
		   (>= <river-depth> <min-water-depth>)))
   (<left-bank> (and geographical-bank
		 (gfp (left-bank <gap> <left-bank>))))
   (<right-bank> (and geographical-bank
		 (gfp (right-bank <gap> <right-bank>))))
   (<max-bridge-length>
    (and Number (gfp (max-length <bridge> <max-bridge-length>))
         (< <max-bridge-length> <water-width>)))
   (<unit> military-unit)
   )
  (and
   ;; This precondition might come back when we go for combined
   ;; narrowing and desloping.
   ;;(profile-of-gap <gap> <max-bridge-length> <max-bank-height>)
   (width-of-object <gap> <max-bridge-length>)
   (desloped <gap> <left-bank> <max-bank-height> <max-bank-height> 25)
   (desloped <gap> <right-bank> <max-bank-height> <max-bank-height> 25)
   (emplaced <bridge> <gap> <max-bridge-length> <unit>)
   )
  )
 (effects
  ()
  ((add (trafficable <bridge> <gap> <unit>))
   )))


(operator DESLOPE-BANK
  (params <gap> <bank> <max-bank-height> <max-slope> <bdz>)
  (preconds
   ((<gap> Geographical-gap)
    (<bdz> Military-dozer)	; don't really want to backtrack on this
    (<bank> Geographical-bank)
    (<bank-height> (and number (gfp (height-of-object <bank> <bank-height>))))
    (<water-depth> (and number (gfp (water-depth <bank> <water-depth>))))
    (<soil> (and soil-type
	       (gfp (soil-of <bank> <soil>))
	       (not-rock <soil>)))	; check it's not rock.
    (<near-approach> (and Geographical-approach
		      (near-approach <bank> <near-approach>)))
    (<above-water-height> Number)
    (<max-bank-height> Number)
    (<max-slope> Number)
    (<bank-slope> (and Number
		   (gfp (max-slope <bank> <bank-slope>))
		   ;;(> <bank-slope> <max-slope>)
		   ))
    (<actual-deslope-height>
     (and Number (gen-from-difference <bank-height> <water-depth>
			        <actual-deslope-height>)
	;;(> <actual-deslope-height> <max-bank-height>)
	;; Needs to be disjunction of the two commented tests, not
	;; conjunction.
	(need-to-deslope <actual-deslope-height> <max-bank-height>
		       <bank-slope> <max-slope>)
	))
    )
   (and
    (object-found-in-location <bdz> <near-approach>)
    (~ (in-use <bdz>))
    )
   )
  (effects ()
	 ((add (desloped <gap> <bank> <above-water-height>
		       <max-bank-height> <max-slope>))
	  (add (desloped <gap> <near-approach>))
	  (add (in-use <bdz>)))))


;;; An inference rule that asserts desloped if the slope is already flat
;;; enough.
(Inference-rule BANK-SLOPE-OK
  (params <gap> <bank> <max-bank-height> <max-slope>)
  (preconds
   ((<gap> Geographical-gap)
    (<bank> Geographical-bank)
    (<near-approach> (and Geographical-approach
		      (near-approach <bank> <near-approach>)))
    (<bank-height> (and number (gfp (height-of-object <bank> <bank-height>))))
    (<water-depth> (and number (gfp (water-depth <bank> <water-depth>))))
    (<max-bank-height> (and Number (bound-from-goal <max-bank-height>)))
    (<actual-deslope-height>
     (and number
	(gen-from-difference <bank-height> <water-depth>
			 <actual-deslope-height>)
	(>= <max-bank-height> <actual-deslope-height>)))
    (<above-water-height> Number)
    (<max-slope> Number)
    (<bank-slope> (and Number
		   (gfp (max-slope <bank> <bank-slope>))
		   (<= <bank-slope> <max-slope>))))
   (and))
  (effects ()
   ((add (desloped <gap> <bank> <above-water-height>
	         <max-bank-height> <max-slope>))
    (add (desloped <gap> <near-approach>)))))


;;; Here we deal with narrowing the gap, or cutting it down if the
;;; river-width is small. If the gap is part of a damaged bridge we
;;; don't have that option.
(Inference-Rule FIXED-BRIDGE-TRAFFICABLE-OVER-A-VERY-SMALL-GAP
 (params <bridge> <gap> <unit>)
 (preconds
  ((<bridge> military-fixed-bridge)
   (<unit> military-unit)
   (<required-traffic-class> (and Number
			    (gfp (max-load-class-in-military-unit <unit> <required-traffic-class>))))
   (<max-bridge-length>
    (and number
         (gen-max-bridge-length <bridge> <required-traffic-class> <max-bridge-length>)))
   (<gap> geographical-gap)
   (<gap-width> (and number
                     (gfp (width-of-object <gap> <gap-width>))
		 (< <max-bridge-length> <gap-width>)
		 (m4t6-less-width <gap-width> <bridge> 26)
		 (avlb-or-tmm-ok-to-bridge <gap> <gap-width> <bridge>)
		 ))
   (<original-bridge> (and civilian-bridge
		       (gfp (cross-section <original-bridge> <gap>))))
   ;; Must have a completely missing bridge to do this..
   (<msl> (and Number (gfp (missing-span-length <original-bridge> <msl>))
	     (= <msl> <gap-width>)))
   )
  (and (emplaced <bridge> <gap> <max-bridge-length> <unit>)
       ;; This is now a precondition of emplace
       ;;(width-of-object <gap> <max-bridge-length>)
       ))
 (effects
  ()
  ((add (trafficable <bridge> <gap> <unit>))
   )))

(Inference-Rule FIXED-BRIDGE-TRAFFICABLE-OVER-ENTIRE-GAP
 (params <bridge> <gap> <unit>)
 (preconds
  ((<bridge> military-fixed-bridge)
   (<unit> military-unit)
   (<required-traffic-class> (and Number
			    (gfp (max-load-class-in-military-unit <unit> <required-traffic-class>))))
   (<max-bridge-length>
    (and number
         (gen-max-bridge-length <bridge> <required-traffic-class> <max-bridge-length>)))
   (<gap> geographical-gap)
   (<gap-width> (and number
                     (gfp (width-of-object <gap> <gap-width>))
		 ))
   (<desired-length> (and number
		      (gen-desired-length <bridge> <gap-width>
				      <desired-length>)
		      (>= <max-bridge-length> <desired-length>)))
   (<original-bridge> (and civilian-bridge
		       (gfp (cross-section <original-bridge> <gap>))))
   (<msl> (and Number (gfp (missing-span-length <original-bridge> <msl>))
	     (> <msl> 0)))
   )
  (and (emplaced <bridge> <gap> <desired-length> <unit>)
       ))
 (effects
  ()
  ((add (trafficable <bridge> <gap> <unit>))
   )))

(Inference-Rule FIXED-BRIDGE-TRAFFICABLE-OVER-BRIDGE-DAMAGE
 (params <bridge> <gap> <unit>)
 (preconds
  ((<bridge> military-fixed-bridge)
   (<gap> geographical-gap)
   (<gap-width> (and number
		 (gfp (width-of-object <gap> <gap-width>))))
   (<original-bridge> (and civilian-bridge
		       (gfp (cross-section <original-bridge> <gap>))))
   (<required-traffic-class> (and Number
			    (gfp (max-load-class-in-military-unit <unit> <required-traffic-class>))))
   (<max-bridge-length>
    (and number
         (gen-max-bridge-length <bridge> <required-traffic-class> <max-bridge-length>)))
   (<msl> (and Number (gfp (missing-span-length <original-bridge> <msl>))
	     (> <msl> 0)
	     (< <msl> <gap-width>)))
   (<desired-length> (and Number
		      (gen-desired-length <bridge> <msl> <desired-length>)
		      (>= <max-bridge-length> <desired-length>)))
   (<unit> military-unit)
   )
  (and
   (emplaced <bridge> <gap> <desired-length> <unit>)
   (~ (mined <original-bridge>))
   ))
 (effects
  ()
  ((add (trafficable <bridge> <gap> <unit>))
   )))


;;; emplacing bridges ======================================

(Operator EMPLACE-TEMPORARY-BRIDGE-MGB
 (params <bridge> <gap> <unit>)
 (preconds
  ((<bridge> mgb)
   (<gap> geographical-gap)
   (<length> number)
   (<desired-width> (and Number
		     (gen-from-difference <length> 2 <desired-width>)))
   (<unit> military-unit)
   )
  (and
   (assembled <bridge> <gap> <length> <unit>)
   (width-of-object <gap> <desired-width>)
   ))
 (effects
  ()
  ((add (emplaced <bridge> <gap> <length> <unit>))
   (add (emplaced <bridge> <gap>))
   )))

(Operator EMPLACE-TEMPORARY-BRIDGE-BAILEY
 (params <bridge> <gap> <unit>)
 (preconds
  ((<bridge> bailey-bridge)
   (<gap> geographical-gap)
   (<length> number)
   (<desired-width> (and Number
		     (gen-from-difference <length> 4 ; 12 feet
				      <desired-width>)))
   (<unit> military-unit)
   )
  (and
   (width-of-object <gap> <desired-width>)
   (assembled <bridge> <gap> <length> <unit>)
   ))
 (effects
  ()
  ((add (emplaced <bridge> <gap> <length> <unit>))
   (add (emplaced <bridge> <gap>))
   )))

;;;   - needs to check bank height >1
(Operator EMPLACE-TEMPORARY-BRIDGE-AVLB-OR-TMM
 (params <bridge> <gap> <unit>)
 (preconds
  ((<bridge> (or avlb-bridge tmm-bridge))
   (<cur-bridge-loc>
    (and place (gfp (object-found-in-location <bridge> <cur-bridge-loc>))))
   (<gap> geographical-gap)
   (<near-approach> (and geographical-approach
		     (either-approach <gap> <near-approach>)
		     (nothing-between <cur-bridge-loc> <near-approach>)
		     ))
   (<far-approach> (and geographical-approach
		    (either-approach <gap> <far-approach>)
		    (diff <far-approach> <near-approach>)))
   (<length> number)
   (<unit> military-unit)
   (<required-traffic-class>
    (and number (gfp (max-load-class-in-military-unit <unit> <required-traffic-class>))))
   (<max-traffic-class-for-bridge>
    (and number
         (gfp (max-traffic-class <bridge> <max-traffic-class-for-bridge>))
         (< <required-traffic-class> <max-traffic-class-for-bridge>)))
   (<max-length-for-bridge>
    (and number (gfp (max-length <bridge> <max-length-for-bridge>))
         (<= <length> <max-length-for-bridge>)))
   )
  (and
   (width-of-object <gap> <length>)
   (object-found-in-location <bridge> <near-approach>)
   (~ (mined <near-approach>))
   ;; see inference rules in demining section
   (sort-of-demined-inf <far-approach>)	
   ))
 (effects
  ()
  ((add (emplaced <bridge> <gap> <length> <unit>))
   (add (emplaced <bridge> <gap>))
   )))

(Operator EMPLACE-TEMPORARY-BRIDGE-M4T6-FIXED
 (params <bridge> <gap> <unit>)
 (preconds
  ((<bridge> m4t6-fixed-bridge)
   (<cur-bridge-loc>
    (and place (gfp (object-found-in-location <bridge> <cur-bridge-loc>))))
   (<gap> geographical-gap)
   ;; I assume the beb and the bridge must be brough to the same side of
   ;; the river
   (<approach> (and geographical-approach
		(either-approach <gap> <approach>)
		(nothing-between <cur-bridge-loc> <approach>)))
   (<length> number)
   (<unit> military-unit)
   (<max-length-for-bridge>
    (and number (gfp (max-length <bridge> <max-length-for-bridge>))
         (<= <length> <max-length-for-bridge>)))
   )
  ;; no demining, because if anything is mined the river is mined, and
  ;; then we can't use a floating bridge.
  (and
   (width-of-object <gap> <length>)
   (object-found-in-location <bridge> <approach>)
   ))
 (effects
  ()
  ((add (emplaced <bridge> <gap> <length> <unit>))
   (add (emplaced <bridge> <gap>))
   )))

;;; Need to check we have enough bays to build a required length of bridge?
(Operator EMPLACE-TEMPORARY-BRIDGE-RIBBON
 (params <bridge> <gap> <unit> <length>)
 (preconds
  ((<bridge> ribbon-bridge)
   (<cur-bridge-loc>
    (and place (gfp (object-found-in-location <bridge> <cur-bridge-loc>))))
   (<ramp> ribbon-bridge-ramp)
   (<cur-ramp-loc>
    (and place (gfp (object-found-in-location <bridge> <cur-ramp-loc>))))
   (<gap> geographical-gap)
   (<river> (and body-of-water (gfp (river-of <gap> <river>))))
   (<river-current> (and Number (gfp (river-current <river> <river-current>))))
   ;; I assume the ramp and the bridge must be brought to the same side
   ;; of the river.
   (<approach> (and geographical-approach
		(either-approach <gap> <approach>)
		(nothing-between <cur-bridge-loc> <approach>)
		(nothing-between <cur-ramp-loc> <approach>)))
   (<unit> military-unit)
   (<length> number)
   (<required-traffic-class>
    (and number (gfp (max-load-class-in-military-unit <unit> <required-traffic-class>))))
   (<max-traffic-class-for-bridge>
    (and number
         (gen-traffic-class-ribbon <bridge> <river-current>
			         <max-traffic-class-for-bridge>)
         (<= <required-traffic-class> <max-traffic-class-for-bridge>)))
   )
  (and
   (width-of-object <river> <length>)	
   ;; width used to be for gap - I don't know if we can narrow the river..
   (object-found-in-location <bridge> <approach>)
   (object-found-in-location <ramp> <approach>)
   ))
 (effects
  ()
  ((add (emplaced <bridge> <gap> <length> <unit>))
   (add (emplaced <bridge> <gap>))
   ))
 )

(Operator EMPLACE-TEMPORARY-BRIDGE-M4T6
 (params <bridge> <gap> <unit> <length>)
 (preconds
  ((<bridge> m4t6)
   (<cur-bridge-loc>
    (and place (gfp (object-found-in-location <bridge> <cur-bridge-loc>))))
   (<gap> geographical-gap)
   (<river> (and body-of-water (gfp (river-of <gap> <river>))))
   (<river-current> (and Number (gfp (river-current <river> <river-current>))))
   (<approach> (and geographical-approach
		(either-approach <gap> <approach>)
		(nothing-between <cur-bridge-loc> <approach>)))
   (<bank> (and geographical-bank
	      ;; we assume both banks have same height
                (gfp (left-bank <gap> <bank>))))
   (<bank-height> (and number
                       (gfp (height-of-object <bank> <bank-height>))))
   (<unit> military-unit)
   (<length> number)
   (<required-traffic-class>
    (and number (gfp (max-load-class-in-military-unit <unit> <required-traffic-class>))))
   (<max-traffic-class-for-bridge>
    (and number
         (gen-traffic-class-m4t6 <gap> <river-current>
			   <max-traffic-class-for-bridge>)
         (<= <required-traffic-class> <max-traffic-class-for-bridge>)))
   )
  (and
   (width-of-object <river> <length>)	; see for ribbon bridge above.
   (object-found-in-location <bridge> <approach>)
   ))
 (effects
  ()
  ((add (emplaced <bridge> <gap> <length> <unit>))
   (add (emplaced <bridge> <gap>))
   ))
 )


;;; Assemble MGB's and Baileys
;;; TO IGNORE: Add slope check - slope less than 5%
(Operator ASSEMBLE-MGB
  (params <bridge> <gap> <unit> <num-storeys> <num-bays> <length>)
  (preconds
   ((<bridge> mgb)
    (<cur-bridge-loc>
     (and place (gfp (object-found-in-location <bridge> <cur-bridge-loc>))))
    (<num-storeys> (and Number (gen-storeys-mgb <num-storeys>)))
    (<gap> geographical-gap)
    (<gap-width> (and number (gfp (width-of-object <gap> <gap-width>))))
    (<near-approach> (and Geographical-approach
		      (either-approach <gap> <near-approach>)
		      (nothing-between <cur-bridge-loc> <near-approach>)
		      ))
    (<far-approach> (and Geographical-approach
		     (either-approach <gap> <far-approach>)
		     (diff <far-approach> <near-approach>)))
    (<length> number)
    (<unit> military-unit)
    (<required-traffic-class>
     (and number (gfp (max-load-class-in-military-unit <unit> <required-traffic-class>))))
    (<num-bays> (and Number (compute-mgb-bays <num-storeys> <length>
				      <required-traffic-class>
				      <num-bays>)))
    )
   (and
    (object-found-in-location <bridge> <near-approach>)
    (~ (mined <near-approach>))
    ;; see inference rules in demining section
    (sort-of-demined-inf <far-approach>)
    ))
  (effects () ((add (assembled <bridge> <gap> <length> <unit>)))))

(Operator ASSEMBLE-BAILEY
  (params <bridge>)
  (preconds
   ((<bridge> bailey-bridge)
    (<cur-bridge-loc>
     (and place (gfp (object-found-in-location <bridge> <cur-bridge-loc>))))
    (<gap> geographical-gap)
    (<length> number)
    (<unit> Military-unit)
    (<gap-width> (and number (gfp (width-of-object <gap> <gap-width>))))
    (<near-approach> (and Geographical-approach
		      (either-approach <gap> <near-approach>)
		      (nothing-between <cur-bridge-loc> <near-approach>)
		      ))
    (<far-approach> (and Geographical-approach
		     (either-approach <gap> <far-approach>)
		     (diff <far-approach> <near-approach>)))
    (<required-traffic-class>
     (and number (gfp (max-load-class-in-military-unit <unit> <required-traffic-class>))))
    ;; I was expecting a symbolic type - but we don't use this anyway.
    (<construction-type>
     (and Number;;bailey-type
	(compute-bailey-type <length> <required-traffic-class>
			 <construction-type>)))
    )
   (and
    (object-found-in-location <bridge> <near-approach>)
    (~ (mined <near-approach>))
    ;; see inference rules in demining section
    (sort-of-demined-inf <far-approach>)
    ))
  (effects ()
	 ((add (assembled <bridge> <gap> <length> <unit>)))))

(operator assemble-raft
 (params <raft> <gap> <unit>)
 (preconds
  ((<raft> floating-bridge)
   (<gap> Geographical-gap)
   (<unit> military-unit)
   (<cur-raft-loc> (and place (gfp (object-found-in-location
			      <raft> <cur-raft-loc>))))
   (<near-approach> (and Geographical-approach
		     (either-approach <gap> <near-approach>)
		     (nothing-between <cur-raft-loc> <near-approach>)))
   ;; All this is done so I can pass a num-bays argument on.
   (<river> (and body-of-water
	       (gfp (river-of <gap> <river>))))
   (<river-current> (and Number
		     (gfp (river-current <river> <river-current>))))
   (<load-class> (and Number
		  (gfp (max-load-class-in-military-unit
		        <unit> <load-class>))))
   (<num-bays> (and Number
		(gen-raft-bays <raft> <river-current> <load-class>
			     <num-bays>))))
  (and
   (object-found-in-location <raft> <near-approach>)
   ))
 (effects ()
	((add (assembled-raft <raft> <gap> <unit>)))
	))


;;; fording ============================

(operator FORD
 (params <gap> <ford> <unit>)
 (preconds
  ((<unit> military-unit)
   (<gap> geographical-gap)
   (<ford> geographical-gap) ;; check inputs
   (<river> (and body-of-water
	       (gfp (river-of <ford> <river>))
	       (dry-or-not-mined <river>)))
    )
   (and
    (trafficable <ford> <unit>)
    ;;(~ (mined <left-bank>))
    ;;(~ (mined <right-bank>))
    ;;(~ (mined <left-approach>))
    ;;(~ (mined <right-approach>))
    ))
 (effects
   ()
   ((add (crossable <gap> <ford> <unit>))
    (add (crossable <gap> <unit>))
    )))

;;; NOTE: if ford site is mined, there is no way to demine it.  Can do it here
;;; or in all the demining operators.
;;; NOTE: For float bridges, if the gap is mined there is no way to demine it.

(inference-rule FORD-TRAFFICABLE
 (params <ford> <unit>)
 (preconds
  ((<unit> military-unit)
   (<ford> Geographical-gap)
   (<left-bank> (and geographical-bank
                     (gfp (left-bank <ford> <left-bank>))))
   (<right-bank> (and geographical-bank
		  (gfp (right-bank <ford> <right-bank>))))
   (<left-approach> (and geographical-approach
		     (gfp (left-approach <ford> <left-approach>))))
   (<right-approach> (and geographical-approach
		      (gfp (right-approach <ford> <right-approach>))))
   (<river> (and body-of-water
                 (gfp (river-of <ford> <river>))
	       (dry-or-not-mined <river>)))
   (<river-current> (and number
		     (gen-river-current <river> <river-current>)
		     ;; the function does the same as this.
		     #|
		     (or (gfp (river-current <river> <river-current>))
		         (list 0))|#
                        (< <river-current> 1.5))) ; 1.5MPS
   (<river-depth> (and number
                       (gfp (water-depth <river> <river-depth>))
		   ;; see notes at move-asset-across-ford-different-from-gap
                       (< <river-depth> 1.2)))
   ;; Need to check about this. Setting this field in the desloped goal
   ;; turns it off (not setting is to 0 as was previously done).
   (<cur-bank-height>
    (and Number (gfp (height-of-object <left-bank> <cur-bank-height>))))
   )
   (and
    (desloped <ford> <left-bank> 0 <cur-bank-height> 25)
    (desloped <ford> <right-bank> 0 <cur-bank-height> 25)
    (~ (mined <river>))
    ;;(~ (mined <left-bank>))
    ;;(~ (mined <right-bank>))
    ;;(~ (mined <left-approach>))
    ;;(~ (mined <right-approach>))
    ))
  (effects
   ()
   ((add (trafficable <ford> <unit>)))))


;;; Tunnels ===================================

(Operator MOVE-ACROSS-TUNNEL
 (params <tunnel> <unit>)
 (preconds
  ((<tunnel> TUNNEL)
   (<unit> military-unit)
   (<one-end> (and tunnel-opening
	         (gfp (part-of <tunnel> <one-end>))))
   (<other-end> (and tunnel-opening
		 (gfp (part-of <tunnel> <other-end>))
		 ;; I assume we want this - Jim
		 (diff <one-end> <other-end>)))
   (<one-approach> (and geographical-approach
		    (gfp (approach-of <tunnel> <one-approach>))))
   (<other-approach> (and geographical-approach
		      (gfp (approach-of <tunnel> <other-approach>))
		      (diff <one-approach> <other-approach>)))
   )
  (and
   ;; Just need to deal with rubble rather than these predicates.
   ;;(shored-up <tunnel> <one-end>)
   ;;(shored-up <tunnel> <other-end>)
   (~ (has-rubble <one-end>))
   (~ (has-rubble <other-end>))
   (~ (mined <one-end>))
   (~ (mined <other-end>))
   (~ (mined <one-approach>))
   (~ (mined <other-approach>))))
 (effects ()
	((add (crossable <tunnel> <unit>))
	 )))

(Operator DOZER-PLOW-TUNNEL-RUBBLE-AND-SHORE-ROOF
 (params <tunnel> <end> <bdz>)
 (preconds
  ((<tunnel> TUNNEL)
   (<end> tunnel-opening)
   (<approach> (and geographical-approach
		;; this is added by the translator
		(gfp (approach-of <end> <approach>))))
   (<bdz> military-dozer)
   (<loader> military-loader)
   (<rubble> (and rubble (gen-rubble <end> <rubble>)))
		  
   )
  (and
   (~ (mined <approach>))
   (~ (mined <end>))
   (object-found-in-location <bdz> <approach>)
   (object-found-in-location <loader> <approach>)
   (~ (in-use <bdz>))
   ))
 (effects ()
  ((add (shored-up <tunnel> <end>))
   (del (has-rubble <end>))
   (add (in-use <bdz>))
   )))

;;; Road segments and craters ============================
;;; (this section was added in the modification phase)


(Operator MOVE-ACROSS-ROAD-SEGMENT
 (params <road> <unit>)
 (preconds
  ((<road> road-segment)
   (<unit> military-unit))
  (forall ((<crater> (and Crater (gfp (in-region <crater> <road>)))))
	(crossable <crater> <unit>)))
 (effects ()
	((add (crossable <road> <unit>)))))


(Inference-Rule crossable-crater
 (params <crater> <unit>)
 (preconds
  ((<crater> crater)
   (<unit> military-unit)
   ;;(<bridge> (or avlb-bridge tmm-bridge))
   (<one-approach> (and geographical-approach
		    (either-approach <crater> <one-approach>)))
   (<other-approach> (and geographical-approach
		      (either-approach <crater> <other-approach>)
		      (diff <one-approach> <other-approach>))))
  (and
   (~ (mined <one-approach>))
   (~ (mined <other-approach>))
   (trafficable <crater> <unit>)))
 (effects ()
	((add (crossable <crater> <unit>))
	 )))

;;; demining preferences:
;;; - for crater approaches: prefer in this order:
;;;      miclic, bangalore followed by tank plow, tank plow, hasty breech

;;; In the absence of control rules, this operator gets preferred over
;;; cross-crater-by-filling-in because it comes above it in the file.
(Inference-Rule cross-crater-with-bridge
  (params <crater> <bridge> <unit>)
  (preconds
   ((<crater> crater)
    (<bridge> (or avlb-bridge tmm-bridge))
    (<unit> military-unit)
    (<crater-width> (and number
                         (gfp (width-of-object <crater> <crater-width>))))
    )
   (and
    ;; will not consider narrowing the crater because craters are 10m or
    ;; so in size
    (emplaced <bridge> <crater> <crater-width> <unit>)
    ))
  (effects ()
   ((add (trafficable <crater> <unit>))
    )))

(Operator EMPLACE-TEMPORARY-BRIDGE-AVLB-OR-TMM-OVER-CRATER
 (params <bridge> <crater> <unit>)
 (preconds
  ((<bridge> (or avlb-bridge tmm-bridge))
   (<unit> military-unit)
   (<crater> crater)
   (<col> (and equipment-collection
	     (gfp (group-members <col> <bridge>))))
   (<max-used> (and Number
		(gfp (group-cardinality <col> <max-used>))))
   (<old-amount> (and Number
		  (gfp (amount-used <col> <old-amount>))
		  (< <old-amount> <max-used>)))
   (<new-amount> (and Number (gen-from-sum <old-amount> 1 <new-amount>)))
   (<cur-bridge-loc>
    (and place (gfp (object-found-in-location <bridge> <cur-bridge-loc>))))
   (<near-approach> (and geographical-approach
		     (either-approach <crater> <near-approach>)
		     ;; no (between <crater> <bridge> <near>)
		     ;; this is currently not quite right.
		     ;;(crater-not-between <crater> <cur-bridge-loc> <near-approach>)
		     (approach-on-same-side-of-crater <crater> <cur-bridge-loc> <near-approach>)
		     ))
   (<far-approach> (and geographical-approach
		    (either-approach <crater> <far-approach>)
		    (diff <far-approach> <near-approach>)))
   (<length> number)
   (<required-traffic-class>
    (and number (gfp (max-load-class-in-military-unit
		  <unit> <required-traffic-class>))))
   (<max-traffic-class-for-bridge>
    (and number
         (gfp (max-traffic-class <bridge> <max-traffic-class-for-bridge>))
         (< <required-traffic-class> <max-traffic-class-for-bridge>)))
   (<max-length-for-bridge>
    (and number (gfp (max-length <bridge> <max-length-for-bridge>))
         (<= <length> <max-length-for-bridge>)))
   )
  (and
   ;; will not consider narrowing the crater because craters are 10m or
   ;; so in size
   (object-found-in-location <bridge> <near-approach>)
   (~ (mined <near-approach>))
   (~ (mined <crater>))
   ;; (sort-of-demined-inf <far-approach>)
   ;; I think we can demine properly for a crater - Jim
   (~ (mined <far-approach>))
   ))
 (effects
  ()
  ((add (emplaced <bridge> <crater> <length> <unit>))
   (add (emplaced <bridge> <crater>))
   ;; this implements the check that we don't use too many items from an
   ;; equipment collection.
   (del (amount-used <col> <old-amount>))
   (add (amount-used <col> <new-amount>))
   )))


(Inference-Rule cross-crater-by-filling-in
  (params <crater> <unit>)
  (preconds
   ((<crater> crater)
    (<unit> military-unit)
    )
   (and
    (filled <crater>)
    ))
  (effects ()
   ((add (trafficable <crater> <unit>))
    )))


(Operator fill-crater-with-tank-plow
  (params <crater> <asset>)
  (preconds
   ((<asset> tank-plow)
    (<crater> crater)
    (<cur-asset-loc> (and place (gfp (object-found-in-location
			        <asset> <cur-asset-loc>))))
    (<near-approach> (and geographical-approach
                          (either-approach <crater> <near-approach>)
		      (crater-not-between <crater> <cur-asset-loc>
				      <near-approach>)))
    (<far-approach> (and geographical-approach
                         (either-approach <crater> <far-approach>)
                         (diff <far-approach> <near-approach>)))
    )
   (and
    (object-found-in-location <asset> <near-approach>)
    (~ (mined <near-approach>))
    (~ (mined <crater>))
    (mounted <asset>)
    (~ (in-use <asset>))
    ))
  (effects ()
   ((add (in-use <asset>))
    (add (filled <crater>))
    (add (object-found-in-location <asset> <crater>))
    (del (object-found-in-location <asset> <near-approach>))
    (add (ready-to-move <asset> <crater> <far-approach>))
    ;; will move only when demined
    )))

(Operator fill-crater-with-dozer-or-m88
  (params <crater> <asset>)
  (preconds
   ((<asset> (or m88 military-dozer))
    (<crater> crater)
    (<cur-asset-loc> (and place (gfp (object-found-in-location
			        <asset> <cur-asset-loc>))))
    (<near-approach> (and geographical-approach
                          (either-approach <crater> <near-approach>)
		      (crater-not-between <crater> <cur-asset-loc>
				      <near-approach>)))
    (<far-approach> (and geographical-approach
                         (either-approach <crater> <far-approach>)
                         (diff <far-approach> <near-approach>)))
    )
   (and
    (object-found-in-location <asset> <near-approach>)
    (~ (mined <near-approach>))
    (~ (mined <crater>))
    (~ (in-use <asset>))
    ))
  (effects ()
   ((add (in-use <asset>))
    (add (filled <crater>))
    (add (object-found-in-location <asset> <crater>))
    (del (object-found-in-location <asset> <near-approach>))
    (add (ready-to-move <asset> <crater> <far-approach>))
    ;; will move only when demined
    )))

;;; as soon as the far approach is demined the asset moves there
(Inference-Rule MOVE-ASSET-WHEN-NOT-MINED
 (mode eager)
 (params <crater> <asset>)
 (preconds
  ((<crater> (and crater
	        (gfp (object-found-in-location <asset> <crater>))))
   (<asset> engineering-equipment)
   (<far-approach> geographical-approach))
  (and
   (object-found-in-location <asset> <crater>)
   (ready-to-move <asset> <crater> <far-approach>)
   (~ (mined <far-approach>))
   ))
 (effects
  ()
  ((add (object-found-in-location <asset> <far-approach>))
   (del (object-found-in-location <asset> <crater>))
   (del (ready-to-move <asset> <crater> <far-approach>))
   )))


;;; The picture is:
;;;     town0  crater1  approach1     approach2 crater2 approach3
;;;
;;; This operator moves an asset from approach1 to approach2
;;;
(Operator MOVE-TO-NEXT-CRATER
 (params <asset> <old-loc> <new-loc>)
 (preconds
  ((<asset> Engineering-equipment)         
   (<new-loc> Geographical-approach)
   (<new-crater> (and crater
		  (gfp (approach-of <new-crater> <new-loc>))
		  ))
   (<town> (and city
	      (gfp (between <new-loc> <town> <new-crater>))))
   (<old-crater> (and crater
		  (gfp (between <old-crater> <town> <new-crater>))
		  (same-craters-between <town> <old-crater>
				    <new-crater>)))
   (<old-loc> (and Geographical-approach
	         (gfp (approach-of <old-crater> <old-loc>))
	         (gfp (between <old-crater> <town> <old-loc>)))))
  (and
   (object-found-in-location <asset> <old-loc>)))
 (effects ()
	((del (object-found-in-location <asset> <old-loc>))
	 (add (object-found-in-location <asset> <new-loc>)))))




;;; Resource use and release =============================

;;; NOTE: the operators to move entire military units do not
;;;  have any in-use precs or effects, I don't think we need them -- yg
;;;
;;; NOTE: Emplacing and assembling bridges: we could add an in-use
;;;  precondition and effect to represent the use of the bridge
;;;  resource, but it doesn't seem necessary because given how the
;;;  domain is represented we will not have operators competing for
;;;  the bridge resource at the same time -- yg
;;;
;;; NOTE: For the demining operators, we'll assume that MICLICs,
;;;   bangalores, and explosives can be in use by several actions in parallel.


(Operator Release-asset
 (params <asset>)
 (preconds
  ((<asset> engineering-equipment))
  (and (in-use <asset>)))
 (effects () ((del (in-use <asset>)))))

;;; Mines =============================

(Operator IDENTIFY-AND-MARK-MINEFIELD
 (params <region> <minefield>)
 (preconds
  ((<region> (and geographical-region
	        (~ tunnel-opening)
	        (~ crater)
	        ))
   (<minefield> (and minefield
		 (gfp (in-region <minefield> <region>))))
   )
  (and
   ))
 (effects ()
  (
   (add (identified-and-marked <region> <minefield>))
   )))

(Inference-rule IDENTIFY-AND-MARK-TUNNEL-OPENING
 (params <end> <minefield>)
 (preconds
  ((<end> tunnel-opening)
   (<approach> (and geographical-approach
                    (nothing-between <end> <approach>)))
   (<minefield> (and minefield
                    (gfp (in-region <minefield> <end>))))
   )
  (~ (mined <approach>)) ; this makes sure that the approach is
                                           ; demined first
  )
  (effects ()
   (
    (add (identified-and-marked <end> <minefield>))
    )))

(Inference-rule IDENTIFY-AND-MARK-CRATER
 (params <crater> <minefield>)
 (preconds
  ((<crater> crater)
   (<approach> (and geographical-approach
		(either-approach <crater> <approach>)))
   (<minefield> (and minefield
                    (gfp (in-region <minefield> <crater>))))
   )
  (~ (mined <approach>)) ; this makes sure that the approach is
                                           ; demined first
  )
  (effects ()
   (
    (add (identified-and-marked <crater> <minefield>))
    )))

(Operator PREPARE-DEMINING-EQUIPMENT
 (params <demining-equipment> <minefield>)
 (preconds
  ((<demining-equipment> ENGINEERING-EQUIPMENT) ; was military-equipment
   (<minefield> minefield)
   (<region> (and :top-type
	        (gfp (in-region <minefield> <region>)))))
  (and
   (~ (in-use <demining-equipment>))
   ))
 (effects ()
	(
	 (add (prepared <demining-equipment> <minefield>))
	 (add (in-use <demining-equipment>))
	 )))

(Operator HASTY-BREACH-MINEFIELD-NOT-A-TUNNEL-END
 (params <region> <asset>)
 (preconds
  ((<asset> EXPLOSIVES)
   (<region> (and Geographical-region (not tunnel-opening)))
   (<minefield> (and minefield
		 (gfp (in-region <minefield> <region>))))
   (<near-approach> (and Geographical-approach
		     (near-approach <region> <near-approach>)))
   )
  (and
   ;; if region is not a tunnel opening then a prec is (prepared <asset>)
   (prepared <asset> <minefield>)
   (object-found-in-location <asset> <near-approach>)
   (identified-and-marked <region> <minefield>)
   ))
 (effects ()
  (
   (del (mined <region>))
   (del (in-region <minefield> <region>)) ; do we really need to delete this?
   (del (prepared <asset> <minefield>))
   )))

;;; For a crater, go to the near approach and make sure it's demined first.
(Operator HASTY-BREACH-MINEFIELD-CRATER
 (params <region> <asset>)
 (preconds
  ((<asset> EXPLOSIVES)
   (<region> crater)
   (<cur-asset-loc> (and place (gfp (object-found-in-location
			       <asset> <cur-asset-loc>))))
   (<minefield> (and minefield
		 (gfp (in-region <minefield> <region>))))
   (<near-approach> (and Geographical-approach
		     (either-approach <region> <near-approach>)
		     (nothing-between <cur-asset-loc> <near-approach>)))
   )
  (and
   (~ (mined <near-approach>))
   ;; if region is not a tunnel opening then a prec is (prepared <asset>)
   ;; I guess only if it's also not a crater
   ;;(prepared <asset> <minefield>)
   (object-found-in-location <asset> <near-approach>)
   (identified-and-marked <region> <minefield>)
   ))
 (effects ()
  (
   (del (mined <region>))
   (del (in-region <minefield> <region>)) ; do we really need to delete this?
   (del (prepared <asset> <minefield>))
   )))

(Operator HASTY-BREACH-MINEFIELD-TUNNEL-END
 (params <region> <asset>)
 (preconds
  ((<asset> EXPLOSIVES)
   (<region> tunnel-opening)
   (<minefield> (and minefield
		 (gfp (in-region <minefield> <region>))))
   (<near-approach> (and Geographical-approach
		     (near-approach <region> <near-approach>)))
   )
  (and
   (object-found-in-location <asset> <near-approach>)
   (identified-and-marked <region> <minefield>)
   ))
 (effects ()
  (
   (del (mined <region>))
   (del (in-region <minefield> <region>)) ; do we really need to delete this?
   (del (prepared <asset> <minefield>))
   )))

(Operator EMPLOY-MICLIC
 (params <region> <asset>)
 (preconds
  ((<asset> MICLIC)
   (<region> geographical-region)
   (<minefield> (and minefield
		 (gfp (in-region <minefield> <region>))))
   (<near-approach> (and geographical-approach
		     (near-approach <region> <near-approach>)))
   )
  (and
   (object-found-in-location <asset> <near-approach>)
   (prepared <asset> <minefield>)
   (identified-and-marked <region> <minefield>)
   ))
  (effects ()
   (
    (del (mined <region>))
    (del (in-region <minefield> <region>)) ; see above
    (del (prepared <asset> <minefield>))
    )))

(Operator TANK-PLOW-REGION
 (params <tank-plow> <region>)
 (preconds
  ((<tank-plow> tank-plow)
   (<region> geographical-region)
   (<minefield> (and minefield
                     (gfp (in-region <minefield> <region>))))
   (<near-approach> (and geographical-approach
		     (near-approach <region> <near-approach>)))
   )
  (and
   (object-found-in-location <tank-plow> <near-approach>)
   (mounted <tank-plow>)
   (prepared <tank-plow> <minefield>)
   (identified-and-marked <region> <minefield>)
   (~ (in-use <tank-plow>))
   ))
  (effects ()
   ((del (mined <region>))
    (del (in-region <minefield> <region>))
    (del (sort-of-demined <region>))
    (add (in-use <tank-plow>))
    )))


(Operator EMPLOY-BANGALORE-TORPEDO
 (params <region> <asset>)
 (preconds
  ((<asset> BANGALORE-TORPEDO)
   (<explosives> EXPLOSIVES)
   (<region> geographical-region)
   (<minefield> (and minefield
                     (gfp (in-region <minefield> <region>))))
   (<near-approach> (and geographical-approach
		     (near-approach <region> <near-approach>)))
   )
  (and
   (object-found-in-location <explosives> <near-approach>)
   (object-found-in-location <asset> <near-approach>)
   (prepared <asset> <minefield>)
   (identified-and-marked <region> <minefield>)
   ))
  (effects ()
   (
    (del (prepared <asset> <minefield>))
    (add (sort-of-demined <region>))
    )))

(Operator TANK-PLOW-BRIDGE
 (params <bridge> <tank-plow> <old-loc> <new-loc>)
 (preconds
  ((<tank-plow> tank-plow)
   (<bridge> civilian-bridge) ; bridges should NOT be regions, that way only this
                              ; operator will apply for bridges.
   (<minefield> (and minefield
		 (gfp (in-region <minefield> <bridge>))))
   (<gap> (and geographical-gap
	     (gfp (cross-section <bridge> <gap>))))
   (<old-loc> (and geographical-approach
                   (gfp (object-found-in-location <tank-plow> <old-loc>))
                   (either-approach <gap> <old-loc>)))
   (<new-loc> (and geographical-approach
                   (either-approach <gap> <new-loc>)
	         (diff <new-loc> <old-loc>)))
   )
  (and
   (mined <bridge>) ; so that this is only used if bridge is mined
   (mounted <tank-plow>)
   (prepared <tank-plow> <minefield>)
   (~ (mined <old-loc>))
   (~ (in-use <tank-plow>))
   ))
  (effects ()
   ((del (mined <bridge>))		; I deleted <minefield>
    (del (object-found-in-location <tank-plow> <old-loc>))
    (add (object-found-in-location <tank-plow> <new-loc>))
    (add (in-use <tank-plow>))
    )))

;;; These two inference rules give us control over how to choose between
;;; de-mining and partially-de-mining a far approach. Also, the partial
;;; order creator can't handle disjunctive preconditions although the
;;; planner can handle them fine.

(Inference-Rule NOT-MINED-MEANS-SORT-OF-DEMINED
 (params <region>)
 (preconds
  ((<region> (and Geographical-region
	        ;; constraint stops the planner from subgoaling on
	        ;; demined.
	        (not-mined <region>))))
  (and))
 (effects () ((add (sort-of-demined-inf <region>)))))

(Inference-Rule BANGALORE-SORT-OF-DEMINE
 (params <region>)
 (preconds
  ((<region> (and Geographical-region
	        (gfp (mined <region>)))))
  (sort-of-demined <region>))
 (effects () ((add (sort-of-demined-inf <region>)))))

(Operator MOVE-ASSET-ACROSS-GAP  ; One of the two magic moves
 (params <asset> <old-loc> <new-loc>)
 (preconds
  ((<asset> (or bangalore-torpedo explosives))
   ;; was (or geographical-gap crater) before MOVE-ASSET-AROUND-CRATER
   (<gap> geographical-gap) 
   (<old-loc> (and geographical-approach
	         ;; made a subgoal because you may need to plan to do this.
                   ;;(gfp (object-found-in-location <asset> <old-loc>))
                   (either-approach <gap> <old-loc>)))
   (<new-loc> (and geographical-approach
                   (either-approach <gap> <new-loc>)
	         (diff <new-loc> <old-loc>)))
   )
  (and
   (object-found-in-location <asset> <old-loc>)
   ))
  (effects ()
   ((del (object-found-in-location <asset> <old-loc>))
    (add (object-found-in-location <asset> <new-loc>))
    )))


(Operator MOVE-ASSET-AROUND-TUNNEL  ; One of the two magic moves
 (params <asset> <old-loc> <new-loc>)
 (preconds
  ((<asset> (or military-dozer military-loader tank-plow explosives))
   (<tunnel> tunnel)
   (<old-loc> (and geographical-approach
                   ;;(gfp (object-found-in-location <asset> <old-loc>))
                   (either-approach <tunnel> <old-loc>)))
   (<new-loc> (and geographical-approach
                   (either-approach <tunnel> <new-loc>)
                   (diff <new-loc> <old-loc>)))
   )
  (and
   (object-found-in-location <asset> <old-loc>)
   (~ (in-use <asset>))
   ))
  (effects ()
   ((del (object-found-in-location <asset> <old-loc>))
    (add (object-found-in-location <asset> <new-loc>))
    (add (in-use <asset>))
    )))

(Operator MOVE-ASSET-AROUND-CRATER
 (params <asset> <old-loc> <new-loc>)
 (preconds
  ((<asset> Engineering-equipment)
   (<new-loc> Geographical-approach)
   (<crater> (and Crater
	        (gfp (approach-of <crater> <new-loc>))))
   (<old-loc> (and Geographical-approach
	         (gfp (approach-of <crater> <old-loc>))
	         (diff <old-loc> <new-loc>))))
  (and
   (object-found-in-location <asset> <old-loc>)
   ;; not using in-use because there may be more than one
   ;; object in the collection.
   ))
 (effects ()
	((del (object-found-in-location <asset> <old-loc>))
	 (add (object-found-in-location <asset> <new-loc>))
	 )))

 

;


;;; forward-chaining inference rules ===================


;;; use an eager inference rule to add rubble if a bridge is damaged.
(Inference-Rule DAMAGED-BRIDGE-MEANS-RUBBLE
 (mode eager)
 (params <bridge>)
 (preconds
  ((<bridge> civilian-bridge)
   (<msl> (and Number (gfp (missing-span-length <bridge> <msl>))
	     (> <msl> 0)))
   (<gap> (and Geographical-gap (gfp (cross-section <bridge> <gap>))))
   (<left-bank> (and geographical-bank
                     (gfp (left-bank <gap> <left-bank>))))
   (<right-bank> (and geographical-bank
		  (gfp (right-bank <gap> <right-bank>)))))
  (and))
 (effects
  ()
  ((add (has-rubble <left-bank>))
   (add (has-rubble <right-bank>)))))

;;; =======================================
;;; Control rules
;;; =======================================

;;; TO DO:

;;; Add a control rule to prefer singles to doubles of MGBs
;;; - currently leaving this under control of *use-storeys*
;;;   since there may be a solution both ways if you can narrow the gap.

;;;============
;;; Control rules to allow all options to be examined
;;;============
;;; The metapredicates used here can be controlled from another program.

;;; Decide whether or not to ford
(control-rule TRY-FORDING
  (if (and (current-goal (crossable <gap> <unit>))
	 (preferred-method-is-ford)))
  (then select operator FORD))

(control-rule DONT-FORD-UNLESS-ASKED
  (if (and (current-goal (crossable <gap> <unit>))
	 (~ (preferred-method-is-ford))))
  (then reject operator FORD))

;;; Select the ford site
(control-rule SELECT-FORD-SITE
  (if (and (current-operator FORD)
	 (preferred-ford-site <site>)))
  (then select bindings ((<ford> . <site>))))

;;; Select the bridge type to use.
(control-rule SELECT-ON-FIXED-BRIDGE-TYPE
  (if (and (current-operator MOVE-ACROSS-GAP-WITH-FIXED-BRIDGE)
	 ;;(type-of-object-gen <cand-bridge> m4t6)
	 (preferred-bridge-type <cand-bridge>)))
  (then select bindings ((<bridge> . <cand-bridge>))))

(control-rule SELECT-ON-FLOATING-BRIDGE-TYPE
  (if (and (current-operator MOVE-ACROSS-GAP-WITH-FLOATING-BRIDGE)
	 ;;(type-of-object-gen <cand-bridge> m4t6)
	 (preferred-bridge-type <cand-bridge>)))
  (then select bindings ((<bridge> . <cand-bridge>))))

(control-rule SELECT-ON-RAFT-TYPE
 (if (and (current-operator RAFT-TRAFFICABLE)
	(preferred-raft-type <cand-raft>)))
 (then select bindings ((<raft> . <cand-raft>))))

;;; If there are no bridges of the desired type, reject the operator
(control-rule NO-OTHER-FIXED-BRIDGES
 (if (and (current-goal (crossable <gap> <unit>))
	(or (~ (preferred-bridge-is-fixed))
	    (no-instances-of-preferred-bridge))))
 (then reject operator MOVE-ACROSS-GAP-WITH-FIXED-BRIDGE))

(control-rule NO-OTHER-FLOATING-BRIDGES
 (if (and (current-goal (crossable <gap> <unit>))
	(or (~ (preferred-bridge-is-floating))
	    (no-instances-of-preferred-bridge)
	    )))
 (then reject operator MOVE-ACROSS-GAP-WITH-FLOATING-BRIDGE))

(control-rule NO-RAFTING
 (if (and (current-goal (crossable <gap> <unit>))
	(or (preferred-bridge-is-floating)
	    (preferred-bridge-is-fixed))))
 (then reject operator RAFT-TRAFFICABLE))


;;; Prefer to go over the entire gap rather than narrow the gap.
(control-rule PREFER-TO-SPAN-ENTIRE-GAP
 (if (and (current-goal (trafficable <bridge> <gap> <unit>))))
 (then prefer operator
       FIXED-BRIDGE-TRAFFICABLE-OVER-ENTIRE-GAP
       FIXED-BRIDGE-TRAFFICABLE-OVER-A-VERY-SMALL-GAP))

;;; Prefer to fix damage in the bridge rather than fix the whole gap.
(control-rule prefer-to-go-over-bridge-damage
 (if (current-goal (trafficable <bridge> <gap> <unit>)))
 (then prefer operator
       FIXED-BRIDGE-TRAFFICABLE-OVER-BRIDGE-DAMAGE
       FIXED-BRIDGE-TRAFFICABLE-OVER-A-VERY-SMALL-GAP
       ))


;;; Force the goal (trafficable <bridge> <gap> <unit>) to be selected if
;;; it's pending, so that we'll fail quickly if it can't be satisfied.
;;; NOTE: This won't do the job for mgb and bailey because they subgoal
;;; on emplaced and then assembled, where feasibility is checked. Need a
;;; couple more control rules to finish this off nicely.

(control-rule FOCUS-ON-BRIDGE
  (if (candidate-goal (trafficable <bridge> <gap> <unit>)))
  (then select goal (trafficable <bridge> <gap> <unit>)))

;;; Similarly fail quickly if fording is not feasible at a particular site.
(control-rule FOCUS-ON-FORD
  (if (candidate-goal (trafficable <ford> <unit>)))
  (then select goal (trafficable <ford> <unit>)))


;;;============
;;; Control rules to move things sensibly
;;;============

;;; Prefer small moves like move-asset-across-bridge
;;; to move-military-unit to get equipment
(control-rule PREFER-SIMPLE-MOVES
  (if (current-goal (object-found-in-location <equipment> <location>)))
  ;; The unbound variable will match any operator.
  (then prefer operator <ANYTHING> EQUIPMENT-FOUND-WITH-UNIT))

;;; If the higher-level goal is to ford, don't be bringing in no bridges
;;; just to move assets around.
(control-rule FORD-PURELY-FIXED
  (if (and (current-goal (object-found-in-location <eq> <loc>))
	 (expanded-operator (ford <u> <g> <r> <lb> <rb> <la> <ra>))))
  (then reject operator MOVE-ASSET-ACROSS-FIXED-BRIDGE))

(control-rule FORD-PURELY-FLOATING
  (if (and (current-goal (object-found-in-location <eq> <loc>))
	 (expanded-operator (ford <u> <g> <r> <lb> <rb> <la> <ra>))))
  (then reject operator MOVE-ASSET-ACROSS-FLOATING-BRIDGE))

;;; If we have emplaced a bridge, prefer to use it for small moves.
;;; Don't know whether it's safe to reject.

(control-rule USE-EMPLACED-FLOATING-BRIDGE
 (if (and (current-goal (object-found-in-location <eq> <loc>))
	(known (emplaced <bridge> <gap>))
	(type-of-object <bridge> floating-bridge)))
 (then prefer operator MOVE-ASSET-ACROSS-FLOATING-BRIDGE <anything-else>))

(control-rule USE-EMPLACED-FIXED-BRIDGE
 (if (and (current-goal (object-found-in-location <eq> <loc>))
	(known (emplaced <bridge> <gap>))
	(type-of-object <bridge> military-fixed-bridge)))
 (then prefer operator MOVE-ASSET-ACROSS-FIXED-BRIDGE <anything-else>))

(control-rule USE-ASSEMBLED-RAFT
 (if (and (current-goal (object-found-in-location <eq> <loc>))
	(known (assembled-raft <raft> <gap> <unit>))
	(type-of-object <raft> floating-bridge)))
 (then prefer operator MOVE-ASSET-ACROSS-RAFT <anything-else>))


;;; Don't use move-military-unit to move some equipment, instead
;;; subgoal through equipment-found-with-unit
(control-rule DONT-USE-MOVE-MIL-UNIT
  (if (and (current-goal (object-found-in-location <equipment> <location>))
	 (type-of-object <equipment> engineering-equipment)))
  (then reject operator MOVE-MILITARY-UNIT))


;;; Work on emplacing a bridge first, because then it's easier to move
;;; other stuff around.
;;; I may need to rethink this, since it interferes with using available
;;; equipment to de-rubble while moving the bridge (for example).
(control-rule PREFER-TO-EMPLACE
  (if (candidate-goal (emplaced <bridge> <gap> <length> <unit>)))
  (then select goal (emplaced <bridge> <gap> <length> <unit>)))

;;; Also be single-minded about moving stuff - this helps to
;;; quickly backtrack to the correct bank.
;;; - not sure yet.

;;; Preference rules to prefer nearby stuff.

(control-rule PREFER-NEARBY-DOZERS-TO-NARROW-GAP
  (if (and (current-operator NARROW-GAP-WITH-BULLDOZER)
	 (current-goal (width-of-object <gap> <x>))
	 (nearby-equipment <gap> military-dozer <dozer>)
	 (type-of-object-gen <other-dozer> military-dozer)
	 (~ (nearby-equipment <gap> military-dozer <other-dozer>))))
  (then prefer bindings ((<bdz> . <dozer>)) ((<bdz> . <other-dozer>))))

(control-rule PREFER-NEARBY-DOZERS-TO-MOVE-RUBBLE
 (if (and (current-operator DOZER-PLOW-RUBBLE)
	(or (current-goal (~ (has-rubble <loc>)))
	    (current-goal (minor-prep <loc>)))
	(nearby-equipment <loc> military-dozer <dozer>)
	(type-of-object-gen <other-dozer> military-dozer)
	(~ (nearby-equipment <loc> military-dozer <other-dozer>))))
 (then prefer bindings ((<bdz> . <dozer>)) ((<bdz> . <other-dozer>))))

(control-rule PREFER-NEARBY-DOZERS-TO-DESLOPE-BANK
 (if (and (current-operator DESLOPE-BANK)
	(current-goal (desloped <gap> <bank> <above-water-height>
			    <max-bank-height> <max-slope>))
	(nearby-equipment <gap> military-dozer <dozer>)
	(type-of-object-gen <other-dozer> military-dozer)
	(~ (nearby-equipment <gap> military-dozer <other-dozer>))))
 (then prefer bindings ((<bdz> . <dozer>)) ((<bdz> . <other-dozer>))))


;;; prefer to plow rubble with available equipment, but if both m88 and
;;; tank-plow are there, prefer m88 unless tank plow is mounted.

(control-rule PREFER-NEARBY-STUFF-TO-PLOW-RUBBLE
  (if (and (or (current-goal (~ (has-rubble <region>)))
	     (current-goal (minor-prep <region>)))
	 (plow-equip-type <type1>)	; military-dozer, tank-plow or m88
	 (nearby-equipment <region> <type1> <ob>)
	 (plow-equip-type <type2>)
	 (no-nearby-equipment <region> <type2>)
	 (plow-op-for <type1> <op1>)
	 (plow-op-for <type2> <op2>)))
  (then prefer operator <op1> <op2>))

;;; In order to de-rubble concurrently with moving if possible, do it
;;; with something belonging to the interdicted unit on its side if it
;;; has something. This cannot cause a cycle with the above rule because
;;; if we choose op1 here, it must be nearby so it wouldn't be reject by
;;; the above rule.

(control-rule PREFER-INTERDICTED-STUFF-TO-PLOW-THEIR-RUBBLE
 (if (and (current-goal (~ (has-rubble <region>)))
	(near-approach-cr <region> <near-approach>)
	(plow-equip-type <type1>)
	(type-of-object-gen <ob> <type1>)
	(known (object-found-in-location <ob> <near-approach>))
	;; find the interdicted unit
	(expanded-goal (crossable <region> <int>))
	;; This handles transitivity of subordinate-unit
	(unit-has-control-of-equipment <int> <ob>)
	(plow-equip-type <type2>)
	(diff <type1> <type2>)
	;; This is needed to hide a forall
	(unit-has-no-equipment-of-type <int> <type2>)
	(plow-op-for <type1> <op1>)
	(plow-op-for <type2> <op2>)))
 (then prefer operator <op1> <op2>))



(control-rule PREFER-M88-UNLESS-TANK-PLOW-MOUNTED
 (if (and (current-goal (~ (has-rubble <region>)))
	(nearby-equipment <region> m88 <m>)
	(nearby-equipment <region> tank-plow <tp>)
	(~ (known (mounted <tp>)))))
 (then prefer operator M88-PLOW-RUBBLE TANK-PLOW-RUBBLE))


;;; Preference rule to prefer better-equipped units.
;;; As you can see, pref rules on bindings are really ugly.
(control-rule PREFER-BRIDGE-CARRYING-UNIT-FOR-DOZER
 (if (and (current-goal (width-of-object <g> <w>))
	(current-operator NARROW-GAP-WITH-BULLDOZER)
	;; if we need to bring one from somewhere..
	(no-nearby-equipment <g> military-dozer)
	;; and if the bridge we want isn't nearby..
	(plan-to-use-bridge <planned-bridge>)
	(and (~ (type-of-object <planned-bridge> civilian-bridge))
	     (~ (nearby-equipment <g> bridge <planned-bridge>)))
	;; and some unit has it..
	(known (group-members <col> <planned-bridge>))
	(known (mission-equipment <u> <col>))
	;; and we're trying to use some dozer..
	(candidate-bindings <using-bridge-unit>)
	;;(elt-val 0 <using-bridge-unit> <dozer>)
	(op-val <using-bridge-unit> narrow-gap-with-bulldozer
	        <bdz> <dozer>)
	;; and that dozer is in the same unit..
	(known (mission-equipment <u> <col2>))
	(known (group-members <col2> <dozer>))
	;; and some other dozer is with a different military unit
	;; (bindings-list will be bound from the right hand side)
	(inst-val <bdz> <using-other-unit> <other-dozer>)
	(known (group-members <col3> <other-dozer>))
	(known (mission-equipment <other-unit> <col3>))
	(diff <unit> <other-unit>)
	(list-to-bindings <using-bridge-unit> narrow-gap-with-bulldozer <better-bindings>)))
 (then prefer bindings <better-bindings> <using-other-unit>))

;;; For craters, prefer to fill if there is filling equipment nearby but
;;; no avlb's or tmm's nearby. Otherwise, prefer bridges.

;;; Need to think about the sets of object types carefully along with
;;; the two-level inference rules and operators for craters.

(control-rule PREFER-NEARBY-STUFF-FOR-CRATERS
 (if (and (current-goal (trafficable <crater> <unit>))
	(type-of-object <crater> crater)
	(or (and (type-of-object-gen <ob> military-dozer)
	         (nearby-equipment <crater> military-dozer <ob>))
	    (and (type-of-object-gen <ob> tank-plow)
	         (nearby-equipment <crater> tank-plow <ob>))
	    (and (type-of-object-gen <ob> m88)
	         (nearby-equipment <crater> m88 <ob>)))
	(and (no-nearby-equipment <crater> avlb-bridge)
	     (no-nearby-equipment <crater> tmm-bridge))))
 (then prefer operator cross-crater-by-filling-in cross-crater-with-bridge))


;;; Another twist on preferring near stuff: prefer the goals for
;;; de-mining, de-rubbling etc that are on the side where the equipment
;;; currently is. This could probably safely be a select goal control
;;; rule.

(control-rule DO-NEAREST-END-FIRST
 (if (and (candidate-goal (~ (mined <end1>)))
	(type-of-object <end1> tunnel-opening)
	(candidate-goal (~ (mined <end2>)))
	(diff <end1> <end2>)
	(type-of-object <end2> tunnel-opening)
	(known (approach-of <end1> <approach1>))
	(known (approach-of <end2> <approach2>))
	(known (object-found-in-location <explosives> <approach1>))
	(type-of-object <explosives> Explosives)
	(no-equipment-at-location <approach2> explosives)))
 ;; The preferred goal is really negative, but Prodigy can't find it if
 ;; it has ~ around it. If you state the positive goal, it finds the
 ;; right literal and figures out the goal sense later.
 (then prefer goal (mined <end1>) (~ (mined <end2>))))

;;; A similar one for craters.

;;; If stuff must be brought from one town, select the crater that's
;;; nearest to it.

(control-rule PREFER-NEAREST-CRATER
 (if (and (candidate-goal (crossable <crater1> <unit>))
	(candidate-goal (crossable <crater2> <unit>))
	(type-of-object <crater1> crater)
	(type-of-object <crater2> crater)
	(no-nearby-equipment <crater1> avlb-bridge)
	(no-nearby-equipment <crater1> tmm-bridge)
	(no-nearby-equipment <crater1> tank-plow)
	(no-nearby-equipment <crater1> m88)
	(no-nearby-equipment <crater1> military-dozer)
	(only-city-with-crater-stuff <town>)
	(nearest-crater-to-city <town> <crater1>)
	(diff <crater1> <crater2>)))
 (then reject goal (crossable <crater2> <unit>)))

;;; If a crater has been made crossable, select one adjacent to that.

(control-rule PREFER-NEXT-CRATER
 (if (and (candidate-goal (crossable <crater1> <unit>))
	(candidate-goal (crossable <crater2> <unit>))
	(type-of-object <crater1> crater)
	(type-of-object <crater2> crater)
	(type-of-object-gen <crater3> crater)
	(known (crossable <crater3> <unit>))
	(adjacent-crater <crater1> <crater3>)
	(diff <crater1> <crater2>)))
 (then reject goal (crossable <crater2> <unit>)))

	


;;; prefer magic moves for things that can use them - because those are
;;; the things you need to move before the bridge is emplaced.

(control-rule PREFER-MAGIC-GAP
 (if (and (current-goal (object-found-in-location <asset> <loc>))
	(or (type-of-object <asset> bangalore-torpedo)
	    (type-of-object <asset> explosives))
	(non-magic-move <op2>)))
 (then prefer operator MOVE-ASSET-ACROSS-GAP <op2>))

(control-rule PREFER-MAGIC-TUNNEL
 (if (and (current-goal (object-found-in-location <asset> <loc>))
	(or (type-of-object <asset> military-dozer)
	    (type-of-object <asset> military-loader)
	    (type-of-object <asset> tank-plow)
	    (type-of-object <asset> explosives))
	(type-of-object-gen <tunnel> tunnel)
	(either-approach <tunnel> <loc>)
	(non-magic-move <op2>)))
 (then prefer operator MOVE-ASSET-AROUND-TUNNEL <op2>))


;;; General movement rule: prefer small moves if possible. This won't
;;; conflict with the others since nothing prefers equipment-found-with-unit

(control-rule PREFER-TO-FORD
 (if (current-goal (object-found-in-location <asset> <loc>)))
 (then prefer operator MOVE-ASSET-ACROSS-GAP-BY-FORDING-IT
       EQUIPMENT-FOUND-WITH-UNIT))


(control-rule PREFER-NEARBY-MICLIC
 (if (and (current-goal (~ (mined <region>)))
	(current-operator employ-miclic)
	(candidate-bindings <using-near-miclic>)
	(op-val <using-near-miclic> employ-miclic
	        <asset> <mic1>)
	(nearby-equipment <region> miclic <mic1>)
	(inst-val <asset> <other-bindings> <mic2>)
	(diff <mic2>)
	(~ (nearby-equipment <region> miclic <mic2>))
	(list-to-bindings <using-near-miclic> employ-miclic
		        <better>)))
 (then prefer bindings <better> <other-bindings>))


;;; Reject any movement goal that isn't worthwhile
;;; for craters (which have a hard enough problem as it is)

(control-rule ONLY-CRATER-WORTHY-MOVES
 (if (and (current-goal (object-found-in-location <o> <l>))
	(known (approach-of <c> <l>))
	(type-of-object <c> crater)
	(bad-move-for-crater <op>)))
 (then reject operator <op>))



;;;============
;;; De-mining operators.
;;;============

;;; - if demining a tunnel opening,
;;;   =>  do only HASTY-BREACH-MINEFIELD, try nothing else
(control-rule ONLY-HASTY-BREACH-FOR-TUNNEL-OPENINGS
 (if (and (current-goal (~ (mined <opening>)))
	(type-of-object <opening> tunnel-opening)))
 (then select operator HASTY-BREACH-MINEFIELD-TUNNEL-END))

;;; - if demining an approach that is by a tunnel,
;;;   =>  the order is TANK-PLOW-REGION HASTY-BREACH-MINEFIELD,
;;;       try nothing else


(control-rule DEMINE-NEAR-A-TUNNEL
 (if (and (current-goal (~ (mined <approach>)))
	(known (approach-of <tunnel> <approach>))
	(type-of-object <tunnel> tunnel)))
 (then select operators (TANK-PLOW-REGION
		     HASTY-BREACH-MINEFIELD-NOT-A-TUNNEL-END)))

;;; - for crater approaches: prefer in this order:
;;;      miclic, bangalore followed by tank plow, tank plow, hasty breech

(control-rule DEMINE-NEAR-A-CRATER
 (if (and (current-goal (~ (mined <approach>)))
	(known (approach-of <crater> <approach>))
	(type-of-object <crater> crater)))
 (then select operators (EMPLOY-MICLIC
		     ;;EMPLOY-BANGALORE-TORPEDO ; doesn't belong here
		     TANK-PLOW-REGION
		     HASTY-BREACH-MINEFIELD-NOT-A-TUNNEL-END)))

;;; - if demining an approach that is on the OTHER side as
;;;    the bridge we are trying to install
;;;   => the order is EMPLOY-BANGALORE-TORPEDO HASTY-BREACH-MINEFIELD,
;;;      try nothing else

(control-rule DEMINE-OTHER-SIDE
 (if (and (current-goal (~ (mined <approach>)))
	(or (known (left-approach <gap> <approach>))
	    (known (right-approach <gap> <approach>)))
	(plan-to-use-bridge <bridge>)
	(~ (type-of-object <bridge> civilian-bridge))
	(known (object-found-in-location <bridge> <bridge-loc>))
	(~ (same-side-of-river <bridge> <bridge-loc>))))
 (then select operators (EMPLOY-BANGALORE-TORPEDO
		     HASTY-BREACH-MINEFIELD-NOT-A-TUNNEL-END)))
	    

;;; - if demining an approach that is on the SAME side as
;;;     the bridge we are trying to install
;;;   => the order is TANK-PLOW-REGION EMPLOY-MICLIC HASTY-BREACH-MINEFIELD,
;;;      try nothing else
;;;      (amendment: use the same rule for either side of a civilian bridge)

(control-rule DEMINE-SAME-SIDE
 (if (and (current-goal (~ (mined <approach>)))
	(or (known (left-approach <gap> <approach>))
	    (known (right-approach <gap> <approach>)))
	(plan-to-use-bridge <bridge>)
	(or (type-of-object <bridge> civilian-bridge)
	    (and (known (object-found-in-location <bridge> <bridge-loc>))
	         (same-side-of-river <bridge-loc> <approach>)))))
 (then select operators (TANK-PLOW-REGION
		     EMPLOY-MICLIC
		     HASTY-BREACH-MINEFIELD-NOT-A-TUNNEL-END)))

;;; To demine a river or river-bank for fording (and a road segment when
;;; that is represented) use MICLIC, Bangalore + tank plow, tank plow
;;; and hasty-breach

(control-rule DEMINE-NO-STRUCTURE-PRESENT
 (if (and (current-goal (~ (mined <region>)))
	(or (type-of-object <region> body-of-water) ; must be dry
	    (and (type-of-object <region> geographical-bank)
	         (expanded-operator
		(ford <u> <g> <r> <lb> <rb> <la> <ra>))))))
 (then select operators (EMPLOY-MICLIC
		     TANK-PLOW-REGION
		     HASTY-BREACH-MINEFIELD-NOT-A-TUNNEL-END)))
	    


;;; One de-rubbling operator - easier to have this than to add a
;;; (not tunnel-opening) restriction on every other rubble operator

(control-rule USE-DOZER-PLOW-TUNNEL-FOR-TUNNEL-RUBBLE
 (if (and (current-goal (~ (has-rubble <tunnel-opening>)))
	(type-of-object <tunnel-opening> tunnel-opening)))
 (then select operator DOZER-PLOW-TUNNEL-RUBBLE-AND-SHORE-ROOF))

;;; Use a tank plow to de-rubble if you're already using one to demine

(control-rule USE-TANK-PLOW-FOR-RUBBLE-IF-DEMINING
 (if (and (current-goal (~ (has-rubble <region>)))
	(or (candidate-goal (~ (mined <region>)))
	    (expanded-operator
	     (TANK-PLOW-REGION <tp> <region> <m> <na>)))))
 (then select operator tank-plow-rubble))

;;; Don't choose narrow-gap just to get rid of rubble (narrow-gap does
;;; have that as a side-effect).

(control-rule DONT-NARROW-TO-DERUBBLE
 (if (current-goal (~ (has-rubble <region>))))
 (then reject operator NARROW-GAP-WITH-BULLDOZER))

(control-rule DONT-NARROW-TO-DO-MINOR-PREP
 (if (current-goal (minor-prep <region>)))
 (then reject operator NARROW-GAP-WITH-BULLDOZER))


;;; Need to make sure we don't waste backtrack time over release-asset

(control-rule ALWAYS-RELEASE
 (if (candidate-goal (~ (in-use <asset>))))
 (then select goal (in-use <asset>)))

(control-rule ALWAYS-APPLY-RELEASE-ASSET
 (if (applicable-operator (release-asset <asset>)))
 (then apply))

;;; Don't mess with the order of moving things
#|
(control-rule SELECT-MOVING
 (if (candidate-goal (object-found-in-location <asset> <loc>)))
 (then select goal (object-found-in-location <asset> <loc>)))
|#

;;; Never subgoal on having some piece of equipment in use
(control-rule DONT-SUBGOAL-ON-IN-USE
 (if (candidate-goal (in-use <asset>)))
 (then reject goal (in-use <asset>)))
