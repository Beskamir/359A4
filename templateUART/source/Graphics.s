//This file contains or directly accesses all of the graphics related stuff

/*
input: 
	top leftmost x coordinate indicating beginning of image
	top leftmost y coordinate indicating beginning of image
	image address
return: null
effect: display an image at specified coordinates on the screen
*/
.globl drawImage

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


actuallyDraw:
	push {r4-r10, fp, lr}

	mov r9,sp		//save the sp

	mov	sp, r0 		//change sp to input parameter
	pop	{r4-r8}		//get the 5 registers

	drawLoop
		ldr r10, [r6], #4	//setting pixel color
		mov r2, r10
		bic r10, #0xFFFF 	//clear all bits other than first one and see if r10 is 0
		//ie 0xF043F is alpha mapped, 0x0FCE8 is not
		cmp r10, #0
		bne skipDraw		//don't draw pixel

		mov	r0,	r4			//Setting x 
		mov	r1,	r5			//Setting y
		push {lr}
		bl	drawPixel
		pop {lr}

	skipDraw:
		add	r4,	#1			//increment x by 1
		cmp	r4,	r7			//compare with width
		blt	drawLoop
		mov	r4,	#0			//reset x

		add	r5,	#1			//increment Y by 1
		cmp	r5,	r8			//compare with height
		blt	drawLoop

	mov	sp, r9 	//restore sp
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
core1Draw:
	//mark the core as being used
	ldr r9, =coreState
	ldr r10, [r9]
	orr r10, #1
	str r10, [r9]

	ldr r0, =stashedImage
	ldmia r0, {r4-r9}

	mov    	r8, r9 		//only draw half of the image
	push   	{r4-r8}
	mov    	r0, sp
	bl    	actuallyDraw

	//mark core as being off
	ldr r9, =coreState
	ldr r10, [r9]
	bic r10, #0x1
	// mov r10, #0
	str r10, [r9]

	mov r10, #0
	str r10, [#0x4000009C] //reset mailbox to 0 (should stop it... I hope)

/*
input: null
return: null
effect: displays half of an image
*/
core2Draw:
	//mark the core as being used
	ldr r9, =coreState
	ldr r10, [r9]
	orr r10, #2
	str r10, [r9]

	ldr r0, =stashedImage
	ldmia r0, {r4-r9}

	add 	r5, r9 		//skip to lower half of the image
	push	{r4-r8}
	mov    	r0, sp
	bl    	actuallyDraw	

	//mark core as being off
	ldr r9, =coreState
	ldr r10, [r9]
	bic r10, #0x2
	// mov r10, #0
	str r10, [r9]

	mov r10, #0
	str r10, [#0x400000AC] //reset mailbox to 0 (should stop it... I hope)
////////EXPERIMENTAL CODE

/*
input: 
	top leftmost x coordinate indicating beginning of image
	top leftmost y coordinate indicating beginning of image
	image address
return: null
effect: display an image at specified coordinates on the screen
*/
drawImage:
	push {r4-r10, fp, lr}
	
	mov r4, r0 		//x coordinate
	mov r5, r1      //y coordinate
	mov r6, r2 		//image address

	ldr r7, [r6], #4	//get the image's x size
	ldr r8, [r6], #4	//get the image's y size

	mov r9, r8 	//copy r8 to r9
	//currently assuming all images are gonna be even

	lsr r9, #2	//divide y value by 2

	ldr r10, =stashedImage
	stmia r10, {r4-r9}

	//gets base address to "core" mailbox
	mov r10, #0x40000000

	//starts core 1
	ldr r0, =core1Draw
	str r0, [r10, #0x9c]	

	//starts core 2
	ldr r0, =core2Draw
	str r0, [r10, #0xAC]

	//stall main core until core 1 and 2 finish.
	coreSync:
		//core state hex number with one's representing on, 0's representing off
		ldr r10, =coreState 

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
		bl	drawPixel
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

//Used for passing on what to print to the cores.
stashedImage:
	.int 0, 0, 0, 0, 0, 0
	.align 4