
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
  FUNCTION VAR TYPE NEWLINE
  NUMBER 
/* add your own predence level of operators here */ 
%left PLUS MINUS
%left TIMES DIVIDE
%left EQ NEQ GT LT GE LE
%left AND OR
%left ASSIGN
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
		|	exp PLUS exp	
		|	exp MINUS exp	
		|	exp TIMES exp	
		|	exp DIVIDE exp	
			{
				if ( $3 )
					$$ = $1 / $3;
				else
				{
					$$ = -1;
					cout << @3.first_line << "." << @3.first_column << " - "
						 << @3.last_line << "." << @3.last_column
						 << ": division by zero " << endl;
				}
			}
		|	LPAREN exp RPAREN	
		/* exponentiation */
		|	exp POWER exp	
		/* Unary minus */
		|	MINUS exp %prec UMINUS
		|	ID LPAREN expr-list RPAREN
		|	ID LPAREN RPAREN
		|	LPAREN expr-seq RPAREN
		|	LPAREN RPAREN
		|	ID LBRACK field-list RBRACK
		|	ID LBRACK RBRACK
		|	ID LBRACE exp RBRACE OF exp
		|	IF exp THEN exp
		|	IF exp THEN exp ELSE exp
		|	WHILE exp DO exp
		|	FOR ID ASSIGN exp TO exp DO exp
		|	BREAK
		|	LET declaration-list IN expr-seq END
		|	LET declaration-list IN END
		|	error PLUS exp
		|	exp PLUS error
		|	error MINUS exp
		|	exp MINUS error
		|	error TIMES exp
		|	exp TIMES error
		|	error DIVIDE exp
		|	exp DIVIDE error
		|	LPAREN error RPAREN	
		/* exponentiation */
		|	error POWER exp	
		|	exp POWER error
		/* Unary minus */
		|	MINUS error %prec UMINUS
		|	ID LPAREN error RPAREN
		|	LPAREN error RPAREN
		|	ID LBRACK error RBRACK
		|	ID LBRACE error RBRACE OF exp
		|	ID LBRACE exp RBRACE OF error
		|	IF error THEN exp
		|	IF exp THEN error
		|	IF error THEN exp ELSE exp
		|	IF exp THEN error ELSE exp
		|	IF exp THEN exp ELSE error
		|	WHILE error DO exp
		|	WHILE exp DO error
		|	FOR ID ASSIGN error TO exp DO exp
		|	FOR ID ASSIGN exp TO error DO exp
		|	FOR ID ASSIGN exp TO exp DO error
		|	LET error IN expr-seq END
		|	LET declaration-list IN error END
		|	LET error IN END
		|	error NEWLINE
		;

expr-seq:	exp
		|	expr-seq COLON exp
		|	error COLON exp
		|	expr-seq COLON error
		|	error NEWLINE
		;

expr-list:	exp
		 |	expr-list COMMA exp
		 |	error COMMA exp
		 |	expr-list COMMA error
		 |	error NEWLINE
		 ;

field-list:	ID EQ exp
		  |	field-list COMMA ID EQ exp
		  |	error COMMA ID EQ exp
		  |	field-list COMMA ID EQ error
		  |	error NEWLINE
		  ;

lvalue:		ID
	   |	lvalue DOT ID
	   |	lvalue LBRACE exp RBRACE
	   |	lvalue LBRACE error RBRACE
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
	|	LBRACK type-fields RBRACK
	|	LBRACK RBRACK
	|	ARRAY OF ID
	|	error NEWLINE
	;

type-fields:	type-field
			|	type-field COMMA type-field
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

