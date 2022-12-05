(load "input_parsing.lisp")

(defun popn (stacks n)
  ; Returns stacks with the top of stack n (zero-indexed) popped
  (let ((iota (loop for i below 10 collect i)))
    (mapcar (lambda (stack i) (if (= i n) (cdr stack) stack))
        stacks
      iota)))

(defun pushn (stacks n item)
  ; Returns stacks with the top of stack n (zero-indexed) popped
  (let ((iota (loop for i below 10 collect i)))
    (mapcar (lambda (stack i) (if (= i n) (cons item stack) stack))
        stacks
      iota)))

(defun make-move (stacks from to)
  (let* ((i (- from 1))
         (j (- to 1))
         (item (first (nth i stacks)))
         (stacks-popped (popn stacks i)))
    (pushn stacks-popped j item)))

(make-move *init-state* 1 3)

(defun make-n-moves (stacks n from to)
    (if (<= n 0)
        stacks
        (make-n-moves (make-move stacks from to) (- n 1) from to)))

(make-n-moves *init-state* 2 1 3)

(defun process-moves (init move-list)
    (if (equal () move-list)
        init
        (process-moves
            (make-n-moves init (first (car move-list)) (second (car move-list)) (third (car move-list)))
            (cdr move-list))))

; Part 1
(print (mapcar #'first (process-moves *init-state* *move-triples*)))