///Assignment 4 by Sebastian Kopacz and Yehonatan Shabash
//use of tabs/formatting to indicate loops.

// .extern	snes
// .extern UpdateScreen
// .include "snes"

.section    .init
.include "Graphics.s"
.globl     _start

_start:	
    b       main
    
.section .text

main:
    mov		sp, #0x8000 // Initializing the stack pointer
	bl		EnableJTAG 	// Enable JTAG
	bl		InitUART 	//This is important to be  able to use UART

	// bl InitFrameBuffer1
	bl InitFrameBuffers

	// bl MainMenu
	// mov r4,r0

///Keep looping this until the game ends or user quits
PlayingLoop:

	bl UpdateScreen

	//Code here

	// b PlayingLoop

	// b haltLoop$

haltLoop$:	//Halts the program
	b	haltLoop$	//infinite loop


.section .data  

.align 4
font: .incbin "font.bin"
// snes: .incbin "snes.bin"
// framebuffer: .incbin "framebuffer.bin"
