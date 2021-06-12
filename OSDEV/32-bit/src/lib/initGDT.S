gdtStart:

gdtNull:
    dd 0
    dd 0
gdtCodeSeg:
    dw 0xffff                           ; limit is entire span of memory

    dw 0x0000                           ; base is the beginning of memory
    db 0x00                             ; middle portion of base

    db 0b10011010                       ; present 
                                        ; kernel priv = 00
                                        ; code/data
                                        ; code 
                                        ; executed by kernel
                                        ; readable;
                                        ; access is always set to 0

    db 0b11001111                       ; 4 KiB Granularity (Page)
                                        ; 32-bit
                                        ; 0
                                        ; 0
                                        ; Max limit

    db 0x00                             ; high portion of base
gdtDataSeg:
    dw 0xffff                           ; limit is entire span of memory

    dw 0x0000                           ; base is the beginning of memory
    db 0x00                             ; middle portion of base

    db 0b10010010                       ; present 
                                        ; kernel priv = 00
                                        ; code/data
                                        ; code 
                                        ; executed by kernel
                                        ; writable;
                                        ; access is always set to 0

    db 0b11001111                       ; 4 KiB Granularity (Page)
                                        ; 32-bit
                                        ; 0
                                        ; 0
                                        ; Max limit

    db 0x00                             ; high portion of base
gdtEnd:

gdtDescriptor:                          
    gdtSize: dw gdtEnd - gdtStart - 1
    gdtOffset: dd gdtNull

codeSegment equ gdtCodeSeg - gdtNull

dataSegment equ gdtDataSeg - gdtNull