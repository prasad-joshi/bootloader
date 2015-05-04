.file "print_bios.S"

.section .data
hex_str:
	.ascii "xxxxxxxxxxxxxxxx"
	.set   hex_size, .-hex_str

.section .text
	.global .hex_to_string

hex_to_string:
	push %rbp
	mov  %rsp, %rbp

	/*
	 * leave speace for local variables
	 *
	 * 8 byte counter        count   -8
	 * 8 byte temp memory    byte    -16
	 * 8 byte to store 0xf   tmp     -24
	 *
	 * Variables on stack
	 * 8 first argument      hex_number +8
	 * 8 pointer to string   hex_string +16
	 * 8 size of string      size       +24
	 */

	sub $0x24, %rsp

	/* find number of characters required for string */

	movq 8(%rbp), %rax    /* ax = hex_number */
	movq $0, %rcx
	jmp .L2

.L1:
	shrq $4, %rax          /* rax >>= 4 */
	addq $1, %rcx          /* rcx++ */
.L2:
	testq %rax, %rax       /* while (rax) */
	jne .L1

	/* if (count > size) { return -1; } */
	movq %rcx, -0x4(%rbp)
	cmpq %rcx, 0x12(%rbp)
	jg .ERROR

.out:
	movq $0, %rax
	ret
.ERROR:
	movq $-1, %rax
	ret

	.global _start
_start:
	pushq $0x56A
	pushq hex_string
	pushq hex_size
	call hex_to_string
