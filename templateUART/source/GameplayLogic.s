//This file contains all the game logic

// .extern	snes
// .extern UpdateScreen
// .include "snes"

/*
**Function**
Keep looping this until the game ends or user quits
input: null
return: null
effect: main loop function in gameplay logic.
*/
.globl playingState


.section    .init
    
.section .text

/*
Keep looping this until the game ends or user quits
input: null (in future could have something to stop _copyMap from executing)
return: null
effect: main loop function in gameplay logic.
*/
playingState:
	push {r4-r10, fp, lr}

	bl _newGame

	_playingLoop:	//Keep looping until game is over
	
	// b PlayingLoop

	pop {r4-r10, fp, lr}
	bx	lr

_newGame:
	push {r4-r10, fp, lr}
	
	bl _copyMap
	//set all variables in gameState to 0

	pop {r4-r10, fp, lr}
	bx	lr

_copyMap:
	push {r4-r10, fp, lr}
	
	//copy all the elements of the map arrays from .text to .data	

	pop {r4-r10, fp, lr}
	bx	lr

_moveMario:
	push {r4-r10, fp, lr}
	
	//

	pop {r4-r10, fp, lr}
	bx	lr

_updateNPCs:
	push {r4-r10, fp, lr}
	
	//read from the map and check collisions

	pop {r4-r10, fp, lr}
	bx	lr

_updateMap:
	push {r4-r10, fp, lr}
	
	//update map position

	pop {r4-r10, fp, lr}
	bx	lr

_checkColisions:
	push {r4-r10, fp, lr}
	
	//update map position

	pop {r4-r10, fp, lr}
	bx	lr

_drawMap:
	push {r4-r10, fp, lr}
		
	//draw the map using graphics
	

	pop {r4-r10, fp, lr}
	bx	lr

.section .data
_GameState:	
	.byte 0, 0, 0, 0