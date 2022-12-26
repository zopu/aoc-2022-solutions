enum GridCell {
	Void;
	Open;
	Wall;
}

class Grid {
	public var w:Int;
	public var h:Int;

	var lines:haxe.ds.Vector<String>;

	public function new(lines) {
		this.h = lines.length;
		this.lines = new haxe.ds.Vector(lines.length);
		this.w = 0;
		for (i in 0...lines.length) {
			if (lines[i].length > this.w) {
				this.w = lines[i].length;
			}
			this.lines[i] = lines[i];
		}
	}

	public function print() {
		for (l in this.lines) {
			trace(l);
		}
	}

	public function cell(x, y) {
		if (x < 0 || x >= this.w || y < 0 || y >= this.h) {
			return Void;
		}
		if (this.lines[y].charAt(x) == '#') {
			return Wall;
		}
		if (this.lines[y].charAt(x) == '.') {
			return Open;
		}
		return Void;
	}

	public function starting_x() {
		for (i in 0...lines[0].length) {
			if (this.lines[0].charAt(i) == '.') {
				return i;
			}
		}
		return -1;
	}

    public function x_bounds(y) {
        var min_x = 0;
		for (i in 0...lines[y].length) {
			if (this.lines[y].charAt(i) != ' ') {
				min_x = i;
                break;
			}
		}
        var max_x = lines[y].length - 1;
        for (i in 0...lines[y].length) {
			if (this.lines[y].charAt(lines[y].length - i - 1) != ' ') {
				max_x = lines[y].length - i - 1;
                break;
			}
		}
		return { min: min_x, max: max_x };
	}

    public function y_bounds(x) {
        var min_y = 0;
		for (i in 0...lines.length) {
            if (this.lines[i].length <= x) {
                continue;
            }
			if (this.lines[i].charAt(x) != ' ') {
				min_y = i;
                break;
			}
		}
        var max_y = lines.length - 1;
        for (i in 0...lines.length) {
            if (this.lines[lines.length - i - 1].length <= x) {
                continue;
            }
			if (this.lines[lines.length - i - 1].charAt(x) != ' ') {
				max_y = lines.length - i - 1;
                break;
			}
		}
		return { min: min_y, max: max_y };
	}
}

enum Instruction {
	L;
	R;
	Move(distance:Int);
}

class ParsedFile {
	public var grid:Grid;
	public var instructions:Array<Instruction>;

	public function new(grid, instructions) {
		this.grid = grid;
		this.instructions = instructions;
	}
}

class Status {
	public var facing:Int; // 0: Right, 1: Down, 2: Left, 3: Right
	public var x:Int;
	public var y:Int;

	public function new(x, y) {
		this.x = x;
		this.y = y;
		this.facing = 0;
	}

	public function rotate_l() {
		--this.facing;
		if (this.facing < 0) {
			this.facing = 3;
		}
	}

	public function rotate_r() {
		++this.facing;
		if (this.facing > 3) {
			this.facing = 0;
		}
	}
}

class D20 {
	static function string_to_instruction(s) {
		switch s {
			case "L":
				return L;
			case "R":
				return R;
			default:
				return Move(Std.parseInt(s));
		}
	}

	static function parse_file(content:String) {
		var lines = content.split("\n");
		var grid = new Grid(lines.slice(0, lines.length - 2));
		var w = grid.w;
		var h = grid.h;
		trace('Grid $w x $h');
		grid.print();
		var instruction_line = lines[lines.length - 1];

		var r = ~/([0-9]+|R|L)/;
		var instructions = [];
		var input = instruction_line;
		while (r.match(input)) {
			instructions.push(string_to_instruction(r.matched(1)));
			input = r.matchedRight();
		}
		return new ParsedFile(grid, instructions);
	}

	static function move(status:Status, grid:Grid) {
        var x = status.x;
        var y = status.y;
		switch status.facing {
			case 0: // Right
				{
                    // trace("Moving right");
                    var bounds = grid.x_bounds(status.y);
                    if (x == bounds.max) {
                        if (grid.cell(bounds.min, y) == Open) {
                            status.x = bounds.min;
                        }
                        return;
                    }
                    if (grid.cell(x + 1, y) == Open) {
                        status.x += 1;
                    }
                    return;
                }
			case 1: // Down
				{
                    // trace("Moving down");
                    var bounds = grid.y_bounds(status.x);
                    if (y == bounds.max) {
                        if (grid.cell(x, bounds.min) == Open) {
                            status.y = bounds.min;
                        }
                        return;
                    }
                    if (grid.cell(x, y + 1) == Open) {
                        status.y += 1;
                    }
                    return;
                }
			case 2: // Left
				{
                    // trace("Moving left");
                    var bounds = grid.x_bounds(status.y);
                    if (x == bounds.min) {
                        if (grid.cell(bounds.max, y) == Open) {
                            status.x = bounds.max;
                        }
                        return;
                    }
                    if (grid.cell(x - 1, y) == Open) {
                        status.x -= 1;
                    }
                    return;
                }
			case 3: // Up
				{
                    // trace("Moving up");
                    var bounds = grid.y_bounds(status.x);
                    if (y == bounds.min) {
                        if (grid.cell(x, bounds.max) == Open) {
                            status.y = bounds.max;
                        }
                        return;
                    }
                    if (grid.cell(x, y - 1) == Open) {
                        status.y -= 1;
                    }
                    return;
                }
		}
	}

	static function follow_path(grid:Grid, instructions:Array<Instruction>) {
		var x = grid.starting_x();
        trace('Starting x: $x');
		var status = new Status(x, 0);
		for (i in instructions) {
			// trace('Instruction: $i');
			switch i {
				case L:
					status.rotate_l();
				case R:
					status.rotate_r();
				case Move(d):
					{
                        // trace("Moving");
						for (n in 0...d) {							
                            move(status, grid);
						}
                        // trace('New position: ${status.x} , ${status.y}');
					}
			}
		}
        trace('Final position: ${status.x}, ${status.y}. Facing ${status.facing}');
        var score = (1000 * (status.y + 1)) + (4 * (status.x + 1)) + status.facing;
        trace('Score: $score');
	}

	static public function main() {
		var pf = parse_file(sys.io.File.getContent('input.txt'));
		follow_path(pf.grid, pf.instructions);
	}
}
