//This file handles the pause menu

.section	.init

.globl	f_pauseMenu								//Menu is the only public function in this file
.globl	d_isPaused								//Public boolean whether game is paused or not

.section	.text

//input: null
//return: null
//effect: Runs the menu. 
//		if quit game chosen then set quiteGame
f_pauseMenu:
	//r4 = Menu state
	//r5 = SNES output
	//r6 = SNES A mask
	//r7 = SNES joy-pad UP mask
	//r8 = SNES joy-pad DOWN mask
	//r9 = SNES Start mask
	//r10 = Has the Start button been released?
	
	push	{r4-r10, lr}			//Push all the general purpose registers along with fp and lr to the stack
	
	ldr		r4, =d_isPaused			//Load the paused boolean register
	mov		r5, #1					//r5 = 1
	str		r5, [r4]				//isPaused = 1
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
	mov		r9, #1					//Move 1 into r9
	lsl		r9, #3					//Shift to bit 3 (Start)
	bl		Read_SNES				//Get input from the SNES
	mov		r5, r0					//Move the input into r5
	b	selectionLoopTest
		
		SLtop:						//Top of the loop
		
		bl		Read_SNES			//Read input
		mov		r5, r0				//Move the output into r5
		
		checkStart:
		tst		r5, r9				//Check if Start was pressed
		//If Start wasn't pressed
		movne	r10, #1				//If it wasn't, indicate Start button was released
		bne		checkUp				//and then go to checkUp
		//If Start was pressed
		tsteq	r10, #0				//Check if r10 is clear
		mov		r4, #2				//If it's isn't, set the state to resume the game
		bne		selectionLoopEnd	//If it isn't, instantly end the loop
		
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
		tst		r5, r6				//AND the input with r6 
		bne		SLtop				//If A hasn't been pressed, move back into the loop
	
	selectionLoopEnd:				//Branched to if Start is pressed
	// mov		r0, r4					//Return the menu state
	ldr 	r1, =d_quitGame
	str 	r4, [r1]

	ldr		r4, =d_isPaused			//Load the paused boolean register
	mov		r5, #0					//r5 = 0
	str		r5, [r4]				//isPaused = 0
	
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
		//draw selected restart option
		ldr r0, =t_PauseRestartSelected
		mov r1, #440
		ldr r2, =350
		mov r3, #1
		bl f_drawElement

		//draw regular quit option
		ldr r0, =t_PauseQuitNormal
		mov r1, #440
		mov r2, #400
		mov r3, #1
		bl f_drawElement

		b _drawSelectionEnd

	_drawSelectionQuit:
		//draw regular restart option
		ldr r0, =t_PauseRestartNormal
		mov r1, #440
		ldr r2, =350
		mov r3, #1
		bl f_drawElement

		//draw selected quit option
		ldr r0, =t_PauseQuitSelected
		mov r1, #440
		mov r2, #400
		mov r3, #1
		bl f_drawElement

	_drawSelectionEnd:
	bl	f_refreshScreen
	
	
	pop		{pc}	//Return to caller popping pc


//Input: Null	
//Output: Null
//Effect: Draws the main background, author names and menu buttons
_f_drawMenu:
	push	{lr}	//only need to push lr
	
	//draw the pause menu logo. (contains title and names)
	ldr r0, =t_PauseMenuLogo
	mov r1, #180
	mov r2, #105
	mov r3, #1
	bl f_drawElement	

	pop		{pc}	//return by popping pc
	
	
.section	.data

d_isPaused:	.byte
