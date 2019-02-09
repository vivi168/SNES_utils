.ifndef MACROS_INC
.define MACROS_INC

OAML_BUF_START = $0100
OAMH_BUF_START = $0300
OAML_SIZE      = $0200
OAMH_SIZE      = $0020
OAM_SIZE       = OAML_SIZE + OAMH_SIZE

.macro reset_oam_buffer
    ; Load dummy data in WRAM, set all sprites at position $101 (out of screen)
    ; first load $01 in all sprites X coord (LSB)
    lda #$01
set_x_lsb:
    sta OAML_BUF_START, x
    inx
    inx
    inx
    inx
    cpx #OAML_SIZE
    bne set_x_lsb

    ; then, set all sprite X MSB to 1
    lda #$55
set_x_msb:
    sta OAML_BUF_START, x
    inx
    sta OAML_BUF_START, x
    inx
    cpx #OAM_SIZE
    bne set_x_msb
.endmacro

; A 8, I 16
.macro transfer_oam_buffer
    ; -------------
    ; LOAD our dummy data into OAM via DMA
    ; -------------
    stz OAMADDL
    stz OAMADDH

    lda #$04 ; OAMDATA $21`04`
    sta BBAD0
    ; from WRAM address $7e:0100 (A bus address)
    lda #$7e
    sta A1T0B
    ldx #OAML_BUF_START
    stx A1T0L
    ; total number of bytes to transfer (OAM is $220 bytes)
    ldx #OAM_SIZE
    stx DAS0L
    ; DMA params : A to B
    lda #$00
    sta DMAP0
    ; initiate DMA via channel 0 (LSB = channel 0, MSB channel 7)
    lda #$01
    sta MDMAEN
.endmacro

; A8, I16
.macro transfer_cgram cgram_start, bank_no, rom_start, btt
    ; -------------
    ; CGRAM DMA TRANSFER
    ; -------------
    lda cgram_start
    sta CGADD
    lda #$22
    sta BBAD1
    lda bank_no
    sta A1T1B
    ldx rom_start
    stx A1T1L
    ldx btt
    stx DAS1L
    lda #$00
    sta DMAP1
    lda #$02
    sta MDMAEN
.endmacro

; A16, I16
.macro transfer_vram vram_start, bank_no, rom_start, btt
    ; -------------
    ; VRAM DMA TRANSFER
    ; -------------
    ; VRAM insert start address
    ldx vram_start
    stx VMADDL
    ; via VRAM write register 21`18` (B bus address)
    lda #$18
    sta BBAD0
    ; from rom address (A bus address)
    lda bank_no
    sta A1T0B
    ldx rom_start
    stx A1T0L
    ; total number of bytes to transfer
    ldx btt
    stx DAS0L
    ; DMA params : A to B, increment, 2 bytes to 2 registers
    lda #%00000001
    sta DMAP0
    ; initiate DMA via channel 0 (LSB = channel 0, MSB channel 7)
    lda #%00000001
    sta MDMAEN
.endmacro

.endif
