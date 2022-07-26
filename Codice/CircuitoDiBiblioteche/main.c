// Questo file contiene la funzione 'main', in cui inizia e termina l'esecuzione del programma.

#include <stdio.h>
#include <stdlib.h>
#include <mysql.h>
#include <string.h>

#include "defines.h"

typedef enum {
	ADMINISTRATOR = 1,
	LIBRARIAN,
	FAILED_LOGIN
} role_t;

struct configuration conf;
struct param_type paramStruct;
static MYSQL* conn;

static role_t attempt_login(MYSQL* conn, char* username, char* password) {
	MYSQL_STMT* login_procedure;
	MYSQL_BIND param[3];	// Used both for input and output
	int role = 0;

	if (!setup_prepared_stmt(&login_procedure, "call login(?, ?, ?)", conn)) {
		print_stmt_error(login_procedure, "Unable to initialize login statement\n");
		goto err2;
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));

	paramStruct.varchar[0] = username;
	paramStruct.varchar[1] = password;
	paramStruct.integer[0] = &role;

	paramStruct.numVarchar = 2;
	paramStruct.numInt = 1;

	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_param(login_procedure, param) != 0) {
		print_stmt_error(login_procedure, "Could not bind parameters for login\n");
		goto err;
	}

	if (mysql_stmt_execute(login_procedure) != 0) {
		print_stmt_error(login_procedure, "Could not execute login procedure\n");
		goto err;
	}

	memset(param, 0, sizeof(param));
	memset(&paramStruct, 0, sizeof(paramStruct));
	paramStruct.integer[0] = &role;
	paramStruct.numInt = 1;
	
	bind_par(param, &paramStruct);

	if (mysql_stmt_bind_result(login_procedure, param)) {
		print_stmt_error(login_procedure, "Could not retrieve output parameter\n");
		goto err;
	}

	if (mysql_stmt_fetch(login_procedure)) {
		print_stmt_error(login_procedure, "Could not buffer results\n");
		goto err;
	}

	mysql_stmt_close(login_procedure);
	return role;

err:
	mysql_stmt_close(login_procedure);
err2:
	return FAILED_LOGIN;
}

int main() {
	role_t role;

	if (!parse_config((char*)"users/login.json", &conf)) {
		fprintf(stderr, "Unable to load login configuration\n");
		exit(EXIT_FAILURE);
	}

	conn = mysql_init(NULL);
	if (conn == NULL) {
		fprintf(stderr, "mysql_init() failed\n");
		exit(EXIT_FAILURE);
	}

	if (mysql_real_connect(conn, conf.host, conf.db_username, conf.db_password, conf.database, conf.port, NULL, CLIENT_MULTI_STATEMENTS | CLIENT_MULTI_RESULTS) == NULL) {
		fprintf(stderr, "mysql_real_connect() failed\n");
		mysql_close(conn);
		exit(EXIT_FAILURE);
	}

	printf("Username: ");
	fflush(stdout);
	fgets(conf.username, 128, stdin);
	conf.username[strlen(conf.username) - 1] = '\0';
	printf("Password: ");
	fflush(stdout);
	insertPassword(conf.password);

	role = attempt_login(conn, conf.username, conf.password);

	switch (role) {
	case ADMINISTRATOR:
		run_as_administrator(conn);
		break;

	case LIBRARIAN:
		run_as_librarian(conn);
		break;

	case FAILED_LOGIN:
		fprintf(stderr, "Invalid credentials\n");
		exit(EXIT_FAILURE);
		break;

	default:
		fprintf(stderr, "Invalid condition at %s:%d\n", __FILE__, __LINE__);
		abort();
	}

	printf("Bye!\n");
	mysql_close(conn);
	return 0;
}