SECTOR_SIZE equ 512
BOOT_SECTOR equ 0x7c00

PROGRAM_SPACE equ (SECTOR_SIZE + BOOT_SECTOR)

; Function: readDisk
;
; Purpose: read sectors of a boot disk disk
; 
; Params: bx - memory buffer address
;         al - sector count  
;         dl - drive number  
;         cl - drive number  

readDisk:
    mov bx, PROGRAM_SPACE               ; buffer address pointer
    mov al, 4                           ; sector count to be read
    mov dl, [BOOT_DISK_NO]              ; the drive number to read from
    mov cl, 2                           ; sector number to be read
    
    mov dh, 0                           ; starting head
    mov ch, 0                           ; starting cylinder

    mov ah, 0x02                        ; indicate read sectors from drive functions
    int 0x13                            ; disk service interrupt

    jc .disk_error

    ret

.disk_error:
    mov bx, DISK_ERR_MSG
    call printString
    hlt

DISK_ERR_MSG:
    db "Disk Read Failed", 0x0a, 0x0d, 0

BOOT_DISK_NO:
    db 0