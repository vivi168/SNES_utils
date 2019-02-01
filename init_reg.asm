.include "include/reg.inc"
.export init_reg

.p816

.segment "CODE"

.proc init_reg
    sep #$20
.a8
    lda #$8f
    sta INIDISP
    stz OBJSEL

    stz OAMADDL
    stz OAMADDH
    stz BGMODE
    stz MOSAIC
    stz BG1SC
    stz BG2SC
    stz BG3SC
    stz BG4SC
    stz BG12NBA
    stz BG34NBA

    rep #$20
.a16
    stz BG1HOFS
    stz BG1VOFS
    stz BG2HOFS
    stz BG2VOFS
    stz BG3HOFS
    stz BG3VOFS
    stz BG4HOFS
    stz BG4VOFS

    sep #$20
.a8
    lda #$80
    sta VMAINC
    stz VMADDL
    stz VMADDH
    stz M7SEL

    rep #$20
.a16
    lda #$0001
    sta M7A
    stz M7B
    stz M7C
    lda #$0001
    sta M7D
    stz M7X
    stz M7Y

    sep #$20
.a8
    stz CGADD
    stz W12SEL
    stz W34SEL
    stz WOBJSEL
    stz WH0
    stz WH1
    stz WH2
    stz WH3
    stz WBGLOG
    stz WOBJLOG
    lda #$01
    sta TM
    stz TS
    stz TMW
    stz TSW
    lda #$30
    sta CGSWSEL
    stz CGADSUB
    lda #$e0
    sta COLDATA
    stz SETINI

    stz NMITIMEN
    lda #$ff
    sta WRIO
    stz WRMPYA
    stz WRMPYB
    stz WRDIVL
    stz WRDIVH
    stz WRDIVB
    stz HTIMEL
    stz HTIMEH
    stz VTIMEL
    stz VTIMEH
    stz MDMAEN
    stz HDMAEN
    stz MEMSEL

    rts
.endproc
