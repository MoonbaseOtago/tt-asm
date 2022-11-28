	mov	a, #0
	mov	x, #0x80
loop:	
	movd	7(x), a    	// a->f7
        mov	(x), a
        mov 	a, #1
        add 	a, (x)
        jne	a, loop

        mov	a, #0xa
        mov 	(x), a    

        mov	a, #0xc
        sub 	a, (x)
        movd	7(x), a    // a->f7

        mov	a, #0xc
        or  	a, (x)
        movd	7(x), a    // a->f7
        mov	a, #0xc
        and 	a, (x)
        movd	7(x), a    // a->f7

        mov	a, #0xc
        xor 	a, (x)
        movd	7(x), a    // a->f7

        mov 	a, (x)
        movd	7(x), a    // a->f7

        add 	a, #5
        movd	7(x), a    // f->f7

        mov 	x, #0x20
        swap 	y, x
        mov 	a, r0
        movd	7(x), a    // 8->f7
        mov 	a, r1
        movd	7(x), a    // c->f7
        call	XX
        movd	7(x), a    // f->f7
        jmp	NN

XX:	add     a, #1
        movd    7(x), a    // d->f7
        call	YY
        add     a, #1
        ret

YY:	add    	a, #1
        movd   	7(x), a    // e->f7
        ret

NN:	jmp	NN

