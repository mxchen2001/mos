printh:

    mov si, HEX_PATTERN
    call printf

    ret

    HEX_PATTERN: db "0x****", 0xa, 0xd, 0