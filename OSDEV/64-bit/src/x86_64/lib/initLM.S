; Function: initLongMode
;
; Purpose: do long mode initialization
; 
initLongMode:
    call detectCPUID
    cmp ax, 0
    je .longModeNotSupported
    call detectLongMode
    cmp ax, 0
    je .longModeNotSupported

    ret

.longModeNotSupported:
    hlt


; Function: detectCPUID
;
; Purpose: detect if the CPUID instruction is supported
; 
; Returns: ax register
;          1 on supported 
;          0 on not supported
detectCPUID:                                    
    ; FLAGS register cannot be moved directly
    ; we use the stack to push/pop the register contents

    push ecx

    pushfd                              ; store the ORIGINAL contents of FLAGS into eax
    pop eax                             

    mov ecx, eax                        ; save a copy of the register

    xor eax, 1 << 21                    ; bit 21 determines if the cpu can use the CPUID instruction

    push eax                            ; pop modified contents into FLAGS
    popfd

    ; At this point the hardware will either
    ; 1. retain the flipped bit or 
    ; 2. flip the bit back

    pushfd                              ; store the UPDATED contents of FLAGS into eax
    pop eax                             

    push ecx                            ; restore the ORIGINAL value of FLAGS that was saved in ecx
    popfd

    cmp eax, ecx
    je .unsupportCpuid

.supportCpuid:
    xor ax, ax                          ; clear ax register
    add ax, 1                           ; 1 is supported
    pop ecx
    ret

.unsupportCpuid:
    xor ax, ax                          ; clear ax register, 0 is unsupported
    pop ecx
    ret

; Function: detectLongMode
;
; Purpose: detect if the long mode is supported
; 
; Returns: ax register
;          1 on supported
;          0 on not supported

detectLongMode:
    mov eax, 0x80000000                 ; Set the eax register to 0x80000000
    cpuid
    cmp eax, 0x80000001                 ; Compare the eax register with 0x80000001
    jb .unsupportLongMode               ; if below, then no long mode

    mov eax, 0x80000001                 ; Set the A-register to 0x80000001
    cpuid
    test edx, 1 << 29                   ; Test if the LM-bit (bit 29) is set in edx
    jz .unsupportLongMode               ; If not set, then no long mode

.supportLongMode:
    xor ax, ax                          ; clear ax register
    add ax, 1                           ; 1 is supported
    ret

.unsupportLongMode:
    xor ax, ax                          ; clear ax register, 0 is supported
    ret
    

