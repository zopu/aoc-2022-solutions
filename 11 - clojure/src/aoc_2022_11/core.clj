(ns aoc-2022-11.core
  (:require [clojure.java.io :as io]
            [clojure.string :as str]))

(def input_sm (slurp (io/resource "input_sm.txt")))
(def input (slurp (io/resource "input.txt")))

(defn parse-monkey [lines]
  [(into [] (map #(Integer/parseInt %)
                 (map (partial re-find #"-?[0-9]+")
                      (str/split (nth lines 1), #","))))   ; Starting items
   [(rest (re-find #"(old|[0-9]+) ([*+]) (old|[0-9]+)" (nth lines 2)))  ; Operation
    (Integer/parseInt (re-find #"-?[0-9]+" (nth lines 3)))  ; Divisibility test
    (Integer/parseInt (re-find #"-?[0-9]+" (nth lines 4)))  ; If true throw to
    (Integer/parseInt (re-find #"-?[0-9]+" (nth lines 5)))]])  ; If false throw to

(defn process-op [op n]
  (let [operator (if (= (nth op 1) "+") #'+ #'*)
        opa (if (= (nth op 0) "old") n (Integer/parseInt (nth op 0)))
        opb (if (= (nth op 2) "old") n (Integer/parseInt (nth op 2)))]
    (operator opa opb)))

; Returns a pair:
;   1st - the monkey the item should be thrown to
;   2nd - the new worry level
(defn monkey-around [modulo monkey worry-level]
  (let [[op divtest iftrue iffalse] monkey
        new-worry-level
        (mod (process-op op worry-level) modulo)]
    (if (= 0 (int (mod new-worry-level divtest)))
      [iftrue new-worry-level]
      [iffalse new-worry-level])))

; returns [init-state monkeys]
(defn parse-input [input]
  (let [parsed (map parse-monkey (partition 7 (conj (str/split-lines input) "")))]
    [(vec (map first parsed)) (map second parsed)]))

(defn pushn [list-of-vecs n item]
  (map-indexed (fn [idx v] (if (= idx n) (conj v item) v)) list-of-vecs))

;; Returns the nth vector and clears it from the list of vectors
(defn popv [list-of-vecs n]
  [(nth list-of-vecs n)
   (map-indexed (fn [idx v] (if (= idx n) '[] v)) list-of-vecs)])

;; Adds x to number n in list
(defn add-to-n [list-of-counts n x]
  (map-indexed (fn [idx c] (if (= idx n) (+ c x) c)) list-of-counts))

(defn one-monkey-turn [modulo monkey state items]
  (if (empty? items)
    state
    (let [[to newlevel] (monkey-around modulo monkey (first items))
          newstate (pushn state to newlevel)]
      (one-monkey-turn modulo monkey newstate (rest items)))))

;; "State" from here on will mean a pair of (counts, world state)
;; where counts is what counting the number of items each monkey have inspected
;; and world state is the list of items each monkey has to inspect
(defn one-round [modulo init-state monkeys]
  (reduce (fn [state idx]
            (let [[items popped-state] (popv (second state) idx)]
              [(vec (add-to-n (first state) idx (count items)))
               (vec (one-monkey-turn modulo (nth monkeys idx) popped-state items))]))
          init-state (range 0 (count monkeys))))

(defn do-n-rounds [n modulo init-state monkeys]
  (reduce (fn [state _idx] (one-round modulo state monkeys))
          init-state (range 0 n)))

(defn solution []
  (let [[init-state monkeys] (parse-input input)
        modulo (reduce * (map #'second monkeys))
        [counts _] (do-n-rounds 10000 modulo [(repeat (count monkeys) 0) init-state] monkeys)]
    (println (reduce * (take 2 (reverse (sort counts)))))))

(defn -main
  "AOC 2022 Day 11 solution"
  [& _args]
  (solution))
