	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	leds: .byte // (or leds: .word)

.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C
	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR, 0x4800000C
	.equ GPIOA_ODR, 0x48000014

	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_OTYPER, 0x48000804
	.equ GPIOC_OSPEEDR, 0x48000808
	.equ GPIOC_PUPDR, 0x4800080C
	.equ GPIOC_IDR, 0x48000810

	.equ X, 0x27100	//160000
	.equ Y, 0x5		//5
	.equ Z, 0x32
main:
	BL GPIO_init
	//(option) Test! Turn on all LEDs
	MOV R1, #0
	LDR R5, =GPIOA_ODR
	STR R1, [R5]

	MOVS R1, #1
	LDR R0, =leds
	STRB R1, [R0]
	MOV R8, #0 //counter
	LDR R5, =GPIOA_ODR
	MOV R12, #1 //bottom state
	LDR R9, =GPIOC_IDR
	MOV R11, #0

Loop:
	/* TODO: Check the button status to determine whether to
	pause updating the LED pattern*/
	BL CheckPress
	BL DisplayLED
	BL Delay
	B Loop

CheckPress:
	/* TODO: Do debounce and check button state */

	LDR R10, [R9]	//read button now state
	AND R10, 0x2000	//R10=PC13(button)
	MOV R10, R10, LSR #13
	MOV R4, #0
	LDR R3, =Z	//R3=50
	CMP R12, R10 //if button state doesn't change -> finish ; else debounce
	BEQ Finish
	CMP R10, #0	//if R10 is 0 calculate # of 0
	BEQ CheckZero
	BNE CheckOne	//else calculate # of 0

CheckZero:
	LDR R10, [R9]
	AND R10, 0x2000
	MOV R10, R10, LSR #13
	CMP R10, #0
	IT EQ
	ADDEQ R4, R4, #1
	CMP R4, R3	//if (# of 0!=50) CheckZero
	BNE CheckZero
	CMP R11, #0	//if(R11==0) r11=1 means stop
	ITE EQ
	MOVEQ R11, #1
	MOVNE R11, #0	//but if R11==1 means stop so we have start
	MOV R12, #0	//button now is pressed
	Bx lr

CheckOne:
	LDR R10, [R9]
	AND R10, 0x2000
	MOV R10, R10, LSR #13
	CMP R10, #1
	IT EQ
	ADDEQ R4, R4, #1
	CMP R4, R3
	BNE CheckOne
	MOV R12, #1	//button now is released
	Bx lr

DisplayLED:
	/* TODO: Display LED by leds */
	LDR R6, [R0]
	MOV R6, R6, LSL #4
	MVN R7, R6
	STRB R7, [R5]

	// if R11==1 means button pressed
	CMP R11, #1
	IT EQ	//so couter(R8)--
	SUBEQ R8, R8, #1
	CMP R8, #0 //if(R8<0) R8=7
	IT LT
	MOVLT R8, #7

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

GPIO_init:
	push {R0,R1,R2}
	/* TODO: Initialize LED, button GPIO pins */
		// Enable AHB2 clock
	ldr R0, =RCC_AHB2ENR
	mov R1, #5
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

	/* Set user button(pc13) as gpio input */
	// set PC13 as input mode
	mov R0, #0x0	//input mode is 00
	ldr R1, =GPIOC_MODER
	ldr R2, [R1]
	and R2, #0xF3FFFFFF
	orr R2, R2, R0
	str R2, [R1]

	// Set PC13 as Pull-up
	mov R0, #0x4000000	//0100000000000000000000000000
	ldr R1, =GPIOC_PUPDR
	ldr R2, [R1]
	and R2, #0xF3FFFFFF
	orr R2, R2, R0
	str R2, [R1]

	pop {R0,R1,R2}
	BX LR

Delay:
	/* TODO: Write a delay 1 sec function */
	// You can implement this part by busy waiting.
	// Timer and Interrupt will be introduced in later lectures.
	push {R3,R4}
		LDR R3, =X
	L1:
		LDR R4,	=Y
	L2:
		SUBS R4,#1
		BNE L2
		SUBS R3,#1
		BNE L1
	pop {R3, R4}
		BX LR

