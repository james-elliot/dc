-- sudo -u postgres psql template1
CREATE USER alliot with CREATEDB ENCRYPTED PASSWORD 'mon_pass';
-- sudo -u alliot psql template1
CREATE DATABASE dc;
-- sudo -u alliot psql dc
-- OU: psql -U alliot -h 192.168.1.1 -p 5432 dc
-- postgresql.conf doit être modifié:
-- listen_addresses = '*'
-- pg_hba.conf doit être modifié:
-- host    all             all             192.168.1.0/24            scram-sha-256
CREATE TYPE sexe AS ENUM ('H','F');
CREATE TABLE dc (
       "id" SERIAL,
       "nom" VARCHAR(80) NULL,
    	"prenom" VARCHAR(80) NULL,	
  	"sexe" sexe,
  	"annee_n" SMALLINT NULL,
  	"mois_n" SMALLINT NULL,
	"jour_n" SMALLINT NULL,	
  	"insee_n" VARCHAR(5) NULL,
  	"commune_n" VARCHAR(30) NULL,
  	"pays_n" VARCHAR(30) NULL,
  	"annee_d" SMALLINT NULL,
  	"mois_d" SMALLINT NULL,
	"jour_d" SMALLINT NULL,	
  	"insee_d" VARCHAR(5) NULL,
  	"num_acte" VARCHAR(9) NULL,
  PRIMARY KEY ("id"));
  
COPY dc (
       nom,
    	prenom,
  	sexe,
  	annee_n,
  	mois_n,
	jour_n,
  	insee_n,
  	commune_n,
  	pays_n,
  	annee_d,
  	mois_d,
	jour_d,
  	insee_d,
  	num_acte
)
FROM '/mnt/home2/alliot/ML/dc/deces-1970-2022.csv' CSV;

CREATE INDEX ON dc(nom);
 
