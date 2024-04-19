;;; This file contains server functions that are needed in addition to
;;; the ones in ../tk-int/top-level.lisp. I tried to use the same ones
;;; wherever possible, but because java does not have a reader like
;;; TCL/TK, I sometimes have to package the lisp output a bit more.
;;; Jim 1/00

(in-package "EXPECT")

(defun java-print-method-capabilities ()
  "Prints the method capabilities in English format, one per line, and ends with \"done\""
  
  (mapcar #'(lambda (cap-method)
	    (tcl::send-to-tcl (first cap-method)))
	(sort (make-capanl&name-list)
	      #'string-lessp
	      :key #'first))
  (tcl::send-to-tcl "done"))
