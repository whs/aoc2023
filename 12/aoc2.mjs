// @ts-check
import * as fs from 'fs'

let input = fs.readFileSync(process.argv[2]).toString().trimEnd()
let problems = input.split("\n").map((line) => {
	let [map, unknowns] = line.split(" ")
	return {
		map,
		unknowns: unknowns.split(",").map((i) => parseInt(i, 10)),
	}
})

/**
 * @returns boolean
 */
function isValidSolution(map, unknowns) {
	let cloned = unknowns.slice(0)
	let inBlock = false
	for(let i = 0; i < map.length; i++){
		if(map[i] === '#'){
			if(cloned[0] <= 0){
				// block too long
				return false
			}
			inBlock = true
			cloned[0]--
		}else if (map[i] === '.') {
			if(cloned[0] === 0){
				cloned.shift()
			}else if(inBlock){
				// block too short
				return false
			}
			inBlock = false
		}
	}
	if(cloned.length > 1){
		return false
	}else if(cloned.length === 1 && cloned[0] !== 0) {
		return false
	}
	return true
}

const cache = {}
function cachedSolve(map, unknowns) {
	let key = map + " " + unknowns.join(",")
	if(cache[key] !== undefined){
		return cache[key]
	}
	let out = solve(map, unknowns)
	cache[key] = out
	return out
}

function solve(map, unknowns){
	if(unknowns.length === 0){
		if(isValidSolution(map)){
			return 1
		}else{
			return 0
		}
	}
	
}

let out2 = problems.map((p) => {
	let map = ""
	let unknowns = []
	for(let i = 0; i < 5; i++){
		map += p.map + "?"
		unknowns.push(...p.unknowns)
	}
	map = map.slice(0, map.length-1)
	let out = cachedSolve(map, unknowns)
	return out
}).reduce((a, b) => a+b, 0)
console.log(out2)
