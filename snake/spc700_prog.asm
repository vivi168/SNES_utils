.spc700

.org 0600
.base 0000

Reset:
        clrp
        di
        mov x,#ff       ; x = 0xff
        mov sp,x        ; stack pointer = 0xff

        mov a,#00

        mov y,#0c       ; master volume left
        call @WriteDSP

        mov y,#1c       ; master volume right
        call @WriteDSP

        mov y,#2c       ; echo volume right
        call @WriteDSP

        mov y,#3c       ; echo volume right
        call @WriteDSP

        mov y,#2d       ; pitch modulation, all voices
        call @WriteDSP

        mov y,#3d       ; noise enable flag, all voices
        call @WriteDSP

        mov y,#4d       ; echo enable flag, all voices
        call @WriteDSP

        mov a,#1b
        mov y,#5d       ; sample directory offset address (1b00)
        call @WriteDSP

        jmp ffc0

; little routine to store A to DSP register Y
WriteDSP:
        mov f2,y
        mov f3,a
        ret
