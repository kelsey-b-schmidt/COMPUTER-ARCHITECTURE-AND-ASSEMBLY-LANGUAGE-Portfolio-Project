TITLE Project6 schmkels		(Proj6_schmkels.asm)

; Author: Kelsey Schmidt
; Last Modified: 06/05/2022
; OSU email address: schmkels@oregonstate.edu
; Course number/section:    CS271 Section 400
; Project Number:65               Due Date: 06/05/2022
; Description:	This program introduces the program and programmer, 
;					displays a promt with instructions,
;					gets 10 integers from the user as strings,
;					validates the strings to a SDWORD format,
;					stores these numeric values in an array,
;					converts each back to a string,
;					displays the string integers, their sum, and their truncated average,
;					and says goodbye to the user.
INCLUDE Irvine32.inc


; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Description:
;	Displays a prompt, gets the user’s keyboard input into a memory location, and saves the number of bytes read to a memory location.
;
; Preconditions: 
;	Do not use EAX, ECX, EDX as arguments,
;
; Postconditions:
;	inString characters initialzed as user's input from keyboard, number of bytes read saved in stringLength global variable
;
; Receives:
;	promptMemoryLocation = memory location of prompt BYTE string,
;	inStringMemoryLocation =  memory location of uninitialized BYTE string to receive input, 
;	maxStringLengthConstant = a constant indicating the max desired string length to be received,
;	stringLengthMemoryLocation = memory location of unitialized DWORD, to receive amount of bytes read during ReadString
;
; Returns: 
;	None
; ---------------------------------------------------------------------------------
mGetString MACRO promptMemoryLocation:REQ, inStringMemoryLocation:REQ, maxStringLengthConstant:REQ, stringLengthMemoryLocation:REQ
	mDisplayString promptMemoryLocation

	; preserve registers
	PUSH	EAX					
	PUSH	EBX					
	PUSH	ECX
	PUSH	EDX

	MOV		EDX, inStringMemoryLocation
	MOV		ECX, maxStringLengthConstant
	CALL	ReadString
	MOV		EBX, stringLengthMemoryLocation
	MOV		[EBX], EAX

	; restore registers
	POP		EDX					
	POP		ECX
	POP		EBX
	POP		EAX
ENDM

; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Description:
;	Prints the string which is stored in a specified memory location.
;
; Preconditions: 
;	Do not use EDX as argument
;
; Postconditions:
;	String is printed to the console
;
; Receives:
;	memoryLocation = memory location of BYTE string to be printed
;
; Returns: 
;	None
; ---------------------------------------------------------------------------------
mDisplayString MACRO memoryLocation:REQ
	; preserve register
    PUSH	EDX	

    MOV		EDX, memoryLocation
    CALL	WriteString

	; restore register
    POP		EDX					
ENDM


MAXSTRINGLENGTH = 1000

.data

intro			BYTE	"Hi, my name is Kelsey Schmidt, and this is my project: Proj6_schmkels.asm",13,10,13,10
				BYTE	"Please provide 10 signed decimal integers.",13,10
				BYTE	"Each number needs to be small enough to fit inside a 32 bit register.",13,10
				BYTE	"After you have finished inputting the raw numbers,",13,10
				BYTE	"I will display a list of the integers, their sum, and their average value. ",13,10,13,10,0
prompt			BYTE	"Please enter a signed number: ",0
allNumbers		BYTE	"You entered the following numbers: ",0
commaSpace		BYTE	", ",0
sumOfNUmbers	BYTE	"The sum of these numbers is: ",0
averageText		BYTE	"The truncated average is: ",0
error			BYTE	"ERROR: Invalid number. Please try again.",0
goodbye			BYTE	"Thanks for playing! Goodbye!",13,10,0

inString		BYTE	MAXSTRINGLENGTH+1 DUP(?)	; user String
reversedString	BYTE	MAXSTRINGLENGTH+1 DUP(?)	; reversed String
backToString	BYTE	MAXSTRINGLENGTH+1 DUP(?)	; re-converted string from SDWORD
reversedString2	BYTE	MAXSTRINGLENGTH+1 DUP(?)	; reversed re-converted string from SDWORD
valArray		SDWORD	10 DUP(?)					; array to hold valid entries
stringLength	SDWORD	?							; length of entered string
place			DWORD	?							; number place (1, 10, 100, 1000, etc.)
placeOverflow	DWORD	?							; indicates if place has overflown
negative		DWORD	?							; indicates negative input (0 for positive, 1 for negative)
enteredNumber	SDWORD	?							; converted signed integer
sum				SDWORD	?							; sum of integers
average			SDWORD	?							; sum of integers


.code
main PROC
	; introduction
	mDisplayString	OFFSET intro

	; get the numbers
	MOV		EDI, OFFSET valArray		; Address of first element of valArray into EDI
	MOV		ECX, 10						; start loop counter for valid entries and for adding to the array
_getNumbersLoop:	
	PUSH	OFFSET placeOverflow
	PUSH	OFFSET prompt
	PUSH	OFFSET error
	PUSH	OFFSET inString
	PUSH	OFFSET reversedString
	PUSH	OFFSET stringLength
	PUSH	OFFSET place
	PUSH	OFFSET negative
	PUSH	OFFSET enteredNumber
	CALL	ReadVal						; get input

	MOV		EAX, enteredNumber			; copy enteredNumber into array
	MOV		[EDI], EAX
	ADD		EDI, TYPE valArray			; Increment ESI by 4 to point to the next element of valArray
	LOOP	_getNumbersLoop


	; print the numbers
	Call	Crlf
	mDisplayString OFFSET allNumbers
	CALL	Crlf
	MOV		ESI, OFFSET valArray		; Address of first element of valArray into ESI
	MOV		ECX, 10						; Number of elements of valArray into ECX
	MOV		sum, 0						; initiate sum

_printArrayLoop:
	MOV		EAX, [ESI]					; n-th element of valArray into EAX
	ADD		sum, EAX					; add to sum
	PUSH	EAX
	PUSH	OFFSET backToString
	PUSH	OFFSET reversedString2
	PUSH	OFFSET stringLength
	CALL	WriteVal
	CMP		ECX, 1						; on last number we don't need the comma
	JE		_finishPrint
	mDisplayString OFFSET commaSpace
	ADD		ESI, TYPE valArray			;Increment ESI by 4 to point to the next element of valArray
	LOOP	_printArrayLoop

_finishPrint:
	CALL	Crlf
	mDisplayString OFFSET sumOfNumbers	; display sum
	PUSH	sum
	PUSH	OFFSET backToString
	PUSH	OFFSET reversedString2
	PUSH	OFFSET stringLength
	CALL	WriteVal

	MOV		EAX, sum					; prep for division to get average
	CDQ
	MOV		EBX, 10
	IDIV	EBX
	MOV		average, EAX
	
	CALL	Crlf
	mDisplayString OFFSET averageText	; display average
	PUSH	average						
	PUSH	OFFSET backToString
	PUSH	OFFSET reversedString2
	PUSH	OFFSET stringLength
	CALL	WriteVal

	; goodbye
	CALL	CrLf
	mDisplayString	OFFSET goodbye		

	; exit to operating system
	Invoke ExitProcess,0				
main ENDP



; ---------------------------------------------------------------------------------
; Name:	ReadVal
;
; Description:		
;	Invokes the mGetString macro to get user input in the form of a string of digits,
;	Converts the string of ASCII digits to its numeric value representation (SDWORD), 
;	validates the user’s input is a valid number (no letters, symbols, etc),
;	and stores this value in a memory variable enteredNumber. 
;
; Preconditions:	
;	Items pushed to the call stack in the following order BEFORE calling procedure:
;		PUSH	OFFSET placeOverflow
;		PUSH	OFFSET prompt
;		PUSH	OFFSET error
;		PUSH	OFFSET inString
;		PUSH	OFFSET reversedString
;		PUSH	OFFSET stringLength
;		PUSH	OFFSET place
;		PUSH	OFFSET negative
;		PUSH	OFFSET enteredNumber
;
; Postconditions:	
;	Validated string converted to SDWORD and stored in enteredNumber
;	Registers changed during procedure: 
;		EAX, EBX, ECX, EDX, EDI, ESI
;	(all registers are restored at end of procedure)
;
; Receives:			
;	global variables: 
;		placeOverflow
;		prompt
;		error
;		inString
;		reversedString
;		stringLength
;		place
;		negative
;		enteredNumber
;	constants: 
;		MAXSTRINGLENGTH
;
; Returns:			
;	None
; ---------------------------------------------------------------------------------
ReadVal		PROC
	PUSH	EBP							; Preserve EBP
	MOV		EBP, ESP					; Assign static stack-frame pointer

	PUSH	EAX							; Preserve registers
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI
	
_getString:
	mGetString [EBP+36], [EBP+28], MAXSTRINGLENGTH, [EBP+20]

	CLD									; Set up loop counter and indices
	MOV		EBX, [EBP+20]
	MOV		ECX, [EBX]
	MOV		ESI, [EBP+28]
	MOV		EDI, [EBP+24]

	JMP		_validateStringLoop			; validate string

_invalidNumber:
	mDisplayString [EBP+32]
	CALL	Crlf
	JMP		_getString
  
_validateStringLoop:
	LODSB								; Put byte in AL
	MOV		EBX, [EBP+20]
	CMP		ECX, [EBX]					; check if first character is a sign (- or +)
	JE		_checkSign
	CMP		AL, 48						; validate is a number (ASCII range 48-57)
	JL		_invalidNumber
	CMP		AL, 57
	JG		_invalidNumber
	LOOP	_validateStringLoop
	JMP		_validNumberString

_checkSign:
	CMP		AL, 43						; check negative/positive sign
	JE		_positiveSign
	CMP		AL, 45
	JE		_negative
	CMP		AL, 48						; if not a sign, validate is a number (ASCII range 48-57)
	JL		_invalidNumber				
	CMP		AL, 57
	JG		_invalidNumber
	JMP		_positive					; if no sign and is a number, process as positive entry

_positiveSign:
	CMP		ECX, 1						; if first digit is a + but is the only character, break
	JE		_invalidNumber

_positive:
	MOV		EAX, 0						; set negative variable value
	MOV		EBX, [EBP+12]
	MOV		[EBX], EAX
	LOOP	_validateStringLoop
	JMP		_validNumberString

_negative:
	CMP		ECX, 1						; if first digit is a - but is the only character, break
	JE		_invalidNumber

	MOV		EAX, 1						; set negative variable value
	MOV		EBX, [EBP+12]
	MOV		[EBX], EAX

	LOOP	_validateStringLoop

_validNumberString:
	MOV		EBX, [EBP+20]
	MOV		ECX, [EBX]					; Set up loop counter and indices	
	MOV		ESI, [EBP+28]
	ADD		ESI, ECX
	DEC		ESI
	MOV		EDI, [EBP+24]
  
_revLoop:								; Reverse string
    STD
    LODSB
    CLD
    STOSB
	LOOP	_revLoop

_processNumber:	
	MOV		EAX, 0						; set placeOverflow variable value
	MOV		EBX, [EBP+40]
	MOV		[EBX], EAX


	MOV		EAX, 0						; start with value of 0 in 1's place
	MOV		EBX, [EBP+8]
	MOV		[EBX], EAX
	MOV		EAX, 1
	MOV		EBX, [EBP+16]
	MOV		[EBX], EAX

	CLD									; Set up loop counter and indices
	MOV		EBX, [EBP+20]
	MOV		ECX, [EBX]
	MOV		ESI, [EBP+24]
	CMP		ECX, 1
	JE		_onlyDigit					; if only one digit no need to loop
	MOV		EAX, 0
	MOV		EBX, [EBP+12]
	CMP		[EBX], EAX					; if positive number, do positive loop, if negative do negative loop
	JE		_positiveLoop
	JMP		_negativeLoop

_onlyDigit:
	LODSB								; Put byte in AL
	SUB		AL, 48						; convert ASCII to number
	MOVSX	EAX, AL						; extend 

	MOV		EBX, [EBP+8]
	ADD		[EBX], EAX					; add to enteredNumber
	JMP		_finished

_positiveLoop:
	CMP		ECX, 1						; on last digit check for sign
	JE		_lastDigit
	LODSB								; Put byte in AL
	SUB		AL, 48						; convert ASCII to number
	MOVSX	EAX, AL						; extend and multiply by place if over 0
	CMP		EAX, 0
	JE		_zero
	MOV		EDX, [EBP+40]
	MOV		EBX, [EDX]
	CMP		EBX, 1						; if place has overflowed, invalid number, do not multiply
	JE		_invalidNumber
	MOV		EDX, [EBP+16]
	MOV		EBX, [EDX]
	IMUL	EBX
	JO		_invalidNumber				; if overflow occurs, invalid number

	MOV		EBX, [EBP+8]				; add to number
	ADD		[EBX], EAX					
	JO		_invalidNumber				; if overflow occurs, invalid number

	MOV		EBX, [EBP+16]				; increase place
	MOV		EAX, [EBX]	
	MOV		EBX, 10
	IMUL	EBX
	MOV		EBX, [EBP+16]
	MOV		[EBX], EAX
	JO		_placeOverflow

	LOOP	_positiveLoop	

_zero:
	MOV		EBX, [EBP+16]				; increase place
	MOV		EAX, [EBX]	
	MOV		EBX, 10
	IMUL	EBX
	MOV		EBX, [EBP+16]
	MOV		[EBX], EAX
	JO		_placeOverflow

	LOOP	_positiveLoop	
	
_placeOverflow:
	MOV		EAX, 1						; set placeOverflow variable value
	MOV		EBX, [EBP+40]
	MOV		[EBX], EAX
	LOOP	_positiveLoop	

_lastDigit:
	LODSB								; Put byte in AL
	CMP		AL, 43						; look for plus sign (+), if found we are done converting number
	JE		_finished

	SUB		AL, 48						; convert to ASCII
	MOVSX	EAX, AL						; extend and multiply by place if over 0
	CMP		EAX, 0
	JE		_finished					; if last digit 0, we're done
	MOV		EDX, [EBP+40]
	MOV		EBX, [EDX]
	CMP		EBX, 1						; if place has overflowed, invalid number, do not multiply
	JE		_invalidNumber
	MOV		EDX, [EBP+16]
	MOV		EBX, [EDX]
	IMUL	EBX
	JO		_invalidNumber				; if overflow occurs, invalid number

	MOV		EBX, [EBP+8]				; add to number
	ADD		[EBX], EAX					
	JO		_invalidNumber				; if overflow occurs, invalid number
	JMP		_finished	

_negativeLoop:
	CMP		ECX, 1						; last digit will be negative sign (-), so we can be done
	JE		_finished
	LODSB								; Put byte in AL
	SUB		AL, 48						; convert ASCII to number
	MOVSX	EAX, AL						; extend and multiply by place if over 0
	CMP		EAX, 0
	JE		_zero2
	MOV		EDX, [EBP+40]
	MOV		EBX, [EDX]
	CMP		EBX, 1						; if place has overflowed, invalid number, do not multiply
	JE		_invalidNumber
	MOV		EDX, [EBP+16]
	MOV		EBX, [EDX]
	IMUL	EBX
	JO		_invalidNumber				; if overflow occurs, invalid number

	MOV		EBX, [EBP+8]				; subtract from number
	SUB		[EBX], EAX					
	JO		_invalidNumber				; if overflow occurs, invalid number

	MOV		EBX, [EBP+16]				; increase place
	MOV		EAX, [EBX]	
	MOV		EBX, 10
	IMUL	EBX
	MOV		EBX, [EBP+16]
	MOV		[EBX], EAX
	JO		_placeOverflow2

	LOOP	_negativeLoop		
	
_zero2:			
	MOV		EBX, [EBP+16]				; increase place
	MOV		EAX, [EBX]	
	MOV		EBX, 10
	IMUL	EBX
	MOV		EBX, [EBP+16]
	MOV		[EBX], EAX
	JO		_placeOverflow2

	LOOP	_negativeLoop

_placeOverflow2:
	MOV		EAX, 1						; set placeOverflow variable value
	MOV		EBX, [EBP+40]
	MOV		[EBX], EAX
	LOOP	_negativeLoop	

_finished:	
										; reset inString
	CLD									; Set up loop counter and indices
	MOV		EBX, [EBP+20]
	MOV		ECX, [EBX]
	MOV		ESI, [EBP+28]
	MOV		EDI, [EBP+28]

_resetInstringLoop:
	MOV		AL, 0						; Put 0 in AL
	STOSB								; overwrite byte
	LOOP	_resetInstringLoop

										; reset reversedString
	CLD									; Set up loop counter and indices
	MOV		EBX, [EBP+20]
	MOV		ECX, [EBX]
	MOV		ESI, [EBP+24]
	MOV		EDI, [EBP+24]

_resetReverseStringLoop:
	MOV		AL, 0						; Put 0 in AL
	STOSB								; overwrite byte
	LOOP	_resetReverseStringLoop

	POP		ESI							; restore registers
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX

	POP		EBP							; restore EBP
	RET		36
ReadVal		ENDP

; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Description:		
;	Converts a numeric SDWORD value to a string of ASCII digits, 
;	Invokes the mDisplayString macro to print the ASCII representation of the SDWORD value to the console.
;
; Preconditions:	
;	Items pushed to the call stack in the following order BEFORE calling procedure:
;		PUSH	[number to be converted]
;		PUSH	OFFSET backToString
;		PUSH	OFFSET reversedString2
;		PUSH	OFFSET stringLength
;
; Postconditions:	
;	ASCII representation of SDWORD value printed to the console.
;	Registers changed during procedure: 
;		EAX, EBX, ECX, EDX, EDI, ESI
;	(all registers are restored at end of procedure)
;
; Receives:			
;	global variables: 
;		placeOverflow
;		prompt
;		error
;		inString
;		reversedString
;		stringLength
;		place
;		negative
;		enteredNumber
;	constants: 
;		MAXSTRINGLENGTH
;
; Returns:			
;	None
; ---------------------------------------------------------------------------------
WriteVal	PROC
	PUSH	EBP							; Preserve EBP
	MOV		EBP, ESP					; Assign static stack-frame pointer

	PUSH	EAX							; Preserve registers
	PUSH	EBX
	PUSH	ECX
	PUSH	EDX
	PUSH	EDI
	PUSH	ESI

	MOV		EAX, [EBP+20]				; move desired number to convert into EAX
	CMP		EAX, 0						; check for negative number
	JL		_changeSign
	JMP		_ASCIIConvert

_changeSign:
	MOV		EBX, -1						; change back to positive for conversion (will add negative back at end)
	MUL		EBX	
	
_ASCIIConvert:
	CLD									; Set up loop counter and indices
	MOV		ECX, MAXSTRINGLENGTH
	MOV		EDI, [EBP+16]
	MOV		EBX, 0						; count elements converted to get new stringLength

_backToStringLoop:
	; ASCII can be fund by repeatedly dividing number by 10, 
	; remainder+48 will be first ASCII digit, which can be saved to BYTE string array, 
	; and divide quotient again for next digit, ets., until 0 is reached.
	; These will be stored in reverse order and need to be reversed when finished

	MOV		EDX, 0						; prep for division
	PUSH	EBX							; don't disrupt digit counter
	MOV		EBX, 10
	DIV		EBX							; quotient in EAX, remainder in EDX
	POP		EBX
	ADD		EDX, 48						; convert to ASCII
	PUSH	EAX							; store into backToString
	MOV		AL, DL						
	STOSB
	POP		EAX

	INC		EBX							; increment digit counter

	CMP		EAX, 0						; once quotient reaches 0, we're done
	JE		_conversionDone
	LOOP	_backToStringLoop

_conversionDone:
	MOV		EDX, [EBP+20]						
	CMP		EDX, 0						; if real number is negative, add a neagtive sign ASCII
	JL		_addSign
	JMP		_reverseString

_addSign:
	MOV		AL, 45						; add negative sign at end of string
	STOSB
	INC		EBX
	JMP		_reverseString

_reverseString:
	MOV		EAX, EBX					; set stringLength
	MOV		EBX, [EBP+8]
	MOV		[EBX], EAX

	MOV		EBX, [EBP+8]
	MOV		ECX, [EBX]					; Set up loop counter and indices
	MOV		ESI, [EBP+16]
	ADD		ESI, ECX
	DEC		ESI
	MOV		EDI, [EBP+12]
  
_revLoop:
	STD
	LODSB
	CLD
	STOSB
	LOOP   _revLoop

_finished:
	mDisplayString [EBP+12]				; display string

										; reset backToString
	CLD									; Set up loop counter and indices
	MOV		EBX, [EBP+8]
	MOV		ECX, [EBX]
	MOV		ESI, [EBP+16]
	MOV		EDI, [EBP+16]

_resetBackToStringLoop:
	MOV		AL, 0						; Put 0 in AL
	STOSB								; overwrite byte
	LOOP	_resetBackToStringLoop

										; reset reversedString2
	CLD									; Set up loop counter and indices
	MOV		EBX, [EBP+8]
	MOV		ECX, [EBX]
	MOV		ESI, [EBP+12]
	MOV		EDI, [EBP+12]

_resetReverseString2Loop:
	MOV		AL, 0						; Put 0 in AL
	STOSB								; overwrite byte
	LOOP	_resetReverseString2Loop

	POP		ESI							; restore registers
	POP		EDI
	POP		EDX
	POP		ECX
	POP		EBX
	POP		EAX

	POP		EBP							; restore EBP
	RET		16

WriteVal	ENDP



END main
