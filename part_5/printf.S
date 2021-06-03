printf:
    pusha ; this pushes all register to the stack, only availible in 16 bit real mode

    mov ah, 0x0e
    sloop:
        mov al, [si] ; loads al with the contents of si
        cmp al , 0x0
        jne .print_char
    popa
    ret

    .print_char:
        int 0x10
        add si, 1
        jmp sloop