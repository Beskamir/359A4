//This file handles Mario stuff, mainly relating to movement

.section		.init

.globl			f_resetMarioPosition		//Reset Mario's position (in registers, not in the map)
.globl			f_moveMario					//Move Mario (in map and registers)
.globl			f_killMario					//Kill Mario
.globl			d_marioPositionX
.section		.text

//Input: Null
//Output: Null
//Effect: Reset's Mario's position back to where he starts at the beginning of the game
f_resetMarioPosition:
	push	{r4-r10, lr}					//Push all the general purpose registers along with fp and lr to the stack
	
	//Clear Mario from the map
	ldr		r4, =d_marioPositionX			//Store the address of Mario's current X position
	ldr		r5, =_d_marioPositionY			//Store the address of Mario's current Y posiion
	ldrh	r0, [r4]						//Load Mario's current X position
	ldrh	r1, [r5]						//Load Mario's current Y position
	ldr		r2, =d_mapForeground 			//Move in the address of the foreground
	mov		r3, #0							//Load the code for an empty cell
	bl		f_setCellElement				//Replace Mario with an empty cell
	
	//Load Mario's default position values
	ldr		r4, =_t_marioDefaultPositionX	//Store the address of Mario's default X position
	ldr		r5, =_t_marioDefaultPositionY	//Store the address of Mario's default Y posiion
	ldrh	r7, [r4]						//Load Mario's default x position
	ldrh	r8, [r5]						//Load Mario's default y position
	
	//Store Mario's default position values
	ldr		r4, =d_marioPositionX			//Store the address of Mario's current X position
	ldr		r5, =_d_marioPositionY			//Store the address of Mario's current Y posiion
	strh	r7, [r4]						//Set Mario's X position to the default
	strh	r8, [r5]						//Set Mario's Y position to the default
	
	//Add Mario to his default location on the map
	mov		r0, r7							//Move in Mario's default X position
	mov		r1, r8							//Move in Mario's default Y position
	ldr		r2, =d_mapForeground 			//Move in the address of the foreground
	mov		r3, #114						//Load the code for Mario
	bl		f_setCellElement				//Add Mario back to the map
	
	//Reset Mario's vertical state
	ldr		r4, =_d_verticalState			//Load the address of the vertical state
	mov		r5, #0							//Store a 0
	str		r5, [r4]						//Store that 0 as the vertical state

	//Reset Mario's jump boost
	ldr		r4, =_d_jumpBoost				//Load the address of the vertical state
	mov		r5, #0							//Store a 0
	strb	r5, [r4]						//Store that 0 as the vertical state

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
	
	// bl		_f_shouldMarioMove				//Should we be moving Mario right now?
	// tst		r0, #1							//Is the answer yes?
	// bne		doneMovingMario					//If not, don't move Mario, just skip to the end
	
	ldr		r8, =_d_tempCoin				//Load the address of tempCoin
	ldrb	r9, [r8]						//Load tempCoin
	cmp		r9, #1							//Is tempCoin set?
	bleq	_f_clearTempCoin				//If so, remove the tempCoin
	
	//r6 = X position
	//r7 = Y position
	ldr		r10, =d_marioPositionX			//Store the address of Mario's X position
	ldrh	r6, [r10]						//Load Mario's X position
	ldr		r10, =_d_marioPositionY			//Store the address of Mario's Y position
	ldrh	r7, [r10]						//Load Mario's Y position
	
	
	//Y movement
	//r8 = verticalState address
	//r9 = vertical state
	ldr		r8, =_d_verticalState			//Load the address of the vertical state
	ldr		r9, [r8]						//Load the value of the vertical state
	cmp		r9, #0							//Compare the vertical state to 0
	bgt		jumping							//If the value is positive, Mario is jumping, so no need to worry about falling
	bl		_f_isMarioOnGround				//Check whether Mario is on the ground or if he should be falling
	cmp		r0, #1							//Is Mario on the ground?
	bne		falling							//If Mario is not jumping and not on the ground then he is falling
	cmp		r5, #1							//Does Mario want to start a jump?
	beq		startJump						//If so go, start the jump (then jump)
	b		doneYMovement					//If Mario is not falling, jumping or starting a jump and he's on the ground, don't do any Y movement
	
	falling:
	//Falling
	//Increase Mario's fall speed
	sub		r9, #1							//Increase Mario's fall speed by 1
	str		r9, [r8]						//Store Mario's new fall speed
	//Move Mario in map
	//r9 = Mario's fall speed = loop counter = Number of times Mario is moved down until he hits terrain
	FallMarioTop:							//Top of the loop, r9 is the loop counter as it is Mario's fall speed
		ldr 	r1, =d_cameraPosition
		ldr 	r1, [r1]
		mov 	r0, r6
		sub 	r0, r1
		lsl		r0, #16						//Move X position to top half of r0
		orr		r0, r7						//Add Y position to bottom half of r0
		mov		r1, #0						//Don't move Mario horizontally
		mov		r2, #-1						//Move Mario 1 space down
		ldr		r3, =d_mapForeground		//Mario is in the foreground
		bl		f_moveElement				//Move Mario
		mov		r10, r0						//Store result in a safe register

		cmp		r10, #2						//Did the move succeed?
		beq		FallMarioTest				//If so, go to the test
		cmp		r10, #1						//Did we fail to move due to an enemy?
		bleq	_f_killEnemy				//If so, kill the enemy!
		beq		FallMarioTest				//Then go to the loop test

		//If neither, then we're done falling!
		mov		r9, #0						//Set Mario's vertical speed to 0
		str		r9, [r8]					//Store Mario's vertical speed
		b		doneFallMap					//We're done falling in the map

	FallMarioTest:							//Loop test
		// bl		_f_inHole					//Check if Mario is in a hole
		bl		_f_collectItems					//Collect any items in Mario's new location
		add		r9, #1						//Add 1 to the loop counter (counting up to 0)
		add		r7, #1						//Subtract 1 from Mario's Y position (by adding because opposite)
		cmp		r9, #0						//Compare the loop counter to 0
		blt		FallMarioTop				//If r9 is still less than 0, we need to move Mario down again
	//Move Mario in data register
	doneFallMap:
	ldr		r10, =_d_marioPositionY			//Load the address of Mario's Y position
	strh	r7, [r10]						//Store Mario's new Y position
	b		doneYMovement					//We're done moving Mario vertically
	
	//Jumping
	startJump:
	//Does Mario have the jump boost powerup?
	ldr		r10, =_d_jumpBoost				//Load the address of jumpBoost
	ldrb	r0, [r10]						//Load the value of jumpBoost
	cmp		r0, #1							//Is jumpBoost activated?
	moveq	r9, #4							//If so, load the boosted jump value as the current jump speed
	movne	r9, #3							//Otherwise, load the normal jump value as the current jump speed
	str		r9, [r8]						//Store the current jump speed as the new vertical state
	jumping:
	//Move Mario in map
	//r9 = Mario's jump speed = loop counter = Number of times Mario is moved up until he hits terrain
	JumpMarioTop:							//Top of the loop, r9 is the loop counter as it is Mario's jump speed
		ldr 	r1, =d_cameraPosition
		ldr 	r1, [r1]
		mov 	r0, r6
		sub 	r0, r1		
		lsl		r0, #16						//Move X position to top half of r0
		orr		r0, r7						//Add Y position to bottom half of r0
		mov		r1, #0						//Don't move Mario horizontally
		mov		r2, #1						//Move Mario 1 space up
		ldr		r3, =d_mapForeground		//Mario is in the foreground
		bl		f_moveElement				//Move Mario
		mov		r10, r0						//Store result in a safe register
		
		cmp		r10, #2						//Did the move succeed?
		beq		JumpMarioTest				//If so, go to the test
		cmp		r10, #1						//Did we fail to move due to an enemy?
		bleq	f_killMario					//If so, kill Mario!
		beq		doneMovingMario				//Then stop moving

		//If neither, then we've hit a block!
		mov		r9, #0						//Set Mario's vertical speed to 0
		str		r9, [r8]					//Store Mario's vertical speed
		bl		_f_hitBlock					//Handle hitting a block
		b		doneJumpMap					//We're done jumping in the map

	JumpMarioTest:							//Loop test
		bl		_f_collectItems					//Collect any items in Mario's new location
		sub		r9, #1						//Subtract 1 from the loop counter
		sub		r7, #1						//Add 1 to Mario's Y position (by subtracting because opposite)
		cmp		r9, #0						//Compare the loop counter to 0
		bgt		JumpMarioTop				//If r9 is still greater than 0, we need to move Mario down again
	//Lower Mario's jump speed
	ldr		r9, [r8]						//Store the jump speed in r9
	sub		r9, #1							//Decrease Mario's jump speed by 1
	str		r9, [r8]						//Store Mario's new jump speed
	//Move Mario in data register
	doneJumpMap:
	ldr		r10, =_d_marioPositionY			//Load the address of Mario's Y position
	strh	r7, [r10]						//Store Mario's new Y position
	//We're done moving Mario vertically
	
	doneYMovement:
	
	bl		_f_collectItems					//Collect any items in Mario's new location
	
	//X movement
	//Check if Mario should be moved horizontally
	cmp		r4, #0							//Compare X offset to 0
	beq		doneMovingMario					//If they're equal, branch to skip the X movement
	
	//Move Mario in map
	ldr 	r1, =d_cameraPosition
	ldr 	r1, [r1]
	mov 	r0, r6
	sub 	r0, r1
	lsl		r0, #16							//Move X position to top half of r0
	orr		r0, r7							//Add Y position to bottom half of r0
	mov		r1, r4							//Move Mario horizontally
	mov		r2, #0							//Don't move Mario vertically
	ldr		r3, =d_mapForeground			//Mario is in the foreground
	bl		f_moveElement					//Move Mario
	
	mov		r10, r0							//Save the feedback in a safe register
	cmp		r10, #0							//Did the move fail because we hit terrain?
	beq		doneMovingMario					//If so, we're done X movement
	cmp		r10, #1							//Did the move fail because we hit an enemy?
	bleq	f_killMario						//If so, kill Mario
	beq		doneMovingMario					//Then stop moving Mario
	//Otherwise, move was successful
	
	//Since move was successful, move Mario in memory registers
	ldr		r10, =d_marioPositionX			//Load the address of Mario's X position
	add		r6, r4							//Add the offset to Mario's X position
	strh	r6, [r10]						//Store Mario's new position
	
	doneMovingMario:
	
	bl		_f_collectItems					//Collect any items in Mario's new location

	bl		_f_didMarioWin					//Check if Mario won
	
	// bl 		_f_inHole						//check if mario in hole
	// ldr		r10, =d_marioPositionX			//Load Mario's X position address
	// ldrh	r0, [r10]						//Load Mario's X position
	// bl		f_updateCameraPosition			//Update the camera position

	pop		{r4-r10, pc}					//Return all the previous registers and return

//Input: Null
//Output: r0 - 0 for no, 1 for yes
//Effect: Null
_f_inHole:
	push	{r4-r10, lr}					//Push all the general purpose registers along with fp and lr to the stack

	ldr		r0, =_d_marioPositionY			//Load the address of Mario's Y position
	ldrh	r1, [r0]						//Load Mario's Y position
	
	cmp		r1, #23							//Is the cell ID too low?
	blt		notInHole						//if Mario is not in a hole
		bl		f_killMario					//End the function
	
	notInHole:

	pop		{r4-r10, pc}					//Return all the previous registers and return
		
//Input: Null
//Output: r0 - 0 for no, 1 for yes
//Effect: Null
_f_isMarioOnGround:
	push	{r4-r10, lr}					//Push all the general purpose registers along with fp and lr to the stack

	ldr		r4, =d_marioPositionX			//Load the address of Mario's X position
	ldrh	r0, [r4]						//Load Mario's X position
	ldr		r5, =_d_marioPositionY			//Load the address of Mario's Y position
	ldrh	r1, [r5]						//Load Mario's Y position
	add		r1, #1							//Add 1 to Mario's Y position to check the cell below him
	ldr		r2, =d_mapForeground			//Load the address of the foreground map
	mov		r3, #0							//Only look cells in the screen
	bl		f_getCellElement				//Find out which cell is below Mario
	mov		r6, r0							//Move the result to a safe register

	cmp		r6, #97							//Is the cell ID too low?
	blt		notOnGround						//Then Mario is not on the ground
	cmp		r6, #108						//Is the cell ID too high?
	bgt		notOnGround						//Then Mario is not on the ground
	//Otherwise, Mario is on the ground
	mov		r0, #1							//Mario is on the ground
	b		endIsMarioOnGround				//End the function
	
	notOnGround:
	mov		r0, #0							//Mario is not on the ground

	endIsMarioOnGround:

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
	movle	r0, #0							//If enough time hasn't passed, return 0
	
	pop		{r4-r10, pc}					//Return all the previous registers and return
	
	
	
//Input: Null	
//Output: Null
//Effect: Kills an enemy and moves Mario into its place
_f_killEnemy:
	push	{r4-r10, lr}					//Push all the general purpose registers along with fp and lr to the stack
	
	//Code to move enemy to seperate layer and do stuff with them here
	
	//Remove enemy from foreground
	ldr		r4, =d_marioPositionX			//Load the address of Mario's X position
	ldr		r5, =_d_marioPositionY			//Load the address of Mario's Y position
	ldrh	r0, [r4]						//Load Mario's X position
	ldrh	r1, [r5]						//Load Mario's Y position
	add		r1, #1							//Add 1 to get the enemy's Y position below Mario
	ldr		r2, =d_mapForeground			//Load the foreground's address
	mov		r3, #0							//Set an empty cell
	bl		f_setCellElement				//Set the cell under Mario (the enemy) to a blank
	
	//Move Mario
	ldr		r0, [r4]						//Load Mario's X position
	ldr 	r1, =d_cameraPosition
	ldr 	r1, [r1]
	sub 	r0, r1
	lsl		r0, #16							//Move Mario's x position to the top half of the register
	ldr		r6, [r5]						//Load Mario's Y position
	orr		r0, r6							//Move Mario's Y position into the bottom half of r0
	mov		r1, #0							//Don't move Mario horizontally
	mov		r2, #-1							//Move Mario down one cell
	ldr		r3, =d_mapForeground			//Load the foreground's address
	bl		f_moveElement					//Move Mario

	//Set enemyKilled flag
	ldr		r4, =_d_enemyKilled				//Load the address
	mov		r5, #1							//Move 1 into r5
	str		r5, [r4]						//Set enemyKilled
	
	pop		{r4-r10, pc}					//Return all the previous registers and return
	

//Input: Null
//Output: 0 if Mario has more lives
//Effect: Handle Mario hitting dying (from hitting an enemy), sets lose flag if no more lives
f_killMario:
	push	{r4-r10, lr}					//Push all the general purpose registers along with fp and lr to the stack
	
	ldr		r4, =_d_enemyKilled				//Load the address
	ldr		r5, [r4]						//Load the value
	cmp		r5, #1							//Is enemyKilled set?
	moveq	r5, #0							//Set to 0
	streq	r5, [r4]						//Clear it
	beq		endKillMario					//End the method

	//r4 = life address
	//r5 = number of lives
	ldr		r4, =d_lives					//Load the address of Mario's lives
	ldrb	r5, [r4]						//Load Mario's lives
	cmp		r5, #0							//Compare Mario's lives to 0
	ble		gameOver						//If Mario didn't have any extra lives, RIP
	sub		r5, #1							//Subtract a life
	strb	r5, [r4]						//Store the amount of lives remaining in r4

	bl		f_resetMarioPosition			//Reset Mario's position
	
	//Reset the camera position to whatever is in the .text copy
	ldr		r0, =t_cameraPosition
	ldr		r1, [r0]
	ldr		r0, =d_cameraPosition
	str		r1, [r0]
	
	b		endKillMario
	
	gameOver:
	ldr		r4, =d_lose						//Load the address of the lose flag
	mov		r5, #1							//Store a 1
	strb	r5, [r4]						//Set the lose flag
	
	
	endKillMario:
	
	pop		{r4-r10, pc}					//Return all the previous registers and return

	
	
//Input: Null
//Output: Null
//Effect: Handle Mario hitting a block above his head by jumping
_f_hitBlock:
	push	{r4-r10, lr}					//Push all the general purpose registers along with fp and lr to the stack
	
	//Set Mario's vertical state to 0
	ldr		r4, =_d_verticalState			//Load the address of Mario's vertical state
	mov		r5, #0							//Move in a 0
	str		r5, [r4]						//Store 0 as Mario's new vertical state
	
	//r4 = X position
	//r5 = Y position
	//r6 = X position address
	//r7 = Y position address
	ldr		r10, =d_marioPositionX			//Store the address of Mario's X position
	ldrh	r4, [r10]						//Load Mario's X position
	ldr		r10, =_d_marioPositionY			//Store the address of Mario's Y position
	ldrh	r5, [r10]						//Load Mario's Y position
	
	//Get the block's code
	//r8 = Block's Code
	mov		r0, r4							//Move in Mario's/Block's X position
	sub		r1, r5, #1						//Subtract 1 to get the Block's Y address (above Mario)
	ldr		r2, =d_mapForeground			//Load the address of the foreground
	mov		r3, #0							//Only look cells in the screen
	bl		f_getCellElement				//Get the block's code
	mov		r8, r0							//Store the block's code in a safe register
	
	//What block do we have?
	cmp		r8, #98							//Compare the block's code to 98
	ble		breakable						//If it's less than or equal to 98, it's breakable
	cmp		r8, #101						//Compare the block's code to 101
	ble		value							//If 98 < block code <= 101 then it's a value/"?" block
	b		doneHitBlock					//Otherwise it's just a solid block, so we don't do anything to it

	breakable:
	mov		r0, r4							//Move in Mario's/Block's X position
	sub		r1, r5, #1						//Subtract 1 to get the Block's Y address (above Mario)
	ldr		r2, =d_mapForeground			//Load the address of the foreground
	mov		r3, #0							//Code for an empty cell
	bl		f_setCellElement				//Replace the breakable block with an empty cell		
	
	mov		r0, r4							//Move in Mario's X position
	ldr 	r1, =d_cameraPosition
	ldr 	r1, [r1]
	sub 	r0, r1
	lsl		r0, #16							//Move it to the top half of the register
	orr		r0, r5							//Move Mario's Y position into the bottom half of r0
	mov		r1, #0							//Don't move Mario horizontally
	mov		r2, #1							//Move Mario one cell up
	ldr		r2, =d_mapForeground			//Load the address of the foreground
	bl		f_moveElement					//Replace the breakable block with an empty cell

	//Update Mario's position in memory registers
	sub		r5, #1							//Subtract 1 from Mario's Y position to move him up one cell
	strh	r5, [r7]						//Store Mario's new Y position
	b		doneHitBlock
		
	value:
	//Get the object
	//r8 = object ID
	mov		r0, r4							//Move in Mario's/Block's X position
	sub		r1, r5, #1						//Subtract 1 to get the Block's Y address (above Mario)
	ldr		r2, =d_mapMiddleground			//Load the address of the middle map
	mov		r3, #0							//Only look cells in the screen
	bl		f_getCellElement				//Get the ID of the object inside the block
	mov		r8, r0							//Store the item's code in a safe register
	
	//Move the item above the block
	mov		r0, r4							//Move in Mario's/Block's X position
	lsl		r0, #16							//Move it to the top half of the register
	sub		r1, r5, #1						//Subtract 1 from Mario's Y position to get the position of the block
	orr		r0, r1							//Move the Block's Y position into the bottom half of r0
	mov		r1, #0							//Don't move the item horizontally
	mov		r2, #1							//Move the item one cell up
	ldr		r2, =d_mapMiddleground			//Load the address of the middleground
	
	//Turn the value block into an empty block
	mov		r0, r4							//Move in Mario's/Block's X position
	sub		r1, r5, #1						//Subtract 1 to get the Block's Y address (above Mario)
	ldr		r2, =d_mapForeground			//Load the address of the foreground
	mov		r3, #102						//Code for an empty block
	bl		f_setCellElement				//Replace the value block with an empty block
	
	//What item was it?
	cmp		r8, #109						//Was it a super (jump) mushroom?
	ble		doneHitBlock					//If it was, then we can just end the function
	//Otherwise, it must be a coin, so we give it to Mario and remove it in the next interval
	
	//Set tempCoin
	ldr		r8, =_d_tempCoin				//Load the address of tempCoin
	mov		r9, #1							//Move in a 1
	strb	r9, [r8]						//Set tempCoin
	
	//Store the tempCoin address
	ldr		r8, =_d_tempCoinX				//Address of the temporary coin's X value
	ldr		r9, =_d_tempCoinY				//Address of the temporary coin's Y value
	strh	r4, [r8]						//Store Mario's X value as the temporary coin's X value
	sub		r10, r5, #2						//Temp coin Y value = 2 above Mario = Mario's Y value - 2
	strh	r10, [r9]						//Store the temporary coin's Y value
	
	bl		f_addCoin						//Give Mario the coin value and bonus score
	
	doneHitBlock:
	
	pop		{r4-r10, pc}					//Return all the previous registers and return
	
//Input: Null
//Output: Null
//Effect: Clears the temporary coin
_f_clearTempCoin:
	push	{r4-r10, lr}					//Push all the general purpose registers along with fp and lr to the stack
	
	//Load the tempCoin address
	ldr		r4, =_d_tempCoinX				//Address of the temporary coin's X value
	ldr		r5, =_d_tempCoinY				//Address of the temporary coin's Y value

	//Remove the coin
	ldrh	r0, [r4]						//Load the tempCoin's X address
	ldrh	r1, [r5]						//Load the tempCoin's Y address
	ldr		r2, =d_mapMiddleground			//Load the address of the middleground
	mov		r3, #0							//Replace coin with an empty cell
	bl		f_setCellElement				//Remove the coin
	
	//Clear tempCoin
	ldr		r4, =_d_tempCoin				//Load the address of tempCoin
	mov		r5, #0							//Move in a 0
	strb	r5, [r4]						//Clear tempCoin
	
	pop		{r4-r10, pc}					//Return all the previous registers and return
	

//Input: Null
//Output: Null
//Effect: Collect any powerups that are in the cell Mario is standing in
_f_collectItems:
	push	{r4-r10, lr}					//Push all the general purpose registers along with fp and lr to the stack
	
	ldr		r6, =d_marioPositionX			//Store the address of Mario's X position
	ldrh	r4, [r6]						//Load Mario's X position
	ldr		r6, =_d_marioPositionY			//Store the address of Mario's Y position
	ldrh	r5, [r6]						//Load Mario's Y position

	mov		r0, r4							//Move in Mario's X position
	mov		r1, r5							//Move in Mario's Y position
	ldr		r2, =d_mapMiddleground			//Load the address of the middle map
	mov		r3, #0							//Only look cells in the screen
	bl		f_getCellElement				//See what object is under Mario
	mov		r8, r0							//Store the item's code in a safe register
	
	cmp		r8, #0							//Is there nothing under Mario?
	beq		doneCollectItems				//If so, we're done
	cmp		r8, #109						//Is there a super (jump) mushroom under Mario?
	beq		superMushroom					//If so, handle it
	cmp		r8, #110						//Is there a life (1-up) mushroom under Mario?
	beq		lifeMushroom					//If so, handle it
	//Otherwise, it must be a coin!
	
	//Coin
	bl		f_addCoin						//Give Mario the coin
	b		removeItem						//Remove the coin
	
	superMushroom:							//Super (jump) Mushroom
	ldr		r6, =_d_jumpBoost				//Load the address of jumpBoost
	mov		r7, #1							//Move in a 1
	strb	r7, [r6]						//Set jumpBoost
	b		removeItem						//Remove the super (jump) mushroom
	
	lifeMushroom:							//Life (1-up) Mushroom
	ldr		r6, =d_lives					//Load the address of Mario's lives
	ldrb	r7, [r6]						//Load the number of lives
	add		r7, #1							//Add an extra life
	strb	r7, [r6]						//Store the new number of lives
	b		removeItem						//Remove the life (1-up) mushroom

	removeItem:								//Remove the item under Mario once it has been collected
	mov		r0, r4							//Move in Mario's/Item's X position
	mov		r1, r5							//Move in Mario's/Item's Y position
	ldr		r2, =d_mapMiddleground			//Load the middleground's address
	mov		r3, #0							//Set an empty cell
	bl		f_setCellElement				//Remove the item
	
	doneCollectItems:
	
	pop		{r4-r10, pc}					//Return all the previous registers and return
	
	
//Input: Null
//Output: Null
//Effect: If Mario won, set the win flag
_f_didMarioWin:
	push	{r4-r10, lr}						//Push all the general purpose registers along with fp and lr to the stack

	ldr		r10, =d_marioPositionX			//Store the address of Mario's X position
	ldrh	r4, [r10]						//Load Mario's X position
	ldr		r10, =_d_marioPositionY			//Store the address of Mario's Y position
	ldrh	r5, [r10]						//Load Mario's Y position
	
	//Get the block's code
	//r8 = Block's Code
	mov		r0, r4							//Move in Mario's X position
	mov		r1, r5							//Move in Mario's Y position
	ldr		r2, =d_mapBackground			//Load the address of the middleground
	mov		r3, #0							//Only look cells in the screen
	bl		f_getCellElement				//Get the block's code
	mov		r8, r0							//Store the block's code in a safe register
	
	cmp		r8, #10							//Compare the block ID to the first castle block ID
	blt		noWin							//If the ID is less than, then it's not a castle block
	cmp		r8, #34							//Compare the block ID to the last castle block ID
	bgt		noWin							//If the ID is greater than, then it's not a castle block
	//Otherwise, it's a castle block, so Mario wins
	
	//Set the win flag
	ldr		r9, =d_win						//Load the address of the win flag
	mov		r10, #1							//Move in a 1
	strb	r10, [r9]						//Set the win flag
	
	noWin:
	
	pop		{r4-r10, pc}					//Return all the previous registers and return
	
//Mario's default map coordinates, used to place him at the start of the game
.align 4
_t_marioDefaultPosition:
.align 4
_t_marioDefaultPositionX:	.hword 2
.align 4
_t_marioDefaultPositionY:	.hword 21

.align 4
//Minimum number of clock ticks between movements
_t_marioMoveDelay:			.byte 0			//Change this to change how often Mario moves
	
.section					.data

.align 4
//Jump/Fall state register, stores whether Mario
_d_verticalState:			.word 0

.align 4
//Last tick in which Mario moved
_d_lastMoveTick:			.word 0

.align 4
//Mario's coordinates in the map
_d_marioPosition:
.align 4
d_marioPositionX:			.hword 2
.align 4
_d_marioPositionY:			.hword 21

.align 4
//Does Mario have a jump boost powerup?
_d_jumpBoost:				.byte 0

.align 4
//If Mario hits a coin block, we need to remove the coin and give it to him in the next interval
_d_tempCoin:				.byte 0			//Is there a temp coin to remove?
.align 4
_d_tempCoinX:				.hword 0		//Temp coin's X position
.align 4
_d_tempCoinY:				.hword 0		//Tempo coin's Y position

.align 4
//enemyKilled flag
_d_enemyKilled:				.word 0
.align 4