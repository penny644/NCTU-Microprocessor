	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	result: .zero 8
.text
	.global main
	.equ X, 0x12345678
	.equ Y, 0xABCDEF00
main:
	LDR R0, =X
	LDR R1, =Y
	LDR R2, =result
	MOV R11, #0
	BL kara_mul
L:
	B L
kara_mul:
//TODO: Separate the leftmost and rightmost halves into
//different registers; then do the Karatsuba algorithm.
	MOV R3, R0, LSR #16	//XL
	MOV R4, R0, LSL #16
	MOV R4, R4, LSR #16	//XR
	MOV R5, R1, LSR #16	//YL
	MOV R6, R1, LSL #16
	MOV R6, R6, LSR #16	//YR
	MUL R7, R3, R5	//left 32 bits (XL*YL)
	ADD R8, R3, R4	//(XL+XR) 17bits
	ADD R9, R5, R6	//(YL+YR) 17bits
	UMULL R8, R12, R8, R9	//(XL+XR)(YL+YR),R8 is low 32 bits,R12 is high 32 bits
	MUL R9, R4, R6	//right 32 bits (XR*YR)
	ADDS R10, R7, R9	//(XL*YL+YL*YR)
	ADC R11, R11, #0	//R11=R11+0+carry
	SUBS R8, R8, R10 //middle 32 bits (XL+XR)(YL+YR)-(XL*YL+YL*YR)
	SBC R12, R12, R11	//R12 is high 32 bit R12=R12-R11-not carry
	MOV R11, R8, LSL #16	//R8 right 16 bits store to R11
	MOV R8, R8, LSR #16	//R8=R8 left 16 bits
	MOV R12, R12, LSL #16	//R12 is 16 bits and R8 left 16bits is 0~15
	ADD R8, R12, R8

	ADDS R11, R9, R11	//((XL+XR)(YL+YR)-(XL*YL+YL*YR))right + right 32 bits (XR*YR)
	ADC R8, R7, R8	//((XL+XR)(YL+YR)-(XL*YL+YL*YR))left + left 32 bits (XR*YR)
	STRD R8, R11, [R2]	//left 32 bits store in r2 and right store in R2+4
	BX LR
