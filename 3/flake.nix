{
	outputs = { nixpkgs, ... }: with builtins; let
		lib = nixpkgs.lib;
		pkgs = import nixpkgs { system = "x86_64-linux"; };
		input = readFile ./input.txt;
		exampleInput1 = readFile ./example.txt;
		isSymbol = v: ! (elem v ["." "0" "1" "2" "3" "4" "5" "6" "7" "8" "9"]);
		# Like foldl but op is called with (op acc index value)
		ifoldl0 = op: nul: list: foldl' (acc: i: op acc i (elemAt list i)) nul (genList (i: i) (length list));
		isSymbolAt = lines: row: col:
			let
				line = elemAt lines row;
				char = substring col 1 line;
			in 
				# This also handle overflows...
				if row < 0 then false
				else if col < 0 then false
				else if row >= length lines then false
				else if col >= stringLength line then false
				else isSymbol char;
		# Return [{number; col} ...]
		getNumbers = line: 
			let
				chars = lib.strings.stringToCharacters line;
				numbers = ifoldl0 (
					acc: index: char:
						let
							last = lib.lists.last acc;
						in if isSymbol char || char == "." then
							# If this is symbol, ensure that the last member of acc is [0]
							if last.col == -1 then acc
							else acc ++ [{number = 0; col = -1;}]
						else
							# This is a number, add it to the last number
							(lib.lists.init acc)
							++ [{
								number = (last.number*10) + (lib.strings.toInt char);
								col = if last.col != -1 then last.col else index;
							}]
				) [{number = 0; col = -1;}] chars;
			in
				# The last number might be invalid, remove it
				if (lib.lists.last numbers).col == -1 then lib.lists.init numbers
				else numbers;
		# Return [{number; col; row;} ..]
		getNumberLines = lines: lib.lists.flatten (lib.lists.imap0 (row: line: map (item: item // {inherit row;}) (getNumbers line)) lines);
		sumNumbers = numbers: foldl' (acc: cur: acc + cur.number) 0 numbers;
		filterNumberNextToSymbol = lines: numbers: filter (
			number: let
				_isSymbolAt = isSymbolAt lines;
				numberLen = stringLength (toString number.number);
				rowRange = lib.lists.range (number.col - 1) (number.col + numberLen);
			in any lib.trivial.id (lib.lists.flatten [
				# above row
				(map (col: _isSymbolAt (number.row - 1) col) rowRange)
				# left
				(_isSymbolAt number.row (number.col - 1))
				# right
				(_isSymbolAt number.row (number.col + numberLen))
				# bottom row
				(map (col: _isSymbolAt (number.row + 1) col) rowRange)
			])
		) numbers;
		solve1 = problem: let
			lines = lib.strings.splitString "\n" (lib.strings.removeSuffix "\n" problem);
			numbers = getNumberLines lines;
		in
			# numbers;
			# filterNumberNextToSymbol lines numbers;
			sumNumbers (filterNumberNextToSymbol lines numbers);

		getGearPositionsLine = line:
			filter
				(x: x != null)
				(
					lib.lists.imap0
					(i: ch: if ch == "*" then {col=i;} else null)
					(lib.strings.stringToCharacters line)
				);
		getGearPositions = lines: lib.lists.flatten (lib.lists.imap0 (row: line: map (item: item // {inherit row;}) (getGearPositionsLine line)) lines);
		# Return the number occupying the space at {row, col}
		getNumberAt = numbers: row: col: lib.lists.findFirst (
			number: let
				numberLen = stringLength (toString number.number);
			in
				number.row == row && number.col <= col && number.col + numberLen > col
		) null numbers;
		solve2 = problem: let
			lines = lib.strings.splitString "\n" (lib.strings.removeSuffix "\n" problem);
			numbers = getNumberLines lines;
			gears = getGearPositions lines;
			gearsNeighbors = map (
				gear: let
					_getNumberAt = getNumberAt numbers;
					neighbors = [
						(_getNumberAt (gear.row - 1) (gear.col - 1)) (_getNumberAt (gear.row - 1) (gear.col)) (_getNumberAt (gear.row - 1) (gear.col + 1))
						(_getNumberAt (gear.row    ) (gear.col - 1))                                          (_getNumberAt (gear.row    ) (gear.col + 1))
						(_getNumberAt (gear.row + 1) (gear.col - 1)) (_getNumberAt (gear.row + 1) (gear.col)) (_getNumberAt (gear.row + 1) (gear.col + 1))
					];
				in lib.lists.unique (lib.lists.remove null neighbors)
			) gears;
			correctGearNeighbors = filter (l: length l == 2) gearsNeighbors;
			# _dbgCorrectGearNeighbors = lib.debug.traceSeq (toJSON correctGearNeighbors) correctGearNeighbors;
			correctGearNeighborsRatio = map (x: (elemAt x 0).number * (elemAt x 1).number) correctGearNeighbors;
		in
			foldl' builtins.add 0 correctGearNeighborsRatio;
	in {
		part1 = pkgs.writeText "$out" "${toString (solve1 input)}";
		part2 = pkgs.writeText "$out" "${toString (solve2 input)}";
		test = assert !isSymbol ".";
			assert !isSymbol "0";
			assert !isSymbol "1";
			assert isSymbol "$";
			assert isSymbol "!";
			assert isSymbol "*";
			assert ifoldl0 (acc: i: elem: elem) 0 ["a" "b" "c"] == "c";
			assert ifoldl0 (acc: i: elem: i) 0 ["a" "b" "c"] == 2;
			assert lib.debug.traceValSeq (getNumbers "467..114..") == [{number = 467; col=0;} {number=114; col=5;}];
			assert lib.debug.traceValSeq (getNumbers "467..114") == [{number = 467; col=0;} {number=114; col=5;}];
			assert lib.debug.traceValSeq (getNumbers "..467..114..") == [{number = 467; col=2;} {number=114; col=7;}];
			assert lib.debug.traceValSeq (getNumberLines ["1.." "..2"]) == [{number = 1; col=0; row=0;} {number=2; col=2; row=1;}];
			assert getNumberAt [{number = 467; col=0; row = 0;} {number=114; col=5; row=0;}] 0 2 == {number = 467; col=0; row=0;};
			assert getNumberAt [{number = 268; col=5; row = 0;}] 0 4 == null;
			assert getNumberAt [{number = 514; col=1; row = 0;}] 0 4 == null;
			assert sumNumbers [{number = 467; col=0;} {number=114; col=5;}] == 467+114;
			assert isSymbolAt ["1.$" "..2"] 0 2;
			assert !isSymbolAt ["1.$" "..2"] 0 0;
			assert !isSymbolAt ["1.$" "..2"] (-1) 2;
			assert !isSymbolAt ["1.$" "..2"] 3 0;
			assert !isSymbolAt ["1.$" "..2"] 0 3;
			assert lib.debug.traceValSeq (getGearPositionsLine "...*......") == [{col=3;}];
			assert lib.debug.traceValSeq (solve1 exampleInput1) == 4361;
			assert lib.debug.traceValSeq (solve2 exampleInput1) == 467835;
			assert solve2 "2\n*\n2" == 4;
			assert solve2 "2.3\n.*." == 6;
			assert solve2 "2.3\n*.." == 0;
			assert solve2 "123\n.*.\n4.." == 123*4;
			assert solve2 "123*345" == 123*345;
			assert solve2 "#514.268\n.....*..\n...305.." == 268*305;
			pkgs.writeText "$out" "true";
	};
}
