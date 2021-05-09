###############################################################################################################################################################################################################################################################################################
# 
# CSCB58 Winter 2021 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Hongxiao Niu, 1006217345, niuhongx
#
# Bitmap Display Configuration:
# -Unit width in pixels: 8 (update this as needed)
# -Unit height in pixels: 8 (update this as needed)
# -Display width in pixels: 512 (update this as needed)
# -Display height in pixels: 512 (update this as needed)
# -Base Address for Display: 0x10008000 ($gp)
#
# Which milestoneshave beenreached in this submission?
# -Milestone 4 
#
# Which approved features have been implementedfor milestone 4?
# (See the assignment handout for the list of additional features)
# 1. Increase in difficulty as game progresses. Difficulty was achieved by adding more obstacles.
# 2. Scoring system: add a score to the game based onsurvival time.
# 3. Smooth graphics: prevent flicker by carefully erasing and redrawing only the parts to the frame buffer that have changed.
#
#
# Link to video demonstration for final submission:
# https://play.library.utoronto.ca/play/b91f8bad3341140f840cf13c50075b89
# https://youtu.be/a3HcvSEpQTU
# https://utoronto-my.sharepoint.com/:v:/g/personal/hongxiao_niu_mail_utoronto_ca/ESRjfilbnExGtwOSJ7p3sMQBS2Hb4XAY1fEdybEi5k_WQQ?e=1eHv8V
#
# Are you OK with us sharing the video with people outside course staff?
# -Yes, and please share this project githublink as well!
#
# Any additional information that the TA needs to know:
# I use an intro page and count down 3 seconds for users to prepare game.
###############################################################################################################################################################################################################################################################################################

.data

ARR_OBSTACLE:	.word	0:4096

.eqv WIDTH		64		# in "units"
.eqv HEIGHT		64		# in "units"
.eqv ROW_SHIFT		8		# 64 units * 4 bytes per pixel = 256 = 2 ^ 8
.eqv NUMBER_OF_OBSTACLE	1		# the number that random value
.eqv HEALTH		9		# how many live that player has

# address(X,Y) = (Y * width + X) * 4

.eqv BASE_ADDRESS	0x10008000
.eqv END_ADDRESS	0x1000BFFC	# (16384)
.eqv SPACESHIP_START	7936		# Space ship start at middle left

.eqv RED		0xff0000
.eqv BLUE		0x0000ff
.eqv BLACK		0x000000
.eqv WHITE		0xffffff
.eqv GREY		0x808080
.eqv PURPLE		0x800080

.text
.globl main
main:	

# $t0 stores the BASE ADDRESS for display
# $t1 stores address of space ship
# $t2 stores the colour code
# $t3 stores the current number of loop
# $t4 stores the different levels
# $t5 stores the health point
# $t6 is compare this round health point to previous round health point, help for efficicie

START:
	li $t0, BASE_ADDRESS	# $t0 stores the BASE ADDRESS for display
	li $t1, SPACESHIP_START	# $t1 stores address of space ship
	li $t2, BLACK		# set color to BLACK
	li $t3, 0		# $t3 stores the current number of loop
	li $t4, 1		# $t4 stores the difficulty levels
	li $t5, HEALTH
	li $t6, HEALTH		# $t6 stores the time that Collisions happened

	
CALL_CLEAN_UP:
	jal CLEAR_UP
	
INTRO:
	#PRINT "WELCOME"
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 3372
	move $a0, $s0
	jal PRINT_WELCOME
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 5480
	move $a0, $s0
	jal PRINT_TO
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 7452
	move $a0, $s0
	jal PRINT_SHIP_GAME
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 9508
	move $a0, $s0
	jal PRINT_START_IN
	
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 11892
	move $a0, $s0
	jal PRINT_THREE
	# SLEEP to SHOW COUNT DOWN
	li $v0, 32
	li $a0, 1000   # Wait one second (1000 milliseconds)
	syscall
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 11892
	move $a0, $s0
	jal PRINT_TWO
	# SLEEP to SHOW COUNT DOWN
	li $v0, 32
	li $a0, 1000   # Wait one second (1000 milliseconds)
	syscall
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 11892
	move $a0, $s0
	jal PRINT_ONE
	# SLEEP to SHOW COUNT DOWN
	li $v0, 32
	li $a0, 1000   # Wait one second (1000 milliseconds)
	syscall
	
	jal CLEAR_UP
	

	
# initial the ship address, set it to the middle left.
INITIAL_SHIP:
	add $t1, $t1, $t0	# SHIP_ADDRESS store in $t1
	move $a0, $t1		# prepair to call the function
	jal PAINT_SHIP
	
CALL_HP:
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 684
	move $a0, $s0
	jal PRINT_HP
	
CALL_D:
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 520
	move $a0, $s0
	jal PRINT_D
	
CALL_NINE:
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 740
	move $a0, $s0 
	jal PRINT_NINE
	
PRINT_LINE:
	li $s0, BASE_ADDRESS
	li $t2, WHITE
	addi $s0, $s0, 2304
	addi $s1, $s0, 256
LOOP:
	sw $t2, 0($s0)		# paint the line WHITE.
	addi $s0, $s0, 4
	bne $s0, $s1, LOOP
	
	beq $t4, 1, DIFF_1
	

START_BIG_LOOP:
# check the difficulty level
	
	beq $s0, $s1, UPDATE_SHIP
	beq $t4, 2, DIFF_2
	beq $t4, 3, DIFF_3
	beq $t4, 4, DIFF_4
	beq $t4, 5, DIFF_5
	beq $t4, 6, DIFF_6
	beq $t4, 7, DIFF_7
	beq $t4, 8, DIFF_8
	j UPDATE_SHIP

DIFF_1:
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 552
	move $a0, $s0
	jal PRINT_ONE
	j UPDATE_SHIP

DIFF_2:
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 552
	move $a0, $s0
	jal PRINT_TWO
	j UPDATE_SHIP

DIFF_3:
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 552
	move $a0, $s0
	jal PRINT_THREE
	j UPDATE_SHIP
	
DIFF_4:
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 552
	move $a0, $s0
	jal PRINT_FOUR
	j UPDATE_SHIP
	
DIFF_5:
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 552
	move $a0, $s0
	jal PRINT_FIVE
	j UPDATE_SHIP
	
DIFF_6:
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 552
	move $a0, $s0
	jal PRINT_SIX
	j UPDATE_SHIP
	
DIFF_7:
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 552
	move $a0, $s0
	jal PRINT_SEVEN
	j UPDATE_SHIP
	
DIFF_8:
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 552
	move $a0, $s0
	jal PRINT_EIGHT
	j UPDATE_SHIP

# Update ship location
UPDATE_SHIP:
	li $t9, 0xffff0000 
	lw $t8, 0($t9)
	bne $t8, 1, OBSTACLE_START
KEYPRESS_HAPPENED:
	lw $t2, 4($t9) 			# this assumes $t9 is set to 0xfff0000from before
	beq $t2, 0x61, RESPOND_TO_A 	# ASCII code of 'a' is 0x61 or 97 in decimal
	beq $t2, 0x41, RESPOND_TO_A 	# ASCII code of 'A' is 0x61 or 65 in decimal
	beq $t2, 0x64, RESPOND_TO_D	# ASCII code of 'd' is 0x64 or 100 in decimal
	beq $t2, 0x44, RESPOND_TO_D	# ASCII code of 'D' is 0x44 or 68 in decimal
	beq $t2, 0x77, RESPOND_TO_W	# ASCII code of 'w' is 0x77 or 119 in decimal
	beq $t2, 0x57, RESPOND_TO_W	# ASCII code of 'W' is 0x57 or 87 in decimal
	beq $t2, 0x73, RESPOND_TO_S	# ASCII code of 's' is 0x73 or 115 in decimal
	beq $t2, 0x53, RESPOND_TO_S	# ASCII code of 'S' is 0x53 or 83 in decimal
	beq $t2, 0x70, RESPOND_TO_P	# ASCII code of 'p' is 0x70 or 112 in decimal
	beq $t2, 0x50, RESPOND_TO_P	# ASCII code of 'P' is 0x50 or 80 in decimal
	j OBSTACLE_START
	
RESPOND_TO_A:	
	li $s1, 256
	sub $s0, $t1, $t0		# check how much distance it from base address
	div $s0, $s1 			# distance % 256 = ? check is it at leftest
	mfhi $s1
	beqz $s1, OBSTACLE_START	# if it is at leftest, move to OBSTACLE_START
	li $t2, BLACK			# set color to BLACK
	sw $t2, 8($t1)			# Paint the SHIP_INDEX + 2 unit on the Y + 0 row BLACK.
	sw $t2, 520($t1)		# Paint the SHIP_INDEX + 2 unit on the Y + 2 row BLACK.
	sw $t2, 268($t1)		# Paint the SHIP_INDEX + 3 unit on the Y + 1 row BLACK.
	addi $t1, $t1, -4
	move $a0, $t1			# prepair to call the function
	jal PAINT_SHIP			# call function "PAINT_SHIP"
	j OBSTACLE_START

RESPOND_TO_D:
	li $s1, 256
	sub $s0, $t1, $t0		# check how much distance it from base address
	div $s0, $s1			# distance % 63 = ? check is it at leftest
	mfhi $s1
	addi $s1, $s1, -240		# check is it at leftest pixel?
	beqz $s1, OBSTACLE_START	# if it is at leftest, move to OBSTACLE_START
	li $t2, BLACK			# set color to BLACK
	sw $t2, 0($t1)			# Paint the SHIP_INDEX + 0 unit on the Y + 0 row BLACK.
	sw $t2, 512($t1)		# Paint the SHIP_INDEX + 0 unit on the Y + 2 row BLACK.
	sw $t2, 260($t1)		# Paint the SHIP_INDEX + 1 unit on the Y + 1 row BLACK.
	addi $t1, $t1, 4
	move $a0, $t1			# prepair to call the function
	jal PAINT_SHIP			# call function "PAINT_SHIP"
	j OBSTACLE_START
	
RESPOND_TO_W:
	sub $s0, $t1, $t0		# check how much distance it from base address
	blt $s0, 2816, OBSTACLE_START	# if it is at highest, move to OBSTACLE_START
	li $t2, BLACK			# set color to BLACK
	sw $t2, 0($t1)			# Paint the SHIP_INDEX + 0 unit on the Y + 0 row BLACK.
	sw $t2, 512($t1)		# Paint the SHIP_INDEX + 0 unit on the Y + 2 row BLACK.
	sw $t2, 516($t1)		# Paint the SHIP_INDEX + 1 unit on the Y + 2 row BLACK.
	sw $t2, 520($t1)		# Paint the SHIP_INDEX + 2 unit on the Y + 2 row BLACK.
	sw $t2, 268($t1)		# Paint the SHIP_INDEX + 3 unit on the Y + 1 row WHITE.
	addi $t1, $t1, -256
	move $a0, $t1			# prepair to call the function
	jal PAINT_SHIP			# call function "PAINT_SHIP"
	j OBSTACLE_START
	
RESPOND_TO_S:
	li $s3, END_ADDRESS		# set $s3 to end_address
	addi $s2, $t1, 512		# set $s2 to the bottom of ship
	sub $s0, $s3, $s2		# check how much distance it from base address
	blt $s0, 256, OBSTACLE_START	# if it is at highest, move to OBSTACLE_START
	li $t2, BLACK			# set color to BLACK
	sw $t2, 0($t1)			# Paint the SHIP_INDEX + 0 unit on the Y + 0 row BLACK.
	sw $t2, 4($t1)			# Paint the SHIP_INDEX + 1 unit on the Y + 0 row BLUE.
	sw $t2, 8($t1)			# Paint the SHIP_INDEX + 2 unit on the Y + 0 row BLUE.
	sw $t2, 512($t1)		# Paint the SHIP_INDEX + 0 unit on the Y + 2 row BLACK.
	sw $t2, 268($t1)		# Paint the SHIP_INDEX + 3 unit on the Y + 1 row WHITE.
	addi $t1, $t1, 256
	move $a0, $t1			# prepair to call the function
	jal PAINT_SHIP			# call function "PAINT_SHIP"
	j OBSTACLE_START
	
RESPOND_TO_P:
	j START
	
# Update obstacle location.
OBSTACLE_START:
	li $s1, 0	# $s1 stores 0 for Y.
	la $s2, ARR_OBSTACLE	# $s2 holds address of ARR_OBSTACLE
	li $t7, 4
	mul $t7, $t7, WIDTH	# $t7 stores the WIDTH * 4 = 256
	li $t8, 4		
	mul $t8, $t8, HEIGHT 	# $t8 stores the HEIGHT * 4 = 256
OBSTACLE_LOOP1:
	mul $s3, $s1, 64	# mul i * 64 = number of address should x move
	add $s4, $s3, $s2	# $s3 holds addr(OBSTACLE[i])
	add $s6, $s3, $t0	# $s6 holds addr(BASE_ADDRESS + i)
	li $s0, 0		# $s0 stores 0 for j.
OBSTACLE_LOOP2:	
	lw $s5, 0($s4)		# $s5 = OBSTACLE[i]
	
	beqz $s5, OBSTACLE_END_IF	# if OBSTACLE[i] != 0
	beqz $s0, OBSTACLE_END_IF_EDGE	# if j != 0
	#beqz $s1, OBSTACLE_END_IF_EDGE	# if i != 0
	
	li $t2, GREY
	sw $t2, -4($s6)
	li $t2, 1
	sw $t2, -4($s4)
OBSTACLE_END_IF_EDGE:
	li $t2, BLACK
	sw $t2, 0($s6)
	li $t2, 0
	sw $t2, 0($s4)
	
OBSTACLE_END_IF:
	addi $s0, $s0, 4
	addi $s4, $s4, 4	# $s4 holds addr(OBSTACLE[i][j])
	addi $s6, $s6, 4	# $s7 = the address of pixel [i][j]
	bne $s0, $t7, OBSTACLE_LOOP2	# while (TEMP_X != WITDTH)
	addi $s1, $s1, 4
	bne $s1, $t8, OBSTACLE_LOOP1	# while (TEMP_Y != HEIGHT)
	
OBSTACLE_END_LOOP:

# Random some obstacles

	li $s0, 16			# set $s0 = 8
	div $t3, $s0			# the number of loop % 8
	mfhi $s0			# get the remainder
	bnez $s0, Collision_detection	# if remainder == 0, Random some number to creative ship
	li $s6, 16376			# the last two pixel
	la $s7, ARR_OBSTACLE		# $s7 holds address of ARR_OBSTACLE
	li $t8, 0			# set the current loop time
	move $t9, $t4			# set the max loop time
	#li $t9, 1
RANDOM: 	
	li $v0, 42			# Random a number in range
	li $a0, 0
	li $a1, 63			# the max range is 63
	syscall				
	move $s1, $a0			# store random number1 in $s1

RANDOM_CHECK:
	blt $s1, 11, RANDOM_LOOP

PAINT_OBSTACLE:
	mul $s1, $s1, 256		# put $s1 to the corresponding row
	addi $s1, $s1, 248		# put it to the second last column
	add $s4, $s1, $t0		# get the address of pixel
	add $s5, $s1, $s7		# get the address of ARR_OBSTACLE
	
	beq $s1, $s6, UNNORMAL_PAINT
	li $t2, GREY			# get GREY color
	sw $t2, 256($s4)
	sw $t2, 260($s4)
	li $t2, 1			# change $t2 to 1
	sw $t2, 256($s5)
	sw $t2, 260($s5)
UNNORMAL_PAINT:
	li $t2, GREY			# get GREY color
	sw $t2, 0($s4)			# paint the color
	sw $t2, 4($s4)
	li $t2, 1			# change $t2 to 1
	sw $t2, 0($s5)			# change the ARR_OBSTACLE array to 1
	sw $t2, 4($s5)
	
	addi $t8, $t8, 1
RANDOM_LOOP:
	bne $t8, $t9, RANDOM

# Detecte of Collosion between ship and obstacle
Collision_detection:
	
	sub $s0, $t1, $t0		# set $s0 as the distance between ship and base address
	la $s1, ARR_OBSTACLE		# $s1 holds address of ARR_OBSTACLE
	add $s2, $s1, $s0		# Go to ARR_OBSTACLE[i][j]
	
DETECT_0:
	lw $s3, 0($s2)			# Get the value of ARR_OBSTACLE[i][j]
	beq $s3, 0, DETECT_4		# check position get hitted or not
	li $a0, 0			# store local positon relative to collision
	jal COLLISION
DETECT_4:
	lw $s3, 4($s2)			# Get the value of ARR_OBSTACLE[i][j]
	beq $s3, 0, DETECT_8		# check position get hitted or not
	li $a0, 4			# store local positon relative to collision
	jal COLLISION
DETECT_8:
	lw $s3, 8($s2)			# Get the value of ARR_OBSTACLE[i][j]
	beq $s3, 0, DETECT_260		# check position get hitted or not
	li $a0, 8			# store local positon relative to collision
	jal COLLISION
DETECT_260:
	lw $s3, 260($s2)		# Get the value of ARR_OBSTACLE[i][j]
	beq $s3, 0, DETECT_264		# check position get hitted or not
	li $a0, 260			# store local positon relative to collision
	jal COLLISION
DETECT_264:
	lw $s3, 264($s2)		# Get the value of ARR_OBSTACLE[i][j]
	beq $s3, 0, DETECT_268		# check position get hitted or not
	li $a0, 264			# store local positon relative to collision
	jal COLLISION
DETECT_268:
	lw $s3, 268($s2)		# Get the value of ARR_OBSTACLE[i][j]
	beq $s3, 0, DETECT_512		# check position get hitted or not
	li $a0, 268			# store local positon relative to collision
	jal COLLISION
DETECT_512:
	lw $s3, 512($s2)		# Get the value of ARR_OBSTACLE[i][j]
	beq $s3, 0, DETECT_516		# check position get hitted or not
	li $a0, 512			# store local positon relative to collision
	jal COLLISION
	
DETECT_516:
	lw $s3, 516($s2)		# Get the value of ARR_OBSTACLE[i][j]
	beq $s3, 0, DETECT_520		# check position get hitted or not
	li $a0, 516			# store local positon relative to collision
	jal COLLISION
	
DETECT_520:
	lw $s3, 520($s2)		# Get the value of ARR_OBSTACLE[i][j]
	beq $s3, 0, FINISH_DETECT	# check position get hitted or not
	li $a0, 520			# store local positon relative to collision
	jal COLLISION
FINISH_DETECT:
	j END_ONE_ROUND
	
# End for one round.
END_ONE_ROUND:
	addi $t3, $t3, 1
	beq $t5, $t6, CHECK_HP		# check if collosion happened
	move $t5, $t6			# change health
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 740
	move $a0, $s0			# prepare to call

	beq $t5, 8, CALL_EIGHT
	beq $t5, 7, CALL_SEVEN
	beq $t5, 6, CALL_SIX
	beq $t5, 5, CALL_FIVE
	beq $t5, 4, CALL_FOUR
	beq $t5, 3, CALL_THREE
	beq $t5, 2, CALL_TWO
	beq $t5, 1, CALL_ONE
	j CHECK_HP

CALL_EIGHT:
	jal PRINT_EIGHT
	j CHECK_HP
CALL_SEVEN:
	jal PRINT_SEVEN
	j CHECK_HP
CALL_SIX:
	jal PRINT_SIX
	j CHECK_HP
CALL_FIVE:
	jal PRINT_FIVE
	j CHECK_HP
CALL_FOUR:
	jal PRINT_FOUR
	j CHECK_HP
CALL_THREE:
	jal PRINT_THREE
	j CHECK_HP
CALL_TWO:
	jal PRINT_TWO
	j CHECK_HP
CALL_ONE:
	jal PRINT_ONE
	j CHECK_HP
	
CHECK_HP:
	move $a0, $t1			# prepair to call the function
	jal PAINT_SHIP			# call function "PAINT_SHIP"
	beq $t5, 0, END			# check health
	beq $t3, 9999, END		# "YOU WIN"
	addi $t3, $t3, 1
	li $s0, 0
	li $s1, 0
	beq $t3, 1000, CHANGE_DIFFICULTY	# change difficuty of game to 2
	beq $t3, 2000, CHANGE_DIFFICULTY	# change difficuty of game to 3
	beq $t3, 3000, CHANGE_DIFFICULTY	# change difficuty of game to 4
	beq $t3, 4000, CHANGE_DIFFICULTY	# change difficuty of game to 5
	beq $t3, 5000, CHANGE_DIFFICULTY	# change difficuty of game to 6
	beq $t3, 6000, CHANGE_DIFFICULTY	# change difficuty of game to 7
	beq $t3, 7000, CHANGE_DIFFICULTY	# change difficuty of game to 8
	j START_BIG_LOOP

CHANGE_DIFFICULTY:
	addi $t4, $t4, 1
	addi $s1, $s1, 1
	j START_BIG_LOOP

END:	
	jal CLEAR_UP
	li $t0, BASE_ADDRESS
	addi $s0, $t0, 4892
	move $a0, $s0
	jal PRINT_GAME_OVER
	addi $s0, $t0, 7232
	move $a0, $s0
	jal PRINT_SCORE
	addi $s0, $t0, 9296
	move $a0, $t3		#  get t3
	move $a1, $s0		# address
	jal COMPARE
	j TERMINATE
	
	
TERMINATE:
	# terminate the program
	li $v0, 10 		# terminate the program gracefully
	syscall
	
	
#######################################################################################################################################################


# Clear up the screen 
CLEAR_UP:
	
	la $s0, ARR_OBSTACLE		# set $s0 to the address of ARR_OBSTACLE
	li $s2, 0			# set $s2 TEMP_X to 0
	li $s3, 0			# set $s3 TEMP_Y to 0
	li $s4, 0			# set $s4 TEMP_ADDRESS to 0
	add $s4, $s4, $t0		# set $s4 TEMP_ADDRESS to BASE_ADDRESS 
	li $t7, WIDTH			# set $t7 to WIDTH
	li $t8, HEIGHT			# set $t8 to HEIGHT
CLEAR_UP_LOOP1:	
	li $t2, BLACK			# set color to black
	sw $t2, 0($s4)			# change color to black
	li $t2, 0			
	sw $t2, 0($s0)			# change array[i][j] to 0
	addi $s0, $s0, 4		# ARR_OBSTACLE to the next address
	addi $s4, $s4, 4		# To the next address
	addi $s3, $s3, 1		# $s3 = $s3 + 1
	bne $s3, $t8, CLEAR_UP_LOOP1	# while (TEMP_Y != HEIGHT)
CLEAR_UP_LOOP2:
	addi $s2, $s2, 1		# $s2 = $s2 + 1
	li $s3, 0			# set $s3 TEMP_Y to 0
	bne $s2, $t7, CLEAR_UP_LOOP1	# while (TEMP_X != WITDTH) 
	jr $ra
	
	
# CLEAN UP NUMBER
CLEAN_NUMBER:
	move $s0, $a0		# get the address of clean.
	li $s1, 0		# X
	li $s2, 0		# Y
	li $t2, BLACK
CLEAN_NUMBER_LOOP1:
	sw $t2, 0($s0)
	addi $s0, $s0, 4
	addi $s3, $s3, 1
	bne $s3, 5, CLEAN_NUMBER_LOOP1
CLEAN_NUMBER_LOOP2:
	addi $s2, $s2, 1
	li $s3, 0
	addi $s0, $s0, -20
	addi $s0, $s0, 256
	bne $s2, 5, CLEAN_NUMBER_LOOP1
	jr $ra

# Paint the ship on screen
PAINT_SHIP:	
	move $t1, $a0		# recieve the address of ship
	li $t2, RED		# set color to RED
	sw $t2, 0($t1)		# Paint the SHIP_INDEX + 0 unit on the Y + 0 row RED.
	sw $t2, 512($t1)	# Paint the SHIP_INDEX + 0 unit on the Y + 2 row RED.
	li $t2, WHITE		# set color to WHITE
	sw $t2, 268($t1)	# Paint the SHIP_INDEX + 3 unit on the Y + 1 row WHITE.
	li $t2, BLUE		# set color to BLUE
	sw $t2, 4($t1)		# Paint the SHIP_INDEX + 1 unit on the Y + 0 row BLUE.
	sw $t2, 8($t1)		# Paint the SHIP_INDEX + 2 unit on the Y + 0 row BLUE.
	sw $t2, 260($t1)	# Paint the SHIP_INDEX + 1 unit on the Y + 1 row BLUE.
	sw $t2, 264($t1)	# Paint the SHIP_INDEX + 2 unit on the Y + 1 row BLUE.
	sw $t2, 516($t1)	# Paint the SHIP_INDEX + 1 unit on the Y + 2 row BLUE.
	sw $t2, 520($t1)	# Paint the SHIP_INDEX + 2 unit on the Y + 2 row BLUE.
	jr $ra			# return to the caller

# Collision situation	
COLLISION:
	move $s4, $a0			# the relative location about ship
	add $s7, $t1, $s4		# the absolute address of ship
	li $t2, PURPLE
	sw $t2, 0($s7)			# Paint the SHIP_INDEX + 0 unit on the Y + 0 row PURPLE.
	bne $t5, $t6, SLEEP_COLLISION
	addi $t6, $t6, -1		# the health minus 1
	
# sleep func for user indicate collision
SLEEP_COLLISION:
	li $v0, 32
	li $a0, 200   # Wait one second (1000 milliseconds)
	syscall
# return to the caller
	jr $ra
	

# COMPARE	
COMPARE:
	move $s5, $a0		# the detected number
	move $s6, $a1		# address to print
	li $t9, 1000
	li $t8, 0		# i
	move $t7, $ra		# store $ra
COMPARE_LOOP:		
	div $s7, $s5, $t9
	move $a0, $s6
	beq $s7, 9, CHECK_NINE
	beq $s7, 8, CHECK_EIGHT
	beq $s7, 7, CHECK_SEVEN
	beq $s7, 6, CHECK_SIX
	beq $s7, 5, CHECK_FIVE
	beq $s7, 4, CHECK_FOUR
	beq $s7, 3, CHECK_THREE
	beq $s7, 2, CHECK_TWO
	beq $s7, 1, CHECK_ONE
	beq $s7, 0, CHECK_ZERO
CHECK_BACK:	
	mul $s1, $s7, $t9
	sub $s5, $s5, $s1		# get new number
	blt $t9, 10, NOT_DIV
	div $t9, $t9, 10
NOT_DIV:
	addi $t8, $t8, 1
	addi $s6, $s6, 24		# give space for next number
	bne $t8, 4, COMPARE_LOOP
	
	move $ra, $t7
	jr $ra
	
CHECK_NINE:
	jal PRINT_NINE
	j CHECK_BACK
CHECK_EIGHT:
	jal PRINT_EIGHT
	j CHECK_BACK
CHECK_SEVEN:
	jal PRINT_SEVEN
	j CHECK_BACK
CHECK_SIX:
	jal PRINT_SIX
	j CHECK_BACK
CHECK_FIVE:
	jal PRINT_FIVE
	j CHECK_BACK
CHECK_FOUR:
	jal PRINT_FOUR
	j CHECK_BACK
CHECK_THREE:
	jal PRINT_THREE
	j CHECK_BACK
CHECK_TWO:
	jal PRINT_TWO
	j CHECK_BACK
CHECK_ONE:
	jal PRINT_ONE
	j CHECK_BACK
CHECK_ZERO:
	jal PRINT_ZERO
	j CHECK_BACK

# PRINT WELCOME
PRINT_WELCOME:
	move $s1, $ra
	move $s0, $a0
	move $a0, $s0
	jal PRINT_W
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_E
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_L
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_C
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_O
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_M
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_E
	move $ra, $s1
	jr $ra
	
	
# PRINT TO	
PRINT_TO:
	move $s1, $ra
	move $s0, $a0
	move $a0, $s0
	jal PRINT_T
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_O
	move $ra, $s1
	jr $ra
	
# PRINT_SHIP_GAME	
PRINT_SHIP_GAME:
	move $s1, $ra
	move $s0, $a0
	move $a0, $s0
	jal PRINT_S
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_H
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_I
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_P
	addi $s0, $s0, 36
	move $a0, $s0
	jal PRINT_G
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_A
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_M
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_E
	move $ra, $s1
	jr $ra
	
# PRINT_START_IN
PRINT_START_IN:
	move $s1, $ra
	move $s0, $a0
	move $a0, $s0
	jal PRINT_S
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_T
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_A
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_R
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_T
	addi $s0, $s0, 36
	move $a0, $s0
	jal PRINT_I
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_N
	# PRINT ":"
	addi $s0, $s0, 24
	sw $t2, 512($s0)
	sw $t2, 1024($s0)
	move $ra, $s1
	jr $ra

# PRINT HP
PRINT_HP:
	move $s1, $ra
	move $s0, $a0
	move $a0, $s0
	jal PRINT_H
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_P
	addi $s0, $s0, 24
	sw $t2, 512($s0)
	sw $t2, 1024($s0)
	move $ra, $s1
	jr $ra
	
# PRINT GAME OVER	
PRINT_GAME_OVER:
	move $s1, $ra
	move $s0, $a0
	move $a0, $s0
	jal PRINT_G
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_A
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_M
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_E
	addi $s0, $s0, 36
	move $a0, $s0
	jal PRINT_O
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_V
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_E
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_R
	move $ra, $s1
	jr $ra
	
# PRINT SCORE	
PRINT_SCORE:
	move $s1, $ra
	move $s0, $a0
	move $a0, $s0
	jal PRINT_S
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_C
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_O
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_R
	addi $s0, $s0, 24
	move $a0, $s0
	jal PRINT_E
	# PRINT ":"
	addi $s0, $s0, 24
	sw $t2, 512($s0)
	sw $t2, 1024($s0)
	
	move $ra, $s1
	jr $ra

# PRINT "A"	
PRINT_A:
	move $s0, $a0
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 16($s0)
	sw $t2, 256($s0)
	sw $t2, 272($s0)
	sw $t2, 512($s0)
	sw $t2, 516($s0)
	sw $t2, 520($s0)
	sw $t2, 524($s0)
	sw $t2, 528($s0)
	sw $t2, 768($s0)
	sw $t2, 784($s0)
	sw $t2, 1024($s0)
	sw $t2, 1040($s0)
	jr $ra
	
# PRINT "C"	
PRINT_C:
	move $s0, $a0
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 16($s0)
	sw $t2, 256($s0)
	sw $t2, 512($s0)
	sw $t2, 768($s0)
	sw $t2, 1024($s0)
	sw $t2, 1028($s0)
	sw $t2, 1032($s0)
	sw $t2, 1036($s0)
	sw $t2, 1040($s0)
	jr $ra

# PRINT D
PRINT_D:
	move $s0, $a0
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 256($s0)
	sw $t2, 272($s0)
	sw $t2, 512($s0)
	sw $t2, 528($s0)
	sw $t2, 768($s0)
	sw $t2, 784($s0)
	sw $t2, 1024($s0)
	sw $t2, 1028($s0)
	sw $t2, 1032($s0)
	sw $t2, 1036($s0)
	sw $t2, 536($s0)
	sw $t2, 1048($s0)
	jr $ra
	
# PRINT "E"	
PRINT_E:
	move $s0, $a0
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 16($s0)
	sw $t2, 256($s0)
	sw $t2, 512($s0)
	sw $t2, 516($s0)
	sw $t2, 520($s0)
	sw $t2, 524($s0)
	sw $t2, 528($s0)
	sw $t2, 768($s0)
	sw $t2, 1024($s0)
	sw $t2, 1028($s0)
	sw $t2, 1032($s0)
	sw $t2, 1036($s0)
	sw $t2, 1040($s0)
	jr $ra

# PRINT "G"	
PRINT_G:
	move $s0, $a0
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 16($s0)
	sw $t2, 256($s0)
	sw $t2, 512($s0)
	sw $t2, 520($s0)
	sw $t2, 524($s0)
	sw $t2, 528($s0)
	sw $t2, 768($s0)
	sw $t2, 784($s0)
	sw $t2, 1024($s0)
	sw $t2, 1028($s0)
	sw $t2, 1032($s0)
	sw $t2, 1036($s0)
	sw $t2, 1040($s0)
	jr $ra


# PRINT "H"
PRINT_H:
	move $s0, $a0
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 16($s0)
	sw $t2, 256($s0)
	sw $t2, 272($s0)
	sw $t2, 512($s0)
	sw $t2, 516($s0)
	sw $t2, 520($s0)
	sw $t2, 524($s0)
	sw $t2, 528($s0)
	sw $t2, 768($s0)
	sw $t2, 784($s0)
	sw $t2, 1024($s0)
	sw $t2, 1040($s0)
	jr $ra

# PRINT_I
PRINT_I:
	move $s0, $a0
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 16($s0)
	sw $t2, 264($s0)
	sw $t2, 520($s0)
	sw $t2, 776($s0)
	sw $t2, 1024($s0)
	sw $t2, 1028($s0)
	sw $t2, 1032($s0)
	sw $t2, 1036($s0)
	sw $t2, 1040($s0)
	jr $ra
	
# PRINT "L"
PRINT_L:
	move $s0, $a0
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 256($s0)
	sw $t2, 512($s0)
	sw $t2, 768($s0)
	sw $t2, 1024($s0)
	sw $t2, 1028($s0)
	sw $t2, 1032($s0)
	sw $t2, 1036($s0)
	sw $t2, 1040($s0)
	jr $ra

# PRINT "M"
PRINT_M:
	move $s0, $a0
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 16($s0)
	sw $t2, 256($s0)
	sw $t2, 264($s0)
	sw $t2, 272($s0)
	sw $t2, 512($s0)
	sw $t2, 520($s0)
	sw $t2, 528($s0)
	sw $t2, 768($s0)
	sw $t2, 776($s0)
	sw $t2, 784($s0)
	sw $t2, 1024($s0)
	sw $t2, 1032($s0)
	sw $t2, 1040($s0)
	jr $ra
	
# PRINT_N
PRINT_N:
	move $s0, $a0
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 16($s0)
	sw $t2, 256($s0)
	sw $t2, 260($s0)
	sw $t2, 272($s0)
	sw $t2, 512($s0)
	sw $t2, 520($s0)
	sw $t2, 528($s0)
	sw $t2, 768($s0)
	sw $t2, 780($s0)
	sw $t2, 784($s0)
	sw $t2, 1024($s0)
	sw $t2, 1040($s0)
	jr $ra
	
# PRINT "O"
PRINT_O:
	move $s0, $a0
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 16($s0)
	sw $t2, 256($s0)
	sw $t2, 272($s0)
	sw $t2, 512($s0)
	sw $t2, 528($s0)
	sw $t2, 768($s0)
	sw $t2, 784($s0)
	sw $t2, 1024($s0)
	sw $t2, 1028($s0)
	sw $t2, 1032($s0)
	sw $t2, 1036($s0)
	sw $t2, 1040($s0)
	jr $ra

# PRINT "P"
 PRINT_P:
	move $s0, $a0
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 16($s0)
	sw $t2, 256($s0)
	sw $t2, 272($s0)
	sw $t2, 512($s0)
	sw $t2, 516($s0)
	sw $t2, 520($s0)
	sw $t2, 524($s0)
	sw $t2, 528($s0)
	sw $t2, 768($s0)
	sw $t2, 1024($s0)
	jr $ra
	
# PRINT "R"
 PRINT_R:
	move $s0, $a0
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 256($s0)
	sw $t2, 272($s0)
	sw $t2, 512($s0)
	sw $t2, 516($s0)
	sw $t2, 520($s0)
	sw $t2, 524($s0)
	sw $t2, 768($s0)
	sw $t2, 784($s0)
	sw $t2, 1024($s0)
	sw $t2, 1040($s0)
	jr $ra
	
# PRINT "S"
 PRINT_S:
	move $s0, $a0
	li $t2, WHITE
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 16($s0)
	sw $t2, 256($s0)
	sw $t2, 516($s0)
	sw $t2, 520($s0)
	sw $t2, 524($s0)
	sw $t2, 784($s0)
	sw $t2, 1024($s0)
	sw $t2, 1028($s0)
	sw $t2, 1032($s0)
	sw $t2, 1036($s0)
	jr $ra
	
# PRINT "T"
 PRINT_T:
	move $s0, $a0
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 16($s0)
	sw $t2, 264($s0)
	sw $t2, 520($s0)
	sw $t2, 776($s0)
	sw $t2, 1032($s0)
	jr $ra
	
# PRINT "V"
 PRINT_V:
	move $s0, $a0
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 16($s0)
	sw $t2, 256($s0)
	sw $t2, 272($s0)
	sw $t2, 512($s0)
	sw $t2, 528($s0)
	sw $t2, 512($s0)
	sw $t2, 772($s0)
	sw $t2, 780($s0)
	sw $t2, 1032($s0)
	jr $ra
	
# PRINT "W"	
PRINT_W:
	move $s0, $a0
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 8($s0)
	sw $t2, 16($s0)
	sw $t2, 256($s0)
	sw $t2,	264($s0)
	sw $t2, 272($s0)
	sw $t2, 512($s0)
	sw $t2, 520($s0)
	sw $t2, 528($s0)
	sw $t2, 768($s0)
	sw $t2, 776($s0)
	sw $t2, 784($s0)
	sw $t2, 1024($s0)
	sw $t2, 1028($s0)
	sw $t2, 1032($s0)
	sw $t2, 1036($s0)
	sw $t2, 1040($s0)
	jr $ra

# PRINT	NINE
PRINT_NINE:
	move $s0, $a0
	move $a1, $ra		# store $ra
	jal CLEAN_NUMBER
	move $s0, $a0
	move $ra, $a1
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 16($s0)
	sw $t2, 256($s0)
	sw $t2, 272($s0)
	sw $t2, 512($s0)
	sw $t2, 516($s0)
	sw $t2, 520($s0)
	sw $t2, 524($s0)
	sw $t2, 528($s0)
	sw $t2, 784($s0)
	sw $t2, 1024($s0)
	sw $t2, 1028($s0)
	sw $t2, 1032($s0)
	sw $t2, 1036($s0)
	sw $t2, 1040($s0)
	jr $ra
	
# PRINT	EIGHT
PRINT_EIGHT:
	move $s0, $a0
	move $a1, $ra		# store $ra
	jal CLEAN_NUMBER
	move $s0, $a0
	move $ra, $a1
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 16($s0)
	sw $t2, 256($s0)
	sw $t2, 272($s0)
	sw $t2, 512($s0)
	sw $t2, 516($s0)
	sw $t2, 520($s0)
	sw $t2, 524($s0)
	sw $t2, 528($s0)
	sw $t2, 768($s0)
	sw $t2, 784($s0)
	sw $t2, 1024($s0)
	sw $t2, 1028($s0)
	sw $t2, 1032($s0)
	sw $t2, 1036($s0)
	sw $t2, 1040($s0)
	jr $ra

# PRINT	SEVEN
PRINT_SEVEN:
	move $s0, $a0
	move $a1, $ra		# store $ra
	jal CLEAN_NUMBER
	move $s0, $a0
	move $ra, $a1
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 16($s0)
	sw $t2, 272($s0)
	sw $t2, 524($s0)
	sw $t2, 776($s0)
	sw $t2, 1032($s0)
	jr $ra
	
# PRINT	SIX
PRINT_SIX:
	move $s0, $a0
	move $a1, $ra		# store $ra
	jal CLEAN_NUMBER
	move $s0, $a0
	move $ra, $a1
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 16($s0)
	sw $t2, 256($s0)
	sw $t2, 512($s0)
	sw $t2, 516($s0)
	sw $t2, 520($s0)
	sw $t2, 524($s0)
	sw $t2, 528($s0)
	sw $t2, 768($s0)
	sw $t2, 784($s0)
	sw $t2, 1024($s0)
	sw $t2, 1028($s0)
	sw $t2, 1032($s0)
	sw $t2, 1036($s0)
	sw $t2, 1040($s0)
	jr $ra
	
# PRINT	FIVE
PRINT_FIVE:
	move $s0, $a0
	move $a1, $ra		# store $ra
	jal CLEAN_NUMBER
	move $s0, $a0
	move $ra, $a1
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 16($s0)
	sw $t2, 256($s0)
	sw $t2, 512($s0)
	sw $t2, 516($s0)
	sw $t2, 520($s0)
	sw $t2, 524($s0)
	sw $t2, 528($s0)
	sw $t2, 784($s0)
	sw $t2, 1024($s0)
	sw $t2, 1028($s0)
	sw $t2, 1032($s0)
	sw $t2, 1036($s0)
	sw $t2, 1040($s0)
	jr $ra
	
# PRINT	FOUR
PRINT_FOUR:
	move $s0, $a0
	move $a1, $ra		# store $ra
	jal CLEAN_NUMBER
	move $s0, $a0
	move $ra, $a1
	li $t2, WHITE
	sw $t2, 12($s0)
	sw $t2, 264($s0)
	sw $t2, 268($s0)
	sw $t2, 516($s0)
	sw $t2, 524($s0)
	sw $t2, 768($s0)
	sw $t2, 772($s0)
	sw $t2, 776($s0)
	sw $t2, 780($s0)
	sw $t2, 784($s0)
	sw $t2, 1036($s0)
	jr $ra

# PRINT	THREE
PRINT_THREE:
	move $s0, $a0
	move $a1, $ra		# store $ra
	jal CLEAN_NUMBER
	move $s0, $a0
	move $ra, $a1
	li $t2, WHITE
	sw $t2, 0($s0)
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 16($s0)
	sw $t2, 272($s0)
	sw $t2, 520($s0)
	sw $t2, 524($s0)
	sw $t2, 528($s0)
	sw $t2, 784($s0)
	sw $t2, 1024($s0)
	sw $t2, 1028($s0)
	sw $t2, 1032($s0)
	sw $t2, 1036($s0)
	sw $t2, 1040($s0)
	jr $ra
	
# PRINT	TWO
PRINT_TWO:
	move $s0, $a0
	move $a1, $ra		# store $ra
	jal CLEAN_NUMBER
	move $s0, $a0
	move $ra, $a1
	li $t2, WHITE
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 256($s0)
	sw $t2, 272($s0)
	sw $t2, 520($s0)
	sw $t2, 524($s0)
	sw $t2, 772($s0)
	sw $t2, 1024($s0)
	sw $t2, 1028($s0)
	sw $t2, 1032($s0)
	sw $t2, 1036($s0)
	sw $t2, 1040($s0)
	jr $ra

# PRINT	ONE
PRINT_ONE:
	move $s0, $a0
	move $a1, $ra		# store $ra
	jal CLEAN_NUMBER
	move $s0, $a0
	move $ra, $a1
	li $t2, WHITE
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 256($s0)
	sw $t2, 264($s0)
	sw $t2, 520($s0)
	sw $t2, 776($s0)
	sw $t2, 1024($s0)
	sw $t2, 1028($s0)
	sw $t2, 1032($s0)
	sw $t2, 1036($s0)
	sw $t2, 1040($s0)
	jr $ra
	
# PRINT	ZERO
PRINT_ZERO:
	move $s0, $a0
	move $a1, $ra		# store $ra
	jal CLEAN_NUMBER
	move $s0, $a0
	move $ra, $a1
	li $t2, WHITE
	sw $t2, 4($s0)
	sw $t2, 8($s0)
	sw $t2, 12($s0)
	sw $t2, 256($s0)
	sw $t2, 272($s0)
	sw $t2, 512($s0)
	sw $t2, 528($s0)
	sw $t2, 768($s0)
	sw $t2, 784($s0)
	sw $t2, 1028($s0)
	sw $t2, 1032($s0)
	sw $t2, 1036($s0)
	jr $ra
