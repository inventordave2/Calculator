%{
    #include <stdio.h>
	#include <math.h>
	
    int yylex();
    int yyerror(const char*);
	
	void printVars();
	
	int vars[256] = { 0 };
%}

%start s

%union
{
    char    name;
    int		val;
}

%token NUM ID OTHER PLUS MINUS MUL DIV EQUALS NL SP TAB POW OB CB PRINT

%right EQUALS
%left  PLUS MINUS
%left  MUL DIV
%left  POW

%type<val> exp NUM
%type<name> ID OTHER

%%

line: NL | s NL | NL s

s: exp | line | line exp

exp : PRINT			{ printVars(); }
	| NUM     {$$ = $1; }
    | ID        {$$ = vars[(unsigned int)$1]; }
	| exp MUL exp  {$$ = $1 * $3; printf("\t\tResult of %d * %d is: %d\n", $1, $3, $$); }
    | exp DIV exp  {$$ = $1 / $3; printf("\t\tResult of %d / %d is: %d\n", $1, $3, $$); }
    | exp PLUS exp  {$$ = $1 + $3; printf("\t\tResult of %d + %d is: %d\n", $1, $3, $$); }
    | exp MINUS exp  {$$ = $1 - $3; printf("\t\tResult of %d - %d is: %d\n", $1, $3, $$); }
    | ID EQUALS exp  {$$ = vars[toNumber($1)] = $3; printf("\t\t\tvars[%c] = %d.\n", $1, $$); } 
	| OB exp CB      {$$ = $2; }
	| exp POW exp	 {$$ = pow($1, $3); printf("\t\tResult of %d ^ %d is: %d\n", $1, $3, $$); }
;

%%

void printVars()	{

	for(int i=0;i<256;i++)
		if(vars[i]!=0)
			printf("vars[%c] = %d\n", (char) i, vars[i]);
}

int main()
{
	//yydebug = 1;
    yyparse();
    return 0;
}

int yyerror(const char *s)
{
	printf("Error: %s\n", s);
	return 1;
}
