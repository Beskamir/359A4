//This file handles the main menu

.globl f_mainMenu								//Menu is the only public function in this file

.section .text

//input: null
//return: r0 - 0 if user wants to quit, 1 if user wants to start the game
//effect: Runs the menu
f_mainMenu:
	//r4 = menu state
	//r5 = SNES output
	//r6 = SNES A mask
	//r7 = SNES joy-pad UP mask
	//r8 = SNES joy-pad DOWN mask
	
	push	{r4-r10, lr}			//Push all the general purpose registers along with fp and lr to the stack
	
	bl		_f_drawMenu				//Draw the menu
	
	mov		r4, #1					//By default, hover over "Start Game"
	
	mov		r0, r4					//Move current selection into r0
	bl		_f_drawSelection		//Draw the selection box
	
	selectionLoop:					//This loop changes input
	mov		r6, #1					//Move 1 into r6
	lsl		r6, #8					//Shift that 1 to bit 8 (A)
	mov		r7, #1					//Move 1 into r7
	lsl		r7, #4					//Shift to bit 4 (joy-pad UP)
	mov		r8, #1					//Move 1 into r8
	lsl		r8, #5					//Shift to bit 5 (joy-pad DOWN)
	bl		Read_SNES				//Get input from the SNES
	mov		r5, r0					//Move the input into r5
	b	selectionLoopTest
		
		SLtop:						//Top of the loop
		
		bl		Read_SNES			//Read input
		mov		r5, r0				//Move the output into r5
		
		checkUp:
		tst		r5, r7				//Check if joy-pad UP was pressed
		bne		checkDown			//If it wasn't, go to checkDown
		cmp		r4, #1				//Check if the game is in state 1
		beq		checkDown			//If it is, go to checkDown
		mov		r4, #1				//If it isn't, change the state to state 1
		mov		r0, r4				//Move the selection box to state 1
		bl		_f_drawSelection	//Call drawSelection
		b		selectionLoopTest	//Since the state was switched, no need to switch it again
		
		checkDown:
		tst		r5, r8				//Check if joy-pad DOWN was pressed
		bne		selectionLoopTest	//If it wasn't, go to selectionLoopTest
		cmp		r4, #0				//Check if the game is in state 0
		beq		selectionLoopTest	//If it is, go to selectionLoopTest
		mov		r4, #0				//If it isn't, change the state to state 0
		mov		r0, r4				//Move the selection box to state 0
		bl		_f_drawSelection	//Call drawSelection
		
		selectionLoopTest:
		bl	 	f_refreshScreen		//refresh the screen
		tst		r5, r6				//AND the input with r5 
		bne		SLtop				//If A hasn't been pressed, move back into the loop
	
	mov		r0, r4					//Return the menu state
	
	pop		{r4-r10, pc}		//Return all the previous registers
	
	
//Input: Menu state in r0 (0 for quit game hover, 1 for start game hover)
//Output: Null
//Effect: Draw the selection box around the appropriate button
	//Currently displaying:
	//start game at: x = 412, y = 384
	//quit game at: x = 412, y = 438
_f_drawSelection:
	push	{lr}	//Push lr to the stack
	
	cmp r0, #0
	beq _drawSelectionQuit
		//draw selected start option
		ldr r0, =t_StartSelect
		mov r1, #412
		mov r2, #384
		mov r3, #1
		bl f_drawElement

		//draw regular quit option
		ldr r0, =t_QuitNorm
		mov r1, #412
		ldr r2, =438
		mov r3, #1
		bl f_drawElement

		b _drawSelectionEnd



	_drawSelectionQuit:
		//draw regular start option
		ldr r0, =t_StartNorm
		mov r1, #412
		mov r2, #384
		mov r3, #1
		bl f_drawElement

		//draw selected quit option
		ldr r0, =t_QuitSelect
		mov r1, #412
		ldr r2, =438
		mov r3, #1
		bl f_drawElement

	_drawSelectionEnd:
	
	pop		{pc}	//Return to caller popping pc


//Input: Null	
//Output: Null
//Effect: Draws the main background, author names and menu buttons
_f_drawMenu:
	push	{lr}	//only need to push lr
	
	//Draw the initial map
	ldr r0, =0x64FE		//Blueish colour based on an image of the original game.
	bl f_colourScreen	//drawing over the entire screen is sort of inefficent
	
	//draw the sprites located on the background map
	ldr r0, =t_mapBackground
	ldr r1, =t_cameraPosition
	bl f_drawMap

	//draw the sprites located on the middle map
	ldr r0, =t_mapMiddleground
	ldr r1, =t_cameraPosition
	bl f_drawMap

	//draw the sprites located on the foreground map
	ldr r0, =t_mapForeground
	ldr r1, =t_cameraPosition
	bl f_drawMap

	//draw the main menu logo. (contains title and names)
	ldr r0, =t_MainMenuLogo
	mov r1, #162
	mov r2, #65
	mov r3, #1
	bl f_drawElement

	pop		{pc}	//return by popping pc
