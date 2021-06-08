printh:
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

    mov si, HEX_PATTERN
    call printf

    ret

    HEX_PATTERN: db "0x****", 0xa, 0xd, 0
    HEX_TABLE: db "0123456789abcdef"