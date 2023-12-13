<?php
$input = trim(file_get_contents($argv[1]));
$input = explode("\n\n", $input);

function solve1H(array $problem): int {
	for($i = 0; $i < count($problem) - 1; $i++){
		if (!isReflection($problem, $i)) {
			continue;
		}
		return $i;
	}

	return -1;
}

function isReflection(array $problem, int $point): bool {
	$upDistance = $point;
	$downDistance = count($problem) - 1 - 1 - $point;
	$maxDistance = min($upDistance, $downDistance);
	echo "start up $upDistance down $downDistance\n";
	$foundSmudge = false; // true for part 1
	for($i = 0; $i <= $maxDistance; $i++){
		$diff = lineDiff($problem[$point - $i], $problem[$point + 1 + $i]);
		echo "\trow " . ((string) $point-$i) . " vs row " . ((string) $point+1+$i) . " diff $diff smudge $foundSmudge\n";
		if (!$foundSmudge && $diff == 1) {
			$foundSmudge = true;
		}else if ($diff != 0) {
			return false;
		}
	}
	return $foundSmudge;
}

function lineDiff(string $a, string $b): int {
	$out = 0;
	for($i = 0; $i < strlen($a); $i++) {
		if($a[$i] != $b[$i]) {
			$out++;
		}
	}
	return $out;
}

function rotateCW(array $problem): array {
	$out = [];
	$height = count($problem) - 1;
	for($i = 0; $i < count($problem); $i++){
		for($j = 0; $j < strlen($problem[$i]); $j++){
			$out[$j][$height - $i] = $problem[$i][$j];
		}
	}
	for($i = 0; $i < count($out); $i++){
		// the array is still keyed, need to sort first...
		ksort($out[$i], SORT_NUMERIC);
		$out[$i] = implode("", $out[$i]);
	}
	return $out;
}

function printProblem(array $problem) {
	foreach($problem as $line){
		echo $line."\n";
	}
}

$accum = 0 ;
foreach($input as $i => $problem) {
	echo "problem $i\n";
	$lines = explode("\n", $problem);
	$reflection = solve1H($lines);

	if($reflection == -1){
		echo "\tchecking V\n";
		$rotated = rotateCW($lines);
		// printProblem($rotated);
		// it is a vertical line
		$reflection = solve1H($rotated);
		if ($reflection == -1) {
			throw new Error("no solution for problem $i");
		}
		echo "\treflection V $reflection\n";
		$accum += $reflection + 1;
	}else{
		echo "\treflection H $reflection\n";
		// it is a horizontal line
		$accum += ($reflection + 1) * 100;
	}
}

echo $accum . "\n";
