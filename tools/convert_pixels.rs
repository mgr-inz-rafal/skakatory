use std::fs::File;
use std::io::Write;
use std::io::{self, BufRead};
use std::path::Path;

fn main() {
    for i in 52..=85 {
        let mut file = File::create(format!("decimal_pixel_data/frame_{}_bytes.bin", i)).unwrap();
        if let Ok(lines) = read_lines(format!("decimal_pixel_data/frame_{}_bytes.txt", i)) {
            for line in lines {
                if let Ok(ip) = line {
                    let number = ip.parse::<u8>().unwrap();
                    file.write_all(&[number]).unwrap();
                }
            }
        }
    }
}

fn read_lines<P>(filename: P) -> io::Result<io::Lines<io::BufReader<File>>>
where
    P: AsRef<Path>,
{
    let file = File::open(filename)?;
    Ok(io::BufReader::new(file).lines())
}
