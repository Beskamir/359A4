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

f_tests3:
	push {r4-r10, lr}

	ldr r0, =0x0
	bl f_colourScreen

	bl f_playingState

	pop {r4-r10, pc}

.section .data  
