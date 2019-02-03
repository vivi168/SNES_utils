.include "include/header.inc"
.include "include/reg.inc"
.import init_reg

SPRITE_X  = $0000
UPDATE_X  = $0001
DIRECTION = $0002
TORSO     = $0003
LEGS      = $0004

;----- Assembler Directives ----------------------------------------------------
.p816                           ; tell the assembler this is 65816 code
;-------------------------------------------------------------------------------

;----- Includes ----------------------------------------------------------------
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
;-------------------------------------------------------------------------------

.segment "CODE"
;-------------------------------------------------------------------------------
;   This is the entry point of the demo
;-------------------------------------------------------------------------------
.proc   ResetHandler
        sei                     ; disable interrupts
        clc                     ; clear the carry flag
        xce                     ; switch the 65816 to native (16-bit mode)
        jsr init_reg

        ; reset custom memory locations
        stz SPRITE_X
        stz UPDATE_X
        stz DIRECTION
        stz TORSO
        lda #$20
        sta LEGS

        rep #$10
        sep #$20
.a8
.i16
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
        lda #$61 ; 16/32, start @ $2000
        sta OBJSEL

        ; make Objects visible
        jsr draw_sprite

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
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;   After the ResetHandler will jump to here
;-------------------------------------------------------------------------------
; .smart ; keep track of registers widths
.proc   GameLoop
        wai                     ; wait for NMI / V-Blank

        lda UPDATE_X
        inc
        sta UPDATE_X
        cmp #$10
        bne continue_gameloop ; skip moving
        stz UPDATE_X

        lda SPRITE_X
        ldx DIRECTION

        cpx #$01
        beq go_left

go_right:
        adc #$10
        cmp #$f0
        bne update_position ; when A == 240, switch direction
        lda #$f0
        inx
        bra update_position
go_left:
        sbc #$10
        cmp #$00
        bne update_position ; when A == 0, switch direction
        dex
        lda #$00

update_position:
        sta SPRITE_X
        stx DIRECTION

        lda TORSO
        ina
        ina
        sta TORSO
        cmp #$07
        bcc update_legs
        lda #$02
        sta TORSO

update_legs:
        lda LEGS
        ina
        ina
        sta LEGS
        cmp #$27
        bcc continue_gameloop
        lda #$22
        sta LEGS




continue_gameloop:

        jmp GameLoop
.endproc
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;   Will be called during V-Blank
;-------------------------------------------------------------------------------
.proc   NMIHandler
        lda RDNMI               ; read NMI status, acknowledge NMI

        jsr draw_sprite

        rti
.endproc
;-------------------------------------------------------------------------------

;-----
; X = sprite x
; Y = sprite y
; A = sprite #
;-----
.proc set_sprite_data
        pha
        phx
        phy

        stx OAMDATA    ; horizontal position
        sty OAMDATA    ; vertical position
        sta OAMDATA    ; name of sprite
        lda #$00       ; no flip, prio 0, palette 0
        sta OAMDATA

        ply
        plx
        pla
        rts
.endproc

.proc draw_sprite
; TODO optimize this mess
        pha
        phx
        phy

        clc

        ldx SPRITE_X
        ldy #$20 ; Y coord
        lda TORSO ; char #
        jsr set_sprite_data

        ldy #$30 ; Y coord
        lda LEGS ; char #
        jsr set_sprite_data

        ply
        plx
        pla
        rts
.endproc
