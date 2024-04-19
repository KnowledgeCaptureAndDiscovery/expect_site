(in-package "EXPECT")

;; check if the goal argument is in these form
;;   (INST INSTANCE-NAME) or
;;   (DESC CONCEPT-NAME)
(defun inst-or-desc-arg (arg)
  (cond ((not (listp (second arg)))
         nil)
        ((or (equal (caadr arg) 'inst)
	   (equal (caadr arg) 'desc))
         t
         nil)))

(defun is-there-inst-or-desc-arg (arg-list)
  (cond ((null arg-list)
         nil)
        ((inst-or-desc-arg (first arg-list))
         t)
        (t (is-there-inst-or-desc-arg (rest arg-list)))))

(defun remove-inst-or-desc (arg)
  (cond ((not (listp arg))
         arg)
        ((or (eq (first arg) 'inst)
	   (eq (first arg) 'desc))
         (second arg))
        (t arg)))

;; replace occurrences of a character to a new character 
(defun replace-char (oldchar newchar inputString)
  (let ((newString inputString))
    (dotimes (count (length inputString) newString)
	   (if (eq (aref inputString count) oldchar)
	       (setf (aref newString count) newchar)))))
  
;; given a list of words in a string, return a list of strings ----
(defun fix-words (inputString) 
  (let ((fixedString inputString))
    (dotimes (count (length inputString) fixedString)
      (if (or (eq (aref inputString count) #\,)
	      (eq (aref inputString count) #\()
	      (eq (aref inputString count) #\))
	      (eq (aref inputString count) #\')
	      (eq (aref inputString count) #\"))
	  (setf (aref fixedString count) #\Space)))))

(defun get-words-in-string (stringInputStream result)
  (let ((word (read stringInputStream nil 'done)))
    (if (eq word 'done)
	result
      (get-words-in-string stringInputStream
			   (append result (list (string word)))))))

(defun find-words (inputString)
  (let ((fixedString (fix-words inputString)))
    (get-words-in-string (make-string-input-stream fixedString) nil)
  ))
;;; end of find words in string ----------------------


;; intersection lists, keeping ordering
(defun intersection-2 (new current)
  (let ((result nil)
	(isn (intersection current new)))
    (dolist (item current)
      (if (member item isn)
	  (setq result (append result (list item)))))
    result))

;; find the package name of the symbol in string
;; note: we assume that the length of a symbol is less than 50
(defun find-package-name (symbol)
  (find-package-name-1 (format nil "~S" symbol)))
(defun find-package-name-1 (symbolInString)
  (let ((package-name (make-string 50 :initial-element #\Space))
	(found nil))
    (dotimes (count (length symbolInString) )
      (cond ((eq (aref symbolInString count) #\:)
	     (setq found 't))
	    (found nil)
	    (t ;; : not found yet
	     (setf (aref package-name count)
		   (aref symbolInString count)))))
    (if (null found)
	"EXPECT" ;; default is EXPECT package
      (string-right-trim '(#\Space) package-name)))
  )

(defun name-equal (name1 name2)
  (string-equal (format nil "~A" name1)
		(format nil "~A" name2)))
	    