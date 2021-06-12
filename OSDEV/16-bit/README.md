# OS Dev

### Bootloader

1. The bootloader starts at `0x7c00` which can be declared using the `[org 0x7c00]`
2. We need to intialize the stack by giving the stack a **base pointer** and **stack pointer** that points to the start of the boot sector.
3. We need to pad the bootloader to be exactly 1 sector or 512 bytes
4. We need to end the sector with a magic value indicating that it is a boot sector.
5. Let the system hang to prevent unwanted execution of uninitialized memory
```nasm
[org 0x7c00]                       ; declare starting address

mov bp, 0x7c00                      ; initialize base pointer
mov sp, bp                          ; initialize stack pointer

hang: jmp hang                      ; system hang

TIMES 510 - ($ - $$) db 0           ; zero pad the sector to make boot sector 512 bytes

dw 0xaa55                           ; magic value
```

The Bootloader is 
![Boot sector Location](../Documentation/assets/bootsectorlocation.png)

### Print Subroutine
We want to create a subroutine that prints characters to the screen.

1. We define strings as null terminated character arrays.
2. We will use the `int 0x10` BIOS interrupt (video service interrupt).
3. We will set the video mode to teletype by setting `ah` to `0x0e`
4. Implement standard subroutine practices
5. Include inside `main.S` to allow main to access subroutine.

```nasm

;================== main.S ===================

[org 0x7c00]                       ; declare starting address

mov bp, 0x7c00                      ; initialize base pointer
mov sp, bp                          ; initialize stack pointer


mov bx, HELLO_WORLD
call printString

hang: jmp hang                      ; system hang

HELLO_WORLD:
    dw "Hello World!", 0

TIMES 510 - ($ - $$) db 0           ; zero pad the sector to make boot sector 512 bytes

dw 0xaa55                           ; magic value


;================== printString.S ===================

; Function: printString
;
; Purpose: to print a null terminated string using bios calls
; 
; Params: starting string address in register `bx`

printString:
    pusha                               ; save contents of registers

    mov ah, 0x0e                        ; indicate teletype output
    .print_loop:
        mov al, [bx]                        ; loads starting address of string
        cmp al , 0x0                        
        je .print_exit                      ; break if null

        int 0x10                            ; video service interrupt
        add bx, 1                           ; increment pointer
        jmp print_loop

    .print_exit:
    popa                                ; restore contents of registers
    ret                                 
```

### Read from disk
We want to load additional sectors beyond just the boot sector. We will use a BIOS interrupt `int 0x13`, the disk service interrupt. We indicate to perform **read disk** by setting register `ah` to `0x02`. 

The registers will include:
| Registers | Parameters                                        |
|-----------|---------------------------------------------------|
| ah        | 0x02 (Read Disk routine)                          |
| al        | Number of Sectors to Read                         |
| ch        | Cylinder Number                                   |
| dh        | Head Number                                       |
| dl        | Drive Number                                      |
| ex:bx     | Buffer Address Pointer (Where to store data)      |

| Registers  | Return Val                  |
|------------|-----------------------------|
| cf (carry) | Set on Error, else No Error |
| ah         | Return Code                 |
| al         | Actual Sectors Read Count   |

You can view details of the return codes [here](https://en.wikipedia.org/wiki/INT_13H#INT_13h_AH=01h:_Get_Status_of_Last_Drive_Operation)


Here is a diagram:

```
Disk:

        +----------+    <- start of boot sector
        | Sector 1 |<- main.S, diskRead.S, printString.S
        +----------+    <- start of extended program
        | Sector 2 |<- program.S
        +----------+
        | Sector 3 |  
        +----------+
        | Sector 4 |  
        +----------+ \
        | Sector 5 | |
        +----------+ |
        | Sector 6 | |  <-  currently unallocated disk
        +----------+ |
        ~  ....... ~ |
        +----------+ /

Memory:

   0x0000   +--------+  <- start of physical memory
            |        |  
            +--------+
            ~  ..... ~
   0x7c00   +--------+  <- start of bootloader
            |        |  
            |     <---- Sector 1 is mapped here
            |        |  
   0x7e00   +--------+  <- start program space
            |        |  
            |        |  
            |     <---- Sector 2, 3, 4 is mapped here
            |        |  
            |        |  
   0x8000   +--------+  <- end program space
            ~  ..... ~
            +--------+
```

We will create a file `diskRead.S` that will load in sectors 2, 3, 4 and map the sectors to `0x7e00` to `0x8000`.

```nasm
; Some compile time variable i.e. #defines

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
;         
; Note  the example has predefine values for each parameter


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

BOOT_DISK_NO:                           ; the disk number of the boot drive is saved here
    db 0
```