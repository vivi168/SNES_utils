.include "include/header.inc"
.include "include/reg.inc"
.import init_reg

SPRITE_X  = $0000
UPDATE_X  = $0001
DIRECTION = $0002

;----- Assembler Directives ----------------------------------------------------
.p816                           ; tell the assembler this is 65816 code
;-------------------------------------------------------------------------------

;----- Includes ----------------------------------------------------------------
.segment "DATA"
    SpriteData:
        .incbin "assets/link_full.png.vra"
    ColorData:
        .incbin "assets/link_full.png.pal"
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

        rep #$10
        sep #$20
.a8
.i16
        ; VRAM insert start address
        ldx #$0000
        stx $2116

        ; via VRAM write register 21`18` (B bus address)
        lda #$18
        sta $4301

        ; from rom address (A bus address)
        lda #$00
        sta $4304
        ldx #$8400
        stx $4302

        ; total number of bytes to transfer
        ldx #$00c0
        stx $4305

        ; DMA params : A to B, increment, 2 bytes to 2 registers
        lda #%00000001
        sta $4300

        ; initiate DMA via channel 0 (LSB = channel 0, MSB channel 7)
        lda #%00000001
        sta $420b

        sep #$30
.a8
.i8

        ; transfer CGRAM data
        lda #$80
        sta CGADD               ; set CGRAM address to $80
        ldx #$00                ; set X to zero, use it as loop counter and offset
CGRAMLoop:
        lda ColorData, X        ; get the color low byte
        sta CGDATA              ; store it in CGRAM
        inx                     ; increase counter/offset
        lda ColorData, X        ; get the color high byte
        sta CGDATA              ; store it in CGRAM
        inx                     ; increase counter/offset
        cpx #$20                ; check whether 32/$20 bytes were transfered
        bcc CGRAMLoop           ; if not, continue loop


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
        bne noupdate_position ; skip moving
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


noupdate_position:

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
        ldy #$10
        lda #$00
        jsr set_sprite_data

        ldy #$18
        lda #$02
        jsr set_sprite_data

        ldy #$20
        lda #04
        jsr set_sprite_data

        txa
        adc #$08
        tax
        ldy #$10
        lda #$01
        jsr set_sprite_data

        ldy #$18
        lda #$03
        jsr set_sprite_data

        ldy #$20
        lda #$05
        jsr set_sprite_data

        ply
        plx
        pla
        rts
.endproc
