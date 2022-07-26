#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "defines.h"

static void add_sick_leave(MYSQL* conn);

static void add_book(MYSQL* conn) {
	MYSQL_STMT* aggiungi_copia_procedure;
	MYSQL_BIND param[7];
	struct param_type paramStruct;

	char isbn[16];
	char titolo[48];
	char autore[48];
	char biblioteca[24];
	char scaffaleStr[16];
	char ripianoStr[16];

	// Get the required information
	printf("\nISBN: ");
	fflush(stdout);
	fgets(isbn, 16, stdin);
	isbn[strlen(isbn) - 1] = '\0';
	printf("Title: ");
	fflush(stdout);
	fgets(titolo, 48, stdin);
	titolo[strlen(titolo) - 1] = '\0';
	printf("Author: ");
	fflush(stdout);
	fgets(autore, 48, stdin);
	autore[strlen(autore) - 1] = '\0';
	printf("Library phone number: ");
	fflush(stdout);
	fgets(biblioteca, 24, stdin);
	biblioteca[strlen(biblioteca) - 1] = '\0';
	printf("Shelving unit number: ");
	fflush(stdout);
	fgets(scaffaleStr, 16, stdin);
	printf("Shelf number: ");
	fflush(stdout);
	fgets(ripianoStr, 16, stdin);

	int scaffale = atoi(scaffaleStr);
	int ripiano = atoi(ripianoStr);
	int id = 0;

	if (!setup_prepared_stmt(&aggiungi_copia_procedure, "call aggiungi_copia(?, ?, ?, ?, ?, ?, ?)", conn)) {
		finish_with_stmt_error(conn, aggiungi_copia_procedure, "Unable to initialize book insertion statement\n", false);
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));

	paramStruct.varchar[0] = isbn;
	paramStruct.varchar[1] = titolo;
	paramStruct.varchar[2] = autore;
	paramStruct.varchar[3] = biblioteca;
	paramStruct.integer[0] = &scaffale;
	paramStruct.integer[1] = &ripiano;
	paramStruct.integer[2] = &id;

	paramStruct.numVarchar = 4;
	paramStruct.numInt = 3;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_param(aggiungi_copia_procedure, param) != 0) {
		finish_with_stmt_error(conn, aggiungi_copia_procedure, "Could not bind parameters for book insertion\n", true);
	}

	if (mysql_stmt_execute(aggiungi_copia_procedure) != 0) {
		print_stmt_error(aggiungi_copia_procedure, "An error occurred while adding the book\n");
		goto out;
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));
	paramStruct.integer[0] = &id;
	paramStruct.numInt = 1;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_result(aggiungi_copia_procedure, param)) {
		finish_with_stmt_error(conn, aggiungi_copia_procedure, "Could not retrieve output parameter\n", true);
	}

	if (mysql_stmt_fetch(aggiungi_copia_procedure)) {
		finish_with_stmt_error(conn, aggiungi_copia_procedure, "Could not buffer results\n", true);
	}

	printf("Book correctly added with ID %d\n", id);
	fflush(stdout);

out:
	mysql_stmt_close(aggiungi_copia_procedure);
}

static void add_work_shift(MYSQL* conn) {
	MYSQL_STMT* aggiungi_turno_procedure;
	MYSQL_BIND param[4];
	struct param_type paramStruct;

	char bibliotecario[24];
	char giornoStr[16];
	char meseStr[16];
	char annoStr[16];
	char inizioOreStr[16];
	char inizioMinStr[16];
	char fineOreStr[16];
	char fineMinStr[16];

	printf("\nLibrarian tax code: ");
	fflush(stdout);
	fgets(bibliotecario, 24, stdin);
	bibliotecario[strlen(bibliotecario) - 1] = '\0';
	printf("Day [1-31]: ");
	fflush(stdout);
	fgets(giornoStr, 16, stdin);
	printf("Month [1-12]: ");
	fflush(stdout);
	fgets(meseStr, 16, stdin);
	printf("Year: ");
	fflush(stdout);
	fgets(annoStr, 16, stdin);
	printf("Hour of the start of work shift [0-23]: ");
	fflush(stdout);
	fgets(inizioOreStr, 16, stdin);
	printf("Minute of the start of work shift [0-59]: ");
	fflush(stdout);
	fgets(inizioMinStr, 16, stdin);
	printf("Hour of the end of work shift [0-23]: ");
	fflush(stdout);
	fgets(fineOreStr, 16, stdin);
	printf("Minute of the end of work shift [0-59]: ");
	fflush(stdout);
	fgets(fineMinStr, 16, stdin);

	int giorno = atoi(giornoStr);
	int mese = atoi(meseStr);
	int anno = atoi(annoStr);
	int inizioOre = atoi(inizioOreStr);
	int inizioMin = atoi(inizioMinStr);
	int fineOre = atoi(fineOreStr);
	int fineMin = atoi(fineMinStr);

	struct MYSQL_TIME date;
	struct MYSQL_TIME time1;
	struct MYSQL_TIME time2;
	memset(&date, 0, sizeof(date));
	memset(&time1, 0, sizeof(time1));
	memset(&time2, 0, sizeof(time2));

	date.day = giorno;
	date.month = mese;
	date.year = anno;
	time1.hour = inizioOre;
	time1.minute = inizioMin;
	time2.hour = fineOre;
	time2.minute = fineMin;

	if (!setup_prepared_stmt(&aggiungi_turno_procedure, "call aggiungi_turno(?, ?, ?, ?)", conn)) {
		finish_with_stmt_error(conn, aggiungi_turno_procedure, "Unable to initialize work shift insertion statement\n", false);
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));

	paramStruct.varchar[0] = bibliotecario;
	paramStruct.date[0] = &date;
	paramStruct.time[0] = &time1;
	paramStruct.time[1] = &time2;

	paramStruct.numVarchar = 1;
	paramStruct.numDate = 1;
	paramStruct.numTime = 2;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_param(aggiungi_turno_procedure, param) != 0) {
		finish_with_stmt_error(conn, aggiungi_turno_procedure, "Could not bind parameters for work shift insertion\n", true);
	}

	if (mysql_stmt_execute(aggiungi_turno_procedure) != 0) {
		print_stmt_error(aggiungi_turno_procedure, "An error occurred while adding the work shift\n");
	}
	else {
		printf("Work shift correctly added\n");
		fflush(stdout);
	}

	mysql_stmt_close(aggiungi_turno_procedure);
}

static void add_librarian(MYSQL* conn, char username[]) {
	MYSQL_STMT* aggiungi_bibliotecario_procedure;
	MYSQL_BIND param[8];
	struct param_type paramStruct;
	
	char cf[24];
	char nome[48];
	char cognome[48];
	char giornoNascitaStr[16];
	char meseNascitaStr[16];
	char annoNascitaStr[16];
	char luogoNascita[48];
	char titoloStudio[48];
	char biblioteca[24];

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
	printf("Day of birth [1-31]: ");
	fflush(stdout);
	fgets(giornoNascitaStr, 16, stdin);
	printf("Month of birth [1-12]: ");
	fflush(stdout);
	fgets(meseNascitaStr, 16, stdin);
	printf("Year of birth: ");
	fflush(stdout);
	fgets(annoNascitaStr, 16, stdin);
	printf("City of birth: ");
	fflush(stdout);
	fgets(luogoNascita, 48, stdin);
	luogoNascita[strlen(luogoNascita) - 1] = '\0';
	printf("Educational qualification: ");
	fflush(stdout);
	fgets(titoloStudio, 48, stdin);
	titoloStudio[strlen(titoloStudio) - 1] = '\0';
	printf("Library phone number: ");
	fflush(stdout);
	fgets(biblioteca, 24, stdin);
	biblioteca[strlen(biblioteca) - 1] = '\0';

	int giornoNascita = atoi(giornoNascitaStr);
	int meseNascita = atoi(meseNascitaStr);
	int annoNascita = atoi(annoNascitaStr);

	struct MYSQL_TIME date;
	memset(&date, 0, sizeof(date));

	date.day = giornoNascita;
	date.month = meseNascita;
	date.year = annoNascita;

	if (!setup_prepared_stmt(&aggiungi_bibliotecario_procedure, "call aggiungi_bibliotecario(?, ?, ?, ?, ?, ?, ?, ?)", conn)) {
		finish_with_stmt_error(conn, aggiungi_bibliotecario_procedure, "Unable to initialize librarian insertion statement\n", false);
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));

	paramStruct.varchar[0] = cf;
	paramStruct.varchar[1] = nome;
	paramStruct.varchar[2] = cognome;
	paramStruct.varchar[3] = luogoNascita;
	paramStruct.varchar[4] = titoloStudio;
	paramStruct.varchar[5] = biblioteca;
	paramStruct.varchar[6] = username;
	paramStruct.date[0] = &date;

	paramStruct.numVarchar = 7;
	paramStruct.numDate = 1;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_param(aggiungi_bibliotecario_procedure, param) != 0) {
		print_stmt_error(aggiungi_bibliotecario_procedure, "Could not bind parameters for librarian insertion\n");
		goto again;
	}

	if (mysql_stmt_execute(aggiungi_bibliotecario_procedure) != 0) {
		print_stmt_error(aggiungi_bibliotecario_procedure, "An error occurred while adding the librarian\n");
		goto again;
	}
	else {
		goto end;
	}

again:
	mysql_stmt_close(aggiungi_bibliotecario_procedure);
	printf("\nLet's try again!\n");
	fflush(stdout);
	add_librarian(conn, username);
	return;

end:
	printf("Librarian correctly added\n");
	fflush(stdout);
	mysql_stmt_close(aggiungi_bibliotecario_procedure);
}

static void create_user(MYSQL* conn) {
	MYSQL_STMT* crea_user_procedure;
	MYSQL_BIND param[3];
	struct param_type paramStruct;
	char options[2] = { '1', '2' };
	char r;

	char username[48];
	char password[48];
	char ruolo[48];

	printf("\nUsername: ");
	fflush(stdout);
	fgets(username, 48, stdin);
	username[strlen(username) - 1] = '\0';
	printf("Password: ");
	fflush(stdout);
	insertPassword(password);
	printf("Assign a possible role:\n");
	printf("\t1) Amministratore\n");
	printf("\t2) Bibliotecario\n");
	fflush(stdout);
	r = multiChoice("Select role", options, 2);

	//Convert role into enum value
	switch (r) {
	case '1':
		strcpy(ruolo, "amministratore");
		break;

	case '2':
		strcpy(ruolo, "bibliotecario");
		break;

	default:
		fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
		abort();
	}

	if (!setup_prepared_stmt(&crea_user_procedure, "call crea_user(?, ?, ?)", conn)) {
		finish_with_stmt_error(conn, crea_user_procedure, "Unable to initialize user insertion statement\n", false);
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));

	paramStruct.varchar[0] = username;
	paramStruct.varchar[1] = password;
	paramStruct.varchar[2] = ruolo;

	paramStruct.numVarchar = 3;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_param(crea_user_procedure, param) != 0) {
		finish_with_stmt_error(conn, crea_user_procedure, "Could not bind parameters for user insertion\n", true);
	}

	if (mysql_stmt_execute(crea_user_procedure) != 0) {
		print_stmt_error(crea_user_procedure, "An error occurred while adding the user\n");
		mysql_stmt_close(crea_user_procedure);
		printf("Let's try again!\n");
		fflush(stdout);
		create_user(conn);
	}
	else {
		printf("User correctly added\n");
		fflush(stdout);
		mysql_stmt_close(crea_user_procedure);

		if (r == '2') {
			add_librarian(conn, username);
		}
	}
}

static void write_off_books(MYSQL* conn) {
	MYSQL_STMT* dismetti_copie_procedure;
	
	if (!setup_prepared_stmt(&dismetti_copie_procedure, "call dismetti_copie()", conn)) {
		finish_with_stmt_error(conn, dismetti_copie_procedure, "Unable to initialize books dissolution statement\n", false);
	}

	if (mysql_stmt_execute(dismetti_copie_procedure) != 0) {
		print_stmt_error(dismetti_copie_procedure, "An error occurred while writing off the books\n");
	}
	else {
		printf("Books correctly wrote off\n");
		fflush(stdout);
	}

	mysql_stmt_close(dismetti_copie_procedure);
}

static void report_uncovered_libraries(MYSQL* conn) {
	MYSQL_STMT* report_biblioteche_scoperte_procedure;
	MYSQL_BIND param[2];
	struct param_type paramStruct;

	char strGiorno1[16];
	char strMese1[16];
	char strAnno1[16];
	char strGiorno2[16];
	char strMese2[16];
	char strAnno2[16];

	printf("\nFirst day [1-31]: ");
	fflush(stdout);
	fgets(strGiorno1, 16, stdin);
	printf("First month [1-12]: ");
	fflush(stdout);
	fgets(strMese1, 16, stdin);
	printf("First year: ");
	fflush(stdout);
	fgets(strAnno1, 16, stdin);
	printf("LastDay [1-31]: ");
	fflush(stdout);
	fgets(strGiorno2, 16, stdin);
	printf("LastMonth [1-12]: ");
	fflush(stdout);
	fgets(strMese2, 16, stdin);
	printf("LastYear: ");
	fflush(stdout);
	fgets(strAnno2, 16, stdin);

	int giorno1 = atoi(strGiorno1);
	int mese1 = atoi(strMese1);
	int anno1 = atoi(strAnno1);
	int giorno2 = atoi(strGiorno2);
	int mese2 = atoi(strMese2);
	int anno2 = atoi(strAnno2);

	struct MYSQL_TIME date1;
	struct MYSQL_TIME date2;
	memset(&date1, 0, sizeof(date1));
	memset(&date2, 0, sizeof(date2));

	date1.day = giorno1;
	date1.month = mese1;
	date1.year = anno1;
	date2.day = giorno2;
	date2.month = mese2;
	date2.year = anno2;

	if (!setup_prepared_stmt(&report_biblioteche_scoperte_procedure, "call report_biblioteche_scoperte(?, ?)", conn)) {
		finish_with_stmt_error(conn, report_biblioteche_scoperte_procedure, "Unable to initialize uncovered libraries report statement\n", false);
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));
	paramStruct.date[0] = &date1;
	paramStruct.date[1] = &date2;
	paramStruct.numDate = 2;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_param(report_biblioteche_scoperte_procedure, param) != 0) {
		finish_with_stmt_error(conn, report_biblioteche_scoperte_procedure, "Could not bind parameters for uncovered libraries report\n", true);
	}

	if (mysql_stmt_execute(report_biblioteche_scoperte_procedure) != 0) {
		print_stmt_error(report_biblioteche_scoperte_procedure, "An error occurred while reporting uncovered libraries\n");
		goto out;
	}

	dump_result_set(conn, report_biblioteche_scoperte_procedure, "");
	if (mysql_stmt_next_result(report_biblioteche_scoperte_procedure) > 0) {
		finish_with_stmt_error(conn, report_biblioteche_scoperte_procedure, "Unexpected contidion\n", true);
	}

out:
	mysql_stmt_close(report_biblioteche_scoperte_procedure);
}

static void add_sick_leave_continue(MYSQL* conn, char malato[], struct MYSQL_TIME* date) {
	MYSQL_STMT* aggiungi_malattia_procedure;
	MYSQL_BIND param[4];
	struct param_type paramStruct;

	char sostituto[24];
	char motivo[48];

	printf("\nSubstitute librarian tax code: ");
	fflush(stdout);
	fgets(sostituto, 24, stdin);
	sostituto[strlen(sostituto) - 1] = '\0';
	printf("Sick leave reason: ");
	fflush(stdout);
	fgets(motivo, 48, stdin);
	motivo[strlen(motivo) - 1] = '\0';

	if (!setup_prepared_stmt(&aggiungi_malattia_procedure, "call aggiungi_malattia(?, ?, ?, ?)", conn)) {
		finish_with_stmt_error(conn, aggiungi_malattia_procedure, "Unable to initialize sick leave insertion statement\n", false);
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));

	paramStruct.varchar[0] = malato;
	paramStruct.varchar[1] = motivo;
	paramStruct.varchar[2] = sostituto;
	paramStruct.date[0] = date;

	paramStruct.numVarchar = 3;
	paramStruct.numDate = 1;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_param(aggiungi_malattia_procedure, param) != 0) {
		print_stmt_error(aggiungi_malattia_procedure, "Could not bind parameters for sick leave insertion\n");
		goto again;
	}

	if (mysql_stmt_execute(aggiungi_malattia_procedure) != 0) {
		print_stmt_error(aggiungi_malattia_procedure, "An error occurred while adding the sick leave\n");
		goto again;
	}
	else {
		goto end;
	}

again:
	mysql_stmt_close(aggiungi_malattia_procedure);
	printf("\nLet's try again!\n");
	fflush(stdout);
	add_sick_leave(conn);
	return;

end:
	printf("Sick leave correctly added\n");
	fflush(stdout);
	mysql_stmt_close(aggiungi_malattia_procedure);
}

static void add_sick_leave(MYSQL* conn) {
	MYSQL_STMT* trova_sostituti_procedure;
	MYSQL_BIND param[2];
	struct param_type paramStruct;

	char malato[24];
	char giornoStr[16];
	char meseStr[16];
	char annoStr[16];

	printf("\nSick librarian tax code: ");
	fflush(stdout);
	fgets(malato, 24, stdin);
	malato[strlen(malato) - 1] = '\0';
	printf("Sick leave day [1-31]: ");
	fflush(stdout);
	fgets(giornoStr, 16, stdin);
	printf("Sick leave month [1-12]: ");
	fflush(stdout);
	fgets(meseStr, 16, stdin);
	printf("Sick leave year: ");
	fflush(stdout);
	fgets(annoStr, 16, stdin);

	int giorno = atoi(giornoStr);
	int mese = atoi(meseStr);
	int anno = atoi(annoStr);

	struct MYSQL_TIME date;
	memset(&date, 0, sizeof(date));

	date.day = giorno;
	date.month = mese;
	date.year = anno;

	if (!setup_prepared_stmt(&trova_sostituti_procedure, "call trova_sostituti(?, ?)", conn)) {
		finish_with_stmt_error(conn, trova_sostituti_procedure, "Unable to initialize substitute librarians search statement\n", false);
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));

	paramStruct.varchar[0] = malato;
	paramStruct.date[0] = &date;

	paramStruct.numVarchar = 1;
	paramStruct.numDate = 1;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_param(trova_sostituti_procedure, param) != 0) {
		finish_with_stmt_error(conn, trova_sostituti_procedure, "Could not bind parameters for substitute librarians search\n", true);
	}

	if (mysql_stmt_execute(trova_sostituti_procedure) != 0) {
		finish_with_stmt_error(conn, trova_sostituti_procedure, "An error occurred while looking for substitute librarians\n", true);
	}

	dump_result_set(conn, trova_sostituti_procedure, "");
	if (mysql_stmt_next_result(trova_sostituti_procedure) > 0) {
		finish_with_stmt_error(conn, trova_sostituti_procedure, "Unexpected contidion\n", true);
	}

	mysql_stmt_close(trova_sostituti_procedure);
	add_sick_leave_continue(conn, malato, &date);
}

void run_as_administrator(MYSQL* conn) {
	char options[7] = { '1', '2', '3', '4', '5', '6', '7'};
	char op;

	printf("Switching to administrator role...\n");
	fflush(stdout);

	if (!parse_config("users/amministratore.json", &conf)) {
		fprintf(stderr, "Unable to load administrator configuration\n");
		exit(EXIT_FAILURE);
	}

	if (mysql_change_user(conn, conf.db_username, conf.db_password, conf.database)) {
		fprintf(stderr, "mysql_change_user() failed\n");
		exit(EXIT_FAILURE);
	}

	while (true) {
		printf("\033[2J\033[H");	// Clean the shell
		printf("*** What should I do for you? ***\n\n");
		printf("1) Add a book into a library\n");
		printf("2) Manage librarians' work shifts\n");
		printf("3) Create a user\n");
		printf("4) Write off some books\n");
		printf("5) Show the uncovered libraries\n");
		printf("6) Set a librarian on sick leave\n");
		printf("7) Quit\n");
		fflush(stdout);

		op = multiChoice("Select an option", options, 7);

		switch (op) {
		case '1':
			add_book(conn);
			break;

		case '2':
			add_work_shift(conn);
			break;

		case '3':
			create_user(conn);
			break;

		case '4':
			write_off_books(conn);
			break;

		case '5':
			report_uncovered_libraries(conn);
			break;

		case '6':
			add_sick_leave(conn);
			break;

		case '7':
			return;

		default:
			fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
			abort();
		}

		getchar();
	}
}