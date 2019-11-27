;**************************************
;
; SNES ASM: WDC 65816 & SPC 700
;
;**************************************

; insert byte sequence at any location
0030: 11 22 33 44 55 66 77 88
0038: de af fa ce de ca fe 12

 ; beware of current mode in mini assembler
.65816 ; to be sure, set cpu explicitly

0000:   lda #12
        sei
        clc
        cmp #14
@label: dec
        bne @label      ; this a comment
        brk 00
        bra @ronre
        wdm 12
@ronre: lda 1234
        bra @label      ; hello world

; from now on we assemble spc700 instructions
.spc700

0020:   mov a,12
@rure:  pcall 12
        bvc @rure
        bbc 12.2,0022