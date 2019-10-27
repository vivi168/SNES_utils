.include "include/reg.inc"
.include "include/def.inc"

.export init_oam_buffer
.export update_oam_buffer
.export update_sprite_x
.export player_move_right
.export player_move_left
.export update_bg_scroll

.segment "CODE"

rep #$10 ; I 16
sep #$20 ; A 8

.proc init_oam_buffer
    ldx #$0000
    ; TORSO
    lda SPRITE_X
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
    lda SPRITE_X
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
    lda SPRITE_X
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

.proc update_sprite_x
    ldx SPRITE_X
    stx PREV_SPRITE_X
    ldx PLAYER_X
    cpx #CENTER_X
    bcc far_left
    cpx #(MAP_W - SPRITE_W - CENTER_X)
    bcs far_right
    lda #CENTER_X
    sta SPRITE_X
    bra return

far_left:
    stx SPRITE_X
    bra return

far_right:
    rep #$20 ; A 16
    lda PLAYER_X
    clc
    adc #CENTER_X
    adc #CENTER_X
    adc #SPRITE_W
    sec
    sbc #MAP_W
    sta SPRITE_X
    sep #$20 ; A 8

return:
    rts
.endproc

.proc player_move_right
    ldx #$03
    lda #$30
    sta OAML_BUF_START, x
    ldx #$07
    sta OAML_BUF_START, x

    rep #$20
    lda PLAYER_X
    sta PREV_PLAYER_X
    clc
    adc PLAYER_X_VEL
    cmp #(MAP_W - SPRITE_W)
    bcc return
    lda #(MAP_W - SPRITE_W)

return:
    sta PLAYER_X
    sep #$20
    rts
.endproc

.proc player_move_left
    ldx #$03
    lda #$70
    sta OAML_BUF_START, x
    ldx #$07
    sta OAML_BUF_START, x

    rep #$20
    lda PLAYER_X
    sta PREV_PLAYER_X
    sec
    sbc PLAYER_X_VEL
    cmp #$00
    bpl return
    lda #$00

return:
    sta PLAYER_X
    sep #$20
    rts
.endproc

.proc update_bg_scroll
    ldx SPRITE_X
    cpx PREV_SPRITE_X
    beq update
    rts
update:
    rep #$20
    lda PLAYER_X
    sec
    sbc PREV_PLAYER_X
    clc
    adc BGH_SCRL
    sta BGH_SCRL
    sep #$20
    rts
.endproc
