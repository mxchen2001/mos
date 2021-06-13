# OS Dev

### Moving to 64-bit

Now that we have moved from 16-bit real mode to 32-bit protected mode, we will now attempt to enter 64-bit Long Mode. Things that we will do to setup long mode include:
1. Detect if long mode is supported, checking [CPUID](https://wiki.osdev.org/CPUID)
2. Set up [paging](https://wiki.osdev.org/Setting_Up_Paging) and [PAE](https://wiki.osdev.org/Setting_Up_Paging_With_PAE) for long mode.
3. Enter long mode.
4. Set up the [GDT](https://wiki.osdev.org/GDT) for long mode


### Long Mode Support
#### CPUID Support

The `CPUID` instruction can retrieve various information about you processor, one of which is if long mode is supported. 

First we have to check if CPUID is supported, we have to flip a bit in the [FLAGS](https://en.wikipedia.org/wiki/FLAGS_register) register and see if the bit remains flipped.
```nasm
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
```

#### Long Mode Support
We can check for long mode support by using the `CPUID` function after we have confirmed that it is working.

```nasm
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
```

### Set up Paging
In 64-bit mode, the virtual memory is split into 4 levels.
```
    Page Map Level 4
    +----------+
    |          | -+
    +----------+  |
    ~  ....... ~  |
    +----------+  |
    |          |  |
    +----------+  |
                  |     Page Directory Pointer Table
                  +-->  +----------+
                        |          | -+
                        +----------+  |
                        ~  ....... ~  |
                        +----------+  |
                        |          |  |
                        +----------+  |
                                      |     Page Directory Table
                                      +-->  +----------+
                                            |          | -+
                                            +----------+  |
                                            ~  ....... ~  |
                                            +----------+  |
                                            |          |  |
                                            +----------+  |
                                                          |     Page Table
                                                          +-->  +----------+
                                                                |          | ---> Physical Mem
                                                                +----------+
                                                                ~  ....... ~
                                                                +----------+
                                                                |          |
                                                                +----------+
```

For a direct mapping or identity mapping, we will need 4 pages (each 4 KiB) or 16384 B of memory. 

We will allocated the page tables starting at the following values. 
- PML4T - `0x1000`
- PDPT - `0x2000`
- PDT - `0x3000`
- PT - `0x4000` (We will construct 512 Page tables to give access 2 MB of Memory)