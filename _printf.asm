; (c) Ded, 2012
section .rodata

JmpTab:
.b      dq      bTok
.c      dq      cTok
.d      dq      dTok
        dq      dflt
.f      dq      fTok
times ('o' - 'f' - 1)   dq      dflt
.o      dq      oTok
times ('s' - 'o' - 1)   dq      dflt
.s      dq      sTok
times ('x' - 's' - 1)   dq      dflt
.x      dq      xTok
        dq      dflt

section .data
args    times (5)       dq      0x00
float_args      times (8) dq 0x00


section .text
        global _printf

_printf:
                push rdi
                lea rdi, args
                mov [rdi], rsi
                mov [rdi + 8], rdx
                mov [rdi + 16], rcx     ; puts args to an array for easier iteration
                mov [rdi + 24], r8
                mov [rdi + 32], r9
                xor r11, r11            ; iterator for args
                pop rdi

                push rdi
                push rsi
                push rdx        ; reg saver
                push rcx
                push r8
                push r9
                push rax

                xor rbx, rbx
                xor rcx, rcx
                call Calculator

                pop rax
                pop r9
                pop r8
                pop rcx
                pop rdx         ;reg unsaver
                pop rsi
                pop rdi

                ret


; ----------------------------
; Calculates len of null-term string and puts it to rax
; ----------------------------
; Needs:          rbx - string offset

; Exit:           rcx - strlen

; Expects:        none

; Destroys:       rax, rcx
; ============================
StrLen:         xor rcx, rcx
.next:          cmp BYTE [rbx], 0x00
                je .break
                inc rcx
                inc rax
                jmp .next
.break:         ret


; ------------------------------
; Processes da format string with some post irony
; ------------------------------
; Needs:          rdi - fmt string

; Exit:           Printed stuff on screen

; Expects:        none

; Destroys:       rbx
; ==============================
Calculator:

.loop:          cmp byte [rdi], '%'
                je .tokens

                push rax
                push rdi
                push rsi
                push rdx
                mov rax, 1
                mov rsi, rdi            ; prints current char
                mov rdi, 1
                mov rdx, 1
                syscall
                pop rdx
                pop rsi
                pop rdi
                pop rax

                inc rdi              ; moves to next

                cmp byte [rdi], 0x00
                jne .loop               ; loop while not \0
                jmp .break          ; skips token check for true

.tokens:        inc rdi        ; shift to format spec

                cmp byte [rdi], 0x00e
                je dflt
                cmp byte [rdi], '%'
                je pTok                ; check for special conditions
                cmp byte [rdi], 'a'
                jb dflt
                cmp byte [rdi], 'x'
                ja dflt

                xor rbx, rbx
                mov bl, byte [rdi]              ;jump to corec function
                call [JmpTab + 8 * (ebx - 'b')]
                inc rdi
                jmp .loop

.break:         ret


; For all _Tok functions call syntax is the same:

; Needs: none

; Exit:   desired output to screen

; ----------------- char token ----------------
cTok:           add r11, args

                push rax
                push rdi
                push rsi
                push rdx
                mov rax, 1
                mov rsi, r11           ; prints current char
                push r11
                mov rdi, 1
                mov rdx, 1
                syscall
                pop r11
                pop rdx
                pop rsi
                pop rdi
                pop rax

                sub r11, args - 8

                ret

bTok:           ret

dTok:           ret

fTok:           ret

sTok:           ret

xTok:           ret

oTok:           ret

pTok:           ret

dflt:           ret





