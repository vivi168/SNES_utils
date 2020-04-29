;**************************************
;
; Snake SNES
;
;**************************************

.65816

.org 818000
.base 8000

snake_bg:
    .incbin assets/snake-bg.bin             ; 0x800
snake_sprite:
    .incbin assets/snake-sprites.bin        ; 0x800
snake_bg_pal:
    .incbin assets/snake-bg-pal.bin         ; 0x20
snake_sprite_pal:
    .incbin assets/snake-sprites-pal.bin    ; 0x20
random_bin:
    .incbin assets/random.bin               ; 0x800
title_screen_map:
    .incbin assets/title-screen.map         ; 0x800
title_screen:
    .incbin assets/title-screen.bin         ; 0x1800
small_font:
    .incbin assets/small-font.bin           ; 0x600
title_screen_pal:
    .incbin assets/title-screen-pal.bin     ; 0x20
small_font_pal:
    .incbin assets/small-font-pal.bin       ; 0x08

;**************************************
; WRAM addresses
;**************************************
; all coord are stored as map coordinate ([0,15], [0,13])
; map coord = random coord >> 4
.org 7e0000
; 7e0000: frame counter
frame_counter:   .rb 1
; 7e0001: random seed
random_seed:   .rb 1
; 7e0002: random x pointer
random_x_pointer:   .rb 1
; 7e0003: random y pointer
random_y_pointer:   .rb 1
; 7e0004: apple x coord
apple_x:   .rb 1
; 7e0005: apple y coord
apple_y:   .rb 1
; 7e0006: body size
body_size:   .rb 1
; 7e0007: head x coord
head_x:   .rb 1
; 7e0008: head y coord
head_y:   .rb 1
; 7e0009: tail x coord
tail_x:   .rb 1
; 7e000a: tail y coord
tail_y:   .rb 1
; 7e000b: last move counter
last_move_counter:   .rb 1
; 7e000c: base speed
base_speed:   .rb 2
; 7e000e: x velocity
x_velocity:   .rb 1
; 7e000f: y velocity
y_velocity:   .rb 1
; 7e0010: score L
score:   .rb 2
; 7e0012: seed read?
seed_read:   .rb 1

; 7e0013: body size buffer
body_size_buffer:   .rb 2
; 7e0015: tile coord buffer
tile_coord_buffer:   .rb 2

; 7e0017: timer frame counter
timer_frame_counter:   .rb 1
; 7e0018: timer second
timer_second:   .rb 1
; 7e0019: timer buffer
timer_buffer:   .rb 1

; 7e001a: score ones
score_bcd:      .rb 4
; 7e0100: JOY1_RAW
joy1_raw:   .rb 2
; 7e0102: JOY1_PRESSL
joy1_press:   .rb 2
; 7e0104: JOY1_HELDL
joy1_held:   .rb 2

; 7e0200: snake body xy coord
snake_body_xy_coords:   .rb 1

.org 7e2000
; coord converted from map coord to screen coord
; screen coord = map coord << 4
; 7e2000: oam buffer
oam_buffer:   .rb 300
; map coord to VRAM tile index:
; 16x16 tile is composed of 4 8x8 tiles:
; 0|1 => tile 0 = (x << 2) + (y << 7), tile 1 = tile 0 + 2
; -+-
; 2|3 => tile 2 = tile 0 + 0x40, tile 3 = tile 2 + 2
;
; 7e2300: snake body tile buffer
snake_body_tile_buffer:   .rb d00
; 7e3000: BG3 tile buffer
bg3_tile_buffer:         .rb 1
; BG tile = vhopppcc cccccccc
;**************************************
; ROUTINES LOCATION
;**************************************
; game engine routines are in first page
; game logic routines are in second page


;**************************************
; Reset @ 8000
;**************************************
.org 808000
.base 0000

ResetVector:
                sei
                clc
                xce
                sep #20         ; M8
                rep #10         ; X16

                ldx #1fff
                txs             ; set stack pointer to 1fff

                ; Forced Blank
                lda #80
                sta 2100        ; INIDISP

                jsr @ClearRegisters
                jsr @ClearCustomRegisters

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

                ; window setting start
                ; lda #33
                ; sta 2123
                ; sta 2124
                ; sta 2125

                ; lda #08
                ; sta 2126
                ; lda #f7
                ; sta 2127
                ; lda #1f
                ; sta 212e
                ; windowing setting end

                lda #05         ; enable BG1&3
                sta 212c        ; TM

                jsr @InitBg3TilemapBuffer
                jsr @InitBg3MenuText

                ;**************************************
                ; DMA transfers
                ;**************************************
                ; transfer buffer to OAMRAM
                jsr @TransferOamBuffer
                jsr @DmaTransfers

                ; SPC 700
                jsr @SpcUploadRoutine

;**************************************
; Final setting before starting gameloop
;**************************************
                ; release forced blanking, set screen to full brightness
                lda #0f
                sta 2100        ; INIDISP

                ; enable NMI, turn on automatic joypad polling
                lda #81
                sta 4200        ; NMITIMEN

                cli
                jmp @MenuLoop

;**************************************
; BRK @ 8150
;**************************************
.org 808150
.base 0150

BreakVector:
                rti

;**************************************
; NMI @ 8200
;**************************************
.org 808200
.base 200

NmiVector:
                lda 4210        ; RDNMI
                inc 0000        ; increase frame counter

                ; timer
                inc 0017
                lda 0017
                cmp #3c
                bne @timer_done
                stz 0017
                inc 0018        ; increase second counter
timer_done:
                inc 000b        ; increase snake should move?

                ; update oam
                jsr @TransferOamBuffer
                ; TODO: reuse dma_transfers routine
                ; update vram (snake body tilemap)
                tsx             ; save stack pointer
                pea 1000        ; vram_dest_addr
                pea 2300        ; rom_src_addr
                lda #7e         ; rom_src_bank
                pha
                pea 0800        ; bytes_to_trasnfer
                jsr @VramDmaTransfer
                txs             ; restore stack pointer
                ; update vram (bg3 tilemap)
                tsx             ; save stack pointer
                pea 5000        ; vram_dest_addr
                pea 3000        ; rom_src_addr
                lda #7e         ; rom_src_bank
                pha
                pea 0800        ; bytes_to_trasnfer
                jsr @VramDmaTransfer
                txs             ; restore stack pointer

                ; HDMA test here
                jsr @HdmaTest

                jsr @ReadJoyPad1
                rti

;**************************************
; Menu screen loop (wait for user to press enter)
; Can increase/decrease speed with up/down arrows
;**************************************
MenuLoop:
                wai
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

dec_speed:
                lda 0103
                bit #04
                beq @speed_done
                inc 000c        ; higher base speed, slower snake moves
                lda 000c
                cmp #13         ; minimum speed is 0x13
                bcc @speed_done
                lda #13
                sta 000c

speed_done:
                jsr @UpdateMenuSpeedDisplayValue

                lda 0103
                bit #10         ; check if start is pressed
                beq @loop_menu

                ; start has been pressed
                jsr @InitRandomSeed
                jsr @RandomAppleCoordinates
                jsr @UpdateOamBufferFromMapCoords
                jsr @SetBgInitialSettings
                jmp @GameLoop

loop_menu:
                jmp @MenuLoop

;**************************************
; in game loop check for DPAD. change velocity, then
; check wall colision/body collision with head => game over
; check apple colision with head, score increase
; TODO if start is pressed in gameloop, jump to pause loop.
; TODO if start is pressed in pause loop, jump to gameloop
;**************************************
GameLoop:
                wai
                jsr @HandlePlayerInput

                lda 000b
                cmp 000c        ; skip if move counter < speed?
                bcc @continue_gl
                ldx 000e        ; skip if velocity is 0
                beq @continue_gl

                jsr @UpdateSnakeBody
                jsr @UpdateSnakeHeadDirection
                jsr @UpdateSnakeTailDirection

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

continue_gl:
                jsr @CheckEatApple
                jsr @CheckWallCollision
                jsr @EatSelf

                jsr @UpdateOamBufferFromMapCoords
                jsr @UpdateSnakeBodyTileMapBuffer

                jmp @GameLoop

;**************************************
; Game over loop
; wait 2 sec and jump to reset
;**************************************
GameOverLoop:
                wai
                jsr @SaveScoreToSram

                lda 0018        ; load second counter
                clc
                adc #02         ; add 2 seconds
                sta 0019        ; save it

check_time:
                lda 0019
                cmp 0018
                bne @check_time ; have 2 seconds elapsed yet?

                jmp @ResetVector

;**************************************
; Init the random seed.
; Set initial x and y pointer
;**************************************
InitRandomSeed:
                lda 0012        ; check if seed was read
                bne @rts_irs    ; if non zero, it was read
                lda 0000        ; else, load frame counter
                bne @save_rs
                inc             ; ensure non zero result
save_rs:
                sta 0001        ; save it as a random seed
                sta 0002        ; initial x pointer = seed
                dec
                sta 0003        ; initial y pointer = seed - 1

rts_irs:
                lda #01         ; seed was read (1)
                sta 0012
                rts

;**************************************
; Get next pseudo random apple coordinate
;**************************************
RandomAppleCoordinates:
                php
next_appl:
                sep #30         ; m8 x8
                ldx 0002        ; load x pointer
                lda !random_bin,x    ; load corresponding value
                lsr
                lsr
                lsr
                lsr
                sta 0004        ; save it to apple x coord
                inx
                stx 0002        ; next x pointer = x pointer + 1

                ldx 0003        ; load y pointer
                lda !random_bin,x    ; load corresponding value
                cmp #e0
                bcc @save_y_appl
                ; if apple.y >= 224, apple.y -= 32
                ; (screen is only 224 high)
                sec
                sbc #20
save_y_appl:
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
                jsr @CheckBodyCollision
                plx
                cmp #01
                beq @next_appl

                plp
                rts

;**************************************
; args: point = 05
; result in A
;**************************************
MapToScreenCoordinates:
                phd
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
; this routine update head/tail and
; apple oam buffer entries from their
; map coord
;**************************************
; coord pairs (RAM map coord/OAM buffer screen coord)
CoordinatesPairs:
    .db 07,00,00,20,08,00,01,20 ; head 7e0007,8 > 7e2000,1
    .db 09,00,04,20,0a,00,05,20 ; tail 7e0009,a > 7e2004,5
    .db 04,00,08,20,05,00,09,20 ; apple 7e0004,5 > 7e2008,9

UpdateOamBufferFromMapCoords:
                phd
                php
                phb

                rep #30         ; m 16 x 16
                lda #@CoordinatesPairs       ; index DP @ coord pairs array
                tcd
                sep #20         ; m 8

                lda #7e
                pha
                plb             ; dbr = 7e
                ldy #0006
                ldx #0000

oam_update_loop:
                lda (00,x)      ; load sprite map coord
                pha
                jsr @MapToScreenCoordinates
                sta (02,x)      ; save it to oam
                pla
                inx
                inx
                inx
                inx
                dey
                bne @oam_update_loop

                ; sprites are not vertically aligned with background
                dec 2001
                dec 2005
                dec 2009

                plb
                plp
                pld
                rts

;**************************************
; handle player input
; up 8
; down 4
; left 2
; right 1
; #TODO: queue up movement so snake won't eat
; himself when pressing down/left quickly for example
;**************************************

HandlePlayerInput:
                lda 0103        ; JOY1_PRESSH

                bit #08
                bne @move_up

                bit #04
                bne @move_down

                bit #02
                bne @move_left

                bit #01
                bne @move_right

                rts
move_up:
                lda 000f        ; don't allow switching direction in same axis
                bne @rts_handle_input
                lda #ff
                stz 000e
                sta 000f
                rts
move_down:
                lda 000f
                bne @rts_handle_input
                lda #01
                stz 000e
                sta 000f
                rts
move_left:
                lda 000e
                bne @rts_handle_input
                lda #ff
                sta 000e
                stz 000f
                rts
move_right:
                lda 000e
                bne @rts_handle_input
                lda #01
                sta 000e
                stz 000f

rts_handle_input:
                rts


;**************************************
; TODO maybe refactor, bit ugly?
;**************************************
UpdateSnakeHeadDirection:
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
skip_head_hf:
                lda 7e2003
                and #3f
                sta 7e2003
                rts

check_h_vert:
                lda 000f        ; yvel
                beq @rts_ushd
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
skip_head_vf:
                lda 7e2003
                and #3f
                sta 7e2003

rts_ushd:
                rts

;**************************************
; TODO: refactor. Can spare cycles by
; better branching organization
;**************************************
UpdateSnakeTailDirection:
                php

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
                bra @rts_ustd

                ; body.x < tail.x
bx_lt_tx:
                lda 7e2007
                and #3f
                ora #40
                sta 7e2007
                bra @rts_ustd

cmp_y:
                inx
                lda 7e0200,x    ; last body y
                cmp 000a
                beq @rts_ustd

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
                bra @rts_ustd

                ; body.y < tail.y
by_lt_ty:
                lda 7e2007
                and #3f
                sta 7e2007
rts_ustd:
                plp
                rts

;**************************************
; this routine update snake body (7e0200)
; and tail, after a head movement
; @b000
;**************************************
UpdateSnakeBody:
                php

                lda 0006        ; load body size
                rep #30
                and #00ff       ; discard accumulator high byte
                dec
                asl             ; each coord entry is 2 bytes
                tax

                ; tail takes place of last body part
                lda 7e0200,x
                sta 0009

update_body_x:
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
; check apple collision +
; increase body size + append a body part
;**************************************
CheckEatApple:
                php

                ldx 0004        ; apple xy
                cpx 0007        ; head xy
                bne @did_not_eat_apple

                jsr @RandomAppleCoordinates

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
                jsr @ConvertScoreToBcd
                jsr @UpdateScore

did_not_eat_apple:
                plp
                rts

;**************************************
; Check wall collisions
;**************************************
CheckWallCollision:
                lda 0007        ; head x
                cmp #00
                bcc @wall_hit
                cmp #10         ; $SCREEN_W
                bcs @wall_hit

                ; left edge < x < right edge
                lda 0008
                cmp #00
                bcc @wall_hit
                cmp #0e         ; $SCREEN_H
                bcs @wall_hit

                ; top edge < y < bottom edge
                rts
wall_hit:
                jmp @GameOverLoop

;**************************************
; check if a xy pair collides with a body xy pair
; args: xy = 08
; result in A
;**************************************
CheckBodyCollision:
                phx
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
check_collision:
                lda 7e0200,x
                cmp 08          ; compare param xy to body xy
                beq @collides

                dex
                dex
                bpl @check_collision

                lda #0000
                bra @did_not_collide
collides:
                lda #0001
did_not_collide:
                plp
                pld
                plx
                rts

;**************************************
; Eat self?
;**************************************
EatSelf:
                ldx 0007
                phx
                jsr @CheckBodyCollision
                plx

                cmp #01
                bne @ate_self
                jmp @GameOverLoop

ate_self:
                rts

;**************************************
; this routine update tilemap WRAM buffer
; from snake body array located at 7e0200
;**************************************
UpdateSnakeBodyTileMapBuffer:
                php

                ldx #0000

                lda 0006
                rep #30
                and #00ff
                asl
                sta 0013

update_tilemap_buffer:
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
                bne @update_tilemap_buffer

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
; Init the background 3 with empty text
;     vhopppcc
; 30: 00110000
;**************************************
InitBg3TilemapBuffer:
                php

                rep #30

                lda #3000
                ldx #0800

reset_bg3:
                sta 7e3000,x
                dex
                dex
                bpl @reset_bg3

                plp
                rts

;**************************************
; init background 3 with score text
;**************************************
ScoreText:
;       S     C     O     R     E     :
    .db 33,30,23,30,2f,30,32,30,25,30,1a,30
;       0     0     0     0
    .db 10,30,10,30,10,30,10,30

InitBg3ScoreText:
                php
                rep #30
                ldx #0000

init_default_txt:
                brk 00
                lda @ScoreText,x
                sta 7e3000,x
                inx
                inx
                cpx #0014
                bne @init_default_txt

                plp
                rts

;**************************************
; update score from BCD buffer
;**************************************
UpdateScore:
                php
                sep #20

                lda @score_bcd+3
                clc
                adc #10
                sta 7e300c

                lda @score_bcd+2
                clc
                adc #10
                sta 7e300e

                lda @score_bcd+1
                clc
                adc #10
                sta 7e3010

                lda @score_bcd
                clc
                adc #10
                sta 7e3012
                plp
                rts

;**************************************
; TODO: use end of string character
; make a print routine
;**************************************
MenuSpeedText:
;       S     p     e     e     d     :     0     0
    .db 33,30,50,30,45,30,45,30,44,30,1a,30,10,30,10,30
MenuPushStart:
;       P     u     s     h           s     t     a     r     t
    .db 30,30,55,30,53,30,48,30,00,30,53,30,54,30,41,30,52,30,54,30,00,30
;       b     u     t     t     o     n
    .db 42,30,55,30,54,30,54,30,4f,30,4e,30
MenuCopyrightText:
;       ©     v     i     v     i     1     6     8           2     0     1     9
    .db 5f,30,56,30,49,30,56,30,49,30,11,30,16,30,18,30,00,30,12,30,10,30,11,30,19,30

InitBg3MenuText:
                ; @ a008
                ldx #0000
speed_txt:
                lda @MenuSpeedText,x
                sta 7e3008,x
                inx
                inx
                cpx #0010
                bcc @speed_txt

                ; @ a080
                ldx #0000
start_txt:
                lda @MenuPushStart,x
                sta 7e3100,x
                inx
                inx
                cpx #0022
                bcc @start_txt

                ; @ a104
                ldx #0000
copyr_txt:
                lda @MenuCopyrightText,x
                sta 7e3284,x
                inx
                inx
                cpx #001a
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
; Update menu speed display value
;**************************************
UpdateMenuSpeedDisplayValue:
                php

                lda 000c        ; load speed
                pha             ; save it

                stz @score_bcd        ; bcd ones
                stz @score_bcd+1      ; bcd tens

                lda #14
                sec
                sbc 000c

                cmp #0a
                bcc @speed_one
                sec
                sbc #0a
                sta 000c
                inc @score_bcd+1

speed_one:
                clc
                adc #10
                sta 7e3016

                lda @score_bcd+1
                clc
                adc #10
                sta 7e3014

                pla             ; restore speed
                sta 000c

                plp
                rts

;**************************************
; Convert score to BCD
;**************************************
ConvertScoreToBcd:
                php

                stz @score_bcd        ; score bcd ones
                stz @score_bcd+1      ; score bcd tens
                stz @score_bcd+2      ; score bcd hundreds
                stz @score_bcd+3      ; score bcd thousands

                lda 0010
                tax
                cmp #000a
                bcc @ones

bcd_loop:
thousands:
                cmp #03e8
                bcc @hundreds
                sec
                sbc #03e8
                sta @score
                inc @score_bcd+3
                bra @bcd_loop
hundreds:
                cmp #0064
                bcc @tens
                sec
                sbc #0064
                sta @score
                inc @score_bcd+2
                bra @bcd_loop
tens:
                cmp #000a
                bcc @ones
                sec
                sbc #000a
                sta @score
                inc @score_bcd+1
                bra @bcd_loop
ones:
                sep #20
                lda @score
                sta @score_bcd
                stx @score

                plp
                rts

;**************************************
; Init OAM Dummy Buffer WRAM
; $oam_buffer_start = 7e2000
;**************************************
InitOamBuffer:
                php
                sep #20
                rep #10
                lda #01
                ldx #0000
set_x_lsb:
                sta 7e2000,x
                inx
                inx
                inx
                inx
                cpx #0200       ; $OAML_SIZE
                bne @set_x_lsb

                lda #55         ; 01010101
set_x_msb:
                sta 7e2000,x
                inx
                sta 7e2000,x
                inx
                cpx #0220       ; $OAM_SIZE
                bne @set_x_msb

                plp
                rts

;**************************************
; OAM buffer - DMA Transfer
; m8 x16
;**************************************
TransferOamBuffer:
                ldx #0000
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
;**************************************
VramDmaTransfer:
                phx             ; save stack pointer
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
;**************************************
CgramDmaTransfer:
                phx             ; save stack pointer
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

; HDMA test
HdmaTest:
                php
                sep #20 ; a 8
                rep #10 ; i 16

                ; via channel 3
                lda #^HdmaTable     ; source bank
                sta 4334
                ldx #@HdmaTable    ; source address
                stx 4332
                lda #00      ; via port 21*26*
                sta 4331
                lda #00     ; ch3 properties
                sta 4330
                lda #08     ; activate channel 3 (0000 1000)
                sta 420c

                plp
                rts

HdmaTable:
    .db 18, 0f
    .db 18, 0e
    .db 18, 0d
    .db 18, 0c
    .db 18, 0b
    .db 18, 0a
    .db 18, 09
    .db 18, 08
    .db 18, 07, 00

;**************************************
; Read Joy Pad 1
;**************************************
ReadJoyPad1:
                php
read_data:
                lda 4212        ; read joypad status (HVBJOY)
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
; Reset tilemap buffer
;**************************************
ResetTileMapBuffer:
                ldx #0000
                lda #00

reset_tm:
                sta 7e2300,x
                inx
                cpx #0800
                bne @reset_tm
                rts

;**************************************
; def oam_initial_settings()
;**************************************
SetOamBufferInitialValues:
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
                lda #30         ; low priority
                sta 7e2000,x    ; flip/prio/color/name msb
                inx

                lda #40         ; 0100_0000
                sta 7e2200      ; X pos msb and size for first 3 sprites
                rts

;**************************************
; Set BGs initial settings
;**************************************
SetBgInitialSettings:
                jsr @FadeOut

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
                jsr @InitOamBuffer
                jsr @SetOamBufferInitialValues
                jsr @ResetTileMapBuffer
                jsr @InitBg3TilemapBuffer
                jsr @InitBg3ScoreText

                jsr @UpdateOamBufferFromMapCoords
                jsr @UpdateSnakeBodyTileMapBuffer

                lda #00
                sta 2100        ; INIDISP
                lda #81
                sta 4200        ; NMITIMEN

                jsr @FadeIn

                rts

;**************************************
; Fade in
;**************************************
FadeIn:
                wai
                lda #00
                sta 2100        ; INIDISP
fadein_loop:
                inc
                sta 2100
                cmp #0f
                bcc @fadein_loop

                rts

;**************************************
; Fade out
;**************************************
FadeOut:
                wai
                lda #0f
                sta 2100        ; INIDISP
fadeout_loop:
                dec
                sta 2100
                bne @fadeout_loop

                rts

;**************************************
; DMA transfers
;**************************************
DmaTransfers:
                ; Copy snake-bg.bin to VRAM
                tsx             ; save stack pointer
                pea 0000        ; vram_dest_addr
                pea @snake_bg
                lda #^snake_bg
                pha
                pea 0800        ; bytes_to_trasnfer
                jsr @VramDmaTransfer
                txs             ; restore stack pointer

                ; Copy WRAM tilemap buffer to VRAM
                tsx             ; save stack pointer
                pea 1000        ; vram_dest_addr (@2000 really, word steps)
                pea 2300        ; rom_src_addr
                lda #7e         ; rom_src_bank
                pha
                pea 0800        ; bytes_to_trasnfer
                jsr @VramDmaTransfer
                txs             ; restore stack pointer

                ; Copy snake-sprites.bin to VRAM
                tsx             ; save stack pointer
                pea 2000        ; vram_dest_addr
                pea @snake_sprite
                lda #^snake_sprite
                pha
                pea 0800        ; bytes_to_trasnfer
                jsr @VramDmaTransfer
                txs             ; restore stack pointer

                ; Copy small-font.bin to VRAM
                tsx             ; save stack pointer
                pea 4000        ; vram_dest_addr (@8000 really, word steps)
                pea @small_font
                lda #^small_font
                pha
                pea 0600        ; bytes_to_trasnfer
                jsr @VramDmaTransfer
                txs             ; restore stack pointer

                ; Copy title-screen.bin to VRAM
                tsx             ; save stack pointer
                pea 6000        ; vram_dest_addr (@c000 really, word steps)
                pea @title_screen
                lda #^title_screen
                pha
                pea 1800        ; bytes_to_trasnfer
                jsr @VramDmaTransfer
                txs             ; restore stack pointer

                ; Copy title-screen.map to VRAM
                tsx             ; save stack pointer
                pea 7000        ; vram_dest_addr (@e000 really, word steps)
                pea @title_screen_map
                lda #^title_screen_map
                pha
                pea 0800        ; bytes_to_trasnfer
                jsr @VramDmaTransfer
                txs             ; restore stack pointer

                ; Copy snake-bg-pal.bin to CGRAM
                tsx             ; save stack pointer
                lda #00
                pha             ; cgram_dest_addr
                pea @snake_bg_pal
                lda #^snake_bg_pal
                pha
                lda #20
                pha             ; bytes_to_trasnfer
                jsr @CgramDmaTransfer
                txs             ; restore stack pointer

                ; Copy small-font-pal.bin to CGRAM
                tsx             ; save stack pointer
                lda #10
                pha             ; cgram_dest_addr
                pea @small_font_pal
                lda #^small_font_pal
                pha
                lda #08
                pha             ; bytes_to_trasnfer
                jsr @CgramDmaTransfer
                txs             ; restore stack pointer

                ; Copy title-screen-pal.bin to CGRAM
                tsx             ; save stack pointer
                lda #20
                pha             ; cgram_dest_addr
                pea @title_screen_pal
                lda #^title_screen_pal
                pha
                lda #20
                pha             ; bytes_to_trasnfer
                jsr @CgramDmaTransfer
                txs             ; restore stack pointer

                ; Copy snake-sprites-pal.bin to CGRAM
                tsx             ; save stack pointer
                lda #80
                pha             ; cgram_dest_addr
                pea @snake_sprite_pal
                lda #^snake_sprite_pal
                pha
                lda #20
                pha             ; bytes_to_trasnfer
                jsr @CgramDmaTransfer
                txs             ; restore stack pointer
                rts

;**************************************
; Clear each Registers
; @8e00
;**************************************
ClearRegisters:
                stz 2101
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
                lda #01
                sta 420d

                rts

;**************************************
; Clear custom registers
;**************************************
ClearCustomRegisters:
                stz 0000        ; clear frame counter
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

                ; timer
                stz 0017
                stz 0018
                stz 0019

                rts

;**************************************
; write to SRAM
; 7e0010: score L
; 7e0011: score H
;**************************************
SaveScoreToSram:
                php
                phb             ; save dbr

                brk 00

                sep #20
                lda #f0
                pha
                plb             ; dbr = f0

                rep #30
                ; TODO: here implement save check
                ; if 0000 != DEAD, means it's
                ; uninitialized SRAM
                lda #dead
                cmp 0000
                beq @save_score
                sta 0000
                stz 0002        ; empty score first time
save_score:
                lda 7e0010      ; load score
                cmp 0002
                ; if score < saved score
                bcc @skip_save_score
                sta 0002        ; store it
skip_save_score:
                plb
                plp
                rts

;**************************************
; SPC upload
;**************************************
DummySpcData:
    .incbin assets/spc700_prog.bin

SpcUploadRoutine:
                php

                sep #20 ; a 8
                rep #10 ; i 16

                ldy #0000       ; retry counter

                ;  1. Wait for a 16-bit read on $2140-1 to return $BBAA.
retry_ack:
                ldx #bbaa
                cpx 2140
                beq @upload_spc ; wait until [2140] == bbaa (means spc700 is ready)
                dey
                bne @retry_ack
                bra @exit_spc_upl

                ; 2. Write the target address to $2142-3.
upload_spc:
                ldx #0600       ; target spc700 ram address
                stx 2142        ; [2142] = dest_addr (spc700 ram address)

                ; 3. Write non-zero to $2141.
                lda #01
                sta 2141        ; start command. can be any non zero value

                ; 4. Write $CC to $2140.
                ; 5. Wait until reading $2140 returns $CC.
write_cc:
                lda #cc
                sta 2140
                cmp 2140
                bne @write_cc ; wait until [2140] == cc (kick command)

                ldx #0039       ; data length (program size)
                ldy #0000       ; loop counter (index)

transfer_spc:
                lda @DummySpcData,y      ; src_addr[y]
                ; 6. Set your first byte to $2141.
                sta 2141        ; send data byte
                tya
                ; 7. Set your byte index ($00 for the first byte) to $2140.
                sta 2140        ; send index.lsb
                cmp 2140
                ; 8. Wait for $2140 to echo your byte index.
                bne @transfer_spc ; wait until [2140] == index.lsb
                iny
                dex
                ; 9. Go back to step 6 with your next byte and ++index until you're done.
                bne @transfer_spc

                ; jump to uploaded code
                ; Put the target address in $2142-3
jmp_upload:
                ldx #0600
                stx 2142
                ; Put $00 in $2141
                lda #00
                sta 2141
                ; Put index+2 in $2140
                tya
                inc
                inc
                ; wait for the echo
                sta 2140
                cmp 2140
                bne @jmp_upload
                ; Shortly afterwards, your code will be executing.

exit_spc_upl:
                plp
                rts

;**************************************
;
; ROM registration data (addresses are offset by 0x8000)
;
;**************************************
.org ffb0
.base 7fb0

; zero bytes
    .db 00,00,00,00,00,00,00,00,00,00,00,00,00,00,00,00
; game title "SUPER SNAKE          "
    .db 53,55,50,45,52,20,53,4e,41,4b,45,20,20,20,20,20,20,20,20,20,20
; map mode
    .db 30
; cartridge type
    .db 00
; ROM size
    .db 09
; RAM size
    .db 01
; destination code
    .db 00
; fixed value
    .db 33
; mask ROM version
    .db 00
; checksum complement
    .db 00,00
; checksum
    .db 00,00

;**************************************
;
; Vectors
;
;**************************************
.org ffe0
.base 7fe0

; zero bytes
    .db 00,00,00,00
; 65816 mode
    .db 00,00 ; COP
    .db 50,81 ; BRK
    .db 00,00
    .db 00,82 ; NMI
    .db 00,00
    .db 00,00 ; IRQ

; zero bytes
    .db 00,00,00,00
; 6502 mode
    .db 00,00 ; COP
    .db 00,00
    .db 00,00
    .db 00,00 ; NMI
    .db 00,80 ; RESET
    .db 00,00 ; IRQ/BRK
