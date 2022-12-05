(load "input_parsing.lisp")

(defun popn (stacks n m)
  ; Returns stacks with the top m elements of stack n (zero-indexed) popped
  (let ((iota (loop for i below 10 collect i)))
    (mapcar (lambda (stack i) (if (= i n) (subseq stack m) stack))
        stacks
      iota)))

(popn *init-state* 1 2)

(defun pushn (stacks n items)
  ; Returns stacks with items added to top of stack n (zero-indexed) popped
  (let ((iota (loop for i below 10 collect i)))
    (mapcar (lambda (stack i) (if (= i n) (append items stack) stack))
        stacks
      iota)))

(defun make-n-moves (stacks n from to)
  stacks
  (pushn (popn stacks (- from 1) n) (- to 1) (subseq (nth (- from 1) stacks) 0 n)))

(make-n-moves *init-state* 2 1 3)

(defun process-moves (init move-list)
  (if (equal () move-list)
      init
      (process-moves
        (make-n-moves init (first (car move-list)) (second (car move-list)) (third (car move-list)))
        (cdr move-list))))

; Part 2
(print (mapcar #'first (process-moves *init-state* *move-triples*)))