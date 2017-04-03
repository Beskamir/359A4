//Math library for our project
.section	.init

.globl	f_modulo
.globl	f_digToASCII
.globl	f_getClock
.globl	d_clock
.globl	f_random

/*Input: 
	r0, first register to combine
	r1, second register to combine
Output: 
	r0, combined registers 
		form 0xFFFFFFFF where 
		first 4 bits are first register 
		last 4 bits are second register
Effect: 
	Null
*/
.globl f_combineRegisters

.section	.text

//Input: Value to find mod of in r0, divisor in r1
//Output: r0 = round(r0 / r1), r1 = r0 % r1
//Effect: Null
f_modulo:
	push	{r4-r7, lr}				//Push the registers onto the stack
	mov		r4, r0					//Move the number into a safe register
	mov		r5, r1					//Move the divisor into a safe register
	//Rounded division value will be in r6
	//Value to sub by will be in r7
	
	sdiv	r6, r4, r5				//Divide value by divisor (answer in r6 will be rounded)
	mul		r7, r6, r5				//Multiply r6 by divisor
	sub		r1, r4, r7				//Store the different between the original number and the number with the last digit rounded down
	mov		r0, r6					//Move the result in r0 to be returned
	
	pop		{r4-r7, pc}				//Pop the old registers and return

	
//Input: Digit (0-9) to convert to ASCII in r0
//Output: ASCII code of digit in r0
//Effect: Null
f_digToASCII:
	push	{r4-r5, lr}			//Push the registers onto the stack
	
	mov		r4, r0				//Save in the input in r4
	mov		r5, #48				//48 is the default ASCII number offset
	add		r0, r4, r5			//Add the ascii number offset to the number entered
	
	pop		{r4-r5, pc}			//Pop the old registers and return


/*
Input: 
	r0, first register to combine
	r1, second register to combine
Output: 
	r0, combined registers 
		form 0xFFFFFFFF where 
		first 4 bits are first register 
		last 4 bits are second register
Effect: 
	Null
*/
f_combineRegisters:
	push {lr}			//Push the registers onto the stack
	
	lsl r0, #16
	orr	r0, r1
	
	pop	{pc}			//Pop the old registers and return
	
//Input: Null
//Output: Null
//Effect: Update the value of the mod clock
f_updateClock:
	push	{r4-r6, lr}				//Push the registers onto the stack
	
	ldr		r4, =0x20003004			//Load address of CLO
	ldr		r5, [r4]				//Load CLO
	lsr		r5, #6					//Shift right by 6 to get half-second intervals
	ldr		r6, =d_clock			//Load our clock address
	str		r5, [r6]				//Store the new value of the mod clock
	
	pop		{r4-r6, pc}				//Pop the old registers and return

//Input: r0 - the modulo value, entering 0 returns without applying any modulo
//Output: r0 - How many half-seconds have passed, modulo the input
//Effect: Null
f_getClock:
	push	{r4-r5, lr}				//Push the registers onto the stack
	
	mov		r4, r0					//Move the mod value to a safe register
	ldr		r5, =d_clock			//Load the clock address
	tst		r4, #0					//Did the user enter 0?
	ldr		r0, [r5]				//Load the clock value into r0
	beq		getClockEnd				//If the user entered 0, return
	mov		r1, r4					//Move the mod value in r1
	bl		f_modulo				//Call modulo
	mov		r0, r1					//Return the modulo value
	
	getClockEnd:
	pop		{r4-r5, pc}				//Pop the old registers and return

/*
Random Generator Function:
Input: null
Output: 
	r0, the random number generated in range (0 to 31)
Effect: Null
*/
f_random:
	// Push r4 to r8 ( you need 5 registers for x,y,z,w and t)
	push {r4-r9, lr}	//Push registers to the stack
	
	//r4 = t
	//r5 = w
	//r6 = x
	//r7 = y
	//r8 = z
	
	// load x,y,z,and w integer values from memory
	ldr	r4, =_d_w
	ldr	r5, [r4]
	ldr	r4, =_d_x
	ldr	r6, [r4]
	ldr	r4, =_d_y
	ldr	r7, [r4]
	ldr	r4, =_d_z
	ldr	r8, [r4]

	// move x to t
	mov	r4, r6
	// xor t by using the following instruction (eor t, t, t, lsl #11)
	eor	r4, r4, r4, lsl #11
	// xor it again using 8 instead of 11
	eor	r4, r4, r4, lsl #8
	// move y to x
	mov	r6, r7
	// move z to y
	mov	r7, r8
	// move w to z
	mov	r8, r5
	// then xor w (eor t, t, t, lsl #19)
	eor r5, r4, r4, lsl #19
	mov r5, r4
	// xor w with t
	// then store value of x in its place in memory( do the same for y z and w)
		// This is made so that they are updated every time and to make it randomly and not every time is based on their initialized
	
	mov r9, r5 //store
	
	//Shift the values
	ldr	r4, =_d_w
	str	r5, [r4]
	ldr	r4, =_d_x
	str	r6, [r4]
	ldr	r4, =_d_y
	str	r7, [r4]
	ldr	r4, =_d_z
	str	r8, [r4]

	mov r0, r9
	mov r1, #32
	bl f_modulo
	// return some value from 0 to 31
	
	pop		{r4-r9, pc}	//Pop register from the stack and return


.section .data

d_clock: .word

.align 4
// Create 4 labels in the data section each having an integer value
// example: x: .int 5000
// Make sure the number you chose is less than 2^64
// You should create labels for y, z and w each with different integer value
_d_w: .int 1605
_d_x: .int 8201
_d_y: .int 3955
_d_z: .int 9602