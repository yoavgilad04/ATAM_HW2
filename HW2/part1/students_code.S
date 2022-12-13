.global count_above

.section .text
count_above:
	push %rbp
	movq %rsp, %rbp	
	push %rbx
	push %r15
	push %r14
	push %r13
	push %r12
	#part 1: find and open
	#rdi=separator , rsi=limit
	movq %rdi, %rbx 	#rbx=separator
	mov %rsi, %r15 		#r15=limit
	

	callq get_path
	#rax= file path
	movq %rax, %r9		#r9 = file_path
	
	#open
	movq %r9, %rdi		
	movq $2, %rax
	movq $0, %rsi
	syscall
	movq %rax, %r13

	
	movq $0 , %r11  #r11 = counter above limit
	sub $20, %rsp  	#allocating 20 bytes in the stack
get_next_number:	
	movq $0, %r10  #r10 = i = 0
	leaq (%rsp, %r10, 1), %rcx  #rcx will contain an adress to memory we would like to read to
	
	#part 2: reading
	#rax= file descriptor

read_rcx:
	movq %r13, %rdi
	movq $0, %rax 
	leaq (%rcx), %rsi
	movq $1, %rdx
	push %rcx
	push %r11
	push %r13
	syscall
	# in (rcx) we have the byte read from the syscall
	pop %r13
	pop %r11
	pop %rcx
	
check_if_EOF:
	cmpq $0, %rax
	je finished
	
check_if_nagative:
	movq $0, %r12  	#r12 = flag for nagative number
	cmpb $45, (%rcx)
	jne not_makaf
	movq $1, %r12       	#if r12 == 1 it means we are in a negative number
	jmp loop_next_digit
not_makaf:
	inc %r10

loop_next_digit:
	movq %r13, %rdi
	leaq (%rsp, %r10, 1), %rcx
	movq $0, %rax 
	leaq (%rcx), %rsi
	movq $1, %rdx
	push %rcx
	push %r11
	push %r13
	syscall   	# in (rcx) we have the byte read from the syscall
	pop %r13
	pop %r11
	pop %rcx
	
check_if_number:
	cmpq $0, %rax
	je end_word
	#check if buff[i] is digit
	cmpb $48, (%rcx)
	jb end_word
	cmpb $57, (%rcx)
	ja end_word
	inc %r10
	jmp loop_next_digit
	#end of check is digit
	
end_word:
	movq $0, %r14
	cmpq $0, %rax
	jne not_end_of_file
	movq $1, %r14
not_end_of_file:
	movb $0, (%rcx) 
	
	#PreLog 
	leaq (%rsp), %rdi 
	push %rcx
	push %rbx
	push %r15
	push %r14
	push %r13
	push %r12
	push %r11
	push %r10
	push %rbp
	movq %rsp, %rbp
	call atam_atol
	
	#AfterLog
	pop %rbp
	pop %r10
	pop %r11
	pop %r12
	pop %r13
	pop %r14
	pop %r15
	pop %rbx
	pop %rcx
	# rax = current number
	
	cmpq $1, %r12
	jne positive
negative:
	not %rax
	inc %rax
positive:
	cmpq %r15, %rax
	jle check_if_end
	inc %r11
	
check_if_end:
	cmpq $0, %r14
	je get_next_number
	
finished:
	movq %r11, %rax
	add $20, %rsp
	pop %r12
	pop %r13
	pop %r14
	pop %r15
	pop %rbx
	leave
	ret
