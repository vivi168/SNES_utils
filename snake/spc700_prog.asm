.spc700

.org 0600
.base 0000

Reset:
    ; global settings
    mov f2,#6c    ; FLG
    mov f3,#20

    mov f2,#5c    ; KOF
    mov f3,#00

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
    mov f2,#04    ; V0SRCN
    mov f3,#00

    ; Voice 1 settings
    mov f2,#10    ; V1VOLL
    mov f3,#7f
    mov f2,#11    ; V1VOLR
    mov f3,#7f
    mov f2,#17    ; V1GAIN
    mov f3,#7f
    mov f2,#14    ; V1SRCN
    mov f3,#01


MainLoop:
Read2140:
    mov x,f4
    cmp x,f4
    bne @Read2140

    cmp x,#42
    bne @PlayMoonSong
    mov f2,#14
    mov f3,#02

    ; Play Song
PlayMoonSong:
    mov x,#00
    mov y,#0b

song_loop:
    ; V0PITCHL
    mov f2,#02
    mov a,@MoonSong+x
    mov f3,a
    inc x
    ; V0PITCHH
    mov f2,#03
    mov a,@MoonSong+x
    mov f3,a
    inc x

    ; V1PITCHL
    mov f2,#12
    mov a,@MoonSong+x
    mov f3,a
    inc x
    ; V1PITCHH
    mov f2,#13
    mov a,@MoonSong+x
    mov f3,a
    inc x

    ; KON
    mov f2,#4c
    mov a,@MoonSong+x
    mov f3,a
    inc x

    push y
    push x

    mov y,#7f
    call @wait

    pop x
    pop y

    dec y
    cmp y,#00
    bne @song_loop

    mov y,#7f
    call @wait

    jmp @MainLoop

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

MoonSong:
    ; V0PITCH, V1PITCH, KON
    .db 0800, 0800, 03
    .db 0000, 0800, 02
    .db 1c00, 0800, 03
    .db 0000, 0c00, 02
    .db 0800, 1000, 03
    .db 0000, 0c00, 02
    .db 1c00, 0800, 03
    .db 0000, 1000, 02
    .db 0800, 0c00, 03
    .db 0000, 0c00, 02
    .db 1c00, 0800, 03

Drum:
    .incbin assets/drum.brr
BassGuitar:
    .incbin assets/bass_guitar.brr
Bell:
    .incbin assets/bell.brr

.org 5600
.base 5000

BrrDirectory:
    .db @Drum, @Drum
    .db @BassGuitar, @BassGuitar
    .db @Bell, @Bell
