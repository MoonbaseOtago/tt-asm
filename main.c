#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

#define YYDEBUG 1

unsigned char code[128];
int pc=0;


int yyval;
int line=1;
int errs=0;

void declare_label(int ind);
void process_op(int ins);
int ref_label(int ind);

int yylex(void);
void yyerror(char *err);

#ifdef ASM4
#include "asm4.tab.c"
#else
#include "asm8.tab.c"
#endif

struct tab {char *name; int token; };

struct tab reserved[] = {
	"a", t_a,
#ifndef ASM4
	"b", t_b,
#endif
	"c", t_c,
	"x", t_x,
	"y", t_y,
	"r0", t_r0,
	"r1", t_r1,
	"r2", t_r2,
	"r3", t_r3,
	"r4", t_r4,
	"r5", t_r5,
	"r6", t_r6,
	"r7", t_r7,
	"add", t_add,
	"sub", t_sub,
	"or", t_or,
	"and", t_and,
	"xor", t_xor,
	"inc", t_inc,
	"mov", t_mov,
	"movd", t_movd,
	"jmp", t_jmp,
	"call", t_call,
	"jne", t_jne,
	"jeq", t_jeq,
	"swap", t_swap,
	"ret", t_ret,
#ifndef ASM4
	"nop", t_nop,
	"clr", t_clr,
	"pc", t_pc,
#endif
	0, 0
};

struct symbol {
	char *name;
	int offset;
	int index;
	struct symbol *next;
	unsigned char found;	// 0 referenced, 1 defined
};
int sym_index=0;
struct symbol *list=0;

struct reloc {
	int offset;
	int index;
	int line;
	struct reloc *next;
};
int reloc_index=0;
struct reloc *reloc_first;
struct reloc *reloc_last;

void
declare_label(int ind)
{
	struct symbol *sp;
	for (sp = list; sp; sp = sp->next) 
	if (sp->index == ind) {
		if (sp->found) {
			errs++;
			fprintf(stderr, "%d: label '%s' declared twice\n", line, sp->name);
		}
		sp->offset = pc;
		sp->found = 1;
		return;
	}
	assert(1);
}
int
ref_label(int ind)
{
	struct reloc *rp;
	rp = malloc(sizeof(*rp));
	rp->offset = pc+1;
	rp->index = ind;
	rp->line = line-1;
	rp->next = 0;
	if (reloc_last) {
		reloc_last->next = rp;
		reloc_last = rp;
	} else {
		reloc_first = rp;
		reloc_last = rp;
	}
	return 0;
}

void
process_op(int ins)
{
	static int over=0;

	if ((ins&0xf0000) == 0x20000) {
		if (pc >= (sizeof(code)-1)) {
			if (!over) {
				fprintf(stderr, "%d: ran out of code space\n", line-1);
				errs++;
				over = 1;
			}
			return;
		}
#ifdef ASM4
		code[pc++] = (ins>>4)&0xf;
		code[pc++] = ins&0xf;
#else
		code[pc++] = ins&0xff;
		code[pc++] = (ins>>8)&0xff;
#endif
	} else {
#ifdef ASM4
		if (pc >= (sizeof(code)-2)) {
#else
		if (pc >= sizeof(code)) {
#endif
			if (!over) {
				fprintf(stderr, "%d: ran out of code space\n", line-1);
				errs++;
				over = 1;
			}
			return;
		}
#ifdef ASM4
		code[pc++] = (ins>>4)&0xf;
		code[pc++] = ins&0xf;
		code[pc++] = (ins>>8)&0xf;
#else
		code[pc++] = ins&0xff;
#endif
	}
}

FILE *fin;
int eof=0;

void
yyerror(char *err)
{
	errs++;
	fprintf(stderr, "%d: %s\n", line, err);
}

int
yylex(void)
{
	int c;

	if (eof)
		return 0;
	c = fgetc(fin);
	while (c == ' ' || c == '\t')
		c = fgetc(fin);
	if (c == EOF) {
		eof = 1;
		line++;
		return t_nl;
	} else
	if (c == '\n') {
		line++;
		return t_nl;
	} else
	if (c >= '0' && c <= '9') {
		int ind;
		char v[100];
		char c1;
		c1 = c;
		ind = 0;
		v[ind++] = c;
		c = fgetc(fin);
		if (c1 == '0' && (c == 'x' || c == 'X')) {
			v[ind++] = c;
			c = fgetc(fin);
			while (isxdigit(c)) {
				if (ind < (sizeof(v)-1))
					v[ind++] = c; 
				c = fgetc(fin);
			}
			v[ind] = 0;
			ungetc(c, fin);
			yylval = strtol(v, NULL, 16);
		} else {
			while (isdigit(c)) {
				if (ind < (sizeof(v)-1))
					v[ind++] = c; 
				c = fgetc(fin);
			}
			v[ind] = 0;
			ungetc(c, fin);
			yylval = strtol(v, NULL, 0);
		}
		if (yylval >= 0 && yylval < 8) {
			return t_value8;
		} else
		if (yylval >= 0 && yylval < 16) {
			return t_value16;
		} else
		if (yylval >= 0 && yylval < 256) {
			return t_value256;
		} else {
			errs++;
			fprintf(stderr, "%d: Invalid constant '%s'\n", line, v);
			return t_value256;
		}
	} else
	if ((c >= 'a' && c <= 'z') ||
	    (c >= 'A' && c <= 'Z') || c == '_') {		
		int i;
		int ind=0;
		char v[256];
		struct symbol *sp;

		while ((c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') ||
            	       (c >= 'A' && c <= 'Z') || c == '_' ) {
			if (ind < (sizeof(v)-1))
				v[ind++] = c; 
			c = fgetc(fin);
		}
		ungetc(c, fin);
		v[ind] = 0;
		for (i = 0; reserved[i].name; i++)
		if (strcmp(v, reserved[i].name) == 0)
			return reserved[i].token;
		for (sp = list; sp; sp=sp->next)
		if (strcmp(v, sp->name) == 0) {
			yylval = sp->index;
			return t_name;
		}
		sp = malloc(sizeof(*sp));
		sp->index = sym_index++;
		sp->found = 0;
		sp->name = strdup(v);
		sp->next = list;
		list = sp;
		yylval = sp->index;
		return t_name;
	} else {
		if (c == '/') {
			c = fgetc(fin);
			if (c == '/') {		
				while (c != '\n' && c != EOF)
					c = fgetc(fin);
				return t_nl;
			}
			ungetc(c, fin);
			c = '/';
		}
		return c;
	}
}

int
main(int argc, char **argv)
{
	int i, src_out=0;
	struct reloc *rp;
	char *in_name = 0;
	char *out_name = "a.out";

	yydebug = 0;
	for (i = 1; i < argc; i++) {	
		if (strcmp(argv[i], "-y") == 0) {
			yydebug = 1;
		} else
		if (strcmp(argv[i], "-s") == 0) {
			src_out = 1;
		} else
		if (strcmp(argv[i], "-o") == 0 && i != (argc-1)) {
			i++;
			out_name = argv[i];
		} else {
			if (in_name) {
				fprintf(stderr, "too many inout files\n");
				errs++;
			}
			in_name = argv[i];
		}
	}

	if (!in_name) {
		fprintf(stderr, "No file specified\n");
		return 1;
	}
	fin = fopen(in_name, "r");
	if (!fin) {
		fprintf(stderr, "Can't open '%s'\n", in_name);
		return 1;
	}
	if (yyparse()) {
		fprintf(stderr, "%d: syntax error\n", line);
		return 1;
	}
	for (rp = reloc_first; rp; rp = rp->next) {
		struct symbol *sp;
		int found = 0;
		for (sp = list; sp; sp=sp->next) 
		if (rp->index == sp->index) {
			found = 1;
#ifdef ASM4
			code[rp->offset] |= (sp->offset>>4)&0xf;
			code[rp->offset+1] |= sp->offset&0xf;
#else
			code[rp->offset] |= sp->offset;
#endif
			if (!sp->found) {
				errs++;
				fprintf(stderr, "%d: '%s' not defined\n", rp->line, sp->name);
			}
		}
		assert(found);
	}
	if (!errs) {
		if (src_out) {
			FILE *fout = fopen(out_name, "wb");
			if (fout) {
#ifdef ASM4
				for (i = 0; i < pc; i++)
					fprintf(fout, "	sram[8'h%02x] = 'h%x;\n", i, code[i]);
#else
				for (i = 0; i < pc; i++)
					fprintf(fout, "	sram[8'h%02x] = 'h%02x;\n", i, code[i]);
#endif
				fclose(fout);
			} else {
				fprintf(stderr, "Can't open output file '%s'\n", out_name);
				errs++;
			}
		} else {
			FILE *fout = fopen(out_name, "w");
			if (fout) {
				fwrite(code, 1, pc, fout);	
				fclose(fout);
			} else {
				fprintf(stderr, "Can't open output file '%s'\n", out_name);
				errs++;
			}
		}
	}
	return errs != 0?1:0;
}
