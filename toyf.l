%{

#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "toyf.tab.h"

#define NUM_STRING_LENGTH 325 // max length of fp (double) number, including decimal point. Obvs is way less than 325.

extern char* enum_str;

extern 	char *(*function)();
extern 	char *convert(double);
double generateExpValue(char *);

extern double vars[256];
extern char*  evars[256];

extern short int truthyFlag;
extern double _TRUE;
extern double _FALSE;

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
"*"					{ return MUL; }
"/"					{ return DIV; }
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

double generateExpValue(char *s)	{

	char *lhs = malloc(NUM_STRING_LENGTH);
	char *rhs = malloc(NUM_STRING_LENGTH);
	
	char e;
	int i, i2;
	
	for(i = 0; i < strlen(s); i++)	{
	
		if(((e = s[i]) == 'e')||((e = s[i]) == 'E'))
			break; // i contains offset of 'e'
	}
	
	for (i2 = 0; i2 < i; i2++)	{
	
		lhs[i2] = s[i2];
	}
	
	lhs[i2] = '\0';
	
	int c = 0;
	for (i2 += 1; i2 < strlen(s); i2++)	{
	
		rhs[c++] = s[i2];
	}
	
	rhs[c] = '\0';
	
	if(strlen(lhs)==1)	{
	
		char ch = lhs[0];
		if ((ch >= 'A') && (ch <= 'z'))	{
		
			if(evars[ch][0] != '\0')
				strcpy(lhs, convert(generateExpValue(evars[ch])) );
			else
				strcpy(lhs, convert(vars[ch]) );
		}
	}
	
	if(strlen(rhs)==1)	{
	
		char ch = rhs[0];
		if ((ch >= 'A') && (ch <= 'z'))	{
		
			if(evars[ch][0] != '\0')
				strcpy(rhs, convert(generateExpValue(evars[ch])) );
			else
				strcpy(rhs, convert(vars[ch]) );
		}
	}
	
	double l = strtod(lhs, 0);
	double r = strtod(rhs, 0);
	
	double result = l * pow(10, r);
	
	return result;
}

int yywrap(void)	{

	return 1;
}
