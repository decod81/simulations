; turns supaplex.exe into a .com-file
; nasm -f bin supa.asm -o supa.com
; CS:IP 0AFF:0010 (45056)
; SS:SP 58D4:0080 (363968)
; relocations don't happen and this will work

BITS 16
ORG 0x100
	mov	ax, cs
	mov	bx, ax

	add	cx, 0x0080	 ; add SP offset
	mov	sp, cx		 ; set SP

	add	bx, 32/16-0x58D4 ; move past the beginning and add SS offset
	mov	ss, bx		 ; set SS
	
	add	ax, 32/16+16+0x0AFF ; move past, correct org and add CS offset
	push	ax
	push	0x0010
	retf                    ; jump to where execution should start

times 32- ($-$$) db 0

begin:

; md5sum supaplex.exe 7caf79506860c98c0e49c1247c81a181
incbin "supaplex.exe",512       ; add the original EXE-file skipping the header
