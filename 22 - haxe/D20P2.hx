enum GridCell {
	Void;
	Open;
	Wall;
}

enum CubeCell {
	A;
	B;
	C;
	D;
	E;
	F;
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

	public function print_with_log(log:Array<Status>) {
		var vec = new haxe.ds.Vector(this.w * this.h);
		for (n in 0...(this.w * this.h)) {
			vec[n] = 0;
		}
		var y = 0;
		for (l in this.lines) {
			var x = 0;
			for (c in new haxe.iterators.StringIterator(l)) {
				vec[y * this.w + x] = c;
				++x;
			}
			++y;
		}
		for (pos in log) {
			var symbol = ' ';
			switch pos.facing {
				case 0:
					symbol = '>';
				case 1:
					symbol = 'v';
				case 2:
					symbol = '<';
				case 3:
					symbol = '^';
			}
			vec[pos.y * this.w + pos.x] = symbol.charCodeAt(0);
		}
		for (j in 0...this.h) {
			for (i in 0...this.w) {
				Sys.stdout().writeString(String.fromCharCode(vec[j * this.w + i]));
			}
			Sys.stdout().writeString("\n");
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
		return {min: min_x, max: max_x};
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
		return {min: min_y, max: max_y};
	}

	function edge_position(cell:CubeCell, along_edge:Int, facing:Int):{x:Int, y:Int} {
		switch cell {
			case A:
				{
					if (facing == 0) { // Right
						return {x: 50, y: 49 - along_edge};
					} else { // Down
						return {x: 50 + along_edge, y: 0};
					}
				}
			case B:
				{
					if (facing == 3) { // Up
						return {x: 100 + along_edge, y: 49};
					} else if (facing == 2) { // Left
						return {x: 149, y: 49 - along_edge};
					} else { // Down
						return {x: 100 + along_edge, y: 0};
					}
				}
			case C:
				{
					if (facing == 0) { // Right
						return {x: 50, y: 50 + along_edge};
					} else { // Left
						return {x: 99, y: 50 + along_edge};
					}
				}
			case D:
				{
					if (facing == 3) { // Up
						return {x: 50 + along_edge, y: 149};
					} else { // Left
						return {x: 99, y: 149 - along_edge};
					}
				}
			case E:
				{
					if (facing == 0) { // Right
						return {x: 0, y: 149 - along_edge};
					} else { // Down
						return {x: along_edge, y: 100};
					}
				}
			case F:
				{
					if (facing == 0) { // Right
						return {x: 0, y: 150 + along_edge};
					} else if (facing == 3) { // Up
						return {x: along_edge, y: 199};
					} else { // Left
						return {x: 49, y: 150 + along_edge};
					}
				}
		}
		return new Status(0, 0);
	}

	public function maybe_teleport(status: Status, cell:CubeCell, along_edge:Int, facing:Int) {
		// trace('Maybe teleporting to cell $cell');
		var ep = edge_position(cell, along_edge, facing);
		if (this.cell(ep.x, ep.y) == Open) {
			status.x = ep.x;
			status.y = ep.y;
			status.facing = facing;
		}
	}

	public function maybe_teleport_up(status:Status) {
		var along_edge = status.x % 50;
		var to_cell:CubeCell = C;
		var facing = 0; // Right
		if (status.x >= 50) {
			to_cell = F;
		}
		if (status.x >= 100) {
			facing = 3; // Up
		}
		maybe_teleport(status, to_cell, along_edge, facing);
	}

	public function maybe_teleport_down(status:Status) {
		var along_edge = status.x % 50;
		var to_cell:CubeCell = B;
		var facing = 1; // Down
		if (status.x >= 50 && status.x < 100) {
			to_cell = F;
		}
		if (status.x >= 100) {
			to_cell = C;
		}
		if (status.x >= 50) {
			facing = 2; // Left
		}
		maybe_teleport(status, to_cell, along_edge, facing);
	}

	public function maybe_teleport_left(status:Status) {
		var along_edge = status.y % 50;
		var to_cell:CubeCell = E;
		var facing = 0; // Right
		if (status.y >= 100) {
			to_cell = A;
		}
		if ((status.y >= 50 && status.y < 100) || status.y >= 150) {
			facing = 1; // Down
		}
		maybe_teleport(status, to_cell, along_edge, facing);
	}

	public function maybe_teleport_right(status:Status) {
		var along_edge = status.y % 50;
		var to_cell:CubeCell = D;
		var facing = 2; // Left
		if (status.y >= 50 && status.y < 150) {
			to_cell = B;
		}
		if ((status.y >= 50 && status.y < 100) || status.y >= 150) {
			facing = 3; // Up
		}
		maybe_teleport(status, to_cell, along_edge, facing);
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

	public function copy() {
		var s = new Status(this.x, this.y);
		s.facing = this.facing;
		return s;
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

class D20P2 {
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
						grid.maybe_teleport_right(status);
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
						grid.maybe_teleport_down(status);
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
						grid.maybe_teleport_left(status);
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
						grid.maybe_teleport_up(status);
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
		var log = [];
		var x = grid.starting_x();
		var status = new Status(x, 0);
		log.push(status.copy());
		var count = 0;
		for (i in instructions) {
			// trace('Instruction: $i');
			switch i {
				case L:
					{
						status.rotate_l();
						log.push(status.copy());
						// log.push({x: status.x, y: status.y, facing: status.facing});
					}
				case R:
					{
						status.rotate_r();
						log.push(status.copy());
						// log.push({x: status.x, y: status.y, facing: status.facing});
					}
				case Move(d):
					{
						// trace("Moving");
						for (n in 0...d) {
							move(status, grid);
							log.push(status.copy());
							// log.push({x: status.x, y: status.y, facing: status.facing});
						}
						// trace('New position: ${status.x} , ${status.y}');
					}
			}
			if (count == 200) {
				
			}
			++count;
		}
		grid.print_with_log(log);

		trace('Final position: ${status.x}, ${status.y}. Facing ${status.facing}');
		var score = (1000 * (status.y + 1)) + (4 * (status.x + 1)) + status.facing;
		trace('Score: $score');
	}

	static public function main() {
		var pf = parse_file(sys.io.File.getContent('input.txt'));
		follow_path(pf.grid, pf.instructions);
	}
}
