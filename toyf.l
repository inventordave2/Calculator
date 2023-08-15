%{

#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "toyf.tab.h"

#define NUM_STRING_LENGTH 325 // max length of fp (double) number, including decimal point. Obvs is way less than 325.

extern char* enum_str;

extern 	char *(*function)();
extern 	char *convert(double);

extern double vars[256];
extern char*  evars[256];

extern short int truthyFlag;
extern double _TRUE;
extern double _FALSE;
extern double generateExpValue(char *);
%}

%%

[0-9]+([\.][0-9]+)?	{ yylval.val = strtod(yytext, 0); return NUM; }
([0-9]+([0-9]+)?[eE]([0-9]+([\.][0-9]+)?))	{ yylval.val = generateExpValue(yytext); enum_str = strdup(yytext); return ENUM; }

[a-zA-Z]			{ yylval.name = yytext[0]; return ID; }

"true"|"TRUE"		{ yylval.val = _TRUE; truthyFlag = 1; return TRUE; }
"false"|"FALSE"		{ yylval.val = _FALSE; truthyFlag = 1; return FALSE; }
"print"				{ return PRINT; }
"+"					{ return PLUS; }
"-"					{ return MINUS; }
"*"					{ return _MUL; }
"/"					{ return _DIV; }
"pow"|"POW"			{ return POW; }
"=="				{ return LOGICAL_EQ; }
"="					{ return EQUALS; }

"&&"				{ return BOOLEAN_LOGICAL_AND; }
"&"					{ return BOOLEAN_BITWISE_AND; }

"||"				{ return BOOLEAN_LOGICAL_OR; }
"|"					{ return BOOLEAN_BITWISE_OR; } 

"^^"				{ return BOOLEAN_LOGICAL_EXC_OR; }
"^"					{ return BOOLEAN_BITWISE_EXC_OR; }



"!"					{ return BOOLEAN_LOGICAL_NOT; }
"~"					{ return BOOLEAN_BITWISE_NOT; }



"("					{ return OB; }
")"					{ return CB; }

","					{ return COMMA; }

[\n]				{ return NL; }
[:space:]           { ; }
[\t]				{ ; }
"setoption"			{ return OPTIONSET; }
"unsetoption"		{ return OPTIONUNSET; }
. 					{ ; }

%%

int yywrap(void)	{

	return 1;
}
