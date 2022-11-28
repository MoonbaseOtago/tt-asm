	mov	a, #15
	mov	x, #0x80
loop:
	movd    7(x), a 
	mov	(x), a
        mov	a, #0xff
        add	a, (x)
        jne	a, loop

        mov	a, #0xaa
        mov	(x), a    

        mov	a, #0xcc
        sub	a, (x)
        movd	7(x), a 

        mov	a, #0xcc
        or	a, (x)
        movd	7(x), a

        mov	a, #0xcc
        and	a, (x)
        movd	7(x), a			// comment

        mov	a, #0xcc
        xor	a, (x)
        movd	7(x), a

        mov	a, (x)
        movd	7(x), a    
       	add	a, #5
        movd	7(x), a    

        swap	y, x
        mov 	x, #0x20
        swap	y, x
        mov	a, r0
        movd	7(x), a 
        mov	a, r1
        movd	7(x), a

        call	XX
        movd	7(x), a

        jmp	NN

XX:	add	a, #1
        movd	7(x), a
        call	YY
        add	a, #1
        ret

YY:	add	a, #1
        movd	7(x), a
        ret

NN:	jmp NN
