# OS Dev

### Moving to 32-bit

On startup, the CPU defaults to 16-bit Real mode. To increase the functionality of the computer, we will switch to 32-bit protected mode. Things that need to be done before we enter protected mode:
1. Disable Interrupts
2. Enable the A20 line
3. Load and set the GDT
4. 
**Disable Interrupts**
Super simple, just do:
```nasm
cli                                     ; disable interrupts
```
### A20
In older intel microprocessors like the 8086 and 8088, the address bus has 20 bits where A19 is MSB and A0 is LSB. This allows for `2^20` bytes if data or 1 Mebibyte. However since the 8086 and 8088 are 16-bits machines, the microprocessor could not reach address past `0xFFFF`. To overcome this, the processors uses segmenting.

The processor used a segment address and offset address such that the memory access was:
```nasm
<segment addr> + <offset addr> = <actual address>

((0x0000) << 4) + 0x3000 = 0x03000
((0xF000) << 4) + 0x3000 = 0xF3000
```

However the problem of overflow occurs. If the address exceeds 20 bits, the address would be truncated. Take the example:
```nasm
((0xF800) << 4) + 0x8000 = 0x100000 ; where the truncated address is 0x00000
```

Note: segment registers cannot be set directly i.e. using the `mov` instruction

This wrapping can be used to index to any point in memory.

The A20 line is the representation of the 21st bit (Bit 20) of a memory address. With the A20 line **disabled** the address will wrap around via being truncated. This is used and a clever way to access certain spots in memory but also restricts the physical memory to be only 1 MB. Therefore for modern operating system the A20 line should be **enable** to allow all of physical memory to be accessed (where the bit 20 is preserved) as we do not want to be restricted to only 1 MB of memory.

To disable the line, 

```nasm
mov ax, 0x2400
int 0x15
```

To enable the line,
```nasm
in al, 0x92
or al, 2
out 0x92, al
```
For more detailed about A20, you can visit [OSDEV](https://wiki.osdev.org/A20_Line).
### GDT

#### GDT Descriptor
The structure of the GDT descriptor is in the form:
```
    0  +--------+  
       |  Size  |  <- (Size of table) - 1
       |        |  
    2  +--------+
       | Offset | 
       |        |  
       |        |  
       |        |  
    6  +--------+
```
#### GDT Entry
The table entries contains 8-byte (double word) entries of the following format
```
GDT Structure:
  63         56 55    52 51         48 47    40 39      32 31        16 15          0
   +-----------+--------+-------------+--------+----------+------------+------------+
   |    Base   | Flags  |    Limit    | Access |   Base   |    Base    |    Limit   |
   |    24:31  |        |    16:19    |  Byte  |   16:23  |    0:15    |    0:15    |
   +-----------+--------+-------------+--------+----------+------------+------------+
```
```
Access Byte:
  47                               40
   +----+-------+---+----+----+----+----+
   | Pr | Privl | S | Ex | DC | RW | Ac | 
   +----+-------+---+----+----+----+----+
   7    6       4   3    2    1    0
```
| Bit   | 1                                               | 0                |
|-------|-------------------------------------------------|------------------|
| Pr    | Present                                         | Not Present      |
| Privl | [rings](https://wiki.osdev.org/Security#Rings)  | N/A              |
| S     | Code/Data Segment                               | System Segment   |
| Ex    | Code Selector                                   | Data Selector    |
| DC    | [Grow Down](https://wiki.osdev.org/Expand_Down) | Grow Up          |
| RW    | Readable for code/ Writable for data            | Not allowed      |
| Ac    | Set to 0, the CPU/hardware will set to 1        | N/A              |

```
Flags:
  55             52
   +----+----+---+---+
   | Gr | Sz | 0 | 0 |
   +----+----+---+---+
   7             4

```
| Bit   | 1                                               | 0                |
|-------|-------------------------------------------------|------------------|
| Gr    | 4 KiB Granularity                               | 1 B Granularity  |
| Sz    | 32 Bit Protected Mode                           | 16 Bit Real Mode |

#### GDT Assembly Code
We will define the GDT as:
```nasm
gdtStart:

gdtNull:
    dd 0
    dd 0
gdtCodeSeg:
    dw 0xffff                           ; limit is entire span of memory

    dw 0x0000                           ; base is the beginning of memory
    db 0x00                             ; middle portion of base

    db 0b10011010                         ; present 
                                        ; kernel priv = 00
                                        ; code/data
                                        ; code 
                                        ; executed by kernel
                                        ; readable;
                                        ; access is always set to 0

    db 0b11001111                         ; 4 KiB Granularity (Page)
                                        ; 32-bit
                                        ; 0
                                        ; 0
                                        ; Max limit

    db 0x00                             ; high portion of base
gdtDataSeg:
    dw 0xffff                           ; limit is entire span of memory

    dw 0x0000                           ; base is the beginning of memory
    db 0x00                             ; middle portion of base

    db 0b10010010                         ; present 
                                        ; kernel priv = 00
                                        ; code/data
                                        ; code 
                                        ; executed by kernel
                                        ; writable;
                                        ; access is always set to 0

    db 0b11001111                         ; 4 KiB Granularity (Page)
                                        ; 32-bit
                                        ; 0
                                        ; 0
                                        ; Max limit

    db 0x00                             ; high portion of base
gdtEnd:

gdtDescriptor:
    gdtSize: dw gdtEnd - gdtStart - 1
    gdtOffset: dd gdtNull
```
For more information about the GDT access/flag bits, you can visit [OSDEV](https://wiki.osdev.org/A20_Line).