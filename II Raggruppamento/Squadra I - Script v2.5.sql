/*
 * Squadra I - Gruppo A2
 * Mariagiovanna Rotundo, Leonardo Vona
 * Versione 2.5
 * 03/12/2019
 */

--drop sequence

DROP SEQUENCE Seq_pk_Persona;

DROP SEQUENCE Seq_pk_Utente;

DROP SEQUENCE Seq_pk_StipendioErogato;
	
DROP SEQUENCE Seq_pk_Veicolo;

DROP SEQUENCE Seq_pk_TipoAssicurazione;

DROP SEQUENCE Seq_pk_Area;

DROP SEQUENCE Seq_pk_TitoloAbbonamento;

DROP SEQUENCE Seq_pk_TipoAbbonamento;

DROP SEQUENCE Seq_pk_Abbonamento;

DROP SEQUENCE Seq_pk_Sede;

DROP SEQUENCE Seq_pk_ParcheggioAutomatico;

DROP SEQUENCE Seq_pk_CodiceSconto;

DROP SEQUENCE Seq_pk_Sanzione;

DROP SEQUENCE Seq_pk_Colonna;

DROP SEQUENCE Seq_pk_Box;

DROP SEQUENCE Seq_pk_TipoTurno;

DROP SEQUENCE Seq_pk_Turno;

DROP SEQUENCE Seq_pk_Sosta;

DROP SEQUENCE Seq_pk_Giorno;

DROP SEQUENCE Seq_pk_Notifica;

DROP SEQUENCE Seq_pk_Carburante;


--drop table

DROP TABLE Notifiche;

DROP TABLE GiorniValidi;

DROP TABLE Giorni;

DROP TABLE SosteAbbonamenti;

DROP TABLE SosteOrarie;

DROP TABLE Soste;

DROP TABLE Turni;

DROP TABLE TipiTurno;

DROP TABLE CarburantiSupportati;

DROP TABLE Carburanti;

DROP TABLE Box;

DROP TABLE Colonne;

DROP TABLE Sanzioni;

DROP TABLE Abbonamenti;

DROP TABLE CodiciSconto;

DROP TABLE TipiAbbonamento;

DROP TABLE TitoliAbbonamento;

DROP TABLE TipiAssicurazione;

DROP TABLE ClientiVeicoli;

DROP TABLE Veicoli;

DROP TABLE Aree;

DROP TABLE Clienti;

DROP TABLE SuperUser;

DROP TABLE Amministratori;

DROP TABLE Operatori;

DROP TABLE ParcheggiAutomatici;

DROP TABLE Responsabili;

DROP TABLE Sedi;

DROP TABLE StipendiErogati;

DROP TABLE Dipendenti;

DROP TABLE Utenti;

DROP TABLE Persone;


--create sequence

CREATE SEQUENCE Seq_pk_Persona
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_Utente
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_StipendioErogato
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_Veicolo
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_TipoAssicurazione
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_Area
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_TipoAbbonamento
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_TitoloAbbonamento
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_Abbonamento
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_Sede
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_ParcheggioAutomatico
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_CodiceSconto
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_Sanzione
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_Colonna
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_Box
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_TipoTurno
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_Turno
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_Sosta
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_Giorno
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_Notifica
	START WITH 5000
	INCREMENT BY 1;

CREATE SEQUENCE Seq_pk_Carburante
	START WITH 5000
	INCREMENT BY 1;

--create table

-- Persone
CREATE TABLE Persone(
pk_Persona INT PRIMARY KEY,
CodiceFiscale CHAR(16) UNIQUE NOT NULL,
Nome VARCHAR(45) NOT NULL,
Cognome VARCHAR(45) NOT NULL,
Indirizzo VARCHAR(60) NOT NULL,
Citta VARCHAR(45) NOT NULL,
DataNascita DATE NOT NULL,
LuogoNascita VARCHAR(45) NOT NULL,
Sesso CHAR(1) NOT NULL,
Telefono VARCHAR(45) NOT NULL,
Email VARCHAR(70) NOT NULL,
CONSTRAINT CHK_Persone_Email CHECK (Email LIKE '%@%.%'),
CONSTRAINT CHK_Persone_Sesso CHECK (Sesso IN ('M','F','A'))
);


-- Utenti
CREATE TABLE Utenti(
pk_Utente INT PRIMARY KEY,
UserName VARCHAR(45) NOT NULL UNIQUE,
Password VARCHAR(45) NOT NULL,
Ruolo INT NOT NULL,
Stato INT NOT NULL,
fk_Persona INT NOT NULL,
FOREIGN KEY(fk_Persona) REFERENCES Persone (pk_Persona),
CONSTRAINT CHK_Utenti_Ruolo CHECK (Ruolo IN (1,2,3,4,5)),
CONSTRAINT CHK_Utenti_Stato CHECK (Stato IN (0,1))
);

-- Dipendenti
CREATE TABLE Dipendenti(
pk_Dipendente INT PRIMARY KEY,
Assunzione DATE NOT NULL,
Licenziamento DATE,
CodiceIBAN VARCHAR(30) NOT NULL,
FOREIGN KEY(pk_Dipendente) REFERENCES Persone (pk_Persona),
CONSTRAINT CHK_Dipendenti_Licenziamento CHECK (Licenziamento>=Assunzione)
);

-- StipendiErogati
CREATE TABLE StipendiErogati(
pk_StipendioErogato INT PRIMARY KEY,
Data DATE NOT NULL,
Importo FLOAT NOT NULL,
fk_Dipendente INT NOT NULL,
FOREIGN KEY(fk_Dipendente) REFERENCES Dipendenti (pk_Dipendente),
CONSTRAINT CHK_StipendiErogati_Importo CHECK (Importo>0)
);


-- SuperUser
CREATE TABLE SuperUser(
pk_SuperUser INT PRIMARY KEY,
StipendioMensile FLOAT NOT NULL,
FOREIGN KEY(pk_SuperUser) REFERENCES Dipendenti (pk_Dipendente),
CONSTRAINT CHK_SuperUser_StipendioMensile  CHECK (StipendioMensile >0)
);


-- Amministratori
CREATE TABLE Amministratori(
pk_Amministratore INT PRIMARY KEY,
StipendioMensile FLOAT NOT NULL,
FOREIGN KEY(pk_Amministratore) REFERENCES Dipendenti (pk_Dipendente),
CONSTRAINT CHK_Amministratori_StipendioMensile  CHECK (StipendioMensile >0)
);


-- Clienti
CREATE TABLE Clienti(
pk_Cliente INT PRIMARY KEY,
BlackList CHAR(1) DEFAULT 0 NOT NULL,
Stato CHAR(1) DEFAULT 1 NOT NULL,
FOREIGN KEY(pk_Cliente) REFERENCES Persone (pk_Persona),
CONSTRAINT CHK_Clienti_BlackList CHECK(BlackList IN ('0','1')),
CONSTRAINT CHK_Clienti_Stato CHECK(Stato IN ('0','1'))
);


-- Aree
CREATE TABLE Aree(
pk_Area INT PRIMARY KEY,
NomeArea VARCHAR(45) UNIQUE NOT NULL,
PesoSostenibile FLOAT NOT NULL,
TariffaOraria FLOAT NOT NULL,
LarghezzaMax FLOAT NOT NULL,
LunghezzaMax FLOAT NOT NULL,
AltezzaMax FLOAT NOT NULL,
CONSTRAINT CHK_Aree_PesoSostenibile CHECK (PesoSostenibile>0),
CONSTRAINT CHK_Aree_TariffaOraria CHECK (TariffaOraria>0),
CONSTRAINT CHK_Aree_LarghezzaMax CHECK (LarghezzaMax>0),
CONSTRAINT CHK_Aree_LunghezzaMax CHECK (LunghezzaMax>0),
CONSTRAINT CHK_Aree_AltezzaMax CHECK (AltezzaMax>0)
);


-- Veicoli
CREATE TABLE Veicoli(
pk_Veicolo INT PRIMARY KEY,
Targa VARCHAR(10) NOT NULL UNIQUE,
Larghezza FLOAT NOT NULL,
Lunghezza FLOAT NOT NULL,
Altezza FLOAT NOT NULL,
Peso FLOAT NOT NULL,
TipoCarburante VARCHAR(45) NOT NULL,
Modello VARCHAR(45),
Cancellato CHAR(1) DEFAULT 0 NOT NULL,
fk_Proprietario INT NOT NULL,
fk_Area INT NOT NULL,
FOREIGN KEY(fk_Proprietario) REFERENCES Clienti (pk_Cliente),
FOREIGN KEY(fk_Area) REFERENCES Aree (pk_Area),
CONSTRAINT CHK_Veicoli_Larghezza CHECK (Larghezza>0),
CONSTRAINT CHK_Veicoli_Lunghezza CHECK (Lunghezza>0),
CONSTRAINT CHK_Veicoli_Altezza CHECK (Altezza>0),
CONSTRAINT CHK_Veicoli_Peso CHECK (Peso>0),
CONSTRAINT CHK_Veicoli_Cancellato CHECK(Cancellato IN ('0','1'))
);


-- ClientiVeicoli
CREATE TABLE ClientiVeicoli(
fk_Cliente INT,
fk_Veicolo INT,
FOREIGN KEY(fk_Cliente) REFERENCES Clienti (pk_Cliente),
FOREIGN KEY(fk_Veicolo) REFERENCES Veicoli (pk_Veicolo),
PRIMARY KEY(fk_Cliente, fk_Veicolo)
);


-- TipiAssicurazione
CREATE TABLE TipiAssicurazione(
pk_TipoAssicurazione INT PRIMARY KEY,
DanniCoperti VARCHAR(100) NOT NULL,
MassimaleCoperto INT NOT NULL,
Costo FLOAT NOT NULL,
AgenziaAssicurativaErogatrice VARCHAR(45),
Stipulabile CHAR(1) DEFAULT 1 NOT NULL ,
CONSTRAINT CHK_TipiAssicurazione_MassimaleCoperto CHECK (MassimaleCoperto>0),
CONSTRAINT CHK_TipiAssicurazione_Costo CHECK(Costo>0),
CONSTRAINT CHK_TipiAssicurazione_Stipulabile CHECK (Stipulabile IN ('0','1'))
);


--TitoliAbbonamento
CREATE TABLE TitoliAbbonamento(
pk_TitoloAbbonamento INT PRIMARY KEY,
Nome CHAR(1) UNIQUE NOT NULL,
OraInizioValidita TIMESTAMP NOT NULL,
OraFineValidita TIMESTAMP NOT NULL
);

-- TipiAbbonamento
CREATE TABLE TipiAbbonamento(
pk_TipoAbbonamento INT PRIMARY KEY,
DurataValidita INT NOT NULL,
Costo FLOAT NOT NULL,
PosteggioGarantito CHAR(1) DEFAULT 0 NOT NULL,
Sottoscrivibile CHAR(1) DEFAULT 1 NOT NULL,
fk_Area INT NOT NULL,
fk_TitoloAbbonamento INT NOT NULL,
FOREIGN KEY(fk_Area) REFERENCES Aree (pk_Area),
FOREIGN KEY(fk_TitoloAbbonamento) REFERENCES TitoliAbbonamento (pk_TitoloAbbonamento),
CONSTRAINT CHK_TipiAbbonamento_Costo CHECK (Costo>0),
CONSTRAINT CHK_TipiAbbonamento_PosteggioGarantito CHECK (PosteggioGarantito IN ('0','1')),
CONSTRAINT CHK_TipiAbbonamento_Sottoscrivibile CHECK (Sottoscrivibile  IN ('0','1'))
);



-- Sedi
CREATE TABLE Sedi(
pk_Sede INT PRIMARY KEY,
Indirizzo VARCHAR(60) NOT NULL,
Citta VARCHAR(45) NOT NULL,
Telefono VARCHAR(45) NOT NULL,
Stato CHAR(1) DEFAULT 1 NOT NULL,
CONSTRAINT CHK_Sedi_Stato CHECK (Stato IN ('0','1'))
);


-- Responsabili
CREATE TABLE Responsabili(
pk_Responsabile INT PRIMARY KEY,
StipendioMensile FLOAT NOT NULL,
fk_Sede INT NOT NULL,
FOREIGN KEY(pk_Responsabile) REFERENCES Dipendenti (pk_Dipendente),
FOREIGN KEY(fk_Sede) REFERENCES Sedi (pk_Sede),
CONSTRAINT CHK_Responsabili_StipendioMensile  CHECK (StipendioMensile >0)
);


-- ParcheggiAutomatici
CREATE TABLE ParcheggiAutomatici(
pk_ParcheggioAutomatico INT PRIMARY KEY,
Citta VARCHAR(45) NOT NULL,
Indirizzo VARCHAR(60) NOT NULL,
AssicurazioneParcheggio VARCHAR(45),
Telefono VARCHAR(45) NOT NULL,
Zona INT NOT NULL,
MaggiorazioneZona FLOAT NOT NULL,
Stato CHAR(1) DEFAULT 1 NOT NULL,
fk_Sede INT NOT NULL,
FOREIGN KEY(fk_Sede) REFERENCES Sedi (pk_Sede),
UNIQUE(Citta,Indirizzo),
CONSTRAINT CHK_ParcheggiAutomatici_Stato CHECK (Stato IN ('0','1'))
);


-- CodiciSconto
CREATE TABLE CodiciSconto(
pk_CodiceSconto INT PRIMARY KEY,
Codice VARCHAR(15) NOT NULL UNIQUE,
Sconto FLOAT NOT NULL,
DataScadenza DATE NOT NULL,
fk_ParcheggioAutomatico INT NOT NULL,
FOREIGN KEY(fk_ParcheggioAutomatico) REFERENCES ParcheggiAutomatici(pk_ParcheggioAutomatico),
CONSTRAINT CHK_CodiciSconto_Sconto CHECK (Sconto>0)
);


-- Abbonamenti
CREATE TABLE Abbonamenti(
pk_Abbonamento INT PRIMARY KEY,
DataInizioValidita DATE NOT NULL,
DataFineValidita DATE NOT NULL,
PrezzoPagato FLOAT NOT NULL,
TipoPagamento VARCHAR(45) NOT NULL,
fk_Veicolo INT NOT NULL,
fk_TipoAssicurazione INT,
fk_TipoAbbonamento INT NOT NULL,
fk_ParcheggioAutomatico INT NOT NULL,
fk_CodiceSconto INT,
FOREIGN KEY(fk_Veicolo) REFERENCES Veicoli (pk_Veicolo),
FOREIGN KEY(fk_TipoAssicurazione) REFERENCES TipiAssicurazione (pk_TipoAssicurazione) ON DELETE SET NULL,
FOREIGN KEY(fk_TipoAbbonamento) REFERENCES TipiAbbonamento (pk_TipoAbbonamento),
FOREIGN KEY(fk_ParcheggioAutomatico) REFERENCES ParcheggiAutomatici (pk_ParcheggioAutomatico),
FOREIGN KEY(fk_CodiceSconto) REFERENCES CodiciSconto(pk_CodiceSconto),
CONSTRAINT CHK_Abbonamenti_DataFineValidita CHECK (DataFineValidita > DataInizioValidita),
CONSTRAINT CHK_Abbonamenti_PrezzoPagato CHECK (PrezzoPagato>=0)
);


-- Operatori
CREATE TABLE Operatori(
pk_Operatore INT PRIMARY KEY,
fk_ParcheggioAutomatico INT NOT NULL,
FOREIGN KEY(pk_Operatore) REFERENCES Dipendenti (pk_Dipendente),
FOREIGN KEY(fk_ParcheggioAutomatico) REFERENCES ParcheggiAutomatici (pk_ParcheggioAutomatico)
);


-- Sanzioni
CREATE TABLE Sanzioni(
pk_Sanzione INT PRIMARY KEY,
MotivoSanzione VARCHAR(100) NOT NULL,
Rilevamento DATE NOT NULL,
Costo FLOAT NOT NULL,
StatoPagamento CHAR(1) NOT NULL,
DataEmissione DATE,
DataScadenza DATE,
fk_Operatore INT NOT NULL,
fk_Veicolo INT NOT NULL,
FOREIGN KEY(fk_Operatore) REFERENCES Operatori (pk_Operatore),
FOREIGN KEY(fk_Veicolo) REFERENCES Veicoli (pk_Veicolo),
CONSTRAINT CHK_Sanzioni_StatoPagamento CHECK (StatoPagamento IN ('0','1')),
CONSTRAINT CHK_Sanzioni_DataEmissione CHECK (DataEmissione >= Rilevamento),
CONSTRAINT CHK_Sanzioni_DataScadenza CHECK (DataScadenza >= DataEmissione),
CONSTRAINT CHK_Sanzioni_Costo CHECK (Costo>0)
);


-- Colonne
CREATE TABLE Colonne(
pk_Colonna INT PRIMARY KEY,
NumeroPianiSopraelevati INT NOT NULL,
NumeroPianiSottoterra INT NOT NULL,
Stato VARCHAR(45),
fk_ParcheggioAutomatico INT NOT NULL,
FOREIGN KEY(fk_ParcheggioAutomatico) REFERENCES ParcheggiAutomatici (pk_ParcheggioAutomatico),
CONSTRAINT CHK_Colonne_NumeroPianiSopraelevati CHECK (NumeroPianiSopraelevati>=0),
CONSTRAINT CHK_Colonne_NumeroPianiSottoterra CHECK (NumeroPianiSottoterra>=0)
);


-- Box
CREATE TABLE Box(
pk_Box INT PRIMARY KEY,
Piano INT NOT NULL,
Stato CHAR(1) DEFAULT 1 NOT NULL,
fk_Area INT NOT NULL,
fk_Colonna INT NOT NULL,
FOREIGN KEY(fk_Area) REFERENCES Aree (pk_Area),
FOREIGN KEY(fk_Colonna) REFERENCES Colonne (pk_Colonna),
CONSTRAINT CHK_Box_Stato CHECK (Stato IN ('0','1'))
);


--Carburanti
CREATE TABLE Carburanti(
pk_Carburante INT PRIMARY KEY, 
Nome VARCHAR(45) NOT NULL UNIQUE
);


--CarburantiSupportati
CREATE TABLE CarburantiSupportati(
fk_Box INT NOT NULL, 
fk_Carburante INT NOT NULL,
FOREIGN KEY(fk_Box) REFERENCES Box(pk_Box),
FOREIGN KEY(fk_Carburante) REFERENCES Carburanti(pk_Carburante),
PRIMARY KEY(fk_Box, fk_Carburante)
);


-- TipiTurno
CREATE TABLE TipiTurno(
pk_TipoTurno INT PRIMARY KEY,
Nome VARCHAR(45) NOT NULL UNIQUE,
OraInizio TIMESTAMP NOT NULL,
OraFine TIMESTAMP NOT NULL,
RetribuzioneOraria FLOAT NOT NULL,
CONSTRAINT CHK_TipiTurno_RetribuzioneOraria CHECK (RetribuzioneOraria>0)
);


-- Turni
CREATE TABLE Turni(
pk_Turno INT PRIMARY KEY,
Data DATE NOT NULL,
Inizio TIMESTAMP,
Fine TIMESTAMP,
fk_ParcheggioAutomatico INT NOT NULL,
fk_Operatore INT NOT NULL,
fk_TipoTurno INT NOT NULL,
FOREIGN KEY(fk_ParcheggioAutomatico) REFERENCES ParcheggiAutomatici (pk_ParcheggioAutomatico),
FOREIGN KEY(fk_Operatore) REFERENCES Operatori (pk_Operatore),
FOREIGN KEY(fk_TipoTurno) REFERENCES TipiTurno (pk_TipoTurno),
CONSTRAINT CHK_Turni_Fine CHECK (Fine>Inizio)
);


-- Soste
CREATE TABLE Soste(
pk_Sosta INT PRIMARY KEY,
Inizio TIMESTAMP NOT NULL,
Fine TIMESTAMP,
fk_Veicolo INT NOT NULL,
fk_Box INT NOT NULL,
FOREIGN KEY(fk_Veicolo) REFERENCES Veicoli (pk_Veicolo),
FOREIGN KEY(fk_Box) REFERENCES Box (pk_Box),
CONSTRAINT CHK_Soste_Fine CHECK (Fine>Inizio)
);


--SosteOrarie
CREATE TABLE SosteOrarie(
pk_SostaOraria INT PRIMARY KEY,
TipoPagamento VARCHAR(45) NOT NULL,
PrezzoPagato FLOAT NOT NULL,
fk_CodiceSconto INT,
FOREIGN KEY(fk_CodiceSconto) REFERENCES CodiciSconto (pk_CodiceSconto),
FOREIGN KEY(pk_SostaOraria) REFERENCES Soste (pk_Sosta),
CONSTRAINT CHK_SosteOrarie_PrezzoPagato CHECK (PrezzoPagato>=0)
);


--SosteAbbonamenti
CREATE TABLE SosteAbbonamenti(
pk_SostaAbbonamento INT PRIMARY KEY,
fk_Abbonamento INT NOT NULL,
FOREIGN KEY(pk_SostaAbbonamento) REFERENCES Soste (pk_Sosta),
FOREIGN KEY(fk_Abbonamento) REFERENCES Abbonamenti (pk_Abbonamento)
);



-- Giorni
CREATE TABLE Giorni(
pk_Giorno INT PRIMARY KEY,
Giorno VARCHAR(9) NOT NULL UNIQUE,
CONSTRAINT CHK_Giorni_Giorno CHECK (Giorno IN ('Lunedi','Martedi','Mercoledi','Giovedi','Venerdi','Sabato','Domenica', 'Festivo'))
);


-- GiorniValidi
CREATE TABLE GiorniValidi(
fk_Giorno INT,
fk_TitoloAbbonamento INT,
FOREIGN KEY(fk_Giorno) REFERENCES Giorni (pk_Giorno),
FOREIGN KEY(fk_TitoloAbbonamento) REFERENCES TitoliAbbonamento (pk_TitoloAbbonamento),
PRIMARY KEY(fk_Giorno, fk_TitoloAbbonamento)
);



--Notifiche
CREATE TABLE Notifiche(
pk_Notifica INT PRIMARY KEY,
Data DATE NOT NULL,
Descrizione VARCHAR(500) NOT NULL,
Tipo INT NOT NULL,
fk_Mittente INT NOT NULL,
fk_Destinatario INT NOT NULL,
FOREIGN KEY(fk_Mittente) REFERENCES Persone (pk_Persona),
FOREIGN KEY(fk_Destinatario) REFERENCES Persone (pk_Persona)
);



COMMIT;
