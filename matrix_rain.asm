        .model  tiny

        .data
		seed	db  ?	;random seed
		r_num	db	?	;random number
		
		row 	db	32	dup (?)
		col 	db	32	dup (?)
		char	db  32  dup (30h)
		n_count	dw	16
		
		shade	db	0fh, 0fh, 0ah, 0ah, 02h, 02h, 08h, 08h
		s_count	dw	8
		s_num	dw  0
		
		d_loop	dw	0
		t_loop	dw	0
		
		life	db  16
		dmg		db	0
		score	db	0
		dp_cd	db	20
		dp_time db	0
		
        .code
        org     0100h
		
main:	mov		ah, 00h		;set video mode
		mov		al, 03h
		int 	10h
		
		mov 	ah,	05h		;set page 1
		mov		al, 01h
		int		10h
		
		mov		ah, 06h		;clear screen
		mov		al, 00h
		mov		bh,	07h
		mov		cx, 0000h
		mov		dx, 184fh
		int		10h
		
		mov		ah,	02h		;set cursor page 1 to (0, 0)
		mov		bh, 01h
		mov		dh, 00h
		mov		dl, 00h
		int		10h
		
		mov		ah, 01h		;hide cursor
		mov		cx, 2000h
		int 	10h
		
		;Init
		mov		di, 0
		;initialize random position
rerow:	call	random		;random row
		mov		dl, r_num
		mov		row[di], dl
		cmp		row[di], 0
		jge		rerow
		cmp		row[di], -64
		jl		rerow
		
		
recol:	call	random		;random column
		mov		dh, r_num
		mov		col[di], dh
		cmp		col[di], 80
		jge		recol
		cmp		col[di], 0
		jl		recol
		
		call	rnd_ch
		mov		char[di], al
		
		inc		t_loop		;check assign to all?
		inc		di
		cmp		t_loop, 32
		jl		rerow
		
loop0:	mov		ah, 06h		;clear screen
		mov		al, 00h
		mov		bh,	07h
		mov		cx, 0000h
		mov		dx, 184fh
		int		10h
		
		mov		al, 00h		;check for keystoke
		mov		ah, 01h
		int 	16h
		
		cmp		al, 00h		;exit on any key pressed
		jne		exit
		
		call	chr_drp		;char drop
		
		mov		cx, 01h		;delay
		mov 	dx, 1000
		mov		ah, 86h
		int		15h
		
		jmp		loop0
		
exit:	mov		cx, 0fh		;delay 1 sec
		mov 	dx, 4240h
		mov		ah, 86h
		int		15h
		
		mov		ah, 01h		;show cursor
		mov		cx, 0607h
		int 	10h
		
		mov		ah, 00h		;pop keyboard buffer
		int		16h
		
		mov 	ah,	05h		;set page 0
		mov		al, 00h
		int		10h
		mov		ah,	02h		;set cursor page 0 to (0, 0)
		mov		bh, 00h
		mov		dh, 00h
		mov		dl, 00h
		int		10h
		
        ret
	
;-----------------	
;sub routines

;core function
chr_drp:mov		t_loop, 0
drop:	mov		si, t_loop
		mov		ah, row[si]	;handling position
		cmp		ah, 48		;check row
		jl		skip1a
		mov		si, t_loop
		
set0:	call	random
		mov		ah, r_num
		cmp		ah, 0		;check column
		jge		set0
		cmp		ah, -16
		jl		set0
		
		mov		row[si], ah
		
retry0:	call	random		;set new column
		mov		al, r_num
		and		al, 7fh
		cmp		al, 80		;check column
		jge		retry0
		cmp		al, 0
		jl		retry0
		mov		si, t_loop
		mov		col[si], al
		
		call	rnd_ch
		mov		char[si], al
		
		jmp		skip1b
		
skip1a:	inc		ah			;move down
		mov		row[si], ah
		
skip1b:	inc		t_loop		;do for each drop
		cmp		t_loop, 32
		jl		drop

		mov		d_loop, 0
		mov		t_loop, 0
trail:	mov		di, d_loop	;draw trail
		mov		dl, row[di]
		mov		dh, 00h
		sub		dx, t_loop
		cmp		dx, 0
		jl		skip2
		
		mov		dh, dl
		mov		di, d_loop
		mov		dl,	col[di]
		
		mov 	ah, 02h		;set cursor
		mov		bh, 01h
		int		10h
		
		mov		ah, 09h		;write char
		mov		di, d_loop
		mov		al, char[di]
		mov		bh, 01h
		mov		si, t_loop
		mov		bl, shade[si]
		mov		cx, 01h
		int		10h
		
		inc		t_loop		;trail inner loop
		cmp		t_loop, 8
		jl		trail
		
skip2:	mov		t_loop, 0	;drop outer loop
		inc		d_loop
		cmp		d_loop, 32
		jl		trail
		
		ret	
		
;random number generator
random:	mov		ah, 2ch		;get system time
		int		21h
		add		dh, dl		;random fomula
		sub     dl, seed
		mov 	ax, dx
		mul		ax
		add 	al, dh
		add		dl, ah
		mul		dx
		add		ah, dl
		add		dh, al
		mov		seed, dh	;set new seed
		add		r_num, al	;get result
		
		ret
		
;random ascii char code
rnd_ch:	call	random
		mov		al, r_num	;handle char
		cmp		al, 60h
		jg		cmp_1
		cmp		al, 40h
		jg		cmp_2
		cmp		al, 2fh
		jg		cmp_3
		jmp		rnd_ch
		
cmp_1:	cmp		al, 7bh
		jl		cmp_get
		jmp		rnd_ch
		
cmp_2:	cmp		al, 5bh
		jl		cmp_get
		jmp		rnd_ch
		
cmp_3:	cmp		al, 3ah
		jl		cmp_get
		jmp		rnd_ch
		
cmp_get:mov		al, r_num
		ret
		
        end     main
		
