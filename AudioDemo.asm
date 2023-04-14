; AudioDemo.asm
; demonstrates function of the peripheral!

ORG 0

Init:
	IN Switches
	STORE Threshold
	
	LOAD Threshold
	OUT	Hex1
	OUT Sound
    
	CALL Delay
	
    IN Sound
    OUT Hex0
    
JUMP Init

	
; the Delay "function"
Delay:
	OUT    Timer
WaitingLoop:
	IN     Timer
	ADDI   -5
	JNEG   WaitingLoop
	RETURN

; Variables
Threshold: DW 0

; IO address constants
Switches:  EQU 000
LEDs:      EQU 001
Timer:     EQU 002
Hex0:      EQU 004 ; The one with 4 digits
Hex1:      EQU 005 ; The one with 2 digits
Sound:     EQU &H50