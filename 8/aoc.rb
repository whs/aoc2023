instruction = gets.chomp
gets

nodes = {}

while l = gets do
	parsed = l.match(/^([A-Z]+) = \(([A-Z]+), ([A-Z]+)\)/)
	nodes[parsed[1]] = {
		"L" => parsed[2],
		"R" => parsed[3],
	}
end

current = "AAA"
step = 0

while current != "ZZZ" do
	cmd = instruction[step % instruction.length]
	current = nodes[current][cmd]
	step += 1
end

puts step
