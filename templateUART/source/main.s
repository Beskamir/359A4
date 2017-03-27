/*
Assignment 4 by Sebastian Kopacz and Yehonatan Shabash
use of tabs/formatting to indicate loops.
Credits: 
Art: 
	http://www.videogamesprites.net/SuperMarioBros1/
	https://www.spriters-resource.com/nes/supermariobros/
Optimization: 
	http://www.valvers.com/open-software/raspberry-pi/step05-bare-metal-programming-in-c-pt5/
*/

// .extern	snes
// .extern UpdateScreen
// .include "snes"

.section    .init
// .include "Graphics.s"
// .include "art.s"
.globl    	_start
// .globl 		coreState

_start:	
    b       main
    
.section .text

main:
    mov		sp, #0x8000 // Initializing the stack pointer
	bl		EnableJTAG 	// Enable JTAG
	bl		InitUART 	//This is important to be  able to use UART

	bl 		InitFrameBuffer //Enable Frame Buffer
	bl		init_GPIO	//Enable the GPIO pins

	bl f_tests

	b haltLoop$


	/// In theory this will stop the cpu's from fighting over resources
	//and make things faster
	ldr r0,=0x4000008C
	ldr r1,=_f_core1Init
	str r1,[r0,#0x10]
	ldr r1,=_f_core2Init
	str r1,[r0,#0x20]
	ldr r1,=_f_core3Init
	str r1,[r0,#0x30]


	ldr sp,=0xFFFF //Must be unique for CPU0

	bl 	_f_enableCache //should help with performance

	_core0_loop:

		bl f_tests //Test code here
		//core 0 code here
		///End Test Code
		// bl MainMenu //branch to main menu
		// mov r4,r0
		///Keep looping this until the game ends or user quits
		// _runningLoop:
			//code that executes every frame here
		//cmp r0, #0 //check if quite message from menu
		//some kind of compare to check whether to keep looping.
		b haltLoop$ //go to halt loop if quit

	b _core0_loop
///Test Code

_f_core1Init:
	//Set up core 1
	bl _f_enableCache
	// MRC p15,0,r0,c1,c0,0
	// ORR r0,#0x0004
	// ORR r0,#0x0800
	// ORR r0,#0x1000
	// MCR p15,0,r0,c1,c0,0
	mrc p15,0,r0,c1,c0,2
	orr r0,#0x300000
	orr r0,#0xC00000
	mrc p15,0,r0,c1,c0,2
	mov r0,#0x40000000
	// vmsr fpexc,r0
	ldr sp,=0xFFF //Must be unique for CPU1
	_core1_Loop:
			//core 1 code here
		b _core1_Loop

_f_core2Init:
	//Set up core 2
	bl _f_enableCache
	// MRC p15,0,r0,c1,c0,0
	// ORR r0,#0x0004
	// ORR r0,#0x0800
	// ORR r0,#0x1000
	// MCR p15,0,r0,c1,c0,0
	mrc p15,0,r0,c1,c0,2
	orr r0,#0x300000
	orr r0,#0xC00000
	mrc p15,0,r0,c1,c0,2
	mov r0,#0x40000000
	// vmsr fpexc,r0
	ldr sp,=0xFF //Must be unique for CPU2
	_core2_Loop:
			//core 2 code here
		b _core2_Loop

_f_core3Init:
	//Set up core 3
	bl _f_enableCache
	// MRC p15,0,r0,c1,c0,0
	// ORR r0,#0x0004
	// ORR r0,#0x0800
	// ORR r0,#0x1000
	// MCR p15,0,r0,c1,c0,0
	mrc p15,0,r0,c1,c0,2
	orr r0,#0x300000
	orr r0,#0xC00000
	mrc p15,0,r0,c1,c0,2
	mov r0,#0x40000000
	// vmsr fpexc,r0
	ldr sp,=0xF //Must be unique for CPU3
	_core3_Loop:
			//core 3 code here
		b _core3_Loop


haltLoop$:	//Halts the program
	b	haltLoop$	//infinite loop




_f_enableCache:
	push {lr}

    .equ    SCTLR_ENABLE_DATA_CACHE,         0x4
    .equ    SCTLR_ENABLE_BRANCH_PREDICTION,  0x800
    .equ    SCTLR_ENABLE_INstrUCTION_CACHE,  0x1000

    // Enable L1 Cache -------------------------------------------------------

    // R0 = System Control Register
    mrc p15,0,r0,c1,c0,0

    // Enable caches and branch prediction
    orr r0,#SCTLR_ENABLE_BRANCH_PREDICTION
    orr r0,#SCTLR_ENABLE_DATA_CACHE
    orr r0,#SCTLR_ENABLE_INstrUCTION_CACHE

    // System Control Register = R0
    mcr p15,0,r0,c1,c0,0

	push {pc}

.globl d_coreState
.section .data  
// d_coreState:
// 	.int 0

// .align 4
// font: .incbin "font.bin"
