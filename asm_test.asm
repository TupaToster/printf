; (c) Ded, 2012

section .data
msg:    db      "matb v kanave", 10d, 0
fmt:    db      "%s", 0

section .text
        extern printf
        global main

main:
                push rbp

                mov rdi, fmt
                mov rsi, msg
                xor rax, rax
                call printf

                pop rbp

                xor rax, rax

                ret

; ----------------------------
; Calculates len of null-term string and puts it to rax
; ----------------------------
; Needs:          rax - string offset

; Exit:           rcx - strlen

; Expects:        none

; Destroys:       rax, rcx
; ============================
StrLen:         xor rdx, rdx
.next:          cmp BYTE [rax], 0x00
                je .break
                inc rdx
                inc rax
                jmp .next
.break:         ret

