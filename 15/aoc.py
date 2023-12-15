def hash(v: str):
	out = 0
	for ch in v:
		out += ord(ch)
		out = out * 17
		out = out % 256
	return out

assert hash("HASH") == 52

if __name__ == "__main__":
	problems = input().split(",")
	out = [hash(p) for p in problems]
	print(sum(out))
