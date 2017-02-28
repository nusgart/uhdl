#

INCS = -I/home/ams/local/src/gplcver-2.12a.src/pli_incs

CFLAGS= -m32 -fPIC -Wall -g $(INCS) -D__CVER__
LFLAGS= -G -shared -export-dynamic -m elf_i386 -L/usr/lib32

all: pli_mmc.so pli_mmc.vpi

pli_mmc.o: pli_mmc.c 
	$(CC) $(CFLAGS) -c pli_mmc.c

pli_mmc.so: pli_mmc.o
	$(LD) $(LFLAGS) pli_mmc.o -o pli_mmc.so

pli_mmc.vpi: pli_mmc.o
	$(LD) $(LFLAGS) pli_mmc.o -o pli_mmc.vpi

clean:
	rm -f *.o *.so *.vpi
