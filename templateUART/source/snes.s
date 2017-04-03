///SNES driver, based on Assignment 3
//use of tabs/formatting to indicate loops.

.section    .init
// .global     _start

//Input: null
//Output: null
//Effect: Initiate GPIO connection
.globl init_GPIO

//Input: null
//Output: new buttons pressed in r0, left and right joystick buttons always returned as pressed if they are pressed on the controller
//Effect: none
//Usage: ALWAYS call init_GPIO first
.globl	Read_SNES
.globl	f_playInput
//.globl	previousButtons

    
.section .text

//Input: null
//Output: Newly pressed buttons pressed in r0; left and right joystick buttons always returned as pressed if they are pressed on the controller even if they were pressed before
//Effect: Writes raw input to previousButtons
//Usage: Make sure that init_GPIO has been called before using
// snes:
	// push {r4-r10, lr}			//Push all the registers we might want to rewrite onto the stack

	// ldr		r7, =previousButtons	//Load the address of the previously pressed buttons into r7
	// ldrh	r4, [r7]				//Load the previously pressed buttons into r7
	// //r4 previous register
	// //r5 current register
	// //r6 register containing info of which button states changed from the last press
	
	// ldr r4, =0xFFFF	//set r4 to 16 one's
	// mov r8, r4		//left half of registers is ones

	// bl Read_SNES	//branch to read snes
	// mov r5, r0		//store read_snes output in r5
	// eor r9, r8		//negate r4 bottom 16 bits
	// orr r6, r5, r9	//newly pressed buttons stored in r6
	
	// //Special case: If left or right on D-pad being held, they should still be counted as pressed!
	// mov r10, #0x40			//r10 = ... 0000 0100 0000
	// tst	r4, r10				//Check what the value of joy pad left was previously
	// biceq r6, r10			//If it's pressed, turn the 1 in r6 in that position into a 0 
	// //Now check for right
	// mov r10, #0x80			//r10 = ... 0000 1000 0000
	// tst	r4, r10				//Check what the value of joy pad right was previous
	// biceq r6, r10			//If it's pressed, turn the 1 in r6 in that position into a 0 
	
	
	// strh	r5, [r7]		//Store the buttons that were just pressed into previousButtons
	
	// mov r0, #10
	// bl Wait	
	
	// mov	r0, r6				//Prepare to return output
	
	// pop {r4-r10, pc}	//Pop the previous registers from the stack

//Input: Null
//Ouput: Null
//Effect: Handle all input from the player
f_playInput:

	push	{r4-r10, lr}	//Push registers to the stack
	
	bl		Read_SNES		//Read input from the player
	mov		r4, r0			//Store the input in r5
	
	//Check if pause menu activated
	
	mov		r5, #1			//Move 1 into r5
	lsl		r5, #3			//Shift to bit 3 (Start)
	tst		r4, r5			//AND the two registers and set flags accordingly
	bne		noPause			//If Start was not pressed, handle the result of the input
	bl		f_pauseMenu		//If Start was pressed, activate the start menu
	b		end_playInput	//After running the pause menu, don't handle any more input until the next play loop
	
	noPause:
	//Check if up was pressed to jump
	//r7 will store whether to jump or not
	mov		r5, #1			//Move 1 into r5
	lsl		r5, #4			//Shift to bit 4 (Joy-pad UP)
	tst		r4, r5			//AND the two registers and set flags accordingly
	moveq	r7, #1			//If Joy-pad UP was pressed, jump!
	movne	r7, #0			//If Joy-pad UP was not pressed, don't jump
	
	//Check if left or right were pressed to move Mario
	mov		r6, #0			//r6 will store the move offset
	mov		r5, #1			//Move 1 into r5
	lsl		r5, #6			//Shift to bit 6 (Joy-pad LEFT)
	tst		r4, r5			//AND the two registers and set flags accordingly
	subeq	r6, #1			//If left was pressed, sub 1 from the move offset
	lsl		r5, #1			//Shift to bit 7 (Joy-pad RIGHT)
	tst		r4, r5			//AND the two registers and set flags accordingly
	addeq	r6, #1			//If right was pressed, add 1 to the move offset

	//Move Mario
	mov		r0, r6			//Move the X offset into r0
	mov		r1, r7			//Move whether to jump into r1
	bl		f_moveMario		//Move Mario
	
	end_playInput:
	
	pop		{r4-r10, pc}	//Pop register from the stack and return

//Input: Nothing
//Return: Nothing
//Effect: Initialize pins
init_GPIO:
	push	{r4-r10, lr}	//Push registers onto the stack
	
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

	
	pop		{r4-r10, pc}	//Load previous registers from the stack

//Writes Latch
//input: what will be written. (1 or 0)
//return: null
//effect: pin 9 set to input.
Write_Latch:
	push {r4-r10, lr} //Push registers onto the stack

	ldr r4, =0x3F200000	//Base GPIO reg
	mov r5, #1			//value to be written
	lsl r5, #9			//align bit for pin #9
	teq r0, #0			//check what should be written where
	streq r5, [r4, #40]	//GPCLR0 (0x28) writes 0 if input was a 0
	strne r5, [r4, #28]	//GPSET0 (0x1C) writes 1 if input was a 1

	pop	{r4-r10, pc}	//Load the original registers from the stack

//Writes Clock
//input: what will be written. (1 or 0)
//return: null
//effect: pin 11 set to input.
Write_Clock:
	push {r4-r10, lr}	//Push registers onto the stack

	ldr r4, =0x3F200000	//Base GPIO reg
	mov r5, #1			//value to be written
	lsl r5, #11			//align bit for pin #11
	teq r0, #0			//check what should be written where
	streq r5, [r4, #40]	//GPCLR0 (0x28) writes 0 if input was a 0
	strne r5, [r4, #28]	//GPSET0 (0x1C) writes 1 if input was a 1

	pop	{r4-r10, pc}	//Load the original registers from the stack

//Input: Nothing
//Return: Data bit in r0
//Effect: None 
Read_Data:
	push	{r4-r10, lr}		//Push registers onto the stack

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

	pop		{r4-r10, pc}		//Load previous registers from the stack

//input: number of micros to wait
//return: null
//output: wait for at least 12 micros
Wait:
	push	{r4-r10, lr}	//Push registers onto the stack

	ldr r4, =0x3F003004 //address of CLO
	ldr r5, [r4]		//read CLO
	add r5, r0			//add micros to wait

	waitLoop:
		ldr	r6, [r4]	//load CLO value to r6
		cmp r5, r6 		//stop when CLO = r5
		bhi waitLoop	//loop back otherwise

	pop		{r4-r10, pc}	//Load the original registers from the stack

//Input: Nothing
//Return: Which buttons were pressed in r0, in order, bits with 0 are pressed
//Effect: Nothing
Read_SNES:
	push	{r4-r10, lr}	//Push registers onto the stack

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

	pop		{r4-r10, pc}	//Load previous registers from the stack


.section .data  

// previousButtons: .hword