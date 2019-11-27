.65816

0000:   brk 11
        ora (11,x)
        cop 11
        ora 11,s
        tsb 11
        ora 11
        asl 11
        ora [11]
        php
        ora #11
        asl
        phd
        tsb 1122
        ora 1122
        asl 1122
        ora 112233
        bpl 0035 {+11}
        ora (11),y
        ora (11)
        ora (11,s),y
        trb 11
        ora 11,x
        asl 11,x
        ora [11],y
        clc
        ora 1122,y
        inc
        tcs
        trb 1122
        ora 1122,x
        asl 1122,x
        ora 112233,x
        jsr 1122
        and (11,x)
        jsl 112233
        and 11,s
        bit 11
        and 11
        rol 11
        and [11]
        plp
        and #11
        rol
        pld
        bit 1122
        and 1122
        rol 1122
        and 112233
        bmi 007d {+11}
        and (11),y
        and (11)
        and (11,s),y
        bit 11,x
        and 11,x
        rol 11,x
        and [11],y
        sec
        and 1122,y
        dec
        tsc
        bit 1122,x
        and 1122,x
        rol 1122,x
        and 112233,x
        rti
        eor (11,x)
        wdm 11
        eor 11,s
        mvp 11,22
        eor 11
        lsr 11
        eor [11]
        pha
        eor #11
        lsr
        phk
        jmp 1122
        eor 1122
        lsr 1122
        eor 112233
        bvc 00c2 {+11}
        eor (11),y
        eor (11)
        eor (11,s),y
        mvn 11,22
        eor 11,x
        lsr 11,x
        eor [11],y
        cli
        eor 1122,y
        phy
        tcd
        jmp 112233
        eor 1122,x
        lsr 1122,x
        eor 112233,x
        rts
        adc (11,x)
        per 11fc {+1122}
        adc 11,s
        stz 11
        adc 11
        ror 11
        adc [11]
        pla
        adc #11
        ror
        rtl
        jmp (1122)
        adc 1122
        ror 1122
        adc 112233
        bvs 0109 {+11}
        adc (11),y
        adc (11)
        adc (11,s),y
        stz 11,x
        adc 11,x
        ror 11,x
        adc [11],y
        sei
        adc 1122,y
        ply
        tdc
        jmp (1122,x)
        adc 1122,x
        ror 1122,x
        adc 112233,x
        bra 012c {+11}
        sta (11,x)
        brl 1242 {+1122}
        sta 11,s
        sty 11
        sta 11
        stx 11
        sta [11]
        dey
        bit #11
        txa
        phb
        sty 1122
        sta 1122
        stx 1122
        sta 112233
        bcc 014f {+11}
        sta (11),y
        sta (11)
        sta (11,s),y
        sty 11,x
        sta 11,x
        stx 11,y
        sta [11],y
        tya
        sta 1122,y
        txs
        txy
        stz 1122
        sta 1122,x
        stz 1122,x
        sta 112233,x
        ldy #11
        lda (11,x)
        ldx #11
        lda 11,s
        ldy 11
        lda 11
        ldx 11
        lda [11]
        tay
        lda #11
        tax
        plb
        ldy 1122
        lda 1122
        ldx 1122
        lda 112233
        bcs 0194 {+11}
        lda (11),y
        lda (11)
        lda (11,s),y
        ldy 11,x
        lda 11,x
        ldx 11,y
        lda [11],y
        clv
        lda 1122,y
        tsx
        tyx
        ldy 1122,x
        lda 1122,x
        ldx 1122,y
        lda 112233,x
        cpy #11
        cmp (11,x)
        rep #00
        cmp 11,s
        cpy 11
        cmp 11
        dec 11
        cmp [11]
        iny
        cmp #11
        dex
        wai
        cpy 1122
        cmp 1122
        dec 1122
        cmp 112233
        bne 01d9 {+11}
        cmp (11),y
        cmp (11)
        cmp (11,s),y
        pei 11
        cmp 11,x
        dec 11,x
        cmp [11],y
        cld
        cmp 1122,y
        phx
        stp
        jmp [1122]
        cmp 1122,x
        dec 1122,x
        cmp 112233,x
        cpx #11
        sbc (11,x)
        sep #00
        sbc 11,s
        cpx 11
        sbc 11
        inc 11
        sbc [11]
        inx
        sbc #11
        nop
        xba
        cpx 1122
        sbc 1122
        inc 1122
        sbc 112233
        beq 021e {+11}
        sbc (11),y
        sbc (11)
        sbc (11,s),y
        pea 1122
        sbc 11,x
        inc 11,x
        sbc [11],y
        sed
        sbc 1122,y
        plx
        xce
        jsr (1122,x)
        sbc 1122,x
        inc 1122,x
        sbc 112233,x