;----- Aliases/Labels ----------------------------------------------------------
; these are aliases for the Memory Mapped Registers we will use
INIDISP     = $2100     ; inital settings for screen
OBJSEL      = $2101     ; object size $ object data area designation
OAMADDL     = $2102     ; address for accessing OAM
OAMADDH     = $2103
OAMDATA     = $2104     ; data for OAM write
BGMODE      = $2105     ; BG MODE and Tile size setting; abcdefff abcd = BG tile size (4321): 0 = 8x8 1 = 16x16, e = BG 3 High Priority, f = BG Mode
BG1SC       = $2107
BG2SC       = $2108
BG3SC       = $2109
BG4SC       = $210a
BG12NBA     = $210b     ; BG 1&2 Tile Data Designation
BG34NBA     = $210c     ; BG 3&4 Tile Data Designation
VMAINC      = $2115     ; VRAM address increment value designation
VMADDL      = $2116     ; address for VRAM read and write
VMADDH      = $2117
VMDATAL     = $2118     ; data for VRAM write
VMDATAH     = $2119     ; data for VRAM write
CGADD       = $2121     ; address for CGRAM read and write
CGDATA      = $2122     ; data for CGRAM write
TM          = $212c     ; main screen designation 000abcde, 000abcde a = Object b = BG 4 c = BG 3 d = BG 2 e = BG 1
NMITIMEN    = $4200     ; enable flaog for v-blank
RDNMI       = $4210     ; read the NMI flag status

JOY1L       = $4218     ; abcd0000 a = Button A b = X c = L d = R
JOY1H       = $4219     ; abcdefgh a = B b = Y c = Select d = Start efgh = Up/Dn/Lt/Rt

SPRITE_X  = $0000
UPDATE_X  = $0001
DIRECTION = $0002

;-------------------------------------------------------------------------------

;----- Assembler Directives ----------------------------------------------------
.p816                           ; tell the assembler this is 65816 code
;-------------------------------------------------------------------------------

;----- Includes ----------------------------------------------------------------
.segment "SPRITEDATA"
SpriteData: .incbin "assets/link_full.png.vra"
ColorData:  .incbin "assets/link_full.png.pal"
;-------------------------------------------------------------------------------

.segment "CODE"
;-------------------------------------------------------------------------------
;   This is the entry point of the demo
;-------------------------------------------------------------------------------
.proc   ResetHandler
        sei                     ; disable interrupts
        clc                     ; clear the carry flag
        xce                     ; switch the 65816 to native (16-bit mode)
        lda #$8f                ; force v-blanking
        sta INIDISP
        stz NMITIMEN            ; disable NMI

        lda #$80
        sta VMAINC              ; increment VRAM address by 1 when writing to VMDATAH

        rep #$30
.a16
.i16
        ; TODO use a proc
        ; transfer VRAM data
        lda #$0000 ; start address in VRAM
        ldx #$0000 ; start address in incbin
        ldy #$0060 ; size of asset in word

        sta VMADDL
VRAMLoop:
        lda SpriteData, x
        sta VMDATAL
        inx
        inx
        dey
        bne VRAMLoop

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

        ; set up OAM data
        stz OAMADDL             ; set the OAM address to ...
        stz OAMADDH             ; ...at $0000

        ; reset custom memory locations
        stz SPRITE_X
        stz UPDATE_X
        stz DIRECTION

        jsr draw_sprite

        ; make Objects visible
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

;-------------------------------------------------------------------------------
;   Is not used in this program
;-------------------------------------------------------------------------------
.proc   IRQHandler
        ; code
        rti
.endproc
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;   Interrupt and Reset vectors for the 65816 CPU
;-------------------------------------------------------------------------------
.segment "VECTOR"
; native mode   COP,        BRK,        ABT,
.addr           $0000,      $0000,      $0000
;               NMI,        RST,        IRQ
.addr           NMIHandler, $0000,      $0000

.word           $0000, $0000    ; four unused bytes

; emulation m.  COP,        BRK,        ABT,
.addr           $0000,      $0000,      $0000
;               NMI,        RST,        IRQ
.addr           $0000,      ResetHandler, $0000
