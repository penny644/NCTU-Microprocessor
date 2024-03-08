	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	leds: .byte 0
.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR, 0x4800000C
	.equ GPIOA_ODR, 0x48000014

	//use to delay one second
	.equ X, 0x27100	//160000
	.equ Y, 0x5		//5
main:
	BL GPIO_init
	MOVS R1, #1
	LDR R0, =leds
	STRB R1, [R0]
	MOV R8, #0 //counter
	LDR R5, =GPIOA_ODR

Loop:
	/* TODO: Write the display pattern into leds variable */
	BL DisplayLED
	BL Delay
	B Loop

GPIO_init:
	/* TODO: Initialize LED GPIO pins as output */

	// Enable AHB2 clock
	ldr R0, =RCC_AHB2ENR
	mov R1, #1
	str R1, [R0]

	// Set pins (Ex. PA4-7) as output mode
	mov R0, #0x5500	//0101 0101 0000 0000
	ldr R1, =GPIOA_MODER
	ldr R2, [R1]
	and R2, #0xFFFF00FF //1111 1111 1111 1111 0000 0000 1111 1111
	orr R2, R2, R0
	str R2, [R1]

	// Keep PUPDR as the default value(pull-up).
	mov R0, #0x5500	//0101 0101 0000 0000
	ldr R1, =GPIOA_PUPDR
	ldr R2, [R1]
	and R2, #0xFFFF00FF
	orr R2, R2, R0
	str R2, [R1]

	// Set output speed register
	mov R0, #0xAA00	//1010 1010 0000 0000
	ldr R1, =GPIOA_OSPEEDR
	ldr R2, [R1]
	and R2, #0xFFFF00FF
	orr R2, R2, R0
	str R2, [R1]

	BX LR

DisplayLED:
	/* TODO: Display LED by leds */
	LDR R6, [R0]
	MOV R6, R6, LSL #4 //R6=R6<<4
	MVN R7, R6 //R7=~R6
	STRB R7, [R5]

	//0001
	CMP R8, #0
	ITTTT EQ
	MOVEQ R6, #3 //0011
	STREQ R6, [R0]
	ADDEQ R8, R8, #1
	BEQ Finish

	//0011
	CMP R8, #1
	ITTTT EQ
	MOVEQ R6, #6 //0110
	STREQ R6, [R0]
	ADDEQ R8, R8, #1
	BEQ Finish

	//0110
	CMP R8, #2
	ITTTT EQ
	MOVEQ R6, #12 //1100
	STREQ R6, [R0]
	ADDEQ R8, R8, #1
	BEQ Finish

	//1100
	CMP R8, #3
	ITTTT EQ
	MOVEQ R6, #8 //1000
	STREQ R6, [R0]
	ADDEQ R8, R8, #1
	BEQ Finish

	//1000
	CMP R8, #4
	ITTTT EQ
	MOVEQ R6, #12 //1100
	STREQ R6, [R0]
	ADDEQ R8, R8, #1
	BEQ Finish

	//1100
	CMP R8, #5
	ITTTT EQ
	MOVEQ R6, #6 //0110
	STREQ R6, [R0]
	ADDEQ R8, R8, #1
	BEQ Finish

	//0110
	CMP R8, #6
	ITTTT EQ
	MOVEQ R6, #3 //0011
	STREQ R6, [R0]
	ADDEQ R8, R8, #1
	BEQ Finish

	//0011
	CMP R8, #7
	ITTTT EQ
	MOVEQ R6, #1 //0001
	STREQ R6, [R0]
	MOVEQ R8, #0
	BEQ Finish

Finish:
	BX LR

Delay:
	/* TODO: Write a delay 1 sec function */
	// You can implement this part by busy waiting.
	// Timer and Interrupt will be introduced in later lectures.
		LDR R3, =X
	L1:
		LDR R4,	=Y
	L2:
		SUBS R4,#1
		BNE L2
		SUBS R3,#1
		BNE L1
		BX LR
