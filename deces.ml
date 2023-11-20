let my_conv s = try int_of_string s with _  -> 0;;
let my_replace c =  if (int_of_char c) > 127 then ' ' else c;;
let my_process s = String.trim (String.map my_replace s);;

let one fp fp_out =
  try
    while true do
      let s = input_line fp in
      let n1 = try
          String.index_from s 0 '*'
        with Not_found ->
          Printf.printf "%s\n" s;
          -1 in
      let n2 = try String.index_from s 0 '/' with Not_found -> -1 in
      let nom =
        if n1<> -1 then
          my_process (String.sub s 0 n1)
        else
          my_process (String.sub s 0 80) in
      let prenom =
        if (n1 <> -1) && (n2 <> -1) then
          my_process (String.sub s (n1+1) (n2-n1-1))
        else "" in
      let sexe = match s.[80] with
        | '1' -> 'H'
        | '2' -> 'F'
        | _ -> failwith "Erreur de sexe" in
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
      if (n1 = -1) || (n2 = -1) then
        Printf.printf 
          "%s,%s,%c,%d,%d,%d,%s,%s,%s,%d,%d,%d,%s,%s\n"
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
  | _ -> failwith "Wrong number of arguments";;