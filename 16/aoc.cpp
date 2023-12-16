#include <iostream>
#include <string>
#include <vector>
#include <set>
#include <utility>

using namespace std;

enum Dir {
	DIR_UP,
	DIR_LEFT,
	DIR_DOWN,
	DIR_RIGHT
};

typedef pair<int, int> Coord;

const Coord advanceInDir(const Coord position, const Dir direction){
	switch(direction){
	case DIR_UP:
		return make_pair(position.first - 1, position.second);
	case DIR_LEFT:
		return make_pair(position.first, position.second - 1);
	case DIR_DOWN:
		return make_pair(position.first + 1, position.second);
	case DIR_RIGHT:
		return make_pair(position.first, position.second + 1);
	}
	__builtin_unreachable();
}

typedef pair<Coord, Dir> WalkedDir;

int solve1(const vector<string> &problem, Coord position, Dir direction, set<WalkedDir> &walked){
	WalkedDir walkedDir = make_pair(position, direction);
	if (walked.contains(walkedDir)) {
		return 0;
	}
	if (position.first < 0 || position.first >= problem.size() || position.second < 0 || position.second >= problem[0].size()) {
		return 0;
	}
	walked.insert(walkedDir);

	// cout << "at position " << position.first << " " << position.second << endl;
	
	const char curChar = problem[position.first][position.second];
	if (curChar == '.') {
		return solve1(problem, advanceInDir(position, direction), direction, walked);
	} else if (curChar == '\\') {
		switch(direction){
		case DIR_UP:
			// \ 
			// |
			return solve1(problem, advanceInDir(position, DIR_LEFT), DIR_LEFT, walked);
		case DIR_LEFT: // \--
			return solve1(problem, advanceInDir(position, DIR_UP), DIR_UP, walked);
		case DIR_DOWN:
			// |
			// \ ..
			return solve1(problem, advanceInDir(position, DIR_RIGHT), DIR_RIGHT, walked);
		case DIR_RIGHT: // --\ ..
			return solve1(problem, advanceInDir(position, DIR_DOWN), DIR_DOWN, walked);
		}
	} else if (curChar == '/') {
		switch(direction){
		case DIR_UP:
			// /
			// |
			return solve1(problem, advanceInDir(position, DIR_RIGHT), DIR_RIGHT, walked);
		case DIR_LEFT: // /--
			return solve1(problem, advanceInDir(position, DIR_DOWN), DIR_DOWN, walked);
		case DIR_DOWN:
			// |
			// /
			return solve1(problem, advanceInDir(position, DIR_LEFT), DIR_LEFT, walked);
		case DIR_RIGHT: // --/
			return solve1(problem, advanceInDir(position, DIR_UP), DIR_UP, walked);
		}
	} else if (curChar == '|') {
		switch(direction){
		case DIR_UP: case DIR_DOWN: // pointy end
			return solve1(problem, advanceInDir(position, direction), direction, walked);
		case DIR_LEFT: case DIR_RIGHT: // flat end
			solve1(problem, advanceInDir(position, DIR_UP), DIR_UP, walked);
			solve1(problem, advanceInDir(position, DIR_DOWN), DIR_DOWN, walked);
			return 1;
		}
	} else if (curChar == '-') {
		switch(direction){
		case DIR_UP: case DIR_DOWN: // flat end
			solve1(problem, advanceInDir(position, DIR_LEFT), DIR_LEFT, walked);
			solve1(problem, advanceInDir(position, DIR_RIGHT), DIR_RIGHT, walked);
			return 1;
		case DIR_LEFT: case DIR_RIGHT: // pointy end
			return solve1(problem, advanceInDir(position, direction), direction, walked);
		}
	} else {
		cout << "wtf is " << curChar << "??" << endl;
		throw new runtime_error("wtf");
	}

	return walked.size();
}

set<Coord> toCoordSet(const set<WalkedDir> walked) {
	set<Coord> out;
	for(WalkedDir d : walked) {
		out.insert(d.first);
	}
	return out;
}

void printWalkDiagram(int w, int h, const set<Coord> &walked) {
	for(int hi = 0; hi < h; hi++){
		for(int wi = 0; wi < w; wi++){
			if (walked.contains(make_pair(hi, wi))) {
				cout << "#";
			}else{
				cout << ".";
			}
		}
		cout << endl;
	}
}

int main() {
	vector<string> problem;
	for(;;) {
		string input;
		getline(cin, input);
		if(input.empty()){
			break;
		}
		problem.push_back(input);
	}
	
	/*/ // part1

	set<WalkedDir> walked;
	solve1(problem, make_pair(0, 0), DIR_RIGHT, walked);

	set<Coord> coords = toCoordSet(walked);

	printWalkDiagram(problem[0].size(), problem.size(), coords);

	cout << coords.size() << endl;

	/**/

	/**/ // part 2

	int maxTiles = 0;

	// top row
	for(int i = 0; i < problem[0].size(); i++) {
		set<WalkedDir> walked;
		solve1(problem, make_pair(0, i), DIR_DOWN, walked);
		set<Coord> coords = toCoordSet(walked);
		maxTiles = max(static_cast<int>(coords.size()), maxTiles);
	}
	// bottom row
	for(int i = 0; i < problem[0].size(); i++) {
		set<WalkedDir> walked;
		solve1(problem, make_pair(problem.size() - 1, i), DIR_UP, walked);
		set<Coord> coords = toCoordSet(walked);
		maxTiles = max(static_cast<int>(coords.size()), maxTiles);
	}
	// left row
	for(int i = 0; i < problem.size(); i++) {
		set<WalkedDir> walked;
		solve1(problem, make_pair(i, 0), DIR_RIGHT, walked);
		set<Coord> coords = toCoordSet(walked);
		maxTiles = max(static_cast<int>(coords.size()), maxTiles);
	}
	// right row
	int rightRow = problem[0].size() - 1;
	for(int i = 0; i < problem.size(); i++) {
		set<WalkedDir> walked;
		solve1(problem, make_pair(rightRow, 1), DIR_LEFT, walked);
		set<Coord> coords = toCoordSet(walked);
		maxTiles = max(static_cast<int>(coords.size()), maxTiles);
	}

	cout << maxTiles << endl;

	/**/

	return 0;
}
