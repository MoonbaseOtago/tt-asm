%token t_a t_b t_c t_x t_y t_r0 t_r1 t_r2 t_r3 t_r4 t_r5 t_r6 t_r7 t_add t_sub t_or t_and t_xor t_inc t_mov t_movd t_jmp t_call t_jne t_jeq t_swap t_ret t_nop t_nl t_clr t_pc 
%token t_value8 t_value256 t_name t_value16
%start  program
%%

mem:		t_value8 '(' t_x ')'	{ $$ = $1; }
	|	t_value8 '(' t_y ')'	{ $$ = 8|$1; }
	|	'(' t_x ')'		{ $$ = 0; }
	|	'(' t_y ')'		{ $$ = 8; }
	;

memr:		mem			{ $$ = $1; }
	|	t_r0			{ $$ = 8|0; }
	|	t_r1			{ $$ = 8|1; }
	|	t_r2			{ $$ = 8|2; }
	|	t_r3			{ $$ = 8|3; }
	|	t_r4			{ $$ = 8|4; }
	| 	t_r5			{ $$ = 8|5; }
	|	t_r6			{ $$ = 8|6; }
	|	t_r7			{ $$ = 8|7; }
	;

ins:		t_add  t_a ',' memr 	{  $$ = (2<<24)| 0x00 | $4; }      
	|	t_sub  t_a ',' memr     {  $$ = (2<<24)| 0x10 | $4; }
	|	t_or  t_a ',' memr      {  $$ = (2<<24)| 0x20 | $4; }
	|	t_and  t_a ',' memr     {  $$ = (2<<24)| 0x30 | $4; }
	|	t_xor  t_a ',' memr     {  $$ = (2<<24)| 0x40 | $4; }
	|	t_mov  t_a ',' memr     {  $$ = (2<<24)| 0x50 | $4; }
	|	t_movd  t_a ',' mem     {  $$ = (2<<24)| 0x60 | $4; }
	|	t_swap  t_x ',' t_y     {  $$ = (2<<24)| 0x70; }
	|	t_swap  t_y ',' t_x     {  $$ = (2<<24)| 0x70; }
	|	t_add  t_a ',' t_c      {  $$ = (2<<24)| 0x71; }
	|	t_mov  t_x ',' t_a      {  $$ = (2<<24)| 0x72; }
	|	t_ret			{  $$ = (2<<24)| 0x73; }
	|	t_add  t_y ',' t_a  	{  $$ = (2<<24)| 0x74; }
	|	t_add  t_x ',' t_a  	{  $$ = (2<<24)| 0x75; }
	|	t_inc  t_y  		{  $$ = (2<<24)| 0x76; }
	|	t_inc  t_x         	{  $$ = (2<<24)| 0x77; }
	|	t_mov  t_a ',' '#' valueX {  $$ = (2<<24)| 0x80 | $5; }
	|	t_add  t_a ',' '#' valueX {  $$ = (2<<24)| 0x90 | $5; }
	|	t_movd  mem ',' t_a     {  $$ = (2<<24)| 0xa0 | $2; }
	|	t_mov  memr ',' t_a     {  $$ = (2<<24)| 0xb0 | $2; }
	|	t_mov  t_x ',' '#' value{  $$ = (3<<24)| 0xc0 | (($5&0xf0)>>4) | (($5&0x0f)<<8); }
	|	t_jne  t_a ',' addr	{  $$ = (3<<24)| 0xd0 | (($4&0xf0)>>4) | (($4&0x0f)<<8); }
	|	t_jne  t_c ',' addr	{  $$ = (3<<24)| 0xd8 | (($4&0xf0)>>4) | (($4&0x0f)<<8); }
	|	t_jeq  t_a ',' addr	{  $$ = (3<<24)| 0xe0 | (($4&0xf0)>>4) | (($4&0x0f)<<8); }
	|	t_jeq  t_c ',' addr	{  $$ = (3<<24)| 0xe8 | (($4&0xf0)>>4) | (($4&0x0f)<<8); }
	|	t_jmp  addr		{  $$ = (3<<24)| 0xf0 | (($2&0xf0)>>4) | (($2&0x0f)<<8); }
	|	t_call addr		{  $$ = (3<<24)| 0xf8 | (($2&0xf0)>>4) | (($2&0x0f)<<8); }
	;

addr:		value			{ $$ = $1; }
	|	t_name			{ $$ = ref_label($1); }
	;

value:		t_value8		{ $$ = $1; }
	|	t_value16		{ $$ = $1; }
	|	t_value256		{ $$ = $1; }
	;

valueX:		t_value8		{ $$ = $1; }
	|	t_value16		{ $$ = $1; }
	;

lname:		t_name			{ $$ = $1; }
	;	

label:		 lname ':'		{ declare_label($1); }
	;

line:		label ins_e t_nl 		
	|	ins_e t_nl
	;

ins_e:		ins		 	{ process_op($1);  }
	|
	;
	
program:	line
	|	program line
	;
