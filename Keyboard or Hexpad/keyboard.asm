org 0000h
ljmp start


keyboard EQU P3
LED EQU P1
input EQU P1
header EQU 80h
buffer EQU 82h
RS EQU P0.0		;Command transfer = 0
RW EQU P0.1				;WRITE = 0
EN EQU P0.2
Dat EQU P2

;ISR
org 000BH
CPL P1.7
MOV TH0, #0D8h
MOV TL0, #0E0h
ACALL keyReport
CPL P1.6
RETI


InitBuffer: MOV A, #0h
	MOV header, A
	MOV header+1, A
	RET

keyReport: nop ;setb PSW.3
	MOV R7, A ;Preserve A
	MOV A, R0 
	MOV R6, A ;Preserve R0
	MOV R0, #10h
	MOV A, R1
	MOV @R0, A ;Preserver R1
	MOV R0, #11h
	MOV A, R3
	MOV @R0, A ;Preserve R3
	
	setb 20h ;Cleared by program if no key is pressed
	ACALL findTheKey ; presed key in A
	JNB 20h, noKeyPressed
	ACALL keyInsert
	
	MOV R0, #10h
	MOV A, @R0
	MOV R1, A ;Recover R1
	MOV R0, #11h
	MOV A, @R0
	MOV R3, A ;Recover R3
	MOV A, R6
	MOV R0, A ;Recover R0
	MOV A, R7 ;Recover A
	RET
	noKeyPressed: MOV R0, #11h
		MOV A, @R0
		MOV R3, A ;Recover R3
		MOV A, R6
		MOV R0, A ;Recover R0
		MOV A, R7 ;Recover A
		RET

findTheKey: nop
	MOV keyboard, #0Fh
	MOV A, keyboard
	cjne A, #0Fh, someKeyPressed0
	noKeyPressed0: clr 20h
		
		RET
		
	someKeyPressed0: JNB keyboard.0, col0
		JNB keyboard.1, col1
		JNB keyboard.2, col2
		JNB keyboard.3, col3
		
		col0: MOV R3, #0h
			sjmp rowCheck
		col1: MOV R3, #4h
			sjmp rowCheck
		col2: MOV R3, #8h
			sjmp rowCheck
		col3: MOV R3, #0Ch
			sjmp rowCheck
	
	rowCheck: MOV keyboard, #0F0h
		MOV A, keyboard
		cjne A, #0F0h, someKeyPressed1
		noKeyPressed1: clr 20h
			RET
			
	someKeyPressed1: JNB keyboard.4, row0
		JNB keyboard.5, row1
		JNB keyboard.6, row2
		JNB keyboard.7, row3
		
		row0: MOV A, R3
			ADD A, #0h
			RET
		row1: MOV A, R3
			ADD A, #1h
			RET
		row2: MOV A, R3
			ADD A, #2h
			RET
		row3: MOV A, R3
			ADD A, #3h
			RET
	
keyInsert: MOV R0, A
	MOV R1, #header+1
	MOV A, @R1
	ANL A, #0F0h
	SWAP A
	inAddCheck0: cjne A, #0h, inAddCheck1
		MOV R1, #buffer
		MOV A, @R1
		ANL A, #0F0h
		ADD A, R0
		ACALL putDataHeaderAdj
		RET
	inAddCheck1: cjne A, #1h, inAddCheck2
		MOV R1, #buffer
		MOV A, @R1
		ANL A, #0Fh
		SWAP A
		ADD A, R0
		SWAP A
		ACALL putDataHeaderAdj
		RET
	inAddCheck2: cjne A, #2h, inAddCheck3
		MOV R1, #buffer+1
		MOV A, @R1
		ANL A, #0F0h
		ADD A, R0
		ACALL putDataHeaderAdj
		RET
	inAddCheck3: cjne A, #3h, inAddCheck4
		MOV R1, #buffer+1
		MOV A, @R1
		ANL A, #0Fh
		SWAP A
		ADD A, R0
		SWAP A
		ACALL putDataHeaderAdj
		RET
	inAddCheck4: cjne A, #4h, inAddCheck5
		MOV R1, #buffer+2
		MOV A, @R1
		ANL A, #0F0h
		ADD A, R0
		ACALL putDataHeaderAdj
		RET
	inAddCheck5: cjne A, #5h, inAddCheck6
		MOV R1, #buffer+2
		MOV A, @R1
		ANL A, #0Fh
		SWAP A
		ADD A, R0
		SWAP A
		ACALL putDataHeaderAdj
		RET
	inAddCheck6: cjne A, #6h, inAddCheck7
		MOV R1, #buffer+3
		MOV A, @R1
		ANL A, #0F0h
		ADD A, R0
		ACALL putDataHeaderAdj
		RET
	inAddCheck7: cjne A, #7h, inAddCheck2
		MOV R1, #buffer+3
		MOV A, @R1
		ANL A, #0Fh
		SWAP A
		ADD A, R0
		SWAP A
		ACALL putDataHeaderAdj
		RET
	
	putDataHeaderAdj: MOV @R1, A
		MOV R1, #header
		INC @R1
		cjne @R1, #9h, incIndex
		MOV @R1, 8H
		incIndex: MOV R1, #header+1
			MOV A, @R1
			ANL A, #0F0h
			SWAP A
			INC A
			cjne A, #08h, indexGood
			MOV A, 0h
		indexGood:	SWAP A
			MOV R0, A
			MOV R1, #header+1
			MOV A, @R1
			ANL A, #0Fh
			ADD A, R0
			MOV @R1, A
			RET
			
	
			

;Display subroutines
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

dispASCIIinReg: MOV A, B
	MSBDisp: ANL A, #0F0h	; 16ths digit
		SWAP A
		CJNE A, #0Ah, notEq
		jmp greater
		notEq: JNC greater
			ADD A, #30h
			MOV R1, A
			ACALL dispLetter
			jmp LSBDisp		
		greater: ADD A, #37h
			MOV R1, A 
			ACALL dispLetter
			
	LSBDisp: MOV A, B
		ANL A, #0Fh
		CJNE A, #0Ah, notEqL
		jmp greaterL
		notEqL: JNC greaterL
			ADD A, #30h
			MOV R1, A
			ACALL dispLetter
			RET		
		greaterL: ADD A, #37h
			MOV R1, A 
			ACALL dispLetter
			RET

;Useful subrountines...
dispLetter: ACALL delay_50ms;busyCheck ; The letter to be displayed should be placed in R1
	setb EN
	setb RS
	clr RW
	MOV Dat, R1
	ACALL clearEN
	ACALL setEN
	RET
	
sendCmd: ACALL delay_50ms;busyCheck ; The letter to be displayed should be placed in R1
	setb EN
	clr RS
	clr RW
	MOV Dat, R1
	ACALL clearEN
	ACALL setEN
	RET
		
busyCheck: clr RS
		setb RW
		JBC Dat.7, busyCheck
		RET
		
clearEn: ACALL delay_50ms
	clr EN
	RET

setEn: ACALL delay_50ms
	clr EN
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


start: MOV TH0, #0D8h	;Initialising timer0 to 0000h
	MOV TL0, #0EFh
	MOV TMOD, #01h	;MODE SETTING - Using Timer0 i mode 1
	SETB EA
	SETB ET0
	CLR TF0
	MOV R1, #buffer
	MOV @R1, #0h
	INC R1
	MOV @R1, #0h
	INC R1
	MOV @R1, #0h
	INC R1
	MOV @R1, #0h
	INC R1
	MOV @R1, #0h
	;SETB TR0		;Run timer0
	
mainProg: ACALL keyReport
	ACALL displayData
	sjmp mainProg
	
displayData: ACALL initDisp
	MOV R1, #buffer
	MOV A, R1
	MOV R3, A
	MOV R4, #8h
	Loop1: MOV B, @R1
		ACALL dispASCIIinReg
		MOV R1, #20h ; ASCII code for ' '
		ACALL dispLetter
		INC R3
		MOV A, R3
		MOV R1, A
		DJNZ R4, Loop1
	RET
	
end