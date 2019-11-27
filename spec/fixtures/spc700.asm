.spc700

0000:   nop
        tcall 0
        set1  12.0
        bbs   12.0,003b {+34}
        or    a,12
        or    a,1234
        or    a,(x)
        or    a,[12+x]
        or    a,#12
        or    12<d>,34<s>
        or1   c,1234.5
        asl   12
        asl   1234
        push  psw
        tset1 1234
        brk
        bpl   0035 {+12}
        tcall 1
        clr1  12.0
        bbc   12.0,005d {+34}
        or    a,12+x
        or    a,1234+x
        or    a,1234+y
        or    a,[12]+y
        or    12,#34
        or    (x),(y)
        decw  12
        asl   12+x
        asl   a
        dec   x
        cmp   x,1234
        jmp   [1234+x]
        clrp
        tcall 2
        set1  12.1
        bbs   12.1,007e {+34}
        and   a,12
        and   a,1234
        and   a,(x)
        and   a,[12+x]
        and   a,#12
        and   12<d>,34<s>
        or1   c,/1234.5
        rol   12
        rol   1234
        push  a
        cbne  12,0097 {+34}
        bra   0077 {+12}
        bmi   0079 {+12}
        tcall 3
        clr1  12.1
        bbc   12.1,00a1 {+34}
        and   a,12+x
        and   a,1234+x
        and   a,1234+y
        and   a,[12]+y
        and   12,#34
        and   (x),(y)
        incw  12
        rol   12+x
        rol   a
        inc   x
        cmp   x,12
        call  1234
        setp
        tcall 4
        set1  12.2
        bbs   12.2,00c1 {+34}
        eor   a,12
        eor   a,1234
        eor   a,(x)
        eor   a,[12+x]
        eor   a,#12
        eor   12<d>,34<s>
        and1  c,1234.5
        lsr   12
        lsr   1234
        push  x
        tclr1 1234
        pcall 12
        bvc   00bc {+12}
        tcall 5
        clr1  12.2
        bbc   12.2,00e4 {+34}
        eor   a,12+x
        eor   a,1234+x
        eor   a,1234+y
        eor   a,[12]+y
        eor   12,#34
        eor   (x),(y)
        cmpw  ya,12
        lsr   12+x
        lsr   a
        mov   x,a
        cmp   y,1234
        jmp   1234
        clrc
        tcall 6
        set1  12.3
        bbs   12.3,0105 {+34}
        cmp   a,12
        cmp   a,1234
        cmp   a,(x)
        cmp   a,[12+x]
        cmp   a,#12
        cmp   12<d>,34<s>
        and1  c,/1234.5
        ror   12
        ror   1234
        push  y
        dbnz  12,011e {+34}
        ret
        bvs   00ff {+12}
        tcall 7
        clr1  12.3
        bbc   12.3,0127 {+34}
        cmp   a,12+x
        cmp   a,1234+x
        cmp   a,1234+y
        cmp   a,[12]+y
        cmp   12,#34
        cmp   (x),(y)
        addw  ya,12
        ror   12+x
        ror   a
        mov   a,x
        cmp   y,12
        reti
        setc
        tcall 8
        set1  12.4
        bbs   12.4,0145 {+34}
        adc   a,12
        adc   a,1234
        adc   a,(x)
        adc   a,[12+x]
        adc   a,#12
        adc   12<d>,34<s>
        eor1  c,1234.5
        dec   12
        dec   1234
        mov   y,#12
        pop   psw
        mov   12,#34
        bcc   0140 {+12}
        tcall 9
        clr1  12.4
        bbc   12.4,0168 {+34}
        adc   a,12+x
        adc   a,1234+x
        adc   a,1234+y
        adc   a,[12]+y
        adc   12,#34
        adc   (x),(y)
        subw  ya,12
        dec   12+x
        dec   a
        mov   x,sp
        div   ya,x
        xcn   a
        ei
        tcall 10
        set1  12.5
        bbs   12.5,0185 {+34}
        sbc   a,12
        sbc   a,1234
        sbc   a,(x)
        sbc   a,[12+x]
        sbc   a,#12
        sbc   12<d>,34<s>
        mov1  c,1234.5
        inc   12
        inc   1234
        cmp   y,#12
        pop   a
        mov   (x)+,a
        bcs   017e {+12}
        tcall 11
        clr1  12.5
        bbc   12.5,01a6 {+34}
        sbc   a,12+x
        sbc   a,1234+x
        sbc   a,1234+y
        sbc   a,[12]+y
        sbc   12,#34
        sbc   (x),(y)
        movw  ya,12
        inc   12+x
        inc   a
        mov   sp,x
        das   a
        mov   a,(x)+
        di
        tcall 12
        set1  12.6
        bbs   12.6,01c3 {+34}
        mov   12,a
        mov   1234,a
        mov   (x),a
        mov   [12+x],a
        cmp   x,#12
        mov   1234,x
        mov1  1234.5,c
        mov   12,y
        mov   1234,y
        mov   x,#12
        pop   x
        mul   ya
        bne   01bc {+12}
        tcall 13
        clr1  12.6
        bbc   12.6,01e4 {+34}
        mov   12+x,a
        mov   1234+x,a
        mov   1234+y,a
        mov   [12]+y,a
        mov   12,x
        mov   12+y,x
        movw  12,ya
        mov   12+x,y
        dec   y
        mov   a,y
        cbne  12+x,01fb {+34}
        daa   a
        clrv
        tcall 14
        set1  12.7
        bbs   12.7,0203 {+34}
        mov   a,12
        mov   a,1234
        mov   a,(x)
        mov   a,[12+x]
        mov   a,#12
        mov   x,1234
        not1  1234.5
        mov   y,12
        mov   y,1234
        notc
        pop   y
        sleep
        beq   01fb {+12}
        tcall 15
        clr1  12.7
        bbc   12.7,0223 {+34}
        mov   a,12+x
        mov   a,1234+x
        mov   a,1234+y
        mov   a,[12]+y
        mov   x,12
        mov   x,12+y
        mov   12<d>,34<s>
        mov   y,12+x
        inc   y
        mov   y,a
        dbnz  y,0218 {+12}
        stop