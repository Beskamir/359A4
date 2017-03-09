///This file is used to clear the screen.

.section    .init
.globl 		UpdateScreen
    
.section .text

//input: The buffer to be displayed
//return: null
//effect: draw a new frame
UpdateScreen:
	push {r4-r10, fp, lr}

	bl ClearScreen

	//get each pixel to draw and then draw to the screen
	///This is to be implemented

	pop {r4-r10, fp, lr}
	bx	lr

//input: null
//return: null
//effect: makes every pixel on the screen black
ClearScreen:
	push {r4-r8, fp, lr}

	mov	r4,	#0			//x value
	mov	r5,	#0			//Y value
	mov	r6,	#0			//black color
	ldr	r7,	=1023		//Width of screen
	ldr	r8,	=767		//Height of the screen


	clearLooping:
		mov	r0,	r4			//Setting x 
		mov	r1,	r5			//Setting y
		mov	r2,	r6			//setting pixel color
		push {lr}
		bl	DrawPixel
		pop {lr}
		add	r4,	#1			//increment x by 1
		cmp	r4,	r7			//compare with width
		blt	clearLooping
		mov	r4,	#0			//reset x
		add	r5,	#1			//increment Y by 1
		cmp	r5,	r8			//compare with height
		blt	clearLooping

	pop {r4-r8,fp,lr}
	bx	lr

//input: 
	//int x value, 
	//int y value, 
	//hex? pixel colour
//return: null
//effect: draw an individual pixel
DrawPixel:
	push	{r4}

	offset	.req	r4

	// offset = (y * 1024) + x = x + (y << 10)
	add		offset,	r0, r1, lsl #10
	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
	lsl		offset, #1

	// store the colour (half word) at framebuffer pointer + offset

	ldr	r0, =FrameBufferPointer
	ldr	r0, [r0]
	strh	r2, [r0, offset]

	pop		{r4}
	bx		lr

.section .data  