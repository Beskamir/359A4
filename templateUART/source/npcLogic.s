//This file contains all the npc/ai logic.
//	subset of gameplay logic

/*
Input: null
Return: null
Effect: updates the AIs (enemies and items count as AIs)
*/
.globl f_updateAIs




.section    .init
    
.section .text


/*
Input: null
Return: null
Effect: updates the AIs (enemies and items count as AIs)
*/
f_updateAIs:
	push {lr}

	//Update everything in the middle layer. 
	//	(aka animate the coins, move powerups, etc)
	ldr r0, =d_mapMiddleground
	mov r1, #0
	bl _f_updateNPCsOnSpecifiedMap

	//Update the AI's (enemies) in the top layer
	ldr r0, =d_mapForeground
	mov r1, #1
	bl _f_updateNPCsOnSpecifiedMap

	pop {pc}

/*
Input:
	r0, map to scan
	r1, which map we're dealing with
Return: null
Effect: finds and updates the AIs on the map specified
*/
_f_updateNPCsOnSpecifiedMap:
	push {r4-r10, lr}

	cellCheckedX_r 	.req r4
	cellCheckedY_r	.req r5

	isAI_r			.req r6

	mapLayerMem_r	.req r7
	isTopLayer		.req r8


	//keep track of which cells had an AI checked for
	mov cellCheckedX_r, #0
	mov cellCheckedY_r, #0

	mov mapLayerMem_r, r0 //store the passed in map address
	mov isTopLayer, r1 //"boolean" for checking which layer it is. 0=middleMap, 1=firstMap


	_AIsearchLoop:
		//restore from memory
		mov r0, cellCheckedX_r
		mov r1, cellCheckedY_r
		mov r2, mapLayerMem_r
		//Read the map
		bl _f_findItemOrNPC 
		//Store following for ease of use and memory
		mov cellCheckedX_r, r0
		mov cellCheckedY_r, r1
		//store following for ease of use
		mov isAI_r, r2

		cmp isAI_r, #0 //End if no more AIs on screen
		beq _NoMoreAIs
		//else:
			mov r3, mapLayerMem_r

			cmp isTopLayer, #0
			beq	_isItem
				//is enemy AI
				cmp isAI_r, #89 //isAI_r > 89: branch _isAdvanceAI
				bgt _isAdvanceAI
					bl _f_moveBasicAI //branch to basic AI movement
					b _AIsearchLoop
					//return to top of loop

				_isAdvanceAI:
					bl _f_moveAdvanceAI //branch to advance AI movement
					b _AIsearchLoop
					//return to top of loop

			_isItem:
				//is item
				cmp isAI_r, #110 //isAI_r > 110: branch _isStaticItem
				bgt _isStaticItem
					bl _f_moveItem //branch to item movement (powerup drifting)
					b _AIsearchLoop
					//return to top of loop

				_isStaticItem:
					bl _f_moveStaticItem //branch to static movement (animation)
					b _AIsearchLoop
					//return to top of loop

	_NoMoreAIs:

	//Unreq everything that was used in this subroutine
	.unreq cellCheckedX_r 
	.unreq cellCheckedY_r 
	.unreq isAI_r 
	.unreq mapLayerMem_r 
	.unreq isTopLayer


	pop {r4-r10, pc}



/*
Input:
	r0, element's x cell value (screen space based)
	r1, element's y cell value (screen space based)
	r2, Basic AI map value (83<=basic<=89)
	r3, mapLayerMemoryAddress (address of the map being used)
Return:
	null
Effect:
	move or animate the element 
*/
_f_moveBasicAI:
	push {r4-r10, lr}

	cellIndexX_r	.req r4 //x screen index of AI
	cellIndexY_r	.req r5 //y screen index of AI

	mapAddress_r	.req r6 //the address to the map being modified

	cameraOffset_r	.req r7 //the camera offset during this

	// //type of AI that's being dealt with
	aiValue_r		.req r8

	//set to input parameters
	mov cellIndexX_r, r0
	mov cellIndexY_r, r1

	mov aiValue_r, 	  r2 

	//get map address
	mov mapAddress_r, r3
 
 	//load the camera offset
	ldr cameraOffset_r, =d_cameraPosition
	ldr cameraOffset_r, [cameraOffset_r] 

	// add mapAddress_r, cameraOffset_r //offset the access to the map to the correct camera spot
	
	add cellIndexX_r, cameraOffset_r
	mul cellIndexY_r, #320

	//Rename to a more fitting name for following code
	.unreq cameraOffset_r
	mapOffset_r	.req r7 //the camera offset during this

	mov mapOffset_r, cellIndexX_r
	add mapOffset_r, cellIndexY_r

	add mapAddress_r, mapOffset_r


	///TODO:
	//Implement the collision checks and stuff


	pop {r4-r10, pc}

/*
Input:
	r0, element's x cell value (screen space based)
	r1, element's y cell value (screen space based)
	r2, Advance AI map value 90<=advance<=96, 109<=powerup<=110, 111<=coin<=113) 
	r3, mapLayerMemoryAddress (address of the map being used)
Return:
	null
Effect:
	move or animate the element 
*/
_f_moveAdvanceAI:
	push {r4-r10, lr}





	pop {r4-r10, pc}

/*
Input:
	r0, element's x cell value (screen space based)
	r1, element's y cell value (screen space based)
	r2, Static item map value (111<=coin<=113) 
	r3, mapLayerMemoryAddress (address of the map being used)
Return:
	null
Effect:
	move or animate the element 
*/
_f_moveStaticItem:
	push {r4-r10, lr}





	pop {r4-r10, pc}

/*
Input:
	r0, element's x cell value (screen space based)
	r1, element's y cell value (screen space based)
	r2, movable item map value (109<=powerup<=110)
	r3, mapLayerMemoryAddress (address of the map being used)
Return:
	null
Effect:
	move or animate the element 
*/
_f_moveItem:
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
	r2, AI type (0 = null, 83<=basic<=89, 90<=advance<=96, 109<=powerup<=110, 111<=coin<=113) 
Effect: Null
*/
_f_findItemOrNPC:
	push {r4-r10, lr}

	//keep track of which cells had an AI checked for
	cellCheckX_r 	.req r4
	cellCheckY_r	.req r5
	//get correct map offset
	mapAddress_r	.req r6
	cameraOffset_r	.req r7

	//type of AI that's being dealt with
	aiType_r		.req r8

	//set to input parameters
	mov cellCheckX_r, r0
	mov cellCheckY_r, r1

	//get map address
	mov mapAddress_r, r2 
 
 	//load the camera offset
	ldr cameraOffset_r, =d_cameraPosition
	ldr cameraOffset_r, [cameraOffset_r] 

	add mapAddress_r, cameraOffset_r //offset the access to the map to the correct camera spot

	.unreq cameraOffset_r

	_NPCsearchLoop:
		ldrb aiType_r, [mapAddress_r], #1
		//Chekc if AI is an enemy
		cmp aiType_r, #83
		blt _notEnemy 
			cmp aiType_r, #96
			bgt _notEnemy 
				b _foundNPC //found an enemy AI and returned it

		//check if "AI" is an item
		_notEnemy:
		cmp aiType_r, #109
		blt _notItem //skip drawing process if equal. 0 means theres no image there
			cmp aiType_r, #113
			bgt _notItem //skip drawing process if equal. 0 means theres no image there
				b _foundNPC

		_notItem:
		add cellCheckX_r, #1	//increment x cell count by 1
		cmp cellCheckX_r, #32
		beq _NPCsearchLoop
		mov cellCheckX_r, #0

		add cellCheckY_r, #1 //increment y cell count by 1
		add mapAddress_r, #288 //map is 320 cells wide, so 320-32=288 which is the offset
		cmp cellCheckY_r, #28
		beq _NPCsearchLoop

		mov aiType_r, #0 //if last cell and AI type not valid then set to 0

	_foundNPC:
		mov r0, cellCheckX_r
		mov r1, cellCheckY_r
		mov r2, aiType_r

	.unreq cellCheckX_r
	.unreq cellCheckY_r
	.unreq mapAddress_r
	.unreq aiType_r

	pop {r4-r10, pc}

.section .data

