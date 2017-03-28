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
.globl d_rectangle

/*
**single int**
Optional:
default: black
format: colour
use: changes colour of text to be displayed.
*/
.globl d_textColour

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
// .globl f_drawPixel
.extern f_drawPixel

// .section .init
// .include "map.s"
// .include "art.s" Not needed, everything's global
// .globl 		UpdateScreen	//makes update screen visible to all
    
.section .text


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
_f_drawArt:
	push {r4-r10, lr}

	xValue_r .req 	r4 	//x screen position
	yValue_r .req	r5	//y screen position

	colorMem_r .req	r6 	//the address to the colour data

	xSize_r	.req	r7 	//x size of image to draw
	ySize_r	.req	r8 	//y size of image to draw

	type_r 	.req 	r9	//what is being drawn. static colour verses image

	xInit_r .req 	r10	//initial x screen position

	mov colorMem_r, r0 	//image address
	mov xValue_r, r1 	//x coordinate
	mov yValue_r, r2    //y coordinate
	mov type_r, r3		//info for what to draw

	mov xInit_r, xValue_r

	ldr xSize_r, [colorMem_r], #4 //load x size of image
	add xSize_r, xValue_r 		//offset x max by starting x value

	ldr ySize_r, [colorMem_r], #4 //load y size of image
	add ySize_r, yValue_r  		//offset y max by starting y value

	_drawLoop:
		cmp type_r, #0
		ldreq r2, [colorMem_r] //if not image, then colour is stored in rectangle aka colorMem
		beq _notImage

			//Load pixel colour from memory
			ldr r2, [colorMem_r], #4	//setting pixel color
			mov r0, r2 					//duplicate r2 into r0
			ldr r3, =0xFFFF 			//load 4 bytes of 1's
			bic r0, r3	//clear all bits other than first one and see if r9 is 0
			//ie 0xF043F is alpha mapped, 0x0FCE8 is not so if r9 is zero then draw pixel
			cmp r0, #0 			//check if r0 is 0, if so that means r2 contains valuable info.
			bne _skipDraw		//don't draw pixel

		_notImage:
			mov	r0,	xValue_r			//Setting x 
			mov	r1,	yValue_r			//Setting y
			// push {lr}
			bl	f_drawPixel
			// pop {lr}

		_skipDraw:
			add	xValue_r, #1			//increment x by 1
			cmp	xValue_r, xSize_r		//compare with width
			blt	_drawLoop
			
			mov xValue_r, xInit_r		//reset x

			add	yValue_r, #1			//increment Y by 1
			cmp	yValue_r, ySize_r		//compare with height
			blt	_drawLoop

	//unreq everything
	.unreq xValue_r 
	.unreq yValue_r 
	.unreq colorMem_r 
	.unreq xSize_r	
	.unreq ySize_r
	.unreq type_r	
	.unreq xInit_r 	

	pop {r4-r10, pc}

/* 
Draw the character 'B' to (0,0)
input: 
	character to print
	top leftmost x coordinate
	top leftmost y coordinate
	text colour
return: null
effect: display a character at specified coordinates on the screen
*/
_f_drawChar:
	push	{r4-r8, lr}


	chAdr_r	.req	r4  //character to be displayed
	px_r	.req	r5	//x position at which character should be displayed
	py_r	.req	r6  //y position at which character should be displayed
	row_r	.req	r7	//no idea
	mask_r	.req	r8 	//no idea

	xInit_r .req 	r9	//initial x position for restoring later

	colour_r .req 	r10 //text colour

	ldr	chAdr_r, =_font		// load the address of the font map
	// mov		r0,		#'B'		// load the character into r0
	add	chAdr_r, r0, lsl #4	// char address = font base + (char * 16)

	mov xInit_r, r1 		// store starting x position.
	mov	py_r,	 r2			// init the Y coordinate (pixel coordinate)

	mov colour_r, r3 		//store colour data

	_charLoop:
		mov		px_r,	xInit_r		// init the X coordinate

		mov		mask_r,	#0x01		// set the bitmask to 1 in the LSB
		
		ldrb	row_r,	[chAdr_r], #1	// load the row byte, post increment chAdr

		_rowLoop:
			tst		row_r,	mask_r		// test row byte against the bitmask
			beq		_noPixel

				mov		r0,		px_r
				mov		r1,		py_r
				mov		r2,		colour_r	//character colour
				bl		f_drawPixel			// draw red pixel at (px, py)

			_noPixel:
				add		px_r,	#1			// increment x coordinate by 1
				lsl		mask_r,	#1			// shift bitmask left by 1

				tst		mask_r,	#0x100		// test if the bitmask has shifted 8 times (test 9th bit)
				beq		_rowLoop

		add		py_r,	#1			// increment y coordinate by 1

		tst		chAdr_r, #0xF
		bne		_charLoop			// loop back to charLoop$, unless address evenly divisibly by 16 (ie: at the next char)

	.unreq	chAdr_r
	.unreq	px_r
	.unreq	py_r
	.unreq	row_r
	.unreq	mask_r

	pop		{r4-r8, pc}



/*
input: 
	image address. (if drawing rectangle store x end, y end, colour in "rectangle: .int 0 0 0")
	top leftmost x coordinate indicating beginning of image
	top leftmost y coordinate indicating beginning of image
	whether the colour is uniform. 0 if uniform colour, 1 if image(sprite), 2 if ascii text, 3 if int to text.
return: null
effect: display an image at specified coordinates on the screen
*/
f_drawElement:
	push {r4-r10, lr}

	mov r4, r0 		//image, rectangle, or text address.
	mov r5, r1 		//x coordinate
	mov r6, r2      //y coordinate
	// mov r7, r3		//info for what to draw

	// //r3 contains info for what is being drawn. Image vs rectangle
	// ldr r10, =_d_type
	// str r3, [r10]	//store it for when it matters

	cmp r3, #2
	beq _textDrawTest

	//preferably only above comparison would be needed. 
	//AKA lets figure out a way to pass in ints as strings rather than as ints.
	cmp r3, #3
	beq _intDrawTest

		//restore all even though most should still be unchanged
		// mov r0, r4 		//image address
		// mov r1, r5 		//x coordinate
		// mov r2, r6      //y coordinate
		// mov r3, r7		//info for what to draw

		bl _f_drawArt

		b _doneDraw

	_isText:
		mov r1, r5
		mov r2, r6
		bl _f_drawChar

	_textDrawTest:

		ldr r0, =d_textColour
		ldr r3, [r0]
		add r5, #20

		ldrb r0, [r4], #1

		cmp r0, #'/' //look for end character
		bne _isText

		//rest to default text colour
		ldr r0, =d_textColour
		mov r1, #0
		str r1, [r0]

		b _doneDraw

	_intDrawTest:

	//TODO somewhere here add int to string functionality... can be hacky as long as it works

	_doneDraw:

	pop {r4-r10, pc}

/*
input: 
	hex colour value to set screen to
return: null
effect: sets ever pixel on screen to a static colour
*/
f_colourScreen:
	push {r4-r9, lr}

	mov	r4,	#0			//x value
	mov	r5,	#0			//Y value

	ldr	r6,	=1023		//Width of screen
	ldr	r7,	=767		//Height of the screen

	mov	r8,	r0 			//colour to set entire screen to
	
	ldr r9, =d_rectangle	
	stmia r9, {r6-r8}	//store in order of x end, y end, colour 
	
	mov r0, r9
	mov r1, r4
	mov r2, r5
	mov r3, #0

	bl f_drawElement

	pop {r4-r9, pc}

// /*
// input: 
// 	int x value, 
// 	int y value, 
// 	hex pixel colour
// 	//buffer offset may not end up using this
// return: null
// effect: draw an individual pixel
// */
// f_drawPixel:
// 	push	{r4}
// 	mov 	r3, #0 	////Init to 0 for now, not yet using it

// 	// offset	.req	r4
// 	xValue_r	.req	r0
// 	yValue_r	.req	r1
// 	colour_r	.req	r2
// 	offset_r	.req	r3
// 	temp_r 		.req	r4

// 	// offset = (y * 1024) + x = x + (y << 10)
// 	// add		offset,	r0, r1, lsl #10
// 	add		offset_r,	xValue_r, yValue_r, lsl #10
// 	// offset *= 2 (for 16 bits per pixel = 2 bytes per pixel)
// 	lsl		offset_r, #1

// 	// store the colour (half word) at framebuffer pointer + offset

// 	ldr		temp_r, =FrameBufferPointer
// 	ldr		temp_r, [temp_r]
// 	strh	colour_r, [temp_r, offset_r]

// 	//unreq everything
// 	.unreq xValue_r
// 	.unreq yValue_r	
// 	.unreq colour_r	
// 	.unreq offset_r	
// 	.unreq temp_r 		

// 	pop		{r4}
// 	bx		lr

// .section .data  

//The type of element that will be drawn.
// 0 = rectangle with a single static colour
// 1 = sprite or image from art.s
// 2 = ascii text to be displayed
// 3 = int text to be displayed
_d_type:
	.byte 0
	.align 4

//specification for end points and colour of a rectangle
//order of x size, y size, colour 
d_rectangle:
	.int 0, 0, 0
	.align 4

//optional.
//changes colour of text to be displayed.
//default is black
d_textColour:
	.int 0
	.align 4

// //address to text that will be displayed
// d_text:
// 	.int 0, 0, 0
// 	.align 4

_font:	.incbin	"font.bin"