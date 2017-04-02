//This file handles Mario stuff, mainly relating to movement

.section		.init

.globl			f_resetMarioPosition		//Reset Mario's position (in registers, not in the map)
.globl			f_moveMarioX				//Move Mario horizontally (in map and registers)
.globl			f_moveMarioY				//Move Mario Vertically

.section		.text

//Input: Null
//Output: Null
//Effect: Reset's Mario's position back to where he starts at the beginning of the game
f_resetMarioPosition:
	push	{r4-r10, lr}					//Push all the general purpose registers along with fp and lr to the stack
	
	//Clear Mario from the map
	ldr		r4, =_d_marioPositionX			//Store the address of Mario's current X position
	ldr		r5, =_d_marioPositionY			//Store the address of Mario's current Y posiion
	ldr		r6, =d_mapForeground			//Load the address of the foreground
	ldrh	r0, [r4]						//Load Mario's current X position
	ldrh	r1, [r5]						//Load Mario's current Y position
	mov		r2, r6				 			//Move in the address of the foreground
	mov		r3, #0							//Load the code for an empty cell
	bl		f_setCellElement				//Replace Mario with an empty cell
	
	//Load Mario's default position values
	ldr		r4, =_t_marioDefaultPositionX	//Store the address of Mario's default X position
	ldr		r5, =_t_marioDefaultPositionY	//Store the address of Mario's default Y posiion
	ldrh	r7, [r4]						//Load Mario's default x position
	ldrh	r8, [r5]						//Load Mario's default y position
	
	//Store Mario's default position values
	ldr		r4, =_d_marioPositionX			//Store the address of Mario's current X position
	ldr		r5, =_d_marioPositionY			//Store the address of Mario's current Y posiion
	strh	r7, [r4]						//Set Mario's X position to the default
	strh	r8, [r5]						//Set Mario's Y position to the default
	
	//Add Mario to his default location on the map
	mov		r0, r7							//Move in Mario's default X position
	mov		r1, r8							//Move in Mario's default Y position
	mov		r2, r6							//Move in the address of the foreground
	mov		r3, #0							//Load the code for an empty cell
	bl		f_setCellElement				//Replace Mario with an empty cell
	
	pop		{r4-r10, pc}					//Return all the previous registers and return
	
	
//Input:
	//r0: -1 to move Mario to the left, 0 to stay, 1 to move Mario to the right
	//r1: 0 for no jump, 1 for jump
//Output: Null
//Effect: Moves Mario in the specified direction	
f_moveMario:
	push	{r4-r10, lr}					//Push all the general purpose registers along with fp and lr to the stack

	//r4 = X offset
	//r5 = Y instruction
	mov		r4, r0							//Save the X offset in a safe register
	mov		r5, r1							//Save the Y instruction in a safe register
	
	bl		shouldMarioMove					//Should we be moving Mario right now?
	tst		r0, #1							//Is the answer yes?
	bne		doneMovingMario					//If not, don't move Mario, just skip to the end
	
	//r6 = X position
	//r7 = Y position
	ldr		r8, =_d_marioPositionX			//Store the address of Mario's X position
	ldrh	r6, [r8]						//Load Mario's X address
	ldr		r8, =_d_marioPositionY			//Store the address of Mario's Y position
	ldrh	r7, [r8]						//Load Mario's Y address
	
	//Y movement
	ldr		r8, =verticalState				//Load the address of the vertical state
	ldrb	r9, [r8]						//Load the value of the vertical state
	cmp		r9, #0							//Compare the vertical state to 0
	bgt		jumping							//If the value is positive, Mario is jumping, so no need to worry about falling
	bl		_f_isMarioOnGround				//Check whether Mario is on the ground or if he should be falling
	cmp		r0, #1							//Is Mario on the ground?
	beq		doneYMovement					//If Mario he is then we're done with vertical movement
	
	//Falling
	sub		r9, #1							//Increase Mario's fall speed by 1
	strb	r9, [r8]						//Store Mario's new fall speed
	//Move Mario in map
	//r9 = Mario's fall speed = loop counter = Number of times Mario is moved down until he hits terrain
	FallMarioTop:							//Top of the loop, r9 is the loop counter as it is Mario's fall speed
		lsl		r0, r6, #16					//Move X position to top half of r0
		orr		r0, r7						//Add Y position to bottom half of r0
		mov		r1, #0						//Don't move Mario horizontally
		mov		r2, #-1						//Move Mario 1 space down
		ldr		r3, =d_mapForeground		//Mario is in the foreground
		bl		f_moveElement				//Move Mario
		mov		r10, r0						//Store result in a safe register
		cmp		r10, #2						//Did the move succeed?
		moveq	FallMarioTest				//If so, go to the test
		cmp		r10, #1						//Did we fail to move due to an enemy?
		bleq	_f_killEnemy				//If so, kill the enemy!
		beq		FallMarioTest				//Then go to the loop test
		//If neither, then we're done falling!
		mov		r9, #0						//Set Mario's vertical speed to 0
		strb	r9, [r8]					//Store Mario's vertical speed
		b		doneYMap					//We're done Y movement
	FallMarioTest:							//Loop test
		sub		r9, #1						//Subtract 1 from the loop counter
		sub		r7, #1						//Subtract 1 from Mario's Y position
		cmp		r9, #0						//Compare the loop counter to 0
		bgt		FallMarioTop				//If r9 is still greater than 0, we need to move Mario down again
	//Move Mario in data register
	doneYMap:
	ldr		r8, =_d_marioPositionY			//Load the address of Mario's Y position
	strh	r7, [r8]						//Store Mario's new Y position
	b		doneYMovement					//We're done moving Mario vertically
	
	//Jumping
	jumping:
	
		//Special case: breaking a block
			//Special special case: hitting a value block
		//Special case: hitting an enemy
	
	
	doneYMovement:
	//X movement
	//Check if Mario should be moved horizontally
	cmp		r4, #0							//Compare X offset to 0
	beq		doneMovingMario					//If they're equal, branch to skip the X movement
	bl		_f_shouldMarioMoveX				//Should Mario be moved right now?
	cmp		r0, #1							//Is the answer yes?
	

	//Move Mario in map
	//Move Mario in data register
	add		r6, r4							//Add the offset to Mario's current X position
	ldr		r8, =_d_marioPositionX			//Load the address of Mario's X position
	strh	r6, [r8]						//Store Mario's new X position
	
		
	doneMovingMario:
	
	pop		{r4-r10, pc}					//Return all the previous registers and return
	
//Input: Null
//Output: r0 - 0 for no, 1 for yes
//Effect: Null
_f_isMarioOnGround:
	push	{r4-r10, lr}					//Push all the general purpose registers along with fp and lr to the stack

	ldr		r4, =_d_marioPositionX			//Load the address of Mario's X position
	ldrh	r0, [r4]						//Load Mario's X position
	ldr		r5, =_d_marioPositionY			//Load the address of Mario's Y position
	ldrh	r1, [r5]						//Load Mario's Y position
	sub		r1, #1							//Subtract 1 from Mario's Y position to check the cell below him
	ldr		r6, =d_mapForeground			//Load the address of the foreground map
	bl		f_getCellElement				//Find out which cell is below Mario
	tst		r0, #0							//Is there empty space beneath Mario?
	moveq	r0, #1							//If yes, move a 1 into r0
	movne	r0, #0							//If not, move a 0 into r0
	
	pop		{r4-r10, pc}					//Return all the previous registers and return
	

//Input: Null	
//Output: r0 - 1 for yes, 0 for no
//Effect: Null
_f_shouldMarioMove:
	push	{r4-r10, lr}					//Push all the general purpose registers along with fp and lr to the stack

	ldr		r4, =_d_lastMoveTick			//Load the address of Mario's X last move time
	ldr		r5, [r4]						//Load Mario last move time

	ldr		r6, =_t_marioMoveDelay			//Load the address for the delay for Mario's movement
	ldr		r7, [r6]						//Load the delay
	add		r5, r7							//Add the delay to the last movement time (for comparison purposes)
	
	bl		f_getClock						//Get the current move time
	mov		r8, r0							//Save it in a safe register
	
	cmp		r8, r5							//Compare the two times
	movgt	r0, #1							//If enough time has passed, return 1
	strgt	r8, [r6]						//If enough time has passed to move Mario, set this as the last move time
	movele	r0, #0							//If enough time hasn't passed, return 0
	
	pop		{r4-r10, pc}					//Return all the previous registers and return
	
	
	
//Input: Null	
//Output: Null
//Effect: Kills an enemy and moves Mario into its place
_f_killEnemy:
	push	{r4-r10, lr}					//Push all the general purpose registers along with fp and lr to the stack
	
	//Code to move enemy to seperate layer and do stuff with them here
	
	//Remove enemy from foreground
	ldr		r4, =_d_marioPositionX			//Load the address of Mario's X position
	ldr		r5, =_d_marioPositionY			//Load the address of Mario's Y position
	ldrh	r0, [r4]						//Load Mario's X position
	ldrh	r1, [r5]						//Load Mario's Y position
	add		r1, #1							//Add 1 to get the enemy's Y position below Mario
	ldr		r2, =d_mapForeground			//Load the foreground's address
	ldr		r3, #0							//Set an empty cell
	bl		d_setCellElement				//Set the cell under Mario (the enemy) to a blank
	
	//Move Mario
	ldr		r0, [r4]						//Load Mario's X position
	lsl		r0, #16							//Move Mario's x position to the top half of the register
	ldr		r6, [r5]						//Load Mario's Y position
	orr		r0, r6							//Move Mario's Y position into the bottom half of r0
	mov		r1, #0							//Don't move Mario horizontally
	mov		r2, #-1							//Move Mario down one cell
	ldr		r3, =d_mapForeground			//Load the foreground's address
	bl		d_moveElement					//Move Mario
	
	pop		{r4-r10, pc}					//Return all the previous registers and return
	
	
	
	
//Mario's default map coordinates, used to place him at the start of the game
_t_marioDefaultPosition:
_t_marioDefaultPositionX:	.hword 2
_t_marioDefaultPositionY:	.hword 21

//Minimum number of clock ticks between movements
_t_marioMoveDelay:			.byte 1			//Change this to change how often Mario moves
	
.section					.data

//Jump/Fall state register, stores whether Mario
_d_verticalState:			.byte 0

//Last tick in which Mario moved
_d_lastMoveTick:			.word 0

//Mario's coordinates in the map
_d_marioPosition:
_d_marioPositionX:			.hword 2
_d_marioPositionY:			.hword 21