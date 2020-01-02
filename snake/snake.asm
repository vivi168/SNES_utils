;**************************************
;
; Snake SNES
;
;**************************************

.65816

8000:           .incbin assets/snake-bg.bin             ; 0x800
8800:           .incbin assets/snake-sprites.bin        ; 0x800
9000:           .incbin assets/snake-bg-pal.bin         ; 0x20
9020:           .incbin assets/snake-sprites-pal.bin    ; 0x20
9040:           .incbin assets/random.bin               ; 0x800
9840:           .incbin assets/title-screen.map         ; 0x800
a040:           .incbin assets/title-screen.bin         ; 0x1800
b840:           .incbin assets/small-font.bin           ; 0x600
be40:           .incbin assets/title-screen-pal.bin     ; 0x20
be60:           .incbin assets/small-font-pal.bin       ; 0x08


;**************************************
; WRAM addresses
;**************************************
; all coord are stored as map coordinate ([0,15], [0,13])
; map coord = random coord >> 4
; 7e0000: frame counter
; 7e0001: random seed
; 7e0002: random x pointer
; 7e0003: random y pointer
; 7e0004: apple x coord
; 7e0005: apple y coord
; 7e0006: body size
; 7e0007: head x coord
; 7e0008: head y coord
; 7e0009: tail x coord
; 7e000a: tail y coord
; 7e000b; last move counter
; 7e000c: base speed
; 7e000d: base speed
; 7e000e: x velocity
; 7e000f: y velocity
; 7e0010: score L
; 7e0011: score H
; 7e0012: seed read?

; 7e0013: body size buffer
; 7e0014: body size buffer
; 7e0015: tile coord buffer
; 7e0016: tile coord buffer

; 7e0020: score ones
; 7e0021: score tens
; 7e0022: score hundreds
; 7e0023: score thousands

; 7e0100: JOY1_RAW
; 7e0102: JOY1_PRESSL
; 7e0103: JOY1_PRESSH
; 7e0104: JOY1_HELDL
; 7e0105: JOY1_HELDH

; 7e0200: snake body xy coord

; coord converted from map coord to screen coord
; screen coord = map coord << 4
; 7e2000: oam buffer
; map coord to VRAM tile index:
; 16x16 tile is composed of 4 8x8 tiles:
; 0|1 => tile 0 = (x << 2) + (y << 7), tile 1 = tile 0 + 2
; -+-
; 2|3 => tile 2 = tile 0 + 0x40, tile 3 = tile 2 + 2
;
; 7e2300: snake body tile buffer
; 7e3000: BG3 tile buffer
; BG tile = vhopppcc cccccccc
;**************************************
; ROUTINES LOCATION
;**************************************
; game engine routines are in first page
; game logic routines are in second page


;**************************************
; Reset @ 8000
;**************************************

; 0000 @ bank 80 = 80/8000
0000:           sei
                clc
                xce
                sep #20         ; M8
                rep #10         ; X16

                ldx #1fff
                txs             ; set stack pointer to 1fff

                ; Forced Blank
                lda #80
                sta 2100        ; INIDISP

                jsr 8e00        ; @clear_registers
                jsr 8ed0

;**************************************
; Main Register Settings
;**************************************

                lda #61
                sta 2101        ; OBSEL (1 = index in VRAM in 8K word steps)
                                ; VRAM[4000]

                lda #09
                sta 2105        ; BGMODE 1, BG3 priority high

                lda #70         ; BG1 MAP @ VRAM[e000]
                sta 2107        ; BG1SC
                lda #50         ; BG3 map @ VRAM[a000]
                sta 2109        ; BG3SC

                lda #06         ; BG1 tiles @ VRAM[c000]
                sta 210b        ; BG12NBA
                lda #04         ; BG3 tiles @ VRAM[8000]
                sta 210c        ; BG34NBA

                lda #05         ; enable BG1&3
                sta 212c        ; TM

                jsr b620        ; @reset_bg3_tilemap_buffer
                jsr b7d0

                ;**************************************
                ; DMA transfers
                ;**************************************
                ; transfer buffer to OAMRAM
                jsr 8400        ; @oam_dma_transfer
                jsr 87e0        ; @dma_transfers

;**************************************
; Final setting before starting gameloop
;**************************************
                ; release forced blanking, set screen to full brightness
                lda #0f
                sta 2100        ; INIDISP

                ; enable NMI, turn on automatic joypad polling
                lda #81
                sta 4200        ; NMITIMEN

                jmp 9000        ; @menu_loop

;**************************************
; BRK @ 8150
;**************************************
0150:           rti
;**************************************
; NMI @ 8200
;**************************************

0200:           lda 4210        ; RDNMI
                inc 0000        ; increase frame counter
                inc 000b        ; increase snake should move?

                ; update oam
                jsr 8400        ; @oam_dma_transfer
                ; TODO: reuse dma_transfers routine
                ; update vram (snake body tilemap)
                tsx             ; save stack pointer
                pea 1000        ; vram_dest_addr
                pea 2300        ; rom_src_addr
                lda #7e         ; rom_src_bank
                pha
                pea 0800        ; bytes_to_trasnfer
                jsr 8430        ; @vram_dma_transfer
                txs             ; restore stack pointer
                ; update vram (bg3 tilemap)
                tsx             ; save stack pointer
                pea 5000        ; vram_dest_addr
                pea 3000        ; rom_src_addr
                lda #7e         ; rom_src_bank
                pha
                pea 0800        ; bytes_to_trasnfer
                jsr 8430        ; @vram_dma_transfer
                txs             ; restore stack pointer

                jsr 8500        ; read joypad
                rti

;**************************************
; def menu_loop()
; Menu screen loop (wait for user to press enter)
; Can increase/decrease speed with up/down arrows
; @9000
;**************************************

1000:           wai
                lda 0103        ; JOY1_PRESSH

                bit #08
                beq @dec_speed
                dec 000c        ; lower base speed, faster snake moves
                lda 000c
                cmp #04         ; maximum speed is 0x04
                bcs @speed_done
                lda #04
                sta 000c
                bra @speed_done

@dec_speed:     lda 0103
                bit #04
                beq @speed_done
                inc 000c        ; higher base speed, slower snake moves
                lda 000c
                cmp #13         ; minimum speed is 0x13
                bcc @speed_done
                lda #13
                sta 000c

@speed_done:    jsr b840        ; update speed shadow

                lda 0103
                bit #10         ; check if start is pressed
                beq @loop_menu

                ; start has been pressed
                jsr a000        ; then init random seed
                ;then generate apple position
                jsr a050
                ; then update oam buffer to reflect new apple coord
                jsr aa20
                ; init bg settings for game loop
                jsr 85e0
                ;jump to game loop
                jmp 9080

@loop_menu:     jmp 9000        ; @menu_loop()

;**************************************
; def game_loop()
; in game loop check for DPAD. change velocity, then
; check wall colision/body collision with head => game over
; check apple colision with head, score increase
; TODO if start is pressed in gameloop, jump to pause loop.
; TODO if start is pressed in pause loop, jump to gameloop
; @9080
;**************************************
1080:           wai
                jsr aa60        ; handle key

                lda 000b
                cmp 000c        ; skip if move counter < speed?
                bcc @continue_gl
                ldx 000e        ; skip if velocity is 0
                beq @continue_gl

                jsr b000 ; update body + tail coords
                jsr aad0 ; update_head_direction()
                jsr ab30 ; update_tail_direction()

                ; head x += xvel
                clc
                lda 0007
                adc 000e
                sta 0007
                ; head y += yvel
                clc
                lda 0008
                adc 000f
                sta 0008

                ; reset move counter
                stz 000b

@continue_gl:   nop
                jsr b050        ; check if collide with apple
                jsr b090        ; check if collide with wall
                jsr b200        ; check if collide with body

                jsr aa20        ; update oam buffer
                jsr b500        ; update background buffer as well

                jmp 9080

;**************************************
; def init_random_seed()
; Init the random seed.
; Set initial x and y pointer
; @a000
;**************************************
2000:           lda 0012        ; check if seed was read
                bne @rts_2000   ; if non zero, it was read
                lda 0000        ; else, load frame counter
                bne @save_2000
                inc             ; ensure non zero result
@save_2000:     sta 0001        ; save it as a random seed

                sta 0002        ; initial x pointer = seed
                dec
                sta 0003        ; initial y pointer = seed - 1

@rts_2000:      lda #01         ; seed was read (1)
                sta 0012
                rts

;**************************************
; def random_apple_coordinates()
; Get next pseudo random apple coordinate
; @a050
;**************************************
2050:           php

@next_appl:     sep #30         ; m8 x8

                ldx 0002        ; load x pointer
                lda 819040,x    ; load corresponding value
                lsr
                lsr
                lsr
                lsr
                sta 0004        ; save it to apple x coord
                inx
                stx 0002        ; next x pointer = x pointer + 1

                ldx 0003        ; load y pointer
                lda 819040,x    ; load corresponding value
                cmp #e0
                bcc @save_y_appl
                ; if apple.y >= 224, apple.y -= 32
                ; (screen is only 224 high)
                sec
                sbc #20
@save_y_appl:   nop
                lsr
                lsr
                lsr
                lsr
                sta 0005        ; save it to apple y coord
                dex
                stx 0003        ; next y pointer = y pointer - 1

                rep #10

                ; check if apple is on head
                ldx 0004
                cpx 0007
                beq @next_appl

                ; check if apple is on body
                phx
                jsr b100
                plx
                cmp #01
                beq @next_appl

                plp
                rts

;**************************************
; def map_to_screen_coord(point=07)
; result in A
; @a850
;**************************************
2850:           phd
                tsc
                tcd

                lda 05
                asl
                asl
                asl
                asl

                pld
                rts


;**************************************
; def update_oam_buffer_from_map_coord()
; this routine update head/tail and
; apple oam buffer entries from their
; map coord
; @aa20
;**************************************
; coord pairs (RAM map coord/OAM buffer screen coord)
2a00: 07 00 00 20 08 00 01 20 ; head 7e0007,8 > 7e2000,1
2a08: 09 00 04 20 0a 00 05 20 ; tail 7e0009,a > 7e2004,5
2a10: 04 00 08 20 05 00 09 20 ; apple 7e0004,5 > 7e2008,9

2a20:           phd
                php
                phb

                rep #30         ; m 16 x 16
                lda #aa00       ; index DP @ coord pairs array
                tcd
                sep #20         ; m 8

                lda #7e
                pha
                plb             ; dbr = 7e
                ldy #0006
                ldx #0000

@loop_2a20:     lda (00,x)      ; load sprite map coord
                pha
                jsr a850        ; map_to_screen_coord
                sta (02,x)      ; save it to oam
                pla
                inx
                inx
                inx
                inx
                dey
                bne @loop_2a20

                ; sprites are not vertically aligned with background
                dec 2001
                dec 2005
                dec 2009

                plb
                plp
                pld
                rts

;**************************************
; def handle_input()
; handle player input
; up 8
; down 4
; left 2
; right 1
; @aa60
;**************************************

2a60:           lda 0103        ; JOY1_PRESSH

                bit #08
                bne @move_up

                bit #04
                bne @move_down

                bit #02
                bne @move_left

                bit #01
                bne @move_right

                rts

@move_up:       nop
                lda 000f        ; don't allow switching direction in same axis
                bne @return_2a60
                lda #ff
                stz 000e
                sta 000f
                rts
@move_down:     nop
                lda 000f
                bne @return_2a60
                lda #01
                stz 000e
                sta 000f
                rts
@move_left:     nop
                lda 000e
                bne @return_2a60
                lda #ff
                sta 000e
                stz 000f
                rts
@move_right:    nop
                lda 000e
                bne @return_2a60
                lda #01
                sta 000e
                stz 000f

@return_2a60:   rts


;**************************************
; def update_head_direction()
; TODO maybe refactor, bit ugly?
; @aad0
;**************************************
2ad0:           nop

                lda 000e        ; xvel
                beq @check_h_vert
                ; head xvel != 0, flip accordingly
                lda #02
                sta 7e2002      ; set horizontal sprite

                lda 000e        ; xvel
                cmp #ff
                bne @skip_head_hf

                ; head xvel < 0, flip tile
                lda 7e2003
                and #3f
                ora #40
                sta 7e2003
                rts

                ; head xvel > 0, reset tile flip
@skip_head_hf:  nop
                lda 7e2003
                and #3f
                sta 7e2003
                rts

@check_h_vert:  nop
                lda 000f        ; yvel
                beq @ret_2ad0
                ; head yvel != 0, proceed

                lda #04
                sta 7e2002      ; set vertical sprite

                lda 000f        ; yvel
                cmp #01
                bne @skip_head_vf
                ; head yvel > 0, flip tile
                lda 7e2003
                and #3f
                ora #80
                sta 7e2003
                rts

                ; head yvel < 0, reset tile flip
@skip_head_vf:  lda 7e2003
                and #3f
                sta 7e2003

@ret_2ad0:      rts
;**************************************
; def update_tail_direction()
; TODO: refactor. Can spare cycles by
; better branching organization
; @ab30
;**************************************
2b30:           php

                lda 0006
                rep #30
                and #00ff
                dec
                asl
                tax

                sep #20

                lda 7e0200,x    ; last body x
                cmp 0009
                beq @cmp_y      ; body.x == tail.x, skip

                ; body.x != tail.x
                lda #06
                sta 7e2006      ; set horizontal sprite

                lda 7e0200,x
                cmp 0009
                bcc @bx_lt_tx

                ; body.x > tail.x
                lda 7e2007
                and #3f
                sta 7e2007
                bra @ret_2b30

                ; body.x < tail.x
@bx_lt_tx:      nop
                lda 7e2007
                and #3f
                ora #40
                sta 7e2007
                bra @ret_2b30

@cmp_y:         nop
                inx
                lda 7e0200,x    ; last body y
                cmp 000a
                beq @ret_2b30

                ; body.y != tail.y
                lda #08
                sta 7e2006      ; set vertical sprite

                lda 7e0200,x
                cmp 000a
                bcc @by_lt_ty

                ; body.y > tail.y
                lda 7e2007
                and #3f
                ora #80
                sta 7e2007
                bra @ret_2b30

                ; body.y < tail.y
@by_lt_ty:      nop
                lda 7e2007
                and #3f
                sta 7e2007

@ret_2b30:      nop
                plp
                rts

;**************************************
; def update_snake_body_parts()
; this routine update snake body (7e0200)
; and tail, after a head movement
; @b000
;**************************************
3000:           php

                lda 0006        ; load body size
                rep #30
                and #00ff       ; discard accumulator high byte
                dec
                asl             ; each coord entry is 2 bytes
                tax

                ; tail takes place of last body part
                lda 7e0200,x
                sta 0009

@update_body_x: nop
                txy
                dex
                dex
                lda 7e0200,x
                tyx
                sta 7e0200,x
                dex
                dex
                bne @update_body_x

                ; first body part takes place of head
                lda 0007
                sta 7e0200

                plp
                rts

;**************************************
; def eat_apple()
; check apple collision +
; increase body size + append a body part
; @b050
;**************************************
3050:           php

                ldx 0004        ; apple xy
                cpx 0007        ; head xy
                bne @ret_3050

                jsr a050        ; next apple coord

                ; increase body size and init new body part coords
                lda 0006        ; load body size
                inc 0006        ; increase it
                rep #30
                and #00ff
                asl             ; body coord index from body size
                tax

                lda 0009        ; get tail xy
                sta 7e0200,x    ; init a new body coord entry

                ; score increase formula: score += 20 - base speed
                lda #0014
                sec
                sbc 000c
                clc
                adc 0010
                sta 010

                ; CAUTION: rep #30 above
                jsr c000        ; update score bcd
                jsr b700        ; update bg3 from score bcd

@ret_3050:      nop
                plp
                rts

;**************************************
; def check_wall_collision()
; @b090
;**************************************
3090:           nop
                lda 0007        ; head x
                cmp #00
                bcc @reset
                cmp #10         ; $SCREEN_W
                bcs @reset

                ; left edge < x < right edge
                lda 0008
                cmp #00
                bcc @reset
                cmp #0e         ; $SCREEN_H
                bcs @reset

                ; top edge < y < bottom edge
                rts

@reset:         nop
                jmp 8000
@no_reset:      nop
                rts

;**************************************
; def collides_with_body(xy=08)
; check if a xy pair collides with a body xy pair
; result in A
; @b100
;**************************************
3100:           phx
                phd             ; save direct page
                php
                tsc
                tcd             ; direct page = stack pointer

                lda 7e0006
                rep #30
                and #00ff
                dec
                asl
                tax

                lda 7e0009      ; compare with tail
                cmp 08
                beq @collides

                ; compare with body loop
@check_colli:   nop

                lda 7e0200,x
                cmp 08          ; compare param xy to body xy
                beq @collides

                dex
                dex
                bpl @check_colli

                lda #0000
                bra @ret_3100

@collides:      nop
                lda #0001

@ret_3100:      nop
                plp
                pld
                plx
                rts

;**************************************
; def eat_self?()
; @b200
;**************************************
3200:           nop

                ldx 0007
                phx
                jsr b100
                plx

                cmp #01
                bne @return_3200
                jmp 8000

@return_3200:   nop
                rts


;**************************************
; def update_vram_buffer_from_map_coord()
; this routine update tilemap WRAM buffer
; from snake body array located at 7e0200
; @b500
;**************************************
3500:           php

                ldx #0000

                lda 0006
                rep #30
                and #00ff
                asl
                sta 0013

@cp_tm_vram:    nop
                ; update x
                lda 7e0200,x
                tay

                and #00ff
                asl
                asl
                sta 0015
                tya
                xba
                and #00ff
                asl
                asl
                asl
                asl
                asl
                asl
                asl
                clc
                adc 0015
                sta 0015

                txy
                ldx 0015
                lda #0001
                sta 7e2300,x    ; tile 1 = x << 2 + y << 7
                inx
                inx
                sta 7e2300,x    ; tile 2 = tile 1 + 2
                txa
                clc
                adc #0040
                tax
                lda #0001
                sta 7e2300,x    ; tile 4 = tile 2 + 0x40
                dex
                dex
                sta 7e2300,x    ; tile 3 = tile 4 - 2 (tile 1 + 0x40)

                tyx

                inx
                inx
                cpx 0013
                bne @cp_tm_vram

                ; HERE: clear tile at tail location
                ; TODO: should propably make a routine to convert xy to tile index

                lda 0009
                tay
                and #00ff
                asl
                asl
                sta 0015
                tya
                xba
                and #00ff
                asl
                asl
                asl
                asl
                asl
                asl
                asl
                clc
                adc 0015
                sta 0015

                ldx 0015
                lda #0000
                sta 7e2300,x    ; tile 1 = x << 2 + y << 7
                inx
                inx
                sta 7e2300,x    ; tile 2 = tile 1 + 2
                txa
                clc
                adc #0040
                tax
                lda #0000
                sta 7e2300,x    ; tile 4 = tile 2 + 0x40
                dex
                dex
                sta 7e2300,x    ; tile 3 = tile 4 - 2 (tile 1 + 0x40)

                plp
                rts

;**************************************
; def reset_bg3_tilemap_buffer()
; b620
;     vhopppcc
; 30: 00110000
;**************************************
;               S     C     O     R     E     :
3600:           33 30 23 30 2f 30 32 30 25 30 1a 30
;               0     0     0     0
360c:           10 30 10 30 10 30 10 30
3620:           nop
                php

                rep #30

                lda #3000
                ldx #0800

@reset_bg3:     nop
                sta 7e3000,x
                dex
                dex
                bpl @reset_bg3

                plp
                rts

;**************************************
; def init_bg3_score_buffer()
; b640
;**************************************
3640:           php
                rep #30
                ldx #0000

@default_txt:   nop
                lda 80b600,x
                sta 7e3000,x
                inx
                inx
                cpx #0014
                bne @default_txt

                plp
                rts

;**************************************
; def update_bg3_tile_buffer()
; update score from BCD buffer
; b700
;**************************************
3700:           nop
                php
                sep #20

                lda 0023
                clc
                adc #10
                sta 7e300c

                lda 0022
                clc
                adc #10
                sta 7e300e

                lda 0021
                clc
                adc #10
                sta 7e3010

                lda 0020
                clc
                adc #10
                sta 7e3012
                plp
                rts

;**************************************
; def init_bg3_title_buffer()
; @b7d0
;**************************************
;     S     p     e     e     d     :     0     0
3750: 33 30 50 30 45 30 45 30 44 30 1a 30 10 30 10 30
;     P     u     s     h           s     t     a     r     t
3760: 30 30 55 30 53 30 48 30 00 30 53 30 54 30 41 30 52 30 54 30 00 30
;     b     u     t     t     o     n
3776: 42 30 55 30 54 30 54 30 4f 30 4e 30
;     ©     v     i     v     i     1     6     8           2     0     1     9
3782: 5f 30 56 30 49 30 56 30 49 30 11 30 16 30 18 30 00 30 12 30 10 30 11 30 19 30
37d0:           nop

                ; @ a008
                ldx #0000
@speed_txt:     nop
                lda 80b750,x
                sta 7e3008,x
                inx
                inx
                cpx #0010
                bcc @speed_txt

                ; @ a080
                ldx #0000
@start_txt:     nop
                lda 80b760,x
                sta 7e3100,x
                inx
                inx
                cpx #0022
                bcc @start_txt

                ; @ a104
                ldx #0000
@copyr_txt:     nop
                lda 80b782,x
                sta 7e3284,x
                inx
                inx
                cpx #0022
                bcc @copyr_txt

                ; BG3 V/H offsets
                lda #80
                sta 2112
                stz 2112

                lda #c0
                sta 2111
                stz 2111

                rts

;**************************************
; def update_speed_display()
; @b840
;**************************************
3840:           php

                lda 000c        ; load speed
                pha             ; save it

                stz 0020        ; bcd ones
                stz 0021        ; bcd tens

                lda #14
                sec
                sbc 000c

                cmp #0a
                bcc @speed_one
                sec
                sbc #0a
                sta 000c
                inc 0021

@speed_one:     nop
                clc
                adc #10
                sta 7e3016

                lda 0021
                clc
                adc #10
                sta 7e3014

                pla             ; restore speed
                sta 000c

                plp
                rts

;**************************************
; def score_to_bcd()
; @c000
;**************************************
4000:           nop
                php

                stz 0020        ; score bcd ones
                stz 0021        ; score bcd tens
                stz 0022        ; score bcd hundreds
                stz 0023        ; score bcd thousands

                lda 0010
                tax
                cmp #000a
                bcc @ones

@bcdloop:       nop

@thousands:     cmp #03e8
                bcc @hundreds
                sec
                sbc #03e8
                sta 0010
                inc 0023
                bra @bcdloop
@hundreds:      nop
                cmp #0064
                bcc @tens
                sec
                sbc #0064
                sta 0010
                inc 0022
                bra @bcdloop
@tens:          nop
                cmp #000a
                bcc @ones
                sec
                sbc #000a
                sta 0010
                inc 0021
                bra @bcdloop

@ones:          nop
                sep #20
                lda 0010
                sta 0020
                stx 0010

                plp
                rts

;**************************************
; def oam_buf_init()
; Init OAM Dummy Buffer WRAM
; $oam_buffer_start = 7e2000
; @8300
;**************************************

0300:           php
                sep #20
                rep #10
                lda #01
                ldx #0000
@set_x_lsb:     sta 7e2000,x
                inx
                inx
                inx
                inx
                cpx #0200       ; $OAML_SIZE
                bne @set_x_lsb

                lda #55         ; 01010101
@set_x_msb:     sta 7e2000,x
                inx
                sta 7e2000,x
                inx
                cpx #0220       ; $OAM_SIZE
                bne @set_x_msb

                plp
                rts

;**************************************
; def oam_dma_transfer()
; OAM buffer - DMA Transfer
; m8 x16
; @8400
;**************************************

0400:           ldx #0000
                stx 2102        ; OAMDADDL

                lda #04         ; OAMDATA 21*04*
                sta 4301        ; BBAD0

                ; from 7e/2000
                ldx #2000
                stx 4302        ; A1T0L
                lda #7e
                sta 4304        ; A1T0B

                ; transfer 220 bytes
                ldx #0220
                stx 4305        ; DAS0L

                ; DMA params: A to B
                lda #00
                sta 4300        ; DMAP0
                ; initiate DMA via channel 0 (LSB = channel 0, MSB channel 7)
                lda #01
                sta 420b        ; MDMAEN
                rts

;**************************************
; def vram_dma_transfer(btt=07, rom_src_bank=09,
;                       rom_src_addr=0a, vram_dest_addr=0c)
; VRAM - DMA Transfer
; m8 x16
; @8430
;**************************************

0430:           phx             ; save stack pointer
                phd             ; save direct page
                tsc
                tcd             ; direct page = stack pointer

                ldx 0c          ; $vram_dest_addr
                stx 2116        ; VMADDL

                lda #18         ; VMDATAL 21*18*
                sta 4301

                ldx 0a          ; $rom_src_addr
                stx 4302
                lda 09          ; $rom_src_bank
                sta 4304

                ldx 07          ; $bytes_to_transfer
                stx 4305

                lda #01
                sta 4300

                lda #01
                sta 420b

                pld             ; restore direct page
                plx             ; restore stack pointer
                rts

;**************************************
; def cgram_dma_transfer(btt=07, rom_src_bank=08,
;                        rom_src_addr=09, cgram_dest_addr=0b)
; CGRAM - DMA Transfer
; m8 x16
; @8460
;**************************************

0460:           phx             ; save stack pointer
                phd             ; save direct page
                tsc
                tcd             ; direct page = stack pointer

                lda 0b
                sta 2121

                lda #22
                sta 4301

                ldx 09
                stx 4302
                lda 08
                sta 4304

                lda 07
                sta 4305

                lda #00
                sta 4300

                lda #01
                sta 420b

                pld
                plx
                rts

;**************************************
; def read_joy_pad_1()
; Read Joy Pad 1
; @8500
;**************************************
0500:           php
@read_data:     lda 4212        ; read joypad status (HVBJOY)
                and #01
                bne @read_data  ; read done when 0

                rep #30         ; m16, x16

                ldx 0100        ; read previous frame raw input (JOY1_RAWL)
                lda 4218        ; read current frame raw input (JOY1L)
                sta 0100        ; save it
                txa             ; move previous frame raw input to A
                eor 0100        ; XOR previous with current, get changes. Held and unpressed become 0
                and 0100        ; AND previous with current, only pressed left to 1
                sta 0102        ; store pressed (JOY1_PRESSL)
                txa             ; move previous frame raw input to A
                and 0100        ; AND with current, only held are left to 1
                sta 0104        ; stored held (JOY1_HELDL)

                plp
                rts


;**************************************
; def reset_tilemap_buffer()
; @8550
;**************************************
0550:           ldx #0000
                lda #00

@reset_tm:      nop
                sta 7e2300,x
                inx
                cpx #0800
                bne @reset_tm
                rts

;**************************************
; def oam_initial_settings()
; @8570
;**************************************
0570:           nop
                ; Init apple and head positions/sprite name here
                ; Snake head, first sprite in OAM (name 2, second sprite in rom)
                ldx #0000
                lda #50
                sta 7e2000,x    ; X pos (lsb)
                inx
                lda #5f
                sta 7e2000,x    ; Y pos
                inx
                lda #02
                sta 7e2000,x    ; name lsb
                inx
                lda #30
                sta 7e2000,x    ; flip/prio/color/name msb
                inx
                ; Snake tail, third sprite in OAM (name 6)
                lda #20
                sta 7e2000,x    ; X pos (lsb)
                inx
                lda #5f
                sta 7e2000,x    ; Y pos
                inx
                lda #06
                sta 7e2000,x    ; name lsb
                inx
                lda #30
                sta 7e2000,x    ; flip/prio/color/name msb
                inx
                ; Apple, third sprite in OAM (name 0).
                ; must be last to appear beneath snake head
                lda #10
                sta 7e2000,x    ; X pos (lsb)
                inx
                lda #20
                sta 7e2000,x    ; Y pos
                inx
                lda #00
                sta 7e2000,x    ; name lsb
                inx
                lda #00         ; low priority
                sta 7e2000,x    ; flip/prio/color/name msb
                inx

                lda #40         ; 0100_0000
                sta 7e2200      ; X pos msb and size for first 3 sprites
                rts

;**************************************
; def init_game_bg_settings()
; @85e0
;**************************************
05e0:           nop

                jsr 8660

                lda #80
                sta 2100        ; INIDISP
                stz 4200        ; NMITIMEN

                ; BG settings
                lda #09
                sta 2105        ; BGMODE 1, BG3 priority high

                lda #10         ; BG1 MAP @ VRAM[2000]
                sta 2107        ; BG1SC
                lda #50         ; BG3 map @ VRAM[a000]
                sta 2109        ; BG3SC

                lda #00         ; BG1 tiles @ VRAM[0000]
                sta 210b        ; BG12NBA
                lda #04         ; BG3 tiles @ VRAM[8000]
                sta 210c        ; BG34NBA

                ; BG3 V/H offsets
                lda #fd
                sta 2112
                stz 2112

                lda #ff
                sta 2111
                stz 2111

                lda #15         ; enable sprites, BG1&3
                sta 212c        ; TM

                ;**************************************
                ; OAM / VRAM init here
                ;**************************************
                ; init a dummy buffer in WRAM
                jsr 8300        ; @oam_buf_init
                jsr 8570        ; @oam_initial_settings
                jsr 8550        ; @reset WRAM tilemap buffer
                jsr b620        ; @init_bg3_tilemap_buffer
                jsr b640        ; @init_bg3_score_buffer

                jsr aa20        ; @update_oam_buffer_from_map_coord()
                jsr b500        ; update background buffer as well

                lda #00
                sta 2100        ; INIDISP
                lda #81
                sta 4200        ; NMITIMEN

                jsr 8640

                rts


;**************************************
; def fade_in()
; @8640
;**************************************
0640:           wai

                lda #00
                sta 2100        ; INIDISP

@fadein_lp:     nop
                inc
                sta 2100
                cmp #0f
                bcc @fadein_lp

                rts

;**************************************
; def fade_out()
; @8660
;**************************************
0660:           wai

                lda #0f
                sta 2100        ; INIDISP


@fadeout_lp:    nop
                dec
                sta 2100
                bne @fadeout_lp

                rts

;**************************************
; def dma_transfers()
; @87e0
;**************************************
07e0:           nop
                ; Copy snake-bg.bin to VRAM
                tsx             ; save stack pointer
                pea 0000        ; vram_dest_addr
                pea 8000        ; rom_src_addr
                lda #81         ; rom_src_bank
                pha
                pea 0800        ; bytes_to_trasnfer
                jsr 8430        ; @vram_dma_transfer
                txs             ; restore stack pointer
                ; Copy WRAM tilemap buffer to VRAM
                tsx             ; save stack pointer
                pea 1000        ; vram_dest_addr (@2000 really, word steps)
                pea 2300        ; rom_src_addr
                lda #7e         ; rom_src_bank
                pha
                pea 0800        ; bytes_to_trasnfer
                jsr 8430        ; @vram_dma_transfer
                txs             ; restore stack pointer
                ; Copy snake-sprites.bin to VRAM
                tsx             ; save stack pointer
                pea 2000        ; vram_dest_addr
                pea 8800        ; rom_src_addr
                lda #81         ; rom_src_bank
                pha
                pea 0800        ; bytes_to_trasnfer
                jsr 8430        ; @vram_dma_transfer
                txs             ; restore stack pointer
                ; Copy small-font.bin to VRAM
                tsx             ; save stack pointer
                pea 4000        ; vram_dest_addr (@8000 really, word steps)
                pea b840        ; rom_src_addr
                lda #81         ; rom_src_bank
                pha
                pea 0600        ; bytes_to_trasnfer
                jsr 8430        ; @vram_dma_transfer
                txs             ; restore stack pointer
                ; Copy title-screen.bin to VRAM
                tsx             ; save stack pointer
                pea 6000        ; vram_dest_addr (@c000 really, word steps)
                pea a040        ; rom_src_addr
                lda #81         ; rom_src_bank
                pha
                pea 1800        ; bytes_to_trasnfer
                jsr 8430        ; @vram_dma_transfer
                txs             ; restore stack pointer
                ; Copy title-screen.map to VRAM
                tsx             ; save stack pointer
                pea 7000        ; vram_dest_addr (@e000 really, word steps)
                pea 9840        ; rom_src_addr
                lda #81         ; rom_src_bank
                pha
                pea 0800        ; bytes_to_trasnfer
                jsr 8430        ; @vram_dma_transfer
                txs             ; restore stack pointer

                ; Copy snake-bg-pal.bin to CGRAM
                tsx             ; save stack pointer
                lda #00
                pha             ; cgram_dest_addr
                pea 9000        ; rom_src_addr
                lda #81
                pha             ; rom_src_bank
                lda #20
                pha             ; bytes_to_trasnfer
                jsr 8460        ; @cgram_dma_transfer
                txs             ; restore stack pointer
                ; Copy small-font-pal.bin to CGRAM
                tsx             ; save stack pointer
                lda #10
                pha             ; cgram_dest_addr
                pea be60        ; rom_src_addr
                lda #81
                pha             ; rom_src_bank
                lda #08
                pha             ; bytes_to_trasnfer
                jsr 8460        ; @cgram_dma_transfer
                txs             ; restore stack pointer
                ; Copy title-screen-pal.bin to CGRAM
                tsx             ; save stack pointer
                lda #20
                pha             ; cgram_dest_addr
                pea be40        ; rom_src_addr
                lda #81
                pha             ; rom_src_bank
                lda #20
                pha             ; bytes_to_trasnfer
                jsr 8460        ; @cgram_dma_transfer
                txs             ; restore stack pointer
                ; Copy snake-sprites-pal.bin to CGRAM
                tsx             ; save stack pointer
                lda #80
                pha             ; cgram_dest_addr
                pea 9020        ; rom_src_addr
                lda #81
                pha             ; rom_src_bank
                lda #20
                pha             ; bytes_to_trasnfer
                jsr 8460        ; @cgram_dma_transfer
                txs             ; restore stack pointer
                rts

;**************************************
; def clear_registers()
; Clear each Registers
; @8e00
;**************************************

0e00:           stz 2101
                stz 2102
                stz 2103
                stz 2105
                stz 2106
                stz 2107
                stz 2108
                stz 2109
                stz 210a
                stz 210b
                stz 210c

                rep #20

                stz 210d
                stz 210d
                stz 210e
                stz 210e
                stz 210f
                stz 210f
                stz 2110
                stz 2110
                stz 2111
                stz 2111
                stz 2112
                stz 2112
                stz 2113
                stz 2113
                stz 2114
                stz 2114

                sep #20

                lda #80
                sta 2115
                stz 2116
                stz 2117
                stz 211a

                rep #20

                lda #0001
                sta 211b
                stz 211c
                stz 211d
                sta 211e
                stz 211f
                stz 2120

                sep #20

                stz 2121
                stz 2123
                stz 2124
                stz 2125
                stz 2126
                stz 2127
                stz 2128
                stz 2129
                stz 212a
                stz 212b
                lda #01
                sta 212c
                stz 212d
                stz 212e
                stz 212f
                lda #30
                sta 2130
                stz 2131
                lda #e0
                sta 2132
                stz 2133

                stz 4200
                lda #ff
                sta 4201
                stz 4202
                stz 4203
                stz 4204
                stz 4205
                stz 4206
                stz 4207
                stz 4208
                stz 4209
                stz 420a
                stz 420b
                stz 420c
                stz 420d

                rts

;**************************************
; def clear_custom_registers()
; @8e00
;**************************************
0ed0:           stz 0000        ; clear frame counter
                stz 0001        ; clear random seed
                lda #02
                sta 0006        ; init body size
                stz 0012        ; clear seed read?

                stz 000b        ; move counter
                lda #0a
                sta 000c        ; base speed
                lda #00
                sta 000d        ; base speed
                stz 000e        ; x vel
                stz 000f        ; y vel
                stz 0010        ; score L
                stz 0011        ; score H

                ; initialize head/tail position
                lda #05         ; head x
                sta 0007
                lda #02         ; tail x
                sta 0009
                lda #06         ; head/tail y
                sta 0008
                sta 000a
                ; first two body parts y
                sta 7e0201
                sta 7e0203
                ; first two body part x
                lda #04
                sta 7e0200
                lda #03
                sta 7e0202

                ; initial apple coordinates
                stz 0004
                stz 0005

                rts

;**************************************
;
; ROM registration data (addresses are offset by 0x8000)
;
;**************************************

; zero bytes
7fb0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

; game title "SUPER SNAKE          "
7fc0: 53 55 50 45 52 20 53 4e 41 4b 45 20 20 20 20 20 20 20 20 20 20

; map mode
7fd5: 20

; cartridge type
7fd6: 00

; ROM size
7fd7: 09

; RAM size
7fd8: 00

; destination code
7fd9: 00

; fixed value
7fda: 33

; mask ROM version
7fdb: 00

; checksum complement
7fdc: 00 00

; checksum
7fde: 00 00

;**************************************
;
; Vectors
;
;**************************************

; zero bytes
7fe0: 00 00 00 00

; 65816 mode
7fe4: 00 00 ; COP
7fe6: 50 81 ; BRK
7fe8: 00 00
7fea: 00 82 ; NMI
7fec: 00 00
7fee: 00 00 ; IRQ

; zero bytes
7ff0: 00 00 00 00

; 6502 mode
7ff4: 00 00 ; COP
7ff6: 00 00
7ff8: 00 00
7ffa: 00 00 ; NMI
7ffc: 00 80 ; RESET
7ffe: 00 00 ; IRQ/BRK
