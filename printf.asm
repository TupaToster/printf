 ; (c) Ded, 2012

section .data
msg     db      "matb v kanave", 0x0a
len     equ     $ - msg

section .text
        global _start

%macro          EXIT 1
                mov rax, 0x3c
                xor rdi, rdi
                syscall
%endmacro

_start:
                mov rax, 0x01
                mov rdi, 1
                mov rsi, msg
                mov rdx, len
                syscall

                EXIT