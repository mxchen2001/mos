; The easiest way to check A20 is by checking if wrapping exists
; We will compare an address to a segemented address and check the values 

; The bootloader magic value 0x7c00 + 510 = 0x7dfe

; Function: printString
;
; Purpose: to print a null terminated string using bios calls
; 
; Returns: 1 on disable
;          0 on disabled
testA20:
    pusha

    mov ax, [0x7dfe]

    ; mov bx, ORIG_A20
    ; call printString

    ; mov bx, ax
    ; call printHex

    ; 0xffff0 + offset = 0x100000 => truncates to 0x00000
    ; To get the magic we will do
    ; 0xffff0 + offset = 0x107dfe => truncates to 0x07dfe
    ; offset = 0x7e0e

    xor bx, bx      ; set to zero
    not bx
                    ; xor + not will set to 0xffff
                    ; mov bx, 0xffff
    
    
    mov es, bx

    ; mov bx, 0x7dfe ; address of magic
    
    ; mov bx, SEG_A20
    ; call printString
    
    mov bx, 0x7e0e ; address of magic
    mov bx, [es:bx]
    mov dx, bx
    ; call printHex

    cmp ax, dx
    je .cont_1

    jmp .exit_enable

.cont_1:
    ; mov bx, ORIG_A20
    ; call printString

    mov ax, [0x7dff]
    ; mov bx, ax
    ; call printHex

    push bx
    mov bx, 0xffff
    mov es, bx
    pop bx

    ; mov bx, SEG_A20
    ; call printString

    mov bx, 0x7e0f
    mov bx, [es:bx]
    mov dx, bx
    ; call printHex
    
    cmp ax, dx
    je .exit_disable
    
    jmp .exit_enable

.exit_enable:
    popa
    mov ax, 1
    ret

.exit_disable:
    popa
    mov ax, 0
    ret


    ORIG_A20:
        db "Non-seg magic value: ", 0
    SEG_A20:
        db "Segment magic value: ", 0



