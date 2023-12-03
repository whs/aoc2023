// [r, g, b]
local getColor(str, color) =
	local trimmed = std.stripChars(str, " ");
	if std.endsWith(trimmed, " " +color)
		then std.parseInt(std.split(trimmed, " ")[0])
		else 0;
local parseTurns(turnStr) = 
	local turns = std.split(turnStr, ",");
	local sumColor(color) = function(acc, str) acc + getColor(str, color);
	[
		std.foldl(sumColor("red"), turns, 0),
		std.foldl(sumColor("green"), turns, 0),
		std.foldl(sumColor("blue"), turns, 0),
	];
// parseGame(gameStr: str) -> {gameId: number, turns: [[r, g, b], ...]]
local parseGame(gameStr) =
	local parts = std.split(gameStr, ":");
	local gameId = std.parseInt(std.substr(parts[0], std.length("Game "), 999));
	local turns = std.split(parts[1], ";");
	{
		id: gameId,
		turns: std.map(parseTurns, turns),
	};
// isValidTurn(turnColor: [r, g, b]) -> bool
local isValidTurn(turnColor) =
	if turnColor[0] > 12 then false
	else if turnColor[1] > 13 then false
	else if turnColor[2] > 14 then false
	else true;
local isValidGame(turns) = std.foldl(
	function(acc, turn)
		if !acc then false
		else isValidTurn(turn),
	turns, true);
local sum(arr) = std.foldl(function(a, b) a+b, arr, 0);

local solve(problemStr) =
	local lines = std.split(problemStr, "\n");
	local parsedLines = std.map(parseGame, lines);
	local possibleGames = std.filter(function(game) isValidGame(game.turns), parsedLines);
	sum(std.map(function(game) game.id, possibleGames));

// part 2
local maxColor(turns) = std.foldl(
	function(acc, turn) [
		std.max(acc[0], turn[0]),
		std.max(acc[1], turn[1]),
		std.max(acc[2], turn[2]),
	],
	turns, [0, 0, 0]
);
local solve2(problemStr) =
	local lines = std.split(problemStr, "\n");
	local parsedLines = std.map(parseGame, lines);
	local gameMaxColors = std.map(function(game) maxColor(game.turns), parsedLines);
	sum(std.map(function(colors) colors[0] * colors[1] * colors[2], gameMaxColors));

local assertEq(a, b) = assert a == b : std.format("%s != %s", [a, b]); "pass";

{
	input:: std.stripChars(importstr "./input.txt", " \n"),
	part1: solve($.input),
	part2: solve2($.input),
	test:: {
		exampleProblem:: "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green",
		exampleGame:: "Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green",

		parseGame: assertEq(parseGame(self.exampleGame), {id: 1, turns: [[4, 0, 3], [1, 2, 6], [0, 2, 0]]}),
		isValidTurn: assertEq(isValidTurn([4, 0, 3]), true),
		isValidTurnR: assertEq(isValidTurn([13, 0, 0]), false),
		isValidTurnG: assertEq(isValidTurn([0, 14, 0]), false),
		isValidTurnB: assertEq(isValidTurn([0, 0, 15]), false),
		isValidGame: assertEq(isValidGame([[4, 0, 3], [1, 2, 6], [0, 2, 0]]), true),
		isValidGameR: assertEq(isValidGame([[4, 0, 3], [13, 0, 0]]), false),

		part1Example: assertEq(solve(self.exampleProblem), 8),

		maxColor: assertEq(maxColor([[4, 0, 3], [1, 2, 6], [0, 2, 0]]), [4, 2, 6]),

		part2Example: assertEq(solve2(self.exampleProblem), 2286),
	}
}
