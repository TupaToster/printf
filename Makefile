ASM = nasm
LINK = ld
CC = gcc
ASM_ARGS = -f elf64 -l list.lst
LINK_ARGS = -s
CC_ARGS = 
ASM_SRC = printf.asm
CC_SRC = 

all: printf $(ASM_SRC) $(CC_SRC)

printf:	$(ASM_SRC)
	$(ASM) $(ASM_ARGS) $^ -o $(^:.asm=.o)
	$(LINK) $(LINK_ARGS) -o $@ $(^:.asm=.o)

std_asm_test: asm_test.asm
	$(ASM) $(ASM_ARGS) $^ -o $(^:.asm=.o)
	$(CC) -no-pie -m64 $(^:.asm=.o) -o $@ -lc

clean:
	rm *.o printf *.lst

.PHONY:	clean

