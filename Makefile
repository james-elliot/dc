deces_c: deces.c
	cc -O -o deces_c deces.c

deces_ml: deces.ml
	ocamlopt -o deces_ml deces.ml

clean:
	rm -rf *~ *.o *.cm* deces_ml deces_c
