[org 0x7c00]


mov si, STR
call printf

mov al, 0x01      ; read a single sector
mov cl, 0x02      ; starting sector, read next sector. Boot sector is 0x01
call read_disk

call SECTOR2 ; note this only works because the segment buffer is 0

jmp $     ; infinite will loop

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

STR:
    db "Mike OS is currently in 16-bit Real Mode.", 0x0a, 0x0d, "Sorry currently does nothing", 0x0a, 0x0d, 0
    ; db "Hello World", 0 ; a null terminated string

DISK_ERR:
    db "Read error, drive failure or sector does not exist", 0x0a, 0x0d, 0  ; 0x0a is carriage return
                                                                            ; 0x0d is reset 'x' space

times 510 - ($ - $$) db 0
dw 0xaa55

SECTOR2:
    mov si, TEST
    call printf
    ret
TEST:
    db "You read Sector 2 of the drive!!", 0x0a, 0x0d, 0
times 512 - ($ - SECTOR2) db 0
