	.syntax unified
	.cpu cortex-m4
	.thumb

.data
	//TODO: put 0 to F 7-Seg LED pattern here
	arr: .byte 0x7E, 0x30, 0x6D, 0x79, 0x33, 0x5B, 0x5F, 0x70, 0x7F, 0x7B, 0x77, 0x1F, 0x4E, 0x3D, 0x4F, 0x47

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
main:
	BL GPIO_init
	BL max7219_init

	ldr R9, =arr
	mov R2, #0


loop:
	BL DisplayDigit
	B loop

GPIO_init:
	//TODO: Initialize GPIO pins for max7219 DIN, CS and CLK
	// Enable AHB2 clock
	ldr R0, =RCC_AHB2ENR
	mov R1, #2
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

	BX LR

DisplayDigit:
	//TODO: Display 0 to F at first digit on 7-SEG LED.
	mov r0, #1	//address : set which digit we have to use(1 mean rightmost bit)
	ldrb r1, [r9, r2]	//load arr[r2] to r1
	BL MAX7219Send
	BL Delay
	add r2, r2, #1	//r2++

	//if(r2!=16) goto DisplayDigit
	cmp r2, #16
	bne DisplayDigit
	//else r2 = 0
	mov r2, #0
	b DisplayDigit
	BX LR

MAX7219Send:
	//input parameter: r0 is ADDRESS , r1 is DATA
	//TODO: Use this function to send a message to max7219
	push {r0-r9}
	lsl r0, r0, #8	//store r0 to D8~D11
	add r0, r0, r1	//store r1 to data
	ldr r2, =#LOAD
	ldr r3, =#DATA
	ldr r4, =#CLOCK
	ldr r5, =#GPIOB_BSRR
	ldr r6, =#GPIOB_BRR
	mov r7, #16		//r7 = i
	max7219send_loop:
		mov r8, #1		// r8=1
		sub r9, r7, #1	// r9=r7-1
		lsl r8, r8, r9 	// r8 = mask
		str r4, [r6]	// BRR[clk]=1-->clk=0
		tst r0, r8		// ands r0, r8 but only update N,Z
		beq bit_not_set	// bit not set
		str r3, [r5]	// BSRR[r3]=1-->data=1
		b if_done
	bit_not_set:
		str r3, [r6]	// BRR[r3]=1-->data=0
	if_done:
		str r4, [r5]	// BSRR[clk]=1-->clk=1
		subs r7, r7, #1	// r7=r7-1
		bgt max7219send_loop	//r7>0 do next loop
		str r2, [r6]	//BRR[load]=1-->load=0
		str r2, [r5]	//BSRR[load]=1-->load=1

	pop {r0-r9}
	BX LR

max7219_init:
	//TODO: Initialize max7219 registers
	push {r0, r1, r2, lr}

	//NO decode : we have to set each 0 or 1
	ldr r0, =#DECODE_MODE
	ldr r1, =#0x0
	BL MAX7219Send

	//Turn all LED on: 0 means no operation
	ldr r0, =#DISPLAY_TEST
	ldr r1, =#0x0
	BL MAX7219Send

	//set how many digit we use : 0 means 1 digits
	ldr r0, =#SCAN_LIMIT
	ldr r1, =0x0
	BL MAX7219Send

	ldr r0, =#INTENSITY
	ldr r1, =#0xA
	BL MAX7219Send

	//shutdown : all LED will be turn off(1 is not shutdown)
	ldr r0, =#SHUTDOWN
	ldr r1, =#0x1
	BL MAX7219Send

	pop {r0, r1, r2, pc}

Delay:
	//TODO: Write a delay 1sec function
		LDR R3, =X
	L1:
		LDR R4,	=Y
	L2:
		SUBS R4,#1
		BNE L2
		SUBS R3,#1
		BNE L1
		BX LR
	BX LR
