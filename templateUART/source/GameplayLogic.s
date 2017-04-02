//This file contains all the game logic.
//	mainly deals with the gameplay state and controls other more specific files


/*
**Function**
Keep looping this until the game ends or user quits
input: null
return: null
effect: main loop function in gameplay logic.
*/
.globl f_playingState

//Input: null
//Output: null
//Effect: Add a coin to coin count, increment score, check if extra life earned
.globl f_addCoin

//Input: Amount to increase score by in r0
//Output: null
//Effect: Increase score by amount in r0
.globl f_addScore

.section    .init
    
.section .text
//Stores the game variables
//First byte is number of coins
//Second byte is number of lives
//Third byte stores the lose flag
//Fourth byte stores the win flag
.align 4
_t_gameState:	
_t_coins:
	.byte 0
_t_lives:
	.byte 3
_t_lose:
	.byte 0
_t_win:
	.byte 0

.align 4
//Word stores the score
_t_gameScore:
	.word 0
	.align

/*
Keep looping this until the game ends or user quits
input: null (in future could have something to stop _copyMap from executing)
return: null
effect: main loop function in gameplay logic.
*/
f_playingState:
	push {r4-r10, lr}

	mov r4, #0

	bl _f_newGame //reset all the stored data to the initial states

	_playingLoop:	//Keep looping until game is over
		//each loop is a frame
		ldr r0, =0x64FE		//Blueish colour based on an image of the original game.
		bl f_colourScreen	//drawing over the entire screen is sort of inefficent
		// ldr r0, =0x0FF0
		// bl f_colourScreen
		//draw the sprites located on the background map
		ldr r0, =d_mapBackground
		ldr r1, =d_cameraPosition
		bl f_drawMap		
		//draw the sprites located on the middle map
		ldr r0, =d_mapMiddleground
		ldr r1, =d_cameraPosition
		bl f_drawMap
		//draw the sprites located on the foreground map
		ldr r0, =d_mapForeground
		ldr r1, =d_cameraPosition
		bl f_drawMap
		
		bl _f_updateHUD // draw HUD
		bl f_refreshScreen	//refresh the screen

		bl f_updateAIs

		//player input
		
		bl	Read_SNES		//Get input from the player
		bl	f_playInput		//Handle input
			
		//check collisions
		//update map
		//update score/coins

		//AI input
		//check collisions
		//update map

		//check end state
		//loop or break

		ldr r0, =d_cameraPosition
		ldr r4, [r0]
		add r4, #1
		str r4, [r0]

		cmp r4, #288
		blt _playingLoop

	// b PlayingLoop

	pop {r4-r10, pc}

//Input: null
//Output: null
//Effect: displays HUD elements
_f_updateHUD:
	push {r4-r10, lr}
	
	//display correct HUD labels
	ldr r0, =t_scoreLabel
	mov r1, #50
	mov r2, #50
	mov r3, #2
	bl f_drawElement
	
	//display score below it
/*	ldr r0, =_d_gameScore
	ldr r1, [r0]
	ldr r0, =d_numToPrint
	str r1, [r0]
	ldr r0, =d_numToPrint
	mov r1, #170
	mov r2, #75
	mov r3, #3
	bl f_drawElement*/

	//display correct HUD labels
	ldr r0, =t_coinsLable
	mov r1, #250
	mov r2, #75
	mov r3, #2
	bl f_drawElement

	//display coins beside it
	ldr r0, =_d_gameState
	ldrb r1, [r0]
	ldr r0, =d_numToPrint
	str r1, [r0]
	ldr r0, =d_numToPrint
	ldr r1, =400
	mov r2, #75
	mov r3, #3
	bl f_drawElement
	
	//display correct HUD labels
	ldr r0, =t_livesLabel
	mov r1, #860
	mov r2, #50
	mov r3, #2
	bl f_drawElement

	//display lives beside it
	ldr r0, =_d_gameState
	ldrb r1, [r0, #1]
	ldr r0, =d_numToPrint
	str r1, [r0]
	ldr r0, =d_numToPrint
	ldr r1, =960
	mov r2, #50
	mov r3, #3
	bl f_drawElement
	
	pop {r4-r10, pc}


/*
Input: null
Return: null
Effect: resets the game to the initial setup.
*/
_f_newGame:
	push {r4-r7, lr}

	//copy maps
	//Technically background doesn't need to be copied as it
	// probably won't be changed but just incase the clouds 
	// are to move or something...
	/// Actually now I want to make the clouds move :P
	ldr r0, =t_mapBackground
	ldr r1, =d_mapBackground
	bl f_copyMap

	//copy the foreground map from text to data so it can 
	// be modified as the game is played
	ldr r0, =t_mapForeground
	ldr r1, =d_mapForeground
	bl f_copyMap

	//reset the camera position to whatever is in the .text copy.
	ldr r0, =t_cameraPosition
	ldr r1, [r0]
	ldr r0, =d_cameraPosition
	str r1, [r0]

	//reset the game state to the contents of the one that's in .text
	ldr r0, =_t_gameState
	// ldmia r0, {r4-r6} //shortcut doesn't seem to work with load byte.
	ldrb r4, [r0], #1
	ldrb r5, [r0], #1
	ldrb r6, [r0], #1

	ldr r0, =_d_gameState
	// stmia r0, {r4-r6} 
	strb r4, [r0], #1
	strb r5, [r0], #1
	strb r6, [r0], #1

	ldr r0, =_t_gameScore
	ldr r4, [r0]

	ldr r0, =_d_gameScore
	str r4, [r0]

	// str r7, [r0, #3]
	
	//Reset Mario's position

	pop {r4-r7, pc}

//Input: null
//Output: null
//Effect: Add a coin to coin count, increment score, check if extra life earned
f_addCoin:
	push {r4-r10, lr}
	
	//Load addresses
	ldr 	r4, =_d_gameState	//Load the address of the number of coins
	add		r5, r4, #1		//Load the address of the number of lives
	add 	r6, r4, #3		//Load the address of the score

	//Coins++
	ldrb	r7, [r4]		//Load the number of coins
	add		r7, #1			//Add an extra coin
	strb	r7, [r4]		//Store the number of coins
	
	//Check if need to increment lives and reset coins
	cmp		r7, #100		//Compare the number of coins to 100
	bne		incScore		//If it's not 100, no need to add a life
	mov		r7, #0			//Otherwise, reset the number of coins
	strb	r7, [r4]		//Store the number of coins
	ldrb	r7, [r5]		//Load the number of lives
	add		r7, #1			//Add an extra life
	strb	r7, [r5]		//Store the number of lives
	
	incScore:
	mov		r0, #200		//Add 200 points
	bl		f_addScore		//Call addScore
	
	pop {r4-r10, pc}

//Input: Amount to increase score by in r0
//Output: null
//Effect: Increase score by amount in r0
f_addScore:
	push {r4-r10, lr}
	
	mov	r4, r0				//Store the score to be added in a safe register
	
	ldr r5, =_d_gameState	//Load the address of the number of coins
	add	r5, #3				//Load the address of the score
	ldr	r6, [r5]			//Load the score
	
	add	r6, r4				//Increase the score
	str	r6, [r5]			//Store the score
	
	pop {r4-r10, pc}

.section .data

//Stores the game variables
//First byte is number of coins
//Second byte is number of lives
//Third byte stores the lose flag
//Fourth byte stores the win flag
.align 4
_d_gameState:	
_d_coins:
	.byte 0
_d_lives:
	.byte 3
d_lose:
	.byte 0
d_win:
	.byte 0

.align 4
//Word stores the score
_d_gameScore:
	.word 0
	.align
