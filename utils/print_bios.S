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
	 * 8 first argument      hex_number +16
	 * 8 pointer to string   hex_string +24
	 * 8 size of string      size       +32
	 */

	sub $0x24, %rsp

	/* find number of characters required for string */

	movq 0x10(%rbp), %rax    /* ax = hex_number */
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
	cmpq %rcx, 0x20(%rbp)
	jg .ERROR

	/* hex_string[count] = 0 */
	movq -0x8(%rbp), %rdx
	mov 0x18(%rbp), %rax
	add %rdx, %rax
	movb $0, (%rax)

	/* c-- */
	subq $0x1, -0x8(%rbp)

	jmp .L6

.L3:
	/* byte = hex_number & 0xf */
	mov 0x10(%rbp), %rax		/* rax = hex_number */
	and $0xf, %rax			/* rax &= 0xf */
	mov %rax, -0x10(%rbp)		/* byte = rax */
	mov %rax, %rbx			/* rbx  = byte */

	/*
	 * if (byte >= 0 && byte <= 0x9) {
	 *     hex_string[c] = '0' + byte
	 * }
	 */

	mov %rbx, %rax			/* rax = byte */
	cmpq $0x0, %rax			/* compare byte and 0x0 */
	js .L4
	mov %rbx, %rax
	cmpq $0x9, %rax
	jg .L4

	mov -0x10(%rbp), %rbx	/* rbx = byte */
	addq $0x30, %rbx	/* rbx += '0' */

	movq -8(%rbp), %rcx	/* rcx = count */
	mov 0x18(%rbp), %rax	/* rax = hex_string */
	add %rcx, %rax		/* rax = hex_string + count */
	movq (%rax), %rbx	/* hex_string[c] = '0' + byte  */
	jmp .L5

.L4:
	/*
	 * else if (byte >= 0xA && byte <= 0xf) {
	 *    hs[c] = 'A' + (b - 0xA);
	 * }
	 */

	mov %rbx, %rax		/* rax = byte */
	cmpq $0xA, %rax
	js .L5
	mov %rbx, %rax
	cmpq $0xF, %rax
	jg .L5

	mov -0x10(%rbp), %rbx   /* rbx = byte */
	subq $0xA, %rbx		/* rbx -= 0xA */
	addq $0x41, %rbx	/* rbx += 'A' */

	 movq -8(%rbp), %rcx	/* rcx = count */
	 mov 0x18(%rbp), %rax	/* rax = hex_string */
	 add %rcx, %rax		/* rax = hex_string + count */
	 movq (%rax), %rbx
	 jmp .L5
.L5:
	/* hex_number >>= 4 */
	mov 0x10(%rbp), %rax		/* rax = hex_number */
	shrq $0x4, %rax
	mov %rax, 0x10(%rbp)

	/* count-- */
	movq -8(%rbp), %rcx
	subq $0x1, %rcx
	mov %rcx, -8(%rbp)
	jmp .L6

.L6:
	/* while (hex_number >=0 && count > 0) */
	mov 0x10(%rbp), %rax
	cmpq $0x0, %rax
	js .out
	mov -8(%rbp), %rax
	cmpq $0x0, %rax
	jg .out
	jmp .L3

.out:
	movl $0, %eax
	ret
.ERROR:
	movl $0xffffffff, %eax
	ret

	.global _start
_start:
	lea hex_size, %rcx
	push %rcx

	lea hex_str, %rcx
	push %rcx

	pushq $0x56A

	call hex_to_string
