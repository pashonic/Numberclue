
;   Numberclue  Copyright (C) 2009  Aaron Greene

;   This program is free software: you can redistribute it and/or modify
;   it under the terms of the GNU General Public License as published by
;   the Free Software Foundation, either version 3 of the License, or
;   (at your option) any later version.

;   This program is distributed in the hope that it will be useful,
;   but WITHOUT ANY WARRANTY; without even the implied warranty of
;   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;   GNU General Public License for more details.

;   You should have received a copy of the GNU General Public License
;   along with this program.  If not, see <http://www.gnu.org/licenses/>.

global main

extern srand
extern rand
extern time

section .data
    strIntro1:      db  "Enter Highest Number:",10
    strIntro1Len    equ $ - strIntro1

    strIntro2:      db  "Enter Number of Guesses:", 10
    strIntro2Len    equ $ - strIntro2

    strG:           db  "Guesses left: XXXX"
    strGLen         equ $ - strG

    strHigh:        db  "Too High",10
    strHighLen      equ $ - strHigh

    strLow:         db  "Too Low",10
    strLowLen       equ $ - strLow

    strWon:         db  "GJ you won!",10
    strWonLen       equ $ - strWon

    strLos:         db  "You FAIL!",10
    strLosLen       equ $ - strLos

section .bss
    string          resb 10
    maxNum          resb 10
    guessCnt        resb 10
    randNum         resb 10

section .text

        ;
        ;;Get max random value from user
        ;

main:   mov  edx, strIntro1Len
        mov  ecx, strIntro1
        call print               ; Print max number user message

        mov  edx, 10		     ; Set input length
        mov  ecx, string	     ; Address to buffer to store string input
        call read                ; Get max random value from user

        mov  ebx, string         ; Point ebx to given decimal string
        call str2dec             ; Convert decimal string to decimal value
        mov  [maxNum], eax       ; Store max number

        ;
        ;;Get guess count value from user
        ;

        mov  edx, strIntro2Len
        mov  ecx, strIntro2
        call print               ; Print max number prompt

        mov  edx, 10		     ; Set input length
        mov  ecx, string	     ; Address to buffer to store string input
        call read                ; Get guess count from user

        mov  ebx, string         ; Point ebx to given decimal string
        call str2dec             ; Convert decimal string to decimal value
        mov  [guessCnt], eax     ; Store guess count

        ;
        ;;Make random number
        ;

        mov  eax, [maxNum]       ; Set max number
        call mkrandn             ; Get random number
        mov  [randNum], eax      ; Store random number

        ;
        ;;Run game
        ;

        mov esi, [randNum]       ; esi = Random number
        mov edi, [guessCnt]      ; edi = Max guesses

play:   cmp  edi, 0              ; Check for last guess
        je   loser               ; If last guess, than GAME OVER!

        mov  eax, edi            ; Set guess count to parameter
        mov  ebx, strG + 14      ; Set EBX to point to number portion of string
        call dec2str             ; Convert guess count to string

        mov  edx, 15             ; Set position
        add  edx, ecx            ; Add decimal length to amount printed
        mov  ecx, strG           ; Set pointer to string with guess count
        call print               ; Print guess count
        dec  edi                 ; Decrement guess count

        mov  edx, 10		     ; Set user input length
        mov  ecx, string	     ; Address to user guess string
        call read                ; Get guess from user
        mov  ebx, string         ; Paramenter as address to user guess string
        call str2dec             ; Convert given guess to decimal value
        cmp  eax, esi            ; Compare guessed number to target random number
        jg   toohigh             ; Guess > Target
        jl   toolow              ; Guess < Target
        jmp  winner              ; Guess = Target

toohigh:mov  edx, strHighLen
        mov  ecx, strHigh
        call print               ; Print "Too Hight" message
        jmp  play

toolow: mov  edx, strLowLen
        mov  ecx, strLow
        call print               ; Print "Too Low" message
        jmp  play

winner: mov  edx, strWonLen
        mov  ecx, strWon
        call print               ; Print win message.
        jmp  exitapp

loser:  mov  edx, strLosLen
        mov  ecx, strLos
        call print               ; Print lose message.

exitapp:mov  eax, 1
        int  0x80                ; Exit Game

;read
;Input:     ECX: Pointer to buffer to write too
;           EDX: Length
;Output:    None
read:   push rbx
        push rax
        mov  ebx, ecx            ; Pass pointer to buffer to EBX
        mov  eax, ebx            ; Pass pointer to buffer to EAX
        add  eax, edx            ; Add length to EAX
read1:  mov  byte [ebx], 0x0     ; Clear bytes
        inc  ebx
        cmp  ebx, eax
        jl   read1               ; Continue loop if EBX < EAX
        mov  eax, 3              ; Set read system command
        mov  ebx, 1              ; Read from standard input
        int  0x80                ; Call kernel
        pop  rax
        pop  rbx
        ret

;print
;Input:     ECX: Pointer to string to print
;           EDX: Length
;Output:    None
print:  push rax
        push rbx
        mov  eax, 4              ; Set print system command
        mov  ebx, 1              ; Set to write to screen
        int  0x80                ; Call kernel
        pop rbx
        pop rax
        ret

;mkrandn (Make Random Number)
;Input:     EAX: Max Random Number
;Output:    EAX: Generated Random Number
mkrandn:push rsi
        push rdi
        push rdx
        push rcx
        push rax
        sub  edi, edi            ; Set C parameter to 0 (NULL)
        call time                ; Call C time function
        mov  edi, eax            ; Pass result to srand parameter
        call srand               ; Call C srand function to seed rand
        call rand                ; Call C rand function, result is in ecx
        pop  rcx                 ; Restore EAX parameter into ECX
getrmd: sub  eax, ecx            ; Subtract ECX from EAX
        cmp  eax, ecx            ; Compare EAX with ECX
        jg   getrmd              ; If EAX is still greater than ECX, continue loop
        pop  rcx
        pop  rdx
        pop  rdi
        pop  rsi
        ret

;ctdig (Count Digits)
;Input:     EAX: Number to count
;Output:    ECX: Number of digits
ctdig:  push rax
        push rsi
        push rdx
        sub ecx, ecx            ; We want to begin count at 0
        mov esi, 10             ; We want to divide by 10
ctloop: sub edx, edx            ; Clear EDX, its a div requirement
        div esi                 ; Divide EAX by 10
        inc ecx                 ; Add 1 to counter
        cmp eax, 0
        jg  ctloop              ; Keep going if EAX is greater than 0
        pop rdx
        pop rsi
        pop rax
        ret

;dec2str (Decimal to String)
;Input:     EAX: Decimal value to convert
;           EBX: Pointer to string buffer to place string
;Output:    EBX: Pointer to string buffer with converted string
;           ECX: Length of string
dec2str:push rax
        push rsi
        push rdi
        push rdx
        call ctdig              ; Count the number of digits
        mov esi, 10             ; We want to divide by 10
        mov edi, ebx            ; Save string pointer starting place to compare later
        add ebx, ecx            ; Start at end of string
        mov byte [ebx], 10      ; Add Ling break character to end of string
addDig: sub edx, edx            ; Zero EDX, needed for div
        div esi                 ; Divide random number by 10 to get 1st right digit
        add dl, 0x30            ; Add 30 to convert from decimal value to acsii number
        dec ebx                 ; Decrement string pointer
        mov [ebx], dl           ; Add acsii character number to string
        cmp ebx, edi            ; Compare EBX pointer with beginning of string
        jg addDig               ; Not end of string? keep going
        pop rdx
        pop rdi
        pop rsi
        pop rax
        ret

;str2dec (String to Decimal)
;Input:     EBX: Pointer to string buffer to place string
;Output:    EAX: Decimal Value
str2dec:push rsi
        push rdx
        push rcx
        sub eax, eax            ; Zero out EAX
        sub edx, edx            ; Zero out EDX
        mov si, 10              ; Set multipler to 10
decloop:mov ecx, [ebx]          ; Get ascii number character
        and ecx, 0xFF           ; Isolate first character
        sub ecx, 0x30           ; Subtract 30 to convert to decimal
        cmp ecx, 9
        jg  exit                ; Exit if EAX > 9
        cmp ecx, 0
        jl  exit                ; Or EAX < 0
        mul si                  ; Multiply EAX by 10 to move decimal value up position
        add eax, ecx            ; Add new single digit value
        inc ebx                 ; Increment string pointer by 1
        jmp decloop             ; Get next decimal character
exit:   pop rcx
        pop rdx
        pop rsi
        ret
