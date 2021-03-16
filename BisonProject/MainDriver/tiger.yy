
%debug
%verbose	/*generate file: tiger.output to check grammar*/
%locations

%{
#include <iostream>
#include <string>
#include "ErrorMsg.h"
#include <FlexLexer.h>

int yylex(void);		/* function prototype */
void yyerror(char *s);	//called by the parser whenever an eror occurs

%}

%union {
	int		ival;	//integer value of INT token
	std::string* sval;	//pointer to name of IDENTIFIER or value of STRING	
					//I have to use pointers since C++ does not support 
					//string object as the union member
}

/* TOKENs and their associated data type */
%token <sval> ID STRING
%token <ival> INT

%token 
  COMMA COLON SEMICOLON LPAREN RPAREN LBRACK RBRACK 
  LBRACE RBRACE DOT 
  ARRAY IF THEN ELSE WHILE FOR TO DO LET IN END OF 
  BREAK NIL
  FUNCTION VAR NEWLINE TYPE
  NUMBER 
/* add your own predence level of operators here */ 


%left ASSIGN
%left OR
%left AND
%nonassoc EQ NEQ GT LT GE LE
%left PLUS MINUS
%left TIMES DIVIDE
%left UMINUS
%right POWER
%start program

%%

/* This is a skeleton grammar file, meant to illustrate what kind of
 * declarations are necessary above the %% mark.  Students are expected
 *  to replace the two dummy productions below with an actual grammar. 
 */

program	:	/* empty */
		|	program line	
		;

line	:	NEWLINE
		|	exp NEWLINE	
		|	error NEWLINE
		;

exp		:	STRING	
		|	INT
		|	NIL
		|	lvalue
		|	lvalue ASSIGN exp
		|	exp PLUS exp	
		|	exp MINUS exp	
		|	exp TIMES exp	
		|	exp DIVIDE exp	
		|	exp EQ exp
		|	exp NEQ exp
		|	exp GT exp
		|	exp LT exp
		|	exp GE exp
		|	exp LE exp
		|	exp OR exp
		|	exp AND exp
		/* exponentiation */
		|	exp POWER exp	
		/* Unary minus */
		|	MINUS exp %prec UMINUS
		|	ID LPAREN expr-list RPAREN
		|	ID LPAREN RPAREN
		|	LPAREN expr-seq RPAREN
		|	LPAREN RPAREN
		|	ID LBRACE field-list RBRACE
		|	ID LBRACE RBRACE
		|	ID LBRACK exp RBRACK OF exp
		|	IF exp THEN exp
		|	IF exp THEN exp ELSE exp
		|	WHILE exp DO exp
		|	FOR ID ASSIGN exp TO exp DO exp
		|	BREAK
		|	LET declaration-list IN expr-seq END
		|	LET declaration-list IN END
		/* error code */
		|	error ASSIGN exp
		|	error PLUS exp
		|	error MINUS exp
		|	error TIMES exp
		|	error DIVIDE exp
		|	error EQ exp
		|	error NEQ exp
		|	error GT exp
		|	error LT exp
		|	error GE exp
		|	error LE exp
		|	error OR exp
		|	error AND exp
		|	UMINUS error
		/* exponentiation */
		|	error POWER exp	
		/* Unary minus */
		|	MINUS error %prec UMINUS
		|	IF error THEN exp
		|	IF exp THEN error
		|	IF error THEN error
		|	IF error THEN exp ELSE exp
		|	IF exp THEN error ELSE exp
		|	IF exp THEN exp ELSE error
		|	WHILE error DO exp
		|	FOR ID ASSIGN error TO exp DO exp
		|	FOR ID ASSIGN exp TO error DO exp
		|	FOR ID ASSIGN exp TO exp DO error
		|	LET error IN expr-seq END
		|	LET declaration-list IN error END
		|	LET error IN error END
		|	error NEWLINE
		;


expr-seq:	exp
		|	expr-seq SEMICOLON exp
		|	error SEMICOLON exp
		|	error NEWLINE
		;

expr-list:	exp
		 |	expr-list COMMA exp
		 |	error COMMA exp
		 |	error NEWLINE
		 ;

field-list:	ID EQ exp
		  |	field-list COMMA ID EQ exp
		  |	error COMMA ID EQ exp
		  |	error NEWLINE
		  ;

lvalue:		ID
	   |	lvalue DOT ID
	   |	lvalue LBRACK exp RBRACK
	   |	error DOT ID
	   |	lvalue LBRACK error RBRACK
	   |	error NEWLINE
	   ;

declaration-list:	declaration
				|	declaration-list declaration
				|	error NEWLINE
				;

declaration:	type-declaration
			|	variable-declaration
			|	function-declaration
			|	error NEWLINE
			;

type-declaration:	type ID EQ type
				|	error NEWLINE
				;

type:	ID
	|	INT
	|	TYPE
	|	STRING
	|	LBRACE type-fields RBRACE
	|	LBRACE RBRACE
	|	ARRAY OF ID
	|	error NEWLINE
	;

type-fields:	type-field
			|	type-fields COMMA type-field
			|	error COMMA type-field
			|	error NEWLINE
			;
type-field:		ID COLON ID
		   ;

variable-declaration:	VAR ID ASSIGN exp
					|	VAR ID COLON ID ASSIGN exp
					|	error NEWLINE
					;

function-declaration:	FUNCTION ID LPAREN type-fields RPAREN EQ exp
					|	FUNCTION ID LPAREN RPAREN EQ exp
					|	FUNCTION ID LPAREN type-fields RPAREN COLON ID EQ exp
					|	FUNCTION ID LPAREN RPAREN COLON ID EQ exp
					|	FUNCTION ID LPAREN error RPAREN EQ exp
					|	FUNCTION ID LPAREN error RPAREN COLON ID EQ exp
					|	error NEWLINE
					;


 

%%
extern yyFlexLexer	lexer;
int yylex(void)
{
	return lexer.yylex();
}

void yyerror(char *s)
{
	extern int	linenum;			//line no of current matched token
	extern int	colnum;
	extern void error(int, int, std::string);

	error(linenum, colnum, s);
}

