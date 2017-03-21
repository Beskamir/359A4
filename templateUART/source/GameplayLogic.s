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

	bl _f_newGame

	bl _f_drawMap

	_playingLoop:	//Keep looping until game is over
	
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

	mov temp_r, #32

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
		
		////BUG: Possibly?
	
			sub r0, #1
			lsl r0, #12 
			//r0 currently has address of sprite to draw
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
_s_gameState:	
	.byte 0, 0, 0, 0
	.align
_s_cameraPosition:
	.int 0