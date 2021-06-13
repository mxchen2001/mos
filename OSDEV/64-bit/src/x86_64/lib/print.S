; Function: printString
;
; Purpose: to print a null terminated string using bios calls
; 
; Params: starting string address in register `bx`

printString:
    pusha                               ; save contents of registers

    mov ah, 0x0e                        ; indicate teletype output
    .print_loop:
        mov al, [bx]                        ; loads starting address of string
        cmp al , 0                        
        je .print_exit                      ; break if null

        int 0x10                            ; video service interrupt
        add bx, 1                           ; increment pointer
        jmp .print_loop

    .print_exit:
    popa                                ; restore contents of registers
    ret                                 


; Function: printHex
;
; Purpose: to print hexidecimal as a string
; 
; Params: starting string address in register `bx`
printHex:
    push dx
    mov dx, bx

    mov bx, dx
    shr bx, 12
    and bx, 0x000F
    mov bx, [HEX_TABLE + bx]
    mov [HEX_PATTERN + 2], bl

    mov bx, dx
    shr bx, 8
    and bx, 0x000F
    mov bx, [HEX_TABLE + bx]
    mov [HEX_PATTERN + 3], bl

    mov bx, dx
    shr bx, 4
    and bx, 0x000F
    mov bx, [HEX_TABLE + bx]
    mov [HEX_PATTERN + 4], bl

    mov bx, dx
    and bx, 0x000F
    mov bx, [HEX_TABLE + bx]
    mov [HEX_PATTERN + 5], bl

    mov bx, HEX_PATTERN
    call printString

    pop dx

    ret

    HEX_PATTERN: db "0x****", 0xa, 0xd, 0
    HEX_TABLE: db "0123456789abcdef"