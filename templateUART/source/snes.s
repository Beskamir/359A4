///SNES driver, based on Assignment 3
//use of tabs/formatting to indicate loops.

.section    .init
// .global     _start
.global	snes

    
.section .text

// main:
snes:
    mov		sp, #0x8000 // Initializing the stack pointer
	bl		EnableJTAG 	// Enable JTAG
	bl		InitUART 	//This is important to be  able to use UART
	

	//r4 previous register
	//r5 current register
	//r6 register containing info of which button states changed from the last press
	ldr r4, =0xFFFF	//set r4 to 16 one's
	mov r8, r4			//all ones
	mainLoop:
		buttonListen:	

				bl Read_SNES	//branch to read snes
				mov r5, r0		//store read_snes output in r5
				eor r9, r8		//negate r4
				orr r6, r5, r9	//newly pressed buttons stored in r6
				
				//Special case: If left or right on D-pad being held, they should still be counted as pressed!
				mov r10, #0x40			//r10 = ... 0000 0100 0000
				tst	r4, r10				//Check what the value of joy pad left is
				biceq r6, r10			//If it's pressed, turn the 1 in r6 in that position into a 0 
				//Now check for right
				mov r10, #0x80			//r10 = ... 0000 1000 0000
				tst	r4, r10				//Check what the value of joy pad right is
				biceq r6, r10			//If it's pressed, turn the 1 in r6 in that position into a 0 
				
				
				ldr r7, =0xFFFF

				mov r0, #10
				bl Wait

				teq r6, r7 //check if user pressed a button
				mov r4, r5
			beq buttonListen //Loop back if user didn't press any buttons

			mov r0, r6
			//branch to function which determines which buttons were pressed
			// and then prints them
			bl printButtons 

			//Print a new line
			ldr r0, =newLine
			mov r1, #2
			bl Print_Message

			//mov r4, r5

			mov r0, #10
			bl Wait	

		b mainLoop	//loop back to mainLoop for the next button press.


	//Otherwise, program ends
	endProgram:
	ldr r0, =exitMessage	//address to the label containing the object prompts
	mov r1, #29				//Number of characters to print
	bl Print_Message 		//Writes to console
	b haltLoop$

haltLoop$:	//Halts the program
	b	haltLoop$	//infinite loop


//Input: Nothing
//Return: Nothing
//Effect: Initialize pins
init_GPIO:
	push	{r4-r10, fp, lr}		//Push registers onto the stack
	
	//Set pin 11 to output and pin 10 to input
	ldr		r4, =0x3F200004		//Load GPFSEL1 address into r4
	ldr		r5, [r4]			//Load GPFSEL1 into r5
	mov		r6, #7				//r6 = ... 000 000 111
	lsl		r6, #3				//r6 = ... 000 111 000
	add		r6, #7				//r6 = ... 000 111 111
	bic		r5, r6				//Clear the pin 11 and set pin 10 bits to output by clearing them
	mov		r6, #1				//r6 = ... 000 000 001
	lsl		r6, #3				//r6 = ... 000 001 000
	orr		r5, r6				//Set pin 11 bits to ouput and don't change pin 10 bits so they stay input
	str		r5, [r4]			//Store GPFSEL1

	//Set pin 9 to output
	ldr		r4, =0x3F200000		//Load GPFSEL0 address into r4
	ldr		r5, [r4]			//Load GPFSEL0 into r5
	mov		r6, #7				//r6 = ... 000 000 111
	lsl		r6, #27				//r6 = 00 111 000...
	bic		r5, r6				//Clear the bits for pin 9
	mov		r6, #1				//r6 = ... 000 000 001
	lsl		r6, #27				//r6 = 00 001 ...
	orr		r5, r6				//Set pin 9 bits to ouput
	str		r5, [r4]			//Store GPFSEL0


	pop		{r4-r10, fp, lr}	//Load previous registers from the stack
	bx 		lr					//Return

//Writes Latch
//input: what will be written. (1 or 0)
//return: null
//effect: pin 9 set to input.
Write_Latch:
	push {r4-r10, fp, lr} //Push registers onto the stack

	ldr r4, =0x3F200000	//Base GPIO reg
	mov r5, #1			//value to be written
	lsl r5, #9			//align bit for pin #9
	teq r0, #0			//check what should be written where
	streq r5, [r4, #40]	//GPCLR0 (0x28) writes 0 if input was a 0
	strne r5, [r4, #28]	//GPSET0 (0x1C) writes 1 if input was a 1

	pop	{r4-r10, fp, lr}	//Load the original registers from the stack
	bx 		lr					//Return

//Writes Clock
//input: what will be written. (1 or 0)
//return: null
//effect: pin 11 set to input.
Write_Clock:
	push {r4-r10, fp, lr}	//Push registers onto the stack

	ldr r4, =0x3F200000	//Base GPIO reg
	mov r5, #1			//value to be written
	lsl r5, #11			//align bit for pin #11
	teq r0, #0			//check what should be written where
	streq r5, [r4, #40]	//GPCLR0 (0x28) writes 0 if input was a 0
	strne r5, [r4, #28]	//GPSET0 (0x1C) writes 1 if input was a 1

	pop	{r4-r10, fp, lr}	//Load the original registers from the stack
	bx 		lr					//Return

//Input: Nothing
//Return: Data bit in r0
//Effect: None 
Read_Data:
	push	{r4-r10, fp, lr}	//Push registers onto the stack

	ldr		r4, =0x3F200034		//Load the base address into r4
	ldr		r5, [r4]			//Load GPLEV0 into r5
	mov		r6, #1				//r6 = ... 000 001
	lsl		r6, #10				//put 1 in the 10th bit
	and		r5, r6				//Mask all the bits except the 10th bit of GPLEV0
	teq		r5, #0				//Compare r5 to 0
	movne	r0, #1				//If they aren't equal, return 1
	moveq	r0, #0				//If they're equal, return 0

	///Appears that nomatter what 0 is being returned...
	//likely due to gpio not being initialized well?
	// mov 	r0, #1	//TEMP! DEBUGGING!

	pop		{r4-r10, fp, lr}	//Load previous registers from the stack
	bx 		lr					//Return

//input: number of micros to wait
//return: null
//output: wait for at least 12 micros
Wait:
	push	{r4-r10, fp, lr}	//Push registers onto the stack

	ldr r4, =0x3F003004 //address of CLO
	ldr r5, [r4]		//read CLO
	add r5, r0			//add micros to wait

	waitLoop:
		ldr	r6, [r4]	//load CLO value to r6
		cmp r5, r6 		//stop when CLO = r5
		bhi waitLoop	//loop back otherwise

	pop		{r4-r10, fp, lr}	//Load the original registers from the stack
	bx 		lr					//Return

//Input: Nothing
//Return: Which buttons were pressed in r0, in order, bits with 0 are pressed
//Effect: Nothing
Read_SNES:
	push	{r4-r10, fp, lr}	//Push registers onto the stack

	//Initiate read
	mov		r0, #1				//Write 1 to latch
	bl		Write_Clock			//Call Write_Clock
	mov		r0, #1				//Write 1 to clock
	bl		Write_Latch			//Call Write_Latch
	mov		r0, #12				//Wait at least 12 microseconds
	bl		Wait				//Call Wait
	mov		r0, #0				//Write 0 to latch
	bl		Write_Latch			//Call Write_Latch

	mov		r4, #0				//The loop counter
	mov		r5, #0				//The button register
	b		RLtest				//Branch to the loop test

	//Loop to read the buttons pressed
	Read_Loop:

	mov		r0, #6				//Wait 6 microseconds
	bl		Wait				//Call Wait

	mov		r0, #0				//Write 0 to clock
	bl		Write_Clock			//Call Write_Clock

	mov		r0, #6				//Wait 6 microseconds
	bl		Wait				//Call Wait
	
	bl		Read_Data			//Read data bit from the SNES
	mov		r6, r0				//Store the data bit in r6
	lsl		r6, r4				//Shift the bit up by the number of buttons processed before
	add		r5, r6				//Add the bit to the button register

	mov		r0, #1				//Write 1 to clock
	bl		Write_Clock			//Call Write_Clock

	add		r4, #1				//Increment loop counter
	RLtest:
	cmp		r4, #16				//Compare the loop counter to the number of buttons
	blt		Read_Loop			//If less loops have occured than there are buttons, loop again

	mov		r0, r5				//Return the button register

	pop		{r4-r10, fp, lr}	//Load previous registers from the stack
	bx 		lr					//Return

//Input: Register of buttons pressed in r0
//Return: prints the buttons pressed to the screen, followed by new lines
//Effects: Nothing
printButtons:
	push	{r4-r10, fp, lr}	//Push registers onto the stack

	ldr 	r9, =0xFFFF

	mov		r4, r0				//Move the button data into r4
	eor		r4,	r9				//For easier comparisons, flip the bits in button data so 1 is on and 0 is off
	mov		r5, #1				//Put 1 in r5

	teq		r4, r5				//See if Y was pressed
	ldreq	r0, =button1		//If it was, get ready print Y
	mov 	r1, #2				//Number of characters to print
	bleq	Print_Message		//Print the button

	lsl		r5, #1				//Move over the 1 to the next button
	teq		r4, r5				//See if B was pressed
	ldreq	r0, =button2		//If it was, get ready print B
	mov 	r1, #2				//Number of characters to print
	bleq	Print_Message		//Print the button

	lsl		r5, #1				//Move over the 1 to the next button
	teq		r4, r5				//See if Select was pressed
	ldreq	r0, =button3		//If it was, get ready print Select
	mov 	r1, #7				//Number of characters to print
	bleq	Print_Message		//Print the button

	lsl		r5, #2				//Move over the 2 to the next button because we won't print Start
	teq		r4, r5				//See if Joy-pad UP was pressed
	ldreq	r0, =button5		//If it was, get ready print Joy-pad UP
	mov 	r1, #11				//Number of characters to print
	bleq	Print_Message		//Print the button

	lsl		r5, #1				//Move over the 1 to the next button
	teq		r4, r5				//See if Joy-pad DOWN was pressed
	ldreq	r0, =button6		//If it was, get ready print Joy-pad DOWN
	mov 	r1, #13				//Number of characters to print
	bleq	Print_Message		//Print the button

	lsl		r5, #1				//Move over the 1 to the next button
	teq		r4, r5				//See if Joy-pad LEFT was pressed
	ldreq	r0, =button7		//If it was, get ready print Joy-pad LEFT
	mov 	r1, #13				//Number of characters to print
	bleq	Print_Message		//Print the button

	lsl		r5, #1				//Move over the 1 to the next button
	teq		r4, r5				//See if Joy-pad RIGHT was pressed
	ldreq	r0, =button8		//If it was, get ready print Joy-pad RIGHT
	mov 	r1, #14				//Number of characters to print
	bleq	Print_Message		//Print the button

	lsl		r5, #1				//Move over the 1 to the next button
	teq		r4, r5				//See if A was pressed
	ldreq	r0, =button9		//If it was, get ready print A
	mov 	r1, #2				//Number of characters to print
	bleq	Print_Message		//Print the button

	lsl		r5, #1				//Move over the 1 to the next button
	teq		r4, r5				//See if X was pressed
	ldreq	r0, =button10		//If it was, get ready print X
	mov 	r1, #2				//Number of characters to print
	bleq	Print_Message		//Print the button

	lsl		r5, #1				//Move over the 1 to the next button
	teq		r4, r5				//See if Left was pressed
	ldreq	r0, =button11		//If it was, get ready print Left
	mov 	r1, #5				//Number of characters to print
	bleq	Print_Message		//Print the button

	lsl		r5, #1				//Move over the 1 to the next button
	teq		r4, r5				//See if Right was pressed
	ldreq	r0, =button12		//If it was, get ready print Right
	mov 	r1, #6				//Number of characters to print
	bleq	Print_Message		//Print the button

	pop		{r4-r10, fp, lr}	//Load previous registers from the stack
	bx 		lr					//Return

.section .data  


// //location where the user input will be stored in
// Buffer:
// 	.rept 256
// 	.byte 0
// 	.endr
