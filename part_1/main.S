mov ah, 0x0e
mov al, 'A'

; display interrupt
int 0x10

; infinite will loop
jmp $

times 510 - ($ - $$) db 0
dw 0xaa55