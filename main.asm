.include "include/reg.inc"
.include "include/macros.inc"
.include "include/header.inc"
.import init_reg

; TODO : find a better way to define ram locations
; .segement ZEROPAGE, .byte/.word ?
PLAYER_SX   = $0001
BGH_SCRL    = $0002
BGH_SCRH    = $0003
BGV_SCRL    = $0004
PLAYER_ATTR = $0005
PLAYER_MXL  = $0006
PLAYER_MXH  = $0007
JOY1_RAWL   = $0010
JOY1_RAWH   = $0011
JOY1_HELDL  = $0012
JOY1_HELDH  = $0013
JOY1_PRESSL = $0014
JOY1_PRESSH = $0015

; constants
TILEMAP_START = $8000
TILEMAP_SIZE = $800
BG_SIZE = $800
BG_START = TILEMAP_START + TILEMAP_SIZE
MARIO_SIZE = $800
MARIO_START = BG_START + BG_SIZE
BG_PAL_SIZE = $20
BG_PAL_START = MARIO_START + MARIO_SIZE
MARIO_PAL_SIZE = $20
MARIO_PAL_START = BG_PAL_START + BG_PAL_SIZE

.segment "DATA"
    ; TODO find a way to find each 'bin' address/size by name
    .incbin "assets/tilemap.tmx.map"
    .incbin "assets/background.png.vra"
    .incbin "assets/mario.png.vra"
    .incbin "assets/background.png.pal"
    .incbin "assets/mario.png.pal"

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
    ldx #$0010
    stx PLAYER_MXL
    stx PLAYER_SX
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
    transfer_vram #$0000, #$02, #BG_START, #BG_SIZE
    ;transfer tilemap data
    transfer_vram #$2000, #$02, #TILEMAP_START, #TILEMAP_SIZE
    ; transfer mario data
    transfer_vram #$6000, #$02, #MARIO_START, #MARIO_SIZE

    ; transfer bg color data
    transfer_cgram #$00, #$02, #BG_PAL_START, #BG_PAL_SIZE
    ; transfer mario color data
    transfer_cgram #$80, #$02, #MARIO_PAL_START, #MARIO_PAL_SIZE

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

    stz PLAYER_ATTR

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

; may need to optimize this
move_right:
    ldx PLAYER_MXL
    inx
    stx PLAYER_MXL
    cpx #512
    bcc check_right_center
    ldx #512
    stx PLAYER_MXL

check_right_center:
    lda PLAYER_SX
    inc
    sta PLAYER_SX

    cpx #(512-120)
    bcs check_right_edge

    cmp #120
    bcc update
    lda #120
    sta PLAYER_SX

    ldx BGH_SCRL
    inx
    stx BGH_SCRL

check_right_edge:
    cmp #240
    bcc update ; P_SX < 120 ? update
    lda #240 ; else block at 120
    sta PLAYER_SX
    bra update

move_left:
    ldx PLAYER_MXL
    dex
    stx PLAYER_MXL
    cpx #$00
    bpl check_left_center
    ldx #$00
    stx PLAYER_MXL

check_left_center:
    lda PLAYER_SX
    dec
    sta PLAYER_SX

    cpx #120
    bcc check_left_edge

    cmp #120
    bcs update
    lda #120
    sta PLAYER_SX

    ldx BGH_SCRL
    dex
    stx BGH_SCRL

check_left_edge:
    cmp #$00
    bpl update
    lda #$00
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
