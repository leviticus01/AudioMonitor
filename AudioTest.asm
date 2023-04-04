; AudioTest.asm
; Reads in the output from the peripheral and displays both the count and the threshold level on the hex display

ORG 0
; The lower 4 bits of the audio peripheral output will be incrementing the number of claps by either 1 or 0; the next 4 bits will be the threshold level (1-3)
Init:
	; Get data from the audio peripheral
	IN     Sound
	STORE	Data	; Store the OG data
	; Display most-significant 10 bits of the magnitude on LEDs
	AND	Mask
	ADD	Count
	STORE	Count
	OUT	Hex0
	LOAD	Data
	SHIFT	-4
	STORE 	Data
	AND	Mask
	OUT	Hex1
	; GO to the start of the program
	JUMP   0

; Variables
Count: DW 0
Data:	DW 0
Mask:	DW &H0F
ResetSwitch:	DW 9

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004 ; The one with 4 digits
Hex1:      EQU 005 ; The one with 2 digits
Sound:     EQU &H50
