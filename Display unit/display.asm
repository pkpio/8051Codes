org 0000h
ljmp start

;org 0500h
;DB "WEL LAB EE 310"
org 0100h
start: nop
RS EQU P0.0		;Command transfer = 0
RW EQU P0.1				;WRITE = 0
EN EQU P0.2
Dat EQU P2

CLR EN
;MOV Dat, #0ffh

ACALL initDisp
MOV R1, #57h ; ASCII code for 'W'
ACALL dispLetter
MOV R1, #45h ; ASCII code for 'E'
ACALL dispLetter
MOV R1, #4Ch ; ASCII code for 'L'
ACALL dispLetter
MOV R1, #20h ; ASCII code for ' '
ACALL dispLetter
MOV R1, #4Ch ; ASCII code for 'L'
ACALL dispLetter
MOV R1, #41h ; ASCII code for 'A'
ACALL dispLetter
MOV R1, #42h ; ASCII code for 'B'
ACALL dispLetter
MOV R1, #20h ; ASCII code for ' '
ACALL dispLetter
MOV R1, #45h ; ASCII code for 'E'
ACALL dispLetter
MOV R1, #45h ; ASCII code for 'E'
ACALL dispLetter
MOV R1, #20h ; ASCII code for ' '
ACALL dispLetter
MOV R1, #33h ; ASCII code for '3'
ACALL dispLetter
MOV R1, #30h ; ASCII code for '0'
ACALL dispLetter
MOV R1, #39h ; ASCII code for '9'
ACALL dispLetter

MOV R1, #0C0h ; 1100 0000  -- RAM address as 01h
ACALL sendCmd
MOV R1, #50h ; ASCII code for 'P'
ACALL dispLetter
MOV R1, #52h ; ASCII code for 'R'
ACALL dispLetter
MOV R1, #41h ; ASCII code for 'A'
ACALL dispLetter
MOV R1, #56h ; ASCII code for 'V'
ACALL dispLetter
MOV R1, #45h ; ASCII code for 'E'
ACALL dispLetter
MOV R1, #45h ; ASCII code for 'E'
ACALL dispLetter
MOV R1, #4Eh ; ASCII code for 'N'
ACALL dispLetter

;LCD initialize (to line 1)
initDisp: nop
	modeSet: MOV R1, #38h ; 00111000
		ACALL sendCmd
	displayON: MOV R1, #0Eh ; 0000 1110
			ACALL sendCmd
	autoRightCur: MOV R1, #06h ; 0000 0110
			ACALL sendCmd
	clearScreen: MOV R1, #01h ; 0000 0001
			ACALL sendCmd
	setCurPos: MOV R1, #80h ; 1000 0000
			ACALL sendCmd
	RET

;Useful subrountines...
dispLetter: ACALL delay_50ms;busyCheck ; The letter to be displayed should be placed in R1
	setb EN
	setb RS
	clr RW
	MOV Dat, R1
	ACALL clearEN
	RET
	
sendCmd: ACALL delay_50ms;busyCheck ; The letter to be displayed should be placed in R1
	setb EN
	clr RS
	clr RW
	MOV Dat, R1
	ACALL clearEN
	RET
		
busyCheck: clr RS
		setb RW
		JBC Dat.7, busyCheck
		RET
		
clearEn: ACALL delay_50ms
	clr EN
	RET

delay: nop
	
	RET

delay_cjne : INC R0
	MOV 51H, @R0
	MOV R2, #00H
	loop_H : MOV A, #00H
	loop_L : INC A
		CJNE A, #0FFH, loop_L
		INC R2
		MOV A, R2
		CJNE A, 51H, loop_H
		DEC R0
		MOV 51H, @R0
		MOV A, #00H
	last_loop : INC A
		CJNE A, 51H, last_loop
RET

delay_50ms : MOV R0, #40H
	MOV @R0, #012H
	INC R0
	MOV @R0, #058H
	DEC R0
	ACALL delay_cjne
RET

delay_1s : MOV 60H, #14H
	loop : ACALL delay_50ms
	DJNZ 60H, loop
RET
end