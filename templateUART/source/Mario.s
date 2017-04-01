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
	
	
//Input:
	//r0: -1 to move Mario to the left, 0 to stay, 1 to move Mario to the right
	//r1: 0 for no jump, 1 for jump
//Output: Null
//Effect: Moves Mario in the specified direction	
f_moveMario:
	push	{r4-r10, lr}					//Push all the general purpose registers along with fp and lr to the stack

	mov		r4, r0							//Save the X offset in a safe register
	mov		r5, r1							//Save the Y instruction in a safe register
	
	//Y movement
	ldr		r6, =verticalState				//Load the address of the vertical state in r6
	ldrb	r7, [r6]						//Load the value of the vertical state
	cmp		r7, #0							//Compare the vertical state to 0
	bgt		jumping							//If the value is positive, Mario is jumping, so no need to worry about falling
	bl		isMarioFalling					//Check if Mario should be falling
	mov		r0, r8
	cmp		r8, #1							//Is Mario falling?
	bne		doneYMovement					//If Mario is not falling (or jumping) then we're done with Y movement
	//Code for falling here
	
	doneYMovement:
	
	//X movement
	cmp		r4, #0							//Compare X offset to 0
	beq		noXMovement						//If they're equal, branch to skip the X movement
	ldr		r6, =_d_marioPositionX			//Load the address of Mario's X position
	ldrh	r7, [r6]						//Load Mario's current X position
	add		r7, r4							//Add the offset to Mario's current X position
	strh	r7, [r6]						//Store Mario's new X position
	
	noXMovement:
	
	
	
	

	pop		{r4-r10, pc}					//Return all the previous registers and return
	
//Input: Null
//Output: r0 - 0 for no, 1 for yes
//Effect: Null
_f_isMarioFalling:
	push	{r4-r10, lr}					//Push all the general purpose registers along with fp and lr to the stack

	//Code required
	
	pop		{r4-r10, pc}					//Return all the previous registers and return
	
	
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