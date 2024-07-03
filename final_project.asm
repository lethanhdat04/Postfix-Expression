.data
	expression: .space 100
	result_msg: .asciiz "The result is: "
	msg: .asciiz "Input: "
	error_msg: .asciiz "Input is invalid"
	nline: .asciiz "\n"
.text
move $fp, $sp
main:
	move $sp, $fp 
	li $v0, 4
	la $a0, msg   
	syscall   #Show the string 
	
	li $v0, 8
	la $a0, expression 
	li $a1, 100
	syscall   #Nhap bieu thuc 
	
	lb $s7, 0($a0)
	beq $s7, 'e', exit
	
	jal tinhGiaTriBieuThucHauto

isOperator:
#luu tru thanh ghi a0 va ra vao stack
	addi $sp, $sp, -8
	sw $a0, 0($sp)
	sw $ra, 4($sp)
	
#Kiem tra toan tu 
	li $t0, '+'
	beq $a0, $t0, isOperatorTrue
	li $t0, '-'
	beq $a0, $t0, isOperatorTrue
	li $t0, '*'
	beq $a0, $t0, isOperatorTrue
	li $t0, '/'
	beq $a0, $t0, isOperatorTrue
	li $t0, '^'
	beq $a0, $t0, isOperatorTrue
	
#Neu la toan tu thi tra ve 1 nguoc lai ve 0
isOperatorFalse:
	li $v0, 0
	j endCheck
	
isOperatorTrue:
	li $v0, 1
	
endCheck:
	lw $a0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
compute:
#Luu tru cac thanh ghi vao stack
	addi $sp, $sp, -16
	sw $a0, 0($sp)
	sw $a1, 4($sp)
	sw $a2, 8($sp)
	sw $ra, 12($sp)
	
#Thuc hien cac phep toan
	li $t0, '+'
	beq $a2, $t0, compute_add 
	li $t0, '-'
	beq $a2, $t0, compute_sub
	li $t0, '*'
	beq $a2, $t0, compute_mul
	li $t0, '/'
	beq $a2, $t0, compute_div
	li $t0, '^'
	beq $a2, $t0, compute_pow
	
compute_add:
	add $v0, $a0, $a1
	j compute_end

compute_sub:
	sub $v0, $a0, $a1
	j compute_end
	
compute_mul:
	mul $v0, $a0, $a1
	j compute_end
	
compute_div:
	beq $a1, 0, error
	div $a0, $a1
	mflo $v0
	j compute_end
	
compute_pow:
	addi $t1, $a0, 0
	addi $t2, $a1, 0
	li $v0, 1
	pow_loop:
		beq $t2, $zero, pow_end
		mul $v0, $v0, $t1
		addi $t2, $t2, -1
		j pow_loop
	pow_end:
		j compute_end

compute_end:
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	lw $a2, 8($sp)
	lw $ra, 12($sp)
	addi $sp, $sp, 16
	jr $ra
	
tinhGiaTriBieuThucHauto:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $s0, expression
	li $t0, 0
	li $t1, 1
#Lap qua tung ki tu cua bieu thuc
evaluate:	
	lb $t2, 0($s0)
	beq $t2, '\n', print_result
	beq $t2, $zero, print_result
	beq $t2, ' ', next_char
	move $a0, $t2
	jal isOperator
	
	beq $v0, $zero, operand
#day la toan tu	
	addi $sp, $sp, 4
	lw $t4, 0($sp)
	addi $sp, $sp, 4
	lw $t3, 0($sp)
	
	move $a0, $t3
	move $a1, $t4
	move $a2, $t2
	jal compute

	sw $v0, 0($sp)
	addi $sp, $sp, -4
	j next_char
	
operand:
	li $s4, '0'
	sub $s5, $t2, $s4
	blt $s5, 0, error
	bgt $s5, 9, error
	li $t5, 0
#Luu tru cac ki tu co nhieu chu so
num_loop:
	beq $t2, ' ', end_num
	sub $t2, $t2, '0'
	mul $t5, $t5, 10
	add $t5, $t5, $t2
	addi $s0, $s0, 1
	lb $t2, 0($s0)
	j num_loop
end_num:
	sw $t5, 0($sp)
	addi $sp, $sp, -4
	addi $s0, $s0, -1
	
next_char:
	addi $s0, $s0, 1
	j evaluate
	
print_result:
	addi $sp, $sp, 4
	lw $v1, 0($sp)
	li $v0, 4
	la $a0, result_msg
	syscall
	
	li $v0, 1
	move $a0, $v1
	syscall
	
	li $v0, 4
	la $a0, nline
	syscall
	
	j main
	
error:
	li $v0, 4
	la $a0, error_msg
	syscall
	j main

exit:	
	li $v0, 10
	syscall
	
	
