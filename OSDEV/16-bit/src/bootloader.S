[org 0x7c00]                        ; declare starting address

mov [BOOT_DISK_NO], dl              ; store disk number from dl

mov bp, 0x7c00                      ; initialize base pointer
mov sp, bp                          ; initialize stack pointer


mov bx, HELLO_WORLD
call printString

call readDisk                       ; read addition sectors

jmp bootsector_end                  ; jump to the end of the sector

hang: jmp hang                      ; system hang

HELLO_WORLD:
    db "Hello World!", 0x0a, 0x0d, 0

; this path is relative to the makefile
%include "./src/lib/printString.S"          ; include printString
%include "./src/lib/diskRead.S"             ; include readDisk

; this path is relative to the current file
; %include "./lib/printString.S"          ; include printString
; %include "./lib/diskRead.S"             ; include readDisk

TIMES 510 - ($ - $$) db 0           ; zero pad the sector to make boot sector 512 bytes

dw 0xaa55                           ; magic value
bootsector_end: