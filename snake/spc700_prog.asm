.spc700

.org 0600
.base 0000

Reset:
    ; global settings
    mov f2,#6c    ; FLG
    mov f3,#20

    mov f2,#5d    ; DIR
    mov f3,#>BrrDirectory

    mov f2,#3d    ; NON
    mov f3,#00

    mov f2,#4d    ; EON
    mov f3,#00

    mov f2,#0c    ; MVOLL
    mov f3,#7f

    mov f2,#1c    ; MVOLR
    mov f3,#7f

    mov f2,#2c    ; EVOLL
    mov f3,#00

    mov f2,#3c    ; EVOLR
    mov f3,#00


    ; Voice 0 settings
    mov f2,#00    ; V0VOLL
    mov f3,#7f
    mov f2,#01    ; V0VOLR
    mov f3,#7f
    mov f2,#07    ; V0GAIN
    mov f3,#7f
    mov f2,#02    ; V0PITCHL
    mov f3,#00
    mov f2,#03    ; V0PITCHH
    mov f3,#10

    ; Voice 1 settings
    mov f2,#10    ; V1VOLL
    mov f3,#7f
    mov f2,#11    ; V1VOLR
    mov f3,#7f
    mov f2,#17    ; V1GAIN
    mov f3,#7f
    mov f2,#12    ; V1PITCHL
    mov f3,#00
    mov f2,#13    ; V1PITCHH
    mov f3,#10

; target song
; main (bass): c-4 . c-4 . c-4 . d-4 . e-4 . d-4 . c-4 . e-4 . d-4 . d-4 . c-4 ....
; rythm (drum): c-4 .. d-5 ..

    ; Play Sample
    mov f2,#14    ; V1SRCN
    mov f3,#00

    mov f2,#04    ; V0SRCN
    mov f3,#01
    mov f2,#4c    ; KON
    mov f3,#03

    mov y,#7f
    call  @wait

    mov f2,#02    ; V0PITCHL
    mov f3,#00
    mov f2,#03    ; V0PITCHH
    mov f3,#0d

    mov f2,#4c    ; KON
    mov f3,#03

    mov y,#7f
    call  @wait

    mov f2,#14    ; V1SRCN
    mov f3,#01
    mov f2,#4c    ; KON
    mov f3,#02

    mov y,#7f
    call @wait

loop:
    jmp @loop

wait:
    mov x,#ff
wait_loop:
    nop
    nop
    nop
    dec x
    bne @wait_loop
    dec y
    bne @wait_loop
    ret

Drum:
    .incbin assets/drum.brr
BassGuitar:
    .incbin assets/bass_guitar.brr

.org 5600
.base 5000

BrrDirectory:
    .db @Drum, @Drum
    .db @BassGuitar, @BassGuitar
