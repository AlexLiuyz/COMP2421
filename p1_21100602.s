#Readme:

#usage of the registers:
#s0 store the input number, a1 store the progress(binary, quaternary, or octal), $s1 for store the divisor in the program, always be 2. $a2 is for the string address, $a3 for the length of the string(the length of the 
#part we want to use),$a0,$a1,$a2, can be used as the register to pass the parameter to the subroutine. $t0,$t1,$t2,$t3,$t7 is for temporary variables, can be use as the loop counter or length of the string, $t4,$t6 is for for 
#storing the base address of the string,$t5 store the temporary variable(The multiplier in the function), $t8 is also used for storing the address, $t9 is the flag in order 
#to detect the negative number 

#Basic structure:
#In this program I used subroutine to finish the task, because through one simple conversion program, we only need to change the progress number(binary, quaternary, octal),which means pass the number,
#and 2,4,8 to the subroutine to let it finish the task. And there is a outside loop to ensure the repetition use of the program.

#Implementation details:
#Subroutine: For the subroutine, the algorithm is to use div function to get the quotient and the remainder,store the remainder to the end of the result string(String named binary,quaternary,octal), and each time
#deduce the pointer by one, to move forward. And to handle the negative number, I have a flag which stored in $t9, if it is set to 1, then we will do some special handling in the subroutine.First, inverse the bits,
#which means 1 to 0, 0 to 1, then do addition add one to the result.(Number conversion)

#The handling of complement of Quaternary and Octal:if it is negative, we will use 2'complement form to get the value. Take care of the first 2 bits for octal, for the other thirty bits, I will have a multiplier stored in $t5
#(for quaternary it is 2,for octal it is 4), if it decrease to one that means I need to increase it to the original size,if not I should decrease it by divide 2.(Number conversion)

#Main program: The main program is used for control the who structure, pass the parameter determine which result string to store,and do what kind of conversion(Binary, Quaternary,or Octal), and also out put the 
#operation result after the execution of the subroutine, if it is a negative number, previously I have mentioned is that $t9 be set to one, then we will only go through the binary convension, not go through the other two.
#(Result output, and the input handling)

#Outside repetition: The second design is the repetition of the program, which is to make a loop at the outside of the whole conversion part, let the program to detect whether the user's input is 0 or 1. if it 
#is 1, he/she can input the data again, if it is 0, then the program will say bye to he/she. If it is neither 0 nor 1, the program will ask them again, until their input satisfy the requirement(shoul be 1 or 0).(Repetition)

#################################################################
##														       ##
## A program do the base conversion by calling the subroutine  ##
##                                                             ##
#################################################################
.data
ask: .asciiz "\n Enter a number:"
reply: .asciiz "\n input number is: "
continue: .asciiz "\n Continue? (1=Yes/0=No)"
result1: .asciiz "\n Binary: "
result2: .asciiz "\n Quaternary: "
result3: .asciiz "\n Octal: "
end_message: .asciiz "\n Bye!"
#result strings.
binary: .space 33         #result string to store the binary value
quaternary: .space 17     #result string to store the quaternary value
octal: .space 12          #result string to store the octal value 
.text
.globl main
main:
resume:                  #if the user want to continueing input numbers
#
#step1: print the ask message using system call 4:
#
	la $a0, ask          # load string address into $a0(ask for input number)
	li $v0, 4			 # and I/O code into $v0
	syscall				 # execute the syscall to perform input/output via the console

	li $v0, 5			# call syscall 5 to read the integer
	syscall				# after the call, the number is stored in $v0
	move $s0, $v0       #to input the value in $s0
	move $s1,$s0
	bgt $s0,$0,positive #if it is a positive number then we won't go through the following operation
	subu $s0,$0,$s0     #convert the negative number to positive
	ori $t9,$0,1       #serve as the negative flag
	
positive:
	la $a0, reply       # load string address into $a0(reply to the user)
	li $v0, 4			# and I/O code into $v0
	syscall				# execute the syscall to perform input/output via the console

print:
	li $v0, 1           # call syscall 1 to print the number input by the user
	move $a0, $s1       # load string address into $a0(ask for input number)
	syscall

#
#step 2: do the number conversion(Binary)
#
	or $a0, $s0, $0    #load the input number to $a0(parameter)
	ori $a3, $0,32     #the length of the binary string(parameter)
	li $a1, 2          #for the binary(parameter)
	la $a2,binary      #for the start of the binary array(parameter)
	addiu $a2, $a2, 31 #goto the end position of the string

	#goto the subroutine to do the operation
	jal transfer       

	#print the binary message
	la $a0, result1    # load string address into $a0(reply to the user)
	li $v0, 4		   # system call 4 to print the result string, tell the user it is binary
	syscall            

	#print the binary number stored
	la $a0, binary     #load the string address into $a0
	li $v0, 4		   # system call 4 to show the output to the user, the binary value
	syscall
	
	addiu $a0,$0,1
#
#step 3: do the number conversion(Quaternary)
#
	or $a0, $s0, $0		  #load the input number to $a0(parameter)
	ori $a3, $0,16	      #to get the length of the quaternary string
	li $a1, 4             #for the quaternary(parameter)
	la $a2,quaternary     #for the start of the quaternary string
	addiu $a2, $a2, 15    #goto the end of the position of the string

	beq $t9,$0,positive_quaternary		
	ori $t1,$0,0         #the counter for the loop
	ori $t2,$0,0         #the sum of 2 bits for quaternary
	ori $t5,$0,2         #the multiplier for each bit of the binary number
	ori $s1,$0,2         #for doing the division, always store 2,act as divisor
	ori $t7,$0,1         #for comparation, whether incrase or decrese
	la $t4,binary        #load the base address of the binary string
	la $t6,quaternary

	#the part uesd to deal with the negative number
quaternary_loop:
	lb  $t3,0($t4)         #store the containt of the binary number to $t3
	addiu $t3,$t3,-48      #store the number value to $t3
	mult $t3,$t5           #get the value of current digit
	mflo $t3               #get the result of the division
	addu $t2,$t3,$t2       #increase the sum
	addiu $t1,$t1,1        #increase the counter by 1
	addiu $t4,$t4,1

	#for check the value of $t5 if it is not 0, then we can decrease it
	bne $t5,$t7,decrease    #if $t5==1,time to increase
	addiu $t2,$t2,48
	sb $t2,0($t6)          #store the value to the quaternary result string
	addiu $t6,$t6,1        #increase the digit by 1
	sll $t5,$t5,1          #increase $t5,$t5=$t5*2
	ori $t2,$0,0           #after store, we need to empty $t2, for holding the value next time
	bne $t1,32,quaternary_loop #the counter of the loop, if it reaches the end of the binary string, then we can exit the loop

	#This part is for decreasing the size of the multiplier
decrease:
	div $t5,$s1           #divide the multiplier by 2, decrese it's size'
	mflo $t5              #get the value and store it back to $t5
	bne $t1,32,quaternary_loop
	j print_quaternary        #for not excute the jal(goto the print part, do not goto the subroutine)
	#goto the subroutine to do the operation
positive_quaternary:
	jal transfer
	
print_quaternary:
	#print the quaternary message
	la $a0,result2
	li $v0, 4
	syscall

	#print the quaternary number stored
	la $a0,quaternary
	li $v0, 4
	syscall

#
#step 4: do the number conversion(Octal)
#
	#this part of value will be pass to the subroutine
	or $a0, $s0, $0      #load the input number to $a0(parameter)
	ori $a3, $0,11       #to get the length of the octal string
	li $a1, 8            #for the octal(parameter)
	la $a2, octal        #for the start of the octal string
	addiu $a2, $a2, 10   #goto the end of the position of the string

	#the intailization part, we will use these value to do the conversion
	beq $t9,$0,positive_octal
	ori $t1,$0,2         #the counter for the loop
	ori $t2,$0,0         #the sum of 3 bits
	ori $t5,$0,4
	ori $s1,$0,2
	ori $t7,$0,1         #for comparation, whether incrase or decrese
	la $t4,binary        #load the base address of the binary string
	la $t6,octal

	lb $t3,0($t4)         #this is for special handling of 32 bits number, we need to care about the first 2 bis
	addiu $t3,$t3,-48     
	sll $t3,$t3,1         
	addu $t2,$t2,$t3

	#get the value of the second bit
	lb $t3,1($t4)         
	addiu $t3,$t3,-48 
	addu $t2,$t2,$t3 
	addiu $t2,$t2,48
	sb $t2,0($t6)        #store the result back to the first position of the string octal

	addiu $t4,$t4,2      #now we have read 2 bits of the binary number
	addiu $t6,$t6,1      #now we have defined first bit of the octal string
	ori $t2,$0,0         #empty the sum field

	#the part uesd to deal with the negative number for negative value
octal_loop:
	lb  $t3,0($t4)         #store the containt of the binary number to $t3
	addiu $t3,$t3,-48      #store the number value to $t3		   
	mult $t3,$t5           #get the value of current digit
	mflo $t3               
	addu $t2,$t3,$t2       #increase the sum
	addiu $t1,$t1,1        #increase the counter by 1
	addiu $t4,$t4,1
	#for check the value of $t5 if it is not 0, then we can decrease it
	bne $t5,$t7,decrease_octal    #if $t5==1,time to increase
	addiu $t2,$t2,48
	sb $t2,0($t6)          #store the value to the quaternary result string
	addiu $t6,$t6,1        #increase the digit by 1
	sll $t5,$t5,2          #increase $t5,$t5=$t5*4
	ori $t2,$0,0           #after store, we need to empty $t2, for holding the value next time
	bne $t1,32,octal_loop
	#This part is for decreasing the multiplier
decrease_octal:
	div $t5,$s1
	mflo $t5
	bne $t1,32,octal_loop
j print_octal

	#goto the subroutine to do the operation
positive_octal:
	jal transfer

print_octal:
	#print the octal message
	la $a0,result3
	li $v0, 4
	syscall

	#print the octal number stored
	la $a0,octal
	li $v0, 4
	syscall

#
#step 5: repetition,check whether the user want to reuse the program
#
check:                   #the point is for checking whether the user want to continue using the program
	addiu $t9,$0,0
	la $a0,continue		 #ask the user whether they want to continue input
	li $v0, 4			 #system call 4 to print the continue message
	syscall

	li $v0,5
	syscall
	move $t1,$v0		  #put the input value int $s1, for comparation
	ori $t2, $0, 1        #load 1 into $s2, for comparation
	beq $t1,$t2, resume   #if the input is 1 will resume the program
	bne $t1, $0, check    #if the input is not 0 or 1 will ask for

	#say bye to the user if they want to exit
	la $a0,end_message
	li $v0,4                 #use system call 4 to print the bye message to the user
	syscall

#end of the program					 
	li $v0, 10
	syscall

#
#Sub-Routine to transfer the number to binary, quaternary, or octal
#$t1 is the temporary end address,$t3 is the temporary length,$t4 is the temporary starting address
#initialize: to initialize each position of the string to 1
#loop:do the convert the decimal number to binary string
#complement_initializer: inverse the binary string, '1' -> '0','0' -> '1'(for negative number)
#addition: add one to the result to get 2's complement(for negative number)
transfer:
	
	andi $t0,$0,1			  #clear $t0
	addiu $t0,$t0,48		  #find the ascii code for the character '0'
	move $t1,$a2              #the starting address of the string(now it is the end address)
	move $t3,$a3              #load the length of the string
	subu $t1,$t1,$a3          #these two lines are for getting the start address of the string(binary, quaternary, octal)
	addiu $t1,$t1, 1          #
	move $t4,$t1              #store the starting address
#initize all the position of the result string by '0'
initialize:
	sb $t0,0($t1)         #initialize each position of the string to '0' 
	addiu $a3,$a3,-1      #count for the loop, play a role in the end condition
	addiu $t1,$t1,1		  #the index for the result string, increase by one each time
	bne $a3,$0,initialize #check whether we have reach to the end position of the result string
#do the transfer: modify the result string(Binary, quaternary,octal)

loop:
	div $a0, $a1          #use the div command to store the quotient in the $lo, remainder in the $hi
	mfhi $t1              #get the remainder
	mflo $a0			  #get the quotient, and update $a0's value
	addiu $t1, $t1, 48    #get the ascii of remainder
	sb $t1, 0($a2)	      #store the remainder to the current postion of the string(binary, quaternary, octal)
	addiu $a2, $a2,-1	  #count the current index of the string(binary, quaternary, octal), each time, decrease by 1
	bne $a0, $0, loop   
	#if positive number, now we can goto back sign, exit the subroutine
	bne $t9,1,back
	#Get 2 types of char, for latter useage
	addiu $t0,$0,49       #'1'
	addiu $t2,$0,48		  #'0'
complement_initializer:
	lb $t8,0($t4)                  #to load the binary string
	beq $t8,$t0,change_to_zero     #check if the position is '0', then goto convert it to '1','1' to '0' 
	sb $t0,0($t4)                         #change to one
	j flag                         #this flag is to avoid do change_to_zero again
change_to_zero:
	sb $t2,0($t4)						  #change to zero
flag:
	addiu $t3,$t3,-1                      #count for the loop, play a role in the end condition($t3 stored a3)
	addiu $t4,$t4,1		                  #the index for the result string, increase by one each time
	bne $t3,$0,	complement_initializer    #check whether we have reach to the end position of the result string

#now $t4-1 is the end address
#the following part is the addtion part,as we know that to get two's complement,finally we need to add 1 to the result
addition:                                
	addiu $t4,$t4,-1                  #the addition start from the last position of the number string
	lb $t1, 0($t4)                    #to load the number stored in the stringor later on,the comparation 
	beq $t1,$t0,to_zero               #check if it is 0 or 1, goto different branch
to_one:
	sb $t0, 0($t4)                    #if it is 0, then 0+1 = 1, we no need to do the addition again, just jump out the subroutine 
	j back
to_zero:
	sb $t2, 0($t4)					  #if it is 1, then 1+1 =10, then we need to change current position to '0', and there is still a carry bit, so jump back to do the addition again
	j addition
back:
	jr $ra