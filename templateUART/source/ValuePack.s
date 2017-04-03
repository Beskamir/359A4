//This file handles the value pack

.section		.init

.section		.text


//Input: Null
//Output: Random number in r0
//Effect: Null
// Random Generator Function (No need for Parameters):
_f_RNG:
	// Push r4 to r8 ( you need 5 registers for x,y,z,w and t)
	push	{r4-r8, lr}	//Push registers to the stack
	
	//r4 = t
	//r5 = w
	//r6 = x
	//r7 = y
	//r8 = z
	
	// load x,y,z,and w integer values from memory
	ldr		r4, =_d_w
	ldr		r5, [r4]
	ldr		r4, =_d_x
	ldr		r6, [r4]
	ldr		r4, =_d_y
	ldr		r7, [r4]
	ldr		r4, =_d_z
	ldr		r8, [r4]
	// move x to t
	mov		r4, r6
	// xor t by using the following instruction (eor t, t, t, lsl #11)
	eor		r4, r4, r4, lsl #11
	// xor it again using 8 instead of 11
	eor		r4, r4, r4, lsl #8
	// move y to x
	mov		r6, r7
	// move z to y
	mov		r7, r8
	// move w to z
	mov		r8, r5
	// then xor w (eor t, t, t, lsl #19)
	// xor w with t
	// then store value of x in its place in memory( do the same for y z and w)
		// This is made so that they are updated every time and to make it randomly and not every time is based on their initialized
	// return w as the returned value
	
	pop		{r4-r8, pc}	//Pop register from the stack and return

.section		.data

// Create 4 labels in the data section each having an integer value
	// example: x: .int 5000
	// Make sure the number you chose is less than 2^64
	// You should create labels for y, z and w each with different integer value
	_d_w:		.int 1605
	_d_x:		.int 8201
	_d_y:		.int 3955
	_d_z:		.int 9602