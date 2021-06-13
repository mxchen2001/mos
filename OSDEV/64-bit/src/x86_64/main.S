; [org 0x7e00]
[bits 16]
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
    jmp codeSegment:ProtectedMode32             ; Perform far jump to code selector


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
 
ProtectedMode32:
    mov ax, dataSegment                     ; load data segment

    mov ds, ax                              ; set segment register
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

    mov [0xb8000], byte 'H'
    mov [0xb8002], byte 'i'

    call initLongMode
    call initPaging
    call initGDT64

    jmp codeSegment:LongMode64
    jmp $

[bits 64]
[extern k_start]

LongMode64:

    ; clear screen function
    mov edi, 0xb8000
    mov rax, 0x1f201f201f201f20
    mov ecx, 500
    rep stosq

    call k_start

    jmp $


; this path is relative to the makefile
[bits 16]
%include "./src/x86_64/lib/print.S"             ; include print functions
%include "./src/x86_64/lib/testA20.S"           ; include testA20
%include "./src/x86_64/lib/initGDT.S"           ; include GDT init functions
[bits 32]
%include "./src/x86_64/lib/initLM.S"            ; include Long Mode init functions
%include "./src/x86_64/lib/initPaging.S"        ; include Paging init functions

; this path is relative to the current file
; [bits 16]
; %include "./lib/print.S"                      ; include print functions
; %include "./lib/testA20.S"                    ; include testA20
; %include "./lib/initGDT.S"                    ; include GDT init functions
; [bits 32]
; %include "./src/lib/initLM.S"                 ; include Long Mode init functions
; %include "./src/lib/initPaging.S"             ; include Paging init functions

[bits 16]
TIMES 2048 - ($ - $$) db 0