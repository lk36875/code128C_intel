CC=g++
ASMBIN=as

all : asm cc link
asm :
	$(ASMBIN) -msyntax=intel -mnaked-reg -o func64.o -g func64.asm
cc :
	$(CC) -c -g -O0 main.cpp &> errors.txt
link :
	$(CC) -g -o test main.o func64.o
clean :
	rm *.o
	rm test
	rm errors.txt
	rm func.lst

