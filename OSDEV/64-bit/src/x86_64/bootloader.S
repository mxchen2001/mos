[org 0x7c00]                        ; declare starting address

mov [BOOT_DISK_NO], dl              ; store disk number from dl

mov bp, 0x7c00                      ; initialize base pointer
mov sp, bp                          ; initialize stack pointer

call readDisk                       ; read addition sectors

jmp bootsector_end                  ; jump to the end of the sector/beginning of next sector

hang: jmp hang                      ; system hang

; this path is relative to the makefile
%include "./src/x86_64/lib/print.S"         ; include print functions
%include "./src/x86_64/lib/diskRead.S"      ; include readDisk

; this path is relative to the current file
; %include "./lib/print.S"                  ; include print functions
; %include "./lib/diskRead.S"               ; include readDisk

TIMES 510 - ($ - $$) db 0           ; zero pad the sector to make boot sector 512 bytes

dw 0xaa55                           ; magic value
bootsector_end: