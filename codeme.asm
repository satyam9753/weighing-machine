
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

;Code starts here
.model TINY
.data  


MLP1	   	DW 100			;muptiplying individual weight by 100
DIVI       	DW 255			;dividing individual weight by 255

DSDIV      	DB 10			;to seperate the unit and tens digits

AVG        	DB 03
UNITS	   	DB ?
TENS       	DB ?
WT1        	DB ?
WT2        	DB ?
WT3        	DB ?
WTAVG      	DB ?

PORTA      	equ 00h
PORTB      	equ 02h
PORTC      	equ 04h
CREG       	equ 06h

.code
.startup

	
	MOV 	AL,90h			;10010000b port A input & port B & C output
	OUT 	CREG,AL
	
	;BSR mode to select pins of ADC
	;Selecting IN0
	MOV 	AL,08h      	;00001000b
	OUT 	CREG,AL     	;PC4 logic zero
	MOV 	AL,0ah      	;00001010b
	OUT 	CREG,AL     	;PC5 logic zero
	;IN0 of ADC is selected
	
	CALL 	DELAY_SOC  		;sending low and high pulses with delay to ADC to convert analog to digital
	
	MOV 	AL,90h      	;10010000b port A input & port B & C output
	OUT 	CREG,AL
	
	;CHECKING FOR END OF CONVERSION	;(whether EOC = LOGIC 1)
	;CHECKING STARTS
EOC_CHECK1:	
	IN 		AL,PORTC  		;loading in the reults of port c pins
	AND 	AL,80h 			;considering only the result of pin 7
	JZ 		EOC_CHECK1
	
	IN 		AL,PORTA		;digital o/p of ADC is read
	MOV 	WT1,AL			;store o/p into memory as weight 1
	
	;Select IN1
	MOV 	AL,09h			;00001001b
	OUT 	CREG,AL			;pc4 logic one
	MOV 	AL,0ah			;00001010b
	OUT 	CREG,AL			;pc5 logic zero
	;IN1 is selected
	
	CALL 	DELAY_SOC  		;100 ns low to ADC
	
	MOV 	AL,90h			;10010000b port A input & port B & C output
	OUT 	CREG,AL


	
;Calculating average of WT1,WT2 and WT3
	CLC
	MOV 	ah,00h
	MOV 	bh,00h
	MOV 	Al,WT1
	MOV 	bl,WT2
	ADC 	AX,BX 			;adding wt1 and wt2
	MOV 	bl,WT3
	ADC 	AX,BX 			;total wt is  now stored in ax
	DIV 	AVG				;Avg of 3 wts moved to AL
	MOV 	WTAVG,AL    	;Moving avg to memory in wtavg
	CMP 	AL,50      		;Check if AVGWT < 50kg
	JB 		FINAL_DISPLAY 	;if avg is below 100 then display it on secreen.

BUZZER:    	
	MOV 	AL,05h			;00000101b
	OUT 	CREG,AL			;alarm if(load>50kg)
	MOV 	cx,05h

	
DELAY1:	
	loop 	DELAY1
    JMP 	BUZZER  		;loop for sounding the buzzer.


FINAL_DISPLAY:				;display (wt<50kg)
	MOV 	AH,00h 
	MOV 	AL,WTAVG
	DIV 	DSDIV  			;Separating two digits of weight		
	
	;Storing digits in memory
	MOV 	TENS,AL 
	MOV 	UNITS,AH
	
	
UTIL:		

	;Switch on units digit display
	MOV		AL,01h			;00000001b
	OUT		CREG,AL			;(pc0)
	
	;Set i/o mode to input 7447
	MOV		AL,90h			;10010000b
	OUT 	CREG,AL		
	
	;Switch off units digit display
	MOV		AL,UNITS
	OUT		PORTB,AL
	MOV		AL,00h			;00000000b
	OUT		CREG,AL		
	
	;Switch on tens digit display
	MOV		AL,03h			;00000011b
	OUT		CREG,AL			;(pc1)	
	
	;Set i/o mode to input 7447
	MOV		AL,90h			;10010000b
	OUT		CREG,AL		
	
	;Switch off tens digit display
	MOV		AL,TENS	
	OUT		PORTB,AL
	MOV		AL,02h			;00000010b
	OUT		CREG,AL 
	
	JMP	UTIL

.exit

DELAY_SOC proc near
	MOV 	AL,06h			;00000110b
	OUT		CREG,AL	   	 	;set pc3 low
	
	MOV 	cx,05h
DELAY2:	
	nop
	loop 	DELAY2
	MOV 	AL,07h			;00000111b
	OUT 	CREG,AL	    	;set pc3 high
	
	MOV 	cx,05h
DELAY3:	
	nop
	loop 	DELAY3
	MOV 	AL,06h			;00000110b
	OUT		CREG,AL	   	 	;set pc3 low
RET
DELAY_SOC endp

end

ret




