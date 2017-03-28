//This file contains or directly accesses all of the graphics related stuff

/*
**Function**
input: null
return: null
effect: place for test code
*/
.globl f_tests1
.globl f_tests2
.globl f_tests3

    
.section .text
// f_tests1:
// 	push {r4-r10, lr}

// 	//basic clear screen function, test if colour screen works
// 		ldr r0, =0xFFFF
// 		bl f_colourScreen

// 	pop {r4-r10, pc}


// f_tests2:
// 	push {r4-r10, lr}

// 	//basic clear screen function, test if colour screen works
// 		ldr r0, =0xFFF0
// 		bl f_colourScreen

// 	pop {r4-r10, pc}

f_tests3:
	push {r4-r10, lr}

	// //basic clear screen function, test if colour screen works
	// 	ldr r0, =0xF500
	// 	bl f_colourScreen

	// //test draw a rectangle with coordinates (32,100) and (832,600)
	// //test if draw rectanlge works
	// 	ldr	r6,	=800		//rectangle's width
	// 	ldr	r7,	=500		//rectangle's height
	// 	ldr	r8,	=0x0FF0		//colour to set entire screen to
		
	// 	mov r9, #0
	// 	ldr r9, =d_rectangle	
	// 	stmia r9, {r6-r8}	//store in order of x, y, colour

	// 	ldr r0, =d_rectangle
	// 	mov r1, #32
	// 	mov r2, #100
	// 	mov r3, #0 
	// 	bl f_drawElement

	//basic clear screen function, test if colour screen works
		ldr r0, =0x64FE
		bl f_colourScreen


		bl f_mainMenu


		// ldr r0, =t_Brickt_0_0 //add the address of s_artSpritesAccess to the "offset" in r0
		// //Now r0 has address of sprite to draw
		// // mul r1, xCounter_r, cellsize_r//compute starting x value for the image
		// mov r1, #0
		// // mul r2, yCounter_r, cellsize_r //compute starting y value for the image
		// mov r2, #0
		// mov r3, #1	//indicate that an image is being drawn
		// bl f_drawElement

		// ldr r0, =t_Brickt_0_0 //add the address of s_artSpritesAccess to the "offset" in r0
		// //Now r0 has address of sprite to draw
		// // mul r1, xCounter_r, cellsize_r//compute starting x value for the image
		// mov r1, #50
		// // mul r2, yCounter_r, cellsize_r //compute starting y value for the image
		// mov r2, #70
		// mov r3, #1	//indicate that an image is being drawn
		// bl f_drawElement


		// ldr r0, =t_BushDouble_0_0 //add the address of s_artSpritesAccess to the "offset" in r0
		// //Now r0 has address of sprite to draw
		// // mul r1, xCounter_r, cellsize_r//compute starting x value for the image
		// mov r1, #100
		// // mul r2, yCounter_r, cellsize_r //compute starting y value for the image
		// mov r2, #300
		// mov r3, #1	//indicate that an image is being drawn
		// bl f_drawElement

	// //draw the background map bypassing playingState using the drawMap function
	// 	ldr r0, =t_mapBackground
	// 	ldr r1, =t_cameraPosition
	// 	bl f_drawMap

	//test playing state which includes cloning the elements from .text to .data
	//and displying the maps
		// bl f_playingState	//may wish to disable if it doesn't work


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

	pop {r4-r10, pc}

.section .data  
