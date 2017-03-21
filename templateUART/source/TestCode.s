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

	ldr r0, =0x0F0F
	bl f_colourScreen

	bl f_playingState

	pop {r4-r10, fp, lr}
	bx	lr

.section .data  
