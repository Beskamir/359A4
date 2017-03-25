//Contains all the strings that will be displayed to the game screen.
// the "/" indicates the end of the string. This may make things easier.
.globl t_scoreLabel
.globl t_livesLabel
.globl t_coinsLable
.globl d_numToPrint

.section .text
.align 4
t_scoreLabel:
	.ascii "MARIO/"

.align 4
t_livesLabel:
	.ascii "LIVES x /"

.align 4
t_coinsLable:
	.ascii "x /"


.section .data

.align 4
d_numToPrint:
	.int 0