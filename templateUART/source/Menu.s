//This file handles the main menu

.globl Menu								//Menu is the only public function in this file

.section .text

//input: null
//return: r0 - 0 if user wants to quit, 1 if user wants to start the game
//effect: Runs the menu
Menu:
	push	{r4-r12, fp, lr}			//Push all the general purpose registers along with fp and lr to the stack
	
	bl		drawMenu					//Draw the menu
	
	mov		r4, #1						//By default, hover over "Start Game"
	
	mov		r0, r4						//Move current selection into r0
	bl		drawSelection				//Draw the selection box
	
	selectionLoop:						//This loop changes input
		//r4 = newly pressed buttons
		//r5 = address of previousButtons
		//r6 = previousButtons
		bl		snes					//Call snes
		mov		r4, r0					//Move the pressed button register into r4
		ldr		r5, =previousButtons	//Load previous buttons address from snes
		ldrh	r6, [r5]				//Load previous buttons
		and		r4,r6
	
	
	pop		{r4-r12, fp, lr}			//Return all the previous registers
	mov		pc, lr						//Return
	
	
//Input: Menu state in r0 (0 for quit game hover, 1 for start game hover)
//Output: Null
//Effect: Draw the selection box around the appropriate button
drawSelection:
	push	{r4-r12, fp, lr}			//Push all the general purpose registers along with fp and lr to the stack
	
	//Put code in here
	
	pop		{r4-r12, fp, lr}			//Return all the previous registers
	mov		pc, lr						//Return


//Input: Null	
//Output: Null
//Effect: Draws the main background, author names and menu buttons
drawMenu:
	push	{r4-r12, fp, lr}			//Push all the general purpose registers along with fp and lr to the stack
	
	//Put code in here
	
	pop		{r4-r12, fp, lr}			//Return all the previous registers
	mov		pc, lr						//Return