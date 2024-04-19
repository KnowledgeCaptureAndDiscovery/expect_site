;;; -*- Mode: Lisp; Package: BATTLE-SPACE; Syntax: COMMON-LISP; Base: 10 -*-

(defpackage "BATTLE-SPACE"
  (:nicknames "BS")  ;; pun intended
  (:shadow
   ;; Concepts:
;   "COLLECTION"
;   "INTEGER"
;   "KNOWLEDGE-BASE"
;   "PROPOSITION"
;   "RATIONAL-NUMBER"
;   "ROLE"
;   "THING"
;   ;; Relations:
;   "ARITY"
;   "CARDINALITY"
;   "IMPLIES"
;   "ISA"
   ;; Lisp types:
   "STREAM"
   ))

(in-package "BATTLE-SPACE")


(defvar *creation-policy* :lite-instance)

(unless (loom:find-context "CYC-SENSUS-UPPER")
  (loom:use-loom "BATTLE-SPACE" :dont-create-context-p t)
  ;;(shadowing-import '(cl-user::role))  ;; hack, unintern loom:role
  )

(loom:in-context 'BUILT-IN-THEORY)
(load (merge-pathnames "measures.loom" *load-pathname*))

;; This should go into a separate top-level context:
(load (merge-pathnames "annotations.loom" *load-pathname*))

(unless (loom:find-context "CYC-SENSUS-UPPER")

  (defcontext CYC-SENSUS-UPPER :theory (BUILT-IN-THEORY)
    :creation-policy *creation-policy*)

  (loom:in-context 'CYC-SENSUS-UPPER)
  (load (merge-pathnames "cyc-sensus-upper.loom" *load-pathname*))

  ;; Exit hook to create bands that have only the upper level loaded:
  (defvar cl-user::*load-cyc-upper-level-only-p* nil)
  (when cl-user::*load-cyc-upper-level-only-p*
    (cerror "Continue loading the remaining ontologies?"
            "CYC Upper level loaded.")))

(in-context 'CYC-SENSUS-UPPER)
(load (merge-pathnames "cyc-sensus-upper-fixes.loom" *load-pathname*))

(defcontext CYC-VEHICLES :theory (CYC-SENSUS-UPPER)
            :creation-policy *creation-policy*)

(in-context 'CYC-VEHICLES)
(load (merge-pathnames "vehicles-cyc.loom" *load-pathname*))
(load (merge-pathnames "vehicles-cyc-fixes.loom" *load-pathname*))

(defcontext LAND-VEHICLES :theory (CYC-VEHICLES)
            :creation-policy *creation-policy*)

(in-context 'LAND-VEHICLES)
(load (merge-pathnames "vehicles.loom" *load-pathname*))

(defcontext FEATURES :theory (CYC-SENSUS-UPPER)
            :creation-policy *creation-policy*)

(in-context 'FEATURES)
(load (merge-pathnames "features.loom" *load-pathname*))

(defcontext ENGINEERING-EQUIPMENT :theory
  (CYC-SENSUS-UPPER LAND-VEHICLES FEATURES)
  :creation-policy *creation-policy*)

(in-context 'ENGINEERING-EQUIPMENT)
(load (merge-pathnames "engineering-equipment.loom" *load-pathname*))

(defcontext MILITARY-UNITS :theory
  (CYC-SENSUS-UPPER LAND-VEHICLES ENGINEERING-EQUIPMENT)
  :creation-policy *creation-policy*)

(in-context 'MILITARY-UNITS)
(with-feature-changes (:unset '(:display-match-changes :emit-match-stars))
  (load (merge-pathnames "military-units.loom" *load-pathname*)))

(defcontext OBDATA-UNITS :theory
  (MILITARY-UNITS)
  :creation-policy *creation-policy*)

(when (probe-file (merge-pathnames "obdata-units.loom" *load-pathname*))
  (in-context 'OBDATA-UNITS)
  (with-feature-changes (:unset '(:display-match-changes :emit-match-stars))
    (load (merge-pathnames "obdata-units.loom" *load-pathname*))))

(defcontext MOVEMENT-ANALYSIS :theory
  (CYC-SENSUS-UPPER LAND-VEHICLES FEATURES MILITARY-UNITS OBDATA-UNITS)
  :creation-policy *creation-policy*)

(when (and (probe-file (merge-pathnames "Reports.loom" *load-pathname*))
           (probe-file (merge-pathnames "MA-Input.loom" *load-pathname*)))
  (in-context 'MOVEMENT-ANALYSIS)
  (load (merge-pathnames "Reports.loom" *load-pathname*))
  (with-feature-changes (:unset '(:display-match-changes :emit-match-stars))
    (load (merge-pathnames "MA-Input.loom" *load-pathname*))))

;; The all-encompassing context:
(defcontext BATTLE-SPACE :theory
  (ENGINEERING-EQUIPMENT FEATURES LAND-VEHICLES MILITARY-UNITS
                         OBDATA-UNITS MOVEMENT-ANALYSIS)
  :creation-policy *creation-policy*)

(in-context 'BATTLE-SPACE)

(tellm)
