#

INCS = -I/home/ams/local/src/gplcver-2.12a.src/pli_incs

CFLAGS= -m32 -fPIC -Wall -g $(INCS) -D__CVER__
LFLAGS= -G -shared -export-dynamic -lSDL -lpthread -m elf_i386 -L/usr/lib32

all: display.so display.vpi

display.o: display.c 
	$(CC) $(CFLAGS) -c display.c

display.so: display.o Makefile
	$(LD) $(LFLAGS) display.o -o display.so

display.vpi: display.o Makefile
	$(LD) $(LFLAGS) display.o -o display.vpi

clean:
	rm -f *.o *.so *.vpi
