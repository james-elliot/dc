let my_conv s = try int_of_string s with _  -> 0;;
let my_replace c =
  let n = int_of_char c in
  if (n=0x09) || (n=0x0A) || (n=0x0C) || (n=0x0D) || (n=0x22) then (Some ' ')
  else if (n<=0x1F) || (n>=0x7F) then  None
  else if (n>=0x61) && (n<=0x7A) then Some (char_of_int (n-0x20))
  else Some c;;
let my_process s =
  let f (b,i) c =
    match (my_replace c) with
    | None -> (b,i)
    | Some c -> Bytes.set b i c;(b,i+1) in
  let b = Bytes.create (String.length s) in
  let (b,n) = String.fold_left f (b,0) s in
  String.trim (String.sub (Bytes.to_string b) 0 n);;


let one fp fp_out =
  try
    while true do
      let s = input_line fp in
      let np = String.sub s 0 80 in
      let n1 = try String.index_from np 0 '*' with Not_found -> 80 in
      let nom = my_process (String.sub np 0 n1) in
      let prenom =
        if n1<>80 then
          let n2 = try String.index_from np n1 '/' with Not_found -> 80 in
          my_process (String.sub np (n1+1) (n2-n1-1))
        else "" in
      let sexe = match s.[80] with | '1' -> 'H' | '2' -> 'F' | _ -> failwith "Erreur de sexe" in
      let year_b = my_conv (String.sub s 81 4) in
      let month_b = my_conv (String.sub s 85 2) in
      let day_b = my_conv (String.sub s 87 2) in
      let insee_b = String.sub s 89 5 in
      let commune_b =  my_process (String.sub s 94 30) in
      let pays_b = my_process (String.sub s 124 30) in
      let year_d = my_conv (String.sub s 154 4) in
      let month_d = my_conv (String.sub s 158 2) in
      let day_d = my_conv (String.sub s 160 2) in
      let insee_d = String.sub s 162 5 in
      let num_acte = my_process (String.sub s 167 9) in
      Printf.fprintf fp_out
        "\"%s\",\"%s\",\"%c\",\"%d\",\"%d\",\"%d\",\"%s\",\"%s\",\"%s\",\"%d\",\"%d\",\"%d\",\"%s\",\"%s\"\n"
        nom prenom sexe year_b month_b day_b insee_b commune_b pays_b
        year_d month_d day_d insee_d num_acte;
    done
  with End_of_file -> ();;

let _ =
  match Array.length Sys.argv with
  | 2 ->
     let fp = open_in ("./deces-"^Sys.argv.(1)^".txt") in
     let fp_out = open_out ("./deces-"^Sys.argv.(1)^".csv") in
     one fp fp_out
  | 3 ->
     let fp_out = open_out ("./deces-"^Sys.argv.(1)^"-"^Sys.argv.(2)^".csv") in
     for i = int_of_string Sys.argv.(1) to int_of_string Sys.argv.(2) do
       let fp = open_in ("./deces-"^(string_of_int i)^".txt") in
       one fp fp_out;
       close_in fp;
     done
  | _ -> failwith "Mauvais nombre d'arguments";;
