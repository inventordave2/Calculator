   #include <stdio.h>
	#include <stdlib.h>
	#include <math.h>
	#include <string.h>
	#include <float.h>
	
	#include "toyf.tab.h"
	
	#include "../../../aplib/aplib_o.c"
	
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

	#define NUM_STRING_LENGTH 325 // max length of fp (double) number, including decimal point. Obvs is way less than 100.


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
