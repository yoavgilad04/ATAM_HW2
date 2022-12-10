.global count_above

.section .text
count_above:
	#part 1: find and open
	#rdi=separator , rsi=limit
	movq %rdi, %rbx 	#rbx=separator
	mov %rsi, %r15 	#rcx=limit
	leaq temp(%rip), %r13 #r13 = temp
	
	push %rbp
	movq %rsp, %rbp
	callq get_path
	#rax= file path
	movq %rax, %r9		#rdi = file_path
	
	#open
	movq %r9, %rdi		
	movq $2, %rax
	movq $0, %rsi
	syscall
	
	
	#part 2: reading
	#rax= file descriptor
	movq %rax, %rdi
	movq $0, %rax 
	leaq buffer(%rip), %rsi
	movq $19, %rdx
	syscall
	# in resi we have the content of the txt
	
	movq $0, %rdx  		#rdx= counter above limit
	movq $0, %r10  		#r10 = index
	movq $0, %r11
loop:
	movb (%rsi, %r10, 1), %r11b
	movq $0, %r12
	cmpb $45, %r11b
	jne not_makaf
	inc %r10
	movq $1, %r12       	#if r12 == 1 it means we are in a negative number
not_makaf:
	movq $0, %r8 			#r8 = (counter for temp) 
get_next_digit:
	movb (%rsi, %r10, 1), %r11b    #r11b = buff[i]
	
	#check if buff[i] is digit
	cmpq $48, %r11
	jb end_word
	cmpq $57, %r11
	ja end_word
	#end of check is digit
	
	leaq (%r13, %r8, 1), %r14  #r14 = temp[j]
	movb %r11b, (%r14)			#temp[j] = buff[i]
	inc %r10
	inc %r8
	jmp get_next_digit
	
end_word:
	leaq (%r13, %r8, 1), %r14 
	movb $0, (%r14)
	movq %r13, %rdi				#rdi = &temp
	
	#PreLog 
	push %rdx
	push %rsi
	push %r11
	push %r10
	push %rbp
	movq %rsp, %rbp
	call atam_atol
	
	#AfterLog
	pop %rbp
	pop %r10
	pop %r11
	pop %rsi
	pop %rdx
	# rax = current number
	
	cmpq $0, %r12
	je positive
	
negative:
	not %rax
	inc %rax
	
positive:
	cmpq %r15, %rax
	jle check_if_end
	inc %rdx
	
check_if_end:
	cmpq $0, %r11			# if buf[i] == EOF
	je end_func
	inc %r10
	jmp loop
	
end_func:
	movq %rdx, %rax
	leave
	ret

.section .data
buffer: .zero 20
temp: .zero 20

