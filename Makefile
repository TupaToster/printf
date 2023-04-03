ASM = nasm
LINK = ld
CC = gcc
ASM_ARGS = -f elf64 -l list.lst
LINK_ARGS = -s
CC_ARGS = -c
ASM_SRC = _printf.asm
CC_SRC = main.cpp
CC_LINK = -no-pie -m64

all: printf

printf:	_printf.o main.o
	$(CC) $(CC_LINK) $^ -o printf -lc

_printf.o:	$(ASM_SRC)
	$(ASM) $(ASM_ARGS) $^ -o $(^:.asm=.o)

main.o:	$(CC_SRC)
	$(CC) $(CC_ARGS) $^ -o $@

std_asm_test: asm_test.asm
	$(ASM) $(ASM_ARGS) $^ -o $(^:.asm=.o)
	$(CC) -no-pie -m64 $(^:.asm=.o) -o $@ -lc

clean:
	rm *.o printf *.lst

.PHONY:	clean

