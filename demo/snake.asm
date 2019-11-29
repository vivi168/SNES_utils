;**************************************
;
; Snake SNES
;
;**************************************

.65816

;**************************************
; Reset @ 8000
;**************************************

; 0000 @ bank 80 = 80/8000
0000:           sei
                clc
                xce
                sep #20         ; M8
                rep #10         ; X16

                ; Forced Blank
                lda #8f
                sta 2100        ; INIDISP

                jmp @clear

;**************************************
; Main Register Settings
;**************************************

                lda #63
                sta 2101        ; OBJSEL

                lda #01
                sta 2105        ; BGMODE

                lda #11
                sta 2107        ; BG1SC

                lda #00
                sta 210b        ; BG12NBA
                sta 210c        ; BG34NBA

                lda #11
                sta 212c        ; TM

                ; OAM / VRAM init here
                ; TODO

                ; release forced blanking, set screen to full brightness
                lda #0f
                sta 2100        ; INIDISP

                ; enable NMI, turn on automatic joypad polling
                lda #81
                sta 4200        ; NMITIMEN

                jmp @gameloop

;**************************************
; NMI @ 8100
;**************************************

0100:           lda 4210        ; RDNMI
                rti

;**************************************
; Game loop
;**************************************

@gameloop:      jmp @gameloop

;**************************************
; Clear each Registers
;**************************************

@clear:         stz 2101
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
                stz 210e
                stz 210f
                stz 2110
                stz 2111
                stz 2112
                stz 2113
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
;
; ROM registration data (addresses are offset by 0x8000)
;
;**************************************

; zero bytes
7fb0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

; game title "SNAKE SNES           "
7fc0: 53 4e 41 4b 45 20 53 4e 45 53 20 20 20 20 20 20 20 20 20 20 20

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
7fe6: 00 00 ; BRK
7fe8: 00 00
7fea: 00 81 ; NMI
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
