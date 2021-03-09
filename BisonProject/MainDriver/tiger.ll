%option noyywrap
%option never-interactive
%option nounistd
%option c++

%{
#include <iostream>
#include <string>
#include <sstream>
#include "tiger.tab.hh"
#include "ErrorMsg.h"
/*
Patrick Wolff
Project 2
lexical analyzer
*/
/*
CHARACTERS
all these are from token.h files
they are simply looking for characters and return characters are stripping them away
*/
/* 
COMMENTS
this section is for the comment section. It checks for nested comments along with ending comments and strips
everything away that isn't a closing brace
*/
/*
STRING LITERAL
This is for recognizing string literals.
it starts by recognizing a quote.
it then checks for illegal escape characters as well as legal ones.
for the legal espace characters it adds them to the string. for the illegal ones. it returns the error function
which takes a few parameters such as colum num and line num.
*/
using std::string;
using std::stringstream;

ErrorMsg			errormsg;	//error handler

int		comment_depth = 0;	// depth of the nested comment
string	value = "";			// the value of current string

int			beginLine=-1;	//beginning line no of a string or comment
int			beginCol=-1;	//beginning column no of a string or comment

int		linenum = 1;		//beginning line no of the current matched token
int		colnum = 1;			//beginning column no of the current matched token
int		tokenCol = 1;		//column no after the current matched token

//the following defines actions that will be taken automatically after 
//each token match. It is used to update colnum and tokenCol automatically.
#define YY_USER_ACTION {colnum = tokenCol; tokenCol=colnum+yyleng;}

int string2int(string);			//convert a string to integer value
void newline(void);				//trace the line #
void error(int, int, string);	//output the error message referring to the current token
%}

ALPHA		[A-Za-z]
DIGIT		[0-9]
INT			[0-9]+
IDENTIFIER	{ALPHA}(({ALPHA}|{DIGIT}|"_")*)
%x	COMMENT
%x  STRNG

%%
" "				{}
\t				{}
\b				{}
\n				{newline(); }
","             { return COMMA; }
":"             { return COLON; }
";"             { return SEMICOLON; }
"("             { return LPAREN; }
")"             { return RPAREN; }
"["             { return LBRACK; }
"]"             { return RBRACK; }
"{"             { return LBRACE; }
"}"             { return RBRACE; }
"."             { return DOT; }
"+"             { return PLUS; }
"-"             { return MINUS; }
"*"             { return TIMES; }
"/"             { return DIVIDE; }
"="             { return EQ; }
"!="            { return NEQ;}
"<"             { return LT; }
"<="            { return LE; }
">"             { return GT; }
">="            { return GE; }
"&"             { return AND; }
"|"             { return OR; }
":="            { return ASSIGN; }
"array"         { return ARRAY; }
while           { return WHILE; }
for             { return FOR; }
to              { return TO; }
break           { return BREAK; }
let             { return LET; }
in              { return IN; }
end             { return END; }
function        { return FUNCTION; }
var             { return VAR; }
type            { return TYPE; }
array           { return ARRAY; }
if              { return IF; }
"<>"            {return NEQ;}
then            { return THEN;}
else            { return ELSE; }
do              { return DO; }
of              { return OF; }
nil             { return NIL; }
{IDENTIFIER} 	{ value = YYText(); yylval.sval = new string(value); return ID; }
{INT}		 	{ yylval.ival = string2int(YYText()); return INT; }

"/*"        {        
                    beginLine = linenum;
                    beginCol = colnum;
                    comment_depth++;
                    BEGIN(COMMENT);
                }
<COMMENT>"/*"    {    
                    comment_depth++;
                }
<COMMENT>[^*/\n]*    {}
<COMMENT>"/"+[^/*\n]* {}
<COMMENT>""+[^*/\n]* {}
<COMMENT>\n        {    newline(); }
<COMMENT>"*"+"/"    {
                        comment_depth--;
                        if(comment_depth == 0)
                        {
                            BEGIN(INITIAL);
                            
                        }
                    }
<COMMENT><<EOF>>    {
                        error(beginLine, beginCol, string("Unclosed comments"));
                        yyterminate();
                    }

\"              {
                    value="";
                    beginLine = linenum;
                    beginCol = colnum;
                    BEGIN(STRNG);
                }
<STRNG>\n       {
                    newline(); 
                    error(beginLine, beginCol, string("unclosed String"));
                    yylval.sval = new string(value);
                    BEGIN(INITIAL);
                    return STRING;  

                }
<STRNG>\\n       {
                    {value=value+'\n';}
                }
<STRNG>\\\\     {value=value+'\\';}
<STRNG>\\t      {value=value+'\t';}
<STRNG>\\\"     {value=value+'\"';}
<STRNG>\\[^nt\\\"]    {    
                            error(linenum, colnum, string(YYText()) + " Illegal token");
                    }
<STRNG>\"           {
                        yylval.sval = new string(value);
                        BEGIN(INITIAL);
                        return STRING;  
                    }
<STRNG><<EOF>> {
                    error(beginLine, beginCol, string("unclosed String"));
                    yyterminate();
               }
<STRNG>.        {
                    value.append(YYText());
                }


<<EOF>>			{	yyterminate(); }
.				{	error(linenum, colnum, string(YYText()) + " illegal token");}





%%

int string2int( string val )
{
	stringstream	ss(val);
	int				retval;

	ss >> retval;

	return retval;
}

void newline()
{
	linenum ++;
	colnum = 1;
	tokenCol = 1;
}

void error(int line, int col, string msg)
{
	errormsg.error(line, col, msg);
}
