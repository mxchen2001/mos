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
