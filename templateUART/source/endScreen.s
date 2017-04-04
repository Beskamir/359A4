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
	bleq _f_drawLose
	blne _f_drawWin
	bl f_refreshScreen		//refresh the screen


	ldr r4, =0x3F003004 //address of CLO
	ldr r5, [r4]		//read CLO
	ldr r5, =5000			//add micros to wait

	waitLoop:
		ldr	r6, [r4]	//load CLO value to r6
		cmp r5, r6 		//stop when CLO = r5
		bhi waitLoop	//loop back otherwise


	pop		{r4-r10, pc}		//Return all the previous registers
	
	
//Input: Null	
//Output: Null
//Effect: Draws the win label
_f_drawLose:
	push	{lr}	//only need to push lr
	
	ldr r0, =0x0
	bl f_colourScreen
	bl f_refreshScreen	//refresh the screen
	
	//draw the main menu logo. (contains title and names)
	ldr r0, =GameLostLabel
	ldr r1, =290
	mov r2, #116
	mov r3, #1
	bl f_drawElement

	pop		{pc}	//return by popping pc

//Input: Null	
//Output: Null
//Effect: Draws the win label
_f_drawWin:
	push	{lr}	//only need to push lr

	//draw the main menu logo. (contains title and names)
	ldr r0, =GameWonLabel
	ldr r1, =290
	mov r2, #116
	mov r3, #1
	bl f_drawElement

	pop		{pc}	//return by popping pc
