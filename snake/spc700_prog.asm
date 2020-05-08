.spc700

.org 0600
.base 0000

Reset:
    mov   f2,#6c    ; FLG
    mov   f3,#20

    mov   f2,#4c    ; KON
    mov   f3,#00

    mov   f2,#5c    ; KOF
    mov   f3,#ff

    mov   f2,#5d    ; DIR
    mov   f3,#>BrrDirectory

    mov   f2,#5c    ; KOF
    mov   f3,#00

    mov   f2,#3d    ; NON
    mov   f3,#00

    mov   f2,#4d    ; EON
    mov   f3,#00

    mov   f2,#0c    ; MVOLL
    mov   f3,#7f

    mov   f2,#1c    ; MVOLR
    mov   f3,#7f

    mov   f2,#2c    ; EVOLL
    mov   f3,#00

    mov   f2,#3c    ; EVOLR
    mov   f3,#00

    mov   f2,#04    ; V0SRCN
    mov   f3,#00

    mov   f2,#00    ; V0VOLL
    mov   f3,#7f

    mov   f2,#01    ; V0VOLR
    mov   f3,#7f

    mov   f2,#07    ; V0GAIN
    mov   f3,#7f

    mov   f2,#02    ; V0PITCHL
    mov   f3,#b8

    mov   f2,#03    ; V0PITCHR
    mov   f3,#0b

    mov   f2,#4c    ; KON
    mov   f3,#07

loop:
    jmp   @loop


BrrSample:
    .incbin assets/Sample1.brr


.org 3600
.base 3000

BrrDirectory:
    .db @BrrSample, @BrrSample