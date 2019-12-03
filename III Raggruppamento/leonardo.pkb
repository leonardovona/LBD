/*
Leonardo Vona
545042
04/12/2019
*/

create or replace PACKAGE BODY leonardo AS
/*
Nota bene: 
    le variabili che iniziano con p_ sono parametri della procedura
    le variabili che iniziano con v_ sono variabili locali della procedura
    le variabili che iniziano con c_ sono cursori
*/

FUNCTION checkAutorizzazione(
    p_username IN utenti.username%TYPE,
    p_status IN VARCHAR2,
    p_authorizedStatus IN VARCHAR2) 
    RETURN persone.pk_persona%TYPE IS
/*
Funzione utilizzata dalle procedure per verificare che p_username esista effettivamente nel sistema e che p_status sia autorizzato
ad eseguire la procedura. Ritorna -2 se l'utente non è stato trovato, -1 se l'utente non è autorizzato.
Se i controlli vanno a buon fine restituisce la chiave primaria della persona associata all'username
*/
v_pkPersona Persone.pk_Persona%TYPE;

CURSOR c_persona IS 
        SELECT fk_persona 
        FROM utenti 
        WHERE username = p_username;
        
BEGIN
    IF(p_authorizedStatus = 'dipendente') THEN
        IF NOT (p_status = 'responsabile' OR p_status = 'superuser' OR p_status = 'operatore' OR p_status = 'amministratore') THEN
            return -1;
        END IF;
    ELSE
        IF p_status <> 'cliente' THEN
            return -1;
        END IF;
    END IF;
    
    OPEN c_persona;
    FETCH c_persona into v_pkPersona;
    IF c_persona%NOTFOUND THEN
        return -2;
    END IF;
    CLOSE c_persona;
    
    RETURN v_pkPersona;

END checkAutorizzazione;

PROCEDURE messaggio(
	v_text varchar2 default '') IS
/*
    Procedura che implementa una pagina di conferma / errore al termine dell'esecuzione di un altra procedura
*/
BEGIN
    ui.htmlOpen;
    ui.inizioPagina(titolo => 'Messaggio');
    ui.openBodyStyle;
    ui.openBarraMenu;
    ui.creaForm(v_text);    --la form viene aperta per questioni "estetiche"
    ui.creabottoneback('Indietro');
    ui.chiudiForm;
    ui.closeBody;
    ui.htmlClose;    
END messaggio;

PROCEDURE visualizzaCliente(
    username IN utenti.username%TYPE DEFAULT NULL,
    status varchar2 default '',
    p_cliente persone.pk_persona%TYPE default null) IS
/*
    Visualizza codice fiscale, nome, cognome, indirizzo, città, data di nascita, luogo di nascita, telefono ed email di un certo
    utente. Se l'utente loggato è un cliente verranno mostrati i propri dati e due pulsanti che portano rispettivamente alla
    pagina di modifica dei propri dati e alla pagina di disattivazione del proprio account.
    Se l'utente loggato è un dipentente allora il parametro v_cliente indica la chiave primaria associata al cliente di cui si
    vogliono visualizzare i dati.
*/
	--variabili
	v_pkPersona utenti.fk_Persona%TYPE; --utilizzato per verificare che l'username sia effettivamente presente nel sistema
	--dati associati al cliente in interesse
    v_codicefiscale persone.codicefiscale%TYPE;
	v_nome persone.nome%TYPE;
	v_cognome persone.cognome%TYPE;
	v_indirizzo persone.indirizzo%TYPE;
	v_citta persone.citta%TYPE;
	v_datanascita persone.datanascita%TYPE;
	v_luogonascita persone.luogonascita%TYPE;
	v_sesso persone.sesso%TYPE;
	v_telefono persone.telefono%TYPE;
	v_email persone.email%TYPE;
	
	--eccezioni
	noResultException EXCEPTION; --lanciata se non vengono trovati i dati associati al cliente
	usernameException EXCEPTION; --lanciata se l'username non è presente nel sistema
    unauthorizedException EXCEPTION; --lanciata se lo status non corrisponde a uno di quelli presenti nel sistema
    
    --recupero dei dati associati al cliente
    CURSOR c_datiPersona IS 
        SELECT P.codicefiscale, P.nome, P.cognome, P.indirizzo, P.citta, P.datanascita, P.luogonascita, P.sesso, P.telefono, P.email
        FROM persone P 
        WHERE P.pk_persona = v_pkPersona;
        
BEGIN
    IF p_cliente IS NOT NULL THEN   --visualizzazione cliente lato dipendente
        IF NOT (status = 'responsabile' OR status = 'superuser' OR status = 'operatore' OR status = 'amministratore') THEN
            raise unauthorizedException;
        ELSE
            v_pkPersona := p_cliente;
        END IF;
    ELSE --visualizzazione lato cliente
        v_pkPersona := checkAutorizzazione(username, status, 'cliente'); --recupera dati cliente
        IF v_pkPersona = -1 THEN
            raise unauthorizedException; 
        ELSIF v_pkPersona = -2 THEN
            raise usernameException;
        END IF;
    END IF;
        
    OPEN c_datiPersona;
    FETCH c_datiPersona INTO v_codicefiscale, v_nome, v_cognome, v_indirizzo, v_citta, v_datanascita, v_luogonascita, v_sesso, v_telefono, v_email;
    IF c_datiPersona%NOTFOUND THEN
        RAISE noResultException;
    END IF;
    CLOSE c_datiPersona;

    ui.htmlOpen;
    ui.inizioPagina(titolo => 'Dettagli cliente');
    ui.openBodyStyle;
    ui.openBarraMenu(username,status);
       
    ui.creaForm;
    ui.openDiv(idDiv => 'header');
    ui.apriTabella;
    ui.apriRigaTabella;
    ui.intestazioneTabella(testo => 'Campo');
    ui.intestazioneTabella(testo => 'Valore');
    ui.chiudiRigaTabella;
    ui.chiudiTabella;
    ui.closeDiv;
    
    ui.openDiv(idDiv => 'tabella');
    
    ui.apriTabella;
       
    ui.apriRigaTabella;
    ui.elementoTabella(testo => 'Codice Fiscale');
    ui.elementoTabella(testo => v_codicefiscale);
    ui.chiudiRigaTabella;
    
    ui.apriRigaTabella;
    ui.elementoTabella(testo => 'Nome');
    ui.elementoTabella(testo => v_nome);
    ui.chiudiRigaTabella;
    
    ui.apriRigaTabella;
    ui.elementoTabella(testo => 'Cognome');
    ui.elementoTabella(testo => v_cognome);
    ui.chiudiRigaTabella;
    
    ui.apriRigaTabella;
    ui.elementoTabella(testo => 'Indirizzo');
    ui.elementoTabella(testo => v_indirizzo);
    ui.chiudiRigaTabella;
    
    ui.apriRigaTabella;
    ui.elementoTabella(testo => 'Città');
    ui.elementoTabella(testo => v_citta);
    ui.chiudiRigaTabella;
    
    ui.apriRigaTabella;
    ui.elementoTabella(testo => 'Data di Nascita');
    ui.elementoTabella(testo => v_datanascita);
    ui.chiudiRigaTabella;
    
    ui.apriRigaTabella;
    ui.elementoTabella(testo => 'Luogo di Nascita');
    ui.elementoTabella(testo => v_luogonascita);
    ui.chiudiRigaTabella;
    
    ui.apriRigaTabella;
    ui.elementoTabella(testo => 'Sesso');
    ui.elementoTabella(testo => v_sesso);
    ui.chiudiRigaTabella;
    
    ui.apriRigaTabella;
    ui.elementoTabella(testo => 'Telefono');
    ui.elementoTabella(testo => v_telefono);
    ui.chiudiRigaTabella;
    
    ui.apriRigaTabella;
    ui.elementoTabella(testo => 'E-mail');
    ui.elementoTabella(testo => v_email);
    ui.chiudiRigaTabella;
    
    ui.chiudiTabella;
    
    ui.closeDiv;
    
    IF(status = 'cliente') THEN
        --crea bottoni per modifica dati e disattivazione account
        ui.creaBottoneLink(PKGNAME || 'modificacliente?username=' || username ||
        	'&status=' || status, 'Modifica Dati');
        
        ui.creaBottoneLink(PKGNAME || 'disattivaaccount?username=' || username ||
            '&status=' || status, 'Disattiva Account');
    END IF;
    
    ui.creabottoneback('Indietro');
    
    ui.chiudiForm;
    ui.closeBody;
    ui.htmlClose;
    
EXCEPTION
    WHEN unauthorizedException THEN messaggio('Non hai i diritti per accedere a questa funzionalità');
    WHEN noResultException THEN messaggio('Errore durante il recupero dei dati');
    WHEN usernameException THEN messaggio('Utente non trovato');
END visualizzaCliente;


PROCEDURE modificaCliente(
    username IN utenti.username%TYPE DEFAULT NULL, 
    status varchar2 default '') IS
/*
Procedura per la modifica dei dati del cliente loggato. Permette di modificare indirizzo, città, telefono, email e password
*/
v_pkPersona utenti.fk_Persona%TYPE;
v_indirizzo persone.indirizzo%TYPE;
v_citta persone.citta%TYPE;
v_telefono persone.telefono%TYPE;
v_email persone.email%TYPE;
v_password utenti.password%TYPE;

unauthorizedException exception;
noResultException exception;
usernameException exception;

CURSOR c_datiPersona IS 
    SELECT indirizzo, citta, telefono, email
    FROM persone 
    WHERE pk_persona = v_pkPersona;

BEGIN
    v_pkPersona := checkAutorizzazione(username, status, 'cliente'); --recupera dati cliente
        IF v_pkPersona = -1 THEN
            raise unauthorizedException; 
        ELSIF v_pkPersona = -2 THEN
            raise usernameException;
        END IF;   
    
    SELECT password INTO v_password FROM Utenti WHERE fk_Persona = v_pkPersona;
    
    OPEN c_datiPersona;
    FETCH c_datiPersona INTO v_indirizzo, v_citta, v_telefono, v_email;
    IF c_datiPersona%NOTFOUND THEN
        RAISE noResultException;
    END IF;
    CLOSE c_datiPersona;
        
    ui.htmlOpen;
    ui.inizioPagina(titolo => 'Modifica dati');
    ui.openBodyStyle;
    ui.openBarraMenu(username,status);
        
    ui.openDiv;
    
    ui.creaForm('Modifica Dati', PKGNAME || 'modificadati');
    
    ui.creaTextField(nomeParametroGet => 'username', inputType => 'hidden', defaultText => username);
    ui.creaTextField(nomeParametroGet => 'status', inputType => 'hidden', defaultText => status);
    
    ui.creaTextField(nomeRif => 'Indirizzo', nomeParametroGet => 'p_indirizzo',
        placeHolder => 'Indirizzo', defaultText => v_indirizzo, flag => 'required');
    ui.vaiACapo;
    
    ui.creaTextField(nomeRif => 'Città', nomeParametroGet => 'p_citta',
        placeHolder => 'Città', defaultText => v_citta, flag => 'required');
    ui.vaiACapo;
    
    ui.creaTextField(nomeRif => 'Telefono', nomeParametroGet => 'p_telefono', inputType => 'number',
        placeHolder => 'Telefono', defaultText => v_telefono, flag => 'required');
    ui.vaiACapo;
    
    ui.creaTextField(nomeRif => 'E-mail', nomeParametroGet => 'p_email', inputType => 'email',
        placeHolder => 'E-mail', defaultText => v_email, flag => 'required');
    ui.vaiACapo;
    
    ui.creaTextField(nomeRif => 'Password', nomeParametroGet => 'p_password',
        placeHolder => 'Password', defaultText => v_password, flag => 'required');
    ui.vaiACapo;
    
    ui.creaBottone('Modifica dati');
    
    ui.creabottoneback('Indietro');
    
    ui.chiudiForm;
    ui.closeDiv;
    
    ui.closeBody;
    
    ui.htmlClose;
    
EXCEPTION
    WHEN unauthorizedException THEN messaggio('Non hai i diritti per accedere a questa funzionalità');
    WHEN noResultException THEN messaggio('Errore durante il recupero dei dati');
    WHEN usernameException THEN messaggio('Utente non trovato');
END modificaCliente;

PROCEDURE modificaDati(
    username IN utenti.username%TYPE DEFAULT NULL, 
    status varchar2 default '', 
    p_indirizzo IN persone.indirizzo%TYPE default '',
    p_citta IN persone.citta%TYPE default '',
    p_telefono IN persone.telefono%TYPE default '',
    p_email IN persone.email%TYPE default '',
    p_password IN utenti.password%TYPE default '') IS
/*
Procedura di appoggio per la modifica dei dati di un cliente.
Prende in input indirizzo, città, telefono, email e password del cliente a cui corrisponde il parametro username e aggiorna i
valori nel database.
*/
v_pkPersona utenti.fk_Persona%TYPE;

unauthorizedException exception;
unvalidDataException exception;
updateException exception;
usernameException exception;

BEGIN
    v_pkPersona := checkAutorizzazione(username, status, 'cliente');
    
    IF v_pkPersona = -1 THEN
        raise unauthorizedException; 
    ELSIF v_pkPersona = -2 THEN
        raise usernameException;
    END IF;
    
    --controllo sui valori passati in input alla procedura
    IF p_indirizzo IS NULL OR p_citta IS NULL OR p_telefono IS NULL OR p_email IS NULL OR p_password IS NULL THEN
        raise unvalidDataException;
    END IF;
    
    --Aggiorna i valori nella tabella Persone           
    UPDATE Persone P
       SET 
       P.indirizzo = p_indirizzo,
       P.citta = p_citta,
       P.telefono = p_telefono,
       P.email = p_email
    WHERE P.pk_persona = v_pkPersona;
        
    IF SQL%ROWCOUNT = 0 THEN --errore durante l'update dei dati in Persone
        raise updateException;
    END IF;
        
    --Aggiorna la password nella tabella Utenti
    UPDATE Utenti U
        SET
        U.password = p_password
        WHERE U.fk_persona = v_pkPersona AND U.ruolo = 5;
    --ruolo = 5 (Cliente) perchè se una persona è sia cliente che dipendente allora ha la stessa chiave primaria in Persone
        
    IF SQL%ROWCOUNT = 0 THEN --errore durante l'update della password in Utenti
        raise updateException;
    END IF;
    
    COMMIT;
    
    ui.htmlOpen;
    ui.inizioPagina(titolo => 'Modifica dati');
    ui.openBodyStyle;
    ui.openBarraMenu(username,status);
    
    ui.creaForm('Complimenti, la procedura è andata a buon fine!');
    
    ui.creaBottoneLink(PKGNAME || 'visualizzacliente?username=' || username || '&status=' || status, 'Torna ai tuoi dati');
    ui.creabottoneback('Indietro');
        
    ui.chiudiform;
    ui.closeBody;
    ui.htmlClose;   
    
EXCEPTION
    WHEN unauthorizedException THEN messaggio('Non hai i diritti per accedere a questa funzionalità');
    WHEN usernameException THEN messaggio('Utente non trovato');
    WHEN updateException THEN messaggio('Errore durante la modifica dei dati');
    WHEN unvalidDataException THEN messaggio('I dati che hai inserito non sono validi');
END modificadati;

PROCEDURE disattivaAccount(
    username IN utenti.username%TYPE DEFAULT NULL,
    status varchar2 default '') is
/*
Procedura per la disattivazione dell'account da parte di un cliente
*/
v_pkPersona persone.pk_Persona%TYPE;

unauthorizedException exception;
usernameException exception;

BEGIN
    v_pkPersona := checkAutorizzazione(username, status, 'cliente');
    
    IF v_pkPersona = -1 THEN
        raise unauthorizedException; 
    ELSIF v_pkPersona = -2 THEN
        raise usernameException;
    END IF;
    
    ui.htmlOpen;
    ui.inizioPagina(titolo => 'Disattiva Account');
    ui.openBodyStyle;
    ui.openBarraMenu(username,status);
    
    ui.creaForm('Sei sicuro di voler disattivare il tuo account?');
    
    ui.creaBottoneLink(PKGNAME || 'disattiva?username=' || username || '&status=' || status, 'Si');
    ui.creaBottoneLink(PKGNAME || 'visualizzaCliente?username=' || username || '&status=' || status, 'No');
    
    ui.chiudiForm;
    ui.closeBody;
    ui.htmlClose;
    
EXCEPTION
    WHEN unauthorizedException THEN messaggio('Non hai i diritti per accedere a questa funzionalità');
    WHEN usernameException THEN	messaggio('Utente non trovato');
END disattivaAccount;

PROCEDURE disattiva(
    username IN utenti.username%TYPE DEFAULT NULL, 
    status varchar2 default '') is
/*
Procedura di supporto per la disattivazione di un account. Attivata quando un cliente conferma di voler eliminare il proprio
account.
La disattivazione dei veicoli associati al cliente viene effettuata in automatico da un trigger.
*/
v_pkPersona persone.pk_Persona%TYPE;

unauthorizedException exception;
usernameException exception;
updateException exception;

BEGIN
    v_pkPersona := checkAutorizzazione(username, status, 'cliente');
    
    IF v_pkPersona = -1 THEN
        raise unauthorizedException; 
    ELSIF v_pkPersona = -2 THEN
        raise usernameException;
    END IF;
    
    UPDATE Clienti C    --disattiva in tabella clienti
		SET 
		C.Stato = 0
		WHERE C.pk_Cliente = v_pkPersona;
        
    IF SQL%ROWCOUNT = 0 THEN
        raise updateException;
    END IF;
    
    UPDATE Utenti U     --disattiva in tabella utenti
		SET 
		U.Stato = 0
		WHERE U.fk_Persona = v_pkPersona AND ruolo = 5;
        
    IF(SQL%ROWCOUNT = 0) THEN
        raise updateException;
    END IF;

    COMMIT;
    
    ui.htmlOpen;
    ui.inizioPagina(titolo => 'Account disattivato');
    ui.openBodyStyle;
    ui.openBarraMenu(username,status);
    ui.creaForm('Il tuo account è stato disattivato');
    ui.creaBottoneLink('.ui.openpage?username=' || username || '&status=' || status || '&title=Homepage', 'Indietro');
    ui.chiudiForm;
    ui.closeBody;
    ui.htmlClose;   
    
EXCEPTION
    WHEN updateException THEN messaggio('Errore durante la disattivazione dell''account');
    WHEN unauthorizedException THEN messaggio('Non hai i diritti per accedere a questa funzionalità');
    WHEN usernameException THEN	messaggio('Utente non trovato');
END disattiva;

PROCEDURE richiestaSostaSenzaAbbonamento(
    username IN utenti.username%TYPE DEFAULT NULL,
    status varchar2 default '') IS
/*
Procedura che implementa la richiesta di una sosta senza abbonamento.
Dall'usernamen in input recupera automaticamente tutti i veicoli di cui è proprietario o può guidare il cliente,
che attualmente non sono in sosta o che non hanno sottoscritto un abbonamento.
Vengono mostrati quindi tutti i parcheggi dove è possibile sostare.
Dopo aver inserito i dati viene attivata una procedura per la ricerca di un box libero.
*/
v_pkPersona persone.pk_persona%TYPE;
v_targa veicoli.targa%TYPE;
v_pkVeicolo veicoli.pk_Veicolo%TYPE;
v_citta parcheggiAutomatici.citta%TYPE;
v_indirizzo parcheggiAutomatici.indirizzo%TYPE;
v_pkParcheggioAutomatico parcheggiAutomatici.pk_ParcheggioAutomatico%TYPE;

unauthorizedException exception;
usernameException exception;
veicoliException exception; --non ci sono veicoli associati attualmente disponibili
parcheggiException exception;   --non ci sono parcheggi attualmente disponibili

CURSOR c_veicolo IS
        SELECT targa, pk_veicolo 
        FROM Veicoli 
        WHERE Cancellato = 0 --veicolo attivo
        AND pk_Veicolo IN
            (   SELECT fk_veicolo --tutti i veicoli che può guidare un cliente ma di cui non è proprietario
                FROM ClientiVeicoli 
                WHERE fk_Cliente = v_pkPersona 
             UNION 
                SELECT pk_veicolo --tutti i veicoli di cui è proprietario un cliente
                FROM Veicoli 
                WHERE fk_proprietario = v_pkPersona 
            MINUS
                SELECT fk_veicolo  --tutti i veicoli che hanno un abbonamento
                FROM Abbonamenti 
            MINUS
                SELECT fk_veicolo --tutti i veicoli che sono in sosta
                FROM Soste 
                WHERE Fine IS NULL);
                
CURSOR c_parcheggio IS 
    SELECT citta, indirizzo, pk_parcheggioautomatico 
    FROM ParcheggiAutomatici 
    WHERE stato = 1;

BEGIN
    v_pkPersona := checkAutorizzazione(username, status, 'cliente');
    
    IF v_pkPersona = -1 THEN
        raise unauthorizedException; 
    ELSIF v_pkPersona = -2 THEN
        raise usernameException;
    END IF;
    
    OPEN c_veicolo;
    FETCH c_veicolo into v_targa, v_pkVeicolo;
    IF c_veicolo%NOTFOUND THEN
        RAISE veicoliException;
    END IF;
    
    OPEN c_parcheggio;
    FETCH c_parcheggio into v_citta, v_indirizzo, v_pkParcheggioAutomatico;
    IF c_parcheggio%NOTFOUND THEN
        RAISE parcheggiException;
    END IF;
    
    ui.htmlOpen;
    ui.inizioPagina(titolo => 'Richiesta sosta senza abbonamento');
    ui.openBodyStyle;
    ui.openBarraMenu(username,status);
    
    ui.creaForm('Seleziona veicolo e parcheggio', PKGNAME || 'assegnaposto');
    
    --i seguenti due valori sono necessari per passare username e status alla procedura successiva
    ui.creaTextField(nomeParametroGet => 'username', inputType => 'hidden', defaultText => username);
    ui.creaTextField(nomeParametroGet => 'status', inputType => 'hidden', defaultText => status);
    
    ui.creaComboBox(nomeLab => 'Veicolo', nomeGet => 'p_Veicolo');
    LOOP    --inserisce i veicoli disponibili in una ComboBox
        ui.aggOpzioneAComboBox(v_targa, v_pkVeicolo);
        FETCH c_veicolo into v_targa, v_pkVeicolo;
        EXIT WHEN c_veicolo%NOTFOUND;
    END LOOP;
    CLOSE c_veicolo;
    ui.chiudiSelectComboBox;
    
    ui.creaComboBox(nomeLab => 'Parcheggio ', nomeGet => 'p_Parcheggio');
    LOOP    --inserisce i parcheggi disponibili in una ComboBox
        ui.aggOpzioneAComboBox(v_citta || ', ' || v_indirizzo, v_pkParcheggioautomatico);
        FETCH c_parcheggio into v_citta, v_indirizzo, v_pkParcheggioAutomatico;
        EXIT WHEN c_parcheggio%NOTFOUND;
    END LOOP;
    CLOSE c_parcheggio;
    ui.chiudiSelectComboBox;
    
   	ui.creaBottone('Cerca un posto');
   	
   	ui.creabottoneback('Indietro');
    
    ui.chiudiForm;
    ui.closeBody;   
    ui.htmlClose;
    
EXCEPTION
    WHEN unauthorizedException THEN messaggio('Non hai i diritti per accedere a questa funzionalità');
    WHEN veicoliException THEN messaggio('Al momento non hai alcun veicolo a disposizione per entrare');
    WHEN parcheggiException THEN messaggio('Al momento non ci sono parcheggi disponibili');
    WHEN usernameException THEN messaggio('Utente non trovato');
END richiestaSostaSenzaAbbonamento;

PROCEDURE assegnaPosto(
    username IN utenti.username%TYPE DEFAULT NULL,
    status varchar2 default '',
    p_veicolo IN veicoli.pk_veicolo%TYPE default -1,
    p_parcheggio IN parcheggiautomatici.pk_parcheggioautomatico%TYPE default -1) IS
/*
Procedura di appoggio a RichiestaSostaSenzaAbbonamento per la ricerca ed assegnazione di un box in uno specifico parcheggio ad
un dato veicolo.
Se nel parcheggio selezionato non ci sono box che possono far sostare il veicolo dato, viene mostrato un messaggio di errore.
*/
v_pkPersona persone.pk_persona%TYPE;
v_pkBox box.pk_Box%TYPE;
v_tipoCarburante veicoli.tipoCarburante%TYPE;
v_area Veicoli.fk_Area%TYPE;

unauthorizedException exception;
usernameException exception;
veicoliException exception; --errore durante il recupero dei dati del veicolo
insertException exception;  --errore durante l'assegnazione del box
noavailableboxException exception;  --non ci sono box disponibili nel parcheggio selezionato

CURSOR c_box IS 
    SELECT B.pk_box 
    FROM Box B
    INNER JOIN Colonne C ON C.pk_Colonna = B.fk_Colonna
    WHERE C.fk_ParcheggioAutomatico = p_parcheggio
    AND B.fk_Area = v_area  --il box deve appartenere ad un area compatibile con il veicolo
    AND B.stato = 1 --il box non deve essere disattivato
    AND B.pk_box NOT IN --il box non deve essere già occupato
        (select S.fk_box 
         from soste S 
         where S.fine IS NULL)
    AND v_tipoCarburante IN --il tipo di alimentazione del veicolo è supportato dal box
        (SELECT nome 
        from Carburanti
        INNER JOIN CarburantiSupportati ON pk_Carburante = fk_Carburante
        INNER JOIN Box ON pk_Box = fk_Box 
        WHERE pk_Box = pk_Box)
    AND ROWNUM = 1; --recupera solo il primo risultato

CURSOR c_veicolo IS --recupera tipo di alimentazione e area del veicolo passato
    SELECT tipoCarburante, fk_Area 
    FROM Veicoli 
    WHERE pk_veicolo = p_veicolo;

BEGIN
    IF(p_veicolo = -1 OR p_parcheggio = -1) THEN
        raise veicoliException;
    END IF;
    
    v_pkPersona := checkAutorizzazione(username, status, 'cliente');
    
    IF v_pkPersona = -1 THEN
        raise unauthorizedException; 
    ELSIF v_pkPersona = -2 THEN
        raise usernameException;
    END IF;
    
    OPEN c_veicolo;
    FETCH c_veicolo INTO v_tipoCarburante, v_Area;
    IF c_veicolo%NOTFOUND THEN
        RAISE veicoliException;
    END IF;
    CLOSE c_veicolo;
    
    OPEN c_box;
    FETCH c_box INTO v_pkBox;
    IF c_box%NOTFOUND THEN
        raise noavailableboxException;
    END IF;
    CLOSE c_box;

    INSERT INTO Soste 
            (pk_Sosta, Inizio, fk_veicolo, fk_box) 
        VALUES
            (Seq_pk_Sosta.NEXTVAL, SYSDATE, p_veicolo, v_pkBox);
    
    IF SQL%NOTFOUND THEN
        raise insertException;
    END IF;
    
    COMMIT;
    
    ui.htmlOpen;
    ui.inizioPagina(titolo => 'Sosta avviata');
    ui.openBodyStyle;
    ui.openBarraMenu(username,status);
    ui.creaForm('La sosta è stata avviata con successo');
    ui.creaBottoneLink('.ui.openpage?username=' || username || '&status=' || status || '&title=Homepage', 'Indietro');
    ui.chiudiForm;
    ui.closeBody;
    ui.htmlClose;  

EXCEPTION
    WHEN unauthorizedException THEN messaggio('Non hai i diritti per accedere a questa funzionalità');
    WHEN veicoliException THEN messaggio('Errore durante il recupero dei dati del veicolo');
    WHEN noAvailableBoxException THEN messaggio('Al momento nel parcheggio selezionato non ci sono box disponibili');
    WHEN usernameException THEN messaggio('Utente non trovato');
    WHEN insertException THEN messaggio('Errore durante l''avvio della sosta');
END assegnaPosto;


PROCEDURE reportMulte(
    username IN utenti.username%TYPE DEFAULT NULL,
    status varchar2 default '',
    p_dataInizio varchar2 default null,
    p_dataFine varchar2 default null,
    p_parcheggio IN parcheggiautomatici.pk_parcheggioautomatico%TYPE default -1) IS
/*
Report che riporta il nome del cliente che ha ricevuto più multe.
Permette di selezionare l'intervallo di tempo e il parcheggio in cui effettuare il report.
Si assume che il report possa essere effettuato da un qualsiasi dipendente.
*/
v_pkPersona persone.pk_persona%TYPE;
v_cittaParcheggio parcheggiautomatici.citta%TYPE;
v_indirizzoParcheggio parcheggiautomatici.indirizzo%TYPE;
v_multe number;
v_nome Persone.nome%TYPE;
v_cognome Persone.cognome%TYPE;
v_cliente Persone.pk_Persona%TYPE;
v_fkVeicolo Veicoli.pk_Veicolo%TYPE;

unauthorizedException exception;
usernameException exception;
personeException exception;
unvalidDataException exception;

CURSOR c_veicoloAll IS --recupera i veicoli che hanno preso più multe nel periodo indicato in tutti i parcheggi
    SELECT fk_veicolo, count(fk_veicolo) multe
        FROM Sanzioni
        WHERE Sanzioni.rilevamento >= TO_DATE(p_dataInizio,'YYYY-MM-DD')
        AND Sanzioni.rilevamento <= TO_DATE(p_dataFine,'YYYY-MM-DD')
        GROUP BY fk_veicolo
        HAVING COUNT(fk_veicolo) =
            (SELECT MAX(m) --recupera il numero massimo di multe nel periodo indicato
             FROM 
                (SELECT count(fk_veicolo) m 
                 FROM Sanzioni
                 WHERE Sanzioni.rilevamento >= TO_DATE(p_dataInizio,'YYYY-MM-DD')
                 AND Sanzioni.rilevamento <= TO_DATE(p_dataFine,'YYYY-MM-DD')
                 GROUP BY fk_veicolo));

CURSOR c_veicolo IS   --recupera i veicoli che hanno preso più multe nel periodo indicato nello specifico parcheggio
    SELECT fk_veicolo, count(fk_veicolo)
        FROM Sanzioni S
        INNER JOIN Operatori O ON S.fk_Operatore = O.pk_Operatore
        WHERE S.rilevamento >= TO_DATE(p_dataInizio,'YYYY-MM-DD')
        AND S.rilevamento <= TO_DATE(p_dataFine,'YYYY-MM-DD')
        AND O.fk_ParcheggioAutomatico = p_parcheggio
        GROUP BY fk_veicolo
        HAVING COUNT(S.fk_veicolo) =
            (SELECT MAX(m) --recupera il numero massimo di multe nel periodo e parcheggio indicati
             FROM 
                (SELECT count(S1.fk_veicolo) m 
                 FROM Sanzioni S1
                 INNER JOIN Operatori O1 ON S1.fk_Operatore = O1.pk_Operatore
                 WHERE S1.rilevamento >= TO_DATE(p_dataInizio,'YYYY-MM-DD')
                 AND S1.rilevamento <= TO_DATE(p_dataFine,'YYYY-MM-DD')
                 AND O1.fk_ParcheggioAutomatico = p_parcheggio
                 GROUP BY S1.fk_veicolo));

BEGIN
    v_pkPersona := checkAutorizzazione(username, status, 'dipendente');
    
    IF v_pkPersona = -1 THEN
        raise unauthorizedException; 
    ELSIF v_pkPersona = -2 THEN
        raise usernameException;
    END IF;
    
    ui.htmlOpen;
    ui.inizioPagina(titolo => 'Report multe');
    ui.openBodyStyle;
    ui.openBarraMenu(username,status);
    
    ui.creaForm('Seleziona il parcheggio e l''intervallo temporale', PKGNAME || 'reportmulte');

    ui.creaTextField(nomeParametroGet => 'username', inputType => 'hidden',defaultText => username);
    ui.creaTextField(nomeParametroGet => 'status', inputType => 'hidden', defaultText => status);
    
    IF p_dataInizio IS NULL THEN
        ui.creaTextField(nomeParametroGet => 'p_dataInizio', inputType => 'date',
            defaultText => TO_CHAR(SYSDATE - 365, 'YYYY-MM-DD'));
    ELSE --deve effettuare il report e imposta il valore selezionato
        ui.creaTextField(nomeParametroGet => 'p_dataInizio', inputType => 'date', defaultText => p_dataInizio);
    END IF;
    
    IF p_dataFine IS NULL THEN
        ui.creaTextField(nomeParametroGet => 'p_dataFine', inputType => 'date',
            defaultText => TO_CHAR(SYSDATE, 'YYYY-MM-DD'));
    ELSE --deve effettuare il report e imposta il valore selezionato
        ui.creaTextField(nomeParametroGet => 'p_dataFine', inputType => 'date', defaultText =>  p_dataFine);
    END IF;
    
    --inserisce i parcheggi all'interno di una ComboBox
    ui.creaComboBox(nomeLab => 'Parcheggio ', nomeGet => 'p_Parcheggio');
    IF p_parcheggio = -1 THEN
        ui.aggOpzioneAComboBox('Tutti', -1); --opzione per effettuare il report su tutti i parcheggi
        FOR c_parcheggio IN (SELECT citta, indirizzo, pk_parcheggioautomatico FROM ParcheggiAutomatici)
        LOOP
            ui.aggOpzioneAComboBox(c_parcheggio.citta || ', ' || c_parcheggio.indirizzo, c_parcheggio.pk_parcheggioautomatico);
        END LOOP;
        
    ELSE --deve effettuare il report e imposta il valore selezionato
        SELECT citta, indirizzo  INTO v_cittaParcheggio, v_indirizzoParcheggio FROM ParcheggiAutomatici WHERE pk_ParcheggioAutomatico = p_parcheggio;
        ui.aggOpzioneAComboBox(v_cittaParcheggio || ', ' || v_indirizzoParcheggio, p_parcheggio);
        ui.aggOpzioneAComboBox('Tutti', -1);
        FOR c_parcheggio IN 
            (SELECT citta, indirizzo, pk_parcheggioautomatico FROM ParcheggiAutomatici WHERE pk_ParcheggioAutomatico <> p_parcheggio)
        LOOP
            ui.aggOpzioneAComboBox(c_parcheggio.citta || ', ' || c_parcheggio.indirizzo, c_parcheggio.pk_parcheggioautomatico);
        END LOOP;
        
    END IF;
    ui.chiudiSelectComboBox;
    
   	ui.creaBottone('Cerca');
   	
   	ui.creabottoneback('Indietro');
    
    IF p_dataInizio IS NOT NULL THEN --deve generare il report
        IF p_dataFine IS NULL THEN
            raise unvalidDataException;
        END IF;
        
        IF TO_DATE(p_dataFine,'YYYY-MM-DD') < TO_DATE(p_dataInizio,'YYYY-MM-DD') THEN
            raise unvalidDataException;
        END IF;
        
        
        IF p_parcheggio = -1 THEN --seleziona da tutti i parcheggi
            OPEN c_veicoloAll;
            FETCH c_veicoloAll into v_fkVeicolo, v_multe;
            IF c_veicoloAll%NOTFOUND THEN
                raise personeException;
            END IF;
        ELSE --seleziona dal parcheggio specificato
            OPEN c_veicolo;
            FETCH c_veicolo into v_fkVeicolo, v_multe;
            IF c_veicolo%NOTFOUND THEN
                raise personeException;
            END IF;
        END IF;
        
        ui.openDiv(idDiv => 'header');
        ui.apriTabella;
        ui.apriRigaTabella;
        ui.intestazioneTabella(testo => 'Nome');
        ui.intestazioneTabella(testo => 'Cognome');
        ui.intestazioneTabella(testo => 'Multe');
        ui.intestazioneTabella(testo => 'Dettagli');
        ui.chiudiRigaTabella;
        ui.chiudiTabella;
        ui.closeDiv;
        
        ui.openDiv(idDiv => 'tabella');
        
        ui.apriTabella;
        
        LOOP
            SELECT Persone.pk_Persona, Persone.nome, Persone.cognome 
            INTO v_cliente, v_nome, v_cognome FROM Persone WHERE pk_Persona = 
                (SELECT fk_proprietario 
                 FROM Veicoli 
                 WHERE pk_Veicolo = v_fkVeicolo);
                    
            ui.apriRigaTabella;
            ui.elementoTabella(testo => v_nome);
            ui.elementoTabella(testo => v_cognome);
            ui.elementoTabella(testo => v_multe);
            ui.apriElementoTabella;
            ui.createLinkableButton('Visualizza', C_URL || PKGNAME || 'visualizzaCliente?username=' || username ||
                    '&status=' || status || '&p_cliente=' || v_cliente);
            ui.chiudiElementoTabella;
            ui.chiudiRigaTabella;
             
            IF(p_parcheggio = -1) THEN
                FETCH c_veicoloAll into v_fkVeicolo, v_multe;
                EXIT WHEN c_veicoloAll%NOTFOUND;
            ELSE
                FETCH c_veicolo into v_fkVeicolo, v_multe;
                EXIT WHEN c_veicolo%NOTFOUND;
            END IF;
        END LOOP;
        
        IF(p_parcheggio = -1) THEN
                CLOSE c_VeicoloAll;
            ELSE
                CLOSE c_veicolo;
            END IF;
            
        ui.chiudiTabella;
        ui.closeDiv;
    END IF;
    
    ui.chiudiForm;
    ui.closeBody;
    ui.htmlClose;
    
EXCEPTION
    WHEN unauthorizedException THEN messaggio('Non hai i diritti per accedere a questa funzionalità');
    WHEN usernameException THEN messaggio('Utente non trovato');
    WHEN personeException THEN ui.titolo( 'Non è stato trovato nessun cliente che ha ricevuto multe nel periodo e nel parcheggio indicati');
    WHEN unvalidDataException THEN ui.titolo('I dati inseriti non sono validi');

END reportmulte;

PROCEDURE reportPeso(
    username IN utenti.username%TYPE DEFAULT NULL,
    status varchar2 default '') IS
/*
Crea una classifica dei veicoli raggruppati per peso.
Permette di selezionare le categorie di veicoli da una checkbox e mostra per ognuna di quelle selezionate una tabella ordinata
per peso dei veicoli che appartengono a tale categoria.
*/
v_pkPersona persone.pk_persona%TYPE;

unauthorizedException exception;
usernameException exception;

BEGIN
    v_pkPersona := checkAutorizzazione(username, status, 'dipendente');
    
    IF v_pkPersona = -1 THEN
        raise unauthorizedException; 
    ELSIF v_pkPersona = -2 THEN
        raise usernameException;
    END IF;
    
    ui.htmlOpen;
    ui.inizioPagina(titolo => 'Report peso');
    ui.openBodyStyle;
    ui.openBarraMenu(username,status);
    
    ui.creaForm('Seleziona le categorie di peso di cui vuoi ricevere il report', PKGNAME || 'peso');
    
    ui.creaTextField(nomeParametroGet => 'username', inputType => 'hidden',defaultText => username);
    ui.creaTextField(nomeParametroGet => 'status', inputType => 'hidden', defaultText => status);
    
    FOR c_area IN (SELECT nomeArea, pk_Area FROM Aree)
    LOOP
        ui.CheckBox(etichetta => c_area.nomeArea, nome => 'p_' || c_area.nomeArea, valore => c_area.pk_Area);
    END LOOP;
    
   	ui.creaBottone('Cerca');
   	
    ui.creabottoneback('Indietro');
    
    ui.chiudiForm;
    ui.closeBody;
    ui.htmlClose;
    
EXCEPTION
    WHEN unauthorizedException THEN messaggio('Non hai i diritti per accedere a questa funzionalità');
    WHEN usernameException THEN messaggio('Utente non trovato');
END reportpeso;

PROCEDURE peso(
    username IN utenti.username%TYPE,
    status varchar2 default '',
    p_Auto number DEFAULT -1,
    p_Moto number DEFAULT -1,
    p_Furgone number DEFAULT -1,
    p_Camion number DEFAULT -1,
    p_Camper number DEFAULT -1) IS
/*
Procedura di appoggio per la generazione del report classifica veicoli ordinata per peso.
I parametri p_[Area] assumono il valore della propria chiave primaria all'interno della tabella Aree se selezionati.
*/
v_pkPersona persone.pk_persona%TYPE;
v_numVeicoli number;

unauthorizedException exception;
usernameException exception;
unvalidDataException exception;

BEGIN
    v_pkPersona := checkAutorizzazione(username, status, 'dipendente');
    
    IF v_pkPersona = -1 THEN
        raise unauthorizedException; 
    ELSIF v_pkPersona = -2 THEN
        raise usernameException;
    END IF;
    
    IF(p_Auto = -1 AND p_Moto = -1 AND p_Furgone = -1 AND p_Camion = -1 AND p_Camper = -1) THEN
        raise unvalidDataException;
    END IF;
    
    ui.htmlOpen;
    ui.inizioPagina(titolo => 'Report peso');
    ui.openBodyStyle;
    ui.openBarraMenu(username,status);
    
    FOR c_area IN (SELECT pk_Area, nomeArea FROM Aree WHERE pk_Area IN (p_Auto, p_Moto, p_Camper, p_Furgone, p_Camion))
    LOOP
        SELECT count(*) INTO v_numVeicoli FROM Veicoli WHERE fk_Area = c_area.pk_Area GROUP BY fk_Area;
        ui.titolo('Tipo di veicolo: ' || c_area.nomeArea);
        ui.titolo(' Numero di veicoli: ' || v_numVeicoli);
        ui.openDiv(idDiv => 'header');
        ui.apriTabella;
        ui.apriRigaTabella;
        ui.intestazioneTabella(testo => 'Targa');
        ui.intestazioneTabella(testo => 'Modello');
        ui.intestazioneTabella(testo => 'Peso');
        ui.intestazioneTabella(testo => 'Dettagli');
        ui.chiudiRigaTabella;
        ui.chiudiTabella;
        ui.closeDiv;
        
        ui.openDiv(idDiv => 'tabella');
        
        ui.apriTabella;
        FOR c_veicolo IN (SELECT pk_Veicolo, Targa, Modello, Peso FROM Veicoli WHERE fk_Area = c_area.pk_Area AND Cancellato = 0 ORDER BY Peso DESC)
        LOOP
            ui.apriRigaTabella;
            ui.elementoTabella(testo => c_veicolo.Targa);
            ui.elementoTabella(testo => c_veicolo.Modello);
            ui.elementoTabella(testo => c_veicolo.Peso);
            ui.apriElementoTabella;
            ui.createLinkableButton('Dettagli', 
                    VEICOLOLINK || 'visualizzaVeicoloRep?username=' || username ||
                    '&status=' || status || '&idVeicolo=' || c_veicolo.pk_Veicolo);
            ui.chiudiElementoTabella;
            ui.chiudiRigaTabella;
        END LOOP;
        ui.chiudiTabella;
    
        ui.closeDiv;
    END LOOP;
   
    ui.creaBottoneLink('.ui.openpage?username=' || username || '&status=' || status || '&title=Homepage', 'Torna alla home');
    ui.creabottoneback('Indietro');
    
    ui.closeBody;
    ui.htmlClose;
    
EXCEPTION
    WHEN unauthorizedException THEN messaggio('Non hai i diritti per accedere a questa funzionalità');
    WHEN unvalidDataException THEN messaggio('Errore durante il recupero dei dati');
    WHEN usernameException THEN messaggio('Utente non trovato');
END peso;



--continuare da qui


procedure reportAbbonamentiCarburante(
	username IN utenti.username%TYPE DEFAULT NULL,
	status varchar2 default '',
    p_carburante1 IN Carburanti.pk_Carburante%TYPE default null,
    p_carburante2 IN Carburanti.pk_Carburante%TYPE default null,
    p_dataInizio varchar2 default null,
    p_dataFine varchar2 default null,
    p_parcheggio IN parcheggiautomatici.pk_parcheggioautomatico%TYPE default -1) IS
/*
Report (di ogni gruppo) che mostra i dettagli dei veicoli di una determinata tipologia di carburante che hanno stipulato
più abbonamenti rispetto ai veicoli di un’altra tipologia di carburante in un particolare parcheggio e in un particolare
periodo di tempo.
*/
v_pkPersona persone.pk_persona%TYPE;
v_pkVeicolo veicoli.pk_Veicolo%TYPE;
v_targa veicoli.targa%TYPE;
v_modello veicoli.modello%TYPE;
v_maxCarburante2 number;
v_nome_carburante1 Carburanti.nome%TYPE;
v_nome_carburante2 Carburanti.nome%TYPE;
v_cittaParcheggio ParcheggiAutomatici.citta%TYPE;
v_indirizzoParcheggio ParcheggiAutomatici.indirizzo%TYPE;

unauthorizedException exception;
usernameException exception;
unvalidDataException exception;
veicoliException exception;

CURSOR c_veicoliAll IS --query effettuata su tutti i parcheggi
    SELECT A.fk_Veicolo FROM Veicoli V
    INNER JOIN Abbonamenti A ON A.fk_Veicolo = V.pk_Veicolo
    WHERE V.tipoCarburante = (SELECT nome FROM Carburanti WHERE pk_Carburante = p_carburante1)
    AND A.dataInizioValidita >= TO_DATE(p_dataInizio,'YYYY-MM-DD')
    AND A.dataFineValidita <= TO_DATE(p_dataFine,'YYYY-MM-DD')
    GROUP BY (A.fk_Veicolo)
    HAVING count(A.fk_Veicolo) > v_maxCarburante2;
    
CURSOR c_veicoli IS --query effettuata su uno specifico parcheggio
    SELECT A.fk_Veicolo FROM Veicoli V
    INNER JOIN Abbonamenti A ON A.fk_Veicolo = V.pk_Veicolo
    WHERE V.tipoCarburante = (SELECT nome FROM Carburanti WHERE pk_Carburante = p_carburante1)
    AND A.fk_ParcheggioAutomatico = p_parcheggio
    AND A.dataInizioValidita >= TO_DATE(p_dataInizio,'YYYY-MM-DD')
    AND A.dataFineValidita <= TO_DATE(p_dataFine,'YYYY-MM-DD')
    GROUP BY (A.fk_Veicolo)
    HAVING count(A.fk_Veicolo) > v_maxCarburante2;

CURSOR c_abbCarburante2All IS --subquery per il conteggio di abbonamenti per il secondo tipo di carburante per tutti i parcheggi
    SELECT MAX(num_abbonamenti) FROM
        (SELECT count(A1.fk_Veicolo) num_abbonamenti 
        FROM Abbonamenti A1
        INNER JOIN Veicoli V1 ON A1.fk_Veicolo = V1.pk_Veicolo
        WHERE V1.tipoCarburante = (SELECT nome FROM Carburanti WHERE pk_Carburante = p_carburante2)
        AND A1.dataInizioValidita >= TO_DATE(p_dataInizio,'YYYY-MM-DD')
        AND A1.dataFineValidita <= TO_DATE(p_dataFine,'YYYY-MM-DD')
        GROUP BY(A1.fk_Veicolo));

CURSOR c_abbCarburante2 IS --subquery per il conteggio di abbonamenti per il secondo tipo di carburante per uno specifico parcheggio
    SELECT MAX(num_abbonamenti) FROM
        (SELECT count(A1.fk_Veicolo) num_abbonamenti 
        FROM Abbonamenti A1
        INNER JOIN Veicoli V1 ON A1.fk_Veicolo = V1.pk_Veicolo
        WHERE V1.tipoCarburante = (SELECT nome FROM Carburanti WHERE pk_Carburante = p_carburante2)
        AND A1.fk_ParcheggioAutomatico = p_parcheggio
        AND A1.dataInizioValidita >= TO_DATE(p_dataInizio,'YYYY-MM-DD')
        AND A1.dataFineValidita <= TO_DATE(p_dataFine,'YYYY-MM-DD')
        GROUP BY(A1.fk_Veicolo));

BEGIN
    v_pkPersona := checkAutorizzazione(username, status, 'dipendente');
    
    IF v_pkPersona = -1 THEN
        raise unauthorizedException; 
    ELSIF v_pkPersona = -2 THEN
        raise usernameException;
    END IF;
    
    ui.htmlOpen;
    ui.inizioPagina(titolo => 'Report abbonamenti carburante');
    ui.openBodyStyle;
    ui.openBarraMenu(username,status);
    
    ui.creaForm('Seleziona i dati', PKGNAME || 'reportabbonamenticarburante');
    
    ui.creaTextField(nomeParametroGet => 'username', inputType => 'hidden',defaultText => username);
    ui.creaTextField(nomeParametroGet => 'status', inputType => 'hidden', defaultText => status);
    
    ui.creaComboBox(nomeLab => 'Carburante 1 ', nomeGet => 'p_carburante1');
    IF(p_carburante1 IS NULL) THEN
        
        FOR c_carburante1 IN (SELECT pk_carburante, nome FROM Carburanti)
        LOOP
            ui.aggOpzioneAComboBox(c_carburante1.nome, c_carburante1.pk_carburante);
        END LOOP;
        
    ELSE --proviene da un form già compilato, deve avvalorare i campi con i valori selezionati
        
        SELECT nome INTO v_nome_carburante1 FROM Carburanti WHERE pk_Carburante = p_carburante1;
        ui.aggOpzioneAComboBox(v_nome_carburante1, p_carburante1);
        FOR c_carburante1 IN (SELECT pk_carburante, nome FROM Carburanti WHERE pk_carburante <> p_carburante1)
        LOOP
            ui.aggOpzioneAComboBox(c_carburante1.nome, c_carburante1.pk_carburante);
        END LOOP;
        
    END IF;
    ui.chiudiSelectComboBox;
    
    ui.creaComboBox(nomeLab => 'Carburante 2 ', nomeGet => 'p_carburante2');
    IF(p_carburante2 IS NULL) THEN
        
        FOR c_carburante2 IN (SELECT pk_carburante, nome FROM Carburanti)
        LOOP
            ui.aggOpzioneAComboBox(c_carburante2.nome, c_carburante2.pk_carburante);
        END LOOP;
        
    ELSE --proviene da un form già compilato, deve avvalorare i campi con i valori selezionati
        
        SELECT nome INTO v_nome_carburante2 FROM Carburanti WHERE pk_Carburante = p_carburante2;
        ui.aggOpzioneAComboBox(v_nome_carburante2, p_carburante2);
        FOR c_carburante2 IN (SELECT pk_carburante, nome FROM Carburanti WHERE pk_carburante <> p_carburante2)
        LOOP
            ui.aggOpzioneAComboBox(c_carburante2.nome, c_carburante2.pk_carburante);
        END LOOP;
        
    END IF;
    ui.chiudiSelectComboBox;
    
    IF p_dataInizio IS NULL THEN
        ui.creaTextField(nomeRif => 'Data Inizio', nomeParametroGet => 'p_dataInizio', inputType => 'date',
            defaultText =>  TO_CHAR(SYSDATE - 365, 'YYYY-MM-DD'));
    ELSE
        ui.creaTextField(nomeRif => 'Data Inizio', nomeParametroGet => 'p_dataInizio', inputType => 'date',
            defaultText =>  p_dataInizio);
    END IF;
    
    IF p_dataFine IS NULL THEN
        ui.creaTextField(nomeRif => 'Data Fine', nomeParametroGet => 'p_dataFine', inputType => 'date',
            defaultText => TO_CHAR(SYSDATE + 365, 'YYYY-MM-DD'));
    ELSE
        ui.creaTextField(nomeRif => 'Data Fine', nomeParametroGet => 'p_dataFine', inputType => 'date',
            defaultText => p_dataFine);
    END IF;
    
    ui.creaComboBox(nomeLab => 'Parcheggio ', nomeGet => 'p_parcheggio');
    IF p_parcheggio = -1 THEN
        
        ui.aggOpzioneAComboBox('Tutti', -1);
        FOR c_parcheggio IN (SELECT citta, indirizzo, pk_parcheggioautomatico FROM ParcheggiAutomatici)
        LOOP
            ui.aggOpzioneAComboBox(c_parcheggio.citta || ', ' || c_parcheggio.indirizzo,
                                    c_parcheggio.pk_parcheggioautomatico);
        END LOOP;
        
    ELSE
        
        SELECT citta, indirizzo INTO v_cittaParcheggio, v_indirizzoParcheggio FROM ParcheggiAutomatici WHERE pk_ParcheggioAutomatico = p_parcheggio;
       
        ui.aggOpzioneAComboBox(v_cittaParcheggio || ', ' || v_indirizzoParcheggio, p_parcheggio);
        ui.aggOpzioneAComboBox('Tutti', -1);
        
        FOR c_parcheggio IN (SELECT P.citta, P.indirizzo, p.pk_parcheggioautomatico FROM ParcheggiAutomatici P WHERE pk_ParcheggioAutomatico <> p_parcheggio)
        LOOP
            ui.aggOpzioneAComboBox(c_parcheggio.citta || ', ' || c_parcheggio.indirizzo,
                                    c_parcheggio.pk_parcheggioautomatico);
        END LOOP;
        
    END IF;
    ui.chiudiSelectComboBox;
    
    ui.creaBottone('Cerca');

   	ui.creaBottoneLink('.ui.openpage?username=' || username || '&status=' || status || '&title=Homepage', 'Indietro');
    
   	IF NOT p_carburante1 is NULL THEN --deve effettuare il report
        IF(p_dataInizio IS null OR p_dataFine IS null OR p_carburante2 IS null) THEN
            raise UnvalidDataException;
        END IF;
        
        IF(p_carburante1 = p_carburante2) THEN
            raise UnvalidDataException;
        END IF;
        
        IF(TO_DATE(p_dataFine,'YYYY-MM-DD') < TO_DATE(p_dataInizio,'YYYY-MM-DD')) THEN
            raise UnvalidDataException;
        END IF;
    
        IF(p_parcheggio = -1) THEN --deve effettuare il report su tutti i parcheggi
            OPEN c_abbCarburante2All;
            FETCH c_abbCarburante2All INTO v_maxCarburante2;
            IF(v_maxCarburante2 IS null) THEN
                v_maxCarburante2 := 0;
            END IF;
            
            OPEN c_veicoliAll;
            FETCH c_veicoliAll INTO v_pkVeicolo;
            IF(c_veicoliAll%NOTFOUND) THEN
                raise VeicoliException; 
            END IF;
        ELSE    --deve effettuare il report su uno specifico parcheggio
            OPEN c_abbCarburante2;
            FETCH c_abbCarburante2 INTO v_maxCarburante2;
            IF(v_maxCarburante2 IS null) THEN
                v_maxCarburante2 := 0;
            END IF;
            
            OPEN c_veicoli;
            FETCH c_veicoli INTO v_pkVeicolo;
            IF(c_veicoli%NOTFOUND) THEN
                raise VeicoliException;
            END IF;
        END IF; 
        
        ui.openDiv(idDiv => 'header');
        ui.apriTabella;
        ui.apriRigaTabella;
        ui.intestazioneTabella(testo => 'Targa');
        ui.intestazioneTabella(testo => 'Modello');
        ui.intestazioneTabella(testo => 'Dettagli');
        ui.chiudiRigaTabella;
        ui.chiudiTabella;
        ui.closeDiv;
        
        ui.openDiv(idDiv => 'tabella');
            
        ui.apriTabella;
        
        LOOP
            SELECT targa, modello INTO v_targa, v_modello FROM Veicoli WHERE pk_Veicolo = v_pkVeicolo;
            
            ui.apriRigaTabella;
                ui.elementoTabella(testo => v_targa);
                ui.elementoTabella(testo => v_modello);
                ui.apriElementoTabella;
                ui.createLinkableButton('Visualizza',
                    VEICOLOLINK || 'visualizzaVeicoloRep?username=' || username ||
                    '&status=' || status || '&idVeicolo=' || v_pkVeicolo);
                ui.chiudiElementoTabella;
                ui.chiudiRigaTabella;
                
            IF p_parcheggio = -1 THEN
                FETCH c_veicoliAll INTO v_pkVeicolo;
                EXIT WHEN c_veicoliAll%NOTFOUND;
            ELSE
                FETCH c_veicoli INTO v_pkVeicolo;
                EXIT WHEN c_veicoli%NOTFOUND;
            END IF;
        END LOOP;
        
        IF p_parcheggio = -1 THEN
            CLOSE c_veicoliAll;
        ELSE
            CLOSE c_veicoli;
        END IF;
        
        ui.chiudiTabella;
        ui.closeDiv;
    END IF;
    
    ui.chiudiForm;
    ui.closeBody;
    ui.htmlClose;
EXCEPTION
    WHEN unauthorizedException THEN messaggio('Non hai i diritti per accedere a questa funzionalità');
    WHEN usernameException THEN	messaggio('Utente non trovato');
    WHEN unvalidDataException THEN ui.titolo('I dati inseriti non sono corretti');
    WHEN veicoliException THEN ui.titolo('Non è stato trovato nessun veicolo con i parametri indicati');
END reportabbonamentiCarburante;

procedure reportVeicoli(
	username IN utenti.username%TYPE DEFAULT NULL,
	status varchar2 default '',
    p_cliente IN clienti.pk_Cliente%TYPE DEFAULT -1,
    p_dataInizio varchar2 DEFAULT NULL,
    p_dataFine varchar2 DEFAULT NULL,
    p_parcheggio IN parcheggiautomatici.pk_parcheggioautomatico%TYPE DEFAULT -1) IS
/*
Report che visualizza i dettagli dei veicoli che sono riconducibili a un cliente e che sono stati posteggiati in un determinato
periodo e in una determinato parcheggio.
*/
v_pkPersona persone.pk_persona%TYPE;
v_pkVeicolo veicoli.pk_Veicolo%TYPE;
v_targa veicoli.targa%TYPE;
v_modello veicoli.modello%TYPE;
v_cittaParcheggio ParcheggiAutomatici.citta%TYPE;
v_indirizzoParcheggio ParcheggiAutomatici.indirizzo%TYPE;
v_nome Persone.nome%TYPE;
v_cognome Persone.cognome%TYPE;

unauthorizedException exception;
usernameException exception;
unvalidDataException exception;
veicoliException exception;

CURSOR c_veicoli IS --query che effettua report su ogni cliente e parcheggio
        SELECT V.targa, V.modello, V.pk_Veicolo FROM Veicoli V  --recupera tutti i veicoli validi che utilizza il cliente
        INNER JOIN ClientiVeicoli CV ON CV.fk_Veicolo = V.pk_Veicolo
        WHERE CV.fk_cliente = p_cliente
        AND V.pk_Veicolo IN
            (SELECT S.fk_Veicolo FROM Soste S
             INNER JOIN Box B ON B.pk_Box = S.fk_Box
             INNER JOIN Colonne C ON C.pk_Colonna = B.fk_Colonna
             WHERE (S.inizio >= TO_DATE(p_dataInizio,'YYYY-MM-DD') AND S.Fine <= TO_DATE(p_dataFine,'YYYY-MM-DD'))                 
             AND C.fk_ParcheggioAutomatico = p_parcheggio)
    UNION   --recupera tutti i veicoli validi di cui è proprietario il cliente
        SELECT V.targa, V.modello, V.pk_Veicolo FROM Veicoli V
        WHERE V.fk_Proprietario = p_cliente
        AND V.pk_Veicolo IN
            (SELECT S.fk_Veicolo FROM Soste S
             INNER JOIN Box B ON B.pk_Box = S.fk_Box
             INNER JOIN Colonne C ON C.pk_Colonna = B.fk_Colonna
             WHERE (S.inizio >= TO_DATE(p_dataInizio,'YYYY-MM-DD') AND S.Fine <= TO_DATE(p_dataFine,'YYYY-MM-DD'))                 
             AND C.fk_ParcheggioAutomatico = p_parcheggio);
         
CURSOR c_veicoliAllC IS --query che effettua report su ogni cliente ed uno specifico parcheggio
    SELECT V.targa, V.modello, V.pk_Veicolo FROM Veicoli V
    WHERE V.pk_Veicolo IN
        (SELECT S.fk_Veicolo FROM Soste S
         INNER JOIN Box B ON B.pk_Box = S.fk_Box
         INNER JOIN Colonne C ON C.pk_Colonna = B.fk_Colonna
         WHERE (S.inizio >= TO_DATE(p_dataInizio,'YYYY-MM-DD') AND S.Fine <= TO_DATE(p_dataFine,'YYYY-MM-DD'))  
         AND C.fk_ParcheggioAutomatico = p_parcheggio);

CURSOR c_veicoliAllP IS --query che effettua report su ogni parcheggio ed uno specifico cliente
        SELECT V.targa, V.modello, V.pk_Veicolo FROM Veicoli V
        INNER JOIN ClientiVeicoli CV ON CV.fk_Veicolo = V.pk_Veicolo
        WHERE CV.fk_cliente = p_cliente
        AND V.pk_Veicolo IN
            (SELECT S.fk_Veicolo FROM Soste S
             WHERE S.inizio >= TO_DATE(p_dataInizio,'YYYY-MM-DD') AND S.Fine <= TO_DATE(p_dataFine,'YYYY-MM-DD'))
    UNION
        SELECT V.targa, V.modello, V.pk_Veicolo FROM Veicoli V
        WHERE V.fk_Proprietario = p_cliente
        AND V.pk_Veicolo IN
            (SELECT S.fk_Veicolo FROM Soste S
             WHERE S.inizio >= TO_DATE(p_dataInizio,'YYYY-MM-DD') AND S.Fine <= TO_DATE(p_dataFine,'YYYY-MM-DD'));
             
CURSOR c_veicoliAllCP IS --query che effettua report su uno specifico cliente ed uno specifico parcheggio
    SELECT V.targa, V.modello, V.pk_Veicolo FROM Veicoli V
    WHERE V.pk_Veicolo IN
        (SELECT S.fk_Veicolo FROM Soste S
         WHERE S.inizio >= TO_DATE(p_dataInizio,'YYYY-MM-DD') AND S.Fine <= TO_DATE(p_dataFine,'YYYY-MM-DD'));

BEGIN
    v_pkPersona := checkAutorizzazione(username, status, 'dipendente');
    
    IF v_pkPersona = -1 THEN
        raise unauthorizedException; 
    ELSIF v_pkPersona = -2 THEN
        raise usernameException;
    END IF;
    
    ui.htmlOpen;
    ui.inizioPagina(titolo => 'Report veicoli');
    ui.openBodyStyle;
    ui.openBarraMenu(username,status);
    
    ui.creaForm('Seleziona i dati', PKGNAME || 'reportveicoli');
    
    ui.creaTextField(nomeParametroGet => 'username', inputType => 'hidden',defaultText => username);
    ui.creaTextField(nomeParametroGet => 'status', inputType => 'hidden', defaultText => status);
    
    ui.creaComboBox(nomeLab => 'Cliente ', nomeGet => 'p_cliente');
    IF p_cliente = -1 THEN
        ui.aggOpzioneAComboBox('Tutti', -1);
        FOR c_cliente IN (SELECT nome, cognome, pk_cliente FROM Clienti INNER JOIN Persone ON pk_Cliente = pk_Persona)
        LOOP
            ui.aggOpzioneAComboBox(c_cliente.nome || ' ' || c_cliente.cognome, c_cliente.pk_cliente);
        END LOOP;
    ELSE --deve selezionare il cliente scelto precedentemente
        SELECT nome, cognome INTO v_nome, v_cognome FROM Clienti INNER JOIN Persone ON pk_Cliente = pk_Persona WHERE pk_Cliente = p_cliente;
        ui.aggOpzioneAComboBox(v_nome || ' ' || v_cognome, p_cliente);
        ui.aggOpzioneAComboBox('Tutti', -1);
        FOR c_cliente IN (SELECT nome, cognome, pk_cliente FROM Clienti INNER JOIN Persone ON pk_Cliente = pk_Persona WHERE pk_Cliente <> p_cliente)
        LOOP
            ui.aggOpzioneAComboBox(c_cliente.nome || ' ' || c_cliente.cognome, p_cliente);
        END LOOP;
    END IF;
    ui.chiudiSelectComboBox;
    
    IF p_dataInizio IS NULL THEN
        ui.creaTextField(nomeRif => 'Data Inizio', nomeParametroGet => 'p_dataInizio', inputType => 'date', defaultText => TO_CHAR(SYSDATE - 10, 'YYYY-MM-DD'));
    ELSE
        ui.creaTextField(nomeRif => 'Data Inizio', nomeParametroGet => 'p_dataInizio', inputType => 'date', defaultText =>  p_dataInizio);
    END IF;
    
    IF p_dataFine IS NULL THEN
        ui.creaTextField(nomeRif => 'Data Fine', nomeParametroGet => 'p_dataFine', inputType => 'date', defaultText => TO_CHAR(SYSDATE, 'YYYY-MM-DD'));
    ELSE
        ui.creaTextField(nomeRif => 'Data Fine', nomeParametroGet => 'p_dataFine', inputType => 'date', defaultText => p_dataFine);
    END IF;
    
    ui.creaComboBox(nomeLab => 'Parcheggio ', nomeGet => 'p_parcheggio');
    IF p_parcheggio = -1 THEN 
        ui.aggOpzioneAComboBox('Tutti', -1);
        FOR c_parcheggio IN (SELECT citta, indirizzo, pk_parcheggioautomatico FROM ParcheggiAutomatici)
        LOOP
            ui.aggOpzioneAComboBox(c_parcheggio.citta || ', ' || c_parcheggio.indirizzo,
                                    c_parcheggio.pk_parcheggioautomatico);
        END LOOP;
    ELSE --seleziona il parcheggio scelto in precedenza
        SELECT citta, indirizzo INTO v_cittaParcheggio, v_indirizzoParcheggio FROM ParcheggiAutomatici WHERE pk_ParcheggioAutomatico = p_parcheggio;
        ui.aggOpzioneAComboBox(v_cittaParcheggio || ', ' || v_indirizzoParcheggio, p_parcheggio);
        ui.aggOpzioneAComboBox('Tutti', -1);
        FOR c_parcheggio IN (SELECT citta, indirizzo, pk_parcheggioautomatico FROM ParcheggiAutomatici WHERE pk_ParcheggioAutomatico <> p_parcheggio)
        LOOP
            ui.aggOpzioneAComboBox(c_parcheggio.citta || ', ' || c_parcheggio.indirizzo,
                                    c_parcheggio.pk_parcheggioautomatico);
        END LOOP;
    END IF;
    ui.chiudiSelectComboBox;
    
    ui.creaBottone('Cerca');
   	
   	ui.creaBottoneBack('Indietro');
    
   	IF NOT p_dataInizio is NULL THEN --deve generare il report
        IF p_dataFine IS NULL THEN
            raise UnvalidDataException;
        END IF;
        
        IF(TO_DATE(p_dataFine,'YYYY-MM-DD') < TO_DATE(p_dataInizio,'YYYY-MM-DD')) THEN --datafine deve essere >= di data inizio
            raise UnvalidDataException;
        END IF;
            
        IF p_cliente = -1 THEN    --deve effettuare report su tutti i clienti
            IF p_parcheggio = -1 THEN     --deve effettuare report su tutti i parcheggi
                OPEN c_VeicoliAllCP;
                FETCH c_veicoliAllCP INTO v_targa, v_modello, v_pkVeicolo;
                IF(c_veicoliAllCP%NOTFOUND) THEN
                    raise VeicoliException; 
                END IF;
            ELSE    --deve effettuare report su uno specifico parcheggio
                OPEN c_VeicoliAllC;
                FETCH c_veicoliAllC INTO v_targa, v_modello, v_pkVeicolo;
                IF(c_veicoliAllC%NOTFOUND) THEN
                    raise VeicoliException; 
                END IF;
            END IF;
        ELSE --deve effettuare report su uno specifico cliente
            IF p_parcheggio = -1 THEN --deve effettuare report su tutti i parcheggi
                OPEN c_VeicoliAllP;
                FETCH c_veicoliAllP INTO v_targa, v_modello, v_pkVeicolo;
                IF(c_veicoliAllP%NOTFOUND) THEN
                    raise VeicoliException; 
                END IF;
            ELSE --deve effettuare report su uno specifico parcheggio
                OPEN c_Veicoli;
                FETCH c_veicoli INTO v_targa, v_modello, v_pkVeicolo;
                IF(c_veicoli%NOTFOUND) THEN
                    raise VeicoliException; 
                END IF;
            END IF;
        END IF;
        
        ui.openDiv(idDiv => 'header');
        ui.apriTabella;
        ui.apriRigaTabella;
        ui.intestazioneTabella(testo => 'Targa');
        ui.intestazioneTabella(testo => 'Modello');
        ui.intestazioneTabella(testo => 'Dettagli');
        ui.chiudiRigaTabella;
        ui.chiudiTabella;
        ui.closeDiv;
        
        ui.openDiv(idDiv => 'tabella');
            
        ui.apriTabella;
        
        LOOP
            ui.apriRigaTabella;
                ui.elementoTabella(testo => v_targa);
                ui.elementoTabella(testo => v_modello);
                ui.apriElementoTabella;
                ui.createLinkableButton('Visualizza',
                    VEICOLOLINK || 'visualizzaVeicoloRep?username=' || username ||
                    '&status=' || status || '&idVeicolo=' || v_pkVeicolo);
                ui.chiudiElementoTabella;
                ui.chiudiRigaTabella;
                
            IF p_cliente = -1 THEN
                IF p_parcheggio = -1 THEN
                    FETCH c_veicoliAllCP INTO v_targa, v_modello, v_pkVeicolo;
                    EXIT WHEN c_veicoliAllCP%NOTFOUND;
                ELSE
                    FETCH c_veicoliAllC INTO v_targa, v_modello, v_pkVeicolo;
                    EXIT WHEN c_veicoliAllC%NOTFOUND;
                END IF;
            ELSE
                IF p_parcheggio = -1 THEN
                    FETCH c_veicoliAllP INTO v_targa, v_modello, v_pkVeicolo;
                    EXIT WHEN c_veicoliAllP%NOTFOUND;
                ELSE
                    FETCH c_veicoli INTO v_targa, v_modello, v_pkVeicolo;
                    EXIT WHEN c_veicoli%NOTFOUND;
                END IF;
            END IF;
        END LOOP;
        
        IF p_cliente = -1 THEN
            IF p_parcheggio = -1 THEN
                CLOSE c_veicoliAllCP;
            ELSE
                CLOSE c_veicoliAllC;
            END IF;
        ELSE
            IF p_parcheggio = -1 THEN
                CLOSE c_veicoliAllP;
            ELSE
                CLOSE c_veicoli;
            END IF;
        END IF;
        
        ui.chiudiTabella;
        ui.closeDiv;

    END IF;
    
    ui.chiudiForm;
    ui.closeBody;
    ui.htmlClose;
    
EXCEPTION
    WHEN unauthorizedException THEN messaggio('Non hai i diritti per accedere a questa funzionalità');
    WHEN usernameException THEN messaggio('Utente non trovato');
    WHEN unvalidDataException THEN ui.titolo('I dati inseriti non sono corretti');
    WHEN veicoliException THEN ui.titolo('Non è stato trovato nessun veicolo con i parametri indicati');
END reportveicoli;

END leonardo;
