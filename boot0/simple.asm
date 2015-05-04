	BITS 16
	ORG 0x7C00

	jmp short start
	nop

start:
	mov ax, 5000h
	add ax, 288

	cli
	mov ss, ax
	mov sp, 4096
	sti

	mov ax, 0h
	mov ds, ax

	; now that data segment is set we can initialize variables
	mov [boot_dev], dl

	; read device parameters
	mov ah, 8
	int 13h
	jc fatal_disk_error

	; store disk parameters
	mov bx, cx
	mov dx, cx
	and bx, FF00h
	shr bx, 8
	and dx, c0h
	shl dx, 2
	or  bx, dx
	mov [max_tracks], bx

	and cl, 1Fh
	mov [max_sects], cl

	mov [max_head], dh

	jmp $

fatal_disk_error:
	mov si, disk_error
	call print_string
	call reboot

reboot:
	; wait for keyboard press
	mov si, press_key
	call print_string
	mov ax, 0
	int 16h

	; reboot machine
	mov ax, 0
	int 19h

	; unused
	ret

print_string:
	mov ah, 0Eh
.repeat:
	lodsb
	cmp al, 0
	je .done
	int 10h
	jmp .repeat

.done:
	ret

	; --------------------------------------------------
	; STRINGS AND VARIABLES

	disk_error db 'Reading boot1 failed!', 0
	press_key  db 'Press a key to continue!', 0
	boot_dev   db 0
	max_tracks db 0
	max_sects  db 0
	max_head   db 0

	times 510-($-$$) db 0
	dw 0xAA55
