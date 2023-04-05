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

ArgJmpTab:
dq      zero
dq      one
dq      two
dq      three
dq      four
dq      five

section .data
buff    times (256) db 0x00

section .text
        global _printf

_printf:
; Disclamer: only top of 8 floats can be outputted per function call because otherwise it becomes pretty un neat to code



                pop r10

                call GetArgCnt

                cmp r11, 5
                jae five
                shl r11, 3
                jmp [ArgJmpTab + r11]

five:           push r9
four:           push r8
three:          push rcx
two:            push rdx
one:            push rsi

zero:           call Calculator


                push r10

                ret

; -----------------------------
; Gets amount of args required by fmt string
; -----------------------------
; Needs:          rdi - fmt string ptr

; Exit:           r11 - total non-float arg count (cause float arg cnt is stored in rax)

; Expects:        none

; Destroys:       none
; =============================
GetArgCnt:      push rcx
                push rax

                mov rax, rdi

                call StrLen

                mov rax, rdi

                xor r11, r11

.loop:          cmp byte [rax], '%'
                jne .next

                inc rax
                dec rcx
                cmp byte [rax], '%'
                je .next
                cmp byte [rax], 'f'
                je .next

                inc r11
.next:          inc rax
                loop .loop

                pop rax
                pop rcx
                ret
; ----------------------------
; Calculates len of null-term string and puts it to rax
; ----------------------------
; Needs:          rax - string offset

; Exit:           rcx - strlen

; Expects:        none

; Destroys:       rax, rcx
; ============================
StrLen:         xor rcx, rcx
.next:          cmp BYTE [rax], 0x00
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

; Destroys:       rdx, rax, rsi, rdi, rbx
; ==============================
Calculator:

                pop r11                 ; saves ret address

                xor rdx, rdx

.loop:          cmp byte [rdi], '%'     ; reads all the way up to the first '%'
                je .break1

                cmp byte [rdi], 0x00
                je .break2              ; checks for string end

                inc rdi
                inc rdx
                jmp .loop

.break1:        push rdi
                push r11
                sub rdi, rdx
                mov rsi, rdi
                mov rax, 1              ; prints everything up to '%'
                mov rdi, 1
                syscall
                pop r11
                pop rdi

                xor rdx, rdx            ; zeroing counter

                inc rdi         ;moves to format spec

                cmp byte [rdi], 0x00
                je dflt
                cmp byte [rdi], '%'
                je pTok
                cmp byte [rdi], 'b'     ;checks extreme cases
                jb dflt
                cmp byte[rdi], 'x'
                ja dflt

                mov dl, byte [rdi]              ;jumps to correc format spec processor
                call [JmpTab + 8 * (rdx - 'b')]
                inc rdi                 ; moves to next symbol
                xor rdx, rdx            ; zeroing counter again
                loop .loop

.break2:
                push r11
                sub rdi, rdx
                mov rsi, rdi
                mov rax, 1              ; prints everything up to 0x00
                mov rdi, 1
                syscall

                ret

; For all _Tok functions call syntax is the same:

; Needs: none

; Exit:   desired output to screen

; Destroys : rax, rsi, rdi, rdx - 100%, others may vary

; ----------------- char token ----------------
cTok:
                pop r9         ; saves return


                pop rax
                mov buff[0], al

                push rdi
                push r11
                mov rax, 1
                lea rsi, buff
                mov rdi, 1              ; prints single char from buff
                mov rdx, 1
                syscall
                pop r11
                pop rdi

                push r9

                ret

bTok:
                push rax
                push rdi
                push rsi
                push rdx

                xor rcx, rcx
                mov rcx, 32d


                ret

dTok:           ret

fTok:           ret

sTok:           ret

xTok:           ret

oTok:           ret

pTok:           ret

dflt:           ret





