	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	result: .byte 0
.text
	.global main
	.equ X, 0xABCD
	.equ Y, 0xEFAB
main:
	ldr R0, =X //This line will cause an error. Why?
	ldr R1, =Y
	ldr R2, =result
	bl hamm
L: b L

hamm:
	//TODO
	eor R3, R0, R1	//R3=R0 xor R1
	mov R4, #0
	b count

count:
	and R5, R3, #1	//mask R3 AND 1
	add R4, R4, R5	//calculate hamming code
	mov R3, R3, lsr #1 //R3=R3>>1
	cmp R3, #0
	beq finish
	b count

finish:
	str R4, [R2]
	bx lr
