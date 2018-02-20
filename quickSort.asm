	.data
nums:	.word	8, 7, 2, 3, 10, 29, 21, 22, 6, 15, 22, 33, 45, 40, 100, 20, 33, 99, 0, 35
size:	.word	20
	.text
	
	addi $a0, $zero, 0
	addi $a1, $zero, 19
	jal quicks
	j print
	
#Recursive quick sort routine
#Expect a0 to be low value and a1 to be high value
#s0 stores the value return from partition
quicks:	
	bge $a0, $a1, q_end
	
	addi $sp, $sp, -16
	sw $ra, 0($sp)
	sw $a0, 4($sp)
	sw $a1, 8($sp)
	sw $s0, 12($sp)
	
	jal part
	move $s0, $v0
	sw $s0, 12($sp)
	addi $s0, $s0, -1
	
	lw $a0, 4($sp)
	move $a1, $s0
	jal quicks
	
	lw $s0, 12($sp)
	addi $s0, $s0, 1
	move $a0, $s0
	lw $a1, 8($sp)
	jal quicks
	
	lw $ra, 0($sp)
	addi $sp, $sp, 16

q_end:	
	jr $ra
			

		
#Routine to place values in correct location of the pivot
#Returns the location after the pivot
#Expect a0 to be low value and a1 to be high value
#s0 stores the value of low
#s1 stores the value of hight
#s2 stores the value of pivot
#s3 stores the value of i
#s4 stores the value of j
part:
	addi $sp, $sp, -24	#save return location
	sw $ra, 0($sp)
	sw $s0, 4($sp)
	sw $s1, 8($sp)
	sw $s2, 12($sp)
	sw $s3, 16($sp)
	sw $s4, 20($sp)
	
	move $s0, $a0
	move $s1, $a1
	
	la $t0, nums		#get the array start address into $t0
	sll $t1, $s1, 2		#multiply the $a1 (high value) by 4 to get the correct offset
	add $t2, $t0, $t1
	lw $s2, 0($t2)		#put the pivot (array[high]) into s2
	
	addi $s3, $s0, -1	#set $s3 = to i (low - 1)
	move $s4, $s0		#j = low
forlop:	
	sll $t1, $s4, 2
	add $t2, $t0, $t1
	lw $t3, 0($t2)		#get the value of array[j]
	
	bge $t3, $s2, elsefor
	addi $s3, $s3, 1
	move $a0, $s3
	move $a1, $s4
	jal swap
	
elsefor:	
	addi $s4, $s4, 1 	#increment counter j
	blt $s4, $s1, forlop
	
	addi $s3, $s3, 1	#increment counter i
	move $a0, $s3		#load the smaller location 
	move $a1, $s1

	jal swap		#swap the low and high location

	move $v0, $s3		#load the return value (middle of partition)
	lw $ra, 0($sp)		#load the previous values
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	addi $sp, $sp, 24	#pop stack
	jr $ra			#return

#Routine to swap two numbers in the number array
#Expect locations to be stored in $a0 and $a1
swap:
	.text
	sll $a0, $a0, 2		#multiply indexes by 4 to get proper byte location
	sll $a1, $a1, 2
	la $t0, nums		#set $t0 to the address of nums
	
	add $t1, $t0, $a0	#offset $t0 by $a0 and place into $t1
	add $t2, $t0, $a1	#offset $t0 by $a1 and place into $t2
	
	lw $t3, 0($t1)		#save these values into temp locations $t3 and $t4
	lw $t4, 0($t2)
	
	sw $t4, 0($t1)		#set the swapped values
	sw $t3, 0($t2)
	
	addi $t9, $t9, 1
	
	jr $ra			#return to caller

#Routine to print the values of the number array
	.data
space:	.asciiz " "
head:	.asciiz "The sorted numbers are:\n"
	.text
print:	la $t0, nums		#load address of number array
	lw $t1, size		#load integer of size of the array
	
	la $a0, head		#print header
	li $v0, 4
	syscall
	
output:	lw $a0, 0($t0)		#print value of number array
	li $v0, 1
	syscall
	
	la $a0, space		#print space between numbers
	li $v0, 4
	syscall
	
	addi $t0, $t0, 4	#increment pointer in number array
	addi $t1, $t1, -1	#decrement loop counter
	
	bgtz $t1, output	#return back to start until loop counter is less than 0
	
exit:	li $v0, 10		#syscall to exit
	syscall
	
