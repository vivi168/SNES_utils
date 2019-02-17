.include "include/reg.inc"
.include "include/def.inc"

.export init_oam_buffer

.segment "CODE"

init_oam_buffer:
    rep #$10 ; I 16
    sep #$20 ; A 8

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
