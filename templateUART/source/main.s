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

.section    .init
.globl    	_start

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
	
	bl 		initGraphics //initialize needed arrays

	bl _f_enableCache

	//TestCode
		bl f_tests3
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
