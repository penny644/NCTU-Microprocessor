	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	arr1: .byte 0x19, 0x34, 0x14, 0x32, 0x52, 0x23, 0x61, 0x29
	arr2: .byte 0x18, 0x17, 0x33, 0x16, 0xFA, 0x20, 0x55, 0xAC

.text
	.global main
	.equ N, 8

do_sort:
//TODO
	ldr r1, =N
	sub r1, r1, #1
	b inner

outer:
	sub r2, r2, #1
	sub r0, r0, #7
	cmp r2, #0
	bne do_sort
	bx lr

inner:
	ldrb r3, [r0]
	ldrb r4, [r0,#1]
	cmp r3, r4
	bgt swap
	cmp r3, r4
	ble next

swap:
	strb r4, [r0]
	add r0, r0, #1
	strb r3, [r0]
	b inner_condition

next:
	add r0, r0, #1
	b inner_condition

inner_condition:
	sub r1, r1, #1
	cmp r1, #0
	bne inner
	b outer

main:
	ldr r0, =arr1
	ldr r2, =N
	sub r2, r2, #1
	bl do_sort
	ldr r0, =arr2
	ldr r2, =N
	sub r2, r2, #1
	bl do_sort

L: b L
