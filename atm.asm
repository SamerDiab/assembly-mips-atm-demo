#################################################################################
# The MIT License (MIT)								#
# Copyright (c) 2019 Samer Diab, contact@samerdiab.net for inquiries  		#
# Permission is hereby granted, free of charge, to any person obtaining a copy  #
# of this software and associated documentation files (the "Software"), to deal #
# in the Software without restriction, including without limitation the rights  #
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell     #
# copies of the Software, and to permit persons to whom the Software is         #
# furnished to do so, subject to the following conditions:			#
# The above copyright notice and this permission notice shall be included in all#
# copies or substantial portions of the Software.  				#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR    #
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,      #
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE   #
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER        #
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, #
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE #
# SOFTWARE.									#		
#################################################################################
.data
strinput1 : .space 16
strinput2 : .space 16

username : .asciiz "Samer"
password : .asciiz "Diab"
balance  : .word  0

login_prompt: .asciiz "\nProvide the username : "
paswd_prompt: .asciiz "\nProvide the password : "
loginerror_prompt: .asciiz "\nInvalid crendentials. Please retry."

welcome_prompt: .asciiz "\n\nHello "
action_prompt: .asciiz "\n  1. Check your balance\n  2. Deposit Money\n  3. Withdraw Money\n  4. Logout\n  5. Exit\nSelect menu option : "
balance_prompt: .asciiz "\nYour current balance is $"
withdraw_prompt: .asciiz "\nEnter the amount to withdraw : "
insufficient_prompt: .asciiz "\nYou dont have suffucient balance."
deposit_prompt: .asciiz "\nEnter the amount to deposit : "
logout_prompt: .asciiz "\nSuccessfully logged out."
action_invalid: .asciiz "\nUnknown input provided. Valid inputs are 1-5."

.text
main:
login:	
	la   $a0, login_prompt     	# load address of prompt for syscall
	li   $v0, 4           		# specify Print String service
	syscall               		# print the prompt string
	la   $a0, strinput1     	# load address of input buffer for syscall
	li   $a1, 16          		# Maximum number of the length of read string service
	li   $v0, 8           		# specify read string service
	syscall               		# Read the string.
	la   $a0, paswd_prompt     	# load address of prompt for syscall
	li   $v0, 4           		# specify Print String service
	syscall               		# print the prompt string
	la   $a0, strinput2     	# load address of input buffer for syscall
	li   $a1, 16          		# Maximum number of the length of read string service
	li   $v0, 8           		# specify read string service
	syscall   					# Read the string.
	
	la   $a0, username     		# load address of the username
	la   $a1, strinput1    		# load address of input buffer for username 
	jal StringCompare
	bne  $v0, 0 , login_incorrect
	
	la   $a0, password     		# load address of the password
	la   $a1, strinput2  		# load address of input buffer for password 
	jal StringCompare
	bne  $v0, 0 , login_incorrect
	
	j account
	
	login_incorrect:	
		la   $a0, loginerror_prompt # load address of prompt for syscall
		li   $v0, 4           		# specify Print String service
		syscall               		# print the prompt string
		j login

account:		
	la   $a0, welcome_prompt    # load address of prompt for syscall
	li   $v0, 4           		# specify Print String service
	syscall               		# print the prompt string
	
	la   $a0, username     		# load address of prompt for syscall
	li   $v0, 4           		# specify Print String service
	syscall               		# print the prompt string
	
	la   $a0, action_prompt     # load address of prompt for syscall
	li   $v0, 4           		# specify Print String service
	syscall               		# print the prompt string
	
	li   $v0, 5           		# specify Read Integer service
	syscall               		# Read the number. After this instruction, the number read is in $v0.
	
	beq  $v0, 1 , account_balance
	beq  $v0, 2 , account_deposit
	beq  $v0, 3 , account_withdraw
	beq  $v0, 4 , account_logout
	beq  $v0, 5 , exit
	
	la   $a0, action_invalid    # load address of prompt for syscall
	li   $v0, 4           		# specify Print String service
	syscall               		# print the prompt string
	j account
	
account_balance:
	la   $a0, balance_prompt    # load address of prompt for syscall
	li   $v0, 4           		# specify Print String service
	syscall               		# print the prompt string
	la   $t0, balance
	lw   $a0, ($t0)       # load the integer to be printed 
	li   $v0, 1           # specify Print Integer service
	syscall               # print the balance number
	j account
	
account_withdraw:
	la   $a0, withdraw_prompt   # load address of prompt for syscall
	li   $v0, 4           		# specify Print String service
	syscall               		# print the prompt string
	li   $v0, 5           		# specify Read Integer service
	syscall               		# Read the number. After this instruction, the number read is in $v0.
	la   $t0, balance
	lw   $t1, ($t0)
	sub  $t1, $t1, $v0
	blt $t1, 0, withdraw_insufficient
	sw   $t1, ($t0)	
	j account_balance
	withdraw_insufficient:
		la   $a0, insufficient_prompt   # load address of prompt for syscall
		li   $v0, 4           			# specify Print String service
		syscall               			# print the prompt string
		j account_balance
		
	
account_deposit:
	la   $a0, deposit_prompt   # load address of prompt for syscall
	li   $v0, 4           		# specify Print String service
	syscall               		# print the prompt string
	li   $v0, 5           		# specify Read Integer service
	syscall               		# Read the number. After this instruction, the number read is in $v0.
	la   $t0, balance
	lw   $t1, ($t0)
	add  $t1, $t1, $v0
	sw   $t1, ($t0)	
	j account_balance
	
account_logout:
	la   $a0, logout_prompt   	# load address of prompt for syscall
	li   $v0, 4           		# specify Print String service
	syscall               		# print the prompt string
	j login

exit:
	# The program is finished. Exit.
	li   $v0, 10          # system call for exit
	syscall               # Exit!
		
###############################################################
# Subroutines

StringCompare: 
	#a0 is the stored string address
	#a1 is the constant string address
	#return : $v0=0 means equal, nonzero unequal
	compareloop: 
		lb $t0, ($a0) 						# $t0 = ASCII of the character of first string
		lb $t1, ($a1) 						# $t1 = ASCII of the character of second string
		beq  $t0, 0, compareloop_done 	#If character is '\0'
		addi $a0, $a0, 1
		addi $a1, $a1, 1
		beq  $t0, $t1, compareloop 		#If character is  equal
	compareloop_exit:
		li $v0,1				 		# return 1
		jr   $ra              	 		# return from subroutine
	compareloop_done:		
		bne  $t1, 10, compareloop_exit 	#If character is not '\n'
		li $v0,0	             		# return 0
		jr   $ra              	 		# return from subroutine
		
# End of subroutines
###############################################################

