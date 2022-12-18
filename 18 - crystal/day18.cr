GRID_SIZE = 22
AIR       =  0
LAVA      =  1
WATER     =  2

grid = Array.new(GRID_SIZE) { |i| Array.new(GRID_SIZE) { |j| Array.new(GRID_SIZE) { |k| 0 } } }
cubes = File.read_lines("input.txt").map { |l| l.split(',').map { |s| s.to_i } }

cubes.each { |cube| grid[cube[0]][cube[1]][cube[2]] = LAVA }

def count_touching_sides(c, grid, material)
  sum = 0
  sum += 1 if c[0] <= 0 || grid[c[0] - 1][c[1]][c[2]] == material
  sum += 1 if c[0] >= (GRID_SIZE - 1) || grid[c[0] + 1][c[1]][c[2]] == material
  sum += 1 if c[1] <= 0 || grid[c[0]][c[1] - 1][c[2]] == material
  sum += 1 if c[1] >= (GRID_SIZE - 1) || grid[c[0]][c[1] + 1][c[2]] == material
  sum += 1 if c[2] <= 0 || grid[c[0]][c[1]][c[2] - 1] == material
  sum += 1 if c[2] >= (GRID_SIZE - 1) || grid[c[0]][c[1]][c[2] + 1] == material
  return sum
end

def add_water_at_edges(grid)
  (0..GRID_SIZE - 1).each { |i|
    (0..GRID_SIZE - 1).each { |j|
      if grid[0][i][j] == AIR
        grid[0][i][j] = WATER
      end
      if grid[GRID_SIZE - 1][i][j] == AIR
        grid[GRID_SIZE - 1][i][j] = WATER
      end
      if grid[i][0][j] == AIR
        grid[i][0][j] = WATER
      end
      if grid[i][GRID_SIZE - 1][j] == AIR
        grid[i][GRID_SIZE - 1][j] = WATER
      end
      if grid[i][j][0] == AIR
        grid[i][j][0] = WATER
      end
      if grid[i][j][GRID_SIZE - 1] == AIR
        grid[i][j][GRID_SIZE - 1] = WATER
      end
    }
  }
end

def spread_water(grid)
  flood_count = 0
  (0..GRID_SIZE - 1).each { |i|
    (0..GRID_SIZE - 1).each { |j|
      (0..GRID_SIZE - 1).each { |k|
        if grid[i][j][k] == AIR
          flood = false
          flood = true if i <= 0 || grid[i - 1][j][k] == WATER
          flood = true if i >= (GRID_SIZE - 1) || grid[i + 1][j][k] == WATER
          flood = true if j <= 0 || grid[i][j - 1][k] == WATER
          flood = true if j >= (GRID_SIZE - 1) || grid[i][j + 1][k] == WATER
          flood = true if k <= 0 || grid[i][j][k - 1] == WATER
          flood = true if k >= (GRID_SIZE - 1) || grid[i][j][k + 1] == WATER
          if flood
            grid[i][j][k] = WATER
            flood_count += 1
          end
        end
      }
    }
  }
  return flood_count
end

part1 = cubes.map { |c| count_touching_sides(c, grid, AIR) }.sum
puts "Part 1: %d" % [part1]

add_water_at_edges(grid)
while spread_water(grid) > 0
end

part2 = cubes.map { |c| count_touching_sides(c, grid, WATER) }.sum
puts "Part 2: %d" % [part2]
