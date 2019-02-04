.include "include/header.inc"
.include "include/reg.inc"
.import init_reg

OAML_BUF_START = $0100
OAMH_BUF_START = $0300

.p816

.segment "DATA"

SpriteData:
    .incbin "assets/background.png.vra" ; $a80 bytes
    .incbin "assets/mario.png.vra" ; $800 bytes
ColorData:
    .incbin "assets/background.png.pal" ; $20 bytes
    .incbin "assets/mario.png.pal" ; $20 bytes

.segment "STARTUP"

NMIStub:
    jml NMIHandler
ResetStub:
    jml ResetHandler

.segment "CODE"

.proc   ResetHandler
        sei                     ; disable interrupts
        clc                     ; clear the carry flag
        xce                     ; switch the 65816 to native (16-bit mode)
        jsr init_reg

        rep #$10
        sep #$20
.a8
.i16

        ; Load dummy data in WRAM, set all sprites at position $101 (out of screen)
        ; first load $01 in all sprites X coord (LSB)
        lda #$01
set_x_lsb:
        sta OAML_BUF_START, x
        inx
        inx
        inx
        inx
        cpx #$0200
        bne set_x_lsb

        ; then, set all sprite X MSB to 1
        lda #$55
set_x_msb:
        sta OAML_BUF_START, x
        inx
        sta OAML_BUF_START, x
        inx
        cpx #$0220
        bne set_x_msb

        ; once that's done, load our sprite data
        ldx #$0000
        ; TORSO
        lda #(256/2 - 16)
        sta OAML_BUF_START, x
        inx
        lda #(224/2 - 16)
        sta OAML_BUF_START, x
        inx
        stz OAML_BUF_START, x
        inx
        stz OAML_BUF_START, x
        inx
        ; LEGS
        lda #(256/2 - 16)
        sta OAML_BUF_START, x
        inx
        lda #(224/2)
        sta OAML_BUF_START, x
        inx
        lda #$20
        sta OAML_BUF_START, x
        inx
        stz OAML_BUF_START, x

        ; reset those two sprites X MSB
        ldx #$0000
        lda #%01010000
        sta OAMH_BUF_START, x

        ; -------------
        ; LOAD our dummy data into OAM via DMA
        ; -------------
        stz OAMADDL
        stz OAMADDH

        lda #$04 ; OAMDATA $21`04`
        sta BBAD0
        ; from WRAM address $7e:0100 (A bus address)
        lda #$7e
        sta A1T0B
        ldx #$0100
        stx A1T0L
        ; total number of bytes to transfer (OAM is $220 bytes)
        ldx #$0220
        stx DAS0L
        ; DMA params : A to B
        lda #$00
        sta DMAP0
        ; initiate DMA via channel 0 (LSB = channel 0, MSB channel 7)
        lda #$01
        sta MDMAEN

        ; -------------
        ; VRAM DMA TRANSFER
        ; -------------
        ; VRAM insert start address
        ldx #$2000
        stx VMADDL
        ; via VRAM write register 21`18` (B bus address)
        lda #$18
        sta BBAD0
        ; from rom address (A bus address)
        lda #$02
        sta A1T0B
        ldx #$8a80 ; starts @ $8000, + bg = $8a80
        stx A1T0L
        ; total number of bytes to transfer
        ldx #$0800
        stx DAS0L
        ; DMA params : A to B, increment, 2 bytes to 2 registers
        lda #%00000001
        sta DMAP0
        ; initiate DMA via channel 0 (LSB = channel 0, MSB channel 7)
        lda #%00000001
        sta MDMAEN

        ; -------------
        ; CGRAM DMA TRANSFER
        ; -------------
        lda #$80
        sta CGADD
        lda #$22
        sta BBAD1
        lda #$02
        sta A1T1B
        ldx #$92a0 ; starts @ $8000, + bg + mario + bg pal = $8ea0
        stx A1T1L
        ldx #$0020
        stx DAS1L
        lda #$00
        sta DMAP1
        lda #$02
        sta MDMAEN

        sep #$30
.a8
.i8
        ; Set sprite size to 16/32, start @ VRAM $2000
        lda #$61
        sta OBJSEL

        ; enables sprites
        lda #$10
        sta TM
        ; release forced blanking, set screen to full brightness
        lda #$0f
        sta INIDISP
        ; enable NMI, turn on automatic joypad polling
        lda #$81
        sta NMITIMEN

        jmp GameLoop            ; all initialization is done
.endproc

.proc   GameLoop
        wai                     ; wait for NMI / V-Blank

        jmp GameLoop
.endproc

.proc   NMIHandler
        lda RDNMI               ; read NMI status, acknowledge NMI

        rti
.endproc
