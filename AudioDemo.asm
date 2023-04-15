; AudioDemo.asm
; Created 2023
; Levi Tucker, George Lee, Edmond Li, Isaac Chia, Edward Kwak
; Demonstrates functionality of the AudioMonitor peripheral.

ORG 0

Init:
	; get threshold as hex data from switches
	IN Switches
	STORE Threshold
	
	; display threshold level on 2-digit hex
	LOAD Threshold
	OUT	Hex1
	OUT Sound
    
	; delay to demonstrate SCOMP doesn't need to constantly
	; poll the peripheral for clap data
	CALL Delay
	
	; get clap data from peripheral and display on 4-digit hex
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
