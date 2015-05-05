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
	movq %rcx, -0x8(%rbp)
	cmpq %rcx, 0x10(%rbp)
	jg .ERROR

	/* hex_string[count] = 0 */
	movq -0x8(%rbp), %rdx
	mov 0x10(%rbp), rax
	add %rdx, %rax
	movb $0, (%rax)

	/* c-- */
	subq $0x1, -0x8(%rbp)

	jmp

	movq 8(%rbp), rdx	/* rdx = hex_number */
	movq -8(%rbp), rcx	/* rcx = count */

.L3:
	/* byte = hex_number & 0xf */
	mov %rdx, %rax
	and $0xf, %rax
	mov %rax, -0x10(%rbp)
	mov %rax, %rbx

	/*
	 * if (byte >= 0 && byte <= 0x9) {
	 *     hex_string[c] = '0' + byte
	 * }
	 */

	mov %rbx, %rax
	cmpq $0x0, %rax
	js
	mov %rbx, %rax
	cmpq $0x9, %rax
	jg

	addq $0x30, %rbx	/* rbx += '0' */
	mov %rcx, %rbx		/* rbx = rcx = count */
	mov 0x10(%rbp), rax	/* rax = hex_string */
	add %rbx, %rax		/* rax = hex_string + count */
	movq (%rax), 
:
	/* while (hex_number >=0 && count > 0) */
.out:
	movq $0, %eax
	ret
.ERROR:
	movq $0xffffffff, %eax
	ret

	.global _start
_start:
	pushq $0x56A
	pushq hex_string
	pushq hex_size
	call hex_to_string
