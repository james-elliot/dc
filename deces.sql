CREATE TABLE `DC` (
       `id` INT NOT NULL AUTO_INCREMENT,
       `nom` VARCHAR(80) NULL,
    	`prenom` VARCHAR(80) NULL,	
  	`sexe` ENUM('H','F') ,
  	`annee_n` SMALLINT NULL,
  	`mois_n` TINYINT NULL,
	`jour_n` TINYINT NULL,	
  	`insee_n` VARCHAR(5) NULL,
  	`commune_n` VARCHAR(30) NULL,
  	`pays_n` VARCHAR(30) NULL,
  	`annee_d` SMALLINT NULL,
  	`mois_d` TINYINT NULL,
	`jour_d` TINYINT NULL,	
  	`insee_d` VARCHAR(5) NULL,
  	`num_acte` VARCHAR(9) NULL,
  PRIMARY KEY (`id`));

SET GLOBAL local_infile=1; -- On the server only once
-- Launch client with: mysql -h 10.31.1.1 --local-infile=1 -u alliot -p DC

LOAD DATA LOCAL INFILE './deces-1970-2022.csv' 
     INTO TABLE DC
     FIELDS TERMINATED BY ',' 
     ENCLOSED BY '"'
     LINES TERMINATED BY '\n'
     (`nom`,`prenom`,`sexe`,`annee_n`,`mois_n`,`jour_n`,`insee_n`,`commune_n`,`pays_n`,
     `annee_d`,`mois_d`,`jour_d`,`insee_d`,`num_acte`);


ALTER TABLE DC ADD INDEX (nom);
