package main

import (
	"bytes"
	"fmt"
	"io"
	"os"
	"slices"
	"strings"
)

func main() {
	input, err := io.ReadAll(os.Stdin)
	if err != nil {
		panic(err)
	}
	fmt.Println("start")

	problem := parse(input)
	// part 1
	//for shiftUp(problem) {
	//}

	// part 2
	steps := make([]string, 0, 10000)
	steps = append(steps, problemToString(problem))
	var repeatingIndex int
	iterationLeft := 0
	iterationCount := 1000000000
	for i := 0; i < iterationCount; i++ {
		spinCycle(problem)
		if i%1_000_000 == 0 {
			fmt.Printf("cycle %d\n", i)
		}
		problemString := problemToString(problem)
		repeatingIndex = slices.Index(steps, problemString)
		if repeatingIndex != -1 {
			fmt.Printf("found cycle at %d - %d\n", repeatingIndex, i)
			iterationLeft = iterationCount - i - 1
			break
		}
		steps = append(steps, problemString)
	}

	// at the break, problem == steps[repeatingIndex]
	patternLength := len(steps) - repeatingIndex
	problem = parse([]byte(steps[repeatingIndex+(iterationLeft%patternLength)]))

	fmt.Println(problemToString(problem))
	fmt.Println(countLoad(problem))
}

func problemToString(p [][]byte) string {
	var out strings.Builder
	for _, l := range p {
		out.Write(l)
		out.WriteRune('\n')
	}
	return out.String()
}

func parse(input []byte) [][]byte {
	return bytes.Split(bytes.TrimSpace(input), []byte{'\n'})
}

func spinCycle(p [][]byte) {
	for shiftUp(p) {
	}
	for shiftLeft(p) {
	}
	for shiftDown(p) {
	}
	for shiftRight(p) {
	}
}

func shiftUp(p [][]byte) bool {
	mutated := false
	for row, rowCh := range p {
		if row == 0 {
			continue
		}
		for col, colCh := range rowCh {
			if colCh != byte('O') {
				continue
			}
			if p[row-1][col] == byte('.') {
				p[row-1][col] = 'O'
				p[row][col] = '.'
				mutated = true
			}
		}
	}
	return mutated
}

func shiftLeft(p [][]byte) bool {
	mutated := false
	for row, rowCh := range p {
		for col, colCh := range rowCh {
			if col == 0 {
				continue
			}
			if colCh != byte('O') {
				continue
			}
			if p[row][col-1] == byte('.') {
				p[row][col-1] = 'O'
				p[row][col] = '.'
				mutated = true
			}
		}
	}
	return mutated
}

func shiftDown(p [][]byte) bool {
	mutated := false
	for row, rowCh := range p {
		if row == len(p)-1 {
			continue
		}
		for col, colCh := range rowCh {
			if colCh != byte('O') {
				continue
			}
			if p[row+1][col] == byte('.') {
				p[row+1][col] = 'O'
				p[row][col] = '.'
				mutated = true
			}
		}
	}
	return mutated
}

func shiftRight(p [][]byte) bool {
	mutated := false
	for row, rowCh := range p {
		for col, colCh := range rowCh {
			if col == len(rowCh)-1 {
				continue
			}
			if colCh != byte('O') {
				continue
			}
			if p[row][col+1] == byte('.') {
				p[row][col+1] = 'O'
				p[row][col] = '.'
				mutated = true
			}
		}
	}
	return mutated
}

func countLoad(p [][]byte) int64 {
	out := int64(0)
	for row, rowCh := range p {
		rowWeight := int64(len(p) - row)
		for _, c := range rowCh {
			if c == byte('O') {
				out += rowWeight
			}
		}
	}

	return out
}
