# Mini-Assembler

Welcome to my "clone" of Apple 2's system monitor/mini assembler.

## Normal mode / System monitor

In this mode, you will be able to examine (hexdump) any area of the file currently loaded.

You will also be able to disassemble any address, as well as replace data directly, or read and insert an external file as anywhere.

### Examine location

syntax: xxxx

Let you examine a single byte at specified address in current bank.

example:

```
(1=m 1=x)*ffec
E9
```

### Examine range

Syntax: `xxxx.xxxx`

Let you examine a multiple bytes from and to specified addresses in current bank.

Start and end addresses are separated by 1 (ore more) dot.

example:

```
(1=m 1=x)*ffe0.ffff
00/FFE0- 1B F0 02 A9 14 85 11 AF
00/FFE8- 6D F3 7E 38 E9 08 8F 6D
00/FFF0- F3 7E C9 A8 90 06 A9 00
00/FFF8- 8F 6D F3 7E 6B FF FF FF
```

### Disassemble from address

Syntax: `xxxxl`

Disassemble next 20 instructions starting at specified address. The adress of the next instruction after the last disassembled is remembered, and if no address is specified (typing `l` only), will disassemble from there. (Reset to 0 when switching bank).

example:

```
(1=m 1=x)*2cl
00/002C: 20 C0 87              JSR 87C0
00/002F: A9 81                 LDA #81
00/0031: 8D 00 42              STA 4200
00/0034: A5 12                 LDA 12
00/0036: F0 FC                 BEQ 0034 {-04}
[...]
```

### Switch bank

Syntax: `xx/`

Switch current bank

Example:

```
(1=m 1=x)*01/
```

### Flip flags

Syntax: `x=(m|x)`

Let you switch the accumulator and index register to 8 or 16 bits

* 0 indicates 16 bits
* 1 indicates 8 bits

Example:

```
(1=m 1=x)*0=m
(0=m 1=x)*
```

### Insert

Syntax: `xxxx:xx xx xx xxxx`

Let you write a byte sequence at specified address. Overwrite or allocate existing data.

Spaces are ignored.

Start address is in current bank. Does not care for bank boundaries

Example:

```
(1=m 1=x)*ffea:00 00 00 0000 0 000 0000000
```

### Incbin

Syntax: `xxxx: .incbin filepath`

Read a binary file and insert it as a byte sequence at specified address. Overwrite or allocate existing data.

Start address is in current bank. Does not care for bank boundaries

Filepath is relative

Example:

```
(1=m 1=x)*2000:.incbin sprite.bin
Inserted 2048 bytes at 00/2000
```

### Read

Syntax: `.read filepath`

Read and attempt to assemble an asm file. Insert the result from current address (or at address specified in the asm file). Overwrite or allocate existing data.

Filepath is relative

If an error is encountered, the faulty line number is returned and read is aborted and no data is ovewritten.

Example:

```
(1=m 1=x)*.read init.asm
00/0000: 78                    SEI
00/0001: 18                    CLC
00/0002: FB                    XCE
00/0003: E2 20                 SEP #20
00/0005: A9 8F                 LDA #8F
00/0007: 8D 00 21              STA 2100
[...]
```

### Write

Syntax: `.write [filepath]`

Write the memory as raw bytes to a file. If no filepath is specified, write to a file named `out.smc`

Example:

```
(1=m 1=x)*.write hello.smc
Written 1048576 bytes to file hello.smc
```

### Mini Assembler

Syntax: `!`

Switch to mini assembler mode.

## Mini Assembler mode

In this mode, any line you type is interpreted as 65816 instruction, and assembled at specified address, if any, or a next address (start at 0, reset to 0 when switching bank). Does not care for bank boundaries (will carry on to next bank).

Immediate feedback is given by printing the disassembly of assembled instruction. In case instruction can't be assembled, an error message is printed.

Syntax: `[xxxx:] xxx xxxx`

To exit mini assembler mode, simply submit an empty line.

Example:

```
(1=m 1=x)*!
(00/0000)!2000:sei
00/2000: 78                    SEI
(00/2001)!clc
00/2001: 18                    CLC
(00/2002)!xce
00/2002: FB                    XCE
(00/2003)!lda #12
00/2003: A9 12                 LDA #12
(00/2005)!
(1=m 1=x)*
```
