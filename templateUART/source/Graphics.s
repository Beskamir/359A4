//This file contains or directly accesses all of the graphics related stuff

/*
**Function**
input: 
	top leftmost x coordinate indicating beginning of image
	top leftmost y coordinate indicating beginning of image
	image address. 
		if drawing rectangle, store x, y,colour  in "rectangle: .int 0 0 0"
		if drawing sprite, just pass in the address to that sprite
	whether the colour is uniform. 0 if uniform, 1 if not. 
		**Use 1 if using an image. 0 if using a static colour specified in "rectangle"
return: null
effect: display an image at specified coordinates on the screen
*/
.globl drawElement

/*
**Function**
input: 
	hex colour value to set screen to
return: null
effect: sets ever pixel on screen to a static colour
*/
.globl colourScreen

/*
**Array of 3 ints**
format: xSize, ySize, colour
use: for passing into drawElement
*/
.globl rectangle

/*
**Function**
input: 
	int x value, 
	int y value, 
	hex pixel colour
	buffer offset may not end up using this
return: null
effect: draw an individual pixel
*/
.globl drawPixel

// .section .init
// .include "map.s"
// .include "art.s" Not needed, everything's global
// .globl 		UpdateScreen	//makes update screen visible to all
    
.section .text

_drawFunction:
	push {r4-r10, fp, lr}

	spSave_	.req	r10 //save sp for restoring it later

	xValue_ .req 	r4 	//x screen position
	yValue_	.req	r5	//y screen position

	colorMem_ .req	r6 	//the address to the colour data

	xSize_	.req	r7 	//x size of image to draw
	ySize_	.req	r8 	//y size of image to draw

	temp_ 	.req 	r9 	//temp register used for cmps

	mov spSave_, sp		//save the sp

	mov	sp, r0 		//change sp to input parameter
	pop	{r4-r8}		//get the 5 registers

	_drawLoop:
		ldr r3, =_isImage
		ldr temp_, [r3]
		cmp temp_, #0
		ldreq r2, [colorMem_]//if not image, then colour is stored in rectangle aka colorMem
		beq _notImage

			//Load pixel colour from memory
			ldr temp_, [colorMem_], #4	//setting pixel color
			mov r2, temp_
			bic temp_, #0xFFFF 	//clear all bits other than first one and see if r9 is 0
			//ie 0xF043F is alpha mapped, 0x0FCE8 is not so if r9 is zero then draw pixel
			cmp temp_, #0
			bne _skipDraw		//don't draw pixel

	_notImage:
		mov	r0,	xValue_			//Setting x 
		mov	r1,	yValue_			//Setting y
		push {lr}
		bl	drawPixel
		pop {lr}

	_skipDraw:
		add	xValue_, #1			//increment x by 1
		cmp	xValue_, xSize_		//compare with width
		blt	_drawLoop
		mov	xValue,	#0			//reset x

		add	yValue_, #1			//increment Y by 1
		cmp	yValue_, ySize_		//compare with height
		blt	_drawLoop

	mov	sp, spSave_ 	//restore sp
	pop {r4-r10, fp, lr}
	bx	lr

//Notes on multithreading
	//https://github.com/dwelch67/raspberrypi/blob/master/multi00/start.s
// multithread:
//     mrc p15, 0, r0, c0, c0, 5 //no idea what's the point of this instruction... 
	//some sample code had it some didn't so it doesn't look required
////////EXPERIMENTAL CODE
/*
input: null
return: null
effect: displays half of an image
*/
_core1Draw:
	//mark the core as being used
	ldr r9, =coreState
	ldr r10, [r9]
	orr r10, #1
	str r10, [r9]

	//get stashed image parameters
	ldr r0, =_stashedImage
	ldmia r0, {r4-r9}

	mov    	r8, r9 		//only draw half of the image
	push   	{r4-r8}
	mov    	r0, sp
	bl    	_drawFunction

	//mark core as being off
	ldr r9, =coreState
	ldr r10, [r9]
	bic r10, #0x1
	str r10, [r9]

	mov r10, #0
	str r10, [#0x4000009C] //reset mailbox to 0 (should stop it... I hope)

/*
input: null
return: null
effect: displays half of an image
*/
_core2Draw:
	//mark the core as being used
	ldr r9, =coreState
	ldr r10, [r9]
	orr r10, #2
	str r10, [r9]

	//get stashed image parameters
	ldr r0, =_stashedImage
	ldmia r0, {r4-r9}

	add 	r5, r9 		//skip to lower half of the image
	push	{r4-r8}
	mov    	r0, sp
	bl    	_drawFunction	

	//mark core as being off
	ldr r9, =coreState
	ldr r10, [r9]
	bic r10, #0x2
	str r10, [r9]

	mov r10, #0
	str r10, [#0x400000AC] //reset mailbox to 0 (should stop it... I hope)
//\\\\//////EXPERIMENTAL CODE

/*
input: 
	top leftmost x coordinate indicating beginning of image
	top leftmost y coordinate indicating beginning of image
	image address. (if drawing rectangle store x, y,colour  in "rectangle: .int 0 0 0")
	whether the colour is uniform. 0 if uniform, 1 if not. 
		**Use 1 if using an image. 0 if using a static colour specified in "rectangle"
return: null
effect: display an image at specified coordinates on the screen
*/
drawElement:
	push {r4-r10, fp, lr}
	mov r4, r0 		//x coordinate
	mov r5, r1      //y coordinate
	mov r6, r2 		//image address

	//r3 contains info for what is being drawn. Image vs rectangle
	ldr r10, =_isImage
	str r3, [r10]	//store it for when it matters
	

	ldr r7, [r6], #4	//get the image's x size
	ldr r8, [r6], #4	//get the image's y size

	mov r9, r8 	//copy r8 to r9
	//currently assuming all images are gonna be even

	lsr r9, #2	//divide copy of y value by 2

	//save regs r4 to r9 in stashed image
	ldr r10, =_stashedImage
	stmia r10, {r4-r9}	

	//gets base address to "core" mailbox
	mov r10, #0x40000000

	//starts core 1
	ldr r0, =_core1Draw
	str r0, [r10, #0x9c]	

	//starts core 2
	ldr r0, =_core2Draw
	str r0, [r10, #0xAC]

	//stall main core until core 1 and 2 finish.
	_coreSync:
		//core state hex number with one's representing on, 0's representing off
		ldr r10, =_coreState 

		cmp r10, #0	//thus if core state is all 0 then all cores are off
		bne coreSync //so stop looping

	pop {r4-r10, fp, lr}
	bx	lr

/*
input: 
	hex colour value to set screen to
return: null
effect: sets ever pixel on screen to a static colour
*/
colourScreen:
	push {r4-r9, fp, lr}

	mov	r4,	#0			//x value
	mov	r5,	#0			//Y value

	ldr	r6,	=1023		//Width of screen
	ldr	r7,	=767		//Height of the screen
	mov	r8,	r0 			//colour to set entire screen to
	
	ldr r9, =rectangle	
	stmia r9, {r6-r8}	//store in order of x, y, colour

	mov r0, r4
	mov r1, r5
	mov r2, r9
	mov r3, #0

	bl drawElement

	pop {r4-r9,fp,lr}
	bx	lr

/*
input: 
	int x value, 
	int y value, 
	hex pixel colour
	buffer offset may not end up using this
return: null
effect: draw an individual pixel
*/
drawPixel:
	push	{r4}
	mov 	r3, #0 	////Init to 0 for now, not yet using it

	// offset	.req	r4
	xValue_	.req	r0
	yValue_	.req	r1
	colour_	.req	r2
	offset_	.req	r3
	temp_	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	// add		offset,	r0, r1, lsl #10
	add		offset,	xValue, yValue, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset

	ldr		temp_, =FrameBufferPointer
	ldr		temp_, [temp_]
	strh	colour_, [temp_, offset_]

	pop		{r4}
	bx		lr

.section .data  

//Used for passing on what to print to the cores.
_stashedImage:
	.int 0, 0, 0, 0, 0, 0
	.align 4

_isImage:
	.byte 0
	.align 4

rectangle:
	.int 0, 0, 0
	.align 4