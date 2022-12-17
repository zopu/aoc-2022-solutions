#!/usr/bin/ruby

shapes = [
    [0, 1, 2, 3],
    [1, 7, 8, 9, 15],
    [0, 1, 2, 9, 16],
    [0, 7, 14, 21],
    [0, 1, 7, 8]
]

class Tetromino
    def initialize (shape, row_bottom)
        @pos = row_bottom * 7 + 2
        @shape = shape.dup
        @width = shape.map{ |o| o % 7 }.max()
        @height = shape.map{ |o| o / 7 }.max()
    end

    def top()
        row = @pos / 7
        return row + @height
    end

    def draw(grid)
        @shape.each { |p|
            pixel = @pos + p
            grid[pixel] = 1
        }
    end

    def maybe_move_left(grid)
        if @pos % 7 == 0
            return
        end
        # Collision: No move
        @shape.each do |offset|
            if grid[(@pos - 1) + offset] > 0
                return
            end
        end
        @pos -= 1
        return
    end

    def maybe_move_right(grid)
        if (@pos + @width) % 7 == 6
            return
        end
        # Collision: No move
        @shape.each do |offset|
            if grid[@pos + 1 + offset] > 0
                return
            end
        end

        @pos += 1
        return
    end

    def maybe_move_down(grid)        
        # Will return false if the tet cannot be moved down
        if @pos < 7
            return false
        end
        newpos = @pos - 7
        @shape.each do |offset|
            if grid[newpos + offset] > 0
                return false
            end
        end
        @pos -= 7
        return true
    end
end


def print_grid(grid, height)
    (height + 4).downto(0).each { |i|
        row_start = i * 7
        (0..6).each { |j|
            if grid[row_start + j] > 0
                print '#'
            else
                print '.'
            end
        }
        print "\n"
    }
end

def tick(tet, grid, instruction)
    if instruction == '<'
        tet.maybe_move_left(grid)
    end
    if instruction == '>'
        tet.maybe_move_right(grid)
    end
    return tet.maybe_move_down(grid)
end

gas = File.read("input.txt").split('')
gas_idx = 0

ITERS = 100000

grid = Array.new(ITERS * 6 * 7) { |z| 0 }
grid_height = 0

height_at_n = Array.new(ITERS) { |z| 0 }

tet = Tetromino.new(shapes[0], grid_height + 3)
next_shape = 1
shape_count = 0
while true
    if !tick(tet, grid, gas[gas_idx])
        tet.draw(grid)
        grid_height = [grid_height, tet.top + 1].max()
        tet = Tetromino.new(shapes[next_shape], grid_height + 3)
        shape_count += 1
        if shape_count % 100000 == 0
            print "."
        end
        if shape_count % 1000000 == 0
            puts ""
        end
        height_at_n[shape_count] = grid_height
        if shape_count == 2022
            puts "Part 1: %d" % [grid_height]
        end
        if shape_count == ITERS
            break
        end
        next_shape += 1
        if next_shape >= shapes.length()
            next_shape = 0
        end
    end
    gas_idx += 1
    if gas_idx >= gas.length()
        gas_idx = 0
    end
end

height_grad = height_at_n.dup
(0..(height_grad.length() - 1)).each{ |i|
    if i != 0
        height_grad[i] = height_at_n[i] - height_at_n[i - 1]
    end
}

def find_repetition(height_grad)
    repetition_max = 0
    (0..10000).each { |init|
        hg = height_grad[init..]
        (2..10000).each { |steps|
            hg_shifted = hg[steps..]
            hg_trunc = hg[0..(hg_shifted.length() - 1)]
            if hg_shifted.length() != hg_trunc.length
                puts "oops"
            end
            if hg_shifted == hg_trunc
                increase = hg[0..(steps - 1)].sum()
                return [init, increase, steps]
            end
        }
    }
end

init, increase, steps = find_repetition(height_grad)
puts "After %d, increases %d every %d" % [init, increase, steps]

steps_after_init = 1_000_000_000_000 - init
main_increase = steps_after_init / steps * increase
last_steps = steps_after_init % steps
last_increase = height_at_n[last_steps + init] - height_at_n[init]

puts height_at_n[init] + main_increase + last_increase