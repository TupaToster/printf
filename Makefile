ASM = nasm
LINK = ld
CC = g++
ASM_ARGS = -f elf64 -l list.lst
LINK_ARGS = -s
CC_ARGS = 
ASM_SRC = printf.asm
CC_SRC = 

all: printf $(ASM_SRC) $(CC_SRC)

printf:	$(ASM_SRC)
	$(ASM) $(ASM_ARGS) $^ -o $(^:.asm=.o)
	$(LINK) $(LINK_ARGS) -o $@ $(^:.asm=.o)

clean:
	rm *.o printf *.lst

.PHONY:	clean

