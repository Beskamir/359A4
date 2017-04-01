//Math library for our project
.section	.init

.globl	f_modulo
.globl	f_digToASCII
.globl	f_getClock
.globl	d_clock

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
	cmp		r4, #0					//Did the user enter 0?
	ldr		r0, [r5]				//Load the clock value into r0
	beq		getClockEnd				//If the user entered 0, return
	mov		r1, r4					//Move the mod value in r1
	bl		f_modulo				//Call modulo
	mov		r0, r1					//Return the modulo value
	
	getClockEnd:
	pop		{r4-r5, pc}				//Pop the old registers and return
	
.section		.data

d_clock:	.word