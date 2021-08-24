/*
Leonardo Vona
545042
04/12/2019
*/

create or replace package leonardo as

C_URL  constant varchar2(30):= 'VONALEONARDO';
PKGNAME constant VARCHAR(10) := '.leonardo.';
VEICOLOLINK constant VARCHAR(48) := 'http://131.114.73.203:8080/apex/GRUPPO_I_5.NICO.';

FUNCTION checkAutorizzazione(
    p_username IN utenti.username%TYPE,
    p_status IN VARCHAR2,
    p_authorizedStatus IN VARCHAR2) 
    RETURN persone.pk_persona%TYPE;

procedure messaggio(
	v_text varchar2 default '');
	
procedure visualizzaCliente(
    username IN utenti.username%TYPE DEFAULT NULL,
    status varchar2 default '',
    p_cliente persone.pk_persona%TYPE default null);

PROCEDURE modificaCliente(
    username IN utenti.username%TYPE DEFAULT NULL, 
    status varchar2 default '');
    
procedure modificaDati(
	username IN utenti.username%TYPE DEFAULT NULL, 
	status varchar2 default '',
	p_indirizzo IN persone.indirizzo%TYPE default '',
	p_citta IN persone.citta%TYPE default '',
	p_telefono IN persone.telefono%TYPE default '',
	p_email IN persone.email%TYPE default '',
	p_password IN utenti.password%TYPE default '');

procedure disattivaAccount(
	username IN utenti.username%TYPE DEFAULT NULL,
	status varchar2 default '');

procedure disattiva(
    username IN utenti.username%TYPE DEFAULT NULL,
	status varchar2 default '');

procedure richiestaSostaSenzaAbbonamento(
	username IN utenti.username%TYPE DEFAULT NULL, 
	status varchar2 default '');

procedure assegnaPosto(
    username IN utenti.username%TYPE DEFAULT NULL,
    status varchar2 default '',
    p_veicolo IN veicoli.pk_veicolo%TYPE default -1,
    p_parcheggio IN parcheggiautomatici.pk_parcheggioautomatico%TYPE default -1);
    
procedure reportMulte(
	username IN utenti.username%TYPE DEFAULT NULL,
	status varchar2 default '',
    p_dataInizio varchar2 default null,
    p_dataFine varchar2 default null,
    p_parcheggio IN parcheggiautomatici.pk_parcheggioautomatico%TYPE default -1);

procedure reportPeso(
	username IN utenti.username%TYPE DEFAULT NULL,
	status varchar2 default '');

procedure peso(
    username IN utenti.username%TYPE DEFAULT NULL,
    status varchar2 default '',
    p_Auto number DEFAULT -1,
    p_Moto number DEFAULT -1,
    p_Furgone number DEFAULT -1,
    p_Camion number DEFAULT -1,
    p_Camper number DEFAULT -1);

procedure reportAbbonamentiCarburante(
	username IN utenti.username%TYPE DEFAULT NULL,
	status varchar2 default '',
    p_carburante1 IN Carburanti.pk_Carburante%TYPE default null,
    p_carburante2 IN Carburanti.pk_Carburante%TYPE default null,
    p_dataInizio varchar2 default null,
    p_dataFine varchar2 default null,
    p_parcheggio IN parcheggiautomatici.pk_parcheggioautomatico%TYPE default -1);

procedure reportVeicoli(
	username IN utenti.username%TYPE DEFAULT NULL,
	status varchar2 default '',
    p_cliente IN clienti.pk_Cliente%TYPE DEFAULT -1,
    p_dataInizio varchar2 DEFAULT NULL,
    p_dataFine varchar2 DEFAULT NULL,
    p_parcheggio IN parcheggiautomatici.pk_parcheggioautomatico%TYPE DEFAULT -1);

end leonardo;
