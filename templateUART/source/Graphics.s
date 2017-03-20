//This file contains or directly accesses all of the graphics related stuff

/*
**Function**
input: 
	image address. 
		if drawing rectangle, store x, y,colour  in "rectangle: .int 0 0 0"
		if drawing sprite, just pass in the address to that sprite
	top leftmost x coordinate indicating beginning of image
	top leftmost y coordinate indicating beginning of image
	whether the colour is uniform. 0 if uniform, 1 if not. 
		**Use 1 if using an image. 0 if using a static colour specified in "rectangle"
return: null
effect: display an image at specified coordinates on the screen
*/
.globl f_drawElement

/*
**Function**
input: 
	hex colour value to set screen to
return: null
effect: sets ever pixel on screen to a static colour
*/
.globl f_colourScreen

/*
**Array of 3 ints**
format: xSize, ySize, colour
use: for passing into f_drawElement
*/
.globl s_rectangle

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
.globl f_drawPixel

// .section .init
// .include "map.s"
// .include "art.s" Not needed, everything's global
// .globl 		UpdateScreen	//makes update screen visible to all
    
.section .text

_f_drawFunction:
	push {r4-r10, fp, lr}

	spSave_r .req	r10 //save sp for restoring it later

	xValue_r .req 	r4 	//x screen position
	yValue_r .req	r5	//y screen position

	colorMem_r .req	r6 	//the address to the colour data

	xSize_r	.req	r7 	//x size of image to draw
	ySize_r	.req	r8 	//y size of image to draw

	temp_r 	.req 	r9 	//temp register used for cmps

	mov spSave_r, sp		//save the sp

	mov	sp, r0 		//change sp to input parameter
	pop	{r4-r8}		//get the 5 registers

	_drawLoop:
		ldr r3, =_s_isImage
		ldr temp_r, [r3]
		cmp temp_r, #0
		ldreq r2, [colorMem_r]//if not image, then colour is stored in rectangle aka colorMem
		beq _notImage

			//Load pixel colour from memory
			ldr temp_r, [colorMem_r], #4	//setting pixel color
			mov r2, temp_r
			// mov r3, #0x0000FFFF 
			bic temp_r, #255	//clear all bits other than first one and see if r9 is 0
			//ie 0xF043F is alpha mapped, 0x0FCE8 is not so if r9 is zero then draw pixel
			cmp temp_r, #0
			bne _skipDraw		//don't draw pixel

	_notImage:
		mov	r0,	xValue_r			//Setting x 
		mov	r1,	yValue_r			//Setting y
		push {lr}
		bl	f_drawPixel
		pop {lr}

	_skipDraw:
		add	xValue_r, #1			//increment x by 1
		cmp	xValue_r, xSize_r		//compare with width
		blt	_drawLoop
		mov	xValue_r,	#0			//reset x

		add	yValue_r, #1			//increment Y by 1
		cmp	yValue_r, ySize_r		//compare with height
		blt	_drawLoop

	mov	sp, spSave_r 	//restore sp
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
_f_core1Draw:
	//mark the core as being used
	ldr r9, =s_coreState
	ldr r10, [r9]
	orr r10, #1
	str r10, [r9]

	//get stashed image parameters
	ldr r0, =_s_stashedImage
	ldmia r0, {r4-r9}

	mov    	r8, r9 		//only draw half of the image
	push   	{r4-r8}
	mov    	r0, sp
	bl    	_f_drawFunction

	//mark core as being off
	ldr r9, =s_coreState
	ldr r10, [r9]
	bic r10, #0x1
	str r10, [r9]

	mov r9, #0x40000000
	mov r10, #0
	str r10, [r9, #0x9C] //reset mailbox to 0 (should stop it... I hope)

/*
input: null
return: null
effect: displays half of an image
*/
_f_core2Draw:
	//mark the core as being used
	ldr r9, =s_coreState
	ldr r10, [r9]
	orr r10, #2
	str r10, [r9]

	//get stashed image parameters
	ldr r0, =_s_stashedImage
	ldmia r0, {r4-r9}

	add 	r5, r9 		//skip to lower half of the image
	push	{r4-r8}
	mov    	r0, sp
	bl    	_f_drawFunction	

	//mark core as being off
	ldr r9, =s_coreState
	ldr r10, [r9]
	bic r10, #0x2
	str r10, [r9]

	mov r9, #0x40000000
	mov r10, #0
	str r10, [r9, #0xAC] //reset mailbox to 0 (should stop it... I hope)
//\\\\//////EXPERIMENTAL CODE

/*
input: 
	image address. (if drawing rectangle store x, y,colour  in "rectangle: .int 0 0 0")
	top leftmost x coordinate indicating beginning of image
	top leftmost y coordinate indicating beginning of image
	whether the colour is uniform. 0 if uniform, 1 if not. 
		**Use 1 if using an image. 0 if using a static colour specified in "rectangle"
return: null
effect: display an image at specified coordinates on the screen
*/
f_drawElement:
	push {r4-r10, fp, lr}
	mov r6, r0 		//image address
	mov r4, r1 		//x coordinate
	mov r5, r2      //y coordinate

	//r3 contains info for what is being drawn. Image vs rectangle
	ldr r10, =_s_isImage
	str r3, [r10]	//store it for when it matters
	

	ldr r7, [r6], #4	//get the image's x size
	ldr r8, [r6], #4	//get the image's y size

	mov r9, r8 	//copy r8 to r9
	//currently assuming all images are gonna be even

	lsr r9, #2	//divide copy of y value by 2

	//save regs r4 to r9 in stashed image
	ldr r10, =_s_stashedImage
	stmia r10, {r4-r9}	

	//gets base address to "core" mailbox
	mov r10, #0x40000000

	//starts core 1
	ldr r0, =_f_core1Draw
	str r0, [r10, #0x9c]	

	//starts core 2
	ldr r0, =_f_core2Draw
	str r0, [r10, #0xAC]

	//stall main core until core 1 and 2 finish.
	_coreSync:
		//core state hex number with one's representing on, 0's representing off
		ldr r10, =s_coreState 

		cmp r10, #0	//thus if core state is all 0 then all cores are off
		bne _coreSync //so stop looping

	pop {r4-r10, fp, lr}
	bx	lr

/*
input: 
	hex colour value to set screen to
return: null
effect: sets ever pixel on screen to a static colour
*/
f_colourScreen:
	push {r4-r9, fp, lr}

	mov	r4,	#0			//x value
	mov	r5,	#0			//Y value

	ldr	r6,	=1023		//Width of screen
	ldr	r7,	=767		//Height of the screen
	mov	r8,	r0 			//colour to set entire screen to
	
	ldr r9, =s_rectangle	
	stmia r9, {r6-r8}	//store in order of x, y, colour

	mov r0, r4
	mov r1, r5
	mov r2, r9
	mov r3, #0

	bl f_drawElement

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
f_drawPixel:
	push	{r4}
	mov 	r3, #0 	////Init to 0 for now, not yet using it

	// offset	.req	r4
	xValue_r	.req	r0
	yValue_r	.req	r1
	colour_r	.req	r2
	offset_r	.req	r3
	temp_r 		.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	// add		offset,	r0, r1, lsl #10
	add		offset_r,	xValue_r, yValue_r, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset_r, #1

	// store the colour (half word) at framebuffer pointer + offset

	ldr		temp_r, =FrameBufferPointer
	ldr		temp_r, [temp_r]
	strh	colour_r, [temp_r, offset_r]

	pop		{r4}
	bx		lr

.section .data  

//Used for passing on what to print to the cores.
_s_stashedImage:
	.int 0, 0, 0, 0, 0, 0
	.align 4

_s_isImage:
	.byte 0
	.align 4

s_rectangle:
	.int 0, 0, 0
	.align 4