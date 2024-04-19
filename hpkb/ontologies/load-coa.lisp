
(defpackage "CYC"
  (:shadow
   "BINARY-RELATION"
   "KNOWLEDGE-BASE"
   "LIST"
   "RATIONAL-NUMBER"
   "UNARY-FUNCTION"
   "MAXIMUM"
   "MINIMUM"
))
  

(in-package "CYC")

;;;(defvar *ontology-path* "/home/moriarty/research/ontologies/foo.lisp")

;;; I reworked the directory definitions to work on the Mac as well
;;; Jim

(defvar *ontology-path* "~expect/COA/ontologies/foo.lisp")

;;; I'd like to make this :classified-instance, but then planet-coa
;;; dies, so we'll leave this for now.
(defvar *creation-policy* :lite-instance)

(defvar *ontology-directory*
  (make-pathname :directory (pathname-directory *load-truename*)))

(defvar *coa-ontology-directory*
  (make-pathname :directory (append (pathname-directory *ontology-directory*)
			      '("coa"))))

(unless (loom:find-context "CYC-KB")
  (loom:use-loom "CYC" :dont-create-context-p t))

(loom:in-context 'BUILT-IN-THEORY)

(unless (loom:find-context "CYC-KB")
  (defcontext CYC-KB :theory (BUILT-IN-THEORY EXPECT-THEORY)
              :creation-policy *creation-policy*))

(unless (loom:find-context "COA")
   (defcontext COA :theory (CYC-KB)
              :creation-policy *creation-policy*))

(loom:in-context 'CYC-KB)

;;; Try to use a stub so we can load in decent time on a laptop
;;; (or at all under windows)
;;;(load (merge-pathnames "cyc-ikb.loom" *ontology-directory*))

(load (merge-pathnames "small-ikb.loom" *ontology-directory*))

(load (merge-pathnames "undefined-concepts.loom" *coa-ontology-directory*))
(load (merge-pathnames "IKB-addendum.loom" *coa-ontology-directory*))
(load (merge-pathnames "military-units.loom" *coa-ontology-directory*))
(load (merge-pathnames "areas.loom" *coa-ontology-directory*))
(load (merge-pathnames "purposes.loom" *coa-ontology-directory*))
(load (merge-pathnames "task-interaction.loom" *coa-ontology-directory*))
(load (merge-pathnames "tactical-tasks.loom" *coa-ontology-directory*))
(load (merge-pathnames "tasks.loom" *coa-ontology-directory*))
(load (merge-pathnames "equipment.loom" *coa-ontology-directory*))
(load (merge-pathnames "planning-assumptions.loom" *coa-ontology-directory*))
(load (merge-pathnames "pma.loom" *coa-ontology-directory*))
(load (merge-pathnames "additional-constants.loom" *coa-ontology-directory*))

(tellm)

