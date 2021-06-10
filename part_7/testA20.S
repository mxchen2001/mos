; The easiest way to check A20 is by checking if wrapping exists
; We will compare an address to a segemented address and check the values 

; The bootloader magic value 0x7c00 + 510 = 0x7dfe
testA20:

    pusha
    
    mov ax, 0x2400
    int 0x15

    mov ax, [0x7dfe]

    mov si, ORIG_A20
    call printf
    mov dx, ax
    call printh

    ; 0xffff0 + offset = 0x100000 => truncates to 0x00000
    ; To get the magic we will do
    ; 0xffff0 + offset = 0x107dfe => truncates to 0x07dfe
    ; offset = 0x7e0e

    push bx
    xor bx, bx     ; set to zero
    not bx
    ; xor + not will set to 0xffff
    ; mov bx, 0xffff
    mov es, bx

    ; mov bx, 0x7dfe ; address of magic
    mov bx, 0x7e0e ; address of magic
    
    mov si, SEG_A20
    call printf
    
    mov dx, [es:bx]
    call printh

    pop bx
    popa

    ret

    ORIG_A20:
        db "Non-seg magic value: ", 0
    SEG_A20:
        db "Segment magic value: ", 0



