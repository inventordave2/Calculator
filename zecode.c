
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
