[org 0x7e00]

initProtectedMode:
    mov bx, TESTING_A20_MSG
    call printString

    call .disableA20                            ; disable A20 line
    call testA20                                ; test A20 line
    cmp ax, 0                                   ; 0 is disable
    jne .failure_message
    call .success_message

    
    mov bx, ENABLE_A20_MSG
    call printString

    call .enableA20                             ; enable A20 line
    call testA20                                ; test A20 line
    cmp ax, 1                                   ; 1 is disable
    jne .failure_message
    call .success_message
    
    mov bx, LOADING_GDT_MSG
    call printString

    cli                                         ; disable/clear interrupts
    lgdt [gdtDescriptor]                        ; load GDT
    mov eax, cr0
    or eax, 1                                   ; set PE (Protection Enable) bit in CR0 (Control Register 0)
    mov cr0, eax
    jmp 08h:SetSegementRegs                     ; Perform far jump to code selector


.enableA20:
    in al, 0x92
    or al, 2
    out 0x92, al
    ret

.disableA20:
    mov ax, 0x2400
    int 0x15
    ret 

.failure_message:
    mov bx, FAILURE_MSG
    call printString
    jmp $

.success_message:
    mov bx, SUCCESS_MSG
    call printString
    ret
    
FAILURE_MSG:
    db "Failure!!!", 0x0a, 0x0d, 0
SUCCESS_MSG:
    db "SUCCESS!!!", 0x0a, 0x0d, 0


ENABLE_A20_MSG:
    db "Enabling A20 line...", 0
TESTING_A20_MSG:
    db "Testing A20 line...",  0
LOADING_GDT_MSG:
    db "Loading Global Descriptor Table...", 0x0a, 0x0d, 0

[bits 32]
 
SetSegementRegs:
    mov ax, dataSegment                     ; load data segment

    mov ds, ax                              ; set segment register
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

    mov [0xb8000], byte 'H'
    mov [0xb8002], byte 'i'

    jmp $

[bits 16]

; this path is relative to the makefile
%include "./src/lib/print.S"                    ; include print functions
%include "./src/lib/testA20.S"                  ; include testA20
%include "./src/lib/initGDT.S"                  ; include GDT

; this path is relative to the current file
; %include "./lib/print.S"                      ; include print functions
; %include "./lib/testA20.S"                    ; include testA20
; %include "./lib/initGDT.S"                    ; include GDT

TIMES 2048 - ($ - $$) db 0