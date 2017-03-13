///Assignment 4 by Sebastian Kopacz and Yehonatan Shabash
//use of tabs/formatting to indicate loops.

// .extern	snes
// .extern UpdateScreen
.include snes.s 
.include UpdateScreen.s 

.section    .init
.globl     _start

_start:	
    b       main
    
.section .text

main:
    mov		sp, #0x8000 // Initializing the stack pointer
	bl		EnableJTAG 	// Enable JTAG
	bl		InitUART 	//This is important to be  able to use UART

	
	//Code here


	b haltLoop$

haltLoop$:	//Halts the program
	b	haltLoop$	//infinite loop

.section .data  

.align 4
font: .incbin "font.bin"
// snes: .incbin "snes.bin"
// framebuffer: .incbin "framebuffer.bin"
