%{

#include <string.h>
#include <stdlib.h>
#include "toy.tab.h"

%}

%%

[0-9]+				{ yylval.val = atoi(yytext); return NUM; }
[a-zA-Z]			{ yylval.name = yytext[0]; return ID; }

"print"				{ return PRINT; }
"+"					{ return PLUS; }
"-"					{ return MINUS; }
"*"					{ return _MUL; }
"/"					{ return _DIV; }
"^"					{ return POW; }
"="					{ return EQUALS; }
"("					{ return OB; }
")"					{ return CB; }
[\n]				{ return NL; }
[:space:]           { ; }
[\t]				{ ; }

%%

int yywrap(void)	{

	return 1; // if we set this to return 0, when in interactive mode, ctrl-z does not exit program.
}
