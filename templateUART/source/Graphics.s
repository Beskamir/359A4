//This file contains or directly accesses all of the graphics stuff

/*
input: //passed in as sp
		mov    r4, #xvalue
		mov    r5, #yvalue
		mov    r6, #colour
		mov    r7, #width
		mov    r8, #height
		push   {r4-r8}
		mov    r0, sp
		bl    drawRectangle
	int x value
	int y value
	hex pixel colour
	width of rectangle
	height of rectangle
return: null
effect: draw a rectangle
*/
.globl drawRectangle

/*
input: 
	hex colour value to set screen to
return: null
effect: sets ever pixel on screen to a static colour
*/
.globl colourScreen

/*
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


// InitFrameBuffers:
// 	push {fp, lr}

// 	bl InitFrameBuffer

// 	pop {fp, lr}
// 	bx	lr

//Convert map.s to an image
DrawGameScreen:
	push {r4-r10, fp, lr}


	// mov	r4,	#0			//x value
	// mov	r5,	#0			//Y value
	// // mov	r6,	#0			//black color


	// mov	r7,	#32		//Width of screen
	// mov	r8,	#32		//Height of the screen

	// ldr r9, =Bricks

	// drawLooping:

	// 	ldr r6, [r9], #4
	// 	mov	r0,	r4			//Setting x 
	// 	mov	r1,	r5			//Setting y
	// 	mov	r2,	r6			//setting pixel color
	// 	push {lr}
	// 	bl	DrawPixel
	// 	pop {lr}
	// 	add	r4,	#1			//increment x by 1
	// 	cmp	r4,	r7			//compare with width
	// 	blt	drawLooping

	// 	mov	r4,	#0			//reset x
	// 	add	r5,	#1			//increment Y by 1
	// 	cmp	r5,	r8			//compare with height
	// 	blt	drawLooping



	ldr r4, =Bricks	//load brick label

	mov r5, #0
	// ldr r6, =BricksRow
	// sub r6, r4
	mov r6, #32
	mov r10, #0

	mov r9, #100
	mov r8, #100

	b drawLoopTest

drawImageLoop:
	b loopTest2
	drawImageLoop2:
		ldr r7, [r4], #4
		bic r7, #0xFF000000

		mov r0, r8
		mov r1, r9
		mov r2, r7
		push {lr}
		bl DrawPixel
		pop {lr}

		add r10, #1
		add r9, #1

		loopTest2:
		cmp r10,r6
		ble drawImageLoop2

	add r8, #1
	add r5, #1
	drawLoopTest:
	cmp r5,r6
	ble drawImageLoop

	pop {r4-r10, fp, lr}
	bx	lr

//input: 
	//top leftmost x coordinate indicating beginning of image
	//top leftmost y coordinate indicating beginning of image
	//image address
//return: null
//effect: display an image at specified coordinates on the screen
drawImage:
	push {r4-r10, fp, lr}
	
	mov r4, r0
	mov r5, r1
	mov r6, r2



	pop {r4-r10, fp, lr}
	bx	lr

//input: The buffer to be displayed
//return: null
//effect: draw a new frame
UpdateScreen:
	push {r4-r10, fp, lr}

	mov r4, r0

	bl ClearScreen

	bl DrawGameScreen
	//r4 contains reference to the buffer that should be drawn
////////////////////////////////////////////////////////
	//get each pixel to draw and then draw to the screen
	///This is to be implemented
//\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

	pop {r4-r10, fp, lr}
	bx	lr

/*
input: 
	hex colour value to set screen to
return: null
effect: sets ever pixel on screen to a static colour
*/
colourScreen:
	push {r4-r8, fp, lr}

	mov	r4,	#0			//x value
	mov	r5,	#0			//Y value
	mov	r6,	r0 			//colour to set entire screen to
	ldr	r7,	=1023		//Width of screen
	ldr	r8,	=767		//Height of the screen

	push [r4-r8]
	mov r0, sp
	bl drawRectangle

	pop {r4-r8,fp,lr}
	bx	lr

/*
input: //passed in as sp
		mov    r4, #xvalue
		mov    r5, #yvalue
		mov    r6, #colour
		mov    r7, #width
		mov    r8, #height
		push   {r4-r8}
		mov    r0, sp
		bl    drawRectangle
	int x value
	int y value
	hex pixel colour
	width of rectangle
	height of rectangle
return: null
effect: draw a rectangle
*/
drawRectangle:
	push {r4-r9, fp, lr}
	mov r9,sp		//save the sp

	mov	sp, r0 		//change sp to input parameter
	pop	{r4-r8}		//get the 5 registers

	rectanlgeLoop:
		mov	r0,	r4			//Setting x 
		mov	r1,	r5			//Setting y
		mov	r2,	r6			//setting pixel color
		push {lr}
		bl	DrawPixel
		pop {lr}

		add	r4,	#1			//increment x by 1
		cmp	r4,	r7			//compare with width
		blt	rectanlgeLoop
		mov	r4,	#0			//reset x

		add	r5,	#1			//increment Y by 1
		cmp	r5,	r8			//compare with height
		blt	rectanlgeLoop

	mov	sp, r9
	pop {r4-r8,fp,lr}
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
	xValue	.req	r0
	yValue	.req	r1
	colour	.req	r2
	offset	.req	r3
	temp	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	// add		offset,	r0, r1, lsl #10
	add		offset,	xValue, yValue, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset

	ldr		temp, =FrameBufferPointer
	ldr		temp, [temp]
	strh	colour, [temp, offset]

	pop		{r4}
	bx		lr

.section .data  