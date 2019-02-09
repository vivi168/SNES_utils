.include "include/reg.inc"
.include "include/macros.inc"
.include "include/header.inc"
.import init_reg

.segment "DATA"
    .incbin "assets/background.png.vra" ; $800 bytes, $8000
    .incbin "assets/mario.png.vra" ; $800 bytes, $8800
    .incbin "assets/background.png.pal" ; $20 bytes, $9000
    .incbin "assets/mario.png.pal" ; $20 bytes, $9020
    .incbin "assets/tilemap.tmx.map" ; $800 bytes, $9040

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

        reset_oam_buffer

        ; once that's done, load our sprite data
        ldx #$0000
        ; TORSO
        lda #$10
        sta OAML_BUF_START, x
        inx
        lda #(224-48)
        sta OAML_BUF_START, x
        inx
        stz OAML_BUF_START, x
        inx
        lda #%00110000 ; OBJ prio 3
        sta OAML_BUF_START, x
        inx
        ; LEGS
        lda #$10
        sta OAML_BUF_START, x
        inx
        lda #(224-32)
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

        transfer_oam_buffer

        ; transfer background data
        transfer_vram #$0000, #$02, #$8000, #$0800
        ;transfer tilemap data
        transfer_vram #$2000, #$02, #$9040, #$0800
        ; transfer mario data
        transfer_vram #$6000, #$02, #$8800, #$0800

        ; transfer bg color data
        transfer_cgram #$00, #$02, #$9000, #$0020
        ; transfer mario color data
        transfer_cgram #$80, #$02, #$9020, #$0020

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
