//This file contains all the game logic

// .extern	snes
// .extern UpdateScreen
// .include "snes"

/*
**Function**
Keep looping this until the game ends or user quits
input: null
return: null
effect: main loop function in gameplay logic.
*/
.globl f_playingState

/*
**Function**
Input: 
	r0: address of map to draw
	r1: address to camera position int
Return: null
Effect: draws the map
*/
.globl f_drawMap

/*
**single int**
contains the position of the left most side of the camera.
*/
.globl t_cameraPosition

.section    .init
    
.section .text
//Stores the game variables
//First byte is number of coins
//Second byte is number of lives
//Third byte stores the win and lose flags
	//Bit 0 is the lose flag, Bit 1 is the win flag
//Word at the end stores the score
_t_gameState:	
	.byte 0, 3, 0
	.word 0
	.align

t_cameraPosition: //this contains the position of the left side of the camera. 
	.int 0 //thus min value = 0 and max value = (size of map - 32)


/*
Keep looping this until the game ends or user quits
input: null (in future could have something to stop _copyMap from executing)
return: null
effect: main loop function in gameplay logic.
*/
f_playingState:
	push {r4-r10, fp, lr}

	bl _f_newGame //reset all the stored data to the initial states

	_playingLoop:	//Keep looping until game is over
		//each loop is a frame
		ldr r0, =0x64FE		//Blueish colour based on an image of the original game.
		bl f_colourScreen	//drawing over the entire screen is sort of inefficent
		// ldr r0, =0x0FF0
		// bl f_colourScreen
		//draw the sprites located on the background map
		ldr r0, =d_mapBackground
		ldr r1, =_d_cameraPosition
		bl f_drawMap
		//draw the sprites located on the foreground map
		ldr r0, =d_mapForeground
		ldr r1, =_d_cameraPosition
		bl f_drawMap

		//draw HUD

		//player input
		//check collisions
		//update map
		//update score/coins

		//AI input
		//check collisions
		//update map

		//check end state
		//loop or break

	// b PlayingLoop

	pop {r4-r10, fp, lr}
	bx	lr

/*
Input: null
Return: null
Effect: resets the game to the initial setup.
*/
_f_newGame:
	push {r4-r7, fp, lr}

	//copy maps
	//Technically background doesn't need to be copied as it
	// probably won't be changed but just incase the clouds 
	// are to move or something...
	/// Actually now I want to make the clouds move :P
	ldr r0, =t_mapBackground
	ldr r1, =d_mapBackground
	bl _f_copyMap

	//copy the foreground map from text to data so it can 
	// be modified as the game is played
	ldr r0, =t_mapForeground
	ldr r1, =d_mapForeground
	bl _f_copyMap

	//reset the camera position to whatever is in the .text copy.
	ldr r0, =t_cameraPosition
	ldr r1, [r0]
	ldr r0, =_d_cameraPosition
	str r1, [r0]

	//reset the game state to the contents of the one that's in .text
	ldr r0, =_t_gameState
	ldmia r0, {r4-r6}
	ldr r7, [r0, #3]
	ldr r0, =_d_gameState
	stmia r0, {r4-r6}
	str r7, [r0, #3]

	pop {r4-r7, fp, lr}
	bx	lr
/*
Input: 
	r0: address of source map to copy from
	r1: address of destination map to copy to
Return: null
Effect: copies map in r0 to map in r1
*/
_f_copyMap:
	push {r4-r6, fp, lr}
	
	sourceMap_r 		.req r4
	destinationMap_r 	.req r5

	cellCounter_r		.req r6

	mov sourceMap_r, r0			//store the .text map address in sourceMap_r
	mov destinationMap_r, r0    //store the .data map address in destinationMap_r

	//copy all the elements of the map arrays from .text to .data	
	_copyMapLoop:
		ldrb r0, [sourceMap_r, cellCounter_r]		//load byte from source map
		strb r0, [destinationMap_r, cellCounter_r]	//store that byte in destination map
		//r0 is only used for these to instructions and changes each loop

		add cellCounter_r, #1 //increment  map cell count by 1
		cmp cellCounter_r, #7680 //map has 7680 elements or "cells". (24*320)
		blt _copyMapLoop

	//Unreq everything that was used in this subroutine
	.unreq sourceMap_r 
	.unreq destinationMap_r 
	.unreq cellCounter_r

	pop {r4-r6, fp, lr}
	bx	lr

_f_moveMario:
	push {r4-r10, fp, lr}
	
	//

	pop {r4-r10, fp, lr}
	bx	lr

_f_updateNPCs:
	push {r4-r10, fp, lr}
	
	//read from the map and check collisions

	pop {r4-r10, fp, lr}
	bx	lr

_f_updateMap:
	push {r4-r10, fp, lr}
	
	//update map position

	pop {r4-r10, fp, lr}
	bx	lr

_f_checkColisions:
	push {r4-r10, fp, lr}
	
	//update map position

	pop {r4-r10, fp, lr}
	bx	lr
	
//Input: null
//Output: null
//Effect: Add a coin to coin count, increment score, check if extra life earned
_f_addCoin:
	push {r4-r10, fp, lr}
	
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
	bl		_f_addScore		//Call addScore
	
	pop {r4-r10, fp, lr}
	mov	pc, lr

//Input: Amount to increase score by in r0
//Output: null
//Effect: Increase score by amount in r0
_f_addScore:
	push {r4-r10, fp, lr}
	
	mov	r4, r0				//Store the score to be added in a safe register
	
	ldr r5, =_d_gameState		//Load the address of the number of coins
	add	r5, #3				//Load the address of the score
	ldr	r6, [r5]			//Load the score
	
	add	r6, r4				//Increase the score
	str	r6, [r5]			//Store the score
	
	pop {r4-r10, fp, lr}
	mov	pc, lr

/*
Input: 
	r0: address of map to draw
	r1: address to camera position int
Return: null
Effect: draws the map
*/
f_drawMap:
	push {r4-r10, fp, lr}

	xCounter_r .req r4 //counts which x cell is being accessed
	yCounter_r .req r5 //counts which y cell is being accessed

	mapToDraw_r .req r6 //address of the map that will be drawn.

	xCameraPosition_r .req r7 //camera position in the world space

	spriteAccess_r .req r8

	temp_r .req r9	//scratch register for temp values



	ldr spriteAccess_r, =t_artSpritesAccess


	mov mapToDraw_r, r0				 //load the map to use for drawing
	ldr xCameraPosition_r, [r1] 	 //get camera position based on input parameter
	add mapToDraw_r, xCameraPosition_r

	// mov temp_r, #0

	.unreq xCameraPosition_r //only need it for the above stuff

	// cellsize_r .req r7	
	// mov cellsize_r, #32

	mov yCounter_r, #0 	//set y loop counter to 0
	
	_drawMapLoopY:
		mov xCounter_r, #0 //reset x loop counter to 0
		_drawMapLoopX:

			ldrb r0, [mapToDraw_r], #1
			cmp r0, #0
			beq _skipDrawing //skip drawing process if equal. 0 means theres no image there
		
			sub r0, #1	//sync r0 with the addresses in art
			//// lsl r0, #12 //(r0-1)>>12=(r0-1)*4096. 4096 is the difference between each label in art
			// ldr r1, =4104
			// mul r0, r1
			//Following faster than using mul
			lsl r0, #10	//r0>>12==r0*(32*32)
			add r0, #2  //r0+2
			lsl r0, #2  //r0>>2==r0*4
			add r0, spriteAccess_r //add the address of s_artSpritesAccess to the "offset" in r0
			//Now r0 has address of sprite to draw
			// mul r1, xCounter_r, cellsize_r//compute starting x value for the image
			mov r1, xCounter_r
			lsl r1, #5
			// mul r2, yCounter_r, cellsize_r //compute starting y value for the image
			mov r2, yCounter_r
			lsl r2, #5
			mov r3, #1	//indicate that an image is being drawn
			bl f_drawElement

			_skipDrawing:
			add xCounter_r, #1	//increment x cell count by 1
			cmp xCounter_r, #32	//x screen size is 32 cells 
			blt _drawMapLoopX

		add yCounter_r, #1 //increment y cell count by 1
		add mapToDraw_r, #288 //map is 320 cells wide, so 320-32=288 which is the offset
		cmp yCounter_r, #24 //y screen size is 24 cells
		blt _drawMapLoopY

	//only need it for the above stuff, so unreq everything that was used in this subroutine
	.unreq xCounter_r 
	.unreq yCounter_r 
	.unreq mapToDraw_r
	// .unreq cellsize_r
	.unreq spriteAccess_r
	.unreq temp_r


	pop {r4-r10, fp, lr}
	bx	lr

.section .data

//Stores the game variables
//First byte is number of coins
//Second byte is number of lives
//Third byte stores the win and lose flags
	//Bit 0 is the lose flag, Bit 1 is the win flag
//Word at the end stores the score
_d_gameState:	
	.byte 0, 0, 0
	.word 0
	.align

_d_cameraPosition: //this contians the position of the left side of the camera. 
	.int 0 //thus min value = 0 and max value = (size of map - 32)