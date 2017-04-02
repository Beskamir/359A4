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
.extern c_init_frameBuffer
.extern c_f_clockBoost
.extern c_f_clockLower

.section    .init
// .include "Graphics.s"
// .include "art.s"
.globl    	_start

// .globl 		coreState

_start:	
    b       main
    
.section .text

main:

	//Idea for initing cores, move this code after they've been activated. Also test using print console debugging
    mov		sp, #0x8000 // Initializing the stack pointer
	bl		EnableJTAG 	// Enable JTAG
	bl		InitUART 	//This is important to be  able to use UART

	// bl 		InitFrameBuffer //Enable Frame Buffer
	bl 		c_init_frameBuffer	//inits frame buffer 
	bl		init_GPIO	//Enable the GPIO pins

	bl 		c_f_clockBoost //boost the core speed

	/*
		Following bit of code from:
		https://github.com/PeterLemon/RaspberryPi/blob/master/NEON/Fractal/Julia/kernel7.asm
		In theory should move the other 3 cores to do nothing
	*/
	// Return CPU ID (0..3) Of The CPU Executed On
	mrc p15,0,r0,c0,c0,5 // R0 = Multiprocessor Affinity Register (MPIDR)
	ands r0, #3 // R0 = CPU ID (Bits 0..1)
	bne haltLoop$ // IF (CPU ID != 0) Branch To Infinite Loop (Core ID 1..3)
	/// In theory this will stop the cpu's from 
	//	fighting over resources and make things faster
	// ldr r0,=0x4000008C
	// ldr r1,=_f_core1Init
	// str r1,[r0,#0x10]
	// ldr r1,=_f_core2Init
	// str r1,[r0,#0x20]
	// ldr r1,=_f_core3Init
	// str r1,[r0,#0x30]

	bl _f_enableCache

	//TestCode
		bl f_tests3
		b _endProgram
	///Test Code

	//actual code
	_core0_loop:
		//core 0 code here
		bl f_mainMenu
		cmp r0, #0
		beq _endProgram 
			bl f_playingState //third test file
			b _core0_loop

	b _core0_loop
////End of Actual coreLoop
//call this when program ends
_endProgram:
	bl c_f_clockLower
	b haltLoop$

haltLoop$:	//Halts the program
	b	haltLoop$	//infinite loop

///Should enable cache and make things faster
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
