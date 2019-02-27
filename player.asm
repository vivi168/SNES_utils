.include "include/reg.inc"
.include "include/def.inc"

.export init_oam_buffer
.export update_oam_buffer
.export player_move_right
.export player_move_left

.segment "CODE"

rep #$10 ; I 16
sep #$20 ; A 8

.proc init_oam_buffer
    ldx #$0050
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

    rts
.endproc

.proc update_oam_buffer
    lda PLAYER_SX
    sta OAML_BUF_START
    ldx #$04
    sta OAML_BUF_START, x

    inc UPDATE_OBJ
    lda UPDATE_OBJ
    cmp #$04
    bne return
    stz UPDATE_OBJ

; TODO: Use look up table instead of incrementing tile name
update_torso:
    ldx #$02
    lda OAML_BUF_START, x
    inc
    inc
    inc
    inc
    sta OAML_BUF_START, x
    cmp #$09
    bcc update_legs
    lda #$00
    sta OAML_BUF_START, x
update_legs:
    ldx #$06
    lda OAML_BUF_START, x
    inc
    inc
    inc
    inc
    sta OAML_BUF_START, x
    cmp #$0b
    bcc return
    lda #$02
    sta OAML_BUF_START, x

return:
    rts
.endproc

.proc player_move_right
    ; TODO: would be better to track direction in PLAYER_ATTR
    ; if direction has changed, flip (EOR #$40)
    ldx #$03
    lda #$30
    sta OAML_BUF_START, x
    ldx #$07
    sta OAML_BUF_START, x

    ldx PLAYER_MXL
    inx
    inx
    stx PLAYER_MXL
    cpx #496
    bcc check_right_center
    ldx #496
    stx PLAYER_MXL

check_right_center:
    lda PLAYER_SX
    inc
    inc
    sta PLAYER_SX

    cpx #(496-120)
    bcs check_right_edge

    cmp #120
    bcc reset_next_tilemap
    lda #120
    sta PLAYER_SX

    ldx BGH_SCRL
    inx
    inx
    stx BGH_SCRL
    ; TODO update next colum here
    ldx PLAYER_MXL
    stx MODULO8
    LSR MODULO8
    LSR MODULO8
    LSR MODULO8
    ASL MODULO8
    ASL MODULO8
    ASL MODULO8
    ldx MODULO8
    cpx PLAYER_MXL
    bne check_right_edge
    ldx NEXT_COL_VRAML
    inx
    stx NEXT_COL_VRAML
    ldx NEXT_COL_ROML
    inx
    inx
    stx NEXT_COL_ROML

check_right_edge:
    cmp #240
    bcc return
    lda #240
    sta PLAYER_SX
    bra return

reset_next_tilemap:
    ldx #$0fff
    ldy #$7fe
    stx LAST_COL_VRAML
    stx NEXT_COL_VRAML
    sty LAST_COL_ROML
    sty NEXT_COL_ROML

return:

    rts
.endproc

.proc player_move_left
    ldx #$03
    lda #$70
    sta OAML_BUF_START, x
    ldx #$07
    sta OAML_BUF_START, x

    ldx PLAYER_MXL
    dex
    dex
    stx PLAYER_MXL
    cpx #$00
    bpl check_left_center
    ldx #$00
    stx PLAYER_MXL

check_left_center:
    lda PLAYER_SX
    cmp #240
    bne continue1
    ldx PLAYER_MXL
    dex
    dex
    stx PLAYER_MXL

continue1:
    dec
    dec
    sta PLAYER_SX

    cpx #120
    bcc check_left_edge

    cmp #120
    bcs reset_prev_tilemap
    lda #120
    sta PLAYER_SX

    ldx BGH_SCRL
    dex
    dex
    stx BGH_SCRL
    ; TODO update next colum here
    ldx PLAYER_MXL
    stx MODULO8
    LSR MODULO8
    LSR MODULO8
    LSR MODULO8
    ASL MODULO8
    ASL MODULO8
    ASL MODULO8
    ldx MODULO8
    cpx PLAYER_MXL
    bne check_left_edge
    ldx NEXT_COL_VRAML
    dex
    stx NEXT_COL_VRAML
    ldx NEXT_COL_ROML
    dex
    dex
    stx NEXT_COL_ROML

check_left_edge:
    ldx PLAYER_MXL
    cpx #120
    bne continue2
    ldx BGH_SCRL
    dex
    dex
    stx BGH_SCRL

continue2:
    cmp #$00
    bpl return
    lda #$00
    sta PLAYER_SX
    bra return

reset_prev_tilemap:
    ldx #$1000
    ldy #$0000
    stx LAST_COL_VRAML
    stx NEXT_COL_VRAML
    sty LAST_COL_ROML
    sty NEXT_COL_ROML

return:
    rts
.endproc
