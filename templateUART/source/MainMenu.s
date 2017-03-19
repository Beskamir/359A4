//This file handles the main menu

.globl mainMenu								//Menu is the only public function in this file

.section .text

//input: null
//return: r0 - 0 if user wants to quit, 1 if user wants to start the game
//effect: Runs the menu
MainMenu:
	//r4 = menu state
	//r5 = snes output
	//r6 = SNES A mask
	//r7 = SNES joy-pad UP mask
	//r8 = SNES joy-pad DOWN mask
	
	push	{r4-r12, fp, lr}		//Push all the general purpose registers along with fp and lr to the stack
	
	bl		drawMenu				//Draw the menu
	
	mov		r4, #1					//By default, hover over "Start Game"
	
	mov		r0, r4					//Move current selection into r0
	bl		drawSelection			//Draw the selection box
	
	selectionLoop:					//This loop changes input
	mov		r6, #1					//Move 1 into r6
	lsl		r6, #9					//Shift that 1 to bit 9 (A)
	mov		r7, #1					//Move 1 into r7
	lsl		r7, #5					//Shift to bit 5 (joy-pad UP)
	mov		r8, #1					//Move 1 into r8
	lsl		r8, #6					//Shift to bit 6 (joy-pad DOWN)
	bl		snes					//Get input from the SNES
	mov		r8, r0					//Move the input into r5
	b	selectionLoopTest
		
		top:						//Top of the loop
		
		bl		snes				//Call snes
		mov		r5, r0				//Move the output into r5
		
		checkUp:					//
		tst		r5, r7				//Check if joy-pad UP was pressed
		bne		checkDown			//If it wasn't, go to checkDown
		cmp		r4, #1				//Check if the game is in state 1
		beq		checkDown			//If it is, go to checkDown
		mov		r4, #1				//If it isn't, change the state to state 1
		mov		r0, r4				//Move the selection box to state 1
		bl		drawSelection		//Call drawSelection
		b		selectionLoopTest	//Since the state was switched, no need to switch it again
		
		checkDown:
		tst		r5, r8				//Check if joy-pad DOWN was pressed
		bne		selectionLoopTest	//If it wasn't, go to selectionLoopTest
		cmp		r4, #0				//Check if the game is in state 0
		beq		selectionLoopTest	//If it is, go to selectionLoopTest
		mov		r4, #0				//If it isn't, change the state to state 0
		mov		r0, r4				//Move the selection box to state 0
		bl		drawSelection		//Call drawSelection
		
		selectionLoopTest:
		tst		r5, r6				//AND the input with r5 
		bne		selectionLoop		//If A hasn't been pressed, move back into the loop
	
	mov		r0, r4					//Return the menu state
	
	pop		{r4-r12, fp, lr}		//Return all the previous registers
	mov		pc, lr					//Return
	
	
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