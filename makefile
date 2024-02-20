abc: abc.o
	gcc -m32 abc.o -o abc
	

abc.o: abc.s
	nasm -f elf32 abc.s -o abc.o

clean:
	rm -f abc abc.o
	

run: abc
	
	./abc
