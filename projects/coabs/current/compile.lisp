;;; -*- Mode: LISP; Syntax: COMMON-LISP; Package: COMMON-LISP-USER; Base: 10. -*-

;;; Load all files necessary to install the EXPECT system. Adapted
;;; from the loom initialization file

(unless (find-package "COMMON-LISP")
  (rename-package (find-package "LISP") "LISP" '("COMMON-LISP" "CL")))
(unless (find-package "COMMON-LISP-USER")
  (rename-package (find-package "USER") "USER" '("COMMON-LISP-USER" "CL-USER")))

(in-package "COMMON-LISP-USER")


;; Make a pathname pointing to the top of the EXPECT directories hierarchy:
;;

(defparameter *expect-pathname-default* 
    (make-pathname :directory (pathname-directory *load-truename*)))

;;; Initialize pathname variables that point to the various subdirectories
;;;    and files referenced during the compilation and/or load process.


(defun expect-pathname (&key name
		         (type *lisp-extension*)
		         (defaults *expect-pathname-default*)
		         subDirectory)
  ;; Returns a pathname for the specified file, merging in EXPECT
  ;; defaults.  "subDirectory" is a string naming a subdirectory of
  ;; the expect root directory.
  (let ((path (make-pathname 
	     :name (truncate-name name)
	     :type type
	     :defaults defaults
	     :directory (if subDirectory
			(append (pathname-directory defaults) 
			        (list subdirectory))
		        (pathname-directory defaults)))))
    
    path))



;;; Create the EXPECT package:

(defpackage "EXPECT" (:shadow RESTRICTIONS))
(loom:use-loom "EXPECT")
(loom:unset-features :display-match-changes)
(loom:load-loom-patches)
(pushnew :EXPECT *features*)
(pushnew :EXPECT-3 *features*)
(pushnew :EXPECT3.0 *features*)


;;; Define defsystem functions.  Load a compiled version if possible.
#+(and (or :LUCID :MCL) (not :MK-DEFSYSTEM))
(load (expect-pathname :name "defsystem" :type nil))
#-(or :MCL :LUCID :TI :MK-DEFSYSTEM)
(load (expect-pathname :name "defsystem"))

;;; Determine the directory for storing and retrieving binaries
;;; for this LISP:
(defvar *expect-binary-directory*;; load time determination
  (or #+(and :ISI :MCL)
        (translate-logical-pathname  "CCL:EXPECT 3.0 binaries;")
      (expect-pathname
       :type #-TI nil #+TI :unspecific
       #+TI :name #+TI ""
       :subdirectory
       (or
	#+(and :ISI :LUCID)
	(let* ((HOST #+:PA "-HP" #-:PA "-")
	       (LISP (cond ((member :LCL4.1 user::*features*) "LCL4.1")
			   ((member :LCL4.0 user::*features*) "LCL4.0")
			   ("LCLx.x"))))
	  (concatenate 'string "BIN" HOST LISP))
	#+(and :ISI :ALLEGRO)
	(let* ((HOST #+:SPARC "-" #-:SPARC "-HP")
	       (LISP (cond ((member :ALLEGRO-V5.0 user::*features*) "ACL5.0")
		         ((member :ALLEGRO-V4.3 user::*features*) "ACL4.3")
			   ((member :ALLEGRO-V4.2 user::*features*) "ACL4.2")
			   ((member :ALLEGRO-V4.1 user::*features*) "ACL4.1")
			   ("ACLx.x"))))
	  (concatenate 'string "BIN" HOST LISP))
	#+(and :ISI :TI) "BIN-XLD"
	#+(and :ISI :CMU) "BIN-CMUCL"
	#+(and :ISI :LINUX86) "BIN-LINUX"
	#+LOOM3.1 "BIN-LOOM3.1"
	"BIN"))))

;; Load the defsys file

(load (expect-pathname :name "defsys"))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; Define (expect) and (e), i.e., the functions that start 
;;    the system, in whatever package this file is loaded.
;;;
(defun expect ()
  (in-package "EXPECT")
  (expect::expect))
  

;;;
(defun e ()
  (expect))


;;; Define (e) also inside the EXPECT package
;;;
(in-package "EXPECT")
(defun e ()
  (expect))

(defparameter expect::*expect-pathname-default* 
    (make-pathname :directory (pathname-directory *load-truename*)))

;; AV 1/30/98 In order to provide compatibility, here they are:
;; But I think we should try to avoid this.

(setq *shared-pathname-default*
  (merge-pathnames (make-pathname :directory '(:relative "shared"))
                   *expect-pathname-default*))
(setq *ps-pathname-default*
  (merge-pathnames (make-pathname :directory '(:relative "ps"))
                   *expect-pathname-default*))
(setq *ka-pathname-default*
  (merge-pathnames (make-pathname :directory '(:relative "ka"))
                   *expect-pathname-default*))
(setq *kas-pathname-default*
  (merge-pathnames (make-pathname :directory '(:relative "kas"))
                   *expect-pathname-default*))
(setq *ui-pathname-default*
  (merge-pathnames (make-pathname :directory '(:relative "ui"))
                   *expect-pathname-default*))
(setq *clim-pathname-default*
  (merge-pathnames (make-pathname :directory '(:relative "ui"))
                   *expect-pathname-default*))
(setq *grator-pathname-default*
  (merge-pathnames (make-pathname :directory '(:relative "grator"))
                   *expect-pathname-default*))
(setq *matcher-pathname-default*
  (merge-pathnames (make-pathname :directory '(:relative "matcher"))
                   *expect-pathname-default*))
(setq *domain-pathname-default*
  (merge-pathnames (make-pathname :directory '(:relative "domains"))
                   *expect-pathname-default*))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(let (#+(and :EXCL (or :Allegro-V4.1 :Allegro-V4.2 :allegro-v4.3))
        (comp:*cltl1-compile-file-toplevel-compatibility-p* nil)
        #+(or :lispworks (and :EXCL (or :Allegro-V4.1 :Allegro-V4.2 :allegro-v4.3 :allegro-v5.0)))
        #+(and :EXCL :UNIX :ISI)(umaskValue (read-line (excl:run-shell-command "umask" :output :stream :wait nil)))
        (*compile-print* nil))
  (common-lisp-user::with-redefinition-warnings-suppressed
   (common-lisp-user::with-undefined-function-warnings-suppressed
    (make:operate-on-system 'expect
		        :compile
		        :force :new-source-and-dependents)))
  #+(and :EXCL :UNIX :ISI) (excl:run-shell-command (format nil "umask ~A" umaskValue) :wait t)
  )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 
;; CLIM stuff
;;


#-:CLIM(defvar *clim* nil)
#+:CLIM(defvar *clim* t)


;;; The size has to be set before we do the definitions and the ka-commands.
;;; 
;;; To use CLIM with screens of different sizes, call clim-resize with
;;; the desired screen size.
;;; The options are 16-inch, mosaic, power-book, and default (18-inch screen).
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

#+:CLIM(clim-resize 'default)

