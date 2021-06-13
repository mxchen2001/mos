PAGE_TABLE_START equ 0x1000

; macro that defines an address to a uint32_t
%define set_flag(a) (a + 3) 

initPaging:
    push ebp

    mov edi, PAGE_TABLE_START           ; Set the destination index to 0x1000.
    mov cr3, edi                        ; Set cr3 to start of PML4T

    ; ==================================
    ; Page Map Level 4 Table at 0x1000
    ; ==================================

    ; mov eax, edi                        
    ; call clearPage                      ; Clear PML4T (0x1000 - 0x1FFF)

    mov DWORD [edi], set_flag(0x2000)   ; Set the uint32_t at [0x1000] to 0x2000 + flag bit.
                                        ; PML4T[0] will point to PDPT[0]

    add edi, 0x1000                     ; increment destination index to PDPT (0x2000)

    ; ==================================
    ; Page Directory Pointer Table at 0x2000
    ; ==================================

    ; mov eax, edi                                                
    ; call clearPage                      ; Clear PDPT (0x2000 - 0x2FFF)

    mov DWORD [edi], set_flag(0x3000)   ; Set the uint32_t at [0x2000] to 0x3000 + flag bit.
                                        ; PDPT[0] will point to PDT[0]

    add edi, 0x1000                     ; increment destination index to PDT (0x3000)

    ; ==================================
    ; Page Directory Table at 0x3000
    ; ==================================

    ; mov eax, edi                                                
    ; call clearPage                      ; Clear PDT (0x3000 - 0x3FFF)

    mov DWORD [edi], set_flag(0x4000)   ; Set the uint32_t at [0x3000] to 0x4000 + flag bit.
                                        ; PDT[0] will point to PT[0]

    
    add edi, 0x1000                     ; increment destination index to PT (0x4000)

    ; ==================================
    ; Page Table
    ; ==================================

    mov ebx, 0x00000003                 ; Set the ebx to 0x00000003, the flag bits of Page Table Entry
    mov ecx, 512                        ; Set loop sentinal
 
.SetPTE:
    mov DWORD [edi], ebx                ; Set the uint32_t at the destination index to the B-register
    add ebx, 0x1000                     ; Increment ebx to the next page
    add edi, 8                          ; Increment destination index with sizeof(uint32_t)
    loop .SetPTE                        ; Set the next entry


    ; Enable PAE-paging by setting the bit 5 of control register 4

    mov eax, cr4                        ; Read CR4 contents
    or eax, 1 << 5                      ; Set the PAE-bit
    mov cr4, eax                        ; Write to CR4 with updated contents  

    ; Set long-mode bit in EFER register
    mov ecx, 0xC0000080                 ; Set the ecx to 0xC0000080, EFER's model-specific register
    rdmsr                               ; Read from the model-specific register
    or eax, 1 << 8                      ; Set the long-mode bit
    wrmsr                               ; Write to model-specific register with updated contents (in eax)

    ; Enabling paging

    mov eax, cr0                        ; Read CR0 to eax
    or eax, 1 << 31                     ; Set the PG-bit
    mov cr0, eax                        ; Write to CR0 with updated contents

    pop ebp

    ret

; Function: clearPage
;
; Purpose: Clear a single page starting at specified address
; 
; Params: The starting address in eax
; 
clearPage:
    mov edi, eax                        ; Set the destination index register to input starting address
    xor eax, eax                        ; clear eax
    mov ecx, 4096                       ; set ecx 4096 or 1 page
    rep stosd                           ; clear [ecx] times starting at [edi] where ecx is decremented and edi is incremented
    mov edi, eax                        ; restore edi register
    ret

