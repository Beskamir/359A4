//This file contains or directly accesses all of the graphics related stuff

/*
**Function**
input: null
return: null
effect: place for test code
*/
.globl f_tests

    
.section .text

f_tests:
	push {r4-r10, fp, lr}

	ldr r0, =0x000F
	bl f_colourScreen

	bl f_playingState

	// // ldr r0, =0x0FF0
	// ldr	r6,	=1000		//Width of screen
	// ldr	r7,	=500		//Height of the screen
	// ldr	r8,	=0x0FF0		//colour to set entire screen to
	
	// mov r9, #0
	// ldr r9, =d_rectangle	
	// stmia r9, {r6-r8}	//store in order of x, y, colour

	// ldr r0, =d_rectangle
	// mov r1, #32
	// mov r2, #100
	// mov r3, #0 
	// bl f_drawElement
	// bl f_playingState

	///Buggy 9001: Probably fixed now
		//After x loops during the drawing stuff it goes back to 
		//the start of the screen rather than stay at the position it 
		//should be at. 
	// ie: 	....00000000...
	//		000000000000...
	//		000000000000...
	//vs:	....00000000...
	//		....00000000...
	//		....00000000...
	// 0s are the pixels that are on, . are stuff that shouldn't be drawn

	pop {r4-r10, fp, lr}
	bx	lr

.section .data  
