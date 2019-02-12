.include "include/reg.inc"
.include "include/macros.inc"
.include "include/header.inc"
.import init_reg

; TODO : find a better way to define ram location
; .segement ZEROPAGE, .byte/.word ?
PLAYER_SX   = $0001
BGH_SCRL    = $0002
BGH_SCRH    = $0003
BGV_SCRL    = $0004
DIRECTION   = $0005
PLAYER_MXL  = $0006
PLAYER_MXH  = $0006
JOY1_RAWL   = $0010
JOY1_RAWH   = $0011
JOY1_HELDL  = $0012
JOY1_HELDH  = $0013
JOY1_PRESSL = $0014
JOY1_PRESSH = $0015

.segment "DATA"
    .incbin "assets/background.png.vra" ; $800 bytes, $8000
    ; TODO : Sprite look up table (for animations)
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
    stx PLAYER_MXL
    lda #$00
    sta PLAYER_SX
    ldx #$0000
    ; TORSO
    lda PLAYER_SX
    sta OAML_BUF_START, x
    inx
    lda #(224-64)
    sta OAML_BUF_START, x
    inx
    stz OAML_BUF_START, x
    inx
    lda #%00110000 ; OBJ prio 3
    sta OAML_BUF_START, x
    inx
    ; LEGS
    lda PLAYER_SX
    sta OAML_BUF_START, x
    inx
    lda #(224-48)
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
    stz BGH_SCRL
    stz BGH_SCRH

    stz DIRECTION

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

; A8 I16
.proc nmi_int
    ; read NMI status, acknowledge NMI
    lda RDNMI

    transfer_oam_buffer
    lda BGH_SCRL
    sta BG1HOFS
    lda BGH_SCRH
    sta BG1HOFS
    jsr read_joypad

    rti
.endproc

.proc GameLoop
    ; wait for NMI / V-Blank
    wai

    lda JOY1_HELDH
    tax
    and #$01
    bne move_right
    txa
    and #$02
    bne move_left

    bra continue

move_right:
    ldx PLAYER_MXL
    inx
    stx PLAYER_MXL
    cpx #512
    bcc continue_mr1 ; P_MX < 512 ? continue_mr1
    ldx #512
    stx PLAYER_MXL

continue_mr1:
    lda PLAYER_SX
    inc
    sta PLAYER_SX

    ldx PLAYER_MXL
    cpx #(512-120)
    bcs continue_mr2 ; P_MX > 392 ? update

    lda PLAYER_SX
    cmp #120
    bcc update ; P_SX < 120 ? update
    lda #120 ; else block at 120
    sta PLAYER_SX

    ldx BGH_SCRL
    inx
    stx BGH_SCRL

continue_mr2:
    lda PLAYER_SX
    cmp #240
    bcc update ; P_SX < 120 ? update
    lda #240 ; else block at 120
    sta PLAYER_SX
    bra update

move_left:
    lda PLAYER_SX
    dec
    sta PLAYER_SX

update:
    sta OAML_BUF_START
    ldx #$04
    sta OAML_BUF_START, x

continue:
    jmp GameLoop
.endproc

read_joypad:
    php
read_data:
    lda HVBJOY ; read joypad status
    and #$01
    bne read_data ; read done when 0

    rep #$30 ; A 16, I 16

    ldx JOY1_RAWL   ; read previous frame raw input
    lda JOY1L       ; read current frame raw input
    sta JOY1_RAWL   ; save it
    txa             ; move previous frame raw input to A
    eor JOY1_RAWL   ; XOR previous with current, get changes. Held and unpressed become 0
    and JOY1_RAWL   ; AND previous with current, only pressed left to 1
    sta JOY1_PRESSL ; store pressed
    txa             ; move previous frame raw input to A
    and JOY1_RAWL   ; AND with current, only held are left to 1
    sta JOY1_HELDL  ; stored held

    plp
    rts
