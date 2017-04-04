//This file handles the value pack

.section		.init

.globl			f_valuePack

.section		.text


f_valuePack:
	push	{r4-r10, lr}	//Push the registers onto the stack

	randomNumberX_r .req r4
	randomNumberY_r .req r5
	cameraOffset_r 	.req r6

	mov randomNumberY_r, #21


	///Add timer to value pack

	bl f_random
	mov randomNumberX_r, r0

	ldr cameraOffset_r, =d_cameraPosition
	ldr cameraOffset_r, [cameraOffset_r]

	//compute convert screen based random value into a map based value
	add randomNumberX_r, cameraOffset_r

	//check that the value pack isn't in something else
	ensureValuePackIsAccessable:
		sub randomNumberY_r, #1

		mov r0, randomNumberX_r
		mov r1, randomNumberY_r
		ldr r2, =d_mapForeground
		mov r3, #0
		bl f_getCellElement
		cmp r0, #0
		bne ensureValuePackIsAccessable

		mov r0, randomNumberX_r
		mov r1, randomNumberY_r
		ldr r2, =d_mapMiddleground
		mov r3, #0
		bl f_getCellElement
		cmp r0, #0
		bne ensureValuePackIsAccessable

	//store the value pack in the middle map for the next frame
	mov r0, randomNumberX_r
	mov r1, randomNumberY_r
	ldr r2, =d_mapMiddleground
	mov r3, #110
	bl f_setCellElement

	.unreq randomNumberX_r
	.unreq randomNumberY_r
	.unreq cameraOffset_r

	pop		{r4-r10, pc}				//Pop the old registers and return


.section		.data

