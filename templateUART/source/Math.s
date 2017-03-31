//Math library for our project
.section	.init

.globl	f_modulo
.globl	f_digToASCII

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