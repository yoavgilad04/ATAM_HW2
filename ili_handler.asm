.globl my_ili_handler
.extern what_to_do, old_ili_handler

.text
.align 4, 0x90
my_ili_handler:
	pushq %rax
	pushq %rcx
	movq $0, %rdi
	movq $0, %rax
	movq $0, %rcx
	movq 16(%rsp), %rcx
	cmpb $0x0F, (%rcx)
	je check_second_bit
	movb (%rcx), %dil
	jmp call_what_to_do
check_second_bit:
	movb 1(%rcx), %dil
call_what_to_do:
	pushq %r15
	pushq %r14
	pushq %r13
	pushq %r12
	pushq %r11
	pushq %r10
	pushq %r9
	pushq %r8
	pushq %rdx
	pushq %rsi
	pushq %rdi
	pushq %rcx
	call what_to_do
	popq %rcx
	popq %rdi
	popq %rsi
	popq %rdx
	popq %r8
	popq %r9
	popq %r10
	popq %r11
	popq %r12
	popq %r13
	popq %r14
	popq %r15
	movq %rax, %rdi
	cmpq $0, %rax
	je call_old
	cmpb $0x0F, (%rcx)
	jne increase_one
	incq 16(%rsp)
increase_one:
	incq 16(%rsp)
	jmp end
call_old:
	popq %rcx
	popq %rax
	jmp *old_ili_handler
end:
	popq %rcx
	popq %rax
	iretq

