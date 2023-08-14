toyf:	
	bison -d toyf.y
	flex toyf.l
	
	gcc toyf.tab.c lex.yy.c -o toyf.exe
	
clean:
	rm -f toyf.exe 
	rm -f toyf.tab.c 
	rm -f toyf.tab.h 
	rm -f lex.yy.c
	
	rm -f toy.exe 
	rm -f toy.tab.c 
	rm -f toy.tab.h 

