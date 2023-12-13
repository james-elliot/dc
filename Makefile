deces_c: deces.c
	cc -O -o deces_c deces.c

deces_ml: deces.ml
	ocamlopt -o deces_ml deces.ml

deces_rs: deces.rs
	rustc -O -o deces_ml deces.rs

clean:
	rm -rf *~ *.o *.cm* deces_ml deces_c
