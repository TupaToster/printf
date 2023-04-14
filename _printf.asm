; (c) Ded, 2012
section .rodata

bin2binStrMask  equ     0x0000000080000000     ; mask to separate upper bit of e_x register
bin2hexStrMask  equ     0x00000000F0000000      ; mask to separate upper half byte of e_x reg
bin2octStrMask  equ     0x0000000038000000      ; mask to separate upper 3 bits of e_x reg for octal
ErrormsgLen     equ     12

JmpTab:
.b      dq      bTok
.c      dq      cTok
.d      dq      dTok
        dq      dflt
.f      dq      fTok
times ('o' - 'f' - 1)   dq      dflt            ; table for format jumps
.o      dq      oTok
times ('s' - 'o' - 1)   dq      dflt
.s      dq      sTok
times ('x' - 's' - 1)   dq      dflt
.x      dq      xTok
        dq      dflt

ArgJmpTab:
dq      zero
dq      one
dq      two             ; selector for amount of pushed args
dq      three
dq      four
dq      five

section .data
buff    times (256) db 0x00     ; print buffer for %_
Errormsg        db '<unkwn_spec>', 0x00

section .text
        global _printf

_printf:
; Disclamer: only top of 8 floats can be outputted per function call because otherwise it becomes pretty un neat to code

                pop r10         ; saves return point

                call GetArgCnt  ; gets non float arg cnt

                cmp r11, 5
                jae five                ; pushes correct amount of args
                shl r11, 3
                jmp [ArgJmpTab + r11]

five:           push r9
four:           push r8
three:          push rcx                ; pusher for custom amount of args for easier life
two:            push rdx
one:            push rsi

zero:           call Calculator         ; function to print all

                push r10                ; restores return point

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
                push rax                ; saves rax rcx rdx rbx
                push rdx
                push rbx

                mov rbx, dflt
                xor rdx, rdx

                mov rax, rdi            ; moves rdi to rax for strlen

                call StrLen

                mov rax, rdi            ; again

                xor r11, r11            ; zeroes r11 for count of args

.loop:          cmp byte [rax], '%'     ; checks for arg token
                jne .next

                inc rax         ; moves to format spec
                dec rcx         ; decreases iterator for loop
                cmp byte [rax], '%'     ; checks for %%
                je .next
                cmp byte [rax], 'f'     ; and %f cause they are different and i hate %f
                je .next
                cmp byte [rax], 'b'     ;checks extreme cases
                jb .next
                cmp byte [rax], 'x'
                ja .next

                xor rdx, rdx
                mov dl, byte [rax]
                sub dl, 'b'
                shl rdx, 3
                mov rdx, [JmpTab + rdx]
                cmp rbx, rdx
                je .next

                inc r11         ; adds arg counter
.next:          inc rax         ; moves to next char
                loop .loop

                pop rbx
                pop rdx
                pop rax         ; restores rax rcx rdx rbx
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
                je .break               ; lol its trivial
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
                inc rdx         ; shifts to next char and incs char count for print to %
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

                inc rdi                 ;moves to format spec

                cmp byte [rdi], 0x00
                jne .noZero
                call dflt
                jmp .xcpnRet
.noZero:        cmp byte [rdi], '%'
                jne .noP
                call pTok
                jmp .xcpnRet
.noP:           cmp byte [rdi], 'b'     ;checks extreme cases
                jae .noLess
                call dflt
                jmp .xcpnRet
.noLess:        cmp byte [rdi], 'x'
                jbe .noMore
                call dflt
                jmp .xcpnRet

.noMore:        mov dl, byte [rdi]              ;jumps to correc format spec processor
                call [JmpTab + 8 * (rdx - 'b')]
.xcpnRet:       inc rdi                 ; moves to next symbol
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

; --------------
; Converts number to binary printf ready stuff in buffer
; --------------
; Needs:          rax - number to convert
; Exit:           rax in binary > buff
; Expects:        none
; Destroys:       rax
; ==============
bin2binStr:     push rbx
                push rdx                ; saves rbx, rdx
                lea rdx, buff

                push rcx                ; saving rcx and setting it to count 0x20 bits
                mov rcx, 0x20

.loop:          mov ebx, eax
                and ebx, bin2binStrMask    ; copies eax to ebx and separates upper bit in here

                cmp ebx, 0      ; writes '0' if ebx == 0x00
                je .write0

                mov byte [rdx], '1'     ; writes one otherwise
                jmp .noWrite0
.write0:        mov byte [rdx], '0'
.noWrite0:      inc rdx

                shl rax, 1              ; shifts one left

                loop .loop

                pop rcx
                pop rdx         ; restoring wasted regs
                pop rbx

                ret


; ------------
; Converts to hex from bin
; ------------
; Needs:          rax - number to convert
; Exit:           eax in hex > buff
; Expects:        none
; Destroys:       rax
; ------------
bin2hexStr:     push rbx        ; saves rbx for use as temp reg
                push rdi

                mov rbx, cs
                mov es, rbx

                lea di, buff    ; sets es:[di] to buff

                push rcx
                mov rcx, 0x8   ; saves rcx ad sets it to count 0x8 hex digits

                mov rbx, rax

.loop:          mov eax, ebx
                and eax, bin2hexStrMask

                shr eax, 4 * 7  ; shifts half byte to al

                cmp al, 0xa
                jae .letter     ; checks if letter to be written

                add al, '0'
                stosb           ; converts al to char and writes it to buff

                jmp .endif

.letter:        add al, 'A' - 0xa
                stosb           ; converts al to letter char and stores it

.endif:         shl rbx, 4      ; shifts to next 4 bits

                loop .loop

                pop rcx         ; restores regs
                pop rdi
                pop rbx

                ret

; ---------------
; Converts to oct str from bin
; ---------------
; Needs:          eax - number to convert
; Exit:           eax in oct > buff
; Expects:        none
; Destroys:       rax
; ===============
bin2octStr:     push rbx
                push rdi

                mov rbx, cs
                mov es, rbx

                lea di, buff    ; sets es:[di] to buff

                push rcx
                mov rcx, 0xa   ; saves rcx and sets it to count 0xa oct digits (remaining 2 bits will be mapped separately)

                xor rbx, rbx
                mov ebx, eax

                and eax, 0x00000000C0000000     ; custom mask for upper 2 bits
                shr eax, 30                     ; switch them to al
                add al, '0'
                stosb

                mov eax, ebx

.loop:          mov eax, ebx
                and eax, bin2octStrMask

                shr eax, 27d  ; shifts half byte to al
                add al, '0'
                stosb           ; converts al to char and writes it to buff

                shl rbx, 3      ; shifts to next 4 bits

                loop .loop

                pop rcx         ; restores regs
                pop rdi
                pop rbx

                ret

; For all _Tok functions call syntax is the same:

; Needs: none

; Exit:   desired output to screen

; Destroys : rax, rsi, rdx, r9 - 100%, others may vary

; ----------------- char token ----------------
cTok:
                pop r9         ; saves return

                pop rax         ; retrieve arg

                push r9         ; restore return point
                mov buff[0], al ; moves char to buff

                push rdi        ; saves regs cause they get wasted
                push r11

                mov rax, 1
                lea rsi, buff
                mov rdi, 1              ; prints single char from buff
                mov rdx, 1
                syscall

                pop r11         ; restores stuf
                pop rdi

                ret
;---------------------------------------------------------------------

bTok:           pop r9          ; saves return

                pop rax         ; gets next arg

                push r9         ; restores return

                call bin2binStr    ; converts eax to binary in buff

                push rdi
                push r11        ; saves rdi, r11 cause they are used

                mov rax, 1
                lea rsi, buff
                mov rdi, 1      ; sets print args
                mov rdx, 32

.skipZeros:     cmp byte [rsi], '0'
                jne .break
                inc rsi         ; skips first zeros
                dec rdx
                jmp .skipZeros

.break:         syscall         ; prints

                pop r11
                pop rdi         ; restures rdi, r11

                ret
;---------------------------------------------------------------------
dTok:           pop r9

                pop rax         ; gets arg

                push r9


                lea rsi, buff
                mov rcx, rsi    ; sets rcx = rsi = lea buff
                xor rdx, rdx

                push rbx
                cqo

.loop:          mov rbx, 0x0a
                div rbx
                add dl, '0'
                mov byte [rcx], dl      ; transfers number to reversed order string
                xor dl, dl
                inc rcx
                cmp rax, 0
                jne .loop

                pop rbx

                sub rcx, rsi    ; rcx = Strlen - 1
                dec rcx
                xor r9, r9

                cmp rcx, 0
                ja .swapper             ; checks for single digit (its easier to add checker than rewrite swapper)
                jmp .skipSwap


.swapper:       mov al, byte [rsi + r9]
                sub rsi, r9
                xchg al, byte [rsi + rcx]               ; reverses buff for rcx
                add rsi, r9
                mov byte [rsi + r9], al
                inc r9
                sub rcx, r9
                cmp r9, rcx
                jae .break
                add rcx, r9
                jmp .swapper

.break:         add rcx, r9     ; restores rcx from swapper
.skipSwap:      inc rcx         ; restores rcx to Strlen

                push rdi
                push r11

                mov rax, 1
                mov rdi, 1      ; prints buff
                mov rdx, rcx
                syscall

                pop r11
                pop rdi

                ret
;---------------------------------------------------------------------

fTok:           ret
;---------------------------------------------------------------------

sTok:           pop r9
                pop rax         ; gets arg
                push r9

                push rax
                call StrLen     ; gets arg len
                pop rax

                push r11
                push rdi

                mov rsi, rax            ; prints arg
                mov rax, 1
                mov rdi, 1
                mov rdx, rcx
                syscall

                pop rdi
                pop r11

                ret             ; simple as grob
;---------------------------------------------------------------------

xTok:           pop r9

                pop rax         ; gets arg

                push r9

                call bin2hexStr ; converts rax to hex in buff

                push rdi        ; saves rdi, r11
                push r11

                mov rax, 1
                lea rsi, buff   ; sets args
                mov rdi, 1
                mov rdx, 0x8

.skipZeros:     cmp byte [rsi], '0'
                jne .break
                inc rsi         ; skips zeros
                dec rdx
                jmp .skipZeros

.break:         syscall         ; le printer

                pop r11
                pop rdi         ; restores stuf

                ret

;---------------------------------------------------------------------

oTok:           pop r9

                pop rax         ; gets arg

                push r9

                call bin2octStr ; converts rax to oct in buff

                push rdi        ; saves regs cause they used
                push r11

                mov rax, 1
                lea rsi, buff
                mov rdi, 1      ; sets syscall args
                mov rdx, 0xb

.skipZeros:     cmp byte [rsi], '0'
                jne .break
                inc rsi
                dec rdx         ; skips Zeros
                jmp .skipZeros

.break:         syscall ; le print

                pop r11         ; restores stuf
                pop rdi

                ret

;---------------------------------------------------------------------

pTok:           push rdi
                push r11
                push rax        ; saves lotta regs
                push rsi
                push rdx

                mov rax, 1
                mov rsi, rdi    ; prints %
                mov rdi, 1
                mov rdx, 1
                syscall

                pop rdx
                pop rsi
                pop rax         ; restores da regs
                pop r11
                pop rdi

                ret
;---------------------------------------------------------------------

dflt:           push rdi
                push r11
                push rax        ; saves lotta regs
                push rsi
                push rdx

                mov rax, 1
                mov rsi, Errormsg
                mov rdi, 1
                mov rdx, ErrormsgLen    ; prints wrong format message instead of %_
                syscall

                pop rdx
                pop rsi
                pop rax
                pop r11         ; restores da regs
                pop rdi

                ret
;---------------------------------------------------------------------





