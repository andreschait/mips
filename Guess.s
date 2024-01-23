.data
	bool: .space 12
	guess: .space 12
	getNumMsg: .asciiz "Provide digit number "
	prmptMsg: .asciiz "Please provide a 3 digit number."
	errorMsg: .asciiz "You are not allowed to use the same digit more than once, please try again:\n"
	guessMsg: .asciiz "Try now to guess the number:\n"
	retryMsg: .asciiz "Give it another try:\n"
	wonMsg: .asciiz "Congratulations! You Guessed!\nDo you want to quit(Q) or play again(P)?\n"
	result: .asciiz "Result: "
.text
main:
	li $s5, 'B'
	li $s6, 'P'
	li $s7, 'N'

	li $v0, 4
	la $a0 prmptMsg
	syscall

init:
	jal get_number

	addi $s3, $zero, 0
	lw $s0, bool($s3)
	addi $s3, $s3, 4
	lw $s1, bool($s3)
	addi $s3, $s3, 4
	lw $s2, bool($s3)

	beq $s0, $s1, showError
	beq $s1, $s2, showError
	beq $s0, $s2, showError

	li $v0, 11
	la $a0 '\n'
	syscall

	li $v0, 4
	la $a0 guessMsg
	syscall
	
	#Ask the user to guess the number
	la $a0, bool
	la $a1, guess
	jal get_guess



end_game:
	li $v0, 10
	syscall

get_number:
	#Read Digits
	addi $t0, $zero, 0
	addi $t1, $zero, 1
	whileRead:
		li $v0, 11
		la $a0 '\n'
		syscall
	
		li $v0, 4
		la $a0 getNumMsg
		syscall

		li $v0, 1
		move $a0 $t1
		syscall

		li $v0, 11
		la $a0 ':'
		syscall
		li $v0, 11
		la $a0 ' '
		syscall

		li $v0, 12
		syscall
		sw $v0, bool($t0) # Add character to BOOL

		addi $t0, $t0, 4
		addi $t1, $t1, 1
		blt $t0, 12, whileRead

	li $v0,11
	la $a0, '\n'
	syscall

	jr $ra
	
get_guess:
	move $t0, $a0 #Bool Address
	move $t1, $a1 #Guess Address

	#Read Guess Digits from Input
	li $v0, 8
	la $a0, guess
	li $a1, 12
	syscall

	la $a0, ($t0)
	la $a1, ($t1)
	jal compare

compare:
	move $s1, $a0 #Bool Address
	move $s0, $a1 #Guess Address

	addi $t0, $zero, 0
	
	whileCompare:
		addi $t2, $zero, 13 #Position found
		lb $s0, guess($t0)
		addi $t1, $zero, 0
		addi $t3, $zero, 0 #Nested Counter
		whileBool:
			lw $s1, bool($t1)
			
			beq $s0, $s1, match
			j else		
			match:
				move $t2, $t3
				addi $t1, $t1, 12
			else:
			addi $t3, $t3, 1
			addi $t1, $t1, 4
			blt $t1, 12, whileBool
		sb $s5, guess($t0)
		beq $t0, $t2, digitFound
		sb $s6, guess($t0)
		blt $t2, 13, digitFound
		sb $s7, guess($t0)
		digitFound:
		addi $t0, $t0, 1
		blt $t0, 3, whileCompare 
	
	addi $s3, $zero, 0
	lb $s0, guess($s3)
	addi $s3, $s3, 1
	lb $s1, guess($s3)
	addi $s3, $s3, 1
	lb $s2, guess($s3)
	
	addi $v0, $zero, 0
	bne $s0, $s5, retry
	bne $s1, $s5, retry
	bne $s2, $s5, retry

	addi $v0, $zero, -1
	
	li $v0,4
	la $a0, wonMsg
	syscall
	
	wrongLetter:
	li $v0,12
	syscall
	
	beq $v0, 'P', init
	beq $v0, 'p', init
	beq $v0, 'Q', end_game
	beq $v0, 'q', end_game
	j wrongLetter
	
	retry:
	li $v0, 4
	la $a0 result
	syscall
	
	#Check for B's
	addi $t0, $zero, 0
	addi $t1, $zero, 0 #Check for B or P
	checkB:
		lb $s0, guess($t0)
		bne $s0,'B', skipB
		addi $t1, $t1, 1
		li $v0, 11
		li $a0, 'B'
		syscall
		skipB:
		addi $t0, $t0, 1
		blt $t0, 3, checkB
	addi $t0, $zero, 0
	checkP:
		lb $s0, guess($t0)
		bne $s0,'P', skipP
		addi $t1, $t1, 1
		li $v0, 11
		li $a0, 'P'
		syscall
		skipP:
		addi $t0, $t0, 1
		blt $t0, 3, checkP

	bne $t1, $zero, noN
	li $v0, 11
	li $a0, 'N'
	syscall

	noN:
	li $v0,11
	la $a0, '\n'
	syscall
	
	li $v0,4
	la $a0, retryMsg
	syscall
	j get_guess

showError:
	li $v0,4
	la $a0, errorMsg
	syscall
	j init
