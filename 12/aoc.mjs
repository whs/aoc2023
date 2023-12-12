// @ts-check
import * as fs from 'fs'

let input = fs.readFileSync(process.argv[2]).toString().trimEnd()
let problems = input.split("\n").map((line) => {
	let [map, unknowns] = line.split(" ")
	return {
		map,
		unknowns: unknowns.split(",").map((i) => parseInt(i, 10))
	}
})

function getBlock(map) {
	let out = 0
	for(let i = 0; i < map.length; i++){
		if(map[i] === '#' || map[i] === '?') {
			out++
		}else{
			break
		}
	}
	return out
}

/**
 * @param {string} map 
 * @param {number[]} unknowns 
 * @returns string[]
 */
function solve1(map, unknowns){
	if(map.length === 0){
		if(unknowns.length > 0){
			// throw new Error(`invalid solution - empty map but ${unknowns.length} unknowns items left`)
			return []
		}
		console.log(`End of the line - empty map`)
		return [""]
	}
	
	if (map[0] === "?") {
		let solns = []
		
		// Try to fill right side
		let continuousUnknownOrDamaged = getBlock(map)
		let wantedSize = unknowns[0]
		if(continuousUnknownOrDamaged >= wantedSize){
			// we can fill, but only if the right side is EOL or . or ?
			if(wantedSize === map.length || map[wantedSize] !== '#'){
				console.log(`We can fill left side ${map} with length ${wantedSize}`)
				let subsoln = cachedSolve1(map.slice(wantedSize + 1), unknowns.slice(1))
				solns.push(...subsoln.map(v => "#".repeat(wantedSize) + "." + v))
			}
		}
		
		// Or fill the current tile with . and go on
		let subsoln = cachedSolve1(map.slice(1), unknowns)
		solns.push(...subsoln.map(v => `.${v}`))
		
		return solns
	}else if(map[0] === "#") {
		let block = getBlock(map)
		if(block < unknowns[0]) {
			// throw new Error(`invalid solution - # block of ${block} but we want at least ${unknowns[0]}`)
			return []
		}
		// fill the block with broken ones
		let prefix = "#".repeat(unknowns[0])
		let newMap = map.slice(unknowns[0])
		let newUnknown = unknowns.slice(1)
		if (newMap.length === 0){
			if(newUnknown.length > 0){
				// throw new Error(`invalid solution - end of line but ${newUnknown.length} unknowns items left`)
				return []
			}
			// we reach the end, hooray!
			console.log("End of line after block fill")
			return [prefix]
		}else if (newMap[0] === "?") {
			// make that operational
			newMap = newMap.slice(1)
			prefix += "."
		}else if (newMap[0] === "#") {
			// throw new Error(`invalid solution - block filled but the next item is #`)
			return []
		}
		console.log(`In ${map} we got block of ${block}. After we filled ${unknowns[0]} we got ${newMap} and unknown ${JSON.stringify(newUnknown)}`)
		return cachedSolve1(newMap, newUnknown).map(v => prefix + v)
	}else if(map[0] === ".") {
		return cachedSolve1(map.slice(1), unknowns).map(v => `.${v}`)
	}else{
		throw new Error("unknown char")
	}
}

const cache = {}
function cachedSolve1(map, unknowns) {
	let key = map + JSON.stringify(unknowns)
	if(cache[key] !== undefined){
		return cache[key]
	}
	let out = solve1(map, unknowns)
	cache[key] = out
	return out
}

let out1 = problems.map((p) => {
	let out = cachedSolve1(p.map, p.unknowns)
	console.log("Problem:")
	console.log(p)
	console.log(`Solutions ${out.length}`)
	console.log(out)
	return out.length
}).reduce((a, b) => a+b, 0)
console.log(out1)
