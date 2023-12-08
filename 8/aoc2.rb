instruction = gets.chomp
gets

$nodes = {}

while l = gets do
	parsed = l.match(/^([0-9A-Z]+) = \(([0-9A-Z]+), ([0-9A-Z]+)\)/)
	$nodes[parsed[1]] = {
		"L" => parsed[2],
		"R" => parsed[3],
	}
end

current = $nodes.keys.filter { |k| k.end_with?("A") }

current_z_every = current.map { |v| 
	step = 0
	cur = v
	while !cur.end_with?("Z") do
		cmd = instruction[step % instruction.length]
		cur = $nodes[cur][cmd]
		step += 1
	end
	step
}

puts current_z_every.reduce(1, :lcm)

