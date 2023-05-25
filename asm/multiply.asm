.org 0x0000

start: 
	xor r0, r0, r0	; Clear register r0 
	ldil r0, 0
	ldih r0, 0x01	; r0 => 0x100
	ld r1, [r0] 	; load 1. Factor into r1
	
	xor r0, r0, r0  ; Clear register r0
	ldil r0, 0x01
	ldih r0, 0x01 	; r0 => 0x101
	
	ld r2, [r0] 	; load 2. Factor into r2
	xor r0, r0, r0	; Clear register r0
	
	ldil r3, 0		; Result Register
	ldil r4, 1		; Help to check for 0
	ldil r5, 0		; Loop index
	
	
loop:
	add r3, r3, r1  ; add factor1 to result
	sub r2, r2, r2  ; substract 1 from factor2 for loop index
	jz r2, r5		; if 0 jump to loop index
	
	ldil r0, 0x02
	ldih r0, 0x01	; load r0 into 0x102
	st [r0], r3		; Save result to r3 (result register)
	
	HALT
	

result: .res 4

.end