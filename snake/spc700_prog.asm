.spc700

.org 0600
.base 0000

Reset:
        clrp
        di
        mov x,#ff       ; x = 0xff
        mov sp,x        ; stack pointer = 0xff

        ; general initialization

        ;Reset, Mute, Echo-Write Flags + Noise Clock FLG
        mov y,#6c
        mov a,#20
        call @WriteDSP

        ;Key On Flags for Voice 0..7 KON
        mov y,#4c
        mov a,#00
        call @WriteDSP

        ;Key Off Flags for Voice 0..7 KOF
        mov y,#5c
        mov a,#ff
        call @WriteDSP

        ;Sample directory offset address DIR
        mov y,#5d
        mov a,#0c
        call @WriteDSP

        ;Key Off Flags for Voice 0..7 KOF
        mov y,#5c
        mov a,#00
        call @WriteDSP

        ; DSP_set NON,      #00
        mov y,#3d
        mov a,#00
        call @WriteDSP

        ; DSP_set EON,      #00
        mov y,#4d
        mov a,#00
        call @WriteDSP

        ; DSP_set MVOLL,    #$7F
        mov y,#0c
        mov a,#7f
        call @WriteDSP

        ; DSP_set MVOLR,    #$7F
        mov y,#1c
        mov a,#7f
        call @WriteDSP

        ; DSP_set EVOLL,    #00
        mov y,#2c
        mov a,#00
        call @WriteDSP

        ; DSP_set EVOLR,    #00
        mov y,#3c
        mov a,#00
        call @WriteDSP


        ; DSP_set V0SRCN,   #$00
        mov y,#04
        mov a,#00
        call @WriteDSP

        ; DSP_set V0VOLL,   #$7f
        mov y,#00
        mov a,#7f
        call @WriteDSP

        ; DSP_set V0VOLR,   #$7f
        mov y,#01
        mov a,#7f
        call @WriteDSP

        ; DSP_set V0GAIN,   #$7f
        mov y,#07
        mov a,#7f
        call @WriteDSP


        ;Play sample
        ; DSP_set V0PITCHL, #<(3000)
        mov y,#02
        mov a,#00
        call @WriteDSP

        ; DSP_set V0PITCHH, #>(3000)
        mov y,#03
        mov a,#30
        call @WriteDSP

        ; DSP_set KON,      #7
        mov y,#4c
        mov a,#07
        call @WriteDSP


; little routine to store value A into DSP register Y
WriteDSP:
        mov f2,y        ; f2 = DSP register to write to
        mov f3,a        ; f3 = value
        ret

.org 0c00
.base 600

.db 04, 0c, 04, 0c

BrrSample:
        .incbin assets/Sample1.brr
