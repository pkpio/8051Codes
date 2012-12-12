;port declarations
enable equ p0.2				;acts like a clock to the LCD
comData equ p0.0			;command = 0, data = 1
writeRead equ p0.1			;write = 0 , read = 1
dataBus equ p2				;datalines
initByte1 equ 38h;#00111000b		;init communication(4bit, 8bit), font and no. of lines
initByte2 equ 0eh;#00001110b		;init - display ,cursor, blink (last 3 bits)
initByte3 equ 06h	;init - increment/decrement cursor , scroll display	
hourAddr equ 40h
minAddr equ 41h
secAddr equ 42h
org 0000h
ljmp startOfProgram

org 000bh
ljmp timerInterrupt

;subroutines
;Delay subroutine
org 0100h
			
smallDelay: clr tcon.7
			orl tmod, #10h
			setb tcon.6
			mov th1, #0d0h
smallDelayLoop: jnb tcon.7, smallDelayLoop   
			clr tcon.6
			clr tcon.7
			ret

largeDelay: clr tcon.7
			orl tmod, #10h
			setb tcon.6
			mov th1, #00h
largeDelayLoop: jnb tcon.7, smallDelayLoop   
			clr tcon.6
			clr tcon.7
			ret

;polling subroutine - that reads the status from uP and exits once it is ready
lcdReady:	setb enable	
			setb writeRead
			mov dataBus, #0ffh		;configuring the dataBus as input to check for uP status
			clr enable
			setb enable			
			jb dataBus.7, lcdReady
			clr writeRead
			ret
			
;Configuring the lcd
lcdConfig:	setb enable
			clr writeRead
			clr comData
			mov dataBus, #initByte1
			acall smallDelay
			clr enable
			acall smallDelay
			;First initialization done
			setb enable
			mov dataBus, #initByte2
			acall smallDelay
			clr enable
			acall smallDelay
			;Second initialization done
			setb enable
			mov dataBus, #initByte3
			acall smallDelay
			clr enable
			acall smallDelay
			;Third initialization done, returning
			setb enable
			ret

;takes the value from r4 register and sets the cursor to that point
setCursor: 	setb enable
			clr writeRead
			clr comData
			mov a, #80h
			orl a, r4
			mov dataBus, a
			acall smallDelay
			clr enable
			acall smallDelay
			setb enable
			ret

clearScreen:	setb enable
				clr writeRead
				clr comData
				mov dataBus, #01h
				acall smallDelay
				clr enable
				acall smallDelay
				setb enable
				ret

;Displays data from address stored in DPTR until 0 is reached

displayData:	clr a
				setb enable
				clr writeRead
				setb comData
				
writeNum: 		clr a
				movc a, @a+dptr
				cjne a, #01h, writeByte
				mov a, @r1
				swap a
				mov r7, a
				acall nibbleToAscii
				mov dataBus, r7
				acall smallDelay
				clr enable
				acall smallDelay
				setb enable
				mov a, @r1
				mov r7, a
				inc r1
				acall nibbleToAscii
				mov dataBus, r7
				acall smallDelay
				clr enable
				acall smallDelay
				setb enable
				inc dptr
				clr a
				movc a, @a+dptr
				jz exitDisplayData
				sjmp writeNum
writeByte:		jz exitDisplayData
				mov dataBus, a
				acall smallDelay
				clr enable
				acall smallDelay
				clr a
				inc dptr
				movc a, @a+dptr
				setb enable
				jnz writeNum
exitDisplayData: ret

displayLine1:	db "hh : mm : ss",0
displayLine2:	db 1," : ",1," : ",1,0

;Converts the lower nibble stored in r7 into equivalent ascii representation and stores it back in r7
nibbleToAscii:	mov a, #0fh
				anl a, r7
				add a, #00h
				da a
				jnb acc.4, convert
				inc a
convert:		add a, #30h		
				da a
				mov r7, a
				ret

displayTime:	mov r4, #40h
				mov dptr, #displayLine2
				acall setCursor
				mov r1, #hourAddr
				
				acall displayData
				ret

incLoop:		mov a, #01h
				add a, secAddr
				da a
				mov secAddr, a
				mov a, #60h
				cjne a, secAddr, continue
				mov secAddr, #00h
incMinute:		mov a, #01h
				add a, minAddr
				da a
				mov minAddr, a
				mov a, #60h
				cjne a, minAddr, continue
				;Hour adjustment
				mov minAddr, #00h
incHour:		mov a, #01h
				add a, hourAddr
				da a
				mov hourAddr, a
				mov a, #13h
				cjne a, hourAddr, continue
				mov hourAddr, #01h
continue:		acall displayTime	
				ret
				
timerInterrupt: inc r0
				cjne r0, #32h, exitTimerInterrupt
				mov r0, #00h
readSwitches:	mov a, p1
				anl a, #0fh
				mov r2, a
				acall smallDelay
				mov a, p1
				anl a, #0fh
				clr c
				subb a, r2
				jnz readSwitches 
				mov a, r2
				swap a
				orl a, #0fh
				mov p1, a
				acall smallDelay
				mov a, r2
				jnb acc.0, dontFreezeTimer
				
freezeTimer:	jnb acc.1, checkHourInc
				acall incMinute
checkHourInc:	jnb acc.2, exitTimerInterrupt
				acall incHour
				sjmp exitTimerInterrupt
				sjmp readSwitches
				
dontFreezeTimer:acall incLoop
				reti
exitTimerInterrupt: reti


;start of the main program
startOfProgram: acall lcdConfig
				acall clearScreen
				
				mov r4, #00h
				mov dptr, #displayLine1
				acall setCursor
				acall displayData
				
				mov r1, #hourAddr
				mov @r1, #12h ; hours
				mov r1, #minAddr
				mov @r1, #57h ; minutes
				mov r1, #secAddr
				mov @r1, #19h ; seconds
				acall displayTime

				clr tcon.4
				clr tcon.5
				orl tmod, #01h
				setb tcon.4
				mov ie, #82h
				mov r0, #00h
				mov r3, #00h
				
loop:			sjmp loop
				end
				