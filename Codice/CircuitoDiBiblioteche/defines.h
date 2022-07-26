#pragma once

#include <stdbool.h>
#include <mysql.h>

struct configuration {
	char* host;
	char* db_username;
	char* db_password;
	unsigned int port;
	char* database;

	char username[128];
	char password[128];
};

struct param_type {
	char* varchar[7];
	MYSQL_TIME* date[2];
	MYSQL_TIME* time[2];
	int* integer[3];
	float* f;
	short int* b;
	int numVarchar;
	int numDate;
	int numTime;
	int numInt;
	int numFloat;
	int numBool;
};

extern struct configuration conf;
extern struct param_type paramStruct;

extern int parse_config(char* path, struct configuration* conf);
extern bool yesOrNo(char* domanda, char yes, char no, bool predef, bool insensitive);
extern char multiChoice(char* domanda, char choices[], int num);
extern void insertPassword(char password[]);
extern void print_error(MYSQL* conn, char* message);
extern void print_stmt_error(MYSQL_STMT* stmt, char* message);
extern void finish_with_error(MYSQL* conn, char* message);
extern void finish_with_stmt_error(MYSQL* conn, MYSQL_STMT* stmt, char* message, bool close_stmt);
extern bool setup_prepared_stmt(MYSQL_STMT** stmt, char* statement, MYSQL* conn);
extern void dump_result_set(MYSQL* conn, MYSQL_STMT* stmt, char* title);
extern void bind_par(MYSQL_BIND param[], struct param_type* paramStruct);
extern char* fixString(char string[]);
extern void run_as_librarian(MYSQL* conn);
extern void run_as_administrator(MYSQL* conn);