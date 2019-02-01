.ifndef HEADER_INC
.define HEADER_INC
;-------------------------------------------------------------------------------
;   Interrupt and Reset vectors for the 65816 CPU
;-------------------------------------------------------------------------------

.segment "HEADER" ; start @ FFC0. See manual page 1-2-16
    ;     "abcdefghijklmnopqrstu"
    .byte "SNES PRIMER          " ; ROM Name (21 bits)

.segment "ROMINFO" ; starts @ FFD5 (HEADER + 21 bits)
    .byte $30 ; ROM makeup byte
    .byte $00 ; ROM type
    .byte $09 ; ROM Size
    .byte $00 ; SRAM Size
    .byte $00 ; Locale
    .byte $33 ; License ID
    .byte $00 ; Version #
    .word $AAAA ; complement (bitwise NOT) value of the checksum
    .word $0000 ; checksum (The sum of all bytes in the ROM after a bitwise AND with the value 0xFFFF)

.segment "VECTOR"
    ; Native mode
   .word $0000, $0000
   .word $0000      ; COP
   .word $0000      ; BRK
   .word $0000      ; ABT
   .word NMIHandler ; NMI
   .word $0000      ; RST
   .word $0000      ; IRQ

   ; Emulation mode
   .word $0000, $0000
   .word $0000        ; COP
   .word $0000        ; BRK
   .word $0000        ; ABT
   .word $0000        ; NMI
   .word ResetHandler ; RST
   .word $0000        ; IRQ

.endif

.segment "STARTUP"
NMIStub:
    jml NMIHandler
ResetStub:
    jml ResetHandler
