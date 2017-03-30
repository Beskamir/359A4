//This file contains all the npc/ai logic.
//	subset of gameplay logic


.globl f_updateAIs

.section    .init
    
.section .text

f_updateAIs:
	push {r4-r10, lr}

	mapLayerCount_r	.req r7
	// mapLayerMem_r	.req r8


	mov mapLayerCount_r, #0

	_mapLayer:
		//scan the middle and foreground maps
		cmp mapLayerCount_r, #0
		// ldreq r0, =d_mapMiddleground
		ldrne r0, =d_mapForeground
		bl _f_updateNPCsOnSpecifiedMap

		add mapLayerCount_r, #1
		cmp mapLayerCount_r, #1
		ble _mapLayer

	.unreq mapLayerCount_r 
	// .unreq mapLayerMem_r 
	// .unreq isAI_r 

	pop {r4-r10, pc}

/*
Input:
	r0, map to scan
*/
_f_updateNPCsOnSpecifiedMap:
	push {r4-r10, lr}

	xCellChecked_r 	.req r4
	yCellChecked_r	.req r5
	isAI_r			.req r6
	// mapLayerCount_r	.req r7
	mapLayerMem_r	.req r7


	//keep track of which cells had an AI checked for
	mov xCellChecked_r, #0
	mov yCellChecked_r, #0

	// mov mapLayerCount_r, #0
	mov mapLayerMem_r, r0


	_AIsearchLoop:
		//restore from memory
		mov r0, xCellChecked_r
		mov r1, yCellChecked_r
		mov r2, mapLayerMem_r
		//Read the map
		bl _f_findNPCorItem 
		//Store following for ease of use and memory
		mov xCellChecked_r, r0
		mov yCellChecked_r, r1
		//store following for ease of use
		mov isAI_r, r2

		cmp isAI_r, #0 //End if no more AIs on screen
		beq _NoMoreAIs
			//else:
			cmp isAI_r, #86 //End if no more AIs on screen
			bgt _isAdvanceAI
				bl _f_moveBasicAI //branch to basic AI movement
				b _AIsearchLoop
				//return to top of loop
			_isAdvanceAI:
				bl _f_moveAdvanceAI //branch to advance AI movement
				b _AIsearchLoop
				//return to top of loop

	_NoMoreAIs:

	//Unreq everything that was used in this subroutine
	.unreq xCellChecked_r 
	.unreq yCellChecked_r 
	.unreq isAI_r 
	.unreq mapLayerMem_r 



	pop {r4-r10, pc}

_f_moveBasicAI:
	push {r4-r10, lr}





	pop {r4-r10, pc}

_f_moveAdvanceAI:
	push {r4-r10, lr}





	pop {r4-r10, pc}	

/*
Scans map and finds enemies/items
Input: 
	r0, x cell to start search at
	r1, y cell to start search at
	r2, which map to scan
Return:
	r0, x cell search ended at (cell with AI)
	r1, y cell search ended at (cell with AI)
	r2, AI type (0 = null, 83<=basic<=86, 87<=advance<=90) 
Effect: Null
*/
_f_findNPCorItem:
	push {r4-r10, lr}

	//keep track of which cells had an AI checked for
	xCellCheck_r 	.req r4
	yCellCheck_r	.req r5
	//get correct map offset
	mapOffset_r		.req r6
	cameraOffset_r	.req r7

	//type of AI that's being dealt with
	aiType_r		.req r8

	//set to input parameters
	mov xCellCheck_r, r0
	mov yCellCheck_r, r1

	//get foreground map address
	mov mapOffset_r, r2 
 
 	//load the camera offset
	ldr cameraOffset_r, =d_cameraPosition
	ldr cameraOffset_r, [cameraOffset_r] 

	add mapOffset_r, cameraOffset_r //offset the access to the map to the correct camera spot

	.unreq cameraOffset_r

	_NPCsearchLoop:
		ldrb aiType_r, [mapOffset_r], #1
		//Chekc if AI is an enemy
		cmp aiType_r, #83
		blt _notEnemy 
			cmp aiType_r, #90
			bgt _notEnemy 
				b _foundNPC //found an enemy AI and returned it

		//check if "AI" is an item
		_notEnemy:
		cmp aiType_r, #103
		blt _notItem //skip drawing process if equal. 0 means theres no image there
			cmp aiType_r, #107
			bgt _notItem //skip drawing process if equal. 0 means theres no image there
				b _foundNPC

		_notItem:
		add xCellCheck_r, #1	//increment x cell count by 1
		cmp xCellCheck_r, #32
		beq _NPCsearchLoop
		mov xCellCheck_r, #0

		add yCellCheck_r, #1 //increment y cell count by 1
		add mapOffset_r, #288 //map is 320 cells wide, so 320-32=288 which is the offset
		cmp yCellCheck_r, #28
		beq _NPCsearchLoop

		mov aiType_r, #0 //if last cell and AI type not valid then set to 0

	_foundNPC:
		mov r0, xCellCheck_r
		mov r1, yCellCheck_r
		mov r2, aiType_r

	pop {r4-r10, pc}	

.section .data

