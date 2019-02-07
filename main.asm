.include "include/header.inc"
.include "include/reg.inc"
.import init_reg

OAML_BUF_START = $0100
OAMH_BUF_START = $0300

.p816

.segment "DATA"

character_data:
    .incbin "assets/background.png.vra" ; $800 bytes, $8000
    .incbin "assets/mario.png.vra" ; $800 bytes, $8800
palette_data:
    .incbin "assets/background.png.pal" ; $20 bytes, $9000
    .incbin "assets/mario.png.pal" ; $20 bytes, $9020
tilemap_data:
    .incbin "assets/tilemap.csv.map" ; $800 bytes, $9040


.segment "STARTUP"

reset_stub:
    jml reset_int

nmi_stub:
    jml nmi_int

.segment "CODE"

.proc reset_int
        sei                     ; disable interrupts
        clc                     ; clear the carry flag
        xce                     ; switch the 65816 to native (16-bit mode)
        jsr init_reg

        rep #$10 ; I 16
        sep #$20 ; A 8

        jsr reset_oam_buffer

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
        lda #%00110000 ; OBJ prio 3
        sta OAML_BUF_START, x
        inx
        ; LEGS
        lda #(256/2 - 16)
        sta OAML_BUF_START, x
        inx
        lda #(224/2)
        sta OAML_BUF_START, x
        inx
        lda #$02
        sta OAML_BUF_START, x
        inx
        lda #%00110000 ; OBJ prio 3
        sta OAML_BUF_START, x

        ; reset those two sprites X MSB
        ldx #$0000
        lda #%01010000
        sta OAMH_BUF_START, x
        jsr transfer_oam_buffer

        rep #$30 ; A 16 I 16

        ; transfer background data
        lda #$0000
        ldx #$8000
        ldy #$0800
        jsr transfer_vram

        ;transfer tilemap data
        lda #$2000
        ldx #$9040
        ldy #$0800
        jsr transfer_vram

        ; transfer mario data
        lda #$6000 ; VRAM start addr
        ldx #$8800 ; ROM start addr
        ldy #$0800 ; 800 bytes to transfer
        jsr transfer_vram

        sep #$20 ; A 8
        ; transfer background palette
        lda #$00 ; CGRAM start addr
        ldx #$9000 ; ROM start addr
        ldy #$0020 ; 20 bytes to transfer
        jsr transfer_cgram
        ; transfer mario palette @ CGRAM $80 (first sprite addr)
        lda #$80 ; CGRAM start addr
        ldx #$9020 ; ROM start addr
        ldy #$0020 ; 20 bytes to transfer
        jsr transfer_cgram

        ; set bg mode 1, 16x16 tiles
        lda #%00010001
        sta BGMODE

        ; set tilemap address
        lda #$20
        sta BG1SC

        ; set tileset address for bg 1 and 2
        ; @ $0000
        lda #$00
        sta BG12NBA
        stz BG34NBA

        ; set bg 1 V/H offset to 0
        stz BG1HOFS
        stz BG1VOFS

        ; Set sprite size to 16/32, start @ VRAM $6000
        lda #$63
        sta OBJSEL

        ; enables sprites, BG 1
        lda #%00010001
        sta TM
        ; release forced blanking, set screen to full brightness
        lda #$0f
        sta INIDISP
        ; enable NMI, turn on automatic joypad polling
        lda #$81
        sta NMITIMEN

        ; all initialization is done
        jmp GameLoop
.endproc

.proc nmi_int
    ; read NMI status, acknowledge NMI
    lda RDNMI

    rti
.endproc

.proc GameLoop
    ; wait for NMI / V-Blank
    wai

    jmp GameLoop
.endproc

.proc reset_oam_buffer
    php
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

    plp
    rts
.endproc

; A 8, I 16
.proc transfer_oam_buffer
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

    rts
.endproc

; A16, I16
; A : VRAM start address
; X : ROM start address
; Y : bytes to transfer
.proc transfer_vram
    php
    ; -------------
    ; VRAM DMA TRANSFER
    ; -------------
    ; VRAM insert start address
    sta VMADDL
    ; via VRAM write register 21`18` (B bus address)
    sep #$20 ; A 8
    lda #$18
    sta BBAD0
    ; from rom address (A bus address)
    lda #$02
    sta A1T0B
    stx A1T0L
    ; total number of bytes to transfer
    sty DAS0L
    ; DMA params : A to B, increment, 2 bytes to 2 registers
    lda #%00000001
    sta DMAP0
    ; initiate DMA via channel 0 (LSB = channel 0, MSB channel 7)
    lda #%00000001
    sta MDMAEN

    plp
    rts
.endproc

; A8, I16
; A : CGRAM start address
; X : ROM start address
; Y : bytes to transfer
.proc transfer_cgram
    ; -------------
    ; CGRAM DMA TRANSFER
    ; -------------
    sta CGADD
    lda #$22
    sta BBAD1
    lda #$02
    sta A1T1B
    stx A1T1L
    sty DAS1L
    lda #$00
    sta DMAP1
    lda #$02
    sta MDMAEN

    rts
.endproc
