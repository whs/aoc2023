use std::io;
use std::io::Read;

// The newly-improved calibration document consists of lines of text
// each line originally contained a specific calibration value that the Elves now need to recover
// On each line, the calibration value can be found by combining the first digit and the last digit (in that order) to form a single two-digit number.
fn solve(text: &str) -> u32 {
    text.lines().map(|v| {
        let first_digit = v.chars().find(|c| c.is_numeric()).map(|c| c.to_digit(10)).flatten().unwrap();
        let last_digit = v.chars().rfind(|c| c.is_numeric()).map(|c| c.to_digit(10)).flatten().unwrap();

        (first_digit * 10) + last_digit
    }).fold(0u32, |a, b| a + b)
}

struct Replacement {
    len: usize,
    text: &'static [u8; 5],
    replacement: &'static [u8; 1],
}

const NUMBERS: [Replacement; 9] = [
    Replacement { len: 3, text: b"one  ", replacement: b"1" },
    Replacement { len: 3, text: b"two  ", replacement: b"2" },
    Replacement { len: 5, text: b"three", replacement: b"3" },
    Replacement { len: 4, text: b"four ", replacement: b"4" },
    Replacement { len: 4, text: b"five ", replacement: b"5" },
    Replacement { len: 3, text: b"six  ", replacement: b"6" },
    Replacement { len: 5, text: b"seven", replacement: b"7" },
    Replacement { len: 5, text: b"eight", replacement: b"8" },
    Replacement { len: 4, text: b"nine ", replacement: b"9" },
];

fn solve2(text: &str) -> u32 {
    text.lines().map(|v| {
        let mut new_v = Vec::<u8>::new();
        let raw = v.as_bytes();
        let mut i = 0;
        let mut last_covered = 0;
        'outer: while i < raw.len() {
            for pattern in &NUMBERS {
                if i + pattern.len > raw.len() {
                    continue;
                }
                if raw[i..i + pattern.len] == pattern.text[0..pattern.len] {
                    last_covered = i + pattern.len;
                    new_v.extend_from_slice(pattern.replacement);
                    i += 1;
                    continue 'outer;
                }
            }
            if last_covered <= i {
                new_v.push(raw[i]);
            }
            i += 1;
        }
        let new_v = unsafe { String::from_utf8_unchecked(new_v) };
        let first_digit = new_v.chars().find(|c| c.is_numeric()).map(|c| c.to_digit(10)).flatten().unwrap();
        let last_digit = new_v.chars().rfind(|c| c.is_numeric()).map(|c| c.to_digit(10)).flatten().unwrap();

        (first_digit * 10) + last_digit
    }).fold(0u32, |a, b| a + b)
}

fn main() {
    let mut stdin = io::stdin();
    let mut input = String::new();
    stdin.read_to_string(&mut input).unwrap();
    println!("{}", solve2(&input));
}

#[cfg(test)]
mod tests {
    use crate::*;

    #[test]
    fn test_example() {
        let input = "1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet";
        assert_eq!(solve(input), 142);
    }

    #[test]
    fn test_example2() {
        let input = "two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen";
        assert_eq!(solve2(input), 281);
    }

    #[test]
    fn test_example2_reddit() {
        let input = "eighthree
sevenine";
        assert_eq!(solve2(input), 83 + 79);
    }
}