.include "include/reg.inc"
.include "include/def.inc"
.include "include/macros.inc"
.include "include/header.inc"
.include "include/import.inc"

.segment "DATA"
    ; TODO find a way to find each 'bin' address/size by name
    .incbin "assets/test.map"
    .incbin "assets/test2.map"
    .incbin "assets/background.bin"
    .incbin "assets/mario.bin"
    .incbin "assets/background-pal.bin"
    .incbin "assets/mario-pal.bin"

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
    jsr init_oam_buffer
    transfer_oam_buffer

    ; transfer background data
    transfer_vram #$0000, #$02, #BG_START, #BG_SIZE
    ;transfer tilemap data
    transfer_vram #$1000, #$02, #TILEMAP_START, #TILEMAP_SIZE
    transfer_vram #$2000, #$02, #TILEMAP2_START, #TILEMAP_SIZE
    ; transfer mario data
    transfer_vram #$6000, #$02, #MARIO_START, #MARIO_SIZE

    ; transfer bg color data
    transfer_cgram #$00, #$02, #BG_PAL_START, #BG_PAL_SIZE
    ; transfer mario color data
    transfer_cgram #$80, #$02, #MARIO_PAL_START, #MARIO_PAL_SIZE

    ; set bg mode 1, 8x8 tiles
    lda #$01
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
    stz UPDATE_OBJ

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

    ; TODO: maybe don't transfer full OAM Buffer each time
    ; but only modified data
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
    and #JOY_RIGHT
    bne move_right
    txa
    and #JOY_LEFT
    bne move_left

    bra stand_still

; may need to optimize this
move_right:
    jsr player_move_right
    bra update

move_left:
    jsr player_move_left

update:
    jsr update_oam_buffer
    bra continue

stand_still:
    lda #$00
    ldx #$02
    sta OAML_BUF_START, x
    lda #$02
    ldx #$06
    sta OAML_BUF_START, x

continue:
    jmp GameLoop
.endproc

.proc read_joypad
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
.endproc
