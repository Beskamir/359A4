//This file handles the main menu

.globl Menu					//Menu is the only public function in this file

.section .text

//input: null
//return: r0 - 0 if user wants to quit, 1 if user wants to start the game
//effect: Runs the menu
Menu:
	push	{r4-r12, fp, lr}			//Push all the general purpose registers along with fp and lr to the stack
	
	
	pop		{r4-r12, fp, lr}			//Return all the previous registers
	mov		pc, lr						//Return