	.syntax unified
	.cpu cortex-m4
	.thumb
.data
	counter: .word 0

.text
	.global main

	.equ RCC_AHB2ENR, 0x4002104C

	.equ GPIOB_MODER, 0x48000400
	.equ GPIOB_OTYPER, 0x48000404
	.equ GPIOB_OSPEEDR, 0x48000408
	.equ GPIOB_PUPDR, 0x4800040C
	.equ GPIOB_ODR, 0x48000414
	.equ GPIOB_BSRR, 0x48000418
	.equ GPIOB_BRR, 0x48000428

	.equ GPIOC_MODER, 0x48000800
	.equ GPIOC_OTYPER, 0x48000804
	.equ GPIOC_OSPEEDR, 0x48000808
	.equ GPIOC_PUPDR, 0x4800080C
	.equ GPIOC_IDR, 0x48000810

	.equ DECODE_MODE, 0x09
	.equ DISPLAY_TEST, 0x0F
	.equ SCAN_LIMIT, 0x0B
	.equ INTENSITY, 0x0A
	.equ SHUTDOWN, 0x0C

	.equ DATA, 0x8 //PB3
	.equ LOAD, 0x10 //PB4
	.equ CLOCK, 0x20 //PB5

	.equ X, 0x27100	//160000
	.equ Y, 0x5		//5
	.equ Z, 0x3E8	//1000
	.equ overflow, 0x5F5E0FF
	.equ DIGIT, 0x8
	.equ long_press, 200000	//500000

main:
	BL GPIO_init
	BL max7219_init
	mov r2, #0	//N
	mov r3, #0	//f0
	mov r4, #1	//f1
	mov r5, #0
	mov R12, #1
	push {r0, r1, r2, r3, r4}
	//print blank in all digit
	mov r3, #0
	blank:
		mov r1, #15
		ldr r4, =DIGIT
		sub r2, r4, r3
		mov r0, r2
		BL MAX7219Send
		add r3, r3, #1
		cmp r2, #2
		bne blank
		pop {r0, r1, r2, r3, r4}

	BL Display

Loop:
	push {r0-r9}
	BL CheckPress
	pop {r0-r9}
	cmp r11, #2
	IT EQ
	BEQ reset
	cmp R11, #1	//if button pressed
	ITT EQ
	addeq r2, r2, #1	//r0 is N(N++)
	BLEQ Fibo
	cmp R11, #1
	IT EQ
	BLEQ Display	//display fn
	B Loop

reset:
	mov r2, #0
	mov r3, #0
	mov r4, #1
	mov r5, #0
	BL Display	//display 0
	b Loop

Fibo:
	cmp r2, #1	//if(N==1) r5=r4 and display r5
	ITT EQ
	moveq r5, r4
	beq Finish
	ldr r6, =overflow	//if(r3==99999999) already overflow->finish
	cmp r5, r6
	beq Finish
	add r5, r4, r3	//else r3=r1+r2
	mov r3, r4	//r1=r2
	mov r4, r5	//r2=r3

	//if(r2<99999999) r3=r2
	cmp r5, r6
	IT GT
	movgt r5, r6
	bx lr	//else r3=99999999

Finish:
	bx lr

Display:
	push {r0-r8, lr}
	mov r7, #0
	Display_loop:
		add r7, r7, #1	//r4++
		mov r8, #10	//r0=0
		udiv r9, r5, r8	//r2=r3/10
		mul r9, r9, r8	//r2=r2*10
		sub r10, r5, r9	//r3=r3-r2
		mov r1, r10	//r1=r3 (ans%10)
		mov r0, r7	//r4 is display digit
		BL MAX7219Send
		udiv r5, r5, r8	//r3=r2/10
		cmp r5, #0
		BNE Display_loop
		cmp r7, #8
		IT EQ
		popeq {r0-r8, pc}
	Display_blank://until r4=8
		add r7, r7, #1	//r4!=8->r4++
		mov r0, r7	//r0=r4
		mov r1, #15	//r1=15
		BL MAX7219Send
		cmp r7, #8
		bne Display_blank
	pop {r0-r8, pc}


GPIO_init:
	//TODO: Initialize three GPIO pins as output for max7219 DIN, CS and CLK
	// Enable AHB2 clock
	push {r0-r2}
	ldr R0, =RCC_AHB2ENR
	mov R1, #6
	str R1, [R0]

	// Set pins (Ex. PB3-5) as output mode
	mov R0, #0x540	//010101000000
	ldr R1, =GPIOB_MODER
	ldr R2, [R1]
	and R2, #0xFFFFF03F
	orr R2, R2, R0
	str R2, [R1]

	// Keep PUPDR as the default value(pull-up).
	mov R0, #0x540	//010101000000
	ldr R1, =GPIOB_PUPDR
	ldr R2, [R1]
	and R2, #0xFFFFF03F
	orr R2, R2, R0
	str R2, [R1]

	// Set output speed register
	mov R0, #0xA80	//101010000000
	ldr R1, =GPIOB_OSPEEDR
	ldr R2, [R1]
	and R2, #0xFFFFF03F
	orr R2, R2, R0
	str R2, [R1]

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
	pop {r0-r2}
	BX LR

MAX7219Send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	Push {r0-r9}
	lsl r0, r0, #8	//store r0 to D8~D11
	add r0, r0, r1	//store r1 to data
	ldr r2, =#LOAD
	ldr r3, =#DATA
	ldr r4, =#CLOCK
	ldr r5, =#GPIOB_BSRR
	ldr r6, =#GPIOB_BRR
	mov r7, #16		//r7 = i
	max7219send_loop:
		mov r8, #1
		sub r9, r7, #1
		lsl r8, r8, r9 	// r8 = mask
		str r4, [r6]	//HAL_GPIO_WritePin(GPIOA, CLOCK, 0);
		tst r0, r8
		beq bit_not_set	//bit not set
		str r3, [r5]
		b if_done
	bit_not_set:
		str r3, [r6]
	if_done:
		str r4, [r5]
		subs r7, r7, #1
		bgt max7219send_loop
		str r2, [r6]
		str r2, [r5]
	pop {r0-r9}
	BX LR

max7219_init:
	//TODO: Initial max7219 registers.
	push {r0, r1, r2, lr}

	//NO decode : we have to set each 0 or 1
	ldr r0, =#DECODE_MODE
	ldr r1, =#0xFF
	BL MAX7219Send

	//Turn all LED on: 0 means no operation
	ldr r0, =#DISPLAY_TEST
	ldr r1, =#0x0
	BL MAX7219Send

	//set how many digit we use : 0 means 1 digits
	ldr r0, =#SCAN_LIMIT
	ldr r1, =0x7
	BL MAX7219Send

	ldr r0, =#INTENSITY
	ldr r1, =#0xA
	BL MAX7219Send

	//shutdown : all LED will be turn off(1 is not shutdown)
	ldr r0, =#SHUTDOWN
	ldr r1, =#0x1
	BL MAX7219Send

	pop {r0, r1, r2, pc}

CheckPress:
	/* TODO: Do debounce and check button state */
	ldr r9, =GPIOC_IDR
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
	CMP R4, R3
	BNE CheckZero
	MOV R12, #0
	LDR R3, =long_press
	long_pressed:
		LDR R10, [R9]
		AND R10, 0x2000
		MOV R10, R10, LSR #13
		CMP R10, #0
		ITT NE
		movne R11,#1
		Bxne lr
		CMP R10, #0
		IT EQ
		ADDEQ R4, R4, #1
		CMP R4, R3
		ITE EQ
		MOVEQ R11, #2
		BNE long_pressed
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
