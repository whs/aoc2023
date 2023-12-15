import re
from aoc import hash

boxes = [list() for x in range(256)]

problems = input().split(",")

for problem in problems:
	parts = re.split('([=-])', problem)
	box_index = hash(parts[0])
	mutating_box = boxes[box_index]
	if parts[1] == '-':
		for item in mutating_box:
			if item[0] == parts[0]:
				mutating_box.remove(item)
				break
	elif parts[1] == '=':
		existing = False
		for item in mutating_box:
			if item[0] == parts[0]:
				item[1] = parts[2]
				existing = True
				break
		if not existing:
			mutating_box.append([parts[0], parts[2]])

print(boxes)

out = 0
for index, content in enumerate(boxes):
	for lensIndex, lens in enumerate(content):
		out += (1 + index) * (lensIndex + 1) * int(lens[1])

print(out)
