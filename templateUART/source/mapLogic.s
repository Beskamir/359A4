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
Input:
	r0, element's actual x cell value (map based)
	r1, element's actual y cell value (map based)
	r2, mapLayerMemoryAddress (address of the map being used)
Return:
	r0, element at the specified (x,y) positions
Effect:
	return cell element
*/
.globl f_getCellElement

/*
Input:
	r0, element's actual x cell value (map based)
	r1, element's actual y cell value (map based)
	r2, mapLayerMemoryAddress (address of the map being used)
	r3, the element to be stored at the (x,y) position
Return:
	null
Effect:
	stores element passed in r3 into the correct position in the map
*/
.globl f_setCellElement

/*
Input:
	r0, element's x and y cell value (screen space based)
		x in first half of register
			ie: 0xffff0000 (f's indicate values where x data is stored)
		y in second half of register
			ie: ox0000ffff (f's indicate values where y data is stored)
		x offset in which to move character 
	r1, x offsets which will be used to move character
		// -1 = move left, 0 = stay put, 1 = move right
	r2, y offsets which will be used to move character
		// -1 = move down, 0 = stay put, 1 = move up 
	r3, mapLayerMemoryAddress (address of the map being used)
Return:
	r0, whether the element was able to move to the new cell or not
		0 = failed to move
		1 = wasn't able to move, element there was enemy
		2 = was able to move
Effect:
	move or animate the element 
*/
.globl f_moveElement


// .globl f_resetCompareMap
// .globl f_compareMaps
// .globl f_drawBackground
// .globl f_clearAllCompareMaps

/*
**single int**
contains the position of the left most side of the camera.
*/
.globl d_cameraPosition

/*
Input: 
	r0: mario's current X position
Return: null
Effect: copies map in r0 to map in r1
*/
.globl f_updateCameraPosition

/*
 memory of what was on screen
*/
// .globl d_cellsChangedAll
// .globl d_cellsOldBackground
// .globl d_cellsOldMiddle
// .globl d_cellsOldForeground

.section    .init
    
.section .text

.align 4
t_cameraPosition: //this contains the position of the left side of the camera. 
	.int 0 //thus min value = 0 and max value = 288 (number of cells in game) 
	//actually this bound is completely wrong
/*
Input: 
	r0: mario's current X position
Return: null
Effect: copies map in r0 to map in r1
*/
f_updateCameraPosition:
	push {r4-r10, lr}
	marioX_r .req r4
	cameraMem_r .req r5
	marioMemX_r .req r6

	ldr marioMemX_r, =d_marioPositionX
	ldrh marioX_r, [marioMemX_r]
	// cameraLoc_r .req r6

	// mov marioX_r, r0
	ldr cameraMem_r, =d_cameraPosition
	// ldr cameraLoc_r, [cameraMem_r]
	cmp marioX_r, #14
	mov r1, #0
	strle r1, [cameraMem_r]
	ble _noCameraUpdate
		ldr r1, =302
		cmp marioX_r, r1
		mov r1, #288
		strge r1, [cameraMem_r]
		bge _noCameraUpdate
		// 	mov r1, #20 
		// 	cmp marioX_r, r1
		// 	bne skipCheat2
		// 		mov r0, marioX_r
		// 		ldr r1, [cameraMem_r]
		// 		sub r0, r1
		// 		ldr marioX_r, =260
		// 		str marioX_r, [cameraMem_r]
		// 		str marioX_r, [marioMemX_r]
		// 		mov r1, #21
		// 		bl f_combineRegisters
		// 		//r0 contains merged x and y
		// 		mov r1, marioX_r //moving left so set this to -1
		// 		mov r2, #0 //vertical delta set to 0 since this is just left/right movement
		// 		ldr r3, =d_mapForeground
		// 		bl f_moveElement
		// 		b _noCameraUpdate
		// skipCheat2:
			sub marioX_r, #14
			str marioX_r, [cameraMem_r]
	//branch here if mario out of camera range
	_noCameraUpdate:

	pop {r4-r10, pc}

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

// /*
// Input: address of screen based compare map to wipe
// Return: null
// Effect: resets all elements d_cellsChangedAll to 0
// */
// f_resetCompareMap:
// 	push {r4-r7, lr}

// 	counterX_r 		.req r4 //counts which x cell is being accessed
// 	counterY_r 		.req r5 //counts which y cell is being accessed
// 	camera_r 		.req r6 //camera position in the world space
// 	mapToReset_r	.req r7 //map to wipe

// 	mov mapToReset_r, r0

// 	_resetCompareMapLoop:
// 		//get each cell address from the array that keeps track of changed cells
// 		mov r0, counterX_r
// 		add r0, camera_r
// 		mov r1, counterY_r
// 		ldr r2, =d_cellsChangedAll
// 		// ldr r2, [r2]
// 		mov r3, #1
// 		bl _f_getCellMemAddress
// 		mov  r2, #0 	//prepare r2
// 		strb r2, [r0] 	//store r2 in cells changed array

// 		add counterX_r, #1	//increment x cell count by 1
// 		cmp counterX_r, #32	//x screen size is 32 cells 
// 		blt _resetCompareMapLoop

// 	mov counterX_r, #0 //reset x loop counter to 0
// 	add counterY_r, #1 //increment y cell count by 1
// 	cmp counterY_r, #24 //y screen size is 24 cells
// 	blt _resetCompareMapLoop

// 	.unreq counterX_r 
// 	.unreq counterY_r 
// 	.unreq camera_r
// 	.unreq mapToReset_r

// 	pop {r4-r7, pc}
// /*
// Input: null
// Return: null
// Effect: resets all the arrays which remember what changed on screen
// */
// f_clearAllCompareMaps:
// 	push {lr}

// 	ldr r0, =d_cellsChangedAll
// 	bl f_resetCompareMap	
// 	ldr r0, =d_cellsOldBackground
// 	bl f_resetCompareMap	
// 	ldr r0, =d_cellsOldMiddle
// 	bl f_resetCompareMap
// 	ldr r0, =d_cellsOldForeground
// 	bl f_resetCompareMap

// 	pop {pc}
// /*
// Input: null
// Return: null
// Effect: compares all maps
// */
// f_compareMaps:
// 	push {lr}

// 	ldr r0, =d_mapBackground
// 	ldr r1, =d_cameraPosition
// 	ldr r2, =d_cellsOldBackground
// 	bl _f_compareMapElements	

// 	ldr r0, =d_mapMiddleground
// 	ldr r1, =d_cameraPosition
// 	ldr r2, =d_cellsOldMiddle
// 	bl _f_compareMapElements

// 	ldr r0, =d_mapForeground
// 	ldr r1, =d_cameraPosition
// 	ldr r2, =d_cellsOldForeground
// 	bl _f_compareMapElements

// 	pop {pc}
// /*
// Input: 
// 	r0: address of map to compare
// 	r1: address to camera position int
// 	r2: address to data that was last displayed to screen
// Return: null
// Effect: compares the maps
// */
// _f_compareMapElements:
// 	push {r4-r10, lr}

// 	counterX_r 		.req r4 //counts which x cell is being accessed
// 	counterY_r 		.req r5 //counts which y cell is being accessed
// 	mapToCheck_r 	.req r6 //address of the map that will be compared to the old map
// 	oldMapAddress_r	.req r7 //address to map containing which elements were last displayed
// 	camera_r 		.req r8 //camera position in the world space
// 	newElement_r	.req r9 //element from the most recent map

// 	mov mapToCheck_r, r0	//load the map to use for drawing
// 	ldr camera_r,	[r1] 	//get camera position based on input parameter
// 	mov oldMapAddress_r, r2

// 	mov counterX_r, #0 	//set x loop counter to 0
// 	mov counterY_r, #0 	//set y loop counter to 0


// 	// _drawMapLoopY:
// 	_compareMapLoop:
// 		// _drawMapLoopX:
// 			//get each cell element from the entire map
// 			mov r0, counterX_r
// 			add r0, camera_r
// 			mov r1, counterY_r
// 			mov r2, mapToCheck_r
// 			mov r3, #0
// 			bl f_getCellElement
// 			mov newElement_r, r0


// 			//get each cell element from previous screen
// 			mov r0, counterX_r
// 			add r0, camera_r
// 			mov r1, counterY_r
// 			mov r2, oldMapAddress_r
// 			mov r3, #1
// 			bl f_getCellElement
// 			//r0 contains the element from map cell

// 			cmp r0, newElement_r
// 			beq _sameElement

// 			breakPoint1:
// 				//get each cell address from previous screen
// 				mov r0, counterX_r
// 				add r0, camera_r
// 				mov r1, counterY_r
// 				mov r2, oldMapAddress_r
// 				mov r3, #1
// 				bl _f_getCellMemAddress
// 				strb newElement_r, [r0] //store the element at it's "cell" address

// 				//get each cell address from the array that keeps track of changed cells
// 				mov r0, counterX_r
// 				add r0, camera_r
// 				mov r1, counterY_r
// 				ldr r2, =d_cellsChangedAll
// 				// ldr r2, [r2]
// 				mov r3, #1
// 				bl _f_getCellMemAddress
// 				mov  r2, #1		//prepare r2
// 				strb r2, [r0] 	//store r2 in cells changed array

// 			_sameElement:

// 			add counterX_r, #1	//increment x cell count by 1
// 			cmp counterX_r, #32	//x screen size is 32 cells 
// 			blt _compareMapLoop

// 		mov counterX_r, #0 //reset x loop counter to 0
// 		add counterY_r, #1 //increment y cell count by 1
// 		cmp counterY_r, #24 //y screen size is 24 cells
// 		blt _compareMapLoop

// 	//only need it for the above stuff, so unreq everything that was used in this subroutine
// 	.unreq counterX_r 
// 	.unreq counterY_r 
// 	.unreq mapToCheck_r
// 	.unreq oldMapAddress_r
// 	.unreq newElement_r
// 	.unreq camera_r

// 	pop {r4-r10, pc}
// /*
// Input: 
// 	r0: colour to be used for drawing the background
// 	r1: camera position
// Return: null
// Effect: draws the map
// */
// f_drawBackground:
// 	push {r4-r10, lr}

// 	counterX_r 		.req r4 //counts which x cell is being accessed
// 	counterY_r 		.req r5 //counts which y cell is being accessed
// 	camera_r 		.req r6 //camera position in the world space
// 	xSize_r 		.req r7 //address of the map that will be drawn.
// 	ySize_r 		.req r8 //address of the map that will be drawn.
// 	colour_r 		.req r9 //address of the map that will be drawn.


// 	mov colour_r,	 r0	 //load the map to use for drawing

// 	ldr camera_r,	[r1] //get camera position based on input parameter

// 	mov counterX_r, #0 	//set x loop counter to 0
// 	mov counterY_r, #0 	//set y loop counter to 0

// 	mov xSize_r, #32
// 	mov ySize_r, #32

// 	// _drawMapLoopY:
// 	_drawBackgroundLoop:
// 		// _drawMapLoopX:
// 			mov r0, counterX_r
// 			add r0, camera_r
// 			mov r1, counterY_r
// 			ldr r2, =d_cellsChangedAll
// 			// ldr r2, [r2]
// 			mov r3, #1
// 			bl f_getCellElement
// 			cmp r0, #1
// 			bne _skipBackgroundDrawing	
// 				//set up rectangle for drawing a background cell
// 				ldr r10, =d_rectangle	
// 				stmia r10, {r7-r9}	//store in order of x end, y end, colour 

// 				mov r0, r10
// 				mov r1, counterX_r
// 				lsl r1, #5
// 				mov r2, counterY_r
// 				lsl r2, #5
// 				mov r3, #0	//indicate that a rectangle of constant colour is being drawn
// 				bl f_drawElement

// 			_skipBackgroundDrawing:
// 			add counterX_r, #1	//increment x cell count by 1
// 			cmp counterX_r, #32	//x screen size is 32 cells 
// 			blt _drawBackgroundLoop

// 		mov counterX_r, #0 //reset x loop counter to 0
// 		add counterY_r, #1 //increment y cell count by 1
// 		cmp counterY_r, #24 //y screen size is 24 cells
// 		blt _drawBackgroundLoop

// 	//only need it for the above stuff, so unreq everything that was used in this subroutine
// 	.unreq counterX_r
// 	.unreq counterY_r
// 	.unreq camera_r
// 	.unreq xSize_r
// 	.unreq ySize_r
// 	.unreq colour_r

// 	pop {r4-r10, pc}
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
			// mov r0, counterX_r
			// add r0, camera_r
			// mov r1, counterY_r
			// ldr r2, =d_cellsChangedAll
			// // ldr r2, [r2]
			// mov r3, #1
			// bl f_getCellElement
			// cmp r0, #1
			// bne _skipDrawing

			mov r0, counterX_r
			add r0, camera_r
			mov r1, counterY_r
			mov r2, mapToDraw_r
			mov r3, #0
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
	r3, 0 if using entire map, 1 if using screen sized map
Return:
	r0, element at the specified (x,y) positions
Effect:
	return cell element
*/
f_getCellElement:
	push {lr}

	bl _f_getCellMemAddress
	ldrb r0, [r0] //load the element from it's "cell" address

	pop {pc}
/*
Input:
	r0, element's new x cell value (map based)
	r1, element's new y cell value (map based)
	r2, mapLayerMemoryAddress (address of the map being used)
	r3, the element to be stored at the (x,y) position
Return:
	null
Effect:
	stores element passed in r3 into the correct position in the map
*/
f_setCellElement:
	push {r4, lr}
	newElement_r .req r4
	mov newElement_r, r3

	bl _f_getCellMemAddress
	strb newElement_r, [r0]  //store the element at it's "cell" address

	.unreq newElement_r
	pop {r4, pc}

/*
Input:
	r0, element's actual x cell value (map based)
	r1, element's actual y cell value (map based)
	r2, mapLayerMemoryAddress (address of the map being used)
	r3, 0 if using entire map, 1 if using screen sized map
Return:
	r0, memory address of specified cell
Effect:
	get cell memory
*/
_f_getCellMemAddress:
	push {r4-r10, lr}

	cellIndexX_r .req r4 //x screen index of AI
	cellIndexY_r .req r5 //y screen index of AI

	mapAddress_r .req r6 //the address to the map being modified
	mapOffset_r	 .req r7 //the camera offset during this

	isSmallMap_r .req r8 //boolean for whether the map in question is full or screen sized

	//set to input parameters
	mov cellIndexX_r, r0
	mov cellIndexY_r, r1

	//get map address
	mov mapAddress_r, r2

	mov isSmallMap_r, r3

	//compute the correct offset to use on the map.
	//	((320*y)+x)+mapBaseAddress
	cmp isSmallMap_r, #1
	movne mapOffset_r, #320 
	moveq mapOffset_r, #32 
	mul mapOffset_r, cellIndexY_r
	add mapOffset_r, cellIndexX_r
	add mapOffset_r, mapAddress_r //combine mapoffset with mapaddress

	mov r0, mapOffset_r

	.unreq cellIndexX_r
	.unreq cellIndexY_r
	.unreq mapAddress_r
	.unreq mapOffset_r
	.unreq isSmallMap_r

	pop {r4-r10, pc}

/*
Input:
	r0, element's x and y cell value (screen space based)
		x in first half of register
			ie: 0xffff0000 (f's indicate values where x data is stored)
		y in second half of register
			ie: ox0000ffff (f's indicate values where y data is stored)
		x offset in which to move character 
	r1, x offsets which will be used to move character
		// -1 = move left, 0 = stay put, 1 = move right
	r2, y offsets which will be used to move character
		// -1 = move down, 0 = stay put, 1 = move up 
	r3, mapLayerMemoryAddress (address of the map being used)
Return:
	r0, whether the element was able to move to the new cell or not
		0 = something prevented from moving (cell had something in it)
		1 = wasn't able to move, element there was enemy. **useful for Mario**
		2 = was able to move without issues (cell was empty)
		3 = cell contained mario and thus couldn't move
Effect:
	move or animate the element 
*/
f_moveElement:
	push {r4-r10, lr}

	cellIndexX_r	.req r4 //x screen index of AI
	cellIndexY_r	.req r5 //y screen index of AI

	mapAddress_r	.req r6 //the address to the map being modified
	cameraOffset_r	.req r7 //the camera offset during this

	newCellXOffset_r .req r8
	newCellYOffset_r .req r9

	hasMoved_r		.req r10

	mov hasMoved_r, #0

	//get the x value from r0
	mov cellIndexX_r, r0
	lsr cellIndexX_r, #16

	//get the y value from r1
	mov cellIndexY_r, r0
	// equivalent to bic cellIndexY_r, #0xFFFF0000 but requires fewer registers 
	lsl cellIndexY_r, #16
	lsr cellIndexY_r, #16

	mov newCellXOffset_r, r1
	mov newCellYOffset_r, r2
	mov mapAddress_r, 	  r3

	ldr cameraOffset_r, =d_cameraPosition
	ldr cameraOffset_r, [cameraOffset_r]

	//compute where in the x axis we are in.
	add cellIndexX_r, cameraOffset_r

	//checks whether cell is safe to move into
	mov r0, cellIndexX_r
	add r0, newCellXOffset_r
	mov r1, cellIndexY_r
	sub r1, newCellYOffset_r
	mov r2, mapAddress_r
	mov r3, #0
	bl f_getCellElement

	//collision checks:
	cmp r0, #0 //check that cell is empty and skip enemy check if so
	beq _cellEmpty
	
	//set flage somewhere that mario died
	cmp r0, #114
	movge hasMoved_r, #3
	bge _cellFull


	//check that cell contains an enemy
	cmp r0, #83 
	blt _cellFull
		cmp r0, #96
		bgt _cellFull
			mov hasMoved_r, #1 //cell contains an enemy
			b _cellFull
	
	_cellEmpty:	
		//get sprite that will be moved
		mov r0, cellIndexX_r
		mov r1, cellIndexY_r
		mov r2, mapAddress_r
		mov r3, #0
		bl f_getCellElement
		mov r3, r0 // set r3 parameter to the sprite that'll be moved
		//store sprite in new cell
		mov r0, cellIndexX_r
		add r0, newCellXOffset_r
		mov r1, cellIndexY_r
		sub r1, newCellYOffset_r
		mov r2, mapAddress_r
		bl f_setCellElement

		//clear sprite from old cell
		mov r0, cellIndexX_r
		mov r1, cellIndexY_r
		mov r2, mapAddress_r
		mov r3, #0
		bl f_setCellElement
		mov hasMoved_r, #2

	_cellFull:
	mov r0, hasMoved_r

	.unreq cellIndexX_r	
	.unreq cellIndexY_r	
	.unreq mapAddress_r	
	.unreq cameraOffset_r 
	.unreq newCellXOffset_r 
	.unreq newCellYOffset_r 
	.unreq hasMoved_r	

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
	.int 0 //thus min value = 0 and max value = 288 (number of cells in map minus 32)

// d_cellsChangedAll:
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

// d_cellsOldBackground:
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

// d_cellsOldMiddle:
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

// d_cellsOldForeground:
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
// 	.byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
