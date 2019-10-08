# Mini-Assembler

## Examples:

different prompts:

```
* ; indicates normal mode
! ; indicates assembler mode
```

```
*0           ; print byte from address 0
*0..f        ; print bytes from address 0 to f
*300:00 00   ; write bytes 00 00 from address 300
*300g        ; execute from address 300
*300l        ; list (disassemble) next 20 instructions from address 300
*0=m         ; set accumulator to 0/1 when you want to disassemble as 16/8 bits
*0=x         ; set index to 0/1 when you want to disassemble as 16/8 bits
*02/         ; switch to bank 02
*!           ; enter in mini assembler mode by writing a '!'
!300:clc     ; set current address to 300, write clc instruction
!xce         ; when omiting address, auto increment is used
!rep #$30
!            ; press enter with empty line to exit write mode
```
