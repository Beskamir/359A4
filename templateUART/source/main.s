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

_t_core_stack1: .word 0
_t_core_stack2: .word 0
_t_core_stack3: .word 0

main:

	//Idea for initing cores, move this code after they've been activated. Also test using print console debugging
    mov		sp, #0x8000 // Initializing the stack pointer
	bl		EnableJTAG 	// Enable JTAG
	bl		InitUART 	//This is important to be  able to use UART

	bl 		InitFrameBuffer //Enable Frame Buffer
	bl		init_GPIO	//Enable the GPIO pins


	// b haltLoop$
	// bl f_tests2	//second test file


	/// In theory this will stop the cpu's from fighting over resources
	//and make things faster
	ldr r0,=0x4000008C
	ldr r1,=_f_core1Init
	str r1,[r0,#0x10]
	ldr r1,=_f_core2Init
	str r1,[r0,#0x20]
	ldr r1,=_f_core3Init
	str r1,[r0,#0x30]

	bl _f_enableCache

	//TestCode
		b f_tests3
		b haltLoop$
	///Test Code

	//actual code
	_core0_loop:
		//core 0 code here
		bl f_mainMenu
		cmp r0, #0
		beq haltLoop$ 
			bl f_playingState //third test file
			b _core0_loop

	b _core0_loop
////End of Actual coreLoop

_f_core1Init:
    ldr	sp, =_t_core_stack1 // set stack pointer for core 1

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
	_core1_Loop:
			//core 1 code here
		b _core1_Loop

_f_core2Init:
    ldr	sp, =_t_core_stack2 // set stack pointer for core 2

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
	_core2_Loop:
			//core 2 code here
		b _core2_Loop

_f_core3Init:
    ldr	sp, =_t_core_stack3 // set stack pointer for core 3

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
	_core3_Loop:
			//core 3 code here
		b _core3_Loop


haltLoop$:	//Halts the program
	b	haltLoop$	//infinite loop




_f_enableCache:
	push {lr}

    // Enable L1 Cache -------------------------------------------------------

    // R0 = System Control Register
    mrc p15,0,r0,c1,c0,0

    // Enable caches and branch prediction
    orr r0,#0x4 //enable data cache
    orr r0,#0x800 //enable branch prediction
    orr r0,#0x1000 //enable instruction cache

    // System Control Register = R0
    mcr p15,0,r0,c1,c0,0

	pop {pc}

.globl d_coreState
.section .data  
// d_coreState:
// 	.int 0

// .align 4
// font: .incbin "font.bin"
