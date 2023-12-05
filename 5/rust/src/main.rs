use std::fmt::{Debug, Formatter};
use std::io;
use std::io::Read;
use rayon::prelude::*;

/// Map from a src-dst to another range of the same size
struct RangeMap {
    pub src: u64,
    pub dst: u64,
    pub len: u64,
}

impl RangeMap {
    pub fn src_end(&self) -> u64 {
        self.src + self.len - 1
    }
    pub fn dst_end(&self) -> u64 {
        self.dst + self.len - 1
    }
}

impl Debug for RangeMap {
    fn fmt(&self, f: &mut Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}..={} -> {}..={}", self.src, self.src_end(), self.dst, self.dst_end())
    }
}

#[derive(Debug)]
struct Problem {
    pub seeds: Vec<u64>,
    pub maps: Vec<Vec<RangeMap>>,
}

fn parse_input(input: &str) -> Problem {
    let mut lines = input.lines();
    // parse seed
    let seed_line = lines.next().unwrap();
    let seeds = seed_line["seeds: ".len()..].split(" ").map(|i| i.parse().unwrap()).collect();

    let _ = lines.next().unwrap();
    // parse the maps
    let mut maps = Vec::new();
    let mut cur_map = None;
    for line in lines {
        if line == "" {
            continue
        } else if line.ends_with(" map:") {
            maps.push(Vec::new());
            cur_map = maps.last_mut();
        } else {
            let mut numbers = line.split(" ").map(|v| v.parse().unwrap());
            cur_map.as_mut().unwrap().push(RangeMap {
                dst: numbers.next().unwrap(),
                src: numbers.next().unwrap(),
                len: numbers.next().unwrap(),
            })
        }
    }

    Problem {
        seeds,
        maps,
    }
}

fn get_mapped(ranges: &Vec<RangeMap>, input: u64) -> u64 {
    for range in ranges {
        if range.src <= input && range.src_end() >= input {
            let offset = input - range.src;
            return range.dst + offset;
        }
    }
    // If unmatched, then return input
    input
}

fn walk_ranges(ranges: &Vec<Vec<RangeMap>>, input: u64) -> u64 {
    let mut out = input;
    for range in ranges {
        out = get_mapped(range, out);
    }
    return out;
}

fn main() {
    let mut stdin = io::stdin();
    let mut input = String::new();
    stdin.read_to_string(&mut input).unwrap();

    let problem = parse_input(&input);
    println!("{:?}", problem);

    // let problem1 = problem.seeds.iter().map(|v| walk_ranges(&problem.maps, *v)).min().unwrap();
    // println!("Problem1: {}", problem1);

    let ranges: Vec<_> = problem.seeds.chunks(2)
        .map(|v| v[0]..(v[0]+v[1]))
        .collect();

    println!("total pairs: {}", ranges.len());

    let problem2 = ranges.into_iter()
        .map(|rng| {
            rng.into_iter().map(|v| walk_ranges(&problem.maps, v)).min().unwrap()
        })
        .inspect(|min_val| {
            println!("Finished a range -> {}", min_val);
        })
        .min().unwrap();
    println!("Problem2: {}", problem2);
}
