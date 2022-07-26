#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "defines.h"

static void start_loan(MYSQL* conn, char bibliotecaImp[16]);

static char* find_library(MYSQL* conn) {
	MYSQL_STMT* ottieni_biblioteca_impiego_procedure;
	MYSQL_BIND param[2];
	struct param_type paramStruct;
	
	char biblioteca[16] = "zzzzzzzzzzzzzzz";

	if (!setup_prepared_stmt(&ottieni_biblioteca_impiego_procedure, "call ottieni_biblioteca_impiego(?, ?)", conn)) {
		finish_with_stmt_error(conn, ottieni_biblioteca_impiego_procedure, "Unable to initialize library search statement\n", false);
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));
	paramStruct.varchar[0] = conf.username;
	paramStruct.varchar[1] = biblioteca;
	paramStruct.numVarchar = 2;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_param(ottieni_biblioteca_impiego_procedure, param) != 0) {
		finish_with_stmt_error(conn, ottieni_biblioteca_impiego_procedure, "Could not bind parameters for library search\n", true);
	}

	if (mysql_stmt_execute(ottieni_biblioteca_impiego_procedure) != 0) {
		finish_with_stmt_error(conn, ottieni_biblioteca_impiego_procedure, "An error occurred while looking for the library\n", true);
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));
	paramStruct.varchar[0] = biblioteca;
	paramStruct.numVarchar = 1;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_result(ottieni_biblioteca_impiego_procedure, param)) {
		finish_with_stmt_error(conn, ottieni_biblioteca_impiego_procedure, "Could not retrieve output parameter\n", true);
	}

	if (mysql_stmt_fetch(ottieni_biblioteca_impiego_procedure)) {
		finish_with_stmt_error(conn, ottieni_biblioteca_impiego_procedure, "Could not buffer results\n", true);
	}

	mysql_stmt_close(ottieni_biblioteca_impiego_procedure);
	return fixString(biblioteca);
}

static void add_fav_contact(MYSQL* conn, char cf[17]) {
	MYSQL_STMT* aggiungi_contatto_preferito_procedure;
	MYSQL_BIND param[2];
	struct param_type paramStruct;
	char options[3] = { '1', '2', '3' };
	char op;

	char mezzoComPref[45];
	printf("\nChoose the favorite type of contact:\n");
	printf("\t1) Telephone\n");
	printf("\t2) Mobile phone\n");
	printf("\t3) E-mail\n");
	fflush(stdout);
	op = multiChoice("Select type of contact", options, 3);

	switch (op) {
	case '1':
		strcpy(mezzoComPref, "telefono");
		break;

	case '2':
		strcpy(mezzoComPref, "cellulare");
		break;

	case '3':
		strcpy(mezzoComPref, "email");
		break;

	default:
		fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
		abort();
	}

	if (!setup_prepared_stmt(&aggiungi_contatto_preferito_procedure, "call aggiungi_contatto_preferito(?, ?)", conn)) {
		finish_with_stmt_error(conn, aggiungi_contatto_preferito_procedure, "Unable to initialize favorite contact insertion statement\n", false);
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));
	paramStruct.varchar[0] = mezzoComPref;
	paramStruct.varchar[1] = cf;
	paramStruct.numVarchar = 2;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_param(aggiungi_contatto_preferito_procedure, param) != 0) {
		print_stmt_error(aggiungi_contatto_preferito_procedure, "Could not bind parameters for favorite contact insertion\n");
		goto again;
	}

	if (mysql_stmt_execute(aggiungi_contatto_preferito_procedure) != 0) {
		print_stmt_error(aggiungi_contatto_preferito_procedure, "An error occurred while adding the favorite contact\n");
		goto again;
	}
	else {
		goto end;
	}

again:
	mysql_stmt_close(aggiungi_contatto_preferito_procedure);
	printf("\nLet's try again!\n");
	fflush(stdout);
	add_fav_contact(conn, cf);
	return;

end:
	printf("Client's information correctly added\n");
	fflush(stdout);
	mysql_stmt_close(aggiungi_contatto_preferito_procedure);
}

static void add_contacts(MYSQL* conn, char cf[17], int numContatti) {
	MYSQL_STMT* aggiungi_contatto_procedure;
	MYSQL_BIND param[3];
	struct param_type paramStruct;
	char options[3] = { '1', '2', '3' };
	char op;

	char recapito[48];
	char mezzoCom[45];

	for (int i = 0; i < numContatti; i++) {
	again:
		printf("\nChoose the type of contact:\n");
		printf("\t1) Telephone\n");
		printf("\t2) Mobile phone\n");
		printf("\t3) E-mail\n");
		fflush(stdout);
		op = multiChoice("Select type of contact", options, 3);
		
		printf("Contact number / e-mail: ");
		fflush(stdout);
		fgets(recapito, 48, stdin);
		recapito[strlen(recapito) - 1] = '\0';

		switch (op) {
		case '1':
			strcpy(mezzoCom, "telefono");
			break;

		case '2':
			strcpy(mezzoCom, "cellulare");
			break;

		case '3':
			strcpy(mezzoCom, "email");
			break;

		default:
			fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
			abort();
		}

		if(!setup_prepared_stmt(&aggiungi_contatto_procedure, "call aggiungi_contatto(?, ?, ?)", conn)) {
			finish_with_stmt_error(conn, aggiungi_contatto_procedure, "Unable to initialize contact insertion statement", false);
		}

		memset(param, 0, sizeof(param));
		memset(&paramStruct, 0, sizeof(paramStruct));

		paramStruct.varchar[0] = recapito;
		paramStruct.varchar[1] = mezzoCom;
		paramStruct.varchar[2] = cf;

		paramStruct.numVarchar = 3;

		bind_par(param, &paramStruct);

		if (mysql_stmt_bind_param(aggiungi_contatto_procedure, param) != 0) {
			print_stmt_error(aggiungi_contatto_procedure, "Could not bind parameters for contact insertion\n");
			mysql_stmt_close(aggiungi_contatto_procedure);
			printf("\nLet's try again!\n");
			fflush(stdout);
			goto again;
		}

		if (mysql_stmt_execute(aggiungi_contatto_procedure) != 0) {
			print_stmt_error(aggiungi_contatto_procedure, "Could not bind parameters for contact insertion\n");
			mysql_stmt_close(aggiungi_contatto_procedure);
			printf("\nLet's try again!\n");
			fflush(stdout);
			goto again;
		}

		mysql_stmt_close(aggiungi_contatto_procedure);
	}
	add_fav_contact(conn, cf);
}

static void add_client(MYSQL* conn) {
	MYSQL_STMT* aggiungi_utente_procedure;
	MYSQL_BIND param[5];
	struct param_type paramStruct;

	char cf[24];
	char nome[48];
	char cognome[48];
	char indirizzo[48];
	char giornoStr[16];
	char meseStr[16];
	char annoStr[16];
	char numContattiStr[16];

	printf("\nTax code: ");
	fflush(stdout);
	fgets(cf, 24, stdin);
	cf[strlen(cf) - 1] = '\0';
	printf("Name: ");
	fflush(stdout);
	fgets(nome, 48, stdin);
	nome[strlen(nome) - 1] = '\0';
	printf("Surname: ");
	fflush(stdout);
	fgets(cognome, 48, stdin);
	cognome[strlen(cognome) - 1] = '\0';
	printf("Address: ");
	fflush(stdout);
	fgets(indirizzo, 48, stdin);
	indirizzo[strlen(indirizzo) - 1] = '\0';
	printf("Day of birth [1-31]: ");
	fflush(stdout);
	fgets(giornoStr, 16, stdin);
	printf("Month of birth [1-12]: ");
	fflush(stdout);
	fgets(meseStr, 16, stdin);
	printf("Year of birth: ");
	fflush(stdout);
	fgets(annoStr, 16, stdin);
	printf("Number of contacts: ");
	fflush(stdout);
	fgets(numContattiStr, 16, stdin);

	int giorno = atoi(giornoStr);
	int mese = atoi(meseStr);
	int anno = atoi(annoStr);
	int numContatti = atoi(numContattiStr);

	struct MYSQL_TIME date;
	memset(&date, 0, sizeof(date));

	date.day = giorno;
	date.month = mese;
	date.year = anno;

	if (!setup_prepared_stmt(&aggiungi_utente_procedure, "call aggiungi_utente(?, ?, ?, ?, ?)", conn)) {
		finish_with_stmt_error(conn, aggiungi_utente_procedure, "Unable to initialize client insertion statement\n", false);
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));

	paramStruct.varchar[0] = cf;
	paramStruct.varchar[1] = nome;
	paramStruct.varchar[2] = cognome;
	paramStruct.varchar[3] = indirizzo;
	paramStruct.date[0] = &date;

	paramStruct.numVarchar = 4;
	paramStruct.numDate = 1;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_param(aggiungi_utente_procedure, param) != 0) {
		finish_with_stmt_error(conn, aggiungi_utente_procedure, "Could not bind parameters for client insertion\n", true);
	}

	if (mysql_stmt_execute(aggiungi_utente_procedure) != 0) {
		print_stmt_error(aggiungi_utente_procedure, "An error occurred while adding the client\n");
		mysql_stmt_close(aggiungi_utente_procedure);
	}
	else {
		mysql_stmt_close(aggiungi_utente_procedure);
		add_contacts(conn, cf, numContatti);
	}
}

static void start_transfer(MYSQL* conn, char isbn[14], char bibliotecaImp[16], char cf[17], char durata[46]) {
	MYSQL_STMT* inizia_trasferimento_procedure;
	MYSQL_BIND param[5];
	struct param_type paramStruct;

	char bibliotecaPart[24];
	printf("\nChoose a library: ");
	fflush(stdout);
	fgets(bibliotecaPart, 24, stdin);
	bibliotecaPart[strlen(bibliotecaPart) - 1] = '\0';

	if (!setup_prepared_stmt(&inizia_trasferimento_procedure, "call inizia_trasferimento(?, ?, ?, ?, ?)", conn)) {
		finish_with_stmt_error(conn, inizia_trasferimento_procedure, "Unable to initialize transfer start statement\n", false);
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));

	paramStruct.varchar[0] = isbn;
	paramStruct.varchar[1] = bibliotecaImp;
	paramStruct.varchar[2] = bibliotecaPart;
	paramStruct.varchar[3] = cf;
	paramStruct.varchar[4] = durata;

	paramStruct.numVarchar = 5;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_param(inizia_trasferimento_procedure, param) != 0) {
		finish_with_stmt_error(conn, inizia_trasferimento_procedure, "Could not bind parameters for transfer start\n", true);
	}

	if (mysql_stmt_execute(inizia_trasferimento_procedure) != 0) {
		print_stmt_error(inizia_trasferimento_procedure, "An error occurred while starting the transfer\n");
		mysql_stmt_close(inizia_trasferimento_procedure);
		printf("Let's try again!\n");
		fflush(stdout);
		start_loan(conn, bibliotecaImp);
	}

	dump_result_set(conn, inizia_trasferimento_procedure, "You are going to lend this copy of selected library:\n");
	if (mysql_stmt_next_result(inizia_trasferimento_procedure) > 0) {
		finish_with_stmt_error(conn, inizia_trasferimento_procedure, "Unexpected contidion\n", true);
	}

	mysql_stmt_close(inizia_trasferimento_procedure);
}

static void start_loan(MYSQL* conn, char bibliotecaImp[16]) {
	MYSQL_STMT* inizia_prestito_procedure;
	MYSQL_BIND param[4];
	struct param_type paramStruct;
	char options[3] = { '1', '2', '3' };
	char dur;

	char isbn[16];
	char cf[24];
	char durata[48];

	printf("\nBook ISBN: ");
	fflush(stdout);
	fgets(isbn, 16, stdin);
	isbn[strlen(isbn) - 1] = '\0';
	printf("Client tax code: ");
	fflush(stdout);
	fgets(cf, 24, stdin);
	cf[strlen(cf) - 1] = '\0';

	printf("\nChoose the expected duration of the loan:\n");
	printf("\t1) One month\n");
	printf("\t2) Two months\n");
	printf("\t3) Three months\n");
	fflush(stdout);
	dur = multiChoice("Select expected duration", options, 3);

	switch (dur) {
	case '1':
		strcpy(durata, "1 mese");
		break;

	case '2':
		strcpy(durata, "2 mesi");
		break;

	case '3':
		strcpy(durata, "3 mesi");
		break;

	default:
		fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
		abort();
	}

	if (!setup_prepared_stmt(&inizia_prestito_procedure, "call inizia_prestito(?, ?, ?, ?)", conn)) {
		finish_with_stmt_error(conn, inizia_prestito_procedure, "Unable to initialize loan start statement\n", false);
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));

	paramStruct.varchar[0] = isbn;
	paramStruct.varchar[1] = bibliotecaImp;
	paramStruct.varchar[2] = cf;
	paramStruct.varchar[3] = durata;

	paramStruct.numVarchar = 4;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_param(inizia_prestito_procedure, param) != 0) {
		finish_with_stmt_error(conn, inizia_prestito_procedure, "Could not bind parameters for loan start\n", true);
	}

	if (mysql_stmt_execute(inizia_prestito_procedure) != 0) {
		finish_with_stmt_error(conn, inizia_prestito_procedure, "An error occurred while starting the loan\n", true);
	}

	short int trasf = 0;
	if (mysql_stmt_store_result(inizia_prestito_procedure)) {	 // Funzione di libreria che estrae il result set corrente per poterlo poi processare
		fprintf(stderr, " mysql_stmt_execute(), 1 failed\n");
		fprintf(stderr, " %s\n", mysql_stmt_error(inizia_prestito_procedure));
		exit(0);
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));
	paramStruct.b = &trasf;
	paramStruct.numBool = 1;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_result(inizia_prestito_procedure, param)) {
		finish_with_stmt_error(conn, inizia_prestito_procedure, "Unable to bind column parameters\n", true);
	}

	if (mysql_stmt_fetch(inizia_prestito_procedure)) {
		finish_with_stmt_error(conn, inizia_prestito_procedure, "Could not buffer results\n", true);
	}

	if (mysql_stmt_next_result(inizia_prestito_procedure) != 0) {
		finish_with_stmt_error(conn, inizia_prestito_procedure, "Unexpected condition\n", true);
	}

	if (!trasf) {
		dump_result_set(conn, inizia_prestito_procedure, "Required book is available in your library. You are going to lend this copy:\n");
		if (mysql_stmt_next_result(inizia_prestito_procedure) > 0) {
			finish_with_stmt_error(conn, inizia_prestito_procedure, "Unexpected contidion\n", true);
		}
		mysql_stmt_close(inizia_prestito_procedure);
	}
	else {
		dump_result_set(conn, inizia_prestito_procedure, "Required book is not available in your library. Here there are the libraries you can ask a transfer to:\n");
		if (mysql_stmt_next_result(inizia_prestito_procedure) > 0) {
			finish_with_stmt_error(conn, inizia_prestito_procedure, "Unexpected contidion\n", true);
		}
		mysql_stmt_close(inizia_prestito_procedure);
		start_transfer(conn, isbn, bibliotecaImp, cf, durata);
	}
}

static void get_isbn(MYSQL* conn) {
	MYSQL_STMT* ottieni_ISBN_procedure;
	MYSQL_BIND param[2];
	struct param_type paramStruct;

	char titolo[48];
	char autore[48];

	printf("\nTitle: ");
	fflush(stdout);
	fgets(titolo, 48, stdin);
	titolo[strlen(titolo) - 1] = '\0';
	printf("Author: ");
	fflush(stdout);
	fgets(autore, 48, stdin);
	autore[strlen(autore) - 1] = '\0';

	if (!setup_prepared_stmt(&ottieni_ISBN_procedure, "call ottieni_ISBN(?, ?)", conn)) {
		finish_with_stmt_error(conn, ottieni_ISBN_procedure, "Unable to initialize ISBN query statement\n", false);
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));
	paramStruct.varchar[0] = titolo;
	paramStruct.varchar[1] = autore;
	paramStruct.numVarchar = 2;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_param(ottieni_ISBN_procedure, param) != 0) {
		finish_with_stmt_error(conn, ottieni_ISBN_procedure, "Could not bind parameters for ISBN query\n", true);
	}

	if (mysql_stmt_execute(ottieni_ISBN_procedure) != 0) {
		finish_with_stmt_error(conn, ottieni_ISBN_procedure, "An error occurred while looking for ISBN\n", true);
	}

	dump_result_set(conn, ottieni_ISBN_procedure, "");
	if (mysql_stmt_next_result(ottieni_ISBN_procedure) > 0) {
		finish_with_stmt_error(conn, ottieni_ISBN_procedure, "Unexpected contidion\n", true);
	}

	mysql_stmt_close(ottieni_ISBN_procedure);
}

static void show_loans(MYSQL* conn, char bibliotecaImp[16]) {
	MYSQL_STMT* report_prestiti_procedure;
	MYSQL_BIND param[1];
	struct param_type paramStruct;

	if (!setup_prepared_stmt(&report_prestiti_procedure, "call report_prestiti(?)", conn)) {
		finish_with_stmt_error(conn, report_prestiti_procedure, "Unable to initialize loans report statement\n", false);
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));
	paramStruct.varchar[0] = bibliotecaImp;
	paramStruct.numVarchar = 1;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_param(report_prestiti_procedure, param) != 0) {
		finish_with_stmt_error(conn, report_prestiti_procedure, "Could not bind parameters for loans report\n", true);
	}

	if (mysql_stmt_execute(report_prestiti_procedure) != 0) {
		finish_with_stmt_error(conn, report_prestiti_procedure, "An error occurred while retrieving the loans report\n", true);
	}
	
	dump_result_set(conn, report_prestiti_procedure, "\n\nBooks in loan:\n");

	if (mysql_stmt_next_result(report_prestiti_procedure)) {
		finish_with_stmt_error(conn, report_prestiti_procedure, "Unexpected contidion\n", true);
	}
	dump_result_set(conn, report_prestiti_procedure, "\n\nInformation about clients that have the books:\n");

	if (mysql_stmt_next_result(report_prestiti_procedure)) {
		finish_with_stmt_error(conn, report_prestiti_procedure, "Unexpected contidion\n", true);
	}
	dump_result_set(conn, report_prestiti_procedure, "\n\nClients' contacts:\n");

	if (mysql_stmt_next_result(report_prestiti_procedure) > 0) {
		finish_with_stmt_error(conn, report_prestiti_procedure, "Unexpected contidion\n", true);
	}
	mysql_stmt_close(report_prestiti_procedure);
}

static void end_loan(MYSQL* conn) {
	MYSQL_STMT* termina_prestito_procedure;
	MYSQL_BIND param[2];
	struct param_type paramStruct;

	char idStr[16];
	printf("\nBook ID: ");
	fflush(stdout);
	fgets(idStr, 16, stdin);

	int id = atoi(idStr);
	float tar = 0;

	if (!setup_prepared_stmt(&termina_prestito_procedure, "call termina_prestito(?, ?)", conn)) {
		finish_with_stmt_error(conn, termina_prestito_procedure, "Unable to initialize loan end statement\n", false);
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));

	paramStruct.integer[0] = &id;
	paramStruct.f = &tar;

	paramStruct.numInt = 1;
	paramStruct.numFloat = 1;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_param(termina_prestito_procedure, param) != 0) {
		finish_with_stmt_error(conn, termina_prestito_procedure, "Could not bind parameters for loan end\n", true);
	}

	if (mysql_stmt_execute(termina_prestito_procedure) != 0) {
		print_stmt_error(termina_prestito_procedure, "An error occurred while ending the loan\n");
		goto out;
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));
	paramStruct.f = &tar;
	paramStruct.numFloat = 1;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_result(termina_prestito_procedure, param)) {
		finish_with_stmt_error(conn, termina_prestito_procedure, "Could not retrieve output parameter\n", true);
	}

	if (mysql_stmt_fetch(termina_prestito_procedure)) {
		finish_with_stmt_error(conn, termina_prestito_procedure, "Could not buffer results\n", true);
	}

	printf("Loan correcty terminated. Penalty is: %.02f euros\n", tar);
	fflush(stdout);

out:
	mysql_stmt_close(termina_prestito_procedure);
}

void run_as_librarian(MYSQL* conn) {
	char options[6] = { '1', '2', '3', '4', '5', '6' };
	char op;

	printf("Switching to librarian role...\n");
	fflush(stdout);

	if (!parse_config("users/bibliotecario.json", &conf)) {
		fprintf(stderr, "Unable to load librarian configuration\n");
		exit(EXIT_FAILURE);
	}

	if (mysql_change_user(conn, conf.db_username, conf.db_password, conf.database)) {
		fprintf(stderr, "mysql_change_user() failed\n");
		exit(EXIT_FAILURE);
	}

	char* bibliotecaImp = find_library(conn);

	while (true) {
		printf("\033[2J\033[H");	// Clean the shell
		printf("*** Telephone number of your library: %s ***\n\n", bibliotecaImp);
		printf("*** What should I do for you? ***\n\n");
		printf("1) Add a client\n");
		printf("2) Start a book loan\n");
		printf("3) Get the ISBN of a book\n");
		printf("4) Show current loans\n");
		printf("5) End a book loan\n");
		printf("6) Quit\n");
		fflush(stdout);

		op = multiChoice("Select an option", options, 6);

		switch (op) {
		case '1':
			add_client(conn);
			break;

		case '2':
			start_loan(conn, bibliotecaImp);
			break;

		case '3':
			get_isbn(conn);
			break;

		case '4':
			show_loans(conn, bibliotecaImp);
			break;

		case '5':
			end_loan(conn);
			break;

		case '6':
			return;

		default:
			fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
			abort();
		}

		getchar();
	}
}