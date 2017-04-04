//This file handles the end screen

.globl f_endScreen		//end screen is the only public function in this file

.section .text

//input: r0, either 1 or 0 depending on win or lose
//	1 = win
//	0 = lose
//return: null
//effect: Runs the menu
f_endScreen:
	push	{r4-r10, lr}			//Push all the general purpose registers along with fp and lr to the stack

	cmp r0, #0
	beq _f_drawLose
	bne _f_drawWin
	bl f_refreshScreen		//refresh the screen

	mov		r6, #1			//Move 1 into r6
	lsl		r6, #8			//Shift that 1 to bit 8 (A)
	
	b	_checkInput
	
	_displayLabel:						//Top of the loop
		
			bl		Read_SNES			//Read input
			mov		r5, r0				//Move the output into r5
				
		_checkInput:
			tst		r5, r6				//AND the input with r5 
			bne		_displayLabel				//If A hasn't been pressed, move back into the loop


	pop		{r4-r10, pc}		//Return all the previous registers
	
	
//Input: Null	
//Output: Null
//Effect: Draws the win label
_f_drawLose:
	push	{lr}	//only need to push lr
	
	//draw the main menu logo. (contains title and names)
	ldr r0, =GameLostLabel
	mov r1, #145
	mov r2, #116
	mov r3, #1
	bl f_drawElement

	pop		{pc}	//return by popping pc

//Input: Null	
//Output: Null
//Effect: Draws the win label
_f_drawWin:
	push	{lr}	//only need to push lr

	ldr r0, =0x0
	bl f_colourScreen
	bl f_refreshScreen	//refresh the screen
	
	//draw the main menu logo. (contains title and names)
	ldr r0, =GameWonLabel
	mov r1, #145
	mov r2, #116
	mov r3, #1
	bl f_drawElement

	pop		{pc}	//return by popping pc
