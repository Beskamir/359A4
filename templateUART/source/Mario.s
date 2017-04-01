//This file handles Mario stuff, mainly relating to movement

.section		.init

.globl			f_resetMarioPosition		//Reset Mario's position (in registers, not in the map)
.globl			f_moveMarioX				//Move Mario horizontally (in map and registers)
.globl			f_moveMarioY				//Move Mario Vertically

.section		.text

//Input: Null
//Output: Null
//Effect: Reset's Mario's position back to where he starts at the beginning of the game
f_resetMarioPosition:
	push	{r4-r10, lr}					//Push all the general purpose registers along with fp and lr to the stack
	
	ldr		r4, =_t_marioDefaultPositionX	//Store the address of Mario's default X position
	ldr		r5, =_t_marioDefaultPositionY	//Store the address of Mario's default Y posiion
	ldrh	r6, [r4]						//Load Mario's default x position
	ldrh	r7, [r5]						//Load Mario's default y position
	
	ldr		r4, =_d_marioPositionX			//Store the address of Mario's current X position
	ldr		r5, =_d_marioPositionY			//Store the address of Mario's current Y posiion
	strh	r6, [r4]						//Set Mario's X position to the default
	strh	r7, [r5]						//Set Mario's Y position to the default
	
	pop		{r4-r10, pc}					//Return all the previous registers and return
	
	
//Input: -1 to move Mario to the left, 1 to move Mario to the right
	
	
f_moveMarioX:

	
_t_marioDefaultPosition:
_t_marioDefaultPositionX:	.hword 2
_t_marioDefaultPositionY:	.hword 21
	
	
	
.section		.data

//Jump/Fall state register, stores whether Mario
_verticalState:		.byte 0

//Mario's coordinates in the map
_d_marioPosition:
_d_marioPositionX:	.hword 2
_d_marioPositionY:	.hword 21