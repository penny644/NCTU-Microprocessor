	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	password: .byte 0
.text
	.global main
	.equ RCC_AHB2ENR, 0x4002104C

	.equ GPIOA_MODER, 0x48000000
	.equ GPIOA_OTYPER, 0x48000004
	.equ GPIOA_OSPEEDR, 0x48000008
	.equ GPIOA_PUPDR, 0x4800000C
	.equ GPIOA_ODR, 0x48000014

	.equ GPIOB_MODER, 0x48000400
	.equ GPIOB_OTYPER, 0x48000404
	.equ GPIOB_OSPEEDR, 0x48000408
	.equ GPIOB_PUPDR, 0x4800040C
	.equ GPIOB_IDR, 0x48000410

	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_OTYPER, 0x48000804
	.equ GPIOC_OSPEEDR, 0x48000808
	.equ GPIOC_PUPDR, 0x4800080C
	.equ GPIOC_IDR, 0x48000810

	.equ X, 0x13880	//80000
	.equ Y, 0x5		//5
	.equ Z, 0x32
main:
	BL GPIO_init
	//(option) Test! Turn on all LEDs
	LDR R0, =password
	MOV R1, #13	//password=13
	STR R1, [R0]
	LDR R1, =GPIOA_ODR
	LDR R5, =GPIOB_IDR
	LDR R9, =GPIOC_IDR
	MOV R12, #1

Loop:
	/* TODO: Check the button status to determine whether to
	pause updating the LED pattern*/
	BL CheckPress
	BL CheckPassword
	B Loop

CheckPress:
	/* TODO: Do debounce and check button state */

	LDR R10, [R9]
	AND R10, 0x2000
	MOV R10, R10, LSR #13
	MOV R4, #0
	MOV R11, #0
	LDR R3, =Z
	CMP R12, R10
	BEQ Finish
	CMP R10, #0
	BEQ CheckZero
	BNE CheckOne

CheckZero:
	LDR R10, [R9]
	AND R10, 0x2000
	MOV R10, R10, LSR #13
	CMP R10, #0
	IT EQ
	ADDEQ R4, R4, #1
	CMP R4, R3	//SUBS R3, R3, #1
	BNE CheckZero
	MOV R11, #1
	MOV R12, #0
	Bx lr

CheckOne:
	LDR R10, [R9]
	AND R10, 0x2000
	MOV R10, R10, LSR #13
	CMP R10, #1
	IT EQ
	ADDEQ R4, R4, #1
	CMP R4, R3	//SUBS R3, R3, #1
	BNE CheckOne
	MOV R12, #1
	Bx lr

CheckPassword:
	CMP R11, #1
	BNE Finish	// not press->finish
	LDR R6, [R5]	//ldr the answer of switch
	MOV R6, R6, LSR #8
	AND R6, R6, #15 //R6=R6 and 1111
	LDR R0, =password
	LDR R7, [R0]
	CMP R6, R7
	MOV R8, #3	//calculate bling 3 times
	BEQ Correct
	//if wrong bling one time
	//Set PA5 as low then delay
	movs r0, #0
	strh r0, [r1]
	bl Delay
	//Set PA5 as high then delay
	movs r0, #(1<<5)
	strh r0, [r1]
	B Loop

Correct:
	//Set PA5 as low then delay
	movs r0, #0
	strh r0, [r1]
	bl Delay
	//Set PA5 as high then delay
	movs r0, #(1<<5)
	strh r0, [r1]
	bl Delay
	SUBS R8, R8, #1
	BNE Correct
	B Loop

Finish:
	BX LR

GPIO_init:
	/* TODO: Initialize LED, button GPIO pins */
		// Enable AHB2 clock
	ldr R0, =RCC_AHB2ENR
	mov R1, #7
	str R1, [R0]

	// Set pins (Ex. PB8-11) as input mode
	mov R0, #0x0
	ldr R1, =GPIOB_MODER
	ldr R2, [R1]
	and R2, #0xFF00FFFF	//1111 1111 0000 0000 1111 1111 1111 1111
	orr R2, R2, R0
	str R2, [R1]

	// Keep PUPDR as the default value(pull-up).
	ldr R0, =0x550000	//0101 0101 0000 0000 0000 0000
	ldr R1, =GPIOB_PUPDR
	ldr R2, [R1]
	and R2, #0xFF00FFFF
	orr R2, R2, R0
	str R2, [R1]

	//Set PA5 as output
	mov R0, #0x400
	ldr R1, =GPIOA_MODER
 	ldr R2, [R1]
	and R2, #0xfffff3ff
	orr R2, R2, R0
	str R2, [R1]

	//Set PA5 as pull up
	mov R0, #0x400
	ldr R1, =GPIOA_PUPDR
	ldr R2, [R1]
	and R2, #0xfffff3ff
	orr R2, R2, R0
	str R2, [R1]

	//set PA5 high speed mode
	mov R0, #0x800
	ldr R1, =GPIOA_OSPEEDR
	ldrh R0, [R1]

	//turn off LED
	LDR R0, =GPIOA_ODR
	MOV R1, #(1<<5)
	STR R1, [R0]


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

