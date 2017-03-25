///Assignment 4 by Sebastian Kopacz and Yehonatan Shabash
//use of tabs/formatting to indicate loops.

// .extern	snes
// .extern UpdateScreen
// .include "snes"

.section    .init
// .include "Graphics.s"
// .include "art.s"
.globl    	_start
.globl 		coreState

_start:	
    b       main
    
.section .text

main:
    mov		sp, #0x8000 // Initializing the stack pointer
	bl		EnableJTAG 	// Enable JTAG
	bl		InitUART 	//This is important to be  able to use UART

	bl 		InitFrameBuffer //Enable Frame Buffer
	bl		init_GPIO	//Enable the GPIO pins


///Test Code

	

	
	bl f_tests


///End Test Code

	// bl MainMenu
	// mov r4,r0

///Keep looping this until the game ends or user quits
	_runningLoop:
		//code that executes every frame here




haltLoop$:	//Halts the program
	b	haltLoop$	//infinite loop


.globl d_coreState
.section .data  
d_coreState:
	.int 0


// .align 4
// font: .incbin "font.bin"
