.spc700

.org 0600
.base 0000

Reset:
        clrp
        di
        mov x,#ff       ; x = 0xff
        mov sp,x        ; stack pointer = 0xff

        ; general initialization

        mov a,#00

        mov y,#2c
        call @WriteDSP  ; zero echo vol
        mov y,#3c
        call @WriteDSP

        mov y,#3d
        call @WriteDSP  ; disable noise

        mov y,#4c
        call @WriteDSP  ; zero key on

        mov y,#5c
        call @WriteDSP  ; zero key off

        mov a,#20
        mov y,#6c
        call @WriteDSP  ; noise off, echo buffer writes off

        mov a,#00
        mov y,#0d
        call @WriteDSP  ; zero echo feedback vol

        mov y,#2d
        call @WriteDSP  ; disable pitch modulation

        mov y,#4d
        call @WriteDSP  ; disable echo

        mov a,#d0
        mov y,#6d
        call @WriteDSP  ; echo buffer out of the way

        mov a,#7f
        mov y,#0c
        call @WriteDSP  ; master vol max (left)
        mov y,#1c
        call @WriteDSP  ; master vol max (right)

        ; channel 0 initialization

        mov a,#3f
        mov y,#07
        call @WriteDSP  ; channel 0 gain
        mov a,#30
        mov y,#00
        call @WriteDSP  ; channel 0 vol (left)
        mov y,#01
        call @WriteDSP  ; channel 0 vol (right)
        ; pitch: 32000 hz
        mov a,#00
        mov y,#02
        call @WriteDSP  ; pitch low byte
        mov a,#10
        mov y,#03
        call @WriteDSP  ; pitch high byte

        ; channel 1 initialization
        mov a,#3f
        mov y,#17
        call @WriteDSP  ; channel 1 gain
        mov a,#30
        mov y,#10
        call @WriteDSP  ; channel 1 vol (left)
        mov y,#11
        call @WriteDSP  ; channel 1 vol (right)
        ; pitch: 32000 hz
        mov a,#00
        mov y,#12
        call @WriteDSP  ; pitch low byte
        mov a,#10
        mov y,#13
        call @WriteDSP  ; pitch high byte

        mov a,#0c
        mov y,#5d
        call @WriteDSP  ; brr directory

        mov a,#00
        mov y,#04
        call @WriteDSP  ; brr index channel 0

Main:
        mov a,#16
        jmp @Main

; little routine to store value A into DSP register Y
WriteDSP:
        mov f2,y        ; f2 = DSP register to write to
        mov f3,a        ; f3 = value
        ret

.org 0c00
.base 600

.db 02, c0

BrrSample:
        .incbin assets/Sample1.brr
