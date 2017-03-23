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


.section    .init
    
.section .text

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
		ldr r0, =0x00FF
		bl f_colourScreen
		ldr r0, =s_mapBackground_data
		bl _f_drawMap
		ldr r0, =s_mapForeground_data
		bl _f_drawMap


	// b PlayingLoop

	pop {r4-r10, fp, lr}
	bx	lr

_f_newGame:
	push {r4-r10, fp, lr}

	bl _f_copyMap

	//set all variables in gameState to 0

	pop {r4-r10, fp, lr}
	bx	lr

_f_copyMap:
	push {r4-r10, fp, lr}
	
	//copy all the elements of the map arrays from .text to .data	

	pop {r4-r10, fp, lr}
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
	ldr 	r4, =gameState	//Load the address of the number of coins
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
	bl		addScore		//Call addScore
	
	pop {r4-r10, fp, lr}
	mov	pc, lr

//Input: Amount to increase score by in r0
//Output: null
//Effect: Increase score by amount in r0
_f_addScore:
	push {r4-r10, fp, lr}
	
	mov	r4, r0				//Store the score to be added in a safe register
	
	ldr r5, =gameState		//Load the address of the number of coins
	add	r5, #3				//Load the address of the score
	ldr	r6, [r5]			//Load the score
	
	add	r6, r4				//Increase the score
	str	r6, [r5]			//Store the score
	
	pop {r4-r10, fp, lr}
	mov	pc, lr

/*
Input: address of map to draw
Return: null
Effect: draws the map
*/
_f_drawMap:
	push {r4-r10, fp, lr}

	xCounter_r .req r4 //counts which x cell is being accessed
	yCounter_r .req r5 //counts which y cell is being accessed

	mapToDraw_r .req r6 //address of the map that will be drawn.

	xCameraPosition_r .req r7 //camera position in the world space

	temp_r, .req r8	//scratch register for temp values

	ldr temp_r, =_s_cameraPosition
	ldr xCameraPosition_r, [temp_r] //get camera position

	ldr mapToDraw_r, [r0] //load the map to use for drawing
	add mapToDraw_r, xCameraPosition_r

	// mov temp_r, #0

	.unreq xCameraPosition_r //only need it for the above stuff

	cellsize_r .req r7	
	mov cellsize_r, #32

	mov yCounter_r, #0 	//set y loop counter to 0
	
	_drawMapLoopY:
		mov xCounter_r, #0 //reset x loop counter to 0
		_drawMapLoopX:

			ldrb r0, [mapToDraw_r], #1
			cmp r0, #0
			beq _skipDrawing //skip drawing process if equal. 0 means theres no image there
		

			ldr temp_r, =s_artSpritesAccess
			sub r0, #1	//sync r0 with the addresses in art
			lsl r0, #12 //(r0-1)>>12=(r0-1)*4096. 4096 is the difference between each label in art
			add r0, temp_r //add the address of s_artSpritesAccess to the "offset" in r0
			//Now r0 has address of sprite to draw
			mul r1, xCounter_r, cellsize_r//compute starting x value for the image
			mul r2, yCounter_r, cellsize_r //compute starting y value for the image
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


	pop {r4-r10, fp, lr}
	bx	lr

.section .data
//Stores the game variables
//First byte is number of coins
//Second byte is number of lives
//Third byte stores the win and lose flags
	//Bit 0 is the lose flag, Bit 1 is the win flag
//Word at the end stores the score
_s_gameState:	
	.byte 0, 0, 0
	.word 0
	.align

_s_cameraPosition: //this contians the position of the left side of the camera. 
	.int 0 //thus min value = 0 and max value = (size of map - 32)