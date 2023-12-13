use std::fs::File;
use std::io::{BufRead, BufReader, BufWriter, Lines, Write};

fn conv(s: String) -> u32 {s.parse().unwrap_or(0)}

fn replace(c: char) -> Option<char> {
    if !c.is_ascii() {
        if c == std::char::REPLACEMENT_CHARACTER {return None}
        return Some(c);
    }
    let n: u8 = c as u8;
    if (n == 0x09) || (n == 0x0A) || (n == 0x0C) || (n == 0x0D) || (n == 0x22) {return Some(' ');}
    if (n <= 0x1F) || (n == 0x7F) {return None;}
    Some(c)
}

fn process(it: &mut std::str::Chars<'_>, n: usize, f: Option<char>, ret: &mut usize) -> String {
    let mut st: String = "".to_string();
    let mut i = 0;
    loop {
        if i >= n {break}
        if let Some(c)= it.next() {
            i += 1;
            if let Some(c2)= replace(c) {
                if Some(c2) == f {break}
                st.push(c2)
            }
        }
	else {break}
    }
    *ret = i;
    st
}

fn advance_by(it: &mut std::str::Chars<'_>, n: usize) {for _ in 0..n {it.next();}}

fn one(lines_in: Lines<BufReader<File>>, st_out: &mut BufWriter<File>)-> u32 {
    let mut nb_errs = 0;
    for line in lines_in {
        match line {
            Ok(ip) => {
                let it = &mut ip.chars();
                let (n1, n2) = (&mut 0, &mut 0);
                let nom = process(it, 80, Some('*'), n1);
                let prenom = process(it, 80 - *n1, Some('/'), n2);
                //            it.advance_by(80-n1-n2).expect("Not enough");
                advance_by(it, 80 - *n1 - *n2);
                let sexe = match it.next() {
                    Some('1') => 'H',
                    Some('2') => 'F',
                    _ => panic!("Sex error"),
                };
                let year_b = conv(process(it, 4, None, n1));
                let month_b = conv(process(it, 2, None, n1));
                let day_b = conv(process(it, 2, None, n1));
                let insee_b = process(it, 5, None, n1);
                let commune_b = process(it, 30, None, n1);
                let pays_b = process(it, 30, None, n1);
                let year_d = conv(process(it, 4, None, n1));
                let month_d = conv(process(it, 2, None, n1));
                let day_d = conv(process(it, 2, None, n1));
                let insee_d = process(it, 5, None, n1);
                let num_acte = process(it, 9, None, n1);
                writeln!(
		    st_out,
		    "\"{}\",\"{}\",\"{}\",\"{}\",\"{}\",\"{}\",\"{}\",\"{}\",\"{}\",\"{}\",\"{}\",\"{}\",\"{}\",\"{}\"",
		    nom.trim(),prenom.trim(),sexe,year_b,month_b,day_b,insee_b,commune_b.trim(),
		    pays_b.trim(),year_d,month_d,day_d,insee_d,num_acte.trim()
		).expect("Write error");
            }
            Err(err) => {
		nb_errs+=1;
                eprintln!("{:?}", err);
            }
        }
    }
    nb_errs
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let mut nb_errs=0;
    match args.len() {
        3 => {
            let low = args[1].parse::<i32>().unwrap();
            let high = args[2].parse::<i32>().unwrap();
            let name = "deces-".to_owned() + &args[1] + "-" + &args[2] + ".csv";
            let file_out = File::create(name).expect("Can't create");
            let st_out = &mut BufWriter::new(file_out);
            for i in low..=high {
                let st: String = "deces-".to_owned() + &i.to_string() + ".txt";
                let file = File::open(st).expect("Can't open");
                nb_errs += one(BufReader::new(file).lines(), st_out);
            }
        }
        2 => {
            let name = "deces-".to_owned() + &args[1] + ".csv";
            let file_out = File::create(name).expect("Can't create");
            let st_out = &mut BufWriter::new(file_out);
            let st: String = "deces-".to_owned() + &args[1] + ".txt";
            let file = File::open(st).expect("Can't open");
            nb_errs += one(BufReader::new(file).lines(), st_out);
        }
        _ => {
            eprintln!("Bad number of arguments");
        }
    }
    println!("{} records dropped",nb_errs);
}
