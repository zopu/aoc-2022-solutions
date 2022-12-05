(load "~/quicklisp/setup.lisp")
(ql:quickload "str")
(ql:quickload "cl-ppcre")

(defparameter *input_file* (uiop:read-file-lines #p"input.txt"))

(defparameter empty-stacks '(() () () () () () () () ()))

(defun split-input-file (stack-lines other-lines)
  ; Will return two lists
  ; First will be the lines with the initial stack
  ; Second will be the lines with moves
  (if (equal "" (str:trim (car other-lines)))
      (list stack-lines (cdr other-lines))
      (split-input-file
        (append stack-lines (list (car other-lines)))
        (cdr other-lines))))

(defun nth-char (n str)
  ; Will return nil if n >= len(str)
  (if (>= n (length str)) nil (subseq str n (+ n 1))))

(defun parse-stack-line (stack-line)
  (mapcar (lambda (char) (if (equal char " ") nil char))
      (mapcar (lambda (n) (nth-char n stack-line))
          '(1 5 9 13 17 21 25 29 33))))

(defun parse-stacks (stack-lines-with-footer)
  ; Remove footer
  (let ((stack-lines (reverse (cdr (reverse stack-lines-with-footer)))))
    (mapcar #'parse-stack-line stack-lines)))

(defun push-onto-stacks (stacks additions)
  ; additions should be a list of (nil|char) detailing what should be pushed
  (mapcar (lambda (stack) (remove nil stack))
      (mapcar #'cons additions stacks)))

(defparameter *init-state* (reduce #'push-onto-stacks
                               (reverse (parse-stacks (first (split-input-file '() *input_file*))))
                             :initial-value empty-stacks))

; Returns three numbers (n, from, to)
(defun parse-move-line (line)
  (mapcar (lambda (n) (parse-integer n))
      (ppcre:all-matches-as-strings "[0-9]+" line)))

(parse-move-line "move 24 from 3 to 9")

(defun parse-moves (lines)
  (mapcar #'parse-move-line lines))

(defparameter *move-triples* (parse-moves (second (split-input-file '() *input_file*))))
