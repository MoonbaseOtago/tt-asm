%token t_a t_b t_c t_x t_y t_r0 t_r1 t_r2 t_r3 t_r4 t_r5 t_r6 t_r7 t_add t_sub t_or t_and t_xor t_inc t_mov t_movd t_jmp t_call t_jne t_jeq t_swap t_ret t_nop t_nl t_clr t_pc
%token t_value8 t_value256 t_name t_value16 t_value4096 t_value8192
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

ins:		t_add  t_a ',' memr 	{  $$ = (1<<24)| 0x00 | $4; }      
	|	t_sub  t_a ',' memr     {  $$ = (1<<24)| 0x10 | $4; }
	|	t_or  t_a ',' memr      {  $$ = (1<<24)| 0x20 | $4; }
	|	t_and  t_a ',' memr     {  $$ = (1<<24)| 0x30 | $4; }
	|	t_xor  t_a ',' memr     {  $$ = (1<<24)| 0x40 | $4; }
	|	t_mov  t_a ',' memr     {  $$ = (1<<24)| 0x50 | $4; }
	|	t_movd  t_a ',' mem     {  $$ = (1<<24)| 0x60 | $4; }
	|	t_add  t_a ',' t_c      {  $$ = (1<<24)| 0x70; }
	|	t_inc  t_a          	{  $$ = (1<<24)| 0x71; }
	|	t_swap  t_x ',' t_y     {  $$ = (1<<24)| 0x72; }
	|	t_swap  t_y ',' t_x     {  $$ = (1<<24)| 0x72; }
	|	t_ret         		{  $$ = (1<<24)| 0x73; }
	|	t_add  t_y ',' t_a  	{  $$ = (1<<24)| 0x74; }
	|	t_add  t_x ',' t_a  	{  $$ = (1<<24)| 0x75; }
	|	t_inc  t_y  		{  $$ = (1<<24)| 0x76; }
	|	t_inc  t_x         	{  $$ = (1<<24)| 0x77; }
	|	t_mov  t_a ',' t_y      {  $$ = (1<<24)| 0x78; }
	|	t_mov  t_a ',' t_x      {  $$ = (1<<24)| 0x79; }
	|	t_mov  t_b ',' t_a      {  $$ = (1<<24)| 0x7a; }
	|	t_swap t_b ',' t_a      {  $$ = (1<<24)| 0x7b; }
	|	t_swap t_a ',' t_b      {  $$ = (1<<24)| 0x7b; }
	|	t_mov  t_y ',' t_a      {  $$ = (1<<24)| 0x7c; }
	|	t_mov  t_x ',' t_a      {  $$ = (1<<24)| 0x7d; }
	|	t_clr  t_a         	{  $$ = (1<<24)| 0x7e; }
	|	t_mov  t_a ',' t_pc     {  $$ = (1<<24)| 0x7f; }
	|	t_nop         		{  $$ = (1<<24)| 0x80; }
	|	t_movd  mem ',' t_a     {  $$ = (1<<24)| 0xa0 | $2; }
	|	t_mov  memr ',' t_a     {  $$ = (1<<24)| 0xb0 | $2; }
	|	t_mov  t_a ',' '#' valueA {  $$ = (2<<24)| 0xf0 | ($5<<8); }
	|	t_add  t_a ',' '#' valueA {  $$ = (2<<24)| 0xf1 | ($5<<8); }
	|	t_mov  t_y ',' '#' valueD {  $$ = (3<<24)| 0xf2 | ($5<<8); }
	|	t_mov  t_x ',' '#' valueD {  $$ = (3<<24)| 0xf3 | ($5<<8); }
	|	t_jne  t_a ',' addr	{  $$ = (3<<24)| 0xf4 | ($4<<8); }
	|	t_jne  t_c ',' addr	{  $$ = (3<<24)| 0xf4 | (($4|0x1000)<<8); }
	|	t_jeq  t_a ',' addr	{  $$ = (3<<24)| 0xf5 | ($4<<8); }
	|	t_jeq  t_c ',' addr	{  $$ = (3<<24)| 0xf5 | (($4|0x1000)<<8); }
	|	t_jmp  addr		{  $$ = (3<<24)| 0xf6 | ($2<<8); }
	|	t_call addr		{  $$ = (3<<24)| 0xf6 | (($2|0x1000)<<8); }
	;

addr:		valueI			{ $$ = $1; }
	|	t_name			{ $$ = ref_label($1); }
	;

valueA:		t_value8		{ $$ = $1; }
	|	t_value16		{ $$ = $1; }
	|	t_value256		{ $$ = $1; }
	;
valueD:		t_value8		{ $$ = $1; }
	|	t_value16		{ $$ = $1; }
	|	t_value256		{ $$ = $1; }
	|	t_value4096		{ $$ = $1; }
	|	t_value8192		{ $$ = $1; }
	;
valueI:		t_value8		{ $$ = $1; }
	|	t_value16		{ $$ = $1; }
	|	t_value256		{ $$ = $1; }
	|	t_value4096		{ $$ = $1; }
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
