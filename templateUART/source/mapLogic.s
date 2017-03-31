//This file contains all the map related logic

/*
**single int**
contains the position of the left most side of the camera.
*/
.globl t_cameraPosition

/*
Input: 
	r0: address of source map to copy from
	r1: address of destination map to copy to
Return: null
Effect: copies map in r0 to map in r1
*/
.globl f_copyMap

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
Input:
	r0, memory address of element to be animated.
		ie: r0 = mapLayer[x][y]
		Where mapLayer is the entire map in question
	r1, value in {0,1,2} representing current state of element
		done by subtracting the lowest possible value of the element's group
			ie: for coin it'd be 111. So 111-111=0, 112-111=1, 113-111=2
	r2, length of each state. (probably in milliseconds or seconds)
Return:
	null
Effect:
	"animate" the element by changing changing it's sprite using the following dfa
		q0 -(t0)-> q1 -(t1)-> q2 -(t2)-> q1 -(t3)-> q0 (trivially loops)
		tn is a value from 0 to 4 gotten by from moduloing the system clock
		qn is the current sprite that's being used.
		stays on qn if tn is not met
*/
.globl f_animate3SpriteSet

/*
**single int**
contains the position of the left most side of the camera.
*/
.globl d_cameraPosition

.section    .init
    
.section .text

.align 4
t_cameraPosition: //this contains the position of the left side of the camera. 
	.int 0 //thus min value = 0 and max value = (size of map - 32) 
	//actually this bound is completely wrong

/*
Input: 
	r0: address of source map to copy from
	r1: address of destination map to copy to
Return: null
Effect: copies map in r0 to map in r1
*/
f_copyMap:
	push {r4-r6, lr}
	
	sourceMap_r 		.req r4
	destinationMap_r 	.req r5

	cellCounter_r		.req r6

	mov sourceMap_r, r0			//store the .text map address in sourceMap_r
	mov destinationMap_r, r1    //store the .data map address in destinationMap_r

	mov cellCounter_r, #0

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

	pop {r4-r6, pc}

/*
Input: 
	r0: address of map to draw
	r1: address to camera position int
Return: null
Effect: draws the map
*/
f_drawMap:
	push {r4-r10, lr}

	counterX_r 		.req r4 //counts which x cell is being accessed
	counterY_r 		.req r5 //counts which y cell is being accessed
	mapToDraw_r 	.req r6 //address of the map that will be drawn.
	spriteAccess_r 	.req r7 //address to all the sprites
	camera_r 		.req r8 //camera position in the world space


	mov mapToDraw_r, r0	 //load the map to use for drawing
	ldr camera_r,	[r1] //get camera position based on input parameter

	ldr spriteAccess_r, =t_artSpritesAccess

	
	mov counterX_r, #0 	//set x loop counter to 0
	mov counterY_r, #0 	//set y loop counter to 0

	// _drawMapLoopY:
	_drawMapLoop:
		// _drawMapLoopX:

			mov r0, counterX_r
			add r0, camera_r
			mov r1, counterY_r
			mov r2, mapToDraw_r
			bl f_getCellElement
			//r0 contains the element from map cell

			cmp r0, #10
			blt _skipDrawing //skip drawing process if equal. 0 means theres no image there

				sub r0, #10	//sync r0 with the addresses in art
				//Following faster than using mul but doesn't work properly :(
				// lsl r0, #10	//r0>>12==r0*(32*32)
				// add r0, #2  //r0+2
				// lsl r0, #2  //r0>>2==r0*4
				ldr r1, =4104 
				mul r0, r1 //(cell - 10) * 4104 = spriteOffset
				add r0, spriteAccess_r //add the address of s_artSpritesAccess to the "offset" in r0
				//Now r0 has address of sprite to draw
				// mul r1, counterX_r, cellsize_r//compute starting x value for the image
				mov r1, counterX_r
				lsl r1, #5
				// mul r2, counterY_r, cellsize_r //compute starting y value for the image
				mov r2, counterY_r
				lsl r2, #5
				mov r3, #1	//indicate that an image is being drawn
				bl f_drawElement

			_skipDrawing:
			add counterX_r, #1	//increment x cell count by 1
			cmp counterX_r, #32	//x screen size is 32 cells 
			blt _drawMapLoop

		mov counterX_r, #0 //reset x loop counter to 0
		add counterY_r, #1 //increment y cell count by 1
		// add mapToDraw_r, #288 //map is 320 cells wide, so 320-32=288 which is the offset
		cmp counterY_r, #24 //y screen size is 24 cells
		blt _drawMapLoop

	//only need it for the above stuff, so unreq everything that was used in this subroutine
	.unreq counterX_r 
	.unreq counterY_r 
	.unreq mapToDraw_r
	.unreq spriteAccess_r


	pop {r4-r10, pc}

/*
Input:
	r0, memory address of element to be animated.
		ie: r0 = mapLayer[x][y]
		Where mapLayer is the entire map in question
	r1, value in {0,1,2} representing current state of element
		done by subtracting the lowest possible value of the element's group
			ie: for coin it'd be 111. So 111-111=0, 112-111=1, 113-111=2
	r2, length of each state. (probably in milliseconds or seconds)
Return:
	null
Effect:
	"animate" the element by changing changing it's sprite using the following dfa
		q0 -(t0)-> q1 -(t1)-> q2 -(t2)-> q1 -(t3)-> q0 (trivially loops)
		tn is a value from 0 to 4 gotten by from moduloing the system clock
		qn is the current sprite that's being used.
		stays on qn if tn is not met
*/
f_animate3SpriteSet:
	push {r4-r10, lr}

	elementMem_r 	.req r4 //address passed in as parameter 
	state_r			.req r5 //state passed in as parameter
	transition_r	.req r6 //transition based on duration which is passed in
	increment_r		.req r7 //-1,0,1 for modifying sprite value
	spriteValue_r	.req r8 //the sprite value at the sprite address

	mov elementMem_r, r0
	mov state_r,	  r1
	mov transition_r, r2

	//TODO:
	//	Do fancy modulo stuff with transition and clock here to get value in {0,1,2,3}

	mov increment_r,  #0

	cmp state_r, #0
	bne _notState0
		cmp transition_r, #0
			moveq increment_r, #1

	_notState0:
	cmp state_r, #1
	bne _notState1
		cmp transition_r, #1
			moveq increment_r, #1
		cmp transition_r, #3
			moveq increment_r, #-1

	_notState1:
	cmp state_r, #2
	bne _notState2
		cmp transition_r, #2
			moveq increment_r, #-1
			
	_notState2:

	//1 comparison is less expensive than loading, incrementing, and storing to memory.
	cmp increment_r, #0
	beq _skipAnimate
		//actually update the sprite in the corresponding map
		ldr spriteValue_r, [elementMem_r]
		add spriteValue_r, increment_r
		str spriteValue_r, [elementMem_r]
	_skipAnimate:

	.unreq elementMem_r
	.unreq state_r
	.unreq transition_r
	.unreq increment_r
	.unreq spriteValue_r

	pop {r4-r10, pc}
/*
Input:
	r0, element's actual x cell value (map based)
	r1, element's actual y cell value (map based)
	r2, mapLayerMemoryAddress (address of the map being used)
Return:
	r0, element at the specified (x,y) positions
Effect:
	move or animate the element 
*/
f_getCellElement:
	push {r4-r10, lr}

	cellIndexX_r .req r4 //x screen index of AI
	cellIndexY_r .req r5 //y screen index of AI

	mapAddress_r .req r6 //the address to the map being modified

	mapOffset_r	 .req r7 //the camera offset during this

	//set to input parameters
	mov cellIndexX_r, r0
	mov cellIndexY_r, r1

	//get map address
	mov mapAddress_r, r2

	//compute the correct offset to use on the map.
	//	(320*y)+x
	mov mapOffset_r, #320 
	mul mapOffset_r, cellIndexY_r
	add mapOffset_r, cellIndexX_r


	ldrb r0, [mapAddress_r, mapOffset_r] //get map element at specified index

	// cmp r0, #0
	// beq debuggingSkip
	// 	debuggingBreak:
	// 	mov r0, r0
	// debuggingSkip:

	.unreq cellIndexX_r
	.unreq cellIndexY_r
	.unreq mapAddress_r
	.unreq mapOffset_r

	pop {r4-r10, pc}

_f_checkColisions:
	push {r4-r10, fp, lr}
	
	//update map position

	pop {r4-r10, fp, lr}
	bx	lr


_f_updateMap:
	push {r4-r10, fp, lr}
	
	//update map position

	pop {r4-r10, fp, lr}
	bx	lr


.section .data

.align 4
d_cameraPosition: //this contains the position of the left side of the camera. 
	.int 0 //thus min value = 0 and max value = (size of map - 32)