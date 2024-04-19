;; generate ps-tree exe-tree descriptions

(in-package "EXPECT")

(defun get-ps-tree-all ()
  (let* ((*package* (find-package "EXPECT"))
	 (sstream (make-string-output-stream)))
    (expect::print-tree-summary expect::*ps-tree* 0 sstream)
    (get-output-stream-string sstream)))

(defun get-ps-tree-success ()
  (let* ((*package* (find-package "EXPECT"))
	 (sstream (make-string-output-stream)))
    (expect::print-tree-summary-success expect::*ps-tree* 0 sstream)
    (get-output-stream-string sstream)))

(defun get-ps-tree-short ()
  (let* ((*package* (find-package "EXPECT"))
	 (sstream (make-string-output-stream)))
    (expect::print-tree-summary-short-success expect::*ps-tree* 0 sstream)
    (get-output-stream-string sstream)))

(defun get-ps-tree-goals ()
  (let* ((*package* (find-package "EXPECT"))
	 (sstream (make-string-output-stream)))
    (expect::print-tree-goals expect::*ps-tree* 0 sstream)
    (get-output-stream-string sstream)))

(defun get-ps-tree-pretty ()
  (let* ((*package* (find-package "EXPECT"))
	 (sstream (make-string-output-stream)))
    (expect::write-expl-r expect::*ps-tree* 0 sstream nil)
    (get-output-stream-string sstream)))

(defun get-ps-tree-pretty-nl ()
  (let* ((*package* (find-package "EXPECT"))
	 (sstream (make-string-output-stream)))
    (expect::write-expl-r expect::*ps-tree* 0 sstream 't)
    (get-output-stream-string sstream)))

(defun get-ps-tree-very-detail ()
  (let* ((*package* (find-package "EXPECT"))
	 (sstream (make-string-output-stream)))
    (expect::print-tree-detail expect::*ps-tree* 0 sstream)
    (get-output-stream-string sstream)))

(defun get-exe-tree-goals ()
  (let* ((*package* (find-package "EXPECT"))
	 (sstream (make-string-output-stream)))
    (expect::print-tree-goals expect::*exe-tree* 0 sstream)
    (get-output-stream-string sstream)))

(defun get-exe-tree-pretty ()
  (let* ((*package* (find-package "EXPECT"))
	 (sstream (make-string-output-stream)))
    (expect::write-expl-r expect::*exe-tree* 0 sstream nil)
    (get-output-stream-string sstream)))

(defun get-exe-tree-pretty-nl ()
  (let* ((*package* (find-package "EXPECT"))
	 (sstream (make-string-output-stream)))
    (expect::write-expl-r expect::*exe-tree* 0 sstream 't)
    (get-output-stream-string sstream)))
