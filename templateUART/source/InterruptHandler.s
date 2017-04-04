//This file handles interrupts

.section	.init
.globl	InstallIntTable		
.globl	f_EnableIRQ		

.section	.text
//Input: null
//Output: null
//Effect: Set up interrupts
//Usage: Should be the first instruction in the program
// InitInterrupts:
// 	push	{r4-r10, lr}		//Push registers onto stack
// 	// bl		InstallIntTable		//Install the interrupt tabel
// 	// bl		EnableIRQ			//Enable IRQ interrupt
// 	pop		{r4-r10, pc}		//Pop registers from stack

//Input: null
//Output: null
//Effect: installs the interrupt table
InstallIntTable:
	push	{r4-r10, lr}		//Push registers onto stack
	ldr		r0, =IntTable
	mov		r1, #0x00000000

	// load the first 8 words and store at the 0 address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// load the second 8 words and store at the next address
	ldmia	r0!, {r2-r9}
	stmia	r1!, {r2-r9}

	// switch to IRQ mode and set stack pointer
	mov		r0, #0xD2
	msr		cpsr_c, r0
	mov		sp, #0x8000

	// switch back to Supervisor mode, set the stack pointer
	mov		r0, #0xD3
	msr		cpsr_c, r0
	mov		sp, #0x8000000

	pop		{r4-r10, pc}		//Pop registers from stack
	

//Input: null
//Output: null
//Effect: enables IRQ
f_EnableIRQ:
	push	{r4-r10, lr}			//Push registers onto stack
	
	//a		Update timer value
	ldr		r4, =0x20003004			//Load address of CLO
	ldr		r5, [r4]				//Load CLO
	ldr		r6, =30000000			//Load the number 30 million
	add		r5, r6					//Add a delay of 30 million microseconds (30 seconds)
	add		r4, #12					//Add 12 to get to timer compare 1
	str		r5, [r4]				//Store the address
	
	//b.	For IRQ
	ldr		r4, =0x3F00B210			//Load the address
	ldr		r0, [r4]				//Load the value in 0x3F00B210 and put it in r0
	mov		r1, #10					//Move 10 to r1
	str		r1, [r0]				//Store the value of r1 in r0
	
	//c.	Disable all other interrupts
	ldr		r4, =0x3F00B214			//Load the address
	ldr		r0, [r4]				//Load the value in 0x3F00B214 and put it in r0
	mov		r1, #0					//Move 0 to r1
	str		r1, [r0]				//Store the value of r1 in r0
	//d.	For cpsr_c register
	//cpsr_c is not defined/equated anywhere. Gonna have to disable this code -SK
	mrs		r0, cpsr				//mrs r0,cpscr
	bic		r0, #0x80				//bic r0, #0x80
	msr		cpsr_c, r0				//msr cpsr_c, r0
	
	pop		{r4-r10, pc}			//Pop register from the stack
	
_f_DoIRQ:
	push	{r4-r10, lr}			//Push registers from the stack
	
	// a. Test if timer1 did the interrupt
		// i. Load the values stored in 0x3F00B204 to r1
		ldr		r4, =0xF00B204
		ldr		r1, [r4]
		// ii. Tst bit 2
		mov		r5, #1
		lsl		r5, #2
		tst		r1, r5
		// iii. If result is zero go to e
		beq		e
	// b. Check if the game was paused
		// i. You should have a label in memory where you store in it if the game is paused or not
		ldr		r4, =d_isPaused
		ldrb	r5, [r4]
		cmp		r5, #1
		// ii. If paused you go to e
		beq		e
	// c. If a,b,c are all valid you draw your value pack.
		bl 		f_valuePack
	// d. Enable CS timer Control
		// i. Load the value stored in 0x3F003000
		ldr		r4, =0x3F003000
		// ii. Put 1 in bit 1 and the rest are zeroes
		mov		r6, #2
		str		r6, [r4]		//Not sure if this should be [r4] or [r5]
	// e. Update time in C1
	e:
	ldr		r4, =0x20003004			//Load address of CLO
	ldr		r5, [r4]				//Load CLO
	ldr		r6, =30000000			//Load the number 30 million
	add		r5, r6					//Add a delay of 30 million microseconds (30 seconds)
	add		r4, #12					//Add 12 to get to timer compare 1
	str		r5, [r4]				//Store the address
	// f. Repeat (2)
	bl		_f_DoIRQ
	// g. Then subs pc, lr, #4
	subs	pc, lr, #4
	
	pop		{r4-r10, pc}		//Pop register from the stack
	
.section	.data
.align
IntTable:
	// Interrupt Vector Table (16 words)
	ldr		pc, reset_handler
	ldr		pc, undefined_handler
	ldr		pc, swi_handler
	ldr		pc, prefetch_handler
	ldr		pc, data_handler
	ldr		pc, unused_handler
	ldr		pc, irq_handler
	ldr		pc, fiq_handler

reset_handler:		.word InstallIntTable
undefined_handler:	.word haltLoop$
swi_handler:		.word haltLoop$
prefetch_handler:	.word haltLoop$
data_handler:		.word haltLoop$
unused_handler:		.word haltLoop$
irq_handler:		.word _f_DoIRQ
fiq_handler:		.word haltLoop$
.align
