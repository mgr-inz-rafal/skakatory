use std::fs::File;
use std::io::{self, BufRead};
use std::path::Path;
use std::io::Write;

fn main() {
    let mut file = File::create("decimal_pixel_data/frame_00_bytes.bin").unwrap();
    if let Ok(lines) = read_lines("decimal_pixel_data/frame_00_bytes.txt") {
        for line in lines {
            if let Ok(ip) = line {
                let number = ip.parse::<u8>().unwrap();
                file.write_all(&[number]).unwrap();
            }
        }
    }    
}

fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where P: AsRef<Path>, {
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}