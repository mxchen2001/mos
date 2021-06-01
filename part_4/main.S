[org 0x7c00]


mov si, STR
call printf

mov al, 0x01      ; read a single sector
mov cl, 0x02      ; starting sector, read next sector. Boot sector is 0x01
call read_disk

call SECTOR2 ; note this only works because the segment buffer is 0

jmp $     ; infinite will loop

%include "./printf.S"
%include "./read_disk.S"

STR:
    db "Mike OS is currently in 16-bit Real Mode.", 0x0a, 0x0d, "Sorry currently does nothing", 0x0a, 0x0d, 0
    ; db "Hello World", 0 ; a null terminated string

times 510 - ($ - $$) db 0
dw 0xaa55

SECTOR2:
    mov si, TEST
    call printf
    ret
TEST:
    db "You read Sector 2 of the drive!!", 0x0a, 0x0d, 0
times 512 - ($ - SECTOR2) db 0
