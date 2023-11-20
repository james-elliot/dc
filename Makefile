deces: deces.ml
	ocamlopt -o deces deces.ml

clean:
	rm -rf *~ *.o *.cm*
