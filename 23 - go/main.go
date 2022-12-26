package main

import (
	"fmt"
	"log"
	"math"
	"os"
)

type Point struct {
	x int
	y int
}

const (
	dir_n = iota
	dir_s = iota
	dir_w = iota
	dir_e = iota
)

func parse_input(content []byte) []Point {
	elves := make([]Point, 0)
	y := 0
	x := 0
	for _, b := range content {
		switch b {
		case '\n':
			x, y = -1, y+1
		case '#':
			elves = append(elves, Point{x: x, y: y})
		}
		x += 1
	}
	return elves
}

func make_elf_map(elves []Point) map[Point]int {
	m := make(map[Point]int)
	for _, elf := range elves {
		m[elf] += 1
	}
	return m
}

func make_proposals(elves []Point, elf_map map[Point]int, first_dir int) []Point {
	proposals := make([]Point, 0)
ELF_LOOP:
	for _, elf := range elves {
		nw := elf_map[Point{x: elf.x - 1, y: elf.y - 1}]
		n := elf_map[Point{x: elf.x, y: elf.y - 1}]
		ne := elf_map[Point{x: elf.x + 1, y: elf.y - 1}]
		w := elf_map[Point{x: elf.x - 1, y: elf.y}]
		e := elf_map[Point{x: elf.x + 1, y: elf.y}]
		sw := elf_map[Point{x: elf.x - 1, y: elf.y + 1}]
		s := elf_map[Point{x: elf.x, y: elf.y + 1}]
		se := elf_map[Point{x: elf.x + 1, y: elf.y + 1}]
		if (nw == 0) && (n == 0) && (ne == 0) && (w == 0) &&
			(e == 0) && (sw == 0) && (s == 0) && (se == 0) {
			proposals = append(proposals, elf)
			continue
		}
		for try_dir := first_dir; try_dir < first_dir+4; try_dir++ {
			if (try_dir%4 == dir_n) && (nw == 0) && (n == 0) && (ne == 0) {
				proposals = append(proposals, Point{x: elf.x, y: elf.y - 1})
				continue ELF_LOOP
			}
			if (try_dir%4 == dir_s) && (sw == 0) && (s == 0) && (se == 0) {
				proposals = append(proposals, Point{x: elf.x, y: elf.y + 1})
				continue ELF_LOOP
			}
			if (try_dir%4 == dir_w) && (nw == 0) && (w == 0) && (sw == 0) {
				proposals = append(proposals, Point{x: elf.x - 1, y: elf.y})
				continue ELF_LOOP
			}
			if (try_dir%4 == dir_e) && (ne == 0) && (e == 0) && (se == 0) {
				proposals = append(proposals, Point{x: elf.x + 1, y: elf.y})
				continue ELF_LOOP
			}

		}
		proposals = append(proposals, elf)
	}
	return proposals
}

func move_elves(elves []Point, proposals []Point, proposals_map map[Point]int) []Point {
	moves := make([]Point, 0)
	for i, elf := range elves {
		if proposals_map[proposals[i]] == 1 {
			moves = append(moves, proposals[i])
		} else {
			moves = append(moves, elf)
		}
	}
	return moves
}

func elf_rect(elves []Point) (int, int, int, int) {
	min_x, min_y, max_x, max_y := math.MaxInt, math.MaxInt, 0, 0
	for _, elf := range elves {
		if elf.x < min_x {
			min_x = elf.x
		}
		if elf.x > max_x {
			max_x = elf.x
		}
		if elf.y < min_y {
			min_y = elf.y
		}
		if elf.y > max_y {
			max_y = elf.y
		}
	}
	return min_x, min_y, max_x, max_y
}

func draw_map(elves []Point) {
	min_x, min_y, max_x, max_y := elf_rect(elves)
	m := make_elf_map(elves)
	for j := min_y; j <= max_y; j++ {
		for i := min_x; i <= max_x; i++ {
			if m[Point{x: i, y: j}] > 0 {
				fmt.Print("#")
			} else {
				fmt.Print(".")
			}
		}
		fmt.Println()
	}
}

func points_equal(a, b []Point) bool {
	if len(a) != len(b) {
		return false
	}
	for i, v := range a {
		if v != b[i] {
			return false
		}
	}
	return true
}

func main() {
	content, err := os.ReadFile("input.txt")
	if err != nil {
		log.Fatal(err)
	}
	elves := parse_input(content)
	fmt.Println()
	draw_map(elves)
	first_dir := dir_n
	i := 0
	for {
		m := make_elf_map(elves)
		p := make_proposals(elves, m, first_dir)
		pm := make_elf_map(p)
		new_elves := move_elves(elves, p, pm)
		if points_equal(elves, new_elves) {
			fmt.Println("No movement at round: ", i+1)
			break
		}
		elves = new_elves
		i += 1
		first_dir += 1
		if first_dir > dir_e {
			first_dir = dir_n
		}

		if i == 10 {
			min_x, min_y, max_x, max_y := elf_rect(elves)
			rect_size := (max_x - min_x + 1) * (max_y - min_y + 1)
			part1 := rect_size - len(elves)
			fmt.Println("Part 1: ", part1)
		}
	}
}
