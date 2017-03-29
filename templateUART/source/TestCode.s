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

		ldr r0, =0x0
		bl f_colourScreen


		bl f_playingState


		// bl f_mainMenu

	// // //basic clear screen function, test if colour screen works
	// 	ldr r0, =0x64FE
	// 	bl f_colourScreen

	// //draw the background map bypassing playingState using the drawMap function
	// 	ldr r0, =t_mapBackground
	// 	ldr r1, =t_cameraPosition
	// 	bl f_drawMap

	// 	ldr r0, =t_mapForeground
	// 	ldr r1, =t_cameraPosition
	// 	bl f_drawMap

		// bl f_playingState

	pop {r4-r10, pc}

.section .data  
