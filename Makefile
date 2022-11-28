all:	asm8 asm4

asm8:	main.c asm8.tab.c
	gcc -DASM8 -o asm8 main.c -g

asm8.tab.c: asm8.y
	bison asm8.y -k

asm4:	main.c asm4.tab.c
	gcc -DASM4  -o asm4 main.c -g

asm4.tab.c: asm4.y
	bison asm4.y -k
