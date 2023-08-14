%{
    #include <stdio.h>
	#include <stdlib.h>
	#include <math.h>
	#include <string.h>
	#include <float.h>
	
	#include "toyf.tab.h"
	
    int yylex();
    int yyerror(const char*);
	
	void printVars();
	char *convert(double x);
	char *trim(double x);
	char *(*function)(); 
	
	short int truthy(double);
	
	double _FALSE;
	double _TRUE;
	double _Null;
	short int truthyFlag;
	
	double vars[256] = { -10000 };
	char*  evars[256] = { '\0' };
	
	short int optionsFlag = 0;
	
	char* enum_str;
	extern double generateExpValue(char *);
	
	#define NUM_STRING_LENGTH 325 // max length of fp (double) number, including decimal point. Obvs is way less than 100.

%}

%start s

%union
{
    char    		name;
    double		    val;
	int				lo_;
}

%token NUM ENUM ID OTHER PLUS MINUS MUL DIV EQUALS NL SP TAB POW OB CB COMMA PRINT OPTIONSET OPTIONUNSET TRUE FALSE

%token LOGICAL_EQ BOOLEAN_LOGICAL_AND BOOLEAN_BITWISE_AND BOOLEAN_LOGICAL_OR BOOLEAN_BITWISE_OR BOOLEAN_LOGICAL_NOT BOOLEAN_BITWISE_NOT BOOLEAN_LOGICAL_EXC_OR BOOLEAN_BITWISE_EXC_OR 



%right EQUALS
%right LOGICAL_EQ BOOLEAN_LOGICAL_AND BOOLEAN_BITWISE_AND BOOLEAN_LOGICAL_OR BOOLEAN_BITWISE_OR BOOLEAN_LOGICAL_NOT BOOLEAN_BITWISE_NOT BOOLEAN_LOGICAL_EXC_OR BOOLEAN_BITWISE_EXC_OR

%left  PLUS MINUS
%left  MUL DIV
%left  POW

%type<val> exp power_f NUM options ENUM TRUE FALSE
%type<lo_> lo LOGICAL_EQ BOOLEAN_LOGICAL_AND BOOLEAN_BITWISE_AND BOOLEAN_LOGICAL_OR BOOLEAN_BITWISE_OR BOOLEAN_LOGICAL_NOT BOOLEAN_BITWISE_NOT BOOLEAN_LOGICAL_EXC_OR BOOLEAN_BITWISE_EXC_OR
%type<name> ID OTHER

%%

line: NL | s NL | NL s | options NL | NL options

s: exp | options | line | line exp | line options

exp : PRINT		{ printVars(); printf("\n\nOption to trim numbers set? %s.\n", optionsFlag == 1 ? "Yes" : "No"); }  
    | ID        {

					if(strcmp(evars[(unsigned int)$1],""))	{
					
						//printf("HERE\n");
						$$ = generateExpValue(evars[(unsigned int)$1]);
						printf("\t\tevars[%c] = %s, %s\n", $1, evars[(unsigned int)$1], function($$) );
					}
					else	{
					
						//printf("HERE 2\n");
						$$ = vars[(unsigned int)$1];
						printf("\t\tvars[%c] = %s\n", $1, function($$));
					}
					
				}
	| MINUS NUM 	 { $$ = -$2; printf("\t\t%s\n", function($$)); }
	| PLUS NUM		 { $$ = $2; printf("\t\t%s\n", function($$)); }
	|  NUM     {$$ = $1; /* printf("\t\t%s\n", function($$)); */ }
	| ENUM		{ $$ = $1; printf("\t\t%s : %s\n", enum_str, function($$)); }

	| TRUE		{ $$ = $1; printf("\t\ttrue(1)\n"); }
	| FALSE		{ $$ = $1; printf("\t\tfalse(0)\n"); }
	
	| power_f	{
					$$ = $1;
				}


	| LOGICAL_EQ	{ printf("\t\t'=='\n"); }
	| LOGICAL_EQ exp { printf("\t\t'==' : '%s'\n", function($$ = $2)); }

	| exp BOOLEAN_LOGICAL_AND exp	{
										if ( (truthy($1) && truthy($3)) )
										{
											$$ = _TRUE;
											//printf("%s\n", "true");
										}
										else
										{
											$$ = _FALSE; 
											//printf("%s\n", "false");
										}
									}
	
	| exp BOOLEAN_BITWISE_AND exp 	{
										//$$ = (double)( (int)$1 & (int)$3 );

										if(!truthy($1))
											$1 = 0.0;

										if($1==_TRUE)
											$1 = 1.0;

										if(!truthy($3))
											$3 = 0.0;

										if($3==_TRUE)
											$3 = 1.0;


										$$ = (double)((int)$1 & (int)$3);
										//printf("BW_AND := %s\n", function($$));

										/*
										if(truthy($1) && truthy($3))
											printf("true");
										else
											printf("false");
											
										printf("\n");
										*/
									}

	| exp BOOLEAN_LOGICAL_OR exp	{
										if ( (truthy($1) || truthy($3)) )
										{
											$$ = _TRUE;
											printf("%s\n", "true");
										}
										else
										{
											$$ = _FALSE; 
											printf("%s\n", "false");
										}
									}
	
	| exp BOOLEAN_BITWISE_OR exp 	{
										//$$ = (double)( (int)$1 | (int)$3 );
										//$$ = ((int)$1 | (int)$3);
										
										int result = ((int)$1 | (int)$3);
										//printf("BW_OR := %d\n", result);
										
										$$ = (double) result;
										
										printf("\t\tResult of %s | %s is: %s\n", function($1), function($3), function($$));
										
										//printf("$$ := %s\n", convert($$));
	
									}
									
	| exp BOOLEAN_BITWISE_EXC_OR exp	{
	
									int result = (int)$1 ^ (int)$3;
									
									$$ = (double) result;
									
									printf("\t\tResult of %s ^(XOR) %s is: %s\n", function($1), function($3), function($$));
	
									}
									
	| BOOLEAN_LOGICAL_NOT exp	{
									if(($2!=_FALSE)&&($2!=_Null)&&($2!=0.0))
										$$ = _FALSE;
										
									else
										$$ = _TRUE;
										
										
									printf("\t\tResult of !%s is: %s\n", function($2), (($$ == _TRUE) ? "true" : "false"));
	
								}
								
	| BOOLEAN_BITWISE_NOT exp	{
									$$ = ~(int)exp;
	
									printf("\t\tResult of ~%s is: %s\n", function($2), function($$));
								}



	| exp MUL exp  { if ($1 == _TRUE) { $1 = 1.0; } else if ($1 == _FALSE) { $1 = 0.0; };
					if ($3 == _TRUE) { $3 = 1.0; } else if ($3 == _FALSE) { $1 = 0.0; };
					if ($1 == _Null) { $1 = 0.0; } else if ($1 == _Null)  { $1 = 0.0; };
					if ($3 == _Null) { $3 = 0.0; } else if ($3 == _Null) { $3 = 0.0; };
					$$ = $1 * $3; printf("\t\tResult of %s * %s is: %s\n", function($1), function($3), function($$)); }
    | exp DIV exp  { if ($1 == _TRUE) { $1 = 1.0; } else if ($1 == _FALSE) { $1 = 0.0; };
					if ($3 == _TRUE) { $3 = 1.0; } else if ($3 == _FALSE) { $3 = 0.0; };
					if ($1 == _Null) { $1 = 0.0; } else if ($1 == _Null)  { $1 = 0.0; };
					if ($3 == _Null) { $3 = 0.0; } else if ($3 == _Null) { $3 = 0.0; };
	
					$$ = $1 / $3; printf("\t\tResult of %s / %s is: %s\n", function($1), function($3), function($$)); }
    | exp PLUS exp  { if ($1 == _TRUE) { $1 = 1.0; } else if ($1 == _FALSE) { $1 = 0.0; };
					if ($3 == _TRUE) { $3 = 1.0; } else if ($3 == _FALSE) { $3 = 0.0; };
					if ($1 == _Null) { $1 = 0.0; } else if ($1 == _Null)  { $1 = 0.0; };
					if ($3 == _Null) { $3 = 0.0; } else if ($3 == _Null) { $3 = 0.0; };
	
					$$ = $1 + $3; printf("\t\tResult of %s + %s is: %s\n", function($1), function($3), function($$)); }
    | exp MINUS exp  {
					if ($1 == _TRUE) { $1 = 1.0; } else if ($1 == _FALSE) { $1 = 0.0; };
					if ($3 == _TRUE) { $3 = 1.0; } else if ($3 == _FALSE) { $3 = 0.0; };
					if ($1 == _Null) { $1 = 0.0; } else if ($1 == _Null)  { $1 = 0.0; };
					if ($3 == _Null) { $3 = 0.0; } else if ($3 == _Null) { $3 = 0.0; };
					
					$$ = $1 - $3; printf("\t\tResult of %s - %s is: %s\n", function($1), function($3), function($$)); }

    | ID EQUALS exp  {
	
						char* str = calloc(NUM_STRING_LENGTH, 1); 
						str = function($3);
						
						if(enum_str[0])
						{

							$$ = generateExpValue(enum_str);
							
							evars[(unsigned int)$1] = strdup(enum_str);
							
							vars[(unsigned int)$1] = _Null;
							printf("\t\tevars[%c] = %s, %s\n", $1, evars[(unsigned int)$1], str);
							enum_str[0] = '\0';
						}
						else	{

							$$ = vars[(unsigned int)$1] = $3;
							evars[(unsigned int)$1] = "\0";
							printf("\t\tvars[%c] = %s\n", $1, str);
							
						}
					}


	| ID lo exp	{ //      BOOLEAN_BITWISE_NOT  BOOLEAN_LOGICAL_NOT 
					
	
					short int evar_or_var;
					if(strcmp(evars[(unsigned int)$1],""))	{
							
						evar_or_var = 1;
								
					}
					else	{
					
						evar_or_var = 0;
					}
			
					printf("$2 == %d, evar_or_var == %d\n", $2, evar_or_var);
					
					$$ = _Null;
					
					double lhs = 0;
					switch($2)	{
					
						case LOGICAL_EQ:
						
							//$$ = _Null;
							
							if (evar_or_var)	{
								if (!strcmp(function(generateExpValue(evars[(unsigned int)$1])),function($3)))
									$$ =_TRUE;
								else
									$$ = _FALSE;
							}
							
							else if (!strcmp(function(vars[(unsigned int)$1]), function($3)))	{
									$$ = _TRUE;
							}
							else
									$$ = _FALSE;
									
						if($$==_FALSE)
							printf("\t\t(%c == %s) := (false)\n", $1, function(vars[(unsigned int)$1]));
						else
							printf("\t\t(%c == %s) := (true)\n", $1, function(vars[(unsigned int)$1]));
						
						break;
						
						case BOOLEAN_LOGICAL_AND:
						
							//$$ = _Null;
							
							lhs = 0;
							
							if (evar_or_var)	{
							
								lhs = generateExpValue(evars[(unsigned int)$1]);
							}
							else
								lhs = vars[(unsigned int)$1];
								
							if (lhs && $3)	{
								printf("\t\t(%c && %s) := (true)\n", $1, function($3));
								$$ = _TRUE;
							}
							else	{
								printf("\t\t(%c && %s) := (false)\n", $1, function($3));
								$$ = _FALSE;
							}
							
						break;
						
						case BOOLEAN_BITWISE_AND:
						
							//$$ = _Null;

							lhs = 0;
							
							if (evar_or_var)	{
							
								lhs = generateExpValue(evars[(unsigned int)$1]);
							}
							else
								lhs = vars[(unsigned int)$1];
								
							$$ = (int)lhs & (int)$3;
							
							printf("\t\t($c & $s) := $s\n", $1, function($3), function($$));
							
						break;
						
						case BOOLEAN_LOGICAL_OR:
						
							lhs = 0;
							
							if (evar_or_var)	{
							
								lhs = generateExpValue(evars[(unsigned int)$1]);
							}
							else
								lhs = vars[(unsigned int)$1];
								
							if (lhs || $3)	{
								printf("\t\t(%c || %s) := (true)\n", $1, function($3));
								$$ = _TRUE;
							}
							else	{
							
								printf("\t\t(%c || %s) := (false)\n", $1, function($3));
								$$ = _FALSE;
							}

						break;
						
						case BOOLEAN_BITWISE_OR:
						
							lhs = 0;
							
							if (evar_or_var)	{
							
								lhs = generateExpValue(evars[(unsigned int)$1]);
							}
							else
								lhs = vars[(unsigned int)$1];
								
							$$ = (int)lhs | (int)$3;
							
							printf("\t\t($c | $s) := $s\n", $1, function($3), function($$));

						break;
						
						case BOOLEAN_LOGICAL_EXC_OR:
	
							
						break;
						
						case BOOLEAN_BITWISE_EXC_OR:
						
						
						break;
						
						
						default:
						
							break;
					
					
					}
				}
					
	| TRUE lo exp	{
								if(($3!=0.0)&&($3!=_FALSE)&&($3!=_Null))	{
								
									$$ = _TRUE;
								}
								else
									$$ = _FALSE;
									
								printf("\t\tResult of logical comparison: %s\n", function($$));
							}
	| FALSE lo exp	{
								if( ($3!=0.0)&&($3!=_Null)&&($3!=_FALSE) )	{
								
									$$ = _FALSE;
								}
								else
									$$ = _TRUE;
									
								printf("\t\tResult: %s\n", function($$));
							}
	| exp lo exp	{
								//("Truthy flag set! (exp LOGICAL_EQ exp)\n");
								if(truthyFlag)	{
									
									truthyFlag = 0;
									
									if( ( ($3!=_Null)||($3!=0.0)||($3==_TRUE) ) && ( ($1!=0.0)||($1!=_FALSE)||($1!=_Null) ) )	{
									
										$$ = _TRUE;
										
									}
									else	{
										
										$$ = _FALSE;
										
									}
								}
								
								else	{
								
									if($1==$3)
										$$ = _TRUE;
									else
										$$ = _FALSE;
								}
								
								if($$==_TRUE)
									printf("\t\ttrue(1)\n");
								
								else
									printf("\t\tfalse(0)\n");
							}

	| MINUS exp { $$ = -$2; printf("\t\tResult: %s\n", function($$)); }
	| PLUS exp  {
					if($2<0)
					{
						$$ = -$2;
					}
					else
					{
						$$ = +$2;
					}
					printf("\t\tResult: %s\n", function($$));
				}
	| OB exp CB      {$$ = $2; }
	
;

lo: LOGICAL_EQ { $$ = LOGICAL_EQ; } | BOOLEAN_LOGICAL_AND { $$ = BOOLEAN_LOGICAL_AND; } | BOOLEAN_BITWISE_AND { $$ = BOOLEAN_BITWISE_AND; } | BOOLEAN_LOGICAL_OR { $$ = BOOLEAN_LOGICAL_OR; } | BOOLEAN_BITWISE_OR  { $$ = BOOLEAN_BITWISE_OR; } | BOOLEAN_LOGICAL_NOT  { $$ = BOOLEAN_LOGICAL_NOT; } | BOOLEAN_BITWISE_NOT  { $$ = BOOLEAN_BITWISE_NOT; } | BOOLEAN_LOGICAL_EXC_OR  { $$ = BOOLEAN_LOGICAL_EXC_OR; }

power_f: POW OB exp COMMA exp CB { $$ = pow($3, $5); printf("\t\tpow(%s, %s) := %s\n", function($3), function($5), function($$)); }

options: OPTIONSET { $$ = 1.0; optionsFlag = 1; printf("Option to trim number set. Use 'unsetoption' to set number printing to verbose.\n"); function = trim; } | OPTIONUNSET { $$ = 0.0; optionsFlag = 0; printf("Option to trim number unset.\n"); function = convert; };

%%

void printVars()	{

	int i;
	
	for(i='A';i<'z';i++)	{
	
		if(vars[i]!=_Null)
			printf("vars[%c] = %s\n", (char) i, function(vars[i]));
			
	}	
	
			
	printf("\n");
	
	for(i='A';i<'z';i++)
		if(strcmp(evars[i],""))	{
			//printf("we're in, by jove!\n");
			printf("Evars[%c] = %s\n", (char) i, evars[i]);
		}
			
			
}

short int truthy(double i)	{

	if ( (i != _FALSE) && (i != _Null) && (i != 0.0) )
		return 1;
		
	return 0;
}

char *convert(double x)	{

	char *buf = malloc(NUM_STRING_LENGTH);
	
	if (x == _FALSE)	{
	
		buf = strdup("false");
		return buf;
	}
	
	if (x == _TRUE)	{
	
		buf = strdup("true");
		return buf;
	}
	
	if (x == _Null)	{
	
		buf = strdup("(empty)");
		return buf;
	}
	
	sprintf(buf, "%.15f", x);
	
	int offset = strlen(buf)-1;
	
	for(int i = offset; i >= 0; i--)	{
	
		if(buf[i]=='0')
			offset = i;
			
		else
			break;
	}

	// offset contains buf[n] offset of last non-zero digit
	if(buf[offset-1]=='.')
		offset--;
		
	buf[offset] = '\0';
	
	return buf;
}


/*
The trim(x) function is superfluous, but I leave it for historical reasons. There is no need to generate a string with trailing 0's
removed, as convert(x) does exactly the same thing. The difference with trim(x) is that trim(x) trims the string at
any contiguous sequence of 2 0's, for prettiness reasons, losing precision of the printed number.
*/
char *trim(double x)
{
    char *buf = malloc(NUM_STRING_LENGTH);
	
	if (x == _FALSE)	{
	
		buf = strdup("false");
		return buf;
	}
	
	if (x == _TRUE)	{
	
		buf = strdup("true");
		return buf;
	}
	
	if (x == _Null)	{
	
		buf = strdup("(empty)");
		return buf;
	}
	
    sprintf(buf, "%.15f", x);
	
	int offset = 0;
	int count = 0;
	short int flag = 0;
	
	
	for(int i=0;i<strlen(buf);i++)	{
	
		if(buf[i]=='.')	{
		
			flag++;
			continue;
		}
		
		if((buf[i]=='0')&&(flag>=1))	{
		
			if(count==0)
				offset = i;
				
			count++;
			
			
			if(count>=2)
				break;
			
			// this will (in the next if-construct), essentially round off the number after a sequence of 2 0's in it's string. Bit weird, lol.
			// I just remembered my reasoning. If an operand has a stupid trailing string, such 2.34500000001, it would round it, effectively to
			// 2.34500, which thinking about it now, is fucking stupid of me, because I am not converting c-strings back to doubles, and we would
			// want to see the number printed as 2.345
			
		}
		else
			count = 0;
			
		
	}
	
	if (count)	{
	
		if(buf[offset-1]=='.')
			offset--;
		// need to truncate
		buf[offset] = '\0';
	}

    return buf;
}


int main()
{

	function = convert;
	
	enum_str = (char *)calloc(NUM_STRING_LENGTH + 1 + NUM_STRING_LENGTH, 1);
	
	_FALSE = -DBL_MAX;
	_TRUE = DBL_MAX;
	_Null = DBL_MAX - 1;
	
	int i;
	
	for(i = 0; i < 256; i++)	{
	
		evars[i] = (char *)calloc(100, 1);
		vars[i] = _Null;
	}
	
	truthyFlag = 0;
	// (*((long long*)&_FALSE))= ~(1LL<<52); // this bloody method didnt work
	
	//printf("_Null == %s\n\n", function(_Null));

	optionsFlag = 1; printf("Option to trim number set. Use 'unsetoption' to set number printing to verbose.\n"); function = trim;
	
	yyparse();
    return 0;
}

int yyerror(const char *s)
{
	printf("Error: %s\n", s);
	return 0;
}
