read_disk:
    pusha
    mov ah, 0x02
    mov dl, 0x80      ; hard drive
    mov ch, 0x00      ; starting cylinder
    mov dh, 0x00      ; starting head
    ; mov al, 0x01      ; read a single sector
    ; mov cl, 0x02      ; starting sector, read next sector. Boot sector is 0x01

    push bx
    mov bx, 0
    mov es, bx        ; segment offset is 0
    pop bx
    mov bx, 0x7c00 + 512

    int 0x13          ; disk read interrupt

    jc .disk_error

    popa
    ret

    .disk_error:
        mov si, DISK_ERR
        call printf
        jmp $

DISK_ERR:
    db "Read error, drive failure or sector does not exist", 0x0a, 0x0d, 0  ; 0x0a is carriage return
                                                                            ; 0x0d is reset 'x' space