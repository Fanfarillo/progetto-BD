-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema CircuitoDiBiblioteche
-- -----------------------------------------------------
DROP SCHEMA IF EXISTS `CircuitoDiBiblioteche` ;

-- -----------------------------------------------------
-- Schema CircuitoDiBiblioteche
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `CircuitoDiBiblioteche` DEFAULT CHARACTER SET utf8 ;
USE `CircuitoDiBiblioteche` ;

-- -----------------------------------------------------
-- Table `CircuitoDiBiblioteche`.`biblioteca`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CircuitoDiBiblioteche`.`biblioteca` ;

CREATE TABLE IF NOT EXISTS `CircuitoDiBiblioteche`.`biblioteca` (
  `numero_telefono` VARCHAR(15) NOT NULL,
  `indirizzo_biblioteca` VARCHAR(45) NOT NULL,
  `responsabile` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`numero_telefono`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `CircuitoDiBiblioteche`.`libro`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CircuitoDiBiblioteche`.`libro` ;

CREATE TABLE IF NOT EXISTS `CircuitoDiBiblioteche`.`libro` (
  `ISBN` VARCHAR(13) NOT NULL,
  `titolo` VARCHAR(45) NOT NULL,
  `autore` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`ISBN`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `CircuitoDiBiblioteche`.`utente`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CircuitoDiBiblioteche`.`utente` ;

CREATE TABLE IF NOT EXISTS `CircuitoDiBiblioteche`.`utente` (
  `CF_utente` VARCHAR(16) NOT NULL,
  `nome_utente` VARCHAR(45) NOT NULL,
  `cognome_utente` VARCHAR(45) NOT NULL,
  `data_nascita_utente` DATE NOT NULL,
  `indirizzo_utente` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`CF_utente`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `CircuitoDiBiblioteche`.`user`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CircuitoDiBiblioteche`.`user` ;

CREATE TABLE IF NOT EXISTS `CircuitoDiBiblioteche`.`user` (
  `username` VARCHAR(45) NOT NULL,
  `password` CHAR(32) NOT NULL,
  `ruolo` ENUM('amministratore', 'bibliotecario') NOT NULL,
  PRIMARY KEY (`username`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `CircuitoDiBiblioteche`.`bibliotecario`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CircuitoDiBiblioteche`.`bibliotecario` ;

CREATE TABLE IF NOT EXISTS `CircuitoDiBiblioteche`.`bibliotecario` (
  `CF_bibliotecario` VARCHAR(16) NOT NULL,
  `nome_bibliotecario` VARCHAR(45) NOT NULL,
  `cognome_bibliotecario` VARCHAR(45) NOT NULL,
  `data_nascita_bibliotecario` DATE NOT NULL,
  `luogo_nascita` VARCHAR(45) NOT NULL,
  `titolo_studio` VARCHAR(45) NOT NULL,
  `biblioteca_impiego` VARCHAR(15) NOT NULL,
  `username_bibliotecario` VARCHAR(45) NOT NULL,
  PRIMARY KEY (`CF_bibliotecario`),
  CONSTRAINT `biblioteca_impiego`
    FOREIGN KEY (`biblioteca_impiego`)
    REFERENCES `CircuitoDiBiblioteche`.`biblioteca` (`numero_telefono`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `username_bibliotecario`
    FOREIGN KEY (`username_bibliotecario`)
    REFERENCES `CircuitoDiBiblioteche`.`user` (`username`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `biblioteca_impiego_idx` ON `CircuitoDiBiblioteche`.`bibliotecario` (`biblioteca_impiego` ASC) VISIBLE;

CREATE UNIQUE INDEX `username_bibliotecario_UNIQUE` ON `CircuitoDiBiblioteche`.`bibliotecario` (`username_bibliotecario` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `CircuitoDiBiblioteche`.`turno`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CircuitoDiBiblioteche`.`turno` ;

CREATE TABLE IF NOT EXISTS `CircuitoDiBiblioteche`.`turno` (
  `bibliotecario` VARCHAR(16) NOT NULL,
  `data` DATE NOT NULL,
  `orario_inizio_turno` TIME NOT NULL,
  `orario_fine_turno` TIME NOT NULL,
  PRIMARY KEY (`bibliotecario`, `data`),
  CONSTRAINT `bibliotecario`
    FOREIGN KEY (`bibliotecario`)
    REFERENCES `CircuitoDiBiblioteche`.`bibliotecario` (`CF_bibliotecario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `CircuitoDiBiblioteche`.`malattia`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CircuitoDiBiblioteche`.`malattia` ;

CREATE TABLE IF NOT EXISTS `CircuitoDiBiblioteche`.`malattia` (
  `bibliotecario_malato` VARCHAR(16) NOT NULL,
  `data_malattia` DATE NOT NULL,
  `motivo` VARCHAR(45) NOT NULL,
  `bibliotecario_sostituto` VARCHAR(16) NOT NULL,
  PRIMARY KEY (`bibliotecario_malato`, `data_malattia`),
  UNIQUE (`data_malattia`, `bibliotecario_sostituto`),
  CONSTRAINT `bibliotecario_sostituto`
    FOREIGN KEY (`bibliotecario_sostituto`)
    REFERENCES `CircuitoDiBiblioteche`.`bibliotecario` (`CF_bibliotecario`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `bibliotecario_sostituto_idx` ON `CircuitoDiBiblioteche`.`malattia` (`bibliotecario_sostituto` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `CircuitoDiBiblioteche`.`apertura`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CircuitoDiBiblioteche`.`apertura` ;

CREATE TABLE IF NOT EXISTS `CircuitoDiBiblioteche`.`apertura` (
  `biblioteca` VARCHAR(15) NOT NULL,
  `giorno_settimanale` INT UNSIGNED NOT NULL,
  `orario_inizio_apertura` TIME NOT NULL,
  `orario_fine_apertura` TIME NOT NULL,
  PRIMARY KEY (`biblioteca`, `giorno_settimanale`),
  CONSTRAINT `biblioteca`
    FOREIGN KEY (`biblioteca`)
    REFERENCES `CircuitoDiBiblioteche`.`biblioteca` (`numero_telefono`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `CircuitoDiBiblioteche`.`disponibilità`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CircuitoDiBiblioteche`.`disponibilità` ;

CREATE TABLE IF NOT EXISTS `CircuitoDiBiblioteche`.`disponibilità` (
  `numero_biblioteca` VARCHAR(15) NOT NULL,
  `ISBN_libro` VARCHAR(13) NOT NULL,
  `quantità` INT UNSIGNED NOT NULL,
  `quantità_totale` INT UNSIGNED NOT NULL,
  `data_ultima_restituzione_libro` DATE NULL,
  PRIMARY KEY (`numero_biblioteca`, `ISBN_libro`),
  CONSTRAINT `numero_biblioteca`
    FOREIGN KEY (`numero_biblioteca`)
    REFERENCES `CircuitoDiBiblioteche`.`biblioteca` (`numero_telefono`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `ISBN_libro`
    FOREIGN KEY (`ISBN_libro`)
    REFERENCES `CircuitoDiBiblioteche`.`libro` (`ISBN`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `ISBN_libro_idx` ON `CircuitoDiBiblioteche`.`disponibilità` (`ISBN_libro` ASC) VISIBLE;

CREATE INDEX `data_ultima_restituzione_libro_idx` ON `CircuitoDiBiblioteche`.`disponibilità` (`data_ultima_restituzione_libro` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `CircuitoDiBiblioteche`.`copia_di_libro`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CircuitoDiBiblioteche`.`copia_di_libro` ;

CREATE TABLE IF NOT EXISTS `CircuitoDiBiblioteche`.`copia_di_libro` (
  `ID` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `biblioteca_ubicazione` VARCHAR(15) NOT NULL,
  `libro` VARCHAR(13) NOT NULL,
  `stato` ENUM('disponibile', 'in prestito', 'trasferita', 'dismessa') NOT NULL,
  `scaffale` INT UNSIGNED NULL,
  `ripiano` INT UNSIGNED NULL,
  `data_ultima_restituzione_copia` DATE NULL,
  PRIMARY KEY (`ID`),
  CONSTRAINT `biblioteca_ubicazione`
    FOREIGN KEY (`biblioteca_ubicazione`)
    REFERENCES `CircuitoDiBiblioteche`.`biblioteca` (`numero_telefono`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE,
  CONSTRAINT `libro`
    FOREIGN KEY (`libro`)
    REFERENCES `CircuitoDiBiblioteche`.`libro` (`ISBN`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `biblioteca_ubicazione_idx` ON `CircuitoDiBiblioteche`.`copia_di_libro` (`biblioteca_ubicazione` ASC) VISIBLE;

CREATE INDEX `libro_idx` ON `CircuitoDiBiblioteche`.`copia_di_libro` (`libro` ASC) VISIBLE;

CREATE INDEX `stato_idx` ON `CircuitoDiBiblioteche`.`copia_di_libro` (`stato` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `CircuitoDiBiblioteche`.`prestito`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CircuitoDiBiblioteche`.`prestito` ;

CREATE TABLE IF NOT EXISTS `CircuitoDiBiblioteche`.`prestito` (
  `copia_prestata` INT UNSIGNED NOT NULL,
  `utente_destinatario` VARCHAR(16) NOT NULL,
  `data_inizio` DATE NOT NULL,
  `durata_prevista` ENUM('1 mese', '2 mesi', '3 mesi') NOT NULL,
  PRIMARY KEY (`copia_prestata`),
  CONSTRAINT `copia_prestata`
    FOREIGN KEY (`copia_prestata`)
    REFERENCES `CircuitoDiBiblioteche`.`copia_di_libro` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `utente_destinatario`
    FOREIGN KEY (`utente_destinatario`)
    REFERENCES `CircuitoDiBiblioteche`.`utente` (`CF_utente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `utente_destinatario_idx` ON `CircuitoDiBiblioteche`.`prestito` (`utente_destinatario` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `CircuitoDiBiblioteche`.`penale`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CircuitoDiBiblioteche`.`penale` ;

CREATE TABLE IF NOT EXISTS `CircuitoDiBiblioteche`.`penale` (
  `copia` INT UNSIGNED NOT NULL,
  `utente_pagante` VARCHAR(16) NOT NULL,
  `data_inizio_prestito` DATE NOT NULL,
  `data_restituzione` DATE NOT NULL,
  `durata_prevista_prestito` ENUM('1 mese', '2 mesi', '3 mesi') NOT NULL,
  PRIMARY KEY (`copia`, `utente_pagante`, `data_inizio_prestito`),
  CONSTRAINT `copia`
    FOREIGN KEY (`copia`)
    REFERENCES `CircuitoDiBiblioteche`.`copia_di_libro` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `utente_pagante`
    FOREIGN KEY (`utente_pagante`)
    REFERENCES `CircuitoDiBiblioteche`.`utente` (`CF_utente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `utente_pagante_idx` ON `CircuitoDiBiblioteche`.`penale` (`utente_pagante` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `CircuitoDiBiblioteche`.`tariffa`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CircuitoDiBiblioteche`.`tariffa` ;

CREATE TABLE IF NOT EXISTS `CircuitoDiBiblioteche`.`tariffa` (
  `inizio_prestito` DATE NOT NULL,
  `restituzione` DATE NOT NULL,
  `durata_pattuita_prestito` ENUM('1 mese', '2 mesi', '3 mesi') NOT NULL,
  `valore_tariffa` FLOAT UNSIGNED NOT NULL,
  PRIMARY KEY (`inizio_prestito`, `restituzione`, `durata_pattuita_prestito`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `CircuitoDiBiblioteche`.`contatto`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CircuitoDiBiblioteche`.`contatto` ;

CREATE TABLE IF NOT EXISTS `CircuitoDiBiblioteche`.`contatto` (
  `recapito` VARCHAR(45) NOT NULL,
  `mezzo_comunicazione` ENUM('telefono', 'cellulare', 'email') NOT NULL,
  `utente` VARCHAR(16) NOT NULL,
  PRIMARY KEY (`recapito`),
  CONSTRAINT `utente`
    FOREIGN KEY (`utente`)
    REFERENCES `CircuitoDiBiblioteche`.`utente` (`CF_utente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `utente_idx` ON `CircuitoDiBiblioteche`.`contatto` (`utente` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `CircuitoDiBiblioteche`.`trasferimento`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CircuitoDiBiblioteche`.`trasferimento` ;

CREATE TABLE IF NOT EXISTS `CircuitoDiBiblioteche`.`trasferimento` (
  `copia_trasferita` INT UNSIGNED NOT NULL,
  `biblioteca_destinazione` VARCHAR(15) NOT NULL,
  PRIMARY KEY (`copia_trasferita`),
  CONSTRAINT `copia_trasferita`
    FOREIGN KEY (`copia_trasferita`)
    REFERENCES `CircuitoDiBiblioteche`.`copia_di_libro` (`ID`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `biblioteca_destinazione`
    FOREIGN KEY (`biblioteca_destinazione`)
    REFERENCES `CircuitoDiBiblioteche`.`biblioteca` (`numero_telefono`)
    ON DELETE NO ACTION
    ON UPDATE CASCADE)
ENGINE = InnoDB;

CREATE INDEX `biblioteca_destinazione_idx` ON `CircuitoDiBiblioteche`.`trasferimento` (`biblioteca_destinazione` ASC) VISIBLE;


-- -----------------------------------------------------
-- Table `CircuitoDiBiblioteche`.`contatto_preferito`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `CircuitoDiBiblioteche`.`contatto_preferito` ;

CREATE TABLE IF NOT EXISTS `CircuitoDiBiblioteche`.`contatto_preferito` (
  `codice_fiscale_utente` VARCHAR(16) NOT NULL,
  `mezzo_comunicazione_preferito` ENUM('telefono', 'cellulare', 'email') NOT NULL,
  PRIMARY KEY (`codice_fiscale_utente`))
ENGINE = InnoDB;

USE `CircuitoDiBiblioteche` ;

-- -----------------------------------------------------
-- procedure login
-- -----------------------------------------------------

USE `CircuitoDiBiblioteche`;
DROP procedure IF EXISTS `CircuitoDiBiblioteche`.`login`;

DELIMITER $$
USE `CircuitoDiBiblioteche`$$
CREATE PROCEDURE `login` (in var_username varchar(45), in var_pass varchar(45), out var_role int)
BEGIN
	declare var_user_role enum('amministratore', 'bibliotecario');
    
    select `ruolo` from `user`
    where `username` = var_username and `password` = md5(var_pass)
    into var_user_role;
    
    if var_user_role = 'amministratore' then
		set var_role = 1;
	elseif var_user_role = 'bibliotecario' then
		set var_role = 2;
	else
		set var_role = 3;
	end if;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure aggiungi_utente
-- -----------------------------------------------------

USE `CircuitoDiBiblioteche`;
DROP procedure IF EXISTS `CircuitoDiBiblioteche`.`aggiungi_utente`;

DELIMITER $$
USE `CircuitoDiBiblioteche`$$
CREATE PROCEDURE `aggiungi_utente` (in var_CF varchar(16), in var_nome varchar(45), in var_cognome varchar(45), in var_indirizzo varchar(45), in var_data_nascita date)
BEGIN
	insert into `utente` values (var_CF, var_nome, var_cognome, var_data_nascita, var_indirizzo);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure aggiungi_contatto
-- -----------------------------------------------------

USE `CircuitoDiBiblioteche`;
DROP procedure IF EXISTS `CircuitoDiBiblioteche`.`aggiungi_contatto`;

DELIMITER $$
USE `CircuitoDiBiblioteche`$$
CREATE PROCEDURE `aggiungi_contatto` (in var_recapito varchar(45), in var_mezzo_comunicazione varchar(45), in var_CF varchar(16))
BEGIN
	insert into `contatto` values (var_recapito, var_mezzo_comunicazione, var_CF);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure aggiungi_contatto_preferito
-- -----------------------------------------------------

USE `CircuitoDiBiblioteche`;
DROP procedure IF EXISTS `CircuitoDiBiblioteche`.`aggiungi_contatto_preferito`;

DELIMITER $$
USE `CircuitoDiBiblioteche`$$
CREATE PROCEDURE `aggiungi_contatto_preferito` (in var_mezzo_comunicazione_preferito varchar(45), in var_CF varchar(16))
BEGIN
	insert into `contatto_preferito` values (var_CF, var_mezzo_comunicazione_preferito);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure crea_user
-- -----------------------------------------------------

USE `CircuitoDiBiblioteche`;
DROP procedure IF EXISTS `CircuitoDiBiblioteche`.`crea_user`;

DELIMITER $$
USE `CircuitoDiBiblioteche`$$
CREATE PROCEDURE `crea_user` (in username varchar(45), in pass varchar(45), in ruolo varchar(45))
BEGIN
	insert into `user` values (username, md5(pass), ruolo);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure aggiungi_copia
-- -----------------------------------------------------

USE `CircuitoDiBiblioteche`;
DROP procedure IF EXISTS `CircuitoDiBiblioteche`.`aggiungi_copia`;

DELIMITER $$
USE `CircuitoDiBiblioteche`$$
CREATE PROCEDURE `aggiungi_copia` (in var_ISBN varchar(13), in var_titolo varchar(45), in var_autore varchar(45), in var_biblioteca varchar(15), in var_scaffale int, in var_ripiano int, out var_ID int)
BEGIN
	declare var_count int;
    
    declare exit handler for sqlexception
    begin
		rollback;	-- rollback any changes made in the transaction
        resignal;	-- raise again the sql exception to the caller
	end;
    
    set transaction isolation level repeatable read;
    start transaction;
    
		select count(*) from `libro` where `ISBN` = var_ISBN into var_count;
		if var_count = 0 then
			insert into `libro` values (var_ISBN, var_titolo, var_autore);
		end if;
    
		insert into `copia_di_libro` (`biblioteca_ubicazione`, `libro`, `stato`, `scaffale`, `ripiano`, `data_ultima_restituzione_copia`) values (var_biblioteca, var_ISBN, 'disponibile', var_scaffale, var_ripiano, curdate());
		set var_ID = last_insert_id();
    
		select count(*) from `disponibilità` where `numero_biblioteca` = var_biblioteca and `ISBN_libro` = var_ISBN into var_count;
		if var_count = 0 then
			insert into `disponibilità` values (var_biblioteca, var_ISBN, 1, 1, curdate());
		else
			update `disponibilità` set `quantità_totale` = `quantità_totale`+1 where `numero_biblioteca` = var_biblioteca and `ISBN_libro` = var_ISBN;
			update `disponibilità` set `quantità` = `quantità`+1 where `numero_biblioteca` = var_biblioteca and `ISBN_libro` = var_ISBN;
		end if;
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure termina_prestito
-- -----------------------------------------------------

USE `CircuitoDiBiblioteche`;
DROP procedure IF EXISTS `CircuitoDiBiblioteche`.`termina_prestito`;

DELIMITER $$
USE `CircuitoDiBiblioteche`$$
CREATE PROCEDURE `termina_prestito` (in var_copia int, out tar float)
BEGIN
	declare var_libro varchar(13);
    declare var_biblioteca_partenza varchar(15);
    declare var_utente varchar(16);
    declare var_data_inizio date;
    declare var_durata varchar(45);
    declare scad date;
    declare num_giorni_ritardo int;
    declare var_count int;
    
	declare exit handler for sqlexception
    begin
		rollback;	-- rollback any changes made in the transaction
        resignal;	-- raise again the sql exception to the caller
	end;
    
    set tar = 0;
    
    set transaction isolation level repeatable read;
    start transaction;
    
		select count(*) from `copia_di_libro` where `ID` = var_copia into var_count;
        if var_count = 0 then
			signal sqlstate '45001';
		end if;

		select `libro`, `biblioteca_ubicazione` from `copia_di_libro` where `ID` = var_copia into var_libro, var_biblioteca_partenza;
    
		update `copia_di_libro` set `stato` = 'disponibile' where `ID` = var_copia;
		update `copia_di_libro` set `data_ultima_restituzione_copia` = curdate() where `ID` = var_copia;
    
		update `disponibilità` set `quantità` = `quantità`+1 where `numero_biblioteca` = var_biblioteca_partenza and `ISBN_libro` = var_libro;
		update `disponibilità` set `data_ultima_restituzione_libro` = curdate() where `numero_biblioteca` = var_biblioteca_partenza and `ISBN_libro` = var_libro;
    
		select `utente_destinatario`, `data_inizio`, `durata_prevista` from `prestito` where `copia_prestata` = var_copia into var_utente, var_data_inizio, var_durata;
		delete from `prestito` where `copia_prestata` = var_copia;
        delete from `trasferimento` where `copia_trasferita` = var_copia;
    
		if var_durata = '1 mese' then
			select date_add(var_data_inizio, interval 30 day) into scad;
		elseif var_durata = '2 mesi' then
			select date_add(var_data_inizio, interval 60 day) into scad;
		elseif var_durata = '3 mesi' then
			select date_add(var_data_inizio, interval 90 day) into scad;
		end if;
    
		select datediff(curdate(), scad) into num_giorni_ritardo;
        
        select count(*) from `tariffa`
        where `inizio_prestito` = var_data_inizio and `restituzione` = curdate() and `durata_pattuita_prestito` = var_durata
        into var_count;
        
		if num_giorni_ritardo > 0 and num_giorni_ritardo <= 10 then
			set tar = num_giorni_ritardo*0.10;
            if var_count = 0 then
				insert into `tariffa` values (var_data_inizio, curdate(), var_durata, tar);
			end if;
			insert into `penale` values (var_copia, var_utente, var_data_inizio, curdate(), var_durata);
            
		elseif num_giorni_ritardo > 10 then
			set tar = 1.00 + (num_giorni_ritardo - 10)*0.50;
            if var_count = 0 then
				insert into `tariffa` values (var_data_inizio, curdate(), var_durata, tar);
			end if;
			insert into `penale` values (var_copia, var_utente, var_data_inizio, curdate(), var_durata);
		end if;
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure report_prestiti
-- -----------------------------------------------------

USE `CircuitoDiBiblioteche`;
DROP procedure IF EXISTS `CircuitoDiBiblioteche`.`report_prestiti`;

DELIMITER $$
USE `CircuitoDiBiblioteche`$$
CREATE PROCEDURE `report_prestiti` (in var_biblioteca_corrente varchar(15))
BEGIN    
	declare exit handler for sqlexception
    begin
		rollback;	-- rollback any changes made in the transaction
        resignal;	-- raise again the sql exception to the caller
	end;
    
    drop temporary table if exists `info_copie_prestate`;
    create temporary table `info_copie_prestate` (
		`ID copia` int,
        `ISBN libro` varchar(13),
        `titolo libro` varchar(45),
		`autore libro` varchar(45),
        `data` date,
        `durata prevista` varchar(45),
        `CF utente` varchar(16)
	);
    
	set transaction isolation level repeatable read;
    start transaction;
        
		insert into `info_copie_prestate`
		select `ID`, `ISBN`, `titolo`, `autore`, `data_inizio`, `durata_prevista`, `utente_destinatario`
		from `copia_di_libro` join `libro` on `libro` = `ISBN` join `prestito` on `ID` = `copia_prestata`
		where `stato` = 'in prestito' and `biblioteca_ubicazione` = var_biblioteca_corrente;
	
		insert into `info_copie_prestate`
		select `ID`, `ISBN`, `titolo`, `autore`, `data_inizio`, `durata_prevista`, `utente_destinatario`
		from `copia_di_libro` join `libro` on `libro` = `ISBN` join `prestito` on `ID` = `copia_prestata` join `trasferimento` on `ID` = `copia_trasferita`
		where `stato` = 'trasferita' and `biblioteca_destinazione` = var_biblioteca_corrente;
    
		select * from `info_copie_prestate` order by `data`, `durata prevista`;
    
		select distinct `CF_utente` as `CF utente`, `nome_utente` as `nome`, `cognome_utente` as `cognome`, `data_nascita_utente` as `nascita`, `indirizzo_utente` as `indirizzo`, `mezzo_comunicazione_preferito` as `mezzo comunicaz preferito`
		from `info_copie_prestate` join `utente` on `CF utente` = `CF_utente` join `contatto_preferito` on `CF_utente` = `codice_fiscale_utente`
		order by `CF_utente`;
    
		select distinct `CF utente`, `recapito`, `mezzo_comunicazione` as `mezzo comunicazione`
		from `info_copie_prestate` join `contatto` on `CF utente` = `utente`
		order by `CF utente`;
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure dismetti_copie
-- -----------------------------------------------------

USE `CircuitoDiBiblioteche`;
DROP procedure IF EXISTS `CircuitoDiBiblioteche`.`dismetti_copie`;

DELIMITER $$
USE `CircuitoDiBiblioteche`$$
CREATE PROCEDURE `dismetti_copie` ()
BEGIN
    
	declare exit handler for sqlexception
    begin
		rollback;	-- rollback any changes made in the transaction
        resignal;	-- raise again the sql exception to the caller
	end;
    
	drop temporary table if exists `libri_da_dismettere`;
	create temporary table `libri_da_dismettere` (
		`ISBN libro` varchar(13),
        `numero biblioteca` varchar(15)
	);
    
    set transaction isolation level read committed;
    start transaction;
        
		insert into `libri_da_dismettere`
		select `ISBN_libro`, `numero_biblioteca` from `disponibilità`
		where `quantità` > 0 and `quantità` = `quantità_totale` and `data_ultima_restituzione_libro` < (now() - interval 3652 day);
        
		update `copia_di_libro` set `stato` = 'dismessa' where (`libro`, `biblioteca_ubicazione`) in (select * from `libri_da_dismettere`);
		delete from `disponibilità` where (`ISBN_libro`, `numero_biblioteca`) in (select * from `libri_da_dismettere`);
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure ottieni_ISBN
-- -----------------------------------------------------

USE `CircuitoDiBiblioteche`;
DROP procedure IF EXISTS `CircuitoDiBiblioteche`.`ottieni_ISBN`;

DELIMITER $$
USE `CircuitoDiBiblioteche`$$
CREATE PROCEDURE `ottieni_ISBN` (in var_titolo varchar(45), in var_autore varchar(45))
BEGIN
	set transaction read only;
    set transaction isolation level read committed;
		select `ISBN` from `libro` where `titolo` = var_titolo and `autore` = var_autore order by `ISBN`;
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure aggiungi_turno
-- -----------------------------------------------------

USE `CircuitoDiBiblioteche`;
DROP procedure IF EXISTS `CircuitoDiBiblioteche`.`aggiungi_turno`;

DELIMITER $$
USE `CircuitoDiBiblioteche`$$
CREATE PROCEDURE `aggiungi_turno` (in var_bibliotecario varchar(16), in var_data date, in var_orario_inizio time, in var_orario_fine time)
BEGIN
	insert into `turno` values(var_bibliotecario, var_data, var_orario_inizio, var_orario_fine);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure report_biblioteche_scoperte
-- -----------------------------------------------------

USE `CircuitoDiBiblioteche`;
DROP procedure IF EXISTS `CircuitoDiBiblioteche`.`report_biblioteche_scoperte`;

DELIMITER $$
USE `CircuitoDiBiblioteche`$$
CREATE PROCEDURE `report_biblioteche_scoperte` (in data1 date, in data2 date)
BEGIN
	declare var_data date;
    declare var_biblioteca varchar(15);
    declare var_indirizzo varchar(45);
    declare var_responsabile varchar(45);
    declare var_giorno_sett int;
    declare var_inizio_turno time;
    declare var_fine_turno time;
    declare var_fine_buco time;
    declare var_count int;
    
    declare done int default false;
    declare cur_bibl cursor for select `numero_telefono`, `indirizzo_biblioteca`, `responsabile` from `biblioteca`;
    declare cur_turni cursor for select `orario_inizio_turno`, `orario_fine_turno` from `turno` join `bibliotecario` on `bibliotecario` = `CF_bibliotecario` where `data` = var_data and `biblioteca_impiego` = var_biblioteca;
    declare continue handler for not found set done = true;
    
	declare exit handler for sqlexception
    begin
		rollback;	-- rollback any changes made in the transaction
        resignal;	-- raise again the sql exception to the caller
	end;
    
    if datediff(data2, data1) < 0 then
		signal sqlstate '45001';
	end if;
    
    drop temporary table if exists `biblioteca_scoperta`;
    create temporary table `biblioteca_scoperta` (
		`data` date,
        `ora inizio buco` time,
        `ora fine buco` time,
        `telefono bibl` varchar(15),
        `indirizzo bibl` varchar(45),
        `responsabile bibl` varchar(45)
	);
    
    set var_data = data1;
    set transaction isolation level repeatable read;
    start transaction;
    
		date_loop: loop
		
			select weekday(var_data) into var_giorno_sett;
			open cur_bibl;
			bibl_loop: loop
			
				fetch cur_bibl into var_biblioteca, var_indirizzo, var_responsabile;
				if done then
					leave bibl_loop;
				end if;
            
				insert into `biblioteca_scoperta`
				select var_data, `orario_inizio_apertura`, `orario_fine_apertura`, var_biblioteca, var_indirizzo, var_responsabile
                from `apertura` where `biblioteca` = var_biblioteca and `giorno_settimanale` = var_giorno_sett;
            
				open cur_turni;
				turni_loop: loop
            
					fetch cur_turni into var_inizio_turno, var_fine_turno;
					if done then
						leave turni_loop;
					end if;
                    
                    select count(*) from `biblioteca_scoperta`
					where time_to_sec(timediff(var_inizio_turno, `ora inizio buco`)) > 0 and time_to_sec(timediff(`ora fine buco`, var_fine_turno)) > 0
						and `data` = var_data and `telefono bibl` = var_biblioteca
                    into var_count;
					
                    if var_count > 0 then
						select `ora fine buco` from `biblioteca_scoperta`
						where time_to_sec(timediff(var_inizio_turno, `ora inizio buco`)) > 0 and time_to_sec(timediff(`ora fine buco`, var_fine_turno)) > 0
							and `data` = var_data and `telefono bibl` = var_biblioteca
						into var_fine_buco;
                    
						insert into `biblioteca_scoperta` values(var_data, var_fine_turno, var_fine_buco, var_biblioteca, var_indirizzo, var_responsabile);
						update `biblioteca_scoperta` set `ora fine buco` = var_inizio_turno 
							where time_to_sec(timediff(var_inizio_turno, `ora inizio buco`)) > 0 and time_to_sec(timediff(`ora fine buco`, var_fine_turno)) > 0
							and `data` = var_data and `telefono bibl` = var_biblioteca;
					end if;
                
					delete from `biblioteca_scoperta` where time_to_sec(timediff(var_inizio_turno, `ora inizio buco`)) <= 0 and time_to_sec(timediff(`ora fine buco`, var_fine_turno)) <= 0
                    and `data` = var_data and `telefono bibl` = var_biblioteca;
                    
					update `biblioteca_scoperta` set `ora inizio buco` = var_fine_turno 
						where time_to_sec(timediff(var_inizio_turno, `ora inizio buco`)) <= 0 and time_to_sec(timediff(`ora fine buco`, var_fine_turno)) > 0 and time_to_sec(timediff(var_fine_turno, `ora inizio buco`)) > 0
                        and `data` = var_data and `telefono bibl` = var_biblioteca;
                    
					update `biblioteca_scoperta` set `ora fine buco` = var_inizio_turno
						where time_to_sec(timediff(var_inizio_turno, `ora inizio buco`)) > 0 and time_to_sec(timediff(`ora fine buco`, var_fine_turno)) <= 0 and time_to_sec(timediff(var_inizio_turno, `ora fine buco`)) < 0
                        and `data` = var_data and `telefono bibl` = var_biblioteca;
                
				end loop;
				close cur_turni;
				set done = false;
            
			end loop;
			close cur_bibl;
			set done = false;
        
			select date_add(var_data, interval 1 day) into var_data;
			if datediff(data2, var_data) < 0 then
				leave date_loop;
			end if;
		end loop;
    
		select * from `biblioteca_scoperta`;
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure aggiungi_bibliotecario
-- -----------------------------------------------------

USE `CircuitoDiBiblioteche`;
DROP procedure IF EXISTS `CircuitoDiBiblioteche`.`aggiungi_bibliotecario`;

DELIMITER $$
USE `CircuitoDiBiblioteche`$$
CREATE PROCEDURE `aggiungi_bibliotecario` (in var_CF varchar(16), in var_nome varchar(45), in var_cognome varchar(45), in var_luogo_nascita varchar(45), in var_titolo_studio varchar(45), in var_biblioteca varchar(15), in var_username varchar(45), in var_data_nascita date)
BEGIN
	insert into `bibliotecario` values (var_CF, var_nome, var_cognome, var_data_nascita, var_luogo_nascita, var_titolo_studio, var_biblioteca, var_username);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure inizia_prestito
-- -----------------------------------------------------

USE `CircuitoDiBiblioteche`;
DROP procedure IF EXISTS `CircuitoDiBiblioteche`.`inizia_prestito`;

DELIMITER $$
USE `CircuitoDiBiblioteche`$$
CREATE PROCEDURE `inizia_prestito` (in var_libro varchar(13), in var_biblioteca_corrente varchar(15), in var_utente varchar(16), in var_durata varchar(45))
BEGIN
	declare var_ID int;
	declare var_count int;
    
	declare exit handler for sqlexception
    begin
		rollback;	-- rollback any changes made in the transaction
        resignal;	-- raise again the sql exception to the caller
	end;
    
    drop temporary table if exists `da_trasferire`;
    create temporary table `da_trasferire` (
		`da trasferire` smallint
	);
    
    set transaction isolation level repeatable read;
    start transaction;
    
		select count(*) from `copia_di_libro`
		where `biblioteca_ubicazione` = var_biblioteca_corrente and `libro` = var_libro and `stato` = 'disponibile' into var_count;
    
		if var_count > 0 then
			insert into `da_trasferire` values ('0');
            select * from `da_trasferire`;
        
			select min(`ID`) from `copia_di_libro`
			where `biblioteca_ubicazione` = var_biblioteca_corrente and `libro` = var_libro and `stato` = 'disponibile' into var_ID;
        
			select `ID`, `scaffale`, `ripiano` from `copia_di_libro` where `ID` = var_ID;
        
			update `copia_di_libro` set `stato` = 'in prestito' where `ID` = var_ID;
			insert into `prestito` values (var_ID, var_utente, curdate(), var_durata);
        
			update `disponibilità` set `quantità` = `quantità`-1 where `numero_biblioteca` = var_biblioteca_corrente and `ISBN_libro` = var_libro;
	
		else
			insert into `da_trasferire` values ('1');
            select * from `da_trasferire`;
        
			select `numero_telefono` as `telefono bibl`, `indirizzo_biblioteca` as `indirizzo bibl`, `responsabile` as `responsabile bibl`
			from `disponibilità` join `biblioteca` on `numero_biblioteca` = `numero_telefono`
			where `ISBN_libro` = var_libro and `quantità` > 0;
		end if;
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure inizia_trasferimento
-- -----------------------------------------------------

USE `CircuitoDiBiblioteche`;
DROP procedure IF EXISTS `CircuitoDiBiblioteche`.`inizia_trasferimento`;

DELIMITER $$
USE `CircuitoDiBiblioteche`$$
CREATE PROCEDURE `inizia_trasferimento` (in var_libro varchar(13), in var_biblioteca_destinazione varchar(15), in var_biblioteca_partenza varchar(15), in var_utente varchar(16), in var_durata varchar(45))
BEGIN
	declare var_ID int;
    declare var_count int;
    
	declare exit handler for sqlexception
    begin
		rollback;	-- rollback any changes made in the transaction
        resignal;	-- raise again the sql exception to the caller
	end;
    
    set transaction isolation level repeatable read;
    start transaction;
    
		select count(*) from `copia_di_libro`
		where `biblioteca_ubicazione` = var_biblioteca_partenza and `libro` = var_libro and `stato` = 'disponibile' into var_count;
    
		if var_count > 0 then
			select min(`ID`) from `copia_di_libro`
			where `biblioteca_ubicazione` = var_biblioteca_partenza and `libro` = var_libro and `stato` = 'disponibile' into var_ID;
        
			select `ID`, `scaffale`, `ripiano` from `copia_di_libro` where `ID` = var_ID;
        
			update `copia_di_libro` set `stato` = 'trasferita' where `ID` = var_ID;
			insert into `prestito` values (var_ID, var_utente, curdate(), var_durata);
			insert into `trasferimento` values (var_ID, var_biblioteca_destinazione);
        
			update `disponibilità` set `quantità` = `quantità`-1 where `numero_biblioteca` = var_biblioteca_partenza and `ISBN_libro` = var_libro;
		else
			signal sqlstate '45001';
		end if;
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure trova_sostituti
-- -----------------------------------------------------

USE `CircuitoDiBiblioteche`;
DROP procedure IF EXISTS `CircuitoDiBiblioteche`.`trova_sostituti`;

DELIMITER $$
USE `CircuitoDiBiblioteche`$$
CREATE PROCEDURE `trova_sostituti` (in bibliotecario_malato varchar(16), in data_mal date)
BEGIN    
	declare exit handler for sqlexception
    begin
		rollback;	-- rollback any changes made in the transaction
        resignal;	-- raise again the sql exception to the caller
	end;
    
    set transaction isolation level read committed;
    start transaction;
    
		select `CF_bibliotecario` as `CF bibliotecario`, `nome_bibliotecario` as `nome`, `cognome_bibliotecario` as `cognome`, `data_nascita_bibliotecario` as `nascita`, `luogo_nascita` as `luogo nascita`, `titolo_studio` as `titolo di studio`
        from `bibliotecario` where `biblioteca_impiego` = (select b.`biblioteca_impiego` from `bibliotecario` b where b.`CF_bibliotecario` = bibliotecario_malato)
        and `CF_bibliotecario` not in (select `bibliotecario` from `turno` where `data` = data_mal)
        and `CF_bibliotecario` not in (select `bibliotecario_sostituto` from `malattia` where `data_malattia` = data_mal);
        
	commit;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure aggiungi_malattia
-- -----------------------------------------------------

USE `CircuitoDiBiblioteche`;
DROP procedure IF EXISTS `CircuitoDiBiblioteche`.`aggiungi_malattia`;

DELIMITER $$
USE `CircuitoDiBiblioteche`$$
CREATE PROCEDURE `aggiungi_malattia` (in bibliotecario_malato varchar(16), in motivo varchar(45), in bibliotecario_sostituto varchar(16), in data_malattia date)
BEGIN
	insert into `malattia` values (bibliotecario_malato, data_malattia, motivo, bibliotecario_sostituto);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure ottieni_biblioteca_impiego
-- -----------------------------------------------------

USE `CircuitoDiBiblioteche`;
DROP procedure IF EXISTS `CircuitoDiBiblioteche`.`ottieni_biblioteca_impiego`;

DELIMITER $$
USE `CircuitoDiBiblioteche`$$
CREATE PROCEDURE `ottieni_biblioteca_impiego` (in username varchar(45), out biblioteca varchar(15))
BEGIN
	set transaction read only;
    set transaction isolation level read committed;
		select `biblioteca_impiego` from `bibliotecario` where `username_bibliotecario` = username into biblioteca;
	commit;
END$$

DELIMITER ;
USE `CircuitoDiBiblioteche`;

DELIMITER $$

USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`biblioteca_BEFORE_INSERT` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`biblioteca_BEFORE_INSERT` BEFORE INSERT ON `biblioteca` FOR EACH ROW
BEGIN
	if not NEW.numero_telefono regexp '^[0-9]{4,15}$' then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`biblioteca_BEFORE_UPDATE` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`biblioteca_BEFORE_UPDATE` BEFORE UPDATE ON `biblioteca` FOR EACH ROW
BEGIN
	if not NEW.numero_telefono regexp '^[0-9]{4,15}$' then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`libro_BEFORE_INSERT` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`libro_BEFORE_INSERT` BEFORE INSERT ON `libro` FOR EACH ROW
BEGIN
	if not (NEW.ISBN regexp '^[0-9]{9,9}X$' or NEW.ISBN regexp '^[0-9]{10,10}$' or NEW.ISBN regexp '^[0-9]{13,13}$') then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`libro_BEFORE_UPDATE` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`libro_BEFORE_UPDATE` BEFORE UPDATE ON `libro` FOR EACH ROW
BEGIN
	if not (NEW.ISBN regexp '^[0-9]{9,9}X$' or NEW.ISBN regexp '^[0-9]{10,10}$' or NEW.ISBN regexp '^[0-9]{13,13}$') then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`utente_BEFORE_INSERT` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`utente_BEFORE_INSERT` BEFORE INSERT ON `utente` FOR EACH ROW
BEGIN
	if not NEW.CF_utente regexp '^[A-Z]{6,6}[0-9]{2,2}[A-Z][0-9]{2,2}[A-Z][0-9]{3,3}[A-Z]$' then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`utente_BEFORE_UPDATE` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`utente_BEFORE_UPDATE` BEFORE UPDATE ON `utente` FOR EACH ROW
BEGIN
	if not NEW.CF_utente regexp '^[A-Z]{6,6}[0-9]{2,2}[A-Z][0-9]{2,2}[A-Z][0-9]{3,3}[A-Z]$' then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`bibliotecario_BEFORE_INSERT` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`bibliotecario_BEFORE_INSERT` BEFORE INSERT ON `bibliotecario` FOR EACH ROW
BEGIN
	if not NEW.CF_bibliotecario regexp '^[A-Z]{6,6}[0-9]{2,2}[A-Z][0-9]{2,2}[A-Z][0-9]{3,3}[A-Z]$' then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`bibliotecario_BEFORE_UPDATE` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`bibliotecario_BEFORE_UPDATE` BEFORE UPDATE ON `bibliotecario` FOR EACH ROW
BEGIN
	if not NEW.CF_bibliotecario regexp '^[A-Z]{6,6}[0-9]{2,2}[A-Z][0-9]{2,2}[A-Z][0-9]{3,3}[A-Z]$' then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`turno_BEFORE_INSERT` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`turno_BEFORE_INSERT` BEFORE INSERT ON `turno` FOR EACH ROW
BEGIN
	declare diff time;
    declare seconds int;
    
    select timediff(NEW.orario_fine_turno, NEW.orario_inizio_turno) into diff;
    select time_to_sec(diff) into seconds;
    
    if seconds > 28800 or seconds <= 0 then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`turno_BEFORE_INSERT_1` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`turno_BEFORE_INSERT_1` BEFORE INSERT ON `turno` FOR EACH ROW
BEGIN
	declare giorno_sett_turno int;
	declare inizio_apertura time;
    declare fine_apertura time;
    declare diff_inizio time;
    declare diff_fine time;
    declare seconds_inizio int;
    declare seconds_fine int;
    declare var_count int;
    
    select weekday(NEW.`data`) into giorno_sett_turno;
    
    select count(*) from `bibliotecario` join `apertura` on `biblioteca_impiego` = `biblioteca`
    where `giorno_settimanale` = giorno_sett_turno and `CF_bibliotecario` = NEW.bibliotecario
    into var_count;
    
    if var_count = 0 then
		signal sqlstate '45000';
	end if;
    
    select `orario_inizio_apertura`, `orario_fine_apertura`
    from `bibliotecario` join `apertura` on `biblioteca_impiego` = `biblioteca`
    where `giorno_settimanale` = giorno_sett_turno and `CF_bibliotecario` = NEW.bibliotecario
    into inizio_apertura, fine_apertura;
    
    select timediff(NEW.orario_inizio_turno, inizio_apertura) into diff_inizio;
    select time_to_sec(diff_inizio) into seconds_inizio;
    select timediff(fine_apertura, NEW.orario_fine_turno) into diff_fine;
    select time_to_sec(diff_fine) into seconds_fine;
    
    if seconds_inizio < 0 or seconds_fine < 0 then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`turno_BEFORE_INSERT_2` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`turno_BEFORE_INSERT_2` BEFORE INSERT ON `turno` FOR EACH ROW
BEGIN
	declare count int;
    
    select count(*) from `malattia`
    where `bibliotecario_sostituto` = NEW.bibliotecario and `data_malattia` = NEW.data
    into count;
    
    if count > 0 then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`turno_BEFORE_UPDATE` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`turno_BEFORE_UPDATE` BEFORE UPDATE ON `turno` FOR EACH ROW
BEGIN
	declare diff time;
    declare seconds int;
    
    select timediff(NEW.orario_fine_turno, NEW.orario_inizio_turno) into diff;
    select time_to_sec(diff) into seconds;
    
    if seconds > 28800 or seconds <= 0 then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`turno_BEFORE_UPDATE_1` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`turno_BEFORE_UPDATE_1` BEFORE UPDATE ON `turno` FOR EACH ROW
BEGIN
	declare giorno_sett_turno int;
	declare inizio_apertura time;
    declare fine_apertura time;
    declare diff_inizio time;
    declare diff_fine time;
    declare seconds_inizio int;
    declare seconds_fine int;
    declare var_count int;
    
    select weekday(NEW.`data`) into giorno_sett_turno;
    
    select count(*) from `bibliotecario` join `apertura` on `biblioteca_impiego` = `biblioteca`
    where `giorno_settimanale` = giorno_sett_turno and `CF_bibliotecario` = NEW.bibliotecario
    into var_count;
    
    if var_count = 0 then
		signal sqlstate '45000';
	end if;
    
    select `orario_inizio_apertura`, `orario_fine_apertura`
    from `bibliotecario` join `apertura` on `biblioteca_impiego` = `biblioteca`
    where `giorno_settimanale` = giorno_sett_turno and `CF_bibliotecario` = NEW.bibliotecario
    into inizio_apertura, fine_apertura;
    
    select timediff(NEW.orario_inizio_turno, inizio_apertura) into diff_inizio;
    select time_to_sec(diff_inizio) into seconds_inizio;
    select timediff(fine_apertura, NEW.orario_fine_turno) into diff_fine;
    select time_to_sec(diff_fine) into seconds_fine;
    
    if seconds_inizio < 0 or seconds_fine < 0 then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`turno_BEFORE_UPDATE_2` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`turno_BEFORE_UPDATE_2` BEFORE UPDATE ON `turno` FOR EACH ROW
BEGIN
	declare count int;
    
    select count(*) from `malattia`
    where `bibliotecario_sostituto` = NEW.bibliotecario and `data_malattia` = NEW.data
    into count;
    
    if count > 0 then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`malattia_BEFORE_INSERT` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`malattia_BEFORE_INSERT` BEFORE INSERT ON `malattia` FOR EACH ROW
BEGIN
	declare count int;
    
	select count(*) from `turno`
    where `bibliotecario` = NEW.bibliotecario_malato and `data` = NEW.data_malattia
    into count;
    
    if count = 0 then
		signal sqlstate '45000';
	end if;
    
    select count(*) from `turno`
    where `bibliotecario` = NEW.bibliotecario_sostituto and `data` = NEW.data_malattia
    into count;
    
    if count > 0 then
		signal sqlstate '45000';
	end if;
    
    select count(*) from `bibliotecario` b1 join `bibliotecario` b2 on b1.`biblioteca_impiego` = b2.`biblioteca_impiego`
    where b1.`CF_bibliotecario` = NEW.bibliotecario_malato and b2.`CF_bibliotecario` = NEW.bibliotecario_sostituto
    into count;
    
    if count = 0 then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`malattia_BEFORE_UPDATE` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`malattia_BEFORE_UPDATE` BEFORE UPDATE ON `malattia` FOR EACH ROW
BEGIN
	declare count int;
    
	select count(*) from `turno`
    where `bibliotecario` = NEW.bibliotecario_malato and `data` = NEW.data_malattia
    into count;
    
    if count = 0 then
		signal sqlstate '45000';
	end if;
    
    select count(*) from `turno`
    where `bibliotecario` = NEW.bibliotecario_sostituto and `data` = NEW.data_malattia
    into count;
    
    if count > 0 then
		signal sqlstate '45000';
	end if;
    
	select count(*) from `bibliotecario` b1 join `bibliotecario` b2 on b1.`biblioteca_impiego` = b2.`biblioteca_impiego`
    where b1.`CF_bibliotecario` = NEW.bibliotecario_malato and b2.`CF_bibliotecario` = NEW.bibliotecario_sostituto
    into count;
    
    if count = 0 then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`apertura_BEFORE_INSERT` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`apertura_BEFORE_INSERT` BEFORE INSERT ON `apertura` FOR EACH ROW
BEGIN
	declare diff time;
    declare seconds int;
    
    select timediff(NEW.orario_fine_apertura, NEW.orario_inizio_apertura) into diff;
    select time_to_sec(diff) into seconds;
    
    if seconds <= 0 then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`apertura_BEFORE_INSERT_1` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`apertura_BEFORE_INSERT_1` BEFORE INSERT ON `apertura` FOR EACH ROW
BEGIN
	if NEW.giorno_settimanale > 6 then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`apertura_BEFORE_UPDATE` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`apertura_BEFORE_UPDATE` BEFORE UPDATE ON `apertura` FOR EACH ROW
BEGIN
	declare diff time;
    declare seconds int;
    
    select timediff(NEW.orario_fine_apertura, NEW.orario_inizio_apertura) into diff;
    select time_to_sec(diff) into seconds;
    
    if seconds <= 0 then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`apertura_BEFORE_UPDATE_1` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`apertura_BEFORE_UPDATE_1` BEFORE UPDATE ON `apertura` FOR EACH ROW
BEGIN
	if NEW.giorno_settimanale > 6 then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`disponibilità_BEFORE_INSERT` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`disponibilità_BEFORE_INSERT` BEFORE INSERT ON `disponibilità` FOR EACH ROW
BEGIN
	if NEW.quantità > NEW.quantità_totale then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`disponibilità_BEFORE_UPDATE` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`disponibilità_BEFORE_UPDATE` BEFORE UPDATE ON `disponibilità` FOR EACH ROW
BEGIN
	if NEW.quantità > NEW.quantità_totale then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`copia_di_libro_BEFORE_INSERT` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`copia_di_libro_BEFORE_INSERT` BEFORE INSERT ON `copia_di_libro` FOR EACH ROW
BEGIN
	declare dieci_anni_fa date;
    declare giorni_alla_dismissione int;
    
    select date_sub(curdate(), interval 3652 day) into dieci_anni_fa;
    select datediff(NEW.data_ultima_restituzione_copia, dieci_anni_fa) into giorni_alla_dismissione;
    
    if giorni_alla_dismissione >= 0 and NEW.stato = 'dismessa' then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`copia_di_libro_BEFORE_UPDATE` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`copia_di_libro_BEFORE_UPDATE` BEFORE UPDATE ON `copia_di_libro` FOR EACH ROW
BEGIN
	declare dieci_anni_fa date;
    declare giorni_alla_dismissione int;
    
    select date_sub(curdate(), interval 3652 day) into dieci_anni_fa;
    select datediff(NEW.data_ultima_restituzione_copia, dieci_anni_fa) into giorni_alla_dismissione;
    
    if giorni_alla_dismissione >= 0 and NEW.stato = 'dismessa' then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`penale_BEFORE_INSERT` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`penale_BEFORE_INSERT` BEFORE INSERT ON `penale` FOR EACH ROW
BEGIN
	declare scad date;
    declare num_giorni_ritardo int;
    
    if NEW.durata_prevista_prestito = '1 mese' then
		select date_add(NEW.data_inizio_prestito, INTERVAL 30 DAY) into scad;
	elseif NEW.durata_prevista_prestito = '2 mesi' then
		select date_add(NEW.data_inizio_prestito, INTERVAL 60 DAY) into scad;
	elseif NEW.durata_prevista_prestito = '3 mesi' then
		select date_add(NEW.data_inizio_prestito, INTERVAL 90 DAY) into scad;
	end if;
    
    select datediff(NEW.data_restituzione, scad) into num_giorni_ritardo;
    if num_giorni_ritardo <= 0 then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`penale_BEFORE_INSERT_1` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`penale_BEFORE_INSERT_1` BEFORE INSERT ON `penale` FOR EACH ROW
BEGIN
	declare count int;
    
    select count(*) from `tariffa`
    where `inizio_prestito` = NEW.data_inizio_prestito and `restituzione` = NEW.data_restituzione and `durata_pattuita_prestito` = NEW.durata_prevista_prestito
    into count;
    
    if count = 0 then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`penale_BEFORE_UPDATE` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`penale_BEFORE_UPDATE` BEFORE UPDATE ON `penale` FOR EACH ROW
BEGIN
	declare scad date;
    declare num_giorni_ritardo int;
    
    if NEW.durata_prevista_prestito = '1 mese' then
		select date_add(NEW.data_inizio_prestito, INTERVAL 30 DAY) into scad;
	elseif NEW.durata_prevista_prestito = '2 mesi' then
		select date_add(NEW.data_inizio_prestito, INTERVAL 60 DAY) into scad;
	elseif NEW.durata_prevista_prestito = '3 mesi' then
		select date_add(NEW.data_inizio_prestito, INTERVAL 90 DAY) into scad;
	end if;
    
    select datediff(NEW.data_restituzione, scad) into num_giorni_ritardo;
    if num_giorni_ritardo <= 0 then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`penale_BEFORE_UPDATE_1` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`penale_BEFORE_UPDATE_1` BEFORE UPDATE ON `penale` FOR EACH ROW
BEGIN
	declare count int;
    
    select count(*) from `tariffa`
    where `inizio_prestito` = NEW.data_inizio_prestito and `restituzione` = NEW.data_restituzione and `durata_pattuita_prestito` = NEW.durata_prevista_prestito
    into count;
    
    if count = 0 then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`tariffa_BEFORE_INSERT` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`tariffa_BEFORE_INSERT` BEFORE INSERT ON `tariffa` FOR EACH ROW
BEGIN
	declare scad date;
    declare num_giorni_ritardo int;
    declare tariffa_esatta float;
    
    if NEW.durata_pattuita_prestito = '1 mese' then
		select date_add(NEW.inizio_prestito, INTERVAL 30 DAY) into scad;
	elseif NEW.durata_pattuita_prestito = '2 mesi' then
		select date_add(NEW.inizio_prestito, INTERVAL 60 DAY) into scad;
	elseif NEW.durata_pattuita_prestito = '3 mesi' then
		select date_add(NEW.inizio_prestito, INTERVAL 90 DAY) into scad;
	end if;
    
    select datediff(NEW.restituzione, scad) into num_giorni_ritardo;
    if num_giorni_ritardo <= 0 then
		signal sqlstate '45000';
	elseif num_giorni_ritardo <= 10 then
		set tariffa_esatta = num_giorni_ritardo*0.10;
        if NEW.valore_tariffa <> tariffa_esatta then
			signal sqlstate '45000';
		end if;
	else
		set tariffa_esatta = 1.00 + (num_giorni_ritardo - 10)*0.50;
        if NEW.valore_tariffa <> tariffa_esatta then
			signal sqlstate '45000';
		end if;
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`tariffa_BEFORE_UPDATE` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`tariffa_BEFORE_UPDATE` BEFORE UPDATE ON `tariffa` FOR EACH ROW
BEGIN
	declare scad date;
    declare num_giorni_ritardo int;
    declare tariffa_esatta float;
    
    if NEW.durata_pattuita_prestito = '1 mese' then
		select date_add(NEW.inizio_prestito, INTERVAL 30 DAY) into scad;
	elseif NEW.durata_pattuita_prestito = '2 mesi' then
		select date_add(NEW.inizio_prestito, INTERVAL 60 DAY) into scad;
	elseif NEW.durata_pattuita_prestito = '3 mesi' then
		select date_add(NEW.inizio_prestito, INTERVAL 90 DAY) into scad;
	end if;
    
    select datediff(NEW.restituzione, scad) into num_giorni_ritardo;
    if num_giorni_ritardo <= 0 then
		signal sqlstate '45000';
	elseif num_giorni_ritardo <= 10 then
		set tariffa_esatta = num_giorni_ritardo*0.10;
        if NEW.valore_tariffa <> tariffa_esatta then
			signal sqlstate '45000';
		end if;
	else
		set tariffa_esatta = 1.00 + (num_giorni_ritardo - 10)*0.50;
        if NEW.valore_tariffa <> tariffa_esatta then
			signal sqlstate '45000';
		end if;
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`contatto_BEFORE_INSERT` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`contatto_BEFORE_INSERT` BEFORE INSERT ON `contatto` FOR EACH ROW
BEGIN
	if NEW.mezzo_comunicazione = 'telefono' or NEW.mezzo_comunicazione = 'cellulare' then
		if not NEW.recapito regexp '^[0-9]{4,15}$' then
			signal sqlstate '45000';
		end if;
	elseif NEW.mezzo_comunicazione = 'email' then
		if not NEW.recapito regexp '^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9._-]@[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]\\.[a-zA-Z]{2,63}$' then
			signal sqlstate '45000';
		end if;
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`contatto_BEFORE_UPDATE` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`contatto_BEFORE_UPDATE` BEFORE UPDATE ON `contatto` FOR EACH ROW
BEGIN
	if NEW.mezzo_comunicazione = 'telefono' or NEW.mezzo_comunicazione = 'cellulare' then
		if not NEW.recapito regexp '^[0-9]{4,15}$' then
			signal sqlstate '45000';
		end if;
	elseif NEW.mezzo_comunicazione = 'email' then
		if not NEW.recapito regexp '^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9._-]@[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9]\\.[a-zA-Z]{2,63}$' then
			signal sqlstate '45000';
		end if;
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`trasferimento_BEFORE_INSERT` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`trasferimento_BEFORE_INSERT` BEFORE INSERT ON `trasferimento` FOR EACH ROW
BEGIN
	declare bibl_part varchar(45);
    
	select `biblioteca_ubicazione` from `copia_di_libro` where `ID` = NEW.copia_trasferita into bibl_part;
    if bibl_part = NEW.biblioteca_destinazione then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`trasferimento_BEFORE_UPDATE` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`trasferimento_BEFORE_UPDATE` BEFORE UPDATE ON `trasferimento` FOR EACH ROW
BEGIN
	declare bibl_part varchar(45);
    
	select `biblioteca_ubicazione` from `copia_di_libro` where `ID` = NEW.copia_trasferita into bibl_part;
    if bibl_part = NEW.biblioteca_destinazione then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`contatto_preferito_BEFORE_INSERT` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`contatto_preferito_BEFORE_INSERT` BEFORE INSERT ON `contatto_preferito` FOR EACH ROW
BEGIN
	declare count int;
    
    select count(*) from `contatto`
    where `utente` = NEW.codice_fiscale_utente and `mezzo_comunicazione` = NEW.mezzo_comunicazione_preferito
    into count;
    
    if count = 0 then
		signal sqlstate '45000';
	end if;
END$$


USE `CircuitoDiBiblioteche`$$
DROP TRIGGER IF EXISTS `CircuitoDiBiblioteche`.`contatto_preferito_BEFORE_UPDATE` $$
USE `CircuitoDiBiblioteche`$$
CREATE DEFINER = CURRENT_USER TRIGGER `CircuitoDiBiblioteche`.`contatto_preferito_BEFORE_UPDATE` BEFORE UPDATE ON `contatto_preferito` FOR EACH ROW
BEGIN
	declare count int;
    
    select count(*) from `contatto`
    where `utente` = NEW.codice_fiscale_utente and `mezzo_comunicazione` = NEW.mezzo_comunicazione_preferito
    into count;
    
    if count = 0 then
		signal sqlstate '45000';
	end if;
END$$


DELIMITER ;
SET SQL_MODE = '';
DROP USER IF EXISTS login;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'login' IDENTIFIED BY 'fm42y7ddm';

GRANT EXECUTE ON procedure `CircuitoDiBiblioteche`.`login` TO 'login';
SET SQL_MODE = '';
DROP USER IF EXISTS bibliotecario;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'bibliotecario' IDENTIFIED BY 'fm42y7ddm';

GRANT EXECUTE ON procedure `CircuitoDiBiblioteche`.`aggiungi_contatto` TO 'bibliotecario';
GRANT EXECUTE ON procedure `CircuitoDiBiblioteche`.`aggiungi_contatto_preferito` TO 'bibliotecario';
GRANT EXECUTE ON procedure `CircuitoDiBiblioteche`.`aggiungi_utente` TO 'bibliotecario';
GRANT EXECUTE ON procedure `CircuitoDiBiblioteche`.`inizia_prestito` TO 'bibliotecario';
GRANT EXECUTE ON procedure `CircuitoDiBiblioteche`.`inizia_trasferimento` TO 'bibliotecario';
GRANT EXECUTE ON procedure `CircuitoDiBiblioteche`.`ottieni_ISBN` TO 'bibliotecario';
GRANT EXECUTE ON procedure `CircuitoDiBiblioteche`.`report_prestiti` TO 'bibliotecario';
GRANT EXECUTE ON procedure `CircuitoDiBiblioteche`.`termina_prestito` TO 'bibliotecario';
GRANT EXECUTE ON procedure `CircuitoDiBiblioteche`.`ottieni_biblioteca_impiego` TO 'bibliotecario';
SET SQL_MODE = '';
DROP USER IF EXISTS amministratore;
SET SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';
CREATE USER 'amministratore' IDENTIFIED BY 'fm42y7ddm';

GRANT EXECUTE ON procedure `CircuitoDiBiblioteche`.`aggiungi_bibliotecario` TO 'amministratore';
GRANT EXECUTE ON procedure `CircuitoDiBiblioteche`.`aggiungi_copia` TO 'amministratore';
GRANT EXECUTE ON procedure `CircuitoDiBiblioteche`.`aggiungi_malattia` TO 'amministratore';
GRANT EXECUTE ON procedure `CircuitoDiBiblioteche`.`aggiungi_turno` TO 'amministratore';
GRANT EXECUTE ON procedure `CircuitoDiBiblioteche`.`crea_user` TO 'amministratore';
GRANT EXECUTE ON procedure `CircuitoDiBiblioteche`.`dismetti_copie` TO 'amministratore';
GRANT EXECUTE ON procedure `CircuitoDiBiblioteche`.`report_biblioteche_scoperte` TO 'amministratore';
GRANT EXECUTE ON procedure `CircuitoDiBiblioteche`.`trova_sostituti` TO 'amministratore';

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

set global event_scheduler = on;
DELIMITER $$

CREATE event IF NOT EXISTS `cleanup_penali_tariffe`
	on schedule
	every 730 day
		on completion preserve

	do
		delete from `penale` where `data_restituzione` < (NOW() - interval 730 day);
		delete from `tariffa` where `restituzione` < (NOW() - interval 730 day);
$$

CREATE event IF NOT EXISTS `cleanup_turni_malattie`
	on schedule
	every 30 day
		on completion preserve

	do
		delete from `malattia` where `data_malattia` < (NOW() - interval 30 day);
		delete from `turno` where `data` < (NOW() - interval 30 day);
$$

DELIMITER ;