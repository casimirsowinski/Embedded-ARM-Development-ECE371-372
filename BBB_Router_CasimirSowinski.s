@ ECE-317, Project 1
@ Casimir Sowinski
@ 11/14/14
@ Router packet transfer program
@ Checks a packet's checksum against it's checksum byte
@ Transfers data if checksum and checksum byte match
@ Switches from Big-Endian to Little-Endian
@ Returns 0 for success and 1 for failure in R0

.text
.global _start

_start:
.equ	CNT_HEADER, 4				@ Counter value, 4 bytes in header
.equ	CNT_INFO, 12				@ Counter value, 12 words in packet

		LDR	 	R13, =STACK			@ Point SP, R13, to bottom of stack space
		ADD		R13, R13, #0x100	@ Point SP, R13, at top of stack space (plus one byte)
		LDR		R1, =ATM			@ Load pointer for ATM cell into R1
		MOV		R2, #CNT_HEADER		@ Load counter for number of bytes in word into R2
		BL		CHECKSUM			@ Branch and link to CHECKSUM
		NOP							@ For breakpoint
		
		LDR 	R3, =OUTGOING		@ Load pointer to OUTGOING cell into R3
		CMP		R0, #0				@ Check whether to arrange outgoing packet
		BLEQ	TRANSFER			@ Branch and link to TRANSFER if checksums are equal
		NOP							@ For breakpoint
		B		EXIT				@ Exit
				
CHECKSUM:	
		STMFD	R13!, {R6-R8, R14}	@ Save used registers on stack, (push)
		MOV		R7, #0				@ Initiate running checksum, R7, to 0

NEXT:	
		LDRB	R6, [R1], #1		@ Get a byte from header, increment pointer, R1
		ADD		R7, R7, R6			@ Add current byte of header to running sum, R7
		SUBS	R2, R2, #1			@ Decrement counter, R2
		BNE		NEXT				@ Repeat until all 4 elements done
		NOP							@ For breakpoint
		
		LDRB	R8, [R1], #1		@ Load checksum byte, increment pointer, R1
		CMP		R7, R8				@ Compare both checksums for equality
		BNE 	FAIL				@ If checksums =/= goto FAIL
		NOP							@ For breakpoint

SUCCEED:
		MOV		R0, #0				@ Set return value, R0, to 0 (success)
		LDMFD	R13!, {R6-R8, PC}	@ Restore registers and return, (pop)

FAIL:	
		MOV		R0, #1				@ Set return value, R0, to 1 (failure)
		LDMFD	R13!, {R6-R8, PC}	@ Restore registers and return, (pop)
		
@ Move bytes from ATM (B-E) to OUTGOING (L-E)			
TRANSFER:
		STMFD	R13!, {R6-R8, R14}	@ Save used registers on stack, (push)
		MOV		R6, #CNT_INFO		@ Load counter, R6, for number of words in package

SWAP:
		LDRB 	R2, [R1], #1		@ Load byte XX000000 (from R1 into R2) 
		STRB 	R2, [R3, #3]		@ Move to   000000XX (from R2 into R3)			
		LDRB 	R2, [R1], #1		@ Load byte 00XX0000 (from R1 into R2) 
		STRB 	R2, [R3, #2]		@ Move to   0000XX00 (from R2 into R3)				
		LDRB 	R2, [R1], #1		@ Load byte 0000XX00 (from R1 into R2) 
		STRB 	R2, [R3, #1]		@ Move to   00XX0000 (from R2 into R3)				
		LDRB 	R2, [R1], #1		@ Load byte 000000XX (from R1 into R2) 
		STRB 	R2, [R3, #0]		@ Move to   XX000000 (from R2 into R3)
		 		
		ADD		R3, R3, #4			@ Increment counter, R3, to next byte		
		SUBS 	R6, R6, #1			@ Decrement counter, R6, to next word		
		
		BNE 	SWAP				@ Loop to next word
		NOP							@ For breakpoint
		
		MOV 	R0, #0				@ Set return value, R0, to 0 (success)
		LDMFD	R13!, {R6-R8, PC}	@ Restore registers and return, (pop)
		
EXIT:	
		@ Goodbye
		
.data 
.align 4							@ Store data word aligned
@ BB: blank byte
@ L: least significant
@ M: most significant
@ DB: data byte
@ CS: checksum byte
@ TYP: type byte
@ AD(#): address number #
@ W(#): word number #
ATM:
.byte 0x01, 0x01, 0x01, 0x00	@ W01	AD3	AD2	AD1	TYP
.byte 0x04, 0xFF, 0xEE, 0xDD	@ W02	CS	DBM	DB	DB
.byte 0xCC, 0xBB, 0xAA, 0x99	@ W03	DB	DB	DB	DB
.byte 0x88, 0x77, 0x66, 0x55	@ W04	DB	DB	DB	DB
.byte 0x44, 0x33, 0x22, 0x11	@ W05	DB	DB	DB	DB
.byte 0x00, 0xFF, 0xEE, 0xDD	@ W06	DB	DB	DB	DB
.byte 0xCC, 0xBB, 0xAA, 0x99	@ W07	DB	DB	DB	DB
.byte 0x88, 0x77, 0x66, 0x55	@ W08	DB	DB	DB	DB
.byte 0x44, 0x33, 0x22, 0x11	@ W09	DB	DB	DB	DB
.byte 0x00, 0xFF, 0xEE, 0xDD	@ W10	DB	DB	DB	DB
.byte 0xCC, 0xBB, 0xAA, 0x99	@ W11	DB	DB	DB	DB
.byte 0x88, 0x77, 0x66, 0x55	@ W12	DB	DB	DB	DB
.byte 0x44, 0x33, 0x22, 0x11	@ W13	DB	DB	DB	DB
.byte 0x01, 0x00, 0x00, 0x00	@ W14	DBL	BB	BB	BB

STACK:	.rept 256				@ Reserve 256 bytes for stack 
		.byte 0x00				@ Fill with 0's
		.endr
OUTGOING: .SPACE 48				@ Reserve 48 bytes for outgoing packet 
		
.END