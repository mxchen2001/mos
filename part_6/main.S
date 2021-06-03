[org 0x7c00]
[bits 16]

section .text
    global main

main:
    cli                                     ; clear/disable interrupt
    jmp 0x0000:NULL_SEGMENT_OFFSET          ; forces the jump to NULL_SEGMENT_OFFSET without any possible segment offset

    NULL_SEGMENT_OFFSET:
        ; mov ax, 0                 
        xor ax, ax                              ; toggles ax
                                                ; mov takes 3 bytes and xor takes 2 bytes

        mov ds, ax                              ; clear segment register
        mov es, ax
        mov ss, ax
        mov fs, ax
        mov gs, ax

        mov sp, main                            ; move stack pointer point to main
        cld                                     ; "clear direction" or set to 0
                                                ; cld = read onwards, std = read backwards

    sti                                     ; set/enable interrupt

    push ax
    xor ax, ax
    mov dl, 0x80                            ; hard drive
    int 0x13
    pop ax

    mov si, INIT_MSG
    call printf



        
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

    INIT_MSG:
        db "main has been sucessfully initialized", 0x0a, 0x0d, 0

    

times 510 - ($ - $$) db 0
dw 0xaa55

SECTOR2:
    mov si, TEST
    call printf
    ret
TEST:
    db "You read Sector 2 of the drive!!", 0x0a, 0x0d, 0
times 512 - ($ - SECTOR2) db 0
