//This file contains all the game logic



/*
**Function**
input: byte value from a map
return: address of the sprite at that byte value
effect: only the return.
*/
.globl f_mapByteToArtLabel


.section .init
    
.section .text

/*

*/
f_mapByteToArtLabel:
	push {r4-r10, fp, lr}

	//should be faster to cut the comparisons apart like this 
	cmp r0, #26
		blle _f_firstSubset
		ble _endMapByteToArtLabel
	cmp r0, #53
		blle _f_secondSubset
		ble _endMapByteToArtLabel
	cmp r0, #80
		blle _f_thirdSubset
		ble _endMapByteToArtLabel
	cmp r0, #107
		blle _f_fourthSubset
		ble _endMapByteToArtLabel
	cmp r0, #134
		blle _f_fifthSubset
		ble _endMapByteToArtLabel

	_endMapByteToArtLabel:
	pop {r4-r10, fp, lr}
	bx	lr


///TODO: ugly if comparison statements. Probably best to generate this.
_f_firstSubset:
	push {r4-r10, fp, lr}


	pop {r4-r10, fp, lr}
	bx	lr


_f_secondSubset:
	push {r4-r10, fp, lr}

	
	

	pop {r4-r10, fp, lr}
	bx	lr


_f_thirdSubset:
	push {r4-r10, fp, lr}

	
	

	pop {r4-r10, fp, lr}
	bx	lr


_f_fourthSubset:
	push {r4-r10, fp, lr}

	
	

	pop {r4-r10, fp, lr}
	bx	lr


_f_fifthSubset:
	push {r4-r10, fp, lr}

	
	

	pop {r4-r10, fp, lr}
	bx	lr


.section .data
