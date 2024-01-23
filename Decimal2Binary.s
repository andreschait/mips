.data
rqstMsg: .asciiz "Please enter a number between -9999 and 9999:\n"
errMsg: .asciiz "Wrong number, please enter again:\n"
breakLine: .asciiz "\n"
.text

main:
	addi $a1, $zero, -9999 #min value
	addi $a2, $zero, 9999 #max value
	addi $s3, $zero, 0 #inverter switch

	#Print Input Message
	li  $v0, 4
	la $a0, rqstMsg
	syscall

requestNumber:	
	li $v0, 5
	syscall

	move $s0, $v0

	#Check if smaller than -9999
	slt $s1, $s0, $a1
	bne $s1, $zero, errorMsg

	#Check if greater than 9999
	sgt $s1, $s0, $a2
	bne $s1, $zero, errorMsg

initialize:
	addi $a3, $zero, 32768 # mask
	addi $s4, $zero, 1 # maskInverted
	addi $t3, $zero, 16 # counter
	
	addi $s2, $zero, 0 # inverted

loop:
	beq $t3, $zero, invert
	and $t2,$s0,$a3

	srl $a3,$a3,1 #Move mask position

	addi $t3,$t3,-1
	
	beq $t2, $zero, bitZero

	or $s2,$s2,$s4 #Populate Inverted Number
	sll $s4,$s4,1 #Move maskInverted position

	li  $v0, 1
	li $a0, 1
	syscall
	
	j loop
	
	bitZero:
		sll $s4,$s4,1
		li  $v0, 1
		li $a0, 0
		syscall
		j loop
	
invert:
	li  $v0, 4
	la $a0, breakLine
	syscall
	
	bne $s3, $zero, exit

	move $s0, $s2
	addi $s3, $zero, 1

	j initialize

exit:
	ori $s0, $s0, 4294901760

	li  $v0, 1
	move $a0, $s0
	syscall
	#Terminate Program 
	li  $v0, 10
	syscall

errorMsg:
	li  $v0, 4
	la $a0, errMsg
	syscall
	j requestNumber
