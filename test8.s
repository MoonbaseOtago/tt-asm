	mov	a, #15
	mov	x, #0x40
loop:
	movd    7(x), a 	// 15-0->47
	mov	r0, a
        mov	a, #0xff
        add	a, r0
        jne	a, loop

        mov	a, #0xaa
        mov	r0, a    

        mov	a, #0xcc	// 22->47
        sub	a, r0
        movd	7(x), a 

        mov	a, #0xcc	// ee->47
        or	a, r0
        movd	7(x), a

        mov	a, #0xcc	// 88->47
        and	a, r0
        movd	7(x), a	

        mov	a, #0xcc	// 66->47
        xor	a, r0
        movd	7(x), a

        mov	a, r0		
        movd	7(x), a    	// aa->47
       	add	a, #5		
        movd	7(x), a    	// af->47

        swap	y, x
        mov 	x, #0x22
        swap	y, x
        mov	a, r0		// f1->47
        movd	7(x), a 
        mov	a, r1		// 5->47
        movd	7(x), a

        call	XX
        movd	7(x), a		// 8->47

        jmp	NN

XX:	add	a, #1
        movd	7(x), a		// 6->47
        call	YY
        inc	a
        ret

YY:	inc	a
        movd	7(x), a		// 7->47
        ret

NN:	jmp NN
