[org 0x7e00]

extendedProgram:                                ; print a message to indicate if mapped to memory
    mov bx, READ_DISK_MSG
    call printString

jmp $                                           ; system hang

READ_DISK_MSG:
    db "Successfully read sector 2", 0x0a, 0x0d, 0

; this path is relative to the makefile
%include "./src/lib/printString.S"              ; include printString

; this path is relative to the current file
; %include "./lib/printString.S"                ; include printString
TIMES 2048 - ($ - $$) db 0